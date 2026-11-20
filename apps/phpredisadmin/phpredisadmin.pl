# apps/phpredisadmin/phpredisadmin.pl
# Virtualmin Web App installer for phpRedisAdmin
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

sub script_phpredisadmin_desc
{
    return "phpRedisAdmin - Web GUI for Redis Databases";
}

sub script_phpredisadmin_uses
{
    return ( "php" );
}

sub script_phpredisadmin_category
{
    return "Database";
}

sub script_phpredisadmin_author
{
    return "Erik Dubbelboer";
}

sub script_phpredisadmin_site
{
    return "https://github.com/erikdubbelboer/phpRedisAdmin";
}

sub script_phpredisadmin_versions
{
    return ( "1.17.2", "latest" );
}

sub script_phpredisadmin_release
{
    return 1;
}

sub script_phpredisadmin_passmode
{
    return 0;
}

sub script_phpredisadmin_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"phpredisadmin_dir\" size=\"25\" value=\"redis\"> ";
    $html .= "(Default: /redis, leave empty for document root /)</td> </tr>";

    return $html;
}

sub script_phpredisadmin_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'phpredisadmin_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);
    return $dir_err if $dir_err;

    return { 'dir' => $clean_dir };
}

sub script_phpredisadmin_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "phpRedisAdmin requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_phpredisadmin_files
{
    my ($d, $ver, $opts) = @_;
    my $tag = ($ver eq 'latest') ? "v1.17.2" : "v$ver";
    my $filename = "phpredisadmin-$tag.tar.gz";
    my $url = "https://github.com/erikdubbelboer/phpRedisAdmin/archive/refs/tags/$tag.tar.gz";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_phpredisadmin_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $tag = ($ver eq 'latest') ? "v1.17.2" : "v$ver";
    my $filename = "phpredisadmin-$tag.tar.gz";
    my $url = "https://github.com/erikdubbelboer/phpRedisAdmin/archive/refs/tags/$tag.tar.gz";
    my $tmp_file = "/tmp/phpredisadmin-$dom-$filename";
    my $tmp_unpack = "/tmp/phpredisadmin-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my @dirs = glob("$tmp_unpack/phpRedisAdmin-*");
    if (@dirs && -d $dirs[0]) {
        system("cp -r $dirs[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $dirs[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    my $sample_conf = "$target_dir/includes/config.sample.inc.php";
    my $conf_file = "$target_dir/includes/config.inc.php";

    if (!-f $conf_file && -f $sample_conf) {
        system("cp $sample_conf $conf_file");
        VirtualminWebApps::Common::secure_file_permissions($conf_file, 0600);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}" : "";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Installed phpRedisAdmin at $full_url. Access the dashboard to view and manage local Redis databases."
    );
}

sub script_phpredisadmin_uninstall
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
