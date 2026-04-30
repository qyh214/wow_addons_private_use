local ADDON_NAME, mppe = ...
local Translate = mppe.Translate

-- 检查数据库是否已加载
local function IsDBLoaded() return MythicPlusPageExtensionDB ~= nil end
-- 延迟初始化标志
local settingsInitialized = false

local mppe_sFrame = CreateFrame("Frame", "MPPE_MythicPlusPageExtension_SettingFrame", InterfaceOptionsFramePanelContainer)
mppe_sFrame.name = "MPPE"
mppe_sFrame:Hide()

local mppe_sTitle = mppe_sFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
mppe_sTitle:SetPoint("TOPLEFT", 0, -15)
mppe_sTitle:SetText(Translate['Mythic Plus Page Extension']..(mppe.Translator and " ("..mppe.Translator..")" or ""))
mppe_sTitle:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")

local line_sTop = mppe_sFrame:CreateTexture(nil, "ARTWORK")
line_sTop:SetSize(550, 1)
line_sTop:SetAtlas("spec-dividerline", false)
line_sTop:SetPoint("TOP", mppe_sFrame, "TOP", -15, -40)

local line_sBottom = mppe_sFrame:CreateTexture(nil, "ARTWORK")
line_sBottom:SetSize(550, 1)
line_sBottom:SetAtlas("spec-dividerline", false)
line_sBottom:SetPoint("BOTTOM", mppe_sFrame, "BOTTOM", -15, 65)

local mppe_sFooter = mppe_sFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
mppe_sFooter:SetPoint("RIGHT", mppe_sFrame, "RIGHT", -10, 0)
mppe_sFooter:SetPoint("BOTTOM", mppe_sFrame, "BOTTOM", 0, 10)
mppe_sFooter:SetJustifyH("RIGHT")
mppe_sFooter:SetText("|c00ffff63MythicPlusPageExtension By CN2714\nReferences: AngryKeystones KeystoneLoot BugSack\nWA:uPxmk1k-L WA:ud2YBS4WC WA:lxA3Tr2Fr (and DeepSeek)|r")

--==================================================================
-- 创建标签页容器
local settings_Tabs = CreateFrame("Frame", "MPPE_SettingsTabs", mppe_sFrame)
settings_Tabs:SetPoint("TOP", line_sTop, "BOTTOM", 0, -5)
settings_Tabs:SetPoint("BOTTOM", line_sBottom, "TOP", 0, 5)
settings_Tabs:SetWidth(550)

-- 标签页系统变量
settings_Tabs.tabs = {}
settings_Tabs.currentTab = 1

-- 标签页按钮容器
settings_Tabs.tabButtons = CreateFrame("Frame", "MPPE_TabButtons", settings_Tabs)
settings_Tabs.tabButtons:SetHeight(30)
settings_Tabs.tabButtons:SetPoint("TOP", 10, 0)
settings_Tabs.tabButtons:SetWidth(550)

-- 标签页内容容器
settings_Tabs.content = CreateFrame("Frame", "MPPE_TabContent", settings_Tabs)
settings_Tabs.content:SetPoint("TOP", settings_Tabs.tabButtons, "BOTTOM", 0, 7)
settings_Tabs.content:SetPoint("BOTTOM", 0, 0)
settings_Tabs.content:SetWidth(550)

-- 创建边框纹理
settings_Tabs.content.borderTop = settings_Tabs.content:CreateTexture(nil, "BORDER")
settings_Tabs.content.borderTop:SetHeight(2)
settings_Tabs.content.borderTop:SetPoint("TOPLEFT", 0, 0)
settings_Tabs.content.borderTop:SetPoint("TOPRIGHT", 0, 0)
settings_Tabs.content.borderTop:SetColorTexture(0.3, 0.3, 0.3, 1)

settings_Tabs.content.borderBottom = settings_Tabs.content:CreateTexture(nil, "BORDER")
settings_Tabs.content.borderBottom:SetHeight(2)
settings_Tabs.content.borderBottom:SetPoint("BOTTOMLEFT", 0, -2)
settings_Tabs.content.borderBottom:SetPoint("BOTTOMRIGHT", 0, -2)
settings_Tabs.content.borderBottom:SetColorTexture(0.3, 0.3, 0.3, 1)

