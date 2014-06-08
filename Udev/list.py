import sys
import pyaudio

## index the devices in the system

p = pyaudio.PyAudio()
count = p.get_device_count()
devices = []
for i in range(count):
    devices.append(p.get_device_info_by_index(i))

soundstr = '-s'
for i, dev in enumerate(devices):
    print "%d - %s" % (i, dev['name'])
    if '(hw:25,0)' in dev['name']:
		soundstr += ' ' + str(i) 
    if '(hw:26,0)' in dev['name']:
		soundstr += ' ' + str(i) 
    if '(hw:27,0)' in dev['name']:
		soundstr += ' ' + str(i) 
    if '(hw:28,0)' in dev['name']:
		soundstr += ' ' + str(i) 
print soundstr
