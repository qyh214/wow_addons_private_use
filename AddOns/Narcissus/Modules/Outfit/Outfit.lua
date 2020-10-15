local upper = string.upper;
local gsub = string.gsub;
local After = C_Timer.After;

local CreateAnimationFrame = NarciAPI_CreateAnimationFrame;
local FadeFrame = NarciAPI_FadeFrame;
local UIFrameFadeIn = UIFrameFadeIn;

local max = math.max;
local min = math.min;
local cos = math.cos;
local sin = math.sin;
local sqrt = math.sqrt;
local floor = math.floor;
local pow = math.pow;
local abs = math.abs;
local pi = math.pi;
local Clamp = Clamp;

local function RotateByYaw(x, y, z, x0, y0, z0, yaw)
    local px, py, pz = x - x0, y - y0, z - z0;
    local sinYaw = sin(yaw);
    local cosYaw = cos(yaw);
    return x0 + px * cosYaw - py * sinYaw, y0 + px * sinYaw + py * cosYaw, z
end

local function linear(t, b, e, d)
    return (e - b) * t / d + b
end

local function outSine(t, b, e, d)
	return (e - b) * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, e, d)
	return (b - e) / 2 * (cos(pi * t / d) - 1) + b
end

local function inOutSineZero(t, b, e, d)
    if d == 0 then
        return e
    else
        return (b - e) / 2 * (cos(pi * t / d) - 1) + b
    end
end


local function GetSetConciseName(name)
    if not name then return end
    name = gsub(name, "\'s.+", "");
    name = gsub(name, ".+of%s", "");
    name = upper(name);
    return name
end

local GRAY_90 = 0.08;
local GRAY_20 = 0.8;
local GRAY_50 = 0.46;
local GRAY_30 = 0.66;

local GetSourceInfo = C_TransmogCollection.GetSourceInfo;
local GetSlotForInventoryType = C_Transmog.GetSlotForInventoryType; --sourceInfo.invType

--C_TransmogSets
local GetBaseSets = C_TransmogSets.GetBaseSets;
local GetSetInfo = C_TransmogSets.GetSetInfo;
local GetVariantSets = C_TransmogSets.GetVariantSets;
local GetSetSources = C_TransmogSets.GetSetSources;

local NarciModelInfo =  NarciModelInfo;
local YAW_FACING_FORWARD, PLAYER_SCALE, OFFSET_AMPLIFIER ,PANNING_OFFSETS_FULL_CENTRAL, PANNING_OFFSETS_FULL_RIGHT, PANNING_OFFSETS_UPPER, PANNING_OFFSETS_LOWER = NarciModelInfo:GetSceneInfo();   --Facing, Scale
local OFFSET_YAW_STEP = -15/360 * pi;

local ACTOR_POSITIONS = {
    --[numActor] = { [1] = {offsetY-s}, [2] = {offsetYaw-s} }
    [1] = {{0},  {YAW_FACING_FORWARD}},
    [2] = {{OFFSET_AMPLIFIER*0.45, -OFFSET_AMPLIFIER*0.45},  {YAW_FACING_FORWARD -OFFSET_YAW_STEP, YAW_FACING_FORWARD + OFFSET_YAW_STEP}},
    [3] = {{OFFSET_AMPLIFIER*0.85, 0, -OFFSET_AMPLIFIER*0.85},  {YAW_FACING_FORWARD -OFFSET_YAW_STEP, YAW_FACING_FORWARD, YAW_FACING_FORWARD + OFFSET_YAW_STEP}},
    [4] = {{OFFSET_AMPLIFIER*1.35, OFFSET_AMPLIFIER*0.45, -OFFSET_AMPLIFIER*0.45, -OFFSET_AMPLIFIER*1.35},  {YAW_FACING_FORWARD -2*OFFSET_YAW_STEP, YAW_FACING_FORWARD -OFFSET_YAW_STEP, YAW_FACING_FORWARD + OFFSET_YAW_STEP, YAW_FACING_FORWARD + 2*OFFSET_YAW_STEP}},
};

local ACTOR_POSITIONS_INWARD = {
    --offsetX
    [1] = {0},
    [2] = {0, 0},
    [3] = {0.2, 0, 0.2},
    [4] = {0.2, 0, 0, 0.2},
};

local SHADOW_OFFSET = 70;
local SHADOW_POSITIONS = {
    [1] = {0},
    [2] = {-SHADOW_OFFSET, SHADOW_OFFSET},
    [3] = {-2*SHADOW_OFFSET, 0, 2*SHADOW_OFFSET},
    [4] = {-3*SHADOW_OFFSET, -SHADOW_OFFSET, SHADOW_OFFSET, 3*SHADOW_OFFSET},
};

--Camera Info
local ZOOM_DISTANCE_CLOSE = 2.7;
local ZOOM_DISTANCE_FAR = 4.2;
local BLEND_DURATION = 1;

--Objects
local OutfitFrame;
local ModelScene, ModelSceneCamera;
local SetList, SetListScrollChild, SetListModel, BlackOverlay;
local LeftTab, ItemModelTab, ItemListTab;

------------------------------------------------------------------
--UI Animation
local VERTICAL_SCROLL = 202;
local animShowSetList = CreateAnimationFrame(0.25);
animShowSetList:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local h = inOutSine(self.total, self.fromHeight, self.toHeight, self.duration);
    if self.total >= self.duration then
        h = self.toHeight;
        self:Hide();
    end
    self.object:SetHeight(h);
    self.frame:SetVerticalScroll(h - VERTICAL_SCROLL);
end)

local function ShowSetList(show)
    if animShowSetList:IsShown() then return false end

    if show then
        animShowSetList.fromHeight = 87;
        animShowSetList.toHeight = 87;  --67
        FadeFrame(BlackOverlay, 0.25, "IN");
        FadeFrame(SetListScrollChild, 0.15, "Forced_IN");
        FadeFrame(ModelScene.TextFrame, 0.15, "OUT");
        FadeFrame(SetListModel, 0.15, "Forced_IN");
    else
        animShowSetList.fromHeight = 87;
        animShowSetList.toHeight = 0.5;
        FadeFrame(BlackOverlay, 0.25, "OUT");
        FadeFrame(SetListScrollChild, 0.25, "OUT");
        FadeFrame(ModelScene.TextFrame, 0.15, "IN");
        FadeFrame(SetListModel, 0.15, "OUT");
    end

    animShowSetList:Show();

    return true
end

---------------------
local animLeftTabEntance = CreateAnimationFrame(0.25);
animLeftTabEntance:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local offset = outSine(self.total, self.fromX, self.toX, self.duration);
    if self.total >= self.duration then
        offset = self.toX;
        self:Hide();
    end
    self.object:SetPoint("TOPLEFT", LeftTab, "TOPLEFT", offset, -44);
end)

local function ShowLeftTab(show)
    if show then
        --animLeftTabEntance.toX = 20;
        FadeFrame(LeftTab, 0.15, "IN");
        SetList:Hide();
    else
        --animLeftTabEntance.toX = -300;
        SetList:Show();
        FadeFrame(LeftTab, 0.25, "OUT");
    end
end

local animNavigationHighlight = CreateAnimationFrame(0.25);
animNavigationHighlight:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local offset = inOutSine(self.total, self.fromX, self.toX, self.duration);
    if self.total >= self.duration then
        offset = self.toX;
        self:Hide();
    end
    self.object:SetPoint("CENTER", self.anchorTo, "LEFT", offset, 0);
end)

local function MoveHighlightTo(index)
    animNavigationHighlight:Hide();
    local _;
    _, animNavigationHighlight.anchorTo, _, animNavigationHighlight.fromX = animNavigationHighlight.object:GetPoint();
    animNavigationHighlight.toX = (index - 1) * 60 + 30.5;
    animNavigationHighlight:Show();
end

-----------------------
----Camera Movement----
-----------------------
local NarciCamera = {};

local ANIMATION_PRESETS = {
    [0] = {0, 0, 0},        --Stand Pause
    [1] = {0, 0, 0.5},
    [2] = {11, 0, 1},       --Shuffle Left
    [3] = {12, 0, 1},       --Shuffle Right
    [4] = {67, 0, 1},       --Wave
};

local BOUNDING_BOX_DISTANCE = 0.35;  --0.25
local STAGE_SIZE = {1.9, 1.6};  --2.7  +y, +z  camera.panningYOffset ~ 43.15    --Height Varies     BE/VE 1.6, Female Troll 1.75
local maxBoundingBoxHeight = STAGE_SIZE[2];
local maxBoundingBoxWidth = (STAGE_SIZE[1] * 2 - BOUNDING_BOX_DISTANCE * 3) / 4;
local modelXSize3D, modelYSize3D = -1, -1;
local modelXSize2D, modelYSize2D = -1, -1;

local function SetActorAnimation(actor, animationIndex)
    --animationIndex ~ Preset
    animationIndex = animationIndex or 0;
    actor:SetAnimationData( unpack( ANIMATION_PRESETS[animationIndex] ) );
end

local animCameraMovement = CreateAnimationFrame(0.25);
animCameraMovement:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local offsetX = inOutSine(self.total, self.fromX, self.toX, self.duration);
    local offsetY = inOutSine(self.total, self.fromY, self.toY, self.duration);
    local actorX = inOutSine(self.total, self.fromActorX, self.toActorX, self.duration);
    local actorY = inOutSine(self.total, self.fromActorY, self.toActorY, self.duration);
    local actorYaw = outSine(self.total, self.fromYaw, self.toYaw, self.duration);
    
    if self.total >= self.duration then
        offsetX = self.toX;
        offsetY = self.toY;
        actorYaw = self.toYaw;
        actorX, actorY = self.toActorX, self.toActorY;
        self:Hide();
    end
    ModelSceneCamera.panningXOffset = offsetX;
    ModelSceneCamera.panningYOffset = offsetY;
    self.actor:MoveTo(actorX, actorY, 0);
    self.actor:SetFacing(actorYaw);
