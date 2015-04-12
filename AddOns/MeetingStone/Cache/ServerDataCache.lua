
BuildEnv(...)

local ServerDataCache = Addon:NewModule('ServerDataCache', 'AceEvent-3.0')

function ServerDataCache:OnInitialize()
    local AnnData = DataCache:NewObject('AnnData') do
        AnnData:SetCallback('OnCacheChanged', AnnData.SetData)
    end

    local MallData = DataCache:NewObject('MallData') do
        MallData:SetCallback('OnCacheChanged', function(MallData, cache)
            self:FormatMallData(MallData, cache)
        end)
        MallData:SetCallback('OnDataChanged', function(MallData, data)
            self:SendMessage('MEETINGSTONE_MALL_LIST_UPDATED', data, MallData:IsNew())
            MallData:SetIsNew(false)
        end)
    end

    local ActivitiesData = DataCache:NewObject('ActivitiesData') do
        ActivitiesData:SetCallback('OnCacheChanged', function(ActivitiesData, ...)
            self:FormatActivitiesData(ActivitiesData, ...)
        end)
        ActivitiesData:SetCallback('OnDataChanged', function(ActivitiesData, data)
            self:SendMessage('MEETINGSTONE_ACTIVITIES_DATA_UPDATED', data)
        end)
    end
end

local PLAYER_FACTION = UnitFactionGroup('player') == 'Alliance' and 1 or 2
local function FormatMallGood(encode)
    local id, priceInfo, item, icon, faction, tip, startTime = strsplit(';', encode)
    local faction = tonumber(faction)
    if faction and faction ~= PLAYER_FACTION then
        return
    end

    local price, originalPrice = strsplit(',', priceInfo)
    local itemId = tonumber(item)
    local model = icon and tonumber(icon)
    local icon = not model and icon and icon:match('^!(.+)$')
    local tip = tip and tip ~= '' and {strsplit('@', tip)}
    local startTime = tonumber(startTime)
    local name = not itemId and item
    local priceType, price = price:match('^(!?)(%d+)$')

    return {
        id = tonumber(id),
        price = tonumber(price),
        originalPrice = tonumber(originalPrice),
        startTime = tonumber(startTime),
        name = name,
        itemId = itemId,
        model = model,
        icon = icon,
        tip = tip,
        priceType = priceType == '!' and 1 or 2
    }
end

local function UnpackGoodList(encode)
    local list = {}
    for item in encode:gmatch('[^#]+') do
        local good = FormatMallGood(item)
        if good then
            tinsert(list, good)
        end
    end
    return list
end

function ServerDataCache:FormatMallData(MallData, cache)
    if MallData:GetData() and not MallData:IsNew() then
        return
    end

    local productList = {}

    for k, v in pairs(cache) do
        local categoryText, categoryOrder, new = ('#'):split(k)
        categoryOrder = tonumber(categoryOrder)

        local goods = {('#'):split(v)}

        local category = {
            text = categoryText,
            coord = MALL_CATEGORY_ICON_LIST[categoryOrder % 7],
            new = new,
            item = {},
        }

        for i, item in ipairs(goods) do
            local good = FormatMallGood(item)
            if good then
                tinsert(category.item, good)
            end
        end

        productList[categoryOrder] = category
    end

    MallData:SetData(productList)
end

function ServerDataCache:FormatActivitiesData(ActivitiesData, title, target, summary, url, misc, mall, lotteryItem, lottery)
    local data = {}
    local tabs, signup, gift, bg = strsplit(';', misc)

    tabs = tonumber(tabs)
    signup = tonumber(signup)

    data.tabMall = bit.band(tabs, 1) > 0
    data.tabLottery = bit.band(tabs, 2) > 0
    data.signUpLeader = bit.band(signup, 1) > 0
    data.signUpMember = bit.band(signup, 2) > 0
    data.gift = tonumber(gift)
    data.background = bg
    data.title = title
    data.target = target
    data.url = url
    data.summary = FormatActivitiesSummaryUrl(summary, url):gsub('^', '<html><body><p>　　'):gsub('$', '</p></body></html>'):gsub('[\r\n]+', '</p><p>　　')
    data.mallList = UnpackGoodList(mall)
    data.mallData = {} do
        for _, v in pairs(data.mallList) do
            data.mallData[v.id] = v
        end
    end
    data.lotteryList, data.lotteryData = {}, {} do
        local lottery = UnpackGoodList(lottery)
        local count = #lottery
        for item in LOTTERY_ORDER:sub((count-2)*MAX_LOTTERY_COUNT+1,(count-1)*MAX_LOTTERY_COUNT):gmatch('.') do
            tinsert(data.lotteryList, lottery[tonumber(item)+1])
        end
        for _, v in ipairs(lottery) do
            data.lotteryData[v.id] = v
        end
    end
    data.lotteryId, data.lotteryPrice = nil, nil do
        local item = FormatMallGood(lotteryItem)
        data.lotteryId = item.id
        data.lotteryPrice = item.price
    end
    ActivitiesData:SetData(data)
end
