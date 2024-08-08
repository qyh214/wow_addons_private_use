local E, L = select(2, ...):unpack()
local P = E.Party

P.extraBars = {}

local function RemoveContainers(raidBarIndex)
	for _, info in pairs(P.groupInfo) do
		local f = info.bar
		P:RemoveUnusedContainers(f, raidBarIndex)
	end
end

local function HideExBar(self, force)
	local key = self.key
	if not force and not P.disabled and E.db.extraBars[key].enabled then
		return
	end
	self:Hide()

	P:RemoveUnusedIcons(self, 1)
	self.numIcons = 0

	RemoveContainers(self.index)
end

function P:HideExBars(force)
	for _, frame in pairs(self.extraBars) do
		HideExBar(frame, force)
	end
end

function P:CreateExtraBarFrames()
	if next(self.extraBars) then return end
	for i = 1, 8 do
		local key = "raidBar" .. i
		local frame = CreateFrame("Frame", E.AddOn .. key, UIParent, "OmniCDTemplate")
		frame.index = i
		frame.key = key
		frame.icons = {}
		frame.numIcons = 0
		frame.db = E.db.extraBars[key]
		frame:SetScript("OnShow", nil)

		frame.anchor.text:SetFontObject(E.AnchorFont)
		local name = i == 1 and L["Interrupts"] or i
		frame.anchor.text:SetText(name)
		frame.anchor.text:SetTextColor(1, 0.824, 0)
		frame.anchor.background:SetColorTexture(0, 0, 0, 1)
		if E.isDF or E.isCata or E.isWOTLKC341 or E.isClassic1144 then
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
	for _, frame in pairs(self.extraBars) do
		local db = frame.db
		local isUnitBar = db.unitBar
		local pixel = (isUnitBar and E.db.general.showRange and self.effectivePixelMult or E.PixelMult) / db.scale
		local growLeft = isUnitBar and strfind(db.anchor, "RIGHT") or db.growLeft
		local growX = growLeft and -1 or 1
		local growRowsUpward = db.growUpward
		local growY = growRowsUpward and 1 or -1
		local isProgressBarEnabled = db.enabled and not isUnitBar and db.progressBar

		frame.point = isUnitBar and db.anchor or "TOPLEFT"
		frame.relativePoint = db.attach
		frame.containerOfsX = db.offsetX * growX * pixel
		frame.containerOfsY = db.offsetY * pixel
		frame.anchorPoint = "BOTTOMLEFT"
		frame.anchorOfsY = growRowsUpward and -(E.baseIconHeight * db.scale + 15) or 0

		if db.layout == "horizontal" then
			frame.ofsX = 0
			frame.ofsY = growY * (E.baseIconHeight + db.paddingY * pixel)
			frame.ofsY2 = 0
			if growLeft then
				frame.point2 = "TOPRIGHT"
				frame.relativePoint2 = "TOPLEFT"
				frame.ofsX2 = -(db.paddingX * pixel)
			else
				frame.point2 = "TOPLEFT"
				frame.relativePoint2 = "TOPRIGHT"
				frame.ofsX2 = db.paddingX * pixel
			end
			frame.shouldShowProgressBar = nil
		else
			frame.ofsX = growX * (E.baseIconHeight + (db.paddingX * pixel) + (isProgressBarEnabled and db.statusBarWidth or 0))
			frame.ofsY = 0
			frame.ofsX2 = 0
			if growRowsUpward then
				frame.point2 = "BOTTOMLEFT"
				frame.relativePoint2 = "TOPLEFT"
				frame.ofsY2 = db.paddingY * pixel
			else
				frame.point2 = "TOPLEFT"
				frame.relativePoint2 = "BOTTOMLEFT"
				frame.ofsY2 = -(db.paddingY * pixel)
			end
			frame.shouldShowProgressBar = isProgressBarEnabled
		end

		local sortBy = db.sortBy
		frame.shouldRearrangeInterrupts = not isUnitBar and db.enabled and (sortBy == 2 or sortBy >= 7)
	end
end

