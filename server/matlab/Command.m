classdef Command < uint8
	enumeration
		Idle(-1)
		Function(0)
		Data(1)
		Done(2)
		Close(3)
	end
end