# apps/grocy/grocy.pl
# Virtualmin Web App installer for Grocy Home Pantry & Asset ERP
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

sub script_grocy_desc
{
    return "Grocy - Home Pantry & Asset Management ERP";
}

sub script_grocy_uses
{
    return ( "php" ); # Pure PHP with embedded SQLite
}

sub script_grocy_category
{
    return "Utilities";
}

sub script_grocy_author
{
    return "Bernd Bestel / Grocy Community";
}

sub script_grocy_site
{
    return "https://grocy.info";
}

sub script_grocy_versions
{
    return ( "4.4.2", "latest" );
}

sub script_grocy_release
{
    return 1;
}

sub script_grocy_passmode
{
    return 0;
}

sub script_grocy_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"grocy_dir\" size=\"25\" value=\"grocy\"> ";
    $html .= "(Default: /grocy, leave empty for document root /)</td> </tr>";

    return $html;
}

sub script_grocy_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'grocy_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);
    return $dir_err if $dir_err;

    return { 'dir' => $clean_dir };
}

sub script_grocy_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Grocy requires PHP to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_grocy_files
{
    my ($d, $ver, $opts) = @_;
    my $tag = ($ver eq 'latest') ? "4.4.2" : $ver;
    my $filename = "grocy_$tag.zip";
    my $url = "https://github.com/grocy/grocy/releases/download/v$tag/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_grocy_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $tag = ($ver eq 'latest') ? "4.4.2" : $ver;
    my $filename = "grocy_$tag.zip";
    my $url = "https://github.com/grocy/grocy/releases/download/v$tag/$filename";
    my $tmp_file = "/tmp/grocy-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $target_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}" : "";
    my $full_url = "$proto://$dom$url_path";

    # Configure data/config.php from config-dist.php
    my $data_dir = "$target_dir/data";
    make_path($data_dir) if !-d $data_dir;
    make_path("$data_dir/viewcache") if !-d "$data_dir/viewcache";

    my $dist_config = "$target_dir/config-dist.php";
    my $config_file = "$data_dir/config.php";

    if (!-f $config_file && -f $dist_config) {
        if (open(my $in_fh, "<", $dist_config)) {
            my $conf_content = do { local $/; <$in_fh> };
            close($in_fh);

            $conf_content =~ s/Setting\('BASE_URL', ''\);/Setting\('BASE_URL', '$full_url'\);/;

            if (open(my $out_fh, ">", $config_file)) {
                print $out_fh $conf_content;
                close($out_fh);
                VirtualminWebApps::Common::secure_file_permissions($config_file, 0600);
            }
        }
    }

    chmod(0775, $data_dir);
    chmod(0775, "$data_dir/viewcache");
    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    return (
        1,
        $full_url,
        "Installed Grocy at $full_url. Default initial login credentials: admin / admin (change password immediately under User Settings)."
    );
}

sub script_grocy_uninstall
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
