-- ============================================================
-- DANDERSFRAMES PERFORMANCE TRACKER
-- Monitors memory and CPU usage over time
-- ============================================================

local _, DF = ...

-- Performance data storage
DF.Performance = {
    enabled = false,
    updateInterval = 1.0,  -- How often to sample (seconds)
    historySize = 300,     -- Keep 5 minutes of history at 1s intervals
    
    -- Current stats
    currentMemory = 0,
    currentCPU = 0,
    cpuEnabled = false,
    useNewAPI = false,
    
    -- History arrays
    memoryHistory = {},
    cpuHistory = {},
    timestamps = {},
    
    -- Stats
    peakMemory = 0,
    minMemory = math.huge,
    avgMemory = 0,
    totalSamples = 0,
    
    -- CPU stats
    peakCPU = 0,
    lastCPU = 0,
    cpuPerSecond = 0,
    lastFrameTime = 0,  -- Time spent in the last frame (new API)
    
    -- Session tracking
    sessionStart = 0,
    lastGC = 0,
}

local Perf = DF.Performance

-- ============================================================
-- CORE FUNCTIONS
-- ============================================================

-- Update memory usage
local function UpdateMemory()
    UpdateAddOnMemoryUsage()
    local mem = GetAddOnMemoryUsage("DandersFrames")
    Perf.currentMemory = mem
    
    -- Update stats
    if mem > Perf.peakMemory then
        Perf.peakMemory = mem
    end
    if mem < Perf.minMemory then
        Perf.minMemory = mem
    end
    
    -- Running average
    Perf.totalSamples = Perf.totalSamples + 1
    Perf.avgMemory = Perf.avgMemory + (mem - Perf.avgMemory) / Perf.totalSamples
    
    return mem
end

-- Update CPU usage
local function UpdateCPU()
    if Perf.useNewAPI then
        -- Use the new C_AddOnProfiler API (10.0+)
        local recentAvg = C_AddOnProfiler.GetAddOnMetric("DandersFrames", Enum.AddOnProfilerMetric.RecentAverageTime)
        local lastTime = C_AddOnProfiler.GetAddOnMetric("DandersFrames", Enum.AddOnProfilerMetric.LastTime)
        local peakTime = C_AddOnProfiler.GetAddOnMetric("DandersFrames", Enum.AddOnProfilerMetric.PeakTime)
        
        -- RecentAverageTime is in seconds, convert to ms
        Perf.cpuPerSecond = (recentAvg or 0) * 1000
        Perf.lastFrameTime = (lastTime or 0) * 1000
        Perf.currentCPU = Perf.cpuPerSecond
        
        if peakTime then
            local peakMs = peakTime * 1000
            if peakMs > Perf.peakCPU then
                Perf.peakCPU = peakMs
            end
        end
        
        return Perf.cpuPerSecond
    elseif Perf.cpuEnabled then
        -- Fall back to old API if scriptProfile is enabled
        UpdateAddOnCPUUsage()
        local cpu = GetAddOnCPUUsage("DandersFrames")
        
        -- Calculate CPU per second (delta since last update)
        local cpuDelta = cpu - Perf.lastCPU
        Perf.cpuPerSecond = cpuDelta / Perf.updateInterval
        Perf.lastCPU = cpu
        Perf.currentCPU = cpu
        
        if Perf.cpuPerSecond > Perf.peakCPU then
            Perf.peakCPU = Perf.cpuPerSecond
        end
        
        return cpu
    end
    
    return 0
end

-- Add sample to history
local function AddToHistory(mem, cpu)
    local now = GetTime()
    
    -- Add to history
    table.insert(Perf.memoryHistory, mem)
    table.insert(Perf.cpuHistory, cpu)
    table.insert(Perf.timestamps, now)
    
    -- Trim history if too long
    while #Perf.memoryHistory > Perf.historySize do
        table.remove(Perf.memoryHistory, 1)
        table.remove(Perf.cpuHistory, 1)
        table.remove(Perf.timestamps, 1)
    end
end

-- ============================================================
-- TRACKING FRAME
-- ============================================================

local trackingFrame = CreateFrame("Frame")
trackingFrame.elapsed = 0
trackingFrame:Hide()

