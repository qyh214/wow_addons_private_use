local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;
local Query = KeystoneLoot.Query;

KeystoneLootRaidBlockMixin = {};

function KeystoneLootRaidBlockMixin:OnLoad()
    self.Inset.Bg:SetAlpha(0.75);
    self.Inset.Bg:SetAtlas("UI-Frame-Dragonflight-BackgroundTile");

    self.entryPool = CreateFramePool("Frame", self.Container, "KeystoneLootEntryFrameTemplate");
end

function KeystoneLootRaidBlockMixin:SetTitle(name)
    self.TitleText:SetText(name);
end

function KeystoneLootRaidBlockMixin:SetRaid(raid)
    self.entryPool:ReleaseAll();

    self:SetWidth(DB:Get("settings.wideMode") and 728 or 500);

    local numBosses = #raid.bossList;

    for index = 1, numBosses do
        local boss = raid.bossList[index];
        local isLastEntry = index == numBosses;
        local lootTable = Query:GetRaidItems(boss.bossId);

        local Frame = self.entryPool:Acquire();
        Frame:Init(index, boss, lootTable, isLastEntry);
        Frame:Show();
    end

    local height = 0;
    height = height + 4;                    -- space above container for title
    height = height + 4;                    -- container padding top
    height = height + (numBosses * 54) - 1; -- entries (last has no bottom divider)
    height = height + 4;                    -- container padding bottom
    height = height + 24;                   -- space below container

    self:SetHeight(height);
    self.Container:Layout();
end
