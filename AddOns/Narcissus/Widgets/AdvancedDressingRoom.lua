--[[
local _, _, _, tocversion = GetBuildInfo();
if tocversion ~= 80200 then     --Dressing Room gets a revamp in 8.2.5. Disable following funtions.
    return;
end
    -- Blizzard Dressing Room --
    Size:   450, 545
--]]

----------------------------------------------------------------------------------------
local DEFAULT_WIDTH, DEFAULT_HEIGHT = 450, 545;       --BLZ dressing room size
local FrameAlpha_OnMoving = 0;                      --Currently Disabled
local buttonWidth, buttonGap = 54, 16;              --Equipment slots
local ButtonOffsetY = 20;                           --Equipment slots
local EmptySlotAlpha = 0.4;                         --Equipment slots
----------------------------------------------------------------------------------------
local L = Narci.L;
local PI = math.pi;
local After = C_Timer.After;
local C_TransmogCollection = C_TransmogCollection;
local GetTransmogItemInfo = C_TransmogCollection.GetItemInfo;
local GetTransmogSourceInfo = C_TransmogCollection.GetSourceInfo;
local GetAppearanceSources = C_TransmogCollection.GetAppearanceSources;     --(isCollected, sourceID, sourceType, visualID, itemID, itemModID)
local GetAppearanceSourceDrops = C_TransmogCollection.GetAppearanceSourceDrops;
local PlayerHasTransmog = C_TransmogCollection.PlayerHasTransmog;
local IsNewAppearance = C_TransmogCollection.IsNewAppearance;
local GetIllusionSourceInfo = C_TransmogCollection.GetIllusionSourceInfo;
local IsFavorite = C_TransmogCollection.GetIsAppearanceFavorite;
local IsAppearanceKnown = NarciAPI.IsAppearanceKnown;
local FadeFrame = NarciAPI_FadeFrame;
local SlotIDtoName = Narci.SlotIDtoName;

local WIDTH_HEIGHT_RATIO = DEFAULT_WIDTH/DEFAULT_HEIGHT;
local RIRST_BUTTON_OFFSET = 0.5*(buttonWidth + buttonGap);
local OVERRIDE_HEIGHT = math.floor(GetScreenHeight()*0.8 + 0.5);
local OVERRIDE_WIDTH = math.floor(WIDTH_HEIGHT_RATIO * OVERRIDE_HEIGHT + 0.5);

local SlotFrameVisibility = true;            --If DressUp addon is loaded, hide our slot frame
local UseTargetModel = true;                 --Replace your model with target's

local XmogSlotTable = {
	[1] = {{5, INVTYPE_CHEST}, {15, INVTYPE_CLOAK}, {3, INVTYPE_SHOULDER}, {1, INVTYPE_HEAD}},		                    --Left 	**slotID for TABARD is 19
	[2] = {{7, INVTYPE_LEGS}, {8, INVTYPE_FEET}},								                                        --Right
    [3] = {{16, INVTYPE_WEAPONMAINHAND}, {17, INVTYPE_WEAPONOFFHAND}},													--Weapon
    [4] = {{4, INVTYPE_BODY}, {19, INVTYPE_TABARD}},                                                                    --Shirt and Tabard
    ["Manual"] = {{10, INVTYPE_HAND}, {6, INVTYPE_WAIST}, {9, INVTYPE_WRIST}},                                          --Manually Created
};

local GetActorInfoByUnit = NarciAPI_GetActorInfoByUnit;

--Frames:
local DressingRoomOverlayFrame;

local function CreateSlotButton(frame)
    local buttonName = "AdvancedDressUpFrameSlotButton";
    local buttonTemplate = "NarciRectangularItemButtonTemplate";
    local offsetX = 0;
    local buttonParent = frame.SlotFrame;
    local button, buttons = nil, {};
    local slotID = 6;                   --Start From Column 2, #2, Waist
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate);
    button:SetPoint("BOTTOMLEFT", buttonParent, "BOTTOM", -RIRST_BUTTON_OFFSET, ButtonOffsetY);
    button:SetID(slotID)
    buttons[slotID] = button;

    slotID = 10;                         --Left to the Waist :Hands 10
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate);
    button:SetPoint("RIGHT", buttons[6], "LEFT", -offsetX, 0);
    button:SetID(slotID);
    buttons[slotID] = button;

    local lastSlotID = 6;
    for _, v in pairs(XmogSlotTable[2]) do
        slotID = v[1];
        button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate);
        button:SetPoint("LEFT", buttons[lastSlotID], "RIGHT", offsetX, 0);
        button:SetID(slotID)
        buttons[slotID] = button;
        lastSlotID = slotID;
    end

    slotID = 9;                         --Column 1 Right end :Wrist 9
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate);
    button:SetPoint("RIGHT", buttons[10], "LEFT", -offsetX - buttonGap, 0);
    button:SetID(slotID);
    buttons[slotID] = button;
    lastSlotID = slotID;

    for _, v in pairs(XmogSlotTable[1]) do
        slotID = v[1];
        button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate);
        button:SetPoint("RIGHT", buttons[lastSlotID], "LEFT", offsetX, 0);
        button:SetID(slotID)
        buttons[slotID] = button;
        lastSlotID = slotID;
    end

    slotID = 16;                         --Column 3 Left end :Main Hand 16
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate);
    button:SetPoint("LEFT", buttons[8], "RIGHT", offsetX + buttonGap, 0);
    button:SetID(slotID);
    buttons[slotID] = button;

    slotID = 17;                         --Column 3 Right end :Off Hand 17
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate);
    button:SetPoint("LEFT", buttons[16], "RIGHT", offsetX, 0);
    button:SetID(slotID);
    buttons[slotID] = button;

    
    slotID = 4;                         --Column 4 Left end :Shirt 4
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate);
    button:SetPoint("LEFT", buttons[17], "RIGHT", offsetX + buttonGap, 0);
    button:SetID(slotID);
    buttons[slotID] = button;

    slotID = 19;                         --Column 4 Left end :Shirt Tabard
    button = CreateFrame("BUTTON", buttonName..slotID, buttonParent, buttonTemplate);
    button:SetPoint("LEFT", buttons[4], "RIGHT", offsetX, 0);
    button:SetID(slotID);
    buttons[slotID] = button;
    
    local textureName, buttonID;
    for _, but in pairs(buttons) do
        buttonID = but:GetID();
        
        _, textureName = GetInventorySlotInfo((SlotIDtoName[buttonID][1]));
        but.SlotIcon:SetTexture(textureName)
    end

    frame.buttons = buttons;
    
    wipe(XmogSlotTable);
