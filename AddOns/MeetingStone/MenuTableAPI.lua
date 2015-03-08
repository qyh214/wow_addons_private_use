
BuildEnv(...)

local searchHistoryMenuTable = {}
local createHistoryMenuTable = {}
local searchActivityCodeCache = {}
local createActivityCodeCache = {}
local currentCodeCache

local function MakeCustomActivityMenuTable(activityId, baseFilter, isCreator)
    local customData = ACTIVITY_CUSTOM_DATA[activityId]
    if not customData then
        return
    end

    local fullName, _, categoryId, groupId, _, filters = C_LFGList.GetActivityInfo(activityId)
    local menuTable = {}
    if isCreator then
        local data = {}
        data.text = fullName
        data.fullName = fullName
        data.value = GetActivityCode(activityId, nil, categoryId, groupId)
        data.categoryId = categoryId
        data.groupId = groupId
        data.activityId = activityId
        data.filters = filters
        data.baseFilter = baseFilter

        currentCodeCache[data.value] = data

        tinsert(menuTable, data)
    end

    for _, id in ipairs(customData) do
        local data = {}
        data.text = ACTIVITY_CUSTOM_NAMES[id]
        data.fullName = format('"\001^1^N%d^', id)
        data.categoryId = categoryId
        data.groupId = groupId
        data.activityId = activityId
        data.filters = filters
        data.baseFilter = baseFilter
        data.customId = id
        data.value = GetActivityCode(activityId, id, categoryId, groupId)

        currentCodeCache[data.value] = data

        tinsert(menuTable, data)
    end
    return menuTable
end

local function MakeActivityMenuTable(activityId, baseFilter, isCreator)
    local fullName, _, categoryId, _, _, filters = C_LFGList.GetActivityInfo(activityId)

    local data = {}
    data.text = fullName
    data.fullName = fullName
    data.categoryId = categoryId
    data.groupId = groupId
    data.activityId = activityId
    data.filters = filters
    data.baseFilter = baseFilter
    data.value = GetActivityCode(activityId, nil, categoryId, groupId)

    currentCodeCache[data.value] = data

    local menuTable = MakeCustomActivityMenuTable(activityId, baseFilter, isCreator)
    if menuTable then
        data.menuTable = menuTable
        data.hasArrow = true
        data.notClickable = isCreator
    end
    return data
end

local function MakeGroupMenuTable(categoryId, groupId, baseFilter, isCreator)
    local data = {}
    data.text = C_LFGList.GetActivityGroupInfo(groupId)
    data.fullName = data.text
    data.categoryId = categoryId
    data.groupId = groupId
    data.baseFilter = baseFilter
    data.notClickable = categoryId == 1 or isCreator
    data.value = not data.notClickable and GetActivityCode(nil, nil, categoryId, groupId)

    if data.value then
        currentCodeCache[data.value] = data
    end
    

    local menuTable = {}

    for _, activityId in ipairs(C_LFGList.GetAvailableActivities(categoryId, groupId)) do
        tinsert(menuTable, MakeActivityMenuTable(activityId, baseFilter, isCreator))
    end

    if #menuTable > 0 then
        data.menuTable = menuTable
        data.hasArrow = true
    end
    return data
end

local function MakeVersionMenuTable(categoryId, versionId, baseFilter, isCreator)
    local data = {}
    data.text = _G['EXPANSION_NAME'..versionId]
    data.notClickable = true

    local menuTable = {}

    for _, groupId in ipairs(C_LFGList.GetAvailableActivityGroups(categoryId)) do
        if CATEGORY[versionId].groups[groupId] then
            tinsert(menuTable, MakeGroupMenuTable(categoryId, groupId, baseFilter, isCreator))
        end
    end

    for _, activityId in ipairs(C_LFGList.GetAvailableActivities(categoryId)) do
        if CATEGORY[versionId].activities[activityId] and select(4, C_LFGList.GetActivityInfo(activityId)) == 0 then
            tinsert(menuTable, MakeActivityMenuTable(activityId, baseFilter, isCreator))
        end
    end

    if #menuTable > 0 then
        data.menuTable = menuTable
        data.hasArrow = true
    else
        return
    end
    return data
