--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Thaddius", 533, 1613)
if not mod then return end
mod:RegisterEnableMob(15928, 15929, 15930) -- Thaddius, Stalagg, Feugen
mod:SetEncounterID(1120)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local UpdateInfoBoxList
local printed = false
local deaths = 0
local firstCharge = true

local EXTRAS_PATH = "Interface\\AddOns\\BigWigs_WrathOfTheLichKing\\Naxxramas\\Extras"

local ICON_POSITIVE = "Spell_ChargePositive" -- 135769
local ICON_NEGATIVE = "Spell_ChargeNegative" -- 135768

local DIRECTION_SOUND = {}
do
	local locale = GetLocale()
	if locale == "zhTW" then locale = "zhCN" end
	local locales = {
		deDE = true,
		koKR = true,
		zhCN = true,
	}
	if not locales[locale] then
		locale = "enUS"
	end

	-- PlaySoundFile("Interface\\AddOns\\BigWigs_WrathOfTheLichKing\\Naxxramas\\Extras\\Thaddius-enUS-Stay.ogg", "Master")
	DIRECTION_SOUND.left = ("%s\\Thaddius-%s-Left.ogg"):format(EXTRAS_PATH, locale)
	DIRECTION_SOUND.right = ("%s\\Thaddius-%s-Right.ogg"):format(EXTRAS_PATH, locale)
	DIRECTION_SOUND.swap = ("%s\\Thaddius-%s-Swap.ogg"):format(EXTRAS_PATH, locale)
	DIRECTION_SOUND.stay = ("%s\\Thaddius-%s-Stay.ogg"):format(EXTRAS_PATH, locale)
end

local DIRECTION_ARROW = {
	left = function()
		local frame = mod.arrow
		frame.texture:SetRotation(0)
		frame.texture:SetTexCoord(0, 1, 0, 1)
		frame:SetPoint("CENTER", -250, 100)
		frame:Show()
		mod:SimpleTimer(function() mod.arrow:Hide() end, 4)
	end,
	right = function()
		local frame = mod.arrow
		frame.texture:SetRotation(0)
		frame.texture:SetTexCoord(1, 0, 0, 1)
		frame:SetPoint("CENTER", 250, 100)
		frame:Show()
		mod:SimpleTimer(function() mod.arrow:Hide() end, 4)
	end,
	swap = function()
		local frame = mod.arrow
		frame.texture:SetRotation(math.rad(-70))
		frame:SetPoint("CENTER", 0, 100)
		frame:Show()
		mod:SimpleTimer(function() mod.arrow:Hide() end, 4)
	end,
	stay = function()
		-- stop sign?
	end,
}

