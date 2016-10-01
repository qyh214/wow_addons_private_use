local ADDONNAME, WIC = ...

-- luacheck: globals LibStub ItemRefTooltip
LibStub("AceAddon-3.0"):NewAddon(WIC, ADDONNAME, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(ADDONNAME)

local _G = _G
local GetTime = GetTime

local find,    split,    lower,    format, len,    join     =
      strfind, strsplit, strlower, format, strlen, strjoin
local type, select, pairs, error, wipe =
      type, select, pairs, error, wipe

-- L["CHAT_MSG_CHANNEL"] = "All Channels"

WIC.RegisteredModules = {}
WIC.RegisteredModulesWithLoadOnDemand = {}
WIC.RegisteredModulesDescription = {}
WIC.RegisteredModulesTranslatedName = {}
WIC.RegisteredModulesList = L["No Modules Registered"]

function WIC:RegisterModule(name, handle, addonName)
    self.RegisteredModules[name] = handle
    if type(addonName) == "string" then
        self.RegisteredModulesWithLoadOnDemand[name] = addonName
    end
end
function WIC:AddTranslatedNameToModule(name, localeName)
    self.RegisteredModulesTranslatedName[name] = localeName
end
function WIC:AddDescriptionToModule(name, description)
    self.RegisteredModulesDescription[name] = description
end


do-- Adding modules
    WIC:RegisterModule("Basic", "WhisperInviteBasic", "WhisperInviteBasic")
    WIC:AddTranslatedNameToModule("Basic", L["Basic"])
    WIC:AddDescriptionToModule("Basic", L["Invite player when they whisper you with a defined keyword."])

    WIC:RegisterModule("Advanced", "WhisperInviteAdvanced", "WhisperInviteAdvanced")
    WIC:AddTranslatedNameToModule("Advanced" ,L["Advanced"])
    WIC:AddDescriptionToModule("Advanced" ,L["Invite player when they whisper you with a defined keyword where they are allowed to use."])


    -- Search for third-party Modules
    -- Add this to your TOC-File:
    --[[
    RequiredDeps: WhisperInvite
    X-WisperInvite-Name: ModuleName
    X-WisperInvite-Handle: AddonName -> used as in LibStub("AceAddon-3.0"):GetAddon(AddonName, true) or Global Variable Name
    X-WisperInvite-Version: Version -> See MODULEVERSION
    X-WisperInvite-Description: Small Description

    LoadOnDemand: 1 -> for when you only want be loaded when needed
    --]]
    --Name and Description supports localization e.g: X-WisperInvite-Description-deDE

    -- Needed functions when not a AceAddon:
    --[[
        Module:Enable()
        Module:Disable()
        Module:IsEnabled()
    --]]
    local tonumber, tinsert =
          tonumber, tinsert
    local GetAddOnInfo, GetAddOnMetadata =
          GetAddOnInfo, GetAddOnMetadata

    local MODULEVERSION = 0
    local locale = GAME_LOCALE or GetLocale()-- luacheck: ignore

    for index=1, GetNumAddOns() do
        local addonName, title, notes, enabled, loadable, reason, security = GetAddOnInfo(index)

        local version = GetAddOnMetadata(addonName, "X-WisperInvite-Version")
        if version and tonumber(version) == MODULEVERSION and loadable then
            local name = GetAddOnMetadata(addonName, "X-WisperInvite-Name")
            local localeName = GetAddOnMetadata(addonName, "X-WisperInvite-Name-"..locale) or name
            local description = GetAddOnMetadata(addonName, "X-WisperInvite-Description-"..locale) or GetAddOnMetadata(addonName, "X-WisperInvite-Description") or L["No description for this module."]
            local handle = GetAddOnMetadata(addonName, "X-WisperInvite-Handle")

            if name and handle then
                WIC:RegisterModule(name, handle, addonName)
                WIC:AddTranslatedNameToModule(name, name)
            end

            if name and localeName then
                WIC:AddTranslatedNameToModule(name, localeName)
            end
            if name and description then
                WIC:AddDescriptionToModule(name, description)
            else
                WIC:AddDescriptionToModule(name, L["No description for this module."])
            end
        end
    end

    local list = {}
    for moduleName in pairs(WIC.RegisteredModules) do
        local name = moduleName--(WIC.RegisteredModulesTranslatedName[name] or name).."<"..name..">"

        tinsert(list, name)
    end
    WIC.RegisteredModulesList = join(", ", unpack(list) )
end

local LF_QUEUE_PVP = "PVP"
local LF_QUEUES = {
    ['**'] = {
        blockInvites = true,
        sendMessage = false,
        returnMessage = L["I'm currently in a LF-Queue"],
    },
    [LF_QUEUE_PVP] = {},
}

for id, name in pairs(LFG_CATEGORY_NAMES) do
    LF_QUEUES[id] = {}
end

local defaults = {
    global = {},
    char = {
        info = {
            ['*'] = 0,
        },
        infoMax = {
            ['*'] = 3,
            setup = 5,
            lfr_block = 9,
        },
    },
    profile = {
        active = true,
        selectedModuleName = false,
        convertGroupToRaid = true,
        inviteThrottleTime = 10, -- seconds

        queueProtection = LF_QUEUES,
        statusProtection = {
            AFK = {
                blockInvites = false,
                sendMessage = false,
                returnMessage = L["I'm currently AFK"],
            },
            DND = {
                blockInvites = false,
                sendMessage = false,
                returnMessage = L["I'm currently DND"],
            },
        },
    },
}

WIC.TYPES = {
    LINK = "whisperinvite",
    H_LINK = "|Hwhisperinvite|h",
}

WIC.LOOKUP_LOCALIZED_CLASS_NAMES = {}

-- TODO: handling of profile.active
function WIC:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WhisperInviteCoreDB", defaults, true)

    self.db.RegisterCallback(self, "OnProfileChanged", "CheckEnabledState")
    self.db.RegisterCallback(self, "OnProfileCopied", "CheckEnabledState")

    self:RegisterConfig()

    -- To enable wisperinvite when disabled
    self:RegisterChatCommand("wisperinviteenable", "Enable", true)
    self:RegisterChatCommand("wienable", "Enable", true)

    self:RegisterChatCommand("wisperinvitedisable", "Disable", true)
    self:RegisterChatCommand("widisable", "Disable", true)

    self:RegisterChatCommand("wi", "CMD", true)
    self:RegisterChatCommand("wisperinvite", "CMD", true)

    -- build localized lookup table for class names
    for class, classLocalized in pairs(_G.LOCALIZED_CLASS_NAMES_MALE) do
        self.LOOKUP_LOCALIZED_CLASS_NAMES[classLocalized] = class
    end
    for class, classLocalized in pairs(_G.LOCALIZED_CLASS_NAMES_FEMALE) do
        self.LOOKUP_LOCALIZED_CLASS_NAMES[classLocalized] = class
    end

    self:SetEnabledState(self.db.profile.active)
    if not self:IsEnabled() and self.db.char.info.enable < self.db.char.infoMax.enable then
        self.db.char.info.enable = self.db.char.info.enable + 1
        self:Print(L["You can run /wienable to enable WisperInvite."])
    end
end

function WIC:Enable_ModuleHandling()
    local showInfo = true
    if type(self.db.profile.selectedModuleName) == "string" then
        local isEnabled = self:EnableSelectedModule()

        if isEnabled or self:SelectModuleIsEnabled() then
            -- Module is registered and enabled
            showInfo = false
        end
    end

    if showInfo then
        if self.db.char.info.setup < self.db.char.infoMax.setup then
            self.db.char.info.setup = self.db.char.info.setup + 1
            self:Print(L["Run /wi modules or /wi options to setup WisperInvite."])
        end
    end
end

function WIC:OnEnable()
    self:Enable_ModuleHandling()

    -- Hooking
    self:SecureHook("ChatFrame_OnHyperlinkShow")
    self:RawHook("HandleModifiedItemClick", true)
    self:RawHook(ItemRefTooltip, "SetHyperlink", "ItemRefTooltip_SetHyperlink", true)
end

function WIC:ItemRefTooltip_SetHyperlink(frame, link, ...)
    if link and find(link, self.TYPES.LINK) then
        return false
    else
        return self.hooks[frame].SetHyperlink(frame, link, ...)
    end
end

function WIC:HandleModifiedItemClick(link, ...)
    if link and find(link, self.TYPES.H_LINK) then
        return false
    else
        return self.hooks.HandleModifiedItemClick(link, ...)
    end
end

function WIC:ChatFrame_OnHyperlinkShow(frame, linkData, link, button, ...)
    if split(":", linkData) == self.TYPES.LINK then
        local _, toonID, toonName, presenceName, presenceID, debug = split(":", linkData)
        --[===[@debug@
        if debug == "DEBUG" then
            self:Printf("Invite: %s(%s), id:%s", toonName, presenceName, toonID)
            return
        end
        --@end-debug@]===]

        local result, code = self:InviteToon(toonID, toonName, presenceName, presenceID)

        --[===[@debug@
        self:Printf("Invite Sent: %s", result and "OK" or "Error: "..code )
        --@end-debug@]===]
    --else
        --self.hooks.ChatFrame_OnHyperlinkShow(frame, linkData, link, button, ...)
    end
end

function WIC:Disable_ModuleHandling()
    self:DisableSelectedModule()
end

function WIC:OnDisable()
    self:Disable_ModuleHandling()
end

function WIC:CheckEnabledState(event, db)
    db = db or self.db
    if db.profile.active then
        --[===[@debug@
        self:Print("Active")
        --@end-debug@]===]
        if not self:IsEnabled() then
            --[===[@debug@
            self:Print("Enable")
            --@end-debug@]===]
            self:Enable()
        else
            --[===[@debug@
            self:Print("Enable->Module")
            --@end-debug@]===]
            self:Enable_ModuleHandling()
        end
    elseif self:IsEnabled() then
        --[===[@debug@
        self:Print("Disable")
        --@end-debug@]===]
        self:Disable()
    end
end

do-- CMD
    local InterfaceOptionsFrame_OpenToCategory, InterfaceOptionsFrameAddOnsListScrollBar =
          InterfaceOptionsFrame_OpenToCategory, InterfaceOptionsFrameAddOnsListScrollBar

    function WIC:CMD(input, editBox)
        --GetArgs(str, numargs, startpos)
        local arg1, lastPos = self:GetArgs(input, 1)
        arg1 = arg1 and lower(arg1) or ""

        if arg1 == "modules" then
            local moduleName = self:GetArgs(input, 1, lastPos)
            if self.RegisteredModules[moduleName] then
                self:SelectModule(moduleName)
            else
                self:Printf(L["Usage: /wi modules moduleName (case sensitive)"])
                self:Printf(L["Modules: %s"], self.RegisteredModulesList )
            end
        elseif arg1 == "enable" or arg1 == "on" or arg1 == L["enable"] or arg1 == L["on"] then
            self.db.profile.active = true
            self:NotifyChange()
            WIC:CheckEnabledState("", self.db)
            self:Print(L["Enabled"])
        elseif arg1 == "disable" or arg1 == "off" or arg1 == L["disable"] or arg1 == L["off"] then
            self.db.profile.active = false
            self:NotifyChange()
            WIC:CheckEnabledState("", self.db)
            self:Print(L["Disabled"])
        elseif arg1 == "toggle" or arg1 == L["toggle"] then
            self.db.profile.active = not self.db.profile.active
            self:NotifyChange()
            WIC:CheckEnabledState("", self.db)
            if self.db.profile.active then
                self:Print(L["Enabled"])
            else
                self:Print(L["Disabled"])
            end
        elseif not arg1 or arg1 == "" or arg1 == "help" or arg1 == "usage" or arg1 == L["help"] or arg1 == L["usage"] then
            self:Print(L["Usage: /wi <command>\nCommands: modules, options"])
        elseif arg1 == "options" or arg1 == "op" then
            -- Load InterfaceOptionsFrameAddOns frame...
            InterfaceOptionsFrame_OpenToCategory(ADDONNAME)

            -- Let's scroll down, so your page can be open
            InterfaceOptionsFrameAddOnsListScrollBar:SetValue(select(2, InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues() ) )
            InterfaceOptionsFrame_OpenToCategory(ADDONNAME)
        else
            LibStub("AceConfigCmd-3.0").HandleCommand(self, "wi", ADDONNAME.."Options", input)
        end
    end
end

function WIC:SelectModule(moduleName)
    if self.RegisteredModules[moduleName] then
        local profile = self.db.profile
        profile.selectedModuleName = moduleName
        if profile.active then
            return self:EnableSelectedModule()
        end
        return true
    end
    return false
end

do-- Module handling
    local IsAddOnLoaded, LoadAddOn =
          IsAddOnLoaded, LoadAddOn

    local oldModule

    function WIC:EnableSelectedModule()
        local name = self.db.profile.selectedModuleName
        local addonName = self.RegisteredModulesWithLoadOnDemand[name]

        if name and addonName then
            if not IsAddOnLoaded(addonName) then
                local loaded, resason = LoadAddOn(self.RegisteredModulesWithLoadOnDemand[name])
                if not loaded then
                    self:Printf(L["Can't load module %s because %s"], name, _G["ADDON_"..resason] or resason)

                    return false, resason
                end
            end


            local handle = self.RegisteredModules[name]
            local selectModule = LibStub("AceAddon-3.0"):GetAddon(handle, true) or _G[handle]
            if selectModule and type(selectModule.Enable) == "function" then
                if oldModule and type(oldModule.Disable) == "function" then
                    oldModule:Disable()
                end

                oldModule = selectModule

                return selectModule:Enable()
            else
                self:Print(not selectModule and L["Module not found."] or L["Module hasn't needed functions."] )
                return false
            end
        else
            self:Printf(L["Can't load module. %s"], (not name and L["No module selected!"] or not addonName and L["Addon name not found!"] or "") )
            return false
        end
    end

    function WIC:SelectModuleIsEnabled()
        local activeModule = oldModule
        if not activeModule then
            local name = self.db.profile.selectedModuleName
            local handle = self.RegisteredModules[name]
            activeModule = LibStub("AceAddon-3.0"):GetAddon(handle, true) or _G[handle]
        end
        if type(activeModule.IsEnabled) == "function" then
            return activeModule:IsEnabled()
        end
        return false
    end
end

function WIC:DisableSelectedModule()
    local name = self.db.profile.selectedModuleName
    --[===[@debug@
    self:Print("Disable Module: ", name)
    --@end-debug@]===]
    if name then
        local handle = self.RegisteredModules[name]
        local selectModule = LibStub("AceAddon-3.0"):GetAddon(handle, true) or _G[handle]

        --[===[@debug@
        self:Print("selectModule: ", selectModule, ", type: ", type(selectModule), ", selectModule.Disable type: ", type(selectModule.Disable))
        --@end-debug@]===]

        if selectModule and type(selectModule.Disable) == "function" then
            selectModule:Disable()
            --[===[@debug@
            self:Print("Module disabled")
            --@end-debug@]===]
        end
    end
end

do-- CanInvite
    local IsInGroup, UnitIsGroupLeader, UnitIsGroupAssistant, GetInstanceInfo =
          IsInGroup, UnitIsGroupLeader, UnitIsGroupAssistant, GetInstanceInfo
    local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

    function WIC:CanInvite()
        --if _G.IsInGroup(_G.LE_PARTY_CATEGORY_INSTANCE) and select(3, _G.GetInstanceInfo() ) ~= 14 then
        --if select(3, _G.GetInstanceInfo() ) ~= 7 then
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            -- we can not invite when in a instance group or can we?
            local _, _, difficultyID = GetInstanceInfo()
            if difficultyID ~= 7  -- LFR
            and difficultyID ~= 17 -- LFR 10-30
            and difficultyID ~= 1  -- Normal
            and difficultyID ~= 2  --[[Heroic]] then
                -- Print infos only a limit time
                if self.db.char.info.lfr_block < self.db.char.infoMax.lfr_block then
                    self:Printf(L["You are in an instance group and not in LFR or LFG group. When you can invite here players let me know it."])
                    local name, instanceType, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize
                    name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = _G.GetInstanceInfo()
                    local info = "instanceType:"..instanceType..", difficultyID:"..difficultyID..", difficultyName:"..difficultyName
                    self:Printf(L["And show me this infos: %s"], info)
                    self.db.char.info.lfr_block = self.db.char.info.lfr_block + 1
                end

                -- hope nothing explodes..
                return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or not IsInGroup()
            end
            return false
        else
            return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or not IsInGroup()
        end
    end
end

do-- CheckGroupSize
    local ConvertToRaid, IsInRaid, GetNumGroupMembers
        = ConvertToRaid, IsInRaid, GetNumGroupMembers
    local LE_PARTY_CATEGORY_HOME, MAX_PARTY_MEMBERS
        = LE_PARTY_CATEGORY_HOME, MAX_PARTY_MEMBERS

    function WIC:CheckGroupSize()
        if not IsInRaid() and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > MAX_PARTY_MEMBERS then
            if self.db.profile.convertGroupToRaid then
                ConvertToRaid()
                return true
            else
                return false
            end
        end

        return true
    end
end

do-- IsQueueProtected / IsStatusProtected
    local BNSendWhisper, SendChatMessage, GetLFGMode, GetMaxBattlefieldID, GetBattlefieldStatus, UnitIsAFK, UnitIsDND, UnitIsUnit, GetCVar, SetCVar =
          BNSendWhisper, SendChatMessage, GetLFGMode, GetMaxBattlefieldID, GetBattlefieldStatus, UnitIsAFK, UnitIsDND, UnitIsUnit, GetCVar, SetCVar

    local function sendReturnMessage(name, presenceID, message)
        if presenceID then
            BNSendWhisper(presenceID, message)
        elseif name and not UnitIsUnit("player", name) then
            SendChatMessage(message, "WHISPER", nil, name)
        end
    end

    function WIC:IsQueueProtected(name, presenceName, presenceID)
        if not name or (name and presenceName and not presenceID) or (name and presenceID and not presenceName) then error("Usage: IsQueueProtected(name) or IsQueueProtected(toonName, presenceName, presenceID") end

        local printName = presenceName and format(L["%s (%s)"], presenceName or L["<No name given>"], name or L["<No toon name given>"]) or name

        -- Look for queue Protection
        for id, data in pairs(self.db.profile.queueProtection) do
            if type(id) == "number" and data.blockInvites then
                local mode = GetLFGMode(id)
                if mode then
                    if data.sendMessage and len(data.returnMessage) > 1 then
                        if presenceID then
                            sendReturnMessage(name, presenceID, data.returnMessage)
                        else
                            sendReturnMessage(name, nil, data.returnMessage)
                        end
                    end

                    self:Printf(L["Your are in a LF-Queue. Can't invite %s"], printName)
                    return true
                end
            elseif id == LF_QUEUE_PVP and data.blockInvites then
                for i=1, GetMaxBattlefieldID() do
                    local status = GetBattlefieldStatus(i)
                    if status ~= "none" then
                        if data.sendMessage and len(data.returnMessage) > 1 then
                            if presenceID then
                                sendReturnMessage(name, presenceID, data.returnMessage)
                            else
                                sendReturnMessage(name, nil, data.returnMessage)
                            end
                        end

                        self:Printf(L["Your are in a LF-Queue. Can't invite %s"], printName)
                        return true
                    end
                end
            end
        end

        return false
    end

    function WIC:IsStatusProtected(name, presenceName, presenceID)
        if not name or (name and presenceName and not presenceID) or (name and presenceID and not presenceName) then error("Usage: IsQueueProtected(name) or IsQueueProtected(toonName, presenceName, presenceID") end

        local printName = presenceName and format(L["%s (%s)"], presenceName or L["<No name given>"], name or L["<No toon name given>"]) or name

        if UnitIsAFK("player") then
            local afkProtection = self.db.profile.statusProtection.AFK

            if afkProtection.sendMessage then
                local returnMessage = afkProtection.returnMessage
                if len(returnMessage) > 1 then
                    local autoClearAFK = GetCVar("autoClearAFK")
                    if autoClearAFK ~= "0" then
                        SetCVar("autoClearAFK", "0")
                    end

                    if presenceID then
                        sendReturnMessage(name, presenceID, returnMessage)
                    else
                        sendReturnMessage(name, nil, returnMessage)
                    end

                    -- re-set autoClearAFK value
                    SetCVar("autoClearAFK", autoClearAFK)
                end
            end

            if afkProtection.blockInvites then
                self:Printf(L["Your are AFK. Invite to %s was not sent."], printName)
                return true
            end
        end
        if UnitIsDND("player") then
            local dndProtection = self.db.profile.statusProtection.DND

            if dndProtection.sendMessage then
                local returnMessage = dndProtection.returnMessage
                if len(returnMessage) > 1 then
                    if presenceID then
                        sendReturnMessage(name, presenceID, returnMessage)
                    else
                        sendReturnMessage(name, nil, returnMessage)
                    end
                end
            end

            if dndProtection.blockInvites then
                self:Printf(L["Your are DND. Haven't send an invite to %s"], printName)
                return true
            end
        end

        return false
    end
end

--- InviteErrorCodeList
-- 1: Player is not allowed to invite other players
-- 2: No BNet/RealID friend is online with this presenceID
-- 3: Invalid parameters
-- 4: Maximal group size reached
-- 5: No WoW toon is online
-- 6: Invite for this key was throttled
-- 7: Invite was blocked because of a LF-Queue or Status (AFK/DND)

do-- InvitePlayer
    local InviteUnit, Ambiguate =
          InviteUnit, Ambiguate

    local playerName_Throttle = {}

    --- Invite player with name
    -- @param (String) name
    -- @return1 (Boolean) true == Invite sent, false == Invite not possible
    -- @return2 (Number) errorCode @see InviteErrorCodeList
    function WIC:InvitePlayer(name)
        if not name then
            return false, 3
        end

        if self:CanInvite() then
            if self:IsQueueProtected(name) or self:IsStatusProtected(name) then
                return false, 7
            elseif self:CheckGroupSize() then
                local time = GetTime()
                if (playerName_Throttle[name] or 0) < time then
                    playerName_Throttle[name] = time + self.db.profile.inviteThrottleTime
                    --_G.InviteUnit( self:UniformPlayerName(name) )
                    InviteUnit( Ambiguate(name, "none") )
                    return true
                else
                    return false, 6
                end
            else
                self:Printf(L["Maximal group size reached. Can't invite %s"], name)
                return false, 4
            end
        else
            return false, 1
        end
    end
end



do-- InviteBNet
    local BNGetFriendIndex, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo, BNGetFriendInfo, UnitFactionGroup =
          BNGetFriendIndex, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo, BNGetFriendInfo, UnitFactionGroup
    local BNET_CLIENT_WOW, RAID_CLASS_COLORS =
          BNET_CLIENT_WOW, RAID_CLASS_COLORS

    local toonCache = {}

    --- Invite player over Battle.net
    -- @paramsig presenceID [, friendIndex]
    -- @paramsig nil, friendIndex
    -- @param (presenceID) presenceID
    -- @param (Number) friendIndex
    -- @return1 (Boolean) true: Invite sent, false: Invite not possible
    -- @return2 (Number) errorCode @see InviteErrorCodeList
    --[===[@debug@
    function WIC:InviteBNet(presenceID, friendIndex, debug)
    --@end-debug@]===]
    --@non-debug@
    function WIC:InviteBNet(presenceID, friendIndex)
    --@end-non-debug@
        if not self:CanInvite() then
            return false, 1
        end

        if type(friendIndex) ~= "number" and presenceID then
            friendIndex = BNGetFriendIndex(presenceID)
            if not friendIndex then
                return false, 2
            end
        elseif type(friendIndex) ~= "number" then
            return false, 3
        end

        local numToons = BNGetNumFriendGameAccounts(friendIndex)
        local toonCount = 0
        for toonIndex=1, numToons do
            local hasFocus, toonName, client, realmName, realmID, faction, race, classLocalized, guild, zoneName, level, gameText, broadcastText, broadcastTime, canSoR, toonID = BNGetFriendGameAccountInfo(friendIndex, toonIndex)
            if client == BNET_CLIENT_WOW then
                toonCount = toonCount + 1
                toonCache[toonCount] = toonCache[toonCount] or {}

                toonCache[toonCount].class = self.LOOKUP_LOCALIZED_CLASS_NAMES[classLocalized] or "WARRIOR"
                toonCache[toonCount].toonID = toonID
                toonCache[toonCount].faction = faction
                toonCache[toonCount].toonName = toonName
                toonCache[toonCount].realmName = realmName

                toonCache[toonCount].presenceID, toonCache[toonCount].presenceName = BNGetFriendInfo(friendIndex)
            end
        end

        --[===[@debug@
        if debug then
            toonCount = 3

            toonCache[1] = toonCache[1] or {}
            toonCache[1].class = "DRUID"
            toonCache[1].toonID = 0
            toonCache[1].faction = "Alliance"
            toonCache[1].toonName = "Areko"
            toonCache[1].realmName = "Alleria"
            toonCache[1].presenceName = "Areko#0000"
            toonCache[1].presenceID = 0

            toonCache[2] = toonCache[2] or {}
            toonCache[2].class = "HUNTER"
            toonCache[2].toonID = 0
            toonCache[2].faction = "Alliance"
            toonCache[2].toonName = "Tânuri"
            toonCache[2].realmName = "Alleria"
            toonCache[2].presenceName = "Tanuri#0000"
            toonCache[2].presenceID = 0

            toonCache[3] = toonCache[3] or {}
            toonCache[3].class = "MAGE"
            toonCache[3].toonID = 0
            toonCache[3].faction = "Horde"
            toonCache[3].toonName = "Keks"
            toonCache[3].realmName = "Alleria"
            toonCache[3].presenceName = "Keks#0000"
            toonCache[3].presenceID = 0
        end
        --@end-debug@]===]

        if toonCount > 0 then
            if toonCount == 1 then
                local toon = toonCache[1]
                return self:InviteToon(toon.toonID, toon.toonName, toon.presenceName, toon.presenceID)
            else
                -- \124 > |
                local linkTemplate = "[|H%s:%s|h%s|h]"
                local colourTemplate = "|c%s%s|r"
                local alliance
                local horde
                local colours = _G.CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

                for i=1,toonCount do
                    local toon = toonCache[i]

                    local linkData = toon.toonID..":"..toon.toonName..":"..toon.presenceName..":"..toon.presenceID
                    local name = self:UniformPlayerName(toon.toonName, toon.realmName)
                    local colour = colours[toon.class].colorStr or "FFFFFFFF"
                    --[===[@debug@
                    if debug then
                        linkData = linkData..":DEBUG"
                    end
                    --@end-debug@]===]

                    local msg = format(colourTemplate, colour, format(linkTemplate, self.TYPES.LINK, linkData, name) )

                    if toon.faction == "Horde" then
                        horde = horde and horde..", "..msg or msg
                    elseif toon.faction == "Alliance" then
                        alliance = alliance and alliance..", "..msg or msg
                    else
                        horde = horde and horde..", "..msg or msg
                        alliance = alliance and alliance..", "..msg or msg
                    end
                end

                local factionGroup = UnitFactionGroup("player")
                self:Printf(L["%s is with more then one toon online. Choose which toons should be invited. Click on the name to invite."], toonCache[1].presenceName )

                if factionGroup == "Alliance" then
                    if alliance then
                        self:Printf(L["Alliance toons: %s"], alliance )
                    end
                    if horde then
                        self:Printf(L["Horde toons: %s"], horde )
                    end
                else
                    if horde then
                        self:Printf(L["Horde toons: %s"], horde )
                    end
                    if alliance then
                        self:Printf(L["Alliance toons: %s"], alliance )
                    end
                end

                return true, toonCount
            end
        else
            local _, presenceName = BNGetFriendInfo(friendIndex)
            self:Printf(L["%s is not online in World of Warcraft."], presenceName)
            return false, 5
        end
    end
end

do-- InviteToon
    local BNInviteFriend = BNInviteFriend

    local battleNet_Throttle = {}

    function WIC:InviteToon(toonID, toonName, presenceName, presenceID)
        if not toonID then
            return false, 3
        end

        if self:IsQueueProtected(toonName, presenceName, presenceID) or self:IsStatusProtected(toonName, presenceName, presenceID) then
            return false, 7
        elseif self:CheckGroupSize() then
            local time = GetTime()
            if (battleNet_Throttle[toonID] or 0) < time then
                battleNet_Throttle[toonID] = time + self.db.profile.inviteThrottleTime
                BNInviteFriend( toonID )
                return true
            else
                return false, 6
            end
        else
            self:Printf(L["Maximal group size reached. Can't invite %s"], format(L["%s (%s)"], presenceName or L["<No name given>"], toonName or L["<No toon name given>"]) )
            return false, 4
        end
    end
end

--- Returns uniformed player or guild name
-- @paramsig playerName [, realmOverride]
-- @param (String) playerName/guildName
-- @param (String, optional) realmOverride
--
-- @return "Name-Realm", "Name", "Realm"
do
    local homeRealm = GetRealmName()
    local dash = "-"
    function WIC:UniformPlayerName(playerName, realmOverride)
        local name = playerName
        local realm = homeRealm

        if find(playerName, dash) then
            name, realm = split(dash, playerName, 2)
        end

        realm = realmOverride or realm

        return name..dash..realm, name, realm
    end

    function WIC:UniformGuildName(guildName, realmOverride)
        -- same as player
        return self:UniformPlayerName(guildName, realmOverride)
    end
end

local optionHandler = {}
function optionHandler:Set(info, value, ...)
    local name = info[#info]
    WIC.db.profile[name] = value
end

function optionHandler:Get(info, value, ...)
    local name = info[#info]
    return WIC.db.profile[name]
end

function optionHandler:SetActive(info, value, ...)
    self:Set(info, value, ...)
    WIC:CheckEnabledState("", WIC.db)
end

function optionHandler:SetModule(info, value, ...)
    self:Set(info, value, ...)
    if WIC:IsEnabled() then
        WIC:EnableSelectedModule()
    end
end
function optionHandler:SetQueue(info, value, ...)
    local name = info[#info]

    WIC.db.profile.queueProtection[info.arg][name] = value
end
function optionHandler:GetQueue(info, value, ...)
    local name = info[#info]

    return WIC.db.profile.queueProtection[info.arg][name]
end
function optionHandler:SetStatus(info, value, ...)
    local name = info[#info]

    WIC.db.profile.statusProtection[info.arg][name] = value
end
function optionHandler:GetStatus(info, value, ...)
    local name = info[#info]

    return WIC.db.profile.statusProtection[info.arg][name]
end
function optionHandler:IsReturnMessageHidden(info)
    return not WIC.db.profile.queueProtection[info.arg].sendMessage
end

local options = {
    type = "group",
    name = L["WisperInvite Core Settings"],
    handler = optionHandler,
    set = "Set",
    get = "Get",
    args = {
        active = {
            type = "toggle",
            name = L["Active"],
            desc = L["Is this profile enabled."],
            width = "full",
            set = "SetActive",
            order = 1,
        },
        selectedModuleName = {
            type = "select",
            name = L["Active module"],
            desc = L["Choose active module."],
            values = WIC.RegisteredModulesTranslatedName,
            set = "SetModule",
            order = 2,
        },
        convertGroupToRaid = {
            type = "toggle",
            name = L["Auto convert"],
            desc = L["Convert group to raid when group has reached maximal size."],
            width = "full",
            order = 3,
        },
        inviteThrottleTime = {
            type = "range",
            name = L["Invite Throttle"],
            desc = L["Delay(seconds) needed between to invites of the same player before, WhisperInvite can send a new invite."],
            min = 0.5,
            max = 120,
            softMin = 6,
            softMax = 30,
            bigStep = 1,
            step = 0.1,
            --width = "full",
            order = 4,
        },
        statusProtection = {
            type = "group",
            inline = true,
            name = L["AFK/DND Protection"],
            set = "SetStatus",
            get = "GetStatus",
            args = {
                descriptionText = {
                    type = "description",
                    name = L["Choose when you don't want to automatic invite other players when you are AFK or DND.\nAnd if to send a message."],
                    fontSize = "normal",
                    order = 0,
                },
                AFK = {
                    type = "group",
                    name = DEFAULT_AFK_MESSAGE,
                    inline = true,
                    args = {
                        blockInvites = {
                            type = "toggle",
                            name = L["Block invites"],
                            desc = L["Block invites when you are AFK"],
                            arg = "AFK",
                            order = 1,
                        },
                        sendMessage = {
                            type = "toggle",
                            name = L["Send an answer"],
                            desc = L["Send a message to inform that you are AFK."],
                            arg = "AFK",
                            order = 2,
                        },
                        returnMessage = {
                            type = "input",
                            name = L["Answer"],
                            desc = L["The message you will send."],
                            width = "full",
                            arg = "AFK",
                            order = 3,
                        },
                    },
                },
                DND = {
                    type = "group",
                    name = DEFAULT_DND_MESSAGE,
                    inline = true,
                    args = {
                        blockInvites = {
                            type = "toggle",
                            name = L["Block invites"],
                            desc = L["Block invites when you are DND"],
                            arg = "DND",
                            order = 1,
                        },
                        sendMessage = {
                            type = "toggle",
                            name = L["Send an answer"],
                            desc = L["Send a message to inform that you are DND."],
                            arg = "DND",
                            order = 2,
                        },
                        returnMessage = {
                            type = "input",
                            name = L["Answer"],
                            desc = L["The message you will send."],
                            width = "full",
                            arg = "DND",
                            order = 3,
                        },
                    },
                },
            },
        },
        queueProtection = {
            type = "group",
            inline = true,
            name = L["LF-Queue Protection"],
            set = "SetQueue",
            get = "GetQueue",
            args = {},
        },
    },
}

local updateConfig
do-- updateConfig
    local LFG_CATEGORY_NAMES, QUEUED_STATUS_UNKNOWN, PVP =
          LFG_CATEGORY_NAMES, QUEUED_STATUS_UNKNOWN, PVP

    function updateConfig()
        local args = wipe(options.args.queueProtection.args)
        for id in pairs(WIC.db.profile.queueProtection) do
            local name
            if type(id) == "number" then
                name = LFG_CATEGORY_NAMES[id] or QUEUED_STATUS_UNKNOWN
            else
                name = PVP
            end

            args[name] = {
                type = "group",
                name = name,
                inline = true,
                args = {
                    blockInvites = {
                        type = "toggle",
                        name = L["Block invites"],
                        desc = format(L["When in the %q Queue block invites."], name),
                        arg = id,
                        order = 1,
                    },
                    sendMessage = {
                        type = "toggle",
                        name = L["Send an answer"],
                        desc = L["Send a message to inform that you have not send an invite because your are in a LF-Queue."],
                        arg = id,
                        order = 2,
                    },
                    returnMessage = {
                        type = "input",
                        name = L["Answer"],
                        desc = L["The message you will send."],
                        arg = id,
                        --hidden = "IsReturnMessageHidden",
                        width = "full",
                        order = 3,
                    },
                },
            }
        end
        args.descriptionText = {
            type = "description",
            name = L["Choose when you don't want to automatic invite other players when you are in a LF-Queue.\n"],
            fontSize = "normal",
            order = 0,
        }
    end
end

local configIsRegistered = false
local unregisteredConfigs = {}
function WIC:RegisterConfig()

    updateConfig()

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ADDONNAME.."Options", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDONNAME.."Options", ADDONNAME)

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ADDONNAME.."Profile", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) )
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDONNAME.."Profile", L["Profile"], ADDONNAME)

    configIsRegistered = true
    for appName, name in pairs(unregisteredConfigs) do
        self:AddModuleConfig(appName, name)
    end
    wipe(unregisteredConfigs)
end

--- Use to register your DB as namespace of the core DB
-- @param (String) name
-- @param (table) defaults
function WIC:RegisterNamespace(name, namespaceDefaults)
    if type(namespaceDefaults) ~= "table" then
        namespaceDefaults = nil
    end
    return self.db:RegisterNamespace(name, namespaceDefaults)
end

--- Add your config to BlizzOptions as child of WhisperInvite
-- @param (String) appName - same as used in AceConfigRegistry:RegisterOptionsTable()
-- @param (String) name - Display name
function WIC:AddModuleConfig(appName, name)
    if configIsRegistered then
        if appName and LibStub("AceConfigRegistry-3.0"):GetOptionsTable(appName) then
            LibStub("AceConfigDialog-3.0"):AddToBlizOptions(appName, name or appName, ADDONNAME)
            return true
        else
            return false
        end
    else
        unregisteredConfigs[appName] = name or appName
    end
end

function WIC:NotifyChange()
    LibStub("AceConfigRegistry-3.0"):NotifyChange(ADDONNAME.."Options")
end
