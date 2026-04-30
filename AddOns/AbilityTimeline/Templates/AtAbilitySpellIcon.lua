local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "AtAbilitySpellIcon"
local Version = 1
local variables = {
	IconSize = {
		width = 44,
		height = 44,
	},
	IconZoom = 0.7,
	TextOffset = {
		x = 10,
		y = 0,
	}
}

private.TEXT_RELATIVE_POSITIONS = {
	RIGHT = "LEFT",
	LEFT = "RIGHT",
	TOP = "BOTTOM",
	BOTTOM = "TOP",
}

setmetatable(private.TEXT_RELATIVE_POSITIONS, {
	__index = function(_, key)
		error(string.format(private.getLocalisation('InvalidTextPosition') .. "%s", tostring(key)), 2);
	end,
})
---handles the Text anchoring depending on the selected text anchor
---@param self Frame
---@param isStopped boolean
local handleAnchors      = function(self, isStopped)
	self.SpellName:ClearAllPoints()
	local relPos, anchorPos, xOffset, yOffset
	if isStopped then
		relPos = private.db.profile.text_settings.text_anchor
		anchorPos = private.TEXT_RELATIVE_POSITIONS
			[private.db.profile.text_settings.text_anchor]
	else
		relPos = private.TEXT_RELATIVE_POSITIONS[private.db.profile.text_settings.text_anchor]
		anchorPos = private.db.profile.text_settings.text_anchor
	end

	if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction == private.TIMELINE_DIRECTIONS.HORIZONTAL then
		-- in horizontal mode we need to adjust position accordingly
		if relPos == 'LEFT' then
			relPos = 'TOP'
		else
			relPos = 'BOTTOM'
		end
		if anchorPos == 'LEFT' then
			anchorPos = 'TOP'
		else
			anchorPos = 'BOTTOM'
		end
	end

	if relPos == 'LEFT' then
		if private.db.profile.icon_settings and private.db.profile.icon_settings.TextOffset then
			xOffset = private.db.profile.icon_settings.TextOffset.x
			yOffset = private.db.profile.icon_settings.TextOffset.y
		else
			xOffset = variables.TextOffset.x
			yOffset = variables.TextOffset.y
		end
	elseif relPos == 'RIGHT' then
		if private.db.profile.icon_settings and private.db.profile.icon_settings.TextOffset then
			xOffset = -private.db.profile.icon_settings.TextOffset.x
			yOffset = -private.db.profile.icon_settings.TextOffset.y
		else
			xOffset = -variables.TextOffset.x
			yOffset = -variables.TextOffset.y
		end
	elseif relPos == 'TOP' then
		if private.db.profile.icon_settings and private.db.profile.icon_settings.TextOffset then
			xOffset = private.db.profile.icon_settings.TextOffset.y
			yOffset = -private.db.profile.icon_settings.TextOffset.x
		else
			xOffset = variables.TextOffset.y
			yOffset = -variables.TextOffset.x
		end
	else -- BOTTOM
		if private.db.profile.icon_settings and private.db.profile.icon_settings.TextOffset then
			xOffset = -private.db.profile.icon_settings.TextOffset.y
			yOffset = private.db.profile.icon_settings.TextOffset.x
		else
			xOffset = -variables.TextOffset.y
			yOffset = variables.TextOffset.x
		end
	end
	self.SpellName:SetPoint(relPos, self, anchorPos, xOffset, yOffset)
	for _, texture in pairs(self.DangerIcon) do
		texture:ClearAllPoints()
		texture:SetPoint(relPos, self, anchorPos, 0, 0)
	end

	for i, texture in pairs(self.RoleIcons) do
		texture:ClearAllPoints()
		texture:SetPoint(anchorPos, self, relPos, 18 * (i - 1), 0)
	end
