
/**
  Returns true if the given &bit_num of value is set, false otherwise
*/
is_bit_set value/int bit_num/int -> bool:
  is_set/bool := ((value >> bit_num) & 0x01 == 1)
  return is_set

set_bit value/int bit_num/int enable/bool -> int:
  if enable: value = enable_bit value bit_num
  else: value = disable_bit value bit_num
  return value

/**
  Enables the given &bit_num of value
  Returns the new resulting value of this operation
*/
enable_bit value/int bit_num/int:
  return value |= 0x01 << bit_num

/**
  Disables the given &bit_num of value
  Returns the new resulting value of this operation
*/
disable_bit value/int bit_num/int:
  return value &= ~(0x01 << bit_num)

/**
   Reads the given span $from_bit (incl) to $to_bit (incl). 
   Returns a new value from span $from_bit to $to_bit 

   Example
   ```
    src = 0b1111_1111
    sub = utils.read_bits src 7 4
   ```
   sub will be 0b0000_1111
*/
read_bits src/int from_bit/int to_bit/int size/int=8 -> int:
  value := 0x00
  for bit := size - 1; bit >= 0; bit--:
    if bit <= from_bit and bit >= to_bit:
      value = value << 1
      if (is_bit_set src bit): 
        value = enable_bit value 0 
      else:
        value = disable_bit value 0

  return value

  /**

  */
twos_comp raw/int bits/int -> int:
  if (raw & (1 << (bits - 1))) != 0:
    return raw - (1 << bits) 
  return raw