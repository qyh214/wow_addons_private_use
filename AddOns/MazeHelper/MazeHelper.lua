local ADDON_NAME, MazeHelper = ...;
local L, E, M = MazeHelper.L, MazeHelper.E, MazeHelper.M;
local Version = C_AddOns.GetAddOnMetadata(ADDON_NAME, 'Version');

-- Lua API
local tonumber = tonumber;

-- WoW API
local IsInRaid, IsInGroup, GetMinimapZoneText = IsInRaid, IsInGroup, GetMinimapZoneText;

local ADDON_COMM_PREFIX = 'MAZEHELPER';
local ADDON_COMM_MODE   = 'NORMAL';
C_ChatInfo.RegisterAddonMessagePrefix(ADDON_COMM_PREFIX);

local playerNameWithRealm, playerRole, inInstance, inMOTS, bossKilled, inEncounter, isMinimized;
local startedInMinMode = false;

local MAX_BUTTONS = 8;
local MAX_ACTIVE_BUTTONS = 4;
local NUM_ACTIVE_BUTTONS = 0;

local FRAME_SIZE = 300;
local X_OFFSET = 2;
local Y_OFFSET = -2;
local BUTTON_SIZE = 64;
local SLIDER_FULL_WIDTH = 10 + FRAME_SIZE + X_OFFSET * (MAX_ACTIVE_BUTTONS - 1) - 50;

local RESERVED_BUTTONS_SEQUENCE = {
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
};

local nameplatesMarkers = {};

local USED_MARKERS = {
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = false,
    [7] = false,
    [8] = false,
};

local MARKER_UNITS = {
    'player',
    'party1',
    'party2',
    'party3',
    'party4',
    'boss1',
};

local SOLUTION_PLAYER_MARKER = 4; -- GREEN
local SKULL_MARKER = 8;

local MODIFIERS = {
    [1] = IsAltKeyDown,
    [2] = IsControlKeyDown,
    [3] = IsShiftKeyDown,
};

local MODIFIERS_LIST = {
    [1] = 'ALT',
    [2] = 'CTRL',
    [3] = 'SHIFT',
};

local CHANNELS_LIST = {
    [1] = 'PARTY',
    [2] = 'SAY',
    [3] = 'YELL',
};

local CHANNELS_LIST_LOCALIZED = {
    [1] = CHAT_MSG_PARTY,
    [2] = CHAT_MSG_SAY,
    [3] = CHAT_MSG_YELL,
};

local TOUGH_CROWD_QUEST_ID = 60739;
local EXPOSED_BOGGARD_NPC_ID = 170080;

local SPRIGAN_RIOT_QUEST_ID = 60585;
local SILKSTRIDER_CARETAKER_NPC_ID = 169273;

local PASSED_COUNTER = 1;
local SOLUTION_BUTTON_ID;
local PREDICTED_SOLUTION_BUTTON_ID;
local isPredictedTemporaryOff = false;

local ANNOUNCED_BUTTON_ID;

local MOTS_INSTANCE_ID = 2290;
local MISTCALLER_ENCOUNTER_ID = 2392;
local ILLUSIONARY_CLONE_ID = 165108;
local DEPLETED_ANIMA_SEED_IDS = {
    [173702] = true,
    [357703] = true,
    [357707] = true,
};

local EVENTS_INSTANCE = {
    'ZONE_CHANGED',
    'ZONE_CHANGED_INDOORS',
    'ZONE_CHANGED_NEW_AREA',
    'ENCOUNTER_START',
    'ENCOUNTER_END',
    'CHAT_MSG_MONSTER_SAY',
};

local EVENTS_SKULLMARKER = {
    'PLAYER_TARGET_CHANGED',
};

local EVENTS_AUTOMARKER = {
    'NAME_PLATE_UNIT_ADDED',
    'NAME_PLATE_UNIT_REMOVED',
};

local DEFAULT_COLORS = {
    Active    = {  0.4, 0.52, 0.95, 1 },
    Received  = { 0.63, 0.55,    1, 1 },
    Solution  = {  0.2,  0.8,  0.4, 1 },
    Predicted = {    1,  0.9, 0.71, 1 },
};

local buttons = {};
local buttonsData = {
    [1] = {
        name = L['LEAF_FULL_CIRCLE'],
        ename = L['ENGLISH_LEAF_FULL_CIRCLE'],
        coords = M.Symbols.COORDS_COLOR.LEAF_CIRCLE_FILL,
        coords_white = M.Symbols.COORDS_WHITE.LEAF_CIRCLE_FILL,
        leaf = true,
        circle = true,
        fill = true,
    },
    [2] = {
        name = L['LEAF_NOFULL_CIRCLE'],
        ename = L['ENGLISH_LEAF_NOFULL_CIRCLE'],
        coords = M.Symbols.COORDS_COLOR.LEAF_CIRCLE_NOFILL,
        coords_white = M.Symbols.COORDS_WHITE.LEAF_CIRCLE_NOFILL,
        leaf = true,
        circle = true,
        fill = false,
    },
    [3] = {
        name = L['FLOWER_FULL_CIRCLE'],
        ename = L['ENGLISH_FLOWER_FULL_CIRCLE'],
        coords = M.Symbols.COORDS_COLOR.FLOWER_CIRCLE_FILL,
        coords_white = M.Symbols.COORDS_WHITE.FLOWER_CIRCLE_FILL,
        leaf = false,
        circle = true,
        fill = true,
    },
    [4] = {
        name = L['FLOWER_NOFULL_CIRCLE'],
        ename = L['ENGLISH_FLOWER_NOFULL_CIRCLE'],
        coords = M.Symbols.COORDS_COLOR.FLOWER_CIRCLE_NOFILL,
        coords_white = M.Symbols.COORDS_WHITE.FLOWER_CIRCLE_NOFILL,
        leaf = false,
        circle = true,
        fill = false,
    },
    [5] = {
        name = L['LEAF_FULL_NOCIRCLE'],
        ename = L['ENGLISH_LEAF_FULL_NOCIRCLE'],
        coords = M.Symbols.COORDS_COLOR.LEAF_NOCIRCLE_FILL,
        coords_white = M.Symbols.COORDS_WHITE.LEAF_NOCIRCLE_FILL,
        leaf = true,
        circle = false,
        fill = true,
    },
    [6] = {
        name = L['LEAF_NOFULL_NOCIRCLE'],
        ename = L['ENGLISH_LEAF_NOFULL_NOCIRCLE'],
        coords = M.Symbols.COORDS_COLOR.LEAF_NOCIRCLE_NOFILL,
        coords_white = M.Symbols.COORDS_WHITE.LEAF_NOCIRCLE_NOFILL,
        leaf = true,
        circle = false,
        fill = false,
    },
    [7] = {
        name = L['FLOWER_FULL_NOCIRCLE'],
        ename = L['ENGLISH_FLOWER_FULL_NOCIRCLE'],
        coords = M.Symbols.COORDS_COLOR.FLOWER_NOCIRCLE_FILL,
        coords_white = M.Symbols.COORDS_WHITE.FLOWER_NOCIRCLE_FILL,
        leaf = false,
        circle = false,
        fill = true,
    },
    [8] = {
        name = L['FLOWER_NOFULL_NOCIRCLE'],
        ename = L['ENGLISH_FLOWER_NOFULL_NOCIRCLE'],
        coords = M.Symbols.COORDS_COLOR.FLOWER_NOCIRCLE_NOFILL,
        coords_white = M.Symbols.COORDS_WHITE.FLOWER_NOCIRCLE_NOFILL,
        leaf = false,
        circle = false,
        fill = false,
    },
};

MazeHelper.ButtonsData = buttonsData;

local function mhPrint(message)
    if not message or message == '' then
        return;
    end

    print(string.format(L['MAZE_HELPER_PRINT'], message));
end

local function GetNpcId(unit)
    return tonumber((select(6, strsplit('-', UnitGUID(unit) or ''))));
end

local function GetPartyChatType()
    if IsInRaid() then
        return false;
    end

    return IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and 'INSTANCE_CHAT' or (IsInGroup(LE_PARTY_CATEGORY_HOME) and 'PARTY' or false);
end

local function AnnounceInChat(partyChatType, fromButton)
    if not SOLUTION_BUTTON_ID or not partyChatType then
        return;
    end

    local announceChannel;

    if fromButton then
        announceChannel = CHANNELS_LIST[MHMOTSConfig.AutoAnnouncerChannel];
    else
        if MHMOTSConfig.AutoAnnouncerChannel == 1 then -- PARTY
            announceChannel = partyChatType;
        else
            announceChannel = IsInInstance() and CHANNELS_LIST[MHMOTSConfig.AutoAnnouncerChannel] or CHANNELS_LIST[1];
        end
    end

    if MazeHelper.currentLocale ~= 'enUS' then
        if MHMOTSConfig.AnnounceOnlyEnglish then
            SendChatMessage(string.format(L['ANNOUNCE_SOLUTION'], buttons[SOLUTION_BUTTON_ID].data.ename), announceChannel);
        elseif MHMOTSConfig.AnnounceWithEnglish then
            SendChatMessage(string.format(L['ANNOUNCE_SOLUTION_WITH_ENGLISH'], buttons[SOLUTION_BUTTON_ID].data.name, buttons[SOLUTION_BUTTON_ID].data.ename), announceChannel);
        else
            SendChatMessage(string.format(L['ANNOUNCE_SOLUTION'], buttons[SOLUTION_BUTTON_ID].data.name), announceChannel);
        end
    else
        SendChatMessage(string.format(L['ANNOUNCE_SOLUTION'], buttons[SOLUTION_BUTTON_ID].data.name), announceChannel);
    end
end

local function BorderColor_UpdateAll()
    for i = 1, MAX_BUTTONS do
        if buttons[i] then
            buttons[i]:UpdateBorder();
        end
    end

    local button = PREDICTED_SOLUTION_BUTTON_ID and buttons[PREDICTED_SOLUTION_BUTTON_ID];

    if button then
        button:SetPredictedBorder();
    end
end

local function PassedCounter_Update()
    MazeHelper.frame.PassedCounter.Text:SetText(PASSED_COUNTER);
    PixelUtil.SetPoint(MazeHelper.frame.PassedCounter.Text, 'CENTER', MazeHelper.frame.PassedCounter, 'CENTER', (PASSED_COUNTER == 1) and -2 or 0, isMinimized and 0 or -1);
end

local function BetterOnDragStop(frame, saveTable)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint();

    saveTable[1] = point;
    saveTable[2] = relativeTo
    saveTable[3] = relativePoint;
    saveTable[4] = xOfs;
    saveTable[5] = yOfs;

    frame:StopMovingOrSizing();

    frame:ClearAllPoints();
    PixelUtil.SetPoint(frame, point, UIParent, relativePoint, xOfs, yOfs);
    frame:SetUserPlaced(true);
end

local function BetterSetScale(frame, value, positionTable, ignoredParentScale)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint();
    local s = frame:GetScale();

    if ignoredParentScale then
        s = PixelUtil.GetPixelToUIUnitFactor() * value / s;
        value = value * PixelUtil.GetPixelToUIUnitFactor();
    else
        s = value / s;
    end

    if positionTable and type(positionTable) == 'table' then
        positionTable[1] = point;
        positionTable[2] = relativeTo;
        positionTable[3] = relativePoint;
        positionTable[4] = xOfs / s;
        positionTable[5] = yOfs / s;
    end

    frame:SetScale(value);
    frame:ClearAllPoints();
    PixelUtil.SetPoint(frame, point, UIParent, relativePoint, xOfs / s, yOfs / s);
    frame:SetUserPlaced(true);
end

MazeHelper.frame = CreateFrame('Frame', 'ST_Maze_Helper', UIParent);
PixelUtil.SetPoint(MazeHelper.frame, 'CENTER', UIParent, 'CENTER', -FRAME_SIZE, FRAME_SIZE);
PixelUtil.SetSize(MazeHelper.frame, FRAME_SIZE + X_OFFSET * (MAX_ACTIVE_BUTTONS - 1), FRAME_SIZE * 3/4);
MazeHelper.frame:EnableMouse(true);
MazeHelper.frame:SetMovable(true);
MazeHelper.frame:SetClampedToScreen(true);
MazeHelper.frame:SetClampRectInsets(-4, 4, 24, 0);
MazeHelper.frame:RegisterForDrag('LeftButton');
MazeHelper.frame:SetScript('OnDragStart', function(self)
    if self:IsMovable() and not MHMOTSConfig.LockedDrag then
        self:StartMoving();
    end
end);
MazeHelper.frame:SetScript('OnDragStop', function(self)
    BetterOnDragStop(self, MHMOTSConfig.SavedPosition);
end);
MazeHelper.frame:HookScript('OnShow', function(self)
    if SOLUTION_BUTTON_ID then
        self.LargeSymbol:Show();
    end
end);
E.CreateSmoothShowing(MazeHelper.frame);
MazeHelper.frame:HookScript('OnEnter', function()
    MazeHelper.frame.LockDragButton:SetShown(not isMinimized);
end);
MazeHelper.frame:HookScript('OnLeave', function()
    if not MazeHelper.frame.LockDragButton:IsMouseOver() then
        MazeHelper.frame.LockDragButton:Hide();
    end
end);

-- Background
MazeHelper.frame.background = MazeHelper.frame:CreateTexture(nil, 'BACKGROUND');
PixelUtil.SetPoint(MazeHelper.frame.background, 'TOPLEFT', MazeHelper.frame, 'TOPLEFT', -15, 22);
PixelUtil.SetPoint(MazeHelper.frame.background, 'BOTTOMRIGHT', MazeHelper.frame, 'BOTTOMRIGHT', 15, -98);
MazeHelper.frame.background:SetTexture(M.BACKGROUND_WHITE);
MazeHelper.frame.background:SetVertexColor(0.05, 0.05, 0.05);

-- Close Button
MazeHelper.frame.CloseButton = CreateFrame('Button', nil, MazeHelper.frame);
PixelUtil.SetPoint(MazeHelper.frame.CloseButton, 'TOPRIGHT', MazeHelper.frame, 'TOPRIGHT', -8, -4);
PixelUtil.SetSize(MazeHelper.frame.CloseButton, 12, 12);
MazeHelper.frame.CloseButton:SetNormalTexture(M.Icons.TEXTURE);
MazeHelper.frame.CloseButton:GetNormalTexture():SetTexCoord(unpack(M.Icons.COORDS.CROSS_WHITE));
MazeHelper.frame.CloseButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
MazeHelper.frame.CloseButton:SetHighlightTexture(M.Icons.TEXTURE, 'BLEND');
MazeHelper.frame.CloseButton:GetHighlightTexture():SetTexCoord(unpack(M.Icons.COORDS.CROSS_WHITE));
MazeHelper.frame.CloseButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
MazeHelper.frame.CloseButton:SetScript('OnClick', function()
    if MazeHelper.frame.Settings:IsShown() then
        MazeHelper.frame.Settings:Hide();
        MazeHelper.frame.SettingsButton:Show();
        MazeHelper.frame.MainHolder:Show();
        MazeHelper.frame.MinButton:Show();

        return;
    end

    MazeHelper.frame:Hide();
end);
MazeHelper.frame.CloseButton:HookScript('OnEnter', function()
    MazeHelper.frame.LockDragButton:SetShown(not isMinimized);
end);
MazeHelper.frame.CloseButton:HookScript('OnLeave', function()
    if not MazeHelper.frame.LockDragButton:IsMouseOver() then
        MazeHelper.frame.LockDragButton:Hide();
    end
end);

