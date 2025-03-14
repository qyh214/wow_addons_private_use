local E = select(2, ...):unpack()
local P = E.Party

local activeIcons = {}
local inactiveIcons = {}
local numActiveIcons = 0

local BarFrameIconMixin = {}

function BarFrameIconMixin:Release()
	local statusBar = self.statusBar
	if statusBar then
		statusBar:Release()
		self.statusBar = nil
	end
	self:HideOverlayGlow()

	self:Hide()
	inactiveIcons[#inactiveIcons + 1] = self
	activeIcons[self] = nil
	numActiveIcons = numActiveIcons - 1
end

local textureUVs = { "borderTop", "borderBottom", "borderRight", "borderLeft" }

function BarFrameIconMixin:HideBorder()
	for _, pieceName in pairs(textureUVs) do
		local region = self[pieceName]
		if region then
			region:Hide()
		end
	end
	self.icon:SetTexCoord(0, 1, 0, 1)
end

function BarFrameIconMixin:SetBorder()
	local db = E.db.icons
	if not db.displayBorder then
		self:HideBorder()
		return
	end

	local edgeSize = P.pixel
	local r, g, b = db.borderColor.r, db.borderColor.g, db.borderColor.b

	self.borderTop:ClearAllPoints()
	self.borderTop:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.borderTop:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -edgeSize)
	self.borderTop:SetColorTexture(r, g, b)
	self.borderTop:Show()

	self.borderBottom:ClearAllPoints()
	self.borderBottom:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
	self.borderBottom:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, edgeSize)
	self.borderBottom:SetColorTexture(r, g, b)
	self.borderBottom:Show()

	self.borderRight:ClearAllPoints()
	self.borderRight:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -edgeSize)
	self.borderRight:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -edgeSize, edgeSize)
	self.borderRight:SetColorTexture(r, g, b)
	self.borderRight:Show()

	self.borderLeft:ClearAllPoints()
	self.borderLeft:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -edgeSize)
	self.borderLeft:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", edgeSize, edgeSize)
	self.borderLeft:SetColorTexture(r, g, b)
	self.borderLeft:Show()

	self.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end

function BarFrameIconMixin:SetMarker()
	local mark = E.spell_marked[self.spellID]
	if not mark or self.statusBar then
		self.hotKey:Hide()
	elseif mark == true or P:IsTalentForPvpStatus(mark, P.groupInfo[self.guid]) then
		self.hotKey:Show()
	end
end

function BarFrameIconMixin:SetOpacity(opaqueStatusBar)
	local statusBar = self.statusBar
	if statusBar and not E.db.extraBars[statusBar.key].useIconAlpha then
		local db = E.db.icons
		self:SetAlpha(self.active == 0 and db.activeAlpha or db.inactiveAlpha)
	else
		self:SetAlpha(1.0)
	end
end

function BarFrameIconMixin:SetColorSaturation()
	local info = P.groupInfo[self.guid]
	if info.isDeadOrOffline then
		self.icon:SetVertexColor(0.3, 0.3, 0.3)
		self.icon:SetDesaturated(true)
	elseif info.preactiveIcons[self.spellID] and not self.isHighlighted then
		self.icon:SetVertexColor(0.4, 0.4, 0.4)
		self.icon:SetDesaturated(E.db.icons.desaturateActive and self.active == 0)
	else
		self.icon:SetVertexColor(1, 1, 1)
		self.icon:SetDesaturated(E.db.icons.desaturateActive and self.active == 0 and not self.isHighlighted)
	end
end

function BarFrameIconMixin:SetSwipeCounter()
	if self.active then
		self:SetCooldownElements(self.maxcharges and self.active)
	end
	local db = E.db.icons
	self.cooldown:SetReverse(db.reverse)
	self.cooldown:SetSwipeColor(0, 0, 0, db.swipeAlpha)
	self.counter:SetScale(db.counterScale)
end

function BarFrameIconMixin:SetChargeScale()
	self.count:SetScale(E.db.icons.chargeScale)
end

function BarFrameIconMixin:SetTooltip()
	self:EnableMouse((not self.SetPassThroughButtons or self.isPassThrough) and (E.db.icons.showTooltip or self.tooltipID))
end

