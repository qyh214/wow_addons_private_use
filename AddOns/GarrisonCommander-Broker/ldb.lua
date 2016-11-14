local me, ns = ...
local toc=select(4,GetBuildInfo())
local pp=print
--[===[@debug@
LoadAddOn("Blizzard_DebugTools")
LoadAddOn("LibDebug")
if LibDebug then LibDebug() end
--@end-debug@]===]
local print=print
--@non-debug@
print=function() end
--@end-non-debug@
local L=LibStub("AceLocale-3.0"):GetLocale(me,true)
--local addon=LibStub("AceAddon-3.0"):NewAddon(me,"AceTimer-3.0","AceEvent-3.0","AceConsole-3.0") --#addon
local addon=LibStub("LibInit"):NewAddon(ns,me,{profile='Default',enhancedProfile=true},"AceTimer-3.0","AceEvent-3.0","AceConsole-3.0","AceHook-3.0") --#addon
local C=addon:GetColorTable()
local LDB=LibStub:GetLibrary("LibDataBroker-1.1",true)
if not LDB then
	LDB={fake=true}
	function LDB:NewDataObject(dummy,init)
		return init
	end
end
local dataobj --#Missions
local farmobj --#Farms
local workobj --#Works
local cacheobj --#Cache
local SecondsToTime=SecondsToTime
local type=type
local strsplit=strsplit
local tonumber=tonumber
local tremove=tremove
local time=time
local tinsert=tinsert
local tContains=tContains
local G=C_Garrison
local format=format
local table=table
local math=math
local GetQuestResetTime=GetQuestResetTime
local CalendarGetDate=CalendarGetDate
local CalendarGetAbsMonth=CalendarGetAbsMonth
local GameTooltip=GameTooltip
local pairs=pairs
local select=select
local READY=READY
local NEXT=NEXT
local NONE=C(NONE,"Red")
local DONE=C(DONE,"Green")
local NEED=C(NEED,"Red")
local IsQuestFlaggedCompleted=IsQuestFlaggedCompleted
local CAPACITANCE_SHIPMENT_COUNT=CAPACITANCE_SHIPMENT_COUNT -- "%d of %d Work Orders Available";
local CAPACITANCE_SHIPMENT_READY=CAPACITANCE_SHIPMENT_READY -- "Work Order ready for pickup!";
local CAPACITANCE_START_WORK_ORDER=CAPACITANCE_START_WORK_ORDER -- "Start Work Order";
local CAPACITANCE_WORK_ORDERS=CAPACITANCE_WORK_ORDERS -- "Work Orders";
local GARRISON_FOLLOWER_XP_ADDED_SHIPMENT=GARRISON_FOLLOWER_XP_ADDED_SHIPMENT -- "%s has earned %d XP for completing %d |4Work Order:Work Orders;.";
local GARRISON_LANDING_SHIPMENT_LABEL=GARRISON_LANDING_SHIPMENT_LABEL -- "Work Order";
local GARRISON_LANDING_SHIPMENT_STARTED_ALERT=GARRISON_LANDING_SHIPMENT_STARTED_ALERT -- "Work Order Started";
local GARRISON_SHIPMENT_IN_PROGRESS=GARRISON_SHIPMENT_IN_PROGRESS -- "Work Order In-Progress";
local GARRISON_SHIPMENT_READY=GARRISON_SHIPMENT_READY -- "Work Order Ready";
local QUEUED_STATUS_WAITING=QUEUED_STATUS_WAITING -- "Waiting"
local CAPACITANCE_ALL_COMPLETE=format(CAPACITANCE_ALL_COMPLETE,'') -- "All work orders will be completed in: %s";
local GARRISON_NUM_COMPLETED_MISSIONS=format(GARRISON_NUM_COMPLETED_MISSIONS,'999'):gsub('999','') -- "%d Completed |4Mission:Missions;";
local KEY_BUTTON1 = "\124TInterface\\TutorialFrame\\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:228:283\124t" -- left mouse button
local KEY_BUTTON2 = "\124TInterface\\TutorialFrame\\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:330:385\124t" -- right mouse button
KEY_BUTTON1="Shift " .. KEY_BUTTON1
KEY_BUTTON2="Shift " .. KEY_BUTTON2
local EMPTY=EMPTY -- "Empty"
local GARRISON_CACHE=GARRISON_CACHE
local LE_FOLLOWER_TYPE_GARRISON_6_0=_G.LE_FOLLOWER_TYPE_GARRISON_6_0
local LE_FOLLOWER_TYPE_SHIPYARD_6_2=_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2
local LE_FOLLOWER_TYPE_GARRISON_7_0=_G.LE_FOLLOWER_TYPE_GARRISON_7_0
local LE_GARRISON_TYPE_6_0=_G.LE_GARRISON_TYPE_6_0
local LE_GARRISON_TYPE_6_2=_G.LE_GARRISON_TYPE_6_2
local LE_GARRISON_TYPE_7_0=_G.LE_GARRISON_TYPE_7_0
local dbversion=1
local frequency=5
local ldbtimer=nil
local ColorStrings={
'00FF00', -- 0
'33FF00', -- 1
'66FF00', -- 2
'99FF00', -- 3
'CCFF00', -- 4
'FFFF00', -- 5
'FFCC00', -- 6
'FF9900', -- 7
'FF6500', -- 8
'FF3200', -- 9
'FF0000' -- 10
}
local ColorValues={}
for i=1,#ColorStrings do
	local c=ColorStrings[i]
	ColorValues[i]={tonumber(c:sub(1,2),16)/255,tonumber(c:sub(3,4),16)/255,tonumber(c:sub(5,6),16)/255}
