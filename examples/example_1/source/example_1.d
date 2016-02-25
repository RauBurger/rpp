module example_1;

import std.stdio;
import std.math;

import rpp.rpc;

int main(char[][] args)
{
	initRPP(`127.0.0.1`, 54000);

	real start = 0;
	real end = 20;
	int points = 400;

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
	plot(x, u, "r", x, u1, "c");
	xlabel("$x_1$", "interpreter", "latex");
	legend(["$u_1$", "$u_2$"], "interpreter", "latex");

	print!"-dpdf"("example_1.pdf");
	print!"-djpeg"("example_1.jpeg");
	print!"-dpng"("example_1.png");
	print!"-dbmp"("example_1.bmp");

	hold!"on"();
	plot(x, u1, "b");
	hold!"off"();
	plot(x, u1, "g");

	return 0;
}