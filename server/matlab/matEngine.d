module main;

import std.stdio;
import std.traits;
import std.conv;

import engine;
import matrix;
import mex;

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

struct mlArray
{
	private double* data;
	mxArray* matlabData;
	ulong length;

	alias matlabData this;

	this(ulong length)
	{
		matlabData = mxCreateDoubleMatrix(1, length, mxComplexity.mxREAL);
		
		data = mxGetPr(matlabData);
	}

	this(double initdata, ulong length)
	{
		this.length = length;
		matlabData = mxCreateDoubleMatrix(1, length, mxComplexity.mxREAL);
		
		data = mxGetPr(matlabData);
		data[0..length] = initdata;
	}

	this(double[] initdata)
	{		
		length = initdata.length;
		matlabData = mxCreateDoubleMatrix(1, initdata.length, mxComplexity.mxREAL);
		
		data = mxGetPr(matlabData);
		data[0..length] = initdata[];
	}

	~this()
	{
		mxDestroyArray(matlabData);
	}

	ref double opIndex(ulong idx)
	{
		writeln("in opIndex 1");
		return data[idx];
	}

	double[] opIndex(ulong idx1, ulong idx2)
	{
		writeln("in opIndex 2");
		return data[idx1..idx2];
	}

	double[] opIndex(ulong[2] idx1)
	{
		writeln("in opIndex 2");
		return data[idx1[0]..idx1[1]];
	}

	double[] opSlice(ulong start, ulong end)
	{
		writeln("In opSlice");
		return data[start..end];
	}

	int opApply(int delegate(int idx, ref double) dg)
	{
		int result = 0;
		for(int i = 0; i < length; i++)
		{
			result = dg(i, data[i]);
			if(result)
				break;
		}
		return result;
	}

	int opApply(int delegate(ref double) dg)
	{
		int result = 0;
		for(int i = 0; i < length; i++)
		{
			result = dg(data[i]);
			if(result)
				break;
		}
		return result;
	}
}

extern (C) int RunMatlab()
{
	writeln("Hello matlab");
	
	Engine* engine = engOpen("");

	if(engine == null)
	{
		writeln("Engine failed to open");
		return -1;
	}

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

	return 0;
}

int main()
{
	return RunMatlab();
}