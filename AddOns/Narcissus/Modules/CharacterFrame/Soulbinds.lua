
local FILE_PATH = "Interface\\AddOns\\Narcissus\\Art\\Modules\\CharacterFrame\\Soulbinds\\";
local CONDUIT_OFFSET = 60;
local QUALITY_COLORS = {
    [0] = {0.5, 0.5, 0.5},
    [1] = {0.8, 0.8, 0.8},
    [2] = {0.57, 0.79, 0.40},
    [3] = {0.17, 0.52, 0.87},
    [4] = {0.64, 0.21, 0.93},
    [5] = {0.5, 0.5, 0.0},
};

local C_Soulbinds = C_Soulbinds;
local GetSpellInfo = GetSpellInfo;

local MainFrame;
-----------------------------------------------------------------------------------
local QueueFrame = CreateFrame("Frame");
QueueFrame.queue = {}; --[1] = {widget, argument1, argument2, ...}
QueueFrame:Hide();

function QueueFrame:Add(newWidget, ...)
    self.t = 0;
    local inQueue;
    for i = 1, #self.queue do
        if self.queue[i][1] == newWidget then
            self.queue[i] = {newWidget, ...};
            inQueue = true;
            break
        end
    end
    if not inQueue then
        tinsert(self.queue, {newWidget, ...});
    end
    self:Show();
end

function QueueFrame:Process()
    print("Processing")
    local isComplete = true;
    for i = 1, #self.queue do
        local widget = self.queue[i][1];
        if widget then
            local arg1 = self.queue[i][2];
            if widget:SetNameBySpellID(arg1) then
                self.queue[i] = {};
            else
                isComplete = false;
            end
        end
    end
    return isComplete;
end

function QueueFrame:Stop()
    self:Hide();
    self.t = 0;
    wipe(self.queue);
end

QueueFrame:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.25 then
        self.t = 0;
        local isComplete = self:Process();
        if isComplete then
            self:Stop();
        end
    end
end)

local ReferenceTooltip = CreateFrame("GameTooltip", "NarciSoulbindsConduitReferenceTooltip", UIParent, "GameTooltipTemplate");

local DataProvider = {};
DataProvider.conduitItemIDs = {};

function DataProvider:GetActiveCovenantID()
    if not self.activeCovenantID then
        self.activeCovenantID = C_Covenants.GetActiveCovenantID();
    end
    return self.activeCovenantID
end

function DataProvider:UpdateCovenantData()
    wipe(self.conduitItemIDs);
    for conduitType = 0, 2 do
        local data = C_Soulbinds.GetConduitCollection(conduitType);
        if data then
            local itemID, conduitID;
            for i = 1, #data do
                itemID = data[i].conduitItemID;
                conduitID = data[i].conduitID;
                if itemID then
                    self.conduitItemIDs[itemID] = conduitID;
                end
            end
        end
    end
end

function DataProvider:GetConduitDescription(conduitID, rank)
    print("GetDescription")
    ReferenceTooltip:SetOwner(UIParent, "ANCHOR_NONE");
    ReferenceTooltip:SetConduit(conduitID, rank);
    if not self.referenceLine then
        self.referenceLine = _G["NarciSoulbindsConduitReferenceTooltip".. "TextLeft5"];
    end
    return self.referenceLine:GetText();
end

function DataProvider:GetConduitIDFromItemID(itemID)
    if itemID then
        return self.conduitItemIDs[tonumber(itemID)];
    end
end

function DataProvider:GetKnownConduitItemLevel(itemID)
    local conduitID = self:GetConduitIDFromItemID(itemID);
    if conduitID then
        local data = C_Soulbinds.GetConduitCollectionData(conduitID);
        if data then
            local rank = data.conduitRank;
            local itemLevel = C_Soulbinds.GetConduitItemLevel(conduitID, rank);
            local description = self:GetConduitDescription(conduitID, rank);
            return true, itemLevel, description;
        else
            return true
        end
    end
end