end
local spellids={
	[158754]='herb',
	[158745]='mine',
	[170599]='mine',
	[170691]='herb',
}
local buildids={
	mine={61,62,63},
	herb={29,136,137}
}
local names={
	mine="Lunar Fall",
	herb="Herb Garden"
}
local today=0
local yesterday=0
local lastreset=0
function addon:ldbCleanup()
	local now=time()
	for i=1,#self.db.realm.missions do
		local s=self.db.realm.missions[i]
		if (type(s)=='string') then
			local t,ID,pc=strsplit('.',s)
			t=tonumber(t) or 0
			if pc==ns.me and t < now then
				tremove(self.db.realm.missions,i)
				i=i-1
			end
		end
	end
end
function addon:ldbUpdate()
	dataobj:Update()
	cacheobj:Update()
end
function addon:GARRISON_MISSION_STARTED(event,missionType,missionID)
	local duration=select(2,G.GetPartyMissionInfo(missionID)) or 0
	local followerType=self.db.global.missionType[missionID]
	if not followerType then
		local t=G.GetBasicMissionInfo(missionID)
		followerType=t.followerTypeID
		self.db.global.missionType[missionID]=followerType
	end
	local k=format("%015d.%4d.%s.%d",time() + duration,missionID,ns.me,followerType)
	tinsert(self.db.realm.missions,k)
	table.sort(self.db.realm.missions)
	self:ldbUpdate()
end
function addon:CheckEvents()
	if (G.IsOnGarrisonMap()) then
		self:RegisterEvent("UNIT_SPELLCAST_START")
		--self:RegisterEvent("ITEM_PUSH")
	else
		self:UnregisterEvent("UNIT_SPELLCAST_START")
		--self:UnregisterEvent("ITEM_PUSH")
	end
end
function addon:ZONE_CHANGED_NEW_AREA()
	self:ScheduleTimer("CheckEvents",1)
	self:ScheduleTimer("DiscoverFarms",1)

end
function addon:QUEST_TURNED_IN(event,quest,item,gold)
	if quest==37485 then
		self.db.realm.cachesize[ns.me] = 1000
		self:Print(L["Your garrison cache size was increased to %d"],1000)
--[[
	elseif quest==38445 then
		self.db.realm.cachesize[ns.me] = 750
		self:Print(L["Your garrison cache size was increased to %d"],750)
	elseif quest==37935 then
		self.db.realm.cachesize[ns.me] = 750
		self:Print(L["Your garrison cache size was increased to %d"],750)
--]]
	end

end
function addon:UNIT_SPELLCAST_START(event,unit,name,rank,lineID,spellID)
	if (unit=='player') then
		if spellids[spellID] then
			name=names[spellids[spellID]]
			if not self.db.realm.farms[ns.me][name] or  today > (tonumber(self.db.realm.farms[ns.me][name]) or 0) then
				self:CheckDateReset()
				self.db.realm.farms[ns.me][name]=today
				farmobj:Update()
			end
		end
	end
