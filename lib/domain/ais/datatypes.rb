module Domain::AIS::Datatypes
  class Int
    def initialize(num)
      @num = num
    end
    
    def bit_vector(bit_count)
      s = ''
      (bit_count - 1).downto(0) do |i|
        s << @num[i].to_s
      end
      s
    end
  end
end