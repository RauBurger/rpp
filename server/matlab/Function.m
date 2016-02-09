classdef Function < uint8
	enumeration
		None(-1), Plot(0), Figure(1), SetupPlot(2), Print(3), Xlabel(4), Ylabel(5), Title(6), Subplot(7), Legend(8), Hold(9), Axes(10), Grid(11)
	end
	%{
	properties
		func = -1;
	end
	
	methods 
		function r = Function(num)
			switch num
				case 0
					r.func = 0;
				case 1
					r.func = 1;
				case 2
					r.func = 2;
				case 3
					r.func = 3;
				case 4
					r.func = 4;
				case 5
					r.func = 5;
				case 6
					r.func = 6;
				case 7
					r.func = 7;
				case 8
					r.func = 8;
				case 9
					r.func = 9;
				case 10
					r.func = 10;
				case 11
					r.func = 11;
				otherwise
					r.func = -1;
			end
		end
	end
	
	methods (Static)
		function fun = makeFunction(num)
			switch num
				case 0
					fun = Function.Plot;
				case 1
					fun = Function.Figure;
				case 2
					fun = Function.SetupPlot;
				case 3
					fun = Function.Print;
				case 4
					fun = Function.Xlabel;
				case 5
					fun = Function.Ylabel;
				case 6
					fun = Function.Title;
				case 7
					fun = Function.Subplot;
				case 8
					fun = Function.Legend;
				case 9
					fun = Function.Hold;
				case 10
					fun = Function.Axes;
				case 11
					fun = Function.Grid;
				otherwise
					fun = Function.None;
			end
		end
	end
	%}
end