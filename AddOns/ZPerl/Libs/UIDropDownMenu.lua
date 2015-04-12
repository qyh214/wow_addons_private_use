local gsub = gsub
local issecure = issecure
local max = max
local securecall = securecall
local strmatch = strmatch
local tonumber = tonumber
local type = type

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local GetCVar = GetCVar
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local OpenColorPicker = OpenColorPicker
local PlaySound = PlaySound

LIB_UIDROPDOWNMENU_MINBUTTONS = 8
LIB_UIDROPDOWNMENU_MAXBUTTONS = 8
LIB_UIDROPDOWNMENU_MAXLEVELS = 2
LIB_UIDROPDOWNMENU_BUTTON_HEIGHT = 16
LIB_UIDROPDOWNMENU_BORDER_HEIGHT = 15
LIB_UIDROPDOWNMENU_OPEN_MENU = nil
LIB_UIDROPDOWNMENU_INIT_MENU = nil
LIB_UIDROPDOWNMENU_MENU_LEVEL = 1
LIB_UIDROPDOWNMENU_MENU_VALUE = nil
LIB_UIDROPDOWNMENU_SHOW_TIME = 2
LIB_UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = nil
LIB_OPEN_DROPDOWNMENUS = { }

local _G, wipe = _G, table.wipe

local Lib_UIDropDownMenuDelegate = CreateFrame("Frame")
for i = 1, LIB_UIDROPDOWNMENU_MAXLEVELS do
	local listFrameName = "Lib_DropDownList"..i
	local f = CreateFrame("Button", listFrameName, nil, "Lib_UIDropDownListTemplate")
	f:SetFrameStrata("FULLSCREEN_DIALOG")
	f:SetID(i)
	f:SetSize(180, 10)
	local fontName, fontHeight, fontFlags = _G["Lib_DropDownList1Button1NormalText"]:GetFont()
	LIB_UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = fontHeight
	for j = 1, LIB_UIDROPDOWNMENU_MAXBUTTONS do
		local b = CreateFrame("Button", listFrameName.."Button"..j, f, "Lib_UIDropDownMenuButtonTemplate")
		b:SetID(j)
	end
end

function Lib_UIDropDownMenuDelegate_OnAttributeChanged(self, attribute, value)
	if attribute == "createframes" and value == true then
		Lib_UIDropDownMenu_CreateFrames(self:GetAttribute("createframes-level"), self:GetAttribute("createframes-index"))
	elseif attribute == "initmenu" then
		LIB_UIDROPDOWNMENU_INIT_MENU = value
	elseif attribute == "openmenu" then
		LIB_UIDROPDOWNMENU_OPEN_MENU = value
	end
end

Lib_UIDropDownMenuDelegate:SetScript("OnAttributeChanged", Lib_UIDropDownMenuDelegate_OnAttributeChanged)

function Lib_UIDropDownMenu_InitializeHelper(frame)
	if frame ~= LIB_UIDROPDOWNMENU_OPEN_MENU then
		LIB_UIDROPDOWNMENU_MENU_LEVEL = 1
	end
	Lib_UIDropDownMenuDelegate:SetAttribute("initmenu", frame)
	local button, dropDownList
	for i = 1, LIB_UIDROPDOWNMENU_MAXLEVELS, 1 do
		dropDownList = _G["Lib_DropDownList"..i]
		if i >= LIB_UIDROPDOWNMENU_MENU_LEVEL or frame ~= LIB_UIDROPDOWNMENU_OPEN_MENU then
			dropDownList.numButtons = 0
			dropDownList.maxWidth = 0
			for j = 1, LIB_UIDROPDOWNMENU_MAXBUTTONS, 1 do
				button = _G["Lib_DropDownList"..i.."Button"..j]
				button:Hide()
			end
			dropDownList:Hide()
		end
	end
	frame:SetHeight(LIB_UIDROPDOWNMENU_BUTTON_HEIGHT * 2)
end

function Lib_UIDropDownMenu_Initialize(frame, initFunction, displayMode, level, menuList)
	frame.menuList = menuList
	securecall("Lib_UIDropDownMenu_InitializeHelper", frame)
	if initFunction then
		frame.initialize = initFunction
		initFunction(frame, level, frame.menuList)
	end
	if level == nil then
		level = 1
	end
	_G["Lib_DropDownList"..level].dropdown = frame
	if displayMode == "MENU" then
		local name = frame:GetName()
		_G[name.."Left"]:Hide()
		_G[name.."Middle"]:Hide()
		_G[name.."Right"]:Hide()
		_G[name.."ButtonNormalTexture"]:SetTexture("")
		_G[name.."ButtonDisabledTexture"]:SetTexture("")
		_G[name.."ButtonPushedTexture"]:SetTexture("")
		_G[name.."ButtonHighlightTexture"]:SetTexture("")
		_G[name.."Button"]:ClearAllPoints()
		_G[name.."Button"]:SetPoint("LEFT", name.."Text", "LEFT", -9, 0)
		_G[name.."Button"]:SetPoint("RIGHT", name.."Text", "RIGHT", 6, 0)
		frame.displayMode = "MENU"
	end