trackingFrame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    
    if self.elapsed >= Perf.updateInterval then
        self.elapsed = 0
        
        local mem = UpdateMemory()
        local cpu = UpdateCPU()
        AddToHistory(mem, cpu)
    end
end)

-- ============================================================
-- PUBLIC API
-- ============================================================

-- Start tracking
function DF:StartPerformanceTracking(interval)
    Perf.updateInterval = interval or 1.0
    Perf.sessionStart = GetTime()
    Perf.enabled = true
    
    -- Check which CPU profiling method is available (check at runtime, not file load)
    local canUseNewAPI = C_AddOnProfiler and C_AddOnProfiler.GetAddOnMetric and Enum and Enum.AddOnProfilerMetric
    
    if canUseNewAPI then
        -- C_AddOnProfiler is available (10.0+) - no scriptProfile needed!
        Perf.cpuEnabled = true
        Perf.useNewAPI = true
        print("|cff00ff00DandersFrames:|r Performance tracking started (Memory + CPU via C_AddOnProfiler)")
    elseif GetCVarBool("scriptProfile") then
        -- Fall back to old API if scriptProfile is enabled
        Perf.cpuEnabled = true
        Perf.useNewAPI = false
        UpdateAddOnCPUUsage()
        Perf.lastCPU = GetAddOnCPUUsage("DandersFrames")
        print("|cff00ff00DandersFrames:|r Performance tracking started (Memory + CPU via scriptProfile)")
    else
        Perf.cpuEnabled = false
        Perf.useNewAPI = false
        print("|cff00ff00DandersFrames:|r Performance tracking started (Memory only)")
        print("|cffff9900Note:|r CPU profiling requires WoW 10.0+ or /console scriptProfile 1")
    end
    
    -- Initial sample
    UpdateMemory()
    if Perf.cpuEnabled then
        UpdateCPU()
    end
    
    trackingFrame:Show()
end

-- Stop tracking
function DF:StopPerformanceTracking()
    Perf.enabled = false
    trackingFrame:Hide()
    print("|cff00ff00DandersFrames:|r Performance tracking stopped")
end

-- Toggle tracking
function DF:TogglePerformanceTracking()
    if Perf.enabled then
        DF:StopPerformanceTracking()
    else
        DF:StartPerformanceTracking()
    end
end

-- Get current stats
function DF:GetPerformanceStats()
    UpdateMemory()
    if Perf.cpuEnabled then
        UpdateCPU()
    end
    
    return {
        memory = Perf.currentMemory,
        peakMemory = Perf.peakMemory,
        minMemory = Perf.minMemory ~= math.huge and Perf.minMemory or 0,
        avgMemory = Perf.avgMemory,
        
        cpuEnabled = Perf.cpuEnabled,
        useNewAPI = Perf.useNewAPI,
        cpuTotal = Perf.currentCPU,
        cpuPerSecond = Perf.cpuPerSecond,
        peakCPU = Perf.peakCPU,
        lastFrameTime = Perf.lastFrameTime,
        
        samples = Perf.totalSamples,
        sessionDuration = Perf.sessionStart > 0 and (GetTime() - Perf.sessionStart) or 0,
    }
end

-- Get history for graphing
function DF:GetPerformanceHistory()
    return {
        memory = Perf.memoryHistory,
        cpu = Perf.cpuHistory,
        timestamps = Perf.timestamps,
    }
end

-- Reset stats
function DF:ResetPerformanceStats()
    Perf.peakMemory = 0
    Perf.minMemory = math.huge
    Perf.avgMemory = 0
    Perf.totalSamples = 0
    Perf.peakCPU = 0
    Perf.memoryHistory = {}
    Perf.cpuHistory = {}
    Perf.timestamps = {}
    Perf.sessionStart = GetTime()
    print("|cff00ff00DandersFrames:|r Performance stats reset")
end

-- Format memory for display
local function FormatMemory(kb)
    if kb >= 1024 then
        return string.format("%.2f MB", kb / 1024)
    else
        return string.format("%.1f KB", kb)
    end
end

