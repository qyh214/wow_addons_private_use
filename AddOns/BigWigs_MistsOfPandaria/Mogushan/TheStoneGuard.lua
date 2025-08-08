--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Stone Guard", 1008, 679)
if not mod then return end
mod:RegisterEnableMob(60051, 60047, 60043, 59915) -- Cobalt Guardian, Amethyst Guardian, Jade Guardian, Jasper Guardian
mod:SetEncounterID(1395)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local cobaltTimer = 10.7
local cobaltCount = 1
local prevTiles = 0
local currentPetri = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L[60051] = "|T134398:0|t Cobalt" -- Cobalt Guardian
	L[60047] = "|T134399:0|t Amethyst" -- Amethyst Guardian
	L[60043] = "|T134397:0|t Jade" -- Jade Guardian
	L[59915] = "|T134396:0|t Jasper" -- Jasper Guardian

	L["129424_desc"] = -5772 -- Add proper description to Cobalt Mine

	L.custom_on_linked_spam = CL.link_say_option_name
	L.custom_on_linked_spam_desc = CL.link_say_option_desc
	L.custom_on_linked_spam_icon = mod:GetMenuIcon("SAY")
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		116529, -- Power Down
		115852, -- Cobalt Petrification
		129424, -- Cobalt Mine
		116057, -- Amethyst Petrification
		130774, -- Amethyst Pool
		116006, -- Jade Petrification
		116036, -- Jasper Petrification
		{130395, "SAY", "ME_ONLY_EMPHASIZE"}, -- Jasper Chains
		"custom_on_linked_spam",
		{"energy", "INFOBOX"},
		"berserk",
	},{
		[116529] = "heroic",
		[115852] = -5771, -- Cobalt Guardian
		[116057] = -5691, -- Amethyst Guardian
		[116006] = -5773, -- Jade Guardian
		[116036] = -5774, -- Jasper Guardian
		energy = "general",
	},{
		[130395] = CL.link, -- Jasper Chains (Link)
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "Petrifications", "boss1", "boss2", "boss3", "boss4")
	self:Log("SPELL_CAST_SUCCESS", "JasperChains", 130395)
	self:Log("SPELL_AURA_APPLIED", "JasperChainsApplied", 130395)
	self:Log("SPELL_AURA_REMOVED", "JasperChainsRemoved", 130395)
	self:Log("SPELL_AURA_APPLIED", "AmethystPoolDamage", 130774)
	self:Log("SPELL_PERIODIC_DAMAGE", "AmethystPoolDamage", 130774)
	self:Log("SPELL_PERIODIC_MISSED", "AmethystPoolDamage", 130774)
	self:Log("SPELL_AURA_APPLIED", "EnergizedTilesApplied", 116541)
	self:Log("SPELL_AURA_APPLIED_DOSE", "EnergizedTilesApplied", 116541)
	self:RegisterUnitEvent("UNIT_POWER_UPDATE", nil, "boss1", "boss2", "boss3", "boss4")
end

function mod:OnEngage()
	prevTiles = 0
	cobaltCount = 1
	currentPetri = 0
	self:OpenInfo("energy", CL.other:format("BigWigs", CL.energy))

	local diff = self:Difficulty()
	cobaltTimer = (diff == 3 or diff == 5) and 8.4 or 10.7
	self:Berserk(self:Heroic() and 420 or 480)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg, boss, _, _, destName)
	if msg:find("spell:116529", nil, true) then -- Power Down
		prevTiles = 0
		self:SetInfo("energy", 10, "")
		self:Message(116529, "orange", CL.other:format(self:SpellName(116529), boss))
		self:PlaySound(116529, "info")
	end
end

