local VisualIDsByCategory = {};

local _G = _G;
local After = C_Timer.After;
local GetAppearanceSourceDrops = C_TransmogCollection.GetAppearanceSourceDrops;
local GetCategoryAppearances = C_TransmogCollection.GetCategoryAppearances;     --Return a list of visualID
local GetCategoryInfo = C_TransmogCollection.GetCategoryInfo;
local GetSourceInfo = C_TransmogCollection.GetSourceInfo;
local GetAppearanceSources = C_TransmogCollection.GetAppearanceSources;         --Input VisualID
local FadeFrame = NarciAPI_FadeFrame;
local UIFrameFadeIn = UIFrameFadeIn;

local max = math.max;
local min = math.min;
local cos = math.cos;
local sin = math.sin;
local sqrt = math.sqrt;
local ceil = math.ceil;
local floor = math.floor;
local pow = math.pow;
local abs = math.abs;
local pi = math.pi;

local function outSine(t, b, e, d)
	return (e - b) * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, e, d)
	return (b - e) / 2 * (cos(pi * t / d) - 1) + b
end

local function outQuart(t, b, e, d)
    t = t / d - 1
    return (b - e) * (pow(t, 4) - 1) + b
end

local activeActor;
local OutfitFrame, ModelScene;

local BLIZZ_BLUE = "40c7eb";
local GRAY_50 = "|cff757575";

local QUALITY_COLORS = {
    --Frigid Tune :P
    [0] = "808080",     --0.8
    [1] = "cccccc",     --0.8
    [2] = "5fbb46",     --Uncommon
    [3] = "3d85cc",     --Rare
    [4] = "8c6bb3",     --Epic
    [5] = "cd853d",     --Lengedary
    [6] = "ccb266",     --Artifact
    [7] = "3dadcc",     --Heirloom
};

for i, color in pairs(QUALITY_COLORS) do
    QUALITY_COLORS[i] = NarciAPI_ConvertHexColorToRGB(color);
end

------------------------------------------------------------------
------------------------------------------------------------------
local sort = table.sort;

local function SortFuncMixed(a, b)
    if ( a.isHideVisual ~= b.isHideVisual ) then
        return a.isHideVisual;
    end

    if a.isUsable and not b.isUsable then
        if b.isCollected then
            return true
        end
    elseif not a.isUsable and b.isUsable then
        if a.isCollected then
            return false
        end
    elseif not a.isUsable and not b.isUsable then
        if a.isCollected then
            if b.isCollected then
                if ( a.uiOrder and b.uiOrder ) then
                    return a.uiOrder > b.uiOrder;
                end
            else
                return false
            end
        elseif b.isCollected then
            return true
        end
    end
    
    if ( a.isFavorite ~= b.isFavorite ) then
        return a.isFavorite;
    end

    if ( a.hasActiveRequiredHoliday ~= b.hasActiveRequiredHoliday ) then
        return a.hasActiveRequiredHoliday;
    end
    if ( a.uiOrder and b.uiOrder ) then
        return a.uiOrder > b.uiOrder;
    end

    return a.visualID > b.visualID;
end

local function SortFuncCollectedFirst(a, b)
    if ( a.isCollected ~= b.isCollected ) then
        return a.isCollected;
    end
    
    if ( a.isUsable ~= b.isUsable ) then
        return a.isUsable;
    end

    if ( a.isHideVisual ~= b.isHideVisual ) then
        return a.isHideVisual;
    end
    
    if ( a.isFavorite ~= b.isFavorite ) then
        return a.isFavorite;
    end

    if ( a.hasActiveRequiredHoliday ~= b.hasActiveRequiredHoliday ) then
        return a.hasActiveRequiredHoliday;
    end
    if ( a.uiOrder and b.uiOrder ) then
        return a.uiOrder > b.uiOrder;
    end

    return a.visualID > b.visualID;
end

local function ChangeSortType(mode)
    local Create = Narci_ItemCollection;
    local subList = VisualIDsByCategory[Create.activeCategory];

    if mode == 1 then
        sort(subList, SortFuncMixed);
    elseif mode == 2 then
        sort(subList, SortFuncCollectedFirst);
    end

    After(0, function()
        Create:RefreshActiveCategory();
    end)
end


------------------------------------------------------------------
local UsableWeapons = {
    ["mainhand"] = {},
    ["offhand"] = {},
};


local sortType = {
    [1] = {"Mixed", ChangeSortType, 1}, 
    [2] = {"Collected First", ChangeSortType, 2},
};


