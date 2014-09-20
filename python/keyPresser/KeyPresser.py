#!/usr/bin/python
import os
import sys 
import fcntl 
import termios 
import threading

fd = sys.stdin.fileno()

oldterm = termios.tcgetattr(fd)
newattr = termios.tcgetattr(fd)
newattr[3] = newattr[3] & ~termios.ICANON & ~termios.ECHO
termios.tcsetattr(fd, termios.TCSANOW, newattr)

oldflags = fcntl.fcntl(fd, fcntl.F_GETFL)
fcntl.fcntl(fd, fcntl.F_SETFL, oldflags | os.O_NONBLOCK)

class KeyPresser(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.daemon = True
        self.isRunning = True

        self.callbacks = []

    def kill(self):
        self.isRunning = False

    def run(self):

        try:
            while self.isRunning:
                try:
                    c = sys.stdin.read(1)
                    for clb in self.callbacks:
                        clb(c)
                except IOError: 
                    pass
        finally:
            termios.tcsetattr(fd, termios.TCSAFLUSH, oldterm)
            fcntl.fcntl(fd, fcntl.F_SETFL, oldflags)

    def add_callback(self, functionToCall):
        if not functionToCall in self.callbacks:
            self.callbacks.append(functionToCall)

    def del_callback(self, functionToCall):
        if functionToCall in self.callbacks:
            self.callbacks.remove(functionToCall)

if __name__ == '__main__':
    import time
    
    kP = KeyPresser()

    def clbPrint(c):
        print c

    kP.add_callback(clbPrint)
    kP.start()

    time.sleep(10)

    kP.kill()
    kP.join()