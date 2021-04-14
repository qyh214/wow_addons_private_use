--Constant
local LEGACY_ID = 15234;
local FEAT_OF_STRENGTH_ID = 81;
local GUILD_FEAT_OF_STRENGTH_ID = 15093;
local GUILD_CATEGORY_ID = 15076;

local sin = math.sin;
local cos = math.cos;
local abs = math.abs;
local min = math.min;
local max = math.max;
local sqrt = math.sqrt;
local pow = math.pow;
local pi = math.pi;
local floor = math.floor;
local ceil = math.ceil;
local After = C_Timer.After;
local gsub = string.gsub;
local GetAchievementCategory = GetAchievementCategory;
local GetAchievementInfo = GetAchievementInfo;
local GetAchievementNumCriteria = GetAchievementNumCriteria;
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo;
local GetRewardItemID = C_AchievementInfo.GetRewardItemID;
local GetPreviousAchievement = GetPreviousAchievement;
local GetNextAchievement = GetNextAchievement;
local SetFocusedAchievement = SetFocusedAchievement;    --Requset guild achievement progress from server, will fire "CRITERIA_UPDATE" after calling GetAchievementCriteriaInfo()
local FadeFrame = NarciFadeUI.Fade;
local GetParentAchievementID = NarciAPI.GetParentAchievementID;
local L = Narci.L;

local function linear(t, b, e, d)
	return (e - b) * t / d + b
end

local function outSine(t, b, e, d)
	return (e - b) * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, e, d)
	return (b - e) / 2 * (cos(pi * t / d) - 1) + b
end

local function outQuart(t, b, e, d)
    t = t / d - 1;
    return (b - e) * (pow(t, 4) - 1) + b
end

--FormatShortDate Derivated from FormatShortDate (Util.lua)
local FormatDate;
if LOCALE_enGB then
    function FormatDate(day, month, year, twoRowMode)
        if (year) then
            if twoRowMode then
                return format("%1$d/%2$d\n20%3$02d", day, month, year);
            else
                return format("%1$d/%2$d/%3$02d", day, month, year);
            end
        else
            return format("%1$d/%2$d", day, month);
        end
    end
else
    function FormatDate(day, month, year, twoRowMode)
        if (year) then
            if twoRowMode then
                return format("%2$d/%1$02d\n20%3$02d", day, month, year);
            else
                return format("%2$d/%1$02d/%3$02d", day, month, year);
            end
        else
            return format("%2$d/%1$02d", day, month);
        end
    end
end

local themeID = 0;
local showNotEarnedMark = false;
local isDarkTheme = true;
local isGuildView = false;
local texturePrefix = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\DarkWood\\";

local function ReskinButton(button)
    --if true then return end
    button.border:SetTexture(texturePrefix.."AchievementCardBorder");
    button.background:SetTexture(texturePrefix.."AchievementCardBackground");
    button.bottom:SetTexture(texturePrefix.."AchievementCardBackground");
    button.lion:SetTexture(texturePrefix.."Lion");
    button.mask:SetTexture(texturePrefix.."AchievementCardBorderMask");
    local isDarkTheme = isDarkTheme;
    button.RewardFrame.background:SetShown(not isDarkTheme);
    button.RewardFrame.rewardNodeLeft:SetShown(isDarkTheme);
    button.RewardFrame.rewardNodeRight:SetShown(isDarkTheme);
    button.RewardFrame.rewardLineLeft:SetShown(isDarkTheme);
    button.RewardFrame.rewardLineRight:SetShown(isDarkTheme);
    if isDarkTheme then
        button.description:SetFontObject(NarciAchievementText);
    else
        button.description:SetFontObject(NarciAchievementTextBlack);
    end

    --Reposition Elements
    button.icon:ClearAllPoints();
    button.lion:ClearAllPoints();
    button.date:ClearAllPoints();
    button.NotEarned:ClearAllPoints();
    if showNotEarnedMark then
        button.NotEarned:SetWidth(20);
    else
        button.NotEarned:SetWidth(0.1);
    end
    if themeID == 3 then
        button.icon:SetPoint("CENTER", button.border, "LEFT", 32, 0);
        button.lion:SetPoint("CENTER", button.border, "RIGHT", -28, -1);
        button.date:SetPoint("RIGHT", button.border, "TOPRIGHT", -54, -25);
        button.NotEarned:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 6, -2);
    else
        button.icon:SetPoint("CENTER", button.border, "LEFT", 27, 4);
        button.lion:SetPoint("CENTER", button.border, "RIGHT", -22, 3);
        button.date:SetPoint("RIGHT", button.border, "TOPRIGHT", -48, -25);
        button.NotEarned:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 7, -6.5);
    end

    button.isDark = nil;
end


local MainFrame, InspectionFrame, MountPreview, Tooltip, ReturnButton, SummaryButton, GoToCategoryButton;
local CategoryContainer, AchievementContainer, DIYContainer, EditorContainer, SummaryFrame, AchievementCards, ResultFrame, ResultButtons, TabButtons;

local CategoryButtons = {
    player = { parentButtons = {}, buttons = {}, },
    guild = { parentButtons = {}, buttons = {}, },
};

function CategoryButtons:GetActiveParentButtons(isGuild)
    if isGuild or isGuildView then
        return self.guild.parentButtons;
    else
        return self.player.parentButtons;
    end
end

local CategoryStructure = {
    player = {},
    guild = {},
};

local DataProvider = {};
DataProvider.categoryCache = {};
DataProvider.achievementCache = {};
DataProvider.achievementOrderCache = {};
DataProvider.id2Button = {};
DataProvider.currentCategory = 0;
DataProvider.isTrackedAchievements = {};
DataProvider.trackedAchievements = {};

function DataProvider:ClearCache()
    wipe(self.categoryCache);
    wipe(self.achievementCache);
    collectgarbage("collect");
end

function DataProvider:GetCategoryInfo(id, index)
    if not self.categoryCache[id] then
        local name, parentID, flags = GetCategoryInfo(id);
        if name then
            self.categoryCache[id] = { name, parentID, flags };
        end
        return name, parentID, flags;
    else
        if index then
            return self.categoryCache[id][index];
        else
            return unpack( self.categoryCache[id] );
        end
    end
end

function DataProvider:GetAchievementInfo(id, index)
    if not self.achievementCache[id] then
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(id);
        if isGuild then
            SetFocusedAchievement(id);
        end
        if description then
            self.achievementCache[id] = {id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe};
        end
        if index then
            if self.achievementCache[id] then
                return self.achievementCache[id][index];
            end
        else
            return id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy
        end
    else
        if index then
            return self.achievementCache[id][index];
        else
            return unpack( self.achievementCache[id] );
        end
    end
end

function DataProvider:UpdateAchievementCache(id)
    if self.achievementCache[id] then
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(id);
        if isGuild then
            SetFocusedAchievement(id);
        end
        if description then
            self.achievementCache[id] = {id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe};
        end
    end
end

function DataProvider:GetAchievementInfoByOrder(categoryID, order)
    if not self.achievementOrderCache[categoryID] then
        self.achievementOrderCache[categoryID] = {};
    end

    if not self.achievementOrderCache[categoryID][order] then
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(categoryID, order);
        if isGuild then
            SetFocusedAchievement(id);
        end
        if description then
            self.achievementOrderCache[categoryID][order] = id;
            self.achievementCache[id] = {id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe};
        end
        return id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy
    else
        local id = self.achievementOrderCache[categoryID][order];
        return self:GetAchievementInfo(id)
    end
end

function DataProvider:GetCategoryButtonByID(categoryID, isGuild)
    return self.id2Button[categoryID];
end

function DataProvider:GetTrackedAchievements()
    local new = {GetTrackedAchievements()} or {};
    local old = self.trackedAchievements;
    local numNew, numOld = #new, #old;
    local dif;

    if numNew >= numOld then
        local lookup = {};
        for i = 1, #old do
            lookup[ old[i] ] = true;
        end
        for i = 1, #new do
            if not lookup[ new[i] ] then
                dif = new[i];
                break
            end
        end
    else
        local lookup = {};
        for i = 1, #new do
            lookup[ new[i] ] = true;
        end
        for i = 1, #old do
            if not lookup[ old[i] ] then
                dif = old[i];
                break
            end
        end
    end

    self.trackedAchievements = new;
    self.numTrackedAchievements = #new;
    wipe(self.isTrackedAchievements);
    for index, id in pairs(new) do
        self.isTrackedAchievements[id] = true;
    end
    return dif
end

function DataProvider:IsTrackedAchievement(id)
    return self.isTrackedAchievements[id]
end


--Limit the request frequency
local processor = CreateFrame("Frame");
processor:Hide();
processor:SetScript("OnUpdate", function(self, elapsed)
    local processComplete;
    if self.func then
        self.arg2, processComplete = self.func(self.arg1, self.arg2);
        if processComplete then
            self:Hide();
            self.func = nil;
            self.callback();
        end
    else
        self:Hide();
    end
end)

function processor:Add(func)
    self.func = func
end


------------------------------------------------------------------------------------------------------
local function HideItemPreview()
    GameTooltip:Hide();
    if MountPreview:IsShown() then
        MountPreview:FadeOut();
    end
    MountPreview:ClearCallback();
end

local function SetItemPreview(self)
    local itemID = self.itemID;
    if itemID then
        MountPreview:SetItem(itemID);
    else
        HideItemPreview();
    end
end


local animFlyIn = NarciAPI_CreateAnimationFrame(0.45);
local animFlyOut = NarciAPI_CreateAnimationFrame(0.25);

animFlyIn:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local alpha = outQuart(self.total, self.fromAlpha, 1, self.duration);
    local scale = outQuart(self.total, 0.5, 1, 0.2);

    if self.total >= 0.2 then
        scale = 1;
        local textAlpha = outQuart(self.total - 0.2, 0, 1, 0.2);
        self.header:SetAlpha(textAlpha);
        self.description:SetAlpha(textAlpha);
        self.date:SetAlpha(textAlpha);
        self.reward:SetAlpha(textAlpha);
    end
    
    if self.total >= self.duration then
        alpha = 1;
        --offsetX = 0;
        --offsetY = 0;
        scale = 1;
        self.header:SetAlpha(1);
        self.description:SetAlpha(1);
        self.date:SetAlpha(1);
        self.reward:SetAlpha(1);
        self:Hide();
    end
    self.background:SetAlpha(alpha);
    self.ObjectiveFrame:SetAlpha(alpha);
    self.ChainFrame:SetAlpha(alpha);
    self.Card:SetScale(scale);
end)


function animFlyIn:Play()
    self:Hide();
    self.Card:SetAlpha(1);
    self.header:SetAlpha(0);
    self.description:SetAlpha(0);
    self.date:SetAlpha(0);
    self.reward:SetAlpha(0);
    self.fromAlpha = self.background:GetAlpha();
    animFlyOut:Hide();
    self:Show();
end


animFlyOut:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local offsetX = inOutSine(self.total, self.fromX, self.toX, self.duration);
    local offsetY = inOutSine(self.total, self.fromY, self.toY, self.duration);
    local alpha = outQuart(self.total, 1, 0, self.duration);
    if self.total >= self.duration then
        offsetX = self.toX;
        offsetY = self.toY;
        alpha = 0;
        InspectionFrame:Hide();
        if self.button then
            self.button:Show();
        end
        self.noTranslation = nil;
        self:Hide();
    end
    self.background:SetAlpha(alpha);
    self.ObjectiveFrame:SetAlpha(alpha);
    self.ChainFrame:SetAlpha(alpha);
    if self.noTranslation then
        self.Card:SetAlpha(alpha);
    else
        self.Card:SetPoint("BOTTOM", InspectionFrame, "CENTER", offsetX, offsetY);
    end
end)

function animFlyOut:Play()
    animFlyIn:Hide();
    self:Hide();
    if self.button then
        --achievement button in the scrollframe
        self.button:Hide();
    end
    local _;
    _, _, _, self.fromX, self.fromY = self.Card:GetPoint();
    self:Show();
    HideItemPreview();
    InspectionFrame.isTransiting = true;
    InspectionFrame.HotkeyShiftClick:Hide();
    InspectionFrame.HotkeyMouseWheel:Hide();
    InspectionFrame.GetLink:Hide();
    InspectionFrame.GoToCategoryButton:Hide();
    self.Card.ParentAchievmentButton:Hide();
end

------------------------------------------------------------------------------------------------------
local function DisplayProgress(id, flags)
    --print(id)
    local cData, iData = {}, {};
    cData.names, iData.names = {}, {};
    cData.icons, iData.icons = {}, {};
    cData.assetIDs, iData.assetIDs = {}, {};
    cData.bars, iData.bars = {}, {};

    local numCompleted, numIncomplete = 0, 0;
    --if ( not ( bit.band(flags, 128) == 128 ) ) then   --ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR = 128!!
        local numCriteria =  GetAchievementNumCriteria(id);
        if numCriteria == 0 then
            numCompleted = 0;
            numIncomplete = 0;
        else
            local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString;
            for i = 1, numCriteria do
                criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i);
                --print("criteriaType: "..criteriaType)
                if ( bit.band(flags, 1) == 1 ) then  --EVALUATION_TREE_FLAG_PROGRESS_BAR = 1
                    if ( completed == false ) then
                        numIncomplete = numIncomplete + 1;
                        tinsert(iData.bars, {quantity, reqQuantity, criteriaString});
                    else
                        numCompleted = numCompleted + 1;
                        tinsert(cData.bars, {quantity, reqQuantity, criteriaString});
                    end
                else
                    if ( completed == false ) then
                        numIncomplete = numIncomplete + 1;
                        criteriaString = "|CFF808080" .. criteriaString .. "|r";
                        tinsert(iData.names, criteriaString);
                        if criteriaType == 8 and assetID then  --CRITERIA_TYPE_ACHIEVEMENT
                            local icon = DataProvider:GetAchievementInfo(assetID, 10);
                            iData.icons[numIncomplete] = icon;
                            iData.assetIDs[numIncomplete] = assetID;
                        end
                    else
                        numCompleted = numCompleted + 1;
                        criteriaString = "|CFF5fbb46" .. criteriaString .. "|r"; --00FF00
                        tinsert(cData.names, criteriaString);
                        if criteriaType == 8 and assetID then  --CRITERIA_TYPE_ACHIEVEMENT
                            local icon = DataProvider:GetAchievementInfo(assetID, 10);
                            cData.icons[numCompleted] = icon;
                            cData.assetIDs[numCompleted] = assetID;
                        end
                    end
                end
            end
        end
    --end
    
    cData.count = numCompleted;
    iData.count = numIncomplete;

    InspectionFrame:DisplayCriteria(cData, iData);
end


local InspectCard;  --function

local function ToggleTracking(id)
    if not id then return end;

    if DataProvider:IsTrackedAchievement(id) then
        RemoveTrackedAchievement(id);
    else
        local MAX_TRACKED_ACHIEVEMENTS = 10;
        if ( DataProvider.numTrackedAchievements >= MAX_TRACKED_ACHIEVEMENTS ) then
            UIErrorsFrame:AddMessage(format(ACHIEVEMENT_WATCH_TOO_MANY, MAX_TRACKED_ACHIEVEMENTS), 1.0, 0.1, 0.1, 1.0);
            return;
        end

        local _, _, _, completed, _, _, _, _, _, _, _, isGuild, wasEarnedByMe = DataProvider:GetAchievementInfo(id);
        if ( (completed and isGuild) or wasEarnedByMe ) then
            UIErrorsFrame:AddMessage(ERR_ACHIEVEMENT_WATCH_COMPLETED, 1.0, 0.1, 0.1, 1.0);
            return;
        end
    
        AddTrackedAchievement(id);
        return true
    end
end

local function ProcessModifiedClick(button)
    local achievementID = button.id;
    if not achievementID then return true end

    local isModifiedClick = IsModifiedClick();
	if isModifiedClick then
		local handled = nil;
		if ( IsModifiedClick("CHATLINK") ) then
			local achievementLink = GetAchievementLink(achievementID);
			if ( achievementLink ) then
				handled = ChatEdit_InsertLink(achievementLink);
				if ( not handled and SocialPostFrame and Social_IsShown() ) then
					Social_InsertLink(achievementLink);
					handled = true;
				end
			end
		end
		if ( not handled and IsModifiedClick("QUESTWATCHTOGGLE") ) then
            local isTracking = ToggleTracking(achievementID);
            button.trackIcon:SetShown(isTracking);
        end
    end
    return isModifiedClick
end

local function AchievementCard_OnClick(self)
    if not ProcessModifiedClick(self) then
        InspectCard(self, true);
    end
end

local function FormatRewardText(id, rewardText)
    if isDarkTheme then
        local itemID = GetRewardItemID(id);
        if itemID then
            local itemID, itemType, itemSubType, _, icon, itemClassID, itemSubClassID = GetItemInfoInstant(itemID);
            if itemSubType == "Mount" then
                rewardText = gsub(rewardText, ".+:(.+)", "|cff808080".. "Mount:" .."|r|cff8950c6".."%1".."|r");
            elseif itemSubType == "Companion Pets" then
                rewardText = gsub(rewardText, ".+:(.+)", "|cff808080".. "Pet:" .."|r|cfff2b344".."%1".."|r");
            else
                rewardText = "|cffa3d39c"..rewardText.."|r";
            end
            return rewardText, itemID
        else
            return ("|cffa3d39c"..rewardText.."|r");      --Pastel Yellow Green
        end
    else
        return ("|cffffd200"..rewardText.."|r");
    end
