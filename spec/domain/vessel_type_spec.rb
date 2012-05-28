require 'spec_helper'

module Domain  
  describe VesselType do
    it "has code and description properties" do
      vt = VesselType.new(60, "Passenger")
      vt.code.should eq(60)
      vt.description.should eq("Passenger")
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
