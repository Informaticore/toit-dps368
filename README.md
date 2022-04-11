# ltc4162-toit
Library to control a LTC4162 Charger IC with toitlang

## Getting Started
Create ltc-device
```
  bus := i2c.Bus
      --sda=gpio.Pin 21
      --scl=gpio.Pin 22
 
  device := bus.device ltc4162.I2C_ADDRESS
  ltc4162_ := ltc4162.LTC4162 device
```

## Run tests
To run all tests you can use
```
toit run --no-device tests/run_all.toit
```