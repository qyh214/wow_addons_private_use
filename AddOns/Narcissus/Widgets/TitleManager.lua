local abs = math.abs
--local L = Narci.L
local ColorTable = Narci_ColorTable;
local ColorIndex = Narci_GlobalColorIndex;
-----------------------------
------Build Title Table------
-----------------------------
local function BuildTitlesDB(object)
    local NewTable = {};	--[TitleID] = {Category, Rarity, SourceID}
    for key, value in pairs(object) do
        NewTable[value[4]] = {value[1], value[2], value[5]}; --value[3] is the title's name // value[4] is TitleID // value[5] is AchievementID;
        --i = i + 1;
    end
    return NewTable;
end

local TitlesDB = BuildTitlesDB(CharacterTitlesTable);
-----------------------------
-------Sorting Function------
-----------------------------
local sortMethod = "Category";
local function SortedByAlphabet(a, b) return a.name < b.name; end
local function SortedByCategory(a, b)
	if a.category == b.category then
		if a.rarity == b.rarity then
			r = a.name < b.name;
		else
			r = a.rarity > b.rarity;
		end
	else
		r = a.category < b.category; 
	end

	return r;
end

--Displayed Gradient Type
local function ColorByDefault(button, index)
	if index % 2 == 1 then
		button.BackgroundColor:SetGradient("HORIZONTAL", 0, 0 ,0, 0.2, 0.2, 0.2);
	else
		button.BackgroundColor:SetGradient("HORIZONTAL", 0.1, 0.1 ,0.1, 0.3, 0.3, 0.3);
	end
end

local function ColorByCategory(button, type)
	if type == "achv" or type == "pve" or type == "repu" then
		button.BackgroundColor:SetGradient("HORIZONTAL", 0.1, 0.1 ,0.1, 0.3, 0.3, 0.3);
	else
		button.BackgroundColor:SetGradient("HORIZONTAL", 0, 0 ,0, 0.2, 0.2, 0.2);
	end
end

--Derivative from Blizzard: PaperDollFrame.lua GetKnownTitles()
--** Add a new sort func & Mark the current title in the table
--** Also returns a table which tells how many titles you've got in each category

local function Narci_GetKnownTitles(sortMethod)
	local playerTitles = {};
	local numRare = 0;
	local titleCount = 2;
	local playerTitle = false;	
	local tempName = 0;
	local CurrentTitle = -1;
	local numPVP, numPVE, numACHV, numREPU, numEVENT = 0, 0, 0, 0, 0;
	local category, rarity;
	playerTitles[1] = { };
	-- reserving space for None so it doesn't get sorted out of the top position
	playerTitles[1].name = "       ";
	playerTitles[1].id = -1;
	playerTitles[1].category = "Z";
	playerTitles[1].rarity = 0;

	for i = 1, GetNumTitles() do
		if ( IsTitleKnown(i) ) then
			tempName, playerTitle = GetTitleName(i);
			if ( tempName and playerTitle ) then
				playerTitles[titleCount] = playerTitles[titleCount] or { };
				playerTitles[titleCount].name = strtrim(tempName);
				playerTitles[titleCount].id = i;

				if TitlesDB[i] then
					category = TitlesDB[i][1] or "achv";
					rarity = TitlesDB[i][2] or 0;
				else
					category = "achv";
					rarity = 0;
				end
				playerTitles[titleCount].category = category;
				playerTitles[titleCount].rarity = rarity;
				if category == "pvp" then
					numPVP = numPVP + 1;
				elseif category == "pve" then
					numPVE = numPVE + 1; 
				elseif category == "achv" then
					numACHV = numACHV + 1; 
				elseif category == "repu" then
					numREPU = numREPU + 1; 
				elseif category == "event" then
					numEVENT = numEVENT + 1; 
				end
				
				if rarity > 0 then
					numRare = numRare + 1;
				end
				titleCount = titleCount + 1;
			end
		end
	end

	if sortMethod == "Alphabet" then
		table.sort(playerTitles, SortedByAlphabet);
	elseif sortMethod == "Category" then
		table.sort(playerTitles, SortedByCategory);
	end

	playerTitles[1].name = PLAYER_TITLE_NONE;
	CurrentTitle = GetCurrentTitle();
	if CurrentTitle then
		playerTitles.CurrentTitle = CurrentTitle;
	end

	local CategoryDetails = {};
	CategoryDetails[4] = {numPVP, CALENDAR_TYPE_PVP};
	CategoryDetails[3] = {numPVE, TRANSMOG_SET_PVE};
	CategoryDetails[1] = {numACHV, AUCTION_CATEGORY_MISCELLANEOUS};
	CategoryDetails[5] = {numREPU, REPUTATION};
	CategoryDetails[2] = {numEVENT, BATTLE_PET_SOURCE_7};
	CategoryDetails.sum = #playerTitles;
	CategoryDetails.rare = numRare;

	return playerTitles, CategoryDetails;