local INITIAL_DIRECTION = {
	{ [ICON_NEGATIVE] = "left", [ICON_POSITIVE] = "right" }, -- 1
	{ [ICON_POSITIVE] = "left", [ICON_NEGATIVE] = "right" }, -- 2
	[false] = {}
}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L[15929] = "Stalagg"
	L[15930] = "Feugen"

	L.stage1_yell_trigger1 = "Stalagg crush you!"
	L.stage1_yell_trigger2 = "Feed you to master!"

	L.stage2_yell_trigger1 = "Eat... your... bones..."
	L.stage2_yell_trigger2 = "Break... you!!"
	L.stage2_yell_trigger3 = "Kill..."

	L.add_death_emote_trigger = "%s dies."
	L.overload_emote_trigger = "%s overloads!"
	L.add_revive_emote_trigger = "%s is jolted back to life!"

	-- BigWigs_ThaddiusArrows
	L.polarity_extras = "Additional alerts for Polarity Shift positioning"

	L.custom_off_select_charge_position = "First position"
	L.custom_off_select_charge_position_desc = "Where to move to after the first Polarity Shift."
	L.custom_off_select_charge_position_value1 = "|cffff2020Negative (-)|r are LEFT, |cff2020ffPositive (+)|r are RIGHT"
	L.custom_off_select_charge_position_value2 = "|cff2020ffPositive (+)|r are LEFT, |cffff2020Negative (-)|r are RIGHT"

	L.custom_off_select_charge_movement = "Movement"
	L.custom_off_select_charge_movement_desc = "The movement strategy your group uses."
	L.custom_off_select_charge_movement_value1 = "Run |cff20ff20THROUGH|r the boss"
	L.custom_off_select_charge_movement_value2 = "Run |cff20ff20CLOCKWISE|r around the boss"
	L.custom_off_select_charge_movement_value3 = "Run |cff20ff20COUNTER-CLOCKWISE|r around the boss"
	L.custom_off_select_charge_movement_value4 = "Four camps 1: Polarity changed moves |cff20ff20RIGHT|r, same polarity moves |cff20ff20LEFT|r"
	L.custom_off_select_charge_movement_value5 = "Four camps 2: Polarity changed moves |cff20ff20LEFT|r, same polarity moves |cff20ff20RIGHT|r"

	L.custom_off_charge_graphic = "Graphical arrow"
	L.custom_off_charge_graphic_desc = "Show an arrow graphic."
	L.custom_off_charge_text = "Text arrows"
	L.custom_off_charge_text_desc = "Show an additional message."
	L.custom_off_charge_voice = "Voice alert"
	L.custom_off_charge_voice_desc = "Play a voice alert."

	-- Translate these to get locale sound files!
	L.left = "<--- GO LEFT <--- GO LEFT <---"
	L.right = "---> GO RIGHT ---> GO RIGHT --->"
	L.swap = "^^^^ SWITCH SIDES ^^^^ SWITCH SIDES ^^^^"
	L.stay = "==== DON'T MOVE ==== DON'T MOVE ===="

	L.chat_message = "The Thaddius mod supports showing you directional arrows and playing voices. Open the options to configure them."
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		-- Stage 1
		28338, -- Magnetic Pull
		28134, -- Power Surge
		{"health", "INFOBOX"},
		-- Stage 2
		{28089, "COUNTDOWN"}, -- Polarity Shift
		{28084, "EMPHASIZE"}, -- Negative Charge
		{28059, "EMPHASIZE"}, -- Positive Charge
		"berserk",
		-- Extras
		"custom_off_select_charge_position",
		"custom_off_select_charge_movement",
		"custom_off_charge_graphic",
		"custom_off_charge_text",
		"custom_off_charge_voice",
	},{
		[28338] = CL.stage:format(1),
		[28089] = CL.stage:format(2),
		["custom_off_select_charge_position"] = L.polarity_extras,
	}
end

function mod:OnRegister()
	local frame = CreateFrame("Frame", "BigWigsThaddiusArrow", UIParent)
	frame:SetFrameStrata("HIGH")
	frame:Raise()
	frame:SetSize(100, 100)
	frame:SetAlpha(0.6)
	self.arrow = frame

	local texture = frame:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture(EXTRAS_PATH.."\\arrow")
	texture:SetAllPoints(frame)
	frame.texture = texture

	frame:Hide()
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "MagneticPull", 28338, 28339, 54517) -- Stalagg, Feugen, Feugen (seems like only this ID is used on wrath)
	self:Log("SPELL_AURA_APPLIED", "PowerSurge", 28134, 54529) -- 25, 10
	self:Log("SPELL_CAST_START", "PolarityShiftStart", 28089)
	self:Log("SPELL_CAST_SUCCESS", "PolarityShift", 28089)

	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")

	self:Log("SPELL_AURA_APPLIED", "NegativeCharge", 28084)
	self:Log("SPELL_AURA_REFRESH", "NegativeChargeRefresh", 28084)
	self:Log("SPELL_AURA_APPLIED", "PositiveCharge", 28059)
	self:Log("SPELL_AURA_REFRESH", "PositiveChargeRefresh", 28059)

	if not printed then
		printed = true
		BigWigs:Print(L.chat_message)
	end
end

function mod:OnEngage()
	deaths = 0
	firstCharge = true
	self:SetStage(1)

	self:OpenInfo("health", "BigWigs: ".. CL.health)
	local npcId = 15928
	for i = 1, 3, 2 do
		npcId = npcId + 1
		self:SetInfo("health", i, L[npcId])
		self:SetInfoBar("health", i, 1)
		self:SetInfo("health", i + 1, "100%")
	end
	self:SimpleTimer(UpdateInfoBoxList, 0.5)

	self:Message("stages", "cyan", CL.stage:format(1), false) -- L.engage_message
	self:Bar(28134, 11) -- Power Surge
	self:Bar(28338, 20) -- Magnetic Pull

	if self:Retail() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	end
