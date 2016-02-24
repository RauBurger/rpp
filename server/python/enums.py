
class Command:
	Idle = -1
	Function, \
	Data, \
	Done, \
	Close = range(4)

class Function:
	Nothing = -1
	Plot, \
	Figure, \
	SetupPlot, \
	Print, \
	Xlabel, \
	Ylabel, \
	Title, \
	Subplot, \
	Legend, \
	Hold, \
	Axis, \
	Grid, \
	Contour, \
	Contourf, \
	Contour3, \
	Colorbar, \
	Semilogx, \
	Semilogy, \
	Loglog = range(19)