end

--------------------------------------------------
------Get Animation By Class and Weapon Type------
--------------------------------------------------
local function SetAnimationIDByUnit(unit)
	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	if (not playerActor) then
		return
    end

    local id = 0;
    local _, _, classID = UnitClass(unit or "player");
    local appliedSourceID, _ = playerActor:GetSlotTransmogSources(16)   --Main-hand slot

    if appliedSourceID and appliedSourceID > 0 then
        local weaponType = GetTransmogSourceInfo(appliedSourceID).categoryID;

        if not classID then
            playerActor.unsheathedAnimationID = 0;
            return
        end

        if classID == 12 then           --DH
            id = 1026;
        elseif classID == 10 then       --Monk
            if weaponType == 17 then    --fist
                id = 678;
            else
                id = 0;
            end
        else
            if weaponType == 17 then
                id = 0
            elseif weaponType == 26 or weaponType == 27 then    --Gun/Crossbow
                id = 48;
            elseif weaponType == 25 then    --Bow
                id = 29;
            elseif weaponType == 23 or weaponType == 24 then
                id = 28;
            elseif weaponType == 20 or weaponType == 21 or weaponType == 22 then    --2H Axe/Sword/Mace
                id = 27;
            else
                id = 26;    --Dual wield
            end
        end
    end

    playerActor.unsheathedAnimationID = id;
end

--------------------------------------------------
local function GenerateHyperlinkAndSource(slotID, itemID, itemModID, sourceID, sourceType, itemQuality, enchantID)
    local _, sourceID = GetTransmogItemInfo(itemID, itemModID)
    local hyperlink, unformatedHyperlink;
    --_, hyperlink = GetItemInfo(itemID)
    local sourceTextColorized, sourcePlainText = "", nil;
    local _, _, _, hex = GetItemQualityColor(itemQuality)
    local bonusID = 0;
    if sourceType == 1 then --TRANSMOG_SOURCE_BOSS_DROP
        local drops = GetAppearanceSourceDrops(sourceID)
        if drops and drops[1] then
            sourceTextColorized = drops[1].encounter.." ".."|cFFFFD100"..drops[1].instance.."|r|CFFf8e694";
            sourcePlainText = drops[1].encounter.." "..drops[1].instance;
            
            if itemModID == 0 then 
                sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY1;
                sourcePlainText = sourcePlainText.." "..PLAYER_DIFFICULTY1;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:356".."1"..":1476:|h[ ]|h|r";
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:356".."1"..":1476";
                bonusID = 3561;
            elseif itemModID == 1 then 
                sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY2;
                sourcePlainText = sourcePlainText.." "..PLAYER_DIFFICULTY2;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:356".."2"..":1476:|h[ ]|h|r";
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:356".."2"..":1476";
                bonusID = 3562;
            elseif itemModID == 3 then 
                sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY6;
                sourcePlainText = sourcePlainText.." "..PLAYER_DIFFICULTY6;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:356".."3"..":1476:|h[ ]|h|r";
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:356".."3"..":1476";
                bonusID = 3563;
            elseif itemModID == 4 then
                sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY3;
                sourcePlainText = sourcePlainText.." "..PLAYER_DIFFICULTY3;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:356".."4"..":1476:|h[ ]|h|r";
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:356".."4"..":1476";
                bonusID = 3564;
            end
        end
    else
        if sourceType == 2 then --quest
            sourceTextColorized = TRANSMOG_SOURCE_2
            if itemModID == 3 then 
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:512".."6"..":1562:|h[ ]|h|r";
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:512".."6"..":1562";
                bonusID = 5126;
            elseif itemModID == 2 then 
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:512".."5"..":1562:|h[ ]|h|r";
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:512".."5"..":1562";
                bonusID = 5125;
            elseif itemModID == 1 then 
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120::::2:512".."4"..":1562:|h[ ]|h|r";
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120::::2:512".."4"..":1562";
                bonusID = 5124;
            end
        elseif sourceType == 3 then --vendor
            sourceTextColorized = TRANSMOG_SOURCE_3
            hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r";
            unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::";
        elseif sourceType == 4 then --world drop
            sourceTextColorized = TRANSMOG_SOURCE_4
            hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r";
            unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::";
        elseif sourceType == 5 then --achievement
            sourceTextColorized = TRANSMOG_SOURCE_5
            hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r"
            unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::"
        elseif sourceType == 6 then	--profession
            sourceTextColorized = TRANSMOG_SOURCE_6
            hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r";
            unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::";
            --item:109168::::::::120::::1:620
            --[[
                stage 1 525
                stage 6 620
            152339::::::::120:::::
            --]]
        else
            if itemQuality == 6 then
                sourceTextColorized = ITEM_QUALITY6_DESC;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r";
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::";
				if slotID == 16 then
					bonusID = itemModID or 0;	--Artifact use itemModID "7V0" + modID - 1
				else
					bonusID = 0;
				end
            elseif itemQuality == 5 then
                sourceTextColorized = ITEM_QUALITY5_DESC;
                hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r";
                unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::";
            end
        end
    end
    
    if not hyperlink then
        hyperlink = "|c"..hex.."|Hitem:"..itemID..":"..enchantID..":::::::120:::::|h[ ]|h|r";
        unformatedHyperlink = "item:"..itemID..":"..enchantID..":::::::120:::::";
    end
    
    return hyperlink, unformatedHyperlink, bonusID, sourceTextColorized, (sourcePlainText or sourceTextColorized);
