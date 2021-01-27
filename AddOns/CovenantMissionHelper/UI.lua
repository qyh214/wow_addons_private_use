CovenantMissionHelper, CMH = ...
local MissionHelper = _G["MissionHelper"]

local MAX_FRAME_WIDTH = 500
local PADDING = 20
local RESULT_HEADER_WIDTH = 300
local RESULT_HEADER_HEIGHT = 30
local RESULT_INFO_HEIGHT = 160
local SCROLL_BAR_WIDTH = 10
local PREDICT_BUTTON_WIDTH = 80
local PREDICT_BUTTON_HEIGHT = 30

local function hideCorners(frame)
    frame.BaseFrameTopLeft:Hide()
    frame.BaseFrameTopRight:Hide()
    frame.BaseFrameBottomLeft:Hide()
    frame.BaseFrameBottomRight:Hide()
end

local function hideBaseCorners(frame)
    frame.RaisedFrameEdges.BaseFrameTopLeftCorner:Hide()
    frame.RaisedFrameEdges.BaseFrameTopRightCorner:Hide()
    frame.RaisedFrameEdges.BaseFrameBottomLeftCorner:Hide()
    frame.RaisedFrameEdges.BaseFrameBottomRightCorner:Hide()
end

local function createMainFrame()
    local mainFrameWidth = math.min(
            GetScreenWidth() * UIParent:GetEffectiveScale() - (CovenantMissionFrame:GetRight() * CovenantMissionFrame:GetEffectiveScale()) - PADDING,
            MAX_FRAME_WIDTH
    )
    local frame  = CreateFrame("Frame", "missionHelperFrame", _G["CovenantMissionFrame"], "CovenantMissionBaseFrameTemplate") -- GarrisonUITemplate/BasicFrameTemplate
        _G["MissionHelper"].missionHelperFrame = frame
        frame:SetPoint("TOPLEFT", CovenantMissionFrame, "TOPRIGHT")
        frame:SetClampedToScreen(true)
        frame:SetSize(mainFrameWidth, CovenantMissionFrame:GetHeight())
        frame:EnableMouse(true)
        frame:EnableMouseWheel(true)
        frame.BaseFrameBackground:SetAtlas('adventures-missions-bg-02', false)
        hideCorners(frame)

    -- move frame
    frame:SetMovable(true)
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and (IsShiftKeyDown()) and not self.isMoving then
            self:StartMoving();
            self.isMoving = true;
        end
    end)

    frame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and (IsShiftKeyDown()) and self.isMoving then
            self:StopMovingOrSizing();
            self.isMoving = false;
        end
    end)

    return frame
end

local function createResultHeader(main_frame)
    local resultHeader = CreateFrame("Frame", nil, main_frame)
    main_frame.resultHeader = resultHeader
        resultHeader:SetPoint("TOP", main_frame, "TOP", 0, -PADDING)
        resultHeader:SetSize(RESULT_HEADER_WIDTH, RESULT_HEADER_HEIGHT)
        resultHeader.BaseFrameBackground = resultHeader:CreateTexture()
        resultHeader.BaseFrameBackground:SetAtlas("adventures_mission_materialframe")
        resultHeader.BaseFrameBackground:SetAllPoints(resultHeader)

    resultHeader.text = resultHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        resultHeader.text:SetPoint("CENTER")
        resultHeader.text:SetJustifyH("CENTER")
        resultHeader.text:SetJustifyV("CENTER")

    return resultHeader
end

local function createPredictButton(resultInfoFrame)
    local function onClick()
        MissionHelper:showResult(MissionHelper:simulateFight(true))
    end

    local predictButton = CreateFrame("Button", nil, resultInfoFrame, "UIPanelButtonTemplate")
    resultInfoFrame.predictButton = predictButton
        predictButton:SetSize(PREDICT_BUTTON_WIDTH, PREDICT_BUTTON_HEIGHT)
        predictButton:SetPoint("BOTTOMRIGHT", resultInfoFrame, "BOTTOMRIGHT", -PADDING, PADDING)
        predictButton:SetText('Simulate')
        predictButton:SetScript('onClick', onClick)
        predictButton:Hide()
end

