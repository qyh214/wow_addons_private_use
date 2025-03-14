local E, L = select(2, ...):unpack()
local P = E.Party

local extraBars = {}

local ExtraBarFrameMixin = {}

function ExtraBarFrameMixin:ReleaseUnitBars()
	for _, info in pairs(P.groupInfo) do
		local f = info.bar
		f:ReleaseUnitBars(self.index)
	end
end

function ExtraBarFrameMixin:Release()
	self:Hide()
	self:ReleaseIcons()
	self:ReleaseUnitBars()
end

function ExtraBarFrameMixin:ReleaseIcons()
	for i = #self.icons, 1, -1 do
		local icon = self.icons[i]
		icon:Release()
		self.icons[i] = nil
	end
	self.numIcons = 0
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
		local token1, token2 = a.unit, b.unit
		if ( token1 == token2 ) then
			if ( a.priority == b.priority ) then
				return a.spellID < b.spellID
			end
			return a.priority > b.priority
		end

		local id1, id2 = UnitInRaid(token1), UnitInRaid(token2);
		local role1, role2
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
			return value1 < value2
		end


		return a.unitName < b.unitName
	end,

	function(a, b)
		if ( a.unit == b.unit ) then
			if ( a.priority == b.priority ) then
				return a.spellID < b.spellID
			end
			return a.priority > b.priority
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
				return id1
			end

			local _, _, subgroup1 = GetRaidRosterInfo(id1);
			local _, _, subgroup2 = GetRaidRosterInfo(id2);

			if ( subgroup1 and subgroup2 and subgroup1 ~= subgroup2 ) then
				return subgroup1 < subgroup2
			end


			return id1 < id2
		else
			if ( token1 == "player" ) then
				return true
			elseif ( token2 == "player" ) then
				return false
			else
				return token1 < token2
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

local Sorter

local ReverseSorter = function(a, b)
	return Sorter(b, a)
end

function ExtraBarFrameMixin:UpdateLayout(sortOrder, updateSettings, updateIcons)
	if P.disabled then
		return
	end



	if updateIcons then
		local n = 0
		for i = self.numIcons, 1, -1 do
			local icons = self.icons
			local icon = icons[i]
			local info = P.groupInfo[icon.guid]
			local spellIcon = info and info.spellIcons[icon.spellID]
			if icon ~= spellIcon then
				icon:Release()
				tremove(icons, i)
				n = n + 1
			end
		end
		self.numIcons = self.numIcons - n
	end

	local db = self.db
	if db.unitBar then
		for _, info in pairs(P.groupInfo) do
			local bar = info.bar
			for raidBarIndex, unitBar in pairs(bar.activeUnitBars) do
				local f = extraBars["raidBar" .. raidBarIndex]
				local icons = unitBar.icons
				if ( sortOrder ) then
					sort(icons, P.sorters[P.sortBy])
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
							icon:SetPoint(f.point, unitBar, f.ofsX * rows, f.ofsY * rows)
							rows = rows + 1
							count = 0
						else
							icon:SetPoint(f.point2, icons[i-1], f.relativePoint2, f.ofsX2, f.ofsY2)
						end
					else
						icon:SetPoint(f.point, unitBar)
					end
					icon:Show()
				end
			end
		end
	else
		if sortOrder then
			Sorter = sorters[db.sortBy]
			local sortFunc = db.sortDirection == "dsc" and ReverseSorter or Sorter
			sort(self.icons, sortFunc)
		end

		local count, rows = 0, 1
		local columns = db.columns
		for i = 1, self.numIcons do
			local icon = self.icons[i]
			icon:Hide()
			icon:ClearAllPoints()
			if i > 1 then
				count = count + 1
				if count == columns then
					icon:SetPoint(self.point, self.container, self.ofsX * rows, self.ofsY * rows)
					rows = rows + 1
					count = 0
				else
					icon:SetPoint(self.point2, self.icons[i-1], self.relativePoint2, self.ofsX2, self.ofsY2)
				end
			else
				icon:SetPoint(self.point, self.container)
			end
			icon:Show()
		end
	end

	if updateSettings then
		self:ApplySettings()
	end
end

