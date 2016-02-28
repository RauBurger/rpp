module rpp.common.utilities;

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
	bytes ~= toUBytes!sizeT(data.length*T.sizeof);
	foreach(el; data)
		bytes ~= toUBytes!T(el);

	return bytes;
}

ubyte[] toUBytes(sizeT, Tto, T)(T[][] data)
	if(isIntegral!T || isFloatingPoint!T)
{
	ubyte[] bytes;
	bytes ~= toUBytes!sizeT(cast(sizeT)(data.length*Tto.sizeof));
	bytes ~= toUBytes!sizeT(cast(sizeT)(data[0].length*Tto.sizeof));
	foreach(slice; data)
		foreach(el; slice)
			bytes ~= toUBytes!Tto(el);

	return bytes;
}

ubyte[] toUBytes(T)(string str)
{
	static assert(isIntegral!T, "string length must be integral type");

	assert(str.length < T.max, "string to large for size type");
	ubyte[] data;
	data ~= toUBytes!T(cast(T)str.length);
	data ~= str[];
	return data;
}

T get(T)(ubyte[] data) if(isIntegral!T || is(T : double) || is(T : float))
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
{
	static assert(isIntegral!T || is(T : string) || is(T : double) || is(T : float), "Only integral types and strings supported");
	static if(isIntegral!T || is(T : double) || is(T : float))
	{
		offset += T.sizeof;
		return get!T(data[offset-T.sizeof..offset]);
	}
	else static if(is(T : string))
	{
		uint strSize = get!uint(data, offset);
		string str = "";
		foreach(el; data[offset..offset+strSize])
			str ~= el;

		offset += strSize;
		return str;
	}
}