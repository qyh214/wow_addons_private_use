---@type string, Addon
local addonName, addon = ...
local LCG = LibStub and LibStub("LibCustomGlow-1.0", true)
local Masque = LibStub and LibStub("Masque", true)
-- Debounce table keyed by group object: one deferred ReSkin per group per frame
local masqueReskinPending = {}
local fontUtil = addon.Utils.FontUtil
local cachedDb = nil

local function UpdateChargeTextFontSize(chargeText, iconSize)
	local font, _, flags = chargeText:GetFont()
	if font then
		chargeText:SetFont(font, math.floor(iconSize * 0.35), flags)
	end
end
-- Reused across Layout() calls to avoid a table allocation on the hot path
local layoutScratch = {}
local frameIdCounter = 0
local function NextFrameName(frameType)
	frameIdCounter = frameIdCounter + 1
	return "MiniCC_" .. frameType .. "_" .. frameIdCounter
end

---@class IconSlotContainer
local M = {}
M.__index = M

addon.Core.IconSlotContainer = M

local function GetDb()
	if not cachedDb then
		local mini = addon.Core.Framework
		if mini and mini.GetSavedVars then
			cachedDb = mini:GetSavedVars()
		end
	end

	return cachedDb
end

local function ScheduleMasqueReSkin(group)
	if not group or masqueReskinPending[group] then
		return
	end
	masqueReskinPending[group] = true
	C_Timer.After(0, function()
		masqueReskinPending[group] = nil
		group:ReSkin()
	end)
end

local function CreateLayer(parentFrame, level, iconSize, noBorder)
	local f = CreateFrame("Frame", NextFrameName("Layer"), parentFrame)
	f:SetAllPoints()

	if level then
		f:SetFrameLevel(level)
	end

	-- place our icons on the 1st draw layer of background
	local icon = f:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetAllPoints()

	local cd = CreateFrame("Cooldown", NextFrameName("Cooldown"), f, "CooldownFrameTemplate")
	cd:SetAllPoints()
	cd:SetDrawEdge(false)
	cd:SetDrawBling(false)
	cd:SetHideCountdownNumbers(false)
	cd:SetSwipeColor(0, 0, 0, 0.8)
	-- When the cooldown expires naturally the frame hides itself via OnCooldownDone without
	-- any external code calling SetSlot again. Clear desaturation immediately so the icon
	-- doesn't stay grey until the next UpdateDisplay (e.g. the delayed ARENA_COOLDOWNS_UPDATE).
	cd:SetScript("OnCooldownDone", function()
		icon:SetDesaturated(false)
	end)

	local border
	if not noBorder then
		-- make the border 1px larger than the icon
		-- refer to https://github.com/Gethe/wow-ui-source/blob/aa3d9bc8633244ba017bf2058bf5e84900397ab5/Interface/AddOns/Blizzard_UnitFrame/Shared/CompactUnitFrame.xml#L31
		border = f:CreateTexture(nil, "OVERLAY")
		border:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 1)
		border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
		border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
		border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
		border:Hide()
	end

	if iconSize then
		cd.DesiredIconSize = iconSize
		-- FontScale will be set when SetSlot is called
		cd.FontScale = 1.0
		fontUtil:UpdateCooldownFontSize(cd, iconSize, nil, cd.FontScale)
	end

	return { Frame = f, Border = border, Icon = icon, Cooldown = cd }
end

local function EnsureContainer(slot, iconSize, group, noBorder)
	if slot.Container then
		return slot.Container
	end

	-- Wrap in its own frame so its alpha doesn't propagate to extra layers,
	-- which are siblings (also children of slot.Frame) rather than descendants.
	local slotLevel = slot.Frame:GetFrameLevel() or 0
	slot.Container = CreateLayer(slot.Frame, slotLevel + 1, iconSize, noBorder)

	if group then
		group:AddButton(slot.Container.Frame, {
			Icon = slot.Container.Icon,
			Cooldown = slot.Container.Cooldown,
		})
	end

	return slot.Container
end