end)

local animActorMovement = CreateAnimationFrame(0.66);
animActorMovement:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local actor2Y = inOutSine(self.total, 0.5, 0, self.duration);
    local actor2X = inOutSine(self.total, self.fromActor2X, self.toActor2X, self.duration);
    
    if self.total >= self.duration then
        actor2X = self.toActor2X;
        self:Hide();
    end

    --self.actor1:MoveTo(-actor2X, 0, 0);
    self.actor2:MoveTo(actor2X, actor2Y, 0);
end)

local function Actor2EnterScene()
    local animActorMovement = animActorMovement;
    animActorMovement:Hide();

    if OutfitFrame:GetActiveTabIndex() == 1 then
        return
    end

    if not animActorMovement.toActor2X then
        animActorMovement.toActor2X = (modelXSize3D + BOUNDING_BOX_DISTANCE)/2;
    end

    local actor2 = animActorMovement.actor2;
    actor2:SetFacing(YAW_FACING_FORWARD);
    SetActorAnimation(actor2, 1);

    animActorMovement.fromActor2X = ModelScene.activeActor:GetPosition();
    animActorMovement:Show();
    NarciCamera.isSecondActorVisible = true;
    
    FadeFrame(actor2, 0.25, "IN");
    actor2.groundShadow:Show();
    --local smoothing = true;
    --ModelScene:ShowGroundShadow(2, smoothing);
end


NarciCamera.executionFrame = animCameraMovement;

NarciCamera.CAMERA_PRESETS = {
  --[i] = {closeUp, down, back, central, hideBackdrop}
    [1] = {true, false, false, false},      --Bust Front
    [2] = {true, true, false, false},       --Lower Body
    [3] = {false, false, false, false},     --Full Body Front
    [4] = {false, false, true, false},      --Full Body Back

    [5] = {false, false, false, true, true},      --Full Body Front Central --Slot fully collected
    [6] = {false, false, false, true, true},      --Full Body Front Central --Slot missing
};

function NarciCamera:IsSameCamera(newIndex)
    if newIndex == self.lastIndex then
        return true
    else
        self.lastIndex = newIndex;
        return false
    end
end

function NarciCamera:GoToCamera(index, transitionDuration)
    local closeUp, down, back, central, hideBackdop = unpack( self.CAMERA_PRESETS[index] );
    
    if self:IsSameCamera(index) then
        return
    end

    local frame = self.executionFrame;
    frame:Hide();

    local ModelScene = ModelScene;
    local ModelSceneCamera = ModelSceneCamera;
    
    local duration;
    local past = frame.total;

    if past == 0 then
        duration = transitionDuration or BLEND_DURATION;
    else
        duration = Clamp(past, 0.66, BLEND_DURATION);
    end

    local actor = frame.actor;
    local toActorX, toActorY;
    local finalZoom, finalYaw;
    local panningOffsets;
    
    if hideBackdop then
        local alpha = ModelScene.GreyBackdrop:GetAlpha();
        if alpha ~= 1 then
            UIFrameFadeIn(ModelScene.GreyBackdrop, 1.5, alpha, 1);
        end
    else
        local alpha = ModelScene.GreyBackdrop:GetAlpha();
        if alpha ~= 0 then
            UIFrameFadeIn(ModelScene.GreyBackdrop, 1.0, alpha, 0);
        end
    end

    if central then
        finalYaw = 0;
        frame.toYaw = YAW_FACING_FORWARD;
        if index == 6 then
            --Outfit fully collected
            toActorX, toActorY = -(modelXSize3D + BOUNDING_BOX_DISTANCE)/2, 0;
            After(0.1, function()
                Actor2EnterScene();
            end)
        else
            toActorX, toActorY = 0, 0;
        end
        panningOffsets = PANNING_OFFSETS_FULL_CENTRAL;
        finalZoom = 5.5;

        closeUp = false;
        if closeUp ~= self.isCloseUp then
            self.isCloseUp = closeUp;
            local Backdrop2 = ModelScene.Backdrop2;
            local Backdrop = ModelScene.Backdrop;
            local BackdropBlur = ModelScene.BackdropBlur;
            local alpha = Backdrop2:GetAlpha();
            UIFrameFadeIn(Backdrop2, 1.5, alpha, 0);
            UIFrameFadeIn(Backdrop, 1.5, alpha, 0);
            UIFrameFadeIn(BackdropBlur, 1.5, 1-alpha, 0);
        end
    else
        finalYaw = 0.52;
        toActorX, toActorY = 0, 0;

        local Backdrop2 = ModelScene.Backdrop2;
        local Backdrop = ModelScene.Backdrop;
        local BackdropBlur = ModelScene.BackdropBlur;
        local updateBackdrop;

        if closeUp ~= self.isCloseUp then
            self.isCloseUp = closeUp;
            updateBackdrop = true;
        end

        if closeUp then
            finalZoom = 2.7;
            if down then
                panningOffsets = PANNING_OFFSETS_LOWER;
            else
                panningOffsets = PANNING_OFFSETS_UPPER;
            end

            if updateBackdrop then
                local alpha = Backdrop2:GetAlpha();
                UIFrameFadeIn(Backdrop2, duration, alpha, 0);
                UIFrameFadeIn(Backdrop, duration, alpha, 0);
                UIFrameFadeIn(BackdropBlur, duration, 1-alpha, 1);
            end
        else
            finalZoom = 4.2;
            panningOffsets = PANNING_OFFSETS_FULL_RIGHT;

            if updateBackdrop then
                local alpha = Backdrop2:GetAlpha();
                UIFrameFadeIn(Backdrop2, 1.5, alpha, 1);
                UIFrameFadeIn(Backdrop, 1.5, alpha, 1);
                UIFrameFadeIn(BackdropBlur, 1.5, 1 - alpha, 0);
            end
        end

        if back ~= frame.lastFacing then
            frame.lastFacing = back;
            local animationIndex;
            if back then
                animationIndex = 2;
            else
                animationIndex = 3;
            end
            SetActorAnimation(actor, animationIndex);
            After(0.65, function()
                SetActorAnimation(actor, 1);
            end)
        end

        if back then
            frame.toYaw = pi + YAW_FACING_FORWARD - finalYaw;
        else
            frame.toYaw = YAW_FACING_FORWARD - finalYaw;
        end

        if self.isSecondActorVisible then
            self.isSecondActorVisible = nil;
            animActorMovement:Hide();
            if self.secondActor then
                FadeFrame(self.secondActor, 0.25, "OUT");
            end
        end
    end

    ModelSceneCamera.customDuration = duration;
    frame.duration = duration;

    local scaleFactor = self.scaleFactor or 1;
    frame.fromX = ModelSceneCamera.panningXOffset;
    frame.fromY = ModelSceneCamera.panningYOffset;
    frame.toX = scaleFactor * panningOffsets[1];
    frame.toY = scaleFactor * panningOffsets[2];
    frame.fromYaw = actor:GetYaw();
    frame.fromYaw = actor:GetYaw();
    frame.fromActorX, frame.fromActorY = actor:GetPosition();
    frame.toActorX, frame.toActorY = toActorX, toActorY;

    frame:Show();
    
    ModelSceneCamera.updateCamera = nil;
    ModelSceneCamera.total = 0;
    ModelSceneCamera.fromZoomDistance = ModelSceneCamera.interpolatedZoomDistance --ModelSceneCamera:GetInterpolatedZoomDistance();
    ModelSceneCamera.toZoomDistance = finalZoom;
    ModelSceneCamera.updateCamera = true;
end


------------------------------------------------------------------
--Set List
local BaseSetData = {};
local VariantSetData = {};

local function HideSetList()
    if ShowSetList(false) then
        SetList.isActive = false;
    end
end

local function RefreshSetData()
    local buttons = SetList.buttons;
    local button;
    local variants;
    local setIDs = {};
    local sort = table.sort;
    local setInfo;
    local baseSetID;
    for i = 1, #buttons do
        button = buttons[i];
        baseSetID = button.setID;
        variants = GetVariantSets(baseSetID);

        wipe(setIDs);
        setInfo = GetSetInfo(baseSetID);
        tinsert(setIDs, {["setID"] = setInfo.setID, ["uiOrder"] = setInfo.uiOrder, ["isCollected"] = setInfo.collected} );

        for j = 1, #variants do
            setInfo = variants[j];
            if setInfo.setID ~= baseSetID then
                tinsert(setIDs, {["setID"] = setInfo.setID, ["uiOrder"] = setInfo.uiOrder, ["isCollected"] = setInfo.collected} );
            end
        end

        sort(setIDs, function(a, b)
            if ( a.uiOrder and b.uiOrder ) then
                return a.uiOrder < b.uiOrder
            end
            return a.setID < b.setID;    
        end);
        button:CreateSubSetIndicator(setIDs);
    end
end

NarciOutfitCardMixin = {};

function NarciOutfitCardMixin:OnClick()
    if self.setID then
        ModelScene:DisplaySet(self.setID);
        HideSetList();
    end
end

function NarciOutfitCardMixin:OnEnter()
    UIFrameFadeIn(self.Name, 0.15, self.Name:GetAlpha(), 1);
    UIFrameFadeIn(self.Label, 0.15, self.Label:GetAlpha(), 0.66);
    UIFrameFadeIn(self.Highlight, 0.25, self.Highlight:GetAlpha(), 1);
end

