__author__ = 'xavierpouyollon'

import Queue
import threading


class DmxHandler(object):
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
        with self.lock:
            id = request.json['id']
            model = request.json['model']
            channel = int(request.json['channel'])

            obj = Ibiza(id, self)
            params = { "model" : model, "channel": channel, "obj": obj}
            if not id in self.hardware:
                self.hardware[id] = params
                obj.PostInit()
                print "Added new hardware"
            return

    def dmx_query(self, id):
        with self.lock:
            if id in self.hardware:
                obj = self.hardware[id]["obj"]
                power = obj.getPower()
                red = obj.getRed()
                green = obj.getGreen()
                blue = obj.getBlue()
                res = { "power": power, "red": red, "green": green, "blue": blue}
                return res
            else:
                return None

    def setData(self, id, rch, value):
        if id in self.hardware:
            rch -= 1
            index = self.hardware[id]['channel'] - 1
            self.datas[index + rch] = value
            return
        else:
            print 'setData: Hardware NOT HERE !'

    def getData(self, id, rch):
        if id in self.hardware:
            rch -= 1
            index = self.hardware[id]['channel'] - 1
            return self.datas[index + rch]
        else:
            print 'getData: Hardware NOT HERE !'

class Projector(object):
    dimmer = None
    red = None
    green = None
    blue = None

    def __init__(self, id, dmxhandler):
        self.id = id
        self.dmx = dmxhandler

    def setData (self, ch, value):
        self.dmx.setData (self.id, ch, value)

    def getData(self,ch):
        return self.dmx.getData (self.id, ch)

    def setPower(self, power):
        self.setData (self.dimmer, power)

    def setRed (self, value):
        self.setData (self.red, value)

    def setBlue (self, value):
        self.setData (self.blue, value)

    def setGreen (self, value):
        self.setData (self.blue, value)

    def getPower(self):
        return self.getData (self.dimmer)

    def getRed (self):
        return self.getData (self.red)

    def getGreen(self):
        return self.getData (self.green)

    def getBlue(self):
        return self.getData (self.blue)

class Ibiza(Projector):
    dimmer = 1
    red = 3
    green = 4
    blue = 5

    def __init__(self, id, dmxhandler):
        super(Ibiza, self).__init__(id, dmxhandler)

    def PostInit(self):
        self.setData (2, 0)
        self.setData (6, 0)
        self.setData (7, 0)
