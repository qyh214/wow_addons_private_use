--[[
local _, _, _, tocversion = GetBuildInfo();
if tocversion ~= 80200 then     --Dressing Room gets a revamp in 8.2.5. Disable following funtions.
    return;
end
    -- Blizzard Dressing Room --
    Size:   450, 545
--]]

----------------------------------------------------------------------------------------
local defaultWidth, defaultHeight = 450, 545;       --BLZ dressing room size
local FrameAlpha_OnMoving = 0;                      --Currently Disabled
local buttonWidth, buttonGap = 54, 16;              --Equipment slots
local ButtonOffsetY = 20;                           --Equipment slots
local EmptySlotAlpha = 0.4;                         --Equipment slots
----------------------------------------------------------------------------------------

local GetTransmogItemInfo = C_TransmogCollection.GetItemInfo;
local GetTransmogSourceInfo = C_TransmogCollection.GetSourceInfo;
local GetAppearanceSources = C_TransmogCollection.GetAppearanceSources;     --(isCollected, sourceID, sourceType, visualID, itemID, itemModID)
local GetAppearanceSourceDrops = C_TransmogCollection.GetAppearanceSourceDrops;
local PlayerHasTransmog = C_TransmogCollection.PlayerHasTransmog;
local IsNewAppearance = C_TransmogCollection.IsNewAppearance;
local GetIllusionSourceInfo = C_TransmogCollection.GetIllusionSourceInfo;

local IsAppearanceKnown = NarciAPI_IsAppearanceKnown;
local FadeFrame = NarciAPI_FadeFrame;
local SlotIDtoName = Narci.SlotIDtoName;

local WidthHeitghtRatio = defaultWidth/defaultHeight;
local FirstButtonOffset = 0.5*(buttonWidth + buttonGap);
local OverrideHeight = math.floor(GetScreenHeight()*0.8 + 0.5);
local OverrideWidth = math.floor(WidthHeitghtRatio * OverrideHeight + 0.5);

local SlotFrameVisibility = true;            --If DressUp addon is loaded, hide our slot frame
local UseTargetModel = true;                 --Replace your model with target's

local XmogSlotTable = {
	[1] = {{5, INVTYPE_CHEST}, {15, INVTYPE_CLOAK}, {3, INVTYPE_SHOULDER}, {1, INVTYPE_HEAD}},		--Left 	**slotID for TABARD is 19
	[2] = {{7, INVTYPE_LEGS}, {8, INVTYPE_FEET}},								--Right
    [3] = {{16, INVTYPE_WEAPONMAINHAND}, {17, INVTYPE_WEAPONOFFHAND}},													--Weapon
    [4] = {{4, INVTYPE_BODY}, {19, INVTYPE_TABARD}},                                                                    --Shirt and Tabard
    ["Manual"] = {{10, INVTYPE_HAND}, {6, INVTYPE_WAIST}, {9, INVTYPE_WRIST}},                                          --Manually Created
};


local ModelScales = {
    --local GenderID = UnitSex(unit);   2 Male 3 Female
	--[raceID] = {male actorID, female actorID},
    [2]  = {483, 483},		-- Orc bow
    [3]  = {471, nil},		-- Dwarf
    [5]  = {472, 487},		-- UD   0.9585 seems small
    [6]  = {449, 484},		-- Tauren
    [7]  = {450, 450},		-- Gnome
    [8]  = {485, 486},		-- Troll  0.9414 too high?  
    [9]  = {476, 477},		-- Goblin
    [11] = {475, 501},		-- Goat
    [22] = {474, 500},      -- Worgen
    [24] = {473, 473},		-- Pandaren
    [28] = {490, 491},		-- Highmountain Tauren
    [30] = {488, 489},		-- Lightforged Draenei
    [31] = {492, 492},		-- Zandalari
    [32] = {494, 497},		-- Kul'Tiran
    [34] = {499, nil},		-- Dark Iron Dwarf
    [36] = {495, 498},		-- Mag'har

}


local function GetActorInfoByUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) or not CanInspect(unit, false) then return; end
    
    local _, _, raceID = UnitRace(unit);
    local genderID = UnitSex(unit);
    if raceID == 25 or raceID == 26 then --Pandaren A|H
        raceID = 24
    end
    if not (raceID and genderID) then
        return 438;
    elseif ModelScales[raceID] then
        return ModelScales[raceID][genderID - 1] or 438;
    else
        return 438;
    end
end

