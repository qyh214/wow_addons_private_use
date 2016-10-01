
BuildEnv(...)

DataBroker = Addon:NewModule('DataBroker', 'AceEvent-3.0')

local ICON1 = [[|TInterface\AddOns\MeetingStone\Media\DataBroker:12:12:0:0:128:32:0:32:0:32|t]]
local ICON2 = [[|TInterface\AddOns\MeetingStone\Media\DataBroker:12:12:0:0:128:32:32:65:0:32|t]]
local TEXT_FORMAT = format('%s %%d   %s %%d', ICON1, ICON2)

function DataBroker:OnInitialize()
    self.db = Profile:GetCharacterDB()
    local LDB = LibStub('LibDataBroker-1.1')
    local BrokerObject = LDB:NewDataObject('MeetingStone', {
        type = 'data source',
        icon = ADDON_LOGO,

        OnEnter = function(owner)
            local anchor = owner:GetBottom() < GetScreenHeight() / 2 and 'ANCHOR_TOP' or 'ANCHOR_BOTTOM'
            GameTooltip:SetOwner(owner, anchor)
            GameTooltip:SetText(L['集合石'])
            if C_LFGList.GetActiveEntryInfo() then
                GameTooltip:AddDoubleLine(ICON1 .. L['申请人数'], C_LFGList.GetNumApplicants(), 1, 1, 1, 1, 1, 1)
            else
                GameTooltip:AddDoubleLine(ICON1 .. L['申请中活动'], C_LFGList.GetNumApplications(), 1, 1, 1, 1, 1, 1)
            end
            local item = BrowsePanel:GetCurrentActivity()
            local label = item and format(L['“%s”总数'], item.text) or L['活动总数']
            GameTooltip:AddDoubleLine(ICON2 .. label, self.activityCount or 0, 1, 1, 1, 1, 1, 1)
            GameTooltip:Show()
        end,

        OnLeave = function()
            GameTooltip:Hide()
        end,

        OnClick = function(owner, button)
            GameTooltip:Hide()
            if button == 'RightButton' then
                -- GUI:ToggleMenu(owner, self:CreateMenuTable())
            else
                Addon:Toggle()
            end
        end
    })

    local BrokerPanel = LibStub('LibWindow-1.1'):Embed(CreateFrame('Button', nil, UIParent)) do
        BrokerPanel:SetSize(150, 26)
        BrokerPanel:SetToplevel(true)
        BrokerPanel:SetFrameStrata('HIGH')
        BrokerPanel:SetClampedToScreen(true)
        BrokerPanel:SetBackdrop{
            bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
            edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
            edgeSize = 16, tileSize = 16, tile = true,
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        }
        BrokerPanel:SetBackdropColor(0, 0, 0, 0.3)
        BrokerPanel:SetBackdropBorderColor(1, 0.82, 0)
        if BrokerObject.OnEnter then
            BrokerPanel:SetScript('OnEnter', BrokerObject.OnEnter)
            BrokerPanel:SetScript('OnLeave', BrokerObject.OnLeave)
        end
        if BrokerObject.OnClick then
            BrokerPanel:SetScript('OnClick', BrokerObject.OnClick)
            BrokerPanel:RegisterForClicks('anyUp')
        end
        BrokerPanel:RegisterConfig(self.db.profile.settings.storage)
        BrokerPanel:MakeDraggable()
        BrokerPanel:RestorePosition()
    end

    local BrokerIcon = BrokerPanel:CreateTexture(nil, 'ARTWORK') do
        BrokerIcon:SetSize(20, 20)
        BrokerIcon:SetPoint('LEFT', 5, 0)
    end

    local BrokerText = BrokerPanel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight') do
        BrokerText:SetPoint('CENTER', 0, 0)
        BrokerText:SetText(BrokerObject.text)
    end

    local BrokerFlash = GUI:GetClass('AlphaFlash'):New(BrokerPanel) do
        BrokerFlash:Hide()
        BrokerFlash:SetPoint('BOTTOM', 0, 2)
        BrokerFlash:SetPoint('LEFT')
        BrokerFlash:SetPoint('RIGHT')
        BrokerFlash:SetHeight(30)
        BrokerFlash:SetTexture([[INTERFACE\CHATFRAME\ChatFrameTab-NewMessage]])
        BrokerFlash:SetVertexColor(1.00, 0.89, 0.18)
        BrokerFlash:SetBlendMode('ADD')
    end

    self.BrokerIcon = BrokerIcon
    self.BrokerObject = BrokerObject
    self.BrokerPanel = BrokerPanel
    self.BrokerText = BrokerText
    self.BrokerFlash = BrokerFlash

    LDB.RegisterCallback(self, 'LibDataBroker_AttributeChanged_MeetingStone', 'OnDataBrokerChanged')
    LibStub('LibDBIcon-1.0'):Register('MeetingStone', BrokerObject, self.db.profile.minimap)

    BrokerObject.text = L['集合石']
    BrokerObject.icon = [[Interface\AddOns\MeetingStone\Media\Mark\0]]

    self:RegisterEvent('LFG_LIST_APPLICATION_STATUS_UPDATED', 'UpdateLabel')
    self:RegisterEvent('LFG_LIST_APPLICANT_LIST_UPDATED')
    self:RegisterEvent('LFG_LIST_APPLICANT_UPDATED')
    self:RegisterMessage('MEETINGSTONE_NEW_VERSION')
    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_COUNT_UPDATED')
    self:RegisterMessage('MEETINGSTONE_SETTING_CHANGED')