function NarciOutfitCardMixin:OnLeave()
    UIFrameFadeIn(self.Name, 0.15, self.Name:GetAlpha(), 0.8);
    UIFrameFadeIn(self.Label, 0.15, self.Label:GetAlpha(), 0.46);
    UIFrameFadeIn(self.Highlight, 0.25, self.Highlight:GetAlpha(), 0);
end

function NarciOutfitCardMixin:CreateSubSetIndicator(variantInfo)
    local numVariation = #variantInfo;

    if not self.squares then
        self.squares = {};
    end

    local icon;
    for i = 1, #variantInfo do
        if self.squares[i] then
            icon = self.squares[i];
        else
            icon = self:CreateTexture(nil, "OVERLAY");
            icon:SetSize(8, 8);
            icon:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/OptionSquare-Green", nil, nil, "TRILINEAR");
            tinsert(self.squares, icon);
        end

        if variantInfo[i].isCollected then
            icon:SetTexCoord(0.5, 1, 0, 1);
        else
            icon:SetTexCoord(0, 0.5, 0, 1);
        end
        
        icon:SetPoint("BOTTOM", self, "BOTTOM", 8 * (1 - numVariation)/2 + (i - 1)*8 , 16);
    end
end

local function CreateSetCard(frame)
    local button, model;
    local buttons, models = {}, {};
    local numSet = #BaseSetData;
    local data;
    local sources;
    local setID;

    for i = 1, numSet do
        button = CreateFrame("Button", nil, frame.ScrollChild, "Narci_OutfitCardTemplate");
        tinsert(buttons, button);
        if i == 1 then
            button:SetPoint("TOPLEFT", frame.ScrollChild, "TOPLEFT", 0, 0);
        else
            button:SetPoint("TOPLEFT", buttons[i - 1], "TOPRIGHT", 0, 0);
        end
        data =  BaseSetData[i];
        setID = data.setID;
        button.Name:SetText( GetSetConciseName(data.name) );
        button.Label:SetText(data.label);
        button.setID = setID;
        button.isFavorite = data.favorite;

        model = CreateFrame("DressUpModel", nil, frame.ModelContainer, "Narci_OufitCardModelTemplate");
        tinsert(models, model);
        button.model = model;
        model:SetPoint("BOTTOM", button, "TOP", 0, 1);
        if i <= 8 then
            model:Show()
        end

        sources = GetSetSources(setID);
        model.sources = sources;
    end

    frame.buttons = buttons;
    frame.ModelContainer.models = models;
    
    return numSet
end

function SetCaredModelOffset(x, y, zoom)
    local model = SetListModel.models[1];
    MODEL1 = model;
    if x and y then
        model:SetViewTranslation(x, y);
    end
    if zoom then
        model:SetPortraitZoom(zoom);
        model:MakeCurrentCameraCustom();
    end
end

local function SetList_ToggleList(self)
    if not SetList.isActive then
        if ShowSetList(true) then
            SetList.isActive = true;
        end
    end
end

local function SetList_OnMouseDown(self)
    if ShowSetList(not self.isActive) then
        self.isActive = not self.isActive;
    end
end

local function SetList_OnLoad(self)
    --Acquire All Set Data
    BaseSetData = GetBaseSets();
    local comparison = function(set1, set2)
        --[[
		local groupFavorite1 = set1.favoriteSetID and true;
		local groupFavorite2 = set2.favoriteSetID and true;
		if ( groupFavorite1 ~= groupFavorite2 ) then
			return groupFavorite1;
        end
        --]]
        --[[
		if ( set1.favorite ~= set2.favorite ) then
			return set1.favorite;
        end
        --]]
        local reverseUIOrder = true
		if ( set1.expansionID ~= set2.expansionID ) then
			return set1.expansionID > set2.expansionID;
		end
		if not ignorePatchID then
			if ( set1.patchID ~= set2.patchID ) then
				return set1.patchID > set2.patchID;
			end
		end
		if ( set1.uiOrder ~= set2.uiOrder ) then
			if ( reverseUIOrder ) then
				return set1.uiOrder < set2.uiOrder;
			else
				return set1.uiOrder > set2.uiOrder;
			end
		end
		if reverseUIOrder then
			return set1.setID < set2.setID;
		else
			return set1.setID > set2.setID;
		end
    end

    table.sort(BaseSetData, comparison);
    

    local numButton = CreateSetCard(self);
    RefreshSetData();
    
    --Scroll Frame
    local BUTTON_PER_PAGE = 5;
    local BUTTON_PER_SCROLL = 1;
    local buttonHeight = 171;   --Use the width because it scrolls horizontally
    local totalHeight = floor(numButton * buttonHeight + 0.5);
    local maxScroll = floor((numButton - BUTTON_PER_PAGE) * buttonHeight + 0.5);
    local scrollBar = self.scrollBar;
    scrollBar:SetMinMaxValues(0, max(maxScroll, 0) )
    scrollBar:SetValueStep(0.001);
    self.buttonHeight = totalHeight;
    self.range = maxScroll;

    scrollBar:Disable();
    scrollBar.nextIndex = 0;
    
    local ceil = math.ceil;

    local function UpdateRenderRange(self, buttonIndex)
        if buttonIndex > self.nextIndex then
            local index = ceil(buttonIndex);
            self.nextIndex = index;
            SetListModel.models[index]:Show();
        end
    end

    scrollBar:SetScript("OnValueChanged", function(self, value)
        self:GetParent():SetHorizontalScroll(value);
        local buttonPosition = value/171 + BUTTON_PER_PAGE
        UpdateRenderRange(self, buttonPosition)
        --UpdateInnerShadowStates(self, nil, false);
    end)
    NarciAPI_SmoothScroll_Initialization(self, nil, nil, BUTTON_PER_SCROLL/(numButton), 0.2, nil, SetList_ToggleList);

    self:SetVerticalScroll(-VERTICAL_SCROLL);
end
------------------------------------------------------------------
NarciOutfitNavigationButtonMixin = {}

local NUM_LEVEL = 4;
local navigationStrutcure = {
    [1] = {
        ["name"] = "Outfit",
        ["scriptType"] = 1,
    },
};

for i = 2, NUM_LEVEL do
    navigationStrutcure[i] = {};
end



function NarciOutfitNavigationButtonMixin:OnEnter()
    if self.isCurrent then
        self.Label:SetTextColor(1, 1, 1);
    else
        self.Label:SetTextColor(GRAY_20, GRAY_20, GRAY_20);
    end
end

function NarciOutfitNavigationButtonMixin:ResetTextColor()
    if self.isCurrent then
        self.Label:SetTextColor(GRAY_20, GRAY_20, GRAY_20);
    else
        self.Label:SetTextColor(GRAY_50, GRAY_50, GRAY_50);
    end
end

function NarciOutfitNavigationButtonMixin:OnLeave()
    self:ResetTextColor();
end

function NarciOutfitNavigationButtonMixin:OnClick()

end

function NarciOutfitNavigationButtonMixin:SetLabel(text)
    if text then
        self.Label:SetText( upper(text) );
        self:SetWidth(floor(self.Label:GetWidth() + 0.5) );
        self:ResetTextColor();
    end
end



local function MoveNavigationButtonHighlight(self)
    local buttons = self:GetParent().navigationButtons;
    for _, button in pairs(buttons) do
        button.isOn = nil;
        button.Label:SetTextColor(GRAY_50, GRAY_50, GRAY_50);
    end
    self.isOn = true;
    self.Label:SetTextColor(GRAY_20, GRAY_20, GRAY_20);
    MoveHighlightTo(self.index);
end

