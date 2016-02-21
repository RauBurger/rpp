#!/usr/bin/env python3

import matplotlib.pyplot as plt
import socket
import enums 

def Plot(data):
	print('butts')

def Figure(data):
	print('in figure')
	plt.figure()
	plt.show(block=False)

def serve():

	print('Waiting for connection')

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
		
		print('got data')
		
		# acknowledge client
		print('len(data) = '+str(len(data)))
		client.send(b'\x00'+int.to_bytes(4, len(data), 'little', signed=False))

		currentCommand = data[0]
		print('currentCommand = '+str(currentCommand))
		if currentCommand == enums.Command.Function: # function command
			currentFunction = data[1]
			currentPayload = int.from_bytes(data[2:-1], 'little', signed=False)
			print('currentFunction = '+str(currentFunction))
			print('currentPayload = '+str(currentPayload))

		elif currentCommand == enums.Command.Data: # data command
			if currentFunction == enums.Function.Plot: # plot function
				Plot(data)
			elif currentFunction == enums.Function.Figure: # figure function
				Figure(data)



		#print(data)


if __name__ == '__main__':
	''' plt.figure()
	plt.show(block=False)
	plt.plot([1,2,3,4])
	plt.show(block=False)
	plt.ylabel('some numbers')
	plt.show() '''
	serve()
