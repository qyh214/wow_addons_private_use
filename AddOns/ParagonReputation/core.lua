		-------------------------------------------------
		-- Paragon Reputation 1.45 by Fail US-Ragnaros --
		-------------------------------------------------

		  --[[	  Special thanks to Ammako for
				  helping me with the vars and
				  the options.						]]--

local ADDON_NAME,ParagonReputation = ...
local PR = ParagonReputation

--TODO FIX FOR 10.0
--[[ [Reputation Watchbar] Color the Reputation Watchbar by the settings. (Thanks Hoalz)
hooksecurefunc(ReputationBarMixin,"Update",function(self)
	local _,_,_,_,_,factionID = GetWatchedFactionInfo()
	if factionID and C_Reputation.IsFactionParagon(factionID) then
		self:SetBarColor(unpack(PR.DB.value))
	end
end)]]

-- [Pet Rewards] Check if a Pet Reward is already owned.
local ParagonPetSearchTooltip = CreateFrame("GameTooltip","ParagonPetSearchTooltip",nil,"GameTooltipTemplate")
local ParagonIsPetOwned = function(link)
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
			local name,link,quality,_,_,_,_,_,_,icon = GetItemInfo(data.itemID)
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
function ParagonReputation:Tooltip(self,event)
	if not self.questID or not PR.PARAGON_DATA[self.questID] then return end
	if event == "OnEnter" then
		local name,_,quality = GetItemInfo(PR.PARAGON_DATA[self.questID].cache)
		if name then
			GameTooltip:SetOwner(self,"ANCHOR_NONE")
			GameTooltip:SetPoint("TOPLEFT",self,"BOTTOMRIGHT")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(self.name)
			GameTooltip:AddLine(name..self.count,ITEM_QUALITY_COLORS[quality].r,ITEM_QUALITY_COLORS[quality].g,ITEM_QUALITY_COLORS[quality].b)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(GUILD_TAB_REWARDS)
			AddParagonRewardsToTooltip(self,GameTooltip,PR.PARAGON_DATA[self.questID].rewards)
			GameTooltip:Show()
		else
			ParagonItemInfoReceivedQueue[PR.PARAGON_DATA[self.questID].cache] = self
		end
	elseif event == "OnLeave" then
		GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
		GameTooltip:Hide()
	end
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
		local name = GetFactionInfoByID(PR.PARAGON_DATA[arg1].factionID)
		local text = GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(arg1))
		if ACTIVE_TOAST then
			WAITING_TOAST[#WAITING_TOAST+1] = {name,text} --Toast is already active, put this info on the line.
		else
			PR:ShowToast(name,text)
		end
	elseif event == "GET_ITEM_INFO_RECEIVED" and arg2 and ParagonItemInfoReceivedQueue[arg1] then
		if ParagonItemInfoReceivedQueue[arg1]:IsMouseOver() and GameTooltip:GetOwner() == ParagonItemInfoReceivedQueue[arg1] then
			PR:Tooltip(ParagonItemInfoReceivedQueue[arg1],"OnEnter")
		end
		ParagonItemInfoReceivedQueue[arg1] = nil
	end
end)

-- [Paragon Overlay] Create the Overlay for the Reputation Bar.
function ParagonReputation:CreateBarOverlay(factionBar)
	local overlay = CreateFrame("FRAME",nil,factionBar)
	overlay:SetAllPoints(factionBar)
	overlay:SetFrameLevel(factionBar:GetFrameLevel())
	overlay.bar = overlay:CreateTexture(nil,"ARTWORK",nil)
	local texture = factionBar:GetStatusBarTexture():GetTexture()
	factionBar.LeftTexture:SetDrawLayer("ARTWORK",1)
	factionBar.RightTexture:SetDrawLayer("ARTWORK",1)
	overlay.bar:SetTexture(texture == 136570 and "Interface\\TARGETINGFRAME\\UI-StatusBar" or texture)
	overlay.bar:SetPoint("TOP",overlay)
	overlay.bar:SetPoint("BOTTOM",overlay)
	overlay.bar:SetPoint("LEFT",overlay)
	overlay.edge = overlay:CreateTexture(nil,"ARTWORK",nil)
	overlay.edge:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	overlay.edge:SetPoint("CENTER",overlay.bar,"RIGHT")
	overlay.edge:SetBlendMode("ADD")
	overlay.edge:SetSize(38,38) --Arbitrary value, I hope there isn't an AddOn that skins the bar and the glow doesnt look right with this size.
	factionBar.ParagonOverlay = overlay
