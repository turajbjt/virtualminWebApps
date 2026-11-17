# apps/litecart/litecart.pl
# Virtualmin Web App installer for LiteCart
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

sub script_litecart_desc
{
    return "LiteCart Lightweight E-Commerce";
}

sub script_litecart_uses
{
    return ( "php", "mysql" );
}

sub script_litecart_category
{
    return "Commerce";
}

sub script_litecart_author
{
    return "LiteCart Team";
}

sub script_litecart_site
{
    return "https://www.litecart.net";
}

sub script_litecart_versions
{
    return ( "2.5.5", "2.5.4" );
}

sub script_litecart_release
{
    return 2;
}

sub script_litecart_passmode
{
    return 0;
}

sub script_litecart_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"lc_dir\" size=\"25\" value=\"store\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"lc_admin\" size=\"20\" value=\"admin\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"lc_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    return $html;
}

sub script_litecart_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'lc_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    my $admin = $in->{'lc_admin'} || 'admin';
    my $pass = $in->{'lc_pass'} || '';
    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    return {
        'dir'   => $dir,
        'admin' => $admin,
        'pass'  => $pass,
    };
}

sub script_litecart_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "LiteCart requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "LiteCart requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_litecart_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "litecart-$ver.zip";
    my $url = "https://github.com/litecart/litecart/archive/refs/tags/$ver.zip";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_litecart_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $download_url = "https://github.com/litecart/litecart/archive/refs/tags/$ver.zip";
    my $tmp_file = "/tmp/lc-$dom-$ver.zip";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/lc-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $src = (glob("$tmp_extract/litecart*"))[0] || $tmp_extract;
    my $public_src = -d "$src/public_html" ? "$src/public_html" : $src;

    system("cp -rf $public_src/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $public_src/.htaccess " . quotemeta("$target_dir/.htaccess") . " 2>/dev/null || true");
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_litecart");
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url" . "install/",
        "Extracted LiteCart to $full_url. Finish setup at $full_url" . "install/ with database $dbname"
    );
}

sub script_litecart_uninstall
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
