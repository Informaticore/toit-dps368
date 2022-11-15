import .testoiteron
import utils

class TestUtils implements TestCase:

  run:
    test_utils_enable_bit
    test_utils_disable_bit
    test_utils_disable_bit_high
    test_utils_is_bit_set
    test_utils_is_bit_not_set
    test_utils_read_bits_size_8
    test_utils_read_bits_size_16

  test_utils_enable_bit:
    value/int := 0b0000_0010
    new_value/int := utils.enable_bit value 0
    assertEquals 3 new_value

  test_utils_disable_bit:
    value/int := 0b0000_0011 
    new_value/int := utils.disable_bit value 1
    assertEquals 1 new_value

  test_utils_disable_bit_high:
    value/int := 0b1111_1111
    new_value/int := utils.disable_bit value 7
    assertEquals 127 new_value

  test_utils_is_bit_set:
    value/int := 0b0001_1000
    is_bit_set := utils.is_bit_set value 4
    assertEquals true is_bit_set

  test_utils_is_bit_not_set:
    value/int := 0b0001_0000
    is_bit_set := utils.is_bit_set value 3
    assertEquals false is_bit_set
    is_bit_set = utils.is_bit_set value 5
    assertEquals false is_bit_set

  test_utils_read_bits_size_8:
    src := 0b1010_1010
    sub := utils.read_bits src 7 4
    assertEquals 0b1010 sub
    sub = utils.read_bits src 3 1
    assertEquals 0b0101 sub

    src = 0b1111_1111
    sub = utils.read_bits src 7 4
    assertEquals 0b0000_1111 sub

  test_utils_read_bits_size_16:
    src := 0b1001110111
    sub := utils.read_bits src 9 5 16
    assertEquals 0b10011 sub
  

main:
  test := TestUtils
  test.run