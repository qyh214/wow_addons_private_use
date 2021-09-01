		-------------------------------------------------
		-- Paragon Reputation 1.37 by Fail US-Ragnaros --
		-------------------------------------------------

		  --[[	  Special thanks to Ammako for
				  helping me with the vars and
				  the options.						]]--

local ADDON_NAME,ParagonReputation = ...
local PR = ParagonReputation

-- [Reputation Watchbar] Color the Reputation Watchbar by the settings. (Thanks Hoalz)
hooksecurefunc(ReputationBarMixin,"Update",function(self)
	local _,_,_,_,_,factionID = GetWatchedFactionInfo()
	if factionID and C_Reputation.IsFactionParagon(factionID) then
		self:SetBarColor(unpack(PR.DB.value))
	end
end)

-- [ParagonTooltip] Setup the Paragon Tooltip accordingly.
hooksecurefunc("ReputationParagonFrame_SetupParagonTooltip",function(self)
	local _,_,rewardQuestID,hasRewardPending = C_Reputation.GetFactionParagonInfo(self.factionID)
	if hasRewardPending then
		local factionName = GetFactionInfoByID(self.factionID)
		local questIndex = C_QuestLog.GetLogIndexForQuestID(rewardQuestID)
		local description = GetQuestLogCompletionText(questIndex) or ""
		EmbeddedItemTooltip:SetText(PR.L["PARAGON"])
		EmbeddedItemTooltip:AddLine(description,HIGHLIGHT_FONT_COLOR.r,HIGHLIGHT_FONT_COLOR.g,HIGHLIGHT_FONT_COLOR.b,1)
		GameTooltip_AddQuestRewardsToTooltip(EmbeddedItemTooltip,rewardQuestID)
		EmbeddedItemTooltip:Show()
	else
		EmbeddedItemTooltip:Hide()
	end
end)

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
			local collected
			local name,link,quality,_,_,_,_,_,_,icon = GetItemInfo(data.itemID)
			if data.type == MOUNT then
				collected = select(11,C_MountJournal.GetMountInfoByID(data.mountID))
			elseif data.type == PET and link then
				collected = ParagonIsPetOwned(link)
			elseif data.type == TOY then
				collected = PlayerHasToy(data.itemID)
			elseif data.type == BINDING_HEADER_OTHER then
				collected = C_QuestLog.IsQuestFlaggedCompleted(data.questID)
			end
			if name then
				tooltip:AddLine(string.format("%s|T%d:0|t %s |cffffd000(|r|cffffffff%s|r|cffffd000)|r",collected and "|A:common-icon-checkmark:14:14|a " or "|A:common-icon-redx:14:14|a ",icon,name,data.type),ITEM_QUALITY_COLORS[quality].r,ITEM_QUALITY_COLORS[quality].g,ITEM_QUALITY_COLORS[quality].b)
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

-- [GameTooltip] Hook the Reputation Bars Scripts to show the Tooltip.
function ParagonReputation:HookScript()
	for n=1,NUM_FACTIONS_DISPLAYED do
		if _G["ReputationBar"..n] then
			_G["ReputationBar"..n]:HookScript("OnEnter",function(self)
				PR:Tooltip(self,"OnEnter")
			end)
			_G["ReputationBar"..n].OnEnter = _G["ReputationBar"..n]:GetScript("OnEnter")
			_G["ReputationBar"..n]:HookScript("OnLeave",function(self)
				PR:Tooltip(self,"OnLeave")
			end)
			_G["ReputationBar"..n].OnLeave = _G["ReputationBar"..n]:GetScript("OnLeave")
		end
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
	overlay:SetFrameLevel(3)
	overlay.bar = overlay:CreateTexture("ARTWORK",nil,nil,-1)
	overlay.bar:SetTexture((ElvUI and ElvUI[1].private and ElvUI[1].private.skins and ElvUI[1].private.skins.blizzard and ElvUI[1].private.skins.blizzard.enable and ElvUI[1].private.skins.blizzard.character and ElvUI[1].media and ElvUI[1].media.normTex) or "Interface\\TARGETINGFRAME\\UI-StatusBar") -- Checks for ElvUI and it's values in case they are skinning the Character Frame.
	overlay.bar:SetPoint("TOP",overlay)
	overlay.bar:SetPoint("BOTTOM",overlay)
	overlay.bar:SetPoint("LEFT",overlay)
	overlay.edge = overlay:CreateTexture("ARTWORK",nil,nil,-1)
	overlay.edge:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	overlay.edge:SetPoint("CENTER",overlay.bar,"RIGHT")
	overlay.edge:SetBlendMode("ADD")
	overlay.edge:SetSize(38,38) --Arbitrary value, I hope there isn't an AddOn that skins the bar and the glow doesnt look right with this size.
	factionBar.ParagonOverlay = overlay