-- layerIndex is the public layer number (2, 3, …); extra layer 1 lives at slot.ExtraLayers[1], etc.
local function EnsureExtraLayer(slot, layerIndex, iconSize)
	local extraIdx = layerIndex - 1
	if not slot.ExtraLayers then
		slot.ExtraLayers = {}
	end

	local slotLevel = slot.Frame:GetFrameLevel() or 0
	-- Base layer (slot.Container) occupies slotLevel+1.
	-- Extra layer l (1-based) sits at slotLevel + 1 + l*2 so each layer clears
	-- the cooldown text draw layer of the one below it.
	local baseLevel = slotLevel + 1

	for l = #slot.ExtraLayers + 1, extraIdx do
		slot.ExtraLayers[l] = CreateLayer(slot.Frame, baseLevel + l * 2, iconSize)
	end

	-- Re-apply levels if the slot frame level has changed since last time.
	if slot.LastExtraBaseLevel ~= baseLevel then
		slot.LastExtraBaseLevel = baseLevel
		for l = 1, #slot.ExtraLayers do
			local el = slot.ExtraLayers[l]
			if el and el.Frame then
				el.Frame:SetFrameLevel(baseLevel + l * 2)
			end
		end
	end

	return slot.ExtraLayers[extraIdx]
end

local function ApplyAlpha(target, alpha)
	if type(alpha) == "number" then
		target:SetAlpha(alpha)
	else
		target:SetAlphaFromBoolean(alpha)
	end
end

local function EnsureFlipbookGlow(parent)
	if parent._FlipbookGlow then
		return parent._FlipbookGlow
	end

	local cg = CreateFrame("Frame", NextFrameName("FlipbookGlow"), parent)
	cg:SetFrameLevel(parent:GetFrameLevel() + 5)

	cg.Texture = cg:CreateTexture(nil, "OVERLAY")
	cg.Texture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\FlipbookWhite.tga")
	cg.Texture:SetAllPoints()
	cg.Texture:SetBlendMode("ADD")

	cg.Anim = cg:CreateAnimationGroup()
	cg.Anim:SetLooping("REPEAT")
	local flip = cg.Anim:CreateAnimation("FlipBook")
	flip:SetChildKey("Texture")
	flip:SetFlipBookRows(6)
	flip:SetFlipBookColumns(5)
	flip:SetFlipBookFrames(30)
	flip:SetDuration(1.0)
	cg.Anim:Play()

	-- Hook the parent's size. When Nameplates or Alerts change scale, the padding stays proportional!
	parent:HookScript("OnSizeChanged", function(self, width)
		if self._FlipbookGlow then
			local padding = width / 3
			self._FlipbookGlow:SetPoint("TOPLEFT", self, "TOPLEFT", -padding, padding)
			self._FlipbookGlow:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", padding, -padding)
		end
	end)

	-- Set initial sizing
	local width = parent:GetWidth()
	local initPadding = (width and width > 0) and (width / 3) or 9
	cg:SetPoint("TOPLEFT", parent, "TOPLEFT", -initPadding, initPadding)
	cg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", initPadding, -initPadding)

	cg:Hide()
	parent._FlipbookGlow = cg
	return cg
end

local function ClearLayerData(layer, glowFrame)
	if not layer then
		return
	end
	layer.Icon:SetTexture(nil)
	layer.Cooldown:Clear()
	if layer.ChargeText then
		layer.ChargeText:Hide()
	end
	if LCG then
		if glowFrame._ProcGlow and LCG.ProcGlow_Stop then
			LCG.ProcGlow_Stop(glowFrame)
		end
		if glowFrame._PixelGlow and LCG.PixelGlow_Stop then
			LCG.PixelGlow_Stop(glowFrame)
		end
		if glowFrame._AutoCastGlow and LCG.AutoCastGlow_Stop then
			LCG.AutoCastGlow_Stop(glowFrame)
		end
	end
	if glowFrame._FlipbookGlow then
		glowFrame._FlipbookGlow:Hide()
	end
end