function DataProvider:GetDefaultSoulbindID(covenantID)
    --Blizzard_SoulbindsUtil.lua
    local SOULBINDS_COVENANT_KYRIAN = 1;
    local SOULBINDS_COVENANT_VENTHYR = 2;
    local SOULBINDS_COVENANT_NIGHT_FAE = 3;
    local SOULBINDS_COVENANT_NECROLORD = 4;
    local soulbindDefaultIDs = {
        [SOULBINDS_COVENANT_KYRIAN] = 7,
        [SOULBINDS_COVENANT_VENTHYR] = 8,
        [SOULBINDS_COVENANT_NIGHT_FAE] = 1,
        [SOULBINDS_COVENANT_NECROLORD] = 4,
    };
    return soulbindDefaultIDs[covenantID]
end

-----------------------------------------------------------------------------------
NarciSoulbindsConduitFrameMixin = {};

function NarciSoulbindsConduitFrameMixin:SetColumn(column)
    column = column or 1;
    self.Conduit:ClearAllPoints();
    self.Conduit:SetPoint("CENTER", self, "LEFT", -CONDUIT_OFFSET + 24*(column - 1), 0);
end

function NarciSoulbindsConduitFrameMixin:UseCircularBorder(isCircle, isEmptySlot)
    if isCircle then
        self.Conduit.Mask:SetTexture(FILE_PATH.."MaskCircle");
        self.Conduit.Border:SetTexCoord(0, 0.25, 0, 1);
    else
        self.Conduit.Mask:SetTexture(FILE_PATH.."MaskOctagon");
        if isEmptySlot then
            self.Conduit.Border:SetTexCoord(0.5, 0.75, 0, 1);
        else
            self.Conduit.Border:SetTexCoord(0.25, 0.5, 0, 1);
        end
    end
end

function NarciSoulbindsConduitFrameMixin:SetIcon(tex)
    self.Conduit.Icon:SetTexture(tex);
end

function NarciSoulbindsConduitFrameMixin:SetNameBySpellID(spellID)
    local name, _, icon = GetSpellInfo(spellID);
    local hasName;
    if name and name ~= "" then
        self.Name:SetText(name);
        self:SetIcon(icon);
        hasName = true;
    else
        QueueFrame:Add(self, spellID);
    end
    return hasName;
end

function NarciSoulbindsConduitFrameMixin:SetUp(traitID, conduitType, rank, row, column)
    if not traitID or not rank then return end;
    --traitID: spellID or conduitID
    
    local spellID, isEmptySlot;
    local quality = 1;
    if rank == 0 then        --This is a fixed conduit
        if traitID == 0 then
            --No conduit in this slot
            isEmptySlot = true;
            self:UseCircularBorder(false, isEmptySlot);
            self.conduitID = nil;
            self.spellID = nil;
            self.conduitRank = nil;
        else
            spellID = traitID;
            self:UseCircularBorder(true);
            self.conduitID = nil;
            self.spellID = traitID;
            self.conduitRank = nil;
        end
    else
        spellID = C_Soulbinds.GetConduitSpellID(traitID, rank);
        self:UseCircularBorder(false);
        self.conduitID = traitID;
        self.spellID = nil;
        self.conduitRank = rank;
        quality = C_Soulbinds.GetConduitQuality(traitID, rank);
        rank = C_Soulbinds.GetConduitItemLevel(traitID, rank);
    end
    if not conduitType then
        conduitType = 3;
    end
    self.ConduitIcon:SetTexCoord(conduitType*0.25, conduitType*0.25 + 0.25, 0, 1); 
    local hasName;
    if isEmptySlot then
        self.Name:SetText(EMPTY);
        quality = 0;
        hasName = true;
    else
        local name, _, icon = GetSpellInfo(spellID);
        self:SetIcon(icon);
        if name and name ~= "" then
            self.Name:SetText(name);
            hasName = true;
        else
            QueueFrame:Add(self, spellID);
        end
    end
    self.Name:SetTextColor(unpack(QUALITY_COLORS[quality]));
    
    if not rank or rank == 0 then
        rank = "";
    end
    self.Rank:SetText(rank);

    if row and column then
        self:ClearAllPoints();
        self:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", 0, -12 -24 * row);
        self:SetColumn(column);
        print("Row: "..row .. " Col: "..column)
    end
    self:Show();
    return hasName