end
function addon:ITEM_PUSH(event,bag,icon)
--[===[@debug@
	self:print(event,bag,icon)
--@end-debug@]===]
end
function addon:CheckDateReset()
	local oldToday=today
	local reset=GetQuestResetTime()
	local weekday, month, day, year = CalendarGetDate()
	if (day <1 or reset<1) then
		self:ScheduleTimer("CheckDateReset",1)
		return day,reset
	end

	today=year*10000+month*100+day
	if month==1 and day==1 then
		local m, y, numdays, firstday = CalendarGetAbsMonth( 12, year-1 )
		yesterday=y*10000+m*100+numdays
	elseif day==1 then
		local m, y, numdays, firstday = CalendarGetAbsMonth( month-1, year)
		yesterday=y*10000+m*100+numdays
	else
		yesterday=year*10000+month*100+day-1
	end
	if (reset<3600*3) then
		today=yesterday
	end
	self:ScheduleTimer("CheckDateReset",60)
--[===[@debug@
	if (false and today~=oldToday) then
		self:Popup(format("o:%s y:%s t:%s r:%s [w:%s m:%s d:%s y:%s] ",oldToday,yesterday,today,reset,CalendarGetDate()))
		dataobj:Update()
		farmobj:Update()
		workobj:Update()
	end
--@end-debug@]===]
end
function addon:CountMissing()
	local tot=0
	local missing=0
	for p,j in pairs(self.db.realm.farms) do
		for s,_ in pairs(j) do
			tot=tot+1
			if not j[s] or j[s] < today then missing=missing+1 end
		end
	end
	return missing,tot
end
function addon:CountCaches()
	local tot=0
	local missing=0
	local now=time()
	local expired=400*600 -- 1 risorsa ogni 10 minuti, per fullare servono 500 * 600 secondi
	for p,j in pairs(self.db.realm.caches) do
		local expired=(addon.db.realm.cachesize[p] or 500)*0.9 *600
		if j>0 then
			tot=tot+1
			if j+expired < now then
				missing=missing+1
			end
		end
	end
	return missing,tot
end
function addon:CountEmpty()
	local tot=0
	local missing=0
	local expire=time()+3600*12
	for p,j in pairs(self.db.realm.orders) do
		for s,w in pairs(j) do
			tot=tot+1
			if not w or w < expire then missing=missing+1 end
		end
	end
	return missing,tot
end
function addon:WorkUpdate(event,success,shipments_running,shipmentCapacity,plotID)

	local buildings = G.GetBuildings(LE_GARRISON_TYPE_6_0);
	for i = 1, #buildings do
		if plotID == buildings[i].plotID then
			local buildingID,name=G.GetBuildingInfo(buildings[i].buildingID)
			local numPending = G.GetNumPendingShipments()
			if not numPending or numPending==0 then
				if not shipments_running or shipments_running==0 then
					self.db.realm.orders[ns.me][name]=0
				end
			else
				local endQueue=select(6,G.GetPendingShipmentInfo(numPending))
				self.db.realm.orders[ns.me][name]=time()+endQueue
			end
		end
	end
end
function addon:DiscoverFarms()
	local buildings = G.GetBuildings(LE_GARRISON_TYPE_6_0);
	for i = 1, #buildings do
		local buildingID = buildings[i].buildingID;
		if ( buildingID) then
			local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = G.GetLandingPageShipmentInfo(buildingID);
			if (tContains(buildids.mine,buildingID)) then
				names.mine=name
				if not self.db.realm.farms[ns.me][name] then
					self.db.realm.farms[ns.me][name]=0
				end
			end
			if (tContains(buildids.herb,buildingID)) then
				names.herb=name
				if not self.db.realm.farms[ns.me][name] then
					self.db.realm.farms[ns.me][name]=0
				end
			end
			if (shipmentCapacity ) then
				if (creationTime) then
					local numPending=shipmentsTotal-shipmentsReady
					local endQueue=duration*numPending-(time()-creationTime)
					if not numPending or numPending==0 then
						self.db.realm.orders[ns.me][name]=0
					else
						self.db.realm.orders[ns.me][name]=time()+endQueue
					end
				end
			end
		end
	end
	farmobj:Update()
