# apps/phpbb/phpbb.pl
# Virtualmin Web App installer for phpBB Forum
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

sub script_phpbb_desc
{
    return "phpBB Bulletin Board Forum";
}

sub script_phpbb_uses
{
    return ( "php", "mysql" );
}

sub script_phpbb_category
{
    return "Community";
}

sub script_phpbb_author
{
    return "phpBB Limited";
}

sub script_phpbb_site
{
    return "https://www.phpbb.com";
}

sub script_phpbb_versions
{
    return ( "3.3.13", "3.3.12" );
}

sub script_phpbb_release
{
    return 2;
}

sub script_phpbb_passmode
{
    return 0;
}

sub script_phpbb_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"phpbb_dir\" size=\"25\" value=\"forum\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_phpbb_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'phpbb_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_phpbb_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "phpBB requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "phpBB requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_phpbb_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "phpBB-$ver.zip";
    my ($major, $minor) = ($ver =~ /^(\d+)\.(\d+)/);
    my $url = "https://download.phpbb.com/pub/release/$major.$minor/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_phpbb_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my ($major, $minor) = ($ver =~ /^(\d+)\.(\d+)/);
    my $filename = "phpBB-$ver.zip";
    my $url = "https://download.phpbb.com/pub/release/$major.$minor/$ver/$filename";
    my $tmp_file = "/tmp/phpbb-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/phpbb-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $src = -d "$tmp_extract/phpBB3" ? "$tmp_extract/phpBB3" : $tmp_extract;
    system("cp -rf $src/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $src/.htaccess " . quotemeta("$target_dir/.htaccess") . " 2>/dev/null || true");
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_phpbb");
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url" . "install/",
        "Extracted phpBB to $full_url. Complete setup wizard at $full_url" . "install/ with database $dbname"
    );
}

sub script_phpbb_uninstall
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
