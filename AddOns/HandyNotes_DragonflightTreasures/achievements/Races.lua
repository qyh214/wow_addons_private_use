local myname, ns = ...

-- TODO: this could be greatly simplified if I properly add multiple-achievement support to core...

local function extend(t1, t2)
    tAppendAll(t1, t2)
    return t1
end
local finalLoot = {
    199669, -- Spiked Crimson Spaulders (all bronze)
    {199688, pet=3279}, -- Bronze Racing Enthusiast (all silver)
    -- Isles Racer title (IsTitleKnown(479) / GetTitleName(478))
}

local Race = ns.Class{
    Initialize=function(self, questname, achievements, currencies)
        self._questname = questname
        self._achievements = achievements
        self._currencies = currencies or {}
    end,
    -- achievement=15941, -- Dragon Racing Completionist: Gold
    atlas="racing", scale=1.2,
    requires=ns.DRAGONRIDING,
    _loot={
        [ns.WAKINGSHORES] = extend({
            {197370, quest=69571}, -- Renewed Proto-Drake: Red Hair
            {197351, quest=69552, note=ADVANCED_LABEL}, -- Renewed Proto-Drake: Gold and Red Armor
        }, finalLoot),
        [ns.OHNAHRANPLAINS] = extend({
            {197599, quest=69803}, -- Windborne Velocidrake: Red Hair
            {197580, quest=69784, note=ADVANCED_LABEL}, -- Windborne Velocidrake: Gold and Red Armor
        }, finalLoot),
        [ns.AZURESPAN] = extend({
            {197118, quest=69319}, -- Highland Drake: Brown Hair
            {197094, quest=69295, note=ADVANCED_LABEL}, -- Highland Drake: Gold and Red Armor
        }, finalLoot),
        [ns.THALDRASZUS] = extend({
            {196987, quest=69187}, -- Cliffside Wylderdrake: Blonde Hair
            {196966, quest=69166, note=ADVANCED_LABEL}, -- Cliffside Wylderdrake: Gold and Orange Armor
        }, finalLoot),
        [ns.FORBIDDENREACH] = {
            -- Forbidden Reach Racer title
        },
    },
    group="races",
    note="Rewards are for zone-wide and continent-wide completion",
    OnTooltipShow=function(self, tooltip)
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
    __get={
        label=function(self)
            self.label = ("{questname:%d}"):format(self._questname)
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
        loot=function(self)
            return self._loot[self._uiMapID]
        end,
    },
}

-- lines with a ? need their currency verified

ns.RegisterPoints(ns.WAKINGSHORES, {
    [63307090] = Race(72434, {15698, 15704}, {2042, 2044}), --Ruby Lifeshrine Loop ? also has 2043 as "medium"
    [47028558] = Race(66721, {15714, 15717}, {2048, 2049}), --Wild Preserve Slalom
    [41956730] = Race(66727, {15726, 15729}, {2052, 2053}), --Emberflow Flight
    [23278430] = Race(66732, {15732, 15735}, {2054, 2055}), --Apex Canopy River Run
    [55424119] = Race(66777, {15738, 15741}, {2056, 2057}), --Uktulut Coaster
    [73203396] = Race(66786, {15744, 15747}, {2058, 2059}), --Wingrest Roundabout
    [62787402] = Race(66710, {15707, 15711}, {2046, 2047}), --Flashfrost Flyover
    [42589446] = Race(66725, {15720, 15723}, {2050, 2051}), --Wild Preserve Circuit
})
ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [63753051] = Race(66835, {15759, 15762}, {2060, 2061}), -- Sundapple Copse Circuit ?
    [86263582] = Race(66877, {15765, 15768}, {2062, 2063}), -- Fen Flythrough ?
    [80897219] = Race(66880, {15771, 15774}, {2064, 2065}), -- Ravine River Run ?
    [25715507] = Race(66885, {15777, 15780}, {2066, 2067}), -- Emerald Garden Ascent ?
    [59933555] = Race(66921, {15784}, {2069}), -- Maruukai Dash ?
    [47497062] = Race(66933, {15787}, {2070}), -- Mirror of the Sky Dash ?
    [43746676] = Race(70710, {16304, 16307}, {2119, 2120}), -- River Rapids Route ?
})
ns.RegisterPoints(ns.AZURESPAN, {
    [47914078] = Race(66946, {15790, 15793}, {2074, 2075}), -- The Azure Span Sprint ?
    [20952262] = Race(67002, {15801, 15804}, {2076, 2077}), -- The Azure Span Slalom ?
    [71292466] = Race(67031, {15820, 15823}, {2078, 2079}), -- The Vakthros Ascent ?
    [16564937] = Race(67296, {15837, 15840}, {2083, 2084}), -- Iskaara Tour ?
    [48493578] = Race(67565, {15843, 15846}, {2085, 2086}), -- Frostland Flyover ?
    [42265674] = Race(67741, {15849, 15852}, {2089, 2090}), -- Archive Ambit ?
})
ns.RegisterPoints(ns.THALDRASZUS, {
    [57777501] = Race(67095, {15829, 15832}, {2080, 2081}), -- The Flowing Forest Flight
    [57236690] = Race(69957, {15857, 15860}, {2092, 2093}), -- Tyrhold Trial
    [37654893] = Race(70051, {15893, 15896}, {2096, 2097}), -- Cliffside Circuit
    [60294159] = Race(70059, {15899, 15902}, {2098, 2099}), -- Academy Ascent
    [39517619] = Race(70157, {15905, 15908}, {2101, 2102}), -- Garden Gallivant
    [58053361] = Race(70161, {15911, 15914}, {2103, 2104}), -- Caverns Criss-Cross
})
ns.RegisterPoints(ns.FORBIDDENREACH, {
    [76136563] = Race(73017, {17216, 17219, 17222}, {2201, 2207, 2213}), -- Stormsunder Crater Circuit
    [31326573] = Race(73020, {17225, 17239, 17242}, {2202, 2208, 2214}), -- Morqut Ascent
    [63095195] = Race(73025, {17245, 17248, 17251}, {2203, 2209, 2215}), -- Aerie Chasm Cruise
    [63658406] = Race(73029, {17254, 17257, 17260}, {2204, 2210, 2216}), -- Southern Reach Route
    [41361455] = Race(73033, {17263, 17266, 17269}, {2205, 2211, 2217}), -- Caldera Coaster
    [49426006] = Race(73061, {17272, 17275, 17278}, {2206, 2212, 2218}), -- Forbidden Reach Rush
})
