--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Baron Aquanis Discovery", 48)
if not mod then return end
mod:RegisterEnableMob(202699) -- Baron Aquanis Season of Discovery
mod:SetEncounterID(2694)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local depthChargeCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Baron Aquanis"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{404806, "ICON", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Depth Charge
		{413664, "CASTBAR"}, -- Bubble Beam
		405953, -- Torrential Downpour
	},nil,{
		[404806] = CL.bomb, -- Depth Charge (Bomb)
		[413664] = CL.beam, -- Bubble Beam (Beam)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "DepthCharge", 404806)
	self:Log("SPELL_AURA_APPLIED", "DepthChargeApplied", 404806)
	self:Log("SPELL_AURA_REMOVED", "DepthChargeRemoved", 404806)
	self:Log("SPELL_CAST_SUCCESS", "BubbleBeam", 413664)
	self:Log("SPELL_AURA_APPLIED", "BubbleBeamChannel", 404373)
	self:Log("SPELL_AURA_REMOVED", "BubbleBeamChannelOver", 404373)

	self:Log("SPELL_AURA_APPLIED", "TorrentialDownpourDamage", 405953)
	self:Log("SPELL_PERIODIC_DAMAGE", "TorrentialDownpourDamage", 405953)
	self:Log("SPELL_PERIODIC_MISSED", "TorrentialDownpourDamage", 405953)
end

function mod:OnEngage()
	depthChargeCount = 1
	self:CDBar(404806, 16, CL.bomb) -- Depth Charge
	self:CDBar(413664, 26, CL.beam) -- Bubble Beam
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DepthCharge(args)
	depthChargeCount = depthChargeCount + 1
	self:CDBar(args.spellId, depthChargeCount % 2 == 0 and 22 or 16, CL.bomb)
end

function mod:DepthChargeApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.bomb)
	self:TargetBar(args.spellId, 8, args.destName, CL.bomb)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, CL.bomb, nil, "Bomb")
		self:SayCountdown(args.spellId, 8)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:DepthChargeRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
	self:StopBar(CL.bomb, args.destName)
	self:PrimaryIcon(args.spellId)
end

function mod:BubbleBeam(args)
	self:StopBar(CL.beam) -- Stop the CDBar
	self:Message(args.spellId, "orange", CL.incoming:format(CL.beam))
	self:PlaySound(args.spellId, "long")
end

function mod:BubbleBeamChannel()
	self:CastBar(413664, 10, CL.beam)
	self:CDBar(404806, {11, 16}, CL.bomb) -- Depth Charge
end

function mod:BubbleBeamChannelOver()
	self:CDBar(413664, 27, CL.beam)
end

do
	local prev = 0
	function mod:TorrentialDownpourDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "aboveyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
