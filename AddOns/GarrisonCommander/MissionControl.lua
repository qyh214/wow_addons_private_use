local me, ns = ...
ns.Configure()
local addon=addon --#addon
local _G=_G
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
local GMCUsedFollowers={}
local wipe=wipe
local pairs=pairs
local tinsert=tinsert
local tremove=tremove
local dbg
local tItems = {
	{t = 'Enable/Disable money rewards.', i = 'Interface\\Icons\\inv_misc_coin_01', key = 'gold'},
	{t = 'Enable/Disable resource awards. (Resources/Seals)', i= 'Interface\\Icons\\inv_garrison_resource', key = 'resources'},
	{t = 'Enable/Disable oil awards.', i= 'Interface\\Icons\\garrison_oil', key = 'oil'},
	{t = 'Enable/Disable rush scroll.', i= 'Interface\\ICONS\\INV_Scroll_12', key = 'rush'},
	{t = 'Enable/Disable Follower XP Bonus rewards.', i = 'Interface\\Icons\\XPBonus_Icon', key = 'xp'},
	{t = 'Enable/Disable follower equip enhancement.', i = 'Interface\\ICONS\\Garrison_ArmorUpgrade', key = 'followerUpgrade'},
	{t = 'Enable/Disable item tokens.', i = "Interface\\ICONS\\INV_Bracer_Cloth_Reputation_C_01", key = 'itemLevel'},
	{t = 'Enable/Disable apexis.', i = "Interface\\Icons\\inv_apexis_draenor", key = 'apexis'},
	{t = 'Enable/Disable other rewards.', i = "Interface\\ICONS\\INV_Box_02", key = 'other'},
	{t = 'Enable/Disable Seal.', i = "Interface\\Icons\\ability_animusorbs", key = 'seal'}
}
local tOrder
local tSort={}
local settings
local module=addon:NewSubClass("MissionControl") --#module
function module:GMCBusy(followerID)
	return GMCUsedFollowers[followerID]
end
addon.GMCBusy=module.GMCBusy
function module:GMCCreateMissionList(workList)
	--First get rid of unwanted rewards and missions that are too long
	local settings=self.privatedb.profile.missionControl
	local ar=settings.allowedRewards
	wipe(workList)
	for _,missionID in self:GetMissionIterator() do
		local discarded=false
		local class=self:GetMissionData(missionID,"class")
		repeat
			print("|cffff0000",'Examing',missionID,self:GetMissionData(missionID,"name"),class,"|r")
			local durationSeconds=self:GetMissionData(missionID,'durationSeconds')
			if (durationSeconds > settings.maxDuration * 3600 or durationSeconds <  settings.minDuration * 3600) then
				print(missionID,"discarded due to len",durationSeconds /3600)
				break
			end -- Mission too long, out of here
			if (self:GetMissionData(missionID,'isRare') and settings.skipRare) then
				print(missionID,"discarded due to rarity")
				break
			end
			if (not ar[class]) then
				print(missionID,"discarded due to class == ", class)
				discarded=true
				break
			end
			if (not discarded) then
				tinsert(workList,missionID)
			end
		until true
	end
	local parties=self:GetParty()
	local function msort(i1,i2)
		local c1=addon:GetMissionData(i1,'class','other')
		local c2=addon:GetMissionData(i2,'class','other')
		if (c1==c2) then
			return addon:GetMissionData(i1,c1,0) > addon:GetMissionData(i2,c2,0)
		else
			return (tSort[c1] or i1)<(tSort[c2] or i2)
		end
	end
	table.sort(workList,msort)
end
--- This routine can be called both as coroutin and as a standard one
-- In standard version, delay between group building and submitting is done via a self schedule
--@param #integer missionID Optional, to run a single mission
--@param #bool start Optional, tells that follower already are on mission and that we need just to start it
function module:GMCRunMission(missionID,start)
	print("Asked to start mission",missionID)
	if (start) then
		G.StartMission(missionID)
		PlaySound("UI_Garrison_CommandTable_MissionStart")
		return
	end
	for i=1,#GMC.ml.Parties do
		local party=GMC.ml.Parties[i]
		print("Checking",party.missionID)
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
	function module:GMCCalculateMissions(this,elapsed)
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
				GMC.runButton:Enable()
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
				--print(C("Processing ","Red"),missionID,addon:GetMissionData(missionID,"name"))
				local minimumChance=0
				if (settings.useOneChance) then
					minimumChance=tonumber(settings.minimumChance) or 100
				else
					minimumChance=tonumber(settings.rewardChance[class]) or 100
				end
				local party={members={},perc=0}
				print ("                           Requested",class,";",minimumChance,"Mission",party.perc,party.full,settings)
				self:MCMatchMaker(missionID,party,settings.skipEpic,minimumChance)
				if ( party.full and party.perc >= minimumChance) then
					--print("                           Mission accepted")
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
						module:GMCRunMission(missionID)
						GMC.ml.widget:RemoveChild(missionID)
					end
					)
				end
				timeElapsed=0
			end
		end
	end
