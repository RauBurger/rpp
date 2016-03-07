#!/usr/bin/env rdmd

import std.conv;
import std.file;
import std.json;
import std.stdio;
import std.string;

int main(string[] args)
{
	if(args.length != 3)
	{
		writeln("Invalid number of arguments. Expected /path/to/package and /path/to/output");
		return -1;
	}

	string pluginDir = args[1];
	string outputDir = args[2];

	if(!exists(outputDir))
	{
		writeln(outputDir, " does not exist!");
		return -1;
	}

	if(!exists(pluginDir~"dub.json"))
	{
		writeln("Can't find dub.json");
	}

	string dubFile = cast(immutable(char)[])std.file.read(pluginDir~"dub.json");

	JSONValue dub = parseJSON(dubFile);

	string targetName = dub["targetName"].to!string.removechars(`"`);
	string dubBuildName = `lib`~targetName~`.so`;

	string dubBuildPath = outputDir~`/`~dubBuildName;
	string outputPath = outputDir~`/`~targetName~`.plg`;

	("Renaming "~dubBuildName~" -> "~targetName~`.plg`).writeln;
	if(exists(dubBuildPath))
	{
		rename(dubBuildPath, outputPath);
	}

	return 0;
}