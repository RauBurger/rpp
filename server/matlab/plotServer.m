function plotServer(address, remotePort, localPort)

	%u = udp(address, remotePort, 'LocalPort', localPort, 'Timeout', .005);
	u = tcpip('0.0.0.0', 54000, 'NetworkRole', 'server', 'Timeout', 0.005);
	
	c = onCleanup(@()cleanUp(u));
	%t = timer('TimerFcn',@(x,y)timerCallback(x, y, u),'StartDelay',0, 'TasksToExecute', 1, 'ExecutionMode', 'fixedRate', 'Period', 0.1); % 
	
	try
		holdOn = false;		
		%u.InputBufferSize = 4096;
		%u.InputBufferSize = 512;
		u.InputBufferSize = 9216;
		
		while(1)
			%start(t);
			fopen(u);
			%while(strcmp(u.Status, 'closed'))
			%	fprintf('no connection\n');
			%	drawnow;
			%end
			fprintf('Server open\n');
			connected = true;

			fwrite(u, uint8([0, 255, 255, 255, 255]));
			currentFunction = Function.None;
			currentPayload = 10;
			while(connected == true)

				bytesRead = 0;

				warning('off', 'instrument:fread:unsuccessfulRead');

				waitForBytes(u);
				data = fread(u, u.BytesAvailable, 'uint8');
				
				bytesRead = bytesRead + max(size(data));

				while(bytesRead < currentPayload)
					%fprintf('1 currentPayload = %d\tbytesRead = %d\n', currentPayload, bytesRead);
					drawnow();
					payload = [uint8(1), typecast(uint32(bytesRead), 'uint8')];
					%fwrite(u, payload, 'uint8');
					waitForBytes(u);
					newData = fread(u, u.BytesAvailable, 'uint8');
					bytesRead = bytesRead + max(size(newData));
					data = [data; newData];
				end
				warning('on', 'instrument:fread:unsuccessfulRead');
				
				drawnow();
				%fprintf('2 currentPayload = %d\tbytesRead = %d\n', currentPayload, bytesRead);
				payload = [uint8(0), typecast(uint32(bytesRead), 'uint8')];
				fwrite(u, payload, 'uint8');

				currentCommand = data(1);

				switch currentCommand
					case Command.Function
						currentFunction = data(2);
						currentPayload = double(typecast(uint8(data(3:end)), 'uint64'));
					case Command.Data
						switch currentFunction
							case Function.Plot
								hlines = Plot(data, holdOn, currentFunction);
							case Function.Figure
								figure;
								drawnow;

							case Function.SetupPlot
								SetupPlot(data', hlines);

							case Function.Print
								Print(data);

							case Function.Xlabel
								textLabel(currentFunction, data');

							case Function.Ylabel
								textLabel(currentFunction, data');

							case Function.Title
								textLabel(currentFunction, data');

							case Function.Subplot
								Subplot(data);

							case Function.Legend
								Legend(data');

							case Function.Hold
								if(data(2) == 1)
									hold on;
									holdOn = true;
								elseif(data(2) == 0)
									hold off;
									holdOn = false;
								end

							case Function.Axis
								Axis(data);

							case Function.Grid
								if(data(2) == 1)
									grid on;
								elseif(data(2) == 0)
									grid off;
								end
								
							case Function.Contour
								Contour(data', Function.Contour);
								
							case Function.Contourf
								Contour(data', Function.Contourf);
								
							case Function.Contour3
								Contour(data', Function.Contour3);

							case Function.Colorbar
								
							case Function.Semilogx
								hlines = Plot(data, holdOn, currentFunction);
								
							case Function.Semilogy
								hlines = Plot(data, holdOn, currentFunction);
								
							case Function.Loglog
								hlines = Plot(data, holdOn, currentFunction);
								
							otherwise

						end

						currentFunction = Function.None;
						currentPayload = 1;
						drawnow;
					case Command.Done
						currentPayload = 10;
						
					case Command.Close
						fprintf('Closing connection\n');
						fwrite(u, uint8([0, 4, 255, 89, 255]), 'uint8');
						fclose(u);
						connected = false;
					otherwise

				end
			end
		end
	catch ME
		SendException(u, ME);
		fclose(u);
		throw(ME);
	end
end

function SendException(u, ME)

	% exception id
	data = typecast(uint32(size(ME.identifier,2)), 'uint8');
	data = [data, uint8(ME.identifier)];
	
	% exception message
	data = [data, typecast(uint32(size(ME.message,2)), 'uint8')];
	data = [data, uint8(ME.message)];

	% Number of stack entries
	data = [data, typecast(uint32(max(size(ME.stack))), 'uint8')];

	% stack trace
	for i=1:max(size(ME.stack))
		data = [data, typecast(uint32(max(size(ME.stack(i).file))), 'uint8')];
		data = [data, uint8(ME.stack(i).file)];

		data = [data, typecast(uint32(max(size(ME.stack(i).name))), 'uint8')];
		data = [data, uint8(ME.stack(i).name)];

		data = [data, typecast(uint32(ME.stack(i).line), 'uint8')];
	end

	requestData(1) = 3;
	requestData = [requestData, typecast(uint32(max(size(data))),'uint8')];
	
	fwrite(u, requestData, 'uint8');
	fwrite(u, data, 'uint8');
end

function [str, offset] = getStr(lengthType, data, offset)
	if(strcmp(lengthType, 'uint8'))
		lengthSize = 1;
	elseif(strcmp(lengthType, 'uint16'))
		lengthSize = 2;
	elseif(strcmp(lengthType, 'uint32'))
		lengthSize = 4;
	end

	len = double(typecast(uint8(data(offset:offset+lengthSize-1)), lengthType));
	offset = offset + lengthSize;
	if(len == 0)
		str = '';
	else
		str = char(data(offset:double(uint64(offset)+uint64(len)-uint64(1))));
	end
	offset = offset + len;
end

function [num, offset] = getNum(numType, data, offset)
	if(strcmp(numType, 'uint16') || strcmp(numType, 'int16'))
		num = typecast(uint8(data(offset:offset+1)), numType);
		offset = offset + 2;
	elseif(strcmp(numType, 'uint32') || strcmp(numType, 'int32') || strcmp(numType, 'single'))
		num = typecast(uint8(data(offset:offset+3)), numType);
		offset = offset + 4;
	elseif(strcmp(numType, 'uint64') || strcmp(numType, 'int64') || strcmp(numType, 'double'))
		num = typecast(uint8(data(offset:offset+7)), numType);
		offset = offset + 8;
	end
end

function [opts, offset] = parseOpts(data, offset)
	numOpts = data(offset);
	offset = offset + 1;
	
	opts = '';
	for i=1:numOpts
		[option, offset] = getStr('uint16', data, offset);
		opts = [',''', option, ''''];
		
		optType = char(data(offset:offset+2));
		offset = offset + 3;
		
		if(strcmp(optType, 'i32'))
			[optNum, offset] = getNum('uint32', data, offset);
			opts = [opts, ',', num2str(double(optNum))];
		elseif(strcmp(optType, 'u32'))
			[optNum, offset] = getNum('int32', data, offset);
			opts = [opts, ',', num2str(double(optNum))];
		elseif(strcmp(optType, 'i64'))
			[optNum, offset] = getNum('uint64', data, offset);
			opts = [opts, ',', num2str(double(optNum))];
		elseif(strcmp(optType, 'u64'))
			[optNum, offset] = getNum('int64', data, offset);
			opts = [opts, ',', num2str(double(optNum))];
		elseif(strcmp(optType, 'f32'))
			[optNum, offset] = getNum('single', data, offset);
			opts = [opts, ',', num2str(double(optNum))];
		elseif(strcmp(optType, 'f64'))
			[optNum, offset] = getNum('double', data, offset);
			opts = [opts, ',', num2str(double(optNum))];
		elseif(strcmp(optType, 'str'))
			[optStr, offset] = getStr('uint16', data, offset);
			opts = [opts, ',''', optStr, ''''];
		end
	end
end

function textLabel(labelFunction, data)
	fnStr = '@()';
	
	if(labelFunction == Function.Xlabel)
		fnStr = [fnStr, 'xlabel('''];
	elseif(labelFunction == Function.Ylabel)
		fnStr = [fnStr, 'ylabel('''];
	elseif(labelFunction == Function.Title)
		fnStr = [fnStr, 'title('''];
	end
	
	offset = 2;
	[labl, offset] = getStr('uint16', data, offset);
	fnStr = [fnStr, labl, ''''];

	[opts, offset] = parseOpts(data, offset);
	fnStr = [fnStr, opts];
	fnStr = [fnStr, ');'];
	
	fn = str2func(fnStr);
	
	fn();
end

function Legend(data)
	fnStr = '@()';
	fnStr = [fnStr, 'legend({'];
	
	offset = 2;
	numLines = data(offset);
	offset = offset + 1;
	
	for i=1:numLines
		[line, offset] = getStr('uint16', data, offset);
		fnStr = [fnStr, '''', line, ''','];
	end
	
	fnStr(end) = '}';
	[opts, offset] = parseOpts(data, offset);
	fnStr = [fnStr, opts];
	fnStr = [fnStr, ');'];
	
	fn = str2func(fnStr);
	
	fn();
end

function SetupPlot(data, hlines)
	
	offset = 2;
	[xlab, offset] = getStr('uint32', data, offset);

	[ylab, offset] = getStr('uint32', data, offset);

	numLines = data(offset);
	offset = offset + 1;

	legendNames = {};
	
	for i=1:numLines
		[legendNames{i}, offset] = getStr('uint32', data, offset);
	end
	
	fontSize = data(offset);
	offset = offset + 1;

	[legendLoc, offset] = getStr('uint32', data, offset);

	setupPlot(hlines, xlab, ylab, legendNames, fontSize, legendLoc);
end

function Subplot(data)

	fnStr = '@()subplot(';

	offset = 2;
	m = data(2);
	n = data(3);
	p = data(4);
	offset = offset + 3;

	fnStr = [fnStr, num2str(m), ',', num2str(n), ',', num2str(p)];
	[opt, offset] = getStr('uint8', data, offset);

	if(~strcmp(opt, ''))
		fnStr = [fnStr, ',', '''', opt, ''''];
	end

	[opts, offset] = parseOpts(data, offset);
	fnStr = [fnStr, opts];
	fnStr = [fnStr, ');'];

	fn = str2func(fnStr);
	fn();
end

function Axis(data)
	offset = 3;
	if(data(2) == 0)
		[str, offset] = getStr('uint8', data', offset);
		axis(str);
	elseif(data(2) == 1)
		[xmin, offset] = getNum('int64', data, offset);
		[xmax, offset] = getNum('int64', data, offset);
		[ymin, offset] = getNum('int64', data, offset);
		[ymax, offset] = getNum('int64', data, offset);
		axis([xmin, xmax, ymin, ymax]);
	end

end

function hlines = Plot(data, holdOn, func)
	
	dataFormat = data(2);
	numLines = data(3);
	
	dataPtr = 4;

	for i=0:numLines-1
		
		length = typecast(uint8(data(dataPtr:dataPtr+3)), 'uint32');
		dataPtr = dataPtr + 4;
		x = zeros(length/8, 1);
		y = zeros(length/8, 1);
		for j=0:length/8-1
			x(j+1) = typecast(uint8(data(dataPtr:dataPtr+7)), 'double');
			dataPtr = dataPtr + 8;
		end
		for j=0:length/8-1
			y(j+1) = typecast(uint8(data(dataPtr:dataPtr+7)), 'double');
			dataPtr = dataPtr + 8;
		end
		if(dataFormat == 1)
			frmtLen = data(dataPtr);
			dataPtr = dataPtr + 1;
			frmt = zeros(frmtLen,1);
			for k=1:frmtLen
				frmt(k) = data(dataPtr);
				dataPtr = dataPtr + 1;
			end
			
			switch func
				case Function.Plot
					hlines(i+1,1) = plot(x, y, char(frmt));
				case Function.Semilogx
					hlines(i+1,1) = semilogx(x, y, char(frmt));
				case Function.Semilogy
					hlines(i+1,1) = semilogy(x, y, char(frmt));
				case Function.Loglog
					hlines(i+1,1) = loglog(x, y, char(frmt));
				otherwise
					
			end
			hold on;
			drawnow;
		elseif(dataFormat == 0)
			switch func
				case Function.Plot
					hlines(i+1,1) = plot(x, y);
				case Function.Semilogx
					hlines(i+1,1) = semilogx(x, y);
				case Function.Semilogy
					hlines(i+1,1) = semilogy(x, y);
				case Function.Loglog
					hlines(i+1,1) = loglog(x, y);
				otherwise
					
			end

			hold on;
			drawnow;
		end
	end

	if (holdOn == false)
		hold off;
	elseif (holdOn == true)
		hold on;
	end
end

function Print(data)

	length = typecast(uint8(data(2:3)), 'uint16');
	path = char(data(4:3+length)');
	formatLen = data(3+length+1);
	format = char(data(3+length+2:3+length+1+formatLen)');
	
	print(path, format);
end

function [outArr, offset] = getArray(lenType, arrType, data, offset)
	if(strcmp(lenType, 'uint16') || strcmp(lenType, 'int16'))
		len = typecast(uint8(data(offset:offset+1)), lenType);
		offset = offset + 2;
	elseif(strcmp(lenType, 'uint32') || strcmp(lenType, 'int32') || strcmp(lenType, 'single'))
		len = typecast(uint8(data(offset:offset+3)), lenType);
		offset = offset + 4;
	elseif(strcmp(lenType, 'uint64') || strcmp(lenType, 'int64') || strcmp(lenType, 'double'))
		len = typecast(uint8(data(offset:offset+7)), lenType);
		offset = offset + 8;
	end

	if(strcmp(arrType, 'uint16') || strcmp(arrType, 'int16'))
		len = len/2;
	elseif(strcmp(arrType, 'uint32') || strcmp(arrType, 'int32') || strcmp(arrType, 'single'))
		len = len/4;
	elseif(strcmp(arrType, 'uint64') || strcmp(arrType, 'int64') || strcmp(arrType, 'double'))
		len = len/8;
	end

	outArr = zeros(len, 1);

	for i=1:len
		[outArr(i), offset] = getNum(arrType, data, offset);
	end
end

function [outArr, offset] = get2DArray(lenType, arrType, data, offset)
	if(strcmp(lenType, 'uint16') || strcmp(lenType, 'int16'))
		len1 = typecast(uint8(data(offset:offset+1)), lenType);
		offset = offset + 2;
		len2 = typecast(uint8(data(offset:offset+1)), lenType);
		offset = offset + 2;
	elseif(strcmp(lenType, 'uint32') || strcmp(lenType, 'int32') || strcmp(lenType, 'single'))
		len1 = typecast(uint8(data(offset:offset+3)), lenType);
		offset = offset + 4;
		len2 = typecast(uint8(data(offset:offset+3)), lenType);
		offset = offset + 4;
	elseif(strcmp(lenType, 'uint64') || strcmp(lenType, 'int64') || strcmp(lenType, 'double'))
		len1 = typecast(uint8(data(offset:offset+7)), lenType);
		offset = offset + 8;
		len2 = typecast(uint8(data(offset:offset+7)), lenType);
		offset = offset + 8;
	end

	if(strcmp(arrType, 'uint16') || strcmp(arrType, 'int16'))
		len1 = len1/2;
		len2 = len2/2;
	elseif(strcmp(arrType, 'uint32') || strcmp(arrType, 'int32') || strcmp(arrType, 'single'))
		len1 = len1/4;
		len2 = len2/4;
	elseif(strcmp(arrType, 'uint64') || strcmp(arrType, 'int64') || strcmp(arrType, 'double'))
		len1 = len1/8;
		len2 = len2/8;
	end

	outArr = zeros(len1, len2);

	for i=1:len1
		for j=1:len2
			[outArr(i, j), offset] = getNum(arrType, data, offset);
		end
	end
end

function hlines = Contour(data, func)

	funcType = data(2);
	offset = 3;
	fnStr = '';
	switch func
		case Function.Contour
			funcTypeStr = 'contour';
		case Function.Contourf
			funcTypeStr = 'contourf';
		case Function.Contour3
			funcTypeStr = 'contour3';
	end

	switch funcType
		case 0
			[Z, offset] = get2DArray('uint32', 'double', data, offset);
			fnStr = ['@(Z)', funcTypeStr, '(Z'];
			[opts, offset] = parseOpts(data, offset);
			fnStr = [fnStr, opts, ');'];
			fn = str2func(fnStr);
			hlines = fn(Z);

		case 1
			[Z, offset] = get2DArray('uint32', 'double', data, offset);
			[n, offset] = getNum('uint32', data, offset);
			fnStr = ['@(Z, n)', funcTypeStr, '(Z, n'];
			[opts, offset] = parseOpts(data, offset);
			fnStr = [fnStr, opts, ');'];
			fn = str2func(fnStr);
			hlines = fn(Z, n);

		case 2
			[Z, offset] = get2DArray('uint32', 'double', data, offset);
			[v, offset] = getArray('uint32', 'uint32', data, offset);
			fnStr = ['@(Z, v)', funcTypeStr, '(Z, v'];
			[opts, offset] = parseOpts(data, offset);
			fnStr = [fnStr, opts, ');'];
			fn = str2func(fnStr);
			hlines = fn(Z, v);

		case 3
			[X, offset] = get2DArray('uint32', 'double', data, offset);
			[Y, offset] = get2DArray('uint32', 'double', data, offset);
			[Z, offset] = get2DArray('uint32', 'double', data, offset);
			fnStr = ['@(X, Y, Z)', funcTypeStr, '(X, Y, Z'];
			[opts, offset] = parseOpts(data, offset);
			fnStr = [fnStr, opts, ');'];
			fn = str2func(fnStr);
			hlines = fn(X, Y, Z);

		case 4
			[X, offset] = get2DArray('uint32', 'double', data, offset);
			[Y, offset] = get2DArray('uint32', 'double', data, offset);
			[Z, offset] = get2DArray('uint32', 'double', data, offset);
			[n, offset] = getNum('uint32', data, offset);
			fnStr = ['@(X, Y, Z, n)', funcTypeStr, '(X, Y, Z, n'];
			[opts, offset] = parseOpts(data, offset);
			fnStr = [fnStr, opts, ');'];
			fn = str2func(fnStr);
			hlines = fn(X, Y, Z, n);

		case 5
			[X, offset] = get2DArray('uint32', 'double', data, offset);
			[Y, offset] = get2DArray('uint32', 'double', data, offset);
			[Z, offset] = get2DArray('uint32', 'double', data, offset);
			[v, offset] = getArray('uint32', 'uint32', data, offset);
			fnStr = ['@(X, Y, Z, v)', funcTypeStr, '(X, Y, Z, v'];
			[opts, offset] = parseOpts(data, offset);
			fnStr = [fnStr, opts, ');'];
			fn = str2func(fnStr);
			hlines = fn(X, Y, Z, v);
		otherwise
			fprintf('bummer');
	end
end
