# apps/flarum/flarum.pl
# Virtualmin Web App installer for Flarum Discussion Forum
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

sub script_flarum_desc
{
    return "Flarum Modern Discussion Forum";
}

sub script_flarum_uses
{
    return ( "php", "mysql" );
}

sub script_flarum_category
{
    return "Community";
}

sub script_flarum_author
{
    return "Flarum Team";
}

sub script_flarum_site
{
    return "https://flarum.org";
}

sub script_flarum_versions
{
    return ( "latest" );
}

sub script_flarum_release
{
    return 1;
}

sub script_flarum_passmode
{
    return 0;
}

sub script_flarum_params
{
    my ($d) = @_;
    my $html = "";

    $html .= "<tr> <td><b>Install Subdirectory</b></td> <td>";
    $html .= "<input name=\"flarum_dir\" size=\"25\" value=\"forum\"> ";
    $html .= "(Leave empty to install in document root /)</td> </tr>";

    $html .= "<tr> <td><b>Forum Title</b></td> <td>";
    $html .= "<input name=\"flarum_title\" size=\"30\" value=\"$d->{'dom'} Forum\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"flarum_admin\" size=\"20\" value=\"admin\"></td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"flarum_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Leave empty to auto-generate)</td> </tr>";

    $html .= "<tr> <td><b>Admin Email</b></td> <td>";
    $html .= "<input name=\"flarum_email\" size=\"30\" value=\"admin\@$d->{'dom'}\"></td> </tr>";

    return $html;
}

sub script_flarum_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'flarum_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;

    my $title = $in->{'flarum_title'} || "$d->{'dom'} Forum";
    my $admin = $in->{'flarum_admin'} || 'admin';
    my $email = $in->{'flarum_email'} || "admin\@$d->{'dom'}";
    my $pass = $in->{'flarum_pass'} || '';

    if (!$pass) {
        my @chars = ('A'..'Z', 'a'..'z', '0'..'9', '!', '@', '#', '%');
        $pass = join '', map { $chars[rand @chars] } 1..16;
    }

    return {
        'dir'   => $dir,
        'title' => $title,
        'admin' => $admin,
        'pass'  => $pass,
        'email' => $email,
    };
}

sub script_flarum_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!$d->{'php'}) {
        return "Flarum requires PHP to be enabled for $d->{'dom'}.";
    }
    if (!$d->{'mysql'}) {
        return "Flarum requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_flarum_files
{
    return ();
}

sub script_flarum_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;

    my $doc_root = $d->{'public_html'} || "$d->{'home'}/public_html";
    my $target_dir = $opts->{'dir'} ? "$doc_root/$opts->{'dir'}" : $doc_root;
    make_path($target_dir) if !-d $target_dir;

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    # Download Composer if not present
    my $composer_bin = `which composer 2>/dev/null`;
    chomp($composer_bin);
    my $php_bin = `which php 2>/dev/null`;
    chomp($php_bin);
    $php_bin ||= "/usr/bin/php";

    if (!$composer_bin) {
        $composer_bin = "$target_dir/composer.phar";
        VirtualminWebApps::Common::download_url("https://getcomposer.org/download/latest-stable/composer.phar", $composer_bin, 60);
        chmod(0755, $composer_bin);
    }

    my $dbname = $defs->{'db'} || ($user . "_flarum");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "localhost";

    # Execute composer create-project
    my $cmd = "su -s /bin/sh $user -c 'cd " . quotemeta($target_dir) . " && " .
              quotemeta($php_bin) . " " . quotemeta($composer_bin) . " create-project flarum/flarum . --prefer-dist --no-interaction'";
    my $out = `$cmd 2>&1`;

    unlink("$target_dir/composer.phar") if -f "$target_dir/composer.phar";

    VirtualminWebApps::Common::set_ownership_recursive($target_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $url_path = $opts->{'dir'} ? "/$opts->{'dir'}/" : "/";
    my $full_url = "$proto://$dom$url_path";

    return (
        1,
        $full_url,
        "Installed Flarum at $full_url. Finish setup wizard with database $dbname"
    );
}

sub script_flarum_uninstall
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
