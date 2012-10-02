require 'set'
require 'cash/equalable'

class Cash
  class Currency
    include Equalable

    attr_reader :code, :offset, :name

    def equality_state
      [code, offset, name]
    end
    protected :equality_state

    def initialize(code, offset, name)
      @code, @offset, @name = code.to_s.upcase, Integer(offset), name
    end

    class << self

      def find(currency)
        currency = currency.to_s.upcase
        all.find{ |c| c.code == currency }
      end

      def all
        @all ||= Set.new
      end

      def register(*args)
        self.all << currency = new(*args).freeze
        currency
      end

    end

  end
end