end

-- [Reputation Frame] Change the Reputation Bars accordingly.
hooksecurefunc("ReputationFrame_InitReputationRow",function(factionRow)
	factionRow.Container.Paragon:Hide()
	if not factionRow.ParagonReputationHook then
		factionRow:HookScript("OnEnter",function(self)
			PR:Tooltip(self,"OnEnter")
		end)
		factionRow:HookScript("OnLeave",function(self)
			PR:Tooltip(self,"OnLeave")
		end)
		factionRow.ParagonReputationHook = true
	end
	if factionRow.factionID and C_Reputation.IsFactionParagon(factionRow.factionID) then
		local currentValue,threshold,rewardQuestID,hasRewardPending = C_Reputation.GetFactionParagonInfo(factionRow.factionID)
		factionRow.name = factionRow.Container.Name:GetText()
		factionRow.count = " |cffffffffx"..floor(currentValue/threshold)-(hasRewardPending and 1 or 0).."|r"
		factionRow.questID = rewardQuestID
		local r,g,b = unpack(PR.DB.value)
		local value = currentValue%threshold
		if hasRewardPending then
			factionRow.Container.Paragon.factionID = factionRow.factionID
			factionRow.Container.Paragon:SetPoint("RIGHT",factionRow)
			factionRow.Container.Paragon.Glow:SetShown(true)
			factionRow.Container.Paragon.Check:SetShown(true)
			factionRow.Container.Paragon:Show()
			-- If value is 0 we force it to 1 so we don't get 0 as result, math...
			local over = math.max(value,1)/threshold
			if not factionRow.Container.ReputationBar.ParagonOverlay then PR:CreateBarOverlay(factionRow.Container.ReputationBar) end
			factionRow.Container.ReputationBar.ParagonOverlay:Show()
			factionRow.Container.ReputationBar.ParagonOverlay.bar:SetWidth(factionRow.Container.ReputationBar.ParagonOverlay:GetWidth()*over)
			factionRow.Container.ReputationBar.ParagonOverlay.bar:SetVertexColor(r+.15,g+.15,b+.15)
			factionRow.Container.ReputationBar.ParagonOverlay.edge:SetVertexColor(r+.25,g+.25,b+.25,(over > .05 and .75) or 0)
			value = value+threshold
		else
			if factionRow.Container.ReputationBar.ParagonOverlay then factionRow.Container.ReputationBar.ParagonOverlay:Hide() end
		end
		factionRow.Container.ReputationBar:SetMinMaxValues(0,threshold)
		factionRow.Container.ReputationBar:SetValue(value)
		factionRow.Container.ReputationBar:SetStatusBarColor(r,g,b)
		factionRow.rolloverText = HIGHLIGHT_FONT_COLOR_CODE.." "..format(REPUTATION_PROGRESS_FORMAT,BreakUpLargeNumbers(value),BreakUpLargeNumbers(threshold))..FONT_COLOR_CODE_CLOSE
		if PR.DB.text == "PARAGON" then
			factionRow.Container.ReputationBar.FactionStanding:SetText(PR.L["PARAGON"])
			factionRow.standingText = PR.L["PARAGON"]
		elseif PR.DB.text == "CURRENT"  then
			factionRow.Container.ReputationBar.FactionStanding:SetText(BreakUpLargeNumbers(value))
			factionRow.standingText = BreakUpLargeNumbers(value)
		elseif PR.DB.text == "VALUE" then
			factionRow.Container.ReputationBar.FactionStanding:SetText(" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
			factionRow.standingText = (" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
			factionRow.rolloverText = nil
		elseif PR.DB.text == "DEFICIT" then
			if hasRewardPending then
				value = value-threshold
				factionRow.Container.ReputationBar.FactionStanding:SetText("+"..BreakUpLargeNumbers(value))
				factionRow.standingText = "+"..BreakUpLargeNumbers(value)
			else
				value = threshold-value
				factionRow.Container.ReputationBar.FactionStanding:SetText(BreakUpLargeNumbers(value))
				factionRow.standingText = BreakUpLargeNumbers(value)
			end
			factionRow.rolloverText = nil
		end
	else
		factionRow.name = nil
		factionRow.count = nil
		factionRow.questID = nil
		if factionRow.Container.ReputationBar.ParagonOverlay then factionRow.Container.ReputationBar.ParagonOverlay:Hide() end
	end
end)