end
---returns a raw icon position without any overlap handling
---@param iconSize number -- the size of the icon
---@param moveHeight number -- the total height of the timeline for position calculation
---@param remainingDuration number -- remaining duration of the icon
---@param isStopped boolean -- whether the icon is currently stopped (paused/blocked)
---@return integer -- x position
---@return integer -- y position
---@return boolean -- is moving
local getRawIconPosition = function(iconSize, moveHeight, remainingDuration, isStopped)
	local timelineOtherPosition = 0
	local timelineMainPosition = 0
	local isMoving = false
	if isStopped then
		if private.db.profile.text_settings.text_anchor == 'RIGHT' then
			timelineOtherPosition = 0 - iconSize -
				private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
		else
			timelineOtherPosition = iconSize +
				private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
		end
	end
	if not (remainingDuration < private.AT_THRESHHOLD_TIME) then
		-- We are out of range of the moving timeline
		if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].inverse_travel_direction then
			timelineMainPosition = 0 - (iconSize / 2)
		else
			timelineMainPosition = moveHeight + (iconSize / 2)
		end
	else
		if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].inverse_travel_direction then
			timelineMainPosition = moveHeight - ((remainingDuration) / private.AT_THRESHHOLD_TIME) * moveHeight -
				(iconSize / 2)
			isMoving = true
		else
			timelineMainPosition = ((remainingDuration) / private.AT_THRESHHOLD_TIME) * moveHeight + (iconSize / 2)
			isMoving = true
		end
	end
	if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction == private.TIMELINE_DIRECTIONS.HORIZONTAL then
		return timelineMainPosition, timelineOtherPosition, isMoving
	else
		return timelineOtherPosition, timelineMainPosition, isMoving
	end
end


---set state to blocked for blocked events
---@param eventID EncounterTimelineEventID
---@param duration number
---@param timeElapsed number
---@param timeRemaining number
---@return EncounterTimelineEventState state
local fixStateForBlocked = function(eventID, duration, timeElapsed, timeRemaining)
	local state = C_EncounterTimeline.GetEventState(eventID)
	local isBlocked = C_EncounterTimeline.IsEventBlocked(eventID)
	if C_CVar.GetCVar("encounterTimelineHideQueuedCountdowns") == "1" then
		return state
	elseif state == private.ENCOUNTER_STATES.Active and isBlocked then
		return private.ENCOUNTER_STATES.Blocked
	elseif not timeElapsed or not timeRemaining or timeRemaining == 0 or timeElapsed >= duration then
		return private.ENCOUNTER_STATES.Blocked
	else
		return state
	end
end
---Returns if an icon is currently in a non moving state
---@param state EncounterTimelineEventState
---@return boolean
local function isStoppedForPosition(state)
	return state == private.ENCOUNTER_STATES.Paused or state == private.ENCOUNTER_STATES.Blocked
end

