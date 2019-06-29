
--[[
    -- Blizzard Dressing Room --
    Size:   450, 545

--]]
local GetTransmogItemInfo = C_TransmogCollection.GetItemInfo;
local GetTransmogSourceInfo = C_TransmogCollection.GetSourceInfo;
local GetAppearanceSources = C_TransmogCollection.GetAppearanceSources;     --(isCollected, sourceID, sourceType, visualID, itemID, itemModID)
local GetAppearanceSourceDrops = C_TransmogCollection.GetAppearanceSourceDrops;
local PlayerHasTransmog = C_TransmogCollection.PlayerHasTransmog;
local IsNewAppearance = C_TransmogCollection.IsNewAppearance;
local GetIllusionSourceInfo = C_TransmogCollection.GetIllusionSourceInfo;

local IsAppearanceKnown = NarciAPI_IsAppearanceKnown;
local FadeFrame = NarciAPI_FadeFrame;

local defaultWidth, defaultHeight = 450, 545;
local OverrideScale = 2;
local WidthHeitghtRatio = defaultWidth/defaultHeight;
local OverrideWidth, OverrideHeight = defaultWidth * OverrideScale, defaultHeight * OverrideScale;
local FrameAlpha_OnMoving = 0;
local buttonWidth, buttonGap = 54, 16;
local FirstButtonOffset = 0.5*(buttonWidth + buttonGap);
local ButtonOffsetY = 20;
local EmptySlotAlpha = 0.4;

OverrideHeight = math.floor(GetScreenHeight()*0.8 + 0.5);
OverrideWidth = math.floor(WidthHeitghtRatio * OverrideHeight + 0.5);

local XmogSlotTable = {
	[1] = {{5, INVTYPE_CHEST}, {15, INVTYPE_CLOAK}, {3, INVTYPE_SHOULDER}, {1, INVTYPE_HEAD}},		--Left 	**slotID for TABARD is 19
	[2] = {{7, INVTYPE_LEGS}, {8, INVTYPE_FEET}},								--Right
    [3] = {{16, INVTYPE_WEAPONMAINHAND}, {17, INVTYPE_WEAPONOFFHAND}},													--Weapon
    [4] = {{4, INVTYPE_BODY}, {19, INVTYPE_TABARD}},                                                                    --Shirt and Tabard
    ["Manual"] = {{10, INVTYPE_HAND}, {6, INVTYPE_WAIST}, {9, INVTYPE_WRIST}},                                          --Manually Created
};

local SlotIDtoName = {
    [1] = {"HeadSlot", INVTYPE_HEAD},
    [3] = {"ShoulderSlot", INVTYPE_SHOULDER},
    [4] = {"ShirtSlot", INVTYPE_BODY},
    [5] = {"ChestSlot", INVTYPE_CHEST},
    [6] = {"WaistSlot", INVTYPE_WAIST},
    [7] = {"LegsSlot", INVTYPE_LEGS},
    [8] = {"FeetSlot", INVTYPE_FEET},
    [9] = {"WristSlot", INVTYPE_WRIST},
    [10]= {"HandsSlot", INVTYPE_HAND},
    [15]= {"BackSlot", INVTYPE_CLOAK},
    [16]= {"MainHandSlot", INVTYPE_WEAPONMAINHAND},
    [17]= {"SecondaryHandSlot", INVTYPE_WEAPONOFFHAND},
    [19]= {"TabardSlot", INVTYPE_TABARD},
}

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
    local appliedSourceID, illusionSourceID = DressUpModel:GetSlotTransmogSources(slotID)
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
        AppearnceSources = GetAppearanceSources(appearanceID)
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
    return itemIcon, (hasMog or hasAppearance), hyperlink, unformatedHyperlink, itemName, sourceTextColorized;
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

