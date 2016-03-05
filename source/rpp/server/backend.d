module rpp.server.backend;

import std.stdio;
import std.conv;
import std.variant;

import core.runtime;
import core.stdc.stdio;
import core.stdc.stdlib;

version(Posix)
{
	import core.sys.posix.dlfcn;
}

import rpp.common.enums;
import rpp.common.utilities;

alias Options = Variant[string];

interface IServerBackend
{
	void Plot(double[][] X, double[][] Y);
	void Plot(double[][] X, double[][] Y, string[] fmts);
	void Figure();
	void Figure(Options options);
	void SetupPlot(string xlabel, string ylabel, string[] legendNames, ubyte fontSize, string legendLoc);
	void Print(string format, string path);
	void Xlabel(string label);
	void Xlabel(string label, Options options);
	void Ylabel(string label);
	void Ylabel(string label, Options options);
	void Title(string label);
	void Title(string label, Options options);
	void Subplot(ubyte m, ubyte n, ubyte p);
	void Subplot(ubyte m, ubyte n, ubyte p, string opt);
	void Subplot(ubyte m, ubyte n, ubyte p, Options options);
	void Subplot(ubyte m, ubyte n, ubyte p, string opt, Options options);
	void Legend(string[] lines);
	void Legend(string[] lines, Options options);
	void Hold(bool on);
	void Axis(long[] limits);
	void Axis(string option);
	void Grid(bool on);
	void Contour(double[][] Z);
	void Contour(double[][] Z, Options options);
	void Contour(double[][] Z, uint n);
	void Contour(double[][] Z, uint n, Options options);
	void Contour(double[][] Z, uint[] v);
	void Contour(double[][] Z, uint[] v, Options options);
	void Contour(double[][] X, double[][] Y, double[][] Z);
	void Contour(double[][] X, double[][] Y, double[][] Z, Options options);
	void Contour(double[][] X, double[][] Y, double[][] Z, uint n);
	void Contour(double[][] X, double[][] Y, double[][] Z, uint n, Options options);
	void Contour(double[][] X, double[][] Y, double[][] Z, uint[] v);
	void Contour(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options);
	void Contourf(double[][] Z);
	void Contourf(double[][] Z, Options options);
	void Contourf(double[][] Z, uint n);
	void Contourf(double[][] Z, uint n, Options options);
	void Contourf(double[][] Z, uint[] v);
	void Contourf(double[][] Z, uint[] v, Options options);
	void Contourf(double[][] X, double[][] Y, double[][] Z);
	void Contourf(double[][] X, double[][] Y, double[][] Z, Options options);
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint n);
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint n, Options options);
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint[] v);
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options);
	void Contour3(double[][] Z);
	void Contour3(double[][] Z, Options options);
	void Contour3(double[][] Z, uint n);
	void Contour3(double[][] Z, uint n, Options options);
	void Contour3(double[][] Z, uint[] v);
	void Contour3(double[][] Z, uint[] v, Options options);
	void Contour3(double[][] X, double[][] Y, double[][] Z);
	void Contour3(double[][] X, double[][] Y, double[][] Z, Options options);
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint n);
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint n, Options options);
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint[] v);
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options);
	void Colorbar();
	void Colorbar(string placement);
	void Colorbar(Options options);
	void Colorbar(string placement, Options options);
	void Semilogx(double[][] X, double[][] Y);
	void Semilogx(double[][] X, double[][] Y, string[] fmts);
	void Semilogy(double[][] X, double[][] Y);
	void Semilogy(double[][] X, double[][] Y, string[] fmts);
	void Loglog(double[][] X, double[][] Y);
	void Loglog(double[][] X, double[][] Y, string[] fmts);
}

extern (C) IServerBackend InitBackend();

struct Backend
{
	static IServerBackend backend;
	static void* plugin;
	static bool LoadBackend(string pluginName)
	{
		version(Posix)
		{
			plugin = dlopen(pluginName.ptr, RTLD_NOW);
			if(plugin is null)
			{
				return false;
			}

			IServerBackend function() initBackend = cast(IServerBackend function())dlsym(plugin, "InitBackend");
			char* error = dlerror();
			if(error)
			{
				writeln("dlsym error: "~to!string(error));
				return false;
			}

			backend = initBackend();
		}
		return true;
	}

	static ~this()
	{
		if(plugin != null)
		{
			version(Posix)
			{
				dlclose(plugin);
			}
		}
	}

