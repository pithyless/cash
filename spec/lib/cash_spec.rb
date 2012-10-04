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

    it 'displays correct offset' do
      Cash.new('123.4567', :jpy).to_s.should == '123 JPY'
      Cash.new('123.4567', :twd).to_s.should == '123.5 TWD'
      Cash.new('123.4567', :pln).to_s.should == '123.46 PLN'
      Cash.new('123.4567', :bhd).to_s.should == '123.457 BHD'
    end
  end

  describe '#inspect' do
    it 'displays value and currency' do
       Cash.new('100.3', :eur).inspect.should == '<Cash 100.30 EUR>'
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
        ->{ Cash.new(1, :pln) <=> Cash.new(1, :usd) }.should raise_error(TypeError)
      end

      it 'fails for non-cash' do
        ->{ Cash.new(1, :pln) <=> 1 }.should raise_error(TypeError)
      end
    end

    it { (Cash.new(1, :usd) < Cash.new(2, :usd)).should be_true }
    it { (Cash.new(3, :usd) >= Cash.new(3, :usd)).should be_true }
    it { (Cash.new(3, :usd) == Cash.new(3, :usd)).should be_true }
    it { (Cash.new(3, :pln) != Cash.new(3, :usd)).should be_true }
    it { (Cash.new('1.234', :usd) != Cash.new('1.23', :usd)).should be_true }

    it 'fails for different currencies' do
      ->{ Cash.new(1, :usd) < Cash.new(1, :pln) }.should raise_error(TypeError)
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
        ->{ one_usd + two_pln }.should raise_error(TypeError)
      end
    end

    describe 'subtraction' do
      it 'subtracts amounts' do
        (three_usd - one_usd).should == two_usd
      end

      it 'fails for different currencies' do
        ->{ three_usd - two_pln }.should raise_error(TypeError)
      end
    end
  end

end
