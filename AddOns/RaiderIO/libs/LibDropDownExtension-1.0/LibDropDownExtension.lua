local MAJOR, MINOR = "LibDropDownExtension-1.0", 3
assert(LibStub, MAJOR .. " requires LibStub")

---@class DropDownList : Button
---@field public dropdown CustomDropDown
---@field public GetID fun(): number
---@field public maxWidth number

---@class LibDropDownExtension
---@field public _callbacks CustomDropDownCallback[]
---@field public _cdropdowns table<DropDownList, CustomDropDown>
---@field public _separatorTable CustomDropDownOption[]
---@field public _hooked table<DropDownList, boolean>
---@field public _Broadcast fun(self: LibDropDownExtension, event: LibDropDownExtensionEvent, dropdown: DropDownList)
---@field public Option table<string, CustomDropDownOption> `LibDropDownExtension.Option.Separator` `LibDropDownExtension.Option.Space`
---@field public RegisterEvent fun(self: LibDropDownExtension, events: string, func: LibDropDownExtensionCallback, levels?: number|boolean, data?: table): boolean `LibDropDownExtension:RegisterEvent(events, func[, levels[, data]])` where func is later called as `func(dropdown, event, options, level, data)` and the return boolean if true will append the options to the dropdown, otherwise false will ignore appending our options to the dropdown.
---@field public UnregisterEvent fun(self: LibDropDownExtension, events: string, func: LibDropDownExtensionCallback, levels?: number|boolean): boolean `LibDropDownExtension:UnregisterEvent(events, func[, levels])`

---@alias LibDropDownExtensionEvent "OnShow"|"OnHide"

---@alias LibDropDownExtensionCallback fun(dropdown: CustomDropDown, event: LibDropDownExtensionEvent, options: CustomDropDownOption[], level: number, data?: table): CustomDropDownOption[]?

---@type LibDropDownExtension?, number?
local Lib, LibPrevMinor = LibStub:NewLibrary(MAJOR, MINOR) ---@diagnostic disable-line: assign-type-mismatch
if not Lib then return end

---@class CustomDropDownOptionIconInfo
---@field public tCoordLeft number
---@field public tCoordRight number
---@field public tCoordTop number
---@field public tCoordBottom number
---@field public tSizeX number
---@field public tSizeY number
---@field public tFitDropDownSizeX boolean
---@field public disablecolor? string

