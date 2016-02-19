module example_2;

import std.stdio;
import std.math;

import rpp;

int main(char[][] args)
{
	initRPP("127.0.0.1", "127.0.0.1", 54000, 55000);
	real start = 0;
	real end = 20;
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
		u1[i] = sin(0.5*sin(_x)*_x);

	figure();
	plot(x, u, "r", x, u1, "b");
	setupPlot("$x$", "$u$", ["$u$", "$u_1$"], 12, "northwest");
	title("Some lines!");
	
	return 0;
}