end

function Lib_UIDropDownMenu_OnUpdate(self, elapsed)
	if not self.showTimer or not self.isCounting then
		return
	elseif self.showTimer < 0 then
		self:Hide()
		self.showTimer = nil
		self.isCounting = nil
	else
		self.showTimer = self.showTimer - elapsed
	end
end

function Lib_UIDropDownMenu_StartCounting(frame)
	if frame.parent then
		Lib_UIDropDownMenu_StartCounting(frame.parent)
	else
		frame.showTimer = LIB_UIDROPDOWNMENU_SHOW_TIME
		frame.isCounting = 1
	end
end

function Lib_UIDropDownMenu_StopCounting(frame)
	if frame.parent then
		Lib_UIDropDownMenu_StopCounting(frame.parent)
	else
		frame.isCounting = nil
	end
end

local Lib_UIDropDownMenu_ButtonInfo = { }
local Lib_UIDropDownMenu_SecureInfo = { }

function Lib_UIDropDownMenu_CreateInfo()
	if issecure() then
		securecall(wipe, Lib_UIDropDownMenu_SecureInfo)
		return Lib_UIDropDownMenu_SecureInfo
	else
		return wipe(Lib_UIDropDownMenu_ButtonInfo)
	end
end

function Lib_UIDropDownMenu_CreateFrames(level, index)
	while level > LIB_UIDROPDOWNMENU_MAXLEVELS do
		LIB_UIDROPDOWNMENU_MAXLEVELS = LIB_UIDROPDOWNMENU_MAXLEVELS + 1
		local newList = CreateFrame("Button", "Lib_DropDownList"..LIB_UIDROPDOWNMENU_MAXLEVELS, nil, "Lib_UIDropDownListTemplate")
		newList:SetFrameStrata("FULLSCREEN_DIALOG")
		newList:SetToplevel(1)
		newList:Hide()
		newList:SetID(LIB_UIDROPDOWNMENU_MAXLEVELS)
		newList:SetWidth(180)
		newList:SetHeight(10)
		for i = LIB_UIDROPDOWNMENU_MINBUTTONS + 1, LIB_UIDROPDOWNMENU_MAXBUTTONS do
			local newButton = CreateFrame("Button", "Lib_DropDownList"..LIB_UIDROPDOWNMENU_MAXLEVELS.."Button"..i, newList, "Lib_UIDropDownMenuButtonTemplate")
			newButton:SetID(i)
		end
	end
	while index > LIB_UIDROPDOWNMENU_MAXBUTTONS do
		LIB_UIDROPDOWNMENU_MAXBUTTONS = LIB_UIDROPDOWNMENU_MAXBUTTONS + 1
		for i = 1, LIB_UIDROPDOWNMENU_MAXLEVELS do
			local newButton = CreateFrame("Button", "Lib_DropDownList"..i.."Button"..LIB_UIDROPDOWNMENU_MAXBUTTONS, _G["Lib_DropDownList"..i], "Lib_UIDropDownMenuButtonTemplate")
			newButton:SetID(LIB_UIDROPDOWNMENU_MAXBUTTONS)
		end
	end
end

