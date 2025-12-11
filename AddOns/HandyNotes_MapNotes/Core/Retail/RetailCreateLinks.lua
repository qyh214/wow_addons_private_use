local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local CaCLFrame

local function hasPotentialLink(text)
    return text:find("http[%w]*://")
        or text:find("www%.")
        or text:find("%S+@%S+%.%a%a")
        or text:find("%f[%a%d][%w_.%-]+%.%a%a")
end

local function formatURL(url)
    return "|cff00ccff|Hurl:" .. url .. "|h" .. url .. "|h|r"
end

local function processMessage(text)
    local result, pos, textLen = "", 1, #text
    while pos <= textLen do
        local s, e, link
        s, e, link = text:find("(%a[%w+.-]+://%S+)", pos) -- protocol
        if not s then
            s, e, link = text:find("(www%S+)", pos) -- www
        end
        if not s then
            s, e, link = text:find("(%S+@[%w_.%-]+%.%a%a+)", pos) --  email
        end
        if not s then
            s, e, link = text:find("([-%w_%.]+%.%a%a+%S*)", pos) -- short
        end
        if s then
            result = result .. text:sub(pos, s - 1) .. formatURL(link)
            pos = e + 1
        else
            result = result .. text:sub(pos)
            break
        end
    end
    return result
end

local function makeClickable(self, event, msg, ...)
    if event == "CHAT_MSG_CHANNEL" then
        local channelName = select(4, ...)
        if type(channelName) == "string" and channelName:lower():find("dienste") then
            return false, msg, ...
        end
    end
    if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.CreateAndCopyLinks and hasPotentialLink(msg) then
        msg = processMessage(msg)
    end
    return false, msg, ...
end

local function RegisterAllChatFilters()
    local skip = {
        COMBAT_LOG = true,
        BG_SYSTEM_ALLIANCE = true,
        BG_SYSTEM_HORDE = true,
        BG_SYSTEM_NEUTRAL = true,

        MONSTER_SAY = true,
        MONSTER_YELL = true,
        MONSTER_EMOTE = true,
        MONSTER_WHISPER = true,

        SYSTEM = true,
        ACHIEVEMENT = true,
        LOOT = true,
        CURRENCY = true,
        MONEY = true,
        SKILL = true,
        IGNORED = true,
        TARGETICONS = true,
    }

    if ChatTypeInfo then
        for chatType in pairs(ChatTypeInfo) do
            if not skip[chatType] then
                ChatFrame_AddMessageEventFilter("CHAT_MSG_" .. chatType, makeClickable)
            end
        end
    end

    local must = {
        "CHAT_MSG_SAY",
        "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
        "CHAT_MSG_YELL",
        "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_BN_WHISPER",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_COMMUNITIES_CHANNEL",
    }
    for _, ev in ipairs(must) do
        ChatFrame_AddMessageEventFilter(ev, makeClickable)
    end
end

local function UnregisterAllChatFilters()
    if ChatTypeInfo then
        for chatType in pairs(ChatTypeInfo) do
            ChatFrame_RemoveMessageEventFilter("CHAT_MSG_" .. chatType, makeClickable)
        end
    end
    local must = {
        "CHAT_MSG_SAY",
        "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
        "CHAT_MSG_YELL",
        "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_BN_WHISPER",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_COMMUNITIES_CHANNEL",
    }
    for _, ev in ipairs(must) do
        ChatFrame_RemoveMessageEventFilter(ev, makeClickable)
    end
end

local function AddMessage(self, text, ...)
  if not self._OriginalAddMessage then return end

  if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.CreateAndCopyLinks then
    if text and not text:find("|Hurl:") then
        if ns.questID then
            local pat = "(https://www%.wowhead%.com/quest=" .. ns.questID .. ")"
            text = text:gsub(pat, "|cff00ccff|Hurl:%1|h%1|h|r")
        end
    
        if ns.questIDs and ns.questIDs ~= ns.questID then
            local pat = "(https://www%.wowhead%.com/quest=" .. ns.questIDs .. ")"
            text = text:gsub(pat, "|cff00ccff|Hurl:%1|h%1|h|r")
        end
    
        if ns.achievementID then
            local pat = "(https://www%.wowhead%.com/achievement=" .. ns.achievementID .. ")"
            text = text:gsub(pat, "|cff00ccff|Hurl:%1|h%1|h|r")
        end
    end
  end

  return self._OriginalAddMessage(self, text, ...)
