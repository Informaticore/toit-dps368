import serial
import .register as reg
import .utils as utils
import .config

I2C_ADDRESS_DEFAULT ::= 0x77
I2C_ADDRESS_PD ::= 0x76

class DPS368:

  registers_/serial.Registers

  constructor device/serial.Device:
    registers_ = device.registers

  productId -> string:
    version := registers_.read_u8 reg.PROD_ID
    revision := utils.read_bits version 7 4
    productId := utils.read_bits version 3 0
    return "$productId.$revision"

  pressure_raw -> int:
    psr_b2 := registers_.read_u8 reg.PSR_B2
    psr_b1 := registers_.read_u8 reg.PSR_B1
    psr_b0 := registers_.read_u8 reg.PSR_B0
    psr := (psr_b2 << 16) | (psr_b1 << 8) | psr_b0

    return utils.get_twos_complement psr 24

  temperature_raw -> int:
    tmp_b2 := registers_.read_u8 reg.TMP_B2
    tmp_b1 := registers_.read_u8 reg.TMP_B1
    tmp_b0 := registers_.read_u8 reg.TMP_B0
    tmp := (tmp_b2 << 16) | (tmp_b1 << 8) | tmp_b0

    return utils.get_twos_complement tmp 24

  measure_config -> int:
    return registers_.read_u8 reg.MEAS_CFG

  standby:
    registers_.write_u8 reg.MEAS_CFG 0b000

  measurePressureOnce:
    registers_.write_u8 reg.MEAS_CFG 0b001

  measureTemperatureOnce:
    registers_.write_u8 reg.MEAS_CFG 0b010

  measureContinousPressureOnly:
    registers_.write_u8 reg.MEAS_CFG 0b101

  measureContinousTemperatureOnly:
    registers_.write_u8 reg.MEAS_CFG 0b110

  measureContinousPressureAndTemperature:
    registers_.write_u8 reg.MEAS_CFG 0b111

  pressure_config pressure_config/PressureConfig:
    registers_.write_u8 reg.PSR_CFG pressure_config.cfg_value

  temperature_config temperature_config/TemperatureConfig:
    registers_.write_u8 reg.TMP_CFG temperature_config.cfg_value

  temperature_sensor -> int:
    coef_srce := registers_.read_u8 reg.COEF_SRCE
    tmp_coef_srce := utils.is_bit_set coef_srce 7
    if tmp_coef_srce == true:
      return 1
    else:
      return 0

  