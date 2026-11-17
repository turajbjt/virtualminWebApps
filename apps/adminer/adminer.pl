# apps/adminer/adminer.pl
# Virtualmin Web App installer for Adminer Database Manager
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

sub script_adminer_desc
{
    return "Adminer Lightweight Database Management Tool";
}

sub script_adminer_uses
{
    return ( "php", "mysql" );
}

sub script_adminer_category
{
    return "Database";
}

sub script_adminer_author
{
    return "Jakub Vrana";
}

sub script_adminer_site
{
    return "https://www.adminer.org";
}

sub script_adminer_versions
{
    return ( "4.8.1" );
}

sub script_adminer_release
{
    return 2;
}

sub script_adminer_passmode
{
    return 0;
}

sub script_adminer_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"adminer_dir\" size=\"25\" value=\"adminer\"> ";
    $html .= "(Default: /adminer, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_adminer_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'adminer_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_adminer_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Adminer requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_adminer_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "adminer-$ver.php";
    my $url = "https://github.com/vrana/adminer/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_adminer_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "adminer-$ver.php";
    my $url = "https://github.com/vrana/adminer/releases/download/v$ver/$filename";
    my $target_file = "$target_dir/index.php";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $target_file, 120);
    return (0, "Download failed: $err") if !$ok;

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Installed Adminer $ver to $full_url. Access database management directly at $full_url."
    );
}

sub script_adminer_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    if ($opts->{'dir'} && -d $target_dir) {
        remove_tree($target_dir);
    } elsif (-f "$target_dir/index.php") {
        unlink("$target_dir/index.php");
    }
    return 1;
}

1;
