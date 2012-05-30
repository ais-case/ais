require 'spec_helper'

module Domain::AIS
  describe Datatypes do
    describe "Int" do      
      it "can create an Integer from a bit string" do
        Datatypes::Int.from_bit_string("001110111000001001100000000").should eq(52 * 600_000)
        Datatypes::Int.from_bit_string("1110").should eq(-2)
      end
      
      it "can convert a value to a bit string" do
        Datatypes::Int.bit_string(5.0 * 6.0, 6).should eq("011110")
        Datatypes::Int.bit_string(52 * 600_000, 27).should eq("001110111000001001100000000")
        Datatypes::Int.bit_string(-2, 4).should eq("1110")
      end
    end
    
    describe "UInt" do
      it "can be created from a bit string" do
        Datatypes::UInt.from_bit_string("001110111000001001100000000").should eq(52 * 600_000)
        Datatypes::UInt.from_bit_string("1110").should eq(14)
      end
      
      it "can return the value as a bit string" do
        Datatypes::UInt.bit_string(52 * 600_000, 27).should eq("001110111000001001100000000")
        Datatypes::UInt.bit_string(14, 4).should eq("1110")
      end
    end
  end
end