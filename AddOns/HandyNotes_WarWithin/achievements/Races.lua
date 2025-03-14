local myname, ns = ...
local _, myfullname = C_AddOns.GetAddOnInfo(myname)

local races = {}

EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
    if C_AddOns.IsAddOnLoaded("ContinentalRacing") then return end
    local showing
    local function ShowTooltipForRace(race, name, description)
        local tooltip = GetAppropriateTooltip()
        tooltip:SetOwner(WorldMapFrame, "ANCHOR_CURSOR")
        GameTooltip_SetTitle(tooltip, name)
        if description then
            GameTooltip_AddNormalLine(tooltip, description)
        end
        race:OnTooltipShow(tooltip)
        tooltip:AddDoubleLine(" ", myfullname:gsub("HandyNotes: ", ""), 0, 1, 1, 0, 1, 1)
        tooltip:Show()
        showing = tooltip
    end
    WorldMapFrame:RegisterCallback("SetAreaLabel", function(_, labelType, name, description)
        if labelType ~= MAP_AREA_LABEL_TYPE.POI then return end
        -- Sadly, there's not a convenient way I could see to just get the areaPoiID or the areaPoiInfo from this point
        -- As such...
        if races[name] then
            return ShowTooltipForRace(races[name], name, description)
        end
        for _, race in ipairs(races) do
            local rname = C_QuestLog.GetTitleForQuestID(race._questid)
            if rname then
                races[rname] = race
            end
            if name == rname then
                return ShowTooltipForRace(race, name, description)
            end
        end
    end)
    WorldMapFrame:RegisterCallback("ClearAreaLabel", function(_, labelType)
        if showing then
            showing:Hide()
            showing = nil
        end
    end)
end)

-- TODO: this could be greatly simplified if I properly add multiple-achievement support to core...

-- Currencies are all available from https://wago.tools/db2/CurrencyTypes
-- They're named in the format `11 Z[zone-number] R[race-number]`

local Race = function(questid, achievements, currencies)
    local race = ns.Getterize{
        _questid = questid,
        _achievements = achievements,
        _currencies = currencies or {},
        -- achievement=40354, -- Khaz Algar Completionist: Gold
        atlas="racing", scale=1.2,
        group="races",
        __get={
            label=function(self)
                self.label = ("{questname:%d}"):format(self._questid)
                return self.label
            end,
            found=function(self)
                local found = {}
                for _, aid in ipairs(self._achievements) do
                    table.insert(found, ns.conditions.Achievement(aid))
                end
                self.found = found
                return found
            end,
            parent=function(self)
                return self._uiMapID == ns.DORNOGAL or self._uiMapID == ns.CITYOFTHREADS
            end,
        },
        OnTooltipShow = function(self, tooltip)
            for i, achievementid in pairs(self._achievements) do
                local _, name, _, complete = GetAchievementInfo(achievementid)
                local currencyInfo = self._currencies[i] and C_CurrencyInfo.GetCurrencyInfo(self._currencies[i])
                tooltip:AddDoubleLine(
                    name or achievementid,
                    currencyInfo and ("%.3f s"):format(currencyInfo.quantity / 1000) or "? s",
                    complete and 0 or 1, complete and 1 or 0, 0,
                    complete and 0 or 1, complete and 1 or 0, 0
                )
            end
        end,
    }
    table.insert(races, race)
    return race
end

-- lines with a ? need their currency verified

