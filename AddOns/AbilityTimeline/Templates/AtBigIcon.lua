local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI             = LibStub("AceGUI-3.0")
local SharedMedia        = LibStub("LibSharedMedia-3.0")
local Type               = "AtBigIcon"
local Version            = 1
local variables          = {
	cooldown_scale = 2,
	icon_text_width = 95,
	icon_text_offset_x = 0,
	icon_text_offset_y = 10,
}

---handles the Text anchoring depending on the selected text anchor
---@param self Frame
---@param isStopped boolean
local handleAnchors      = function(self)
	self.SpellName:ClearAllPoints()
	local relPos, anchorPos, xOffset, yOffset
	relPos = private.TEXT_RELATIVE_POSITIONS[private.db.profile.big_icon_text_settings.text_anchor]
	anchorPos = private.db.profile.big_icon_text_settings.text_anchor
	if relPos == 'LEFT' then
		if private.db.profile.big_icon_settings and private.db.profile.big_icon_settings.TextOffset then
			xOffset = private.db.profile.big_icon_settings.TextOffset.x
			yOffset = private.db.profile.big_icon_settings.TextOffset.y
		else
			xOffset = variables.TextOffset.x
			yOffset = variables.TextOffset.y
		end
	elseif relPos == 'RIGHT' then
		if private.db.profile.big_icon_settings and private.db.profile.big_icon_settings.TextOffset then
			xOffset = -private.db.profile.big_icon_settings.TextOffset.x
			yOffset = -private.db.profile.big_icon_settings.TextOffset.y
		else
			xOffset = -variables.TextOffset.x
			yOffset = -variables.TextOffset.y
		end
	elseif relPos == 'TOP' then
		if private.db.profile.big_icon_settings and private.db.profile.big_icon_settings.TextOffset then
			xOffset = private.db.profile.big_icon_settings.TextOffset.x
			yOffset = -private.db.profile.big_icon_settings.TextOffset.y
		else
			xOffset = variables.TextOffset.x
			yOffset = -variables.TextOffset.y
		end
	else -- BOTTOM
		if private.db.profile.big_icon_settings and private.db.profile.big_icon_settings.TextOffset then
			xOffset = -private.db.profile.big_icon_settings.TextOffset.x
			yOffset = private.db.profile.big_icon_settings.TextOffset.y
		else
			xOffset = -variables.TextOffset.x
			yOffset = variables.TextOffset.y
		end
	end
	self.SpellName:SetPoint(relPos, self, anchorPos, xOffset, yOffset)
	for _, texture in pairs(self.DangerIcon) do
		texture:ClearAllPoints()
		texture:SetPoint(relPos, self, anchorPos, 0, 0)
	end
end

---Handles the cooldown display for a given frame (the frame needs to be the frame of a AtAbilitySpellIcon widget)
---@param self frame
---@param remainingTime number
local HandleCooldown     = function(self, remainingTime)
	local roundedTime = math.ceil(remainingTime)
	self.CooldownText:SetText(roundedTime)
	if private.db.profile.cooldown_settings.cooldown_highlight and private.db.profile.cooldown_settings.cooldown_highlight.enabled then
		for _, value in pairs(private.db.profile.cooldown_settings.cooldown_highlight.highlights) do
			local time, color = value.time, value.color
			if (remainingTime <= time) then
				self.CooldownText:SetTextColor(color.r, color.g, color.b)
				if value.useGlow then
					private.EnableGlow(self, value.glowType, time, value.glowColor)
				end
				return
			end
		end
	end
	if private.db.profile.cooldown_settings.cooldown_color then
		self.CooldownText:SetTextColor(
			private.db.profile.cooldown_settings.cooldown_color.r,
			private.db.profile.cooldown_settings.cooldown_color.g,
			private.db.profile.cooldown_settings.cooldown_color.b
		)
	else
		self.CooldownText:SetTextColor(1, 1, 1)
	end
end

