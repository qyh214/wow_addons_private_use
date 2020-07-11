local _, _MS = ...
local L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)

local _UI = _MS.UI
local _U = _MS.UTILS
local _DC = _MS.DATACORE
local _CD = _MS.CONSTDATA
local _EVENTUI = _MS.EVENTUI



function _UI.refreshQuickRating()
    local i = 1
    for uid, guid in pairs(_CD.partyMembers)
    do
        if uid ~= "player" then
            local panel = _UI.quickRatingFrame.panels[i]
            panel.guid = guid
            -- Role Icon
            _U:setFrameTexture(panel.roleIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\".._DC:selectDatafromDB(guid, "role"))
            _U:setFrameColor(panel.roleIcon, 0.7, 0.7, 0.7, 1, 0, 0, 0, 0)

            -- Player name and server
            panel.name:SetText(_DC:selectDatafromDB(guid, "name").."-".._DC:selectDatafromDB(guid, "server"))
            local r, g, b = GetClassColor(_CD.classIdx[_DC:selectDatafromDB(guid, "classIndex")])
            panel.name:SetTextColor(r, g, b, 1)

            panel.rateGoodIcon:Show()

            local rating = _DC:selectDatafromDB(guid, "rating")
            if  rating then
                panel.rating = rating
                if tonumber(rating) == 1 then
                    _U:setFrameColor(panel.rateGoodIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
                    _U:setFrameColor(panel.rateBadIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
                else
                    _U:setFrameColor(panel.rateBadIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
                    _U:setFrameColor(panel.rateGoodIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
                end
            else
                _U:setFrameColor(panel.rateGoodIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
                _U:setFrameColor(panel.rateBadIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
            end
            i = i + 1
        end
    end
end


function _UI.createQuickRatingFrame()
    -- --------------------
    -- Frame
    local frame = CreateFrame("Frame", "MSQuickRatingFrame", UIParent)
    _UI.quickRatingFrame = frame
    frame:Hide()
    frame:SetSize(210, 240)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    _U:setFrameTexture(frame, 1)
    _U:setFrameColor(frame, 0, 0, 0, 0.7, 0, 0, 0, 1)
    _U:Striping(frame)
    _U:setFrameMovable(frame)

    -- Title
    local title = CreateFrame("Frame", "MSQuickRatingTitle", frame)
    title:SetSize(80, 26)
    title:SetPoint("TOP", frame, "TOP", 0, 10)
    _U:setFrameTexture(title, 1)
    _U:setFrameColor(title, 0, 0, 0, 0.9, 0, 0, 0, 1)
    _U:setFrameText(title, L["QuickRating"], 14, "CENTER", "CENTER", 0, 0)
    frame.Title = title

    -- Member panel
    local panels = {}
    for i = 1, 4, 1
    do
        local panel = CreateFrame("Frame", "MSQuickRatingPanel"..i, frame)
        panel:SetSize(200, 40)
        panel:SetPoint("TOP", frame, "TOP", 0, -20-(i-1)*45)
        _U:setFrameTexture(panel, 1)
        _U:setFrameColor(panel, 0, 0, 0, 0.8, 0, 0, 0, 1)

        -- Role Icon
        local roleIcon = CreateFrame("Frame", "MSQuickRatingPanelRoleIcon"..i, panel)
        roleIcon:SetSize(18, 18)
        _U:setFrameTexture(roleIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\TANK")
        _U:setFrameColor(roleIcon, 0.8, 0.8, 0.8, 1, 0, 0, 0, 0)
        roleIcon:SetPoint("LEFT", panel, "LEFT", 8, 0)
        panel.roleIcon = roleIcon

        -- Player name and server
        local name = panel:CreateFontString(nil, "OVERLAY")
        name:SetFont("Interface\\Addons\\Minesweeperr\\media\\font.ttf", 16, "THINOUTLINE")
        name:SetText("")
        name:SetPoint("LEFT", panel, "LEFT", 40, 0)
        panel.name = name

        panel.rateGoodIcon = CreateFrame("Frame", "MSQuickRatingPanelRateGood"..i, panel)
        -- panel.rateGoodIcon:Hide()
        panel.rateGoodIcon:SetSize(16, 16)
        panel.rateGoodIcon:SetPoint("RIGHT", panel, "RIGHT", -25, 0)
        _U:setFrameTexture(panel.rateGoodIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\good")
        _U:setFrameColor(panel.rateGoodIcon, 0.5, 0.5, 0.5, 1, 0, 0, 0, 0)
        _U:setFrameMouseSizeEffect(panel.rateGoodIcon, 16, 20)
    
        panel.rateGoodIcon:SetScript("OnMouseUp", function()
            _U:setFrameColor(panel.rateGoodIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
            _U:setFrameColor(panel.rateBadIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
            _DC:saveRating(panel.guid, 1)
        end)
    
        panel.rateBadIcon = CreateFrame("Frame", "MSQuickRatingPanelRateBad"..i, panel)
        -- panel.rateBadIcon:Hide()
        panel.rateBadIcon:SetSize(16, 16)
        panel.rateBadIcon:SetPoint("RIGHT", panel, "RIGHT", 0, 0)
        _U:setFrameTexture(panel.rateBadIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\bad")
        _U:setFrameColor(panel.rateBadIcon, 0.5, 0.5, 0.5, 1, 0, 0, 0, 0)
        _U:setFrameMouseSizeEffect(panel.rateBadIcon, 16, 20)
    
        panel.rateBadIcon:SetScript("OnMouseUp", function()
            _U:setFrameColor(panel.rateBadIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
            _U:setFrameColor(panel.rateGoodIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
            _DC:saveRating(panel.guid, 0)
        end)

        panels[i] = panel
        i = i + 1
    end
    -- Rating For ALL Icon 
    local rateAllGoodIcon = CreateFrame("Frame", "MSQuickRatingRateGoodForAll", frame)
    rateAllGoodIcon:SetSize(20, 20)
    _U:setFrameTexture(rateAllGoodIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\good")
    _U:setFrameColor(rateAllGoodIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
    rateAllGoodIcon:SetPoint("CENTER", frame, "BOTTOMRIGHT", -49, 25)
    rateAllGoodIcon:EnableMouse(true)
    _U:setFrameMouseSizeEffect(rateAllGoodIcon, 20, 24)


    local rateAllBadIcon = CreateFrame("Frame", "MSQuickRatingRateBadForAll", frame)
    rateAllBadIcon:SetSize(20, 20)
    _U:setFrameTexture(rateAllBadIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\bad")
    _U:setFrameColor(rateAllBadIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
    rateAllBadIcon:SetPoint("CENTER", frame, "BOTTOMRIGHT", -19, 23)
    rateAllBadIcon:EnableMouse(true)
    _U:setFrameMouseSizeEffect(rateAllBadIcon, 20, 24)

    rateAllGoodIcon:SetScript("OnMouseUp", function()
        _U:setFrameColor(rateAllGoodIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
        _U:setFrameColor(rateAllBadIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
        for i = 1, 4, 1 do
            if _UI.quickRatingFrame.panels[i].guid then
                _DC:saveRating(_UI.quickRatingFrame.panels[i].guid, 1)
                _U:setFrameColor(_UI.quickRatingFrame.panels[i].rateGoodIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
                _U:setFrameColor(_UI.quickRatingFrame.panels[i].rateBadIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
            end
        end
    end)
    frame.rateAllGoodIcon = rateAllGoodIcon

    rateAllBadIcon:SetScript("OnMouseUp", function()
        _U:setFrameColor(rateAllBadIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
        _U:setFrameColor(rateAllGoodIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
        for i = 1, 4, 1 do
            if _UI.quickRatingFrame.panels[i].guid then
                _DC:saveRating(_UI.quickRatingFrame.panels[i].guid, 0)
                _U:setFrameColor(_UI.quickRatingFrame.panels[i].rateBadIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
                _U:setFrameColor(_UI.quickRatingFrame.panels[i].rateGoodIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
            end
        end
    end)
    frame.rateAllBadIcon = rateAllBadIcon

    -- --------------------
    -- Close Btn
    local closeBtn = CreateFrame("Frame", "MSQuickRatingRateBadForAll", frame)
    closeBtn:SetSize(100, 30)
    _U:setFrameTexture(closeBtn, 1)
    _U:setFrameColor(closeBtn, 0, 0, 0, 0.9, 0, 0, 0, 1)
    closeBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 10)
    _U:setFrameText(closeBtn, L["Close"], 14, "CENTER", "CENTER", 0, 0)
    closeBtn:EnableMouse(true)
    _U:setBtnMouseColorEffect(closeBtn)
    closeBtn:SetScript("OnMouseUp", function(self) self:GetParent():Hide();  end)
    frame.closeBtn = closeBtn

    frame.panels = panels


end


function _UI.showQuickRating()
    if _CD.autoshowQC then
        _UI:refreshQuickRating()
        _UI.quickRatingFrame:Show()
    end
end

function _UI.challengeStart()
    ClearAchievementComparisonUnit()
    ClearInspectPlayer()
    _U.FLAG:releaseRefreshFlag()
    _U:wait(3, _DC.partyChanged)
end


local challengeStartEventFrame = CreateFrame("Frame", "ChallengeStartFrame", _EVENTUI.eventFrame)
challengeStartEventFrame:RegisterEvent("CHALLENGE_MODE_START")
challengeStartEventFrame:SetScript("OnEvent", _DC.partyChanged);

local challengeEndEventFrame = CreateFrame("Frame", "ChallengeStartFrame", _EVENTUI.eventFrame)
challengeEndEventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
challengeEndEventFrame:SetScript("OnEvent", _UI.showQuickRating);