end

--Derivative from Blizzard: HybridScrollFrame_CreateButtons

local function NarciAPI_BuildScrollFrame(self, buttonTemplate, initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint)
	local scrollChild = self.scrollChild;
	local button, buttonHeight, buttons, numButtons;

	local parentName = self:GetName();
	local buttonName = parentName and (parentName .. "Button") or nil;

	initialPoint = initialPoint or "TOPLEFT";
	initialRelative = initialRelative or "TOPLEFT";
	point = point or "TOPLEFT";
	relativePoint = relativePoint or "BOTTOMLEFT";
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;

	if ( self.buttons ) then
		buttons = self.buttons;
		buttonHeight = buttons[1]:GetHeight();
	else
		button = CreateFrame("BUTTON", buttonName and (buttonName .. 1) or nil, scrollChild, buttonTemplate);
		buttonHeight = button:GetHeight();
		button:SetPoint(initialPoint, scrollChild, initialRelative, initialOffsetX, initialOffsetY);
		buttons = {}
		if button.BackgroundColor then
			button.BackgroundColor:SetGradient("HORIZONTAL", 0, 0 ,0, 0.2, 0.2, 0.2);
		end
		tinsert(buttons, button);
	end

	self.buttonHeight = Round(buttonHeight) - offsetY;

	local numButtons = math.ceil(self:GetHeight() / buttonHeight) + 1;

	for i = #buttons + 1, numButtons do
		button = CreateFrame("BUTTON", buttonName and (buttonName .. i) or nil, scrollChild, buttonTemplate);
		button:SetPoint(point, buttons[i-1], relativePoint, offsetX, offsetY);
		if button.BackgroundColor then
			if i % 2 ==1 then
				button.BackgroundColor:SetGradient("HORIZONTAL", 0, 0 ,0, 0.2, 0.2, 0.2);
			else
				button.BackgroundColor:SetGradient("HORIZONTAL", 0.1, 0.1 ,0.1, 0.3, 0.3, 0.3);
			end
		end
		tinsert(buttons, button);
	end

	scrollChild:SetWidth(self:GetWidth())
	scrollChild:SetHeight(numButtons * buttonHeight);
	self:SetVerticalScroll(0);
	self:UpdateScrollChildRect();

	self.buttons = buttons;
	local scrollBar = self.scrollBar;
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar.buttonHeight = buttonHeight;
	scrollBar:SetValueStep(buttonHeight);
	scrollBar:SetStepsPerPage(numButtons - 2);
	scrollBar:SetValue(0);
end

local function SmoothScrollFrame_Update(self, totalHeight, displayedHeight)
	local range = floor(totalHeight - self:GetHeight() + 0.5);

	if ( range > 0 and self.scrollBar ) then
		local minVal, maxVal = self.scrollBar:GetMinMaxValues();
		if ( math.floor(self.scrollBar:GetValue()) >= math.floor(maxVal) ) then
			self.scrollBar:SetMinMaxValues(0, range)
			if ( math.floor(self.scrollBar:GetValue()) ~= math.floor(range) ) then
				self.scrollBar:SetValue(range);
			else
				HybridScrollFrame_SetOffset(self, range); -- If we've scrolled to the bottom, we need to recalculate the offset.
			end
		else
			self.scrollBar:SetMinMaxValues(0, range)
		end
		self.scrollBar:Enable();
		self.scrollBar:Show();
	elseif ( self.scrollBar ) then
		self.scrollBar:SetValue(0);
		if ( self.scrollBar.doNotHide ) then
			self.scrollBar:Disable();
			self.scrollBar.thumbTexture:Hide();
		else
			self.scrollBar:Hide();
		end
	end

	self.range = range;
	self.totalHeight = totalHeight;
	self.scrollChild:SetHeight(displayedHeight);
	self:UpdateScrollChildRect();
end

