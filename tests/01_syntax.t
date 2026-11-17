#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Basename;

my $base_dir = dirname(__FILE__) . "/..";
my $lib_dir = "$base_dir/lib";
my $apps_dir = "$base_dir/apps";

my @libs = glob("$lib_dir/*.pl");
my @apps = glob("$apps_dir/*/*.pl");

my $total_files = scalar(@libs) + scalar(@apps);
plan tests => $total_files;

for my $lib (@libs) {
    my $cmd = "perl -cw -I" . quotemeta($lib_dir) . " " . quotemeta($lib) . " 2>&1";
    my $out = `$cmd`;
    my $rc = $? >> 8;
    ok($rc == 0 && $out =~ /syntax OK/, "Library syntax: " . basename($lib));
}

for my $app (@apps) {
    my $cmd = "perl -cw -I" . quotemeta($lib_dir) . " " . quotemeta($app) . " 2>&1";
    my $out = `$cmd`;
    my $rc = $? >> 8;
    ok($rc == 0 && $out =~ /syntax OK/, "App script syntax: " . basename($app));
}