-- TODO FIX THIS We should use something similar to the "dynamic group" idea of WeakAuras
-- Currently the offset is ignored when calculating if a conflict is happening. The official timeline also does no conflict resolving and just overlaps icons so maybe we should do the same?
local calculateOffset       = function(iconSize, timelineHeight, sourceEventID, sourceTimeElapsed, rawSourcePosX,
									   rawSourcePosY)
	local eventList = C_EncounterTimeline.GetEventList()
	local totalEvents = 0
	local conflictingYEvents = 0
	local shorterYConflictingEvents = 0
	local conflictingXEvents = 0
	local shorterXConflictingEvents = 0
	local sourceEventInfo = C_EncounterTimeline.GetEventInfo(sourceEventID)
	local sourceRemainingTime = C_EncounterTimeline.GetEventTimeRemaining(sourceEventID)
	local sourceState = fixStateForBlocked(sourceEventID, sourceEventInfo.duration, sourceTimeElapsed,
		sourceRemainingTime)
	local sourceUpperXBound = rawSourcePosX + (iconSize / 2) +
		private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
	local sourceLowerXBound = rawSourcePosX - (iconSize / 2) -
		private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
	local sourceUpperYBound = rawSourcePosY + (iconSize / 2) +
		private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
	local sourceLowerYBound = rawSourcePosY - (iconSize / 2) -
		private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
	for _, eventID in pairs(eventList) do
		if eventID ~= sourceEventID and private.activeFrames[eventID] then
			local timeElapsed = C_EncounterTimeline.GetEventTimeElapsed(eventID)
			local eventInfo = C_EncounterTimeline.GetEventInfo(eventID)
			local remainingTime = C_EncounterTimeline.GetEventTimeRemaining(eventID)
			local state = fixStateForBlocked(eventID, eventInfo.duration, timeElapsed, remainingTime)
			if sourceState == state then
				totalEvents = totalEvents + 1
				local x, y = getRawIconPosition(iconSize, timelineHeight, remainingTime,
					isStoppedForPosition(state))
				local upperXBound = x + iconSize / 2 +
					private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
				local lowerXBound = x - iconSize / 2 -
					private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
				local upperYBound = y + iconSize / 2 +
					private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
				local lowerYBound = y - iconSize / 2 -
					private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin
				if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction == private.TIMELINE_DIRECTIONS.VERTICAL then
					if upperYBound >= sourceLowerYBound and upperYBound <= sourceUpperYBound or
						lowerYBound >= sourceLowerYBound and lowerYBound <= sourceUpperYBound then
						conflictingYEvents = conflictingYEvents + 1
						-- use eventID as tiebreaker to have a consistent order
						if remainingTime < sourceRemainingTime or (remainingTime == sourceRemainingTime and eventID < sourceEventID) then
							shorterYConflictingEvents = shorterYConflictingEvents + 1
						end
					end
				else
					if upperXBound >= sourceLowerXBound and upperXBound <= sourceUpperXBound or
						lowerXBound >= sourceLowerXBound and lowerXBound <= sourceUpperXBound then
						conflictingXEvents = conflictingXEvents + 1
						-- use eventID as tiebreaker to have a consistent order
						if remainingTime < sourceRemainingTime or (remainingTime == sourceRemainingTime and eventID < sourceEventID) then
							shorterXConflictingEvents = shorterXConflictingEvents + 1
						end
					end
				end
			end
		end
	end
	return
		shorterXConflictingEvents *
		(iconSize + private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin),
		shorterYConflictingEvents *
		(iconSize + private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].iconMargin)
end

---comment
---@param self AtAbilitySpellIcon
---@param timeElapsed number -- time elapsed since the ability was started
---@param moveHeight number -- total height of the timeline for position calculation
---@param isStopped boolean -- whether the icon is currently stopped (paused/blocked)
---@return integer x -- xPosition of an icon including potential offsets to handle overlaps
---@return integer y -- yPosition of an icon including potential offsets to handle overlaps
---@return boolean ismoving -- whether the icon is currently moving
local calculateIconPosition = function(self, timeElapsed, moveHeight, isStopped)
	local iconSize = private.db.profile.icon_settings and private.db.profile.icon_settings.size or variables.IconSize.height
	local x, y, isMoving = getRawIconPosition(iconSize, moveHeight,
		self.eventInfo.duration - timeElapsed, isStopped)
	if self.eventInfo.duration - timeElapsed > private.AT_THRESHHOLD_TIME or isStopped then
		-- only add offset for waiting icons
		local xOffset, yOffset = calculateOffset(iconSize, moveHeight, self.eventInfo.id, timeElapsed, x,
			y)
		if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].inverse_travel_direction then
			return x - xOffset, y - yOffset, isMoving
		end
		return x + xOffset, y + yOffset, isMoving
	end
	return x, y, isMoving
end
---Plays a short highlight animation
---@param self Frame
local PlayHighlight         = function(self)
	private.EnableGlow(self, private.GlowTypes.PROC, 0.5)
