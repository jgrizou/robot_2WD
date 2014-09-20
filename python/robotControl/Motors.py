import threading
import time

MOVEXCOUNT = 20
GETCOUNT = 21
COUNT = 22
RESETCOUNT = 23
RESETEDCOUNT = 24
SETPOSCONTROLSTATUS = 25
SETACCELERATION = 26
SETDECELERATION = 27
SETMAXSPEED = 28

SETSPEED = 40
GETSPEED = 41
SPEED = 42
SETPID = 43
SETPIDLIMIT = 44

class Motors(threading.Thread):
    def __init__(self, cmdMessenger, freq, timeout=0.1):
        threading.Thread.__init__(self)
        self.daemon = True
        self.isRunning = True
        self.setFreq(freq)
        self.timeout = timeout

        self.countM0 = 0
        self.countM1 = 0
        self.resetedCount = []

        self.speedM0 = 0
        self.speedM1 = 0

        self.cMes = cmdMessenger
        self.cMes.attach(COUNT, self.updateCount)
        self.cMes.attach(SPEED, self.updateSpeed)
        self.cMes.attach(RESETEDCOUNT, self.handleResetedCount)
        if not self.cMes.isRunning:
            self.cMes.start()

        self.setPosControlStatus(1)
        self.setPID(0.,1., 0.)
        self.setPIDLimit(50.)

        self.acceleration = 100.
        self.decelearation = 20.
        self.maxSpeed = 40.

        self.isCountUpdated = True
        self.isSpeedUpdated = True

    def kill(self):
        self.isRunning = False

    def run(self):
        while self.isRunning:
            if self.isCountUpdated:
                self.cMes.send(GETCOUNT)
            if self.isSpeedUpdated:
                self.cMes.send(GETSPEED)
            time.sleep(self.sleepTime)


    def setFreq(self, freq):
        self.sleepTime = 1./freq

    def moveXcount(self, nCountM0, nCountM1):
        self.cMes.send(MOVEXCOUNT, int(nCountM0), int(nCountM1))

    def getCountM0(self):
        return self.countM0

    def getCountM1(self):
        return self.countM1

    def getCounts(self):
        return self.getCountM0(), self.getCountM1()

    def setSpeed(self, speedM0, speedM1):
        self.cMes.send(SETSPEED, float(speedM0), float(speedM1))

    def getSpeedM0(self):
        return self.speedM0

    def getSpeedM1(self):
        return self.speedM1

    def getSpeeds(self):
        return self.getSpeedM0(), self.getSpeedM1()

    def updateCount(self, cmdList):
        self.countM0 = int(cmdList[1])
        self.countM1 = int(cmdList[2])

    def updateSpeed(self, cmdList):
        self.speedM0 = float(cmdList[1])
        self.speedM1 = float(cmdList[2])

    def handleResetedCount(self, cmdList):
        self.resetedCount = cmdList[1:]

    def resetCount(self):
        self.cMes.send(RESETCOUNT)
        startTime = time.time()
        inTime = True
        while not self.resetedCount and inTime:
            time.sleep(1e-6)
            if time.time() - startTime > self.timeout:
                inTime = False
        if not inTime:
            return [None, None]
        tmp = self.resetedCount
        self.resetedCount = []
        return tmp

    def setPosControlStatus(self, status):
        self.positionControl = int(status)
        self.cMes.send(SETPOSCONTROLSTATUS, self.positionControl)

    def setPID(self, KP, KI, KD):
        self.KP = float(KP)
        self.KI = float(KI)
        self.KD = float(KD)
        self.cMes.send(SETPID, self.KP, self.KI, self.KD)

    def setPIDLimit(self, limit):
        self.PIDLimit = float(limit)
        self.cMes.send(SETPIDLIMIT, self.PIDLimit)

    def setAcceleration(self, acc):
        self.acceleration = float(acc)
        self.cMes.send(SETACCELERATION, self.acceleration)

    def setDeceleration(self, dec):
        self.deceleration = float(dec)
        self.cMes.send(SETDECELERATION, self.acceleration)

    def setMaxSpeed(self, speed):
        self.maxSpeed = float(speed)
        self.cMes.send(SETMAXSPEED, self.maxSpeed)