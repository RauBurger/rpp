module matlab.matlabBacked;

import std.conv;
import std.experimental.allocator.mallocator;
import std.stdio;
import std.string;

import rpp.server.backend;
import rpp.common.enums;

import matlab.engine;
import matlab.mex;
import matlab.mlArray;

extern (C) IServerBackend InitBackend()
{
	return new MatlabBackend();
}

class MatlabBackend : IServerBackend
{
	Engine* engine;

	this()
	{	
		engine = engOpen("matlab -nosplash");

		if(engine == null)
		{
			throw new Exception("Failed to open matlab engine");
		}
	}

	~this()
	{
		engClose(engine);
	}
	
	void Plot(double[][] X, double[][] Y)
	{
		plotImpl!(Function.Plot)(X, Y, null);
	}
	
	void Plot(double[][] X, double[][] Y, string[] fmts)
	{
		plotImpl!(Function.Plot)(X, Y, fmts);
	}
	
	private string optionsToCommandString(Options options)
	{
		string opts = "";
		if(options !is null)
		{
			foreach(option; options.keys)
			{
				opts ~= `'` ~ option ~ `',`;
				if(options[option].type == typeid(immutable(char)[]))
				{
					opts ~= `'` ~ options[option].get!string ~ `',`;
				}
				else
				{
					opts ~= options[option].to!string ~ `,`;
				}
			}
		}

		return opts;
	}

	private void plotImpl(Function func)(double[][] X, double[][] Y, string[] fmts)
	{
		string command = `hlines = `~func.to!string.toLower~`(`;

		foreach(ulong i; 0..X.length)
		{
			auto x = mlArray!double(X[i]);
			auto y = mlArray!double(Y[i]);

			string xStr = "X"~i.to!string;
			string yStr = "Y"~i.to!string;

			engPutVariable(engine, xStr.toStringz, x.matlabData);
			engPutVariable(engine, yStr.toStringz, y.matlabData);

			if(fmts is null)
			{
				command ~= xStr~", "~yStr~", ";
			}
			else
			{
				command ~= xStr~", "~yStr~`, '`~fmts[i]~`', `;
			}
		}

		command = command.chomp(", ") ~ ");";

		engEvalString(engine, command.toStringz);
	}

	void Figure()
	{
		engEvalString(engine, "figure;");
	}

	void Figure(Options options)
	{
		string command = `figure(`;

		command ~= optionsToCommandString(options);

		command = command.chomp(`,`) ~ `);`;

		engEvalString(engine, command.toStringz);
	}

	void SetupPlot(string xlabel, string ylabel, string[] legendNames, ubyte fontSize, string legendLoc)
	{
		string command = `setupPlot(hlines, '`~xlabel~`', '`~ylabel~`', {'`;

		foreach(immutable name; legendNames)
		{
			command ~= name ~ `','`;
		}

		command = command.chomp(`,'`) ~ `},`~fontSize.to!string~`,'`~legendLoc~`');`;

		engEvalString(engine, command.toStringz);
	}

	void Print(string format, string path)
	{
		string command = `print('`~path~`','`~format~`');`;
		engEvalString(engine, command.toStringz);
	}

	void Xlabel(string label)
	{
		textLabelImpl!(Function.Xlabel)(label, null);
	}

	void Xlabel(string label, Options options)
	{
		textLabelImpl!(Function.Xlabel)(label, options);
	}

	void Ylabel(string label)
	{
		textLabelImpl!(Function.Ylabel)(label, null);
	}
	
	void Ylabel(string label, Options options)
	{
		textLabelImpl!(Function.Ylabel)(label, options);
	}
	
	void Title(string label)
	{
		textLabelImpl!(Function.Title)(label, null);
	}
	
	void Title(string label, Options options)
	{
		textLabelImpl!(Function.Title)(label, options);
	}
	
	private void textLabelImpl(Function func)(string label, Options options)
	{
		string command = func.to!string.toLower~`('`~label~`',`;

		command ~= optionsToCommandString(options);

		command = command.chomp(",") ~ `);`;

		engEvalString(engine, command.toStringz);
	}

	void Subplot(ubyte m, ubyte n, ubyte p)
	{
		subplotImpl(m, n, p, null, null);
	}
	
	void Subplot(ubyte m, ubyte n, ubyte p, string opt)
	{
		subplotImpl(m, n, p, opt, null);
	}
	
	void Subplot(ubyte m, ubyte n, ubyte p, Options options)
	{
		subplotImpl(m, n, p, null, options);
	}
	
	void Subplot(ubyte m, ubyte n, ubyte p, string opt, Options options)
	{
		subplotImpl(m, n, p, opt, options);
	}

	void subplotImpl(ubyte m, ubyte n, ubyte p, string opt, Options options)
	{
		string command = `subplot(` ~ m.to!string ~ `,` ~ n.to!string ~ `,` ~ p.to!string ~ `,`;

		if(opt !is null)
		{
			command ~= `'` ~ opt ~ `',`;
		}

		command ~= optionsToCommandString(options);

		command = command.chomp(`,`) ~ `);`;

		engEvalString(engine, command.toStringz);
	}
	
