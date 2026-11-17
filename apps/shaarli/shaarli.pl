# apps/shaarli/shaarli.pl
# Virtualmin Web App installer for Shaarli
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

sub script_shaarli_desc
{
    return "Shaarli Personal Bookmarking & Link Sharing";
}

sub script_shaarli_uses
{
    return ( "php" );
}

sub script_shaarli_category
{
    return "Utilities";
}

sub script_shaarli_author
{
    return "Shaarli Community";
}

sub script_shaarli_site
{
    return "https://shaarli.readthedocs.io";
}

sub script_shaarli_versions
{
    return ( "0.16.10" );
}

sub script_shaarli_release
{
    return 1;
}

sub script_shaarli_passmode
{
    return 0;
}

sub script_shaarli_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"shaarli_dir\" size=\"25\" value=\"links\"> ";
    $html .= "(Default: /links or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_shaarli_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'shaarli_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    return { 'dir' => $dir };
}

sub script_shaarli_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Shaarli requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_shaarli_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "shaarli-v$ver-full.zip";
    my $url = "https://github.com/shaarli/Shaarli/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_shaarli_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "shaarli-v$ver-full.zip";
    my $url = "https://github.com/shaarli/Shaarli/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/shaarli-$dom-$filename";
    my $tmp_unpack = "/tmp/shaarli-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from Shaarli / unzipped root
    my @contents = glob("$tmp_unpack/Shaarli*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable data and cache directories
    for my $sub ("data", "cache", "pagecache") {
        my $sub_dir = "$target_dir/$sub";
        make_path($sub_dir) if !-d $sub_dir;
        chmod(0777, $sub_dir);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Installed Shaarli to $full_url. Open the URL to configure your admin account."
    );
}

sub script_shaarli_uninstall
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
