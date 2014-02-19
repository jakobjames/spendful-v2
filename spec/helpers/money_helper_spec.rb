require 'helper_helper'

describe MoneyHelper do
  describe 'currency_to_integer' do
    it 'should require an amount' do
      expect { helper.currency_to_integer }.to raise_exception
    end

    it 'should default to zero if non-numeric amount passed' do
      helper.currency_to_integer(nil).should == 0
      helper.currency_to_integer('').should == 0
      helper.currency_to_integer('ABC').should == 0
    end

    it "should convert a 'dollar' amount into equivalent 'cents'" do
      helper.currency_to_integer(123.45).should == 12345
    end
  end # describe 'currency_to_integer'
end