	void Legend(string[] lines)
	{
		legendImpl(lines, null);
	}
	
	void Legend(string[] lines, Options options)
	{
		legendImpl(lines, options);
	}
	
	private void legendImpl(string[] lines, Options options)
	{
		string command = `legend({`;

		foreach(line; lines)
		{
			command ~= `'`~line~`',`;
		}

		command = command.chomp(`,`) ~ `},`;

		command ~= optionsToCommandString(options);

		command = command.chomp(`,`) ~ `);`;

		engEvalString(engine, command.toStringz);
	}

	void Hold(bool on)
	{
		if(on)
		{
			engEvalString(engine, `hold on;`);
		}
		else
		{
			engEvalString(engine, `hold off;`);
		}
	}
	
	void Axis(double[] limits)
	{
		string command = `axis([`~limits[0].to!string~`,`~limits[1].to!string~`,`~limits[2].to!string~`,`~limits[3].to!string~`]);`;
		engEvalString(engine, command.toStringz);
	}
	
	void Axis(string option)
	{
		string command = `axis('` ~ option ~ `');`;
		engEvalString(engine, command.toStringz);
	}
	
	void Caxis(double[] limits)
	{
		string command = `caxis([`~limits[0].to!string~`,`~limits[1].to!string~`]);`;
		engEvalString(engine, command.toStringz);
	}
	
	void Caxis(string option)
	{
		string command = `caxis('` ~ option ~ `');`;
		engEvalString(engine, command.toStringz);
	}
	
	void Grid(bool on)
	{
		if(on)
		{
			engEvalString(engine, `grid on;`);
		}
		else
		{
			engEvalString(engine, `grid off;`);
		}
	}
	
	void Contour(double[][] Z)
	{
		contourImpl!(Function.Contour, 0)(null, null, Z, 0, null, null);
	}
	
	void Contour(double[][] Z, Options options)
	{
		contourImpl!(Function.Contour, 0)(null, null, Z, 0, null, options);
	}
	
	void Contour(double[][] Z, uint n)
	{
		contourImpl!(Function.Contour, 1)(null, null, Z, n, null, null);
	}
	
	void Contour(double[][] Z, uint n, Options options)
	{
		contourImpl!(Function.Contour, 1)(null, null, Z, n, null, options);
	}
	
	void Contour(double[][] Z, uint[] v)
	{
		contourImpl!(Function.Contour, 2)(null, null, Z, 0, v, null);
	}
	
	void Contour(double[][] Z, uint[] v, Options options)
	{
		contourImpl!(Function.Contour, 2)(null, null, Z, 0, v, options);
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z)
	{
		contourImpl!(Function.Contour, 3)(X, Y, Z, 0, null, null);
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, Options options)
	{
		contourImpl!(Function.Contour, 3)(X, Y, Z, 0, null, options);
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, uint n)
	{
		contourImpl!(Function.Contour, 4)(X, Y, Z, n, null, null);
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, uint n, Options options)
	{
		contourImpl!(Function.Contour, 4)(X, Y, Z, n, null, options);
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, uint[] v)
	{
		contourImpl!(Function.Contour, 5)(X, Y, Z, 0, v, null);
	}
	
	void Contour(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options)
	{
		contourImpl!(Function.Contour, 5)(X, Y, Z, 0, v, options);
	}
	
	void Contourf(double[][] Z)
	{
		contourImpl!(Function.Contourf, 0)(null, null, Z, 0, null, null);
	}
	
	void Contourf(double[][] Z, Options options)
	{
		contourImpl!(Function.Contourf, 0)(null, null, Z, 0, null, options);
	}
	
	void Contourf(double[][] Z, uint n)
	{
		contourImpl!(Function.Contourf, 1)(null, null, Z, n, null, null);
	}
	
	void Contourf(double[][] Z, uint n, Options options)
	{
		contourImpl!(Function.Contourf, 1)(null, null, Z, n, null, options);
	}
	
	void Contourf(double[][] Z, uint[] v)
	{
		contourImpl!(Function.Contourf, 2)(null, null, Z, 0, v, null);
	}
	
	void Contourf(double[][] Z, uint[] v, Options options)
	{
		contourImpl!(Function.Contourf, 2)(null, null, Z, 0, v, options);
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z)
	{
		contourImpl!(Function.Contourf, 3)(X, Y, Z, 0, null, null);
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z, Options options)
	{
		contourImpl!(Function.Contourf, 3)(X, Y, Z, 0, null, options);
	}

	void Contourf(double[][] X, double[][] Y, double[][] Z, uint n)
	{
		contourImpl!(Function.Contourf, 4)(X, Y, Z, n, null, null);
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint n, Options options)
	{
		contourImpl!(Function.Contourf, 4)(X, Y, Z, n, null, options);
	}
	
	void Contourf(double[][] X, double[][] Y, double[][] Z, uint[] v)
	{
		contourImpl!(Function.Contourf, 5)(X, Y, Z, 0, v, null);
	}

