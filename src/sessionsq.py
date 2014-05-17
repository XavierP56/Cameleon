__author__ = 'xavierpouyollon'

import Queue

queues = {}

def CreateQueue(name):
    global queues
    # print 'Create queue ' + name

    queues[name] = {}
    return

def AddSession(qname, sname):
    global queues
    # print 'Adding session ' + sname + ' for ' + qname
    queues[qname][sname] = Queue.Queue(0)

def PostEvent (qname, evt):
    global queues
    for sname in queues[qname]:
        queues[qname][sname].put(evt)

def GetEvent(qname, sname):
    global queues
    # print 'Getting for queue ' + qname + 'session sname'
    try:
        evt = queues[qname][sname].get(timeout=10)
    except:
        evt = None
    # print 'Get done'
    return evt
