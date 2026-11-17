# apps/cyberchef/cyberchef.pl
# Virtualmin Web App installer for CyberChef
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

sub script_cyberchef_desc
{
    return "CyberChef The Cyber Swiss Army Knife";
}

sub script_cyberchef_uses
{
    return ();
}

sub script_cyberchef_category
{
    return "Utilities";
}

sub script_cyberchef_author
{
    return "GCHQ";
}

sub script_cyberchef_site
{
    return "https://gchq.github.io/CyberChef/";
}

sub script_cyberchef_versions
{
    return ( "11.5.0" );
}

sub script_cyberchef_release
{
    return 1;
}

sub script_cyberchef_passmode
{
    return 0;
}

sub script_cyberchef_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"cyberchef_dir\" size=\"25\" value=\"cyberchef\"> ";
    $html .= "(Default: /cyberchef or leave empty for root /)</td> </tr>";

    return $html;
}

sub script_cyberchef_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'cyberchef_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    return { 'dir' => $dir };
}

sub script_cyberchef_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    return undef;
}

sub script_cyberchef_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "CyberChef_v$ver.zip";
    my $url = "https://github.com/gchq/CyberChef/releases/download/v$ver/CyberChef_8cd426dd4f40f1423912d5fad91b578a86a65112.zip";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_cyberchef_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "CyberChef_v$ver.zip";
    my $url = "https://github.com/gchq/CyberChef/releases/download/v$ver/CyberChef_8cd426dd4f40f1423912d5fad91b578a86a65112.zip";
    my $tmp_file = "/tmp/cyberchef-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Ensure index.html exists if named CyberChef_*.html
    if (!-f "$target_dir/index.html") {
        my ($chef_html) = glob("$target_dir/CyberChef_*.html");
        if ($chef_html && -f $chef_html) {
            system("cp -f $chef_html $target_dir/index.html");
        }
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        "$full_url",
        "Installed CyberChef to $full_url. Access directly in your browser."
    );
}

sub script_cyberchef_uninstall
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
