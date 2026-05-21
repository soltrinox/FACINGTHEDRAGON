#!/usr/bin/env perl
use strict;
use warnings;

while (<>) {
  s/\]\((\d+)\.md#([^)]+)\)/](#$2)/g;
  s/\]\((\d+)\.md\)/"\](#".lc($1).")"/ge;
  s/\]\(0\.md\)/](#0)/g;
  s/\]\(#L(\d+)\)/"\](#".lc($1).")"/ge;
  print;
}
