module matlab.matlabBacked;

import std.conv;
import std.experimental.allocator.mallocator;
import std.stdio;
import std.string;

import rpp.server.backend;
import rpp.common.enums;

import matlab.engine;
import matlab.mex;
import matlab.mlArray;

extern (C) IServerBackend InitBackend()
{
	return new MatlabBackend();
}

double[] linspace(double start, double end, int points)
{
	double h = (end-start)/(points-1);
	double[] x = new double[points];
	x[0] = start;
	for(int i = 1; i < points; i++)
	{
		x[i] = x[i-1]+h;
	}
	return x;
}

class MatlabBackend : IServerBackend
{
	Engine* engine;

	this()
	{	
		engine = engOpen("");

		if(engine == null)
		{
			throw new Exception("Failed to open matlab engine");
		}
	}

	~this()
	{
		engClose(engine);
	}
	
	void Plot(double[][] X, double[][] Y)
	{
		string command = `hlines = plot(`;

		foreach(ulong i; 0..X.length)
		{
			mlArray x = mlArray(X[i]);
			mlArray y = mlArray(Y[i]);

			string xStr = "X"~i.to!string;
			string yStr = "Y"~i.to!string;

			engPutVariable(engine, xStr.toStringz, x.matlabData);
			engPutVariable(engine, yStr.toStringz, y.matlabData);

			command ~= xStr~", "~yStr~", ";
		}

		command = command.chomp(", ") ~ ");";

		engEvalString(engine, command.toStringz);
	}
	
	void Plot(double[][] X, double[][] Y, string[] fmts)
	{
		string command = `hlines = plot(`;

		foreach(ulong i; 0..X.length)
		{
			mlArray x = mlArray(X[i]);
			mlArray y = mlArray(Y[i]);

			string xStr = "X"~i.to!string;
			string yStr = "Y"~i.to!string;

			engPutVariable(engine, xStr.toStringz, x.matlabData);
			engPutVariable(engine, yStr.toStringz, y.matlabData);

			command ~= xStr~", "~yStr~`, '`~fmts[i]~`', `;
		}

		command = command.chomp(", ") ~ ");";

		engEvalString(engine, command.toStringz);
	}
	
	void Figure()
	{
		engEvalString(engine, "figure;");
		//writeln("Figure1");
	}

	void Figure(Options options)
	{

		writeln("Figure2");
	}

	void SetupPlot(string xlabel, string ylabel, string[] legendNames, ubyte fontSize, string legenLoc)
	{
		writeln("SetupPlot");
	}

	void Print(string format, string path)
	{
		writeln("Print");
	}

	void Xlabel(string label)
	{
		writeln("Xlabel1");
	}

	void Xlabel(string label, Options options)
	{
		writeln("Xlabel2");
	}

	void Ylabel(string label)
	{
		writeln("Ylabel");
	}
	
	void Ylabel(string label, Options options)
	{
		writeln("Ylabel");
	}
	
	void Title(string label)
	{
		writeln("Title");
	}
	
	void Title(string label, Options options)
	{
		writeln("Title");
	}
	
	void Subplot(ubyte m, ubyte n, ubyte p)
	{
		writeln("Subplot");
	}
	
	void Subplot(ubyte m, ubyte n, ubyte p, string opt)
	{
		writeln("Subplot");
	}
	
	void Subplot(ubyte m, ubyte n, ubyte p, Options options)
	{
		writeln("Subplot");
	}
	
	void Subplot(ubyte m, ubyte n, ubyte p, string opt, Options options)
	{
		writeln("Subplot");
	}
	
	void Legend(string[] lines)
	{
		writeln("Legend");
	}
	
	void Legend(string[] lines, Options options)
	{
		writeln("Legend");
	}
	
	void Hold(bool on)
	{
		writeln("Hold");
	}
	
	void Axis(long[] limits)
	{
		writeln("Axis");
	}
	
	void Axis(string option)
	{
		writeln("Axis");
	}
	
	void Grid(bool on)
	{
		writeln("Grid");
	}
	
	void Contour(double[][] Z)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] Z, Options options)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] Z, uint n)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] Z, uint n, Options options)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] Z, uint[] v)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] Z, uint[] v, Options options)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, Options options)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, uint n)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, uint n, Options options)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, uint[] v)
	{
		writeln("Contour");
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options)
	{
		writeln("Contour");
	}
	
	void Contourf(double[][] Z)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] Z, Options options)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] Z, uint n)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] Z, uint n, Options options)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] Z, uint[] v)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] Z, uint[] v, Options options)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z, Options options)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint n)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint n, Options options)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint[] v)
	{
		writeln("Contourf");
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options)
	{
		writeln("Contourf");
	}
	
	void Contour3(double[][] Z)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] Z, Options options)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] Z, uint n)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] Z, uint n, Options options)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] Z, uint[] v)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] Z, uint[] v, Options options)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, Options options)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint n)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint n, Options options)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint[] v)
	{
		writeln("Contour3");
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options)
	{
		writeln("Contour3");
	}
	
	void Colorbar()
	{
		writeln("Colorbar");
	}
	
	void Colorbar(string placement)
	{
		writeln("Colorbar");
	}
	
	void Colorbar(Options options)
	{
		writeln("Colorbar");
	}
	
	void Colorbar(string placement, Options options)
	{
		writeln("Colorbar");
	}
	
	void Semilogx(double[][] X, double[][] Y)
	{
		writeln("Semilogx");
	}
	
	void Semilogx(double[][] X, double[][] Y, string[] fmts)
	{
		writeln("Semilogx");
	}
	
	void Semilogy(double[][] X, double[][] Y)
	{
		writeln("Semilogy");
	}
	
	void Semilogy(double[][] X, double[][] Y, string[] fmts)
	{
		writeln("Semilogy");
	}
	
	void Loglog(double[][] X, double[][] Y)
	{
		writeln("Loglog");
	}
	
	void Loglog(double[][] X, double[][] Y, string[] fmts)
	{
		writeln("Loglog");
	}
	
}