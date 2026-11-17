# apps/firefly_iii/firefly_iii.pl
# Virtualmin Web App installer for Firefly III
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

sub script_firefly_iii_desc
{
    return "Firefly III Personal Finance Manager";
}

sub script_firefly_iii_uses
{
    return ( "php", "mysql" );
}

sub script_firefly_iii_category
{
    return "Finance";
}

sub script_firefly_iii_author
{
    return "James Cole / Firefly III";
}

sub script_firefly_iii_site
{
    return "https://www.firefly-iii.org";
}

sub script_firefly_iii_versions
{
    return ( "6.7.9" );
}

sub script_firefly_iii_release
{
    return 2;
}

sub script_firefly_iii_passmode
{
    return 0;
}

sub script_firefly_iii_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"firefly_dir\" size=\"25\" value=\"finance\"> ";
    $html .= "(Default: /finance or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_firefly_iii_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'firefly_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_firefly_iii_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Firefly III requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Firefly III requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_firefly_iii_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "FireflyIII-v$ver.tar.gz";
    my $url = "https://github.com/firefly-iii/firefly-iii/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_firefly_iii_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "FireflyIII-v$ver.tar.gz";
    my $url = "https://github.com/firefly-iii/firefly-iii/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/firefly-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 600);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Set up .env
    if (-f "$target_dir/.env.example" && !-f "$target_dir/.env") {
        system("cp -f $target_dir/.env.example $target_dir/.env");
        my $app_key = VirtualminWebApps::Common::generate_random_key(32);

        my $dbname = $defs->{'db'} || ($user . "_firefly");
        my $dbuser = $defs->{'dbuser'} || $user;
        my $dbpass = $defs->{'dbpass'} || '';

        my $env_content = "";
        if (open(my $efh, "<", "$target_dir/.env")) {
            local $/ = undef;
            $env_content = <$efh>;
            close($efh);
            $env_content =~ s/DB_DATABASE=.*/DB_DATABASE=$dbname/;
            $env_content =~ s/DB_USERNAME=.*/DB_USERNAME=$dbuser/;
            $env_content =~ s/DB_PASSWORD=.*/DB_PASSWORD=$dbpass/;
            $env_content =~ s/APP_KEY=.*/APP_KEY=$app_key/;
            if (open(my $wfh, ">", "$target_dir/.env")) {
                print $wfh $env_content;
                close($wfh);
            chmod(0600, "$target_dir/.env");
            }
        }
    }

    # Ensure writable storage
    for my $sub ("storage", "storage/framework", "storage/logs", "bootstrap/cache") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0777, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Installed Firefly III to $full_url. Log in to register your administrative account."
    );
}

sub script_firefly_iii_uninstall
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
