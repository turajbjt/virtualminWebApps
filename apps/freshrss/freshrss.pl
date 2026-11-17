# apps/freshrss/freshrss.pl
# Virtualmin Web App installer for FreshRSS
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

sub script_freshrss_desc
{
    return "FreshRSS - Lightweight Feed Aggregator";
}

sub script_freshrss_uses
{
    return ( "php", "mysql" );
}

sub script_freshrss_category
{
    return "News";
}

sub script_freshrss_author
{
    return "FreshRSS Community";
}

sub script_freshrss_site
{
    return "https://freshrss.org";
}

sub script_freshrss_versions
{
    return ( "1.24.3" );
}

sub script_freshrss_release
{
    return 3;
}

sub script_freshrss_passmode
{
    return 0;
}

sub script_freshrss_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"freshrss_dir\" size=\"25\" value=\"freshrss\"> ";
    $html .= "(Default: /freshrss or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_freshrss_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'freshrss_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_freshrss_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "FreshRSS requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_freshrss_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "FreshRSS-$ver.tar.gz";
    my $url = "https://github.com/FreshRSS/FreshRSS/archive/refs/tags/$ver.tar.gz";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_freshrss_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "FreshRSS-$ver.tar.gz";
    my $url = "https://github.com/FreshRSS/FreshRSS/archive/refs/tags/$ver.tar.gz";
    my $tmp_file = "/tmp/freshrss-$dom-$filename";
    my $tmp_unpack = "/tmp/freshrss-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from FreshRSS-x.x.x
    my @contents = glob("$tmp_unpack/FreshRSS-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable data directory
    my $data_dir = "$target_dir/data";
    make_path($data_dir) if !-d $data_dir;
    chmod(0777, $data_dir);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_freshrss");
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url" . "p/",
        "Extracted FreshRSS to $full_url. Finish the installation wizard at $full_url" . "p/ (database: $dbname or SQLite)."
    );
}

sub script_freshrss_uninstall
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
