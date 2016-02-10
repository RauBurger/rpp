module rpp.rpc;

import std.file;
import std.math;
import std.socket;
import std.stdio;
import std.meta;
import std.conv;
import std.string;
import std.exception;
import std.traits;
import std.typecons;

alias initRPP = rpc.initRPP;
alias plot = rpc.plot;
alias figure = rpc.figure;
alias print = rpc.print;
alias xlabel = rpc.xlabel;
alias ylabel = rpc.ylabel;
alias title = rpc.title;
alias subplot = rpc.subplot;
alias legend = rpc.legend;
alias hold = rpc.hold;
alias axis = rpc.axis;
alias setupPlot = rpc.setupPlot;
alias grid = rpc.grid;

class PlotException : Exception
{
	struct ExceptionStack
	{
		string file;
		string name;
		uint line;
	}

	public immutable string identifier;
	public immutable ExceptionStack[] stack;

	this(string id, string msg, ExceptionStack[] exStack)
	{
		super(msg);
		identifier = id;
		stack = cast(immutable)(exStack);
	}

	public string ToString()
	{
		string output = "";
		output ~= "\nUnhandled server exception: " ~ identifier ~ "\n";
		output ~= "Message: " ~ msg ~ "\n\n";
		output ~= "-------------------- stack trace --------------------\n";
		foreach(stackItem; stack)
		{
			output ~= "\tIn file: " ~ stackItem.file ~ "\n";
			output ~= "\tIn function: " ~ stackItem.name ~ "\n";
			output ~= "\tOn line: " ~ to!string(stackItem.line) ~ "\n\n";
		}
		return output;
	}
}

class rpc
{
	private enum Command : byte
	{
		Function = 0,
		Data,
		Done
	}

	private enum Function : byte
	{
		Plot = 0,	// done
		Figure,		// done
		SetupPlot,	// done
		Print,		// done
		Xlabel,		// done
		Ylabel,		// done
		Title,		// done
		Subplot,	// done - testing
		Legend,		// done
		Hold,		// done
		Axis,		// done
		Grid,		// done
		Contour,	//
		Colorbar,	//
		Semilogx,	//
		Semilogy,	//
		Loglog		//
	}

	private static Socket server;
	private static Address serverAddr;
	private static Address serverRcv;
	//private static const uint maxSendBytes = 64000;
	private static const uint maxSendBytes = 9216;

	static void initRPP(string remoteAddr, string localAddr, ushort remotePort, ushort localPort)
	{
		writeln("trying to connect to server");
		//server = new UdpSocket(AddressFamily.INET);
		server = new TcpSocket(AddressFamily.INET);
		server.blocking = true;
		writeln("connected to server... I think");
		serverAddr = new InternetAddress(to!(const(char[]))(remoteAddr), remotePort);
		serverRcv = new InternetAddress(to!(const(char[]))(localAddr), localPort);
		server.bind(serverRcv);
		server.connect(serverAddr);
		//server.bind(serverRcv);
	}

	private static void SendFunctionCommand(Function func)(ulong dataLength)
	{
		ubyte[10] funcCommand;
		funcCommand[0] = Command.Function;
		funcCommand[1] = func;

		funcCommand[2..$] = toUBytes!long(dataLength);

		long sentBytes = server.sendTo(funcCommand, serverAddr);
		ubyte[5] respData;
		long rcvBytes = server.receiveFrom(respData, serverAddr);
		if(respData[0] == 3)
			ThrowPlotException(respData);
	}

	private static ubyte[T.sizeof] toUBytes(T)(T data) if (isIntegral!T || is(T : double) || is(T : float))
	{
		static assert(isIntegral!T || is(T : double) || is(T : float), "Only integral types supported");
		union conv
		{
			T type;
			ubyte[T.sizeof] b;
		}
		conv tb = { type : data };
		return tb.b;
	}

	private static ubyte[] toUBytes(T)(string str)
	{
		static assert(isIntegral!T, "string length must be integral type");

		assert(str.length < T.max, "string to large for size type");
		ubyte[] data;
		data ~= toUBytes!T(cast(T)str.length);
		data ~= str[];
		return data;
	}

	private static int argMod(T, ulong len)()
	{
		static if(is(T == real[]) || len == 2)
			return 2;
		else static if(is(T == string))
			return 3;
		else
			static assert(false, "Not supported");
	}


