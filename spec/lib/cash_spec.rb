#encoding: UTF-8

require 'spec_helper'

describe Cash do

  describe '#initialize' do

    let(:currency) { Cash::Currency::USD }
    let(:big_one) { BigDecimal('1.0') }
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
        expect{ Cash.new(Float(one), currency) }.to raise_error(ArgumentError)
      end

      it 'fails with nil object' do
        expect{ Cash.new(nil, currency) }.to raise_error(ArgumentError)
      end

      it 'fails with other object' do
        expect{ Cash.new(Object.new, currency) }.to raise_error(ArgumentError)
      end

      it 'fails with invalid string' do
        expect{ Cash.new('silly', currency) }.to raise_error(ArgumentError)
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
        expect{ Cash.new(1, 'zzz') }.to raise_error(ArgumentError)
      end

      it 'fails with nil object' do
        expect{ Cash.new(1, nil) }.to raise_error(ArgumentError)
      end

      it 'fails with other object' do
        expect{ Cash.new(1, Object.new) }.to raise_error(ArgumentError)
      end
    end

  end

  describe '#to_s' do
    it 'displays amount and currency' do
      Cash.new('100.3', :eur).to_s.should == '100.30 EUR'
      Cash.new('9999', :usd).to_s.should == '9999.00 USD'
      Cash.new('.123', :pln).to_s.should == '0.12 PLN'
    end

    it 'displays correct offset' do
      Cash.new('123.4567', :jpy).to_s.should == '123 JPY'
      Cash.new('123.4567', :twd).to_s.should == '123.5 TWD'
      Cash.new('123.4567', :pln).to_s.should == '123.46 PLN'
      Cash.new('123.4567', :bhd).to_s.should == '123.457 BHD'
    end
  end

  describe '#pretty_print' do
    it 'displays Euro' do
      Cash.new('100.3', :eur).pretty_print.should == '€100.30'
    end

    it 'displays Dollar' do
      Cash.new('9999', :usd).pretty_print.should == '$9999.00'
    end

    it 'displays other currencies' do
      Cash.new('.123', :pln).pretty_print.should == '0.12 PLN'
    end

    it 'displays correct offset' do
      Cash.new('123.4567', :jpy).pretty_print.should == '123 JPY'
      Cash.new('123.4567', :twd).pretty_print.should == '123.5 TWD'
      Cash.new('123.4567', :pln).pretty_print.should == '123.46 PLN'
      Cash.new('123.4567', :bhd).pretty_print.should == '123.457 BHD'
    end
  end

  describe '#inspect' do
    it 'displays value and currency' do
       Cash.new('100.3', :eur).inspect.should == '<Cash 100.30 EUR>'
    end
  end

  describe '#to_h' do
    it 'returns serialized hash' do
       Cash.new('100.3', :eur).to_h.should == {
         :amount => '100.30',
         :currency => 'EUR'
       }
    end
  end

  context 'comparable' do
    describe '#==' do
      it { Cash.new(1, :usd).should == Cash.new(1, :usd) }
      it { Cash.new(2, :usd).should_not == Cash.new(1, :usd) }
      it { Cash.new(1, :pln).should_not == Cash.new(1, :usd) }
    end

    describe '#<=>' do
      it { (Cash.new(1, :usd) <=> Cash.new(2, :usd)).should == -1 }
      it { (Cash.new(2, :usd) <=> Cash.new(2, :usd)).should == 0 }
      it { (Cash.new(3, :usd) <=> Cash.new(2, :usd)).should == 1 }

      it 'fails for different currencies' do
        expect{ Cash.new(1, :pln) <=> Cash.new(1, :usd) }.to raise_error(TypeError)
      end

      it 'fails for non-cash' do
        expect{ Cash.new(1, :pln) <=> 1 }.to raise_error(TypeError)
      end
    end

    it { (Cash.new(1, :usd) < Cash.new(2, :usd)).should be_true }
    it { (Cash.new(3, :usd) >= Cash.new(3, :usd)).should be_true }
    it { (Cash.new(3, :usd) == Cash.new(3, :usd)).should be_true }
    it { (Cash.new(3, :pln) != Cash.new(3, :usd)).should be_true }
    it { (Cash.new('1.234', :usd) != Cash.new('1.23', :usd)).should be_true }

    it 'fails for different currencies' do
      expect{ Cash.new(1, :usd) < Cash.new(1, :pln) }.to raise_error(TypeError)
    end
  end

  context 'arithmetic' do
    let(:one_usd) { Cash.new(1, :usd) }
    let(:two_usd) { Cash.new(2, :usd) }
    let(:three_usd) { Cash.new(3, :usd) }
    let(:two_pln) { Cash.new(2, :pln) }


    describe 'addition' do
      it 'adds amounts' do
        (one_usd + two_usd).should == three_usd
      end

      it 'fails for different currencies' do
        expect{ one_usd + two_pln }.to raise_error(TypeError)
      end
    end

    describe 'subtraction' do
      it 'subtracts amounts' do
        (three_usd - one_usd).should == two_usd
      end

      it 'fails for different currencies' do
        expect{ three_usd - two_pln }.to raise_error(TypeError)
      end
    end

    describe 'multiplication' do
      it 'multiplies amount by bigdecimal' do
        double = one_usd * 2
        double.should == Cash.new(2, :usd)

        tax = three_usd * BigDecimal.new('0.17')
        tax.should == Cash.new('0.51', :usd)
      end

      it 'fails if multiplying cash by cash' do
        expect{ one_usd * one_usd }.to raise_error(ArgumentError)
      end
    end

    describe 'division' do
      it 'divides amount by bigdecimal' do
        split = one_usd / BigDecimal.new('4')
        split.should == Cash.new('0.25', 'USD')
      end

      it 'fails if multiplying cash by cash' do
        expect{ two_usd / one_usd }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#round' do
    it 'rounds to the nearest whole number' do
      Cash.new('1.21', 'USD').round.should == Cash.new('1', 'USD')
    end

    it 'always returns new object' do
      cash = Cash.new('1', 'PLN')
      cash.round.should eq(cash)
      cash.round.should_not equal(cash)
    end
  end

end
