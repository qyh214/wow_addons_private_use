-- ============================================================
-- TestFramePool.lua
-- Creates separate non-secure frames for test mode preview
-- These frames are completely independent of live header children
-- ============================================================

local _, DF = ...

-- Test frame storage
DF.testPartyFrames = {}  -- [0]=player, [1-4]=party
DF.testRaidFrames = {}   -- [1-40]=raid

-- Test containers
DF.testPartyContainer = nil
DF.testRaidContainer = nil

-- Flag to track initialization
DF.testFramePoolInitialized = false

-- ============================================================
-- CREATE TEST CONTAINERS
-- ============================================================
local function CreateTestContainers()
    local db = DF:GetDB()
    local raidDb = DF:GetRaidDB()
    
    -- Party test container (non-secure)
    if not DF.testPartyContainer then
        local scale = db.frameScale or 1.0
        DF.testPartyContainer = CreateFrame("Frame", "DandersTestPartyContainer", UIParent)
        DF.testPartyContainer:SetScale(scale)
        DF.testPartyContainer:SetPoint("CENTER", UIParent, "CENTER", (db.anchorX or 0) / scale, (db.anchorY or 0) / scale)
        DF.testPartyContainer:SetSize(500, 200)
        DF.testPartyContainer:Hide()  -- Hidden by default
    end

    -- Raid test container (non-secure)
    if not DF.testRaidContainer then
        local raidScale = raidDb.frameScale or 1.0
        DF.testRaidContainer = CreateFrame("Frame", "DandersTestRaidContainer", UIParent)
        DF.testRaidContainer:SetScale(raidScale)
        DF.testRaidContainer:SetPoint("CENTER", UIParent, "CENTER", (raidDb.raidAnchorX or 0) / raidScale, (raidDb.raidAnchorY or 0) / raidScale)
        DF.testRaidContainer:SetSize(600, 400)
        DF.testRaidContainer:Hide()  -- Hidden by default
    end
end

-- ============================================================
-- CREATE SINGLE TEST FRAME
-- ============================================================
local function CreateTestFrame(index, isRaid)
    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    local parent = isRaid and DF.testRaidContainer or DF.testPartyContainer
    
    -- Generate frame name
    local frameName
    if isRaid then
        frameName = "DandersTestRaidFrame" .. index
    else
        frameName = "DandersTestPartyFrame" .. index
    end
    
    -- Create as regular Button (NOT SecureUnitButtonTemplate)
    -- This allows us to show/hide at any time without combat lockdown
    local frame = CreateFrame("Button", frameName, parent)
    frame:SetSize(db.frameWidth or 120, db.frameHeight or 50)
    
    -- Set up frame properties
    frame.index = index
    frame.isRaidFrame = isRaid
    frame.dfIsTestFrame = true  -- Mark as test frame
    frame.dfIsDandersFrame = true  -- For consistency with live frames
    
    -- Assign a fake unit for test purposes
    if isRaid then
        frame.unit = "raid" .. index
    else
        frame.unit = index == 0 and "player" or ("party" .. index)
    end
    
    -- Enable mouse for hover effects in test mode
    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyUp")
    
    -- Use existing CreateFrameElements to create all visual elements
    -- This ensures test frames look identical to live frames
    if DF.CreateFrameElements then
        DF:CreateFrameElements(frame, isRaid)
    end
    
    -- CRITICAL: Apply frame style to set up fonts and other settings
    -- Without this, FontStrings won't have fonts set
    if DF.ApplyFrameStyle then
        DF:ApplyFrameStyle(frame)
    end
    
    -- Apply aura layouts to set fonts on aura icons
    if DF.ApplyAuraLayout then
        DF:ApplyAuraLayout(frame, "BUFF")
        DF:ApplyAuraLayout(frame, "DEBUFF")
    end
    
    -- Binding tooltip on hover
    frame:SetScript("OnEnter", function(self)
        if DF.ShowBindingTooltip then DF:ShowBindingTooltip(self) end
    end)
    frame:SetScript("OnLeave", function(self)
        if DFBindingTooltip then DFBindingTooltip:Hide(); DFBindingTooltip.anchorFrame = nil end
    end)

    -- Hide by default
    frame:Hide()

    return frame
end

-- ============================================================
-- CREATE TEST FRAME POOL
-- ============================================================
function DF:CreateTestFramePool()
    if DF.testFramePoolInitialized then return end
    
    -- Create containers first
    CreateTestContainers()
    
    -- Create party test frames (player + party1-4)
    for i = 0, 4 do
        DF.testPartyFrames[i] = CreateTestFrame(i, false)
    end
    
    -- Create raid test frames (1-40)
    for i = 1, 40 do
        DF.testRaidFrames[i] = CreateTestFrame(i, true)
    end
    
    DF.testFramePoolInitialized = true
    
    if DF.debugMode then
        print("|cff00ff00[DF TestFramePool]|r Created 5 party + 40 raid test frames")
    end
