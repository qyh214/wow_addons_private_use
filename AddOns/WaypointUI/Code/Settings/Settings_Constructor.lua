local env = select(2, ...)
local Config = env.Config
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local UIKit = env.modules:Import("packages\\ui-kit")
local Settings_Enum = env.modules:Import("@\\Settings\\Enum")
local Settings_Widgets = env.modules:Import("@\\Settings\\Settings_Widgets")
local Settings_Preload = env.modules:Import("@\\Settings\\Preload")
local Setting = env.modules:Await("@\\Settings")
local Settings_Constructor = env.modules:New("@\\Settings\\Constructor")

local tinsert = table.insert
local ipairs = ipairs



Settings_Constructor.Tabs = {}
Settings_Constructor.TabButtons = {}

local SettingFrame = _G[Settings_Preload.FRAME_NAME]
local buildTarget = nil

local function HasDBKeyValueChanged(frame)
    local lastLocalValue = frame:GetLocalValue()
    frame:PullDBKeyToLocalValue()
    local newValueFromDB = frame:GetLocalValue()

    return (newValueFromDB ~= lastLocalValue)
end

local function ResolveValueThatIsFunctionOrValue(value)
    if type(value) == "function" then
        return value()
    end
    return value
end



local WidgetMixin = {}

function WidgetMixin:OnLoad(widgetInfo, root, tab)
    local widgetType = widgetInfo.widgetType
    local widgetName = widgetInfo.widgetName or ""
    local widgetDescription = widgetInfo.widgetDescription
    local widgetTransparent = widgetInfo.widgetTransparent
    local widgetIndent = widgetInfo.indent
    local disableWhen = widgetInfo.disableWhen
    local showWhen = widgetInfo.showWhen

    self.__children = {}
    self.__handlerDisableWhen = disableWhen
    self.__handlerShowWhen = showWhen
    self.__tab = tab
    self.__widgetType = widgetType
    self.__isTransparent = widgetTransparent

    tinsert(root.__children, self)

    CallbackRegistry.Add("Setting.Refresh", function(event, force)
        self:Refresh(force)
    end)

    local isTitle = (widgetType == Settings_Enum.WidgetType.Title)
    local isContainer = (widgetType == Settings_Enum.WidgetType.Container)
    local isWidgetElement = (not isTitle and not isContainer)

    if not isTitle and widgetTransparent then self:SetTransparent(widgetTransparent) end
    if not isWidgetElement then return end

    -- Element-specific attributes
    self.__key = nil
    self.__currentValue = nil
    self.__handlerRefresh = nil

    if widgetName or widgetDescription then
        local name = widgetName or ""
        local description = widgetDescription and widgetDescription.description or nil
        local imagePath = widgetDescription and widgetDescription.imagePath or nil
        local imageType = widgetDescription and widgetDescription.imageType or nil
        self:SetData(name, description, imagePath, imageType)
    end
    self:SetIndent(widgetIndent or 0)
end

function WidgetMixin:Refresh(force)
    if not self:GetFrameParent():IsVisible() then return end

    if self.__handlerShowWhen then
        local shouldShow = self:__handlerShowWhen()
        if self:IsShown() ~= shouldShow then
            self:SetShown(shouldShow)
            if self.__tab:IsVisible() then
                self.__tab:_Render()
            end
        end
    end

    if self.__handlerDisableWhen then
        local shouldEnable = not self:__handlerDisableWhen()
        if self.__interactableWidget then
            if self.__interactableWidget:IsEnabled() ~= shouldEnable then
                self.__interactableWidget:SetEnabled(shouldEnable)
            end
        end
    end

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
    CallbackRegistry.Trigger("Setting.Refresh")
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



local Build = {}

do -- Tab
    local function TabButton_OnClick(self)
        Setting:OpenTabByIndex(self.__index)
    end

    function Build.Tab(widgetInfo, parent)
        local name = widgetInfo.widgetName or ""
        local isFooter = widgetInfo.widgetTab_isFooter

        local tab = Settings_Widgets.Tab()
        tab:parent(parent)
        tab:Hide()

        local tabButton = Settings_Widgets.TabButton()
        tabButton:parent(isFooter and SettingFrame.Sidebar.Footer or SettingFrame.Sidebar.Tab)
        tabButton:SetText(name)
        tabButton:HookMouseUp(TabButton_OnClick)
        tabButton.__index = #Settings_Constructor.Tabs + 1

        tab.__children = {}

        -- Add to tab list
        tinsert(Settings_Constructor.Tabs, tab)
        tinsert(Settings_Constructor.TabButtons, tabButton)

        return tab, tab.Layout
    end
end

