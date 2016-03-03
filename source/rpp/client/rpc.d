module rpp.client.rpc;

import std.socket;
import std.stdio;
import std.meta;
import std.conv;
import std.traits;
import std.file;
import std.exception : assumeUnique;

import rpp.common.utilities;
import rpp.common.enums;

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

private Socket server;
private Address serverAddr;

void initRPP(string remoteAddr, ushort port)
{
	writeln("trying to connect to server");
	
	//server = new TcpSocket(AddressFamily.INET);
	server = new Socket(AddressFamily.INET, SocketType.STREAM);
	server.blocking = true;
	//server.setOption(SocketOptionLevel.TCP, SocketOption.TCP_NODELAY, 1);
	
	//serverAddr = new InternetAddress(to!(const(char[]))(remoteAddr), port);
	//serverAddr = new InternetAddress("localhost", port);
	server.connect(new InternetAddress("localhost", port));
	writeln("connected to server... I think");

	//server.send([0]);
	ubyte[5] respData;
	long rcvBytes = server.receiveFrom(respData, serverAddr);
	writeln("got bytes");

	if(respData[0] == 3)
		ThrowPlotException(respData);

}

private static ~this()
{
	writeln("closing socket");

	server.send([Command.Close, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
	
	ubyte[5] respData;
	long rcvBytes = server.receiveFrom(respData, serverAddr);
	if(respData[0] == 3)
		ThrowPlotException(respData);

	writeln(respData);
	server.close();
}

private void SendFunctionCommand(Function func)(ulong dataLength)
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

private int argMod(T, ulong len)()
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

void plot(Line...)(Line args)
{
	plotImpl!(Function.Plot)(args);
}

void semilogx(Line...)(Line args)
{
	plotImpl!(Function.Semilogx)(args);
}

void semilogy(Line...)(Line args)
{
	plotImpl!(Function.Semilogy)(args);
}

void loglog(Line...)(Line args)
{
	plotImpl!(Function.Loglog)(args);
}

enum PlotFormat : ubyte
{
	NoFormatStr = 0,
	FormatStr
}

private void plotImpl(Function func, Line...)(Line args)
{
	alias lines = AliasSeq!(args);
	static assert(lines.length >= 2, "Not enough input arguments");

	ubyte[] plotData;
	plotData ~= Command.Data;

	static if(is(typeof(lines[$-1]) == real[]) || lines.length == 2)
	{
		static assert(lines.length%2 == 0, "Invalid number of arguments");
		plotData ~= PlotFormat.NoFormatStr;
		plotData ~= lines.length/2;
	}
	else static if(is(typeof(lines[2]) == string))
	{
		static assert(lines.length%3 == 0, "Invalid number of arguments");
		plotData ~= PlotFormat.FormatStr;
		plotData ~= lines.length/3;
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
				static assert(is(typeof(sym) == real[]) || is(typeof(sym) == double[]) || is(typeof(sym) == float[]));

				uint length = cast(uint)sym.length*8; // array length in bytes

				plotData ~= toUBytes!uint(length);

				foreach(el; sym)
					plotData ~= toUBytes!double(el);
			}
			else static if(i % mod() == 1)
			{
				static assert(is(typeof(sym) == real[]) || is(typeof(sym) == double[]) || is(typeof(sym) == float[]));

				foreach(el; sym)
					plotData ~= toUBytes!double(el);
			}
			else static if(i % mod() == 2)
			{
				static assert(is(typeof(sym) == string));
				immutable string lineStyle = cast(immutable string)sym;

				plotData ~= lineStyle.toUBytes!ubyte();
			}
		}
	}

	SendFunctionCommand!(func)(plotData.length);
	SendData(plotData);
	SendDoneCommand();
}

void figure()
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

void print(string format)(string path)
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
	printData ~= toUBytes!ushort(newPath);

	printData ~= toUBytes!ubyte(format);

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
void setupPlot(string xlabel, string ylabel, string[] legendNames, ubyte fontSize, string legendLoc)
{
	ubyte[] setupData;
	setupData ~= Command.Data;

	setupData ~= toUBytes!uint(xlabel);
	setupData ~= toUBytes!uint(ylabel);

	setupData ~= cast(ubyte)legendNames.length;
	foreach(legendName; legendNames)
		setupData ~= toUBytes!uint(legendName);

	setupData ~= fontSize;

	setupData ~= toUBytes!uint(legendLoc);

	SendFunctionCommand!(Function.SetupPlot)(setupData.length);
	SendData(setupData);
	SendDoneCommand();
}

private string typeStr(T)()
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

