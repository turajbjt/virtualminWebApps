# apps/grav/grav.pl
# Virtualmin Web App installer for Grav CMS
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

sub script_grav_desc
{
    return "Grav Modern Flat-File Content Management System";
}

sub script_grav_uses
{
    return ( "php" );
}

sub script_grav_category
{
    return "CMS";
}

sub script_grav_author
{
    return "Trilobyte / Grav Team";
}

sub script_grav_site
{
    return "https://getgrav.org";
}

sub script_grav_versions
{
    return ( "2.2.30" );
}

sub script_grav_release
{
    return 2;
}

sub script_grav_passmode
{
    return 0;
}

sub script_grav_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"grav_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_grav_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'grav_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_grav_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Grav requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_grav_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "grav-admin-v$ver.zip";
    my $url = "https://github.com/getgrav/grav/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_grav_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "grav-admin-v$ver.zip";
    my $url = "https://github.com/getgrav/grav/releases/download/$ver/$filename";
    my $tmp_file = "/tmp/grav-$dom-$filename";
    my $tmp_unpack = "/tmp/grav-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from grav-admin/
    if (-d "$tmp_unpack/grav-admin") {
        system("cp -r $tmp_unpack/grav-admin/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/grav-admin/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable user and cache directories
    for my $sub ("cache", "logs", "images", "user", "backup") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0777, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url" . "admin",
        "Installed Grav CMS with Admin Panel to $full_url. Create your admin user at $full_url" . "admin."
    );
}

sub script_grav_uninstall
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
