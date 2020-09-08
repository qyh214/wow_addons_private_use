local L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)
local MS = Minesweeperr
MS.Frame = {}


function MS.Frame:setFrameTexture(f, edgeSize, bgTexture)
    if not bgTexture then
       bgTexture = "Interface\\AddOns\\Minesweeperr\\media\\normTex"
    end
    f:SetBackdrop({
          bgFile = bgTexture,
          insets = {left = 0,right = 0,top = 0,bottom = 0},
          edgeFile = "Interface\\AddOns\\Minesweeperr\\media\\normTex",
          edgeSize = edgeSize,
    })
end

function MS.Frame:setFrameColor(f, bgR, bgG, bgB, bgA, egR, egG, egB, egA)
    f:SetBackdropColor(bgR, bgG, bgB, bgA)
    f:SetBackdropBorderColor(egR, egG, egB, egA)
end

function MS.Frame:setFrameMovable(f)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

function MS.Frame:setRotationAnimation(f)
    local ag = f:CreateAnimationGroup()    
    local rotate = ag:CreateAnimation("Rotation")
    rotate:SetDegrees(360/3.5*100)
    rotate:SetDuration(100)
    f.ag = ag
end

function MS.Frame:CreateTextBox(parent, name, text, fontsize, r, g, b, a, width, height, anchor)
    local f = CreateFrame("Frame", name, parent)
    f.text = f:CreateFontString(nil, "OVERLAY")
    f.text:SetFont("Interface\\Addons\\Minesweeperr\\media\\font.ttf", fontsize, "THINOUTLINE") 
    f.text:SetText(text)
    if not anchor then
        anchor = "CENTER"
    end
    f.text:SetPoint(anchor, f, anchor, 0, 0)
    f.text:SetTextColor( r, g, b, a)
    f:SetSize(width, height)
    self:setFrameTexture(f, 1)
    self:setFrameColor(f, 0.1, 0.1, 0.11, 0, 0, 0, 0, 0)
    return f
end

function MS.Frame:CreateTagBox(parent, name, text, fontsize, r, g, b, a, width, height, anchor)
    local f = self:CreateTextBox(parent, name, text, fontsize, r, g, b, a, width, height, anchor)
    self:setFrameColor(f, 0.1, 0.1, 0.11, 0, r, g, b, a)
    return f
end

function MS.Frame:Create()

    local mainFrame = CreateFrame("Frame", "MSMainFrame", UIParent)
    mainFrame:SetFrameLevel(7)
    mainFrame:SetSize(400, 600)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", -250, 0)
    self:setFrameTexture(mainFrame, 1)
    self:setFrameColor(mainFrame, 0.15, 0.15, 0.16, 1, 0.15, 0.15, 0.16, 1)
    MS.Frame:setFrameMovable(mainFrame)

    local initializeFrame = CreateFrame("Frame", "MSInitializeFrame", mainFrame)
    initializeFrame:SetFrameLevel(15)
    initializeFrame:SetSize(1000, 600)
    initializeFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
    self:setFrameTexture(initializeFrame, 1)
    self:setFrameColor(initializeFrame, 0.1, 0.1, 0.11, 1, 0.1, 0.1, 0.11, 1)
    initializeFrame.Text = self:CreateTextBox(initializeFrame, nil, L["Initializing"], 20, 0.95, 0.85, 0.75, 1, 80, 20)
    initializeFrame.Text:SetPoint("CENTER", initializeFrame, "CENTER", 10, 0)
    mainFrame.initializeFrame = initializeFrame
    
    -- --------------------
    -- Title Box
    local titleBox = CreateFrame("Frame", "MSMainFrameTitle", mainFrame)
    titleBox:SetPoint("TOP", mainFrame, "TOP", 0, 0)
    titleBox:SetSize(400, 40)
    self:setFrameTexture(titleBox, 0)
    self:setFrameColor(titleBox, 0.1, 0.1, 0.11, 0, 0.1, 0.1, 0.1, 0)
    mainFrame.titleBox = titleBox

    local titleText = self:CreateTextBox(titleBox, "MSMainFrameTitleText", "Minesweeperr", 14, 0.95, 0.85, 0.75, 1, 80, 14)
    titleText:SetPoint("LEFT", titleBox, "LEFT", 10, 0)
    mainFrame.titleText = titleText

    local closeText = self:CreateTextBox(titleBox, "MSMainFrameCloseText", L["Close"], 14, 0.95, 0.85, 0.75, 1, 30, 14)
    closeText:SetPoint("RIGHT", titleBox, "RIGHT", -15, 0)
    closeText:EnableMouse(true)
    closeText:SetScript("OnMouseUp", function(self) mainFrame:Hide() end)
    mainFrame.closeText = closeText

    local refreshText = self:CreateTextBox(titleBox, "MSMainFrameRefreshText", L["Refresh"], 14, 0.95, 0.85, 0.75, 1, 30, 14)
    refreshText:SetPoint("RIGHT", titleBox, "RIGHT", -50, 0)
    refreshText:EnableMouse(true)
    refreshText:SetScript("OnMouseUp", function(self) MS:SendMessage("MSCustomEvent", "REFRESH_ALL") end)
    mainFrame.refreshText = refreshText

    local historyText = self:CreateTextBox(titleBox, "MSMainFrameRefreshText", L["History"], 14, 0.95, 0.85, 0.75, 1, 30, 14)
    historyText:SetPoint("RIGHT", titleBox, "RIGHT", -85, 0)
    historyText:EnableMouse(true)
    historyText:SetScript("OnMouseUp", function(self) MS.Frame:ToggleHistory() end)
    mainFrame.historyText = historyText


    -- Main Unit Info Panels
    MS.Frame.currentSelectPanel = "player"
    MS.Frame.currentSelectPanelUID = "player"
    MS.Frame.panels = {}
    for i = 0, 4, 1 do
        local panel = MS.Frame:CreateUnitPanel(mainFrame, i)
        panel:SetPoint("TOP", mainFrame, "TOP", 0, -50-i*110)
        MS.Frame.panels[i] = panel
        MS.Frame.panels[MS.Const.partyMembersTempl[i+1]] = panel
        -- MS.Frame.panels[i]:Hide()
    end

    local detailsFrame = MS.Frame:CreateDetails(mainFrame)
    local historyFrame = MS.Frame:CreateHistoryFrame(mainFrame)
    local qcFrame = MS.Frame:CreateQCFrame()

    MS.Frame.qcFrame = qcFrame
    MS.Frame.mainFrame = mainFrame
    MS.Frame.detailsFrame = detailsFrame
    MS.Frame.historyFrame = historyFrame
    tinsert(UISpecialFrames, "MSMainFrame")
end

