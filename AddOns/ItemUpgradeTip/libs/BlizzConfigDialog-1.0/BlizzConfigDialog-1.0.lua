--- BlizzConfigDialog-1.0 generates Blizzard settings categories based on option tables.
---@class file
---@name BlizzConfigDialog-1.0

local LibStub = LibStub
local reg = LibStub("AceConfigRegistry-3.0")

local MAJOR, MINOR = "BlizzConfigDialog-1.0", 4
local BlizzConfigDialog = LibStub:NewLibrary(MAJOR, MINOR)

if not BlizzConfigDialog then return end

-- Lua APIs
local tinsert, tsort, tremove, wipe = table.insert, table.sort, table.remove, table.wipe
local format = string.format
local error = error
local pairs, next, select, type = pairs, next, select, type

-- Recycling functions
local new, del
do
	local pool = setmetatable({},{__mode="k"})
	function new()
		local t = next(pool)
		if t then
			pool[t] = nil
			return t
		else
			return {}
		end
	end
	function del(t)
		wipe(t)
		pool[t] = true
	end
end

-- Picks the first non-nil value and returns it
local function pickfirstset(...)
	for i = 1, select("#", ...) do
		if select(i,...) ~= nil then
			return select(i, ...)
		end
	end
end

-- Gets an option from a given group, checking plugins
---@param group table
---@param key string|number
local function GetSubOption(group, key)
	if group.plugins then
		for _, t in pairs(group.plugins) do
			if t[key] then
				return t[key]
			end
		end
	end

	return group.args[key]
end

-- Option member type definitions, used to decide how to access it

-- Is the member Inherited from parent options
local isInherited = {
	set = true,
	get = true,
	func = true,
	confirm = true,
	validate = true,
	disabled = true,
	hidden = true
}

-- Does a string type mean a literal value, instead of the default of a method of the handler
local stringIsLiteral = {
	name = true,
	desc = true,
	action = true,
	icon = true,
	usage = true,
	width = true,
	image = true,
	fontSize = true,
	tooltipHyperlink = true
}

-- Is Never a function or method
local allIsLiteral = {
	type = true,
	descStyle = true,
	imageWidth = true,
	imageHeight = true,
}

-- Gets the value for a member that could be a function.
-- Function refs are called with an info arg, every other type is returned
---@param membername string
---@param option table
---@param options table
---@param path table
---@param appName string
local function GetOptionsMemberValue(membername, option, options, path, appName, ...)
	--get definition for the member
	local inherits = isInherited[membername]

	--get the member of the option, traversing the tree if it can be inherited
	local member

	if inherits then
		local group = options
		if group[membername] ~= nil then
			member = group[membername]
		end
		for i = 1, #path do
			group = GetSubOption(group, path[i])
			if group[membername] ~= nil then
				member = group[membername]
			end
		end
	else
		member = option[membername]
	end

	--check if we need to call a functon, or if we have a literal value
	if (not allIsLiteral[membername]) and (type(member) == "function" or ((not stringIsLiteral[membername]) and type(member) == "string")) then
		--We have a function to call
		local info = new()
		--traverse the options table, picking up the handler and filling the info with the path
		local group = options
		local handler = group.handler

		for i = 1, #path do
			group = GetSubOption(group, path[i])
			info[i] = path[i]
			handler = group.handler or handler
		end

		info.options = options
		info.appName = appName
		info[0] = appName
		info.arg = option.arg
		info.handler = handler
		info.option = option
		info.type = option.type
		info.uiType = "dialog"
		info.uiName = MAJOR

		local a, b, c, d
		--using 4 returns for the get of a color type, increase if a type needs more
		if type(member) == "function" then
			--Call the function
			a, b, c, d = member(info, ...)
		else
			--Call the method
			if handler and handler[member] then
				a, b, c, d = handler[member](handler, info, ...)
			else
				error(format("Method %s doesn't exist in handler for type %s", member, membername))
			end
		end
		del(info)
		return a, b, c, d
	else
		--The value isnt a function to call, return it
		return member
	end
end

-- Tables to hold orders and names for options being sorted, will be created with new()
-- Prevents needing to call functions repeatedly while sorting
local tempOrders
local tempNames

---@param a any
---@param b any
local function compareOptions(a, b)
	if not a then
		return true
	end
	if not b then
		return false
	end
	local OrderA, OrderB = tempOrders[a] or 100, tempOrders[b] or 100
	if OrderA == OrderB then
		local NameA = (type(tempNames[a]) == "string") and tempNames[a] or ""
		local NameB = (type(tempNames[b]) == "string") and tempNames[b] or ""
		return NameA:upper() < NameB:upper()
	end
	if OrderA < 0 then
		if OrderB >= 0 then
			return false
		end
	else
		if OrderB < 0 then
			return true
		end
	end
	return OrderA < OrderB
