--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Buru the Gorger", 509, 1540)
if not mod then return end
mod:RegisterEnableMob(15370)
mod:SetEncounterID(721)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.fixate = CL.fixate
	L.fixate_desc = "Fixate on a target, ignoring threat from other attackers."
	L.fixate_icon = "ability_hunter_snipershot"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		{"fixate", "ICON", "SAY", "ME_ONLY_EMPHASIZE"},
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:Log("SPELL_AURA_REMOVED", "ThornsRemoved", 25640)
end

function mod:OnEngage()
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_EMOTE(_, _, sender, _, _, player)
	if sender == mod.displayName then
		self:TargetMessage("fixate", "yellow", player, CL.fixate, L.fixate_icon)
		self:SecondaryIcon("fixate", player) -- Secondary, since skull often used for egg targets
		local guid = self:UnitGUID(player)
		if self:Me(guid) then
			self:Say("fixate", CL.fixate, nil, "Fixate")
			self:PlaySound("fixate", "warning", nil, player)
		end
	end
end

function mod:ThornsRemoved()
	self:SetStage(2)
	self:Message("stages", "cyan", CL.percent:format(20, CL.stage:format(2)), false)
	self:SecondaryIcon("fixate")
	self:PlaySound("stages", "long")
end
