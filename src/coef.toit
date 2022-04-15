class Coefficients:

  c0_/int
  c1_/int
  c00_/int
  c10_/int
  c01_/int
  c11_/int
  c20_/int
  c21_/int
  c30_/int

  press_comp_scale_factor_/int
  temp_comp_scale_factor_/int

  constructor c0/int c1/int c00/int c10/int c01/int c11/int c20/int c21/int c30 .press_comp_scale_factor_ .temp_comp_scale_factor_:
    c0_= c0
    c1_= c1
    c00_ = c00
    c10_ = c10
    c01_ = c01
    c11_ = c11
    c20_ = c20
    c21_ = c21
    c30_ = c30

  calculate_pressure press_raw/int temp_raw/int -> float:
    pressure_sc := press_raw.to_float/press_comp_scale_factor_.to_float
    temperature_sc := temp_raw.to_float/temp_comp_scale_factor_.to_float
    return c00_ + pressure_sc* (c10_ + pressure_sc *(c20_ + pressure_sc *c30_)) + temperature_sc *c01_ + temperature_sc *pressure_sc *(c11_+pressure_sc*c21_)

  calculate_temperature temp_raw/int:
    return (c0_ * 0.5) + (c1_ * (temp_raw/temp_comp_scale_factor_.to_float))

  dump:
    print "c0:  $c0_"
    print "c1:  $c1_"
    print "c00: $c00_"
    print "c10: $c10_"
    print "c01: $c01_"
    print "c11: $c11_"
    print "c20: $c20_"
    print "c21: $c21_"
    print "c30: $c30_"