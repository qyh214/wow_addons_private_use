local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;
local Query = KeystoneLoot.Query;

KeystoneLootDungeonsFrameMixin = {};

function KeystoneLootDungeonsFrameMixin:OnLoad()
    self.Inset.Bg:SetAlpha(0.75);
    self.Inset.Bg:SetAtlas("UI-Frame-Dragonflight-BackgroundTile");

    self.entryPool = CreateFramePool("Frame", self.Container, "KeystoneLootEntryFrameTemplate");
end

function KeystoneLootDungeonsFrameMixin:Init()
    local function OnChanged()
        if (not self:IsShown()) then
            return;
        end

        self:Refresh();
    end

    DB:AddObserver("filters.specId", OnChanged);
    DB:AddObserver("filters.slotId", OnChanged);
    DB:AddObserver("ui.selectedCharacterKey", OnChanged);
    DB:AddObserver("ui.selectedTab", OnChanged);
    DB:AddObserver("settings.highlighting.*", OnChanged);
    DB:AddObserver("settings.wideMode", OnChanged);

    self:Refresh();
end

function KeystoneLootDungeonsFrameMixin:RefreshSize()
    local Parent = self:GetParent();
    if (Parent.dungeonsTabId) then
        Parent:RefreshSize(Parent.dungeonsTabId);
    end
end

function KeystoneLootDungeonsFrameMixin:OnShow()
    -- Update cooldowns for teleport buttons in case they were on cooldown when the frame was hidden.
    for Frame in self.entryPool:EnumerateActive() do
        Frame.TeleportButton:UpdateCooldown();
    end
end

function KeystoneLootDungeonsFrameMixin:Refresh()
    self.entryPool:ReleaseAll();

    self:SetWidth(DB:Get("settings.wideMode") and 728 or 500);

    local height = 0;
    height = height + 60; -- margin top
    height = height + 4;  -- padding top

    local dungeons = Query:GetDungeons();
    local numDungeons = #dungeons;

    for index = 1, numDungeons do
        local dungeon = dungeons[index];
        local isLastEntry = index == numDungeons;
        local lootTable = Query:GetDungeonItems(dungeon.challengeModeId);

        height = height + (not isLastEntry and 54 or 53); -- entry height

        local Frame = self.entryPool:Acquire();
        Frame:Init(index, dungeon, lootTable, isLastEntry);
        Frame:Show();
    end

    height = height + 4;  -- padding bottom
    height = height + 24; -- margin bottom

    self:SetHeight(height);
    self.Container:Layout();
    self:RefreshSize();
end
