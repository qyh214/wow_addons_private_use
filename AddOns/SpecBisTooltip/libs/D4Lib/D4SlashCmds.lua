local _, D4 = ...
function D4:AddSlash(name, func)
    local cmdName = string.upper(name)
    if not _G["SlashCmdList"] then
        _G["SlashCmdList"] = {}
    end

    if _G["SlashCmdList"][cmdName] then return end
    SlashCmdList[cmdName] = function(msg)
        func(msg)
    end

    local i = 1
    while _G["SLASH_" .. cmdName .. i] ~= nil do
        i = i + 1
    end

    _G["SLASH_" .. cmdName .. i] = "/" .. name
end
