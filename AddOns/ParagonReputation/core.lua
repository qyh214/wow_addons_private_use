		-------------------------------------------------
		-- Paragon Reputation 1.60 by Fail US-Ragnaros --
		-------------------------------------------------

		  --[[	  Special thanks to Ammako for
				  helping me with the vars and
				  the options.						]]--

local ADDON_NAME,ParagonReputation = ...
local PR = ParagonReputation

-- [Pet Rewards] Check if a Pet Reward is already owned.
local ParagonPetSearchTooltip = CreateFrame("GameTooltip","ParagonPetSearchTooltip",nil,"GameTooltipTemplate")
local function ParagonIsPetOwned(link)
	ParagonPetSearchTooltip:SetOwner(UIParent,"ANCHOR_NONE")
	ParagonPetSearchTooltip:SetHyperlink(link)
	for index=3,5 do
		local text = _G["ParagonPetSearchTooltipTextLeft"..index] and _G["ParagonPetSearchTooltipTextLeft"..index]:GetText()
		if text and string.find(text,"(%d)/(%d)") then
			return true
		end
	end
	return false
end

-- [GameTooltip] Add Paragon Rewards to the Tooltip.
local ParagonItemInfoReceivedQueue = {}
local function AddParagonRewardsToTooltip(self,tooltip,rewards)
	if rewards then
		for index,data in ipairs(rewards) do
			local name,link,quality,_,_,_,_,_,_,icon = C_Item.GetItemInfo(data.itemID)
			if name then
				local collected
				if data.type == MOUNT then
					collected = select(11,C_MountJournal.GetMountInfoByID(data.mountID))
				elseif data.type == PET and link then
					collected = ParagonIsPetOwned(link)
				elseif data.type == TOY then
					collected = PlayerHasToy(data.itemID)
				elseif data.type == ITEM_COSMETIC then
					collected = C_TransmogCollection.PlayerHasTransmogByItemInfo(data.itemID)
				elseif data.type == BINDING_HEADER_OTHER then
					collected = C_QuestLog.IsQuestFlaggedCompleted(data.questID)
				end
				tooltip:AddLine(string.format("|A:common-icon-%s:14:14|a |T%d:0|t %s %s",collected and "checkmark" or "redx",icon,name,data.covenant or "|cffffd000(|r|cffffffff"..data.type.."|r|cffffd000)|r"),ITEM_QUALITY_COLORS[quality].r,ITEM_QUALITY_COLORS[quality].g,ITEM_QUALITY_COLORS[quality].b)
			else
				tooltip:AddLine(ERR_TRAVEL_PASS_NO_INFO,1,0,0)
				ParagonItemInfoReceivedQueue[data.itemID] = self
			end
		end
	else
		tooltip:AddLine(VIDEO_OPTIONS_NONE,1,0,0)
	end
end

-- [GameTooltip] Show the GameTooltip with the Item Reward on mouseover. (Thanks Brudarek)
function ParagonReputation:Tooltip(self)
	if not self.questID or not PR.PARAGON_DATA[self.questID] then return end
	EmbeddedItemTooltip:ClearLines()
	EmbeddedItemTooltip:SetOwner(self,"ANCHOR_RIGHT")
	ReputationParagonFrame_SetupParagonTooltip(self)
	GameTooltip_SetBottomText(EmbeddedItemTooltip,REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION,GREEN_FONT_COLOR)
	AddParagonRewardsToTooltip(self,EmbeddedItemTooltip,PR.PARAGON_DATA[self.questID].rewards)
	EmbeddedItemTooltip:AddLine(" ")
	EmbeddedItemTooltip:AddLine(string.format(ARCHAEOLOGY_COMPLETION,self.count))
	EmbeddedItemTooltip:AddLine(" ")
	EmbeddedItemTooltip:SetClampedToScreen(true)
	EmbeddedItemTooltip.paragon_clamp = true
	EmbeddedItemTooltip:Show()
end

local ACTIVE_TOAST = false
local WAITING_TOAST = {}

