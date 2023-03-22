local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local random = random
local strmatch = strmatch
local CreateFrame = CreateFrame
local UnitIsTapDenied = UnitIsTapDenied
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsCharmed = UnitIsCharmed
local UnitIsEnemy = UnitIsEnemy

function UF.HealthClipFrame_OnUpdate(clipFrame)
	UF.HealthClipFrame_HealComm(clipFrame.__frame)

	clipFrame:SetScript('OnUpdate', nil)
end

function UF:Construct_HealthBar(frame, bg, text, textPos)
	local health = CreateFrame('StatusBar', '$parent_HealthBar', frame)
	UF.statusbars[health] = true

	health:SetFrameLevel(10) --Make room for Portrait and Power which should be lower by default
	health.PostUpdate = UF.PostUpdateHealth
	health.PostUpdateColor = UF.PostUpdateHealthColor

	if bg then
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints()
		health.bg:SetTexture(E.media.blankTex)
		health.bg.multiplier = 0.35
	end

	if text then
		health.value = UF:CreateRaisedText(frame.RaisedElementParent)
		health.value:Point(textPos, health, textPos, textPos == 'LEFT' and 2 or -2, 0)
	end

	health:CreateBackdrop(nil, nil, nil, nil, true)

	local clipFrame = UF:Construct_ClipFrame(frame, health)
	clipFrame:SetScript('OnUpdate', UF.HealthClipFrame_OnUpdate)

	return health
end