local function CreateSlotButton(frame)
    local strupper = strupper;
    local buttonName = "AdvancedDressUpFrameSlotButton";
    local buttonTemplate = "NarciRectangularItemButtonTemplate";
    local offsetX = 0;
    local buttonParent = frame.SlotFrame;
    local button, buttons = nil, {};
    local slotID = 6;                   --Start From Column 2, #2, Waist
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate)
    button:SetPoint("BOTTOMLEFT", buttonParent, "BOTTOM", -FirstButtonOffset, ButtonOffsetY);
    button:SetID(slotID)
    buttons[slotID] = button;

    slotID = 10                         --Left to the Waist :Hands 10
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate)
    button:SetPoint("RIGHT", buttons[6], "LEFT", -offsetX, 0);
    button:SetID(slotID)
    buttons[slotID] = button;

    local lastSlotID = 6;
    for _, v in pairs(XmogSlotTable[2]) do
        slotID = v[1];
        button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate)
        button:SetPoint("LEFT", buttons[lastSlotID], "RIGHT", offsetX, 0);
        button:SetID(slotID)
        buttons[slotID] = button;
        lastSlotID = slotID;
    end

    slotID = 9                         --Column 1 Right end :Wrist 9
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate)
    button:SetPoint("RIGHT", buttons[10], "LEFT", -offsetX - buttonGap, 0);
    button:SetID(slotID)
    buttons[slotID] = button;
    lastSlotID = slotID;

    for _, v in pairs(XmogSlotTable[1]) do
        slotID = v[1];
        button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate)
        button:SetPoint("RIGHT", buttons[lastSlotID], "LEFT", offsetX, 0);
        button:SetID(slotID)
        buttons[slotID] = button;
        lastSlotID = slotID;
    end

    slotID = 16                         --Column 3 Left end :Main Hand 16
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate)
    button:SetPoint("LEFT", buttons[8], "RIGHT", offsetX + buttonGap, 0);
    button:SetID(slotID)
    buttons[slotID] = button;

    slotID = 17                         --Column 3 Right end :Off Hand 17
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate)
    button:SetPoint("LEFT", buttons[16], "RIGHT", offsetX, 0);
    button:SetID(slotID)
    buttons[slotID] = button;

    
    slotID = 4                         --Column 4 Left end :Shirt 4
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate)
    button:SetPoint("LEFT", buttons[17], "RIGHT", offsetX + buttonGap, 0);
    button:SetID(slotID)
    buttons[slotID] = button;

    slotID = 19                         --Column 4 Left end :Shirt Tabard
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate)
    button:SetPoint("LEFT", buttons[4], "RIGHT", offsetX, 0);
    button:SetID(slotID)
    buttons[slotID] = button;
    
    local textureName, butID;
    for _, but in pairs(buttons) do
        butID = but:GetID();
        
        _, textureName = GetInventorySlotInfo((SlotIDtoName[butID][1]))
        but.SlotIcon:SetTexture(textureName)
    end

    frame.buttons = buttons;
    --]]
end

--------------------------------------------------
local function GenerateHyperlinkAndSource(itemID, itemModID, sourceID, sourceType, itemQuality, enchantID)
    local _, sourceID = GetTransmogItemInfo(itemID, itemModID)
    local hyperlink, unformatedHyperlink;
    --_, hyperlink = GetItemInfo(itemID)
    local sourceTextColorized, sourcePlainText = "", nil;
    local _, _, _, hex = GetItemQualityColor(itemQuality)

    if sourceType == 1 then --TRANSMOG_SOURCE_BOSS_DROP
        local drops = GetAppearanceSourceDrops(sourceID)
        if drops and drops[1] then
            sourceTextColorized = drops[1].encounter.." ".."|cFFFFD100"..drops[1].instance.."|r|CFFf8e694";
            sourcePlainText = drops[1].encounter.." "..drops[1].instance;
            
            if itemModID == 0 then 
                sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY1;
                sourcePlainText = sourcePlainText.." "..PLAYER_DIFFICULTY1;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:356".."1"..":1476:|h[ ]|h|r"
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:356".."1"..":1476"
            elseif itemModID == 1 then 
                sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY2;
                sourcePlainText = sourcePlainText.." "..PLAYER_DIFFICULTY2;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:356".."2"..":1476:|h[ ]|h|r"
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:356".."2"..":1476"
            elseif itemModID == 3 then 
                sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY6;
                sourcePlainText = sourcePlainText.." "..PLAYER_DIFFICULTY6;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:356".."3"..":1476:|h[ ]|h|r"
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:356".."3"..":1476"
            elseif itemModID == 4 then
                sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY3;
                sourcePlainText = sourcePlainText.." "..PLAYER_DIFFICULTY3;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:356".."4"..":1476:|h[ ]|h|r"
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:356".."4"..":1476"
            end
        end
    else
        if sourceType == 2 then --quest
            sourceTextColorized = TRANSMOG_SOURCE_2
            if itemModID == 3 then 
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:512".."6"..":1562:|h[ ]|h|r"
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:512".."6"..":1562"
            elseif itemModID == 2 then 
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:512".."5"..":1562:|h[ ]|h|r"
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:512".."5"..":1562"
            elseif itemModID == 1 then 
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:512".."4"..":1562:|h[ ]|h|r"
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:512".."4"..":1562"
            end
        elseif sourceType == 3 then --vendor
            sourceTextColorized = TRANSMOG_SOURCE_3
            hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r"
            unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::"
        elseif sourceType == 4 then --world drop
            sourceTextColorized = TRANSMOG_SOURCE_4
            hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r"
            unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::"
        elseif sourceType == 5 then --achievement
            sourceTextColorized = TRANSMOG_SOURCE_5
            hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r"
            unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::"
        elseif sourceType == 6 then	--profession
            sourceTextColorized = TRANSMOG_SOURCE_6
            hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r"
            unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::"
            --item:109168::::::::120::::1:620
            --[[
                stage 1 525
                stage 6 620
            152339::::::::120:::::
            --]]
        else
            if itemQuality == 6 then
                sourceTextColorized = ITEM_QUALITY6_DESC;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r"
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::"
            elseif itemQuality == 5 then
                sourceTextColorized = ITEM_QUALITY5_DESC;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r"
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::"
            end
        end
    end
    
    if not hyperlink then
        hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r"
        unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::"
    end
    
    return hyperlink, unformatedHyperlink, sourceTextColorized, (sourcePlainText or sourceTextColorized);
