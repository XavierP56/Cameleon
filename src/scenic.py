# Copyright Xavier Pouyollon 2013
# GPL v3 License

import Queue
import bottle
import swmixer2
from bottle import route, run, request, abort, static_file

app = bottle.Bottle()
eventq = None
sounds = {}
sndchannels = {}
levels = {}

@app.route('/sceniq/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='./../Files/')


def sound_finished(id, chn):
    global eventq
    global sounds
    global sndchannels
    global levels

    # Remove from dictionnary
    del sounds[id]
    #del levels[id]
    del sndchannels[chn]

    evt = {'evt': 'stop', 'id': id}
    eventq.put(evt)


@app.route('/sounds/query/:id', method='GET')
def sounds_query(id):
    global sounds
    global levels

    if id in sounds:
        playing = True
    else:
        playing = False

    sndlevel = 1.0
    if id in levels:
        sndlevel = levels[id]

    print sndlevel

    return {'playing':playing, 'level':sndlevel}


@app.route('/sounds/stop/:id', method='GET')
def sounds_stop(id):
    global sounds

    print 'Stopping sound' + str(id)
    chn = sounds[id]
    chn.stop()
    sound_finished(id, chn)


@app.route('/sounds/play', method='POST')
def sounds_play():
    global eventq
    global sounds
    global sndchannels
    global levels

    id = request.json['id']
    repeat = request.json['repeat']
    name = request.json['name']
    power = request.json['power']

    print 'Playing sound' + str(id) + " " + name
    filepath = './../Files/waves/' + name
    snd = swmixer2.Sound(filepath)

    sndlevel = int(power) / 100.0
    levels[id] = sndlevel

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

    print "Power" + str(id) + " " + str(power)
    sndlevel = (int(power) / 100.0)
    if id in sounds:
        sndchn = sounds[id]
        sndchn.set_volume(sndlevel)

    levels[id] = sndlevel

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

    print "Sound stopped !"
    print sndchan
    id = sndchannels[sndchan]
    print id
    sound_finished(id, sndchan)

# Create a queue to notify a song has finished
eventq = Queue.Queue(0)
# Start swmixer
swmixer2.init()
swmixer2.start()
swmixer2.set_stopHandler(sound_stopped)

# Start the bottle server.
bottle.run(app, port=8080, server='cherrypy')

