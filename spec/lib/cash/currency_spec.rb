#encoding: UTF-8

require 'spec_helper'

describe Cash::Currency do

  describe '#initialize' do
    it 'accepts code' do
      ['USD', 'usd', :USD, :usd].each do |code|
        Cash::Currency.new(code, 2, 'US dollar').code.should == 'USD'
      end
    end

    it 'accepts offset' do
      [2, '2'].each do |offset|
        Cash::Currency.new(:usd, offset, 'US dollar').offset.should == 2
      end
    end

    it 'accepts name' do
      Cash::Currency.new(:usd, 2, 'US dollar').name.should == 'US dollar'
    end
  end

  describe '::find' do
    it 'returns registered currency' do
      [:usd, :USD, 'usd', 'USD'].each do |currency|
        Cash::Currency.find(currency).should == Cash::Currency::USD
      end
    end

    it 'returns self for currency' do
      currency = Cash::Currency::USD
      Cash::Currency.find(currency).should equal(currency)
    end

    it 'returns nil for missing currency' do
      Cash::Currency.find('zzz').should be_nil
    end
  end


  describe '::find!' do
    it 'returns currency' do
      Cash::Currency.find!('usd').should == Cash::Currency::USD
    end

    it 'fails for missing currency' do
      ->{ Cash::Currency.find!('zzz') }.should raise_error(ArgumentError)
    end
  end


  context 'equality' do
    let(:usd) { Cash::Currency::USD }
    let(:usd2) { Cash::Currency.new('usd', 2, 'US dollar') }

    it { (usd == usd2).should be_true }
    it { (usd.eql?(usd2)).should be_true }

    it { (usd.equal?(usd2)).should be_false }

    it { usd.hash.should == usd2.hash }

    it { usd.should == Cash::Currency.find('usd') }
    it { usd.should_not == Cash::Currency.find('pln') }
  end

end
