local W, F, L = unpack(select(2, ...))
local CORE = W:GetModule("Core")

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

        if rule.message.keywords then
            for keyword, _ in pairs(rule.message.keywords) do
                if strfind(data.message, keyword) then
                    return true
                end
            end
        end
        return false
    end
end

CORE:RegisterRuleParser("Message", getMessageFilter)
