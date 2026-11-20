# apps/freescout/freescout.pl
# Virtualmin Web App installer for FreeScout Help Desk & Shared Mailbox
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

sub script_freescout_desc
{
    return "FreeScout - Help Desk & Shared Mailbox";
}

sub script_freescout_uses
{
    return ( "php", "mysql" );
}

sub script_freescout_category
{
    return "Business";
}

sub script_freescout_author
{
    return "FreeScout Help Desk";
}

sub script_freescout_site
{
    return "https://freescout.net";
}

sub script_freescout_versions
{
    return ( "1.8.146", "latest" );
}

sub script_freescout_release
{
    return 1;
}

sub script_freescout_passmode
{
    return 0;
}

sub script_freescout_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"freescout_dir\" size=\"25\" value=\"helpdesk\"> ";
    $html .= "(Default: /helpdesk, leave empty for document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"freescout_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"freescout_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    return $html;
}

sub script_freescout_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'freescout_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);
    return $dir_err if $dir_err;

    my $email = $in->{'freescout_email'} || "admin\@$d->{'dom'}";
    my $pass = $in->{'freescout_pass'} || '';
    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    return {
        'dir'   => $clean_dir,
        'email' => $email,
        'pass'  => $pass,
    };
}

sub script_freescout_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "FreeScout requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "FreeScout requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_freescout_files
{
    my ($d, $ver, $opts) = @_;
    my $tag = ($ver eq 'latest') ? "1.8.146" : $ver;
    my $url = "https://github.com/freescout-helpdesk/freescout/releases/download/$tag/freescout-$tag.zip";

    return (
        {
            'name' => "freescout-$tag.zip",
            'url'  => $url,
        }
    );
}

sub script_freescout_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $tag = ($ver eq 'latest') ? "1.8.146" : $ver;
    my $url = "https://github.com/freescout-helpdesk/freescout/releases/download/$tag/freescout-$tag.zip";
    my $tmp_file = "/tmp/freescout-$dom-$tag.zip";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}" : "";
    my $full_url = "$proto://$dom$url_path";

    my $dbname = $defs->{'db'} || ($user . "_freescout");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    # Prepare .env
    my $env_file = "$target_dir/.env";
    my $app_key = "base64:" . VirtualminWebApps::Common::generate_random_key(32);

    my $env_content = <<"EOF";
APP_ENV=production
APP_KEY=$app_key
APP_DEBUG=false
APP_URL=$full_url
APP_LOCALE=en

DB_CONNECTION=mysql
DB_HOST=$dbhost
DB_PORT=3306
DB_DATABASE=$dbname
DB_USERNAME=$dbuser
DB_PASSWORD=$dbpass

MAIL_DRIVER=sendmail
MAIL_FROM_ADDRESS=$opts->{'email'}
MAIL_FROM_NAME="Help Desk"
EOF

    if (open(my $efh, ">", $env_file)) {
        print $efh $env_content;
        close($efh);
        VirtualminWebApps::Common::secure_file_permissions($env_file, 0600);
    }

    # Writable folders
    for my $sub ("storage", "storage/app", "storage/framework", "storage/logs", "bootstrap/cache") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Register background cron for fetching emails and running queues
    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $cron_line = "* * * * * $php_bin $target_dir/artisan schedule:run >> /dev/null 2>&1";
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    if ($current_cron !~ /artisan schedule:run/) {
        my $new_cron = $current_cron . "\n" . $cron_line . "\n";
        if (open(my $cfh, '|-', "crontab -u $user -")) {
            print $cfh $new_cron;
            close($cfh);
        }
    }

    return (
        1,
        $full_url,
        "Installed FreeScout at $full_url. Initial setup completed with database $dbname."
    );
}

sub script_freescout_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $user = $d->{'user'};
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    # Remove cron
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    $current_cron =~ s/.*artisan schedule:run.*\n?//g;
    if (open(my $cfh, '|-', "crontab -u $user -")) {
        print $cfh $current_cron;
        close($cfh);
    }

    if ($opts->{'dir'} && -d $target_dir) {
        remove_tree($target_dir);
    }
    return 1;
}

1;