function Lib_UIDropDownMenu_AddButton(info, level)
	-- Might to uncomment this if there are performance issues 
	--[[if not LIB_UIDROPDOWNMENU_OPEN_MENU then
		return
	end]]
	if not level then
		level = 1
	end
	local listFrame = _G["Lib_DropDownList"..level]
	local index = listFrame and (listFrame.numButtons + 1) or 1
	local width
	Lib_UIDropDownMenuDelegate:SetAttribute("createframes-level", level)
	Lib_UIDropDownMenuDelegate:SetAttribute("createframes-index", index)
	Lib_UIDropDownMenuDelegate:SetAttribute("createframes", true)
	listFrame = listFrame or _G["Lib_DropDownList"..level]
	local listFrameName = listFrame:GetName()
	listFrame.numButtons = index
	local button = _G[listFrameName.."Button"..index]
	local normalText = _G[button:GetName().."NormalText"]
	local icon = _G[button:GetName().."Icon"]
	local invisibleButton = _G[button:GetName().."InvisibleButton"]
	button:SetDisabledFontObject(GameFontDisableSmallLeft)
	invisibleButton:Hide()
	button:Enable()
	if info.notClickable then
		info.disabled = 1
		button:SetDisabledFontObject(GameFontHighlightSmallLeft)
	end
	if info.isTitle then
		info.disabled = 1
		button:SetDisabledFontObject(GameFontNormalSmallLeft)
	end
	if info.disabled then
		button:Disable()
		invisibleButton:Show()
		info.colorCode = nil
	end
	if info.disablecolor then
		info.colorCode = info.disablecolor
	end
	if info.text then
		if info.colorCode then
			button:SetText(info.colorCode..info.text.."|r")
		else
			button:SetText(info.text)
		end
		width = normalText:GetWidth() + 40
		if info.hasArrow or info.hasColorSwatch then
			width = width + 10
		end
		if info.notCheckable then
			width = width - 30
		end
		if info.icon then
			icon:SetSize(16,16)
			icon:SetTexture(info.icon)
			icon:ClearAllPoints()
			icon:SetPoint("RIGHT")
			if info.tCoordLeft then
				icon:SetTexCoord(info.tCoordLeft, info.tCoordRight, info.tCoordTop, info.tCoordBottom)
			else
				icon:SetTexCoord(0, 1, 0, 1)
			end
			icon:Show()
			width = width + 10
		else
			icon:Hide()
		end
		if info.padding then
			width = width + info.padding
		end
		width = max(width, info.minWidth or 0)
		if width > listFrame.maxWidth then
			listFrame.maxWidth = width
		end
		if info.fontObject then
			button:SetNormalFontObject(info.fontObject)
			button:SetHighlightFontObject(info.fontObject)
		else
			button:SetNormalFontObject(GameFontHighlightSmallLeft)
			button:SetHighlightFontObject(GameFontHighlightSmallLeft)
		end
	else
		button:SetText("")
		icon:Hide()
	end
	
	button.iconOnly = nil
	button.icon = nil
	button.iconInfo = nil
	if info.iconOnly and info.icon then
		button.iconOnly = true
		button.icon = info.icon
		button.iconInfo = info.iconInfo
		Lib_UIDropDownMenu_SetIconImage(icon, info.icon, info.iconInfo)
		icon:ClearAllPoints()
		icon:SetPoint("LEFT")
		width = icon:GetWidth()
		if info.hasArrow or info.hasColorSwatch then
			width = width + 50 - 30
		end
		if info.notCheckable then
			width = width - 30
		end
		if width > listFrame.maxWidth then
			listFrame.maxWidth = width
		end
	end
	button.func = info.func
	button.owner = info.owner
	button.hasOpacity = info.hasOpacity
	button.opacity = info.opacity
	button.opacityFunc = info.opacityFunc
	button.cancelFunc = info.cancelFunc
	button.swatchFunc = info.swatchFunc
	button.keepShownOnClick = info.keepShownOnClick
	button.tooltipTitle = info.tooltipTitle
	button.tooltipText = info.tooltipText
	button.arg1 = info.arg1
	button.arg2 = info.arg2
	button.hasArrow = info.hasArrow
	button.hasColorSwatch = info.hasColorSwatch
	button.notCheckable = info.notCheckable
	button.menuList = info.menuList
	button.tooltipWhileDisabled = info.tooltipWhileDisabled
	button.tooltipOnButton = info.tooltipOnButton
	button.noClickSound = info.noClickSound
	button.padding = info.padding
	if info.value then
		button.value = info.value
	elseif info.text then
		button.value = info.text
	else
		button.value = nil
	end
	if info.hasArrow then
		_G[listFrameName.."Button"..index.."ExpandArrow"]:Show()
	else
		_G[listFrameName.."Button"..index.."ExpandArrow"]:Hide()
	end
	button.hasArrow = info.hasArrow
	local xPos = 5
	local yPos = - ((button:GetID() - 1) * LIB_UIDROPDOWNMENU_BUTTON_HEIGHT) - LIB_UIDROPDOWNMENU_BORDER_HEIGHT
	local displayInfo = normalText
	if info.iconOnly then
		displayInfo = icon
	end
	displayInfo:ClearAllPoints()
	if info.notCheckable then
		if info.justifyH and info.justifyH == "CENTER" then
			displayInfo:SetPoint("CENTER", button, "CENTER", -7, 0)
		else
			displayInfo:SetPoint("LEFT", button, "LEFT", 0, 0)
		end
		xPos = xPos + 10
	else
		xPos = xPos + 12
		displayInfo:SetPoint("LEFT", button, "LEFT", 20, 0)
	end
	local frame = LIB_UIDROPDOWNMENU_OPEN_MENU
	if frame and frame.displayMode == "MENU" then
		if not info.notCheckable then
			xPos = xPos - 6
		end
	end
	frame = frame or LIB_UIDROPDOWNMENU_INIT_MENU
	if info.leftPadding then
		xPos = xPos + info.leftPadding
	end
	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", xPos, yPos)
	if frame then
		if Lib_UIDropDownMenu_GetSelectedName(frame) then
			if button:GetText() == Lib_UIDropDownMenu_GetSelectedName(frame) then
				info.checked = 1
			end
		elseif Lib_UIDropDownMenu_GetSelectedID(frame) then
			if button:GetID() == Lib_UIDropDownMenu_GetSelectedID(frame) then
				info.checked = 1
			end
		elseif Lib_UIDropDownMenu_GetSelectedValue(frame) then
			if button.value == Lib_UIDropDownMenu_GetSelectedValue(frame) then
				info.checked = 1
			end
		end
	end
	if not info.notCheckable then 
		if info.isNotRadio then
			_G[listFrameName.."Button"..index.."Check"]:SetTexCoord(0.0, 0.5, 0.0, 0.5)
			_G[listFrameName.."Button"..index.."UnCheck"]:SetTexCoord(0.5, 1.0, 0.0, 0.5)
		else
			_G[listFrameName.."Button"..index.."Check"]:SetTexCoord(0.0, 0.5, 0.5, 1.0)
			_G[listFrameName.."Button"..index.."UnCheck"]:SetTexCoord(0.5, 1.0, 0.5, 1.0)
		end
		local checked = info.checked
		if type(checked) == "function" then
			checked = checked(button)
		end
		if checked then
			button:LockHighlight()
			_G[listFrameName.."Button"..index.."Check"]:Show()
			_G[listFrameName.."Button"..index.."UnCheck"]:Hide()
		else
			button:UnlockHighlight()
			_G[listFrameName.."Button"..index.."Check"]:Hide()
			_G[listFrameName.."Button"..index.."UnCheck"]:Show()
		end
	else
		_G[listFrameName.."Button"..index.."Check"]:Hide()
		_G[listFrameName.."Button"..index.."UnCheck"]:Hide()
	end	
	button.checked = info.checked
	local colorSwatch = _G[listFrameName.."Button"..index.."ColorSwatch"]
	if info.hasColorSwatch then
		_G["Lib_DropDownList"..level.."Button"..index.."ColorSwatch".."NormalTexture"]:SetVertexColor(info.r, info.g, info.b)
		button.r = info.r
		button.g = info.g
		button.b = info.b
		colorSwatch:Show()
	else
		colorSwatch:Hide()
	end
	listFrame:SetHeight((index * LIB_UIDROPDOWNMENU_BUTTON_HEIGHT) + (LIB_UIDROPDOWNMENU_BORDER_HEIGHT * 2))
	button:Show()
