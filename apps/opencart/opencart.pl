# apps/opencart/opencart.pl
# Virtualmin Web App installer for OpenCart E-Commerce
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

sub script_opencart_desc
{
    return "OpenCart E-Commerce Platform";
}

sub script_opencart_uses
{
    return ( "php", "mysql" );
}

sub script_opencart_category
{
    return "Commerce";
}

sub script_opencart_author
{
    return "OpenCart Community";
}

sub script_opencart_site
{
    return "https://www.opencart.com";
}

sub script_opencart_versions
{
    return ( "4.0.2.3", "3.0.3.8" );
}

sub script_opencart_release
{
    return 2;
}

sub script_opencart_passmode
{
    return 0;
}

sub script_opencart_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"opencart_dir\" size=\"25\" value=\"store\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"opencart_admin\" size=\"20\" value=\"admin\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"opencart_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"opencart_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    return $html;
}

sub script_opencart_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'opencart_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    my $admin = $in->{'opencart_admin'} || 'admin';
    my $pass = $in->{'opencart_pass'} || '';
    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }
    my $email = $in->{'opencart_email'} || "admin\@$d->{'dom'}";

    return {
        'dir'   => $dir,
        'admin' => $admin,
        'pass'  => $pass,
        'email' => $email,
    };
}

sub script_opencart_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "OpenCart requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "OpenCart requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_opencart_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "opencart-$ver.zip";
    my $url = "https://github.com/opencart/opencart/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_opencart_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "opencart-$ver.zip";
    my $download_url = "https://github.com/opencart/opencart/releases/download/$ver/$filename";
    my $tmp_file = "/tmp/ocart-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/ocart-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # OpenCart zips place web files in upload/
    my $source_dir = -d "$tmp_extract/upload" ? "$tmp_extract/upload" : $tmp_extract;
    system("cp -rf $source_dir/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $source_dir/.htaccess.txt " . quotemeta("$target_dir/.htaccess") . " 2>/dev/null || true");
    remove_tree($tmp_extract);

    # Prepare config files
    if (-f "$target_dir/config-dist.php" && !-f "$target_dir/config.php") {
        system("cp -f $target_dir/config-dist.php $target_dir/config.php");
    }
    if (-f "$target_dir/admin/config-dist.php" && !-f "$target_dir/admin/config.php") {
        system("cp -f $target_dir/admin/config-dist.php $target_dir/admin/config.php");
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_opencart");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    my $admin_user = $opts->{'admin'};
    my $admin_pass = $opts->{'pass'};
    my $admin_email = $opts->{'email'};

    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    # Execute OpenCart CLI installer
    if (-f "$target_dir/install/cli_install.php") {
        my $install_cmd = "su -s /bin/sh $user -c '" .
            quotemeta($php_bin) . " " . quotemeta("$target_dir/install/cli_install.php") . " install " .
            "--db_hostname " . quotemeta($dbhost) . " " .
            "--db_username " . quotemeta($dbuser) . " " .
            "--db_password " . quotemeta($dbpass) . " " .
            "--db_database " . quotemeta($dbname) . " " .
            "--db_prefix \"oc_\" " .
            "--username " . quotemeta($admin_user) . " " .
            "--password " . quotemeta($admin_pass) . " " .
            "--email " . quotemeta($admin_email) . " " .
            "--http_server " . quotemeta($full_url) . "'";

        my $out = `$install_cmd 2>&1`;
        # After installation, remove or rename install directory for security
        remove_tree("$target_dir/install");
    }

    return (
        1,
        $full_url,
        "Installed OpenCart at $full_url. Admin: $admin_user (Password: $admin_pass)"
    );
}

sub script_opencart_uninstall
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