---Updates glow effects on a layer frame
---@param layerFrame table The layer frame to update glow on
---@param options IconLayerOptions Options containing glow settings
local function UpdateGlow(layerFrame, options)
	local db = GetDb()
	local glowType = (db and db.GlowType) or "Proc Glow"

	if options.Glow then
		-- Check which glow types currently exist
		local hasProcGlow = layerFrame._ProcGlow ~= nil
		local hasPixelGlow = layerFrame._PixelGlow ~= nil
		local hasAutoCastGlow = layerFrame._AutoCastGlow ~= nil
		local hasCustomGlow = layerFrame._FlipbookGlow ~= nil

		-- Check if color has changed
		local colorChanged = false
		local newColorKey = nil

		if options.Color then
			newColorKey = string.format(
				"%.2f_%.2f_%.2f_%.2f",
				options.Color.r or 1,
				options.Color.g or 1,
				options.Color.b or 1,
				options.Color.a or 1
			)
		end

		if not newColorKey or not issecretvalue(newColorKey) then
			if layerFrame._GlowColorKey ~= newColorKey then
				colorChanged = true
				layerFrame._GlowColorKey = newColorKey
			end
		elseif newColorKey and issecretvalue(newColorKey) then
			colorChanged = true
		end

		-- Determine if we need to start a new glow
		local needsGlow = false
		if glowType == "Proc Glow" and (not hasProcGlow or colorChanged) then
			needsGlow = true
			if hasPixelGlow and LCG.PixelGlow_Stop then
				LCG.PixelGlow_Stop(layerFrame)
			end
			if hasAutoCastGlow and LCG.AutoCastGlow_Stop then
				LCG.AutoCastGlow_Stop(layerFrame)
			end
			if hasProcGlow and colorChanged and LCG.ProcGlow_Stop then
				LCG.ProcGlow_Stop(layerFrame)
			end
			if hasCustomGlow then
				layerFrame._FlipbookGlow:Hide()
			end
		elseif glowType == "Pixel Glow" and (not hasPixelGlow or colorChanged) then
			needsGlow = true
			if hasProcGlow and LCG.ProcGlow_Stop then
				LCG.ProcGlow_Stop(layerFrame)
			end
			if hasAutoCastGlow and LCG.AutoCastGlow_Stop then
				LCG.AutoCastGlow_Stop(layerFrame)
			end
			if hasPixelGlow and colorChanged and LCG.PixelGlow_Stop then
				LCG.PixelGlow_Stop(layerFrame)
			end
			if hasCustomGlow then
				layerFrame._FlipbookGlow:Hide()
			end
		elseif glowType == "Autocast Shine" and (not hasAutoCastGlow or colorChanged) then
			needsGlow = true
			if hasProcGlow and LCG.ProcGlow_Stop then
				LCG.ProcGlow_Stop(layerFrame)
			end
			if hasPixelGlow and LCG.PixelGlow_Stop then
				LCG.PixelGlow_Stop(layerFrame)
			end
			if hasAutoCastGlow and colorChanged and LCG.AutoCastGlow_Stop then
				LCG.AutoCastGlow_Stop(layerFrame)
			end
			if hasCustomGlow then
				layerFrame._FlipbookGlow:Hide()
			end
		elseif
			glowType == "Rotation Assist"
			and (not hasCustomGlow or colorChanged or not layerFrame._FlipbookGlow:IsShown())
		then
			needsGlow = true
			if hasProcGlow and LCG.ProcGlow_Stop then
				LCG.ProcGlow_Stop(layerFrame)
			end
			if hasPixelGlow and LCG.PixelGlow_Stop then
				LCG.PixelGlow_Stop(layerFrame)
			end
			if hasAutoCastGlow and LCG.AutoCastGlow_Stop then
				LCG.AutoCastGlow_Stop(layerFrame)
			end
		end

		-- Only start glow if needed
		if needsGlow then
			local glowOptions = { startAnim = false }

			if options.Color then
				glowOptions.color = { options.Color.r, options.Color.g, options.Color.b, options.Color.a }
			end

			if glowType == "Pixel Glow" and LCG and LCG.PixelGlow_Start then
				LCG.PixelGlow_Start(layerFrame, glowOptions.color)
			elseif glowType == "Autocast Shine" and LCG and LCG.AutoCastGlow_Start then
				LCG.AutoCastGlow_Start(layerFrame, glowOptions.color)
			elseif glowType == "Rotation Assist" then
				local cg = EnsureFlipbookGlow(layerFrame)
				if options.Color then
					cg.Texture:SetVertexColor(
						options.Color.r or 1,
						options.Color.g or 1,
						options.Color.b or 1,
						options.Color.a or 1
					)
				else
					cg.Texture:SetVertexColor(1, 1, 1, 1)
				end
				cg:Show()
			else
				if LCG and LCG.ProcGlow_Start then
					LCG.ProcGlow_Start(layerFrame, glowOptions)
				end
			end
		end

		-- Always update alpha for the active glow type
		local alpha = options.Alpha
		if glowType == "Proc Glow" then
			local procGlow = layerFrame._ProcGlow
			if procGlow then
				ApplyAlpha(procGlow, alpha)
			end
		elseif glowType == "Pixel Glow" then
			local pixelGlow = layerFrame._PixelGlow
			if pixelGlow then
				ApplyAlpha(pixelGlow, alpha)
			end
		elseif glowType == "Autocast Shine" then
			local autoCastGlow = layerFrame._AutoCastGlow
			if autoCastGlow then
				ApplyAlpha(autoCastGlow, alpha)
			end
		elseif glowType == "Rotation Assist" then
			if layerFrame._FlipbookGlow then
				ApplyAlpha(layerFrame._FlipbookGlow, alpha)
			end
		end

		-- calling ProcGlow_Start on an existing glow will reset its size to match the current icon size
		if glowType == "Proc Glow" and layerFrame._ProcGlow and LCG and LCG.ProcGlow_Start then
			local glowOptions = { startAnim = false }
			if options.Color then
				glowOptions.color = { options.Color.r, options.Color.g, options.Color.b, options.Color.a }
			end
			LCG.ProcGlow_Start(layerFrame, glowOptions)
		end
	else
		-- Stop all glow types only if any exist
		if layerFrame._ProcGlow and LCG and LCG.ProcGlow_Stop then
			LCG.ProcGlow_Stop(layerFrame)
		end
		if layerFrame._PixelGlow and LCG and LCG.PixelGlow_Stop then
			LCG.PixelGlow_Stop(layerFrame)
		end
		if layerFrame._AutoCastGlow and LCG and LCG.AutoCastGlow_Stop then
			LCG.AutoCastGlow_Stop(layerFrame)
		end
		if layerFrame._FlipbookGlow then
			layerFrame._FlipbookGlow:Hide()
		end
		layerFrame._GlowColorKey = nil
	end
