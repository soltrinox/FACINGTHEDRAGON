#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use YAML::XS qw(LoadFile);
use Path::Tiny;

my $root = path($FindBin::Bin)->parent->parent->stringify;
my $manifest = LoadFile("$FindBin::Bin/manifest.yaml");

my %map;
for my $f (@{ $manifest->{files} }) {
    next unless $f->{legacy};
    $map{ $f->{legacy} } = $f->{new_file};
}

my @skip = qw(README.md EDITORIAL_REVIEW.md Parables.Shortened.md PRODUCTION_READY_EXECUTION_REPORT.md);
for my $md (grep { $_->basename =~ /\.md$/ } path($root)->children) {
    next if grep { $_ eq $md->basename } @skip;
    my $text = $md->slurp_utf8;
    my $orig = $text;
    for my $legacy (sort { length($b) <=> length($a) } keys %map) {
        my $new = $map{$legacy};
        $text =~ s/\]\(\Q$legacy\E(\#[^)]*)?\)/]($new$1)/g;
        $text =~ s/\]\(\Q$legacy\E\)/]($new)/g;
    }
    $md->spew_utf8($text) if $text ne $orig;
    print "fix-links: updated ", $md->basename, "\n";
}
print "fix-links.pl: done\n";