function BarFrameIconMixin:SetExBorder(db, edgeSize)
	local db_icon = E.db.icons
	local showProgressBar = db.progressBar and db.layout == "vertical" and not db.unitBar

	if not db_icon.displayBorder and not showProgressBar then
		self:HideBorder()
		return
	end

	local r, g, b = db_icon.borderColor.r, db_icon.borderColor.g, db_icon.borderColor.b

	self.borderTop:ClearAllPoints()
	self.borderTop:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.borderTop:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -edgeSize)
	self.borderTop:SetColorTexture(r, g, b)
	self.borderTop:Show()

	self.borderBottom:ClearAllPoints()
	self.borderBottom:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
	self.borderBottom:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, edgeSize)
	self.borderBottom:SetColorTexture(r, g, b)
	self.borderBottom:Show()

	self.borderRight:ClearAllPoints()
	self.borderRight:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -edgeSize)
	self.borderRight:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -edgeSize, edgeSize)
	self.borderRight:SetColorTexture(r, g, b)
	self.borderRight:Show()

	self.borderLeft:ClearAllPoints()
	self.borderLeft:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -edgeSize)
	self.borderLeft:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", edgeSize, edgeSize)
	self.borderLeft:SetColorTexture(r, g, b)
	self.borderLeft:Show()

	self.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	if showProgressBar then
		local statusBar = self.statusBar
		if statusBar then
			if db.nameBar then
				statusBar:DisableDrawLayer("BORDER")
			else
				statusBar:EnableDrawLayer("BORDER")


				statusBar.borderTop:ClearAllPoints()
				statusBar.borderTop:SetPoint("TOPLEFT", statusBar, "TOPLEFT")
				statusBar.borderTop:SetPoint("BOTTOMRIGHT", statusBar, "TOPRIGHT", 0, -edgeSize)

				statusBar.borderBottom:ClearAllPoints()
				statusBar.borderBottom:SetPoint("BOTTOMLEFT", statusBar, "BOTTOMLEFT")
				statusBar.borderBottom:SetPoint("TOPRIGHT", statusBar, "BOTTOMRIGHT", 0, edgeSize)

				statusBar.borderRight:ClearAllPoints()
				statusBar.borderRight:SetPoint("TOPRIGHT", statusBar.borderTop, "BOTTOMRIGHT")
				statusBar.borderRight:SetPoint("BOTTOMLEFT", statusBar.borderBottom, "TOPRIGHT", -edgeSize, 0)

				if db.hideBorder then
					statusBar.borderTop:Hide()
					statusBar.borderBottom:Hide()
					statusBar.borderRight:Hide()
				else
					statusBar.borderTop:SetColorTexture(r, g, b)
					statusBar.borderTop:Show()
					statusBar.borderBottom:SetColorTexture(r, g, b)
					statusBar.borderBottom:Show()
					statusBar.borderRight:SetColorTexture(r, g, b)
					statusBar.borderRight:Show()
				end
			end
		end
	end
end

function BarFrameIconMixin:SetExIconName(db)
	if db.layout == "vertical" and db.progressBar or not db.showName or db.unitBar then
		self.name:Hide()
	else
		self.name:SetPoint("BOTTOM", 0, db.nameOfsY)
		local nameWithoutRealm = P.groupInfo[self.guid].nameWithoutRealm
		local numChar = db.truncateIconName
		if numChar > 0 then
			nameWithoutRealm = string.utf8sub(nameWithoutRealm, 1, numChar)
		end
		if db.classColor then
			local c = RAID_CLASS_COLORS[self.class]
			if c and c.r then
				self.name:SetTextColor(c.r, c.g, c.b)
			end
		else
			self.name:SetTextColor(1, 1, 1)
		end
		self.name:SetText(nameWithoutRealm)
		self.name:Show()
	end
end


local pendingPassThroughButtons = {}

function P:UpdatePassThroughButtons()
	if #pendingPassThroughButtons > 0 then
		local showTooltip = E.db.icons.showTooltip
		for i = #pendingPassThroughButtons, 1, -1 do
			local icon = pendingPassThroughButtons[i]
			icon:SetPassThroughButtons("LeftButton", "RightButton")
			icon.isPassThrough = true
			if showTooltip then
				icon:EnableMouse(true)
			end
			pendingPassThroughButtons[i] = nil
		end
	end
end