end

function Lib_UIDropDownMenu_Refresh(frame, useValue, dropdownLevel)
	local button, checked, checkImage, uncheckImage, normalText, width
	local maxWidth = 0
	local somethingChecked = nil 
	if not dropdownLevel then
		dropdownLevel = LIB_UIDROPDOWNMENU_MENU_LEVEL
	end
	local listFrame = _G["Lib_DropDownList"..dropdownLevel]
	listFrame.numButtons = listFrame.numButtons or 0
	for i = 1, LIB_UIDROPDOWNMENU_MAXBUTTONS do
		button = _G["Lib_DropDownList"..dropdownLevel.."Button"..i]
		checked = nil
		if i <= listFrame.numButtons then
			if Lib_UIDropDownMenu_GetSelectedName(frame) then
				if button:GetText() == Lib_UIDropDownMenu_GetSelectedName(frame) then
					checked = 1
				end
			elseif Lib_UIDropDownMenu_GetSelectedID(frame) then
				if button:GetID() == Lib_UIDropDownMenu_GetSelectedID(frame) then
					checked = 1
				end
			elseif Lib_UIDropDownMenu_GetSelectedValue(frame) then
				if button.value == Lib_UIDropDownMenu_GetSelectedValue(frame) then
					checked = 1
				end
			end
		end
		if button.checked and type(button.checked) == "function" then
			checked = button.checked(button)
		end
		if not button.notCheckable and button:IsShown() then	
			checkImage = _G["Lib_DropDownList"..dropdownLevel.."Button"..i.."Check"]
			uncheckImage = _G["Lib_DropDownList"..dropdownLevel.."Button"..i.."UnCheck"]
			if checked then
				somethingChecked = true
				local icon = _G[frame:GetName().."Icon"]
				if button.iconOnly and icon and button.icon then
					Lib_UIDropDownMenu_SetIconImage(icon, button.icon, button.iconInfo)
				elseif useValue then
					Lib_UIDropDownMenu_SetText(frame, button.value)
					icon:Hide()
				else
					Lib_UIDropDownMenu_SetText(frame, button:GetText())
					icon:Hide()
				end
				button:LockHighlight()
				checkImage:Show()
				uncheckImage:Hide()
			else
				button:UnlockHighlight()
				checkImage:Hide()
				uncheckImage:Show()
			end
		end
		if button:IsShown() then
			if button.iconOnly then
				local icon = _G[frame:GetName().."Icon"]
				width = icon:GetWidth()
			else
				normalText = _G[button:GetName().."NormalText"]
				width = normalText:GetWidth() + 40
			end
			if button.hasArrow or button.hasColorSwatch then
				width = width + 10
			end
			if button.notCheckable then
				width = width - 30
			end
			if button.padding then
				width = width + button.padding
			end
			if width > maxWidth then
				maxWidth = width
			end
		end
	end
	if somethingChecked == nil then
		Lib_UIDropDownMenu_SetText(frame, VIDEO_QUALITY_LABEL6)
	end
	if not frame.noResize then
		for i = 1, LIB_UIDROPDOWNMENU_MAXBUTTONS do
			button = _G["Lib_DropDownList"..dropdownLevel.."Button"..i]
			button:SetWidth(maxWidth)
		end
		_G["Lib_DropDownList"..dropdownLevel]:SetWidth(maxWidth + 15)
	end
