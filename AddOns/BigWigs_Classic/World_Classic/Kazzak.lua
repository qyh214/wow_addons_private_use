--------------------------------------------------------------------------------
-- Module Declaration
--

if BigWigsLoader.isSeasonOfDiscovery then return end
local mod, CL = BigWigs:NewBoss("Lord Kazzak", -1419)
if not mod then return end
mod:RegisterEnableMob(12397)
mod:SetAllowWin(true)
mod.otherMenu = -947
mod.worldBoss = 12397

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Lord Kazzak"

	L.engage_trigger = "For the Legion! For Kil'Jaeden!"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		21056, -- Mark of Kazzak
		21063, -- Twisted Reflection
		"berserk",
	},nil,{
		[21056] = CL.curse, -- Mark of Kazzak (Curse)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "MarkOfKazzakApplied", 21056)
	self:Log("SPELL_AURA_APPLIED", "TwistedReflectionApplied", 21063)

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:Death("Win", 12397)
end

function mod:OnEngage()
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Berserk(180)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MarkOfKazzakApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.curse)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	elseif self:Dispeller("curse") then
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:TwistedReflectionApplied(args)
	self:TargetMessage(args.spellId, "orange", args.destName)
	if self:Dispeller("magic") then
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.engage_trigger, nil, true) then
		if self:IsEngaged() then
			self:Wipe()
		end
		self:Engage()
	end
end
