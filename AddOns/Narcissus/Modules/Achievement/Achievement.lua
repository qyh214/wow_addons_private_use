local _G = _G;
local GetAchievementInfo = GetAchievementInfo;
local GetExpandedButtonHeight;

local TEXTURE_ROOT = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\";
local ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B = 0.557, 0.176, 0.08; --0.7, 0.15, 0.05 
local ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B = 0.129, 0.671, 0.875;

local FadeFrame = NarciAPI_FadeFrame;
local UIFrameFadeIn = UIFrameFadeIn;
local After = C_Timer.After;
local max = math.max;
local sin = math.sin;
local floor = math.floor;
local pi = math.pi;

local function linear(t, b, e, d)
	return (e - b) * t / d + b
end


local function outSine(t, b, e, d)
	return (e - b) * sin(t / d * (pi / 2)) + b
end

local function round(n, digits)
    digits = digits or 0;
    local a = 10 ^ digits;
    return floor(n*a + 0.5)/a
end

--buttonHeight = 84;
--local ACHIEVEMENTUI_CATEGORIESWIDTH = 197;

--Constant
local FEAT_OF_STRENGTH_ID = 81;
local GUILD_FEAT_OF_STRENGTH_ID = 15093;
local GUILD_CATEGORY_ID = 15076;
local LEGACY_ID = 15234;

--Frames
local ACHV;
local NarciCategoryTooltip;
local MountPreview;
local ReturnFrame;
local SummaryFrame;

--private functions
local ClearFadeIn;

local backdrop = {};
backdrop.edgeFile = TEXTURE_ROOT.. "Tooltip-Border-Heavy";
backdrop.tile = true;
backdrop.edgeSize = 16;

---------------------------------------------------------
local CriteriaStructure = {};
CriteriaStructure.buttons = {};
CriteriaStructure.level = {};

function CriteriaStructure:GetNextReturnButton(id)
    local index = 1;
    for i = 1, #self.level + 1 do
        if not self.level[i] then
            index = i;
            break;
        end
    end
    
    self.level[index] = id;
    self.numActiveButtons = index;
    
    for i = 1, #self.buttons do
        self.buttons[i]:SetAlpha(0);
    end

    if not self.buttons[index] then
        local button = CreateFrame("Button", nil, ReturnFrame, "NarciAchievementReturnButtonTemplate");
        button.index = index;
        self.buttons[index] = button;
        if index ~= 1 then
            button:SetPoint("LEFT", self.buttons[index - 1], "RIGHT", 0, 0);
        end
        return button 
    end
    
    return self.buttons[index]
end

function CriteriaStructure:GetNumActiveButtons()
    return self.numActiveButtons or 0
end

function CriteriaStructure:GetCurrentReturnButton()
    local index = #self.level
    return self.buttons[index];
end

function CriteriaStructure:TrimRight(button)
    --Remove this button and all buttons to the right
    local index = button.index;
    for i = index, #self.level do
        self.level[i] = nil;
        self.buttons[i]:Hide();
        print("|cff00DD00Trim: "..i)
    end
end

function CriteriaStructure:GetGroupWidth()
    local width = 0;
    for i = 1, self.numActiveButtons do
        width = width + self.buttons[i]:GetWidth();
    end
    return width
end


local DataProvider = {};

DataProvider.categoryInfoCache = {};

function DataProvider:GetCategoryInfo(categoryID)
    if self.categoryInfoCache[categoryID] then
        return unpack(self.categoryInfoCache[categoryID]);
    else
        local title, parentCategoryID, flags = GetCategoryInfo(categoryID);
        self.categoryInfoCache[categoryID] = {title, parentCategoryID, flags};
        return title, parentCategoryID, flags;
    end
end

local function LocateButtonInSight(id)
    local container, child, scrollBar = AchievementFrameAchievementsContainer, AchievementFrameAchievementsContainerScrollChild, AchievementFrameAchievementsContainerScrollBar;
    local ReturnButton = CriteriaStructure:GetCurrentReturnButton();
    if ReturnButton then
        local achievementButton;
        for index = 1, #container.buttons do
            if container.buttons[index].id == id then
                ReturnButton:AnchorToButton(index);
                print("lock to button #"..index)
                UIFrameFadeIn(ReturnButton.blackOverlayCenter, 0.15, 1, 0);
                UIFrameFadeIn(ReturnButton.blackOverlayTop, 0.1, 1, 0.8);
                UIFrameFadeIn(ReturnButton.blackOverlayBottom, 0.1, 1, 0.8);
                break
            end
        end

        local numActiveButtons = CriteriaStructure:GetNumActiveButtons();print("numStructure: "..numActiveButtons)
        for i = 1, numActiveButtons do
            ReturnButton = CriteriaStructure.buttons[i];
            if ReturnButton:IsShown() then
                UIFrameFadeIn(ReturnButton, 0.15, 0, 1);
            end
        end
    else
        --ReturnFrame:Hide();
        FadeFrame(ReturnFrame, 0.15, "OUT");
    end
end

function DataProvider:LocateAchievementButton(id, category, isComparison, isReturn)
    local includeAll = false;
    local total, completed, incompleted = GetCategoryNumAchievements(category, includeAll);
    --print("Search Size: "..total);

    local slice = 15;   --updates per frame
    local startIndex = 0;
    local numRecursion = 1;

    local container, child, scrollBar = AchievementFrameAchievementsContainer, AchievementFrameAchievementsContainerScrollChild, AchievementFrameAchievementsContainerScrollBar;
    if ( isComparison ) then
        container = AchievementFrameComparisonContainer;
        child = AchievementFrameComparisonContainerScrollChild;
        scrollBar = AchievementFrameComparisonContainerScrollBar;
    end

    local found = false;

    local updateFunc = ACHIEVEMENT_FUNCTIONS.updateFunc;

    local buttons = container.buttons;
    for i = 1, #buttons do
        buttons[i].selected = nil;
        buttons[i]:UnlockHighlight();
        buttons[i].highlight:Hide();
    end

    local function Recursion()
        --print("Recursion #"..numRecursion);
        numRecursion = numRecursion + 1;
        for i = 1 + startIndex, slice + startIndex do
            if i <= total then
                local achievementID = GetAchievementInfo(category, i);
                if achievementID == id then
                    found = true;
                    updateFunc();

                    After(0, function()
                        
                        local buttonPosition = 1;
                        scrollBar:SetValue( (i - buttonPosition)* container.buttonHeight);  --i - 2 show match as the second button
                        After(0, function()
                            
                            local achievementButton;
                            for index = 1, #buttons do
                                achievementButton = buttons[index];

                                if achievementButton.id == id then
                                    achievementButton:Click();
                                    local ReturnButton = CriteriaStructure:GetCurrentReturnButton();
                                    if not ReturnButton then
                                        LocateButtonInSight(id)
                                        print("|cffff0000".."No button")
                                        return
                                    else
                                        print("|cffff0000Current button is button #"..(ReturnButton.index) )
                                    end

                                    local cursorY = ReturnButton:InitializePosition(isReturn);
                                    
                                    if isReturn then
                                        LocateButtonInSight(id);
                                    else
                                        After(0, function()        
                                            for j = 1, #buttons do
                                                achievementButton = buttons[j];
                                                if achievementButton.id == id then
                                                    local top = achievementButton:GetTop();             --Align to the card's Top with offsetY = -12 roughly the center of title bar
                                                    local scrollBarOffset = (cursorY - top + 10);
                                                    local expandedHeight = GetExpandedButtonHeight(achievementButton, id, achievementButton.completed) - 84;     --Compensation, so that large button can be fully displayed
                                                    print("|cffFF2200Expaned Button extra height "..expandedHeight)
                                                    local maxOffsetDown = container:GetTop() - top;
                                                    local effectiveValue = scrollBar:GetValue() + scrollBarOffset + expandedHeight;
                                                    if effectiveValue < 0 then
                                                        effectiveValue = 0;
                                                    end
                                                    scrollBar:SetValue(effectiveValue);
                                                    After(0, function()
                                                        LocateButtonInSight(id);
                                                    end)
                                                    
                                                    break;
                                                end
                                            end
                                        end)
                                    end
                                    
                                    break
                                else
                                    --achievementButton.isSelected = nil;

                                end
                            end

                        end)

                    end)

                    break
                end
            else
                break
            end
        end

        startIndex = startIndex + slice;
        if found or (startIndex + 1 > total) then
            return
        else
            After(0, Recursion);
        end
    end

    Recursion();
end

-----------Copied from Blizzard_AchivementUI.lua----------
local IN_GUILD_VIEW = nil;
local TEXTURES_OFFSET = 0;

