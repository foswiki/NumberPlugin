# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
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

package Foswiki::Plugins::NumberPlugin::Core;

use strict;
use warnings;
use CLDR::Number ();
use Error qw(:try);
use Scalar::Util qw( looks_like_number );

use Foswiki::Func ();
use Foswiki::Plugins ();

use constant TRACE => 0; # toggle me
our @BYTE_SUFFIX = ('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB');

sub new {
  my $class = shift;

  my $this = bless({
    @_
  }, $class);

  $this->{_client} = undef;


  return $this;
}

sub finish {
  my $this = shift;

  undef $this->{_client};
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

sub formatBytes {
  my ($this, $value, $params) = @_;

  return $value unless looks_like_number($value);
  my $max = $params->{"max"} || '';

  my $magnitude = 0;
  my $suffix;

  while ($magnitude < scalar(@BYTE_SUFFIX)) {
    $suffix = $BYTE_SUFFIX[$magnitude];
    last if $value < 1024;
    last if $max eq $suffix;
    $value = $value/1024;
    $magnitude++;
  };

  my $prec = $params->{"prec"} // 2;

  my $result = sprintf("%.0".$prec."f", $value);
  $result =~ s/\.00$//;
  $result .= ' '. $suffix;

  return $result;
}

sub handleNUMBER {
  my ($this, $session, $params, $topic, $web) = @_;

  _writeDebug("called handleNUMBER()");
  my $theNumber = $params->{_DEFAULT} || 0;
  my $theType = $params->{type} || 'decimal';

  my $formatter;
  my $result;
 
  try {
    if ($theType eq 'bytes') {
      $result = $this->formatBytes($theNumber, $params);
    } elsif ($theType eq 'decimal' or $theType eq 'number') {
      $formatter = $this->decimalFormatter(%$params);
      throw Error::Simple("can't create formatter") unless defined $formatter;
    } elsif ($theType eq 'currency') {

      my $targetCurrency = $params->{currency_code} // $params->{currency} // $params->{to}; 
      $params->{currency_code} = $targetCurrency if defined $targetCurrency;

      $formatter = $this->currencyFormatter(%$params);
      throw Error::Simple("can't create formatter") unless defined $formatter;

      my $sourceCurrency =  $params->{from};
      if (defined $sourceCurrency && $sourceCurrency ne $targetCurrency) {
        $theNumber = $this->convertCurrency($sourceCurrency, $targetCurrency, $theNumber);
      }

    } elsif ($theType eq 'percent') {
      $formatter = $this->percentFormatter(%$params);
      throw Error::Simple("can't create formatter") unless defined $formatter;
    } else {
      throw Error::Simple("unknown number type");
    }
    $result = $formatter->format($theNumber) if defined $formatter;
    $result = _cloakNumber($theNumber, $result);

  } catch Error::Simple with {
    $result = shift;
    $result =~ s/ at \/.*$//;
    $result =~ s/^\s+|\s+$//g;
    $result = _inlineError($result);
  };

  return $result;
}

sub handleCURRENCIES {
  my ($this, $session, $params, $topic, $web) = @_;

  my $header = $params->{header} // "";
  my $footer = $params->{footer} // "";
  my $separator = $params->{separator} // ", ";
  my $format = $params->{format} // '$code';

  my $include = $params->{include};
  my $exclude = $params->{exclude};
  my $baseCurrency = $params->{base} // $this->client->getExchange->{base};
  my $total = $params->{_DEFAULT} // $params->{total} // 1;

  my @results =();
  foreach my $code (sort $this->getCurrencies) {
    next if defined $include && ! $code =~ /$include/;
    next if defined $exclude && $code =~ /$exclude/;
    my $line = $format;
    my $rate = $this->convertCurrency($baseCurrency, $code, 1);
    $line =~ s/\$code\b/$code/g;
    $line =~ s/\$rate\b/$rate/g;
    $line =~ s/\$total\b/$total*$rate/ge;
    push @results, $line;
  }

  return "" unless @results;

  return Foswiki::Func::decodeFormatTokens($header.join($separator, @results).$footer);
}

sub handleCurrency {
  my ($this, $params) = @_;

  my $theNumber = $params->{_DEFAULT} || 0;
  my $formatter;
  my $result;
  my $error;

  try {
    my $targetCurrency = $params->{currency_code} // $params->{currency} // $params->{to}; 
    $params->{currency_code} = $targetCurrency if defined $targetCurrency;

    $formatter = $this->currencyFormatter(%$params);
    throw Error::Simple("can't create formatter") unless defined $formatter;

    my $sourceCurrency =  $params->{from};
    if (defined $sourceCurrency && $sourceCurrency ne $targetCurrency) {
      $theNumber = $this->convertCurrency($sourceCurrency, $targetCurrency, $theNumber);
    }

    $result = $formatter->format($theNumber);
  } catch Error::Simple with {
    $error = shift;
    $error =~ s/ at \/.*$//;
    $error =~ s/^\s+|\s+$//g;
    $error = _inlineError($error);
  };
  return $error if defined $error;

  $result = _cloakNumber($theNumber, $result) if Foswiki::Func::isTrue($params->{cloak}, 1);

  return $result;
}

# make it work with SpreadSheetPlugin
sub _cloakNumber {
  my ($number, $format) = @_;

  # (1) replace commas with html entity to prevent SSP splitting up groups into integers
  $format =~ s/,/&#44;/; 

  # (2) sneak in the original value in a hidden span
  # unfortunately this doesn't work: 
  # return "<span class='currency' data-value='$number'>$format</span>"; 
  return "<span style='display:none'>$number</span>$format"; 
}

sub _inlineError {
  return "<div class='foswikiAlert'>$_[0]</div>";
}

sub _writeDebug {
  return unless TRACE;
  #Foswiki::Func::writeDebug("NumberPlugin::Core - $_[0]");
  print STDERR "NumberPlugin::Core - $_[0]\n";
}

sub convertCurrency {
  my ($this, $from, $to, $val) = @_;

  return $val * $this->getRate($from, $to);
}

sub getCurrencies {
  my $this = shift;

  return keys %{$this->client->getExchange->{rates}};
}

sub getRate {
  my ($this, $from, $to) = @_;

  throw Error::Simple("unsupported rate '$from'") 
    unless defined $this->client->getExchange->{rates}{$from};

  throw Error::Simple("unsupported rate '$to'") 
    unless defined $this->client->getExchange->{rates}{$to};

  return $this->client->getExchange->{rates}{$to} / $this->client->getExchange->{rates}{$from};
}

sub client {
  my ($this, $client) = @_;

  if (defined $client) {
    $this->{_client} = $client;
  } else {
    unless (defined $this->{_client}) {
      require Foswiki::Plugins::NumberPlugin::RatesClient;
      $this->{_client} = Foswiki::Plugins::NumberPlugin::RatesClient->new();
    }
  }

  return $this->{_client};
}

1;
