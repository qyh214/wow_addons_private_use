---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Fonts; addon.C.Fonts = NS

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
		function Callback:LoadFonts(loadCustomFonts)
			if loadCustomFonts then
				local localeFonts = addon.C.AddonInfo.Variables.Fonts.FONT_TABLE[NS.Variables.LOCALE]
				for fontName, localeFontInfo in pairs(localeFonts) do
					local fontInfo = Callback.CustomFontUtil:GetFont(fontName)
					NS[fontName] = fontInfo

					--------------------------------

					CallbackRegistry:Trigger("C_FONT_OVERRIDE", fontInfo)
				end
			else
				local localeFonts = addon.C.AddonInfo.Variables.Fonts.FONT_TABLE[NS.Variables.LOCALE]
				for fontName, fontInfo in pairs(localeFonts) do
					NS[fontName] = fontInfo
				end
			end
		end

		function Callback:OverrideFont(fontKey, newFontInfo)
			NS[fontKey] = newFontInfo

			--------------------------------

			CallbackRegistry:Trigger("C_FONT_OVERRIDE", newFontInfo)
			C_Timer.After(0, function() CallbackRegistry:Trigger("C_FONT_OVERRIDE_READY") end)
		end
	end

	--------------------------------
	-- FUNCTIONS (LibSharedMedia)
	--------------------------------

	do
		Callback.LibSharedMedia = {}
		Callback.LibSharedMedia.NAME = "LibSharedMedia-3.0"
		Callback.LibSharedMedia.LIB = nil

		--------------------------------

		function Callback.LibSharedMedia:Load()
			if not C_AddOns.IsAddOnLoaded(Callback.LibSharedMedia.NAME) then C_AddOns.LoadAddOn(Callback.LibSharedMedia.NAME) end

			--------------------------------

			local lib = LibStub and LibStub:GetLibrary(Callback.LibSharedMedia.NAME, true)
			if lib then
				function Callback.LibSharedMedia:GetFonts()
					local results = {}
					local font = lib:HashTable("font")

					for fontName, fontPath in pairs(font) do
						local fontInfo = addon.CS:NewFontInfo(fontName, fontPath, 1)
						table.insert(results, fontInfo)
					end

					return results
				end

				Callback.LibSharedMedia:GetFonts()
			end
		end
	end

	--------------------------------
	-- FUNCTIONS (CustomFontUtil)
	--------------------------------

	do
		Callback.CustomFontUtil = {}

		--------------------------------

		function Callback.CustomFontUtil:GetDefault(key)
			return addon.C.AddonInfo.Variables.Fonts.FONT_TABLE[NS.Variables.LOCALE][key]
		end

		function Callback.CustomFontUtil:GetAllFonts()
			local results = {}
			local default = Callback.CustomFontUtil:GetDefault("CONTENT_DEFAULT")

			--------------------------------

			table.insert(results, default)

			if Callback.LibSharedMedia.GetFonts then
				local libFonts = Callback.LibSharedMedia:GetFonts()
				for i = 1, #libFonts do
					table.insert(results, libFonts[i])
				end
			end

			--------------------------------

			return results
		end

		function Callback.CustomFontUtil:GetDatabase()
			return addon.C.Database.Variables.DB_GLOBAL.profile.C_FONT_CUSTOM
		end

		function Callback.CustomFontUtil:GetFont(key)
			local db = Callback.CustomFontUtil:GetDatabase()

			-- If font doesn't exist in database, use default
			if not db[key] then db[key] = Callback.CustomFontUtil:GetDefault(key) end

			-- If font doesn't pass integrity check, use default
			if not addon.CS:CheckFontIntegrity(db[key]) then db[key] = Callback.CustomFontUtil:GetDefault(key) end

			-- Return font
			if db[key] then return db[key] end
		end

		function Callback.CustomFontUtil:SetFont(key, fontInfo)
			Callback:OverrideFont(key, fontInfo)
		end

		--------------------------------

		function Callback.CustomFontUtil:GetFontNameList()
			local allFonts = Callback.CustomFontUtil:GetAllFonts()
			local fontNames = {}
			local index = 0
			for k, v in ipairs(allFonts) do
				index = index + 1
				fontNames[index] = v.name
			end

			return fontNames
		end

		function Callback.CustomFontUtil:GetFontInfoFromIndex(index)
			local allFonts = Callback.CustomFontUtil:GetAllFonts()
			return allFonts[index]
		end

		function Callback.CustomFontUtil:GetIndexFromFontInfo(font)
			local allFonts = Callback.CustomFontUtil:GetAllFonts()
			for i = 1, #allFonts do
				if allFonts[i] == font then return i end
			end
		end
	end

	--------------------------------
	-- FUNCTIONS (DropdownUtil)
	--------------------------------

	do
		Callback.DropdownUtil = {}

		--------------------------------

		function Callback.DropdownUtil:GetKeys()
			local fontNameList = Callback.CustomFontUtil:GetFontNameList()
			return fontNameList
		end

		function Callback.DropdownUtil:Get(key)
			return Callback.CustomFontUtil:GetIndexFromFontInfo(Callback.CustomFontUtil:GetFont(key)) or 1
		end

		function Callback.DropdownUtil:Set(key, index)
			local fontInfo = Callback.CustomFontUtil:GetFontInfoFromIndex(index)
			Callback.CustomFontUtil:SetFont(key, fontInfo)
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Callback:LoadFonts(false)
		Callback.LibSharedMedia:Load()

		C_Timer.After(.1, function()
			Callback:LoadFonts(true)
		end)
	end
end
