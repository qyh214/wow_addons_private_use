--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Sha of Anger", -379, 691)
if not mod then return end
mod:RegisterEnableMob(60491)
mod.otherMenu = -424
mod.worldBoss = 60491

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{119622, "ME_ONLY_EMPHASIZE"}, -- Growing Anger
		{119626, "COUNTDOWN"}, -- Aggressive Behavior
		119488, -- Unleashed Wrath
		119610, -- Bitter Thoughts
	},nil,{
		[119626] = CL.mind_control, -- Aggressive Behavior (Mind Control)
	}
end

function mod:OnBossEnable()
	self:ScheduleTimer("CheckForEngage", 1)
	self:Death("Win", 60491)
end

function mod:OnEngage()
	self:CheckForWipe()

	-- World bosses will wipe but keep listening to events if you fly away, so we only register OnEngage
	self:Log("SPELL_CAST_START", "UnleashedWrath", 119488)
	self:Log("SPELL_AURA_APPLIED", "GrowingAngerApplied", 119622)
	self:Log("SPELL_AURA_APPLIED", "AggressiveBehavior", 119626)

	-- Bitter Thoughts is hidden
	self:ScheduleRepeatingTimer("BitterThoughts", 0.5)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UnleashedWrath(args)
	self:Message(args.spellId, "yellow", CL.on_group:format(args.spellName))
	self:CDBar(args.spellId, 25)
end

do
	local prev = 0
	function mod:BitterThoughts()
		local auraTbl = self:GetPlayerAura(119610) -- Bitter Thoughts
		if auraTbl then
			local t = GetTime()
			if t-prev > 2 then -- throttle so the timer can catch it sooner
				prev = t
				self:PersonalMessage(119610, "underyou", auraTbl.name)
				self:PlaySound(119610, "underyou")
			end
		end
	end
end

do
	local prev = 0
	function mod:GrowingAngerApplied(args)
		if args.time-prev > 6 then
			prev = args.time
			self:Bar(119626, 6, CL.mind_control)
		end
		if self:Me(args.destGUID) then
			self:PersonalMessage(args.spellId, nil, CL.mind_control_short)
			self:PlaySound(args.spellId, "warning")
		end
	end
end

do
	local playerList = {}
	local prev = 0
	function mod:AggressiveBehavior(args)
		if args.time-prev > 6 then
			prev = args.time
			playerList = {}
		end
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(args.spellId, "red", playerList, nil, CL.mind_control)
	end
end
