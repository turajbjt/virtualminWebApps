# apps/privatebin/privatebin.pl
# Virtualmin Web App installer for PrivateBin
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

sub script_privatebin_desc
{
    return "PrivateBin Zero-Knowledge Encrypted Pastebin";
}

sub script_privatebin_uses
{
    return ( "php" );
}

sub script_privatebin_category
{
    return "Security";
}

sub script_privatebin_author
{
    return "PrivateBin Team";
}

sub script_privatebin_site
{
    return "https://privatebin.info";
}

sub script_privatebin_versions
{
    return ( "2.1.1" );
}

sub script_privatebin_release
{
    return 2;
}

sub script_privatebin_passmode
{
    return 0;
}

sub script_privatebin_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"privatebin_dir\" size=\"25\" value=\"paste\"> ";
    $html .= "(Default: /paste or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_privatebin_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'privatebin_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_privatebin_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "PrivateBin requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_privatebin_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "PrivateBin-$ver.tar.gz";
    my $url = "https://github.com/PrivateBin/PrivateBin/archive/refs/tags/$ver.tar.gz";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_privatebin_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "PrivateBin-$ver.tar.gz";
    my $url = "https://github.com/PrivateBin/PrivateBin/archive/refs/tags/$ver.tar.gz";
    my $tmp_file = "/tmp/privatebin-$dom-$filename";
    my $tmp_unpack = "/tmp/privatebin-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from PrivateBin-x.x.x
    my @contents = glob("$tmp_unpack/PrivateBin-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Create config file if sample exists
    if (-f "$target_dir/cfg/conf.sample.php" && !-f "$target_dir/cfg/conf.php") {
        system("cp -f $target_dir/cfg/conf.sample.php $target_dir/cfg/conf.php");
    }

    # Ensure writable data directory
    my $data_dir = "$target_dir/data";
    make_path($data_dir) if !-d $data_dir;
    chmod(0777, $data_dir);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Installed PrivateBin to $full_url. Client-side zero-knowledge encryption is active."
    );
}

sub script_privatebin_uninstall
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
