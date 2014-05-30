# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License


import bottle
import argparse
import soundplayer
import dmxhandler
import models
import sessionsq
import uuid
import scenes

from bottle import route, run, request, abort, static_file

app = bottle.Bottle()
args = {}

sessionId = 0

# Sound handling

@app.route('/sceniq/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='./../Files/')

@app.route('/profiles/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='./../Files/Profiles/'+args.profile)

@app.route('/sounds/query/:id', method='GET')
def sound_query(id):
    return sndplayer.sounds_query(id)

@app.route('/sounds/stop/:id', method='GET')
def sounds_stop(id):
    return sndplayer.sounds_stop(id)

@app.route('/sounds/play', method='POST')
def sounds_play():
    return sndplayer.sounds_play(request)

@app.route('/sounds/level/:id/:power', method='GET')
def sounds_level(id, power):
    return sndplayer.sounds_level(id, power)

@app.route('/sounds/panic')
def sounds_panic():
    return sndplayer.sounds_panic()

@app.route('/sounds/events', method='POST')
def sounds_events():
    return sndplayer.sounds_events(request)

# DMX handling
@app.route('/dmx/light/:id')
def dmx_light(id):
   return dmxhandler.dmx_light(id)

@app.route('/dmx/query/:id/:name', method='GET')
def dmx_query(id,name):
    return dmxhandler.dmx_query(id,name)

@app.route('/dmx/set', method='POST')
def dmx_set():
    return dmxhandler.dmx_set(request)

@app.route('/dmx/setLight/:light', method='GET')
def dmx_set(light):
    return dmxhandler.dmx_setlight(light)

@app.route('/dmx/faders/:id')
def dmx_faders(id):
    return dmxhandler.dmx_faders(id)

@app.route('/dmx/getfaderlist')
def dmx_getfaderlist():
    return dmxhandler.dmx_faders_list()

@app.route('/dmx/setfader', method='POST')
def dmx_setfader():
    return dmxhandler.dmx_setfader(request)

@app.route('/dmx/panic')
def dmx_panic():
    return dmxhandler.dmx_panic()

# Models

@app.route('/models/getdefs', method='POST')
def models_getdefs():
    dmx = dmxhandler.dmx_getdefs()
    snd = sndplayer.snd_getdefs()
    fixtures = { 'dmx_fixtures' : models.dmx_fixtures}
    res = dict(dmx.items() + snd.items() + fixtures.items())
    return res

@app.route('/models/setdefs', method='POST')
def models_setdefs():
    dmxhandler.dmx_setdefs(request)
    sndplayer.snd_setdefs(request)
    models.dmx_fixtures = request.json['dmx_fixtures']
    return

@app.route('/models/save')
def models_save():
    models.saveModel(args)

@app.route('/models/scenes')
def models_scenes():
    models.loadScenes(args)
    return {'scenes':models.scenes}

@app.route('/dmx/events', method='POST')
def dmx_events():
    return dmxhandler.dmx_events(request)

@app.route ('/dmx/recordsetting/:fader/:setname')
def dmx_recordsetting (fader,setname):
    return dmxhandler.dmx_recordsetting(fader,setname)

@app.route ('/dmx/recordsetting/:fader')
def dmx_recordsetting1 (fader):
    return dmxhandler.dmx_recordsetting(fader,'')

@app.route('/dmx/generate/:fader/:setting/:prefix')
def dmx_generate (fader, setting,prefix):
    return dmxhandler.dmx_generate(fader, setting, prefix)

@app.route('/scenic/newsession')
def newsession():
    sessionId = uuid.uuid1()
    sName = 's' + str(sessionId)
    print 'New session id ' + sName

    sessionsq.AddSession('snd', sName)
    sessionsq.AddSession('dmx', sName)
    return {'id' : sName}

@app.route('/cfg/getsettinglist')
def cfg_getsettinglist():
    res = []
    for s in sorted(models.dmx_setting):
        v = {'name':s}
        res.append(v)
    return {'settings': res}

@app.route('/cfg/reloadprofiles')
def cfg_reloadprofiles():
    try:
        models.loadModel(args)
    except:
        print 'Load model failed'

@app.route('/models/saveDrooms', method='POST')
def models_savedrooms():
    models.saveDRooms(args,request)

@app.route('/models/loadDrooms')
def models_loaddrooms():
    return models.loadDRooms(args)

#
# Cameleon
#

@app.route('/cameleon/getscenelist')
def cameleon_getscenelist():
    return scenes.getscenelist()

@app.route('/cameleon/createscene/:scene')
def cameleon_createscene(scene):
    return scenes.createscene(scene)

@app.route('/cameleon/recordscene', method='POST')
def cameleon_recordscene():
    return scenes.recordscene(request)

@app.route('/cameleon/loadscene/:scene')
def cameleon_loadscene(scene):
    return scenes.loadscene(scene)

@app.route('/cameleon/getpictureslist')
def cameleon_getpictureslist():
    return scenes.cameleon_getpictureslist()

@app.route('/cameleon/createpicture/:picture')
def cameleon_createpicture(picture):
    return scenes.createpicture(picture)

@app.route('/cameleon/recordpicture', method='POST')
def cameleon_recordpicture():
    return scenes.recordpicture(request)

@app.route('/cameleon/loadpicture/:picture')
def cameleon_loadpicture(picture):
    return scenes.loadpicture(picture)

@app.route('/cameleon/getsoundlist')
def cameleon_getsoundlist():
    return sndplayer.getsoundlist()

# Start swmixer
parser = argparse.ArgumentParser()
parser.add_argument("-w", "--waves",help="Path to waves", default="./../Files/waves")
parser.add_argument("-s", "--snd", help="Sound card index", default=None, nargs='+',type=int)
parser.add_argument('-d', '--dmx', help="Output to dmx device like /dev/dmx0", default=None)
parser.add_argument('-p', '--profile', help="Profile subdirectory", default="demo")
# /dev/tty.usbmodemfa121
parser.add_argument('-i', '--wireless', help="Wireless", default=None)
parser.add_argument('-v', '--view', help="View DMX frame", default=False,type=bool)
args = parser.parse_args()

try:
    models.loadModel(args)
except:
    print 'Load model failed'

try:
    models.loadScenes(args)
except:
    print 'Load Scenes failed'

sndplayer = soundplayer.SoundPlayer(args)
dmxhandler = dmxhandler.DmxHandler(args, sndplayer)
scenes = scenes.Scenes(args,sndplayer,dmxhandler)
try:
    scenes.LoadFromDisk()
except:
    pass

# Start the bottle server.
bottle.run(app, port=8080, host='0.0.0.0', server='cherrypy')