end
function addon:SetDbDefaults(default)
	default.realm={
		missions={},
		farms={["*"]={
				["*"]=false
			}},
		orders={["*"]={
				["*"]=false
			}},
		caches={["*"]=0},
		cachesize={["*"]=false},
		dbversion=1
	}
	default.global.missionType={}
	default.profile['allowedWorkOrders']={["*"]=true}
end
function addon:OnInitialized()
	if dbversion>self.db.realm.dbversion then
		self.db:ResetDB()
		self.db.realm.dbversion=dbversion
	end
	-- Compatibility with alpha
	if self.db.realm.lastday then
		for k,v in pairs(addon.db.realm.farms) do
			for s,d in pairs(v) do
				v[s]=tonumber(self.db.realm.lastday) or 0
			end
		end
		self.db.realm.lastday=nil
	end
	-- Extra sanity check for cases where a broken version messed up things
	for k,v in pairs(addon.db.realm.farms) do
		for s,d in pairs(v) do
			v[s]=tonumber(v[s]) or 0
		end
	end
	-- I was not satisfied with logistic improved, now Ignore it
	for k,v in pairs(addon.db.realm.cachesize) do
		if v and v==750 then
			addon.db.realm.cachesize[k]=500
		end
	end
	print("initing",LDB)
	--[===[@debug@
	if LDB.fake then
		self:Print("Missing LibDataBroker-1.1, still collecting data but no display possibile")
	end
	--@end-debug@]===]
	ns.me=GetUnitName("player",false)
	self:RegisterEvent("GARRISON_MISSION_STARTED")
	self:RegisterEvent("GARRISON_MISSION_NPC_OPENED","ldbCleanup")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("SHIPMENT_CRAFTER_CLOSED")
	self:RegisterEvent("SHIPMENT_CRAFTER_INFO")
	self:RegisterEvent("SHOW_LOOT_TOAST")
	--self:RegisterEvent("QUEST_AUTOCOMPLETE",print)
	--self:RegisterEvent("QUEST_COMPLETE",print)
	--self:RegisterEvent("QUEST_FINISH",print)
	self:RegisterEvent("QUEST_TURNED_IN")
	--self:RegisterEvent("SHIPMENT_CRAFTER_REAGENT_UPDATE",print)
	self:AddLabel(GARRISON_NUM_COMPLETED_MISSIONS)
	self:AddToggle("OLDINT",false,L["Use old interface"],L["Uses the old, more intrusive interface"])
	self:AddToggle("SHOWNEXT",false,L["Show next toon"],L["Show the next toon which will complete a mission"])
	self:AddToggle("SUMMARY",false,L["Only summary"],"Only show summary in tooltip")
	self:AddSlider("FREQUENCY",5,1,60,L["Update frequency"])
	frequency=self:GetNumber("FREQUENCY",5)
	self:ScheduleTimer("DelayedInit",1)
	-- Avoid double adding
	if not IsAddOnLoaded("GarrisonCommander") then
		GarrisonLandingPageMinimapButton:HookScript("OnEnter",function(this)
				if this.description==MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP then
					GameTooltip:AddLine(WARDROBE_NEXT_VISUAL_KEY .. " " .. MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP)
				end
				GameTooltip:Show()
		end
		)
		GarrisonLandingPageMinimapButton:RegisterForClicks("LEFTBUTTONUP","RIGHTBUTTONUP")
		GarrisonLandingPageMinimapButton:SetScript("OnClick",
			function (this,button)
					if (_G.GarrisonLandingPage and GarrisonLandingPage:IsShown()) then
						HideUIPanel(GarrisonLandingPage);
					else
						if button=="RightButton" then
								ShowGarrisonLandingPage(2)
						else
								ShowGarrisonLandingPage(C_Garrison.GetLandingPageGarrisonType());
						end
					end
			end
		)
	end
	self:loadHelp()
end
function addon:ApplyFREQUENCY(value)
	frequency=value
	if (ldbtimer) then
		self:CancelTimer(ldbtimer)
	end
	ldbtimer=self:ScheduleRepeatingTimer("ldbUpdate",frequency)
