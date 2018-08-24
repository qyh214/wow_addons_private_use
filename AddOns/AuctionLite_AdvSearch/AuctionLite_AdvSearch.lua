
local L = LibStub("AceLocale-3.0"):GetLocale("AuctionLite_AdvSearch", true)
local AuctionLite = AuctionLite

AuctionLite_AdvSearch = {
	L = L,
	Quality = -1,
}
local AdvSearch = AuctionLite_AdvSearch



-- Tooltip code copied from TMW
local function TTOnEnter(self)
	if self.__title or self.__text then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		-- dumbed down from TMW here: we don't need to call get().
		GameTooltip:AddLine(self.__title, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, false)
		GameTooltip:AddLine(self.__text, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, not self.__noWrapTooltipText)
		GameTooltip:Show()
	end
end
local function TTOnLeave(self)
	GameTooltip:Hide()
end
local function TT(f, title, text, actualtitle, actualtext)
	-- setting actualtitle or actualtext true cause it to use exactly what is passed in for title or text as the text in the tooltip
	-- if these variables arent set, then it will attempt to see if the string is a global variable (e.g. "MAXIMUM")
	-- if they arent set and it isnt a global, then it must be a TMW localized string, so use that
	if title then
		f.__title = (actualtitle and title) or _G[title] or L[title]
	else
		f.__title = title
	end

	if text then
		f.__text = (actualtext and text) or _G[text] or L[text]
	else
		f.__text = text
	end

	if not f.__ttHooked then
		f.__ttHooked = 1
		f:HookScript("OnEnter", TTOnEnter)
		f:HookScript("OnLeave", TTOnLeave)
	else
		if not f:GetScript("OnEnter") then
			f:HookScript("OnEnter", TTOnEnter)
		end
		if not f:GetScript("OnLeave") then
			f:HookScript("OnLeave", TTOnLeave)
		end
	end
end



local Query, isOurQuery
hooksecurefunc(AuctionLite, "StartQuery", function(self, query)
	Query = query
end)
hooksecurefunc(AuctionLite, "QueryEnd", function(self)
	Query = nil
end)

hooksecurefunc(AuctionLite, "AuctionFrameBuy_Search", function(self)
	if Query then
		Query.useCustomParams = true
	end
end)

local oldQueryUpdate = AuctionLite.QueryUpdate
function AuctionLite.QueryUpdate(...)
	isOurQuery = true
	
	local success, err = pcall(oldQueryUpdate, ...)
	
	isOurQuery = false
	
	assert(success, err)
end

local oldQueryAuctionItems = QueryAuctionItems
function QueryAuctionItems(...)
	if isOurQuery and Query then
		if Query.useCustomParams then
			local canSend, canGetAll = CanSendAuctionQuery("list")
			
			local name
			if Query.name ~= nil then
				name = Query.name
			elseif Query.link ~= nil then
				name = AuctionLite:SplitLink(Query.link)
			end
			if name ~= nil then
				-- local MAX_QUERY_BYTES = 63
				name = AuctionLite:Truncate(name, 63)
			end

			oldQueryAuctionItems(
				name, 
				AdvSearch.Min, 
				AdvSearch.Max, 
				Query.page, 
				AdvSearch.Usable, 
				AdvSearch.Quality, 
				canGetAll and Query.getAll,
				Query.exact,
				AdvSearch.FilterCat and AdvSearch.FilterCat.filters or nil
			)
		else
			oldQueryAuctionItems(...)
		end
	else
		oldQueryAuctionItems(...)
	end
	
	AuctionLite:QueryAuctionItems_Hook()
end



function BuySearchButton:Disable() 
	-- disallow disableing of the search button
	-- (we want to allow searches without a name because there may be category/other filters in place)
end

BuyName:SetScript("OnTabPressed", function(self)
	if IsShiftKeyDown() then
		BuyMaxLevel:SetFocus()
	else
		BuyQuantity:SetFocus()
	end
end)
BuyQuantity:SetScript("OnTabPressed", function(self)
	if IsShiftKeyDown() then
		BuyName:SetFocus()
	else
		BuyMinLevel:SetFocus()
	end
end)