-- Format time for display
local function FormatTime(seconds)
    if seconds >= 3600 then
        return string.format("%dh %dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
    elseif seconds >= 60 then
        return string.format("%dm %ds", math.floor(seconds / 60), math.floor(seconds % 60))
    else
        return string.format("%.1fs", seconds)
    end
end

-- Print current stats to chat
function DF:PrintPerformanceStats()
    local stats = DF:GetPerformanceStats()
    
    print("|cff00ff00=== DandersFrames Performance ===|r")
    print(string.format("|cffaaaaaa Memory:|r %s (Peak: %s, Avg: %s)", 
        FormatMemory(stats.memory),
        FormatMemory(stats.peakMemory),
        FormatMemory(stats.avgMemory)))
    
    if stats.cpuEnabled then
        if stats.useNewAPI then
            -- New API shows average time per frame
            print(string.format("|cffaaaaaa CPU:|r %.3f ms/frame avg (Peak: %.3f ms, Last: %.3f ms)", 
                stats.cpuPerSecond,
                stats.peakCPU,
                stats.lastFrameTime or 0))
        else
            -- Old API shows cumulative time
            print(string.format("|cffaaaaaa CPU:|r %.2f ms/sec (Peak: %.2f ms/sec, Total: %.1f ms)", 
                stats.cpuPerSecond,
                stats.peakCPU,
                stats.cpuTotal))
        end
    else
        print("|cffaaaaaa CPU:|r Not available (requires WoW 10.0+ or /console scriptProfile 1)")
    end
    
    print(string.format("|cffaaaaaa Session:|r %s (%d samples)", 
        FormatTime(stats.sessionDuration),
        stats.samples))
end

-- Force garbage collection and report
function DF:ForceGarbageCollection()
    local beforeMem = Perf.currentMemory
    UpdateMemory()
    beforeMem = Perf.currentMemory
    
    collectgarbage("collect")
    
    UpdateMemory()
    local afterMem = Perf.currentMemory
    local freed = beforeMem - afterMem
    
    Perf.lastGC = GetTime()
    
    print(string.format("|cff00ff00DandersFrames:|r GC freed %s (Now: %s)", 
        FormatMemory(freed > 0 and freed or 0),
        FormatMemory(afterMem)))
end

-- ============================================================
-- PERFORMANCE MONITOR FRAME (Visual Display with Graph)
-- ============================================================

local monitorFrame = nil
local GRAPH_WIDTH = 260
local GRAPH_HEIGHT = 80
local GRAPH_POINTS = 150  -- Number of data points to show (2.5 mins at 1 sample/sec)

-- PERFORMANCE FIX: Pre-defined color to avoid table creation in OnUpdate
local GRAPH_COLOR_MEMORY = {r = 0.4, g = 0.9, b = 0.4, a = 0.8}

-- Draw graph using textures (more reliable than lines)
local function UpdateGraphTextures(graphFrame, data, color)
    if not graphFrame.bars then
        graphFrame.bars = {}
    end
    
    local count = #data
    if count < 2 then return 0, 0 end
    
    -- Determine how many points to show
    local startIdx = math.max(1, count - GRAPH_POINTS + 1)
    local pointsToShow = count - startIdx + 1
    
    -- Calculate min/max for auto-scaling
    local minVal, maxVal = math.huge, 0
    for i = startIdx, count do
        local val = data[i]
        if val and val < minVal then minVal = val end
        if val and val > maxVal then maxVal = val end
    end
    
    -- Ensure we have a valid range
    if minVal == math.huge then minVal = 0 end
    if maxVal == 0 then maxVal = 1 end
    
    -- Add padding
    local range = maxVal - minVal
    if range < 0.001 then 
        range = maxVal * 0.1
        if range < 0.001 then range = 1 end
        minVal = maxVal - range
    end
    
    -- Hide all existing bars first
    for _, bar in ipairs(graphFrame.bars) do
        bar:Hide()
    end
    
    -- Calculate bar width based on points to show
    local barWidth = math.max(1, GRAPH_WIDTH / GRAPH_POINTS)
    
    -- Draw bars for each point
    local barIdx = 0
    for i = startIdx, count do
        barIdx = barIdx + 1
        
        -- Create bar if needed
        if not graphFrame.bars[barIdx] then
            local bar = graphFrame:CreateTexture(nil, "ARTWORK")
            graphFrame.bars[barIdx] = bar
        end
        
        local bar = graphFrame.bars[barIdx]
        local val = data[i] or 0
        
        -- Calculate position and height
        local x = ((i - startIdx) / GRAPH_POINTS) * GRAPH_WIDTH
        local heightPct = (val - minVal) / range
        heightPct = math.max(0.01, math.min(1, heightPct))  -- Clamp between 1% and 100%
        local barHeight = heightPct * GRAPH_HEIGHT
        
        bar:SetSize(math.max(2, barWidth), math.max(1, barHeight))
        bar:SetPoint("BOTTOMLEFT", graphFrame, "BOTTOMLEFT", x, 0)
        bar:SetColorTexture(color.r, color.g, color.b, color.a or 0.8)
        bar:Show()
    end
    
    return minVal, maxVal
end

function DF:ShowPerformanceMonitor()
    if monitorFrame then
        monitorFrame:Show()
        return
    end
    
    -- Create the monitor frame
    monitorFrame = CreateFrame("Frame", "DandersFramesPerformanceMonitor", UIParent, "BackdropTemplate")
    monitorFrame:SetSize(300, 220)
    monitorFrame:SetPoint("TOPRIGHT", -20, -200)
    monitorFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    monitorFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    monitorFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    monitorFrame:SetMovable(true)
    monitorFrame:EnableMouse(true)
    monitorFrame:RegisterForDrag("LeftButton")
    monitorFrame:SetScript("OnDragStart", monitorFrame.StartMoving)
    monitorFrame:SetScript("OnDragStop", monitorFrame.StopMovingOrSizing)
    monitorFrame:SetFrameStrata("HIGH")
    monitorFrame:SetClampedToScreen(true)
    
    -- Title
    local title = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("TOP", 0, -8)
    title:SetText("|cff00ff00DandersFrames Performance|r")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, monitorFrame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function() monitorFrame:Hide() end)
    
    -- Row 1: Memory current + CPU current
    monitorFrame.memoryText = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    monitorFrame.memoryText:SetPoint("TOPLEFT", 12, -28)
    monitorFrame.memoryText:SetJustifyH("LEFT")
    
    monitorFrame.cpuText = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    monitorFrame.cpuText:SetPoint("TOPRIGHT", -12, -28)
    monitorFrame.cpuText:SetJustifyH("RIGHT")
    
    -- Row 2: Peak/Avg + Session
    monitorFrame.statsText = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    monitorFrame.statsText:SetPoint("TOPLEFT", 12, -42)
    monitorFrame.statsText:SetJustifyH("LEFT")
    
    monitorFrame.sessionText = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    monitorFrame.sessionText:SetPoint("TOPRIGHT", -12, -42)
    monitorFrame.sessionText:SetJustifyH("RIGHT")
    
    -- Graph section label
    local graphLabel = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    graphLabel:SetPoint("TOPLEFT", 12, -60)
    graphLabel:SetText("|cff88ff88Memory|r (Last 2.5 min)")
    
    -- Graph container
    local graphContainer = CreateFrame("Frame", nil, monitorFrame, "BackdropTemplate")
    graphContainer:SetPoint("TOPLEFT", 12, -75)
    graphContainer:SetSize(GRAPH_WIDTH + 6, GRAPH_HEIGHT + 6)
    graphContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    graphContainer:SetBackdropColor(0, 0, 0, 0.5)
    graphContainer:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    
    -- Graph frame (for drawing)
    monitorFrame.memoryGraph = CreateFrame("Frame", nil, graphContainer)
    monitorFrame.memoryGraph:SetPoint("BOTTOMLEFT", 3, 3)
    monitorFrame.memoryGraph:SetSize(GRAPH_WIDTH, GRAPH_HEIGHT)
    
    -- Horizontal grid lines
    for i = 1, 3 do
        local gridLine = graphContainer:CreateTexture(nil, "BACKGROUND")
        gridLine:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        gridLine:SetSize(GRAPH_WIDTH, 1)
        gridLine:SetPoint("BOTTOMLEFT", 3, 3 + (GRAPH_HEIGHT / 4) * i)
    end
    
    -- Min/Max labels (positioned outside graph on right side)
    monitorFrame.graphMaxLabel = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    monitorFrame.graphMaxLabel:SetPoint("TOPLEFT", graphContainer, "TOPRIGHT", 4, 0)
    monitorFrame.graphMaxLabel:SetTextColor(0.6, 0.6, 0.6)
    monitorFrame.graphMaxLabel:SetText("")
    
    monitorFrame.graphMinLabel = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    monitorFrame.graphMinLabel:SetPoint("BOTTOMLEFT", graphContainer, "BOTTOMRIGHT", 4, 0)
    monitorFrame.graphMinLabel:SetTextColor(0.6, 0.6, 0.6)
    monitorFrame.graphMinLabel:SetText("")
    
    -- Time labels below graph
    local timeLabel1 = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    timeLabel1:SetPoint("TOPLEFT", graphContainer, "BOTTOMLEFT", 0, -2)
    timeLabel1:SetText("-2.5m")
    timeLabel1:SetTextColor(0.5, 0.5, 0.5)
    
    local timeLabel2 = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    timeLabel2:SetPoint("TOPRIGHT", graphContainer, "BOTTOMRIGHT", 0, -2)
    timeLabel2:SetText("now")
    timeLabel2:SetTextColor(0.5, 0.5, 0.5)
    
    -- API info label at bottom
    monitorFrame.apiLabel = monitorFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    monitorFrame.apiLabel:SetPoint("BOTTOM", 0, 8)
    monitorFrame.apiLabel:SetTextColor(0.5, 0.5, 0.5)
    
    -- Update script
    monitorFrame.elapsed = 0
    monitorFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed < 0.5 then return end
        self.elapsed = 0
        
        local stats = DF:GetPerformanceStats()
        local history = DF:GetPerformanceHistory()
        
        -- Update text displays
        self.memoryText:SetText(string.format("|cff88ff88Mem:|r %s", FormatMemory(stats.memory)))
        
        if stats.cpuEnabled then
            if stats.useNewAPI then
                self.cpuText:SetText(string.format("|cff8888ffCPU:|r %.3f ms/f", stats.cpuPerSecond))
            else
                self.cpuText:SetText(string.format("|cff8888ffCPU:|r %.2f ms/s", stats.cpuPerSecond))
            end
        else
            self.cpuText:SetText("|cff666666CPU: N/A|r")
        end
        
        self.statsText:SetText(string.format("Peak: %s | Avg: %s", 
            FormatMemory(stats.peakMemory), 
            FormatMemory(stats.avgMemory)))
        
        self.sessionText:SetText(string.format("%s (%d)", 
            FormatTime(stats.sessionDuration),
            stats.samples))
        
        -- Update API label
        if stats.cpuEnabled then
            if stats.useNewAPI then
                self.apiLabel:SetText("Using C_AddOnProfiler API")
            else
                self.apiLabel:SetText("Using scriptProfile API")
            end
        else
            self.apiLabel:SetText("CPU profiling unavailable")
        end
        
        -- Update memory graph
        if history.memory and #history.memory >= 2 then
            local minMem, maxMem = UpdateGraphTextures(
                self.memoryGraph, 
                history.memory, 
                GRAPH_COLOR_MEMORY
            )
            
            if minMem and maxMem and minMem > 0 then
                self.graphMinLabel:SetText(FormatMemory(minMem))
                self.graphMaxLabel:SetText(FormatMemory(maxMem))
            end
        end
    end)
    
    -- Start tracking if not already
    if not Perf.enabled then
        DF:StartPerformanceTracking()
    end
    
    monitorFrame:Show()
end

function DF:HidePerformanceMonitor()
    if monitorFrame then
        monitorFrame:Hide()
    end
end

function DF:TogglePerformanceMonitor()
    if monitorFrame and monitorFrame:IsShown() then
        DF:HidePerformanceMonitor()
    else
        DF:ShowPerformanceMonitor()
    end
end

-- ============================================================
-- SLASH COMMANDS
-- ============================================================

-- NOTE: /dfperf is now handled by PerformanceTest.lua which opens a UI window
-- The functions below can still be called programmatically:
--   DF:StartPerformanceTracking()
--   DF:StopPerformanceTracking()
--   DF:PrintPerformanceStats()
--   DF:ResetPerformanceStats()
--   DF:ForceGarbageCollection()
--   DF:ShowPerformanceMonitor()
--   DF:HidePerformanceMonitor()
--   DF:TogglePerformanceMonitor()
