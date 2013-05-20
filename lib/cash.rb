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

  def StrictDecimal(arg)
    case arg
    when BigDecimal
      arg
    when Float
      fail ArgumentError, "innacurate float for StrictDecimal(): #{arg.inspect}"
    when Integer
      BigDecimal(arg.to_s)
    when String
      Float(arg)
      BigDecimal(arg)
    else
      fail TypeError
    end
  rescue TypeError
    fail ArgumentError, "invalid value for StrictDecimal(): #{arg.inspect}"
  end

  def pretty_print
    Format.display(self)
  end

  def to_s
    "#{amount_string} #{currency.code}"
  end

  def inspect
    "<Cash #{to_s}>"
  end

  def to_h
    {
      :amount => amount_string,
      :currency => currency.code
    }
  end

  def amount_string
   "%.#{currency.offset}f" % amount.round(currency.offset)
  end

  def round
    Cash.new(amount.round, currency)
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

  def *(factor)
    factor = StrictDecimal(factor)
    Cash.new(amount * factor, currency)
  rescue ArgumentError
    raise ArgumentError, "cannot multiply #{self.inspect} by #{factor}"
  end

  def /(factor)
    factor = StrictDecimal(factor)
    Cash.new(amount / factor, currency)
  rescue ArgumentError
    raise ArgumentError, "cannot divide #{self.inspect} by #{factor}"
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
