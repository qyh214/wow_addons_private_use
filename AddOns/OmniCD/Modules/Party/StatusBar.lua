local E = select(2, ...):unpack()
local P = E.Party

local format, ceil, floor, min, GetTime = string.format, math.ceil, math.floor, math.min, GetTime

local CASTING_BAR_ALPHA_STEP = 0.05;
local CASTING_BAR_HOLD_TIME = 1;
local SECONDS_PER_MIN = 60

local activeStatusBars = {}
local inactiveStatusBars = {}
local numActiveStatusBars = 0

local StatusBarFrameMixin = {}

function StatusBarFrameMixin:Release()
	self:Hide()
	inactiveStatusBars[#inactiveStatusBars + 1] = self
	activeStatusBars[self] = nil
	numActiveStatusBars = numActiveStatusBars - 1
end

function StatusBarFrameMixin:ApplySettings(db)
	self:SetWidth(db.statusBarWidth)
	self:SetColors(db)

	local text = self.Text
	text:ClearAllPoints()
	if db.nameBar and db.invertNameBar then
		text:SetPoint("TOPLEFT", self.icon, "TOPLEFT", -db.statusBarWidth + db.textOfsX, db.textOfsY)
		text:SetPoint("BOTTOMRIGHT", self.icon, "BOTTOMLEFT", -db.textOfsX, db.textOfsY)
		text:SetJustifyH("RIGHT")
	else
		text:SetPoint("LEFT", self, db.textOfsX, db.textOfsY)
		text:SetPoint("RIGHT", self, -3, db.textOfsY)
		text:SetJustifyH("LEFT")
	end
	text:SetScale(db.textScale)

	local castingBar = self.CastingBar
	castingBar.Timer:SetPoint("RIGHT", castingBar, -3, db.textOfsY)
	castingBar.Text:SetPoint("LEFT", castingBar, db.textOfsX, db.textOfsY)
	castingBar.Text:SetScale(db.textScale)
end

function StatusBarFrameMixin:SetColors(db)
	local icon = self.icon
	local info = P.groupInfo[icon.guid]
	if not info then
		return
	end

	db = db or E.db.extraBars[self.key]

	if info.isDeadOrOffline then
		if icon.active then
			local castingBar = self.CastingBar
			castingBar:SetStatusBarColor(0.3, 0.3, 0.3)
			castingBar.BG:SetVertexColor(0.3, 0.3, 0.3)
			castingBar.Text:SetVertexColor(0.3, 0.3, 0.3)
		end

		self.Text:SetTextColor(0.3, 0.3, 0.3)
		self.BG:SetVertexColor(0.3, 0.3, 0.3)
	elseif db.nameBar then
		if icon.active then
			local castingBar = self.CastingBar
			local startColor, startBGColor, startTextColor = castingBar:GetEffectiveStartColor(castingBar.channeling)
			self.Text:SetTextColor(startTextColor:GetRGB())
		else
			local classColor = RAID_CLASS_COLORS[icon.class]
			local c = db.textColors.useClassColor.inactive and classColor or db.textColors.inactiveColor
			self.Text:SetTextColor(c.r, c.g, c.b)
		end
	else
		if icon.active then
			local castingBar = self.CastingBar
			local startColor, startBGColor, startTextColor = castingBar:GetEffectiveStartColor(castingBar.channeling)
			castingBar:SetStatusBarColor(startColor:GetRGBA())
			castingBar.BG:SetVertexColor(startBGColor:GetRGBA())
			castingBar.Text:SetTextColor(startTextColor:GetRGB())
		end

		local classColor = RAID_CLASS_COLORS[icon.class]
		local c = db.textColors.useClassColor.inactive and classColor or db.textColors.inactiveColor
		self.Text:SetTextColor(c.r, c.g, c.b)
		if info.preactiveIcons[icon.spellID] and not E.forbearanceIDs[icon.spellID] then
			self.BG:SetVertexColor(0.7, 0.7, 0.7)
		else
			c = db.barColors.useClassColor.inactive and classColor or db.barColors.inactiveColor
			self.BG:SetVertexColor(c.r, c.g, c.b, db.useIconAlpha and 1 or db.barColors.inactiveColor.a)
		end
	end

	self.Text:SetShown(db.nameBar or not icon.active)
	self.BG:SetShown(not db.nameBar and not icon.active)
end

local CastingBarFrameMixin = {}

function CastingBarFrameMixin:SetStartCastColor(r, g, b, a)
	self.startCastColor = CreateColor(r, g, b, a);
end

function CastingBarFrameMixin:SetStartChannelColor(r, g, b, a)
	self.startChannelColor = CreateColor(r, g, b, a);
end

function CastingBarFrameMixin:SetStartRechargeColor(r, g, b, a)
	self.startRechargeColor = CreateColor(r, g, b, a);
end

function CastingBarFrameMixin:SetFinishedCastColor(r, g, b)
	self.finishedCastColor = CreateColor(r, g, b);
end

function CastingBarFrameMixin:SetFailedCastColor(r, g, b)
	self.failedCastColor = CreateColor(r, g, b);
end

function CastingBarFrameMixin:SetNonInterruptibleCastColor(r, g, b)
	self.nonInterruptibleColor = CreateColor(r, g, b);
end

function CastingBarFrameMixin:SetUseStartColorForFinished(finishedColorSameAsStart)
	self.finishedColorSameAsStart = finishedColorSameAsStart;
end

function CastingBarFrameMixin:SetUseStartColorForFlash(flashColorSameAsStart)
	self.flashColorSameAsStart = flashColorSameAsStart;
end

function CastingBarFrameMixin:SetStartCastBGColor(r, g, b, a)
	self.startCastBGColor = CreateColor(r, g, b, a);
end

function CastingBarFrameMixin:SetStartChannelBGColor(r, g, b, a)
	self.startChannelBGColor = CreateColor(r, g, b, a);
end

function CastingBarFrameMixin:SetStartRechargeBGColor(r, g, b, a)
	self.startRechargeBGColor = CreateColor(r, g, b, a);
end

function CastingBarFrameMixin:SetStartCastTextColor(r, g, b)
	self.startCastTextColor = CreateColor(r, g, b);
end

function CastingBarFrameMixin:SetStartChannelTextColor(r, g, b)
	self.startChannelTextColor = CreateColor(r, g, b);
end

function CastingBarFrameMixin:SetStartRechargeTextColor(r, g, b)
	self.startRechargeTextColor = CreateColor(r, g, b);
end

function CastingBarFrameMixin:SetUnit(icon)
	self.name = self.statusBar.name
	self.unit = icon.guid
	self.spellID = icon.spellID

	self.casting = nil;
	self.channeling = nil;
	self.holdTime = 0;
	self.fadeOut = nil;

	self:Hide()
end

function CastingBarFrameMixin:OnLoad(db, icon)
	local classColor = RAID_CLASS_COLORS[icon.class]
	local c, active, recharge

	c = db.bgColors
	active = c.useClassColor.active and classColor or c.activeColor
	recharge = c.useClassColor.recharge and classColor or c.rechargeColor

	self:SetStartCastBGColor(active.r, active.g, active.b, c.activeColor.a);
	self:SetStartChannelBGColor(active.r, active.g, active.b, c.activeColor.a);
	self:SetStartRechargeBGColor(recharge.r, recharge.g, recharge.b, c.rechargeColor.a);

	c = db.textColors
	active = c.useClassColor.active and classColor or c.activeColor
	recharge = c.useClassColor.recharge and classColor or c.rechargeColor
	self:SetStartCastTextColor(active.r, active.g, active.b);
	self:SetStartChannelTextColor(active.r, active.g, active.b);
	self:SetStartRechargeTextColor(recharge.r, recharge.g, recharge.b);

	c = db.barColors
	active = c.useClassColor.active and classColor or c.activeColor
	recharge = c.useClassColor.recharge and classColor or c.rechargeColor
	self:SetStartRechargeColor(recharge.r, recharge.g, recharge.b, c.rechargeColor.a);
	self:SetStartCastColor(active.r, active.g, active.b, c.activeColor.a);
	self:SetStartChannelColor(active.r, active.g, active.b, c.activeColor.a);
	self:SetFinishedCastColor(0.0, 1.0, 0.0);
	self:SetNonInterruptibleCastColor(0.7, 0.7, 0.7);
	self:SetFailedCastColor(.55, .27, 1.0);

	self:SetUseStartColorForFinished(true);
	self:SetUseStartColorForFlash(true);

	self:SetUnit(icon);

	self.showCastbar = true;

	local point, _,_,_, offsetY = self.Spark:GetPoint();
	if ( point == "CENTER" ) then
		self.Spark.offsetY = offsetY;
	end

	self.isSparkEnabled = not db.hideSpark
	self.Spark:SetShown(self.isSparkEnabled)
	self.nextTextUpdate = 0

	if P.groupInfo[icon.guid].active[icon.spellID] then
		self:OnEvent(db.reverseFill and	 'UNIT_SPELLCAST_CHANNEL_START' or 'UNIT_SPELLCAST_START')
	end
end

function CastingBarFrameMixin:FinishSpell()
	if not self.finishedColorSameAsStart then
		self:SetStatusBarColor(self.finishedCastColor:GetRGB());
	end
	if ( self.isSparkEnabled ) then
		self.Spark:Hide();
	end

	if not P.extraBars[self.statusBar.key].shouldRearrangeInterrupts then
		self.fadeOut = true;
	end
	self.casting = nil;
	self.channeling = nil;
end

function CastingBarFrameMixin:FindStartEndTime(now)
	local info = P.groupInfo[self.unit]
	local active = info and info.active[self.spellID]
	if active then

		local modRate = active.modRate
		self.modRate = modRate
		if modRate then
			now = now or GetTime()
			local newTime = now - (now - active.startTime) / modRate
			return newTime , newTime + active.duration / modRate
		end
		return active.startTime, active.startTime + active.duration
	end
end

function CastingBarFrameMixin:ApplyAlpha(alpha)
	self:SetAlpha(alpha);
end

local function OmniCDCastingBarFrame_OnShow(self)
	if ( self.unit ) then
		--[[
		if ( self.casting ) then
			local startTime = self:FindStartEndTime()
			if ( startTime ) then
				self.value = (GetTime() - startTime);
			end
		else
			local _, endTime = self:FindStartEndTime()
			if ( endTime ) then
				self.value = (endTime - GetTime())
			end
		end
		]]
		if ( self.casting or self.channeling ) then
			local statusBar = self.statusBar
			statusBar.Text:Hide()
			statusBar.BG:Hide()
		end
	end
end

local function OmniCDCastingBarFrame_OnHide(self)
	local statusBar = self.statusBar
	statusBar.Text:Show()
	statusBar.BG:Show()


	local icon = statusBar.icon
	if icon.tooltipID then
		statusBar.icon.icon:SetTexture(icon.iconTexture)
		icon.tooltipID = nil
		if not E.db.icons.showTooltip then
			icon:EnableMouse(false)
		end
	end
end

local function TimeFormat(value)
	if value > SECONDS_PER_MIN then
		if value <= P.mmss then
			local secRemaining = value%SECONDS_PER_MIN
			local sec = ceil(secRemaining)
			if sec == SECONDS_PER_MIN then
				return format("%d:%02d", floor(value/SECONDS_PER_MIN) + 1, 0), secRemaining%1
			else
				return format("%d:%02d", floor(value/SECONDS_PER_MIN), sec), secRemaining%1
			end
		else
			return format("%dm", ceil(value/SECONDS_PER_MIN)), min(value%SECONDS_PER_MIN, value - P.mmss)
		end
	else
		return ceil(value), value%1
	end
end

local function OmniCDCastingBarFrame_OnUpdate(self, elapsed)
	if ( self.casting ) then
		local modRate = self.modRate
		if modRate then
			elapsed = elapsed / modRate
		end
		self.value = self.value + elapsed;
		if ( self.value >= self.maxValue ) then
			self:SetValue(self.maxValue);
			self:FinishSpell();
			return;
		end
		self:SetValue(self.value);
		if ( self.isSparkEnabled ) then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, self.Spark.offsetY or 2);
		end

		if self.nextTextUpdate and self.nextTextUpdate > 0 then
			self.nextTextUpdate = self.nextTextUpdate - elapsed
			return
		end
		local counter, nextTextUpdate = TimeFormat(self.maxValue - self.value)
		self.nextTextUpdate = nextTextUpdate
		self.Timer:SetText(counter)
	elseif ( self.channeling ) then
		local modRate = self.modRate
		if modRate then
			elapsed = elapsed / modRate
		end
		self.value = self.value - elapsed;
		if ( self.value <= 0 ) then
			self:FinishSpell();
			return;
		end
		self:SetValue(self.value);
		if ( self.isSparkEnabled ) then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, self.Spark.offsetY or 2);
		end

		if self.nextTextUpdate and self.nextTextUpdate > 0 then
			self.nextTextUpdate = self.nextTextUpdate - elapsed
			return
		end
		local counter, nextTextUpdate = TimeFormat(self.value)
		self.nextTextUpdate = nextTextUpdate
		self.Timer:SetText(counter)
	elseif ( GetTime() < self.holdTime ) then
		return;
	elseif ( self.fadeOut ) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if ( alpha > 0 ) then
			self:ApplyAlpha(alpha);
		else
			self.fadeOut = nil;
			self:Hide();
			OmniCDCastingBarFrame_OnHide(self)
		end
	else
		self:Hide();
		OmniCDCastingBarFrame_OnHide(self)
	end
