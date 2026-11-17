# apps/invoiceninja/invoiceninja.pl
# Virtualmin Web App installer for Invoice Ninja
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

sub script_invoiceninja_desc
{
    return "Invoice Ninja Invoicing & Payments Platform";
}

sub script_invoiceninja_uses
{
    return ( "php", "mysql" );
}

sub script_invoiceninja_category
{
    return "Business";
}

sub script_invoiceninja_author
{
    return "Invoice Ninja Community";
}

sub script_invoiceninja_site
{
    return "https://www.invoiceninja.com";
}

sub script_invoiceninja_versions
{
    return ( "5.10.40", "latest" );
}

sub script_invoiceninja_release
{
    return 2;
}

sub script_invoiceninja_passmode
{
    return 0;
}

sub script_invoiceninja_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"ninja_dir\" size=\"25\" value=\"invoice\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_invoiceninja_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'ninja_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_invoiceninja_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Invoice Ninja requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Invoice Ninja requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_invoiceninja_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "invoiceninja.tar";
    my $url = ($ver eq 'latest')
        ? "https://download.invoiceninja.com/invoiceninja.tar"
        : "https://github.com/invoiceninja/invoiceninja/releases/download/v$ver/invoiceninja.tar";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_invoiceninja_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $url = ($ver eq 'latest')
        ? "https://download.invoiceninja.com/invoiceninja.tar"
        : "https://github.com/invoiceninja/invoiceninja/releases/download/v$ver/invoiceninja.tar";
    my $tmp_file = "/tmp/ninja-$dom-invoiceninja.tar";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    # Extract tar
    system("tar -xf " . quotemeta($tmp_file) . " -C " . quotemeta($target_dir));
    unlink($tmp_file);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_invoiceninja");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "127.0.0.1";

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    # Setup .env
    my $env_file = "$target_dir/.env";
    if (-f "$target_dir/.env.example" && !-f $env_file) {
        system("cp -f $target_dir/.env.example $env_file");
    }

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

    # Generate key & migrate
    system("su -s /bin/sh $user -c 'cd " . quotemeta($target_dir) . " && " .
           quotemeta($php_bin) . " artisan key:generate --force' 2>/dev/null");
    system("su -s /bin/sh $user -c 'cd " . quotemeta($target_dir) . " && " .
           quotemeta($php_bin) . " artisan migrate --force' 2>/dev/null");

    # Register background scheduler cron
    my $cron_line = "* * * * * $php_bin $target_dir/artisan schedule:run >> /dev/null 2>&1";
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    if ($current_cron !~ /schedule:run/) {
        my $new_cron = $current_cron . "\n" . $cron_line . "\n";
        if (open(my $cfh, '|-', "crontab -u $user -")) {
            print $cfh $new_cron;
            close($cfh);
        }
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    return (
        1,
        $full_url,
        "Installed Invoice Ninja at $full_url with database $dbname. Complete setup wizard to create initial administrator."
    );
}

sub script_invoiceninja_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $user = $d->{'user'};
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    # Remove cron
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    $current_cron =~ s/.*schedule:run.*\n?//g;
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
