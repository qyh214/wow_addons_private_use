local _, _MS = ...

_MS.UI = {}

local _DC = _MS.DATACORE
local _U = _MS.UTILS
local _CD = _MS.CONSTDATA
local _EVENTUI = _MS.EVENTUI
local _UI = _MS.UI


function _UI.registerTooltip(self, f, text)
    f:EnableMouse(true)
    f:SetScript('OnEnter', function()
        GameTooltip:Hide()
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
        GameTooltip:AddLine("|cFFFFFFFF" .. tostring(text))
        GameTooltip:Show()
    end)
    f:SetScript('OnLeave', function() GameTooltip:Hide() end)
end
    
function _UI.stopRefresh(self, uid)
    _UI.panelList[uid].refreshBtn.ag:Stop()
    _U:setFrameColor(_UI.panelList[uid].refreshBtn, 0.25, 0.25, 0.25, 0.9, 0, 0, 0, 0)
end

function _UI.startRefresh(self, uid)
    _UI.panelList[uid].refreshBtn.ag:Play()
    _U:setFrameColor(_UI.panelList[uid].refreshBtn, 0.5, 0.5, 0.5, 0.9, 0, 0, 0, 0)
end

function _UI.createInfoPanel(self, mainFrame, uid)
    -- Player Info Panel
    local panel = CreateFrame("Frame", "MSMainFrameInfoPanel"..uid, mainFrame)
    panel:SetSize(220, 460)
    _U:setFrameTexture(panel, 1)
    _U:Striping(panel)
    _U:setFrameColor(panel, 0, 0, 0, 0.8, 0, 0, 0, 1)

    -- --------------------
    -- Refresh Btn
    local refreshBtn = CreateFrame("Frame", "MSMainFrameRefreshBtn"..uid, panel)
    refreshBtn:SetSize(20, 20)
    refreshBtn:SetPoint("CENTER", panel, "TOPRIGHT", -20, -20)
    _U:setFrameTexture(refreshBtn, 0, "Interface\\Addons\\Minesweeperr\\media\\refresh")
    _U:setFrameColor(refreshBtn, 0.25, 0.25, 0.25, 0.9, 0, 0, 0, 0)
    refreshBtn:EnableMouse(true)
    _U:setFrameMouseSizeEffect(refreshBtn, 20, 24)
    _U:setRefreshMouseAnimation(refreshBtn, 15)
    refreshBtn:SetScript("OnMouseUp", function(self) 
        if _U.FLAG.getRefreshFlag() then
            print("|cFFFFFF00" .. L["RefreshBusy"])
            return
        end
        if GetNumGroupMembers() > 5 then
            print("|cFFFFFF00" .. L["InRaid"])
            return
        end
        _U:setFrameColor(refreshBtn, 0.6, 0.6, 0.6, 0.9, 0, 0, 0, 0)
        refreshBtn.ag:Play()
        _DC:getUnitData(uid)
    end)
    panel.refreshBtn = refreshBtn

    -- Class Icon
    panel.classIcon = CreateFrame("Frame", "MSMainFrameInfoPanelClassIcon"..uid, panel)
    panel.classIcon:SetSize(64, 64)
    _U:setFrameTexture(panel.classIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\classicons\\none")
    _U:setFrameColor(panel.classIcon, 1, 1, 1, 1, 0, 0, 0, 0)
    panel.classIcon:SetPoint("TOP", panel, "TOP", 0, -30)
    _U:setFrameText(panel.classIcon, "", 12, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0)
    panel.classIcon.Text:SetTextColor(0.8, 0.8, 0.8, 1)

    -- Player name and server
    panel.name = CreateFrame("Frame", "MSMainFrameInfoPanelName"..uid, panel)
    panel.name:SetSize(160, 24)
    _U:setFrameTexture(panel.name, 0)
    _U:setFrameColor(panel.name, 0, 0, 0, 0, 0, 0, 0, 0)
    panel.name:SetPoint("TOP", panel, "TOP", 0, -120)
    _U:setFrameText(panel.name, "Test Name", 16, "CENTER", "CENTER", 0, 0)
    panel.name.Text:SetTextColor(0.8, 0.8, 0.8, 1)

    panel.server = CreateFrame("Frame", "MSMainFrameInfoPanelServer"..uid, panel)
    panel.server:SetSize(160, 24)
    _U:setFrameTexture(panel.server, 0)
    _U:setFrameColor(panel.server, 0, 0, 0, 0, 0, 0, 0, 0)
    panel.server:SetPoint("TOP", panel, "TOP", 0, -140)
    _U:setFrameText(panel.server, "Test server", 12, "CENTER", "CENTER", 0, 0)
    panel.server.Text:SetTextColor(0.5, 0.5, 0.5, 1)

    -- Player iLvl and Corruption and Gem
    panel.iLvl = CreateFrame("Frame", "MSMainFrameInfoPanelItemLevel"..uid, panel)
    panel.iLvl:SetSize(16, 16)
    panel.iLvl:SetPoint("TOPLEFT", panel, "TOPLEFT", 30, -180)
    _U:setFrameTexture(panel.iLvl, 0, "Interface\\Addons\\Minesweeperr\\media\\ilvl")
    _U:setFrameColor(panel.iLvl, 1, 1, 1, 1, 0, 0, 0, 0)
    _U:setFrameText(panel.iLvl, "--", 14, "LEFT", "RIGHT", 5, 0)
    panel.iLvl.Text:SetTextColor(0.7, 0.7, 0.7, 1)
    -- _UI:registerTooltip(panel.iLvl, L["iLvl"])

    panel.corruptionValue = CreateFrame("Frame", "MSMainFrameInfoPanelCorruptionValue"..uid, panel)
    panel.corruptionValue:SetSize(16, 16)
    panel.corruptionValue:SetPoint("TOPLEFT", panel, "TOPLEFT", 85, -180)
    _U:setFrameTexture(panel.corruptionValue, 0, "Interface\\Addons\\Minesweeperr\\media\\corruption")
    _U:setFrameColor(panel.corruptionValue, 1, 1, 1, 1, 0, 0, 0, 0)
    _U:setFrameText(panel.corruptionValue, "--", 14, "LEFT", "RIGHT", 5, 0)
    panel.corruptionValue.Text:SetTextColor(0.7, 0.7, 0.7, 1)

    panel.gem = CreateFrame("Frame", "MSMainFrameInfoPanelGem"..uid, panel)
    panel.gem:SetSize(16, 16)
    panel.gem:SetPoint("TOPLEFT", panel, "TOPLEFT", 130, -180)
    _U:setFrameTexture(panel.gem, 0, "Interface\\Addons\\Minesweeperr\\media\\gem")
    _U:setFrameColor(panel.gem, 1, 1, 1, 1, 0, 0, 0, 0)
    _U:setFrameText(panel.gem, "--", 14, "LEFT", "RIGHT", 5, 0)
    panel.gem.Text:SetTextColor(0.7, 0.7, 0.7, 1)

    -- Role Icon
    panel.roleIcon = CreateFrame("Frame", "MSMainFrameInfoPanelRoleIcon"..uid, panel)
    panel.roleIcon:SetSize(16, 16)
    panel.roleIcon:SetPoint("TOPLEFT", panel, "TOPLEFT", 175, -180)
    _U:setFrameTexture(panel.roleIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\TANK")
    _U:setFrameColor(panel.roleIcon, 0.7, 0.7, 0.7, 0, 0, 0, 0, 0)

    -- Main Achievement Icon
    panel.mainAchiIcon = CreateFrame("Frame", "MSMainFrameInfoPanelMainAchiIcon"..uid, panel)
    panel.mainAchiIcon:SetSize(64, 64)
    panel.mainAchiIcon:SetPoint("TOP", panel, "TOP", 0, -220)
    _U:setFrameTexture(panel.mainAchiIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\unachi")
    _U:setFrameColor(panel.mainAchiIcon, 1, 1, 1, 1, 0, 0, 0, 0)
    -- Main Achievement Data
    _U:setFrameText(panel.mainAchiIcon, L["watingRefresh"], 12, "TOP", "BOTTOM", 0, 15)
    panel.mainAchiIcon.Text:SetTextColor(0.8, 0.8, 0.8, 1)

    -- Child Achievement Icon 1
    panel.childAchiIcon1 = CreateFrame("Frame", "MSMainFrameInfoPanelCAchiIcon1"..uid, panel)
    panel.childAchiIcon1:SetSize(16, 16)
    panel.childAchiIcon1:SetPoint("TOP", panel, "TOP", -32, -270)
    _U:setFrameTexture(panel.childAchiIcon1, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
    _U:setFrameColor(panel.childAchiIcon1, 1, 1, 1, 1, 0, 0, 0, 0)

    -- Child Achievement Icon 2
    panel.childAchiIcon2 = CreateFrame("Frame", "MSMainFrameInfoPanelCAchiIcon2"..uid, panel)
    panel.childAchiIcon2:SetSize(16, 16)
    panel.childAchiIcon2:SetPoint("TOP", panel, "TOP", 0, -280)
    _U:setFrameTexture(panel.childAchiIcon2, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
    _U:setFrameColor(panel.childAchiIcon2, 1, 1, 1, 1, 0, 0, 0, 0)

    -- Child Achievement Icon 3
    panel.childAchiIcon3 = CreateFrame("Frame", "MSMainFrameInfoPanelCAchiIcon3"..uid, panel)
    panel.childAchiIcon3:SetSize(16, 16)
    panel.childAchiIcon3:SetPoint("TOP", panel, "TOP", 32, -270)
    _U:setFrameTexture(panel.childAchiIcon3, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
    _U:setFrameColor(panel.childAchiIcon3, 1, 1, 1, 1, 0, 0, 0, 0)



    -- Dungeon Count Icon
    local countIcons = {}
    for j = 1, getn(_CD.dungeonIds), 1
    do
        local countIcon = CreateFrame("Frame", "MSMainFrameInfoPanelCountIcon"..uid..j, panel)
        countIcon:SetSize(16, 16)
        countIcon:SetPoint("TOPLEFT", panel, "TOPLEFT", 68 + math.fmod((j-1), 5) * 16, -335 + math.modf((j-1)/5) * 16)
        _U:setFrameTexture(countIcon, 1)
        _U:setFrameColor(countIcon, 0.2, 0.2, 0.2, 1, 0, 0, 0, 1)

        countIcons[j] = countIcon
    end
    panel.countIcons = countIcons

    -- Current Keystone Info
    panel.curKeystoneLabel = CreateFrame("Frame", "MSMainFrameInfoPanelcurKeystoneLabel"..uid, panel)
    panel.curKeystoneLabel:SetSize(30, 20)
    _U:setFrameTexture(panel.curKeystoneLabel, 1)
    _U:setFrameColor(panel.curKeystoneLabel, 0.3, 0.3, 0.3, 1, 0.6, 0.6, 0.6, 0)
    panel.curKeystoneLabel:SetPoint("TOP", panel, "TOP", -80, -380)
    _U:setFrameText(panel.curKeystoneLabel, L["currentKeystone"], 12, "CENTER", "CENTER", 0, 0)
    panel.curKeystoneLabel.Text:SetTextColor(0.9, 0.9, 0.9, 1)

    panel.curKeystone = CreateFrame("Frame", "MSMainFrameInfoPanelCurKeystone"..uid, panel)
    panel.curKeystone:SetSize(30, 20)
    _U:setFrameTexture(panel.curKeystone, 1)
    _U:setFrameColor(panel.curKeystone,  0.1, 0.1, 0.1, 1, 0.6, 0.6, 0.6, 0)
    panel.curKeystone:SetPoint("LEFT", panel.curKeystoneLabel, "RIGHT", -1, 0)
    _U:setFrameText(panel.curKeystone, "", 14, "CENTER", "CENTER", 0, 0)
    panel.curKeystone.Text:SetTextColor(0.7, 0.7, 0.7, 1)

    panel.maxIntimeLabel = CreateFrame("Frame", "MSMainFrameInfoPanelmaxIntimeLabel"..uid, panel)
    panel.maxIntimeLabel:SetSize(30, 20)
    _U:setFrameTexture(panel.maxIntimeLabel, 1)
    _U:setFrameColor(panel.maxIntimeLabel, 0.3, 0.3, 0.3, 1, 0.6, 0.6, 0.6, 0)
    panel.maxIntimeLabel:SetPoint("TOP", panel, "TOP", -15, -380)
    _U:setFrameText(panel.maxIntimeLabel, L["maxIntime"], 12, "CENTER", "CENTER", 0, 0)
    panel.maxIntimeLabel.Text:SetTextColor(0.9, 0.9, 0.9, 1)

    panel.maxIntime = CreateFrame("Frame", "MSMainFrameInfoPanelmaxIntime"..uid, panel)
    panel.maxIntime:SetSize(30, 20)
    _U:setFrameTexture(panel.maxIntime, 1)
    _U:setFrameColor(panel.maxIntime, 0.1, 0.1, 0.1, 1, 0.6, 0.6, 0.6, 0)
    panel.maxIntime:SetPoint("LEFT", panel.maxIntimeLabel, "RIGHT", -1, 0)
    _U:setFrameText(panel.maxIntime, "", 14, "CENTER", "CENTER", 0, 0)
    panel.maxIntime.Text:SetTextColor(0.7, 0.7, 0.7, 1)

    panel.maxOvertimeLabel = CreateFrame("Frame", "MSMainFrameInfoPanelmaxOvertimeLabel"..uid, panel)
    panel.maxOvertimeLabel:SetSize(30, 20)
    _U:setFrameTexture(panel.maxOvertimeLabel, 1)
    _U:setFrameColor(panel.maxOvertimeLabel, 0.3, 0.3, 0.3, 1, 0.6, 0.6, 0.6, 0)
    panel.maxOvertimeLabel:SetPoint("TOP", panel, "TOP", 50, -380)
    _U:setFrameText(panel.maxOvertimeLabel, L["maxOvertime"], 12, "CENTER", "CENTER", 0, 0)
    panel.maxOvertimeLabel.Text:SetTextColor(0.9, 0.9, 0.9, 1)

    panel.maxOvertime = CreateFrame("Frame", "MSMainFrameInfoPanelmaxOvertime"..uid, panel)
    panel.maxOvertime:SetSize(30, 20)
    _U:setFrameTexture(panel.maxOvertime, 1)
    _U:setFrameColor(panel.maxOvertime, 0.1, 0.1, 0.1, 1, 0.6, 0.6, 0.6, 0)
    panel.maxOvertime:SetPoint("LEFT", panel.maxOvertimeLabel, "RIGHT", -1, 0)
    _U:setFrameText(panel.maxOvertime, "", 14, "CENTER", "CENTER", 0, 0)
    panel.maxOvertime.Text:SetTextColor(0.7, 0.7, 0.7, 1)




    -- Rating Icon
    panel.rateGoodIcon = CreateFrame("Frame", "MSMainFrameInfoPanelRateGood"..uid, panel)
    panel.rateGoodIcon:SetSize(20, 20)
    panel.rateGoodIcon:SetPoint("CENTER", panel, "TOP", -40, -435)
    _U:setFrameTexture(panel.rateGoodIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\good")
    _U:setFrameColor(panel.rateGoodIcon, 0.5, 0.5, 0.5, 1, 0, 0, 0, 0)
    _U:setFrameMouseSizeEffect(panel.rateGoodIcon, 20, 24)

    panel.rateGoodIcon:SetScript("OnMouseUp", function()
        _U:setFrameColor(panel.rateGoodIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
        _U:setFrameColor(panel.rateBadIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
        _DC:saveRating(panel.guid, 1)
    end)

    panel.rateGoodCount = CreateFrame("Frame", "MSMainFrameInfoPanelRateGood"..uid, panel)
    panel.rateGoodCount:SetSize(20, 20)
    panel.rateGoodCount:SetPoint("CENTER", panel, "TOP", -20, -437)
    _U:setFrameTexture(panel.rateGoodCount, 0)
    _U:setFrameColor(panel.rateGoodCount, 0.5, 0.5, 0.5, 0, 0, 0, 0, 0)
    _U:setFrameText(panel.rateGoodCount, "0", 14, "CENTER", "CENTER", 0, 0)
    panel.rateGoodCount.Text:SetTextColor(0.6, 0.6, 0.6, 1)



    panel.rateBadIcon = CreateFrame("Frame", "MSMainFrameInfoPanelRateBad"..uid, panel)
    panel.rateBadIcon:SetSize(20, 20)
    panel.rateBadIcon:SetPoint("CENTER", panel, "TOP", 35, -435)
    _U:setFrameTexture(panel.rateBadIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\bad")
    _U:setFrameColor(panel.rateBadIcon, 0.5, 0.5, 0.5, 1, 0, 0, 0, 0)
    _U:setFrameMouseSizeEffect(panel.rateBadIcon, 20, 24)

    panel.rateBadIcon:SetScript("OnMouseUp", function()
        _U:setFrameColor(panel.rateBadIcon, 0.9, 0.9, 0.9, 1, 0, 0, 0, 0)
        _U:setFrameColor(panel.rateGoodIcon, 0.3, 0.3, 0.3, 1, 0, 0, 0, 0)
        _DC:saveRating(panel.guid, 0)
    end)

    panel.rateBadCount = CreateFrame("Frame", "MSMainFrameInfoPanelRateGood"..uid, panel)
    panel.rateBadCount:SetSize(20, 20)
    panel.rateBadCount:SetPoint("CENTER", panel, "TOP", 55, -437)
    _U:setFrameTexture(panel.rateBadCount, 0)
    _U:setFrameColor(panel.rateBadCount, 0.5, 0.5, 0.5, 0, 0, 0, 0, 0)
    _U:setFrameText(panel.rateBadCount, "0", 14, "CENTER", "CENTER", 0, 0)
    panel.rateBadCount.Text:SetTextColor(0.6, 0.6, 0.6, 1)


    return panel
end


function _UI.registerCorruptionTooltip(self, f, corruptionList)
    f:EnableMouse(true)
    f:SetScript('OnEnter', function()
        GameTooltip:Hide()
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
        GameTooltip:AddLine("|cFF8888FF" .. L["Corruption"])
        for k, v in pairs(corruptionList)
        do
            GameTooltip:AddLine("|cFFFFFFFF" .. L[v["name"]]..v["level"].." * "..v["count"])
        end
        GameTooltip:Show()
    end)
    f:SetScript('OnLeave', function() GameTooltip:Hide() end)
end


function _UI.refresInfoPanelByUnitInfo(self, panel, unitInfo)
    panel.guid = unitInfo["GUID"]
    _U:setFrameTexture(panel.classIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\classicons\\".._CD.classIdx[unitInfo["classIndex"]])
    _U:setFrameColor(panel.classIcon, 1, 1, 1, 1, 0, 0, 0, 0)
    if unitInfo["currentSpecName"] then
        panel.classIcon.Text:SetText(unitInfo["currentSpecName"])
    else
        panel.classIcon.Text:SetText("")
    end

    panel.name.Text:SetText(unitInfo["name"])
    panel.server.Text:SetText(unitInfo["server"])

   if unitInfo["ilvl"] then
        panel.iLvl.Text:SetText(unitInfo["ilvl"])
    else
        panel.iLvl.Text:SetText("--")
    end

    if unitInfo["corruptionValue"] then
        panel.corruptionValue.Text:SetText(unitInfo["corruptionValue"])
        local corrValue = tonumber(unitInfo["corruptionValue"])
        if corrValue >= 40 and corrValue < 60 then
            panel.corruptionValue.Text:SetTextColor(0.9, 0.8, 1, 1)
        elseif corrValue >= 60 then
            panel.corruptionValue.Text:SetTextColor(1, 0.1, 0.1, 1)
        else
            panel.corruptionValue.Text:SetTextColor(0.7, 0.7, 0.7, 1)
        end
    else
        panel.corruptionValue.Text:SetText("--")
    end

    if unitInfo["corruptionList"] then
        _UI:registerCorruptionTooltip(panel.corruptionValue, unitInfo["corruptionList"])
    end

    if unitInfo["gemSlot"] then
        panel.gem.Text:SetText(unitInfo["gemSlot"])
        local gemValue = tonumber(unitInfo["gemSlot"])
        if gemValue >= 5 and gemValue < 8 then
            panel.gem.Text:SetTextColor(0.9, 0.8, 1, 1)
        elseif gemValue >= 8 then
            panel.gem.Text:SetTextColor(1, 0.55, 0, 1)
        else
            panel.gem.Text:SetTextColor(0.7, 0.7, 0.7, 1)
        end
    else
        panel.gem.Text:SetText("--")
    end

    if unitInfo["role"] and unitInfo["role"] ~= "NONE"then
        _U:setFrameTexture(panel.roleIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\"..unitInfo["role"])
        _U:setFrameColor(panel.roleIcon, 0.7, 0.7, 0.7, 1, 0, 0, 0, 0)
    else
        _U:setFrameColor(panel.roleIcon, 0.7, 0.7, 0.7, 0, 0, 0, 0, 0)
    end

    _UI:registerTooltip(panel.mainAchiIcon, unitInfo["mainAchiName"])
    if unitInfo["mainAchi"]
    then
        if unitInfo["mainAchi"] ~= 0 then
            _U:setFrameTexture(panel.mainAchiIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\achi")
            panel.mainAchiIcon.Text:SetText(unitInfo["mainAchi"])
            _UI:registerTooltip(panel.mainAchiIcon, unitInfo["mainAchiName"]..": "..unitInfo["mainAchi"])
        else
            _U:setFrameTexture(panel.mainAchiIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\unachi")
            panel.mainAchiIcon.Text:SetText(L["Uncompleted"])
        end
    else
        _U:setFrameTexture(panel.mainAchiIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\unachi")
        panel.mainAchiIcon.Text:SetText(L["watingRefresh"])
    end
    _U:setFrameColor(panel.mainAchiIcon, 1, 1, 1, 1, 0, 0, 0, 0)

    _UI:registerTooltip(panel.childAchiIcon1, unitInfo["cAchi1Name"])
    if unitInfo["cAchi1"]
    then
        if unitInfo["cAchi1"] ~= 0 then
            _U:setFrameTexture(panel.childAchiIcon1, 0, "Interface\\Addons\\Minesweeperr\\media\\star")
            _UI:registerTooltip(panel.childAchiIcon1, unitInfo["cAchi1Name"]..": "..unitInfo["cAchi1"])
        else
            _U:setFrameTexture(panel.childAchiIcon1, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
        end
    else
        _U:setFrameTexture(panel.childAchiIcon1, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
    end
    _U:setFrameColor(panel.childAchiIcon1, 1, 1, 1, 1, 0, 0, 0, 0)

    _UI:registerTooltip(panel.childAchiIcon2, unitInfo["cAchi2Name"])
    if unitInfo["cAchi2"]
    then
        if unitInfo["cAchi2"] ~= 0 then
            _U:setFrameTexture(panel.childAchiIcon2, 0, "Interface\\Addons\\Minesweeperr\\media\\star")
            _UI:registerTooltip(panel.childAchiIcon2, unitInfo["cAchi2Name"]..": "..unitInfo["cAchi2"])
        else
            _U:setFrameTexture(panel.childAchiIcon2, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
        end
    else
        _U:setFrameTexture(panel.childAchiIcon2, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
    end
    _U:setFrameColor(panel.childAchiIcon2, 1, 1, 1, 1, 0, 0, 0, 0)

    _UI:registerTooltip(panel.childAchiIcon3, unitInfo["cAchi3Name"])
    if unitInfo["cAchi3"]
    then
        if unitInfo["cAchi3"] ~= 0 then
            _U:setFrameTexture(panel.childAchiIcon3, 0, "Interface\\Addons\\Minesweeperr\\media\\star")
            _UI:registerTooltip(panel.childAchiIcon3, unitInfo["cAchi3Name"]..": "..unitInfo["cAchi3"])
        else
            _U:setFrameTexture(panel.childAchiIcon3, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
        end
    else
        _U:setFrameTexture(panel.childAchiIcon3, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
    end
    _U:setFrameColor(panel.childAchiIcon3, 1, 1, 1, 1, 0, 0, 0, 0)


    if unitInfo["dungeonCount"] then
        for i = 1, getn(_CD.dungeonIds), 1
        do
            count = unitInfo["dungeonCount"][_CD.dungeonIds[i]]
            _UI.registerTooltip(self, panel.countIcons[i], _CD.dungeonNames[i].. ": ".. count)
            if count == "--" then
                count = 0
            end
            count = tonumber(count)
            if count > 50 then
                count = 50
            end
            panel.countIcons[i]:SetBackdropColor(0.2+0.6*count/50, 0.2, 0.2, 1)
        end
    else
        for i = 1, getn(_CD.dungeonIds), 1
        do
            panel.countIcons[i]:SetBackdropColor(0.2, 0.2, 0.2, 1)
        end
    end

    if unitInfo["keystoneInfo"] then
        if unitInfo["keystoneInfo"]["c"] then
            panel.curKeystone.Text:SetText(unitInfo["keystoneInfo"]["c"]["lvl"])
            _UI.registerTooltip(self, panel.curKeystone, unitInfo["keystoneInfo"]["c"]["nm"])
        end
        if unitInfo["keystoneInfo"]["mi"] then
            panel.maxIntime.Text:SetText(unitInfo["keystoneInfo"]["mi"]["lvl"])
            _UI.registerTooltip(self, panel.maxIntime, unitInfo["keystoneInfo"]["mi"]["nm"])
        end
        if unitInfo["keystoneInfo"]["mo"] then
            panel.maxOvertime.Text:SetText(unitInfo["keystoneInfo"]["mo"]["lvl"])
            _UI.registerTooltip(self, panel.maxOvertime, unitInfo["keystoneInfo"]["mo"]["nm"])
        end
    else
        panel.curKeystone.Text:SetText("--")
        panel.maxIntime.Text:SetText("--")
        panel.maxOvertime.Text:SetText("--")
    end

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

    if unitInfo["goodRatingCount"] then
        if _U:getN(unitInfo["goodRatingCount"]) > 0 then
            panel.rateGoodCount.Text:SetText(_U:getN(unitInfo["goodRatingCount"]))
        else
            panel.rateGoodCount.Text:SetText("")
        end
    end
    if unitInfo["badRatingCount"] then
        if _U:getN(unitInfo["badRatingCount"]) > 0 then
            panel.rateBadCount.Text:SetText(_U:getN(unitInfo["badRatingCount"]))
        else
            panel.rateBadCount.Text:SetText("")
        end
    end
end

function _UI.refreshInfoPanel(self, uid)
    local unitInfo = _MS.DB[_CD.partyMembers[uid]]
    if not unitInfo then
        return
    end

    local panel = _UI.panelList[uid]
    _UI:refresInfoPanelByUnitInfo(panel, unitInfo)
    panel:Show()
end


function _UI.resetPanel(self, panel)
    _UI:refresInfoPanelByUnitInfo(panel, _CD.unitInfoTempl)
end

function _UI.refreshAll()
    if _U.FLAG.getRefreshFlag() then
        print("|cFFFFFF00" .. L["RefreshBusy"])
        return
    end
    if GetNumGroupMembers() > 5 then
        print("|cFFFFFF00" .. L["InRaid"])
        return
    end
    for uid, panel in pairs(_UI.panelList)
    do
        _U:setFrameColor(panel.refreshBtn, 0.5, 0.5, 0.5, 0.9, 0, 0, 0, 0)
        panel.refreshBtn.ag:Play()
    end
    _DC.partyChanged()
end


function _UI.togglePanel()
    for i = 1, getn(_CD.partyMembersTempl), 1
    do
        if _CD.partyMembers[_CD.partyMembersTempl[i]] then
            _UI.panelList[_CD.partyMembersTempl[i]]:Show()
        else
            _UI.panelList[_CD.partyMembersTempl[i]]:Hide()
            _UI:resetPanel(_UI.panelList[_CD.partyMembersTempl[i]])
        end
    end
end


function _UI.createMainFrame()
    -- --------------------
    -- Main Frame
    local mainFrame = CreateFrame("Frame", "MSMainFrame", UIParent)
    _UI.mainFrame = mainFrame

    mainFrame:SetFrameLevel(5)
    mainFrame:SetSize(1160, 560)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    _U:setFrameTexture(mainFrame, 1)
    _U:Striping(mainFrame)
    _U:setFrameColor(mainFrame, 0, 0, 0, 0.7, 0, 0, 0, 1)
    _U:setFrameMovable(mainFrame)

    -- --------------------
    -- Title Box
    local titleBox = CreateFrame("Frame", "MSMainFrameTitle", mainFrame)
    titleBox:SetPoint("TOP", mainFrame, "TOP", 0, 20)
    titleBox:SetSize(180, 50)
    _U:setFrameTexture(titleBox, 1)
    _U:Striping(titleBox)
    _U:setFrameColor(titleBox, 0, 0, 0, 0.9, 0, 0, 0, 1)
    _U:setFrameText(titleBox, "Minesweeperr", 30, "CENTER", "CENTER", 0, 0)
    mainFrame.titleBox = titleBox


    -- --------------------
    -- Close Btn
    local closeBtn = CreateFrame("Frame", "MSMainFrameCloseBtn", mainFrame)
    closeBtn:SetSize(120, 30)
    closeBtn:SetPoint("BOTTOM", mainFrame, "BOTTOM", 300, 15)
    _U:setFrameTexture(closeBtn, 1)
    _U:setFrameColor(closeBtn, 0, 0, 0, 0.9, 0, 0, 0, 1)
    _U:setFrameText(closeBtn, L["Close"], 14, "CENTER", "CENTER", 0, 0)
    closeBtn.Text:SetTextColor(0.8, 0.8, 0.8, 1)
    closeBtn:EnableMouse(true)
    _U:setBtnMouseColorEffect(closeBtn)
    closeBtn:SetScript("OnMouseUp", function(self) self:GetParent():Hide() end)
    mainFrame.closeBtn = closeBtn

    -- --------------------
    -- Refresh Btn
    local refreshBtn = CreateFrame("Frame", nil, mainFrame)
    refreshBtn:SetSize(120, 30)
    refreshBtn:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 15)
    _U:setFrameTexture(refreshBtn, 1)
    _U:setFrameColor(refreshBtn, 0, 0, 0, 0.9, 0, 0, 0, 1)
    _U:setFrameText(refreshBtn, L["Refresh"], 14, "CENTER", "CENTER", 0, 0)
    refreshBtn.Text:SetTextColor(0.8, 0.8, 0.8, 1)
    refreshBtn:EnableMouse(true)
    _U:setBtnMouseColorEffect(refreshBtn)
    refreshBtn:SetScript("OnMouseUp", _UI.refreshAll)

    -- History Btn
    local historyBtn = CreateFrame("Frame", "MSMainFrameHistoryBtn", mainFrame)
    historyBtn:SetSize(120, 30)
    historyBtn:SetPoint("BOTTOM", mainFrame, "BOTTOM", -300, 15)
    _U:setFrameTexture(historyBtn, 1)
    _U:setFrameColor(historyBtn, 0, 0, 0, 0.9, 0, 0, 0, 1)
    _U:setFrameText(historyBtn, L["History"], 14, "CENTER", "CENTER", 0, 0)
    historyBtn.Text:SetTextColor(0.8, 0.8, 0.8, 1)
    historyBtn:EnableMouse(true)
    _U:setBtnMouseColorEffect(historyBtn)
    historyBtn:SetScript("OnMouseUp", function(self)
        if _CD.historyMembers then
            _UI:refreshHistory()
            _UI.historyFrame:Show()
        end
    end)
    mainFrame.historyBtn = historyBtn

    -- ----------------------
    -- Create Info Panel for Player
    _UI.panelList = {}

    local playerPanel = _UI:createInfoPanel(mainFrame, "player")
    playerPanel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -40)
    playerPanel:EnableMouse(true)
    playerPanel:SetScript("OnMouseUp", function() _DC:getUnitData("player") end)
    _UI.panelList["player"] = playerPanel
    for i = 1, 4, 1 do
        local memberPanel = _UI:createInfoPanel(mainFrame, "party"..i)
        memberPanel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10+i*230, -40)
        memberPanel:Hide()
        _UI.panelList["party"..i] = memberPanel
    end
    return mainFrame
end