end

local function NarciBridge_GetDressUpModelSlotSource(slotID, enchantID)
    local sourcePlainText, itemQuality, itemIcon, hyperlink, unformatedHyperlink, bonusID, itemModID, itemID, itemName, visualID, sourceType, _;
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

    local sourceInfo = GetTransmogSourceInfo(appliedSourceID);
    if not sourceInfo then return; end
    sourceType = sourceInfo.sourceType;
    visualID = sourceInfo.sourceInfo;
    itemModID = sourceInfo.itemModID;
    itemID = sourceInfo.itemID;
    itemName = sourceInfo.name; 
    local appearanceID, sourceID = GetTransmogItemInfo(itemID, itemModID);							        --appearanceID, sourceID
    itemIcon = C_TransmogCollection.GetSourceIcon(appliedSourceID)
    --local _, _, _, hex = GetItemQualityColor(itemQuality)
    _, hyperlink = GetItemInfo(itemID);

    local hasMog = PlayerHasTransmog(itemID, itemModID);
    --print(appearanceID)
    local AppearnceSources
    if appearanceID then
        AppearnceSources = GetAppearanceSources(appearanceID);
    end

    unformatedHyperlink = "item:"..itemID.."::::::::120:::::";
    
    itemQuality = sourceInfo.quality or 12;	
    hyperlink, unformatedHyperlink, bonusID, sourceTextColorized, sourcePlainText = GenerateHyperlinkAndSource(slotID, itemID, itemModID, sourceID, sourceType, itemQuality, enchantID)
    --print(hyperlink.." itemModID: "..itemModID.."/"..sourceTextColorized)
    local hasAppearance = IsAppearanceKnown(hyperlink);
    if hasAppearance then
        --print("From another source: "..hyperlink)
        if AppearnceSources then
            for i = 1, #AppearnceSources do
                --print("Total Source: "..#AppearnceSources)
                if AppearnceSources[i] and AppearnceSources[i].isCollected then
                    
                    local collectedItemID = AppearnceSources[i].itemID;
                    --print(collectedItemID.." Collected")
                    local collectedItemModID = AppearnceSources[i].itemModID;
                    hyperlink, unformatedHyperlink, bonusID, sourceTextColorized, sourcePlainText = GenerateHyperlinkAndSource(slotID, collectedItemID, collectedItemModID, sourceID, sourceType, itemQuality, enchantID)
                    --print(hyperlink)
                    break;
                end
            end
        end
    end
    return appliedSourceID, appearanceID, itemIcon, (hasMog or hasAppearance), hyperlink, unformatedHyperlink, itemName, sourceTextColorized, itemID, bonusID
end

-------Create Mogit List-------
local newSet = {items = {}}
-------------------------------
local ItemList = {};
local UnitInfo = {
    raceID = nil,
    genderID = nil,
    classID = nil,
};

--Background Transition Animation--
local function SetDressUpBackground(unit, instant)
    local _, atlasPostfix = UnitClass(unit or "player");
    local frame = DressUpFrame;
    if ( frame.ModelBackground and frame.ModelBackgroundOverlay and atlasPostfix ) then
        if instant then
            frame.ModelBackground:SetAtlas("dressingroom-background-"..atlasPostfix);
        else
            frame.ModelBackgroundOverlay:SetAtlas("dressingroom-background-"..atlasPostfix);
            frame.ModelBackgroundOverlay:StopAnimating();
            frame.ModelBackgroundOverlay.animIn:Play();
        end
	end
end

local function GetDressingSource(mainHandEnchant, offHandEnchant)
    local buttons = DressingRoomOverlayFrame.buttons;
    local button, appliedSourceID, appearanceID, icon, hasMog, hyperlink, unformatedHyperlink, itemName, itemID, bonusID, sourceTextColorized, isIllusionCollected, illusionHyperlink;
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
            appliedSourceID, appearanceID, icon, hasMog, hyperlink, unformatedHyperlink, itemName, sourceTextColorized, itemID, bonusID = NarciBridge_GetDressUpModelSlotSource(slotID, enchantID);
            if illusionHyperlink then
                --hyperlink = illusionHyperlink;
            end     
            ItemList[slotID] = {itemName, sourceTextColorized, itemID, bonusID};
            newSet.items[slotID] = hyperlink;
            button = buttons[slotID];
            button.hyperlink = hyperlink;
            button.appearanceID = appearanceID;
            if icon then
                if appliedSourceID then
                    button.sourceID = appliedSourceID;
                end
                button.Icon:SetTexture(icon)
                if hasMog then
                    button.Icon:SetDesaturated(false);
                    button.Border:SetTexCoord(0.5, 1, 0, 1);
                    button.Black:Hide();
                    button.isHidden = false;
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

        --Favorite Star
        button.Star:SetShown(appearanceID and IsFavorite(appearanceID));
    end
end

local function DressingRoomOverlayFrame_OnLoad(self)
    self:SetParent(DressUpFrame);
    self:GetParent():SetMovable(true);
    self:GetParent():RegisterForDrag("LeftButton");
    self:GetParent():SetScript("OnDragStart", function(self)
        self:StartMoving();	
    end);
    self:GetParent():SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing();
    end);

    self.mode = "visual";
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
        if DressingRoomOverlayFrame.buttons[i] then
            DressingRoomOverlayFrame.buttons[i].isHidden = false;
        end
	end

	playerActor:TryOn(appearanceSources[mainHandSlotID], "MAINHANDSLOT", mainHandEnchant);
    playerActor:TryOn(appearanceSources[secondaryHandSlotID], "SECONDARYHANDSLOT", offHandEnchant);

    return mainHandEnchant, offHandEnchant