-- [Paragon Toast] Show the Paragon Toast if a Paragon Reward Quest is accepted.
function ParagonReputation:ShowToast(name,text)
	ACTIVE_TOAST = true
	if PR.DB.sound then PlaySound(44295,"master",true) end
	PR.toast:EnableMouse(false)
	PR.toast.title:SetText(name)
	PR.toast.title:SetAlpha(0)
	PR.toast.description:SetText(text)
	PR.toast.description:SetAlpha(0)
	PR.toast.reset:Hide()
	PR.toast.lock:Hide()
	UIFrameFadeIn(PR.toast,.5,0,1)
	C_Timer.After(.5,function()
		UIFrameFadeIn(PR.toast.title,.5,0,1)
	end)
	C_Timer.After(.75,function()
		UIFrameFadeIn(PR.toast.description,.5,0,1)
	end)
	C_Timer.After(PR.DB.fade,function()
		UIFrameFadeOut(PR.toast,1,1,0)
	end)
	C_Timer.After(PR.DB.fade+1.25,function()
		PR.toast:Hide()
		ACTIVE_TOAST = false
		if #WAITING_TOAST > 0 then
			PR:WaitToast()
		end
	end)
end

-- [Paragon Toast] Get next Paragon Reward Quest if more than two are accepted at the same time.
function ParagonReputation:WaitToast()
	local name,text = unpack(WAITING_TOAST[1])
	table.remove(WAITING_TOAST,1)
	PR:ShowToast(name,text)
end

-- [Paragon Toast] Handle QUEST_ACCEPTED and GET_ITEM_INFO_RECEIVED events.
local events = CreateFrame("FRAME")
events:RegisterEvent("QUEST_ACCEPTED")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:SetScript("OnEvent",function(self,event,arg1,arg2)
	if event == "QUEST_ACCEPTED" and PR.DB.toast and PR.PARAGON_DATA[arg1] then
		local data = C_Reputation.GetFactionDataByID(PR.PARAGON_DATA[arg1].factionID)
		local text = GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(arg1))
		if ACTIVE_TOAST then
			WAITING_TOAST[#WAITING_TOAST+1] = {data.name,text} --Toast is already active, put this info on the line.
		else
			PR:ShowToast(data.name,text)
		end
	elseif event == "GET_ITEM_INFO_RECEIVED" and arg2 and ParagonItemInfoReceivedQueue[arg1] then
		if ParagonItemInfoReceivedQueue[arg1]:IsMouseOver() and EmbeddedItemTooltip:GetOwner() == ParagonItemInfoReceivedQueue[arg1] then
			PR:Tooltip(ParagonItemInfoReceivedQueue[arg1])
		end
		ParagonItemInfoReceivedQueue[arg1] = nil
	end
end)

-- [Paragon Overlay] Create the Overlay for the Reputation Bar.
function ParagonReputation:CreateBarOverlay(bar)
	local overlay = CreateFrame("FRAME",nil,bar)
	overlay:SetAllPoints(bar)
	overlay:SetFrameLevel(bar:GetFrameLevel())
	overlay.bar = overlay:CreateTexture(nil,"ARTWORK",nil)
	local texture = bar:GetStatusBarTexture():GetTexture()
	bar.LeftTexture:SetDrawLayer("ARTWORK",1)
	bar.RightTexture:SetDrawLayer("ARTWORK",1)
	overlay.bar:SetTexture(texture == 136570 and "Interface\\TARGETINGFRAME\\UI-StatusBar" or texture)
	overlay.bar:SetPoint("TOP",overlay)
	overlay.bar:SetPoint("BOTTOM",overlay)
	overlay.bar:SetPoint("LEFT",overlay)
	overlay.edge = overlay:CreateTexture(nil,"ARTWORK",nil)
	overlay.edge:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	overlay.edge:SetPoint("CENTER",overlay.bar,"RIGHT")
	overlay.edge:SetBlendMode("ADD")
	overlay.edge:SetSize(38,38) --Arbitrary value, I hope there isn't an AddOn that skins the bar and the glow doesnt look right with this size.
	bar.ParagonOverlay = overlay
end

