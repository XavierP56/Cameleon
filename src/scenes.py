__author__ = 'xavierpouyollon'

import json
import requests


class Scenes:
    scenes = {}
    dmx = None
    snd = None

    args = None
    def __init__(self,largs,lsnd,ldmx):
        self.args = largs
        self.snd = lsnd
        self.dmx = ldmx

    def LoadFromDisk(self):
        # Save the scenes
        ref = "../Files/Profiles/"+self.args.profile
        fpath = ref + "/scenes.json"
        with open(fpath) as datafile:
            self.scenes = json.load(datafile)
        return

    def SaveToDisk(self):
        # Save the scenes
        ref = "../Files/Profiles/"+self.args.profile
        fpath = ref + "/scenes.json"
        with open(fpath, "w") as outfile:
            json.dump(self.scenes, outfile, sort_keys=True, indent=4,ensure_ascii=False)

    # /cameleon/getscenelist
    def getscenelist(self):
        res = []
        #res.append ( {'id' : None, 'name': '<Create a new scene>'})
        for k in self.scenes:
            res.append( {'id':k, 'name':k})
        return {'list' : res}

    # /cameleon/createscene/:scene
    def createscene(self,scene):
        entry = { 'desc' :'TODO', 'list':[]}
        self.scenes[scene] = entry
        return {'res' : 'ok'}

    # /cameleon/recordscene
    def recordscene(self,request):
        id = request.json['scene']
        self.scenes[id]['list'] = request.json['machines']
        self.SaveToDisk()
        return {'res':'OK'}

    # /cameleon/loadscene/:scene
    def loadscene(self,scene):
        list = self.scenes[scene]['list']
        for entry in list:
            req = requests.FakeRequest()
            req.json['id'] = entry['id']
            req.json['setting'] = entry['setting']
            self.dmx.dmx_setfader(req)
        return {'load': self.scenes[scene]}