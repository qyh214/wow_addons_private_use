local _, private = ...

local tinsert, twipe = table.insert, table.wipe

---------------
-- Prototype --
---------------
local modulePrototype = {}

function modulePrototype:RegisterEvents(...)
	for _, event in ipairs({...}) do
		self.frame:RegisterEvent(event)
	end
end

function modulePrototype:RegisterShortTermEvents(...)
	for _, event in ipairs({...}) do
		self.frame:RegisterEvent(event)
		tinsert(self.shortTermEvents, event)
	end
end

function modulePrototype:UnregisterShortTermEvents()
	for _, event in ipairs(self.shortTermEvents) do
		self.frame:UnregisterEvent(event)
	end
	twipe(self.shortTermEvents)
end

-------------
-- Modules --
-------------
local modules = {}

function private:NewModule(name)
	if modules[name] then
		error("DBM:NewModule(): Module names must be unique", 2)
	end
	local frame = CreateFrame("Frame", "DBM" .. name)
	local obj = setmetatable({
		frame = frame,
		shortTermEvents = {}
	}, {
		__index = modulePrototype
	})
	frame:SetScript("OnEvent", function(_, event, ...)
		local handler = obj[event]
		if handler then
			handler(obj, ...)
		end
	end)
	modules[name] = obj
	return obj
end

function private:GetModule(name)
	return modules[name]
end
