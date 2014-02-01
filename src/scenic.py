# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License


import bottle
import argparse
import soundplayer

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


# Start swmixer
parser = argparse.ArgumentParser()
parser.add_argument("-w", "--waves",help="Path to waves", default="./../Files/waves")
parser.add_argument("-s", "--snd", help="Sound card index", default=None, type=int)
args = parser.parse_args()

sndplayer = soundplayer.SoundPlayer(args)

# Start the bottle server.
bottle.run(app, port=8080, host='0.0.0.0', server='cherrypy')

