--[[
@Date    : 2016-06-21 18:53:39
@Author  : DengSir (ldz5@qq.com)
@Link    : https://dengsir.github.io
@Version : $Id$
]]

BuildEnv(...)

AppWhisper = Addon:NewModule('AppWhisper', 'AceEvent-3.0', 'AceHook-3.0', 'LibInvoke-1.0')

function AppWhisper:OnInitialize()
    local r, g, b = Profile:GetChatGroupColor('APP_WHISPER')

    _G.APP_WHISPER = '随身集合石密语'
    _G.CHAT_FLAG_APP = '<App>'
    _G.CHAT_APP_WHISPER_GET = _G.CHAT_WHISPER_GET
    _G.CHAT_APP_WHISPER_INFORM_GET = _G.CHAT_WHISPER_INFORM_GET


    CHAT_INVERTED_CATEGORY_LIST['APP_WHISPER'] = 'WHISPER'
    CHAT_INVERTED_CATEGORY_LIST['APP_WHISPER_INFORM'] = 'WHISPER'

    ADDON_INVERTED_CATEGORY_LIST = {}
    ADDON_INVERTED_CATEGORY_LIST['CHAT_MSG_APP_WHISPER'] = 'APP_WHISPER'
    ADDON_INVERTED_CATEGORY_LIST['CHAT_MSG_APP_WHISPER_INFORM'] = 'APP_WHISPER'

    ChatTypeInfo['APP_WHISPER'] = { sticky = 1, flashTab = true, flashTabOnGeneral = true, colorNameByClass = false, id = 101, r = r, g = g, b = b }
    ChatTypeInfo['APP_WHISPER_INFORM'] = ChatTypeInfo['APP_WHISPER']

    ChatTypeGroup['APP_WHISPER'] = {
        'CHAT_MSG_APP_WHISPER',
        'CHAT_MSG_APP_WHISPER_INFORM',
    }

    tinsert(CHAT_CONFIG_CHAT_LEFT, {
        type = 'APP_WHISPER',
        noClassColor = true,
        checked = function () return IsListeningForMessageType('APP_WHISPER'); end;
        func = function (_, checked) ToggleChatMessageGroup(checked, 'APP_WHISPER'); end;
    })

    local function privateHookFactory(func)
        return function(chatFrame, chatTarget)
            if not chatTarget or not chatTarget:find('-', nil, true) then
                return
            end
            return _G[func](chatFrame, ChatTargetSystemToApp(chatTarget))
        end
    end

    self:SecureHook('ChangeChatColor')
    self:SecureHook('ChatFrame_AddMessageGroup')
    self:SecureHook('ChatFrame_RemoveMessageGroup')
    self:SecureHook('ChatFrame_RemoveAllMessageGroups')

    self:SecureHook('ChatFrame_AddPrivateMessageTarget', privateHookFactory('ChatFrame_AddPrivateMessageTarget'))
    self:SecureHook('ChatFrame_RemovePrivateMessageTarget', privateHookFactory('ChatFrame_RemovePrivateMessageTarget'))
    self:SecureHook('ChatFrame_ExcludePrivateMessageTarget', privateHookFactory('ChatFrame_ExcludePrivateMessageTarget'))
    self:SecureHook('ChatFrame_RemoveExcludePrivateMessageTarget', privateHookFactory('ChatFrame_RemoveExcludePrivateMessageTarget'))

    self:RawHook('FCFManager_ShouldSuppressMessage', true)
    self:RawHook('FCFManager_GetNumDedicatedFrames', true)
    self:RawHook('FCFManager_ShouldSuppressMessageFlash', true)

    self:RawHook('FCF_OpenNewWindow', true)
    self:SecureHook('FCF_ResetChatWindows')
    self:SecureHook('ChatEdit_UpdateHeader')

    ---- Tell target fixed
    self.lastTellTarget = {}
    self:SecureHook('ChatEdit_OnEnterPressed')
    self:SecureHook('ChatEdit_SendText')
end

function AppWhisper:OnEnable()
    self:InitChatGroup()
    ChatConfig_CreateCheckboxes(
        ChatConfigChatSettingsLeft,
        CHAT_CONFIG_CHAT_LEFT,
        'ChatConfigCheckBoxWithSwatchAndClassColorTemplate',
        PLAYER_MESSAGES
    )
end

function AppWhisper:InitChatGroup()
    for i, v in ipairs(CHAT_FRAMES) do
        local chatFrame = _G[v]
        if chatFrame then
            if Profile:IsChatGroupListening(chatFrame:GetID(), 'APP_WHISPER') then
                _G.ChatFrame_AddMessageGroup(chatFrame, 'APP_WHISPER')
            end
        end
    end
end

