# See bottom of file for license and copyright information
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
__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2017-2018 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.

