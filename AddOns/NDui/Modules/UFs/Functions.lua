local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:RegisterModule("UnitFrames")
local AURA = B:GetModule("Auras")

local format, floor = string.format, math.floor
local pairs, next, unpack = pairs, next, unpack
local UnitGUID, IsItemInRange = UnitGUID, IsItemInRange
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local SpellGetVisibilityInfo, UnitAffectingCombat, SpellIsSelfBuff, SpellIsPriorityAura = SpellGetVisibilityInfo, UnitAffectingCombat, SpellIsSelfBuff, SpellIsPriorityAura
local x1, x2, y1, y2 = unpack(DB.TexCoord)

-- Custom colors
oUF.colors.smooth = {1, 0, 0, .85, .8, .45, .1, .1, .1}
oUF.colors.debuff.none = {0, 0, 0}

local function ReplacePowerColor(name, index, color)
	oUF.colors.power[name] = color
	oUF.colors.power[index] = oUF.colors.power[name]
end
ReplacePowerColor("MANA", 0, {0, .4, 1})
ReplacePowerColor("SOUL_SHARDS", 7, {.58, .51, .79})
ReplacePowerColor("HOLY_POWER", 9, {.88, .88, .06})
ReplacePowerColor("CHI", 12, {0, 1, .59})
ReplacePowerColor("ARCANE_CHARGES", 16, {.41, .8, .94})

-- Various values
local function retVal(self, val1, val2, val3, val4, val5)
	local mystyle = self.mystyle
	if mystyle == "player" or mystyle == "target" then
		return val1
	elseif mystyle == "focus" then
		return val2
	elseif mystyle == "boss" or mystyle == "arena" then
		return val3
	else
		if mystyle == "nameplate" and val5 then
			return val5
		else
			return val4
		end
	end
end

-- Elements
local function UF_OnEnter(self)
	if not self.disableTooltip then
		UnitFrame_OnEnter(self)
	end
	self.Highlight:Show()
end

local function UF_OnLeave(self)
	if not self.disableTooltip then
		UnitFrame_OnLeave(self)
	end
	self.Highlight:Hide()
end

function UF:CreateHeader(self, onKeyDown)
	local hl = self:CreateTexture(nil, "OVERLAY")
	hl:SetAllPoints()
	hl:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	hl:SetTexCoord(0, 1, .5, 1)
	hl:SetVertexColor(.6, .6, .6)
	hl:SetBlendMode("ADD")
	hl:Hide()
	self.Highlight = hl

	self:RegisterForClicks(onKeyDown and "AnyDown" or "AnyUp")
	self:HookScript("OnEnter", UF_OnEnter)
	self:HookScript("OnLeave", UF_OnLeave)
end

local function UpdateHealthColorByIndex(health, index)
	health.colorClass = (index == 2)
	health.colorReaction = (index == 2)
	if health.SetColorTapping then
		health:SetColorTapping(index == 2)
	else
		health.colorTapping = (index == 2)
	end
	if health.SetColorDisconnected then
		health:SetColorDisconnected(index == 2)
	else
		health.colorDisconnected = (index == 2)
	end
	health.colorSmooth = (index == 3)
	if index == 1 then
		health:SetStatusBarColor(.1, .1, .1)
		health.bg:SetVertexColor(.6, .6, .6)
	elseif index == 4 then
		health:SetStatusBarColor(0, 0, 0, 0)
	end
end

function UF:UpdateHealthBarColor(self, force)
	local health = self.Health
	local mystyle = self.mystyle
	if mystyle == "PlayerPlate" then
		health.colorHealth = true
	elseif mystyle == "raid" then
		UpdateHealthColorByIndex(health, C.db["UFs"]["RaidHealthColor"])
	else
		UpdateHealthColorByIndex(health, C.db["UFs"]["HealthColor"])
	end

	if force then
		health:ForceUpdate()
	end
end

local endColor = CreateColor(0, 0, 0, .25)
function UF.HealthPostUpdate(element, unit, cur, max)
	local self = element.__owner
	local mystyle = self.mystyle
	local useGradient, useGradientClass
	if mystyle == "PlayerPlate" then
		-- do nothing
	elseif mystyle == "raid" then
		useGradient = C.db["UFs"]["RaidHealthColor"] > 3
		useGradientClass = C.db["UFs"]["RaidHealthColor"] == 5
	else
		useGradient = C.db["UFs"]["HealthColor"] > 3
		useGradientClass = C.db["UFs"]["HealthColor"] == 5
	end
	if useGradient then
		element.bg:SetVertexColor(self:ColorGradient(cur or 1, max or 1, 1,0,0, 1,.7,0, .7,1,0))
	end
	if useGradientClass then
		local color
		if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
			local _, class = UnitClass(unit)
			color = self.colors.class[class]
		elseif UnitReaction(unit, "player") then
			color = self.colors.reaction[UnitReaction(unit, "player")]
		end
		if color then
			element:GetStatusBarTexture():SetGradient("HORIZONTAL", CreateColor(color[1], color[2], color[3], .75), endColor)
		end
	end
end

function UF:CreateHealthBar(self)
	local mystyle = self.mystyle
	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT", self)
	health:SetPoint("TOPRIGHT", self)
	local healthHeight
	if mystyle == "PlayerPlate" then
		healthHeight = C.db["Nameplate"]["PPHealthHeight"]
	elseif mystyle == "raid" then
		if self.raidType == "party" then
			healthHeight = C.db["UFs"]["PartyHeight"]
		elseif self.raidType == "pet" then
			healthHeight = C.db["UFs"]["PartyPetHeight"]
		elseif self.raidType == "simple" then
			local scale = C.db["UFs"]["SMRScale"]/10
			healthHeight = 20*scale - 2*scale - C.mult
		else
			healthHeight = C.db["UFs"]["RaidHeight"]
		end
	else
		healthHeight = retVal(self, C.db["UFs"]["PlayerHeight"], C.db["UFs"]["FocusHeight"], C.db["UFs"]["BossHeight"], C.db["UFs"]["PetHeight"])
	end
	health:SetHeight(healthHeight)
	health:SetStatusBarTexture(DB.normTex)
	health:SetStatusBarColor(.1, .1, .1)
	health:SetFrameLevel(self:GetFrameLevel() - 2)

	self.backdrop = B.SetBD(health, 0)
	if self.backdrop.__shadow then
		self.backdrop.__shadow:SetOutside(self, 4+C.mult, 4+C.mult)
		self.backdrop.__shadow:SetFrameLevel(0)
		self.backdrop.__shadow = nil
	end
	B:SmoothBar(health)

	local bg = self:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	bg:SetPoint("BOTTOMRIGHT", health)
	bg:SetTexture(DB.bdTex)
	bg:SetVertexColor(.6, .6, .6)
	bg.multiplier = .25

	self.Health = health
	self.Health.bg = bg
	self.Health.PostUpdate = UF.HealthPostUpdate

	UF:UpdateHealthBarColor(self)
end

UF.VariousTagIndex = {
	[1] = "",
	[2] = "currentpercent",
	[3] = "currentmax",
	[4] = "current",
	[5] = "percent",
	[6] = "loss",
	[7] = "losspercent",
}

function UF:UpdateFrameHealthTag()
	local mystyle = self.mystyle
	local valueType
	if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerHPTag"]]
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusHPTag"]]
	elseif mystyle == "boss" or mystyle == "arena" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossHPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["PetHPTag"]]
	end

	local showValue = C.db["UFs"]["PlayerAbsorb"] and mystyle == "player" and "[curAbsorb] " or ""
	self:Tag(self.healthValue, showValue.."[VariousHP("..valueType..")]")
	self.healthValue:UpdateTag()
end