void xlabel(options...)(string label, options args)
{
	textLabelImpl!(Function.Xlabel)(label, args);
}

void ylabel(options...)(string label, options args)
{
	textLabelImpl!(Function.Ylabel)(label, args);
}

private void textLabelImpl(Function func, options...)(string label, options args)
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

private ubyte[] optionsToUbytes(options...)(options args)
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

void title(options...)(string title, options args)
{
	textLabelImpl!(Function.Title)(title, args);
}

void subplot(string opt = "", options...)(ubyte m, ubyte n, ubyte p, options args)
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

void legend(options...)(string[] lines, options args)
{
	ubyte[] legendData;

	legendData ~= Command.Data;

	legendData ~= cast(ubyte)lines.length;

	foreach(line; lines)
	{
		legendData ~= toUBytes!ushort(line);
	}

	legendData ~= optionsToUbytes(args);

	SendFunctionCommand!(Function.Legend)(legendData.length);
	SendData(legendData);
	SendDoneCommand();
}

void axis(T)(T arg) if(is(T : string) || (isArray!T && isIntegral!(typeof(arg[0]))))
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

void hold(string onOff)()
{
	static assert((onOff == "on") || (onOff == "off"), "hold on or off, what are you doing");
	SendFunctionCommand!(Function.Hold)(2);
	SendData([Command.Data, onOff == "on" ? 1 : 0]);
	SendDoneCommand();
}

void grid(string onOff)()
{
	static assert((onOff == "on") || (onOff == "off"), "hold on or off, what are you doing");
	SendFunctionCommand!(Function.Grid)(2);
	SendData([Command.Data, onOff == "on" ? 1 : 0]);
	SendDoneCommand();
}

void contour(T, options...)(T[][] Z, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour)(Z, args);
}

void contourf(T, options...)(T[][] Z, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contourf)(Z, args);
}

void contour3(T, options...)(T[][] Z, options args)
	if(isFloatingPoint!T && (is(options[0] : string)|| (options.length == 0)))
{
	contourImpl!(Function.Contour3)(Z, args);
}

private void contourImpl(Function func, T, options...)(T[][] Z, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	ubyte[] contourData;
	contourData ~= Command.Data;
	contourData ~= 0x0;
	contourData ~= toUBytes!(uint, double)(Z);
	contourData ~= optionsToUbytes(args);

	SendFunctionCommand!(func)(contourData.length);
	SendData(contourData);
	SendDoneCommand();
}

void contour(T, options...)(T[][] Z, uint n, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour)(Z, n, args);
}

void contourf(T, options...)(T[][] Z, uint n, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contourf)(Z, n, args);
}

void contour3(T, options...)(T[][] Z, uint n, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour3)(Z, n, args);
}

private void contourImpl(Function func, T, options...)(T[][] Z, uint n, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	ubyte[] contourData;
	contourData ~= Command.Data;
	contourData ~= 0x1;
	contourData ~= toUBytes!(uint, double)(Z);
	contourData ~= toUBytes!uint(n);
	contourData ~= optionsToUbytes(args);

	SendFunctionCommand!(func)(contourData.length);
	SendData(contourData);
	SendDoneCommand();
}

void contour(T, options...)(T[][] Z, uint[] v, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour)(Z, v, args);
}

void contourf(T, options...)(T[][] Z, uint[] v, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contourf)(Z, v, args);
}

void contour3(T, options...)(T[][] Z, uint[] v, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour3)(Z, v, args);
}

private void contourImpl(Function func, T, options...)(T[][] Z, uint[] v, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	ubyte[] contourData;
	contourData ~= Command.Data;
	contourData ~= 0x2;
	contourData ~= toUBytes!(uint, double)(Z);
	contourData ~= toUBytes!uint(v);
	contourData ~= optionsToUbytes(args);
	
	SendFunctionCommand!(func)(contourData.length);
	SendData(contourData);
	SendDoneCommand();
}

void contour(T, options...)(T[][] X, T[][] Y, T[][] Z, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour)(X, Y, Z, args);
}

void contourf(T, options...)(T[][] X, T[][] Y, T[][] Z, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contourf)(X, Y, Z, args);
}

void contour3(T, options...)(T[][] X, T[][] Y, T[][] Z, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour3)(X, Y, Z, args);
}

private void contourImpl(Function func, T, options...)(T[][] X, T[][] Y, T[][] Z, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	ubyte[] contourData;
	contourData ~= Command.Data;
	contourData ~= 0x3;
	contourData ~= toUBytes!(uint, double)(X);
	contourData ~= toUBytes!(uint, double)(Y);
	contourData ~= toUBytes!(uint, double)(Z);
	contourData ~= optionsToUbytes(args);

	SendFunctionCommand!(func)(contourData.length);
	SendData(contourData);
	SendDoneCommand();
}