function MS.Frame:CreateUnitPanel(parent, idx)
    local panel = CreateFrame("Frame", "MSUnitPanel"..idx, parent)
    panel:SetSize(400, 110)
    self:setFrameTexture(panel, 0)
    self:setFrameColor(panel, 0.1, 0.1, 0.11, 0, 0, 0, 0, 0)

    local panelBG = CreateFrame("Frame", "MSUnitPanelBG"..idx, panel)
    panelBG:SetFrameLevel(8)
    panelBG:SetSize(400, 110)
    self:setFrameTexture(panelBG, 1)
    self:setFrameColor(panelBG, 0.1, 0.1, 0.11, 1, 0, 0, 0, 0)
    panelBG:SetPoint("CENTER", panel, "CENTER", 0,0)
    panelBG:SetAlpha(0)
    panelBG.hover = false
    panelBG.keepHover = false
    panelBG:EnableMouse(true)
    panelBG:SetScript("OnMouseUp", function(self, mouse)
        if mouse == "LeftButton" then
            MS:SendMessage("MSCustomEvent", "PANEL_CLICK", idx)
        elseif mouse == "RightButton" then
            MS:SendMessage("MSCustomEvent", "REFRESH_UNIT", idx)
        end
    end)
    panel.panelBG = panelBG

    panel.refreshIcon = CreateFrame("Frame", nil, panel)
    panel.refreshIcon:SetSize(14, 14)
    panel.refreshIcon:SetPoint("CENTER", panel, "TOPLEFT", 20, -25)
    self:setFrameTexture(panel.refreshIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\refresh")
    self:setFrameColor(panel.refreshIcon, 0.5, 0.5, 0.5, 1, 0, 0, 0, 0)
    MS.Frame:setRotationAnimation(panel.refreshIcon)
    panel.refreshIcon:Hide()

    panel.classIcon = CreateFrame("Frame", nil, panel)
    panel.classIcon:SetSize(50, 50)
    self:setFrameTexture(panel.classIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\classicons\\NONE")
    self:setFrameColor(panel.classIcon, 1, 1, 1, 1, 0, 0, 0, 0)
    panel.classIcon:SetPoint("LEFT", panel, "LEFT", 20, 0)

    panel.specText = self:CreateTextBox(panel.classIcon, nil, "Spec", 12, 0.95, 0.85, 0.75, 1, 30, 12)
    panel.specText:SetPoint("BOTTOM", panel.classIcon, "BOTTOM", 0, 0)

    panel.nameText = self:CreateTextBox(panel, nil, "UnitName", 16, 0.95, 0.85, 0.75, 1, 150, 16, "LEFT")
    panel.nameText:SetPoint("TOPLEFT", panel, "TOPLEFT", 90, -15)
    panel.nameText.splitLine = CreateFrame("Frame", nil, panel.nameText)
    panel.nameText.splitLine:SetSize(40, 1)
    panel.nameText.splitLine:SetPoint("BOTTOMLEFT", panel.nameText, "BOTTOMLEFT", 0, -2)
    self:setFrameTexture(panel.nameText.splitLine, 0)
    self:setFrameColor(panel.nameText.splitLine, 0.25, 0.25, 0.25, 1, 0.15, 0.15, 0.16, 0)

    panel.authorTag = self:CreateTagBox(panel, nil, L["Author"], 12, 0.8, 0.7, 0.6, 1, 30, 16, "CENTER")
    panel.authorTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 2, 0)

    panel.goodRatingTag = self:CreateTagBox(panel, nil, L["RatingGood"], 12, 0.5, 0.9, 0.5, 1, 35, 16, "CENTER")
    panel.goodRatingTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 2, 0)

    panel.badRatingTag = self:CreateTagBox(panel, nil, L["RatingBad"], 12, 0.9, 0.2, 0.2, 1, 35, 16, "CENTER")
    panel.badRatingTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 2, 0)


    panel.serverText = self:CreateTextBox(panel, nil, "UnitServer", 10, 0.8, 0.7, 0.6, 1, 150, 10, "LEFT")
    panel.serverText:SetPoint("TOPLEFT", panel, "TOPLEFT", 90, -35)

    panel.achiIcon = CreateFrame("Frame", nil, panel)
    panel.achiIcon:SetSize(12, 12)
    panel.achiIcon:SetPoint("TOPLEFT", panel, "TOPLEFT", 90, -55)
    self:setFrameTexture(panel.achiIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
    self:setFrameColor(panel.achiIcon, 1, 1, 1, 1, 0, 0, 0, 0)

    panel.achiText = self:CreateTextBox(panel, nil, "Achievement Status", 12, 0.8, 0.7, 0.6, 1, 50, 12, "LEFT")
    panel.achiText:SetPoint("LEFT", panel.achiIcon, "RIGHT", 5, 0)


    panel.ilvlTextLabel = self:CreateTextBox(panel, nil, "iLvl", 12, 0.95, 0.85, 0.75, 1, 15, 12, "LEFT")
    panel.ilvlTextLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 90, -80)
    panel.ilvlTextValue = self:CreateTextBox(panel, nil, "---", 12, 0.95, 0.85, 0.75, 1, 15, 12, "LEFT")
    panel.ilvlTextValue:SetPoint("TOPLEFT", panel, "TOPLEFT", 110, -80)

    panel.slotTextLabel = self:CreateTextBox(panel, nil, "Slot", 12, 0.95, 0.85, 0.75, 1, 15, 12, "LEFT")
    panel.slotTextLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 135, -80)
    panel.slotTextValue = self:CreateTextBox(panel, nil, "--", 12, 0.95, 0.85, 0.75, 1, 15, 12, "LEFT")
    panel.slotTextValue:SetPoint("TOPLEFT", panel, "TOPLEFT", 155, -80)

    panel.corrTextLabel = self:CreateTextBox(panel, nil, "Corr.", 12, 0.95, 0.85, 0.75, 1, 15, 12, "LEFT")
    panel.corrTextLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 180, -80)
    panel.corrTextValue = self:CreateTextBox(panel, nil, "--", 12, 0.95, 0.85, 0.75, 1, 15, 12, "LEFT")
    panel.corrTextValue:SetPoint("TOPLEFT", panel, "TOPLEFT", 205, -80)

    -- Dungeon Count Icon
    local countIcons = {}
    for j = 1, 10, 1
    do
        local countIcon = CreateFrame("Frame", "MSPanelCountIcon"..idx..j, panel)
        countIcon:SetSize(16, 16)
        countIcon:SetPoint("TOPLEFT", panel, "TOPLEFT", 290 + math.fmod((j-1), 5) * 18, -32 + math.modf((j-1)/5) * 18)
        self:setFrameTexture(countIcon, 0)
        self:setFrameColor(countIcon, 0.2, 0.2, 0.2, 1, 0, 0, 0, 0)
        countIcons[j] = countIcon
    end
    panel.countIcons = countIcons

    panel.countSumTextLabel = self:CreateTextBox(panel, nil, L["Sum"], 12, 0.95, 0.85, 0.75, 1, 15, 12, "RIGHT")
    panel.countSumTextLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -40, -55)
    panel.countSumTextValue = self:CreateTextBox(panel, nil, "----", 12, 0.95, 0.85, 0.75, 1, 30, 12, "RIGHT")
    panel.countSumTextValue:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -20, -55)

    panel.currentKeyTextLabel = self:CreateTextBox(panel, nil, L["currentKeystone"], 12, 0.95, 0.85, 0.75, 1, 15, 12, "RIGHT")
    panel.currentKeyTextLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -90, -80)
    panel.currentKeyTextValue = self:CreateTextBox(panel, nil, "--", 12, 0.95, 0.85, 0.75, 1, 20, 12, "RIGHT")
    panel.currentKeyTextValue:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -70, -80)

    panel.maxInTimeTextLabel = self:CreateTextBox(panel, nil, L["maxIntime"], 12, 0.95, 0.85, 0.75, 1, 15, 12, "RIGHT")
    panel.maxInTimeTextLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -40, -80)
    panel.maxInTimeTextValue = self:CreateTextBox(panel, nil, "--", 12, 0.95, 0.85, 0.75, 1, 20, 12, "RIGHT")
    panel.maxInTimeTextValue:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -20, -80)
    
    return panel
end