--Derivative from Blizzard: HybridScrollFrame_Update
function Narci_TitileManager_UpdateList()
	local scrollFrame = Narci_TitleManager.ListScrollFrame;
	local List = scrollFrame.updatedList
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numList = #List   --#buttons;
	--print("numList: "..numList)
	if numList > 1 then
		scrollFrame.scrollBar.thumbTexture:SetHeight(max((320*2/numList), 8))
	end

	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;
		if ( displayIndex <= numList ) then
			button.buttonID = List[displayIndex].id;

			if button.buttonID == List.CurrentTitle then
				button.SelectedColor:Show();
			else
				button.SelectedColor:Hide();
			end
			
			if button.BackgroundColor then
				if sortMethod == "Alphabet" then
					ColorByDefault(button, displayIndex);
				elseif sortMethod == "Category" then
					ColorByCategory(button, List[displayIndex].category);
				end
			end
			
			button.Name:SetText(List[displayIndex].name);
			button.Name:SetAlpha(1)

			if List[displayIndex].rarity > 0 then
				button.Star:Show();
			else
				button.Star:Hide();
			end

			button:Show();
			button:SetEnabled(true);
		else
			button:Hide();
			button:SetEnabled(false);
		end
	end
	local totalHeight = numList * buttons[1]:GetHeight();
	SmoothScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
end


-----------------------------
--------Initialization-------
-----------------------------

local function SortTitleList(method)
	local scrollFrame = Narci_TitleManager.ListScrollFrame;
	if method == "Category" then
		playerTitles_SortedByCategory, CategoryNumDetails = Narci_GetKnownTitles("Category");
		scrollFrame.updatedList = playerTitles_SortedByCategory;
	elseif method == "Alphabet" then
		playerTitles_SortedByAlphabet, CategoryNumDetails = Narci_GetKnownTitles("Alphabet");
		scrollFrame.updatedList = playerTitles_SortedByAlphabet;
	end
	Narci_TitileManager_UpdateList();
end


local function CreateSliderTextureAndLabel()
	if not CategoryNumDetails then
		return;
	end
	local max = math.max;
	local numTotal = CategoryNumDetails.sum or 1;
	local slider = Narci_TitleManager.ListScrollFrame.scrollBar;
	local sliderHeight = Narci_TitleManager_ListScrollFrame:GetHeight() or 0;
	local scrollChildHeight = numTotal * 20 --Title Button Height;
	local baseHeight = Narci_TitleManager.ListScrollFrame:GetHeight() or 1;
	local offsetX = 2;
	local width = 2;
	local minHeight = 8;
	local heightRatio = baseHeight/numTotal;
	local height = max(CategoryNumDetails[1][1] * heightRatio, minHeight);
	local lastHeight = height;
	local numType = 5;
	local TexName = "NarciTitleSliderTexture";
	local Tex = slider:CreateTexture(TexName.."1", "BACKGROUND");
	local Texs = {};
	local buttonName = "NarciTitleSliderLabel";
	local button = CreateFrame("BUTTON", buttonName.."1", slider, "TitleCategoryLabelTemplate");
	local buttonHeight = button:GetHeight();
	local buttons = {};
	local num = CategoryNumDetails[1][1] or 0;
	local lastNum = 0;

	local filterFrame = Narci_TitleManager_Filter;
	local numRare = CategoryNumDetails.rare or 0;
	filterFrame.Label:SetText(TOTAL.." "..(numTotal-1))
	if numRare > 0 then
		filterFrame.numRare:SetText(numRare)
		filterFrame.numRare:Show()
		filterFrame.Star:Show()
	end

	Tex:SetWidth(width);
	Tex:SetHeight(height);
	Tex:SetPoint("TOP", slider, "TOP", 0, 0)
	Tex:SetColorTexture(0.6, 0.6, 0.6, 1)
	tinsert(Texs, Tex);
	button:SetPoint("TOPLEFT", Tex, "TOPRIGHT", 2, 0)
	button.Label:SetText(num.." "..CategoryNumDetails[1][2]);
	button.value = lastNum;
	lastNum = lastNum + num;
	tinsert(buttons, button);

	for i=2, numType do
		num = CategoryNumDetails[i][1] or 0;
		height = max(num * heightRatio, minHeight);
		Tex = slider:CreateTexture(TexName..i, "BACKGROUND");
		Tex:SetWidth(width);
		

		if i < numType then
			Tex:SetHeight(height);
			Tex:SetPoint("TOP", Texs[i-1], "BOTTOM", 0, 0)
		else
			Tex:SetPoint("TOP", Texs[i-1], "BOTTOM", 0, 0)
			Tex:SetPoint("BOTTOM", slider, "BOTTOM", 0, 0)
		end

		button = CreateFrame("BUTTON", buttonName..i, slider, "TitleCategoryLabelTemplate");
		button:SetPoint("TOPLEFT", Tex, "TOPRIGHT", offsetX, 0)
		button.Label:SetText(num.." "..CategoryNumDetails[i][2]);


		if lastHeight < buttonHeight then
			button:ClearAllPoints();
			button:SetPoint("TOPLEFT", Tex, "TOPRIGHT", offsetX, lastHeight - buttonHeight)
		end
		lastHeight = height;

		if i % 2 == 1 then
			Tex:SetColorTexture(0.6, 0.6, 0.6, 1)
		else
			Tex:SetColorTexture(0.3, 0.3, 0.3, 1)
		end

		button.value = 20 * lastNum
		lastNum = lastNum + num;

		tinsert(Texs, Tex);
		tinsert(buttons, button);
	end

	slider.buttons = buttons;
	slider.Texs = Texs;
