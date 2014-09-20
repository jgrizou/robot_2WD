import os
import sys
import inspect

thisFolder =  os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))  
pythonSrcFolder =  os.path.join(thisFolder, '../python')
sys.path.append(pythonSrcFolder)

import scipy.io
from fingerDrawer import FingerDrawer

if __name__ == '__main__':

    f = FingerDrawer.FingerDrawer()

    def clb(x, y, timeStamp):
        d = {}
        d['x'] = x
        d['y'] = y
        d['timeStamp'] = timeStamp
        folderToSave = os.path.join(thisFolder, 'shared', 'fingers')
        if not os.path.exists(folderToSave):
            os.mkdir(folderToSave)
        datasetName =  os.path.join(folderToSave, str(timeStamp[0]))
        scipy.io.savemat(datasetName, d)
       
    f.add_callback(clb)
    f.start()