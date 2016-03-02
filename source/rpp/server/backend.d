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
	void SetupPlot(string xlabel, string ylabel, string[] legendNames, ubyte fontSize, string legenLoc);
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
	void Axis(int[] limits);
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

		static if(func == Function.Plot)
		{
			if(plotFormat)
			{
				backend.Plot(X, Y, formats);
			}
			else
			{
				backend.Plot(X, Y);
			}
		}
		else static if(func == Function.Semilogx)
		{
			if(plotFormat)
			{
				backend.Semilogx(X, Y, formats);
			}
			else
			{
				backend.Semilogx(X, Y);
			}
		}
		else static if(func == Function.Semilogx)
		{
			if(plotFormat)
			{
				backend.Semilogy(X, Y, formats);
			}
			else
			{
				backend.Semilogy(X, Y);
			}
		}
		else static if(func == Function.Semilogx)
		{
			if(plotFormat)
			{
				backend.Loglog(X, Y, formats);
			}
			else
			{
				backend.Loglog(X, Y);
			}
		}
	}

	static private Options bytesToOptions(ubyte[] data, ref uint offset)
	{
		ubyte numOptions = data[offset];
		offset++;

		Options options;
		
		foreach(i; 0..numOptions)
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

		static if(func == Function.Xlabel)
		{
			if(options.length > 0)
			{
				backend.Xlabel(label, options);
			}
			else
			{
				backend.Xlabel(label);
			}
		}
		else static if(func == Function.Ylabel)
		{
			if(options.length > 0)
			{
				backend.Ylabel(label, options);
			}
			else
			{
				backend.Ylabel(label);
			}
		}
		else static if(func == Function.Title)
		{
			if(options.length > 0)
			{
				backend.Title(label, options);
			}
			else
			{
				backend.Title(label);
			}
		}
	}

	static void Subplot(ubyte[] data)
	{

	}

	static void Legend(ubyte[] data)
	{

	}

	static void Hold(bool on)
	{

	}

	static void Axis(ubyte[] data)
	{

	}

	static void Grid(bool on)
	{

	}

	static void Contour(Function func)(ubyte[] data)
	{

	}

	static void Colorbar(ubyte[] data)
	{

	}
}