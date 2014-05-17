__author__ = 'xavierpouyollon'
# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License


import Queue
import soundmixer
import threading
import models
import requests
import sessionsq

class SoundPlayer:
    sounds = {}
    sndchannels = {}
    levels = {}
    args = None
    lock = None

    def __init__(self, args):
        self.args = args
        # Create the queue
        sessionsq.CreateQueue('snd')

        self.lock = threading.RLock()
        soundmixer.init(output_device_indexes=args.snd)
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
            sessionsq.PostEvent('snd',evt)

    def sounds_query(self,id):
        with self.lock:
            if id in self.sounds:
                playing = True
            else:
                playing = False

            sndlevel = None
            if id in self.levels:
                sndlevel = self.levels[id]

            opts = dict(models.knobs_model['snd'])
            if 'knob' in models.sounds[id]:
                    for k in models.sounds[id]['knob']:
                        opts[k] = models.sounds[id]['knob'][k]
            return {'playing':playing,
                    'level':sndlevel,
                    'defs' : models.sounds[id],
                    'knob' : opts
                    }

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
            card = request.json['card']

            # if already playing, don't start again !
            if id in self.sounds:
                print "Already playing !"
                return

            filepath =  self.args.waves + '/'  + name
            snd = soundmixer.StreamingSound(filepath,position=position,card=card)

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
            sessionsq.PostEvent('snd',evt)
            return

    def sounds_level(self, id, power):
        with self.lock:
            sndlevel = (int(power) / 100.0)
            if id in self.sounds:
                sndchn = self.sounds[id]
                sndchn.set_volume(sndlevel)

            self.levels[id] = power

    def sounds_panic(self):
        keys = self.sounds.keys()
        for id in keys:
            self.sounds_stop(id)
        return { 'res' : 'ok'}

    def sounds_events(self, request):
        #print "En attente !"
        try:
            sessionId = request.get_header('SessionId')
            evt = sessionsq.GetEvent('snd',sessionId)
        except:
            evt = None
        #print evt
        return evt

    def sound_stopped(self,sndchan):
        id = self.sndchannels[sndchan]
        self.sound_finished(id, sndchan)

    def snd_getdefs(self):
        return {"snd_setting": models.sounds}

    def snd_setdefs(self, request):
        with self.lock:
            models.sounds = request.json['snd_setting']
            return

    def snd_playSong (self, id):
        req = requests.FakeRequest()

        if id  not in models.sounds:
            return

        mdl = models.sounds[id]
        if id in self.levels:
            sndlevel = self.levels[id]
        else:
            sndlevel = mdl['defLevel']
        req.json['id'] = id
        req.json['power'] = sndlevel
        req.json['name'] = mdl['songFile']
        if 'position' in mdl:
            req.json['position'] = mdl['position']
        if 'loop' in mdl:
            req.json['repeat'] = mdl['loop']
        else:
            req.json['repeat'] = False
        if 'card' in mdl:
            req.json['card'] = mdl['card']
        self.sounds_play(req)

    def snd_stopSong(self,id):
        self.sounds_stop(id)