	void Contourf(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options)
	{
		contourImpl!(Function.Contourf, 5)(X, Y, Z, 0, v, options);
	}

	void Contour3(double[][] Z)
	{
		contourImpl!(Function.Contour3, 0)(null, null, Z, 0, null, null);
	}
	
	void Contour3(double[][] Z, Options options)
	{
		contourImpl!(Function.Contour3, 0)(null, null, Z, 0, null, options);
	}
	
	void Contour3(double[][] Z, uint n)
	{
		contourImpl!(Function.Contour3, 1)(null, null, Z, n, null, null);
	}
	
	void Contour3(double[][] Z, uint n, Options options)
	{
		contourImpl!(Function.Contour3, 1)(null, null, Z, n, null, options);
	}
	
	void Contour3(double[][] Z, uint[] v)
	{
		contourImpl!(Function.Contour3, 2)(null, null, Z, 0, v, null);
	}
	
	void Contour3(double[][] Z, uint[] v, Options options)
	{
		contourImpl!(Function.Contour3, 2)(null, null, Z, 0, v, options);
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z)
	{
		contourImpl!(Function.Contour3, 3)(X, Y, Z, 0, null, null);
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, Options options)
	{
		contourImpl!(Function.Contour3, 3)(X, Y, Z, 0, null, options);
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint n)
	{
		contourImpl!(Function.Contour3, 4)(X, Y, Z, n, null, null);
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint n, Options options)
	{
		contourImpl!(Function.Contour3, 4)(X, Y, Z, n, null, options);
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint[] v)
	{
		contourImpl!(Function.Contour3, 5)(X, Y, Z, 0, v, null);
	}
	
	void Contour3(double[][] X, double[][] Y, double[][] Z, uint[] v, Options options)
	{
		contourImpl!(Function.Contour3, 5)(X, Y, Z, 0, v, options);
	}
	
	private void contourImpl(Function func, int type)(double[][]X, double[][]Y, double[][]Z, uint n, uint[] v, Options options)
	{
		assert(Z !is null);
		auto z = mlArray2D(Z);
		engPutVariable(engine, "Z", z.matlabData);
		string command = `hlines = `~func.to!string.toLower~`(`;

		static if(type == 0)
		{
			command ~= `Z,`;
		}
		else static if(type == 1)
		{
			command ~= `Z,`~n.to!string~`,`;
		}
		else static if(type == 2)
		{
			assert(v !is null);
			auto V = mlArray!double(to!(double[])(v));
			engPutVariable(engine, "v", V.matlabData);

			command ~= `Z, v,`;
		}
		else static if((type == 3) || (type == 4) || (type == 5))
		{
			assert(X !is null);
			assert(Y !is null);
			auto x = mlArray2D(X);
			auto y = mlArray2D(Y);
			engPutVariable(engine, "X", x.matlabData);
			engPutVariable(engine, "Y", y.matlabData);

			command ~= `X, Y, Z,`;

			static if(type == 4)
			{
				command ~= n.to!string~`,`;
			}
			else static if(type == 5)
			{
				assert(v !is null);
				auto V = mlArray!double(to!(double[])(v));
				engPutVariable(engine, "v", V.matlabData);
				command ~= `v,`;
			}
		}

		command ~= optionsToCommandString(options);
		command = command.chomp(`,`) ~ `);`;
		engEvalString(engine, command.toStringz);
	}

	void Colorbar()
	{
		engEvalString(engine, `colorbar;`);
	}
	
	void Colorbar(string placement)
	{
		string command = `colorbar('` ~ placement ~ `');`;
		engEvalString(engine, command.toStringz);
	}
	
	void Colorbar(Options options)
	{
		string command = `colorbar(`;
		command ~= optionsToCommandString(options);
		command = command.chomp(",") ~ `);`;
		engEvalString(engine, command.toStringz);
	}
	
	void Colorbar(string placement, Options options)
	{
		string command = `colorbar('` ~ placement ~ `',`;
		command ~= optionsToCommandString(options);
		command = command.chomp(",") ~ `);`;
		engEvalString(engine, command.toStringz);
	}
	
	void Semilogx(double[][] X, double[][] Y)
	{
		plotImpl!(Function.Semilogx)(X, Y, null);
	}
	
	void Semilogx(double[][] X, double[][] Y, string[] fmts)
	{
		plotImpl!(Function.Semilogx)(X, Y, fmts);
	}
	
	void Semilogy(double[][] X, double[][] Y)
	{
		plotImpl!(Function.Semilogy)(X, Y, null);
	}
	
	void Semilogy(double[][] X, double[][] Y, string[] fmts)
	{
		plotImpl!(Function.Semilogy)(X, Y, fmts);
	}
	
	void Loglog(double[][] X, double[][] Y)
	{
		plotImpl!(Function.Loglog)(X, Y, null);
	}
	
	void Loglog(double[][] X, double[][] Y, string[] fmts)
	{
		plotImpl!(Function.Loglog)(X, Y, fmts);
	}
	
}