local function CreateLeftTabNavigations(frame)
    local function func1(self)
        MoveNavigationButtonHighlight(self);
        self:GetParent().Create:Show();
        self:GetParent().ItemList:Hide();

        NarciCamera:GoToCamera(1);
        OutfitFrame:SetActiveTabIndex(1);
    end

    local function func2(self)
        MoveNavigationButtonHighlight(self);
        self:GetParent().Create:Hide();
        local isOutfitComplete = self:GetParent().ItemList:UpdateSources(true);

        OutfitFrame:SetActiveTabIndex(2);

        local transitionDuration = 0.8;
        if isOutfitComplete then
            NarciCamera:GoToCamera(5, transitionDuration);
        else
            NarciCamera:GoToCamera(6, transitionDuration);
        end
    end

    local function func3(self)
        MoveNavigationButtonHighlight(self);
        self:GetParent().Create:Hide();
        self:GetParent().ItemList:UpdateSources(false);

        OutfitFrame:SetActiveTabIndex(3);

        local transitionDuration = 0.8;
        NarciCamera:GoToCamera(6, transitionDuration);
    end

    local LeftNavigations = {
        --Order = {Button Text, Function}
        [1] = {"Create", func1},
        [2] = {"Collect", func2},
        [3] = {"Share", func3},
    };

    local button;
    local buttons = {};
    for i = 1, #LeftNavigations do
        button = CreateFrame("Button", nil, frame, "Narci_TabNavigationButtonTemplate");
        tinsert(buttons, button);
        if i == 1 then
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
        else
            button:SetPoint("TOPLEFT", buttons[i - 1], "TOPRIGHT", 0, 0);
        end
        button.Label:SetText(LeftNavigations[i][1]);
        button.index = i;
        button:SetScript("OnClick", LeftNavigations[i][2]);
    end

    frame.navigationButtons = buttons;
    frame.Navigation:SetWidth( button:GetWidth() * #LeftNavigations )
end

local function DisplayComponent(sources)
    local appliedSourceIDs = {};
    local slotID;
    local slotButton;
    local sourceInfo;
    local cameraID;
    local itemButtons = ItemModelTab.buttonBySlotID;
    
    for sourceID, isCollected in pairs(sources) do
        sourceInfo = GetSourceInfo(sourceID);
        slotID = GetSlotForInventoryType(sourceInfo.invType);
        slotButton = itemButtons[slotID];
        appliedSourceIDs[slotID] = sourceID;
        --[[
        if slotButton then

            slotButton.sourceID = sourceID;
            slotButton.isFavorite = sourceInfo.isFavorite;
            slotButton.isCollected = sourceInfo.isCollected;
            slotButton.isUsable = true;
            slotButton.visualID = sourceInfo.visualID;
            slotButton:UpdateStatusIcon();

            slotButton:Show();
            slotButton:RefreshSlot();
        end
        --]]
    end

    OutfitFrame.appliedSourceIDs = appliedSourceIDs;

    --[[
    for slotID, button in pairs(itemButtons) do
        if not appliedSourceIDs[slotID] then
            button:Undress();
            button.Label:Show();
            button.LabelBackground:Show();
            button:UpdateStatusIcon();
            button:Show();
            button:RefreshSlot();
        end
    end
    --]]
end


local function SelectActor(actorIndex)
    local actor = ModelScene:GetNarciActor(actorIndex);
    ModelScene:ShowTriggerArea(false);
    ModelScene:FadeOutOtherActors(actorIndex);
    ModelScene.activeActor = actor;
    --Item List
    DisplayComponent(actor.sources);

    SetActorAnimation(actor, 1);
    animCameraMovement.actor = actor;
    animActorMovement.actor1 = actor;
    local actor2Index; 
    if actorIndex == 2 then
        actor2Index = 1;
    else
        actor2Index = 2;
    end
    local actor2 = ModelScene:GetNarciActor(actor2Index);
    --actor2:SetFacing(YAW_FACING_FORWARD);
    ModelScene.secondActor = actor2;
    animActorMovement.actor2 = actor2;
    NarciCamera.secondActor = actor2;
    
    OutfitFrame:SetStructure(2, ModelScene.Name:GetText(), 1);
    ShowLeftTab(true);
    
    local back = false;
    animCameraMovement.lastFacing = back;

    NarciCamera:GoToCamera(1);
    ItemModelTab:ReturnHome();
    OutfitFrame:SetActiveTabIndex(1);
end


------------------------------------------------------------------
NarciOutfitModelSceneActorMixin = {};

function NarciOutfitModelSceneActorMixin:SetAnimationData(animation, variation, animSpeed, timeOffsetSecs)
    if not animation then return end;
    self:SetAnimation(animation, variation, animSpeed, timeOffsetSecs);
    self.animationData = {animation, variation, animSpeed, timeOffsetSecs};
end

function NarciOutfitModelSceneActorMixin:GetAnimationData()
    if self.animationData then
        return unpack(self.animationData)
    end
end

function NarciOutfitModelSceneActorMixin:MoveTo(x, y, z)
    self:SetPosition(x, y, z);
    self.hasMoved = true;
end

function NarciOutfitModelSceneActorMixin:SetFacing(yaw)
    if yaw >  pi then
        yaw = yaw - 2 * pi;
    elseif yaw < - pi then
        yaw = yaw + 2 * pi;
    end
    self:SetYaw(yaw);
    self.hasMoved = true;
end

function NarciOutfitModelSceneActorMixin:OnModelLoaded()
    --/run Narci_Outfit.ModelScene.narciActor[1]:SetModelByFileID(123465)1611191
    --/run
    --if true then return end
    self:SetUseCenterForOrigin(true, true, false);
    self.hasBoundingBox = nil;
    After(0, function()
        local offsetX, offsetY = 0 , 0
        local x, y, z = self:GetPosition();
        local scale = self:GetScale();
        local a, b, c, d, e, f = self:GetActiveBoundingBox();
        local depth, width, height = abs(a - d), abs(b - e), abs(c - f);

        local scaleX, scaleY = 1, 1;
        local scaleModifier = max(-0.3774*depth + 1.3208, 0.75);  --Kultiran 0.8
        print("Model depth: "..depth);

        local maxBoundingBoxWidth = maxBoundingBoxWidth * scaleModifier;
        if width > maxBoundingBoxWidth then
            scaleX = sqrt(maxBoundingBoxWidth / width);
            height = height * scaleX;
        end

        if height > maxBoundingBoxHeight then
            print("Over Height")
            --print("EXP Height: "..maxBoundingBoxHeight)
            scaleY = maxBoundingBoxHeight / height;
            height = maxBoundingBoxHeight;
        end

        local finalScale = scaleX * scaleY;

        depth = depth * finalScale;
        width = width * finalScale;

        
        self.centerOffsetY = depth/finalScale / 4;
        self.modelCenter = y;

        if modelYSize3D == -1 then
            modelYSize3D = depth;
            BOUNDING_BOX_DISTANCE = BOUNDING_BOX_DISTANCE/finalScale/scaleModifier;
        end
        if modelXSize3D == -1 then
            modelXSize3D = width;

            local ModelScene = self:GetParent();
            local L = ModelScene:Project3DPointTo2D(width/2, 0, 0);
            local R = ModelScene:Project3DPointTo2D(-width/2, 0, 0);
            modelXSize2D = abs(L - R);
            self.anchorPoint3D[4]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", L, 20);
            self.anchorPoint3D[5]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", R, 20);
            local _, B = ModelScene:Project3DPointTo2D(0, 0, 0);
            local _, H = ModelScene:Project3DPointTo2D(0, 0, height);
            modelYSize2D = abs(H - B);
        end

        print("Calculated Scale: "..finalScale)
        self:SetScale(finalScale)

        --Show Bounding Box
        if true then return end
        local hideAxis = false;

        print("depth "..depth)
        --x = x - depth/4
        scale = finalScale
        a, d = a + x, d + x;
        b, e = b + y, e + y;
        c, f = c + z, f + z; 
        a, b, c, d, e, f = a*scale, b*scale, c*scale, d*scale, e*scale, f*scale

        local ModelScene = self:GetParent();

        if not self.a1 then
            local a1 = ModelScene:CreateActor();
            a1:SetModelByFileID(397940);
            self.a1 = a1
            if hideAxis then
                a1:Hide();
            end
        end
        self.a1:SetPosition(d, b, c);
        self.bottomright = {d, b, c};

        if not self.b3 then
            local b3 = ModelScene:CreateActor();
            b3:SetModelByFileID(397940);
            self.b3 = b3;
            if hideAxis then
                b3:Hide();
            end
        end
        self.b3:SetPosition(d, e, f);

        if not self.b1 then
            local b1 = ModelScene:CreateActor();
            b1:SetModelByFileID(397940);
            self.b1 = b1;
            if hideAxis then
                b1:Hide();
            end
        end
        self.b1:SetPosition(a, b, f);

        if not self.a2 then
            local a2 = ModelScene:CreateActor();
            a2:SetModelByFileID(397940);
            self.a2 = a2;
            if hideAxis then
                a2:Hide();
            end
        end
        self.a2:SetPosition(a, b, c);
        self.bottomleft = {a, b, c};

        if not self.a3 then
            local a3 = ModelScene:CreateActor();
            a3:SetModelByFileID(397940);
            self.a3 = a3;
            if hideAxis then
                a3:Hide();
            end
        end
        self.a3:SetPosition(d, b, c);

        if not self.a4 then
            local a4 = ModelScene:CreateActor();
            a4:SetModelByFileID(397940);
            self.a4 = a4;
            if hideAxis then
                a4:Hide();
            end
        end
        self.a4:SetPosition(a, e, c);

        if not self.b4 then
            local b4 = ModelScene:CreateActor();
            b4:SetModelByFileID(397940);
            self.b4 = b4;
            if hideAxis then
                b4:Hide();
            end
        end
        self.b4:SetPosition(d, b, f);

        if not self.b2 then
            local b2 = ModelScene:CreateActor();
            b2:SetModelByFileID(397940);
            self.b2 = b2;
            if hideAxis then
                b2:Hide();
            end
        end
        self.b2:SetPosition(a, e, f);

        self.hasBoundingBox = true
    end)
    --/run Narci_Outfit.ModelScene.narciActor[1]:SetModelByFileID(197617)
end

function NarciOutfitModelSceneActorMixin:OnUpdate(elapsed)
    local alpha = self:GetAlpha();
    if alpha < 0.2 then
        alpha = 0;
    end
    self.groundShadow:SetAlpha(alpha);

    --[[
    local arrow = self.arrow;
    if arrow then
        local x0, y0, z0 = self:GetPosition();
        local scale = self:GetScale();
        local yaw = self:GetYaw();
        local ax, ay, az = RotateByYaw( (x0 + arrow.offsetX) , (y0 + arrow.offsetY), (z0 + arrow.offsetZ),   x0, y0, z0,  yaw);
        arrow:SetPosition(ax*2*scale, ay*2*scale, az*2*scale);
        arrow:SetYaw(yaw)
        local x1, y1, z1 = ModelScene:Project3DPointTo2D(ax, ay, az);
        self.anchorPoint3D[1]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", x1, y1);
        self.anchorPoint3D[1]:Show()
    end
    --]]

    if false and not self.hasMoved then return end

    self.t = self.t + elapsed;
    local x, y, z = self:GetPosition();
    local yaw = self:GetYaw();
    if self.t > 0.5 then
        self.t = 0;
        if y ~= self.lastY then
            self.lastY = y;
        elseif yaw ~= self.lastYaw then
            self.lastYaw = yaw;
        else
            self.hasMoved = nil;
            return
        end
    end

    local ModelScene = self:GetParent();
    local scale = self:GetScale();

    if self.centerOffsetY then
        x, y, z = RotateByYaw(x + self.centerOffsetY, y, z,    x, y, z, yaw);
    end

    x = x * scale;
    y = y * scale;
    z = z * scale;

    local modelXSize3D = modelXSize3D * scale;
    local modelYSize3D = modelYSize3D * scale;

    local x1, y1, z1 = ModelScene:Project3DPointTo2D(x, y, z);    --bottom center
    self.anchorPoint3D[1]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", x1, y1);

    local x2, y2, z2 = RotateByYaw((x - modelXSize3D/2) , (y + modelYSize3D/2) , z,    x, y, z,    yaw);   --bottom left
    x2, y2, z2 = ModelScene:Project3DPointTo2D(x2, y2, z2);    --bottomleft
    self.anchorPoint3D[2]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", x2, y2);

    local x3, y3, z3 = RotateByYaw((x - modelXSize3D/2) , (y - modelYSize3D/2) , z,    x, y, z,    yaw);    --bottom right
    x3, y3, z3 = ModelScene:Project3DPointTo2D(x3, y3, z3);
    self.anchorPoint3D[3]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", x3, y3);

    local x4, y4, z4 = RotateByYaw((x + modelXSize3D/2) , (y - modelYSize3D/2) , z,    x, y, z,    yaw);    --top right
    x4, y4, z4 = ModelScene:Project3DPointTo2D(x4, y4, z4);
    self.anchorPoint3D[4]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", x4, y4);

    local x5, y5, z5 = RotateByYaw((x + modelXSize3D/2) , (y + modelYSize3D/2) , z,    x, y, z,    yaw);    --top left
    x5, y5, z5 = ModelScene:Project3DPointTo2D(x5, y5, z5);
    self.anchorPoint3D[5]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", x5, y5);

    local left = min(x2, x3, x4, x5);
    local right = max(x2, x3, x4, x5);
    local top = max(y2, y3, y4, y5);
    local bottom = min(y2, y3, y4, y5);
    local x0 = (left + right)/2;
    self.x0 = x0;
    self.anchorPoint3D[0]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", x0 , y1);


    local shadowWidth = 1.25*max(right - left, top - bottom);
    self.groundShadow:SetSize(shadowWidth, shadowWidth/2);

    
    if false and self.hasBoundingBox then
        local a, b, c = ModelScene:Project3DPointTo2D( unpack(self.bottomleft) );
        self.anchorPoint3D[4]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", a, b);
        a, b, c = ModelScene:Project3DPointTo2D( unpack(self.bottomright) );
        self.anchorPoint3D[5]:SetPoint("CENTER", ModelScene, "BOTTOMLEFT", a, b);
    end
end


NarciOutfitModelSceneMixin = CreateFromMixins(PanningModelSceneMixin);

function NarciOutfitModelSceneMixin:OnLoadNew()
    self:OnLoad()
    local _, _, raceID = UnitRace("player");
    local isWorgen = (raceID == 22);
    if isWorgen then
        self.isWorgen = true;
    end
end

function NarciOutfitModelSceneMixin:OnSizeChanged(width, height)
    self.WorgenPreview:SetWidth(height);
end

function NarciOutfitModelSceneMixin:GetActiveActor()
    return self.activeActor
end

function NarciOutfitModelSceneMixin:GetSecondActor()
    return self.secondActor
end

function NarciOutfitModelSceneMixin:GetNarciActor(index, preload)
    if not self.narciActor then
        self.narciActor = {};
    end

    if not index then return end 

    if not self.narciActor[index] then
        local actor = self:CreateActor(nil, "NarciOutfitModelSceneActorTemplate");

        actor:SetModelByUnit("player");
        actor:SetAnimationBlendOperation(2);    --Smooth Transition
        actor:Undress();
        actor:SetScale(1);
        actor:SetFacing(-pi);
        actor.index = index;
        actor.t = 0;    --Update Timer
        self.narciActor[index] = actor;

        if self.isWorgen then
            local _, inHumanForm = HasAlternateForm();
            actor.inHumanForm = inHumanForm;
            self.inHumanForm = inHumanForm;
            if inHumanForm then
                self.humanActor = actor;
            else
                self.worgenActor = actor;
            end
        end

        --3D Points for Reference
        actor.anchorPoint3D = {};
        for i = 0, 5 do
            local point = self:CreateTexture(nil, "OVERLAY", "NarciModelScene3DPointTemplate");
            actor.anchorPoint3D[i] = point;
            if i == 4 or i == 5 then
                --Visual Center
                point:SetColorTexture(0, 1, 0);
            end
            --point:Show()
        end

        local shadow = self:CreateTexture(nil, "BACKGROUND", "Narci_OutfitModelGroundshadowTemplate", 1);

        actor.groundShadow = shadow;
        shadow:ClearAllPoints();
        shadow:SetPoint("CENTER", actor.anchorPoint3D[0], "CENTER", 0, 0);

        if preload then
            actor:SetAlpha(0);
        end
    end

    return self.narciActor[index]
end

function NarciOutfitModelSceneMixin:GetAlternateActor(forcedHumanForm)
    if self.isWorgen then
        if self.activeActor then
            local goal;
            if forcedHumanForm == nil then
                goal = not self.inHumanForm;
            else
                goal = forcedHumanForm;
                print("Force Changed")
            end

            if goal then
                self.WorgenPreview:Hide();
                --Return Human
                if self.humanActor then
                    self.inHumanForm = true;
                    return self.humanActor;
                else
                    local _, inHumanForm = HasAlternateForm();
                    if inHumanForm then
                        local actor = self:GetNarciActor(11);
                        self.inHumanForm = true;
                        return actor
                    end
                end
            else
                --Return Worgen
                if self.worgenActor then
                    self.inHumanForm = false;
                    return self.worgenActor
                else
                    local _, inHumanForm = HasAlternateForm();
                    if inHumanForm then
                        self.WorgenPreview:Show();
                    else
                        self.WorgenPreview:Hide();
                        self.WorgenPreview.Image:SetTexture(nil);
                        local actor = self:GetNarciActor(11);
                        self.inHumanForm = false;
                        return actor
                    end
                end
            end

        end

    else

    end
end

function NarciOutfitModelSceneMixin:SwitchToAlternateActor(forcedHumanForm)
    local actor = self:GetAlternateActor(forcedHumanForm);
    if actor then
        print("Has Actor")
        WORGENACTOR = actor
        self:DuplicateActor(self.activeActor, actor);
        self.activeActor = actor;
        animCameraMovement.actor = actor;
        animActorMovement.actor1 = actor;
    else
        if self.activeActor then
            self.activeActor:Hide();
            print("Alternate form was not set")
        end
    end
end

function NarciOutfitModelSceneMixin:DuplicateActor(actor, newActor)
    local x, y, z = actor:GetPosition();
    local yaw = actor:GetYaw();
    local animation, variation, speed = actor:GetAnimationData();
    newActor:SetPosition(x, y, z);
    newActor:SetFacing(yaw);
    newActor:SetSheathed( actor:GetSheathed() );
    local newActorAnimation = newActor:GetAnimationData()
    if animation ~= newActorAnimation then
        newActor:SetAnimationData(animation, variation, speed);
    end

    local sourceID;
    local appliedSourceIDs = self:GetParent().appliedSourceIDs;
    for slotID, sourceID in pairs(appliedSourceIDs) do
        local slotSource = newActor:GetSlotTransmogSources(slotID);
        if slotSource ~= sourceID then
            if slotID == 16 then
                newActor:TryOn(sourceID, "MAINHANDSLOT", 0);
            elseif slotID == 17 then
                newActor:TryOn(sourceID, "SECONDARYHANDSLOT", 0);
            else
                newActor:TryOn(sourceID)
            end
        end
    end
    --
    FadeFrame(actor, 0.15, "OUT");
    newActor:Show();
    newActor.groundShadow:Show();
    newActor.groundShadow:SetAlpha(1);
    newActor:SetAlpha(1);

    print("#1 IsHuman: "..tostring(actor.inHumanForm) )
    print("#2 IsHuman: "..tostring(newActor.inHumanForm) )
end

function NarciOutfitModelSceneMixin:GetNarciActorAndFinalPosition(actorIndex)
    local actor = self:GetNarciActor(actorIndex);
    local numVariation = 2;
    local targetOffsetsY = ACTOR_POSITIONS[numVariation][1][2];
    local facings = ACTOR_POSITIONS[numVariation][2];
    actor:SetFacing(YAW_FACING_FORWARD);
    
    return actor, targetOffsetsY
end

function NarciOutfitModelSceneMixin:GetTriggerArea(actorIndex)
    if not self.triggerAreas then
        self.triggerAreas = CreateFrame("Frame", nil, self);
    end

    if not self.triggerAreas[actorIndex] then
        local triggerArea = CreateFrame("Button", nil, self.triggerAreas);
        self.triggerAreas[actorIndex] = triggerArea;
        triggerArea.actorIndex = actorIndex;
        triggerArea.actor = self.narciActor[actorIndex];

        triggerArea:SetHeight(1200);

        triggerArea:SetScript("OnEnter", function(self)
            SetActorAnimation(self.actor, 4);
        end)
        triggerArea:SetScript("OnLeave", function(self)
            SetActorAnimation(self.actor, 0);
        end)
        triggerArea:SetScript("OnClick", function(self)
            SelectActor(self.actorIndex);
        end)

        local tex = triggerArea:CreateTexture(nil, "OVERLAY");
        local r = math.random();
        tex:SetAllPoints(true)
        tex:SetColorTexture(r, 1 - r, 1 - r, 0.5);
        tex:Hide();

        return triggerArea
    else
        return self.triggerAreas[actorIndex]
    end
end

function NarciOutfitModelSceneMixin:UpdateTriggerArea()
    if modelXSize2D == -1 then return end
    local scaleFactor = self:GetParent().scaleFactor or 1;
    local actor, triggerArea;
    for i = 1, #self.narciActor do
        if i > 5 then return end

        actor = self.narciActor[i];
        if actor then
            triggerArea = self:GetTriggerArea(i);
            if actor:IsShown() then
                print(actor.index)
                local center = actor.x0;
                if not self.triggerAreaSize then
                    self.triggerAreaSize = {};
                end
                self.triggerAreaSize[i] = {center - modelXSize2D/2, center + modelXSize2D/2};
                triggerArea:SetWidth(modelXSize2D * scaleFactor);
                triggerArea:SetPoint("BOTTOM", self, "BOTTOMLEFT", center, 80);
                triggerArea:Show();
            else
                triggerArea:Hide();
            end
        end
    end
end

function NarciOutfitModelSceneMixin:ShowTriggerArea(visible)
    if self.triggerAreas then
        self.triggerAreas:SetShown(visible);
    end
end

function NarciOutfitModelSceneMixin:SetLabel(name, label)
    if not name then return end;

    name = GetSetConciseName(name);
    self.Name:SetText(name);
    self.Label:SetText(label);
    self.TextFrame:Show();
end

function NarciOutfitModelSceneMixin:HideGroundShadows()
    if self.shadows then
        for _, shadow in pairs(self.shadows) do
            shadow:Hide();
            shadow:SetAlpha(0);
            if shadow.fadeInfo then
                shadow.fadeInfo.endAlpha = 0;
            end
        end
    end

    NarciCamera.isGroundShadowVisible = nil;
end

--[[
function NarciOutfitModelSceneMixin:ShowGroundShadow(numActor, smoothing)
    if not self.shadows then
        self.shadows = {};
    end
    local shadows = self.shadows;
    local shadow;
    local offsets = SHADOW_POSITIONS[numActor];

    local numActor = 1  --

    for i = 1, numActor do
        shadow = shadows[i];
        if not shadow then
            shadow = self:CreateTexture(nil, "BACKGROUND", "Narci_OutfitModelGroundshadowTemplate");
            tinsert(shadows, shadow);
            local actor = self:GetNarciActor(i);
            actor.groundShadow = shadow;
            shadow:ClearAllPoints();
            shadow:SetPoint("CENTER", self.AnchorPoint0, "CENTER", 0, 0);
            --shadow:SetPoint("BOTTOMRIGHT", self.AnchorPoint2)
        end

        --shadow:SetPoint("BOTTOM", self, "BOTTOM", offsets[i], 60);
        if smoothing then
            FadeFrame(shadow, 1, "IN");
        else
            shadow:Show();
            shadow:SetAlpha(1);
        end
    end

    for i = numActor + 1, #shadows do
        shadows[i]:Hide();
    end

    NarciCamera.isGroundShadowVisible = true;
end
--]]

function NarciOutfitModelSceneMixin:HideOtherActors(numHidden)
    if not numHidden then return end

    if self.narciActor then
        for _, actor in pairs(self.narciActor) do
            if actor.index > numHidden then
                actor:Hide();
                actor.groundShadow:Hide();
            end
        end
    end
end

function NarciOutfitModelSceneMixin:FadeOutOtherActors(actorIndex)
    if self.narciActor then
        for _, actor in pairs(self.narciActor) do
            if actor.index ~= actorIndex then
                FadeFrame(actor, 0.15, "OUT");
            end
        end
    end
    FadeFrame(self.TextFrame, 0.25, "OUT");
end

function NarciOutfitModelSceneMixin:DisplaySet(baseSetID)
    --Set Data
    local setInfo = GetSetInfo(baseSetID);
    self:SetLabel("vengeance" or setInfo.name, setInfo.label);

    local variants = GetVariantSets(baseSetID);
    local setID;
    local setIDs = {};
    local uiOrder = setInfo.uiOrder;
    tinsert(setIDs, {["setID"] = baseSetID, ["uiOrder"] = uiOrder} );

    for i = 1, #variants do
        setInfo = variants[i];
        if setInfo then
            setID = setInfo.setID;
            if setID ~= baseSetID then
                uiOrder = setInfo.uiOrder;
                tinsert(setIDs, {["setID"] = setID, ["uiOrder"] = uiOrder} );
            end
        end
    end

    table.sort(setIDs, function(a, b)
        if ( a.uiOrder and b.uiOrder ) then
            return a.uiOrder > b.uiOrder
        end
    
        return a.setID > b.setID;    
    end);

    local numVariation = #setIDs;
    local sources;
    local actor;
    local offsetsY = ACTOR_POSITIONS[numVariation][1];
    local facings = ACTOR_POSITIONS[numVariation][2];
    local offsetsX = ACTOR_POSITIONS_INWARD[numVariation];

    local sourceInfo, slot, slotSources;

    
    --Actor
    self:HideOtherActors(numVariation);

    local actors = {};
    for i = 1, numVariation do
        --Position
        actor = self:GetNarciActor(i);
        SetActorAnimation(actor, 0);
        actor:MoveTo(offsetsX[i], offsetsY[i], 0);
        actor:SetFacing(facings[i]);
        --print(facings[i])
        actor:SetAlpha(0);
        tinsert(actors, actor);
        actor:Undress();

        --Dress Up
        local collectedSources = {};
        setID = setIDs[i]["setID"];
        sources = GetSetSources(setID);

        for sourceID, isCollected in pairs(sources) do
            actor:TryOn(sourceID);
            sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
            slot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType);
            slotSources = C_TransmogSets.GetSourcesForSlot(setID, slot);

            local isVisualCollected;

            for index, info in pairs(slotSources) do
                if info.isCollected then
                    isVisualCollected = true;
                    collectedSources[info.sourceID] = true;
                    break
                end
            end

            if not isVisualCollected then
                collectedSources[sourceID] = false;
            end
        end

        actor.sources = collectedSources;

        --actor:UndressSlot(1)  --Helm Off
        actor:Show();
        actor.groundShadow:Show();
        ACTOR = actor;
    end

    ModelSceneCamera.interpolatedZoomDistance = 4.5;
    ModelSceneCamera:SnapAllInterpolatedValues();
    After(0, function()
        ModelSceneCamera.interpolatedZoomDistance = 5.5;
        self:ReCalculatePosition(numVariation);
        After(0, function()
            self:UpdateTriggerArea();
        end)
    end)
    
    for _, actor in pairs(actors) do
        UIFrameFadeIn(actor, 0.25, 0, 1);
    end
    --self:ShowGroundShadow(numVariation);