local GetAchievementNumCriteria = GetAchievementNumCriteria;
local function AchievementButton_UpdatePlusMinusTexture(button)
	local id = button.id;
	if ( not id ) then
		return;
	end

	local display = false;
	if ( GetAchievementNumCriteria(id) ~= 0 ) then
		display = true;
	elseif ( button.completed and GetPreviousAchievement(id) ) then
		display = true;
	elseif ( not button.completed and GetAchievementGuildRep(id) ) then
		display = true;
	end

	if ( display ) then
		button.plusMinus:Show();
		if ( button.collapsed and button.saturatedStyle ) then
			button.plusMinus:SetTexCoord(0, .5, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.25);
		elseif ( button.collapsed ) then
			button.plusMinus:SetTexCoord(.5, 1, TEXTURES_OFFSET, TEXTURES_OFFSET + 0.25);
		elseif ( button.saturatedStyle ) then
			button.plusMinus:SetTexCoord(0, .5, TEXTURES_OFFSET + 0.25, TEXTURES_OFFSET + 0.50);
		else
			button.plusMinus:SetTexCoord(.5, 1, TEXTURES_OFFSET + 0.25, TEXTURES_OFFSET + 0.50);
		end
	else
		button.plusMinus:Hide();
	end
end
---------------------------------------------------------

--Override default functions
local function AchievementButton_Saturate(self)
	if ( IN_GUILD_VIEW ) then
		self.background:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Parchment");
		self.titleBar:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\TitleBar");
		self.titleBar:SetTexCoord(0, 1, 0, 0.5);
		self.NarciBorderOverlay:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, 1);
		self.shield.points:SetVertexColor(0, 1, 0);
		self.saturatedStyle = "guild";
	else
		self.background:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Parchment");
		if ( self.accountWide ) then
			self.titleBar:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\TitleBar");
			self.titleBar:SetTexCoord(0, 1, 0.5, 1);
			self.NarciBorderOverlay:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B, 1);
			self.saturatedStyle = "account";
		else
			self.titleBar:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\TitleBar");
			self.titleBar:SetTexCoord(0, 1, 0, 0.5);
			self.NarciBorderOverlay:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, 1);
			self.saturatedStyle = "normal";
		end
		self.shield.points:SetVertexColor(1, 0.914, 0.435);     --Modified
	end
	--self.glow:SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	self.reward:SetVertexColor(1, .82, 0);
    self.label:SetVertexColor(1, 1, 1);
	self.description:SetTextColor(0, 0, 0, 1);
    
    
    --Modified
    AchievementButton_UpdatePlusMinusTexture(self);
    self.description:SetShadowColor(0.894, 0.761, 0.408, 1);
    self.description:SetShadowOffset(1, -1);
    self.hiddenDescription:SetTextColor(0, 0, 0, 1);
    self.hiddenDescription:SetShadowColor(0.894, 0.761, 0.408, 1);
    self.hiddenDescription:SetShadowOffset(1, -1);
end

local function AchievementButton_Desaturate(self)
	self.saturatedStyle = nil;
	if ( IN_GUILD_VIEW ) then
		self.background:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Parchment-Desaturated");
		self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
		self.titleBar:SetTexCoord(0, 1, 0.74609375, 0.82421875);
	else
		self.background:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Parchment-Desaturated");
		if ( self.accountWide ) then
			self.titleBar:SetTexture("Interface\\AchievementFrame\\AccountLevel-AchievementHeader");
			self.titleBar:SetTexCoord(0, 1, 0.40625, 0.78125);
		else
			self.titleBar:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders");
			self.titleBar:SetTexCoord(0, 1, 0.91796875, 0.99609375);
		end
	end
	--self.glow:SetVertexColor(.22, .17, .13);
	self.icon:Desaturate();
	self.shield:Desaturate();
	self.shield.points:SetVertexColor(.65, .65, .65);
	self.reward:SetVertexColor(.8, .8, .8);
	self.label:SetVertexColor(.65, .65, .65);
	self.description:SetTextColor(0.88, 0.88, 0.88, 1);
	self.description:SetShadowOffset(1, -1);
    --self:SetBackdropBorderColor(.5, .5, .5);
    
    --Modified
    AchievementButton_UpdatePlusMinusTexture(self);
    self.description:SetShadowColor(0, 0, 0, 1);
    self.hiddenDescription:SetTextColor(0.88, 0.88, 0.88, 1);
    self.hiddenDescription:SetShadowColor(0, 0, 0, 1);
    self.hiddenDescription:SetShadowOffset(1, -1);
    self.NarciBorderOverlay:SetBackdropBorderColor(.35, .35, .35);
end

local delayMouseOver = NarciAPI_CreateAnimationFrame(0.25);
delayMouseOver:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    if self.total >= self.duration then
        self:Hide()
        if self.callBack then
            self.callBack();
        end
    end
end);

local function AchievementButton_OnEnter(self)
    SetCursor("Interface/CURSOR/Item.blp")
    --print(self.index)
    self.highlight:Show();
    if self.reward:IsShown() then
        local itemID = C_AchievementInfo.GetRewardItemID(self.id);
        if itemID then
            MountPreview:SetItem(itemID);
            GameTooltip:SetOwner(self, "ANCHOR_NONE");
            GameTooltip:SetItemByID(itemID);
            GameTooltip:SetPoint("TOPLEFT", ACHV, "TOPRIGHT", 0, 0);
            GameTooltip:Show();
            
            --print("|cffFFDD00item ID:|r "..itemID)
        else
            GameTooltip:Hide();
            if MountPreview:IsShown() then
                MountPreview:FadeOut();
            end
            MountPreview:ClearCallback();
        end
    else
        GameTooltip:Hide();
        if MountPreview:IsShown() then
            MountPreview:FadeOut();
        end
        MountPreview:ClearCallback();
    end
end

------------------------------------------------------
local function ModifyAchievementButton(button)
    button:SetBackdrop(nil);
    local border = CreateFrame("Frame", nil, button, "NarciAchievementBorderOverlayTemplate");
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
    border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
    
    --
	button.Saturate = AchievementButton_Saturate;
	button.Desaturate = AchievementButton_Desaturate;

    --Handlers
    button:SetScript("OnEnter", AchievementButton_OnEnter);
    button:SetScript("OnShow", function(self)
        local button = self;
        if not self.fadeInPlayed then
            button.fadeInPlayed = true;
            button:SetAlpha(0);
            After(button.narciButtonIndex/14, function()
                if button:IsShown() then
                    UIFrameFadeIn(button, 0.15, 0, 1);
                else
                    button:SetAlpha(1);
                    button.fadeInPlayed = true;
                end
            end)
        end
    end)
    

    --Constant objects
    local name = button:GetName();
    button.background:Show();
    button.description:ClearAllPoints();
    button.description:SetPoint("TOP", button, "TOP", 0, -38);
    button.hiddenDescription:ClearAllPoints();
    button.hiddenDescription:SetPoint("TOP", button, "TOP", 0, -38);
    button.icon.frame:SetTexture(TEXTURE_ROOT.."IconFrame");
    local TopTsunami1 = _G[name.."TopTsunami1"];
    if TopTsunami1 then
        TopTsunami1:SetTexture(TEXTURE_ROOT.."Tsunami-Top");
        TopTsunami1:SetTexCoord(0, 1, 0, 1);
        TopTsunami1:SetSize(512, 8);
        TopTsunami1:ClearAllPoints();
        TopTsunami1:SetPoint("TOP", button.titleBar, "BOTTOM", 0, 2);
        TopTsunami1:SetBlendMode("BLEND");
        TopTsunami1:SetAlpha(0.4);
    end
    local BottomTsunami1 = _G[name.."BottomTsunami1"];
    if BottomTsunami1 then
        BottomTsunami1:SetTexture(TEXTURE_ROOT.."Tsunami-Top");
        BottomTsunami1:SetTexCoord(1, 0, 1, 0);
        BottomTsunami1:SetSize(512, 8);
        BottomTsunami1:ClearAllPoints();
        BottomTsunami1:SetPoint("BOTTOM", button, "BOTTOM", 0, 5);
        BottomTsunami1:SetBlendMode("BLEND");
        BottomTsunami1:SetAlpha(0.5);
    end

    local titleBarShadow = button.glow;
    titleBarShadow:ClearAllPoints();
    titleBarShadow:SetPoint("TOPLEFT", button.titleBar, "BOTTOMLEFT", 0, 8);
    titleBarShadow:SetPoint("TOPRIGHT", button.titleBar, "TOPRIGHT", 0, 8);
    titleBarShadow:SetHeight(24);
	titleBarShadow:SetTexCoord(0, 1, 0, 1);
    titleBarShadow:SetTexture(TEXTURE_ROOT.."TitleBarShadow");
    titleBarShadow:SetAlpha(0.8);
    titleBarShadow:SetDrawLayer("ARTWORK", -1);

    local plusMinus = button.plusMinus;
    plusMinus:SetTexture(TEXTURE_ROOT.."PlusMinus");
    plusMinus:SetSize(20, 20); --15
    plusMinus:ClearAllPoints();
    plusMinus:SetPoint("TOPLEFT", button, "TOPLEFT", 68, -6);

    --Shield
    local shieldButton = button.shield;
    local oldShieldIcon = shieldButton.icon;
    local newShieldIcon = button:CreateTexture(nil, "ARTWORK", nil, 2);
    
    oldShieldIcon:Hide();

    hooksecurefunc(oldShieldIcon, "SetTexture", function(object, tex)
        --print(tex);
    end)
    hooksecurefunc(oldShieldIcon, "SetTexCoord", function(object, l, r, t, b)
        newShieldIcon:SetTexCoord(l, r, t, b);
    end);

    newShieldIcon:SetTexture(TEXTURE_ROOT.."Shields");
    newShieldIcon:SetPoint("TOPRIGHT", shieldButton, "TOPRIGHT", 0, -3);
    newShieldIcon:SetSize(68, 68);
    newShieldIcon:SetTexCoord(0, 0.5, 0, 0.5);

    local points = shieldButton.points;

    points:ClearAllPoints();
    points:SetPoint("CENTER", newShieldIcon, "CENTER", 0, 3);
    points:SetTextColor(1, 0.914, 0.435);
    points:SetShadowColor(0, 0, 0);
    points:SetShadowOffset(2, -2);

    local dateCompleted = shieldButton.dateCompleted;
    dateCompleted:ClearAllPoints();
    dateCompleted:SetPoint("TOP", shieldButton, "BOTTOM", -2, 5);
    dateCompleted:SetShadowColor(0, 0, 0);
    dateCompleted:SetShadowOffset(1, -1);

    button.background:SetTexture(TEXTURE_ROOT.."Parchment")
