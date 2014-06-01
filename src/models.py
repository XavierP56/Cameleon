# Copyright Xavier Pouyollon 2014
# GPL v3 License

# This file contains the model. Will get away in a soon future.
import json

dmx_devices = {}
dmx_setting = {}
dmx_light = {}
dmx_group = {}
dmx_fixtures = {}
sounds = {}
scenes = []

def saveModel(args):

    # Save the fixtures
    ref = "../Files/Fixtures"
    fpath = ref + "/fixtures.json"
    with open(fpath, "w") as outfile:
        json.dump(dmx_fixtures, outfile, sort_keys=True, indent=4,ensure_ascii=False)

    # Save the profiles.
    ref = "../Files/Profiles/"+args.profile

    fpath = ref + "/dmx_devices.json"
    with open(fpath, "w") as outfile:
        json.dump(dmx_devices, outfile, sort_keys=True, indent=4,ensure_ascii=False)

    fpath = ref + "/dmx_setting.json"
    with open(fpath, "w") as outfile:
        json.dump(dmx_setting, outfile, sort_keys=True, indent=4,ensure_ascii=False)

    fpath = ref + "/sounds.json"
    with open(fpath, "w") as outfile:
        json.dump(sounds, outfile, sort_keys=True, indent=4,ensure_ascii=False)


    return

def GenerateDefaultGroup():
    global dmx_group
    global dmx_devices

    for lid in dmx_devices:
        key = '_' + lid
        if not key in dmx_group:
            dmx_group[key] = [lid]

def loadModel(args):
    global dmx_devices
    global dmx_setting
    global dmx_light
    global dmx_group
    global sounds
    global knobs_model
    global dmx_fixtures

    # Load the fixtures
    ref = "../Files/Fixtures"
    fpath = ref + "/fixtures.json"
    with open(fpath) as datafile:
        dmx_fixtures = json.load(datafile)

    # Load the profile
    ref = "../Files/Profiles/"+args.profile
    fpath = ref + "/dmx_devices.json"
    with open(fpath) as datafile:
        dmx_devices = json.load(datafile)

    fpath = ref + "/dmx_setting.json"
    with open(fpath) as datafile:
        dmx_setting = json.load(datafile)

    fpath = ref + "/sounds.json"
    with open(fpath) as datafile:
        sounds = json.load(datafile)

    fpath = ref + "/knobs.json"
    with open(fpath) as datafile:
        knobs_model = json.load(datafile)

    # Generate the default group
    GenerateDefaultGroup()
    return

def loadScenes(args):
    global scenes

    ref = "../Files/Profiles/"+args.profile
    fpath = ref + "/room_model.json"
    with open(fpath) as datafile:
        scenes = json.load(datafile)

def saveScenes(args):
    global scenes

    ref = "../Files/Profiles/"+args.profile

    fpath = ref + "/room_model.json"
    with open(fpath, "w") as outfile:
        json.dump(scenes, outfile, sort_keys=True, indent=4,ensure_ascii=False)

def loadDRooms(args):
    ref = "../Files/Profiles/"+args.profile
    fpath = ref + "/drooms.json"
    with open(fpath) as datafile:
        drooms = json.load(datafile)
    return {'drooms' : drooms}

def saveDRooms(args, request):
    drooms = request.json['drooms']
    ref = "../Files/Profiles/"+args.profile
    fpath = ref + "/drooms.json"
    with open(fpath, "w") as outfile:
        json.dump(drooms, outfile, sort_keys=True, indent=4,ensure_ascii=False)