end

function module:GMC_OnClick_Run(this,button)
	this:Disable()
	GMC.logoutButton:Disable()
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
				GMC.logoutButton:Enable()
			end
		end
	end
	)
	end
end
function module:GMC_OnClick_Start(this,button)
	print(C("-------------------------------------------------","Yellow"))
	GMC.ml.widget:ClearChildren()
	if (self:GetTotFollowers(AVAILABLE) == 0) then
		GMC.ml.widget:SetTitle("All followers are busy")
		GMC.ml.widget:SetTitleColor(C.Orange())
		return
	end
	if ( G.IsAboveFollowerSoftCap(1) ) then
		GMC.ml.widget:SetTitle(GARRISON_MAX_FOLLOWERS_MISSION_TOOLTIP)
		GMC.ml.widget:SetTitleColor(C.Red())
		return
	end
	this:Disable()
	GMC.ml.widget:SetTitleColor(C.Green())
	self:GMCCreateMissionList(aMissions)
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
local function drawItemButtons()
	local scale=1.1
	local h=37 -- itemButtonTemplate standard size
	local gap=5
	local single=settings.useOneChance
	--for j = 1, #tItems do
		--local i=tOrder[j]
	for j,i in ipairs(tOrder) do
		local frame = GMC.ignoreFrames[j] or CreateFrame('BUTTON', "Priority" .. j, GMC.aif, 'ItemButtonTemplate')
		GMC.ignoreFrames[j] = frame
		frame:SetID(j)
		frame:ClearAllPoints()
		frame:SetScale(scale)
		frame:SetPoint('TOPLEFT', 0,(j) * (-h -gap) * scale)
		frame.icon:SetTexture(tItems[i].i)
		frame.key=tItems[i].key
		tSort[frame.key]=j
		frame.tooltip=tItems[i].t
		if ns.toc<60200 and frame.key=="oil" then
			settings.allowedRewards[frame.key]=false
		end
		frame.allowed=settings.allowedRewards[frame.key]
		frame.chance=settings.rewardChance[frame.key]
		frame.icon:SetDesaturated(not frame.allowed)
		-- Need to resave them asap in order to populate the array for future scans
		settings.allowedRewards[frame.key]=frame.allowed
		settings.rewardChance[frame.key]=frame.chance
		frame.slider=frame.slider or factory:Slider(frame,0,100,frame.chance or 100,frame.chance or 100)
		frame.slider:SetWidth(128)
		frame.slider:SetPoint('BOTTOMLEFT',60,0)
		frame.slider.Text:SetFontObject('NumberFont_Outline_Med')
		if (single) then
			frame.slider.Text:SetTextColor(C.Silver())
		else
			frame.slider.Text:SetTextColor(C.Green())
		end
		frame.slider.isPercent=true
		frame.slider:SetScript("OnValueChanged",function(this,value)
			settings.rewardChance[this:GetParent().key]=this:OnValueChanged(value)
			end
		)
		frame.slider:OnValueChanged(settings.rewardChance[frame.key] or 100)
		--frame.slider:SetText(settings.rewardChance[frame.key])
		frame.chest = frame.chest or frame:CreateTexture(nil, 'BACKGROUND')
		frame.chest:SetTexture('Interface\\Garrison\\GarrisonMissionUI2.blp')
		frame.chest:SetAtlas(chestTexture)
		frame.chest:SetSize((209-(209*0.25))*0.30, (155-(155*0.25)) * 0.30)
		frame.chest:SetPoint('CENTER',frame.slider, 0, 25)
		if (single) then
			frame.chest:SetDesaturated(true)
		else
			frame.chest:SetDesaturated(false)
		end
		frame.chest:Show()
		frame:SetScript('OnClick', function(this)
			settings.allowedRewards[this.key] = not settings.allowedRewards[this.key]
			drawItemButtons()
			GMC.startButton:Click()
		end)
		frame:SetScript('OnEnter', function(this)
			GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT')
			GameTooltip:AddLine(this.tooltip);
			GameTooltip:Show()
		end)
		frame:RegisterForDrag("LeftButton")
		frame:SetMovable(true)
		frame:SetScript("OnDragStart",function(this,button)
			print("Start",this:GetID(),this.key)
			this:StartMoving()
			this.oldframestrata=this:GetFrameStrata()
			this:SetFrameStrata("FULLSCREEN_DIALOG")
		end)
		frame:SetScript("OnDragStop",function(this,button)
			this:StopMovingOrSizing()
			print("Stopped",this:GetID(),this.key)
			this:SetFrameStrata(this.oldframestrata)

		end)
		frame:SetScript("OnReceiveDrag",function(this)
				print("Receive",this:GetID(),this.key)
				local from=this:GetID()
				local to
				local x,y=this:GetCenter()
				local id=this:GetID()
				for i=1,#GMC.ignoreFrames do
					local f=GMC.ignoreFrames[i]
					if f:GetID() ~= id then
						if y>=f:GetBottom() and y<=f:GetTop() then
							to=f:GetID()
						end
					end
				end
				if (to) then
					print("from:",from,"to:",to)
					local appo=tremove(tOrder,from)
					tinsert(tOrder,to,appo)
				end
				drawItemButtons()
				GMC.startButton:Click()
		end)
		frame:SetScript('OnLeave', function() GameTooltip:Hide() end)
		frame:Show()
		frame.top=frame:GetTop()
		frame.bottom=frame:GetBottom()
	end
	if not GMC.rewardinfo then
		GMC.rewardinfo = GMC.aif:CreateFontString()
		local info=GMC.rewardinfo
		info:SetFontObject('GameFontHighlight')
		info:SetText("Click to enable/disable a reward.\nDrag to reorder")
		info:SetTextColor(1, 1, 1)
		info:SetPoint("TOP",GMC.ignoreFrames[#tItems],"BOTTOM",256/2,-15)
	end
	GMC.aif:SetSize(256, (scale*h+gap) * #tItems)
	return GMC.ignoreFrames[#tItems]

end
local function dbfixV1()
	if type(settings.allowedRewards['equip'])~='nil' then
		settings.allowedRewards['itemLevel']=settings.allowedRewards['equip']
		settings.rewardChance['itemLevel']=settings.rewardChance['equip']
		settings.allowedRewards['equip']=nil
		settings.rewardChance['equip']=nil
	end
	if type(settings.allowedRewards['followerEquip'])~='nil' then
		settings.allowedRewards['followerUpgrade']=settings.allowedRewards['followerEquip']
		settings.rewardChance['followerUpgrade']=settings.rewardChance['followerEquip']
		settings.allowedRewards['followerEquip']=nil
		settings.rewardChance['followerEquip']=nil
	end
end

function module:OnInitialized()
	local bigscreen=ns.bigscreen
	db=addon.db.global
	dbcache=addon.privatedb.profile
	cache=addon.private.profile
	chestTexture='GarrMission-'..UnitFactionGroup('player').. 'Chest'
	GMC = CreateFrame('FRAME', 'GMCOptions', GMF)
	ns.GMC=GMC
	settings=dbcache.missionControl
	tOrder=settings.rewardOrder
	if settings.version < 2 then
		dbfixV1()
	end
	if false then
		local aa={}
		for k,v in pairs(tOrder) do aa[k]=v end
		for k,v in pairs(aa) do tOrder[k]=nil end
		wipe(tOrder)
		for i=1,#tItems do
			tinsert(tOrder,i)
		end
		_G.tOrder=tOrder
	end
	for i=1,#tOrder do
		tSort[tItems[tOrder[i]].key]=i
	end

	if settings.itemPrio then
		settings.itemPrio=nil
	end
	GMC:SetAllPoints()
	--GMC:SetPoint('LEFT')
	--GMC:SetSize(GMF:GetWidth(), GMF:GetHeight())
	GMC:Hide()
	local chance=self:GMCBuildChance()
	local duration=self:GMCBuildDuration()
	local rewards=self:GMCBuildRewards()
	local list=self:GMCBuildMissionList()
	duration:SetPoint("TOPLEFT",0,-50)
	chance:SetPoint("TOPLEFT",duration,"BOTTOMLEFT",0,-80)
	rewards:SetPoint("TOPLEFT",duration,"TOPRIGHT",bigscreen and 50 or 10,0)
	list:SetPoint("TOPLEFT",rewards,"TOPRIGHT",10,-30)
	list:SetPoint("BOTTOMRIGHT",GMF,"BOTTOMRIGHT",-25,25)
	GMC.startButton = CreateFrame('BUTTON',nil,  list.frame, 'GameMenuButtonTemplate')
	GMC.startButton:SetText('Calculate')
	GMC.startButton:SetWidth(148)
	GMC.startButton:SetPoint('TOPLEFT',10,25)
	GMC.startButton:SetScript('OnClick', function(this,button) self:GMC_OnClick_Start(this,button) end)
	GMC.startButton:SetScript('OnEnter', function() GameTooltip:SetOwner(GMC.startButton, 'ANCHOR_TOPRIGHT') GameTooltip:AddLine('Assign your followers to missions.') GameTooltip:Show() end)
	GMC.startButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
	GMC.runButton = CreateFrame('BUTTON', nil,list.frame, 'GameMenuButtonTemplate')
	GMC.runButton:SetText('Send all mission at once')
	GMC.runButton:SetScript('OnEnter', function()
		GameTooltip:SetOwner(GMC.runButton, 'ANCHOR_TOPRIGHT')
		GameTooltip:AddLine(L["Submit all your mission at once. No question asked."])
		GameTooltip:AddLine(L["You can also send mission one by one clicking on each button."])
		GameTooltip:Show()
	end)
	GMC.runButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
	GMC.runButton:SetWidth(148)
	GMC.runButton:SetScript('OnClick',function(this,button) self:GMC_OnClick_Run(this,button) end)
	GMC.runButton:Disable()
	GMC.runButton:SetPoint('TOPRIGHT',-10,25)
	GMC.logoutButton=CreateFrame('BUTTON', nil,list.frame, 'GameMenuButtonTemplate')
	GMC.logoutButton:SetText(LOGOUT)
	GMC.logoutButton:SetWidth(ns.bigscreen and 148 or 90)
	GMC.logoutButton:SetScript("OnClick",function() GMF:Hide() Logout() end )
	GMC.logoutButton:SetPoint('TOP',0,25)
	GMC.skipRare=factory:Checkbox(GMC,settings.skipRare,L["Ignore rare missions"])
	GMC.skipRare:SetPoint("TOPLEFT",chance,"BOTTOMLEFT",40,-50)
	GMC.skipRare:SetScript("OnClick",function(this)
		settings.skipRare=this:GetChecked()
		module:GMC_OnClick_Start(GMC.startButton,"LeftUp")
	end)
	local warning=GMC:CreateFontString(nil,"ARTWORK","CombatTextFont")
	warning:SetText(L["Epic followers are NOT sent alone on xp only missions"])
	warning:SetPoint("TOPLEFT",GMC,"TOPLEFT",0,-25)
	warning:SetPoint("TOPRIGHT",GMC,"TOPRIGHT",0,-25)
	warning:SetJustifyH("CENTER")
	warning:SetTextColor(C.Orange())
	if (settings.skipEpic) then warning:Show() else warning:Hide() end
	GMC.skipEpic=factory:Checkbox(GMC,settings.skipEpic,L["Ignore epic for xp missions."])
	GMC.skipEpic:SetPoint("TOPLEFT",GMC.skipRare,"BOTTOMLEFT",0,-10)
	GMC.skipEpic:SetScript("OnClick",function(this)
		settings.skipEpic=this:GetChecked()
		if (settings.skipEpic) then warning:Show() else warning:Hide() end
		module:GMC_OnClick_Start(GMC.startButton,"LeftUp")
	end)
	GMC.Credits=GMC:CreateFontString(nil,"ARTWORK","QuestFont_Shadow_Small")
	GMC.Credits:SetWidth(0)
	GMC.Credits:SetFormattedText(C(L["Original concept and interface by %s"],'Yellow'),C("Motig","Red") )
	GMC.Credits:SetJustifyH("LEFT")
	GMC.Credits:SetPoint("BOTTOMLEFT",25,25)
	return GMC
end
function module:GMCBuildChance()
	_G['GMC']=GMC
	--Chance
	GMC.cf = CreateFrame('FRAME', nil, GMC)
	GMC.cf:SetSize(256, 150)

	GMC.cp = GMC.cf:CreateTexture(nil, 'BACKGROUND')
	GMC.cp:SetTexture('Interface\\Garrison\\GarrisonMissionUI2.blp')
	GMC.cp:SetAtlas(chestTexture)
	GMC.cp:SetDesaturated(not settings.useOneChance)
	GMC.cp:SetSize((209-(209*0.25))*0.60, (155-(155*0.25))*0.60)
	GMC.cp:SetPoint('CENTER', 0, 20)

	GMC.cc = GMC.cf:CreateFontString()
	GMC.cc:SetFontObject('GameFontNormalHuge')
	GMC.cc:SetText(L['Success Chance'])
	GMC.cc:SetPoint('TOP', 0, 0)
	GMC.cc:SetTextColor(C:White())

	GMC.ct = GMC.cf:CreateFontString()
	GMC.ct:SetFontObject('ZoneTextFont')
	GMC.ct:SetFormattedText('%d%%',settings.minimumChance)
	GMC.ct:SetPoint('TOP', 0, -40)
	if settings.useOneChance then
		GMC.ct:SetTextColor(C:Green())
	else
		GMC.ct:SetTextColor(C:Silver())
	end
	GMC.cs = factory:Slider(GMC.cf,0,100,settings.minimumChance,L['Minumum needed chance'])
	GMC.cs:SetPoint('BOTTOM', 10, 0)
	GMC.cs:SetScript('OnValueChanged', function(self, value)
			local value = math.floor(value)
			GMC.ct:SetText(value..'%')
			settings.minimumChance = value
	end)
	GMC.cs:SetValue(settings.minimumChance)
	GMC.ck=factory:Checkbox(GMC.cs,settings.useOneChance,L["Global success chance"])
	GMC.ck.tooltip=L["Unchecking this will allow you to set specific success chance for each reward type"]
	GMC.ck:SetPoint("TOPLEFT",GMC.cs,"BOTTOMLEFT",-25,-10)
	GMC.ck:SetScript("OnClick",function(this)
		settings.useOneChance=this:GetChecked()
		if (settings.useOneChance) then
			GMC.cp:SetDesaturated(false)
			GMC.ct:SetTextColor(C.Green())
		else
			GMC.cp:SetDesaturated(true)
			GMC.ct:SetTextColor(C.Silver())
		end
		drawItemButtons()
	end)
	return GMC.cf
end
local function timeslidechange(this,value)
	local value = math.floor(value)
	if (this.max) then
		settings.maxDuration = max(value,settings.minDuration)
		if (value~=settings.maxDuration) then this:SetValue(settings.maxDuration) end
	else
		settings.minDuration = min(value,settings.maxDuration)
		if (value~=settings.minDuration) then this:SetValue(settings.minDuration) end
	end
	local c = 1-(value*(1/24))
	if c < 0.3 then c = 0.3 end
	GMC.mt:SetTextColor(1, c, c)
	GMC.mt:SetFormattedText("%d-%dh",settings.minDuration,settings.maxDuration)
end
function module:GMCBuildDuration()
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
	GMC.mt:SetFormattedText('%d-%dh',settings.minDuration,settings.maxDuration)
	GMC.mt:SetPoint('CENTER', 0, 0)
	GMC.mt:SetTextColor(1, 1, 1)

	GMC.ms1 = factory:Slider(GMC.tf,0,24,settings.minDuration,L['Minimum mission duration.'])
	GMC.ms2 = factory:Slider(GMC.tf,0,24,settings.maxDuration,L['Maximum mission duration.'])
	GMC.ms1:SetPoint('BOTTOM', 0, 0)
	GMC.ms2:SetPoint('TOP', GMC.ms1,"BOTTOM",0, -25)
	GMC.ms2.max=true
	GMC.ms1:SetScript('OnValueChanged', timeslidechange)
	GMC.ms2:SetScript('OnValueChanged', timeslidechange)
	timeslidechange(GMC.ms1,settings.minDuration)
	timeslidechange(GMC.ms2,settings.maxDuration)
	return GMC.tf
end
function module:GMCBuildRewards()
	--Allowed rewards
	GMC.aif = CreateFrame('FRAME', nil, GMC)
	GMC.itf = GMC.aif:CreateFontString()
	GMC.itf:SetFontObject('GameFontNormalHuge')
	GMC.itf:SetText(L['Allowed Rewards'])
	GMC.itf:SetPoint('TOP', 0, 0)
	GMC.itf:SetTextColor(1, 1, 1)
	GMC.ignoreFrames = {}
	local ref=drawItemButtons()
	return GMC.aif
end

function module:GMCBuildMissionList()
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
