#!/usr/bin/python
import os
from time import sleep
from sense_hat import SenseHat

sense = SenseHat()
sense.set_rotation(180)

coltxt =  (255, 255, 255)
colback = (25, 25, 60)

sleep(2)

sense.show_message("SenseHat Up!", text_colour=coltxt, back_colour=colback)

sleep(2)

if not os.path.exists("/home/pi/.config/sensehatwelcomed"):
    os.mknod("/home/pi/.config/sensehatwelcomed")

sleep(2)

sense.clear()