-- Settings Button
MazeHelper.frame.SettingsButton = CreateFrame('Button', nil, MazeHelper.frame);
PixelUtil.SetPoint(MazeHelper.frame.SettingsButton, 'RIGHT', MazeHelper.frame.CloseButton, 'LEFT', -8, 0);
PixelUtil.SetSize(MazeHelper.frame.SettingsButton, 14, 14);
MazeHelper.frame.SettingsButton:SetNormalTexture(M.Icons.TEXTURE);
MazeHelper.frame.SettingsButton:GetNormalTexture():SetTexCoord(unpack(M.Icons.COORDS.GEAR_WHITE));
MazeHelper.frame.SettingsButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
MazeHelper.frame.SettingsButton:SetHighlightTexture(M.Icons.TEXTURE, 'BLEND');
MazeHelper.frame.SettingsButton:GetHighlightTexture():SetTexCoord(unpack(M.Icons.COORDS.GEAR_WHITE));
MazeHelper.frame.SettingsButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
MazeHelper.frame.SettingsButton:SetScript('OnClick', function(self)
    local settingsIsShown = MazeHelper.frame.Settings:IsShown();

    self:Hide();

    MazeHelper.frame.Settings:SetShown(not settingsIsShown);
    MazeHelper.frame.MainHolder:SetShown(settingsIsShown);
    MazeHelper.frame.MinButton:SetShown(settingsIsShown);
end);
MazeHelper.frame.SettingsButton:HookScript('OnEnter', function()
    MazeHelper.frame.LockDragButton:SetShown(not isMinimized);
end);
MazeHelper.frame.SettingsButton:HookScript('OnLeave', function()
    if not MazeHelper.frame.LockDragButton:IsMouseOver() then
        MazeHelper.frame.LockDragButton:Hide();
    end
end);

-- Minimize Button
MazeHelper.frame.MinButton = CreateFrame('Button', nil, MazeHelper.frame);
PixelUtil.SetPoint(MazeHelper.frame.MinButton, 'RIGHT', MazeHelper.frame.SettingsButton, 'LEFT', -8, 1);
PixelUtil.SetSize(MazeHelper.frame.MinButton, 14, 14);
MazeHelper.frame.MinButton.icon = MazeHelper.frame.MinButton:CreateTexture(nil, 'OVERLAY');
PixelUtil.SetPoint(MazeHelper.frame.MinButton.icon, 'BOTTOM', MazeHelper.frame.MinButton, 'BOTTOM', 0, 0);
PixelUtil.SetSize(MazeHelper.frame.MinButton.icon, 10, 2);
MazeHelper.frame.MinButton.icon:SetTexture('Interface\\Buttons\\WHITE8x8');
MazeHelper.frame.MinButton.icon:SetVertexColor(0.7, 0.7, 0.7, 1);
MazeHelper.frame.MinButton:SetScript('OnClick', function()
    isMinimized = true;

    PixelUtil.SetHeight(MazeHelper.frame, 40);
    for i = 1, MAX_BUTTONS do
        buttons[i]:Hide();
    end

    PixelUtil.SetPoint(MazeHelper.frame.SolutionText, 'LEFT', MazeHelper.frame, 'LEFT', 2, 4);

    MazeHelper.frame.BottomButtonsHolder:Hide();

    PixelUtil.SetPoint(MazeHelper.frame.background, 'TOPLEFT', MazeHelper.frame, 'TOPLEFT', -15, 0);
    PixelUtil.SetPoint(MazeHelper.frame.background, 'BOTTOMRIGHT', MazeHelper.frame, 'BOTTOMRIGHT', 15, 0);

    PixelUtil.SetPoint(MazeHelper.frame.CloseButton, 'TOPRIGHT', MazeHelper.frame, 'TOPRIGHT', -8, -8);

    MazeHelper.frame.PassedCounter:ClearAllPoints();
    PixelUtil.SetPoint(MazeHelper.frame.PassedCounter, 'LEFT', MazeHelper.frame, 'LEFT', -18, 5);
    MazeHelper.frame.PassedCounter:SetScale(1);
    PassedCounter_Update();

    if SOLUTION_BUTTON_ID then
        MazeHelper.frame.MiniSolution:Show();
        MazeHelper.frame.MiniSolution.Icon:SetTexCoord(unpack(MHMOTSConfig.UseColoredSymbols and buttonsData[SOLUTION_BUTTON_ID].coords or buttonsData[SOLUTION_BUTTON_ID].coords_white));
    else
        MazeHelper.frame.MiniSolution:Hide();
    end

    MazeHelper.frame.PassedCounter:SetShown(not MazeHelper.frame.MiniSolution:IsShown());

    MazeHelper.frame.AnnounceButton:Hide();

    MazeHelper.frame.SettingsButton:Hide();

    MazeHelper.frame.InvisibleMaxButton:Show();

    MazeHelper.frame.MinButton:Hide();

    MazeHelper.frame.LockDragButton:Hide();

    MazeHelper.frame:SetClampRectInsets(-8, 4, 4, 0);
end);
MazeHelper.frame.MinButton:SetScript('OnEnter', function(self) self.icon:SetVertexColor(1, 0.85, 0, 1); end);
MazeHelper.frame.MinButton:SetScript('OnLeave', function(self) self.icon:SetVertexColor(0.7, 0.7, 0.7, 1); end);
MazeHelper.frame.MinButton:HookScript('OnEnter', function()
    MazeHelper.frame.LockDragButton:SetShown(not isMinimized);
end);
MazeHelper.frame.MinButton:HookScript('OnLeave', function()
    if not MazeHelper.frame.LockDragButton:IsMouseOver() then
        MazeHelper.frame.LockDragButton:Hide();
    end
end);

-- Invisible Maximize Button
MazeHelper.frame.InvisibleMaxButton = CreateFrame('Button', nil, MazeHelper.frame);
PixelUtil.SetPoint(MazeHelper.frame.InvisibleMaxButton, 'TOPLEFT', MazeHelper.frame, 'TOPLEFT', 0, 0);
PixelUtil.SetPoint(MazeHelper.frame.InvisibleMaxButton, 'BOTTOMRIGHT', MazeHelper.frame, 'BOTTOMRIGHT', 0, 0);
MazeHelper.frame.InvisibleMaxButton:SetScript('OnClick', function()
    if not isMinimized then
        return;
    end

    isMinimized = false;

    PixelUtil.SetHeight(MazeHelper.frame, FRAME_SIZE * 3/4);
    for i = 1, MAX_BUTTONS do
        buttons[i]:Show();
    end

    PixelUtil.SetPoint(MazeHelper.frame.SolutionText, 'LEFT', MazeHelper.frame, 'LEFT', 2, -54);

    MazeHelper.frame.BottomButtonsHolder:Show();
    MazeHelper.frame.PassedButton:SetShown(not inEncounter);
    if inEncounter then
        PixelUtil.SetSize(MazeHelper.frame.BottomButtonsHolder, MazeHelper.frame.ResetButton:GetWidth(), 22);
    else
        PixelUtil.SetSize(MazeHelper.frame.BottomButtonsHolder, MazeHelper.frame.ResetButton:GetWidth() + MazeHelper.frame.PassedButton:GetWidth() + 8, 22);
    end

    PixelUtil.SetPoint(MazeHelper.frame.background, 'TOPLEFT', MazeHelper.frame, 'TOPLEFT', -15, 22);
    PixelUtil.SetPoint(MazeHelper.frame.background, 'BOTTOMRIGHT', MazeHelper.frame, 'BOTTOMRIGHT', 15, -98);

    PixelUtil.SetPoint(MazeHelper.frame.CloseButton, 'TOPRIGHT', MazeHelper.frame, 'TOPRIGHT', -8, -4);

    MazeHelper.frame.PassedCounter:ClearAllPoints();
    PixelUtil.SetPoint(MazeHelper.frame.PassedCounter, 'BOTTOM', MazeHelper.frame, 'TOP', 0, -32);
    MazeHelper.frame.PassedCounter:SetScale(1.25);
    MazeHelper.frame.PassedCounter:Show();
    PassedCounter_Update();

    MazeHelper.frame.MiniSolution:Hide();

    MazeHelper.frame.AnnounceButton:SetShown((SOLUTION_BUTTON_ID and not MazeHelper.frame.AnnounceButton.clicked and GetPartyChatType() and not MHMOTSConfig.AutoAnnouncer) and true or false);

    MazeHelper.frame.SettingsButton:Show();

    MazeHelper.frame.InvisibleMaxButton:Hide();

    MazeHelper.frame.MinButton:Show();

    MazeHelper.frame.LockDragButton:Show();

    MazeHelper.frame:SetClampRectInsets(-4, 4, 24, 0);
end);
MazeHelper.frame.InvisibleMaxButton:RegisterForDrag('LeftButton');
MazeHelper.frame.InvisibleMaxButton:SetScript('OnDragStart', function()
    if MazeHelper.frame:IsMovable() and not MHMOTSConfig.LockedDrag then
        MazeHelper.frame:StartMoving();
    end
end);
MazeHelper.frame.InvisibleMaxButton:SetScript('OnDragStop', function()
    BetterOnDragStop(MazeHelper.frame, MHMOTSConfig.SavedPosition);
end);
MazeHelper.frame.InvisibleMaxButton:Hide();

MazeHelper.frame.MainHolder = CreateFrame('Frame', nil, MazeHelper.frame);
MazeHelper.frame.MainHolder:SetAllPoints();

-- Large Solution Symbol
MazeHelper.frame.LargeSymbol = CreateFrame('Button', nil, UIParent);
PixelUtil.SetPoint(MazeHelper.frame.LargeSymbol, 'TOP', UIParent, 'TOP', 0, -32);
PixelUtil.SetSize(MazeHelper.frame.LargeSymbol, 64, 64)
MazeHelper.frame.LargeSymbol:SetIgnoreParentScale(true);
MazeHelper.frame.LargeSymbol:EnableMouse(true);
MazeHelper.frame.LargeSymbol:SetMovable(true);
MazeHelper.frame.LargeSymbol:SetClampedToScreen(true);
MazeHelper.frame.LargeSymbol:RegisterForClicks('RightButtonUp');
MazeHelper.frame.LargeSymbol:SetScript('OnClick', function(self)
    self:Hide();
end);
MazeHelper.frame.LargeSymbol:RegisterForDrag('LeftButton');
MazeHelper.frame.LargeSymbol:SetScript('OnDragStart', function(self)
    if self:IsMovable() and not MHMOTSConfig.LockedDrag then
        self:StartMoving();
    end
end);
MazeHelper.frame.LargeSymbol:SetScript('OnDragStop', function(self)
    BetterOnDragStop(self, MHMOTSConfig.SavedPositionLargeSymbol);
end);
MazeHelper.frame.LargeSymbol.Icon = MazeHelper.frame.LargeSymbol:CreateTexture(nil, 'ARTWORK');
MazeHelper.frame.LargeSymbol.Icon:SetAllPoints();
MazeHelper.frame.LargeSymbol.Icon:SetTexture(M.Symbols.TEXTURE);
MazeHelper.frame.LargeSymbol.Background = MazeHelper.frame.LargeSymbol:CreateTexture(nil, 'BACKGROUND');
PixelUtil.SetPoint(MazeHelper.frame.LargeSymbol.Background, 'TOPLEFT', MazeHelper.frame.LargeSymbol, 'TOPLEFT', -64, 64);
PixelUtil.SetPoint(MazeHelper.frame.LargeSymbol.Background, 'BOTTOMRIGHT', MazeHelper.frame.LargeSymbol, 'BOTTOMRIGHT', 64, -64);
MazeHelper.frame.LargeSymbol.Background:SetTexture(M.Rings.TEXTURE);
MazeHelper.frame.LargeSymbol.Background:SetTexCoord(unpack(M.Rings.COORDS.GREEN));
MazeHelper.frame.LargeSymbol:Hide();
MazeHelper.frame.LargeSymbol:HookScript('OnShow', function()
    PlaySoundFile(M.Sounds.Notification, 'SFX');
end);
E.CreateSmoothShowing(MazeHelper.frame.LargeSymbol);

-- Solution Text
MazeHelper.frame.SolutionText = MazeHelper.frame.MainHolder:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge');
PixelUtil.SetPoint(MazeHelper.frame.SolutionText, 'LEFT', MazeHelper.frame, 'LEFT', 2, -54);
PixelUtil.SetPoint(MazeHelper.frame.SolutionText, 'RIGHT', MazeHelper.frame, 'RIGHT', -2, 0);
MazeHelper.frame.SolutionText:SetShadowColor(0.15, 0.15, 0.15);
MazeHelper.frame.SolutionText:SetText(L['CHOOSE_SYMBOLS_4']);

local function ResetAll()
    NUM_ACTIVE_BUTTONS = 0;
    SOLUTION_BUTTON_ID = nil;
    PREDICTED_SOLUTION_BUTTON_ID = nil;
    ANNOUNCED_BUTTON_ID = nil;

    isPredictedTemporaryOff = false;

    for i = 1, #RESERVED_BUTTONS_SEQUENCE do
        RESERVED_BUTTONS_SEQUENCE[i] = false;
    end

    for i = 1, MAX_BUTTONS do
        local button = buttons[i];

        button:SetUnactiveBorder();
        button:ResetSequence();

        button.state = false;
        button.sender = nil;
        button.sequence = nil;
    end

    MazeHelper.frame.SolutionText:SetText(L['CHOOSE_SYMBOLS_4']);
    MazeHelper.frame.PassedButton:SetEnabled(false);
    MazeHelper.frame.AnnounceButton:Hide();
    MazeHelper.frame.AnnounceButton.clicked = false;

    MazeHelper.frame.LargeSymbol:Hide();
    MazeHelper.frame.MiniSolution:Hide();
    MazeHelper.frame.PassedCounter:Show();

    MazeHelper.frame.ResetButton:SetEnabled(false);

    if MHMOTSConfig.SetMarkerSolutionPlayer then
        if GetRaidTargetIndex('player') == SOLUTION_PLAYER_MARKER then
            SetRaidTarget('player', 0);
        end
    end
end

MazeHelper.frame.BottomButtonsHolder = CreateFrame('Frame', nil, MazeHelper.frame.MainHolder);
PixelUtil.SetPoint(MazeHelper.frame.BottomButtonsHolder, 'TOP', MazeHelper.frame.SolutionText, 'BOTTOM', 0, -8);
PixelUtil.SetSize(MazeHelper.frame.BottomButtonsHolder, MazeHelper.frame.MainHolder:GetWidth(), 22);