end

---Creates a new IconSlotContainer instance
---@param parent table frame to attach to
---@param count number of slots to create (default: 3)
---@param size number of each icon slot (default: 20)
---@param spacing number between slots (default: 2)
---@param groupName string? Masque sub-group name (e.g. "CC", "Trinkets"). Omit to skip Masque.
---@param noBorder boolean? When true, skips creating the border texture on each layer.
---@param moduleName string? Overrides the MiniCCModule label set on Frame. Defaults to groupName.
---@return IconSlotContainer
function M:New(parent, count, size, spacing, groupName, noBorder, moduleName)
	local instance = setmetatable({}, M)

	count = count or 3
	size = size or 20
	spacing = spacing or 2

	instance.Frame = CreateFrame("Frame", NextFrameName("Container"), parent)
	instance.Frame:SetIgnoreParentScale(true)
	instance.Frame:SetIgnoreParentAlpha(true)
	instance.Slots = {}
	instance.Count = 0
	instance.Size = size
	instance.Spacing = spacing
	instance.NumRows = nil
	instance.RowAlignment = nil
	instance.InvertLayout = false
	instance.Columns = nil
	instance.NoBorder = noBorder or false
	instance.Frame.MiniCCModule = moduleName or nil
	instance.MasqueGroup = Masque and groupName and Masque:Group("MiniCC", groupName) or nil

	instance:SetCount(count)

	return instance
end