local function GetTargetSource(mainHandEnchant, offHandEnchant)
    local buttons = NarciBridge_DressUpFrame.buttons;
    local button, icon, hasMog, hyperlink, unformatedHyperlink, isIllusionCollected, illusionHyperlink;
    local enchantID;
    wipe(newSet.items)
    wipe(ItemList)
    for slotID, v in pairs(SlotIDtoName) do
        if slotID == 16 then
            enchantID = mainHandEnchant or "";
        elseif slotID == 17 then
            enchantID = offHandEnchant or "";
        else
            enchantID = "";
        end
        icon, hasMog, hyperlink, unformatedHyperlink, itemName, sourceTextColorized = NarciBridge_GetDressUpModelSlotSource(slotID, enchantID);
        if illusionHyperlink then
            --hyperlink = illusionHyperlink;
        end     
        ItemList[slotID] = {itemName, sourceTextColorized};
        newSet.items[slotID] = hyperlink;
        button = buttons[slotID];
        button.hyperlink = hyperlink;
        if icon then
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
            button:SetAlpha(EmptySlotAlpha);
            button.Icon:Hide();
            button.Border:SetTexCoord(0, 0.5, 0, 1);
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
    DressUpModel:Undress()
	local mainHandSlotID = 16   --GetInventorySlotInfo("MAINHANDSLOT");
	local secondaryHandSlotID = 17  --GetInventorySlotInfo("SECONDARYHANDSLOT");
	for i = 1, #appearanceSources do
		if ( i ~= mainHandSlotID and i ~= secondaryHandSlotID ) then
			if ( appearanceSources[i] and appearanceSources[i] ~= NO_TRANSMOG_SOURCE_ID ) then
				DressUpModel:TryOn(appearanceSources[i]);
			end
		end
	end

	DressUpModel:TryOn(appearanceSources[mainHandSlotID], "MAINHANDSLOT", mainHandEnchant);
    DressUpModel:TryOn(appearanceSources[secondaryHandSlotID], "SECONDARYHANDSLOT", offHandEnchant);

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
    GearTexts:SetText(strtrim(texts))
end

local function UpdateDressingRoomModel(self, unit)
    unit = unit or "player"
    if not UnitExists(unit) or not UnitIsPlayer(unit) or not CanInspect(unit, false) then return; end
    local className, classFileName = UnitClass(unit);
    SetDressUpBackground(DressUpFrame, classFileName);
    self:GetParent().DressUpModel:SetUnit(unit)
    NotifyInspect(unit);
    local mainHandEnchant, offHandEnchant;
    C_Timer.After(0.1,function()
        mainHandEnchant, offHandEnchant = DressUpSources(C_TransmogCollection.GetInspectSources())
        ClearInspectPlayer();
    end);
    C_Timer.After(0.2,function()
        GetTargetSource(mainHandEnchant, offHandEnchant)
        if self.OptionFrame.GearTexts:IsShown() then
            CopyTexts(self.OptionFrame.GearTexts)
        end
    end);
end

local function NarciBridge_DressUpFrame_OnEvent(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateDressingRoomModel(self, "target")
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
    if GetCVar("miniDressUpFrame") == "0" then
        self.SlotFrame:Show();
    else
        self.SlotFrame:Hide();
    end
end

local function NarciBridge_DressUpFrame_OnShow(self)
    --self:GetParent():SetSize(OverrideWidth, OverrideHeight)
    self:RegisterEvent("PLAYER_TARGET_CHANGED");
    --self:RegisterEvent("PLAYER_STARTED_MOVING");
    --self:RegisterEvent("PLAYER_STOPPED_MOVING");
    --UpdateDressingRoomModel(self)
end

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

local function NarciBridge_DressUpFrame_Initialize()
    local parentFrame = DressUpFrame;
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

    parentFrame.DressUpModel:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 0.8, 1, 1, 1, 0.6, 0.8, 0.8, 0.8)

    local texName = parentFrame:GetName() and parentFrame:GetName().."BackgroundOverlay"
    local tex = parentFrame:CreateTexture(texName, "BACKGROUND", "ModelBackground_Template", 2)

    if MaximizeMinimizeFrame then
        local function OnMaximize(frame)
            frame:GetParent():SetSize(OverrideWidth, OverrideHeight);   --Override DressUpFrame Resize Mixin
            UpdateUIPanelPositions(frame);
        end

        MaximizeMinimizeFrame:SetOnMaximizedCallback(OnMaximize);
    end
end

local initialize = CreateFrame("Frame")
initialize:RegisterEvent("VARIABLES_LOADED");
initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
initialize:RegisterEvent("UI_SCALE_CHANGED");
initialize:SetScript("OnEvent",function(self,event,...)
    if event == "VARIABLES_LOADED" then
        NarciBridge_DressUpFrame_Initialize()
        self:UnregisterEvent("VARIABLES_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        if IsAddOnLoaded("MogIt") and MogIt then                         --Mogit
            local button = NarciBridge_SaveToMogItButton;
            button:Show();
            button:SetHeight(48);
            button:SetScript("OnClick", NarciBridge_MogIt_SaveButton_OnClick);
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
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

function NarciRectangularItemButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 1);
	if (self.hyperlink) then
		GameTooltip:SetHyperlink(self.hyperlink);
		GameTooltip:Show();
		return;
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
--]]

function NarciBridge_CopyTextButton_OnClick(self)
    CopyTexts(self)
    local GearTexts = self:GetParent().GearTexts;
    if not GearTexts:IsShown() then
        FadeFrame(GearTexts, 0.25, "IN")
    else
        FadeFrame(GearTexts, 0.25, "OUT")
    end
end