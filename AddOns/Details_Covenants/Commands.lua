local _, dc = ...

local coloredName = "|CFFe5a472Details_Covenants|r"
SLASH_DETAILSCOVENANT1, SLASH_DETAILSCOVENANT2 = '/dc', '/dcovenants';
local function commandLineHandler(msg, editBox)
    if string.match(msg, "icon ") then
        local _, numberValue = dc.utils:splitCommand(msg)
        if dc.utils:isNumeric(numberValue) then 
            local size = tonumber(numberValue)
            if size > 10 and size < 48 then 
                DCovenant["iconSize"] = math.floor(size / 2) * 2
                print(coloredName.." icon size has been set to: |CFF9fd78a"..DCovenant["iconSize"].."|r")
            else
                print("|CFFd77c7aError:|r Please enter value between |CFF9fd78a10|r and |CFF9fd78a48|r") 
            end 
        else
            print("|CFFd77c7aError:|r Please enter value between |CFF9fd78a10|r and |CFF9fd78a48|r") 
        end 
    elseif msg == "chat on" then
        DCovenantLog = true
        print(coloredName.." chat logs is |CFF9fd78aon|r")
    elseif msg == "chat off" then
        DCovenantLog = false
        print(coloredName.." chat logs is |CFFd77c7aoff|r")
    elseif msg == "log all" then
        dc.oribos:log()
    elseif msg == "log group" or msg == "log" then
        dc.oribos:logParty()
    elseif string.match(msg, "align") then
        local _, alignValue = dc.utils:splitCommand(msg)
        if alignValue == "left" or alignValue == "right" then
            DCovenant["iconAlign"] = alignValue
            print(coloredName.." align of covenant icon has been set to: |CFF9fd78a"..DCovenant["iconAlign"].."|r")
        else 
            print("|CFFd77c7aError:|r Please enter one of value |CFF9fd78aleft|r or |CFF9fd78aright|r") 
        end
    else 
        local coloredCommand = "  |CFFc0a7c7/dc|r |CFFf3ce87"
        local currentChatOption = ""
        local currentAlignOption = DCovenant["iconAlign"]

        if not currentAlignOption then
            currentAlignOption = "left"
        end  

        if DCovenantLog == true then
            currentChatOption = "|CFF9fd78aon|r"
        else
            currentChatOption = "|CFFd77c7aoff|r"
        end
        print(coloredName.." usage info:\n"..coloredCommand.."icon [number]:|r change size of icons (currently: |CFF9fd78a"..DCovenant["iconSize"].."|r)\n"..coloredCommand.."chat [on | off]:|r log a new character's covenant to chat (currently: "..currentChatOption..")\n"..coloredCommand.."log [all | group]:|r prints all collected data or just for your party/raid".."\n"..coloredCommand.."align [left | right]:|r change align of covenant icon (currently: |CFF9fd78a"..currentAlignOption.."|r)")
    end
end
SlashCmdList["DETAILSCOVENANT"] = commandLineHandler;
