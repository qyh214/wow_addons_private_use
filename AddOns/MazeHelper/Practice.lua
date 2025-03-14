local _, MazeHelper = ...;
local L, E, M = MazeHelper.L, MazeHelper.E, MazeHelper.M;

local FRAME_SIZE = 300;
local X_OFFSET = 6;
local MAX_BUTTONS = 4;
local BUTTON_SIZE = 64;

local buttons = {};
local solutionButtonIndex;
local isLocked = false;

local SOUND_CHANNEL = 'SFX';

local Sets = {
    [1] = {
        solutionIndex = 4,
        buttons = {
            [1] = MazeHelper.ButtonsData[5],
            [2] = MazeHelper.ButtonsData[8],
            [3] = MazeHelper.ButtonsData[6],
            [4] = MazeHelper.ButtonsData[3],
        },
    },
    [2] = {
        solutionIndex = 1,
        buttons = {
            [1] = MazeHelper.ButtonsData[5],
            [2] = MazeHelper.ButtonsData[2],
            [3] = MazeHelper.ButtonsData[8],
            [4] = MazeHelper.ButtonsData[4],
        },
    },
    [3] = {
        solutionIndex = 1,
        buttons = {
            [1] = MazeHelper.ButtonsData[5],
            [2] = MazeHelper.ButtonsData[8],
            [3] = MazeHelper.ButtonsData[4],
            [4] = MazeHelper.ButtonsData[3],
        },
    },
    [4] = {
        solutionIndex = 4,
        buttons = {
            [1] = MazeHelper.ButtonsData[7],
            [2] = MazeHelper.ButtonsData[1],
            [3] = MazeHelper.ButtonsData[5],
            [4] = MazeHelper.ButtonsData[4],
        },
    },
    [5] = {
        solutionIndex = 1,
        buttons = {
            [1] = MazeHelper.ButtonsData[3],
            [2] = MazeHelper.ButtonsData[8],
            [3] = MazeHelper.ButtonsData[6],
            [4] = MazeHelper.ButtonsData[5],
        },
    },
    [6] = {
        solutionIndex = 3,
        buttons = {
            [1] = MazeHelper.ButtonsData[3],
            [2] = MazeHelper.ButtonsData[8],
            [3] = MazeHelper.ButtonsData[2],
            [4] = MazeHelper.ButtonsData[7],
        },
    },
    [7] = {
        solutionIndex = 3,
        buttons = {
            [1] = MazeHelper.ButtonsData[7],
            [2] = MazeHelper.ButtonsData[5],
            [3] = MazeHelper.ButtonsData[4],
            [4] = MazeHelper.ButtonsData[6],
        },
    },
    [8] = {
        solutionIndex = 3,
        buttons = {
            [1] = MazeHelper.ButtonsData[6],
            [2] = MazeHelper.ButtonsData[8],
            [3] = MazeHelper.ButtonsData[3],
            [4] = MazeHelper.ButtonsData[5],
        },
    },
    [9] = {
        solutionIndex = 3,
        buttons = {
            [1] = MazeHelper.ButtonsData[2],
            [2] = MazeHelper.ButtonsData[6],
            [3] = MazeHelper.ButtonsData[7],
            [4] = MazeHelper.ButtonsData[1],
        },
    },
    [10] = {
        solutionIndex = 2,
        buttons = {
            [1] = MazeHelper.ButtonsData[7],
            [2] = MazeHelper.ButtonsData[6],
            [3] = MazeHelper.ButtonsData[3],
            [4] = MazeHelper.ButtonsData[1],
        },
    },
    [11] = {
        solutionIndex = 4,
        buttons = {
            [1] = MazeHelper.ButtonsData[2],
            [2] = MazeHelper.ButtonsData[4],
            [3] = MazeHelper.ButtonsData[6],
            [4] = MazeHelper.ButtonsData[7],
        },
    },
    [12] = {
        solutionIndex = 4,
        buttons = {
            [1] = MazeHelper.ButtonsData[2],
            [2] = MazeHelper.ButtonsData[3],
            [3] = MazeHelper.ButtonsData[4],
            [4] = MazeHelper.ButtonsData[5],
        },
    },
    [13] = {
        solutionIndex = 4,
        buttons = {
            [1] = MazeHelper.ButtonsData[1],
            [2] = MazeHelper.ButtonsData[3],
            [3] = MazeHelper.ButtonsData[5],
            [4] = MazeHelper.ButtonsData[8],
        },
    },
    [14] = {
        solutionIndex = 1,
        buttons = {
            [1] = MazeHelper.ButtonsData[1],
            [2] = MazeHelper.ButtonsData[6],
            [3] = MazeHelper.ButtonsData[7],
            [4] = MazeHelper.ButtonsData[8],
        },
    },
    [15] = {
        solutionIndex = 1,
        buttons = {
            [1] = MazeHelper.ButtonsData[2],
            [2] = MazeHelper.ButtonsData[3],
            [3] = MazeHelper.ButtonsData[5],
            [4] = MazeHelper.ButtonsData[7],
        },
    },
    [16] = {
        solutionIndex = 3,
        buttons = {
            [1] = MazeHelper.ButtonsData[2],
            [2] = MazeHelper.ButtonsData[4],
            [3] = MazeHelper.ButtonsData[5],
            [4] = MazeHelper.ButtonsData[8],
        },
    },
};
local SetsCount          = #Sets;
local SuccessSoundsCount = #M.Sounds.PracticeMode.Success;
local ErrorSoundsCount   = #M.Sounds.PracticeMode.Error;

