---@class AbstractFramework
local AF = _G.AbstractFramework

local localizedClass
if LocalizedClassList then
    localizedClass = LocalizedClassList()
else
    localizedClass = {}
    FillLocalizedClassList(localizedClass)
end

local sortedClasses = {}
local classFileToID = {}
local classIDToFile = {}

do
    -- WARRIOR = 1,
    -- PALADIN = 2,
    -- HUNTER = 3,
    -- ROGUE = 4,
    -- PRIEST = 5,
    -- DEATHKNIGHT = 6,
    -- SHAMAN = 7,
    -- MAGE = 8,
    -- WARLOCK = 9,
    -- MONK = 10,
    -- DRUID = 11,
    -- DEMONHUNTER = 12,
    -- EVOKER = 13,
    --! GetNumClasses returns the highest class ID (NOT IN CLASSIC)
    local highestClassID = GetNumClasses()
    if highestClassID < 11 then highestClassID = 11 end
    for i = 1, highestClassID do
        local classFile, classID = select(2, GetClassInfo(i))
        if classFile and classID == i then
            tinsert(sortedClasses, classFile)
            classFileToID[classFile] = i
            classIDToFile[i] = classFile
        end
    end
    sort(sortedClasses)
end

local GetNumClasses = GetNumClasses

function AF.GetClassID(classFile)
    return classFileToID[classFile]
end

function AF.GetClassFile(classID)
    return classIDToFile[classID]
end

function AF.GetLocalizedClassName(classFileOrID)
    if type(classFileOrID) == "string" then
        return localizedClass[classFileOrID] or classFileOrID
    elseif type(classFileOrID) == "number" and classIDToFile[classFileOrID] then
        return localizedClass[classIDToFile[classFileOrID]] or classFileOrID
    end
    return ""
end

function AF.IterateClasses()
    local i = 0
    return function()
        i = i + 1
        if i <= GetNumClasses() then
            return sortedClasses[i], classFileToID[sortedClasses[i]], i
        end
    end
end

function AF.GetSortedClasses()
    return AF.Copy(sortedClasses)
end