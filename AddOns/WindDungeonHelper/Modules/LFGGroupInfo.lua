-- Module: LFGGroupInfo
-- Author: houshuu@NGA
-- Icon resource is from FFXIV public kit
local AddOnName, WDH = ...
local L, B, C, DB = WDH.L, WDH.Base, WDH.Config, WDH.DataBase
local LGI = WDH:NewModule("LFGGroupInfo", "AceHook-3.0")

local GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local GetSearchResultMemberInfo = C_LFGList.GetSearchResultMemberInfo
local pairs, format, twipe, tsort = pairs, string.format, table.wipe, table.sort

DB.defaults.profile.modules.LFGGroupInfo = {
	enable = true,
	compact_mode = false,
	hide_title = false,
}

C.ModulesOrder.LFGGroupInfo = 22
C.ModulesOption.LFGGroupInfo = {
    name = L["LFG Group Info"],
	type = "group",
	childGroups = "tree",
    args = {
		general = {
			order = 1,
			name = L["General"],
			type = "group",
			inline = true,
			set = function(info,value) LGI.db[info[#info]] = value end,
			get = function(info) return LGI.db[info[#info]] end,
			args = {
				enable = {
					order = 1,
					name = L["Enable"],
					desc = L["Enables / disables the module"],
					type = "toggle",
					width = "full",
				},
				compact_mode = {
					order = 2,
					name = L["Compact mode"],
					desc = L["Display a role icon for each class instead of the role title."],
					type = "toggle",
				},
				hide_title = {
					order = 3,
					name = L["No title in tooltip"],
					desc = L["Do not display the WindDungeonHelper title in tooltip."],
					type = "toggle",
				},
			},
		},
    }
}

local function AddClassInfo(tooltip, resultID)
	if not LGI.db.enable then return end
	local result = GetSearchResultInfo(resultID)
	local cache = {
		TANK = {},
		HEALER = {},
		DAMAGER = {},
	}

	local display = {
		TANK = false, 
		HEALER = false,
		DAMAGER = false,
	}

	local display_order = {
		[1] = "TANK",
		[2] = "HEALER",
		[3] = "DAMAGER",
	}

	local role_text = {
		TANK = "|cff00a8ff".._G["TANK"].."|r",
		HEALER = "|cff2ecc71".._G["HEALER"].."|r",
		DAMAGER = "|cffe74c3c".._G["DAMAGER"].."|r",
	}

	local role_icons = {
		TANK = {
			inline  = "|TInterface\\AddOns\\WindDungeonHelper\\Texture\\Tank:18:18:0:0:64:64:8:56:8:56|t",
			compact = "|TInterface\\AddOns\\WindDungeonHelper\\Texture\\Tank:22:22:0:0:64:64:8:56:8:56|t",
		},
		HEALER = {
			inline  = "|TInterface\\AddOns\\WindDungeonHelper\\Texture\\Healer:18:18:0:0:64:64:8:56:8:56|t",
			compact = "|TInterface\\AddOns\\WindDungeonHelper\\Texture\\Healer:22:22:0:0:64:64:8:56:8:56|t",
		},
		DAMAGER = {
			inline  = "|TInterface\\AddOns\\WindDungeonHelper\\Texture\\Damager:18:18:0:0:64:64:8:56:8:56|t",
			compact = "|TInterface\\AddOns\\WindDungeonHelper\\Texture\\Damager:22:22:0:0:64:64:8:56:8:56|t",
		},
	}

	-- Get result and save to cache
	for i=1, result.numMembers do
		local role, class = GetSearchResultMemberInfo(resultID, i)
		-- init the counter
		if not display[role] then display[role] = true end
		if not cache[role][class] then cache[role][class] = 0 end
		cache[role][class] = cache[role][class] + 1
	end

	-- Set display order
	tsort(cache, function(a,b) print(a); return display_order[a] > display_order[b] end)
	
	-- Add text in tooltip
	if not LGI.db.hide_title then
		tooltip:AddLine(" ")
		tooltip:AddLine(L["|cff00a8ffWDH|r Party Info"])
	end
	
	-- [compact mode] Take a little break between title and members
	if LGI.db.compact_mode then tooltip:AddLine(" ") end

	-- Display the classes by role
	for i=1, #display_order do 
		local role = display_order[i]
		local members = cache[role]
		if members and display[role] then
			-- [not compact mode] Add the role title
			if not LGI.db.compact_mode then
				tooltip:AddLine(" ")
				tooltip:AddLine(role_icons[role].inline.." "..role_text[role])
			end
			for class, counter in pairs(members) do
				local number_text, icon = "", ""
				local class_color = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR
				local class_color_prefix = "|c"..class_color:GenerateHexColor()
				
				-- Just add times symbol if there are not only one player of this class
				if counter ~= 1 then number_text = format(" × %d", counter) end
				
				-- [compact mode] Add a icon to the head of class string
				if LGI.db.compact_mode then icon = role_icons[role].compact.." " end

				tooltip:AddLine(icon..class_color_prefix..LOCALIZED_CLASS_NAMES_MALE[class].."|r"..number_text)
			end
		end
	end

	-- Cleanup
	twipe(cache)
	
	-- Resize the tooltip
	tooltip:Show()

	-- Change the tooltip to the better position
	tooltip:ClearAllPoints()
	tooltip:SetPoint("TOPLEFT", _G.LFGListFrame, "TOPRIGHT", 10, 0)
end

function LGI:OnInitialize()
    self.Version = B.Version
    self.db = DB.profile.modules.LFGGroupInfo
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", AddClassInfo)
end
