module Domain::AIS::SixBitEncoding

  def encode_nibble(nibble)
    value = nibble.to_i(2)
    case value
    when (0..39) 
      ascii = value + 48
    when (40..63)
      ascii = value + 48 + 8
    else
      raise "Encoding error for bit pattern " << nibble 
    end
    ascii.chr
  end

  def encode(binary_string)
    # input binary string from SixBitDecoder
    # output ascii string according to AIVDM transformation (see above)
    chunk_count = binary_string.length / 6
    encoded = ""
    1.upto(chunk_count) do |i|
      a = i*6-1
      nibble = binary_string[a-5..a]
      
      encoded << encode_nibble(nibble)
    end
    encoded
  end

  def decode_character(character)
    ascii = character[0].ord
    case ascii
    when (48..87) 
      value = ascii - 48
    when (96..119)
      value = ascii - 48 - 8
    else
      raise "Decoding error for character " << character 
    end
    value.to_s(2).rjust(6, '0')
  end

  def decode(sixbit)
    binaryString = ""
    sixbit.each_char do |c|
      binaryString << decode_character(c)
    end
    binaryString
  end
  
  module_function :encode_nibble, :encode, :decode_character, :decode
end