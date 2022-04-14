class MEASURE_RATE:
  static TIMES_1    ::= 0b000
  static TIMES_2    ::= 0b001
  static TIMES_4    ::= 0b010
  static TIMES_8    ::= 0b011
  static TIMES_16   ::= 0b100
  static TIMES_32   ::= 0b101
  static TIMES_64   ::= 0b110
  static TIMES_128  ::= 0b111
  static ALL_RATES  ::= {TIMES_1, TIMES_2, TIMES_4, TIMES_8, TIMES_16, TIMES_32, TIMES_64, TIMES_128}

class OVERSAMPLING_RATE:
  static TIMES_1    ::= 0b0000
  static TIMES_2    ::= 0b0001
  static TIMES_4    ::= 0b0010
  static TIMES_8    ::= 0b0011
  static TIMES_16   ::= 0b0100
  static TIMES_32   ::= 0b0101
  static TIMES_64   ::= 0b0110
  static TIMES_128  ::= 0b0111
  static ALL_RATES ::= {TIMES_1, TIMES_2, TIMES_4, TIMES_8, TIMES_16, TIMES_32, TIMES_64, TIMES_128}

class COMPENSATION_SCALE_FACTOR:
  static TIMES_1    ::= 524288
  static TIMES_2    ::= 1572864
  static TIMES_4    ::= 3670016
  static TIMES_8    ::= 7864320
  static TIMES_16   ::= 253952
  static TIMES_32   ::= 516096
  static TIMES_64   ::= 1040384
  static TIMES_128  ::= 2088960

class Config:

  oversampling_rate/int
  measure_rate/int
  cfg_value/int := 0

  constructor .measure_rate/int .oversampling_rate/int:
    if not MEASURE_RATE.ALL_RATES.contains measure_rate:
      throw "config value $measure_rate for Measure Rate is not valied"
    if not OVERSAMPLING_RATE.ALL_RATES.contains oversampling_rate:
      throw "config value $oversampling_rate for Oversampling Rate is not valied"

  comp_scale_factor -> int:
    if oversampling_rate == OVERSAMPLING_RATE.TIMES_1:
      return COMPENSATION_SCALE_FACTOR.TIMES_1
    else if oversampling_rate == OVERSAMPLING_RATE.TIMES_2:
      return COMPENSATION_SCALE_FACTOR.TIMES_2
    else if oversampling_rate == OVERSAMPLING_RATE.TIMES_4:
      return COMPENSATION_SCALE_FACTOR.TIMES_4
    else if oversampling_rate == OVERSAMPLING_RATE.TIMES_8:
      return COMPENSATION_SCALE_FACTOR.TIMES_8
    else if oversampling_rate == OVERSAMPLING_RATE.TIMES_16:
      return COMPENSATION_SCALE_FACTOR.TIMES_16
    else if oversampling_rate == OVERSAMPLING_RATE.TIMES_32:
      return COMPENSATION_SCALE_FACTOR.TIMES_32
    else if oversampling_rate == OVERSAMPLING_RATE.TIMES_64:
      return COMPENSATION_SCALE_FACTOR.TIMES_64
    else if oversampling_rate == OVERSAMPLING_RATE.TIMES_128:
      return COMPENSATION_SCALE_FACTOR.TIMES_128
    else:
      return COMPENSATION_SCALE_FACTOR.TIMES_16 //return default
      

class PressureConfig extends Config:

  constructor measure_rate/int oversampling_rate/int:
    super measure_rate oversampling_rate
    
  cfg_value -> int:
    return measure_rate << 4 | oversampling_rate

class TemperatureConfig extends Config:
  static SENSOR_INTERNAL ::= 0
  static SENSOR_EXTERNAL ::= 1

  sensor/int

  constructor .sensor/int measure_rate/int oversampling_rate:
    super measure_rate oversampling_rate
    if sensor != SENSOR_EXTERNAL and sensor != SENSOR_INTERNAL:
      throw "sensor value $sensor is not allowed"
    
  cfg_value -> int:
    return sensor << 7 | measure_rate << 4 | oversampling_rate
