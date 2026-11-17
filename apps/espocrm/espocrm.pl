# apps/espocrm/espocrm.pl
# Virtualmin Web App installer for EspoCRM
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

sub script_espocrm_desc
{
    return "EspoCRM Open-Source Customer Relationship Management";
}

sub script_espocrm_uses
{
    return ( "php", "mysql" );
}

sub script_espocrm_category
{
    return "Business";
}

sub script_espocrm_author
{
    return "EspoCRM Team";
}

sub script_espocrm_site
{
    return "https://www.espocrm.com";
}

sub script_espocrm_versions
{
    return ( "10.1.3" );
}

sub script_espocrm_release
{
    return 1;
}

sub script_espocrm_passmode
{
    return 0;
}

sub script_espocrm_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"espocrm_dir\" size=\"25\" value=\"crm\"> ";
    $html .= "(Default: /crm or /espocrm, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_espocrm_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'espocrm_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    return { 'dir' => $dir };
}

sub script_espocrm_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "EspoCRM requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "EspoCRM requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_espocrm_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "EspoCRM-$ver.zip";
    my $url = "https://github.com/espocrm/espocrm/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_espocrm_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "EspoCRM-$ver.zip";
    my $url = "https://github.com/espocrm/espocrm/releases/download/$ver/$filename";
    my $tmp_file = "/tmp/espocrm-$dom-$filename";
    my $tmp_unpack = "/tmp/espocrm-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 400);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted EspoCRM directory
    my @contents = glob("$tmp_unpack/EspoCRM-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable directories
    for my $sub ("data", "custom", "client/custom") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_espocrm");
    my $dbuser = $defs->{'user'} || $user;
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";
    my $install_url = "$full_url" . "install/";

    return (
        1,
        $install_url,
        "Extracted EspoCRM $ver to $full_url. Finish the installation wizard at $install_url (Database: $dbname, User: $dbuser)."
    );
}

sub script_espocrm_uninstall
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
