# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# NumberPlugin is Copyright (C) 2017-2025 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Form::Percent;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Form::Number ();
our @ISA = ('Foswiki::Form::Number');

sub new {
    my $class = shift;
    my $this  = $class->SUPER::new(@_);

    $this->{_class} = 'foswikiPercentField';

    return $this;
}

sub formatter {
  my ($this) = @_;

  unless (defined $this->{_formatter}) {
    my $fraction = $this->param("fraction") // 2;
    my %params = (
      minimum_fraction_digits => $fraction,
      %{$this->param()}  
    );

    $this->{_formatter} = Foswiki::Plugins::NumberPlugin::getCore()->percentFormatter(%params);
  }

  return $this->{_formatter};
}

1;
