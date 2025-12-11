local env                 = select(2, ...)
local Config              = env.Config

local tinsert             = table.insert
local ipairs              = ipairs

local CallbackRegistry    = env.WPM:Import("wpm_modules/callback-registry")
local UIKit               = env.WPM:Import("wpm_modules/ui-kit")
local Setting_Enum        = env.WPM:Import("@/Setting/Enum")
local Setting_Widgets     = env.WPM:Import("@/Setting/Setting_Widgets")
local Setting_Shared      = env.WPM:Import("@/Setting/Shared")
local Setting_Logic       = env.WPM:Await("@/Setting/Logic")
local Setting_Constructor = env.WPM:New("@/Setting/Constructor")


-- Shared
--------------------------------

Setting_Constructor.Tabs = {}
Setting_Constructor.TabButtons = {}

local SettingFrame = _G[Setting_Shared.FRAME_NAME]
local buildTarget = nil


-- Helper
--------------------------------

local function hasDBKeyValueChanged(frame)
    local lastLocalValue = frame:GetLocalValue()
    frame:PullDBKeyToLocalValue()
    local newValueFromDB = frame:GetLocalValue()

    return (newValueFromDB ~= lastLocalValue)
end

local function resolveValueThatIsFunctionOrValue(value)
    if type(value) == "function" then
        return value()
    end
    return value
end



local WidgetMixin = {}

function WidgetMixin:OnLoad(widgetInfo, root, tab)
    -- Shared across all widgets
    local widgetType          = widgetInfo.widgetType
    local widgetName          = widgetInfo.widgetName or ""
    local widgetDescription   = widgetInfo.widgetDescription
    local widgetTransparent   = widgetInfo.widgetTransparent
    local widgetIndent        = widgetInfo.indent
    local disableWhen         = widgetInfo.disableWhen
    local showWhen            = widgetInfo.showWhen

    self.__children           = {}
    self.__handlerDisableWhen = disableWhen
    self.__handlerShowWhen    = showWhen
    self.__tab                = tab
    self.__widgetType         = widgetType
    self.__isTransparent      = widgetTransparent

    tinsert(root.__children, self)

    CallbackRegistry:Add("Setting.Refresh", function(event, force)
        self:Refresh(force)
    end)

    local isTitle = (widgetType == Setting_Enum.WidgetType.Title)
    local isContainer = (widgetType == Setting_Enum.WidgetType.Container)
    local isWidgetElement = (not isTitle and not isContainer)

    -- Set transparency
    if not isTitle and widgetTransparent then self:SetTransparent(widgetTransparent) end

    -- Element only
    if not isWidgetElement then return end


    -- Element specific attributes
    self.__key            = nil
    self.__currentValue   = nil
    self.__handlerRefresh = nil


    if widgetName or widgetDescription then
        local name = widgetName or ""
        local description = widgetDescription and widgetDescription.description or nil
        local imagePath = widgetDescription and widgetDescription.imagePath or nil
        local imageType = widgetDescription and widgetDescription.imageType or nil
        self:SetInfo(name, description, imagePath, imageType)
    end
    self:SetIndent(widgetIndent or 0)
end

function WidgetMixin:Refresh(force)
    if not self:GetFrameParent():IsVisible() then return end

    -- Change visibility based on value from user-provided `Show When` handler
    if self.__handlerShowWhen then
        local shouldShow = self:__handlerShowWhen()
        if self:IsShown() ~= shouldShow then
            self:SetShown(shouldShow)

            -- Re-RenderElements the tab to update layout after widget visibility has changed
            if self.__tab:IsVisible() then
                self.__tab:_Render()
            end
        end
    end

    -- Disable when handler
    if self.__handlerDisableWhen then
        local shouldEnable = not self:__handlerDisableWhen()

        if self.__interactableWidget then
            if self.__interactableWidget:IsEnabled() ~= shouldEnable then
                self.__interactableWidget:SetEnabled(shouldEnable)
            end
        end
    end

    -- Refresh handler
    if not self.__widgetRefreshHandler then return end
    self.__widgetRefreshHandler(self, force)
