# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# NumberPlugin is Copyright (C) 2017-2024 Michael Daum http://michaeldaumconsulting.com
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

package Foswiki::Form::Currency;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Form::Number ();
our @ISA = ('Foswiki::Form::Number');

sub new {
    my $class = shift;
    my $this  = $class->SUPER::new(@_);

    $this->{_class} = 'foswikiCurrencyField';

    return $this;
}

sub formatter {
  my ($this) = @_;

  # TODO: provide currecny_code in another formfield

  unless (defined $this->{_formatter}) {
    $this->{_formatter} = Foswiki::Plugins::NumberPlugin::getCore()->currencyFormatter(%{$this->param()});
  }

  return $this->{_formatter};
}

1;