end

local function ShowAchievementCategoryTooltip(self)
    local id = self.categoryID;
    if not id then return end;

    GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, 0);

    if ( id == FEAT_OF_STRENGTH_ID ) then
        NarciCategoryTooltip:ShowTooltip(self, nil, FEAT_OF_STRENGTH_DESCRIPTION);
    elseif ( id == GUILD_FEAT_OF_STRENGTH_ID ) then
        NarciCategoryTooltip:ShowTooltip(self, nil, GUILD_FEAT_OF_STRENGTH_DESCRIPTION);
    elseif id == "summary" then
        NarciCategoryTooltip:Hide();
    elseif (AchievementFrame.selectedTab == 1 or AchievementFrame.selectedTab == 2 ) then
        NarciCategoryTooltip:ShowProgress(self, id);
    else
        button.showTooltipFunc = nil;
    end
	
	GameTooltip:Show();
end

local function CategoryButton_OnLeave()
    GameTooltip:SetMinimumWidth(0, false);
    GameTooltip:Hide();
    NarciCategoryTooltip:Hide();
end

local function ModifyCategoryButton()
    local scrollFrame = AchievementFrameCategoriesContainer;
    if scrollFrame then
        local buttons = scrollFrame.buttons;
        local button;
        local background, highlight;
        for i = 1, #buttons do
            button = buttons[i];

            button:SetScript("OnMouseDown", function(self)
                self.label:SetScale(0.975);
            end)
            button:SetScript("OnMouseUp", function(self)
                self.label:SetScale(1);
            end)
            button:SetScript("OnEnter", ShowAchievementCategoryTooltip);
            button:SetScript("OnLeave", CategoryButton_OnLeave);
            
            --[[
            background = button.background;
            background:SetTexture(nil);
            button:SetNormalTexture(TEXTURE_ROOT.."CategoryButton");
            local normalTexture = button:GetNormalTexture();
            normalTexture:SetTexture(TEXTURE_ROOT.."CategoryButton");
            normalTexture:SetTexCoord(0, 1, 0, 0.5);
            normalTexture:ClearAllPoints();
            normalTexture:SetPoint("LEFT", button, "LEFT", -12, -2);
            normalTexture:SetPoint("RIGHT", button, "RIGHT", 12, -2);
            normalTexture:SetHeight(53);
            button.narciNormalTexture = normalTexture;

            local highlight = button:GetHighlightTexture();
            highlight:SetTexture(TEXTURE_ROOT.."CategoryButton-Highlight");
            highlight:SetTexCoord(0, 1, 0, 1);
            highlight:ClearAllPoints();
            highlight:SetPoint("TOPLEFT", normalTexture, "TOPLEFT", 0, 0);
            highlight:SetPoint("BOTTOMRIGHT", normalTexture, "BOTTOMRIGHT", 0, 0);
            
            button:SetPushedTexture(TEXTURE_ROOT.."CategoryButton")
            local pushedTexture = button:GetPushedTexture();
            pushedTexture:SetTexture(TEXTURE_ROOT.."CategoryButton");
            pushedTexture:SetTexCoord(0, 1, 0.5, 1);
            pushedTexture:ClearAllPoints();
            pushedTexture:SetPoint("TOPLEFT", normalTexture, "TOPLEFT", 0, 0);
            pushedTexture:SetPoint("BOTTOMRIGHT", normalTexture, "BOTTOMRIGHT", 0, 0);
            --]]
        end

        --[[
        local categoryBackground = AchievementFrameCategoriesBG;
        if categoryBackground then
            categoryBackground:SetTexture(TEXTURE_ROOT.."CategoryBackground");
        end

        local waterMark = AchievementFrameWaterMark;
        if waterMark then
            waterMark:SetTexCoord(0, 1, 0, 1);
            waterMark:SetSize(190, 190);
        end
        --]]
        
        local scrollBar = AchievementFrameCategoriesContainerScrollBar;
        --[[
        if scrollBar then
            scrollBar.trackBG:SetAlpha(0.35);
            local leftShadow = scrollBar:CreateTexture(nil, "BACKGROUND");
            leftShadow:SetPoint("TOPLEFT", scrollBar.ScrollBarTop, "TOPLEFT", -8, 0);
            leftShadow:SetPoint("BOTTOMRIGHT", scrollBar.ScrollBarBottom, "BOTTOMLEFT", 4, 0);
            leftShadow:SetColorTexture(0, 0, 0);
            leftShadow:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 0, 0, 0, 0.8);

            hooksecurefunc(scrollBar, "Show", function()
                waterMark:SetTexCoord(0, 1, 0, 1);
                waterMark:SetSize(190, 190);
            end)
            hooksecurefunc(scrollBar, "Hide", function()
                waterMark:SetTexCoord(0, 1, 0, 1);
                waterMark:SetSize(190, 190);
            end)
        end
        --]]

        scrollFrame:SetScript("OnLeave", function(self)
            if not self:IsMouseOver() then
                NarciCategoryTooltip:Hide();
                NarciCategoryTooltip:SetAlpha(0);
            end
        end)

        scrollBar:SetScript("OnEnter", function(self)
            NarciCategoryTooltip:Hide();
            NarciCategoryTooltip:SetAlpha(0);
        end)
    end
end

local function AddSmoothScroll()
    NarciAPI_ApplySmoothScrollToBlizzardUI(AchievementFrameAchievementsContainer, 1, 0.24);
    NarciAPI_ApplySmoothScrollToBlizzardUI(AchievementFrameCategoriesContainer, 2, 0.2, function()
        NarciCategoryTooltip:SetScrolling();
    end);
end

local function OverrideTexturesToLoad()
    oldTextures = {"AchievementFrameHeaderLeft", "AchievementFrameHeaderRight", "AchievementFrameHeaderPointBorder"};

    for i = 1, #oldTextures do
        local tex = _G[oldTextures[i]];
        if tex then
            tex:SetTexture(nil);
        end
    end

    ACHIEVEMENT_TEXTURES_TO_LOAD = 	{
    {
		name="AchievementFrameAchievementsBackground",
		file= TEXTURE_ROOT.. "AchievementBackground",
	},
	{
		name="AchievementFrameSummaryBackground",
		file= TEXTURE_ROOT.. "AchievementBackground",
	},
	{
		name="AchievementFrameComparisonBackground",
		file= TEXTURE_ROOT.. "AchievementBackground",
    },
    
    --[[
	{
		name="AchievementFrameCategoriesBG",
		file= TEXTURE_ROOT.. "CategoryBackground",
    },
    --]]
    
    };
end

local function ModifySummary()
    local name = "AchievementFrameSummary";
    if not _G[name] then
        print("Narcissus - Couldn't find achievement summary");
        return
    end

    local achievement = _G[name.."Achievements"];
    local categories = _G[name.."Categories"];

    categories:ClearAllPoints();
    categories:SetPoint("TOPLEFT", achievement, "BOTTOMLEFT", 0, 0);
    categories:SetPoint("TOPRIGHT", achievement, "BOTTOMRIGHT", 0, 0);
end

