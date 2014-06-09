__author__ = 'xavierpouyollon'

import json
import requests
import sessionsq

class Scenes:
    scenes = {}
    pictures = {}

    scenesstates = {}

    dmx = None
    snd = None

    args = None
    def __init__(self,largs,lsnd,ldmx):
        self.args = largs
        self.snd = lsnd
        self.dmx = ldmx

    def LoadFromDisk(self):
        # Load the scenes
        ref = "../Files/Profiles/"+self.args.profile
        fpath = ref + "/scenes.json"
        with open(fpath) as datafile:
            self.scenes = json.load(datafile)
        # Load the pictures
        ref = "../Files/Profiles/"+self.args.profile
        fpath = ref + "/pictures.json"
        with open(fpath) as datafile:
            self.pictures = json.load(datafile)
        return

    def SaveToDisk(self):
        # Save the scenes
        ref = "../Files/Profiles/"+self.args.profile
        fpath = ref + "/scenes.json"
        with open(fpath, "w") as outfile:
            json.dump(self.scenes, outfile, sort_keys=True, indent=4,ensure_ascii=False)
        # Save the pictures
        ref = "../Files/Profiles/"+self.args.profile
        fpath = ref + "/pictures.json"
        with open(fpath, "w") as outfile:
            json.dump(self.pictures, outfile, sort_keys=True, indent=4,ensure_ascii=False)

    # /cameleon/getscenelist
    def getscenelist(self):
        res = []
        for k in sorted(self.scenes):
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

    # /cameleon/getpictureslist
    def cameleon_getpictureslist(self):
        res = []
        for k in sorted(self.pictures):
            res.append( {'id':k, 'name':k})
        return {'list' : res}

    # /cameleon/createpicture/:picture
    def createpicture(self,picture):
        entry = { 'desc' :'TODO', 'list':[]}
        self.pictures[picture] = entry
        return {'res' : 'ok'}

    # /cameleon/recordpicture
    def recordpicture(self, request):
        id = request.json['picture']
        self.pictures[id]['list'] = request.json['stuff']
        self.SaveToDisk()
        return {'res':'OK'}

    # '/cameleon/loadpicture/:picture'
    def loadpicture(self,picture):
        return {'load': self.pictures[picture]}

    # /cameleon/dmxscene
    def dmxscene(self, request):
        scene = request.json['scene']
        opts = request.json['opts']

        if scene in self.scenesstates:
            state = self.scenesstates[scene]
            state = not state
            self.scenesstates[scene] = state
        else:
            state = True
            self.scenesstates[scene] = state

        # We'll get a list of machines that are used.
        pjs = self.dmx.dmxscene(self.scenes[scene]['list'],state)

        for other in self.scenes:
            if other == scene:
                # Send the event for this scene.
                evt =  {'evt': 'sceneState', 'id': scene, 'state':state}
                sessionsq.PostEvent ('dmx', evt)
            else:
                otherpslist = self.scenes[other]['list']
                for opj in otherpslist:
                    if opj['id'] in pjs:
                        # The projetor is used elsewhere, notify scene is not 'active'.
                        evt =  {'evt': 'sceneState', 'id': other, 'state':False}
                        sessionsq.PostEvent ('dmx', evt)
                        self.scenesstates[other] = False

        # Start song
        if opts['startsong'] is not "":
            sound = opts['startsong']
            if state is True:
                self.snd.snd_playSong(sound)
            else:
                self.snd.snd_stopSong(sound)
        return {'res': 'OK'}

    def dmx_panic(self):
        for scene in self.scenes:
            evt =  {'evt': 'sceneState', 'id': scene, 'state':False}
            sessionsq.PostEvent ('dmx', evt)
            if scene in self.scenesstates:
                self.scenesstates[scene] = False

    # /cameleon/getscenestate/:scene
    def getscenestate(self,scene):
        if scene in self.scenesstates:
            state = self.scenesstates[scene]
        else:
            state = False
        return {'state' : state}