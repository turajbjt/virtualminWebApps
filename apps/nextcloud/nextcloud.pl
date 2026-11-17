# apps/nextcloud/nextcloud.pl
# Virtualmin Web App installer for Nextcloud Hub & Cloud Storage
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

sub script_nextcloud_desc
{
    return "Nextcloud Cloud & Collaboration Hub";
}

sub script_nextcloud_uses
{
    return ( "php", "mysql" );
}

sub script_nextcloud_category
{
    return "Cloud";
}

sub script_nextcloud_author
{
    return "Nextcloud GmbH";
}

sub script_nextcloud_site
{
    return "https://nextcloud.com";
}

sub script_nextcloud_versions
{
    return ( "30.0.6", "29.0.12", "latest" );
}

sub script_nextcloud_release
{
    return 2;
}

sub script_nextcloud_passmode
{
    return 0; # Plaintext password needed for occ maintenance:install
}

# script_nextcloud_params(&domain)
sub script_nextcloud_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"nextcloud_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"nextcloud_admin\" size=\"20\" value=\"admin\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"nextcloud_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    $html .= "<tr> <td><b>Data Directory</b></td> <td>";
    $html .= "<input name=\"nextcloud_data\" size=\"40\" value=\"$d->{'home'}/nextcloud-data\"> ";
    $html .= "(Best practice: stored securely outside public_html)</td> </tr>";

    return $html;
}

# script_nextcloud_parse(&domain, &in)
sub script_nextcloud_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'nextcloud_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    my $admin = $in->{'nextcloud_admin'} || 'admin';
    my $pass = $in->{'nextcloud_pass'} || '';
    if (!$pass) {
        # Auto-generate 16-character secure random password
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    my $data_dir = $in->{'nextcloud_data'} || "$d->{'home'}/nextcloud-data";

    return {
        'dir'      => $dir,
        'admin'    => $admin,
        'pass'     => $pass,
        'data_dir' => $data_dir,
    };
}

# script_nextcloud_check(&domain, $version, $dbtype, $dir)
sub script_nextcloud_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    # Ensure PHP is enabled
    if (!$d->{'php'}) {
        return "Nextcloud requires PHP to be enabled for $d->{'dom'}.";
    }

    # Ensure MySQL/MariaDB is enabled
    if (!$d->{'mysql'}) {
        return "Nextcloud requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

# script_nextcloud_files(&domain, $version, $options)
sub script_nextcloud_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = ($ver eq 'latest') ? "latest.zip" : "nextcloud-$ver.zip";
    my $url = "https://download.nextcloud.com/server/releases/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

# script_nextcloud_install(&domain, $version, $options, $defs, $setup)
sub script_nextcloud_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $data_dir = $opts->{'data_dir'};
    make_path($data_dir) if !-d $data_dir;
    VirtualminWebApps::Common::set_ownership_recursive($data_dir, $user, $group);

    # Download & Extract
    my $filename = ($ver eq 'latest') ? "latest.zip" : "nextcloud-$ver.zip";
    my $download_url = "https://download.nextcloud.com/server/releases/$filename";
    my $tmp_file = "/tmp/nc-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    # Nextcloud zip extracts into a 'nextcloud/' top-level directory
    my $tmp_extract = "/tmp/nc-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy from nextcloud/ to target_dir
    my $source_dir = -d "$tmp_extract/nextcloud" ? "$tmp_extract/nextcloud" : $tmp_extract;
    system("cp -rf $source_dir/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $source_dir/.htaccess " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $source_dir/.user.ini " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Database parameters provided by Virtualmin
    my $dbname = $defs->{'db'} || ($user . "_nextcloud");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    # Execute Nextcloud CLI installer via occ
    my $admin_user = $opts->{'admin'};
    my $admin_pass = $opts->{'pass'};

    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $occ_cmd = "su -s /bin/sh $user -c '" .
        quotemeta($php_bin) . " " . quotemeta("$target_dir/occ") . " maintenance:install " .
        "--database \"mysql\" " .
        "--database-name " . quotemeta($dbname) . " " .
        "--database-user " . quotemeta($dbuser) . " " .
        "--database-pass " . quotemeta($dbpass) . " " .
        "--database-host " . quotemeta($dbhost) . " " .
        "--admin-user " . quotemeta($admin_user) . " " .
        "--admin-pass " . quotemeta($admin_pass) . " " .
        "--data-dir " . quotemeta($data_dir) . "'";

    my $occ_out = `$occ_cmd 2>&1`;
    my $rc = $? >> 8;
    if ($rc != 0 && $occ_out !~ /Nextcloud was successfully installed/i) {
        return (0, "Nextcloud occ setup failed: $occ_out");
    }

    # Add trusted domain
    system("su -s /bin/sh $user -c '" . quotemeta($php_bin) . " " . quotemeta("$target_dir/occ") . " config:system:set trusted_domains 1 --value=" . quotemeta($dom) . "' 2>/dev/null");

    # Register system cron for Nextcloud background jobs
    my $cron_line = "*/5 * * * * $php_bin -f $target_dir/cron.php >/dev/null 2>&1";
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    if ($current_cron !~ /cron\.php/) {
        my $new_cron = $current_cron . "\n" . $cron_line . "\n";
        open(my $cfh, '|-', "crontab -u $user -") or warn "Cannot register crontab for $user: $!";
        print $cfh $new_cron;
        close($cfh);
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Installed Nextcloud Hub at $full_url. Admin user: $admin_user (Password: $admin_pass)"
    );
}

# script_nextcloud_uninstall(&domain, $version, $options)
sub script_nextcloud_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $user = $d->{'user'};
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    # Remove cron job
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    $current_cron =~ s/.*cron\.php.*\n?//g;
    if (open(my $cfh, '|-', "crontab -u $user -")) {
        print $cfh $current_cron;
        close($cfh);
    }

    # Remove files if in subdirectory
    if ($opts->{'dir'} && -d $target_dir) {
        remove_tree($target_dir);
    }

    return 1;
}

# script_nextcloud_upgrade(&domain, $version, $options)
sub script_nextcloud_upgrade
{
    my ($d, $ver, $opts) = @_;
    my $user = $d->{'user'};
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    # Put in maintenance mode
    system("su -s /bin/sh $user -c '$php_bin $target_dir/occ maintenance:mode --on'");

    # Run upgrade command
    system("su -s /bin/sh $user -c '$php_bin $target_dir/occ upgrade'");

    # Turn off maintenance mode
    system("su -s /bin/sh $user -c '$php_bin $target_dir/occ maintenance:mode --off'");

    return 1;
}

1;
