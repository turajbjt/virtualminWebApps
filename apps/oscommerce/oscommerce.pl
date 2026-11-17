# apps/oscommerce/oscommerce.pl
# Virtualmin Web App installer for osCommerce
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

sub script_oscommerce_desc
{
    return "osCommerce Open-Source E-Commerce Platform";
}

sub script_oscommerce_uses
{
    return ( "php", "mysql" );
}

sub script_oscommerce_category
{
    return "Commerce";
}

sub script_oscommerce_author
{
    return "osCommerce";
}

sub script_oscommerce_site
{
    return "https://www.oscommerce.com";
}

sub script_oscommerce_versions
{
    return ( "4.14", "4.0" );
}

sub script_oscommerce_release
{
    return 2;
}

sub script_oscommerce_passmode
{
    return 0;
}

sub script_oscommerce_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"oscommerce_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_oscommerce_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'oscommerce_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_oscommerce_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "osCommerce requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "osCommerce requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_oscommerce_files
{
    my ($d, $ver, $opts) = @_;
    my $url = "https://github.com/osCommerce/osCommerce-V4/archive/refs/heads/master.zip";

    return (
        {
            'name' => "oscommerce-v4-master.zip",
            'url'  => $url,
        }
    );
}

sub script_oscommerce_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $url = "https://github.com/osCommerce/osCommerce-V4/archive/refs/heads/master.zip";
    my $tmp_file = "/tmp/oscommerce-$dom.zip";
    my $tmp_unpack = "/tmp/oscommerce-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Handle inner directory if extracted with prefix (e.g. osCommerce-V4-master)
    my @contents = glob("$tmp_unpack/*");
    if (scalar(@contents) == 1 && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Ensure writable directories
    for my $sub ("var", "var/cache", "var/logs", "images", "pub") {
        if (-d "$target_dir/$sub") {
            chmod(0775, "$target_dir/$sub");
        }
    }

    my $dbname = $defs->{'db'} || ($user . "_oscommerce");
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Extracted osCommerce to $full_url. Complete the installation wizard in your web browser using database '$dbname'."
    );
}

sub script_oscommerce_uninstall
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
