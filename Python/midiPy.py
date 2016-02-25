import io
import os
import serial
import struct
import sys
import time
import binascii

ser = serial.Serial('/dev/ttyUSB0',baudrate=31250)
ser.flushOutput()
ser.flushInput()

def bytes2int(str):
	return int(str.encode('hex'), 16)

def bytes2hex(str):
	return '0x'+str.encode('hex')

def int2bytes(i):
	h = int2hex(i)
	return hex2bytes(h)

def int2hex(i):
	return hex(i)

def hex2int(h):
	if len(h) > 1 and h[0:2] == '0x':
		h = h[2:]

	if len(h) % 2:
		h = "0" + h

	return int(h, 16)

def hex2bytes(h):
	if len(h) > 1 and h[0:2] == '0x':
		h = h[2:]

	if len(h) % 2:
		h = "0" + h

	return h.decode('hex')

i = 0

try:
	while True:

		a = (struct.unpack('B', ser.read(1))[0])
		if a != 252:

			print ("%i:\t%s = %i"%(i,hex(a),a))
			i+=1;

			if i % 4 == 0:
				print("\n")

except KeyboardInterrupt:
    pass

print("\n\nDone")