local E, L = select(2, ...):unpack()
local P = E.Party

P.extraBars = {}

local function HideExBar(self, force)
	local key = self.key
	if not force and not P.disabled and E.db.extraBars[key].enabled then
		return
	end
	self:Hide()

	P:RemoveUnusedIcons(self, 1)
	self.numIcons = 0
end

function P:HideExBars(force)
	for _, frame in pairs(self.extraBars) do
		HideExBar(frame, force)
	end
end

function P:CreateExtraBarFrames()
	if next(self.extraBars) then return end
	for i = 0, 8 do
		local key = "raidBar" .. i
		local frame = CreateFrame("Frame", E.AddOn .. key, UIParent, "OmniCDTemplate")
		frame.index = i
		frame.key = key
		frame.icons = {}
		frame.numIcons = 0
		frame.db = E.db.extraBars[key]
		frame:SetScript("OnShow", nil)


		frame.anchor.text:SetFontObject(E.AnchorFont)
		local name = key == "raidBar0" and L["Interrupts"] or i
		frame.anchor.text:SetText(name)
		frame.anchor.text:SetTextColor(1, 0.824, 0)
		frame.anchor.background:SetColorTexture(0, 0, 0, 1)
		if E.isDF or E.isWOTLKC341 then
			frame.anchor.background:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, .05))
		else
			frame.anchor.background:SetGradientAlpha("Horizontal", 1, 1, 1, 1, 1, 1, 1, .05)
		end
		frame.anchor:EnableMouse(true)
		frame.anchor:SetScript("OnMouseUp", E.OmniCDAnchor_OnMouseUp)
		frame.anchor:SetScript("OnMouseDown", E.OmniCDAnchor_OnMouseDown)

		self.extraBars[key] = frame
	end
end

function P:UpdateExBarPositionValues()
	for key, frame in pairs(self.extraBars) do
		local db = frame.db
		local pixel = E.PixelMult / db.scale
		local growLeft = db.growLeft
		local growX = growLeft and -1 or 1
		local growRowsUpward = db.growUpward
		local growY = growRowsUpward and 1 or -1
		local isProgressBarEnabled = db.enabled and db.progressBar

		frame.point = "TOPLEFT"
		frame.anchorPoint = "BOTTOMLEFT"
		frame.anchorOfsY = growRowsUpward and -(E.baseIconHeight * db.scale + 15) or 0

		if db.layout == "horizontal" then
			if growLeft then
				frame.point2 = "TOPRIGHT"
				frame.relativePoint2 = "TOPLEFT"
				frame.ofsX2 = -(db.paddingX * pixel)
			else
				frame.point2 = "TOPLEFT"
				frame.relativePoint2 = "TOPRIGHT"
				frame.ofsX2 = db.paddingX * pixel
			end
			frame.ofsX = 0
			frame.ofsY = growY * (E.baseIconHeight + db.paddingY * pixel)
			frame.ofsY2 = 0
			frame.shouldShowProgressBar = nil
		else
			if growRowsUpward then
				frame.point2 = "BOTTOMLEFT"
				frame.relativePoint2 = "TOPLEFT"
				frame.ofsY2 = db.paddingY * pixel
			else
				frame.point2 = "TOPLEFT"
				frame.relativePoint2 = "BOTTOMLEFT"
				frame.ofsY2 = -(db.paddingY * pixel)
			end
			frame.ofsX = growX * (E.baseIconHeight + (db.paddingX * pixel) + (isProgressBarEnabled and db.statusBarWidth or 0))
			frame.ofsY = 0
			frame.ofsX2 = 0
			frame.shouldShowProgressBar = isProgressBarEnabled
		end

		local sortBy = db.sortBy
		frame.shouldRearrangeInterrupts = db.enabled and (sortBy == 2 or sortBy >= 7)
	end
end