local function createBestDispositionButton(resultInfoFrame)
    local function onClick()
        MissionHelper:findBestDisposition()
    end

    local function onEnter(buttonFrame)
        GameTooltip:SetOwner(buttonFrame, "ANCHOR_TOPLEFT")
        GameTooltip_AddNormalLine(GameTooltip, "Change the order of your troops to minimize HP loss")
        GameTooltip_AddColoredLine(GameTooltip, "It shuffles only units on board and doesn't consider others", RED_FONT_COLOR)
        GameTooltip:SetPoint("TOPLEFT", buttonFrame, "BOTTOMRIGHT", 0, 0);
        GameTooltip:Show()
    end

    local function onLeave()
        GameTooltip_Hide()
    end

    local BestDispositionButton = CreateFrame("Button", nil, resultInfoFrame, "UIPanelButtonTemplate")
    resultInfoFrame.BestDispositionButton = BestDispositionButton
        BestDispositionButton:SetSize(PREDICT_BUTTON_WIDTH, PREDICT_BUTTON_HEIGHT)
        BestDispositionButton:SetPoint("BOTTOMRIGHT", resultInfoFrame, "BOTTOMRIGHT", -2*PADDING - PREDICT_BUTTON_WIDTH, PADDING)
        BestDispositionButton:SetText('Optimize')
        BestDispositionButton:SetScript('onClick', onClick)
        BestDispositionButton:SetScript('onEnter', onEnter)
        BestDispositionButton:SetScript('onLeave', onLeave)
        BestDispositionButton:Hide()
end

local function createResultInfo(mainFrame)
    local resultInfo = CreateFrame("Frame", nil, mainFrame, "CovenantMissionBaseFrameTemplate")
    mainFrame.resultInfo = resultInfo
        resultInfo:SetSize(mainFrame:GetWidth() - 2*PADDING, RESULT_INFO_HEIGHT)
        resultInfo:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", PADDING, -(RESULT_HEADER_HEIGHT + 1.5*PADDING))
        hideBaseCorners(resultInfo)
        hideCorners(resultInfo)

    resultInfo.text = resultInfo:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        resultInfo.text:SetSize(resultInfo:GetWidth() - 2*PADDING , resultInfo:GetHeight() - PADDING)
        resultInfo.text:SetPoint("TOPLEFT", PADDING, -PADDING)
        resultInfo.text:SetJustifyH("LEFT")
        resultInfo.text:SetJustifyV("TOP")

    createBestDispositionButton(resultInfo)
    createPredictButton(resultInfo)

    return resultInfo
end

local function createScrollingMessageFrame(mainFrame, combatLogFrame)
    local messageFrame = CreateFrame("ScrollingMessageFrame", "missionHelperMessageFrame", combatLogFrame)
    combatLogFrame.CombatLogMessageFrame = messageFrame
        messageFrame:SetFontObject(GameFontNormal)
        messageFrame:SetSize(mainFrame:GetWidth() - 5*PADDING, mainFrame:GetHeight() - 300)
        messageFrame:SetPoint("TOPLEFT", PADDING, -PADDING)
        messageFrame:SetJustifyH("LEFT")
        messageFrame:SetJustifyV("TOP")
        --messageFrame:SetHyperlinksEnabled(true)
        messageFrame:SetFading(false)
        messageFrame:SetMaxLines(20000)
        --messageFrame:ScrollToTop()
    return messageFrame
end

local function createScrollBar(mainFrame, combatLogFrame)
    local scrollBar = CreateFrame("Slider", "missionHelperScrollBar", combatLogFrame, "OribosScrollBarTemplate")
    combatLogFrame.CombatLogMessageFrame.ScrollBar = scrollBar
        scrollBar:SetPoint("TOPRIGHT", combatLogFrame, "TOPRIGHT", -SCROLL_BAR_WIDTH, -30)
        scrollBar:SetSize(SCROLL_BAR_WIDTH, mainFrame:GetHeight() - 320)
        scrollBar:SetFrameLevel(combatLogFrame:GetFrameLevel() + 1)
        scrollBar:SetMinMaxValues(0, 100)
        scrollBar:SetValueStep(5)

    scrollBar:SetScript("OnValueChanged", function(self, value)
        MissionHelper.missionHelperFrame.combatLogFrame.CombatLogMessageFrame:SetScrollOffset(select(2, self:GetMinMaxValues()) - value)
    end)

    scrollBar:SetValue(select(2, scrollBar:GetMinMaxValues()))

    return scrollBar