end

function NarciSoulbindsConduitFrameMixin:ShowTooltip()
    GameTooltip:Hide();
    if self.conduitID or self.spellID then
        GameTooltip:SetOwner(self, "ANCHOR_NONE");
        GameTooltip:SetPoint("TOPLEFT", self.Conduit, "TOPRIGHT", 2, 0);
        if self.conduitID then
            GameTooltip:SetConduit(self.conduitID, self.conduitRank)
        elseif self.spellID then
            GameTooltip:SetSpellByID(self.spellID);
        end
        GameTooltip:Show();
    end
end

function NarciSoulbindsConduitFrameMixin:HideTooltip()
    GameTooltip:Hide();
end

function NarciSoulbindsConduitFrameMixin:OnEnter()
    --self:ShowTooltip();
end

function NarciSoulbindsConduitFrameMixin:OnLeave()
    --self:HideTooltip();
end

function NarciSoulbindsConduitFrameMixin:OnLoad()
    self.Conduit:SetScript("OnEnter", function()
        self:ShowTooltip();
    end)
    self.Conduit:SetScript("OnLeave", function()
        self:HideTooltip();
    end)
end

------------------------------------------------------------------
function GetActiveConduit()
    local soulbindID = C_Soulbinds.GetActiveSoulbindID();
    local data = C_Soulbinds.GetSoulbindData(soulbindID);
    if not data or not data.tree then return end;
    local nodes = data.tree.nodes;
    local conduitType, conduitState;
    for i = 1, #nodes do
        conduitState = nodes[i].state;
        if conduitState and conduitState == 3 then
            conduitType = nodes[i].conduitType;
            if conduitType then
                print(C_Soulbinds.GetConduitSpellID(nodes[i].conduitID, nodes[i].conduitRank))
            else
                print(nodes[i].spellID);
            end
        end
    end
end

local function SoulbindsCharacterButton_SetSelect(button, state)
    button:UnlockHighlight();
    if state then
        button.Texture:SetTexCoord(0.5, 1, 0, 0.5);
        button.Highlight:SetTexCoord(0.5, 1, 0.5, 1);
        --button:LockHighlight();
    else
        button.Texture:SetTexCoord(0, 0.5, 0, 0.5);
        button.Highlight:SetTexCoord(0, 0.5, 0.5, 1);
        --button:UnlockHighlight();
    end
end

local function SoulbindsCharacterButton_OnClick(button)
    print(button.soulbindID)
    if button.soulbindID then
        MainFrame:SelectTree(button.soulbindID);
        --SoulbindsCharacterButton_SetSelect(button, true);
        button:LockHighlight();
    end
end

local dynamicEvents = {"SOULBIND_ACTIVATED", "SOULBIND_NODE_UPDATED", "SOULBIND_PATH_CHANGED", "SOULBIND_NODE_LEARNED"};

NarciSoulbindsMixin = {};

function NarciSoulbindsMixin:OnLoad()
    MainFrame = self;
    local numRow = 8;
    self:SetHeight( (numRow + 1) * 24);

    --Static Events
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("COVENANT_CHOSEN");

    --Dynamic Events
    for i = 1, #dynamicEvents do
        self:RegisterEvent(dynamicEvents[i]);
    end

    self:RegisterForDrag("LeftButton");
end

function NarciSoulbindsMixin:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event);
        self:UpdateCovenantData();
    elseif event == "COVENANT_CHOSEN" then
        local newCovenantID = ...;
        self:UpdateCovenantData(newCovenantID);
    else
        print(event);
    end
end

function NarciSoulbindsMixin:UpdateCovenantData(newCovenantID)
    local covenantID = newCovenantID or C_Covenants.GetActiveCovenantID();
    if not covenantID or covenantID == 0 then
        --Covenant Unselected
        return
    end
    
    local data = C_Covenants.GetCovenantData(covenantID);
    self.defaultSoulbindID = DataProvider:GetDefaultSoulbindID(covenantID);
    if data then
        self.covenantData = data;
        self:CreateChoiceButtons(data.soulbindIDs);
    end

    DataProvider.activeCovenantID = covenantID;
    DataProvider:UpdateCovenantData();
