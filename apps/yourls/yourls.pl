# apps/yourls/yourls.pl
# Virtualmin Web App installer for YOURLS URL Shortener
#

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path remove_tree);

use Cwd qw(abs_path);

# Include shared libraries
BEGIN {
    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $dir = dirname($real_file);
    unshift @INC, "$dir/lib" if -d "$dir/lib";
    unshift @INC, "$dir/../../lib" if -d "$dir/../../lib";
    unshift @INC, "$dir/../lib" if -d "$dir/../lib";
}

require "Common.pl";

sub script_yourls_desc
{
    return "YOURLS - Your Own URL Shortener";
}

sub script_yourls_uses
{
    return ( "php", "mysql" );
}

sub script_yourls_category
{
    return "Utilities";
}

sub script_yourls_author
{
    return "YOURLS Community";
}

sub script_yourls_site
{
    return "https://yourls.org";
}

sub script_yourls_versions
{
    return ( "1.10.6" );
}

sub script_yourls_release
{
    return 3;
}

sub script_yourls_passmode
{
    return 0;
}

sub script_yourls_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"yourls_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Default: root / or enter /u, /s, etc.)</td> </tr>";

    return $html;
}

sub script_yourls_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'yourls_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_yourls_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "YOURLS requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "YOURLS requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_yourls_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "YOURLS-$ver.tar.gz";
    my $url = "https://github.com/YOURLS/YOURLS/archive/refs/tags/$ver.tar.gz";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_yourls_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "YOURLS-$ver.tar.gz";
    my $url = "https://github.com/YOURLS/YOURLS/archive/refs/tags/$ver.tar.gz";
    my $tmp_file = "/tmp/yourls-$dom-$filename";
    my $tmp_unpack = "/tmp/yourls-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted YOURLS directory
    my @contents = glob("$tmp_unpack/YOURLS-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    my $dbname = $defs->{'db'} || ($user . "_yourls");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || '';
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}" : "";
    my $full_url = "$proto://$dom$url_path";

    # Configure user/config.php if user/config-sample.php exists
    my $sample_conf = "$target_dir/user/config-sample.php";
    my $conf_file = "$target_dir/user/config.php";
    if (-f $sample_conf && !-f $conf_file) {
        if (open(my $in_fh, "<", $sample_conf)) {
            my $conf_data = do { local $/; <$in_fh> };
            close($in_fh);

            my $cookiekey = VirtualminWebApps::Common::generate_random_key(32);
            $conf_data =~ s/'YOURLS_DB_USER',\s*'[^']*'/'YOURLS_DB_USER', '$dbuser'/;
            $conf_data =~ s/'YOURLS_DB_PASS',\s*'[^']*'/'YOURLS_DB_PASS', '$dbpass'/;
            $conf_data =~ s/'YOURLS_DB_NAME',\s*'[^']*'/'YOURLS_DB_NAME', '$dbname'/;
            $conf_data =~ s/'YOURLS_SITE',\s*'[^']*'/'YOURLS_SITE', '$full_url'/;
            $conf_data =~ s/'YOURLS_COOKIEKEY',\s*'[^']*'/'YOURLS_COOKIEKEY', '$cookiekey'/;

            if (open(my $out_fh, ">", $conf_file)) {
                print $out_fh $conf_data;
                close($out_fh);
            }
        }
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $admin_url = "$full_url/admin/";

    return (
        1,
        $admin_url,
        "Installed YOURLS $ver to $full_url. Finish the installation wizard at $admin_url (Database: $dbname, User: $dbuser)."
    );
}

sub script_yourls_uninstall
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
