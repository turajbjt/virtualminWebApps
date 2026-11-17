# apps/mybb/mybb.pl
# Virtualmin Web App installer for MyBB Discussion Forum
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

sub script_mybb_desc
{
    return "MyBB Discussion Board & Community Forum";
}

sub script_mybb_uses
{
    return ( "php", "mysql" );
}

sub script_mybb_category
{
    return "Community";
}

sub script_mybb_author
{
    return "MyBB Group";
}

sub script_mybb_site
{
    return "https://mybb.com";
}

sub script_mybb_versions
{
    return ( "1.8.41" );
}

sub script_mybb_release
{
    return 2;
}

sub script_mybb_passmode
{
    return 0;
}

sub script_mybb_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"mybb_dir\" size=\"25\" value=\"forum\"> ";
    $html .= "(Default: /forum or /mybb, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_mybb_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'mybb_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_mybb_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "MyBB requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "MyBB requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_mybb_files
{
    my ($d, $ver, $opts) = @_;
    my $tag = $ver;
    $tag =~ s/\.//g;
    my $filename = "mybb_$tag.zip";
    my $url = "https://github.com/mybb/mybb/releases/download/mybb_$tag/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_mybb_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $tag = $ver;
    $tag =~ s/\.//g;
    my $filename = "mybb_$tag.zip";
    my $url = "https://github.com/mybb/mybb/releases/download/mybb_$tag/$filename";
    my $tmp_file = "/tmp/mybb-$dom-$filename";
    my $tmp_unpack = "/tmp/mybb-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from Upload directory
    if (-d "$tmp_unpack/Upload") {
        system("cp -r $tmp_unpack/Upload/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/Upload/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    # Rename config.default.php to config.php if config.php doesn't exist
    if (-f "$target_dir/inc/config.default.php" && !-f "$target_dir/inc/config.php") {
        system("cp $target_dir/inc/config.default.php $target_dir/inc/config.php");
    }

    # Ensure writable directories & configuration files
    for my $sub ("cache", "cache/themes", "uploads", "uploads/avatars") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }
    for my $f ("inc/config.php", "inc/settings.php") {
        my $p = "$target_dir/$f";
        if (-f $p) {
            chmod(0666, $p);
        }
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_mybb");
    my $dbuser = $defs->{'user'} || $user;
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";
    my $install_url = "$full_url" . "install/";

    return (
        1,
        $install_url,
        "Extracted MyBB $ver to $full_url. Finish the installation wizard at $install_url (Database: $dbname, User: $dbuser)."
    );
}

sub script_mybb_uninstall
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