end

local function GetProgressivePoints(achievementID, basePoints)
	local points;
    local _, progressivePoints, completed
    if basePoints then
        progressivePoints = basePoints;
    else
        _, _, progressivePoints, completed = DataProvider:GetAchievementInfo(achievementID);
    end
    achievementID = GetPreviousAchievement(achievementID);
	while achievementID do
		_, _, points, completed = DataProvider:GetAchievementInfo(achievementID);
        progressivePoints = progressivePoints + points;
        achievementID = GetPreviousAchievement(achievementID);
	end

	if ( progressivePoints ) then
		return progressivePoints;
	else
		return 0;
	end
end


local function FormatAchievementCard(buttonIndex, id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe)
    local headerObject, numLines, textHeight;
    local button = AchievementCards[buttonIndex];
    if not button then
        button = CreateFrame("Button", nil, AchievementContainer.ScrollChild, "NarciAchievementCardLargeTemplate");
        button:SetScript("OnClick", AchievementCard_OnClick);
        button:SetPoint("TOP", AchievementCards[buttonIndex - 1], "BOTTOM", 0, -4);
        tinsert(AchievementCards, button);
        button.index = buttonIndex;
        ReskinButton(button);
    end

    button.id = id;
    button.trackIcon:SetShown( DataProvider:IsTrackedAchievement(id) );
    if (not (wasEarnedByMe and completed) ) and (showNotEarnedMark) and (not isGuildView) then
        button.NotEarned:Show();
    else
        button.NotEarned:Hide();
    end

    --for long text
    button.header:SetText(name);
    if button.header:IsTruncated() then
        headerObject = button.headerLong;
        headerObject:SetText(name);
        button.header:Hide();
    else
        headerObject = button.header;
        button.headerLong:Hide();
    end
    headerObject:Show();

    if flags == 131072 then
        if completed then
            if isDarkTheme then
                headerObject:SetTextColor(0.427, 0.812, 0.965); --(0.427, 0.812, 0.965)(0.4, 0.755, 0.9)
            else
                headerObject:SetTextColor(1, 1, 1);
            end
        else
            if isDarkTheme then
                headerObject:SetTextColor(0.214, 0.406, 0.484);
            else
                headerObject:SetTextColor(0.5, 0.5, 0.5);
            end
        end
    else
        if completed then
            if isDarkTheme then
                headerObject:SetTextColor(0.9, 0.82, 0.58);  --(1, 0.91, 0.647); --(0.9, 0.82, 0.58) --(0.851, 0.774, 0.55)
            else
                headerObject:SetTextColor(1, 1, 1);
            end
        else
            if isDarkTheme then
                headerObject:SetTextColor(0.5, 0.46, 0.324);
            else
                headerObject:SetTextColor(0.5, 0.5, 0.5);
            end
        end
    end

    points = GetProgressivePoints(id, points);
    if points == 0 then
        button.points:SetText("");
        button.lion:Show();
    else
        if points >= 100 then
            if not button.useSmallPoints then
                button.useSmallPoints = true;
                button.points:SetFontObject(NarciAchievemtPointsSmall);
            end
        else
            if button.useSmallPoints then
                button.useSmallPoints = nil;
                button.points:SetFontObject(NarciAchievemtPoints);
            end
        end
        button.points:SetText(points);
        button.lion:Hide();
    end

    button.icon:SetTexture(icon);

    local rewardHeight;
    local shadowHeight = 0;
    if rewardText and rewardText ~= "" then
        local itemID;
        rewardHeight = 24;
        rewardText, itemID = FormatRewardText(id, rewardText);
        button.RewardFrame.reward:SetText(rewardText);
        button.RewardFrame.itemID = itemID;
        button.itemID = itemID;
        button.RewardFrame:Show();
    else
        if isDarkTheme then
            rewardHeight = 2;
        else
            rewardHeight = 8;
        end
        button.RewardFrame:Hide();
        button.RewardFrame:SetHeight(2);
    end
    button.RewardFrame:SetHeight(rewardHeight);
    button.description:SetHeight(0);
    button.description:SetText(description);
    textHeight = floor( button.background:GetHeight() + 0.5 );
    local descriptionHeight = button.description:GetHeight();
    button.description:SetHeight(descriptionHeight + 2)
    numLines = ceil( descriptionHeight / 14 - 0.1 );
    button:SetHeight(72 + rewardHeight + 14*(numLines - 1) );
    button.shadow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 12, - 6 - numLines * 6 - shadowHeight);

    if flags == 131072 then     --ACHIEVEMENT_FLAGS_ACCOUNT
        if button.accountWide ~= true then
            button.accountWide = true;
            button.border:SetTexCoord(0.05078125, 0.94921875, 0.5, 1);
            button.bottom:SetTexCoord(0.05078125, 0.94921875, 0.985, 1);
        end
        if textHeight <= 288 then
            button.background:SetTexCoord(0.05078125, 0.94921875, 0.985 - textHeight/288/2, 0.985);
        else
            button.background:SetTexCoord(0.05078125, 0.94921875,  0.5, 1);
        end
    else
        if button.accountWide then
            button.accountWide = nil;
            button.border:SetTexCoord(0.05078125, 0.94921875, 0, 0.5);
            button.bottom:SetTexCoord(0.05078125, 0.94921875, 0.485, 0.5);
        end
        if textHeight <= 288 then
            button.background:SetTexCoord(0.05078125, 0.94921875, 0.485 - textHeight/288/2, 0.485);
        else
            button.background:SetTexCoord(0.05078125, 0.94921875,  0, 0.485);
        end
    end

    if completed then
        button.date:SetText( FormatDate(day, month, year) );
        button.RewardFrame.reward:SetAlpha(1);
        
        if buttonIndex > 7 or buttonIndex < 0 then
            button:SetAlpha(1);
        else
            button.toAlpha = 1;
            button:SetAlpha(0);     --for flip animation
        end

        if (button.isDark == nil) or (button.isDark) then
            button.isDark = false;
            button.icon:SetDesaturated(false);
            button.points:SetTextColor(0.8, 0.8, 0.8);
            if isDarkTheme then
                button.description:SetTextColor(0.8, 0.8, 0.8);
            else
                button.description:SetTextColor(0, 0, 0);
            end
            button.icon:SetVertexColor(1, 1, 1);
            button.lion:SetVertexColor(1, 1, 1);
            button.border:SetVertexColor(1, 1, 1);
            button.background:SetVertexColor(1, 1, 1);
            button.bottom:SetVertexColor(1, 1, 1);
            button.border:SetDesaturated(false);
            button.background:SetDesaturated(false);
            button.bottom:SetDesaturated(false);
        end
    else
        button.date:SetText("");
        button.RewardFrame.reward:SetAlpha(0.60);

        if buttonIndex > 7 or buttonIndex < 0 then
            button:SetAlpha(1); --0.5
        else
            button.toAlpha = 1  --0.5;
            button:SetAlpha(0);     --for flip animation
        end

        if (button.isDark == nil) or (not button.isDark) then
            button.isDark = true;
            button.icon:SetDesaturated(true);
            button.points:SetTextColor(0.6, 0.6, 0.6);
            if isDarkTheme then
                button.description:SetTextColor(0.6, 0.6, 0.6);
            else
                button.description:SetTextColor(0, 0, 0);
            end
            button.icon:SetVertexColor(0.60, 0.60, 0.60);
            button.lion:SetVertexColor(0.60, 0.60, 0.60);
            button.border:SetVertexColor(0.60, 0.60, 0.60);
            button.background:SetVertexColor(0.72, 0.72, 0.72);
            button.bottom:SetVertexColor(0.72, 0.72, 0.72);
            button.border:SetDesaturation(0.6);
            button.background:SetDesaturation(0.6);
            button.bottom:SetDesaturation(0.6);
        end
    end

    if buttonIndex < 20 then
        button:Show();
    else
        button:Hide();
    end
end


local function InspectAchievement(id)
    if not id then return end;
    
    local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe = DataProvider:GetAchievementInfo(id);
    FormatAchievementCard(-1, id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe);
    DisplayProgress(id, flags);
    InspectionFrame.currentAchievementID = id;
    InspectionFrame.currentAchievementName = name;
    InspectionFrame:Show();
    InspectionFrame.HotkeyShiftClick:Show();
    InspectionFrame.GetLink:Show();

    local itemID = GetRewardItemID(id);
    if itemID then
        MountPreview:SetItem(itemID);
    else
        HideItemPreview();
    end

    InspectionFrame:UpdateChain(id, completed);
    InspectionFrame:FindParentAchievementID(id);
    GoToCategoryButton:SetAchievement(id, isGuild);

    return completed, AchievementCards[-1]:GetHeight()/2
end

function InspectCard(button, playAnimation)    --Private
    local index = button.index;
    if not index then return end;

    local Card = InspectionFrame.Card;
    local id = button.id;
    Card:ClearAllPoints();
    Card:SetPoint("BOTTOM", InspectionFrame, "CENTER", 0, 36);

    InspectionFrame.pauseScroll = nil;
    InspectionFrame.inspectedButtonIndex = index;

    local numAchievements = InspectionFrame.numAchievements;
    if index <= 1 then
        index = 1;
        InspectionFrame.PrevButton:Disable();
        InspectionFrame.NextButton:Enable();
    elseif index >= numAchievements then
        index = numAchievements;
        InspectionFrame.PrevButton:Enable();
        InspectionFrame.NextButton:Disable();
    else
        InspectionFrame.PrevButton:Enable();
        InspectionFrame.NextButton:Enable();
    end
    if numAchievements > 0 then
        InspectionFrame.HotkeyMouseWheel:Show();
    else
        InspectionFrame.HotkeyMouseWheel:Hide();
    end

    local completed, extraY = InspectAchievement(id);

    --Animation
    local x0, y0 = InspectionFrame:GetCenter();
    local x1, y1 = button:GetCenter();
    local offsetX = x1 - x0;
    local offsetY = y1 - y0 - extraY;

    --animFlyIn.fromX, animFlyIn.fromY = offsetX, offsetY;
    animFlyOut.toX, animFlyOut.toY = offsetX, offsetY;
    animFlyOut.button = button;
    animFlyOut.duration = max(0.2, 0.2*(sqrt(offsetX^2 + (offsetY - 36)^2))/150 );

    if playAnimation then
        InspectionFrame:SyncBlurOffset(index);
        animFlyIn:Play();
    end
end


local function Slice_UpdateAchievementCards(categoryID, startIndex)
    --from 1st complete achievement to bottom
    local slice = 4;
    local button;
    local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe;
    local processComplete = false;
    local numProcessed = 0;
    
    --print("process: "..startIndex);
    for i = startIndex, startIndex + slice do
        id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe = DataProvider:GetAchievementInfoByOrder(categoryID, i);
        if i > 0 and id then
            FormatAchievementCard(i, id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe);
            numProcessed = i;
        else
            processComplete = true;
            break;
        end
    end

    return numProcessed, processComplete
end

local function Slice_ReverselyUpdateAchievementCards_Callback(categoryID, startIndex)
    --from 1st complete achievement to 1st incomplete
    local slice = 4;
    local button;
    local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe;
    local processComplete = false;
    local numProcessed = 0;
    local numAchievements, numCompleted, numIncomplete = GetCategoryNumAchievements(categoryID, false);
    local index;
    for i = startIndex, startIndex + slice do
        id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe = DataProvider:GetAchievementInfoByOrder(categoryID, i);
        if i <= numCompleted then
            index = i + numIncomplete;
            FormatAchievementCard(index, id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe);
            numProcessed = i;
        else
            processComplete = true;
            break;
        end
    end

    return numProcessed, processComplete
end

local function Slice_ReverselyUpdateAchievementCards(categoryID, startIndex)
    --from 1st incomplete achievement to the bottom
    local slice = 4;
    local button;
    local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe;
    local processComplete = false;
    local numProcessed = 0;
    local numAchievements, numCompleted = GetCategoryNumAchievements(categoryID, false);

    --print("reverse process: "..startIndex);
    for i = startIndex, startIndex + slice do
        id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe = DataProvider:GetAchievementInfoByOrder(categoryID, numCompleted + i);
        if id then
            --print("id #"..id)
            if not completed then
                FormatAchievementCard(i, id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe);
                numProcessed = i;
            end
        else
            --print("Break, begin forward")
            processor:Hide();
            processor.arg1 = categoryID;
            processor.arg2 = 1;     --startIndex
            processor.func = Slice_ReverselyUpdateAchievementCards_Callback  --Slice_UpdateAchievementCards;
            processor:Show();
            return 1, false
        end
    end

    return numProcessed, processComplete
end

local function UpdateAchievementScrollRange()
    local numAchievements = DataProvider.numAchievements or 0;
    local scrollBar = AchievementContainer.scrollBar;
    local range;
    if numAchievements == 0 or not AchievementCards[numAchievements] then
        range = 0;
    else
        range = max(0, AchievementCards[1]:GetTop() -  AchievementCards[numAchievements]:GetBottom() - AchievementContainer:GetHeight() + 40);
    end
    scrollBar:SetMinMaxValues(0, range);
    AchievementContainer.range = range;
    scrollBar:SetShown(range ~= 0);

    for i = numAchievements + 1, #AchievementCards do
        AchievementCards[i]:Hide();
    end
end

processor.func = Slice_ReverselyUpdateAchievementCards  --Slice_UpdateAchievementCards;
processor.callback = UpdateAchievementScrollRange;


local animFlip = {};

function animFlip:Add(buttons, cap, groupIndex)
    for i = 1, cap do
        local button = buttons[i];
        if not button then break end;

        button.toAlpha = 1;
        local flip = NarciAPI_CreateAnimationFrame(0.4);
        if not self.animFrames then
            self.animFrames = {};
        end
        if not self.animFrames[groupIndex] then
            self.animFrames[groupIndex] = {};
        end
        
        self.animFrames[groupIndex][i] = flip;
        flip.index = i;
        flip.hold = true;
        flip.button = button;
        flip.border = button.border;
        flip.description = button.description;
        flip.objects = {
            button.points,
            button.icon,
            button.lion,
            button.border,
        }
        flip:SetScript("OnUpdate", function(frame, elapsed)
            frame.total = frame.total + elapsed;
            local scale = outQuart(frame.total, 1.25, 1, frame.duration);
            local offset1 = outQuart(frame.total, 24, 0, frame.duration);
            local offset2 = outQuart(frame.total, -72, -48, frame.duration);
            local alpha = min(button.toAlpha, linear(frame.total, 0, 1, 0.25) );
            if frame.total >= 0.05 and frame.hold then
                frame.hold = nil;
                local nextFlip = self.animFrames[groupIndex][frame.index + 1];
                if nextFlip and nextFlip.button:IsShown() then
                    self.animFrames[groupIndex][frame.index + 1]:Show();
                end
            end
            if frame.total >= frame.duration then
                frame:Hide()
                scale = 1;
                offset1 = 0;
                offset2 = -48;
                alpha = button.toAlpha;
            end
        
            frame.button:SetAlpha(alpha);
            frame.border:SetPoint("TOP", 0, offset1);
            frame.description:SetPoint("TOP", 0, offset2);
            for i = 1, #frame.objects do
                frame.objects[i]:SetScale(scale);
            end
        end)
    end
end

function animFlip:Play(groupIndex)
    local group = self.animFrames[groupIndex];
    if group then
        for i = 1, #group do
            group[i]:Hide();
            group[i].hold = true;
        end

        group[1]:Show();
    end
end

local SORT_FUNC = Slice_ReverselyUpdateAchievementCards;
local function UpdateAchievementCardsBySlice(categoryID)
    processor:Hide();
    AchievementContainer.scrollBar:SetValue(0);
    for i = 1, 7 do
        AchievementCards[i]:Hide();
    end
    local numAchievements, numCompleted, numIncomplete = GetCategoryNumAchievements(categoryID, false);
    DataProvider.numAchievements = numAchievements;
    processor.arg1 = categoryID;
    processor.arg2 = 1;     --fromIndex
    processor.func = SORT_FUNC;
    processor:Show();

    --animation

    if numAchievements ~= 0 then
        animFlip:Play(1);
    end
end

local function SwitchToSortMethod(index)
    if index == 2 then
        SORT_FUNC = Slice_UpdateAchievementCards;
    else
        SORT_FUNC = Slice_ReverselyUpdateAchievementCards;
    end

    local categoryID = DataProvider.currentCategory;
    if categoryID and categoryID ~= 0 then
        UpdateAchievementCardsBySlice(categoryID);
    end
end


