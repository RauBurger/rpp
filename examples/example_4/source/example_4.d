module example_4;

import std.stdio;
import std.math;
import std.mathspecial;

import rpp.rpc;

int main(char[][] args)
{
	initRPP("127.0.0.1", "127.0.0.1", 54000, 55000);
	real start = -12;
	real end = 12;
	int points = 1000;

	real h = (end-start)/(points-1);
	real[] x = new real[points];
	x[0] = start;

	for(int i = 1; i < points; i++)
		x[i] = x[i-1]+h;

	real[] u = new real[x.length];
	real[] u1 = new real[x.length];

	foreach(int i, _x; x)
		u[i] = sin(_x)*sin(0.5*sin(_x)*_x);

	foreach(int i, _x; x)
		u1[i] = erf(_x);

	figure();
	subplot(1, 3, 1); semilogx(x, u, "r", x, u1, "b");
	setupPlot("$x$", "$u$", ["line", "other line"], 12, "south");
	title("log(x) scale");

	subplot(1, 3, 2); semilogy(x, u, "r", x, u1, "b");
	setupPlot("$x$", "$u$", ["line", "other line"], 12, "southeast");
	axis("square");
	title("log(y) scale");

	subplot(1, 3, 3); loglog(x, u, "r", x, u1, "b");
	setupPlot("$x$", "$u$", ["line", "other line"], 12, "east");
	grid!"on"();
	title("Log-log scale");

	return 0;
}