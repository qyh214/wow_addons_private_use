--[[
Follow the instructions located at https://github.com/methodgg/WagoAnalytics/tree/shim to use this.

Example Usage:

Options = {
	breadcrumbCount = 10, -- Default: 20. Number of breadcrumbs to push with an error
	reportErrors = true, -- Default: true. Should we report errors?
}

local WagoAnalytics = LibStub("WagoAnalytics"):Register("<Your Wago addon ID>") -- 2nd argument is an optional list of options

-- Add breadcrumb data with arg1 message
WagoAnalytics:Breadcrumb("Some useful debug information here.")

-- Increments the counter arg1 by arg2 amount
WagoAnalytics:Counter("SomeCounter", 50)

-- Set a boolean arg1 value to arg2 or true
WagoAnalytics:Switch("SomeSwitch")

-- Throw a custom error message arg1. This includes the previous breadcrumbs automatically.
WagoAnalytics:Error("Variable was expected to be defined, but wasn't")
--]]

local _, addon = ...

WagoAnalytics = {}
local WagoAnalytics = WagoAnalytics

local SV, playerClass, playerRegion, playerMinLevel, playerMaxLevel, playerRace, playerFaction, playerLocale, playerName, playerRealm
local registeredAddons, playerSpecs, playerAddons, variableCount = {}, {}, {}, {}

local isRetail = WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1)

do
	local tostring, pairs, ipairs, debugstack, debuglocals, tIndexOf, tinsert, match =
		tostring, pairs, ipairs, debugstack, debuglocals, tIndexOf, table.insert, string.match
	local GetLocale, UnitFactionGroup, GetCurrentRegion, UnitAffectingCombat, InCombatLockdown, GetNumAddOns, GetAddOnInfo, GetAddOnMetadata, CreateFrame, UnitClass, UnitLevel, UnitRace, GetSpecialization, GetSpecializationInfo =
		GetLocale, UnitFactionGroup, GetCurrentRegion, UnitAffectingCombat, InCombatLockdown, GetNumAddOns, GetAddOnInfo, GetAddOnMetadata, CreateFrame, UnitClass, UnitLevel, UnitRace, GetSpecialization, GetSpecializationInfo

	-- isSimple 3 state: True is simple, False is pcall, Nil is not simple
	local function handleError(errorMessage, isSimple, errorObj)
		errorMessage = tostring(errorMessage)
		local wagoID = GetAddOnMetadata(match(errorMessage, "AddOns\\([^\\]+)\\") or "Unknown", "X-Wago-ID")
		if not wagoID or not registeredAddons[wagoID] then
			return
		end
		local addonObj = registeredAddons[wagoID]
		for _, err in ipairs(addonObj.errors) do
			if err.message and err.message == errorMessage then
				return
			end
		end
		if isSimple then
			addonObj:Error({
				message = errorMessage
			})
		else
			addonObj:Error({
				message = errorMessage,
				stack = errorObj and errorObj.stack or debugstack(3),
				locals = errorObj and errorObj.locals or (InCombatLockdown() or UnitAffectingCombat("player")) and "Skipped (In Encounter)" or debuglocals(isSimple == nil and 3 or 5)
			})
		end
	end

	do
		local oldErrorHandler = _G.geterrorhandler()
		_G.seterrorhandler(function(err)
			local ok, innerError = pcall(handleError, err, false)
			oldErrorHandler(err)

			if not ok then
				oldErrorHandler(innerError)
			end
		end)
	end

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterEvent("ADDON_LOADED")
	frame:RegisterEvent("ADDON_ACTION_BLOCKED")
	frame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	frame:RegisterEvent("LUA_WARNING")
	frame:RegisterEvent("ADDONS_UNLOADING")
	if isRetail then
		frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	end

	frame:SetScript("OnEvent", function(_, event, arg1, arg2)
		-- Handles when the addon loads
		if event == "PLAYER_LOGIN" then
			if not WagoAnalyticsSV then
				WagoAnalyticsSV = {}
			end
			local _, _, _playerClass = UnitClass("player")
			playerClass = _playerClass
			if isRetail then
				local currentSpec = GetSpecialization()
				if currentSpec then
					local playerSpec = GetSpecializationInfo(currentSpec)
					tinsert(playerSpecs, playerSpec)
				end
			end
			local _, _, _playerRace = UnitRace("player")
			playerRace = _playerRace
			playerFaction = UnitFactionGroup("player") or "Neutral"
			playerMinLevel = UnitLevel("player")
			playerMaxLevel = playerMinLevel
			playerLocale = GetLocale()
			playerRegion = GetCurrentRegion()
			playerName = UnitName("player")
			playerRealm = GetRealmName()
			for i = 1, GetNumAddOns() do
				local name, _, _, enabled = GetAddOnInfo(i)
				if enabled then
					playerAddons[name] = GetAddOnMetadata(i, "Version") or "Unknown"
				end
			end
			-- Hooks into BugSack
			local BugGrabber = _G["BugGrabber"]
			if BugGrabber and BugGrabber.RegisterCallback then
				BugGrabber.RegisterCallback(addon, "BugGrabber_BugGrabbed", function(_, error)
					handleError(error.message, error.stack and true or nil, error)
				end)
			end
		-- Handles when the player changes their specialization
		elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
			local currentSpec = GetSpecialization()
			if currentSpec then
				local playerSpec = GetSpecializationInfo(currentSpec)
				if not tIndexOf(playerSpecs, playerSpec) then
					tinsert(playerSpecs, playerSpec)
				end
			end
		-- Handles when the player levels up
		elseif event == "PLAYER_LEVEL_UP" then
			playerMaxLevel = arg1
		-- Handles when an addon is loaded
		elseif event == "ADDON_LOADED" then
			playerAddons[arg1] = GetAddOnMetadata(arg1, "Version") or "Unknown"
		-- Handles when an addon fires a bad action (protected or forbidden)
		elseif event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN" then
			handleError(("[%s] AddOn '%s' tried to call the protected function '%s'."):format(event, arg1 or "<name>", arg2 or "<func>"))
		-- Handles when an addon fires bad Lua code
		elseif event == "LUA_WARNING" then
			handleError(arg2, true)
		-- Handles when the player closes the game or logs out
		elseif event == "ADDONS_UNLOADING" then
			for _, addonObj in pairs(registeredAddons) do
				addonObj:Save()
			end
		end
	end)
