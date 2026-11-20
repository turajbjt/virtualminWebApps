# apps/shlink/shlink.pl
# Virtualmin Web App installer for Shlink URL Shortener
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

sub script_shlink_desc
{
    return "Shlink - Self-Hosted URL Shortener";
}

sub script_shlink_uses
{
    return ( "php", "mysql" );
}

sub script_shlink_category
{
    return "Utilities";
}

sub script_shlink_author
{
    return "Alejandro Celaya & Shlink Contributors";
}

sub script_shlink_site
{
    return "https://shlink.io";
}

sub script_shlink_versions
{
    return ( "4.2.1" );
}

sub script_shlink_release
{
    return 1;
}

sub script_shlink_passmode
{
    return 0;
}

sub script_shlink_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"shlink_dir\" size=\"25\" value=\"shlink\"> ";
    $html .= "(Default: /shlink, leave empty for document root /)</td> </tr>";

    $html .= "<tr> <td><b>Database Name</b></td> <td>";
    $html .= "<input name=\"shlink_db\" size=\"25\" value=\"shlink\"> ";
    $html .= "(MySQL/MariaDB database for short links and analytics)</td> </tr>";

    return $html;
}

sub script_shlink_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'shlink_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);
    return $dir_err if $dir_err;

    my $db = $in->{'shlink_db'} || 'shlink';
    if ($db =~ /[^a-zA-Z0-9_]/) {
        return "Database name contains invalid characters";
    }

    return { 'dir' => $clean_dir, 'db' => $db };
}

sub script_shlink_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Shlink requires PHP to be enabled for $d->{'dom'}.";
    }

    if (!$d->{'mysql'}) {
        return "Shlink requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_shlink_files
{
    my ($d, $ver, $opts) = @_;
    my $tag = ($ver eq 'latest') ? "4.2.1" : $ver;
    return (
        {
            'name' => "shlink-$tag.dist.zip",
            'url'  => "https://github.com/shlinkio/shlink/releases/download/v$tag/shlink-$tag.dist.zip"
        }
    );
}

sub script_shlink_install
{
    my ($d, $version, $opts) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};
    my $dir = $opts->{'dir'} || "shlink";
    my $db_name = $opts->{'db'} || "shlink";

    my $target_dir = "$home/public_html/$dir";
    $target_dir =~ s/\/$//;

    make_path($target_dir, { mode => 0755 });

    my $archive = "/tmp/shlink-$version.dist.zip";
    my $url = "https://github.com/shlinkio/shlink/releases/download/v$version/shlink-$version.dist.zip";

    if (VirtualminWebApps::Common::has_command('curl')) {
        system("curl -sSL -o $archive $url");
    } elsif (VirtualminWebApps::Common::has_command('wget')) {
        system("wget -q -O $archive $url");
    }

    if (-f $archive && VirtualminWebApps::Common::has_command('unzip')) {
        system("unzip -q -o $archive -d $target_dir");
        unlink $archive;
    }

    VirtualminWebApps::Common::set_domain_ownership($d, $target_dir);

    return (1, "Shlink URL Shortener v$version successfully installed to $target_dir.");
}

1;
