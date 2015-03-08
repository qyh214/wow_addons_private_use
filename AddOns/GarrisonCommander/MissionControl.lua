local me, ns = ...
local addon=ns.addon --#addon
local L=ns.L
local D=ns.D
local C=ns.C
local AceGUI=ns.AceGUI
local _G=_G
local new, del, copy =ns.new,ns.del,ns.copy
-- Courtesy of Motig
-- Concept and interface reused with permission
-- Mission building rewritten from scratch
--local GMC_G = {}
local factory=addon:GetFactory()
--GMC_G.frame = CreateFrame('FRAME')
local aMissions={}
local dbcache
local cache
local db
local GMC
local GMF=GarrisonMissionFrame
local G=C_Garrison
local GMCUsedFollowers={}
local wipe=wipe
local pairs=pairs
local tinsert=tinsert
local xprint=ns.xprint
--[===[@debug@
_G.GAC=addon
if LibDebug then LibDebug() end
--@end-debug@]===]
local dbg
function addon:GMCBusy(followerID)
	return GMCUsedFollowers[followerID]
end
function addon:GMCCreateMissionList(workList)
	--First get rid of unwanted rewards and missions that are too long
	local settings=self.privatedb.profile.missionControl
	local ar=settings.allowedRewards
	wipe(workList)
	for _,missionID in self:GetMissionIterator() do
		local discarded=false
		repeat
			xprint("|cffff0000",'Examing',self:GetMissionData(missionID,"name"),self:GetMissionData(missionID,"class"),"|r")
			local durationSeconds=self:GetMissionData(missionID,'durationSeconds')
			if (durationSeconds > settings.maxDuration * 3600 or durationSeconds <  settings.minDuration * 3600) then
				xprint(missionID,"discarded due to len",durationSeconds /3600)
				break
			end -- Mission too long, out of here
			if (self:GetMissionData(missionID,'isRare') and settings.skipRare) then
				xprint(missionID,"discarded due to rarity")
				break
			end
			for k,v in pairs(ar) do
				if (not v) then
					if (self:GetMissionData(missionID,"class")==k) then -- we have a forbidden reward
						xprint(missionID,"discarded due to class == ", k)
						discarded=true
						break
					end
				end
			end
			if (not discarded) then
				tinsert(workList,missionID)
			end
		until true
	end
	local parties=self:GetParty()
	local function msort(i1,i2)
		for i=1,#GMC.settings.itemPrio do
			local criterium=GMC.settings.itemPrio[i]
			if (criterium) then
				if addon:GetMissionData(i1,criterium) ~= addon:GetMissionData(i2,criterium) then
					return addon:GetMissionData(i1,criterium) > addon:GetMissionData(i2,criterium)
				end
			end
		end
		if (parties[i1].perc and parties[i2].perc) then
			return parties[i1].perc > parties[i2].perc
		end
		return addon:GetMissionData(i1,'level') > addon:GetMissionData(i2,'level')
	end
	table.sort(workList,msort)
end
--- This routine can be called both as coroutin and as a standard one
-- In standard version, delay between group building and submitting is done via a self schedule
--@param #integer missionID Optional, to run a single mission
--@param #bool start Optional, tells that follower already are on mission and that we need just to start it
function addon:GMCRunMission(missionID,start)
	xprint("Asked to start mission",missionID)
	if (start) then
		G.StartMission(missionID)
		PlaySound("UI_Garrison_CommandTable_MissionStart")
		return
	end
	for i=1,#GMC.ml.Parties do
		local party=GMC.ml.Parties[i]
		xprint("Checking",party.missionID)
		if (missionID and party.missionID==missionID or not missionID) then
			GMC.ml.widget:RemoveChild(party.missionID)
			GMC.ml.widget:DoLayout()
			if (party.full) then
				for j=1,#party.members do
					G.AddFollowerToMission(party.missionID, party.members[j])
				end
				if (not missionID) then
					coroutine.yield(true)
					G.StartMission(party.missionID)
					PlaySound("UI_Garrison_CommandTable_MissionStart")
					coroutine.yield(true)
				else
					self:ScheduleTimer("GMCRunMission",0.25,party.missionID,true)
				end
			end
		end
	end
