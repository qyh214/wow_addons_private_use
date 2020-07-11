--[[-----------------------------------------------------------------------------
Frame Container
-------------------------------------------------------------------------------]]
local Type, Version = "AcamarFrame", 26
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, assert, type = pairs, assert, type
local wipe = table.wipe

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: CLOSE

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnClick(frame)
	PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
	frame.obj:Hide()
end

local function ButtonSettings_OnClick(frame)
  frame.obj:Fire("OnSettingsClick")
end

local function ButtonPower_OnClick(frame)
  frame.obj:Fire("OnPowerClick")
end

local function Frame_OnShow(frame)
	frame.obj:Fire("OnShow")
end

local function Frame_OnClose(frame)
	frame.obj:Fire("OnClose")
end

local function Frame_OnMouseDown(frame)
	frame:StartMoving()
	AceGUI:ClearFocus()
end

local function Frame_OnMouseUp(frame)
	frame:StopMovingOrSizing()
	local self = frame.obj
	local status = self.status or self.localstatus
	status.width = frame:GetWidth()
	status.height = frame:GetHeight()
	status.top = frame:GetTop()
	status.left = frame:GetLeft()
end

local function Frame_OnEnter(frame)
end

local function Frame_OnLeave(frame)
end

local function Title_OnMouseDown(frame)
	frame:GetParent():StartMoving()
	AceGUI:ClearFocus()
end

local function MoverSizer_OnMouseUp(mover)
	local frame = mover:GetParent()
	frame:StopMovingOrSizing()
	local self = frame.obj
	local status = self.status or self.localstatus
	status.width = frame:GetWidth()
	status.height = frame:GetHeight()
	status.top = frame:GetTop()
	status.left = frame:GetLeft()
end

local function SizerSE_OnMouseDown(frame)
	frame:GetParent():StartSizing("BOTTOMRIGHT")
	AceGUI:ClearFocus()
end

local function SizerS_OnMouseDown(frame)
	frame:GetParent():StartSizing("BOTTOM")
	AceGUI:ClearFocus()
end

local function SizerE_OnMouseDown(frame)
	frame:GetParent():StartSizing("RIGHT")
	AceGUI:ClearFocus()
end

local function StatusBar_OnEnter(frame)
	frame.obj:Fire("OnEnterStatusBar")
end