end

function NarciOutfitModelSceneMixin:ReCalculatePosition(numActor)
    local actor;
    local actors = ModelScene.narciActor;
    local modelXSize3D = modelXSize3D;

    for i = 1, #actors do
        actor = actors[i];
        local newCenter
        if i == 1 then
            print(actor.modelCenter)
            newCenter = (modelXSize3D + BOUNDING_BOX_DISTANCE) * (numActor - 1)/2
            actor:MoveTo(newCenter, 0, 0);
            actor.modelCenter = newCenter;
        else
            newCenter = actors[i - 1].modelCenter - modelXSize3D - BOUNDING_BOX_DISTANCE;
            actor.modelCenter = newCenter;
            actor:MoveTo(newCenter, 0, 0 )
        end
    end
end

function NarciOutfitModelSceneMixin:Initialize()
    local CAMERA_DEFAULT_PITCH = 0 -- -pi/40;
    local CAMERA_DEFAULT_YAW = pi/2;
    ModelScene = self;

    self.Name = self.TextFrame.Name;
    self.Label = self.TextFrame.Label;
    self.Name:SetTextColor(GRAY_20, GRAY_20, GRAY_20);
    self.Label:SetTextColor(GRAY_50, GRAY_50, GRAY_50);

    self:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);

    --Camera Setting
    local camera = self:GetActiveCamera();
    camera.maxZoomDistance = 5.5;
    --camera:SetZoomDistance(5.5);
    camera.interpolatedZoomDistance = 5.5;
    camera.zoomInterpolationAmount = 0.06--(ZOOM_DISTANCE_FAR - ZOOM_DISTANCE_CLOSE) / BLEND_DURATION;  --0.15
    ModelSceneCamera = camera;
    self.narciCamera = camera;
    CAMERA = camera;    --global test

    camera:SetYaw(CAMERA_DEFAULT_YAW);
    camera:SetPitch(CAMERA_DEFAULT_PITCH);
    camera.interpolatedYaw = pi/2;
    camera.interpolatedPitch = CAMERA_DEFAULT_PITCH;
    self.defaultYaw = camera:GetYaw();

    camera.panningXOffset = 0 or PANNING_OFFSETS_FULL_CENTRAL[1];
    camera.panningYOffset = PANNING_OFFSETS_FULL_CENTRAL[2];

    self:SetViewInsets(0, 0, 0, 0);


    --Backdrop Reference Points
    local point1 = self:CreateTexture(nil, "OVERLAY", "NarciModelScene3DPointTemplate");
    point1:SetColorTexture(0, 0, 1);
    self.pointFar = point1;

    local point2 = self:CreateTexture(nil, "OVERLAY", "NarciModelScene3DPointTemplate");
    point2:SetColorTexture(1, 0, 0);
    self.pointNear = point2;

    local point3 = self:CreateTexture(nil, "OVERLAY", "NarciModelScene3DPointTemplate");
    point2:SetColorTexture(0, 1, 0);
    self.point3 = point3;

    --[[
    point1:Show();
    point2:Show();
    point3:Show();
    --]]

    self.near = - 2.3;
    self.far = 0;
    function ChangeFar(x)
        self.far = x;
        print("Far: "..x)
    end
    function ChangeNear(x)
        self.near = x;
        print("Near: "..x)
    end

    local Backdrop = self.Backdrop;
    local w, h = self:GetSize();
    w = 1.1*w
    Backdrop:ClearAllPoints();
    Backdrop:SetSize(w, 554/2048* w);
    Backdrop:SetPoint("CENTER", point1, "CENTER", 0, 0);

    local BackdropBlur = self.BackdropBlur;
    BackdropBlur:ClearAllPoints();
    BackdropBlur:ClearAllPoints();
    BackdropBlur:SetSize(w, 554/2048* w);
    BackdropBlur:SetPoint("CENTER", point1, "CENTER", 0, 0);

    local Backdrop2 = self.Backdrop2;
    Backdrop2:ClearAllPoints();
    Backdrop2:SetSize(w, 877/2048*w);
    Backdrop2:SetPoint("BOTTOM", Backdrop, "CENTER", 0, 0);

    local Backdrop3 = self.Backdrop3;
    Backdrop3:ClearAllPoints();
    Backdrop3:SetSize(w, 877/2048*w);
    Backdrop3:SetPoint("BOTTOM", Backdrop, "CENTER", 0, 0);

    Backdrop:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/Backdrop/Ground", nil, nil, "TRILINEAR");
    BackdropBlur:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/Backdrop/GroundBlur", nil, nil, "TRILINEAR");
    Backdrop2:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/Backdrop/Distance", nil, nil, "TRILINEAR");
    Backdrop3:SetTexture("Interface/AddOns/Narcissus/Art/Modules/Outfit/Backdrop/DistanceBlur", nil, nil, "TRILINEAR");
    BackdropBlur:SetAlpha(0);

    --Model Rotation
    self.lastDeltaX = 0;