local function ApplySettings(self)
	-- Apply settings to the icon
	if private.db.profile.big_icon_settings and private.db.profile.big_icon_settings.size then
		self.frame:SetSize(private.db.profile.big_icon_settings.size, private.db.profile.big_icon_settings.size)
	else
		self.frame:SetSize(variables.IconSize.width, variables.IconSize.height)
	end
	if private.db.profile.big_icon_settings and private.db.profile.big_icon_settings.TextOffset then
		handleAnchors(self.frame, self.isStopped)
	end
	if private.db.profile.big_icon_text_settings and private.db.profile.big_icon_text_settings.font and private.db.profile.big_icon_text_settings.fontSize then
		self.frame.SpellName:SetFont(SharedMedia:Fetch("font", private.db.profile.big_icon_text_settings.font),
			private.db.profile.big_icon_text_settings.fontSize, "OUTLINE")
	elseif private.db.profile.big_icon_text_settings and private.db.profile.big_icon_text_settings.fontSize then
		self.frame.SpellName:SetFontHeight(private.db.profile.big_icon_text_settings.fontSize)
	end

	if private.db.profile.cooldown_settings and private.db.profile.cooldown_settings.font and private.db.profile.cooldown_settings.fontSize then
		self.frame.CooldownText:SetFont(SharedMedia:Fetch("font", private.db.profile.cooldown_settings.font),
			private.db.profile.cooldown_settings.fontSize, "OUTLINE")
	elseif private.db.profile.cooldown_settings and private.db.profile.cooldown_settings.fontSize then
		self.frame.CooldownText:SetFontHeight(private.db.profile.cooldown_settings.fontSize)
	end

	if private.db.profile.big_icon_text_settings and private.db.profile.big_icon_text_settings.defaultColor then
		self.frame.SpellName:SetTextColor(
			private.db.profile.big_icon_text_settings.defaultColor.r,
			private.db.profile.big_icon_text_settings.defaultColor.g,
			private.db.profile.big_icon_text_settings.defaultColor.b
		)
	end

	if private.db.profile.big_icon_text_settings and private.db.profile.big_icon_text_settings.enableShadow then
		self.frame.SpellName:SetShadowColor(0, 0, 0, 1)
	else
		self.frame.SpellName:SetShadowColor(0, 0, 0, 0)
	end

	if not self.frame.SpellIcon.zoomApplied or self.frame.SpellIcon.zoomApplied ~= (1 - private.db.profile.big_icon_settings.zoom) then
		if self.frame.SpellIcon.zoomApplied then
			private.ResetZoom(self.frame.SpellIcon)
		end
		private.SetZoom(self.frame.SpellIcon, 1 - private.db.profile.big_icon_settings.zoom)
		self.frame.SpellIcon.zoomApplied = 1 - private.db.profile.big_icon_settings.zoom
	end

	for i, edges in ipairs(self.frame.DispellTypeBorderEdges) do
		for _, edgeTexture in ipairs(edges) do
			if private.db.profile.big_icon_settings.dispellBorders then
				edgeTexture:Show()
			else
				edgeTexture:Hide()
			end
		end
	end
	for i, texture in ipairs(self.frame.DispellTypeIcons) do
		if private.db.profile.big_icon_settings.dispellIcons then
			texture:Show()
		else
			texture:Hide()
		end
	end
	for i, texture in ipairs(self.frame.DangerIcon) do
		if private.db.profile.big_icon_settings.dangerIcon then
			texture:Show()
		else
			texture:Hide()
		end
	end
	if private.db.profile.big_icon_text_settings.useBackground then
		local texture = SharedMedia:Fetch("background", private.db.profile.big_icon_text_settings.backgroundTexture)
		self.frame.SpellNameBackground:SetPoint("LEFT", self.frame.SpellName, "LEFT",
			-private.db.profile.big_icon_text_settings.backgroundTextureOffset.x, 0)
		self.frame.SpellNameBackground:SetPoint("RIGHT", self.frame.SpellName, "RIGHT",
			private.db.profile.big_icon_text_settings.backgroundTextureOffset.x, 0)
		self.frame.SpellNameBackground:SetPoint("TOP", self.frame.SpellName, "TOP", 0,
			private.db.profile.big_icon_text_settings.backgroundTextureOffset.y)
		self.frame.SpellNameBackground:SetPoint("BOTTOM", self.frame.SpellName, "BOTTOM", 0,
			-private.db.profile.big_icon_text_settings.backgroundTextureOffset.y)
		self.frame.SpellNameBackground:SetTexture(texture)
		self.frame.SpellNameBackground:Show()
	else
		self.frame.SpellNameBackground:Hide()
	end
end

---@param self AtBigIcon
local function OnAcquire(self)
	ApplySettings(self)
end

---@param self AtBigIcon
local function OnRelease(self)
	self.frame.SpellIcon:SetTexture(nil)
	self.frame.SpellName:SetText("")
	self.frame.eventInfo = nil
	self.frame:SetScript("OnUpdate", nil)
	private.ClearEventTooltip(self.frame)
end