settings_Tabs.content.borderLeft = settings_Tabs.content:CreateTexture(nil, "BORDER")
settings_Tabs.content.borderLeft:SetWidth(2)
settings_Tabs.content.borderLeft:SetPoint("TOPLEFT", 0, 0)
settings_Tabs.content.borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
settings_Tabs.content.borderLeft:SetColorTexture(0.3, 0.3, 0.3, 1)

settings_Tabs.content.borderRight = settings_Tabs.content:CreateTexture(nil, "BORDER")
settings_Tabs.content.borderRight:SetWidth(2)
settings_Tabs.content.borderRight:SetPoint("TOPRIGHT", 0, 0)
settings_Tabs.content.borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
settings_Tabs.content.borderRight:SetColorTexture(0.3, 0.3, 0.3, 1)

-- 创建标签按钮的函数
function settings_Tabs:CreateTab(tabName, tabContentFrame)
    local tabID = #self.tabs + 1
    
    -- 创建标签按钮
    local tabButton = CreateFrame("Button", "MPPE_TabButton"..tabID, self.tabButtons)
    tabButton:SetSize(150, 25)
    
    -- 设置位置
    if tabID == 1 then
        tabButton:SetPoint("TOPLEFT", 10, 0)
    else
        tabButton:SetPoint("LEFT", self.tabs[tabID-1].button, "RIGHT", 3, 0)
    end
    
    -- 创建背景纹理
    tabButton.bg = tabButton:CreateTexture(nil, "BACKGROUND")
    tabButton.bg:SetAllPoints()
    tabButton.bg:SetColorTexture(0.3, 0.3, 0.3, 1)

    -- 创建选中状态纹理
    tabButton.selected = tabButton:CreateTexture(nil, "ARTWORK")
    tabButton.selected:SetAllPoints()
    tabButton.selected:SetColorTexture(0.1, 0.4, 0.8, 0.6)
    tabButton.selected:Hide()
    
    -- 创建高亮纹理
    tabButton.highlight = tabButton:CreateTexture(nil, "HIGHLIGHT")
    tabButton.highlight:SetAllPoints()
    tabButton.highlight:SetColorTexture(1, 1, 1, 0.2)
    
    -- 创建文本
    tabButton.text = tabButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tabButton.text:SetPoint("CENTER")
    tabButton.text:SetText(tabName)
    
    -- 点击事件
    tabButton:SetScript("OnClick", function()
        settings_Tabs:SetTab(tabID)
    end)
    
    -- 鼠标悬停效果
    tabButton:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.4, 0.4, 0.6, 1)
    end)
    
    tabButton:SetScript("OnLeave", function(self)
        if settings_Tabs.currentTab ~= tabID then
            self.bg:SetColorTexture(0.3, 0.3, 0.3, 1)
        else
            self.bg:SetColorTexture(0.1, 0.4, 0.8, 0.6)
        end
    end)
    
    -- 创建内容框架作为滚动框架
    local contentFrame = CreateFrame("ScrollFrame", "MPPE_ContentFrame_"..tabID, self.content, "ScrollFrameTemplate")
    contentFrame:SetPoint("TOPLEFT", self.content, "TOPLEFT", 2, -5)  -- 调整位置，留出一点间距
    contentFrame:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", -22, 0)
    contentFrame:Hide()

    if tabContentFrame then
        tabContentFrame:SetParent(contentFrame)
        contentFrame:SetScrollChild(tabContentFrame)
    end
    -- 存储标签信息
    self.tabs[tabID] = {
        button = tabButton,
        content = contentFrame,
        name = tabName
    }
    
    return tabID
end

-- 切换标签页
function settings_Tabs:SetTab(tabID)
    if not self.tabs[tabID] then return end
    
    -- 隐藏当前标签内容并重置样式
    if self.currentTab and self.tabs[self.currentTab] then
        self.tabs[self.currentTab].content:Hide()
        self.tabs[self.currentTab].button.selected:Hide()
        self.tabs[self.currentTab].button.bg:SetColorTexture(0.3, 0.3, 0.3, 1)
    end
    
    -- 显示新标签内容并设置选中样式
    self.tabs[tabID].content:Show()
    self.tabs[tabID].button.selected:Show()
    self.tabs[tabID].button.bg:SetColorTexture(0.1, 0.4, 0.8, 0.6)
    
    -- 更新当前标签
    self.currentTab = tabID