end

function NarciOutfitModelSceneMixin:OnShow()
    if not self.hasPreloaded then
        self.hasPreloaded = true;
        local preload = true;
        self:GetNarciActor(1, preload);
        self:GetNarciActor(2, preload);

        local ambient = self:CreateActor();
        ambient:SetModelByFileID(1688083);
        ambient:SetScale(0.02);
        ambient:SetAnimation(0, 0, 1);
        ambient:SetDesaturation(1);
        ambient:SetPosition(30, 30, 20);
        ambient:SetAlpha(0.5);

        --[[
        local arrow = self:CreateActor();
        arrow:SetModelByFileID(1346220);
        arrow:SetScale(0.5);--7228
        arrow:SetPosition(0, 0, 0);
        arrow.offsetX, arrow.offsetY, arrow.offsetZ = 1.1, -0.34, 2.78;
        arrow:SetUseCenterForOrigin(0,0,0);
        arrow:SetYaw(YAW_FACING_FORWARD);
        ARROW = arrow
        self.narciActor[1].arrow = arrow;

        function ArrowPos(x, y, z)
            if x then
                arrow.offsetX = x;
            end
            if y then
                arrow.offsetY = y;
            end
            if z then
                arrow.offsetZ = z;
            end
        end
        --]]
    end
    self.lastDeltaX = 0;