end
function addon:SHIPMENT_CRAFTER_INFO(...)
	self:WorkUpdate(...)
end
function addon:SHIPMENT_CRAFTER_CLOSED(...)
	self:CountEmpty()
	workobj:Update()
end
function addon:SHOW_LOOT_TOAST(event,typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource)
	if (isPersonal and lootSource==10) then -- GARRISON_CACHE
		self.db.realm.caches[ns.me]=time()
		self.db.realm.caches[ns.me]=time()
		self.db.realm.cachesize[ns.me]=self:GetImprovedCacheSize()
		cacheobj:Update()
	end
end
local init=5
function addon:DelayedInit()
	self:CheckDateReset()
	self:WorkUpdate()
	self:ZONE_CHANGED_NEW_AREA()
	farmobj:Update()
	workobj:Update()
	dataobj:Update()
	self.db.realm.cachesize[ns.me] = self:GetImprovedCacheSize()
	if init > 0 then
		self:ScheduleTimer('DelayedInit',2)
		init=init-1
	else
		ldbtimer=self:ScheduleRepeatingTimer("ldbUpdate",frequency)
	end
end
function addon:GetImprovedCacheSize()
	if IsQuestFlaggedCompleted(37485) then
		return 1000 -- Arakkoa item
--[[
	elseif IsQuestFlaggedCompleted(38445) then
		return 750 --Alliance improved logistic
	elseif IsQuestFlaggedCompleted(37953) then
		return 750 --Horde improved logistic
--]]
	else
		return 500
	end
end

function addon:OnEnabled()
	self:ScheduleTimer("DelayedInit",5)
end
function addon:Gradient(perc)
	local rc,r,g,b=pcall(self.ColorGradient,self,perc,1,0,0,1,1,0,0,1,0)
	if (rc) then
		return r,g,b
	else
		return 0,1,0
	end
end

function addon:ColorGradient(perc, ...)
	if perc > 1 then perc=1
	elseif perc < 0 then perc=0
	end
	local num = select('#', ...) / 3
	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)
	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end
function addon:ColorToString(r,g,b)
	return format("%02X%02X%02X", 255*r, 255*g, 255*b)
end

dataobj=LDB:NewDataObject("GC-Missions", {
	type = "data source",
	label = "GC "  .. GARRISON_NUM_COMPLETED_MISSIONS,
	text=QUEUED_STATUS_WAITING,
	category = "Interface",
	icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_WORKINGOVERTIME"
})
farmobj=LDB:NewDataObject("GC-Farms", {
	type = "data source",
	label = "GC " .. "Harvesting",
	text=QUEUED_STATUS_WAITING,
	category = "Interface",
	icon = "Interface\\Icons\\Inv_ore_gold_nugget"
	--icon = "Interface\\Icons\\Trade_Engineering"
})
workobj=LDB:NewDataObject("GC-WorkOrders", {
	type = "data source",
	label = "GC " ..CAPACITANCE_WORK_ORDERS,
	text=QUEUED_STATUS_WAITING,
	category = "Interface",
	icon = "Interface\\Icons\\Trade_Engineering"
})
cacheobj=LDB:NewDataObject("GC-Cache", {
	type = "data source",
	label = "GC " .. GARRISON_CACHE,
	text=QUEUED_STATUS_WAITING,
	category = "Interface",
	icon = "Interface\\Icons\\inv_garrison_resource"
})
function farmobj:Update()
	local n,t=addon:CountMissing()
	if (t>0) then
		--local c=addon:ColorToString(addon:Gradient(1/t*(t-n)))
		local c,perc=addon:moreIsGood(n,t)
		farmobj.text=format("|cff%s%d|r/|cff20ff20%d|r",c,t-n,t)
	else
		farmobj.text=NONE
	end
end
function workobj:Update()
	local n,t=addon:CountEmpty()
	if (t>0) then
		local c,perc=addon:moreIsGood(n,t)
		workobj.text=format("|cff%s%d|r/|cff20ff20%d|r",c,t-n,t)
	else
		workobj.text=NONE
	end
end

function cacheobj:Update()
	local n,t=addon:CountCaches()
	if (t>0) then
		local c,perc=addon:moreIsGood(n,t)
		cacheobj.text=format("|cff%s%d|r/|cff20ff20%d|r",c,t-n,t)
	else
		cacheobj.text=NONE
	end