BuyName:SetWidth(200)
BuySearchButton:SetWidth(80)
BuyScanButton:SetWidth(80)
BuyQuantity:SetWidth(50-10)
BuyScanButton:ClearAllPoints()
BuyScanButton:SetPoint("TOPRIGHT", BuyExpand, "TOPRIGHT", -245, 28)
BuySearchButton:SetPoint("TOPRIGHT", BuyScanButton, "TOPLEFT", -3, 0)
BuyQuantityText:SetPoint("TOPLEFT", BuyNameText, 325 - 100, 0)

BuyUsableButton:SetFrameLevel(BuyUsableButton:GetFrameLevel() + 3)
BuyUsableButtonLabel:SetText(L["USE"])

BuyAdvancedText:Hide()
BuyAdvancedButton:SetPoint("TOPRIGHT", 60, -44 - 2)
BuyAdvancedButton:CreateFontString("BuyAdvancedTextSmall", "ARTWORK", "GameFontNormalSmall")
BuyAdvancedTextSmall:SetPoint("BOTTOM", BuyAdvancedButton, "TOP", 0, 0)
BuyAdvancedTextSmall:SetText(L["ADVANCED_TRUNC"])

BuyCategoryDropdownQualText:SetText(L["RARITY_LABEL"]:format(ALL))
TT(BuyName, "NAME", "NAME_DESC")
TT(BuyQuantity, "QUANTITY", "QUANTITY_DESC")
TT(BuySearchButton, "SEARCH", "SEARCH_DESC")
TT(BuyScanButton, "FULLSCAN", "FULLSCAN_DESC")
TT(BuyUsableButton, "USE", "USE_DESC")
TT(BuyCategoryDropdown, "CATEGORY", "CATEGORY_DESC")
TT(BuyMinLevel, "LEVEL_MIN", "LEVEL_MIN_DESC")
TT(BuyMaxLevel, "LEVEL_MAX", "LEVEL_MAX_DESC")
TT(BuyResetButton, "RESET", "RESET_DESC")
TT(BuyAdvancedButton, "ADVANCED", "ADVANCED_DESC")


local function AddDropdownSpacer()
	local info = UIDropDownMenu_CreateInfo()
	info.text = ""
	info.isTitle = true
	info.notCheckable = true
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
end

