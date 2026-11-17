# apps/dokuwiki/dokuwiki.pl
# Virtualmin Web App installer for DokuWiki
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

sub script_dokuwiki_desc
{
    return "DokuWiki Standards-Compliant Flat-File Wiki";
}

sub script_dokuwiki_uses
{
    return ( "php" );
}

sub script_dokuwiki_category
{
    return "Wiki";
}

sub script_dokuwiki_author
{
    return "Andreas Gohr & DokuWiki Community";
}

sub script_dokuwiki_site
{
    return "https://www.dokuwiki.org";
}

sub script_dokuwiki_versions
{
    return ( "2026-07-14c" );
}

sub script_dokuwiki_release
{
    return 2;
}

sub script_dokuwiki_passmode
{
    return 0;
}

sub script_dokuwiki_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"dokuwiki_dir\" size=\"25\" value=\"wiki\"> ";
    $html .= "(Default: /wiki or /dokuwiki, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_dokuwiki_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'dokuwiki_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_dokuwiki_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "DokuWiki requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_dokuwiki_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "dokuwiki-$ver.tgz";
    my $url = "https://github.com/dokuwiki/dokuwiki/releases/download/release-$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_dokuwiki_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "dokuwiki-$ver.tgz";
    my $url = "https://github.com/dokuwiki/dokuwiki/releases/download/release-$ver/$filename";
    my $tmp_file = "/tmp/dokuwiki-$dom-$filename";
    my $tmp_unpack = "/tmp/dokuwiki-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted dokuwiki directory
    my @contents = glob("$tmp_unpack/dokuwiki-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable directories
    for my $sub ("data", "conf", "lib/plugins", "lib/tpl") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";
    my $install_url = "$full_url" . "install.php";

    return (
        1,
        $install_url,
        "Extracted DokuWiki $ver to $full_url. Finish the installation wizard at $install_url."
    );
}

sub script_dokuwiki_uninstall
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
