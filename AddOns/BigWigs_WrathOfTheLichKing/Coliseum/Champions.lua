--------------------------------------------------------------------------------
-- Module Declaration
--
local mod, CL = BigWigs:NewBoss("Faction Champions", 649, 1621)
if not mod then return end
mod:RegisterEnableMob(
	-- Alliance NPCs
	34460, 34461, 34463, 34465, 34466, 34467, 34468, 34469, 34470, 34471, 34472, 34473, 34474, 34475,
	-- Horde NPCs
	34441, 34444, 34445, 34447, 34448, 34449, 34450, 34451, 34453, 34454, 34455, 34456, 34458, 34459
)
-- mod:SetEncounterID(1086) -- Fires too early
-- mod:SetRespawnTime(30)
mod.toggleOptions = {65960, 65801, 65877, 66010, 65947, {65816, "FLASH"}, 67514, 67777, 65983, 65980}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.defeat_trigger = "A shallow and tragic victory."

	L["Shield on %s!"] = "Shield on %s!"
	L["Bladestorming!"] = "Bladestorming!"
	L["Hunter pet up!"] = "Hunter pet up!"
	L["Felhunter up!"] = "Felhunter up!"
	L["Heroism on champions!"] = "Heroism on champions!"
	L["Bloodlust on champions!"] = "Bloodlust on champions!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Blind", 65960)
	self:Log("SPELL_AURA_APPLIED", "Polymorph", 65801)
	self:Log("SPELL_AURA_APPLIED", "Wyvern", 65877)
	self:Log("SPELL_AURA_APPLIED", "DivineShield", 66010)
	self:Log("SPELL_CAST_SUCCESS", "Bladestorm", 65947)
	self:Log("SPELL_SUMMON", "Felhunter", 67514)
	self:Log("SPELL_SUMMON", "Cat", 67777)
	self:Log("SPELL_CAST_SUCCESS", "Heroism", 65983)
	self:Log("SPELL_CAST_SUCCESS", "Bloodlust", 65980)
	self:Log("SPELL_AURA_APPLIED", "Hellfire", 65816)
	self:Log("SPELL_AURA_REMOVED", "HellfireStopped", 65816)
	self:Log("SPELL_DAMAGE", "HellfireOnYou", 65817)
	self:Log("SPELL_MISSED", "HellfireOnYou", 65817)

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg == L.defeat_trigger or msg:find(L.defeat_trigger, nil, true) then
		self:Win()
	end
end

function mod:Hellfire(args)
	self:MessageOld(args.spellId, "orange")
	self:Bar(args.spellId, 15)
end

function mod:HellfireStopped(args)
	self:StopBar(args.spellId)
end

do
	local last = 0
	function mod:HellfireOnYou(args)
		if self:Me(args.destGUID) then
			local t = GetTime()
			if t-4 > last then
				self:MessageOld(65816, "blue", "alarm", CL["you"]:format(self:SpellName(65816))) -- Hellfire
				self:Flash(65816)
				last = t
			end
		end
	end
end

function mod:Wyvern(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow")
end

function mod:Blind(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow")
end

function mod:Polymorph(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow")
end

function mod:DivineShield(args)
	self:MessageOld(args.spellId, "orange", nil, L["Shield on %s!"]:format(args.destName))
end

function mod:Bladestorm(args)
	self:MessageOld(args.spellId, "red", nil, L["Bladestorming!"])
end

function mod:Cat(args)
	self:MessageOld(args.spellId, "orange", nil, L["Hunter pet up!"])
end

function mod:Felhunter(args)
	self:MessageOld(args.spellId, "orange", nil, L["Felhunter up!"])
end

function mod:Heroism(args)
	self:MessageOld(args.spellId, "red", nil, L["Heroism on champions!"])
end

function mod:Bloodlust(args)
	self:MessageOld(args.spellId, "red", nil, L["Bloodlust on champions!"])
end

