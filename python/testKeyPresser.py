from robotControl import CmdMessenger
from robotControl import CmdManager
from robotControl import Motors
from robotControl import SpeedControl
from robotControl import Gripper
from robotControl import Led

from keyPresser import KeyPresser 

import time
import threading


class KeySpeed(object):
    def __init__(self, kP):
        self.direction = 0
        self.speed = 0
        kP.add_callback(self.clb)

    def clb(self, c):
        if c == 'j':
            self.direction -= 0.25
        if c == 'l':
            self.direction += 0.25
        if c == 'i':
            self.speed += 10
        if c == 'k':
            self.speed -= 10



if __name__ == '__main__':

    cMes = CmdMessenger.CmdMessenger()
    cMes.start()

    cMan = CmdManager.CmdManager(cMes)

    cMotor = Motors.Motors(cMes, 5)
    cMotor.start()

    cSpeed = SpeedControl.SpeedControl(cMotor)

    gripper = Gripper.Gripper(cMes)
    led = Led.Led(cMes)
    led.setColor((0, 200, 0), False)

    kP = KeyPresser.KeyPresser()
    kS = KeySpeed(kP)

    def clb(c):
        if c == 'w':
            led.toggle()
        if c == 'q':
            gripper.open()
        if c == 'a':
            gripper.close()
        if c == 'e':
            kS.speed = 0

    kP.add_callback(clb)
    kP.start()

    while 1:
        print kS.direction, kS.speed
        cSpeed.setDirection(kS.direction)
        cSpeed.setSpeed(kS.speed)
        time.sleep(0.1)




