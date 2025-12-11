local T, C, L, G = unpack(JST)

G.Encounter_Order[1302] = {2684, 2686, 2685, 2687, 2688, 2747, 2690, 2691, "r2810"}

for _, v in pairs(G.Encounter_Order[1302]) do
	if type(v) == "number" then
		G.Timeline_Data[v] = {}
	end
end

local function soundfile(filename, arg)
	return string.format("[1302\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["你正处于稳定飞行"] = "你正处于%s"
elseif G.Client == "ruRU" then
	--L["你正处于稳定飞行"] = "You are currently in %s"
else
	L["你正处于稳定飞行"] = "You are currently in %s"
end

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["r2810"] = { -- Test
	map_id = 2810,
	alerts = {
		{ -- 翔空雷什
			spells = {
				{1235114},
			},
			options = {
				{ -- 首领模块 提示稳定飞行模式
					category = "BossMod",
					spellID = 404468,
					name = string.format(L["你正处于稳定飞行"], T.GetIconLink(404468)),
					points = {hide = true},
					events = {
						["UNIT_AURA_ADD"] = true,
						["UNIT_AURA_REMOVED"] = true,
						["ZONE_CHANGED"] = true,
						["ZONE_CHANGED_INDOORS"] = true,
					},
					init = function(frame)
						T.RegisterWatchAuraSpellID(404468)
						
						local mapGroupID = C_Map.GetMapGroupID(2467)
						local mapGroupMembersInfo = C_Map.GetMapGroupMembersInfo(mapGroupID)
						
						for index, mapGroupMemberInfo in ipairs(mapGroupMembersInfo) do
							if mapGroupMemberInfo.mapID == 2467 then
								frame.mapName = mapGroupMemberInfo.name
							end
						end
						
						if not frame.text_frame then
							frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
							frame.text_frame.text:SetText(string.format(L["你正处于稳定飞行"], T.GetIconLink(404468)))
						end
						
						function frame:check()
							local subZone = GetSubZoneText()
							if subZone == self.mapName and AuraUtil.FindAuraBySpellID(404468, "player", "HELPFUL") then
								self.text_frame:Show()
							else
								self.text_frame:Hide()
							end
						end						
					end,
					update = function(frame, event, ...)
						if event == "UNIT_AURA_ADD" or event == "UNIT_AURA_REMOVED" then
							local unit, spellID = ...
							if unit == "player" and spellID == 404468 then
								frame:check()
							end
						elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
							frame:check()
						else
							frame:check()
						end
					end,
					reset = function(frame, event)
						frame.text_frame:Hide()
					end,
				},
			},
		},
	},
}