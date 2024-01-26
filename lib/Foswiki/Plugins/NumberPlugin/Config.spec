# ---+ Extensions
# ---++ NumberPlugin
# This is the configuration used by the <b>NumberPlugin</b>.

# **SELECT none,FixerIO,OpenExchangeRates,CurrencyLayer LABEL="Exchange Rates Provider" **
# Select an online service that provides up-to-date exchange rates.
$Foswiki::cfg{NumberPlugin}{RatesProvider} = 'none';

# **STRING 50 LABEL="Currencies" DISPLAY_IF="{NumberPlugin}{RatesProvider}=='none'" CHECK="undefok emptyok"**
# List of known currencies to create a foswiki macro for.
$Foswiki::cfg{NumberPlugin}{Currencies} = 'EUR, USD';

# **STRING 50 DISPLAY_IF="{NumberPlugin}{RatesProvider}=='FixerIO'" LABEL="Fixer.io Url"**
# Api endpoint for the Fixer.io provider.
$Foswiki::cfg{NumberPlugin}{FixerIO}{Url} = ' http://data.fixer.io/api/latest';

# **STRING 50 DISPLAY_IF="{NumberPlugin}{RatesProvider}=='OpenExchangeRates'" LABEL="OpenExchangeRates Url"**
# Api endpoint for the Fixer.io provider.
$Foswiki::cfg{NumberPlugin}{OpenExchangeRates}{Url} = 'https://openexchangerates.org/api/latest.json';

# **STRING 50 DISPLAY_IF="{NumberPlugin}{RatesProvider}=='CurrencyLayer'" LABEL="CurrencyLayer Url"**
# Api endpoint for the CurrencyLayer provider.
$Foswiki::cfg{NumberPlugin}{CurrencyLayer}{Url} = 'https://apilayer.net/api/live';

# **PERL DISPLAY_IF="{NumberPlugin}{RatesProvider}=='FixerIO'" CHECK="undefok" LABEL="Fixer.io Parameter"**
# Extra api parameter for the Fixer.io provider.
$Foswiki::cfg{NumberPlugin}{FixerIO}{Params} = {
  'access_key' => '???'
};

# **PERL DISPLAY_IF="{NumberPlugin}{RatesProvider}=='CurrencyLayer'" CHECK="undefok" LABEL="CurrencyLayer Parameter"**
# Extra api parameter for the Fixer.io provider.
$Foswiki::cfg{NumberPlugin}{CurrencyLayer}{Params} = {
  'access_key' => '???'
};

# **PERL DISPLAY_IF="{NumberPlugin}{RatesProvider}=='OpenExchangeRates'" CHECK="undefok" LABEL="OpenExchangeRates Parameter"**
# Extra api parameter for the OpenExchangeRates provider. Note that you must register at
# https://openexchangerates.org/signup and provide an app_id here
$Foswiki::cfg{NumberPlugin}{OpenExchangeRates}{Params} = {
  'app_id' => '???'
};

# **NUMBER**
# Network timeout in seconds talking to the rates provider API.
$Foswiki::cfg{NumberPlugin}{Timeout} = 5;

1;
