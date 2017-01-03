# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
#
# NumberPlugin is Copyright (C) 2017 Michael Daum http://michaeldaumconsulting.com
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

package Foswiki::Plugins::NumberPlugin::Core;

use strict;
use warnings;
use CLDR::Number ();
use Error qw(:try);

use Foswiki::Func ();
use Foswiki::Plugins ();

use constant TRACE => 0; # toggle me


sub new {
  my $class = shift;

  my $this = bless({
    @_
  }, $class);


  return $this;
}

sub finish {
  my $this = shift;

}

sub cldr {
  my ($this, $locale) = @_;

  unless (defined $locale) {
    my $session = $Foswiki::Plugins::SESSION;
    $locale = $session->i18n->language();
  }
  return CLDR::Number->new(locale => $locale);
}

sub decimalFormatter {
  my ($this, %params) = @_;

  my $locale = delete $params{locale};

  return $this->cldr($locale)->decimal_formatter(%params);
}

sub currencyFormatter {
  my ($this, %params) = @_;

  my $locale = delete $params{locale};

  return $this->cldr($locale)->currency_formatter(%params);
}

sub percentFormatter {
  my ($this, %params) = @_;

  my $locale = delete $params{locale};

  return $this->cldr($locale)->percent_formatter(%params);
}

sub handleNUMBER {
  my ($this, $session, $params, $topic, $web) = @_;

  _writeDebug("called handleNUMBER()");
  my $theNumber = $params->{_DEFAULT} || 0;
  my $theType = $params->{type} || 'decimal';

  my $formatter;
  my $result;
 
  try {
    if ($theType eq 'decimal') {
      $formatter = $this->decimalFormatter(%$params);
    } elsif ($theType eq 'currency') {
      $formatter = $this->currencyFormatter(%$params);
    } elsif ($theType eq 'percent') {
      $formatter = $this->percentFormatter(%$params);
    } else {
      throw Error::Simple("unknown number type");
    }
    throw Error::Simple("can't create formatter") unless defined $formatter;
    $result = $formatter->format($theNumber);

  } catch Error::Simple with {
    $result = shift;
    $result =~ s/ at \/.*$//;
    $result =~ s/^\s+|\s+$//g;
    $result = _inlineError($result);
  };

  return $result;
}

sub handleCurrency {
  my ($this, $params) = @_;

  my $theNumber = $params->{_DEFAULT} || 0;
  my $formatter;
  my $result;

  try {
    $formatter = $this->currencyFormatter(%$params);
    throw Error::Simple("can't create formatter") unless defined $formatter;
    $result = $formatter->format($theNumber);
  } catch Error::Simple with {
    $result = shift;
    $result =~ s/ at \/.*$//;
    $result =~ s/^\s+|\s+$//g;
    $result = _inlineError($result);
  };

  return $result;
}

sub _inlineError {
  return "<div class='foswikiAlert'>$_[0]</div>";
}

sub _writeDebug {
  return unless TRACE;
  #Foswiki::Func::writeDebug("NumberPlugin::Core - $_[0]");
  print STDERR "NumberPlugin::Core - $_[0]\n";
}

1;
