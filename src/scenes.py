__author__ = 'xavierpouyollon'

import json

scenes = {}

args = None

def Init(largs):
    global args

    args = largs

def LoadFromDisk():
    global args
    global scenes
    # Save the scenes
    ref = "../Files/Profiles/"+args.profile
    fpath = ref + "/scenes.json"
    with open(fpath) as datafile:
        scenes = json.load(datafile)
    return

def SaveToDisk():
    global args
    # Save the scenes
    ref = "../Files/Profiles/"+args.profile
    fpath = ref + "/scenes.json"
    with open(fpath, "w") as outfile:
        json.dump(scenes, outfile, sort_keys=True, indent=4,ensure_ascii=False)

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
    SaveToDisk()
    return {'res':'OK'}

# /cameleon/loadscene/:scene
def loadscene(scene):
    global scenes

    list = scenes[scene]['list']
    return {'load': scenes[scene]}