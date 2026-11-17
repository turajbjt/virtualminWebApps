# apps/bookstack/bookstack.pl
# Virtualmin Web App installer for BookStack Documentation Platform
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

sub script_bookstack_desc
{
    return "BookStack Documentation Platform";
}

sub script_bookstack_uses
{
    return ( "php", "mysql" );
}

sub script_bookstack_category
{
    return "Wiki";
}

sub script_bookstack_author
{
    return "Dan Brown / BookStack Community";
}

sub script_bookstack_site
{
    return "https://www.bookstackapp.com";
}

sub script_bookstack_versions
{
    return ( "24.05.4", "24.05.3" );
}

sub script_bookstack_release
{
    return 2;
}

sub script_bookstack_passmode
{
    return 0;
}

sub script_bookstack_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"bs_dir\" size=\"25\" value=\"docs\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_bookstack_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'bs_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_bookstack_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "BookStack requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "BookStack requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_bookstack_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "BookStack-v$ver.zip";
    my $url = "https://github.com/BookStackApp/BookStack/archive/refs/tags/v$ver.zip";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_bookstack_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $url = "https://github.com/BookStackApp/BookStack/archive/refs/tags/v$ver.zip";
    my $tmp_file = "/tmp/bs-$dom-v$ver.zip";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/bs-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $src = (glob("$tmp_extract/BookStack*"))[0] || $tmp_extract;
    system("cp -rf $src/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $src/.env.example " . quotemeta("$target_dir/.env") . " 2>/dev/null || true");
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_bookstack");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "127.0.0.1";

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    # Configure .env
    my $env_file = "$target_dir/.env";
    if (-f $env_file) {
        my $content = VirtualminWebApps::ProxyHelper::read_file_contents($env_file);
        $content =~ s|^APP_URL=.*|APP_URL=$full_url|m;
        $content =~ s|^DB_HOST=.*|DB_HOST=$dbhost|m;
        $content =~ s|^DB_DATABASE=.*|DB_DATABASE=$dbname|m;
        $content =~ s|^DB_USERNAME=.*|DB_USERNAME=$dbuser|m;
        $content =~ s|^DB_PASSWORD=.*|DB_PASSWORD=$dbpass|m;
        VirtualminWebApps::ProxyHelper::write_file_contents($env_file, $content);
    }

    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    # Generate app key & run migrations
    system("su -s /bin/sh $user -c 'cd " . quotemeta($target_dir) . " && " .
           quotemeta($php_bin) . " artisan key:generate --no-interaction' 2>/dev/null");
    system("su -s /bin/sh $user -c 'cd " . quotemeta($target_dir) . " && " .
           quotemeta($php_bin) . " artisan migrate --force --no-interaction' 2>/dev/null");

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    return (
        1,
        $full_url,
        "Installed BookStack at $full_url. Default credentials: admin\@admin.com / password"
    );
}

sub script_bookstack_uninstall
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
