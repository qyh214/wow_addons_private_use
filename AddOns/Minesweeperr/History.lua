local _, _MS = ...

local _DC = _MS.DATACORE
local _U = _MS.UTILS
local _CD = _MS.CONSTDATA
local _EVENTUI = _MS.EVENTUI
local _UI = _MS.UI


function _UI.refreshHistoryPanel(self, panel, unitInfo)
    -- Time
    panel.guid = unitInfo["GUID"]
    panel.time.Text:SetText(unitInfo["time"])

    -- Class Icon
    panel.nameserver.Text:SetText(unitInfo["name"].."-"..unitInfo["server"])
    local r, g, b = GetClassColor(_CD.classIdx[unitInfo["classIndex"]])
    panel.nameserver.Text:SetTextColor(r, g, b, 1)
    -- -- Rating Icon
    panel.rateGoodIcon:Show()
    panel.rateBadIcon:Show()
    if unitInfo["rating"] then
        if tonumber(unitInfo["rating"]) == 1 then
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

end


function _UI.refreshHistory()
    local unitInfo = 1
    local i = 1
    while unitInfo do
        unitInfo = _U.List:pop(_CD.historyMembers)
        if unitInfo then
            local panel = _UI.historyList[i]
            _UI:refreshHistoryPanel(panel, unitInfo)
        end
        i = i + 1
    end
end


function _UI.createHistoryPanel(self, mainFrame, uid)
    local panel = CreateFrame("Frame", "MSHistoryInfoPanel"..uid, mainFrame)
    panel:SetSize(180, 40)
    _U:setFrameTexture(panel, 0)
    _U:setFrameColor(panel, 0, 0, 0, 0, 0, 0, 0, 0)

    -- Time
    panel.time = CreateFrame("Frame", "MSHistoryInfoPanelTime"..uid, panel)
    panel.time:SetSize(32, 32)
    _U:setFrameTexture(panel.time, 0)
    _U:setFrameColor(panel.time, 1, 1, 1, 0, 0, 0, 0, 0)
    panel.time:SetPoint("LEFT", panel, "LEFT", 0, 0)
    _U:setFrameText(panel.time, "", 12, "CENTER", "CENTER", 0, 0)
    panel.time.Text:SetTextColor(1, 1, 1, 1)

    -- Class Icon
    panel.nameserver = CreateFrame("Frame", "MSHistoryInfoPanelnameserver"..uid, panel)
    panel.nameserver:SetSize(32, 32)
    _U:setFrameTexture(panel.nameserver, 0)
    _U:setFrameColor(panel.nameserver, 1, 1, 1, 0, 0, 0, 0, 0)
    panel.nameserver:SetPoint("LEFT", panel, "LEFT", 35, 0)
    _U:setFrameText(panel.nameserver, "", 12, "LEFT", "LEFT", 0, 0)
    panel.nameserver.Text:SetTextColor(1, 1, 1, 1)

    -- Rating Icon
    panel.rateGoodIcon = CreateFrame("Frame", "MSHistoryInfoPanelRateGood"..uid, panel)
    panel.rateGoodIcon:Hide()
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

    panel.rateBadIcon = CreateFrame("Frame", "MSHistoryInfoPanelRateBad"..uid, panel)
    panel.rateBadIcon:Hide()
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

    return panel

end


function _UI.createHistoryFrame()
    -- --------------------
    -- History Frame
    local historyFrame = CreateFrame("Frame", "MSHistoryFrame", _UI.mainFrame)
    historyFrame:Hide()
    _UI.historyFrame = historyFrame
    historyFrame:SetFrameLevel(5)
    historyFrame:SetSize(200, 560)
    historyFrame:SetPoint("RIGHT", _UI.mainFrame, "LEFT", 0, 0)
    _U:setFrameTexture(historyFrame, 1)
    _U:Striping(historyFrame)
    _U:setFrameColor(historyFrame, 0, 0, 0, 0.9, 0, 0, 0, 1)

    --------------------
    -- Close Btn
    
    local closeBtn = CreateFrame("Frame", "MShistoryFrameCloseBtn", historyFrame)
    closeBtn:SetSize(120, 30)
    closeBtn:SetPoint("BOTTOM", historyFrame, "BOTTOM", 0, 15)
    _U:setFrameTexture(closeBtn, 1)
    _U:setFrameColor(closeBtn, 0, 0, 0, 0.9, 0, 0, 0, 1)
    _U:setFrameText(closeBtn, L["Close"], 14, "CENTER", "CENTER", 0, 0)
    closeBtn.Text:SetTextColor(0.8, 0.8, 0.8, 1)
    closeBtn:EnableMouse(true)
    _U:setBtnMouseColorEffect(closeBtn)
    closeBtn:SetScript("OnMouseUp", function(self) self:GetParent():Hide() end)
    historyFrame.closeBtn = closeBtn


    -- ----------------------
    -- Create Info Panel for Player
    _UI.historyList = {}
    for i = 1, 10, 1 do
        local historyPanel = _UI:createHistoryPanel(historyFrame, i)
        historyPanel:SetPoint("TOPLEFT", historyFrame, "TOPLEFT", 10, -10-(i-1)*45)
        _UI.historyList[i] = historyPanel
    end
end