end
---Handles the cooldown display for a given frame (the frame needs to be the frame of a AtAbilitySpellIcon widget)
---@param self frame
---@param remainingTime number
local HandleCooldown        = function(self, remainingTime)
	local formatedTime = remainingTime
	if formatedTime <= 0 then
		self.Cooldown:SetText("")
		return
	end
	if remainingTime > 60 then
		local seconds = remainingTime % 60
		if seconds > 30 then
			formatedTime = math.ceil(remainingTime / 60) .. "m"
		else
			formatedTime = math.floor(remainingTime / 60) .. "m"
		end
	else
		formatedTime = math.ceil(remainingTime)
	end
	self.Cooldown:SetText(formatedTime)
	if private.db.profile.cooldown_settings.cooldown_highlight and private.db.profile.cooldown_settings.cooldown_highlight.enabled then
		for _, value in pairs(private.db.profile.cooldown_settings.cooldown_highlight.highlights) do
			local time, color = value.time, value.color
			if (remainingTime <= time) then
				self.Cooldown:SetTextColor(color.r, color.g, color.b)
				if value.useGlow then
					private.EnableGlow(self, value.glowType, time, value.glowColor)
				end
				return
			end
		end
	end
	if private.db.profile.cooldown_settings.cooldown_color then
		self.Cooldown:SetTextColor(
			private.db.profile.cooldown_settings.cooldown_color.r,
			private.db.profile.cooldown_settings.cooldown_color.g,
			private.db.profile.cooldown_settings.cooldown_color.b
		)
	else
		self.Cooldown:SetTextColor(1, 1, 1)
	end
end