end



local function URLClicker_OnHyperlinkShow(self, link)
    if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.CreateAndCopyLinks and link:sub(1, 3) == "url" then
        if CaCLFrame then
            CaCLFrame:Show()
            CaCLFrame.editBox:SetText(link:sub(5))
            CaCLFrame.editBox:HighlightText()
        end
    end
end

function ns.CreateAndCopyLink()
    if ns.CreateAndCopyLinkEnabled then return end

    CaCLFrame = CreateFrame("Frame", "CaCLFrame", UIParent, "DialogBoxFrame")
    CaCLFrame:SetSize(400, 130)
    CaCLFrame:SetPoint("TOP", 0, -300)
    CaCLFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    CaCLFrame:SetBackdropBorderColor(0, 0, 0, 1)
    CaCLFrame:SetMovable(true)
    CaCLFrame:EnableMouse(true)
    CaCLFrame:RegisterForDrag("LeftButton")
    CaCLFrame:SetScript("OnDragStart", CaCLFrame.StartMoving)
    CaCLFrame:SetScript("OnDragStop", CaCLFrame.StopMovingOrSizing)

    CaCLFrame.text = CaCLFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    CaCLFrame.text:SetPoint("TOP", 0, -15)
    CaCLFrame.text:SetText("|cffff0000Map|r|cff00ccffNotes|r\n" .. L["Use CTRL + C to copy the link"] .. "\n" .. L["The window closes automatically after copying"])

    CaCLFrame.editBox = CreateFrame("EditBox", nil, CaCLFrame, "InputBoxTemplate")
    CaCLFrame.editBox:SetSize(370, 30)
    CaCLFrame.editBox:SetPoint("CENTER", 0, -3)
    CaCLFrame.editBox:SetAutoFocus(true)
    CaCLFrame.editBox:SetFontObject(GameFontHighlight)
    CaCLFrame.editBox:SetScript("OnEscapePressed", function() CaCLFrame:Hide() end)
    CaCLFrame.editBox:SetScript("OnKeyUp", function(self, key)
        if IsControlKeyDown() and key == "C" then
            CaCLFrame:Hide()
        end
    end)

    RegisterAllChatFilters()

    for i = 1, NUM_CHAT_WINDOWS do
        local chatframe = _G["ChatFrame" .. i]
        if not chatframe._OriginalAddMessage then
            chatframe._OriginalAddMessage = chatframe.AddMessage
            chatframe.AddMessage = AddMessage
        end
    end

    local hookedAny = false
    for i = 1, NUM_CHAT_WINDOWS do
        local chatframe = _G["ChatFrame" .. i]
        if chatframe and not chatframe._MN_UrlHooked then
            chatframe._MN_UrlHooked = true
            if chatframe.SetHyperlinksEnabled then
                chatframe:SetHyperlinksEnabled(true)
            end
            chatframe:HookScript("OnHyperlinkClick", function(self, link, text, button)
                URLClicker_OnHyperlinkShow(self, link)
            end)
            hookedAny = true
        end
    end

    if not hookedAny and type(_G.ChatFrame_OnHyperlinkShow) == "function" then
        hooksecurefunc("ChatFrame_OnHyperlinkShow", URLClicker_OnHyperlinkShow)
    end

    ns.CreateAndCopyLinkEnabled = true
end

function ns.DisableCreateAndCopyLink()
    if not ns.CreateAndCopyLinkEnabled then return end

    UnregisterAllChatFilters()

    for i = 1, NUM_CHAT_WINDOWS do
        local chatframe = _G["ChatFrame" .. i]
        if chatframe._OriginalAddMessage then
            chatframe.AddMessage = chatframe._OriginalAddMessage
            chatframe._OriginalAddMessage = nil
        end
    end

    if CaCLFrame then
        CaCLFrame:Hide()
    end

    ns.CreateAndCopyLinkEnabled = false
end

function ns.ToggleCreateAndCopyLink()
    if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.CreateAndCopyLinks then
        ns.CreateAndCopyLink()
    else
        ns.DisableCreateAndCopyLink()
    end
end

do
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, ev, addon)
        if ev == "ADDON_LOADED" and addon == ADDON_NAME then
            if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.CreateAndCopyLinks then
                ns.CreateAndCopyLink()
            end
        end
    end)
end