local L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)
local MS = Minesweeperr

MS.optionsTable = { 
    name = "Minesweeperr",
    type = "group",
    handler = MS,
    args = {
        group1 = { 
            type = "group",
            order = 1,
            name = "成就",
            guiInline = true,
            args = {
                mainAchi = {
                    type = "input",
                    name = L["MainAchi"],
                    desc = L["MainAchiDesc"],
                    get = "getMainAchiID",
                    set = "setMainAchiID",
                },
                childAchi1 = {
                    type = "input",
                    name = L["ChildAchi1"],
                    desc = L["ChildAchi1Desc"],
                    get = "getChildAchi1ID",
                    set = "setChildAchi1ID",
                },
                childAchi2 = {
                    type = "input",
                    name = L["ChildAchi2"],
                    desc = L["ChildAchi2Desc"],
                    get = "getChildAchi2ID",
                    set = "setChildAchi2ID",
                },
                childAchi3 = {
                    type = "input",
                    name = L["ChildAchi3"],
                    desc = L["ChildAchi3Desc"],
                    get = "getChildAchi3ID",
                    set = "setChildAchi3ID",
                },
            }
        },
        group2 = { 
            type = "group",
            order = 1,
            name = "小地图",
            guiInline = true,
            args = {
                minimapicon = {
                    type = "toggle",
                    name = L["HideMinimap"],
                    get = "getShowMinimap",
                    set = "setShowMinimap",
                }
            }
        },
        group3 = { 
            type = "group",
            order = 1,
            name = "自动显示快捷评分",
            guiInline = true,
            args = {
                autoShow = {
                    type = "toggle",
                    name = L["AutoShow"],
                    get = "getAutoShow",
                    set = "setAutoShow",
                }
            }
        }
    }
}

function MS:getMainAchiID(info)
    return tostring(self.db.profile.mainAchiID)
end
    
function MS:setMainAchiID(info, newValue)
    local newValue = tonumber(newValue)
    if not newValue then
        newValue = 14145
    end
    self.db.profile.mainAchiID = newValue
end

function MS:getChildAchi1ID(info)
    return tostring(self.db.profile.childAchi1ID)
end
    
function MS:setChildAchi1ID(info, newValue)
    local newValue = tonumber(newValue)
    if not newValue then
        newValue = 13781
    end
    self.db.profile.childAchi1ID = newValue
end

function MS:getChildAchi2ID(info)
    return tostring(self.db.profile.childAchi2ID)
end

function MS:setChildAchi2ID(info, newValue)
    local newValue = tonumber(newValue)
    if not newValue then
        newValue = 13449
    end
    self.db.profile.childAchi2ID = newValue
end

function MS:getChildAchi3ID(info)
    return tostring(self.db.profile.childAchi3ID)
end
    
function MS:setChildAchi3ID(info, newValue)
    local newValue = tonumber(newValue)
    if not newValue then
        newValue = 13080
    end
    self.db.profile.childAchi3ID = newValue
end

function MS:getShowMinimap(info)
    return self.db.profile.minimap.hide
end
    
function MS:setShowMinimap(info, newValue)
    self.db.profile.minimap.hide = newValue
end

function MS:getAutoShow(info)
    return self.db.profile.autoShow
end
    
function MS:setAutoShow(info, newValue)
    self.db.profile.autoShow = newValue
end