---Sets the event info and all associated handling for an icon
---@param self AtAbilitySpellIcon
---@param eventInfo EncounterTimelineEventInfo
---@param disableOnUpdate boolean -- if true, the OnUpdate script will not be set
local SetEventInfo          = function(self, eventInfo, disableOnUpdate)
	self:ApplySettings()
	self.frame.eventInfo = eventInfo
	self.frame.SpellIcon:SetTexture(eventInfo.iconFileID)
	private.Debug("============================")
	if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction == private.TIMELINE_DIRECTIONS.HORIZONTAL then
		self.frame.SpellName:SetText("")
		if eventInfo and eventInfo.id then
			private.Debug("Timeline is in horizontal mode, hiding text for eventID: " .. eventInfo.id)
		end
	else
		self.frame.SpellName:SetText(eventInfo.spellName)
		if private.db.profile.text_settings.useEventColor then
			if issecretvalue(eventInfo.icons) then
				self.frame.SpellName:SetTextColor(eventInfo.color.r, eventInfo.color.g, eventInfo.color.b)
				local r,g,b = eventInfo.color:GetRGB()
				private.Debug("Using event color for text for eventID: " .. eventInfo.id.. " with RGB values R: " .. r .. " G: " .. g .. " B: " .. b	)
			elseif eventInfo.id and private.BossModsColors and private.BossModsColors[eventInfo.id] and private.BossModsColors[eventInfo.id].textColor then
				local color = private.BossModsColors[eventInfo.id].textColor
				self.frame.SpellName:SetTextColor(color.r, color.g, color.b)
				private.Debug("Found text color for bossmods event, applying to text for timer event")
				private.Debug("Color values - R: " .. color.r .. " G: " .. color.g .. " B: " .. color.b)
			elseif private.db.profile.dispellTextColor and eventInfo.icons and eventInfo.icons ~= 0 then
				local colorHasBeenSet = false
				for _, value in pairs(private.dispellTypeList) do
					if bit.band(eventInfo.icons, value.mask) ~= 0 then
						self.frame.SpellName:SetTextColor(value.color.r, value.color.g, value.color.b)
						colorHasBeenSet = true
						private.Debug("Found dispell type for event, applying its color to the text for eventID: " .. eventInfo.id.. " with RGB values R: " .. value.color.r .. " G: " .. value.color.g .. " B: " .. value.color.b	)
						break -- Only set the first matching color
					end
				end
				if not colorHasBeenSet then
					local r,g,b = eventInfo.color:GetRGB()
					private.Debug("No dispell type found for event, using event text color for eventID: " .. eventInfo.id.. " with RGB values R: " .. r .. " G: " .. g .. " B: " .. b	)				
					self.frame.SpellName:SetTextColor(eventInfo.color.r, eventInfo.color.g, eventInfo.color.b)
				else
					private.Debug("color was set")
				end
			elseif not disableOnUpdate then
				private.Debug("Not using  color for text for eventID: " .. eventInfo.id)			
			end
		elseif not disableOnUpdate then
			private.Debug("Event coloring disabled for text for eventID: " .. eventInfo.id)
		end
	end
	-- OnUpdate we want to update the position of the icon based on elapsed time
	self.frame.frameIsMoving = false
	if not disableOnUpdate then
		private.Debug("Setting event info for eventID: " .. eventInfo.id .. " with spell name: " .. eventInfo.spellName)
		local EventIconTextureID = eventInfo.id
		if eventInfo.source == Enum.EncounterTimelineEventSource.Script and private.BossModsSpellIndicators and private.BossModsSpellIndicators[eventInfo.id] then
			private.Debug("Found spell indicator for bossmods event, using its icons for the Textures")
			EventIconTextureID = private.BossModsSpellIndicators[eventInfo.id]	
		elseif eventInfo.source == Enum.EncounterTimelineEventSource.Script then
			private.Debug("No spell indicator for bossmods event, using event icon for the Textures")
		end
		if private.db.profile.icon_settings.dispellIcons then
			C_EncounterTimeline.SetEventIconTextures(EventIconTextureID, 126, self.frame.dispellTypeIcons)
		end
		if private.db.profile.icon_settings.border == private.IconBorderSettings.dispell then
			for i, dispellValue in ipairs(private.dispellTypeList) do
				for _, edgeTexture in ipairs(self.frame.DispellTypeBorderEdges[i]) do
					local textureArray = {}
					table.insert(textureArray, edgeTexture)
					C_EncounterTimeline.SetEventIconTextures(EventIconTextureID, dispellValue.mask, textureArray)
					edgeTexture:SetTexture(nil)
					edgeTexture:SetColorTexture(dispellValue.color.r, dispellValue.color.g, dispellValue.color.b,
						dispellValue.color.a)
				end
			end
		elseif private.db.profile.icon_settings.border == private.IconBorderSettings.bossmods and private.BossModsColors[eventInfo.id] and private.BossModsColors[eventInfo.id].borderColor then
			private.Debug("Found border color for bossmods event, applying to border for timer event")
			local color = private.BossModsColors[eventInfo.id].borderColor
			for _, edgeTexture in pairs(self.frame.BossModsBorderEdges) do
                edgeTexture:SetColorTexture(color.r, color.g, color.b, color.a)
				edgeTexture:Show()
            end
		else
			private.Debug("No border color found for bossmods event, using no border for timer event".. eventInfo.id)
			for _, edgeTexture in pairs(self.frame.BossModsBorderEdges) do
				edgeTexture:Hide()
            end
		end

		if private.db.profile.icon_settings.roleIcons then
			C_EncounterTimeline.SetEventIconTextures(EventIconTextureID, 896, self.frame.RoleIcons)
		end

		if private.db.profile.icon_settings.dangerIcon then
			C_EncounterTimeline.SetEventIconTextures(EventIconTextureID, 1, self.frame.DangerIcon)
		end
		self.frame:SetScript("OnUpdate", function(self)
			local timeElapsed = C_EncounterTimeline.GetEventTimeElapsed(self.eventInfo.id)
			local timeRemaining = C_EncounterTimeline.GetEventTimeRemaining(self.eventInfo.id)
			local state = fixStateForBlocked(self.eventInfo.id, self.eventInfo.duration, timeElapsed, timeRemaining)
			local isStopped = isStoppedForPosition(state)
			if not timeElapsed or timeElapsed < 0 then timeElapsed = self.eventInfo.duration end
			if not timeRemaining or timeRemaining < 0 or state == private.ENCOUNTER_STATES.Active and timeRemaining == 0 then
				private.removeAtIconFrame(self.eventInfo.id, 'PlayFinishAnimation')
				return
			end
			self.isStopped = isStopped
			if state ~= self.state then
				self.state = state
				handleAnchors(self, isStopped)
			elseif state == private.ENCOUNTER_STATES.Paused then
				return
			end

			HandleCooldown(self, timeRemaining)

			local xPos, yPos, isMoving = calculateIconPosition(self, timeElapsed, private.TIMELINE_FRAME:GetMoveSize(),
				isStopped)
			if self.frameIsMoving ~= isMoving then
				if isMoving then
					--self.TrailAnimation:Play()
					--self.HighlightAnimation:Play()
				else
					--self.TrailAnimation:Stop()
				end
				self.frameIsMoving = isMoving
			end
			if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction == private.TIMELINE_DIRECTIONS.HORIZONTAL then
				self:SetPoint("CENTER", private.TIMELINE_FRAME.frame, "LEFT", xPos, yPos)
			else
				self:SetPoint("CENTER", private.TIMELINE_FRAME.frame, "BOTTOM", xPos, yPos)
			end
			for tick, time in ipairs(private.TIMELINE_TICKS) do
				local inRange = (eventInfo.duration - timeElapsed - time)
				if inRange < 0.01 and inRange > -0.01 then -- this is not gonna work if fps are to low
					-- self.IconContainer.HighlightAnimation:Play()
					PlayHighlight(self)
				end
			end

			local inBigIconRange = (eventInfo.duration - timeElapsed - private.BIGICON_THRESHHOLD_TIME)
			if inBigIconRange < 0.01 and inBigIconRange > -0.01 then -- this is not gonna work if fps are to low
				private.TRIGGER_HIGHLIGHT(self.eventInfo)
			end
		end)
	end
	self.frame:Show()

	if private.db.profile.icon_settings and private.db.profile.icon_settings.useTooltip and private.db.profile.icon_settings.useTooltip ~= Enum.EncounterEventsTooltipAnchor.Hidden then
		private.AddEventTooltip(self.frame, eventInfo, private.db.profile.icon_settings.useTooltip)
	end
