from robotControl import CmdMessenger
from robotControl import CmdManager
from robotControl import Motors
from robotControl import SpeedControl

from fingerDrawer import FingerDrawer

if __name__ == '__main__':

    cMes = CmdMessenger.CmdMessenger()
    cMes.start()

    cMan = CmdManager.CmdManager(cMes)

    cMotor = Motors.Motors(cMes, 5)
    cMotor.start()

    cSpeed = SpeedControl.SpeedControl(cMotor)

    f = FingerDrawer.FingerDrawer()

    def clb(x, y, timeStamp):
        side = x[0]
        if side > 750:
            side = 750
        if side < 50:
            side = 50
        side = (side-400)/350.
        
        speed = y[0]
        if speed > 1000:
            speed = 1000
        if speed < 100:
            speed = 100
        speed = -(speed-550)/450.

        cSpeed.setSpeed(speed * 150)
        cSpeed.setDirection(side)

    f.add_callback(clb)
    f.start()