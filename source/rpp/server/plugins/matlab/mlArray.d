module matlab.mlArray;

import std.experimental.allocator.mallocator;
import std.stdio;
import std.traits;

import matlab.mex;
import matlab.matrix;

// Based of phobos Mallocator implementation
@nogc void[] allocate(size_t bytes)
{
	if(!bytes) return null;
	auto p = mxMalloc(bytes);
	return p ? p[0..bytes] : null;
}

struct mlArray(T)
	if((is(T: double) && !isArray!T) ||
		is(T: string))
{
	static if(!is(T: string))
	{
		T[] data;
	}
	else
	{
		T data;
	}

	mxArray* matlabData;

	alias data this;

	@nogc this(ulong length)
	{
		static if(!is(T: string))
		{
			matlabData = mxCreateDoubleMatrix(0, 0, mxComplexity.mxREAL);
			data = cast(T[])allocate(length*T.sizeof);
			mxSetM(matlabData, length);
			mxSetN(matlabData, 1);
			mxSetPr(matlabData, data.ptr);
		}
	}

	@nogc this(T initdata, ulong length)
	{
		static if(!is(T: string))
		{
			matlabData = mxCreateDoubleMatrix(0, 0, mxComplexity.mxREAL);
			data = cast(T[])allocate(length*T.sizeof);
			mxSetM(matlabData, length);
			mxSetN(matlabData, 1);
			mxSetPr(matlabData, data.ptr);
			data[] = initdata;
		}
	}

	@nogc this(string initdata)
	{
		static if(is(T: string))
		{
			matlabData = mxCreateString(null);
			data = cast(T)allocate(initdata.length);
			mxSetM(matlabData, initdata.length);
			mxSetN(matlabData, 1);
			mxSetData(matlabData, cast(void*)data.ptr);
			data = initdata[]; // not sure if this does what I want
		}
	}

	@nogc this(T[] initdata)
	{
		static if(!is(T: string))
		{
			matlabData = mxCreateDoubleMatrix(0, 0, mxComplexity.mxREAL);
			data = cast(T[])allocate(initdata.length*T.sizeof);
			mxSetM(matlabData, initdata.length);
			mxSetN(matlabData, 1);
			mxSetPr(matlabData, data.ptr);
			data[] = initdata[];
		}
	}

	@nogc ~this()
	{
		static if(!is(T: string))
		{
			mxSetData(matlabData, null);
			mxDestroyArray(matlabData);
			mxFree(data.ptr);
		}
	}
}

struct mlArray2D
{
	double[] data;

	mxArray* matlabData;

	alias data this;

	@nogc this(ulong dim1, ulong dim2)
	{
		matlabData = mxCreateDoubleMatrix(0, 0, mxComplexity.mxREAL);
		data = cast(double[])allocate(dim1*dim2*double.sizeof);
		mxSetM(matlabData, dim1);
		mxSetN(matlabData, dim2);
		mxSetPr(matlabData, data.ptr);
	}

	@nogc this(double initdata, ulong dim1, ulong dim2)
	{
		matlabData = mxCreateDoubleMatrix(0, 0, mxComplexity.mxREAL);
		data = cast(double[])allocate(dim1*dim2*double.sizeof);
		
		mxSetM(matlabData, dim1);
		mxSetN(matlabData, dim2);
		mxSetPr(matlabData, data.ptr);
		
		data[] = initdata;
	}

	@nogc this(double[][] initdata)
	{
		matlabData = mxCreateDoubleMatrix(0, 0, mxComplexity.mxREAL);
		
		data = cast(double[])allocate(initdata.length*initdata[0].length*double.sizeof);

		mxSetM(matlabData, initdata.length);
		mxSetN(matlabData, initdata[0].length);
		mxSetPr(matlabData, data.ptr);

		ulong offset = 0;
		for(int i = 0; i < initdata.length; i++)
		{
			data[offset..offset+initdata.length] = initdata[i][];
			offset += initdata[i].length;
		}
	}

	@nogc ~this()
	{
		mxSetData(matlabData, null);
		mxDestroyArray(matlabData);
		mxFree(data.ptr);
	}
}