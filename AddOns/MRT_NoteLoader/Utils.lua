local _, MRT_NL = ...

local function GetSendChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInRaid() then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    end
end

local GetSpellLink = GetSpellLink or C_Spell.GetSpellLink

local isWaitForSending
function MRT_NL:SendChatMessage(lines)
    local sendChannel = GetSendChannel()
    if not sendChannel then
        MRT_NL_Send:SetEnabled(true)
        return
    end

    if isWaitForSending then return end
    isWaitForSending = true

    -- remove color codes
    lines = string.gsub(lines, "\124\124c%w%w%w%w%w%w%w%w", "")
    lines = string.gsub(lines, "\124\124r", "")

    -- {time:mm:ss}, {time:ss}
    lines = string.gsub(lines, "%{time:%d+:%d+%}", function(text)
        local m, s = strmatch(text, "(%d+):(%d+)")
        m = tonumber(m)
        s = format("%02d", s)
        return "["..m..":"..s.."]"
    end)
    lines = string.gsub(lines, "%{time:%d+%}", function(text)
        local s = tonumber(strmatch(text, "%d+"))
        s = format("%02d", s)
        return "[0:"..s.."]"
    end)

    -- {time:mm:ss,event:spellId:count}, {time:ss,event:spellId:count}
    lines = string.gsub(lines, "%{time:%d+:%d+,%a+:%d+:%d+%}", function(text)
        local m, s, id, count = strmatch(text, "(%d+):(%d+),%a+:(%d+):(%d+)")
        m = tonumber(m)
        s = format("%02d", s)

        count = tonumber(count)
        if count == 0 then count = "" end

        local link = GetSpellLink(id) or ""

        return count..link.."["..m..":"..s.."]"
    end)
    lines = string.gsub(lines, "%{time:%d+,%a+:%d+:%d+%}", function(text)
        local s, id, count = strmatch(text, "(%d+),%a+:(%d+):(%d+)")
        s = format("%02d", s)

        count = tonumber(count)
        if count == 0 then count = "" end

        local link = GetSpellLink(id) or ""

        return count..link.."[0:"..s.."]"
    end)


    -- {spell:xxx} -> link
    lines = string.gsub(lines, "%{spell:%d+%}", function(text)
        local id = tonumber(strmatch(text, "%d+"))
        local link = GetSpellLink(id)
        if link then
            return link
        else
            return ""
        end
    end)

    -- convert to string[]
    lines = strsplittable("\n", lines)

    -- test
    -- texplore(lines)
    -- for _, line in pairs(lines) do
    --     print(line)
    -- end
    -- C_Timer.After(1, function()
    --     isWaitForSending = false
    --     MRT_NL_Send:SetEnabled(true)
    -- end)

    for i = 1, #lines + 1 do
        local delay = i * 200 / 1000

        if lines[i] then
            C_Timer.After(delay, function()
                SendChatMessage(lines[i], sendChannel)
            end)
        else
            C_Timer.After(delay, function()
                isWaitForSending = false
                MRT_NL_Send:SetEnabled(true)
            end)
        end
    end
end