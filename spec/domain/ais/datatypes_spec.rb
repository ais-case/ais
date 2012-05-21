require 'spec_helper'

module Domain::AIS
  describe Datatypes do
    describe "Int" do
      it "can return the value as a bit vector" do
        int = Datatypes::Int.new(52 * 600_000)
        int.bit_string(27).should eq("001110111000001001100000000")
      end
    end       
  end
end