end

local function MakeCategoryMenuTable(categoryId, baseFilter, isCreator)
    local name, _, autoChoose = C_LFGList.GetCategoryInfo(categoryId)
    local data = {}
    data.text = name
    data.categoryId = categoryId
    data.baseFilter = baseFilter
    data.notClickable = isCreator
    data.value = not data.notClickable and GetActivityCode(nil, nil, categoryId)

    if data.value then
        currentCodeCache[data.value] = data
    end

    local menuTable = {}

    if categoryId == 2 or categoryId == 3 then
        for i = #MAX_PLAYER_LEVEL_TABLE, 0, -1 do
            local versionMenu = MakeVersionMenuTable(categoryId, i, baseFilter, isCreator)
            if versionMenu then
                tinsert(menuTable, versionMenu)
            end
        end
    elseif autoChoose and categoryId ~= 6 then
        return MakeActivityMenuTable(C_LFGList.GetAvailableActivities(categoryId)[1], baseFilter, isCreator)
    else
        for _, groupId in ipairs(C_LFGList.GetAvailableActivityGroups(categoryId)) do
            tinsert(menuTable, MakeGroupMenuTable(categoryId, groupId, baseFilter, isCreator))
        end
        for _, activityId in ipairs(C_LFGList.GetAvailableActivities(categoryId)) do
            if select(4, C_LFGList.GetActivityInfo(activityId)) == 0 then
                tinsert(menuTable, MakeActivityMenuTable(activityId, baseFilter, isCreator))
            end
        end
    end

    if #menuTable > 0 then
        data.menuTable = menuTable
        data.hasArrow = true
    end
    return data
end

local function MakeMenuTable(list, baseFilter, isCreator)
    list = list or {}

    for _, categoryId in ipairs(C_LFGList.GetAvailableCategories(baseFilter)) do
        if categoryId ~= 6 or baseFilter ~= LE_LFG_LIST_FILTER_PVE then
            tinsert(list, MakeCategoryMenuTable(categoryId, baseFilter, isCreator))
        end
    end

    return list
end

function GetActivitesMenuTable(isCreator)
    currentCodeCache = wipe(isCreator and createActivityCodeCache or searchActivityCodeCache)
    local list = {}
    MakeMenuTable(list, LE_LFG_LIST_FILTER_PVE, isCreator)
    MakeMenuTable(list, LE_LFG_LIST_FILTER_PVP, isCreator)

    local menuTable = 

    tinsert(list, 1, {
        text = isCreator and L['|cff00ff00最近创建|r'] or L['|cff00ff00最近搜索|r'],
        notClickable = true,
        hasArrow = true,
        menuTable = RefreshHistoryMenuTable(isCreator),
    })

    return list
end

function RefreshHistoryMenuTable(isCreator)
    local menuTable = wipe(isCreator and createHistoryMenuTable or searchHistoryMenuTable)
    local currentCodeCache = isCreator and createActivityCodeCache or searchActivityCodeCache
    local list = Profile:GetHistoryList(isCreator)

    for _, value in ipairs(list) do
        local data = currentCodeCache[value]
        if data then
            tinsert(menuTable, {
                categoryId = data.categoryId,
                groupId = data.groupId,
                activityId = data.activityId,
                customId = data.customId,
                filters = data.filters,
                baseFilter = data.baseFilter,
                value = data.value,
                text = data.text,
                fullName = data.fullName,
            })
        end
    end

    if #menuTable == 0 then
        tinsert(menuTable, {
            text = L['暂无'],
            disabled = true,
        })
    end

    return menuTable
end
