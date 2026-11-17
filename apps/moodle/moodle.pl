# apps/moodle/moodle.pl
# Virtualmin Web App installer for Moodle LMS
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

sub script_moodle_desc
{
    return "Moodle Learning Management System";
}

sub script_moodle_uses
{
    return ( "php", "mysql" );
}

sub script_moodle_category
{
    return "Education";
}

sub script_moodle_author
{
    return "Moodle HQ";
}

sub script_moodle_site
{
    return "https://moodle.org";
}

sub script_moodle_versions
{
    return ( "4.4.4", "4.3.7" );
}

sub script_moodle_release
{
    return 2;
}

sub script_moodle_passmode
{
    return 0;
}

sub script_moodle_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"moodle_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_moodle_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'moodle_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_moodle_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Moodle requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Moodle requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_moodle_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "moodle-latest-404.tgz";
    my $url = "https://packaging.moodle.org/stable404/moodle-latest-404.tgz";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_moodle_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    # Secure moodledata outside document root
    my $data_dir = "$d->{'home'}/moodledata";
    make_path($data_dir) if !-d $data_dir;
    chmod(0777, $data_dir);
    VirtualminWebApps::Common::set_ownership_recursive($data_dir, $user, $group);

    my $filename = "moodle-latest-404.tgz";
    my $url = "https://packaging.moodle.org/stable404/moodle-latest-404.tgz";
    my $tmp_file = "/tmp/moodle-$dom-$filename";
    my $tmp_unpack = "/tmp/moodle-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 600);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Unpack inner moodle directory
    if (-d "$tmp_unpack/moodle") {
        system("cp -r $tmp_unpack/moodle/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/moodle/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_moodle");
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Extracted Moodle to $full_url with moodledata at $data_dir. Finish setup at $full_url with database '$dbname'."
    );
}

sub script_moodle_uninstall
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
