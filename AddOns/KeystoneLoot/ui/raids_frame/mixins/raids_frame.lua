local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;
local Query = KeystoneLoot.Query;

KeystoneLootRaidsFrameMixin = {};

function KeystoneLootRaidsFrameMixin:OnLoad()
    self.blockPool = CreateFramePool("Frame", self, "KeystoneLootRaidBlockTemplate");
end

function KeystoneLootRaidsFrameMixin:RefreshSize()
    local Parent = self:GetParent();
    if (Parent.raidsTabId) then
        Parent:RefreshSize(Parent.raidsTabId);
    end
end

function KeystoneLootRaidsFrameMixin:SetRaid(raid)
    self.currentRaid = raid;
    self.blockPool:ReleaseAll();

    self:SetWidth(DB:Get("settings.wideMode") and 728 or 500);

    local Block = self.blockPool:Acquire();
    Block.RaidIcon:Hide();
    Block:ClearAllPoints();
    Block:SetPoint("TOPLEFT", 0, -80);
    Block:SetRaid(raid);
    Block:Show();

    self:SetHeight(80 + Block:GetHeight());
    self:RefreshSize();
end

function KeystoneLootRaidsFrameMixin:SetAllRaids(raids)
    self.blockPool:ReleaseAll();

    self:SetWidth(DB:Get("settings.wideMode") and 728 or 500);

    local totalHeight = 80; -- space above first block
    local PrevBlock = nil;

    for _, raid in ipairs(raids) do
        local Block = self.blockPool:Acquire();
        local raidName = EJ_GetInstanceInfo(raid.journalInstanceId);

        Block:SetTitle(raidName);
        Block:SetRaid(raid);
        Block:ClearAllPoints();

        if (PrevBlock) then
            Block:SetPoint("TOPLEFT", PrevBlock, "BOTTOMLEFT");
        else
            Block:SetPoint("TOPLEFT", 0, -80);
        end

        Block:Show();

        totalHeight = totalHeight + Block:GetHeight();
        PrevBlock = Block;
    end

    self:SetHeight(totalHeight);
    self:RefreshSize();
end

function KeystoneLootRaidsFrameMixin:Init()
    local raids = Query:GetRaids();

    local stackedMode = Query:GetTotalRaidBosses() <= 10;

    local function OnChanged()
        if (not self:IsShown()) then
            return;
        end

        if (stackedMode) then
            self:SetAllRaids(raids);
        else
            self:SetRaid(self.currentRaid);
        end
    end

    DB:AddObserver("filters.specId", OnChanged);
    DB:AddObserver("filters.slotId", OnChanged);
    DB:AddObserver("filters.raid.rank", OnChanged);
    DB:AddObserver("ui.selectedCharacterKey", OnChanged);
    DB:AddObserver("ui.selectedTab", OnChanged);
    DB:AddObserver("settings.highlighting.*", OnChanged);
    DB:AddObserver("settings.wideMode", OnChanged);

    if (stackedMode) then
        self.DropdownButton:Hide();
        self:SetAllRaids(raids);
    else
        self.DropdownButton:Init(raids);
        self:SetRaid(raids[1]);
    end
end
