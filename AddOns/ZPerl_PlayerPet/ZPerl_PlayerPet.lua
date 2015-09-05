-- X-Perl UnitFrames
-- Author: Zek <Boodhoof-EU>
-- License: GNU GPL v3, 29 June 2007 (see LICENSE.txt)

local XPerl_Player_Pet_Events = {}
local conf, pconf
XPerl_RequestConfig(function(new)
	conf = new
	pconf = new.pet
	if (XPerl_Player_Pet) then
		XPerl_Player_Pet.conf = pconf
	end
end, "$Revision: 974 $")

local XPerl_Player_Pet_HighlightCallback

-- XPerl_Player_Pet_OnLoad
function XPerl_Player_Pet_OnLoad(self)
	XPerl_SetChildMembers(self)
	self.partyid = "pet"

	XPerl_BlizzFrameDisable(PetFrame)

	local BuffOnUpdate, DebuffOnUpdate, BuffUpdateTooltip, DebuffUpdateTooltip
	BuffUpdateTooltip = XPerl_Unit_SetBuffTooltip
	DebuffUpdateTooltip = XPerl_Unit_SetDeBuffTooltip

	self.buffSetup = {
		buffScripts = {
			OnEnter = XPerl_Unit_SetBuffTooltip,
			OnUpdate = BuffOnUpdate,
			OnLeave = XPerl_PlayerTipHide,
		},
		debuffScripts = {
			OnEnter = XPerl_Unit_SetDeBuffTooltip,
			OnUpdate = DebuffOnUpdate,
			OnLeave = XPerl_PlayerTipHide,
		},
		updateTooltipBuff = BuffUpdateTooltip,
		updateTooltipDebuff = DebuffUpdateTooltip,
		debuffParent = true,
		debuffSizeMod = 0.3,
		debuffAnchor1 = function(self, b)
			local buff1 = XPerl_GetBuffButton(self, 1, 0, true)
			if (pconf.buffs.above) then
				b:SetPoint("BOTTOMLEFT", buff1, "TOPLEFT", 0, 0)
			else
				b:SetPoint("TOPLEFT", buff1, "BOTTOMLEFT", 0, 0)
			end
			self.buffSetup.debuffAnchor1 = nil
		end,
		buffAnchor1 = function(self, b)
			if (pconf.buffs.above) then
				b:SetPoint("BOTTOMLEFT", 0, 0)
			else
				b:SetPoint("TOPLEFT", 0, 0)
			end
			self.buffSetup.buffAnchor1 = nil
		end,
	}

	--CombatFeedback_Initialize(self, self.hitIndicator.text, 30)

	XPerl_SecureUnitButton_OnLoad(self, "pet", nil, PetFrameDropDown, XPerl_ShowGenericMenu)			--PetFrame.menu)
	XPerl_SecureUnitButton_OnLoad(self.nameFrame, "pet", nil, PetFrameDropDown, XPerl_ShowGenericMenu)	--PetFrame.menu)

	--RegisterUnitWatch(self)
	local events = {
		"UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_LEVEL", "UNIT_POWER_FREQUENT", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_NAME_UPDATE", "UNIT_FACTION", "UNIT_PORTRAIT_UPDATE", "UNIT_FLAGS", "UNIT_AURA", "UNIT_PET", "PET_ATTACK_START", "UNIT_COMBAT", --[["UNIT_SPELLMISS",]] "VARIABLES_LOADED", "PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "UNIT_THREAT_LIST_UPDATE", "PLAYER_TARGET_CHANGED", "UNIT_TARGET", "PET_BATTLE_OPENING_START","PET_BATTLE_CLOSE"
	}
	for i, event in pairs(events) do
		if string.find(event, "^UNIT_") then
			if event == "UNIT_THREAT_LIST_UPDATE" then
				self:RegisterUnitEvent(event, "target")
			else
				self:RegisterUnitEvent(event, "pet", "player")
			end
		else
			self:RegisterEvent(event)
		end
	end

	self.time = 0

	-- Set here to reduce amount of function calls made
	self:SetScript("OnEvent", XPerl_Player_Pet_OnEvent)
	self:SetScript("OnUpdate", XPerl_Player_Pet_OnUpdate)
	if (FOM_FeedButton) then
		self:SetScript("OnShow", function(self)
			XPerl_Unit_UpdatePortrait(self)
			XPerl_ProtectedCall(Set_FOM_FeedButton)
		end)
	else
		self:SetScript("OnShow", XPerl_Unit_UpdatePortrait)
	end

	if (XPerl_ArcaneBar_RegisterFrame) then
		XPerl_ArcaneBar_RegisterFrame(self.nameFrame, UnitHasVehicleUI("player") and "player" or "pet")
	end

	XPerl_RegisterHighlight(self.highlight, 2)
	XPerl_RegisterPerlFrames(self, {self.nameFrame, self.statsFrame, self.portraitFrame, self.levelFrame})
	self.FlashFrames = {self.nameFrame, self.levelFrame, self.statsFrame, self.portraitFrame}

	XPerl_RegisterOptionChanger(XPerl_Player_Pet_Set_Bits, self)

	XPerl_Highlight:Register(XPerl_Player_Pet_HighlightCallback, self)

	if (XPerlDB) then
		self.conf = XPerlDB.pet
	end

	self.GetBuffSpacing = function(self)
		local w = self.statsFrame:GetWidth()
		if (self.portraitFrame and self.portraitFrame:IsShown()) then
			w = w - 2 + self.portraitFrame:GetWidth()
		end
		if (not self.buffSpacing) then
			--self.buffSpacing = XPerl_GetReusableTable()
			self.buffSpacing = { }
		end
		self.buffSpacing.rowWidth = w
		self.buffSpacing.smallRowHeight = 0
		self.buffSpacing.smallRowWidth = w
	end
	XPerl_Player_Pet_OnLoad = nil
