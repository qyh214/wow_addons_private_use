local AddonName, D4 = ...
local nam = AddonName
local ico = ""
function D4:SetAddonOutput(name, icon)
    nam = name
    ico = icon
end

function D4:MSG(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFA0A0FF", nam, ico), ...)
end

function D4:INFO(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFFFFF00", nam, ico), ...)
end

function D4:WARN(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFFF0000", nam, ico), ...)
end

function D4:ERR(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFFF0000", nam, ico), ...)
end

function D4:DEB(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFAAAA00", nam, ico), ...)
end