end
do
	local timeElapsed=0
	local currentMission=0
	local x=0
	function addon:GMCCalculateMissions(this,elapsed)
		db.news.MissionControl=true
		timeElapsed = timeElapsed + elapsed
		if (#aMissions == 0 ) then
			if timeElapsed >= 1 then
				currentMission=0
				x=0
				self:Unhook(this,"OnUpdate")
				GMC.ml.widget:SetTitle(READY)
				GMC.ml.widget:SetTitleColor(C.Green())
				wipe(GMCUsedFollowers)
				this:Enable()
				if (#GMC.ml.Parties>0) then
					GMC.runButton:Enable()
				end
			end
			return
		end
		if (timeElapsed >=0.05) then
			currentMission=currentMission+1
			if (currentMission > #aMissions) then
				wipe(aMissions)
				currentMission=0
				x=0
				timeElapsed=0.5
			else
				local missionID=aMissions[currentMission]
				GMC.ml.widget:SetFormattedTitle("Processing mission %d of %d (%s)",currentMission,#aMissions,G.GetMissionName(missionID))
				local class=self:GetMissionData(missionID,"class")
				local checkprio=class
				if checkprio=="itemLevel" then class="equip" end
				if checkprio=="followerUpgrade" then class= "followerEquip" end
				xprint(C("Processing ","Red"),missionID,addon:GetMissionData(missionID,"name"))
				local minimumChance=0
				if (GMC.settings.useOneChance) then
					minimumChance=tonumber(GMC.settings.minimumChance) or 100
				else
					minimumChance=tonumber(GMC.settings.rewardChance[checkprio]) or 100
				end
				local party={members={},perc=0}
				self:MCMatchMaker(missionID,party,false,false)
				xprint ("                           Requested",class,";",minimumChance,"Mission",party.perc,party.full)
				if ( party.full and party.perc >= minimumChance) then
					xprint("                           Mission accepted")
					local mb=AceGUI:Create("GMCMissionButton")
					for i=1,#party.members do
						GMCUsedFollowers[party.members[i]]=true
					end
					party.missionID=missionID
					tinsert(GMC.ml.Parties,party)
					GMC.ml.widget:PushChild(mb,missionID)
					mb:SetFullWidth(true)
					mb:SetMission(self:GetMissionData(missionID),party)
					mb:SetCallback("OnClick",function(...)
						addon:GMCRunMission(missionID)
						GMC.ml.widget:RemoveChild(missionID)
					end
					)
				end
				timeElapsed=0
			end
		end
	end
end

function addon:GMC_OnClick_Run(this,button)
	this:Disable()
	do
	local elapsed=0
	local co=coroutine.wrap(self.GMCRunMission)
	self:RawHookScript(GMC.runButton,'OnUpdate',function(this,ts)
		elapsed=elapsed+ts
		if (elapsed>0.25) then
			elapsed=0
			local rc=co(self)
			if (not rc) then
				self:Unhook(GMC.runButton,'OnUpdate')
			end
		end
	end
	)
	end
end
function addon:GMC_OnClick_Start(this,button)
	xprint(C("-------------------------------------------------","Yellow"))
	GMC.ml.widget:ClearChildren()
	if (self:GetTotFollowers(AVAILABLE) == 0) then
		GMC.ml.widget:SetTitle("All followers are busy")
		return
	end
	this:Disable()
	addon:GMCCreateMissionList(aMissions)
	wipe(GMCUsedFollowers)
	wipe(GMC.ml.Parties)
	self:RefreshFollowerStatus()
	if (#aMissions>0) then
		GMC.ml.widget:SetFormattedTitle(L["Processing mission %d of %d"],1,#aMissions)
	else
		GMC.ml.widget:SetTitle("No mission matches your criteria")
		GMC.ml.widget:SetTitleColor(C.Red())
	end
	self:RawHookScript(GMC.startButton,'OnUpdate',"GMCCalculateMissions")

end
local chestTexture
function addon:GMCBuildPanel(bigscreen)
	db=self.db.global
	dbcache=self.privatedb.profile
	cache=self.private.profile
	chestTexture='GarrMission-'..UnitFactionGroup('player').. 'Chest'
	GMC = CreateFrame('FRAME', 'GMCOptions', GMF)
	GMC.settings=dbcache.missionControl
	GMC:SetPoint('CENTER')
	GMC:SetSize(GMF:GetWidth(), GMF:GetHeight())
	GMC:Hide()
	local chance=self:GMCBuildChance()
	local duration=self:GMCBuildDuration()
	local rewards=self:GMCBuildRewards()
	local priorities=self:GMCBuildPriorities()
	local list=self:GMCBuildMissionList()
	duration:SetPoint("TOPLEFT",0,-50)
	chance:SetPoint("TOPLEFT",duration,"TOPRIGHT",bigscreen and 50 or 10,0)
	priorities:SetPoint("TOPLEFT",duration,"BOTTOMLEFT",25,-40)
	rewards:SetPoint("TOPLEFT",priorities,"TOPRIGHT",bigscreen and 50 or 15,0)
	list:SetPoint("TOPLEFT",chance,"TOPRIGHT",10,-30)
	list:SetPoint("BOTTOMRIGHT",GMF,"BOTTOMRIGHT",-25,25)
	GMC.startButton = CreateFrame('BUTTON',nil,  list.frame, 'GameMenuButtonTemplate')
	GMC.startButton:SetText('Calculate')
	GMC.startButton:SetWidth(148)
	GMC.startButton:SetPoint('TOPLEFT',15,25)
	GMC.startButton:SetScript('OnClick', function(this,button) self:GMC_OnClick_Start(this,button) end)
	GMC.startButton:SetScript('OnEnter', function() GameTooltip:SetOwner(GMC.startButton, 'ANCHOR_TOPRIGHT') GameTooltip:AddLine('Assign your followers to missions.') GameTooltip:Show() end)
	GMC.startButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
	GMC.runButton = CreateFrame('BUTTON', nil,list.frame, 'GameMenuButtonTemplate')
	GMC.runButton:SetText('Send all mission at once')
	GMC.runButton:SetScript('OnEnter', function()
		GameTooltip:SetOwner(GMC.runButton, 'ANCHOR_TOPRIGHT')
		GameTooltip:AddLine('Submit all yopur mission at once. No question asked.')
		GameTooltip:AddLine('You can also send mission one by one clicking on each button.')
		GameTooltip:Show()
	end)
	GMC.runButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
	GMC.runButton:SetWidth(148)
	GMC.runButton:SetPoint('TOPRIGHT',-15,25)
	GMC.runButton:SetScript('OnClick',function(this,button) self:GMC_OnClick_Run(this,button) end)
	GMC.runButton:Disable()
	GMC.skipRare=factory:Checkbox(GMC,GMC.settings.skipRare,L["Ignore rare missions"])
	GMC.skipRare:SetPoint("TOPLEFT",priorities,"BOTTOMLEFT",0,-10)
	GMC.skipRare:SetScript("OnClick",function(this)
		GMC.settings.skipRare=this:GetChecked()
		addon:GMC_OnClick_Start(GMC.startButton,"LeftUp")
	end)
	local warning=GMC:CreateFontString(nil,"ARTWORK","CombatTextFont")
	warning:SetText(L["Epic followers are NEVER sent alone on xp only missions"])
	warning:SetPoint("TOPLEFT",GMC,"TOPLEFT",0,-25)
	warning:SetPoint("TOPRIGHT",GMC,"TOPRIGHT",0,-25)
	warning:SetJustifyH("CENTER")
	warning:SetTextColor(C.Orange())
	GMC.Credits=GMC:CreateFontString(nil,"ARTWORK","DestinyFontLarge")
	GMC.Credits:SetWidth(0)
	GMC.Credits:SetFormattedText(C("Original concept and interface by %s",'Yellow'),C("Motig","Red") )
	GMC.Credits:SetPoint("BOTTOMLEFT",25,25)
	return GMC
end
function addon:GMCRewardRefresh()
	local single=GMC.settings.useOneChance
	local ref
	for i=1,#GMC.ignoreFrames do
		local frame=GMC.ignoreFrames[i]
		local allowed=GMC.settings.allowedRewards[frame.key]
		frame.icon:SetDesaturated(not allowed)
		local a1,o,a2,x,y=frame:GetPoint(1)
		if (not single) then
			frame.chest:Show()
			frame.slider:Show()
			frame:SetPoint(a1,o,a2,0,y)
		else
			frame.chest:Hide()
			frame.slider:Hide()
			frame:SetPoint(a1,o,a2,100,y)
		end
		ref=frame
	end
	if (single) then
		GMC.itf2:SetPoint('TOPLEFT',ref,'BOTTOMLEFT', -110, -15)
		GMC.cp:SetDesaturated(false)
		GMC.ct:SetTextColor(C.Green())
	else
		GMC.itf2:SetPoint('TOPLEFT',ref,'BOTTOMLEFT', 10, -15)
		GMC.cp:SetDesaturated(true)
		GMC.ct:SetTextColor(C.Silver())
	end
end
function addon:GMCBuildChance()
	_G['GMC']=GMC
	--Chance
	GMC.cf = CreateFrame('FRAME', nil, GMC)
	GMC.cf:SetSize(256, 150)

	GMC.cp = GMC.cf:CreateTexture(nil, 'BACKGROUND')
	GMC.cp:SetTexture('Interface\\Garrison\\GarrisonMissionUI2.blp')
	GMC.cp:SetAtlas(chestTexture)
	GMC.cp:SetSize((209-(209*0.25))*0.60, (155-(155*0.25))*0.60)
	GMC.cp:SetPoint('CENTER', 0, 20)

	GMC.cc = GMC.cf:CreateFontString()
	GMC.cc:SetFontObject('GameFontNormalHuge')
	GMC.cc:SetText('Success Chance')
	GMC.cc:SetPoint('TOP', 0, 0)
	GMC.cc:SetTextColor(1, 1, 1)

	GMC.ct = GMC.cf:CreateFontString()
	GMC.ct:SetFontObject('ZoneTextFont')
	GMC.ct:SetFormattedText('%d%%',GMC.settings.minimumChance)
	GMC.ct:SetPoint('TOP', 0, -40)
	GMC.ct:SetTextColor(0, 1, 0)

	GMC.cs = factory:Slider(GMC.cf,0,100,GMC.settings.minimumChance,'Minumum chance to start a mission')
	GMC.cs:SetPoint('BOTTOM', 10, 0)
	GMC.cs:SetScript('OnValueChanged', function(self, value)
			local value = math.floor(value)
			GMC.ct:SetText(value..'%')
			GMC.settings.minimumChance = value
	end)
	GMC.cs:SetValue(GMC.settings.minimumChance)
	GMC.ck=factory:Checkbox(GMC.cs,GMC.settings.useOneChance,"Use this percentage for all missions")
	GMC.ck.tooltip="Unchecking this will allow you to set specific success chance for each reward type"
	GMC.ck:SetPoint("TOPLEFT",GMC.cs,"BOTTOMLEFT",-60,-10)
	GMC.ck:SetScript("OnClick",function(this)
		GMC.settings.useOneChance=this:GetChecked()
		addon:GMCRewardRefresh()
	end)
	return GMC.cf
end
local function timeslidechange(this,value)
	local value = math.floor(value)
	if (this.max) then
		GMC.settings.maxDuration = max(value,GMC.settings.minDuration)
		if (value~=GMC.settings.maxDuration) then this:SetValue(GMC.settings.maxDuration) end
	else
		GMC.settings.minDuration = min(value,GMC.settings.maxDuration)
		if (value~=GMC.settings.minDuration) then this:SetValue(GMC.settings.minDuration) end
	end
	local c = 1-(value*(1/24))
	if c < 0.3 then c = 0.3 end
	GMC.mt:SetTextColor(1, c, c)
	GMC.mt:SetFormattedText("%d-%dh",GMC.settings.minDuration,GMC.settings.maxDuration)
end
function addon:GMCBuildDuration()
	-- Duration
	GMC.tf = CreateFrame('FRAME', nil, GMC)
	GMC.tf:SetSize(256, 180)
	GMC.tf:SetPoint('LEFT', 80, 120)

	GMC.bg = GMC.tf:CreateTexture(nil, 'BACKGROUND')
	GMC.bg:SetTexture('Interface\\Timer\\Challenges-Logo.blp')
	GMC.bg:SetSize(100, 100)
	GMC.bg:SetPoint('CENTER', 0, 0)
	GMC.bg:SetBlendMode('ADD')

	GMC.tcf = GMC.tf:CreateTexture(nil, 'BACKGROUND')
	--bb:SetTexture('Interface\\Timer\\Challenges-Logo.blp')
	--bb:SetTexture('dungeons\\textures\\devices\\mm_clockface_01.blp')
	GMC.tcf:SetTexture('World\\Dungeon\\Challenge\\clockRunes.blp')
	GMC.tcf:SetSize(110, 110)
	GMC.tcf:SetPoint('CENTER', 0, 0)
	GMC.tcf:SetBlendMode('ADD')

	GMC.mdt = GMC.tf:CreateFontString()
	GMC.mdt:SetFontObject('GameFontNormalHuge')
	GMC.mdt:SetText('Mission Duration')
	GMC.mdt:SetPoint('TOP', 0, 0)
	GMC.mdt:SetTextColor(1, 1, 1)

	GMC.mt = GMC.tf:CreateFontString()
	GMC.mt:SetFontObject('ZoneTextFont')
	GMC.mt:SetFormattedText('%d-%dh',GMC.settings.minDuration,GMC.settings.maxDuration)
	GMC.mt:SetPoint('CENTER', 0, 0)
	GMC.mt:SetTextColor(1, 1, 1)

	GMC.ms1 = factory:Slider(GMC.tf,0,24,GMC.settings.minDuration,'Minimum mission duration.')
	GMC.ms2 = factory:Slider(GMC.tf,0,24,GMC.settings.maxDuration,'Maximum mission duration.')
	GMC.ms1:SetPoint('BOTTOM', 0, 0)
	GMC.ms2:SetPoint('TOP', GMC.ms1,"BOTTOM",0, -25)
	GMC.ms2.max=true
	GMC.ms1:SetScript('OnValueChanged', timeslidechange)
	GMC.ms2:SetScript('OnValueChanged', timeslidechange)
	timeslidechange(GMC.ms1,GMC.settings.minDuration)
	timeslidechange(GMC.ms2,GMC.settings.maxDuration)
	return GMC.tf
end
function addon:GMCBuildRewards()
	--Allowed rewards
	GMC.aif = CreateFrame('FRAME', nil, GMC)
	GMC.aif:SetPoint('CENTER', 0, 120)

	GMC.itf = GMC.aif:CreateFontString()
	GMC.itf:SetFontObject('GameFontNormalHuge')
	GMC.itf:SetText('Allowed Rewards')
	GMC.itf:SetPoint('TOP', 0, -10)
	GMC.itf:SetTextColor(1, 1, 1)

	GMC.itf2 = GMC.aif:CreateFontString()
	GMC.itf2:SetFontObject('GameFontHighlight')
	GMC.itf2:SetText('Click to enable/disable a reward.')
	GMC.itf2:SetTextColor(1, 1, 1)


	local t = {
		{t = 'Enable/Disable money rewards.', i = 'Interface\\Icons\\inv_misc_coin_01', key = 'gold'},
		{t = 'Enable/Disable other currency awards. (Resources/Seals)', i= 'Interface\\Icons\\inv_garrison_resource', key = 'resources'},
		{t = 'Enable/Disable Follower XP Bonus rewards.', i = 'Interface\\Icons\\XPBonus_Icon', key = 'xp'},
		{t = 'Enable/Disable follower equip enhancement.', i = 'Interface\\ICONS\\Garrison_ArmorUpgrade', key = 'followerEquip'},
		{t = 'Enable/Disable item tokens.', i = "Interface\\ICONS\\INV_Bracer_Cloth_Reputation_C_01", key = 'equip'}
	}
	local scale=1.1
	GMC.ignoreFrames = {}
	local ref
	local h=37 -- itemButtonTemplate standard size
	local gap=5
	-- converting from old data
	local ar=GMC.settings.allowedRewards
	local rc=GMC.settings.rewardChance
	if ar.xpBonus then ar.xp=true end
	ar.xpBonus=nil
	if ar.followerUpgrade then ar.followerEquip=true end
	ar.followerUpgrade=nil
	if ar.itemLevel then ar.equip=true end
	ar.itemLevel=nil
	if rc.xpBonus then rc.xp=rc.xpbonus or 100 end
	rc.xpBonus=nil
	if rc.followerUpgrade then rc.followerEquip=rc.followerUpgrade or 100 end
	rc.followerUpgrade=nil
	if rc.itemLevel then rc.equip=rc.itemLevel or 100 end
	rc.itemLevel=nil

	for i = 1, #t do
			local frame = CreateFrame('BUTTON', nil, GMC.aif, 'ItemButtonTemplate')
			frame:SetScale(scale)
			frame:SetPoint('TOPLEFT', 0,(i) * (-h -gap) * scale)
			frame.icon:SetTexture(t[i].i)
			frame.key=t[i].key
			frame.tooltip=t[i].t
			local allowed=GMC.settings.allowedRewards[frame.key]
			local chance=GMC.settings.rewardChance[frame.key]
			-- Need to resave them asap in order to populate the array for future scans
			GMC.settings.allowedRewards[frame.key]=allowed
			GMC.settings.rewardChance[frame.key]=chance
			frame.slider=factory:Slider(frame,0,100,chance or 100,chance or 100)
			frame.slider:SetWidth(128)
			frame.slider:SetPoint('BOTTOMLEFT',60,0)
			frame.slider.Text:SetFontObject('NumberFont_Outline_Med')
			frame.slider.Text:SetTextColor(C.Green())
			frame.slider.isPercent=true
			frame.slider:SetScript("OnValueChanged",function(this,value)
				GMC.settings.rewardChance[this:GetParent().key]=this:OnValueChanged(value)
				end
			)
			frame.chest = frame:CreateTexture(nil, 'BACKGROUND')
			frame.chest:SetTexture('Interface\\Garrison\\GarrisonMissionUI2.blp')
			frame.chest:SetAtlas(chestTexture)
			frame.chest:SetSize((209-(209*0.25))*0.30, (155-(155*0.25)) * 0.30)
			frame.chest:SetPoint('CENTER',frame.slider, 0, 25)
			frame:SetScript('OnClick', function(this)
				local allowed=  this.icon:IsDesaturated() -- ID it was desaturated, I want it allowed, now
				GMC.settings.allowedRewards[this.key] = allowed
				addon:GMCRewardRefresh()
			end)
			frame:SetScript('OnEnter', function(this)
				GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT')
				GameTooltip:AddLine(this.tooltip);
				GameTooltip:Show()
			end)

			frame:SetScript('OnLeave', function() GameTooltip:Hide() end)
			GMC.ignoreFrames[i] = frame
			ref=frame
	end
	self:GMCRewardRefresh()
	GMC.aif:SetSize(256, (scale*h+gap) * #t)
	GMC.itf2:SetPoint('TOPLEFT',ref,'BOTTOMLEFT', 5, -15)
	return GMC.aif
end

local addPriorityRule,prioRefresh,removePriorityRule,prioMenu,prioTitles,prioCheck,prioVoices
do
-- 1 = item, 2 = folitem, 3 = exp, 4 = money, 5 = resource
	prioTitles={
		itemLevel="Equipment",
		followerUpgrade="Followr Upgrade",
		xp="Xp gain",
		gold="Gold Reward",
		resources="Resource Rewards"
	}
	prioVoices=0
	for _ in pairs(prioTitles) do prioVoices=prioVoices+1 end
	prioMenu={}

	---@function [parent=#GMC] prioRefresh
	function prioRefresh()
		for i=1,prioVoices do
			local group=GMC.prioFrames[i]
			local code=GMC.settings.itemPrio[i]
			if (not code) then
				group.text:Hide()
				group.xbutton:Hide()
				group.nr:Hide()
			else
				group.text:Show()
				group.text:SetText(prioTitles[code])
				group.xbutton:Show()
				group.nr:Show()
			end
		end
		GMC.abutton:Hide()
		for i=1,prioVoices do
			local group=GMC.prioFrames[i]
			if (not group.text:IsShown()) then
				group.nr:Show()
				GMC.abutton:SetPoint("TOPLEFT",group.text)
				GMC.abutton:Show()
				break
			end
		end
	end
	---@function [parent=#GMC] addPriorityRule
	function addPriorityRule(this,key)
		tinsert(GMC.settings.itemPrio,key)
		prioRefresh()
	end
	---@function [parent=#GMC] removePriorityRule
	function removePriorityRule(index)
		tremove(GMC.settings.itemPrio,index)
		prioRefresh()
	end

end
_G.XPRIO=prioRefresh
function addon:GMCBuildPriorities()
	--Prio
	GMC.pf = CreateFrame('FRAME', nil, GMC)
	GMC.pf:SetSize(256, 240)

	GMC.pft = GMC.pf:CreateFontString()
	GMC.pft:SetFontObject('GameFontNormalHuge')
	GMC.pft:SetText('Item Priority')
	GMC.pft:SetPoint('TOP', 0, -10)
	GMC.pft:SetTextColor(1, 1, 1)

	GMC.pft2 = GMC.pf:CreateFontString()
	GMC.pft2:SetFontObject('GameFontNormal')
	GMC.pft2:SetText('Prioritize missions with certain a reward.')
	GMC.pft2:SetPoint('BOTTOM', 0, 16)
	GMC.pft2:SetTextColor(1, 1, 1)
	GMC.pmf = CreateFrame("FRAME", "GMC_PRIO_MENU", GMC.pf, "UIDropDownMenuTemplate")


	GMC.prioFrames = {}
	GMC.prioFrames.selected = 0
	for i = 1, prioVoices do
		GMC.prioFrames[i] = {}
		local this = GMC.prioFrames[i]
		this.f = CreateFrame('FRAME', nil, GMC.pf)
		this.f:SetSize(255, 32)
		this.f:SetPoint('TOP', 0, -38-((i-1)*32))

		this.nr = this.f:CreateFontString()
		this.nr:SetFontObject('GameFontNormalHuge')
		this.nr:SetText(i..'.')
		this.nr:SetPoint('LEFT', 8, 0)
		this.nr:SetTextColor(1, 1, 1)

		this.text = this.f:CreateFontString()
		this.text:SetFontObject('GameFontNormalLarge')
		this.text:SetText('Def')
		this.text:SetPoint('LEFT', 32, 0)
		--this.text:SetTextColor(1, 1, 0)
		this.text:SetJustifyH('LEFT')
		this.text:Hide()

		this.xbutton = CreateFrame('BUTTON', nil, this.f, 'GameMenuButtonTemplate')
		this.xbutton:SetPoint('RIGHT', 0, 0)
		this.xbutton:SetText('X')
		this.xbutton:SetWidth(28)
		this.xbutton:SetScript('OnClick', function() removePriorityRule(i)  end)
		this.xbutton:Hide()
	end

	GMC.abutton = CreateFrame('BUTTON', nil, GMC.pmf, 'GameMenuButtonTemplate')
	GMC.abutton:SetText(L['Add priority rule'])
	GMC.abutton:SetWidth(128)
	GMC.abutton:Hide()
	GMC.abutton:SetScript('OnClick', function()
		wipe(prioMenu)
		tinsert(prioMenu,{text = L["Select an item to add as priority."], isTitle = true, isNotRadio=true,disabled=true, notCheckable=true,notClickable=true})
		for k,v in pairs(prioTitles) do
			tinsert(prioMenu,{text = v, func = addPriorityRule, notCheckable=true, isNotRadio=true, arg1 = k , disabled=tContains(GMC.settings.itemPrio,k)})
		end
		EasyMenu(prioMenu, GMC.pmf, "cursor", 0 , 0, "MENU")
		end
	)
	prioRefresh()
	return GMC.pf
end
function addon:GMCBuildMissionList()
		-- Mission list on follower panels
--		local ml=CreateFrame("Frame",nil,GMC)
--		addBackdrop(ml)
--		ml:Show()
--		ml.Missions={}
--		ml.Parties={}
--		GMC.ml=ml
--		local fs=ml:CreateFontString(nil, "BACKGROUND", "GameFontNormalHugeBlack")
--		fs:SetPoint("TOPLEFT",0,-5)
--		fs:SetPoint("TOPRIGHT",0,-5)
--		fs:SetText(READY)
--		fs:SetTextColor(C.Green())
--		fs:SetHeight(30)
--		fs:SetJustifyV("CENTER")
--		fs:Show()
--		GMC.progressText=fs
--		GMC.ml.Header=fs
--		return GMC.ml
	local ml={widget=AceGUI:Create("GMCLayer"),Parties={}}
	ml.widget:SetTitle(READY)
	ml.widget:SetTitleColor(C.Green())
	ml.widget:SetTitleHeight(40)
	ml.widget:SetParent(GMC)
	ml.widget:Show()
	GMC.ml=ml
	return ml.widget

end
