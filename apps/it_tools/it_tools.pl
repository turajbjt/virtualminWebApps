# apps/it_tools/it_tools.pl
# Virtualmin Web App installer for IT-Tools
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

sub script_it_tools_desc
{
    return "IT-Tools Handy Online Tools for Developers";
}

sub script_it_tools_uses
{
    return ();
}

sub script_it_tools_category
{
    return "Development";
}

sub script_it_tools_author
{
    return "Corentin Thomasset";
}

sub script_it_tools_site
{
    return "https://it-tools.tech";
}

sub script_it_tools_versions
{
    return ( "2024.10.22" );
}

sub script_it_tools_release
{
    return 2;
}

sub script_it_tools_passmode
{
    return 0;
}

sub script_it_tools_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"it_tools_dir\" size=\"25\" value=\"it-tools\"> ";
    $html .= "(Default: /it-tools or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_it_tools_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'it_tools_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_it_tools_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    return undef;
}

sub script_it_tools_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "it-tools-$ver-7ca5933.zip";
    my $url = "https://github.com/CorentinTh/it-tools/releases/download/v$ver-7ca5933/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_it_tools_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "it-tools-$ver-7ca5933.zip";
    my $url = "https://github.com/CorentinTh/it-tools/releases/download/v$ver-7ca5933/$filename";
    my $tmp_file = "/tmp/it-tools-$dom-$filename";
    my $tmp_unpack = "/tmp/it-tools-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from dist/ folder
    if (-d "$tmp_unpack/dist") {
        system("cp -r $tmp_unpack/dist/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/dist/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Installed IT-Tools to $full_url. Access directly in your browser."
    );
}

sub script_it_tools_uninstall
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