local function AchievementComparisonPlayerButton_Saturate(self)
	--local name = self:GetName();
	if ( IN_GUILD_VIEW ) then
		--self.background:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal");
        self.titleBar:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\TitleBar");
        self.titleBar:SetTexCoord(0, 1, 0, 0.5);
		self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
		self.shield.points:SetVertexColor(0, 1, 0);
		self.saturatedStyle = "guild";
	else
		--self.background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal");
		self.shield.points:SetVertexColor(1, 1, 1);
		if ( self.accountWide ) then
			self.titleBar:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\TitleBar");
			self.titleBar:SetTexCoord(0, 1, 0.5, 1);
			self:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B, ACHIEVEMENTUI_BLUEBORDER_A);
			self.saturatedStyle = "account";
		else
			self.titleBar:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\TitleBar");
			self.titleBar:SetTexCoord(0, 1, 0, 0.5);
			self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
			self.saturatedStyle = "normal";
		end
	end
	if ( self.isSummary ) then
		if ( self.accountWide ) then
			self.titleBar:SetAlpha(1);
		else
			self.titleBar:SetAlpha(1);  --0.5
		end
	end
	self.glow:SetVertexColor(1.0, 1.0, 1.0);
	self.icon:Saturate();
	self.shield:Saturate();
	--self.label:SetVertexColor(1, 1, 1);
	--self.description:SetTextColor(0, 0, 0, 1);
	--self.description:SetShadowOffset(0, 0);
end

local function rotateTexture(tex, radian)
    if radian > 1.57 and radian < 1.571 then
        radian = 1.57;
    end

	local ag = tex.ag;
	if not ag then
		ag = tex:CreateAnimationGroup();
	end
	local a1 = ag.a1;
	if not a1 then
		a1 = ag:CreateAnimation("Rotation");
		ag.a1 = a1;
	end
	ag:Stop();
	a1:SetRadians(radian);
	a1:SetOrigin("CENTER", 0 ,0);
	a1:SetOrder(1);
	a1:SetDuration(0);
	local a2 = ag.a2;
	if not a2 then
		a2 = ag:CreateAnimation("Rotation");
		ag.a2 = a2;
	end
	a2:SetRadians(0);
	a2:SetOrigin("CENTER", 0 ,0); 
	a2:SetOrder(2);
	a2:SetDuration(1);
	ag:Play();
	ag:Pause();

	tex.ag = ag;
end

local animProgressHalfRing = NarciAPI_CreateAnimationFrame(0.5);
animProgressHalfRing:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local radian = outSine(self.total, pi, self.endRadian, self.duration);
    if self.total >= self.duration then
        self:Hide();
        radian = self.endRadian;
    end
    print(radian)
    rotateTexture(self.object, radian);
end)

local animProgressFullRing = NarciAPI_CreateAnimationFrame(0.5);
animProgressFullRing:SetScript("OnShow", function(self)
    rotateTexture(self.object1, -pi);
    rotateTexture(self.object2, pi);
end)

animProgressFullRing:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local radian1 = linear(self.total, pi, 0, 0.4);
    if self.total < 0.4 then
        rotateTexture(self.object1, radian1);
    else
        radian1 = 0;
        local radian2 = outSine(self.total - 0.4, pi, self.endRadian, self.duration - 0.4);
        if self.total >= self.duration then
            self:Hide();
            radian2 = self.endRadian;
        end
        rotateTexture(self.object1, radian1);
        rotateTexture(self.object2, radian2);
        print(radian2)
    end
end)

local function CreateSummaryButtons()
    SummaryFrame = CreateFrame("Frame", nil, AchievementFrame);
    SummaryFrame:SetPoint("TOPLEFT", AchievementFrameSummaryAchievements, "TOPLEFT", 0 , 0);
    SummaryFrame:SetPoint("BOTTOMRIGHT", AchievementFrameSummaryAchievements, "BOTTOMRIGHT", 0 , 0);
    SummaryFrame:Hide();
    
    local label = SummaryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium");
    SummaryFrame.label = label;
    label:SetTextColor(252/255, 218/255, 157/255);
    label:SetText("Mythic: Vexiona");
    label:SetPoint("CENTER", SummaryFrame, "CENTER", 0, -17);

    local description = SummaryFrame:CreateFontString(nil, "OVERLAY", "AchievementDescriptionFont");
    SummaryFrame.description = description;
    description:SetTextColor(0.8, 0.8, 0.8);
    description:SetText("This is an achievement decription.")
    description:SetPoint("TOP", label, "BOTTOM", 0, -11);

    local title = SummaryFrame:CreateFontString(nil, "OVERLAY", "AchievementDescriptionFont");
    title:SetPoint("CENTER", SummaryFrame, "TOP", 0, -6);
    title:SetText( string.upper(LATEST_UNLOCKED_ACHIEVEMENTS) );
    title:SetTextColor(0.8, 0.8, 0.8);
    title:SetShadowOffset(0, -2);

    local buttons = {};

    local function OnEnter(self)
        label:SetText(self.name);
        description:SetText(self.description);
    end

    for i = 1, 5 do
        local button = CreateFrame("Button", nil, SummaryFrame, "NarciAchievementSummaryButton");
        tinsert(buttons, button);
        
        if i == 1 then
            button:SetPoint("CENTER", SummaryFrame, "CENTER", -156, 33);
        else
            button:SetPoint("CENTER", buttons[i - 1], "CENTER", 78.5, 0);
        end

        button:SetScript("OnEnter", OnEnter);
    end



    SummaryFrame.buttons = buttons;
end

function UpdateSummaryButtons()
    local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy;
    local achievementIDs = { GetLatestCompletedAchievements() };
    local button;
    for i = 1, #achievementIDs do
        button = SummaryFrame.buttons[i];
        id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementIDs[i]);
        button.icon:SetTexture(icon);
        button.name = name;
        button.id = id;
        button.description = description;
    end
end

local function CreateSummaryStatusBar()
    UpdateSummaryButtons()
    --
    local categories = GetCategoryList();
    local id;
    local name, parentCategoryID;
    local parentCategories = {};
    local legacys = { LEGACY_ID };
    local feats = { FEAT_OF_STRENGTH_ID };
    local sortedCategories = {};

    for i = 1, #categories do
        id = categories[i];
		name, parentCategoryID = GetCategoryInfo(id);
		if ( parentCategoryID == -1 and id ~= 15301 ) then
            tinsert(parentCategories, { ["id"] = id, ["name"] = name, });
            sortedCategories[parentCategoryID] = {};
        elseif parentCategoryID == LEGACY_ID then
            tinsert(legacys, id);
        elseif parentCategoryID == FEAT_OF_STRENGTH_ID then
            tinsert(feats, id);
        else
            if not sortedCategories[parentCategoryID] then
                sortedCategories[parentCategoryID] = {};
            end
            print("parentID: "..parentCategoryID)
            tinsert(sortedCategories[parentCategoryID], id);
		end
	end


    local title = SummaryFrame:CreateFontString(nil, "OVERLAY", "AchievementDescriptionFont");
    title:SetPoint("TOP", SummaryFrame, "BOTTOM", 0, -5);
    title:SetText( string.upper(ACHIEVEMENT_CATEGORY_PROGRESS) );
    title:SetTextColor(0.8, 0.8, 0.8);
    title:SetShadowOffset(0, -2);

    --
    AchievementFrameSummaryCategories:Hide();
    local bars = {};
    local bar;
    for i = 1, 10 do
        bar = CreateFrame("Button", nil, SummaryFrame, "NarciAchievementProgressBar");
        tinsert(bars, bar);
        if i == 1 then
            bar:SetPoint("TOP", SummaryFrame, "BOTTOM", 8, -47);
        elseif i == 6 then
            bar:SetPoint("LEFT", bars[1], "RIGHT", 16, 0);
        else
            bar:SetPoint("TOP", bars[i - 1], "BOTTOM", 0, -18);
        end
        bar.barFill:SetVertexColor(124/255, 114/255, 91/255);  --SetVertexColor(151/255, 138/255, 111/255);
        local categoryID = parentCategories[i].id;
        bar.label:SetText( parentCategories[i].name );
        bar.categoryID = categoryID;
        bar.subCategories = sortedCategories[categoryID];
        bar.label:SetShadowOffset(1, -1);
        bar.percent:SetShadowOffset(1, -1);
        bar:Update();
    end

    --Ring
    local function UpdateRing(self)
        animProgressHalfRing:Hide();
        animProgressFullRing:Hide();

        local numAchievements, numCompleted = GetCategoryNumAchievements(-1);   --ACHIEVEMENT_COMPARISON_SUMMARY_ID
        self.current:SetText(numCompleted);
        self.total:SetText(numAchievements);
        local percentage = numCompleted / numAchievements;
        
        if percentage <= 0.5 then
            self.leftFill:Hide();
            animProgressHalfRing.endRadian =  pi - pi * 2 * percentage;
            animProgressHalfRing:Show();
        else
            self.leftFill:Show();
            print("duration:"..percentage)
            animProgressFullRing.duration = percentage;
            animProgressFullRing.endRadian = pi - pi * 2 * (percentage - 0.5);
            animProgressFullRing:Show();
        end
    end

    local ring = CreateFrame("Frame", "NarciAchievementProgressRing", SummaryFrame, "NarciAchievementProgressRingTemplate");
    ring:SetPoint("CENTER", SummaryFrame, "BOTTOM", -154, -106);
    animProgressHalfRing.object = ring.rightMask;
    animProgressFullRing.object1 = ring.rightMask;
    animProgressFullRing.object2 = ring.leftMask;

    ring.Update = UpdateRing;

    ring:SetScript("OnShow", UpdateRing);

    local numLegacy = 0;
    for i = 1, #legacys do
        numAchievements, numCompleted = GetCategoryNumAchievements(legacys[i]);
        numLegacy = numLegacy + numCompleted;
    end
    ring.legacy:SetText(numLegacy);

    local numFeats = 0;
    for i = 1, #feats do
        numAchievements, numCompleted = GetCategoryNumAchievements(feats[i]);
        numFeats = numFeats + numCompleted;
    end
    ring.feats:SetText(numFeats);
