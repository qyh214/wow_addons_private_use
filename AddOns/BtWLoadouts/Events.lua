local ADDON_NAME, Internal = ...;
local L = Internal.L;

local HelpTipBox_Anchor = Internal.HelpTipBox_Anchor;
local HelpTipBox_SetText = Internal.HelpTipBox_SetText;

local format = string.format
local sort = table.sort

local GetCharacterSlug = Internal.GetCharacterSlug

-- A map from the equipment manager ids to our sets
local equipmentSetMap = {};
-- A map from the talent tree ids to our sets
local dfTalentTreeSetMap = {};

local frame = CreateFrame("Frame");
frame:SetScript("OnEvent", function (self, event, ...)
    self[event](self, ...);
end);
function frame:ADDON_LOADED(...)
    if ... == ADDON_NAME then
        BtWLoadoutsSettings = BtWLoadoutsSettings or {}
        Internal.Settings(BtWLoadoutsSettings)

        Internal.UpdateClassInfo()
        
        if Internal.Settings.sortClassesByName then
            Internal.SortClassesByName()
        end

        BtWLoadoutsSets = setmetatable(BtWLoadoutsSets or {
            profiles = {},
            talents = {},
            dftalents = {},
            pvptalents = {},
            essences = {},
            equipment = {},
            actionbars = {},
            conditions = {},
        }, {
            __index = function (self, key)
                local result = {}
                self[key] = result
                return result
            end
        })
        BtWLoadoutsCollapsed = setmetatable(BtWLoadoutsCollapsed or {
            profiles = {},
            talents = {},
            dftalents = {},
            pvptalents = {},
            essences = {},
            equipment = {},
            actionbars = {},
            conditions = {},
        }, {
            __index = function (self, key)
                local result = {}
                self[key] = result
                return result
            end
        })
        BtWLoadoutsCategories = setmetatable(BtWLoadoutsCategories or {
            profiles = {"spec"},
            talents = {"spec"},
            dftalents = {"spec"},
            pvptalents = {"spec"},
            essences = {"role"},
            equipment = {"character"},
            soulbinds = {"covenant"},
            actionbars = {},
            conditions = {},
        }, {
            __index = function (self, key)
                local result = {}
                self[key] = result
                return result
            end
        })
        BtWLoadoutsFilters = setmetatable(BtWLoadoutsFilters or {
            profiles = {},
            talents = {},
            dftalents = {},
            pvptalents = {},
            essences = {},
            equipment = {},
            actionbars = {},
            conditions = {},
        }, {
            __index = function (self, key)
                local result = {}
                self[key] = result
                return result
            end
        })

        BtWLoadoutsSpecInfo = BtWLoadoutsSpecInfo or {}
        BtWLoadoutsRoleInfo = BtWLoadoutsRoleInfo or {}
        BtWLoadoutsEssenceInfo = BtWLoadoutsEssenceInfo or {}
        BtWLoadoutsCharacterInfo = BtWLoadoutsCharacterInfo or {}
        BtWLoadoutsHelpTipFlags = BtWLoadoutsHelpTipFlags or {}
        BtWLoadoutsTraitsInfo = BtWLoadoutsTraitsInfo or {}
        BtWLoadoutsTraitsInfo.trees = BtWLoadoutsTraitsInfo.trees or {}
        BtWLoadoutsTraitsInfo.nodes = BtWLoadoutsTraitsInfo.nodes or {}

        -- Clean up filters
        for _,sets in pairs(BtWLoadoutsSets) do
            for setID,set in pairs(sets) do
                if type(set) == "table" then
                    set.setID = setID;
                    set.useCount = 0;

                    -- Refresh filtering
                    set.filters = set.filters or {}
                    if set.character and type(set.character) == "string" then
                        set.filters.character = set.character
                        local characterInfo = Internal.GetCharacterInfo(set.character)
                        if characterInfo then
                            set.filters.class = characterInfo.class
                        end
                    end
                    if set.specID then
                        set.filters.spec = set.specID
                        set.filters.role, set.filters.class = select(5, GetSpecializationInfoByID(set.specID))

                        if not set.filters.character then
                            local characters = {}
                            local class = set.filters.class
                            for _,character in Internal.CharacterIterator() do
                                if class == Internal.GetCharacterInfo(character).class then
                                    characters[#characters+1] = character
                                end
                            end
                            set.filters.character = characters
                        end
                    end
                    if set.role then
                        set.filters.role = set.role

                        if not set.filters.character then
                            local characters = {}
                            local role = set.filters.role
                            for _,character in Internal.CharacterIterator() do
                                if Internal.IsClassRoleValid(Internal.GetCharacterInfo(character).class, role) then
                                    characters[#characters+1] = character
                                end
                            end
                            set.filters.character = characters
                        end
                    end
                end
            end
        end
        -- Update talent sets for spec changes
        if BtWLoadoutsSets.talents.version ~= Internal.GetSpecInfoVersion() then
            local changed = false
            local FixTalentSet = Internal.FixTalentSet
            for _,set in pairs(BtWLoadoutsSets.talents) do
                if type(set) == "table" then
                    local setChanged = FixTalentSet(set)
                    changed = setChanged or changed
                end
            end

            BtWLoadoutsSets.talents.version = Internal.GetSpecInfoVersion()
            if changed then
                print(L["BtWLoadouts: Some talent sets were updated to account for talent changes"])
            end
        end
        if BtWLoadoutsSets.pvptalents.version ~= Internal.GetSpecInfoVersion() then
            local changed = false
            local FixSet = Internal.FixPvPTalentSet
            for _,set in pairs(BtWLoadoutsSets.pvptalents) do
                if type(set) == "table" then
                    local setChanged = FixSet(set)
                    changed = setChanged or changed
                end
            end

            BtWLoadoutsSets.pvptalents.version = Internal.GetSpecInfoVersion()
            if changed then
                print(L["BtWLoadouts: Some pvp talent sets were updated to account for talent changes"])
            end
        end
        if BtWLoadoutsSpecInfo.version ~= Internal.GetSpecInfoVersion() then
--[==[@debug@
            print(L["BtWLoadouts: Clearing spec info cache as internal spec data been updated"])
--@end-debug@]==]
            BtWLoadoutsSpecInfo = {}
            BtWLoadoutsSpecInfo.version = Internal.GetSpecInfoVersion()
        end
        if BtWLoadoutsTraitsInfo.version ~= Internal.GetTraitInfoVersion() then
--[==[@debug@
            print(L["BtWLoadouts: Clearing trait info cache as internal trait data been updated"])
--@end-debug@]==]
            BtWLoadoutsTraitsInfo = {trees = {}, nodes = {}}
            BtWLoadoutsTraitsInfo.version = Internal.GetTraitInfoVersion()
        end
        -- Make sure equipment sets have all the tables needed
        for setID,set in pairs(BtWLoadoutsSets.equipment) do
            if type(set) == "table" then
                -- Fix an issue where equipment sets were created with character data flipped
                -- and caused duplicated data from the in game equipment sets
                if not Internal.GetCharacterInfo(set.character) then
                    BtWLoadoutsSets.equipment[setID] = nil
                else
                    set.extras = set.extras or {};
                    set.locations = set.locations or {};
                    set.data = set.data or {};
                end
            end
        end
        -- Update loadouts, converting to version 2 and fixing use counts
        for setID,set in pairs(BtWLoadoutsSets.profiles) do
            if type(set) == "table" then
                -- Convert from version 1 to version 2 loadouts
                if set.version == nil then
                    set.talents = {set.talentSet}
                    set.talentSet = nil

                    set.pvptalents = {set.pvpTalentSet}
                    set.pvpTalentSet = nil

                    set.essences = {set.essencesSet}
                    set.essencesSet = nil

                    set.equipment = {set.equipmentSet}
                    set.equipmentSet = nil

                    set.actionbars = {set.actionBarSet}
                    set.actionBarSet = nil

                    set.version = 2
                end

                for _,segment in Internal.EnumerateLoadoutSegments() do
                    local id = segment.id
                    set[id] = set[id] or {}
                    for i=#set[id],1,-1 do
                        local subsetID = set[id][i]
                        if BtWLoadoutsSets[id][subsetID] then
                            BtWLoadoutsSets[id][subsetID].useCount = BtWLoadoutsSets[id][subsetID].useCount + 1;
                        elseif subsetID > 0 then -- Negative numbers are virtual sets, like soulbinds
                            table.remove(set[id], i)
                        end
                    end
                end
            end
        end
        -- Update condition use counts
        for setID,set in pairs(BtWLoadoutsSets.conditions) do
            if type(set) == "table" then
                if set.profileSet and BtWLoadoutsSets.profiles[set.profileSet] then
                    BtWLoadoutsSets.profiles[set.profileSet].useCount = BtWLoadoutsSets.profiles[set.profileSet].useCount + 1;
                end

                Internal.UpdateConditionFilters(set)
            end
        end

        if not BtWLoadoutsHelpTipFlags["MINIMAP_ICON"] then
            BtWLoadoutsMinimapButton.FirstTimeAnim:Play();
        end

        Internal.SetLoadoutSegmentEnabled("essences", Internal.Settings.essences)
        BtWLoadoutsFrame.Essences:SetEnabled(Internal.Settings.essences)
        
        Internal.SetLoadoutSegmentEnabled("soulbinds", Internal.Settings.soulbinds)
        BtWLoadoutsFrame.Soulbinds:SetEnabled(Internal.Settings.soulbinds)
    end
end
function frame:PLAYER_LOGIN(...)
    Internal.CreateLauncher();
    Internal.CreateLauncherMinimapIcon();

    frame:RegisterEvent("PLAYER_TALENT_UPDATE");

    if (BtWLoadoutsSets.actionbars.version or 0) < 1 then
        for _,set in pairs(BtWLoadoutsSets.actionbars) do
            if type(set) == "table" then
                for slot=121,181 do
                    set.ignored[slot] = true
                end
            end
        end
        BtWLoadoutsSets.actionbars.version = 1
    end

    for _,set in pairs(BtWLoadoutsSets.conditions) do
        if type(set) == "table" then
            if set.difficultyID ~= 8 then
                set.map.affixesID = nil
                set.map.affixID1 = nil
                set.map.affixID2 = nil
                set.map.affixID3 = nil
                set.map.affixID4 = nil
            end
            -- Fix to remove the season affix from condition mapping
            if set.map.affixesID ~= nil then
                if set.affixesID then
                    local affixID1, affixID2, affixID3, affixID4 = Internal.GetAffixesForID(set.affixesID)

                    set.map.affixID1 = (affixID1 ~= 0 and affixID1 or nil)
                    set.map.affixID2 = (affixID2 ~= 0 and affixID2 or nil)
                    set.map.affixID3 = (affixID3 ~= 0 and affixID3 or nil)
                    set.map.affixID4 = (affixID4 ~= 0 and affixID4 or nil)
                end

                set.map.affixesID = nil
            end

            -- Fixes an issue where conditions could be left with a missing loadout
            if set.profileSet and Internal.GetProfile(set.profileSet) == nil then
                set.profileSet = nil
            end

			if Internal.IsConditionEnabled(set) then
                Internal.AddConditionToMap(set);
            end
        end
    end

    local activeConfigID = C_ClassTalents.GetActiveConfigID();
    if next(dfTalentTreeSetMap) == nil then
        local character = GetCharacterSlug();
        for setID,set in pairs(BtWLoadoutsSets.dftalents) do
            if type(set) == "table" then
                if set.character and set.configID then
                    local info = Internal.GetCharacterInfo(set.character)
                    if not info then -- Clear character specific data if the character is unknown
                        set.character = nil
                        set.configID = nil
                    end
                end
                if set.character == character and set.configID ~= nil then
                    dfTalentTreeSetMap[set.configID] = set
                end
            end
        end
    end

    local specID = GetSpecializationInfo(GetSpecialization());
    local tree = Internal.GetTreeInfoBySpecID(specID);
    local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID);
    for _,configID in ipairs(configIDs) do
        self:TRAIT_CONFIG_UPDATED(configID);
    end

    -- Delete any trait trees that arent for the current spec but think they are
    for configID,set in pairs(dfTalentTreeSetMap) do
        local configInfo = C_Traits.GetConfigInfo(configID);
        if activeConfigID == configID or not configInfo or configInfo.treeIDs[1] ~= tree.ID or configInfo.type ~= 1 or (not tContains(configIDs, configID) and set.specID == specID) then
            self:TRAIT_CONFIG_DELETED(configID);
        end
    end
end
local firstLogin = true
function frame:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
    -- The info we want isnt available here unless we are reloading
    if firstLogin and isReloadingUi then
        self:UnregisterEvent("CONSOLE_MESSAGE")

        Internal.BuildEquipmentMap()
        self:EQUIPMENT_SETS_CHANGED()

        firstLogin = nil
    end
    for specIndex=1,GetNumSpecializations() do
        local specID = GetSpecializationInfo(specIndex);
        local spec = BtWLoadoutsSpecInfo[specID] or {talents = {}};
        spec.talents = spec.talents or {};
        local talents = spec.talents;
        for tier=1,MAX_TALENT_TIERS do
            local tierItems = talents[tier] or {};

            for column=1,3 do
                local talentID = GetTalentInfoBySpecialization(specIndex, tier, column);
                tierItems[column] = talentID;
            end

            talents[tier] = tierItems;
        end

        BtWLoadoutsSpecInfo[specID] = spec;
    end

    do
        local specID = GetSpecializationInfo(GetSpecialization());
        local spec = BtWLoadoutsSpecInfo[specID] or {};

        spec.pvptalentslots = spec.pvptalentslots or {};
        wipe(spec.pvptalentslots);
        do
            local index = 1
            local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(index)
            while slotInfo do
                spec.pvptalentslots[index] = slotInfo

                index = index + 1
                slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(index)
            end
        end

        BtWLoadoutsSpecInfo[specID] = spec;
    end

    do
        local essences = C_AzeriteEssence.GetEssences();
        if essences ~= nil then
            local roleID = select(5, GetSpecializationInfo(GetSpecialization()));
            local role = BtWLoadoutsRoleInfo[roleID] or {};

            role.essences = role.essences or {};
            wipe(role.essences);

            sort(essences, function (a,b)
                return a.name < b.name;
            end);
            for _,essence in ipairs(essences) do
                if essence.valid then
                    role.essences[#role.essences+1] = essence.ID;
                end

                local essenceInfo = BtWLoadoutsEssenceInfo[essence.ID] or {};
                wipe(essenceInfo);
                essenceInfo.ID = essence.ID;
                essenceInfo.name = essence.name;
                essenceInfo.icon = essence.icon;

                BtWLoadoutsEssenceInfo[essence.ID] = essenceInfo;
            end

            BtWLoadoutsRoleInfo[roleID] = role;
        end
    end

    Internal.UpdateTraitInfoFromPlayer();
    Internal.UpdatePlayerInfo();
    Internal.UpdateAreaMap();

    -- Run conditions for instance info
    do
        Internal.UpdateConditionsForInstance();
		local bossID = Internal.UpdateConditionsForBoss();
        Internal.UpdateConditionsForAffixes();
        -- Boss is unavailable so dont trigger conditions
        if bossID and not Internal.BossAvailable(bossID) then
            return
        end
        Internal.TriggerConditions();
    end

    Internal.UpdateLauncher(Internal.GetActiveProfiles());
end
function frame:CONSOLE_MESSAGE()
    -- PLAYER_LOGIN and PLAYER_ENTERING_WORLD are to early, some info isnt available yet during first login
    if firstLogin then
        self:UnregisterEvent("CONSOLE_MESSAGE")

        Internal.BuildEquipmentMap()
        self:EQUIPMENT_SETS_CHANGED()

        firstLogin = nil
    end
end
function frame:EQUIPMENT_SETS_CHANGED(...)
    -- Update our saved equipment sets to match the built in equipment sets

    if next(equipmentSetMap) == nil then
        local name, realm = UnitFullName("player");
        local character = GetCharacterSlug();
        for setID,set in pairs(BtWLoadoutsSets.equipment) do
            if type(set) == "table" then
                if set.character == character and set.managerID ~= nil then
                    equipmentSetMap[set.managerID] = set
                end
            end
        end
    end

    local oldEquipmentSetMap = equipmentSetMap;
    equipmentSetMap = {};

    local managerIDs = C_EquipmentSet.GetEquipmentSetIDs();
    for _,managerID in ipairs(managerIDs) do
        local isNewSet = false
        local set = oldEquipmentSetMap[managerID];
        if set == nil then
            set = Internal.AddBlankEquipmentSet();
            isNewSet = true
        end

        set.managerID = managerID;
        set.name = C_EquipmentSet.GetEquipmentSetInfo(managerID);

        local ignored = C_EquipmentSet.GetIgnoredSlots(managerID);
        local ids = C_EquipmentSet.GetItemIDs(managerID);
        local locations = C_EquipmentSet.GetItemLocations(managerID);
        for inventorySlotId=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
            set.ignored[inventorySlotId] = ignored[inventorySlotId] and true or nil

            if locations then -- Seems in some situations the locations table is nil instead
                local location = locations[inventorySlotId] or -1;
                
                if location > -1 then -- If location is -1 we ignore it as we cant get the item link for the item
                    local previousLocation = set.locations[inventorySlotId]
                    set.locations[inventorySlotId] = locations[inventorySlotId] -- Only update if the item has a location

                    local itemLink = Internal.GetItemLinkByLocation(location)
                    if itemLink and itemLink ~= "" then
                        set.equipment[inventorySlotId] = itemLink
                        set.extras[inventorySlotId] = Internal.GetExtrasForLocation(location, set.extras[inventorySlotId] or {})
                        set.data[inventorySlotId] = Internal.EncodeItemData(itemLink, set.extras[inventorySlotId] and set.extras[inventorySlotId].azerite)
                    end

                    if not isNewSet then
                        -- We force update because the blizzard manager should be correct
                        Internal.UpdateEquipmentSetItemInMapData(set, inventorySlotId, previousLocation, locations[inventorySlotId], true)
                    end
                elseif ids[inventorySlotId] == nil then -- Slot is empty
                    local previousLocation = set.locations[inventorySlotId]
                    set.locations[inventorySlotId] = nil

                    set.equipment[inventorySlotId] = nil
                    set.extras[inventorySlotId] = nil
                    set.data[inventorySlotId] = nil

                    if not isNewSet then
                        -- We force update because the blizzard manager should be correct
                        Internal.UpdateEquipmentSetItemInMapData(set, inventorySlotId, previousLocation, nil, true)
                    end
                end
            end
        end

        if isNewSet then
            Internal.AddEquipmentSetToMapData(set)
            Internal.Call("EquipmentSetCreated", set.setID);
        end

        equipmentSetMap[managerID] = set;
        oldEquipmentSetMap[managerID] = nil;
    end

    -- If a set previously managed by the blizzard manager is deleted
    -- we delete our set unless its in use, then we just disconnect it from
    -- the blizzard manager
    do
        local name, realm = UnitFullName("player");
        local character = GetCharacterSlug();
        for setID,set in pairs(BtWLoadoutsSets.equipment) do
            if type(set) == "table" then
                if set.character == character and set.managerID ~= nil then
                    if equipmentSetMap[set.managerID] ~= set then
                        if set.useCount > 0 then
                            set.managerID = nil;
                        else
                            Internal.DeleteEquipmentSet(set)
                        end
                    end
                end
            end
        end
    end

    BtWLoadoutsFrame:Update();
    Internal.UpdateLauncher(Internal.GetActiveProfiles());
end
function frame:BANKFRAME_OPENED(...)
    self:EQUIPMENT_SETS_CHANGED()
    Internal.InitializeBankItems()
end
function frame:ACTIVE_PLAYER_SPECIALIZATION_CHANGED(...)
    do
        local specID = GetSpecializationInfo(GetSpecialization());
        local spec = BtWLoadoutsSpecInfo[specID] or {};

        spec.pvptalentslots = spec.pvptalentslots or {};
        wipe(spec.pvptalentslots);
        do
            local index = 1
            local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(index)
            while slotInfo do
                spec.pvptalentslots[index] = slotInfo

                index = index + 1
                slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(index)
            end
        end

        BtWLoadoutsSpecInfo[specID] = spec;
    end
    Internal.UpdateLauncher(Internal.GetActiveProfiles());
    Internal.UpdateTraitInfoFromPlayer();

    local activeConfigID = C_ClassTalents.GetActiveConfigID();
    local specID = GetSpecializationInfo(GetSpecialization());
    local tree = Internal.GetTreeInfoBySpecID(specID);
    local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID);
    for _,configID in ipairs(configIDs) do
        self:TRAIT_CONFIG_UPDATED(configID);
    end

    -- Delete any trait trees that arent for the current spec but think they are
    for configID,set in pairs(dfTalentTreeSetMap) do
        local configInfo = C_Traits.GetConfigInfo(configID);
        if activeConfigID == configID or not configInfo or configInfo.treeIDs[1] ~= tree.ID or configInfo.type ~= 1 or (not tContains(configIDs, configID) and set.specID == specID) then
            self:TRAIT_CONFIG_DELETED(configID);
        end
    end
end
function frame:UPDATE_INSTANCE_INFO(...)
    local name, realm = UnitFullName("player")
    if not realm then
        return
    end
    
    Internal.UpdateConditionsForInstance();
    local bossID = Internal.UpdateConditionsForBoss();
    Internal.UpdateConditionsForAffixes();
    -- Boss is unavailable so dont trigger conditions
    if bossID and not Internal.BossAvailable(bossID) then
        return
    end
    Internal.TriggerConditions();
end
function frame:ZONE_CHANGED(...)
    local bossID = Internal.UpdateConditionsForBoss();
    -- Boss is unavailable so dont trigger conditions
    if bossID and not Internal.BossAvailable(bossID) then
        return
    end
    Internal.TriggerConditions();
end
function frame:ZONE_CHANGED_NEW_AREA(...)
    Internal.UpdateConditionsForInstance();
    local bossID = Internal.UpdateConditionsForBoss();
    Internal.UpdateConditionsForAffixes();
    -- Boss is unavailable so dont trigger conditions
    if bossID and not Internal.BossAvailable(bossID) then
        return
    end
    Internal.TriggerConditions();
end
function frame:UPDATE_MOUSEOVER_UNIT(...)
    local bossID = Internal.UpdateConditionsForBoss("mouseover");
    -- Boss is unavailable so dont trigger conditions
    if bossID and not Internal.BossAvailable(bossID) then
        return
    end
    Internal.TriggerConditions();
end
function frame:NAME_PLATE_UNIT_ADDED(...)
    local bossID = Internal.UpdateConditionsForBoss(...);
    -- Boss is unavailable so dont trigger conditions
    if bossID and not Internal.BossAvailable(bossID) then
        return
    end
    Internal.TriggerConditions();
end
function frame:PLAYER_TARGET_CHANGED(...)
    local bossID = Internal.UpdateConditionsForBoss("target");
    -- Boss is unavailable so dont trigger conditions
    if bossID and not Internal.BossAvailable(bossID) then
        return
    end
    Internal.TriggerConditions();
end
function frame:PLAYER_TALENT_UPDATE(...)
    Internal.UpdateLauncher(Internal.GetActiveProfiles());
end
function frame:ENCOUNTER_END(...)
    -- We dont trigger events during an encounter so we retrigger things after an encounter ends
    local bossID = Internal.UpdateConditionsForBoss();
    -- Boss is unavailable so dont trigger conditions
    if bossID and not Internal.BossAvailable(bossID) then
        return
    end
    Internal.TriggerConditions();
end
local enchantBySpellID = {
    [2831] = 15, -- Apply Armor Kit
    [2832] = 16, -- Apply Armor Kit
    [2833] = 17, -- Apply Armor Kit
    [10344] = 18, -- Apply Armor Kit
    [7443] = 24, -- Minor Mana
    [3974] = 30, -- Crude Scope
    [3975] = 32, -- Standard Scope
    [3976] = 33, -- Accurate Scope
    [7218] = 34, -- Weapon Counterweight
    [6296] = 36, -- Enchant: Fiery Blaze
    [7220] = 37, -- Weapon Chain
    [7420] = 41, -- Minor Health
    [7216] = 43, -- Iron Shield Spike
    [7426] = 44, -- Minor Absorption
    [13538] = 63, -- Lesser Absorption
    [7863] = 66, -- Minor Stamina
    [13503] = 241, -- Lesser Striking
    [7748] = 242, -- Lesser Health
    [7766] = 243, -- Minor Versatility
    [7776] = 246, -- Lesser Mana
    [7867] = 247, -- Minor Agility
    [7782] = 248, -- Minor Strength
    [7786] = 249, -- Minor Beastslayer
    [7788] = 250, -- Minor Striking
    [7857] = 254, -- Health
    [13380] = 255, -- Lesser Versatility
    [34001] = 369, -- Major Intellect
    [9781] = 463, -- Mithril Shield Spike
    [9783] = 464, -- Mithril Spurs
    [12459] = 663, -- Deadly Scope
    [12460] = 664, -- Sniper Scope
    [7793] = 723, -- Lesser Intellect
    [13644] = 724, -- Lesser Stamina
    [13421] = 744, -- Lesser Protection
    [7771] = 783, -- Minor Protection
    [13898] = 803, -- Fiery Weapon
    [13943] = 805, -- Greater Striking
    [13536] = 823, -- Lesser Strength
    [13607] = 843, -- Mana
    [13612] = 844, -- Mining
    [13617] = 845, -- Herbalism
    [24302] = 846, -- Eternium Fishing Line
    [13626] = 847, -- Minor Stats
    [13635] = 848, -- Defense
    [13637] = 849, -- Lesser Agility
    [13640] = 850, -- Greater Health
    [20024] = 851, -- Versatility
    [13836] = 852, -- Stamina
    [13653] = 853, -- Lesser Beastslayer
    [13655] = 854, -- Lesser Elemental Slayer
    [13661] = 856, -- Strength
    [13663] = 857, -- Greater Mana
    [13689] = 863, -- Lesser Parry
    [13698] = 865, -- Skinning
    [13700] = 866, -- Lesser Stats
    [13746] = 884, -- Greater Defense
    [13935] = 904, -- Agility
    [13822] = 905, -- Intellect
    [13841] = 906, -- Advanced Mining
    [13846] = 907, -- Greater Versatility
    [13858] = 908, -- Superior Health
    [13868] = 909, -- Advanced Herbalism
    [25083] = 910, -- Stealth
    [13890] = 911, -- Minor Speed
    [13915] = 912, -- Demonslaying
    [13917] = 913, -- Superior Mana
    [13931] = 923, -- Dodge
    [7428] = 924, -- Minor Dodge
    [13646] = 925, -- Lesser Dodge
    [13939] = 927, -- Greater Strength
    [13941] = 928, -- Stats
    [20020] = 929, -- Greater Stamina
    [13947] = 930, -- Riding Skill
    [13948] = 931, -- Minor Haste
    [13529] = 943, -- Lesser Impact
    [13937] = 963, -- Greater Impact
    [34009] = 1071, -- Major Stamina
    [44528] = 1075, -- Greater Fortitude
    [60663] = 1099, -- Major Agility
    [44633] = 1103, -- Exceptional Agility
    [44555] = 1119, -- Exceptional Intellect
    [47715] = 1119, -- Enchant Template
    [60653] = 1128, -- Greater Intellect
    [44508] = 1147, -- Greater Versatility
    [44593] = 1147, -- Major Versatility
    [15340] = 1483, -- Lesser Arcane Amalgamation
    [15389] = 1503, -- Lesser Arcane Amalgamation
    [15391] = 1504, -- Lesser Arcane Amalgamation
    [15394] = 1505, -- Lesser Arcane Amalgamation
    [15397] = 1506, -- Lesser Arcane Amalgamation
    [15400] = 1507, -- Lesser Arcane Amalgamation
    [15402] = 1508, -- Lesser Arcane Amalgamation
    [15404] = 1509, -- Lesser Arcane Amalgamation
    [15406] = 1510, -- Lesser Arcane Amalgamation
    [60763] = 1597, -- Greater Assault
    [60616] = 1600, -- Assault
    [60668] = 1603, -- Crusher
    [60621] = 1606, -- Greater Potency
    [16623] = 1704, -- Thorium Shield Spike
    [19057] = 1843, -- Apply Armor Kit
    [20008] = 1883, -- Greater Intellect
    [20009] = 1884, -- Superior Versatility
    [20010] = 1885, -- Superior Strength
    [20011] = 1886, -- Superior Stamina
    [20012] = 1887, -- Greater Agility
    [20023] = 1887, -- Greater Agility
    [20015] = 1889, -- Superior Defense
    [20016] = 1890, -- Vitality
    [20025] = 1891, -- Greater Stats
    [27905] = 1891, -- Stats
    [44616] = 1891, -- Greater Stats
    [60692] = 1891, -- Powerful Stats
    [74191] = 1891, -- Mighty Stats
    [20026] = 1892, -- Major Health
    [20028] = 1893, -- Major Mana
    [20029] = 1894, -- Icy Chill
    [20030] = 1896, -- Superior Impact
    [13695] = 1897, -- Impact
    [20031] = 1897, -- Superior Striking
    [20032] = 1898, -- Lifestealing
    [20033] = 1899, -- Unholy Weapon
    [20034] = 1900, -- Crusader
    [20035] = 1903, -- Major Versatility
    [20036] = 1904, -- Major Intellect
    [44591] = 1951, -- Superior Dodge
    [44489] = 1952, -- Dodge
    [47766] = 1953, -- Greater Dodge
    [33999] = 2322, -- Major Healing
    [44635] = 2326, -- Greater Spellpower
    [60767] = 2332, -- Superior Spellpower
    [44509] = 2381, -- Greater Versatility
    [21931] = 2443, -- Winter's Might
    [22593] = 2483, -- Flame Mantle of the Dawn
    [22594] = 2484, -- Frost Mantle of the Dawn
    [22598] = 2485, -- Arcane Mantle of the Dawn
    [22597] = 2486, -- Nature Mantle of the Dawn
    [22596] = 2487, -- Shadow Mantle of the Dawn
    [22599] = 2488, -- Chromatic Mantle of the Dawn
    [22725] = 2503, -- Core Armor Kit
    [22749] = 2504, -- Spellpower
    [22750] = 2505, -- Healing Power
    [22779] = 2523, -- Biznicks 247x128 Accurascope
    [22840] = 2543, -- Arcanum of Rapidity
    [22844] = 2544, -- Arcanum of Focus
    [22846] = 2545, -- Arcanum of Protection
    [23799] = 2563, -- Strength
    [23800] = 2564, -- Agility
    [25080] = 2564, -- Superior Agility
    [23801] = 2565, -- Argent Versatility
    [23803] = 2567, -- Mighty Versatility
    [23804] = 2568, -- Mighty Intellect
    [24149] = 2583, -- Presence of Might
    [24160] = 2584, -- Syncretist's Sigil
    [24163] = 2587, -- Vodouisant's Vigilant Embrace
    [24164] = 2588, -- Presence of Sight
    [24165] = 2589, -- Hoodoo Hex
    [24167] = 2590, -- Prophetic Aura
    [24168] = 2591, -- Animist's Caress
    [13620] = 2603, -- Fishing
    [144736] = 2603, -- Fishing
    [24420] = 2604, -- Zandalar Signet of Serenity
    [24421] = 2605, -- Zandalar Signet of Mojo
    [24422] = 2606, -- Zandalar Signet of Might
    [25072] = 2613, -- Threat
    [25073] = 2614, -- Shadow Power
    [25074] = 2615, -- Frost Power
    [25078] = 2616, -- Fire Power
    [25079] = 2617, -- Healing Power
    [25084] = 2621, -- Subtlety
    [25086] = 2622, -- Dodge
    [27837] = 2646, -- Agility
    [27899] = 2647, -- Brawn
    [27906] = 2648, -- Greater Dodge
    [47051] = 2648, -- Greater Dodge
    [27914] = 2649, -- Fortitude
    [27950] = 2649, -- Fortitude
    [23802] = 2650, -- Healing Power
    [27944] = 2653, -- Lesser Dodge
    [27945] = 2654, -- Intellect
    [27946] = 2655, -- Parry
    [27948] = 2656, -- Vitality
    [27951] = 2657, -- Dexterity
    [27954] = 2658, -- Surefooted
    [27957] = 2659, -- Exceptional Health
    [27960] = 2661, -- Exceptional Stats
    [44623] = 2661, -- Super Stats
    [74250] = 2661, -- Peerless Stats
    [104395] = 2661, -- Glorious Stats
    [27961] = 2662, -- Major Armor
    [27968] = 2666, -- Major Intellect
    [27971] = 2667, -- Savagery
    [27972] = 2668, -- Potency
    [27975] = 2669, -- Major Spellpower
    [27977] = 2670, -- Major Agility
    [27981] = 2671, -- Sunfire
    [27982] = 2672, -- Soulfrost
    [27984] = 2673, -- Mongoose
    [28003] = 2674, -- Spellsurge
    [28004] = 2675, -- Battlemaster
    [27913] = 2679, -- Versatility Prime
    [28161] = 2681, -- Savage Guard
    [28163] = 2682, -- Ice Guard
    [28165] = 2683, -- Shadow Guard
    [29454] = 2714, -- Felsteel Shield Spike
    [29475] = 2715, -- Resilience of the Scourge
    [29480] = 2716, -- Fortitude of the Scourge
    [29483] = 2717, -- Might of the Scourge
    [29467] = 2721, -- Power of the Scourge
    [30250] = 2722, -- Adamantite Scope
    [30252] = 2723, -- Khorium Scope
    [30260] = 2724, -- Stabilized Eternium Scope
    [31369] = 2745, -- Silver Spellthread
    [31370] = 2746, -- Golden Spellthread
    [31371] = 2747, -- Mystic Spellthread
    [31372] = 2748, -- Runic Spellthread
    [32397] = 2792, -- Apply Armor Kit
    [32398] = 2793, -- Vindicator's Armor Kit
    [32399] = 2794, -- Magister's Armor Kit
    [44968] = 2841, -- Apply Armor Kit
    [33992] = 2933, -- Major Armor
    [33993] = 2934, -- Blasting
    [33994] = 2935, -- Precise Strikes
    [33997] = 2937, -- Major Spellpower
    [34003] = 2938, -- PvP Power
    [134871] = 2938, -- PvP Power
    [34007] = 2939, -- Cat's Swiftness
    [34008] = 2940, -- Boar's Speed
    [35355] = 2977, -- Inscription of Warding
    [35402] = 2978, -- Greater Inscription of Warding
    [35403] = 2979, -- Inscription of Faith
    [35404] = 2980, -- Greater Inscription of Faith
    [35405] = 2981, -- Inscription of Discipline
    [35406] = 2982, -- Greater Inscription of Discipline
    [35407] = 2983, -- Inscription of Vengeance
    [35417] = 2986, -- Greater Inscription of Vengeance
    [35432] = 2990, -- Inscription of the Knight
    [35433] = 2991, -- Greater Inscription of the Knight
    [35434] = 2992, -- Inscription of the Oracle
    [35435] = 2993, -- Greater Inscription of the Oracle
    [35436] = 2994, -- Inscription of the Orb
    [35437] = 2995, -- Greater Inscription of the Orb
    [35438] = 2996, -- Inscription of the Blade
    [35439] = 2997, -- Greater Inscription of the Blade
    [35441] = 2998, -- Inscription of Endurance
    [35443] = 2999, -- Arcanum of the Defender
    [35445] = 3001, -- Arcanum of Renewal
    [35447] = 3002, -- Arcanum of Power
    [35452] = 3003, -- Arcanum of Ferocity
    [35453] = 3004, -- Arcanum of the Gladiator
    [35454] = 3005, -- Arcanum of Nature Warding
    [35455] = 3006, -- Arcanum of Arcane Warding
    [35456] = 3007, -- Arcanum of Fire Warding
    [35457] = 3008, -- Arcanum of Frost Warding
    [35458] = 3009, -- Arcanum of Shadow Warding
    [35488] = 3010, -- Cobrahide Leg Armor
    [35489] = 3011, -- Clefthide Leg Armor
    [35490] = 3012, -- Nethercobra Leg Armor
    [35495] = 3013, -- Nethercleft Leg Armor
    [37889] = 3095, -- Arcanum of Chromatic Warding
    [37891] = 3096, -- Arcanum of the Outcast
    [33991] = 3150, -- Versatility Prime
    [42620] = 3222, -- Greater Agility
    [42687] = 3223, -- Adamantite Weapon Chain
    [42974] = 3225, -- Executioner
    [44119] = 3228, -- Enchant Bracer - Template
    [44383] = 3229, -- Armor
    [44484] = 3231, -- Haste
    [44598] = 3231, -- Haste
    [47901] = 3232, -- Tuskarr's Vitality
    [27958] = 3233, -- Exceptional Mana
    [44488] = 3234, -- Precision
    [44492] = 3236, -- Mighty Health
    [44506] = 3238, -- Gatherer
    [44524] = 3239, -- Icebreaker
    [44576] = 3241, -- Lifeward
    [44582] = 3243, -- Minor Power
    [44584] = 3244, -- Greater Vitality
    [44588] = 3245, -- Exceptional Armor
    [44592] = 3246, -- Exceptional Spellpower
    [44595] = 3247, -- Scourgebane
    [44612] = 3249, -- Greater Blasting
    [44621] = 3251, -- Giant Slayer
    [44625] = 3253, -- Armsman
    [44631] = 3256, -- Shadow Armor
    [44769] = 3260, -- Glove Reinforcements
    [45697] = 3269, -- Truesilver Fishing Line
    [46578] = 3273, -- Deathfrost
    [47103] = 3289, -- Riding Crop
    [48555] = 3289, -- Skybreaker Whip
    [48557] = 3289, -- Riding Crop
    [47672] = 3294, -- Mighty Stamina
    [47899] = 3296, -- Wisdom
    [47900] = 3297, -- Super Health
    [48401] = 3315, -- Carrot on a Stick
    [48556] = 3315, -- Carrot on a Stick
    [50901] = 3325, -- Jormungar Leg Armor
    [50902] = 3326, -- Nerubian Leg Armor
    [50906] = 3329, -- Apply Armor Kit
    [50909] = 3330, -- Apply Armor Kit
    [50913] = 3332, -- Wyrmscale Leg Armor
    [53344] = 3368, -- Rune of the Fallen Crusader
    [53343] = 3370, -- Rune of Razorice
    [54736] = 3599, -- EMP Generator
    [54793] = 3601, -- Frag Belt
    [55002] = 3605, -- Flexweave Underlay
    [55076] = 3607, -- Sun Scope
    [55135] = 3608, -- Heartseeker Scope
    [55630] = 3718, -- Shining Spellthread
    [55631] = 3719, -- Brilliant Spellthread
    [55632] = 3720, -- Azure Spellthread
    [55634] = 3721, -- Sapphire Spellthread
    [55836] = 3731, -- Titanium Weapon Chain
    [56353] = 3748, -- Titanium Shield Spike
    [24162] = 3754, -- Falcon's Call
    [24161] = 3755, -- Death's Embrace
    [58126] = 3775, -- Inscription of High Discipline
    [58128] = 3776, -- Inscription of the Frostblade
    [58129] = 3777, -- Inscription of Kings
    [59619] = 3788, -- Accuracy
    [59621] = 3789, -- Berserking
    [59625] = 3790, -- Black Magic
    [59771] = 3793, -- Inscription of Triumph
    [59773] = 3794, -- Inscription of Dominance
    [59777] = 3795, -- Arcanum of Triumph
    [59778] = 3796, -- Arcanum of Dominance
    [59784] = 3797, -- Arcanum of Dominance
    [59927] = 3806, -- Inscription of the Storm
    [59928] = 3807, -- Inscription of the Crag
    [59934] = 3808, -- Greater Inscription of the Axe
    [59936] = 3809, -- Greater Inscription of the Crag
    [59937] = 3810, -- Greater Inscription of the Storm
    [59941] = 3811, -- Greater Inscription of the Pinnacle
    [59944] = 3812, -- Arcanum of the Frosty Soul
    [59945] = 3813, -- Arcanum of Toxic Warding
    [59946] = 3814, -- Arcanum of the Fleeing Shadow
    [59947] = 3815, -- Arcanum of the Eclipsed Moon
    [59948] = 3816, -- Arcanum of the Flame's Soul
    [59954] = 3817, -- Arcanum of Torment
    [59955] = 3818, -- Arcanum of the Stalwart Protector
    [59960] = 3819, -- Arcanum of Blissful Mending
    [59970] = 3820, -- Arcanum of Burning Mysteries
    [60581] = 3822, -- Frosthide Leg Armor
    [60582] = 3823, -- Icescale Leg Armor
    [60606] = 3824, -- Assault
    [60609] = 3825, -- Speed
    [60623] = 3826, -- Icewalker
    [60691] = 3827, -- Massacre
    [44630] = 3828, -- Greater Savagery
    [44513] = 3829, -- Greater Assault
    [44629] = 3830, -- Exceptional Spellpower
    [47898] = 3831, -- Greater Speed
    [60707] = 3833, -- Superior Potency
    [60714] = 3834, -- Mighty Spellpower
    [61117] = 3835, -- Master's Inscription of the Axe
    [61118] = 3836, -- Master's Inscription of the Crag
    [61119] = 3837, -- Master's Inscription of the Pinnacle
    [61120] = 3838, -- Master's Inscription of the Storm
    [61271] = 3842, -- Arcanum of the Savage Gladiator
    [61468] = 3843, -- Diamond-cut Refractor Scope
    [44510] = 3844, -- Exceptional Versatility
    [44575] = 3845, -- Greater Assault
    [34010] = 3846, -- Major Healing
    [62158] = 3847, -- Rune of the Stoneskin Gargoyle
    [62201] = 3849, -- Titanium Plating
    [62256] = 3850, -- Major Stamina
    [62257] = 3851, -- Titanguard
    [62384] = 3852, -- Greater Inscription of the Gladiator
    [62447] = 3853, -- Earthen Leg Armor
    [62948] = 3854, -- Greater Spellpower
    [62959] = 3855, -- Spellpower
    [63746] = 3858, -- Lesser Accuracy
    [64441] = 3869, -- Blade Ward
    [64579] = 3870, -- Blood Draining
    [56039] = 3872, -- Sanctified Spellthread
    [56034] = 3873, -- Master's Spellthread
    [59929] = 3875, -- Inscription of the Axe
    [59932] = 3876, -- Inscription of the Pinnacle
    [74132] = 4061, -- Mastery
    [74189] = 4062, -- Earthen Vitality
    [74192] = 4064, -- Lesser Power
    [74193] = 4065, -- Speed
    [74195] = 4066, -- Mending
    [74197] = 4067, -- Avalanche
    [74198] = 4068, -- Haste
    [74199] = 4069, -- Haste
    [74200] = 4070, -- Stamina
    [74201] = 4071, -- Critical Strike
    [74202] = 4072, -- Intellect
    [74207] = 4073, -- Protection
    [74211] = 4074, -- Elemental Slayer
    [74212] = 4075, -- Exceptional Strength
    [74213] = 4076, -- Major Agility
    [74214] = 4077, -- Mighty Armor
    [112059] = 4077, -- Enchant Chest - Mighty Resilience - Test Only
    [74220] = 4082, -- Greater Haste
    [74223] = 4083, -- Hurricane
    [74225] = 4084, -- Heartsong
    [74226] = 4085, -- Mastery
    [74229] = 4086, -- Superior Dodge
    [74230] = 4087, -- Critical Strike
    [74231] = 4088, -- Exceptional Versatility
    [74232] = 4089, -- Precision
    [74234] = 4090, -- Protection
    [74235] = 4091, -- Superior Intellect
    [74236] = 4092, -- Precision
    [74237] = 4093, -- Exceptional Versatility
    [74238] = 4094, -- Mastery
    [74239] = 4095, -- Greater Haste
    [74240] = 4096, -- Greater Intellect
    [74242] = 4097, -- Power Torrent
    [74244] = 4098, -- Windwalk
    [74246] = 4099, -- Landslide
    [74247] = 4100, -- Greater Critical Strike
    [74248] = 4101, -- Greater Critical Strike
    [74251] = 4103, -- Greater Stamina
    [74253] = 4104, -- Lavawalker
    [74252] = 4105, -- Assassin's Step
    [74254] = 4106, -- Mighty Strength
    [74255] = 4107, -- Greater Mastery
    [74256] = 4108, -- Greater Speed
    [75149] = 4109, -- Ghostly Spellthread
    [75150] = 4110, -- Powerful Ghostly Spellthread
    [75151] = 4111, -- Enchanted Spellthread
    [75152] = 4112, -- Powerful Enchanted Spellthread
    [75154] = 4113, -- Master's Spellthread
    [75155] = 4114, -- Sanctified Spellthread
    [78165] = 4120, -- Apply Armor Kit
    [78166] = 4121, -- Heavy Savage Armor Kit
    [78169] = 4122, -- Scorched Leg Armor
    [78170] = 4124, -- Twilight Leg Armor
    [78171] = 4126, -- Dragonscale Leg Armor
    [78172] = 4127, -- Charscale Leg Armor
    [81932] = 4175, -- Gnomish X-Ray Scope
    [81933] = 4176, -- R19 Threatfinder
    [81934] = 4177, -- Safety Catch Removal Kit
    [84424] = 4187, -- Invisibility Field
    [84427] = 4188, -- Grounded Plasma Shield
    [86375] = 4193, -- Swiftsteel Inscription
    [86401] = 4194, -- Lionsmane Inscription
    [86402] = 4195, -- Inscription of the Earth Prince
    [86403] = 4196, -- Felfire Inscription
    [86847] = 4197, -- Inscription of Unbreakable Quartz
    [86854] = 4198, -- Greater Inscription of Unbreakable Quartz
    [86898] = 4199, -- Inscription of Charged Lodestone
    [86899] = 4200, -- Greater Inscription of Charged Lodestone
    [86900] = 4201, -- Inscription of Jagged Stone
    [86901] = 4202, -- Greater Inscription of Jagged Stone
    [86906] = 4203, -- Inscription of Shattered Crystal
    [86907] = 4204, -- Greater Inscription of Shattered Crystal
    [86909] = 4205, -- Inscription of Shattered Crystal
    [86931] = 4206, -- Arcanum of the Earthern Ring
    [86932] = 4207, -- Arcanum of Hyjal
    [86933] = 4208, -- Arcanum of the Highlands
    [86934] = 4209, -- Arcanum of Ramkahen
    [84425] = 4214, -- Cardboard Assassin
    [92433] = 4215, -- Elementium Shield Spike
    [92437] = 4216, -- Pyrium Shield Spike
    [93448] = 4217, -- Pyrium Weapon Chain
    [67839] = 4222, -- Mind Amplification Dish
    [55016] = 4223, -- Nitro Boosts
    [95471] = 4227, -- Mighty Agility
    [96245] = 4245, -- Arcanum of Vicious Intellect
    [96246] = 4246, -- Arcanum of Vicious Agility
    [96247] = 4247, -- Arcanum of Vicious Strength
    [96249] = 4248, -- Greater Inscription of Vicious Intellect
    [96250] = 4249, -- Greater Inscription of Vicious Strength
    [96251] = 4250, -- Greater Inscription of Vicious Agility
    [96261] = 4256, -- Major Strength
    [96262] = 4257, -- Mighty Intellect
    [96264] = 4258, -- Agility
    [96286] = 4259, -- Reinforced Fishing Line
    [99623] = 4267, -- Flintlocke's Woodchucker
    [101598] = 4270, -- Drakehide Leg Armor
    [104338] = 4411, -- Mastery
    [104385] = 4412, -- Major Dodge
    [104389] = 4414, -- Super Intellect
    [104390] = 4415, -- Exceptional Strength
    [104391] = 4416, -- Greater Agility
    [104392] = 4417, -- Super Armor
    [104393] = 4418, -- Mighty Versatility
    [104397] = 4420, -- Superior Stamina
    [104398] = 4421, -- Accuracy
    [104401] = 4422, -- Greater Protection
    [104403] = 4423, -- Superior Intellect
    [104404] = 4424, -- Superior Critical Strike
    [104407] = 4426, -- Greater Haste
    [104408] = 4427, -- Greater Precision
    [104409] = 4428, -- Blurred Speed
    [104414] = 4429, -- Pandaren's Step
    [104416] = 4430, -- Greater Haste
    [104417] = 4431, -- Superior Haste
    [104419] = 4432, -- Super Strength
    [104420] = 4433, -- Superior Mastery
    [104445] = 4434, -- Major Intellect
    [104425] = 4441, -- Windsong
    [104427] = 4442, -- Jade Spirit
    [104430] = 4443, -- Elemental Force
    [104434] = 4444, -- Dancing Steel
    [104440] = 4445, -- Colossus
    [104442] = 4446, -- River's Song
    [108115] = 4687, -- Enchant Weapon - Ninja (TEST VERSION)
    [109086] = 4699, -- Lord Blastington's Scope of Doom
    [109093] = 4700, -- Mirror Scope
    [113011] = 4719, -- Inscription
    [7418] = 4720, -- Minor Health
    [7457] = 4721, -- Minor Stamina
    [13378] = 4722, -- Minor Stamina
    [7745] = 4723, -- Minor Impact
    [13419] = 4724, -- Minor Agility
    [7779] = 4725, -- Minor Agility
    [13687] = 4726, -- Lesser Versatility
    [7859] = 4727, -- Lesser Versatility
    [13485] = 4728, -- Lesser Versatility
    [13622] = 4729, -- Lesser Intellect
    [13501] = 4730, -- Lesser Stamina
    [13631] = 4731, -- Lesser Stamina
    [71692] = 4732, -- Angler
    [13464] = 4733, -- Lesser Protection
    [13882] = 4734, -- Lesser Agility
    [13642] = 4735, -- Versatility
    [13659] = 4736, -- Versatility
    [13648] = 4737, -- Stamina
    [13817] = 4738, -- Stamina
    [13887] = 4739, -- Strength
    [13815] = 4740, -- Agility
    [13905] = 4741, -- Greater Versatility
    [20013] = 4742, -- Greater Strength
    [13945] = 4743, -- Greater Stamina
    [20017] = 4744, -- Greater Stamina
    [13693] = 4745, -- Striking
    [27967] = 4746, -- Major Striking
    [44500] = 4747, -- Superior Agility
    [44589] = 4748, -- Superior Agility
    [82200] = 4750, -- Spinal Healing Injector
    [121192] = 4803, -- Greater Tiger Fang Inscription
    [121193] = 4804, -- Greater Tiger Claw Inscription
    [121194] = 4805, -- Greater Ox Horn Inscription
    [121195] = 4806, -- Greater Crane Wing Inscription
    [121988] = 4808, -- Enchant Weapon - Magic Weapon
    [122387] = 4822, -- Shadowleather Leg Armor
    [122388] = 4823, -- Angerhide Leg Armor
    [122386] = 4824, -- Ironscale Leg Armor
    [122392] = 4825, -- Greater Cerulean Spellthread
    [122393] = 4826, -- Greater Pearlescent Spellthread
    [124091] = 4869, -- Sha Armor Kit
    [124116] = 4870, -- Toughened Leg Armor
    [124118] = 4871, -- Sha-Touched Leg Armor
    [124119] = 4872, -- Brutal Leg Armor
    [124559] = 4880, -- Primal Leg Reinforcements
    [124561] = 4881, -- Draconic Leg Reinforcements
    [124563] = 4882, -- Heavy Leg Reinforcements
    [124564] = 4883, -- Primal Leg Reinforcements
    [124565] = 4884, -- Heavy Leg Reinforcements
    [124566] = 4885, -- Draconic Leg Reinforcements
    [124567] = 4886, -- Primal Leg Reinforcements
    [124568] = 4887, -- Heavy Leg Reinforcements
    [124569] = 4888, -- Draconic Leg Reinforcements
    [125496] = 4895, -- Master's Spellthread
    [125497] = 4896, -- Sanctified Spellthread
    [126392] = 4897, -- Goblin Glider
    [127015] = 4907, -- Tiger Fang Inscription
    [127014] = 4908, -- Tiger Claw Inscription
    [127013] = 4909, -- Crane Wing Inscription
    [127012] = 4910, -- Ox Horn Inscription
    [113048] = 4912, -- Secret Ox Horn Inscription
    [113047] = 4913, -- Secret Tiger Fang Inscription
    [113046] = 4914, -- Secret Tiger Claw Inscription
    [113045] = 4915, -- Secret Crane Wing Inscription
    [113044] = 4916, -- Secret Serpent Pearl Inscription
    [128286] = 4918, -- Living Steel Weapon Chain
    [130749] = 4992, -- Exceptional Strength (Scaling)
    [130758] = 4993, -- Greater Parry
    [109099] = 5000, -- Watergliding Jets
    [131464] = 5001, -- Ghost Iron Shield Spike
    [131862] = 5003, -- Cerulean Spellthread
    [131863] = 5004, -- Pearlescent Spellthread
    [139631] = 5035, -- Enchant Weapon - Glorious Tyranny
    [142469] = 5124, -- Enchant Weapon - Spirit of Conquest
    [142468] = 5125, -- Enchant Weapon - Bloody Dancing Steel
    [27911] = 5183, -- Superior Healing
    [27917] = 5184, -- Spellpower
    [33990] = 5237, -- Major Versatility
    [33995] = 5250, -- Major Strength
    [33996] = 5255, -- Assault
    [34002] = 5257, -- Lesser Assault
    [34004] = 5258, -- Greater Agility
    [44529] = 5259, -- Major Agility
    [46594] = 5260, -- Dodge
    [155692] = 5274, -- enchant gloves - test
    [156050] = 5275, -- Oglethorpe's Missile Splitter
    [156061] = 5276, -- Megawatt Filament
    [158877] = 5281, -- Breath of Critical Strike
    [158907] = 5284, -- Breath of Critical Strike
    [158892] = 5285, -- Breath of Critical Strike
    [158893] = 5292, -- Breath of Haste
    [158894] = 5293, -- Breath of Mastery
    [158895] = 5294, -- Breath of Haste
    [158896] = 5295, -- Breath of Versatility
    [158908] = 5297, -- Breath of Haste
    [158878] = 5298, -- Breath of Haste
    [158909] = 5299, -- Breath of Mastery
    [158879] = 5300, -- Breath of Mastery
    [158910] = 5301, -- Breath of Mastery
    [158880] = 5302, -- Breath of Critical Strike
    [158911] = 5303, -- Breath of Versatility
    [158881] = 5304, -- Breath of Versatility
    [158884] = 5310, -- Gift of Critical Strike
    [158885] = 5311, -- Gift of Haste
    [158886] = 5312, -- Gift of Mastery
    [158887] = 5313, -- Gift of Critical Strike
    [158889] = 5314, -- Gift of Versatility
    [158899] = 5317, -- Gift of Critical Strike
    [158900] = 5318, -- Gift of Haste
    [158901] = 5319, -- Gift of Mastery
    [158902] = 5320, -- Gift of Haste
    [158903] = 5321, -- Gift of Versatility
    [158914] = 5324, -- Gift of Critical Strike
    [158915] = 5325, -- Gift of Haste
    [158916] = 5326, -- Gift of Mastery
    [158917] = 5327, -- Gift of Mastery
    [158918] = 5328, -- Gift of Versatility
    [159235] = 5330, -- Mark of the Thunderlord
    [159236] = 5331, -- Mark of the Shattered Hand
    [159672] = 5334, -- Mark of the Frostwolf
    [159673] = 5335, -- Mark of Shadowmoon
    [159674] = 5336, -- Mark of Blackrock
    [159671] = 5337, -- Mark of Warsong
    [170627] = 5352, -- Glory of the Thunderlord
    [170628] = 5353, -- Glory of the Shadowmoon
    [170629] = 5354, -- Glory of the Blackrock
    [170630] = 5355, -- Glory of the Warsong
    [170631] = 5356, -- Glory of the Frostwolf
    [170886] = 5357, -- Rook's Lucky Fishing Line
    [173287] = 5383, -- Hemet's Heartseeker
    [173323] = 5384, -- Mark of Bleeding Hollow
    [190866] = 5423, -- Word of Critical Strike
    [190992] = 5423, -- Word of Critical Strike
    [191009] = 5423, -- Word of Critical Strike
    [190867] = 5424, -- Word of Haste
    [190993] = 5424, -- Word of Haste
    [191010] = 5424, -- Word of Haste
    [190868] = 5425, -- Word of Mastery
    [190994] = 5425, -- Word of Mastery
    [191011] = 5425, -- Word of Mastery
    [190869] = 5426, -- Word of Versatility
    [190995] = 5426, -- Word of Versatility
    [191012] = 5426, -- Word of Versatility
    [190870] = 5427, -- Binding of Critical Strike
    [190996] = 5427, -- Binding of Critical Strike
    [191013] = 5427, -- Binding of Critical Strike
    [190871] = 5428, -- Binding of Haste
    [190997] = 5428, -- Binding of Haste
    [191014] = 5428, -- Binding of Haste
    [190872] = 5429, -- Binding of Mastery
    [190998] = 5429, -- Binding of Mastery
    [191015] = 5429, -- Binding of Mastery
    [190873] = 5430, -- Binding of Versatility
    [190999] = 5430, -- Binding of Versatility
    [191016] = 5430, -- Binding of Versatility
    [190874] = 5431, -- Word of Strength
    [191000] = 5431, -- Word of Strength
    [191017] = 5431, -- Word of Strength
    [190875] = 5432, -- Word of Agility
    [191001] = 5432, -- Word of Agility
    [191018] = 5432, -- Word of Agility
    [190876] = 5433, -- Word of Intellect
    [191002] = 5433, -- Word of Intellect
    [191019] = 5433, -- Word of Intellect
    [190877] = 5434, -- Binding of Strength
    [191003] = 5434, -- Binding of Strength
    [191020] = 5434, -- Binding of Strength
    [190878] = 5435, -- Binding of Agility
    [191004] = 5435, -- Binding of Agility
    [191021] = 5435, -- Binding of Agility
    [190879] = 5436, -- Binding of Intellect
    [191005] = 5436, -- Binding of Intellect
    [191022] = 5436, -- Binding of Intellect
    [190892] = 5437, -- Mark of the Claw
    [191006] = 5437, -- Mark of the Claw
    [191023] = 5437, -- Mark of the Claw
    [190893] = 5438, -- Mark of the Distant Army
    [191007] = 5438, -- Mark of the Distant Army
    [191024] = 5438, -- Mark of the Distant Army
    [190894] = 5439, -- Mark of the Hidden Satyr
    [191008] = 5439, -- Mark of the Hidden Satyr
    [191025] = 5439, -- Mark of the Hidden Satyr
    [190954] = 5440, -- Boon of the Scavenger
    [190955] = 5441, -- Boon of the Gemfinder
    [190956] = 5442, -- Boon of the Harvester
    [190957] = 5443, -- Boon of the Butcher
    [190988] = 5444, -- Legion Herbalism
    [190989] = 5445, -- Legion Mining
    [190990] = 5446, -- Legion Skinning
    [190991] = 5447, -- Legion Surveying
    [210608] = 5843, -- Songs of Battle
    [210626] = 5844, -- Songs of Peace
    [210628] = 5845, -- Songs of the Legion
    [222851] = 5881, -- Boon of the Salvager
    [222852] = 5882, -- Boon of the Manaseeker
    [222853] = 5883, -- Boon of the Bloodhunter
    [223937] = 5884, -- Songs of the Horde
    [223938] = 5885, -- Songs of the Alliance
    [228139] = 5888, -- Boon of the Nether
    [228402] = 5889, -- Mark of the Heavy Hide
    [228403] = 5889, -- Mark of the Heavy Hide
    [228404] = 5889, -- Mark of the Heavy Hide
    [228405] = 5890, -- Mark of the Trained Soldier
    [228406] = 5890, -- Mark of the Trained Soldier
    [228407] = 5890, -- Mark of the Trained Soldier
    [228408] = 5891, -- Mark of the Ancient Priestess
    [228409] = 5891, -- Mark of the Ancient Priestess
    [228410] = 5891, -- Mark of the Ancient Priestess
    [235695] = 5895, -- Mark of the Master
    [235699] = 5895, -- Mark of the Master
    [235703] = 5895, -- Mark of the Master
    [235696] = 5896, -- Mark of the Versatile
    [235700] = 5896, -- Mark of the Versatile
    [235704] = 5896, -- Mark of the Versatile
    [235697] = 5897, -- Mark of the Quick
    [235701] = 5897, -- Mark of the Quick
    [235705] = 5897, -- Mark of the Quick
    [235698] = 5898, -- Mark of the Deadly
    [235702] = 5898, -- Mark of the Deadly
    [235706] = 5898, -- Mark of the Deadly
    [235731] = 5899, -- Boon of the Builder
    [235794] = 5900, -- Boon of the Zookeeper
    [254584] = 5929, -- Boon of the Steadfast
    [254607] = 5930, -- Ancient Fishing Line
    [254706] = 5931, -- Boon of the Lightbearer
    [255035] = 5932, -- Kul Tiran Herbalism
    [267458] = 5932, -- Zandalari Herbalism
    [255040] = 5933, -- Kul Tiran Mining
    [267482] = 5933, -- Zandalari Mining
    [255065] = 5934, -- Kul Tiran Skinning
    [267486] = 5934, -- Zandalari Skinning
    [255066] = 5935, -- Kul Tiran Surveying
    [267490] = 5935, -- Zandalari Surveying
    [255068] = 5936, -- Swift Hearthing
    [267495] = 5936, -- Swift Hearthing
    [255070] = 5937, -- Kul Tiran Crafting
    [267498] = 5937, -- Zandalari Crafting
    [255071] = 5938, -- Seal of Critical Strike
    [255086] = 5938, -- Seal of Critical Strike
    [255094] = 5938, -- Seal of Critical Strike
    [255072] = 5939, -- Seal of Haste
    [255087] = 5939, -- Seal of Haste
    [255095] = 5939, -- Seal of Haste
    [255073] = 5940, -- Seal of Mastery
    [255088] = 5940, -- Seal of Mastery
    [255096] = 5940, -- Seal of Mastery
    [255074] = 5941, -- Seal of Versatility
    [255089] = 5941, -- Seal of Versatility
    [255097] = 5941, -- Seal of Versatility
    [255075] = 5942, -- Pact of Critical Strike
    [255090] = 5942, -- Pact of Critical Strike
    [255098] = 5942, -- Pact of Critical Strike
    [255076] = 5943, -- Pact of Haste
    [255091] = 5943, -- Pact of Haste
    [255099] = 5943, -- Pact of Haste
    [281260] = 5943, -- Test Spell Token - Enchantment (DNT)
    [255077] = 5944, -- Pact of Mastery
    [255092] = 5944, -- Pact of Mastery
    [255100] = 5944, -- Pact of Mastery
    [255078] = 5945, -- Pact of Versatility
    [255093] = 5945, -- Pact of Versatility
    [255101] = 5945, -- Pact of Versatility
    [255103] = 5946, -- Coastal Surge
    [255104] = 5946, -- Coastal Surge
    [255105] = 5946, -- Coastal Surge
    [255110] = 5948, -- Siphoning
    [255111] = 5948, -- Siphoning
    [255112] = 5948, -- Siphoning
    [255129] = 5949, -- Torrent of Elements
    [255130] = 5949, -- Torrent of Elements
    [255131] = 5949, -- Torrent of Elements
    [255141] = 5950, -- Gale-Force Striking
    [255142] = 5950, -- Gale-Force Striking
    [255143] = 5950, -- Gale-Force Striking
    [255936] = 5952, -- Belt Enchant: Holographic Horror Projector
    [255940] = 5953, -- Belt Enchant: Personal Space Amplifier
    [264877] = 5955, -- Crow's Nest Scope
    [264959] = 5956, -- Monelite Scope of Alacrity
    [264762] = 5957, -- Incendiary Ammunition
    [265095] = 5958, -- Frost-Laced Ammunition
    [267554] = 5960, -- _JKL - Item Enchantment Test
    [268852] = 5962, -- Versatile Navigation
    [268878] = 5962, -- Versatile Navigation
    [268879] = 5962, -- Versatile Navigation
    [268894] = 5963, -- Quick Navigation
    [268895] = 5963, -- Quick Navigation
    [268897] = 5963, -- Quick Navigation
    [268901] = 5964, -- Masterful Navigation
    [268902] = 5964, -- Masterful Navigation
    [268903] = 5964, -- Masterful Navigation
    [268907] = 5965, -- Deadly Navigation
    [268908] = 5965, -- Deadly Navigation
    [268909] = 5965, -- Deadly Navigation
    [268913] = 5966, -- Stalwart Navigation
    [268914] = 5966, -- Stalwart Navigation
    [268915] = 5966, -- Stalwart Navigation
    [269123] = 5967, -- Belt Enchant: Miniaturized Plasma Shield
    [271277] = 5969, -- QA Visual Debug Enchant
    [271366] = 5970, -- Safe Hearthing
    [271433] = 5971, -- Cooled Hearthing
    [279182] = 6087, -- Resilient Spellthread
    [310948] = 6087, -- Spellthread Enchant 03
    [279183] = 6088, -- Discreet Spellthread
    [310946] = 6088, -- Spellthread Enchant 01
    [279184] = 6089, -- Feathery Spellthread
    [310947] = 6089, -- Spellthread Enchant 02
    [298009] = 6108, -- Accord of Critical Strike
    [298010] = 6108, -- Accord of Critical Strike
    [298011] = 6108, -- Accord of Critical Strike
    [297989] = 6109, -- Accord of Haste
    [297994] = 6109, -- Accord of Haste
    [298016] = 6109, -- Accord of Haste
    [297995] = 6110, -- Accord of Mastery
    [298001] = 6110, -- Accord of Mastery
    [298002] = 6110, -- Accord of Mastery
    [297991] = 6111, -- Accord of Versatility
    [297993] = 6111, -- Accord of Versatility
    [297999] = 6111, -- Accord of Versatility
    [298433] = 6112, -- Machinist's Brilliance
    [300769] = 6112, -- Machinist's Brilliance
    [300770] = 6112, -- Machinist's Brilliance
    [298439] = 6148, -- Force Multiplier
    [298440] = 6148, -- Force Multiplier
    [300788] = 6148, -- Force Multiplier
    [298437] = 6149, -- Oceanic Restoration
    [298438] = 6149, -- Oceanic Restoration
    [298515] = 6149, -- Oceanic Restoration
    [298441] = 6150, -- Naga Hide
    [298442] = 6150, -- Naga Hide
    [300789] = 6150, -- Naga Hide
    [307414] = 6158, -- LUIS TEST - Enchant
    [308398] = 6162, -- LUIS TEST - Enchant - Base Visual
    [308725] = 6162, -- Illusion: Wraithchill
    [309612] = 6163, -- Bargain of Critical Strike
    [309616] = 6164, -- Tenet of Critical Strike
    [309613] = 6165, -- Bargain of Haste
    [309617] = 6166, -- Tenet of Haste
    [309614] = 6167, -- Bargain of Mastery
    [309618] = 6168, -- Tenet of Mastery
    [309615] = 6169, -- Bargain of Versatility
    [309619] = 6170, -- Tenet of Versatility
    [307418] = 6186, -- Enchant Visual - Test - LIA
    [310495] = 6192, -- Dimensional Shifter
    [310496] = 6193, -- Electro-Jump
    [310497] = 6194, -- Damage Retaliator
    [321535] = 6195, -- Infra-green Reflex Sight
    [321536] = 6196, -- Optical Target Embiggener
    [309528] = 6202, -- Fortified Speed
    [309530] = 6203, -- Fortified Avoidance
    [309531] = 6204, -- Fortified Leech
    [309524] = 6205, -- Shadowlands Gathering
    [323609] = 6207, -- Soul Treads
    [323755] = 6208, -- Soul Vitality
    [309525] = 6209, -- Strength of Soul
    [309526] = 6210, -- Eternal Strength
    [309534] = 6211, -- Eternal Agility
    [309532] = 6212, -- Agile Soulwalker
    [309535] = 6213, -- Eternal Bulwark
    [323760] = 6214, -- Eternal Skirmish
    [323762] = 6216, -- Sacred Stats
    [323761] = 6217, -- Eternal Bounds
    [309608] = 6219, -- Illuminated Soul
    [309609] = 6220, -- Eternal Intellect
    [309610] = 6222, -- Shaded Hearthing
    [309620] = 6223, -- Lightless Force
    [309621] = 6226, -- Eternal Grace
    [309622] = 6227, -- Ascended Vigor
    [309623] = 6228, -- Sinful Revelation
    [309627] = 6229, -- Celestial Guidance
    [324773] = 6230, -- Eternal Stats
    [326805] = 6241, -- Rune of Sanguination
    [326855] = 6242, -- Rune of Spellwarding
    [326911] = 6243, -- Rune of Hysteria
    [326977] = 6244, -- Rune of Unending Thirst
    [327082] = 6245, -- Rune of the Apocalypse
    [330504] = 6246, -- Kali - Test Enchant Weapons
    [331680] = 6248, -- Enchant Visual - Test - GGO
    [342316] = 6265, -- Eternal Insight
    [359584] = 6347, -- JDP - Test - Enchants
    [322354] = 6349, -- FX Test Enchant - High
    [323326] = 6350, -- FX Test Enchant - Low
    [376822] = 6488, -- Apply Fierce Armor Kit
    [376844] = 6489, -- Apply Fierce Armor Kit
    [376848] = 6490, -- Apply Fierce Armor Kit
    [376839] = 6491, -- Apply Reinforced Armor Kit
    [376843] = 6492, -- Apply Reinforced Armor Kit
    [376849] = 6493, -- Apply Reinforced Armor Kit
    [376819] = 6494, -- Apply Frosted Armor Kit
    [376845] = 6495, -- Apply Frosted Armor Kit
    [376847] = 6496, -- Apply Frosted Armor Kit
    [385766] = 6520, -- Apply Gyroscopic Kaleidoscope
    [385768] = 6521, -- Apply Gyroscopic Kaleidoscope
    [385770] = 6522, -- Apply Gyroscopic Kaleidoscope
    [385772] = 6523, -- Apply Projectile Propulsion Pinion
    [385773] = 6524, -- Apply Projectile Propulsion Pinion
    [385775] = 6525, -- Projectile Propulsion Pinion
    [386152] = 6526, -- High Intensity Thermal Scanner
    [386153] = 6527, -- High Intensity Thermal Scanner
    [386154] = 6528, -- High Intensity Thermal Scanner
    [387284] = 6536, -- Vibrant Spellthread
    [387285] = 6537, -- Vibrant Spellthread
    [387286] = 6538, -- Vibrant Spellthread
    [387291] = 6539, -- Frozen Spellthread
    [387293] = 6540, -- Frozen Spellthread
    [387294] = 6541, -- Frozen Spellthread
    [387295] = 6542, -- Temporal Spellthread
    [387296] = 6543, -- Temporal Spellthread
    [387298] = 6544, -- Temporal Spellthread
    [400122] = 6721, -- 10.0.5 - Generic - Storm - Weapon Enchant - High
    [398623] = 6818, -- FX Testing - Enchant Visual - Sarah King [DNT]
    [406295] = 6828, -- Apply Lambent Armor Kit
    [406298] = 6829, -- Apply Lambent Armor Kit
    [406299] = 6830, -- Apply Lambent Armor Kit
    [411897] = 6904, -- Apply Shadowed Belt Clasp
    [411898] = 6905, -- Apply Shadowed Belt Clasp
    [411899] = 6906, -- Apply Shadowed Belt Clasp
    [426327] = 7052, -- Incandescent Essence
    [441296] = 7282, -- Inscribe Pickaxe
    [445445] = 7320, -- Test Enchant - MM
    [446284] = 7323, -- 10FX - Weapon Enchant - Sha - All Weapons
    [455829] = 7526, -- Algari Weaverline
    [457618] = 7529, -- Daybreak Spellthread
    [457619] = 7530, -- Daybreak Spellthread
    [457620] = 7531, -- Daybreak Spellthread
    [457621] = 7532, -- Sunset Spellthread
    [457622] = 7533, -- Sunset Spellthread
    [457623] = 7534, -- Sunset Spellthread
    [457624] = 7535, -- Weavercloth Spellthread
    [457625] = 7536, -- Weavercloth Spellthread
    [457626] = 7537, -- Weavercloth Spellthread
    [451826] = 7593, -- Apply Defender's Armor Kit
    [451827] = 7594, -- Apply Defender's Armor Kit
    [451828] = 7595, -- Apply Defender's Armor Kit
    [451829] = 7596, -- Apply Dual Layered Armor Kit
    [451830] = 7597, -- Apply Dual Layered Armor Kit
    [451831] = 7598, -- Apply Dual Layered Armor Kit
    [451821] = 7599, -- Apply Stormbound Armor Kit
    [451824] = 7600, -- Apply Stormbound Armor Kit
    [451825] = 7601, -- Apply Stormbound Armor Kit
    [1216517] = 7652, -- Apply Charged Armor Kit
    [1216518] = 7653, -- Apply Charged Armor Kit
    [1216519] = 7654, -- Apply Charged Armor Kit
}

local itemChangedData = {}
function frame:ITEM_CHANGED(previousHyperlink, newHyperlink)
    itemChangedData[1], itemChangedData[2] = previousHyperlink, newHyperlink
end
local appliedEnchantID
function frame:UNIT_SPELLCAST_SUCCEEDED(unit, castID, spellID)
    if spellID == 358498 then -- Remove Domination Gem
        Internal.CastedSoulFireChisel()
        return
    end
    appliedEnchantID = enchantBySpellID[spellID]
    if not appliedEnchantID then
        return
    end
end
function frame:BAG_UPDATE_DELAYED()
    Internal.RemovedDominationGem()
    Internal.GemApplied()
    if itemChangedData[1] then
        Internal.RuneforgeItemUpdated(unpack(itemChangedData))
        wipe(itemChangedData)
    end
    if appliedEnchantID then
        Internal.EnchantApplied(appliedEnchantID)
        appliedEnchantID = nil
    end
end
function frame:UNIT_INVENTORY_CHANGED()
    Internal.RemovedDominationGem()
    Internal.GemApplied()
    if itemChangedData[1] then
        Internal.RuneforgeItemUpdated(unpack(itemChangedData))
        wipe(itemChangedData)
    end
    if appliedEnchantID then
        Internal.EnchantApplied(appliedEnchantID)
        appliedEnchantID = nil
    end
end
function frame:SOCKET_INFO_SUCCESS(...)
    Internal.GemApplied()
end
function frame:TRAIT_CONFIG_CREATED(configInfo)
    self:TRAIT_CONFIG_UPDATED(configInfo.ID)
end
function frame:TRAIT_CONFIG_UPDATED(configID)
    local activeConfigID = C_ClassTalents.GetActiveConfigID();
    if activeConfigID == configID then
        return;
    end

    -- Prevent adding trait trees that arent for the current spec
    local specID = GetSpecializationInfo(GetSpecialization());
    local tree = Internal.GetTreeInfoBySpecID(specID);
    
    local validConfigIDs = C_ClassTalents.GetConfigIDsBySpecID(specID);
    if not tContains(validConfigIDs, configID) then
        return
    end

    local configInfo = C_Traits.GetConfigInfo(configID);
    if not configInfo or configInfo.treeIDs[1] ~= tree.ID or configInfo.type ~= 1 then
        return
    end

    local set = dfTalentTreeSetMap[configID];
    if not set then
        set = Internal.AddSet("dftalents", {
            name = "",
            useCount = 0,
        })
        dfTalentTreeSetMap[configID] = set;
    end

    Internal.RefreshSetFromConfigID(set, configID)
end
function frame:TRAIT_CONFIG_DELETED(configID)
    local set = dfTalentTreeSetMap[configID]
    if set then
--[==[@debug@
        print(format(L["[BtWLoadouts]: Unflagged talent loadout \"%s\" as a blizzard talent tree."], set.name));
--@end-debug@]==]

        -- If the set is in use we disconnect it from the Blizzard manager
        -- otherwise we delete it
        if set.useCount > 0 then
            set.configID = nil;
            set.character = nil;
        else
            Internal.DeleteSet(BtWLoadoutsSets.dftalents, set);
        end

        -- Clear map
        dfTalentTreeSetMap[configID] = nil;
    end
end
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("CONSOLE_MESSAGE");
frame:RegisterEvent("EQUIPMENT_SETS_CHANGED");
frame:RegisterEvent("BANKFRAME_OPENED");
frame:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED");
frame:RegisterEvent("UPDATE_INSTANCE_INFO");
frame:RegisterEvent("ZONE_CHANGED");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED");
frame:RegisterEvent("PLAYER_TARGET_CHANGED");
frame:RegisterEvent("ENCOUNTER_END");
frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
frame:RegisterEvent("BAG_UPDATE_DELAYED");
frame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player");
frame:RegisterEvent("SOCKET_INFO_SUCCESS");
frame:RegisterEvent("ITEM_CHANGED");
frame:RegisterEvent("TRAIT_CONFIG_CREATED");
frame:RegisterEvent("TRAIT_CONFIG_UPDATED");
frame:RegisterEvent("TRAIT_CONFIG_DELETED");
