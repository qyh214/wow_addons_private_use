local W, F, L = unpack(select(2, ...))
local CORE = W:GetModule("Core")

local gsub = gsub
local next = next
local pairs = pairs
local strfind = strfind
local strsplit = strsplit

local function getMessageFilter(rule)
    if not rule.message or not rule.message.enabled then
        return nil
    end

    if not rule.message.keywords or not next(rule.message.keywords) then
        return nil
    end

    return function(data)
        if not data.message then
            return false
        end

        local playerName = strsplit("-", data.sender)

        if rule.message.keywords then
            for keyword, _ in pairs(rule.message.keywords) do
                local kw = gsub(keyword, "%%playerName%%", playerName)
                if strfind(data.message, kw) or strfind(gsub(data.message, "%s", ""), kw) then
                    return true
                end
            end
        end
        return false
    end
end

CORE:RegisterRuleParser("Message", getMessageFilter)
