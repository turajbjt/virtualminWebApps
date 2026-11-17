# apps/woocommerce/woocommerce.pl
# Virtualmin Web App installer for WooCommerce + WordPress
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

sub script_woocommerce_desc
{
    return "WooCommerce E-Commerce (WordPress)";
}

sub script_woocommerce_uses
{
    return ( "php", "mysql" );
}

sub script_woocommerce_category
{
    return "Commerce";
}

sub script_woocommerce_author
{
    return "Automattic / WooCommerce Community";
}

sub script_woocommerce_site
{
    return "https://woocommerce.com";
}

sub script_woocommerce_versions
{
    return ( "latest" );
}

sub script_woocommerce_release
{
    return 2;
}

sub script_woocommerce_passmode
{
    return 0;
}

sub script_woocommerce_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"woo_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Store Name</b></td> <td>";
    $html .= "<input name=\"woo_title\" size=\"30\" value=\"$d->{'dom'} Store\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"woo_admin\" size=\"20\" value=\"admin\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"woo_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"woo_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    return $html;
}

sub script_woocommerce_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'woo_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    my $title = $in->{'woo_title'} || "$d->{'dom'} Store";
    my $admin = $in->{'woo_admin'} || 'admin';
    my $email = $in->{'woo_email'} || "admin\@$d->{'dom'}";
    my $pass = $in->{'woo_pass'} || '';

    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    return {
        'dir'   => $dir,
        'title' => $title,
        'admin' => $admin,
        'pass'  => $pass,
        'email' => $email,
    };
}

sub script_woocommerce_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "WooCommerce requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "WooCommerce requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_woocommerce_files
{
    return ();
}

sub script_woocommerce_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Download WP-CLI for automated installation
    my $wpcli_path = "$target_dir/wp-cli.phar";
    my ($dl_ok, $dl_err) = VirtualminWebApps::Common::download_url(
        "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
        $wpcli_path,
        60
    );
    return (0, "Failed to download WP-CLI: $dl_err") if !$dl_ok;
    chmod(0755, $wpcli_path);

    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $dbname = $defs->{'db'} || ($user . "_woocommerce");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    # 1. Download WordPress core
    my $cmd_download = "su -s /bin/sh $user -c 'cd " . quotemeta($target_dir) . " && " .
                       quotemeta($php_bin) . " wp-cli.phar core download'";
    system($cmd_download);

    # 2. Generate wp-config.php
    my $cmd_config = "su -s /bin/sh $user -c 'cd " . quotemeta($target_dir) . " && " .
                     quotemeta($php_bin) . " wp-cli.phar config create " .
                     "--dbname=" . quotemeta($dbname) . " " .
                     "--dbuser=" . quotemeta($dbuser) . " " .
                     "--dbpass=" . quotemeta($dbpass) . " " .
                     "--dbhost=" . quotemeta($dbhost) . "'";
    system($cmd_config);

    # 3. Install WordPress
    my $cmd_install = "su -s /bin/sh $user -c 'cd " . quotemeta($target_dir) . " && " .
                      quotemeta($php_bin) . " wp-cli.phar core install " .
                      "--url=" . quotemeta($full_url) . " " .
                      "--title=" . quotemeta($opts->{'title'}) . " " .
                      "--admin_user=" . quotemeta($opts->{'admin'}) . " " .
                      "--admin_password=" . quotemeta($opts->{'pass'}) . " " .
                      "--admin_email=" . quotemeta($opts->{'email'}) . "'";
    system($cmd_install);

    # 4. Install & Activate WooCommerce plugin
    my $cmd_woo = "su -s /bin/sh $user -c 'cd " . quotemeta($target_dir) . " && " .
                  quotemeta($php_bin) . " wp-cli.phar plugin install woocommerce --activate'";
    system($cmd_woo);

    # Remove WP-CLI from document root
    unlink($wpcli_path);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    return (
        1,
        $full_url,
        "Installed WooCommerce at $full_url. Admin: $opts->{'admin'} (Password: $opts->{'pass'})"
    );
}

sub script_woocommerce_uninstall
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
