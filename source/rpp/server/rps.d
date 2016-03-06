module rpp.server.rps;

import std.concurrency;
import std.conv;
import std.range;
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
	server.blocking = false;
	//server.bind(new InternetAddress("0.0.0.0", port));
	server.bind(new InternetAddress("0.0.0.0", port));

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
			"hey".writeln;
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
		ubyte[5] respData = [ServerResponce.Ok, 0xFF, 0xFF, 0xFF, 0xFF];
		client.send(respData);

		Command currentCommand = Command.None;
		Function currentFunction = Function.None;

		while(connected && running)
		{
			data.length = currentPayload;
			ptrdiff_t resp = client.receive(data);
			if(resp == 0)
			{
				writeln("client closed, connection lost");
				connected = false;
			}

			while(resp != currentPayload)
			{
				resp += client.receive(data[resp..$]);
			}

			respData = chain(cast(ubyte[])[0], cast(ubyte[])toUBytes(to!uint(cast(ulong)resp))).array;
			client.send(respData);
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
								Backend.Hold(true);
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
								Backend.Grid(true);
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
					respData = [0, 4, 255, 89, 255];
					client.send(respData);
					client.shutdown(SocketShutdown.BOTH);
					client.close();
					connected = false;
					currentPayload = 10;
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

	//server(54000);
	writeln("Press enter to exit...heh");
	readln();
	/+
	while(true)
	{
		string str = readln();
		writeln(str);
	}
	+/
	send(thread, false);
	//writeln("Stopping server");
	
	return 0;
	
}