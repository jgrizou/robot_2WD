import CmdMessenger
import CmdManager
import Motors
import Gripper
import Led

import SpeedControl

if __name__ == '__main__':

    cMes = CmdMessenger.CmdMessenger()
    cMes.start()

    cMan = CmdManager.CmdManager(cMes)

    cMotor = Motors.Motors(cMes, 5)
    cMotor.start()

    cSpeed = SpeedControl.SpeedControl(cMotor)

    gripper = Gripper.Gripper(cMes)
    led = Led.Led(cMes)
