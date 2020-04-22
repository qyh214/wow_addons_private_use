-- Import libraries
local AddOnName, WDH = ...
local pairs = pairs
LibStub("AceAddon-3.0"):NewAddon(WDH, AddOnName, "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnName, true)
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(L["Wind Dungeon Helper"], {
	type = "data source",
	text = "WDH",
	icon = "Interface\\ICONS\\Achievement_Challengemode_Gold",
	OnClick = function() WDH:OpenOptionFrame() end,
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		tooltip:AddLine("|cff00a8ff"..L["Wind Dungeon Helper"].."|r")
		tooltip:AddLine(L["Click to toggle config window."])
	end,
})

WDH.L, WDH.LDB = L, LDB
WDH.Base = {}
WDH.Config = {}
WDH.DataBase = {}
local B, C, DB = WDH.Base, WDH.Config, WDH.DataBase

-- Base
B.AddonName = L["Wind Dungeon Helper"]
B.Version = GetAddOnMetadata(AddOnName, "Version")
B.AddonMsgPrefix = "WDH"

-- Config
WDH.Config.ModulesOrder = {}
WDH.Config.ModulesOption = {}
function WDH.Config.CreateOptionTable()
	local tempOptionsTable = {
		type = "group",
		name = B.ColorString(B.AddonName).." - "..B.Version,
		args = {
			author = {
				order = 1,
				name = L["Author"]..": "..B.ColorString("Tabimonk-暗影之月(TW)", 0, 1, 0.59).." @ 人生海海",
				type = "description",
			},
			-- enable = {
			-- 	order = 2,
			-- 	name = L["Enable"],
			-- 	desc = L["Enables / disables Wind Dungeon Helper"],
			-- 	type = "toggle",
			-- 	set = function(info,val) DB.profile.enable = val end,
			-- 	get = function(info) return DB.profile.enable end
			-- },
			enable = {
				order = 2,
				name = L["Minimap icon"],
				desc = L["Enables / disables Wind Dungeon Helper minimap icon"],
				type = "toggle",
				set = function(info,val)
					DB.profile.minimapicon.hide = not val
					if val then LibStub("LibDBIcon-1.0"):Show(L["Wind Dungeon Helper"])
					else LibStub("LibDBIcon-1.0"):Hide(L["Wind Dungeon Helper"]) end
				end,
				get = function(info) return not DB.profile.minimapicon.hide end
			},
			addondesctitle = {
				order = 3,
				type = "header",
				name = L["Description"],
			},
			addondesctext = {
				order = 4,
				type = "description",
				name = L["Wind Dungeon Helper is a combat helper works with several modules.\nIf you want to share the module you write, just pull request on addon github page."],
			},
			github = {
				order = 5,
				type  = "input",
				width = "full",
				name  = L["Wind Dungeon Helper on Github"],
				get   = function(info) return "https://github.com/fang2hou/WindDungeonHelper" end,
				set   = function(info) return "https://github.com/fang2hou/WindDungeonHelper" end,
			},
			moduleconfigtitle = {
				order = 6,
				type = "header",
				name = L["Modules"],
			},
		}
	}

	for k, v in pairs(WDH.Config.ModulesOption) do
		tempOptionsTable.args[k] = v
		tempOptionsTable.args[k].order = WDH.Config.ModulesOrder[k]
	end

	return tempOptionsTable
end

-- DataBase
DB.defaults = {
	profile = {
		enable = true,
		minimapicon = {
			hide = false,
		},
		modules = {},
	}
}

-- Functions
local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return format("%02x%02x%02x", r*255, g*255, b*255)
end

function B.ColorString(str, r, g, b)
	local hex
	local coloredString
	
	if r and g and b then
		hex = RGBToHex(r, g, b)
	else
		hex = RGBToHex(52/255, 152/255, 219/255)
	end
	
	coloredString = "|cff"..hex..str.."|r"
	return coloredString
end

function B.Round(number, decimals)
	return (("%%.%df"):format(decimals)):format(number)
end

function table.pack(...)
	return { n = select("#", ...), ... }
end

function WDH:OnInitialize()
    self:SetUpConfig()
	self:RegisterChatCommand("wdh", "OpenOptionFrame")
	C_ChatInfo.RegisterAddonMessagePrefix(B.AddonMsgPrefix)
end

function WDH:SetUpConfig()
	DB.db = LibStub("AceDB-3.0"):New(AddOnName.."DB", DB.defaults)
	DB.profile = DB.db.profile
	DB.profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(DB.db)

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddOnName, function() return C.CreateOptionTable() end)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddOnName.."Profiles", DB.profileOptions)

    self.optionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, B.AddonName)
	self.optionFrame.profilePanel = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName.."Profiles", L["Profiles"], B.AddonName)

    local logo = CreateFrame('Frame', nil, self.optionFrame)
    logo:SetFrameLevel(4)
    logo:SetSize(64, 64)
    logo:SetPoint('TOPRIGHT', -12, -12)
    logo:SetBackdrop({bgFile = ('Interface\\ICONS\\TRADE_ARCHAEOLOGY_NERUBIAN_OBELISK'):format(AddOnName)})
    self.optionFrame.logo = logo

    LibStub("LibDBIcon-1.0"):Register(L["Wind Dungeon Helper"], self.LDB, DB.profile.minimapicon)
end

function WDH:OpenOptionFrame()
    InterfaceOptionsFrame_OpenToCategory(self.optionFrame.profilePanel)
    InterfaceOptionsFrame_OpenToCategory(self.optionFrame)
end