ns.RegisterPoints(ns.DORNOGAL, {
    [43471165] = Race(80219, {20257, 20260, 20263}, {2923, 2929, 2935}), -- Dornogal Drift
})
ns.RegisterPoints(ns.ISLEOFDORN, {
    -- quest, {achievements}, {currencies}
    [38574346] = Race(80220, {20266, 20269, 20272}, {2924, 2930, 2936}), -- Storm's Watch Survey
    [53486422] = Race(80221, {20275, 20278, 20281}, {2925, 2931, 2937}), -- Basin Bypass
    [62164601] = Race(80222, {20284, 20287, 20290}, {2926, 2932, 2938}), -- The Wold Ways
    [58332485] = Race(80223, {20293, 20296, 20299}, {2927, 2933, 2938}), -- Thunderhead Trail
    [32937483] = Race(80224, {20302, 20305, 20308}, {2928, 2934, 2940}), -- Orecreg's Doglegs
})
ns.RegisterPoints(ns.RINGINGDEEPS, {
    -- quest, {achievements}, {currencies}
    [38261131] = Race(80237, {20311, 20314, 20317}, {2941, 2947, 2953}), -- Earthenworks Weave
    [39542744] = Race(80238, {20320, 20323, 20326}, {2942, 2948, 2954}), -- Ringing Deeps Ramble
    [63593479] = Race(80239, {20329, 20332, 20335}, {2943, 2949, 2955}), -- Chittering Concourse
    [49134686] = Race(80240, {20338, 20341, 20344}, {2944, 2950, 2956}), -- Cataract River Cruise
    [62406868] = Race(80242, {20347, 20350, 20353}, {2945, 2951, 2957}), -- Taelloch Twist
    [59517513] = Race(80243, {20356, 20359, 20362}, {2946, 2952, 2958}), -- Opportunity Point Amble
})
ns.RegisterPoints(ns.HALLOWFALL, {
    -- quest, {achievements}, {currencies}
    [72783842] = Race(80256, {20365, 20368, 20371}, {2959, 2965, 2971}), -- Dunelle's Detour
    [59196894] = Race(80257, {20374, 20377, 20380}, {2960, 2966, 2972}), -- Tenir's Traversal
    [41436725] = Race(80258, {20383, 20386, 20389}, {2961, 2967, 2973}), -- Light's Redoubt Descent
    [60412602] = Race(80259, {20392, 20395, 20398}, {2962, 2968, 2974}), -- Stillstone Slalom
    [38976136] = Race(80260, {20401, 20404, 20407}, {2963, 2969, 2975}), -- Mereldar Meander
    [54131740] = Race(80261, {20410, 20413, 20416}, {2964, 2670, 2976}), -- Velhan's Venture
})
ns.RegisterPoints(ns.CITYOFTHREADS, {
    [27010793] = Race(80277, {20421, 20424, 20427}, {2977, 2983, 2989}), -- City of Threads Twist
})
ns.RegisterPoints(ns.AZJKAHET, {
    -- quest, {achievements}, {currencies}
    [77927964] = Race(80278, {20431, 20434, 20437}, {2978, 2984, 2990}), -- Maddening Deep Dip
    [52943618] = Race(80279, {20441, 20444, 20447}, {2979, 2985, 2991}), -- The Weaver's Wing
    [71343636] = Race(80280, {20450, 20453, 20456}, {2980, 2986, 2992}), -- Rak-Ahat Rush
    [23814835] = Race(80281, {20459, 20462, 20465}, {2981, 2987, 2993}), -- Pit Plunge
    [40183220] = Race(80282, {20468, 20471, 20474}, {2982, 2988, 2994}), -- Siegehold Scuttle
})
ns.RegisterPoints(ns.UNDERMINE, {
    -- quest, {achievements}, {currencies}
    -- Skyrocketing
    [39032869] = Race(85071, {40914, 40917}, {3119, 3121}), -- Skyrocketing Sprint
    [33787623] = Race(85097, {40920, 40923}, {3122, 3123}), -- The Heaps Leap
    [39221137] = Race(85099, {40926, 40929}, {3124, 3125}), -- Scrapshop Shot
    [25504213] = Race(85101, {40932, 40935}, {3126, 3127}), -- Rags to Riches Rush
    -- Breaknecking (hide before No More Walking Here (87581?))
    [26005300] = Race(85900, {41059, 41062}, {3181, 3182}), -- Breakneck Bolt
    [43507800] = Race(85902, {41065, 41068}, {3183, 3184}), -- Junkyard Jaunt
    [39505400] = Race(85904, {41071, 41074}, {3185, 3186}), -- Casino Cruise
    [47504400] = Race(85906, {41077, 41080}, {3187, 3188}), -- Sandy Scuttle
})
