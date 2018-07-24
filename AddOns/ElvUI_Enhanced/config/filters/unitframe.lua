local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

local function SpellName(id)
	local name = GetSpellInfo(id) 	
	if not name then
		print('|cff1784d1ElvUI:|r SpellID is not valid: '..id..'. Please check for an updated version, if none exists report to ElvUI author.')
		return 'Impale'
	else
		return name
	end
end

local function Defaults(priorityOverride)
	return {['enable'] = true, ['priority'] = priorityOverride or 0}
end

-- Make sure we see these spell in the aura frame (WhiteList)

G.unitframe.aurafilters['Whitelist']['spells'][SpellName(132726)] = Defaults()	-- Growing (Plants in Sunsong Ranch)
