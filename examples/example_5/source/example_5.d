module example_5;

import std.stdio;
import std.math;
import std.mathspecial;

import rpp.rpc;
import numd.utility;

struct Meshgrid
{
	real[][] X;
	real[][] Y;
}

Meshgrid meshgrid(real[] x, real[] y)
{
	Meshgrid mesh = {X: new real[][](y.length, x.length), Y: new real[][](y.length, x.length)};

	for(int i = 0; i < y.length; i++)
		for(int j = 0; j < x.length; j++)
			mesh.X[i][j] = x[j];

	for(int i = 0; i < y.length; i++)
		for(int j = 0; j < x.length; j++)
			mesh.Y[i][j] = y[i];

	return mesh;
}

int main(char[][] args)
{
	initRPP("127.0.0.1", "127.0.0.1", 54000, 55000);

	real start = -5;
	real end = 5;
	int points = 200;
	Meshgrid grid = meshgrid(linspace(-5, 5, points), linspace(-5, 5, points));

	real[][] Z = new real[][](points, points);

	for(int i = 0; i < points; i++)
		for(int j = 0; j < points; j++)
			Z[i][j] = (1 - grid.X[i][j])^^2 + 1*(grid.Y[i][j] - grid.X[i][j]^^2)^^2;

	contourf(grid.X, grid.Y, Z, 100, "LineStyle", "none");

	return 0;
}