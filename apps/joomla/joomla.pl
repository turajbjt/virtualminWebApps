# apps/joomla/joomla.pl
# Virtualmin Web App installer for Joomla! CMS
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

sub script_joomla_desc
{
    return "Joomla! Content Management System";
}

sub script_joomla_uses
{
    return ( "php", "mysql" );
}

sub script_joomla_category
{
    return "CMS";
}

sub script_joomla_author
{
    return "Open Source Matters";
}

sub script_joomla_site
{
    return "https://www.joomla.org";
}

sub script_joomla_versions
{
    return ( "5.1.4", "4.4.8" );
}

sub script_joomla_release
{
    return 2;
}

sub script_joomla_passmode
{
    return 0;
}

sub script_joomla_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"joomla_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_joomla_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'joomla_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_joomla_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Joomla! requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Joomla! requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_joomla_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "Joomla_$ver-Stable-Full_Package.zip";
    my $url = "https://github.com/joomla/joomla-cms/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_joomla_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "Joomla_$ver-Stable-Full_Package.zip";
    my $url = "https://github.com/joomla/joomla-cms/releases/download/$ver/$filename";
    my $tmp_file = "/tmp/joomla-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    if (-f "$target_dir/htaccess.txt" && !-f "$target_dir/.htaccess") {
        system("cp -f $target_dir/htaccess.txt $target_dir/.htaccess");
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_joomla");
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url" . "installation/",
        "Extracted Joomla! to $full_url. Finish setup at $full_url" . "installation/ with database $dbname"
    );
}

sub script_joomla_uninstall
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
