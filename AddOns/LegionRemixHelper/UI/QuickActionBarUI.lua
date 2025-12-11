---@class AddonPrivate
local Private = select(2, ...)

---@class QuickActionBarUI
---@field frame Frame
---@field parent Frame
---@field utils QuickActionBarUtils
---@field defaultPanelInfo {area: string, pushable: number, whileDead: boolean, width: number}?
local quickActionBarUI = {
    frame = nil,
    parent = nil,
    utils = nil,
    defaultPanelInfo = nil,
    editor = {
        ---@type ScrollFrameComponentObject
        scrollFrame = nil,
        ---@type QuickActionObject|nil
        selected = nil,
        ---@type LabelComponentObject
        titlePreview = nil,
        ---@type RoundedIconComponentObject
        iconPreview = nil,
        ---@type TextBoxComponentObject
        titleInput = nil,
        ---@type TextBoxComponentObject
        iconInput = nil,
        ---@type TextBoxComponentObject
        actionIDInput = nil,
        ---@type DropdownComponentObject
        actionTypeDropdown = nil,
        ---@type CheckBoxComponentObject
        checkUsabilityInput = nil,
        ---@type number
        entryID = nil,
    },
    ---@type table<any, string>
    L = nil
}
Private.QuickActionBarUI = quickActionBarUI

local const = Private.constants
local components = Private.Components

function quickActionBarUI:Init(parentTab)
    self.parent = parentTab
    self.utils = Private.QuickActionBarUtils
    self.L = Private.L
end

---@return fun(button:Button|table, elementData:QuickActionObject)
function quickActionBarUI:GetInitializer()
    return function(button, elementData)
        if not button.isInitialized then
            button.icon = button:CreateTexture(nil, "ARTWORK")
            button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            button:RegisterForClicks("AnyUp", "AnyDown")

            button:SetScript("OnSizeChanged", function(btn)
                local w, h = btn:GetSize()
                local size = math.min(w, h)
                btn.icon:ClearAllPoints()
                btn.icon:SetSize(size, size)
                btn.icon:SetPoint("CENTER")
            end)

            button:SetScript("PostClick", function()
                ---@type QuickActionObject?
                local data = button.data
                if not data then return end

                local codeStr = data:GetCustomCode()
                if not codeStr then return end

                pcall(function()
                    local loadedFunc = loadstring(codeStr)
                    if not loadedFunc then return end

                    loadedFunc()
                end)
            end)

            button.isInitialized = true
        end
        button.data = elementData

        local actionType = elementData:GetActionType()
        button:SetAttribute("type", actionType)
        if actionType == const.QUICK_ACTION_BAR.ACTION_TYPE.ITEM then
            local itemName = elementData:GetActionID()
            if tonumber(itemName) then
                local item = Item:CreateFromItemID(tonumber(itemName))
                item:ContinueOnItemLoad(function()
                    if button and button.SetAttribute then
                        button:SetAttribute(actionType, item:GetItemName())
                    end
                end)
            else
                button:SetAttribute(actionType, itemName)
            end
        else
            button:SetAttribute(actionType, elementData:GetActionID())
        end

        button.icon:SetTexture(elementData:GetIcon())

        button:GetScript("OnSizeChanged")(button)
    end
end

function quickActionBarUI:CreateFrame()
    self.defaultPanelInfo = UIPanelWindows["CollectionsJournal"]

    local f = CreateFrame("Frame", nil, self.parent, "PortraitFrameFlatBaseTemplate")
    ButtonFrameTemplate_HidePortrait(f)
    f:SetWidth(85)
    f:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 5, 0)
    f:SetPoint("BOTTOMLEFT", CollectionsJournal, "BOTTOMRIGHT", 5, 0)
    f:SetScript("OnShow", function()
        if not self.defaultPanelInfo then
            self.defaultPanelInfo = UIPanelWindows["CollectionsJournal"]
        end
        local newWidth = self.defaultPanelInfo.width + f:GetWidth()
        UIPanelWindows["CollectionsJournal"] = {
            area = self.defaultPanelInfo.area,
            pushable = self.defaultPanelInfo.pushable,
            whileDead = self.defaultPanelInfo.whileDead,
            width = newWidth,
        }
        SetUIPanelAttribute(CollectionsJournal, "width", newWidth)
        UpdateScaleForFitForOpenPanels()
    end)
    f:SetScript("OnHide", function()
        if not self.defaultPanelInfo then
            self.defaultPanelInfo = UIPanelWindows["CollectionsJournal"]
        end
        UIPanelWindows["CollectionsJournal"] = self.defaultPanelInfo
        SetUIPanelAttribute(CollectionsJournal, "width", self.defaultPanelInfo.width)
        UpdateScaleForFitForOpenPanels()
    end)
    f:Hide()
    self.frame = f
    f:SetTitle(self.L["QuickActionBarUI.QuickBarTitle"])

    local scrollFrame = components.ScrollFrame:CreateFrame(f, {
        anchors = {
            with_scroll_bar = {
                { "TOPLEFT",     20,  -30 },
                { "BOTTOMRIGHT", -25, 20 }
            },
            without_scroll_bar = {
                { "TOPLEFT",     20,  -30 },
                { "BOTTOMRIGHT", -25, 20 }
            },
        },
        template = "InsecureActionButtonTemplate",
        element_height = 35,
        element_width = 35,
        element_padding = 5,
        elements_per_row = 1,
        type = "GRID",
        initializer = self:GetInitializer()
    })

    self.utils:AddVisibilityCallback(function(actions)
        scrollFrame:UpdateContent(actions)
    end)
