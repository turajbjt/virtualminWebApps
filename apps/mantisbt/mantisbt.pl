# apps/mantisbt/mantisbt.pl
# Virtualmin Web App installer for MantisBT Bug Tracker
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

sub script_mantisbt_desc
{
    return "MantisBT Web-Based Issue & Bug Tracking System";
}

sub script_mantisbt_uses
{
    return ( "php", "mysql" );
}

sub script_mantisbt_category
{
    return "Project";
}

sub script_mantisbt_author
{
    return "MantisBT Team";
}

sub script_mantisbt_site
{
    return "https://www.mantisbt.org";
}

sub script_mantisbt_versions
{
    return ( "2.28.4" );
}

sub script_mantisbt_release
{
    return 2;
}

sub script_mantisbt_passmode
{
    return 0;
}

sub script_mantisbt_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"mantisbt_dir\" size=\"25\" value=\"bugs\"> ";
    $html .= "(Default: /bugs or /mantisbt, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_mantisbt_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'mantisbt_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_mantisbt_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "MantisBT requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "MantisBT requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_mantisbt_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "mantisbt-$ver.tar.gz";
    my $url = "https://downloads.sourceforge.net/project/mantisbt/mantis-stable/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_mantisbt_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "mantisbt-$ver.tar.gz";
    my $url = "https://downloads.sourceforge.net/project/mantisbt/mantis-stable/$ver/$filename";
    my $tmp_file = "/tmp/mantisbt-$dom-$filename";
    my $tmp_unpack = "/tmp/mantisbt-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted mantisbt directory
    my @contents = glob("$tmp_unpack/mantisbt-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable config directory
    my $config_dir = "$target_dir/config";
    make_path($config_dir) if !-d $config_dir;
    chmod(0775, $config_dir);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_mantis");
    my $dbuser = $defs->{'user'} || $user;
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";
    my $install_url = "$full_url" . "admin/install.php";

    return (
        1,
        $install_url,
        "Extracted MantisBT $ver to $full_url. Finish the installation wizard at $install_url (Database: $dbname, User: $dbuser)."
    );
}

sub script_mantisbt_uninstall
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
