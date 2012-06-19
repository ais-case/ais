require 'spec_helper'

module Domain::AIS
  describe Policy do
    describe "position_reports_compliant?" do
      
      before(:each) do
        @msg = Domain::AIS::Message1.new(12345)
        @msg.lat = 52
        @msg.lon = 4
      end
            
      describe "for non-anchored, non-route changing vessels" do
        it "returns false for non-compliant message sequences" do
          {1.0 => 10, 14.1 => 6, 23.1 => 2}.each do |speed,interval|
            m1 = @msg.clone
            m1.speed = speed
            t1 = Time.new.to_f - interval - 1
            
            m2 = m1.clone
            t2 = t1 + interval + 1

            Policy::position_reports_compliant?(t1, m1, t2, m2).should be_false
          end
        end

        it "returns true for compliant message sequences" do
          {1.0 => 10, 14.1 => 6, 23.1 => 2}.each do |speed,interval|
            m1 = @msg.clone
            m1.speed = speed
            t1 = Time.new.to_f - interval
            
            m2 = m1.clone
            t2 = t1 + interval

            Policy::position_reports_compliant?(t1, m1, t2, m2).should be_true
          end
        end
      end
      
      describe "for non-anchored, route changing vessels" do
        it "returns false for non-compliant message sequences" do
          {1.0 => 3.5, 14.1 => 2, 23.1 => 2}.each do |speed,interval|
            m1 = @msg.clone
            m1.speed = speed
            m1.heading = 80
            t1 = Time.new.to_f - interval - 1
            
            m2 = m1.clone
            m2.heading = 10
            t2 = t1 + interval + 1

            Policy::position_reports_compliant?(t1, m1, t2, m2).should be_false
          end
        end

        it "returns true for compliant message sequences" do
          {1.0 => 3.5, 14.1 => 2, 23.1 => 2}.each do |speed,interval|
            m1 = @msg.clone
            m1.speed = speed
            m1.heading = 80
            t1 = Time.new.to_f - interval
            
            m2 = m1.clone
            m2.heading = 10
            t2 = t1 + interval

            Policy::position_reports_compliant?(t1, m1, t2, m2).should be_true
          end
        end
      end
      
      describe "for anchored vessels" do
        it "returns false for non-compliant message sequences" do
          {1.0 => 180, 3.1 => 10}.each do |speed,interval|
            m1 = @msg.clone
            m1.speed = speed
            m1.navigation_status = Domain::NavigationStatus::from_str('Moored')
            t1 = Time.new.to_f - interval - 1
            
            m2 = m1.clone
            t2 = t1 + interval + 1

            Policy::position_reports_compliant?(t1, m1, t2, m2).should be_false
          end
        end

        it "returns true for compliant message sequences" do
          {1.0 => 180, 3.1 => 10}.each do |speed,interval|
            m1 = @msg.clone
            m1.speed = speed
            m1.navigation_status = Domain::NavigationStatus::from_str('Moored')
            t1 = Time.new.to_f - interval
            
            m2 = m1.clone
            t2 = t1 + interval

            Policy::position_reports_compliant?(t1, m1, t2, m2).should be_true
          end
        end
      end
      
      describe "for vessels with unknown speed" do
        it "returns false when vessel has reported unknown speed once" do
          interval = 1
          m1 = @msg.clone
          m1.speed = nil
          t1 = Time.new.to_f - interval - 1
          
          m2 = m1.clone
          m2.speed = nil
          t2 = t1 + interval

          Policy::position_reports_compliant?(t1, m1, t2, m2).should be_false
          Policy::position_reports_compliant?(t1, m2, t2, m1).should be_false
        end

        it "returns false when vessel always reports unknown speed" do
          interval = 1
          m1 = @msg.clone
          m1.speed = nil
          t1 = Time.new.to_f - interval - 1
          
          m2 = m1.clone
          m2.speed = nil
          t2 = t1 + interval

          Policy::position_reports_compliant?(t1, m1, t2, m2).should be_false
        end
      end
    end
  end
end