end

-- Builds 2 tables out of an options group:
-- * keySort, sorted keys
-- * opts, combined options from .plugins and args
---@param group table
---@param keySort table
---@param opts table
---@param options table
---@param path table
---@param appName string
local function BuildSortedOptionsTable(group, keySort, opts, options, path, appName)
	tempOrders = new()
	tempNames = new()

	if group.plugins then
		for _, t in pairs(group.plugins) do
			for k, v in pairs(t) do
				if not opts[k] then
					tinsert(keySort, k)
					opts[k] = v

					path[#path + 1] = k
					tempOrders[k] = GetOptionsMemberValue("order", v, options, path, appName)
					tempNames[k] = GetOptionsMemberValue("name", v, options, path, appName)
					path[#path] = nil
				end
			end
		end
	end

	for k, v in pairs(group.args) do
		if not opts[k] then
			tinsert(keySort, k)
			opts[k] = v

			path[#path+1] = k
			tempOrders[k] = GetOptionsMemberValue("order", v, options, path, appName)
			tempNames[k] = GetOptionsMemberValue("name", v, options, path, appName)
			path[#path] = nil
		end
	end

	tsort(keySort, compareOptions)

	del(tempOrders)
	del(tempNames)
end

--- Checks whether the given option should be hidden
--

local function CheckOptionHidden(option, options, path, appName)
	-- Check for a specific boolean option
	local hidden = pickfirstset(option.dialogHidden, option.guiHidden)
	if hidden ~= nil then
		return hidden
	end

	return GetOptionsMemberValue("hidden", option, options, path, appName)
end

---@param minValue number
---@param maxValue number
---@return number|function
local function GetFormatter1to10(minValue, maxValue)
	return function(value)
		return RoundToSignificantDigits(((value-minValue)/(maxValue-minValue) * 9) + 1, 1)
	end
end

--- Feed the given options to the Blizzard settings panel
--
-- @param appName The application name as given to `:RegisterOptionsTable()`
-- @param options The root of the options table being fed
-- @param path A table with the keys to get to the group being fed
-- @param group The current option group being fed
-- @param category The reference to the category registered into the Interface Options.
-- @param layout The reference to the category's layout
-- @param isRoot Whether this is the root group
local function FeedOptions(appName, options, path, group, category, layout, isRoot)
	local keySort = new()
	local opts = new()

	BuildSortedOptionsTable(group, keySort, opts, options, path, appName)

	for i = 1, #keySort do
		local k = keySort[i]
		local v = opts[k]
		tinsert(path, k)
		local hidden = CheckOptionHidden(v, options, path, appName)
		local name = GetOptionsMemberValue("name", v, options, path, appName)
		if not hidden then
			if v.type == "group" then
				if name and name ~= "" then
					--check if the group has child groups
					local hasChildGroups
					for _, v2 in pairs(group.args) do
						if v2.type == "group" and not pickfirstset(v2.dialogInline, v2.guiInline, v2.inline, false) and not CheckOptionHidden(v2, options, path, appName) then
							hasChildGroups = true
						end
					end
					if group.plugins then
						for _, t in pairs(group.plugins) do
							for _, v2 in pairs(t) do
								if v2.type == "group" and not pickfirstset(v2.dialogInline, v2.guiInline, v2.inline, false) and not CheckOptionHidden(v2, options, path, appName) then
									hasChildGroups = true
								end
							end
						end
					end

					if hasChildGroups and not isRoot then
						local subCategory, subLayout = Settings.RegisterVerticalLayoutSubcategory(category, name);

						local subDesc = GetOptionsMemberValue("desc", v, options, path, appName)
						if subDesc and subDesc ~= "" then
							subLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(subDesc));
						end

						FeedOptions(appName, options, path, v, subCategory, subLayout, false)
					else
						FeedOptions(appName, options, path, v, category, layout, false)
					end
				else
					FeedOptions(appName, options, path, v, category, layout, false)
				end
			else
				local function SetValue() end

				local function OnSettingChanged(setting, val)
					v.set(setting, val);
				end

				if v.type == "execute" then
					local buttonName = GetOptionsMemberValue("buttonName", v, options, path, appName)
					local desc = GetOptionsMemberValue("desc", v, options, path, appName)
					local addSearchTags = true;
					local initializer = CreateSettingsButtonInitializer(name, buttonName or name, v.func, desc, addSearchTags);
					layout:AddInitializer(initializer);

				elseif v.type == "input" then
					-- TODO

				elseif v.type == "toggle" then
					local value = GetOptionsMemberValue("get", v, options, path, appName)
					local desc = GetOptionsMemberValue("desc", v, options, path, appName)
					local defaultValue = GetOptionsMemberValue("defaultValue", v, options, path, appName)

					local setting = Settings.RegisterProxySetting(category, k, type(defaultValue), name, defaultValue, v.get, SetValue)
					Settings.CreateCheckbox(category, setting, desc)
					setting:SetValueChangedCallback(OnSettingChanged)
					setting:SetValue(value)

				elseif v.type == "range" then
					local value = GetOptionsMemberValue("get", v, options, path, appName)
					local desc = GetOptionsMemberValue("desc", v, options, path, appName)
					local defaultValue = tonumber(GetOptionsMemberValue("defaultValue", v, options, path, appName))
					local minValue = GetOptionsMemberValue("min", v, options, path, appName)
					local maxValue = GetOptionsMemberValue("max", v, options, path, appName)
					local step = GetOptionsMemberValue("step", v, options, path, appName)

					local setting = Settings.RegisterProxySetting(category, k, type(defaultValue), name, defaultValue, v.get, SetValue)
					local sliderOptions = Settings.CreateSliderOptions(minValue, maxValue, step);

					sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
					Settings.CreateSlider(category, setting, sliderOptions, desc);
					setting:SetValueChangedCallback(OnSettingChanged)
					setting:SetValue(value)

				elseif v.type == "select" then
					local value = GetOptionsMemberValue("get", v, options, path, appName)
					local desc = GetOptionsMemberValue("desc", v, options, path, appName)
					local defaultValue = GetOptionsMemberValue("defaultValue", v, options, path, appName)
					local values = GetOptionsMemberValue("values", v, options, path, appName)

					local function GetOptions()
						local container = Settings.CreateControlTextContainer()
						for optionsKey, optionsValue in pairs(values) do
							container:Add(optionsKey, optionsValue)
						end
						return container:GetData()
					end

					local setting = Settings.RegisterProxySetting(category, k, type(defaultValue), name, defaultValue, v.get, SetValue)
					Settings.CreateDropdown(category, setting, GetOptions, desc)
					setting:SetValueChangedCallback(OnSettingChanged)
					setting:SetValue(value)

				elseif v.type == "multiselect" then
					-- TODO

				elseif v.type == "color" then
					-- TODO

				elseif v.type == "keybinding" then
					local action = GetOptionsMemberValue("action", v, options, path, appName);
					assert(action ~= "" and action ~= nil)

					local bindingIndex = C_KeyBindings.GetBindingIndex(action);
					assert(bindingIndex ~= nil)

					local initializer = CreateKeybindingEntryInitializer(bindingIndex, true);
					initializer:AddSearchTags(GetBindingName(action));
					layout:AddInitializer(initializer);

				elseif v.type == "header" then
					layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(name));

				elseif v.type == "description" then
					-- TODO - is this even possible?
				end
			end
		end
		tremove(path)
	end

	del(keySort)
	del(opts)
end

--- Traverses the tree of options and registers them with Blizzard
--
-- @param appName The application name as given to `:RegisterOptionsTable()`
-- @param category The reference to the root category registered into the Interface Options.
-- @param layout The reference to the root category's layout
local function FeedToBlizPanel(appName, category, layout)
	local app = reg:GetOptionsTable(appName)
	if not app then
		error(("%s isn't registed with AceConfigRegistry, unable to open config"):format(appName), 2)
	end
	local options = app("dialog", MAJOR)

	local path = new()
	local group = options

	FeedOptions(appName, options, path, group, category, layout, true)
end

BlizzConfigDialog.BlizOptions = BlizzConfigDialog.BlizOptions or {}

--- Add an option table into the Blizzard Interface Options panel.
-- You can optionally supply a descriptive name to use.
-- If no name is specified, the appName will be used instead.
--
-- This function returns a reference to the container frame registered with the Interface
-- Options. You can use this reference to open the options with the API function
-- `InterfaceOptionsFrame_OpenToCategory`.
--
---@param appName string The application name as given to `:RegisterOptionsTable()`
---@param name string A descriptive name to display in the options tree (defaults to appName)
---@return Frame category The reference to the root category registered into the Interface Options.
---@return integer category The category ID to pass to Settings.OpenToCategory (or InterfaceOptionsFrame_OpenToCategory)
function BlizzConfigDialog:AddToBlizOptions(appName, name)
	local BlizOptions = BlizzConfigDialog.BlizOptions

	local key = appName

	if not BlizOptions[appName] then
		BlizOptions[appName] = {}
	end

	if not BlizOptions[appName][key] then
		local categoryName = name or appName
		local category, layout = Settings.RegisterVerticalLayoutCategory(categoryName)

		BlizOptions[appName][key] = category

		FeedToBlizPanel(appName, category, layout)

		Settings.RegisterAddOnCategory(category)

		return category, category.ID
	else
		error(("%s has already been added to the Blizzard Options Window with the given path"):format(appName), 2)
	end
end