end

function mod:OnBossDisable()
	self:SetRespawnTime(0)
	self.arrow:Hide()
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:MagneticPull(args)
		if args.time - prev > 5 then
			prev = args.time
			self:Bar(28338, 20)
			self:Message(28338, "red")
			self:PlaySound(28338, "alert")
		end
	end
end

function mod:PowerSurge(args)
	self:Message(28134, "red", CL.on:format(args.spellName, args.destName))
	self:TargetBar(28134, 10, args.destName)
	self:CDBar(28134, 26)
end

function mod:CHAT_MSG_MONSTER_EMOTE(_, msg, sender)
	if msg == L.add_death_emote_trigger then
		deaths = math.min(2, deaths + 1) -- they can revive, just don't look too weird
		self:Message("stages", "green", CL.mob_killed:format(sender, deaths, 2), false)
		if deaths == 2 then
			self:StopBar(28338) -- Magnetic Pull
			self:StopBar(28134) -- Power Surge
			if self:Retail() then
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
		if sender == L[15929] then
			self:SetInfoBar("health", 1, 0)
			self:SetInfo("health", 2, CL.dead)
		elseif sender == L[15930] then
			self:SetInfoBar("health", 3, 0)
			self:SetInfo("health", 4, CL.dead)
		end
		self:PlaySound("stages", "info")
	elseif msg == L.add_revive_emote_trigger then
		deaths = deaths - 1
	end
end

do
	local prev = 0
	function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg) -- Pre-Stage 2
		if msg == L.overload_emote_trigger then
			local t = GetTime()
			if t-prev > 2 then
				prev = t
				self:CloseInfo("health")
				self:Message("stages", "cyan", CL.incoming:format(self.displayName), false)
				self:Bar("stages", 3, CL.stage:format(2), "spell_lightning_lightningbolt01")
				self:PlaySound("stages", "long")
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg) -- Stage 2
	if msg:find(L.stage2_yell_trigger1, nil, true) or msg:find(L.stage2_yell_trigger2, nil, true) or msg:find(L.stage2_yell_trigger3, nil, true) then
		self:StopBar(28338) -- Magnetic Pull
		self:StopBar(28134) -- Power Surge
		self:SetRespawnTime(32)
		self:SetStage(2)

		self:Message("stages", "cyan", CL.stage:format(2), false)
		self:Berserk(300, true)
		self:PlaySound("stages", "info")
	elseif self:Retail() and (msg:find(L.stage1_yell_trigger1, nil, true) or msg:find(L.stage1_yell_trigger2, nil, true)) then
		self:Engage()
	end
end

function mod:PolarityShiftStart(args)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "long")
end

function mod:PolarityShift(args)
	self:CDBar(args.spellId, 28)
end

function mod:NegativeCharge(args)
	if self:Me(args.destGUID) then
		local opt = self:GetOption("custom_off_select_charge_position")
		local strategy_first = INITIAL_DIRECTION[opt]
		local strategy_change, direction
		opt = self:GetOption("custom_off_select_charge_movement")
		if opt == 1 then -- through
			strategy_change = "swap"
		elseif opt == 2 then -- cw
			strategy_change = "left"
		elseif opt == 3 then -- ccw
			strategy_change = "right"
		elseif opt == 4 then -- 4r
			strategy_change = "right"
		elseif opt == 5 then -- 4l
			strategy_change = "left"
		end

		if firstCharge then -- First charge
			firstCharge = false
			direction = strategy_first[ICON_NEGATIVE]
		else
			direction = strategy_change
		end
		self:Message(args.spellId, "blue", args.spellName, ICON_NEGATIVE)
		if self:GetOption("custom_off_charge_graphic") then
			DIRECTION_ARROW[direction]()
		end
		if self:GetOption("custom_off_charge_text") then
			self:Message(args.spellId, "blue", L[direction], ICON_NEGATIVE)
		end
		if self:GetOption("custom_off_charge_voice") then
			self:PlaySoundFile(DIRECTION_SOUND[direction])
		else
			self:PlaySound(args.spellId, "warning")
		end
	end
end