end

function Lib_UIDropDownMenu_RefreshAll(frame, useValue)
	for dropdownLevel = LIB_UIDROPDOWNMENU_MENU_LEVEL, 2, -1 do
		local listFrame = _G["Lib_DropDownList"..dropdownLevel]
		if listFrame:IsShown() then
			Lib_UIDropDownMenu_Refresh(frame, nil, dropdownLevel)
		end
	end
	Lib_UIDropDownMenu_Refresh(frame, useValue, 1)
end

function Lib_UIDropDownMenu_SetIconImage(icon, texture, info)
	icon:SetTexture(texture)
	if info.tCoordLeft then
		icon:SetTexCoord(info.tCoordLeft, info.tCoordRight, info.tCoordTop, info.tCoordBottom)
	else
		icon:SetTexCoord(0, 1, 0, 1)
	end
	if info.tSizeX then
		icon:SetWidth(info.tSizeX)
	else
		icon:SetWidth(16)
	end
	if info.tSizeY then
		icon:SetHeight(info.tSizeY)
	else
		icon:SetHeight(16)
	end
	icon:Show()
end

function Lib_UIDropDownMenu_SetSelectedName(frame, name, useValue)
	frame.selectedName = name
	frame.selectedID = nil
	frame.selectedValue = nil
	Lib_UIDropDownMenu_Refresh(frame, useValue)
end

function Lib_UIDropDownMenu_SetSelectedValue(frame, value, useValue)
	frame.selectedName = nil
	frame.selectedID = nil
	frame.selectedValue = value
	Lib_UIDropDownMenu_Refresh(frame, useValue)
end

function Lib_UIDropDownMenu_SetSelectedID(frame, id, useValue)
	frame.selectedID = id
	frame.selectedName = nil
	frame.selectedValue = nil
	Lib_UIDropDownMenu_Refresh(frame, useValue)
end

function Lib_UIDropDownMenu_GetSelectedName(frame)
	return frame.selectedName
end

function Lib_UIDropDownMenu_GetSelectedID(frame)
	if frame.selectedID then
		return frame.selectedID
	else
		local button
		for i = 1, LIB_UIDROPDOWNMENU_MAXBUTTONS do
			button = _G["Lib_DropDownList"..LIB_UIDROPDOWNMENU_MENU_LEVEL.."Button"..i]
			if ( Lib_UIDropDownMenu_GetSelectedName(frame) ) then
				if button:GetText() == Lib_UIDropDownMenu_GetSelectedName(frame) then
					return i
				end
			elseif Lib_UIDropDownMenu_GetSelectedValue(frame) then
				if button.value == Lib_UIDropDownMenu_GetSelectedValue(frame) then
					return i
				end
			end
		end
	end
end

function Lib_UIDropDownMenu_GetSelectedValue(frame)
	return frame.selectedValue
end

