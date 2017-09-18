# ---+ Extensions
# ---++ NumberPlugin
# This is the configuration used by the <b>NumberPlugin</b>.

# **SELECT FixerIO,OpenExchangeRates LABEL="Exchange Rates Provider" **
# Select an online service that provides up-to-date exchange rates.
$Foswiki::cfg{NumberPlugin}{RatesProvider} = 'FixerIO';

# **STRING 50 DISPLAY_IF="{NumberPlugin}{RatesProvider}=='FixerIO'" LABEL="Fixer.io Url"**
# Api endpoint for the Fixer.io provider.
$Foswiki::cfg{NumberPlugin}{FixerIO}{Url} = 'https://api.fixer.io/latest';

# **PERL DISPLAY_IF="{NumberPlugin}{RatesProvider}=='FixerIO'" CHECK="undefok" LABEL="Fixer.io Parameter"**
# Extra api parameter for the Fixer.io provider.
$Foswiki::cfg{NumberPlugin}{FixerIO}{Params} = {};

# **STRING 50 DISPLAY_IF="{NumberPlugin}{RatesProvider}=='OpenExchangeRates'" LABEL="OpenExchangeRates Url"**
# Api endpoint for the Fixer.io provider.
$Foswiki::cfg{NumberPlugin}{OpenExchangeRates}{Url} = 'https://openexchangerates.org/api/latest.json';

# **PERL DISPLAY_IF="{NumberPlugin}{OpenExchangeRates}=='OpenExchangeRates'" LABEL="OpenExchangeRates Parameter"**
# Extra api parameter for the OpenExchangeRates provider. Note that you must register at
# https://openexchangerates.org/signup and provide an app_id here
$Foswiki::cfg{NumberPlugin}{OpenExchangeRates}{Params} = {
  'app_id' => '???'
};

# **STRING LABEL="Cache Expiration"**
# Expiration time when fetching and caching exchange rates from the provider.
$Foswiki::cfg{NumberPlugin}{CacheExpire} = '1 d';

1;