function M:Layout()
	-- Populate scratch table with used slot indices
	local n = 0
	for i = 1, self.Count do
		if self.Slots[i] and self.Slots[i].IsUsed then
			n = n + 1
			layoutScratch[n] = i
		end
	end

	-- Build a cheap signature from the current size, row settings, and used slot indices.
	-- If it matches the last run, the visual result would be identical so we
	-- can skip all the SetPoint/SetSize/Show/Hide calls.
	local numRows = (not self.GrowDown and self.NumRows and self.NumRows > 1) and self.NumRows or nil
	local columnsPerRow = (self.GrowDown and self.Columns and self.Columns > 1) and self.Columns or nil
	local sig = self.Size .. ":" .. (numRows or 1) .. ":" .. (self.RowAlignment or "C") .. ":" .. (self.OverflowRowAlignment or "C") .. ":" .. (self.InvertLayout and "1" or "0") .. ":" .. (self.GrowDown and "D" or "H") .. ":" .. (columnsPerRow or 1) .. ":" .. table.concat(layoutScratch, ",", 1, n)
	if self.LayoutSignature == sig then
		return
	end
	self.LayoutSignature = sig

	-- Trim stale entries left over from a previous call with more slots
	for i = n + 1, #layoutScratch do
		layoutScratch[i] = nil
	end

	local usedCount = n

	if usedCount == 0 then
		self.Frame:SetSize(self.Size, self.Size)
	elseif numRows then
		-- Multi-row layout: divide active icons across the requested number of rows
		local iconsPerRow = math.max(1, math.ceil(usedCount / numRows))
		local actualRows = math.ceil(usedCount / iconsPerRow)
		local rowWidth = iconsPerRow * self.Size + (iconsPerRow - 1) * self.Spacing
		local totalHeight = actualRows * self.Size + (actualRows - 1) * self.Spacing
		self.Frame:SetSize(rowWidth, totalHeight)
		self.Frame:SetAlpha(1)

		local row1Alignment = self.RowAlignment or "CENTER"
		local overflowAlignment = self.OverflowRowAlignment or row1Alignment

		for displayIndex = 1, usedCount do
			local slot = self.Slots[layoutScratch[displayIndex]]
			local rowIndex = math.floor((displayIndex - 1) / iconsPerRow) -- 0-based
			-- When InvertLayout is set, reverse the column order so slot 1 lands at the
			-- rightmost position of every row instead of the leftmost.
			local rawCol = (displayIndex - 1) % iconsPerRow -- 0-based
			local colIndex = self.InvertLayout and (iconsPerRow - 1 - rawCol) or rawCol
			local rowIcons = (rowIndex == actualRows - 1) and (usedCount - (actualRows - 1) * iconsPerRow) or iconsPerRow

			local x
			if self.InvertLayout then
				-- Inverted: use simple LEFT formula; column reversal already handles right-to-left
				-- fill, so partial rows are naturally right-aligned without an extra shift.
				x = colIndex * (self.Size + self.Spacing) - (rowWidth / 2) + (self.Size / 2)
			else
				local alignment = rowIndex == 0 and row1Alignment or overflowAlignment
				if alignment == "LEFT" then
					x = colIndex * (self.Size + self.Spacing) - (rowWidth / 2) + (self.Size / 2)
				elseif alignment == "RIGHT" then
					local shift = (iconsPerRow - rowIcons) * (self.Size + self.Spacing)
					x = colIndex * (self.Size + self.Spacing) - (rowWidth / 2) + (self.Size / 2) + shift
				else -- CENTER
					local thisRowWidth = rowIcons * self.Size + (rowIcons - 1) * self.Spacing
					x = colIndex * (self.Size + self.Spacing) - (thisRowWidth / 2) + (self.Size / 2)
				end
			end
			local y = (totalHeight / 2) - (self.Size / 2) - rowIndex * (self.Size + self.Spacing)

			slot.Frame:ClearAllPoints()
			slot.Frame:SetPoint("CENTER", self.Frame, "CENTER", x, y)
			slot.Frame:SetSize(self.Size, self.Size)
			slot.Frame:Show()
		end
	elseif self.GrowDown and columnsPerRow then
		-- Grid grow-down: icons fill left-to-right up to columnsPerRow per row, then wrap down
		local cols = columnsPerRow
		local actualRows = math.ceil(usedCount / cols)
		local rowWidth = cols * self.Size + (cols - 1) * self.Spacing
		local totalHeight = actualRows * self.Size + (actualRows - 1) * self.Spacing
		self.Frame:SetSize(rowWidth, totalHeight)
		self.Frame:SetAlpha(1)

		for displayIndex = 1, usedCount do
			local slot = self.Slots[layoutScratch[displayIndex]]
			local rowIndex = math.floor((displayIndex - 1) / cols) -- 0-based
			local colIndex = (displayIndex - 1) % cols             -- 0-based
			-- Number of icons in this row (may be less than cols on the last row)
			local rowIcons = math.min(cols, usedCount - rowIndex * cols)
			-- Center this row within the full grid width
			local thisRowWidth = rowIcons * self.Size + (rowIcons - 1) * self.Spacing
			local rowOffsetX = (rowWidth - thisRowWidth) / 2
			local x = rowOffsetX + colIndex * (self.Size + self.Spacing) - (rowWidth / 2) + (self.Size / 2)
			local y = (totalHeight / 2) - (self.Size / 2) - rowIndex * (self.Size + self.Spacing)

			slot.Frame:ClearAllPoints()
			slot.Frame:SetPoint("CENTER", self.Frame, "CENTER", x, y)
			slot.Frame:SetSize(self.Size, self.Size)
			slot.Frame:Show()
		end
	elseif self.GrowDown then
		-- Vertical single column, growing downward
		local totalHeight = usedCount * self.Size + (usedCount - 1) * self.Spacing
		self.Frame:SetSize(self.Size, totalHeight)
		self.Frame:SetAlpha(1)

		for displayIndex = 1, usedCount do
			local slot = self.Slots[layoutScratch[displayIndex]]
			local y = (totalHeight / 2) - (self.Size / 2) - (displayIndex - 1) * (self.Size + self.Spacing)
			slot.Frame:ClearAllPoints()
			slot.Frame:SetPoint("CENTER", self.Frame, "CENTER", 0, y)
			slot.Frame:SetSize(self.Size, self.Size)
			slot.Frame:Show()
		end
	else
		-- Single row
		local totalWidth = usedCount * self.Size + (usedCount - 1) * self.Spacing
		self.Frame:SetSize(totalWidth, self.Size)
		self.Frame:SetAlpha(1)

		for displayIndex = 1, usedCount do
			local slot = self.Slots[layoutScratch[displayIndex]]
			-- When InvertLayout is set, mirror the position so slot 1 is rightmost.
			local effIndex = self.InvertLayout and (usedCount - displayIndex + 1) or displayIndex
			local x = (effIndex - 1) * (self.Size + self.Spacing) - (totalWidth / 2) + (self.Size / 2)
			slot.Frame:ClearAllPoints()
			slot.Frame:SetPoint("CENTER", self.Frame, "CENTER", x, 0)
			slot.Frame:SetSize(self.Size, self.Size)
			slot.Frame:Show()
		end
	end

	-- Hide unused active slots
	for i = 1, self.Count do
		local slot = self.Slots[i]
		if slot and not slot.IsUsed then
			slot.Frame:Hide()
		end
	end

	-- Always hide inactive pooled slots
	for i = self.Count + 1, #self.Slots do
		local slot = self.Slots[i]
		if slot then
			slot.IsUsed = false
			slot.Frame:Hide()
		end
	end

	-- testing to see if this helps with the weird issue with randomly large Masque borders and icons
	ScheduleMasqueReSkin(self.MasqueGroup)
