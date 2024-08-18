--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Shazzrah", 409, 1523)
if not mod then return end
mod:RegisterEnableMob(12264, 228434) -- Shazzrah, Shazzrah (Season of Discovery)
mod:SetEncounterID(667)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		19714, -- Magic Grounding / Deaden Magic (different name on classic era)
		23138, -- Gate of Shazzrah
		19715, -- Counterspell
		19713, -- Shazzrah's Curse
	},nil,{
		[23138] = CL.teleport, -- Gate of Shazzrah (Teleport)
		[19715] = CL.frontal_cone, -- Counterspell (Frontal Cone)
		[19713] = CL.curse, -- Shazzrah's Curse (Curse)
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			19714, -- Deaden Magic
			23138, -- Gate of Shazzrah
			19715, -- Counterspell
			19713, -- Shazzrah's Curse
			{460856, "CASTBAR", "EMPHASIZE"}, -- Reflect Magic
		},nil,{
			[23138] = CL.teleport, -- Gate of Shazzrah (Teleport)
			[19715] = CL.frontal_cone, -- Counterspell (Frontal Cone)
			[19713] = CL.curse, -- Shazzrah's Curse (Curse)
		}
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "GateOfShazzrah", 23138)
	self:Log("SPELL_AURA_APPLIED", "MagicGroundingDeadenMagicApplied", 19714) -- Normal, Level 1 & 2
	self:Log("SPELL_DISPEL", "MagicGroundingDeadenMagicDispelled", "*") -- Normal, Level 1 & 2
	self:Log("SPELL_CAST_SUCCESS", "Counterspell", 19715)
	self:Log("SPELL_CAST_SUCCESS", "ShazzrahsCurse", 19713) -- Normal, Level 1
	if self:GetSeason() == 2 then
		self:Log("SPELL_CAST_SUCCESS", "ShazzrahsCurse", 461343) -- Level 2 & 3
		self:Log("SPELL_CAST_START", "ReflectMagic", 460856) -- Level 3
		self:Log("SPELL_AURA_APPLIED", "ReflectMagicApplied", 460856) -- Level 3
		self:Log("SPELL_AURA_REMOVED", "ReflectMagicRemoved", 460856) -- Level 3
	end
end

function mod:OnEngage()
	self:CDBar(19713, 6.4, CL.curse) -- Shazzrah's Curse
	self:CDBar(19715, 9.7) -- Counterspell
	self:CDBar(23138, self:GetSeason() == 2 and 21 or 30, CL.teleport) -- Gate of Shazzrah
	if self:GetPlayerAura(458842) or self:GetPlayerAura(458843) then -- Level 2 & 3 only
		self:CDBar(460856, 16) -- Reflect Magic
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:GateOfShazzrah()
	self:CDBar(23138, self:GetSeason() == 2 and 21 or 41, CL.teleport) -- 21-30 on SoD, 41-50 elsewhere
	self:Message(23138, "red", CL.teleport)
	self:PlaySound(23138, "long")
end

function mod:MagicGroundingDeadenMagicApplied(args)
	self:Message(args.spellId, "orange", CL.magic_buff_boss:format(args.spellName))
	if self:Dispeller("magic", true) then
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:MagicGroundingDeadenMagicDispelled(args)
	if args.extraSpellName == self:SpellName(19714) then
		self:Message(19714, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:Counterspell(args)
	self:CDBar(args.spellId, self:GetSeason() == 2 and 9.6 or 15) -- 9.6-12.9 on SoD, 15-19 elsewhere
	self:Message(args.spellId, "yellow", CL.extra:format(args.spellName, CL.frontal_cone))
	self:PlaySound(args.spellId, "alert")
end

function mod:ShazzrahsCurse()
	self:CDBar(19713, self:GetSeason() == 2 and 16.2 or 22.6, CL.curse) -- 16.2-21 on SoD, 22.6-25 elsewhere
	self:Message(19713, "yellow", CL.curse)
	if self:Dispeller("curse") then
		self:PlaySound(19713, "alarm")
	end
end

function mod:ReflectMagic(args)
	self:StopBar(args.spellName)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "warning")
end

do
	local prev = 0
	function mod:ReflectMagicApplied(args)
		prev = args.time
		self:CastBar(args.spellId, 5)
	end

	function mod:ReflectMagicRemoved(args)
		self:StopBar(CL.cast:format(args.spellName))
		self:Message(args.spellId, "green", CL.over:format(args.spellName), nil, true) -- Disable emphasize
		self:CDBar(args.spellId, prev > 0 and (21.6 - (args.time-prev)) or 16.6) -- Show the bar after it ends
		self:PlaySound(args.spellId, "info")
	end
end
