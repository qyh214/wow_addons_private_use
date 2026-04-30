local addonName, DF = ...

-- ============================================================
-- PERFORMANCE TEST UI
-- Checkboxes to disable major systems for isolating memory issues
-- Usage: /df perftest
-- ============================================================

-- Global flags that other systems will check
DF.PerfTest = {
    -- All default to true (enabled)
    -- Major systems
    enableAuras = true,
    enableDispel = true,
    enableDefensive = true,
    enableMissingBuff = true,
    enableRange = true,
    enableHealthFade = true,
    enableHighlights = true,
    enableHealPrediction = true,
    enableAbsorbs = true,
    -- Additional systems
    enableBlizzardAuraCache = true,
    enablePrivateAuras = true,
    enableTargetedSpells = true,
    enableHealthUpdates = true,
    enablePowerBar = true,
    enableNameUpdates = true,
    enableRoleLeaderIcons = true,
    enableStatusIcons = true,
    enableConnectionStatus = true,
    enableAnimations = true,
    enableAllEvents = true,  -- Nuclear option
    enableClickCastApplyBindings = true,  -- Click casting binding updates
}

local frame = nil
local allCheckboxes = {}

local function CreateCheckbox(parent, label, key, x, yOffset)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, yOffset)
    cb:SetSize(24, 24)
    cb:SetChecked(DF.PerfTest[key])
    cb.key = key  -- Store key for OnShow refresh
    
    cb.text = cb:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    cb.text:SetText(label)
    
    cb:SetScript("OnClick", function(self)
        DF.PerfTest[key] = self:GetChecked()
        local status = self:GetChecked() and "|cff00ff00ON|r" or "|cffff0000OFF|r"
        print("|cff00ff00DF PerfTest:|r " .. label .. " = " .. status)
    end)
    
    allCheckboxes[#allCheckboxes + 1] = cb
    return cb
end

local function CreatePerfTestFrame()
    if frame then
        frame:Show()
        return frame
    end
    
    wipe(allCheckboxes)
    
    frame = CreateFrame("Frame", "DFPerfTestFrame", UIParent, "BackdropTemplate")
    frame:SetSize(480, 460)  -- Taller to fit second row of buttons
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText("DF Performance Test")
    
    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -3)
    subtitle:SetText("Uncheck to disable systems for testing")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Memory display row
    frame.memText = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    frame.memText:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.memText:SetText("Memory: --")
    frame.memText:SetTextColor(1, 1, 0)
    
    frame.deltaText = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    frame.deltaText:SetPoint("LEFT", frame.memText, "RIGHT", 20, 0)
    frame.deltaText:SetText("Delta: --")
    frame.deltaText:SetTextColor(0.7, 0.7, 0.7)
    
    frame.gcMemText = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    frame.gcMemText:SetPoint("LEFT", frame.deltaText, "RIGHT", 20, 0)
    frame.gcMemText:SetText("After GC: --")
    frame.gcMemText:SetTextColor(0.5, 1, 0.5)
    
    -- Column headers
    local col1Header = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    col1Header:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -80)
    col1Header:SetText("|cff00ff00Major Systems|r")
    
    local col2Header = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    col2Header:SetPoint("TOPLEFT", frame, "TOPLEFT", 245, -80)
    col2Header:SetText("|cff00ff00Additional Systems|r")
    
    -- Checkboxes - Column 1 (Major Systems)
    local yStart = -100
    local yStep = -24
    local col1X = 10
    local col2X = 240
    local i = 0
    
    CreateCheckbox(frame, "Auras (Buffs/Debuffs)", "enableAuras", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Dispel Overlay", "enableDispel", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Defensive Icon", "enableDefensive", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Missing Buff Icon", "enableMissingBuff", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Range Checking", "enableRange", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Health Threshold Fade", "enableHealthFade", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Highlights (Target/Mouse)", "enableHighlights", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Heal Prediction", "enableHealPrediction", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Absorb Shields", "enableAbsorbs", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Health Updates", "enableHealthUpdates", col1X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Power Bar", "enablePowerBar", col1X, yStart + (i * yStep)); i = i + 1
    
    -- Checkboxes - Column 2 (Additional Systems)
    i = 0
    CreateCheckbox(frame, "Blizzard Aura Cache", "enableBlizzardAuraCache", col2X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Private Auras", "enablePrivateAuras", col2X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Targeted Spells", "enableTargetedSpells", col2X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Name Updates", "enableNameUpdates", col2X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Role/Leader Icons", "enableRoleLeaderIcons", col2X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Status Icons", "enableStatusIcons", col2X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Connection Status", "enableConnectionStatus", col2X, yStart + (i * yStep)); i = i + 1
    CreateCheckbox(frame, "Animations", "enableAnimations", col2X, yStart + (i * yStep)); i = i + 1
    
    -- Divider
    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.5, 0.5, 0.5, 0.5)
    divider:SetSize(450, 1)
    divider:SetPoint("TOP", frame, "TOP", 0, -345)
    
    -- Nuclear option
    local nuclearCb = CreateCheckbox(frame, "|cffff0000ALL EVENTS (Nuclear - disables entire OnEvent)|r", "enableAllEvents", col1X, -355)
    nuclearCb.text:SetTextColor(1, 0.5, 0.5)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    
    -- Button row
    local btnY = 15
    local btnWidth = 90
    local btnHeight = 22
    
    -- GC Button
    local gcBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    gcBtn:SetSize(btnWidth, btnHeight)
    gcBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, btnY)
    gcBtn:SetText("Force GC")
    gcBtn:SetScript("OnClick", function()
        collectgarbage("collect")
        UpdateAddOnMemoryUsage()
        local mem = GetAddOnMemoryUsage("DandersFrames")
        frame.gcMemText:SetText(string.format("After GC: %.2f KB", mem))
        print("|cff00ff00DF PerfTest:|r GC done. Memory: " .. string.format("%.2f", mem) .. " KB")
    end)
    
    -- Disable All button
    local disableBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    disableBtn:SetSize(btnWidth, btnHeight)
    disableBtn:SetPoint("LEFT", gcBtn, "RIGHT", 5, 0)
    disableBtn:SetText("Disable All")
    disableBtn:SetScript("OnClick", function()
        for key in pairs(DF.PerfTest) do
            DF.PerfTest[key] = false
        end
        -- Refresh checkboxes
        for _, cb in ipairs(allCheckboxes) do
            cb:SetChecked(false)
        end
        print("|cff00ff00DF PerfTest:|r All systems |cffff0000DISABLED|r")
    end)
    
    -- Enable All button
    local enableBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    enableBtn:SetSize(btnWidth, btnHeight)
    enableBtn:SetPoint("LEFT", disableBtn, "RIGHT", 5, 0)
    enableBtn:SetText("Enable All")
    enableBtn:SetScript("OnClick", function()
        for key in pairs(DF.PerfTest) do
            DF.PerfTest[key] = true
        end
        -- Refresh checkboxes
        for _, cb in ipairs(allCheckboxes) do
            cb:SetChecked(true)
        end
        print("|cff00ff00DF PerfTest:|r All systems |cff00ff00ENABLED|r")
    end)
    
    -- Snapshot button (takes memory reading after GC for comparison)
    local snapshotBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    snapshotBtn:SetSize(btnWidth, btnHeight)
    snapshotBtn:SetPoint("LEFT", enableBtn, "RIGHT", 5, 0)
    snapshotBtn:SetText("Snapshot")
    frame.snapshotMem = nil
    snapshotBtn:SetScript("OnClick", function()
        collectgarbage("collect")
        UpdateAddOnMemoryUsage()
        frame.snapshotMem = GetAddOnMemoryUsage("DandersFrames")
        print("|cff00ff00DF PerfTest:|r Snapshot taken: " .. string.format("%.2f", frame.snapshotMem) .. " KB")
    end)
    
    -- Second row of buttons
    local btnY2 = 45
    
    -- Pause button
    frame.isPaused = false
    local pauseBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    pauseBtn:SetSize(btnWidth, btnHeight)
    pauseBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, btnY2)
    pauseBtn:SetText("Pause Monitor")
    pauseBtn:SetScript("OnClick", function(self)
        frame.isPaused = not frame.isPaused
        if frame.isPaused then
            self:SetText("Resume")
            frame.memText:SetText("Memory: |cffaaaaa-- PAUSED --|r")
            frame.deltaText:SetText("")
            print("|cff00ff00DF PerfTest:|r Monitoring |cffff0000PAUSED|r - UI no longer allocating memory")
        else
            self:SetText("Pause Monitor")
            frame.lastMem = 0
            frame.lastTime = GetTime()
            print("|cff00ff00DF PerfTest:|r Monitoring |cff00ff00RESUMED|r")
        end
    end)
    
    -- Run 10s Test button
    local testBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    testBtn:SetSize(btnWidth + 20, btnHeight)
    testBtn:SetPoint("LEFT", pauseBtn, "RIGHT", 5, 0)
    testBtn:SetText("Run 10s Test")
    testBtn:SetScript("OnClick", function(self)
        -- Pause the UI monitor during test
        local wasPaused = frame.isPaused
        frame.isPaused = true
        pauseBtn:SetText("Resume")
        frame.memText:SetText("Memory: |cffaaaa00TESTING...|r")
        frame.deltaText:SetText("")
        
        self:Disable()
        print("|cff00ff00DF PerfTest:|r Starting 10 second memory test (UI paused)...")
        
        collectgarbage("collect")
        UpdateAddOnMemoryUsage()
        local startMem = GetAddOnMemoryUsage("DandersFrames")
        local startTime = GetTime()
        
        C_Timer.After(10, function()
            collectgarbage("collect")
            UpdateAddOnMemoryUsage()
            local endMem = GetAddOnMemoryUsage("DandersFrames")
            local endTime = GetTime()
            local elapsed = endTime - startTime
            local delta = endMem - startMem
            local perSec = delta / elapsed
            
            print("|cff00ff00DF PerfTest:|r ========== 10 SECOND TEST RESULTS ==========")
            print(string.format("  Start: %.2f KB", startMem))
            print(string.format("  End:   %.2f KB (after GC)", endMem))
            print(string.format("  Delta: %.2f KB over %.1f seconds", delta, elapsed))
            local color = perSec > 0.5 and "|cffff0000" or perSec > 0.1 and "|cffffff00" or "|cff00ff00"
            print(string.format("  Rate:  %s%.3f KB/s|r", color, perSec))
            print("|cff00ff00DF PerfTest:|r =============================================")
            
            self:Enable()
            -- Restore pause state
            if not wasPaused then
                frame.isPaused = false
                pauseBtn:SetText("Pause Monitor")
                frame.lastMem = endMem
                frame.lastTime = GetTime()
            end
        end)
    end)
    
    -- Run 30s Test button
    local test30Btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    test30Btn:SetSize(btnWidth + 20, btnHeight)
    test30Btn:SetPoint("LEFT", testBtn, "RIGHT", 5, 0)
    test30Btn:SetText("Run 30s Test")
    test30Btn:SetScript("OnClick", function(self)
        -- Pause the UI monitor during test
        local wasPaused = frame.isPaused
        frame.isPaused = true
        pauseBtn:SetText("Resume")
        frame.memText:SetText("Memory: |cffaaaa00TESTING 30s...|r")
        frame.deltaText:SetText("")
        
        self:Disable()
        testBtn:Disable()
        print("|cff00ff00DF PerfTest:|r Starting 30 second memory test (UI paused)...")
        
        collectgarbage("collect")
        UpdateAddOnMemoryUsage()
        local startMem = GetAddOnMemoryUsage("DandersFrames")
        local startTime = GetTime()
        
        C_Timer.After(30, function()
            collectgarbage("collect")
            UpdateAddOnMemoryUsage()
            local endMem = GetAddOnMemoryUsage("DandersFrames")
            local endTime = GetTime()
            local elapsed = endTime - startTime
            local delta = endMem - startMem
            local perSec = delta / elapsed
            
            print("|cff00ff00DF PerfTest:|r ========== 30 SECOND TEST RESULTS ==========")
            print(string.format("  Start: %.2f KB", startMem))
            print(string.format("  End:   %.2f KB (after GC)", endMem))
            print(string.format("  Delta: %.2f KB over %.1f seconds", delta, elapsed))
            local color = perSec > 0.5 and "|cffff0000" or perSec > 0.1 and "|cffffff00" or "|cff00ff00"
            print(string.format("  Rate:  %s%.3f KB/s|r", color, perSec))
            print("|cff00ff00DF PerfTest:|r =============================================")
            
            self:Enable()
            testBtn:Enable()
            -- Restore pause state
            if not wasPaused then
                frame.isPaused = false
                pauseBtn:SetText("Pause Monitor")
                frame.lastMem = endMem
                frame.lastTime = GetTime()
            end
        end)
    end)
    
    -- Update memory display periodically
    frame.lastMem = 0
    frame.lastTime = GetTime()
    frame:SetScript("OnUpdate", function(self, elapsed)
        -- Skip if paused
        if self.isPaused then return end
        
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed < 0.5 then return end
        self.elapsed = 0
        
        UpdateAddOnMemoryUsage()
        local mem = GetAddOnMemoryUsage("DandersFrames")
        local now = GetTime()
        local timeDelta = now - self.lastTime
        
        self.memText:SetText(string.format("Memory: %.2f KB", mem))
        
        if self.lastMem > 0 and timeDelta > 0 then
            local delta = (mem - self.lastMem) / timeDelta
            local color = delta > 2 and "|cffff0000" or delta > 0.5 and "|cffffff00" or "|cff00ff00"
            self.deltaText:SetText(string.format("Delta: %s%+.2f KB/s|r", color, delta))
        end
        
        -- Show comparison to snapshot if available
        if self.snapshotMem then
            local diff = mem - self.snapshotMem
            local color = diff > 10 and "|cffff0000" or diff > 1 and "|cffffff00" or "|cff00ff00"
            self.gcMemText:SetText(string.format("vs Snapshot: %s%+.2f KB|r", color, diff))
        end
        
        self.lastMem = mem
        self.lastTime = now
    end)
    
    -- Refresh checkbox states on show
    frame:SetScript("OnShow", function(self)
        for _, cb in ipairs(allCheckboxes) do
            if cb.key then
                cb:SetChecked(DF.PerfTest[cb.key])
            end
        end
    end)
    
    frame:Show()
    return frame
end

-- Toggle function
local function TogglePerfTestFrame()
    if frame and frame:IsShown() then
        frame:Hide()
    else
        CreatePerfTestFrame()
    end
end

-- Slash command
SLASH_DFPERFTEST1 = "/dfperftest"
SLASH_DFPERFTEST2 = "/dfperf"
SlashCmdList["DFPERFTEST"] = TogglePerfTestFrame

-- Hook into /df command after a delay to ensure it's registered
C_Timer.After(1, function()
    local originalSlashHandler = SlashCmdList["DANDERSFRAMES"]
    if originalSlashHandler then
        SlashCmdList["DANDERSFRAMES"] = function(msg)
            if msg == "perftest" or msg == "perf" then
                TogglePerfTestFrame()
            else
                originalSlashHandler(msg)
            end
        end
    end
end)
