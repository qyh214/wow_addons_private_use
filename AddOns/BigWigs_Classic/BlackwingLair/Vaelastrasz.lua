--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Vaelastrasz the Corrupt", 469, 1530)
if not mod then return end
mod:RegisterEnableMob(13020)
mod:SetEncounterID(611)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.warmup_trigger = "Too late, friends!"
	L.tank_bomb = "Tank Bomb"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"warmup",
		{18173, "ICON", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Burning Adrenaline
		{23620, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Burning Adrenaline
	},nil,{
		[18173] = CL.bomb, -- Burning Adrenaline (Bomb)
		[23620] = L.tank_bomb, -- Burning Adrenaline (Tank Bomb)
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_CAST_SUCCESS", "BurningAdrenaline", 18173)
	self:Log("SPELL_AURA_APPLIED", "BurningAdrenalineApplied", 18173)
	self:Log("SPELL_AURA_REMOVED", "BurningAdrenalineRemoved", 18173)
	self:Log("SPELL_CAST_SUCCESS", "BurningAdrenalineTank", 23620)
	self:Log("SPELL_AURA_APPLIED", "BurningAdrenalineTankApplied", 23620)
	self:Log("SPELL_AURA_REMOVED", "BurningAdrenalineTankRemoved", 23620)
end

function mod:OnEngage()
	self:CDBar(18173, 16, CL.bomb) -- Burning Adrenaline
	self:Bar(23620, 45, L.tank_bomb) -- Burning Adrenaline
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.warmup_trigger, nil, true) then
		self:Bar("warmup", 43.5, CL.active, "inv_misc_monsterscales_05") -- Can vary up to 45s
	end
end

function mod:BurningAdrenaline(args)
	self:CDBar(args.spellId, 16, CL.bomb)
end

function mod:BurningAdrenalineApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.bomb)
	self:PrimaryIcon(args.spellId, args.destName)
	self:TargetBar(args.spellId, 20, args.destName, CL.explosion)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, CL.bomb, nil, "Bomb")
		self:SayCountdown(args.spellId, 20, nil, 5)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:BurningAdrenalineRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
	--self:PrimaryIcon(args.spellId) -- Next one is applied before previous one expires
	self:StopBar(CL.explosion, args.destName)
end

function mod:BurningAdrenalineTank(args)
	self:Bar(args.spellId, 45, L.tank_bomb)
end

function mod:BurningAdrenalineTankApplied(args)
	self:TargetMessage(args.spellId, "purple", args.destName, L.tank_bomb)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, L.tank_bomb, nil, "Tank Bomb")
		self:SayCountdown(args.spellId, 20, nil, 5)
	end
	self:TargetBar(args.spellId, 20, args.destName, L.tank_bomb)
	self:PlaySound(args.spellId, "long")
end

function mod:BurningAdrenalineTankRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
	self:StopBar(L.tank_bomb, args.destName)
end