end

local function ModifyRecentAchievement()
    ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS = 5;
    AchievementFrameSummary_UpdateAchievements();

    local buttons = AchievementFrameSummaryAchievements.buttons;
    local button;
    AchievementFrameSummaryAchievements:Hide();
    for i = 1, #buttons do
        button = buttons[i];
        --[[
        
        --button.background:SetTexture(TEXTURE_ROOT.."Parchment");
        button.background:SetTexture(nil);
        button:SetBackdrop(nil);
        --button.shield:Hide();
       
        button.shield.icon:SetTexture(TEXTURE_ROOT.."Shields");
        button.icon.frame:SetTexture(TEXTURE_ROOT.."Progressive-IconBorder");
        button.icon.frame:SetSize(50, 50)
        button.icon.frame:SetTexCoord(0, 1, 0, 1);
        
        button.titleBar:Hide();
        button.label:SetVertexColor(1, 0.82, 0);
        button.label:SetShadowOffset(0, 0);
        button.label:ClearAllPoints();
        button.label:SetSize(340, 16);
        button.label:SetShadowOffset(1, -1);
        button.label:SetPoint("LEFT", button, "LEFT", 54, 7);
        button.label:SetJustifyH("LEFT");
        button.description:SetSize(366, 16);
        button.description:SetTextColor(0.88, 0.88, 0.88, 1);
        button.description:SetShadowOffset(1, -1);
        button.description:ClearAllPoints();
        button.description:SetPoint("LEFT", button, "BOTTOMLEFT", 54, 14);
        button.description:SetJustifyH("LEFT");
        button.glow:Hide();
        
        button.Saturate = AchievementComparisonPlayerButton_Saturate;
        button:Saturate();
        --]]

        button:Hide();
    end

    
    AchievementFrameSummaryAchievementsHeader:Hide()
    AchievementFrameSummaryCategoriesHeader:Hide()

    local primaryBar = AchievementFrameSummaryCategoriesStatusBar;
    primaryBar:SetPoint("TOP", AchievementFrameSummaryCategoriesHeader, "BOTTOM", 0, -24)
    CreateSummaryButtons();
    CreateSummaryStatusBar();
end

local function ReskinFrame()
    local name = "AchievementFrame";
    local headerName = name.."Header";
    --_G[headerName.."Left"]:SetTexture(TEXTURE_ROOT.."Header");
    --_G[headerName.."Right"]:SetTexture(TEXTURE_ROOT.."Header");
    --_G[headerName.."PointBorder"]:SetTexture(TEXTURE_ROOT.."Header");
    _G[headerName]:Hide();

    local frame = AchievementFrame;

    frame:SetBackdrop(nil);
    local border = CreateFrame("Frame", nil, frame, "NarciWoodenBorderOverlay");
    border:SetPoint("CENTER", frame, "CENTER", 0 ,0);

    local metalBorders = {"MetalBorderTop", "MetalBorderTopLeft", "MetalBorderTopRight", "MetalBorderBottom", "MetalBorderBottomLeft", "MetalBorderBottomRight", "MetalBorderLeft", "MetalBorderRight"};
    for i = 1, #metalBorders do
        _G[name..metalBorders[i]]:Hide();
    end

    local woodBorders = {"WoodBorderTopLeft", "WoodBorderTopRight", "WoodBorderBottomLeft", "WoodBorderBottomRight"};
    for i = 1, #woodBorders do
        _G[name..woodBorders[i]]:Hide();
    end

    local searchBox = frame.searchBox;
    searchBox:ClearAllPoints();
    searchBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -114, 10);
    searchBox:SetWidth(113);
    searchBox:SetBackdrop(nil);
    searchBox.Left:Hide();
    searchBox.Right:Hide();
    searchBox.Middle:Hide();

    local filter = _G[name.."FilterDropDown"];
    if filter then
        filter:ClearAllPoints();
        filter:SetPoint("TOPLEFT", frame, "TOPLEFT", 121, 7);
        filter:SetWidth(113);
    end

    local headerPoints = _G[name.."HeaderPoints"];
    if headerPoints then
        headerPoints:ClearAllPoints();
        headerPoints:SetParent(border);
        headerPoints:SetPoint("CENTER", border, "TOP", 0, -9);
        headerPoints:SetDrawLayer("OVERLAY", 2);
    end

    local miniShield = _G[name.."HeaderShield"];
    if miniShield then
        miniShield:SetParent(border);
        miniShield:SetSize(18, 18);
        miniShield:SetDrawLayer("OVERLAY", 2);
    end

    local title = _G[name.."HeaderTitle"];
    if title then
        title:SetParent(border);
        title:ClearAllPoints();
        title:SetPoint("BOTTOM", border, "TOP", 0, 4);
        title:SetDrawLayer("OVERLAY", 2);
    end
    
    --Tabs
    local frameLevel = frame:GetFrameLevel();
    for i = 1, 3 do
        local tab = _G[name.."Tab"..i];
        if tab then
            tab:SetFrameLevel(frameLevel);
        end
    end

    --Borders
    local categories = _G[name.."Categories"];
    if categories then
        --categories:SetBackdrop(backdrop);
        --categories:SetBackdropBorderColor(ACHIEVEMENTUI_GOLDBORDER_R, ACHIEVEMENTUI_GOLDBORDER_G, ACHIEVEMENTUI_GOLDBORDER_B, ACHIEVEMENTUI_GOLDBORDER_A);
    end

    OverrideTexturesToLoad();
    ModifySummary();
    ModifyRecentAchievement();
end

local function OverrideFunctions()
    local FEAT_OF_STRENGTH_ID = 81;
    local GUILD_FEAT_OF_STRENGTH_ID = 15093;
    local GUILD_CATEGORY_ID = 15076;

    --This will also solve an intrinsic performance issue caused by calling AchievementFrame_GetCategoryTotalNumAchievements in a loop
    function AchievementFrameCategories_DisplayButton (button, element)
        if ( not element ) then
            button.element = nil;
            button:Hide();
            return;
        end
        
        button:Show();
        if ( type(element.parent) == "number" ) then
            button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 25);
            --button.label:SetFontObject("GameFontHighlight");
            button.parentID = element.parent;
            button.background:SetVertexColor(0.6, 0.6, 0.6);
            --button.narciNormalTexture:SetVertexColor(0.6, 0.6, 0.6);
            button.label:SetTextColor(0.88, 0.88, 0.88);
        else
            button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 10);
            --button.label:SetFontObject("GameFontNormal");
            button.parentID = element.parent;
            button.background:SetVertexColor(1, 1, 1);
            --button.narciNormalTexture:SetVertexColor(1, 1, 1);
            button.label:SetTextColor(1, 0.82, 0);
        end
    
        local categoryName, parentID, flags;
        local numAchievements, numCompleted;
    
        local id = element.id;
    

        -- kind of janky    ← This note was left by the people who made AchievementUI in the first place.

        if ( id == "summary" ) then
            categoryName = ACHIEVEMENT_SUMMARY_CATEGORY;
            numAchievements, numCompleted = 1, 2 --GetNumCompletedAchievements(IN_GUILD_VIEW);
            --ClearFadeIn();
        else
            categoryName, parentID, flags = DataProvider:GetCategoryInfo(id); --"Test"..id, 1;
            numAchievements, numCompleted = 1, 2 --AchievementFrame_GetCategoryTotalNumAchievements(id, true);
        end
        button.label:SetText(categoryName);
        button.categoryID = id;
        button.flags = flags;
        button.element = element;
    
        -- For the tooltip
        button.name = categoryName;
        --[[
        if ( id == FEAT_OF_STRENGTH_ID ) then
            -- This is the feat of strength category since it's sorted to the end of the list
            button.text = FEAT_OF_STRENGTH_DESCRIPTION;
            button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
        elseif ( id == GUILD_FEAT_OF_STRENGTH_ID ) then
            button.text = GUILD_FEAT_OF_STRENGTH_DESCRIPTION;
            button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
        elseif ( AchievementFrame.selectedTab == 1 or AchievementFrame.selectedTab == 2 ) then
            button.text = nil;
            button.numAchievements = numAchievements;
            button.numCompleted = numCompleted;
            button.numCompletedText = numCompleted.."/"..numAchievements;
            button.showTooltipFunc = AchievementFrameCategory_StatusBarTooltip;
        else
            button.showTooltipFunc = nil;
        end
        --]]
    end

    function AchievementFrame_SetTabs()
        return
    end
