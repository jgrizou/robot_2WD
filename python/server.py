import socket
import threading

class Server(threading.Thread):

    def __init__(self, host, port, end_char='\n'):
        threading.Thread.__init__(self)
        self.daemon = True
        
        self.host  = host
        self.port = port
        self.end_char = end_char

        self._socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)        
        self._socket.bind((self.host, self.port))
        self._socket.listen(1)
        self._callback = []
        self._conn = None
        
    def addCallback(self,callbackfunc) :
        if callbackfunc not in self._callback:
            self._callback.append(callbackfunc)
        
    def delCallback(self,callbackfunc) :
        if callbackfunc in self._callback:
            self._callback.remove(callbackfunc)

    def send(self, msg):
        if self._conn:
            self._conn.send(msg+self.end_char)

    def close(self):
        self._socket.close()

    def run(self):
        data = ""
        while True:
            data = ""
            self._conn, self._addr = self._socket.accept()
            while True:
                data += self._conn.recv(1)
                if not data: 
                    break
                if data[-1] == self.end_char:
                    message = data.split(self.end_char)
                    for clb in self._callback :
                        clb(message[0])
                    data = ""

if __name__ == "__main__":
    s = Server('127.0.0.1', 30003, ';')

    def treat(cmd):
        print cmd

    s.addCallback(treat)
    s.start()

