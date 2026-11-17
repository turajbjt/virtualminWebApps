# apps/owncloud/owncloud.pl
# Virtualmin Web App installer for ownCloud Classic
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

sub script_owncloud_desc
{
    return "ownCloud Classic Cloud Platform";
}

sub script_owncloud_uses
{
    return ( "php", "mysql" );
}

sub script_owncloud_category
{
    return "Cloud";
}

sub script_owncloud_author
{
    return "ownCloud GmbH";
}

sub script_owncloud_site
{
    return "https://owncloud.com";
}

sub script_owncloud_versions
{
    return ( "10.13.4", "latest" );
}

sub script_owncloud_release
{
    return 2;
}

sub script_owncloud_passmode
{
    return 0;
}

sub script_owncloud_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"owncloud_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"owncloud_admin\" size=\"20\" value=\"admin\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"owncloud_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    $html .= "<tr> <td><b>Data Directory</b></td> <td>";
    $html .= "<input name=\"owncloud_data\" size=\"40\" value=\"$d->{'home'}/owncloud-data\"> ";
    $html .= "(Stored outside public_html for security)</td> </tr>";

    return $html;
}

sub script_owncloud_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'owncloud_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    my $admin = $in->{'owncloud_admin'} || 'admin';
    my $pass = $in->{'owncloud_pass'} || '';
    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    my $data_dir = $in->{'owncloud_data'} || "$d->{'home'}/owncloud-data";

    return {
        'dir'      => $dir,
        'admin'    => $admin,
        'pass'     => $pass,
        'data_dir' => $data_dir,
    };
}

sub script_owncloud_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "ownCloud requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "ownCloud requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_owncloud_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = ($ver eq 'latest') ? "owncloud-complete-latest.zip" : "owncloud-$ver.zip";
    my $url = "https://download.owncloud.com/community/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_owncloud_install
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

    my $filename = ($ver eq 'latest') ? "owncloud-complete-latest.zip" : "owncloud-$ver.zip";
    my $download_url = "https://download.owncloud.com/community/$filename";
    my $tmp_file = "/tmp/oc-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/oc-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $source_dir = -d "$tmp_extract/owncloud" ? "$tmp_extract/owncloud" : $tmp_extract;
    system("cp -rf $source_dir/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $source_dir/.htaccess " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $source_dir/.user.ini " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_owncloud");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

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
    if ($rc != 0 && $occ_out !~ /ownCloud was successfully installed/i) {
        return (0, "ownCloud occ setup failed: $occ_out");
    }

    system("su -s /bin/sh $user -c '" . quotemeta($php_bin) . " " . quotemeta("$target_dir/occ") . " config:system:set trusted_domains 1 --value=" . quotemeta($dom) . "' 2>/dev/null");

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Installed ownCloud Classic at $full_url. Admin: $admin_user (Password: $admin_pass)"
    );
}

sub script_owncloud_uninstall
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