-- copy pasta more or less from UIDropDownMenu.lua about UIDropDownMenu_CreateInfo()
---@class CustomDropDownOption : CustomDropDownOptionIconInfo
---@field public text string @The text of the button
---@field public value any @The value that UIDROPDOWNMENU_MENU_VALUE is set to when the button is clicked
---@field public func fun(button: CustomDropDownButton, arg1: any, arg2: any, checked: boolean) @The function that is called when you click the button. Called as `func(button, option.arg1, option.arg2, option.checkedEval)`
---@field public checked boolean|fun(self: CustomDropDownOption): boolean? @Check the button if true or function returns true
---@field public checkedEval boolean @The final value of the checked state (in case a function and such, use this in your click handler)
---@field public isNotRadio boolean @Check the button uses radial image if false check box image if true
---@field public isTitle boolean @If it's a title the button is disabled and the font color is set to yellow
---@field public disabled boolean @Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
---@field public tooltipWhileDisabled boolean @Show the tooltip, even when the button is disabled.
---@field public hasArrow boolean @Show the expand arrow for multilevel menus
---@field public hasColorSwatch boolean @Show color swatch or not, for color selection
---@field public r number @Red color value of the color swatch [1-255]
---@field public g number @Green color value of the color swatch [1-255]
---@field public b number @Blue color value of the color swatch [1-255]
---@field public colorCode string @"|cAARRGGBB" embedded hex value of the button text color. Only used when button is enabled
---@field public swatchFunc function @Function called by the color picker on color change
---@field public hasOpacity boolean @Show the opacity slider on the colorpicker frame
---@field public opacity number @Percentatge of the opacity, 1.0 is fully shown, 0 is transparent [0.0-1.0]
---@field public opacityFunc function @Function called by the opacity slider when you change its value
---@field public cancelFunc function @Function called by the colorpicker when you click the cancel button (it takes the previous values as its argument)
---@field public notClickable boolean @Disable the button and color the font white
---@field public notCheckable boolean @Shrink the size of the buttons and don't display a check box
---@field public owner table @Dropdown frame that "owns" the current dropdownlist
---@field public keepShownOnClick boolean @Don't hide the dropdownlist after a button is clicked
---@field public tooltipTitle string @Title of the tooltip shown on mouseover
---@field public tooltipText string @Text of the tooltip shown on mouseover
---@field public tooltipOnButton boolean @Show the tooltip attached to the button instead of as a Newbie tooltip.
---@field public noTooltipWhileEnabled boolean
---@field public justifyH string @Justify button text like "LEFT", "CENTER", "RIGHT"
---@field public arg1 any @This is the first argument used by .func
---@field public arg2 any @This is the second argument used by .func
---@field public fontObject table @font object replacement for Normal and Highlight
---@field public menuTable table @This contains an array of info tables to be displayed as a child menu
---@field public noClickSound boolean @Set to 1 to suppress the sound when clicking the button. The sound only plays if .func is set.
---@field public padding number @Number of pixels to pad the text on the right side
---@field public leftPadding number @Number of pixels to pad the button on the left side
---@field public minWidth number @Minimum width for this line
---@field public customFrame table @Allows this button to be a completely custom frame, should inherit from UIDropDownCustomMenuEntryTemplate and override appropriate methods.
---@field public icon string|number @An icon for the button.
---@field public mouseOverIcon string|number @An override icon when a button is moused over.
---@field public dist number
---@field public isUninteractable boolean
---@field public iconOnly boolean
---@field public iconInfo CustomDropDownOptionIconInfo
---@field public customCheckIconAtlas string
---@field public customCheckIconTexture string|number
---@field public customUncheckIconAtlas string
---@field public customUncheckIconTexture string|number
---@field public show? fun()

---@class CustomDropDownCallback
---@field public events table<LibDropDownExtensionEvent, number|boolean>
---@field public func LibDropDownExtensionCallback
---@field public options CustomDropDownOption[]
---@field public data table

Lib._callbacks = Lib._callbacks or {}
local callbacks = Lib._callbacks

---@class CustomDropDownButton : Button
---@field public option CustomDropDownOption
---@field public order number
---@field public invisibleButton Button
---@field public highlight Texture
---@field public normalText FontString
---@field public iconTexture Texture
---@field public expandArrow Button
---@field public check Texture
---@field public uncheck Texture
---@field public colorSwatch Button
---@field public colorSwatchNormalTexture Texture
---@field public mouseOverIcon string?
---@field public tooltipOnButton boolean?
---@field public tooltipTitle string?
---@field public tooltipWhileDisabled boolean?
---@field public tooltipInstruction string?
---@field public tooltipText string?
---@field public tooltipWarning string?
---@field public colorSwatchBg Texture?

---@class CustomDropDown : DropDownList
---@field public options CustomDropDownOption[]
---@field public buttons CustomDropDownButton[]

Lib._cdropdowns = Lib._cdropdowns or {}
local cdropdowns = Lib._cdropdowns

---@param self CustomDropDownButton
local function CustomDropDownButton_OnClick(self)
    local option = self.option
    if not option then
        return
    end
    local cdropdown = self:GetParent()
    ---@diagnostic disable-next-line: assign-type-mismatch
    local checked = option.checked ---@type boolean
    if type(checked) == "function" then
        checked = checked(self)
    end
    if option.keepShownOnClick and not option.notCheckable then
        if checked then
            checked = false
            self.check:Hide()
            self.uncheck:Show()
        else
            checked = true
            self.check:Show()
            self.uncheck:Hide()
        end
    end
    if type(option.checkedEval) ~= "function" then
        option.checkedEval = checked
    end
    if type(option.func) == "function" then
        option.func(self, option.arg1, option.arg2, checked)
    end
    if not option.noClickSound then
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end
    if not option.keepShownOnClick then
        ---@diagnostic disable-next-line: undefined-field
        cdropdown:GetParent():Hide() -- CloseDropDownMenus()
    end
