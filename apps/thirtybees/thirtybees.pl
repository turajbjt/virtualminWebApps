# apps/thirtybees/thirtybees.pl
# Virtualmin Web App installer for Thirty Bees High-Performance E-Commerce
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

sub script_thirtybees_desc
{
    return "Thirty Bees High-Performance E-Commerce";
}

sub script_thirtybees_uses
{
    return ( "php", "mysql" );
}

sub script_thirtybees_category
{
    return "Commerce";
}

sub script_thirtybees_author
{
    return "Thirty Bees Community";
}

sub script_thirtybees_site
{
    return "https://thirtybees.com";
}

sub script_thirtybees_versions
{
    return ( "1.7.0", "1.6.0" );
}

sub script_thirtybees_release
{
    return 1;
}

sub script_thirtybees_passmode
{
    return 0;
}

sub script_thirtybees_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"thirtybees_dir\" size=\"25\" value=\"shop\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Shop Name</b></td> <td>";
    $html .= "<input name=\"thirtybees_name\" size=\"30\" value=\"$d->{'dom'} Store\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"thirtybees_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"thirtybees_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Minimum 8 characters. Leave empty to auto-generate)</td> </tr>";

    return $html;
}

sub script_thirtybees_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'thirtybees_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    my $name = $in->{'thirtybees_name'} || "$d->{'dom'} Store";
    my $email = $in->{'thirtybees_email'} || "admin\@$d->{'dom'}";
    my $pass = $in->{'thirtybees_pass'} || '';
    if (!$pass || length($pass) < 8) {
        my @chars = ('A'..'Z', 'a'..'z', '0'..'9', '!', '@', '#', '%');
        $pass = join '', map { $chars[rand @chars] } 1..16;
    }

    return {
        'dir'   => $dir,
        'name'  => $name,
        'email' => $email,
        'pass'  => $pass,
    };
}

sub script_thirtybees_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Thirty Bees requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Thirty Bees requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_thirtybees_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "thirtybees-v$ver.zip";
    my $url = "https://github.com/thirtybees/thirtybees/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_thirtybees_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "thirtybees-v$ver.zip";
    my $download_url = "https://github.com/thirtybees/thirtybees/releases/download/$ver/$filename";
    my $tmp_file = "/tmp/tb-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/tb-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    system("cp -rf $tmp_extract/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_thirtybees");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    my $admin_email = $opts->{'email'};
    my $admin_pass = $opts->{'pass'};
    my $shop_name = $opts->{'name'};

    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    my $base_uri = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $ssl_flag = $d->{'ssl'} ? 1 : 0;

    # CLI Installer execution if present
    if (-f "$target_dir/install/index_cli.php") {
        my $install_cmd = "su -s /bin/sh $user -c '" .
            quotemeta($php_bin) . " " . quotemeta("$target_dir/install/index_cli.php") . " " .
            "--domain=" . quotemeta($dom) . " " .
            "--db_server=" . quotemeta($dbhost) . " " .
            "--db_name=" . quotemeta($dbname) . " " .
            "--db_user=" . quotemeta($dbuser) . " " .
            "--db_password=" . quotemeta($dbpass) . " " .
            "--prefix=\"tb_\" " .
            "--email=" . quotemeta($admin_email) . " " .
            "--password=" . quotemeta($admin_pass) . " " .
            "--name=" . quotemeta($shop_name) . " " .
            "--base_uri=" . quotemeta($base_uri) . " " .
            "--ssl=" . $ssl_flag . "'";

        my $out = `$install_cmd 2>&1`;
        remove_tree("$target_dir/install");
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $full_url = "$proto://$dom$base_uri";

    return (
        1,
        $full_url,
        "Installed Thirty Bees at $full_url. Admin: $admin_email (Password: $admin_pass)"
    );
}

sub script_thirtybees_uninstall
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
