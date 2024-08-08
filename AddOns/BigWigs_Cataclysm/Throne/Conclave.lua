--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Conclave of Wind", 754, 154)
if not mod then return end
mod:RegisterEnableMob(45870, 45871, 45872) -- Anshal, Nezir, Rohash
mod:SetEncounterID(1035)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local firstWindBlast = true
local toxicSporesWarned = false
local InitialBossCheck

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.gather_strength = "%s is Gathering Strength"

	L["93059_desc"] = "Absorption Shield"

	L.full_power = "Full Power"
	L.full_power_desc = "Warning for when the bosses reach full power and start to cast the special abilities."
	L.gather_strength_emote = "%s begins to gather strength"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- Rohash
		86193, -- Wind Blast
		93059, -- Storm Shield
		-- Nezir
		84645, -- Wind Chill
		86082, -- Permafrost
		-- Anshal
		85422, -- Nurture
		86281, -- Toxic Spores
		86205, -- Soothing Breeze
		-- General
		86307, -- Gather Strength
		"full_power",
		"berserk",
	},{
		[86193] = -3172, -- Rohash
		[84645] = -3178, -- Nezir
		[85422] = -3166, -- Anshal
		[86307] = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "FullPower", 84638)

	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE") -- Gather Strength

	self:Log("SPELL_AURA_APPLIED", "StormShield", 93059)
	self:Log("SPELL_CAST_SUCCESS", "WindBlast", 86193)
	self:Log("SPELL_AURA_APPLIED_DOSE", "WindChill", 84645)
	self:Log("SPELL_CAST_SUCCESS", "Permafrost", 86082)
	self:Log("SPELL_CAST_SUCCESS", "Nurture", 85422)
	self:Log("SPELL_AURA_APPLIED", "ToxicSpores", 86281)
	self:Log("SPELL_CAST_START", "SoothingBreeze", 86205)
end

function mod:OnEngage()
	firstWindBlast = true
	toxicSporesWarned = false
	self:SimpleTimer(InitialBossCheck, 1)
	self:Berserk(480)
	self:Bar("full_power", 90, L["full_power"], 86193)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function InitialBossCheck()
	local unit = mod:GetUnitIdByGUID(45870) -- Anshal
	if unit and mod:UnitWithinRange(unit, 100) then
		mod:Bar(86205, 15.2) -- Soothing Breeze
		mod:Bar(85422, 26.3) -- Nurture
		return
	end

	local unit = mod:GetUnitIdByGUID(45872) -- Rohash
	if unit and mod:UnitWithinRange(unit, 100) then
		mod:Bar(93059, 28) -- Storm Shield
		mod:Bar(86193, 31.1) -- Wind Blast
		return
	end

	local unit = mod:GetUnitIdByGUID(45871) -- Nezir
	if unit and mod:UnitWithinRange(unit, 100) then
		mod:CDBar(86082, 11) -- Permafrost
		return
	end

	mod:Bar(86205, 17) -- Soothing Breeze
	mod:Bar(85422, 29) -- Nurture
	mod:Bar(93059, 29) -- Storm Shield
	mod:Bar(86193, 29) -- Wind Blast
	mod:CDBar(86082, 11) -- Permafrost
end

function mod:FullPower(args)
	self:Bar("full_power", 113, L["full_power"], args.spellId)
	self:Message("full_power", "yellow", L["full_power"], args.spellId)
	self:Bar(86205, 31.3) -- Soothing Breeze
end

function mod:WindChill(args)
	if self:Me(args.destGUID) then
	-- probably need to adjust stack numbers
		if args.amount == 4 then
			self:StackMessage(args.spellId, "blue", args.destName, args.amount, 8)
		elseif args.amount == 8 then
			self:StackMessage(args.spellId, "blue", args.destName, args.amount, 8)
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

function mod:StormShield(args)
	self:Bar(args.spellId, 113)
	local unit = mod:GetUnitIdByGUID(args.sourceGUID)
	if unit and mod:UnitWithinRange(unit, 100) then
		self:Message(args.spellId, "orange")
	end
end

function mod:WindBlast(args)
	self:Bar(args.spellId, firstWindBlast and 82 or 60)
	firstWindBlast = false
	local unit = mod:GetUnitIdByGUID(args.sourceGUID)
	if unit and mod:UnitWithinRange(unit, 100) then
		self:Message(args.spellId, "red")
	end
end

function mod:ToxicSpores(args)
	if not toxicSporesWarned then
		toxicSporesWarned = true
		self:Bar(args.spellId, 20)
		local unit = mod:GetUnitIdByGUID(45870) -- Anshal
		if unit and mod:UnitWithinRange(unit, 100) then
			self:Message(args.spellId, "orange")
		end
	end
end

function mod:SoothingBreeze(args)
	self:Bar(args.spellId, 32.5)
	local unit = mod:GetUnitIdByGUID(args.sourceGUID)
	if unit and mod:UnitWithinRange(unit, 100) then
		self:Message(args.spellId, "orange")
	end
end

function mod:Permafrost(args)
	self:CDBar(args.spellId, 11)
	local unit = mod:GetUnitIdByGUID(args.sourceGUID)
	if unit and mod:UnitWithinRange(unit, 100) then
		self:Message(args.spellId, "orange")
	end
end

function mod:Nurture(args)
	toxicSporesWarned = false
	self:Bar(args.spellId, 113)
	self:Bar(86281, 23) -- Toxic Spores
	local unit = mod:GetUnitIdByGUID(args.sourceGUID)
	if unit and mod:UnitWithinRange(unit, 100) then
		self:Message(args.spellId, "orange")
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg, sender)
	if msg:find(L.gather_strength_emote, nil, true) then
		self:Message(86307, "red", L["gather_strength"]:format(sender))
		self:Bar(86307, 60, L["gather_strength"]:format(sender))
		self:PlaySound(86307, "long")
	end
end
