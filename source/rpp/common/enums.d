module rpp.common.enums;

import std.variant;

enum Command : byte
{
	None = -1,
	Function = 0,
	Data,
	Done,
	Close
}

enum Function : byte
{
	None = -1,
	Plot = 0,	// done
	Figure,		// 1	done
	SetupPlot,	// 2	done
	Print,		// 3	done
	Xlabel,		// 4	done
	Ylabel,		// 5	done
	Title,		// 6	done
	Subplot,	// 7	done - testing
	Legend,		// 8	done
	Hold,		// 9	done
	Axis,		// 10	done
	Grid,		// 11	done
	Contour,	// 12
	Contourf,	// 13
	Contour3,	// 14
	Colorbar,	// 15
	Semilogx,	// 16	done
	Semilogy,	// 17	done
	Loglog		// 18	done
}

enum ServerResponce : ubyte
{
	Ok = 0,
	MoreBytes,	// depricated
	Exception,
	Connected,
	Disconnecting
}
