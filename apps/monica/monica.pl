# apps/monica/monica.pl
# Virtualmin Web App installer for Monica PRM
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

sub script_monica_desc
{
    return "Monica - Personal Relationship Management (PRM)";
}

sub script_monica_uses
{
    return ( "php", "mysql" );
}

sub script_monica_category
{
    return "Business";
}

sub script_monica_author
{
    return "Monica Community";
}

sub script_monica_site
{
    return "https://www.monicahq.com";
}

sub script_monica_versions
{
    return ( "4.1.2" );
}

sub script_monica_release
{
    return 3;
}

sub script_monica_passmode
{
    return 0; # Auto-generated DB password or user-provided
}

sub script_monica_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"monica_dir\" size=\"25\" value=\"monica\"> ";
    $html .= "(Default: /monica or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_monica_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'monica_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_monica_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Monica requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Monica requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_monica_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "monica-v$ver.tar.bz2";
    my $url = "https://github.com/monicahq/monica/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_monica_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "monica-v$ver.tar.bz2";
    my $url = "https://github.com/monicahq/monica/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/monica-$dom-$filename";
    my $tmp_unpack = "/tmp/monica-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 600);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from unpacked monica directory
    my @contents = glob("$tmp_unpack/monica-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    # Configure .env
    if (-f "$target_dir/.env.example" && !-f "$target_dir/.env") {
        system("cp -f $target_dir/.env.example $target_dir/.env");
        my $app_key = VirtualminWebApps::Common::generate_random_key(32);

        my $dbname = $defs->{'db'} || ($user . "_monica");
        my $dbuser = $defs->{'dbuser'} || $user;
        my $dbpass = $defs->{'dbpass'} || '';

        my $env_content = "";
        if (open(my $efh, "<", "$target_dir/.env")) {
            local $/ = undef;
            $env_content = <$efh>;
            close($efh);
            $env_content =~ s/APP_ENV=.*/APP_ENV=production/;
            $env_content =~ s/APP_KEY=.*/APP_KEY=$app_key/;
            $env_content =~ s|APP_URL=.*|APP_URL=$full_url|;
            $env_content =~ s/DB_CONNECTION=.*/DB_CONNECTION=mysql/;
            $env_content =~ s/DB_HOST=.*/DB_HOST=127.0.0.1/;
            $env_content =~ s/DB_PORT=.*/DB_PORT=3306/;
            $env_content =~ s/DB_DATABASE=.*/DB_DATABASE=$dbname/;
            $env_content =~ s/DB_USERNAME=.*/DB_USERNAME=$dbuser/;
            $env_content =~ s/DB_PASSWORD=.*/DB_PASSWORD=$dbpass/;
            if (open(my $wfh, ">", "$target_dir/.env")) {
                print $wfh $env_content;
                close($wfh);
            chmod(0600, "$target_dir/.env");
            }
        }
    }

    # Ensure writable directories
    for my $sub ("storage", "storage/framework", "storage/framework/cache", "storage/framework/sessions", "storage/framework/views", "storage/logs", "bootstrap/cache") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0777, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    return (
        1,
        "$full_url",
        "Installed Monica PRM to $full_url. Access the site to register your primary user account."
    );
}

sub script_monica_uninstall
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
