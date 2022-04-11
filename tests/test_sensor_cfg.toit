import .testoiteron
import config

class TestSensorCfg implements TestCase:

  run:
    test_pressure_config
    test_config_throw_oversampling
    test_config_throw_measure_rate
    test_temperature_config
    test_temperature_config_throw_sensor

  test_pressure_config:
    value/int := 0b0001_0010
    cfg := config.PressureConfig config.MEAS_RATE_2 config.OS_4_TIMES
    assertEquals value cfg.cfg_value    

  test_temperature_config:
    value/int := 0b0001_0010 // sensor 0
    cfg := config.TemperatureConfig 0 config.MEAS_RATE_2 config.OS_4_TIMES
    assertEquals value cfg.cfg_value
    value = 0b1001_0010  //sensor 1
    cfg = config.TemperatureConfig 1 config.MEAS_RATE_2 config.OS_4_TIMES
    assertEquals value cfg.cfg_value

  test_temperature_config_throw_sensor:
    exception := catch:
      config.TemperatureConfig 2 0b001 0b1111
    assertException exception

  test_config_throw_oversampling:
    exception := catch:
      config.PressureConfig 0b001 0b1111
    assertException exception

  test_config_throw_measure_rate:
    exception := catch:
      config.PressureConfig 0b1111 0b0001
    assertException exception

main:
  test := TestSensorCfg
  test.run