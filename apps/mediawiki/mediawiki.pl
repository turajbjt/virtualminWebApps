# apps/mediawiki/mediawiki.pl
# Virtualmin Web App installer for MediaWiki
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

sub script_mediawiki_desc
{
    return "MediaWiki - Knowledge Base & Wiki";
}

sub script_mediawiki_uses
{
    return ( "php", "mysql" );
}

sub script_mediawiki_category
{
    return "Wiki";
}

sub script_mediawiki_author
{
    return "Wikimedia Foundation";
}

sub script_mediawiki_site
{
    return "https://www.mediawiki.org";
}

sub script_mediawiki_versions
{
    return ( "1.42.3", "1.41.4", "1.39.10" );
}

sub script_mediawiki_release
{
    return 3;
}

sub script_mediawiki_passmode
{
    return 0;
}

sub script_mediawiki_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"mw_dir\" size=\"25\" value=\"wiki\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Wiki Name</b></td> <td>";
    $html .= "<input name=\"mw_name\" size=\"30\" value=\"$d->{'dom'} Wiki\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"mw_admin\" size=\"20\" value=\"admin\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"mw_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Minimum 10 chars. Leave empty to auto-generate)</td> </tr>";

    return $html;
}

sub script_mediawiki_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'mw_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    my $name = $in->{'mw_name'} || "$d->{'dom'} Wiki";
    my $admin = $in->{'mw_admin'} || 'admin';
    my $pass = $in->{'mw_pass'} || '';

    if (!$pass || length($pass) < 10) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    return {
        'dir'   => $dir,
        'name'  => $name,
        'admin' => $admin,
        'pass'  => $pass,
    };
}

sub script_mediawiki_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "MediaWiki requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "MediaWiki requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_mediawiki_files
{
    my ($d, $ver, $opts) = @_;
    my ($major, $minor) = ($ver =~ /^(\d+)\.(\d+)/);
    my $branch = "$major.$minor";
    my $filename = "mediawiki-$ver.tar.gz";
    my $url = "https://releases.wikimedia.org/mediawiki/$branch/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_mediawiki_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my ($major, $minor) = ($ver =~ /^(\d+)\.(\d+)/);
    my $branch = "$major.$minor";
    my $filename = "mediawiki-$ver.tar.gz";
    my $download_url = "https://releases.wikimedia.org/mediawiki/$branch/$filename";
    my $tmp_file = "/tmp/mw-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir, 1);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_mediawiki");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $scriptpath = $opts->{'dir'} ? "/$opts->{'dir'}" : "";
    my $server_url = "$proto://$dom";
    my $full_url = "$server_url" . ($scriptpath ? "$scriptpath/" : "/");

    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    # Run MediaWiki automated CLI installer
    my $run_script = (-f "$target_dir/maintenance/run.php")
        ? "$target_dir/maintenance/run.php install"
        : "$target_dir/maintenance/install.php";

    my $install_cmd = "su -s /bin/sh $user -c '" .
        quotemeta($php_bin) . " " . $run_script . " " .
        "--dbtype mysql " .
        "--dbserver " . quotemeta($dbhost) . " " .
        "--dbname " . quotemeta($dbname) . " " .
        "--dbuser " . quotemeta($dbuser) . " " .
        "--dbpass " . quotemeta($dbpass) . " " .
        "--server " . quotemeta($server_url) . " " .
        "--scriptpath " . quotemeta($scriptpath) . " " .
        "--pass " . quotemeta($opts->{'pass'}) . " " .
        quotemeta($opts->{'name'}) . " " .
        quotemeta($opts->{'admin'}) . "'";

    my $out = `$install_cmd 2>&1`;
    my $rc = $? >> 8;
    if ($rc != 0 && !-f "$target_dir/LocalSettings.php") {
        return (0, "MediaWiki CLI setup failed: $out");
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    return (
        1,
        $full_url,
        "Installed MediaWiki at $full_url. Admin: $opts->{'admin'} (Password: $opts->{'pass'})"
    );
}

sub script_mediawiki_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    if ($opts->{'dir'} && -d $target_dir) {
        remove_tree($target_dir);
    }
    return 1;
}

sub script_mediawiki_upgrade
{
    my ($d, $ver, $opts) = @_;
    my $user = $d->{'user'};
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $update_script = (-f "$target_dir/maintenance/run.php")
        ? "$target_dir/maintenance/run.php update --quick"
        : "$target_dir/maintenance/update.php --quick";

    system("su -s /bin/sh $user -c '$php_bin $update_script'");
    return 1;
}

1;
