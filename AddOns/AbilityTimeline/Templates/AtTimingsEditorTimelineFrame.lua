local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")

local Type = "AtTimingsEditorTimelineFrame"
local Version = 1
local variables = {
	BackdropBorderColor = { 0.25, 0.25, 0.25, 0.9 },
	BackdropColor = { 0, 0, 0, 0.9 },
	FrameHeight = 600,
	FrameWidth = 800,
	Backdrop = {
		bgFile = nil,
		edgeFile = nil,
		tile = true,
		tileSize = 16,
		edgeSize = 1,
	},
	ScrollSize = { width = 9000, height = 600 },
	Padding = { x = 2, y = 2 },
	SpellFrameWidth = 200,
}

---@param self AtTimingsEditorTimelineFrame
local function OnAcquire(self)
end

---@param self AtTimingsEditorTimelineFrame
local function OnRelease(self)
end




local function Constructor()
	local count          = AceGUI:GetNextWidgetNum(Type)

	local frame          = CreateFrame("Frame", Type .. count, UIParent, "BackdropTemplate")

	local horizScrollBar = CreateFrame("EventFrame", nil, frame, "WowTrimHorizontalScrollBar")
	horizScrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT")
	horizScrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT")


	local horizScrollBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
	horizScrollBox:SetAllPoints(frame)

	horizScrollBox.content = CreateFrame("Frame", nil, horizScrollBox, "ResizeLayoutFrame")
	horizScrollBox.content.scrollable = true
	horizScrollBox.content:SetSize(variables.ScrollSize.height, variables.ScrollSize.width)
	horizScrollBox:SetHeight(horizScrollBox.content:GetHeight())

	local horizView = CreateScrollBoxLinearView()
	horizView:SetPanExtent(50)
	horizView:SetHorizontal(true)
	horizScrollBox:SetScript("OnMouseWheel", nil)


	ScrollUtil.InitScrollBoxWithScrollBar(horizScrollBox, horizScrollBar, horizView)

	---@class AtTimingsEditorTimelineFrame : AceGUIWidget
	local widget = {
		OnAcquire = OnAcquire,
		OnRelease = OnRelease,
		FullUpdate = function(self)
			horizScrollBox:FullUpdate()
		end,
		content = horizScrollBox.content,
		frame = frame,
		type = Type,
		count = count,
	}

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
