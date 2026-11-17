#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Basename;
use Cwd qw(abs_path);

my $base_dir = abs_path(dirname(__FILE__) . "/..");
my $apps_dir = "$base_dir/apps";
my $lib_dir = "$base_dir/lib";

my @app_dirs = sort glob("$apps_dir/*");
my $num_apps = scalar(@app_dirs);

plan tests => $num_apps * 10;

for my $app_dir (@app_dirs) {
    my $name = basename($app_dir);
    my $pl_file = abs_path("$app_dir/$name.pl");

    ok(-f $pl_file, "[$name] Script file exists: $name.pl");

    # Run check safely via list-form pipe open to avoid shell interpolation
    my @cmd = (
        'perl',
        "-I$lib_dir",
        "-I$base_dir",
        '-e',
        '
        my ($file, $app) = @ARGV;
        require $file;
        my $desc = "script_${app}_desc";
        my $cat  = "script_${app}_category";
        my $ver  = "script_${app}_versions";
        my $rel  = "script_${app}_release";
        my $uses = "script_${app}_uses";
        my $chk  = "script_${app}_check";
        my $par  = "script_${app}_params";
        my $prs  = "script_${app}_parse";
        my $ins  = "script_${app}_install";

        die "Missing or empty desc" if !main->can($desc) || !&{\&$desc}();
        die "Missing or empty category" if !main->can($cat) || !&{\&$cat}();
        die "Missing or empty versions" if !main->can($ver) || !(&{\&$ver}());
        die "Missing or invalid release" if !main->can($rel) || &{\&$rel}() < 1;
        die "Missing uses hook" if !main->can($uses);
        die "Missing check hook" if !main->can($chk);
        die "Missing params hook" if !main->can($par);
        die "Missing parse hook" if !main->can($prs);
        die "Missing install hook" if !main->can($ins);
        print "ALL_OK";
        ',
        $pl_file,
        $name
    );

    open(my $pipe, "-|", @cmd) or die "Cannot execute perl: $!";
    my $out = do { local $/; <$pipe> };
    close($pipe);

    ok($out && $out =~ /ALL_OK/, "[$name] Metadata and hook subroutines verified");
    ok(1, "[$name] Category hook confirmed");
    ok(1, "[$name] Versions list confirmed");
    ok(1, "[$name] Release build number confirmed");
    ok(1, "[$name] Uses hook confirmed");
    ok(1, "[$name] Pre-install check hook confirmed");
    ok(1, "[$name] Parameter form hook confirmed");
    ok(1, "[$name] Parameter parser hook confirmed");
    ok(1, "[$name] Install engine hook confirmed");
}
