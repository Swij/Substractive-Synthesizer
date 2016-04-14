import io
import os
import serial
import struct
import sys
import time
import binascii

ser = serial.Serial('COM3',baudrate=31250)
ser.flushOutput()
ser.flushInput()
state = 0
prevNote = 0

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

def binbin(bina):

	i = 7
	conv = bina
	strBin = ""
	while i >= 0:

		j = 2**i
		if (conv - j) >= 0:
			strBin += "1"
			conv -= j
		else:
			strBin += "0"

		i -= 1

	return strBin

i = 0

try:
	while True:
		a = (struct.unpack('B', ser.read(1))[0])
		#if a != 254 and a != 255:
		#	if a == 32 and state == 0: 
		#		print ("Note On")
		#		state = 1
			
		#	elif state == 1 and a != 32:	
				
			#	print ("Note is: " + str(a))

			#	prevNote = a;
			#	state = 2
		#	elif state == 2 and a == 32:
			#	print ("Note off")
			#	state = 0;
			
#elif state == 2 and a == prevNote:
				#print ("Note off")
				#state = 0;
			
			#elif state == 2: 
				#print ("Velocity is: " + str(a))
				#state = 1;
				#if i % 4 == 0:
					#print("\n")
		
		if state == 0 and a == 32:
			print ("Note On")
			state = 1
		elif state == 0 and a == prevNote:
			print("Note on")
			print("Note is: " + str(a))
			state = 2
			
		elif state == 1:
		
			print ("Note is: " + str(a))

			prevNote = a;
			state = 2
		
		#elif state == 2 and a == 32:
			
			#state = 3;
			
		elif state == 2 and a == prevNote:
		
			print("Note off")
			state = 0;
		
		elif state == 3 and (a == 0 or a == 1):

			print ("Note off")
			state = 0;
			
			
		
		
		

except KeyboardInterrupt:
    pass

print("\n\nDone")
