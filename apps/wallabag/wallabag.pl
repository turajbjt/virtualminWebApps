# apps/wallabag/wallabag.pl
# Virtualmin Web App installer for Wallabag
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

sub script_wallabag_desc
{
    return "Wallabag Self-Hosted Read-It-Later & Article Archiver";
}

sub script_wallabag_uses
{
    return ( "php", "mysql" );
}

sub script_wallabag_category
{
    return "Utilities";
}

sub script_wallabag_author
{
    return "Wallabag Team";
}

sub script_wallabag_site
{
    return "https://wallabag.org";
}

sub script_wallabag_versions
{
    return ( "2.6.17" );
}

sub script_wallabag_release
{
    return 2;
}

sub script_wallabag_passmode
{
    return 0;
}

sub script_wallabag_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"wallabag_dir\" size=\"25\" value=\"wallabag\"> ";
    $html .= "(Default: /wallabag, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_wallabag_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'wallabag_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_wallabag_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Wallabag requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Wallabag requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_wallabag_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "wallabag-$ver.tar.gz";
    my $url = "https://github.com/wallabag/wallabag/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_wallabag_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "wallabag-$ver.tar.gz";
    my $url = "https://github.com/wallabag/wallabag/releases/download/$ver/$filename";
    my $tmp_file = "/tmp/wallabag-$dom-$filename";
    my $tmp_unpack = "/tmp/wallabag-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted wallabag directory
    my @contents = glob("$tmp_unpack/wallabag-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable directories
    for my $sub ("var", "var/cache", "var/logs", "var/sessions", "data") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_wallabag");
    my $dbuser = $defs->{'user'} || $user;
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";
    my $web_url = "$full_url" . "web/";

    return (
        1,
        $web_url,
        "Extracted Wallabag $ver to $full_url. Access Wallabag via $web_url (or point DocumentRoot to the web/ subfolder; Database: $dbname, User: $dbuser)."
    );
}

sub script_wallabag_uninstall
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