end

function CastingBarFrameMixin:GetEffectiveStartColor(isChannel, notInterruptible)
	if self.nonInterruptibleColor and notInterruptible then
		return self.nonInterruptibleColor;
	end

	local icon = self.statusBar.icon
	if icon.active ~= 0 then
		return self.startRechargeColor, self.startRechargeBGColor, self.startRechargeTextColor
	elseif isChannel then
		return self.startChannelColor, self.startChannelBGColor, self.startChannelTextColor
	else
		return self.startCastColor, self.startCastBGColor, self.startCastTextColor
	end
end

function CastingBarFrameMixin:UpdateInterruptibleState(notInterruptible)
	if ( self.casting or self.channeling ) then
		local startColor = self:GetEffectiveStartColor(self.channeling, notInterruptible);
		self:SetStatusBarColor(startColor:GetRGB());
	end
end

local RESET = NEWBIE_TOOLTIP_STOPWATCH_RESETBUTTON or "Reset"

function CastingBarFrameMixin:OnEvent(event)
	local info = P.groupInfo[self.unit]
	if not info then
		return
	end

	local statusBar = self.statusBar
	if E.db.extraBars[statusBar.key].nameBar then
		local isChannel = event == 'UNIT_SPELLCAST_CHANNEL_START' or event == 'UNIT_SPELLCAST_CHANNEL_UPDATE'
		if ( isChannel or event == 'UNIT_SPELLCAST_START' or event == 'UNIT_SPELLCAST_CAST_UPDATE' ) then
			local _,_, startTextColor = self:GetEffectiveStartColor(isChannel);
			if info.isDeadOrOffline then
				statusBar.Text:SetTextColor(0.3, 0.3, 0.3)
			else
				statusBar.Text:SetTextColor(startTextColor:GetRGB())
			end
		elseif ( event == 'UNIT_SPELLCAST_STOP' or event == 'UNIT_SPELLCAST_CHANNEL_STOP' or event == 'UNIT_SPELLCAST_FAILED' ) then
			statusBar:SetColors()
		end
		return
	end

	if ( event == 'UNIT_SPELLCAST_START' ) then
		local text = self.name
		local now = GetTime()
		local startTime, endTime = self:FindStartEndTime(now)
		if ( not startTime ) then
			self:Hide();
			return;
		end

		if info.isDeadOrOffline then
			self:SetStatusBarColor(0.3, 0.3, 0.3)
			self.BG:SetVertexColor(0.3, 0.3, 0.3)
			self.Text:SetTextColor(0.3, 0.3, 0.3)
		else
			local startColor, startBGColor, startTextColor = self:GetEffectiveStartColor(false);
			self:SetStatusBarColor(startColor:GetRGBA());
			self.BG:SetVertexColor(startBGColor:GetRGBA())
			self.Text:SetTextColor(startTextColor:GetRGB())
		end
		if ( self.isSparkEnabled ) then
			self.Spark:Show();
		end
		self.value = (now - startTime);
		self.maxValue = (endTime - startTime);
		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		self.nextTextUpdate = 0
		if ( self.Text ) then
			self.Text:SetText(text);
		end
		self:ApplyAlpha(1.0);
		self.holdTime = 0;
		self.casting = true;
		self.channeling = nil;
		self.fadeOut = nil;
		if ( self.showCastbar ) then
			self:Show();
		end
	elseif ( event == 'UNIT_SPELLCAST_STOP' or event == 'UNIT_SPELLCAST_CHANNEL_STOP' ) then
		if ( not self:IsVisible() ) then
			self:Hide();
		end
		if ( self.casting and event == 'UNIT_SPELLCAST_STOP' ) or ( self.channeling and event == 'UNIT_SPELLCAST_CHANNEL_STOP' ) then
			if self.holdTime > 0 then
				return
			end

			if ( self.isSparkEnabled ) then
				self.Spark:Hide();
			end
			self:SetValue(self.maxValue);
			if ( event == 'UNIT_SPELLCAST_STOP' ) then
				self.casting = nil;
				if not self.finishedColorSameAsStart then
					self:SetStatusBarColor(self.finishedCastColor:GetRGB());
				end
			else
				self.channeling = nil;
			end
			self.fadeOut = true;
			self.holdTime = 0;
			self.nextTextUpdate = 0
		end
	elseif ( event == 'UNIT_SPELLCAST_FAILED' or event == 'UNIT_SPELLCAST_INTERRUPTED' ) then
		if ( self:IsShown() and (self.casting or self.channeling) and not self.fadeOut ) then
			self:SetValue(self.maxValue);
			self:SetStatusBarColor(self.failedCastColor:GetRGB());
			if ( self.isSparkEnabled ) then
				self.Spark:Hide();
			end
			if ( self.Text ) then
				self.Text:SetText(RESET)
			end
			self.casting = nil;
			self.channeling = nil;
			self.fadeOut = true;
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
			self.nextTextUpdate = 0
		end
	elseif ( event == 'UNIT_SPELLCAST_DELAYED' ) then
		if ( self:IsShown() ) then
			local now = GetTime()
			local startTime, endTime = self:FindStartEndTime(now)
			if ( not startTime ) then
				self:Hide();
				return;
			end
			self.value = (now - startTime);
			self.maxValue = (endTime - startTime);
			self:SetMinMaxValues(0, self.maxValue);
			self.nextTextUpdate = 0
			if ( not self.casting ) then
				self:SetStatusBarColor(self:GetEffectiveStartColor(false):GetRGB());
				if ( self.isSparkEnabled ) then
					self.Spark:Show();
				end
				self.casting = true;
				self.channeling = nil;
				self.fadeOut = nil;
			end
		end
	elseif ( event == 'UNIT_SPELLCAST_CAST_UPDATE' ) then
		if ( self:IsShown() ) then
			local now = GetTime()
			local startTime, endTime = self:FindStartEndTime(now)
			if ( not startTime ) then
				self:Hide();
				return;
			end
			self.value = (now - startTime)
			self.maxValue = (endTime - startTime)
			self:SetMinMaxValues(0, self.maxValue);
			self:SetValue(self.value);
			self.nextTextUpdate = 0
		end
	elseif ( event == 'UNIT_SPELLCAST_CHANNEL_START' ) then
		local text = self.name
		local now = GetTime()
		local startTime, endTime = self:FindStartEndTime(now)
		if ( not startTime ) then
			self:Hide();
			return;
		end

		if info.isDeadOrOffline then
			self:SetStatusBarColor(0.3, 0.3, 0.3)
			self.BG:SetVertexColor(0.3, 0.3, 0.3)
			self.Text:SetTextColor(0.3, 0.3, 0.3)
		else
			local startColor, startBGColor, startTextColor = self:GetEffectiveStartColor(true);
			self:SetStatusBarColor(startColor:GetRGBA());
			self.BG:SetVertexColor(startBGColor:GetRGBA())
			self.Text:SetTextColor(startTextColor:GetRGB())
		end

		self.value = endTime - now;
		self.maxValue = endTime - startTime;
		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		self.nextTextUpdate = 0
		if ( self.Text ) then
			self.Text:SetText(text);
		end
		if ( self.isSparkEnabled ) then
			self.Spark:Show();
		end
		self:ApplyAlpha(1.0);
		self.holdTime = 0;
		self.casting = nil;
		self.channeling = true;
		self.fadeOut = nil;
		if ( self.showCastbar ) then
			self:Show();
		end
	elseif ( event == 'UNIT_SPELLCAST_CHANNEL_UPDATE' ) then
		if ( self:IsShown() ) then
			local now = GetTime()
			local startTime, endTime = self:FindStartEndTime(now)
			if ( not startTime ) then
				self:Hide();
				return;
			end
			self.value = (endTime - now)
			self.maxValue = endTime - startTime
			self:SetMinMaxValues(0, self.maxValue);
			self:SetValue(self.value);
			self.nextTextUpdate = 0
		end
	elseif ( event == 'UNIT_SPELLCAST_INTERRUPTIBLE' or event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE' ) then
		self:UpdateInterruptibleState(event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE');
	end
end

local numStatusBars = 0
function P:AcquireStatusBar(icon, key, nameWithoutRealm)
	local statusBar = tremove(inactiveStatusBars)
	if not statusBar then
		numStatusBars = numStatusBars + 1
		statusBar = CreateFrame("Frame", "OmniCDStatusBar" .. numStatusBars, UIParent, "OmniCDStatusBar")

		local castingBar = statusBar.CastingBar
		castingBar.statusBar = statusBar
		castingBar:SetScript("OnUpdate", OmniCDCastingBarFrame_OnUpdate)
		castingBar:SetScript("OnShow", OmniCDCastingBarFrame_OnShow)

		statusBar.Text:SetFontObject(E.StatusBarFont)
		castingBar.Text:SetFontObject(E.StatusBarFont)
		castingBar.Timer:SetFontObject(E.StatusBarFont)

		local texture = E.Libs.LSM:Fetch("statusbar", E.profile.General.textures.statusBar.bar)
		statusBar.BG:SetTexture(texture)
		castingBar:SetStatusBarTexture(texture)
		castingBar.BG:SetTexture(E.Libs.LSM:Fetch("statusbar", E.profile.General.textures.statusBar.BG))

		statusBar.BG:SetTexelSnappingBias(0.0)
		statusBar.BG:SetSnapToPixelGrid(false)
		statusBar.borderTop:SetTexelSnappingBias(0.0)
		statusBar.borderTop:SetSnapToPixelGrid(false)
		statusBar.borderBottom:SetTexelSnappingBias(0.0)
		statusBar.borderBottom:SetSnapToPixelGrid(false)
		statusBar.borderRight:SetTexelSnappingBias(0.0)
		statusBar.borderRight:SetSnapToPixelGrid(false)
		castingBar.BG:SetTexelSnappingBias(0.0)
		castingBar.BG:SetSnapToPixelGrid(false)
		local castingBarTexture = castingBar:GetStatusBarTexture()
		castingBarTexture:SetTexelSnappingBias(0.0)
		castingBarTexture:SetSnapToPixelGrid(false)
		Mixin(statusBar, StatusBarFrameMixin)
		Mixin(castingBar, CastingBarFrameMixin)
	end

	local db = E.db.extraBars[key]
	local numChar = db.truncateStatusBarName
	if numChar > 0 then
		nameWithoutRealm = string.utf8sub(nameWithoutRealm, 1, numChar)
	end
	statusBar.name = nameWithoutRealm
	statusBar.Text:SetText(nameWithoutRealm)
	statusBar.key = key
	statusBar.icon = icon
	statusBar.CastingBar:OnLoad(db, icon)

	statusBar:SetParent(icon)
	statusBar:ClearAllPoints()
	statusBar:SetPoint("TOPLEFT", icon, "TOPRIGHT")
	statusBar:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT")
	statusBar:Show()
	statusBar.BG:Show()
	statusBar.Text:Show()

	icon.statusBar = statusBar

	activeStatusBars[statusBar] = true
	numActiveStatusBars = numActiveStatusBars + 1
	return statusBar
end

function P:UpdateStatusBarTextures()
	local barTexture = E.Libs.LSM:Fetch("statusbar", E.profile.General.textures.statusBar.bar)
	local bgTexture = E.Libs.LSM:Fetch("statusbar", E.profile.General.textures.statusBar.BG)

	for statusBar in pairs(activeStatusBars) do
		statusBar.BG:SetTexture(barTexture)
		statusBar.CastingBar:SetStatusBarTexture(barTexture)
		statusBar.CastingBar.BG:SetTexture(bgTexture)
	end
	for i = 1, #inactiveStatusBars do
		local statusBar = inactiveStatusBars[i]
		statusBar.BG:SetTexture(barTexture)
		statusBar.CastingBar:SetStatusBarTexture(barTexture)
		statusBar.CastingBar.BG:SetTexture(bgTexture)
	end
end

function P:UpateStatusBarTimerFormat()
	local db = E.profile.General.cooldownText.statusBar
	self.mmss = db.mmss
	self.ss = db.ss
	self.mmssColor = db.mmssColor
	self.ssColor = db.ssColor
end