end

function NarciOutfitModelSceneMixin:OnUpdate(elapsed)
	if self.activeCamera then
		self.activeCamera:OnUpdate(elapsed);
    end

    local x1, y1 = self:Project3DPointTo2D(0, 0, 0);
    self.pointFar:SetPoint("CENTER", self, "BOTTOMLEFT", x1, y1);
    local x2, y2 = self:Project3DPointTo2D(-2.0, -0.43, 0);
    self.pointNear:SetPoint("CENTER", self, "BOTTOMLEFT", x2, y2);
    local x3, y3 = self:Project3DPointTo2D(0, 9999, 0);
    self.point3:SetPoint("CENTER", self, "BOTTOMLEFT", x3, y3);

    if not self.defaultDistance then
        self.defaultDistance = abs(x2 - x1);
        self.scaleFactor = 1;
    else
        local scale = abs(x1 - x2) / self.defaultDistance / self.scaleFactor;
        self.Backdrop:SetScale( scale );
        self.BackdropBlur:SetScale( scale );
        self.Backdrop2:SetScale( scale );
        self.Backdrop3:SetScale( scale );
    end

    if self.handleActorYaw then
        local deltaX, deltaY = GetScaledCursorDelta();
        --local x, y = GetCursorPosition();
        --local scale = UIParent:GetEffectiveScale();
        --print(x/scale)
        self.lastDeltaX = deltaX;
        if deltaX ~= 0 then
            local facing = self.activeActor:GetYaw() + deltaX * 0.008937;
            self.activeActor:SetFacing(facing);
            if self.secondActor then
                self.secondActor:SetFacing(facing + 3.14);
            end
        end
    elseif self.keyboardMode then
        local deltaX = self.direction * min(5, abs(self.lastDeltaX) + 20 * elapsed);
        self.lastDeltaX = deltaX;
        local facing = self.activeActor:GetYaw() + deltaX * 0.008937;
        self.activeActor:SetFacing(facing);
        if self.secondActor then
            self.secondActor:SetFacing(facing);
        end
    elseif self.handleInertia then
        local lastDeltaX = self.lastDeltaX;
        if lastDeltaX > 0 then
            lastDeltaX = max(0, lastDeltaX - 20 * (elapsed) );
        elseif lastDeltaX < 0 then
            lastDeltaX = min(0, lastDeltaX + 20 * (elapsed) );
        else
            self.handleInertia = false;
        end
        local facing = self.activeActor:GetYaw() + lastDeltaX * 0.008937;
        self.activeActor:SetFacing(facing);
        if self.secondActor then
            self.secondActor:SetFacing(facing);
        end
        self.lastDeltaX = lastDeltaX;
    end
end

function NarciOutfitModelSceneMixin:OnEnter()
    --[[
    local actor = self:GetNarciActor(1);
    actor:SetAnimation(1330, 0, 1);
    --]]
end

function NarciOutfitModelSceneMixin:OnLeave()
    --[[
    local actor = self:GetNarciActor(1);
    actor:SetAnimation(0, 0, 0);
    --]]
end

function NarciOutfitModelSceneMixin:OnMouseUp(button)
    if button == "LeftButton" then
        self.isLeftButtonDown = false;
        self.handleActorYaw = false;
        self.handleInertia = false;
        self.lastDeltaX = 0;
    elseif button == "RightButton" then
        self.isRightButtonDown = false;
        --[[
        local camera = self.narciCamera;
        local modelYaw = self.narciActor[1]:GetYaw();
        local x, y, z = self:GetCameraPosition()
        print(modelYaw - (camera:GetYaw() - self.defaultYaw) );
        print("Panning offsets:", camera.panningXOffset, camera.panningYOffset)
        print("Zoom:", camera:GetZoomDistance());

        
        --]]
        self:UpdateTriggerArea();

        local scale = 1 or UIParent:GetEffectiveScale();
        local xpos = GetCursorPosition() / scale;
        local left = self:GetLeft() / scale;
        xpos = xpos - left;
        print(xpos)
        for actorIndex, area in pairs(self.triggerAreaSize) do    
            if xpos >= area[1] and xpos <= area[2] then
                print(actorIndex);
                return
            end
        end
    end

	if self.activeCamera then
		self.activeCamera:OnMouseUp(button);
	end
end

function NarciOutfitModelSceneMixin:OnMouseDown(button)
    if button == "LeftButton" then
        --self.isLeftButtonDown = true;
        if self:GetActiveActor() then
            self.handleActorYaw = true;
        end
	elseif button == "RightButton" then
        self.isRightButtonDown = true;
    end

	if self.activeCamera then
		self.activeCamera:OnMouseUp(button);
	end
end



------------------------------------------------------------------
NarciOutfitMixin = {};

function NarciOutfitMixin:SetUIElements()
    self.Background:SetColorTexture(GRAY_90, GRAY_90, GRAY_90);    --GRAY_90
    self.ModelScene.GreyBackdrop:SetColorTexture(GRAY_90, GRAY_90, GRAY_90);
    self.SetList.Background:SetColorTexture(GRAY_90, GRAY_90, GRAY_90);
    
    --Assigning animated objects
    BlackOverlay = self.BlackOverlay;
    SetList = self.SetList;
    SetListScrollChild = SetList.ScrollChild;
    SetListModel = SetList.ModelContainer;
    LeftTab = self.LeftTab;

    animShowSetList.object = SetList.Background;
    animShowSetList.frame = SetList;

    --Assigning Scripts
    BlackOverlay:SetScript("OnMouseDown", HideSetList);
    SetList:SetScript("OnMouseDown", SetList_OnMouseDown);

    --Create Navigation Buttons
    local baseFrameLevel = self:GetFrameLevel();
    local button;
    local buttons = {};
    for i = 1, #navigationStrutcure do
        button = CreateFrame("Button", nil, self, "Narci_TextNavigationButtonTemplate");
        tinsert(buttons, button);
        button:SetFrameLevel(baseFrameLevel + 2);
        if i == 1 then
            button:SetPoint("TOPLEFT", self.Inset, "TOPLEFT", 0, 0);
            button:SetScript("OnClick", function()
                ShowLeftTab(false);
                ModelScene:ShowTriggerArea(true);
            end);
        else
            button:SetPoint("LEFT", buttons[i - 1], "RIGHT", 8, 0);
        end
        button.level = i;
    end
    self.navigationButtons = buttons;
    self:UpdateNavigationButtons();


    --Left Tab
        CreateLeftTabNavigations(LeftTab);

        --Create Item Buttons
        ItemModelTab = LeftTab.Create;
        ItemModelTab:Load();

        --Create Item Source Button
        ItemListTab = LeftTab.ItemList;
        ItemListTab:Load();

        animNavigationHighlight.object = LeftTab.Navigation.BackgroundMask;

    --Maximize Button
    local DEFAULT_WIDTH, DEFAULT_HEIGHT = 855, 481;
    self:SetSize(DEFAULT_WIDTH, DEFAULT_HEIGHT);

    local function Maximize(isMaximized)
        if isMaximized then
            local uiScale = UIParent:GetEffectiveScale();
            width0, height0 = UIParent:GetWidth() * uiScale, UIParent:GetHeight() * uiScale;
            local newWidth, newHeight, scaleFactor;

            if width0 / height0 >= 16/9 then
                newHeight = height0;
                newWidth = height0 * 16/9;
                scaleFactor = height0 / DEFAULT_HEIGHT;
            elseif width0 / height0 < 16/9 then
                newWidth = width0;
                newHeight = width * 9/16;
                scaleFactor = width0 / DEFAULT_WIDTH;
            end
            self:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
            self:SetSize(newWidth, newHeight);
            Narci_ItemCollection:Scale(scaleFactor);
            local fontPath, fontHeight = NarciOutfitSearchBox:GetFont();
            if not self.defaultFontHeight then
                self.defaultFontHeight = fontHeight;
            end
            NarciOutfitSearchBox:SetFont(fontPath, self.defaultFontHeight / scaleFactor);
            self.scaleFactor = scaleFactor;
            NarciCamera.scaleFactor = scaleFactor;
            ModelSceneCamera.panningXOffset = ModelSceneCamera.panningXOffset * scaleFactor;
            ModelSceneCamera.panningYOffset = ModelSceneCamera.panningYOffset * scaleFactor;
        else
            self:SetPoint("CENTER", UIParent, "CENTER", 0, 20);
            self:SetSize(DEFAULT_WIDTH, DEFAULT_HEIGHT);
            Narci_ItemCollection:Scale(1);
            local fontPath = NarciOutfitSearchBox:GetFont();
            NarciOutfitSearchBox:SetFont(fontPath, self.defaultFontHeight or 9);
            NarciCamera.scaleFactor = 1;
            ModelSceneCamera.panningXOffset = ModelSceneCamera.panningXOffset / self.scaleFactor;
            ModelSceneCamera.panningYOffset = ModelSceneCamera.panningYOffset / self.scaleFactor;
            self.scaleFactor = 1;
        end

        After(0, function()
            ModelScene:UpdateTriggerArea();
        end)
    end

    self.MaximizeButton.func = Maximize;