local function OmniCDCooldown_OnHide(self)
	if self:GetCooldownTimes() > 0 then
		return
	end

	local icon = self:GetParent()
	local info = P.groupInfo[icon.guid]
	if not info then
		return
	end

	local active = info.active[icon.spellID]
	if not active then
		return
	end

	local maxcharges = icon.maxcharges
	local charges = active.charges
	if maxcharges and charges then
		if charges + 1 < maxcharges then
			icon:StartCooldown(icon.duration, true)
			return
		end
		icon.count:SetText(maxcharges)
	end

	info.active[icon.spellID] = nil
	icon.active = nil

	local frame = icon:GetParent():GetParent()
	local key = frame.key
	if type(key) == "number" then
		if not P.displayInactive then
			frame:UpdateLayout()
		end
	else
		if frame.shouldRearrangeInterrupts then
			frame:UpdateLayout(true)
		end
	end

	local statusBar = icon.statusBar
	if not statusBar or E.db.extraBars[key].useIconAlpha then
		icon:SetAlpha(E.db.icons.inactiveAlpha)
	end
	if not info.isDeadOrOffline then
		icon.icon:SetDesaturated(false)
	end
	if icon.isHighlighted then
		icon:RemoveHighlight()
	end
	if icon.glowBorder then
		icon.Glow:SetShown(not info.isDeadOrOffline and E.db.highlight.glowBorderCondition ~= 2)
	end
	if statusBar then
		statusBar.CastingBar:OnEvent('UNIT_SPELLCAST_STOP')
	end
end

local SpellTooltip = CreateFrame("GameTooltip", "OmniCDSpellTooltip", UIParent, "GameTooltipTemplate")
local TOOLTIP_UPDATE_TIME = 0.2
SpellTooltip.updateTooltipTimer = TOOLTIP_UPDATE_TIME

local function SpellTooltip_OnUpdate(self, elapsed)
	self.updateTooltipTimer = self.updateTooltipTimer - elapsed
	if self.updateTooltipTimer > 0 then
		return
	end
	self.updateTooltipTimer = TOOLTIP_UPDATE_TIME
	local owner = self:GetOwner()
	if owner then
		self:SetSpellByID(owner.tooltipID or owner.spellID)
	end
end
SpellTooltip:SetScript("OnUpdate", SpellTooltip_OnUpdate)

local function OmniCDIcon_OnEnter(self)
	local id = self.tooltipID or self.spellID
	if id then
		SpellTooltip:SetOwner(self, "ANCHOR_RIGHT")
		SpellTooltip:SetSpellByID(id)
	end
end

local function OmniCDIcon_OnLeave()
	SpellTooltip:Hide()
end

local numIcons = 0
function P:AcquireIcon(barFrame, iconIndex, unitBar)
	local icon = tremove(inactiveIcons)
	if not icon then
		numIcons = numIcons + 1
		icon = CreateFrame("Button", "OmniCDIcon" .. numIcons, UIParent, "OmniCDButtonTemplate")
		icon:SetSize(E.BASE_ICON_HEIGHT, E.BASE_ICON_HEIGHT)
		icon.counter = icon.cooldown:GetRegions()
		for _, pieceName in ipairs(textureUVs) do
			local region = icon[pieceName]
			if region then
				region:SetTexelSnappingBias(0.0)
				region:SetSnapToPixelGrid(false)
			end
		end
		icon.icon:SetTexelSnappingBias(0.0)
		icon.icon:SetSnapToPixelGrid(false)

		icon.name:SetFontObject(E.IconFont)
		if E.ElvUI1 then
			E.ElvUI1:RegisterCooldown(icon.cooldown, "OmniCD")
		end
		icon.cooldown:SetScript("OnHide", OmniCDCooldown_OnHide)
		icon:SetScript("OnEnter", OmniCDIcon_OnEnter)
		icon:SetScript("OnLeave", OmniCDIcon_OnLeave)
		if icon.SetPassThroughButtons then
			if self.inLockdown then
				tinsert(pendingPassThroughButtons, icon)
			else
				icon:SetPassThroughButtons("LeftButton", "RightButton")
				icon.isPassThrough = true
			end
		end
		Mixin(icon, BarFrameIconMixin)
	end
	activeIcons[icon] = true
	numActiveIcons = numActiveIcons + 1

	icon:SetParent(unitBar or barFrame.container)
	barFrame.icons[iconIndex] = icon
	return icon
end

P.BarFrameIconMixin = BarFrameIconMixin
