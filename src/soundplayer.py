__author__ = 'xavierpouyollon'

import Queue
import soundmixer
import threading

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
        soundmixer.init(output_device_index=args.snd)
        soundmixer.start()
        soundmixer.set_stopHandler(self.sound_stopped)

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
            position = request.json['position']

            # if already playing, don't start again !
            if id in self.sounds:
                print "Already playing !"
                return

            filepath =  self.args.waves + '/'  + name
            snd = soundmixer.StreamingSound(filepath,position=position)

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
