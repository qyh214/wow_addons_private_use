---@type string, Addon
local addonName, addon = ...
local mini = addon.Core.Framework
local array = addon.Utils.Array
local wowEx = addon.Utils.WoWEx
local maxParty = MAX_PARTY_MEMBERS or 4
local maxRaid = MAX_RAID_MEMBERS or 40
local maxTestFrames = 3
local testPartyFrames = {}
local testFramesContainer = nil
---@type Db
local db
local initialised = false
---@class Frames
local M = {}
addon.Core.Frames = M

local function CreateTestFrame(i)
	local frame = CreateFrame("Frame", addonName .. "TestFrame" .. i, UIParent, "BackdropTemplate")
	frame:SetSize(144, 72)

	local _, class = UnitClass("player")
	local colour = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR

	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})

	frame:SetBackdropColor(colour.r, colour.g, colour.b, 0.9)
	frame:SetBackdropBorderColor(0, 0, 0, 1)

	frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.Text:SetPoint("CENTER")
	frame.Text:SetText(("party%d"):format(i))
	frame.Text:SetTextColor(1, 1, 1)

	-- some modules expect this, e.g. trinket module
	frame.unit = "party" .. i
	frame:Hide()

	return frame
end

local function CreateTestFrames()
	testFramesContainer = CreateFrame("Frame", addonName .. "TestContainer")
	testFramesContainer:SetClampedToScreen(true)
	testFramesContainer:EnableMouse(true)
	testFramesContainer:SetMovable(true)
	testFramesContainer:RegisterForDrag("LeftButton")
	testFramesContainer:SetScript("OnDragStart", function(containerSelf)
		containerSelf:StartMoving()
	end)
	testFramesContainer:SetScript("OnDragStop", function(containerSelf)
		containerSelf:StopMovingOrSizing()
	end)
	testFramesContainer:SetPoint("CENTER", UIParent, "CENTER", -450, 0)
	testFramesContainer:Hide()

	local width, height = 144, 72
	local padding = 10

	for i = 1, maxTestFrames do
		local frame = testPartyFrames[i]
		if not frame then
			frame = CreateTestFrame(i)
			testPartyFrames[i] = frame
		end

		frame:ClearAllPoints()
		frame:SetSize(width, height)
		frame:SetPoint("TOP", testFramesContainer, "TOP", 0, (i - 1) * -frame:GetHeight() - padding)
	end

	testFramesContainer:SetSize(width + padding * 2, height * maxTestFrames + padding * 2)
end

