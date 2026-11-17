# apps/passbolt/passbolt.pl
# Virtualmin Web App installer for Passbolt Password Manager
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

sub script_passbolt_desc
{
    return "Passbolt Open-Source Team Password Manager";
}

sub script_passbolt_uses
{
    return ( "php", "mysql" );
}

sub script_passbolt_category
{
    return "Security";
}

sub script_passbolt_author
{
    return "Passbolt SA";
}

sub script_passbolt_site
{
    return "https://www.passbolt.com";
}

sub script_passbolt_versions
{
    return ( "5.18.0", "5.17.0" );
}

sub script_passbolt_release
{
    return 1;
}

sub script_passbolt_passmode
{
    return 0;
}

sub script_passbolt_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"passbolt_dir\" size=\"25\" value=\"\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_passbolt_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'passbolt_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    return { 'dir' => $dir };
}

sub script_passbolt_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Passbolt requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Passbolt requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_passbolt_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "passbolt-api-v$ver.tar.gz";
    my $url = "https://github.com/passbolt/passbolt_api/archive/refs/tags/v$ver.tar.gz";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_passbolt_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "passbolt-api-v$ver.tar.gz";
    my $url = "https://github.com/passbolt/passbolt_api/archive/refs/tags/v$ver.tar.gz";
    my $tmp_file = "/tmp/passbolt-$dom-$filename";
    my $tmp_unpack = "/tmp/passbolt-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 600);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Handle inner directory passbolt_api-5.x.x
    my @contents = glob("$tmp_unpack/passbolt_api-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $target_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Ensure writable logs and tmp
    for my $sub ("tmp", "logs") {
        if (-d "$target_dir/$sub") {
            chmod(0777, "$target_dir/$sub");
        }
    }

    my $dbname = $defs->{'db'} || ($user . "_passbolt");
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Extracted Passbolt to $full_url. Finish setup at $full_url using database '$dbname'."
    );
}

sub script_passbolt_uninstall
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