---------------------------------------------------------------------------------------------------
local function UpdateCategoryScrollRange()
    local button, buttons;
    local totalHeight = 0;
    local parentButtons = CategoryButtons:GetActiveParentButtons();

    for i = 1, #parentButtons do
        button = parentButtons[i];
        if button.expanded then
            totalHeight = totalHeight + ( button.expandedHeight or 32);
        else
            totalHeight = totalHeight + 32;
        end

        totalHeight = totalHeight + 4;
    end

    local scrollBar = CategoryContainer.scrollBar;
    local newRange = max(0, totalHeight - CategoryContainer:GetHeight() + 52);
    local _, oldRange = scrollBar:GetMinMaxValues();

    CategoryContainer.positionFunc = nil;
    if (newRange < oldRange) and (scrollBar:GetValue() > newRange) then
        CategoryContainer.positionFunc = function(endValue, delta, scrollBar)
            if scrollBar:GetValue() <= newRange then
                CategoryContainer.positionFunc = nil;
                scrollBar:SetShown(newRange ~= 0);
                scrollBar:SetMinMaxValues(0, newRange);
                CategoryContainer.range = newRange;
            end
        end
    else
        scrollBar:SetShown(newRange ~= 0);
        scrollBar:SetMinMaxValues(0, newRange);
        CategoryContainer.range = newRange;
    end
end


local animExpand = NarciAPI_CreateAnimationFrame(0.25);
animExpand:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local height = outSine(self.total, self.fromHeight, self.toHeight, self.duration);
    if self.total >= self.duration then
        self:Hide()
        height = self.toHeight;
    end
    animExpand.object:SetHeight(height);
end)

function animExpand:Set(object, toHeight)
    if self:IsShown() then
        if object == self.object then
            self:Hide();
        else
            --Snap to destination
            self.object:SetHeight(self.toHeight);
            self:Hide();
        end
    end
    local fromHeight = object:GetHeight();
    self.object = object;
    self.fromHeight = fromHeight;
    self.toHeight = toHeight;
    local duration = sqrt(abs(fromHeight - toHeight)/32)*0.085;
    if duration > 0.01 then
        self.duration = duration;
        self:Show();
    end
end

function animExpand:CollapseAll()
    self:Hide();
    local button;
    local parentButtons = CategoryButtons:GetActiveParentButtons();

    for i = 1, #parentButtons do
        button = parentButtons[i];
        button.box:SetHeight(32);
        button.drawer:Hide();
        button.drawer:SetAlpha(0);
        button.expanded = nil;
        button.progress:Hide();
        button.percentSign:Show();
        button.value:Show();
    end
    local lastButton = DataProvider:GetCategoryButtonByID(DataProvider.currentCategory);
    if lastButton then
        lastButton.label:SetTextColor(0.8, 0.8, 0.8);
    end
    DataProvider.currentCategory = 0;

    CategoryContainer.scrollBar:SetValue(0);
    UpdateCategoryScrollRange();
end


local function SetCategoryButtonProgress(button, numAchievements, numCompleted, isFeatsOfStrength)
    if numAchievements == 0 or numCompleted == 0 then
        button.fill:Hide();
        button.fillEnd:Hide();
        button.progress:SetText(0 .."/".. numAchievements);
    else
        if isFeatsOfStrength then
            button.fill:Hide();
            button.fillEnd:Hide();
            button.progress:SetText(numCompleted);
        else
            local percentage = numCompleted / numAchievements;
            if false and percentage == 1 then
                button.fill:Hide();
                button.fillEnd:Hide();
                button.progress:SetText("");
            else
                button.fill:Show();
                button.fillEnd:Show();
                button.fill:SetWidth(button.fillWidth * percentage);
                button.fill:SetTexCoord(0, percentage *  0.75, 0, 1);
                button.progress:SetText(numCompleted .."/".. numAchievements);
            end
        end
    end
    button.progress:Show();
    button.percentSign:Hide();
    button.value:Hide();
    button.numAchievements, button.numCompleted = numAchievements, numCompleted;
end

local function UpdateCategoryButtonProgress(button)
    local categoryID = button.id;
    local totalAchievements, totalCompleted = GetCategoryNumAchievements(categoryID, true);   --ACHIEVEMENT_COMPARISON_SUMMARY_ID
    button.numAchievements, button.numCompleted = totalAchievements, totalCompleted;
    --print(button.label:GetText().." ".. totalCompleted .. "/" ..totalAchievements);
    local noPercent = button.noPercent;
    if noPercent then
        button.progress:SetText(totalCompleted);
    else
        button.progress:SetText(totalCompleted .."/".. totalAchievements);
    end

    if button.expanded then
        button.progress:Show();
        button.percentSign:Hide();
        button.value:Hide();
    else
        button.progress:Hide();
        button.percentSign:Show();
        button.value:Show();
    end


    if button.subCategories then
        local numAchievements, numCompleted;
        for i = 1, #button.subCategories do
            categoryID = button.subCategories[i];
            numAchievements, numCompleted = GetCategoryNumAchievements(categoryID, true);
            totalAchievements = totalAchievements + numAchievements;
            totalCompleted = totalCompleted + numCompleted;
            local childButton = DataProvider:GetCategoryButtonByID(categoryID);
            if childButton then
                SetCategoryButtonProgress(childButton, numAchievements, numCompleted, noPercent);
            end
        end
    end

    button.totalAchievements, button.totalCompleted = totalAchievements, totalCompleted;
    

    if totalAchievements == 0 or totalCompleted == 0 then
        button.fill:Hide();
        button.fillEnd:Hide();
        button.value:SetText("0");
    else
        if noPercent then
            button.fill:Hide();
            button.fillEnd:Hide();
            button.value:SetText(totalCompleted);
        else
            button.fill:Show();
            button.fillEnd:Show();

            local percentage = totalCompleted / totalAchievements;
            button.fill:SetWidth(button.fillWidth * percentage);
            button.fill:SetTexCoord(0, percentage *  0.75, 0, 1);
            if percentage == 1 then
                button.value:SetText("100");
            else
                button.value:SetText( floor(100 * percentage) );
            end
        end
    end
end

local function UpdateCategoryButtonProgressByCategoryID(categoryID)
    local button = DataProvider:GetCategoryButtonByID(categoryID);
    if button then
        UpdateCategoryButtonProgress(button)
    end
end

local function SelectCategory(categoryID)
    local numAchievements = GetCategoryNumAchievements(categoryID, false);
    InspectionFrame.numAchievements = numAchievements;
    UpdateAchievementCardsBySlice(categoryID);
end

local function SubCategoryButton_OnClick(button)
    local categoryID = button.id;
    if categoryID ~= DataProvider.currentCategory then
        --print(categoryID);
        local lastButton = DataProvider:GetCategoryButtonByID(DataProvider.currentCategory);
        DataProvider.currentCategory = categoryID;
        if lastButton then
            lastButton.label:SetTextColor(0.8, 0.8, 0.8);
        end
        button.label:SetTextColor(1, 0.91, 0.647);
        SelectCategory(categoryID);
    else
        --print("old")
    end
end

local function ToggleFeatOfStrenghtText(button)
    if button.isFoS then
        local _, totalCompleted = GetCategoryNumAchievements(button.id, false);
        if totalCompleted == 0 then
            if isGuildView then
                MainFrame.FeatOfStrengthText:SetText(GUILD_FEAT_OF_STRENGTH_DESCRIPTION);
            else
                MainFrame.FeatOfStrengthText:SetText(FEAT_OF_STRENGTH_DESCRIPTION);
            end
            MainFrame.FeatOfStrengthText:Show();
        else
            MainFrame.FeatOfStrengthText:Hide();
        end
    else
        MainFrame.FeatOfStrengthText:Hide();
    end
end

local function CategoryButton_OnClick(button, mouse)
    AchievementContainer:Show();
    SummaryFrame:Hide();
    SummaryButton:Show();

    local expandedHeight = button.expandedHeight;
    local isExpanded = not button.expanded;
    if expandedHeight ~= 32 then
        if (mouse == "RightButton" or DataProvider.currentCategory == button.id) and (not isExpanded) then
            FadeFrame(button.drawer, 0.15, 0);
            animExpand:Set(button.box, 32);
            button.expanded = nil;
        else
            FadeFrame(button.drawer, 0.2, 1);
            animExpand:Set(button.box, expandedHeight);
            button.expanded = true;
            if mouse ~= "RightButton" then
                SubCategoryButton_OnClick(button);
            end
        end
    else
        button.expanded = isExpanded;
        SubCategoryButton_OnClick(button);
    end

    if button.expanded then
        button.progress:Show();
        button.percentSign:Hide();
        button.value:Hide();
    else
        button.progress:Hide();
        button.percentSign:Show();
        button.value:Show();
    end

    UpdateCategoryScrollRange();


    ----
    ToggleFeatOfStrenghtText(button);
end

local function ExpandCategoryButtonNoAnimation(button)
    if not button then return end;

    if not button.expanded then
        button.progress:Show();
        button.percentSign:Hide();
        button.value:Hide();

        local expandedHeight = button.expandedHeight;
        if expandedHeight ~= 32 then
            button.box:SetHeight(expandedHeight);
            button.drawer:Show();
            button.drawer:SetAlpha(1);
        end
        button.expanded = true;

        UpdateCategoryScrollRange();
        ToggleFeatOfStrenghtText(button);
    end
end

local function BuildCategoryStructure(isGuild)
    local GUILD_FEAT_OF_STRENGTH_ID = 15093;
    local GUILD_CATEGORY_ID = 15076;


    local categories, structure, feats, legacys;
    if isGuild then
        categories = GetGuildCategoryList();
        structure = CategoryStructure.guild;
        feats = { FEAT_OF_STRENGTH_ID };
        legacys = {};
    else
        categories = GetCategoryList();
        structure = CategoryStructure.player;
        feats = { GUILD_FEAT_OF_STRENGTH_ID };
        legacys = { LEGACY_ID };
    end

    local id;
    local name, parentID;
    local id2Order = {};
    local subCategories = {};

    local numParent = 0;
    
    for i = 1, #categories do
        id = categories[i];
        name, parentID = DataProvider:GetCategoryInfo(id);
        --print(name, parentID)
        if (parentID == -1 or parentID == 15076) then
            if not id2Order[id] then 
                numParent = numParent + 1;
                structure[ numParent ] = { ["id"] = id, ["name"] = name, ["children"] = {} };
                id2Order[ id ] = numParent;
            end
        else
            tinsert(subCategories, id);
        end

        if parentID == LEGACY_ID then
            tinsert(legacys, id);
        elseif parentID == FEAT_OF_STRENGTH_ID then
            tinsert(feats, id);
        end
    end

    local order;
    for i = 1, #subCategories do
        id = subCategories[i];
        name, parentID = DataProvider:GetCategoryInfo(id);
        
        order = id2Order[parentID];
        tinsert( structure[ order ].children,  id);
    end

    structure.numCategories = #categories;
end

local function CreateCategoryButtons(isGuild)
    local frame;
    local button, parentButton, parentData, id;
    local structure;
    local numButtons = 0;
    local parentButtons, buttons;

    if not CategoryButtons.buttons then
        CategoryButtons.buttons = {};
    end

    local parentButtons = CategoryButtons:GetActiveParentButtons(isGuild);
    if isGuild then
        buttons = CategoryButtons.guild.buttons;
        structure = CategoryStructure.guild;
        frame = CategoryContainer.ScrollChild.GuildCategory;
        CategoryContainer.ScrollChild.PlayerCategory:Hide();
    else
        buttons = CategoryButtons.player.buttons;
        structure = CategoryStructure.player;
        frame = CategoryContainer.ScrollChild.PlayerCategory;
        CategoryContainer.ScrollChild.GuildCategory:Hide();
    end
    frame:Show();
    
    for i = 1, #structure do
        numButtons = numButtons + 1;
        parentButton = buttons[numButtons];
        parentData = structure[i];
        id = parentData.id;

        if not parentButton then
            parentButton = CreateFrame("Button", nil, frame, "NarciAchievementCategoryButtonTemplate");
            tinsert(buttons, parentButton);
            tinsert(parentButtons, parentButton);
            parentButton.isParentButton = true;
            parentButton:SetScript("OnClick", CategoryButton_OnClick);
        end
        
        DataProvider.id2Button[id] = parentButton;
        parentButton:SetParent(frame);
        parentButton:ClearAllPoints();

        if i == 1 then
            parentButton:SetPoint("TOP", frame, "TOP", 2 , -24);
        else
            parentButton:SetPoint("TOP", parentButtons[i - 1].box, "BOTTOM", 0, -2);
        end

        if id == LEGACY_ID or id == FEAT_OF_STRENGTH_ID or id == 15093 then
            parentButton.noPercent = true;
            parentButton.percentSign:SetText("");
            parentButton.value:SetPoint("RIGHT", parentButton, "RIGHT", -10, 0);
            if id == FEAT_OF_STRENGTH_ID or id == 15093 then
                parentButton.isFoS = true;
            end
        else
            parentButton.noPercent = nil;
            parentButton.percentSign:SetText("%");
            parentButton.value:SetPoint("RIGHT", parentButton, "RIGHT", -16, 0);
        end

        parentButton.id = id;
        parentButton.label:SetText(parentData.name);
        parentButton.subCategories = parentData.children;

        local numChildren = #parentData.children;
        parentButton.expandedHeight = numChildren * 32 + 32;

        for j = 1, numChildren do
            button = buttons[numButtons + 1];
            id = parentData.children[j];
            if not button then
                button = CreateFrame("Button", nil, parentButton.drawer, "NarciAchievementSubCategoryButtonTemplate");
                button.label:SetWidth(130);
                tinsert(buttons, button);
                button:SetScript("OnClick", SubCategoryButton_OnClick);
            end
            DataProvider.id2Button[id] = button;
            button:SetParent(parentButton.drawer);

            button:ClearAllPoints();
            if j == 1 then
                button:SetPoint("TOPRIGHT", parentButton.drawer, "BOTTOMRIGHT", 0, 0);
            else
                button:SetPoint("TOPRIGHT", buttons[numButtons], "BOTTOMRIGHT", 0, 0);
            end
            numButtons = numButtons + 1;
            
            button.id = id;
            button.label:SetText( DataProvider:GetCategoryInfo(id, 1) );
            button.noPercent = nil;
        end

        UpdateCategoryButtonProgress(parentButton);
    end
end


local function CreateAchievementButtons(frame)
    local button;
    local buttons = {};
    local numButtons = 0;

    for i = 1, 40 do
        button = CreateFrame("Button", nil, frame, "NarciAchievementCardLargeTemplate");
        button:SetScript("OnClick", AchievementCard_OnClick);
        button.index = i;
        --button.RewardFrame:SetScript("OnEnter", SetItemPreview);
        --button.RewardFrame:SetScript("OnLeave", HideItemPreview);
        tinsert(buttons, button);
        if i == 1 then
            button:SetPoint("TOP", frame, "TOP", 0, -18);
        else
            button:SetPoint("TOP", buttons[i - 1], "BOTTOM", 0, -4);
        end
        ReskinButton(button);
    end

    frame.buttons = buttons;
    AchievementCards = buttons;

    --Pop-up Card : Achievement details
    local Card = InspectionFrame.Card
    Card:SetScript("OnClick", AchievementCard_OnClick);
    AchievementCards[-1] = Card;
    animFlyIn.Card = Card;
    animFlyOut.Card = Card;
    animFlyIn.header = Card.header;
    animFlyIn.description = Card.description;
    animFlyIn.date = Card.date;
    animFlyIn.reward = Card.RewardFrame;
end

local function UpdateRenderedArea(value)
    --103 avg. height
    local firstIndex = max(1, ceil(value/98) - 2);
    local lastIndex = firstIndex + 22;
    
    for i = 1, firstIndex - 1 do
        if AchievementCards[i] then
            AchievementCards[i]:Hide();
        end
    end
    for i = lastIndex + 1, InspectionFrame.numAchievements do
        if AchievementCards[i] then
            AchievementCards[i]:Hide();
        end
    end
    for i = firstIndex, lastIndex do
        if AchievementCards[i] then
            AchievementCards[i]:Show();
        end
    end
end

------------------------------------------------
NarciAchievementInspectionFrameMixin = {};

