local addonName, DF = ...

-- ============================================================
-- CLASS POWER PIPS
-- Displays class-specific resources (Holy Power, Chi, etc.)
-- on the player frame as individual colored pips.
-- In test mode, shows pips on all relevant class frames.
-- Supports horizontal (top/bottom/inside) and vertical (left/right) layouts.
-- Compatible with test mode (testShowClassPower) and health fade.
-- ============================================================

local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitClass = UnitClass
local UnitIsUnit = UnitIsUnit
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local IsInRaid = IsInRaid
local ceil = math.ceil
local min = math.min
local max = math.max

-- ============================================================
-- CLASS POWER MAPPING
-- ============================================================

local CLASS_POWER_TYPES = {
    PALADIN     = 9,   -- Holy Power
    MONK        = 12,  -- Chi (Windwalker)
    ROGUE       = 4,   -- Combo Points
    DRUID       = 4,   -- Combo Points (Feral / cat form)
    WARLOCK     = 7,   -- Soul Shards
    MAGE        = 16,  -- Arcane Charges (Arcane spec)
    EVOKER      = 19,  -- Essence
}

-- Default max pips per class (for test mode where we can't query UnitPowerMax)
local CLASS_POWER_MAX = {
    PALADIN = 5,
    ROGUE   = 7,
    WARLOCK = 5,
    MONK    = 5,
    MAGE    = 4,
    DRUID   = 5,
    EVOKER  = 5,
}

local POWER_COLORS = {
    [4]  = { r = 1.00, g = 0.96, b = 0.41 },  -- Combo Points
    [7]  = { r = 0.58, g = 0.51, b = 0.79 },  -- Soul Shards
    [9]  = { r = 0.95, g = 0.90, b = 0.60 },  -- Holy Power
    [12] = { r = 0.71, g = 1.00, b = 0.92 },  -- Chi
    [16] = { r = 0.44, g = 0.44, b = 1.00 },  -- Arcane Charges
    [19] = { r = 0.00, g = 0.69, b = 0.58 },  -- Essence
}

local POWER_TYPE_TOKENS = {
    [4]  = "COMBO_POINTS",
    [7]  = "SOUL_SHARDS",
    [9]  = "HOLY_POWER",
    [12] = "CHI",
    [16] = "ARCANE_CHARGES",
    [19] = "ESSENCE",
}

-- Vertical anchors grow pips top-to-bottom along the frame side
local VERTICAL_ANCHORS = {
    LEFT = true,
    RIGHT = true,
}

local MAX_PIPS = 10

-- Live mode state (single player frame)
local activePowerType = nil
local activePowerToken = nil
local pipContainer = nil
local pips = {}
local currentTargetFrame = nil
local currentUseRaidDb = false

-- Test mode state (per-frame pip data)
local testPipData = {}  -- keyed by frame: { container = Frame, pips = {} }

-- ============================================================
-- HELPERS
-- ============================================================

local function GetFillColor(db, powerType)
    if db.classPowerUseCustomColor and db.classPowerColor then
        local c = db.classPowerColor
        return c.r or 1, c.g or 0.82, c.b or 0, c.a or 1
    end
    local color = POWER_COLORS[powerType]
    if color then
        return color.r, color.g, color.b, 1.0
    end
    return 1, 1, 1, 1
end

local function GetBgColor(db)
    if db.classPowerBgColor then
        local c = db.classPowerBgColor
        return c.r or 0.15, c.g or 0.15, c.b or 0.15, c.a or 0.4
    end
    return 0.15, 0.15, 0.15, 0.4
end

local function IsRoleAllowed(db, role)
    if role == "TANK" then
        return db.classPowerShowTank ~= false
    elseif role == "HEALER" then
        return db.classPowerShowHealer ~= false
    elseif role == "DAMAGER" then
        return db.classPowerShowDamager ~= false
    end
    -- NONE or unknown role: show by default
    return true
end

-- ============================================================
-- GET THE FRAME THAT DISPLAYS THE PLAYER (party or raid)
-- When in raid, the party container is hidden; the player is shown on a raid frame.
-- ============================================================
local function GetPlayerFrameForClassPower()
    -- Test mode: use the player test frame (index 0 for party, or first frame in raid)
    if DF.testMode and DF.testPartyFrames then
        local f = DF.testPartyFrames[0]
        if f and f:IsShown() then
            return f, false
        end
    end
    if DF.raidTestMode and DF.testRaidFrames then
        local f = DF.testRaidFrames[1]
        if f and f:IsShown() then
            return f, true
        end
    end

    -- Live: raid frames take priority
    if IsInRaid() and DF.raidContainer and DF.raidContainer:IsShown() and DF.IterateRaidFrames then
        local found = nil
        DF:IterateRaidFrames(function(f)
            if not f then return end
            local u = f.unit or (f.GetAttribute and f:GetAttribute("unit"))
            if u and UnitIsUnit(u, "player") and f:IsShown() then
                found = f
                return true
            end
        end)
        if found then
            return found, true
        end
    end
    return DF.playerFrame, false
end

-- ============================================================
-- DETECT CLASS POWER
-- ============================================================

local function DetectClassPower()
    local _, playerClass = UnitClass("player")
    if not playerClass then return nil end
    local candidateType = CLASS_POWER_TYPES[playerClass]
    if not candidateType then return nil end

    local maxPower = UnitPowerMax("player", candidateType)
    if type(maxPower) == "number" and maxPower > 0 then
        return candidateType, POWER_TYPE_TOKENS[candidateType], maxPower
    end

    return nil
end

-- ============================================================
-- ANCHOR PIPS TO A FRAME
-- Shared between live and test mode pip containers.
-- Returns parentSize, pipThickness, isVertical
-- ============================================================

local function AnchorPipContainer(container, frame, db)
    local thickness = db.classPowerHeight or 4
    local yOffset = db.classPowerY or -1
    local xOffset = db.classPowerX or 0
    local anchor = db.classPowerAnchor or "INSIDE_BOTTOM"
    local bar = frame.healthBar or frame
    local isVertical = VERTICAL_ANCHORS[anchor]

    container:ClearAllPoints()

    if isVertical then
        -- Vertical: pips stack top-to-bottom along the frame side
        local parentHeight = bar:GetHeight()
        container:SetSize(thickness, parentHeight)

        if anchor == "LEFT" then
            container:SetPoint("RIGHT", bar, "LEFT", xOffset, yOffset)
        else -- RIGHT
            container:SetPoint("LEFT", bar, "RIGHT", xOffset, yOffset)
        end

        return parentHeight, thickness, true
    else
        -- Horizontal: pips span left-to-right
        local parentWidth = bar:GetWidth()
        container:SetSize(parentWidth, thickness)

        if anchor == "INSIDE_BOTTOM" then
            container:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", xOffset, yOffset)
            container:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", xOffset, yOffset)
        elseif anchor == "INSIDE_TOP" then
            container:SetPoint("TOPLEFT", bar, "TOPLEFT", xOffset, yOffset)
            container:SetPoint("TOPRIGHT", bar, "TOPRIGHT", xOffset, yOffset)
        elseif anchor == "TOP" then
            container:SetPoint("BOTTOM", bar, "TOP", xOffset, yOffset)
        else -- BOTTOM
            container:SetPoint("TOP", bar, "BOTTOM", xOffset, yOffset)
        end

        return parentWidth, thickness, false
    end
end

-- ============================================================
-- LAYOUT INDIVIDUAL PIPS
-- Shared logic for both live and test pip arrays
-- ============================================================

local function LayoutPipArray(container, pipArray, count, db, parentSize, thickness, isVertical)
    local gap = db.classPowerGap or 1
    local pipSpan = (parentSize - (count - 1) * gap) / count
    local bgR, bgG, bgB, bgA = GetBgColor(db)

    for i = 1, MAX_PIPS do
        if not pipArray[i] then
            local bg = container:CreateTexture(nil, "BACKGROUND")
            bg:SetTexture("Interface\\Buttons\\WHITE8x8")
            local fg = container:CreateTexture(nil, "ARTWORK")
            fg:SetTexture("Interface\\Buttons\\WHITE8x8")
            pipArray[i] = { bg = bg, fg = fg }
        end

        local pip = pipArray[i]

        if i <= count then
            local offset = (i - 1) * (pipSpan + gap)

            pip.bg:ClearAllPoints()
            pip.fg:ClearAllPoints()

            if isVertical then
                -- Vertical: stack top-to-bottom
                pip.bg:SetPoint("TOP", container, "TOP", 0, -offset)
                pip.bg:SetSize(thickness, pipSpan)
                pip.fg:SetPoint("TOP", container, "TOP", 0, -offset)
                pip.fg:SetSize(thickness, pipSpan)
            else
                -- Horizontal: span left-to-right
                pip.bg:SetPoint("LEFT", container, "LEFT", offset, 0)
                pip.bg:SetSize(pipSpan, thickness)
                pip.fg:SetPoint("LEFT", container, "LEFT", offset, 0)
                pip.fg:SetSize(pipSpan, thickness)
            end

            pip.bg:SetVertexColor(bgR, bgG, bgB, bgA)
            pip.bg:Show()
            pip.fg:Hide()
        else
            pip.bg:Hide()
            pip.fg:Hide()
        end
    end
end

-- ============================================================
-- LAYOUT AND UPDATE PIPS (LIVE MODE)
-- ============================================================

local function LayoutPips(frame, count, db)
    if not pipContainer or not frame then return end
    local parentSize, thickness, isVertical = AnchorPipContainer(pipContainer, frame, db)
    LayoutPipArray(pipContainer, pips, count, db, parentSize, thickness, isVertical)
end

local function UpdatePips()
    if not activePowerType or not pipContainer then return end
    if not pipContainer:IsShown() then return end

    local current = UnitPower("player", activePowerType) or 0
    local maxPower = UnitPowerMax("player", activePowerType) or 0

    -- Secret value guard: if values aren't numbers, hide pips
    if type(current) ~= "number" or type(maxPower) ~= "number" or maxPower == 0 then
        pipContainer:Hide()
        return
    end

    pipContainer:SetAlpha(1.0)

    local db = DF.GetDB and (currentUseRaidDb and DF:GetRaidDB() or DF:GetDB()) or nil
    local r, g, b, a = 1, 1, 1, 1
    if db then
        r, g, b, a = GetFillColor(db, activePowerType)
    else
        local color = POWER_COLORS[activePowerType] or { r = 1, g = 1, b = 1 }
        r, g, b, a = color.r, color.g, color.b, 1.0
    end

    for i = 1, maxPower do
        local pip = pips[i]
        if pip then
            if i <= current then
                pip.fg:SetVertexColor(r, g, b, a)
                pip.fg:Show()
            else
                pip.fg:Hide()
            end
        end
    end

    for i = maxPower + 1, MAX_PIPS do
        if pips[i] then
            pips[i].bg:Hide()
            pips[i].fg:Hide()
        end
    end
end

-- ============================================================
-- TEST MODE PIP FUNCTIONS
-- ============================================================

local function GetOrCreateTestPipData(frame)
    if testPipData[frame] then return testPipData[frame] end

    local container = CreateFrame("Frame", nil, frame)
    local baseLevel = frame.healthBar and frame.healthBar:GetFrameLevel() or frame:GetFrameLevel()
    container:SetFrameLevel(baseLevel + 5)

    local data = { container = container, pips = {} }
    testPipData[frame] = data
    return data
end

local function LayoutTestPips(frame, count, db, powerType)
    local data = GetOrCreateTestPipData(frame)
    local container = data.container
    local parentSize, thickness, isVertical = AnchorPipContainer(container, frame, db)
    LayoutPipArray(container, data.pips, count, db, parentSize, thickness, isVertical)
    return data
end

local function UpdateTestPips(frame, filledCount, maxCount, powerType, db)
    local data = testPipData[frame]
    if not data then return end

    local tPips = data.pips
    local r, g, b, a = GetFillColor(db, powerType)

    for i = 1, maxCount do
        local pip = tPips[i]
        if pip then
            if i <= filledCount then
                pip.fg:SetVertexColor(r, g, b, a)
                pip.fg:Show()
            else
                pip.fg:Hide()
            end
        end
    end

    for i = maxCount + 1, MAX_PIPS do
        if tPips[i] then
            tPips[i].bg:Hide()
            tPips[i].fg:Hide()
        end
    end
end

local function GetTestFillCount(maxPips, frameIndex)
    local base = ceil(maxPips * 0.6)
    local offset = ((frameIndex or 0) % 3)
    return min(max(base + offset - 1, 1), maxPips)
end

function DF:UpdateTestClassPower(frame, testData)
    if not frame or not testData then return end

    local classToken = testData.class
    if not classToken then
        self:HideTestClassPower(frame)
        return
    end

    local powerType = CLASS_POWER_TYPES[classToken]
    if not powerType then
        self:HideTestClassPower(frame)
        return
    end

    local maxPips = CLASS_POWER_MAX[classToken] or 5
    local isRaid = frame.isRaidFrame
    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    if not db or not db.classPowerEnabled then
        self:HideTestClassPower(frame)
        return
    end
    if db.testShowClassPower == false then
        self:HideTestClassPower(frame)
        return
    end

    -- Role filter for test mode
    local role = testData.role
    if role and not IsRoleAllowed(db, role) then
        self:HideTestClassPower(frame)
        return
    end

    local data = LayoutTestPips(frame, maxPips, db, powerType)
    local frameIndex = testData.index or 0
    local filledCount = GetTestFillCount(maxPips, frameIndex)
    UpdateTestPips(frame, filledCount, maxPips, powerType, db)
    data.container:Show()
end

function DF:HideTestClassPower(frame)
    if not frame then return end
    local data = testPipData[frame]
    if data and data.container then
        data.container:Hide()
    end
end

function DF:CleanupTestClassPower()
    for frame, data in pairs(testPipData) do
        if data.container then
            data.container:Hide()
        end
    end
end

function DF:UpdateAllTestClassPower()
    if DF.testMode and DF.testPartyFrames then
        local db = DF:GetDB()
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame and frame:IsShown() then
                local testData = DF:GetTestUnitData(i, false)
                if testData then
                    testData.index = i
                    DF:UpdateTestClassPower(frame, testData)
                end
            end
        end
    end
    if DF.raidTestMode and DF.testRaidFrames then
        local raidDb = DF:GetRaidDB()
        local count = raidDb and raidDb.raidTestFrameCount or 10
        for i = 1, count do
            local frame = DF.testRaidFrames[i]
            if frame and frame:IsShown() then
                local testData = DF:GetTestUnitData(i, true)
                if testData then
                    testData.index = i
                    DF:UpdateTestClassPower(frame, testData)
                end
            end
        end
    end
end

-- ============================================================
-- REFRESH (LIVE + TEST MODE)
-- ============================================================

local eventFrame = CreateFrame("Frame")

local function Refresh()
    -- In test mode, update all test frames with pips and also handle the player pip
    if DF.testMode or DF.raidTestMode then
        DF:UpdateAllTestClassPower()
    end

    local frame, useRaidDb = GetPlayerFrameForClassPower()
    local db = DF.GetDB and (useRaidDb and DF:GetRaidDB() or DF:GetDB()) or nil

    -- In raid, raid frame units may not be assigned yet; if we fell back to party frame but it's hidden, retry
    if IsInRaid() and DF.raidContainer and DF.raidContainer:IsShown() and not useRaidDb and frame == DF.playerFrame and (not frame or not frame:IsShown()) then
        if C_Timer and C_Timer.After then
            C_Timer.After(0.5, Refresh)
        end
        return
    end

    currentTargetFrame = frame
    currentUseRaidDb = useRaidDb

    if not frame or not frame:IsShown() then
        if pipContainer then pipContainer:Hide() end
        activePowerType = nil
        activePowerToken = nil
        if db and db.classPowerEnabled then
            eventFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
            eventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        end
        return
    end

    if not db or not db.classPowerEnabled then
        if pipContainer then pipContainer:Hide() end
        activePowerType = nil
        activePowerToken = nil
        eventFrame:UnregisterEvent("UNIT_POWER_FREQUENT")
        eventFrame:UnregisterEvent("UNIT_MAXPOWER")
        return
    end

    -- Test mode: the player frame pips are handled by UpdateAllTestClassPower
    -- We still need the live pip container for non-test mode
    if DF.testMode or DF.raidTestMode then
        if pipContainer then pipContainer:Hide() end
        return
    end

    -- Role filter: check if current player role is allowed
    local playerRole = UnitGroupRolesAssigned("player") or "NONE"
    if not IsRoleAllowed(db, playerRole) then
        if pipContainer then pipContainer:Hide() end
        activePowerType = nil
        activePowerToken = nil
        return
    end

    local powerType, powerToken, maxPower = DetectClassPower()

    if not powerType or not maxPower or type(maxPower) ~= "number" or maxPower == 0 then
        activePowerType = nil
        activePowerToken = nil
        if pipContainer then pipContainer:Hide() end
        eventFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
        eventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        return
    end

    activePowerType = powerType
    activePowerToken = powerToken

    local containerParent = (db.classPowerIgnoreFade and frame:GetParent()) or frame
    if not pipContainer then
        pipContainer = CreateFrame("Frame", nil, containerParent)
    end
    pipContainer:SetParent(containerParent)
    local baseLevel = frame.healthBar and frame.healthBar:GetFrameLevel() or frame:GetFrameLevel()
    pipContainer:SetFrameLevel(containerParent == frame and (baseLevel + 5) or (frame:GetFrameLevel() + 10))

    eventFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    eventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")

    LayoutPips(frame, maxPower, db)
    pipContainer:Show()
    UpdatePips()
end

-- ============================================================
-- EVENT HANDLER
-- ============================================================

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

eventFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "GROUP_ROSTER_UPDATE" then
        Refresh()
        return
    end
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" then
        if C_Timer and C_Timer.After then
            C_Timer.After(0.5, Refresh)
            if event == "PLAYER_ENTERING_WORLD" then
                C_Timer.After(2, Refresh)
            end
        else
            Refresh()
        end
    elseif event == "UNIT_POWER_FREQUENT" and arg1 == "player" then
        if activePowerToken then
            if arg2 == activePowerToken then
                UpdatePips()
            end
        else
            local pType, pToken, maxP = DetectClassPower()
            if pType and maxP and maxP > 0 then
                Refresh()
            end
        end
    elseif event == "UNIT_MAXPOWER" and arg1 == "player" then
        if activePowerToken then
            Refresh()
        else
            local pType, pToken, maxP = DetectClassPower()
            if pType and maxP and maxP > 0 then
                Refresh()
            end
        end
    end
end)

-- ============================================================
-- EXPORTS
-- ============================================================

DF.RefreshClassPower = Refresh

DF.UpdateClassPowerAlpha = function()
    if not pipContainer or not pipContainer:IsShown() then return end
    local frame, useRaidDb = GetPlayerFrameForClassPower()
    if not frame then return end
    local db = DF.GetDB and (useRaidDb and DF:GetRaidDB() or DF:GetDB()) or nil
    if not db then return end
    local containerParent = (db.classPowerIgnoreFade and frame:GetParent()) or frame
    if pipContainer:GetParent() ~= containerParent then
        pipContainer:SetParent(containerParent)
    end
    pipContainer:SetAlpha(1.0)
end
