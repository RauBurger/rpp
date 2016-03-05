module matlab.mlArray;

import std.experimental.allocator.mallocator;
import std.stdio;

import matlab.mex;
import matlab.matrix;

// Based of phobos Mallocator implementation
@nogc void[] allocate(size_t bytes)
{
	if(!bytes) return null;
	auto p = mxMalloc(bytes);
	return p ? p[0..bytes] : null;
}

struct mlArray
{
	double[] data;
	mxArray* matlabData;

	alias data this;

	@nogc this(ulong length)
	{
		matlabData = mxCreateDoubleMatrix(0, 0, mxComplexity.mxREAL);
		data = cast(double[])allocate(length*double.sizeof);
		mxSetM(matlabData, length);
		mxSetN(matlabData, 1);
		mxSetPr(matlabData, data.ptr);
	}

	@nogc this(double initdata, ulong length)
	{
		matlabData = mxCreateDoubleMatrix(0, 0, mxComplexity.mxREAL);
		data = cast(double[])allocate(length*double.sizeof);
		mxSetM(matlabData, length);
		mxSetN(matlabData, 1);
		mxSetPr(matlabData, data.ptr);

		data[] = initdata;
	}

	@nogc this(double[] initdata)
	{
		matlabData = mxCreateDoubleMatrix(0, 0, mxComplexity.mxREAL);
		data = cast(double[])allocate(initdata.length*double.sizeof);
		mxSetM(matlabData, data.length);
		mxSetN(matlabData, 1);
		mxSetPr(matlabData, data.ptr);
		
		data[] = initdata[];
	}

	@nogc ~this()
	{
		mxSetData(matlabData, null);
		mxDestroyArray(matlabData);
		mxFree(data.ptr);
	}
}