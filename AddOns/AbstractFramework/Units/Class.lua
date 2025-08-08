---@class AbstractFramework
local AF = _G.AbstractFramework

local classFileToLocalized
if LocalizedClassList then
    classFileToLocalized = LocalizedClassList()
else
    classFileToLocalized = {}
    FillLocalizedClassList(classFileToLocalized)
end

local classLocalizedToFile = AF.SwapKeyValue(classFileToLocalized)

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

function AF.GetClassID(classFileOrLocalized)
    if classLocalizedToFile[classFileOrLocalized] then
        classFileOrLocalized = classLocalizedToFile[classFileOrLocalized]
    end
    return classFileToID[classFileOrLocalized]
end

function AF.GetClassFile(classIDOrLocalized)
    if type(classIDOrLocalized) == "string" then
        return classLocalizedToFile[classIDOrLocalized]
    elseif type(classIDOrLocalized) == "number" then
        return classIDToFile[classIDOrLocalized]
    end
end

function AF.GetLocalizedClassName(classFileOrID)
    if type(classFileOrID) == "string" then
        return classFileToLocalized[classFileOrID] or classFileOrID
    elseif type(classFileOrID) == "number" and classIDToFile[classFileOrID] then
        return classFileToLocalized[classIDToFile[classFileOrID]] or classFileOrID
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