function NarciAchievementInspectionFrameMixin:OnLoad()
    if not self.isLoaded then
        self.isLoaded = true;
    else
        return
    end

    InspectionFrame = self;

    local CompleteFrame = self.CriteriaFrame.LeftInset;
    CompleteFrame.header:SetText("COMPLETED");
    CompleteFrame.header:SetTextColor(0.216, 0.502, 0.2);
    CompleteFrame.count:SetTextColor(0.216, 0.502, 0.2);
    self.numCompleted = CompleteFrame.count;

    local IncompleteFrame = self.CriteriaFrame.RightInset;
    IncompleteFrame.header:SetText("INCOMPLETED");
    IncompleteFrame.header:SetTextColor(0.502, 0.2, 0.2);
    IncompleteFrame.count:SetTextColor(0.502, 0.2, 0.2);
    self.numIncomplete = IncompleteFrame.count;

    animFlyIn.background = self.blur;
    animFlyIn.ObjectiveFrame = self.CriteriaFrame;
    animFlyIn.ChainFrame = self.ChainFrame;
    animFlyOut.background = self.blur;
    animFlyOut.ObjectiveFrame = self.CriteriaFrame;
    animFlyOut.ChainFrame = self.ChainFrame;

    self.inspectedButtonIndex = 1;


    self.TextContainerLeft = self.CriteriaFrame.LeftInset.TextFrame;
    self.TextContainerRight = self.CriteriaFrame.RightInset.TextFrame;
    self.MetaContainerLeft = self.CriteriaFrame.LeftInset.MetaFrame;
    self.MetaContainerRight = self.CriteriaFrame.RightInset.MetaFrame;
    self.BarContainerLeft = self.CriteriaFrame.LeftInset.BarFrame;
    self.BarContainerRight = self.CriteriaFrame.RightInset.BarFrame;


    --Achievement Container Blur
    local BlurFrame = self.blur;
    local BlurAnchor = BlurFrame.ScrollChild;
    local blur1 = BlurFrame.ScrollChild.blur1;
    local blur2 = BlurFrame.ScrollChild.blur2;

    local deltaRatio = 1;
    local speedRatio = 0.24;
    local blurHeight = 77;
    local range = 10000;
    local RepositionBlur = function(value, delta)
        local index;
        if delta < 0 then
            index = ceil( (value - 200) /940);
        else
            index = ceil( (value - 200) /940) - 1;
        end
        if index < 0 then
            index = 1;
        end
        if index ~= self.blurOffset then
            self.blurOffset = index;
            if index % 2 == 1 then
                blur2:SetPoint("TOPLEFT", BlurAnchor, "TOPLEFT", 0, -index * 940);
                blur2:SetPoint("TOPRIGHT", BlurAnchor, "TOPRIGHT", 0, -index * 940);
            else
                blur1:SetPoint("TOPLEFT", BlurAnchor, "TOPLEFT", 0, -index * 940);
                blur1:SetPoint("TOPRIGHT", BlurAnchor, "TOPRIGHT", 0, -index * 940);
            end
        end
    end


    NarciAPI_ApplySmoothScrollToScrollFrame(BlurFrame, deltaRatio, speedRatio, RepositionBlur, blurHeight, range);
    local Blur_OnMouseWheel = BlurFrame:GetScript("OnMouseWheel");

    function self:ScrollBlur(delta)
        Blur_OnMouseWheel(BlurFrame, delta);
        ReturnButton:Hide();
    end

    function self:SyncBlurOffset(buttonIndex)
        self.blurOffset = -1;
        local value = (buttonIndex - 1) * blurHeight;
        BlurFrame.scrollBar:SetValue(value);

        local index = ceil( (value - 200) /940);
        if index < 0 then
            index = 1;
        end
        if index % 2 == 1 then
            blur1:SetPoint("TOPLEFT", BlurAnchor, "TOPLEFT", 0, (1 - index) * 940);
            blur1:SetPoint("TOPRIGHT", BlurAnchor, "TOPRIGHT", 0, (1 - index) * 940);
            blur2:SetPoint("TOPLEFT", BlurAnchor, "TOPLEFT", 0, -index * 940);
            blur2:SetPoint("TOPRIGHT", BlurAnchor, "TOPRIGHT", 0, -index * 940);
        else
            blur1:SetPoint("TOPLEFT", BlurAnchor, "TOPLEFT", 0, -index * 940);
            blur1:SetPoint("TOPRIGHT", BlurAnchor, "TOPRIGHT", 0, -index * 940);
            blur2:SetPoint("TOPLEFT", BlurAnchor, "TOPLEFT", 0, (1- index) * 940);
            blur2:SetPoint("TOPRIGHT", BlurAnchor, "TOPRIGHT", 0, (1 -index) * 940);
        end
    end

    --ScrollFrames: Criteria: Text, Meta
    local function UpdateScrollFrameDivider(value, delta, scrollBar)
        local minVal, maxVal = scrollBar:GetMinMaxValues();

        if value >= maxVal - 0.1 then
            scrollBar.divLeft:Hide();
            scrollBar.divCenter:Hide();
            scrollBar.divRight:Hide();
        elseif maxVal ~= 0 then
            scrollBar.divLeft:Show();
            scrollBar.divCenter:Show();
            scrollBar.divRight:Show();
        end
    end

    local positionFunc = UpdateScrollFrameDivider;
    local parentScrollFunc = function(delta)
        InspectionFrame:OnMouseWheel(delta);
    end

    local numLines = 30;
    local deltaRatio = 2;
    local speedRatio = 0.24;
    local buttonHeight = 26;
    local range = numLines * buttonHeight - IncompleteFrame:GetHeight();
    
    NarciAPI_ApplySmoothScrollToScrollFrame(IncompleteFrame.TextFrame, deltaRatio, speedRatio, positionFunc, buttonHeight, range, parentScrollFunc);
    NarciAPI_ApplySmoothScrollToScrollFrame(CompleteFrame.TextFrame, deltaRatio, speedRatio, positionFunc, buttonHeight, range, parentScrollFunc);

    local buttonHeight = 36;
    local deltaRatio = 2;
    NarciAPI_ApplySmoothScrollToScrollFrame(IncompleteFrame.MetaFrame, deltaRatio, speedRatio, positionFunc, buttonHeight, range, parentScrollFunc);
    NarciAPI_ApplySmoothScrollToScrollFrame(CompleteFrame.MetaFrame, deltaRatio, speedRatio, positionFunc, buttonHeight, range, parentScrollFunc);
end

function NarciAchievementInspectionFrameMixin:OnShow()
    self.isTransiting = nil;
end

function NarciAchievementInspectionFrameMixin:OnMouseDown()
    animFlyOut:Play();
end

function NarciAchievementInspectionFrameMixin:ScrollToCategoryButton(button)
    if button then
        local topButton =  CategoryButtons.player.buttons[1];
        local offset = max(0, topButton:GetTop() -  button:GetTop() - (CategoryContainer:GetHeight()/2 or 32) +32); --Attempt to position it to the vertical center
        CategoryContainer.scrollBar:SetValue(offset);
    end
end

function NarciAchievementInspectionFrameMixin:ScrollToButton(button)
    if button then
        local offset = AchievementCards[1]:GetTop() -  button:GetTop();
        AchievementContainer.scrollBar:SetValue(offset);
        UpdateRenderedArea(offset);
    end
end

function NarciAchievementInspectionFrameMixin:OnMouseWheel(delta)
    if self.isTransiting or self.pauseScroll then return end;

    local categoryID = DataProvider.currentCategory;
    local numAchievements = self.numAchievements;
    local index = self.inspectedButtonIndex;
    if delta > 0 then
        if index == 1 then
            return
        else
            index = index - 1;
        end
    else
        if index == numAchievements then
            return
        else
            index = index + 1;
        end
    end
    self:ScrollBlur(delta);

    self.inspectedButtonIndex = index;

    local newButton = AchievementCards[index];
    self:ScrollToButton(newButton);
    InspectCard(newButton)
    --local id = DataProvider:GetAchievementInfoByOrder(categoryID, index)
    --InspectAchievement(id);
end

local function FormatTextButtons(container, data, count, completed)
    if not container.buttons then
        container.buttons = {};
    end
    local buttons = container.buttons;
    local button, numLines;
    
    for i = 1, count do
        button = buttons[i];
        if not button then
            button = CreateFrame("Button", nil, container.ScrollChild, "NarciAchievementObjectiveTextButton");
            tinsert(buttons, button);
            if i == 1 then
                button:SetPoint("TOPLEFT", container.ScrollChild, "TOPLEFT", 0, 0);
                button:SetPoint("TOPRIGHT", container.ScrollChild, "TOPRIGHT", 0, 0);
            elseif i % 5 == 1 then
                --bigger distance for every 5 entries
                button:SetPoint("TOPLEFT", buttons[i - 1], "BOTTOMLEFT", 0, -14);
                button:SetPoint("TOPRIGHT", buttons[i - 1], "TOPRIGHT", 0, -14);
            else
                button:SetPoint("TOPLEFT", buttons[i - 1], "BOTTOMLEFT", 0, 0);
                button:SetPoint("TOPRIGHT", buttons[i - 1], "TOPRIGHT", 0, 0);
            end

            if not completed then
                button.dash:SetTextColor(0.6, 0.6, 0.6);
                button.icon:SetDesaturated(true);
            else
                button.dash:SetText("|CFF5fbb46- |r");
                button.icon:SetDesaturated(false);
            end
        end
        button.name:SetText(data.names[i]);
        numLines = ceil( button.name:GetHeight() / 12 - 0.1 );
        button.icon:SetTexture(nil);
        if icon and false then
            button:SetHeight(32 + (numLines - 1)*12 );
        else
            button:SetHeight(18 + (numLines - 1)*12 );
        end
        
        button:Show();
    end

    for i = count + 1, #buttons do
        buttons[i]:Hide();
    end

    --Update Scroll Range
    local scrollBar = container.scrollBar;
    local range;
    if count == 0 then
        range = 0;
    else
        range = max(0, buttons[1]:GetTop() -  buttons[count]:GetBottom() - container:GetHeight() + 4);
    end
    scrollBar:SetValue(0);
    scrollBar:SetMinMaxValues(0, range);
    scrollBar:SetShown(range ~= 0);
    container.positionFunc(0, 1, scrollBar);
    container.range = range;
end

local function FormatMetaButtons(container, data, count, completed)
    if not container.buttons then
        container.buttons = {};
    end
    local buttons = container.buttons;
    local button, icon;

    for i = 1, count do
        button = buttons[i];
        if not button then
            button = CreateFrame("Button", nil, container.ScrollChild, "NarciAchievementObjectiveMetaAchievementButton");
            tinsert(buttons, button);
            if i == 1 then
                local buttonWidth = button:GetWidth();
                button:SetPoint("TOP", container.ScrollChild, "TOP", -(buttonWidth + 1) * 3, 0);
            elseif i % 7 == 1 then
                button:SetPoint("TOPLEFT", buttons[i - 7], "BOTTOMLEFT", 0, -1);
            else
                button:SetPoint("TOPLEFT", buttons[i - 1], "TOPRIGHT", 1, 0);
            end
            if not completed then
                button.icon:SetDesaturated(true);
            end
        end
        icon = data.icons[i];
        button.icon:SetTexture(icon);
        local id = data.assetIDs[i];
        button.id = id;
        if id then
            button.textMode = nil;
            button.criteriaString = nil;
        else
            button.textMode = true;
            button.criteriaString = data.names[i];
            if completed then
                button.icon:SetTexture(461267);     --ThumbsUp
            else
                button.icon:SetTexture(456031);     --Thumbsdown
            end
        end
        button.trackIcon:SetShown( DataProvider:IsTrackedAchievement(id) );
        button:Show();
    end
    for i = count + 1, #buttons do
        buttons[i]:Hide();
    end

    local header = container.name;
    local numRow = ceil( count / 7);

    header:ClearAllPoints();
    if numRow < 3 then
        header:SetPoint("TOPLEFT", buttons[1 + (numRow - 1)*7], "BOTTOMLEFT", 3, -4);
    else
        header:SetPoint("TOPLEFT", container, "BOTTOMLEFT", 3, -16);
    end

    if completed then
        header:SetText("");
        container.description:SetText("");
        container.points:SetText("");
        container.shield:Hide();
    else
        buttons[1]:SetAchievement();
    end

    --Update Scroll Range
    local scrollBar = container.scrollBar;
    local range;
    if count == 0 then
        range = 0;
    else
        range = max(0, buttons[1]:GetTop() -  buttons[count]:GetBottom() - container:GetHeight());
    end
    scrollBar:SetValue(0);
    scrollBar:SetMinMaxValues(0, range);
    scrollBar:SetShown(range ~= 0);
    container.positionFunc(0, 1, scrollBar);
    container.range = range;
end

local function FormatStatusBars(container, data, count, completed)
    if not container.bars then
        container.bars = {};
    end
    local bars = container.bars;
    local numBars = #data.bars;
    local bar, barData;

    for i = 1, numBars do
        bar = bars[i];
        if not bar then
            bar = CreateFrame("Button", nil, container, "NarciAchievementObjectiveStatusBar");
            tinsert(bars, bar);
            if i == 1 then
                bar:SetPoint("TOP", container, "TOP", 0, -2);
            else
                bar:SetPoint("TOP", bars[i - 1], "BOTTOM", 0, -16);
            end
            if completed then
                bar.label:SetTextColor(0.8, 0.8, 0.8);
            else
                bar.label:SetTextColor(0.6, 0.6, 0.6);
            end
        end
        barData = data.bars[i];
        bar:SetMinMaxValues(0, barData[2]);
        bar:SetValue(barData[1], true);
        bar.label:SetText(barData[3]);
        bar:SetHeight(bar.label:GetHeight() + 22);
        bar:Show();
    end
    for i = numBars + 1, #bars do
        bars[i]:Hide();
    end
end

function NarciAchievementInspectionFrameMixin:FindParentAchievementID(achievementID)
    local parentAchievementID = GetParentAchievementID(achievementID);
    local button = AchievementCards[-1].ParentAchievmentButton;
    if parentAchievementID then
        local _, name, _, completed, month, day, year, _, _, icon = DataProvider:GetAchievementInfo(parentAchievementID);
        if completed then
            button:SetAlpha(1);
        else
            button:SetAlpha(0.60);
        end
        button.name = name;
        button.id = parentAchievementID;
        button.icon:SetTexture(icon);
        button.icon:SetDesaturated(not completed);
        button:Show();
        if not button.hasInitialized then
            button.hasInitialized = true;
            button.border:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Shared\\IconBorderMiniPointRight");
        end
    else
        button:Hide();
    end
end

function NarciAchievementInspectionFrameMixin:UpdateChain(achievementID, currentIsCompleted)
    local ChainFrame = self.ChainFrame;
    if not ChainFrame.buttons then
        ChainFrame.buttons = {};
    end
    local buttons = ChainFrame.buttons;
    local button;
    local achievements = { achievementID };
    local currentAchievementID = achievementID;
    local currentPosition = 1;

    achievementID = GetPreviousAchievement(currentAchievementID);
    while achievementID do
        tinsert(achievements, 1, achievementID);
        achievementID = GetPreviousAchievement(achievementID);
        currentPosition = currentPosition + 1;
    end

    achievementID = GetNextAchievement(currentAchievementID);
    while achievementID do
        tinsert(achievements, achievementID);
        achievementID = GetNextAchievement(achievementID);
    end

    local numAchievements = #achievements;
    
    if numAchievements > 1 then
        local gap = 1;
        local extraHeight = 0;
        local buttonWidth;
        local id, completed, month, day, year, icon, _;
        local numCompleted = 0;
        for i = 1, numAchievements do
            button = buttons[i];
            if not button then
                button = CreateFrame("Button", nil, ChainFrame, "NarciAchievementChainButton");
                button.date.flyIn.hold1:SetDuration( (i - 1)*0.025 );
                button.date.flyIn.hold2:SetDuration( (i - 1)*0.025 );
                tinsert(buttons, button);
            end

            id = achievements[i];
            _, _, _, completed, month, day, year, _, _, icon = DataProvider:GetAchievementInfo(id);
            if completed then
                numCompleted = numCompleted + 1;
            end

            button:ClearAllPoints();
            if i == 1 then
                buttonWidth = button:GetWidth();
                local numButtonsFirstRow = min(15, numAchievements);
                button:SetPoint("CENTER", ChainFrame.reference, "TOP", (buttonWidth + gap)*(1 - numButtonsFirstRow)/2 , -buttonWidth/2);
                buttonWidth = buttonWidth + gap;
            elseif i % 15 == 1 then
                --15 buttons per row
                local numButtonsThisRow = mod(numAchievements, 15);
                extraHeight = extraHeight + buttonWidth;
                local offsetY;
                if ChainFrame.showDates and completed then
                    offsetY = -78;
                else
                    offsetY = -1.5 * buttonWidth;
                end
                button:SetPoint("CENTER", ChainFrame.reference, "TOP", (buttonWidth + gap)*(1 - numButtonsThisRow)/2, offsetY);
            else
                button:SetPoint("CENTER", buttons[i - 1], "CENTER", buttonWidth, 0);
            end

            if i == currentPosition then
                button.border:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Shared\\IconBorderPointyMini");
                button:SetAlpha(1);
            else
                button.border:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Shared\\IconBorderMini");
                if completed then
                    button:SetAlpha(0.60);
                else
                    button:SetAlpha(0.33);
                end
            end

            if completed then
                button.date:SetText( FormatDate(day, month, year, true) );
            else
                button.date:SetText("");
            end

            button.icon:SetDesaturated(not completed);
            button.id = id;
            button.icon:SetTexture(icon);
            button:Show();
        end

        for i = numAchievements + 1, #buttons do
            buttons[i]:Hide();
        end

        ChainFrame.count:SetText( numCompleted .."/".. numAchievements);

        ChainFrame.reference:SetHeight(34 + extraHeight);   --base height 34
        ChainFrame:Show();

        return true
    else
        ChainFrame:Hide();
        return false
    end
end

