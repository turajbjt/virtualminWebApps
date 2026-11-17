# apps/matomo/matomo.pl
# Virtualmin Web App installer for Matomo Analytics (Piwik)
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

sub script_matomo_desc
{
    return "Matomo Web Analytics (Piwik)";
}

sub script_matomo_uses
{
    return ( "php", "mysql" );
}

sub script_matomo_category
{
    return "Analytics";
}

sub script_matomo_author
{
    return "Matomo Team";
}

sub script_matomo_site
{
    return "https://matomo.org";
}

sub script_matomo_versions
{
    return ( "5.1.2", "latest" );
}

sub script_matomo_release
{
    return 2;
}

sub script_matomo_passmode
{
    return 0;
}

sub script_matomo_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"matomo_dir\" size=\"25\" value=\"analytics\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"matomo_admin\" size=\"20\" value=\"admin\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"matomo_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"matomo_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    return $html;
}

sub script_matomo_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'matomo_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    my $admin = $in->{'matomo_admin'} || 'admin';
    my $pass = $in->{'matomo_pass'} || '';
    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }
    my $email = $in->{'matomo_email'} || "admin\@$d->{'dom'}";

    return {
        'dir'   => $dir,
        'admin' => $admin,
        'pass'  => $pass,
        'email' => $email,
    };
}

sub script_matomo_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Matomo requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Matomo requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_matomo_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = ($ver eq 'latest') ? "matomo.zip" : "matomo-$ver.zip";
    my $url = "https://builds.matomo.org/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_matomo_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = ($ver eq 'latest') ? "matomo.zip" : "matomo-$ver.zip";
    my $download_url = "https://builds.matomo.org/$filename";
    my $tmp_file = "/tmp/matomo-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/matomo-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $src = -d "$tmp_extract/matomo" ? "$tmp_extract/matomo" : $tmp_extract;
    system("cp -rf $src/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Generate initial config/config.ini.php
    my $dbname = $defs->{'db'} || ($user . "_matomo");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    my $salt = join('', map { ( 'a'..'z', '0'..'9' )[rand 36] } 1..32);
    my $config_dir = "$target_dir/config";
    make_path($config_dir) if !-d $config_dir;

    my $config_ini = "$config_dir/config.ini.php";
    if (!-f $config_ini) {
        open(my $cfh, '>', $config_ini);
        print $cfh <<"EOF";
; <?php exit; ?> DO NOT REMOVE THIS LINE
[database]
host = "$dbhost"
username = "$dbuser"
password = "$dbpass"
dbname = "$dbname"
tables_prefix = "matomo_"
adapter = "PDO\\MYSQL"

[General]
salt = "$salt"
trusted_hosts[] = "$dom"
assume_secure_protocol = 1
EOF
        close($cfh);
        VirtualminWebApps::Common::set_ownership_recursive($config_ini, $user, $group);
    }

    # Register Matomo cron archiving task (runs every hour)
    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $cron_line = "5 * * * * $php_bin $target_dir/console core:archive >/dev/null 2>&1";
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    if ($current_cron !~ /core:archive/) {
        my $new_cron = $current_cron . "\n" . $cron_line . "\n";
        if (open(my $cfh, '|-', "crontab -u $user -")) {
            print $cfh $new_cron;
            close($cfh);
        }
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Installed Matomo at $full_url with database $dbname. Open the URL to finalize admin user setup."
    );
}

sub script_matomo_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $user = $d->{'user'};
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    # Remove cron
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    $current_cron =~ s/.*core:archive.*\n?//g;
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