function MS.Frame:RefreshUnitPanel(unitInfo)
    if not unitInfo then
        return
    end
    local panel = MS.Frame.panels[unitInfo["uid"]]
    
    if unitInfo["classIndex"] then
        self:setFrameTexture(panel.classIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\classicons\\"..MS.Const.classIdx[unitInfo["classIndex"]])
    else
        self:setFrameTexture(panel.classIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\classicons\\NONE.tga")
    end
    self:setFrameColor(panel.classIcon, 1, 1, 1, 1, 0, 0, 0, 0)
    
    if unitInfo["currentSpecName"] then
        panel.specText.text:SetText(unitInfo["currentSpecName"])
        panel.specText.text:SetTextColor(unitInfo["classColorR"], unitInfo["classColorG"], unitInfo["classColorB"], 1)
    else
        panel.specText.text:SetText("Spec")
    end

    if unitInfo["name"] then
        panel.nameText.text:SetText(unitInfo["name"])
        panel.nameText.text:SetTextColor(unitInfo["classColorR"], unitInfo["classColorG"], unitInfo["classColorB"], 1)
    else
        panel.nameText.text:SetText("UnitName")
        panel.nameText.text:SetTextColor(0.95, 0.85, 0.75, 1)
    end

    if unitInfo["server"] then
        panel.serverText.text:SetText(unitInfo["server"])
    else
        panel.serverText.text:SetText("UnitServer")
    end

    if unitInfo["mainAchi"] then
        if unitInfo["mainAchi"] == 0 then
            self:setFrameTexture(panel.achiIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
            panel.achiText.text:SetText(L["Uncompleted"])
        else
            self:setFrameTexture(panel.achiIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\star")
            panel.achiText.text:SetText(unitInfo["mainAchi"])
        end
    else
        self:setFrameTexture(panel.achiIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
        panel.achiText.text:SetText(L["watingRefresh"])
    end
    self:setFrameColor(panel.achiIcon, 1, 1, 1, 1, 0, 0, 0, 0)
    panel.achiText:SetSize(panel.achiText.text:GetStringWidth(), 15)

    if unitInfo["ilvl"] then
        panel.ilvlTextValue.text:SetText(unitInfo["ilvl"])
    else
        panel.ilvlTextValue.text:SetText("--")
    end

    if unitInfo["gemSlot"] then
        panel.slotTextValue.text:SetText(unitInfo["gemSlot"])
        if unitInfo["gemSlot"] >= 5 and unitInfo["gemSlot"] < 8 then
            panel.slotTextValue.text:SetTextColor(0.9, 0.8, 1, 1)
        elseif unitInfo["gemSlot"] >= 8 then
            panel.slotTextValue.text:SetTextColor(1, 0.55, 0, 1)
        else
            panel.slotTextValue.text:SetTextColor(0.7, 0.7, 0.7, 1)
        end
    else
        panel.slotTextValue.text:SetText("--")
        panel.slotTextValue.text:SetTextColor(0.9, 0.85, 0.85, 1)
    end

    if unitInfo["corruptionValue"] then
        panel.corrTextValue.text:SetText(unitInfo["corruptionValue"])
        if unitInfo["corruptionValue"] >= 40 and unitInfo["corruptionValue"] < 60 then
            panel.corrTextValue.text:SetTextColor(0.9, 0.8, 1, 1)
        elseif unitInfo["corruptionValue"] >= 60 then
            panel.corrTextValue.text:SetTextColor(1, 0.1, 0.1, 1)
        else
            panel.corrTextValue.text:SetTextColor(0.9, 0.85, 0.85, 1)
        end
    else
        panel.corrTextValue.text:SetText("--")
        panel.corrTextValue.text:SetTextColor(0.9, 0.85, 0.85, 1)
    end

    if unitInfo["dungeonCount"] then
        local sumNum = 0
        for j = 1, 10, 1
        do
            local count = unitInfo["dungeonCount"][MS.Const.dungeonIds[j]]
            if count and count ~= '\-\-' then
                sumNum = sumNum + count
                self:setFrameTexture(panel.countIcons[j], 0)
                self:setFrameColor(panel.countIcons[j], 0.2+0.6*count/50, 0.2, 0.2, 1, 0, 0, 0, 0)
            end
        end
        panel.countSumTextValue.text:SetText(sumNum)
    else
        for j = 1, 10, 1
        do
            self:setFrameTexture(panel.countIcons[j], 0)
            self:setFrameColor(panel.countIcons[j], 0.2, 0.2, 0.2, 1, 0, 0, 0, 0)
        end
        panel.countSumTextValue.text:SetText("---")
    end

    if unitInfo["keystoneInfo"] then
        if unitInfo["keystoneInfo"]["c"] then
            panel.currentKeyTextValue.text:SetText(unitInfo["keystoneInfo"]["c"]["lvl"])
        else
            panel.currentKeyTextValue.text:SetText("--")
        end
        if unitInfo["keystoneInfo"]["mi"] then
            panel.maxInTimeTextValue.text:SetText(unitInfo["keystoneInfo"]["mi"]["lvl"])
        else
            panel.maxInTimeTextValue.text:SetText("--")
        end
    end

    if unitInfo["rating"] then
        if unitInfo["rating"] == 1 then
            panel.goodRatingTag:Show()
            panel.goodRatingTag.text:SetText(L["RatingGood"])
            if MS:getN(unitInfo["badRatingCount"]) == 0 then
                panel.badRatingTag:Hide()
            end
        elseif unitInfo["rating"] == 0 then
            panel.badRatingTag:Show()
            panel.badRatingTag.text:SetText(L["RatingBad"])
            if MS:getN(unitInfo["goodRatingCount"]) == 0 then
                panel.goodRatingTag:Hide()
            end
            if panel.goodRatingTag:IsShown() then
                panel.badRatingTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 40, 0)
            else
                panel.badRatingTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 2, 0)
            end
        end
    else
        panel.goodRatingTag:Hide()
        panel.badRatingTag:Hide()
        panel.goodRatingTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 2, 0)
        panel.badRatingTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 2, 0)
    end

    if unitInfo["goodRatingCount"] then
        if MS:getN(unitInfo["goodRatingCount"]) > 0 then
            panel.goodRatingTag:Show()
            panel.goodRatingTag.text:SetText(L["RatingGood"].." "..MS:getN(unitInfo["goodRatingCount"]))
        end
    end
    if unitInfo["badRatingCount"] then
        if MS:getN(unitInfo["badRatingCount"]) > 0 then
            panel.badRatingTag:Show()
            panel.badRatingTag.text:SetText(L["RatingBad"].." "..MS:getN(unitInfo["badRatingCount"]))
            if panel.goodRatingTag:IsShown() then
                panel.badRatingTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 40, 0)
            else
                panel.badRatingTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 2, 0)
            end
        end
    end

    
    if MS.Const.autherGUID[unitInfo["GUID"]] then
        panel.authorTag:Show()
        if panel.badRatingTag:IsShown() then
            panel.authorTag:SetPoint("LEFT", panel.badRatingTag, "RIGHT", 2, 0)
        elseif panel.goodRatingTag:IsShown() then
            panel.authorTag:SetPoint("LEFT", panel.goodRatingTag, "RIGHT", 2, 0)
        else
            panel.authorTag:SetPoint("LEFT", panel.nameText.text, "RIGHT", 2, 0)
        end
    else
        panel.authorTag:Hide()
    end


    if MS.Frame.currentSelectPanel == unitInfo["uid"] then
        MS.Frame:onPanelClick(MS.Frame.currentSelectPanel, unitInfo)
    end
end


function MS.Frame:onPanelClick(idx, unitInfo)
    if not unitInfo then
        return
    end
    if not idx then
        idx = unitInfo["uid"]
    end
    MS.Frame.currentSelectPanel = idx
    MS.Frame.currentSelectPanelUID = unitInfo["uid"]
    MS.Frame.detailsFrame:Show()
    MS.Frame:RefreshUnitDetails(unitInfo)

    for _, panel in pairs(MS.Frame.panels) do
        panel.panelBG.clicked = false
        panel.panelBG:SetAlpha(0)
    end
    MS.Frame.panels[idx].panelBG.clicked = true
    MS.Frame.panels[idx].panelBG:SetAlpha(1)
end

function MS.Frame:updateDetails(unitInfo)
    if not unitInfo then
        return
    end

    if MS.Frame.currentSelectPanelUID == unitInfo["uid"] then
        MS.Frame:RefreshUnitDetails(unitInfo)
    end

end

function MS.Frame:onTogglePanel(partyMembers)
    for i, uid in pairs(MS.Const.partyMembersTempl) do
        if partyMembers[uid] then
            MS.Frame.panels[uid]:Show()
        else
            MS.Frame.panels[uid]:Hide()
        end
    end
end

function MS.Frame:triggerRefreshIcon(uid)
    MS.Frame.panels[uid].refreshIcon:Show()
    MS.Frame.panels[uid].refreshIcon.ag:Play()
end

function MS.Frame:shutdownRefreshIcon(uid)
    MS.Frame.panels[uid].refreshIcon:Hide()
    MS.Frame.panels[uid].refreshIcon.ag:Stop()
end

-- ------------------------
-- Details Frame

function MS.Frame:CreateDetailsSubTitle(parent, text)
    local subtitleFrame = self:CreateTextBox(parent, nil, text, 14, 0.95, 0.85, 0.75, 1, 200, 30, "LEFT")

    local rightGuideline = CreateFrame("Frame", nil, subtitleFrame)
    rightGuideline:SetSize(180, 1)
    rightGuideline:SetPoint("LEFT", subtitleFrame.text, "RIGHT", 3, 0)
    self:setFrameTexture(rightGuideline, 0)
    self:setFrameColor(rightGuideline, 0.3, 0.3, 0.3, 1, 0.15, 0.15, 0.16, 0)
    subtitleFrame.rightGuideline = rightGuideline

    return subtitleFrame
end

function MS.Frame:CreatePortrait(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(70)
    f:SetWidth(70)

    local img = f:CreateTexture(nil, "BACKGROUND")
    img:SetHeight(70)
    img:SetWidth(70)
    img:SetPoint("TOPLEFT", 0, 0)
    SetPortraitTexture(img, "player")
    f.img = img
    return f
end

function MS.Frame:CreateDetailsGearList(parent)
    local gearFrame = CreateFrame("Frame", nil, parent)
    gearFrame:SetSize(200, 400)

    local gearItems = {}
    for i = 1, 18, 1 do
        local gearItem = CreateFrame("Frame", nil, gearFrame)
        gearItem:SetSize(200, 16)
        gearItem:SetPoint("TOP", gearFrame, "TOP", 0, -(i-1)*16)

        gearItem.lvl = self:CreateTextBox(gearItem, nil, "", 12, 0.6, 0.6, 0.6, 1, 20, 12, "LEFT")
        gearItem.lvl:SetPoint("LEFT", gearItem, "LEFT", 0, 0)

        gearItem.link = self:CreateTextBox(gearItem, nil, "", 12, 0.6, 0.6, 0.6, 1, 160, 12, "LEFT")
        gearItem.link:SetPoint("LEFT", gearItem, "LEFT", 30, 0)

        gearItems[i] = gearItem
    end

    gearFrame.gearItems = gearItems

    gearFrame.setGearList = function(self, gearList)
        self:initGearList()
        local i = 1
        for slot, gearLink in pairs(gearList) do
            self.gearItems[i].lvl.text:SetText(gearLink["lvl"])
            self.gearItems[i].link.text:SetText(gearLink["link"])
            self.gearItems[i]:SetScript("OnEnter", function(self)
                GameTooltip:Hide()
                GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, 20)
                GameTooltip:SetHyperlink(gearLink["link"])
                GameTooltip:Show()
            end)
            self.gearItems[i]:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)      
            i = i + 1
        end
    end

    gearFrame.initGearList = function(self)
        for i = 1, 18, 1 do
            self.gearItems[i].lvl.text:SetText("")
            self.gearItems[i].link.text:SetText("")
        end
    end

    return gearFrame
end

