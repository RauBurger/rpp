classdef Command < uint8
	enumeration
		Idle(-1)
		Function(0)
		Data(1)
		Done(2)
	end
end