function ExtraBarFrameMixin:ApplySettings()
	local db = self.db
	local pixel = self.pixel

	self:SetExAnchor()
	self:SetExScale()

	local numIcons = self.numIcons
	for i = 1, numIcons do

		local icon = self.icons[i]
		icon:SetExBorder(db, pixel)
		icon:SetExIconName(db)
		local statusBar = icon.statusBar
		if statusBar then
			statusBar:ApplySettings(db)
		end

		icon:SetMarker()
		icon:SetOpacity()
		icon:SetColorSaturation()
		icon:SetSwipeCounter()
		icon:SetChargeScale()
		icon:SetTooltip()
	end
end

function ExtraBarFrameMixin:SetExAnchor()
	local anchor = self.anchor
	local db = self.db

	if db.locked or db.unitBar then
		anchor:Hide()
	else
		anchor:ClearAllPoints()
		anchor:SetPoint(self.anchorPoint, self, self.point, 0, self.anchorOfsY)
		if self.shouldShowProgressBar then
			anchor:SetWidth((E.BASE_ICON_HEIGHT + db.statusBarWidth) * self.iconScale)
		else
			local width = math.max(anchor.text:GetWidth() + 20, E.BASE_ICON_HEIGHT * self.iconScale)
			anchor:SetWidth(width)
		end
		anchor.text:SetText(db.name or (self.index == 1 and L["Interrupts"] or self.index))
		anchor:Show()
	end
end

function ExtraBarFrameMixin:SetExScale()
	if self.db.unitBar then
		for _, info in pairs(P.groupInfo) do
			local f = info.bar
			if ( f.activeUnitBars[self.index] ) then
				f.activeUnitBars[self.index]:SetScale(self.iconScale)
			end
		end
	else
		self.container:SetScale(self.iconScale)
	end
end

function ExtraBarFrameMixin:UpdateExBarBackdrop(db)
	local icons = self.icons
	local pixel = self.pixel
	for i = 1, self.numIcons do
		local icon = icons[i]
		icon:SetExBorder(db, pixel)
	end
end

function P:CreateExtraBarFrames()
	if extraBars.raidBar1 then
		return
	end
	for i = 1, 8 do
		local key = "raidBar" .. i
		local frame = CreateFrame("Frame", E.AddOn .. key, UIParent, "OmniCDTemplate")
		Mixin(frame, ExtraBarFrameMixin)
		frame.index = i
		frame.key = key
		frame.icons = {}
		frame.numIcons = 0


		frame.anchor.text:SetFontObject(E.AnchorFont)
		local name = i == 1 and L["Interrupts"] or i
		frame.anchor.text:SetText(name)
		frame.anchor.text:SetTextColor(1, 0.824, 0)
		frame.anchor.background:SetColorTexture(0, 0, 0, 1)

		frame.anchor.background:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, .05))

		frame.anchor:SetScript("OnMouseUp", E.OmniCDAnchor_OnMouseUp)
		frame.anchor:SetScript("OnMouseDown", E.OmniCDAnchor_OnMouseDown)

		extraBars[key] = frame
	end
end

function P:ReleaseExBars()
	for _, frame in pairs(extraBars) do
		frame:Release()
	end
end

function P:HideExBars()
	for _, frame in pairs(extraBars) do
		frame:Hide()
	end
end

function P:UpdateExBars()
	if self.disabled then
		return
	end
	for _, frame in pairs(extraBars) do
		if frame.db.enabled then
			E.LoadPosition(frame)
			frame:UpdateLayout(true, true, true)
			frame:Show()
		else
			frame:Release()
		end
		if not frame.db.unitBar then
			frame:ReleaseUnitBars(frame.index)
		end
	end
end

function P:UpdateExBarPositionValues()
	for _, frame in pairs(extraBars) do
		local db = frame.db
		local isUnitBar = db.unitBar
		local pixelMult = isUnitBar and E.db.general.showRange and self.effectivePixelMult or E.PixelMult

		local size = E.BASE_ICON_HEIGHT * db.scale
		frame.iconScale = (size - size % pixelMult) / E.BASE_ICON_HEIGHT

		local pixel = pixelMult / frame.iconScale
		frame.pixel = pixel

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
		frame.anchorOfsY = growRowsUpward and -(E.BASE_ICON_HEIGHT * frame.iconScale + 15) or 0

		if db.layout == "horizontal" then
			frame.ofsX = 0
			frame.ofsY = growY * (E.BASE_ICON_HEIGHT + db.paddingY * pixel)
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
			frame.ofsX = growX * (E.BASE_ICON_HEIGHT + (db.paddingX * pixel) + (isProgressBarEnabled and db.statusBarWidth or 0))
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

P.extraBars = extraBars