local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local roleValues = { MAINTANK = 1, MAINASSIST = 2, TANK = 3, HEALER = 4, DAMAGER = 5, NONE = 6 }
local sorters
sorters = {

	function(a, b)
		if a.duration == b.duration then
			return a.unitName < b.unitName
		end
		return a.duration < b.duration
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		if info1.isDeadOrOffline == info2.isDeadOrOffline then
			local active1, active2 = a.active == 0 and info1.active[a.spellID], b.active == 0 and info2.active[b.spellID]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				return sorters[1](a, b)
			end
			return active2
		end
		return info2.isDeadOrOffline
	end,

	function(a, b)
		if a.priority == b.priority then
			if a.class == b.class then
				if a.spellID == b.spellID then
					return a.unitName < b.unitName
				end
				return a.spellID < b.spellID
			end
			return a.class < b.class
		end
		return a.priority > b.priority
	end,

	function(a, b)
		if a.class == b.class then
			if a.priority == b.priority then
				if a.spellID == b.spellID then
					return a.unitName < b.unitName
				end
				return a.spellID < b.spellID
			end
			return a.priority > b.priority
		end
		return a.class < b.class
	end,

	function(a, b)
		local token1, token2 = a.unit, b.unit;
		if ( token1 == token2 ) then
			if ( a.priority == b.priority ) then
				return a.spellID < b.spellID;
			end
			return a.priority > b.priority;
		end

		local id1, id2 = UnitInRaid(token1), UnitInRaid(token2);
		local role1, role2;
		if ( id1 ) then
			role1 = select(10, GetRaidRosterInfo(id1));
		end
		if ( id2 ) then
			role2 = select(10, GetRaidRosterInfo(id2));
		end

		role1 = role1 or UnitGroupRolesAssigned(token1);
		role2 = role2 or UnitGroupRolesAssigned(token2);

		local value1, value2 = roleValues[role1], roleValues[role2];
		if ( value1 ~= value2 ) then
			return value1 < value2;
		end


		return a.unitName < b.unitName;
	end,

	function(a, b)
		if ( a.unit == b.unit ) then
			if ( a.priority == b.priority ) then
				return a.spellID < b.spellID;
			end
			return a.priority > b.priority;
		end

		if a.class == b.class then
			return a.unitName < b.unitName
		end
		return a.class < b.class
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		if info1.isDeadOrOffline == info2.isDeadOrOffline then
			local active1, active2 = a.active == 0 and info1.active[a.spellID], b.active == 0 and info2.active[b.spellID]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				return sorters[5](a, b)
			end
			return active2
		end
		return info2.isDeadOrOffline
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		if info1.isDeadOrOffline == info2.isDeadOrOffline then
			local active1, active2 = a.active == 0 and info1.active[a.spellID], b.active == 0 and info2.active[b.spellID]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				return sorters[6](a, b)
			end
			return active2
		end
		return info2.isDeadOrOffline
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		if info1.isDeadOrOffline == info2.isDeadOrOffline then
			local id1, id2 = a.spellID, b.spellID
			local active1, active2 = a.active == 0 and info1.active[id1], b.active == 0 and info2.active[id2]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				if a.priority == b.priority then
					if a.class == b.class then
						if id1 == id2 then
							return a.unitName < b.unitName
						end
						return id1 < id2
					end
					return a.class < b.class
				end
				return a.priority > b.priority
			end
			return active2
		end
		return info2.isDeadOrOffline
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		if info1.isDeadOrOffline == info2.isDeadOrOffline then
			local id1, id2 = a.spellID, b.spellID
			local active1, active2 = a.active == 0 and info1.active[id1], b.active == 0 and info2.active[id2]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				if a.class == b.class then
					if a.priority == b.priority then
						if id1 == id2 then
							return a.unitName < b.unitName
						end
						return id1 < id2
					end
					return a.priority > b.priority
				end
				return a.class < b.class
			end
			return active2
		end
		return info2.isDeadOrOffline
	end,

	function(a, b)
		local token1, token2 = a.unit, b.unit
		if ( token1 == token2 ) then
			if ( a.priority == b.priority ) then
				return a.spellID < b.spellID
			end
			return a.priority > b.priority
		end

		if ( IsInRaid() ) then
			local id1 = tonumber(string.sub(token1, 5));
			local id2 = tonumber(string.sub(token2, 5));

			if ( not id1 or not id2 ) then
				return id1;
			end

			local _, _, subgroup1 = GetRaidRosterInfo(id1);
			local _, _, subgroup2 = GetRaidRosterInfo(id2);

			if ( subgroup1 and subgroup2 and subgroup1 ~= subgroup2 ) then
				return subgroup1 < subgroup2;
			end


			return id1 < id2;
		else
			if ( token1 == "player" ) then
				return true;
			elseif ( token2 == "player" ) then
				return false;
			else
				return token1 < token2;
			end
		end
	end,

	function(a, b)
		if ( a.unit == b.unit ) then
			if ( a.priority == b.priority ) then
				return a.spellID < b.spellID
			end
			return a.priority > b.priority
		end
		return a.unitName < b.unitName
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		if info1.isDeadOrOffline == info2.isDeadOrOffline then
			local active1, active2 = a.active == 0 and info1.active[a.spellID], b.active == 0 and info2.active[b.spellID]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				return sorters[11](a, b)
			end
			return active2
		end
		return info2.isDeadOrOffline
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		if info1.isDeadOrOffline == info2.isDeadOrOffline then
			local active1, active2 = a.active == 0 and info1.active[a.spellID], b.active == 0 and info2.active[b.spellID]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				return sorters[12](a, b)
			end
			return active2
		end
		return info2.isDeadOrOffline
	end,

	function(a, b)
		if a.priority == b.priority then
			return a.unitName < b.unitName
		end
		return a.priority > b.priority
	end,

	function(a, b)
		local info1, info2 = P.groupInfo[a.guid], P.groupInfo[b.guid]
		if info1.isDeadOrOffline == info2.isDeadOrOffline then
			local id1, id2 = a.spellID, b.spellID
			local active1, active2 = a.active == 0 and info1.active[id1], b.active == 0 and info2.active[id2]
			if active1 and active2 then
				return a.duration + active1.startTime < b.duration + active2.startTime
			elseif not active1 and not active2 then
				return sorters[15](a, b)
			end
			return active2
		end
		return info2.isDeadOrOffline
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

	if ( db.unitBar ) then
		for _, info in pairs(self.groupInfo) do
			local bar = info.bar
			for raidBarIndex, container in pairs(bar.exContainers) do
				local f = self.extraBars["raidBar" .. raidBarIndex]
				local icons = container.icons
				if ( sortOrder ) then
					sort(icons, self.sorters[self.sortBy])
				end

				local count, rows = 0, 1
				local columns = f.db.columns
				for i = 1, #icons do
					local icon = icons[i]
					icon:Hide()
					icon:ClearAllPoints()
					if ( i > 1 ) then
						count = count + 1
						if ( count == columns ) then
							icon:SetPoint(f.point, container, f.ofsX * rows, f.ofsY * rows)
							rows = rows + 1
							count = 0
						else
							icon:SetPoint(f.point2, icons[i-1], f.relativePoint2, f.ofsX2, f.ofsY2)
						end
					else
						icon:SetPoint(f.point, container)
					end
					icon:Show()
				end
			end
		end
	else
		if sortOrder then
			_sorter = sorters[db.sortBy]
			local sortFunc = db.sortDirection == "dsc" and reverseSort or _sorter
			sort(frame.icons, sortFunc)
		end

		local count, rows = 0, 1
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
			end
			icon:Show()
		end
	end


	if updateSettings then
		self:ApplyExSettings(key)
	end
end

function P:SetExAnchor(frame, db)
	local anchor = frame.anchor
	if ( db.locked or db.unitBar ) then
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
		anchor.text:SetText(db.name or (frame.index == 1 and L["Interrupts"] or frame.index))
		anchor:Show()
	end
end

function P:SetExScale(frame, db)
	if ( db.unitBar ) then
		for _, info in pairs(self.groupInfo) do
			local f = info.bar
			if ( f.exContainers[frame.index] ) then
				f.exContainers[frame.index]:SetScale(db.scale)
			end
		end
	else
		frame.container:SetScale(db.scale)

	end
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
	local shouldShowProgressBar = not db.unitBar and db.layout == "vertical" and db.progressBar
	if db_icon.displayBorder or shouldShowProgressBar then
		icon.borderTop:ClearAllPoints()
		icon.borderBottom:ClearAllPoints()
		icon.borderRight:ClearAllPoints()
		icon.borderLeft:ClearAllPoints()
		local edgeSize = (db.unitBar and E.db.general.showRange and self.effectivePixelMult or E.PixelMult) / db.scale
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
			if statusBar then
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
	if ( db.layout == "vertical" and db.progressBar or not db.showName or db.unitBar ) then
		icon.name:Hide()
	else
		icon.name:SetPoint("BOTTOM", 0, db.nameOfsY)
		local unitName = self.groupInfo[icon.guid].name
		local numChar = db.truncateIconName
		if numChar > 0 then
			unitName = string.utf8sub(unitName, 1, numChar)
		end
		if db.classColor then
			local c = RAID_CLASS_COLORS[icon.class]
			if c and c.r then
				icon.name:SetTextColor(c.r, c.g, c.b)
			end
		else
			icon.name:SetTextColor(1, 1, 1)
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

		if ( not frame.db.unitBar ) then
			RemoveContainers(frame.index)
		end
	end
end