function NarciAchievementInspectionFrameMixin:DisplayCriteria(cData, iData)
    local numCompleted = cData.count;
    local numIncomplete = iData.count;
    
    self.numCompleted:SetText(numCompleted);
    self.numIncomplete:SetText(numIncomplete);

    local TextContainer = self.TextContainerLeft;
    local MetaContainer = self.MetaContainerLeft;
    local BarContainer = self.BarContainerLeft;
    local icon = cData.icons[1];
    local numBars = #cData.bars;
    local type = 1;
    if numBars ~= 0 then
        type = 3
    elseif icon then
        type = 2;
    end

    if numCompleted == 0 then
        TextContainer:Hide();
        MetaContainer:Hide();
        BarContainer:Hide();
    else
        if type == 2 then
            TextContainer:Hide();
            MetaContainer:Show();
            BarContainer:Hide();
            FormatMetaButtons(MetaContainer, cData, numCompleted, true);
        elseif type == 3 then
            TextContainer:Hide();
            MetaContainer:Hide();
            BarContainer:Show();
            FormatStatusBars(BarContainer, cData, numCompleted, true);
        else
            TextContainer:Show();
            MetaContainer:Hide();
            BarContainer:Hide();
            FormatTextButtons(TextContainer, cData, numCompleted, true);
        end
    end

    --
    local TextContainer = self.TextContainerRight;
    local MetaContainer = self.MetaContainerRight;
    local BarContainer = self.BarContainerRight;
    local icon = iData.icons[1];
    local numBars = #iData.bars;
    local type = 1;
    if numBars ~= 0 then
        type = 3
    elseif icon then
        type = 2;
    end

    if numIncomplete == 0 then
        TextContainer:Hide();
        MetaContainer:Hide();
        BarContainer:Hide();
    else
        if type == 2 then
            TextContainer:Hide();
            MetaContainer:Show();
            BarContainer:Hide();
            FormatMetaButtons(MetaContainer, iData, numIncomplete);
        elseif type == 3 then
            TextContainer:Hide();
            MetaContainer:Hide();
            BarContainer:Show();
            FormatStatusBars(BarContainer, iData, numIncomplete);
        else
            TextContainer:Show();
            MetaContainer:Hide();
            BarContainer:Hide();
            FormatTextButtons(TextContainer, iData, numIncomplete);
        end
    end
end

function NarciAchievementInspectionFrameMixin:ShowOrHideChainDates()
    local ChainFrame = self.ChainFrame;
    local showDates = ChainFrame.showDates;
    local buttons = ChainFrame.buttons;
    local button;

    local offsetY;
    if showDates then
        offsetY = -78;
    else
        offsetY = -52.5;
    end

    for i = 1, #buttons do
        button = buttons[i];
        button.date:SetShown(showDates);
        if showDates then
            button.date.flyIn:Play();
        else
            button.date.flyIn:Stop();
        end

        if i ~= 1 and i % 15 == 1 then
            local date = button.date:GetText();
            if date and date ~= "" then
                local point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint();
                button:SetPoint(point, relativeTo, relativePoint, xOfs, offsetY);
            end
        end
    end

    --Update toggle visual
    if showDates then
        ChainFrame.DateToggle:SetLabelText(L["Hide Dates"]);
    else
        ChainFrame.DateToggle:SetLabelText(L["Show Dates"]);
    end
    ChainFrame.count:SetShown(not showDates);
    ChainFrame.header:SetShown(not showDates);
    ChainFrame.divLeft:SetShown(not showDates);
    ChainFrame.divRight:SetShown(not showDates);
end


------------------------------------------------------------------------------
NarciAchievementGoToCategoryButtonMixin = {};

function NarciAchievementGoToCategoryButtonMixin:OnLoad()
    GoToCategoryButton = self;
    self:OnLeave();
end

function NarciAchievementGoToCategoryButtonMixin:OnEnter()
    self.Label:SetTextColor(0.8, 0.8, 0.8);
    self.Icon:SetTexCoord(0.5, 1, 0, 1);
    self.Icon:SetAlpha(0.6);
end

function NarciAchievementGoToCategoryButtonMixin:OnLeave()
    self.Label:SetTextColor(0.6, 0.6, 0.6);
    self.Icon:SetTexCoord(0, 0.5, 0, 1);
    self.Icon:SetAlpha(0.4);
end

function NarciAchievementGoToCategoryButtonMixin:OnClick()
    if self.categoryID then
        local categoryButton = DataProvider:GetCategoryButtonByID(self.categoryID, self.isGuild);
        if categoryButton and (self.categoryID ~= DataProvider.currentCategory) then
            if not categoryButton.isParentButton then
                local parentCategoryButton = DataProvider:GetCategoryButtonByID(self.parentCategoryID, self.isGuild);
                ExpandCategoryButtonNoAnimation(parentCategoryButton);
            end
            categoryButton:Click();
            animFlyOut.noTranslation = true;
            animFlyOut:Play();

            InspectionFrame:ScrollToCategoryButton(categoryButton);

            AchievementContainer:Show();
            SummaryFrame:Hide();
            SummaryButton:Show();
        else
            animFlyOut:Play();
        end
    end
end

function NarciAchievementGoToCategoryButtonMixin:SetAchievement(achievementID, isGuild)
    local categoryID = GetAchievementCategory(achievementID);
    local name, parentCategoryID = DataProvider:GetCategoryInfo(categoryID);
    if categoryID then
        self.categoryID = categoryID;
        self.parentCategoryID = parentCategoryID;
        self.isGuild = isGuild;
        self.Label:SetText(name);
        self:Show();
        self:SetWidth(max(self.Label:GetWidth() + 60, 96));
    end
end


NarciMetaAchievementButtonMixin = {};

function NarciMetaAchievementButtonMixin:SetAchievement()
    local id = self.id;
    if id then
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText = DataProvider:GetAchievementInfo(id);
        local parent = self:GetParent():GetParent();
        parent.name:SetText(name);
        parent.description:SetText(description);
        parent.points:SetText(points);
        parent.shield:SetShown(points ~= 0);
        if completed then
            if flags and flags == 131072 then
                parent.name:SetTextColor(0.427, 0.812, 0.965);
            else
                parent.name:SetTextColor(1, 0.91, 0.647);
            end
        else
            parent.name:SetTextColor(0.8, 0.8, 0.8);
        end

        self.name = name;
    end
end

function NarciMetaAchievementButtonMixin:OnEnter()
    if self.textMode then
        local parent = self:GetParent():GetParent();
        parent.name:SetText(self.criteriaString);
        parent.description:SetText(nil);
        parent.points:SetText(nil);
        parent.shield:Hide();
    else
        self:SetAchievement();
    end
    self.icon.animIn:Play();
    self.border.animIn:Play();
end

function NarciMetaAchievementButtonMixin:OnLeave()
    self.icon.animIn:Stop();
    self.border.animIn:Stop();
    self.icon:SetScale(1);
    self.border:SetScale(1);
end

function NarciMetaAchievementButtonMixin:OnClick()
    if ProcessModifiedClick(self) then return end;

    local id = InspectionFrame.currentAchievementID;
    if id and id ~= self.id then
        ReturnButton:AddToQueue(id, InspectionFrame.currentAchievementName);
        InspectAchievement(self.id);
    end
end

NarciAchievementChainButtonMixin = {};

function NarciAchievementChainButtonMixin:OnLoad()
    
end

function NarciAchievementChainButtonMixin:OnEnter()
    self:SetAchievement();
    self.icon.animIn:Play();
    self.border.animIn:Play();
end

function NarciAchievementChainButtonMixin:OnLeave()
    self.icon.animIn:Stop();
    self.border.animIn:Stop();
    self.icon:SetScale(1);
    self.border:SetScale(1);

    Tooltip:FadeOut();
    local ChainFrame = self:GetParent();
    if ChainFrame.DateToggle and not ChainFrame:IsMouseOver() then
        ChainFrame.DateToggle:FadeOut();
    end
end

function NarciAchievementChainButtonMixin:SetAchievement()
    local id = self.id;
    if id then
        Tooltip:ClearAllPoints();
        Tooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 1, -2);
        Tooltip:SetAchievement(id);
    end
end

function NarciAchievementChainButtonMixin:OnMouseDown()
    Tooltip:FadeOut();
end

NarciAchievementTooltipMixin = {};

function NarciAchievementTooltipMixin:OnLoad()
    local animFade = NarciAPI_CreateAnimationFrame(0.25);
    self.animFade = animFade;
    animFade:SetScript("OnUpdate", function(frame, elapsed)
        frame.total = frame.total + elapsed;
        local alpha = outQuart(frame.total, frame.fromAlpha, frame.toAlpha, frame.duration);
        if frame.total >= frame.duration then
            frame:Hide();
            alpha = frame.toAlpha;
            if alpha == 0 then
                self:Hide();
            end
        end
        self:SetAlpha(alpha);
    end)

    function self:FadeIn()
        if InspectionFrame.isTransiting then return end;
        self:Show();
        animFade:Hide();
        animFade.fromAlpha = self:GetAlpha();
        animFade.toAlpha = 1;
        animFade:Show();
    end

    function self:FadeOut()
        animFade.toAlpha = 0;
        if not self:IsShown() then return end;
        animFade:Hide();
        animFade.fromAlpha = self:GetAlpha();
        animFade:Show();
    end

    local showDelay = NarciAPI_CreateAnimationFrame(0.12);
    self.showDelay = showDelay;
    showDelay:SetScript("OnUpdate", function(frame, elapsed)
        frame.total = frame.total + elapsed;
        if frame.total >= frame.duration then
            frame:Hide();
            if animFade.toAlpha == 1 then
                self:FadeIn();
            end
        end
    end)
end

function NarciAchievementTooltipMixin:OnHide()
    self:Hide();
    self:SetAlpha(0);
end

function NarciAchievementTooltipMixin:ResizeAndShow()
    --local textWidth = min(280, self.description:GetWidth());
    --self.description:SetWidth(textWidth);
    --self:SetWidth(textWidth + 32);
    self:SetHeight( self.name:GetHeight() + self.description:GetHeight() + 4 + 24 );
    
    if not self:IsShown() then
        self.animFade.toAlpha = 1;
        self.showDelay:Show();
    elseif self.animFade.toAlpha == 0 then
        self:FadeIn();
    end
end

function NarciAchievementTooltipMixin:SetAchievement(id)
    local _, name, points, completed, month, day, year, description, flags, icon = DataProvider:GetAchievementInfo(id);

    self.name:SetText(name);
    self.description:SetText(description);
    
    if completed then
        if flags and flags == 131072 then
            self.name:SetTextColor(0.427, 0.812, 0.965);
        else
            self.name:SetTextColor(1, 0.91, 0.647);
        end
        self.date:SetText( FormatDate(day, month, year) );
    else
        self.name:SetTextColor(0.8, 0.8, 0.8);
        self.date:SetText("");
    end

    if points == 0 then
        self.shield:Hide();
        self.points:Hide();
    else
        self.shield:Show();
        self.points:SetText(points);
    end

    self:ResizeAndShow();
end

----------------------------------------------------------------------------------
NarciAchievementNavigationButtonMixin = {};

function NarciAchievementNavigationButtonMixin:OnEnter()
    self:StopAnimating();
    self.highlight.flyIn:Play();
    self.flyIn.hold:SetDuration(60);
end

function NarciAchievementNavigationButtonMixin:OnLeave()
    self.flyIn.hold:SetDuration(0);
    self.highlight.fadeOut:Play(); 
end

function NarciAchievementNavigationButtonMixin:OnMouseDown()
    self.background:SetScale(0.9);
    if not self:IsEnabled() then
        self:GetParent():OnMouseDown();
    end
end

function NarciAchievementNavigationButtonMixin:OnMouseUp()
    self.background:SetScale(1);
end

function NarciAchievementNavigationButtonMixin:OnClick()
    InspectionFrame:OnMouseWheel(self.delta);
end

function NarciAchievementNavigationButtonMixin:OnDisable()
    self:SetAlpha(0);
end

function NarciAchievementNavigationButtonMixin:OnEnable()
    self:SetAlpha(1);
end


NarciAchievementReturnButtonMixin = {};

function NarciAchievementReturnButtonMixin:OnLoad()
    ReturnButton = self;
    self.structure = {};
end

function NarciAchievementReturnButtonMixin:PlayFlyIn()
    self.flyIn:Play();
end

function NarciAchievementReturnButtonMixin:OnEnter()
    self.label:SetTextColor(0.88, 0.88, 0.88);
end

function NarciAchievementReturnButtonMixin:OnLeave()
    self.label:SetTextColor(0.6, 0.6, 0.6);
end

function NarciAchievementReturnButtonMixin:OnHide()
    self:Hide();
    self:StopAnimating();
    wipe(self.structure);
end

function NarciAchievementReturnButtonMixin:SetLabelText(text)
    self.label:SetText("");
    self.label:SetWidth(0);
    self.label:SetText(text);

    local textWidth = min(140, self.label:GetWidth());
    self.label:SetWidth(textWidth)
    self:SetWidth(textWidth + 24);
end

function NarciAchievementReturnButtonMixin:AddToQueue(achievementID, achievementName)
    for i = 1, #self.structure + 1 do
        if self.structure[i] == nil then
            self.structure[i] = {id = achievementID, name = achievementName};
            break;
        end
    end
    self:SetLabelText(achievementName);
    self:Show();
    self:PlayFlyIn();
end

function NarciAchievementReturnButtonMixin:OnClick()
    for i = #self.structure, 1, -1 do
        local info = self.structure[i];
        if info and info.id then
            InspectAchievement(info.id);
            if i == 1 then
                self:Hide();
            else
                self:SetLabelText(self.structure[i - 1].name)
            end
            self.structure[i] = nil;
            break;
        end
    end
end


NarciAchievementSearchBoxMixin = {};

local function InspectResult(button)
    local playAnimation = not InspectionFrame:IsShown();

    local id = button.id;
    local Card = InspectionFrame.Card;
    Card:ClearAllPoints();
    Card:SetPoint("BOTTOM", InspectionFrame, "CENTER", 0, 36);

    InspectionFrame.PrevButton:Disable();
    InspectionFrame.NextButton:Disable();
    InspectionFrame.pauseScroll = true;

    InspectAchievement(id);

    animFlyOut.button = nil;
    animFlyOut.fromX, animFlyOut.toX, animFlyOut.fromY, animFlyOut.toY = 0, 0, 0, 0;
    animFlyOut.noTranslation = true;

    if playAnimation then
        animFlyIn:Play();
    end
end

function NarciAchievementSearchBoxMixin:OnLoad()
    SearchBoxTemplate_OnLoad(self);
    self.Left:Hide();
    self.Middle:Hide();
    self.Right:Hide();

    local delayedSearch = NarciAPI_CreateAnimationFrame(0.5);
    self.delayedSearch = delayedSearch;
    delayedSearch:SetScript("OnUpdate", function(frame, elapsed)
        frame.total = frame.total + elapsed;
        if frame.total >= frame.duration then
            frame:Hide();
            SetAchievementSearchString(self.keyword);
        end
    end)


    ---
    local ClipFrame = self.ClipFrame;


    ---
    ResultFrame = ClipFrame.ResultFrame;
    self.ResultFrame = ResultFrame;
    local buttons = {};
    local button;
    for i = 1, 5 do
        button = CreateFrame("Button", nil, ResultFrame, "NarciAchievementSearchResultButtonTemplate");
        button:SetScript("OnClick", function(button)
            InspectResult(button);
            ResultFrame:Hide();
        end);
        tinsert(buttons, button);
        if i == 1 then
            button:SetPoint("TOP", ResultFrame, "TOP", 0, -24);
        else
            button:SetPoint("TOP", buttons[i - 1], "BOTTOM", 0, -2);
        end
        button:Hide();
    end
    ResultFrame.buttons = buttons;
    ResultButtons = buttons;

    self.ResultFrame:SetScript("OnMouseWheel", function(frame, delta)
        if self.numResults and self.numResults > 5 then
            if delta > 0 then
                if self.currentPage > 1 then
                    self.currentPage = self.currentPage - 1;
                    self:UpdatePage();
                end
            else
                if self.currentPage < self.maxPage then
                    self.currentPage = self.currentPage + 1;
                    self:UpdatePage();
                end
            end
        end
    end)

    --Animation
    local animDrop = NarciAPI_CreateAnimationFrame(0.35);
    animDrop:SetScript("OnUpdate", function(frame, elapsed)
        frame.total = frame.total + elapsed;
        local alpha = outQuart(frame.total, frame.fromAlpha, frame.toAlpha, frame.duration);

        if frame.total >= frame.duration then
            frame:Hide();
            alpha = frame.toAlpha;
            if alpha == 0 then
                ResultFrame:Hide();
            end
        end

        ResultFrame:SetAlpha(alpha);
    end)

    function self:ShowResults()
        animDrop:Hide();
        animDrop.fromAlpha = ResultFrame:GetAlpha();
        animDrop.toAlpha = 1;
        ResultFrame:Show();
        animDrop:Show();
    end

    function self:HideResults()
        animDrop:Hide();
        animDrop.fromAlpha = ResultFrame:GetAlpha();
        animDrop.toAlpha = 0;
        animDrop:Show();
    end
    
    ResultFrame:SetAlpha(0);
    --ResultFrame:SetHeight(24);
end

function NarciAchievementSearchBoxMixin:OnUpdate()
    self.pauseUpdate = true;
end

function NarciAchievementSearchBoxMixin:OnTextChanged()
    SearchBoxTemplate_OnTextChanged(self);
    self.keyword = self:GetText();
    if ( strlen(self.keyword) >= MIN_CHARACTER_SEARCH ) then
        self.delayedSearch.total = 0;
        self.delayedSearch:Show();
    else
        self.delayedSearch:Hide();
    end