function MS.Frame:CreateDetailsAttributeList(parent)
    local attrFrame = CreateFrame("Frame", nil, parent)
    attrFrame:SetSize(200, 80)
    local labels = {
        [1] = ITEM_MOD_CRIT_RATING_SHORT,
        [2] = ITEM_MOD_HASTE_RATING_SHORT,
        [3] = ITEM_MOD_MASTERY_RATING_SHORT,
        [4] = ITEM_MOD_VERSATILITY,
        ["C"] = 1,
        ["H"] = 2,
        ["M"] = 3,
        ["V"] = 4
    }
    local attrItems = {}
    for i = 1, 4, 1 do
        local attrItem = CreateFrame("Frame", nil, attrFrame)
        attrItem:SetSize(200, 20)
        attrItem:SetPoint("TOP", attrFrame, "TOP", 0, -(i-1)*20)
        attrItem.label = self:CreateTextBox(attrItem, nil, labels[i], 12, 0.95, 0.85, 0.75, 1, 20, 12, "LEFT")
        attrItem.label:SetPoint("LEFT", attrItem, "LEFT", 0, 0)

        -- For test
        attrItem.progressBar = CreateFrame("Frame", nil, attrItem)
        attrItem.progressBar:SetSize(1, 1)
        attrItem.progressBar:SetPoint("LEFT", attrItem.label, "RIGHT", 5, 0)
        self:setFrameTexture(attrItem.progressBar, 0)
        self:setFrameColor(attrItem.progressBar, 0.95, 0.85, 0.75, 1, 0.15, 0.15, 0.16, 0)

        attrItem.progressSpark = CreateFrame("Frame", nil, attrItem)
        attrItem.progressSpark:SetSize(3, 3)
        attrItem.progressSpark:SetPoint("LEFT", attrItem.progressBar, "RIGHT", 0, 0)
        self:setFrameTexture(attrItem.progressSpark, 0)
        self:setFrameColor(attrItem.progressSpark, 0.95, 0.95, 0.95, 1, 0.15, 0.15, 0.16, 0)

        attrItem.progressNum = self:CreateTextBox(attrItem, nil, 0, 12, 0.95, 0.85, 0.75, 1, 20, 12, "LEFT")
        attrItem.progressNum:SetPoint("LEFT", attrItem.progressBar, "RIGHT", 7, 0)

        attrItems[i] = attrItem
    end

    attrFrame.attrItems = attrItems

    attrFrame.setAttrList = function(self, attrList)
        self:initAttrList()
        for name, value in pairs(attrList) do
            local value = math.floor(value+0.5)
            self.attrItems[labels[name]].progressBar:SetSize(math.min(100, math.max(value, 1)), 1)
            self.attrItems[labels[name]].progressSpark:SetPoint("LEFT", self.attrItems[labels[name]].progressBar, "RIGHT", 0, 0)
            self.attrItems[labels[name]].progressNum.text:SetText(value)
        end
    end

    attrFrame.initAttrList = function(self)
        for i = 1, 4, 1 do
            self.attrItems[i].progressBar:SetSize(1, 1)
            self.attrItems[i].progressSpark:SetPoint("LEFT", self.attrItems[i].progressBar, "RIGHT", 0, 0)
            self.attrItems[i].progressNum.text:SetText("0")
        end
    end
    return attrFrame
end


