# apps/fossbilling/fossbilling.pl
# Virtualmin Web App installer for FOSSBilling (BoxBilling successor)
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

sub script_fossbilling_desc
{
    return "FOSSBilling Billing & Digital Shopping Cart";
}

sub script_fossbilling_uses
{
    return ( "php", "mysql" );
}

sub script_fossbilling_category
{
    return "Commerce";
}

sub script_fossbilling_author
{
    return "FOSSBilling Community";
}

sub script_fossbilling_site
{
    return "https://fossbilling.org";
}

sub script_fossbilling_versions
{
    return ( "0.6.22", "latest" );
}

sub script_fossbilling_release
{
    return 1;
}

sub script_fossbilling_passmode
{
    return 0;
}

sub script_fossbilling_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"fb_dir\" size=\"25\" value=\"billing\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"fb_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"fb_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    return $html;
}

sub script_fossbilling_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'fb_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    my $email = $in->{'fb_email'} || "admin\@$d->{'dom'}";
    my $pass = $in->{'fb_pass'} || '';
    if (!$pass) {
        my @chars = ('A'..'Z', 'a'..'z', '0'..'9', '!', '@', '#', '%');
        $pass = join '', map { $chars[rand @chars] } 1..16;
    }

    return {
        'dir'   => $dir,
        'email' => $email,
        'pass'  => $pass,
    };
}

sub script_fossbilling_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "FOSSBilling requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "FOSSBilling requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_fossbilling_files
{
    my ($d, $ver, $opts) = @_;
    my $url = ($ver eq 'latest')
        ? "https://fossbilling.org/downloads/stable"
        : "https://github.com/FOSSBilling/FOSSBilling/releases/download/$ver/FOSSBilling.zip";

    return (
        {
            'name' => "FOSSBilling.zip",
            'url'  => $url,
        }
    );
}

sub script_fossbilling_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $url = ($ver eq 'latest')
        ? "https://fossbilling.org/downloads/stable"
        : "https://github.com/FOSSBilling/FOSSBilling/releases/download/$ver/FOSSBilling.zip";
    my $tmp_file = "/tmp/fb-$dom-FOSSBilling.zip";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Set up config.php template if available
    my $dbname = $defs->{'db'} || ($user . "_fossbilling");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    # Register background cron for invoicing & automation
    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $cron_line = "*/5 * * * * $php_bin $target_dir/cron.php >/dev/null 2>&1";
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    if ($current_cron !~ /cron\.php/) {
        my $new_cron = $current_cron . "\n" . $cron_line . "\n";
        if (open(my $cfh, '|-', "crontab -u $user -")) {
            print $cfh $new_cron;
            close($cfh);
        }
    }

    return (
        1,
        $full_url,
        "Installed FOSSBilling at $full_url. Complete initial setup wizard with database $dbname."
    );
}

sub script_fossbilling_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $user = $d->{'user'};
    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;

    # Remove cron
    my $current_cron = `crontab -u $user -l 2>/dev/null || true`;
    $current_cron =~ s/.*cron\.php.*\n?//g;
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