end


---------------------------------------------------------------------------------------

local metaCriteriaTable = {};   --Green check, achv icon and meta criteria name

local function MetaCriteriaButton_PreClick(self)
    local id = self:GetParent().id;     --ObjectivesFrame
    local name = self:GetParent():GetParent().label:GetText();      --parent achievement button
    local button = CriteriaStructure:GetNextReturnButton(id);
    button:SetLabelAndID(name, id);
end

local function Hook_AchievementButton_GetMeta()
    hooksecurefunc("AchievementButton_GetMeta", function(index, renderOffScreen)
        if not metaCriteriaTable[index] then
            local button = _G["AchievementFrameMeta"..index];
            if button then
                metaCriteriaTable[index] = button;
                button.border:SetTexture(TEXTURE_ROOT.."Progressive-IconBorder");
                button.border:SetTexCoord(0, 1, 0, 1);
                button.icon:ClearAllPoints();
                button.icon:SetPoint("CENTER", button.border, "CENTER", 0, 0);
                button.icon:SetSize(20, 20);
                button.icon:SetTexCoord(0.025, 0.975, 0.025, 0.975);
                button.check:SetTexture(TEXTURE_ROOT.."Criteria-Check");
                button.check:SetTexCoord(0, 1, 0, 1);
                button.check:SetSize(16, 16);
                button.label:ClearAllPoints();
                button.label:SetPoint("LEFT", button, "LEFT", 32, 0);
                button:SetScript("PreClick", MetaCriteriaButton_PreClick);
            end
        end
    end)
end

local miniTable = {};   --Mini shield with achv points

local function Hook_AchievementButton_GetMiniAchievement()
    hooksecurefunc("AchievementButton_GetMiniAchievement", function(index)
        if not miniTable[index] then
            local button = _G["AchievementFrameMiniAchievement"..index];
            if button then
                miniTable[index] = button;
                button.border:ClearAllPoints();
                button.border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
                button.border:SetSize(48, 48);
                button.border:SetTexture(TEXTURE_ROOT.."MiniBorderShield");
                button.border:SetTexCoord(0, 1, 0, 1);
                button.icon:ClearAllPoints();
                button.icon:SetPoint("CENTER", button, "TOPLEFT", 21, -21);
                button.icon:SetSize(22, 22);
                button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95);
                button.points:ClearAllPoints();
                button.points:SetPoint("CENTER", button, "BOTTOMRIGHT", -8, 14)
                button.shield:Hide();
            end
        end
    end)
end

local loopCount = 0;
local eraseDelay = NarciAPI_CreateAnimationFrame(0.1);
eraseDelay:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    if self.total >= self.duration then
        self:Hide();
        --print("numCalled: "..loopCount);
        loopCount = 0;
    end
end)

local function Hook_Test()
    hooksecurefunc("AchievementFrameAchievements_Update", function(frame)
        loopCount = loopCount + 1;
        eraseDelay:Show();
    end)








    local function GetSafeScrollChildBottom(scrollChild)
        return scrollChild:GetBottom() or 0;
    end

    function AchievementFrame_SelectAchievement(id, forceSelect, isComparison, isReturn)
        if ( not AchievementFrame:IsShown() and not forceSelect ) then
            return;
        end
    
        local _, _, _, achCompleted, _, _, _, _, flags = GetAchievementInfo(id);
        if ( achCompleted and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_INCOMPLETE].func) ) then
            AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
        elseif ( (not achCompleted) and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_COMPLETE].func) ) then
            AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
        end
    
        local tabIndex = 1;
        local category = GetAchievementCategory(id);
        if ( bit.band(flags, ACHIEVEMENT_FLAGS_GUILD) == ACHIEVEMENT_FLAGS_GUILD ) then
            tabIndex = 2;
        end
    
        if ( isComparison ) then
            AchievementFrameTab_OnClick = AchievementFrameComparisonTab_OnClick;
        else
            AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
        end
    
        AchievementFrameTab_OnClick(tabIndex);
        AchievementFrameSummary:Hide();
    
        if ( not isComparison ) then
            AchievementFrameAchievements:Show();
        end
    
        -- Figure out if this is part of a progressive achievement; if it is and it's incomplete, make sure the previous level was completed. If not, find the first incomplete achievement in the chain and display that instead.
        id = AchievementFrame_FindDisplayedAchievement(id);
    
        AchievementFrameCategories_ClearSelection();
    
        local categoryIndex, parent, hidden = 0;
        for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
            if ( entry.id == category ) then
                parent = entry.parent;
            end
        end
    
        for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
            if ( entry.id == parent ) then
                entry.collapsed = false;
            elseif ( entry.parent == parent ) then
                entry.hidden = false;
            elseif ( entry.parent == true ) then
                entry.collapsed = true;
            elseif ( entry.parent ) then
                entry.hidden = true;
            end
        end
    
        local achievementFunctions = ACHIEVEMENT_FUNCTIONS
        achievementFunctions.selectedCategory = category;
        AchievementFrameCategoriesContainerScrollBar:SetValue(0);
        AchievementFrameCategories_Update();
    
        local shown = false;
        local found = false;
        while ( not shown ) do
            found = false;
            for _, button in next, AchievementFrameCategoriesContainer.buttons do
                if ( button.categoryID == category ) then
                    found = true;
                end
                if ( button.categoryID == category and math.ceil(button:GetBottom()) >= math.ceil(GetSafeScrollChildBottom(AchievementFrameAchievementsContainerScrollChild)) ) then
                    shown = true;
                end
            end
    
            if ( not shown ) then
                local _, maxVal = AchievementFrameCategoriesContainerScrollBar:GetMinMaxValues();
                if ( AchievementFrameCategoriesContainerScrollBar:GetValue() == maxVal ) then
                    --assert(false)
                    if ( not found ) then
                        return;
                    else
                        shown = true;
                    end
                elseif AchievementFrameCategoriesContainerScrollBar:IsVisible() then
                    HybridScrollFrame_OnMouseWheel(AchievementFrameCategoriesContainer, -1);
                else
                    break;
                end
            end
        end
    
        local container, child, scrollBar = AchievementFrameAchievementsContainer, AchievementFrameAchievementsContainerScrollChild, AchievementFrameAchievementsContainerScrollBar;
        if ( isComparison ) then
            container = AchievementFrameComparisonContainer;
            child = AchievementFrameComparisonContainerScrollChild;
            scrollBar = AchievementFrameComparisonContainerScrollBar;
        end

        --achievementFunctions.updateFunc();

        local includeAll = false;
        
        DataProvider:LocateAchievementButton(id, category, includeAll, isReturn);
    end


    if true then return end
    hooksecurefunc("AchievementButton_DisplayObjectives", function(button, id, completed, renderOffScreen)
        print(math.random())
        print("")
        print(id, completed, renderOffScreen)
    end) 

    hooksecurefunc("AchievementFrameAchievements_Update", function()
        loopCount = loopCount + 1;
        print(loopCount)
    end)
end

local function Hook_RepositionFirstCriteria()
    hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id, renderOffScreen)
        --[[
        if not CriteriaFrame1 then
            if AchievementFrameCriteria1 then
                CriteriaFrame1 = AchievementFrameCriteria1;
                hooksecurefunc(AchievementFrameCriteria1, "SetPoint", function(object, point, relativeTo, relativePoint, ofsx, ofsy)
                    print(point, relativeTo, relativePoint, ofsx, ofsy)
                    object:SetPoint(point, relativeTo, relativePoint, ofsx, ofsy + 3);
                end);
            end
        end
        --]]
        print("hook achv "..id)
    end)
end

local function Hook_UnnamedFrame()
    hooksecurefunc("AchievementFrameAchievementsBackdrop_OnLoad", function(frame)
        print(frame:GetName());
    end)
end

----------------------------------------------------------------
local function GetAchievementFromAchivementButton()
    local object = GetMouseFocus();
    if not (object and object:IsObjectType("Button") and AchievementFrame and AchievementFrame:IsMouseOver() ) then
        print("Invalid")
        return
    end
    
    local id = object.id;
    if not id and type(id) ~= "number" then return end;
    
    local id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(id);

    print(name.."\n"..description);
end


local trigger = CreateFrame("Frame");
trigger:Hide();

trigger:SetScript("OnShow", function(self)
    self:RegisterEvent("GLOBAL_MOUSE_DOWN");
end);

trigger:SetScript("OnHide", function(self)
    self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
end);

