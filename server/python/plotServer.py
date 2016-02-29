#!/usr/bin/env python3

import matplotlib.pyplot as plt
import socket
import enums 
import struct
import numpy as np

numTypes = {'uint16':'<H', 'int16':'<h', 'uint32':'<L', 'int32':'<l', 'single':'<I', 'uint64':'<Q', 'int64':'<q', 'double':'<d'}

def Plot(data, func, holdOn):
	print(type(data))

	fmt = data[1]
	lines = data[2]

	dataOffset = 3
	for idx in range(lines):

		(num, dataOffset) = getNum('uint32', data, dataOffset)
		lineLen = int(num/8)
		print("lineLen = "+str(lineLen))

		x = []
		y = []

		for j in range(lineLen):
			(num, dataOffset) = getNum('double', data, dataOffset)
			x.append(num)

		for j in range(lineLen):
			(num, dataOffset) = getNum('double', data, dataOffset)
			y.append(num)

		fmtStr = ''
		if fmt == 1:
			fmtLen = data[dataOffset]
			dataOffset += 1
			
			fmtStr = data[dataOffset:dataOffset+fmtLen].decode()
			dataOffset += fmtLen

			print(fmtStr)

			plt.hold(True)

			if func == enums.Function.Plot:
					plt.plot(x, y, fmtStr);
			elif func == enums.Function.Semilogx:
					plt.semilogx(x, y, fmtStr);
			elif func == enums.Function.Semilogy:
					plt.semilogy(x, y, fmtStr);
			elif func == enums.Function.Loglog:
					plt.loglog(x, y, fmtStr);
			else:
				print("PANIC: (func not equal to plot || semilogx/y || loglog)")

			plt.show(block = False)
		else:
			plt.hold(True)

			if func == enums.Function.Plot:
					plt.plot(x, y);
			elif func == enums.Function.Semilogx:
					plt.semilogx(x, y);
			elif func == enums.Function.Semilogy:
					plt.semilogy(x, y);
			elif func == enums.Function.Loglog:
					plt.loglog(x, y);
			else:
				print("PANIC: (func not equal to plot || semilogx/y || loglog)")

			plt.show(block = False)

	if (not holdOn):
		plt.hold(False)
	else:
		plt.hold(True)


def Figure(data):
	print('in figure')
	plt.figure()
	plt.show(block=False)

def getNum(numType, data, offset):
	if (numType == 'uint16' or numType == 'int16'):
		num = struct.unpack(numTypes[numType], data[offset:offset+2])[0]
		offset = offset + 2;

	elif( numType == 'uint32' or numType == 'int32' or numType == 'single'):
		num = struct.unpack(numTypes[numType], data[offset:offset+4])[0]
		offset = offset + 4;

	elif(numType == 'uint64' or numType == 'int64' or numType == 'double'):
		num = struct.unpack(numTypes[numType], data[offset:offset+8])[0]
		offset = offset + 8

	return num, offset

def serve():

	print('Waiting for connection')

	holdOn = False;
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.bind(('127.0.0.1', 54000))
	sock.listen(0)
	(client, clientAddr) = sock.accept()
	print('got connection')
	client.send(b'\x00\xFF\xFF\xFF\xFF')
	print('sent connection bytes')
	currentPayload = 10;
	currentFunction = ''

	while 1:
		# get data from client
		data = client.recv(currentPayload)
		
		#print('got data')
		
		# acknowledge client
		#print('len(data) = '+str(len(data)))
		#print('data[0] = '+str(data[0]))
		#intBytes = int.to_bytes(4, len(data), 'little', signed=False)
		intBytes = struct.pack('<I', len(data))
		#print('intBytes = '+str(intBytes))

		print("currentPayload = "+str(currentPayload))
		clientData = b'\x00'+intBytes

		client.send(clientData)

		currentCommand = data[0]
		#print('currentCommand = '+str(currentCommand))
		if currentCommand == enums.Command.Function: # function command
			currentFunction = data[1]
			currentPayload = int.from_bytes(data[2:-1], 'little', signed=False)
			#print('currentFunction = '+str(currentFunction))
			#print('currentPayload = '+str(currentPayload))

		elif currentCommand == enums.Command.Data: # data command
			currentPayload = 1
			if currentFunction == enums.Function.Plot: # plot function
				Plot(data, enums.Function.Plot, holdOn)
			elif currentFunction == enums.Function.Semilogx:
				Plot(data, enums.Function.Semilogx, holdOn)
			elif currentFunction == enums.Function.Semilogy:
				Plot(data, enums.Function.Semilogy, holdOn)
			elif currentFunction == enums.Function.Loglog:
				Plot(data, enums.Function.Loglog, holdOn)
			elif currentFunction == enums.Function.Figure: # figure function
				Figure(data)
			elif currentFunction == enums.Function.Hold:
				if(data[1] == 1):
					plt.hold(True)
					holdOn = True
				elif(data[1] == 0):
					plt.hold(False)
					holdOn = False
		elif currentCommand == enums.Command.Done:
			currentPayload = 10

		elif currentCommand == enums.Command.Close:
			plt.show()


if __name__ == '__main__':
	''' plt.figure()
	plt.show(block=False)
	plt.plot([1,2,3,4])
	plt.show(block=False)
	plt.ylabel('some numbers')
	plt.show() '''
	serve()
