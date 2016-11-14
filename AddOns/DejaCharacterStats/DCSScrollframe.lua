local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

-- Scroll Frame	

-- Scrollframe Parent Frame
	local DCS_ScrollframeParentFrame = CreateFrame("Frame", "DCS_ScrollframeParentFrame", CharacterFrameInsetRight)
		DCS_ScrollframeParentFrame:SetSize(198, 352)
		DCS_ScrollframeParentFrame:SetPoint("TOP", CharacterFrameInsetRight, "TOP", 0, -4)

local _, private = ...
private.defaults.dcsdefaults.dejacharacterstatsScrollbarMax = {
	DCS_ScrollbarMax = 34,
}	
 -- Scrollframe 
	local DCS_ScrollFrame = CreateFrame("ScrollFrame", nil, DCS_ScrollframeParentFrame)
		DCS_ScrollFrame:SetPoint("TOP")
		DCS_ScrollFrame:SetSize(DCS_ScrollframeParentFrame:GetSize())

--	local DCS_scrollframetexture = DCS_ScrollFrame:CreateTexture() 
--		DCS_scrollframetexture:SetAllPoints() 
--		DCS_scrollframetexture:SetColorTexture(.5,.5,.5,1) 

-- DCS_Scrollbar 
	local DCS_Scrollbar = CreateFrame("Slider", "DCS_Scrollbar", DCS_ScrollFrame, "UIPanelScrollBarTemplate") 
		DCS_Scrollbar:RegisterEvent("PLAYER_LOGIN")
		DCS_Scrollbar:SetPoint("TOPLEFT", CharacterFrameInsetRight, "TOPRIGHT", -18, -20) 
		DCS_Scrollbar:SetPoint("BOTTOMLEFT", CharacterFrameInsetRight, "BOTTOMRIGHT", -18, 18) 
		DCS_Scrollbar:SetValueStep(1) 
		DCS_Scrollbar.scrollStep = 1
		DCS_Scrollbar:SetValue(0) 
		DCS_Scrollbar:SetWidth(16) 
--		DCS_Scrollbar:Hide() 

	DCS_Scrollbar:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local cur_val = self:GetValue()
		local min_val, max_val = DCS_Scrollbar:GetMinMaxValues()
		DCS_Scrollbar:SetMinMaxValues(cur_val, private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax)
		if DCS_SelectStatsCheck:GetChecked(true) then
				private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax = 142
			elseif not DCS_SelectStatsCheck:GetChecked(true) then
				if DCS_ShowAllStatsCheck:GetChecked(true) then
					private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax = 128
				elseif not DCS_ShowAllStatsCheck:GetChecked(true) then
					private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax = 34
				end
			end
			DCS_Scrollbar:UnregisterAllEvents();
		end
	end)
	
	DCS_Scrollbar:SetScript("OnValueChanged", function (self, value) 
		local cur_val = self:GetValue()
		local min_val, max_val = DCS_Scrollbar:GetMinMaxValues()
		
		DCS_Scrollbar:SetMinMaxValues(cur_val, private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax)

		self:GetParent():SetVerticalScroll(value) 
	end) 

-- Scrollbar Check

	local _, gdbprivate = ...
	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsScrollbarChecked = {
		ScrollbarSetChecked = false,
	}	
	
local DCS_ScrollbarCheck = CreateFrame("CheckButton", "DCS_ScrollbarCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ScrollbarCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ScrollbarCheck:ClearAllPoints()
	DCS_ScrollbarCheck:SetPoint("LEFT", 25, -175)
	DCS_ScrollbarCheck:SetScale(1.25)
	DCS_ScrollbarCheck.tooltipText = L['Displays the DCS scrollbar.'] --Creates a tooltip on mouseover.
	_G[DCS_ScrollbarCheck:GetName() .. "Text"]:SetText(L["Scrollbar"])
	
	DCS_ScrollbarCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked
			self:SetChecked(checked.ScrollbarSetChecked)
			if self:GetChecked(true) then
				DCS_Scrollbar:Show() 
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked = true
			else
				DCS_Scrollbar:Hide() 
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked = false
			end
		end
		DCS_ScrollbarCheck:UnregisterAllEvents();
	end)

	DCS_ScrollbarCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked
		if self:GetChecked(true) then
			DCS_Scrollbar:Show() 
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked = true
		else
			DCS_Scrollbar:Hide() 
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked = false
		end
	end)
 
-- DCS_ScrollChild Frame
	local DCS_ScrollChild = CreateFrame("Frame", nil, DCS_ScrollFrame)
		DCS_ScrollChild:SetSize(DCS_ScrollFrame:GetSize())
		DCS_ScrollFrame:SetScrollChild(DCS_ScrollChild)