end

function NarciSoulbindsMixin:CreateChoiceButtons(soulbindIDs)
    if not self.buttons then
        self.buttons = {};
    end
    local numChoices = #soulbindIDs;
    local gap = 4;
    local button;
    for i = 1, numChoices do
        button = self.buttons[i];
        if not button then
            button = CreateFrame("Button", nil, self, "NarciSoulbindsCharacterButton");
            button:SetPoint("CENTER", self, "LEFT", 0, (16 + gap)*(numChoices - 1)/2 - (16 + gap)*(i - 1));
            button:SetScript("OnClick", SoulbindsCharacterButton_OnClick);
            self.buttons[i] = button;
        end
        button.soulbindID = soulbindIDs[i];
        if i == 1 then
            SoulbindsCharacterButton_SetSelect(button, true);
        else
            SoulbindsCharacterButton_SetSelect(button, false);
        end
    end
end

function NarciSoulbindsMixin:ReleaseConduitFrames()
    QueueFrame:Stop();
    if self.framePool then
        for index, frame in pairs(self.framePool) do
            frame:Hide();
        end
    end
end

function NarciSoulbindsMixin:AcquireAndSetUpConduitFrame(index, traitID, conduitType, rank, row, column)
    if not self.framePool then
        self.framePool = {};
    end
    local frame = self.framePool[index];
    if not frame then
        frame = CreateFrame("Frame", nil, self, "NarciSoulbindsConduitFrameTemplate");
        self.framePool[index] = frame;
    end
    frame:SetUp(traitID, conduitType, rank, row, column);
end

function NarciSoulbindsMixin:GetPipe(index, row, col, effectiveCol)
    if not self.pipePool then
        self.pipePool = {};
    end
    local pipe = self.pipePool[index];
    if not pipe then
        pipe = self:CreateTexture(nil, "OVERLAY", "NarciSoulbindsPipeTextureTemplate");
        self.pipePool[index] = pipe;
    end
    pipe:ClearAllPoints();
    pipe:Show();
    local offsetY = 0;
    if col == 2 and effectiveCol and effectiveCol ~= 2 then
        --Flip Texture
        offsetY = -24;
        col = effectiveCol;
    end
    pipe:SetPoint("TOP", self, "TOPLEFT", 60 + 24*(col - 2), 24*(1 - row) + offsetY);
    return pipe
end

