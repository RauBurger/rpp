module matlab.matlabBacked;

import std.stdio;
import std.conv;

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
		writeln("Hello matlab");
		
		engine = engOpen("");

		if(engine == null)
		{
			writeln("Engine failed to open");
			return;
			//return -1;
		}
		/+
		mlArray arr = mlArray(linspace(0, 10, 100));

		writeln("Copied array, off to matlab");
		engPutVariable(engine, "T", arr);

		writeln("making thing");
		engEvalString(engine, "D = T.^2;");
		writeln("plotting");
		engEvalString(engine, "hlines = plot(T, D);");
		engEvalString(engine, `setupPlot(hlines, '$T$', '$Y$', {'line'}, 12, 'northwest');`);

		writeln("Press return");
		readln();

		foreach(int i, ref el; arr)
			el = to!double(i);

		engPutVariable(engine, "T", arr);

		engEvalString(engine, "figure;");
		engEvalString(engine, `hlines = plot(D, T, 'r', D, -T, 'g');`);
		engEvalString(engine, `setupPlot(hlines, '$D$', '$T$', {'line1', 'line2'}, 12, 'northwest');`);

		writeln("Press return to exit");
		readln();

		engClose(engine);
		writeln("Goodbye");
		+/
	}

	~this()
	{
		writeln("closing down");
		engClose(engine);
		writeln("Goodbye");
	}
	
	void Plot(double[][] X, double[][] Y)
	{
		writeln("Plot1");
	}
	
	void Plot(double[][] X, double[][] Y, string[] fmts)
	{
		writeln("Plot2");
	}
	
	void Figure()
	{
		writeln("Figure1");
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