local SetEventInfo = function(widget, eventInfo, disableOnUpdate)
	widget.eventInfo = eventInfo
	if not disableOnUpdate then
		widget.frame.Cooldown:SetCooldown(GetTime(),
			eventInfo.duration - C_EncounterTimeline.GetEventTimeElapsed(eventInfo.id))
		widget.frame:SetScript("OnUpdate", function(self)
			local remaining = C_EncounterTimeline.GetEventTimeRemaining(eventInfo.id)
			local state = C_EncounterTimeline.GetEventState(eventInfo.id)
			if state ~= private.ENCOUNTER_STATES.Active then -- this should be handled better but for now we just hide non active states from the ui
				remaining = 0
			end
			if remaining > 0 then
				HandleCooldown(self, remaining)
			else
				private.HIGHLIGHT_EVENTS.BigIcons[eventInfo.id] = nil
				for i, f in ipairs(private.BIG_ICONS) do
					if f == widget then
						table.remove(private.BIG_ICONS, i)
						break
					end
				end
				widget:Release()
				private.evaluateBigIconPositions()
			end
		end)
		local EventIconTextureID = eventInfo.id
		if eventInfo.source == Enum.EncounterTimelineEventSource.Script and private.BossModsSpellIndicators and private.BossModsSpellIndicators[eventID] then
			EventIconTextureID = private.BossModsSpellIndicators[eventID]	
		end
		if private.db.profile.big_icon_settings.dispellIcons then
			C_EncounterTimeline.SetEventIconTextures(EventIconTextureID, 126, widget.frame.DispellTypeIcons)
		end
		if private.db.profile.big_icon_settings.dispellBorders then
			for i, dispellValue in ipairs(private.dispellTypeList) do
				for _, edgeTexture in ipairs(widget.frame.DispellTypeBorderEdges[i]) do
					local textureArray = {}
					table.insert(textureArray, edgeTexture)
					C_EncounterTimeline.SetEventIconTextures(EventIconTextureID, dispellValue.mask, textureArray)
					edgeTexture:SetTexture(nil)
					edgeTexture:SetColorTexture(dispellValue.color.r, dispellValue.color.g, dispellValue.color.b,
						dispellValue.color.a)
				end
			end
		end
		if private.db.profile.big_icon_settings.dangerIcon then
			C_EncounterTimeline.SetEventIconTextures(EventIconTextureID, 1, widget.frame.DangerIcon)
		end
	end

	local xOffset = (private.db.profile.big_icon_settings.size + private.db.global.bigicon[private.ACTIVE_EDITMODE_LAYOUT].margin) *
	(#private.BIG_ICONS)
	widget.frame:SetPoint("LEFT", private.BIGICON_FRAME.frame, "LEFT", xOffset, 0)
	widget.frame.xOffset = xOffset
	widget.frame.SpellIcon:SetAllPoints(widget.frame)
	widget.frame.SpellIcon:SetTexture(eventInfo.iconFileID)
	widget.frame.SpellName:SetText(eventInfo.spellName)

	if private.db.profile.text_settings.useEventColor then
			if issecretvalue(eventInfo.icons) then
				widget.frame.SpellName:SetTextColor(eventInfo.color.r, eventInfo.color.g, eventInfo.color.b)
			elseif private.db.profile.dispellTextColor and eventInfo.icons and eventInfo.icons ~= 0 then
				for _, value in pairs(private.dispellTypeList) do
					if bit.band(eventInfo.icons, value.mask) ~= 0 then
						widget.frame.SpellName:SetTextColor(value.color.r, value.color.g, value.color.b)
						break -- Only set the first matching color
					end
				end
			end
		end
	widget.frame:Show()
	if private.db.profile.big_icon_settings and private.db.profile.big_icon_settings.useTooltip and private.db.profile.big_icon_settings.useTooltip ~= Enum.EncounterEventsTooltipAnchor.Hidden then
		private.AddEventTooltip(widget.frame, eventInfo, private.db.profile.big_icon_settings.useTooltip)
	end
end

local function Constructor()
	local count = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", "BIGICON" .. count, private.BIGICON_FRAME.frame)
	frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	frame.Cooldown:SetDrawSwipe(true)
	frame.Cooldown:SetDrawEdge(true)
	frame.Cooldown:SetAllPoints(frame)
	frame.Cooldown:SetScale(variables.cooldown_scale)
	frame.Cooldown:SetHideCountdownNumbers(true)

	frame.CooldownText = frame.Cooldown:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
	frame.CooldownText:SetPoint("CENTER", frame.Cooldown, "CENTER", 0, 0)

	frame:SetSize(private.db.profile.big_icon_settings.size, private.db.profile.big_icon_settings.size)

	frame.TextureHolder = CreateFrame("Frame", nil, frame)
	frame.TextureHolder:SetAllPoints(frame)
	frame.TextureHolder:SetFrameStrata("HIGH")

	frame.SpellIcon = frame:CreateTexture(nil, "BACKGROUND")
	frame.SpellName = frame.TextureHolder:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
	frame.SpellName:SetWidth(variables.icon_text_width)
	frame.SpellName:SetWordWrap(true)
	frame.SpellName:SetPoint("TOP", frame, "BOTTOM", variables.icon_text_offset_x, variables.icon_text_offset_y)
	frame:Show()

	-- spell name background
	frame.SpellNameBackground = frame:CreateTexture(nil, "BACKGROUND")
	frame.SpellNameBackground:SetPoint("LEFT", frame.SpellName, "LEFT",
		-private.db.profile.text_settings.backgroundTextureOffset.x, 0)
	frame.SpellNameBackground:SetPoint("RIGHT", frame.SpellName, "RIGHT",
		private.db.profile.text_settings.backgroundTextureOffset.x, 0)
	frame.SpellNameBackground:SetPoint("TOP", frame.SpellName, "TOP", 0,
		private.db.profile.text_settings.backgroundTextureOffset.y)
	frame.SpellNameBackground:SetPoint("BOTTOM", frame.SpellName, "BOTTOM", 0,
		-private.db.profile.text_settings.backgroundTextureOffset.y)
	frame.SpellNameBackground:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	frame.SpellNameBackground:Hide()

	frame.RoleIcons = {}

	for i = 1, 4 do
		local texture = frame.TextureHolder:CreateTexture(nil, "ARTWORK")
		texture:SetPoint("LEFT", frame.TextureHolder, "RIGHT", 18 * (i - 1), 0)
		texture:SetSize(16, 16)
		texture:Show()
		table.insert(frame.RoleIcons, texture)
	end

	frame.DangerIcon = {}

	local dangerTexture = frame.TextureHolder:CreateTexture(nil, "ARTWORK")
	dangerTexture:SetSize(16, 16)
	dangerTexture:SetPoint("CENTER", frame.TextureHolder, "TOPLEFT", 0, 0)
	dangerTexture:Show()
	table.insert(frame.DangerIcon, dangerTexture)

	frame.DispellTypeIcons = {}

	local dispellTypeTexture = frame.TextureHolder:CreateTexture(nil, "ARTWORK")
	dispellTypeTexture:SetPoint("BOTTOMRIGHT", frame.TextureHolder, "BOTTOMRIGHT", -3, 3)
	dispellTypeTexture:SetSize(16, 16)
	dispellTypeTexture:Show()
	table.insert(frame.DispellTypeIcons, dispellTypeTexture)

	frame.DispellTypeBorderEdges = {}

	for i, value in pairs(private.dispellTypeList) do
		local topTexture = frame.TextureHolder:CreateTexture(nil, "BORDER")
		topTexture:SetPoint("TOPLEFT", frame.TextureHolder, "TOPLEFT", 0, 0)
		topTexture:SetPoint("TOPRIGHT", frame.TextureHolder, "TOPRIGHT", 0, 0)
		topTexture:SetHeight(3)
		topTexture:Show()

		-- Bottom edge
		local bottomTexture = frame.TextureHolder:CreateTexture(nil, "BORDER")
		bottomTexture:SetPoint("BOTTOMLEFT", frame.TextureHolder, "BOTTOMLEFT", 0, 0)
		bottomTexture:SetPoint("BOTTOMRIGHT", frame.TextureHolder, "BOTTOMRIGHT", 0, 0)
		bottomTexture:SetHeight(3)
		bottomTexture:Show()

		-- Left edge
		local leftTexture = frame.TextureHolder:CreateTexture(nil, "BORDER")
		leftTexture:SetPoint("TOPLEFT", frame.TextureHolder, "TOPLEFT", 0, 0)
		leftTexture:SetPoint("BOTTOMLEFT", frame.TextureHolder, "BOTTOMLEFT", 0, 0)
		leftTexture:SetWidth(3)
		leftTexture:Show()

		-- Right edge
		local rightTexture = frame.TextureHolder:CreateTexture(nil, "BORDER")
		rightTexture:SetPoint("TOPRIGHT", frame.TextureHolder, "TOPRIGHT", 0, 0)
		rightTexture:SetPoint("BOTTOMRIGHT", frame.TextureHolder, "BOTTOMRIGHT", 0, 0)
		rightTexture:SetWidth(3)
		rightTexture:Show()

		frame.DispellTypeBorderEdges[i] = { topTexture, bottomTexture, leftTexture, rightTexture }
	end


	---@class AtBigIcon : AceGUIWidget
	local widget = {
		OnAcquire = OnAcquire,
		OnRelease = OnRelease,
		type = Type,
		count = count,
		frame = frame,
		SetEventInfo = SetEventInfo,
		HandleCooldown = HandleCooldown,
		ApplySettings = ApplySettings,
	}

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