	/*
	 * Plot command start:
	 * [0] = Command.Function
	 * [1] = Function.Plot
	 * [2] = data length byte 1
	 * [3] = data length byte 2
	 * [4] = data length byte 3
	 * [5] = data length byte 4
	 * [6] = data length byte 5
	 * [7] = data length byte 6
	 * [8] = data length byte 7
	 * [9] = data length byte 8
	 * 
	 * Plot command data:
	 * [0] = Command.Data
	 * [1] = Data format: 0x0 data, no line format; 0x1 data with line format
	 * [2] = Number of lines
	 * [3] = line 1 number of bytes (assumes x,y same length. other end will multiply by 2 to get to the next line
	 * [4] = line 1 number of bytes (assumes x,y same length. other end will multiply by 2 to get to the next line
	 * [5] = line 1 number of bytes (assumes x,y same length. other end will multiply by 2 to get to the next line
	 * [6] = line 1 number of bytes (assumes x,y same length. other end will multiply by 2 to get to the next line
	 * [7] = x data idx 0
	 * .
	 * .
	 * .
	 * [n] = y data idx 0
	 * .
	 * .
	 * .
	 * [2*n] = length
	 * [2*n+1] = format string idx 0
	 */
	static void plot(Line...)(Line args)
	{
		alias lines = AliasSeq!(args);
		static assert(lines.length >= 2, "Not enough input arguments");

		ubyte[] plotData;
		plotData ~= Command.Data;

		static if(is(typeof(lines[$-1]) == real[]) || lines.length == 2)
		{
			static assert(lines.length%2 == 0, "Invalid number of arguments");
			plotData~=0x0;
			plotData~= lines.length/2;
		}
		else static if(is(typeof(lines[2]) == string))
		{
			static assert(lines.length%3 == 0, "Invalid number of arguments");
			plotData~=0x1;
			plotData~= lines.length/3;
		}
		else
			static assert(false, "Invalid parameters");

		alias mod = argMod!(typeof(lines[$-1]), lines.length);
		foreach(int i, sym; lines)
		{
			static if(is(sym))
				pragma(msg, "sym: "~sym);
			else
			{
				static if(i % mod() == 0)
				{
					static assert(is(typeof(sym) == real[]));

					uint length = cast(uint)sym.length*8; // array length in bytes

					plotData ~= toUBytes!uint(length);

					foreach(el; sym)
						plotData ~= toUBytes!double(el);
				}
				else static if(i % mod() == 1)
				{
					static assert(is(typeof(sym) == real[]));

					foreach(el; sym)
						plotData ~= toUBytes!double(el);
				}
				else static if(i % mod() == 2)
				{
					static assert(is(typeof(sym) == string));
					immutable string lineStyle = cast(immutable string)sym;

					plotData ~= cast(ubyte)lineStyle.length;
					plotData ~= lineStyle[];
				}
			}
		}

		SendFunctionCommand!(Function.Plot)(plotData.length);
		SendData(plotData);
		SendDoneCommand();
	}

	static void figure()
	{
		SendFunctionCommand!(Function.Figure)(1);
		SendData([Command.Data]);
		SendDoneCommand();
	}

	/* 
	 * [0] = Command.Data
	 * [1] = pathLength 1
	 * [2] = pathLength 2
	 * [3] = path data start
	 * .
	 * .
	 * .
	 * [n] = format length
	 * [n+1] = format data start
	 */

	static void print(string format)(string path)
	{
		string newPath = "";
		if(path[0] != '/' || path[0] != '~')
		{
			// It's a relative path, append cwd
			newPath ~= getcwd() ~ '/';
			if(path[0] == '.')
				newPath ~= path[1..$];
			else
				newPath ~= path;
		}
		else
			newPath = path;

		debug
		{
			writeln("newPath: ", newPath);
			writeln("newPath.length: ", newPath.length);
		}

		ubyte[] printData;
		printData ~= Command.Data;
		printData ~= toUBytes!ushort(cast(ushort)newPath.length);

		printData ~= newPath[];

		printData ~= cast(ubyte)format.length;

		printData ~= format[];

		SendFunctionCommand!(Function.Print)(printData.length);
		SendData(printData);
		SendDoneCommand();

	}

	// hlines will be kept server side and will always reference the most recent plot
	/*
	 * [0] = Command.Data
	 * [1] = xlabel.length 1
	 * [2] = xlabel.length 2
	 * [3] = xlabel.length 3
	 * [4] = xlabel.length 4
	 * [5] = xlabel[0]
	 *
	 *
	 * []
	 *
	 *
	 *
	 *
	 *
	 */
	static void setupPlot(string xlabel, string ylabel, string[] legendNames, ubyte fontSize, string legendLoc)
	{
		ubyte[] setupData;
		setupData ~= Command.Data;

		setupData ~= toUBytes!uint(xlabel);
		setupData ~= toUBytes!uint(ylabel);

		setupData ~= cast(ubyte)legendNames.length;
		foreach(legendName; legendNames)
		{
			setupData ~= toUBytes!uint(legendName);
		}

		setupData ~= fontSize;

		setupData ~= toUBytes!uint(legendLoc);

		SendFunctionCommand!(Function.SetupPlot)(setupData.length);
		SendData(setupData);
		SendDoneCommand();
	}

