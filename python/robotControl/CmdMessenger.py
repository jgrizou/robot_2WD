#!/usr/bin/python

import threading
import serial

class CmdMessenger(threading.Thread):
    def __init__(self, port='/dev/tty.usbserial-A4004CwB', baudrate=19200, timeout=0.01, fldSeparator=',', cmdSeparator=';'):
        threading.Thread.__init__(self)
        self.daemon = True
        self.isRunning = True

        self.cmdSeparator = cmdSeparator
        self.fldSeparator = fldSeparator

        self.ser = serial.Serial(port=port, baudrate=baudrate, timeout=timeout)

        self.callback = {}

    def kill(self):
        self.isRunning = False

    def run(self):
        if not self.ser.isOpen():
            self.ser.open()
        cmd = ''
        while self.isRunning:
                msg = self.ser.read(1)
                if msg:
                    if msg == self.cmdSeparator:
                        self.handle(cmd)
                        cmd = ''
                    else:
                        cmd = cmd + msg
        self.ser.close()

    def attach(self, msgId, functionToCall):
        if not self.callback.has_key(str(msgId)):
            self.callback[str(msgId)] = []
        if not functionToCall in self.callback[str(msgId)]:
            self.callback[str(msgId)].append(functionToCall)

    def detach(self, msgId, functionToCall):
        if not self.callback.has_key(str(msgId)):
            if functionToCall in self.callback[str(msgId)]:
                self.callback[str(msgId)].remove(functionToCall)

    def attachUnknown(self, functionToCall):
        if not self.callback.has_key(None):
            self.callback[None] = []
        if not functionToCall in self.callback[None]:
            self.callback[None].append(functionToCall)

    def detachUnknown(self, functionToCall):
        if not self.callback.has_key(None):
            if functionToCall in self.callback[None]:
                self.callback[None].remove(functionToCall)

    def handle(self, cmd):
        cmd = cmd.strip()
        cmdList = cmd.split(self.fldSeparator)
        if cmdList[0] in self.callback:
            for clb in self.callback[cmdList[0]]:
                clb(cmdList)
        else:
            if None in self.callback:
                for clb in self.callback[None]:
                    clb(cmd)

    def formatCmd(self, msgId, *arg):
        cmd = ''
        cmd += str(msgId)
        for thearg in arg:
            cmd += self.fldSeparator
            cmd += str(thearg)
        cmd += self.cmdSeparator
        return cmd

    def send(self, msgId, *arg):
        cmd = self.formatCmd(msgId, *arg)
        self.write(cmd)

    def write(self, msg):
        self.ser.write(msg)

if __name__ == '__main__':
    cMes = CmdMessenger()
    cMes.start()

    def clb(msg):
        print msg

    cMes.attach(22, clb)
    cMes.attachUnknown(clb)

    cMes.send(20,100,100)

    quit = False
    while not quit:
        msg = raw_input()
        if msg == "QUIT":
            quit = True
        else:
            cMes.ser.write(msg)

    cMes.kill()
    cMes.join()