end

function WidgetMixin:SetRefreshHandler(handler)
    self.__widgetRefreshHandler = handler
end

function WidgetMixin:GetRefreshHandler()
    return self.__widgetRefreshHandler
end

function WidgetMixin:SetDBKey(key)
    self.__key = key
end

function WidgetMixin:GetDBKey()
    return self.__key
end

function WidgetMixin:SetUserInteractableObject(widget)
    self.__interactableWidget = widget
end

function WidgetMixin:GetUserInteractableObject()
    return self.__interactableWidget
end

function WidgetMixin:PushLocalValueToDBKey()
    if self.__currentValue == nil then return end

    Config.DBGlobal:SetVariable(self.__key, self.__currentValue)
    CallbackRegistry:Trigger("Setting.Refresh")
end

function WidgetMixin:PullDBKeyToLocalValue()
    local dbValue = Config.DBGlobal:GetVariable(self.__key)
    self.__currentValue = dbValue
end

function WidgetMixin:SetLocalValue(value)
    self.__currentValue = value
end

function WidgetMixin:GetLocalValue()
    return self.__currentValue
end


-- Build
--------------------------------

local Build = {}

do -- Tab
    local function TabButton_OnClick(self)
        Setting_Logic:OpenTabByIndex(self.__index)
    end

    function Build.Tab(widgetInfo, parent)
        local name = widgetInfo.widgetName or ""
        local isFooter = widgetInfo.widgetTab_isFooter


        -- Create Widget
        local tab = Setting_Widgets.Tab()
        tab:parent(parent)
        tab:Hide()

        local tabButton = Setting_Widgets.TabButton()
        tabButton:parent(isFooter and SettingFrame.Sidebar.Footer or SettingFrame.Sidebar.Tab)
        tabButton:SetText(name)
        tabButton:HookMouseUp(TabButton_OnClick)
        tabButton.__index = #Setting_Constructor.Tabs + 1


        -- Add to tab list
        tinsert(Setting_Constructor.Tabs, tab)
        tinsert(Setting_Constructor.TabButtons, tabButton)


        -- Variables
        tab.__children = {}


        return tab, tab.Layout
    end
end

do -- Title
    function Build.Title(widgetInfo, parent, root, tab)
        local name = widgetInfo.widgetName or ""
        local titleInfo = widgetInfo.widgetTitle_info

        assert(titleInfo, "Title is required!")

        -- Create Widget
        local widget = Setting_Widgets.Title()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)

        -- Info
        widget:SetInfo(titleInfo.imagePath, titleInfo.text, titleInfo.subtext)

        return widget
    end
end

do -- Container
    function Build.Container(widgetInfo, parent, root, tab)
        local name = widgetInfo.widgetName or ""
        local isNested = widgetInfo.widgetContainer_isNested


        -- Create Widget
        local widget = Setting_Widgets.ContainerWithTitle()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)


        -- Key
        widget.__isNested = isNested

        widget:SetSubcontainer(isNested)
        widget.Title:SetText(name)


        return widget, widget.Content
    end
end

do -- Text
    function Build.Text(widgetInfo, parent, root, tab)
        local name = widgetInfo.widgetName or ""

        -- Create Widget
        local widget = Setting_Widgets.ElementText()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)

        return widget
    end
end