end

local function NarciBridge_GetDressUpModelSlotSource(slotID, enchantID)
    local sourcePlainText, itemQuality, itemIcon, hyperlink, unformatedHyperlink, itemModID, itemID, itemName, visualID, sourceType;
    local sourceTextColorized = "";
	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	if (not playerActor) then
		return;
	end
    local appliedSourceID, illusionSourceID = playerActor:GetSlotTransmogSources(slotID)
    local illusionName, isIllusionCollected, illusionHyperlink, illusionVisualID;
    if illusionSourceID and illusionSourceID ~= 0 then
        local illusionSourceInfo = GetTransmogSourceInfo(illusionSourceID)
        --print("illusionSourceID: "..illusionSourceID)
        if illusionSourceInfo then
            isIllusionCollected = illusionSourceInfo.isCollected;
            illusionVisualID, illusionName, illusionHyperlink = GetIllusionSourceInfo(illusionSourceID);
            --print(illusionName)
        end
    end
    if appliedSourceID < 0 then return; end

    local sourceInfo = GetTransmogSourceInfo(appliedSourceID)
    if not sourceInfo then return; end
    sourceType = sourceInfo.sourceType
    visualID = sourceInfo.sourceInfo;
    itemModID = sourceInfo.itemModID;
    itemID = sourceInfo.itemID;
    itemName = sourceInfo.name; 
    local appearanceID, _ = GetTransmogItemInfo(itemID, itemModID)							--appearanceID, sourceID
    itemIcon = GetItemIcon(itemID); 																--sourceitemIcon
    --local _, _, _, hex = GetItemQualityColor(itemQuality)
    _, hyperlink = GetItemInfo(itemID)

    local hasMog = PlayerHasTransmog(itemID, itemModID);
    --print(appearanceID)
    local AppearnceSources
    if appearanceID then
        AppearnceSources = GetAppearanceSources(appearanceID);
    end

    unformatedHyperlink = "item:"..itemID.."::::::::120:::::";
    
    itemQuality = sourceInfo.quality or 12;	
    hyperlink, unformatedHyperlink, sourceTextColorized, sourcePlainText = GenerateHyperlinkAndSource(itemID, itemModID, sourceID, sourceType, itemQuality, enchantID)
    --print(hyperlink.." itemModID: "..itemModID.."/"..sourceTextColorized)
    local hasAppearance = IsAppearanceKnown(hyperlink);
    if hasAppearance then
        --print("From another source: "..hyperlink)
        if AppearnceSources then
            for i = 1, #AppearnceSources do
                --print("Total Source: "..#AppearnceSources)
                if AppearnceSources[i] and AppearnceSources[i].isCollected then
                    
                    local CollectedItemID = AppearnceSources[i].itemID;
                    --print(CollectedItemID.." Collected")
                    local CollectedItemModID = AppearnceSources[i].itemModID;
                    hyperlink, unformatedHyperlink, sourceTextColorized, sourcePlainText = GenerateHyperlinkAndSource(CollectedItemID, CollectedItemModID, sourceID, sourceType, itemQuality, enchantID)
                    --print(hyperlink)
                    break;
                end
            end
        end
    end
    return appliedSourceID, itemIcon, (hasMog or hasAppearance), hyperlink, unformatedHyperlink, itemName, sourceTextColorized;
end

-------Create Mogit List-------
local newSet = {items = {}}
-------------------------------
local ItemList = {};

--Background Transition Animation--
local function SetDressUpBackground(frame, atlasPostfix)
	if ( frame.ModelBackground and frame.ModelBackgroundOverlay and atlasPostfix ) then
        frame.ModelBackgroundOverlay:SetAtlas("dressingroom-background-"..atlasPostfix);
        frame.ModelBackgroundOverlay:StopAnimating();
        frame.ModelBackgroundOverlay.animIn:Play();
	end
end

local function GetDressingSource(mainHandEnchant, offHandEnchant)
    local buttons = NarciBridge_DressUpFrame.buttons;
    local button, appliedSourceID, icon, hasMog, hyperlink, unformatedHyperlink, isIllusionCollected, illusionHyperlink;
    local enchantID;
    wipe(newSet.items)
    wipe(ItemList)
    for slotID, v in pairs(SlotIDtoName) do
        if slotID ~= 2 and slotID ~= 11 and slotID ~= 12 and slotID ~= 13 and slotID~=14 and slotID ~= 18 then
            if slotID == 16 then
                enchantID = mainHandEnchant or "";
            elseif slotID == 17 then
                enchantID = offHandEnchant or "";
            else
                enchantID = "";
            end
            appliedSourceID, icon, hasMog, hyperlink, unformatedHyperlink, itemName, sourceTextColorized = NarciBridge_GetDressUpModelSlotSource(slotID, enchantID);
            if illusionHyperlink then
                --hyperlink = illusionHyperlink;
            end     
            ItemList[slotID] = {itemName, sourceTextColorized};
            newSet.items[slotID] = hyperlink;
            button = buttons[slotID];
            button.hyperlink = hyperlink;
            if icon then
                if appliedSourceID then
                    button.appearance = appliedSourceID;
                end
                button.Icon:SetTexture(icon)
                if hasMog then
                    button.Icon:SetDesaturated(false);
                    button.Border:SetTexCoord(0.5, 1, 0, 1);
                    button.Black:Hide();
                else
                    button.Icon:SetDesaturated(true);
                    button.Border:SetTexCoord(0, 0.5, 0, 1);
                    button.Black:Show();
                end
                button:SetAlpha(1);
                button.Icon:Show();
            else
                if button.isHidden then
                    button:SetAlpha(EmptySlotAlpha);
                else
                    button:SetAlpha(EmptySlotAlpha);
                    button.Icon:Hide();
                    button.Border:SetTexCoord(0, 0.5, 0, 1);
                end
            end
        end
    end
end

local function NarciBridge_DressUpFrame_OnLoad(self)

    self:SetParent(DressUpFrame);
    self:GetParent():SetMovable(true);
    self:GetParent():RegisterForDrag("LeftButton");
    self:GetParent():SetScript("OnDragStart", function(self)
        self:StartMoving();	
    end);
    self:GetParent():SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing();
    end);