end

function NarciAchievementSearchBoxMixin:OnEditFocusGained()
    self:RegisterEvent("ACHIEVEMENT_SEARCH_UPDATED");
    local numResults = GetNumFilteredAchievements();
    --this filter might be removed by using the original AchievementFrame so we need to set again
    if numResults and numResults > 0 then
        self:ShowResults();
    else
        if self:GetText() ~= "" then
            self:OnTextChanged();
        end
    end
end

function NarciAchievementSearchBoxMixin:OnEditFocusLost()
    SearchBoxTemplate_OnEditFocusLost(self);
    if not self.ResultFrame:IsMouseOver() then
        --self.ResultFrame:Hide();
        self:HideResults();
    end
    self:UnregisterEvent("ACHIEVEMENT_SEARCH_UPDATED");
end

function NarciAchievementSearchBoxMixin:OnEnterPressed()
    self:ClearFocus();
    if self:GetText() ~= "" then
        local button1 = self.ResultFrame.buttons[1];
        if button1:IsShown() then
            button1:Click();
        end
    end
end

function NarciAchievementSearchBoxMixin:OnHide()
    self:UnregisterEvent("ACHIEVEMENT_SEARCH_UPDATED");
    self.ResultFrame:Hide();
end

function NarciAchievementSearchBoxMixin:ProcessResults()
    local numResults = GetNumFilteredAchievements();
    self.numResults = numResults;
    self.ResultFrame.count:SetText(numResults.." |cff808080Results|r");
    local numPages = ceil(numResults / 5);
    self.maxPage = numPages;
    if ( numResults > 0 ) then
        self.currentPage = 1;
        --self.ResultFrame:Show();
        self:ShowResults();
    end
    self:UpdatePage();
end

function NarciAchievementSearchBoxMixin:OnEvent(event)
    self:ProcessResults();
end

function NarciAchievementSearchBoxMixin:UpdatePage()
    local page = self.currentPage or 1;
    local numPages = ceil(self.numResults / 5);
    local buttons = self.ResultFrame.buttons;
    if numPages > 0 then
        self.ResultFrame.pageText:SetText(page.."/"..numPages);
        local firstID = 5*(page - 1);
        local button;
        local index;
        local id, name, points, completed, _, _, _, _, flags, icon;
        for i = 1, 5 do
            index = i + firstID;
            button = buttons[i];
            if index <= self.numResults then
                local achievementID = GetFilteredAchievementID(index);
                id, name, points, completed, _, _, _, _, flags, icon = DataProvider:GetAchievementInfo(achievementID);
                button.id = achievementID;
                button.header:SetText(name);
                button.icon:SetTexture(icon);
                if flags == 131072 then     --ACHIEVEMENT_FLAGS_ACCOUNT
                    button.header:SetTextColor(0.427, 0.812, 0.965);
                    button.background:SetTexCoord(0, 1, 0.5, 1);
                else
                    button.header:SetTextColor(1, 0.91, 0.647);
                    button.background:SetTexCoord(0, 1, 0, 0.5);
                end


                local categoryID = GetAchievementCategory(achievementID);
                local categoryName, parentCategoryID = DataProvider:GetCategoryInfo(categoryID);
                local path = categoryName;
                while ( not (parentCategoryID == -1) ) do
                    categoryName, parentCategoryID = DataProvider:GetCategoryInfo(parentCategoryID);
                    path = categoryName.." > "..path;
                end
                button.path:SetText(path);
                
                if completed then
                    button.icon:SetDesaturated(false);
                    button.header:SetAlpha(1);
                    button.icon:SetVertexColor(1, 1, 1);
                    button.background:SetVertexColor(1, 1, 1);
                else
                    button.icon:SetDesaturated(true);
                    button.header:SetAlpha(0.5);
                    button.icon:SetVertexColor(0.5, 0.5, 0.5);
                    button.background:SetVertexColor(0.5, 0.5, 0.5);
                end

                button:Show();
            else
                button:Hide();
            end
        end
    else
        self.ResultFrame.pageText:SetText(nil);
        for i = 1, 5 do
            buttons[i]:Hide();
        end
    end
end


--------------------------------------------------------------
local DateUtil = {};
function DateUtil:GetToday()
    self.today = time();
end

function DateUtil:GetDifference(day, month, year)
    year = 2000 + year;
    local past = time( {day = day, month = month, year = year} )
    if not self.today then
        self.today = time();
    end
    return (self.today - past)
end

function DateUtil:GetPastDays(day, month, year)
    local diff = self:GetDifference(day, month, year);
    local day = floor(diff / 86400);
    if day <= 0 then
        return "Today"
    elseif day == 1 then
        return "Yesterday"
    elseif day < 31 then
        return day .. " days ago"
    else
        local month = floor(day / 30.5);
        if month <= 1 then
            return month .. " month ago"
        else
            return month .. " months ago"
        end
    end
end


local function FormatRecentAchievementButton(button, id, name, points, completed, month, day, year, description, flags, icon, rewardText, useRelativeDate)
    local headerObject, numLines, textHeight;
    button.id = id;

    --for long text
    button.header:SetText(name);
    if button.header:IsTruncated() then
        headerObject = button.headerLong;
        headerObject:SetText(name);
        button.header:Hide();
    else
        headerObject = button.header;
        button.headerLong:Hide();
    end
    headerObject:Show();

    if flags == 131072 then
        if completed then
            if isDarkTheme then
                headerObject:SetTextColor(0.427, 0.812, 0.965); --(0.427, 0.812, 0.965)(0.4, 0.755, 0.9)
            else
                headerObject:SetTextColor(1, 1, 1);
            end
        else
            if isDarkTheme then
                headerObject:SetTextColor(0.214, 0.406, 0.484);
            else
                headerObject:SetTextColor(0.5, 0.5, 0.5);
            end
        end
    else
        if completed then
            if isDarkTheme then
                headerObject:SetTextColor(0.9, 0.82, 0.58);  --(1, 0.91, 0.647); --(0.9, 0.82, 0.58) --(0.851, 0.774, 0.55)
            else
                headerObject:SetTextColor(1, 1, 1);
            end
        else
            if isDarkTheme then
                headerObject:SetTextColor(0.5, 0.46, 0.324);
            else
                headerObject:SetTextColor(0.5, 0.5, 0.5);
            end
        end
    end

    points = GetProgressivePoints(id, points);
    if points == 0 then
        button.points:SetText("");
        button.lion:Show();
    else
        if points >= 100 then
            if not button.useSmallPoints then
                button.useSmallPoints = true;
                button.points:SetFontObject(NarciAchievemtPointsSmall);
            end
        else
            if button.useSmallPoints then
                button.useSmallPoints = nil;
                button.points:SetFontObject(NarciAchievemtPoints);
            end
        end
        button.points:SetText(points);
        button.lion:Hide();
    end

    button.icon:SetTexture(icon);

    local rewardHeight;
    local shadowHeight = 0;
    if rewardText and rewardText ~= "" then
        local itemID;
        rewardHeight = 24;
        shadowHeight = 6;
        rewardText, itemID = FormatRewardText(id, rewardText);
        button.RewardFrame.reward:SetText(rewardText);
        button.RewardFrame.itemID = itemID;
        button.itemID = itemID;
        button.RewardFrame:Show();
    else
        if isDarkTheme then
            rewardHeight = 2;
        else
            rewardHeight = 8;
        end
        button.RewardFrame:Hide();
        button.RewardFrame:SetHeight(2);
    end
    button.RewardFrame:SetHeight(rewardHeight);

    button.description:SetHeight(0);
    button.description:SetText(description);
    local descriptionHeight = button.description:GetHeight();
    button.description:SetHeight(descriptionHeight)
    textHeight = floor( button.background:GetHeight() + 0.5 );
    numLines = ceil( descriptionHeight / 14 - 0.1 );
    button:SetHeight(72 + rewardHeight + 14*(numLines - 1) );
    button.shadow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 12, - 6 - numLines * 6 - shadowHeight);

    if flags == 131072 then     --ACHIEVEMENT_FLAGS_ACCOUNT
        button.accountWide = true;
        button.border:SetTexCoord(0.05078125, 0.94921875, 0.5, 1);
        button.bottom:SetTexCoord(0.05078125, 0.94921875, 0.985, 1);
        if textHeight <= 288 then
            button.background:SetTexCoord(0.05078125, 0.94921875, 0.985 - textHeight/288/2, 0.985);
        else
            button.background:SetTexCoord(0.05078125, 0.94921875,  0.5, 0.985);
        end
    else
        button.accountWide = nil;
        button.border:SetTexCoord(0.05078125, 0.94921875, 0, 0.5);
        button.bottom:SetTexCoord(0.05078125, 0.94921875, 0.485, 0.5);
        if textHeight <= 288 then
            button.background:SetTexCoord(0.05078125, 0.94921875, 0.485 - textHeight/288/2, 0.485);
        else
            button.background:SetTexCoord(0.05078125, 0.94921875,  0, 0.485);
        end
    end

    --button.date:SetText( FormatDate(day, month, year) );
    if useRelativeDate then
        button.date:SetText( DateUtil:GetPastDays(day, month, year) );
    else
        button.date:SetText( FormatDate(day, month, year) );
    end
    button.RewardFrame.reward:SetAlpha(1);

    button.toAlpha = 1;
    button:SetAlpha(0);     --for flip animation
    button:Show();
end


local UpdateHeaderFrame;

local function CreateSummaryButtons()
    local MAX_SUMMARY_ACHIEVEMENTS = 5;

    if not SummaryFrame.buttons then
        SummaryFrame.buttons = {};
    end
    local buttons = SummaryFrame.buttons;
    local button;
    for i = 1, MAX_SUMMARY_ACHIEVEMENTS do
        button = buttons[i];
        if not button then
            button = CreateFrame("Button", nil, SummaryFrame, "NarciAchievementCardLargeTemplate");
            button:SetScript("OnClick", InspectResult);
            button.header:SetWidth(274);
            button.description:SetMaxLines(1);
            tinsert(buttons, button);
            if i == 1 then
                button:SetPoint("TOP", SummaryFrame, "TOP", -9, -18);
            else
                button:SetPoint("TOP", buttons[i - 1], "BOTTOM", 0, -4);
            end
            button:Hide();

            ReskinButton(button);
        end
    end

    animFlip:Add(buttons, MAX_SUMMARY_ACHIEVEMENTS, 2);
end

local function UpdateSummaryFrame(breakLoop, noRenderWhileHidden)
    if noRenderWhileHidden and not SummaryFrame:IsShown() then return end;

    local buttons = SummaryFrame.buttons;
    local button;
    local recentAchievements = { GetLatestCompletedAchievements(isGuildView) };

    if (#recentAchievements <= 5) and (not breakLoop) then
        SummaryFrame:SetAlpha(0);
        After(0.05, function()
            UpdateSummaryFrame(true);
        end);
        return
    end

    local id, name, points, completed, month, day, year, description, flags, icon, rewardText;
    local useRelativeDate = true;
    for i = 1, 5 do
        button = buttons[i];
        id = recentAchievements[i];
        if id then
            id, name, points, completed, month, day, year, description, flags, icon, rewardText = DataProvider:GetAchievementInfo(id);
            FormatRecentAchievementButton(button, id, name, points, completed, month, day, year, description, flags, icon, rewardText, useRelativeDate);
            ReskinButton(button);
        else
            button:Hide();
        end
    end

    SummaryFrame:SetAlpha(1);
    UpdateHeaderFrame(isGuildView);
    animFlip:Play(2);
end


----------------------------------------------------------------------------------
local TabUtil = {};

function TabUtil:SaveView(isGuild, saveOffset)
    --print("currentCategory: ".. DataProvider.currentCategory)
    local lastButton;
    if isGuild then
        if saveOffset then
            self.lastPlayerButton = DataProvider:GetCategoryButtonByID(DataProvider.currentCategory);
            self.lastPlayerScrollValue = CategoryContainer.scrollBar:GetValue();
        end
        lastButton = self.lastGuildButton;
        if lastButton then
            AchievementContainer:Show();
            SummaryFrame:Hide();
            SummaryButton:Show();
            SubCategoryButton_OnClick(lastButton);
            ToggleFeatOfStrenghtText(lastButton);
        else
            SummaryButton:Click();
        end
    else
        if saveOffset then
            self.lastGuildButton = DataProvider:GetCategoryButtonByID(DataProvider.currentCategory);
            self.lastGuildScrollValue = CategoryContainer.scrollBar:GetValue();
        end
        lastButton = self.lastPlayerButton;
        if lastButton then
            AchievementContainer:Show();
            SummaryFrame:Hide();
            SummaryButton:Show();
            SubCategoryButton_OnClick(lastButton);
            ToggleFeatOfStrenghtText(lastButton);
        else
            SummaryButton:Click();
        end
    end
    AchievementContainer.scrollBar:SetValue(0);
end


function TabUtil:ToggleGuildView(isGuild)
    if (isGuild ~= isGuildView) or self.isDIY then
        isGuildView = isGuild;
        CategoryContainer.ScrollChild.PlayerCategory:SetShown(not isGuild);
        CategoryContainer.ScrollChild.GuildCategory:SetShown(isGuild);
        DIYContainer:Hide();
        EditorContainer:Hide();
        CategoryContainer:Show();
        SummaryButton:Enable();

        self:SaveView(isGuild, not self.isDIY);

        UpdateCategoryScrollRange();

        if isGuild then
            CategoryContainer.scrollBar:SetValue(self.lastGuildScrollValue or 0);
        else
            CategoryContainer.scrollBar:SetValue(self.lastPlayerScrollValue or 0);
        end

        local noRenderWhileHidden = true;
        --UpdateSummaryFrame(false, noRenderWhileHidden);
        MainFrame.HeaderFrame.points:SetText( BreakUpLargeNumbers(GetTotalAchievementPoints(isGuild)) );
        
        self.isDIY = false;
    end
end

function TabUtil:ToggleDIY()
    if self.isDIY then return end;
    self.isDIY = true;

    DIYContainer:Show();
    if not TabUtil.isDIYLoaded then
        TabUtil.isDIYLoaded = true;
        DIYContainer:Refresh();
        DIYContainer.scrollBar:SetValue(0);
    end
    
    EditorContainer:Show();
    CategoryContainer:Hide();
    SummaryFrame:Hide();
    SummaryButton:Disable();
    AchievementContainer:Hide();
end

--------------------------------------------------------------
local function FilterButton_OnClick(self)
    local state = not NarciAchievementOptions.IncompleteFirst;
    NarciAchievementOptions.IncompleteFirst = state;
    if state then
        self.label:SetText(L["Incomplete First"]);
        SwitchToSortMethod(1);
    else
        self.label:SetText(L["Earned First"]);
        SwitchToSortMethod(2);
    end
end

local function SummaryButton_OnClick(self)
    if DataProvider.currentCategory ~= 0 then
        animExpand:CollapseAll();
    end
    UpdateSummaryFrame();
    AchievementContainer:Hide();
    SummaryFrame:Show();
    SummaryButton:Hide();
end


local function CreateTabButtons()
    local tabNames = {ACHIEVEMENTS, ACHIEVEMENTS_GUILD_TAB, "DIY", L["Settings"]};
    local frame = Narci_AchievementFrame;
    local buttons = {};
    local function DeselectRest(button)
        for i = 1, #buttons do
            if buttons[i] ~= button then
                buttons[i]:Deselect();
            end
        end
    end

    local funcs = {
        function(self)
            TabUtil:ToggleGuildView(false);
            DeselectRest(self);
            self:Select();
        end,

        function(self)
            TabUtil:ToggleGuildView(true);
            DeselectRest(self);
            self:Select();
        end,

        function(self)
            TabUtil:ToggleDIY();
            DeselectRest(self);
            self:Select();
        end,

        function(self)
            MainFrame.Settings:Toggle();
        end,
    }
    
    local numTabs = #tabNames;
    for i = 1, numTabs do
        local button = CreateFrame("Button", nil, frame, "NarciAchievementTabButtonTemplate");
        tinsert(buttons, button);
        button:SetLabel(tabNames[i]);
        button.id = i;

        if i == 1 then
            button:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 23, 0);
            button:Select();
        elseif i == numTabs then
            button:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -23, 0);
        else
            button:SetPoint("TOPLEFT", buttons[i - 1], "TOPRIGHT", 14, 0);
        end

        button:SetScript("OnClick", funcs[i]);
    end

    TabButtons = buttons;
end
----------------------------------------------------------------------------------
local function GetInspectedCardLink()
    local achievementID = InspectionFrame.Card.id;
    if not achievementID then return end;

    local URL = NarciLanguageUtil:GetWowheadLink();
    URL = URL .. "achievement=" .. tostring(achievementID);

    return URL
end

NarciAchievementGetLinkButtonMixin = {};

