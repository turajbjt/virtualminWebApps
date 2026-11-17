# apps/piwigo/piwigo.pl
# Virtualmin Web App installer for Piwigo Photo Gallery
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

sub script_piwigo_desc
{
    return "Piwigo Photo Gallery & Digital Asset Management";
}

sub script_piwigo_uses
{
    return ( "php", "mysql" );
}

sub script_piwigo_category
{
    return "Media";
}

sub script_piwigo_author
{
    return "Piwigo Community";
}

sub script_piwigo_site
{
    return "https://piwigo.org";
}

sub script_piwigo_versions
{
    return ( "16.5.0" );
}

sub script_piwigo_release
{
    return 2;
}

sub script_piwigo_passmode
{
    return 0;
}

sub script_piwigo_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"piwigo_dir\" size=\"25\" value=\"gallery\"> ";
    $html .= "(Default: /gallery or /piwigo, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_piwigo_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'piwigo_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_piwigo_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Piwigo requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Piwigo requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_piwigo_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "piwigo-$ver.zip";
    my $url = "https://piwigo.org/download/dlcounter.php?code=$ver";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_piwigo_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "piwigo-$ver.zip";
    my $url = "https://piwigo.org/download/dlcounter.php?code=$ver";
    my $tmp_file = "/tmp/piwigo-$dom-$filename";
    my $tmp_unpack = "/tmp/piwigo-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted piwigo folder
    if (-d "$tmp_unpack/piwigo") {
        system("cp -r $tmp_unpack/piwigo/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/piwigo/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable directories for caches, uploads, and configuration
    for my $sub ("_data", "upload", "galleries", "local", "local/config") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_piwigo");
    my $dbuser = $defs->{'user'} || $user;
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Extracted Piwigo $ver to $full_url. Finish the installation wizard at $full_url (Database: $dbname, User: $dbuser)."
    );
}

sub script_piwigo_uninstall
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
