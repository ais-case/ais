module Domain::AIS::Datatypes
  class Int
    attr_reader :value
    
    def initialize(value)
      @value = value
    end
    
    def self.from_bit_string(s)
      n = s.bytesize
      first = s[0].to_i
      rem = s.byteslice(1, n).reverse

      sum = 2**(n - 1) * -first
      0.upto(n - 2) do |i|
        sum += 2**i * rem[i].to_i
      end
      
      Int.new(sum)
    end
    
    def bit_string(bit_count)
      s = ''
      (bit_count - 1).downto(0) do |i|
        s << @value[i].to_s
      end
      s
    end
  end
end