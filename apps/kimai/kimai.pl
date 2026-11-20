# apps/kimai/kimai.pl
# Virtualmin Web App installer for Kimai Time Tracking & Invoicing
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

sub script_kimai_desc
{
    return "Kimai - Time Tracking & Invoicing";
}

sub script_kimai_uses
{
    return ( "php", "mysql" );
}

sub script_kimai_category
{
    return "Business";
}

sub script_kimai_author
{
    return "Kimai Team";
}

sub script_kimai_site
{
    return "https://www.kimai.org";
}

sub script_kimai_versions
{
    return ( "2.34.0", "latest" );
}

sub script_kimai_release
{
    return 1;
}

sub script_kimai_passmode
{
    return 0;
}

sub script_kimai_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"kimai_dir\" size=\"25\" value=\"kimai\"> ";
    $html .= "(Default: /kimai, leave empty for document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"kimai_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"kimai_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    return $html;
}

sub script_kimai_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'kimai_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);
    return $dir_err if $dir_err;

    my $email = $in->{'kimai_email'} || "admin\@$d->{'dom'}";
    my $pass = $in->{'kimai_pass'} || '';
    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    return {
        'dir'   => $clean_dir,
        'email' => $email,
        'pass'  => $pass,
    };
}

sub script_kimai_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Kimai requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Kimai requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_kimai_files
{
    my ($d, $ver, $opts) = @_;
    my $tag = ($ver eq 'latest') ? "2.34.0" : $ver;
    my $url = "https://github.com/kimai/kimai/releases/download/$tag/kimai.zip";

    return (
        {
            'name' => "kimai-$tag.zip",
            'url'  => $url,
        }
    );
}

sub script_kimai_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $tag = ($ver eq 'latest') ? "2.34.0" : $ver;
    my $url = "https://github.com/kimai/kimai/releases/download/$tag/kimai.zip";
    my $tmp_file = "/tmp/kimai-$dom-$tag.zip";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}" : "";
    my $full_url = "$proto://$dom$url_path";

    my $dbname = $defs->{'db'} || ($user . "_kimai");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "127.0.0.1";

    # Prepare .env.local
    my $env_file = "$target_dir/.env.local";
    my $app_secret = VirtualminWebApps::Common::generate_random_key(32);

    my $env_content = <<"EOF";
APP_ENV=prod
APP_SECRET=$app_secret
DATABASE_URL="mysql://$dbuser:$dbpass\@$dbhost:3306/$dbname?charset=utf8mb4&serverVersion=10.11.0-mariadb"
CORS_ALLOW_ORIGIN=^https?://(localhost|127\\.0\\.0\\.1)(:[0-9]+)?\$
EOF

    if (open(my $efh, ">", $env_file)) {
        print $efh $env_content;
        close($efh);
        VirtualminWebApps::Common::secure_file_permissions($env_file, 0600);
    }

    # Writable folders
    for my $sub ("var", "var/cache", "var/log", "var/plugins", "public/avatars") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    return (
        1,
        $full_url,
        "Installed Kimai at $full_url. Configured with database $dbname."
    );
}

sub script_kimai_uninstall
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
