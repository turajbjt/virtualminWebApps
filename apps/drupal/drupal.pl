# apps/drupal/drupal.pl
# Virtualmin Web App installer for Drupal CMS
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

sub script_drupal_desc
{
    return "Drupal Enterprise Content Management System";
}

sub script_drupal_uses
{
    return ( "php", "mysql" );
}

sub script_drupal_category
{
    return "CMS";
}

sub script_drupal_author
{
    return "Drupal Community";
}

sub script_drupal_site
{
    return "https://www.drupal.org";
}

sub script_drupal_versions
{
    return ( "10.3.5", "10.2.7" );
}

sub script_drupal_release
{
    return 2;
}

sub script_drupal_passmode
{
    return 0;
}

sub script_drupal_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"drupal_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_drupal_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'drupal_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_drupal_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Drupal requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Drupal requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_drupal_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "drupal-$ver.tar.gz";
    my $url = "https://ftp.drupal.org/files/projects/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_drupal_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "drupal-$ver.tar.gz";
    my $url = "https://ftp.drupal.org/files/projects/$filename";
    my $tmp_file = "/tmp/drupal-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir, 1);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_drupal");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    # Prepare sites/default/settings.php
    my $sites_default = "$target_dir/sites/default";
    my $settings_file = "$sites_default/settings.php";
    my $default_settings = "$sites_default/default.settings.php";

    if (-f $default_settings && !-f $settings_file) {
        system("cp -f $default_settings $settings_file");
        open(my $sfh, '>>', $settings_file);
        print $sfh <<"EOF";

\$databases['default']['default'] = array (
  'database' => '$dbname',
  'username' => '$dbuser',
  'password' => '$dbpass',
  'prefix' => '',
  'host' => '$dbhost',
  'port' => '3306',
  'namespace' => 'Drupal\\\\Core\\\\Database\\\\Driver\\\\mysql',
  'driver' => 'mysql',
);
\$settings['hash_salt'] = '@{[ join('', map { ('a'..'z','0'..'9')[rand 36] } 1..32) ]}';
EOF
        close($sfh);
        chmod(0664, $settings_file);
    }

    # Prepare files directory
    my $files_dir = "$sites_default/files";
    make_path($files_dir) if !-d $files_dir;
    chmod(0775, $files_dir);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Installed Drupal at $full_url with database $dbname. Open the site to complete initial setup."
    );
}

sub script_drupal_uninstall
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