function Lib_UIDropDownMenuButton_OnClick(self)
	local checked = self.checked
	if type (checked) == "function" then
		checked = checked(self)
	end
	if self.keepShownOnClick then
		if not self.notCheckable then
			if checked then
				_G[self:GetName().."Check"]:Hide()
				_G[self:GetName().."UnCheck"]:Show()
				checked = false
			else
				_G[self:GetName().."Check"]:Show()
				_G[self:GetName().."UnCheck"]:Hide()
				checked = true
			end
		end
	else
		self:GetParent():Hide()
	end
	if type(self.checked) ~= "function" then 
		self.checked = checked
	end
	local playSound = true
	if self.noClickSound then
		playSound = false
	end
	local func = self.func
	if func then
		func(self, self.arg1, self.arg2, checked)
	else
		return
	end
	if playSound then
		PlaySound("UChatScrollButton")
	end
end

function Lib_HideDropDownMenu(level)
	local listFrame = _G["Lib_DropDownList"..level]
	listFrame:Hide()
end

function Lib_ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
	if not level then
		level = 1
	end
	Lib_UIDropDownMenuDelegate:SetAttribute("createframes-level", level)
	Lib_UIDropDownMenuDelegate:SetAttribute("createframes-index", 0)
	Lib_UIDropDownMenuDelegate:SetAttribute("createframes", true)
	LIB_UIDROPDOWNMENU_MENU_LEVEL = level
	LIB_UIDROPDOWNMENU_MENU_VALUE = value
	local listFrame = _G["Lib_DropDownList"..level]
	local listFrameName = "Lib_DropDownList"..level
	local tempFrame
	local point, relativePoint, relativeTo
	if not dropDownFrame then
		tempFrame = button:GetParent()
	else
		tempFrame = dropDownFrame
	end
	if listFrame:IsShown() and (LIB_UIDROPDOWNMENU_OPEN_MENU == tempFrame) then
		listFrame:Hide()
	else
		local uiScale
		local uiParentScale = UIParent:GetScale()
		if GetCVar("useUIScale") == "1" then
			uiScale = tonumber(GetCVar("uiscale"))
			if uiParentScale < uiScale then
				uiScale = uiParentScale
			end
		else
			uiScale = uiParentScale
		end
		listFrame:SetScale(uiScale)
		listFrame:Hide()
		local anchorFrame
		if level == 1 then
			Lib_UIDropDownMenuDelegate:SetAttribute("openmenu", dropDownFrame)
			listFrame:ClearAllPoints()
			if not anchorName then
				if dropDownFrame.xOffset then
					xOffset = dropDownFrame.xOffset
				end
				if dropDownFrame.yOffset then
					yOffset = dropDownFrame.yOffset
				end
				if dropDownFrame.point then
					point = dropDownFrame.point
				end
				if dropDownFrame.relativeTo then
					relativeTo = dropDownFrame.relativeTo
				else
					relativeTo = LIB_UIDROPDOWNMENU_OPEN_MENU:GetName().."Left"
				end
				if dropDownFrame.relativePoint then
					relativePoint = dropDownFrame.relativePoint
				end
			elseif anchorName == "cursor" then
				relativeTo = nil
				local cursorX, cursorY = GetCursorPosition()
				cursorX = cursorX / uiScale
				cursorY = cursorY / uiScale
				if not xOffset then
					xOffset = 0
				end
				if not yOffset then
					yOffset = 0
				end
				xOffset = cursorX + xOffset
				yOffset = cursorY + yOffset
			else
				if dropDownFrame.xOffset then
					xOffset = dropDownFrame.xOffset
				end
				if dropDownFrame.yOffset then
					yOffset = dropDownFrame.yOffset
				end
				if dropDownFrame.point then
					point = dropDownFrame.point
				end
				if dropDownFrame.relativeTo then
					relativeTo = dropDownFrame.relativeTo
				else
					relativeTo = anchorName
				end
				if dropDownFrame.relativePoint then
					relativePoint = dropDownFrame.relativePoint
				end
			end
			if not xOffset or not yOffset then
				xOffset = 8
				yOffset = 22
			end
			if not point then
				point = "TOPLEFT"
			end
			if not relativePoint then
				relativePoint = "BOTTOMLEFT"
			end
			listFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
		else
			if not dropDownFrame then
				dropDownFrame = LIB_UIDROPDOWNMENU_OPEN_MENU
			end
			listFrame:ClearAllPoints()
			local bname = button:GetParent():GetName()
			if bname:match("^Lib_DropDownList%d+$") then
				anchorFrame = button
			else
				anchorFrame = button:GetParent()
			end
			point = "TOPLEFT"
			relativePoint = "TOPRIGHT"
			listFrame:SetPoint(point, anchorFrame, relativePoint, 0, 0)
		end
		if dropDownFrame and dropDownFrame.displayMode == "MENU" then
			_G[listFrameName.."Backdrop"]:Hide()
			_G[listFrameName.."MenuBackdrop"]:Show()
		else
			_G[listFrameName.."Backdrop"]:Show()
			_G[listFrameName.."MenuBackdrop"]:Hide()
		end
		dropDownFrame.menuList = menuList
		Lib_UIDropDownMenu_Initialize(dropDownFrame, dropDownFrame.initialize, nil, level, menuList)
		if listFrame.numButtons == 0 then
			return
		end
		listFrame:Show()
		local x, y = listFrame:GetCenter()
		if not x or not y then
			listFrame:Hide()
			return
		end
		listFrame.onHide = dropDownFrame.onHide
		if level == 1 then
			local offLeft = listFrame:GetLeft() / uiScale
			local offRight = (GetScreenWidth() - listFrame:GetRight()) / uiScale
			local offTop = (GetScreenHeight() - listFrame:GetTop()) / uiScale
			local offBottom = listFrame:GetBottom() / uiScale
			local xAddOffset, yAddOffset = 0, 0
			if offLeft < 0 then
				xAddOffset = - offLeft
			elseif offRight < 0 then
				xAddOffset = offRight
			end
			if offTop < 0 then
				yAddOffset = offTop
			elseif offBottom < 0 then
				yAddOffset = -offBottom
			end
			listFrame:ClearAllPoints()
			if anchorName == "cursor" then
				listFrame:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset)
			else
				listFrame:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset)
			end
		else
			local offscreenY, offscreenX
			if (y - listFrame:GetHeight() / 2) < 0 then
				offscreenY = 1
			end
			if listFrame:GetRight() > GetScreenWidth() then
				offscreenX = 1
			end
			if offscreenY and offscreenX then
				point = gsub(point, "TOP(.*)", "BOTTOM%1")
				point = gsub(point, "(.*)LEFT", "%1RIGHT")
				relativePoint = gsub(relativePoint, "TOP(.*)", "BOTTOM%1")
				relativePoint = gsub(relativePoint, "(.*)RIGHT", "%1LEFT")
				xOffset = -11
				yOffset = -14
			elseif offscreenY then
				point = gsub(point, "TOP(.*)", "BOTTOM%1")
				relativePoint = gsub(relativePoint, "TOP(.*)", "BOTTOM%1")
				xOffset = 0
				yOffset = -14
			elseif offscreenX then
				point = gsub(point, "(.*)LEFT", "%1RIGHT")
				relativePoint = gsub(relativePoint, "(.*)RIGHT", "%1LEFT")
				xOffset = -11
				yOffset = 14
			else
				xOffset = 0
				yOffset = 14
			end
			listFrame:ClearAllPoints()
			listFrame.parentLevel = tonumber(strmatch(anchorFrame:GetName(), "Lib_DropDownList(%d+)"))
			listFrame.parentID = anchorFrame:GetID()
			listFrame:SetPoint(point, anchorFrame, relativePoint, xOffset, yOffset)
		end
		if autoHideDelay and tonumber(autoHideDelay) then
			listFrame.showTimer = autoHideDelay
			listFrame.isCounting = 1
		end
	end
