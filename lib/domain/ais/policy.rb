require_relative '../navigation_status'

module Domain
  module AIS
    module Policy      
      def position_reports_compliant?(prev_timestamp, prev_message, timestamp, message)
        if prev_message.speed.nil? or message.speed.nil?
          return false
        end
        
        min_speed = [message.speed, prev_message.speed].min
        
        course_changed = false
        if message.heading and prev_message.heading
          heading_change = (message.heading - prev_message.heading).abs
          course_changed = (heading_change > 5)
        end
        
        anchored = message.navigation_status == Domain::NavigationStatus::from_str('Anchored')
        moored = message.navigation_status == Domain::NavigationStatus::from_str('Moored')

        if anchored or moored
          if min_speed > 3.0
            interval = 10.0
          else 
            interval = 180.0
          end            
        elsif course_changed
          if min_speed > 23.0
            interval = 2.0
          elsif min_speed > 14.0
            interval = 2.0
          else 
            interval = 3.5
          end
        else
          if min_speed > 23.0
            interval = 2.0
          elsif min_speed > 14.0
            interval = 6.0
          else 
            interval = 10.0
          end            
        end
        compliant = (timestamp - prev_timestamp <= interval)
      end
      
      module_function :position_reports_compliant?
    end
  end
end