end

local function HideSliderLabel()
	local flag = NarcissusDB.IsSortedByCategory;
	local slider = Narci_TitleManager.ListScrollFrame.scrollBar;
	if not(slider.Texs and slider.buttons) then
		return;
	end
	
	for i=1, #slider.Texs do
		slider.Texs[i]:SetShown(flag);
	end
	for i=1, #slider.Texs do
		slider.buttons[i]:SetShown(flag);
	end
end
--Initialize
local playerTitles_SortedByAlphabet = {};
local playerTitles_SortedByCategory = {};
local CategoryNumDetails = {};

local function Narci_TitleManager_Filter_OnLoad(self)
	if NarcissusDB.IsSortedByCategory then
		sortMethod = "Category"
		self.Method:SetText(CATEGORY);
	else
		sortMethod = "Alphabet"
		self.Method:SetText(COMPACT_UNIT_FRAME_PROFILE_SORTBY_ALPHABETICAL);

	end
	SortTitleList(sortMethod);
end

local LoadSettings = CreateFrame("Frame");
LoadSettings:RegisterEvent("VARIABLES_LOADED");
LoadSettings:SetScript("OnEvent",function(self,event,...)
	C_Timer.After(2, function()
		Narci_TitleManager_Filter_OnLoad(Narci_TitleManager.FilterFrame)
		CreateSliderTextureAndLabel();
		HideSliderLabel();
	end)
end)



function Narci_TitleManager_Filter_OnClick(self)
	NarcissusDB.IsSortedByCategory = not NarcissusDB.IsSortedByCategory;
	Narci_TitleManager_Filter_OnLoad(self);
	HideSliderLabel();
	Narci_TitleManager.ListScrollFrame.scrollBar:SetValue(0);
end
-----------------------------
------AAA Smooth Scroll------
-----------------------------
local NarciAPI_SmoothScroll_Initialization = NarciAPI_SmoothScroll_Initialization;

function Narci_TitleManager_ListScrollFrame_OnLoad(self)
    self:EnableMouse(true);
    NarciAPI_BuildScrollFrame(self, "OptionalTitleTemplate", 0, 0, nil, nil, 0, 0);
	NarciAPI_SmoothScroll_Initialization(self, playerTitles, Narci_TitileManager_UpdateList, 3, 0.2)
end

function Narci_TitleToken_OnClick(self)
	if self.buttonID then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		SetCurrentTitle(self.buttonID);

		local scrollFrame = Narci_TitleManager.ListScrollFrame;
		scrollFrame.updatedList.CurrentTitle = self.buttonID;
		Narci_TitileManager_UpdateList();
	end
end


-------------------
--[[ LibEasing ]]--
local sin = math.sin;
local pi = math.pi;
local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end
-------------------

local TitleManagerHeight = 320 + 20;
local AnimDuration = 0.4;
--/run Narci_TitleFrame_AnimFrame:Show()
function Narci_TitleFrame_AnimFrame_OnUpdate(self, elapsed)
	local height, alpha;
	local t = self.TimeSinceLastUpdate;
	local targetFrame = Narci_TitleManager;
	local blackFrame = Narci_TitleFrameBlackScreen;

	if self.OppoDirection then
		height = outSine(t, self.startHeight, 0 - self.startHeight, AnimDuration);
		alpha = outSine(t, self.startAlpha, 0 - self.startAlpha, AnimDuration);
	else
		height = outSine(t, self.startHeight, TitleManagerHeight - self.startHeight, AnimDuration);
		alpha = outSine(t, self.startAlpha, 1 - self.startAlpha, AnimDuration);
	end

	targetFrame:SetHeight(height);
	blackFrame:SetAlpha(alpha);

	if t >= AnimDuration then
		if self.OppoDirection then
			targetFrame:SetHeight(0);
			blackFrame:SetAlpha(0);
		else
			targetFrame:SetHeight(TitleManagerHeight);
			blackFrame:SetAlpha(1);
		end

		self:Hide();
		return;
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

