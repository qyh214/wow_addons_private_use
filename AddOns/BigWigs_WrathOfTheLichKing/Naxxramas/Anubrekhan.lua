--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Anub'Rekhan", 533, 1601)
if not mod then return end
mod:RegisterEnableMob(15956)
mod:SetEncounterID(1107)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.add = "Crypt Guard"
	L.add_icon = "inv_misc_ahnqirajtrinket_02"

	L.locust = "Locust"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"add",
		28783, -- Impale
		28785, -- Locust Swarm
		"berserk",
	}, nil, {
		["add"] = CL.big_add, -- Crypt Guard (Big Add)
		[28785] = L.locust, -- Locust Swarm (Locust)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Impale", 28783, 56090)
	self:Log("SPELL_CAST_START", "LocustSwarm", 28785, 54021)
	self:Log("SPELL_AURA_APPLIED", "LocustSwarmApplied", 28785, 54021)
	self:Log("SPELL_AURA_REMOVED", "LocustSwarmRemoved", 28785, 54021)

	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
end

function mod:OnEngage(diff)
	self:Berserk(600, true)

	local locustTime = diff == 3 and 102 or 92
	self:Message(28785, "yellow", CL.custom_start_s:format(self.displayName, self:SpellName(28785), locustTime), false)
	self:DelayedMessage(28785, locustTime - 10, "red", CL.soon:format(self:SpellName(28785)), nil, "alarm")
	self:CDBar(28785, locustTime) -- Locust Swarm
	if diff == 3 then
		self:Bar("add", 16, CL.big_add, L.add_icon)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg, sender)
	if sender == L.add then
		self:Message("add", "purple", CL.spawned:format(CL.big_add), L.add_icon)
		if self:Tank() then
			self:PlaySound("add", "warning")
		end
	end
end

function mod:Impale(args)
	self:Message(28783, "orange")
	self:PlaySound(28783, "alert")
	-- self:CDBar(28783, 10) -- 10~35s z.z
end

function mod:LocustSwarm(args)
	self:StopBar(28785)
	self:Message(28785, "yellow")
	self:PlaySound(28785, "long")
	self:Bar(28785, 3, CL.incoming:format(L.locust))
end

function mod:LocustSwarmApplied(args)
	if self:MobId(args.destGUID) == 15956 then
		self:Bar(28785, args.spellId == 28785 and 16 or 20, CL.over:format(L.locust))
		self:CDBar(28785, 92) -- 92~104s in 25n
		self:DelayedMessage(28785, 82, "red", CL.soon:format(args.spellName), nil, "alarm")
	end
end

function mod:LocustSwarmRemoved(args)
	if self:MobId(args.destGUID) == 15956 then
		self:Message(28785, "green", CL.over:format(args.spellName))
		self:PlaySound(28785, "info")
	end
end