end

function DataBroker:MEETINGSTONE_SETTING_CHANGED(_, key, value, onUser)
    if key == 'panel' then
        self.BrokerPanel:SetShown(value)
    elseif key == 'panelLock' then
        self.BrokerPanel:SetMovable(not value)
        if value then
            self.BrokerPanel:SetScript('OnDragStart', nil)
            self.BrokerPanel:SetScript('OnDragStop', nil)
        else
            self.BrokerPanel:MakeDraggable()
        end
    elseif key == 'sound' then
        self:SetMinimapButtonSound(value)
    elseif key == 'ignore' then
        if value then
            Addon:EnableModule('Misc')
        else
            Addon:DisableModule('Misc')
        end
        IgnoreList_Update()
    elseif key == 'spamWord' then
        self:SendMessage('MEETINGSTONE_SPAMWORD_STATUS_UPDATE', value, onUser)
    end
end


function DataBroker:MEETINGSTONE_NEW_VERSION(_, _, _, isSupport)
    if not isSupport then
        self:UnregisterAllEvents()
        self:UnregisterAllMessages()
        self.BrokerObject.text = L['发现新版本']
    end
end

function DataBroker:OnDataBrokerChanged(_, name, key, value, object)
    if key == 'text' then
        self.BrokerText:SetText(value)
    elseif key == 'flash' then
        self.BrokerFlash:SetShown(value)
    elseif key == 'icon' then
        self.BrokerIcon:SetTexture(value)
    end
end

function DataBroker:MEETINGSTONE_ACTIVITIES_COUNT_UPDATED(_, count)
    self.activityCount = count
    self:UpdateLabel()
end

function DataBroker:LFG_LIST_APPLICANT_LIST_UPDATED(_, hasNewPending, hasNewPendingWithData)
    if hasNewPending and hasNewPendingWithData and IsActivityManager() then
        self:SetMinimapButtonGlow(not ApplicantPanel:IsVisible())
        FlashClientIcon()
    end
    self:UpdateLabel()
end

function DataBroker:LFG_LIST_APPLICANT_UPDATED()
    if select(2, C_LFGList.GetNumApplicants()) == 0 then
        self:SetMinimapButtonGlow(false)
    end
    self:UpdateLabel()
end

function DataBroker:UpdateLabel()
    if C_LFGList.GetActiveEntryInfo() then
        self.BrokerObject.text = format(TEXT_FORMAT, select(2, C_LFGList.GetNumApplicants()), self.activityCount or 0)
    else
        self.BrokerObject.text = format(TEXT_FORMAT, select(2, C_LFGList.GetNumApplications()), self.activityCount or 0)
    end
end

function DataBroker:SetMinimapButtonGlow(enable)
    QueueStatusMinimapButton_SetGlowLock(QueueStatusMinimapButton, 'lfglist-applicant', enable)
end

local org_OnLoop = QueueStatusMinimapButton.EyeHighlightAnim:GetScript('OnLoop')
function DataBroker:SetMinimapButtonSound(enable)
    QueueStatusMinimapButton.EyeHighlightAnim:SetScript('OnLoop', enable and org_OnLoop or nil)
end