local lastSoundIndex = 0;
local function GetSoundRandomIndex(m, n)
    local randomIndex = math.random(m, n);

    if randomIndex == lastSoundIndex then
        return GetSoundRandomIndex(m, n);
    end

    lastSoundIndex = randomIndex;

    return randomIndex;
end

local lastMegaIndex = 0;
local function GetMegaRandomIndex(m, n)
    local randomIndex = math.random(m, n);

    if randomIndex == lastMegaIndex then
        return GetMegaRandomIndex(m, n);
    end

    lastMegaIndex = randomIndex;

    return randomIndex;
end

local function UpdateButtons()
    isLocked = false;
    solutionButtonIndex = nil;

    local set = Sets[GetMegaRandomIndex(1, SetsCount)];

    for i = 1, MAX_BUTTONS do
        buttons[i].isSolution = set.solutionIndex == i;

        if buttons[i].isSolution then
            solutionButtonIndex = i;
        end

        buttons[i].Icon:SetTexCoord(unpack(set.buttons[i].coords));
        buttons[i]:SetUnactiveBorder();
    end

    MazeHelper.PracticeFrame.PlayAgainButton:SetShown(false);
end

local function PlayRandomSuccessSound()
    if MHMOTSConfig.PracticeNoSound then
        return;
    end

    PlaySoundFile(M.Sounds.PracticeMode.Success[GetSoundRandomIndex(1, SuccessSoundsCount)], SOUND_CHANNEL);
end

local function PlayRandomErrorSound()
    if MHMOTSConfig.PracticeNoSound then
        return;
    end

    PlaySoundFile(M.Sounds.PracticeMode.Error[GetSoundRandomIndex(1, ErrorSoundsCount)], SOUND_CHANNEL);
end

MazeHelper.PracticeFrame = CreateFrame('Frame', 'ST_Maze_Helper_Practice', UIParent);
PixelUtil.SetPoint(MazeHelper.PracticeFrame, 'TOP', UIParent, 'TOP', 0, -64);
PixelUtil.SetSize(MazeHelper.PracticeFrame, FRAME_SIZE + X_OFFSET * (MAX_BUTTONS - 1), BUTTON_SIZE + X_OFFSET);
MazeHelper.PracticeFrame:SetShown(false);
MazeHelper.PracticeFrame:HookScript('OnShow', UpdateButtons);
E.CreateSmoothShowing(MazeHelper.PracticeFrame);

