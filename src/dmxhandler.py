__author__ = 'xavierpouyollon'

import Queue
import threading
import time
import thread
import models

dmx_model = models.dmx_model
dmx_setting = models.dmx_setting

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
            remain -= PERIOD
            v['delay'] = remain
            newvals = v['vals']
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
            id = request.json['id']
            if id not in self.hardware:
                return

            entries = request.json['entries']

            for entry in entries:
                key = entry['key']
                val = entry['val']
                self.hardware[id]['defs'][key]=int(val)
            return

    def dmx_orig_getdefs (self,id):
        if id in self.hardware:
            with self.lock:
                datas = []
                for k in sorted(self.hardware[id]['defs']):
                    res = {"key":k, "val":self.hardware[id]['defs'][k]}
                    datas.append(res)
                return {"res":datas}

    def dmx_getdefs (self,id):
        str = "dmx_model"
        return {"res":eval(str)}

    def dmx_query(self, id, key):
        if id in self.hardware:
            with self.lock:
                dstchan = self.GetChannel(id, key)
                return {key: self.datas[dstchan]}

    def dmx_set(self, request):
        global dmx_setting
        id = request.json['id']
        if 'setting' in request.json:
            setting = request.json['setting']
            cmds = dmx_setting[setting]
        if 'cmds' in request.json:
            cmds = request.json['cmds']
        if 'transition' in request.json:
            transition = request.json['transition']
        else:
            transition = False
        if 'delay' in request.json:
            delay = int(request.json['delay']) * 1000
        else:
            delay = 0

        if id in self.hardware:
            with self.lock:
                if (transition == False):
                    for key in cmds:
                        dstchan = self.GetChannel(id, key)
                        val = int(cmds[key])
                        self.datas[dstchan] = val
                        evt = {'evt': 'update', 'id': id, 'key': key, 'val': val}
                        self.eventq.put(evt)
                    self.changed = True
                else:
                    cmds=dmx_setting[setting]
                    v= {'cmds':cmds, 'delay':delay, 'vals': {}}
                    self.transition[id] = v

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

