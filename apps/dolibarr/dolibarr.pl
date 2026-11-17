# apps/dolibarr/dolibarr.pl
# Virtualmin Web App installer for Dolibarr ERP & CRM
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

sub script_dolibarr_desc
{
    return "Dolibarr ERP & CRM Suite";
}

sub script_dolibarr_uses
{
    return ( "php", "mysql" );
}

sub script_dolibarr_category
{
    return "Business";
}

sub script_dolibarr_author
{
    return "Dolibarr Community";
}

sub script_dolibarr_site
{
    return "https://www.dolibarr.org";
}

sub script_dolibarr_versions
{
    return ( "20.0.2", "19.0.3" );
}

sub script_dolibarr_release
{
    return 1;
}

sub script_dolibarr_passmode
{
    return 0;
}

sub script_dolibarr_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"doli_dir\" size=\"25\" value=\"erp\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    return $html;
}

sub script_dolibarr_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'doli_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    return { 'dir' => $dir };
}

sub script_dolibarr_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Dolibarr requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Dolibarr requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_dolibarr_files
{
    my ($d, $ver, $opts) = @_;
    my $filename = "dolibarr-$ver.zip";
    my $url = "https://github.com/Dolibarr/dolibarr/archive/refs/tags/$ver.zip";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_dolibarr_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    # Dolibarr documents folder outside public_html for security
    my $docs_dir = "$d->{'home'}/dolibarr-documents";
    make_path($docs_dir) if !-d $docs_dir;
    VirtualminWebApps::Common::set_ownership_recursive($docs_dir, $user, $group);

    my $url = "https://github.com/Dolibarr/dolibarr/archive/refs/tags/$ver.zip";
    my $tmp_file = "/tmp/doli-$dom-v$ver.zip";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my $tmp_extract = "/tmp/doli-extract-$dom";
    make_path($tmp_extract);
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_extract);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $src = (glob("$tmp_extract/dolibarr*"))[0] || $tmp_extract;
    my $htdocs = -d "$src/htdocs" ? "$src/htdocs" : $src;

    system("cp -rf $htdocs/* " . quotemeta($target_dir) . "/ 2>/dev/null || true");
    system("cp -f $htdocs/.htaccess " . quotemeta("$target_dir/.htaccess") . " 2>/dev/null || true");
    remove_tree($tmp_extract);

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Pre-create conf/conf.php with database settings
    my $dbname = $defs->{'db'} || ($user . "_dolibarr");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    my $conf_file = "$target_dir/conf/conf.php";
    if (!-f $conf_file) {
        make_path("$target_dir/conf");
        open(my $cfh, '>', $conf_file);
        print $cfh <<"EOF";
<?php
\$dolibarr_main_url_root='$full_url';
\$dolibarr_main_document_root='$target_dir';
\$dolibarr_main_url_root_alt='/custom';
\$dolibarr_main_document_root_alt='$target_dir/custom';
\$dolibarr_main_data_root='$docs_dir';
\$dolibarr_main_db_host='$dbhost';
\$dolibarr_main_db_port='3306';
\$dolibarr_main_db_name='$dbname';
\$dolibarr_main_db_prefix='llx_';
\$dolibarr_main_db_user='$dbuser';
\$dolibarr_main_db_pass='$dbpass';
\$dolibarr_main_db_type='mysqli';
EOF
        close($cfh);
        chmod(0644, $conf_file);
        VirtualminWebApps::Common::set_ownership_recursive($conf_file, $user, $group);
    }

    return (
        1,
        "$full_url" . "install/",
        "Installed Dolibarr ERP to $full_url. Finish setup at $full_url" . "install/ with database $dbname"
    );
}

sub script_dolibarr_uninstall
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
