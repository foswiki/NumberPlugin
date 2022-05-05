# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# NumberPlugin is Copyright (C) 2017-2022 Michael Daum http://michaeldaumconsulting.com
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

package Foswiki::Plugins::NumberPlugin::RatesClient;

use strict;
use warnings;

use Foswiki::Contrib::CacheContrib ();
use REST::Client ();
use URI ();
use HTTP::Response ();
use HTTP::Status ();
use JSON ();
our @ISA = qw( REST::Client );

use constant TRACE => 0;
our %EXCHANGE; # in-memory cache

sub new {
  my $class = shift;

  my $this = $class->SUPER::new(@_);

  $this->{provider} = $Foswiki::cfg{NumberPlugin}{RatesProvider} || 'none';
  $this->{apiUrl} = $Foswiki::cfg{NumberPlugin}{$this->{provider}}{Url} || '';
  $this->{apiParams} = $Foswiki::cfg{NumberPlugin}{$this->{provider}}{Params} || {};
  $this->{timeout} = $Foswiki::cfg{NumberPlugin}{Timeout};
  $this->{timeout} = 5 unless defined $this->{timeout};

  $this->setTimeout($this->{timeout});

  if ($Foswiki::cfg{PROXY}{HOST}) {
    $this->getUseragent->proxy(['http','https'], $Foswiki::cfg{PROXY}{HOST});
  }

  return $this;
}

sub getExchange {
  my $this = shift;

  unless (%EXCHANGE) {

    if ($this->{provider} eq 'none') {
      foreach my $code (split(/\s*,\s*/, $Foswiki::cfg{NumberPlugin}{Currencies} || '')) {
        $EXCHANGE{base} //= $code;
        $EXCHANGE{rates}{$code} = 1;
      }
    } else {
      my $uri = new URI($this->{apiUrl});
      $uri->query_form($this->{apiParams});

      my $data = $this->get($uri);

      if ($this->{provider} eq 'CurrencyLayer') {
        $this->_getExchangeFromCurrencyLayer($data);
      } else {
        %EXCHANGE = %$data;
      }
    }

    # make sure the base is in
    $EXCHANGE{rates}{$EXCHANGE{base}} = 1
      if defined $EXCHANGE{base}; 
  }

  return \%EXCHANGE;
}

sub _getExchangeFromCurrencyLayer {
  my ($this, $data) = @_;

  %EXCHANGE = ();
  $EXCHANGE{base} = $data->{source};
  foreach my $key (keys %{$data->{quotes}}) {
    my $val = $data->{quotes}{$key};
    $key=~ s/^$EXCHANGE{base}//;
    $EXCHANGE{rates}{$key} = $val;
  }

  return \%EXCHANGE;
}

sub json {
  my $this = shift;

  unless (defined $this->{_json}) {
    $this->{_json} = JSON->new->allow_nonref;
  }

  return $this->{_json};
}

sub get {
  my ($this, $uri) = @_;

  my $cgiObj = Foswiki::Func::getRequestObject();
  my $refresh = $cgiObj->param("refresh") || '';
  $refresh = ($refresh =~ /^(exchangerates|on)$/) ? 1:0;

  _writeDebug("refreshing cache") if $refresh;

  my $cache = Foswiki::Contrib::CacheContrib::getCache("NumberPlugin");
  my $content;
  my $data;
  my $key = $uri->as_string;
  $content = $cache->get($key) unless $refresh;

  if (defined $content) {
    _writeDebug("found rates in cache $uri");
    $data = $this->json->decode($content);
  } else {
    _writeDebug("fetching rates from $uri");

    $this->GET($uri);
    $content = $this->responseContent();

    ## cache only "200 OK" content
    if ($this->responseCode eq HTTP::Status::RC_OK) {
      $data = $this->json->decode($content);
      if ($data->{success}) {
        $cache->set($key, $content);
      } else {
        _writeError($data->{error}{info});
        $data = undef;
      }
    }
  }

  #print STDERR "content=$content\n";

  $data //= {
    rates => {},
  }; 

  return $data;
}

sub _writeDebug {
  return unless TRACE;
  print STDERR "RatesClient - $_[0]\n";
}

sub _writeError {
  print STDERR "RatesClient - ERROR: $_[0]\n";
}

1;

