function leg = setupPlot(hlines, xLabel, yLabel, legendNames, fontSize, legendLoc)

	%set(gca, 'interpreter', 'latex');
	xh = xlabel(xLabel, 'interpreter', 'latex');
	yh = ylabel(yLabel, 'interpreter', 'latex');

	s = size(hlines, 1);
	
	hs = size(hlines, 2);
	leg = 0;
	if(hs == 1)
		if(s > 1)
			for i = 1:s
				set(hlines(i), 'Displayname', char(legendNames(i)));
			end

			if(~strcmp(legendLoc, ''))
				h = legend('Location',legendLoc);
				set(h, 'interpreter', 'latex')
				leg = h;
			end

		end
	end
	
	set(gcf, 'PaperUnits', 'inches');
	set(gcf, 'PaperOrientation', 'Landscape');
	set(gca, 'FontSize', fontSize);
	set(xh, 'FontSize', fontSize);
	set(yh, 'FontSize', fontSize);

	papersize = get(gcf, 'PaperSize');

	width = 11;         % Initialize a variable for width.
	height = 8;          % Initialize a variable for height.

	left = (papersize(1)- width)/2;

	bottom = (papersize(2)- height)/2;

	myfiguresize = [left, bottom, width, height];
	set(gcf, 'PaperPosition', myfiguresize);

end