local Preydator = _G.Preydator
if type(Preydator) ~= "table" then
    return
end

local DebugRuntime = {}
Preydator:RegisterModule("DebugRuntime", DebugRuntime)

function DebugRuntime:FormatMemoryKB(value)
    return string.format("%.1f", value or 0)
end

function DebugRuntime:PrintMemoryUsage(ctx)
    local collectgarbageFn = ctx and ctx.collectgarbageFn
    local printFn = (ctx and ctx.printFn) or print
    if type(collectgarbageFn) ~= "function" then
        printFn("Preydator: collectgarbage API unavailable.")
        return
    end

    local before = collectgarbageFn("count")
    collectgarbageFn("collect")
    local after = collectgarbageFn("count")
    local delta = before - after

    printFn(
        "Preydator memory (KB): before=" .. self:FormatMemoryKB(before)
            .. " afterGC=" .. self:FormatMemoryKB(after)
            .. " reclaimed=" .. self:FormatMemoryKB(delta)
    )
end

function DebugRuntime:BuildStageSoundPlayedSummary(state, maxStage)
    local parts = {}
    local limit = tonumber(maxStage) or 0
    for stage = 1, limit do
        parts[#parts + 1] = tostring(stage) .. "=" .. tostring(state and state.stageSoundPlayed and state.stageSoundPlayed[stage] == true)
    end
    return table.concat(parts, ", ")
end

function DebugRuntime:TrimText(value, maxLen)
    if type(value) ~= "string" then
        return ""
    end

    maxLen = tonumber(maxLen) or 80
    if #value <= maxLen then
        return value
    end

    return string.sub(value, 1, maxLen - 3) .. "..."
end