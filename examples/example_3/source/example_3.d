module example_3;

import std.stdio;
import std.math;
import std.mathspecial;

import rpp.rpc;

int main(char[][] args)
{
	initRPP("192.168.2.129", "192.168.2.43", 54000, 55000);
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
	subplot(1, 2, 1); plot(x, u);
	setupPlot("$x$", "$u$", ["line"], 12, "");
	axes([-12, 12, -1, 1]);
	title("Some lines!");

	subplot(1, 2, 2); plot(x, u1);
	setupPlot("$x$", "$u$", ["line"], 12, "");
	axes("square");
	title("Some lines!");

	return 0;
}