function MS.Frame:CreateDetailsAchievementList(parent)
    local achiFrame = CreateFrame("Frame", nil, parent)
    achiFrame:SetSize(200, 120)
    local achiItems = {}
    local labels = {
        [1] = "mainAchi",
        [2] = "cAchi1",
        [3] = "cAchi2",
        [4] = "cAchi3"
    }
    for i = 1, 4, 1 do
        local achiItem = CreateFrame("Frame", nil, achiFrame)
        achiItem:SetSize(200, 30)
        achiItem:SetPoint("TOP", achiFrame, "TOP", 0, -(i-1)*30)

        achiItem.icon = CreateFrame("Frame", nil, achiItem)
        achiItem.icon:SetSize(14, 14)
        achiItem.icon:SetPoint("LEFT", achiItem, "LEFT", 0, 0)
        self:setFrameTexture(achiItem.icon, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
        self:setFrameColor(achiItem.icon, 1, 1, 1, 1, 0, 0, 0, 0)

        achiItem.label = self:CreateTextBox(achiItem, nil, "Achievement Name", 12, 0.5, 0.5, 0.5, 1, 160, 12, "LEFT")
        achiItem.label:SetPoint("LEFT", achiItem.icon, "RIGHT", 10, 5)

        achiItem.status = self:CreateTextBox(achiItem, nil, "Status", 10, 0.5, 0.5, 0.5, 1, 100, 10, "LEFT")
        achiItem.status:SetPoint("LEFT", achiItem.icon, "RIGHT", 15, -8)


        achiItems[i] = achiItem
    end

    achiFrame.achiItems = achiItems
    achiFrame.setAchiList = function(self, unitInfo)
        self:initAchiList()
        for i = 1, 4, 1 do
            local achiStat = unitInfo[labels[i]]
            local achiName = unitInfo[labels[i].."Name"]
            if achiStat then
                if achiStat == 0 then
                    MS.Frame:setFrameTexture(self.achiItems[i].icon, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
                    self.achiItems[i].status.text:SetText(L["Uncompleted"])
                    self.achiItems[i].label.text:SetTextColor(0.4, 0.4, 0.4, 1)
                    self.achiItems[i].status.text:SetTextColor(0.4, 0.4, 0.4, 1)
                else
                    MS.Frame:setFrameTexture(self.achiItems[i].icon, 0, "Interface\\Addons\\Minesweeperr\\media\\star")
                    self.achiItems[i].status.text:SetText(achiStat)
                    self.achiItems[i].label.text:SetTextColor(0.95, 0.85, 0.75, 1)
                    self.achiItems[i].status.text:SetTextColor(0.5, 0.5, 0.5, 1)
                end
            else
                MS.Frame:setFrameTexture(self.achiItems[i].icon, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
                self.achiItems[i].status.text:SetText(L["watingRefresh"])
                self.achiItems[i].label.text:SetTextColor(0.4, 0.4, 0.4, 1)
                self.achiItems[i].status.text:SetTextColor(0.4, 0.4, 0.4, 1)
            end
            
            MS.Frame:setFrameColor(self.achiItems[i].icon, 1, 1, 1, 1, 0, 0, 0, 0)
            self.achiItems[i].label.text:SetText(achiName)
        end
    end
    achiFrame.initAchiList = function(self)
        for i = 1, 4, 1 do
            MS.Frame:setFrameTexture(self.achiItems[i].icon, 0, "Interface\\Addons\\Minesweeperr\\media\\unstar")
            self.achiItems[i].status.text:SetText(L["watingRefresh"])
            self.achiItems[i].label.text:SetTextColor(0.4, 0.4, 0.4, 1)
            self.achiItems[i].status.text:SetTextColor(0.4, 0.4, 0.4, 1)
            MS.Frame:setFrameColor(self.achiItems[i].icon, 1, 1, 1, 1, 0, 0, 0, 0)
            self.achiItems[i].label.text:SetText(L["watingRefresh"])
        end
    end

    return achiFrame
end

function MS.Frame:CreateDetailsCorruptionList(parent)
    local corruptionFrame = CreateFrame("Frame", nil, parent)
    corruptionFrame:SetSize(200, 160)

    local corruptionItems = {}
    for i = 1, 10, 1 do
        local corruptionItem = self:CreateTextBox(corruptionFrame, nil, "", 12, 0.95, 0.85, 0.75, 1, 100, 12, "LEFT")
        corruptionItem:SetPoint("TOPLEFT", corruptionFrame, "TOPLEFT", 100*math.fmod((i-1), 2), -math.floor((i-1)/2)*16)
        corruptionItems[i] = corruptionItem
    end

    corruptionFrame.corruptionItems = corruptionItems

    corruptionFrame.setCorrList = function(self, corrList)
        self:initCorrList()
        local i = 1
        for id, corr in pairs(corrList) do
            self.corruptionItems[i].text:SetText(L[corr["name"]].." "..corr["level"].." * "..corr['count'])
            i = i + 1
        end
    end
    corruptionFrame.initCorrList = function(self)
        for i = 1, 10, 1 do
            self.corruptionItems[i].text:SetText("")
        end
    end
    return corruptionFrame
end

function MS.Frame:CreateDetailsDungeonList(parent)
    local dungeonFrame = CreateFrame("Frame", nil, parent)
    dungeonFrame:SetSize(215, 90)
    self:setFrameTexture(dungeonFrame, 1)
    self:setFrameColor(dungeonFrame, 0.15, 0.15, 0.16, 0, 0.2, 0.2, 0.2, 0)
    local dungeonItems = {}
    for i = 1, 10, 1 do
        local dungeonItem = CreateFrame("Frame", nil, dungeonFrame)
        dungeonItem:SetSize(60, 16)
        dungeonItem:SetPoint("TOPLEFT", dungeonFrame, "TOPLEFT", 15 + 120*math.fmod((i-1), 2), -5-math.modf((i-1) / 2)*16)

        dungeonItem.name = self:CreateTextBox(dungeonItem, nil, MS.Const.dungeonNames[i], 12, 0.95, 0.85, 0.75, 1, 30, 12, "LEFT")
        dungeonItem.name:SetPoint("LEFT", dungeonItem, "LEFT", 0, 0)
        dungeonItem.count = self:CreateTextBox(dungeonItem, nil, "--", 12, 0.6, 0.6, 0.6, 1, 30, 12, "RIGHT")
        dungeonItem.count:SetPoint("RIGHT", dungeonItem, "RIGHT", 0, 0)

        dungeonItems[i] = dungeonItem
    end

    dungeonFrame.dungeonItems = dungeonItems
    dungeonFrame.setDungeonList = function(self, dungeonList)
        self:initDungeonList()
        for i = 1, 10, 1 do
            self.dungeonItems[i].count.text:SetText(dungeonList[MS.Const.dungeonIds[i]])
        end
    end
    dungeonFrame.initDungeonList = function(self, dungeonList)
        for i = 1, 10, 1 do
            self.dungeonItems[i].count.text:SetText("--")
        end
    end
    return dungeonFrame
end

function MS.Frame:CreateDetails(parent)
    local detailsFrame = CreateFrame("Frame", "MSDetailsFrame", parent)
    detailsFrame:SetFrameLevel(7)
    detailsFrame:SetSize(600, 600)
    detailsFrame:SetPoint("LEFT", parent, "RIGHT", 0, 0)
    self:setFrameTexture(detailsFrame, 0)
    self:setFrameColor(detailsFrame, 0.1, 0.1, 0.11, 1, 0.15, 0.15, 0.16, 0)

    -- --------------------
    -- Portrait
    local portraitBox = MS.Frame:CreatePortrait(detailsFrame)
    portraitBox:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 50, -40)
    detailsFrame.portraitBox = portraitBox
    -- --------------------
    -- Name Box
    detailsFrame.nameText = self:CreateTextBox(detailsFrame, "MSDetailsName", "UnitName", 24, 0.95, 0.85, 0.75, 1, 200, 24, "LEFT")
    detailsFrame.nameText:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 140, -40)

    -- --------------------
    -- Server Box
    detailsFrame.serverText = self:CreateTextBox(detailsFrame, "MSDetailsServer", "UnitServer", 12, 0.6, 0.6, 0.6, 1, 200, 12, "LEFT")
    detailsFrame.serverText:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 140, -72)

    -- --------------------
    -- Guild Box
    detailsFrame.guildText = self:CreateTextBox(detailsFrame, "MSDetailsGuild", "<Guild>", 14, 0.6, 0.6, 0.6, 1, 200, 14, "LEFT")
    detailsFrame.guildText:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 140, -90)
    -- --------------------
    -- iLvl Box
    detailsFrame.iLvlText = self:CreateTextBox(detailsFrame, "MSDetailsiLvl", "---", 36, 0.6, 0.6, 0.6, 1, 200, 36, "RIGHT")
    detailsFrame.iLvlText:SetPoint("TOPRIGHT", detailsFrame, "TOPRIGHT", -55, -45)

    -- ---------------------
    -- Rating Button
    detailsFrame.ratingGoodBtn = self:CreateTagBox(detailsFrame, "MSDetailsRatingGoodBtn", L["RatingGood"], 12, 0.5, 0.5, 0.5, 1, 30, 16, "CENTER")
    detailsFrame.ratingGoodBtn:SetPoint("TOPRIGHT", detailsFrame, "TOPRIGHT", -55, -85)
    detailsFrame.ratingGoodBtn:SetScript("OnEnter", function(self)
        detailsFrame.ratingGoodBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
        MS.Frame:setFrameColor(detailsFrame.ratingGoodBtn, 0.2, 0.2, 0.1, 1, 0.95, 0.85, 0.75, 1)
    end)
    detailsFrame.ratingGoodBtn:SetScript("OnLeave", function(self)
        detailsFrame.ratingGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(detailsFrame.ratingGoodBtn, 0.2, 0.2, 0.1, 0, 0.5, 0.5, 0.5, 1)
    end)
    detailsFrame.ratingGoodBtn:SetScript("OnMouseUp", function(self)
        MS:SendMessage("MSCustomEvent", "SAVE_GOOD_RATING", detailsFrame.guid)
    end)

    detailsFrame.ratingBadBtn = self:CreateTagBox(detailsFrame, "MSDetailsRatingBadBtn", L["RatingBad"], 12, 0.5, 0.5, 0.5, 1, 30, 16, "CENTER")
    detailsFrame.ratingBadBtn:SetPoint("TOPRIGHT", detailsFrame, "TOPRIGHT", -90, -85)
    detailsFrame.ratingBadBtn:SetScript("OnEnter", function(self)
        detailsFrame.ratingBadBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
        MS.Frame:setFrameColor(detailsFrame.ratingBadBtn, 0.2, 0.2, 0.1, 1, 0.95, 0.85, 0.75, 1)
    end)
    detailsFrame.ratingBadBtn:SetScript("OnLeave", function(self)
        detailsFrame.ratingBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(detailsFrame.ratingBadBtn, 0.2, 0.2, 0.1, 0, 0.5, 0.5, 0.5, 1)
    end)
    detailsFrame.ratingBadBtn:SetScript("OnMouseUp", function(self)
        MS:SendMessage("MSCustomEvent", "SAVE_BAD_RATING", detailsFrame.guid)
    end)

    -- ---------------------
    -- Gear
    local gearSubtitle = MS.Frame:CreateDetailsSubTitle(detailsFrame, L["Gear"])
    gearSubtitle:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 55, -130)

    local gearList = MS.Frame:CreateDetailsGearList(detailsFrame)
    gearList:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 70, -160)
    detailsFrame.gearList = gearList

    -- ---------------------
    -- Attribute
    local attributeSubtitle = MS.Frame:CreateDetailsSubTitle(detailsFrame, L["Attribute"])
    attributeSubtitle:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 55, -450)

    local attributeList = MS.Frame:CreateDetailsAttributeList(detailsFrame)
    attributeList:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 70, -480)
    detailsFrame.attributeList = attributeList

    -- ---------------------
    -- Achievement
    local achievementSubtitle = MS.Frame:CreateDetailsSubTitle(detailsFrame, L["Achievement"])
    achievementSubtitle:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 330, -130)

    local achievementList = MS.Frame:CreateDetailsAchievementList(detailsFrame)
    achievementList:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 345, -160)
    detailsFrame.achievementList = achievementList

    -- ----------------------
    -- Corruption
    local corruptionSubtitle = MS.Frame:CreateDetailsSubTitle(detailsFrame, L["Corruption"])
    corruptionSubtitle:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 330, -290)

    local corruptionList = MS.Frame:CreateDetailsCorruptionList(detailsFrame)
    corruptionList:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 345, -320)
    detailsFrame.corruptionList = corruptionList

    -- -----------------------
    -- Dungeon Info
    local dungeonSubtitle = MS.Frame:CreateDetailsSubTitle(detailsFrame, L["Mplus"])
    dungeonSubtitle:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 330, -400)

    
    detailsFrame.curKeyLabel = self:CreateTextBox(detailsFrame, "MSDetailsCurKeyLabel", L["currentKeystone"], 12, 0.95, 0.85, 0.75, 1, 40, 12, "LEFT")
    detailsFrame.curKeyLabel:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 345, -430)
    detailsFrame.curKeyName = self:CreateTextBox(detailsFrame, "MSDetailsCurKeyLabel", "KeyStone", 12, 0.6, 0.6, 0.6, 1, 40, 12, "LEFT")
    detailsFrame.curKeyName:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 420, -430)
    detailsFrame.curKeyLvl = self:CreateTextBox(detailsFrame, "MSDetailsCurKeyLabel", "Lvl", 12, 0.6, 0.6, 0.6, 1, 40, 12, "LEFT")
    detailsFrame.curKeyLvl:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 460, -430)
    
    detailsFrame.maxinKeyLabel = self:CreateTextBox(detailsFrame, "MSDetailsMaxinKeyLabel", L["maxIntime"], 12, 0.95, 0.85, 0.75, 1, 40, 12, "LEFT")
    detailsFrame.maxinKeyLabel:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 345, -445)
    detailsFrame.maxinKeyName = self:CreateTextBox(detailsFrame, "MSDetailsMaxinKeyLabel", "KeyStone", 12, 0.6, 0.6, 0.6, 1, 40, 12, "LEFT")
    detailsFrame.maxinKeyName:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 420, -445)
    detailsFrame.maxinKeyLvl = self:CreateTextBox(detailsFrame, "MSDetailsMaxinKeyLabel", "Lvl", 12, 0.6, 0.6, 0.6, 1, 40, 12, "LEFT")
    detailsFrame.maxinKeyLvl:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 460, -445)

    detailsFrame.maxoverKeyLabel = self:CreateTextBox(detailsFrame, "MSDetailsMaxoverKeyLabel", L["maxOvertime"], 12, 0.95, 0.85, 0.75, 1, 40, 12, "LEFT")
    detailsFrame.maxoverKeyLabel:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 345, -460)
    detailsFrame.maxoverKeyName = self:CreateTextBox(detailsFrame, "MSDetailsMaxoverKeyLabel", "KeyStone", 12, 0.6, 0.6, 0.6, 1, 40, 12, "LEFT")
    detailsFrame.maxoverKeyName:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 420, -460)
    detailsFrame.maxoverKeyLvl = self:CreateTextBox(detailsFrame, "MSDetailsMaxoverKeyLabel", "Lvl", 12, 0.6, 0.6, 0.6, 1, 40, 12, "LEFT")
    detailsFrame.maxoverKeyLvl:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 460, -460)

    local dungeonList = MS.Frame:CreateDetailsDungeonList(detailsFrame)
    dungeonList:SetPoint("TOPLEFT", detailsFrame, "TOPLEFT", 330, -490)
    detailsFrame.dungeonList = dungeonList

    return detailsFrame