end

-- XPerl_Player_Pet_HighlightCallback
function XPerl_Player_Pet_HighlightCallback(self, updateGUID)
	if (updateGUID == UnitGUID("pet")) then
		XPerl_Highlight:SetHighlight(self, updateGUID)
	end
end

-- XPerl_Player_Pet_UpdateName
local function XPerl_Player_Pet_UpdateName(self)
	local petname = UnitName(self.partyid)

	if (petname == UNKNOWN) then
		self.nameFrame.text:SetText("")
	else
		self.nameFrame.text:SetText(petname)
	end

	if (self.partyid == "pet") then
		local c = conf.colour.reaction.none
		self.nameFrame.text:SetTextColor(c.r, c.g, c.b, conf.transparency.text)
	elseif (not UnitIsFriend("player", "pet")) then		-- Pet or you charmed
		local c = conf.colour.reaction.enemy
		self.nameFrame.text:SetTextColor(c.r, c.g, c.b, conf.transparency.text)
	else
		XPerl_ColourFriendlyUnit(self.nameFrame.text, self.partyid)
	end
end

-- XPerl_Player_Pet_UpdateLevel
local function XPerl_Player_Pet_UpdateLevel(self)
	XPerl_Unit_UpdateLevel(self)
end

-- XPerl_Player_Pet_UpdateHealth
function XPerl_Player_Pet_UpdateHealth(self)
	local pethealth = UnitHealth(self.partyid)
	local pethealthmax = UnitHealthMax(self.partyid)

	XPerl_SetHealthBar(self, pethealth, pethealthmax)

	XPerl_Player_Pet_UpdateAbsorbPrediction(self)
	XPerl_Player_Pet_UpdateHealPrediction(self)

	if (UnitIsDead(self.partyid)) then
		self.statsFrame.healthBar.text:SetText(XPERL_LOC_DEAD)
		self.statsFrame.manaBar.text:Hide()
	end
end

-- XPerl_Player_Pet_UpdateAbsorbPrediction
function XPerl_Player_Pet_UpdateAbsorbPrediction(self)
	if pconf.absorbs then
		XPerl_SetExpectedAbsorbs(self)
	else
		self.statsFrame.expectedAbsorbs:Hide()
	end
end

-- XPerl_Player_Pet_UpdateHealPrediction
function XPerl_Player_Pet_UpdateHealPrediction(self)
	if pconf.healprediction then
		XPerl_SetExpectedHealth(self)
	else
		self.statsFrame.expectedHealth:Hide()
	end
end