do -- Range
    local function Range_Refresh(self, force)
        if not force and hasDBKeyValueChanged(self) == false then return end

        local value = self:GetLocalValue()
        self:GetRange():SetValue(value)

        local textFormatting = self.__textFormatting
        local textFormattingFunc = self.__textFormattingFunc
        local min = self.__min
        local max = self.__max
        local step = self.__step
        local text = tostring(value)

        -- Format text with provided text formatting method or string.format
        if textFormattingFunc then
            text = tostring(textFormattingFunc(value))
        elseif textFormatting then
            text = string.format(textFormatting, tostring(value))
        end

        -- Re-apply min/max/step values if method provided instead of number
        if min and type(min) == "function" and max and type(max) == "function" then
            self:GetRange():SetMinMaxValues(min(), max())
        end

        if step and type(step) == "function" then
            self:GetRange():SetValueStep(step())
        end

        -- Set text
        self.Range:SetText(text)
    end

    local function Range_OnValueChanged(self, value, userInput)
        local widget = self.__widgetRef

        if widget.__lastValue == value then return end
        widget.__lastValue = value

        widget:SetLocalValue(value)
        widget:PushLocalValueToDBKey()
        widget:Refresh(true)

        local setFunc = widget.__setFunc
        if setFunc then
            setFunc(self, value, userInput)
        end
    end

    function Build.Range(widgetInfo, parent, root, tab)
        local name               = widgetInfo.widgetName or ""
        local key                = widgetInfo.key
        local set                = widgetInfo.set

        local min                = widgetInfo.widgetRange_min
        local max                = widgetInfo.widgetRange_max
        local step               = widgetInfo.widgetRange_step
        local textFormatting     = widgetInfo.widgetRange_textFormatting
        local textFormattingFunc = widgetInfo.widgetRange_textFormattingFunc

        assert(min, "Range min is required!")
        assert(max, "Range max is required!")
        assert(step, "Range step is required!")
        assert(key, "Range key is required!")


        -- Create Widget
        local widget = Setting_Widgets.ElementRange()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetRange())

        local range = widget:GetRange()
        range:SetMinMaxValues(resolveValueThatIsFunctionOrValue(min), resolveValueThatIsFunctionOrValue(max))
        range:SetValueStep(resolveValueThatIsFunctionOrValue(step))


        -- Key
        widget:SetDBKey(key)
        widget:PullDBKeyToLocalValue()

        range.__widgetRef = widget
        widget.__setFunc = set
        widget.__textFormatting = textFormatting
        widget.__textFormattingFunc = textFormattingFunc
        widget.__min = min
        widget.__max = max
        widget.__step = step

        range:SetValue(widget:GetLocalValue())
        range:HookEvent("OnValueChanged", Range_OnValueChanged)


        -- Refresh
        widget:SetRefreshHandler(Range_Refresh)


        return widget
    end
end

do -- Button
    local function Button_OnClick(self)
        local setFunc = self.__widgetRef.__setFunc
        if setFunc then
            setFunc(self)
        end

        local refreshOnClick = self.__widgetRef.__refreshOnClick
        if refreshOnClick then
            Setting_Constructor:Refresh()
        end
    end

    function Build.Button(widgetInfo, parent, root, tab)
        local name = widgetInfo.widgetName or ""
        local set = widgetInfo.set

        local buttonText = widgetInfo.widgetButton_text
        local refreshOnClick = widgetInfo.widgetButton_refreshOnClick

        assert(buttonText, "Button text is required!")


        -- Create Widget
        local widget = Setting_Widgets.ElementButton()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetButton())

        local button = widget:GetButton()


        -- Key
        button.__widgetRef = widget
        widget.__setFunc = set
        widget.__refreshOnClick = refreshOnClick

        button:HookMouseUp(Button_OnClick)
        button:SetText(buttonText)

        return widget
    end
end

