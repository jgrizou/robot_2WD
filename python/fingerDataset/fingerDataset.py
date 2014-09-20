from fingerDrawer import FingerDrawer

import numpy
import scipy.io


if __name__ == '__main__':

    data = []
    
    f = FingerDrawer.FingerDrawer()

    def clb(x, y, timeStamp):
        data.append((x, y, timeStamp))

    f.add_callback(clb)
    f.start()

    run = 1
    while run:

        mes = raw_input()

        print len(data)

        if mes == 'QUIT':
            run = 0


    datasetName = raw_input('Enter dataset name: ')

    d = {}
    d['fingerData'] = data

    scipy.io.savemat(datasetName, d)