end

local includeItemID = false;
local function CopyTexts()
    local texts = "";
    if includeItemID then
        for k, v in pairs(ItemList) do
            if v[1] and v[1] ~= "" then
                texts = texts .. "|cFFFFD100"..SlotIDtoName[k][2]..":|r " .. v[1];
                if v[3] then
                    texts = texts .. " |cFF959595" .. v[3] .. "|r";
                end
                if v[2] and v[2] ~= "" then
                    texts = texts .. " |cFF40C7EB(" .. v[2] .. ")|r";
                end
                texts = texts .. "\n";
            end
        end
    else
        for k, v in pairs(ItemList) do
            if v[1] and v[1] ~= "" then
                texts = texts .. "|cFFFFD100"..SlotIDtoName[k][2]..":|r " .. v[1];
                if v[2] and v[2] ~= "" then
                    texts = texts .. " |cFF40C7EB(" .. v[2] .. ")|r"
                end
                texts = texts .. "\n"
            end
        end
    end

    NarciDressingRoom_GearTexts:SetText(strtrim(texts));
end


local function IsDressUpFrameMaximized()
    return (DressUpFrame.MaximizeMinimizeFrame and not DressUpFrame.MaximizeMinimizeFrame:IsMinimized())
end

local PanningYOffsetForCurrentActor

local function UpdateCameraPanningOffset()
    local ModelScene = DressUpFrame.ModelScene;
    local offsets = ModelScene.panningYOffset
    local panningYOffset;
    if IsDressUpFrameMaximized() then
        panningYOffset = PanningYOffsetForCurrentActor[1];
    else
        panningYOffset = PanningYOffsetForCurrentActor[2];
    end
    
    local camera = DressUpFrame.ModelScene:GetActiveCamera();
    if not camera then return end;

    camera.panningYOffset = panningYOffset;
    camera:SetTarget(0, 0, 2);
    camera:SnapAllInterpolatedValues()
end

local IsCurrentModelPlayer = false;

local function UpdateDressingRoomModel(unit)
    unit = unit or "player";
    local NarciBridge = DressingRoomOverlayFrame;
    if not UnitExists(unit) then
        return
    elseif not UnitIsPlayer(unit) or not CanInspect(unit, false) then
        NarciBridge.OptionFrame.TryOnButton:Disable();
        return
    else
        NarciBridge.OptionFrame.TryOnButton:Enable();
    end

    SetDressUpBackground(unit);
    local ModelScene = DressUpFrame.ModelScene;
    local actor = ModelScene:GetPlayerActor();
    if not actor then return; end;
    
    --Acquire target's gears
    NarciBridge:RegisterEvent("INSPECT_READY");
    NotifyInspect(unit);

    local _;
    _, _, UnitInfo.raceID = UnitRace(unit);
    UnitInfo.genderID = UnitSex(unit);
    _, _, UnitInfo.classID = UnitClass(unit);

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
        local modelInfo;
        modelInfo = GetActorInfoByUnit(modelUnit);
        if modelInfo then
            After(0.0,function()
                ModelScene:InitializeActor(actor, modelInfo);   --Re-scale
            end);
        end
    end

    --Update Unsheathed Animation
    --SetAnimationIDByUnit(unit);
end

local function RefreshFavoriteState(appearanceID)
    local buttons = DressingRoomOverlayFrame.buttons;
    local state;
    for slot, button in pairs(buttons) do
        if button.appearanceID and button.appearanceID == appearanceID then
            state = IsFavorite(button.appearanceID);
            button.Star:SetShown(state);
            local note = button:GetParent().Notification;
            note.fadeOut:Stop();
            note:ClearAllPoints();
            note:SetPoint("TOP", button, "BOTTOM", 0, 0);
            if state then
                note:SetText("|cffffe8a5"..L["Favorited"]);
            else
                note:SetText("|cffcccccc"..L["Unfavorited"]);
            end
            note.fadeOut:Play();

            if slot == 16 then
                local offHandSlot = buttons[17];
                if offHandSlot.appearanceID and offHandSlot.appearanceID == appearanceID then
                    offHandSlot.Star:SetShown(state);
                end
            end

            return
        end
    end
end

local function ResetHiddenSlot()
    --print("Load model...")
    for i = 1, 19 do
        if DressingRoomOverlayFrame.buttons[i] then
            DressingRoomOverlayFrame.buttons[i].isHidden = false;
            DressingRoomOverlayFrame.buttons[i].sourceID = nil;
        end
    end