local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local roleValues = { MAINTANK = 1, MAINASSIST = 2, TANK = 3, HEALER = 4, DAMAGER = 5, NONE = 6 }
local sorters = {

	function(a, b)
		local cd1, cd2 = a.duration, b.duration
		if cd1 == cd2 then
			local class1, class2 = a.class, b.class
			if class1 == class2 then
				return P.groupInfo[a.guid].name < P.groupInfo[b.guid].name
			end
			return class1 < class2
		end
		return cd1 < cd2
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		local dead1, dead2 = info1.isDeadOrOffline, info2.isDeadOrOffline
		if dead1 == dead2 then
			local id1, id2 = a.spellID, b.spellID
			local active1, active2 = info1.active[id1], info2.active[id2]
			local cd1, cd2 = a.duration, b.duration
			if active1 and active2 then
				return cd1 + active1.startTime < cd2 + active2.startTime
			elseif not active1 and not active2 then
				if cd1 == cd2 then
					local class1, class2 = a.class, b.class
					if class1 == class2 then
						if id1 == id2 then
							return info1.name < info2.name
						end
						return id1 < id2
					end
					return class1 < class2
				end
				return cd1 < cd2
			end
			return active2
		end
		return dead2
	end,

	function(a, b)
		local prio1, prio2 = E.db.priority[a.type], E.db.priority[b.type]
		if prio1 == prio2 then
			local class1, class2 = a.class, b.class
			if class1 == class2 then
				local id1, id2 = a.spellID, b.spellID
				if id1 == id2 then
					return P.groupInfo[a.guid].name < P.groupInfo[b.guid].name
				end
				return id1 < id2
			end
			return class1 < class2
		end
		return prio1 > prio2
	end,

	function(a, b)
		local class1, class2 = a.class, b.class
		if class1 == class2 then
			local prio1, prio2 = E.db.priority[a.type], E.db.priority[b.type]
			if prio1 == prio2 then
				local id1, id2 = a.spellID, b.spellID
				if id1 == id2 then
					return P.groupInfo[a.guid].name < P.groupInfo[b.guid].name
				end
				return id1 < id2
			end
			return prio1 > prio2
		end
		return class1 < class2
	end,

	function(a, b)
		local role1 = UnitGroupRolesAssigned(token1)
		local role2 = UnitGroupRolesAssigned(token2)

		local value1, value2 = roleValues[role1], roleValues[role2]
		if value1 ~= value2 then
			return value1 < value2
		end
		return P.groupInfo[a.guid].name < P.groupInfo[b.guid].name
	end,

	function(a, b)
		local class1, class2 = a.class, b.class
		if class1 == class2 then
			return P.groupInfo[a.guid].name < P.groupInfo[b.guid].name
		end
		return class1 < class2
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		local dead1, dead2 = info1.isDeadOrOffline, info2.isDeadOrOffline
		if dead1 == dead2 then
			local active1, active2 = info1.active[a.spellID], info2.active[b.spellID]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				local role1 = UnitGroupRolesAssigned(token1)
				local role2 = UnitGroupRolesAssigned(token2)

				local value1, value2 = roleValues[role1], roleValues[role2]
				if value1 == value2 then
					return info1.name < info2.name
				end
				return value1 < value2
			end
			return active2
		end
		return dead2
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		local dead1, dead2 = info1.isDeadOrOffline, info2.isDeadOrOffline
		if dead1 == dead2 then
			local active1, active2 = info1.active[a.spellID], info2.active[b.spellID]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				local class1, class2 = a.class, b.class
				if class1 == class2 then
					return info1.name < info2.name
				end
				return class1 < class2
			end
			return active2
		end
		return dead2
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		local dead1, dead2 = info1.isDeadOrOffline, info2.isDeadOrOffline
		if dead1 == dead2 then
			local id1, id2 = a.spellID, b.spellID
			local active1, active2 = info1.active[id1], info2.active[id2]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				local prio1, prio2 = E.db.priority[a.type], E.db.priority[b.type]
				if prio1 == prio2 then
					local class1, class2 = a.class, b.class
					if class1 == class2 then
						if id1 == id2 then
							return info1.name < info2.name
						end
						return id1 < id2
					end
					return class1 < class2
				end
				return prio1 > prio2
			end
			return active2
		end
		return dead2
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		local dead1, dead2 = info1.isDeadOrOffline, info2.isDeadOrOffline
		if dead1 == dead2 then
			local id1, id2 = a.spellID, b.spellID
			local active1, active2 = info1.active[id1], info2.active[id2]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				local class1, class2 = a.class, b.class
				if class1 == class2 then
					local prio1, prio2 = E.db.priority[a.type], E.db.priority[b.type]
					if prio1 == prio2 then
						if id1 == id2 then
							return info1.name < info2.name
						end
						return id1 < id2
					end
					return prio1 > prio2
				end
				return class1 < class2
			end
			return active2
		end
		return dead2
	end,
}

