__author__ = 'xavierpouyollon'

import Queue
import threading
import time
import thread

class DmxHandler(object):
    args = None
    eventq = None
    lock = None
    datas = [None]*513
    hardware = {}
    gthread = None
    changed = False
    dmxoutput = None

    def __init__(self, args):
        self.args = args
        self.eventq = Queue.Queue(0)
        self.lock = threading.RLock()

        if self.args.dmx:
            self.dmxoutput = open ('/dev/dmx0', 'wb')

        def f():
            while True:
                self.tick()
                time.sleep(0.01)
        self.gthread = thread.start_new_thread(f, ())

    def tick(self):
        if (self.args.dmx == False):
            return
        if (self.changed == False):
            return

        datas = []
        for a in self.datas:
            if a == None:
                datas.append(0)
            else:
                datas.append(a)
        self.dmxoutput.write(bytearray(datas))
        self.changed = False
        self.dmxoutput.flush()
        
    def dmx_entry(self, request):
        with self.lock:
            id = request.json['id']
            defs = request.json['defs']
            inits = request.json['inits']
            channel = int(request.json['channel'])

            params = { "channel": channel, "defs": defs}
            # If we got it, delete it first.
            if  id in self.hardware:
                del self.hardware[id]
                print "Deleted current config !"
            # Store it with it's default values.
            self.hardware[id] = params
            # Init to the default values.
            for key in inits:
                dstchan = self.GetChannel(id, key)
                val = int(inits[key])
                self.datas[dstchan] = val
            print "Added new hardware"
            return

    def dmx_query(self, id, key):
        if id in self.hardware:
            with self.lock:
                dstchan = self.GetChannel(id, key)
                return {'val':self.datas[dstchan]}

    def dmx_set(self, request):
        id = request.json['id']
        cmds = request.json['cmds']
        if id in self.hardware:
            with self.lock:
                for key in cmds:
                    dstchan = self.GetChannel(id, key)
                    val = int(cmds[key])
                    self.datas[dstchan] = val
                    evt = {'evt': 'update', 'id': id, 'key':key, 'val':val}
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