end

---@param self CustomDropDownButton
local function CustomDropDownButton_OnEnter(self)
    local option = self.option
    if not option then
        return
    end
    ---@diagnostic disable-next-line: assign-type-mismatch
    local cdropdown = self:GetParent() ---@type CustomDropDown
    if option.hasArrow then
        -- open next dropdown level and we don't support that
    else
        CloseDropDownMenus(cdropdown:GetID() + 1)
    end
    self.highlight:Show()
    local shownTooltip
    if self.normalText:IsTruncated() then
        if not shownTooltip then
            shownTooltip = true
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip_SetTitle(GameTooltip, self.normalText:GetText())
        else
            GameTooltip:AddLine(self.normalText:GetText(), 1, 1, 1, false)
        end
        GameTooltip:Show()
    end
    if option.tooltipTitle and not option.noTooltipWhileEnabled then
        if option.tooltipOnButton then
            if not shownTooltip then
                shownTooltip = true
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip_SetTitle(GameTooltip, option.tooltipTitle)
            else
                GameTooltip:AddLine(option.tooltipTitle, 1, 1, 1, false)
            end
            if option.tooltipText then
                GameTooltip_AddNormalLine(GameTooltip, option.tooltipText, true)
            end
            GameTooltip:Show()
        end
    end
    if option.mouseOverIcon then
        self.iconTexture:SetTexture(self.mouseOverIcon)
        self.iconTexture:Show()
    end
end

---@param self CustomDropDownButton
local function CustomDropDownButton_OnLeave(self)
    self.highlight:Hide()
    GameTooltip:Hide()
    local option = self.option
    if option.mouseOverIcon then
        if option.icon then
            self.iconTexture:SetTexture(option.icon)
        else
            self.iconTexture:Hide()
        end
    end
end

---@param self CustomDropDownButton
local function CustomDropDownButton_OnEnable(self)
    self.invisibleButton:Hide()
end

---@param self CustomDropDownButton
local function CustomDropDownButton_OnDisable(self)
    self.invisibleButton:Show()
end

local function CustomDropDownButton_InvisibleButton_OnEnter(self)
    local button = self:GetParent() ---@type CustomDropDownButton
    ---@diagnostic disable-next-line: assign-type-mismatch
    local cdropdown = button:GetParent() ---@type CustomDropDown
    CloseDropDownMenus(cdropdown:GetID() + 1)
    if not button.tooltipOnButton or (not button.tooltipTitle and not button.tooltipWhileDisabled) then
        return
    end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, button.tooltipTitle)
    if button.tooltipInstruction then
        GameTooltip_AddInstructionLine(GameTooltip, button.tooltipInstruction)
    end
    if button.tooltipText then
        GameTooltip_AddNormalLine(GameTooltip, button.tooltipText, true)
    end
    if button.tooltipWarning then
        GameTooltip_AddColoredLine(GameTooltip, button.tooltipWarning, RED_FONT_COLOR, true)
    end
    GameTooltip:Show()
end

local function CustomDropDownButton_InvisibleButton_OnLeave(self)
    GameTooltip:Hide()
end

local function CustomDropDownButton_ColorSwatch_OnClick(self)
    local button = self:GetParent() ---@type CustomDropDownButton
    CloseMenus()
    UIDropDownMenuButton_OpenColorPicker(button)
end

local function CustomDropDownButton_ColorSwatch_OnEnter(self)
    local button = self:GetParent() ---@type CustomDropDownButton
    ---@diagnostic disable-next-line: assign-type-mismatch
    local cdropdown = button:GetParent() ---@type CustomDropDown
    CloseDropDownMenus(cdropdown:GetID() + 1)
    button.colorSwatchBg:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end

local function CustomDropDownButton_ColorSwatch_OnLeave(self)
    local button = self:GetParent() ---@type CustomDropDownButton
    button.colorSwatchBg:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end