local _sorter

local reverseSort = function(a, b)
	return _sorter(b, a)
end


function P:SetExIconLayout(key, sortOrder, updateSettings, updateIcons)
	if self.disabled then
		return
	end

	local frame = self.extraBars[key]
	local db = frame.db


	if updateIcons then
		local n = 0
		for i = frame.numIcons, 1, -1 do
			local icons = frame.icons
			local icon = icons[i]
			local info = self.groupInfo[icon.guid]
			local spellIcon = info and info.spellIcons[icon.spellID]
			if icon ~= spellIcon then
				self:RemoveIcon(icon)
				tremove(icons, i)
				n = n + 1
			end
		end
		frame.numIcons = frame.numIcons - n
	end

	if sortOrder then
		_sorter = sorters[db.sortBy]
		local sortFunc = db.sortDirection == "dsc" and reverseSort or _sorter
		sort(frame.icons, sortFunc)
	end

	local count, rows = 0, 0
	local columns = db.columns
	for i = 1, frame.numIcons do
		local icon = frame.icons[i]
		icon:Hide()
		icon:ClearAllPoints()

		if i > 1 then
			count = count + 1
			if count == columns then
				icon:SetPoint(frame.point, frame.container, frame.ofsX * rows, frame.ofsY * rows)
				rows = rows + 1
				count = 0
			else
				icon:SetPoint(frame.point2, frame.icons[i-1], frame.relativePoint2, frame.ofsX2, frame.ofsY2)
			end
		else
			icon:SetPoint(frame.point, frame.container)
			rows = rows + 1
		end

		icon:Show()
	end


	if updateSettings then
		self:ApplyExSettings(key)
	end
end

function P:SetExAnchor(frame, db)
	local anchor = frame.anchor
	if db.locked then
		anchor:Hide()
	else
		anchor:ClearAllPoints()
		anchor:SetPoint(frame.anchorPoint, frame, frame.point, 0, frame.anchorOfsY)
		if frame.shouldShowProgressBar then
			anchor:SetWidth((E.baseIconHeight + db.statusBarWidth) * db.scale)
		else
			local width = math.max(anchor.text:GetWidth() + 20, E.baseIconHeight * db.scale)
			anchor:SetWidth(width)
		end
		anchor.text:SetText(db.name or (frame.index == 0 and L["Interrupts"] or frame.index))
		anchor:Show()
	end
end

function P:SetExScale(frame, db)
	frame.container:SetScale(db.scale)

end

function P:UpdateExBarBackdrop(frame, db)
	local icons = frame.icons
	for i = 1, frame.numIcons do
		local icon = icons[i]
		self:SetExBorder(icon, db)
	end
end

