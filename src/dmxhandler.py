__author__ = 'xavierpouyollon'

import Queue
import threading

class DmxHandler:
    args = None
    eventq = None
    lock = None
    datas = [0]*512
    hardware = {}

    def __init__(self, args):
        self.args = args
        self.eventq = Queue.Queue(0)
        self.lock = threading.RLock()

    def dmx_entry(self, request):
        id = request.json['id']
        model = request.json['model']
        channel = request.json['channel']

        params = { "model" : model, "channel": channel}
        if not id in self.hardware:
            self.hardware[id] = params
            print "Added new hardware"
        return

    def dmx_query(self, id):
        return