end

function NarciBridge_UpdateCharacterButton_OnClick(self)
    UpdateDressingRoomModel()
end

local function NarciBridge_MogIt_SaveButton_OnClick(self)
    StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, newSet);    --Create a new whishlist
    MogIt.view:Show();  --Open a view window
end

local function CopyTextButton_OnClick(self)
    local GearTexts = NarciDressingRoom_GearTexts;
    if not GearTexts:IsShown() then
        CopyTexts();
        FadeFrame(GearTexts, 0.25, "IN");
        GearTexts:SetFocus();
    else
        NarciDressingRoom_GearTexts:HighlightText(0, 0);
        FadeFrame(GearTexts, 0.25, "OUT")
    end
end

local function SetButtonColor(button)
    if button.IsOn then
        button.Label:SetTextColor(0, 0, 0);
        button.Label:SetShadowColor(1, 1, 1);
        button.Background:SetColorTexture(0.88, 0.88, 0.88);
    else
        button.Label:SetTextColor(0.25, 0.78, 0.92);
        button.Label:SetShadowColor(0, 0, 0);
        button.Background:SetColorTexture(0.2, 0.2, 0.2);
    end
end

local function ItemIDButton_SetState(button)
    button.IsOn = NarcissusDB.DressingRoomIncludeItemID;
    includeItemID = button.IsOn;
    SetButtonColor(button);
end

local function ItemIDButton_OnClick(self)
    self.IsOn = not self.IsOn;
    includeItemID = self.IsOn;
    NarcissusDB.DressingRoomIncludeItemID = self.IsOn;
    SetButtonColor(self);
    CopyTexts();
    NarciDressingRoom_GearTexts:SetFocus();
end

local function TryOnButton_OnClick(self)
    local state = NarcissusDB.DressingRoomUseTargetModel;
    NarcissusDB.DressingRoomUseTargetModel = not state;
    UseTargetModel = not state;
    self.useTargetModel = not state;
    if not state then   --true
        self.Label:SetText(self.targetModelText);
    else
        self.Label:SetText(self.yourModelText);
    end
    UpdateDressingRoomModel("target");
end

local function GetWowHeadDressingRoomURL()
    local itemList = {};
    for k, v in pairs(ItemList) do
        itemList[k] = {v[3], v[4]};
    end
    return NarciAPI.EncodeItemlist(itemList, UnitInfo)
end

local function ExternalLinkButton_OnClick(self)
    local state = not self.Clipboard:IsShown();
    self.Clipboard:SetShown(state);
    if state then
        self.Clipboard:SetText(GetWowHeadDressingRoomURL());
        self.Clipboard:SetCursorPosition(26);     --should be at .com
        self.Clipboard:SetFocus();
    end
end

local function LinkEditBox_OnTextChanged(self, isUserInput)
    if isUserInput then
        self:Hide();
    end
end

local function LinkEditBox_OnKeyDown(self, key)
    local keys = CreateKeyChordStringUsingMetaKeyState(key);
    if keys == "CTRL-C" or key == "COMMAND-C" then
        self.hasCopied = true;
        After(0.1, function()
            --Texts won't be copied if hide immediately
            self:Hide();
        end);
    end
end

function Narci_UpdateDressingRoom()
    local frame = DressingRoomOverlayFrame;
    if not frame then return end;
    
    frame.mode = "visual";

    if not frame.pauseUpdate then
        frame.pauseUpdate = true;
        After(0, function()
            if SlotFrameVisibility and IsDressUpFrameMaximized() then
                frame.SlotFrame:Show();
                frame.OptionFrame:Show();
                GetDressingSource(frame.mainHandEnchant, frame.offHandEnchant);
                if NarciDressingRoom_GearTexts:IsShown() then
                    CopyTexts();
                end
            end
            frame.pauseUpdate = nil;
        end)
    end
end

local Narci_UpdateDressingRoom = Narci_UpdateDressingRoom;

function Narci_ShowDressingRoom()
    local frame = DressUpFrame;
    --derivated from Blizzard DressUpFrames.lua / DressUpFrame_Show
    if ( not frame:IsShown() or frame.mode ~= "player") then
		frame.mode = "player";
		frame.ResetButton:SetShown(true);
        frame.MaximizeMinimizeFrame:Maximize(true);
        if InCombatLockdown() then
            frame:Show();
            DressingRoomOverlayFrame:ListenEscapeKey(true);
        else
            ShowUIPanel(frame);
        end
		frame.ModelScene:ClearScene();
		frame.ModelScene:SetViewInsets(0, 0, 0, 0);
		frame.ModelScene:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
		
		local sheatheWeapons = false;
		local autoDress = true;
		local itemModifiedAppearanceIDs = nil;
        SetupPlayerForModelScene(frame.ModelScene, itemModifiedAppearanceIDs, sheatheWeapons, autoDress);
        Narci_UpdateDressingRoom();
	end
end

