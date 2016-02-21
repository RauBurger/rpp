import matplotlib.pyplot as plt
import socket
#import enums 

class Command:
	Idle = -1
	Function = 0
	Data = 1
	Done = 2
	Close = 3

class Function:
	Nothing = -1
	Plot = 0
	Figure = 1
	SetupPlot = 2
	Print = 3
	Xlabel = 4
	Ylabel = 5
	Title = 6
	Subplot = 7
	Legend = 8
	Hold = 9
	Axis = 1
	Grid = 1
	Contour = 1
	Colorbar = 1
	Semilogx = 1
	Semilogy = 15
	Loglog = 16

def Plot(data):
	print('butts')

def Figure(data):
	print('in figure')
	plt.figure()
	plt.show(block=False)

def serve():

	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.bind(('127.0.0.1', 54000))
	sock.listen(0)
	(client, clientAddr) = sock.accept()
	print('got connection')
	client.send(b'\x00\xFF\xFF\xFF\xFF')
	print('sent connection bytes')
	currentPayload = 10;
	currentFunction = '';
	while 1:
		# get data from client
		data = client.recv(currentPayload)
		
		print('got data')
		
		# acknowledge client
		print('len(data) = '+str(len(data)))
		client.send(b'\x00'+int.to_bytes(4, len(data), 'little', signed=False))

		currentCommand = data[0]
		print('currentCommand = '+str(currentCommand))
		if currentCommand == Command.Function: # function command
			currentFunction = data[1]
			currentPayload = int.from_bytes(data[2:-1], 'little', signed=False)
			print('currentFunction = '+str(currentFunction))
			print('currentPayload = '+str(currentPayload))

		elif currentCommand == Command.Data: # data command
			if currentFunction == Function.Plot: # plot function
				Plot(data)
			elif currentFunction == Function.Figure: # figure function
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
