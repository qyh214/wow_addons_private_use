local E, L = select(2, ...):unpack()
local P = E.Party

local GetSpellInfo = GetSpellInfo or function(spellID)
	if not spellID then
		return nil;
	end

	local spellInfo = C_Spell.GetSpellInfo(spellID);
	if spellInfo then
		return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
	end
end

local markEnhancedDesc = {}
for k, v in pairs(E.spell_marked) do
	if not C_Spell.DoesSpellExist(k) or (v ~= true and not C_Spell.DoesSpellExist(v)) then
		E.spell_marked[k] = nil

	else
		local id = v == true and k or v
		local name, _, icon = GetSpellInfo(id)
		name = format("|T%s:18|t %s", icon, name)
		markEnhancedDesc[#markEnhancedDesc + 1] = name
	end
end
markEnhancedDesc = table.concat(markEnhancedDesc, "\n")

local highlight = {
	name = L["Highlighting"],
	order = 35,
	type = "group",
	get = function(info) return E.profile.Party[ info[2] ].highlight[ info[#info] ] end,
	set = function(info, value)
		local key = info[2]
		E.profile.Party[key].highlight[ info[#info] ] = value
		if P:IsCurrentZone(key) then
			P:Refresh()
		end
	end,
	args = {
		glow = {
			name = L["Glow Icons"],
			order = 10,
			type = "group",
			inline = true,
			args = {
				glow = {
					name = ENABLE,
					desc = L["Display a glow animation around an icon when it is activated"],
					order = 1,
					type = "toggle",
				},
			}
		},
		highlight = {
			disabled = function(info) return info[5] and not E.profile.Party[ info[2] ].highlight.glowBuffs end,
			name = L["Highlight Icons"],
			order = 20,
			type = "group",
			inline = true,
			args = {
				glowBuffs = {
					disabled = false,
					name = ENABLE,
					desc = L["Highlight the icon when a buffing spell is used until the buff falls off"],
					order = 1,
					type = "toggle",
				},
				glowType = {
					name = TYPE,
					order = 2,
					type = "select",
					values = {
						actionBar = L["Strong Yellow Glow"],
						wardrobe = L["Weak Purple Glow"],
					}
				},
				buffTypes = {
					name = L["Spell Types"],
					order = 3,
					type = "multiselect",
					values = E.L_HIGHLIGHTS,
					get = function(info, k) return E.profile.Party[ info[2] ].highlight.glowBuffTypes[k] end,
					set = function(info, k, value)
						local key = info[2]
						E.profile.Party[key].highlight.glowBuffTypes[k] = value
						if P:IsCurrentZone(key) then
							P:Refresh()
						end
					end,
				},
			}
		},
		glowBorder = {
			disabled = function(info) return not E.profile.Party[ info[2] ].highlight.glowBorder end,
			name = L["Glow Border"],
			order = 30,
			type = "group",
			inline = true,
			args = {
				glowBorder = {
					disabled = false,
					name = ENABLE,
					desc = format("%s.\n\n|cffff2020%s", L["Glow Border"], L["Only applies to spells that have Glow enabled in the Spells tab"]),
					order = 1,
					type = "toggle",
				},
				glowBorderCondition = {
					name = L["Condition"],
					order = 2,
					type = "select",
					values = {
						[1] = L["Usable"],
						[2] = L["Unusable"],
						[3] = L["Both"],
					},
				},
			}
		},
		markEnhanced = {
			disabled = function(info) return not E.profile.Party[ info[2] ].icons.markEnhanced end,
			name = L["Mark Enhanced Spells"],
			order = 40,
			type = "group",
			inline = true,
			args = {
				markEnhanced = {
					disabled = false,
					name = ENABLE,
					desc = L["Mark icons with a red dot to indicate enhanced spells"] .. "\n\n" .. markEnhancedDesc,
					order = 1,
					type = "toggle",
					get = P.getIcons,
					set = P.setIcons,
				},
			}
		},
	}
}

P:RegisterSubcategory("highlight", highlight)