function UF:UpdateFrameNameTag()
	local name = self.nameText
	if not name then return end

	local mystyle = self.mystyle
	if mystyle == "nameplate" then return end

	local value = mystyle == "raid" and "RCCName" or "CCName"
	local colorTag = C.db["UFs"][value] and "[color]" or ""

	if mystyle == "player" then
		self:Tag(name, " "..colorTag.."[name]")
	elseif mystyle == "target" then
		self:Tag(name, " [fulllevel] "..colorTag.."[name][afkdnd]")
	elseif mystyle == "focus" then
		self:Tag(name, " "..colorTag.."[name][afkdnd]")
	elseif mystyle == "arena" then
		self:Tag(name, "[arenaspec] "..colorTag.."[name]")
	elseif self.raidType == "simple" and C.db["UFs"]["TeamIndex"] then
		self:Tag(name, "[group] "..colorTag.."[name]")
	else
		self:Tag(name, colorTag.."[name]")
	end
	name:UpdateTag()
end

function UF:UpdateRaidNameAnchor(name)
	if self.raidType == "pet" then
		name:ClearAllPoints()
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetWidth(self:GetWidth()*.95)
			name:SetJustifyH("CENTER")
			name:SetPoint("CENTER")
		else
			name:SetWidth(self:GetWidth()*.65)
			name:SetJustifyH("LEFT")
			name:SetPoint("LEFT", 3, -1)
		end
	elseif self.raidType == "simple" then
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetWidth(self:GetWidth()*.95)
		else
			name:SetWidth(self:GetWidth()*.65)
		end
	else
		name:ClearAllPoints()
		name:SetWidth(self:GetWidth()*.95)
		name:SetJustifyH("CENTER")
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetPoint("CENTER")
		else
			name:SetPoint("TOP", 0, -3)
		end
	end
end

function UF:CreateHealthText(self)
	local mystyle = self.mystyle
	local textFrame = CreateFrame("Frame", nil, self)
	textFrame:SetAllPoints(self.Health)

	local name = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 12, C.db["Nameplate"]["NameTextSize"]), "", false, "LEFT", 3, 0)
	self.nameText = name
	name:SetJustifyH("LEFT")
	if mystyle == "raid" then
		UF.UpdateRaidNameAnchor(self, name)
		name:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "nameplate" then
		name:ClearAllPoints()
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
		name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 5)
		self:Tag(name, "[nplevel][name]")
	elseif mystyle == "player" or mystyle == "target" then
		name:SetPoint("LEFT", 3, C.db["UFs"]["PlayerNameOffset"])
		name:SetWidth(self:GetWidth()*(C.db["UFs"]["PlayerNameOffset"] == 0 and .55 or 1))
	elseif mystyle == "focus" then
		name:SetPoint("LEFT", 3, C.db["UFs"]["FocusNameOffset"])
		name:SetWidth(self:GetWidth()*(C.db["UFs"]["FocusNameOffset"] == 0 and .55 or 1))
	elseif mystyle == "boss" or mystyle == "arena" then
		name:SetPoint("LEFT", 3, C.db["UFs"]["BossNameOffset"])
		name:SetWidth(self:GetWidth()*(C.db["UFs"]["BossNameOffset"] == 0 and .55 or 1))
	else
		name:SetPoint("LEFT", 3, C.db["UFs"]["PetNameOffset"])
		name:SetWidth(self:GetWidth()*(C.db["UFs"]["PetNameOffset"] == 0 and .55 or 1))
	end

	UF.UpdateFrameNameTag(self)

	local hpval = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 12, C.db["Nameplate"]["HealthTextSize"]), "", false, "RIGHT", -3, 0)
	self.healthValue = hpval
	if mystyle == "raid" then
		self:Tag(hpval, "[raidhp]")
		if self.raidType == "pet" then
			hpval:SetPoint("RIGHT", -3, -1)
		elseif self.raidType == "simple" then
			hpval:SetPoint("RIGHT", -4, 0)
		else
			hpval:ClearAllPoints()
			hpval:SetPoint("BOTTOM", 0, 1)
			hpval:SetJustifyH("CENTER")
		end
		hpval:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "nameplate" then
		hpval:SetPoint("RIGHT", self, 0, 5)
		self:Tag(hpval, "[VariousHP(currentpercent)]")
	else
		UF.UpdateFrameHealthTag(self)
	end
end

local function UpdatePowerColorByIndex(power, index)
	power.colorPower = (index == 2) or (index == 5)
	power.colorClass = (index ~= 2)
	power.colorReaction = (index ~= 2)
	if power.SetColorTapping then
		power:SetColorTapping(index ~= 2)
	else
		power.colorTapping = (index ~= 2)
	end
	if power.SetColorDisconnected then
		power:SetColorDisconnected(index ~= 2)
	else
		power.colorDisconnected = (index ~= 2)
	end
end

function UF:UpdatePowerBarColor(self, force)
	local power = self.Power
	local mystyle = self.mystyle
	if mystyle == "PlayerPlate" then
		power.colorPower = true
	elseif mystyle == "raid" then
		UpdatePowerColorByIndex(power, C.db["UFs"]["RaidHealthColor"])
	else
		UpdatePowerColorByIndex(power, C.db["UFs"]["HealthColor"])
	end

	if force then
		power:ForceUpdate()
	end
end

local frequentUpdateCheck = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["PlayerPlate"] = true,
}
function UF:CreatePowerBar(self)
	local mystyle = self.mystyle
	local power = CreateFrame("StatusBar", nil, self)
	power:SetStatusBarTexture(DB.normTex)
	power:SetPoint("BOTTOMLEFT", self)
	power:SetPoint("BOTTOMRIGHT", self)
	local powerHeight
	if mystyle == "PlayerPlate" then
		powerHeight = C.db["Nameplate"]["PPPowerHeight"]
	elseif mystyle == "raid" then
		if self.raidType == "party" then
			powerHeight = C.db["UFs"]["PartyPowerHeight"]
		elseif self.raidType == "pet" then
			powerHeight = C.db["UFs"]["PartyPetPowerHeight"]
		elseif self.raidType == "simple" then
			powerHeight = 2*C.db["UFs"]["SMRScale"]/10
		else
			powerHeight = C.db["UFs"]["RaidPowerHeight"]
		end
	else
		powerHeight = retVal(self, C.db["UFs"]["PlayerPowerHeight"], C.db["UFs"]["FocusPowerHeight"], C.db["UFs"]["BossPowerHeight"], C.db["UFs"]["PetPowerHeight"])
	end
	power:SetHeight(powerHeight)
	power.wasHidden = powerHeight == 0
	power:SetFrameLevel(self:GetFrameLevel() - 2)
	power.backdrop = B.CreateBDFrame(power, 0)
	B:SmoothBar(power)

	local bg = power:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	self.Power = power
	self.Power.bg = bg

	power.frequentUpdates = frequentUpdateCheck[mystyle]
	UF:UpdatePowerBarColor(self)
end

function UF:CheckPowerBars()
	for _, frame in pairs(oUF.objects) do
		if frame.Power and frame.Power.wasHidden then
			frame:DisableElement("Power")
			if frame.powerText then frame.powerText:Hide() end
		end
	end
end

function UF:UpdateFramePowerTag()
	local mystyle = self.mystyle
	local valueType
	if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerMPTag"]]
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusMPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossMPTag"]]
	end

	self:Tag(self.powerText, "[color][VariousMP("..valueType..")]")
	self.powerText:UpdateTag()
end

function UF:CreatePowerText(self)
	local textFrame = CreateFrame("Frame", nil, self)
	textFrame:SetAllPoints(self.Power)

	local ppval = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 12), "", false, "RIGHT", -3, 2)
	local mystyle = self.mystyle
	if mystyle == "raid" then
		ppval:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "player" or mystyle == "target" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["PlayerPowerOffset"])
	elseif mystyle == "focus" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["FocusPowerOffset"])
	elseif mystyle == "boss" or mystyle == "arena" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["BossPowerOffset"])
	end
	self.powerText = ppval
	UF.UpdateFramePowerTag(self)
end

local textScaleFrames = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["pet"] = true,
	["tot"] = true,
	["focustarget"] = true,
	["boss"] = true,
	["arena"] = true,
}
function UF:UpdateTextScale()
	local scale = C.db["UFs"]["UFTextScale"]
	for _, frame in pairs(oUF.objects) do
		local style = frame.mystyle
		if style and textScaleFrames[style] then
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			if frame.powerText then frame.powerText:SetScale(scale) end
			local castbar = frame.Castbar
			if castbar then
				if castbar.Text then castbar.Text:SetScale(scale) end
				if castbar.Time then castbar.Time:SetScale(scale) end
				if castbar.Lag then castbar.Lag:SetScale(scale) end
			end
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
		end
	end
