#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use YAML::XS qw(LoadFile);
use Path::Tiny;

my $root = path($FindBin::Bin)->parent->parent->stringify;
my $map = LoadFile("$FindBin::Bin/section-ref-map.yaml");

my @skip = qw(README.md EDITORIAL_REVIEW.md Parables.Shortened.md PRODUCTION_READY_EXECUTION_REPORT.md);

sub apply_rules {
    my ($text, $rules) = @_;
    for my $rule (@$rules) {
        my $pat = $rule->{pattern};
        my $rep = $rule->{replace};
        $text =~ s/$pat/$rep/g;
    }
    return $text;
}

for my $md (grep { $_->basename =~ /\.md$/ } path($root)->children) {
    next if grep { $_ eq $md->basename } @skip;
    my $text = $md->slurp_utf8;
    my $orig = $text;

    $text = apply_rules($text, $map->{global_replacements});
    if ($md->basename eq '49-self-destruction-to-compassion.md') {
        for my $h (@{ $map->{worksheet_headings} }) {
            $text =~ s/\Q$h->{old}\E/$h->{new}/g;
        }
        $text = apply_rules($text, $map->{worksheet_replacements});
    }

    if ($md->basename eq '55-glossary.md') {
        $text = apply_rules($text, $map->{section_7_replacements});
    }

    $md->spew_utf8($text) if $text ne $orig;
    print "fix-section-refs: ", $md->basename, "\n";
}
print "fix-section-refs.pl: done\n";
