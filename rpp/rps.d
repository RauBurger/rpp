module rpp.rps;

import std.stdio;
import std.conv;
import core.runtime;

extern(C) int heyThere()
{
	Runtime.initialize();
	writeln("hey sexy!");
	double[] x = new double[52];
	foreach(int i, ref el; x)
		el = to!double(i);
	return to!int(x[50]);
}