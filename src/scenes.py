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

    entry = { 'desc' :'TODO', 'list':[]}
    scenes[scene] = entry
    return {'res' : 'ok'}

# /cameleon/recordscene
def recordscene(request):
    global scenes
    id = request.json['scene']
    scenes[id]['list'] = request.json['machines']
    return {'res':'OK'}