end

--Derivative of Blizzard DressUpFrames.lua--
local function DressUpSources(appearanceSources, mainHandEnchant, offHandEnchant)
    if ( not appearanceSources ) then
		return true;
    end

	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	if (not playerActor) then
		return true;
	end
    
    playerActor:Undress()
	local mainHandSlotID = 16   --GetInventorySlotInfo("MAINHANDSLOT");
    local secondaryHandSlotID = 17  --GetInventorySlotInfo("SECONDARYHANDSLOT");
	for i = 1, #appearanceSources do
		if ( i ~= mainHandSlotID and i ~= secondaryHandSlotID ) then
			if ( appearanceSources[i] and appearanceSources[i] ~= NO_TRANSMOG_SOURCE_ID ) then
                playerActor:TryOn(appearanceSources[i]);
			end
        end
        if NarciBridge_DressUpFrame.buttons[i] then
            NarciBridge_DressUpFrame.buttons[i].isHidden = false;
        end
	end

	playerActor:TryOn(appearanceSources[mainHandSlotID], "MAINHANDSLOT", mainHandEnchant);
    playerActor:TryOn(appearanceSources[secondaryHandSlotID], "SECONDARYHANDSLOT", offHandEnchant);

    return mainHandEnchant, offHandEnchant
end

local function CopyTexts(frame)
    local texts = "";
    for k, v in pairs(ItemList) do
        if v[1] and v[1] ~= "" then
            texts = texts .. "|cFFFFD100"..SlotIDtoName[k][2]..":|r " .. v[1];
            if v[2] and v[2] ~= "" then
                texts = texts .. " |cFF40C7EB(" .. v[2] .. ")|r"
            end
            texts = texts .. "\n"
        end
    end
    local GearTexts = frame:GetParent().GearTexts;
    GearTexts:SetText(strtrim(texts));
end

local function NarciBridge_DressUpFrame_OnModelLoaded(self)
    if self:GetDisplayInfo() ~= 0 then      --If the current model in Dressing Room is not players', hide slot frame.
        NarciBridge_DressUpFrame.SlotFrame:Hide();
    else
        NarciBridge_DressUpFrame_OnSizeChanged(NarciBridge_DressUpFrame);
        ResetHiddenSlot()
    end
    print("loaded")
end