end

function Lib_CloseDropDownMenus(level)
	if not level then
		level = 1
	end
	for i = level, LIB_UIDROPDOWNMENU_MAXLEVELS do
		_G["Lib_DropDownList"..i]:Hide()
	end
end

function Lib_UIDropDownMenu_OnHide(self)
	local id = self:GetID()
	if self.onHide then
		self.onHide(id + 1)
		self.onHide = nil
	end
	Lib_CloseDropDownMenus(id + 1)
	LIB_OPEN_DROPDOWNMENUS[id] = nil
end

function Lib_UIDropDownMenu_SetWidth(frame, width, padding)
	_G[frame:GetName().."Middle"]:SetWidth(width)
	local defaultPadding = 25
	if padding then
		frame:SetWidth(width + padding)
	else
		frame:SetWidth(width + defaultPadding + defaultPadding)
	end
	if padding then
		_G[frame:GetName().."Text"]:SetWidth(width)
	else
		_G[frame:GetName().."Text"]:SetWidth(width - defaultPadding)
	end
	frame.noResize = 1
end

function Lib_UIDropDownMenu_SetButtonWidth(frame, width)
	if width == "TEXT" then
		width = _G[frame:GetName().."Text"]:GetWidth()
	end
	_G[frame:GetName().."Button"]:SetWidth(width)
	frame.noResize = 1
