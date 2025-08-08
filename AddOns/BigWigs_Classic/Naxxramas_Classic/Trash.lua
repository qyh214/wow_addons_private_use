--------------------------------------------------------------------------------
-- Module Declaration
--

if not BigWigsLoader.isSeasonOfDiscovery then return end
local mod, CL = BigWigs:NewBoss("Naxxramas Trash", 533)
if not mod then return end
mod.displayName = CL.trash
mod:RegisterEnableMob(16028, 15931, 15932, 15928, 15929, 15930) -- Patchwerk, Grobbulus, Gluth, Thaddius, Stalagg, Feugen

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{1219235, "ME_ONLY", "ME_ONLY_EMPHASIZE", "SAY", "SAY_COUNTDOWN"}, -- Overcharged
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "OverchargedApplied", 1219235)
	self:Log("SPELL_AURA_REMOVED", "OverchargedRemoved", 1219235)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function PrintSay()
		mod:Say(1219235, nil, nil, "Overcharged")
	end

	local timer1, timer2 = nil, nil
	function mod:OverchargedApplied(args)
		self:TargetMessage(args.spellId, "yellow", args.destName)
		self:TargetBar(args.spellId, 30, args.destName)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, nil, nil, "Overcharged")
			self:SayCountdown(args.spellId, 30, nil, 5)
			timer1 = self:ScheduleTimer(PrintSay, 10)
			timer2 = self:ScheduleTimer(PrintSay, 20)
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end

	function mod:OverchargedRemoved(args)
		self:StopBar(args.spellName, args.destName)
		if self:Me(args.destGUID) then
			self:CancelSayCountdown(args.spellId)
			if timer1 then
				self:CancelTimer(timer1)
				timer1 = nil
			end
			if timer2 then
				self:CancelTimer(timer2)
				timer2 = nil
			end
		end
	end
end