---Retrieves a list of Blizzard compact party/raid member frames.
---@param visibleOnly boolean
---@return table
function M:BlizzardFrames(visibleOnly)
	local frames = {}

	-- + 1 for player/self
	for i = 1, maxParty + 1 do
		local frame = _G["CompactPartyFrameMember" .. i]

		if frame and (frame:IsVisible() or not visibleOnly) then
			frames[#frames + 1] = frame
		end
	end

	for i = 1, maxRaid do
		local frame = _G["CompactRaidFrame" .. i]

		if frame and (frame:IsVisible() or not visibleOnly) then
			frames[#frames + 1] = frame
		end
	end

	return frames
end

---Retrieves a list of Blizzard standard (non-compact) party frames.
---@param visibleOnly boolean
---@return table
function M:BlizzardPartyFrames(visibleOnly)
	if not PartyFrame then
		return {}
	end

	local frames = {}

	for i = 1, maxParty + 1 do
		local frame = PartyFrame["MemberFrame" .. i]

		if frame and (frame:IsVisible() or not visibleOnly) then
			frames[#frames + 1] = frame
		end
	end

	return frames
end

---Retrieves a list of visible DandersFrames frames.
---@return table
function M:DandersFrames()
	local frames

	if DandersFrames_GetAllFrames then
		local dandersSuccess, result = pcall(DandersFrames_GetAllFrames)
		if dandersSuccess then
			frames = result
		end
	end

	frames = frames or {}

	return frames
end

---Retrieves a list of Grid2 frames.
---@param visibleOnly boolean
---@return table
function M:Grid2Frames(visibleOnly)
	if not Grid2 or not Grid2.GetUnitFrames then
		return {}
	end

	local frames = {}
	local playerSuccess, playerFrames = pcall(Grid2.GetUnitFrames, Grid2, "player")
	local playerFrame = playerSuccess and playerFrames and next(playerFrames)

	if playerFrame and (playerFrame:IsVisible() or not visibleOnly) then
		frames[#frames + 1] = playerFrame
	end

	for i = 1, maxParty do
		local partySuccess, partyFrames = pcall(Grid2.GetUnitFrames, Grid2, "party" .. i)
		local frame = partySuccess and partyFrames and next(partyFrames)

		if not frame then
			break
		end

		if frame:IsVisible() or not visibleOnly then
			frames[#frames + 1] = frame
		end
	end

	for i = 1, maxRaid do
		local raidSuccess, raidFrames = pcall(Grid2.GetUnitFrames, Grid2, "raid" .. i)
		local frame = raidSuccess and raidFrames and next(raidFrames)

		if frame and (frame:IsVisible() or not visibleOnly) then
			frames[#frames + 1] = frame
		end
	end

	return frames
end

---Retrieves a list of ElvUI frames.
---@param visibleOnly boolean
---@return table
function M:ElvUIFrames(visibleOnly)
	if not ElvUI then
		return {}
	end

	---@diagnostic disable-next-line: deprecated
	local elvuiSuccess, E = pcall(unpack, ElvUI)

	if not elvuiSuccess or not E then
		return {}
	end

	local ufSuccess, UF = pcall(E.GetModule, E, "UnitFrames")

	if not ufSuccess or not UF then
		return {}
	end

	local frames = {}

	for groupName in pairs(UF.headers) do
		local group = UF[groupName]
		if group and group.GetChildren then
			local groupFrames = { group:GetChildren() }

			for _, frame in ipairs(groupFrames) do
				-- is this a unit frame or a subgroup?
				if not frame.Health then
					local children = { frame:GetChildren() }

					for _, child in ipairs(children) do
						if child.unit and (child:IsVisible() or not visibleOnly) then
							frames[#frames + 1] = child
						end
					end
				elseif frame.unit and (frame:IsVisible() or not visibleOnly) then
					frames[#frames + 1] = frame
				end
			end
		end
	end

	return frames
end

---Retrieves a list of Shadowed Unit Frames (SUF) frames.
---@param visibleOnly boolean
---@return table
function M:ShadowedUFFrames(visibleOnly)
	if not SUFUnitplayer and not SUFHeaderpartyUnitButton1 and not SUFHeaderraidUnitButton1 then
		return {}
	end

	local frames = {}

	local function Add(frame)
		if not frame then
			return
		end
		if frame.IsForbidden and frame:IsForbidden() then
			return
		end
		if (not visibleOnly) or frame:IsVisible() then
			frames[#frames + 1] = frame
		end
	end

	-- Party / Raid header buttons (SUFHeaderpartyUnitButton# / SUFHeaderraidUnitButton#) :contentReference[oaicite:2]{index=2}
	for i = 1, maxParty do
		Add(_G["SUFHeaderpartyUnitButton" .. i])

		-- Some layouts/forks also expose party as SUFUnitparty#
		Add(_G["SUFUnitparty" .. i])
	end

	for i = 1, maxRaid do
		Add(_G["SUFHeaderraidUnitButton" .. i])

		-- Some layouts/forks also expose raid as SUFUnitraid#
		Add(_G["SUFUnitraid" .. i])
	end

	return frames
end

---Retrieves a list of Plexus raid/party unit frames from PlexusLayoutHeader frames only.
---@param visibleOnly boolean
---@return table
function M:PlexusFrames(visibleOnly)
	-- Plexus must be loaded
	if not PlexusLayoutHeader1 then
		return {}
	end

	local frames = {}
	local seen = {}

	local function Add(frame)
		if not frame then
			return
		end
		if seen[frame] then
			return
		end
		if frame.IsForbidden and frame:IsForbidden() then
			return
		end
		if visibleOnly and not frame:IsVisible() then
			return
		end

		seen[frame] = true
		frames[#frames + 1] = frame
	end

	local headerIndex = 1

	while true do
		local header = _G["PlexusLayoutHeader" .. headerIndex]
		if not header then
			break
		end

		-- These are secure header children = actual unit buttons
		for _, child in ipairs({ header:GetChildren() }) do
			local unit = child.unit or (child.GetAttribute and child:GetAttribute("unit"))

			if unit and unit ~= "" then
				Add(child)
			end
		end

		headerIndex = headerIndex + 1
	end

	return frames
end

---Retrieves a list of VuhDo unit frames.
---VuhDo panel frames are globals named Vd1, Vd2, … up to 10.
---Unit buttons are direct children; the unit token is in :GetAttribute("unit") or button.raidid.
---@param visibleOnly boolean
---@return table
function M:VuhDoFrames(visibleOnly)
	if not _G["Vd1"] then
		return {}
	end

	local frames = {}
	local seen = {}

	local panelNum = 1
	while true do
		local panel = _G["Vd" .. panelNum]
		if not panel then break end

		for _, child in ipairs({ panel:GetChildren() }) do
			if not seen[child] then
				local unit = (child.GetAttribute and child:GetAttribute("unit")) or child.raidid
				if unit and unit ~= "" then
					if (not child.IsForbidden or not child:IsForbidden()) and (child:IsVisible() or not visibleOnly) then
						seen[child] = true
						frames[#frames + 1] = child
					end
				end
			end
		end

		panelNum = panelNum + 1
	end

	return frames
end

---Retrieves a list of Cell party/raid unit frames.
---@param visibleOnly boolean
---@return table
function M:CellFrames(visibleOnly)
	if not CellPartyFrameHeader and not CellRaidFrameHeader0 then
		return {}
	end

	local frames = {}
	local headers = { CellPartyFrameHeader, CellSoloFrame }

	for i = 0, 8 do
		local header = _G["CellRaidFrameHeader" .. i]
		if header then
			headers[#headers + 1] = header
		end
	end

	for _, header in ipairs(headers) do
		if header then
			for _, child in ipairs({ header:GetChildren() }) do
				local unit = child.unit or (child.GetAttribute and child:GetAttribute("unit"))

				if unit and unit ~= "" then
					if (not child.IsForbidden or not child:IsForbidden()) and (child:IsVisible() or not visibleOnly) then
						frames[#frames + 1] = child
					end
				end
			end
		end
	end

	return frames
end

---Retrieves a list of Cell spotlight unit frames.
---@param visibleOnly boolean
---@return table
function M:CellSpotlightFrames(visibleOnly)
	if not _G["CellSpotlightFrameUnitButton1"] then
		return {}
	end

	local frames = {}

	for i = 1, 15 do
		local frame = _G["CellSpotlightFrameUnitButton" .. i]
		if not frame then
			break
		end
		if not frame.IsForbidden or not frame:IsForbidden() then
			frames[#frames + 1] = frame
		end
	end

	return frames
end

---Retrieves a list of TPerl party unit frames.
---@param visibleOnly boolean
---@return table
function M:TPerlFrames(visibleOnly)
	if not TPerl_Party_SecureHeader then
		return {}
	end

	local frames = {}

	for _, child in ipairs({ TPerl_Party_SecureHeader:GetChildren() }) do
		local unit = child.unit or (child.GetAttribute and child:GetAttribute("unit"))

		if unit and unit ~= "" then
			if (not child.IsForbidden or not child:IsForbidden()) and (child:IsVisible() or not visibleOnly) then
				frames[#frames + 1] = child
			end
		end
	end

	return frames
end

---Retrieves a list of Enhanced QoL party unit frames.
---@param visibleOnly boolean
---@return table
function M:EnhancedQoLFrames(visibleOnly)
	local hasAny = EQOLUFPartyHeader
	for i = 1, 8 do
		if _G["EQOLUFRaidGroupHeader" .. i] then
			hasAny = true
			break
		end
	end

	if not hasAny then
		return {}
	end

	local frames = {}
	local headers = { EQOLUFPartyHeader }

	for i = 1, 8 do
		local header = _G["EQOLUFRaidGroupHeader" .. i]
		if header then
			headers[#headers + 1] = header
		end
	end

	for _, header in ipairs(headers) do
		if header then
			for _, child in ipairs({ header:GetChildren() }) do
				local unit = child.unit or (child.GetAttribute and child:GetAttribute("unit"))

				if unit and unit ~= "" then
					if (not child.IsForbidden or not child:IsForbidden()) and (child:IsVisible() or not visibleOnly) then
						frames[#frames + 1] = child
					end
				end
			end
		end
	end

	return frames
end

---Retrieves a list of BuzzardFrames unit frames.
---@param visibleOnly boolean
---@return table
function M:BuzzardFrames(visibleOnly)
	local BF = _G["BuzzardFrames"]
	if not BF or not BF.GetUnitFrames then
		return {}
	end

	local frames = {}
	local playerSuccess, playerFrames = pcall(BF.GetUnitFrames, BF, "player")
	local playerFrame = playerSuccess and playerFrames and next(playerFrames)

	if playerFrame and (playerFrame:IsVisible() or not visibleOnly) then
		frames[#frames + 1] = playerFrame
	end

	for i = 1, maxParty do
		local partySuccess, partyFrames = pcall(BF.GetUnitFrames, BF, "party" .. i)
		local frame = partySuccess and partyFrames and next(partyFrames)

		if not frame then
			break
		end

		if frame:IsVisible() or not visibleOnly then
			frames[#frames + 1] = frame
		end
	end

	for i = 1, maxRaid do
		local raidSuccess, raidFrames = pcall(BF.GetUnitFrames, BF, "raid" .. i)
		local frame = raidSuccess and raidFrames and next(raidFrames)

		if frame and (frame:IsVisible() or not visibleOnly) then
			frames[#frames + 1] = frame
		end
	end

	return frames
end

---Retrieves a list of NDui unit frames.
---NDui uses oUF. Party/raid frames are spawned as secure headers whose children are the actual unit buttons.
---Boss and arena frames are spawned directly as named globals.
---@param visibleOnly boolean
---@return table
function M:NDuiFrames(visibleOnly)
	if not NDuiDB then
		return {}
	end

	local frames = {}
	local seen = {}

	local function Add(frame)
		if not frame or seen[frame] then return end
		if frame.IsForbidden and frame:IsForbidden() then return end
		if visibleOnly and not frame:IsVisible() then return end
		seen[frame] = true
		frames[#frames + 1] = frame
	end

	local function AddHeader(header)
		if not header then return end
		for _, child in ipairs({ header:GetChildren() }) do
			local unit = child.unit or (child.GetAttribute and child:GetAttribute("unit"))
			if unit and unit ~= "" then
				Add(child)
			end
		end
	end

	-- Party header
	AddHeader(_G["oUF_Party"])

	-- Raid: simple mode uses oUF_Raid; per-group mode uses oUF_Raid1..8
	AddHeader(_G["oUF_Raid"])
	for i = 1, 8 do
		AddHeader(_G["oUF_Raid" .. i])
	end

	return frames
end

---Retrieves a list of GW2 UI unit frames.
---GW2 UI stores all spawned oUF headers in GW.GridHeaders. Each header's direct
---children are either unit buttons (have .unit) or sub-group frames (when groupingOrder
---is set), whose children are the actual unit buttons.
---@param visibleOnly boolean
---@return table
function M:GW2UIFrames(visibleOnly)
	if not GW2_ADDON or not GW2_ADDON.GridHeaders then
		return {}
	end

	local frames = {}
	local seen = {}

	local function Add(frame)
		if not frame or seen[frame] then return end
		if frame.IsForbidden and frame:IsForbidden() then return end
		if visibleOnly and not frame:IsVisible() then return end
		seen[frame] = true
		frames[#frames + 1] = frame
	end

	for _, header in ipairs(GW2_ADDON.GridHeaders) do
		for _, child in ipairs({ header:GetChildren() }) do
			local unit = child.unit or (child.GetAttribute and child:GetAttribute("unit"))
			if unit and unit ~= "" then
				Add(child)
			else
				-- sub-group frame - walk one level deeper
				for _, grandchild in ipairs({ child:GetChildren() }) do
					local gcUnit = grandchild.unit or (grandchild.GetAttribute and grandchild:GetAttribute("unit"))
					if gcUnit and gcUnit ~= "" then
						Add(grandchild)
					end
				end
			end
		end
	end

	return frames
end

---Retrieves a list of MidnightSimpleUnitFrames (MSUF) unit frames.
---MSUF registers all its unit frames (player, target, focus, pet, party1-4,
---raid1-40, boss1-5, arena1-5, etc.) in _G.MSUF_UnitFrames, keyed by unit
---@param visibleOnly boolean
---@return table
function M:MSUFFrames(visibleOnly)
	local registry = _G.MSUF_UnitFrames
	if type(registry) ~= "table" then
		return {}
	end

	local frames = {}

	for _, frame in pairs(registry) do
		if frame
			and (not frame.IsForbidden or not frame:IsForbidden())
			and frame.unit
			and (frame.unit:match("^party%d") or frame.unit:match("^raid%d"))
			and (not visibleOnly or frame:IsVisible())
		then
			frames[#frames + 1] = frame
		end
	end

	return frames
end

---Retrieves a list of custom frames from our saved vars.
---@param visibleOnly boolean
---@return table
function M:CustomFrames(visibleOnly)
	local frames = {}
	local i = 1
	local anchor = db["Anchor" .. i]

	while anchor and anchor ~= "" do
		local frame = _G[anchor]

		if not frame then
			mini:Notify("Bad anchor%d: '%s'.", i, anchor)
		elseif frame:IsVisible() or not visibleOnly then
			frames[#frames + 1] = frame
		end

		i = i + 1
		anchor = db["Anchor" .. i]
	end

	return frames
end

function M:GetTestFrameContainer()
	return testFramesContainer
end

function M:GetTestFrames()
	return testPartyFrames
end

function M:GetAll(visibleOnly, includeTestFrames)
	local anchors = {}
	local elvui = M:ElvUIFrames(visibleOnly)
	local grid2 = M:Grid2Frames(visibleOnly)
	local danders = M:DandersFrames()
	local blizzard = not wowEx:IsDandersEnabled() and M:BlizzardFrames(visibleOnly) or {}
	local blizzardParty = not wowEx:IsDandersEnabled() and M:BlizzardPartyFrames(visibleOnly) or {}
	local suf = M:ShadowedUFFrames(visibleOnly)
	local plexus = M:PlexusFrames(visibleOnly)
	local cell = M:CellFrames(visibleOnly)
	local cellSpotlight = M:CellSpotlightFrames(visibleOnly)
	local vuhdo = M:VuhDoFrames(visibleOnly)
	local tperl = M:TPerlFrames(visibleOnly)
	local eqol = M:EnhancedQoLFrames(visibleOnly)
	local buzzard = M:BuzzardFrames(visibleOnly)
	local ndui = M:NDuiFrames(visibleOnly)
	local gw2ui = M:GW2UIFrames(visibleOnly)
	local msuf = M:MSUFFrames(visibleOnly)
	local custom = M:CustomFrames(visibleOnly)

	array:Append(blizzard, anchors)
	array:Append(blizzardParty, anchors)
	array:Append(elvui, anchors)
	array:Append(grid2, anchors)
	array:Append(danders, anchors)
	array:Append(suf, anchors)
	array:Append(plexus, anchors)
	array:Append(cell, anchors)
	array:Append(cellSpotlight, anchors)
	array:Append(vuhdo, anchors)
	array:Append(tperl, anchors)
	array:Append(eqol, anchors)
	array:Append(buzzard, anchors)
	array:Append(ndui, anchors)
	array:Append(gw2ui, anchors)
	array:Append(msuf, anchors)
	array:Append(custom, anchors)

	if includeTestFrames then
		local testFrames = M:GetTestFrames()
		array:Append(testFrames, anchors)
	end

	return anchors
end

local strataOrder = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }
local strataIndex = {}
for i, v in ipairs(strataOrder) do strataIndex[v] = i end

---Returns the frame strata one level above the given strata, clamped at TOOLTIP.
---@param strata string
---@return string
function M:GetNextStrata(strata)
	return strataOrder[math.min((strataIndex[strata] or 1) + 1, #strataOrder)]
end


---Returns true if the frame is a VuhDo unit button.
---Used to decide whether to bump strata so FCD icons render above VuhDo frame elements.
---@param frame table
---@return boolean
function M:IsVuhDoFrame(frame)
	if not frame or issecretvalue(frame) then
		return false
	end
	if frame:IsForbidden() then
		return false
	end
	local name = frame:GetName()
	return name ~= nil and string.find(name, "^Vd%d+H%d+") ~= nil
end

---Returns true if the frame is a Blizzard compact or standard party frame (not a raid frame).
---Used to decide whether to bump strata so FCD icons render above party frame elements.
---@param frame table
---@return boolean
function M:IsBlizzardPartyFrame(frame)
	if not frame or issecretvalue(frame) then
		return false
	end
	if frame:IsForbidden() then
		return false
	end

	local name = frame:GetName()
	if name and string.find(name, "CompactPartyFrame") ~= nil then
		return true
	end

	if PartyFrame and frame:GetParent() == PartyFrame then
		return true
	end

	return false
end

function M:IsFriendlyCuf(frame)
	if not frame or issecretvalue(frame) then
		return false
	end
	if frame:IsForbidden() then
		return false
	end

	local name = frame:GetName()
	if not name then
		return false
	end

	if string.find(name, "CompactParty") ~= nil or string.find(name, "CompactRaid") ~= nil then
		return true
	end

	-- Standard (non-compact) Blizzard party frames: PartyFrameMemberFrame#
	if PartyFrame and frame:GetParent() == PartyFrame then
		return true
	end

	return false
end

---@param frame table
---@param anchor table
---@param isTest boolean
---@param excludePlayer boolean
function M:ShowHideFrame(frame, anchor, isTest, excludePlayer)
	if anchor:IsForbidden() then
		frame:Hide()
		return
	end

	local unit = frame:GetAttribute("unit") or anchor.unit or anchor:GetAttribute("unit")

	if unit and unit ~= "" then
		if excludePlayer and UnitIsUnit(unit, "player") then
			frame:Hide()
			return
		end
	end

	if anchor:IsVisible() then
		-- technically it can be visible but have an alpha of 0, or even worse a secret alpha of 0
		-- but we're going to assume frame addons are sane and properly hide frames instead of doing that
		frame:SetAlpha(1)
		frame:Show()
	else
		frame:Hide()
	end
end

---Registers a callback via NDui's internal oUF:RegisterInitCallback, called once per frame as NDui spawns it.
---Safe to call even if NDui is not loaded.
---@param callback fun()
function M:HookNDuiVisibility(callback)
	if not NDuiDB then return end

	local ndui = _G["NDui"]
	local ouf = ndui and ndui.oUF
	if ouf and ouf.RegisterInitCallback then
		ouf:RegisterInitCallback(function(frame)
			if frame.unit and frame.unit ~= "" then
				callback()
			end
		end)
	end
end

---Hooks OnShow/OnHide on all 15 Cell spotlight unit buttons, calling callback() on each change.
---Safe to call even if Cell is not loaded (buttons simply won't exist).
---@param callback fun()
function M:HookCellSpotlightVisibility(callback)
	for i = 1, 15 do
		local btn = _G["CellSpotlightFrameUnitButton" .. i]
		if btn then
			btn:HookScript("OnShow", callback)
			btn:HookScript("OnHide", callback)
		end
	end
end

function M:Init()
	if initialised then
		return
	end

	db = mini:GetSavedVars()
	CreateTestFrames()

	initialised = true
end
