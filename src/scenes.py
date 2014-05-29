__author__ = 'xavierpouyollon'

import sessionsq
import threading
import time
import thread
import models
import serial
import requests
import pprint

scenes = {}

# /cameleon/getscenelist
def getscenelist():
    global scenes

    res = []
    res.append ( {'id' : None, 'name': '<Create a new scene>'})
    for k in scenes:
        res.append( {'id':k, 'name':k})
    return {'list' : res}

# /cameleon/createscene/:scene
def createscene(scene):
    global scenes

    e = { 'desc' :'TODO', 'list':[]}
    scenes[scene] = []
    return {'res' : 'ok'}