local IsCurrentModelPlayer = false;
local function UpdateDressingRoomModel(self, unit)
    unit = unit or "player";
    if not UnitExists(unit) or not UnitIsPlayer(unit) or not CanInspect(unit, false) then return; end
    local className, classFileName = UnitClass(unit);
    local frame = DressUpFrame;
    SetDressUpBackground(frame, classFileName);
    local ModelScene = frame.ModelScene;
    local actor = ModelScene:GetPlayerActor();
    if not actor then return; end;

    --Acquire target's gears
    NotifyInspect(unit);

    local modelUnit;
    local updateScale;
    local sheatheWeapons = actor:GetSheathed() or false;

    if UseTargetModel then
        modelUnit = unit;
        actor:SetModelByUnit(modelUnit, sheatheWeapons, true);
        updateScale = true;
        IsCurrentModelPlayer = false;
    else
        modelUnit = "player";
        if not IsCurrentModelPlayer then
            IsCurrentModelPlayer = true;
            actor:SetModelByUnit(modelUnit, sheatheWeapons, true);
            updateScale = true;
        end
    end

    if updateScale then
        local modelInfo = C_ModelInfo.GetModelSceneActorInfoByID(GetActorInfoByUnit(modelUnit));
        C_Timer.After(0.0,function()
            ModelScene:InitializeActor(actor, modelInfo);   --Re-scale
        end);
    end

    C_Timer.After(0.1,function()
        self.mainHandEnchant, self.offHandEnchant = DressUpSources(C_TransmogCollection.GetInspectSources())
        GetDressingSource(self.mainHandEnchant, self.offHandEnchant)
        if NarciBridge_DressUpFrame.OptionFrame.GearTexts:IsShown() then
            CopyTexts(NarciBridge_DressUpFrame.OptionFrame.GearTexts)
        end
        ClearInspectPlayer();
    end);
end

local function NarciBridge_DressUpFrame_OnEvent(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateDressingRoomModel(self, "target");
    elseif event == "PLAYER_STARTED_MOVING" then
        local parent = self:GetParent();
        UIFrameFadeOut(parent, 0.2, parent:GetAlpha(), FrameAlpha_OnMoving)
    elseif event == "PLAYER_STOPPED_MOVING" then
        local parent = self:GetParent();
        UIFrameFadeIn(parent, 0.2, parent:GetAlpha(), 1)
    end
end

local function NarciBridge_DressUpFrame_OnSizeChanged(self, width, height)
    --print(width.." x "..height);
    if GetCVar("miniDressUpFrame") == "0" and SlotFrameVisibility then
        self.SlotFrame:Show();
    else
        self.SlotFrame:Hide();
    end
end

local function NarciBridge_DressUpFrame_OnShow(self)
    self:RegisterEvent("PLAYER_TARGET_CHANGED");
    --self:RegisterEvent("PLAYER_STARTED_MOVING");
    --self:RegisterEvent("PLAYER_STOPPED_MOVING");
    --UpdateDressingRoomModel(self)
end

local function ResetHiddenSlot()
    --print("Load model...")
    for i = 1, 19 do
        if NarciBridge_DressUpFrame.buttons[i] then
            NarciBridge_DressUpFrame.buttons[i].isHidden = false;
            NarciBridge_DressUpFrame.buttons[i].appearance = nil;
        end
    end
end
-------------------------------------------
--From Blizzard DressUpFrame_OnDressModel--
local function DressUpFrame_OnDressModel2(self)
	-- only want 1 update per frame
	if ( not self.gotDressed ) then
		self.gotDressed = true;
        C_Timer.After(0, function()
            self.gotDressed = nil;
            DressUpFrameOutfitDropDown:UpdateSaveButton();
            C_Timer.After(0.2,function()
                GetDressingSource(self.mainHandEnchant, self.offHandEnchant)
                if NarciBridge_DressUpFrame.OptionFrame.GearTexts:IsShown() then
                    CopyTexts(NarciBridge_DressUpFrame.OptionFrame.GearTexts)
                end
            end);
        end);
	end
end

local function NarciBridge_DressUpFrame_OnDressModel(self)
    DressUpFrame_OnDressModel2(self);
end
-----------------------------------------

function NarciBridge_UpdateCharacterButton_OnClick(self)
    UpdateDressingRoomModel(self:GetParent():GetParent())
end

local function NarciBridge_DressUpFrame_OnHide(self)
    self:UnregisterAllEvents();
end

local function NarciBridge_MogIt_SaveButton_OnClick(self)
    StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, newSet);    --Create a new whishlist
    MogIt.view:Show();  --Open a view window
end

local function CopyTextButton_OnClick(self)
    CopyTexts(self)
    local GearTexts = self:GetParent().GearTexts;
    if not GearTexts:IsShown() then
        FadeFrame(GearTexts, 0.25, "IN")
    else
        FadeFrame(GearTexts, 0.25, "OUT")
    end
