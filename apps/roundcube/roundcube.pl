# apps/roundcube/roundcube.pl
# Virtualmin Web App installer for Roundcube Webmail
#

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path remove_tree);

# Include shared libraries
BEGIN {
    my $dir = dirname(__FILE__);
    unshift @INC, "$dir/lib" if -d "$dir/lib";
    unshift @INC, "$dir/../../lib" if -d "$dir/../../lib";
    unshift @INC, "$dir/../lib" if -d "$dir/../lib";
}

require "Common.pl";

sub script_roundcube_desc
{
    return "Roundcube Modern Webmail Platform";
}

sub script_roundcube_uses
{
    return ( "php", "mysql" );
}

sub script_roundcube_category
{
    return "Email";
}

sub script_roundcube_author
{
    return "Roundcube Community";
}

sub script_roundcube_site
{
    return "https://roundcube.net";
}

sub script_roundcube_versions
{
    return ( "1.6.9" );
}

sub script_roundcube_release
{
    return 1;
}

sub script_roundcube_passmode
{
    return 0;
}

sub script_roundcube_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"roundcube_dir\" size=\"25\" value=\"webmail\"> ";
    $html .= "(Default: /webmail or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_roundcube_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'roundcube_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    return { 'dir' => $dir };
}

sub script_roundcube_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Roundcube requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Roundcube requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_roundcube_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "roundcubemail-$ver-complete.tar.gz";
    my $url = "https://github.com/roundcube/roundcubemail/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_roundcube_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "roundcubemail-$ver-complete.tar.gz";
    my $url = "https://github.com/roundcube/roundcubemail/releases/download/$ver/$filename";
    my $tmp_file = "/tmp/roundcube-$dom-$filename";
    my $tmp_unpack = "/tmp/roundcube-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy contents of roundcubemail-x.x.x
    my @contents = glob("$tmp_unpack/roundcubemail-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Create config file from sample
    if (-f "$target_dir/config/config.inc.php.sample" && !-f "$target_dir/config/config.inc.php") {
        system("cp -f $target_dir/config/config.inc.php.sample $target_dir/config/config.inc.php");
        
        my $dbname = $defs->{'db'} || ($user . "_roundcube");
        my $dbuser = $defs->{'dbuser'} || $user;
        my $dbpass = $defs->{'dbpass'} || '';

        # Import SQL schema if available
        if (-f "$target_dir/SQL/mysql.initial.sql") {
            my $mysql_cmd = "mysql -u " . quotemeta($dbuser);
            $mysql_cmd .= " -p" . quotemeta($dbpass) if $dbpass;
            $mysql_cmd .= " " . quotemeta($dbname) . " < $target_dir/SQL/mysql.initial.sql 2>/dev/null";
            system($mysql_cmd);
        }

        # Write config
        my $dsn = "mysql://$dbuser:$dbpass\@localhost/$dbname";
        my $des_key = VirtualminWebApps::Common::generate_random_key(24);
        if (open(my $cfh, ">>", "$target_dir/config/config.inc.php")) {
            print $cfh "\n// Virtualmin Auto-Configuration\n";
            print $cfh "\$config['db_dsnw'] = '$dsn';\n";
            print $cfh "\$config['default_host'] = 'localhost';\n";
            print $cfh "\$config['smtp_server'] = 'localhost';\n";
            print $cfh "\$config['smtp_port'] = 25;\n";
            print $cfh "\$config['des_key'] = '$des_key';\n";
            print $cfh "\$config['plugins'] = array('archive', 'zipdownload');\n";
            close($cfh);
        }
    }

    # Ensure writable temp and logs directories
    for my $sub ("temp", "logs") {
        if (-d "$target_dir/$sub") {
            chmod(0777, "$target_dir/$sub");
        }
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Installed Roundcube Webmail to $full_url. Users can log in directly using their domain email accounts."
    );
}

sub script_roundcube_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    if ($opts->{'dir'} && -d $target_dir) {
        remove_tree($target_dir);
    }
    return 1;
}

1;
