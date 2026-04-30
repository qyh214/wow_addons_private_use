---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local wowEx = addon.Utils.WoWEx

addon.Modules.EnemyCooldowns = addon.Modules.EnemyCooldowns or {}

---@class EnemyCooldownDisplay
local D = {}
addon.Modules.EnemyCooldowns.Display = D

---@type Db
local db
local testModeActive = false

-- C_Spell.GetSpellInfo follows talent overrides locally; use originalIconID to get the
-- canonical icon unaffected by the viewing player's own talent replacements.
local function GetSpellIcon(spellId)
	local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellId)
	return (info and info.originalIconID) or C_Spell.GetSpellTexture(spellId)
end

local function GetOptions()
	return db and db.Modules.EnemyCooldownTrackerModule
end

---Returns the arena enemy frame for the given index, checking known frame addons in order:
---Blizzard (CompactArenaFrame.memberUnitFrames[index]), then sArena Reloaded (sArenaEnemyFrame1/2/3).
---@param index number
---@return table?
local function GetArenaEnemyFrame(index)
	local sArena = _G["sArenaEnemyFrame" .. index]
	if sArena then
		return sArena
	end
	local blizz = CompactArenaFrame and CompactArenaFrame.memberUnitFrames
	return blizz and blizz[index]
end

-- Scratch table reused by UpdateDisplay to avoid per-call allocation.
local slotsScratch = {}