end

-- Start Utility functions
local CollectBufferElements

do
	local tinsert = table.insert

	function CollectBufferElements(buffer)
		local elements = {}

		for i = buffer:GetNumElements(), 1, -1 do
			tinsert(elements, buffer:GetEntryAtIndex(i))
		end

		return elements
	end
end
-- End utility functions

local wagoPrototype = {}

function wagoPrototype:IncrementCounter(name, increment)
	return self:SetCounter(name, (self.counters[name] or 0) + (increment or 1))
end

function wagoPrototype:DecrementCounter(name, decrement)
    return self:SetCounter(name, (self.counters[name] or 0) - (decrement or 1))
end

function wagoPrototype:SetCounter(name, value)
    if type(name) ~= "string" then
        return false
    end
    if #name > 128 then
        name = name:sub(0, 128)
    end
    if not self.counters[name] then
        local elemLen = variableCount[self.addon].counters
        if elemLen > 512 then
            return false
        end
        variableCount[self.addon].counters = elemLen + 1
    end
    self.counters[name] = value
end

function wagoPrototype:Switch(name, value)
	value = value == nil and true or value
	if type(name) ~= "string" or type(value) ~= "boolean" then
		return false
	end
	if #name > 128 then
		name = name:sub(0, 128)
	end
	local elemLen = variableCount[self.addon].switches
	if elemLen > 512 then
		return false
	end
	variableCount[self.addon].switches = elemLen + 1
	self.switches[name] = value
end

do
	local tinsert = table.insert

	function wagoPrototype:Error(error)
		if type(error) ~= "string" then
			return false
		end
		if #self.errors > 512 then
			return false
		end
		if #error > 1024 then
			error = error:sub(0, 1021) .. "..."
		end
		tinsert(self.errors, {
			error = error,
			breadcrumb = CollectBufferElements(self.breadcrumbs)
		})
	end
end

do
	local type = type

	function wagoPrototype:Breadcrumb(data)
		if type(data) ~= "string" then
			return false
		end
		if #data > 255 then
			data = data:sub(0, 252) .. "..."
		end
		self.breadcrumbs:PushFront(data)
	end
end

do
	local gsub, format, random, time, pairs, next = string.gsub, string.format, math.random, time, pairs, next

	local function StripExcessAnalyticsEntries()
		local count, lastTime, lastK = 0, math.huge
		for k, v in pairs(WagoAnalyticsSV) do
			count = count + 1
			if v.time < lastTime then
				lastK = k
				lastTime = v.time
			end
			if count > 2 then
				WagoAnalyticsSV[lastK] = nil
				break
			end
		end
	end

	function wagoPrototype:Save()
		if not SV then
			SV = {
				data = {},
				time = time(),
				addons = playerAddons,
				playerData = {
					name = playerName,
					realm = playerRealm,
					locale = playerLocale,
					class = playerClass,
					region = playerRegion,
					specs = playerSpecs,
					levelMin = playerMinLevel,
					levelMax = playerMaxLevel,
					race = playerRace,
					faction = playerFaction
				}
			}
		end

		-- Prevent saving addon data if there's no analytics
		if variableCount[self.addon].counters > 0 or variableCount[self.addon].switches > 0 or #self.errors > 0 then
			SV.data[self.addon] = {
				counters = self.counters,
				switches = self.switches,
				errors = self.errors
			}
		end

		if not next(SV.data) then
			return
		end

		local uuid = gsub("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "x", function()
			return format("%x", random(0, 0xf))
		end)
		WagoAnalyticsSV[uuid] = SV

		StripExcessAnalyticsEntries()
	end
end

do
	local CreateCircularBuffer, mmin, setmetatable = CreateCircularBuffer, math.min, setmetatable

	function WagoAnalytics:Register(addonName, options)
		if registeredAddons[addonName] then
			return registeredAddons[addonName]
		end
		if not options then
			options = {}
		end
		if options.reportErrors == nil then
			options.reportErrors = true
		end
		local obj = setmetatable({
			addon = addonName,
			options = options,
			counters = {},
			switches = {},
			errors = {},
			breadcrumbs = CreateCircularBuffer(mmin(options.breadcrumbCount or 20, 50))
		}, {
			__index = wagoPrototype
		})
		registeredAddons[addonName] = obj
		variableCount[addonName] = {
			counters = 0,
			switches = 0
		}
		return obj
	end
end