end

local function TryOnButton_OnClick(self)
    local state = NarcissusDB.DressingRoomUseTargetModel;
    NarcissusDB.DressingRoomUseTargetModel = not state
    UseTargetModel = not state;
    if not state then   --true
        self.Label:SetText("Use Target's Model");
    else
        self.Label:SetText("Use Your Model");
    end
    UpdateDressingRoomModel(self, "target");
end

local function NarciBridge_DressUpFrame_Initialize()
    if not (NarcissusDB and NarcissusDB.DressingRoom) then return; end;
    local parentFrame = DressUpFrame;
    --local modelFrame = DressUpModel;
    if not parentFrame then 
        print("Narcissus failed to initialize Advanced Dressing Room");
        return;
    end
    local frame = CreateFrame("Frame", "NarciBridge_DressUpFrame", parentFrame, "NarciBridge_DressUpFrame_Template")
    CreateSlotButton(frame)
    NarciBridge_DressUpFrame_OnLoad(frame);
    frame:SetScript("OnShow", NarciBridge_DressUpFrame_OnShow);
    frame:SetScript("OnHide", NarciBridge_DressUpFrame_OnHide);
    frame:SetScript("OnEvent", NarciBridge_DressUpFrame_OnEvent);
    frame:SetScript("OnSizeChanged", NarciBridge_DressUpFrame_OnSizeChanged);

    local texName = parentFrame:GetName() and parentFrame:GetName().."BackgroundOverlay"
    local tex = parentFrame:CreateTexture(texName, "BACKGROUND", "ModelBackground_Template", 2)

    if MaximizeMinimizeFrame then
        local function OnMaximize(frame)
            frame:GetParent():SetSize(OverrideWidth, OverrideHeight);   --Override DressUpFrame Resize Mixin
            UpdateUIPanelPositions(frame);
        end

        MaximizeMinimizeFrame:SetOnMaximizedCallback(OnMaximize);
    end

    hooksecurefunc("DressUpVisual", function()
        local frame = NarciBridge_DressUpFrame;
        if frame and SlotFrameVisibility and GetCVar("miniDressUpFrame") == "0" then
            frame.SlotFrame:Show();
            frame.OptionFrame.CopyButton:Show();
            GetDressingSource(frame.mainHandEnchant, frame.offHandEnchant)
            if frame.OptionFrame.GearTexts:IsShown() then
                CopyTexts(frame.OptionFrame.GearTexts)
            end
        end
    end)
    
    local function HideIrrelevantUI()
        local frame = NarciBridge_DressUpFrame;
        if frame then
            frame.SlotFrame:Hide();
            frame.OptionFrame.CopyButton:Hide();
        end
    end
    
    hooksecurefunc("DressUpMountLink", function()
        HideIrrelevantUI()
    end)
    
    hooksecurefunc("DressUpBattlePetLink", function()
        HideIrrelevantUI()
    end)

    frame.OptionFrame.CopyButton:SetScript("OnClick", CopyTextButton_OnClick);
    local TryOnButton = frame.OptionFrame.TryOnButton;
    TryOnButton:SetScript("OnClick", TryOnButton_OnClick);

    --[[
    function ModelSceneActorMixin:OnModelLoaded()   --Mixin Override DressUpFrame Resize Mixin
        --Original 8.2.5
        self:MarkScaleDirty();

        --Narcissus
        print(self:GetParent():GetParent():GetName())
    end
    --]]
end


local initialize = CreateFrame("Frame")
initialize:RegisterEvent("VARIABLES_LOADED");
initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
initialize:RegisterEvent("UI_SCALE_CHANGED");
initialize:SetScript("OnEvent",function(self,event,...)
    if event == "VARIABLES_LOADED" then
        self:UnregisterEvent("VARIABLES_LOADED");
        NarciBridge_DressUpFrame_Initialize();
    elseif event == "PLAYER_ENTERING_WORLD" then
        UseTargetModel = NarcissusDB.DressingRoomUseTargetModel;
        if not NarciBridge_DressUpFrame then
            self:UnregisterAllEvents();
            return
        end

        local TryOnButton = NarciBridge_DressUpFrame.OptionFrame.TryOnButton;
        TryOnButton:SetScript("OnClick", TryOnButton_OnClick);
        if UseTargetModel then   --true
            TryOnButton.Label:SetText("Use Target's Model");
        else
            TryOnButton.Label:SetText("Use Your Model");
        end

        if IsAddOnLoaded("MogIt") and MogIt then                         --Mogit: Add Save as Mogit wishlist
            local button = NarciBridge_SaveToMogItButton;
            button:Show();
            button:SetHeight(48);
            button:SetScript("OnClick", NarciBridge_MogIt_SaveButton_OnClick);
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        end

        if IsAddOnLoaded("DressUp") then                                --DressUp: Hide our dressing room slot frame
            NarciBridge_DressUpFrame.SlotFrame:Hide();
            SlotFrameVisibility = false;
        end
    elseif event == "UI_SCALE_CHANGED" then
        C_Timer.After(0.5, function()
            OverrideHeight = math.floor(GetScreenHeight()*0.8 + 0.5);
            OverrideWidth = math.floor(WidthHeitghtRatio * OverrideHeight + 0.5);
            if GetCVar("miniDressUpFrame") == "0" then
                DressUpFrame:SetSize(OverrideWidth, OverrideHeight)
            end
        end)
    end
end);