do -- CheckButton
    local function CheckButton_Refresh(self, force)
        if not force and hasDBKeyValueChanged(self) == false then return end

        local value = self:GetLocalValue()
        self:GetCheckButton():SetChecked(value)
    end

    local function CheckButton_OnCheck(self, value)
        local widget = self.__widgetRef

        if widget.__lastValue == value then return end
        widget.__lastValue = value

        widget:SetLocalValue(value)
        widget:PushLocalValueToDBKey()
        widget:Refresh(true)

        if widget.__setFunc then
            widget.__setFunc(widget, value)
        end
    end

    function Build.CheckButton(widgetInfo, parent, root, tab)
        local name = widgetInfo.widgetName or ""
        local key = widgetInfo.key
        local set = widgetInfo.set


        -- Create Widget
        local widget = Setting_Widgets.ElementCheckButton()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetCheckButton())

        local checkButton = widget:GetCheckButton()


        -- Key
        widget:SetDBKey(key)
        widget:PullDBKeyToLocalValue()

        checkButton.__widgetRef = widget
        widget.__setFunc = set

        checkButton:SetChecked(widget:GetLocalValue())
        checkButton:HookCheck(CheckButton_OnCheck)


        -- Refresh
        widget:SetRefreshHandler(CheckButton_Refresh)


        return widget
    end
end

do -- Selection Menu
    local function SelectionMenu_Refresh(self, force)
        if not force and hasDBKeyValueChanged(self) == false then return end

        local value = self:GetLocalValue()
        self:GetButtonSelectionMenu():SetValue(value)
    end

    local function SelectionMenu_OnValueChanged(self, value)
        local widget = self.__widgetRef

        if widget.__lastValue == value then return end
        widget.__lastValue = value

        widget:SetLocalValue(value)
        widget:PushLocalValueToDBKey()
        widget:Refresh(true)

        local setFunc = widget.__setFunc
        if setFunc then
            setFunc(self, value)
        end
    end

    function Build.SelectionMenu(widgetInfo, parent, root, tab)
        local name              = widgetInfo.widgetName or ""
        local key               = widgetInfo.key
        local set               = widgetInfo.set

        local selectionMenuData = widgetInfo.widgetSelectionMenu_data


        -- Create Widget
        local widget = Setting_Widgets.ElementSelectionMenu()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetButtonSelectionMenu())

        local buttonSelectionMenu = widget:GetButtonSelectionMenu()


        -- Key
        widget:SetDBKey(key)
        widget:PullDBKeyToLocalValue()

        buttonSelectionMenu.__widgetRef = widget
        widget.__setFunc = set

        buttonSelectionMenu:SetSelectionMenu(SettingFrame.SelectionMenu)
        buttonSelectionMenu:SetData(resolveValueThatIsFunctionOrValue(selectionMenuData))
        buttonSelectionMenu:SetValue(widget:GetLocalValue())
        buttonSelectionMenu:HookValueChanged(SelectionMenu_OnValueChanged)


        -- Refresh
        widget:SetRefreshHandler(SelectionMenu_Refresh)


        return widget
    end
end

do -- Color Input
    local function ColorInput_Refresh(self, force)
        if not force and hasDBKeyValueChanged(self) == false then return end

        local value = self:GetLocalValue()
        self:GetColorInput():SetColor(value)
    end

    local function ColorInput_OnColorChange(self, color)
        local widget = self.__widgetRef

        if widget.__lastValue.r == color.r and widget.__lastValue.g == color.g and widget.__lastValue.b == color.b then return end
        widget.__lastValue.r = color.r
        widget.__lastValue.g = color.g
        widget.__lastValue.b = color.b

        widget:SetLocalValue(color)
        widget:PushLocalValueToDBKey()
        widget:Refresh(true)

        local setFunc = widget.__setFunc
        if setFunc then
            setFunc(self, color)
        end
    end

    function Build.ColorInput(widgetInfo, parent, root, tab)
        local name = widgetInfo.widgetName or ""
        local key  = widgetInfo.key
        local set  = widgetInfo.set


        -- Create Widget
        local widget = Setting_Widgets.ElementColorInput()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetColorInput())

        local colorInput = widget:GetColorInput()


        -- Key
        widget:SetDBKey(key)
        widget:PullDBKeyToLocalValue()

        colorInput.__widgetRef = widget
        widget.__setFunc = set
        widget.__lastValue = {
            r = nil,
            g = nil,
            b = nil
        } -- Ensure `__lastValue` is a local copy and not a variable reference. `:HookColorChange()` return value: `color` is a variable reference.

        colorInput:SetColor(widget:GetLocalValue())
        colorInput:HookColorChange(ColorInput_OnColorChange)


        -- Refresh
        widget:SetRefreshHandler(ColorInput_Refresh)


        return widget
    end
