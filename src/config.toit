MEAS_RATE_1    ::= 0b000
MEAS_RATE_2    ::= 0b001
MEAS_RATE_4    ::= 0b010
MEAS_RATE_8    ::= 0b011
MEAS_RATE_16   ::= 0b100
MEAS_RATE_32   ::= 0b101
MEAS_RATE_64   ::= 0b110
MEAS_RATE_128  ::= 0b111
MEASURE_RATES ::= {MEAS_RATE_1, MEAS_RATE_2, MEAS_RATE_4, MEAS_RATE_8, MEAS_RATE_16, MEAS_RATE_32, MEAS_RATE_64, MEAS_RATE_128}

OS_1_TIME    ::= 0b0000
OS_2_TIMES    ::= 0b0001
OS_4_TIMES    ::= 0b0010
OS_8_TIMES    ::= 0b0011
OS_16_TIMES   ::= 0b0100
OS_32_TIMES   ::= 0b0101
OS_64_TIMES   ::= 0b0110
OS_128_TIMES  ::= 0b0111
OS_RATES ::= {OS_1_TIME, OS_2_TIMES, OS_4_TIMES, OS_8_TIMES, OS_16_TIMES, OS_32_TIMES, OS_64_TIMES, OS_128_TIMES}

class PressureConfig:

  cfg_value/int

  constructor measure_rate/int oversampling_rate/int:
    if not MEASURE_RATES.contains measure_rate:
      throw "config value $measure_rate for Measure Rate is not valied"
    if not OS_RATES.contains oversampling_rate:
      throw "config value $oversampling_rate for Oversampling Rate is not valied"
      
    cfg_value = measure_rate << 4 | oversampling_rate

  cfg -> int:
    return cfg_value

class TemperatureConfig:
  static SENSOR_INTERNAL ::= 0
  static SENSOR_EXTERNAL ::= 1

  cfg_value/int

  constructor sensor/int measure_rate/int oversampling_rate:
    if sensor != SENSOR_EXTERNAL and sensor != SENSOR_INTERNAL:
      throw "sensor value $sensor is not allowed"
    if not MEASURE_RATES.contains measure_rate:
      throw "config value $measure_rate for Measure Rate is not valied"
    if not OS_RATES.contains oversampling_rate:
      throw "config value $oversampling_rate for Oversampling Rate is not valied"
      
    cfg_value = sensor << 7 | measure_rate << 4 | oversampling_rate

  cfg -> int:
    return cfg_value