	static void Plot(Function func)(ubyte[] data)
	{
		uint offset = 1;
		bool plotFormat = to!bool(data[offset]);
		offset++;

		ubyte numLines = data[offset];
		offset++;

		string[] formats;

		if(plotFormat)
		{
			formats = new string[numLines];
		}

		double[][] X = new double[][](numLines);
		double[][] Y = new double[][](numLines);

		for(int i = 0; i < numLines; i++)
		{
			uint length = get!uint(data, offset)/8;
			X[i] = new double[length];
			Y[i] = new double[length];

			foreach(ref el; X[i])
			{
				el = get!double(data, offset);
			}

			foreach(ref el; Y[i])
			{
				el = get!double(data, offset);
			}

			if(plotFormat)
			{
				formats[i] = get!(string, ubyte)(data, offset);
			}
		}

		if(plotFormat)
		{
			mixin("backend."~to!string(func)~"(X, Y, formats);");
		}
		else
		{
			mixin("backend."~to!string(func)~"(X, Y);");
		}
	}

	static private Options bytesToOptions(ubyte[] data, ref uint offset)
	{
		ubyte numOptions = data[offset];
		offset++;

		Options options;
		
		foreach(i; 0..numOptions-1)
		{
			string option = get!(string, ushort)(data, offset);

			string type = to!string(data[offset..offset+3]);
			offset += 3;

			if(type == "i32")
			{
				options[option] = get!int(data, offset);
			}
			else if(type == "u32")
			{
				options[option] = get!uint(data, offset);
			}
			else if(type == "i64")
			{
				options[option] = get!long(data, offset);
			}
			else if(type == "u64")
			{
				options[option] = get!ulong(data, offset);
			}
			else if(type == "f32")
			{
				options[option] = get!float(data, offset);
			}
			else if(type == "f64")
			{
				options[option] = get!double(data, offset);
			}
			else if(type == "str")
			{
				options[option] = get!(string, ushort)(data, offset);
			}
		}

		return options;
	}

	static void Figure(ubyte[] data)
	{
		backend.Figure();
	}

	static void SetupPlot(ubyte[] data)
	{
		uint offset = 1;
		string xlabel = get!(string, uint)(data, offset);
		string ylabel = get!(string, uint)(data, offset);

		ubyte legendNamesLen = data[offset];
		offset++;

		string[] legendNames = new string[legendNamesLen];
		foreach(ref name; legendNames)
		{
			name = get!(string, uint)(data, offset);
		}

		ubyte fontSize = data[offset];
		offset++;

		string legendLoc = get!(string, uint)(data, offset);

		backend.SetupPlot(xlabel, ylabel, legendNames, fontSize, legendLoc);
	}

	static void Print(ubyte[] data)
	{
		uint offset = 1;
		string path = get!(string, ushort)(data, offset);
		string format = get!(string, ubyte)(data, offset);
		backend.Print(format, path);
	}

	static void TextLabel(Function func)(ubyte[] data)
	{
		uint offset = 1;
		string label = get!(string, ushort)(data, offset);

		Options options = bytesToOptions(data, offset);

		if(options.length > 0)
		{
			mixin("backend."~to!string(func)~"(label, options);");
		}
		else
		{
			mixin("backend."~to!string(func)~"(label);");
		}
	}

	static void Subplot(ubyte[] data)
	{
		uint offset = 1;

		ubyte m = data[offset];
		offset++;
		ubyte n = data[offset];
		offset++;
		ubyte p = data[offset];
		offset++;

		string option = get!(string, ubyte)(data, offset);
		Options options = bytesToOptions(data, offset);

		if((option.length == 0) && (options.length == 0))
		{
			backend.Subplot(m, n, p);
		}
		else if((option.length == 0) && (options.length != 0))
		{
			backend.Subplot(m, n, p, options);
		}
		else if((option.length != 0) && (options.length == 0))
		{
			backend.Subplot(m, n, p, option);
		}
		else
		{
			backend.Subplot(m, n, p, option, options);
		}
	}

	static void Legend(ubyte[] data)
	{
		uint offset = 1;

		ubyte numLines = data[offset];
		offset++;

		string[] lines = new string[numLines];

		foreach(ref line; lines)
		{
			line = get!(string, ushort)(data, offset);
		}

		Options options = bytesToOptions(data, offset);

		if(options.length == 0)
		{
			backend.Legend(lines);
		}
		else
		{
			backend.Legend(lines, options);
		}
	}