end

---Sets the spacing between slots
---@param newSpacing number
function M:SetSpacing(newSpacing)
	---@diagnostic disable-next-line: cast-local-type
	newSpacing = tonumber(newSpacing)
	if not newSpacing or newSpacing < 0 then
		return
	end
	if self.Spacing == newSpacing then
		return
	end

	self.Spacing = newSpacing
	self.LayoutSignature = nil
	self:Layout()
end

---Sets the number of rows to distribute icons across, and the alignment of partial rows.
---Rows 2+ automatically use the opposite alignment (LEFT<->RIGHT) so that overflow icons
---hug the edge the container grows from.
---@param numRows number? 1 or nil means single row (no multi-row layout)
---@param alignment string? "LEFT", "RIGHT", or "CENTER" (default)
---@param invertLayout boolean? When true, slot 1 is placed at the rightmost position and the layout fills right-to-left. Use this instead of reversing the slots array so multi-row behaves consistently.
function M:SetRows(numRows, alignment, invertLayout)
	numRows = (numRows and numRows > 1) and math.floor(numRows) or nil
	alignment = alignment or "CENTER"
	local overflowAlignment
	if alignment == "LEFT" then
		overflowAlignment = "RIGHT"
	elseif alignment == "RIGHT" then
		overflowAlignment = "LEFT"
	else
		overflowAlignment = alignment
	end
	invertLayout = invertLayout and true or false
	if self.NumRows == numRows and self.RowAlignment == alignment and self.OverflowRowAlignment == overflowAlignment and self.InvertLayout == invertLayout then
		return
	end
	self.NumRows = numRows
	self.RowAlignment = alignment
	self.OverflowRowAlignment = overflowAlignment
	self.InvertLayout = invertLayout
	self.LayoutSignature = nil
	self:Layout()
end

---Switches the container to a vertical single-column layout, growing downward.
---When enabled, multi-row settings are ignored.
---@param enabled boolean
function M:SetGrowDown(enabled)
	enabled = enabled and true or false
	if self.GrowDown == enabled then
		return
	end
	self.GrowDown = enabled
	self.LayoutSignature = nil
	self:Layout()
end

---Sets the maximum number of icons per row when growing downward.
---Only effective when GrowDown is true; a value of 1 or nil reverts to a single column.
---@param n number? Maximum icons per row; nil or 1 means single column
function M:SetColumns(n)
	n = (n and n > 1) and math.floor(n) or nil
	if self.Columns == n then
		return
	end
	self.Columns = n
	self.LayoutSignature = nil
	self:Layout()
end

---Sets the icon size for all slots
---@param newSize number
function M:SetIconSize(newSize)
	---@diagnostic disable-next-line: cast-local-type
	newSize = tonumber(newSize)
	if not newSize or newSize <= 0 then
		return
	end
	if self.Size == newSize then
		return
	end

	self.Size = newSize

	-- Resize active slots and update cooldown font sizes
	for i = 1, self.Count do
		local slot = self.Slots[i]
		if slot and slot.Frame then
			slot.Frame:SetSize(self.Size, self.Size)

			local layer = slot.Container
			if layer and layer.Cooldown then
				layer.Cooldown.DesiredIconSize = self.Size
				local fontScale = layer.Cooldown.FontScale or 1.0
				fontUtil:UpdateCooldownFontSize(layer.Cooldown, self.Size, nil, fontScale)
			end
			if layer and layer.ChargeText then
				UpdateChargeTextFontSize(layer.ChargeText, self.Size)
			end

			if slot.ExtraLayers then
				for _, el in ipairs(slot.ExtraLayers) do
					if el then
						if el.Frame then
							el.Frame:SetSize(self.Size, self.Size)
						end
						if el.Cooldown then
							el.Cooldown.DesiredIconSize = self.Size
							local fontScale = el.Cooldown.FontScale or 1.0
							fontUtil:UpdateCooldownFontSize(el.Cooldown, self.Size, nil, fontScale)
						end
						if el.ChargeText then
							UpdateChargeTextFontSize(el.ChargeText, self.Size)
						end
					end
				end
			end
		end
	end

	-- Re-apply the Masque skin at the new size, debounced per group.
	ScheduleMasqueReSkin(self.MasqueGroup)

	self:Layout()
