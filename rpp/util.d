module rpp.util;

import std.traits;

package ubyte[T.sizeof] toUBytes(T)(T data)
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

package ubyte[] toUBytes(sizeT, T)(T[] data)
	if(isIntegral!T || isFloatingPoint!T)
{
	ubyte[] bytes;
	bytes ~= toUBytes!sizeT(data.length*T.sizeof);
	foreach(el; data)
		bytes ~= toUBytes!T(el);

	return bytes;
}

package ubyte[] toUBytes(sizeT, T)(T[][] data)
	if(isIntegral!T || isFloatingPoint!T)
{
	ubyte[] bytes;
	bytes ~= toUBytes!sizeT(data.length*T.sizeof*data[0].length);
	foreach(slice; data)
		foreach(el; slice)
			bytes ~= toUBytes!T(el);

	return bytes;
}

package ubyte[] toUBytes(T)(string str)
{
	static assert(isIntegral!T, "string length must be integral type");

	assert(str.length < T.max, "string to large for size type");
	ubyte[] data;
	data ~= toUBytes!T(cast(T)str.length);
	data ~= str[];
	return data;
}

package T get(T)(ubyte[] data) if(isIntegral!T || is(T : double) || is(T : float))
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

package T get(T)(ubyte[] data, ref uint offset)
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