--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Atal'ai Defenders Discovery", 109)
if not mod then return end
mod:RegisterEnableMob(
	221759, 221637, -- Gasher
	221834, 221638, -- Loro
	218868, 221835, -- Mijan
	221640, 221837, -- Zul'Lor
	221836, 221639, -- Zolo
	218922 -- Hukku
)
mod:SetEncounterID(2954)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local magicCount = 0
local magicTime = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Atal'ai Defenders"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		-- Zul'Lor
		446372, -- Corrupted Slam
		446364, -- Frailty
		-- Mijan
		438294, -- Thorns
		438341, -- Renew
		438335, -- Healing Ward
		-- Zolo
		446338, -- Chain Lightning
		-- Gasher
		445284, -- Fervor
		445289, -- Spinning Axes
		-- Loro
		23511, -- Demoralizing Shout
		-- Hukku
		438350, -- Shadow Bolt Volley
		446360, -- Hukku's Guardians
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	-- Zul'Lor
	self:Log("SPELL_CAST_START", "CorruptedSlamStart", 446372)
	self:Log("SPELL_CAST_SUCCESS", "Frailty", 446364)
	self:Log("SPELL_AURA_APPLIED", "FrailtyApplied", 446364)
	self:Log("SPELL_AURA_REMOVED", "FrailtyRemoved", 446364)
	self:Log("SPELL_CAST_SUCCESS", "SummonZulLor", 444962)
	-- Mijan
	self:Log("SPELL_CAST_SUCCESS", "Thorns", 438294)
	self:Log("SPELL_CAST_START", "RenewStart", 438341)
	self:Log("SPELL_INTERRUPT", "RenewInterrupted", "*")
	self:Log("SPELL_CAST_START", "HealingWardStart", 438335)
	self:Log("SPELL_CAST_SUCCESS", "SummonMijan", 444963)
	-- Zolo
	self:Log("SPELL_CAST_START", "ChainLightningStart", 446338)
	self:Log("SPELL_CAST_SUCCESS", "SummonZolo", 444964)
	-- Gasher
	self:Log("SPELL_AURA_APPLIED_DOSE", "FervorApplied", 445284)
	self:Log("SPELL_CAST_SUCCESS", "SpinningAxes", 445289)
	self:Log("SPELL_CAST_SUCCESS", "SummonGasher", 444747)
	-- Loro
	self:Log("SPELL_CAST_START", "DemoralizingShoutStart", 23511)
	self:Log("SPELL_CAST_SUCCESS", "SummonLoro", 444960)
	-- Hukku
	self:Log("SPELL_CAST_START", "ShadowBoltVolleyStart", 438350)
	self:Log("SPELL_CAST_SUCCESS", "HukkusGuardians", 446360)
end

function mod:OnEngage()
	magicCount = 0
	magicTime = 0
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Zul'Lor (1)
function mod:Frailty(args)
	magicCount = 0
	magicTime = args.time
	self:Message(args.spellId, "yellow", CL.on_group:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
end

function mod:FrailtyApplied()
	magicCount = magicCount + 1
end

function mod:FrailtyRemoved(args)
	magicCount = magicCount - 1
	if magicCount == 0 then
		self:Message(args.spellId, "green", CL.removed_after:format(args.spellName, args.time-magicTime))
	end
end

function mod:CorruptedSlamStart(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "long")
end

function mod:SummonZulLor()
	self:SetStage(2)
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:PlaySound("stages", "info")
end

-- Mijan (2)
function mod:Thorns(args)
	self:Message(args.spellId, "orange", CL.magic_buff_boss:format(args.spellName))
end

function mod:RenewStart(args)
	self:Message(args.spellId, "red", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "warning")
end

function mod:RenewInterrupted(args)
	if args.extraSpellName == self:SpellName(438341) then
		self:Message(438341, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:HealingWardStart(args)
	self:Message(args.spellId, "red", CL.incoming:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
end

function mod:SummonMijan()
	self:SetStage(3)
	self:Message("stages", "cyan", CL.stage:format(3), false)
	self:PlaySound("stages", "info")
end

-- Zolo (3)
function mod:ChainLightningStart(args)
	self:Message(args.spellId, "red", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "warning")
end

function mod:SummonZolo()
	self:SetStage(4)
	self:Message("stages", "cyan", CL.stage:format(4), false)
	self:PlaySound("stages", "info")
end

-- Gasher (4)
function mod:FervorApplied(args)
	if args.amount % 4 == 0 then
		self:StackMessage(args.spellId, "yellow", CL.boss, args.amount, 8)
	end
end

function mod:SpinningAxes(args)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "alarm")
end

function mod:SummonGasher()
	self:SetStage(5)
	self:Message("stages", "cyan", CL.stage:format(5), false)
	self:PlaySound("stages", "info")
end

-- Loro (5)
function mod:DemoralizingShoutStart(args)
	self:Message(args.spellId, "red", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "warning")
end

function mod:SummonLoro()
	self:SetStage(6)
	self:Message("stages", "cyan", CL.stage:format(6), false)
	self:PlaySound("stages", "info")
end

-- Hukku (6)
function mod:ShadowBoltVolleyStart(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "warning")
end

function mod:HukkusGuardians(args)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "alarm")
end