function NarciSoulbindsMixin:UpdatePipeline(structure)
    if self.pipePool then
        for _, pipe in pairs(self.pipePool) do
            pipe:Hide();
        end
    end

    local numTex = 0;
    local numRow = #structure;
    local numCol = 3;
    local numNodesPerRow = {};
    for row = 1, numRow do
        local numNodes = 0;
        for col = 1, numCol do
            if structure[row][col] ~= 0 then
                numNodes = numNodes + 1;
            end
        end
        numNodesPerRow[row] = numNodes;
    end

    for row = 1, numRow - 1 do
        local numNodes = numNodesPerRow[row];
        for col = 1, numCol do
            local nodeState = structure[row][col];
            if nodeState ~= 0 then
                local texOffsetY, nextNodeState;
                local nextRowData = structure[row + 1];
                if false and numNodes == 3 then
                    numTex = numTex + 1;
                    nextNodeState = nextRowData[col];
                    if nodeState == 2 and nextNodeState == 2 then
                        texOffsetY = 0.5;
                    else
                        texOffsetY = 0;
                    end
                    local pipe = self:GetPipe(numTex, row, col, col);
                    pipe:SetTexCoord(0.25, 0.5, texOffsetY, texOffsetY + 0.5);
                else
                    if nextRowData[col] and nextRowData[col] ~= 0 then
                        numTex = numTex + 1;
                        nextNodeState = nextRowData[col];
                        if nodeState == 2 and nextNodeState == 2 then
                            texOffsetY = 0.5;
                        else
                            texOffsetY = 0;
                        end
                        local pipe = self:GetPipe(numTex, row, col, col);
                        pipe:SetTexCoord(0.25, 0.5, texOffsetY, texOffsetY + 0.5);
                    end
                    if numNodes == 1 or numNodesPerRow[row + 1] ~= 3 then
                        if nextRowData[col - 1] and nextRowData[col - 1] ~= 0 then
                            numTex = numTex + 1;
                            nextNodeState = nextRowData[col - 1];
                            if nodeState == 2 and nextNodeState == 2 then
                                texOffsetY = 0.5;
                            else
                                texOffsetY = 0;
                            end
                            local pipe = self:GetPipe(numTex, row, col - 1, 3);
                            if col == 2 then
                                pipe:SetTexCoord(0, 0.25, texOffsetY, texOffsetY + 0.5);
                            else
                                pipe:SetTexCoord(0.5, 0.75, texOffsetY + 0.5, texOffsetY);
                            end
                        end
                        if nextRowData[col + 1] and nextRowData[col + 1] ~= 0 then
                            numTex = numTex + 1;
                            nextNodeState = nextRowData[col + 1];
                            if nodeState == 2 and nextNodeState == 2 then
                                texOffsetY = 0.5;
                            else
                                texOffsetY = 0;
                            end
                            local pipe = self:GetPipe(numTex, row, col + 1, 1);
                            if col == 2 then
                                pipe:SetTexCoord(0.5, 0.75, texOffsetY, texOffsetY + 0.5);
                            else
                                pipe:SetTexCoord(0, 0.25, texOffsetY + 0.5, texOffsetY);
                            end
                        end
                    end
                end
            end
        end
    end

    for i = 1, #structure do
        print(unpack(structure[i]))
    end
end

local function GetNullStructure()
    local structure = {};
    local numRow, numCol = 8, 3;
    for row = 1, numRow do
        structure[row] = {};
        for col = 1, numCol do
            structure[row][col] = 0;
        end
    end
    return structure
end

local atlasInfo = {
    [1] = { --"Kyrian"
        texture = "Interface\\Soulbinds\\SoulbindsShotsKyrian",
        [13] = {603, 558, 0.00048828125, 0.294921875, 0.0009765625, 0.5458984375},  --Kleia
		[18] = {578, 558, 0.2958984375, 0.578125, 0.0009765625, 0.5458984375},  --Mikanikos
		[7] = {578, 558, 0.5791015625, 0.861328125, 0.0009765625, 0.5458984375}, --Pelagos
    },

    [2] = { --"Venthyr"
        texture = "Interface\\Soulbinds\\SoulbindsShotsVenthyr",
		[3] = {603, 558, 0.6064453125, 0.90087890625, 0.0009765625, 0.5458984375},   --Draven
		[8] = {629, 558, 0.00048828125, 0.3076171875, 0.0009765625, 0.5458984375},   --Nadjia
		[9] = {608, 558, 0.30859375, 0.60546875, 0.0009765625, 0.5458984375},   --Theotar
    },

    [3]={   --Night Fae
        texture = "Interface\\Soulbinds\\SoulbindsShotsFey",
        [1]={578, 558, 0.591309, 0.873535, 0.000976562, 0.545898},    --Niya
        [2]={603, 558, 0.000488281, 0.294922, 0.000976562, 0.545898},  --Dreamweaver
        [6]={603, 558, 0.295898, 0.590332, 0.000976562, 0.545898},     --Korayn
    },

    [4]={   --Necrolord
        texture = "Interface\\Soulbinds\\SoulbindsShotsNecrolords",
		[5] = {629, 558, 0.00048828125, 0.3076171875, 0.0009765625, 0.5458984375}, --Emeni
		[4] = {572, 558, 0.5888671875, 0.8681640625, 0.0009765625, 0.5458984375},   --Marileth
		[10] = {572, 558, 0.30859375, 0.587890625, 0.0009765625, 0.5458984375},   --Heirmir
    },
}