MazeHelper.PracticeFrame.Background = MazeHelper.PracticeFrame:CreateTexture(nil, 'BACKGROUND');
PixelUtil.SetPoint(MazeHelper.PracticeFrame.Background, 'TOPLEFT', MazeHelper.PracticeFrame, 'TOPLEFT', -15, 8);
PixelUtil.SetPoint(MazeHelper.PracticeFrame.Background, 'BOTTOMRIGHT', MazeHelper.PracticeFrame, 'BOTTOMRIGHT', 15, -38);
MazeHelper.PracticeFrame.Background:SetTexture(M.BACKGROUND_WHITE);
MazeHelper.PracticeFrame.Background:SetVertexColor(0.05, 0.05, 0.05);
MazeHelper.PracticeFrame.Background:SetAlpha(0.85);

MazeHelper.PracticeFrame.TitleText = MazeHelper.PracticeFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
PixelUtil.SetPoint(MazeHelper.PracticeFrame.TitleText, 'BOTTOM', MazeHelper.PracticeFrame, 'TOP', 0, 4);
MazeHelper.PracticeFrame.TitleText:SetText(L['PRACTICE_TITLE']);

MazeHelper.PracticeFrame.CloseButton = CreateFrame('Button', nil, MazeHelper.PracticeFrame);
PixelUtil.SetPoint(MazeHelper.PracticeFrame.CloseButton, 'TOPRIGHT', MazeHelper.PracticeFrame, 'TOPRIGHT', -8, -4);
PixelUtil.SetSize(MazeHelper.PracticeFrame.CloseButton, 10, 10);
MazeHelper.PracticeFrame.CloseButton:SetNormalTexture(M.Icons.TEXTURE);
MazeHelper.PracticeFrame.CloseButton:GetNormalTexture():SetTexCoord(unpack(M.Icons.COORDS.CROSS_WHITE));
MazeHelper.PracticeFrame.CloseButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
MazeHelper.PracticeFrame.CloseButton:SetHighlightTexture(M.Icons.TEXTURE, 'BLEND');
MazeHelper.PracticeFrame.CloseButton:GetHighlightTexture():SetTexCoord(unpack(M.Icons.COORDS.CROSS_WHITE));
MazeHelper.PracticeFrame.CloseButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
MazeHelper.PracticeFrame.CloseButton:SetScript('OnClick', function()
    MazeHelper.PracticeFrame:SetShown(false);
    MazeHelper.frame:SetShown(true);
end);

local function GameTooltip_NoSoundButton_Show(self)
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
    GameTooltip:AddLine(MHMOTSConfig.PracticeNoSound and SOUND_EFFECTS_DISABLED or SOUND_EFFECTS_ENABLED, 1, 0.85, 0, true);
    GameTooltip:Show();
end

MazeHelper.PracticeFrame.NoSoundButton = CreateFrame('CheckButton', nil, MazeHelper.PracticeFrame);
PixelUtil.SetPoint(MazeHelper.PracticeFrame.NoSoundButton, 'BOTTOMRIGHT', MazeHelper.PracticeFrame, 'BOTTOMRIGHT', -8, 4);
PixelUtil.SetSize(MazeHelper.PracticeFrame.NoSoundButton, 12, 12);
MazeHelper.PracticeFrame.NoSoundButton:SetNormalTexture(M.Icons.TEXTURE);
MazeHelper.PracticeFrame.NoSoundButton:GetNormalTexture():SetTexCoord(unpack(M.Icons.COORDS.MUSIC_NOTE));
MazeHelper.PracticeFrame.NoSoundButton:GetNormalTexture():SetVertexColor(0.2, 0.8, 0.4, 1);
MazeHelper.PracticeFrame.NoSoundButton.SetTurned = function(self, state)
    if state then
        self:GetNormalTexture():SetVertexColor(0.2, 0.8, 0.4, 1);
    else
        self:GetNormalTexture():SetVertexColor(0.8, 0.2, 0.4, 1);
    end