local function Dropdown(self, level)
	if level == 1 then
		-- rarity header
		local info = UIDropDownMenu_CreateInfo()
		info.text = L["RARITY"]
		info.value = "RARITY"
		
		info.tooltipTitle = L["RARITY"]
		info.tooltipText = L["RARITY_DESC"]
		info.tooltipOnButton = true
		
		info.hasArrow = true
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
		
		AddDropdownSpacer()
		
		--add the actual categories themselves
		for categoryIndex, category in pairs(AuctionCategories) do
			if not category.flags or not category.flags.WOW_TOKEN_FLAG then
				local info = UIDropDownMenu_CreateInfo()
				info.text = category.name
				info.value = categoryIndex
				info.hasArrow = not not category.subCategories
				info.checked = AdvSearch.FilterCat == category
				or AdvSearch.FilterCat and (AdvSearch.FilterCat.parent and (AdvSearch.FilterCat.parent == category or 
				    (AdvSearch.FilterCat.parent.parent and AdvSearch.FilterCat.parent.parent == category)))
				info.func = function()
					AdvSearch.FilterCat = category
					UIDropDownMenu_SetText(BuyCategoryDropdown, category.name)
					CloseDropDownMenus()
				end
				UIDropDownMenu_AddButton(info, level)
			end
		end
		
		AddDropdownSpacer()
		
		--adds a button at the bottom to clear the category and rarity filters
		local info = UIDropDownMenu_CreateInfo()
		info.text = L["CLEARCATEGORY"]
		
		info.tooltipTitle = L["CLEARCATEGORY"]
		info.tooltipText = L["CLEARCATEGORY_DESC"]
		info.tooltipOnButton = true
		
		info.hasArrow = false
		info.func = function()
			AdvSearch.FilterCat = nil
			UIDropDownMenu_SetText(BuyCategoryDropdown, L["CATEGORY"])
			BuyCategoryDropdownQualText:SetText(L["RARITY_LABEL"]:format(ALL))
			CloseDropDownMenus()
		end
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
		
	elseif level == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "RARITY" then
			-- populates the rarity menu with item qualities
			-- this is based on Blizzard_AuctionUI.lua/BrowseDropDown_Initialize()
			local info = UIDropDownMenu_CreateInfo()
			info.text = ALL
			info.value = -1
			info.checked = AdvSearch.Quality == -1
			info.func = function()
				AdvSearch.Quality = -1
				CloseDropDownMenus()
				BuyCategoryDropdownQualText:SetText(L["RARITY_LABEL"]:format(ALL))
			end
			UIDropDownMenu_AddButton(info,level)
		
			AddDropdownSpacer()
			
			for i = 0, #ITEM_QUALITY_COLORS-2  do
				local info = UIDropDownMenu_CreateInfo()
				local r, g, b, hex = GetItemQualityColor(i)
				hex = "|c" .. hex
				info.text = hex .. _G["ITEM_QUALITY" .. i .. "_DESC"]
				info.checked = AdvSearch.Quality == i
				info.func = function()
					AdvSearch.Quality = i
					BuyCategoryDropdownQualText:SetText(L["RARITY_LABEL"]:format(hex .. _G["ITEM_QUALITY" .. i .. "_DESC"] .. "|r"))
					CloseDropDownMenus()
				end
				UIDropDownMenu_AddButton(info,level)
			end
		end
		
		--populates the category menus with subcategories
		for categoryIndex, category in ipairs(AuctionCategories) do
			if UIDROPDOWNMENU_MENU_VALUE == categoryIndex and category.subCategories then
				for subCatIndex, subCat in pairs(category.subCategories) do					
					local info = UIDropDownMenu_CreateInfo()
					info.text = subCat.name
					info.value = subCat
					info.checked = (
						AdvSearch.FilterCat == subCat or (AdvSearch.FilterCat and AdvSearch.FilterCat.parent and (AdvSearch.FilterCat.parent == subCat))
					)
					info.func = function()
						AdvSearch.FilterCat = subCat
						UIDropDownMenu_SetText(BuyCategoryDropdown, subCat.name)
						CloseDropDownMenus()
					end
					
					-- true if the category is armor and subCat is misc, cloth, leather, mail, plate
					info.hasArrow = not not subCat.subCategories
					
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end
		
	elseif level == 3 then
		--populates the sub-sub category menus of armor types that have sub-subcategories
		for subSubCatIndex, subSubCat in ipairs(UIDROPDOWNMENU_MENU_VALUE.subCategories) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = subSubCat.name
			info.checked = (
				AdvSearch.FilterCat == subSubCat
			)
			info.func = function()
				AdvSearch.FilterCat = subSubCat
				
				UIDropDownMenu_SetText(BuyCategoryDropdown, subSubCat.parent.name .. " " .. subSubCat.name)
				CloseDropDownMenus()
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
end
--This is run by the OnLoad script of BuyCategoryDropdown in BuyFrame.xml (not anymore)
--function BuyFrameCatDropdownInit()
	UIDropDownMenu_SetText(BuyCategoryDropdown, L["CATEGORY"])
	BuyCategoryDropdown:Show()
	UIDropDownMenu_Initialize(BuyCategoryDropdown, Dropdown)
	UIDropDownMenu_SetWidth(BuyCategoryDropdown, 100)
	UIDropDownMenu_SetButtonWidth(BuyCategoryDropdown, 124)
	UIDropDownMenu_JustifyText(BuyCategoryDropdown, "LEFT")
--end
