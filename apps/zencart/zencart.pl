# apps/zencart/zencart.pl
# Virtualmin Web App installer for Zen Cart E-Commerce
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

sub script_zencart_desc
{
    return "Zen Cart - Open-Source E-Commerce";
}

sub script_zencart_uses
{
    return ( "php", "mysql" );
}

sub script_zencart_category
{
    return "Commerce";
}

sub script_zencart_author
{
    return "Zen Cart Team";
}

sub script_zencart_site
{
    return "https://www.zen-cart.com";
}

sub script_zencart_versions
{
    return ( "2.2.2", "2.1.0", "1.5.8" );
}

sub script_zencart_release
{
    return 3;
}

sub script_zencart_passmode
{
    return 0;
}

sub script_zencart_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"zc_dir\" size=\"25\" value=\"store\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"zc_admin\" size=\"20\" value=\"admin\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"zc_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"zc_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    return $html;
}

sub script_zencart_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'zc_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    my $admin = $in->{'zc_admin'} || 'admin';
    my $pass = $in->{'zc_pass'} || '';
    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }
    my $email = $in->{'zc_email'} || "admin\@$d->{'dom'}";

    return {
        'dir'   => $dir,
        'admin' => $admin,
        'pass'  => $pass,
        'email' => $email,
    };
}

sub script_zencart_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Zen Cart requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Zen Cart requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_zencart_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "zencart-v$ver.zip";
    my $url = "https://github.com/zencart/zencart/archive/refs/tags/v$ver.zip";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_zencart_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $download_url = "https://github.com/zencart/zencart/archive/refs/tags/v$ver.zip";
    my $tmp_file = "/tmp/zc-$dom-v$ver.zip";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/zc-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $src = (glob("$tmp_extract/zencart*"))[0] || $tmp_extract;
    system("cp -rf $src/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $src/.htaccess " . quotemeta("$target_dir/.htaccess") . " 2>/dev/null || true");
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_zencart");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url" . "zc_install/",
        "Extracted Zen Cart to $full_url. Finish setup at $full_url" . "zc_install/ with database $dbname"
    );
}

sub script_zencart_uninstall
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