end
function farmobj:OnTooltipShow()
	self:AddDoubleLine(L["Time to next reset"],SecondsToTime(GetQuestResetTime()))
	for k,v in kpairs(addon.db.realm.farms) do
		if (k==ns.me) then
			self:AddLine(k,C.Green())
		else
			self:AddLine(k,C.Orange())
		end
		for s,d in kpairs(v) do
			self:AddDoubleLine(s,(d and d==today) and DONE or NEED)
		end
	end
	self:AddLine("Manually mark my tasks:",C:Cyan())
	self:AddDoubleLine(KEY_BUTTON1,DONE)
	self:AddDoubleLine(KEY_BUTTON2,NEED)
	self:AddLine(me,C.Silver())
end
function cacheobj:OnTooltipShow()
	self:AddLine(GARRISON_CACHE)
	for k,v in kpairs(addon.db.realm.caches) do
		local t=addon.db.realm.cachesize[k] or 500
		local n=math.min(t,math.floor((time()-v)*(1/600)))
		self:AddDoubleLine(k==ns.me and C(k,"green") or C(k,"Orange"),format("%d/%d",n,t),nil,nil,nil,addon:moreIsGood(n,t,true)) -- uses more because n is not the "missing" part
	end
	self:AddLine(me,C.Silver())
end

function dataobj:OnTooltipShow()
	self:AddLine(L["Mission awaiting"])
	local db=addon.db.realm.missions
	local now=time()
	local remove=nil
	local last
	if #db > 0 then
		if addon:GetBoolean("SUMMARY") then
			local sorted=addon:NewTable()
			local now=time()
			for i=1,#db do
				if db[i] then
					local t,missionID,pc,followerType=strsplit('.',db[i])
					t=tonumber(t) or 0
					if not sorted[pc] then
						sorted[pc]=t
					else
						if t > now then
							if sorted[pc]<now then
								sorted[pc]=t
							else
								sorted[pc]=math.min(sorted[pc],t)
							end
						end
					end
				end
			end
			for pc,t in pairs(sorted) do
				local msg=format("|cff%s%s|r",pc==ns.me and C.Green.c or C.Orange.c,pc)
				t=t-now
				if t > 0 then
					self:AddDoubleLine(msg,SecondsToTime(t),nil,nil,nil,C:Red())
				else
					self:AddDoubleLine(msg,DONE,nil,nil,nil,C:Green())
				end
			end
			addon:DelTable(sorted)
		--[===[@debug@
		addon:CacheStats()
		--@end-debug@]===]
		else
			for i=1,#db do
				if db[i] then
					local t,missionID,pc,followerType=strsplit('.',db[i])
					t=tonumber(t) or 0
					followerType=tonumber(followerType) or LE_FOLLOWER_TYPE_GARRISON_6_0
					local name= (followerType==LE_FOLLOWER_TYPE_SHIPYARD_6_2) and C(G.GetMissionName(missionID),"cyan") or
									(followerType==LE_FOLLOWER_TYPE_GARRISON_7_0) and C(G.GetMissionName(missionID),"epic") or
									G.GetMissionName(missionID)
					if name then
						if not remove and pc==ns.me then
							if not G.GetPartyMissionInfo(missionID) then
								remove=i
							end
						end
						local msg=format("|cff%s%s|r: %s",pc==ns.me and C.Green.c or C.Orange.c,pc,name)
						if t > now then
							self:AddDoubleLine(msg,SecondsToTime(t-now),nil,nil,nil,C.Red())
						else
							self:AddDoubleLine(msg,DONE)
						end
					end
				end
			end
		end
		if remove then
			tremove(db,remove)
		end
	end
	self:AddLine(me,C.Silver())
end

function dataobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	dataobj.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end

function dataobj:OnLeave()
	GameTooltip:Hide()
