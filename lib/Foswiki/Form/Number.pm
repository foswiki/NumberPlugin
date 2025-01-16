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

package Foswiki::Form::Number;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Render ();
use Foswiki::Plugins::JQueryPlugin ();
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
  my ($this, $key, $val) = @_;

  unless (defined $this->{_params}) {
    my %params = Foswiki::Func::extractParameters($this->{value});
    $this->{_params} = \%params;
  }

  if (defined $key && defined $val) {
    $this->{_params}{$key} = $val;
    return $val;
  }

  return (defined $key) ? $this->{_params}{$key} : $this->{_params};
}

sub formatter {
  my ($this) = @_;

  unless (defined $this->{_formatter}) {
    my $fraction = $this->param("fraction") // 2;
    my %params = (
      minimum_fraction_digits => $fraction,
      %{$this->param()}  
    );
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
  my ($this, $meta, $value) = @_;

  my $placeholder = $this->param("placeholder") // $this->{_placehoder};
  my $fraction = $this->param("fraction") // 2;
  Foswiki::Plugins::JQueryPlugin::createPlugin("imask");

  my $params = {
    "type" => "text",
    "class" => $this->cssClasses("foswikiInputField imask $this->{_class}"),
    "name" => $this->{name},
    "size" => $this->{size},
    "override" => 1,
    "value" => $value,
    "data-type" => "number",
  };

  $params->{"data-scale"} = $fraction;
  $params->{"placeholder"} = $placeholder if defined $placeholder && $placeholder ne "";

  return (
    '',
    Foswiki::Render::html('input', $params)
  );
}

1;