do -- Title
    function Build.Title(widgetInfo, parent, root, tab)
        local name = widgetInfo.widgetName or ""
        local titleInfo = widgetInfo.widgetTitle_info

        assert(titleInfo, "Title is required!")

        local widget = Settings_Widgets.Title()
        widget:parent(parent)
        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetData(titleInfo.imagePath, titleInfo.text, titleInfo.subtext)

        return widget
    end
end

do -- Container
    function Build.Container(widgetInfo, parent, root, tab)
        local name = widgetInfo.widgetName or ""
        local isNested = widgetInfo.widgetContainer_isNested

        local widget = Settings_Widgets.ContainerWithTitle()
        widget:parent(parent)
        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)

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
        local widget = Settings_Widgets.ElementText()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)

        return widget
    end
end

do -- Range
    local function Range_Refresh(self, force)
        if not force and HasDBKeyValueChanged(self) == false then return end

        local value = self:GetLocalValue()
        self:GetRange():SetValue(value)

        local textFormatting = self.__textFormatting
        local textFormattingFunc = self.__textFormattingFunc
        local min = self.__min
        local max = self.__max
        local step = self.__step
        local text = tostring(value)

        -- Format text using provided formatter
        if textFormattingFunc then
            text = tostring(textFormattingFunc(value))
        elseif textFormatting then
            text = string.format(textFormatting, tostring(value))
        end

        -- Re-apply dynamic min/max/step values
        if min and type(min) == "function" and max and type(max) == "function" then
            self:GetRange():SetMinMaxValues(min(), max())
        end

        if step and type(step) == "function" then
            self:GetRange():SetValueStep(step())
        end

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
        local name = widgetInfo.widgetName or ""
        local key = widgetInfo.key
        local set = widgetInfo.set

        local min = widgetInfo.widgetRange_min
        local max = widgetInfo.widgetRange_max
        local step = widgetInfo.widgetRange_step
        local textFormatting = widgetInfo.widgetRange_textFormatting
        local textFormattingFunc = widgetInfo.widgetRange_textFormattingFunc

        assert(min, "Range min is required!")
        assert(max, "Range max is required!")
        assert(step, "Range step is required!")
        assert(key, "Range key is required!")


        local widget = Settings_Widgets.ElementRange()
        local range = widget:GetRange()
        widget:parent(parent)
        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetRange())
        range:SetMinMaxValues(ResolveValueThatIsFunctionOrValue(min), ResolveValueThatIsFunctionOrValue(max))
        range:SetValueStep(ResolveValueThatIsFunctionOrValue(step))


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
            Settings_Constructor:Refresh()
        end
    end

    function Build.Button(widgetInfo, parent, root, tab)
        local name = widgetInfo.widgetName or ""
        local set = widgetInfo.set

        local buttonText = widgetInfo.widgetButton_text
        local refreshOnClick = widgetInfo.widgetButton_refreshOnClick

        assert(buttonText, "Button text is required!")


        local widget = Settings_Widgets.ElementButton()
        local button = widget:GetButton()
        widget:parent(parent)
        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetButton())


        button.__widgetRef = widget
        widget.__setFunc = set
        widget.__refreshOnClick = refreshOnClick

        button:HookMouseUp(Button_OnClick)
        button:SetText(buttonText)

        return widget
    end
end

do -- Check Button
    local function CheckButton_Refresh(self, force)
        if not force and HasDBKeyValueChanged(self) == false then return end

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


        local widget = Settings_Widgets.ElementCheckButton()
        local checkButton = widget:GetCheckButton()
        widget:parent(parent)

        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetCheckButton())


        widget:SetDBKey(key)
        widget:PullDBKeyToLocalValue()

        checkButton.__widgetRef = widget
        widget.__setFunc = set

        checkButton:SetChecked(widget:GetLocalValue())
        checkButton:HookCheck(CheckButton_OnCheck)
        widget:SetRefreshHandler(CheckButton_Refresh)

        return widget
    end
end

do -- Selection Menu
    local function SelectionMenu_Refresh(self, force)
        if not force and HasDBKeyValueChanged(self) == false then return end

        local value = self:GetLocalValue()

        if self.__selectionMenuGetFunc then
            value = self.__selectionMenuGetFunc(value)
        end

        self:GetSelectionMenuButton():SetValue(value)
    end

    local function SelectionMenu_OnValueChanged(self, value)
        local widget = self.__widgetRef

        if widget.__selectionMenuSetFunc then
            value = widget.__selectionMenuSetFunc(value)
        end

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
        local name = widgetInfo.widgetName or ""
        local key = widgetInfo.key
        local set = widgetInfo.set
        local selectionMenuGet = widgetInfo.widgetSelectionMenu_get
        local selectionMenuSet = widgetInfo.widgetSelectionMenu_set
        local selectionMenuData = widgetInfo.widgetSelectionMenu_data


        local widget = Settings_Widgets.ElementSelectionMenu()
        local selectionMenuButton = widget:GetSelectionMenuButton()
        widget:parent(parent)
        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetSelectionMenuButton())


        widget:SetDBKey(key)
        widget:PullDBKeyToLocalValue()

        selectionMenuButton.__widgetRef = widget
        widget.__setFunc = set
        widget.__selectionMenuGetFunc = selectionMenuGet
        widget.__selectionMenuSetFunc = selectionMenuSet

        selectionMenuButton:SetSelectionMenu(SettingFrame.SelectionMenu)
        selectionMenuButton:SetData(ResolveValueThatIsFunctionOrValue(selectionMenuData))
        selectionMenuButton:HookValueChanged(SelectionMenu_OnValueChanged)
        widget:SetRefreshHandler(SelectionMenu_Refresh)

        return widget
    end