end
function farmobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	farmobj.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end
function workobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	workobj.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end
function workobj:OnTooltipShow()
	self:AddLine(CAPACITANCE_WORK_ORDERS)
	local now=time()
	local normal=24*3600
	local short=12*3600
	local long=48*3600
	for k,v in kpairs(addon.db.realm.orders) do
		if (k==ns.me) then
			self:AddLine(k,C.Green())
		else
			self:AddLine(k,C.Orange())
		end

		for s,d in kpairs(v) do
			local delta=d-now
			if (delta >0) then
				local gradient=1
				if delta > long then gradient=0
				elseif delta > normal then  gradient=0.25
				elseif delta >short then gradient=0.5
				end
				self:AddDoubleLine(s,SecondsToTime(delta),nil,nil,nil,addon:Gradient(gradient))
			else
				self:AddDoubleLine(s,EMPTY,nil,nil,nil,C:Red())
			end
		end
	end
	self:AddLine(me,C.Silver())
end

farmobj.OnLeave=dataobj.OnLeave
workobj.OnLeave=dataobj.OnLeave
cacheobj.OnLeave=dataobj.OnLeave
function farmobj:OnClick(button)
	if (IsShiftKeyDown()) then
		for k,v in pairs(addon.db.realm.farms) do
			if (k==ns.me) then
				for s,d in pairs(v) do
					if (button=="LeftButton") then
						v[s]=today;
					else
						v[s]=today-1;
					end
				end
			end
		end
		farmobj:Update()
	else
		dataobj:OnClick(button)
	end
	farmobj:Update()

end

function dataobj:OnClick(button)
	if (button=="LeftButton") then
		GarrisonLandingPage_Toggle()
	else
		addon:Gui()
	end
end
workobj.OnClick=dataobj.OnClick
cacheobj.OnClick=dataobj.OnClick
function dataobj:Update()
	if addon:GetBoolean("OLDINT") then return self:OldUpdate() end
	local now=time()
	local n=0
	local t=0
	local prox=false
	for i=1,#addon.db.realm.missions do
		local tm,missionID,pc=strsplit('.',addon.db.realm.missions[i])
		tm=tonumber(tm) or 0
		t=t+1
		if tm>now then
			if not prox then
				local duration=tm-now
				local duration=duration < 60 and duration or math.floor(duration/60)*60
				prox=format("|cff20ff20%s|r in %s",pc,SecondsToTime(duration))
			end
		else
			n=n+1
		end
	end
	if t>0 then
		local c,perc=addon:moreIsGood(n,t)
		if (prox and addon:GetBoolean("SHOWNEXT")) then
			self.text=format("|cff%s%d|r/|cff20ff20%d|r (%s)",c,n,t,prox)
		else
			self.text=format("|cff%s%d|r/|cff20ff20%d|r",c,n,t)
		end
	else
		self.text=NONE
	end
end
function dataobj:OldUpdate()
	local now=time()
	local completed=0
	local ready=NONE
	local prox=NONE
	for i=1,#addon.db.realm.missions do
		local t,missionID,pc=strsplit('.',addon.db.realm.missions[i])
		t=tonumber(t) or 0
		if t>now then
			local duration=t-now
			local duration=duration < 60 and duration or math.floor(duration/60)*60
			prox=format("|cff20ff20%s|r in %s",pc,SecondsToTime(duration),completed)
			break;
		else
			if ready==NONE then
				ready=format("|cff20ff20%s|r",pc)
			end
		end
		completed=completed+1
	end
	self.text=format("%s: %s (Tot: |cff00ff00%d|r) %s: %s",READY,ready,completed,NEXT,prox)
end-- Resources rate: 144 a day
local satchel_id=120146
local satchel_name
local satchel_link
local satchel_index
local button

local function convert(perc,numeric)
	perc=max(0,min(10,perc))
	if numeric then
		return unpack(ColorValues[perc+1])
	else
		return ColorStrings[perc+1]
	end
end
function addon:lessIsGood(n,t,numeric)
	-- t = total
	-- n = counted
	return convert(math.floor(10/t*(t-n)),numeric)
end
function addon:moreIsGood(n,t,numeric)
	-- t = total
	-- n = counted
	return convert(math.floor(10/t*n),numeric)
end
--[===[@debug@
local function highdebug(tb)
	for k,v in pairs(tb) do
		if type(v) == "function" then
			tb[k]=function(...) print(date(),k) return v(...) end
		end
	end
end
--highdebug(addon)
--highdebug(dataobj)
--highdebug(farmobj)
--highdebug(workobj)
_G.GACB=addon
--@end-debug@]===]