end

function UF:UpdateRaidTextScale()
	local scale = C.db["UFs"]["RaidTextScale"]
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			UF.UpdateRaidNameAnchor(frame, frame.nameText)
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			frame.healthValue:UpdateTag()
			if frame.powerText then frame.powerText:SetScale(scale) end
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
			frame.disableTooltip = C.db["UFs"]["HideTip"]
		end
	end
end

function UF:CreatePortrait(self)
	local portrait = CreateFrame("PlayerModel", nil, self.Health)
	portrait:SetAllPoints()
	portrait:SetAlpha(.2)
	self.Portrait = portrait
end

function UF:TogglePortraits()
	for _, frame in pairs(oUF.objects) do
		if frame.Portrait then
			if C.db["UFs"]["Portrait"] and not frame:IsElementEnabled("Portrait") then
				frame:EnableElement("Portrait")
				frame.Portrait:ForceUpdate()
			elseif not C.db["UFs"]["Portrait"] and frame:IsElementEnabled("Portrait") then
				frame:DisableElement("Portrait")
			end
		end
	end
end

local function postUpdateRole(element, role)
	if element:IsShown() then
		if role == "DAMAGER" and C.db["UFs"]["ShowRoleMode"] == 3 then
			element:Hide()
			return
		end
		B.ReskinSmallRole(element, role)
	end
end

function UF:CreateRestingIndicator(self)
	local frame = CreateFrame("Frame", "NDuiRestingFrame", self)
	frame:SetSize(5, 5)
	frame:SetPoint("CENTER", self, "LEFT", -2, 4)
	frame:Hide()
	frame.str = {}

	local step, stepSpeed = 0, .33

	local stepMaps = {
		[1] = {true, false, false},
		[2] = {true, true, false},
		[3] = {true, true, true},
		[4] = {false, true, true},
		[5] = {false, false, true},
		[6] = {false, false, false},
	}

	local offsets = {
		[1] = {4, -4},
		[2] = {0, 0},
		[3] = {-5, 5},
	}

	for i = 1, 3 do
		local textFrame = CreateFrame("Frame", nil, frame)
		textFrame:SetAllPoints()
		textFrame:SetFrameLevel(i+5)
		local text = B.CreateFS(textFrame, (7+i*3), "z", nil, "CENTER", offsets[i][1], offsets[i][2])
		text:SetTextColor(.6, .8, 1)
		frame.str[i] = text
	end

	frame:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > stepSpeed then
			step = step + 1
			if step == 7 then step = 1 end

			for i = 1, 3 do
				frame.str[i]:SetShown(stepMaps[step][i])
			end

			self.elapsed = 0
		end
	end)

	frame:SetScript("OnHide", function()
		step = 6
	end)

	self.RestingIndicator = frame
end

function UF:CreateIcons(self)
	local mystyle = self.mystyle
	if mystyle == "player" then
		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:SetPoint("CENTER", self, "BOTTOMLEFT")
		combat:SetSize(28, 28)
		combat:SetAtlas(DB.objectTex)
		self.CombatIndicator = combat
	elseif mystyle == "target" then
		local quest = self:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 8)
		quest:SetSize(16, 16)
		self.QuestIndicator = quest
	end

	local phase = CreateFrame("Frame", nil, self)
	phase:SetSize(24, 24)
	phase:SetPoint("CENTER", self.Health)
	phase:SetFrameLevel(5)
	phase:EnableMouse(true)
	local icon = phase:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	phase.Icon = icon
	self.PhaseIndicator = phase

	if C.db["UFs"]["ShowRoleMode"] ~= 2 then
		local ri = self:CreateTexture(nil, "OVERLAY")
		if mystyle == "raid" then
			ri:SetPoint("TOPRIGHT", self, 5, 5)
		else
			ri:SetPoint("TOPRIGHT", self, 0, 8)
		end
		ri:SetSize(15, 15)
		ri.PostUpdate = postUpdateRole
		self.GroupRoleIndicator = ri
	end

	local li = self:CreateTexture(nil, "OVERLAY")
	li:SetPoint("TOPLEFT", self, -1, 8)
	li:SetSize(12, 12)
	self.LeaderIndicator = li

	local ai = self:CreateTexture(nil, "OVERLAY")
	ai:SetPoint("TOPLEFT", self, -1, 8)
	ai:SetSize(12, 12)
	self.AssistantIndicator = ai
end

function UF:CreateRaidMark(self)
	local mystyle = self.mystyle
	local ri = self:CreateTexture(nil, "OVERLAY")
	if mystyle == "raid" then
		ri:SetPoint("TOP", self, 0, 10)
	elseif mystyle == "nameplate" then
		ri:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 3)
	else
		ri:SetPoint("CENTER", self, "TOP")
	end
	local size = retVal(self, 18, 13, 12, 12, 32)
	ri:SetSize(size, size)
	self.RaidTargetIndicator = ri
end

local function createBarMover(bar, text, value, anchor)
	local mover = B.Mover(bar, text, value, anchor, bar:GetHeight()+bar:GetWidth()+3, bar:GetHeight()+3)
	bar:ClearAllPoints()
	bar:SetPoint("RIGHT", mover)
	bar.mover = mover
end

local function updateSpellTarget(self, _, unit)
	UF.PostCastUpdate(self.Castbar, unit)
end

function UF:ToggleCastBarLatency(frame)
	frame = frame or _G.oUF_Player
	if not frame then return end

	if C.db["UFs"]["LagString"] then
		frame:RegisterEvent("GLOBAL_MOUSE_UP", UF.OnCastSent, true) -- Fix quests with WorldFrame interaction
		frame:RegisterEvent("GLOBAL_MOUSE_DOWN", UF.OnCastSent, true)
		frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", UF.OnCastSent, true)
	else
		frame:UnregisterEvent("GLOBAL_MOUSE_UP", UF.OnCastSent)
		frame:UnregisterEvent("GLOBAL_MOUSE_DOWN", UF.OnCastSent)
		frame:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED", UF.OnCastSent)
		if frame.Castbar then frame.Castbar.__sendTime = nil end
	end
end