-- XPerl_Player_Pet_UpdateMana()
local function XPerl_Player_Pet_UpdateMana(self)
	local petmana = UnitPower(self.partyid)
	local petmanamax = UnitPowerMax(self.partyid)

	self.statsFrame.manaBar:SetMinMaxValues(0, petmanamax)
	self.statsFrame.manaBar:SetValue(petmana)

	self.statsFrame.manaBar.text:SetFormattedText("%d/%d", petmana, petmanamax)

	if (pconf.values) then
		self.statsFrame.manaBar.text:Show()
	end
end

-- XPerl_Player_Pet_CombatFlash
local function XPerl_Player_Pet_CombatFlash(self, elapsed, argNew, argGreen)
	if (XPerl_CombatFlashSet(self, elapsed, argNew, argGreen)) then
		XPerl_CombatFlashSetFrames(self)
	end
end

-- XPerl_Player_Pet_OnUpdate
function XPerl_Player_Pet_OnUpdate(self, elapsed)
	--[[if pconf.hitIndicator and pconf.portrait then
		CombatFeedback_OnUpdate(self, elapsed)
	end]]
	if (self.PlayerFlash) then
		XPerl_Player_Pet_CombatFlash(self, elapsed, false)
	end
end

--------------------
-- Buff Functions --
--------------------
local function XPerl_Player_Pet_Buff_UpdateAll(self)
	if (UnitExists(self.partyid)) then
		XPerl_Unit_UpdateBuffs(self)
		XPerl_Unit_BuffPositions(self, self.buffFrame.buff, self.buffFrame.debuff, self.conf.buffs.size, self.conf.debuffs.size)
		XPerl_CheckDebuffs(self, self.partyid)
	end
end

-- XPerl_Player_Pet_Update_Control
local function XPerl_Player_Pet_Update_Control(self)
	if (UnitIsCharmed(self.partyid) and not UnitInVehicle("player")) then
		self.nameFrame.warningIcon:Show()
	else
		self.nameFrame.warningIcon:Hide()
	end
end

-- XPerl_Player_Pet_UpdateCombat
local function XPerl_Player_Pet_UpdateCombat(self)
	if (UnitExists(self.partyid)) then
		if (UnitAffectingCombat(self.partyid)) then
			self.nameFrame.combatIcon:Show()
		else
			self.nameFrame.combatIcon:Hide()
		end
		XPerl_Player_Pet_Update_Control(self)
	end
end

-- XPerl_Player_Pet_UpdateDisplay
function XPerl_Player_Pet_UpdateDisplay(self)
	local unit = self:GetAttribute("unit")
	if (unit ~= self.partyid) then
		self.portraitFrame:SetAlpha(0)
		self.nameFrame:SetAlpha(0)
		self.statsFrame:SetAlpha(0)
		self.levelFrame:SetAlpha(0)
		self.buffFrame:SetAlpha(0)
		self.debuffFrame:SetAlpha(0)
	else
		self.portraitFrame:SetAlpha(1)
		self.nameFrame:SetAlpha(1)
		self.statsFrame:SetAlpha(1)
		self.levelFrame:SetAlpha(1)
		self.buffFrame:SetAlpha(1)
		self.debuffFrame:SetAlpha(1)
	end
	XPerl_Unit_UpdatePortrait(self)
	XPerl_Player_Pet_UpdateName(self)
	XPerl_Player_Pet_UpdateHealth(self)
	XPerl_SetManaBarType(self)
	XPerl_Player_Pet_UpdateMana(self)
	XPerl_Player_Pet_UpdateLevel(self)
	XPerl_Player_Pet_Buff_UpdateAll(self)
	XPerl_Player_Pet_UpdateCombat(self)
end

-------------------
-- Event Handler --
-------------------
function XPerl_Player_Pet_OnEvent(self, event, unitID, ...)
	local func = XPerl_Player_Pet_Events[event]
	if string.find(event, "^UNIT_") then
	 	if (unitID == "pet" or unitID == "player") then
			func(self, unitID, ...)
		end
	else
		func(self, unitID, ...)
	end
end

-- VARIABLES_LOADED
function XPerl_Player_Pet_Events:VARIABLES_LOADED()
	XPerl_Player_Pet_Events.VARIABLES_LOADED = nil
end

-- UNIT_AURA
function XPerl_Player_Pet_Events:UNIT_AURA()
	XPerl_Player_Pet_Buff_UpdateAll(self)
end