---Populates an entry's icon container with the current enemy cooldown state.
---Shows committed cooldowns (buff has expired, CD timer running).
---@param entry EcdWatchEntry
local function UpdateDisplay(entry)
	local options = GetOptions()
	if not options then
		return
	end

	local container = entry.Container
	local showTooltips = options.ShowTooltips
	local iconOptions = options.Icons

	if testModeActive then
		local now = GetTime()
		local testSpells = {
			{ SpellId = 45438,  StartOffset = 30,  Cooldown = 240 }, -- Ice Block
			{ SpellId = 642,    StartOffset = 15,  Cooldown = 300 }, -- Divine Shield
			{ SpellId = 31224,  StartOffset = 10,  Cooldown = 60  }, -- Cloak of Shadows
			{ SpellId = 48792,  StartOffset = 45,  Cooldown = 180 }, -- Icebound Fortitude
			{ SpellId = 47585,  StartOffset = 5,   Cooldown = 120 }, -- Dispersion
			{ SpellId = 22812,  StartOffset = 20,  Cooldown = 60  }, -- Barkskin
			{ SpellId = 871,    StartOffset = 60,  Cooldown = 240 }, -- Shield Wall
			{ SpellId = 33206,  StartOffset = 8,   Cooldown = 120 }, -- Pain Suppression
		}
		local usedCount = 0
		for _, t in ipairs(testSpells) do
			local texture = GetSpellIcon(t.SpellId)
			if texture and usedCount < container.Count then
				usedCount = usedCount + 1
				container:SetSlot(usedCount, {
					Texture = texture,
					SpellId = showTooltips and t.SpellId or nil,
					DurationObject = wowEx:CreateDuration(now - t.StartOffset, t.Cooldown),
					Alpha = 1,
					ReverseCooldown = iconOptions.ReverseCooldown,
					FontScale = db.FontScale,
				})
			end
		end
		for i = usedCount + 1, container.Count do
			container:SetSlotUnused(i)
		end
		return
	end

	-- Reuse the scratch table to avoid per-call allocation.
	local slots = slotsScratch
	for i = 1, #slots do
		slots[i] = nil
	end

	local now = GetTime()
	local disabledSpells = options.DisabledSpells or {}

	-- Committed cooldowns: buff has expired, CD timer is running.
	for cdKey, cd in pairs(entry.ActiveCooldowns) do
		if cd.UsedCharges then
			-- Multi-charge entry: visible while at least one charge is recharging.
			local usedCount = #cd.UsedCharges
			if usedCount > 0 then
				local texture = cd.SpellId and not disabledSpells[cd.SpellId] and GetSpellIcon(cd.SpellId)
				if texture then
					local startTime = cd.UsedCharges[1].Expiry - cd.Cooldown
					slots[#slots + 1] = {
						Texture        = texture,
						SpellId        = showTooltips and cd.SpellId or nil,
						DurationObject = wowEx:CreateDuration(startTime, cd.Cooldown),
						Alpha          = 1,
						ReverseCooldown = iconOptions.ReverseCooldown,
						FontScale      = db.FontScale,
						ChargeText     = tostring(cd.MaxCharges - usedCount),
					}
				end
			end
		elseif now < cd.StartTime + cd.Cooldown then
			local texture = cd.SpellId and not disabledSpells[cd.SpellId] and GetSpellIcon(cd.SpellId)
			if texture then
				slots[#slots + 1] = {
					Texture = texture,
					SpellId = showTooltips and cd.SpellId or nil,
					DurationObject = wowEx:CreateDuration(cd.StartTime, cd.Cooldown),
					Alpha = 1,
					ReverseCooldown = iconOptions.ReverseCooldown,
					FontScale = db.FontScale,
				}
			end
		else
			entry.ActiveCooldowns[cdKey] = nil
		end
	end

	local usedCount = math.min(#slots, container.Count)
	for i = 1, usedCount do
		container:SetSlot(i, slots[i])
	end
	for i = usedCount + 1, container.Count do
		container:SetSlotUnused(i)
	end
end

---Positions an entry's container in Linear display mode.
---arena1 uses the saved drag position; arena2/3 stack below the previous entry's frame.
---Skips re-anchoring if the anchor parameters haven't changed since the last call.
---@param entry EcdWatchEntry
---@param index number  1=arena1, 2=arena2, 3=arena3
---@param prevEntry EcdWatchEntry?  the entry above this one in the stack (nil for arena1)
local function AnchorContainerLinear(entry, index, prevEntry)
	local options = GetOptions()
	if not options then
		return
	end

	local entrySpacing = tonumber(options.EntrySpacing) or 4

	local frame = entry.Container.Frame
	frame:ClearAllPoints()
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(100)
	frame:SetAlpha(1)

	if index == 1 or not prevEntry then
		local relTo = _G[options.Linear.RelativeTo] or UIParent
		frame:SetPoint(
			options.Linear.Point or "CENTER",
			relTo,
			options.Linear.RelativePoint or "CENTER",
			options.Linear.X or 0,
			options.Linear.Y or 200
		)
	else
		frame:SetPoint("TOP", prevEntry.Container.Frame, "BOTTOM", 0, -entrySpacing)
	end

end

---Positions an entry's container anchored to its corresponding enemy arena frame.
---Skips re-anchoring if the anchor parameters haven't changed since the last call.
---@param entry EcdWatchEntry
---@param index number  1=arena1, 2=arena2, 3=arena3
local function AnchorContainerArenaFrames(entry, index)
	local options = GetOptions()
	if not options then
		return
	end

	local arenaFrame = GetArenaEnemyFrame(index)
	if not arenaFrame then
		return
	end

	local grow = options.ArenaFrames.Grow or "LEFT"
	local xOff = options.ArenaFrames.Offset and options.ArenaFrames.Offset.X or 0
	local yOff = options.ArenaFrames.Offset and options.ArenaFrames.Offset.Y or 0

	local frame = entry.Container.Frame
	frame:ClearAllPoints()

	local strata = arenaFrame:GetFrameStrata()
	frame:SetFrameStrata(strata)
	frame:SetFrameLevel(arenaFrame:GetFrameLevel() + 10)
	frame:SetAlpha(1)

	if grow == "LEFT" then
		frame:SetPoint("RIGHT", arenaFrame, "LEFT", xOff, yOff)
	elseif grow == "RIGHT" then
		frame:SetPoint("LEFT", arenaFrame, "RIGHT", xOff, yOff)
	elseif grow == "DOWN" then
		frame:SetPoint("TOP", arenaFrame, "BOTTOM", xOff, yOff)
	else
		frame:SetPoint("CENTER", arenaFrame, "CENTER", xOff, yOff)
	end

end

---Must be called once from M:Init before any display functions are used.
function D:Init()
	db = mini:GetSavedVars()
end

---@param active boolean
function D:SetTestMode(active)
	testModeActive = active
end

---@param entry EcdWatchEntry
function D:UpdateDisplay(entry)
	UpdateDisplay(entry)
end

---Populates the arena1 container with combined cooldowns from all watch entries.
---Used in Linear mode so all enemies' cooldowns appear in one row.
---@param entries table<string, EcdWatchEntry>
function D:UpdateLinearDisplay(entries)
	local options = GetOptions()
	if not options then
		return
	end

	local entry1 = entries["arena1"]
	if not entry1 then
		return
	end

	-- In test mode, just show the standard test icons in the single container.
	if testModeActive then
		UpdateDisplay(entry1)
		return
	end

	local container = entry1.Container
	local showTooltips = options.ShowTooltips
	local iconOptions = options.Icons

	local slots = slotsScratch
	for i = 1, #slots do
		slots[i] = nil
	end

	local now = GetTime()
	local disabledSpells = options.DisabledSpells or {}

	for _, entry in pairs(entries) do
		for cdKey, cd in pairs(entry.ActiveCooldowns) do
			if cd.UsedCharges then
				local usedCount = #cd.UsedCharges
				if usedCount > 0 then
					local texture = cd.SpellId and not disabledSpells[cd.SpellId] and GetSpellIcon(cd.SpellId)
					if texture then
						local startTime = cd.UsedCharges[1].Expiry - cd.Cooldown
						slots[#slots + 1] = {
							Texture        = texture,
							SpellId        = showTooltips and cd.SpellId or nil,
							DurationObject = wowEx:CreateDuration(startTime, cd.Cooldown),
							Alpha          = 1,
							ReverseCooldown = iconOptions.ReverseCooldown,
							FontScale      = db.FontScale,
							ChargeText     = tostring(cd.MaxCharges - usedCount),
						}
					end
				end
			elseif now < cd.StartTime + cd.Cooldown then
				local texture = cd.SpellId and not disabledSpells[cd.SpellId] and GetSpellIcon(cd.SpellId)
				if texture then
					slots[#slots + 1] = {
						Texture        = texture,
						SpellId        = showTooltips and cd.SpellId or nil,
						DurationObject = wowEx:CreateDuration(cd.StartTime, cd.Cooldown),
						Alpha          = 1,
						ReverseCooldown = iconOptions.ReverseCooldown,
						FontScale      = db.FontScale,
					}
				end
			else
				entry.ActiveCooldowns[cdKey] = nil
			end
		end
	end

	local usedCount = math.min(#slots, container.Count)
	for i = 1, usedCount do
		container:SetSlot(i, slots[i])
	end
	for i = usedCount + 1, container.Count do
		container:SetSlotUnused(i)
	end
end

---@param entry EcdWatchEntry
---@param index number
---@param prevEntry EcdWatchEntry?
function D:AnchorContainer(entry, index, prevEntry)
	local options = GetOptions()
	if not options then
		return
	end

	if options.DisplayMode == "Linear" then
		AnchorContainerLinear(entry, index, prevEntry)
	else
		AnchorContainerArenaFrames(entry, index)
	end
end

---@param index number
---@return table?
function D:GetArenaEnemyFrame(index)
	return GetArenaEnemyFrame(index)
end