do
	local prevLinkName, prevLinkGUID, mySaySpamTarget = nil, nil, nil
	function mod:JasperChains(args)
		prevLinkName, prevLinkGUID, mySaySpamTarget = nil, nil, nil
		self:Bar(args.spellId, 19.4, CL.link)
	end

	local function RepeatLinkSay()
		if not mod:IsEngaged() or not mySaySpamTarget then return end
		mod:SimpleTimer(RepeatLinkSay, 5)
		mod:Say(false, CL.link_with:format(mySaySpamTarget), true, ("Linked with %s"):format(mySaySpamTarget))
	end

	function mod:JasperChainsApplied(args)
		if not prevLinkGUID then
			prevLinkName, prevLinkGUID = args.destName, args.destGUID
		elseif prevLinkGUID then
			if self:Me(args.destGUID) then
				mySaySpamTarget = prevLinkName
				if self:GetOption("custom_on_linked_spam") then
					self:SimpleTimer(RepeatLinkSay, 5)
				end
				local msg = CL.link_with:format(prevLinkName)
				self:PersonalMessage(args.spellId, false, msg)
				self:Say(args.spellId, msg, true, ("Linked with %s"):format(prevLinkName))
				self:PlaySound(args.spellId, "warning", nil, args.destName)
			elseif self:Me(prevLinkGUID) then
				mySaySpamTarget = args.destName
				if self:GetOption("custom_on_linked_spam") then
					self:SimpleTimer(RepeatLinkSay, 5)
				end
				local msg = CL.link_with:format(args.destName)
				self:PersonalMessage(args.spellId, false, msg)
				self:Say(args.spellId, msg, true, ("Linked with %s"):format(args.destName))
				self:PlaySound(args.spellId, "warning", nil, prevLinkName)
			else
				self:Message(args.spellId, "yellow", CL.link_both:format(self:ColorName(prevLinkName), self:ColorName(args.destName)))
			end
		end
	end

	function mod:JasperChainsRemoved(args)
		if self:Me(args.destGUID) then
			mySaySpamTarget = nil
			self:Say(args.spellId, CL.link_removed, true, "Link removed")
		end
	end
end

do
	local prev = 0
	function mod:AmethystPoolDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:Petrifications(_, _, _, spellId)
	if spellId == 115852 then -- Cobalt Petrification
		currentPetri = 60051
		self:Message(115852, "cyan")
		self:PlaySound(115852, "alert")
	elseif spellId == 116006 then -- Jade Petrification
		currentPetri = 60043
		self:Message(116006, "cyan")
		self:PlaySound(116006, "alert")
	elseif spellId == 116036 then -- Jasper Petrification
		currentPetri = 59915
		self:Message(116036, "cyan")
		self:PlaySound(116036, "alert")
	elseif spellId == 116057 then -- Amethyst Petrification
		currentPetri = 60047
		self:Message(116057, "cyan")
		self:PlaySound(116057, "alert")
	elseif spellId == 129424 then -- Cobalt Mine
		self:StopBar(CL.count:format(self:SpellName(spellId), cobaltCount))
		cobaltCount = cobaltCount + 1
		self:CDBar(129424, cobaltTimer, CL.count:format(self:SpellName(spellId), cobaltCount))
	end
end

function mod:EnergizedTilesApplied(args)
	local amount = args.amount or 1
	if amount > prevTiles then
		prevTiles = amount
		if amount == 1 then
			self:SetInfo("energy", 9, ("|T134457:0|t %s"):format(args.spellName))
		end
		self:SetInfo("energy", 10, amount)
	end
end

do
	local bossList = {
		["boss1"] = 1,
		["boss2"] = 3,
		["boss3"] = 5,
		["boss4"] = 7,
	}
	local icons = {
		[60051] = 115852, -- Cobalt Guardian
		[60047] = 116057, -- Amethyst Guardian
		[60043] = 116006, -- Jade Guardian
		[59915] = 116036, -- Jasper Guardian
	}
	local prevPower = {
		["boss1"] = 0,
		["boss2"] = 0,
		["boss3"] = 0,
		["boss4"] = 0,
	}
	local prevSound = 0

	function mod:UNIT_POWER_UPDATE(_, unit)
		local power = UnitPower(unit)
		local prevPowerForUnit = prevPower[unit]
		if power ~= prevPowerForUnit then
			prevPower[unit] = power
			local npcID = self:MobId(self:UnitGUID(unit))
			local name = L[npcID] or "??"
			self:SetInfo("energy", bossList[unit], name)
			self:SetInfo("energy", bossList[unit]+1, power)
			if power >= 80 then
				if npcID == currentPetri then
					self:SetInfoBar("energy", bossList[unit], power/100, 0.5, 0, 1, 1) -- Always purple for petrified one
				else
					self:SetInfoBar("energy", bossList[unit], power/100, 1, 0, 0, 1) -- Red for danger level
				end
				if prevPowerForUnit < 80 then
					self:Message("energy", "red", CL.other:format(self:UnitName(unit), CL.energy_percent:format(power)), icons[npcID] or false)
					local t = GetTime()
					if t-prevSound > 5 then
						prevSound = t
						self:PlaySound("energy", "long")
					end
				end
			else
				if npcID == currentPetri then
					self:SetInfoBar("energy", bossList[unit], power/100, 0.5, 0, 1, 1) -- Always purple for petrified one
				else
					self:SetInfoBar("energy", bossList[unit], power/100)
				end
			end
		end
	end
end