end

---Sets the total number of slots
---@param newCount number of slots to maintain
function M:SetCount(newCount)
	newCount = math.max(0, newCount or 0)
	if newCount == self.Count then
		return
	end

	-- If shrinking, disable anything beyond newCount (pooled slots)
	if newCount < self.Count then
		for i = newCount + 1, #self.Slots do
			local slot = self.Slots[i]
			if slot then
				slot.IsUsed = false
				self:ClearSlot(i)
				slot.Frame:Hide()
			end
		end
	end

	self.Count = newCount

	-- Grow pool if needed
	for i = #self.Slots + 1, newCount do
		local slotFrame = CreateFrame(self.MasqueGroup and "Button" or "Frame", NextFrameName("Slot"), self.Frame)
		slotFrame:SetSize(self.Size, self.Size)
		slotFrame:EnableMouse(false)

		self.Slots[i] = {
			Frame = slotFrame,
			Container = nil,
			ExtraLayers = {},
			IsUsed = false,
		}
	end

	self:Layout()
end

---Sets an icon on a specific slot, optionally on a stacked layer above it.
---@param slotIndex number Slot index (1-based)
---@param options IconLayerOptions Options for the layer
---@class IconLayerOptions
---@field Texture string Texture path/ID
---@field DurationObject table? DurationObject from C_DurationUtil.CreateDuration or C_UnitAuras.GetAuraDuration
---@field Alpha number|boolean? Control alpha: number sets it directly, boolean uses SetAlphaFromBoolean
---@field Glow boolean? Whether to show glow effect (requires LibCustomGlow)
---@field ReverseCooldown boolean? Whether to reverse the cooldown animation
---@field Color table? RGBA color table {r, g, b, a} for glow and border color
---@field FontScale number? Font scale multiplier for cooldown text (default: 1.0)
---@field Layer number? Which layer to render on (1 = base, 2+ = stacked above; default: 1)
---@field SpellId number? Spell ID for tooltip on hover
function M:SetSlot(slotIndex, options)
	if slotIndex < 1 or slotIndex > self.Count then
		return
	end

	if not options.Texture then
		return
	end

	local slot = self.Slots[slotIndex]

	if not slot then
		return
	end

	if not slot.IsUsed then
		slot.IsUsed = true
		self:Layout()
	end

	slot.SpellId = options.SpellId
	if options.SpellId then
		if not slot.MouseEnabled then
			slot.MouseEnabled = true
			slot.Frame:EnableMouse(true)
			slot.Frame:SetScript("OnEnter", function(f)
				if slot.SpellId then
					GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
					GameTooltip:SetSpellByID(slot.SpellId)
					GameTooltip:Show()
				end
			end)
			slot.Frame:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
		end
	elseif slot.MouseEnabled then
		slot.MouseEnabled = false
		slot.Frame:EnableMouse(false)
		slot.Frame:SetScript("OnEnter", nil)
		slot.Frame:SetScript("OnLeave", nil)
	end

	local layerIndex = options.Layer or 1
	local layer

	if layerIndex <= 1 then
		layer = EnsureContainer(slot, self.Size, self.MasqueGroup, self.NoBorder)
	else
		layer = EnsureExtraLayer(slot, layerIndex, self.Size)
	end

	local db = GetDb()
	layer.Icon:SetTexture(options.Texture)
	layer.Cooldown:SetReverse(options.ReverseCooldown)
	if layer.Cooldown.SetCountdownMillisecondsThreshold then
		layer.Cooldown:SetCountdownMillisecondsThreshold(options.ShowMilliseconds and (db and db.MillisecondsThreshold or 5) or 0)
	end

	if options.DurationObject then
		layer.Cooldown:SetCooldownFromDurationObject(options.DurationObject)
		layer.Cooldown:SetDrawSwipe(not (db and db.DisableSwipe))
	else
		layer.Cooldown:Clear()
		layer.Cooldown:SetDrawSwipe(false)
	end
	-- Query IsShown() AFTER setting the cooldown - the frame hides itself when the
	-- duration is zero or expired, so this is the authoritative "on cooldown" check.
	layer.Icon:SetDesaturated(options.Desaturate and layer.Cooldown:IsShown() or false)

	if options.ChargeText then
		if not layer.ChargeText then
			local overlay = CreateFrame("Frame", nil, layer.Frame)
			overlay:SetAllPoints(layer.Frame)
			overlay:SetFrameLevel(layer.Cooldown:GetFrameLevel() + 1)
			layer.ChargeText = overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
			layer.ChargeText:SetPoint("BOTTOMRIGHT", layer.Frame, "BOTTOMRIGHT", -3, 1)
		end
		UpdateChargeTextFontSize(layer.ChargeText, self.Size)
		layer.ChargeText:SetText(options.ChargeText)
		layer.ChargeText:Show()
	elseif layer.ChargeText then
		layer.ChargeText:Hide()
	end

	ApplyAlpha(layer.Frame, options.Alpha)

	if options.Color and layer.Border then
		layer.Border:SetVertexColor(
			options.Color.r or 1,
			options.Color.g or 1,
			options.Color.b or 1,
			options.Color.a or 1
		)
		layer.Border:Show()
	elseif layer.Border then
		layer.Border:Hide()
	end

	if options.FontScale then
		layer.Cooldown.FontScale = options.FontScale
		fontUtil:UpdateCooldownFontSize(layer.Cooldown, self.Size, nil, options.FontScale)
	end

	UpdateGlow(layer.Frame, options)