local function DressingRoomOverlayFrame_Initialize()
    if not (NarcissusDB and NarcissusDB.DressingRoom) then return; end;
    
    local parentFrame = DressUpFrame;
    if not parentFrame then 
        print("Narcissus failed to initialize Advanced Dressing Room");
        return;
    end

    local frame = CreateFrame("Frame", "DressingRoomOverlayFrame", parentFrame, "Narci_DressingRoomOverlay")
    CreateSlotButton(frame)
    DressingRoomOverlayFrame_OnLoad(frame);

    local texName = parentFrame:GetName() and parentFrame:GetName().."BackgroundOverlay"
    local tex = parentFrame:CreateTexture(texName, "BACKGROUND", "NarciDressingRoomBackgroundTemplate", 2)

    local ReScaleFrame = parentFrame.MaximizeMinimizeFrame;
    
    if ReScaleFrame then
        local function OnMaximize(frame)
            frame:GetParent():SetSize(OVERRIDE_WIDTH, OVERRIDE_HEIGHT);   --Override DressUpFrame Resize Mixin
            UpdateUIPanelPositions(frame);
        end
        ReScaleFrame:SetOnMaximizedCallback(OnMaximize);
    end

    hooksecurefunc("DressUpVisual", Narci_UpdateDressingRoom);
    
    --[[
    local prefix = "www";
    local language = GetLocale();

    if language == "zhCN" or language == "zhTW" then
        prefix = "cn";
    elseif language == "deDE" then
        prefix = "de";
    elseif language == "esES" or language == "esMX" then
        prefix = "es";
    elseif language == "frFR" then
        prefix = "fr";
    elseif language == "itIT" then
        prefix = "it";
    elseif language == "ptBR" then
        prefix = "pt";
    elseif language == "ruRU" then
        prefix = "ru";
    elseif language == "koKR" then
        prefix = "ko";
    end

    local WOWHEAD_DOMAIN = string.format("https://%s.wowhead.com/", prefix)
    --]]

    local function SetDressingRoomMode(mode, link)
        local frame = DressingRoomOverlayFrame;
        if frame then
            frame.mode = mode;
            --frame.link = link;
            frame.SlotFrame:Hide();
            frame.OptionFrame:Hide();
        end
    end
    
    hooksecurefunc("DressUpMountLink", function(link)
        --[[
        if link then
            local _, _, _, linkType, linkID = strsplit(":|H", link);
            if linkType == "item" or linkType == "spell" then
                link = WOWHEAD_DOMAIN .. linkType .. "=" .. linkID;
            end
        end       
        SetDressingRoomMode("mount", link);
        --]]
        SetDressingRoomMode("mount");
    end)
    
    hooksecurefunc("DressUpBattlePet", function(creatureID)
        --SetDressingRoomMode("battlePet",  WOWHEAD_DOMAIN .. "npc=" .. creatureID);
        SetDressingRoomMode("battlePet");
    end)

    frame.OptionFrame.CopyButton:SetScript("OnClick", CopyTextButton_OnClick);
    frame.OptionFrame.TryOnButton:SetScript("OnClick", TryOnButton_OnClick);
    frame.OptionFrame.ExternalLinkButton:SetScript("OnClick", ExternalLinkButton_OnClick);
    frame.OptionFrame.ExternalLinkButton.Clipboard:SetScript("OnTextChanged", LinkEditBox_OnTextChanged);
    frame.OptionFrame.ExternalLinkButton.Clipboard:SetScript("OnKeyDown", LinkEditBox_OnKeyDown);
    
    local ItemIDButton = frame.OptionFrame.GearTexts.IncludeID;
    ItemIDButton_SetState(ItemIDButton);
    ItemIDButton:SetScript("OnClick", ItemIDButton_OnClick);


    local minZoom, maxZoom, mediumZoom, lastYaw;
    DressUpFrame.ModelScene:HookScript("OnMouseDown", function(self, button)
        if button == "MiddleButton" then
            local camera = self:GetActiveCamera();
            if not camera then return end;
            minZoom = camera:GetMinZoomDistance() or 2;
            maxZoom = camera:GetMaxZoomDistance() or 4;
            mediumZoom = (minZoom + maxZoom) /2 *0.8;
            if camera:GetZoomDistance() > mediumZoom then
                lastYaw = camera:GetYaw();
                local n = floor(lastYaw / 2 /PI);
                self.lastYaw = lastYaw;
                camera:SetZoomDistance(minZoom);
                --camera:SetYaw(4*PI/6 + n* 2*PI);
            else
                camera:SetZoomDistance(maxZoom);
                --camera:SetYaw(self.lastYaw or 3*PI/6);
            end
        elseif (button == "LeftButton" and IsMouseButtonDown("RightButton")) or (button == "RightButton" and IsMouseButtonDown("LeftButton")) then
            self:Reset();
        end
    end)

    if DressUpFrame.ResetButton then
        DressUpFrame.ResetButton:HookScript("OnClick", function(self)
            UpdateDressingRoomModel("player");
        end)
    end
end


