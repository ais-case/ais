module Domain
  module AIS
    module Datatypes
      class Int        
        def self.from_bit_string(s)
          n = s.bytesize
          first = s[0].to_i
          rem = s.byteslice(1, n).reverse
    
          sum = 2**(n - 1) * -first
          0.upto(n - 2) do |i|
            sum += 2**i * rem[i].to_i
          end
          
          sum
        end
        
        def self.bit_string(value, bit_count)
          intval = value.to_i
          s = ''
          (bit_count - 1).downto(0) do |i|
            s << intval[i].to_s
          end
          s
        end
      end
      
      class UInt < Int
        def self.from_bit_string(s)
          s.to_i(2)
        end
      end
    end
  end
end