local function StatusBar_OnLeave(frame)
	frame.obj:Fire("OnLeaveStatusBar")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
  -- Power button status toggle
  ["OnPowerButtonStatus"] = function(self, isactive)
    if isactive then
      self.powerbutton:SetNormalTexture("Interface\\AddOns\\Acamar\\Media\\on")
      self.powerbutton:SetHighlightTexture("Interface\\AddOns\\Acamar\\Media\\on")
      self.powerbutton:SetPushedTexture("Interface\\AddOns\\Acamar\\Media\\on")
    else
      self.powerbutton:SetNormalTexture("Interface\\AddOns\\Acamar\\Media\\off")
      self.powerbutton:SetHighlightTexture("Interface\\AddOns\\Acamar\\Media\\off")
      self.powerbutton:SetPushedTexture("Interface\\AddOns\\Acamar\\Media\\off")
    end
  end,
  
	["OnAcquire"] = function(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("BACKGROUND")
		self:SetTitle()
		self:SetStatusText()
		self:ApplyStatus()
		self:Show()
        self:EnableResize(true)
	end,

	["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end,

	["SetTitle"] = function(self, title)
		self.titletext:SetText(title)
		--self.titlebg:SetWidth((self.titletext:GetWidth() or 0) + 10)
	end,

	["SetStatusText"] = function(self, text)
		--self.statustext:SetText(text)
	end,

	["Hide"] = function(self)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		self.frame:Show()
	end,

	["EnableResize"] = function(self, state)
		local func = state and "Show" or "Hide"
		self.sizer_se[func](self.sizer_se)
		self.sizer_s[func](self.sizer_s)
		self.sizer_e[func](self.sizer_e)
	end,

	-- called to set an external table to store status in
	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end,

	["ApplyStatus"] = function(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 700)
		self:SetHeight(status.height or 500)
		frame:ClearAllPoints()
		if status.top and status.left then
			frame:SetPoint("TOP", UIParent, "BOTTOM", 0, status.top)
			frame:SetPoint("LEFT", UIParent, "LEFT", status.left, 0)
		else
			frame:SetPoint("CENTER")
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local FrameBackdrop = {
	bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
	--edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	tile = false, 
	tileSize = 1, 
	edgeSize = 10, 
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local PaneBackdrop  = {
	bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
	--edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	tile = false, 
	tileSize = 1, 
	edgeSize = 10, 
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local function Constructor()
	local minWidth = 80
	local minHeight = 50

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetBackdrop(FrameBackdrop)
	frame:SetBackdropColor(0, 0, 0, 0.36)
	frame:SetMinResize(minWidth, minHeight)
	--frame:SetToplevel(true)
	frame:SetScript("OnShow", Frame_OnShow)
	frame:SetScript("OnHide", Frame_OnClose)

	frame:SetScript("OnMouseDown", Frame_OnMouseDown)
	frame:SetScript("OnMouseUp", Frame_OnMouseUp)

	--[[
	frame:SetScript("OnEnter", Frame_OnEnter)
	frame:SetScript("OnLeave", Frame_OnLeave)
	]]
	--local closebutton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	local closebutton = CreateFrame("Button", nil, frame)
	closebutton:SetSize(11, 11)
	closebutton:SetPoint("TOPRIGHT", -5, -5)
	closebutton:SetScript("OnClick", Button_OnClick)
	closebutton:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
	closebutton:SetHighlightTexture("Interface\\Buttons\\UI-StopButton")
	closebutton:SetPushedTexture("Interface\\Buttons\\UI-StopButton")

	local settingsbutton = CreateFrame("Button", nil, frame)
	settingsbutton:SetSize(11, 11)
	settingsbutton:SetPoint("TOPLEFT", 5, -5)
	settingsbutton:SetScript("OnClick", ButtonSettings_OnClick)
	--settingsbutton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
	--settingsbutton:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton")
	--settingsbutton:SetPushedTexture("Interface\\Buttons\\UI-OptionsButton")
	settingsbutton:SetNormalTexture("Interface\\AddOns\\Acamar\\Media\\options")
	settingsbutton:SetHighlightTexture("Interface\\AddOns\\Acamar\\Media\\options")
	settingsbutton:SetPushedTexture("Interface\\AddOns\\Acamar\\Media\\options")

	local powerbutton = CreateFrame("Button", nil, frame)
	powerbutton:SetSize(20, 20)
	--powerbutton:SetPoint("TOPLEFT", 15+5, -5)
	powerbutton:SetPoint("CENTER", 0, -5)
	powerbutton:SetScript("OnClick", ButtonPower_OnClick)
	powerbutton:SetNormalTexture("Interface\\AddOns\\Acamar\\Media\\on")
	powerbutton:SetHighlightTexture("Interface\\AddOns\\Acamar\\Media\\on")
	powerbutton:SetPushedTexture("Interface\\AddOns\\Acamar\\Media\\on")

    --closeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    --closeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    --closeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	--closebutton:SetScript("OnClick", Button_OnClick)

	--[[
	local closebutton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	closebutton:SetScript("OnClick", Button_OnClick)
	closebutton:SetPoint("BOTTOMRIGHT", -27, 17)
	closebutton:SetHeight(20)
	closebutton:SetWidth(100)
	closebutton:SetText(CLOSE)

	local statusbg = CreateFrame("Button", nil, frame)
	statusbg:SetPoint("BOTTOMLEFT", 15, 15)
	statusbg:SetPoint("BOTTOMRIGHT", -132, 15)
	statusbg:SetHeight(24)
	statusbg:SetBackdrop(PaneBackdrop)
	statusbg:SetBackdropColor(0.1,0.1,0.1)
	statusbg:SetBackdropBorderColor(0.4,0.4,0.4)
	statusbg:SetScript("OnEnter", StatusBar_OnEnter)
	statusbg:SetScript("OnLeave", StatusBar_OnLeave)

	local statustext = statusbg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	statustext:SetPoint("TOPLEFT", 7, -2)
	statustext:SetPoint("BOTTOMRIGHT", -7, 2)
	statustext:SetHeight(20)
	statustext:SetJustifyH("LEFT")
	statustext:SetText("")

	local titlebg = frame:CreateTexture(nil, "OVERLAY")
	titlebg:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
	titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
	titlebg:SetPoint("TOP", 0, 12)
	titlebg:SetWidth(100)
	titlebg:SetHeight(40)

	local title = CreateFrame("Frame", nil, frame)
	title:EnableMouse(true)
	title:SetScript("OnMouseDown", Title_OnMouseDown)
	title:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
	title:SetAllPoints(titlebg)

	local titletext = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	titletext:SetPoint("TOP", titlebg, "TOP", 0, -14)

	local titlebg_l = frame:CreateTexture(nil, "OVERLAY")
	titlebg_l:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
	titlebg_l:SetTexCoord(0.21, 0.31, 0, 0.63)
	titlebg_l:SetPoint("RIGHT", titlebg, "LEFT")
	titlebg_l:SetWidth(30)
	titlebg_l:SetHeight(40)

	local titlebg_r = frame:CreateTexture(nil, "OVERLAY")
	titlebg_r:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
	titlebg_r:SetTexCoord(0.67, 0.77, 0, 0.63)
	titlebg_r:SetPoint("LEFT", titlebg, "RIGHT")
	titlebg_r:SetWidth(30)
	titlebg_r:SetHeight(40)
	]]


	local titlebg = frame:CreateTexture(nil, "OVERLAY")
	--titlebg:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
	titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
	titlebg:SetPoint("TOP", 0, 12)
	titlebg:SetWidth(minWidth)
	titlebg:SetHeight(50)

	local title = CreateFrame("Frame", nil, frame)
	title:EnableMouse(true)
	--title:SetBackdrop(FrameBackdrop)
	--title:SetBackdropColor(0.6, 0, 0, 0.6)
	title:SetScript("OnMouseDown", Title_OnMouseDown)
	title:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
	title:SetAllPoints(titlebg)

	local titletext = title:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	titletext:SetPoint("TOP", titlebg, "TOP", 0, -14)

	title:SetHeight(titletext:GetStringHeight())
	title:SetWidth(frame:GetWidth())


	local sizer_se = CreateFrame("Frame", nil, frame)
	sizer_se:SetPoint("BOTTOMRIGHT")
	sizer_se:SetWidth(25)
	sizer_se:SetHeight(25)
	sizer_se:EnableMouse()
	sizer_se:SetScript("OnMouseDown",SizerSE_OnMouseDown)
	sizer_se:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

	--[[
	local line1 = sizer_se:CreateTexture(nil, "BACKGROUND")
	line1:SetWidth(14)
	line1:SetHeight(14)
	line1:SetPoint("BOTTOMRIGHT", -8, 8)
	line1:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	local x = 0.1 * 14/17
	line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

	local line2 = sizer_se:CreateTexture(nil, "BACKGROUND")
	line2:SetWidth(8)
	line2:SetHeight(8)
	line2:SetPoint("BOTTOMRIGHT", -8, 8)
	line2:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	local x = 0.1 * 8/17
	line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)
	]]

	local line1 = sizer_se:CreateTexture(nil, "BACKGROUND")
	line1:SetWidth(8)
	line1:SetHeight(8)
	line1:SetPoint("BOTTOMRIGHT", -2, 2)
	line1:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

	local sizer_s = CreateFrame("Frame", nil, frame)
	sizer_s:SetPoint("BOTTOMRIGHT", -25, 0)
	sizer_s:SetPoint("BOTTOMLEFT")
	sizer_s:SetHeight(25)
	sizer_s:EnableMouse(true)
	sizer_s:SetScript("OnMouseDown", SizerS_OnMouseDown)
	sizer_s:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

	local sizer_e = CreateFrame("Frame", nil, frame)
	sizer_e:SetPoint("BOTTOMRIGHT", 0, 25)
	sizer_e:SetPoint("TOPRIGHT")
	sizer_e:SetWidth(25)
	sizer_e:EnableMouse(true)
	sizer_e:SetScript("OnMouseDown", SizerE_OnMouseDown)
	sizer_e:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

	--Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 5, -15)
	content:SetPoint("BOTTOMRIGHT", -5, 5)
	content:SetScript("OnMouseDown", Title_OnMouseDown)
	content:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

	local widget = {
		localstatus = {},
    	powerbutton = powerbutton,
    	title 		= title,
		titletext   = titletext,
		statustext  = statustext,
		titlebg     = titlebg,
		sizer_se    = sizer_se,
		sizer_s     = sizer_s,
		sizer_e     = sizer_e,
		content     = content,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	closebutton.obj, settingsbutton.obj, powerbutton.obj = widget, widget, widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
