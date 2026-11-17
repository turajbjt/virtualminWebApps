# apps/invoiceplane/invoiceplane.pl
# Virtualmin Web App installer for InvoicePlane
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

sub script_invoiceplane_desc
{
    return "InvoicePlane Open-Source Invoicing & Client Management";
}

sub script_invoiceplane_uses
{
    return ( "php", "mysql" );
}

sub script_invoiceplane_category
{
    return "Business";
}

sub script_invoiceplane_author
{
    return "InvoicePlane Community";
}

sub script_invoiceplane_site
{
    return "https://invoiceplane.com";
}

sub script_invoiceplane_versions
{
    return ( "1.6.1" );
}

sub script_invoiceplane_release
{
    return 2;
}

sub script_invoiceplane_passmode
{
    return 0;
}

sub script_invoiceplane_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"invoiceplane_dir\" size=\"25\" value=\"invoices\"> ";
    $html .= "(Default: /invoices or /invoiceplane, leave empty for root /)</td> </tr>";

    return $html;
}

sub script_invoiceplane_parse
{
    my ($d, $in) = @_;
    my $raw_dir = $in->{'invoiceplane_dir'} || '';

    my ($clean_dir, $dir_err) = VirtualminWebApps::Common::sanitize_path($raw_dir, 1);

    return $dir_err if $dir_err;

    my $dir = $clean_dir;

    return { 'dir' => $dir };
}

sub script_invoiceplane_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "InvoicePlane requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "InvoicePlane requires MySQL/MariaDB to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_invoiceplane_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "invoiceplane-$ver.zip";
    my $url = "https://github.com/InvoicePlane/InvoicePlane/releases/download/v$ver/v$ver.zip";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_invoiceplane_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    my $filename = "invoiceplane-$ver.zip";
    my $url = "https://github.com/InvoicePlane/InvoicePlane/releases/download/v$ver/v$ver.zip";
    my $tmp_file = "/tmp/invoiceplane-$dom-$filename";
    my $tmp_unpack = "/tmp/invoiceplane-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from ip folder inside archive
    if (-d "$tmp_unpack/ip") {
        system("cp -r $tmp_unpack/ip/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/ip/.[!.]* $target_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $target_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $target_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}" : "";
    my $full_url = "$proto://$dom$url_path";

    # Configure ipconfig.php from ipconfig.php.example
    my $example_conf = "$target_dir/ipconfig.php.example";
    my $conf_file = "$target_dir/ipconfig.php";
    if (-f $example_conf && !-f $conf_file) {
        if (open(my $in_fh, "<", $example_conf)) {
            my $conf_data = do { local $/; <$in_fh> };
            close($in_fh);

            $conf_data =~ s/IP_URL=http:\/\/localhost/IP_URL=$full_url/;

            if (open(my $out_fh, ">", $conf_file)) {
                print $out_fh $conf_data;
                close($out_fh);
            }
        }
    }

    # Ensure writable directories
    for my $sub ("uploads", "uploads/archive", "uploads/customer_files", "application/logs") {
        my $p = "$target_dir/$sub";
        make_path($p) if !-d $p;
        chmod(0775, $p);
    }

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $dbname = $defs->{'db'} || ($user . "_invoices");
    my $dbuser = $defs->{'user'} || $user;
    my $setup_url = "$full_url/index.php/setup";

    return (
        1,
        $setup_url,
        "Extracted InvoicePlane $ver to $full_url. Finish the installation wizard at $setup_url (Database: $dbname, User: $dbuser)."
    );
}

sub script_invoiceplane_uninstall
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