end

---@return fun(gridFrame:Frame|BackdropTemplate|table, elementData:QuickActionObject)
function quickActionBarUI:GetSettingsListInitializer()
    return function(gridFrame, elementData)
        if not gridFrame.isInit then
            gridFrame.isInit = true

            local btn = CreateFrame("Button", nil, gridFrame)
            btn:SetAllPoints()

            local tex = btn:CreateTexture()
            tex:SetPoint("CENTER")

            local label = btn:CreateFontString(nil, nil, "GameFontHighlight")
            label:SetPoint("TOPLEFT", 36, 1)
            label:SetPoint("BOTTOMRIGHT", 0, 1)
            label:SetJustifyH("LEFT")

            btn.Label = label
            btn.Texture = tex

            function btn:UpdateState()
                if quickActionBarUI.editor.selected == self.data then
                    self.Texture:SetAtlas("Options_List_Active", true)
                    self.Texture:Show()
                else
                    self.Texture:SetShown(self.over)
                    if self.over then
                        self.Texture:SetAtlas("Options_List_Hover", true)
                    end
                end
            end

            function btn:SetHover(isHovered)
                if self:IsEnabled() then
                    self.over = isHovered
                    self:UpdateState()
                    return true
                end
                return false
            end

            function btn:OnEnter()
                return self:SetHover(true)
            end

            function btn:OnLeave()
                return self:SetHover(nil)
            end

            function btn:OnClick()
                quickActionBarUI:SetSelection(self.data)
            end

            btn:SetScript("OnEnter", btn.OnEnter)
            btn:SetScript("OnLeave", btn.OnLeave)
            btn:SetScript("OnClick", btn.OnClick)

            gridFrame.button = btn
        end

        local btn = gridFrame.button
        btn.data = elementData
        btn.Label:SetText(elementData:GetTitle())

        btn:UpdateState()
    end
end

---@param data QuickActionObject
---@return Button|table|nil
function quickActionBarUI:GetButtonForData(data)
    if not data then return end
    local list = self.editor.scrollFrame
    if not list then return end
    local view = list.scrollView
    if not view then return end

    ---@diagnostic disable-next-line: undefined-field
    local frame = view:FindFrame(data)
    if not frame then return end
    return frame.button
end

---@param data QuickActionObject|nil
function quickActionBarUI:SetSelection(data)
    local activeSelect = self.editor.selected
    if not activeSelect or activeSelect ~= data then
        local oldBtn = self:GetButtonForData(activeSelect)
        self.editor.selected = data
        if oldBtn then
            oldBtn:UpdateState()
        end
    end
    local newBtn = self:GetButtonForData(data)
    if newBtn then
        newBtn:UpdateState()
    end

    local editor = self.editor
    local newID = data and data:GetID() or nil
    local newTitle = data and data:GetTitle() or self.L["QuickActionBarUI.SettingTitlePreview"]
    local newIcon = data and data:GetIconOverride() or ""
    local newIconPreview = data and data:GetIcon() or 5228749
    local newActionID = data and data:GetActionID() or ""
    local newActionType = data and data:GetActionType() or const.QUICK_ACTION_BAR.ACTION_TYPE.SPELL
    local newCheckUsability = data and not (not data.checkVisibility) or false

    editor.entryID = newID
    editor.titlePreview:SetText(newTitle)
    editor.iconPreview:SetTexture(newIconPreview)
    editor.titleInput:SetText(newTitle)
    editor.iconInput:SetText(newIcon)
    editor.actionIDInput:SetText(newActionID)
    editor.actionTypeDropdown:GetDropdown().SetSelection(newActionType)
    editor.checkUsabilityInput:SetChecked(newCheckUsability)
end

