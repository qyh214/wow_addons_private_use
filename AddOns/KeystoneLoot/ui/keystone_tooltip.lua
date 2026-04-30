local AddonName, KeystoneLoot = ...;

local Keystone = KeystoneLoot.Keystone;
local DB = KeystoneLoot.DB;
local L = KeystoneLoot.L;

local function OnTooltipSetItem(tooltip)
    -- GameTooltip and ItemRefTooltip only
    if (tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip) then
        return;
    end

    -- Check if feature is enabled
    if (not DB:Get("settings.keystoneTooltip")) then
        return;
    end

    -- Get item link from tooltip
    local _, itemLink = tooltip:GetItem();
    if (not itemLink) then
        return;
    end

    -- Extract keystone level from item link
    -- New format: keystone:180653:2:378:10:9:160:0
    local keystoneLevel = tonumber(itemLink:match("keystone:%d+:%d+:(%d+)"));

    -- Old format fallback: item:180653:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10
    if (not keystoneLevel) then
        keystoneLevel = tonumber(itemLink:match("item:180653:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:(%d+)"));
    end

    if (not keystoneLevel) then
        return;
    end

    -- Get rewards from Keystone module
    local rewards = Keystone:GetRewards(keystoneLevel);
    if (not rewards) then
        return;
    end

    -- Add to tooltip
    tooltip:AddLine(" ");
    tooltip:AddLine("|cff9d5db8KeystoneLoot|r");
    tooltip:AddDoubleLine(
        LOOT,
        rewards.endOfRun.level .. " (" .. rewards.endOfRun.rank .. ")",
        1, 1, 1,
        1, 1, 1
    );
    tooltip:AddDoubleLine(
        L["Great Vault"],
        rewards.greatVault.level .. " (" .. rewards.greatVault.rank .. ")",
        1, 1, 1,
        1, 1, 1
    );
    tooltip:Show();
end

-- Register tooltip hook
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem);
