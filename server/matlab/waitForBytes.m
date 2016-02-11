function waitForBytes(u)
	while(u.BytesAvailable == 0)
		drawnow;
		pause(0.001);
	end
end