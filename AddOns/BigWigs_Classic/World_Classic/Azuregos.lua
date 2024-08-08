--------------------------------------------------------------------------------
-- Module Declaration
--

if BigWigsLoader.isSeasonOfDiscovery then return end
local mod, CL = BigWigs:NewBoss("Azuregos", -1447)
if not mod then return end
mod:RegisterEnableMob(6109)
mod:SetAllowWin(true)
mod.otherMenu = -947
mod.worldBoss = 6109

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Azuregos"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{22067, "CASTBAR", "EMPHASIZE"}, -- Reflection
		21147, -- Arcane Vacuum
		21099, -- Frost Breath
		21097, -- Manastorm
	},nil,{
		[21147] = CL.teleport, -- Arcane Vacuum (Teleport)
		[21099] = CL.interruptible, -- Frost Breath (Interruptible)
		[21097] = CL.interruptible, -- Manastorm (Interruptible)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "ReflectionApplied", 22067)
	self:Log("SPELL_AURA_REMOVED", "ReflectionRemoved", 22067)
	self:Log("SPELL_CAST_SUCCESS", "ArcaneVacuum", 21147)
	self:Log("SPELL_CAST_START", "FrostBreath", 21099)
	self:Log("SPELL_CAST_START", "Manastorm", 21097)

	self:Death("Win", 6109)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:ReflectionApplied(args)
		prev = args.time
		self:StopBar(args.spellName)
		self:Message(args.spellId, "red")
		self:CastBar(args.spellId, 10)
		self:PlaySound(args.spellId, "warning")
	end

	function mod:ReflectionRemoved(args)
		self:StopBar(CL.cast:format(args.spellName))
		self:Message(args.spellId, "green", CL.over:format(args.spellName), nil, true) -- Disable emphasize
		self:CDBar(args.spellId, prev > 0 and (20 - (args.time-prev)) or 10) -- Show the bar after it ends
		self:PlaySound(args.spellId, "info")
	end
end

function mod:ArcaneVacuum(args)
	self:Message(args.spellId, "yellow", CL.teleport)
	self:PlaySound(args.spellId, "alarm")
end

function mod:FrostBreath(args)
	self:Message(args.spellId, "orange", CL.extra:format(CL.breath, CL.interruptible))
	self:PlaySound(args.spellId, "alert")
end

function mod:Manastorm(args)
	self:Message(args.spellId, "orange", CL.extra:format(args.spellName, CL.interruptible))
	self:PlaySound(args.spellId, "alert")
end
