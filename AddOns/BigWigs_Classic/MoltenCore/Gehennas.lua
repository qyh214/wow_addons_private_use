--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Gehennas", 409, 1521)
if not mod then return end
mod:RegisterEnableMob(12259, 228431) -- Gehennas, Gehennas (Season of Discovery)
mod:SetEncounterID(665)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L["19716_desc"] = mod:GetSeason() == 2 and 461232 or 19716
end

--------------------------------------------------------------------------------
-- Locals
--

local curseCount = 0
local curseTime = 0

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		19716, -- Gehennas' Curse
		19717, -- Rain of Fire
	},nil,{
		[19716] = CL.curse, -- Gehennas' Curse (Curse)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "GehennasCurse", 19716)
	self:Log("SPELL_AURA_APPLIED", "GehennasCurseApplied", 19716)
	self:Log("SPELL_AURA_REMOVED", "GehennasCurseRemoved", 19716)
	self:Log("SPELL_AURA_APPLIED", "RainOfFireDamage", 19717)
	self:Log("SPELL_PERIODIC_DAMAGE", "RainOfFireDamage", 19717)
	self:Log("SPELL_PERIODIC_MISSED", "RainOfFireDamage", 19717)
	if self:GetSeason() == 2 then
		self:Log("SPELL_CAST_SUCCESS", "GehennasCurse", 461232)
		self:Log("SPELL_AURA_APPLIED", "GehennasCurseApplied", 461232)
		self:Log("SPELL_AURA_REMOVED", "GehennasCurseRemoved", 461232)
	end
end

function mod:OnEngage()
	curseCount = 0
	curseTime = 0
	self:CDBar(19716, 6, CL.curse) -- Gehennas' Curse
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:GehennasCurse(args)
	curseTime = args.time
	self:CDBar(19716, 27, CL.curse) -- 27-37
	self:Message(19716, "orange", CL.curse)
end

function mod:GehennasCurseApplied(args)
	if self:Player(args.destFlags) then -- Players, not pets
		curseCount = curseCount + 1
	end
end

function mod:GehennasCurseRemoved(args)
	if self:Player(args.destFlags) then -- Players, not pets
		curseCount = curseCount - 1
		if curseCount == 0 then
			self:Message(19716, "green", CL.removed_after:format(CL.curse, args.time-curseTime))
		end
	end
end

do
	local prev = 0
	function mod:RainOfFireDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "aboveyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
