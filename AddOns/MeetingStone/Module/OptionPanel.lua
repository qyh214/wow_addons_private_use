
BuildEnv(...)

SettingPanel = Addon:NewModule(CreateFrame('Frame', nil, MainPanel), 'SettingPanel', 'AceEvent-3.0', 'AceTimer-3.0')

local BINDING_KEY = 'MEETINGSTONE_TOGGLE'

function SettingPanel:OnInitialize()
    GUI:Embed(self, 'Owner')
    MainPanel:RegisterPanel(L['设置'], self, 3, 70, 1, true)

    self.db = Profile:GetCharacterDB()

    local order do
        local index = 0
        function order()
            index = index + 1
            return index
        end
    end

    local options = {
        type = 'group',
        name = L['设置'],
        get = function(item)
            return self.db.profile.settings[item[#item]]
        end,
        set = function(item, value)
            local key = item[#item]
            self.db.profile.settings[key] = value
            self:SendMessage('MEETINGSTONE_SETTING_CHANGED', key, value, true)
        end,
        args = {
            minimap = {
                type = 'toggle',
                name = L['显示小地图图标'],
                width = 'full',
                order = order(),
                get = function()
                    return not self.db.profile.minimap.hide
                end,
                set = function(_, value)
                    self.db.profile.minimap.hide = not value
                    if value then
                        LibStub('LibDBIcon-1.0'):Show('MeetingStone')
                    else
                        LibStub('LibDBIcon-1.0'):Hide('MeetingStone')
                    end
                end
            },
            panel = {
                type = 'toggle',
                name = L['显示悬浮窗'],
                width = 'full',
                order = order(),
            },
            panelLock = {
                type = 'toggle',
                name = L['锁定悬浮窗'],
                width = 'full',
                order = order(),
                disabled = function()
                    return not self.db.profile.settings.panel
                end
            },
            sound = {
                type = 'toggle',
                name = L['启用活动申请提示音'],
                width = 'full',
                order = order(),
            },
            ignore = {
                type = 'toggle',
                name = L['启用屏蔽列表增强'],
                width = 'full',
                order = order(),
            },
            -- onlyms = {
            --     type = 'toggle',
            --     name = L['只显示集合石活动'],
            --     width = 'full',
            --     order = 7,
            -- },
            spamWord = {
                type = 'toggle',
                name = L['启用活动列表关键字过滤'],
                width = 'full',
                order = order(),
            },
            key = {
                type = 'keybinding',
                name = L['打开/关闭集合石组团按键设置'],
                width = 'full',
                order = order(),
                get = function()
                    return GetBindingKey(BINDING_KEY)
                end,
                set = function(info, key)
                    for _, key in ipairs({GetBindingKey(BINDING_KEY)}) do
                        SetBinding(key, nil)
                    end
                    SetBinding(key, BINDING_KEY)
                    SaveBindings(GetCurrentBindingSet())
                end,
                confirm = function(info, key)
                    local action = GetBindingAction(key)
                    if action ~= '' and action ~= BINDING_KEY then
                        return L['按键已绑定到|cffffd100%s|r，你确定要覆盖吗？']:format(_G['BINDING_NAME_' .. action] or action)
                    end
                end
            },
            clearhistory = {
                type = 'execute',
                name = L['清理最近创建及搜索列表'],
                width = 'full',
                order = order(),
                confirm = function()
                    return L['你确定要清理最近创建及搜索列表吗？']
                end,
                func = function()
                    Profile:ClearHistory()
                end
            }
        }
    }

    local group = LibStub('AceGUI-3.0'):Create('BlizOptionsGroup')
    group.frame:ClearAllPoints()
    group.frame:SetParent(self)
    group.frame:SetPoint('TOPLEFT', 20, -20)
    group.frame:SetSize(400, 330)
    group.frame:Show()
    group:SetCallback('OnShow', function()
        LibStub('AceConfigDialog-3.0'):Open('MeetingStone', group)
    end)
    group:SetCallback('OnHide', function()
        group:ReleaseChildren()
    end)

    LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable('MeetingStone', options)

    do -- spam word.
        local SpamWordWidget = GUI:GetClass('TitleWidget'):New(self) do
            SpamWordWidget:SetPoint('TOPRIGHT', -5, 25)
            SpamWordWidget:SetPoint('TOPLEFT', group.label, 'TOPRIGHT', 5, 0)
            SpamWordWidget:SetText(L['关键字过滤'])
            SpamWordWidget:SetHeight(280)
            SpamWordWidget:SetBgShown(false)
        end

        local SpamWordInset = CreateFrame('Frame', nil, SpamWordWidget, 'InsetFrameTemplate') do
            SpamWordInset:SetPoint('TOPLEFT', 2, -25)
            SpamWordInset:SetPoint('BOTTOMRIGHT', -2, 5)
        end

        local InputSpamWord = Addon:GetClass('InputDialog'):New(UIParent) do
            InputSpamWord:SetTitle(L['请输入需要屏蔽的关键字'])
            InputSpamWord:SetCheckBoxLabel(L['正则?'])
            InputSpamWord:SetMaxLetters(50)
            InputSpamWord:SetErrorHandler(function(text)
                return pcall(strmatch, '', text)
            end)
            InputSpamWord:SetCallback('OnSubmit', function(_, text, checked)
                Profile:AddSpamWord({
                    text = text,
                    pain = not checked and true or nil
                })
                Logic:SendCommand('SPWD', text, checked or nil)
            end)
            InputSpamWord:SetCallback('OnError', function(self)
                self:SetError(L['正则有误，请检查'])
            end)
        end

        local SpamWordList = GUI:GetClass('ListView'):New(SpamWordInset) do
            SpamWordList:SetPoint('TOPLEFT', 5, -5)
            SpamWordList:SetPoint('BOTTOMRIGHT', -5, 5)
            SpamWordList:SetItemClass(Addon:GetClass('SpamWordItem'))
            SpamWordList:SetItemHeight(20)
            SpamWordList:SetItemSpacing(2)
            SpamWordList:SetSelectMode('RADIO')
            SpamWordList:SetItemHighlightWithoutChecked(true)
            SpamWordList:SetCallback('OnItemFormatted', function(_, button, data)
                button:SetData(data)
            end)
        end

        local SpamWordAdd = CreateFrame('Button', nil, SpamWordWidget, 'UIPanelButtonTemplate') do
            SpamWordAdd:SetPoint('LEFT', SpamWordWidget.Text, 'RIGHT', 0, 0)
            SpamWordAdd:SetSize(50, 22)
            SpamWordAdd:SetText(ADD)
            SpamWordAdd:SetScript('OnClick', function()
                self:AddSpamWord()
            end)
        end

        local SpamWordReset = CreateFrame('Button', nil, SpamWordWidget, 'UIPanelButtonTemplate') do
            SpamWordReset:SetPoint('TOPRIGHT', 0, -2)
            SpamWordReset:SetSize(50, 22)
            SpamWordReset:SetText(RESET)
            SpamWordReset:SetScript('OnClick', function()
                GUI:CallMessageDialog(L['确定重置关键字列表？'], function(result)
                    if result then
                        Profile:ResetSpamWord()
                    end
                end)
            end)
        end

        local EditDialog = Addon:GetClass('EditDialog'):New(UIParent) do
            EditDialog:SetCallback('OnSubmit', function(_, text)
                Profile:ImportSpamWord(text)
            end)
        end

        local SpamWordExport = CreateFrame('Button', nil, SpamWordWidget, 'UIPanelButtonTemplate') do
            SpamWordExport:SetPoint('TOPRIGHT', SpamWordWidget, 'BOTTOMRIGHT', 0, 0)
            SpamWordExport:SetSize(50, 22)
            SpamWordExport:SetText(L['导出'])
            SpamWordExport:SetScript('OnClick', function()
                EditDialog:Open(L['导出关键字'], L['点击 Ctrl+A 全选，Ctrl+C 复制'], Profile:ExportSpamWord(), false)
            end)
        end

        local SpamWordImport = CreateFrame('Button', nil, SpamWordWidget, 'UIPanelButtonTemplate') do
            SpamWordImport:SetPoint('RIGHT', SpamWordExport, 'LEFT', -2, 0)
            SpamWordImport:SetSize(50, 22)
            SpamWordImport:SetText(L['导入'])
            SpamWordImport:SetScript('OnClick', function()
                EditDialog:Open(L['导入关键字'], L['每行一个关键字，“!”开头启用正则'])
            end)
        end

        self.SpamWordList = SpamWordList
        self.InputSpamWord = InputSpamWord

        self:RegisterMessage('MEETINGSTONE_SPAMWORD_UPDATE', 'RefreshSpamWord')
    end
end

function SettingPanel:OnEnable()
    self:RefreshSpamWord()
end

function SettingPanel:RefreshSpamWord(_, word)
    self.SpamWordList:SetItemList(Profile:GetSpamWords())
    self.SpamWordList:Refresh()

    if word then
        self.SpamWordList:SetSelectedItem(word)
        self:ScheduleTimer('UpdateSpamWordScorll', 0.02)
    end
end

function SettingPanel:UpdateSpamWordScorll()
    local index = self.SpamWordList:GetSelected() or 0
    local maxCount = self.SpamWordList:GetMaxCount()
    if index > maxCount then
        index = index - maxCount + 1
    else
        index = 1
    end
    self.SpamWordList:SetOffset(index)
end

function SettingPanel:AddSpamWord(word)
    local text, enable
    if type(word) == 'table' then
        text = word.text
        enable = not word.pain
    elseif word then
        text = word
    end
    self.InputSpamWord:Open(text, enable)
end