function NarciAchievementGetLinkButtonMixin:OnLoad()
    self.Label:SetText(L["External Link"]);
    local textWidth = max(40, floor( self.Label:GetWidth() + 0.5 ) );
    self:SetWidth(textWidth + 40 + 16);

    local range = textWidth + 24;
    self.Icon:SetPoint("RIGHT", self, "RIGHT", -18, 0);


    local animShow = NarciAPI_CreateAnimationFrame(0.25);
    self.animShow = animShow;
    animShow:SetScript("OnUpdate", function(frame, elapsed)
        frame.total = frame.total + elapsed;
        local offsetX = inOutSine(frame.total, frame.fromX, frame.toX, frame.duration);
        local textOffset = inOutSine(frame.total, frame.fromTextX, frame.toTextX, frame.duration);
        local alpha = outQuart(frame.total, frame.fromAlpha, frame.toAlpha, frame.duration);
        if frame.total >= frame.duration then
            offsetX = frame.toX;
            textOffset = frame.toTextX;
            alpha = frame.toAlpha;
            frame:Hide();

            if alpha == 0 then
                self.Clipboard:Hide();
            end
        end
        self.Icon:SetPoint("RIGHT", self, "RIGHT", offsetX, 0);
        self.Label:SetPoint("RIGHT", self, textOffset, 0);
        self.Label:SetAlpha(alpha);
        self.Clipboard:SetAlpha(alpha);
    end);

    function self:AnimShow()
        animShow:Hide();
        local offsetX, _;
        _, _, _, offsetX = self.Icon:GetPoint();
        _, _, _, animShow.fromTextX = self.Label:GetPoint();
        animShow.duration = ( sqrt(1 - abs(offsetX)/ range) * 0.4);
        animShow.fromX = offsetX;
        animShow.toX = -range;
        --animShow.fromTextX = -28; --keep label still
        animShow.toTextX = -28;
        animShow.fromAlpha = self.Label:GetAlpha();
        animShow.toAlpha = 1;
        animShow:Show();
    end

    function self:AnimHide()
        animShow:Hide();
        local offsetX, _;
        _, _, _, offsetX = self.Icon:GetPoint();
        _, _, _, animShow.fromTextX = self.Label:GetPoint();
        animShow.duration = ( sqrt(abs(offsetX)/ range) * 0.5);
        animShow.fromX = offsetX;
        animShow.toX = -20;
        animShow.toTextX = -10;
        animShow.fromAlpha = self.Label:GetAlpha();
        animShow.toAlpha = 0;
        animShow:Show();
    end

    self.Clipboard:SetScript("OnLeave", function()
        self:OnLeave();
    end);
    self.Clipboard.EditBox:SetScript("OnLeave", function()
        self:OnLeave();
    end);

    self.Clipboard:ReAnchorTooltipToObject(self.Label);
    self.Clipboard.EditBox.onQuitFunc = function()
        self:OnLeave();
    end
end

function NarciAchievementGetLinkButtonMixin:OnClick()
    self.Clipboard:ShowClipboard();
    self.Clipboard:SetText( GetInspectedCardLink() );
    self.Clipboard:SetFocus();
    self.Label:Hide();
end

function NarciAchievementGetLinkButtonMixin:OnEnter()
    --self.Label:SetTextColor(1, 1, 1);
    self.Icon:SetTexCoord(0.5, 1, 0, 1);
    self.Icon:SetAlpha(0.6);
    self:AnimShow();
    self.Label:Show();
end

function NarciAchievementGetLinkButtonMixin:OnLeave()
    if not self:IsMouseOver() then
        self.Label:SetTextColor(0.8, 0.8, 0.8);
        self.Icon:SetTexCoord(0, 0.5, 0, 1);
        self.Icon:SetAlpha(0.4);
        self:AnimHide();
        self.Clipboard.EditBox:HighlightText(0, 0);
    end
end


--------------------------------------------------------
--Start updating rendered area when dragging achievement scrollframe scrollbar
local updateFrame = CreateFrame("Frame");
updateFrame:Hide();
updateFrame.t = 0;
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.2 then
        self.t = 0;
        UpdateRenderedArea(self.scrollBar:GetValue());
    end
end);

local function ScrollBar_OnDragStart()
    updateFrame:Show();
end

local function ScrollBar_OnDragStop()
    updateFrame.t = 1;
    After(0, function()
        updateFrame:Hide();
    end)
end

local function InitializeFrame(frame)
    MainFrame = frame;

    --Category
    CategoryContainer = frame.CategoryFrame;
    local isGuild = true;
    CreateCategoryButtons(isGuild);
    isGuild = not isGuild;
    CreateCategoryButtons(isGuild);

    local numCategories = CategoryStructure.player.numCategories;
    local deltaRatio = 2;
    local speedRatio = 0.2;
    local buttonHeight = 32;
    local range = numCategories  * (buttonHeight + 4) - CategoryContainer:GetHeight();
    local positionFunc;
    
    NarciAPI_ApplySmoothScrollToScrollFrame(CategoryContainer, deltaRatio, speedRatio, positionFunc, buttonHeight, range);
    UpdateCategoryScrollRange();


    --Sort Method
    local FilterButton = frame.FilterButton;
    if NarciAchievementOptions.IncompleteFirst then
        SORT_FUNC = Slice_ReverselyUpdateAchievementCards;
        FilterButton.label:SetText(L["Incomplete First"]);
    else
        SORT_FUNC = Slice_UpdateAchievementCards;
        FilterButton.label:SetText(L["Earned First"]);
    end
    FilterButton:SetScript("OnClick", FilterButton_OnClick);
    showNotEarnedMark = NarciAchievementOptions.ShowRedMark;

    --Achievement
    AchievementContainer = frame.AchievementCardFrame;
    CreateAchievementButtons(AchievementContainer.ScrollChild);
    animFlip:Add(AchievementCards, 7, 1);

    local numCards = #AchievementCards;
    local deltaRatio = 1;
    local speedRatio = 0.24;
    local buttonHeight = 64;
    local range = numCards  * (buttonHeight + 4) - AchievementContainer:GetHeight();
    local positionFunc = UpdateRenderedArea;
    NarciAPI_ApplySmoothScrollToScrollFrame(AchievementContainer, deltaRatio, speedRatio, positionFunc, buttonHeight, range);
    local scrollBar = AchievementContainer.scrollBar;
    updateFrame.scrollBar = scrollBar;
    scrollBar:SetScript("OnMouseDown", ScrollBar_OnDragStart);
    scrollBar:SetScript("OnMouseUp", ScrollBar_OnDragStop);
    UpdateAchievementScrollRange();

    --Model Preview
    MountPreview = CreateFrame("ModelScene", nil, frame,"NarciAchievementRewardModelTemplate");
    MountPreview:ClearAllPoints();
    MountPreview:SetPoint("LEFT", frame, "RIGHT", 4, 0);

    Tooltip = frame.Tooltip;

    --Header Filter, Total Points, Search, Close
    local HeaderFrame = frame.HeaderFrame;

    SummaryButton = frame.SummaryButton;
    SummaryButton:SetScript("OnClick", SummaryButton_OnClick);
    
    function UpdateHeaderFrame(isGuild) --Private
        local total, completed = GetNumCompletedAchievements(isGuild);
        HeaderFrame.totalAchievements:SetText(completed.."/"..total);
        HeaderFrame.points:SetText( BreakUpLargeNumbers(GetTotalAchievementPoints(isGuild)) );
        if completed > 0 then
            HeaderFrame.fill:Show();
            local percentage = completed / total;
            HeaderFrame.fill:SetWidth(198 * percentage);
            HeaderFrame.fill:SetTexCoord(0, percentage *  0.75, 0, 1);
            if percentage == 1 then
                HeaderFrame.value:SetText("100");
                HeaderFrame.fillEnd:Hide();
            else
                HeaderFrame.value:SetText( floor(100 * percentage) );
                HeaderFrame.fillEnd:Show();
            end
        end
    end

    --SummaryFrame
    SummaryFrame = frame.SummaryFrame;
    CreateSummaryButtons();
    UpdateSummaryFrame();

    --DIY Achievements
    DIYContainer = frame.DIYContainer;
    EditorContainer = frame.EditorContainer;

    --Tabs
    CreateTabButtons();
    NarciAchievement_SelectTheme(NarciAchievementOptions.Theme or 1);
    --
    tinsert(UISpecialFrames, frame:GetName());
    frame:Hide();
    frame:SetAlpha(1);

    --Reclaim Temp
    wipe(CategoryStructure);
    CategoryStructure = nil;
    CreateCategoryButtons = nil;
    CreateAchievementButtons = nil;
    CreateSummaryButtons = nil;
    CreateTabButtons = nil;
    InitializeFrame = nil;
end

-----------------------------------------
local FloatingCards = CreateFrame("Frame", "NarciFloatingCardsContainer");

local positionFrame = CreateFrame("Frame");
FloatingCards.positionFrame = positionFrame;

positionFrame.screenMidPoint = WorldFrame:GetWidth()/2;
positionFrame:Hide();
positionFrame:SetScript("OnUpdate", function(self)
    local cursorX, cursorY = GetCursorPosition();
    local uiScale = self.uiScale;
    cursorX, cursorY = cursorX/uiScale, cursorY/uiScale;
    local compensatedX = cursorX - self.offsetX;
    local midPoint = self.screenMidPoint/uiScale;
    if (compensatedX > midPoint - 40) and (compensatedX < midPoint + 40) then
        compensatedX = midPoint;
    end
    if self.object then
        self.object:SetPoint("CENTER", UIParent, "BOTTOMLEFT", compensatedX, cursorY - self.offsetY);
    else
        self:Hide();
    end
end);


FloatingCards.cards = {};

local function MoveFloatingCard(card)
    positionFrame:Hide();
    local uiScale = card:GetScale();
    positionFrame.object = card;
    positionFrame.uiScale = uiScale;
    local cursorX, cursorY = GetCursorPosition();
    cursorX, cursorY = cursorX/uiScale, cursorY/uiScale;
    local x0, y0 = card:GetCenter();
    positionFrame.offsetX = cursorX - x0;
    positionFrame.offsetY = cursorY - y0;
    positionFrame:Show();
end


local function FloatingCard_OnDragStop(self)
    positionFrame:Hide();
end



function FloatingCards:Acquire()
    self:RegisterEvent("GLOBAL_MOUSE_UP");
    local card;
    for i = 1, #self.cards + 1 do
        card = self.cards[i];
        if card and (not card:IsShown()) then
            break
        end
        if not card then
            card = CreateFrame("Button", nil, self, "NarciAchievementFloatingCardTemplate");
            card.index = i;
            card:SetFrameStrata("DIALOG");
            card:SetFrameLevel(i);
            card:SetScript("OnDragStart", MoveFloatingCard);
            card:SetScript("OnDragStop", FloatingCard_OnDragStop);
            tinsert(self.cards, card);
            ReskinButton(card);
            break
        end
    end

    self.pendingCard = card;
    return card
end

function FloatingCards:PostCreate()
    if self.parentCard then
        UIFrameFadeIn(self.parentCard, 0.5, 0, 1);
    end

    local pendingCard = self.pendingCard;
    if MainFrame:IsMouseOver() then
        if pendingCard then
            pendingCard:Hide();
            pendingCard = nil;
        end
    else
        if pendingCard then
            FloatingCard_OnDragStop(pendingCard);
        end
    end
end

function FloatingCards:OnEvent(event, ...)
    if event == "GLOBAL_MOUSE_UP" then
        self:UnregisterEvent("GLOBAL_MOUSE_UP");
        self:PostCreate();
    end
end

FloatingCards:SetScript("OnEvent", function(frame, event, ...)
    frame:OnEvent(event, ...);
end);


local function FormatFloatingCard(card, id, name, points, completed, month, day, year, description, flags, icon, rewardText)
    FormatRecentAchievementButton(card, id, name, points, true, month, day, year, description, flags, icon, rewardText);

    local texOffset;
    local ModelScene = card.VFX;
    ModelScene:ClearAllPoints();
    if flags and flags == 131072 then
        texOffset = 0.5;
        ModelScene:SetPoint("CENTER", card, "TOP", 0, -158);
        NarciAPI_SetupModelScene(ModelScene, 1893721, 20);
    else
        texOffset = 0;
        ModelScene:SetPoint("CENTER", card, "CENTER", 0, 0);
        NarciAPI_SetupModelScene(ModelScene, 2012607, 8);
    end
    card.highlightTop:SetTexCoord(0.05078125, 0.94921875, 0 + texOffset, 0.5 + texOffset);
    card.highlightCenter:SetTexCoord(0.05078125, 0.94921875, 0 + texOffset, 0.40625 + texOffset);
    card.highlightBottom:SetTexCoord(0.05078125, 0.94921875, 0.40625 + texOffset, 0.5 + texOffset);
end


--------------------------------------------------------------------
--Public
NarciAchivementFrameMixin = {};

function NarciAchivementFrameMixin:OnLoad()
    self:RegisterForDrag("LeftButton");
    self:SetAttribute("nodeignore", true);  --ConsolePort: Ignore this frame
end

function NarciAchivementFrameMixin:OnShow()
    if self.pendingCategoryID then
        SelectCategory(self.pendingCategoryID);
        self.pendingCategoryID = nil;
    elseif self.pendingUpdate then
        self.pendingUpdate = nil;
        UpdateSummaryFrame();
    end
end

function NarciAchivementFrameMixin:ShowRedMark(visible)
    showNotEarnedMark = visible;
    for i = 1, #AchievementCards do
        if visible then
            AchievementCards[i].NotEarned:SetWidth(20);
        else
            AchievementCards[i].NotEarned:SetWidth(0.1);
        end
    end
    if MainFrame:IsShown() then
        local categoryID = DataProvider.currentCategory;
        if categoryID and categoryID ~= 0 then
            UpdateAchievementCardsBySlice(categoryID);
        end
    end
end

function NarciAchivementFrameMixin:LocateAchievement(achievementID, clickAgainToClose)
    local Card = InspectionFrame.Card;

    if  (not achievementID) or ( clickAgainToClose and (Card.id == achievementID) and MainFrame:IsShown() and InspectionFrame:IsShown() ) then
        MainFrame:Hide();
        return
    end
    
    MainFrame:Show();
    local playAnimation = not InspectionFrame:IsShown();
    Card:ClearAllPoints();
    Card:SetPoint("BOTTOM", InspectionFrame, "CENTER", 0, 36);

    InspectionFrame.PrevButton:Disable();
    InspectionFrame.NextButton:Disable();
    InspectionFrame.pauseScroll = true;

    InspectAchievement(achievementID);

    animFlyOut.button = nil;
    animFlyOut.fromX, animFlyOut.toX, animFlyOut.fromY, animFlyOut.toY = 0, 0, 0, 0;
    animFlyOut.noTranslation = true;

    if playAnimation then
        animFlyIn:Play();
    end
end

function NarciAchievement_FormatAlertCard(card)
    local achievementID = card.id;
    local uiScale = MainFrame:GetEffectiveScale();
    card.uiScale = uiScale;
    local id, name, points, completed, month, day, year, description, flags, icon, rewardText = DataProvider:GetAchievementInfo(achievementID);
    FormatFloatingCard(card, id, name, points, completed, month, day, year, description, flags, icon, rewardText);
    ReskinButton(card);
end

function NarciAchievement_ReskinButton(card)
    ReskinButton(card);
    card.isDarkTheme = isDarkTheme;
end

function NarciAchievement_CreateFloatingCard(self)
    local id = self.id;
    if not id then return end;
    self.animPushed:Stop();
    self:Hide();
    FloatingCards.parentCard = self;

    local card = FloatingCards:Acquire();
    local uiScale = MainFrame:GetEffectiveScale();
    card:SetScale(uiScale);
    card.uiScale = uiScale;
    local id, name, points, completed, month, day, year, description, flags, icon, rewardText = DataProvider:GetAchievementInfo(id);
    FormatRecentAchievementButton(card, id, name, points, true, month, day, year, description, flags, icon, rewardText);
    
    card:ClearAllPoints();
    card:SetAlpha(1);
    positionFrame.object = card;
    positionFrame.uiScale = uiScale;

    local cursorX, cursorY = GetCursorPosition();
    cursorX, cursorY = cursorX/uiScale, cursorY/uiScale;
    local x0, y0 = self:GetCenter();
    positionFrame.offsetX = cursorX - x0;
    positionFrame.offsetY = cursorY - y0;
    positionFrame:Show();
end

