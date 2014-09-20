import time

SETLEDCOLOR = 60

class Led(object):
    def __init__(self, cmdMessenger):
        self.cMes = cmdMessenger
        self.currentColor = (0,0,0)
        self.isOn = False
        if not self.cMes.isRunning:
            self.cMes.start()

    def setOn(self):
        self.isOn = True
        self._applyColor(self.currentColor)

    def setOff(self):
        self.isOn = False
        self._applyColor((0,0,0))

    def setColor(self, color, setOn=True):
        self.currentColor = color
        if setOn:
            self.setOn()

    def _applyColor(self, color):
        r, g, b = color
        self.cMes.send(SETLEDCOLOR, r, g, b)

    def toggle(self):
        if self.isOn:
            self.setOff()
        else:
            self.setOn()

    def blink(self, nTimes=2, delay=0.2):
    	"""
        set color to (0,0,0) for delay seconds
    	and put bakc the original color
        """
        if nTimes == 0:
            return
        else:
            r, g, b = self.currentColor
            self.toggle()
            time.sleep(delay)
            self.toggle()
            time.sleep(delay)
            self.blink(nTimes-1, delay)

# SETLEDPOWER = 61
    # def setPower(self, r, g, b):
        # self.cMes.send(SETLEDPOWER, r, g, b)