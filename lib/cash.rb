# encoding: UTF-8

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

  def to_s
    Format.display(self)
  end

  def inspect
    val = '%.2f' % amount
    "<Cash #{val} #{currency.code}>"
  end


  module Format
    CURRENCIES = {
      'EUR' => '€',
      'USD' => '$'
    }.freeze

    def self.display(cash)
      amount = '%.2f' % cash.amount.round(2)
      currency_code = cash.currency.code

      if sym = CURRENCIES[currency_code]
        "#{sym}#{amount}"
      else
        "#{amount} #{currency_code}"
      end
    end
  end

end
