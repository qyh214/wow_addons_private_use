local W, F, L, P, O = unpack(select(2, ...))
local GI = W:GetModule("GroupInfo")
local LFGPI = W.Utilities.LFGPlayerInfo

local cache = {
	groupInfo = {},
}

O.groupInfo = {
	order = 5,
	name = L["Group Info"],
	type = "group",
	get = function(info)
		return W.db[info[#info - 1]][info[#info]]
	end,
	set = function(info, value)
		W.db[info[#info - 1]][info[#info]] = value
		GI:ProfileUpdate()
	end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			desc = L["Add LFG group info to tooltip."],
			width = "full",
		},
		title = {
			order = 2,
			type = "toggle",
			name = L["Add Title"],
			desc = L["Display an additional title."],
		},
		mode = {
			order = 3,
			name = L["Mode"],
			type = "select",
			values = {
				NORMAL = L["Normal"],
				COMPACT = L["Compact"],
			},
		},
		classIconStyle = {
			order = 4,
			name = L["Class Icon Style"],
			type = "select",
			values = function()
				local result = {}
				for _, style in pairs(F.GetClassIconStyleList()) do
					local monkIcon = F.GetClassIconStringWithStyle("MONK", style)
					local druidIcon = F.GetClassIconStringWithStyle("DRUID", style)
					local evokerIcon = F.GetClassIconStringWithStyle("EVOKER", style)

					if monkIcon and druidIcon and evokerIcon then
						result[style] = format("%s %s %s", monkIcon, druidIcon, evokerIcon)
					end
				end
				return result
			end,
		},
		betterAlign1 = {
			order = 5,
			type = "description",
			name = "",
			width = "full",
		},
		template = {
			order = 6,
			type = "input",
			name = L["Template"],
			desc = L["Please click the button below to read reference."],
			width = "full",
			get = function(info)
				return cache.groupInfo.template or W.db.groupInfo.template
			end,
			set = function(info, value)
				cache.groupInfo.template = value
			end,
		},
		resourcePage = {
			order = 7,
			type = "execute",
			name = L["Reference"],
			desc = format(
				"|cff00d1b2%s|r (%s)\n%s\n%s\n%s",
				L["Tips"],
				L["Editbox"],
				L["CTRL+A: Select All"],
				L["CTRL+C: Copy"],
				L["CTRL+V: Paste"]
			),
			func = function()
				if W.Locale == "zhCN" or W.Locale == "zhTW" then
					StaticPopup_Show(
						"WIND_DUNGEON_HELPER_EDITBOX",
						L["Wind Dungeon Helper"] .. " - " .. L["Reference"],
						nil,
						"https://github.com/fang2hou/ElvUI_WindTools/wiki/预组建队伍玩家信息"
					)
				else
					StaticPopup_Show(
						"WIND_DUNGEON_HELPER_EDITBOX",
						L["Wind Dungeon Helper"] .. " - " .. L["Reference"],
						nil,
						"https://github.com/fang2hou/ElvUI_WindTools/wiki/LFG-Player-Info"
					)
				end
			end,
		},
		useDefaultTemplate = {
			order = 8,
			type = "execute",
			name = L["Default"],
			func = function(info)
				W.db[info[#info - 1]].template = P[info[#info - 1]].template
				cache.groupInfo.template = nil
			end,
		},
		applyButton = {
			order = 9,
			type = "execute",
			name = L["Apply"],
			disabled = function()
				return not cache.groupInfo.template
			end,
			func = function(info)
				W.db[info[#info - 1]].template = cache.groupInfo.template
			end,
		},
		betterAlign2 = {
			order = 10,
			type = "description",
			name = "",
			width = "full",
		},
		previewText = {
			order = 11,
			type = "description",
			name = function(info)
				LFGPI:SetClassIconStyle(W.db[info[#info - 1]].classIconStyle)
				local text = LFGPI:ConductPreview(cache.groupInfo.template or W.db[info[#info - 1]].template)
				return L["Preview"] .. ": " .. text
			end,
		},
	},
}
