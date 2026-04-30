local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;

KeystoneLootEntryFrameMixin = {};

function KeystoneLootEntryFrameMixin:OnLoad()
    local top, bottom, left, right, spacing = 0, 0, 6, 6, 10;
    local view = CreateScrollBoxListLinearView(top, bottom, left, right, spacing);

    view:SetVirtualized(false);
    view:SetHorizontal(true);
    view:SetElementExtent(28);
    view:SetElementInitializer("KeystoneLootLootIconButtonTemplate", function(Button, itemId)
        Button:Init(itemId);
    end);

    self.IconScrollBox:Init(view);
    self.IconScrollBox:RegisterCallback(BaseScrollBoxEvents.OnScroll, self.OnScroll, self);

    self.BackButton.Pulse:Play();
    self.NextButton.Pulse:Play();
end

function KeystoneLootEntryFrameMixin:OnScroll(offset)
    local hasScrollableExtent = self.IconScrollBox:HasScrollableExtent();
    local showLeft = hasScrollableExtent and offset > ScrollBoxConstants.ScrollBegin;
    local showRight = hasScrollableExtent and offset < ScrollBoxConstants.ScrollEnd;

    self.BackButton:SetShown(showLeft);
    self.NextButton:SetShown(showRight);
end

function KeystoneLootEntryFrameMixin:Init(index, instance, lootTable, isLastEntry)
    local name, texture;

    if (instance.bossId) then
        name = EJ_GetEncounterInfo(instance.bossId);
        local _, _, _, creatureDisplayID = EJ_GetCreatureInfo(1, instance.bossId);
        SetPortraitTextureFromCreatureDisplayID(self.TeleportButton.Icon, creatureDisplayID);
    else
        name, _, _, texture = C_ChallengeMode.GetMapUIInfo(instance.challengeModeId);
        self.TeleportButton:Init(instance, texture);
        self.DungeonBG:SetTexture(instance.bgTexture);
    end

    self.layoutIndex = index;
    self.Text:SetText(name);
    self.Background:SetShown(index % 2 == 0);
    self.Divider:SetShown(not isLastEntry);

    -- Dimming if no loot
    if (#lootTable == 0) then
        self.Text:SetTextColor(GRAY_FONT_COLOR:GetRGB());
        self.Text:SetAlpha(0.8);
        self.IconScrollBox:SetAlpha(0.5);
        self.DungeonBG:SetDesaturated(true);
    else
        self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
        self.Text:SetAlpha(1);
        self.IconScrollBox:SetAlpha(1);
        self.DungeonBG:SetDesaturated(false);
    end

    -- Resize for wide mode (12 slots) or normal mode (6 slots)
    local wideMode = DB:Get("settings.wideMode");
    local numSlots = wideMode and 12 or 6;

    self:SetWidth(wideMode and 714 or 486);
    self.IconScrollBox:SetWidth(wideMode and 458 or 230);
    self.Divider:SetWidth(wideMode and 688 or 460);

    -- Adds fake entries to always fill all slots
    local dataProvider = CreateDataProvider();
    for i = #lootTable, numSlots - 1 do
        table.insert(lootTable, { itemId = 0 });
    end

    dataProvider:InsertTable(lootTable);
    self.IconScrollBox:SetDataProvider(dataProvider);
end
