# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# NumberPlugin is Copyright (C) 2017-2018 Michael Daum http://michaeldaumconsulting.com
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

use REST::Client ();
use Cache::FileCache ();
use URI ();
use HTTP::Response ();
use HTTP::Status ();
use JSON ();
our @ISA = qw( REST::Client );

#use Data::Dump qw(dump);

sub new {
  my $class = shift;

  my $this = $class->SUPER::new(@_);

  $this->{cacheExpire} = $Foswiki::cfg{NumberPlugin}{CacheExpire} || "1 d";
  $this->{provider} = $Foswiki::cfg{NumberPlugin}{RatesProvider} || 'https://api.fixer.io';
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

  unless (defined $this->{_exchange}) {
    my $uri = new URI($this->{apiUrl});
    $uri->query_form($this->{apiParams});

    my $data = $this->get($uri);

    if ($this->{provider} eq 'CurrencyLayer') {
      $this->_getExchangeFromCurrencyLayer($data);
    } else {
      $this->{_exchange} = $data;
    }

    # make sure the base is in
    $this->{_exchange}{rates}{$this->{_exchange}{base}} = 1
      if defined $this->{_exchange}{base}; 
  }

  return $this->{_exchange};
}

sub _getExchangeFromCurrencyLayer {
  my ($this, $data) = @_;

  $this->{_exchange} = ();
  $this->{_exchange}{base} = $data->{source};
  foreach my $key (keys %{$data->{quotes}}) {
    my $val = $data->{quotes}{$key};
    $key=~ s/^$this->{_exchange}{base}//;
    $this->{_exchange}{rates}{$key} = $val;
  }

  return $this->{_exchange};
}

sub cache {
  my $this = shift;

  unless ($this->{cache}) {
    $this->{cache} = Cache::FileCache->new({
        'cache_root' => Foswiki::Func::getWorkArea('NumberPlugin') . '/cache',
        'default_expires_in' => $this->{cacheExpire},
        'directory_umask' => 077,
      }
    );
  }

  return $this->{cache};
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
  $refresh = ($refresh =~ /^(on|exchangerates)$/) ? 1:0;

  my $content;
  $content = $this->cache->get($uri) unless $refresh;

  if (defined $content) {
    #print STDERR "... found in cache $uri\n";
  } else {
    #print STDERR " ... fetching $uri\n";

    $this->GET($uri);
    $content = $this->responseContent();

    ## cache only "200 OK" content
    if ($this->responseCode eq HTTP::Status::RC_OK) {
      $this->cache->set($uri->as_string, $content, $this->{cacheExpire});
    } else {
      $content = "{\"rates\": {}}"; # null result
    }
  }

  #print STDERR "content=$content\n";

  return $this->json->decode($content);
}

sub clearCache {
  my $this = shift;

  return $this->cache->clear(@_);
}

sub purgeCache {
  my $this = shift;

  return $this->cache->purge(@_);
}

1;