end

-- [Reputation Frame] Change the Reputation Bars accordingly.
hooksecurefunc("ReputationFrame_Update",function()
	ReputationFrame.paragonFramesPool:ReleaseAll()
	local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
	for n=1,NUM_FACTIONS_DISPLAYED,1 do
		local factionIndex = factionOffset+n
		local factionRow = _G["ReputationBar"..n]
		local factionBar = _G["ReputationBar"..n.."ReputationBar"]
		local factionStanding = _G["ReputationBar"..n.."ReputationBarFactionStanding"]
		if factionIndex <= GetNumFactions() then
			local name,_,_,_,_,_,_,_,_,_,_,_,_,factionID = GetFactionInfo(factionIndex)
			if factionID and C_Reputation.IsFactionParagon(factionID) then
				local currentValue,threshold,rewardQuestID,hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
				factionRow.name = name
				factionRow.count = " |cffffffffx"..floor(currentValue/threshold)-(hasRewardPending and 1 or 0).."|r"
				factionRow.questID = rewardQuestID
				if currentValue then
					local r,g,b = unpack(PR.DB.value)
					local value = mod(currentValue,threshold)
					if hasRewardPending then
						local paragonFrame = ReputationFrame.paragonFramesPool:Acquire()
						paragonFrame.factionID = factionID
						paragonFrame:SetPoint("RIGHT",factionRow,11,0)
						paragonFrame.Glow:SetShown(true)
						paragonFrame.Check:SetShown(true)
						paragonFrame:Show()
						-- If value is 0 we force it to 1 so we don't get 0 as result, math...
						local over = ((value <= 0 and 1) or value)/threshold
						if not factionBar.ParagonOverlay then PR:CreateBarOverlay(factionBar) end
						factionBar.ParagonOverlay:Show()
						factionBar.ParagonOverlay.bar:SetWidth(factionBar.ParagonOverlay:GetWidth()*over)
						factionBar.ParagonOverlay.bar:SetVertexColor(r+.15,g+.15,b+.15)
						factionBar.ParagonOverlay.edge:SetVertexColor(r+.2,g+.2,b+.2,(over > .05 and .75) or 0)
						value = value+threshold
					else
						if factionBar.ParagonOverlay then factionBar.ParagonOverlay:Hide() end
					end
					factionBar:SetMinMaxValues(0,threshold)
					factionBar:SetValue(value)
					factionBar:SetStatusBarColor(r,g,b)
					factionRow.rolloverText = HIGHLIGHT_FONT_COLOR_CODE.." "..format(REPUTATION_PROGRESS_FORMAT,BreakUpLargeNumbers(value),BreakUpLargeNumbers(threshold))..FONT_COLOR_CODE_CLOSE
					if PR.DB.text == "PARAGON" then
						factionStanding:SetText(PR.L["PARAGON"])
						factionRow.standingText = PR.L["PARAGON"]
					elseif PR.DB.text == "CURRENT"  then
						factionStanding:SetText(BreakUpLargeNumbers(value))
						factionRow.standingText = BreakUpLargeNumbers(value)
					elseif PR.DB.text == "VALUE" then
						factionStanding:SetText(" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
						factionRow.standingText = (" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
						factionRow.rolloverText = nil					
					elseif PR.DB.text == "DEFICIT" then
						if hasRewardPending then
							value = value-threshold
							factionStanding:SetText("+"..BreakUpLargeNumbers(value))
							factionRow.standingText = "+"..BreakUpLargeNumbers(value)
						else
							value = threshold-value
							factionStanding:SetText(BreakUpLargeNumbers(value))
							factionRow.standingText = BreakUpLargeNumbers(value)
						end
						factionRow.rolloverText = nil
					end
				end
			else
				factionRow.name = nil
				factionRow.count = nil
				factionRow.questID = nil
				if factionBar.ParagonOverlay then factionBar.ParagonOverlay:Hide() end
			end
			if factionRow:IsMouseOver() then
				if GameTooltip:GetOwner() == factionRow then GameTooltip:Hide() end
				factionRow:OnEnter()
			end
		else
			factionRow:Hide()
		end
	end
end)