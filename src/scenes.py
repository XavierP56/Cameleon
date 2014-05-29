__author__ = 'xavierpouyollon'

import sessionsq
import threading
import time
import thread
import models
import serial
import requests
import pprint


# /cameleon/getscenelist
def getscenelist():
    res = []
    res.append ( {'id' : None, 'name': '<Create a new scene>'})
    return {'list' : res}