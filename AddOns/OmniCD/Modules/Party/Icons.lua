local E = select(2, ...):unpack()
local P = E.Party

local tonumber, sort, min, max = tonumber, table.sort, math.min, math.max

P.sorters = {
	function(a, b)
		if a.priority == b.priority then
			return a.spellID < b.spellID
		end
		return a.priority > b.priority
	end,
	function(a, b)
		local type1, type2 = E.db.priority[a.type], E.db.priority[b.type]
		if type1 == type2 then
			return P.sorters[1](a, b)
		end
		return type1 > type2
	end,
}

function P:SetIconLayout(frame, sortOrder)
	local icons = frame.icons
	local displayInactive = self.displayInactive

	local sorter = self.sortBy
	if sortOrder then
		local sortFunc = self.sorters[sorter]
		sort(icons, sortFunc)
	end

	local db_prio = E.db.priority
	local count, rows, numActive, lastActiveIndex = 0, 1, 1
	for i = 1, frame.numIcons do
		local icon = icons[i]
		local iconPrio = sorter == 2 and db_prio[icon.type] or icon.priority
		icon:Hide()

		if (displayInactive or icon.active) and (self.multiline or numActive <= self.maxNumIcons) then
			icon:ClearAllPoints()
			if numActive > 1 then
				count = count + 1
				if not self.multiline and count == self.columns or
					(self.multiline and (rows == 1 and iconPrio <= self.breakPoint or (self.tripleline and rows == 2 and iconPrio <= self.breakPoint2))) then
					if self.tripleline and rows == 1 and iconPrio <= self.breakPoint2 then
						rows = rows + 1
					end
					icon:SetPoint(self.point, frame.container, self.ofsX * rows, self.ofsY * rows)
					count = 0
					rows = rows + 1
				else
					icon:SetPoint(self.point2, icons[lastActiveIndex], self.relativePoint2, self.ofsX2, self.ofsY2)
				end
			else
				if self.multiline and iconPrio <= self.breakPoint then
					if self.tripleline and rows == 1 and iconPrio <= self.breakPoint2 then
						rows = rows + 1
					end
					icon:SetPoint(self.point, frame.container, self.ofsX * rows, self.ofsY * rows)
					rows = rows + 1
				else
					icon:SetPoint(self.point, frame.container)
				end
			end

			numActive = numActive + 1
			lastActiveIndex = i

			if not self.multiline or count < self.maxNumIcons then
				icon:Show()
			end
		end
	end
end

function P:SetAnchor(frame)
	local anchorShouldShow = E.db.position.detached and not E.db.position.locked
	if anchorShouldShow or E.db.general.showAnchor then
		frame.anchor:Show()
	else
		frame.anchor:Hide()
	end

	if anchorShouldShow then
		frame.anchor:EnableMouse(true)
		frame.anchor.background:SetColorTexture(0, 0.8, 0, 1)
	else
		frame.anchor:EnableMouse(false)
		frame.anchor.background:SetColorTexture(0.756, 0, 0.012, 0.7)
	end
end

function P:SetIconScale(frame)
	local scale = E.db.icons.scale
	frame.anchor:SetScale(min(max(0.7, scale), 1))
	frame.container:SetScale(scale)
end