function P:SetExBorder(icon, db)
	local db_icon = E.db.icons
	local shouldShowProgressBar = db.layout == "vertical" and db.progressBar
	if db_icon.displayBorder or shouldShowProgressBar then
		icon.borderTop:ClearAllPoints()
		icon.borderBottom:ClearAllPoints()
		icon.borderRight:ClearAllPoints()
		icon.borderLeft:ClearAllPoints()
		local edgeSize = E.PixelMult / db.scale
		icon.borderTop:SetPoint("TOPLEFT", icon, "TOPLEFT")
		icon.borderTop:SetPoint("BOTTOMRIGHT", icon, "TOPRIGHT", 0, -edgeSize)
		icon.borderBottom:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT")
		icon.borderBottom:SetPoint("TOPRIGHT", icon, "BOTTOMRIGHT", 0, edgeSize)
		icon.borderRight:SetPoint("TOPRIGHT", icon, "TOPRIGHT")
		icon.borderRight:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", -edgeSize, 0)
		icon.borderLeft:SetPoint("TOPLEFT", icon, "TOPLEFT")
		icon.borderLeft:SetPoint("BOTTOMRIGHT", icon, "BOTTOMLEFT", edgeSize, 0)
		local r, g, b = db_icon.borderColor.r, db_icon.borderColor.g, db_icon.borderColor.b
		icon.borderTop:SetColorTexture(r, g, b)
		icon.borderBottom:SetColorTexture(r, g, b)
		icon.borderLeft:SetColorTexture(r, g, b)
		icon.borderRight:SetColorTexture(r, g, b)
		icon.borderTop:Show()
		icon.borderBottom:Show()
		icon.borderRight:Show()
		icon.borderLeft:Show()
		icon.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

		if shouldShowProgressBar then
			local statusBar = icon.statusBar
			if db.nameBar then
				statusBar:DisableDrawLayer("BORDER")
			else
				statusBar:EnableDrawLayer("BORDER")
				statusBar.borderTop:ClearAllPoints()
				statusBar.borderBottom:ClearAllPoints()
				statusBar.borderRight:ClearAllPoints()
				statusBar.borderTop:SetPoint("TOPLEFT", statusBar, "TOPLEFT")
				statusBar.borderTop:SetPoint("BOTTOMRIGHT", statusBar, "TOPRIGHT", 0, -edgeSize)
				statusBar.borderBottom:SetPoint("BOTTOMLEFT", statusBar, "BOTTOMLEFT")
				statusBar.borderBottom:SetPoint("TOPRIGHT", statusBar, "BOTTOMRIGHT", 0, edgeSize)
				statusBar.borderRight:SetPoint("TOPRIGHT", statusBar.borderTop, "BOTTOMRIGHT")
				statusBar.borderRight:SetPoint("BOTTOMLEFT", statusBar.borderBottom, "TOPRIGHT", -edgeSize, 0)
				if db.hideBorder then
					statusBar.borderTop:Hide()
					statusBar.borderBottom:Hide()
					statusBar.borderRight:Hide()
				else
					statusBar.borderTop:SetColorTexture(r, g, b)
					statusBar.borderBottom:SetColorTexture(r, g, b)
					statusBar.borderRight:SetColorTexture(r, g, b)
					statusBar.borderTop:Show()
					statusBar.borderBottom:Show()
					statusBar.borderRight:Show()
				end
			end
		end
	else
		icon.borderTop:Hide()
		icon.borderBottom:Hide()
		icon.borderRight:Hide()
		icon.borderLeft:Hide()
		icon.icon:SetTexCoord(0, 1, 0, 1)
	end
end

function P:SetExIconName(icon, db)
	if db.layout == "vertical" and db.progressBar or not db.showName then
		icon.name:Hide()
	else
		icon.name:SetPoint("BOTTOM", 0, db.nameOfsY)
		local unitName = self.groupInfo[icon.guid].name
		local numChar = db.truncateIconName
		if numChar > 0 then
			unitName = string.utf8sub(unitName, 1, numChar)
		end
		icon.name:SetText(unitName)
		icon.name:Show()
	end
end