end

function MS.Frame:RefreshUnitDetails(unitInfo)
    if not unitInfo then
        return
    end
    local detailsFrame = MS.Frame.detailsFrame
    detailsFrame.guid = unitInfo["GUID"]
    -- --------------------
    -- Portrait
    if unitInfo["uid"] then
        SetPortraitTexture(detailsFrame.portraitBox.img, unitInfo["uid"])
    else
        SetPortraitTexture(detailsFrame.portraitBox.img, "player")
    end
    -- --------------------
    -- Name
    if unitInfo["name"] then
        detailsFrame.nameText.text:SetText(unitInfo["name"])
        detailsFrame.nameText.text:SetTextColor(unitInfo["classColorR"], unitInfo["classColorG"], unitInfo["classColorB"], 1)
    else
        detailsFrame.nameText.text:SetText("UnitName")
        detailsFrame.nameText.text:SetTextColor(0.95, 0.85, 0.75, 1)
    end

    -- --------------------
    -- Server
    if unitInfo["server"] then
        detailsFrame.serverText.text:SetText(unitInfo["server"])
    else
        detailsFrame.serverText.text:SetText("UnitServer")
    end

    -- --------------------
    -- Guild
    if unitInfo["guild"] then
        detailsFrame.guildText.text:SetText("<"..unitInfo["guild"]..">")
    else
        detailsFrame.guildText.text:SetText("<Guild>")
    end

    -- --------------------
    -- iLvl Box
    if unitInfo["ilvl"] then
        detailsFrame.iLvlText.text:SetText(unitInfo["ilvl"])
    else
        detailsFrame.iLvlText.text:SetText(unitInfo["---"])
    end

    -- ---------------------
    -- Gear
    if unitInfo["gearLinks"] then
        detailsFrame.gearList:setGearList(unitInfo["gearLinks"])
    else
        detailsFrame.gearList:initGearList()
    end

    -- ---------------------
    -- Attribute
    if unitInfo["stat"] then
        detailsFrame.attributeList:setAttrList(unitInfo["stat"])
    else
        detailsFrame.attributeList:initAttrList()
    end

    -- ---------------------
    -- Achievement
    if unitInfo["mainAchi"] then
        detailsFrame.achievementList:setAchiList(unitInfo)
    else
        detailsFrame.achievementList:initAchiList()
    end

    -- ----------------------
    -- Corruption
    if unitInfo["corruptionList"] then
        detailsFrame.corruptionList:setCorrList(unitInfo["corruptionList"])
    else
        detailsFrame.corruptionList:initCorrList()
    end

    -----------------------
    -- Dungeon Info
    if unitInfo["dungeonCount"] then
        detailsFrame.dungeonList:setDungeonList(unitInfo["dungeonCount"])
    else
        detailsFrame.dungeonList:initDungeonList()
    end

    -- --------------------
    -- Rating
    if unitInfo["rating"] then
        if unitInfo["rating"] == 1 then
            detailsFrame.ratingGoodBtn:EnableMouse(false)
            detailsFrame.ratingBadBtn:EnableMouse(true)
            detailsFrame.ratingGoodBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
            MS.Frame:setFrameColor(detailsFrame.ratingGoodBtn, 0.2, 0.2, 0.1, 0, 0.95, 0.85, 0.75, 1)
            detailsFrame.ratingBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
            MS.Frame:setFrameColor(detailsFrame.ratingBadBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)

        elseif unitInfo["rating"] == 0 then
            detailsFrame.ratingBadBtn:EnableMouse(false)
            detailsFrame.ratingGoodBtn:EnableMouse(true)
            detailsFrame.ratingBadBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
            MS.Frame:setFrameColor(detailsFrame.ratingBadBtn, 0.2, 0.2, 0.1, 0, 0.95, 0.85, 0.75, 1)
            detailsFrame.ratingGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
            MS.Frame:setFrameColor(detailsFrame.ratingGoodBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)

        end
    else
        detailsFrame.ratingBadBtn:EnableMouse(true)
        detailsFrame.ratingGoodBtn:EnableMouse(true)
        detailsFrame.ratingGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(detailsFrame.ratingGoodBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
        detailsFrame.ratingBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(detailsFrame.ratingBadBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
    end

    -- --------------------
    -- Keystone Info
    if unitInfo["keystoneInfo"] then
        if unitInfo["keystoneInfo"]["c"] then
            detailsFrame.curKeyLvl.text:SetText(unitInfo["keystoneInfo"]["c"]["lvl"])
            detailsFrame.curKeyName.text:SetText(unitInfo["keystoneInfo"]["c"]["nm"])
        else
            detailsFrame.curKeyLvl.text:SetText("--")
            detailsFrame.curKeyName.text:SetText("--")
        end
        if unitInfo["keystoneInfo"]["mi"] then
            detailsFrame.maxinKeyLvl.text:SetText(unitInfo["keystoneInfo"]["mi"]["lvl"])
            detailsFrame.maxinKeyName.text:SetText(unitInfo["keystoneInfo"]["mi"]["nm"])
        else
            detailsFrame.maxinKeyLvl.text:SetText("--")
            detailsFrame.maxinKeyName.text:SetText("--")
        end
        if unitInfo["keystoneInfo"]["mo"] then
            detailsFrame.maxoverKeyLvl.text:SetText(unitInfo["keystoneInfo"]["mo"]["lvl"])
            detailsFrame.maxoverKeyName.text:SetText(unitInfo["keystoneInfo"]["mo"]["nm"])
        else
            detailsFrame.maxoverKeyLvl.text:SetText("--")
            detailsFrame.maxoverKeyName.text:SetText("--")
        end
    else
        detailsFrame.curKeyLvl.text:SetText("--")
        detailsFrame.curKeyName.text:SetText("--")
        detailsFrame.maxinKeyLvl.text:SetText("--")
        detailsFrame.maxinKeyName.text:SetText("--")
        detailsFrame.maxoverKeyLvl.text:SetText("--")
        detailsFrame.maxoverKeyName.text:SetText("--")
    end
end


-- -------------------------
-- History Frame

function MS.Frame:CreateHistoryPanel(parent, idx)
    local historyPanel = CreateFrame("Frame", nil, parent)
    historyPanel:SetSize(400, 50)
    historyPanel:SetPoint("TOP", parent, "TOP", 0, -20+(idx-1)*-50)
    self:setFrameTexture(historyPanel, 1)
    self:setFrameColor(historyPanel, 0.15, 0.15, 0.16, 0, 0, 0, 0, 0)


    historyPanel.classIcon = CreateFrame("Frame", nil, historyPanel)
    historyPanel.classIcon:SetSize(36, 36)
    self:setFrameTexture(historyPanel.classIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\classicons\\NONE")
    self:setFrameColor(historyPanel.classIcon, 1, 1, 1, 1, 0, 0, 0, 0)
    historyPanel.classIcon:SetPoint("LEFT", historyPanel, "LEFT", 80, 0)

    historyPanel.nameText = self:CreateTextBox(historyPanel, nil, "UnitName", 16, 0.95, 0.85, 0.75, 1, 150, 16, "LEFT")
    historyPanel.nameText:SetPoint("TOPLEFT", historyPanel, "TOPLEFT", 150, -10)

    historyPanel.serverText = self:CreateTextBox(historyPanel, nil, "UnitServer", 10, 0.8, 0.7, 0.6, 1, 150, 10, "LEFT")
    historyPanel.serverText:SetPoint("TOPLEFT", historyPanel, "TOPLEFT", 150, -30)

    -- ---------------------
    -- Rating Button
    historyPanel.ratingGoodBtn = self:CreateTagBox(historyPanel, "MSHistoryRatingGoodBtn", L["RatingGood"], 12, 0.5, 0.5, 0.5, 1, 30, 16, "CENTER")
    historyPanel.ratingGoodBtn:SetPoint("RIGHT", historyPanel, "RIGHT", -55, 0)
    historyPanel.ratingGoodBtn:SetScript("OnEnter", function(self)
        historyPanel.ratingGoodBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
        MS.Frame:setFrameColor(historyPanel.ratingGoodBtn, 0.2, 0.2, 0.1, 1, 0.95, 0.85, 0.75, 1)
    end)
    historyPanel.ratingGoodBtn:SetScript("OnLeave", function(self)
        historyPanel.ratingGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(historyPanel.ratingGoodBtn, 0.2, 0.2, 0.1, 0, 0.5, 0.5, 0.5, 1)
    end)

    historyPanel.ratingBadBtn = self:CreateTagBox(historyPanel, "MSHistoryRatingBadBtn", L["RatingBad"], 12, 0.5, 0.5, 0.5, 1, 30, 16, "CENTER")
    historyPanel.ratingBadBtn:SetPoint("RIGHT", historyPanel, "RIGHT", -100, -0)
    historyPanel.ratingBadBtn:SetScript("OnEnter", function(self)
        historyPanel.ratingBadBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
        MS.Frame:setFrameColor(historyPanel.ratingBadBtn, 0.2, 0.2, 0.1, 1, 0.95, 0.85, 0.75, 1)
    end)
    historyPanel.ratingBadBtn:SetScript("OnLeave", function(self)
        historyPanel.ratingBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(historyPanel.ratingBadBtn, 0.2, 0.2, 0.1, 0, 0.5, 0.5, 0.5, 1)
    end)


    return historyPanel
end

function MS.Frame:CreateHistoryFrame(parent)
    local historyFrame = CreateFrame("Frame", "MSHistoryFrame", parent)
    historyFrame:SetFrameLevel(11)
    historyFrame:SetSize(400, 560)
    historyFrame:SetPoint("TOP", parent, "TOP", 0, -40)
    self:setFrameTexture(historyFrame, 1)
    self:setFrameColor(historyFrame, 0.15, 0.15, 0.16, 1, 0.15, 0.15, 0.16, 1)

    MS.Frame.historyPanels = {}
    for i = 1, 10, 1 do
        MS.Frame.historyPanels[i] = self:CreateHistoryPanel(historyFrame, i)
    end

    historyFrame.closeBtn = CreateFrame("Frame", "MSMainFrame", historyFrame)
    historyFrame.closeBtn:SetSize(24, 24)
    historyFrame.closeBtn:SetPoint("BOTTOM", historyFrame, "BOTTOM", 0, 10)
    historyFrame.closeBtn:SetScript("OnMouseUp", function(self) MS.Frame:ToggleHistory() end)
    self:setFrameTexture(historyFrame.closeBtn, 0, "Interface\\Addons\\Minesweeperr\\media\\arrow")
    self:setFrameColor(historyFrame.closeBtn, 0.4, 0.4, 0.4, 1, 0.15, 0.15, 0.16, 0)

    return historyFrame
end

function MS.Frame:popHistoryData(list)
    if not list.cur then
        list.cur = list.first
    end
    local value = list[list.cur]
    if value then
        list.cur = list.cur - 1
        return value["value"]
    else
        list.cur = nil
        return value
    end
end

function MS.Frame:refreshUnitHistoryPanel(unitInfo, idx)
    local panel = MS.Frame.historyPanels[idx]
    if not panel then
        return
    end
    if not unitInfo then
        panel:Hide()
        return
    end
    panel.guid = unitInfo["GUID"]
    -- --------------------
    -- Name
    if unitInfo["name"] then
        panel.nameText.text:SetText(unitInfo["name"])
        panel.nameText.text:SetTextColor(unitInfo["classColorR"], unitInfo["classColorG"], unitInfo["classColorB"], 1)
    else
        panel.nameText.text:SetText("UnitName")
        panel.nameText.text:SetTextColor(0.95, 0.85, 0.75, 1)
    end

    -- --------------------
    -- Server
    if unitInfo["server"] then
        panel.serverText.text:SetText(unitInfo["server"])
    else
        panel.serverText.text:SetText("UnitServer")
    end

    -- ---------------------
    -- Class Icon
    if unitInfo["classIndex"] then
        self:setFrameTexture(panel.classIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\classicons\\"..MS.Const.classIdx[unitInfo["classIndex"]])
    else
        self:setFrameTexture(panel.classIcon, 0, "Interface\\Addons\\Minesweeperr\\media\\classicons\\NONE.tga")
    end
    self:setFrameColor(panel.classIcon, 1, 1, 1, 1, 0, 0, 0, 0)

        -- --------------------
    -- Rating
    if unitInfo["rating"] then
        if unitInfo["rating"] == 1 then
            panel.ratingGoodBtn:EnableMouse(false)
            panel.ratingBadBtn:EnableMouse(true)
            panel.ratingGoodBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
            MS.Frame:setFrameColor(panel.ratingGoodBtn, 0.2, 0.2, 0.1, 0, 0.95, 0.85, 0.75, 1)
            panel.ratingBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
            MS.Frame:setFrameColor(panel.ratingBadBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
            panel.ratingBadBtn:SetScript("OnMouseUp", function(self)
                MS:SendMessage("MSCustomEvent", "SAVE_BAD_RATING_FROM_HISTORY", panel.guid)
            end)
        elseif unitInfo["rating"] == 0 then
            panel.ratingBadBtn:EnableMouse(false)
            panel.ratingGoodBtn:EnableMouse(true)
            panel.ratingBadBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
            MS.Frame:setFrameColor(panel.ratingBadBtn, 0.2, 0.2, 0.1, 0, 0.95, 0.85, 0.75, 1)
            panel.ratingGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
            MS.Frame:setFrameColor(panel.ratingGoodBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
            panel.ratingGoodBtn:SetScript("OnMouseUp", function(self)
                MS:SendMessage("MSCustomEvent", "SAVE_GOOD_RATING_FROM_HISTORY", panel.guid)
            end)
        end
    else
        panel.ratingBadBtn:EnableMouse(true)
        panel.ratingGoodBtn:EnableMouse(true)
        panel.ratingGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(panel.ratingGoodBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
        panel.ratingBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(panel.ratingBadBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
        panel.ratingBadBtn:SetScript("OnMouseUp", function(self)
            MS:SendMessage("MSCustomEvent", "SAVE_BAD_RATING_FROM_HISTORY", panel.guid)
        end)
        panel.ratingGoodBtn:SetScript("OnMouseUp", function(self)
            MS:SendMessage("MSCustomEvent", "SAVE_GOOD_RATING_FROM_HISTORY", panel.guid)
        end)
    end



    panel:Show()
end

function MS.Frame:RefreshHistoryFrame()

    local unitInfo = 1
    local i = 1
    while unitInfo do
        unitInfo = self:popHistoryData(MS.db.global.history)
        if unitInfo then
            self:refreshUnitHistoryPanel(unitInfo, i)
        end
        i = i + 1
    end
    for j = i-1, 10, 1 do
        MS.Frame.historyPanels[j]:Hide()
    end
end

function MS.Frame:ToggleMainFrame()
    if not self.mainFrame then
        return
    else
        if self.mainFrame:IsShown() then
            self.mainFrame:Hide()
        else
            self.mainFrame:Show()
        end
    end
end

function MS.Frame:ToggleHistory()
    if self.historyFrame:IsShown() then
        self.historyFrame:Hide()
        MS:SendMessage("MSCustomEvent", "REFRESH_ALL")
    else
        self.historyFrame:Show()
        MS:SendMessage("MSCustomEvent", "REFRESH_HISTORY")
    end
end

function MS.Frame:CloseInitializeFrame()
    self.mainFrame.initializeFrame:Hide()
    self.historyFrame:Hide()
end


-- ---------------------------
-- Quick Rating Frame

function MS.Frame:CreateQCPanel(parent, idx)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetSize(300, 40)
    panel:SetPoint("TOP", parent, "TOP", 0, -30-(idx-1)*30)
    self:setFrameTexture(panel, 0)
    self:setFrameColor(panel, 0.15, 0.15, 0.16, 0, 0.15, 0.15, 0.16, 0)

    panel.nameText = self:CreateTextBox(panel, nil, "UnitName", 14, 0.95, 0.85, 0.75, 1, 150, 20, "LEFT")
    panel.nameText:SetPoint("LEFT", panel, "LEFT", 70, 0)

    panel.roleTankTag = self:CreateTagBox(panel, nil, "Tank", 12, 0.9, 0.4, 0.4, 1, 40, 16)
    panel.roleTankTag:SetPoint("LEFT", panel, "LEFT", 20, 0)
    -- panel.roleTankTag:Hide()

    panel.roleHealerTag = self:CreateTagBox(panel, nil, "Healer", 12, 0.9, 0.9, 0.9, 1, 40, 16)
    panel.roleHealerTag:SetPoint("LEFT", panel, "LEFT", 20, 0)
    panel.roleHealerTag:Hide()

    panel.roleDpsTag = self:CreateTagBox(panel, nil, "Damage", 12, 0.4, 0.9, 0.4, 1, 40, 16)
    panel.roleDpsTag:SetPoint("LEFT", panel, "LEFT", 20, 0)
    panel.roleDpsTag:Hide()

    -- ---------------------
    -- Rating Button
    panel.ratingGoodBtn = self:CreateTagBox(panel, nil, L["RatingGood"], 12, 0.5, 0.5, 0.5, 1, 30, 16, "CENTER")
    panel.ratingGoodBtn:SetPoint("RIGHT", panel, "RIGHT", -20, 0)
    panel.ratingGoodBtn:SetScript("OnEnter", function(self)
        panel.ratingGoodBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
        MS.Frame:setFrameColor(panel.ratingGoodBtn, 0.2, 0.2, 0.1, 1, 0.95, 0.85, 0.75, 1)
    end)
    panel.ratingGoodBtn:SetScript("OnLeave", function(self)
        panel.ratingGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(panel.ratingGoodBtn, 0.2, 0.2, 0.1, 0, 0.5, 0.5, 0.5, 1)
    end)

    panel.ratingBadBtn = self:CreateTagBox(panel, nil, L["RatingBad"], 12, 0.5, 0.5, 0.5, 1, 30, 16, "CENTER")
    panel.ratingBadBtn:SetPoint("RIGHT", panel, "RIGHT", -55, -0)
    panel.ratingBadBtn:SetScript("OnEnter", function(self)
        panel.ratingBadBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
        MS.Frame:setFrameColor(panel.ratingBadBtn, 0.2, 0.2, 0.1, 1, 0.95, 0.85, 0.75, 1)
    end)
    panel.ratingBadBtn:SetScript("OnLeave", function(self)
        panel.ratingBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(panel.ratingBadBtn, 0.2, 0.2, 0.1, 0, 0.5, 0.5, 0.5, 1)
    end)


    return panel
end

function MS.Frame:CreateQCFrame()
    local qcFrame = CreateFrame("Frame", "MSQCFrame", UIParent)
    qcFrame:SetFrameLevel(11)
    qcFrame:SetSize(300, 200)
    
    qcFrame:ClearAllPoints()
    qcFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 0, 0)
    self:setFrameTexture(qcFrame, 1)
    self:setFrameColor(qcFrame, 0.15, 0.15, 0.16, 1, 0.15, 0.15, 0.16, 1)

    local qcBGFrame = CreateFrame("Frame", "MSQCBGFrame", qcFrame)
    qcBGFrame:SetFrameLevel(10)
    qcBGFrame:SetSize(300, 200)
    qcBGFrame:SetPoint("CENTER", qcFrame, "CENTER", 5, -5)
    self:setFrameTexture(qcBGFrame, 1)
    self:setFrameColor(qcBGFrame, 0.1, 0.1, 0.11, 1, 0.1, 0.1, 0.11, 1)


    qcFrame.titleText = self:CreateTextBox(qcFrame, nil, L["QuickRating"], 14, 0.95, 0.85, 0.75, 1, 30, 16, "LEFT")
    qcFrame.titleText:SetPoint("TOPLEFT", qcFrame, "TOPLEFT", 10, -10)

    MS.Frame.qcPanels = {}
    for i = 1, 4, 1 do
        MS.Frame.qcPanels["party"..i] = self:CreateQCPanel(qcFrame, i)
    end


    qcFrame.closeBtn = self:CreateTextBox(qcFrame, nil, L["Close"], 14, 0.95, 0.85, 0.75, 1, 25, 16, "LEFT")
    qcFrame.closeBtn:SetPoint("TOPRIGHT", qcFrame, "TOPRIGHT", -10, -10)
    qcFrame.closeBtn:SetScript("OnMouseUp", function(self) qcFrame:Hide() end)

    qcFrame.ratingAllGoodBtn = self:CreateTagBox(qcFrame, "MSQCRatingGoodBtn", L["All"].."\n"..L["RatingGood"], 12, 0.5, 0.5, 0.5, 1, 30, 30, "CENTER")
    qcFrame.ratingAllGoodBtn:SetPoint("BOTTOMRIGHT", qcFrame, "BOTTOMRIGHT", -20, 10)
    qcFrame.ratingAllGoodBtn:SetScript("OnEnter", function(self)
        qcFrame.ratingAllGoodBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
        MS.Frame:setFrameColor(qcFrame.ratingAllGoodBtn, 0.2, 0.2, 0.1, 1, 0.95, 0.85, 0.75, 1)
    end)
    qcFrame.ratingAllGoodBtn:SetScript("OnLeave", function(self)
        qcFrame.ratingAllGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(qcFrame.ratingAllGoodBtn, 0.2, 0.2, 0.1, 0, 0.5, 0.5, 0.5, 1)
    end)

    qcFrame.ratingAllBadBtn = self:CreateTagBox(qcFrame, "MSQCRatingBadBtn", L["All"].."\n"..L["RatingBad"], 12, 0.5, 0.5, 0.5, 1, 30, 30, "CENTER")
    qcFrame.ratingAllBadBtn:SetPoint("BOTTOMRIGHT", qcFrame, "BOTTOMRIGHT", -55, 10)
    qcFrame.ratingAllBadBtn:SetScript("OnEnter", function(self)
        qcFrame.ratingAllBadBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
        MS.Frame:setFrameColor(qcFrame.ratingAllBadBtn, 0.2, 0.2, 0.1, 1, 0.95, 0.85, 0.75, 1)
    end)
    qcFrame.ratingAllBadBtn:SetScript("OnLeave", function(self)
        qcFrame.ratingAllBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(qcFrame.ratingAllBadBtn, 0.2, 0.2, 0.1, 0, 0.5, 0.5, 0.5, 1)
    end)

    for i = 1, 4, 1 do
        MS.Frame.qcPanels["party"..i]:Hide()
    end

    return qcFrame
end

function MS.Frame:RefreshUnitQCPanel(unitInfo)
    if not unitInfo then
        return
    end

    if unitInfo["uid"] == "player" then
        return
    end

    local panel = self.qcPanels[unitInfo["uid"]]

    panel:Show()

    panel.guid = unitInfo["GUID"]
    self.qcFrame.allGUID[unitInfo["GUID"]] = 1
    -- --------------------
    -- Name
    if unitInfo["name"] then
        panel.nameText.text:SetText(unitInfo["name"])
        panel.nameText.text:SetTextColor(unitInfo["classColorR"], unitInfo["classColorG"], unitInfo["classColorB"], 1)
    else
        panel.nameText.text:SetText("UnitName")
        panel.nameText.text:SetTextColor(0.95, 0.85, 0.75, 1)
    end

    -- ---------------------
    -- Role Tag
    
    panel.roleTankTag:Hide()
    panel.roleHealerTag:Hide()
    panel.roleDpsTag:Hide()
    if unitInfo["role"] then
        if unitInfo["role"] == "TANK" then
            panel.roleTankTag:Show()
        elseif unitInfo["role"] == "HEALER" then
            panel.roleHealerTag:Show()
        elseif unitInfo["role"] == "DAMAGER" then
            panel.roleDpsTag:Show()
        end
    end

    -- --------------------
    -- Rating
    if unitInfo["rating"] then
        if unitInfo["rating"] == 1 then
            panel.ratingGoodBtn:EnableMouse(false)
            panel.ratingBadBtn:EnableMouse(true)
            panel.ratingGoodBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
            MS.Frame:setFrameColor(panel.ratingGoodBtn, 0.2, 0.2, 0.1, 0, 0.95, 0.85, 0.75, 1)
            panel.ratingBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
            MS.Frame:setFrameColor(panel.ratingBadBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
            panel.ratingBadBtn:SetScript("OnMouseUp", function(self)
                MS:SendMessage("MSCustomEvent", "SAVE_BAD_RATING_FROM_QC", panel.guid)
            end)
        elseif unitInfo["rating"] == 0 then
            panel.ratingBadBtn:EnableMouse(false)
            panel.ratingGoodBtn:EnableMouse(true)
            panel.ratingBadBtn.text:SetTextColor(0.95, 0.85, 0.75, 1)
            MS.Frame:setFrameColor(panel.ratingBadBtn, 0.2, 0.2, 0.1, 0, 0.95, 0.85, 0.75, 1)
            panel.ratingGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
            MS.Frame:setFrameColor(panel.ratingGoodBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
            panel.ratingGoodBtn:SetScript("OnMouseUp", function(self)
                MS:SendMessage("MSCustomEvent", "SAVE_GOOD_RATING_FROM_QC", panel.guid)
            end)
        end
    else
        panel.ratingBadBtn:EnableMouse(true)
        panel.ratingGoodBtn:EnableMouse(true)
        panel.ratingGoodBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(panel.ratingGoodBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
        panel.ratingBadBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        MS.Frame:setFrameColor(panel.ratingBadBtn, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 1)
        panel.ratingBadBtn:SetScript("OnMouseUp", function(self)
            MS:SendMessage("MSCustomEvent", "SAVE_BAD_RATING_FROM_QC", panel.guid)
        end)
        panel.ratingGoodBtn:SetScript("OnMouseUp", function(self)
            MS:SendMessage("MSCustomEvent", "SAVE_GOOD_RATING_FROM_QC", panel.guid)
        end)
    end

    self.qcFrame.ratingAllGoodBtn:SetScript("OnMouseUp", function(self)
        for guid, _ in pairs(MS.Frame.qcFrame.allGUID) do
            MS:SendMessage("MSCustomEvent", "SAVE_GOOD_RATING_FROM_QC", guid)
        end
    end)
    self.qcFrame.ratingAllBadBtn:SetScript("OnMouseUp", function(self)
        for guid, _ in pairs(MS.Frame.qcFrame.allGUID) do
            MS:SendMessage("MSCustomEvent", "SAVE_BAD_RATING_FROM_QC", guid)
        end
    end)

end

function MS.Frame:RefreshQCFrame(partyMembers)
    if not partyMembers then
        return
    end
    self.qcFrame.allGUID = {}
    for i, uid in pairs(MS.Const.partyMembersTempl) do
        if uid ~= "player" then
            if partyMembers[uid] then
                self.qcPanels[uid]:Show()
                MS:SendMessage("MSCustomEvent", "REFRESH_QC_PANEL", uid)
            else
                self.qcPanels[uid]:Hide()
            end
        end
    end
end