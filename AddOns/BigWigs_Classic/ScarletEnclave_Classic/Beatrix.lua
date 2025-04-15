--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("High Commander Beatrix", 2856)
if not mod then return end
mod:RegisterEnableMob(240812)
mod:SetEncounterID(3187)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "High Commander Beatrix"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		"berserk",
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()

end

function mod:OnEngage()
	--self:Message("stages", "cyan", CL.stage:format(1), false)
	self:Bar("stages", 120, CL.stage:format(2), "ability_mount_charger")
	self:Berserk(420)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

