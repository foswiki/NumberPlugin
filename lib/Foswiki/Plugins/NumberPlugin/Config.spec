# ---+ Extensions
# ---++ NumberPlugin
# This is the configuration used by the <b>NumberPlugin</b>.

# **STRING 50**
# list of currency shortcuts for which a macro are created. E.g. by default an %EUR and %USD macro
# is created which is equivalent to <code>%NUMBER{"%DEFAULT{default="0"}%" type="currency" currency_code="EUR"}%</code>
# and <code>%NUMBER{"%DEFAULT{default="0"}%" type="currency" currency_code="USD"}%</code>.
$Foswiki::cfg{NumberPlugin}{Currencies} = "EUR, USD";
1;