void contour(T, options...)(T[][] X, T[][] Y, T[][] Z, uint n, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour)(X, Y, Z, n, args);
}

void contourf(T, options...)(T[][] X, T[][] Y, T[][] Z, uint n, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contourf)(X, Y, Z, n, args);
}

void contour3(T, options...)(T[][] X, T[][] Y, T[][] Z, uint n, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour3)(X, Y, Z, n, args);
}

private void contourImpl(Function func, T, options...)(T[][] X, T[][] Y, T[][] Z, uint n, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	ubyte[] contourData;
	contourData ~= Command.Data;
	contourData ~= 0x4;
	contourData ~= toUBytes!(uint, double)(X);
	contourData ~= toUBytes!(uint, double)(Y);
	contourData ~= toUBytes!(uint, double)(Z);
	contourData ~= toUBytes!uint(n);
	contourData ~= optionsToUbytes(args);

	SendFunctionCommand!(func)(contourData.length);
	SendData(contourData);
	SendDoneCommand();
}

void contour(T, options...)(T[][] X, T[][] Y, T[][] Z, uint[] v, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour)(X, Y, Z, v, args);
}

void contourf(T, options...)(T[][] X, T[][] Y, T[][] Z, uint[] v, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contourf)(X, Y, Z, v, args);
}

void contour3(T, options...)(T[][] X, T[][] Y, T[][] Z, uint[] v, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	contourImpl!(Function.Contour3)(X, Y, Z, v, args);
}

private void contourImpl(Function func, T, options...)(T[][] X, T[][] Y, T[][] Z, uint[] v, options args)
	if(isFloatingPoint!T && (is(options[0] : string) || (options.length == 0)))
{
	ubyte[] contourData;
	contourData ~= Command.Data;
	contourData ~= 0x5;
	contourData ~= toUBytes!(uint, double)(X);
	contourData ~= toUBytes!(uint, double)(Y);
	contourData ~= toUBytes!(uint, double)(Z);
	contourData ~= toUBytes!uint(v);
	contourData ~= optionsToUbytes(args);

	SendFunctionCommand!(func)(contourData.length);
	SendData(contourData);
	SendDoneCommand();
}

void colorbar()
{

}

void colorbar(string placement)
{

}

void colorbar(Nvp...)(Nvp nvp)
	if ((Nvp.length == 2) && is(Nvp[0]: string) &&
		(isIntegral!(AliasSeq!(Nvp)[1]) || isFloatingPoint!(AliasSeq!(Nvp)[1]) || is(Nvp[1]: string)))
{

}

void colorbar(Nvp...)(string placement, Nvp nvp)
	if ((Nvp.length == 2) && is(Nvp[0]: string) &&
		(isIntegral!(AliasSeq!(Nvp)[1]) || isFloatingPoint!(AliasSeq!(Nvp)[1]) || is(Nvp[1]: string)))
{

}

private void SendData(ubyte[] data)
{
	ptrdiff_t sentBytes = server.sendTo(data, serverAddr);

	ubyte[5] respData;
	ptrdiff_t rcvBytes = server.receiveFrom(respData, serverAddr);
	uint bytesReceived = get!uint(respData[1..$]);
}

private void SendDoneCommand()
{
	ptrdiff_t sentBytes = server.sendTo([Command.Done], serverAddr);
	ubyte [5] respData;
	ptrdiff_t rcvBytes = server.receiveFrom(respData, serverAddr);
	if(respData[0] == 3)
		ThrowPlotException(respData);
}

private void ThrowPlotException(ubyte[5] requestData)
{
	ubyte[] data = new ubyte[get!uint(requestData[1..$])];
	uint offset = 0;

	ptrdiff_t rcvBytes = server.receiveFrom(data, serverAddr);

	string id = get!(string, uint)(data, offset);
	string msg = get!(string, uint)(data, offset);

	uint stackSize = get!uint(data, offset);
	PlotException.ExceptionStack[] stack = new PlotException.ExceptionStack[stackSize];

	foreach(ref stackItem; stack)
	{
		stackItem.file = get!(string, uint)(data, offset);
		stackItem.name = get!(string, uint)(data, offset);
		stackItem.line = get!uint(data, offset);
	}

	auto plotException = new PlotException(id, msg, stack);
	writeln(plotException.ToString());
	throw plotException;
}