---@param cdropdown CustomDropDown
---@param button CustomDropDownButton?
---@return CustomDropDownButton button
local function NewCustomDropDownButton(cdropdown, button)
    local index = #cdropdown.buttons + 1
    ---@diagnostic disable-next-line: cast-local-type
    button = button or CreateFrame("Button", cdropdown:GetName() .. "Button" .. index, cdropdown, "UIDropDownMenuButtonTemplate")
    button.order = nil
    button.option = nil
    button:SetID(index)
    button:SetFrameLevel(cdropdown:GetFrameLevel() + 2)
    button:SetScript("OnClick", CustomDropDownButton_OnClick)
    button:SetScript("OnEnter", CustomDropDownButton_OnEnter)
    button:SetScript("OnLeave", CustomDropDownButton_OnLeave)
    button:SetScript("OnEnable", CustomDropDownButton_OnEnable)
    button:SetScript("OnDisable", CustomDropDownButton_OnDisable)
    local buttonName = button:GetName()
    button.invisibleButton = _G[buttonName .. "InvisibleButton"]
    button.invisibleButton:SetScript("OnEnter", CustomDropDownButton_InvisibleButton_OnEnter)
    button.invisibleButton:SetScript("OnLeave", CustomDropDownButton_InvisibleButton_OnLeave)
    button.highlight = _G[buttonName .. "Highlight"]
    button.normalText = _G[buttonName .. "NormalText"]
    button.normalText:ClearAllPoints()
    button.normalText:SetPoint("LEFT")
    button.normalText:SetPoint("RIGHT")
    button.normalText:SetWordWrap(false) ---@diagnostic disable-line: redundant-parameter
    button.normalText:SetNonSpaceWrap(false)
    button.iconTexture = _G[buttonName .. "Icon"]
    button.expandArrow = _G[buttonName .. "ExpandArrow"]
    button.expandArrow:SetScript("OnMouseDown", nil) ---@diagnostic disable-line: param-type-mismatch
    button.expandArrow:SetScript("OnEnter", nil) ---@diagnostic disable-line: param-type-mismatch
    button.check = _G[buttonName .. "Check"]
    button.uncheck = _G[buttonName .. "UnCheck"]
    button.colorSwatch = _G[buttonName .. "ColorSwatch"]
    button.colorSwatchBg = _G[buttonName .. "ColorSwatchSwatchBg"]
    button.colorSwatchNormalTexture = _G[buttonName .. "ColorSwatchNormalTexture"]
    button.colorSwatch:SetScript("OnClick", CustomDropDownButton_ColorSwatch_OnClick)
    button.colorSwatch:SetScript("OnEnter", CustomDropDownButton_ColorSwatch_OnEnter)
    button.colorSwatch:SetScript("OnLeave", CustomDropDownButton_ColorSwatch_OnLeave)
    ---@diagnostic disable-next-line: return-type-mismatch
    return button
end

---@param cdropdown CustomDropDown
local function CustomDropDown_OnShow(cdropdown)
    ---@type DropDownList
    local parent = cdropdown:GetParent() ---@diagnostic disable-line: assign-type-mismatch
    local maxWidth = parent.maxWidth
    local width, height = parent:GetWidth(), 32
    for i = 1, #cdropdown.buttons do
        local button = cdropdown.buttons[i]
        if button:IsShown() then
            button:SetWidth(maxWidth)
            height = height + button:GetHeight()
        end
    end
    cdropdown:SetHeight(height)
end

---@param widget Region
local function Hide(widget)
    widget:SetAlpha(0)
    widget:Hide()
    widget.Show = widget.Hide
end

