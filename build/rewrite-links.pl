#!/usr/bin/env perl
use strict;
use warnings;

while (<>) {
  # Slug-based manuscript links (NN-name.md)
  s/\]\(([0-9][0-9a-z-]*)\.md#([^)]+)\)/](#$2)/g;
  s/\]\(([0-9][0-9a-z-]*)\.md\)/](#$1)/g;
  # Legacy numeric links
  s/\]\((\d+)\.md#([^)]+)\)/](#$2)/g;
  s/\]\((\d+)\.md\)/](#$1)/g;
  s/\]\(0\.md\)/](#00-title)/g;
  s/\]\(000\.md\)/](#00-toc)/g;
  print;
}
