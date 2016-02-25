module example_0;

import std.stdio;
import std.math;

import rpp.rpc;

int main(char[][] args)
{
	initRPP(`127.0.0.1`, 54000);

	real start = 0;
	real end = 20;
	int points = 300;

	real h = (end-start)/(points-1);
	real[] x = new real[points];
	x[0] = start;

	for(int i = 1; i < points; i++)
		x[i] = x[i-1]+h;

	real[] u = new real[x.length];

	foreach(int i, _x; x)
		u[i] = sin(_x)*sin(0.5*sin(_x)*_x);

	figure();
	plot(x, u, u, x);
	figure();
	plot(u, x, "b");

	return 0;
}