	private static string typeStr(T)()
	{
		static if(is(T : int))
			return "i32";
		
		else static if(is(T : uint))
			return "u32";

		else static if(is(T : long))
			return "i64";

		else static if(is(T : ulong))
			return "u64";

		else static if(is(T : float))
			return "f32";

		else static if(is(T : double))
			return "f64";

		else static if(is(T : string))
			return "str";

		else
			static assert(false, "type not supported");
	}

	static void xlabel(options...)(string label, options args)
	{
		textLabelImpl!(Function.Xlabel)(label, args);
	}

	static void ylabel(options...)(string label, options args)
	{
		textLabelImpl!(Function.Ylabel)(label, args);
	}

	private static void textLabelImpl(Function func, options...)(string label, options args)
	{
		static assert((func == Function.Ylabel) || (func == Function.Xlabel) || (func == Function.Title), "Incorrect function type for label");
		alias options = AliasSeq!(args);

		ubyte[] labelData;
		labelData ~= Command.Data;

		labelData ~= toUBytes!ushort(label);
		labelData ~= optionsToUbytes(args);

		SendFunctionCommand!func(labelData.length);
		SendData(labelData);
		SendDoneCommand();
	}

	private static ubyte[] optionsToUbytes(options...)(options args)
	{
		alias options = AliasSeq!args;
		static assert(options.length%2 == 0, "Invalid number of options");

		ubyte[] data;

		data ~= cast(ubyte)options.length/2;

		foreach(int i, opt; options)
		{
			static if(i%2 == 0)
			{
				static assert(is(typeof(opt) : string), "Option name must be a string");
				data ~= toUBytes!ushort(opt);
			}
			else
			{
				data ~= typeStr!(typeof(opt))();
				static if(is(typeof(opt) :  string))
					data ~= toUBytes!ushort(opt);
				else
					data ~= toUBytes!(typeof(opt))(opt);
			}
		}
		return data;
	}

	static void title(options...)(string title, options args)
	{
		textLabelImpl!(Function.Title)(title, args);
	}

	static void subplot(string opt = "", options...)(ubyte m, ubyte n, ubyte p, options args)
	{
		ubyte[] subplotData;
		subplotData ~= Command.Data;

		subplotData ~= m;
		subplotData ~= n;
		subplotData ~= p;

		subplotData ~= toUBytes!ubyte(opt);

		subplotData ~= optionsToUbytes(args);

		SendFunctionCommand!(Function.Subplot)(subplotData.length);
		SendData(subplotData);
		SendDoneCommand();
	}

	static void legend(options...)(string[] lines, options args)
	{
		ubyte[] legendData;

		legendData ~= Command.Data;

		legendData ~= cast(ubyte)lines.length;

		foreach(line; lines)
			legendData ~= toUBytes!ushort(line);

		legendData ~= optionsToUbytes(args);

		SendFunctionCommand!(Function.Legend)(legendData.length);
		SendData(legendData);
		SendDoneCommand();
	}

	static void axis(T)(T arg) if(is(T : string) || (isArray!T && isIntegral!(typeof(arg[0]))))
	{
		alias options = AliasSeq!arg;
		ubyte[] axesData;

		axesData ~= Command.Data;

		static if(is(T : string))
		{
			axesData ~= 0;

			axesData ~= toUBytes!ubyte(arg);
		}
		else
		{
			assert(arg.length == 4, "Array must be 4 elements long for axes command");
			
			axesData ~= 1;

			axesData ~= toUBytes!long(arg[0]);
			axesData ~= toUBytes!long(arg[1]);
			axesData ~= toUBytes!long(arg[2]);
			axesData ~= toUBytes!long(arg[3]);
		}

		SendFunctionCommand!(Function.Axis)(axesData.length);
		SendData(axesData);
		SendDoneCommand();
	}

	static void hold(string onOff)()
	{
		static assert((onOff == "on") || (onOff == "off"), "hold on or off, what are you doing");
		SendFunctionCommand!(Function.Hold)(2);
		SendData([Command.Data, onOff == "on" ? 1 : 0]);
		SendDoneCommand();
	}