-- UNIT_PET
function XPerl_Player_Pet_Events:UNIT_PET()
	if (conf) then		-- DK can issue very early UNIT_PET, long before PEW. We refresh on entering world regardless
		XPerl_Player_Pet_UpdateDisplay(XPerl_Player_Pet)
	end
end

function XPerl_Player_Pet_Events:PET_BATTLE_OPENING_START()
	if (UnitExists("pet")) then
		self:Hide()
	end
end

function XPerl_Player_Pet_Events:PET_BATTLE_CLOSE()
	if (UnitExists("pet")) then
		XPerl_ProtectedCall(Show, self);
	end
end

XPerl_Player_Pet_Events.PET_STABLE_SHOW = XPerl_Player_Pet_Events.UNIT_PET

-- UNIT_NAME_UPDATE
function XPerl_Player_Pet_Events:UNIT_NAME_UPDATE()
	XPerl_Player_Pet_UpdateName(self)
end

-- UNIT_PORTRAIT_UPDATE
function XPerl_Player_Pet_Events:UNIT_PORTRAIT_UPDATE()
	XPerl_Unit_UpdatePortrait(self)
end

-- UNIT_HEALTH, UNIT_MAXHEALTH
function XPerl_Player_Pet_Events:UNIT_HEALTH()
	XPerl_Player_Pet_UpdateHealth(self)
end

XPerl_Player_Pet_Events.UNIT_MAXHEALTH = XPerl_Player_Pet_Events.UNIT_HEALTH

-- Ticket 735 Player Pet frame's power bar fix.
-- Thanks Brounks pointed out again... -.- By PlayerLin

function XPerl_Player_Pet_Events:UNIT_POWER_FREQUENT()
	XPerl_Player_Pet_UpdateMana(self)
	XPerl_Player_Pet_UpdateCombat(self)
end

XPerl_Player_Pet_Events.UNIT_MAXPOWER = XPerl_Player_Pet_Events.UNIT_POWER_FREQUENT


-- UNIT_LEVEL
function XPerl_Player_Pet_Events:UNIT_LEVEL()
	XPerl_Player_Pet_UpdateLevel(self)
end

XPerl_Player_Pet_Events.UNIT_PET_EXPERIENCE = XPerl_Player_Pet_Events.UNIT_LEVEL

-- UNIT_DISPLAYPOWER
function XPerl_Player_Pet_Events:UNIT_DISPLAYPOWER()
	XPerl_SetManaBarType(self)
end

-- PET_ATTACK_START
function XPerl_Player_Pet_Events:PET_ATTACK_START()
	XPerl_Player_Pet_UpdateCombat(XPerl_Player_Pet)
end

-- UNIT_COMBAT
function XPerl_Player_Pet_Events:UNIT_COMBAT(...)
	local unitID, action, descriptor, damage, damageType = ...

	if (unitID == self.partyid) then
		--[[if (pconf.hitIndicator and pconf.portrait) then
			CombatFeedback_OnCombatEvent(self, ...)
		end]]

		if (action == "HEAL") then
			XPerl_Player_Pet_CombatFlash(XPerl_Player_Pet, 0, true, true)
		elseif (damage and damage > 0) then
			XPerl_Player_Pet_CombatFlash(XPerl_Player_Pet, 0, true)
		end
	end
end

-- UNIT_SPELLMISS
--[[function XPerl_Player_Pet_Events:UNIT_SPELLMISS(...)
	if (pconf.hitIndicator and pconf.portrait) then
		CombatFeedback_OnSpellMissEvent(self, ...)
	end
end]]

-- UNIT_FACTION
function XPerl_Player_Pet_Events:UNIT_FACTION()
	XPerl_Player_Pet_UpdateName(self)
	XPerl_Player_Pet_UpdateCombat(self)
end

XPerl_Player_Pet_Events.UNIT_FLAGS = XPerl_Player_Pet_Events.UNIT_FACTION

-- PLAYER_REGEN_ENABLED
function XPerl_Player_Pet_Events:PLAYER_REGEN_ENABLED()
	if (self:GetAttribute("unit") ~= self.partyid) then
		self:SetAttribute("unit", self.partyid)
	end
end

-- PLAYER_ENTERING_WORLD
function XPerl_Player_Pet_Events:PLAYER_ENTERING_WORLD()
	if (UnitHasVehicleUI("player")) then
		self.partyid = "player"
		self:SetAttribute("unit", "player")
	else
		self.partyid = "pet"
		self:SetAttribute("unit", "pet")
	end
