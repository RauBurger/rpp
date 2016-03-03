module rpp.server.rps;

import std.concurrency;
import std.conv;
import std.socket;
import std.stdio;
import std.traits;

import core.time;

import rpp.common.utilities;
import rpp.common.enums;
import rpp.server.backend;
/+
Socket server;

static ~this()
{
	if(server is null)
	{
		server.close();
	}
}
+/
void server(ushort port)
{
	writeln("Initializing plotting backend");
	Backend.LoadBackend("plugins/libmatlabBackend.so");
	//auto server = new TcpSocket(AddressFamily.INET);
	auto server = new Socket(AddressFamily.INET, SocketType.STREAM);
	//server.blocking = false;
	//server.bind(new InternetAddress("0.0.0.0", port));
	server.bind(new InternetAddress("localhost", port));

	bool running = true;
	bool connected = false;

	ulong currentPayload = 10;
	ubyte[] data = new ubyte[currentPayload];

	server.listen(1);

	SocketSet readSet = new SocketSet;

	while(running)
	{
		Socket client;

		readSet.reset();
		readSet.add(server);

		int selectResp = 0;
		writeln("Waiting for connection");
		while((0 == server.select(readSet, null, null)) && running)
		{
			receiveTimeout(dur!"msecs"(10), (bool run){ running = run;});
		}

		if(!running)
		{
			break;
		}

		client = server.accept();
		writeln("Got connection");
		client.blocking = true;

		connected = true;

		// Acknowledge client connection
		client.send([ServerResponce.Ok, 0xFF, 0xFF, 0xFF, 0xFF]);

		Command currentCommand = Command.None;
		Function currentFunction = Function.None;

		while(connected && running)
		{
			//receiveTimeout(dur!"msecs"(-1), (bool run){ running = run;});

			data.length = currentPayload;
			ptrdiff_t resp = client.receive(data);
			if(resp == 0)
			{
				writeln("client closed, connection lost");
				connected = false;
			}

			client.send(cast(ubyte[])[0]~toUBytes(to!uint(resp)));
			currentCommand = to!Command(data[0]);

			switch(currentCommand)
			{
				case Command.Function:
					currentFunction = to!Function(data[1]);
					currentPayload = get!ulong(data[2..$]);
					break;

				case Command.Data:
					switch(currentFunction)
					{
						case Function.Plot:
							Backend.Plot!(Function.Plot)(data);
							break;

						case Function.Figure:
							Backend.Figure(data);
							break;

						case Function.SetupPlot:
							Backend.SetupPlot(data);
							break;

						case Function.Print:
							Backend.Print(data);
							break;

						case Function.Xlabel:
							Backend.TextLabel!(Function.Xlabel)(data);
							break;

						case Function.Ylabel:
							Backend.TextLabel!(Function.Ylabel)(data);
							break;

						case Function.Title:
							Backend.TextLabel!(Function.Title)(data);
							break;

						case Function.Subplot:
							Backend.Subplot(data);
							break;

						case Function.Legend:
							Backend.Legend(data);
							break;

						case Function.Hold:
							if(data[1] == 0)
							{
								Backend.Hold(false);
							}
							else if(data[1] == 1)
							{
								Backend.Hold(false);
							}
							break;

						case Function.Axis:
							Backend.Axis(data);
							break;

						case Function.Grid:
							if(data[1] == 0)
							{
								Backend.Grid(false);
							}
							else if(data[1] == 1)
							{
								Backend.Grid(false);
							}
							break;

						case Function.Contour:
							Backend.Contour!(Function.Contour)(data);
							break;

						case Function.Contourf:
							Backend.Contour!(Function.Contourf)(data);
							break;

						case Function.Contour3:
							Backend.Contour!(Function.Contour3)(data);
							break;

						case Function.Colorbar:
							Backend.Colorbar(data);
							break;

						case Function.Semilogx:
							Backend.Plot!(Function.Semilogx)(data);
							break;

						case Function.Semilogy:
							Backend.Plot!(Function.Semilogy)(data);
							break;

						case Function.Loglog:
							Backend.Plot!(Function.Loglog)(data);
							break;

						default:
							break;
					}
					currentPayload = 1;
					break;

				case Command.Done:
					currentPayload = 10;
					break;

				case Command.Close:
					writeln("closing connection");
					client.send([0, 4, 255, 89, 255]);
					client.close();
					connected = false;
					break;

				default:
					break;
			}
		}
	}

	writeln("closing server");
	server.close();
}

int main()
{
	writeln("Spawning server");
	
	Tid thread = spawn({ server(54000); });

	writeln("Press enter to exit...heh");
	readln();

	send(thread, false);
	writeln("Stopping server");
	return 0;
}