function NarciAchievement_SelectTheme(index)
    if not index or index > 3 or index < 1 then
        index = 1;
    end
    if index == themeID then return end;

    themeID = index;
    NarciAchievementOptions.Theme = index;

    if index == 3 then
        isDarkTheme = true;
        texturePrefix = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Flat\\";
    elseif index == 2 then
        isDarkTheme = false;
        texturePrefix = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\";
    else
        isDarkTheme = true;
        texturePrefix = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\DarkWood\\";
    end
    
    for i = 1, #AchievementCards do
        ReskinButton(AchievementCards[i]);
    end

    ReskinButton(AchievementCards[-1]);

    --DIY Cards
    if DIYContainer.cards then
        for i = 1, #DIYContainer.cards do
            ReskinButton(DIYContainer.cards[i]);
            DIYContainer.cards[i].isDarkTheme = isDarkTheme;
        end
    end
    DIYContainer:RefreshTheme();
    DIYContainer.NewEntry.background:SetTexture(texturePrefix.."NewEntry");
    if index == 1 then
        EditorContainer.notes:SetFontObject(NarciAchievementText);
        EditorContainer.notes:SetTextColor(0.68, 0.58, 0.51);
    elseif index == 2 then
        EditorContainer.notes:SetFontObject(NarciAchievementTextBlack);
        EditorContainer.notes:SetTextColor(0, 0, 0);
    else
        EditorContainer.notes:SetFontObject(NarciAchievementText);
        EditorContainer.notes:SetTextColor(0.5, 0.5, 0.5);
    end

    local inpsectedAchievementID = AchievementCards[-1].id;
    if inpsectedAchievementID then
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText = DataProvider:GetAchievementInfo(inpsectedAchievementID);
        FormatAchievementCard(-1, id, name, points, completed, month, day, year, description, flags, icon, rewardText);
        --print("FormatAchievementCard")
    end
    
    local categoryID = DataProvider.currentCategory;
    if categoryID and categoryID ~= 0 then
        UpdateAchievementCardsBySlice(categoryID);
    end
    UpdateSummaryFrame();

    --Search Results:
    for i = 1, #ResultButtons do
        ResultButtons[i].background:SetTexture(texturePrefix.."ResultButton");
        ResultButtons[i].mask:SetTexture(texturePrefix.."ResultButtonMask");
    end

    --Border Skin
    local HeaderFrame = MainFrame.HeaderFrame;
    HeaderFrame.background:SetTexture(texturePrefix.."BoxHeaderBorder");
    HeaderFrame.mask:SetTexture(texturePrefix.."BoxHeaderBorderMask");

    MainFrame.background:SetTexture(texturePrefix.."BoxRight");
    MainFrame.categoryBackground:SetTexture(texturePrefix.."BoxLeft");

    AchievementContainer.OverlayFrame.top:SetTexture(texturePrefix.."BoxRight");
    AchievementContainer.OverlayFrame.bottom:SetTexture(texturePrefix.."BoxRight");
    AchievementContainer.scrollBar.Thumb:SetTexture(texturePrefix.."SliderThumb");
    
    CategoryContainer.OverlayFrame.top:SetTexture(texturePrefix.."BoxLeft");
    CategoryContainer.OverlayFrame.bottom:SetTexture(texturePrefix.."BoxLeft");
    CategoryContainer.scrollBar.Thumb:SetTexture(texturePrefix.."SliderThumb");

    DIYContainer.OverlayFrame.top:SetTexture(texturePrefix.."BoxRight");
    DIYContainer.OverlayFrame.bottom:SetTexture(texturePrefix.."BoxRight");
    DIYContainer.scrollBar.Thumb:SetTexture(texturePrefix.."SliderThumb");

    EditorContainer.OverlayFrame.top:SetTexture(texturePrefix.."BoxLeft");
    EditorContainer.OverlayFrame.bottom:SetTexture(texturePrefix.."BoxLeft");
    EditorContainer.scrollBar.Thumb:SetTexture(texturePrefix.."SliderThumb");
    
    --Scroll frame inner Shadow
    local showShadow = index == 1;
    AchievementContainer.OverlayFrame.topShadow:SetShown(showShadow);
    AchievementContainer.OverlayFrame.bottomShadow:SetShown(showShadow);
    DIYContainer.OverlayFrame.topShadow:SetShown(showShadow);
    DIYContainer.OverlayFrame.bottomShadow:SetShown(showShadow);
    CategoryContainer.OverlayFrame.topShadow:SetShown(showShadow);
    CategoryContainer.OverlayFrame.bottomShadow:SetShown(showShadow);
    EditorContainer.OverlayFrame.topShadow:SetShown(showShadow);
    EditorContainer.OverlayFrame.bottomShadow:SetShown(showShadow);

    --Category Buttons
    local playerButtons = CategoryButtons.player.buttons;
    for i = 1, #playerButtons do
        if playerButtons[i].isParentButton then
            playerButtons[i].background:SetTexture(texturePrefix.."CategoryButton");
        else
            playerButtons[i].background:SetTexture(texturePrefix.."SubCategoryButton");
        end
        playerButtons[i].fill:SetTexture(texturePrefix.."CategoryButtonBar");
        playerButtons[i].fillEnd:SetTexture(texturePrefix.."CategoryButtonBar");
    end

    local guildButtons = CategoryButtons.guild.buttons;
    for i = 1, #guildButtons do
        if guildButtons[i].isParentButton then
            guildButtons[i].background:SetTexture(texturePrefix.."CategoryButton");
        else
            guildButtons[i].background:SetTexture(texturePrefix.."SubCategoryButton");
        end
        guildButtons[i].fill:SetTexture(texturePrefix.."CategoryButtonBar");
        guildButtons[i].fillEnd:SetTexture(texturePrefix.."CategoryButtonBar");
    end

    HeaderFrame.fill:SetTexture(texturePrefix.."CategoryButtonBar");
    HeaderFrame.fillEnd:SetTexture(texturePrefix.."CategoryButtonBar");


    --Header Reposition
    local offsetY = 0;
    if index == 2 then
        offsetY = -6;
    end

    local FilterButton = MainFrame.FilterButton;
    FilterButton:ClearAllPoints();
    FilterButton:SetPoint("TOPRIGHT", MainFrame, "TOP", -2, -12 + offsetY);
    FilterButton.texture:SetTexture(texturePrefix.."DropDownButton");

    local CloseButton = MainFrame.CloseButton;
    CloseButton:ClearAllPoints();
    CloseButton:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -11, -11 + offsetY);

    local SearchBox = HeaderFrame.SearchBox
    SearchBox:ClearAllPoints();
    SearchBox:SetPoint("TOPRIGHT", HeaderFrame, "TOPRIGHT", -67, -5 + offsetY);

    local points = HeaderFrame.points;
    points:ClearAllPoints();
    points:SetPoint("TOPRIGHT", HeaderFrame, "TOP", 137, -17 + offsetY);

    local reference = HeaderFrame.reference;  --Summary All Points/Achv
    if index == 2 then
        reference:SetHeight(35);
    else
        reference:SetHeight(32);
    end

    local CloseButton = MainFrame.CloseButton;
    CloseButton.texture:SetTexture(texturePrefix.."CloseButton");
    if index == 2 then
        CloseButton:SetSize(39, 26);
    else
        CloseButton:SetSize(36, 26);
    end

    SummaryButton:ClearAllPoints();
    SummaryButton:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 32, -8 + offsetY);
    SummaryButton.texture:SetTexture(texturePrefix.."SummaryButton");


    --Tab buttons
    for i = 1, #TabButtons do
        TabButtons[i]:SetButtonTexture(texturePrefix.."TabButton");
        if index == 1 then
            TabButtons[i]:SetTextOffset(28);
        else
            TabButtons[i]:SetTextOffset(20);
        end
    end
    
    local resultButtonGap;
    if index == 3 then
        resultButtonGap = -1;
    else
        resultButtonGap = -2
    end
    for i = 2, #ResultButtons do
        ResultButtons[i]:SetPoint("TOP", ResultButtons[i - 1], "BOTTOM", 0, resultButtonGap);
    end

    --AlertSystem

    --Floating Cards
    for i = 1, #FloatingCards.cards do
        ReskinButton(FloatingCards.cards[i]);
    end
end


--------------------------------------------------------------------
local function UpdateTrackAchievements()
    local changedAchievementID = DataProvider:GetTrackedAchievements();
    if not changedAchievementID then return end

    local currentCategory = DataProvider.currentCategory;
    local categoryID = GetAchievementCategory(changedAchievementID);
    local shouldUpdate;
    if categoryID == currentCategory then
        shouldUpdate = true;
    end
    local isTracked = DataProvider:IsTrackedAchievement(changedAchievementID);

    if shouldUpdate then
        local numAchievements = DataProvider.numAchievements or 0;
        local card;
        for i = 1, numAchievements do
            card = AchievementCards[i];
            if card then
                if card.id == changedAchievementID then
                    card.trackIcon:SetShown(isTracked);
                end
            else
                break
            end
        end
    end

    if (InspectionFrame:IsShown()) and (changedAchievementID == InspectionFrame.Card.id) then
        InspectionFrame.Card.trackIcon:SetShown(isTracked);
    end
end

local function RefreshInspection(achievementID)
    --Refresh inspection card
    if (InspectionFrame:IsShown()) and (achievementID == InspectionFrame.Card.id) then
        InspectAchievement(achievementID);
    end
end

-------------------------------------------------------------------------------------
--Redirect Blizzard Achievement to Narcissus Achievement Frame
local Original_OnBlockHeaderClick = ACHIEVEMENT_TRACKER_MODULE.OnBlockHeaderClick;
local Original_OpenAchievementFrameToAchievement = OpenAchievementFrameToAchievement;

local function OnBlockHeaderClick(_, block, mouseButton)
    if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
        local achievementLink = GetAchievementLink(block.id);
        if ( achievementLink ) then
            ChatEdit_InsertLink(achievementLink);
        end
    elseif ( mouseButton ~= "RightButton" ) then
        if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
            ToggleTracking(block.id);
        else
            local clickAgainToClose = true;
            MainFrame:LocateAchievement(block.id, clickAgainToClose);
        end
    else
        ObjectiveTracker_ToggleDropDown(block, AchievementObjectiveTracker_OnOpenDropDown);
    end
end

local RedirectFrame = {};
RedirectFrame.hasOverwritten = false;

function RedirectFrame:RestoreFunctions()
    if self.hasOverwritten then
        self.hasOverwritten = false;
        OpenAchievementFrameToAchievement = Original_OpenAchievementFrameToAchievement;
        ACHIEVEMENT_TRACKER_MODULE.OnBlockHeaderClick = Original_OnBlockHeaderClick;
    end
end

function RedirectFrame:OverrideFunctions()
    if not self.hasOverwritten then
        self.hasOverwritten = true;
        function OpenAchievementFrameToAchievement(achievementID)
            MainFrame:LocateAchievement(achievementID);
        end

        ACHIEVEMENT_TRACKER_MODULE.OnBlockHeaderClick = OnBlockHeaderClick;
    end
end

local function OnAchivementEarned(achievementID)
    DataProvider:UpdateAchievementCache(achievementID);
    RefreshInspection(achievementID);
    
    local categoryID = GetAchievementCategory(achievementID);
    if categoryID then
        if DataProvider.achievementOrderCache[categoryID] then
            wipe(DataProvider.achievementOrderCache[categoryID]);
        end
        UpdateCategoryButtonProgressByCategoryID(categoryID);
        if categoryID == DataProvider.currentCategory then
            if MainFrame:IsShown() then
                SelectCategory(categoryID);
            else
                MainFrame.pendingCategoryID = categoryID;
            end
            return;
        end
    end
    if SummaryFrame:IsShown() then
        MainFrame.pendingUpdate = true;
    end
end


-----------------------------------------------------------------------------
local strsub = strsub;
local strsplit = strsplit;

local IS_TOOLTIP_HOOKED = false;
local ENABLE_TOOLTIP = false;
local tooltipButtons = {};

local function InsertTooltipButton(tooltipFrame, buttonIndex, achievementID, completed, topLine)
    --Called after adding new line
    local line;
    if topLine then
        line = 1;
    else
        line = tooltipFrame:NumLines();
    end
    if not tooltipButtons[buttonIndex] then
        tooltipButtons[buttonIndex] = CreateFrame("Button", nil, nil, "NarciAchievementTooltipButtonTemplate");
    end
    local button = tooltipButtons[buttonIndex];
    button:ClearAllPoints();
    button:SetParent(tooltipFrame);
    button.achievementID = achievementID;
    button:SetPoint("TOPLEFT", tooltipFrame:GetName().."TextLeft"..line, "TOPLEFT", 0, 2);
    if topLine then
        button:SetPoint("BOTTOMLEFT", tooltipFrame:GetName().."TextLeft"..line, "BOTTOMLEFT", 0, -2);
        button:SetWidth(tooltipFrame:GetWidth());
        button.closeFrame = true;
    else
        button:SetPoint("BOTTOMRIGHT", tooltipFrame:GetName().."TextLeft"..line, "BOTTOMRIGHT", 0, -2);
        button.closeFrame = false;
    end
    if completed then
        button.Highlight:SetVertexColor(0.251, 0.753, 0.251);
    else
        button.Highlight:SetVertexColor(1, 0.82, 0);
    end
    button:Show();
    if not tooltipFrame.insertedFrames then
        tooltipFrame.insertedFrames = {};
    end
    tinsert(tooltipFrame.insertedFrames, button);
end

local function HookAchievementTooltip()
    if IS_TOOLTIP_HOOKED then return end;
    IS_TOOLTIP_HOOKED = true;
    
    hooksecurefunc(ItemRefTooltip, "SetHyperlink", function(self, link)
        if not ENABLE_TOOLTIP then return end;

        if strsub(link, 1, 11) == "achievement" then
            local _, achievementID = strsplit(":", link);
            achievementID = tonumber(achievementID);
            local id, name, _, completed = DataProvider:GetAchievementInfo(achievementID);
            InsertTooltipButton(self, 1, achievementID, completed, true)
            local parentAchievementID1, parentAchievementID2 = GetParentAchievementID(achievementID, true);
            if parentAchievementID1 then
                self:AddLine(" ");
                local id, name, _, completed = DataProvider:GetAchievementInfo(parentAchievementID1);
                local colorString;
                if completed then
                    colorString = "|cff40c040";
                else
                    colorString = "|cFFFFD100";
                end
                --self:AddDoubleLine("|cFF808080> |r"..colorString..name.."|r", id, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, true);
                self:AddLine("|cFF808080> |r"..colorString..name.."|r", 0.5, 0.5, 0.5, true);
                InsertTooltipButton(self, 2, parentAchievementID1, completed);
                if parentAchievementID2 then
                    id, name, _, completed = DataProvider:GetAchievementInfo(parentAchievementID2);
                    if completed then
                        colorString = "|cff40c040";
                    else
                        colorString = "|cFFFFD100";
                    end
                    --self:AddDoubleLine("|cFF808080>> |r"..colorString..name.."|r", id, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, true);
                    self:AddLine("|cFF808080>> |r"..colorString..name.."|r", 0.5, 0.5, 0.5, true);
                    InsertTooltipButton(self, 3, parentAchievementID2, completed);
                end
                self:Show();
            end
        end
    end);
end


NarciAchievementExtraTooltipMixin = {};

function NarciAchievementExtraTooltipMixin:OnLoad()
    self:RegisterForDrag("LeftButton");
end

function NarciAchievementExtraTooltipMixin:OnDragStart()
    local parent = self:GetParent();
    if parent and parent.OnDragStart then
        parent:OnDragStart();
    end
end

function NarciAchievementExtraTooltipMixin:OnDragStop()
    local parent = self:GetParent();
    if parent and parent.OnDragStop then
        parent:OnDragStop();
    end
end

function NarciAchievementExtraTooltipMixin:OnClick(button)
    if self.achievementID then
        Narci_AchievementFrame:LocateAchievement(self.achievementID);
        if button == "RightButton" or self.closeFrame then
            self:GetParent():Hide();
        end
    end
end

-----------------------------------------------------------------------------
function NarciAchievement_RedirectPrimaryAchievementFrame()
    if NarciAchievementOptions.UseAsDefault then
        RedirectFrame:OverrideFunctions();
        HookAchievementTooltip()
        ENABLE_TOOLTIP = true;
        NarciAchievementAlertSystem:Enable();
    else
        RedirectFrame:RestoreFunctions();
        ENABLE_TOOLTIP = false;
        NarciAchievementAlertSystem:Disable();
    end
end

local initialize = CreateFrame("Frame");
initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
initialize:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event);
        DataProvider:GetTrackedAchievements();
        self:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED");
        self:RegisterEvent("ADDON_LOADED");

        After(0.7, function()
            NarciAchievement_RedirectPrimaryAchievementFrame();
            BuildCategoryStructure();
            local isGuild = true;
            BuildCategoryStructure(isGuild);
            InitializeFrame(Narci_AchievementFrame);
            self:RegisterEvent("ACHIEVEMENT_EARNED");
            self:RegisterEvent("CRITERIA_EARNED");
        end)

    elseif event == "ADDON_LOADED" then
        local name = ...;
        if name == "Blizzard_AchievementUI" then
            self:UnregisterEvent(event);
            NarciAchievement_RedirectPrimaryAchievementFrame();
        end

    elseif event == "ACHIEVEMENT_EARNED" then
        local achievementID = ...;
        OnAchivementEarned(achievementID);
        if not self.pauseUpdate then
            self.pauseUpdate = true;
            After(0, function()
                UpdateHeaderFrame(isGuildView);
                self.pauseUpdate = nil;
            end);
        end
    elseif event == "CRITERIA_EARNED" then
        local achievementID, description = ...;
        RefreshInspection(achievementID);

    elseif event == "TRACKED_ACHIEVEMENT_LIST_CHANGED" then
        UpdateTrackAchievements();
    end

    --print(event)
end)

--[[
    Sound:
    sound/spells/spell_ma_arcaneorb_impact_01.ogg
1401 sound/doodad/scroll_bookevaporate01.ogg



/run AchievementAlertSystem:AddAlert(13994, true)
--]]