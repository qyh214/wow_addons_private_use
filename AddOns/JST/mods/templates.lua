local T, C, L, G = unpack(select(2, ...))


----------------------------------------------------------
------------------[[    计时条    ]]----------------------
----------------------------------------------------------

--【一般施法计时条】
--[[
				T.Temp_NormalCastBar(spellID, {
					text = L["全团AE"],
					show_tar = true,
					sound = "[dodge_circle]cast",
					range_ck = true,
					threat_ck = true,
					spellIDs = {438883},
				}),
]]
T.Temp_NormalCastBar = function(spellID, args)
	if args then
		local t = {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
		}	
		MergeTable(t, args)	
		return t
	else
		return {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
		}
	end
end

--【重要施法计时条】
--[[
				T.Temp_ImportantCastBar(spellID, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
]]
T.Temp_ImportantCastBar = function(spellID, args)
	if args then
		local t = {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
			glow = true,
			group = 1,
		}	
		MergeTable(t, args)	
		return t
	else
		return {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
			glow = true,
			group = 1,
		}
	end
end

--【打坦计时条】
--[[
				T.Temp_TankCastBar(spellID, sound),
]]
T.Temp_TankCastBar = function(spellID, sound)
	return {
		category = "AlertTimerbar",
		type = "cast",
		spellID = spellID,
		group = 1,
		ficon = "0",
		sound = sound,
	}
end

--【一般CLEU计时条】
--[[
				T.Temp_NormalCLEUBar(spellID, event, dur, {
					show_tar = true,
					sound = "[dodge_circle]cast",
				}),
]]
T.Temp_NormalCLEUBar = function(spellID, event, dur, args)
	if args then
		local t = {
			category = "AlertTimerbar",
			type = "cleu",
			event = event,
			spellID = spellID,
			dur = dur,
		}	
		MergeTable(t, args)	
		return t
	else
		return {
			category = "AlertTimerbar",
			type = "cleu",
			event = event,
			spellID = spellID,
			dur = dur,
		}
	end
end

--【重要CLEU计时条】
--[[
				T.Temp_ImportantCLEUBar(spellID, event, dur, {
					show_tar = true,
					sound = "[dodge_circle]cast",
				}),
]]
T.Temp_ImportantCLEUBar = function(spellID, event, dur, args)
	if args then
		local t = {
			category = "AlertTimerbar",
			type = "cleu",
			event = event,
			spellID = spellID,
			dur = dur,
			glow = true,
			group = 1,
		}	
		MergeTable(t, args)	
		return t
	else
		return {
			category = "AlertTimerbar",
			type = "cleu",
			event = event,
			spellID = spellID,
			dur = dur,
			glow = true,
			group = 1,
		}
	end
end

--【一般队伍光环】
--[[
				T.Temp_NormalGroupAuraBar(spellID, {	
					ficon = "14",
					spellIDs = {spellID},
				}),
]]
T.Temp_NormalGroupAuraBar = function(spellID, args)
	if args then
		local t = {
			category = "AlertTimerbar",
			type = "aura",
			aura_type = "HARMFUL",
			spellID = spellID,
			unit = "group",
			show_tar = true,
		}	
		MergeTable(t, args)	
		return t
	else
		return {
			category = "AlertTimerbar",
			type = "aura",
			aura_type = "HARMFUL",
			spellID = spellID,
			unit = "group",
			show_tar = true,
		}
	end
end

--【重要打断计时条】
--[[
				T.Temp_ImportantInterruptBar(spellID, {
					show_tar = true,
					ficon = "14",
					spellIDs = {spellID},
				}),
]]
T.Temp_ImportantInterruptBar = function(spellID, args)
	if args then
		local t = {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
			ficon = "6",
			group = 1,
			glow = true,
			show_rm = true,
		}	
		MergeTable(t, args)	
		return t
	else
		return {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
			ficon = "6",
			group = 1,
			glow = true,
			show_rm = true,
		}
	end
end

--【一般打断计时条】
--[[	
				T.Temp_NormalInterruptBar(spellID, {
					show_tar = true,
					ficon = "14",
					spellIDs = {spellID},
				}),
]]
T.Temp_NormalInterruptBar = function(spellID, args)
	if args then
		local t = {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
			ficon = "6",
			sub_group = 2,
			show_rm = true,
		}
		MergeTable(t, args)
		return t
	else
		return {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
			ficon = "6",
			sub_group = 2,
			show_rm = true,
		}
	end
end

--【次级打断计时条】
--[[
				T.Temp_SubInterruptBar(spellID, {
					show_tar = true,
					ficon = "14",
					spellIDs = {spellID},
				}),
]]
T.Temp_SubInterruptBar = function(spellID, args)
	if args then
		local t = {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
			ficon = "6",
			sub_group = 2,
			enable_tag = "disable",
			show_rm = true,
		}
		MergeTable(t, args)
		return t
	else
		return {
			category = "AlertTimerbar",
			type = "cast",
			spellID = spellID,
			ficon = "6",
			sub_group = 2,
			enable_tag = "disable",
			show_rm = true,
		}
	end
end

----------------------------------------------------------
--------------------[[    图标    ]]----------------------
----------------------------------------------------------

--【普通DEBUFF图标】
--[[
				T.Temp_NormalDebuff(spellID, tip),
				
				T.Temp_NormalDebuff(spellID, tip, {
					ficon = "7",
					sound = "[defense]",
					msg = {str_applied = "%name %spell"},
					spellIDs = {spellID},
				}),
]]
T.Temp_NormalDebuff = function(spellID, tip, args)
	if args then
		local t = {
			category = "AlertIcon",
			type = "aura",
			aura_type = "HARMFUL",
			unit = "player",
			spellID = spellID,
			tip = tip,
		}
		MergeTable(t, args)	
		return t
	else
		return {
			category = "AlertIcon",
			type = "aura",
			aura_type = "HARMFUL",
			unit = "player",
			spellID = spellID,
			tip = tip,
		}
	end
end

--【重要DEBUFF图标】
--[[
				T.Temp_ImportantDebuffIcon(spellID, hl, tip),
				
				T.Temp_ImportantDebuffIcon(spellID, hl, tip, {
					ficon = "7",
					sound = "[defense]",
					msg = {str_applied = "%name %spell"},
					spellIDs = {spellID},
				}),
]]
T.Temp_ImportantDebuffIcon = function(spellID, hl, tip, args)
	if args then
		local t = {
			category = "AlertIcon",
			type = "aura",
			aura_type = "HARMFUL",
			unit = "player",
			spellID = spellID,
			tip = tip,
			hl = hl,
		}
		MergeTable(t, args)	
		return t
	else
		return {
			category = "AlertIcon",
			type = "aura",
			aura_type = "HARMFUL",
			unit = "player",
			spellID = spellID,
			tip = tip,
			hl = hl,
		}
	end
end

--【普通DOT图标】
--[[
				T.Temp_DoTIcon(spellID, ficon, hl),
]]
T.Temp_DoTIcon = function(spellID, ficon, hl)	
	return {
		category = "AlertIcon",
		type = "aura",
		aura_type = "HARMFUL",
		unit = "player",
		spellID = spellID,
		tip = L["DOT"],
		ficon = ficon,
		hl = hl or "",
	}
end

--【强力DOT图标】
--[[
				T.Temp_BigDoTIcon(spellID, ficon, hl),
]]
T.Temp_BigDoTIcon = function(spellID, ficon, hl)	
	return {
		category = "AlertIcon",
		type = "aura",
		aura_type = "HARMFUL",
		unit = "player",
		spellID = spellID,
		tip = L["强力DOT"],
		ficon = ficon,
		hl = hl or "red",
		sound = "[defense]",
	}
end

--【踩火图标】
--[[
				T.Temp_OnFireIcon(spellID),
]]
T.Temp_OnFireIcon = function(spellID)
	return {
		category = "AlertIcon",
		type = "aura",
		aura_type = "HARMFUL",
		unit = "player",
		spellID = spellID,
		tip = L["快走开"],
		sound = "[sound_dd]",
	}
end

--【有益图标】
--[[
				T.Temp_PositiveIcon(spellID, text),
]]
T.Temp_PositiveIcon = function(spellID, text)
	return {
		category = "AlertIcon",
		type = "aura",
		aura_type = "HARMFUL",
		unit = "player",
		spellID = spellID,
		tip = text,
		hl = "gre",
	}
end

--【对我施法图标】
--[[
				T.Temp_ComIcon(spellID),
				
				T.Temp_ComIcon(spellID, {
					msg = {str_applied = "%name %spell"},
					sound = "[spread]cast",
				}),
]]
T.Temp_ComIcon = function(spellID)
	if args then
		local t = {
			category = "AlertIcon",
			type = "com",
			spellID = spellID,
			hl = "yel_flash",
		}	
		MergeTable(t, args)	
		return t
	else
		return {
			category = "AlertIcon",
			type = "com",
			spellID = spellID,
			hl = "yel_flash",
		}
	end
end

----------------------------------------------------------
-------------------[[    姓名板    ]]---------------------
----------------------------------------------------------

--【姓名板打断】
--[[
				T.Temp_PlateInterrupt(spellID, npcIDs, count),
]]
T.Temp_PlateInterrupt = function(spellID, npcIDs, count)	
	return {
		category = "PlateAlert",
		type = "PlateInterrupt",
		spellID = spellID,
		mobID = npcIDs,
		interrupt = count,
		ficon = "6",
	}
end

--【姓名板光环】
--[[
				T.Temp_PlateAura(spellID),
]]
T.Temp_PlateAura = function(spellID, args)	
	return {
		category = "PlateAlert",
		type = "PlateAuras",
		aura_type = "HELPFUL",
		spellID = spellID,
	}
end

--【姓名板光环带高亮】
--[[
				T.Temp_PlateAuraWithGlow(spellID, ficon),
]]
T.Temp_PlateAuraWithGlow = function(spellID, args)
	return {
		category = "PlateAlert",
		type = "PlateAuras",
		aura_type = "HELPFUL",
		spellID = spellID,
		hl_np = true,
	}	
end

--【姓名板施法高亮】
--[[
				T.Temp_PlateCastGlow(spellID),
]]
T.Temp_PlateCastGlow = function(spellID)
	return {
		category = "PlateAlert",
		type = "PlateSpells",
		spellID = spellID,
		hl_np = true,
	}
end

--【姓名板NPC高亮】
--[[
				T.Temp_PlateNpcGlow(npcID),
]]
T.Temp_PlateNpcGlow = function(npcID)
	return {
		category = "PlateAlert",
		type = "PlateNpcID",
		mobID = npcID,
		hl_np = true,
	}
end

--【姓名板光环来源图标】
--[[
				T.Temp_PlateAuraSourceGlow(spellID),
]]
T.Temp_PlateAuraSourceGlow = function(spellID)
	return {
		category = "PlateAlert",
		type = "PlayerAuraSource",
		aura_type = "HARMFUL",
		spellID = spellID,
		hl_np = true,
	}
end

----------------------------------------------------------
------------------[[    团队框架    ]]--------------------
----------------------------------------------------------

--【施法图标】
--[[
				T.Temp_RaidCastIcon(spellID),
]]
T.Temp_RaidCastIcon = function(spellID)
	return {
		category = "RFIcon",
		type = "Cast",
		spellID = spellID,
	}
end

--【光环高亮】
--[[
				T.Temp_RaidAuraGlow(spellID, color, amount),
]]
T.Temp_RaidAuraGlow = function(spellID, color_tag, amount)
	return {
		category = "RFIcon",
		type = "Aura",
		spellID = spellID,
		color = color_tag,
		amount = amount,
	}
end

----------------------------------------------------------
------------------[[    声音提示    ]]--------------------
----------------------------------------------------------

--【CLEU提示音】
--[[
				T.Temp_CLEUSound(spellID, event, sound),
]]
T.Temp_CLEUSound = function(spellID, event, sound)
	return {
		category = "Sound",
		sub_event = event,
		spellID = spellID,
		file = sound,
	}
end

--【减益驱散提示音】
--[[
				T.Temp_DispelDebuffSound(spellID, ficon, amount, sound),
]]
T.Temp_DispelDebuffSound = function(spellID, ficon, amount, sound)
	return {
		category = "Sound",
		sub_event = "SPELL_AURA_APPLIED",
		spellID = spellID,
		ficon = ficon,
		file =  sound or "[dispel]",
		amount = amount,
	}
end

--【进攻驱散提示音】
--[[
				T.Temp_DispelBuffSound(spellID, ficon, sound, amount),
]]
T.Temp_DispelBuffSound = function(spellID, ficon, amount, sound)
	return {
		category = "Sound",
		sub_event = "SPELL_AURA_APPLIED",
		spellID = spellID,
		ficon = ficon,
		file =  sound or "[dispel]",
		amount = amount,
		aura_type = "HELPFUL",
	}
end


--【减益驱散提示音(开始施法)】
--[[
				T.Temp_DispelDebuffCastSound(spellID, ficon, sound),
]]
T.Temp_DispelDebuffCastSound = function(spellID, ficon, sound)
	return {
		category = "Sound",
		sub_event = "SPELL_CAST_START",
		spellID = spellID,
		ficon = ficon,
		file =  sound or "[prepare_dispel]",
	}
end

--【进攻驱散提示音(开始施法)】
--[[
				T.Temp_DispelBuffCastSound(spellID, ficon, sound),
]]
T.Temp_DispelBuffCastSound = function(spellID, ficon, sound)
	return {
		category = "Sound",
		sub_event = "SPELL_CAST_START",
		spellID = spellID,
		ficon = ficon,
		file =  sound or "[prepare_dispel]",
		aura_type = "HELPFUL",
	}
end

----------------------------------------------------------
------------------[[    自保技能    ]]--------------------
----------------------------------------------------------

--【CLEU自保提示】
--[[
				T.Temp_HPWatchCLEU(spellID, event, dur, threshold),
]]
T.Temp_HPWatchCLEU = function(spellID, event, dur, threshold)
	return {
		category = "HPWatch",
		type = "CLEU",
		spellID = spellID,
		event = event,
		dur = dur,
		threshold = threshold or 65,
	}
end

--【光环自保提示】
--[[
				T.Temp_HPWatchAura(spellID, amount, threshold),
]]
T.Temp_HPWatchAura = function(spellID, amount, threshold)
	return {
		category = "HPWatch",
		type = "Aura",
		spellID = spellID,
		amount = amount,
		threshold = threshold or 65,
	}
end