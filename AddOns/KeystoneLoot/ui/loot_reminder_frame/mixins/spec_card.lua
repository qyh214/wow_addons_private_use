local AddonName, KeystoneLoot = ...;

local Character               = KeystoneLoot.Character;
local L                       = KeystoneLoot.L;

-- Blizzard_PlayerSpells\ClassSpecializations\Blizzard_ClassSpecializationsFrame.lua
local SPEC_THUMBNAILS         = {
    [62] = "mage-arcane",
    [63] = "mage-fire",
    [64] = "mage-frost",
    [65] = "paladin-holy",
    [66] = "paladin-protection",
    [70] = "paladin-retribution",
    [71] = "warrior-arms",
    [72] = "warrior-fury",
    [73] = "warrior-protection",
    [102] = "druid-balance",
    [103] = "druid-feral",
    [104] = "druid-guardian",
    [105] = "druid-restoration",
    [250] = "deathknight-blood",
    [251] = "deathknight-frost",
    [252] = "deathknight-unholy",
    [253] = "hunter-beastmastery",
    [254] = "hunter-marksmanship",
    [255] = "hunter-survival",
    [256] = "priest-discipline",
    [257] = "priest-holy",
    [258] = "priest-shadow",
    [259] = "rogue-assassination",
    [260] = "rogue-outlaw",
    [261] = "rogue-subtlety",
    [262] = "shaman-elemental",
    [263] = "shaman-enhancement",
    [264] = "shaman-restoration",
    [265] = "warlock-affliction",
    [266] = "warlock-demonology",
    [267] = "warlock-destruction",
    [268] = "monk-brewmaster",
    [269] = "monk-windwalker",
    [270] = "monk-mistweaver",
    [577] = "demonhunter-havoc",
    [581] = "demonhunter-vengeance",
    [1467] = "evoker-devastation",
    [1468] = "evoker-preservation",
    [1473] = "evoker-augmentation",
    [1480] = "demonhunter-devourer"
}

local MAX_ICONS_PER_SPEC      = 8;
local ICONS_PER_ROW           = 4;
local ICON_SPACING_X          = 10;
local ICON_SPACING_Y          = 8;
local ICON_PADDING_X          = 11;
local ICON_PADDING_Y          = 10;

KeystoneLootReminderSpecMixin = {};

function KeystoneLootReminderSpecMixin:OnLoad()
    self.iconPool = CreateFramePool("Button", self, "KeystoneLootReminderIconTemplate");
end

function KeystoneLootReminderSpecMixin:Init(displaySpecId, favoSpecId, items, lootSpecId, allSpecItems)
    self.specId = displaySpecId;

    local specName = Character:GetSpecName(displaySpecId);
    self.Title:SetText(specName);

    self.Bg:SetHorizTile(false);
    self.Bg:SetVertTile(false);
    self.Bg:SetAtlas(string.format("spec-thumbnail-%s", SPEC_THUMBNAILS[displaySpecId] or "mage-arcane"));

    if (displaySpecId ~= favoSpecId) then
        local displayName = Character:GetSpecName(displaySpecId);
        local favoName = Character:GetSpecName(favoSpecId);
        self.LootSpecButton.EfficiencyIcon.tooltipText = string.format(L["%s has a smaller loot pool than %s"], HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(displayName), HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(favoName));
        self.LootSpecButton.EfficiencyIcon:Show();
    else
        self.LootSpecButton.EfficiencyIcon:Hide();
    end

    self:UpdateLootSpec(lootSpecId);
    self:SetIcons(items, allSpecItems);
end

function KeystoneLootReminderSpecMixin:SetIcons(items, allSpecItems)
    self.iconPool:ReleaseAll();

    local LastIcon = nil;
    local LastRowFirstIcon = nil;

    for i = 1, math.min(#items, MAX_ICONS_PER_SPEC) do
        local item = items[i];
        local Icon = self.iconPool:Acquire();
        local col = (i - 1) % ICONS_PER_ROW;
        local row = math.floor((i - 1) / ICONS_PER_ROW);

        Icon:ClearAllPoints();
        if (row == 0 and col == 0) then
            Icon:SetPoint("TOPLEFT", ICON_PADDING_X, -ICON_PADDING_Y);
            LastRowFirstIcon = Icon;
        elseif (col == 0) then
            Icon:SetPoint("TOPLEFT", LastRowFirstIcon, "BOTTOMLEFT", 0, -ICON_SPACING_Y);
            LastRowFirstIcon = Icon;
        else
            Icon:SetPoint("LEFT", LastIcon, "RIGHT", ICON_SPACING_X, 0);
        end

        Icon:Init(item.itemId, item.icon, allSpecItems[item.itemId] ~= nil);
        LastIcon = Icon;
    end
end

function KeystoneLootReminderSpecMixin:UpdateLootSpec(lootSpecId)
    local isActive = self.specId == lootSpecId;
    self.LootSpecButton:SetShown(not isActive);
    self.ActiveText:SetShown(isActive);
end