function UF:CreateCastBar(self)
	local mystyle = self.mystyle
	if mystyle ~= "nameplate" and not C.db["UFs"]["Castbars"] then return end

	local cb = CreateFrame("StatusBar", "oUF_Castbar"..mystyle, self)
	cb:SetHeight(20)
	cb:SetWidth(self:GetWidth() - 22)
	B.CreateSB(cb, true, .3, .7, 1)
	cb.castTicks = {}

	if mystyle == "player" then
		cb:SetFrameLevel(10)
		cb:SetSize(C.db["UFs"]["PlayerCBWidth"], C.db["UFs"]["PlayerCBHeight"])
		createBarMover(cb, L["Player Castbar"], "PlayerCB", C.UFs.Playercb)
	elseif mystyle == "target" then
		cb:SetFrameLevel(10)
		cb:SetSize(C.db["UFs"]["TargetCBWidth"], C.db["UFs"]["TargetCBHeight"])
		createBarMover(cb, L["Target Castbar"], "TargetCB", C.UFs.Targetcb)
	elseif mystyle == "focus" then
		cb:SetFrameLevel(10)
		cb:SetSize(C.db["UFs"]["FocusCBWidth"], C.db["UFs"]["FocusCBHeight"])
		createBarMover(cb, L["Focus Castbar"], "FocusCB", C.UFs.Focuscb)
	elseif mystyle == "boss" or mystyle == "arena" then
		cb:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -8)
		cb:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -8)
		cb:SetHeight(10)
	elseif mystyle == "nameplate" then
		cb:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
		cb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
		cb:SetHeight(self:GetHeight())
	end

	local timer = B.CreateFS(cb, 12, "", false, "RIGHT", -2, 0)
	local name = B.CreateFS(cb, 12, "", false, "LEFT", 2, 0)
	name:SetPoint("RIGHT", timer, "LEFT", -5, 0)
	name:SetJustifyH("LEFT")

	if mystyle ~= "boss" and mystyle ~= "arena" then
		cb.Icon = cb:CreateTexture(nil, "ARTWORK")
		cb.Icon:SetSize(cb:GetHeight(), cb:GetHeight())
		cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -3, 0)
		cb.Icon:SetTexCoord(x1, x2, y1, y2)
		B.SetBD(cb.Icon)
	end

	if mystyle == "player" then
		local safeZone = cb:CreateTexture(nil, "OVERLAY")
		safeZone:SetTexture(DB.normTex)
		safeZone:SetVertexColor(1, 0, 0, .6)
		safeZone:SetPoint("TOPRIGHT")
		safeZone:SetPoint("BOTTOMRIGHT")
		cb:SetFrameLevel(10)
		cb.SafeZone = safeZone

		local lagStr = B.CreateFS(cb, 10)
		lagStr:ClearAllPoints()
		lagStr:SetPoint("BOTTOM", cb, "TOP", 0, 2)
		cb.LagString = lagStr

		UF:ToggleCastBarLatency(self)

	elseif mystyle == "nameplate" then
		name:SetPoint("TOPLEFT", cb, "LEFT", 0, -1)
		timer:SetPoint("TOPRIGHT", cb, "RIGHT", 0, -1)

		local shield = cb:CreateTexture(nil, "OVERLAY")
		shield:SetAtlas("nameplates-InterruptShield")
		shield:SetSize(18, 18)
		shield:SetPoint("TOP", cb, "CENTER", 0, -1)
		cb.Shield = shield

		local iconSize = self:GetHeight()*2 + 5
		cb.Icon:SetSize(iconSize, iconSize)
		cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -5, 0)
		cb.timeToHold = .5

		cb.glowFrame = B.CreateGlowFrame(cb, iconSize)
		cb.glowFrame:SetPoint("CENTER", cb.Icon)

		local spellTarget = B.CreateFS(cb, C.db["Nameplate"]["NameTextSize"]+3)
		spellTarget:ClearAllPoints()
		spellTarget:SetJustifyH("LEFT")
		spellTarget:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
		cb.spellTarget = spellTarget

		self:RegisterEvent("UNIT_TARGET", updateSpellTarget)
	end

	local stage = B.CreateFS(cb, 22)
	stage:ClearAllPoints()
	stage:SetPoint("TOPLEFT", cb.Icon, -2, 2)
	cb.stageString = stage

	if mystyle == "nameplate" or mystyle == "boss" or mystyle == "arena" then
		cb.decimal = "%.1f"
	else
		cb.decimal = "%.2f"
	end

	cb.Time = timer
	cb.Text = name
	cb.OnUpdate = UF.OnCastbarUpdate
	cb.PostCastStart = UF.PostCastStart
	cb.PostCastUpdate = UF.PostCastUpdate
	cb.PostCastStop = UF.PostCastStop
	cb.PostCastFail = UF.PostCastFailed
	cb.PostCastInterruptible = UF.PostUpdateInterruptible
	cb.CreatePip = UF.CreatePip
	cb.PostUpdatePips = UF.PostUpdatePips

	self.Castbar = cb
end

function UF:CreateSparkleCastBar(self)
	if not C.db["UFs"]["PetCB"] then return end

	local bar = CreateFrame("StatusBar", "oUF_SparkleCastbar"..self.mystyle, self)
	bar:SetAllPoints(self.Power)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetStatusBarColor(1, 1, 1, .25)

	local spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(DB.sparkTex)
	spark:SetBlendMode("ADD")
	spark:SetAlpha(.8)
	spark:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
	spark:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)
	bar.Spark = spark

	self.Castbar = bar
end

function UF:ToggleCastBar(unit)
	if not self or not unit then return end

	if C.db["UFs"][unit.."CB"] and not self:IsElementEnabled("Castbar") then
		self:EnableElement("Castbar")
	elseif not C.db["UFs"][unit.."CB"] and self:IsElementEnabled("Castbar") then
		self:DisableElement("Castbar")
	end
end

local function reskinTimerBar(bar)
	bar:SetSize(280, 15)
	B.StripTextures(bar)

	local statusbar = bar.StatusBar or _G[bar:GetName().."StatusBar"]
	if statusbar then
		statusbar:SetAllPoints()
	elseif bar.SetStatusBarTexture then
		bar:SetStatusBarTexture(DB.normTex)
	end

	B.SetBD(bar)
end

function UF:ReskinMirrorBars()
	hooksecurefunc(MirrorTimerContainer, "SetupTimer", function(self, timer)
		local bar = self:GetAvailableTimer(timer)
		if not bar.styled then
			reskinTimerBar(bar)
			bar.styled = true
		end
	end)
end

function UF:ReskinTimerTrakcer(self)
	local function updateTimerTracker()
		for _, timer in pairs(TimerTracker.timerList) do
			if timer.bar and not timer.bar.styled then
				reskinTimerBar(timer.bar)

				timer.bar.styled = true
			end
		end
	end
	self:RegisterEvent("START_TIMER", updateTimerTracker, true)
end

-- Auras Relevant
function UF:UpdateIconTexCoord(width, height)
	local ratio = height / width
	local mult = (1 - ratio) / 2
	self.Icon:SetTexCoord(x1, x2, y1 + mult, y2 - mult)
end

function UF.PostCreateButton(element, button)
	local fontSize = element.fontSize or element.size*.6
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
	button.Count = B.CreateFS(parentFrame, fontSize, "", false, "BOTTOMRIGHT", 6, -3)
	button.Cooldown:SetReverse(true)
	local needShadow = true
	if element.__owner.mystyle == "raid" and not C.db["UFs"]["RaidBuffIndicator"] then
		needShadow = false
	end
	button.iconbg = B.ReskinIcon(button.Icon, needShadow)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .25)
	button.HL:SetAllPoints()

	button.Overlay:SetTexture(nil)
	button.Stealable:SetAtlas("bags-newitem")
	if AURA then
		button:HookScript("OnMouseDown", AURA.RemoveSpellFromIgnoreList)
	end

	if element.disableCooldown then
		hooksecurefunc(button, "SetSize", UF.UpdateIconTexCoord)
		button.timer = B.CreateFS(button, fontSize, "")
		button.timer:ClearAllPoints()
		button.timer:SetPoint("LEFT", button, "TOPLEFT", -2, 0)
		button.Count:ClearAllPoints()
		button.Count:SetPoint("RIGHT", button, "BOTTOMRIGHT", 5, 0)
	end
end

local filteredStyle = {
	["target"] = true,
	["nameplate"] = true,
	["boss"] = true,
	["arena"] = true,
}

UF.ReplacedSpellIcons = {
	[368078] = 348567, -- 移速
	[368079] = 348567, -- 移速
	[368103] = 648208, -- 急速
	[368243] = 237538, -- CD
	[373785] = 236293, -- S4，大魔王伪装
}

local dispellType = {
	["Magic"] = true,
	[""] = true,
}

function UF.PostUpdateButton(element, button, unit, data)
	local duration, expiration, debuffType = data.duration, data.expirationTime, data.dispelName

	if duration then button.iconbg:Show() end

	local style = element.__owner.mystyle
	if style == "nameplate" then
		button:SetSize(element.size, element.size * C.db["Nameplate"]["SizeRatio"])
	else
		button:SetSize(element.size, element.size)
	end

	if element.desaturateDebuff and button.isHarmful and filteredStyle[style] and not data.isPlayerAura then
		button.Icon:SetDesaturated(true)
	else
		button.Icon:SetDesaturated(false)
	end

	if element.showDebuffType and button.isHarmful then
		local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		button.iconbg:SetBackdropBorderColor(color[1], color[2], color[3])
	else
		button.iconbg:SetBackdropBorderColor(0, 0, 0)
	end

	if element.alwaysShowStealable and dispellType[debuffType] and not UnitIsPlayer(unit) and (not button.isHarmful) then
		button.Stealable:Show()
	end

	if element.disableCooldown then
		if duration and duration > 0 then
			button.expiration = expiration
			button:SetScript("OnUpdate", B.CooldownOnUpdate)
			button.timer:Show()
		else
			button:SetScript("OnUpdate", nil)
			button.timer:Hide()
		end
	end

	local newTexture = UF.ReplacedSpellIcons[button.spellID]
	if newTexture then
		button.Icon:SetTexture(newTexture)
	end

	if element.bolsterInstanceID and element.bolsterInstanceID == button.auraInstanceID then
		button.Count:SetText(element.bolsterStacks)
	end