end

-- Clears all layers on a slot
---@param slotIndex number Slot index
function M:ClearSlot(slotIndex)
	if slotIndex < 1 or slotIndex > #self.Slots then
		return
	end

	local slot = self.Slots[slotIndex]
	if not slot or not slot.Container then
		return
	end

	slot.SpellId = nil
	ClearLayerData(slot.Container, slot.Container.Frame)

	if slot.ExtraLayers then
		for _, el in ipairs(slot.ExtraLayers) do
			if el then
				ClearLayerData(el, el.Frame)
			end
		end
	end
end

---Marks a slot as unused and triggers layout update
---This will shift all other used slots to fill the gap
---@param slotIndex number Slot index
function M:SetSlotUnused(slotIndex)
	if slotIndex < 1 or slotIndex > self.Count then
		return
	end

	local slot = self.Slots[slotIndex]
	if not slot then
		return
	end

	if slot.IsUsed then
		slot.IsUsed = false
		self:ClearSlot(slotIndex)
		self:Layout()
	end
end

---Gets the number of currently used slots
---@return number Count of used slots
function M:GetUsedSlotCount()
	local count = 0
	for i = 1, self.Count do
		if self.Slots[i] and self.Slots[i].IsUsed then
			count = count + 1
		end
	end
	return count
end

---Resets all slots to unused (active range only)
function M:ResetAllSlots()
	local needsLayout = false
	for i = 1, self.Count do
		local slot = self.Slots[i]
		if slot and slot.IsUsed then
			slot.IsUsed = false
			self:ClearSlot(i)
			needsLayout = true
		end
	end
	if needsLayout then
		self:Layout()
	end
end

---@class IconLayer
---@field Frame table
---@field Icon table
---@field Cooldown table
---@field Border table

---@class IconSlot
---@field Frame table
---@field Container IconLayer?
---@field ExtraLayers IconLayer[]
---@field IsUsed boolean

---@class IconSlotContainer
---@field Frame table
---@field MasqueGroup table?
---@field Slots IconSlot[]
---@field Count number
---@field Size number
---@field Spacing number
---@field NumRows number?
---@field RowAlignment string?
---@field OverflowRowAlignment string?
---@field InvertLayout boolean
---@field Columns number?
---@field NoBorder boolean
---@field SetCount fun(self: IconSlotContainer, count: number)
---@field SetSpacing fun(self: IconSlotContainer, spacing: number)
---@field SetRows fun(self: IconSlotContainer, iconsPerRow: number?, alignment: string?, invertLayout: boolean?)
---@field SetGrowDown fun(self: IconSlotContainer, enabled: boolean)
---@field SetColumns fun(self: IconSlotContainer, n: number?)
---@field SetIconSize fun(self: IconSlotContainer, size: number)
---@field SetSlot fun(self: IconSlotContainer, slotIndex: number, options: IconLayerOptions)
---@field ClearSlot fun(self: IconSlotContainer, slotIndex: number)
---@field SetSlotUnused fun(self: IconSlotContainer, slotIndex: number)
---@field GetUsedSlotCount fun(self: IconSlotContainer): number
---@field ResetAllSlots fun(self: IconSlotContainer)

