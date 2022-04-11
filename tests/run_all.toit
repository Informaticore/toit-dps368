import .testoiteron
import .test_utils
import .test_sensor_cfg

main:
  print "Run all test"
  testcases := [TestUtils, TestSensorCfg]
  testcases.do: | test_case/TestCase |
    test_case.run
      
  print ""
  print "(｡◕‿◕｡) -ALL TESTS OKAY"
