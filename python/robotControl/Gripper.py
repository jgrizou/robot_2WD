SETSERVOPOSITION = 50
SETGRIPPERPOSITION = 51

class Gripper(object):
    def __init__(self, cmdMessenger):
        self.cMes = cmdMessenger
        if not self.cMes.isRunning:
            self.cMes.start()

    def setServoPosition(self, leftServoValue, rightServoValue):
        self.cMes.send(SETSERVOPOSITION, leftServoValue, rightServoValue)

    def open(self):
        self.setServoPosition(50, 100)

    def close(self):
        self.setServoPosition(170, 5)