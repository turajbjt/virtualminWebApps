# apps/linkstack/linkstack.pl
# Virtualmin Web App installer for LinkStack
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

sub script_linkstack_desc
{
    return "LinkStack Open-Source Linktree Alternative";
}

sub script_linkstack_uses
{
    return ( "php", "mysql" );
}

sub script_linkstack_category
{
    return "Utilities";
}

sub script_linkstack_author
{
    return "LinkStack Community";
}

sub script_linkstack_site
{
    return "https://linkstack.org";
}

sub script_linkstack_versions
{
    return ( "4.8.8" );
}

sub script_linkstack_release
{
    return 1;
}

sub script_linkstack_passmode
{
    return 0;
}

sub script_linkstack_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"linkstack_dir\" size=\"25\" value=\"links\"> ";
    $html .= "(Default: /links or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_linkstack_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'linkstack_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    return { 'dir' => $dir };
}

sub script_linkstack_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "LinkStack requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_linkstack_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "linkstack-$ver.zip";
    my $url = "https://github.com/LinkStackOrg/LinkStack/releases/download/v$ver/linkstack.zip";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_linkstack_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "linkstack-$ver.zip";
    my $url = "https://github.com/LinkStackOrg/LinkStack/releases/download/v$ver/linkstack.zip";
    my $tmp_file = "/tmp/linkstack-$dom-$filename";
    my $tmp_unpack = "/tmp/linkstack-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted linkstack directory
    if (-d "$tmp_unpack/linkstack") {
        system("cp -r $tmp_unpack/linkstack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/linkstack/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Ensure writable directories
    for my $sub ("database", "storage", "bootstrap/cache") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_linkstack");
    my $dbuser = $defs->{'user'} || $user;
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Extracted LinkStack $ver to $full_url. Finish the installation wizard at $full_url (Database: $dbname, User: $dbuser, or SQLite)."
    );
}

sub script_linkstack_uninstall
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
