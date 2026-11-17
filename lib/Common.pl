# lib/Common.pl
# Shared utility functions for Virtualmin custom web app installers
package VirtualminWebApps::Common;

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path remove_tree);

# download_url($url, $dest_file, [$timeout])
# Downloads a file via curl or wget, with fallback
sub download_url
{
    my ($url, $dest, $timeout) = @_;
    $timeout ||= 120;

    my $dest_dir = dirname($dest);
    if (!-d $dest_dir) {
        make_path($dest_dir);
    }

    my $cmd;
    if (&has_command('curl')) {
        $cmd = "curl -f -s -S -L --connect-timeout 15 --max-time $timeout -o " . quotemeta($dest) . " " . quotemeta($url);
    }
    elsif (&has_command('wget')) {
        $cmd = "wget -q --timeout=$timeout -O " . quotemeta($dest) . " " . quotemeta($url);
    }
    else {
        return (0, "Neither curl nor wget is available on this system.");
    }

    my $out = `$cmd 2>&1`;
    my $rc = $? >> 8;
    if ($rc != 0 || !-f $dest || -s $dest == 0) {
        unlink($dest) if -f $dest;
        return (0, "Download failed from $url: $out");
    }

    return (1, undef);
}

# extract_archive($archive_path, $dest_dir, [$strip_components])
# Extracts .tar.gz, .tgz, .tar.xz, .zip
sub extract_archive
{
    my ($archive, $dest_dir, $strip_components) = @_;
    $strip_components ||= 0;

    if (!-f $archive) {
        return (0, "Archive not found: $archive");
    }

    make_path($dest_dir) if !-d $dest_dir;

    my $cmd;
    if ($archive =~ /\.(tar\.gz|tgz)$/i) {
        my $strip = $strip_components > 0 ? "--strip-components=$strip_components" : "";
        $cmd = "tar -xzf " . quotemeta($archive) . " $strip -C " . quotemeta($dest_dir);
    }
    elsif ($archive =~ /\.(tar\.xz|txz)$/i) {
        my $strip = $strip_components > 0 ? "--strip-components=$strip_components" : "";
        $cmd = "tar -xJf " . quotemeta($archive) . " $strip -C " . quotemeta($dest_dir);
    }
    elsif ($archive =~ /\.zip$/i) {
        if (!&has_command('unzip')) {
            return (0, "'unzip' command is required to extract $archive");
        }
        $cmd = "unzip -q -o " . quotemeta($archive) . " -d " . quotemeta($dest_dir);
    }
    else {
        return (0, "Unsupported archive format for $archive");
    }

    my $out = `$cmd 2>&1`;
    my $rc = $? >> 8;
    if ($rc != 0) {
        return (0, "Extraction failed: $out");
    }

    return (1, undef);
}

# set_ownership_recursive($path, $user, $group)
sub set_ownership_recursive
{
    my ($path, $user, $group) = @_;
    return 1 if !-e $path;

    my $uid = (getpwnam($user))[2];
    my $gid = defined($group) ? (getgrnam($group))[2] : (getpwnam($user))[3];

    return (0, "User $user not found") if !defined $uid;
    return (0, "Group $group not found") if !defined $gid;

    my $cmd = "chown -R " . quotemeta("$user:$group") . " " . quotemeta($path);
    my $out = `$cmd 2>&1`;
    return ($? >> 8 == 0) ? (1, undef) : (0, $out);
}

# has_command($cmd_name)
sub has_command
{
    my ($cmd) = @_;
    my $which = `which $cmd 2>/dev/null`;
    chomp($which);
    return ($which && -x $which) ? 1 : 0;
}

# get_arch()
# Returns normalized architecture: amd64, arm64, armv7
sub get_arch
{
    my $arch = `uname -m 2>/dev/null`;
    chomp($arch);
    if ($arch =~ /^(x86_64|amd64)$/i) {
        return "amd64";
    }
    elsif ($arch =~ /^(aarch64|arm64)$/i) {
        return "arm64";
    }
    elsif ($arch =~ /^armv7/i) {
        return "armv7";
    }
    return $arch;
}

1;
