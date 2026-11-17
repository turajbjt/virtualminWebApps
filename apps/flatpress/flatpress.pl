# apps/flatpress/flatpress.pl
# Virtualmin Web App installer for FlatPress
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

sub script_flatpress_desc
{
    return "FlatPress Flat-File Blogging Engine";
}

sub script_flatpress_uses
{
    return ( "php" ); # Zero SQL database required
}

sub script_flatpress_category
{
    return "Blog";
}

sub script_flatpress_author
{
    return "FlatPress Community";
}

sub script_flatpress_site
{
    return "https://www.flatpress.org";
}

sub script_flatpress_versions
{
    return ( "1.5.1" );
}

sub script_flatpress_release
{
    return 2;
}

sub script_flatpress_passmode
{
    return 2; # Web setup wizard sets up initial administrator credentials
}

sub script_flatpress_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"flatpress_dir\" size=\"25\" value=\"blog\"> ";
    $html .= "(Default: /blog or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_flatpress_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'flatpress_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_flatpress_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "FlatPress requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_flatpress_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "flatpress-$ver.tar.gz";
    my $url = "https://codeload.github.com/flatpressblog/flatpress/tar.gz/refs/tags/$ver";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_flatpress_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "flatpress-$ver.tar.gz";
    my $url = "https://codeload.github.com/flatpressblog/flatpress/tar.gz/refs/tags/$ver";
    my $tmp_file = "/tmp/flatpress-$dom-$filename";
    my $tmp_unpack = "/tmp/flatpress-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted flatpress directory
    my @contents = glob("$tmp_unpack/flatpress-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure fp-content directory is writable
    my $content_dir = "$target_dir/fp-content";
    make_path($content_dir) if !-d $content_dir;
    chmod(0775, $content_dir);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";
    my $setup_url = "$full_url" . "setup.php";

    return (
        1,
        $setup_url,
        "Extracted FlatPress $ver to $full_url. Complete setup by visiting $setup_url."
    );
}

sub script_flatpress_uninstall
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
