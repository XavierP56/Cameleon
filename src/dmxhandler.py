__author__ = 'xavierpouyollon'
# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License


import Queue
import threading
import time
import thread
import models

dmx_model = models.dmx_model
dmx_setting = models.dmx_setting
dmx_light = models.dmx_light

# This is where the DMX lighting setup is defined.


PERIOD = 10

class DmxHandler(object):
    args = None
    eventq = None
    lock = None
    datas = [0] * 513
    hardware = {}
    transition = {}
    gthread = None
    changed = False
    dmxoutput = None


    def __init__(self, args):
        self.args = args
        self.eventq = Queue.Queue(0)
        self.lock = threading.RLock()

        if self.args.dmx:
            self.dmxoutput = open('/dev/dmx0', 'wb')

        def f():
            while True:
                self.tick()
                time.sleep(float(PERIOD) / 1000)

        self.gthread = thread.start_new_thread(f, ())
        # Init the model
        global dmx_model
        for id in dmx_model:
            self.hardware[id] = dmx_model[id]
            for key in dmx_model[id]['inits']:
                dstchan = self.GetChannel(id, key)
                val = int(dmx_model[id]['inits'][key])
                self.datas[dstchan] = val

    def handle_transition(self):
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
                    self.eventq.put(evt)
                self.changed = True

            if (remain == 0):
                print "Removing transition !"
                del self.transition[t]
                return

    def tick(self):
        # Handle the DMX transition.
        self.handle_transition()

        if (self.args.dmx == False):
            return
        if (self.changed == False):
            return

        self.dmxoutput.write(bytearray(self.datas))
        self.changed = False
        self.dmxoutput.flush()

    def dmx_setdefs(self, request):
        with self.lock:
            global dmx_model
            global dmx_setting
            global dmx_light

            dmx_model = request.json['dmx_model']
            dmx_setting = request.json['dmx_setting']
            dmx_light = request.json['dmx_light']
            return

    def dmx_getdefs (self):
        return {"dmx_model":dmx_model,
                "dmx_setting": dmx_setting,
                "dmx_light": dmx_light}

    def dmx_query(self, id, key):
        if id in self.hardware:
            with self.lock:
                dstchan = self.GetChannel(id, key)
                return {key: self.datas[dstchan]}

    def dmx_light(self,id):
        if id in dmx_light:
            return {'light':dmx_light[id]}

    def dmx_set(self, request):
        global dmx_setting
        id = request.json['id']
        if 'setting' in request.json:
            setting = request.json['setting']
            cmds = dmx_setting[setting]
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

        if id in self.hardware:
            with self.lock:
                if ((transition == "True") and (delay >0)):
                    cmds=dmx_setting[setting]
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
                        self.eventq.put(evt)
                    self.changed = True

            if (setting != None):
                evt = { "evt": "activeLight", "id": id, "setting": setting }
                self.eventq.put(evt)

    # Services routines
    def GetChannel(self, id, key):
        hw = self.hardware[id]
        channel = int(hw['channel']) - 1
        relch = int(hw['defs'][key])
        dstchan = channel + relch
        return dstchan

    def dmx_events(self):
        #print "En attente !"
        try:
            evt = self.eventq.get(timeout=1)
        except:
            evt = None
        return evt