end

function UF.AurasPostUpdateInfo(element, _, _, debuffsChanged)
	element.bolsterStacks = 0
	element.bolsterInstanceID = nil

	for auraInstanceID, data in next, element.allBuffs do
		if data.spellId == 209859 then
			if not element.bolsterInstanceID then
				element.bolsterInstanceID = auraInstanceID
				element.activeBuffs[auraInstanceID] = true
			end
			element.bolsterStacks = element.bolsterStacks + 1
			if element.bolsterStacks > 1 then
				element.activeBuffs[auraInstanceID] = nil
			end
		end
	end
	if element.bolsterStacks > 0 then
		for i = 1, element.visibleButtons do
			local button = element[i]
			if element.bolsterInstanceID and element.bolsterInstanceID == button.auraInstanceID then
				button.Count:SetText(element.bolsterStacks)
				break
			end
		end
	end

	if debuffsChanged then
		element.hasTheDot = nil
		if C.db["Nameplate"]["ColorByDot"] then
			for _, data in next, element.allDebuffs do
				if data.isPlayerAura and C.db["Nameplate"]["DotSpells"][data.spellId] then
					element.hasTheDot = true
					break
				end
			end
		end
	end
end

function UF.PostUpdateGapButton(_, _, button)
	if button.iconbg and button.iconbg:IsShown() then
		button.iconbg:Hide()
	end
end

function UF.CustomFilter(element, unit, data)
	local style = element.__owner.mystyle
	local name, debuffType, isStealable, spellID, nameplateShowAll = data.name, data.dispelName, data.isStealable, data.spellId, data.nameplateShowAll

	if style == "nameplate" or style == "boss" or style == "arena" then
		if name and spellID == 209859 then -- pass all bolster
			return true
		end
		if element.__owner.plateType == "NameOnly" then
			return UF.NameplateWhite[spellID]
		elseif UF.NameplateBlack[spellID] then
			return false
		elseif (element.showStealableBuffs and isStealable or element.alwaysShowStealable and dispellType[debuffType]) and not UnitIsPlayer(unit) and (not data.isHarmful) then
			return true
		elseif UF.NameplateWhite[spellID] then
			return true
		else
			local auraFilter = C.db["Nameplate"]["AuraFilter"]
			return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and data.isPlayerAura)
		end
	else
		return (element.onlyShowPlayer and data.isPlayerAura) or (not element.onlyShowPlayer and name)
	end
end

function UF.UnitCustomFilter(element, _, data)
	local value = element.__value
	if data.isHarmful then
		if C.db["UFs"][value.."DebuffType"] == 2 then
			return data.name
		elseif C.db["UFs"][value.."DebuffType"] == 3 then
			return data.isPlayerAura
		end
	else
		if C.db["UFs"][value.."BuffType"] == 2 then
			return data.name
		elseif C.db["UFs"][value.."BuffType"] == 3 then
			return data.isStealable
		end
	end
end

local function auraIconSize(w, n, s)
	return (w-(n-1)*s)/n
end

function UF:UpdateAuraContainer(parent, element, maxAuras)
	local width = parent:GetWidth()
	local iconsPerRow = element.iconsPerRow
	local maxLines = iconsPerRow and B:Round(maxAuras/iconsPerRow) or 2
	element.size = iconsPerRow and auraIconSize(width, iconsPerRow, element.spacing) or element.size
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)

	local fontSize = element.fontSize or element.size*.6
	for i = 1, #element do
		local button = element[i]
		if button then
			if button.timer then B.SetFontSize(button.timer, fontSize) end
			if button.Count then B.SetFontSize(button.Count, fontSize) end
		end
	end
end

function UF:ConfigureAuras(element)
	local value = element.__value
	element.numBuffs = C.db["UFs"][value.."BuffType"] ~= 1 and C.db["UFs"][value.."NumBuff"] or 0
	element.numDebuffs = C.db["UFs"][value.."DebuffType"] ~= 1 and C.db["UFs"][value.."NumDebuff"] or 0
	element.iconsPerRow = C.db["UFs"][value.."AurasPerRow"]
	element.showDebuffType = C.db["UFs"]["DebuffColor"]
	element.desaturateDebuff = C.db["UFs"]["Desaturate"]
end

function UF:RefreshUFAuras(frame)
	if not frame then return end
	local element = frame.Auras
	if not element then return end

	UF:ConfigureAuras(element)
	UF:UpdateAuraContainer(frame, element, element.numBuffs + element.numDebuffs)
	UF:UpdateAuraDirection(frame, element)
	element:ForceUpdate()
end

function UF:ConfigureBuffAndDebuff(element, isDebuff)
	local value = element.__value
	local vType = isDebuff and "Debuff" or "Buff"
	element.num = C.db["UFs"][value..vType.."Type"] ~= 1 and C.db["UFs"][value.."Num"..vType] or 0
	element.iconsPerRow = C.db["UFs"][value..vType.."PerRow"]
	element.showDebuffType = C.db["UFs"]["DebuffColor"]
	element.desaturateDebuff = C.db["UFs"]["Desaturate"]
end

function UF:RefreshBuffAndDebuff(frame)
	if not frame then return end

	local element = frame.Buffs
	if element then
		UF:ConfigureBuffAndDebuff(element)
		UF:UpdateAuraContainer(frame, element, element.num)
		element:ForceUpdate()
	end

	local element = frame.Debuffs
	if element then
		UF:ConfigureBuffAndDebuff(element, true)
		UF:UpdateAuraContainer(frame, element, element.num)
		element:ForceUpdate()
	end
end

function UF:UpdateUFAuras()
	UF:RefreshUFAuras(_G.oUF_Player)
	UF:RefreshUFAuras(_G.oUF_Target)
	UF:RefreshUFAuras(_G.oUF_Focus)
	UF:RefreshUFAuras(_G.oUF_ToT)
	UF:RefreshUFAuras(_G.oUF_Pet)

	for i = 1, 5 do
		UF:RefreshBuffAndDebuff(_G["oUF_Boss"..i])
		UF:RefreshBuffAndDebuff(_G["oUF_Arena"..i])
	end
end

function UF:ToggleUFAuras(frame, enable)
	if not frame then return end
	if enable then
		if not frame:IsElementEnabled("Auras") then
			frame:EnableElement("Auras")
		end
	else
		if frame:IsElementEnabled("Auras") then
			frame:DisableElement("Auras")
			frame.Auras:ForceUpdate()
		end
	end
end

function UF:ToggleAllAuras()
	local enable = C.db["UFs"]["ShowAuras"]
	UF:ToggleUFAuras(_G.oUF_Player, enable)
	UF:ToggleUFAuras(_G.oUF_Target, enable)
	UF:ToggleUFAuras(_G.oUF_Focus, enable)
	UF:ToggleUFAuras(_G.oUF_ToT, enable)
end

UF.AuraDirections = {
	[1] = {name = L["RIGHT_DOWN"], initialAnchor = "TOPLEFT", relAnchor = "BOTTOMLEFT", x = 0, y = -1, growthX = "RIGHT", growthY = "DOWN"},
	[2] = {name = L["RIGHT_UP"], initialAnchor = "BOTTOMLEFT", relAnchor = "TOPLEFT", x = 0, y = 1, growthX = "RIGHT", growthY = "UP"},
	[3] = {name = L["LEFT_DOWN"], initialAnchor = "TOPRIGHT", relAnchor = "BOTTOMRIGHT", x = 0, y = -1, growthX = "LEFT", growthY = "DOWN"},
	[4] = {name = L["LEFT_UP"], initialAnchor = "BOTTOMRIGHT", relAnchor = "TOPRIGHT", x = 0, y = 1, growthX = "LEFT", growthY = "UP"},
}

