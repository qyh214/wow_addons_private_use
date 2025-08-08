---@class addon
local addon = select(2, ...)
local NS = addon.C.CallbackRegistry; addon.C.CallbackRegistry = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		-- Adds a function to a callback category.
		---@param id string
		---@param func function
		---@param priority? number: Higher priority runs later. Priority with -1 is ALWAYS run first. Default is run after .5s.
		function Callback:Add(id, func, priority)
			if NS.Variables.Callbacks[id] == nil then
				NS.Variables.Callbacks[id] = {}
			end

			local callback = {
				func = func,
				priority = priority
			}

			table.insert(NS.Variables.Callbacks[id], callback)
		end

		-- Triggers all functions in a callback category.
		---@param id string
		function Callback:Trigger(id, ...)
			if not NS.Variables.Callbacks[id] then
				return
			end

			--------------------------------

			table.sort(NS.Variables.Callbacks[id], function(a, b)
				return (a.priority or 0) < (b.priority or 0)
			end)

			for _, callback in ipairs(NS.Variables.Callbacks[id]) do
				local func = callback.func
				func(...)
			end
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------
end