function P:SetExStatusBarWidth(statusBar, db)
	statusBar:SetWidth(db.statusBarWidth)

	statusBar.Text:ClearAllPoints()
	if db.nameBar and db.invertNameBar then
		statusBar.Text:SetPoint("TOPLEFT", statusBar.icon, "TOPLEFT", -db.statusBarWidth + db.textOfsX, db.textOfsY)
		statusBar.Text:SetPoint("BOTTOMRIGHT", statusBar.icon, "BOTTOMLEFT", -db.textOfsX, db.textOfsY)
		statusBar.Text:SetJustifyH("RIGHT")
	else
		statusBar.Text:SetPoint("LEFT", statusBar, db.textOfsX, db.textOfsY)
		statusBar.Text:SetPoint("RIGHT", statusBar, -3, db.textOfsY)
		statusBar.Text:SetJustifyH("LEFT")
	end
	statusBar.CastingBar.Text:SetPoint("LEFT", statusBar.CastingBar, db.textOfsX, db.textOfsY)
	statusBar.CastingBar.Timer:SetPoint("RIGHT", statusBar.CastingBar, -3, db.textOfsY)


	statusBar.Text:SetScale(db.textScale)
end

function P:SetExStatusBarColor(icon, key, db)
	local info = self.groupInfo[icon.guid]
	if not info then return end

	db = db or E.db.extraBars[key]
	local c, r, g, b, a = RAID_CLASS_COLORS[icon.class]
	local statusBar = icon.statusBar




	if not db.nameBar or not icon.active then
		if info.isDeadOrOffline then
			r, g, b = 0.3, 0.3, 0.3
		elseif db.textColors.useClassColor.inactive then
			r, g, b = c.r, c.g, c.b
		else
			local text_c = db.textColors.inactiveColor
			r, g, b = text_c.r, text_c.g, text_c.b
		end
		statusBar.Text:SetTextColor(r, g, b)
	end

	statusBar.BG:SetShown(not db.nameBar and not icon.active)
	statusBar.Text:SetShown(db.nameBar or not icon.active)


	local bar_c = db.barColors.inactiveColor
	local alpha = db.useIconAlpha and 1 or bar_c.a
	local spellID = icon.spellID
	if info.isDeadOrOffline then
		r, g, b, a = 0.3, 0.3, 0.3, alpha
	elseif info.preactiveIcons[spellID] and spellID ~= 1022 and spellID ~= 204018 then
		r, g, b, a = 0.7, 0.7, 0.7, alpha
	elseif db.barColors.useClassColor.inactive then
		r, g, b, a = c.r, c.g, c.b, alpha
	else
		r, g, b, a =  bar_c.r, bar_c.g, bar_c.b, alpha
	end
	statusBar.BG:SetVertexColor(r, g, b, a)


end

function P:ApplyExSettings(key)
	local frame = self.extraBars[key]
	local db = frame.db

	self:SetExAnchor(frame, db)
	self:SetExScale(frame, db)

	local opaque = not db.useIconAlpha
	local db_icon = E.db.icons
	local chargeScale = db_icon.chargeScale
	local showTooltip = db_icon.showTooltip
	local numIcons = frame.numIcons
	for i = 1, numIcons do
		local icon = frame.icons[i]
		self:SetExBorder(icon, db)
		self:SetExIconName(icon, db)
		local statusBar = icon.statusBar
		if statusBar then
			self:SetExStatusBarWidth(statusBar, db)
			self:SetExStatusBarColor(icon, key, db)
		end

		self:SetMarker(icon, nil)
		self:SetOpacity(icon, db_icon, statusBar and opaque)
		self:SetSwipeCounter(icon, db_icon)
		self:SetChargeScale(icon, chargeScale)
		self:SetTooltip(icon, showTooltip)
	end
end

function P:UpdateExBars()
	if self.disabled then
		return
	end

	for key, frame in pairs(self.extraBars) do
		if frame.db.enabled then
			self:SetExIconLayout(key, true, true, true)
			E.LoadPosition(frame)
			frame:Show()
		else
			HideExBar(frame)
		end
	end
end
