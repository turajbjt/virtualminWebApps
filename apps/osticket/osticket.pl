# apps/osticket/osticket.pl
# Virtualmin Web App installer for osTicket Support & Ticketing System
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

sub script_osticket_desc
{
    return "osTicket - Customer Support & Ticketing System";
}

sub script_osticket_uses
{
    return ( "php", "mysql" );
}

sub script_osticket_category
{
    return "Business";
}

sub script_osticket_author
{
    return "Enhancesoft / osTicket Community";
}

sub script_osticket_site
{
    return "https://osticket.com";
}

sub script_osticket_versions
{
    return ( "1.18.1" );
}

sub script_osticket_release
{
    return 1;
}

sub script_osticket_passmode
{
    return 0;
}

sub script_osticket_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"osticket_dir\" size=\"25\" value=\"support\"> ";
    $html .= "(Default: /support or /osticket, leave empty for document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"osticket_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"osticket_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    return $html;
}

sub script_osticket_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'osticket_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);
    return $dir_err if $dir_err;

    my $email = $in->{'osticket_email'} || "admin\@$d->{'dom'}";
    my $pass = $in->{'osticket_pass'} || '';
    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    return {
        'dir'   => $clean_dir,
        'email' => $email,
        'pass'  => $pass,
    };
}

sub script_osticket_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "osTicket requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "osTicket requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_osticket_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "osTicket-v$ver.zip";
    my $url = "https://github.com/osTicket/osTicket/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_osticket_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "osTicket-v$ver.zip";
    my $url = "https://github.com/osTicket/osTicket/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/osticket-$dom-$filename";
    my $tmp_unpack = "/tmp/osticket-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from upload directory if present
    if (-d "$tmp_unpack/upload") {
        system("cp -r $tmp_unpack/upload/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/upload/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}" : "";
    my $full_url = "$proto://$dom$url_path";

    my $dbname = $defs->{'db'} || ($user . "_osticket");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    # Prepare ost-config.php from ost-sampleconfig.php
    my $sample_conf = "$target_dir/include/ost-sampleconfig.php";
    my $conf_file = "$target_dir/include/ost-config.php";

    if (!-f $conf_file && -f $sample_conf) {
        if (open(my $in_fh, "<", $sample_conf)) {
            my $conf_content = do { local $/; <$in_fh> };
            close($in_fh);

            my $salt = VirtualminWebApps::Common::generate_random_key(32);
            $conf_content =~ s/%CONFIG-DBHOST/$dbhost/g;
            $conf_content =~ s/%CONFIG-DBNAME/$dbname/g;
            $conf_content =~ s/%CONFIG-DBUSER/$dbuser/g;
            $conf_content =~ s/%CONFIG-DBPASS/$dbpass/g;
            $conf_content =~ s/%CONFIG-PREFIX/ost_/g;
            $conf_content =~ s/%CONFIG-SKEY/$salt/g;

            if (open(my $out_fh, ">", $conf_file)) {
                print $out_fh $conf_content;
                close($out_fh);
                VirtualminWebApps::Common::secure_file_permissions($conf_file, 0600);
            }
        }
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Register background cron for ticket polling
    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $cron_line = "*/5 * * * * $php_bin $target_dir/api/cron.php >/dev/null 2>&1";
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    if ($current_cron !~ /api\/cron\.php/) {
        my $new_cron = $current_cron . "\n" . $cron_line . "\n";
        if (open(my $cfh, '|-', "crontab -u $user -")) {
            print $cfh $new_cron;
            close($cfh);
        }
    }

    my $setup_url = "$full_url/setup/";

    return (
        1,
        $setup_url,
        "Installed osTicket files at $full_url. Finish the installation wizard at $setup_url (Database: $dbname, User: $dbuser)."
    );
}

sub script_osticket_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $user = $d->{'user'};
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    # Remove cron
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    $current_cron =~ s/.*api\/cron\.php.*\n?//g;
    if (open(my $cfh, '|-', "crontab -u $user -")) {
        print $cfh $current_cron;
        close($cfh);
    }

    if ($opts->{'dir'} && -d $target_dir) {
        remove_tree($target_dir);
    }
    return 1;
}

1;
