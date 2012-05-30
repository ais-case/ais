require 'spec_helper'

module Domain  
  describe VesselType do
    it "has code and description properties" do
      vt = VesselType.new(62)
      vt.code.should eq(62)
      vt.description.should eq("Passenger")
    end

    it "can be compared to othe VesselType objects" do
      vt1 = VesselType.new(62)
      vt2 = VesselType.new(62)
      vt3 = VesselType.new(63)
      
      vt1.should eq(vt2)
      vt1.should_not eq(vt3)
    end

    it "can be created from its description" do
      types = {"Passenger" => 60, "Cargo" => 70, "Tanker" => 80}
      types.each do |description, code|
        vt = VesselType::from_str(description)
        vt.code.should eq(code)
      end
    end
  end  
end