end

local function ApplySettings(self)
	-- Apply settings to the icon
	if private.db.profile.icon_settings and private.db.profile.icon_settings.size then
		self.frame:SetSize(private.db.profile.icon_settings.size, private.db.profile.icon_settings.size)
	else
		self.frame:SetSize(variables.IconSize.width, variables.IconSize.height)
	end
	if private.db.profile.icon_settings and private.db.profile.icon_settings.TextOffset then
		handleAnchors(self.frame, self.isStopped)
	end
	if private.db.profile.text_settings and private.db.profile.text_settings.font and private.db.profile.text_settings.fontSize and private.db.profile.text_settings.fontFlag then
		local fontFlags = ""
		for flag, isEnabled in pairs(private.db.profile.text_settings.fontFlag) do
			if isEnabled then
				if fontFlags ~= "" then
					fontFlags = fontFlags .. ",".. flag
				else
					fontFlags = flag
				end
			end
		end
		self.frame.SpellName:SetFont(SharedMedia:Fetch("font", private.db.profile.text_settings.font),
			private.db.profile.text_settings.fontSize, fontFlags)
			
	elseif private.db.profile.text_settings and private.db.profile.text_settings.font and private.db.profile.text_settings.fontSize then
		self.frame.SpellName:SetFont(SharedMedia:Fetch("font", private.db.profile.text_settings.font),
			private.db.profile.text_settings.fontSize, "OUTLINE")
	elseif private.db.profile.text_settings and private.db.profile.text_settings.fontSize then
		self.frame.SpellName:SetFontHeight(private.db.profile.text_settings.fontSize)
	end

	if private.db.profile.cooldown_settings and private.db.profile.cooldown_settings.font and private.db.profile.cooldown_settings.fontSize then
		self.frame.Cooldown:SetFont(SharedMedia:Fetch("font", private.db.profile.cooldown_settings.font),
			private.db.profile.cooldown_settings.fontSize, "OUTLINE")
	elseif private.db.profile.cooldown_settings and private.db.profile.cooldown_settings.fontSize then
		self.frame.Cooldown:SetFontHeight(private.db.profile.cooldown_settings.fontSize)
	end

	if private.db.profile.text_settings and private.db.profile.text_settings.defaultColor then
		self.frame.SpellName:SetTextColor(
			private.db.profile.text_settings.defaultColor.r,
			private.db.profile.text_settings.defaultColor.g,
			private.db.profile.text_settings.defaultColor.b
		)
	end

	if private.db.profile.text_settings and private.db.profile.text_settings.enableShadow then
		self.frame.SpellName:SetShadowColor(0, 0, 0, 1)
	else
		self.frame.SpellName:SetShadowColor(0, 0, 0, 0)
	end

	if private.db.profile.icon_settings and private.db.profile.icon_settings.strata then
		self.frame:SetFrameStrata(private.db.profile.icon_settings.strata)
	end

	if not self.frame.SpellIcon.zoomApplied or self.frame.SpellIcon.zoomApplied ~= (1 - private.db.profile.icon_settings.zoom) then
		if self.frame.SpellIcon.zoomApplied then
			private.ResetZoom(self.frame.SpellIcon)
		end
		private.SetZoom(self.frame.SpellIcon, 1 - private.db.profile.icon_settings.zoom)
		self.frame.SpellIcon.zoomApplied = 1 - private.db.profile.icon_settings.zoom
	end

	for i, edges in ipairs(self.frame.DispellTypeBorderEdges) do
		for _, edgeTexture in ipairs(edges) do
			if private.db.profile.icon_settings.border == private.IconBorderSettings.dispell then
				edgeTexture:Show()
			else
				edgeTexture:Hide()
			end
		end
	end

	if private.db.profile.icon_settings.border ~= private.IconBorderSettings.bossmods then
		for _, edgeTexture in pairs(self.frame.BossModsBorderEdges) do
			edgeTexture:Hide()
		end
	end

	for i, texture in ipairs(self.frame.dispellTypeIcons) do
		if private.db.profile.icon_settings.dispellIcons then
			texture:Show()
		else
			texture:Hide()
		end
	end
	for i, texture in ipairs(self.frame.DangerIcon) do
		if private.db.profile.icon_settings.dangerIcon then
			texture:Show()
		else
			texture:Hide()
		end
	end
	for i, texture in ipairs(self.frame.RoleIcons) do
		if private.db.profile.icon_settings.roleIcons then
			texture:Show()
		else
			texture:Hide()
		end
	end
	if private.db.profile.text_settings.useBackground then
		local texture = SharedMedia:Fetch("background", private.db.profile.text_settings.backgroundTexture)
		self.frame.SpellNameBackground:SetPoint("LEFT", self.frame.SpellName, "LEFT",
			-private.db.profile.text_settings.backgroundTextureOffset.x, 0)
		self.frame.SpellNameBackground:SetPoint("RIGHT", self.frame.SpellName, "RIGHT",
			private.db.profile.text_settings.backgroundTextureOffset.x, 0)
		self.frame.SpellNameBackground:SetPoint("TOP", self.frame.SpellName, "TOP", 0,
			private.db.profile.text_settings.backgroundTextureOffset.y)
		self.frame.SpellNameBackground:SetPoint("BOTTOM", self.frame.SpellName, "BOTTOM", 0,
			-private.db.profile.text_settings.backgroundTextureOffset.y)
		self.frame.SpellNameBackground:SetTexture(texture)
		self.frame.SpellNameBackground:Show()
	else
		self.frame.SpellNameBackground:Hide()
	end