function P:SetBorder(icon, db)
	if db.displayBorder then
		icon.borderTop:ClearAllPoints()
		icon.borderBottom:ClearAllPoints()
		icon.borderRight:ClearAllPoints()
		icon.borderLeft:ClearAllPoints()
		local edgeSize = ( E.db.general.showRange and not E.db.position.detached and self.effectivePixelMult or E.PixelMult) / db.scale
		icon.borderTop:SetPoint("TOPLEFT", icon, "TOPLEFT")
		icon.borderTop:SetPoint("BOTTOMRIGHT", icon, "TOPRIGHT", 0, -edgeSize)
		icon.borderBottom:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT")
		icon.borderBottom:SetPoint("TOPRIGHT", icon, "BOTTOMRIGHT", 0, edgeSize)
		icon.borderLeft:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, -edgeSize)
		icon.borderLeft:SetPoint("BOTTOMRIGHT", icon, "BOTTOMLEFT", edgeSize, edgeSize)
		icon.borderRight:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 0, -edgeSize)
		icon.borderRight:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", -edgeSize, edgeSize)
		local r, g, b = db.borderColor.r, db.borderColor.g, db.borderColor.b
		icon.borderTop:SetColorTexture(r, g, b)
		icon.borderBottom:SetColorTexture(r, g, b)
		icon.borderRight:SetColorTexture(r, g, b)
		icon.borderLeft:SetColorTexture(r, g, b)
		icon.borderTop:Show()
		icon.borderBottom:Show()
		icon.borderRight:Show()
		icon.borderLeft:Show()
		icon.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	else
		icon.borderTop:Hide()
		icon.borderBottom:Hide()
		icon.borderRight:Hide()
		icon.borderLeft:Hide()
		icon.icon:SetTexCoord(0, 1, 0, 1)
	end
end

function P:SetMarker(icon, markEnhanced)
	local hotkey = icon.hotKey
	if markEnhanced then
		local spellID = icon.spellID
		local mark = E.spell_marked[spellID]
		if mark and (mark == true or self:IsTalentForPvpStatus(mark, self.groupInfo[icon.guid])) then
			hotkey:Show()
		else
			hotkey:Hide()
		end
	else
		hotkey:Hide()
	end
end

function P:SetOpacity(icon, db, opaque)

	if opaque then
		icon:SetAlpha(1.0)
	else
		icon:SetAlpha(icon.active == 0 and db.activeAlpha or db.inactiveAlpha)
	end


	local info = self.groupInfo[icon.guid]
	if not info then return end
	if info.isDeadOrOffline then
		icon.icon:SetDesaturated(true)
		icon.icon:SetVertexColor(0.3, 0.3, 0.3)
	else
		if info.preactiveIcons[icon.spellID] and not icon.isHighlighted then
			icon.icon:SetVertexColor(0.4, 0.4, 0.4)
		else
			icon.icon:SetVertexColor(1, 1, 1)
		end
		icon.icon:SetDesaturated(db.desaturateActive and icon.active == 0 and not icon.isHighlighted)
	end
end

function P:SetSwipeCounter(icon, db)
	if icon.active then
		self:SetCooldownElements(nil, icon, icon.maxcharges and icon.active)
	end
	icon.cooldown:SetReverse(db.reverse)
	icon.cooldown:SetSwipeColor(0, 0, 0, db.swipeAlpha)
	icon.counter:SetScale(db.counterScale)
end

function P:SetChargeScale(icon, chargeScale)
	icon.count:SetScale(chargeScale)
end

function P:SetTooltip(icon, showTooltip)
	icon:EnableMouse((not icon.SetPassThroughButtons or icon.isPassThrough) and (showTooltip or icon.tooltipID))
end

function P:ApplySettings(frame)
	self:SetAnchor(frame)
	self:SetIconScale(frame)

	local db = E.db.icons
	local markEnhanced = db.markEnhanced
	local chargeScale = db.chargeScale
	local showTooltip = db.showTooltip
	local condition = E.db.highlight.glowBorderCondition
	local info = self.groupInfo[frame.guid]
	local numIcons = frame.numIcons
	for i = 1, numIcons do
		local icon = frame.icons[i]
		self:SetBorder(icon, db)
		self:SetMarker(icon, markEnhanced)
		self:SetOpacity(icon, db)
		self:SetSwipeCounter(icon, db)
		self:SetChargeScale(icon, chargeScale)
		self:SetTooltip(icon, showTooltip)
		if icon.glowBorder then
			icon.Glow:SetShown(not info.isDeadOrOffline and (condition==3 or (condition==1 and icon.active~=0) or (condition==2 and icon.active==0)))
		end
	end
end
