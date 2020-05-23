if not (GetLocale() == "ruRU") then
    return;
end

local L = Narci.L

L["Heritage Armor"] = "Традиционные Доспехи";
ITEMSOURCE_SECRETFINDING = "Секретная";

NARCI_ALIAS_USE_ALIAS = "Псевдони́м";
NARCI_ALIAS_USE_PLAYER_NAME = CALENDAR_PLAYER_NAME;

L["Minimap Tooltip Middle Button"] = "|CFFFF1000Middle button |cffffffffСбросить камеру";

NARCI_STAT_STRENGTH = "Сила";
NARCI_STAT_AGILITY = "Ловкость";
NARCI_STAT_INTELLECT = "Интеллект";

--Model Control--
NARCI_GROUP_PHOTO = "Групповое Фото";
NARCI_GROUP_PHOTO_NOTIFICATION = "Пожалуйста, выберите игрока.";

--NPC Browser--
NARCI_NPC_BROWSER_TITLE_LEVEL = "%?.*";      --Level ?? --Use this to check if the second line of the tooltip is NPC's title or unit type 