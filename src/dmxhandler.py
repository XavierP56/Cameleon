__author__ = 'xavierpouyollon'
# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License


import sessionsq
import threading
import time
import thread
import models
import serial
import requests

# This is where the DMX lighting setup is defined.

PERIOD = 100



class DmxHandler(object):
    args = None
    eventq = None
    lock = None
    datas = [0] * 513
    sent = [0] * 513
    hardware = {}
    transition = {}
    gthread = None
    changed = False
    dmxoutput = None
    activeGroup = {}

    def transition_thread(self):
        while True:
            # Handle the DMX transition.
            self.handle_transition()
            time.sleep(float(PERIOD) / 1000)

    def dmx_thread(self):
        while True:
            self.dmxCond.acquire()
            # print 'DMX Acquire'
            if (self.changed == False ):
                self.dmxCond.wait()
            if (self.dmxFull is True):
                self.flushDmxFull()
            else:
                self.flushDmxPartial()
            # print 'DMX Release'
            self.changed = False
            self.dmxCond.release()

    def __init__(self, args, sndplayer):
        self.args = args
        # Create the queue
        sessionsq.CreateQueue('dmx')
        self.lock = threading.RLock()
        self._changed = False

        self.dmxoutput = None
        self.dmxFull = None
        self.sndplayer = sndplayer

        if self.args.dmx and self.args.wireless is None:
            print "DMX on wire"
            self.dmxoutput = open('/dev/dmx0', 'wb')
            self.dmxFull = True

        if self.args.wireless is not None:
            print 'DMX on arduino'
            self.dmxoutput = serial.Serial(port=self.args.wireless, baudrate=115200)
            self.dmxFull = False

        self.dmxCond = threading.Condition()

        if (self.dmxoutput is  not None):
            self.tr_thread = thread.start_new_thread(self.transition_thread, ())
            self.dm_thread = thread.start_new_thread(self.dmx_thread, ())

        # Init the model
        for id in models.dmx_model:
            models.dmx_model[id] = models.dmx_model[id]
            for key in models.dmx_model[id]['inits']:
                dstchan = self.GetChannel(id, key)
                val = int(models.dmx_model[id]['inits'][key])
                self.datas[dstchan] = val

    def handle_transition(self):
        with self.lock:
            for t in self.transition:
                v=self.transition[t]
                remain = v['delay']
                if (remain > 0):
                    remain -= PERIOD
                v['delay'] = remain
                cmds = v['cmds']
                vals = v['vals']
                id = t

                for key in cmds:
                    dstchan = self.GetChannel(id, key)
                    curval = self.datas[dstchan]
                    if key not in vals:
                        vals[key] = curval

                    divider = remain / PERIOD
                    dstval = int(cmds[key])
                    if divider != 0:
                        incr = float(dstval - curval) / float(divider)
                    else:
                        incr = 0
                    vals[key] = curval + incr
                    val = int(vals[key])
                    self.datas[dstchan] = val
                    if (remain % 500) == 0:
                        evt = {'evt': 'update', 'id': id, 'key': key, 'val': val}
                        sessionsq.PostEvent('dmx',evt)
                    self.changed = True

                if (remain == 0):
                    print "Removing transition !"
                    del self.transition[t]
                    return


    @property
    def changed(self):
        return self._changed

    @changed.setter
    def changed(self, v):
        self.dmxCond.acquire()
        self._changed = v
        if (v is True):
            self.dmxCond.notify()
        self.dmxCond.release()

    # Flush DMX in fullmode.
    def flushDmxFull(self):
        if (self.args.dmx == False):
            return
        if (self.changed == False):
            return

        self.dmxoutput.write(bytearray(['F']))
        self.dmxoutput.write(bytearray(self.datas[1:]))
        self.dmxoutput.flush()
        self.changed = False

    # Flush DMX in small trunck
    def flushDmxTrunk(self, start):
        base = int(start / 8)
        index = base * 8
        self.dmxoutput.write(bytearray(['P',base]))
        self.dmxoutput.write(bytearray(self.datas[index:index+8]))
        self.dmxoutput.flush()
        self.sent[index:index+8] = self.datas[index:index+8]
        self.changed = False

    def flushDmxPartial(self):
        if (self.args.dmx == False):
            return
        if (self.changed == False):
            return

        loopagain = True
        while (loopagain):
            different = False
            for v in range(1,513):
                if (self.datas[v] != self.sent[v]):
                    # Flush a trunck from v.
                    self.flushDmxTrunk (v)
                    different = True
                    break
            # if different, loop again
            loopagain = different


    def dmx_setdefs(self, request):
        with self.lock:
            models.dmx_model = request.json['dmx_model']
            models.dmx_setting = request.json['dmx_setting']
            models.dmx_light = request.json['dmx_light']
            return

    def dmx_getdefs (self):
        return {"dmx_model":models.dmx_model,
                "dmx_setting": models.dmx_setting,
                "dmx_light": models.dmx_light}

    def dmx_query(self, id, key):
        if id in models.dmx_model:
            with self.lock:
                dstchan = self.GetChannel(id, key)
                opts = dict(models.knobs_model['dmx'])
                if key in models.dmx_model[id]['knobs']:
                    for k in models.dmx_model[id]['knobs'][key]:
                        opts[k] = models.dmx_model[id]['knobs'][key][k]
                return {key: self.datas[dstchan],
                        'knob' : opts}

    def dmx_light(self,light):
        if light in models.dmx_light:
            l = models.dmx_light[light]
            # Is it a metagroup button ?
            if 'list' in l:
                return {'light':models.dmx_light[light], 'active':False}
            # Normal light button.
            grp = l['group']
            active = False
            if grp in self.activeGroup:
                if self.activeGroup[grp] == light:
                    active = True
            return {'light':models.dmx_light[light], 'active':active}

    def dmx_faders(self,id):
        l = []
        defs = models.dmx_model[id]["defs"]
        sort = sorted(defs.items(), key=lambda x: x[1])
        for e in sort:
            l.append({"id" : id, "name" : e[0], "key" : e[0]})
        return  {"res":l}

    def dmx_set(self, request):
        id = request.json['id']
        if 'setting' in request.json:
            setting = request.json['setting']
            cmds = models.dmx_setting[setting]
        else:
            setting = None
        if 'cmds' in request.json:
            cmds = request.json['cmds']
        if 'transition' in request.json:
            transition = request.json['transition']
        else:
            transition = "False"
        if 'delay' in request.json:
            delay = int(request.json['delay']) * 1000
        else:
            delay = 0

        if id in models.dmx_model:
            with self.lock:
                if ((transition == "True") and (delay >0)):
                    cmds=models.dmx_setting[setting]
                    v= {'cmds':cmds, 'delay':delay, 'vals': {}}
                    self.transition[id] = v
                else:
                    if id in self.transition:
                        del self.transition[id]
                    for key in cmds:
                        dstchan = self.GetChannel(id, key)
                        val = int(cmds[key])
                        self.datas[dstchan] = val
                        evt = {'evt': 'update', 'id': id, 'key': key, 'val': val}
                        sessionsq.PostEvent('dmx',evt)
                    self.changed = True


    def dmx_setonelight (self, light):
        if light in models.dmx_light:
            l = models.dmx_light[light]
            grp = l['group']
            mdls = models.dmx_group[grp]
            for mdl in mdls:
                request = requests.FakeRequest()
                request.json['id'] = mdl
                request.json['setting'] = l['setting']
                if 'transition' in l:
                    request.json['transition'] = l['transition']
                self.dmx_set(request)

            # Music maestro !
            if 'sounds_start' in l:
                for sound in l['sounds_start']:
                    self.sndplayer.snd_playSong(sound)
            # Music stop !
            if 'sounds_stop' in l:
                for sound in l['sounds_stop']:
                    self.sndplayer.snd_stopSong(sound)

            self.activeGroup[grp] = light
            # And send active light event
            evt = { "evt": "activeLight", "light": light, "group":grp}
            sessionsq.PostEvent('dmx',evt)

    def dmx_setlight (self, light):
        if light in models.dmx_light:
            l = models.dmx_light[light]
            if 'list' in l:
                print 'Meta button'
                for l in l['list']:
                    self.dmx_setonelight(l)
            else:
                # Simple light.
                self.dmx_setonelight(light)

    # Services routines
    def GetChannel(self, id, key):
        hw = models.dmx_model[id]
        channel = int(hw['channel']) - 1
        relch = int(hw['defs'][key])
        dstchan = channel + relch
        return dstchan

    def dmx_events(self,request):
        try:
            sessionId = request.get_header('SessionId')
            evt = sessionsq.GetEvent('dmx',sessionId)
        except:
            evt = None
        #print evt
        return evt