function UF:UpdateAuraDirection(self, element)
	local direc = C.db["UFs"][element.__value.."AuraDirec"]
	local yOffset = C.db["UFs"][element.__value.."AuraOffset"]
	local value = UF.AuraDirections[direc]
	element.initialAnchor = value.initialAnchor
	element["growth-x"] = value.growthX
	element["growth-y"] = value.growthY
	element:ClearAllPoints()
	element:SetPoint(value.initialAnchor, self, value.relAnchor, value.x, value.y * yOffset)
end

local auraUFs = {
	["player"] = "Player",
	["target"] = "Target",
	["tot"] = "ToT",
	["pet"] = "Pet",
	["focus"] = "Focus",
}
function UF:CreateAuras(self)
	local mystyle = self.mystyle
	local bu = CreateFrame("Frame", nil, self)
	bu:SetFrameLevel(self:GetFrameLevel() + 2)
	bu.gap = true
	bu.initialAnchor = "TOPLEFT"
	bu["growth-y"] = "DOWN"
	bu.spacing = 3
	bu.tooltipAnchor = "ANCHOR_BOTTOMLEFT"
	if auraUFs[mystyle] then
		bu.__value = auraUFs[mystyle]
		UF:ConfigureAuras(bu)
		UF:UpdateAuraDirection(self, bu)
		bu.FilterAura = UF.UnitCustomFilter
	elseif mystyle == "nameplate" then
		bu.initialAnchor = "BOTTOMLEFT"
		bu["growth-y"] = "UP"
		if C.db["Nameplate"]["TargetPower"] then
			bu:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 10 + C.db["Nameplate"]["PPBarHeight"])
		else
			bu:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
		end
		bu.numTotal = C.db["Nameplate"]["maxAuras"]
		bu.size = C.db["Nameplate"]["AuraSize"]
		bu.fontSize = C.db["Nameplate"]["FontSize"]
		bu.showDebuffType = C.db["Nameplate"]["DebuffColor"]
		bu.desaturateDebuff = C.db["Nameplate"]["Desaturate"]
		bu.gap = false
		bu.disableMouse = true
		bu.disableCooldown = true
		bu.FilterAura = UF.CustomFilter
		bu.PostUpdateInfo = UF.AurasPostUpdateInfo
	end

	UF:UpdateAuraContainer(self, bu, bu.numTotal or bu.numBuffs + bu.numDebuffs)
	bu.showStealableBuffs = true
	bu.PostCreateButton = UF.PostCreateButton
	bu.PostUpdateButton = UF.PostUpdateButton
	bu.PostUpdateGapButton = UF.PostUpdateGapButton

	self.Auras = bu
end

function UF:CreateBuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	bu:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
	bu.initialAnchor = "BOTTOMLEFT"
	bu["growth-x"] = "RIGHT"
	bu["growth-y"] = "UP"
	bu.spacing = 3
	bu.tooltipAnchor = "ANCHOR_BOTTOMLEFT"

	bu.__value = "Boss"
	UF:ConfigureBuffAndDebuff(bu)
	bu.FilterAura = UF.UnitCustomFilter

	UF:UpdateAuraContainer(self, bu, bu.num)
	bu.showStealableBuffs = true
	bu.PostCreateButton = UF.PostCreateButton
	bu.PostUpdateButton = UF.PostUpdateButton

	self.Buffs = bu
end

function UF:CreateDebuffs(self)
	local mystyle = self.mystyle
	local bu = CreateFrame("Frame", nil, self)
	bu.spacing = 3
	bu.initialAnchor = "TOPRIGHT"
	bu["growth-x"] = "LEFT"
	bu["growth-y"] = "DOWN"
	bu.tooltipAnchor = "ANCHOR_BOTTOMLEFT"
	bu.showDebuffType = true
	bu:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
	bu.__value = "Boss"
	UF:ConfigureBuffAndDebuff(bu, true)
	bu.FilterAura = UF.UnitCustomFilter

	UF:UpdateAuraContainer(self, bu, bu.num)
	bu.PostCreateButton = UF.PostCreateButton
	bu.PostUpdateButton = UF.PostUpdateButton

	self.Debuffs = bu
end

-- Class Powers
function UF.PostUpdateClassPower(element, cur, max, diff, powerType, chargedPowerPoints)
	if not cur or cur == 0 then
		for i = 1, 7 do
			element[i].bg:Hide()
		end

		element.prevColor = nil
	else
		for i = 1, max do
			element[i].bg:Show()
		end

		element.thisColor = cur == max and 1 or 2
		if not element.prevColor or element.prevColor ~= element.thisColor then
			local r, g, b = 1, 0, 0
			if element.thisColor == 2 then
				local color = element.__owner.colors.power[powerType]
				r, g, b = color[1], color[2], color[3]
			end
			for i = 1, #element do
				element[i]:SetStatusBarColor(r, g, b)
			end
			element.prevColor = element.thisColor
		end
	end

	if diff then
		for i = 1, max do
			element[i]:SetWidth((element.__owner.ClassPowerBar:GetWidth() - (max-1)*C.margin)/max)
		end
		for i = max + 1, 7 do
			element[i].bg:Hide()
		end
	end

	for i = 1, 7 do
		local bar = element[i]
		if not bar.chargeStar then break end

		bar.chargeStar:SetShown(chargedPowerPoints and tContains(chargedPowerPoints, i))
	end
end

function UF:OnUpdateRunes(elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
	self.timer:SetText("")
	if C.db["UFs"]["RuneTimer"] then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(B.FormatTime(remain))
		end
	end
end

function UF.PostUpdateRunes(element, runemap)
	for index, runeID in next, runemap do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				rune.timer:SetText("")
			elseif start then
				rune:SetAlpha(.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", UF.OnUpdateRunes)
			end
		end
	end
end

function UF:CreateClassPower(self)
	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local barPoint = {"BOTTOMLEFT", self, "TOPLEFT", C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]}
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, C.margin}
	elseif self.mystyle == "targetplate" then
		barWidth, barHeight = C.db["Nameplate"]["PlateWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"CENTER", self}
	end

	local isDK = DB.MyClass == "DEATHKNIGHT"
	local maxBar = isDK and 6 or 7
	local bar = CreateFrame("Frame", "$parentClassPowerBar", self.Health)
	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))

	-- show bg while size changed
	if not isDK then
		bar.bg = B.SetBD(bar)
		bar.bg:SetFrameLevel(5)
		bar.bg:SetBackdropBorderColor(1, .8, 0)
		bar.bg:Hide()
	end

	local bars = {}
	for i = 1, maxBar do
		bars[i] = CreateFrame("StatusBar", nil, bar)
		bars[i]:SetHeight(barHeight)
		bars[i]:SetWidth((barWidth - (maxBar-1)*C.margin) / maxBar)
		bars[i]:SetStatusBarTexture(DB.normTex)
		bars[i]:SetFrameLevel(self:GetFrameLevel() + 5)
		B.SetBD(bars[i], 0)
		if i == 1 then
			bars[i]:SetPoint("BOTTOMLEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", C.margin, 0)
		end

		bars[i].bg = (isDK and bars[i] or bar):CreateTexture(nil, "BACKGROUND")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(DB.normTex)
		bars[i].bg.multiplier = .25

		if isDK then
			bars[i].timer = B.CreateFS(bars[i], 13, "")
		else
			if not bar.chargeParent then
				bar.chargeParent = CreateFrame("Frame", nil, bar)
				bar.chargeParent:SetAllPoints()
				bar.chargeParent:SetFrameLevel(8)
			end
			local chargeStar = bar.chargeParent:CreateTexture()
			chargeStar:SetTexture(DB.starTex)
			chargeStar:SetSize(12, 12)
			chargeStar:SetPoint("CENTER", bars[i])
			chargeStar:Hide()
			bars[i].chargeStar = chargeStar
		end
	end

	if isDK then
		bars.colorSpec = true
		bars.sortOrder = "asc"
		bars.PostUpdate = UF.PostUpdateRunes
		bars.__max = 6
		self.Runes = bars
	else
		bars.PostUpdate = UF.PostUpdateClassPower
		self.ClassPower = bars
	end

	self.ClassPowerBar = bar