trigger:SetScript("OnEvent", function(self)
    self:Hide();
    GetAchievementFromAchivementButton()
end);

function GrabAchievementFromButton()
    trigger:Show();
end

local function OnDragStart(self)
    print("Drag Start: "..self:GetName())
end

local function OnDragStop(self)
    if AchievementFrame and AchievementFrame:IsMouseOver() then
        print("Inbound");
    else
        local id = self.id;
        if id and type(id) == "number" then
            local _, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(id);
            print(name.."\n"..description);
            AchivementTestFrame.Icon:SetTexture(icon)
        end
    end
end

local function ModifyAchivementButtons()
    local button;
    local buttons = AchievementFrameAchievementsContainer.buttons;
    local fadingButtons = {};
    if buttons then
        print(#buttons)
        for i = 1, #buttons do
            button = buttons[i];

            button.narciButtonIndex = i - 1;
            ModifyAchievementButton(button);

            if not button:GetScript("OnDragStart") then
                button:RegisterForDrag("LeftButton");
                button:SetScript("OnDragStart", OnDragStart);
                button:SetScript("OnDragStop", OnDragStop);
            else
                print("Already have script")
            end

            tinsert(fadingButtons, button);
        end
    end

    function ClearFadeIn()
        for i = 1, #fadingButtons do
            fadingButtons[i].fadeInPlayed = nil;
        end
    end

    AchievementFrameAchievementsContainer:HookScript("OnHide", ClearFadeIn);
end


--------------------------------------------------------------------
local newTabButtons = {};

local function UpdateTabButtons(id)
    for i = 1, #newTabButtons do
        if id == newTabButtons[i].id then
            newTabButtons[i]:Select();
        else
            newTabButtons[i]:Deselect();
        end
    end
end

local function CreateTabButtons()
    local tabNames = {ACHIEVEMENTS, ACHIEVEMENTS_GUILD_TAB, STATISTICS};

    for i = 1, 3 do
        local tab = _G["AchievementFrameTab"..i];
        if tab then
            tab:Hide();
        end

        local newTab = CreateFrame("Button", "NarciTabButton"..i, AchievementFrame, "NarciAchievementTabButtonTemplate");
        tinsert(newTabButtons, newTab);
        newTab:SetLabel(tabNames[i]);
        newTab.id = i;

        if i == 1 then
            newTab:SetPoint("TOPLEFT", AchievementFrame, "BOTTOMLEFT", 15, 12);
        else
            newTab:SetPoint("TOPLEFT", newTabButtons[i - 1], "TOPRIGHT", 6, 0);
        end
    end

    UpdateTabButtons(1);
    hooksecurefunc("AchievementFrame_UpdateTabs", UpdateTabButtons);
end

--------------------------------------------------------------------
local tooltipDelay = NarciAPI_CreateAnimationFrame(0.5);
tooltipDelay:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    if self.total >= self.duration then
        if AchievementFrameCategoriesContainer:IsMouseOver() then
            NarciCategoryTooltip:FadeIn();
        end
        NarciCategoryTooltip.isScrolling = nil;
        self:Hide();
    end
end)

NarciCategoryTooltipMixin = {};

function NarciCategoryTooltipMixin:SetScrolling()
    tooltipDelay:Hide();
    self.isScrolling = true;
    self:SetAlpha(0);
end

function NarciCategoryTooltipMixin:FadeIn()
    UIFrameFadeIn(self, 0.15, self:GetAlpha(), 1);
end

function NarciCategoryTooltipMixin:ShowDelay()
    if self.isScrolling then
        tooltipDelay.t = 0;
        tooltipDelay:Show();
    else
        self:FadeIn();
    end
end

function NarciCategoryTooltipMixin:SetMinMaxWidth(minWidth, maxWidth)
    if minWidth and type(minWidth) == "number" then
        self.minWidth = minWidth;
    end
    if maxWidth and type(maxWidth) == "number" then
        self.maxWidth = maxWidth;
    end
end

function NarciCategoryTooltipMixin:SetInset(offset)
    self.inset = offset;
    self.header:ClearAllPoints();
    self.header:SetPoint("TOPLEFT", self, "TOPLEFT", offset, -offset);
    self.description:ClearAllPoints();
    self.description:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 0, -4);
    self.topLeft:ClearAllPoints();
    self.topLeft:SetPoint("TOPLEFT", self, "TOPLEFT", offset, -offset);
end

function NarciCategoryTooltipMixin:SetText(header, description)
    self.topRight:Hide();
    self.header:SetText(nil);
    self.header:SetSize(0, 0);
    self.header:SetText(header);

    local headerWidth, headerHeight;
    local descriptionObject;
    
    if header then
        headerWidth = self.header:GetWidth();
        headerHeight = 4 + self.header:GetHeight();
        descriptionObject = self.description;
        self.topLeft:Hide();
        self.header:Show();
    else
        headerWidth = 0;
        headerHeight = 0;
        descriptionObject = self.topLeft;
        self.description:Hide();
    end

    descriptionObject:SetText(nil);
    descriptionObject:SetSize(0, 0);
    descriptionObject:SetText(description);
    descriptionObject:SetTextColor(1, 0.91, 0.647);
    descriptionObject:Show();

    local descriptionWidth = descriptionObject:GetWidth();
    if descriptionWidth > self.maxWidth then
        descriptionWidth = self.maxWidth;
        descriptionObject:SetWidth(descriptionWidth);
    end
    
    self:SetWidth( max(self.minWidth, headerWidth + 2*self.inset, descriptionWidth + 2*self.inset) );

    local descriptionHeight = descriptionObject:GetHeight();

    self:SetHeight(2*self.inset + descriptionHeight + headerHeight);
end

function NarciCategoryTooltipMixin:ShowProgressBar(visibility)
    self.barBackground:SetShown(visibility);
    self.barFill:SetShown(visibility);
    self.barBorder:SetShown(visibility);
end

function NarciCategoryTooltipMixin:SetDoubleLine(text1, text2)
    self.header:Hide();
    self.description:Hide();
    self.topLeft:SetText(text1);
    self.topLeft:SetTextColor(1, 1, 1);
    self.topLeft:Show();
    self.topRight:SetText(text2);
    self.topRight:SetTextColor(0.88, 0.88, 0.88);
    self.topRight:Show();
    self:SetSize(144, 46);
end

function NarciCategoryTooltipMixin:OnLoad()
    self:SetInset(8);
    self:SetMinMaxWidth(144, 240);
end

function NarciCategoryTooltipMixin:SetOwner(frame)
    self:ClearAllPoints();
    self:SetPoint("LEFT", frame, "RIGHT", 0, 0);
    --self:Show();
    self:ShowDelay();
end

function NarciCategoryTooltipMixin:ShowProgress(frame, categoryID)
    if not categoryID then
        self:Hide();
        return
    end

    local includeAll = false;
    local total, completed, incompleted = GetCategoryNumAchievements(categoryID, includeAll);
    local percentage;

    if total <= 0 then
        self:Hide();
        return
    end

    if completed > 0 then
        percentage = completed/total;
        self.barFill:SetWidth(percentage * 128);
        self.barFill:SetTexCoord(0, percentage, 0.25, 0.5);
    
        if percentage > 0.66 then
            self.barFill:SetVertexColor(0.224, 0.71, 0.29);
        elseif percentage > 0.33 then
            self.barFill:SetVertexColor(0.8, 0.7, 0.33);
        else
            self.barFill:SetVertexColor(0.5, 0.5, 0.5);
        end

        percentage = round(100 * percentage, 1);
        self.barFill:Show();
    else
        percentage = 0;
        self.barFill:SetWidth(0.1);
    end

    self:SetDoubleLine(completed.."/"..total, percentage.."%");

    self:ShowProgressBar(true);
    self:SetOwner(frame);
end

function NarciCategoryTooltipMixin:ShowTooltip(frame, header, description)
    self:SetText(header, description);
    self:ClearAllPoints();
    self:SetPoint("LEFT", frame, "RIGHT", 0, 0);
    self:ShowProgressBar(false);
    self:SetOwner(frame);
end

function NarciCategoryTooltipMixin:OnShow()
    self:RegisterEvent("GLOBAL_MOUSE_DOWN");
end

function NarciCategoryTooltipMixin:OnEvent(event)
    self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
    self:Hide();
    self:SetAlpha(0);
end

function NarciCategoryTooltipMixin:OnHide()
    self:Hide();
end


NarciAchievementReturnButtonMixin = {};

function NarciAchievementReturnButtonMixin:OnLoad()
    self.t = 0;
    self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, 1);
    self.arrow:SetTexture(TEXTURE_ROOT.."ReturnButton", nil, nil, "TRILINEAR");
    local overlay = self:GetParent().overlay;
    self.overlay = overlay;
    self.blackOverlayTop = overlay.blackOverlayTop;
    self.blackOverlayCenter = overlay.blackOverlayCenter;
    self.blackOverlayBottom = overlay.blackOverlayBottom;
