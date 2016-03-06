module rpp.common.utilities;

import std.conv;
import std.meta;
import std.traits;
import std.stdio;

ubyte[T.sizeof] toUBytes(T)(T data)
	if (isIntegral!T || isFloatingPoint!T)
{
	union conv
	{
		T type;
		ubyte[T.sizeof] b;
	}
	conv tb = { type : data };
	return tb.b;
}

ubyte[] toUBytes(sizeT, T)(T[] data)
	if(isIntegral!T || isFloatingPoint!T)
{
	ubyte[] bytes;
	bytes ~= toUBytes!sizeT(data.length*(ForeachType!T).sizeof);
	foreach(el; data)
		bytes ~= toUBytes!T(el);

	return bytes;
}

ubyte[] toUBytes(sizeT, toT, T)(T[][] data)
	if(isIntegral!T || isFloatingPoint!T)
{
	ubyte[] bytes;
	bytes ~= toUBytes!sizeT(cast(sizeT)(data.length*toT.sizeof));
	bytes ~= toUBytes!sizeT(cast(sizeT)(data[0].length*toT.sizeof));
	foreach(slice; data)
		foreach(el; slice)
			bytes ~= toUBytes!toT(el);

	return bytes;
}

ubyte[] toUBytes(T)(string str)
{
	static assert(isIntegral!T, "string length must be integral type");

	assert(str.length < T.max, "string to large for size type");
	ubyte[] data;
	data ~= toUBytes!T(to!T(str.length));
	data ~= str[];
	return data;
}

T get(T)(ubyte[] data)
	if(isIntegral!T || is(T : double) || is(T : float))
{
	union conv
	{
		T type;
		ubyte[T.sizeof] b;
	}
	conv tb;
	tb.b[] = data[];
	return tb.type;
}

T get(T)(ubyte[] data, ref uint offset)
	if(isIntegral!T || is(T : double) || is(T : float))
{
	offset += T.sizeof;
	return get!T(data[offset-T.sizeof..offset]);
}

T get(T, sizeT)(ubyte[] data, ref uint offset)
	if(is(T : string) || isArray!T)
{
	static if(is(T: string))
	{
		sizeT strSize = get!sizeT(data, offset);
		string str = "";
		foreach(el; data[offset..offset+strSize])
			str ~= el;

		offset += strSize;
		return str;
	}
	else static if(!isArray!(ForeachType!T))
	{
		sizeT dim = get!sizeT(data, offset)/(ForeachType!T).sizeof;

		T arr = new T(dim);

		foreach(ref el; arr)
		{
			el = get!(ForeachType!T)(data, offset);
		}
		return arr;
	}
	else static if(isArray!(ForeachType!T) && !isArray!(ForeachType!(ForeachType!T)))
	{
		sizeT dim1 = get!sizeT(data, offset)/(ForeachType!(ForeachType!T)).sizeof;
		sizeT dim2 = get!sizeT(data, offset)/(ForeachType!(ForeachType!T)).sizeof;

		T arr = new T(dim1, dim2);

		foreach(ref subarr; arr)
		{
			foreach(ref el; subarr)
			{
				el = get!(ForeachType!(ForeachType!T))(data, offset);
			}
		}

		return arr;
	}	
	else
	{
		static assert(0, "Not implimented");
	}
}