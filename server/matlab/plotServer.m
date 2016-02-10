function plotServer(address, remotePort, localPort)

	u = udp(address, remotePort, 'LocalPort', localPort, 'Timeout', .005);
	
	c = onCleanup(@()cleanUp(u));
	
	try
		holdOn = false;		
		%u.InputBufferSize = 4096;
		%u.InputBufferSize = 512;
		u.InputBufferSize = 9216;
		
		fopen(u);
		fprintf('Server open\n');
		
		currentFunction = Function.None;%Function.makeFunction(-1);
		currentPayload = 10;
		while(1)
			
			bytesRead = 0;
			data = 255*ones(currentPayload, 1);
			
			warning('off', 'instrument:fread:unsuccessfulRead');
			data = fread(u, currentPayload-bytesRead, 'uint8');
			bytesRead = bytesRead + max(size(data));
			
			while(bytesRead < currentPayload)
				%fprintf('bytesRead = %d\n', bytesRead);
				drawnow();
				payload = [uint8(1), typecast(uint32(bytesRead), 'uint8')];
				fwrite(u, payload, 'uint8');
				newData = fread(u, currentPayload, 'uint8');
				bytesRead = bytesRead + max(size(newData));
				data = [data; newData];
			end
			warning('on', 'instrument:fread:unsuccessfulRead');
			drawnow();
			
			payload = [uint8(0), typecast(uint32(bytesRead), 'uint8')];
			fwrite(u, payload, 'uint8');
			

			currentCommand = data(1); %Command.makeCommand(data(1));
			
			switch currentCommand
				case Command.Function
					currentFunction = data(2); %Function.makeFunction(data(2));
					currentPayload = double(typecast(uint8(data(3:end)), 'uint64'));
				case Command.Data
					switch currentFunction
						case Function.Plot
							hlines = Plot(data, holdOn);
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
							
						case Function.Axes
							Axes(data);
							
						case Function.Grid
							if(data(2) == 1)
								grid on;
							elseif(data(2) == 0)
								grid off;
							end
						otherwise
							
					end
					
					currentFunction = Function.None;
					currentPayload = 1;
					drawnow;
				case Command.Done
					currentPayload = 10;
				otherwise
					
			end
		end
	catch ME
		SendException(u, ME);
		fclose(u);
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

	length = typecast(uint8(data(offset:offset+lengthSize-1)), lengthType);
	offset = offset + lengthSize;
	if(length == 0)
		str = '';
	else
		str = char(data(offset:offset+length-1));
	end
	offset = offset + length;
end

function [num, offset] = getNum(numType, data, offset)
	if(strcmp(lengthType, 'uint16'))
		num = typecast(uint8(data(offset:offset+1)), lengthType);
		offset = offset + 2;
	elseif(strcmp(lengthType, 'uint32') || strcmp(lengthType, 'int32') || strcmp(lengthType, 'single'))
		num = typecast(uint8(data(offset:offset+3)), lengthType);
		offset = offset + 4;
	elseif(strcmp(lengthType, 'uint64') || strcmp(lengthType, 'int64') || strcmp(lengthType, 'double'))
		num = typeast(uint8(data(offset:offset+7)), lengthType);
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

function Axes(data)

	fnStr = '@()axes';

	offset = 3;
	if(data(2) == 0)
		[str, offset] = getStr('uint8', data, offset);
		fnStr = [fnStr, ' ', str. ';'];
	elseif(data(2) == 1)
		[xmin, offset] = getNum('int64', data, offset);
		[xmax, offset] = getNum('int64', data, offset);
		[ymin, offset] = getNum('int64', data, offset);
		[ymax, offset] = getNum('int64', data, offset);

		fnStr = [fnStr, '(', num2str(xmin), ',', num2str(xmax), ',', num2str(ymin), ',', num2str(ymax), ');']
	end

	fn = str2func(fnStr);
	fn();

end

function hlines = Plot(data, holdOn)
	
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
			
			hlines(i+1,1) = plot(x, y, char(frmt));
			hold on;
			drawnow;
		elseif(dataFormat == 0)
			hlines(i+1,1) = plot(x, y);
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