local initialize = CreateFrame("Frame")
initialize:RegisterEvent("ADDON_LOADED");
initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
initialize:RegisterEvent("UI_SCALE_CHANGED");
initialize:SetScript("OnEvent",function(self,event,...)
    if event == "ADDON_LOADED" then
        local name = ...;
        if name == "Narcissus" then
            self:UnregisterEvent("ADDON_LOADED");
            DressingRoomOverlayFrame_Initialize();
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        UseTargetModel = NarcissusDB.DressingRoomUseTargetModel;
        local _;
        _, PanningYOffsetForCurrentActor = GetActorInfoByUnit("player");

        if not DressingRoomOverlayFrame then
            self:UnregisterAllEvents();
            return
        end

        local TryOnButton = DressingRoomOverlayFrame.OptionFrame.TryOnButton;
        TryOnButton:SetScript("OnClick", TryOnButton_OnClick);
        if UseTargetModel then   --true
            TryOnButton.Label:SetText(L["Use Target Model"]);
            TryOnButton.useTargetModel = true;
        else
            TryOnButton.Label:SetText(L["Use Your Model"]);
            TryOnButton.useTargetModel = false;
        end

        if IsAddOnLoaded("MogIt") and MogIt then                         --Mogit: Add Save as Mogit wishlist
            local button = NarciBridge_SaveToMogItButton;
            button:Show();
            button:SetHeight(36);
            button:SetScript("OnClick", NarciBridge_MogIt_SaveButton_OnClick);
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        else
            NarciBridge_ItemListButton:SetPoint("BOTTOMLEFT", 4, 0);
        end

        if IsAddOnLoaded("DressUp") or IsAddOnLoaded("BetterWardrobe") then                                --DressUp: Hide our dressing room slot frame
            DressingRoomOverlayFrame.SlotFrame:Hide();
            SlotFrameVisibility = false;
        end
    elseif event == "UI_SCALE_CHANGED" then
        After(0.5, function()
            OVERRIDE_HEIGHT = math.floor(GetScreenHeight()*0.8 + 0.5);
            OVERRIDE_WIDTH = math.floor(WIDTH_HEIGHT_RATIO * OVERRIDE_HEIGHT + 0.5);
            if IsDressUpFrameMaximized() then
                DressUpFrame:SetSize(OVERRIDE_WIDTH, OVERRIDE_HEIGHT)
            end
        end)
    end
end);


--Item Button--
NarciDressingRoomItemButtonMixin = {};
local numDragThrough = 0;
local hideAll = false;
local isMouseDown = false;
local sharedActor;

function NarciDressingRoomItemButtonMixin:OnLoad()
    self:RegisterForClicks("RightButtonUp");
    self:RegisterForDrag("LeftButton");
    self.isHidden = false;
end
function NarciDressingRoomItemButtonMixin:OnEnter()
    if not isMouseDown then
        GameTooltip:SetOwner(self, "ANCHOR_NONE");
        GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 1);
        if (self.hyperlink) then
            GameTooltip:SetHyperlink(self.hyperlink);
            GameTooltip:Show();
        end
    else
        if (not sharedActor) then
            return
        end
        numDragThrough = numDragThrough + 1;
        if hideAll then
            sharedActor:UndressSlot(self:GetID());
            self.Icon:SetDesaturated(true);
        elseif self.sourceID then
            sharedActor:TryOn(self.sourceID);
            self.Icon:SetDesaturated(false);
        end
        self.isHidden = hideAll;
    end
end

function NarciDressingRoomItemButtonMixin:OnLeave()
    GameTooltip:Hide();
end

function NarciDressingRoomItemButtonMixin:OnMouseDown(button)
    if button == "LeftButton" then
        GameTooltip:Hide();
        self.isHidden = not self.isHidden;
        sharedActor = DressUpFrame.ModelScene:GetPlayerActor();
        if (not sharedActor) then
            return
        end
        
        if self.isHidden then
            sharedActor:UndressSlot(self:GetID());
            self.Icon:SetDesaturated(true);
        elseif self.sourceID then
            --print(self.sourceID)
            sharedActor:TryOn(self.sourceID);
            self.Icon:SetDesaturated(false);
        end
    end
end

function NarciDressingRoomItemButtonMixin:OnClick(button)
    if button == "RightButton" then
        if self.sourceID then
            if not self.appearanceID then return end

            local state;
            if IsFavorite(self.appearanceID) then
                --Remove from favorite
                state = false;
            else
                state = true;
                PlaySound(39672, "SFX");
            end
            C_TransmogCollection.SetIsAppearanceFavorite(self.appearanceID, state);
            --print("appearanceID: ".. (self.appearanceID or "") );
            --print("sourceID: ".. (self.sourceID or "") );
        end
    end
end

function NarciDressingRoomItemButtonMixin:OnDragStart()
    isMouseDown = true;
    hideAll = self.isHidden;
    After(0.2, function()
        if numDragThrough >= 5 and sharedActor then
            local buttons = DressingRoomOverlayFrame.buttons;
            local button;
            for k, v in pairs(buttons) do
                button = v;
                if hideAll then
                    sharedActor:UndressSlot(k);
                    button.Icon:SetDesaturated(true);
                elseif button.sourceID then
                    sharedActor:TryOn(button.sourceID);
                    button.Icon:SetDesaturated(false);
                end
                self.isHidden = hideAll;
            end
            After(0, function()
                GetDressingSource();
                if NarciDressingRoom_GearTexts:IsShown() then
                    CopyTexts();
                end
            end);
        end
        numDragThrough = 0;
    end)
end

function NarciDressingRoomItemButtonMixin:OnDragStop()
    isMouseDown = false;
end



NarciDressingRoomOverlayMixin = {};

function NarciDressingRoomOverlayMixin:OnLoad()
    DressingRoomOverlayFrame = self;
end

function NarciDressingRoomOverlayMixin:OnShow()
    if self.mode ~= "visual" then return end;

    SetDressUpBackground("player", true);
    self:RegisterEvent("PLAYER_TARGET_CHANGED");
    self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");
    self:RegisterEvent("BARBER_SHOP_CLOSE");
    After(0, function()
        GetDressingSource();
    end)
end

function NarciDressingRoomOverlayMixin:ListenEscapeKey(state)
    if state then
        self:SetScript("OnKeyDown", function(frame, key, down)
            if key == "ESCAPE" then
                DressUpFrame:Hide();
            end
        end)
    else
        self:SetScript("OnKeyDown", nil);
    end
end

