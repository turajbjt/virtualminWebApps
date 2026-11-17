#!/usr/bin/env perl
# tests/09_virtualmin_loader.t
# Verifies that all 69 scripts can be dynamically loaded via Perl's `do` operator
# when symlinked into Virtualmin's custom scripts directory (/etc/webmin/virtual-server/scripts)
# exactly matching Virtualmin's get_script() loader routine in scripts-lib.pl.

use strict;
use warnings;
use Test::More;
use File::Basename;
use File::Temp qw(tempdir);
use Cwd qw(abs_path);

my $root_dir = abs_path(dirname(__FILE__) . "/..");
my $apps_dir = "$root_dir/apps";

opendir(my $dh, $apps_dir) or die "Cannot read $apps_dir: $!";
my @app_dirs = grep { -d "$apps_dir/$_" && !/^\./ } readdir($dh);
closedir($dh);

plan tests => scalar(@app_dirs) * 3;

# Create isolated mock Virtualmin scripts directory (WITHOUT any local lib)
my $tmp_dir = tempdir(CLEANUP => 1);
my $mock_scripts_dir = "$tmp_dir/scripts";
mkdir($mock_scripts_dir, 0755) or die "Cannot create $mock_scripts_dir: $!";

for my $app (sort @app_dirs) {
    my $src_pl = "$apps_dir/$app/$app.pl";
    my $target_symlink = "$mock_scripts_dir/$app.pl";
    symlink($src_pl, $target_symlink) or die "Cannot symlink $src_pl to $target_symlink: $!";

    # Virtualmin get_script() simulation:
    # 1. Check readability
    ok(-r $target_symlink, "$app symlink is readable in Virtualmin scripts dir");

    # 2. Execute via Perl `do` operator
    my $ret = eval { do $target_symlink };
    my $err = $@;
    ok($ret && !$err, "$app loads cleanly via do() without INC errors" . ($err ? " (Error: $err)" : ""));

    # 3. Check that mandatory descriptor functions exist
    my $desc_func = "script_${app}_desc";
    my $vers_func = "script_${app}_versions";
    my $has_funcs = main->can($desc_func) && main->can($vers_func);
    ok($has_funcs, "$app defines mandatory Virtualmin functions ($desc_func and $vers_func)");
}
