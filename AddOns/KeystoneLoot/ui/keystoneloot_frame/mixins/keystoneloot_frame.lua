local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;
local Favorites = KeystoneLoot.Favorites;
local Character = KeystoneLoot.Character;
local L = KeystoneLoot.L;

KeystoneLootFrameMixin = {};

function KeystoneLootFrameMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
    self:RegisterForDrag("LeftButton");

    CallbackRegistryMixin.OnLoad(self);
    TabSystemOwnerMixin.OnLoad(self);

    self:SetPortraitToAsset("Interface\\Icons\\INV_Relics_Hourglass_02");
    self:SetTitle(string.format(L['%s (%s Season %d)'], AddonName, KeystoneLoot.Config.expansionName, KeystoneLoot.Config.seasonNumber));

    table.insert(UISpecialFrames, self:GetName());
end

function KeystoneLootFrameMixin:InitializeTabSystem()
    self:SetTabSystem(self.TabSystem);

    self.DungeonsFrame = CreateFrame("Frame", nil, self, "KeystoneLootDungeonsFrameTemplate");
    self.DungeonsFrame:Init();
    self.dungeonsTabId = self:AddNamedTab(DUNGEONS, self.DungeonsFrame);

    self.RaidsFrame = CreateFrame("Frame", nil, self, "KeystoneLootRaidsFrameTemplate");
    self.RaidsFrame:Init();
    self.raidsTabId = self:AddNamedTab(RAIDS, self.RaidsFrame);

    self:SetTab(self.dungeonsTabId);
end

function KeystoneLootFrameMixin:OnEvent(event)
    if (event == "ACTIVE_TALENT_GROUP_CHANGED") then
        self:SyncSpecFilter();
        return;
    end

    self:UnregisterEvent("PLAYER_ENTERING_WORLD");

    DB:Init();
    Favorites:Init();

    self:SyncSpecFilter();

    self:InitializeTabSystem();

    self.ClassDropdown:Init();
    self.SlotDropdown:Init();
    self.ItemLevelDropdown:Init();
    self.CharacterDropdown:Init();
    self.SettingsDropdown:Init();
    self.CatalystFrame:Init();
    KeystoneLootMinimapButton:Init();
end

function KeystoneLootFrameMixin:SyncSpecFilter()
    local currentClassId = Character:GetCurrentClassId();
    local currentSpecId = Character:GetCurrentSpecId();

    if (DB:Get("filters.classId") == currentClassId) then
        DB:Set("filters.classId", currentClassId);
        DB:Set("filters.specId", currentSpecId);
    end
end

function KeystoneLootFrameMixin:SetTab(tabId)
    TabSystemOwnerMixin.SetTab(self, tabId);

    local tabName = self:GetTabName(tabId);
    DB:Set("ui.selectedTab", tabName);

    self:RefreshSize(tabId);
end

function KeystoneLootFrameMixin:OnShow()
    PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
end

function KeystoneLootFrameMixin:OnHide()
    PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
end

function KeystoneLootFrameMixin:OnDragStart()
    self:StartMoving();
    self:SetUserPlaced(true);
end

function KeystoneLootFrameMixin:OnDragStop()
    self:StopMovingOrSizing();
end

function KeystoneLootFrameMixin:RefreshSize(tabId)
    local Frame = self:GetElementsForTab(tabId)[1];
    self:SetSize(Frame:GetSize());
end

function KeystoneLootFrameMixin:GetTabName(tabId)
    if (tabId == self.dungeonsTabId) then
        return "dungeons";
    elseif (tabId == self.raidsTabId) then
        return "raids";
    end

    return "dungeons"; -- Fallback
end
