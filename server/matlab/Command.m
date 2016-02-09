classdef Command
	enumeration
		Idle(-1), Function(0), Data(1), Done(2)
	end
	
	properties
		command = -1;
	end
	
	methods
		function r = Command(num)
			switch num
				case 0
					r.command = 0;
				case 1
					r.command = 1;
				case 2
					r.command = 2;
				otherwise
					r.command = -1;
			end
		end
	end
	
	methods (Static)
		function comm = makeCommand(num)
			switch num
				case 0
					comm = Command.Function;
				case 1
					comm = Command.Data;
				case 2
					comm = Command.Done;
				otherwise
					comm = Command.Idle;
			end
		end
	end
	
end