end

function UF:StaggerBar(self)
	if DB.MyClass ~= "MONK" then return end

	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local barPoint = {"BOTTOMLEFT", self, "TOPLEFT", C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]}
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, C.margin}
	end

	local stagger = CreateFrame("StatusBar", nil, self.Health)
	stagger:SetSize(barWidth, barHeight)
	stagger:SetPoint(unpack(barPoint))
	stagger:SetStatusBarTexture(DB.normTex)
	stagger:SetFrameLevel(self:GetFrameLevel() + 5)
	B.SetBD(stagger, 0)

	local bg = stagger:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	local text = B.CreateFS(stagger, 13)
	text:SetPoint("CENTER", stagger, "TOP")
	self:Tag(text, "[monkstagger]")

	self.Stagger = stagger
	self.Stagger.bg = bg
end

function UF:ToggleUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	if C.db["UFs"]["ClassPower"] then
		if playerFrame.ClassPower then
			if not playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:EnableElement("ClassPower")
				playerFrame.ClassPower:ForceUpdate()
			end
		end
		if playerFrame.Runes then
			if not playerFrame:IsElementEnabled("Runes") then
				playerFrame:EnableElement("Runes")
				playerFrame.Runes:ForceUpdate()
			end
		end
		if playerFrame.Stagger then
			if not playerFrame:IsElementEnabled("Stagger") then
				playerFrame:EnableElement("Stagger")
				playerFrame.Stagger:ForceUpdate()
			end
		end
	else
		if playerFrame.ClassPower then
			if playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:DisableElement("ClassPower")
			end
		end
		if playerFrame.Runes then
			if playerFrame:IsElementEnabled("Runes") then
				playerFrame:DisableElement("Runes")
			end
		end
		if playerFrame.Stagger then
			if playerFrame:IsElementEnabled("Stagger") then
				playerFrame:DisableElement("Stagger")
			end
		end
	end
end

function UF:UpdateUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local xOffset, yOffset = C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]
	local bars = playerFrame.ClassPower or playerFrame.Runes
	if bars then
		local bar = playerFrame.ClassPowerBar
		bar:SetSize(barWidth, barHeight)
		bar:SetPoint("BOTTOMLEFT", playerFrame, "TOPLEFT", xOffset, yOffset)
		if bar.bg then bar.bg:Show() end
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max-1)*C.margin) / max)
		end
	end

	if playerFrame.Stagger then
		playerFrame.Stagger:SetSize(barWidth, barHeight)
		playerFrame.Stagger:SetPoint("BOTTOMLEFT", playerFrame, "TOPLEFT", xOffset, yOffset)
	end
end

function UF.PostUpdateAltPower(element, _, cur, _, max)
	if cur and max then
		local perc = floor((cur/max)*100)
		if perc < 35 then
			element:SetStatusBarColor(0, 1, 0)
		elseif perc < 70 then
			element:SetStatusBarColor(1, 1, 0)
		else
			element:SetStatusBarColor(1, 0, 0)
		end
	end
end

function UF:CreateAltPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	bar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	bar:SetHeight(2)
	B.SetBD(bar, 0)

	local text = B.CreateFS(bar, 14, "")
	text:SetJustifyH("CENTER")
	self:Tag(text, "[altpower]")

	self.AlternativePower = bar
	self.AlternativePower.PostUpdate = UF.PostUpdateAltPower
end

function UF:CreateExpRepBar(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
	bar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 10, 0)
	bar:SetOrientation("VERTICAL")
	B.CreateSB(bar)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints(bar)
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .4, 1, .6)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	rest:SetOrientation("VERTICAL")
	bar.restBar = rest

	B:GetModule("Misc"):SetupScript(bar)
end

function UF:PostUpdatePrediction(_, health, maxHealth, allIncomingHeal, allAbsorb)
	if not C.db["UFs"]["OverAbsorb"] then
		self.overAbsorbBar:Hide()
		return
	end

	local hasOverAbsorb
	local overAbsorbAmount = health + allIncomingHeal + allAbsorb - maxHealth
	if overAbsorbAmount > 0 then
		if overAbsorbAmount > maxHealth then
			hasOverAbsorb = true
			overAbsorbAmount = maxHealth
		end
		self.overAbsorbBar:SetMinMaxValues(0, maxHealth)
		self.overAbsorbBar:SetValue(overAbsorbAmount)
		self.overAbsorbBar:Show()
	else
		self.overAbsorbBar:Hide()
	end

	if hasOverAbsorb then
		self.overAbsorb:Show()
	else
		self.overAbsorb:Hide()
	end
end

function UF:CreatePrediction(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints(self.Health)
	frame:SetClipsChildren(true)
	local frameLevel = frame:GetFrameLevel()-1

	-- Position and size
	local myBar = CreateFrame("StatusBar", nil, frame)
	myBar:SetPoint("TOP")
	myBar:SetPoint("BOTTOM")
	myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
	myBar:SetStatusBarTexture(DB.normTex)
	myBar:SetStatusBarColor(0, 1, .5, .5)
	myBar:Hide()

	local otherBar = CreateFrame("StatusBar", nil, frame)
	otherBar:SetPoint("TOP")
	otherBar:SetPoint("BOTTOM")
	otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
	otherBar:SetStatusBarTexture(DB.normTex)
	otherBar:SetStatusBarColor(0, 1, 0, .5)
	otherBar:Hide()

	local absorbBar = CreateFrame("StatusBar", nil, frame)
	absorbBar:SetPoint("TOP")
	absorbBar:SetPoint("BOTTOM")
	absorbBar:SetPoint("LEFT", otherBar:GetStatusBarTexture(), "RIGHT")
	absorbBar:SetStatusBarTexture(DB.bdTex)
	absorbBar:SetStatusBarColor(.66, 1, 1)
	absorbBar:SetFrameLevel(frameLevel)
	absorbBar:SetAlpha(.5)
	absorbBar:Hide()
	local tex = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
	tex:SetAllPoints(absorbBar:GetStatusBarTexture())
	tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	tex:SetHorizTile(true)
	tex:SetVertTile(true)

	local overAbsorbBar = CreateFrame("StatusBar", nil, frame)
	overAbsorbBar:SetAllPoints()
	overAbsorbBar:SetStatusBarTexture(DB.bdTex)
	overAbsorbBar:SetStatusBarColor(.66, 1, 1)
	overAbsorbBar:SetFrameLevel(frameLevel)
	overAbsorbBar:SetAlpha(.35)
	overAbsorbBar:Hide()
	local tex = overAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
	tex:SetAllPoints(overAbsorbBar:GetStatusBarTexture())
	tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	tex:SetHorizTile(true)
	tex:SetVertTile(true)

	local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
	healAbsorbBar:SetPoint("TOP")
	healAbsorbBar:SetPoint("BOTTOM")
	healAbsorbBar:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:SetStatusBarTexture(DB.bdTex)
	healAbsorbBar:SetStatusBarColor(1, 0, .5)
	healAbsorbBar:SetFrameLevel(frameLevel)
	healAbsorbBar:SetAlpha(.35)
	healAbsorbBar:Hide()
	local tex = healAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
	tex:SetAllPoints(healAbsorbBar:GetStatusBarTexture())
	tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	tex:SetHorizTile(true)
	tex:SetVertTile(true)

	local overAbsorb = self.Health:CreateTexture(nil, "OVERLAY")
	overAbsorb:SetWidth(15)
	overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	overAbsorb:SetBlendMode("ADD")
	overAbsorb:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
	overAbsorb:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)
	overAbsorb:Hide()

	local overHealAbsorb = frame:CreateTexture(nil, "OVERLAY")
	overHealAbsorb:SetWidth(15)
	overHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
	overHealAbsorb:SetBlendMode("ADD")
	overHealAbsorb:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
	overHealAbsorb:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)
	overHealAbsorb:Hide()

	-- Register with oUF
	self.HealthPrediction = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorbBar = overAbsorbBar,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		maxOverflow = 1,
		PostUpdate = UF.PostUpdatePrediction,
	}
	self.predicFrame = frame
