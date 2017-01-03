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

package Foswiki::Plugins::NumberPlugin;

use strict;
use warnings;

use Foswiki::Func ();

our $VERSION = '1.00';
our $RELEASE = '03 Jan 2017';
our $SHORTDESCRIPTION = 'Localized Number Formatter';
our $NO_PREFS_IN_TOPIC = 1;
our $core;

sub initPlugin {

  Foswiki::Func::registerTagHandler('NUMBER', sub { return getCore()->handleNUMBER(@_); });

  if ($Foswiki::cfg{NumberPlugin}{Currencies}) {
    foreach my $code (split(/\s*,\s*/, $Foswiki::cfg{NumberPlugin}{Currencies})) {
      Foswiki::Func::registerTagHandler($code, sub {
        my ($session, $params) = @_;
        $params->{currency_code} = $code;
        return getCore()->handleCurrency($params); 
      });
    }
  }

  return 1;
}

sub getCore {
  unless (defined $core) {
    require Foswiki::Plugins::NumberPlugin::Core;
    $core = Foswiki::Plugins::NumberPlugin::Core->new();
  }
  return $core;
}


sub finishPlugin {

  $core->finish if defined $core;
  undef $core;
}

1;