require 'spec_helper'

module Domain::AIS
  describe Datatypes do
    describe "Int" do
      it "has a value property" do
        int = Datatypes::Int.new(10)
        int.value.should eq(10)
      end
      
      it "can be created from a bit string" do
        int = Datatypes::Int.from_bit_string("001110111000001001100000000")
        int.value.should eq(52 * 600_000)
        
        int = Datatypes::Int.from_bit_string("1110")
        int.value.should eq(-2)
      end
      
      it "can return the value as a bit string" do
        int = Datatypes::Int.new(52 * 600_000)
        int.bit_string(27).should eq("001110111000001001100000000")

        int = Datatypes::Int.new(-2)
        int.bit_string(4).should eq("1110")
      end
    end
    
    describe "UInt" do
      it "has a value property" do
        int = Datatypes::UInt.new(10)
        int.value.should eq(10)
      end
      
      it "can be created from a bit string" do
        int = Datatypes::UInt.from_bit_string("001110111000001001100000000")
        int.value.should eq(52 * 600_000)
        
        int = Datatypes::UInt.from_bit_string("1110")
        int.value.should eq(14)
      end
      
      it "can return the value as a bit string" do
        int = Datatypes::UInt.new(52 * 600_000)
        int.bit_string(27).should eq("001110111000001001100000000")

        int = Datatypes::UInt.new(14)
        int.bit_string(4).should eq("1110")
      end
    end
  end
end