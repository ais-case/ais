require 'spec_helper'

module Domain  
  describe NavigationStatus do
    it "has code and description properties" do
      ns = NavigationStatus.new(1)
      ns.code.should eq(1)
      ns.description.should eq("Anchored")
    end

    it "can be compared to othe VesselType objects" do
      ns1 = NavigationStatus.new(1)
      ns2 = NavigationStatus.new(1)
      ns3 = NavigationStatus.new(5)
      
      ns1.should eq(ns2)
      ns1.should_not eq(ns3)
      ns1.should_not eq(nil)
    end

    it "can be created from its description" do
      status = {"Anchored" => 1, "Moored" => 5, "Fishing" => 7}
      status.each do |description, code|
        ns = NavigationStatus::from_str(description)
        ns.code.should eq(code)
      end
    end
  end  
end
