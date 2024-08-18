--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Magmadar", 409, 1520)
if not mod then return end
mod:RegisterEnableMob(11982, 228430) -- Magmadar, Magmadar (Season of Discovery)
mod:SetEncounterID(664)

--------------------------------------------------------------------------------
-- Locals
--

local castCollector = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L["19408_icon"] = "spell_shadow_psychicscream"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		19408, -- Panic
		19451, -- Enrage / Frenzy (different name on classic era)
		19428, -- Conflagration
	},nil,{
		[19408] = CL.fear, -- Panic (Fear)
		[19428] = CL.underyou:format(CL.fire), -- Conflagration (Fire under YOU)
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			19408, -- Panic
			19451, -- Enrage / Frenzy (different name on classic era)
			19428, -- Conflagration
			461131, -- Summon Core Hound
		},nil,{
			[19408] = CL.fear, -- Panic (Fear)
			[19428] = CL.underyou:format(CL.fire), -- Conflagration (Fire under YOU)
		}
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Panic", 19408)
	self:Log("SPELL_AURA_APPLIED", "EnrageFrenzy", 19451)
	self:Log("SPELL_DISPEL", "EnrageFrenzyDispelled", "*")
	self:Log("SPELL_AURA_APPLIED", "ConflagrationApplied", 19428)
	self:Log("SPELL_AURA_REFRESH", "ConflagrationApplied", 19428)
	if self:GetSeason() == 2 then
		self:Log("SPELL_CAST_SUCCESS", "Panic", 461125)
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		self:RegisterMessage("BigWigs_BossComm")
	end
end

function mod:OnEngage()
	castCollector = {}
	self:CDBar(19451, 8.1) -- Enrage / Frenzy
	self:CDBar(19408, 9.7, CL.fear, L["19408_icon"]) -- Panic
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castGUID, spellId)
	if (spellId == 461131 or spellId == 364727) and not castCollector[castGUID] then -- Summon Core Hound (Level 2+3, 1)
		castCollector[castGUID] = true
		self:Sync("sum")
	end
end

do
	local times = {
		["sum"] = 0,
	}
	function mod:BigWigs_BossComm(_, msg)
		if times[msg] then
			local t = GetTime()
			if t-times[msg] > 5 then
				times[msg] = t
				if msg == "sum" then
					self:Message(461131, "cyan", self:SpellName(461131), false)
					self:PlaySound(461131, "alert")
				end
			end
		end
	end
end

function mod:Panic()
	self:CDBar(19408, 31, CL.fear, L["19408_icon"]) -- 31-50, sometimes even higher
	self:Message(19408, "orange", CL.fear, L["19408_icon"])
	self:PlaySound(19408, "long")
end

function mod:EnrageFrenzy(args)
	self:TargetBar(args.spellId, 8, args.destName)
	self:CDBar(args.spellId, 18) -- 18-21
	self:Message(args.spellId, "yellow", CL.buff_boss:format(args.spellName))
	self:PlaySound(args.spellId, "info")
end

function mod:EnrageFrenzyDispelled(args)
	if args.extraSpellName == self:SpellName(19451) then
		self:StopBar(args.extraSpellName, args.destName)
		self:Message(19451, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:ConflagrationApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, "underyou", CL.fire)
		self:PlaySound(args.spellId, "underyou")
	end
end