local function AddSectorToDropdown(Dropdown, sectorName, buttonData)
    if not buttonData then return end
    Dropdown.numSector = Dropdown.numSector + 1;

    if not Dropdown.buttons then
        Dropdown.buttons = {};
    end

    local textWidth;
    local maxTextWidth = Dropdown.maxTextWidth;
    local buttons = Dropdown.buttons;

    Dropdown.numEffectiveButtons = Dropdown.numEffectiveButtons + 1;
    local categoryButton = buttons[ Dropdown.numEffectiveButtons ];
    if not categoryButton then
        categoryButton = CreateFrame("Button", nil, Dropdown, "NarciOutfitDropdownButtonTemplate");
        if Dropdown.numSector == 1 then
            categoryButton:SetPoint("TOPLEFT", Dropdown, "TOPLEFT", 0, 0);
            categoryButton:SetPoint("TOPRIGHT", Dropdown, "TOPRIGHT", 0, 0);
        else
            categoryButton:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT", 0, 0);
            categoryButton:SetPoint("TOPRIGHT", buttons[#buttons], "BOTTOMRIGHT", 0, 0);
        end
        tinsert(buttons, categoryButton);
    end
    categoryButton.Text:SetText(sectorName);
    categoryButton.func = nil;
    categoryButton.arg1 = nil;
    categoryButton:Disable();
    categoryButton:Show();

    textWidth = categoryButton.Text:GetWidth();
    if textWidth > maxTextWidth then
        maxTextWidth = textWidth;
    end


    local button;
    
    for i = 1, #buttonData do
        Dropdown.numEffectiveButtons = Dropdown.numEffectiveButtons + 1;
        button = buttons[ Dropdown.numEffectiveButtons ];
        if not button then
            button = CreateFrame("Button", nil, Dropdown, "NarciOutfitDropdownButtonTemplate");

            button:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT", 0, 0);
            button:SetPoint("TOPRIGHT", buttons[#buttons], "BOTTOMRIGHT", 0, 0);

            button:SetScript("OnClick", function(self)
                if self.func then
                    self.func(self.arg1);
                end
                self:GetParent().parentFrame.Text:SetText(self.Text:GetText());
                Dropdown:Hide();
            end);

            tinsert(buttons, button);
        end

        button:Show();
        button:Enable();
        button.Text:SetText( buttonData[i][1] );
        button.func = buttonData[i][2];
        button.arg1 = buttonData[i][3];

        textWidth = button.Text:GetWidth();
        if textWidth > maxTextWidth then
            maxTextWidth = textWidth;
        end
    end

    Dropdown.maxTextWidth = maxTextWidth;

    if not Dropdown.sectors then
        Dropdown.sectors = {};
    end
    
    local sector = Dropdown.sectors[Dropdown.numSector];
    if not sector then
        sector = CreateFrame("Frame", nil, Dropdown, "NarciOuftiDropdownMenuSectorTemplate");
        tinsert(Dropdown.sectors, sector);
    end

    sector:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0);
    sector:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
    sector:Show();
    sector:SetFrameLevel(button:GetFrameLevel());
    sector:SetHeight(#buttonData * 18);
end

local function CreateDropdownMenu(isWeapon, isOffHand)
    local parentFrame = Narci_ItemCollection.Filter;
    local START_OFFSET_Y = -8;

    local weaponType;
    if isWeapon then
        if isOffHand then
            weaponType = UsableWeapons.offhand;
            print("Off Hand")
        else
            weaponType = UsableWeapons.mainhand;
            print("Main Hand")
        end
    end

    local sortType = sortType;


    local Dropdown = parentFrame.Dropdown;
    if not Dropdown then
        Dropdown = CreateFrame("Frame", nil, parentFrame, "NarciOutfitDropdownMenuTemplate");
        Dropdown:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 0, START_OFFSET_Y);
        Dropdown.parentFrame = parentFrame;
        parentFrame.Dropdown = Dropdown;
        Dropdown.onShowFunc = function()
            parentFrame.Arrow:SetTexCoord(0, 0.25, 0.5, 0.25);
        end
        Dropdown.onHideFunc = function()
            parentFrame.Arrow:SetTexCoord(0, 0.25, 0.25, 0.5);
        end
    end


    --Add sectors
    Dropdown.numEffectiveButtons = 0;
    Dropdown.numSector = 0;
    Dropdown.maxTextWidth = 0;

    AddSectorToDropdown(Dropdown, "Type", weaponType);
    AddSectorToDropdown(Dropdown, "Sort", sortType);

    for i = Dropdown.numEffectiveButtons + 1, #Dropdown.buttons do
        Dropdown.buttons[i]:Hide();
    end

    for i = Dropdown.numSector + 1, #Dropdown.sectors do
        Dropdown.sectors[i]:Hide();
    end

    local width = parentFrame:GetWidth();
    local height = Dropdown.numEffectiveButtons * 18;
    Dropdown:SetDropdownSize( max(width, Dropdown.maxTextWidth + 16) , height);

    Dropdown:Hide();
end



------------------------------------------------------------------
local sourceTemp;
local visualSourceTemp;
local DataProvider = {};
DataProvider.sourceCache = {};    --Cache Constants: --[sourceID] = {name, quality, visualID, sourceType, itemID, itemModID}   --Variable isCollected
DataProvider.visualSourceCache = {};    --{[visualID] = { [1] = sourceID1, [2] = sourceID2, [selectedSourceIndex] = 1}

function DataProvider:GetSourceInfo(sourceID, key)
    if not sourceID or sourceID == 0 then
        if key then
            return -1
        else
            return {}
        end
    end

    if self.sourceCache[sourceID] then
        --print("Source #"..sourceID.." is using cache.");
        if key then
            return self.sourceCache[sourceID][key]
        else
            return self.sourceCache[sourceID]
        end
    else
        sourceTemp = GetSourceInfo(sourceID);
        if sourceTemp.name and sourceTemp.sourceType and sourceTemp.quality then
            self.sourceCache[sourceID] = sourceTemp;
        end
        if key then
            return sourceTemp[key]
        else
            return sourceTemp
        end
    end
end

function DataProvider:IsVisualCollected(visualID)
    if not visualID then return end

    local info = self.visualSourceCache[visualID];
    if info then
        return info.isCollected
    else
        return select( 4, self:GetAppearanceSourceID(visualID))
    end
end

function DataProvider:IsSourceCollected(sourceID)
    sourceTemp = self:GetSourceInfo(sourceID);
    return sourceTemp.isCollected;
end

function DataProvider:IsSourceVisualCollected(sourceID)
    --sourceID → visualID (which leads to multiple sourceID)
    return sourceID and self:IsVisualCollected( self:GetSourceInfo(sourceID).visualID )
end

function DataProvider:GetAppearanceSourceID(visualID, index)
    local info = self.visualSourceCache[visualID];
    if info then
        if index then
            info.selectedSourceIndex = index;
        end
        --print("Visual #"..visualID.." is using cache.");
        return info[info.selectedSourceIndex], info.selectedSourceIndex, #info, info.isCollected
    else
        visualSourceTemp = GetAppearanceSources(visualID);
        if visualSourceTemp then
            self.visualSourceCache[visualID] = {};
            info = self.visualSourceCache[visualID];

            local sourceID;
            local outputID;
            local isCollected = false;
            --print("numSources: "..#visualSourceTemp);

            for i = 1, #visualSourceTemp do
                sourceID = visualSourceTemp[i].sourceID;
                tinsert(info, sourceID);
                self:GetSourceInfo(sourceID);
                if visualSourceTemp[i].isCollected then
                    info.selectedSourceIndex = info.selectedSourceIndex or i;
                    isCollected = true;
                end
            end

            if not info.selectedSourceIndex then
                info.selectedSourceIndex = 1;
            end
            info.isCollected = isCollected;

            return info[info.selectedSourceIndex], info.selectedSourceIndex, #visualSourceTemp, isCollected
        end
    end
end

function DataProvider:GetSourceText(sourceType, sourceID, itemModID, showEncounter)
    if sourceType then
        if sourceType == 1 then
            --Boss Drop
            local drops = GetAppearanceSourceDrops(sourceID);
            if drops and drops[1] then
                local instance = drops[1].instance;
                local difficulty;
                if itemModID == 0 then
                    difficulty = PLAYER_DIFFICULTY1;    --N
                elseif itemModID == 1 then
                    difficulty = PLAYER_DIFFICULTY2;    --H
                elseif itemModID == 3 then
                    difficulty = PLAYER_DIFFICULTY6;    --M
                elseif itemModID == 4 then
                    difficulty = PLAYER_DIFFICULTY3;    --LFR
                end
                
                if difficulty then
                    if showEncounter then
                        local encounter = drops[1].encounter or "";
                        return encounter.."  |cffe6cc80"..difficulty.."|r  "..instance
                    else
                        return difficulty.."|cff808080 | |r"..instance
                    end
                else
                    return instance
                end
            else
                return _G["TRANSMOG_SOURCE_1"]
            end
        else
            return _G["TRANSMOG_SOURCE_"..sourceType]
        end
    end
end

function DataProvider:GetUnusableReason(visualID)
    if not visualID then return end

    self.sources = GetAppearanceSources(visualID);
    if self.sources and self.sources[1] then
        return self.sources[1].useError
    end
end

function DataProvider:ClearCache()
    wipe(self.sourceCache);
    wipe(self.visualSourceCache);
end

------------------------------------------------------------------
local Model_ApplyUICamera = Model_ApplyUICamera;
local GetAppearanceCameraIDByVisual = C_TransmogCollection.GetAppearanceCameraID;
local GetAppearanceCameraIDBySource = C_TransmogCollection.GetAppearanceCameraIDBySource;
local GetSourceIcon = C_TransmogCollection.GetSourceIcon
 
local SLOT_INFO = {
    --[order] = {slotID, representative sourceID, categoryID, narciCameraIndex, isWeapon}
    --categoryID = -1   reserved for weapon types
    --Order: → ↓
    [1] = {1, 77344, 1, 1},     --Head
    [2] = {3, 77343, 2, 1 },     --Shoulders
    [3] = {5, 104602, 4, 1 },     --Chest
    [4] = {7, 105553, 10, 3 },    --Legs
    [5] = {15, 77345, 3, 4 },    --Back
    [6] = {10, 94331, 8, 1 },    --Hands
    [7] = {6, 84223, 9, 1 },     --Waist
    [8] = {8, 104603, 11, 2 },    --Feet
    [9] = {9, 104604, 7, 1 },     --Wrist
    [11]= {16, 471, 14, 1, true },   --Main-hand    --Bow 25
    [12]= {17, 471, -1, 1, true },   --Off-hand
    [13]= {4, 83202, 5, 1 },     --Shirt
    [14]= {19, 83203, 6, 1 },    --Tabard
};

function DataProvider:QueryCameraID(slotButton)
    if not self.slotButtonQueue then
        self.slotButtonQueue = {};
    end

    if slotButton then
        local isNew = true;
        for i = 1, #self.slotButtonQueue do
            isNew = isNew and not( slotButton == self.slotButtonQueue[i] );
        end
        if isNew then
            tinsert(self.slotButtonQueue, slotButton);
        end
    end

    if not self.isProcessing then
        self.isProcessing = true;

        After(0.5, function()
            local recursive = false;
            for i = 1, #self.slotButtonQueue do
                local button = self.slotButtonQueue[i];
                if button then
                    local cameraID = GetAppearanceCameraIDBySource( SLOT_INFO[ button.order ][2] );
                    if cameraID and cameraID ~= 0 then
                        self.slotButtonQueue[i] = nil;
                        button.defaultCameraID = cameraID;
                        --print("CameraID: "..cameraID)
                    else
                        recursive = true
                    end
                end
            end
            
            self.isProcessing = nil;
            if recursive then
                self:QueryCameraID();
            end
        end)
    end
    
end

local lightValues = { enabled=true, omni=false, dirX=-1, dirY=1, dirZ=-1, ambIntensity=1.0, ambR=1, ambG=1, ambB=1, dirIntensity=0, dirR=1, dirG=1, dirB=1 };
local lightValues2 = { enabled=true, omni=false, dirX=-1, dirY=1, dirZ=-1, ambIntensity=1.0, ambR=1, ambG=1, ambB=1, dirIntensity=1, dirR=1, dirG=1, dirB=1 };

local MouseOverTimer = NarciAPI_CreateAnimationFrame(0.12);
MouseOverTimer:SetScript("OnUpdate", function(self, elpased)
    self.total = self.total + elpased;
    if self.total > self.duration then
        self:Hide();
        local frame = GetMouseFocus();
        if frame and frame == self.frame then
            OutfitFrame:GoToCamera(self.arg1);
        end
    end
end)

local function MouseOverDelay(frame, arg1)
    MouseOverTimer.total = 0;
    MouseOverTimer.frame = frame;
    MouseOverTimer.arg1 = arg1;
    MouseOverTimer:Show();
end

-------------------------------------------------------------
local WeaponButtonMixin = {};

function WeaponButtonMixin:SetSheatheAnimationByCategoryID(categoryID)
    if categoryID <= 17 or categoryID == 19 then
        self.animationID = 90;      --Hip
        print("Hip")
    else
        self.animationID = 89;      --Back
        print("Back")
    end
end

function WeaponButtonMixin:ChangeSheathed()
    if not activeActor then return end;

    local mainHandSource, offHandSource = activeActor:GetSlotTransmogSources(16), activeActor:GetSlotTransmogSources(17);
    if mainHandSource == 0 and offHandSource == 0 then
        return
    else

    end

    if not self.inTransition then
        self.inTransition = true;

        local isSheathed = not activeActor:GetSheathed();

        if isSheathed then
            self.button.Icon:SetTexCoord(0.75, 1, 0.25, 0.5);
            self.button.Label:SetText("Draw Weapon (Z)");
        else
            self.button.Icon:SetTexCoord(0.5, 0.75, 0.25, 0.5);
            self.button.Label:SetText("Sheathe Weapon (Z)");
        end

        --animation
        local animation, variation, speed = activeActor:GetAnimationData();
        activeActor:SetAnimationData(self.animationID, 0, 1);
        After(0.5, function()
            activeActor:SetSheathed(isSheathed);
            After(0.5, function()
                activeActor:SetAnimationData(animation, variation, speed);
                self.inTransition = nil;
            end)
        end)
    end
end



NarciOutfitItemModelMixin = {};

function NarciOutfitItemModelMixin:OnLoad()
    --Texture
    self.Star:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/OutfitIcons", nil, nil, "TRILINEAR");
    self.Status:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/OutfitIcons", nil, nil, "TRILINEAR");

    --Model
    self.needRefresh = true;
    self:SetUseTransmogSkin(true);  --not self.usePlayerSkin
    self:SetAutoDress(false);
    self:SetKeepModelOnHide(true);
    self:SetDoBlend(false);
    self:Undress();
	self:SetLight(lightValues.enabled, lightValues.omni,
			lightValues.dirX, lightValues.dirY, lightValues.dirZ,
			lightValues.ambIntensity, lightValues.ambR, lightValues.ambG, lightValues.ambB,
            lightValues.dirIntensity, lightValues.dirR, lightValues.dirG, lightValues.dirB);
    self:FreezeAnimation(0, 0, 0);

    --Animation Frame
    local animLight = NarciAPI_CreateAnimationFrame(0.25);
    animLight:SetScript("OnUpdate", function(frame, elpased)
        frame.total = frame.total + elpased;
        local intensity = inOutSine(frame.total, frame.fromIntensity, frame.toIntensity, frame.duration);
        if frame.total >= frame.duration then
            intensity = frame.toIntensity;
            frame:Hide();
        end

        self:SetLight(true, false, -1, 1, -1, 1, 1, 1, 1, intensity, 1, 1, 1);
    end);

    self.animLight = animLight;
end

function NarciOutfitItemModelMixin:RefreshSlot()
    if self.sourceID then
        self:TryOn(self.sourceID);
    else
        self:Undress();
    end
end

function NarciOutfitItemModelMixin:ForceReset()
    self:SetUnit("player", false);
    self:RefreshSlot();
    local cameraID = GetAppearanceCameraIDBySource(self.sourceID or self.cameraReferenceSourceID or 0);
    if cameraID ~= self.cameraID then
        self.cameraID = cameraID;
        self:RefreshCamera();
        Model_ApplyUICamera(self, cameraID);
    end
end

function NarciOutfitItemModelMixin:Blacken(useTransmogSkin)
    self:SetUseTransmogSkin(useTransmogSkin);
    self:RefreshUnit();
end

function NarciOutfitItemModelMixin:DressUpSources(sources, ignoredSlotID)
    self:Undress();
    for slotID, source in pairs(sources) do
        if slotID ~= ignoredSlotID then
            self:TryOn(source);
        end
    end
end

function NarciOutfitItemModelMixin:OnModelLoaded()
    local id = self.cameraID or self.defaultCameraID;
    if id then
        self:RefreshCamera();
        Model_ApplyUICamera(self, id);
	end
end

function NarciOutfitItemModelMixin:OnShow()
    if self.needRefresh then
        self.needRefresh = nil;
        if not self.isWeapon then
            self:SetUnit("player", false);
            self:RefreshSlot();
        end
    end
end

local HighlightBorder;

function NarciOutfitItemModelMixin:OnEnter()
    UIFrameFadeIn(self.Highlight, 0.25, self.Highlight:GetAlpha(), 1);
    self.animLight:Hide();
    local _;
    _, _, _, _, _, _, _, _, _, self.animLight.fromIntensity = self:GetLight();
    self.animLight.toIntensity = 1;
    self.animLight:Show();
    --self:SetCameraDistance(0.98 * self:GetCameraDistance());

    HighlightBorder:SetPoint("CENTER", self, "CENTER", 0, 0);
    UIFrameFadeIn(HighlightBorder, 0.25, HighlightBorder:GetAlpha(), 1);
    ----Item Tooltip      (text1, text2, icon, colorIndex, offsetX, offsetY, delay)

    if not self.sourceID then
        if self.isEditMode then
            activeActor:UndressSlot(self:GetParent().currentSlotID);
            return
        end
    end

    print(self.sourceID)
    if not self.name then
        if self.sourceID then
            sourceTemp = DataProvider:GetSourceInfo(self.sourceID);
            self.name = sourceTemp.name;
            self.itemModID = sourceTemp.itemModID;
            self.sourceType = sourceTemp.sourceType;
            self.icon = GetSourceIcon(self.sourceID);
            After(0.2, function()
                if self:IsMouseOver() then
                    self:OnEnter();
                end
            end)
        else
            if not self.isEditMode then
                MouseOverDelay(self, self.narciCameraIndex or 1);
            end
        end
        return
    end

    --print("SourceID #".. self.sourceID or 0);

    local text2;
    local delay;
    if self.isEditMode then
        if self.caseIndex == 3 then
            text2 = DataProvider:GetUnusableReason(self.visualID);
            text2 = NarciAPI_DeformatString(text2, {TRANSMOG_REQUIRED_SKILL, TRANSMOG_REQUIRED_HOLIDAY});
        else
            text2 = DataProvider:GetSourceText(self.sourceType, self.sourceID, self.itemModID);
        end

        if activeActor then
            if self.isWeapon then
                if self.isMainHand then
                    activeActor:TryOn(self.sourceID, "MAINHANDSLOT", 0);
                else
                    activeActor:TryOn(self.sourceID, "SECONDARYHANDSLOT", 0);
                end
            else
                activeActor:TryOn(self.sourceID);
            end
        end
    else
        delay = 1.5;
        text2 = "Click to change this slot.";
        MouseOverDelay(self, self.narciCameraIndex or 1);
    end


    NarciItemTooltip:NewText(self.name, text2, self.icon, self.caseIndex, nil, 4, delay);
end

function NarciOutfitItemModelMixin:OnLeave()
    UIFrameFadeIn(self.Highlight, 0.25, self.Highlight:GetAlpha(), 0);
    HighlightBorder:Hide();
    self.animLight:Hide();
    local _;
    _, _, _, _, _, _, _, _, _, self.animLight.fromIntensity = self:GetLight();
    self.animLight.toIntensity = 0;
    self.animLight:Show();
    
    NarciItemTooltip:FadeOut();
end

function NarciOutfitItemModelMixin:OnMouseUp(button)
    if not self:IsMouseOver() then return end

    local Create = self:GetParent();
    if self.isEditMode then
        if button == "LeftButton" then
            local slotID = Create.currentSlotID;
            OutfitFrame.appliedSourceIDs[slotID] = self.sourceID;
            Create.lastVisitedPage[slotID] = Create.lastIndex;
            Create:ReturnHome();
        end
    else
        if button == "LeftButton" then
            Create.currentSlotID = self.slotID;
            local categoryID = self.categoryID;
            if categoryID then
                if categoryID == -1 then

                else
                    Create:SetCategory(categoryID);
                    CreateDropdownMenu(self.isWeapon, (self.slotID == 17) );
                end
            end
        end
    end

    NarciItemTooltip:JustHide();
end


function NarciOutfitItemModelMixin:UpdateStatusIcon()
    if not self.sourceID then
        self.Star:Hide();
        self.Status:Hide();
        self.Label:Show();
        self.LabelBackground:Show();
        return
    else
        self.Label:Hide();
        self.LabelBackground:Hide();
    end

    if self.isFavorite and self.isEditMode then
        self.Star:Show();
    else
        self.Star:Hide();
    end

    if not self.isCollected then
        self.Status:SetTexCoord(0.25, 0.5, 0, 0.25);
        self.Status:Show();
        self.caseIndex = 2;
    elseif not self.isUsable then
        self.Status:SetTexCoord(0.5, 0.75, 0, 0.25);
        self.Status:Show();
        self.caseIndex = 3;
    else
        if self.sourceID then
            self.Status:SetTexCoord(0.75, 1, 0, 0.25);
            self.Status:Show();
        end
        self.caseIndex = 1;
    end
end

local function CreateItemButtons(frame, isWeapon)
    local BUTTON_PER_ROW = 5;
    local BUTTON_OFFSET_X = 8;
    local BUTTON_OFFSET_Y = 8;
    local NUM_SLOT = 20;
    frame.numButtons = NUM_SLOT;

    local button;
    local buttons = {};
    if not frame.buttonBySlotID then
        frame.buttonBySlotID = {};
    end
    local buttonBySlotID = frame.buttonBySlotID;
    local slotID, slotName;
    local slotInfo;

    local buttonWidth, buttonHeight;

    for i = 1, NUM_SLOT do
        button = CreateFrame("DressUpModel", nil, frame, "Narci_OutfitItemModelTemplate");
        button.isWeapon = isWeapon;
        tinsert(buttons, button);
        if i == 1 then
            --Align to bottom inset
            buttonHeight = button:GetHeight();
            local frameHeight = frame:GetHeight();
            local startOffsetY = frameHeight - (BUTTON_OFFSET_Y + buttonHeight) * (ceil(NUM_SLOT / BUTTON_PER_ROW) - 1) - buttonHeight;
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -startOffsetY); --18

            --Adjust Tab width
            local BORDER_INSET = 20;
            buttonWidth = button:GetWidth();
            frame:SetWidth( BUTTON_PER_ROW * (BUTTON_OFFSET_X + buttonWidth) - BUTTON_OFFSET_X + BORDER_INSET);

            --Align Filter Button to Top-left
            local Filter = frame.Filter;
            Filter:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, BUTTON_OFFSET_Y);
            Filter:SetWidth(buttonWidth * 2 + BUTTON_OFFSET_X);

        elseif i % BUTTON_PER_ROW == 1 then
            button:SetPoint("TOPLEFT", buttons[i - BUTTON_PER_ROW], "BOTTOMLEFT", 0, -BUTTON_OFFSET_Y);
        else
            button:SetPoint("TOPLEFT", buttons[i - 1], "TOPRIGHT", BUTTON_OFFSET_X, 0);

            if i == BUTTON_PER_ROW then
                --Align Search Box to Top-right
                local SearchBox = frame.SearchBox;
                SearchBox:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 0, BUTTON_OFFSET_Y);
                SearchBox:SetWidth(buttonWidth * 2 + BUTTON_OFFSET_X);
            elseif i == 3 then
                --Set Progress Bar Size
                local ProgressBar = frame.ProgressBar;
                ProgressBar:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, BUTTON_OFFSET_Y);
                local span = 1;
                local barWidth = buttonWidth * span + BUTTON_OFFSET_X * (span - 1);
                ProgressBar:SetWidth(barWidth);
                ProgressBar.width = barWidth;
            end
        end

        slotInfo = SLOT_INFO[i];
        if slotInfo then
            slotID = slotInfo[1];
            button.slotID = slotID;
            button.categoryID = slotInfo[3];
            button.narciCameraIndex = slotInfo[4];
            if slotInfo[5] == isWeapon then
                slotName = NarciAPI_GetSlotLocalizedName(slotID);
                button.slotName = slotName;
                button.Label:SetText(slotName);
                button.order = i;
                local defaultCameraID = GetAppearanceCameraIDBySource(slotInfo[2]);
                button.cameraReferenceSourceID = slotInfo[2];
                if not defaultCameraID or defaultCameraID == 0 then
                    local frame = button;
                    DataProvider:QueryCameraID(frame);
                else
                    button.defaultCameraID = defaultCameraID;
                end
                buttonBySlotID[slotID] = button;
            end
        end
    end

    if isWeapon then
        frame.weaponButtons = buttons;

        --UI Blur
        local Blur = frame.ButtonBlur;
        Blur:SetPoint("TOPLEFT", buttons[1], "TOPLEFT", 0, 0);
        Blur:SetPoint("BOTTOMRIGHT", buttons[ #buttons ], "BOTTOMRIGHT", 0, 0);
    else
        frame.armorButtons = buttons;
    end
end



------------------------------------------------------------------
NarciItemCollectionMixin = {};

function NarciItemCollectionMixin:Load()
    self.firstModelIndex= 2;       --Reserved for current item and pending items
    self.maxPendingItems = 4;
    self.lastIndex = 0;
    self.lastVisitedPage = {};

    HighlightBorder = self.HighlightBorder;

    local isWeapon = true;
    CreateItemButtons(self, isWeapon);
    CreateItemButtons(self);

    self.mainHandButton = self.buttonBySlotID[16];
    self.offHandButton = self.buttonBySlotID[17];

    local _, _, raceID = UnitRace("player");
    if raceID == 22 then
        self:SetScript("OnShow", function()
            self:RegisterEvent("UNIT_MODEL_CHANGED")
        end)
        self:SetScript("OnHide", function()
            self:UnregisterEvent("UNIT_MODEL_CHANGED")
        end)
        self:SetScript("OnEvent", function(_, event, ...)
            self:OnEvent(event, ...)
        end)
    end
end


function NarciItemCollectionMixin:OnMouseWheel(delta)
    if not self.isEditMode then return end

    if delta > 0 then
        if self.isFirstPage then return end
        self.lastIndex = max(0, self.lastIndex - 2* self.numPerPage);
    else
        if self.isLastPage then return end
    end
    self:UpdatePage();

    NarciItemTooltip:JustHide();
end

function NarciItemCollectionMixin:UpdatePage(fadeIn)
    local index = self.lastIndex;

    if index == 0 then
        self.isFirstPage = true;
    else
        self.isFirstPage = nil;
    end

    local subList = self.subList;
    local model;
    local sourceID;
    local visualInfo, visualID;
    local cameraID;
    local isLastPage;
    for i = self.firstModelIndex, self.numButtons do
        index = index + 1;
        visualInfo = subList[index];
        model = self.itemButtons[i];
        if visualInfo then
            model.isFavorite = visualInfo.isFavorite;
            model.isCollected = visualInfo.isCollected;
            model.isUsable = visualInfo.isUsable;
            visualID = visualInfo.visualID;
            sourceID = DataProvider:GetAppearanceSourceID(visualID);
            cameraID = GetAppearanceCameraIDByVisual(visualID);

            if cameraID ~= model.cameraID then
                model.cameraID = cameraID;
                model:RefreshCamera();
                Model_ApplyUICamera(model, cameraID);
            end

            if not model.isWeapon then
                model:TryOn(sourceID);
            else
                model:SetItemAppearance(visualID);
            end

            model.sourceID = sourceID;
            model.visualID = visualID;
            model.name = nil;
            --[[
            sourceTemp = DataProvider:GetSourceInfo(sourceID);
            model.name = sourceTemp.name;
            model.itemModID = sourceTemp.itemModID;
            model.sourceType = sourceTemp.sourceType;
            model.icon = GetSourceIcon(sourceID);
            --]]

            model:UpdateStatusIcon();
            model:Hide();
            model:Show();
            model:SetAlpha(1);
            --Animation
            
            if fadeIn then
                if not model.isFading then
                    model:SetAlpha(0);
                end
                After(i/50, function()
                    local frame = self.itemButtons[i];
                    if not frame.isFading then
                        frame.isFading = true;
                        UIFrameFadeIn(frame, 0.15, 0, 1);
                        frame.fadeInfo.finishedArg1 = frame;
                        frame.fadeInfo.finishedFunc = function(self) self.isFading = nil end
                    end
                end);
            end
        else
            model:Hide();
            model.isFading = nil;
            isLastPage = true;
        end
    end
    
    if not subList[index + 1] then
        isLastPage = true;
    end

    self.lastIndex = index;

    self.isLastPage = isLastPage;

    self.ProgressBar:SetThumbPosition( (index - self.numPerPage) / (self.numVisuals - self.numPerPage) );
end

function NarciItemCollectionMixin:ChooseButtonPool(isHome, isWeapon, isMainHand)
    if isHome then
        self.isWeapon = nil;
        self.itemButtons = {};
        for i = 1, self.numButtons do
            if i == 11 or i == 12 then
                self.itemButtons[i] = self.weaponButtons[i];
                self.armorButtons[i]:Hide();
            else
                self.itemButtons[i] = self.armorButtons[i];
                self.weaponButtons[i]:Hide();
            end
        end
    else
        local hideButton;
        if isWeapon ~= self.isWeapon then
            self.isWeapon = isWeapon;
            hideButton = true;
        else
            return
        end

        if isWeapon then
            if hideButton then
                for i = 1, self.numButtons do
                    self.armorButtons[i]:Hide();
                end
            end

            for i = 1, #self.weaponButtons do
                self.weaponButtons[i].isMainHand = isMainHand;
            end

            self.itemButtons = self.weaponButtons;
        else
            if hideButton then
                for i = 1, self.numButtons do
                    self.weaponButtons[i]:Hide();
                end
            end
            self.itemButtons = self.armorButtons;
        end
    end
end

function NarciItemCollectionMixin:RefreshModel()
    for i = 1, #self.armorButtons do
        self.armorButtons[i]:ForceReset();
    end
end

function NarciItemCollectionMixin:OnEvent(event, ...)
    local unit = ...;
    if ( unit == "player" and IsUnitModelReadyForUI("player") ) then
        local hasAlternateForm, inAlternateForm = HasAlternateForm();
        if ( self.inAlternateForm ~= inAlternateForm ) then
            self.inAlternateForm = inAlternateForm;
            self:RefreshModel();
        end
    end
end

function NarciItemCollectionMixin:SetCategory(categoryID, lastSourceID, filteredList)
    --[[
	local collected, total;
	if ( self.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		total = #self.visualsList;
		collected = 0;
		for i, illusion in ipairs(self.visualsList) do
			if ( illusion.isCollected ) then
				collected = collected + 1;
			end
		end
	else
		collected = C_TransmogCollection.GetCategoryCollectedCount(self.activeCategory);
		total = C_TransmogCollection.GetCategoryTotal(self.activeCategory);
	end
	WardrobeCollectionFrame_UpdateProgressBar(collected, total);  
    --]]
    activeActor = ModelScene:GetActiveActor();

    if categoryID then
        self.activeCategory = categoryID;
    else
        categoryID = self.activeCategory;
    end

    local subList;
    local numCollected, numVisuals;
    local fadeIn;
    if filteredList then
        subList = filteredList;
        numCollected = 0;
        numVisuals = #subList;
        fadeIn = false;
        for i = 1, numVisuals do
            if subList[i].isCollected then
                numCollected = numCollected + 1;
            end
        end
    else
        subList = VisualIDsByCategory[categoryID];
        numCollected = C_TransmogCollection.GetCategoryCollectedCount(categoryID);
        numVisuals = C_TransmogCollection.GetCategoryTotal(categoryID);
        fadeIn = true;
    end
    self.ProgressBar:SetProgress(numCollected, numVisuals);

    local currentSlotID = self.currentSlotID;
    local lastSourceID = activeActor:GetSlotTransmogSources(currentSlotID);
    local isEmpty = (not lastSourceID) or (lastSourceID == 0);
    local appliedSourceIDs = OutfitFrame.appliedSourceIDs;

    local isWeapon, canEnchant, canMainHand, canOffHand = subList.isWeapon, subList.canEnchant, subList.canMainHand, subList.canOffHand;
    local isHome = false;
    local isMainHand = currentSlotID == 16;
    self:ChooseButtonPool(isHome, isWeapon, isMainHand);   --mainhand slot 16

    self.subList = subList;
    self.isEditMode = true;
    self.firstModelIndex= 2;
    self.numPerPage = self.numButtons - 1;
    self.lastIndex = max( 0, (self.lastVisitedPage[currentSlotID] or 0) - self.numPerPage);
    self.numVisuals = numVisuals;
    self.totalPages = ceil(numVisuals / self.numPerPage);

    local model = self.itemButtons[1];
    local visualID;

    if isEmpty then 
        model.sourceID = nil;
        visualID = subList[1].visualID;
    else
        model.sourceID = lastSourceID;
        visualID = DataProvider:GetSourceInfo(lastSourceID, "visualID");
    end

    if visualID then
        local cameraID = GetAppearanceCameraIDByVisual(visualID);
        if cameraID ~= model.cameraID then
            model.cameraID = cameraID;
            model:RefreshCamera();
            Model_ApplyUICamera(model, cameraID);
        end
    else
        visualID = -1;
    end
    
    if isWeapon then
        if isEmpty then
            model:SetItemAppearance(0);
        else
            model:SetItemAppearance(visualID)
        end
        WeaponButtonMixin:SetSheatheAnimationByCategoryID(categoryID);
    else
        if isEmpty then
            model:Undress();
        else
            model:TryOn(lastSourceID);
        end
    end

    model.isEditMode = true;
    model.Label:SetText("|cff40c7ebSelected");
    model.Label:Show();
    model.LabelBackground:Show();
    model.Status:Hide();
    model:Hide();
    model:Show();

    for i = 2, self.numButtons do
        --#1 reserved for current gear
        model = self.itemButtons[i];
        model.isEditMode = true;
        model.Label:Hide();
        model.LabelBackground:Hide();
        model.sourceID = nil;
        model:Show();
        model:RefreshSlot();
    end

    self:UpdatePage(fadeIn);
    self:ShowExtraButtons(true);
end

function NarciItemCollectionMixin:RefreshActiveCategory()
    self.lastVisitedPage[self.currentSlotID] = nil;
    self:SetCategory();
end


function NarciItemCollectionMixin:ReturnHome()
    self.isEditMode = nil;
    local isHome = true;
    self:ChooseButtonPool(isHome);

    local model;
    local appliedSourceIDs = OutfitFrame.appliedSourceIDs;
    local slotID;
    local sourceID;
    for i = 1, self.numButtons do
        model = self.itemButtons[i];
        model.isEditMode = nil;
        model.name = nil;
        model.itemModID = nil;
        model.sourceType = nil;
        model.cameraID = nil;

        slotID = model.slotID;
        if slotID then
            sourceID = appliedSourceIDs[slotID];
            model.sourceID = sourceID;
            model:Undress();
            if sourceID then
                model.Label:Hide();
                model.LabelBackground:Hide();
                if model.isWeapon then 
                    local visualID = DataProvider:GetSourceInfo(sourceID, "visualID");
                    --print("visualID #"..visualID)
                    if visualID then
                        local cameraID = GetAppearanceCameraIDByVisual(visualID);
                        model.defaultCameraID = cameraID;
                        model:SetItemAppearance(visualID);
                    end
                else
                    local cameraID = GetAppearanceCameraIDBySource(sourceID); 
                    model.defaultCameraID = cameraID;
                    model:TryOn(sourceID);
                end
                model.Star:Hide();
                model.isCollected = DataProvider:IsSourceCollected(sourceID);
                model.isUsable = true;
                model:UpdateStatusIcon();
            else
                local cameraID = GetAppearanceCameraIDBySource(model.cameraReferenceSourceID); 
                model.defaultCameraID = cameraID;
                model.Label:SetText(model.slotName);
                model.Label:Show();
                model.LabelBackground:Show();
                model.Star:Hide();
                model.Status:Hide();
            end

            if not model.isFading then
                model:SetAlpha(0);
            end
            
            After(i/50, function()
                local frame = self.itemButtons[i];
                frame:RefreshCamera();
                Model_ApplyUICamera(frame, frame.defaultCameraID);
                if not frame.isFading then
                    frame.isFading = true;
                    UIFrameFadeIn(frame, 0.15, 0, 1);
                    frame.fadeInfo.finishedArg1 = frame;
                    frame.fadeInfo.finishedFunc = function(frame) frame.isFading = nil end
                end
            end);
        else
            model.sourceID = nil;
            model:Hide();
            --[[
            After(i/50, function()
                local frame = self.itemButtons[i];
                if not frame.isFading and frame:IsShown() then
                    frame.isFading = true;
                    FadeFrame(frame, 0.15, "OUT");
                    if frame.fadeInfo then
                        frame.fadeInfo.finishedArg1 = frame;
                        frame.fadeInfo.finishedFunc = function(frame)
                            frame:Hide();
                            frame.isFading = nil;
                        end
                    end
                end
            end);
            --]]
        end
    end

    self:ShowExtraButtons(false);
end

function NarciItemCollectionMixin:ShowExtraButtons(show)
    local mode;
    if show then
        mode = "IN";
    else
        mode = "OUT";
    end
    FadeFrame(self.SearchBox, 0.25, mode);
    FadeFrame(self.ProgressBar, 0.25, mode);
    FadeFrame(self.Filter, 0.25, mode);
end

function NarciItemCollectionMixin:Scale(scale)
    self:SetScale(scale);
    After(0, function()
        if self.itemButtons then
            for i = 1, #self.itemButtons do
                self.itemButtons[i]:OnModelLoaded();        --Refreshing camera to maintain model scale/position
            end
        end
    end)
end

------------------------------------------------------------------
NarciOutfitDropdownMenuMixin = {};

function NarciOutfitDropdownMenuMixin:SetDropdownSize(width, height)
    self:SetSize(width, height);
    self.width = width;
end

function NarciOutfitDropdownMenuMixin:OnLoad()
    local animDropdown = NarciAPI_CreateAnimationFrame(0.25);
    animDropdown:SetScript("OnUpdate", function(frame, elpased)
        frame.total = frame.total + elpased;
        local alpha = 1.2 * frame.total / frame.duration;
        local width = outQuart(frame.total, frame.fromWidth, frame.toWidth, frame.duration);
        if frame.total > frame.duration then
            frame:Hide();
            width = frame.toWidth;
            alpha = 1;
        end
        self:SetWidth(width);
        self:SetAlpha(alpha);
    end)

    self.animFrame = animDropdown;
end

function NarciOutfitDropdownMenuMixin:OnShow()
    self.animFrame:Hide();
    if self.width then
        self.animFrame.toWidth = self.width;
        self.animFrame.fromWidth = self.width * 0.1;
        self.animFrame:Show();
    end

    self:RegisterEvent("GLOBAL_MOUSE_DOWN");

    if self.onShowFunc then
        self.onShowFunc();
    end
end

function NarciOutfitDropdownMenuMixin:OnHide()
    self.animFrame:Hide();

    self:UnregisterEvent("GLOBAL_MOUSE_DOWN");

    if self.onHideFunc then
        self.onHideFunc();
    end
end

function NarciOutfitDropdownMenuMixin:OnEvent(event, button)
    if event == "GLOBAL_MOUSE_DOWN" then
        if not (self:IsMouseOver() or self.parentFrame:IsMouseOver()) then
            self:Hide();
        end
    end
end


------------------------------------------------------------------
NarciOutfitFilterMixin = {};

function NarciOutfitFilterMixin:OnEnter()
    self.Text:SetAlpha(0.8);
end

function NarciOutfitFilterMixin:OnLeave()
    self.Text:SetAlpha(0.46);
end

function NarciOutfitFilterMixin:OnLoad()

end

function NarciOutfitFilterMixin:OnClick()
    self.Dropdown:SetShown(not self.Dropdown:IsShown())
end


------------------------------------------------------------------
NarciOutfitSourceButtonMixin = {}

function NarciOutfitSourceButtonMixin:CreateOptionIcon()
    local numSources = self.numSources;

    if not self.icons then
        self.icons = {};
    end

    if not numSources then return end

    local icon;
    local icons = self.icons;

    if numSources > 1 then
        local SIZE = 6;
        local MAX_PER_COL = 5;
        local maxCol = ceil(numSources/MAX_PER_COL);

        for i = 1, numSources do
            icon = icons[i];
            if not icon then
                icon = self:CreateTexture(nil, "OVERLAY");
                icon:SetSize(SIZE, SIZE);
                icon:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/OptionSquare", nil, nil, "TRILINEAR");
                icon:SetTexCoord(0, 0.5, 0, 1);
                tinsert(icons, icon);
            end

            icon:ClearAllPoints();
            
            if i % MAX_PER_COL == 1 then
                local numCol = ceil(i/MAX_PER_COL);
                local offsetY;
                if numCol == maxCol then
                    offsetY = SIZE *(numSources - 1 - (maxCol - 1)*MAX_PER_COL)/2
                else
                    offsetY = SIZE *(MAX_PER_COL - 1)/2
                end

                if self.isRight then
                    icon:SetPoint("CENTER", self, "RIGHT", 2 - SIZE * (numCol - 0.5), offsetY);
                else
                    icon:SetPoint("CENTER", self, "LEFT", SIZE * (numCol - 0.5) -2, offsetY);
                end
            else
                icon:SetPoint("CENTER", icons[i - 1], "CENTER", 0, -SIZE);
            end

            icon:Show();
        end
    else
        icon = icons[1];
        if icon then
            icon:Hide();
        end
    end

    for i = numSources + 1, #icons do
        icon = icons[i];
        icon:Hide();
    end
end

function NarciOutfitSourceButtonMixin:UpdateDirection()
    if self.isRight then
        local reference = self.TextReference;
        self.IconMask:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/IconMaskRight");
        reference:ClearAllPoints();
        self.Header:ClearAllPoints();
        self.Text:ClearAllPoints();
        reference:SetPoint("RIGHT", self, "LEFT", 0, 0);
        self.Header:SetPoint("TOPRIGHT", reference, "TOPLEFT", 0, -6);
        self.Text:SetPoint("BOTTOMRIGHT", reference, "BOTTOMLEFT", 0, 6);
        self.Header:SetJustifyH("RIGHT");
        self.Text:SetJustifyH("RIGHT");
    end
end

function NarciOutfitSourceButtonMixin:OnEnter()
    if self.selectedIcon then
        self.selectedIcon:SetSize(10, 10);
    end
end

function NarciOutfitSourceButtonMixin:OnLeave()
    if self.selectedIcon then
        self.selectedIcon:SetSize(6, 6);
    end
end

function NarciOutfitSourceButtonMixin:OnClick(button)
    if button == "LeftButton" then
        if self.numSources > 1 then
            local newIndex;
            if button == "LeftButton" then
                if self.selectedSourceIndex < self.numSources then
                    newIndex = self.selectedSourceIndex + 1;
                else
                    newIndex = 1;
                end
            elseif button == "RightButton" then
                if self.selectedSourceIndex <= 1 then
                    newIndex = self.numSources;
                else
                    newIndex = self.selectedSourceIndex - 1;
                end
            end
            self.fadeOut = true;
            self:SetPrimarySource(newIndex);
        end
    else
        if self.sourceType and self.sourceType == 1 then
            --Open Encounter Journal, search that item
            if not EncounterJournal or not EncounterJournal:IsShown() then
                ToggleEncounterJournal();
            end

            if EncounterJournal then
                --Unavailable for low level char
                After(0, function()
                    local searchBox = EncounterJournal.searchBox;
                    if searchBox then
                        searchBox:SetText(" ");
                        searchBox:SetText(self.Header:GetText());
                        After(0.15, function()
                            searchBox.searchPreview[1]:Click()
                        end)
                    end
                end)
            end
        end
    end
end

function NarciOutfitSourceButtonMixin:OnHide()
    self.fadeOut = nil;
end

function NarciOutfitSourceButtonMixin:UpdateSourceIcon(sourceIndex)
    if self.needRefresh then
        self.needRefresh = nil;
        self:CreateOptionIcon();
    end

    self.selectedSourceIndex = sourceIndex;
    local icon;
    local icons = self.icons;
    self.selectedIcon = icons[sourceIndex];

    local hasFocus = self:IsMouseOver();

    for i = 1, #icons do
        icon = icons[i];
        if i == sourceIndex then
            icon:SetTexCoord(0.5, 1, 0, 1);
            if hasFocus then
                icon:SetSize(10, 10);
            else
                icon:SetSize(6, 6);
            end
        else
            icons[i]:SetTexCoord(0, 0.5, 0, 1);
            icon:SetSize(6, 6);
        end
    end
end

function NarciOutfitSourceButtonMixin:SetSourceText(text1, text2, quality)
    if self.fadeOut then
        UIFrameFadeIn(self.Header, 0.1, self.Header:GetAlpha(), 0);
        UIFrameFadeIn(self.Text, 0.1, self.Header:GetAlpha(), 0);
    else
        self.Header:SetAlpha(0);
        self.Text:SetAlpha(0);
    end

    After(0.1, function()
        self.Header:SetText(text1);
        self.Text:SetText(text2);
        self.Header:ClearAllPoints();
        if text2 then
            if self.isRight then
                self.Header:SetPoint("TOPRIGHT", self.TextReference, "TOPLEFT", 0, -6);
            else
                self.Header:SetPoint("TOPLEFT", self.TextReference, "TOPRIGHT", 0, -6);
            end
            self.Header:SetJustifyV("TOP");
            self.TextReference:SetHeight(self.Header:GetHeight() + self.Text:GetHeight() + 16);
        else
            if self.isRight then
                self.Header:SetPoint("RIGHT", self.TextReference, "LEFT", 0, 0);
            else
                self.Header:SetPoint("LEFT", self.TextReference, "RIGHT", 0, 0);
            end
            self.Header:SetJustifyV("MIDDLE");
        end
        UIFrameFadeIn(self.Header, 0.15, self.Header:GetAlpha(), 1);
        UIFrameFadeIn(self.Text, 0.15, self.Header:GetAlpha(), 1);
        self.Header:SetTextColor( unpack(QUALITY_COLORS[quality]));
    end)
end

function NarciOutfitSourceButtonMixin:SetPrimarySource(sourceIndex)
    local sourceID, selectedSourceIndex, numSources = DataProvider:GetAppearanceSourceID(self.visualID, sourceIndex);
    if not sourceID then
        sourceID = self.oddSourceID;
        selectedSourceIndex = 1;
        numSources = 1;
    end

    self.selectedSourceIndex = selectedSourceIndex;
    self.numSources = numSources;
    sourceIndex = sourceIndex or selectedSourceIndex;

    sourceTemp = DataProvider:GetSourceInfo(sourceID or self.oddSourceID);
    local quality = sourceTemp.quality or 1;
    local icon = GetSourceIcon(sourceID);
    self.Icon:SetTexture(icon);
    if sourceTemp.name then
        if sourceTemp.isCollected and self.hideCollectedSource then
            self:SetSourceText(sourceTemp.name, "|cff3cb878Collected", 0);
            self.Icon:SetDesaturated(true);
            self.Icon:SetAlpha(0.38);
        else
            self.sourceType = sourceTemp.sourceType;
            self:SetSourceText(sourceTemp.name, DataProvider:GetSourceText(self.sourceType, sourceID, sourceTemp.itemModID, true), quality);
            self.Icon:SetDesaturated(false);
            self.Icon:SetAlpha(1);
        end
    else
        UIFrameFadeIn(self.Header, 0.2, self.Header:GetAlpha(), 0);
        UIFrameFadeIn(self.Text, 0.2, self.Header:GetAlpha(), 0);
        After(0.5, function()
            self:SetPrimarySource();
        end)
    end

    self:UpdateSourceIcon(sourceIndex);
end

function NarciOutfitSourceButtonMixin:SetVisual(visualID, oddSourceID, hideCollectedSource)
    if hideCollectedSource == self.hideCollectedSource then
        if visualID then
            if visualID == self.visualID then
                return
            end
        elseif oddSourceID == self.oddSourceID then
            return
        end
    else
        self.hideCollectedSource = hideCollectedSource;
    end

    self.visualID = visualID;
    self.oddSourceID = oddSourceID;
    self.needRefresh = true;
    sourceTemp = DataProvider:GetSourceInfo(oddSourceID);
    self:SetPrimarySource();
end

function NarciOutfitSourceButtonMixin:EmptyVisual()
    if self.oddSourceID then
        self.oddSourceID = nil;
        self:SetSourceText(self.slotName, nil, 0);
        self.Icon:SetTexture(self.slotTexture);
        self.Icon:SetDesaturated(false);
        self.Icon:SetAlpha(0.46);
        self.numSources = 0;
        self:CreateOptionIcon();
    end
end



local function CreateSourceButtons(frame)
    local BUTTON_OFFSET_X = 20;
    local BUTTON_OFFSET_Y = 8;
    local SOURCE_BUTTON_INFO = {
        [1] = { --Left
            1,  --Head
            3,  --Shoulder
            15, --Back
            5,  --Chest
            7,  --Legs
    
            16, --Main
        },
    
        [2] = { --Right
            9,  --Wrist
            10, --Hand
            6,  --Waist
            8,  --Feet
            4,  --Shirt
            19, --Tabard
    
            17, --Off
        },
    }

    local info = SOURCE_BUTTON_INFO[1];
    local button;
    local buttons = {};
    local buttonBySlotID = {};
    local slotID;
    local buttonHeight;

    for i = 1, #info do
        button = CreateFrame("Button", nil, frame, "Narci_OutfitSourceButtonTemplate");
        tinsert(buttons, button);
        if i == 1 then
            buttonHeight = button:GetHeight();
            button:SetPoint("BOTTOMLEFT", frame, "LEFT", BUTTON_OFFSET_X, buttonHeight + 1.5 * BUTTON_OFFSET_Y);
        elseif i == #info then
            button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -BUTTON_OFFSET_X, BUTTON_OFFSET_X);
            button.isRight = true;
            button:UpdateDirection();
        else
            button:SetPoint("TOP", buttons[i - 1], "BOTTOM", 0, -BUTTON_OFFSET_Y);
        end
        button.slotID = info[i];
    end

    local indexOffset = #buttons;

    info = SOURCE_BUTTON_INFO[2];
    for i = 1, #info do
        button = CreateFrame("Button", nil, frame, "Narci_OutfitSourceButtonTemplate");
        tinsert(buttons, button);
        button.isRight = true;
        if i == 1 then
            buttonHeight = button:GetHeight();
            button:SetPoint("BOTTOMRIGHT", frame, "RIGHT", -BUTTON_OFFSET_X, 2 * buttonHeight + 2.5 * BUTTON_OFFSET_Y);
        elseif i == #info then
            button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", BUTTON_OFFSET_X, BUTTON_OFFSET_X);
            button.isRight = nil;
        else
            button:SetPoint("TOP", buttons[i - 1 + indexOffset], "BOTTOM", 0, -BUTTON_OFFSET_Y);
        end
        button.slotID = info[i];
        button:UpdateDirection();
    end

    --OnLoad
    for i = 1, #buttons do
        button = buttons[i];
        buttonBySlotID[button.slotID] = button;
        button.slotName, button.slotTexture = NarciAPI_GetSlotLocalizedName(button.slotID);
        button.slotName = GRAY_50.. button.slotName;
        button.oddSourceID = -1;
        if button.isRight then
            button:SetHitRectInsets(0, 8, 0, 0);
        else
            button:SetHitRectInsets(-8, 0, 0, 0);
        end
    end

    frame.buttonBySlotID = buttonBySlotID;
end


------------------------------------------------------------------
NarciItemListMixin = {};

local function CreatOutfitProgressBar(self)
    local BAR_HEIGHT = 2;

    local frame = self:GetParent().Navigation.HighlightFrame;
    local tube = frame:CreateTexture(nil, "OVERLAY", nil, 1);
    local navigationButton = self:GetParent().navigationButtons[2];
    tube:SetPoint("TOPLEFT", navigationButton, "BOTTOMLEFT", 8, BAR_HEIGHT + 1);
    tube:SetPoint("BOTTOMRIGHT", navigationButton, "BOTTOMRIGHT", -8, 1);
    tube:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/ProgressBar", nil, nil, "TRILINEAR");
    tube:SetTexCoord(0, 1, 0, 0.25);
    local fill = frame:CreateTexture(nil, "OVERLAY", nil, 2);
    fill:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/ProgressBar", nil, nil, "TRILINEAR");
    fill:SetTexCoord(0, 1, 0.5, 0.75);
    fill:SetPoint("LEFT", tube, "LEFT", 0, 0);
    fill:SetSize(20, BAR_HEIGHT);

    self.fill = fill;
    self.maxFillWidth = tube:GetWidth();
end

function NarciItemListMixin:Load()
    CreateSourceButtons(self);
    CreatOutfitProgressBar(self);
end

function NarciItemListMixin:UpdateSources(hideCollectedSource)
    local central = true;
    self:Show();
    
    local appliedSourceIDs = OutfitFrame.appliedSourceIDs;
    local buttonBySlotID = self.buttonBySlotID;
    local button;

    for slotID, button in pairs(buttonBySlotID) do
        button:Hide();
    end
    
    local visualID, sourceID;
    local numCollected, numItems = 0, 0;

    local secondActor = ModelScene:GetSecondActor();

    for slotID, button in pairs(buttonBySlotID) do
        sourceID = appliedSourceIDs[slotID];
        if sourceID then
            self.visualInfoTemp = DataProvider:GetSourceInfo(sourceID);
            button:SetVisual(self.visualInfoTemp.visualID, sourceID, hideCollectedSource);
            button:Show();
            
            numItems = numItems + 1;
            if DataProvider:IsSourceVisualCollected(sourceID) then
                numCollected = numCollected + 1;
                secondActor:TryOn(sourceID, slotID);
            else
                secondActor:UndressSlot(slotID);
            end
        else
            button:EmptyVisual();
            button:Show();
            secondActor:UndressSlot(slotID);
        end
    end

    self:SetProgress(numCollected, numItems);

    local isOutfitComplete = (numCollected == numItems);
    return isOutfitComplete
    --OutfitFrame:SetActiveTab(2);
end

function NarciItemListMixin:SetProgress(numCollected, numItems)
    --print(numCollected, numItems)
    if numCollected > 0 and numItems > 0 then
        self.fill:Show();
        local percent = numCollected / numItems;
        self.fill:SetWidth( self.maxFillWidth * percent );
        self.fill:SetTexCoord(0, percent, 0.5, 0.75);
    else
        self.fill:Hide();
    end
end



------------------------------------------------------------------
--Camera Panel

NarciOutfitCameraPanelMixin = {};

function NarciOutfitCameraPanelMixin:SetInteractiveArea(left, right, top, bottom)
    self:SetHitRectInsets(left, right, top, bottom);
    self.left = left;
    self.right = right;
    self.top = top;
    self.bottom = bottom;
end

function NarciOutfitCameraPanelMixin:OnLoad()
    local TooltipFrame = CreateFrame("Frame", nil, self);
    TooltipFrame:SetAlpha(0);
    TooltipFrame:Hide();
    self.TooltipFrame = TooltipFrame;
    self.AutoZoom.Label:SetParent(TooltipFrame);
    self.SheatheWeapon.Label:SetParent(TooltipFrame);
    self.CombatView.Label:SetParent(TooltipFrame);

    self:SetInteractiveArea(-60, 0, -30, -30);

    self.SheatheWeapon:SetScript("OnClick", function()
        WeaponButtonMixin:ChangeSheathed()
    end);

    WeaponButtonMixin.button = self.SheatheWeapon;
end

function NarciOutfitCameraPanelMixin:OnEnter()
    FadeFrame(self.TooltipFrame, 0.15, "IN");
end

function NarciOutfitCameraPanelMixin:OnLeave()
    if not self:IsMouseOver() then
        FadeFrame(self.TooltipFrame, 0.25, "OUT");
    end
end


------------------------------------------------------------------
--Hotkeys

local function InsertCommandList()
    local function ChangeSheathed()
        WeaponButtonMixin:ChangeSheathed();
    end

    local panelIndex = 1;
    OutfitFrame:AddCommand(panelIndex, "Z", ChangeSheathed);
end



------------------------------------------------------------------
NarciOutfitProgressBarMixin = {};

function NarciOutfitProgressBarMixin:OnLoad()
    self.Thumb:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/ProgressBarThumb", nil, nil, "TRILINEAR");
end

function NarciOutfitProgressBarMixin:OnEnter()
    self.Green:SetColorTexture(0.235, 0.722, 0.471, 1);
    self.Yellow:SetColorTexture(1, 0.824, 0, 1);
end

function NarciOutfitProgressBarMixin:OnLeave()
    self.Green:SetColorTexture(0.235, 0.722, 0.471, 0.5);
    self.Yellow:SetColorTexture(1, 0.824, 0, 0.5);
end

function NarciOutfitProgressBarMixin:OnClick()
    self:Disable();
    After(1, function()
        self:Enable();
    end)

end

function NarciOutfitProgressBarMixin:SetProgress(numCollected, total)
    local numUncollceted = total - numCollected;
    self.numCollected:SetText(numCollected);
    self.numUncollected:SetText(numUncollceted);
    
    if not self.barWidth then
        self.barWidth = self:GetWidth();
    end
    local barWidth = self.barWidth;
    local greenWidth = numCollected / total * barWidth;
    if numCollected == 0 then
        greenWidth = 0.5;
        self.numCollected:Hide();
        self.numUncollected:Show();
        self.Yellow:Show();
    elseif numCollected == total then
        self.numCollected:Show();
        self.numUncollected:Hide();
        self.Yellow:Hide();
    else
        greenWidth = max(greenWidth - 1, 12);
        self.numCollected:Show();
        self.numUncollected:Show();
        self.Yellow:Show();
    end
    self.Green:SetWidth(greenWidth);
end

function NarciOutfitProgressBarMixin:SetThumbPosition(percentage)
    percentage = Clamp(percentage, 0, 1);
    if percentage == 0 then
        self.Thumb:SetTexCoord(0.25, 0.5, 0, 1);
    elseif percentage == 1 then
        self.Thumb:SetTexCoord(0.5, 0.75, 0, 1);
    else
        self.Thumb:SetTexCoord(0, 0.25, 0, 1);
    end
    local offset = percentage * self.barWidth;
    self.Thumb:SetPoint("CENTER", self.Green, "LEFT", offset, 0);
end



------------------------------------------------------------------
NarciOutfitSearchBoxMixin = {};

function NarciOutfitSearchBoxMixin:OnLoad()
    self.DefaultText:SetText(SEARCH);
    self.Icon:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/OutfitIcons", nil, nil, "TRILINEAR");
end

function NarciOutfitSearchBoxMixin:QuitEdit()
    if not self.pauseUpdate then
        self.pauseUpdate = true;
        self:HighlightText(0, 0);
        self:ClearFocus();
        if self:GetText() == "" then
            self.DefaultText:Show();
        end
        After(0, function()
            self.pauseUpdate = nil
        end)
    end
end

function NarciOutfitSearchBoxMixin:OnEditFocusGained()
    self.DefaultText:Hide();
    local categoryID = self:GetParent().activeCategory;
    if not self.isSearchDBLoaded then
        local loaded = LoadAddOn("Blizzard_Collections");
        self.isSearchDBLoaded = loaded;
        if loaded then
            After(0, function()
                if not self.resultFrame then
                    self.resultFrame = WardrobeCollectionFrame.ItemsCollectionFrame;
                    self.resultFrame.visualsList = VisualIDsByCategory[categoryID]
                    self.resultFrame.filteredVisualsList = {};
                end
            end)
        end
    end

    C_TransmogCollection.SetSearchAndFilterCategory(categoryID);
    --/dump WardrobeCollectionFrame.ItemsCollectionFrame.filteredVisualsList
end

function NarciOutfitSearchBoxMixin:OnEnter()
    self.DefaultText:SetTextColor(0.8, 0.8, 0.8);
end

function NarciOutfitSearchBoxMixin:OnLeave()
    self.DefaultText:SetTextColor(0.46, 0.46, 0.46);
end

function NarciOutfitSearchBoxMixin:OnTextChanged()
    local text = self:GetText();
    if text ~= "" then
        C_TransmogCollection.SetSearch(1, text);
        local searchSize = C_TransmogCollection.SearchSize(1);
        local searchProgress = C_TransmogCollection.SearchProgress(1);
        After(0.2, function()
            local searchType = 1;
            if not C_TransmogCollection.IsSearchInProgress(searchType) then
                self.filteredList = self.resultFrame.filteredVisualsList;
                self:GetParent():SetCategory(nil, nil, self.filteredList);
            end
        end)

    end
end


------------------------------------------------------------------
local function BuildVisualList()
    local NUM_CATEGORY = NUM_LE_TRANSMOG_COLLECTION_TYPES or 29;
    local categoryID = 1;
    local name, isWeapon, canEnchant, canMainHand, canOffHand;
    local isMainHandIDAssigned, isOffHandIDAssigned;
    local AbbreviateWeaponName; --function
    local locale = GetLocale();

    if locale == "zhCN" or locale == "zhTW" then
        AbbreviateWeaponName = function(name)
            return name
        end
    else
        local ONE_HANDED = gsub(AUCTION_SUBCATEGORY_ONE_HANDED, "%-", "%%-");
        local TWO_HANDED = gsub(AUCTION_SUBCATEGORY_TWO_HANDED, "%-", "%%-");
        local gsub = string.gsub;

        AbbreviateWeaponName = function(name)
            name = gsub(name, ONE_HANDED, "1H");
            name = gsub(name, TWO_HANDED, "2H");
            return name
        end
    end

    local function SetMainHandWeaponType(categoryID)
        Narci_ItemCollection:SetCategory(categoryID);
        Narci_ItemCollection.mainHandButton.categoryID = categoryID;
    end

    local function SetOffHandWeaponType(categoryID)
        Narci_ItemCollection:SetCategory(categoryID);
        Narci_ItemCollection.offHandButton.categoryID = categoryID;
    end

    local function Recursion()
        name, isWeapon, canEnchant, canMainHand, canOffHand = GetCategoryInfo(categoryID);
        while (not name) do
            categoryID = categoryID + 1;
            name, isWeapon, canEnchant, canMainHand, canOffHand = GetCategoryInfo(categoryID);
        end


        if isWeapon then
            name = AbbreviateWeaponName(name);
            print(categoryID.." "..name.." Mainhand: "..tostring(canMainHand).." Offhand: "..tostring(canOffHand))
            if canMainHand then
                tinsert(UsableWeapons.mainhand, {name, SetMainHandWeaponType, categoryID});
                if not isMainHandIDAssigned then
                    isMainHandIDAssigned = true;
                    Narci_ItemCollection.mainHandButton.categoryID = categoryID
                end
            end
            if canOffHand then
                tinsert(UsableWeapons.offhand, {name, SetOffHandWeaponType, categoryID});
                if not isOffHandIDAssigned then
                    isOffHandIDAssigned = true;
                    Narci_ItemCollection.offHandButton.categoryID = categoryID;
                end
            end
        end

        local exclusionCategory;
        if canMainHand then
            exclusionCategory = 2;
        end

        VisualIDsByCategory[categoryID] = GetCategoryAppearances(categoryID, exclusionCategory);
        local subList = VisualIDsByCategory[categoryID];
        subList.isWeapon, subList.canEnchant, subList.canMainHand, subList.canOffHand = isWeapon, canEnchant, canMainHand, canOffHand;

        sort(VisualIDsByCategory[categoryID], SortFuncMixed);

        if categoryID < NUM_CATEGORY then
            categoryID = categoryID + 1;
            After(0.2, Recursion);
        else
            CreateDropdownMenu(true);
        end
    end

    --query category info
    for i = 1, NUM_CATEGORY do
        GetCategoryInfo(i);
    end

    After(1, Recursion);
end

local Initialize = CreateFrame("Frame")
Initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
Initialize:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        OutfitFrame = Narci_Outfit;
        ModelScene = OutfitFrame.ModelScene;
        BuildVisualList();
        InsertCommandList();
    end
end)

---------------------------------------------------------------
--[[
    /dump WardrobeCollectionFrame.ItemsCollectionFrame.chosenVisualSources
    EncounterJournal_DisplayInstance(instanceID);

    if not EncounterJournal or not EncounterJournal:IsShown() then
        ToggleEncounterJournal();
    end
    After(0, function()
        local searchBox = EncounterJournal.searchBox;
        if searchBox then
            searchBox:SetText("Helm of the Inexorable Tide")
            searchBox.searchPreview[1]:Click()
        end
    end)
--]]

hooksecurefunc(C_AdventureJournal, "ActivateEntry", function(index)
    print("index "..index)
end)