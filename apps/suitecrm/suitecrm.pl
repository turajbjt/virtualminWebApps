# apps/suitecrm/suitecrm.pl
# Virtualmin Web App installer for SuiteCRM
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

sub script_suitecrm_desc
{
    return "SuiteCRM Enterprise Customer Relationship Management";
}

sub script_suitecrm_uses
{
    return ( "php", "mysql" );
}

sub script_suitecrm_category
{
    return "Business";
}

sub script_suitecrm_author
{
    return "SalesAgility";
}

sub script_suitecrm_site
{
    return "https://suitecrm.com";
}

sub script_suitecrm_versions
{
    return ( "8.10.2", "8.9.3" );
}

sub script_suitecrm_release
{
    return 1;
}

sub script_suitecrm_passmode
{
    return 0;
}

sub script_suitecrm_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"suitecrm_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_suitecrm_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'suitecrm_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    return { 'dir' => $dir };
}

sub script_suitecrm_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "SuiteCRM requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "SuiteCRM requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_suitecrm_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "SuiteCRM-$ver.zip";
    my $url = "https://github.com/SuiteCRM/SuiteCRM-Core/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_suitecrm_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "SuiteCRM-$ver.zip";
    my $url = "https://github.com/SuiteCRM/SuiteCRM-Core/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/suitecrm-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 600);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Ensure writable permissions for SuiteCRM cache, logs, and legacy dirs
    for my $sub ("config.php", "custom", "data", "cache", "public/legacy") {
        if (-e "$target_dir/$sub") {
            chmod(0775, "$target_dir/$sub");
        }
    }

    my $dbname = $defs->{'db'} || ($user . "_suitecrm");
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Extracted SuiteCRM to $full_url. Finish the installation wizard at $full_url with database '$dbname'."
    );
}

sub script_suitecrm_uninstall
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
