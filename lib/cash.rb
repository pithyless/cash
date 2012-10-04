require 'bigdecimal'

require "cash/currency"
require "cash/currency/iso4217"

class Cash
  def initialize(amount, currency)
    @amount, @currency = StrictDecimal(amount), Currency.find!(currency)
  end

  attr_reader :amount, :currency

  def StrictDecimal(value)
    if value.is_a?(Float)
      fail ArgumentError, "innacurate float for StrictDecimal(): #{amount}"
    end

    Float(value)
    BigDecimal(value)
  rescue TypeError
    fail ArgumentError, "invalid value for StrictDecimal(): #{amount}"
  end

end