end

function NarciAchievementReturnButtonMixin:OnEnter()
    self:SetBackdropBorderColor(255/255, 210/255, 110/255, 1);
    
end

function NarciAchievementReturnButtonMixin:OnLeave()
    self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, 1);
end

function NarciAchievementReturnButtonMixin:OnClick()
    CriteriaStructure:TrimRight(self);
    if self.id then
        ReturnFrame.blackOverlayFull:Show();
        AchievementFrame_SelectAchievement(self.id, true, nil, true);
    end
end

function NarciAchievementReturnButtonMixin:OnHide()
    if self.index == 1 then
        print("Hide Frame")
        --ReturnFrame:Hide();
    end
    self:Hide();
    self.posY = nil;
    self.t = 0;

    CriteriaStructure:TrimRight(self);
end

function NarciAchievementReturnButtonMixin:InitializePosition(isReturn)
    self.t = 0;
    self.posY = nil;
    After(0.25, function()
        self.posY = self:GetTop();
    end)

    if isReturn and self.scrollFrameOffset then
        --AchievementFrameAchievementsContainerScrollBar:SetValue(self.scrollFrameOffset);
        print("Resume value")
    end

    return self.cursorY or 0;
end

function NarciAchievementReturnButtonMixin:OnPositionChanged(elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.2 then
        self.t = 0;
        local posY = self:GetTop();
        if self.posY and posY ~= self.posY then
            self:Hide();
        end
    end
end

function NarciAchievementReturnButtonMixin:SetLabelAndID(text, id)
    self.id = id;
    self.scrollFrameOffset = AchievementFrameAchievementsContainerScrollBar:GetValue();
    
    if id then
        ReturnFrame:Show();
        self.label:SetText(nil);
        self.label:SetWidth(0);
        self.label:SetText(text);
        local width = self.label:GetWidth();
        if width < 48 then
            width = 48;
            self.label:SetWidth(48);
        elseif width > 240 then
            width = 240;
            self.label:SetWidth(width);
        end

        self:SetWidth(width + 32);
        self:Show();

        self.blackOverlayTop:SetAlpha(1);
        self.blackOverlayCenter:SetAlpha(1);
        self.blackOverlayBottom:SetAlpha(1);

        --Get cursor position for scrollBar reposition
        local uiScale = ACHV:GetEffectiveScale();
        local cursorX, cursorY = GetCursorPosition();
        local bottom = ACHV:GetBottom();
        cursorY = cursorY / uiScale;
        if cursorY < bottom + 108 then
            cursorY = bottom + 108;
        end
        self.cursorY = cursorY;

        self:AnchorToButton(1);
    else
        ReturnFrame:Hide();
    end
end

function NarciAchievementReturnButtonMixin:AnchorToButton(achivementButtonIndex)
    local container = AchievementFrameAchievementsContainer;
    local achievementButton = container.buttons[achivementButtonIndex];

    local firstReturnButton;
    local offsetX;
    print("|cff0000FFThis is button #"..(self.index))
    if self.index == 1 then
        firstReturnButton = self;
        offsetX = 0;
    else
        firstReturnButton = CriteriaStructure.buttons[1];
        offsetX = -self:GetWidth()/2
    end

    firstReturnButton:ClearAllPoints();
    print("|cffFF1100"..offsetX)
    if achievementButton:GetTop() + 36 > container:GetTop() then
        firstReturnButton:SetPoint("TOP", achievementButton, "BOTTOM", offsetX, -8);
    else
        firstReturnButton:SetPoint("BOTTOM", achievementButton, "TOP", offsetX, 8);
    end

    self.overlay:ClearAllPoints();
    self.overlay:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0);
    self.overlay:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0);
    self.overlay:SetFrameLevel(self:GetFrameLevel() - 1);
    self.blackOverlayTop:ClearAllPoints();
    self.blackOverlayBottom:ClearAllPoints();
    self.blackOverlayCenter:ClearAllPoints();
    self.blackOverlayTop:SetPoint("TOPLEFT", container, "TOPLEFT", 1, 0);
    self.blackOverlayTop:SetPoint("BOTTOMRIGHT", achievementButton, "TOPRIGHT", 0, 0);
    self.blackOverlayBottom:SetPoint("TOPLEFT", achievementButton, "BOTTOMLEFT", 0, 0);
    self.blackOverlayBottom:SetPoint("TOPRIGHT", achievementButton, "BOTTOMRIGHT", 0, 0);
    self.blackOverlayBottom:SetPoint("BOTTOM", container, "BOTTOM", 0, 0);
    self.blackOverlayCenter:SetPoint("TOPLEFT", achievementButton, "TOPLEFT", 0, 0);
    self.blackOverlayCenter:SetPoint("BOTTOMRIGHT", achievementButton, "BOTTOMRIGHT", 0, 0);
end


NarciAchievementProgressBarMixin = {};

function NarciAchievementProgressBarMixin:Update()
    local totalAchievements, totalCompleted = GetCategoryNumAchievements(self.categoryID, true);   --ACHIEVEMENT_COMPARISON_SUMMARY_ID
    local numAchievements, numCompleted;
    if self.subCategories then
        for i = 1, #self.subCategories do
            numAchievements, numCompleted = GetCategoryNumAchievements(self.subCategories[i], true);
            totalAchievements = totalAchievements + numAchievements;
            totalCompleted = totalCompleted + numCompleted;
        end
    end

    local percentage;
    if totalAchievements == 0 or totalCompleted == 0 then
        percentage = 0.001;
    else
        percentage = totalCompleted / totalAchievements;
    end
    self.barFill:SetWidth(percentage * 128);
    self.barFill:SetTexCoord(0, percentage, 0.25, 0.5);
    self.percent:SetText(round(percentage*100).."%")
end



local function ToggleAchievementFrame(toggleStatFrame, toggleGuildView)
	AchievementFrameComparison:Hide();
	AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
	if ( not toggleStatFrame ) then
		if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 1 ) then
			HideUIPanel(AchievementFrame);
		else
			AchievementFrame_SetTabs();
			ShowUIPanel(AchievementFrame);
			if ( toggleGuildView ) then
				AchievementFrameTab_OnClick(2);
			else
				AchievementFrameTab_OnClick(1);
			end
		end
		return;
	end
	if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 3 ) then
		HideUIPanel(AchievementFrame);
	else
		ShowUIPanel(AchievementFrame);
		AchievementFrame_SetTabs();
		AchievementFrameTab_OnClick(3);
	end
end

local function OverrideMircoButton()
    local button = AchievementMicroButton;
    --[[
    button:SetScript("OnClick", function()
        if ( ( HasCompletedAnyAchievement() or IsInGuild() ) and CanShowAchievementUI() ) then
            AchievementFrame_LoadUI();
            AchievementFrame:SetShown(not AchievementFrame:IsShown());
        end
    end)
    --]]
    
    hooksecurefunc("ShowUIPanel", function(frame)
        if InCombatLockdown() and frame == AchievementFrame then
            AchievementFrame:SetShown(not AchievementFrame:IsShown())
        end
    end)
    hooksecurefunc("HideUIPanel", function(frame)
        if InCombatLockdown() and frame == AchievementFrame then
            AchievementFrame:SetShown(not AchievementFrame:IsShown())
        end
    end)
end



--------------------------------------------------------------------
local initialize = CreateFrame("Frame");
initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
initialize:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
initialize:SetScript("OnEvent", function(self,event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        --self:RegisterEvent("ADDON_LOADED")
    elseif event == "ADDON_LOADED" then
        local name = ...
        if name == "Blizzard_AchievementUI" then
            self:UnregisterEvent("ADDON_LOADED");
            After(0, function()
                if not AchievementFrame then return end;
                --[[
                Hook_RepositionFirstCriteria();
                ACHV = AchievementFrame;
                Hook_UnnamedFrame();
                ModifyAchivementButtons();
                Hook_AchievementButton_GetMeta();
                Hook_AchievementButton_GetMiniAchievement();
                Hook_Test();
                ReskinFrame();
                CreateTabButtons();
                
                
                NarciCategoryTooltip:SetPoint("CENTER", ACHV, "CENTER", 0, 0);
                MountPreview = CreateFrame("ModelScene", nil, ACHV,"NarciAchievementRewardModelTemplate");
                MountPreview:ClearAllPoints();
                MountPreview:SetPoint("LEFT", ACHV, "RIGHT", 0, 0);

                ReturnFrame = NarciAchievementReturnFrame;
                GetExpandedButtonHeight = AchievementButton_DisplayObjectives;
                --]]

                NarciCategoryTooltip = CreateFrame("Frame", "NarciCategoryTooltip", AchievementFrame, "NarciCategoryTooltipTemplate");
                ModifyCategoryButton();
                OverrideMircoButton();
                OverrideFunctions();
                AddSmoothScroll();
            end)
        end
    end
    local name = ...
    --print(event)
end)