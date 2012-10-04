# Cash

Money object for your application. Based on BigDecimal and ISO-4217 currencies.


## Features

Encapsulates an amount with its currency.

Backed by BigDecimal, so it can store arbitrary-precision values without rounding errors. Useful if you’re dealing with fractional cents.

Safe and strict. Fail fast approach let's you sleep like a baby.


## Compatibility

Tested on Ruby 1.9, 1.8, JRuby, and RBX: 

https://travis-ci.org/#!/pithyless/cash


## Credits

Huge thanks go out to:

  * The guys from money gem, helping rid the world of floating finances
  * The guys from big_money gem, helping to spread the word that BigDecimal is bigger and better
  * Luca Guidi for being awesome and giving up the cash gem name ;]