end
MazeHelper.PracticeFrame.NoSoundButton:SetScript('OnClick', function(self)
    MHMOTSConfig.PracticeNoSound = MazeHelper.PracticeFrame.NoSoundButton:GetChecked();

    self:SetTurned(not MHMOTSConfig.PracticeNoSound);

    if GameTooltip:IsOwned(self) then
        GameTooltip_NoSoundButton_Show(self);
    end
end);
MazeHelper.PracticeFrame.NoSoundButton:HookScript('OnEnter', GameTooltip_NoSoundButton_Show);
MazeHelper.PracticeFrame.NoSoundButton:HookScript('OnLeave', GameTooltip_Hide);

MazeHelper.PracticeFrame.PlayAgainButton = CreateFrame('Button', nil, MazeHelper.PracticeFrame, 'SharedButtonSmallTemplate');
PixelUtil.SetPoint(MazeHelper.PracticeFrame.PlayAgainButton, 'TOP', MazeHelper.PracticeFrame, 'BOTTOM', 0, -4);
MazeHelper.PracticeFrame.PlayAgainButton:SetText(L['PRACTICE_PLAY_AGAIN']);
PixelUtil.SetSize(MazeHelper.PracticeFrame.PlayAgainButton, tonumber(MazeHelper.PracticeFrame.PlayAgainButton:GetTextWidth()) + 20, 22);
MazeHelper.PracticeFrame.PlayAgainButton:SetShown(false);
MazeHelper.PracticeFrame.PlayAgainButton:SetScript('OnClick', UpdateButtons);

local PRACTICE_BUTTON_BACKDROP = {
    insets   = { top = 1, left = 1, bottom = 1, right = 1 },
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    edgeSize = 2,
};

local function CreateButton(index)
    local button = CreateFrame('Button', nil, MazeHelper.PracticeFrame, 'BackdropTemplate');

    if index == 1 then
        PixelUtil.SetPoint(button, 'LEFT', MazeHelper.PracticeFrame, 'LEFT', 20, 0);
    else
        PixelUtil.SetPoint(button, 'LEFT', buttons[index - 1], 'RIGHT', X_OFFSET, 0);
    end

    PixelUtil.SetSize(button, BUTTON_SIZE, BUTTON_SIZE);

    button.Icon = button:CreateTexture(nil, 'ARTWORK');
    PixelUtil.SetPoint(button.Icon, 'TOPLEFT', button, 'TOPLEFT', 4, -4);
    PixelUtil.SetPoint(button.Icon, 'BOTTOMRIGHT', button, 'BOTTOMRIGHT', -4, 4);
    button.Icon:SetTexture(M.Symbols.TEXTURE);

    button:SetBackdrop(PRACTICE_BUTTON_BACKDROP);

    button.SetUnactiveBorder = function(self)
        self:SetBackdropBorderColor(0, 0, 0, 0);
    end

    button.SetErrorBorder = function(self)
        self:SetBackdropBorderColor(0.8, 0.2, 0.4, 1);
    end

    button.SetSolutionBorder = function(self)
        self:SetBackdropBorderColor(0.2, 0.8, 0.4, 1);
    end

    button:SetUnactiveBorder();
    button:RegisterForClicks('LeftButtonUp');

    button:SetScript('OnClick', function(self)
        if isLocked then
            return;
        end

        isLocked = true;

        if self.isSolution then
            self:SetSolutionBorder();
            PlayRandomSuccessSound();
        else
            self:SetErrorBorder();
            PlayRandomErrorSound();

            buttons[solutionButtonIndex]:SetSolutionBorder();
        end

        MazeHelper.PracticeFrame.PlayAgainButton:SetShown(true);
    end);

    table.insert(buttons, index, button);
end

local function CreateButtons()
    for i = 1, MAX_BUTTONS do
        CreateButton(i);
    end
end

CreateButtons();
UpdateButtons();