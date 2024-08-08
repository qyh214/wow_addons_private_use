--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Instructor Razuvious", 533, 1607)
if not mod then return end
mod:RegisterEnableMob(16061, 16803) -- Instructor Razuvious, Deathknight Understudy
mod:SetEncounterID(1113)

--------------------------------------------------------------------------------
-- Locals
--

local understudyIcons = {}
local mindExhaustionList = {}
local mindExhaustionDebuffTime = {}
local UpdateInfoBoxList

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.understudy = "Deathknight Understudy"

	L["29107_icon"] = "ability_warrior_battleshout"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		29107, -- Disrupting Shout
		29060, -- Taunt
		29061, -- Shield Wall
		{29051, "INFOBOX"}, -- Mind Exhaustion
	}, {
		[29060] = L.understudy,
	}
end

function mod:VerifyEnable(unit, mobId)
	if mobId == 16061 then
		return true
	elseif mobId == 16803 then
		return self:GetHealth(unit) == 100
	end
end

function mod:OnBossEnable()
	understudyIcons = {}
	mindExhaustionList = {}
	mindExhaustionDebuffTime = {}

	self:Log("SPELL_CAST_SUCCESS", "DisruptingShout", 29107)
	self:Log("SPELL_CAST_SUCCESS", "Taunt", 29060)
	self:Log("SPELL_AURA_APPLIED", "TauntApplied", 29060)
	self:Log("SPELL_AURA_REMOVED", "TauntRemoved", 29060)
	self:Log("SPELL_CAST_SUCCESS", "ShieldWall", 29061)
	--self:Log("SPELL_AURA_APPLIED", "MindExhaustion", 29051) -- Hidden

	self:Log("SPELL_AURA_APPLIED", "MindControl", 10912)
	self:Death("UnderstudyKilled", 16803) -- Deathknight Understudy
end

function mod:OnEngage()
	-- Mind Control can happen before engage, so we don't reset any locals
	self:CDBar(29107, 25, self:SpellName(29107), L["29107_icon"]) -- Disrupting Shout
	self:DelayedMessage(29107, 20, "red", CL.soon:format(self:SpellName(29107)))

	self:OpenInfo(29051, "BigWigs")
	self:SetInfo(29051, 1, "|T136222:0:0:0:0:64:64:4:60:4:60|t".. self:SpellName(29051))
	self:SimpleTimer(UpdateInfoBoxList, 0.1)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DisruptingShout(args)
	self:Message(args.spellId, "red", args.spellName, L["29107_icon"])
	self:CDBar(args.spellId, 25, args.spellName, L["29107_icon"])
	self:DelayedMessage(args.spellId, 20, "red", CL.soon:format(args.spellName))
	self:PlaySound(args.spellId, "warning")
end

function mod:Taunt(args)
	local icon = understudyIcons[args.sourceGUID]
	if icon then
		local msg = icon .. args.spellName
		self:Message(args.spellId, "orange", msg)
		self:Bar(args.spellId, 60, msg)
	else
		self:Message(args.spellId, "orange")
		self:Bar(args.spellId, 60)
	end
	self:PlaySound(args.spellId, "info")
end

do
	local prevTaunt = nil
	function mod:TauntApplied(args)
		prevTaunt = args.sourceGUID
		self:Bar(args.spellId, 20, CL.on:format(args.spellName, CL.boss))
	end

	function mod:TauntRemoved(args)
		if prevTaunt == args.sourceGUID then
			self:StopBar(CL.on:format(args.spellName, CL.boss))
			self:Message(args.spellId, "orange", CL.over:format(args.spellName))
		end
	end
end

function mod:ShieldWall(args)
	if self:MobId(args.sourceGUID) == 16803 then -- Shared with 4 horsemen
		local icon = understudyIcons[args.sourceGUID]
		if icon then
			local msg = icon .. args.spellName
			self:Message(args.spellId, "yellow", msg)
			self:Bar(args.spellId, 20, msg)
		else
			self:Message(args.spellId, "yellow")
			self:Bar(args.spellId, 20)
		end
		self:PlaySound(args.spellId, "long")
	end
end

--function mod:MindExhaustion(args)
--	local icon = understudyIcons[args.destGUID]
--	if icon then
--		-- Not much of a point if they aren't marked
--		self:Bar(args.spellId, 60, icon .. args.spellName)
--	end
--end

function mod:MindControl(args)
	if self:MobId(args.destGUID) == 16803 then -- Only when mind controlling an understudy
		self:DeleteFromTable(mindExhaustionList, args.destGUID)
		local icon = self:GetIconTexture(self:GetIcon(args.destRaidFlags))
		if icon then
			mindExhaustionList[#mindExhaustionList + 1] = args.destGUID
			mindExhaustionDebuffTime[args.destGUID] = GetTime() + 60
			understudyIcons[args.destGUID] = icon
		else
			understudyIcons[args.destGUID] = nil
		end
	end
end

function mod:UnderstudyKilled(args)
	mindExhaustionDebuffTime[args.destGUID] = -1
	local icon = understudyIcons[args.destGUID]
	if icon then
		self:StopBar(icon .. self:SpellName(29060)) -- Taunt
		self:StopBar(icon .. self:SpellName(29061)) -- Shield Wall
	else
		self:StopBar(29060) -- Taunt
		self:StopBar(29061) -- Shield Wall
	end
end

function UpdateInfoBoxList()
	if not mod:IsEngaged() then return end
	mod:SimpleTimer(UpdateInfoBoxList, 0.1)

	local t = GetTime()
	local line = 3
	for i = 1, 5 do
		local npcGUID = mindExhaustionList[i]
		if npcGUID then
			local remaining = (mindExhaustionDebuffTime[npcGUID] or 0) - t
			mod:SetInfo(29051, line, understudyIcons[npcGUID])
			if remaining > 0 then
				mod:SetInfo(29051, line + 1, CL.seconds:format(remaining))
				mod:SetInfoBar(29051, line, remaining / 60)
			else
				if mindExhaustionDebuffTime[npcGUID] == -1 then
					mod:SetInfo(29051, line + 1, CL.dead, 1, 0.2, 0.2)
				else
					mod:SetInfo(29051, line + 1, CL.ready, 0.13, 1, 0.13)
				end
				mod:SetInfoBar(29051, line, 0)
			end
		else
			mod:SetInfo(29051, line, "")
			mod:SetInfo(29051, line + 1, "")
			mod:SetInfoBar(29051, line, 0)
		end
		line = line + 2
	end
end
