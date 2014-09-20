UNKNOWNCMD = 10
SETFLOATPRECISION = 11
SETTIMERMICROSEC = 12

class CmdManager(object):
    def __init__(self, cmdMessenger):

        self.cMes = cmdMessenger

        self.cMes.attachUnknown(self.OnUnknownCommand)
        self.cMes.attach(UNKNOWNCMD, self.UnknownCmd)

    def OnUnknownCommand(self, cmd):
        print "Computer received unknown command: " + cmd

    def UnknownCmd(self, cmdList):
        print "Robot received unknown command!"

    def SetFloatPrecision(self, n):
        self.cMes.send(SETFLOATPRECISION, n)

    def SetTimeMicroSec(self, n):
        self.cMes.send(SETTIMERMICROSEC, n)












