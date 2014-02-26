# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License


import bottle
import argparse
import soundplayer
import dmxhandler
import models

from bottle import route, run, request, abort, static_file

app = bottle.Bottle()
args = {}


# Sound handling

@app.route('/sceniq/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='./../Files/')

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

@app.route('/sounds/events')
def sounds_events():
    return sndplayer.sounds_events()

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

@app.route('/models/getdefs')
def models_getdefs():
    dmx = dmxhandler.dmx_getdefs()
    snd = sndplayer.snd_getdefs()
    res = dict(dmx.items() + snd.items())
    return res

@app.route('/models/setdefs', method='POST')
def models_setdefs():
    dmxhandler.dmx_setdefs(request)
    sndplayer.dmx_setdefs(request)
    return

@app.route('/models/save')
def models_save():
    models.saveModel()

@app.route('/dmx/events')
def dmx_events():
    return dmxhandler.dmx_events()

# Start swmixer
parser = argparse.ArgumentParser()
parser.add_argument("-w", "--waves",help="Path to waves", default="./../Files/waves")
parser.add_argument("-s", "--snd", help="Sound card index", default=None, nargs='+',type=int)
parser.add_argument('-d', '--dmx', help="Output to /dev/dmx0", default=False, type=bool)
args = parser.parse_args()

try:
    models.loadModel()
    models.loadScenes()
    print models.scenes
except:
    models.saveModel()
    models.saveScenes()

sndplayer = soundplayer.SoundPlayer(args)
dmxhandler = dmxhandler.DmxHandler(args)

# Start the bottle server.
bottle.run(app, port=8080, host='0.0.0.0', server='cherrypy')

