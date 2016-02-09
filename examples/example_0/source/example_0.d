module example_0;

import std.stdio;
import std.math;

import rpp.rpc;

int main(char[][] args)
{
	rpc.initRPP("127.0.0.1", "127.0.0.1", 54000, 55000);
	rpc.Command command;
	real start = 0;
	real end = 20;
	int points = 100;

	real h = (end-start)/(points-1);
	real[] x = new real[points];
	x[0] = start;
	for(int i = 1; i < points; i++)
	{
		x[i] = x[i-1]+h;
	}

	real[] u = new real[x.length];

	for(int i = 0; i < u.length; i++)
	{
		u[i] = sin(x[i])*sin(0.5*sin(x[i])*x[i]);
	}

	figure();
	plot(x, u, "r", u, x, "c");
	figure();
	plot(u, x, "b");

	return 0;
}