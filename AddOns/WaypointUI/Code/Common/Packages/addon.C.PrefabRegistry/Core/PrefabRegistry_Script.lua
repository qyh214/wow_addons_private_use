---@class addon
local addon = select(2, ...)
local NS = addon.C.PrefabRegistry; addon.C.PrefabRegistry = NS

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
		-- Adds a prefab (function under the identifier name to create an element) to the registry. It can be created with [addon.C.PrefabRegistry:Create(id, ...)].
		---@param id string
		---@param prefabFunc function
		function Callback:Add(id, prefabFunc)
			if NS.Variables.Prefabs[id] == nil then
				NS.Variables.Prefabs[id] = prefabFunc
			end
		end

		-- Creates an element using the prefab under the identifier name.
		---@param id string
		---@param ... any
		function Callback:Create(id, ...)
			if NS.Variables.Prefabs[id] then
				return NS.Variables.Prefabs[id](...)
			end
		end

		-- Adds a variable table for the prefab under the identifier name.
		---@param id string
		---@param varTable table
		function Callback:AddVariableTable(id, varTable)
			if NS.Variables.PrefabVariables[id] == nil then
				NS.Variables.PrefabVariables[id] = varTable
			end
		end

		-- Gets a variable table for the prefab under the identifier name.
		---@param id string
		---@return table
		function Callback:GetVariableTable(id)
			return NS.Variables.PrefabVariables[id]
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------
end