end

-- UNIT_ENTERED_VEHICLE
function XPerl_Player_Pet_Events:UNIT_ENTERED_VEHICLE(unit, showVehicle)
	if (unit == "player" and showVehicle) then
		self.partyid = "player"
		if (XPerl_ArcaneBar_SetUnit) then
			XPerl_ArcaneBar_SetUnit(self.nameFrame, "player")
		end
		if (not InCombatLockdown()) then
			self:SetAttribute("unit", "player")
		end
		XPerl_Player_Pet_UpdateDisplay(self)
	else
		XPerl_Player_Pet_Events.UNIT_EXITED_VEHICLE(self, unit)
	end
end

-- UNIT_EXITED_VEHICLE
function XPerl_Player_Pet_Events:UNIT_EXITED_VEHICLE(unit)
	if (unit == "player") then
		if (self.partyid ~= "pet") then
			self.partyid = "pet"
			if (XPerl_ArcaneBar_SetUnit) then
				XPerl_ArcaneBar_SetUnit(self.nameFrame, "pet")
			end
			if (not InCombatLockdown()) then
				self:SetAttribute("unit", "pet")
			end
			XPerl_Player_Pet_UpdateDisplay(self)
		end
	end
end

function XPerl_Player_Pet_Events:UNIT_THREAT_LIST_UPDATE(unit)
	if (unit == "target") then
		XPerl_Unit_ThreatStatus(self)
	end
end

function XPerl_Player_Pet_Events:PLAYER_TARGET_CHANGED()
	XPerl_Unit_ThreatStatus(self, nil, true)
end
XPerl_Player_Pet_Events.UNIT_TARGET = XPerl_Player_Pet_Events.PLAYER_TARGET_CHANGED

-- PLAYER_REGEN_DISABLED
local virtual
function XPerl_Player_Pet_Events:PLAYER_REGEN_DISABLED()
	if (virtual) then
		virtual = nil
		RegisterUnitWatch(XPerl_Player_Pet)
		if (UnitExists("pet")) then
			XPerl_Player_Pet:Show()
			XPerl_Player_Pet_UpdateDisplay(XPerl_Player_Pet)
		else
			XPerl_Player_Pet:Hide()
		end

		if (XPerl_PetTarget) then
			RegisterUnitWatch(XPerl_PetTarget)
			if (UnitExists("pettarget")) then
				XPerl_PetTarget:Show()
				XPerl_TargetTarget_UpdateDisplay(XPerl_PetTarget)
			else
				XPerl_PetTarget:Hide()
			end
		end
	end
end

function XPerl_Player_Pet_Events:UNIT_HEAL_PREDICTION(unit)
	if (pconf.healprediction and unit == self.partyid) then
		XPerl_SetExpectedHealth(self)
	end
end

function XPerl_Player_Pet_Events:UNIT_ABSORB_AMOUNT_CHANGED(unit)
	if (pconf.absorbs and unit == self.partyid) then
		XPerl_SetExpectedAbsorbs(self)
	end
end

-- XPerl_Player_Pet_SetWidth
function XPerl_Player_Pet_SetWidth(self)
	pconf.size.width = max(0, pconf.size.width or 0)
	self.statsFrame:SetWidth(80 + pconf.size.width)
	self.nameFrame:SetWidth(80 + pconf.size.width)
	self:SetScale(pconf.scale)
	XPerl_StatsFrameSetup(self, nil, 2)
	XPerl_SavePosition(self, true)
end

