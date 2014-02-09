__author__ = 'xavierpouyollon'

import Queue
import threading
import time
import thread

# This is where the DMX lighting setup is defined.

dmx_model = {
    "1": {"channel": 1,
          "defs": {
              "dimmer": 1,
              "red": 3,
              "green": 4,
              "blue": 5
          },
          "inits": {
              "dimmer": 255,
              "red": 255,
              "green": 254,
              "blue": 253
          }
    }
}

class DmxHandler(object):
    args = None
    eventq = None
    lock = None
    datas = [0] * 513
    hardware = {}
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
                time.sleep(0.01)

        self.gthread = thread.start_new_thread(f, ())
        # Init the model
        global dmx_model
        for id in dmx_model:
            self.hardware[id] = dmx_model[id]
            for key in dmx_model[id]['inits']:
                dstchan = self.GetChannel(id, key)
                val = int(dmx_model[id]['inits'][key])
                self.datas[dstchan] = val

    def tick(self):
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

    def dmx_getdefs (self,id):
        if id in self.hardware:
            with self.lock:
                datas = []
                for k in sorted(self.hardware[id]['defs']):
                    res = {"key":k, "val":self.hardware[id]['defs'][k]}
                    datas.append(res)
                return {"res":datas}

    def dmx_query(self, id, key):
        if id in self.hardware:
            with self.lock:
                dstchan = self.GetChannel(id, key)
                return {key: self.datas[dstchan]}

    def dmx_set(self, request):
        id = request.json['id']
        cmds = request.json['cmds']
        if id in self.hardware:
            with self.lock:
                for key in cmds:
                    dstchan = self.GetChannel(id, key)
                    val = int(cmds[key])
                    self.datas[dstchan] = val
                    evt = {'evt': 'update', 'id': id, 'key': key, 'val': val}
                    self.eventq.put(evt)
                self.changed = True

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

