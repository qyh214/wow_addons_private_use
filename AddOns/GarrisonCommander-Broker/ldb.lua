local me, ns = ...
if (not LibStub:GetLibrary("LibDataBroker-1.1",true)) then
	--[===[@debug@
	print("Missing libdatabroker")
	--@end-debug@]===]
	return
end
if (LibDebug) then LibDebug() end
local L=LibStub("AceLocale-3.0"):GetLocale(me,true)
local addon=LibStub("AceAddon-3.0"):NewAddon(me,"AceTimer-3.0","AceEvent-3.0")
local dataobj
local SecondsToTime=SecondsToTime
local type=type
local strsplit=strsplit
local tonumber=tonumber
local tremove=tremove
local time=time
local tinsert=tinsert
local G=C_Garrison
local NONE=NONE
local DONE=DONE
local format=format
local table=table
local math=math
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
	local now=time()
	local completed=0
	for i=1,#self.db.realm.missions do
		local t,missionID,pc=strsplit('.',self.db.realm.missions[i])
		t=tonumber(t) or 0
		if t>now then
			local duration=t-now
			local duration=duration < 60 and duration or math.floor(duration/60)*60
			dataobj.text=format("Next mission on |cff20ff20%s|r in %s (|cff20ff20%d|r completed)",pc,SecondsToTime(duration),completed)
			return
		end
		completed=completed+1
	end
	dataobj.text=format("Next mission %s (|cff20ff20%d|r completed)",NONE,completed)
end
function addon:GARRISON_MISSION_STARTED(event,missionID)
	local duration=select(2,G.GetPartyMissionInfo(missionID)) or 0
	local k=format("%015d.%4d.%s",time() + duration,missionID,ns.me)
	tinsert(self.db.realm.missions,k)
	table.sort(self.db.realm.missions)
	self:ldbUpdate()
end
function addon:OnInitialize()
	ns.me=GetUnitName("player",false)
	self:RegisterEvent("GARRISON_MISSION_STARTED")
	self:RegisterEvent("GARRISON_MISSION_NPC_OPENED","ldbCleanup")
	self:ScheduleRepeatingTimer("ldbUpdate",1)
	self.db=LibStub("AceDB-3.0"):New("dbGACB",{realm={missions={}}})
end
dataobj=LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(me, {
	type = "data source",
	label = "GarrisonCommander",
	text=NONE,
	icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_WORKINGOVERTIME"
})
function dataobj:OnTooltipShow()
	self:AddLine(L["Mission awaiting"])
	local db=addon.db.realm.missions
	local now=time()
	for i=1,#db do
		if db[i] then
			local t,missionID,pc=strsplit('.',db[i])
			t=tonumber(t) or 0
			local name=C_Garrison.GetMissionName(missionID)
			if (name) then
				if t > now then
					self:AddDoubleLine(format("|cffff9900%s|r: %s",pc,name),SecondsToTime(t-now),nil,nil,nil,0,1,0)
				else
					self:AddDoubleLine(format("|cffff9900%s|r: %s",pc,name),DONE,nil,nil,nil,1,0,0)
				end
			end
		end
	end
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
--[===[@debug@
_G.GACDB=addon
--@end-debug@]===]
--function dataobj:OnClick(button)
--end
