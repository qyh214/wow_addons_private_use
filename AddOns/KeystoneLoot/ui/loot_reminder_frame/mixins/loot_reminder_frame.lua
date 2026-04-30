local AddonName, KeystoneLoot    = ...;

local Keystone                   = KeystoneLoot.Keystone;
local Query                      = KeystoneLoot.Query;
local L                          = KeystoneLoot.L;

local SPEC_FRAME_WIDTH           = 180;
local SPEC_FRAME_HEIGHT          = 90;
local SPEC_FRAME_SPACING         = 20;
local FRAME_PADDING              = 20;
local FRAME_HEADER_HEIGHT        = 80;
local SPEC_TITLE_HEIGHT          = 24;
local SPEC_BUTTON_HEIGHT         = 30;

local instanceIdToChallengeMapId = {};

KeystoneLootReminderFrameMixin   = {};

function KeystoneLootReminderFrameMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterForDrag("LeftButton");

    self.Inset:Hide();
    self.Bg:SetPoint("TOPLEFT", 0, -6);
    self.Bg:SetPoint("BOTTOMRIGHT", -4, 3);
    self.HeadlineBg:SetVertexColor(0.1, 0.1, 0.1, 1);
    self.Title:SetText(L["Correct loot specialization set?"]);

    self.specPool = CreateFramePool("Frame", self.Container, "KeystoneLootReminderSpecTemplate");

    for _, dungeon in ipairs(Query:GetDungeons()) do
        instanceIdToChallengeMapId[dungeon.instanceId] = dungeon.challengeModeId;
    end
end

function KeystoneLootReminderFrameMixin:OnShow()
    PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
end

function KeystoneLootReminderFrameMixin:OnHide()
    PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
end

function KeystoneLootReminderFrameMixin:OnDragStart()
    self:StartMoving();
    self:SetUserPlaced(true);
end

function KeystoneLootReminderFrameMixin:OnDragStop()
    self:StopMovingOrSizing();
end

function KeystoneLootReminderFrameMixin:OnEvent()
    self:Hide();

    local _, instanceType, difficultyId, _, _, _, _, instanceId = GetInstanceInfo();
    if (instanceType ~= "party") then
        return;
    end

    if (difficultyId == 0) then
        difficultyId = GetDungeonDifficultyID();
    end

    if (difficultyId ~= DifficultyUtil.ID.DungeonMythic) then
        return;
    end

    local challengeMapId = instanceIdToChallengeMapId[instanceId];
    if (not challengeMapId) then
        return;
    end

    self:Open(challengeMapId);
end

function KeystoneLootReminderFrameMixin:Open(challengeModeId)
    local itemList, allSpecItems = Keystone:GetLootReminderItemList(challengeModeId);

    if (not next(itemList)) then
        return;
    end

    self.specPool:ReleaseAll();

    local lootSpecId = GetLootSpecialization();
    if (lootSpecId == 0) then
        lootSpecId = GetSpecializationInfo(GetSpecialization());
    end

    -- Sort by favo spec id for deterministic ordering
    local sortedSpecs = {};
    for favoSpecId in pairs(itemList) do
        table.insert(sortedSpecs, favoSpecId);
    end
    table.sort(sortedSpecs);

    local PrevFrame = nil;
    for _, favoSpecId in ipairs(sortedSpecs) do
        local entry = itemList[favoSpecId];
        local SpecFrame = self.specPool:Acquire();
        SpecFrame:ClearAllPoints();

        if (PrevFrame) then
            SpecFrame:SetPoint("LEFT", PrevFrame, "RIGHT", SPEC_FRAME_SPACING, 0);
        else
            SpecFrame:SetPoint("TOPLEFT", self.Container, "TOPLEFT", 0, 0);
        end

        SpecFrame:Init(entry.displaySpecId, entry.favoSpecId, entry.items, lootSpecId, allSpecItems);
        SpecFrame:Show();
        PrevFrame = SpecFrame;
    end

    -- Resize frame to fit all spec cards
    local numSpecs = #sortedSpecs;
    local totalWidth = FRAME_PADDING * 2 + numSpecs * SPEC_FRAME_WIDTH + (numSpecs - 1) * SPEC_FRAME_SPACING;
    local totalHeight = FRAME_HEADER_HEIGHT + SPEC_TITLE_HEIGHT + SPEC_FRAME_HEIGHT + SPEC_BUTTON_HEIGHT;

    -- Shared items footer
    local numShared = 0;
    for _ in pairs(allSpecItems) do
        numShared = numShared + 1;
    end

    if (numShared > 0) then
        local text;
        if (numShared == 1) then
            text = L["+1 item dropping for all specs."];
        else
            text = string.format(L["+%d items dropping for all specs."], numShared);
        end

        self.SharedItemsText:SetText(text);
        self.SharedItemsText:Show();

        if (totalWidth > 220) then
            totalHeight = totalHeight + 10;
        else
            totalHeight = totalHeight + 20;
        end
    else
        self.SharedItemsText:Hide();
        totalHeight = totalHeight - 5;
    end

    self:SetSize(totalWidth, totalHeight);
    self.Container:SetSize(totalWidth - FRAME_PADDING * 2, SPEC_FRAME_HEIGHT);
    self:Show();
end

function KeystoneLootReminderFrameMixin:UpdateLootSpec(lootSpecId)
    for SpecFrame in self.specPool:EnumerateActive() do
        SpecFrame:UpdateLootSpec(lootSpecId);
    end
end

hooksecurefunc("SetLootSpecialization", function(newLootSpecId)
    if (not KeystoneLootReminderFrame:IsShown()) then
        return;
    end

    KeystoneLootReminderFrame:UpdateLootSpec(newLootSpecId);
end);