end

---@param self AtAbilitySpellIcon
local function OnAcquire(self)
	private.Debug(self.frame, "AT_ABILITY_SPELL_ICON_FRAME_ACQUIRED")
	ApplySettings(self)
end

---@param self AtAbilitySpellIcon
local function OnRelease(self)
	self.frame.eventInfo = nil
	self.frame.SpellIcon:SetTexture(nil)
	self.frame.SpellName:SetText("")
	handleAnchors(self.frame, false)
	self.frame:SetScript("OnUpdate", nil)
	self.frame.frameIsMoving = false
	private.ClearEventTooltip(self.frame)
	for _, edgeTexture in pairs(self.frame.BossModsBorderEdges) do
		edgeTexture:Hide()
	end
end

local function Constructor()
	local count = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", Type .. count, UIParent)
	frame:Show()

	-- spell icon
	frame.SpellIcon = frame:CreateTexture(nil, "BACKGROUND")
	frame.SpellIcon:SetAllPoints(frame)
	frame.SpellIcon:SetPoint("CENTER", frame, "CENTER")

	private.Debug(frame, Type .. count)
	
	frame:SetFrameStrata(private.FrameStrata.FULLSCREEN)
	local borderWidth = 3
	
	frame.BossModsBorderEdges = {}
	
	-- Top edge
	local topEdge = frame:CreateTexture(nil, "ARTWORK")
	topEdge:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	topEdge:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	topEdge:SetHeight(borderWidth)
	topEdge:Hide()
	
	-- Bottom edge
	local bottomEdge = frame:CreateTexture(nil, "ARTWORK")
	bottomEdge:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
	bottomEdge:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	bottomEdge:SetHeight(borderWidth)
	bottomEdge:Hide()
	
	-- Left edge
	local leftEdge = frame:CreateTexture(nil, "ARTWORK")
	leftEdge:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	leftEdge:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
	leftEdge:SetWidth(borderWidth)
	leftEdge:Hide()
	
	-- Right edge
	local rightEdge = frame:CreateTexture(nil, "ARTWORK")
	rightEdge:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	rightEdge:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	rightEdge:SetWidth(borderWidth)
	rightEdge:Hide()
	frame.BossModsBorderEdges = { topEdge, bottomEdge, leftEdge, rightEdge }
	-- spell name
	frame.SpellName = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
	frame.SpellName:Show()
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
	-- cooldown
	frame.Cooldown = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
	frame.Cooldown:SetPoint("CENTER", frame, "CENTER")

	frame.RoleIcons = {}

	for i = 1, 3 do
		local texture = frame:CreateTexture(nil, "OVERLAY")
		texture:SetPoint("LEFT", frame, "RIGHT", 18 * (i - 1), 0)
		texture:SetSize(16, 16)
		texture:Show()
		table.insert(frame.RoleIcons, texture)
	end

	frame.DangerIcon = {}

	local dangerTexture = frame:CreateTexture(nil, "OVERLAY")
	dangerTexture:SetSize(16, 16)
	dangerTexture:SetPoint("CENTER", frame, "TOPLEFT", 0, 0)
	dangerTexture:Show()
	table.insert(frame.DangerIcon, dangerTexture)

	frame.dispellTypeIcons = {}

	local dispellTypeTexture = frame:CreateTexture(nil, "OVERLAY")
	dispellTypeTexture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 3)
	dispellTypeTexture:SetSize(16, 16)
	dispellTypeTexture:Show()
	table.insert(frame.dispellTypeIcons, dispellTypeTexture)

	frame.DispellTypeBorderEdges = {}

	for i, value in pairs(private.dispellTypeList) do
		local topTexture = frame:CreateTexture(nil, "ARTWORK")
		topTexture:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
		topTexture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
		topTexture:SetHeight(3)
		topTexture:Show()

		-- Bottom edge
		local bottomTexture = frame:CreateTexture(nil, "ARTWORK")
		bottomTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
		bottomTexture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
		bottomTexture:SetHeight(3)
		bottomTexture:Show()

		-- Left edge
		local leftTexture = frame:CreateTexture(nil, "ARTWORK")
		leftTexture:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
		leftTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
		leftTexture:SetWidth(3)
		leftTexture:Show()

		-- Right edge
		local rightTexture = frame:CreateTexture(nil, "ARTWORK")
		rightTexture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
		rightTexture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
		rightTexture:SetWidth(3)
		rightTexture:Show()

		frame.DispellTypeBorderEdges[i] = { topTexture, bottomTexture, leftTexture, rightTexture }
	end

	handleAnchors(frame, false)
	---@class AtAbilitySpellIcon : AceGUIWidget
	local widget = {
		OnAcquire = OnAcquire,
		OnRelease = OnRelease,
		type = Type,
		count = count,
		frame = frame,
		eventInfo = {},
		SetEventInfo = SetEventInfo,
		ApplySettings = ApplySettings,
		HandleCooldown = HandleCooldown,
	}

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
