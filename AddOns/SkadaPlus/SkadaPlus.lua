local function Event(event, handler)
    if _G.event == nil then
        _G.event = CreateFrame("Frame")
        _G.event.handler = {}
        _G.event.OnEvent = function(frame, event, ...)
            for key, handler in pairs(_G.event.handler[event]) do
                handler(...)
            end
        end
        _G.event:SetScript("OnEvent", _G.event.OnEvent)
    end
    if _G.event.handler[event] == nil then
        _G.event.handler[event] = {}
        _G.event:RegisterEvent(event)
    end
    table.insert(_G.event.handler[event], handler)
end

local function HookFormatNumber()
    Skada.FormatNumber = function(self, number)
        if number then
            if self.db.profile.numberformat == 1 then
                if number > 100000000 then
                    return ("%02.2f亿"):format(number / 100000000)
                end
                return ("%02.2f万"):format(number / 10000)
            else
                return math.floor(number)
            end
        end
    end
end

local function CheckSkadaChatFrame()
    _G.SkadaWindowName = "统计"
    for i = 1, NUM_CHAT_WINDOWS do
        name = GetChatWindowInfo(i)
        if name == SkadaWindowName then
            _G.SkadaChatFrame = _G['ChatFrame' .. i]
            _G.SkadaChatFrameTab = _G['ChatFrame' .. i .. "Tab"]
            return true
        end
    end
    return false
end

local function AnchorSkadaToChatFrame()
    if not CheckSkadaChatFrame() then
        FCF_OpenNewWindow(SkadaWindowName)
        CheckSkadaChatFrame()
    end
    FCF_DockFrame(SkadaChatFrame, (#FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)+1), true);
    ChatFrame_RemoveAllChannels(SkadaChatFrame)
    ChatFrame_RemoveAllMessageGroups(SkadaChatFrame)
    FCF_SelectDockFrame(DEFAULT_CHAT_FRAME)
    FCF_FadeInChatFrame(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK))
    _G.SkadaMainWindow = Skada:GetWindows()[1]
    SkadaMainWindow.bargroup:ClearAllPoints()
    SkadaMainWindow.bargroup:SetPoint("BOTTOMLEFT", SkadaChatFrame, "BOTTOMLEFT", 0, 0)
    SkadaMainWindow.db.background.height = SkadaChatFrame:GetHeight() - 20
    SkadaMainWindow.db.barwidth = SkadaChatFrame:GetWidth()
    SkadaMainWindow.db.barslocked = true
    SkadaMainWindow.db.background.borderthickness = 0
    SkadaMainWindow.db.background.bordertexture="None"
    SkadaMainWindow.db.background.texture="None"
    SkadaMainWindow.db.bartexture="Armory"
    SkadaMainWindow.db.title.texture = "Armory"
    SkadaMainWindow.db.title.borderthickness = 0
    SkadaMainWindow.db.hidden = true
    SkadaMainWindow:Hide()
    Skada:ApplySettings()
    SkadaChatFrame:HookScript('OnShow', function(self) SkadaMainWindow.db.hidden = false; SkadaMainWindow:Show() end)
    SkadaChatFrame:HookScript('OnHide', function(self) SkadaMainWindow.db.hidden = true; SkadaMainWindow:Hide() end)
end

local function CreateSkadaPlus()
    Skada:DeleteWindow("SkadaPlus")
    _G.SkadaPlusWindow = Skada:CreateWindow("SkadaPlus", nil, "bar")
    SkadaPlusWindow.bargroup:SetPoint('TOPRIGHT', PlayerFrame, 'BOTTOMRIGHT', -5, -25)
    SkadaPlusWindow.db.barslocked = true
    SkadaPlusWindow.db.enabletitle = false
    SkadaPlusWindow.db.clickthrough = true
    SkadaPlusWindow.db.classicons = false
    SkadaPlusWindow.db.barfontsize = 10
    SkadaPlusWindow.db.barheight = 14
    SkadaPlusWindow.db.barspacing = 2
    SkadaPlusWindow.db.barfont = "聊天"
    SkadaPlusWindow.db.background.height = 200
    SkadaPlusWindow.db.barwidth = 190
    SkadaPlusWindow.db.background.borderthickness = 0
    SkadaPlusWindow.db.background.bordertexture="None"
    SkadaPlusWindow.db.background.texture="None"
    SkadaPlusWindow.db.bartexture="Armory"
    SkadaPlusWindow.db.hidden = true
    SkadaPlusWindow:Hide()
    Skada:ApplySettings()
    Event("PLAYER_REGEN_DISABLED", function() SkadaPlusWindow.db.hidden = false; SkadaPlusWindow:Show() end)
    Event("PLAYER_REGEN_ENABLED", function() SkadaPlusWindow.db.hidden = true; SkadaPlusWindow:Hide() end)
end

Event("PLAYER_ENTERING_WORLD", function()
    HookFormatNumber()
    --CreateSkadaPlus()
    --AnchorSkadaToChatFrame()
end)