function NarciDressingRoomOverlayMixin:OnHide()
    self:UnregisterEvent("PLAYER_TARGET_CHANGED");
    self:UnregisterEvent("TRANSMOG_COLLECTION_UPDATED");
    self:UnregisterEvent("INSPECT_READY");
    self.isActorHooked = false;
    self:ListenEscapeKey(false);
end

function NarciDressingRoomOverlayMixin:OnEvent(event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateDressingRoomModel("target");
    elseif event == "TRANSMOG_COLLECTION_UPDATED" then
        local collectionIndex, modID, itemAppearanceID, reason = ...
        if reason == "favorite" and itemAppearanceID then
            RefreshFavoriteState(itemAppearanceID);
        end
    elseif event == "INSPECT_READY" then
        self:UnregisterEvent("INSPECT_READY")
        After(0,function()
            self.mainHandEnchant, self.offHandEnchant = DressUpSources(C_TransmogCollection.GetInspectSources());
            GetDressingSource(self.mainHandEnchant, self.offHandEnchant);
            if NarciDressingRoom_GearTexts:IsShown() then
                CopyTexts();
            end
            ClearInspectPlayer();
        end);
    end
end


function NarciDressingRoomOverlayMixin:OnSizeChanged(width, height)
    --print(width.." x "..height);
    if SlotFrameVisibility then
        if IsDressUpFrameMaximized() then
            self.SlotFrame:Show();
        else
            self.SlotFrame:Hide();
        end

        --UpdateCameraPanningOffset();
    else
        self.SlotFrame:Hide();
    end
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
/run DressingRoomOverlayFrame.SlotFrame:Hide();

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

function GetActorID(RaceName)
    --Run this when new playable race available
    local temp, tag;
    local match1 = RaceName.."-male";
    local match2 = RaceName.."-female";

    for i = 1, 1500 do
        temp = C_ModelInfo.GetModelSceneActorInfoByID(i)
        if temp and temp.scriptTag then
            tag = temp.scriptTag
            if tag == match1 or tag == match2 or tag == RaceName then
                print(i.." "..tag);
            end
        end
    end
end

hooksecurefunc("ChatFrame_DisplayUsageError", function(messageTag)
    print(messageTag)
end)
--]]

--[[
function ModelSceneActorMixin:OnModelLoaded()
    self:MarkScaleDirty();
    self:SetAlpha(0);
    After(0, function()
        if self:IsShown() then
            print("Loaded")
            UIFrameFadeIn(self, 0.2, 0, 1)
        end
    end)
end
--]]

--[[
WardrobeCollectionFrame.SetsCollectionFrame:Refresh()


local customSources = {};
local CustomSet = {
    ["description"] = "Custom",
    ["label"] = "This Is A Set Description",
    ["hiddenUntilCollected"] = false,
    ["setID"] = 1208001,
    ["expansionID"] = 9,
    ["limitedTimeSet"] = true,
    ["patchID"] = 90000,
    ["classMask"] = 3592,
    ["collected"] = true,
    ["uiOrder"] = 3592,
    ["favorite"] = false,
    ["name"] = "Custom Name",
}

local GetSetInfo = C_TransmogSets.GetSetInfo;
local GetBaseSets = C_TransmogSets.GetBaseSets;
local GetVariantSets = C_TransmogSets.GetVariantSets;
local GetBaseSetID = C_TransmogSets.GetBaseSetID;
local GetSetSources = C_TransmogSets.GetSetSources;
local GetSourcesForSlot = C_TransmogSets.GetSourcesForSlot;
local IsBaseSetCollected = C_TransmogSets.IsBaseSetCollected;

local function IsSourceCollected(sourceID)
    return C_TransmogCollection.GetSourceInfo(sourceID) or false
end

function C_TransmogSets.GetSetInfo(setID)
    if setID < 10000 then
        return GetSetInfo(setID)
    else
        return CustomSet
    end
end

function C_TransmogSets.GetVariantSets(setID)
    if setID < 10000 then
        return GetVariantSets(setID)
    else
        return {}
    end
end

function C_TransmogSets.GetBaseSetID(setID)
    if setID < 10000 then
        return GetBaseSetID(setID)
    else
        return setID
    end
end

function C_TransmogSets.GetSetSources(setID)
    if setID < 10000 then
        return GetSetSources(setID)
    else
        local table = {}
        for k, v in pairs(customSources) do
            table[v] = IsSourceCollected(v);
        end

        return table
    end
end

function C_TransmogSets.GetSourcesForSlot(setID, slot)
    if setID < 10000 then
        return GetSourcesForSlot(setID, slot)
    else
        return {}
    end
end

function C_TransmogSets.IsBaseSetCollected(setID)
    if setID < 10000 then
        return IsBaseSetCollected(setID)
    else
        return true
    end
end

function C_TransmogSets.GetBaseSets()
    local Sets = GetBaseSets();
    if CustomSet and #customSources ~= 0 then
        tinsert(Sets, CustomSet);
    end
    return Sets
end


hooksecurefunc(C_TransmogCollection, "SaveOutfit", function(name, sourceIDTable, mainHandEnchant, offHandEnchant, icon)
    print(name);
    CustomSet.name = name;
    customSources = sourceIDTable;
    if WardrobeCollectionFrame then
        After(0, function()
            local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame;
            SetsCollectionFrame:Hide();
            SetsCollectionFrame:Show();
        end)
    end
end)

hooksecurefunc("DressUpSources", function(appearanceSources, mainHandEnchant, offHandEnchant)
    if not appearanceSources then
        return
    else
        After(0.1, function()
            GetDressingSource(mainHandEnchant, offHandEnchant);
        end)
    end
end)
--]]