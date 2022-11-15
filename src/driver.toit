import serial
import .register as reg
import .utils as utils
import .config as cfg
import .coef

I2C_ADDRESS_DEFAULT ::= 0x77
I2C_ADDRESS_PD ::= 0x76

class DPS368:

  registers_/serial.Registers
  coef/Coefficients? := null

  constructor device/serial.Device:
    registers_ = device.registers 

  init pressure_measure_rate/int pressure_oversampling_rate/int temperature_measure_rate/int temperature_oversampling_rate/int:
    sensor := temperature_sensor
    temperature_cfg := cfg.TemperatureConfig sensor temperature_measure_rate temperature_oversampling_rate
    pressure_cfg := cfg.PressureConfig pressure_measure_rate pressure_oversampling_rate
    pressure_scale_factor := pressure_cfg.comp_scale_factor
    temperature_scale_factor := temperature_cfg.comp_scale_factor
    coef = calibration_coefficiency_values pressure_scale_factor temperature_scale_factor

    enable_p_shift pressure_oversampling_rate > cfg.OVERSAMPLING_RATE.TIMES_8
    enable_t_shift temperature_oversampling_rate > cfg.OVERSAMPLING_RATE.TIMES_8

    // set dps368 to standby to set config
    standby
    // set config
    temperature_config temperature_cfg
    pressure_config pressure_cfg
    //perform a first temperature measurement
    //the most recent temperature will be saved internally
    //and used for compensation when calculating pressure
    measureTemperatureOnce
    temperature_raw

    correct_temperature
    standby
    sleep --ms=100

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

    return utils.twos_comp psr 24

  temperature_raw -> int:
    tmp_b2 := registers_.read_u8 reg.TMP_B2
    tmp_b1 := registers_.read_u8 reg.TMP_B1
    tmp_b0 := registers_.read_u8 reg.TMP_B0
    tmp := (tmp_b2 << 16) | (tmp_b1 << 8) | tmp_b0

    return utils.twos_comp tmp 24

  correct_temperature:
    registers_.write_u8 reg.FIX_TMP_1 0xA5
    registers_.write_u8 reg.FIX_TMP_2 0x96
    registers_.write_u8 reg.FIX_TMP_3 0x02
    registers_.write_u8 reg.FIX_TMP_4 0x00
    registers_.write_u8 reg.FIX_TMP_5 0x00

    measureTemperatureOnce
    temperature_raw

  enable_interrupt enable/bool:
    enable_config reg.CFG_REG 7 enable

  enable_fifo_full_interrupt enable/bool:
    enable_config reg.CFG_REG 6 enable

  enable_temperature_interrupt enable/bool:
    enable_config reg.CFG_REG 5 enable

  enable_pressure_interrupt enable/bool:
    enable_config reg.CFG_REG 4 enable

  enable_t_shift enable/bool:
    enable_config reg.CFG_REG 3 enable

  enable_p_shift enable/bool:
    enable_config reg.CFG_REG 2 enable

  enable_fifo enable/bool:
    enable_config reg.CFG_REG 1 enable

  enable_config cfg_register/int bit_nr/int enable/bool:
    config := registers_.read_u8 cfg_register
    if enable:
      config = utils.enable_bit config bit_nr
    else:
      config = utils.disable_bit config bit_nr
    registers_.write_u8 cfg_register config

  is_fifo_full -> bool:
    value := registers_.read_u8 reg.FIFO_STS
    return utils.is_bit_set value 1

  is_fifo_empty -> bool:
    value := registers_.read_u8 reg.FIFO_STS
    return utils.is_bit_set value 0

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

  pressure_config pressure_config/cfg.PressureConfig:
    registers_.write_u8 reg.PSR_CFG pressure_config.cfg_value

  temperature_config temperature_config/cfg.TemperatureConfig:
    registers_.write_u8 reg.TMP_CFG temperature_config.cfg_value

  temperature_sensor -> int:
    coef_srce := registers_.read_u8 reg.COEF_SRCE
    tmp_coef_srce := utils.is_bit_set coef_srce 7
    if tmp_coef_srce:
      return 1
    else:
      return 0

  pressure -> float:
    return coef.calculate_pressure pressure_raw temperature_raw

  temperature -> float:
    return coef.calculate_temperature temperature_raw

  calibration_coefficiency_values press_comp_scale_factor/int temp_comp_scale_factor/int -> Coefficients:
    c0_1    := registers_.read_u8 reg.COEF.C0
    c0_c1   := registers_.read_u8 reg.COEF.C0_C1
    c1_1    := registers_.read_u8 reg.COEF.C1
    c00_1   := registers_.read_u8 reg.COEF.C00_1
    c00_2   := registers_.read_u8 reg.COEF.C00_2
    c00_c10 := registers_.read_u8 reg.COEF.C00_C10
    c10_1   := registers_.read_u8 reg.COEF.C10_1
    c10_2   := registers_.read_u8 reg.COEF.C10_2
    c01_1   := registers_.read_u8 reg.COEF.C01_1
    c01_2   := registers_.read_u8 reg.COEF.C01_2
    c11_1   := registers_.read_u8 reg.COEF.C11_1
    c11_2   := registers_.read_u8 reg.COEF.C11_2
    c20_1   := registers_.read_u8 reg.COEF.C20_1
    c20_2   := registers_.read_u8 reg.COEF.C20_2
    c21_1   := registers_.read_u8 reg.COEF.C21_1
    c21_2   := registers_.read_u8 reg.COEF.C21_2
    c30_1   := registers_.read_u8 reg.COEF.C30_1
    c30_2   := registers_.read_u8 reg.COEF.C30_2

    c0  := utils.twos_comp (((c0_1 << 4) | c0_c1 >> 4)) 12
    c1  := utils.twos_comp ((c0_c1 & 0x0f) << 8 | c1_1) 12
    c00 := utils.twos_comp ((c00_1 << 12) | (c00_2 << 4) | (c00_c10 >> 4)) 20
    c10 := utils.twos_comp (((c00_c10 & 0x0f) << 16) | (c10_1 << 8) | c10_2) 20
    c01 := utils.twos_comp ((c01_1 << 8) | c01_2) 16
    c11 := utils.twos_comp ((c11_1 << 8) | c11_2) 16
    c20 := utils.twos_comp ((c20_1 << 8) | c20_2) 16
    c21 := utils.twos_comp ((c21_1 << 8) | c21_2) 16
    c30 := utils.twos_comp ((c30_1 << 8) | c30_2) 16
     
    return Coefficients c0 c1 c00 c10 c01 c11 c20 c21 c30 press_comp_scale_factor temp_comp_scale_factor
  