end

do -- Input
    local function Input_Refresh(self, force)
        if not force and hasDBKeyValueChanged(self) == false then return end

        local value = self:GetLocalValue()
        if not self:GetInput():HasFocus() then
            self:GetInput():SetText(value)
        end
    end

    local function Input_OnTextChange(self, text, userInput)
        local widget = self.__widgetRef

        if not userInput then return end
        if widget.__lastValue == text then return end
        widget.__lastValue = text

        widget:SetLocalValue(text)
        widget:PushLocalValueToDBKey()
        widget:Refresh(true)

        local setFunc = widget.__setFunc
        if setFunc then
            setFunc(self, text)
        end
    end

    function Build.Input(widgetInfo, parent, root, tab)
        local name                    = widgetInfo.widgetName or ""
        local key                     = widgetInfo.key
        local set                     = widgetInfo.set

        local widgetInput_placeholder = widgetInfo.widgetInput_placeholder


        -- Create Widget
        local widget = Setting_Widgets.ElementInput()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetInput())

        local input = widget:GetInput()


        -- Key
        widget:SetDBKey(key)
        widget:PullDBKeyToLocalValue()

        input.__widgetRef = widget
        widget.__setFunc = set

        if widgetInput_placeholder then input:SetPlaceholder(widgetInput_placeholder) end
        input:SetText(widget:GetLocalValue())
        input:HookEvent("OnTextChanged", Input_OnTextChange)


        -- Refresh
        widget:SetRefreshHandler(Input_Refresh)


        return widget
    end
end


-- Scanning
--------------------------------

local BUILD_MAP = {
    [Setting_Enum.WidgetType.Tab]           = Build.Tab,
    [Setting_Enum.WidgetType.Title]         = Build.Title,
    [Setting_Enum.WidgetType.Container]     = Build.Container,
    [Setting_Enum.WidgetType.Text]          = Build.Text,
    [Setting_Enum.WidgetType.Range]         = Build.Range,
    [Setting_Enum.WidgetType.Button]        = Build.Button,
    [Setting_Enum.WidgetType.CheckButton]   = Build.CheckButton,
    [Setting_Enum.WidgetType.SelectionMenu] = Build.SelectionMenu,
    [Setting_Enum.WidgetType.ColorInput]    = Build.ColorInput,
    [Setting_Enum.WidgetType.Input]         = Build.Input
}

local function buildWidget(info, parent, root, tab)
    local widgetType = info.widgetType
    local buildFunc = BUILD_MAP[widgetType]

    if not buildFunc then return end

    local widget, contentFrame = buildFunc(info, parent, root, tab)
    return widget, contentFrame
end

local function traverseAndBuildWidgetsFromTable(widgetTable, parent, root, currentTab)
    for _, info in ipairs(widgetTable) do
        local isTab = info.widgetType == Setting_Enum.WidgetType.Tab

        -- Build the widget using the appropriate method
        local widget, contentFrame = buildWidget(info, parent, root, currentTab)
        assert(widget, "Failed to build widget!")

        -- If the widget is a Tab, update currentTab for its children
        local nextTab = isTab and widget or currentTab

        -- Recursively build any child widgets
        if info.children then
            traverseAndBuildWidgetsFromTable(info.children, contentFrame or widget, widget, nextTab)
        end
    end
end


-- API
--------------------------------

function Setting_Constructor:SetBuildTargetFrame(frame)
    buildTarget = frame
end

function Setting_Constructor:Build(origin)
    UIKit.BeginBatch()
    traverseAndBuildWidgetsFromTable(origin, buildTarget)
    UIKit.EndBatch()
end

function Setting_Constructor:Refresh(force)
    CallbackRegistry:Trigger("Setting.Refresh", force)
end
