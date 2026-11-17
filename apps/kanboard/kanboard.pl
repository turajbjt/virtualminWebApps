# apps/kanboard/kanboard.pl
# Virtualmin Web App installer for Kanboard
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

sub script_kanboard_desc
{
    return "Kanboard Minimalist Project Management Software";
}

sub script_kanboard_uses
{
    return ( "php" );
}

sub script_kanboard_category
{
    return "Project";
}

sub script_kanboard_author
{
    return "Frédéric Guillot";
}

sub script_kanboard_site
{
    return "https://kanboard.org";
}

sub script_kanboard_versions
{
    return ( "1.2.40" );
}

sub script_kanboard_release
{
    return 2;
}

sub script_kanboard_passmode
{
    return 0;
}

sub script_kanboard_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"kanboard_dir\" size=\"25\" value=\"kanboard\"> ";
    $html .= "(Default: /kanboard or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_kanboard_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'kanboard_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_kanboard_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Kanboard requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_kanboard_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "kanboard-v$ver.tar.gz";
    my $url = "https://github.com/kanboard/kanboard/archive/refs/tags/v$ver.tar.gz";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_kanboard_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "kanboard-v$ver.tar.gz";
    my $url = "https://github.com/kanboard/kanboard/archive/refs/tags/v$ver.tar.gz";
    my $tmp_file = "/tmp/kanboard-$dom-$filename";
    my $tmp_unpack = "/tmp/kanboard-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from kanboard-x.x.x
    my @contents = glob("$tmp_unpack/kanboard-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable data directory (stores SQLite DB and uploads)
    my $data_dir = "$target_dir/data";
    make_path($data_dir) if !-d $data_dir;
    chmod(0777, $data_dir);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Installed Kanboard to $full_url. Default credentials are admin / admin."
    );
}

sub script_kanboard_uninstall
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
