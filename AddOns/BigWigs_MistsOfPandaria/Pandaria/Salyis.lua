--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Salyis's Warband", -376, 725)
if not mod then return end
mod:RegisterEnableMob(62346)
mod.otherMenu = -424
mod.worldBoss = 62346

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.adds_icon = "inv_weapon_halberd_12"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		121600, -- Cannon Barrage
		121787, -- Stomp
		"adds",
	}
end

function mod:OnBossEnable()
	self:ScheduleTimer("CheckForEngage", 1)
	self:Death("Win", 62346) -- Galleon
end

function mod:OnEngage()
	self:CheckForWipe()

	-- World bosses will wipe but keep listening to events if you fly away, so we only register OnEngage
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")

	self:CDBar(121600, 23) -- Cannon Barrage
	self:CDBar(121787, 50) -- Stomp
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function AddsArrived()
		mod:Message("adds", "cyan", CL.adds, L.adds_icon)
		mod:PlaySound("adds", "info")
	end
	function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
		if msg:find("spell:121600", nil, true) then
			self:Message(121600, "orange", CL.incoming:format(self:SpellName(121600)))
			self:CDBar(121600, 60)
			self:PlaySound(121600, "long")
		elseif msg:find("spell:121787", nil, true) then
			self:Message(121787, "red", CL.incoming:format(self:SpellName(121787)))
			self:CDBar(121787, 60)
			self:Bar("adds", 10, CL.adds, L.adds_icon) -- Adds
			self:ScheduleTimer(AddsArrived, 10)
			self:PlaySound(121787, "alarm")
		end
	end
end