-- Reset Button
MazeHelper.frame.ResetButton = CreateFrame('Button', nil, MazeHelper.frame.BottomButtonsHolder, 'SharedButtonSmallTemplate');
PixelUtil.SetPoint(MazeHelper.frame.ResetButton, 'RIGHT', MazeHelper.frame.BottomButtonsHolder, 'RIGHT', 0, 0);
MazeHelper.frame.ResetButton:SetText(L['RESET']);
PixelUtil.SetSize(MazeHelper.frame.ResetButton, tonumber(MazeHelper.frame.ResetButton:GetTextWidth()) + 20, 22);
MazeHelper.frame.ResetButton:SetScript('OnClick', function()
    if NUM_ACTIVE_BUTTONS == 0 then
        return;
    end

    MazeHelper:SendResetCommand();
    ResetAll();
end);
MazeHelper.frame.ResetButton:SetEnabled(false);
MazeHelper.frame.ResetButton:HookScript('OnEnter', function()
    MazeHelper.frame.LockDragButton:SetShown(not isMinimized);
end);
MazeHelper.frame.ResetButton:HookScript('OnLeave', function()
    if not MazeHelper.frame.LockDragButton:IsMouseOver() then
        MazeHelper.frame.LockDragButton:Hide();
    end
end);


-- Passed Button
MazeHelper.frame.PassedButton = CreateFrame('Button', nil, MazeHelper.frame.BottomButtonsHolder, 'SharedButtonSmallTemplate');
PixelUtil.SetPoint(MazeHelper.frame.PassedButton, 'RIGHT', MazeHelper.frame.ResetButton, 'LEFT', -8, 0);
MazeHelper.frame.PassedButton:SetText(L['PASSED']);
PixelUtil.SetSize(MazeHelper.frame.PassedButton, tonumber(MazeHelper.frame.PassedButton:GetTextWidth()) + 20, 22);
MazeHelper.frame.PassedButton:SetScript('OnClick', function()
    PASSED_COUNTER = PASSED_COUNTER + 1;
    PassedCounter_Update();

    MazeHelper:SendPassedCommand();
    ResetAll();
end);
MazeHelper.frame.PassedButton:SetEnabled(false);
MazeHelper.frame.PassedButton:HookScript('OnEnter', function()
    MazeHelper.frame.LockDragButton:SetShown(not isMinimized);
end);
MazeHelper.frame.PassedButton:HookScript('OnLeave', function()
    if not MazeHelper.frame.LockDragButton:IsMouseOver() then
        MazeHelper.frame.LockDragButton:Hide();
    end
end);

PixelUtil.SetSize(MazeHelper.frame.BottomButtonsHolder, MazeHelper.frame.ResetButton:GetWidth() + MazeHelper.frame.PassedButton:GetWidth() + 8, 22);

-- Passed Counter Text
MazeHelper.frame.PassedCounter = CreateFrame('Frame', nil, MazeHelper.frame.MainHolder);
PixelUtil.SetPoint(MazeHelper.frame.PassedCounter, 'BOTTOM', MazeHelper.frame, 'TOP', 0, -32);
PixelUtil.SetSize(MazeHelper.frame.PassedCounter, 64, 64);
MazeHelper.frame.PassedCounter:SetScale(1.25);
MazeHelper.frame.PassedCounter.Background = MazeHelper.frame.PassedCounter:CreateTexture(nil, 'BACKGROUND');
MazeHelper.frame.PassedCounter.Background:SetAllPoints();
MazeHelper.frame.PassedCounter.Background:SetTexture(M.Rings.TEXTURE);
MazeHelper.frame.PassedCounter.Background:SetTexCoord(unpack(M.Rings.COORDS.BLUE));
MazeHelper.frame.PassedCounter.Text = MazeHelper.frame.PassedCounter:CreateFontString(nil, 'ARTWORK', 'GameFontNormalShadowHuge2');
PixelUtil.SetPoint(MazeHelper.frame.PassedCounter.Text, 'CENTER', MazeHelper.frame.PassedCounter, 'CENTER', -2, -1);
MazeHelper.frame.PassedCounter.Text:SetShadowColor(0.15, 0.15, 0.15);
MazeHelper.frame.PassedCounter.Text:SetText(PASSED_COUNTER);
MazeHelper.frame.PassedCounter.Text:SetJustifyH('CENTER');


-- Mini solution icon
MazeHelper.frame.MiniSolution = CreateFrame('Frame', nil, MazeHelper.frame.MainHolder);
MazeHelper.frame.MiniSolution:SetAllPoints(MazeHelper.frame.PassedCounter);
PixelUtil.SetPoint(MazeHelper.frame.MiniSolution, 'CENTER', MazeHelper.frame.PassedCounter, 'CENTER', 0, 0);
MazeHelper.frame.MiniSolution.Icon = MazeHelper.frame.MiniSolution:CreateTexture(nil, 'OVERLAY');
PixelUtil.SetPoint(MazeHelper.frame.MiniSolution.Icon, 'CENTER', MazeHelper.frame.MiniSolution, 'CENTER', 0, 0);
PixelUtil.SetSize(MazeHelper.frame.MiniSolution.Icon, 40, 40);
MazeHelper.frame.MiniSolution.Icon:SetTexture(M.Symbols.TEXTURE);
MazeHelper.frame.MiniSolution:Hide();

-- Announce Button
MazeHelper.frame.AnnounceButton = CreateFrame('Button', nil, MazeHelper.frame.MainHolder);
PixelUtil.SetPoint(MazeHelper.frame.AnnounceButton, 'TOPLEFT', MazeHelper.frame, 'TOPLEFT', 2, 4);
PixelUtil.SetSize(MazeHelper.frame.AnnounceButton, 18, 18);
MazeHelper.frame.AnnounceButton:SetNormalTexture(M.Icons.TEXTURE);
MazeHelper.frame.AnnounceButton:GetNormalTexture():SetTexCoord(unpack(M.Icons.COORDS.MEGAPHONE_WHITE));
MazeHelper.frame.AnnounceButton:GetNormalTexture():SetVertexColor(1, 0.85, 0, 1);
MazeHelper.frame.AnnounceButton:SetHighlightTexture(M.Icons.TEXTURE, 'BLEND');
MazeHelper.frame.AnnounceButton:GetHighlightTexture():SetTexCoord(unpack(M.Icons.COORDS.MEGAPHONE_WHITE));
MazeHelper.frame.AnnounceButton:GetHighlightTexture():SetVertexColor(1, 1, 0, 1);
MazeHelper.frame.AnnounceButton.Background = MazeHelper.frame.AnnounceButton:CreateTexture(nil, 'BACKGROUND');
PixelUtil.SetPoint(MazeHelper.frame.AnnounceButton.Background, 'TOPLEFT', MazeHelper.frame.AnnounceButton, 'TOPLEFT', -26, 22);
PixelUtil.SetPoint(MazeHelper.frame.AnnounceButton.Background, 'BOTTOMRIGHT', MazeHelper.frame.AnnounceButton, 'BOTTOMRIGHT', 26, -26);
MazeHelper.frame.AnnounceButton.Background:SetTexture(M.Rings.TEXTURE);
MazeHelper.frame.AnnounceButton.Background:SetTexCoord(unpack(M.Rings.COORDS.VIOLET));
MazeHelper.frame.AnnounceButton:SetScript('OnClick', function(self)
    if not SOLUTION_BUTTON_ID then
        return;
    end

    AnnounceInChat(GetPartyChatType(), true);

    self.clicked = true;
    self:Hide();
end);
MazeHelper.frame.AnnounceButton:Hide();

local function GameTooltip_LockDragButton_Show(self)
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
    GameTooltip:AddLine(MHMOTSConfig.LockedDrag and L['LOCKED_DRAG_BUTTON_TOOLTIP'] or L['UNLOCKED_DRAG_BUTTON_TOOLTIP'], 1, 0.85, 0, true);
    GameTooltip:Show();
end

MazeHelper.frame.LockDragButton = CreateFrame('CheckButton', nil, MazeHelper.frame.MainHolder);
PixelUtil.SetPoint(MazeHelper.frame.LockDragButton, 'BOTTOMLEFT', MazeHelper.frame, 'BOTTOMLEFT', 10, 28);
PixelUtil.SetSize(MazeHelper.frame.LockDragButton, 14, 14);
MazeHelper.frame.LockDragButton:SetNormalTexture(M.Icons.TEXTURE);
MazeHelper.frame.LockDragButton.SetTurned = function(self, state)
    if state then
        self:GetNormalTexture():SetVertexColor(0.8, 0.2, 0.4, 1);
        self:GetNormalTexture():SetTexCoord(unpack(M.Icons.COORDS.LOCKED_WHITE));
    else
        self:GetNormalTexture():SetVertexColor(0.2, 0.8, 0.4, 1);
        self:GetNormalTexture():SetTexCoord(unpack(M.Icons.COORDS.UNLOCKED_WHITE));
    end
end
MazeHelper.frame.LockDragButton:SetScript('OnClick', function(self)
    MHMOTSConfig.LockedDrag = self:GetChecked();

    self:SetTurned(MHMOTSConfig.LockedDrag);

    if GameTooltip:IsOwned(self) then
        GameTooltip_LockDragButton_Show(self);
    end
end);
MazeHelper.frame.LockDragButton:HookScript('OnEnter', GameTooltip_LockDragButton_Show);
MazeHelper.frame.LockDragButton:HookScript('OnLeave', GameTooltip_Hide);
MazeHelper.frame.LockDragButton:Hide();

MazeHelper.frame.Settings = CreateFrame('Frame', nil, MazeHelper.frame);
MazeHelper.frame.Settings:SetAllPoints();
MazeHelper.frame.Settings:Hide();

MazeHelper.frame.PracticeModeButton = CreateFrame('Button', nil, MazeHelper.frame.Settings);
PixelUtil.SetPoint(MazeHelper.frame.PracticeModeButton, 'BOTTOM', MazeHelper.frame.Settings, 'TOP', 0, -4);
PixelUtil.SetSize(MazeHelper.frame.PracticeModeButton, 24, 24);
MazeHelper.frame.PracticeModeButton:SetNormalTexture(M.Icons.TEXTURE);
MazeHelper.frame.PracticeModeButton:GetNormalTexture():SetTexCoord(unpack(M.Icons.COORDS.MAZE_BRAIN));
MazeHelper.frame.PracticeModeButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
MazeHelper.frame.PracticeModeButton:SetHighlightTexture(M.Icons.TEXTURE, 'BLEND');
MazeHelper.frame.PracticeModeButton:GetHighlightTexture():SetTexCoord(unpack(M.Icons.COORDS.MAZE_BRAIN));
MazeHelper.frame.PracticeModeButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
MazeHelper.frame.PracticeModeButton:SetScript('OnClick', function()
    MazeHelper.frame:Hide();
    MazeHelper.frame.LargeSymbol:Hide();
    MazeHelper.PracticeFrame:Show();
end);
E.CreateTooltip(MazeHelper.frame.PracticeModeButton, L['PRACTICE_BUTTON_TOOLTIP']);

MazeHelper.frame.PracticeModeButton.Background = MazeHelper.frame.PracticeModeButton:CreateTexture(nil, 'BACKGROUND');
PixelUtil.SetPoint(MazeHelper.frame.PracticeModeButton.Background, 'TOPLEFT', MazeHelper.frame.PracticeModeButton, 'TOPLEFT', -30, 30);
PixelUtil.SetPoint(MazeHelper.frame.PracticeModeButton.Background, 'BOTTOMRIGHT', MazeHelper.frame.PracticeModeButton, 'BOTTOMRIGHT', 30, -30);
MazeHelper.frame.PracticeModeButton.Background:SetTexture(M.Rings.TEXTURE);
MazeHelper.frame.PracticeModeButton.Background:SetTexCoord(unpack(M.Rings.COORDS.GREEN));

local settingsScrollChild = E.CreateScrollFrame(MazeHelper.frame.Settings, 26);