	static void Hold(bool on)
	{
		backend.Hold(on);
	}

	static void Axis(ubyte[] data)
	{
		uint offset = 1;

		ubyte funcType = data[offset];
		offset++;

		if(funcType == 0)
		{
			// string argument
			string option = get!(string, ubyte)(data, offset);
			backend.Axis(option);
		}
		else if(funcType == 1)
		{
			// array argument
			long[] limits = new long[4];

			limits[0] = get!long(data, offset);
			limits[1] = get!long(data, offset);
			limits[2] = get!long(data, offset);
			limits[3] = get!long(data, offset);

			backend.Axis(limits);
		}
	}

	static void Grid(bool on)
	{
		backend.Grid(on);
	}

	static void Contour(Function func)(ubyte[] data)
	{

		uint offset = 1;
		ubyte funcType = data[offset];
		offset++;

		switch(funcType)
		{
			case 0:
				ContourImpl0!(func)(data, offset);
				break;

			case 1:
				ContourImpl1!(func)(data, offset);
				break;

			case 2:
				ContourImpl2!(func)(data, offset);
				break;

			case 3:
				ContourImpl3!(func)(data, offset);
				break;

			case 4:
				ContourImpl4!(func)(data, offset);
				break;

			case 5:
				ContourImpl5!(func)(data, offset);
				break;

			default:
				break;
		}
	}

	static void ContourImpl0(Function func)(ubyte[] data, uint offset)
	{
		double[][] Z = get!(double[][], uint)(data, offset);

		Options options = bytesToOptions(data, offset);

		if(options.length == 0)
		{
			mixin("backend."~to!string(func)~"(Z);");
		}
		else
		{
			mixin("backend."~to!string(func)~"(Z, options);");
		}
	}

	static void ContourImpl1(Function func)(ubyte[] data, uint offset)
	{
		double[][] Z = get!(double[][], uint)(data, offset);
		uint n = get!uint(data, offset);

		Options options = bytesToOptions(data, offset);

		if(options.length == 0)
		{
			mixin("backend."~to!string(func)~"(Z, n);");
		}
		else
		{
			mixin("backend."~to!string(func)~"(Z, n, options);");
		}
	}

	static void ContourImpl2(Function func)(ubyte[] data, uint offset)
	{
		double[][] Z = get!(double[][], uint)(data, offset);
		uint[] v = get!(uint[], uint)(data, offset);

		Options options = bytesToOptions(data, offset);

		if(options.length == 0)
		{
			mixin("backend."~to!string(func)~"(Z, v);");
		}
		else
		{
			mixin("backend."~to!string(func)~"(Z, v, options);");
		}
	}

	static void ContourImpl3(Function func)(ubyte[] data, uint offset)
	{
		double[][] X = get!(double[][], uint)(data, offset);
		double[][] Y = get!(double[][], uint)(data, offset);
		double[][] Z = get!(double[][], uint)(data, offset);

		Options options = bytesToOptions(data, offset);

		if(options.length == 0)
		{
			mixin("backend."~to!string(func)~"(X, Y, Z);");
		}
		else
		{
			mixin("backend."~to!string(func)~"(X, Y, Z, options);");
		}
	}

	static void ContourImpl4(Function func)(ubyte[] data, uint offset)
	{
		double[][] X = get!(double[][], uint)(data, offset);
		double[][] Y = get!(double[][], uint)(data, offset);
		double[][] Z = get!(double[][], uint)(data, offset);

		uint n = get!uint(data, offset);

		Options options = bytesToOptions(data, offset);

		if(options.length == 0)
		{
			mixin("backend."~to!string(func)~"(X, Y, Z, n);");
		}
		else
		{
			mixin("backend."~to!string(func)~"(X, Y, Z, n, options);");
		}
	}

	static void ContourImpl5(Function func)(ubyte[] data, uint offset)
	{
		double[][] X = get!(double[][], uint)(data, offset);
		double[][] Y = get!(double[][], uint)(data, offset);
		double[][] Z = get!(double[][], uint)(data, offset);

		uint[] v = get!(uint[], uint)(data, offset);

		Options options = bytesToOptions(data, offset);

		if(options.length == 0)
		{
			mixin("backend."~to!string(func)~"(X, Y, Z, v);");
		}
		else
		{
			mixin("backend."~to!string(func)~"(X, Y, Z, v, options);");
		}
	}

	static void Colorbar(ubyte[] data)
	{

	}
}