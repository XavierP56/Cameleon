__author__ = 'xavierpouyollon'
# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License


import Queue
import threading
import time
import thread
import models
import serial

# This is where the DMX lighting setup is defined.

PERIOD = 100

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
    activeSetting = {}

    def transition_thread(self):
        while True:
            # Handle the DMX transition.
            self.handle_transition()
            time.sleep(float(PERIOD) / 1000)

    def dmx_thread(self):
        while True:
            self.dmxEvent.wait()
            self.flushDmx()

    def __init__(self, args):
        self.args = args
        self.eventq = Queue.Queue(0)
        self.lock = threading.RLock()

        if self.args.dmx:
            # self.dmxoutput = open('/dev/dmx0', 'wb')
            print 'DMX sur arduino'
            self.dmxoutput = serial.Serial(port='/dev/tty.usbmodemfa121', baudrate=115200)




        self.dmxEvent = threading.Event()
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
                        self.eventq.put(evt)
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
        self._changed = v
        self.dmxEvent.set()

    def flushDmx(self):
        if (self.args.dmx == False):
            return
        if (self.changed == False):
            return

        self.dmxoutput.write(bytearray(self.datas))
        self.changed = False
        #print 'Ecrit' + str(len(self.datas))
        self.dmxoutput.flush()
        self.dmxEvent.clear()

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
                return {key: self.datas[dstchan]}

    def dmx_light(self,id):
        if id in models.dmx_light:
            pid = models.dmx_light[id]['id']
            if pid in self.activeSetting:
                setting = self.activeSetting[pid]
            else:
                setting = None
            return {'light':models.dmx_light[id], 'setting':setting}

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
            self.activeSetting[id] = setting
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
                        self.eventq.put(evt)
                    self.changed = True

            if (setting != None):
                evt = { "evt": "activeLight", "id": id, "setting": setting }
                self.eventq.put(evt)

    # Services routines
    def GetChannel(self, id, key):
        hw = models.dmx_model[id]
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

