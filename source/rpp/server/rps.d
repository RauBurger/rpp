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
	auto server = new TcpSocket(AddressFamily.INET);
	server.blocking = false;
	server.bind(new InternetAddress(port));

	bool running = true;
	bool connected = false;

	ulong currentPayload = 10;
	ubyte[] data = new ubyte[currentPayload];

	server.listen(1);

	while(running)
	{
		Socket client;

		writeln("Waiting for connection");
		while((client is null) && running)
		{
			client = server.accept();
			receiveTimeout(dur!"msecs"(-1), (bool run){ running = run;});	
		}
		writeln("Got connection");
		client.blocking = true;

		connected = true;

		// Acknowledge client connection
		client.send([ServerResponce.Ok, 0xFF, 0xFF, 0xFF, 0xFF]);

		Command currentCommand = Command.None;
		Function currentFunction = Function.None;

		while(connected && running)
		{
			receiveTimeout(dur!"msecs"(-1), (bool run){ running = run;});

			ptrdiff_t resp = client.receive(data);
			if(resp == 0)
			{
				writeln("server closed, connection lost");
				connected = false;
			}

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
					break;

				case Command.Done:
					break;

				case Command.Close:
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
	writeln("Initializing plotting backend");
	Backend.LoadBackend("plugins/libmatlabBackend.so");

	Backend.Plot!(Function.Plot)(null);
	
	writeln("Spawning server");
	auto serverTid = spawn(&server, cast(ushort)54000);

	writeln("Press enter to exit...heh");
	readln();

	writeln("Stopping server");
	send(serverTid, false);

	return 0;
	//return RunMatlab();
}