end

function UF.PostUpdateAddPower(element, cur, max)
	if element.Text and max > 0 then
		local perc = cur/max * 100
		if perc > 95 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = format("%d%%", perc)
			element:SetAlpha(1)
		end
		element.Text:SetText(perc)
	end
end

function UF:CreateAddPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	bar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	bar:SetHeight(4)
	bar:SetStatusBarTexture(DB.normTex)
	B.SetBD(bar, 0)
	bar.colorPower = true
	B:SmoothBar(bar)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25
	local text = B.CreateFS(bar, 12, "", false, "CENTER", 1, -3)

	self.AdditionalPower = bar
	self.AdditionalPower.bg = bg
	self.AdditionalPower.Text = text
	self.AdditionalPower.PostUpdate = UF.PostUpdateAddPower
	self.AdditionalPower.displayPairs = {
		["DRUID"] = {
			[1] = true,
			[3] = true,
			[8] = true,
		},
		["SHAMAN"] = {
			[11] = true,
		},
		["PRIEST"] = {
			[13] = true,
		}
	}
end

function UF:ToggleAddPower()
	local frame = _G.oUF_Player
	if not frame then return end

	if C.db["UFs"]["AddPower"] then
		if not frame:IsElementEnabled("AdditionalPower") then
			frame:EnableElement("AdditionalPower")
			frame.AdditionalPower:ForceUpdate()
		end
	elseif frame:IsElementEnabled("AdditionalPower") then
		frame:DisableElement("AdditionalPower")
	end
end

function UF:ToggleSwingBars()
	local frame = _G.oUF_Player
	if not frame then return end

	if C.db["UFs"]["SwingBar"] then
		if not frame:IsElementEnabled("Swing") then
			frame:EnableElement("Swing")
		end
	elseif frame:IsElementEnabled("Swing") then
		frame:DisableElement("Swing")
	end
end

function UF:CreateSwing(self)
	local width, height = C.db["UFs"]["SwingWidth"], C.db["UFs"]["SwingHeight"]

	local bar = CreateFrame("Frame", nil, self)
	bar:SetSize(width, height)
	bar.mover = B.Mover(bar, L["UFs SwingBar"], "Swing", {"BOTTOM", UIParent, "BOTTOM", 0, 170})
	bar:ClearAllPoints()
	bar:SetPoint("CENTER", bar.mover)

	local two = CreateFrame("StatusBar", nil, bar)
	two:Hide()
	two:SetAllPoints()
	B.CreateSB(two, true, .8, .8, .8)

	local main = CreateFrame("StatusBar", nil, bar)
	main:Hide()
	main:SetAllPoints()
	B.CreateSB(main, true, .8, .8, .8)

	local off = CreateFrame("StatusBar", nil, bar)
	off:Hide()
	if C.db["UFs"]["OffOnTop"] then
		off:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 3)
		off:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 3)
	else
		off:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -3)
		off:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -3)
	end
	off:SetHeight(height)
	B.CreateSB(off, true, .8, .8, .8)

	bar.Text = B.CreateFS(bar, 12, "")
	bar.Text:SetShown(C.db["UFs"]["SwingTimer"])
	bar.TextMH = B.CreateFS(main, 12, "")
	bar.TextMH:SetShown(C.db["UFs"]["SwingTimer"])
	bar.TextOH = B.CreateFS(off, 12, "")
	bar.TextOH:SetShown(C.db["UFs"]["SwingTimer"])

	self.Swing = bar
	self.Swing.Twohand = two
	self.Swing.Mainhand = main
	self.Swing.Offhand = off
	self.Swing.hideOoc = true
end

local scrolls = {}
function UF:UpdateScrollingFont()
	local fontSize = C.db["UFs"]["FCTFontSize"]
	for _, scroll in pairs(scrolls) do
		B.SetFontSize(scroll, fontSize)
		scroll:SetSize(10*fontSize, 10*fontSize)
	end
end

function UF:CreateFCT(self)
	if not C.db["UFs"]["CombatText"] then return end

	local parentFrame = CreateFrame("Frame", nil, UIParent)
	local parentName = self:GetName()
	local fcf = CreateFrame("Frame", parentName.."CombatTextFrame", parentFrame)
	fcf:SetSize(32, 32)
	if self.mystyle == "player" then
		B.Mover(fcf, L["CombatText"], "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})
	else
		B.Mover(fcf, L["CombatText"], "TargetCombatText", {"BOTTOM", self, "TOPRIGHT", 0, 120})
	end

	for i = 1, 36 do
		fcf[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
	end

	local scrolling = CreateFrame("ScrollingMessageFrame", parentName.."CombatTextScrollingFrame", parentFrame)
	scrolling:SetSpacing(3)
	scrolling:SetMaxLines(20)
	scrolling:SetFadeDuration(.2)
	scrolling:SetTimeVisible(3)
	scrolling:SetJustifyH("CENTER")
	scrolling:SetPoint("BOTTOM", fcf)
	fcf.Scrolling = scrolling
	tinsert(scrolls, scrolling)

	fcf.font = DB.Font[1]
	fcf.fontFlags = DB.Font[3]
	fcf.abbreviateNumbers = true
	self.FloatingCombatFeedback = fcf

	-- Default CombatText
	SetCVar("enableFloatingCombatText", 0)
end

function UF:CreatePVPClassify(self)
	local bu = self:CreateTexture(nil, "ARTWORK")
	bu:SetSize(30, 30)
	bu:SetPoint("LEFT", self, "RIGHT", 5, -2)

	self.PvPClassificationIndicator = bu
end

local function updatePartySync(self)
	local hasJoined = C_QuestSession.HasJoined()
	if(hasJoined) then
		self.QuestSyncIndicator:Show()
	else
		self.QuestSyncIndicator:Hide()
	end
end

function UF:CreateQuestSync(self)
	local sync = self:CreateTexture(nil, "OVERLAY")
	sync:SetPoint("CENTER", self, "BOTTOMLEFT", 16, 0)
	sync:SetSize(28, 28)
	sync:SetAtlas("QuestSharing-DialogIcon")
	sync:Hide()

	self.QuestSyncIndicator = sync
	self:RegisterEvent("QUEST_SESSION_LEFT", updatePartySync, true)
	self:RegisterEvent("QUEST_SESSION_JOINED", updatePartySync, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", updatePartySync, true)
end

-- Demonic Gateway
local GatewayTexs = {
	[59262] = 607512, -- green
	[59271] = 607513, -- purple
}
local function DGI_UpdateGlow()
	local frame = _G.oUF_Focus
	if not frame then return end

	local element = frame.DemonicGatewayIndicator
	if element:IsShown() and IsItemInRange(37727, "focus") then
		B.ShowOverlayGlow(element.glowFrame)
	else
		B.HideOverlayGlow(element.glowFrame)
	end
end

local function DGI_Visibility()
	local frame = _G.oUF_Focus
	if not frame then return end

	local element = frame.DemonicGatewayIndicator
	local guid = UnitGUID("focus")
	local npcID = guid and B.GetNPCID(guid)
	local isGate = npcID and GatewayTexs[npcID]

	element:SetTexture(isGate)
	element:SetShown(isGate)
	element.updater:SetShown(isGate)
	DGI_UpdateGlow()
end

local function DGI_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		DGI_UpdateGlow()

		self.elapsed = 0
	end
end

function UF:DemonicGatewayIcon(self)
	local icon = self:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("CENTER")
	icon:SetSize(22, 22)
	icon:SetTexture(607512) -- 607513 for purple
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon.glowFrame = B.CreateGlowFrame(self, 22)

	local updater = CreateFrame("Frame")
	updater:SetScript("OnUpdate", DGI_OnUpdate)
	updater:Hide()

	self.DemonicGatewayIndicator = icon
	self.DemonicGatewayIndicator.updater = updater
	B:RegisterEvent("PLAYER_FOCUS_CHANGED", DGI_Visibility)
end