-- [Reputation Frame] Change the Reputation Bars accordingly.
local function UpdateBar(self)
	if not self.Content or not self.Content.ReputationBar then return end
	if self.factionID and C_Reputation.IsFactionParagon(self.factionID) then
		if not self.paragon_hook and self.ShowParagonRewardsTooltip then
			hooksecurefunc(self,"ShowParagonRewardsTooltip",function(_self)
				PR:Tooltip(_self)
			end)
			self.paragon_hook = true
		end
		local currentValue,threshold,rewardQuestID,hasRewardPending = C_Reputation.GetFactionParagonInfo(self.factionID)
		self.count = floor(currentValue/threshold)-(hasRewardPending and 1 or 0)
		self.questID = rewardQuestID
		local r,g,b = PR.DB.value[1],PR.DB.value[2],PR.DB.value[3]
		local value = currentValue%threshold
		if hasRewardPending then
			self.Content.ParagonIcon.factionID = self.factionID
			self.Content.ParagonIcon:SetPoint("CENTER",self,"RIGHT",4,0)
			self.Content.ParagonIcon.Glow:SetShown(true)
			self.Content.ParagonIcon.Check:SetShown(true)
			self.Content.ParagonIcon:Show()
			-- If value is 0 we force it to 1 so we don't get 0 as result, math...
			local over = math.max(value,1)/threshold
			if not self.Content.ReputationBar.ParagonOverlay then PR:CreateBarOverlay(self.Content.ReputationBar) end
			self.Content.ReputationBar.ParagonOverlay:Show()
			self.Content.ReputationBar.ParagonOverlay.bar:SetWidth(self.Content.ReputationBar.ParagonOverlay:GetWidth()*over)
			self.Content.ReputationBar.ParagonOverlay.bar:SetVertexColor(r+.15,g+.15,b+.15)
			self.Content.ReputationBar.ParagonOverlay.edge:SetVertexColor(r+.25,g+.25,b+.25,(over > .05 and .75) or 0)
			value = value+threshold
		else
			self.Content.ParagonIcon:Hide()
			if self.Content.ReputationBar.ParagonOverlay then self.Content.ReputationBar.ParagonOverlay:Hide() end
		end
		self.Content.ReputationBar:SetMinMaxValues(0,threshold)
		self.Content.ReputationBar:SetValue(value)
		self.Content.ReputationBar:SetStatusBarColor(r,g,b)
		self.Content.ReputationBar.barProgressText = HIGHLIGHT_FONT_COLOR_CODE.." "..format(REPUTATION_PROGRESS_FORMAT,BreakUpLargeNumbers(value),BreakUpLargeNumbers(threshold))..FONT_COLOR_CODE_CLOSE
		if PR.DB.text == "PARAGON" then
			self.Content.ReputationBar.BarText:SetText(PR.L["PARAGON"])
			self.Content.ReputationBar.reputationStandingText = PR.L["PARAGON"]
		elseif PR.DB.text == "CURRENT"  then
			self.Content.ReputationBar.BarText:SetText(BreakUpLargeNumbers(value))
			self.Content.ReputationBar.reputationStandingText = BreakUpLargeNumbers(value)
		elseif PR.DB.text == "VALUE" then
			self.Content.ReputationBar.BarText:SetText(" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
			self.Content.ReputationBar.reputationStandingText = (" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
			self.Content.ReputationBar.barProgressText = nil
		elseif PR.DB.text == "DEFICIT" then
			if hasRewardPending then
				value = value-threshold
				self.Content.ReputationBar.BarText:SetText("+"..BreakUpLargeNumbers(value))
				self.Content.ReputationBar.reputationStandingText = "+"..BreakUpLargeNumbers(value)
			else
				value = threshold-value
				self.Content.ReputationBar.BarText:SetText(BreakUpLargeNumbers(value))
				self.Content.ReputationBar.reputationStandingText = BreakUpLargeNumbers(value)
			end
			self.Content.ReputationBar.barProgressText = nil
		end
	else
		self.count = nil
		self.questID = nil
		if self.Content.ReputationBar.ParagonOverlay then self.Content.ReputationBar.ParagonOverlay:Hide() end
	end
end

-- [Reputation Frame] Hook the Reputation Frame.
for _,children in ipairs({ReputationFrame.ScrollBox.ScrollTarget:GetChildren()}) do
	if children.Initialize then
		hooksecurefunc(children,"Initialize",function(self)
			UpdateBar(self)
		end)
	end
	UpdateBar(children)
end
hooksecurefunc(ReputationEntryMixin,"Initialize",function(self)
	UpdateBar(self)
end)
EmbeddedItemTooltip:HookScript("OnHide",function(self)
	if self.paragon_clamp then
		self:SetClampedToScreen(false)
		self.paragon_clamp = nil
	end
end)