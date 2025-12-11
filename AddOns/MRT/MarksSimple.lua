local GlobalAddonName, ExRT = ...

if ExRT.isMN then
	return
end

local UnitName, UnitGUID, GetRaidTargetIndex, SetRaidTarget, math_frexp, tonumber = UnitName, UnitGUID, GetRaidTargetIndex, SetRaidTarget, math.frexp, tonumber
local wipe, sort = wipe, sort
local GetSpellInfo = ExRT.F.GetSpellInfo or GetSpellInfo
local IsEncounterInProgress = C_InstanceEncounter and C_InstanceEncounter.IsEncounterInProgress or IsEncounterInProgress

local VMRT = nil

local ELib,L = ExRT.lib,ExRT.L
local module = ExRT:New("AutoMarks",L.panelmarks)

local UpdateData

function module.options:Load()
	self:CreateTilte()
	
	self.decorationLine = CreateFrame("Frame",nil,self)
	self.decorationLine:SetPoint("TOPLEFT",self,0,-25)
	self.decorationLine:SetPoint("BOTTOMRIGHT",self,"TOPRIGHT",0,-45)
	ELib:Texture(self.decorationLine,1,1,1,1,"BACKGROUND"):Point('x'):Gradient("VERTICAL",.24,.25,.30,1,.27,.28,.33,1)
	
	self.t = ELib:Tabs(self,0,L.panelmarksTab1,L.panelmarksTab2,L.panelmarksTab3):Point(0,-45):Size(690,570):SetTo(ExRT.isMN and 1 or 3)
	self.t:SetBackdropBorderColor(0,0,0,0)
	self.t:SetBackdropColor(0,0,0,0)

	if ExRT.isMN then
		self.t.tabs[2].button:Hide()
		self.t.tabs[3].button:Hide()
	end
	
	local function Tab1EditBoxOnChange(self)
		local text = self:GetText()
		if strtrim(text) == "" then
			text = nil
		end
		VMRT.MarksSimple.names[self.index] = text
	end

	self.editbox = {}
	for i=1,4 do
		self.editbox[i] = {}
		for j=1,8 do
			local index = (i-1)*8+j
			self.editbox[i][j] = ELib:Edit(self.t.tabs[1]):Size(130,20):Text(VMRT.MarksSimple.names[index] or ""):OnChange(Tab1EditBoxOnChange)
			if i <= 2 then
				self.editbox[i][j]:Point("TOPRIGHT",self.t.tabs[1],"TOP",-5-140*(2-i),-34-(j-1)*25)
			else
				self.editbox[i][j]:Point("TOPLEFT",self.t.tabs[1],"TOP",5+140*(i-3),-34-(j-1)*25)
			end
			self.editbox[i][j].index = index
			if i==1 then
				ELib:Icon(self.t.tabs[1],"Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..j,16):Point("RIGHT",self.editbox[i][j],"LEFT",-10,0)
			end
		end
		ELib:Text(self.t.tabs[1],i,14,"GameFontNormal"):Point("BOTTOM",self.editbox[i][1],"TOP",0,5):Left():Color()
	end
	
	self.buttonclear = ELib:Button(self.t.tabs[1],L.panelmarksclear):Size(150,20):Point("TOP",0,-240):OnClick(function()
		for i=1,4 do
			for j=1,8 do
				module.options.editbox[i][j]:SetText("")
				VMRT.MarksSimple.names[(i-1)*8+j] = nil
			end
		end
	
	end) 
	
	ELib:Text(self.t.tabs[1],L.panelmarkstooltip,11,"GameFontNormal"):Point("TOP",self.buttonclear,"BOTTOM",0,-10):Point("LEFT",10,0):Point("RIGHT",-10,0):Color()

	----------------------------------

	self.autoMarkChkEnable = ELib:Check(self.t.tabs[2],L.Enable,VMRT.MarksSimple.autoMarkEnabled):AddColorState():Point(10,-10):OnClick(function(self) 
		if self:GetChecked() then
			VMRT.MarksSimple.autoMarkEnabled = true
		else
			VMRT.MarksSimple.autoMarkEnabled = nil
		end
		module:UpdateState()
	end)

	local npcIDtoName = {}
	local npcIDawait = {}

	local function Tab2LineUpdate(self,isFull)
		local num = self._i

		if isFull then
			self.edit:SetText(VMRT.MarksSimple.autoMarkNames[num] or "")
			self.marks.state = VMRT.MarksSimple.autoMarkState[num] or "87654321"
		end
		
		for i=1,#self.marks.list do
			local mark = self.marks.state:sub(i,i)
			if mark ~= "" then
				self.marks.list[i]:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
				SetRaidTargetIconTexture(self.marks.list[i], tonumber(mark,19))
			else
				self.marks.list[i]:SetTexture()
			end
			if mark == self.marks.picked_mark then
				self.marks.list[i]:SetAlpha(.7)
			else
				self.marks.list[i]:SetAlpha(1)			
			end
			self.marks.list[i]:SetShown(i <= 8 or self.isExpand)
		end
		if self.isExpand and not self.isExpanded then
			self.marks:SetWidth(20*17)
			self.edit:Size(470-20*8,20)
			self.isExpanded = true
		elseif not self.isExpand and self.isExpanded then
			self.marks:SetWidth(20*9)
			self.edit:Size(470,20)
			self.isExpanded = false
		end
	end

	local function Tab2EditboxNPCID(self)
		local text = self:GetText()
		local npcName
		if text and tonumber(text) then
			npcName = npcIDtoName[text]
			if not npcName and C_TooltipInfo then
				local tooltip = C_TooltipInfo.GetHyperlink("unit:Creature-0-0-0-0-"..text)
				if tooltip and tooltip.lines and tooltip.lines[1] and tooltip.lines[1].leftText ~= "" then
					npcName = tooltip.lines[1].leftText
					npcIDtoName[text] = npcName
				elseif not npcIDawait[text] then
					npcIDawait[text] = true
					C_Timer.After(0.5,function()
						Tab2EditboxNPCID(self)
					end)
				end
			end
		end
		if npcName then
			self.backgroundText2:SetText(npcName)
		else
			self.backgroundText2:SetText("")
		end
	end
	
	local function Tab2EditboxOnChange(self,isUser)
		Tab2EditboxNPCID(self)

		if not isUser then return end
		local text = self:GetText()
		if strtrim(text) == "" then text = nil end
		VMRT.MarksSimple.autoMarkNames[self._i] = text
		UpdateData()
		self:GetParent():Update()
	end
	local function Tab2MarksOnUpdate(self)
		if not IsMouseButtonDown(1) then
			self:SetScript("OnUpdate",nil)
			self.picked = nil
			self.picked_mark = nil
			VMRT.MarksSimple.autoMarkState[self:GetParent()._i] = self.state
			self:GetParent():Update()
			UpdateData()
			return
		end
		local currCursor = 1
		for i=1,self.state_len do
			local x,y = ExRT.F.GetCursorPos(self.list[i])
			if x < 0 then
				break
			end
			currCursor = i
		end
		local newState = self.saved_state:gsub(self.saved_state:sub(self.picked,self.picked),""):sub(1,currCursor-1) .. self.saved_state:sub(self.picked,self.picked) .. self.saved_state:gsub(self.saved_state:sub(self.picked,self.picked),""):sub(currCursor,-1)
		if newState ~= self.state then
			self.state = newState
			self:GetParent():Update()
		end
	end	
	local function Tab2MarksOnMouseDown(self,button)
		self.picked_mark = nil
		if button == "LeftButton" then
			local x,y = ExRT.F.GetCursorPos(self.list.refresh)
			if x >= 0 and x <= 19 then
				self.state = self:GetParent().isExpand and "876543219ABCDEFG" or "87654321"
				VMRT.MarksSimple.autoMarkState[self:GetParent()._i] = self.state
				self:GetParent():Update()
				UpdateData()
				return
			end		
		
			self.picked = nil
			for i=1,#self.list do
				if self.list[i]:IsShown() then
					local x,y = ExRT.F.GetCursorPos(self.list[i])
					if x >= 0 and x <= 19 then
						self.picked = i
						self.saved_state = self.state
						self.state_len = self.state:len()
						if self.state_len < i then
							return
						end
						break
					end
				end
			end
			if self.picked then
				self.picked_mark = self.saved_state:sub(self.picked,self.picked)
				self:SetScript("OnUpdate",Tab2MarksOnUpdate)
				self:GetParent():Update()
			end
		elseif button == "RightButton" then
			local x,y = ExRT.F.GetCursorPos(self.list.refresh)
			if x >= 0 and x <= 19 then
				--self:GetParent().isExpand = not self:GetParent().isExpand
				self:GetParent():Update()
				return
			end

			for i=1,#self.list do
				if self.list[i]:IsShown() then
					local x,y = ExRT.F.GetCursorPos(self.list[i])
					if x >= 0 and x <= 19 then
						local newState = self.state:sub(1,i-1)..self.state:sub(i+1,-1)
						self.state = newState
						VMRT.MarksSimple.autoMarkState[self:GetParent()._i] = newState
						self:GetParent():Update()
						UpdateData()
						break
					end
				end
			end			
		end
	end
	local function Tab2MarksListOnEnter(self)
		self:GetParent().Background:Show()
	end
	local function Tab2MarksListOnLeave(self)
		self:GetParent().Background:Hide()
	end

	local MARK_PAGE_COUNT = 20

	self.autoMarkLine = {}
	for i=1,MARK_PAGE_COUNT do
		local line = CreateFrame("Frame",nil,self.t.tabs[2])
		self.autoMarkLine[i] = line
		line:SetPoint("TOP",0,-35-(i-1)*25)
		line:SetPoint("LEFT",5,0)
		line:SetPoint("RIGHT",-25,0)
		line:SetHeight(25)
		line._i = i
		
		local edit = ELib:Edit(line):Size(460,20):Point("LEFT",5,0):Tooltip(L.panelmarksAutoMarkMobName):OnChange(Tab2EditboxOnChange):Text(VMRT.MarksSimple.autoMarkNames[i] or "")
		edit.backgroundText2 = ELib:Text(edit,"",12,"ChatFontNormal"):Point("LEFT",2,0):Point("RIGHT",-2,0):Color(.5,.5,.5):Right()
		edit._i = i
		line.edit = edit
		
		local marks = CreateFrame("Frame",nil,line)
		marks:EnableMouse(true)
		ELib:Border(marks,1,0.24,0.25,0.3,1,1)
		marks.Background = marks:CreateTexture(nil,"BACKGROUND")
		marks.Background:SetColorTexture(0,0,0,.3)
		marks.Background:SetPoint("TOPLEFT")
		marks.Background:SetPoint("BOTTOMRIGHT")
		marks:SetPoint("RIGHT",-5,0)
		marks:SetSize(20*9,20)
		marks.list = {}
		for i=1,16 do
			marks.list[i] = marks:CreateTexture(nil,"ARTWORK")
			marks.list[i]:SetPoint("LEFT",(i-1)*20,0)
			marks.list[i]:SetSize(18,18)
			marks.list[i]:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			SetRaidTargetIconTexture(marks.list[i], i)
			marks.list[i]:SetShown(i <= 8)
		end
		marks.list.refresh = marks:CreateTexture(nil,"ARTWORK")
		marks.list.refresh:SetPoint("RIGHT",0,0)
		marks.list.refresh:SetSize(18,18)
		marks.list.refresh:SetTexture([[Interface\AddOns\MRT\media\DiesalGUIcons16x256x128]])
		marks.list.refresh:SetTexCoord(0.125,0.1875,0.5,0.625)
		marks.list.refresh:SetVertexColor(1,1,1,0.7)	

		marks:SetScript("OnMouseDown",Tab2MarksOnMouseDown)
		
		marks.state = VMRT.MarksSimple.autoMarkState[i] or "87654321"
		
		line.marks = marks
		
		line.Update = Tab2LineUpdate
		line:Update()
		
		line.Background = line:CreateTexture(nil,"BACKGROUND")
		line.Background:SetColorTexture(1,1,1,.15)
		line.Background:SetPoint("TOPLEFT",-5)
		line.Background:SetPoint("BOTTOMRIGHT",5)
		line.Background:Hide()
		
		marks:SetScript("OnEnter",Tab2MarksListOnEnter)
		marks:SetScript("OnLeave",Tab2MarksListOnLeave)
	end

	local function UpdateMarkPage()
		local newPointer = floor( self.t.tabs[2].scrollBar:GetValue() + 0.5 )
		if self.markPagePointer == newPointer and self.markPageMax == VMRT.MarksSimple.markMax then
			return
		end
		self.markPagePointer = newPointer
		self.markPageMax = VMRT.MarksSimple.markMax

		if newPointer == select(2,self.t.tabs[2].scrollBar:GetMinMaxValues()) then
			self.markAddMore:Show()
			self.autoMarkLine[MARK_PAGE_COUNT]:Hide()
		else
			self.markAddMore:Hide()
			self.autoMarkLine[MARK_PAGE_COUNT]:Show()
		end

		for i=1,MARK_PAGE_COUNT do
			local line = self.autoMarkLine[i]
			line._i = newPointer+i-1
			line.edit._i = newPointer+i-1
			line:Update(true)
		end
	end

	self.markAddMore = ELib:Button(self.t.tabs[2],L.panelmarksBuffAddMore):Point(self.autoMarkLine[MARK_PAGE_COUNT]):Shown(false):OnClick(function()
		if type(VMRT.MarksSimple.markMax) ~= "number" then
			VMRT.MarksSimple.markMax = 100
		end
		VMRT.MarksSimple.markMax = VMRT.MarksSimple.markMax + 50
		if VMRT.MarksSimple.markMax > 1000 then
			VMRT.MarksSimple.markMax = 1000
		end
		UpdateMarkPage()

		local pointer = self.markPagePointer
		self.t.tabs[2].scrollBar:Range(1,max(1,(type(VMRT.MarksSimple.markMax)=="number" and VMRT.MarksSimple.markMax or 100)-MARK_PAGE_COUNT+1)+1):SetTo(pointer)
	end)

	self.t.tabs[2].scrollBar = ELib:ScrollBar(self.t.tabs[2]):Size(16,25*MARK_PAGE_COUNT):Point("TOPLEFT",self.autoMarkLine[1],"TOPRIGHT",5,0):Range(1,max(1,(type(VMRT.MarksSimple.markMax)=="number" and VMRT.MarksSimple.markMax or 100)-MARK_PAGE_COUNT+1)+1):OnChange(function(scrollBar)
		UpdateMarkPage()
	end)

	self.t.tabs[2]:SetScript("OnMouseWheel",function(_,delta)
		delta = -delta
		self.t.tabs[2].scrollBar:SetValue(tonumber(self.t.tabs[2].scrollBar:GetValue())+delta)
	end)

	ELib:Text(self.t.tabs[2],L.panelmarksTab2Tooltip,11,"GameFontNormal"):Point("TOP",self.autoMarkLine[#self.autoMarkLine],"BOTTOM",0,-10):Point("LEFT",10,0):Point("RIGHT",-10,0):Color()
	
	----------------------------------

	self.buffMarkChkEnable = ELib:Check(self.t.tabs[3],L.Enable,VMRT.MarksSimple.buffMarkEnabled):AddColorState():Point(10,-10):OnClick(function(self) 
		if self:GetChecked() then
			VMRT.MarksSimple.buffMarkEnabled = true
		else
			VMRT.MarksSimple.buffMarkEnabled = nil
		end
		module:UpdateState()
	end)
	
	local function Tab3LineUpdate(self,isFull)
		local num = self._i

		if isFull then
			self.edit:SetText(VMRT.MarksSimple.buffMarks[num] or "")
			self.marks.state = VMRT.MarksSimple.buffMarksState[num] or "12345678"
		end
		
		local spellID = VMRT.MarksSimple.buffMarks[num]
		if type(spellID)=='string' then
			spellID = spellID:gsub("%D","")
		end
		spellID = tonumber(spellID or "?")
		if not spellID then		
			self.texture:SetTexture("Interface\\Icons\\INV_MISC_QUESTIONMARK")
			self.text:SetText("")
		else
			local spellName,_,spellTexture = GetSpellInfo( spellID )
			self.texture:SetTexture(spellTexture)
			self.text:SetText(spellName)
		end
		
		for i=1,8 do
			local mark = self.marks.state:sub(i,i)
			if mark ~= "" then
				self.marks.list[i]:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark)
			else
				self.marks.list[i]:SetTexture()
			end
			if mark == self.marks.picked_mark then
				self.marks.list[i]:SetAlpha(.7)
			else
				self.marks.list[i]:SetAlpha(1)			
			end
		end
	end
	
	local function Tab3EditboxOnChange(self,isUser)
		if not isUser then return end
		local text = self:GetText()
		if strtrim(text) == "" then text = nil end
		VMRT.MarksSimple.buffMarks[self._i] = text
		UpdateData()
		self:GetParent():Update()
	end
	local function Tab3MarksOnUpdate(self)
		if not IsMouseButtonDown(1) then
			self:SetScript("OnUpdate",nil)
			self.picked = nil
			self.picked_mark = nil
			VMRT.MarksSimple.buffMarksState[self:GetParent()._i] = self.state
			self:GetParent():Update()
			UpdateData()
			return
		end
		local currCursor = 1
		for i=1,self.state_len do
			local x,y = ExRT.F.GetCursorPos(self.list[i])
			if x < 0 then
				break
			end
			currCursor = i
		end
		local newState = self.saved_state:gsub(self.saved_state:sub(self.picked,self.picked),""):sub(1,currCursor-1) .. self.saved_state:sub(self.picked,self.picked) .. self.saved_state:gsub(self.saved_state:sub(self.picked,self.picked),""):sub(currCursor,-1)
		if newState ~= self.state then
			self.state = newState
			self:GetParent():Update()
		end
	end	
	local function Tab3MarksOnMouseDown(self,button)
		self.picked_mark = nil
		if button == "LeftButton" then
			local x,y = ExRT.F.GetCursorPos(self.list[9])
			if x >= 0 and x <= 19 then
				VMRT.MarksSimple.buffMarksState[self:GetParent()._i] = nil
				self.state = "12345678"
				self:GetParent():Update()
				UpdateData()
				return
			end		
		
			self.picked = nil
			for i=1,8 do
				local x,y = ExRT.F.GetCursorPos(self.list[i])
				if x >= 0 and x <= 19 then
					self.picked = i
					self.saved_state = self.state
					self.state_len = self.state:len()
					if self.state_len < i then
						return
					end
					break
				end
			end
			if self.picked then
				self.picked_mark = self.saved_state:sub(self.picked,self.picked)
				self:SetScript("OnUpdate",Tab3MarksOnUpdate)
				self:GetParent():Update()
			end
		elseif button == "RightButton" then
			for i=1,8 do
				local x,y = ExRT.F.GetCursorPos(self.list[i])
				if x >= 0 and x <= 19 then
					local newState = self.state:sub(1,i-1)..self.state:sub(i+1,-1)
					self.state = newState
					VMRT.MarksSimple.buffMarksState[self:GetParent()._i] = newState
					self:GetParent():Update()
					UpdateData()
					break
				end
			end			
		end
	end
	local function Tab3EditboxOnEnter(self)
		ELib.Tooltip.Std(self)
		if self:GetText() and tonumber(self:GetText()) then
			ELib.Tooltip:Add("spell:"..self:GetText())
		end
	end
	local function Tab3EditboxOnLeave(self)
		ELib.Tooltip.Hide(self)
		ELib.Tooltip:HideAdd()
	end
	local function Tab3MarksListOnEnter(self)
		self:GetParent().Background:Show()
	end
	local function Tab3MarksListOnLeave(self)
		self:GetParent().Background:Hide()
	end

	local BUFF_PAGE_COUNT = 20

	self.buffMarkLine = {}
	for i=1,BUFF_PAGE_COUNT do
		local line = CreateFrame("Frame",nil,self.t.tabs[3])
		self.buffMarkLine[i] = line
		line:SetPoint("TOP",0,-35-(i-1)*25)
		line:SetPoint("LEFT",5,0)
		line:SetPoint("RIGHT",-25,0)
		line:SetHeight(25)
		line._i = i
		
		local edit = ELib:Edit(line):Size(140,20):Point("LEFT",5,0):Tooltip(L.panelmarksBuffMarkTooltip):OnChange(Tab3EditboxOnChange):Text(VMRT.MarksSimple.buffMarks[i] or "")
		edit._i = i
		edit:SetScript("OnEnter",Tab3EditboxOnEnter)
		edit:SetScript("OnLeave",Tab3EditboxOnLeave)
		line.edit = edit
		
		local texture = line:CreateTexture(nil, "BACKGROUND")
		texture:SetPoint("LEFT",edit,"RIGHT",11,0)
		texture:SetSize(24,24)
		line.texture = texture
		
		local text = ELib:Text(line,"",11):Point("LEFT",texture,"RIGHT",5):Color():Size(290,0)
		line.text = text
		
		local marks = CreateFrame("Frame",nil,line)
		marks:EnableMouse(true)
		ELib:Border(marks,1,0.24,0.25,0.3,1,1)
		marks.Background = marks:CreateTexture(nil,"BACKGROUND")
		marks.Background:SetColorTexture(0,0,0,.3)
		marks.Background:SetPoint("TOPLEFT")
		marks.Background:SetPoint("BOTTOMRIGHT")
		marks:SetPoint("RIGHT",-5,0)
		marks:SetSize(20*9,20)
		marks.list = {}
		for i=1,9 do
			marks.list[i] = marks:CreateTexture(nil,"ARTWORK")
			marks.list[i]:SetPoint("LEFT",(i-1)*20,0)
			marks.list[i]:SetSize(18,18)
			marks.list[i]:SetTexture(i <= 8 and "Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..i or [[Interface\AddOns\MRT\media\DiesalGUIcons16x256x128]])
			if i == 9 then
				marks.list[i]:SetTexCoord(0.125,0.1875,0.5,0.625)
				marks.list[i]:SetVertexColor(1,1,1,0.7)			
			end
		end
		marks:SetScript("OnMouseDown",Tab3MarksOnMouseDown)
		
		marks.state = VMRT.MarksSimple.buffMarksState[i] or "12345678"
		
		line.marks = marks
		
		line.Update = Tab3LineUpdate
		line:Update()
		
		line.Background = line:CreateTexture(nil,"BACKGROUND")
		line.Background:SetColorTexture(1,1,1,.15)
		line.Background:SetPoint("TOPLEFT",0,0)
		line.Background:SetPoint("BOTTOMRIGHT",0,0)
		line.Background:Hide()
		
		marks:SetScript("OnEnter",Tab3MarksListOnEnter)
		marks:SetScript("OnLeave",Tab3MarksListOnLeave)
	end

	local function UpdateBuffPage()
		local newPointer = floor( self.t.tabs[3].scrollBar:GetValue() + 0.5 )
		if self.buffPagePointer == newPointer and self.buffPageMax == VMRT.MarksSimple.buffMax then
			return
		end
		self.buffPagePointer = newPointer
		self.buffPageMax = VMRT.MarksSimple.buffMax

		if newPointer == select(2,self.t.tabs[3].scrollBar:GetMinMaxValues()) then
			self.buffAddMore:Show()
			self.buffMarkLine[BUFF_PAGE_COUNT]:Hide()
		else
			self.buffAddMore:Hide()
			self.buffMarkLine[BUFF_PAGE_COUNT]:Show()
		end

		for i=1,BUFF_PAGE_COUNT do
			local line = self.buffMarkLine[i]
			line._i = newPointer+i-1
			line.edit._i = newPointer+i-1
			line:Update(true)
		end
	end

	self.buffAddMore = ELib:Button(self.t.tabs[3],L.panelmarksBuffAddMore):Point(self.buffMarkLine[BUFF_PAGE_COUNT]):Shown(false):OnClick(function()
		if type(VMRT.MarksSimple.buffMax) ~= "number" then
			VMRT.MarksSimple.buffMax = 100
		end
		VMRT.MarksSimple.buffMax = VMRT.MarksSimple.buffMax + 50
		if VMRT.MarksSimple.buffMax > 1000 then
			VMRT.MarksSimple.buffMax = 1000
		end
		UpdateBuffPage()

		local pointer = self.buffPagePointer
		self.t.tabs[3].scrollBar:Range(1,max(1,(type(VMRT.MarksSimple.buffMax)=="number" and VMRT.MarksSimple.buffMax or 100)-BUFF_PAGE_COUNT+1)+1):SetTo(pointer)
	end)

	self.t.tabs[3].scrollBar = ELib:ScrollBar(self.t.tabs[3]):Size(16,25*BUFF_PAGE_COUNT):Point("TOPLEFT",self.buffMarkLine[1],"TOPRIGHT",5,0):Range(1,max(1,(type(VMRT.MarksSimple.buffMax)=="number" and VMRT.MarksSimple.buffMax or 100)-BUFF_PAGE_COUNT+1)+1):OnChange(function(scrollBar)
		UpdateBuffPage()
	end)

	self.t.tabs[3]:SetScript("OnMouseWheel",function(_,delta)
		delta = -delta
		self.t.tabs[3].scrollBar:SetValue(tonumber(self.t.tabs[3].scrollBar:GetValue())+delta)
	end)

	ELib:Text(self.t.tabs[3],L.panelmarksTab3Tooltip,11,"GameFontNormal"):Point("TOP",self.buffMarkLine[BUFF_PAGE_COUNT],"BOTTOM",0,-10):Point("LEFT",10,0):Point("RIGHT",-10,0):Color()

end

local data_buffs,data_buffs_state,data_names,data_names_state = {},{},{},{}
function UpdateData()
	wipe(data_buffs)
	wipe(data_buffs_state)
	if type(VMRT.MarksSimple.buffMax) ~= "number" or VMRT.MarksSimple.buffMax < 100 then
		VMRT.MarksSimple.buffMax = 100
	end
	if type(VMRT.MarksSimple.buffMax) == "number" and VMRT.MarksSimple.buffMax > 1000 then
		VMRT.MarksSimple.buffMax = 1000
	end
	local lastNonZeroIndex = 0
	for i=1,VMRT.MarksSimple.buffMax do
		if VMRT.MarksSimple.buffMarks[i] then
			local spellID = tonumber(VMRT.MarksSimple.buffMarks[i])
			if spellID then
				data_buffs[spellID] = true
				data_buffs_state[spellID] = VMRT.MarksSimple.buffMarksState[i] or "12345678"
			end
			lastNonZeroIndex = i
		end
	end
	if lastNonZeroIndex < 100 then
		lastNonZeroIndex = 100
	end
	VMRT.MarksSimple.buffMax = ceil(lastNonZeroIndex / 50) * 50

	wipe(data_names)
	wipe(data_names_state)
	if type(VMRT.MarksSimple.markMax) ~= "number" or VMRT.MarksSimple.markMax < 100 then
		VMRT.MarksSimple.markMax = 100
	end
	if type(VMRT.MarksSimple.markMax) == "number" and VMRT.MarksSimple.markMax > 1000 then
		VMRT.MarksSimple.markMax = 1000
	end
	local lastNonZeroIndex = 0
	for i=1,VMRT.MarksSimple.markMax do
		local name = VMRT.MarksSimple.autoMarkNames[i]
		if name and name ~= "" then
			if name:find("^%-") then
				name = name:gsub("^%-","")
			end
			data_names[ (name):lower() ] = true
			data_names_state[ (name):lower() ] = VMRT.MarksSimple.autoMarkState[i] or "87654321"
			lastNonZeroIndex = i
		end
	end
	if lastNonZeroIndex < 100 then
		lastNonZeroIndex = 100
	end
	VMRT.MarksSimple.markMax = ceil(lastNonZeroIndex / 50) * 50
end

local VMRT_MarksSimple_buffMarkEnabled, VMRT_MarksSimple_autoMarkEnabled
function module:UpdateState()
	UpdateData()
	VMRT_MarksSimple_buffMarkEnabled = VMRT.MarksSimple.buffMarkEnabled
	VMRT_MarksSimple_autoMarkEnabled = VMRT.MarksSimple.autoMarkEnabled
	if ExRT.isMN then
		return
	end
	module:UnregisterEvents('UNIT_TARGET','UPDATE_MOUSEOVER_UNIT','NAME_PLATE_UNIT_ADDED','INSTANCE_ENCOUNTER_ENGAGE_UNIT','UNIT_NAME_UPDATE','COMBAT_LOG_EVENT_UNFILTERED')
	if VMRT_MarksSimple_autoMarkEnabled then
		module:RegisterEvents('UNIT_TARGET','UPDATE_MOUSEOVER_UNIT','NAME_PLATE_UNIT_ADDED','INSTANCE_ENCOUNTER_ENGAGE_UNIT','UNIT_NAME_UPDATE')
	end
	if VMRT_MarksSimple_autoMarkEnabled or VMRT_MarksSimple_buffMarkEnabled then
		module:RegisterEvents('COMBAT_LOG_EVENT_UNFILTERED')
	end
	module:RegisterEvents('ENCOUNTER_END','ENCOUNTER_START')
end

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	VMRT.MarksSimple = VMRT.MarksSimple or {}
	
	VMRT.MarksSimple.names = VMRT.MarksSimple.names or {}
	VMRT.MarksSimple.autoMarkNames = VMRT.MarksSimple.autoMarkNames or {}
	VMRT.MarksSimple.autoMarkState = VMRT.MarksSimple.autoMarkState or {}
	VMRT.MarksSimple.buffMarks = VMRT.MarksSimple.buffMarks or {}
	VMRT.MarksSimple.buffMarksState = VMRT.MarksSimple.buffMarksState or {}
	
	module:UpdateState()
	module:RegisterSlash()
	module:RegisterAddonMessage()
end

function module:slash(arg)
	if arg:find("^mark ") then
		local patt = arg:match("^mark (%d+)")
		patt = tonumber(patt or "?")
		if patt and patt ~= 5 then
			for i=1,8 do
				local index = (patt-1)*8+i
				if VMRT.MarksSimple.names[index] then
					SetRaidTarget(VMRT.MarksSimple.names[index], i) 
				end
			end
		elseif patt == 5 then
			module:RegisterEvents('RAID_TARGET_UPDATE')
			for i=1,8 do
				SetRaidTarget("player", i) 
			end
		end
	end
end


function module.main:RAID_TARGET_UPDATE()
	if GetRaidTargetIndex("player") == 8 then
		SetRaidTarget("player", 0)
		module:UnregisterEvents('RAID_TARGET_UPDATE')
	end
end

local addon_msg_antispam = {}
function module:addonMessage(sender, prefix, ...)
	if prefix == "marks" then
		local spellID,eType = ...
		spellID = tonumber(spellID or "-")
		if type(spellID)~='number' or spellID < 1000000 then
			return
		end
		local t = GetTime()
		if (addon_msg_antispam[sender] or 0) >= t then
			return
		end
		addon_msg_antispam[sender] = t + 1
		local event = "SPELL_AURA_APPLIED"
		if eType == "2" then
			event = "SPELL_AURA_REMOVED"
		end
		sender = ExRT.F.delUnitNameServer(sender)
		module.main.COMBAT_LOG_EVENT_UNFILTERED(nil,event,nil,nil,nil,nil,nil,nil,sender,nil,nil,spellID)
	end
end


local guidToMark = {}
local marksUsed = {}

local FIX_UNIT_DEATH_ENCOUNTER = false
local FIX_NOT_UNIT_DEATH_ENCOUNTER = false
local FIX_RANGE_LIMIT = false
local FIX_CN_GENERALS = false

local function FreeMark(name)
	local state = data_names_state[name]
	for i=1,state:len() do
		local m = tonumber(state:sub(i,i),19)
		if m and not marksUsed[m] then
			return m
		end
	end
	return 0
end
local function ClearMark()
	wipe(marksUsed)
end

local function placeOnTargetOrMouseover(unit)
	local guid = UnitGUID(unit)
	if guid and not guidToMark[guid] then
		local name = UnitName(unit):lower()
		local type,_,serverID,instanceID,zoneUID,mobID,spawnID = strsplit("-", guid)
		if data_names[ name ] then
			local mark = FreeMark(name)
			if mark > 0 then
				guidToMark[guid] = mark
				if GetRaidTargetIndex(unit) ~= mark then 
					SetRaidTarget(unit, mark) 
				end
				marksUsed[mark] = true
				if FIX_UNIT_DEATH_ENCOUNTER then
					C_Timer.After(20,function()
						marksUsed[mark] = nil
					end)
				end
			end
		elseif (mobID and data_names[ mobID ]) then
			if FIX_RANGE_LIMIT and not UnitInRange(unit) then
				return
			elseif FIX_CN_GENERALS and mobID == "169601" then
				return
			end
			local mark = FreeMark(mobID)
			if mark > 0 then
				guidToMark[guid] = mark
				if GetRaidTargetIndex(unit) ~= mark then 
					SetRaidTarget(unit, mark) 
				end
				marksUsed[mark] = true
				if FIX_UNIT_DEATH_ENCOUNTER then
					C_Timer.After(20,function()
						marksUsed[mark] = nil
					end)
				end
			end
		end
	end
end

function module.main:UNIT_TARGET(unit)
	placeOnTargetOrMouseover(unit.."target")
end
function module.main:UPDATE_MOUSEOVER_UNIT()
	placeOnTargetOrMouseover("mouseover")
end
function module.main:NAME_PLATE_UNIT_ADDED(unitID)
	placeOnTargetOrMouseover(unitID)
end
function module.main:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	for i=1,8 do
		placeOnTargetOrMouseover("boss"..i)
	end
end
function module.main:UNIT_NAME_UPDATE(unit)
	placeOnTargetOrMouseover(unit)
end

local currentMarkBuffData = {}

function module.main.COMBAT_LOG_EVENT_UNFILTERED(_,event,_,sourceGUID,_,_,_,_,destName,_,destFlags2,spellId,spellName)
	if (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_APPLIED_DOSE") then
		if data_buffs[ spellId ] and VMRT_MarksSimple_buffMarkEnabled then
			if not currentMarkBuffData[spellId] then
				currentMarkBuffData[spellId] = 1
			end
			local currentMarkBuff = currentMarkBuffData[spellId]
			local currentMark = tonumber(data_buffs_state[spellId]:sub(currentMarkBuff,currentMarkBuff),19)
			if not currentMark then
				return
			end
			if GetRaidTargetIndex(destName) ~= currentMark then
				SetRaidTarget(destName, currentMark)
			end
			currentMarkBuffData[spellId] = currentMarkBuffData[spellId] + 1
			C_Timer.After(2, function()
				currentMarkBuffData[spellId] = 1
			end)
		end
	elseif event == "SPELL_AURA_REMOVED" then
		if data_buffs[ spellId ] and VMRT_MarksSimple_buffMarkEnabled then
			SetRaidTarget(destName, 0)
		elseif spellId == 343135 then		--CN: generals
			ClearMark()
			wipe(currentMarkBuffData)
			FIX_CN_GENERALS = true
			C_Timer.After(2,function()
				FIX_CN_GENERALS = false
			end)
		--[=[
		elseif spellId == 244894 then	--Aggramar 
			wipe(marksUsed)
		]=]
		end
	--[[
	elseif event == "SPELL_CAST_START" then	--Xanesh 
		if spellId == 312336 then
			ClearMark()
		end
	elseif event == "SPELL_CAST_SUCCESS" then
		if spellId == 210781 then	--Illgynoth
			ClearMark()
		elseif spellId == 209471 then	--Illgynoth
			local m = guidToMark[sourceGUID]
			if m then
				marksUsed[m] = nil
			end
		elseif spellId == 207513 then	--Trillax
			ClearMark()
		elseif spellId == 208863 then	--Elisande
			ClearMark()
		end
	]]
	elseif event == "UNIT_DIED" then
		if destFlags2 > 0 and VMRT_MarksSimple_autoMarkEnabled and not FIX_NOT_UNIT_DEATH_ENCOUNTER then
			local markFlag = bit.band(destFlags2, COMBATLOG_OBJECT_RAIDTARGET_MASK)
			local h,u = math_frexp(markFlag)
			marksUsed[u] = nil
		end
	end
end

function module.main:ENCOUNTER_END()
	ClearMark()
	FIX_UNIT_DEATH_ENCOUNTER = false
	FIX_RANGE_LIMIT = false
	wipe(currentMarkBuffData)
end
function module.main:ENCOUNTER_START(eID)
	ClearMark()
	if eID == 2051 then
		FIX_UNIT_DEATH_ENCOUNTER = true
	elseif eID == 2008 then
		--FIX_UNIT_DEATH_ENCOUNTER = true
	elseif eID == 2269 then
		FIX_UNIT_DEATH_ENCOUNTER = true
	elseif eID == 2328 then
		FIX_NOT_UNIT_DEATH_ENCOUNTER = true
	elseif eID == 2417 then
		--FIX_RANGE_LIMIT = true	
	elseif eID == 2422 then
		FIX_UNIT_DEATH_ENCOUNTER = true
	end
	wipe(currentMarkBuffData)
end