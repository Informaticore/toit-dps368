import serial
import gpio
import i2c
import dps368
import dps368.config as cfg

main:
  bus := i2c.Bus
      --sda=gpio.Pin 21
      --scl=gpio.Pin 22

  device := bus.device dps368.I2C_ADDRESS_PD
  dps368 := dps368.DPS368 device

  pressure_cfg := cfg.PressureConfig cfg.MEAS_RATE_4 cfg.OS_4_TIMES
  dps368.pressure_config pressure_cfg

  sensor := dps368.temperature_sensor
  temperature_cfg := cfg.TemperatureConfig sensor cfg.MEAS_RATE_4 cfg.OS_4_TIMES
  dps368.temperature_config temperature_cfg

  dps368.measureContinousPressureAndTemperature

  print "ProductId:  $dps368.productId"
  print "Pressure: $dps368.pressure_raw"
  print "Temperature: $dps368.temperature_raw"
  print "Config: $dps368.measure_config"