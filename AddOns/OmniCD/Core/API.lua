local E = select(2, ...):unpack()

















function OmniCD.AddUnitFrameData(addon, frame, unit, delay, testFunc, index)
	local arg = type(addon) ~= "string" and "addon" or (type(frame) ~= "string" and "frame") or (type(unit) ~= "string" and "unit")
	if arg then
		error(("Usage: OmniCD.AddUnitFrameData(addon, frame, unit, [delay, testFunc, index]): '%s' - string expected, got '%s'."):format(arg, type(arg)))
	end
	arg = delay and type(delay) ~= "number" and "delay" or (index and type(index) ~= "number" and "index")
	if arg then
		error(("Usage: OmniCD.AddUnitFrameData(addon, frame, unit, [delay, testFunc, index]): 'delay' - number expected, got '%s'."):format(arg, type(arg)))
	end

	local tbl = { addon, frame, unit, delay or 1, index or 5 }
	local update

	for i = 1, #E.unitFrameData do
		local data = E.unitFrameData[i]
		if data[1] == addon then
			E.unitFrameData[i] = tbl
			update = true
			break
		end
	end

	if not update then
		tinsert(E.unitFrameData, tbl)
	end

	if testFunc then
		E.addOnTestMode[addon] = testFunc
	end
end