settingsScrollChild.Data.AutoToggleVisibility = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.AutoToggleVisibility:SetPosition('TOPLEFT', settingsScrollChild, 'TOPLEFT', 12, 0);
settingsScrollChild.Data.AutoToggleVisibility:SetLabel(L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL']);
settingsScrollChild.Data.AutoToggleVisibility:SetTooltip(L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP']);
settingsScrollChild.Data.AutoToggleVisibility:SetScript('OnClick', function(self)
    MHMOTSConfig.AutoToggleVisibility = self:GetChecked();
end);

settingsScrollChild.Data.SyncEnabled = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.SyncEnabled:SetPosition('TOPLEFT', settingsScrollChild.Data.AutoToggleVisibility, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.SyncEnabled:SetLabel(L['SETTINGS_SYNC_ENABLED_LABEL']);
settingsScrollChild.Data.SyncEnabled:SetTooltip(L['SETTINGS_SYNC_ENABLED_TOOLTIP']);
settingsScrollChild.Data.SyncEnabled:SetScript('OnClick', function(self)
    MHMOTSConfig.SyncEnabled = self:GetChecked();
end);

settingsScrollChild.Data.ShowAtBoss = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.ShowAtBoss:SetPosition('TOPLEFT', settingsScrollChild.Data.SyncEnabled, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.ShowAtBoss:SetLabel(L['SETTINGS_SHOW_AT_BOSS_LABEL']);
settingsScrollChild.Data.ShowAtBoss:SetTooltip(L['SETTINGS_SHOW_AT_BOSS_TOOLTIP']);
settingsScrollChild.Data.ShowAtBoss:SetScript('OnClick', function(self)
    MHMOTSConfig.ShowAtBoss = self:GetChecked();
end);

settingsScrollChild.Data.PredictSolution = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.PredictSolution:SetPosition('TOPLEFT', settingsScrollChild.Data.ShowAtBoss, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.PredictSolution:SetLabel(M.INLINE_NEW_ICON .. L['SETTINGS_PREDICT_SOLUTION_LABEL']);
settingsScrollChild.Data.PredictSolution:SetTooltip(L['SETTINGS_PREDICT_SOLUTION_TOOLTIP']);
settingsScrollChild.Data.PredictSolution:SetScript('OnClick', function(self)
    MHMOTSConfig.PredictSolution = self:GetChecked();
    ResetAll();
end);

settingsScrollChild.Data.ShowLargeSymbol = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.ShowLargeSymbol:SetPosition('TOPLEFT', settingsScrollChild.Data.PredictSolution, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.ShowLargeSymbol:SetLabel(L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL']);
settingsScrollChild.Data.ShowLargeSymbol:SetTooltip(L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP']);
settingsScrollChild.Data.ShowLargeSymbol:SetScript('OnClick', function(self)
    MHMOTSConfig.ShowLargeSymbol = self:GetChecked();

    if SOLUTION_BUTTON_ID then
        MazeHelper.frame.LargeSymbol:SetShown(MHMOTSConfig.ShowLargeSymbol);
    end
end);

settingsScrollChild.Data.SetMarkerSolutionPlayer = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.SetMarkerSolutionPlayer:SetPosition('TOPLEFT', settingsScrollChild.Data.ShowLargeSymbol, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.SetMarkerSolutionPlayer:SetLabel(L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL']);
settingsScrollChild.Data.SetMarkerSolutionPlayer:SetTooltip(L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP']);
settingsScrollChild.Data.SetMarkerSolutionPlayer:SetScript('OnClick', function(self)
    MHMOTSConfig.SetMarkerSolutionPlayer = self:GetChecked();

    if not MHMOTSConfig.SetMarkerSolutionPlayer then
        if GetRaidTargetIndex('player') == SOLUTION_PLAYER_MARKER then
            SetRaidTarget('player', 0);
        end
    end
end);

settingsScrollChild.Data.UseCloneAutoMarker = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.UseCloneAutoMarker:SetPosition('TOPLEFT', settingsScrollChild.Data.SetMarkerSolutionPlayer, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.UseCloneAutoMarker:SetLabel(L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL']);
settingsScrollChild.Data.UseCloneAutoMarker:SetTooltip(L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP']);
settingsScrollChild.Data.UseCloneAutoMarker:SetScript('OnClick', function(self)
    MHMOTSConfig.UseCloneAutoMarker = self:GetChecked();

    if MHMOTSConfig.UseCloneAutoMarker and inEncounter then
        for _, event in ipairs(EVENTS_AUTOMARKER) do
            MazeHelper.frame:RegisterEvent(event);
        end
    else
        for _, event in ipairs(EVENTS_AUTOMARKER) do
            MazeHelper.frame:UnregisterEvent(event);
        end
    end
end);

settingsScrollChild.Data.SetMarkerOnTargetClone = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.SetMarkerOnTargetClone:SetPosition('TOPLEFT', settingsScrollChild.Data.UseCloneAutoMarker, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.SetMarkerOnTargetClone:SetLabel(L['SETTINGS_SKULLMARKER_CLONE_LABEL']);
settingsScrollChild.Data.SetMarkerOnTargetClone:SetTooltip(L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP']);
settingsScrollChild.Data.SetMarkerOnTargetClone:SetScript('OnClick', function(self)
    MHMOTSConfig.SetMarkerOnTargetClone = self:GetChecked();

    if MHMOTSConfig.SetMarkerOnTargetClone and inEncounter then
        for _, event in ipairs(EVENTS_SKULLMARKER) do
            MazeHelper.frame:RegisterEvent(event);
        end
    else
        for _, event in ipairs(EVENTS_SKULLMARKER) do
            MazeHelper.frame:UnregisterEvent(event);
        end
    end

    if MHMOTSConfig.SetMarkerOnTargetClone then
        settingsScrollChild.Data.SetMarkerOnTargetCloneUseModifier:SetEnabled(true);
        settingsScrollChild.Data.SetMarkerOnTargetCloneModifier:SetEnabled(MHMOTSConfig.SetMarkerOnTargetCloneUseModifier);
    else
        settingsScrollChild.Data.SetMarkerOnTargetCloneUseModifier:SetEnabled(false);
        settingsScrollChild.Data.SetMarkerOnTargetCloneModifier:SetEnabled(false);
    end
end);

settingsScrollChild.Data.SetMarkerOnTargetCloneUseModifier = E.CreateCheckButton('MazeHelper_Settings_SetMarkerOnTargetCloneUseModifier_CheckButton', settingsScrollChild);
settingsScrollChild.Data.SetMarkerOnTargetCloneUseModifier:SetPosition('LEFT', settingsScrollChild.Data.SetMarkerOnTargetClone.Label, 'RIGHT', 6, 0);
settingsScrollChild.Data.SetMarkerOnTargetCloneUseModifier:SetTooltip(L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP']);
settingsScrollChild.Data.SetMarkerOnTargetCloneUseModifier:SetScript('OnClick', function(self)
    MHMOTSConfig.SetMarkerOnTargetCloneUseModifier = self:GetChecked();

    settingsScrollChild.Data.SetMarkerOnTargetCloneModifier:SetEnabled(MHMOTSConfig.SetMarkerOnTargetCloneUseModifier);
end);

settingsScrollChild.Data.SetMarkerOnTargetCloneModifier = E.CreateDropdown(settingsScrollChild);
settingsScrollChild.Data.SetMarkerOnTargetCloneModifier:SetPoint('LEFT', settingsScrollChild.Data.SetMarkerOnTargetCloneUseModifier.Label, 'RIGHT', 2, 0);
settingsScrollChild.Data.SetMarkerOnTargetCloneModifier:SetSize(70, 24);
settingsScrollChild.Data.SetMarkerOnTargetCloneModifier:SetScale(0.85);
settingsScrollChild.Data.SetMarkerOnTargetCloneModifier:SetList(MODIFIERS_LIST);
settingsScrollChild.Data.SetMarkerOnTargetCloneModifier.OnValueChangedCallback = function(_, value)
    MHMOTSConfig.SetMarkerOnTargetCloneModifier = tonumber(value);
end

settingsScrollChild.Data.UseColoredSymbols = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.UseColoredSymbols:SetPosition('TOPLEFT', settingsScrollChild.Data.SetMarkerOnTargetClone, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.UseColoredSymbols:SetLabel(L['SETTINGS_USE_COLORED_SYMBOLS_LABEL']);
settingsScrollChild.Data.UseColoredSymbols:SetTooltip(L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP']);
settingsScrollChild.Data.UseColoredSymbols:SetScript('OnClick', function(self)
    MHMOTSConfig.UseColoredSymbols = self:GetChecked();

    for i = 1, MAX_BUTTONS do
        buttons[i].Icon:SetTexCoord(unpack(MHMOTSConfig.UseColoredSymbols and buttonsData[i].coords or buttonsData[i].coords_white));
    end

    if SOLUTION_BUTTON_ID then
        MazeHelper.frame.LargeSymbol.Icon:SetTexCoord(unpack(MHMOTSConfig.UseColoredSymbols and buttonsData[SOLUTION_BUTTON_ID].coords or buttonsData[SOLUTION_BUTTON_ID].coords_white));
    end
end);

settingsScrollChild.Data.ShowSequenceNumbers = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.ShowSequenceNumbers:SetPosition('TOPLEFT', settingsScrollChild.Data.UseColoredSymbols, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.ShowSequenceNumbers:SetLabel(L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL']);
settingsScrollChild.Data.ShowSequenceNumbers:SetTooltip(L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP']);
settingsScrollChild.Data.ShowSequenceNumbers:SetScript('OnClick', function(self)
    MHMOTSConfig.ShowSequenceNumbers = self:GetChecked();

    for i = 1, MAX_BUTTONS do
        buttons[i].SequenceText:SetShown(MHMOTSConfig.ShowSequenceNumbers);
    end
end);

settingsScrollChild.Data.StartInMinMode = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.StartInMinMode:SetPosition('TOPLEFT', settingsScrollChild.Data.ShowSequenceNumbers, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.StartInMinMode:SetLabel(L['SETTINGS_START_IN_MINMODE_LABEL']);
settingsScrollChild.Data.StartInMinMode:SetTooltip(L['SETTINGS_START_IN_MINMODE_TOOLTIP']);
settingsScrollChild.Data.StartInMinMode:SetScript('OnClick', function(self)
    MHMOTSConfig.StartInMinMode = self:GetChecked();
end);

settingsScrollChild.Data.PrintResettedPlayerName = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.PrintResettedPlayerName:SetPosition('TOPLEFT', settingsScrollChild.Data.StartInMinMode, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.PrintResettedPlayerName:SetLabel(L['SETTINGS_REVEAL_RESETTER_LABEL']);
settingsScrollChild.Data.PrintResettedPlayerName:SetTooltip(L['SETTINGS_REVEAL_RESETTER_TOOLTIP']);
settingsScrollChild.Data.PrintResettedPlayerName:SetScript('OnClick', function(self)
    MHMOTSConfig.PrintResettedPlayerName = self:GetChecked();
end);

settingsScrollChild.Data.AnnounceOnlyEnglish = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.AnnounceOnlyEnglish:SetPosition('TOPLEFT', settingsScrollChild.Data.PrintResettedPlayerName, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.AnnounceOnlyEnglish:SetLabel(M.INLINE_NEW_ICON .. L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL']);
settingsScrollChild.Data.AnnounceOnlyEnglish:SetTooltip(L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP']);
settingsScrollChild.Data.AnnounceOnlyEnglish:SetScript('OnClick', function(self)
    MHMOTSConfig.AnnounceOnlyEnglish = self:GetChecked();

    settingsScrollChild.Data.AnnounceWithEnglish:SetEnabled(not MHMOTSConfig.AnnounceOnlyEnglish);
end);

settingsScrollChild.Data.AnnounceWithEnglish = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.AnnounceWithEnglish:SetPosition('TOPLEFT', settingsScrollChild.Data.AnnounceOnlyEnglish, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.AnnounceWithEnglish:SetLabel(L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL']);
settingsScrollChild.Data.AnnounceWithEnglish:SetTooltip(L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP']);
settingsScrollChild.Data.AnnounceWithEnglish:SetScript('OnClick', function(self)
    MHMOTSConfig.AnnounceWithEnglish = self:GetChecked();
end);

settingsScrollChild.Data.AutoAnnouncer = E.CreateRoundedCheckButton(settingsScrollChild);
settingsScrollChild.Data.AutoAnnouncer:SetPosition('TOPLEFT', settingsScrollChild.Data.AnnounceWithEnglish, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.AutoAnnouncer:SetLabel(L['SETTINGS_AUTOANNOUNCER_LABEL']);
settingsScrollChild.Data.AutoAnnouncer:SetTooltip(L['SETTINGS_AUTOANNOUNCER_TOOLTIP']);
settingsScrollChild.Data.AutoAnnouncer:SetScript('OnClick', function(self)
    MHMOTSConfig.AutoAnnouncer = self:GetChecked();

    settingsScrollChild.Data.AutoAnnouncerAsPartyLeader:SetEnabled(MHMOTSConfig.AutoAnnouncer);
    settingsScrollChild.Data.AutoAnnouncerAsAlways:SetEnabled(MHMOTSConfig.AutoAnnouncer);
    settingsScrollChild.Data.AutoAnnouncerAsTank:SetEnabled(MHMOTSConfig.AutoAnnouncer);
    settingsScrollChild.Data.AutoAnnouncerAsHealer:SetEnabled(MHMOTSConfig.AutoAnnouncer);
end);

settingsScrollChild.Data.AutoAnnouncerAsPartyLeader = E.CreateCheckButton('MazeHelper_Settings_AutoAnnouncerAsPartyLeader_CheckButton', settingsScrollChild);
settingsScrollChild.Data.AutoAnnouncerAsPartyLeader:SetPosition('TOPLEFT', settingsScrollChild.Data.AutoAnnouncer, 'BOTTOMRIGHT', 0, 2);
settingsScrollChild.Data.AutoAnnouncerAsPartyLeader:SetLabel(M.INLINE_LEADER_ICON);
settingsScrollChild.Data.AutoAnnouncerAsPartyLeader:SetTooltip(L['SETTINGS_AA_PARTY_LEADER']);
settingsScrollChild.Data.AutoAnnouncerAsPartyLeader:SetScript('OnClick', function(self)
    MHMOTSConfig.AutoAnnouncerAsPartyLeader = self:GetChecked();
end);

settingsScrollChild.Data.AutoAnnouncerAsAlways = E.CreateCheckButton('MazeHelper_Settings_AutoAnnouncerAsAlways_CheckButton', settingsScrollChild);
settingsScrollChild.Data.AutoAnnouncerAsAlways:SetPosition('LEFT', settingsScrollChild.Data.AutoAnnouncerAsPartyLeader.Label, 'RIGHT', 12, 0);
settingsScrollChild.Data.AutoAnnouncerAsAlways:SetLabel(M.INLINE_INFINITY_ICON);
settingsScrollChild.Data.AutoAnnouncerAsAlways:SetTooltip(L['SETTINGS_AA_ALWAYS']);
settingsScrollChild.Data.AutoAnnouncerAsAlways:SetScript('OnClick', function(self)
    MHMOTSConfig.AutoAnnouncerAsAlways = self:GetChecked();
end);

settingsScrollChild.Data.AutoAnnouncerAsTank = E.CreateCheckButton('MazeHelper_Settings_AutoAnnouncerAsTank_CheckButton', settingsScrollChild);
settingsScrollChild.Data.AutoAnnouncerAsTank:SetPosition('LEFT', settingsScrollChild.Data.AutoAnnouncerAsAlways.Label, 'RIGHT', 12, 0);
settingsScrollChild.Data.AutoAnnouncerAsTank:SetLabel(M.INLINE_TANK_ICON);
settingsScrollChild.Data.AutoAnnouncerAsTank:SetTooltip(L['SETTINGS_AA_TANK']);
settingsScrollChild.Data.AutoAnnouncerAsTank:SetScript('OnClick', function(self)
    MHMOTSConfig.AutoAnnouncerAsTank = self:GetChecked();
end);

settingsScrollChild.Data.AutoAnnouncerAsHealer = E.CreateCheckButton('MazeHelper_Settings_AutoAnnouncerAsHealer_CheckButton', settingsScrollChild);
settingsScrollChild.Data.AutoAnnouncerAsHealer:SetPosition('LEFT', settingsScrollChild.Data.AutoAnnouncerAsTank.Label, 'RIGHT', 12, 0);
settingsScrollChild.Data.AutoAnnouncerAsHealer:SetLabel(M.INLINE_HEALER_ICON);
settingsScrollChild.Data.AutoAnnouncerAsHealer:SetTooltip(L['SETTINGS_AA_HEALER']);
settingsScrollChild.Data.AutoAnnouncerAsHealer:SetScript('OnClick', function(self)
    MHMOTSConfig.AutoAnnouncerAsHealer = self:GetChecked();
end);

settingsScrollChild.Data.AutoAnnouncerChannel = E.CreateDropdown(settingsScrollChild);
settingsScrollChild.Data.AutoAnnouncerChannel:SetPoint('TOPLEFT', settingsScrollChild.Data.AutoAnnouncerAsPartyLeader, 'BOTTOMLEFT', 3, -6);
settingsScrollChild.Data.AutoAnnouncerChannel:SetSize(90, 20);
settingsScrollChild.Data.AutoAnnouncerChannel:SetScale(1);
settingsScrollChild.Data.AutoAnnouncerChannel:SetLabel(M.INLINE_NEW_ICON .. L['SETTINGS_AUTOANNOUNCE_CHANNEL']);
settingsScrollChild.Data.AutoAnnouncerChannel:SetTooltip(L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP']);
settingsScrollChild.Data.AutoAnnouncerChannel:SetList(CHANNELS_LIST_LOCALIZED);
settingsScrollChild.Data.AutoAnnouncerChannel.OnValueChangedCallback = function(_, value)
    MHMOTSConfig.AutoAnnouncerChannel = tonumber(value);
end

settingsScrollChild.Data.ColorsHeader = E.CreateHeader(settingsScrollChild, L['SETTINGS_BORDERS_COLORS']);
settingsScrollChild.Data.ColorsHeader:SetPosition('TOPLEFT', settingsScrollChild.Data.AutoAnnouncer, 'BOTTOMLEFT', 0, -56);
settingsScrollChild.Data.ColorsHeader:SetSize(settingsScrollChild:GetWidth() - 4, 18);

settingsScrollChild.Data.ActiveColorPicker = E.CreateColorPicker(settingsScrollChild, DEFAULT_COLORS.Active)
PixelUtil.SetPoint(settingsScrollChild.Data.ActiveColorPicker, 'TOPLEFT', settingsScrollChild.Data.ColorsHeader, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.ActiveColorPicker:SetLabel(L['SETTINGS_ACTIVE_COLORPICKER']);
settingsScrollChild.Data.ActiveColorPicker.OnValueChanged = function(_, r, g, b, a)
    MHMOTSConfig.ActiveColor[1] = r;
    MHMOTSConfig.ActiveColor[2] = g;
    MHMOTSConfig.ActiveColor[3] = b;
    MHMOTSConfig.ActiveColor[4] = a;

    BorderColor_UpdateAll();
end

settingsScrollChild.Data.ReceivedColorPicker = E.CreateColorPicker(settingsScrollChild, DEFAULT_COLORS.Received)
PixelUtil.SetPoint(settingsScrollChild.Data.ReceivedColorPicker, 'TOPLEFT', settingsScrollChild.Data.ColorsHeader, 'BOTTOMLEFT', settingsScrollChild.Data.ColorsHeader:GetWidth() / 2, 0);
settingsScrollChild.Data.ReceivedColorPicker:SetLabel(L['SETTINGS_RECEIVED_COLORPICKER']);
settingsScrollChild.Data.ReceivedColorPicker.OnValueChanged = function(_, r, g, b, a)
    MHMOTSConfig.ReceivedColor[1] = r;
    MHMOTSConfig.ReceivedColor[2] = g;
    MHMOTSConfig.ReceivedColor[3] = b;
    MHMOTSConfig.ReceivedColor[4] = a;

    BorderColor_UpdateAll();
end

settingsScrollChild.Data.SolutionColorPicker = E.CreateColorPicker(settingsScrollChild, DEFAULT_COLORS.Solution)
PixelUtil.SetPoint(settingsScrollChild.Data.SolutionColorPicker, 'TOPLEFT', settingsScrollChild.Data.ActiveColorPicker, 'BOTTOMLEFT', 0, 0);
settingsScrollChild.Data.SolutionColorPicker:SetLabel(L['SETTINGS_SOLUTION_COLORPICKER']);
settingsScrollChild.Data.SolutionColorPicker.OnValueChanged = function(_, r, g, b, a)
    MHMOTSConfig.SolutionColor[1] = r;
    MHMOTSConfig.SolutionColor[2] = g;
    MHMOTSConfig.SolutionColor[3] = b;
    MHMOTSConfig.SolutionColor[4] = a;

    BorderColor_UpdateAll();
end

settingsScrollChild.Data.PredictedColorPicker = E.CreateColorPicker(settingsScrollChild, DEFAULT_COLORS.Predicted)
PixelUtil.SetPoint(settingsScrollChild.Data.PredictedColorPicker, 'TOPLEFT', settingsScrollChild.Data.ActiveColorPicker, 'BOTTOMLEFT', settingsScrollChild.Data.ColorsHeader:GetWidth() / 2, 0);
settingsScrollChild.Data.PredictedColorPicker:SetLabel(L['SETTINGS_PREDICTED_COLORPICKER']);
settingsScrollChild.Data.PredictedColorPicker.OnValueChanged = function(_, r, g, b, a)
    MHMOTSConfig.PredictedColor[1] = r;
    MHMOTSConfig.PredictedColor[2] = g;
    MHMOTSConfig.PredictedColor[3] = b;
    MHMOTSConfig.PredictedColor[4] = a;

    BorderColor_UpdateAll();
end

settingsScrollChild.Data.EmptyHeader = E.CreateHeader(settingsScrollChild);
settingsScrollChild.Data.EmptyHeader:SetPosition('TOPLEFT', settingsScrollChild.Data.SolutionColorPicker, 'BOTTOMLEFT', 0, -30);
settingsScrollChild.Data.EmptyHeader:SetSize(settingsScrollChild:GetWidth() - 4, 18);

settingsScrollChild.Data.ResetColorsButton = CreateFrame('Button', nil, settingsScrollChild, 'SharedButtonSmallTemplate');
PixelUtil.SetPoint(settingsScrollChild.Data.ResetColorsButton, 'BOTTOM', settingsScrollChild.Data.EmptyHeader, 'TOP', 0, 0);
settingsScrollChild.Data.ResetColorsButton:SetText(L['RESET']);
PixelUtil.SetSize(settingsScrollChild.Data.ResetColorsButton, tonumber(settingsScrollChild.Data.ResetColorsButton:GetTextWidth()) + 20, 22);
settingsScrollChild.Data.ResetColorsButton:SetScript('OnClick', function()
    settingsScrollChild.Data.ActiveColorPicker:SetValue(unpack(DEFAULT_COLORS.Active));
    settingsScrollChild.Data.ReceivedColorPicker:SetValue(unpack(DEFAULT_COLORS.Received));
    settingsScrollChild.Data.SolutionColorPicker:SetValue(unpack(DEFAULT_COLORS.Solution));
    settingsScrollChild.Data.PredictedColorPicker:SetValue(unpack(DEFAULT_COLORS.Predicted));

    BorderColor_UpdateAll();
end);

settingsScrollChild.Data.Scale = E.CreateSlider('Scale', settingsScrollChild);
settingsScrollChild.Data.Scale:SetPosition('TOPLEFT', settingsScrollChild.Data.EmptyHeader, 'BOTTOMLEFT', 0, -21);
PixelUtil.SetWidth(settingsScrollChild.Data.Scale, SLIDER_FULL_WIDTH);
settingsScrollChild.Data.Scale:SetLabel(L['SETTINGS_SCALE_LABEL']);
settingsScrollChild.Data.Scale:SetTooltip(L['SETTINGS_SCALE_TOOLTIP']);
settingsScrollChild.Data.Scale.OnMouseUpCallback = function(_, value)
    MHMOTSConfig.SavedScale = tonumber(value);
    BetterSetScale(MazeHelper.frame, MHMOTSConfig.SavedScale, MHMOTSConfig.SavedPosition);
end

settingsScrollChild.Data.ScaleLargeSymbol = E.CreateSlider('Scale', settingsScrollChild);
settingsScrollChild.Data.ScaleLargeSymbol:SetPosition('TOPLEFT', settingsScrollChild.Data.Scale, 'BOTTOMLEFT', 0, -42);
PixelUtil.SetWidth(settingsScrollChild.Data.ScaleLargeSymbol, SLIDER_FULL_WIDTH);
settingsScrollChild.Data.ScaleLargeSymbol:SetLabel(L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL']);
settingsScrollChild.Data.ScaleLargeSymbol:SetTooltip(L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP']);
settingsScrollChild.Data.ScaleLargeSymbol.OnMouseUpCallback = function(_, value)
    MHMOTSConfig.SavedScaleLargeSymbol = tonumber(value);
    BetterSetScale(MazeHelper.frame.LargeSymbol, MHMOTSConfig.SavedScaleLargeSymbol, MHMOTSConfig.SavedPositionLargeSymbol, true);
end

settingsScrollChild.Data.SavedBackgroundAlpha = E.CreateSlider('Scale', settingsScrollChild);
settingsScrollChild.Data.SavedBackgroundAlpha:SetPosition('TOPLEFT', settingsScrollChild.Data.ScaleLargeSymbol, 'BOTTOMLEFT', 0, -42);
PixelUtil.SetWidth(settingsScrollChild.Data.SavedBackgroundAlpha, SLIDER_FULL_WIDTH);
settingsScrollChild.Data.SavedBackgroundAlpha:SetLabel(L['SETTINGS_ALPHA_BACKGROUND_LABEL']);
settingsScrollChild.Data.SavedBackgroundAlpha:SetTooltip(L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP']);
settingsScrollChild.Data.SavedBackgroundAlpha.OnValueChangedCallback = function(_, value)
    MHMOTSConfig.SavedBackgroundAlpha = tonumber(value);
    MazeHelper.frame.background:SetAlpha(MHMOTSConfig.SavedBackgroundAlpha);
end

settingsScrollChild.Data.SavedBackgroundAlphaLargeSymbol = E.CreateSlider('Scale', settingsScrollChild);
settingsScrollChild.Data.SavedBackgroundAlphaLargeSymbol:SetPosition('TOPLEFT', settingsScrollChild.Data.SavedBackgroundAlpha, 'BOTTOMLEFT', 0, -42);
PixelUtil.SetWidth(settingsScrollChild.Data.SavedBackgroundAlphaLargeSymbol, SLIDER_FULL_WIDTH);
settingsScrollChild.Data.SavedBackgroundAlphaLargeSymbol:SetLabel(L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL']);
settingsScrollChild.Data.SavedBackgroundAlphaLargeSymbol:SetTooltip(L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP']);
settingsScrollChild.Data.SavedBackgroundAlphaLargeSymbol.OnValueChangedCallback = function(_, value)
    MHMOTSConfig.SavedBackgroundAlphaLargeSymbol = tonumber(value);
    MazeHelper.frame.LargeSymbol.Background:SetAlpha(MHMOTSConfig.SavedBackgroundAlphaLargeSymbol);
end

-- send & sender can be nil
local function Button_SetActive(button, send, sender, isDoubleClick)
    if isDoubleClick or IsShiftKeyDown() then
        if button.sequence == 1 then
            isPredictedTemporaryOff = true;
            button.SequenceText:SetText(1);

            if send then
                MazeHelper:SendButtonID(button.id, 'ACTIVE', isPredictedTemporaryOff);
            end
        end
    end

    if button.state or NUM_ACTIVE_BUTTONS == MAX_ACTIVE_BUTTONS then
        return;
    end

    MazeHelper.frame.ResetButton:SetEnabled(true);

    NUM_ACTIVE_BUTTONS = math.min(MAX_ACTIVE_BUTTONS, NUM_ACTIVE_BUTTONS + 1);

    if NUM_ACTIVE_BUTTONS == 1 and IsShiftKeyDown() then
        isPredictedTemporaryOff = true;
    end

    button.state  = true;
    button.sender = sender;

    button:UpdateBorder();
    button:UpdateSequence();

    MazeHelper.frame.SolutionText:SetText(L['CHOOSE_SYMBOLS_' .. (MAX_ACTIVE_BUTTONS - NUM_ACTIVE_BUTTONS)]);

    if send then
        MazeHelper:SendButtonID(button.id, 'ACTIVE', isPredictedTemporaryOff);
    end

    MazeHelper:UpdateSolution();

    if MHMOTSConfig.SetMarkerSolutionPlayer then
        if not inEncounter and not sender and SOLUTION_BUTTON_ID and not PREDICTED_SOLUTION_BUTTON_ID and button.id == SOLUTION_BUTTON_ID then
            if GetRaidTargetIndex('player') ~= SOLUTION_PLAYER_MARKER then
                SetRaidTarget('player', SOLUTION_PLAYER_MARKER);
            end
        end
    end
end

-- send & sender can be nil
local function Button_SetUnactive(button, send, sender)
    if not button.state then
        return;
    end

    NUM_ACTIVE_BUTTONS = math.max(0, NUM_ACTIVE_BUTTONS - 1);

    button.state  = false;
    button.sender = sender;

    button:SetUnactiveBorder();
    button:ResetSequence();

    if NUM_ACTIVE_BUTTONS < MAX_ACTIVE_BUTTONS then
        MazeHelper.frame.SolutionText:SetText(L['CHOOSE_SYMBOLS_' .. (MAX_ACTIVE_BUTTONS - NUM_ACTIVE_BUTTONS)]);

        if SOLUTION_BUTTON_ID then
            buttons[SOLUTION_BUTTON_ID]:SetUnactiveBorder();
        end

        for i = 1, MAX_BUTTONS do
            buttons[i]:UpdateBorder();
        end

        MazeHelper.frame.PassedButton:SetEnabled(false);
        MazeHelper.frame.AnnounceButton:Hide();
        MazeHelper.frame.AnnounceButton.clicked = false;

        if MHMOTSConfig.SetMarkerSolutionPlayer then
            if not inEncounter and not sender and SOLUTION_BUTTON_ID and not PREDICTED_SOLUTION_BUTTON_ID and button.id == SOLUTION_BUTTON_ID then
                if GetRaidTargetIndex('player') == SOLUTION_PLAYER_MARKER then
                    SetRaidTarget('player', 0);
                end
            end
        end

        MazeHelper:UpdateSolution();
    end

    if NUM_ACTIVE_BUTTONS == 0 then
        MazeHelper.frame.ResetButton:SetEnabled(false);
        isPredictedTemporaryOff = false;
    end

    if send then
        MazeHelper:SendButtonID(button.id, 'UNACTIVE', isPredictedTemporaryOff);
    end
end

local function GetMinimumReservedSequence()
    for i = 1, #RESERVED_BUTTONS_SEQUENCE do
        if RESERVED_BUTTONS_SEQUENCE[i] == false then
            return i;
        end
    end
end

local BUTTON_BACKDROP = {
    insets   = { top = 1, left = 1, bottom = 1, right = 1 },
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    edgeSize = 2,
};

function MazeHelper:CreateButton(index)
    local button = CreateFrame('Button', nil, MazeHelper.frame.MainHolder, 'BackdropTemplate');

    button.id    = index;
    button.data  = buttonsData[index];
    button.state = false;

    if index == 1 then
        PixelUtil.SetPoint(button, 'TOPLEFT', MazeHelper.frame.MainHolder, 'TOPLEFT', 20, -20);
    elseif index == 5 then
        PixelUtil.SetPoint(button, 'TOPLEFT', buttons[1], 'BOTTOMLEFT', 0, Y_OFFSET);
    else
        PixelUtil.SetPoint(button, 'LEFT', buttons[index - 1], 'RIGHT', X_OFFSET, 0);
    end

    PixelUtil.SetSize(button, BUTTON_SIZE, BUTTON_SIZE);

    button.Icon = button:CreateTexture(nil, 'ARTWORK');
    PixelUtil.SetPoint(button.Icon, 'TOPLEFT', button, 'TOPLEFT', 4, -4);
    PixelUtil.SetPoint(button.Icon, 'BOTTOMRIGHT', button, 'BOTTOMRIGHT', -4, 4);
    button.Icon:SetTexture(M.Symbols.TEXTURE);
    button.Icon:SetTexCoord(unpack(MHMOTSConfig.UseColoredSymbols and buttonsData[index].coords or buttonsData[index].coords_white));

    button.SequenceText = button:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
    PixelUtil.SetPoint(button.SequenceText, 'BOTTOMRIGHT', button, 'BOTTOMRIGHT', -2, 2);
    button.SequenceText:SetShown(MHMOTSConfig.ShowSequenceNumbers);

    button:SetBackdrop(BUTTON_BACKDROP);

    button.SetActiveBorder = function(self)
        self:SetBackdropBorderColor(unpack(MHMOTSConfig.ActiveColor));
    end

    button.SetUnactiveBorder = function(self)
        self:SetBackdropBorderColor(0, 0, 0, 0);
    end

    button.SetReceivedBorder = function(self)
        self:SetBackdropBorderColor(unpack(MHMOTSConfig.ReceivedColor));
    end

    button.SetSolutionBorder = function(self)
        self:SetBackdropBorderColor(unpack(MHMOTSConfig.SolutionColor));
    end

    button.SetPredictedBorder = function(self)
        self:SetBackdropBorderColor(unpack(MHMOTSConfig.PredictedColor));
    end

    button.UpdateBorder = function(self)
        if self.state then
            if self.sender then
                self:SetReceivedBorder();
            else
                self:SetActiveBorder();
            end
        else
            self:SetUnactiveBorder();
        end
    end

    button.UpdateSequence = function(self)
        self.sequence = GetMinimumReservedSequence();
        RESERVED_BUTTONS_SEQUENCE[self.sequence] = true;

        self.SequenceText:SetText((not isPredictedTemporaryOff and MHMOTSConfig.PredictSolution and self.sequence == 1) and M.INLINE_ENTRANCE_ICON or self.sequence);
    end

    button.ResetSequence = function(self)
        if self.sequence then
            RESERVED_BUTTONS_SEQUENCE[self.sequence] = false;
            self.sequence = nil;
        end

        self.SequenceText:SetText('');
    end

    button:SetUnactiveBorder();
    button:RegisterForClicks('LeftButtonUp', 'RightButtonUp');

    button:SetScript('OnClick', function(self, b)
        if b == 'LeftButton' then
            Button_SetActive(self, true);
        elseif b == 'RightButton' then
            Button_SetUnactive(self, true);
        end
    end);

    button:SetScript('OnDoubleClick', function(self, b)
        if b == 'LeftButton' then
            Button_SetActive(self, true, nil, true);
        end
    end);

    button:HookScript('OnEnter', function(self)
        if not self.sender then
            self.tooltip = nil;
            return;
        end

        self.tooltip = self.state and string.format(L['SENDED_BY'], self.sender) or string.format(L['CLEARED_BY'], self.sender);
    end);

    E.CreateTooltip(button);

    button:RegisterForDrag('LeftButton');
    button:SetScript('OnDragStart', function()
        if MazeHelper.frame:IsMovable() and not MHMOTSConfig.LockedDrag then
            MazeHelper.frame:StartMoving();
        end
    end);
    button:SetScript('OnDragStop', function()
        BetterOnDragStop(MazeHelper.frame, MHMOTSConfig.SavedPosition);
    end);

    button:HookScript('OnEnter', function()
        MazeHelper.frame.LockDragButton:SetShown(not isMinimized);
    end);

    button:HookScript('OnLeave', function()
        if not MazeHelper.frame.LockDragButton:IsMouseOver() then
            MazeHelper.frame.LockDragButton:Hide();
        end
    end);

    table.insert(buttons, index, button); -- index for just to be sure
end

function MazeHelper:CreateButtons()
    for i = 1, MAX_BUTTONS do
        MazeHelper:CreateButton(i);
    end
end

-- Credit to Garthul#2712
-- Main idea: 
-- The solution is the opposite of entrance symbol or opposite of an existing symbol that shares two features with entrance symbol.
-- Order of conditions matter.
local TryHeuristicSolution do
    local filterTable = {};

    local reusableOppositeTable = {
        fill   = false,
        leaf   = false,
        circle = false,
    };

    local function Filter(b, f) wipe(filterTable); for i, v in pairs(b) do if f(v) then filterTable[i] = v; end end return filterTable; end
    local function Find(b, f) for i, v in pairs(b) do if f(v) then return i, v; end end end
    local function Equals(s1, s2) return s1.fill == s2.fill and s1.leaf == s2.leaf and s1.circle == s2.circle; end
    local function Opposite(s)
        reusableOppositeTable.fill   = not s.fill;
        reusableOppositeTable.leaf   = not s.leaf;
        reusableOppositeTable.circle = not s.circle;

        return reusableOppositeTable;
    end
    local function NumberOfSharedFeatures(s1, s2) return (s1.fill == s2.fill and 1 or 0) + (s1.leaf == s2.leaf and 1 or 0) + (s1.circle == s2.circle and 1 or 0); end

    local IsActiveButtonFunction = function(b) return b.state; end
    local IsEntranceButtonFunction = function(b) return b.state and b.sequence == 1; end

    function TryHeuristicSolution()
        if inEncounter then
            return nil;
        end

        local activeButtons = Filter(buttons, IsActiveButtonFunction);
        local _, entranceButton = Find(activeButtons, IsEntranceButtonFunction);

        if entranceButton ~= nil then
            local IsOppositeOfEntranceFunction = function(b) return Equals(b.data, Opposite(entranceButton.data)); end
            local i, solutionButton = Find(activeButtons, IsOppositeOfEntranceFunction);
            if solutionButton ~= nil then
                return i;
            end

            local IsSharingTwoFeaturesWithEntrance = function(b) return NumberOfSharedFeatures(b.data, entranceButton.data) == 2; end
            local _, helperButton = Find(activeButtons, IsSharingTwoFeaturesWithEntrance);

            if helperButton ~= nil then
                local IsOppositeOfHelperFunction = function(b) return Equals(b.data, Opposite(helperButton.data)); end
                i, solutionButton = Find(activeButtons, IsOppositeOfHelperFunction);
                if solutionButton ~= nil then
                    return i;
                end

                local IsDifferentFromFirstAndSecond = function(b) return not Equals(b.data, helperButton.data) and not Equals(b.data, entranceButton.data); end
                local _, thirdButton = Find(activeButtons, IsDifferentFromFirstAndSecond);

                if thirdButton ~= nil then
                    local solutionSymbol;
                    local numSharedFeatures = NumberOfSharedFeatures(thirdButton.data, entranceButton.data);

                    if numSharedFeatures == 1 then
                        solutionSymbol = Opposite(helperButton.data);
                    elseif numSharedFeatures == 2 then
                        solutionSymbol = Opposite(entranceButton.data);
                    end

                    if solutionSymbol ~= nil then
                        local IsSolutionSymbol = function(b) return Equals(b.data, solutionSymbol); end
                        return Find(buttons, IsSolutionSymbol);
                    end
                end
            end
        end

        return nil;
    end
end

local TryFullSolution do
    local function GetSumCharacteristics()
        local fillSum, leafSum, circleSum = 0, 0, 0;

        for i = 1, MAX_BUTTONS do
            if buttons[i].state then
                if buttons[i].data.circle then
                    circleSum = circleSum + 1;
                end

                if buttons[i].data.leaf then
                    leafSum = leafSum + 1;
                end

                if buttons[i].data.fill then
                    fillSum = fillSum + 1;
                end
            end
        end

        return fillSum, leafSum, circleSum;
    end

    local function GetStagedSolution(kindSum, kind, sButtonId, sFoundCount)
        for i = 1, MAX_BUTTONS do
            if buttons[i].state then
                if (kindSum == 1 and buttons[i].data[kind]) or (kindSum == 3 and not buttons[i].data[kind]) then
                    return i, sFoundCount + 1;
                end
            end
        end

        return sButtonId, sFoundCount;
    end

    function TryFullSolution()
        local fillSum, leafSum, circleSum = GetSumCharacteristics();

        local sButtonId;
        local sFoundCount = 0;

        sButtonId, sFoundCount = GetStagedSolution(fillSum, 'fill', sButtonId, sFoundCount);
        sButtonId, sFoundCount = GetStagedSolution(leafSum, 'leaf', sButtonId, sFoundCount);
        sButtonId, sFoundCount = GetStagedSolution(circleSum, 'circle', sButtonId, sFoundCount);

        if sFoundCount > 1 then
            return;
        end

        return sButtonId;
    end
end


function MazeHelper:UpdateSolution()
    SOLUTION_BUTTON_ID = nil;

    if not isPredictedTemporaryOff and MHMOTSConfig.PredictSolution and NUM_ACTIVE_BUTTONS < MAX_ACTIVE_BUTTONS  then
        SOLUTION_BUTTON_ID = TryHeuristicSolution();
        PREDICTED_SOLUTION_BUTTON_ID = SOLUTION_BUTTON_ID or nil;
    end

    if NUM_ACTIVE_BUTTONS == MAX_ACTIVE_BUTTONS then
        if PREDICTED_SOLUTION_BUTTON_ID then
            buttons[PREDICTED_SOLUTION_BUTTON_ID]:UpdateBorder();

            PREDICTED_SOLUTION_BUTTON_ID = nil;
        end

        SOLUTION_BUTTON_ID = TryFullSolution();
    end

    if SOLUTION_BUTTON_ID then
        local partyChatType = GetPartyChatType();

        for i = 1, MAX_BUTTONS do
            if not buttons[i].state then
                buttons[i]:SetUnactiveBorder();
            end
        end

        if PREDICTED_SOLUTION_BUTTON_ID then
            buttons[PREDICTED_SOLUTION_BUTTON_ID]:SetPredictedBorder();
        else
            buttons[SOLUTION_BUTTON_ID]:SetSolutionBorder();
        end

        MazeHelper.frame.LargeSymbol.Icon:SetTexCoord(unpack(MHMOTSConfig.UseColoredSymbols and buttonsData[SOLUTION_BUTTON_ID].coords or buttonsData[SOLUTION_BUTTON_ID].coords_white));
        MazeHelper.frame.LargeSymbol:SetShown(MHMOTSConfig.ShowLargeSymbol);

        MazeHelper.frame.MiniSolution.Icon:SetTexCoord(unpack(MHMOTSConfig.UseColoredSymbols and buttonsData[SOLUTION_BUTTON_ID].coords or buttonsData[SOLUTION_BUTTON_ID].coords_white));

        MazeHelper.frame.AnnounceButton:SetShown((not isMinimized and partyChatType and not MHMOTSConfig.AutoAnnouncer) and true or false);
        MazeHelper.frame.PassedButton:SetEnabled(true);
        MazeHelper.frame.SolutionText:SetText(string.format(L['SOLUTION'], buttons[SOLUTION_BUTTON_ID].data.name));

        if isMinimized then
            MazeHelper.frame.MiniSolution:Show();
            MazeHelper.frame.PassedCounter:Hide();
        end

        if MHMOTSConfig.AutoAnnouncer and partyChatType then
            local announce = false;

            if MHMOTSConfig.AutoAnnouncerAsAlways then
                announce = true;
            elseif MHMOTSConfig.AutoAnnouncerAsPartyLeader and UnitIsGroupLeader('player') then
                announce = true;
            elseif MHMOTSConfig.AutoAnnouncerAsTank and playerRole == 'TANK' then
                announce = true;
            elseif MHMOTSConfig.AutoAnnouncerAsHealer and playerRole == 'HEALER' then
                announce = true;
            end

            if announce and ANNOUNCED_BUTTON_ID ~= SOLUTION_BUTTON_ID then
                ANNOUNCED_BUTTON_ID = SOLUTION_BUTTON_ID;
                AnnounceInChat(partyChatType);
            end
        end
    else
        MazeHelper.frame.LargeSymbol:Hide();
        MazeHelper.frame.MiniSolution:Hide();
        MazeHelper.frame.PassedCounter:Show();
        MazeHelper.frame.AnnounceButton:Hide();

        MazeHelper.frame.PassedButton:SetEnabled(false);

        if NUM_ACTIVE_BUTTONS == MAX_ACTIVE_BUTTONS then
            for i = 1, MAX_BUTTONS do
                buttons[i]:UpdateBorder();
            end

            MazeHelper.frame.SolutionText:SetText(L['SOLUTION_NA']);
        end
    end
end

function MazeHelper:SendResetCommand()
    if not MHMOTSConfig.SyncEnabled then
        return;
    end

    local partyChatType = GetPartyChatType();
    if not partyChatType then
        return;
    end

    ChatThrottleLib:SendAddonMessage(ADDON_COMM_MODE, ADDON_COMM_PREFIX, 'SendReset', partyChatType);
end

function MazeHelper:SendPassedCommand(isAutoPass)
    if not MHMOTSConfig.SyncEnabled then
        return;
    end

    local partyChatType = GetPartyChatType();
    if not partyChatType then
        return;
    end

    ChatThrottleLib:SendAddonMessage(ADDON_COMM_MODE, ADDON_COMM_PREFIX, isAutoPass and string.format('SendPassed|%s|%s', PASSED_COUNTER, 'AP') or string.format('SendPassed|%s', PASSED_COUNTER), partyChatType);
end

function MazeHelper:SendPassedCounter(step)
    if not MHMOTSConfig.SyncEnabled then
        return;
    end

    if step == PASSED_COUNTER then
        return;
    end

    local partyChatType = GetPartyChatType();
    if not partyChatType then
        return;
    end

    ChatThrottleLib:SendAddonMessage(ADDON_COMM_MODE, ADDON_COMM_PREFIX, string.format('RECPC|%s', PASSED_COUNTER), partyChatType);
end

function MazeHelper:RequestPassedCounter()
    if not MHMOTSConfig.SyncEnabled then
        return;
    end

    local partyChatType = GetPartyChatType();
    if not partyChatType then
        return;
    end

    ChatThrottleLib:SendAddonMessage(ADDON_COMM_MODE, ADDON_COMM_PREFIX, string.format('REQPC|%s', PASSED_COUNTER), partyChatType);
end

function MazeHelper:SendButtonID(buttonID, mode, isPredictedOff)
    if not MHMOTSConfig.SyncEnabled then
        return;
    end

    local partyChatType = GetPartyChatType();
    if not partyChatType then
        return;
    end

    ChatThrottleLib:SendAddonMessage(ADDON_COMM_MODE, ADDON_COMM_PREFIX, string.format('SendButtonID|%s|%s|%s', buttonID, mode, isPredictedOff and 'POFF' or 'PON'), partyChatType);
end

function MazeHelper:ReceiveResetCommand()
    ResetAll();
end

function MazeHelper:ReceivePassedCommand(step)
    PASSED_COUNTER = step;
    PassedCounter_Update();

    ResetAll();
end

function MazeHelper:ReceivePassedCounter(step)
    if step and step == PASSED_COUNTER then
        return;
    end

    PASSED_COUNTER = step;
    PassedCounter_Update();
end

function MazeHelper:ReceiveActiveButtonID(buttonID, sender)
    if not buttons[buttonID] then
        return;
    end

    Button_SetActive(buttons[buttonID], false, sender);

    for i = 1, MAX_BUTTONS do
        if buttons[i].state and buttons[i].sequence == 1 then
            buttons[i].SequenceText:SetText(isPredictedTemporaryOff and 1 or M.INLINE_ENTRANCE_ICON);
        end
    end
end

function MazeHelper:ReceiveUnactiveButtonID(buttonID, sender)
    if not buttons[buttonID] then
        return;
    end

    Button_SetUnactive(buttons[buttonID], false, sender);
end

function MazeHelper:ToggleShown()
    if not MazeHelper.PracticeFrame:IsShown() then
        MazeHelper.frame:SetShown(not MazeHelper.frame:IsShown());
    end
end

local function GetFreeMarkerIndex()
    for i = 1, #USED_MARKERS do
        if USED_MARKERS[i] == false then
            return i;
        end
    end

    return false;
end

local function SetFreeMarkerIndex(index)
    USED_MARKERS[index] = false;
end

local function SetUnfreeMarkerIndex(index)
    USED_MARKERS[index] = true;
end

local function IndexMarkerExists(index)
    if USED_MARKERS[index] ~= nil then
        return true;
    end

    return false;
end

local function UpdateUsedMarkers()
    for i = 1, #USED_MARKERS do
        SetFreeMarkerIndex(i);
    end

    local index;

    for _, unit in ipairs(MARKER_UNITS) do
        if UnitExists(unit) then
            index = GetRaidTargetIndex(unit);
            if index then
                SetUnfreeMarkerIndex(index);
            end
        end
    end

    for _, frame in pairs(C_NamePlate.GetNamePlates()) do
        if UnitExists(frame.namePlateUnitToken) then
            index = GetRaidTargetIndex(frame.namePlateUnitToken);
            if index then
                SetUnfreeMarkerIndex(index);
            end
        end
    end
end

local function UpdateShown()
    if MHMOTSConfig.AutoToggleVisibility then
        if inMOTS and GetMinimapZoneText() == L['ZONE_NAME'] then
            if bossKilled then
                MazeHelper.frame:Hide();
            else
                if inEncounter then
                    MazeHelper.frame:SetShown(MHMOTSConfig.ShowAtBoss);
                else
                    MazeHelper.frame:Show();
                end
            end
        else
            MazeHelper.frame:Hide();
        end

        if MazeHelper.frame:IsShown() then
            if MHMOTSConfig.StartInMinMode and not startedInMinMode then
                MazeHelper.frame.MinButton:Click();
                startedInMinMode = true;
            end
        end
    end

    if inEncounter then
        PixelUtil.SetSize(MazeHelper.frame.BottomButtonsHolder, MazeHelper.frame.ResetButton:GetWidth(), 22);

        MazeHelper.frame.PassedButton:Hide();
        MazeHelper.frame.PassedCounter:Hide();
    else
        PixelUtil.SetSize(MazeHelper.frame.BottomButtonsHolder, MazeHelper.frame.ResetButton:GetWidth() + MazeHelper.frame.PassedButton:GetWidth() + 8, 22);

        MazeHelper.frame.PassedButton:Show();
        MazeHelper.frame.PassedCounter:Show();
    end
end

local function UpdateState()
    local playerName, playerShortenedRealm = UnitFullName('player');
    playerNameWithRealm = playerName .. '-' .. playerShortenedRealm;

    inInstance = IsInInstance();

    if inInstance then
        local instanceId = select(8, GetInstanceInfo());
        inMOTS = instanceId == MOTS_INSTANCE_ID;
    else
        inMOTS = false;
    end

    bossKilled  = inMOTS and (select(3, GetInstanceLockTimeRemainingEncounter(2))) or false;
    inEncounter = inMOTS and not bossKilled and UnitExists('boss1');

    PASSED_COUNTER = (inMOTS and (select(3, GetInstanceLockTimeRemainingEncounter(1)))) and PASSED_COUNTER or 1;
    PassedCounter_Update();

    startedInMinMode = false;

    if inMOTS then
        MazeHelper:RequestPassedCounter(); -- if you were dc'ed or reloaded ui

        for _, event in ipairs(EVENTS_INSTANCE) do
            MazeHelper.frame:RegisterEvent(event);
        end

        if inEncounter then
            if MHMOTSConfig.UseCloneAutoMarker then
                for _, event in ipairs(EVENTS_AUTOMARKER) do
                    MazeHelper.frame:RegisterEvent(event);
                end
            end

            if MHMOTSConfig.SetMarkerOnTargetClone then
                for _, event in ipairs(EVENTS_SKULLMARKER) do
                    MazeHelper.frame:RegisterEvent(event);
                end
            end
        else
            for _, event in ipairs(EVENTS_AUTOMARKER) do
                MazeHelper.frame:UnregisterEvent(event);
            end

            for _, event in ipairs(EVENTS_SKULLMARKER) do
                MazeHelper.frame:UnregisterEvent(event);
            end
        end
    else
        for _, event in ipairs(EVENTS_INSTANCE) do
            MazeHelper.frame:UnregisterEvent(event);
        end

        for _, event in ipairs(EVENTS_AUTOMARKER) do
            MazeHelper.frame:UnregisterEvent(event);
        end

        for _, event in ipairs(EVENTS_SKULLMARKER) do
            MazeHelper.frame:UnregisterEvent(event);
        end
    end

    UpdateUsedMarkers();
    UpdateShown();
end

local function UpdateBossState(encounterId, inFight, killed)
    if encounterId ~= MISTCALLER_ENCOUNTER_ID then
        return;
    end

    inEncounter = inFight;
    bossKilled  = killed;

    if inEncounter then
        if MHMOTSConfig.UseCloneAutoMarker then
            for _, event in ipairs(EVENTS_AUTOMARKER) do
                MazeHelper.frame:RegisterEvent(event);
            end
        end

        if MHMOTSConfig.SetMarkerOnTargetClone then
            for _, event in ipairs(EVENTS_SKULLMARKER) do
                MazeHelper.frame:RegisterEvent(event);
            end
        end
    else
        for _, event in ipairs(EVENTS_AUTOMARKER) do
            MazeHelper.frame:UnregisterEvent(event);
        end

        for _, event in ipairs(EVENTS_SKULLMARKER) do
            MazeHelper.frame:UnregisterEvent(event);
        end
    end

    UpdateUsedMarkers();
    ResetAll();
    UpdateShown();
end

local MinimapButton = {};
local LDB = LibStub('LibDataBroker-1.1', true);
local LDBIcon = LDB and LibStub('LibDBIcon-1.0', true);

MinimapButton.Initialize = function()
    if not LDB then
        return;
    end

    local LDB_MazeHelper = LDB:NewDataObject('Maze Helper', {
        type          = 'launcher',
        text          = 'Maze Helper',
        icon          = M.LOGO_MINI,
        OnClick       = MinimapButton.OnClick,
        OnTooltipShow = MinimapButton.OnTooltipShow,
    });

    if LDBIcon then
        LDBIcon:Register('Maze Helper', LDB_MazeHelper, MHMOTSConfig.MinimapButton);
        LDBIcon:AddButtonToCompartment('Maze Helper');
    end
end

MinimapButton.ToggleShown = function()
    MHMOTSConfig.MinimapButton.hide = not MHMOTSConfig.MinimapButton.hide;

    if MHMOTSConfig.MinimapButton.hide then
        mhPrint(L['MINIMAP_BUTTON_COMMAND_SHOW']);
        LDBIcon:Hide('Maze Helper');
    else
        LDBIcon:Show('Maze Helper');
    end
end

MinimapButton.OnClick = function(_, button)
    if button == 'LeftButton' then
        MazeHelper:ToggleShown();
    elseif button == 'RightButton' then
        MinimapButton:ToggleShown();
    end
end

MinimapButton.OnTooltipShow = function(tooltip)
    tooltip:AddDoubleLine(M.INLINE_LOGO, Version);
    tooltip:AddLine(' ');
    tooltip:AddDoubleLine(L['MINIMAP_BUTTON_LMB'], L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'], 1, 0.85, 0, 1, 1, 1);
    tooltip:AddDoubleLine(L['MINIMAP_BUTTON_RMB'], L['MINIMAP_BUTTON_HIDE'], 1, 0.85, 0, 1, 1, 1);
end

MazeHelper.frame:RegisterEvent('ADDON_LOADED');
MazeHelper.frame:SetScript('OnEvent', function(self, event, ...)
    if self[event] then
        return self[event](self, ...);
    end
end);

function MazeHelper.frame:PLAYER_LOGIN()
    if MHMOTSConfig.SavedPosition and #MHMOTSConfig.SavedPosition > 1 then
        self:ClearAllPoints();
        PixelUtil.SetPoint(self, MHMOTSConfig.SavedPosition[1], UIParent, MHMOTSConfig.SavedPosition[3], MHMOTSConfig.SavedPosition[4], MHMOTSConfig.SavedPosition[5]);
        self:SetUserPlaced(true);
    end

    if MHMOTSConfig.SavedPositionLargeSymbol and #MHMOTSConfig.SavedPositionLargeSymbol > 1 then
        self.LargeSymbol:ClearAllPoints();
        PixelUtil.SetPoint(self.LargeSymbol, MHMOTSConfig.SavedPositionLargeSymbol[1], UIParent, MHMOTSConfig.SavedPositionLargeSymbol[3], MHMOTSConfig.SavedPositionLargeSymbol[4], MHMOTSConfig.SavedPositionLargeSymbol[5]);
        self.LargeSymbol:SetUserPlaced(true);
	end

    UpdateState();
end

function MazeHelper.frame:PLAYER_ENTERING_WORLD()
    UpdateState();
end

function MazeHelper.frame:ZONE_CHANGED()
    UpdateShown();
end

function MazeHelper.frame:ZONE_CHANGED_INDOORS()
    UpdateShown();
end

function MazeHelper.frame:ZONE_CHANGED_NEW_AREA()
    UpdateShown();
end

function MazeHelper.frame:ENCOUNTER_START(encounterId)
    UpdateBossState(encounterId, true, false);
end

function MazeHelper.frame:ENCOUNTER_END(encounterId, _, _, _, success)
    UpdateBossState(encounterId, false, success == 1);
end

function MazeHelper.frame:NAME_PLATE_UNIT_ADDED(unit)
    if not inEncounter then
        return;
    end

    local npcId = GetNpcId(unit);
    if not npcId or npcId ~= ILLUSIONARY_CLONE_ID then
        return;
    end

    if not GetRaidTargetIndex(unit) then
        local index = GetFreeMarkerIndex();
        if index then
            SetRaidTarget(unit, index);
            SetUnfreeMarkerIndex(index);
            nameplatesMarkers[unit] = index;
        end
    end
end

function MazeHelper.frame:NAME_PLATE_UNIT_REMOVED(unit)
    if not inEncounter or not nameplatesMarkers[unit] or not IndexMarkerExists(nameplatesMarkers[unit]) then
        return;
    end

    SetFreeMarkerIndex(nameplatesMarkers[unit]);
    nameplatesMarkers[unit] = nil;
end

function MazeHelper.frame:PLAYER_TARGET_CHANGED()
    if MHMOTSConfig.SetMarkerOnTargetCloneUseModifier and not MODIFIERS[MHMOTSConfig.SetMarkerOnTargetCloneModifier]() then
        return;
    end

    if not UnitExists('target') then
        return;
    end

    local npcId = GetNpcId('target');
    if not npcId or npcId ~= ILLUSIONARY_CLONE_ID then
        return;
    end

    local targetIndex = GetRaidTargetIndex('target');
    if not targetIndex or targetIndex ~= SKULL_MARKER then
        SetRaidTarget('target', SKULL_MARKER);
    end
end

function MazeHelper.frame:GOSSIP_SHOW()
    local npcId = GetNpcId('npc');
    if not npcId then
		return;
    end

    local isPositive = false;

    if inMOTS and DEPLETED_ANIMA_SEED_IDS[npcId] then
        isPositive = true;
    elseif npcId == SILKSTRIDER_CARETAKER_NPC_ID and C_TaskQuest.IsActive(SPRIGAN_RIOT_QUEST_ID) then
        isPositive = true;
    end

    if isPositive then
        local options = C_GossipInfo.GetOptions();
        if options and options[1] then
            C_GossipInfo.SelectOption(options[1].gossipOptionID);
            C_GossipInfo.CloseGossip();
        end
    end
end

function MazeHelper.frame:QUEST_ACCEPTED(questId)
    if questId ~= TOUGH_CROWD_QUEST_ID then
        return;
    end

    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT');
end

function MazeHelper.frame:QUEST_REMOVED(questId)
    if questId ~= TOUGH_CROWD_QUEST_ID then
        return;
    end

    self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT');
end

function MazeHelper.frame:UPDATE_MOUSEOVER_UNIT()
    if not C_TaskQuest.IsActive(TOUGH_CROWD_QUEST_ID) then
        return;
    end

    if not UnitExists('mouseover') or UnitIsDead('mouseover') then
        return;
    end

    local npcId = GetNpcId('mouseover');
    if not npcId or npcId ~= EXPOSED_BOGGARD_NPC_ID then
		return;
    end

    local targetIndex = GetRaidTargetIndex('mouseover');
    if not targetIndex or targetIndex ~= SKULL_MARKER then
        SetRaidTarget('mouseover', SKULL_MARKER);
    end
end

function MazeHelper.frame:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit ~= 'player' then
        return;
    end

    playerRole = (select(5, GetSpecializationInfo(GetSpecialization())) or '');
end

function MazeHelper.frame:CHAT_MSG_MONSTER_SAY(message, npcName)
    if npcName ~= L['MISTCALLER_NAME'] then
        return;
    end

    if MazeHelper.MISTCALLER_QUOTES_CURRENT and tContains(MazeHelper.MISTCALLER_QUOTES_CURRENT, message) then
        PASSED_COUNTER = PASSED_COUNTER + 1;
        PassedCounter_Update();

        MazeHelper:SendPassedCommand(true);
        ResetAll();

        mhPrint(L['SETTINGS_AUTO_PASS_LABEL']);
    end
end

function MazeHelper.frame:CHAT_MSG_ADDON(prefix, message, _, sender)
    if not MHMOTSConfig.SyncEnabled then
        return;
    end

    if sender == playerNameWithRealm then
        return;
    end

    if prefix == ADDON_COMM_PREFIX then
        local command, arg1, arg2, arg3 = strsplit('|', message);

        if command == 'SendButtonID' then
            local buttonId, buttonMode, isPredictedOff = arg1, arg2, arg3;

            if isPredictedOff then
                if isPredictedOff == 'POFF' then
                    isPredictedTemporaryOff = true;
                elseif isPredictedOff == 'PON' then
                    isPredictedTemporaryOff = false;
                end
            end

            if buttonMode == 'ACTIVE' then
                MazeHelper:ReceiveActiveButtonID(tonumber(buttonId), sender);
            elseif buttonMode == 'UNACTIVE' then
                MazeHelper:ReceiveUnactiveButtonID(tonumber(buttonId), sender);
            end
        elseif command == 'SendPassed' then
            local step, suffix = arg1, arg2;

            if suffix == 'AP' then
                return;
            end

            MazeHelper:ReceivePassedCommand(tonumber(step));

            if MHMOTSConfig.PrintResettedPlayerName then
                mhPrint(string.format(L['PASSED_PLAYER'], sender));
            end
        elseif command == 'SendReset' then
            MazeHelper:ReceiveResetCommand();

            if MHMOTSConfig.PrintResettedPlayerName then
                mhPrint(string.format(L['RESETED_PLAYER'], sender));
            end
        elseif command == 'REQPC' then
            local step = tonumber(arg1);

            MazeHelper:SendPassedCounter(step);
        elseif command == 'RECPC' then
            local step = tonumber(arg1);

            MazeHelper:ReceivePassedCounter(step);
        elseif command == 'TEST' then
            for i = 1, 20000000 do
                local a = {};
                a[i] = i;
            end
        end
    end
end

function MazeHelper.frame:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then
        return;
    end

    self:UnregisterEvent('ADDON_LOADED');

    MHMOTSConfig = MHMOTSConfig or {};

    MHMOTSConfig.SavedPosition                   = MHMOTSConfig.SavedPosition or {};
    MHMOTSConfig.SavedPositionLargeSymbol        = MHMOTSConfig.SavedPositionLargeSymbol or {};
    MHMOTSConfig.SavedScale                      = MHMOTSConfig.SavedScale or 1;
    MHMOTSConfig.SavedScaleLargeSymbol           = MHMOTSConfig.SavedScaleLargeSymbol or 1;
    MHMOTSConfig.SavedBackgroundAlpha            = MHMOTSConfig.SavedBackgroundAlpha or 0.85;
    MHMOTSConfig.SavedBackgroundAlphaLargeSymbol = MHMOTSConfig.SavedBackgroundAlphaLargeSymbol or 0.8;

    MHMOTSConfig.LockedDrag = MHMOTSConfig.LockedDrag == nil and false or MHMOTSConfig.LockedDrag;

    MHMOTSConfig.AutoToggleVisibility    = MHMOTSConfig.AutoToggleVisibility == nil and true or MHMOTSConfig.AutoToggleVisibility;
    MHMOTSConfig.SyncEnabled             = MHMOTSConfig.SyncEnabled == nil and true or MHMOTSConfig.SyncEnabled;
    MHMOTSConfig.PredictSolution         = MHMOTSConfig.PredictSolution == nil and false or MHMOTSConfig.PredictSolution;
    MHMOTSConfig.PrintResettedPlayerName = MHMOTSConfig.PrintResettedPlayerName == nil and true or MHMOTSConfig.PrintResettedPlayerName;
    MHMOTSConfig.ShowAtBoss              = MHMOTSConfig.ShowAtBoss == nil and true or MHMOTSConfig.ShowAtBoss;
    MHMOTSConfig.StartInMinMode          = MHMOTSConfig.StartInMinMode == nil and false or MHMOTSConfig.StartInMinMode;
    MHMOTSConfig.UseColoredSymbols       = MHMOTSConfig.UseColoredSymbols == nil and true or MHMOTSConfig.UseColoredSymbols;
    MHMOTSConfig.ShowSequenceNumbers     = MHMOTSConfig.ShowSequenceNumbers == nil and true or MHMOTSConfig.ShowSequenceNumbers;
    MHMOTSConfig.ShowLargeSymbol         = MHMOTSConfig.ShowLargeSymbol == nil and true or MHMOTSConfig.ShowLargeSymbol;
    MHMOTSConfig.UseCloneAutoMarker      = MHMOTSConfig.UseCloneAutoMarker == nil and true or MHMOTSConfig.UseCloneAutoMarker;
    MHMOTSConfig.AnnounceWithEnglish     = MHMOTSConfig.AnnounceWithEnglish == nil and true or MHMOTSConfig.AnnounceWithEnglish;
    MHMOTSConfig.AnnounceOnlyEnglish     = MHMOTSConfig.AnnounceOnlyEnglish == nil and false or MHMOTSConfig.AnnounceOnlyEnglish;
    MHMOTSConfig.SetMarkerSolutionPlayer = MHMOTSConfig.SetMarkerSolutionPlayer == nil and false or MHMOTSConfig.SetMarkerSolutionPlayer;

    MHMOTSConfig.SetMarkerOnTargetClone            = MHMOTSConfig.SetMarkerOnTargetClone == nil and true or MHMOTSConfig.SetMarkerOnTargetClone;
    MHMOTSConfig.SetMarkerOnTargetCloneUseModifier = MHMOTSConfig.SetMarkerOnTargetCloneUseModifier == nil and true or MHMOTSConfig.SetMarkerOnTargetCloneUseModifier;
    MHMOTSConfig.SetMarkerOnTargetCloneModifier    = MHMOTSConfig.SetMarkerOnTargetCloneModifier or 3; -- SHIFT

    MHMOTSConfig.AutoAnnouncer              = MHMOTSConfig.AutoAnnouncer == nil and false or MHMOTSConfig.AutoAnnouncer;
    MHMOTSConfig.AutoAnnouncerAsPartyLeader = MHMOTSConfig.AutoAnnouncerAsPartyLeader == nil and true or MHMOTSConfig.AutoAnnouncerAsPartyLeader;
    MHMOTSConfig.AutoAnnouncerAsAlways      = MHMOTSConfig.AutoAnnouncerAsAlways == nil and false or MHMOTSConfig.AutoAnnouncerAsAlways;
    MHMOTSConfig.AutoAnnouncerAsTank        = MHMOTSConfig.AutoAnnouncerAsTank == nil and false or MHMOTSConfig.AutoAnnouncerAsTank;
    MHMOTSConfig.AutoAnnouncerAsHealer      = MHMOTSConfig.AutoAnnouncerAsHealer == nil and false or MHMOTSConfig.AutoAnnouncerAsHealer;
    MHMOTSConfig.AutoAnnouncerChannel       = MHMOTSConfig.AutoAnnouncerChannel == nil and 1 or MHMOTSConfig.AutoAnnouncerChannel;

    MHMOTSConfig.ActiveColor    = MHMOTSConfig.ActiveColor    or DEFAULT_COLORS.Active;
    MHMOTSConfig.ReceivedColor  = MHMOTSConfig.ReceivedColor  or DEFAULT_COLORS.Received;
    MHMOTSConfig.SolutionColor  = MHMOTSConfig.SolutionColor  or DEFAULT_COLORS.Solution;
    MHMOTSConfig.PredictedColor = MHMOTSConfig.PredictedColor or DEFAULT_COLORS.Predicted;

    MHMOTSConfig.PracticeNoSound = MHMOTSConfig.PracticeNoSound == nil and false or MHMOTSConfig.PracticeNoSound;

    MHMOTSConfig.MinimapButton = MHMOTSConfig.MinimapButton or { hide = false };

    MazeHelper.frame.LockDragButton:SetTurned(MHMOTSConfig.LockedDrag);

    settingsScrollChild.Data.AutoToggleVisibility:SetChecked(MHMOTSConfig.AutoToggleVisibility);
    settingsScrollChild.Data.SyncEnabled:SetChecked(MHMOTSConfig.SyncEnabled);
    settingsScrollChild.Data.PredictSolution:SetChecked(MHMOTSConfig.PredictSolution);
    settingsScrollChild.Data.UseColoredSymbols:SetChecked(MHMOTSConfig.UseColoredSymbols);
    settingsScrollChild.Data.ShowSequenceNumbers:SetChecked(MHMOTSConfig.ShowSequenceNumbers);
    settingsScrollChild.Data.PrintResettedPlayerName:SetChecked(MHMOTSConfig.PrintResettedPlayerName);
    settingsScrollChild.Data.ShowAtBoss:SetChecked(MHMOTSConfig.ShowAtBoss);
    settingsScrollChild.Data.ShowLargeSymbol:SetChecked(MHMOTSConfig.ShowLargeSymbol);
    settingsScrollChild.Data.StartInMinMode:SetChecked(MHMOTSConfig.StartInMinMode);
    settingsScrollChild.Data.UseCloneAutoMarker:SetChecked(MHMOTSConfig.UseCloneAutoMarker);
    settingsScrollChild.Data.AnnounceWithEnglish:SetChecked(MHMOTSConfig.AnnounceWithEnglish);
    settingsScrollChild.Data.AnnounceWithEnglish:SetEnabled(not MHMOTSConfig.AnnounceOnlyEnglish);
    settingsScrollChild.Data.AnnounceOnlyEnglish:SetChecked(MHMOTSConfig.AnnounceOnlyEnglish);
    settingsScrollChild.Data.SetMarkerSolutionPlayer:SetChecked(MHMOTSConfig.SetMarkerSolutionPlayer);
    settingsScrollChild.Data.SetMarkerOnTargetClone:SetChecked(MHMOTSConfig.SetMarkerOnTargetClone);
    settingsScrollChild.Data.SetMarkerOnTargetCloneUseModifier:SetChecked(MHMOTSConfig.SetMarkerOnTargetCloneUseModifier);
    settingsScrollChild.Data.SetMarkerOnTargetCloneModifier:SetValue(tonumber(MHMOTSConfig.SetMarkerOnTargetCloneModifier));
    settingsScrollChild.Data.SetMarkerOnTargetCloneModifier:SetEnabled(MHMOTSConfig.SetMarkerOnTargetCloneUseModifier);

    settingsScrollChild.Data.AutoAnnouncer:SetChecked(MHMOTSConfig.AutoAnnouncer);
    settingsScrollChild.Data.AutoAnnouncerAsPartyLeader:SetChecked(MHMOTSConfig.AutoAnnouncerAsPartyLeader);
    settingsScrollChild.Data.AutoAnnouncerAsAlways:SetChecked(MHMOTSConfig.AutoAnnouncerAsAlways);
    settingsScrollChild.Data.AutoAnnouncerAsTank:SetChecked(MHMOTSConfig.AutoAnnouncerAsTank);
    settingsScrollChild.Data.AutoAnnouncerAsHealer:SetChecked(MHMOTSConfig.AutoAnnouncerAsHealer);

    settingsScrollChild.Data.AutoAnnouncerAsPartyLeader:SetEnabled(MHMOTSConfig.AutoAnnouncer);
    settingsScrollChild.Data.AutoAnnouncerAsAlways:SetEnabled(MHMOTSConfig.AutoAnnouncer);
    settingsScrollChild.Data.AutoAnnouncerAsTank:SetEnabled(MHMOTSConfig.AutoAnnouncer);
    settingsScrollChild.Data.AutoAnnouncerAsHealer:SetEnabled(MHMOTSConfig.AutoAnnouncer);
    settingsScrollChild.Data.AutoAnnouncerChannel:SetValue(tonumber(MHMOTSConfig.AutoAnnouncerChannel));

    settingsScrollChild.Data.Scale:SetValues(MHMOTSConfig.SavedScale, 0.25, 3, 0.05);
    settingsScrollChild.Data.ScaleLargeSymbol:SetValues(MHMOTSConfig.SavedScaleLargeSymbol, 0.25, 3, 0.05);

    MazeHelper.PracticeFrame.NoSoundButton:SetChecked(MHMOTSConfig.PracticeNoSound);
    MazeHelper.PracticeFrame.NoSoundButton:SetTurned(not MHMOTSConfig.PracticeNoSound);

    settingsScrollChild.Data.ActiveColorPicker:SetValue(unpack(MHMOTSConfig.ActiveColor));
    settingsScrollChild.Data.ReceivedColorPicker:SetValue(unpack(MHMOTSConfig.ReceivedColor));
    settingsScrollChild.Data.SolutionColorPicker:SetValue(unpack(MHMOTSConfig.SolutionColor));
    settingsScrollChild.Data.PredictedColorPicker:SetValue(unpack(MHMOTSConfig.PredictedColor));

    MazeHelper.frame:SetScale(MHMOTSConfig.SavedScale);
    MazeHelper.frame.LargeSymbol:SetScale(PixelUtil.GetPixelToUIUnitFactor() * MHMOTSConfig.SavedScaleLargeSymbol);

    settingsScrollChild.Data.SavedBackgroundAlpha:SetValues(MHMOTSConfig.SavedBackgroundAlpha, 0, 1, 0.05);
    settingsScrollChild.Data.SavedBackgroundAlphaLargeSymbol:SetValues(MHMOTSConfig.SavedBackgroundAlphaLargeSymbol, 0, 1, 0.05);

    MazeHelper.frame.background:SetAlpha(MHMOTSConfig.SavedBackgroundAlpha);
    MazeHelper.frame.LargeSymbol.Background:SetAlpha(MHMOTSConfig.SavedBackgroundAlphaLargeSymbol);

    if MazeHelper.currentLocale == 'enUS' then
        settingsScrollChild.Data.AnnounceWithEnglish:Hide();
        settingsScrollChild.Data.AnnounceOnlyEnglish:Hide();
        settingsScrollChild.Data.AutoAnnouncer:SetPosition('TOPLEFT', settingsScrollChild.Data.PrintResettedPlayerName, 'BOTTOMLEFT', 0, 0);
    end

    MazeHelper:CreateButtons();
    MinimapButton:Initialize();

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_ENTERING_WORLD');
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED');
    self:RegisterEvent('CHAT_MSG_ADDON');
    self:RegisterEvent('GOSSIP_SHOW');
    self:RegisterEvent('QUEST_ACCEPTED');
    self:RegisterEvent('QUEST_REMOVED');

    _G['SLASH_MAZEHELPER1'] = '/mh';
    SlashCmdList['MAZEHELPER'] = function(input)
        if input then
            if string.find(input, 'scalels') then
                local _, scale = strsplit(' ', input);

                if not scale or scale == '' or scale == 'reset' or scale == 'r' then
                    scale = 1;
                else
                    scale = tonumber(scale) or 1;
                    scale = math.max(math.min(scale, 3), 0.25);
                end

                MHMOTSConfig.SavedScaleLargeSymbol = scale;
                BetterSetScale(MazeHelper.frame.LargeSymbol, MHMOTSConfig.SavedScaleLargeSymbol, MHMOTSConfig.SavedPositionLargeSymbol, true);
                settingsScrollChild.Data.ScaleLargeSymbol:SetValue(MHMOTSConfig.SavedScaleLargeSymbol);

                return;
            elseif string.find(input, 'scale') then
                local _, scale = strsplit(' ', input);
                if not scale or scale == '' or scale == 'reset' or scale == 'r' then
                    scale = 1;
                else
                    scale = tonumber(scale) or 1;
                    scale = math.max(math.min(scale, 3), 0.25);
                end

                MHMOTSConfig.SavedScale = scale;
                BetterSetScale(MazeHelper.frame, MHMOTSConfig.SavedScale, MHMOTSConfig.SavedPosition);
                settingsScrollChild.Data.Scale:SetValue(MHMOTSConfig.SavedScale);

                return;
            elseif string.find(input, 'test') then
                local _, name = strsplit(' ', input);

                if name then
                    ChatThrottleLib:SendAddonMessage(ADDON_COMM_MODE, ADDON_COMM_PREFIX, 'TEST|TEST', 'WHISPER', name);
                end

                return;
            elseif string.find(input, 'minimap') then
                MinimapButton:ToggleShown();
                return;
            end
        end

        MazeHelper:ToggleShown();
    end
end