---@return fun(frame:Frame|BackdropTemplate|table, data:table)
function quickActionBarUI:GetTreeSettingsInitializer()
    self.utils = Private.QuickActionBarUtils
    self.L = Private.L
    return function(frame)
        if frame.isInitialized then
            return
        end
        frame.isInitialized = true
        NineSliceUtil.ApplyUniqueCornersLayout(frame, "OptionsFrame")

        local list = components.ScrollFrame:CreateFrame(frame, {
            anchors = {
                with_scroll_bar = {
                    { "TOPLEFT",    16, -15 },
                    { "BOTTOMLEFT", 16, 16 }
                },
                without_scroll_bar = {
                    { "TOPLEFT",    16, -16 },
                    { "BOTTOMLEFT", 16, 16 }
                },
            },
            width = 175,
            element_height = 20,
            element_padding = 5,
            elements_per_row = 1,
            type = "LIST",
            initializer = self:GetSettingsListInitializer()
        })

        local editorTitle = components.Label:CreateFrame(frame, {
            anchors = {
                { "TOPLEFT",  list.scrollBox, "TOPRIGHT", 50, -15 },
                { "TOPRIGHT", -125,           -15 }
            },
            font = "GameFontNormalHuge",
            text = self.L["QuickActionBarUI.SettingsEditorTitle"],
        })

        local titlePreview = components.Label:CreateFrame(frame, {
            anchors = {
                { "TOPLEFT",  editorTitle.frame, "BOTTOMLEFT",  0, -5 },
                { "TOPRIGHT", editorTitle.frame, "BOTTOMRIGHT", 0, -5 },
            },
            text = self.L["QuickActionBarUI.SettingTitlePreview"],
            color = const.COLORS.YELLOW
        })

        local iconPreview = components.RoundedIcon:CreateFrame(frame, {
            anchors = {
                { "TOPRIGHT", -31, -30 },
            },
            height = 40,
            width = 40,
        })
        iconPreview:SetTexture(5228749)

        local titleLabel = components.Label:CreateFrame(frame, {
            anchors = {
                { "TOPLEFT", titlePreview.frame, "BOTTOMLEFT", 0, -25 }
            },
            color = const.COLORS.YELLOW,
            text = self.L["QuickActionBarUI.SettingsTitleLabel"],
        })

        local titleInput = components.TextBox:CreateFrame(frame, {
            anchors = {
                { "TOPRIGHT", -31, -100 },
            },
            width = 175,
            instructions = self.L["QuickActionBarUI.SettingsTitleInput"],
        })

        local iconLabel = components.Label:CreateFrame(frame, {
            anchors = {
                { "TOPLEFT", titleLabel.frame, "BOTTOMLEFT", 0, -15 }
            },
            color = const.COLORS.YELLOW,
            text = self.L["QuickActionBarUI.SettingsIconLabel"],
        })

        local iconInput = components.TextBox:CreateFrame(frame, {
            anchors = {
                { "TOPRIGHT", titleInput.editBox, "BOTTOMRIGHT", 0, -15 },
                { "TOPLEFT",  titleInput.editBox, "BOTTOMLEFT",  0, -15 },
            },
            instructions = self.L["QuickActionBarUI.SettingsIconInput"],
        })

        local actionIDLabel = components.Label:CreateFrame(frame, {
            anchors = {
                { "TOPLEFT", iconLabel.frame, "BOTTOMLEFT", 0, -15 }
            },
            color = const.COLORS.YELLOW,
            text = self.L["QuickActionBarUI.SettingsIDLabel"],
        })

        local actionIDInput = components.TextBox:CreateFrame(frame, {
            anchors = {
                { "TOPRIGHT", iconInput.editBox, "BOTTOMRIGHT", 0, -15 },
                { "TOPLEFT",  iconInput.editBox, "BOTTOMLEFT",  0, -15 },
            },
            instructions = self.L["QuickActionBarUI.SettingsIDInput"],
        })

        local actionTypeLabel = components.Label:CreateFrame(frame, {
            anchors = {
                { "TOPLEFT", actionIDLabel.frame, "BOTTOMLEFT", 0, -15 }
            },
            color = const.COLORS.YELLOW,
            text = self.L["QuickActionBarUI.SettingsTypeLabel"],
        })

        local actionTypeDropdown = components.Dropdown:CreateFrame(frame, {
            anchors = {
                { "TOPRIGHT", actionIDInput.editBox, "BOTTOMRIGHT", 0,  -15 },
                { "TOPLEFT",  actionIDInput.editBox, "BOTTOMLEFT",  -5, -15 },
            },
            dropdownType = "RADIO",
            radioOptions = {
                { self.L["QuickActionBarUI.SettingsTypeInputSpell"], const.QUICK_ACTION_BAR.ACTION_TYPE.SPELL },
                { self.L["QuickActionBarUI.SettingsTypeInputItem"], const.QUICK_ACTION_BAR.ACTION_TYPE.ITEM },
            }
        })

        local checkUsabilityLabel = components.Label:CreateFrame(frame, {
            anchors = {
                { "TOPLEFT", actionTypeLabel.frame, "BOTTOMLEFT", 0, -15 }
            },
            color = const.COLORS.YELLOW,
            text = self.L["QuickActionBarUI.SettingsCheckUsableLabel"],
        })

        local checkUsabilityInput = components.CheckBox:CreateFrame(frame, {
            anchors = {
                { "TOPLEFT", actionTypeDropdown.dropdown, "BOTTOMLEFT", 0, -12 }
            },
            width = 20,
            height = 20,
        })

        local saveButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        saveButton:SetPoint("BOTTOMRIGHT", -31, 31)
        saveButton:SetSize(125, 22)
        saveButton:SetText(self.L["QuickActionBarUI.SettingsEditorSave"])

        local newButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        newButton:SetPoint("BOTTOMRIGHT", saveButton, "BOTTOMLEFT", -5, 0)
        newButton:SetSize(125, 22)
        newButton:SetText(self.L["QuickActionBarUI.SettingsEditorNew"])

        local deleteButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        deleteButton:SetPoint("BOTTOMRIGHT", newButton, "BOTTOMLEFT", -5, 0)
        deleteButton:SetSize(125, 22)
        deleteButton:SetText(self.L["QuickActionBarUI.SettingsEditorDelete"])

        self.editor.scrollFrame = list
        self.editor.titlePreview = titlePreview
        self.editor.iconPreview = iconPreview
        self.editor.titleInput = titleInput
        self.editor.iconInput = iconInput
        self.editor.actionIDInput = actionIDInput
        self.editor.actionTypeDropdown = actionTypeDropdown
        self.editor.checkUsabilityInput = checkUsabilityInput

        self.utils:AddUpdateCallback(function(actions)
            self:UpdateEditor(actions)
        end)

        newButton:SetScript("OnClick", function()
            local newAction = self.utils:CreateAction(const.QUICK_ACTION_BAR.ACTION_TYPE.SPELL, self.L["QuickActionBarUI.SettingsEditorNew"], nil,
                self.utils:GetDefaultVisibilityFunc())
            list:UpdateContent(self.utils:GetAllActions())
            self:SetSelection(newAction)
        end)

        deleteButton:SetScript("OnClick", function()
            if not self.editor.selected then return end
            self.utils:DeleteActionByID(self.editor.selected:GetID())
            list:UpdateContent(self.utils:GetAllActions())
            self:SetSelection(nil)
        end)

        saveButton:SetScript("OnClick", function()
            local obj = self.editor.selected
            if not obj then
                Private.Addon:FPrint(self.L["QuickActionBarUI.SettingsNoActionSaveError"])
                return
            end

            local title = self.editor.titleInput:GetText()
            local icon = tonumber(self.editor.iconInput:GetText()) or self.editor.iconInput:GetText()
            local actionID = self.editor.actionIDInput:GetText()
            local actionType = self.editor.actionTypeDropdown:GetDropdown().selectedValue
            local checkUsability = self.editor.checkUsabilityInput:GetChecked()

            if title == "" then
                title = self.L["QuickActionBarUI.SettingsEditorAction"]:format(tostring(self.editor.entryID) or "?")
            end
            if not actionType then
                actionType = const.QUICK_ACTION_BAR.ACTION_TYPE.SPELL
            end

            obj:SetActionID(actionID)
            obj:SetActionType(actionType)
            obj:SetIconOverride(icon and icon ~= "" and icon or nil)
            obj:SetTitle(title)
            if checkUsability then
                obj:SetVisibilityFunc(self.utils:GetDefaultVisibilityFunc())
            else
                obj:SetVisibilityFunc(nil)
            end

            local errMsg = self.utils:EditActionByID(self.editor.entryID, obj)
            if errMsg then
                Private.Addon:FPrint(self.L["QuickActionBarUI.SettingsGeneralActionSaveError"], errMsg)
                return
            end

            self:UpdateEditor(self.utils:GetAllActions())
            self:SetSelection(obj)
        end)
    end
end

---@param actions QuickActionObject[]
function quickActionBarUI:UpdateEditor(actions)
    self.editor.scrollFrame:UpdateContent(actions)
end

function quickActionBarUI:Toggle()
    if InCombatLockdown() then
        Private.Addon:Print(self.L["QuickActionBarUI.CombatToggleError"])
        return
    end
    if not self.frame then
        self:CreateFrame()
    end

    self.frame:SetShown(not self.frame:IsShown())
end

function quickActionBarUI:IsVisible()
    return self.frame and self.frame:IsShown()
end