local function ShowTitleMangerTooltip(self, elapsed)
	self.counter = self.counter + elapsed;
	if self.counter > 0.8 then
		local tooltipFrame = self.Tooltip;
		local titleFrame = PlayerInfoFrame.Miscellaneous;
		if self.IsOn then
			tooltipFrame:SetText(NARCI_TITLE_MANAGER_CLOSE);
		else
			tooltipFrame:SetText(NARCI_TITLE_MANAGER_OPEN);
		end
		UIFrameFadeIn(tooltipFrame, 0.25, tooltipFrame:GetAlpha(), 1);
		UIFrameFadeOut(titleFrame, 0.15, titleFrame:GetAlpha(), 0);
		self.counter = 0;
		self:SetScript("OnUpdate", function()
		end)
	end
end

function Narci_TitleManager_Switch_TooltipCountDown(self)
	self:SetScript("OnUpdate", ShowTitleMangerTooltip);
end

function Narci_TitleFrame_SetColorTheme(self)
	local ColorIndex = Narci_GlobalColorIndex;
	local R, G, B = ColorTable[ColorIndex][1], ColorTable[ColorIndex][2], ColorTable[ColorIndex][3];
	local r, g, b = R/255, G/255 ,B/255;
	self.HighlightColor:SetColorTexture(r, g, b);
	self.SelectedColor:SetColorTexture(r, g, b);
end

local function SetTitleSourceTooltip()
	local name, description, icon;
	local tooltipFrame = Narci_TitleManager_TitleTooltip;

	if tooltipFrame.AchivementID then
		_, name, _, _, _, _, _, description, _, icon = GetAchievementInfo(tonumber(tooltipFrame.AchivementID));
		tooltipFrame.Icon:SetTexture(icon);
		tooltipFrame.Title:SetText(name);
		tooltipFrame.Description:SetText(description);
		local lines = tooltipFrame.Description:GetNumLines() + tooltipFrame.Title:GetNumLines();
		if lines < 3 then
			tooltipFrame.Description:SetText(description.."\n");
		end
	else
		return false;
	end

	if name then
		return true;
	else
		return false;
	end
end

local TooltipDelay = 0.6
local function Narci_TitleManager_Title_TooltipCountDown(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	if  self.TimeSinceLastUpdate > TooltipDelay then
		self:SetScript("OnUpdate", function() end);
		UIFrameFadeIn(self:GetParent(), 0.25, self:GetParent():GetAlpha(), 1);
		self:Hide()
	end
end

function OptionalTitle_OnEnter(self)
	local id = self.buttonID;
	--print(id)
	--print(TitlesDB[id][3])
	local tooltipFrame = Narci_TitleManager_TitleTooltip;

	if tooltipFrame:GetAlpha() ~= 1 then
		tooltipFrame.AnimFrame.TimeSinceLastUpdate = 0;
		tooltipFrame.AnimFrame:SetScript("OnUpdate", Narci_TitleManager_Title_TooltipCountDown);
	end


	if id == -1 then
		tooltipFrame:SetAlpha(0);
		return;
	end

	if id and TitlesDB[id] then
		tooltipFrame.AchivementID = TitlesDB[id][3]
		if SetTitleSourceTooltip() then
			tooltipFrame:ClearAllPoints();
			tooltipFrame:SetPoint("TOPRIGHT", self, "TOPLEFT", -8, 0);
			tooltipFrame.AnimFrame:Show();
		else
			tooltipFrame:SetAlpha(0)
			tooltipFrame.AnimFrame:Hide();
		end
	end
end

Test_ToggleAzeriteUI = function(forced)
    local CogWheel = _G.CogWheel
    if CogWheel then 
        local LibFader = CogWheel("LibFader", true)
        if LibFader then 
            LibFader:SetObjectFadeOverride(forced)
        end 
        local LibModule = CogWheel("LibModule", true)
        if LibModule then 
            local AzeriteUI = LibModule:GetModule("AzeriteUI", true)
            if AzeriteUI then 
                local ActionBars = AzeriteUI:GetModule("ActionBarMain", true)
                if (ActionBars) then 
                    ActionBars:SetForcedVisibility(forced)
                end 
            end 
        end 
    end 
end 