end

do -- Color Input
    local function ColorInput_Refresh(self, force)
        if not force and HasDBKeyValueChanged(self) == false then return end

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
        local key = widgetInfo.key
        local set = widgetInfo.set


        local widget = Settings_Widgets.ElementColorInput()
        local colorInput = widget:GetColorInput()
        widget:parent(parent)
        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetColorInput())


        widget:SetDBKey(key)
        widget:PullDBKeyToLocalValue()

        colorInput.__widgetRef = widget
        widget.__setFunc = set
        widget.__lastValue = {
            r = nil,
            g = nil,
            b = nil
        } -- Use local copy to avoid reference issues from HookColorChange

        colorInput:SetColor(widget:GetLocalValue())
        colorInput:HookColorChange(ColorInput_OnColorChange)
        widget:SetRefreshHandler(ColorInput_Refresh)

        return widget
    end
end

do -- Input
    local function Input_Refresh(self, force)
        if not force and HasDBKeyValueChanged(self) == false then return end

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
        local name = widgetInfo.widgetName or ""
        local key = widgetInfo.key
        local set = widgetInfo.set

        local widgetInput_placeholder = widgetInfo.widgetInput_placeholder


        local widget = Settings_Widgets.ElementInput()
        local input = widget:GetInput()
        widget:parent(parent)
        Mixin(widget, WidgetMixin)
        widget:OnLoad(widgetInfo, root, tab)
        widget:SetUserInteractableObject(widget:GetInput())


        widget:SetDBKey(key)
        widget:PullDBKeyToLocalValue()

        input.__widgetRef = widget
        widget.__setFunc = set

        if widgetInput_placeholder then input:SetPlaceholder(widgetInput_placeholder) end
        input:SetText(widget:GetLocalValue())
        input:HookEvent("OnTextChanged", Input_OnTextChange)
        widget:SetRefreshHandler(Input_Refresh)

        return widget
    end
end



local BUILD_MAP = {
    [Settings_Enum.WidgetType.Tab]           = Build.Tab,
    [Settings_Enum.WidgetType.Title]         = Build.Title,
    [Settings_Enum.WidgetType.Container]     = Build.Container,
    [Settings_Enum.WidgetType.Text]          = Build.Text,
    [Settings_Enum.WidgetType.Range]         = Build.Range,
    [Settings_Enum.WidgetType.Button]        = Build.Button,
    [Settings_Enum.WidgetType.CheckButton]   = Build.CheckButton,
    [Settings_Enum.WidgetType.SelectionMenu] = Build.SelectionMenu,
    [Settings_Enum.WidgetType.ColorInput]    = Build.ColorInput,
    [Settings_Enum.WidgetType.Input]         = Build.Input
}

local function BuildWidget(info, parent, root, tab)
    local widgetType = info.widgetType
    local buildFunc = BUILD_MAP[widgetType]

    if not buildFunc then return end

    local widget, contentFrame = buildFunc(info, parent, root, tab)
    return widget, contentFrame
end

local function TraverseAndBuildWidgetsFromTable(widgetTable, parent, root, currentTab)
    for _, info in ipairs(widgetTable) do
        local isTab = info.widgetType == Settings_Enum.WidgetType.Tab

        local widget, contentFrame = BuildWidget(info, parent, root, currentTab)
        assert(widget, "Failed to build widget!")

        local nextTab = isTab and widget or currentTab

        if info.children then
            TraverseAndBuildWidgetsFromTable(info.children, contentFrame or widget, widget, nextTab)
        end
    end
end



function Settings_Constructor:SetBuildTargetFrame(frame)
    buildTarget = frame
end

function Settings_Constructor:Build(origin)
    UIKit.BeginBatch()
    TraverseAndBuildWidgetsFromTable(origin, buildTarget)
    UIKit.EndBatch()
end

function Settings_Constructor:Refresh(force)
    CallbackRegistry.Trigger("Setting.Refresh", force)
end
