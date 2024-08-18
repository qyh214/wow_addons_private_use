local myname, ns = ...

-- TODO: this could be greatly simplified if I properly add multiple-achievement support to core...

-- local function extend(t1, t2)
--     tAppendAll(t1, t2)
--     return t1
-- end
-- local finalLoot = {
--     199669, -- Spiked Crimson Spaulders (all bronze)
--     {199688, pet=3279}, -- Bronze Racing Enthusiast (all silver)
--     -- Isles Racer title (IsTitleKnown(479) / GetTitleName(478))
-- }

local Race = ns.Class{
    Initialize=function(self, questid, achievements, currencies)
        self._questid = questid
        self._achievements = achievements
        self._currencies = currencies or {}
    end,
    -- achievement=40354, -- Khaz Algar Completionist: Gold
    atlas="racing", scale=1.2,
    _loot={
        --[[
        [ns.WAKINGSHORES] = extend({
            {197370, quest=69571}, -- Renewed Proto-Drake: Red Hair
            {197351, quest=69552, note=ADVANCED_LABEL}, -- Renewed Proto-Drake: Gold and Red Armor
        }, finalLoot),
        --]]
    },
    group="races",
    -- note="Rewards are for zone-wide and continent-wide completion",
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
        loot=function(self)
            return self._loot[self._uiMapID]
        end,
    },
}

-- lines with a ? need their currency verified

ns.RegisterPoints(ns.ISLEOFDORN, {
    -- quest, {achievements}, {currencies}
    -- [32937483] = Race(, {}, {}), --
    -- [62164601] = Race(, {}, {}), -- The Wold Ways
    -- [53486422] = Race(, {}, {}), -- Basin Bypass
    -- [38574346] = Race(, {}, {}), -- Storm's Watch Survey
    -- [] = Race(, {}, {}), --
    -- [] = Race(, {}, {}), --
})
ns.RegisterPoints(ns.RINGINGDEEPS, {
    -- quest, {achievements}, {currencies}
    -- [42232744] = Race(, {}, {}), -- Ringing Deeps Ramble
    -- [52474686] = Race(, {}, {}), -- Cataract River Cruise
    -- [40861131] = Race(, {}, {}), -- Earthenworks Weave
    -- [63557513] = Race(, {}, {}), -- Opportunity Point Amble
    -- [] = Race(, {}, {}), --
    -- [] = Race(, {}, {}), --
})
ns.RegisterPoints(ns.HALLOWFALL, {
    -- quest, {achievements}, {currencies}
    -- [72783842] = Race(, {}, {}), -- Dunelle's Detour
    -- [38976136] = Race(, {}, {}), -- Mereldar Meander
    -- [41436725] = Race(, {}, {}), -- Light's Redoubt Descent
    -- [59196894] = Race(, {}, {}), -- Tenir's Traversal
    -- [] = Race(, {}, {}), --
    -- [] = Race(, {}, {}), --
})
ns.RegisterPoints(ns.AZJKAHET, {
    -- quest, {achievements}, {currencies}
    -- [71343636] = Race(, {}, {}), -- Rak-Ahat Rush
    -- [23814835] = Race(, {}, {}), -- Pit Plunge
    -- [52943618] = Race(, {}, {}), -- The Weaver's Wing
    -- [40183220] = Race(, {}, {}), -- Siegehold Scuttle
    -- [] = Race(, {}, {}), --
})
ns.RegisterPoints(ns.CITYOFTHREADS, {
    -- [27010793] = Race(, {}, {}), -- City of Threads Twist
})
