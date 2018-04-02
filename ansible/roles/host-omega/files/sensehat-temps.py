#!/usr/bin/python
from sense_hat import SenseHat
from datetime import datetime
from time import sleep

sense = SenseHat()
sense.clear()

thedate = datetime.now()

pressure = sense.get_pressure()
temp = sense.get_temperature()
humidity = sense.get_humidity()

print "date: " + str(thedate)

print "pressure: " + str(pressure)

print "temp: " + str(temp)

print "humidity: " + str(humidity)
