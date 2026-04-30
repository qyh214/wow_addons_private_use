local _, core = ...

local dbIcon = LibStub("LibDBIcon-1.0")

local function OnTooltipShow(tooltip, button)
	local isOwner = tooltip:GetOwner() and tooltip:GetOwner() == button
	if not tooltip.icon and isOwner then
		local size = 48
		local tooltipIcon = CreateFrame("Frame", nil, tooltip)
		tooltipIcon:SetPoint("RIGHT", tooltip, "LEFT", 0, 0)
		tooltipIcon:SetSize(size, size)
		tooltipIcon.icon = tooltipIcon:CreateTexture(nil, "ARTWORK")
		tooltipIcon.icon:SetAllPoints(tooltipIcon)
		tooltipIcon.icon:Show()
		tooltipIcon.icon.Background = tooltipIcon:CreateTexture(nil, "BACKGROUND")
		tooltipIcon.icon.Background:SetAllPoints(tooltipIcon)
		tooltipIcon.icon.Background:Show()
		tooltipIcon.icon.Border = tooltipIcon:CreateTexture(nil, "BORDER")
		tooltipIcon.icon.Border:SetAllPoints(tooltipIcon)
		tooltipIcon.icon.Border:Show()
		tooltipIcon.icon:SetTexture(core:Artwork(MURLOKEXPORT_TITLE))
		tooltip.icon = tooltipIcon
	end

	if tooltip.icon and isOwner then
		tooltip.icon:Show()
	end

	tooltip:AddLine(MURLOKEXPORT_TITLE, 1, 1, 1)
	tooltip:AddLine("Simple addon to display Murlok.io rated Mythic+ or PvP data", 0.4, 0.8, 1, 1)
end

local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function OnEnter(button)
	dbIcon.tooltip:SetOwner(button, "ANCHOR_NONE")
	dbIcon.tooltip:SetPoint(getAnchors(button))
	OnTooltipShow(dbIcon.tooltip, button)
	dbIcon.tooltip:Show()
end

local function OnLeave(button)
	if dbIcon.tooltip.icon then
		dbIcon.tooltip.icon:Hide()
	end
	dbIcon.tooltip:Hide()
end

local function OnClick(self, button)
	if button=="LeftButton" then
		core:Toggle()
	else
		UIMurlokExport:SetShown(false)
		UIMurlokExport.OptionsPanel:Open()
	end
end

local dataObject = LibStub("LibDataBroker-1.1"):NewDataObject(MURLOKEXPORT_TITLE, {
	type = "data source",
	text = MURLOKEXPORT_TITLE,
	icon = core:Artwork(MURLOKEXPORT_TITLE),
	OnClick = OnClick,
	OnEnter = OnEnter,
	OnLeave = OnLeave
})

function core:RegisterMinimapButton()
	dbIcon:Register(MURLOKEXPORT_TITLE, dataObject, MurlokExportConfig)
end

core.dbIcon = dbIcon