module matlab.mlArray;

import std.stdio;

import matlab.mex;
import matlab.matrix;

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