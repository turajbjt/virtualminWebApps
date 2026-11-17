# apps/prestashop/prestashop.pl
# Virtualmin Web App installer for PrestaShop E-Commerce
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

sub script_prestashop_desc
{
    return "PrestaShop E-Commerce Platform";
}

sub script_prestashop_uses
{
    return ( "php", "mysql" );
}

sub script_prestashop_category
{
    return "Commerce";
}

sub script_prestashop_author
{
    return "PrestaShop Community";
}

sub script_prestashop_site
{
    return "https://www.prestashop.com";
}

sub script_prestashop_versions
{
    return ( "8.1.7", "8.1.5", "1.7.8.10" );
}

sub script_prestashop_release
{
    return 2;
}

sub script_prestashop_passmode
{
    return 0;
}

sub script_prestashop_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"prestashop_dir\" size=\"25\" value=\"shop\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Shop Name</b></td> <td>";
    $html .= "<input name=\"prestashop_name\" size=\"30\" value=\"$d->{'dom'} Shop\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"prestashop_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"prestashop_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Minimum 8 characters. Leave empty to auto-generate)</td> </tr>";

    return $html;
}

sub script_prestashop_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'prestashop_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    my $name = $in->{'prestashop_name'} || "$d->{'dom'} Shop";
    my $email = $in->{'prestashop_email'} || "admin\@$d->{'dom'}";
    my $pass = $in->{'prestashop_pass'} || '';
    if (!$pass || length($pass) < 8) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    return {
        'dir'   => $dir,
        'name'  => $name,
        'email' => $email,
        'pass'  => $pass,
    };
}

sub script_prestashop_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "PrestaShop requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "PrestaShop requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_prestashop_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "prestashop_$ver.zip";
    my $url = "https://github.com/PrestaShop/PrestaShop/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_prestashop_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "prestashop_$ver.zip";
    my $download_url = "https://github.com/PrestaShop/PrestaShop/releases/download/$ver/$filename";
    my $tmp_file = "/tmp/ps-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/ps-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # PrestaShop archive contains a prestashop.zip inside it
    if (-f "$tmp_extract/prestashop.zip") {
        VirtualminWebApps::Common::extract_archive("$tmp_extract/prestashop.zip", $target_dir);
    } else {
        system("cp -rf $tmp_extract/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    }
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_prestashop");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    my $admin_email = $opts->{'email'};
    my $admin_pass = $opts->{'pass'};
    my $shop_name = $opts->{'name'};

    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $base_uri = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $ssl_flag = $d->{'ssl'} ? 1 : 0;

    # Execute PrestaShop CLI installer
    if (-f "$target_dir/install/index_cli.php") {
        my $install_cmd = "su -s /bin/sh $user -c '" .
            quotemeta($php_bin) . " " . quotemeta("$target_dir/install/index_cli.php") . " " .
            "--domain=" . quotemeta($dom) . " " .
            "--db_server=" . quotemeta($dbhost) . " " .
            "--db_name=" . quotemeta($dbname) . " " .
            "--db_user=" . quotemeta($dbuser) . " " .
            "--db_password=" . quotemeta($dbpass) . " " .
            "--prefix=\"ps_\" " .
            "--email=" . quotemeta($admin_email) . " " .
            "--password=" . quotemeta($admin_pass) . " " .
            "--name=" . quotemeta($shop_name) . " " .
            "--base_uri=" . quotemeta($base_uri) . " " .
            "--ssl=" . $ssl_flag . "'";

        my $out = `$install_cmd 2>&1`;
        # Remove install directory for security
        remove_tree("$target_dir/install");
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $full_url = "$proto://$dom$base_uri";

    return (
        1,
        $full_url,
        "Installed PrestaShop at $full_url. Admin email: $admin_email (Password: $admin_pass)"
    );
}

sub script_prestashop_uninstall
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
