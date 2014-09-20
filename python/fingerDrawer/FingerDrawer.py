import threading
import time

import sockit

class FingerDrawer(threading.Thread):
    def __init__(self, interface='en0', port=12345):
        threading.Thread.__init__(self)
        self.daemon = True
        self.isRunning = True

        self.interface = interface
        self.port =port
        self.server = sockit.Server()

        self.callbacks = []

    def kill(self):
        self.isRunning = False

    def run(self):
        self.server.start(self.interface, self.port)
        while self.isRunning:
            if self.server.get_number_of_messages() > 0:
                message = self.server.receive()

                x = []
                y = []
                timeStamp = []

                size = message.read()
                for i in xrange(size):
                    x.append(message.read())
                    y.append(message.read())
                    timeStamp.append(message.read())

                for clb in self.callbacks:
                    clb(x, y, timeStamp)

            else:
                time.sleep(0.1)

        self.server.stop()

    def add_callback(self, functionToCall):
       	if not functionToCall in self.callbacks:
            self.callbacks.append(functionToCall)

    def del_callback(self, functionToCall):
        if functionToCall in self.callbacks:
            self.callbacks.remove(functionToCall)

if __name__ == '__main__':
    f = FingerDrawer()

    def clb(x, y, timeStamp):
        print x
        print y
        print timeStamp

    f.add_callback(clb)
    f.start()

    raw_input()

    f.kill()
    f.join()