function UF:Configure_HealthBar(frame)
	local db = frame.db
	local health = frame.Health

	health:SetColorTapping(true)
	health:SetColorDisconnected(true)
	E:SetSmoothing(health, UF.db.smoothbars)

	--Text
	if db.health and health.value then
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.health.attachTextTo)
		health.value:ClearAllPoints()
		health.value:Point(db.health.position, attachPoint, db.health.position, db.health.xOffset, db.health.yOffset)
		frame:Tag(health.value, db.health.text_format)
	end

	--Colors
	local colorSelection
	health.colorSmooth = nil
	health.colorHealth = nil
	health.colorClass = nil
	health.colorReaction = nil

	if db.colorOverride and db.colorOverride == 'FORCE_ON' then
		health.colorClass = true
		health.colorReaction = true
	elseif db.colorOverride and db.colorOverride == 'FORCE_OFF' then
		if UF.db.colors.colorhealthbyvalue then
			health.colorSmooth = true
		else
			health.colorHealth = true
		end
	else
		if E.Retail and UF.db.colors.healthselection then
			colorSelection = true
		elseif UF.db.colors.healthclass ~= true then
			if UF.db.colors.colorhealthbyvalue then
				health.colorSmooth = true
			else
				health.colorHealth = true
			end
		else
			health.colorClass = (not UF.db.colors.forcehealthreaction)
			health.colorReaction = true
		end
	end

	health:SetColorSelection(colorSelection)

	--Position
	health:ClearAllPoints()
	health.WIDTH = db.width
	health.HEIGHT = db.height

	if frame.ORIENTATION == 'LEFT' then
		health:Point('TOPRIGHT', frame, 'TOPRIGHT', -UF.BORDER - UF.SPACING - (frame.PVPINFO_WIDTH or 0), -UF.BORDER - UF.SPACING - frame.CLASSBAR_YOFFSET)

		if frame.USE_POWERBAR_OFFSET then
			health:Point('TOPRIGHT', frame, 'TOPRIGHT', -UF.BORDER - UF.SPACING - frame.POWERBAR_OFFSET, -UF.BORDER - UF.SPACING - frame.CLASSBAR_YOFFSET)
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', frame.PORTRAIT_WIDTH + UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET)

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET) - (UF.BORDER + UF.SPACING + frame.PORTRAIT_WIDTH)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET)
		elseif frame.POWERBAR_DETACHED or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR then
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', frame.PORTRAIT_WIDTH + UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0)) - (UF.BORDER + UF.SPACING + frame.PORTRAIT_WIDTH)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)
		elseif frame.USE_MINI_POWERBAR then
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', frame.PORTRAIT_WIDTH + UF.BORDER + UF.SPACING, UF.SPACING + (frame.POWERBAR_HEIGHT*0.5))

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0)) - (UF.BORDER + UF.SPACING + frame.PORTRAIT_WIDTH)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.SPACING + frame.POWERBAR_HEIGHT * 0.5)
		else
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', frame.PORTRAIT_WIDTH + UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0)) - (UF.BORDER + UF.SPACING + frame.PORTRAIT_WIDTH)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)
		end
	elseif frame.ORIENTATION == 'RIGHT' then
		health:Point('TOPLEFT', frame, 'TOPLEFT', UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0), -UF.BORDER - UF.SPACING - frame.CLASSBAR_YOFFSET)

		if frame.USE_POWERBAR_OFFSET then
			health:Point('TOPLEFT', frame, 'TOPLEFT', UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET, -UF.BORDER - UF.SPACING - frame.CLASSBAR_YOFFSET)
			health:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -frame.PORTRAIT_WIDTH - UF.BORDER - UF.SPACING, UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET)

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET) - (UF.BORDER + UF.SPACING + frame.PORTRAIT_WIDTH)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET)
		elseif frame.POWERBAR_DETACHED or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR then
			health:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -frame.PORTRAIT_WIDTH - UF.BORDER - UF.SPACING, UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0)) - (UF.BORDER + UF.SPACING + frame.PORTRAIT_WIDTH)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)
		elseif frame.USE_MINI_POWERBAR then
			health:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -frame.PORTRAIT_WIDTH - UF.BORDER - UF.SPACING, UF.SPACING + (frame.POWERBAR_HEIGHT*0.5))

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0)) - (UF.BORDER + UF.SPACING + frame.PORTRAIT_WIDTH)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.SPACING + frame.POWERBAR_HEIGHT * 0.5)
		else
			health:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -frame.PORTRAIT_WIDTH - UF.BORDER - UF.SPACING, UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0)) - (UF.BORDER + UF.SPACING + frame.PORTRAIT_WIDTH)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)
		end
	elseif frame.ORIENTATION == 'MIDDLE' then
		health:Point('TOPRIGHT', frame, 'TOPRIGHT', -UF.BORDER - UF.SPACING - (frame.PVPINFO_WIDTH or 0), -UF.BORDER - UF.SPACING - frame.CLASSBAR_YOFFSET)

		if frame.USE_POWERBAR_OFFSET then
			health:Point('TOPRIGHT', frame, 'TOPRIGHT', -UF.BORDER - UF.SPACING - frame.POWERBAR_OFFSET, -UF.BORDER - UF.SPACING - frame.CLASSBAR_YOFFSET)
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET, UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET)

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET) - (UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.BORDER + UF.SPACING + frame.POWERBAR_OFFSET)
		elseif frame.POWERBAR_DETACHED or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR then
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0)) - (UF.BORDER + UF.SPACING)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)
		elseif frame.USE_MINI_POWERBAR then
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', UF.BORDER + UF.SPACING, UF.SPACING + (frame.POWERBAR_HEIGHT*0.5))

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0)) - (UF.BORDER + UF.SPACING)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.SPACING + frame.POWERBAR_HEIGHT * 0.5)
		else
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', frame.PORTRAIT_WIDTH + UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)

			health.WIDTH = health.WIDTH - (UF.BORDER + UF.SPACING + (frame.PVPINFO_WIDTH or 0)) - (UF.BORDER + UF.SPACING + frame.PORTRAIT_WIDTH)
			health.HEIGHT = health.HEIGHT - (UF.BORDER + UF.SPACING + frame.CLASSBAR_YOFFSET) - (UF.BORDER + UF.SPACING + frame.BOTTOM_OFFSET)
		end
	end

	if db.health then
		--Party/Raid Frames allow to change statusbar orientation
		if db.health.orientation then
			health:SetOrientation(db.health.orientation)
		end

		health:SetReverseFill(db.health.reverseFill)
	end

	UF:ToggleTransparentStatusBar(UF.db.colors.transparentHealth, frame.Health, frame.Health.bg, true, nil, db.health and db.health.reverseFill)

	UF:Configure_FrameGlow(frame)

	if frame:IsElementEnabled('Health') then
		frame.Health:ForceUpdate()
	end