end

function Lib_UIDropDownMenu_SetText(frame, text)
	local filterText = _G[frame:GetName().."Text"]
	filterText:SetText(text)
end

function Lib_UIDropDownMenu_GetText(frame)
	local filterText = _G[frame:GetName().."Text"]
	return filterText:GetText()
end

function Lib_UIDropDownMenu_ClearAll(frame)
	frame.selectedID = nil
	frame.selectedName = nil
	frame.selectedValue = nil
	Lib_UIDropDownMenu_SetText(frame, "")
	local button, checkImage, uncheckImage
	for i = 1, LIB_UIDROPDOWNMENU_MAXBUTTONS do
		button = _G["Lib_DropDownList"..LIB_UIDROPDOWNMENU_MENU_LEVEL.."Button"..i]
		button:UnlockHighlight()
		checkImage = _G["Lib_DropDownList"..LIB_UIDROPDOWNMENU_MENU_LEVEL.."Button"..i.."Check"]
		checkImage:Hide()
		uncheckImage = _G["Lib_DropDownList"..LIB_UIDROPDOWNMENU_MENU_LEVEL.."Button"..i.."UnCheck"]
		uncheckImage:Hide()
	end
end

function Lib_UIDropDownMenu_JustifyText(frame, justification)
	local text = _G[frame:GetName().."Text"]
	text:ClearAllPoints()
	if justification == "LEFT" then
		text:SetPoint("LEFT", frame:GetName().."Left", "LEFT", 27, 2)
		text:SetJustifyH("LEFT")
	elseif justification == "RIGHT" then
		text:SetPoint("RIGHT", frame:GetName().."Right", "RIGHT", -43, 2)
		text:SetJustifyH("RIGHT")
	elseif justification == "CENTER" then
		text:SetPoint("CENTER", frame:GetName().."Middle", "CENTER", -5, 2)
		text:SetJustifyH("CENTER")
	end
end

function Lib_UIDropDownMenu_SetAnchor(dropdown, xOffset, yOffset, point, relativeTo, relativePoint)
	dropdown.xOffset = xOffset
	dropdown.yOffset = yOffset
	dropdown.point = point
	dropdown.relativeTo = relativeTo
	dropdown.relativePoint = relativePoint
end

function Lib_UIDropDownMenu_GetCurrentDropDown()
	if LIB_UIDROPDOWNMENU_OPEN_MENU then
		return LIB_UIDROPDOWNMENU_OPEN_MENU
	elseif LIB_UIDROPDOWNMENU_INIT_MENU then
		return LIB_UIDROPDOWNMENU_INIT_MENU
	end
end

function Lib_UIDropDownMenuButton_GetChecked(self)
	return _G[self:GetName().."Check"]:IsShown()
end

function Lib_UIDropDownMenuButton_GetName(self)
	return _G[self:GetName().."NormalText"]:GetText()
end

function Lib_UIDropDownMenuButton_OpenColorPicker(self, button)
	Lib_CloseDropDownMenus()
	if not button then
		button = self
	end
	LIB_UIDROPDOWNMENU_MENU_VALUE = button.value
	OpenColorPicker(button)
end

function Lib_UIDropDownMenu_DisableButton(level, id)
	_G["Lib_DropDownList"..level.."Button"..id]:Disable()
end

function Lib_UIDropDownMenu_EnableButton(level, id)
	_G["Lib_DropDownList"..level.."Button"..id]:Enable()
end

function Lib_UIDropDownMenu_SetButtonText(level, id, text, colorCode)
	local button = _G["Lib_DropDownList"..level.."Button"..id]
	if colorCode then
		button:SetText(colorCode..text.."|r")
	else
		button:SetText(text)
	end
end

function Lib_UIDropDownMenu_DisableDropDown(dropDown)
	local label = _G[dropDown:GetName().."Label"]
	if label then
		label:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
	_G[dropDown:GetName().."Text"]:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	_G[dropDown:GetName().."Button"]:Disable()
	dropDown.isDisabled = 1
end

function Lib_UIDropDownMenu_EnableDropDown(dropDown)
	local label = _G[dropDown:GetName().."Label"]
	if label then
		label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end
	_G[dropDown:GetName().."Text"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	_G[dropDown:GetName().."Button"]:Enable()
	dropDown.isDisabled = nil
end

function Lib_UIDropDownMenu_IsEnabled(dropDown)
	return not dropDown.isDisabled
end

function Lib_UIDropDownMenu_GetValue(id)
	local button = _G["DropDownList1Button"..id]
	if button then
		return _G["DropDownList1Button"..id].value
	else
		return nil
	end
end