end

--==================================================================
settings_Tabs.SettingsList = {
    [1] = {
        tabName = "Score&Teleport",
        tabList = {
            [1] = {
                db = "ScoreNTeleport_Enable",
                name = "Enable",
                type = "CheckBox", 
                indent = 0,
                value = {
                    default = true,
                }
            },
            [2] = {
                name = "↑Disabling this feature requires a UI reload (/reload) to take effect.",
                type = "Label", 
                indent = 0,
                lines = 1
            },
            [3] = {
                db = "ScoreNTeleport_TryClearOther",
                name = "Try to clear other non-native content on dungeon icon(excluding this addon).",
                type = "CheckBox", 
                indent = 1,
                value = {
                    default = true,
                }
            },
            [4] = {
                db = "ScoreNTeleport_ScoreColorStyle",
                name = "Score Text Color Style",
                type = "ComboBox", 
                indent = 1,
                value = {
                    default = "highestlv",
                    list = {["highestlv"] = "Match Highest Level", ["raiderio"] = "RaiderIO Style", ["standard"] = "Standard Style"}
                }
            },
            [5] = {
                db = "ScoreNTeleport_EnableTeleport",
                name = "Enable click-to-use teleport(separate toggle to avoid conflict with other addons; does not affect other functions).",
                type = "CheckBox", 
                indent = 1,
                value = {
                    default = true,
                }
            },
            [6] = {
                db = "ScoreNTeleport_SendTeleportInfo",
                name = "Send a message to the party channel after using teleport.",
                type = "CheckBox", 
                indent = 1,
                value = {
                    default = true,
                }
            },
            [7] = {
                db = "ScoreNTeleport_STI_CastStatu",
                name = "Send message when",
                type = "ComboBox", 
                indent = 2,
                value = {
                    default = "castsucceeded",
                    list = {["caststart"] = "Teleport Start", ["castsucceeded"] = "Teleport Complete"}
                }
            },
            [8] = {
                db = "ScoreNTeleport_UseOldStyle",
                name = "Use Original Style (WA:ud2YBS4WC)",
                type = "CheckBox", 
                indent = 1,
                value = {
                    default = false,
                }
            },
            [9] = {
                db = "ScoreNTeleport_DunShortName_FontSize",
                name = "Dungeon Shortname Font Size",
                type = "Slider", 
                indent = 1,
                value = {
                    default = 13,
                    min = 5,
                    max = 25,
                    step = 0.1
                }
            },
            [10] = {
                db = "ScoreNTeleport_DunShortName_PerLine",
                name = "The number of characters per line of the Dungeon Shortname",
                type = "Slider", 
                indent = 1,
                value = {
                    default = 7,
                    min = 1,
                    max = 25,
                    step = 1
                }
            },
            [11] = {
                db = "ScoreNTeleport_DunLevel_FontSize",
                name = "Dungeon Highest Level Font Size",
                type = "Slider", 
                indent = 1,
                value = {
                    default = 22,
                    min = 5,
                    max = 25,
                    step = 0.1
                }
            },
            [12] = {
                db = "ScoreNTeleport_DunScore_FontSize",
                name = "Dungeon Highest Score Font Size",
                type = "Slider", 
                indent = 1,
                value = {
                    default = 22,
                    min = 5,
                    max = 25,
                    step = 0.1
                }
            },
        }
    },
    [2] = {
        tabName = "PartyInfo",
        tabList = {
            [1] = {
                db = "PartyKeyStone_Enable",
                name = "Enable",
                type = "CheckBox", 
                indent = 0,
                value = {
                    default = true,
                }
            },
            [2] = {
                db = "PartyKeyStone_ScoreColorStyle",
                name = "Score Text Color Style",
                type = "ComboBox", 
                indent = 1,
                value = {
                    default = "raiderio",
                    list = {["raiderio"] = "RaiderIO Style", ["standard"] = "Standard Style"}
                }
            },
            [3] = {
                db = "PartyKeyStone_xOffset",
                name = "X Offset",
                type = "Slider", 
                indent = 1,
                value = {
                    default = 0.0,
                    min = -200.0,
                    max = 200.0,
                    step = 0.1
                }
            },
            [4] = {
                db = "PartyKeyStone_yOffset",
                name = "Y Offset",
                type = "Slider", 
                indent = 1,
                value = {
                    default = 0.0,
                    min = -200.0,
                    max = 200.0,
                    step = 0.1
                }
            }
        }
    },
    [3] = {
        tabName = "WeeklyReport",
        tabList = {
            [1] = {
                db = "WeeklyReport_Enable",
                name = "Enable",
                type = "CheckBox", 
                indent = 0,
                value = {
                    default = true,
                }
            },
            -- [2] = {
            --     db = "WeeklyReport_FrameStyle",
            --     name = "周报窗口样式",
            --     type = "ComboBox", 
            --     indent = 1,
            --     value = {
            --         default = "accordion",
            --         list = {["accordion"] = "Accordion Style", ["standard"] = "Standard Style"}
            --     }
            -- },
            [2] = {
                db = "WeeklyReport_HideRaiderIOFrame",
                name = "Hide RaiderIO Frame When Mythic+ Page Opens.",
                type = "CheckBox", 
                indent = 1,
                value = {
                    default = true,
                }
            },
            [3] = {
                db = "WeeklyReport_ShowWeeklyTOP8",
                name = "Show Weekly Top8 Report",
                type = "CheckBox", 
                indent = 1,
                value = {
                    default = true,
                }
            },
            [4] = {
                db = "WeeklyReport_FontSize",
                name = "Weekly Report Font Size",
                type = "Slider", 
                indent = 1,
                value = {
                    default = 15,
                    min = 5,
                    max = 25,
                    step = 0.1
                }
            },
            [5] = {
                db = "WeeklyReport_FrameWidth",
                name = "Weekly Report Frame Width",
                type = "Slider", 
                indent = 1,
                value = {
                    default = 400,
                    min = 300,
                    max = 800,
                    step = 1
                }
            },
            [6] = {
                db = "WeeklyReport_FrameHeightCorrection",
                name = "Weekly Report Frame Height Correction(Fix misalignment and height discrepancies caused by UI scaling.)",
                type = "Slider", 
                indent = 1,
                value = {
                    default = 0,
                    min = -2.00,
                    max = 2.00,
                    step = 0.01
                }
            },
        }
    },
}
function settings_Tabs:CreateTabContext()
    for i, content in ipairs(settings_Tabs.SettingsList) do
        local _tabName = Translate[content.tabName] or "TabPage_"..tostring(i)
        local _tabPage = CreateFrame("Frame", "MPPE_SettingsTabPage_"..tostring(i))
        _tabPage:SetSize(500, 1500) 

        local _tabHeight = 5
        for j, item in ipairs(content.tabList) do
            local itemName = Translate[item.name] or item.name or "Item_"..tostring(j)
            local leftmargin = 5 + (type(item.indent) == "number" and item.indent or 0) * 20
            if item.type == "Label" then
                local label = _tabPage:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                label:SetText(itemName)
                label:SetPoint("TOPLEFT", _tabPage, "TOPLEFT", leftmargin, -_tabHeight)
                label:SetSize(600-12, (item.lines and item.lines or 1) * 15)
                label:SetJustifyH("LEFT")
                label:SetJustifyV("TOP")

                _tabHeight = _tabHeight + label:GetHeight() + 10             
            elseif item.type == "CheckBox" then
                local checkBoxTitle = _tabPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                checkBoxTitle:SetPoint("TOPLEFT", leftmargin + 24, -_tabHeight - 5)
                checkBoxTitle:SetText(itemName)
                checkBoxTitle:SetHeight(32)
                checkBoxTitle:SetWidth(600-36)
                checkBoxTitle:SetJustifyH("LEFT")
                checkBoxTitle:SetJustifyV("MIDDLE")
                local checkBox = CreateFrame("CheckButton", "MPPE_Setting_"..item.db, _tabPage, "ChatConfigCheckButtonTemplate")
                checkBox:SetSize(24, 24)
                checkBox:SetPoint("RIGHT", checkBoxTitle, "LEFT", 0, 0)

                                
                local _value = MythicPlusPageExtensionDB[item.db]
                if type(_value) ~= "boolean" then _value = (type(item.value.default) == "boolean") and item.value.default or false end
                checkBox:SetChecked(_value)
                checkBox:SetScript("OnClick", function(self)
                    MythicPlusPageExtensionDB[item.db] = self:GetChecked()
                end)

                _tabHeight = _tabHeight + checkBox:GetHeight() + 10 +12
            elseif item.type == "Slider" then
                local sliderTitle = _tabPage:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall") 
                sliderTitle:SetPoint("TOPLEFT", leftmargin, -_tabHeight - 5)
                sliderTitle:SetText(itemName)
                sliderTitle:SetHeight(32)
                sliderTitle:SetWidth(400 - leftmargin)
                sliderTitle:SetJustifyH("LEFT")
                sliderTitle:SetJustifyV("MIDDLE")
                local slider = CreateFrame("Slider", "MPPE_Setting_"..item.db, _tabPage, "OptionsSliderTemplate")
                slider:SetSize(180, 17)
                slider:SetPoint("LEFT", sliderTitle, "RIGHT", 15, 0)
                slider:SetMinMaxValues(item.value.min or 0, item.value.max or 100)
                slider.Low:SetText(item.value.min or 0)
                slider.High:SetText(item.value.max or 100)
                
                if type(item.value.step) ~= "number" or item.value.step <= 0 then item.value.step = 1 end
                slider:SetValueStep(item.value.step)
                local str = tostring(mppe.MathRound(item.value.step, 3))
                local dec = str:match("%.(%d+)")
                local _decimalPlace = dec and math.min(#dec, 3) or 0
                
                local _value = MythicPlusPageExtensionDB[item.db]
                if type(_value) ~= "number" then _value = (type(item.value.default) == "number") and item.value.default or 50 end
                slider:SetValue(_value)
                slider.Text:SetText(mppe.MathRound(slider:GetValue(), _decimalPlace))
                slider:SetScript("OnValueChanged", function(self, value)
                    self.Text:SetText(mppe.MathRound(value, _decimalPlace))
                    MythicPlusPageExtensionDB[item.db] = mppe.MathRound(value, _decimalPlace)                                     
                end)
                
                local sliderPlusBtn = CreateFrame("Button", "MPPE_Setting_"..item.db.."_Plus", _tabPage)
                sliderPlusBtn:SetSize(10,10)
                sliderPlusBtn:SetPoint("LEFT", slider, "RIGHT", 1, 0)
                sliderPlusBtn.Icon = sliderPlusBtn:CreateTexture(nil, "OVERLAY")
                sliderPlusBtn.Icon:SetAllPoints()
                sliderPlusBtn.Icon:SetAtlas("common-icon-plus")
                sliderPlusBtn:SetScript("OnEnter", function(self)
                    self.Icon:SetVertexColor(1, 0.5, 0)
                end)
                sliderPlusBtn:SetScript("OnLeave", function(self)
                    self.Icon:SetVertexColor(1, 1, 1)
                end)
                sliderPlusBtn:SetScript("OnClick", function()
                    slider:SetValue(slider:GetValue() + item.value.step)
                end)

                local sliderMinusBtn = CreateFrame("Button", "MPPE_Setting_"..item.db.."_Minus", _tabPage)
                sliderMinusBtn:SetSize(10,10)
                sliderMinusBtn:SetPoint("RIGHT", slider, "LEFT", -1, 0)
                sliderMinusBtn.Icon = sliderMinusBtn:CreateTexture(nil, "OVERLAY")
                sliderMinusBtn.Icon:SetAllPoints()
                sliderMinusBtn.Icon:SetAtlas("common-icon-minus")
                sliderMinusBtn:SetScript("OnEnter", function(self)
                    self.Icon:SetVertexColor(1, 0.5, 0)
                end)
                sliderMinusBtn:SetScript("OnLeave", function(self)
                    self.Icon:SetVertexColor(1, 1, 1)
                end)
                sliderMinusBtn:SetScript("OnClick", function()
                    slider:SetValue(slider:GetValue() - item.value.step)
                end)

                _tabHeight = _tabHeight + sliderTitle:GetHeight() + 20 -- 补一个间距    
            elseif item.type == "ComboBox" then
                local comboBoxTitle = _tabPage:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                comboBoxTitle:SetPoint("TOPLEFT", leftmargin, -_tabHeight)
                comboBoxTitle:SetText(itemName)
                comboBoxTitle:SetHeight(32)
                comboBoxTitle:SetWidth(400 - leftmargin)
                comboBoxTitle:SetJustifyH("LEFT")
                comboBoxTitle:SetJustifyV("MIDDLE")
                local comboBox = CreateFrame("Frame", "MPPE_Setting_"..item.db, _tabPage, "UIDropDownMenuTemplate")
                comboBox:SetSize(165, 32)
                comboBox:SetPoint("LEFT", comboBoxTitle, "RIGHT", -5, 0)
                UIDropDownMenu_SetWidth(comboBox, 175)
                
                -- 初始化函数
                local function InitializeDropDown(self, level)
                    local info = UIDropDownMenu_CreateInfo()
                    local currentValueFromDB = MythicPlusPageExtensionDB[item.db]
                    
                    for key, displayText in pairs(item.value.list or {}) do
                        info.text ="  "..Translate[displayText] or key
                        info.value = key
                        info.checked = (currentValueFromDB == key)
                        info.func = function(button)
                            local selectedKey = button.value
                            local selectedDisplayText = button:GetText()
                            UIDropDownMenu_SetSelectedValue(comboBox, selectedKey)
                            UIDropDownMenu_SetText(comboBox, selectedDisplayText)
                            MythicPlusPageExtensionDB[item.db] = selectedKey
                            CloseDropDownMenus()
                        end
                        UIDropDownMenu_AddButton(info)
                    end
                end
                
                UIDropDownMenu_Initialize(comboBox, InitializeDropDown)
                -- 确定最终要使用的键 (key)，遵循三级优先级
                local finalKey = nil
                -- 按优先级检查：数据库值 -> 配置默认值 -> 列表第一项
                local candidateKeys = { MythicPlusPageExtensionDB[item.db], item.value.default, }
                for _, key in ipairs(candidateKeys) do
                    if key and item.value.list and item.value.list[key] then
                        finalKey = key
                        break
                    end
                end
                -- 如果前两级都无效，使用列表第一个选项
                if not finalKey and item.value.list then finalKey = next(item.value.list) end
                -- 应用选择
                if finalKey then
                    local displayText = Translate[item.value.list[finalKey]] or item.value.list[finalKey]
                    UIDropDownMenu_SetText(comboBox, displayText)
                    UIDropDownMenu_SetSelectedValue(comboBox, finalKey)
                    MythicPlusPageExtensionDB[item.db] = finalKey
                else
                    UIDropDownMenu_SetText(comboBox, "- WRONG -")
                end
                
                _tabHeight = _tabHeight + comboBoxTitle:GetHeight() + 10
            elseif item.type == "TextBox" then
                local textBoxTitle = _tabPage:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")  -- 父框架改为content
                textBoxTitle:SetPoint("TOPLEFT", leftmargin, -_tabHeight)
                textBoxTitle:SetText(itemName)
                textBoxTitle:SetHeight(32)
                textBoxTitle:SetWidth(400 - leftmargin)
                textBoxTitle:SetJustifyH("LEFT")
                textBoxTitle:SetJustifyV("MIDDLE")
                local textBox = CreateFrame("EditBox", "MPPE_Setting_"..item.db, _tabPage, "InputBoxTemplate")
                textBox:SetSize(185, 32)
                textBox:SetAutoFocus(false)
                textBox:SetPoint("LEFT", textBoxTitle, "RIGHT", 15, 0)

                textBox:SetText(MythicPlusPageExtensionDB[item.db] or item.value.default or "")
                textBox:SetScript("OnTextChanged", function(self)
                    MythicPlusPageExtensionDB[item.db] = self:GetText()
                end)
                _tabHeight = _tabHeight + textBoxTitle:GetHeight() + 20 -- 补一个间距   
            end
            _tabPage:SetHeight(_tabHeight)
        end
        settings_Tabs:CreateTab(_tabName, _tabPage)
    end
end

--==================================================================
-- 初始化设置函数
local _initTimes = 0
local function InitializeSettings()
    if _initTimes > 500 then
        print(string.format("|cffff0000MPPE Settings: %s|r", Translate['SavedVariables failed to load. Critical plugin error! Please check for updates!']))
        return
    end
    if not IsDBLoaded() then
        if _initTimes % 100 == 0 then
            print(string.format("|cffff0000MPPE Settings: |r%s", Translate['SavedVariables not loaded, initializing lazily.']))
        end
        C_Timer.After(0.1, InitializeSettings)
        _initTimes = _initTimes + 1
        return
    end
    if not settingsInitialized then
        settings_Tabs:CreateTabContext()
        settings_Tabs:SetTab(1)
        settingsInitialized = true
    end

    -- 旧版SavedVariables数据转换并清空
    if MythicPlusPageExtensionDB.DunNameSize then MythicPlusPageExtensionDB.ScoreNTeleport_DunShortName_FontSize = MythicPlusPageExtensionDB.DunNameSize MythicPlusPageExtensionDB.DunNameSize = nil end
    if MythicPlusPageExtensionDB.DunNamePerLine then MythicPlusPageExtensionDB.ScoreNTeleport_DunShortName_PerLine = MythicPlusPageExtensionDB.DunNamePerLine MythicPlusPageExtensionDB.DunNamePerLine = nil end
    if MythicPlusPageExtensionDB.DunLevelSize then MythicPlusPageExtensionDB.ScoreNTeleport_DunLevel_FontSize = MythicPlusPageExtensionDB.DunLevelSize MythicPlusPageExtensionDB.DunLevelSize = nil end
    if MythicPlusPageExtensionDB.DunScoreSize then MythicPlusPageExtensionDB.ScoreNTeleport_DunScore_FontSize = MythicPlusPageExtensionDB.DunScoreSize MythicPlusPageExtensionDB.DunScoreSize = nil end
    if MythicPlusPageExtensionDB.HideMainFrame then MythicPlusPageExtensionDB.WeeklyReport_Enable = false MythicPlusPageExtensionDB.HideMainFrame = nil end
    if MythicPlusPageExtensionDB.HideRaiderIOFrame then MythicPlusPageExtensionDB.WeeklyReport_HideRaiderIOFrame = MythicPlusPageExtensionDB.HideRaiderIOFrame MythicPlusPageExtensionDB.HideRaiderIOFrame = nil end
    if MythicPlusPageExtensionDB.WeeklyReportSize then MythicPlusPageExtensionDB.WeeklyReport_FontSize = MythicPlusPageExtensionDB.WeeklyReportSize MythicPlusPageExtensionDB.WeeklyReportSize = nil end
    if MythicPlusPageExtensionDB.WeeklyReportWidth then MythicPlusPageExtensionDB.WeeklyReport_FrameWidth = MythicPlusPageExtensionDB.WeeklyReportWidth MythicPlusPageExtensionDB.WeeklyReportWidth = nil end
end

mppe_sFrame:SetScript("OnShow", function(self)
    line_sTop:SetSize(mppe_sFrame:GetWidth()-15,1)
    line_sBottom:SetSize(line_sTop:GetSize())
    settings_Tabs.tabButtons:SetWidth(mppe_sFrame:GetWidth())
    settings_Tabs:SetWidth(mppe_sFrame:GetWidth())
    settings_Tabs.content:SetWidth(settings_Tabs:GetWidth() - 20)

    if not settingsInitialized then InitializeSettings() end
end)

C_Timer.After(1, function()
    if not settingsInitialized then InitializeSettings() end
end)
--==================================================================
local category = Settings.RegisterCanvasLayoutCategory(mppe_sFrame, "MPPE");
Settings.RegisterAddOnCategory(category)

function mppe.SettingsShow() 
    if UnitAffectingCombat("player") then
        print(string.format("%s%s","[MPPE]", Translate['Settings cannot be opened by command in combat.']))
        return
    end
    Settings.OpenToCategory(category.ID) 
end

SLASH_MPPE1 = "/mppe"
SlashCmdList["MPPE"] = function()
    Settings.OpenToCategory(category.ID)
end