local isMouseDown = false;

function NarciRectangularItemButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 1);
	if (self.hyperlink) then
		GameTooltip:SetHyperlink(self.hyperlink);
		GameTooltip:Show();
    end
end

function NarciRectangularItemButton_OnLeave(self)
    GameTooltip:Hide();
end

function NarciRectangularItemButton_OnClick(self)
    GameTooltip:Hide();
    self.isHidden = not self.isHidden;
	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	if (not playerActor) then
		return true;
    end
    
    if self.isHidden then
        playerActor:UndressSlot(self:GetID());
        self.Icon:SetDesaturated(true);
    elseif self.appearance then
        --print(self.appearance)
        playerActor:TryOn(self.appearance);
        self.Icon:SetDesaturated(false);
    end
end

function NarciRectangularItemButton_OnDragStart()
    isMouseDown = true;
end

function NarciRectangularItemButton_OnDragStop()
    isMouseDown = false;
end


--[[
hooksecurefunc("PanelTemplates_TabResize", function(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)
    print(tab:GetName())
    print(padding)
    print(absoluteSize)
    print(minWidth)
    print(maxWidth)
end)

/run A1=DressUpFrame.ModelScene:GetPlayerActor()
/run DressUpFrame.ModelScene:SetLightDirection(- 0.44699833180028 ,  0.72403680806459 , -0.52532198881773)
/dump A1:GetScale();    SetModelByUnit  SetModelByFileID GetModelFileID()
/dump A1:GetModelFileID()   1100258 BE female
/run A1:SetAnimation()  48 CrossBow/Rifle 
/dump A1:SetCustomRace(1,1)
/dump A1.OnModelLoaded
/run A1:TryOn(105951)   105951 Renowned Explorer's Versatile Vest 105950 104948 105946 105945 105949 105947 105944 Cap    105952 Cloak 105959 Tabard  105953 Rucksack     1287 Explorer's Jungle Hopper
/script local a=DressUpFrame.ModelScene:GetPlayerActor();a:Undress();for i=105945,105951 do a:TryOn(i);end;a:TryOn(105953);

Wooly Wendigo
/script local a=DressUpFrame.ModelScene:GetPlayerActor();a:Undress();for i=105954,105958 do a:TryOn(i);end;

/script local a=NarciPlayerModelFrame1;a:Undress();for i=105945,105951 do a:TryOn(i);end;a:TryOn(105953);
/run NarciPlayerModelFrame1:TryOn(66602)
/dump DressUpFrame.ModelScene:GetCameraPosition()
/dump DressUpFrame.ModelScene:GetActiveCamera():GetZoomDistance()
:GetZoomDistance()
local modelSceneType, cameraIDs, actorIDs = C_ModelInfo.GetModelSceneInfoByID(modelSceneID);
playerActor:SetRequestedScale()
/run A1:SetRequestedScale(0.65)
C_ModelInfo.GetModelSceneActorInfoByID(486)
ModelScene:AcquireActor()
/run DressUpFrame.ModelScene:InitializeActor(DressUpFrame.ModelScene:GetPlayerActor(), C_ModelInfo.GetModelSceneActorInfoByID(438))
/run local a = C_ModelInfo.GetModelSceneActorInfoByID(438);print(a.scriptTag)
/run DressUpFrame.ModelScene:CreateActorFromScene(486)
/run DressUpFrame.ModelScene:AcquireAndInitializeActor(C_ModelInfo.GetModelSceneActorInfoByID(486))
/dump DressUpFrame.ModelScene.actorTemplate ModelSceneActorTemplate
ApplyFromModelSceneActorInfo
ReleaseAllActors()

/dump C_TransmogCollection.GetItemInfo(itemID)  171324 118559 Shovel 66602 (return appearanceID, sourceID)
2921871 Gillvanas ModelFileID 93312(DisplayID)  Finduin 2924741/93311 animation 217
A1:SetAnimation(217,1,0.5,0)
9331 Gnome
/run NarciBridge_DressUpFrame.SlotFrame:Hide();

function DressUpMountLink(link)
	if( link ) then
		local mountID = 0;

		local _, _, _, linkType, linkID = strsplit(":|H", link);
		if linkType == "item" then
			mountID = C_MountJournal.GetMountFromItem(tonumber(linkID));
		elseif linkType == "spell" then
			mountID = C_MountJournal.GetMountFromSpell(tonumber(linkID));
		end

		if ( mountID ) then
			return DressUpMount(mountID);
		end
	end
	return false
end
local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType = C_PetJournal.GetPetInfoByPetID(petID)
SpeciesID = C_PetJournal.GetPetInfoByIndex()
speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
C_PetJournal.FindPetIDByName()

local creatureDisplayID, _, _, isSelfMount, _, modelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID);   --93202 Hopper
	local mountActor = frame.ModelScene:GetActorByTag("unwrapped");
	if mountActor then
        mountActor:SetModelByCreatureDisplayID(creatureDisplayID);  --93202
DressUpFrame.ModelScene:AttachPlayerToMount(A2, 91, false, false);       
DressUpFrame.ModelScene:AttachPlayerToMount(mountActor, animID, isSelfMount, disablePlayerMountPreview);   

				local calcMountScale = mountActor:CalculateMountScale(playerActor);
				local inverseScale = 1 / calcMountScale; 
				playerActor:SetRequestedScale( inverseScale );
                mountActor:AttachToMount(playerActor, animID, spellVisualKitID);
                
actorIDs:
[486] = troll-female 0.65   (expected:0.8526)
[487] = undead-female
[488] = lightforgeddraenei-male
[489] = lightforgeddraenei-female
[490] = highmountaintauren-male
[491] = highmountaintauren-female
[492] = zandalaritroll
[495] = magharorc-male
[497] = kultiran-female
[498] = magharorc-female
[499] = darkirondwarf-male
[500] = worgen-female
[501] = draenei-female
[494] = kultiran-male
[438]   player!!!!
[449] = tauren-male
[450] = gnome
[471] = dwarf-male
[472] = undead-male
[473] = pandaren
[474] = worgen-male
[475] = draenei-male
[484] = tauren-female
[483] = orc
[477] = goblin-female
[476] = goblin-male
[485] = troll-male


normalizeScaleAggressiveness
A1:CalculateNormalizedScale(0.65)
/run MountDressingRoom(307256)

--Unlisted APIs:
ModelSceneActor:
SetModelByFileID(fileID [, enableMips])
SetModelByCreatureDisplayID()
SetAnimation(animation[, variation, animSpeed, timeOffsetSecs])
SetSpellVisualKit(spellVisualKitID[, oneShot])

--]]





