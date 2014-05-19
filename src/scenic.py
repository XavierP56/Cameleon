# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License


import bottle
import argparse
import soundplayer
import dmxhandler
import models
import sessionsq
import uuid

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

@app.route('/dmx/setfader/:fader/:setting')
def dmx_setfader(fader, setting):
    return dmxhandler.dmx_setfader(fader, setting)

# Models

@app.route('/models/getdefs')
def models_getdefs():
    dmx = dmxhandler.dmx_getdefs()
    snd = sndplayer.snd_getdefs()
    res = dict(dmx.items() + snd.items())
    return res

@app.route('/models/setdefs', method='POST')
def models_setdefs():
    dmxhandler.dmx_setdefs(request)
    sndplayer.snd_setdefs(request)
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

@app.route ('/dmx/recordsetting/:fader')
def dmx_recordsetting (fader):
    return dmxhandler.dmx_recordsetting(fader)

@app.route('/dmx/generate/:fader/:setting')
def dmx_generate (fader, setting):
    return dmxhandler.dmx_generate(fader, setting)

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
    res.append({'name': '-------'})
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

# Start swmixer
parser = argparse.ArgumentParser()
parser.add_argument("-w", "--waves",help="Path to waves", default="./../Files/waves")
parser.add_argument("-s", "--snd", help="Sound card index", default=None, nargs='+',type=int)
parser.add_argument('-d', '--dmx', help="Output to dmx device like /dev/dmx0", default=None)
parser.add_argument('-p', '--profile', help="Profile subdirectory", default="demo")
# /dev/tty.usbmodemfa121
parser.add_argument('-i', '--wireless', help="Wireless", default=None)
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

# Start the bottle server.
bottle.run(app, port=8080, host='0.0.0.0', server='cherrypy')