function NarciSoulbindsMixin:SetPortrait(index)
    local covenantID = DataProvider:GetActiveCovenantID();
    if not atlasInfo[covenantID] then return end;
    local data = atlasInfo[covenantID][index];
    if data then
        local width, height, left, right, top, bottom = unpack(data);
        local ratio = 0.8;
        local effectiveWidth = (self:GetHeight())*width/height * ratio;
        self.Portrait:SetWidth(effectiveWidth);
        self.Portrait:SetTexture(atlasInfo[covenantID].texture);
        self.Portrait:SetTexCoord(left, left + (right - left)*ratio, top, bottom);
    end
end

function NarciSoulbindsMixin:SelectTree(soulbindID)
    self:ReleaseConduitFrames();
    local data;
    local activeSoulbindID = C_Soulbinds.GetActiveSoulbindID();
    soulbindID = soulbindID or activeSoulbindID;
    if soulbindID == 0 then
        soulbindID = self.defaultSoulbindID;
    end
    if soulbindID then
        data = C_Soulbinds.GetSoulbindData(soulbindID);
    else
        return
    end

    if not data or not data.tree then return end;

    local nodes = data.tree.nodes;
    if not nodes then return end;

    local node, conduitType, conduitState, spellID, conduitRank, traitID;
    local numRow = 0;
    local structure = GetNullStructure();
    for i = 1, #nodes do
        node = nodes[i];
        conduitState = node.state;
        if conduitState then
            if conduitState == 3 then
                structure[node.row + 1][node.column + 1] = 2;
                numRow = numRow + 1;
                conduitType = node.conduitType;
                conduitRank = node.conduitRank;
                if conduitType then
                    traitID = node.conduitID;
                else
                    traitID = node.spellID;
                end
                self:AcquireAndSetUpConduitFrame(i, traitID, conduitType, conduitRank, node.row, node.column);
            else
                structure[node.row + 1][node.column + 1] = 1;
            end
        end
    end

    --Node Links
    self:UpdatePipeline(structure);

    --Soulbinds Character Button
    if self.buttons then
        for i = 1, #self.buttons do
            SoulbindsCharacterButton_SetSelect(self.buttons[i], self.buttons[i].soulbindID == activeSoulbindID);
        end
    end

    if soulbindID == activeSoulbindID then
        self.Stone:SetVertexColor(1, 1, 1);
    else
        self.Stone:SetVertexColor(0.66, 0.66, 0.66);
    end

    self:SetPortrait(soulbindID);
end


----------------------------------------------
--Conduit Tooltip

local function AddComparisionByHyperlink(frame, link)
    if not link then return end;
    
    local itemID = strmatch(link, "item:(%d+):");
    local isConduit, knownLevel, description = DataProvider:GetKnownConduitItemLevel(itemID);
    if isConduit then
        frame:AddLine(" ");
        if knownLevel then
            frame:AddDoubleLine("Known", knownLevel, 1, 1, 1, 1, 1, 1);
            if description then
                frame:AddLine(description, nil, nil, nil, true);
            end
        else
            frame:AddLine("Unlearned", nil, nil, nil, true);
            print("New")
        end
        frame:Show();
    end
end

--[[
hooksecurefunc(GameTooltip, "SetBagItem", function(frame, bag, slot)
    local _, link = frame:GetItem();
    AddComparisionByHyperlink(frame, link);
end)

hooksecurefunc(GameTooltip, "SetHyperlink", function(frame, link)
    print(link)
    AddComparisionByHyperlink(frame, link);
end)
--]]

GameTooltip:HookScript("OnTooltipSetItem", function(frame)
    local _, link = frame:GetItem();
    AddComparisionByHyperlink(frame, link);
end);

GameTooltip.ItemTooltip.Tooltip:HookScript("OnTooltipSetItem", function(frame)
    local _, link = frame:GetItem();
    AddComparisionByHyperlink(frame, link);
end);
--]]


--[[
    column 0, 1, 2
    row 0, 1, ..., 7
    Enum.SoulbindNodeState:
        0 Unavailable
        1 Unselected
        2 Selectable
        3 Selected

    Enum.SoulbindConduitType:
        0 Finesse
        1 Potency
        2 Endurance
        3 Flex 
--]]