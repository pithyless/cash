# encoding: UTF-8

require 'bigdecimal'

require "cash/currency"
require "cash/currency/iso4217"

class Cash
  include Comparable
  include Equalable

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
    "<Cash #{amount_string} #{currency.code}>"
  end

  def amount_string
   "%.#{currency.offset}f" % amount.round(currency.offset)
  end

  def <=>(o)
    check_type(o, :compare)
    amount <=> o.amount
  end

  def +(o)
    check_type(o, :add)
    Cash.new(amount + o.amount, currency)
  end

  def -(o)
    check_type(o, :subtract)
    Cash.new(amount - o.amount, currency)
  end

  protected

  def equality_state
    [amount, currency]
  end

  def check_type(o, method)
    unless o.instance_of?(self.class) && o.currency == currency
      raise TypeError, "cannot #{method} #{self.inspect} to #{o.inspect}"
    end
  end


  module Format
    CURRENCIES = {
      'EUR' => '€',
      'USD' => '$'
    }.freeze

    def self.display(cash)
      amount = cash.amount_string
      currency_code = cash.currency.code

      if sym = CURRENCIES[currency_code]
        "#{sym}#{amount}"
      else
        "#{amount} #{currency_code}"
      end
    end
  end

end
