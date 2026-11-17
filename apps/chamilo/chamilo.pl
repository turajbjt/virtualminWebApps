# apps/chamilo/chamilo.pl
# Virtualmin Web App installer for Chamilo LMS
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

sub script_chamilo_desc
{
    return "Chamilo LMS - Open-Source E-Learning Platform";
}

sub script_chamilo_uses
{
    return ( "php", "mysql" );
}

sub script_chamilo_category
{
    return "Education";
}

sub script_chamilo_author
{
    return "Chamilo Association";
}

sub script_chamilo_site
{
    return "https://chamilo.org";
}

sub script_chamilo_versions
{
    return ( "3.0.2" );
}

sub script_chamilo_release
{
    return 3;
}

sub script_chamilo_passmode
{
    return 0;
}

sub script_chamilo_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"chamilo_dir\" size=\"25\" value=\"chamilo\"> ";
    $html .= "(Default: /chamilo or /lms, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_chamilo_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'chamilo_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_chamilo_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Chamilo LMS requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Chamilo LMS requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_chamilo_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "chamilo-$ver.zip";
    my $url = "https://github.com/chamilo/chamilo-lms/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_chamilo_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "chamilo-$ver.zip";
    my $url = "https://github.com/chamilo/chamilo-lms/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/chamilo-$dom-$filename";
    my $tmp_unpack = "/tmp/chamilo-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 600);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted chamilo directory
    my @contents = glob("$tmp_unpack/chamilo-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable directories
    for my $sub ("app/cache", "app/upload", "app/courses", "app/config", "main/default_course_document/images") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_chamilo");
    my $dbuser = $defs->{'user'} || $user;
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Extracted Chamilo LMS $ver to $full_url. Finish the installation wizard at $full_url (Database: $dbname, User: $dbuser)."
    );
}

sub script_chamilo_uninstall
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