---@param dropdown DropDownList
local function NewCustomDropDown(dropdown)
    ---@type CustomDropDown
    local cdropdown = CreateFrame("Button", "LibDropDownExtensionCustomDropDown_" .. tostring(dropdown), dropdown, "UIDropDownListTemplate") ---@diagnostic disable-line: assign-type-mismatch
    cdropdown:SetID(dropdown:GetID())
    cdropdown.options = {}
    cdropdown.buttons = {}
    do
        local cdropdownName = cdropdown:GetName()
        Hide(_G[cdropdownName .. "Backdrop"])
        Hide(_G[cdropdownName .. "MenuBackdrop"])
        cdropdown:SetFrameStrata(dropdown:GetFrameStrata())
        cdropdown:SetFrameLevel(dropdown:GetFrameLevel() + 1)
        cdropdown:SetScript("OnClick", nil) ---@diagnostic disable-line: param-type-mismatch
        cdropdown:SetScript("OnUpdate", nil) ---@diagnostic disable-line: param-type-mismatch
        cdropdown:SetScript("OnShow", CustomDropDown_OnShow)
        cdropdown:SetScript("OnHide", nil) ---@diagnostic disable-line: param-type-mismatch
        for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
            ---@type CustomDropDownButton
            local button = _G[cdropdown:GetName() .. "Button" .. i]
            if not button then
                break
            end
            button = NewCustomDropDownButton(cdropdown, button)
            cdropdown.buttons[i] = button
        end
    end
    return cdropdown
end

---@param a CustomDropDownButton
---@param b CustomDropDownButton
local function SortDropDownButtons(a, b)
    return a.order < b.order
end

---@param cdropdown CustomDropDown
local function ClearDropDown(cdropdown)
    for i = 1, #cdropdown.buttons do
        local button = cdropdown.buttons[i]
        button.option = nil
    end
    table.wipe(cdropdown.options)
end

