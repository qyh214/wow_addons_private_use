local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;

local GameTooltip = GameTooltip;
local ItemRefTooltip = ItemRefTooltip;


local function OnTooltipSetItem(tooltip)
	if ((tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip) or not KeystoneLootDB.keystoneItemLevelEnabled) then
		return;
	end

	local _, itemLink = tooltip:GetItem();
	if (not itemLink) then
		return;
	end

	local keystoneLevel = tonumber(itemLink:match('keystone:%d+:%d+:(%d+)'));
	if (not keystoneLevel) then
		keystoneLevel = tonumber(itemLink:match('item:180653:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:(%d+)'));
	end

	if (not keystoneLevel) then
		return;
	end

	local data = KeystoneLoot:GetKeystoneItemLevels(keystoneLevel);
	if (not data) then
		return;
	end

	tooltip:AddLine('|n'..AddonName);
	tooltip:AddDoubleLine(LOOT, data.endOfRun.level..' ('..Translate[data.endOfRun.text]..')', 1, 1, 1, 1, 1, 1);
	tooltip:AddDoubleLine(Translate['Great Vault'], data.greatVault.level..' ('..Translate[data.greatVault.text]..')', 1, 1, 1, 1, 1, 1);
	tooltip:Show();
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem);