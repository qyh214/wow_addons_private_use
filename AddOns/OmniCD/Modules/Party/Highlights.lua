local E = select(2, ...):unpack()
local P = E.Party

local BarFrameIconMixin = P.BarFrameIconMixin

local OverlayGlowFrameMixin = {}
local unusedOverlayGlows = {}
local numOverlays = 0

function OverlayGlowFrameMixin:Release()
	self:Hide()
	tinsert(unusedOverlayGlows, self)
end

local function OverlayGlow_AnimOutFinished(animGroup)
	local overlay = animGroup:GetParent()
	local icon = overlay:GetParent()
	overlay:Release()
	icon.overlay = nil
end

local function OverlayGlow_OnHide(self)
	if self.animOut:IsPlaying() then
		self.animOut:Stop()
		OverlayGlow_AnimOutFinished(self.animOut)
	end
end

local function AcquireOverlayGlow()
	local overlay = tremove(unusedOverlayGlows)
	if not overlay then
		numOverlays = numOverlays + 1
		overlay = CreateFrame("Frame", "OmniCDOverlayGlow".. numOverlays, UIParent, "OmniCDButtonSpellActivationAlert")
		overlay.animOut:SetScript("OnFinished", OverlayGlow_AnimOutFinished)
		overlay:SetScript("OnHide", OverlayGlow_OnHide)
		Mixin(overlay, OverlayGlowFrameMixin)
	end
	return overlay
end

function OverlayGlowFrameMixin:ShowOverlayGlowNoAnim()
	local frameWidth, frameHeight = self:GetSize()
	self.spark:SetSize(frameWidth, frameHeight)
	self.spark:SetAlpha(0)
	self.innerGlow:SetSize(frameWidth, frameHeight)
	self.innerGlow:SetAlpha(0)
	self.innerGlowOver:SetAlpha(0)
	self.outerGlow:SetSize(frameWidth, frameHeight)
	self.outerGlow:SetAlpha(1.0)
	self.outerGlowOver:SetAlpha(0)
	self.ants:SetSize(frameWidth * 0.85, frameHeight * 0.85)
	self.ants:SetAlpha(1.0)
	self:Show()
end

local RemoveHighlight_OnTimerEnd
RemoveHighlight_OnTimerEnd = function(icon)
	local guid = icon.guid
	if guid then
		local info = P.groupInfo[guid]
		if info and icon.isHighlighted then
			local duration, expTime = P:GetBuffDuration(info.unit, icon.buff)
			if duration and duration > 0 then
				duration = expTime - GetTime()
				if duration > 0 then
					icon.isHighlighted = C_Timer.NewTimer(duration + 0.1, function() RemoveHighlight_OnTimerEnd(icon) end)
				else
					icon:RemoveHighlight()
				end
			else
				icon:RemoveHighlight()
			end
		end
	end
end

function BarFrameIconMixin:ShowOverlayGlow(duration, isRefresh)
	if E.db.highlight.glowType == "wardrobe" then
		if not self.isHighlighted then
			self.PendingFrame:Show()
			if not isRefresh then
				self.AnimFrame.animIn:Play()
			end
		end
	elseif self.overlay then
		if self.overlay.animOut:IsPlaying() then
			self.overlay.animOut:Stop()
			if isRefresh then
				self.overlay:ShowOverlayGlowNoAnim()
			else
				self.overlay.animIn:Play()
			end
		end
	else
		self.overlay = AcquireOverlayGlow()
		local frameWidth, frameHeight = self:GetSize()
		self.overlay:SetParent(self)
		self.overlay:ClearAllPoints()
		self.overlay:SetSize(frameWidth * 1.4, frameHeight * 1.4)
		self.overlay:SetPoint("TOPLEFT", self, "TOPLEFT", -frameWidth * 0.2, frameHeight * 0.2)
		self.overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", frameWidth * 0.2, -frameHeight * 0.2)
		if isRefresh then
			self.overlay:ShowOverlayGlowNoAnim()
		else
			self.overlay.animIn:Play()
		end
	end
	if type(self.isHighlighted) == "userdata" then
		self.isHighlighted:Cancel()
	end
	self.isHighlighted = (self.guid ~= E.userGUID or E.summonedBuffDuration[self.spellID]) and C_Timer.NewTimer(duration + 0.1, function() RemoveHighlight_OnTimerEnd(self) end) or true
end

function BarFrameIconMixin:HideOverlayGlow()
	if self.overlay then
		if self.overlay.animIn:IsPlaying() then
			self.overlay.animIn:Stop()
		end

		if self:IsVisible() then
			self.overlay.animOut:Play()
		else
			OverlayGlow_AnimOutFinished(self.overlay.animOut)
		end
	elseif self.isHighlighted then
		self.PendingFrame:Hide()
		if self:IsVisible() then
			self.AnimFrame.animOut:Play()
		else
			self.AnimFrame:Hide()
		end
	end

	if type(self.isHighlighted) == "userdata" then
		self.isHighlighted:Cancel()
	end

	self.isHighlighted = nil
end

function BarFrameIconMixin:RemoveHighlight()
	local info = P.groupInfo[self.guid]
	if not info or not info.glowIcons[self.buff] then
		return
	end

	info.glowIcons[self.buff] = nil
	self:HideOverlayGlow()


	local active = self.active and info.active[self.spellID]
	if active then
		if info.preactiveIcons[self.spellID] then
			self.icon:SetVertexColor(0.4, 0.4, 0.4)
		end
		self:SetCooldownElements(active.charges, info)
		self.icon:SetDesaturated(E.db.icons.desaturateActive and (not active.charges or active.charges == 0))
	end
end

function BarFrameIconMixin:SetHighlight(isRefresh)
	if not E.db.highlight.glowBuffs or not E.db.highlight.glowBuffTypes[self.type] then
		return
	end

	local buff = self.buff
	if buff == 0 or not E.spell_highlighted[buff] then
		return
	end

	local info = P.groupInfo[self.guid]
	--[==[@debug@
	assert(info, self.unitName)
	--@end-debug@]==]
	if not info then
		return
	end

	local spellID = self.spellID
	local duration, expTime = E.summonedBuffDuration[spellID]

	if duration then

		local active = info.active[spellID]
		if active then
			duration = duration - GetTime() + active.startTime
		end
	else
		duration, expTime = P:GetBuffDuration(info.unit, buff)
		if duration and duration > 0 then
			duration = expTime - GetTime()
		end
	end
	if duration and duration > 0 then
		if E.buffFixNoCLEU[buff] and (not E.isBFA or not P.isInArena) then
			info.bar:RegisterUnitEvent('UNIT_AURA', info.unit)
		end

		self:ShowOverlayGlow(duration, isRefresh)
		self:SetCooldownElements(nil, info)
		self.icon:SetDesaturated(false)

		info.glowIcons[buff] = self
		return true
	end
end

function BarFrameIconMixin:SetGlow()
	self.AnimFrame.animIn:Play()
end