	static void grid(string onOff)()
	{
		static assert((onOff == "on") || (onOff == "off"), "hold on or off, what are you doing");
		SendFunctionCommand!(Function.Grid)(2);
		SendData([Command.Data, onOff == "on" ? 1 : 0]);
		SendDoneCommand();
	}

	private static void SendData(ubyte[] data)
	{
		if(data.length < maxSendBytes)
		{
			ptrdiff_t sentBytes = server.sendTo(data, serverAddr);

			ubyte[5] respData;
			ptrdiff_t rcvBytes = server.receiveFrom(respData, serverAddr);
			uint bytesReceived = get!uint(respData[1..$]);
			
			// server did not get all the bytes, so we need to send more
			if(respData[0] == 1)
			{
				while(bytesReceived < data.length)
				{
					sentBytes = server.sendTo(data[bytesReceived..$], serverAddr);
					if(sentBytes < 0)
						writeln("error text: ", lastSocketError());
					rcvBytes = server.receiveFrom(respData, serverAddr);
					if(respData[0] == 3)
						ThrowPlotException(respData);
					
					bytesReceived = get!uint(respData[1..$]);
				}
			}
			else if(respData[0] == 3)
				ThrowPlotException(respData);
		}
		else
		{
			int chunks = cast(int)ceil(cast(real)data.length/maxSendBytes);
			auto bytesLeft = data.length;
			for(int i = 0; i < chunks; i++)
			{
				ubyte[maxSendBytes] sendBuff;
				sendBuff[0..(bytesLeft < maxSendBytes ? bytesLeft : $)] = data[i*maxSendBytes..(bytesLeft < maxSendBytes ? $ : maxSendBytes*(i+1))];

				ptrdiff_t sentBytes = server.sendTo(sendBuff[0..(bytesLeft < maxSendBytes ? bytesLeft : $)], serverAddr);

				ubyte[5] respData;
				ptrdiff_t rcvBytes = server.receiveFrom(respData, serverAddr);
				uint bytesReceived = get!uint(respData[1..$]);

				if(respData[0] == 1)
				{
					while((bytesReceived - i*maxSendBytes) < maxSendBytes)
					{
						sentBytes = server.sendTo(sendBuff[bytesReceived - i*maxSendBytes..(bytesLeft < maxSendBytes ? bytesLeft : $)], serverAddr);
						if(sentBytes < 0)
							writeln("error text: ", lastSocketError());
						rcvBytes = server.receiveFrom(respData, serverAddr);
						if(respData[0] == 3)
							ThrowPlotException(respData);

						bytesReceived = get!uint(respData[1..$]);
					}
				}
				else if(respData[0] == 3)
				{
					ThrowPlotException(respData);
				}
				bytesLeft -= maxSendBytes;
			}
		}
	}

	private static void SendDoneCommand()
	{
		ptrdiff_t sentBytes = server.sendTo([Command.Done], serverAddr);
		ubyte [5] respData;
		ptrdiff_t rcvBytes = server.receiveFrom(respData, serverAddr);
		if(respData[0] == 3)
			ThrowPlotException(respData);
	}

	private static T get(T)(ubyte[] data)
	{
		static assert(isIntegral!T || is(T : double) || is(T : float), "Only integral types supported");

		union conv
		{
			T type;
			ubyte[T.sizeof] b;
		}
		conv tb;
		tb.b[] = data[];
		return tb.type;
	}

	private static T get(T)(ubyte[] data, ref uint offset)
	{
		static assert(isIntegral!T || is(T : string) || is(T : double) || is(T : float), "Only integral types and strings supported");
		static if(isIntegral!T || is(T : double) || is(T : float))
		{
			offset += T.sizeof;
			return get!T(data[offset-T.sizeof..offset]);
		}
		else static if(is(T : string))
		{
			uint strSize = get!uint(data, offset);
			string str = "";
			foreach(el; data[offset..offset+strSize])
				str ~= el;

			offset += strSize;
			return str;
		}
	}

	private static void ThrowPlotException(ubyte[5] requestData)
	{
		ubyte[] data = new ubyte[get!uint(requestData[1..$])];
		uint offset = 0;

		ptrdiff_t rcvBytes = server.receiveFrom(data, serverAddr);

		string id = get!string(data, offset);
		string msg = get!string(data, offset);

		uint stackSize = get!uint(data, offset);
		PlotException.ExceptionStack[] stack = new PlotException.ExceptionStack[stackSize];

		foreach(ref stackItem; stack)
		{
			stackItem.file = get!string(data, offset);
			stackItem.name = get!string(data, offset);
			stackItem.line = get!uint(data, offset);
		}

		auto plotException = new PlotException(id, msg, stack);
		writeln(plotException.ToString());
		throw plotException;
	}
}