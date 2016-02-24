function PlotServerJava(port)
	javaaddpath('java/JavaPlotServer.jar');
	start(JavaPlotServer(port));
	
end