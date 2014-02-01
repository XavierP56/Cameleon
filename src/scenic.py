# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License

import Queue
import bottle
import swmixer2
import threading
import argparse
from bottle import route, run, request, abort, static_file

app = bottle.Bottle()
args = {}

class SoundPlayer:
    sounds = {}
    sndchannels = {}
    levels = {}
    args = None
    eventq = None
    lock = None

    def __init__(self, args):
        self.args = args
        self.eventq = Queue.Queue(0)
        self.lock = threading.RLock()

    def sound_finished(self,id, chn):
        with self.lock:
            # Remove from dictionnary
            del self.sounds[id]
            # Keep the level in case we leave / come back in the browser.
            #del levels[id]
            del self.sndchannels[chn]

            evt = {'evt': 'stop', 'id': id}
            self.eventq.put(evt)

    def sounds_query(self,id):
        with self.lock:
            if id in self.sounds:
                playing = True
            else:
                playing = False

            sndlevel = None
            if id in self.levels:
                sndlevel = self.levels[id]

            return {'playing':playing, 'level':sndlevel}

    def sounds_stop(self,id):
        with self.lock:
            if not id in self.sounds:
                return

            chn = self.sounds[id]
            chn.stop()
            self.sound_finished(id, chn)

    def sounds_play(self,request):
        with self.lock:
            id = request.json['id']
            repeat = request.json['repeat']
            name = request.json['name']
            power = request.json['power']

            # if already playing, don't start again !
            if id in self.sounds:
                print "Already playing !"
                return

            filepath =  self.args.waves + '/'  + name
            snd = swmixer2.StreamingSound(filepath)

            sndlevel = int(power) / 100.0
            self.levels[id] = power

            if (repeat == True):
                sndchan = snd.play(loops=-1,volume=sndlevel)
            else:
                sndchan = snd.play(volume=sndlevel)

            # Store in dictionnary
            self.sounds[id] = sndchan
            self.sndchannels[sndchan] = id
            # Send event.
            evt = {'evt': 'play', 'id': id}
            self.eventq.put(evt)

    def sounds_level(self, id, power):
        with self.lock:
            sndlevel = (int(power) / 100.0)
            if id in self.sounds:
                sndchn = self.sounds[id]
                sndchn.set_volume(sndlevel)

            self.levels[id] = power

    def sounds_events(self):
        #print "En attente !"
        try:
            evt = self.eventq.get(timeout=1)
        except:
            evt = None
        #print evt
        return evt

    def sound_stopped(self,sndchan):
        id = self.sndchannels[sndchan]
        self.sound_finished(id, sndchan)

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


def sound_stopped(sndchan):
    sndplayer.sound_stopped(sndchan)

# Start swmixer
parser = argparse.ArgumentParser()
parser.add_argument("-w", "--waves",help="Path to waves", default="./../Files/waves")
parser.add_argument("-s", "--snd", help="Sound card index", default=None, type=int)
args = parser.parse_args()

sndplayer = SoundPlayer(args)
swmixer2.init(output_device_index=args.snd)
swmixer2.start()
swmixer2.set_stopHandler(sound_stopped)

# Start the bottle server.
bottle.run(app, port=8080, host='0.0.0.0', server='cherrypy')