function mod:NegativeChargeRefresh(args)
	if self:Me(args.destGUID) then
		local strategy_nochange
		local opt = self:GetOption("custom_off_select_charge_movement")
		if opt == 1 then -- through
			strategy_nochange = "stay"
		elseif opt == 2 then -- cw
			strategy_nochange = "stay"
		elseif opt == 3 then -- ccw
			strategy_nochange = "stay"
		elseif opt == 4 then -- 4r
			strategy_nochange = "left"
		elseif opt == 5 then -- 4l
			strategy_nochange = "right"
		end

		local direction = strategy_nochange
		self:Message(args.spellId, "blue", args.spellName, ICON_NEGATIVE, true) -- Disable emphasize
		if self:GetOption("custom_off_charge_graphic") then
			DIRECTION_ARROW[direction]()
		end
		if self:GetOption("custom_off_charge_text") then
			self:Message(args.spellId, "blue", L[direction], ICON_NEGATIVE, true) -- Disable emphasize
		end
		if self:GetOption("custom_off_charge_voice") then
			self:PlaySoundFile(DIRECTION_SOUND[direction])
		end
	end
end

function mod:PositiveCharge(args)
	if self:Me(args.destGUID) then
		local opt = self:GetOption("custom_off_select_charge_position")
		local strategy_first = INITIAL_DIRECTION[opt]
		local strategy_change, direction
		opt = self:GetOption("custom_off_select_charge_movement")
		if opt == 1 then -- through
			strategy_change = "swap"
		elseif opt == 2 then -- cw
			strategy_change = "left"
		elseif opt == 3 then -- ccw
			strategy_change = "right"
		elseif opt == 4 then -- 4r
			strategy_change = "right"
		elseif opt == 5 then -- 4l
			strategy_change = "left"
		end

		if firstCharge then -- First charge
			firstCharge = false
			direction = strategy_first[ICON_POSITIVE]
		else
			direction = strategy_change
		end
		self:Message(args.spellId, "blue", args.spellName, ICON_POSITIVE)
		if self:GetOption("custom_off_charge_graphic") then
			DIRECTION_ARROW[direction]()
		end
		if self:GetOption("custom_off_charge_text") then
			self:Message(args.spellId, "blue", L[direction], ICON_POSITIVE)
		end
		if self:GetOption("custom_off_charge_voice") then
			self:PlaySoundFile(DIRECTION_SOUND[direction])
		else
			self:PlaySound(args.spellId, "warning")
		end
	end
end

function mod:PositiveChargeRefresh(args)
	if self:Me(args.destGUID) then
		local strategy_nochange
		local opt = self:GetOption("custom_off_select_charge_movement")
		if opt == 1 then -- through
			strategy_nochange = "stay"
		elseif opt == 2 then -- cw
			strategy_nochange = "stay"
		elseif opt == 3 then -- ccw
			strategy_nochange = "stay"
		elseif opt == 4 then -- 4r
			strategy_nochange = "left"
		elseif opt == 5 then -- 4l
			strategy_nochange = "right"
		end

		local direction = strategy_nochange
		self:Message(args.spellId, "blue", args.spellName, ICON_POSITIVE, true) -- Disable emphasize
		if self:GetOption("custom_off_charge_graphic") then
			DIRECTION_ARROW[direction]()
		end
		if self:GetOption("custom_off_charge_text") then
			self:Message(args.spellId, "blue", L[direction], ICON_POSITIVE, true) -- Disable emphasize
		end
		if self:GetOption("custom_off_charge_voice") then
			self:PlaySoundFile(DIRECTION_SOUND[direction])
		end
	end
end

do
	local bossList = {
		[15929] = 1, -- Stalagg
		[15930] = 3, -- Feugen
	}
	local unitTracker = {}
	function UpdateInfoBoxList()
		if not mod:IsEngaged() or deaths == 2 then return end
		mod:SimpleTimer(UpdateInfoBoxList, 0.5)

		for npcId in next, bossList do
			if not unitTracker[npcId] or mod:MobId(mod:UnitGUID(unitTracker[npcId])) ~= npcId then
				unitTracker[npcId] = mod:GetUnitIdByGUID(npcId)
			end
		end

		for npcId, unitToken in next, unitTracker do
			local line = bossList[npcId]
			local currentHealthPercent = math.floor(mod:GetHealth(unitToken))
			mod:SetInfoBar("health", line, currentHealthPercent/100)
			mod:SetInfo("health", line + 1, ("%d%%"):format(currentHealthPercent))
		end
	end
end