--[[
--For Testing

function MountDressingRoom(mountSpellID)
    if not DressingRoomMountModel then
        DressingRoomMountModel = DressUpFrame.ModelScene:CreateActor();
    end

    local mountActor = DressingRoomMountModel;
    local ModelScene = DressUpFrame.ModelScene;
    local playerActor = ModelScene:GetPlayerActor();

    local mountID = C_MountJournal.GetMountFromSpell(tonumber(mountSpellID));
    local creatureDisplayID, _, _, isSelfMount, _, modelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID);   --93202 Hopper
    mountActor:SetModelByCreatureDisplayID(creatureDisplayID);

    local calcMountScale = mountActor:CalculateMountScale(playerActor);
    if false then   --Scale down Player
        local inverseScale = 1 / calcMountScale; 
        playerActor:SetRequestedScale( inverseScale );
    else            --Scale Mount
        mountActor:SetScale( calcMountScale );
    end
    playerActor:SetYaw(0)
    mountActor:AttachToMount(playerActor, animID, spellVisualKitID);
end

function GetActorScriptTag(actorID)
    local a = C_ModelInfo.GetModelSceneActorInfoByID(actorID)
    if a then print(" Tag: "..(a.scriptTag or "N/A") ); end;
end

function GetAllActorScriptTags()
    local modelSceneID = 290;       --DressUpFrame
    local _, _, actorIDs = C_ModelInfo.GetModelSceneInfoByID(modelSceneID);
    for k, v in pairs(actorIDs) do
        print("ID: "..(k or "N/A"));
        GetActorScriptTag(v);
    end
end

function GetDressUpFrameInfo()
    local ModelScene = DressUpFrame.ModelScene;
    local camera = ModelScene:GetActiveCamera();
    local actor = ModelScene:GetPlayerActor();
    local scale = actor:GetScale();
    local x, y, z = ModelScene:GetCameraPosition();
    local cameraDistance = camera:GetZoomDistance();
    print("Model Scale: "..scale);
    print(x.."\n"..y.."\n"..z);
    print("Distance: "..cameraDistance)
    --/run GetDressUpFrameInfo()
end

function TestActorIDs(begin, ending)
    local temp;
    for i = begin, ending do
        temp = C_ModelInfo.GetModelSceneActorInfoByID(i)
        if temp and temp.scriptTag then
            print(i.." Tag: "..temp.scriptTag);
        end
    end
end

hooksecurefunc("ChatFrame_DisplayUsageError", function(messageTag)
    print(messageTag)
end)
--]]