-- 	Debugging Texture
--	local DCS_ScrollChildtexture = DCS_ScrollChild:CreateTexture() 
--		DCS_ScrollChildtexture:SetAllPoints(DCS_ScrollChild) 
--		DCS_ScrollChildtexture:SetColorTexture(.5,.5,.5,1) 
--		DCS_ScrollChildtexture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo") 

	CharacterStatsPane:ClearAllPoints()
	CharacterStatsPane:SetParent(DCS_ScrollChild)
	CharacterStatsPane:SetSize(DCS_ScrollChild:GetSize())
	CharacterStatsPane:SetPoint("TOP", DCS_ScrollChild, "TOP", 0, 0) 

	CharacterStatsPane.ClassBackground:ClearAllPoints()
	CharacterStatsPane.ClassBackground:SetParent(CharacterFrameInsetRight)
	CharacterStatsPane.ClassBackground:SetPoint("CENTER")
	
-- Enable mousewheel scrolling
	DCS_ScrollFrame:EnableMouseWheel(true)
	DCS_ScrollFrame:SetScript("OnMouseWheel", function(self, delta)
		DCS_Scrollbar:SetMinMaxValues(0, private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax)
		local cur_val = DCS_Scrollbar:GetValue()
		local min_val, max_val = DCS_Scrollbar:GetMinMaxValues()

		if delta < 0 and cur_val < max_val then
			if IsShiftKeyDown() then
				if DCS_SelectStatsCheck:GetChecked(true) then
					DCS_Scrollbar:SetValue(142)
				elseif DCS_ShowAllStatsCheck:GetChecked(true) then
					DCS_Scrollbar:SetValue(128)
				elseif not DCS_ShowAllStatsCheck:GetChecked(true) then
					DCS_Scrollbar:SetValue(34)
				end
			else
				cur_val = math.min(max_val, cur_val + 22)
				DCS_Scrollbar:SetValue(cur_val)
			end
		elseif delta > 0 and cur_val > min_val then
			if IsShiftKeyDown() then
				DCS_Scrollbar:SetValue(0)
			else
				cur_val = math.max(min_val, cur_val - 22)
				DCS_Scrollbar:SetValue(cur_val)
			end
		end
	end)
	
-- DejaCharacterStats
  
	CharacterStatsPane.ItemLevelCategory:Hide()
	CharacterStatsPane.ItemLevelCategory.Title:Hide()
	CharacterStatsPane.ItemLevelCategory.Background:Hide()

	CharacterStatsPane.ItemLevelFrame:ClearAllPoints()
	CharacterStatsPane.ItemLevelFrame:SetWidth(186)
	CharacterStatsPane.ItemLevelFrame:SetHeight(28)
	CharacterStatsPane.ItemLevelFrame:SetPoint(
		"TOP", CharacterStatsPane, "TOP", 0, -8)

	CharacterStatsPane.ItemLevelFrame.Background:ClearAllPoints()
	CharacterStatsPane.ItemLevelFrame.Background:SetWidth(186)
	CharacterStatsPane.ItemLevelFrame.Background:SetHeight(28)
	CharacterStatsPane.ItemLevelFrame.Background:SetPoint(
		"CENTER", CharacterStatsPane.ItemLevelFrame, "CENTER", 0, 0)

	CharacterStatsPane.ItemLevelFrame.Value:SetFont(
		"Fonts\\FRIZQT__.TTF", 22, "THINOUTLINE")

	hooksecurefunc(CharacterStatsPane.AttributesCategory,"SetPoint",function(self,_,_,_,_,_,flag)
		if flag~="CharacterStatsPane" then
			self:ClearAllPoints()
			self:SetWidth(186)
			self:SetHeight(28)
			self:SetPoint(
				"TOP", CharacterStatsPane.ItemLevelFrame, "BOTTOM", 0, -2, "CharacterStatsPane")
			-- Reset DCS_Scrollbar when the CharacterStatsPane is closed and reopened.
			DCS_Scrollbar:SetValue(0) 
		end
	end)

	hooksecurefunc(CharacterStatsPane.AttributesCategory.Background,"SetPoint",function(self,_,_,_,_,_,flag)
		if flag~="CharacterStatsPane" then
			self:ClearAllPoints()
			self:SetPoint(
				"CENTER", CharacterStatsPane.AttributesCategory, "CENTER", 0, 2, "CharacterStatsPane")
		end
	end)
	
	CharacterStatsPane.AttributesCategory.Background:SetWidth(186)
	CharacterStatsPane.AttributesCategory.Background:SetHeight(28)
		
	CharacterStatsPane.EnhancementsCategory:SetWidth(186)
	CharacterStatsPane.EnhancementsCategory:SetHeight(28)

	CharacterStatsPane.EnhancementsCategory.Background:SetWidth(186)
	CharacterStatsPane.EnhancementsCategory.Background:SetHeight(28)
	
	PaperDollSidebarTab1:HookScript("OnShow", function(self,event) 
		DCS_ScrollframeParentFrame:Show()
	end)

	PaperDollSidebarTab1:HookScript("OnClick", function(self,event) 
		DCS_ScrollframeParentFrame:Show()
	end)
	
	PaperDollSidebarTab2:HookScript("OnClick", function(self,event) 
		DCS_ScrollframeParentFrame:Hide()
	end)
	
	PaperDollSidebarTab3:HookScript("OnClick", function(self,event) 
		DCS_ScrollframeParentFrame:Hide()
	end)