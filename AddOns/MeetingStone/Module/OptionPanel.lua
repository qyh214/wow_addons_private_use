
BuildEnv(...)

local SettingPanel = Addon:NewModule(CreateFrame('Frame', nil, MainPanel), 'SettingPanel', 'AceEvent-3.0')

local BINDING_KEY = 'MEETINGSTONE_TOGGLE'

function SettingPanel:OnInitialize()
    GUI:Embed(self, 'Owner')
    MainPanel:RegisterPanel(L['设置'], self, 0, 70)

    self.db = Profile:GetCharacterDB()

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
                order = 1,
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
                order = 3,
            },
            panelLock = {
                type = 'toggle',
                name = L['锁定悬浮窗'],
                width = 'full',
                order = 4,
                disabled = function()
                    return not self.db.profile.settings.panel
                end
            },
            sound = {
                type = 'toggle',
                name = L['启用活动申请提示音'],
                width = 'full',
                order = 5,
            },
            ignore = {
                type = 'toggle',
                name = L['启用屏蔽列表增强'],
                width = 'full',
                order = 6,
            },
            key = {
                type = 'keybinding',
                name = L['打开/关闭集合石组团按键设置'],
                width = 'full',
                order = 8,
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
                order = 9,
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
    group.frame:SetSize(400, 300)
    group.frame:Show()
    group:SetCallback('OnShow', function()
        LibStub('AceConfigDialog-3.0'):Open('MeetingStone', group)
    end)
    group:SetCallback('OnHide', function()
        group:ReleaseChildren()
    end)

    LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable('MeetingStone', options)
end
