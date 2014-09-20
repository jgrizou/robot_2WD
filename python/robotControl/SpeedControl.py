

class SpeedControl(object):
    def __init__(self, cMotor):
        self.cMotor = cMotor

        self.cMotor.isCountUpdated = False
        self.cMotor.isSpeedUpdated = False
        self.cMotor.setPosControlStatus(False)

        self.direction = 0
        self.speed = 0

    def setSpeed(self, speed):
        self.speed = speed
        self.setDirection(self.direction)

    def setDirection(self, direction):
        # 0 for straight, smae value for both wheel
        # 1 for stationary rotation right
        # -1 for stationary rotation left
        # between are non stationary turn

        self.direction = direction
        if direction < 0:
            if direction < -1:
                direction = -1 
            alpha = 2 * (direction + 0.5)
            self.cMotor.setSpeed(-self.speed,  alpha * self.speed)
        elif direction > 0:
            if direction > 1:
                direction = 1 
            alpha = -2 * (direction - 0.5)
            self.cMotor.setSpeed(- alpha * self.speed, self.speed)
        else:
            self.cMotor.setSpeed(-self.speed, self.speed)


