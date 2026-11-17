# apps/limesurvey/limesurvey.pl
# Virtualmin Web App installer for LimeSurvey
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

sub script_limesurvey_desc
{
    return "LimeSurvey - Professional Online Survey & Questionnaires Platform";
}

sub script_limesurvey_uses
{
    return ( "php", "mysql" );
}

sub script_limesurvey_category
{
    return "Surveys";
}

sub script_limesurvey_author
{
    return "LimeSurvey Community & GmbH";
}

sub script_limesurvey_site
{
    return "https://www.limesurvey.org";
}

sub script_limesurvey_versions
{
    return ( "6.17.19" );
}

sub script_limesurvey_release
{
    return 3;
}

sub script_limesurvey_passmode
{
    return 0;
}

sub script_limesurvey_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"limesurvey_dir\" size=\"25\" value=\"surveys\"> ";
    $html .= "(Default: /surveys or /limesurvey, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_limesurvey_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'limesurvey_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_limesurvey_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "LimeSurvey requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "LimeSurvey requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_limesurvey_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "limesurvey$ver+260832.zip";
    my $url = "https://download.limesurvey.org/latest-v6.x/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_limesurvey_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "limesurvey$ver+260832.zip";
    my $url = "https://download.limesurvey.org/latest-v6.x/$filename";
    my $tmp_file = "/tmp/limesurvey-$dom-$filename";
    my $tmp_unpack = "/tmp/limesurvey-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 600);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted limesurvey directory
    if (-d "$tmp_unpack/limesurvey") {
        system("cp -r $tmp_unpack/limesurvey/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/limesurvey/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable directories
    for my $sub ("tmp", "upload", "upload/surveys", "application/config") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_limesurvey");
    my $dbuser = $defs->{'user'} || $user;
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";
    my $admin_url = "$full_url" . "admin";

    return (
        1,
        $admin_url,
        "Extracted LimeSurvey $ver to $full_url. Finish the installation wizard at $admin_url (Database: $dbname, User: $dbuser)."
    );
}

sub script_limesurvey_uninstall
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
