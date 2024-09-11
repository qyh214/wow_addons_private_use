local AddonName, KeystoneLoot = ...;


function KeystoneLoot:GetSeasonId()
	return 13; -- 13 = TWW Season 1
end


local _slotList = { INVTYPE_HEAD, INVTYPE_NECK, INVTYPE_SHOULDER, INVTYPE_CLOAK, INVTYPE_CHEST, INVTYPE_WRIST, INVTYPE_HAND, INVTYPE_WAIST, INVTYPE_LEGS, INVTYPE_FEET, INVTYPE_WEAPONMAINHAND, INVTYPE_WEAPONOFFHAND, INVTYPE_FINGER, INVTYPE_TRINKET, EJ_LOOT_SLOT_FILTER_OTHER }
function KeystoneLoot:GetSlotList()
	return _slotList;
end


SlashCmdList.KEYSTONELOOT = function(msg)
	local OverviewFrame = KeystoneLoot:GetOverview();
	OverviewFrame:SetShown(not OverviewFrame:IsShown());
end;

SLASH_KEYSTONELOOT1 = "/ksl";
SLASH_KEYSTONELOOT2 = "/keyloot";
SLASH_KEYSTONELOOT3 = "/keystoneloot";


local function OnEvent(self, event, ...)
	self:UnregisterEvent(event);

	KeystoneLoot:CheckDB();
	KeystoneLoot:CheckCharacterDB();

	KeystoneLoot:UpdateMinimapButton();
	KeystoneLoot:UpdateUpgradeTooltip();
end

local handler = CreateFrame('Frame');
handler:RegisterEvent('PLAYER_ENTERING_WORLD');
handler:SetScript('OnEvent', OnEvent);