end

function NarciOutfitMixin:UpdateNavigationButtons(level)
    level = level or 1;
    local button, info;

    for i = 1, NUM_LEVEL do
        button = self.navigationButtons[i];
        if i < level then
            --Update the buttons to the left
            button.isCurrent = nil;
            button:ResetTextColor();
        else
            info = navigationStrutcure[i];
            button.scriptType = info.scriptType;
            if i == level then
                button.isCurrent = true;
                button:SetLabel(info.name);
                button:Show();
            else
                button:Hide();
                button.isCurrent = nil;
            end
        end
    end
end

function NarciOutfitMixin:SetStructure(level, name, scriptType)
    navigationStrutcure[level] = { ["name"] = name, ["scriptType"] = scriptType};
    self:UpdateNavigationButtons(level);
end

function NarciOutfitMixin:OnLoad()
    self.commandList = {};
    OutfitFrame = self;
    self:SetUIElements();
end

function NarciOutfitMixin:OnClick()

end

function NarciOutfitMixin:GoToCamera(index)
    NarciCamera:GoToCamera(index);
end

function NarciOutfitMixin:ShowSecondActor(isOutfitComplete)
    if not isOutfitComplete then
        Actor2EnterScene();
    else

    end
end

function NarciOutfitMixin:GetActiveTabIndex()
    return self.activeTabIndex or 0
end

function NarciOutfitMixin:SetActiveTabIndex(index)
    self.activeTabIndex = index;
    self.activeCommandList = self.commandList[index] or {};
end

function NarciOutfitMixin:AddCommand(panelIndex, key, func)
    --panelIndex: 1 Create 2
    if type(panelIndex) == "number" then
        panelIndex = {panelIndex};
    end

    for i = 1, #panelIndex do
        local index = panelIndex[i];
        if not self.commandList[index] then
            self.commandList[index] = {};
        end

        if self.commandList[index][key] then
            print("conflict! Panel: #"..index.."  Key: "..key);
        else
            self.commandList[index][key] = func;
        end
    end
end

function NarciOutfitMixin:OnKeyDown(key)
    if key == "ESCAPE" then
        if self.MaximizeButton.isMaximized then
            self:SetPropagateKeyboardInput(false);
            self.MaximizeButton:Click();
        else
            self:SetPropagateKeyboardInput(true);
        end
    elseif key == "X" then
        self.CloseButton:Click();
        self:SetPropagateKeyboardInput(false);
    elseif self.activeCommandList and self.activeCommandList[key] then
        self:SetPropagateKeyboardInput(false);
        local func = self.activeCommandList[key];
        func();
    else
        self:SetPropagateKeyboardInput(true);
    end
end

function NarciOutfitMixin:OnKeyUp(key)
    if key == "Q" or key == "E" then
        if self.ModelScene.activeActor then
            self.ModelScene.keyboardMode = false;
            self.ModelScene.handleInertia = true;
        end
    end
end

function NarciOutfitMixin:Open()
    FadeFrame(self, 0.2, "IN");
end


local function InsertCommandList()
    local function RotateModel(direction)
        --direction: ±1
        ModelScene.keyboardMode = true;
        ModelScene.direction = direction;
    end

    OutfitFrame:AddCommand( {1, 2}, "Q", function()
        RotateModel(-1);
    end);

    OutfitFrame:AddCommand( {1, 2}, "E", function()
        RotateModel(1);
    end);

    local _, _, raceID = UnitRace("player");
    if raceID == 22 then
        OutfitFrame:AddCommand(1, "TAB", function()
            ModelScene:SwitchToAlternateActor();
        end)


        After(2, function()
            local eventFrame = CreateFrame("Frame");
            eventFrame:RegisterEvent("UNIT_MODEL_CHANGED");
        
            eventFrame:SetScript("OnEvent", function(eventFrame, event, ...)
                print(event)
                if event == "UNIT_MODEL_CHANGED" then
                    local unit = ...;
                    if unit == "player" then
                        local _, inHumanForm = HasAlternateForm();
                        if inHumanForm ~= ModelScene.inHumanForm then
                            After(0.2, function()
                            ModelScene:SwitchToAlternateActor(inHumanForm);
                            end)
                            eventFrame:UnregisterEvent("UNIT_MODEL_CHANGED");
                        end
                    end
                end
            end)
        end)
    end
end

---------------------------------------------------------------
local function InitializeCamera()
    local function InterpolateDimension(lastValue, targetValue, amount, elapsed)
        return lastValue and amount and DeltaLerp(lastValue, targetValue, amount, elapsed) or targetValue;
    end

    ModelSceneCamera.total = 0;
    ModelSceneCamera.customDuration = 1;
    ModelSceneCamera.interpolatedYaw = pi/2;
    
    function ModelSceneCamera:UpdateInterpolationTargets(elapsed)
        local yaw, pitch, roll = self:GetDerivedOrientation();
        local targetX, targetY, targetZ = self:GetDerivedTarget();
        local zoomDistance = self:GetDerivedZoomDistance();
        
        self.interpolatedYaw = InterpolateDimension(self.interpolatedYaw, yaw, self.yawInterpolationAmount, elapsed);
        self.interpolatedPitch = InterpolateDimension(self.interpolatedPitch, pitch, self.pitchInterpolationAmount, elapsed);
        self.interpolatedRoll = InterpolateDimension(self.interpolatedRoll, roll, self.rollInterpolationAmount, elapsed);
        
        if self.updateCamera then
            self.total = self.total + elapsed;
            self.interpolatedZoomDistance = inOutSineZero(self.total, self.fromZoomDistance, self.toZoomDistance, self.customDuration);
            --self.interpolatedYaw = inOutSine(self.total, self.fromYaw, self.toYaw, self.customDuration);
            --InterpolateDimension(self.interpolatedYaw, yaw, self.yawInterpolationAmount, elapsed);
            if self.total >= self.customDuration then
                self.updateCamera = nil;
                self.total = 0;
            end
        else
            --self.interpolatedYaw = self.toYaw or self.yaw;
        end
        self.interpolatedTargetX = InterpolateDimension(self.interpolatedTargetX, targetX, self.targetInterpolationAmount, elapsed);
        self.interpolatedTargetY = InterpolateDimension(self.interpolatedTargetY, targetY, self.targetInterpolationAmount, elapsed);
        self.interpolatedTargetZ = InterpolateDimension(self.interpolatedTargetZ, targetZ, self.targetInterpolationAmount, elapsed);
    end

    function ModelSceneCamera:SetYaw(yaw)
        self.yaw = yaw;
        self.toYaw = yaw;
    end

    function ModelSceneCamera:GetYaw()
        return self.yaw or self.toYaw
    end
end


local Initialize = CreateFrame("Frame")
Initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
Initialize:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
    Narci_Outfit.ModelScene:Initialize();
    SetList_OnLoad(SetList);
    InitializeCamera();
    InsertCommandList();
end)

local angleInc = 0.05
function myOnUpdate(self, elapsed)
 	--self.timer = self.timer + elapsed;
 	--if ( self.timer > 0.02 ) then
  		self.hAngle = self.hAngle - angleInc;
  		self.s = sin(self.hAngle);
  		self.c = cos(self.hAngle);
  		self.tex:SetTexCoord(	0.5-self.s, 0.5+self.c,
  					0.5+self.c, 0.5+self.s,
  					0.5-self.c, 0.5-self.s,
  					0.5+self.s, 0.5-self.c);
  		--self.timer = 0;
 	--end
end

function RotateTexture(degrees)
    text = TestTexture;
	local angle = math.rad(degrees)
	local cos, sin = math.cos(angle), math.sin(angle)
	text:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)
end