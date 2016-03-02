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
	void Plot(double[][] X, double[][] Y) {}
	void Plot(double[][] X, double[][] Y, string[] fmts) {}
	void Figure() {}
	void Figure(Options options) {}
	void SetupPlot(string xlabel, string ylabel, string[] legendNames, ubyte fontSize, string legenLoc) {}
	void Print(string format, string path) {}
	void Xlabel(string label) {}
	void Xlabel(string label, Options options) {}
	void Ylabel(string label) {}
	void Ylabel(string label, Options options) {}
	void Title(string label) {}
	void Title(string label, Options options) {}
	void Subplot(ubyte m, ubyte n, ubyte p) {}
	void Subplot(ubyte m, ubyte n, ubyte p, string opt) {}
	void Subplot(ubyte m, ubyte n, ubyte p, Options options) {}
	void Subplot(ubyte m, ubyte n, ubyte p, string opt, Options options) {}
	void Legend(string[] lines) {}
	void Legend(string[] lines, Options options) {}
	void Hold(bool on) {}
	void Axis(int[] limits) {}
	void Axis(string option) {}
	void Grid(bool on) {}
	void Contour(double[][] Z) {}
	void Contour(double[][] Z, Options options) {}
	void Contour(double[][] Z, uint n) {}
	void Contour(double[][] Z, uint n, Options options) {}
	void Contour(double[][] Z, uint[] v) {}
	void Contour(double[][] Z, uint[] v, Options options) {}
	void Contour(double[][] X, double[][] Y, double[][] Z) {}
	void Contour(double[][] X, double[][] Y, double[][] Z, Options options) {}
	void Contour(double[][] X, double[][] Y, double[][] Z, uint n) {}
	void Contour(double[][] X, double[][] Y, double[][] Z, uint n, Options options) {}
	void Contour(double[][] X, double[][] Y, double[][] Z, uint[] v) {}
	void Contour(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options) {}
	void Contourf(double[][] Z) {}
	void Contourf(double[][] Z, Options options) {}
	void Contourf(double[][] Z, uint n) {}
	void Contourf(double[][] Z, uint n, Options options) {}
	void Contourf(double[][] Z, uint[] v) {}
	void Contourf(double[][] Z, uint[] v, Options options) {}
	void Contourf(double[][] X, double[][] Y, double[][] Z) {}
	void Contourf(double[][] X, double[][] Y, double[][] Z, Options options) {}
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint n) {}
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint n, Options options) {}
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint[] v) {}
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options) {}
	void Contour3(double[][] Z) {}
	void Contour3(double[][] Z, Options options) {}
	void Contour3(double[][] Z, uint n) {}
	void Contour3(double[][] Z, uint n, Options options) {}
	void Contour3(double[][] Z, uint[] v) {}
	void Contour3(double[][] Z, uint[] v, Options options) {}
	void Contour3(double[][] X, double[][] Y, double[][] Z) {}
	void Contour3(double[][] X, double[][] Y, double[][] Z, Options options) {}
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint n) {}
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint n, Options options) {}
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint[] v) {}
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options) {}
	void Colorbar() {}
	void Colorbar(string placement) {}
	void Colorbar(Options options) {}
	void Colorbar(string placement, Options options) {}
	void Semilogx(double[][] X, double[][] Y) {}
	void Semilogx(double[][] X, double[][] Y, string[] fmts) {}
	void Semilogy(double[][] X, double[][] Y) {}
	void Semilogy(double[][] X, double[][] Y, string[] fmts) {}
	void Loglog(double[][] X, double[][] Y) {}
	void Loglog(double[][] X, double[][] Y, string[] fmts) {}
}