end

function UF:GetHealthBottomOffset(frame)
	local bottomOffset = 0
	if frame.USE_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_INSET_POWERBAR then
		bottomOffset = bottomOffset + frame.POWERBAR_HEIGHT - (UF.BORDER-UF.SPACING)
	end
	if frame.USE_INFO_PANEL then
		bottomOffset = bottomOffset + frame.INFO_PANEL_HEIGHT - (UF.BORDER-UF.SPACING)
	end

	return bottomOffset
end

local HOSTILE_REACTION = 2

function UF:PostUpdateHealthColor(unit, r, g, b)
	local parent = self:GetParent()
	local colors = E.db.unitframe.colors

	local isTapped = UnitIsTapDenied(unit)
	local isDeadOrGhost = UnitIsDeadOrGhost(unit)
	local healthBreak = not isTapped and colors.healthBreak

	if not b then r, g, b = colors.health.r, colors.health.g, colors.health.b end
	local newr, newg, newb -- fallback for bg if custom settings arent used
	if ((colors.healthclass and colors.colorhealthbyvalue) or (colors.colorhealthbyvalue and parent.isForced)) and not isTapped then
		newr, newg, newb = ElvUF:ColorGradient(self.cur, self.max, 1, 0, 0, 1, 1, 0, r, g, b)
		self:SetStatusBarColor(newr, newg, newb)
	elseif healthBreak and healthBreak.enabled then
		local breakPoint = self.max > 0 and (self.cur / self.max) or 1
		local onlyLow, color = healthBreak.onlyLow

		if breakPoint <= healthBreak.low then
			color = healthBreak.bad
		elseif breakPoint >= healthBreak.high and breakPoint ~= 1 and not onlyLow then
			color = healthBreak.good
		elseif breakPoint >= healthBreak.low and breakPoint < healthBreak.high and not onlyLow then
			color = colors.healthBreak.neutral
		end

		if color then
			self:SetStatusBarColor(color.r, color.g, color.b)
		end
	end

	-- Charmed player should have hostile color
	if unit and (strmatch(unit, "raid%d+") or strmatch(unit, "party%d+")) then
		if not isDeadOrGhost and UnitIsConnected(unit) and UnitIsCharmed(unit) and UnitIsEnemy("player", unit) then
			local color = parent.colors.reaction[HOSTILE_REACTION]
			if color then self:SetStatusBarColor(color.r, color.g, color.b) end
		end
	end

	if self.bg then
		self.bg.multiplier = (colors.healthMultiplier > 0 and colors.healthMultiplier) or 0.35

		if colors.useDeadBackdrop and isDeadOrGhost then
			self.bg:SetVertexColor(colors.health_backdrop_dead.r, colors.health_backdrop_dead.g, colors.health_backdrop_dead.b)
		elseif colors.customhealthbackdrop then
			self.bg:SetVertexColor(colors.health_backdrop.r, colors.health_backdrop.g, colors.health_backdrop.b)
		elseif colors.classbackdrop then
			local reaction, color = (UnitReaction(unit, 'player'))

			if UnitIsPlayer(unit) then
				local _, Class = UnitClass(unit)
				color = parent.colors.class[Class]
			elseif reaction then
				color = parent.colors.reaction[reaction]
			end

			if color then
				self.bg:SetVertexColor(color.r * self.bg.multiplier, color.g * self.bg.multiplier, color.b * self.bg.multiplier)
			end
		elseif newb then
			self.bg:SetVertexColor(newr * self.bg.multiplier, newg * self.bg.multiplier, newb * self.bg.multiplier)
		else
			self.bg:SetVertexColor(r * self.bg.multiplier, g * self.bg.multiplier, b * self.bg.multiplier)
		end
	end
end

function UF:PostUpdateHealth(_, cur)
	local parent = self:GetParent()
	if parent.isForced then
		self.cur = random(1, 100)
		self.max = 100
		self:SetMinMaxValues(0, self.max)
		self:SetValue(self.cur)
	elseif parent.ResurrectIndicator then
		parent.ResurrectIndicator:SetAlpha(cur == 0 and 1 or 0)
	end
end