-- XPerl_Player_Pet_Virtual
function XPerl_Player_Pet_Virtual(show)
	if (not InCombatLockdown()) then
		if (show) then
			if (not virtual) then
				virtual = true
				if not UnitExists("pet") then
					XPerl_Player_Pet:RegisterEvent("PLAYER_REGEN_DISABLED")
					UnregisterUnitWatch(XPerl_Player_Pet)
					XPerl_Player_Pet:Show()
					XPerl_Player_Pet.nameFrame.text:SetText(PET)
					XPerl_Player_Pet.statsFrame.healthBar.text:SetText("")
					XPerl_Player_Pet.statsFrame.manaBar.text:SetText("")
					XPerl_Player_Pet:SetAlpha(0.5)
				end

				if XPerl_PetTarget and not UnitExists("pettarget") then
					XPerl_PetTarget.virtual = true
					UnregisterUnitWatch(XPerl_PetTarget)
					XPerl_PetTarget:Show()
					XPerl_PetTarget.nameFrame.text:SetText(PET.." "..TARGET)
					XPerl_PetTarget.statsFrame.healthBar.text:SetText("")
					XPerl_PetTarget.statsFrame.manaBar.text:SetText("")
					XPerl_PetTarget.statsFrame.healthBar.percent:SetText("")
					XPerl_PetTarget.statsFrame.manaBar.percent:SetText("")
					XPerl_PetTarget:SetAlpha(0.5)
				end
			end
		else
			if (virtual) then
				virtual = nil
				RegisterUnitWatch(XPerl_Player_Pet)
				if (XPerl_PetTarget) then
					XPerl_PetTarget.virtual = nil
					if (XPerl_PetTarget.conf.enable) then
						RegisterUnitWatch(XPerl_PetTarget)
						XPerl_PetTarget:Hide()
					end
				end
				XPerl_Player_Pet:UnregisterEvent("PLAYER_REGEN_DISABLED")
			end
		end
	end
end

-- XPerl_Player_Pet_Set_Bits
function XPerl_Player_Pet_Set_Bits(self)
	if (not virtual) then
		RegisterUnitWatch(self)
	end

	if (pconf.portrait) then
		self.portraitFrame:Show()
		self.portraitFrame:SetWidth(50)
	else
		self.portraitFrame:Hide()
		self.portraitFrame:SetWidth(3)
	end

	if (pconf.name) then
		self.nameFrame:Show()
		self.nameFrame:SetHeight(24)
	else
		self.nameFrame:Hide()
		self.nameFrame:SetHeight(2)
	end

	if (pconf.name or pconf.portrait) then
		if (pconf.level) then
			self.levelFrame:SetPoint("TOPRIGHT", self.portraitFrame, "TOPLEFT", 2, 0)
		end
	else
		if (pconf.level) then
			self.levelFrame:SetPoint("TOPRIGHT", self.statsFrame, "TOPLEFT", 2, 0)
		end
	end

	if (pconf.level) then
		self.levelFrame:Show()
	else
		self.levelFrame:Hide()
	end

	self.buffOptMix = nil
	self.buffFrame:ClearAllPoints()
	if (pconf.buffs.above) then
		if (pconf.portrait) then
			self.buffFrame:SetPoint("BOTTOMLEFT", self.portraitFrame, "TOPLEFT", 3, 0)
		else
			self.buffFrame:SetPoint("BOTTOMLEFT", self.nameFrame, "TOPLEFT", 3, 0)
		end
	else
		if (not pconf.extendPortrait and (not pconf.portrait or not pconf.name)) then
			self.buffFrame:SetPoint("TOPLEFT", self.statsFrame, "BOTTOMLEFT", 3, 0)
		else
			self.buffFrame:SetPoint("TOPLEFT", self.portraitFrame, "BOTTOMLEFT", 3, 0)
		end
	end

	if (pconf.values) then
		self.statsFrame.healthBar.text:Show()
		self.statsFrame.manaBar.text:Show()
	else
		self.statsFrame.healthBar.text:Hide()
		self.statsFrame.manaBar.text:Hide()
	end

	self.portraitFrame:SetHeight(56 + (pconf.extendPortrait and 1 or 0) * 10)

	self.highlight:ClearAllPoints()
	if (pconf.portrait or pconf.name) then
		self.highlight:SetPoint("BOTTOMLEFT", self.portraitFrame)
	else
		self.highlight:SetPoint("BOTTOMLEFT", self.statsFrame)
	end
	self.highlight:SetPoint("TOPRIGHT", self.nameFrame)

	pconf.buffs.size = tonumber(pconf.buffs.size) or 20
	XPerl_SetBuffSize(self)

	if (pconf.healprediction) then
		self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "pet", "player")
	else
		self:UnregisterEvent("UNIT_HEAL_PREDICTION")
	end

	if (pconf.absorbs) then
		self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "pet", "player")
	else
		self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	end

	XPerl_Player_Pet_SetWidth(self)

	if (self:IsShown()) then
		XPerl_Player_Pet_UpdateDisplay(self)
	end
end