end

local function createCombatLogFrame(mainFrame, resultInfo)
    local frame_height = mainFrame:GetHeight() - (RESULT_HEADER_HEIGHT + RESULT_INFO_HEIGHT + 3.5*PADDING)
    local combatLogFrame = CreateFrame("Frame", "missionHelperCombatLogFrame", mainFrame, "CovenantMissionBaseFrameTemplate")
    mainFrame.combatLogFrame = combatLogFrame
    combatLogFrame:SetPoint("TOPLEFT", resultInfo, "BOTTOMLEFT", 0, -PADDING/2)
    combatLogFrame:SetSize(mainFrame:GetWidth() - 2*PADDING, frame_height)
    combatLogFrame.BaseFrameBackground:SetAtlas('adventures-missions-bg-01', false)
    hideCorners(combatLogFrame)
    hideBaseCorners(combatLogFrame)

    createScrollingMessageFrame(mainFrame, combatLogFrame)
    createScrollBar(mainFrame, combatLogFrame)
    return combatLogFrame
end

function MissionHelper:createMissionHelperFrame(...)

    local mainFrame = createMainFrame()
    local resultHeader = createResultHeader(mainFrame)
    local resultInfo = createResultInfo(mainFrame)
    local combatLogFrame = createCombatLogFrame(mainFrame, resultInfo)

    mainFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur_val = mainFrame.combatLogFrame.CombatLogMessageFrame.ScrollBar:GetValue()
        local min_val, max_val = mainFrame.combatLogFrame.CombatLogMessageFrame.ScrollBar:GetMinMaxValues()

        if delta < 0 and cur_val < max_val then
            cur_val = math.min(max_val, cur_val + 5)
            mainFrame.combatLogFrame.CombatLogMessageFrame.ScrollBar:SetValue(cur_val)
        elseif delta > 0 and cur_val > min_val then
            cur_val = math.max(min_val, cur_val - 5)
            mainFrame.combatLogFrame.CombatLogMessageFrame.ScrollBar:SetValue(cur_val)
        end
    end)

    mainFrame:Hide()
    MissionHelper.missionHelperFrame = mainFrame
    return mainFrame

end

function MissionHelper:editDefaultFrame(...)
    CovenantMissionFrame:ClearAllPoints()
    CovenantMissionFrame:SetPoint("CENTER", UIParent, "CENTER", -300, 0)
    if CovenantMissionFrame:GetLeft() < PADDING then
        CovenantMissionFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
                PADDING * CovenantMissionFrame:GetEffectiveScale(), CovenantMissionFrame:GetBottom())
    end
end

function MissionHelper:clearFrames()
    MissionHelper.missionHelperFrame.combatLogFrame.CombatLogMessageFrame:Clear()
    MissionHelper.missionHelperFrame.combatLogFrame.CombatLogMessageFrame.ScrollBar:SetMinMaxValues(0, 10)
    MissionHelper.missionHelperFrame.combatLogFrame.CombatLogMessageFrame:SetScrollOffset(0)
    MissionHelper:setResultHeader('')
    MissionHelper:setResultInfo('')
    MissionHelper:hidePredictButton()
    CMH.Board.CombatLog = {}
    CMH.Board.HiddenCombatLog = {}
    CMH.Board.CombatLogEvents = {}

end

function MissionHelper:setResultHeader(message)
    MissionHelper.missionHelperFrame.resultHeader.text:SetText(message)
end

function MissionHelper:setResultInfo(message)
    MissionHelper.missionHelperFrame.resultInfo.text:SetText(message)
end

function MissionHelper:AddCombatLogMessage(message)
    MissionHelper.missionHelperFrame.combatLogFrame.CombatLogMessageFrame:AddMessage(message)
end

function MissionHelper:hidePredictButton()
    MissionHelper.missionHelperFrame.resultInfo.predictButton:Hide()
end

function MissionHelper:showPredictButton()
    MissionHelper.missionHelperFrame.resultInfo.predictButton:Show()
end

function MissionHelper:hideBestDispositionButton()
    MissionHelper.missionHelperFrame.resultInfo.BestDispositionButton:Hide()
end

function MissionHelper:showBestDispositionButton()
    MissionHelper.missionHelperFrame.resultInfo.BestDispositionButton:Show()
end