end

-- ============================================================
-- POSITION TEST CONTAINERS
-- ============================================================
function DF:PositionTestPartyContainer()
    if not DF.testPartyContainer then return end

    local db = DF:GetDB()
    local scale = db.frameScale or 1.0
    DF.testPartyContainer:SetScale(scale)
    DF.testPartyContainer:ClearAllPoints()
    DF.testPartyContainer:SetPoint("CENTER", UIParent, "CENTER", (db.anchorX or 0) / scale, (db.anchorY or 0) / scale)
end

function DF:PositionTestRaidContainer()
    if not DF.testRaidContainer then return end

    local db = DF:GetRaidDB()
    local raidScale = db.frameScale or 1.0
    DF.testRaidContainer:SetScale(raidScale)
    DF.testRaidContainer:ClearAllPoints()
    DF.testRaidContainer:SetPoint("CENTER", UIParent, "CENTER", (db.raidAnchorX or 0) / raidScale, (db.raidAnchorY or 0) / raidScale)
end

-- ============================================================
-- APPLY FRAME STYLE TO TEST FRAMES
-- ============================================================
function DF:ApplyTestFrameStyles()
    if not DF.testFramePoolInitialized then return end
    
    local partyDb = DF:GetDB()
    local raidDb = DF:GetRaidDB()
    
    -- Apply styles to party test frames
    for i = 0, 4 do
        local frame = DF.testPartyFrames[i]
        if frame then
            frame:SetSize(partyDb.frameWidth or 120, partyDb.frameHeight or 50)
            if DF.ApplyFrameStyle then
                DF:ApplyFrameStyle(frame)
            end
        end
    end
    
    -- Apply styles to raid test frames
    for i = 1, 40 do
        local frame = DF.testRaidFrames[i]
        if frame then
            frame:SetSize(raidDb.frameWidth or 90, raidDb.frameHeight or 40)
            if DF.ApplyFrameStyle then
                DF:ApplyFrameStyle(frame)
            end
        end
    end
end

-- ============================================================
-- ITERATOR HELPERS FOR TEST FRAMES
-- ============================================================
-- These mirror the live frame iterators but for test frames

function DF:IterateTestPartyFrames(callback)
    if not callback then return end
    for i = 0, 4 do
        local frame = DF.testPartyFrames[i]
        if frame then
            callback(frame)
        end
    end
end

function DF:IterateTestRaidFrames(callback)
    if not callback then return end
    for i = 1, 40 do
        local frame = DF.testRaidFrames[i]
        if frame then
            callback(frame)
        end
    end
end

function DF:GetTestPartyFrame(index)
    return DF.testPartyFrames[index]
end

function DF:GetTestRaidFrame(index)
    return DF.testRaidFrames[index]
end

-- ============================================================
-- SHOW/HIDE TEST CONTAINERS
-- ============================================================
function DF:ShowTestPartyContainer()
    if not DF.testPartyContainer then
        DF:CreateTestFramePool()
    end
    
    -- Hide live party container
    if DF.partyContainer then
        DF.partyContainer:Hide()
    end
    
    -- Position and show test container
    DF:PositionTestPartyContainer()
    DF.testPartyContainer:Show()
end

function DF:HideTestPartyContainer()
    if DF.testPartyContainer then
        DF.testPartyContainer:Hide()
    end
    
    -- Show live party container (if not in combat)
    if DF.partyContainer and not InCombatLockdown() then
        DF.partyContainer:Show()
        -- Trigger header visibility update
        if DF.UpdateHeaderVisibility then
            DF:UpdateHeaderVisibility()
        end
    end
end

function DF:ShowTestRaidContainer()
    if not DF.testRaidContainer then
        DF:CreateTestFramePool()
    end
    
    -- Hide live raid container
    if DF.raidContainer then
        DF.raidContainer:Hide()
    end
    
    -- Hide party frames/container when showing raid test
    if DF.partyContainer then
        DF.partyContainer:Hide()
    end
    if DF.testPartyContainer then
        DF.testPartyContainer:Hide()
    end
    
    -- Position and show test container
    DF:PositionTestRaidContainer()
    DF.testRaidContainer:Show()
end

function DF:HideTestRaidContainer()
    if DF.testRaidContainer then
        DF.testRaidContainer:Hide()
    end
    
    -- Restore appropriate live container based on group status
    if not InCombatLockdown() then
        if IsInRaid() then
            if DF.raidContainer then
                DF.raidContainer:Show()
            end
        else
            if DF.partyContainer then
                DF.partyContainer:Show()
            end
        end
        
        if DF.UpdateHeaderVisibility then
            DF:UpdateHeaderVisibility()
        end
    end
end
