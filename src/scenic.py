# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License

import Queue
import bottle
import swmixer2
import threading
import argparse
from bottle import route, run, request, abort, static_file

app = bottle.Bottle()
eventq = None
sounds = {}
sndchannels = {}
levels = {}
args = {}

@app.route('/sceniq/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='./../Files/')


def sound_finished(id, chn):
    global eventq
    global sounds
    global sndchannels
    global levels
    global lock

    with lock:
        # Remove from dictionnary
        del sounds[id]
        # Keep the level in case we leave / come back in the browser.
        #del levels[id]
        del sndchannels[chn]

        evt = {'evt': 'stop', 'id': id}
        eventq.put(evt)


@app.route('/sounds/query/:id', method='GET')
def sounds_query(id):
    global sounds
    global levels
    global lock

    with lock:
        if id in sounds:
            playing = True
        else:
            playing = False

        sndlevel = None
        if id in levels:
            sndlevel = levels[id]

        return {'playing':playing, 'level':sndlevel}


@app.route('/sounds/stop/:id', method='GET')
def sounds_stop(id):
    global sounds
    global lock

    with lock:
        if not id in sounds:
            return

        chn = sounds[id]
        chn.stop()
        sound_finished(id, chn)


@app.route('/sounds/play', method='POST')
def sounds_play():
    global eventq
    global sounds
    global sndchannels
    global levels
    global lock
    global args

    with lock:
        id = request.json['id']
        repeat = request.json['repeat']
        name = request.json['name']
        power = request.json['power']

        # if already playing, don't start again !
        if id in sounds:
            return

        filepath =  args.waves + '/'  + name
        snd = swmixer2.StreamingSound(filepath)

        sndlevel = int(power) / 100.0
        levels[id] = power

        if (repeat == True):
            sndchan = snd.play(loops=-1,volume=sndlevel)
        else:
            sndchan = snd.play(volume=sndlevel)

        # Store in dictionnary
        sounds[id] = sndchan
        sndchannels[sndchan] = id
        # Send event.
        evt = {'evt': 'play', 'id': id}
        eventq.put(evt)


@app.route('/sounds/level/:id/:power', method='GET')
def sounds_level(id, power):
    global sounds
    global levels
    global lock

    with lock:
        sndlevel = (int(power) / 100.0)
        if id in sounds:
            sndchn = sounds[id]
            sndchn.set_volume(sndlevel)

        levels[id] = power

@app.route('/sounds/events')
def sounds_events():
    global eventq
    #print "En attente !"
    try:
        evt = eventq.get(timeout=1)
    except:
        evt = None
    #print evt
    return evt


def sound_stopped(sndchan):
    global sndchannels

    id = sndchannels[sndchan]
    sound_finished(id, sndchan)

# Create a queue to notify a song has finished
eventq = Queue.Queue(0)
# Start swmixer
parser = argparse.ArgumentParser()
parser.add_argument("-w", "--waves",help="Path to waves", default="./../Files/waves")
parser.add_argument("-s", "--snd", help="Sound card index", default=None, type=int)
args = parser.parse_args()

swmixer2.init(output_device_index=args.snd)
swmixer2.start()
swmixer2.set_stopHandler(sound_stopped)
lock = threading.RLock()

# Start the bottle server.
bottle.run(app, port=8080, host='0.0.0.0', server='cherrypy')

