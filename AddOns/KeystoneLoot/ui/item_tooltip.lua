local AddonName, KeystoneLoot = ...;

local Favorites = KeystoneLoot.Favorites;
local DB = KeystoneLoot.DB;
local Query = KeystoneLoot.Query;
local Character = KeystoneLoot.Character;

local function GetSourceInfo(itemId)
    -- Check catalyst first — no tooltip for catalyst items
    if (KeystoneLoot.CatalystDatabase[itemId]) then
        return;
    end

    -- Check dungeons
    for _, dungeon in ipairs(Query:GetDungeons()) do
        for _, lootItemId in ipairs(dungeon.lootTable) do
            if (lootItemId == itemId) then
                local name = C_ChallengeMode.GetMapUIInfo(dungeon.challengeModeId);
                return {
                    type = "dungeon",
                    name = name,
                    instanceId = dungeon.instanceId,
                };
            end
        end
    end

    -- Check raids
    for _, raid in ipairs(Query:GetRaids()) do
        for _, boss in ipairs(raid.bossList) do
            for _, lootTable in pairs(boss.lootTable) do
                for _, lootItemId in ipairs(lootTable) do
                    if (lootItemId == itemId) then
                        local bossName = EJ_GetEncounterInfo(boss.bossId);
                        local raidName = EJ_GetInstanceInfo(raid.journalInstanceId);
                        return {
                            type = "raid",
                            name = raidName,
                            bossName = bossName,
                            instanceId = raid.instanceId,
                        };
                    end
                end
            end
        end
    end
end

local function OnTooltipSetItem(tooltip)
    -- GameTooltip and ItemRefTooltip only
    if (tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip) then
        return;
    end

    -- Check if feature is enabled
    if (not DB:Get("settings.favoriteTooltip")) then
        return;
    end

    if (tooltip.KeystoneLootOwned) then
        return;
    end

    -- Get item link from tooltip
    local _, itemLink = tooltip:GetItem();
    if (not itemLink) then
        return;
    end

    local itemId = tonumber(itemLink:match("item:(%d+)"));
    if (not itemId) then
        return;
    end

    -- Catalyst items: no tooltip
    if (KeystoneLoot.CatalystDatabase[itemId]) then
        return;
    end

    local tier = Favorites:GetAnyTier(itemId, true);
    if (tier == 0) then
        return;
    end

    local sourceInfo = GetSourceInfo(itemId);
    if (not sourceInfo) then
        return;
    end

    -- Get specs for item
    local specs = Favorites:GetItemSpecs(itemId, true);
    local classId = Character:GetCurrentClassId();
    local totalSpecs = C_SpecializationInfo.GetNumSpecializationsForClassID(classId);
    local specText, sourceName;

    if (#specs >= totalSpecs) then
        specText = ALL_SPECS;
    else
        local specNames = {};
        for _, specId in ipairs(specs) do
            local name = Character:GetSpecName(specId);
            if (name ~= "") then
                table.insert(specNames, name);
            end
        end
        specText = table.concat(specNames, " / ");
    end

    if (sourceInfo.type == "dungeon") then
        sourceName = "|A:questlog-questtypeicon-dungeon:16:16:0:0|a " .. sourceInfo.name;
    elseif (sourceInfo.type == "raid") then
        sourceName = "|A:questlog-questtypeicon-raid:16:16:0:0|a " .. string.format("%s - %s", sourceInfo.name, sourceInfo.bossName);
    end

    -- Check if player is currently in the correct instance
    local _, _, _, _, _, _, _, currentInstanceId = GetInstanceInfo();
    local inCorrectInstance = currentInstanceId == sourceInfo.instanceId;

    tooltip:AddLine(" ");
    tooltip:AddLine("|cff9d5db8KeystoneLoot|r");
    tooltip:AddLine(string.format("|T%s:16:16|t %s (%s)", Favorites.TIER_TEXTURE[tier], Favorites.TIER_NAME[tier], specText));

    if (not inCorrectInstance) then
        tooltip:AddLine(sourceName);
    end

    tooltip:Show();
end

-- Register tooltip hook
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem);
