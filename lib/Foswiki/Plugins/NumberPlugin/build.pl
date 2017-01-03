#!/usr/bin/env perl 

use strict;
use warnings;;

BEGIN { 
  unshift @INC, split( /:/, $ENV{FOSWIKI_LIBS} ); 
}

use Foswiki::Contrib::Build ();

my $build = new Foswiki::Contrib::Build('NumberPlugin');
$build->build($build->{target});

1;
