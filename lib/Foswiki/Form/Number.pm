# See bottom of file for license and copyright information
package Foswiki::Form::Number;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Plugins::NumberPlugin ();
use Foswiki::Form::Text ();
use Error qw(:try);
use Scalar::Util qw( looks_like_number );
our @ISA = ('Foswiki::Form::Text');

sub new {
    my $class = shift;
    my $this  = $class->SUPER::new(@_);

    $this->{_class} = 'foswikiNumberField';

    return $this;
}

sub finish {
  my $this = shift;

  $this->SUPER::finish();

  undef $this->{_formatter};
  undef $this->{_params};
}

sub param {
  my ($this, $key) = @_;

  unless (defined $this->{_params}) {
    my %params = Foswiki::Func::extractParameters($this->{value});
    $this->{_params} = \%params;
  }

  return (defined $key)?$this->{_params}{$key}:$this->{_params};
}

sub formatter {
  my ($this) = @_;

  unless (defined $this->{_formatter}) {
    $this->{_formatter} = Foswiki::Plugins::NumberPlugin::getCore()->decimalFormatter(%{$this->param()});
  }

  return $this->{_formatter};
}

sub getDefaultValue {
    my $this = shift;

    my $value =
      ( exists( $this->{default} ) ? $this->{default} : '' );
    $value = '' unless defined $value;

    return $value;
}

sub getDisplayValue {
  my ($this, $value) = @_;

  return $value unless looks_like_number($value);

  my $result;
  try {
    $result = $this->formatter->format($value);
    $result =~ s/([,.])/'&#'.ord($1).';'/ge; # encode the display value not to disturbe CALC otherwise
  } catch Error::Simple with {
    $result = shift;
    $result =~ s/ at \/.*$//;
    $result =~ s/^\s+|\s+$//g;
  };

  return "<span class='foswikiNumber foswikiHidden'>$value</span>".$result;
}

sub renderForDisplay {
  my ($this, $format, $value, $attrs) = @_;

  my $displayValue = $this->getDisplayValue($value);
  $format =~ s/\$value\(display\)/$displayValue/g;
  $format =~ s/\$value/$value/g;

  return $this->SUPER::renderForDisplay($format, $value, $attrs);
}

sub renderForEdit {
  my ($this, $topicObject, $value) = @_;

  return (
    '',
    CGI::textfield(
      -class => $this->cssClasses("foswikiInputField $this->{_class}"),
      -name => $this->{name},
      -size => $this->{size},
      -override => 1,
      -value => $value,
      -data_rule_pattern => '^[+\-]?\d+(\.\d+)?$',
    )
  );
}

1;
__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2017-2021 Foswiki Contributors. Foswiki Contributors
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