function AppWhisper:MakeAppWhisper(event, msg, target)
    local chatGroup = ADDON_INVERTED_CATEGORY_LIST[event]
    for i, v in ipairs(CHAT_FRAMES) do
        local chatFrame = _G[v]
        if chatGroup and Profile:IsChatGroupListening(chatFrame:GetID(), chatGroup) or chatFrame:IsEventRegistered(event) then
            chatFrame:GetScript('OnEvent')(chatFrame, event, msg, target, '', '', '', 'APP', 0, 0, '', 0, 0, nil, 0)

            if strsub(event, 10) == 'APP_WHISPER' then
                ChatEdit_SetLastTellTarget(target, 'WHISPER')
                if chatFrame.tellTimer and GetTime() > chatFrame.tellTimer then
                    PlaySound(SOUNDKIT and SOUNDKIT.TELL_MESSAGE or 'TellMessage')
                end
                chatFrame.tellTimer = GetTime() + CHAT_TELL_ALERT_TIME
                FlashClientIcon()
            end
        end
    end

    if chatGroup ~= 'APP_WHISPER' then
        return
    end

    local chatGroup   = 'WHISPER'
    local chatTarget  = ChatTargetAppToSystem(target)
    local whisperMode = GetCVar('whisperMode')

    if (whisperMode == 'popout' or whisperMode == 'popout_and_inline') and FCFManager_GetNumDedicatedFrames(chatGroup, chatTarget) == 0 then
        local chatFrame = FCF_OpenTemporaryWindow(chatGroup, chatTarget)
        chatFrame:GetScript('OnEvent')(chatFrame, event, msg, target, '', '', '', 'APP', 0, 0, '', 0, 0, nil, 0)
        chatFrame.editBox:SetAttribute('tellTarget', target)

        if event == 'CHAT_MSG_APP_WHISPER_INFORM' and whisperMode == 'popout' then
            FCF_SelectDockFrame(chatFrame)
            FCF_FadeInChatFrame(chatFrame)
        end
    end

    if event == 'CHAT_MSG_APP_WHISPER_INFORM' and whisperMode == 'popout_and_inline' then
        FCFManager_StopFlashOnDedicatedWindows(chatGroup, chatTarget);
    end
end

function AppWhisper:ChatFrame_AddMessageGroup(chatFrame, group)
    if group == 'APP_WHISPER' then
        Profile:ToggleChatGroupListening(chatFrame:GetID(), group, true)
    elseif group == 'WHISPER' and chatFrame:GetID() > 10 then
        _G.ChatFrame_AddMessageGroup(chatFrame, 'APP_WHISPER')
    end
end

function AppWhisper:ChatFrame_RemoveMessageGroup(chatFrame, group)
    if group == 'APP_WHISPER' then
        Profile:ToggleChatGroupListening(chatFrame:GetID(), group, false)
    elseif group == 'WHISPER' and chatFrame:GetID() > 10 then
        _G.ChatFrame_RemoveMessageGroup(chatFrame, 'APP_WHISPER')
    end
end

function AppWhisper:ChatFrame_RemoveAllMessageGroups(chatFrame)
    Profile:ToggleChatGroupListening(chatFrame:GetID(), 'APP_WHISPER', false)
end

function AppWhisper:FCFManager_ShouldSuppressMessage(chatFrame, chatType, chatTarget)
    return self.hooks.FCFManager_ShouldSuppressMessage(chatFrame, chatType, ChatTargetAppToSystem(chatTarget))
end

function AppWhisper:FCFManager_ShouldSuppressMessageFlash(chatFrame, chatType, chatTarget)
    return self.hooks.FCFManager_ShouldSuppressMessageFlash(chatFrame, chatType, ChatTargetAppToSystem(chatTarget))
end

function AppWhisper:FCFManager_GetNumDedicatedFrames(chatType, chatTarget)
    return self.hooks.FCFManager_GetNumDedicatedFrames(chatType, ChatTargetAppToSystem(chatTarget))
end

function AppWhisper:ChangeChatColor(type, r, g, b)
    if type ~= 'APP_WHISPER' then
        return
    end

    local info = ChatTypeInfo[type]
    info.r, info.g, info.b = r, g, b

    Profile:SetChatGroupColor(type, r, g, b)

    for i, v in ipairs(CHAT_FRAMES) do
        local frame = _G[v]
        frame:GetScript('OnEvent')(frame, 'UPDATE_CHAT_COLOR', 'APP_WHISPER', r, g, b)
    end
end

function AppWhisper:FCF_OpenNewWindow(...)
    local chatFrame = self.hooks.FCF_OpenNewWindow(...)
    if chatFrame then
        _G.ChatFrame_AddMessageGroup(chatFrame, 'APP_WHISPER')
    end
    return chatFrame
end

function AppWhisper:FCF_ResetChatWindows()
    Profile:ResetChatWindows()
    self:InitChatGroup()
end

function AppWhisper:ChatEdit_UpdateHeader(editBox)
    local chatType = editBox:GetAttribute('chatType')
    local target = editBox:GetAttribute('tellTarget')

    if chatType == 'WHISPER' and IsChatTargetApp(target) then
        local r, g, b = Profile:GetChatGroupColor('APP_WHISPER')
        editBox.header:SetTextColor(r, g, b)
        editBox.headerSuffix:SetTextColor(r, g, b)

        editBox:SetTextColor(r, g, b)
        editBox.focusLeft:SetVertexColor(r, g, b)
        editBox.focusRight:SetVertexColor(r, g, b)
        editBox.focusMid:SetVertexColor(r, g, b)
    end
end

function AppWhisper:ChatEdit_SendText(editBox)
    local chatFrame = editBox:GetParent()
    if not chatFrame then
        return
    end
    if not chatFrame.isTemporary or chatFrame.chatType == 'PET_BATTLE_COMBAT_LOG' then
        return
    end
    self.lastTellTarget[chatFrame:GetID()] = editBox:GetAttribute('tellTarget')
end

function AppWhisper:ChatEdit_OnEnterPressed(editBox)
    local chatFrame = editBox:GetParent()
    if not chatFrame.isTemporary or chatFrame.chatType == 'PET_BATTLE_COMBAT_LOG' then
        return
    end
    local tellTarget = self.lastTellTarget[chatFrame:GetID()]
    if tellTarget and tellTarget ~= editBox:GetAttribute('tellTarget') then
        editBox:SetAttribute('tellTarget', tellTarget)
    end
end
