module main;

import std.stdio;
import std.traits;
import std.conv;

import engine;
import matrix;
import mex;

struct mArray
{
	private double[] data;
	mxArray matlabData;
	ulong length;

	//alias matlabData this;

	alias data this;

	this(ulong length)
	{

		data = new double[length];
		mxSetPr(&matlabData, data.ptr);
		mxSetM(&matlabData, length);
		mxSetN(&matlabData, 1);
		//matlabData = mxCreateDoubleMatrix(1, length, mxComplexity.mxREAL);
		
		//data = mxGetPr(matlabData);
	}

	this(double initdata, ulong length)
	{
		data = new double[length];
		mxSetPr(&matlabData, data.ptr);
		mxSetM(&matlabData, length);
		mxSetN(&matlabData, 1);
		data[] = initdata;
		/*
		this.length = length;
		matlabData = mxCreateDoubleMatrix(1, length, mxComplexity.mxREAL);
		
		data = mxGetPr(matlabData);
		data[1..length] = initdata;
		*/
	}

	this(double[] initdata)
	{
		data = new double[length];
		mxSetPr(&matlabData, data.ptr);
		mxSetM(&matlabData, length);
		mxSetN(&matlabData, 1);
		data[] = initdata;
		/*
		length = initdata.length;
		matlabData = mxCreateDoubleMatrix(1, initdata.length, mxComplexity.mxREAL);
		
		data = mxGetPr(matlabData);
		data[1..initdata.length] = initdata[];
		*/
	}

	~this()
	{
		//mxDestroyArray(matlabData);
	}
/*
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
	*/
}

extern (C) int RunMatlab()
{
	writeln("Hello matlab");
	
	Engine* engine = engOpen("");

	mArray arr = mArray(100);

	if(engine == null)
	{
		writeln("Engine failed to open");
		return -1;
	}

	writeln("Copied array, off to matlab");
	engPutVariable(engine, "T", &arr.matlabData);

	writeln("making thing");
	engEvalString(engine, "D = T.^2;");
	writeln("plotting");
	engEvalString(engine, "hlines = plot(T, D);");
	engEvalString(engine, `setupPlot(hlines, '$T$', '$Y$', {'line'}, 12, 'northwest');`);

	writeln("Press return");
	readln();

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