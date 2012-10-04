#encoding: UTF-8

require 'spec_helper'

describe Cash do

  describe '#initialize' do

    let(:currency) { Cash::Currency::USD }
    let(:big_one) { BigDecimal.new('1.0') }
    let(:one) { '1.0' }

    context 'amount' do
      it 'initializes with big decimal' do
        Cash.new(big_one, currency).amount.should eq(big_one)
      end

      it 'initializes with string' do
        Cash.new(one, currency).amount.should eq(big_one)
      end

      it 'initializes with integer' do
        Cash.new(1, currency).amount.should eq(big_one)
      end

      it 'fails with float' do
        ->{ Cash.new(Float(one), currency) }.should raise_error(ArgumentError)
      end

      it 'fails with nil object' do
        ->{ Cash.new(nil, currency) }.should raise_error(ArgumentError)
      end

      it 'fails with other object' do
        ->{ Cash.new(Object.new, currency) }.should raise_error(ArgumentError)
      end

      it 'fails with invalid string' do
        ->{ Cash.new('silly', currency) }.should raise_error(ArgumentError)
      end
    end

    context 'currency' do
      it 'initializes with string' do
        Cash.new(1, 'usd').currency.should == Cash::Currency::USD
      end

      it 'initializes with symbol' do
        Cash.new(1, :USD).currency.should == Cash::Currency::USD
      end

      it 'initializes with currency' do
        currency = Cash::Currency.find('usd')
        Cash.new(1, currency).currency.should == Cash::Currency::USD
      end

      it 'fails with missing currency' do
        ->{ Cash.new(1, 'zzz') }.should raise_error(ArgumentError)
      end

      it 'fails with nil object' do
        ->{ Cash.new(1, nil) }.should raise_error(ArgumentError)
      end

      it 'fails with other object' do
        ->{ Cash.new(1, Object.new) }.should raise_error(ArgumentError)
      end
    end

  end

  describe '#to_s' do
    it 'displays Euro' do
       Cash.new('100.3', :eur).to_s.should == '€100.30'
    end

    it 'displays Dollar' do
       Cash.new('9999', :usd).to_s.should == '$9999.00'
    end

    it 'displays other currencies' do
       Cash.new('.123', :pln).to_s.should == '0.12 PLN'
    end
  end

  describe '#inspect' do
    it 'displays value and currency' do
       Cash.new('100.3', :eur).inspect.should == '<Cash 100.30 EUR>'
    end
  end

end