---@param cdropdown CustomDropDown
---@param options CustomDropDownOption[]
---@param orderOffset number
local function AppendDropDown(cdropdown, options, orderOffset)
    ---@type table<CustomDropDownButton, boolean?>
    local available = {}
    for i = 1, #cdropdown.buttons do
        local button = cdropdown.buttons[i]
        if not button.option then
            available[button] = true
        end
    end
    for i = 1, #options do
        local option = options[i]
        ---@type CustomDropDownButton
        local button = next(available)
        if not button then
            button = NewCustomDropDownButton(cdropdown)
            cdropdown.buttons[#cdropdown.buttons + 1] = button
        else
            available[button] = nil
        end
        button.order = orderOffset + i
        button.option = option
        cdropdown.options[#cdropdown.options + 1] = option
    end
end

---@param button CustomDropDownButton
local function RefreshButton(button)
    local option = button.option

    local icon = button.iconTexture
    local invisibleButton = button.invisibleButton

    button:SetDisabledFontObject(GameFontDisableSmallLeft)
    button:Enable()
    invisibleButton:Hide()

    if option.notClickable then
        option.disabled = true
        button:SetDisabledFontObject(GameFontHighlightSmallLeft)
    end

    if option.isTitle then
        option.disabled = true
        button:SetDisabledFontObject(GameFontNormalSmallLeft)
    end

    if option.disabled then
        button:Disable()
        invisibleButton:Show()
        option.colorCode = nil
    end

    if option.disablecolor then
        option.colorCode = option.disablecolor
    end

    if option.text then

        if option.colorCode then
            button:SetText(option.colorCode .. option.text .. "|r")
        else
            button:SetText(option.text)
        end

        if option.icon or option.mouseOverIcon then
            icon:ClearAllPoints()
            icon:SetPoint("RIGHT")
            icon:SetSize(16, 16)
            icon:SetTexture(option.icon or option.mouseOverIcon)
            if option.tCoordLeft then
                icon:SetTexCoord(option.tCoordLeft, option.tCoordRight, option.tCoordTop, option.tCoordBottom)
            else
                icon:SetTexCoord(0, 1, 0, 1)
            end
            icon:Show()
        else
            icon:Hide()
        end

        if option.fontObject then
            button:SetNormalFontObject(option.fontObject)
            button:SetHighlightFontObject(option.fontObject)
        else
            button:SetNormalFontObject(GameFontHighlightSmallLeft)
            button:SetHighlightFontObject(GameFontHighlightSmallLeft)
        end

    else
        button:SetText("")
        icon:Hide()
    end

    if option.iconInfo then
        icon.tFitDropDownSizeX = option.iconInfo.tFitDropDownSizeX
    else
        icon.tFitDropDownSizeX = nil
    end

    if option.iconOnly and option.icon then
        icon:ClearAllPoints()
        icon:SetPoint("LEFT")
        icon:SetWidth(option.iconInfo and option.iconInfo.tSizeX or 16)
        icon:SetHeight(option.iconInfo and option.iconInfo.tSizeY or 16)
        icon:SetTexture(option.icon)
        if option.iconInfo and option.iconInfo.tCoordLeft then
            icon:SetTexCoord(option.iconInfo.tCoordLeft, option.iconInfo.tCoordRight, option.iconInfo.tCoordTop, option.iconInfo.tCoordBottom)
        else
            icon:SetTexCoord(0, 1, 0, 1)
        end
        icon:Show()
    end

    local expandArrow = button.expandArrow
    expandArrow:SetShown(option.hasArrow)
    expandArrow:SetEnabled(not option.disabled)

    if option.iconOnly then
        icon:SetPoint("LEFT")
        icon:SetPoint("RIGHT", -5, 0)
    end

    --[=[
    local xPos = 5
    local displayInfo = button.normalText ---@type FontString|Texture
    if option.iconOnly then
        displayInfo = icon
    end

    displayInfo:ClearAllPoints()

    if option.notCheckable then
        if option.justifyH and option.justifyH == "CENTER" then
            displayInfo:SetPoint("CENTER", button, "CENTER", -7, 0)
        else
            displayInfo:SetPoint("LEFT", button, "LEFT", 0, 0)
        end
        xPos = xPos + 10
    else
        displayInfo:SetPoint("LEFT", button, "LEFT", 20, 0)
        xPos = xPos + 12
    end

    local frame = UIDROPDOWNMENU_OPEN_MENU
	if frame and frame.displayMode == "MENU" then
		if not option.notCheckable then
			xPos = xPos - 6
		end
    end

    frame = frame or UIDROPDOWNMENU_INIT_MENU
    if option.leftPadding then
		xPos = xPos + option.leftPadding
    end

    displayInfo:SetPoint("TOPLEFT", button, "TOPLEFT", xPos, 0)
    --]=]

    if not option.notCheckable then

        local check = button.check
        local uncheck = button.uncheck

        if option.disabled then
            check:SetDesaturated(true)
            check:SetAlpha(0.5)
            uncheck:SetDesaturated(true)
            uncheck:SetAlpha(0.5)
        else
            check:SetDesaturated(false)
            check:SetAlpha(1)
            uncheck:SetDesaturated(false)
            uncheck:SetAlpha(1)
        end

        if option.customCheckIconAtlas or option.customCheckIconTexture then
            check:SetTexCoord(0, 1, 0, 1)
            uncheck:SetTexCoord(0, 1, 0, 1)
            if option.customCheckIconAtlas then
                check:SetAtlas(option.customCheckIconAtlas)
                uncheck:SetAtlas(option.customUncheckIconAtlas or option.customCheckIconAtlas)
            else
                check:SetTexture(option.customCheckIconTexture)
                uncheck:SetTexture(option.customUncheckIconTexture or option.customCheckIconTexture)
            end
        elseif option.isNotRadio then
            check:SetTexCoord(0, 0.5, 0, 0.5)
            check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
            uncheck:SetTexCoord(0.5, 1, 0, 0.5)
            uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
        else
            check:SetTexCoord(0, 0.5, 0.5, 1)
            check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
            uncheck:SetTexCoord(0.5, 1, 0.5, 1)
            uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
        end

        ---@diagnostic disable-next-line: assign-type-mismatch
        local checked = option.checked ---@type boolean
        if type(checked) == "function" then
            checked = checked(button)
        end

        if checked then
            button:LockHighlight()
            check:Show()
            uncheck:Hide()
        else
            button:UnlockHighlight()
            check:Hide()
            uncheck:Show()
        end

    else
        button.check:Hide()
        button.uncheck:Hide()
    end

    local colorSwatch = button.colorSwatch
    if option.hasColorSwatch then
        button.colorSwatchNormalTexture:SetVertexColor(option.r, option.g, option.b)
        colorSwatch:Show()
    else
        colorSwatch:Hide()
    end
end

---@param cdropdown CustomDropDown
local function RefreshButtons(cdropdown)
    local lastButton ---@type CustomDropDownButton?
    for i = 1, #cdropdown.buttons do
        local button = cdropdown.buttons[i]
        if not button.option then
            button.order = 1000000
        end
    end
    table.sort(cdropdown.buttons, SortDropDownButtons)
    for i = 1, #cdropdown.buttons do
        local button = cdropdown.buttons[i]
        if button.option then
            button:ClearAllPoints()
            if lastButton then
                button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0)
            else
                button:SetPoint("TOPLEFT", cdropdown, "TOPLEFT", 15, -17)
            end
            RefreshButton(button)
            button:Show()
            lastButton = button
        else
            button:Hide()
        end
    end
    local numOptions = #cdropdown.options
    if numOptions > 0 then
        ---@diagnostic disable-next-line: assign-type-mismatch
        local parent = cdropdown:GetParent() ---@type Frame
        parent:SetHeight(parent:GetHeight() + 16 * numOptions)
        cdropdown:ClearAllPoints()
        cdropdown:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
        cdropdown:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
        cdropdown:Show()
    else
        cdropdown:Hide()
    end
end

---@param dropdown DropDownList
local function GetCustomDropDown(dropdown)
    local cdropdown = cdropdowns[dropdown]
    if not cdropdown then
        cdropdown = NewCustomDropDown(dropdown)
        cdropdowns[dropdown] = cdropdown
    end
    return cdropdown
end

---@param option CustomDropDownOption
local function IsOptionValid(option)
    return type(option) == "table"
end

---@param options1 CustomDropDownOption[]
---@param options2 CustomDropDownOption[]
local function CopyOptions(options1, options2)
    table.wipe(options2)
    local index = 0
    for i = 1, #options1 do
        local option = options1[i]
        if IsOptionValid(option) then
            index = index + 1
            options2[index] = option
        end
    end
end

---@param options CustomDropDownOption[]
local function RemoveInvalidOptions(options)
    for i = #options, 1, -1 do
        local option = options[i]
        if not IsOptionValid(option) then
            table.remove(options, i)
        end
    end
end

---@param event LibDropDownExtensionEvent
---@param dropdown DropDownList
function Lib:_Broadcast(event, dropdown)
    local level = dropdown:GetID()
    local cdropdown = GetCustomDropDown(dropdown)
    local shownSeparator
    ClearDropDown(cdropdown)
    for i = 1, #callbacks do
        local callback = callbacks[i]
        local callbackLevel = callback.events[event]
        if callbackLevel == true or callbackLevel == level then
            local status, retval = pcall(callback.func, dropdown.dropdown, event, callback.options, level, callback.data)
            if status and retval then
                if not shownSeparator and callback.options[1] then
                    shownSeparator = true
                    AppendDropDown(cdropdown, Lib._separatorTable, 0)
                end
                if type(retval) == "table" and retval ~= callback.options then
                    CopyOptions(retval, callback.options)
                else
                    RemoveInvalidOptions(callback.options)
                end
                AppendDropDown(cdropdown, callback.options, i * 100)
            end
        end
    end
    RefreshButtons(cdropdown)
end

---@param func LibDropDownExtensionCallback
---@return CustomDropDownCallback?, number?
local function GetCallbackForFunc(func)
    for i = 1, #callbacks do
        local callback = callbacks[i]
        if callback.func == func then
            return callback, i
        end
    end
end

---@param self DropDownList
local function DropDown_OnShow(self)
    Lib:_Broadcast("OnShow", self)
end

---@param self DropDownList
local function DropDown_OnHide(self)
    Lib:_Broadcast("OnHide", self)
end

Lib._hooked = Lib._hooked or {}

for i = 1, 3 do
    local dropDownList = _G[format("DropDownList%d", i)] ---@type DropDownList?
    if dropDownList and not Lib._hooked[dropDownList] then
        Lib._hooked[dropDownList] = true
        dropDownList:HookScript("OnShow", DropDown_OnShow)
        dropDownList:HookScript("OnHide", DropDown_OnHide)
    end
end

Lib.Option = Lib.Option or {}

Lib.Option.Separator = Lib.Option.Separator or {
    hasArrow = false,
    dist = 0,
    isTitle = true,
    isUninteractable = true,
    notCheckable = true,
    iconOnly = true,
    icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
    tCoordLeft = 0,
    tCoordRight = 1,
    tCoordTop = 0,
    tCoordBottom = 1,
    tSizeX = 0,
    tSizeY = 8,
    tFitDropDownSizeX = true,
    iconInfo = {
        tCoordLeft = 0,
        tCoordRight = 1,
        tCoordTop = 0,
        tCoordBottom = 1,
        tSizeX = 0,
        tSizeY = 8,
        tFitDropDownSizeX = true
    }
}

Lib.Option.Space = Lib.Option.Space or {
    hasArrow = false,
    dist = 0,
    isTitle = true,
    isUninteractable = true,
    notCheckable = true
}

Lib._separatorTable = Lib._separatorTable or { Lib.Option.Separator }

---@param events string
---@param func LibDropDownExtensionCallback
---@param levels (number|boolean)?
---@param data table?
---@return boolean success
function Lib:RegisterEvent(events, func, levels, data)
    assert(type(events) == "string" and type(func) == "function", "LibDropDownExtension:RegisterEvent(events, func[, levels][, data]) requires events to be a string and func a function. levels is an optional number 1, 2 or nil for any level.")
    local callback = GetCallbackForFunc(func)
    for _, event in ipairs({strsplit(" ", events)}) do
        if not callback then
            ---@type CustomDropDownCallback
            callback = {
                events = {},
                func = func,
                options = {},
                data = type(data) == "table" and data or {},
            }
            callbacks[#callbacks + 1] = callback
        end
        callback.events[event] = levels or true
    end
    return callback ~= nil
end

---@param events string
---@param func LibDropDownExtensionCallback
---@param levels (number|boolean)?
---@return boolean success
function Lib:UnregisterEvent(events, func, levels)
    assert(type(events) == "string" and type(func) == "function", "LibDropDownExtension:UnregisterEvent(events, func) requires events to be a string and func a function.")
    local callback, index = GetCallbackForFunc(func)
    if not callback then
        return false
    end
    for _, event in ipairs({strsplit(" ", events)}) do
        callback.events[event] = levels
    end
    if not next(callback.events) then
        table.remove(callbacks, index)
    end
    return true
end

-- DEBUG:
--[[
print(..., MAJOR, LibPrevMinor, "->", MINOR)
Lib:RegisterEvent("OnShow", function(dropdown, event, options, level, data)
    if event == "OnShow" then
        options[1] = { text = "A1 | Level " .. level .. " | Random " .. data.test .. " | A1", tooltipOnButton = true, tooltipTitle = "Custom Tooltip Title", tooltipText = "Custom Tooltip Text" }
        options[2] = { text = "A2 | Level " .. level .. " | Random " .. data.test .. " | A2" }
        options[3] = { text = "A3 | Level " .. level .. " | Random " .. data.test .. " | A3" }
        return true
    else
        wipe(options)
    end
end, true, { test = random(100000000, 999999999) })
Lib:RegisterEvent("OnShow", function(dropdown, event, options, level, data)
    if event == "OnShow" then
        options[1] = { text = "B1 | Level " .. level .. " | Random " .. data.test .. " | B1" }
        options[2] = { text = "B2 | Level " .. level .. " | Random " .. data.test .. " | B2" }
        options[3] = { text = "B3 | Level " .. level .. " | Random " .. data.test .. " | B3" }
        return true
    else
        wipe(options)
    end
end, true, { test = random(100000000, 999999999) })
Lib:RegisterEvent("OnShow", function(dropdown, event, options, level, data)
    if event == "OnShow" then
        options[1] = { text = "C1 | Level " .. level .. " | Random " .. data.test .. " | C1" }
        options[2] = { text = "C2 | Level " .. level .. " | Random " .. data.test .. " | C2" }
        options[3] = { text = "C3 | Level " .. level .. " | Random " .. data.test .. " | C3" }
        return true
    else
        wipe(options)
    end
end, true, { test = random(100000000, 999999999) })
--]]
