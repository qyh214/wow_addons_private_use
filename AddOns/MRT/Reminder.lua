local GlobalAddonName, ExRT = ...

--[[
TODO
log next combat
]]

local ELib,L = ExRT.lib,ExRT.L
local module = ExRT:New("Reminder2",L.Reminder)
if not module then return end

local LibDeflate = LibStub:GetLibrary("LibDeflate")

local VMRT = nil

local UnitPowerMax, tonumber, tostring, UnitGUID, PlaySoundFile, RAID_CLASS_COLORS, floor, ceil = UnitPowerMax, tonumber, tostring, UnitGUID, PlaySoundFile, RAID_CLASS_COLORS, floor, ceil
local UnitHealthMax, UnitHealth, ScheduleTimer, UnitName, GetRaidTargetIndex, UnitCastingInfo, UnitChannelInfo, UnitIsUnit, UnitIsDead = UnitHealthMax, UnitHealth, ExRT.F.ScheduleTimer, UnitName, GetRaidTargetIndex, UnitCastingInfo, UnitChannelInfo, UnitIsUnit, UnitIsDead
local GetSpellInfo, strsplit, GetTime, UnitPower, UnitGetTotalAbsorbs, UnitClass, GetSpellCooldown, UnitGroupRolesAssigned = ExRT.F.GetSpellInfo or GetSpellInfo, strsplit, GetTime, UnitPower, UnitGetTotalAbsorbs, UnitClass, ExRT.F.GetSpellCooldown or GetSpellCooldown, UnitGroupRolesAssigned
local pairs, ipairs, bit, string_gmatch, tremove, pcall, format, wipe, type, select, loadstring, next, max, bit_band, unpack = pairs, ipairs, bit, string.gmatch, tremove, pcall, format, wipe, type, select, loadstring, next, math.max, bit.band, unpack

local senderVersion = 4
local addonVersion = 39


module.db.timers = {}
module.db.reminders = {}
local reminders = module.db.reminders
module.db.eventsToTriggers = {}
module.db.showedReminders = {}
module.db.historyNow = {}
module.db.history = {{}}
local IsHistoryEnabled

module.db.nameplateFrames = {}
module.db.nameplateHL = {}
module.db.nameplateGUIDToFrames = {}
module.db.nameplateGUIDToUnit = {}

module.db.frameHL = {}
module.db.frameGUIDToFrames = {}
module.db.frameText = {}

module.db.debug = false
module.db.debugLog = false
module.db.debugDB = {}
module.db.debugByName = {}
module.db.debugLogDB = {}

local profiles = {
	[0] = L.InterruptsProfileShared,
	[1] = L.InterruptsProfilePersonal.." #1",
	[2] = L.InterruptsProfilePersonal.." #2",
	[3] = L.InterruptsProfilePersonal.." #3",
	[4] = L.InterruptsProfilePersonal.." #4",
	[5] = L.InterruptsProfilePersonal.." #5",
}
local profilesSorted = {0,1,2,3,4,5}

local CURRENT_DATA = {}

--upvals
local tCOMBAT_LOG_EVENT_UNFILTERED, tUNIT_HEALTH, tUNIT_POWER_FREQUENT, tUNIT_ABSORB_AMOUNT_CHANGED, tUNIT_AURA, tUNIT_TARGET, tUNIT_SPELLCAST_SUCCEEDED, tUNIT_CAST

local REM = {
	TYPE_TEXT = 1,
	TYPE_CHAT = 2,
	TYPE_NAMEPLATE = 3,
	TYPE_RAIDFRAME = 4,
	TYPE_WA = 5,
	TYPE_BAR = 6,
}

local frame = CreateFrame('Frame',nil,UIParent)
module.frame = frame
frame:SetSize(30,30)
frame:SetPoint("CENTER",UIParent,"TOP",0,-100)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
	if self:IsMovable() then
		self:StartMoving()
	end
end)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	VMRT.Reminder2.Left = self:GetLeft()
	VMRT.Reminder2.Top = self:GetTop()
end)

frame.textBig = frame:CreateFontString(nil,"ARTWORK")
frame.textBig:SetPoint("TOP")
frame.textBig:SetFont(ExRT.F.defFont, 80, "")
frame.textBig:SetShadowOffset(1,-1)
frame.textBig:SetTextColor(1,1,1,1)
frame.textBig:SetText(" ")

frame.text = frame:CreateFontString(nil,"ARTWORK")
frame.text:SetPoint("TOP",frame.textBig,"BOTTOM",0,0)
frame.text:SetFont(ExRT.F.defFont, 40, "")
frame.text:SetShadowOffset(1,-1)
frame.text:SetTextColor(1,1,1,1)
frame.text:SetText(" ")

frame.textSmall = frame:CreateFontString(nil,"ARTWORK")
frame.textSmall:SetPoint("TOP",frame.text,"BOTTOM",0,0)
frame.textSmall:SetFont(ExRT.F.defFont, 20, "")
frame.textSmall:SetShadowOffset(1,-1)
frame.textSmall:SetTextColor(1,1,1,1)
frame.textSmall:SetText(" ")

frame.dot = frame:CreateTexture(nil, "BACKGROUND",nil,-6)
frame.dot:SetTexture("Interface\\AddOns\\MRT\\media\\circle256")
frame.dot:SetAllPoints()
frame.dot:SetVertexColor(1,0,0,1)

frame:Hide()
frame.dot:Hide()



local frameBars = CreateFrame('Frame',nil,UIParent)
module.frameBars = frameBars
frameBars:SetSize(30,30)
frameBars:SetPoint("CENTER",UIParent,"TOP",0,-250)
frameBars:EnableMouse(false)
frameBars:SetMovable(true)
frameBars:RegisterForDrag("LeftButton")
frameBars:SetScript("OnDragStart", function(self)
	if self:IsMovable() then
		self:StartMoving()
	end
end)
frameBars:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	VMRT.Reminder2.BarsLeft = self:GetLeft()
	VMRT.Reminder2.BarsTop = self:GetTop()
end)

frameBars.dot = frameBars:CreateTexture(nil, "BACKGROUND",nil,-6)
frameBars.dot:SetTexture("Interface\\AddOns\\MRT\\media\\circle256")
frameBars.dot:SetAllPoints()
frameBars.dot:SetVertexColor(0,0,1,1)

frameBars:Hide()
frameBars.dot:Hide()

frameBars.IDtoBar = {}
frameBars.bars = {}
frameBars.slots = {}

function frameBars:BarOnUpdate()
	local t = GetTime()
	local timeLeft = self.time_end - t
	if self.check then
		if not self:check() then
			frameBars:StopBar(self.id)
			return
		end
		if timeLeft <= 0 then
			timeLeft = 0.01
		end
	elseif timeLeft <= 0 then
		frameBars:StopBar(self.id)
		return
	end
	if not self.progressFunc then
		self.progress:SetWidth( self.width * (timeLeft/self.time_dur) )
		self.progress:SetTexCoord(0,timeLeft/self.time_dur,0,1)
		if self.icon.on then
			self.icon:SetPoint("LEFT", (self.width - self.height) * (timeLeft/self.time_dur), 0 )
		end
	else
		local pos,val = self:progressFunc()
		self.progress:SetWidth( self:GetWidth() * pos )
		self.progress:SetTexCoord(0,pos,0,1)
		if self.icon.on then
			self.icon:SetPoint("LEFT", (self.width - self.height) * pos, 0 )
		end
		timeLeft = pos * 100
	end

	local time = self.time
	time:SetFormattedText(self.countdownFormat or "%.1f",timeLeft)
	local wnow,wold = time:GetStringWidth(),time.w
	if (wnow > wold and wnow - wold > 3) or (wnow < wold and wold - wnow > 3) then
		time:SetPoint("LEFT",self,"RIGHT",-wnow-3,0)
		time.w = wnow
	end

	if self.text_data and t - self.text_prev >= 0.05 then
		local text = module:FormatMsg(self.text_data[1],self.text_data[2])
		self.text:SetText(text or "")
		self.text_prev = t
	end
end

function frameBars:GetBar()
	for i=1,#self.bars do
		local bar = self.bars[i]
		if not bar:IsShown() then
			return bar
		end
	end
	local bar = CreateFrame("Frame",nil,self)
	self.bars[#self.bars+1] = bar

	local height = VMRT.Reminder2.BarHeight or 40
	local width = VMRT.Reminder2.BarWidth or 450
	local fontSize = floor(height*0.5/2)*2

	bar:SetSize(width,height)
	bar.height = height
	bar.width = width
	ELib:Border(bar,2,0,0,0,1)
	bar.background = bar:CreateTexture(nil, "BACKGROUND")
	bar.background:SetAllPoints()
	bar.background:SetColorTexture(0,0,0,.8)

	bar.progress = bar:CreateTexture(nil, "BORDER")
	bar.progress:SetPoint("TOPLEFT",0,0)
	bar.progress:SetPoint("BOTTOMLEFT",0,0)
	bar.progress:SetTexture(VMRT.Reminder2.BarTexture or [[Interface\AddOns\MRT\media\bar17.tga]])

	bar.text = bar:CreateFontString(nil,"ARTWORK")
	bar.text:SetPoint("LEFT",3,0)
	bar.text:SetFont(VMRT.Reminder2.BarFont or ExRT.F.defFont, fontSize, "")
	bar.text:SetShadowOffset(1,-1)
	bar.text:SetTextColor(1,1,1,1)

	bar.text_prev = 0

	bar.time = bar:CreateFontString(nil,"ARTWORK")
	bar.time:SetPoint("LEFT",self,"RIGHT",-height,0)
	bar.time:SetFont(VMRT.Reminder2.BarFont or ExRT.F.defFont, fontSize, "")
	bar.time:SetShadowOffset(1,-1)
	bar.time:SetTextColor(1,1,1,1)
	bar.time:SetJustifyH("LEFT")
	bar.time.w = 0

	bar.icon = bar:CreateTexture(nil, "BORDER", nil, 2)
	bar.icon:SetSize(height,height)
	bar.icon:Hide()

	bar.ticks = {}

	bar:SetScript("OnUpdate",self.BarOnUpdate)
	
	return bar
end

do
	local function CancelSoundTimers(self)
		for i=1,#self do
			self[i]:Cancel()
		end
	end
	function frameBars:StartBar(id,time,text,size,color,countdownFormat,voice,ticks,icon,checkFunc,progressFunc)
		if not id or time <= 0 then
			return
		end
		if self.IDtoBar[id] then
			self:StopBar(id)
		end
		local bar = self:GetBar()
		bar.time_start = GetTime()
		bar.time_end = bar.time_start + time
		bar.time_dur = time
		bar.id = id
		bar:ClearAllPoints()
		local slot
		for i=1,#self.bars do
			if not self.slots[i] then
				slot = i
				break
			end
		end
		if slot > 30 then
			return
		end
		bar.slot = slot
		if slot == 1 then
			bar:SetPoint("TOP",self,"CENTER",0,0)
		else
			bar:SetPoint("TOP",self.bars[slot-1],"BOTTOM",0,0)
		end
		size = size or 1
		if bar.size ~= size or true then
			bar.size = size
			bar.icon:SetSize(bar.height*size,bar.height*size)
			bar:SetHeight(bar.height*size)

			bar.text:SetScale(size < 1 and size * 1.5 or size)
			bar.time:SetScale(size < 1 and size * 1.5 or size)
		end
		if type(text) == "table" then
			bar.text:SetText(text[3] or "")
			bar.text_data = text
		else
			bar.text:SetText(text or "")
			bar.text_data = nil
		end
		if color then
			bar.progress:SetVertexColor(unpack(color))
		else
			bar.progress:SetVertexColor(1,.3,.3,1)
		end
		bar.countdownFormat = countdownFormat
	
		if voice and time >= 1.3 then
			local clist = {Cancel = CancelSoundTimers}
			local soundTemplate = module.datas.vcdsounds[ voice ]
			if soundTemplate then
				for i=1,min(5,time-0.3) do
					local sound = soundTemplate .. i .. ".ogg"
					local tmr = ScheduleTimer(PlaySoundFile, time-(i+0.3), sound, "Master")
					module.db.timers[#module.db.timers+1] = tmr
					clist[#clist+1] = tmr
				end
				bar.voice = clist
			end
		else
			bar.voice = nil
		end

		for i,t in pairs(bar.ticks) do
			t:Hide()
		end
		if ticks then
			for i=1,#ticks do
				local tick = bar.ticks[i]
				if not tick then
					tick = bar:CreateTexture(nil,"ARTWORK")
					bar.ticks[i] = tick
					tick:SetPoint("TOP")
					tick:SetPoint("BOTTOM")
					tick:SetWidth(2)
					tick:SetColorTexture(0,1,0,1)
				end
				local tt = ticks[i]
				if tt > 0 and tt < time then
					tick:SetPoint("LEFT",bar:GetWidth() * (tt/time) - 1,0)
					tick:Show()
				end
			end
		end
		if icon then
			if type(icon) == "table" then
				bar.icon:SetTexture(icon[3])
				if icon[6] then
					bar.icon:SetTexCoord(unpack(icon[6]))
				else
					bar.icon:SetTexCoord(0,1,0,1)
				end
			else
				if type(icon)=='string' and icon:find("^A:") then
					bar.icon:SetTexCoord(0,1,0,1)
					bar.icon:SetAtlas(icon:sub(3))
				else
					bar.icon:SetTexture(icon)
					bar.icon:SetTexCoord(0,1,0,1)
				end
			end
			bar.icon.on = true
			bar.icon:Show()
		else
			bar.icon:Hide()
			bar.icon.on = false
		end
		if type(checkFunc) == "function" then
			bar.check = checkFunc
		else
			bar.check = nil
		end
		if type(progressFunc) == "function" then
			bar.progressFunc = progressFunc
		else
			bar.progressFunc = nil
		end
	
		self.slots[slot] = true
		self.IDtoBar[id] = bar
	
		bar:Show()
		self:Show()
	end
end

function frameBars:GetBarByID(id)
	if id then
		return self.IDtoBar[id]
	end
end


function frameBars:StopBar(id)
	local bar = self.IDtoBar[id]
	if bar then
		if bar.voice then
			bar.voice:Cancel()
		end
		self.IDtoBar[id] = nil
		bar:Hide()
		self.slots[bar.slot] = false
	end
end

function frameBars:StopAllBars()
	for id,bar in pairs(self.IDtoBar) do 
		bar:Hide()
	end
	wipe(self.IDtoBar)
	wipe(self.slots)
	self:Hide()
end

function module:UpdateVisual(onlyFont)
	local outline = VMRT.Reminder2.FontOutline and "OUTLINE" or ""
	frame.text:SetFont(VMRT.Reminder2.Font or ExRT.F.defFont, VMRT.Reminder2.FontSize or 50, outline)
	frame.textBig:SetFont(VMRT.Reminder2.Font or ExRT.F.defFont, (VMRT.Reminder2.FontSize or 50)*1.5, outline)
	frame.textSmall:SetFont(VMRT.Reminder2.Font or ExRT.F.defFont, (VMRT.Reminder2.FontSize or 50)/2, outline)

	frame.textBig:ClearAllPoints()
	frame.text:ClearAllPoints()
	frame.textSmall:ClearAllPoints()
	
	if VMRT.Reminder2.FontAdj == 1 then
		frame.textBig:SetPoint("TOPLEFT")
		frame.text:SetPoint("TOPLEFT",frame.textBig,"BOTTOMLEFT",0,0)
		frame.textSmall:SetPoint("TOPLEFT",frame.text,"BOTTOMLEFT",0,0)
	elseif VMRT.Reminder2.FontAdj == 2 then
		frame.textBig:SetPoint("TOPRIGHT")
		frame.text:SetPoint("TOPRIGHT",frame.textBig,"BOTTOMRIGHT",0,0)
		frame.textSmall:SetPoint("TOPRIGHT",frame.text,"BOTTOMRIGHT",0,0)
	else
		frame.textBig:SetPoint("TOP")
		frame.text:SetPoint("TOP",frame.textBig,"BOTTOM",0,0)
		frame.textSmall:SetPoint("TOP",frame.text,"BOTTOM",0,0)
	end

	local width = VMRT.Reminder2.BarWidth or 450
	local height = VMRT.Reminder2.BarHeight or 40
	local fontSize = floor(height*0.5/2)*2
	local texture = VMRT.Reminder2.BarTexture or [[Interface\AddOns\MRT\media\bar17.tga]]
	local barfont = VMRT.Reminder2.BarFont or ExRT.F.defFont
	for i=1,#frameBars.bars do
		local bar = frameBars.bars[i]

		bar:SetSize(width,height*(bar.size or 1))
		bar.progress:SetTexture(texture)
		bar.text:SetFont(barfont, fontSize, "")
		bar.time:SetFont(barfont, fontSize, "")
		bar.icon:SetSize(height*(bar.size or 1),height*(bar.size or 1))
		bar.height = height
		bar.width = width	
	end
	
	if onlyFont then
		return
	end
	if VMRT.Reminder2.Left and VMRT.Reminder2.Top then
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",VMRT.Reminder2.Left,VMRT.Reminder2.Top)
	end
	if VMRT.Reminder2.BarsLeft and VMRT.Reminder2.BarsTop then
		frameBars:ClearAllPoints()
		frameBars:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",VMRT.Reminder2.BarsLeft,VMRT.Reminder2.BarsTop)
	end

	if frame.unlocked then
		frame.dot:Show()
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame.text:SetText(L.ReminderDefText)
		frame.textBig:SetText(L.ReminderBigText)
		frame.textSmall:SetText(L.ReminderSmallText)
		frame:Show()

		frameBars.dot:Show()
		frameBars:EnableMouse(true)
		frameBars:SetMovable(true)
		frameBars:StopAllBars()
		frameBars:StartBar("test"..tostring({}),11,"Test Bar")
		frameBars:StartBar("test"..tostring({}),11,"Big Test Bar",1.5)
		frameBars:StartBar("test"..tostring({}),11,"Small Test Bar",0.5)
		frameBars:Show()
	else
		frame.dot:Hide()
		frame:EnableMouse(false)
		frame:SetMovable(false)
		frame.text:SetText("")
		frame.textBig:SetText("")
		frame.textSmall:SetText("")
		frame:Hide()

		frameBars.dot:Hide()
		frameBars:EnableMouse(false)
		frameBars:SetMovable(false)
		frameBars:StopAllBars()
		frameBars:Hide()
	end
end

ELib:FixPreloadFont(frame,function() 
	if VMRT then
		frame.text:SetFont(GameFontWhite:GetFont(),11, "")
		frame.textBig:SetFont(GameFontWhite:GetFont(),11, "")
		frame.textSmall:SetFont(GameFontWhite:GetFont(),11, "")
		module:UpdateVisual(true)
		return true
	end
end)

local function GetMRTNoteLines()
	return {strsplit("\n", VMRT.Note.Text1..(VMRT.Note.SelfText and "\n"..VMRT.Note.SelfText or ""))}
end


local function GSUB_Icon(spellID,iconSize)
	spellID = tonumber(spellID)
	if spellID then
		local _,_,spellTexture = GetSpellInfo( spellID )
		if not iconSize or iconSize == "" then
			iconSize = 0
		end
		return "|T"..(spellTexture or "134400")..":"..iconSize.."|t"
	end
end

local function GSUB_Mark(markID)
	return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..markID..":0|t"
end

local defCDList = {
	DRUID = 22812,
	SHAMAN = 108271,
	WARLOCK = 104773,
	MONK = 115203,
	MAGE = 55342,
	DEMONHUNTER = 198589,
	DEATHKNIGHT = 48792,
	PRIEST = 19236,
	HUNTER = 281195,
	PALADIN = 498,
	WARRIOR = 184364,
	ROGUE = 1966,
	EVOKER = 363916,
}

local defSpecName = {
	[62] = "arcane",
	[63] = "fire",
	[64] = "frost",
	[65] = "holy",
	[66] = "protection",
	[70] = "retribution",
	[71] = "arms",
	[72] = "fury",
	[73] = "protection",
	[74] = "ferocity",
	[79] = "cunning",
	[81] = "tenacity",
	[102] = "balance",
	[103] = "feral",
	[104] = "guardian",
	[105] = "restoration",
	[250] = "blood",
	[251] = "frost",
	[252] = "unholy",
	[253] = "beast mastery",
	[254] = "marksmanship",
	[255] = "survival",
	[256] = "discipline",
	[257] = "holy",
	[258] = "shadow",
	[259] = "assassination",
	[260] = "outlaw",
	[261] = "subtlety",
	[262] = "elemental",
	[263] = "enhancement",
	[264] = "restoration",
	[265] = "affliction",
	[266] = "demonology",
	[267] = "destruction",
	[268] = "brewmaster",
	[269] = "windwalker",
	[270] = "mistweaver",
	[535] = "ferocity",
	[536] = "cunning",
	[537] = "tenacity",
	[577] = "havoc",
	[581] = "vengeance",
	[1467] = "devastation",
	[1468] = "preservation",
}

local damageImmuneCDList = {
	MAGE = 45438,
	HUNTER = 186265,
	PALADIN = 642,
	ROGUE = 31224,
	DEMONHUNTER = 196555,
}

local sprintCDList = {
	DRUID = 106898,
	SHAMAN = 192077,
	MONK = 116841,
	EVOKER = 374968,
}

local healCDList = {
	[65] = 317223,
	[257] = 64844,
	[264] = 108280,
	[270] = 115310,
	[105] = 157982,
	[1468] = 363534,
}

local raidCDList = {
	[65] = 31821,
	[66] = 204018,
	[256] = 62618,
	[264] = 98008,
	[71] = 97463,
	[72] = 97463,
	[73] = 97463,
	[577] = 196718,
	[250] = 51052,
	[251] = 51052,
	[252] = 51052,
}

local gsub_trigger_params_now
local gsub_trigger_update_req

local function GSUB_NumCondition(num,str)
	num = tonumber(num)
	if not num or num == 0 then
		return ""
	end
	return select(num,strsplit(";",str or "")) or ""
end

local function GSUB_Icon(str)
	local spellID,iconSize = strsplit(":",str)
	spellID = tonumber(spellID)
	if spellID then
		local _,_,spellTexture = GetSpellInfo( spellID )
		if not iconSize or iconSize == "" then
			iconSize = 0
		end
		return "|T"..(spellTexture or "134400")..":"..iconSize.."|t"
	end
end

local function GSUB_Upper(_,str)
	return (str or ""):upper()
end

local function GSUB_Lower(_,str)
	return (str or ""):lower()
end

local function GSUB_ModNextWord(str)
	if str:find("^specIconAndClassColor") then
		local name = str:match("^specIconAndClassColor *(.-)$")
		if name then
			local mod = name
			local class = select(2,UnitClass(name))
			if class and RAID_CLASS_COLORS[class] then
				mod = "|c"..RAID_CLASS_COLORS[class].colorStr..mod.."|r"
			end
			local role = UnitGroupRolesAssigned(name)
			if role == "TANK" then
				mod = "|A:groupfinder-icon-role-large-tank:0:0|a"..mod
			elseif role == "DAMAGER" then
				mod = "|A:groupfinder-icon-role-large-dps:0:0|a"..mod
			elseif role == "HEALER" then
				mod = "|A:groupfinder-icon-role-large-heal:0:0|a"..mod
			end
			return mod
		else
			return ""
		end
	elseif str:find("^specIcon") then
		local name = str:match("^specIcon *(.-)$")

		if name then
			local role = UnitGroupRolesAssigned(name)
			if role == "TANK" then
				return "|A:groupfinder-icon-role-large-tank:0:0|a"..name
			elseif role == "DAMAGER" then
				return "|A:groupfinder-icon-role-large-dps:0:0|a"..name
			elseif role == "HEALER" then
				return "|A:groupfinder-icon-role-large-heal:0:0|a"..name
			else
				return name
			end
		else
			return ""
		end
	elseif str:find("^classColor") then
		local name = str:match("^classColor *(.-)$")
		if name then
			local class = select(2,UnitClass(name))
			if class and RAID_CLASS_COLORS[class] then
				return "|c"..RAID_CLASS_COLORS[class].colorStr..name.."|r"
			end
			return name
		else
			return ""
		end
	end
end

local GSUB_Math
do
	local setfenv = setfenv
	GSUB_Math = function(line)
		local c,lastChar = line:match("^([%d%.%+%-/%*%(%)%%%^]+)([rfc]?)$")
		if c then
			local func, error = loadstring("return "..c)
			if func then
				setfenv(func, {})
				local isFine, res = pcall(func)
				if type(res) == "number" then
					if lastChar == "r" then
						return tostring(floor(res+0.5))
					elseif lastChar == "f" then
						return tostring(floor(res))
					elseif lastChar == "c" then
						return tostring(ceil(res))
					else
						return tostring(res)
					end
				end
			end
		else
			local isHex,hexBase,str = line:match("^(hex):(%d-):?([^:]+)$")
			if isHex == "hex" then
				if hexBase == "" then hexBase = 16 end
				str = str:match("[0-9A-Za-z]+$")
				if str then
					local res = tonumber(str,tonumber(hexBase),nil)
					if res then
						return tostring(res)
					end
				end
			end
		end 
		return "0"
	end
end

local function GSUB_Repeat(num,line)
	return (line or ""):rep(min(100,tonumber(num) or 0))
end

local function GSUB_Length(num,line)
	local res = ExRT.F.utf8sub(line or "", 1, tonumber(num) or 0)
	if res:find("|c.?.?.?.?.?.?.?.?$") then
		res = res:gsub("|c.?.?.?.?.?.?.?.?$","")
	end
	return res
end

local function GSUB_None()
	return ""
end

local function GSUB_ExRTNote(patt)
	patt = "^"..patt:gsub("%%","%%%%"):gsub("[%-%.%+%*%(%)%$%[%?%^]","%%%1")
	if VMRT and VMRT.Note and VMRT.Note.Text1 then
		local lines = GetMRTNoteLines()
		for i=1,#lines do
			if lines[i]:find(patt) then
				return lines[i]
			end
		end
	end
	return ""
end

local function GSUB_ExRTNoteList(str)
	local pos,patt = strsplit(":",str,2)
	patt = "^"..(patt or ""):gsub("%%","%%%%"):gsub("[%-%.%+%*%(%)%$]","%%%1")
	if VMRT and VMRT.Note and VMRT.Note.Text1 and tonumber(pos) then
		local lines = GetMRTNoteLines()
		for i=1,#lines do
			if lines[i]:find(patt) then
				pos = tonumber(pos)
				local line = lines[i]:gsub(patt,""):gsub("|c........",""):gsub("|r",""):gsub("%b{}",""):gsub("|",""):gsub(" +"," "):trim()
				local u,uc = {},0
				line = line:gsub("%b()",function(a)
					uc = uc + 1
					u[uc] = a:sub(2,-2)
					return "##"..uc
				end)
				local allpos = {strsplit(" ", line)}
				pos = pos % #allpos
				if pos == 0 then pos = #allpos end
				local res = allpos[pos]
				if not res then
					return ""
				end
				if res:find("^##%d+$") then
					local c = res:match("^##(%d+)$")
					res = u[tonumber(c)]
					res = res:gsub(" ",";")
				end
				return res
			end
		end
	end
	return ""
end

local function GSUB_Min(line)
	local m
	for c in string_gmatch(line, "[^;,]+") do
		c = tonumber(c)
		if c and (not m or c < m) then
			m = c
		end
	end
	return m or ""
end

local function GSUB_Max(line)
	local m
	for c in string_gmatch(line, "[^;,]+") do
		c = tonumber(c)
		if c and (not m or c > m) then
			m = c
		end
	end
	return m or ""
end

local function GSUB_Status(str)
	gsub_trigger_update_req = true
	if gsub_trigger_params_now and gsub_trigger_params_now._reminder then
		local triggerNum,uid = strsplit(":",str,2)

		triggerNum = tonumber(triggerNum) or 0
		local trigger = gsub_trigger_params_now._reminder.triggers[triggerNum]
		uid = tonumber(uid) or uid or ""
		if trigger and trigger.active and trigger.active[uid] then
			return "on"
		end
	end
	return "off"
end

local function GSUB_YesNoCondition(condition,str)
	local res = 1
	local pnow = 1
	local isORnow = false
	while true do
		local andps,andpe = condition:find(" AND ",pnow)
		local orps,orpe = condition:find(" OR ",pnow)
		
		local curre = condition:len()
		local nexts
		local isOR
		if andps then
			curre = andps - 1
			nexts = andpe + 1
		end
		if orps and orps < curre then
			curre = orps - 1
			nexts = orpe + 1
			isOR = true
		end
		local condNow = condition:sub(pnow,curre)
		local a,b,condRest = condNow:match("^([^}=~<>]*)([=~<>]=?)(.-)$")

		local isPass
		if condRest then
			for c in string_gmatch(condRest, "[^;]+") do
				if 
					(b == "=" and a == c) or 
					(b == "~" and a ~= c) or 
					(b == ">" and tonumber(a) and tonumber(c) and tonumber(a) > tonumber(c)) or
					(b == "<" and tonumber(a) and tonumber(c) and tonumber(a) < tonumber(c)) or
					(b == "<=" and tonumber(a) and tonumber(c) and tonumber(a) <= tonumber(c)) or
					(b == ">=" and tonumber(a) and tonumber(c) and tonumber(a) >= tonumber(c)) or
					(b == ">" and a > c) or
					(b == "<" and a < c)
				then
					isPass = true
					break
				end
			end
		end

		if isORnow then
			res = res + (isPass and 1 or 0)
		else
			res = res * (isPass and 1 or 0)
		end

		isORnow = isOR 

		if not nexts then
			break
		end
		pnow = nexts
	end

	local yes,no = strsplit(";",str or "")
	if res > 0 then
		return yes
	else
		return no or ""
	end
end

local function GSUB_Mark(num)
	if tonumber(num) then
		return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..num..":0|t"
	end
end

local function GSUB_Role(name)
	local role = UnitGroupRolesAssigned(name)
	return (role or "none"):lower()
end

local function GSUB_RoleExtra(name)
	local role1,role2 = module:GetUnitRole(name)
	return (role2 or role1 or "none"):lower()
end

local function GSUB_Find(arg,res)
	local find,str = strsplit(":",arg,2)
	local yes,no = strsplit(";",res or "")
	if (str or ""):find(find) then
		return yes
	else
		return no or ""
	end
end

local function GSUB_Replace(arg,res)
	local from,to = strsplit(":",arg,2)
	local isOk, resOk = pcall(string.gsub, res, from, to)
	return isOk and resOk or res
end

local function GSUB_Sub(arg)
	local from,to,str = strsplit(":",arg,3)
	from = tonumber(from)
	to = tonumber(to or "")
	if from and to and str then
		if to == 0 then to = -1 end
		return str:sub(from,to)
	else
		return ""
	end
end

local function GSUB_EscapeSequences(a)
	if a == "n" then
		return "\n"
	else
		return "|"..a
	end
end

local function GSUB_OnlyIconsFix(text)
	if text:gsub("|T.-|t","") == "" then
		return text .. " "
	end
end

local function GSUB_Trim(text)
	return text:trim()
end


local GSUB_TriggerExtra, GSUB_Trigger

local CreateListOfReplacers
do
	local listOfExtraTriggerWords = {
		allSourceNames = true,
		allTargetNames = true,
		activeTime = true,
		timeLeft = true,
		status = true,
		allActiveUIDs = true,
		activeNum = true,
		timeMinLeft = true,
		counter = true,
		patt = true,
	}
	local listOfReplacers = {}

	function CreateListOfReplacers()
		for k,v in pairs(module.C) do
			if v.replaceres then
				for _,r in ipairs(v.replaceres) do
					listOfReplacers[r] = true
				end
			end
		end	
	end

	function GSUB_TriggerExtra(mword,word,num,rest)
		if gsub_trigger_params_now then
			local r = gsub_trigger_params_now[mword or word]

			if word == "counter" then
				local mod,subrest = rest:match("^:(%d+)(.-)$")

				if mod then
					local c = tonumber(r) or 0
					if c == 0 then
						return "0"..subrest
					end
					return ( (c-1)%(tonumber(mod) or 1) + 1 )..subrest
				elseif r then
					return r..rest
				else
					return "0"..rest
				end
			elseif word == "timeLeft" then
				gsub_trigger_update_req = true

				local t = gsub_trigger_params_now._reminder and gsub_trigger_params_now._reminder.triggers[tonumber(num) or 0] or gsub_trigger_params_now._trigger
				if t and not t.status then
					local ts = gsub_trigger_params_now._reminder.triggers
					for j=1,#ts do
						if ts[j].status then
							t = ts[j]
							break
						end
					end
				end
				if t and t.status then
					local mod,subrest = rest:match("^:(%d+)(.-)$")
					if mod then
						return format("%."..mod.."f",max((t.status.timeLeft or t.status.timeLeftB) - GetTime(),0))..subrest
					else
						return format("%.1f",max((t.status.timeLeft or t.status.timeLeftB) - GetTime(),0))..rest
					end
				end
				return rest
			elseif type(r) == "function" then
				gsub_trigger_update_req = true
				local res,cutRest = r(select(2,strsplit(":",rest)))
				if res then
					return res..(not cutRest and rest or "")
				end
			elseif r then
				return r..rest
			elseif word == "allSourceNames" or word == "allTargetNames" then
				local key = word == "allSourceNames" and "sourceName" or "targetName"

				local indexFrom,indexTo,customPattern = select(2,strsplit(":",rest))
				local onlyText

				if indexFrom then indexFrom = tonumber(indexFrom) end
				if indexTo then indexTo = tonumber(indexTo) end
				if indexFrom == 0 or indexTo == 0 then indexFrom = nil end
				if customPattern == "1" then onlyText = true customPattern = nil else onlyText = false end
				local r="" 
				local lowestindex = 0
				local count = 0

				if not onlyText then
					gsub_trigger_update_req = true
				end

				local t = gsub_trigger_params_now._reminder and gsub_trigger_params_now._reminder.triggers[tonumber(num) or 0]
				if not t and gsub_trigger_params_now._reminder then
					local ts = gsub_trigger_params_now._reminder.triggers
					for j=1,#ts do
						if ts[j].status then
							t = ts[j]
							break
						end
					end
					t = t or gsub_trigger_params_now._reminder.triggers[1]
				end
				if t then
					repeat
						local lownow, vnow
						for _,v in pairs(t.active) do 
							if (not lownow or v.aindex < lownow) and v.aindex > lowestindex then
								vnow = v
								lownow = v.aindex
							end
						end 
						if vnow then
							count = count + 1
							if not indexFrom or (count >= indexFrom and count <= indexTo) then
								if vnow[key] then 
									if customPattern then
										r=r..customPattern:gsub("([A-Za-z]+)",function(a)
											return vnow[a]
										end)
									else
										local index = UnitName(vnow[key]) and GetRaidTargetIndex(vnow[key])
										if index and not onlyText then r=r..ExRT.F.GetRaidTargetText(index,0) end
										r=r..(onlyText and "" or "%classColor")..vnow[key]..", " 
									end
								end 
							end
							lowestindex = lownow
						else
							lowestindex = nil
						end
					until (not lowestindex)
					return (customPattern and r:gsub("|?|?[n;,] *$","") or r:sub(1,-3))..(not rest:find("^:") and rest or "")
				end
				return rest
			elseif word == "allActiveUIDs" then
				local indexFrom,indexTo,specialOpt = select(2,strsplit(":",rest))

				if indexFrom then indexFrom = tonumber(indexFrom) or 1 end
				if indexTo then indexTo = tonumber(indexTo) or math.huge end
				local r="" 
				local lowestindex = 0
				local count = 0
				local t = gsub_trigger_params_now._reminder and gsub_trigger_params_now._reminder.triggers[tonumber(num) or 1]
				if t then
					if specialOpt == "2" then
						local list = {}
						for _,v in pairs(t.active) do 
							if v.guid then 
								list[#list+1] = v.guid
							end
						end
						if #list > 0 then				
							sort(list)
							for i=1,#list do
								r = r .. list[i] .. ";"
							end
							return r:sub(1,-2) 
						end
					else
						repeat
							local lownow, vnow
							for _,v in pairs(t.active) do 
								if (not lownow or v.aindex < lownow) and v.aindex > lowestindex then
									vnow = v
									lownow = v.aindex
								end
							end 
							if vnow then
								count = count + 1
								if not indexFrom or (count >= indexFrom and count <= indexTo) then
									if vnow.uid or vnow.guid then 
										r=r..(vnow.uid or vnow.guid)..";" 
									end 
								end
								lowestindex = lownow
							else
								lowestindex = nil
							end
						until (not lowestindex)
						return r:sub(1,-2) .. (not indexFrom and rest or "")
					end
				end
				return rest
			elseif word == "activeTime" then
				gsub_trigger_update_req = true

				local t = gsub_trigger_params_now._reminder and gsub_trigger_params_now._reminder.triggers[tonumber(num) or 0] or gsub_trigger_params_now._trigger
				if t and not t.status then
					local ts = gsub_trigger_params_now._reminder.triggers
					for j=1,#ts do
						if ts[j].status then
							t = ts[j]
							break
						end
					end
				end
				if t and t.status then
					local mod,subrest = rest:match("^:(%d+)(.-)$")
					if mod then
						return format("%."..mod.."f",GetTime() - t.status.atime)..subrest
					else
						return format("%.1f",GetTime() - t.status.atime)..rest
					end
				end
				return rest
			elseif word == "status" then
				gsub_trigger_update_req = true

				local t = gsub_trigger_params_now._reminder and gsub_trigger_params_now._reminder.triggers[tonumber(num) or 1]
				if t and t.status then
					return "on"..rest
				else
					return "off"..rest
				end
			elseif word == "activeNum" then
				gsub_trigger_update_req = true

				local c = 0
				local t = gsub_trigger_params_now._reminder and gsub_trigger_params_now._reminder.triggers[tonumber(num) or 0] or gsub_trigger_params_now._trigger or gsub_trigger_params_now._reminder and gsub_trigger_params_now._reminder.triggers[1]
				if t and t.active then
					for _ in pairs(t.active) do 
						c=c+1 
					end
				end
				return tostring(c)..rest
			elseif word == "timeMinLeft" then
				gsub_trigger_update_req = true

				local t = gsub_trigger_params_now._reminder and gsub_trigger_params_now._reminder.triggers[tonumber(num) or 0] or gsub_trigger_params_now._trigger or gsub_trigger_params_now._reminder and gsub_trigger_params_now._reminder.triggers[1]
				if t and t._trigger.activeTime then
					local lowest
					for _,v in pairs(t.active) do 
						if v.atime and (not lowest or lowest > v.atime) then
							lowest = v.atime
						end
					end
					if lowest then
						local mod,subrest = rest:match("^:(%d+)(.-)$")
						if mod then
							return format("%."..mod.."f",lowest + t._trigger.activeTime - GetTime())..subrest
						else
							return format("%.1f",lowest + t._trigger.activeTime - GetTime())..rest
						end
					end
				end
				return rest
			elseif word == "patt" then
				if gsub_trigger_params_now._data and gsub_trigger_params_now._data.notePattern then
					local players = module:FindPlayersListInNote(gsub_trigger_params_now._data.notePattern)
					if players then
						local c = 1
						local isOpen
						players = players:gsub("%b{}","")
						local list = {}
						for p in string_gmatch(players, "[^ ]+") do
							if p:sub(1,1) == "(" then
								isOpen = true
								p = p:sub(2)
							end
							if p:sub(-1,-1) == ")" then
								isOpen = false
								p = p:sub(1,-2)
							end
							if isOpen and list[c] then
								list[c] = list[c] .. " " .. p
							else
								list[c] = p
							end
							if not isOpen then
								c = c + 1
							end
						end
						if num ~= "" then
							return (list[tonumber(num)] or "")..rest
						else
							return players..rest
						end
					end
				end
			elseif listOfReplacers[word] then
				return rest or ""
			end
		end
	end

	function GSUB_Trigger(mword,word,num,rest)
		if word == "playerName" then
			return UnitName'player'..rest
		elseif word == "playerClass" then
			return (select(2,UnitClass'player'):lower())..rest
		elseif word == "playerSpec" then
			local specid,specname = GetSpecializationInfo and GetSpecializationInfo(GetSpecialization() or 1)
			return (defSpecName[specid or 0] or specname and specname:lower() or "")..rest
		elseif word == "defCDIcon" then
			local icon = defCDList[select(2,UnitClass'player') or ""]
			return (icon and "{spell:"..icon.."}" or "")..rest
		elseif word == "damageImmuneCDIcon" then
			local icon = damageImmuneCDList[select(2,UnitClass'player') or ""]
			return (icon and "{spell:"..icon.."}" or "")..rest
		elseif word == "sprintCDIcon" then
			local icon = sprintCDList[select(2,UnitClass'player') or ""]
			return (icon and "{spell:"..icon.."}" or "")..rest
		elseif word == "healCDIcon" then
			local specid,specname = GetSpecializationInfo and GetSpecializationInfo(GetSpecialization() or 1)
			local icon = healCDList[specid or 0]
			return (icon and "{spell:"..icon.."}" or "")..rest
		elseif word == "raidCDIcon" then
			local specid,specname = GetSpecializationInfo and GetSpecializationInfo(GetSpecialization() or 1)
			local icon = raidCDList[specid or 0]
			return (icon and "{spell:"..icon.."}" or "")..rest
		elseif word == "notePlayer" or word == "notePlayerRight" then
			if gsub_trigger_params_now and gsub_trigger_params_now._data then
				local notePattern = gsub_trigger_params_now._data.notePattern
				if notePattern then
					local found, line = module:FindPlayerInNote(notePattern)
					if found and line then
						line = line:gsub(notePattern.." *",""):gsub("|c........",""):gsub("|r",""):gsub("{time[^}]+}",""):gsub("{0}.-{/0}",""):gsub(" *$",""):gsub("|",""):gsub(" +"," ")
						local playerName = UnitName'player'
						if word == "notePlayer" then
							local prefix = line:match("([^ ]+) +[^ ]*"..playerName) or ""
							if prefix:find("_$") then
								local prefix2 = line:match("(%b__) +[^ ]*"..playerName)
								if prefix2 then
									prefix = prefix2:sub(2,-2)
								end
							end
							if prefix:find("^%(") then prefix = prefix:sub(2) end
							return prefix..rest
						else
							local suffix = line:match(playerName.."[^ ]* +([^ ]+)") or ""
							if suffix:find("^_") then
								local suffix2 = line:match(playerName.."[^ ]* +(%b__)")
								if suffix2 then
									suffix = suffix2:sub(2,-2)
								end
							end
							return suffix..rest
						end


					end
				end
			end
			return rest
		elseif mword:find("^specIcon") or mword:find("^classColor") then
			--nothing, save for GSUB_ModNextWord
			return
		end
		return GSUB_TriggerExtra(mword,word,num,rest) or "%"..mword..rest
	end

	local set_list = {}
	local set_update_req
	local function GSUB_Set(num,str)
		if num ~= "" and tonumber(num) then
			if set_update_req then
				wipe(set_list)
				set_update_req = false
			end
			set_list[num] = str
		end
		return ""
	end
	local function GSUB_SetBack(num)
		return set_list[num] or ""
	end

	local replace_counter = false
	local replace_forchat = false

	local handlers_nocloser = {
		spell = GSUB_Icon,
		math = GSUB_Math,
		noteline = GSUB_ExRTNote,
		note = GSUB_ExRTNoteList,
		min = GSUB_Min,
		max = GSUB_Max,
		status = GSUB_Status,
		role = GSUB_Role,
		roleextra = GSUB_RoleExtra,
		sub = GSUB_Sub,
		trim = GSUB_Trim,
	}

	local function replace_nocloser(mword,word,num,fullArg,arg)
		local handler = handlers_nocloser[word]
		if handler then
			--print('nc',word,arg)
			replace_counter = true
			return handler(arg) or ""
		elseif word == "rt" then
			replace_counter = true
			--print('nc',word,arg)
			if replace_forchat then
				return "___M"..num.."___"
			end
			return GSUB_Mark(num) or ""
		elseif gsub_trigger_params_now and (gsub_trigger_params_now[word] or gsub_trigger_params_now[mword] or listOfExtraTriggerWords[word] or listOfExtraTriggerWords[mword]) then
			replace_counter = true
			--print('nc',word,arg)
			return GSUB_TriggerExtra(mword,word,num,fullArg) or ""
		end 
	end

	local handlers_closer = {
		num = GSUB_NumCondition,
		up = GSUB_Upper,
		lower = GSUB_Lower,
		rep = GSUB_Repeat,
		len = GSUB_Length,
		["0"] = GSUB_None,
		cond = GSUB_YesNoCondition,
		find = GSUB_Find,
		replace = GSUB_Replace,
		set = GSUB_Set,
	}

	local function replace_closer(word,arg,data)
		local handler = handlers_closer[word]
		if handler then
			replace_counter = true
			--print('c',word,arg,data)
			return handler(arg,data) or ""
		end 
	end

	function module:FormatMsg(msg,params,isForChat)
		gsub_trigger_params_now = params
		gsub_trigger_update_req = false

		set_update_req = true
		replace_forchat = false
		if isForChat then
			replace_forchat = true
		end

		msg = msg:gsub("%%(([A-Za-z]+)(%d*))([^%% ,{}]*)",GSUB_Trigger)

		--print('lets go')
		local subcount = 0
		while true do
			replace_counter = false
			subcount = subcount + 1
			--print('sc',subcount,msg)
			msg = msg:gsub("{(([A-Za-z]+)(%d*))(:?([^{}]*))}",replace_nocloser)
				:gsub("{([^:{}]+):?([^{}]*)}([^{}]-){/%1}",replace_closer)
			if not replace_counter or subcount > 100 then
				if not set_update_req then
					msg = msg:gsub("%%set(%d+)",GSUB_SetBack)
					set_update_req = true
				else
					break
				end
			end
		end
	
		msg = msg:gsub("||([crTtnAa])",GSUB_EscapeSequences)
			:gsub("%%([sc][A-Za-z]+ *[^ ,%%;:%(%)|]*)",GSUB_ModNextWord)
			:gsub("[^\n]+",GSUB_OnlyIconsFix)

		if replace_forchat then
			msg = msg:gsub("___M(%d+)___","{rt%1}")
		end

		return msg, gsub_trigger_update_req
	end
end

function module:FormatMsgForChat(msg)
	return msg:gsub("|c........",""):gsub("|[rn]",""):gsub("|[TA][^|]+|[ta]","")
end

function module:ExtraCheckParams(extraCheck,params)
	extraCheck = module:FormatMsg(extraCheck,params)

	if not extraCheck:find("[=~<>]") then
		return false, false
	else
		if GSUB_YesNoCondition(extraCheck,1) == "1" then
			return true, true
		else
			return false, true
		end
	end
end

module.datas = {
	countdownType = {
		{1,"5"," %d"},
		{nil,"5.3"," %.1f"},
		{3,"5.32"," %.2f"},
	},
	countdownTypeText = {
		{1,L.ReminderEvery2Sec," %d"},
		{nil,L.ReminderEvery1Sec," %.1f"},
		{3,L.ReminderEveryHalfSec," %.2f"},
	},
	sounds = {
		{"TTS","Text-to-Speech"},
		{"1",L.ReminderSoundMajor},
		{"2",L.ReminderSoundMinor},
		{"3",L.ReminderSoundMajorDebuff},
		{"4",L.ReminderSoundPersonalSave},
		{"5",L.ReminderSoundMove},
		{"6",L.ReminderSoundAlert},
	},
	messageSize = {
		{nil,L.ReminderDefText},
		{2,L.ReminderBigText},
		{3,L.ReminderSmallText},
		{12,L.ReminderProgressBar},
		{13,L.ReminderProgressBarSmall},
		{14,L.ReminderProgressBarBig},
		{4,L.ReminderMsgSay},
		{5,L.ReminderMsgYell},
		{8,L.ReminderMsgRaid},
		{11,L.ReminderMsgTextPers},
		{6,L.ReminderMsgNameplate},
		{7,L.ReminderMsgNameplateText},
		{9,L.ReminderMsgRaidFrame},
		{10,L.ReminderMsgWA,"Custom event MRT_REMINDER_EVENT"},
	},
	bossDiff = {
		{nil,ALL},
		{14,PLAYER_DIFFICULTY1 or "Normal"},
		{15,PLAYER_DIFFICULTY2 or "HC"},
		{16,PLAYER_DIFFICULTY6 or "Mythic"},
	},
	rolesList = {
		{1,L.ReminderTanks,"TANK",1},
		{2,L.ReminderHealers,"HEALER",2},
		{3,L.ReminderDD,"DAMAGER",4},
		{4,L.ReminderRDD,"RDD",8},
		{5,L.ReminderMDD,"MDD",16},
		{7,L.ReminderRHEALER,"RHEALER",32},
		{8,L.ReminderMHEALER,"MHEALER",64},
	},
	events = {
		1,2,3,6,7,4,5,11,8,9,10,12,13,14,15,16,17,20,18,19,21,
	},
	counterBehavior = {
		{nil,L.ReminderGlobalCounter,L.ReminderGlobalCounterTip},
		{1,L.ReminderCounterSource,L.ReminderCounterSourceTip},
		{2,L.ReminderCounterDest,L.ReminderCounterDestTip},
		{3,L.ReminderCounterTriggers,L.ReminderCounterTriggersTip},
		{4,L.ReminderCounterTriggersPersonal,L.ReminderCounterTriggersPersonalTip},
		{5,L.ReminderCounterGlobal,L.ReminderCounterGlobalTip},
		{6,L.ReminderCounterReset5,L.ReminderCounterReset5Tip},
	},
	units = {
		{nil,"-"},
		{"player",STATUS_TEXT_PLAYER or "Player"},
		{"target",TARGET or "Target"},
		{"focus",L.ReminderFocus},
		{"mouseover",L.ReminderMouseover},
		{"boss1"},
		{"boss2"},
		{"boss3"},
		{"boss4"},
		{"boss5"},
		{"boss6"},
		{"boss7"},
		{"boss8"},
		{"pet",PET or "Pet"},
		{1,L.ReminderAnyBoss},
		{2,L.ReminderAnyNameplate},
		{3,L.ReminderAnyRaid},
		{4,L.ReminderAnyParty},
	},
	marks = {
		{nil,"-"},
		{0,L.ReminderNoMark},
		{1,ExRT.F.GetRaidTargetText(1,20)},
		{2,ExRT.F.GetRaidTargetText(2,20)},
		{3,ExRT.F.GetRaidTargetText(3,20)},
		{4,ExRT.F.GetRaidTargetText(4,20)},
		{5,ExRT.F.GetRaidTargetText(5,20)},
		{6,ExRT.F.GetRaidTargetText(6,20)},
		{7,ExRT.F.GetRaidTargetText(7,20)},
		{8,ExRT.F.GetRaidTargetText(8,20)},
		{9,ExRT.F.GetRaidTargetText(9,20)},
		{10,ExRT.F.GetRaidTargetText(10,20)},
		{11,ExRT.F.GetRaidTargetText(11,20)},
		{12,ExRT.F.GetRaidTargetText(12,20)},
		{13,ExRT.F.GetRaidTargetText(13,20)},
		{14,ExRT.F.GetRaidTargetText(14,20)},
		{15,ExRT.F.GetRaidTargetText(15,20)},
		{16,ExRT.F.GetRaidTargetText(16,20)},
	},
	markToIndex = {
		[0] = 0,
		[0x1] = 1,
		[0x2] = 2,
		[0x4] = 3,
		[0x8] = 4,
		[0x10] = 5,
		[0x20] = 6,
		[0x40] = 7,
		[0x80] = 8,
		[0x100] = 9,
		[0x200] = 10,
		[0x400] = 11,
		[0x800] = 12,
		[0x1000] = 13,
		[0x2000] = 14,
		[0x4000] = 15,
		[0x8000] = 16,
		[0x10000] = 17,
		[0x20000] = 18,
	},
	unitsList = {
		{"boss1","boss2","boss3","boss4","boss5"},
		{"nameplate1","nameplate2","nameplate3","nameplate4","nameplate5","nameplate6","nameplate7","nameplate8","nameplate9","nameplate10",
		 "nameplate11","nameplate12","nameplate13","nameplate14","nameplate15","nameplate16","nameplate17","nameplate18","nameplate19","nameplate20",
		 "nameplate21","nameplate22","nameplate23","nameplate24","nameplate25","nameplate26","nameplate27","nameplate28","nameplate29","nameplate30",
		 "nameplate31","nameplate32","nameplate33","nameplate34","nameplate35","nameplate36","nameplate37","nameplate38","nameplate39","nameplate40"},
		{"raid1","raid2","raid3","raid4","raid5","raid6","raid7","raid8","raid9","raid10",
		 "raid11","raid12","raid13","raid14","raid15","raid16","raid17","raid18","raid19","raid20",
		 "raid21","raid22","raid23","raid24","raid25","raid26","raid27","raid28","raid29","raid30",
		 "raid31","raid32","raid33","raid34","raid35","raid36","raid37","raid38","raid39","raid40"},
		{"player","party1","party2","party3","party4"},
		ALL = {"boss1","boss2","boss3","boss4","boss5",
		 "nameplate1","nameplate2","nameplate3","nameplate4","nameplate5","nameplate6","nameplate7","nameplate8","nameplate9","nameplate10",
		 "nameplate11","nameplate12","nameplate13","nameplate14","nameplate15","nameplate16","nameplate17","nameplate18","nameplate19","nameplate20",
		 "nameplate21","nameplate22","nameplate23","nameplate24","nameplate25","nameplate26","nameplate27","nameplate28","nameplate29","nameplate30",
		 "nameplate31","nameplate32","nameplate33","nameplate34","nameplate35","nameplate36","nameplate37","nameplate38","nameplate39","nameplate40",
		 "raid1","raid2","raid3","raid4","raid5","raid6","raid7","raid8","raid9","raid10",
		 "raid11","raid12","raid13","raid14","raid15","raid16","raid17","raid18","raid19","raid20",
		 "raid21","raid22","raid23","raid24","raid25","raid26","raid27","raid28","raid29","raid30",
		 "raid31","raid32","raid33","raid34","raid35","raid36","raid37","raid38","raid39","raid40",
		 "player","party1","party2","party3","party4"},
		ALL_FRIENDLY = {"raid1","raid2","raid3","raid4","raid5","raid6","raid7","raid8","raid9","raid10",
		 "raid11","raid12","raid13","raid14","raid15","raid16","raid17","raid18","raid19","raid20",
		 "raid21","raid22","raid23","raid24","raid25","raid26","raid27","raid28","raid29","raid30",
		 "raid31","raid32","raid33","raid34","raid35","raid36","raid37","raid38","raid39","raid40",
		"player","party1","party2","party3","party4"},
	},
	fields = {
		"eventCLEU","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","targetRole",
		"spellID","spellName","extraSpellID","stacks","numberPercent","pattFind","bwtimeleft","counter","cbehavior","delayTime","activeTime","invert","guidunit","onlyPlayer",
	},
	glowTypes = {
		{nil,L.ReminderFormatTipNameplateGlowTypeDef},
		{1,L.ReminderFormatTipNameplateGlowType1},
		{2,L.ReminderFormatTipNameplateGlowType2},
		{3,L.ReminderFormatTipNameplateGlowType3},
		{4,L.ReminderAIM},
		{5,L.ReminderSolidColor},
		{6,L.ReminderCustomIconAbove},
		{7,L.ReminderHealthPer},
	},
	glowImages = {
		{nil,"-"},
		{1,"Target mark",[[Interface\AddOns\MRT\media\Textures\target_indicator.tga]],100,50,{0,1,0,0.5}},
		{4,"Target mark 2",[[Interface\AddOns\MRT\media\Textures\targeting-mark.tga]]},
		{2,"Jesus",[[Interface\Addons\MRT\media\Textures\Aura113]]},
		{3,"Swords",[[Interface\Addons\MRT\media\Textures\Aura19]]},
		{5,"X",[[Interface\Addons\MRT\media\Textures\Aura118]]},
		{6,"STOP",[[Interface\Addons\MRT\media\Textures\Aura138]]},
		{7,"Logo",[[Interface\AddOns\MRT\media\OptionLogo2.tga]]},
		{8,"Boom",[[Interface\AddOns\MRT\media\deathstard.tga]]},
		{9,"BigWigs",[[Interface\AddOns\BigWigs\Media\Icons\core-enabled.tga]],64,64},
		{0,L.ReminderCustom},
	},
	glowImagesData = {},	--create later via func from <glowImages>
	vcountdowns = {
		{nil,"-"},
		{1,"English: Amy","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Amy\\"},
		{2,"English: David","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\David\\"},
		{3,"English: Jim","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Jim\\"},
		{4,"English: Default (Female)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\enUS\\female\\"},
		{5,"English: Default (Male)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\enUS\\male\\"},
		{6,"Deutsch: Standard (Female)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\deDE\\female\\"},
		{7,"Deutsch: Standard (Male)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\deDE\\male\\"},
		{8,"Español: Predeterminado (es) (Femenino)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\esES\\female\\"},
		{9,"Español: Predeterminado (es) (Masculino)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\esES\\male\\"},
		{10,"Español: Predeterminado (mx) (Femenino)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\esMX\\female\\"},
		{11,"Español: Predeterminado (mx) (Masculino)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\esMX\\male\\"},
		{12,"Français: Défaut (Femme)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\frFR\\female\\"},
		{13,"Français: Défaut (Homme)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\frFR\\male\\"},
		{14,"Italiano: Predefinito (Femmina)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\itIT\\female\\"},
		{15,"Italiano: Predefinito (Maschio)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\itIT\\male\\"},
		{16,"Русский: По умолчанию (Женский)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\ruRU\\female\\"},
		{17,"Русский: По умолчанию (Мужской)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\ruRU\\male\\"},
		{18,"한국어: 기본 (여성)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\koKR\\female\\"},
		{19,"한국어: 기본 (남성)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\koKR\\male\\"},
		{20,"Português: Padrão (Feminino)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\ptBR\\female\\"},
		{21,"Português: Padrão (Masculino)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\ptBR\\male\\"},
		{22,"简体中文:默认 (女性)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\zhCN\\female\\"},
		{23,"简体中文:默认 (男性)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\zhCN\\male\\"},
		{24,"繁體中文:預設值 (女性)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\zhTW\\female\\"},
		{25,"繁體中文:預設值 (男性)","Interface\\AddOns\\"..GlobalAddonName.."\\Media\\Sounds\\Heroes\\zhTW\\male\\"},
	},
	vcdsounds = {},	--create later via func from <vcountdowns>
}

for _,v in pairs(module.datas.vcountdowns) do
	if v[3] then
		module.datas.vcdsounds[ v[1] ] = v[3]
	end
end
for _,v in pairs(module.datas.glowImages) do
	if v[3] then
		module.datas.glowImagesData[ v[1] ] = v
	end
end

module.C = {
	[1] = {
		id = 1,
		name = "COMBAT_LOG_EVENT_UNFILTERED",
		lname = L.ReminderCombatLog,
		events = "COMBAT_LOG_EVENT_UNFILTERED",
		isUntimed = false,
		isUnits = false,
		subEventField = "eventCLEU",
		subEvents = {
			"SPELL_CAST_START",
			"SPELL_CAST_SUCCESS",
			"SPELL_AURA_APPLIED",
			"SPELL_AURA_REMOVED",
			"SPELL_DAMAGE",
			"SPELL_PERIODIC_DAMAGE",
			"SWING_DAMAGE",
			"SPELL_HEAL",
			"SPELL_PERIODIC_HEAL",
			"SPELL_ABSORBED",
			"SPELL_ENERGIZE",
			"SPELL_MISSED",
			"UNIT_DIED",
			"SPELL_SUMMON",
			"SPELL_INTERRUPT",
			"SPELL_DISPEL",
			"SPELL_AURA_BROKEN_SPELL",
			"ENVIRONMENTAL_DAMAGE",
		},
		triggerFields = {"eventCLEU"},
		alertFields = {"eventCLEU"},
	},
	["SPELL_CAST_START"] = {
		main_id = 1,
		subID = 1,
		lname = L.ReminderCastStart,
		events = {"SPELL_CAST_START","SPELL_EMPOWER_START"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","sourceID","sourceMark","spellName","invert"},
		replaceres = {"sourceName","sourceMark","sourceGUID","spellName","spellID","counter","guid"},
	},
	["SPELL_CAST_SUCCESS"] = {
		main_id = 1,
		subID = 2,
		lname = L.ReminderCastDone,
		events = {"SPELL_CAST_SUCCESS","SPELL_EMPOWER_END"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","targetRole","guidunit","onlyPlayer","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","invert","guidunit","onlyPlayer","targetRole"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","counter","guid"},
	},
	["SPELL_AURA_APPLIED"] = {
		main_id = 1,
		subID = 3,
		lname = L.ReminderAuraAdd,
		events = {"SPELL_AURA_APPLIED","SPELL_AURA_APPLIED_DOSE"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","targetRole","guidunit","stacks","onlyPlayer","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","stacks","invert","guidunit","onlyPlayer","targetRole"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","stacks","counter","guid"},
	},
	["SPELL_AURA_REMOVED"] = {
		main_id = 1,
		subID = 4,
		lname = L.ReminderAuraRem,
		events = {"SPELL_AURA_REMOVED","SPELL_AURA_REMOVED_DOSE"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","targetRole","guidunit","stacks","onlyPlayer","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","stacks","invert","guidunit","onlyPlayer","targetRole"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","stacks","counter","guid"},
	},
	["SPELL_DAMAGE"] = {
		main_id = 1,
		subID = 5,
		lname = L.ReminderSpellDamage,
		events = {"SPELL_DAMAGE","RANGE_DAMAGE"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","extraSpellID",extraSpellID=L.ReminderReplacerextraSpellIDSpellDmg,"counter","guid"},
	},
	["SPELL_PERIODIC_DAMAGE"] = {
		main_id = 1,
		subID = 6,
		lname = L.ReminderSpellDamageTick,
		events = "SPELL_PERIODIC_DAMAGE",
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","extraSpellID",extraSpellID=L.ReminderReplacerextraSpellIDSpellDmg,"counter","guid"},
	},
	["SWING_DAMAGE"] = {
		main_id = 1,
		subID = 7,
		lname = L.ReminderMeleeDamage,
		events = "SWING_DAMAGE",
		triggerFields = {"eventCLEU","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellID",spellID=L.ReminderReplacerspellIDSwing,"counter","guid"},
	},
	["SPELL_HEAL"] = {
		main_id = 1,
		subID = 8,
		lname = L.ReminderSpellHeal,
		events = "SPELL_HEAL",
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","extraSpellID",extraSpellID=L.ReminderReplacerextraSpellIDSpellDmg,"counter","guid"},
	},
	["SPELL_PERIODIC_HEAL"] = {
		main_id = 1,
		subID = 9,
		lname = L.ReminderSpellHealTick,
		events = "SPELL_PERIODIC_HEAL",
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","extraSpellID",extraSpellID=L.ReminderReplacerextraSpellIDSpellDmg,"counter","guid"},
	},
	["SPELL_ABSORBED"] = {
		main_id = 1,
		subID = 10,
		lname = L.ReminderSpellAbsorb,
		events = "SPELL_ABSORBED",
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","extraSpellID",extraSpellID=L.ReminderReplacerextraSpellIDSpellDmg,"counter","guid"},
	},
	["SPELL_ENERGIZE"] = {
		main_id = 1,
		subID = 11,
		lname = L.ReminderCLEUEnergize,
		events = {"SPELL_ENERGIZE","SPELL_PERIODIC_ENERGIZE"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","extraSpellID",extraSpellID=L.ReminderReplacerextraSpellIDSpellDmg,"counter","guid"},
	},
	["SPELL_MISSED"] = {
		main_id = 1,
		subID = 12,
		lname = L.ReminderCLEUMiss,
		events = {"SPELL_MISSED","RANGE_MISSED","SPELL_PERIODIC_MISSED"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","pattFind","counter","cbehavior","delayTime","activeTime","invert"},
		fieldNames = {["pattFind"]=L.ReminderMissType},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","pattFind","sourceID","sourceMark","targetID","targetMark","spellName","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","counter","guid"},
	},
	["UNIT_DIED"] = {
		main_id = 1,
		subID = 13,
		lname = L.ReminderDeath,
		events = {"UNIT_DIED","UNIT_DESTROYED"},
		triggerFields = {"eventCLEU","targetName","targetID","targetUnit","targetMark","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","counter","cbehavior","delayTime","activeTime","targetName","targetUnit","targetID","targetMark","invert"},
		replaceres = {"targetName","targetMark","targetGUID","counter","guid"},
	},
	["SPELL_SUMMON"] = {
		main_id = 1,
		subID = 14,
		lname = L.ReminderSummon,
		events = {"SPELL_SUMMON","SPELL_CREATE"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","counter","guid"},
	},
	["SPELL_DISPEL"] = {
		main_id = 1,
		subID = 15,
		lname = L.ReminderDispel,
		events = {"SPELL_DISPEL","SPELL_STOLEN"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","extraSpellID","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","extraSpellID","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","extraSpellID","counter","guid"},
	},
	["SPELL_AURA_BROKEN_SPELL"] = {
		main_id = 1,
		subID = 16,
		lname = L.ReminderCCBroke,
		events = {"SPELL_AURA_BROKEN_SPELL","SPELL_AURA_BROKEN"},
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","extraSpellID","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","extraSpellID","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","extraSpellID",extraSpellID=L.ReminderReplacerextraSpellID,"counter","guid"},
	},
	["ENVIRONMENTAL_DAMAGE"] = {
		main_id = 1,
		subID = 17,
		lname = L.ReminderEnvDamage,
		events = "ENVIRONMENTAL_DAMAGE",
		triggerFields = {"eventCLEU","spellID","targetName","targetID","targetUnit","targetMark","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","targetName","targetUnit","targetID","targetMark","invert"},
		replaceres = {"targetName","targetMark","targetGUID","spellName","counter","guid"},
	},
	["SPELL_INTERRUPT"] = {
		main_id = 1,
		subID = 18,
		lname = L.ReminderInterrupt,
		events = "SPELL_INTERRUPT",
		triggerFields = {"eventCLEU","spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","extraSpellID","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"eventCLEU","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","spellName","extraSpellID","invert","guidunit"},
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","extraSpellID","counter","guid"},
	},
	[2] = {
		id = 2,
		name = "BOSS_PHASE",
		lname = L.ReminderBossPhase,
		events = {"BigWigs_Message","BigWigs_SetStage","DBM_SetStage"},
		isUntimed = true,
		isUnits = false,
		triggerFields = {"pattFind","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"pattFind"},
		fieldNames = {["pattFind"]=L.ReminderBossPhaseLabel},
		triggerSynqFields = {"pattFind","counter","cbehavior","delayTime","activeTime","invert"},
		help = L.ReminderBossPhaseTip,
		replaceres = {"phase","counter"},
	},
	[3] = {
		id = 3,
		name = "BOSS_START",
		lname = L.ReminderBossPull,
		isUntimed = false,
		isUnits = false,
		triggerFields = {"delayTime","activeTime","invert"},
		triggerSynqFields = {"delayTime","activeTime","invert"},
	},
	[4] = {
		id = 4,
		name = "UNIT_HEALTH",
		lname = L.ReminderHealth,
		events = "UNIT_HEALTH",
		isUntimed = true,
		isUnits = true,
		unitField = "targetUnit",
		triggerFields = {"targetName","targetID", "targetUnit", "targetMark","numberPercent","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"numberPercent","targetUnit"},
		triggerSynqFields = {"numberPercent","targetUnit","counter","cbehavior","delayTime","activeTime","targetName","targetID","targetMark","invert"},
		help = L.ReminderHealthTip,
		replaceres = {"targetName","targetMark","guid",guid=L.ReminderReplacertargetGUID,"health","value","counter"},
	},
	[5] = {
		id = 5,
		name = "UNIT_POWER_FREQUENT",
		lname = L.ReminderMana,
		events = "UNIT_POWER_FREQUENT",
		isUntimed = true,
		isUnits = true,
		unitField = "targetUnit",
		triggerFields = {"targetName","targetID", "targetUnit", "targetMark","numberPercent","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"numberPercent","targetUnit"},
		triggerSynqFields = {"numberPercent","targetUnit","counter","cbehavior","delayTime","activeTime","targetName","targetID","targetMark","invert"},
		help = L.ReminderManaTip,
		replaceres = {"targetName","targetMark","guid",guid=L.ReminderReplacertargetGUID,"health",health=L.ReminderReplacerhealthenergy,"value",value=L.ReminderReplacervalueenergy,"counter"},
	},
	[6] = {
		id = 6,
		name = "BW_MSG",
		lname = L.ReminderBWMsg,
		events = {"BigWigs_Message","DBM_Announce"},
		isUntimed = false,
		isUnits = false,
		triggerFields = {"pattFind","spellID","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {0,"pattFind","spellID"},
		triggerSynqFields = {"spellID","pattFind","counter","cbehavior","delayTime","activeTime","invert"},
		replaceres = {"spellID","spellName",spellName=L.ReminderReplacerspellNameBWMsg,"counter"},
	},
	[7] = {
		id = 7,
		name = "BW_TIMER",
		lname = L.ReminderBWTimer,
		events = {"BigWigs_StartBar","BigWigs_StopBar","BigWigs_PauseBar","BigWigs_ResumeBar","BigWigs_StopBars","BigWigs_OnBossDisable","DBM_TimerStart","DBM_TimerStop","DBM_TimerPause","DBM_TimerResume","DBM_TimerUpdate","DBM_kill","DBM_kill"},
		isUntimed = false,
		isUnits = false,
		extraDelayTable = true,
		triggerFields = {"pattFind","spellID","bwtimeleft","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"bwtimeleft",0,"pattFind","spellID"},
		triggerSynqFields = {"bwtimeleft","spellID","pattFind","counter","cbehavior","delayTime","activeTime","invert"},
		replaceres = {"spellID","spellName",spellName=L.ReminderReplacerspellNameBWTimer,"timeLeft","counter"},
	},
	[8] = {
		id = 8,
		name = "CHAT_MSG",
		lname = L.ReminderChat,
		events = {"CHAT_MSG_RAID_WARNING","CHAT_MSG_MONSTER_YELL","CHAT_MSG_MONSTER_EMOTE","CHAT_MSG_MONSTER_SAY","CHAT_MSG_MONSTER_WHISPER","CHAT_MSG_RAID_BOSS_EMOTE","CHAT_MSG_RAID_BOSS_WHISPER","CHAT_MSG_RAID","CHAT_MSG_RAID_LEADER","CHAT_MSG_PARTY","CHAT_MSG_PARTY_LEADER","CHAT_MSG_WHISPER"},
		isUntimed = false,
		isUnits = false,
		triggerFields = {"pattFind","sourceName","sourceID","sourceUnit","targetName","targetUnit","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"pattFind"},
		triggerSynqFields = {"pattFind","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","targetUnit","sourceID","invert"},
		replaceres = {"sourceName","targetName","text","counter"},
	},
	[9] = {
		id = 9,
		name = "INSTANCE_ENCOUNTER_ENGAGE_UNIT",
		lname = L.ReminderBossFrames,
		events = "INSTANCE_ENCOUNTER_ENGAGE_UNIT",
		isUntimed = false,
		isUnits = false,
		triggerFields = {"targetName","targetID","targetUnit","counter","cbehavior","delayTime","activeTime","invert"},
		triggerSynqFields = {"counter","cbehavior","delayTime","activeTime","targetName","targetUnit","targetID","invert"},
		replaceres = {"targetName","guid",guid=L.ReminderReplacertargetGUID,"counter"},
	},
	[10] = {
		id = 10,
		name = "UNIT_AURA",
		lname = L.ReminderAura,
		events = "UNIT_AURA",
		isUntimed = true,
		isUnits = true,
		extraDelayTable = true,
		unitField = "targetUnit",
		triggerFields = {"spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","targetRole","stacks","bwtimeleft","onlyPlayer","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"targetUnit",0,"spellID","spellName"},
		triggerSynqFields = {"targetUnit","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceUnit","targetName","sourceID","sourceMark","targetID","targetMark","spellName","stacks","bwtimeleft","invert","onlyPlayer","targetRole"},
		help = L.ReminderAuraTip,
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","spellName","spellID","stacks","timeLeft","counter","guid","auraValA","auraValB","auraValC"},
	},
	[11] = {
		id = 11,
		name = "UNIT_ABSORB_AMOUNT_CHANGED",
		lname = L.ReminderAbsorb,
		events = "UNIT_ABSORB_AMOUNT_CHANGED",
		isUntimed = true,
		isUnits = true,
		unitField = "targetUnit",
		triggerFields = {"targetName","targetID", "targetUnit", "targetMark","numberPercent","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"numberPercent","targetUnit"},
		fieldNames = {["numberPercent"]=L.ReminderAbsorbLabel},
		triggerSynqFields = {"numberPercent","targetUnit","counter","cbehavior","delayTime","activeTime","targetName","targetID","targetMark","invert"},
		help = L.ReminderAbsorbTip,
		replaceres = {"targetName","targetMark","guid",guid=L.ReminderReplacertargetGUID,"value",value=L.ReminderReplacervalueabsorb,"counter"},
	},
	[12] = {
		id = 12,
		name = "UNIT_TARGET",
		lname = L.ReminderCurTarget,
		events = {"UNIT_TARGET","UNIT_THREAT_LIST_UPDATE"},
		isUntimed = true,
		isUnits = true,
		unitField = "sourceUnit",
		triggerFields = {"sourceName","sourceID","sourceUnit","sourceMark","targetName","targetID","targetUnit","targetMark","guidunit","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"sourceUnit"},
		triggerSynqFields = {"sourceUnit","counter","cbehavior","delayTime","activeTime","sourceName","targetName","targetUnit","sourceID","sourceMark","targetID","targetMark","invert","guidunit"},
		help = L.ReminderCurTargetTip,
		replaceres = {"sourceName","sourceMark","sourceGUID","targetName","targetMark","targetGUID","counter","guid"},
	},
	[13] = {
		id = 13,
		name = "CDABIL",
		lname = L.ReminderSpellCD,
		events = "SPELL_UPDATE_COOLDOWN",
		tooltip = L.ReminderSpellCDTooltip,
		isUntimed = true,
		isUnits = false,
		triggerFields = {"spellID","spellName","bwtimeleft","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {0,"spellID","spellName"},
		triggerSynqFields = {"spellID","counter","cbehavior","delayTime","activeTime","spellName","bwtimeleft","invert"},
		help = L.ReminderSpellCDTip,
		replaceres = {"spellName","spellID","counter","timeLeft"},
	},
	[14] = {
		id = 14,
		name = "UNIT_SPELLCAST_SUCCEEDED",
		lname = L.ReminderSpellCastDone,
		events = "UNIT_SPELLCAST_SUCCEEDED",
		tooltip = L.ReminderSpellCastDoneTooltip,
		isUntimed = false,
		isUnits = true,
		unitField = "sourceUnit",
		triggerFields = {"spellID","spellName","sourceName","sourceID","sourceUnit","sourceMark","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"sourceUnit"},
		triggerSynqFields = {"sourceUnit","spellID","counter","cbehavior","delayTime","activeTime","sourceName","sourceID","sourceMark","spellName","invert"},
		replaceres = {"sourceName","sourceMark","guid",guid=L.ReminderReplacersourceGUID,"spellID","spellName","counter"},
	},
	[15] = {
		id = 15,
		name = "UPDATE_UI_WIDGET",
		lname = L.ReminderWidget,
		events = "UPDATE_UI_WIDGET",
		isUntimed = true,
		isUnits = false,
		triggerFields = {"spellID","spellName","numberPercent","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"numberPercent",0,"spellID","spellName"},
		fieldNames = {["spellID"]=L.ReminderWidgetLabelID,["spellName"]=L.ReminderWidgetLabelName},
		triggerSynqFields = {"numberPercent","spellID","counter","cbehavior","delayTime","activeTime","spellName","invert"},
		help = L.ReminderWidgetTip,
		replaceres = {"spellID",spellID=L.ReminderReplacerspellIDwigdet,"spellName",spellName=L.ReminderReplacerspellNamewigdet,"value",value=L.ReminderReplacervaluewigdet,"counter"},
	},
	[16] = {
		id = 16,
		name = "PARTY_UNIT",
		lname = L.ReminderRaidPartyUnit,
		events = "GROUP_ROSTER_UPDATE",
		isUntimed = true,
		isUnits = true,
		unitField = "",
		triggerFields = {"targetName","pattFind"},
		fieldNames = {["pattFind"]=L.ReminderNotePatt..":"},
		triggerSynqFields = {"targetName","pattFind"},
		help = L.ReminderRaidPartyUnitTip,
		replaceres = {"targetName","guid",guid=L.ReminderReplacertargetGUID},		
	},
	[17] = {
		id = 17,
		name = "PLAYERS_IN_RANGE",
		lname = L.ReminderPlayersInRange,
		events = "TIMER",
		isUntimed = true,
		triggerFields = {"bwtimeleft","stacks","invert"},
		fieldNames = {["bwtimeleft"]=L.ReminderPlayersInRangeRange,["stacks"]=L.ReminderPlayersInRangeNumber},
		fieldTooltips = {["bwtimeleft"]=L.ReminderPlayersInRangeTip2:format("0-5, 5-6, 6-7, 7-8, 8-10, 10-13, 13-18, 18-22, 22-28, 28-30, 30-40, 40-50, 50-60, 60-80")},
		alertFields = {"bwtimeleft","stacks"},
		triggerSynqFields = {"bwtimeleft","stacks","invert"},
		help = L.ReminderPlayersInRangeTip,
		replaceres = {"value",value=L.ReminderReplacervaluerange,"list"},
	},
	[18] = {
		id = 18,
		name = "UNIT_CAST",
		lname = L.ReminderUnitCast,
		events = {"UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_STOP"},
		isUntimed = true,
		isUnits = true,
		unitField = "sourceUnit",
		triggerFields = {"sourceName","sourceID", "sourceUnit", "sourceMark","spellID","spellName","counter","cbehavior","delayTime","activeTime","invert"},
		alertFields = {"sourceUnit"},
		triggerSynqFields = {"spellID","sourceUnit","counter","cbehavior","delayTime","activeTime","sourceName","spellName","sourceID","sourceMark","invert"},
		help = L.ReminderUnitCastTip,
		replaceres = {"sourceName","sourceMark","guid",guid=L.ReminderReplacersourceGUID,"spellID","spellName","timeLeft"},
	},
	[19] = {
		id = 19,
		name = "NOTE_TIMERS",
		lname = L.ReminderNoteTimers,
		isUntimed = true,
		events = {"BigWigs_Message","BigWigs_SetStage","DBM_SetStage","COMBAT_LOG_EVENT_UNFILTERED"},
		triggerFields = {"bwtimeleft","activeTime","pattFind","invert"},
		fieldNames = {["pattFind"]=(FILTER or "Filter")..":"},
		fieldTooltips = {["pattFind"]=L.ReminderNoteTimersFilter},
		triggerSynqFields = {"bwtimeleft","activeTime","invert","pattFind"},
		help = L.ReminderNoteTimersTip,
		replaceres = {"text",text=L.ReminderReplacertextnotetimers,"textLeft","textModIcon:X:Y",value=L.ReminderReplacerlistmobrange,"fullLine","fullLineClear","phase"},
	},
	[20] = {
		id = 20,
		name = "MOBS_IN_RANGE",
		lname = L.ReminderMobInRange,
		events = "TIMER",
		isUntimed = true,
		triggerFields = {"bwtimeleft","stacks","targetName","targetID","targetUnit","targetMark","invert"},
		fieldNames = {["bwtimeleft"]=L.ReminderPlayersInRangeRange,["stacks"]=L.ReminderMobInRangeNumber},
		fieldTooltips = {["bwtimeleft"]=L.ReminderPlayersInRangeTip2:format("0-2, 2-3, 3-4, 4-5, 5-7, 7-8, 8-10, 10-15, 15-20, 20-25, 25-30, 30-35, 35-38, 39-40,\n40-45, 45-50, 50-55, 55-60, 60-70, 70-80, 80-90, 90-100, 100-150, 150-200")},
		alertFields = {"bwtimeleft","stacks","targetUnit"},
		triggerSynqFields = {"bwtimeleft","stacks","targetName","targetID","targetUnit","targetMark","invert"},
		help = L.ReminderPlayersInRangeTip,
		replaceres = {"value",value=L.ReminderReplacervaluemobrange,"list",value=L.ReminderReplacerlistmobrange,"targetName","targetMark","guid",guid=L.ReminderReplacertargetGUID},
	},
	[21] = {
		id = 21,
		name = "NOTE_TIMERS_ALL",
		lname = L.ReminderNoteTimersAll,
		isUntimed = true,
		events = {"BigWigs_Message","BigWigs_SetStage","DBM_SetStage","COMBAT_LOG_EVENT_UNFILTERED"},
		triggerFields = {"bwtimeleft","activeTime","pattFind","invert"},
		fieldNames = {["pattFind"]=(FILTER or "Filter")..":"},
		fieldTooltips = {["pattFind"]=L.ReminderNoteTimersFilter},
		triggerSynqFields = {"bwtimeleft","activeTime","invert","pattFind"},
		help = L.ReminderNoteTimersAllTip,
		replaceres = {"text",text=L.ReminderReplacertextnotetimers,"textLeft","textModIcon:X:Y",value=L.ReminderReplacerlistmobrange,"fullLine","fullLineClear","phase"},
	},
}

CreateListOfReplacers()

function module:FindPlayerInNote(pat)
	local reverse = pat:find("^%-")
	local playerName = ExRT.SDB.charName
	pat = "^"..pat:gsub("^%-",""):gsub("([%.%(%)%-%$])","%%%1")
	if not VMRT or not VMRT.Note or not VMRT.Note.Text1 then
		return
	end
	local lines = GetMRTNoteLines()
	for i=1,#lines do
		if lines[i]:find(pat) then
			local l = lines[i]:gsub(pat.." *",""):gsub("|c........",""):gsub("|r",""):gsub(" *$",""):gsub("|",""):gsub(" +"," ")
			local list = {strsplit(" ", l)}
			for j=1,#list do
				if list[j] == playerName then
					if reverse then
						return false, lines[i]
					else
						return true, lines[i]
					end
				end
			end
		end
	end
	if reverse then
		return true
	else
		return false
	end
end

function module:FindPlayersListInNote(pat)
	pat = "^"..pat:gsub("([%.%(%)%-%$])","%%%1")
	if not VMRT or not VMRT.Note or not VMRT.Note.Text1 then
		return
	end
	local lines = GetMRTNoteLines()
	local res
	for i=1,#lines do
		if lines[i]:find(pat) then
			local l = lines[i]:gsub(pat.." *",""):gsub("|c........",""):gsub("|r",""):gsub(" *$",""):gsub("|",""):gsub(" +"," ")
			if not res then res = "" end
			res = res..(res ~= "" and " " or "")..l
		end
	end
	return res
end

function module:GetUnitRole(unit)
	local role = UnitGroupRolesAssigned(unit)
	if role == "HEALER" then
		local _,class = UnitClass(unit)
		return role, (class == "PALADIN" or class == "MONK") and "MHEALER" or "RHEALER"
	elseif role ~= "DAMAGER" then
		--TANK, NONE
		return role
	else
		local _,class = UnitClass(unit)
		local isMelee = (class == "WARRIOR" or class == "PALADIN" or class == "ROGUE" or class == "DEATHKNIGHT" or class == "MONK" or class == "DEMONHUNTER")
		if class == "DRUID" then
			isMelee = not (UnitPowerType(unit) == 8)	--astral power
		elseif class == "SHAMAN" then
			isMelee = not ((ExRT.A.Inspect and UnitName(unit) and ExRT.A.Inspect.db.inspectDB[UnitName(unit)] and ExRT.A.Inspect.db.inspectDB[UnitName(unit)].spec) == 262)
		elseif class == "HUNTER" then
			isMelee = (ExRT.A.Inspect and UnitName(unit) and ExRT.A.Inspect.db.inspectDB[UnitName(unit)] and ExRT.A.Inspect.db.inspectDB[UnitName(unit)].spec) == 255
		end
		if isMelee then
			return role, "MDD"
		else
			return role, "RDD"
		end
	end
end

-- enh shaman can't be checked, always ranged
function module:CmpUnitRole(unit,roleIndex)
	if not UnitGUID(unit) then return end
	local mainRole, subRole = module:GetUnitRole(unit)

	local sub = ExRT.F.table_find3(module.datas.rolesList,subRole,3)
	if sub and (roleIndex == sub[1] or (roleIndex >= 100 and bit.band(roleIndex - 100,sub[4]) > 0)) then
		return true
	end

	local main = ExRT.F.table_find3(module.datas.rolesList,mainRole,3)
	if main and (roleIndex == main[1] or (roleIndex >= 100 and bit.band(roleIndex - 100,main[4]) > 0)) then
		return true
	end

	if roleIndex == 6 and main ~= "TANK" then	--not tank role, hardcoded
		return true
	end
end

function module:GetRoleIndex()
	local mainRole, subRole = ExRT.F.GetPlayerRole()

	local sub = ExRT.F.table_find3(module.datas.rolesList,subRole,3)
	if sub then
		return sub[1]
	end

	local main = ExRT.F.table_find3(module.datas.rolesList,mainRole,3)
	if main then
		return main[1]
	else
		return 0
	end
end

local function ConvertNumToBit(num, base)
	local r = "" 
	base = math.max(base, 36)
	while num ~= 0 do 
		local n = num % base 
		num = floor(num/base) 
		if n >= 10 then 
			r = string.char( n - 10 + 65)..r 
		else 
			r = n .. r 
		end 
	end 
	if r == "" then
		return "0"
	else
		return r
	end
end

function module:ConvertTo36Bit(num)
	return ConvertNumToBit(num or 0, 36)
end

function module.options:Load()
	self:CreateTilte()

	ExRT.lib:Text(self,"v."..addonVersion.." beta",10):Point("BOTTOMLEFT",self.title,"BOTTOMRIGHT",5,2)

	local encountersList = ExRT.F.GetEncountersList(true,false,true)

	local function GetEncounterSortIndex(id,unk)
		for i=1,#encountersList do
			local dung = encountersList[i]
			for j=2,#dung do
				if id == dung[j] then
					return i * 100 + (#dung - j)
				end
			end
		end
		return unk
	end

	local function GetMapNameByID(mapID)
		return (C_Map.GetMapInfo(mapID or 0) or {}).name or ("Map ID "..mapID)
	end

	local newRemainderTemplate = {
		triggers = {
			{
				event = 3,
			},
		},
		dur = 2,
		players = {},
		allPlayers = true,
	}

	local function AlertIcon_OnEnter(self)
		if not self.tooltip then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		if self.tooltipTitle then
			GameTooltip:AddLine(self.tooltipTitle)
		end
		GameTooltip:AddLine(self.tooltip, nil, nil, nil, true)
		GameTooltip:Show()
	end
	local function AlertIcon_OnLeave(self)
		GameTooltip_Hide()
	end
	local function AlertIcon_SetType(self,typeNum)
		if typeNum == 1 then
			self.outterCircle:SetVertexColor(.7,.15,.08,1)
			self.innerCircle:SetVertexColor(.9,0,.24,1)
			self.tooltip = L.ReminderAlertFieldReq
		elseif typeNum == 2 then
			self.outterCircle:SetVertexColor(.75,.6,0,1)
			self.innerCircle:SetVertexColor(.95,.8,.1,1)
			self.tooltip = L.ReminderAlertFieldSome
		elseif typeNum == 3 then
			self.outterCircle:SetVertexColor(.5,.7,.7,1)
			self.innerCircle:SetVertexColor(.7,.9,.9,1)
			self.text:SetText("?")
		end
	end

	local function CreateAlertIcon(parent,tooltip,tooltipTitle,posRight,isButton)
		local self = CreateFrame(isButton and "Button" or "Frame",nil,parent)
		self:SetSize(20,20)

		local outterCircle = self:CreateTexture(nil,"BACKGROUND",nil,1)
		outterCircle:SetPoint("TOPLEFT")
		outterCircle:SetPoint("BOTTOMRIGHT")
		outterCircle:SetTexture([[Interface\AddOns\MRT\media\circle256]])
		outterCircle:SetVertexColor(.7,.15,.08,1)
		self.outterCircle = outterCircle

		local innerCircle = self:CreateTexture(nil,"BACKGROUND",nil,2)
		innerCircle:SetPoint("TOPLEFT",3,-3)
		innerCircle:SetPoint("BOTTOMRIGHT",-3,3)
		innerCircle:SetTexture([[Interface\AddOns\MRT\media\circle256]])
		innerCircle:SetVertexColor(.9,0,.24,1)
		self.innerCircle = innerCircle

		local text = self:CreateFontString(nil,"BACKGROUND","GameFontWhite",3)
		text:SetPoint("CENTER")
		text:SetFont(ExRT.F.defFont,14, "")
		text:SetText("!")
		text:SetShadowColor(0,0,0)
		text:SetShadowOffset(1,-1)
		self.text = text

		self:SetScript("OnEnter",AlertIcon_OnEnter)
		self:SetScript("OnLeave",AlertIcon_OnLeave)

		self.SetType = AlertIcon_SetType

		self.tooltip = tooltip
		self.tooltipTitle = tooltipTitle
		if posRight then
			self:SetPoint("LEFT",parent,"RIGHT",3,0)
		end

		self:Hide()

		return self
	end

	ELib:DecorationLine(self,true,"BACKGROUND",1):Point("TOPLEFT",self,0,-25):Point("BOTTOMRIGHT",self,"TOPRIGHT",0,-45)

	self.chkEnable = ELib:Check(self,L.Enable,VMRT.Reminder2.enabled):Point(560,-26):Size(18,18):AddColorState():TextButton():OnClick(function(self) 
		VMRT.Reminder2.enabled = self:GetChecked() 

		if VMRT.Reminder2.enabled then
			module:Enable()
		else
			module:Disable()
		end
	end)

	self.tab = ELib:Tabs(self,0,L.ReminderGlobal,L.ReminderPersonal,L.minimapmenuset):Point(0,-45):Size(698,570):SetTo(1)
	self.tab:SetBackdropBorderColor(0,0,0,0)
	self.tab:SetBackdropColor(0,0,0,0)

	function self.tab:buttonAdditionalFunc()
		if self.selected == 1 or self.selected == 2 then
			local prev = module.options.isPersonalTab
			module.options.isPersonalTab = nil
			if self.selected == 2 then
				module.options.isPersonalTab = true

				self.tabs[2]:Hide()
				self.tabs[1]:Show()
			end
			if prev ~= module.options.isPersonalTab then
				module.options:UpdateData()
				module.options.scrollList.ScrollBar.slider:SetValue(0)

				module.options.SyncButton:SetShown(self.selected == 1)
				module.options.ExportButton:SetShown(self.selected == 1)
				module.options.ImportButton:SetShown(self.selected == 1)
				module.options.CopyToButton:SetShown(self.selected == 1)
				module.options.ResetButton:SetShown(self.selected == 1)
				module.options.lastUpdate:SetShown(self.selected == 1)
			end
		end
	end


	self.scrollList = ELib:ScrollButtonsList(self.tab.tabs[1]):Point("TOP",0,-5):Size(690,530)
	self.scrollList.ButtonsInLine = 2
	ELib:Border(self.scrollList,0)

	self.searchEditBox = ELib:Edit(self.scrollList):Point("TOPLEFT",self,350,-27):Size(160,16):AddSearchIcon():OnChange(function (self,isUser)
		if not isUser then
			return
		end
		local text = self:GetText():lower()
		if text == "" then
			text = nil
		end
		module.options.search = text

		if self.scheduledUpdate then
			return
		end
		self.scheduledUpdate = C_Timer.NewTimer(.3,function()
			self.scheduledUpdate = nil
			module.options.scrollList.ScrollBar.slider:SetValue(0)
			module.options:UpdateData()
		end)
	end):Tooltip(SEARCH)
	self.searchEditBox:SetTextColor(0,1,0,1)


	self.profileDropDown = ELib:DropDown(self.scrollList,250,#profilesSorted+1):Point("BOTTOMLEFT",self.searchEditBox,"TOPLEFT",0,10):Size(160):SetText(profiles[VMRT.Reminder2.Profile]):AddText(L.InterruptsProfile..":")
	self.profileDropDown.leftText:SetFontObject("GameFontNormalSmall")
	self.profileDropDown.leftText:SetTextColor(1,.82,0)
	self.profileDropDown.leftText:SetFont(self.profileDropDown.leftText:GetFont(),10)

	local function SetProfile(_,arg1)
		module:SetProfile(arg1)
		ELib:DropDownClose()
	end
	for i=1,#profilesSorted do
		self.profileDropDown.List[i] = {text = profiles[ profilesSorted[i] ], arg1 = profilesSorted[i], func = SetProfile}
		if profilesSorted[i] == 0 then
			self.profileDropDown.List[i].tooltip = function()
				if VMRT.Reminder2.LastUpdateName then
					return L.NoteLastUpdate..": "..VMRT.Reminder2.LastUpdateName.." ("..date("%d.%m.%Y %H:%M",VMRT.Reminder2.LastUpdateTime or 0)..")"
				else
					return ""
				end
			end
		end
	end
	self.profileDropDown.List[#profilesSorted+1] = {text = L.minimapmenuclose,func = ELib.ScrollDropDown.Close}


	local function UpdateOption(uid,enable,optionBit)
		if not uid then return end
		local options = VMRT.Reminder2.options[uid] or 0
		if enable then
			if bit.band(options,optionBit) > 0 then
				options = bit.bxor(options,optionBit)
			end
		else
			options = bit.bor(options,optionBit)
		end
		if options == 0 then options = nil end
		VMRT.Reminder2.options[uid] = options
	end

	local function CopyOneReminder(_,profile,data)
		ELib.ScrollDropDown.Close()
		VMRT.Reminder2.data[profile][data.uid] = ExRT.F.table_copy2(data)
	end

	function self.scrollList:ButtonClick(button)
		local data = self.data
		if not data then
			return
		end
		if button == "RightButton" then
			if data.data then
				local copySubMenu = {}
				for i=1,#profilesSorted do
					copySubMenu[i] = {text = profiles[ profilesSorted[i] ], arg1 = profilesSorted[i], arg2 = data.data, func = CopyOneReminder, isTitle = VMRT.Reminder2.Profile == profilesSorted[i]}
				end
				local menu = {
					{ text = data.name or "~"..L.ReminderNoName, isTitle = true, notCheckable = true, notClickable = true },
					{ text = L.InterruptsCopyTo.."...", subMenu = copySubMenu},
					{ text = DELETE, func = function() ELib.ScrollDropDown.Close() module.options:RemoveReminder(data.data.uid) end, notCheckable = true },
					{ text = CLOSE, func = function() ELib.ScrollDropDown.Close() end, notCheckable = true },
				}
				ELib.ScrollDropDown.EasyMenu(self,menu,150)
			end
			return
		end
		local data2
		if data.isNew then
			data2 = ExRT.F.table_copy2(newRemainderTemplate)
			data2.bossID = data.bossIDnew
			data2.zoneID = data.zoneIDnew
			data2.uid = module.options:GetNewUID()
			if data.isPersonal then
				UpdateOption(data2.uid,false,bit.bor(bit.lshift(1,3),bit.lshift(1,2)))
			end
		else
			data2 = ExRT.F.table_copy2(data.data)
		end
		module.options.setupFrame:Update(data2)
		module.options.setupFrame:Show()
	end

	local function Button_OnOff_Click(self)
		local status = self.status
		if status == 1 then
			status = 2
		elseif status == 2 then
			status = 1
		end
		self.status = status
		self:Update(status)

		UpdateOption(self:GetParent().data.uid,status==1,bit.lshift(1,0))
		module:ReloadAll()
	end
	local function Button_OnOff_Update(self,status)
		if status == 1 then
			self.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
		elseif status == 2 then
			self.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
		end
	end

	local function Button_Sound_Click(self)
		local status = self.status
		if status == 1 then
			status = 2
		elseif status == 2 then
			status = 1
		end
		self.status = status
		self:Update(status)

		UpdateOption(self:GetParent().data.uid,status==1,bit.lshift(1,1))
	end
	local function Button_Sound_Update(self,status)
		if status == 1 then
			self.line:Hide()
		elseif status == 2 then
			self.line:Show()
		end
	end

	local function Button_Lock_Click(self)
		local status = self.status
		if status == 1 then
			status = 2
		elseif status == 2 then
			status = 1
		end
		self.status = status
		self:Update(status)

		UpdateOption(self:GetParent().data.uid,status==1,bit.lshift(1,2))
	end
	local function Button_Lock_Update(self,status)
		if status == 1 then
			self.texture:SetTexCoord(.6875,.7425,.5,.625)
		elseif status == 2 then
			self.texture:SetTexCoord(.625,.68,.5,.625)
		end
	end

	local function ButtonIcon_OnEnter(self)
		if not self["tooltip"..(self.status or 1)] then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local tip = self["tooltip"..(self.status or 1)]
		if type(tip) == "function" then
			tip = tip(self)
		end
		GameTooltip:AddLine(tip)
		GameTooltip:Show()
	end

	local function ButtonIcon_OnLeave(self)
		GameTooltip_Hide()
	end

	local function Button_Create(parent)
		local self = ELib:Button(parent,"",1):Size(20,20)
		self.texture = self:CreateTexture(nil,"ARTWORK")
		self.texture:SetPoint("CENTER")
		self.texture:SetSize(14,14)

		self.HighlightTexture = self:CreateTexture(nil,"BACKGROUND")
		self.HighlightTexture:SetColorTexture(1,1,1,.3)
		self.HighlightTexture:SetPoint("TOPLEFT")
		self.HighlightTexture:SetPoint("BOTTOMRIGHT")
		self:SetHighlightTexture(self.HighlightTexture)

		self:SetScript("OnEnter",ButtonIcon_OnEnter)
		self:SetScript("OnLeave",ButtonIcon_OnLeave)

		return self
	end

	local function Button_OnEnter(self)
		local data = self.data.data
		if not data then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine(data.name or "~"..L.ReminderNoName)
		GameTooltip:AddDoubleLine(L.ReminderMsg..":",module:FormatMsg(data.msg or ""))
		GameTooltip:AddDoubleLine(L.ReminderTriggersCount..":",#data.triggers)
		for i=1,#data.triggers do
			local trigger = data.triggers[i]
			local event = trigger.event
			local eventDB = module.C[event]
			if eventDB then
				if event == 1 then
					local spellText = ""
					if trigger.spellID then
						local spellName,_,spellTexture = GetSpellInfo(trigger.spellID)
						spellText = " "
						if spellTexture then
							spellText = "|T"..spellTexture..":0|t "
						end
						if spellName then
							spellText = spellText .. spellName
						end
					end
					GameTooltip:AddDoubleLine("  ["..i.."] "..L.ReminderCLEUShort..": "..(trigger.eventCLEU and module.C[trigger.eventCLEU] and module.C[trigger.eventCLEU].lname or ""),spellText)
				elseif event == 3 then
					GameTooltip:AddDoubleLine("  ["..i.."] "..eventDB.lname,(trigger.delayTime or ""))
				elseif event == 2 then
					GameTooltip:AddDoubleLine("  ["..i.."] "..eventDB.lname.." "..(trigger.pattFind or ""),(trigger.delayTime or ""))
				end
			end
		end
		if data.diffID then
			local diff = ExRT.F.table_find3(module.datas.bossDiff,data.diffID,1)
			GameTooltip:AddDoubleLine(L.ReminderRaidDiff..":",diff and diff[2] or "diffID "..data.diffID)
		end

		local c = 0
		local players = ""
		if not data.allPlayers then
			local playersTable = {}
			for k,v in pairs(data.players) do
				playersTable[#playersTable+1] = k
			end
			sort(playersTable)
			for _,v in ipairs(playersTable) do
				c = c + 1
				local _,class = UnitClass(v)
				local classColor
				if class then
					classColor = RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr
				end
				players = players .. (classColor or "") .. v .. (classColor and "|r" or "") .. ", " 
				if c % 5 == 0 then
					players = players:gsub(", $","")
					GameTooltip:AddDoubleLine(c <= 5 and TUTORIAL_TITLE19..":" or " ",players)
					players = ""
				end
			end
			players = players:gsub(", $","")
		end
		if data.allPlayers or players ~= "" then
			GameTooltip:AddDoubleLine(c <= 5 and TUTORIAL_TITLE19..":" or " ",data.allPlayers and L.ReminderAllPlayers or players)
		end
		if data.updatedName then
			GameTooltip:AddDoubleLine(L.ReminderUpdated..":",data.updatedName..date(" %x %X",data.updatedTime))
		end

		GameTooltip:Show()
	end
	local function Button_OnLeave(self)
		GameTooltip_Hide()
	end

	local function Button_Lvl1_Remove(self)
		StaticPopupDialogs["EXRT_REMINDER_CLEAR"] = {
			text = L.ReminderRemove.."?",
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				for uid,data in pairs(CURRENT_DATA) do
					if 
						bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,2)) == 0 and
						(
						 (bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,3)) == 0 and not module.options.isPersonalTab) or
						 (bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,3)) > 0 and module.options.isPersonalTab)
						) and
						(
						 (self.bossID and data.bossID == self.bossID) or 
						 (type(self.bossID)=="table" and self.bossID[data.bossID]) or 
						 (self.zoneID and module:FindNumberInString(self.zoneID,data.zoneID))
						)
					then
						CURRENT_DATA[uid] = nil
						VMRT.Reminder2.removed[uid] = time()
					end
				end
				module.options:UpdateData()
				module:ReloadAll()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_REMINDER_CLEAR")
	end
	local function Button_Lvl1_Export(self)
		local export = module:Sync(true,self.bossID,self.zoneID)

		module.options:ExportStr(export)
	end
	local function Button_Lvl1_Send(self)
		module:Sync(false,self.bossID,self.zoneID)
	end

	local function Button_Lvl2_SetTypeIcon(self,iconType)
		self.text:Hide()
		self.glow:Hide()
		self.glow2:Hide()
		self.bar:Hide()

		if iconType == 1 then
			self.text:FontSize(12)
			self.text:SetText("T")
			self.text:Show()
		elseif iconType == 2 then
			self.text:FontSize(18)
			self.text:SetText("T")
			self.text:Show()
		elseif iconType == 3 then
			self.text:FontSize(8)
			self.text:SetText("t")
			self.text:Show()
		elseif iconType == 4 then
			self.glow:Show()
		elseif iconType == 5 then
			self.glow2:Show()
		elseif iconType == 6 then
			self.text:FontSize(8)
			self.text:SetText("/say")
			self.text:Show()
		elseif iconType == 7 then
			self.text:FontSize(10)
			self.text:SetText("WA")
			self.text:Show()
		elseif iconType == 8 then
			self.bar:Show()
		end
	end

	function self.scrollList:ModButton(button,level)
		if level == 1 then
			local textObj = button:GetTextObj()
			textObj:SetPoint("LEFT",5+22+3,0)

			button.bossImg = button:CreateTexture(nil, "ARTWORK")
			button.bossImg:SetSize(22,22)
			button.bossImg:SetPoint("LEFT",5,0)

			button.dungImg = button:CreateTexture(nil, "ARTWORK")
			button.dungImg:SetPoint("TOPLEFT",20,0)
			button.dungImg:SetPoint("BOTTOMRIGHT",button,"BOTTOM",20,0)
			button.dungImg:SetAlpha(.7)

			button.remove = Button_Create(button):Point("RIGHT",button,"RIGHT",-30,0)
			button.remove:SetScript("OnClick",Button_Lvl1_Remove)
			button.remove.tooltip1 = L.ReminderRemoveSection
			button.remove.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")

			button.export = Button_Create(button):Point("RIGHT",button.remove,"LEFT",-5,0)
			button.export:SetScript("OnClick",Button_Lvl1_Export)
			button.export.tooltip1 = L.ReminderExportToString
			button.export.texture:SetTexture("Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128")
			button.export.texture:SetTexCoord(0.125,0.1875,0.5,0.625)

			button.send = Button_Create(button):Point("RIGHT",button.export,"LEFT",-5,0)
			button.send:SetScript("OnClick",Button_Lvl1_Send)
			button.send.tooltip1 = L.ReminderSendSection
			button.send.texture:SetTexture("Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128")
			button.send.texture:SetTexCoord(0.1875,0.25,0.875,1)
			button.send.texture:SetSize(20,20)
		elseif level == 2 then
			local textObj = button:GetTextObj()
			textObj:SetPoint("RIGHT",-3-18*3,0)

			textObj:SetPoint("LEFT",3+20+2,0)
			button.typeicon = CreateFrame("Frame",nil,button)
			button.typeicon:SetPoint("LEFT",2,0)
			button.typeicon:SetSize(20,20)
			button.typeicon.text = ELib:Text(button.typeicon,"T"):Point("CENTER"):Color()
			button.typeicon.glow = ELib:Texture(button.typeicon,[[Interface\SpellActivationOverlay\IconAlert]]):Point("CENTER",-1,0):Size(18,18):TexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
			button.typeicon.glow:SetDesaturated(true)
			button.typeicon.glow2 = CreateFrame("Frame",nil,button.typeicon)
			button.typeicon.glow2:SetSize(18,18)
			button.typeicon.glow2:SetPoint("CENTER")
			button.typeicon.glow2.t1 = ELib:Texture(button.typeicon.glow2,1,1,1,1):Point("TOPLEFT",button.typeicon.glow2,"CENTER",-7,7):Size(5,2)
			button.typeicon.glow2.t2 = ELib:Texture(button.typeicon.glow2,1,1,1,1):Point("TOPRIGHT",button.typeicon.glow2,"CENTER",7,7):Size(5,2)
			button.typeicon.glow2.l1 = ELib:Texture(button.typeicon.glow2,1,1,1,1):Point("TOPLEFT",button.typeicon.glow2,"CENTER",-7,7):Size(2,5)
			button.typeicon.glow2.l2 = ELib:Texture(button.typeicon.glow2,1,1,1,1):Point("BOTTOMLEFT",button.typeicon.glow2,"CENTER",-7,-7):Size(2,5)
			button.typeicon.glow2.r1 = ELib:Texture(button.typeicon.glow2,1,1,1,1):Point("TOPRIGHT",button.typeicon.glow2,"CENTER",7,7):Size(2,5)
			button.typeicon.glow2.r2 = ELib:Texture(button.typeicon.glow2,1,1,1,1):Point("BOTTOMRIGHT",button.typeicon.glow2,"CENTER",7,-7):Size(2,5)
			button.typeicon.glow2.b1 = ELib:Texture(button.typeicon.glow2,1,1,1,1):Point("BOTTOMLEFT",button.typeicon.glow2,"CENTER",-7,-7):Size(5,2)
			button.typeicon.glow2.b2 = ELib:Texture(button.typeicon.glow2,1,1,1,1):Point("BOTTOMRIGHT",button.typeicon.glow2,"CENTER",7,-7):Size(5,2)
			button.typeicon.bar = ELib:Texture(button.typeicon,1,1,1,1):Point("CENTER",-1,0):Size(18,4)
			button.typeicon.SetType = Button_Lvl2_SetTypeIcon
			button.typeicon:SetType()

			button.onoff = Button_Create(button):Point("RIGHT",button,"RIGHT",-2,0)
			button.onoff:SetScript("OnClick",Button_OnOff_Click)
			button.onoff.Update = Button_OnOff_Update
			button.onoff.tooltip1 = L.ReminderPersonalDisable
			button.onoff.tooltip2 = L.ReminderPersonalEnable

			button.lock = Button_Create(button):Point("RIGHT",button.onoff,"LEFT",0,0)
			button.lock.texture:SetTexture([[Interface\AddOns\MRT\media\DiesalGUIcons16x256x128.tga]])
			button.lock:SetScript("OnClick",Button_Lock_Click)
			button.lock.Update = Button_Lock_Update
			button.lock.tooltip1 = L.ReminderUpdatesDisable
			button.lock.tooltip2 = L.ReminderUpdatesEnable

			button.sound = Button_Create(button):Point("RIGHT",button.lock,"LEFT",0,0)
			button.sound.texture:SetTexture([[Interface\AddOns\MRT\media\volume.tga]])
			button.sound.line = button.sound:CreateLine(nil,"ARTWORK",nil,2)
			button.sound.line:SetColorTexture(1,0,0,1)
			button.sound.line:SetStartPoint("CENTER",-5,-5)
			button.sound.line:SetEndPoint("CENTER",5,5)
			button.sound.line:SetThickness(2)
			button.sound:SetScript("OnClick",Button_Sound_Click)
			button.sound.Update = Button_Sound_Update
			button.sound.tooltip1 = L.ReminderSoundDisable
			button.sound.tooltip2 = L.ReminderSoundEnable

			button:SetScript("OnEnter",Button_OnEnter)
			button:SetScript("OnLeave",Button_OnLeave)

			button:RegisterForClicks("LeftButtonUp","RightButtonUp")
		end
	end
	function self.scrollList:ModButtonUpdate(button,level)
		if level == 1 then
			local data = button.data
			local resetBossImg,resetDungImg = true,true
			if data.bossID then
				if ExRT.GDB.encounterIDtoEJ[data.bossID] and EJ_GetCreatureInfo then
					local displayInfo = select(4, EJ_GetCreatureInfo(1, ExRT.GDB.encounterIDtoEJ[data.bossID]))
					if displayInfo then
						button.bossImg:SetTexCoord(0,1,0,1)
						SetPortraitTextureFromCreatureDisplayID(button.bossImg, displayInfo)
						resetBossImg = false
					end
				end
			elseif data.zoneID then
				local journalInstance = ExRT.GDB.MapIDToJournalInstance[tonumber(data.zoneID)]
				if journalInstance and EJ_GetInstanceInfo then
					local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(journalInstance)
					if buttonImage1 then
						button.bossImg:SetTexCoord(0.2,0.8,0,0.6)
						button.bossImg:SetTexture(buttonImage1)
						resetBossImg = false
					end
					if bgImage then
						button.dungImg:SetTexture(bgImage)
						button.dungImg:SetTexCoord(0,1,.4,.6)
						resetDungImg = false
					end
				end
			end
			if resetBossImg then
				button.bossImg:SetTexture("")
			end
			if resetDungImg then
				button.dungImg:SetTexture("")
			end

			if data.bossID or data.zoneID then
				button.export.bossID = data.bossID or data.zone_bossID
				button.export.zoneID = data.zoneID
				button.export:Show()

				button.send.bossID = data.bossID or data.zone_bossID
				button.send.zoneID = data.zoneID
				button.send:Show()

				button.remove.bossID = data.bossID or data.zone_bossID
				button.remove.zoneID = data.zoneID
				button.remove:Show()
			else
				button.export:Hide()
				button.send:Hide()
				button.remove:Hide()
			end

			if module.options.isPersonalTab then
				button.export:Hide()
				button.send:Hide()
			end
		elseif level == 2 then
			button:GetTextObj():SetWordWrap(false)

			local data = button.data
			if data.nohud and not button.ishudhidden then
				button.onoff:Hide()
				button.sound:Hide()
				button.lock:Hide()
				button.ishudhidden = true
			elseif not data.nohud and button.ishudhidden then
				button.onoff:Show()
				button.sound:Show()
				button.lock:Show()
				button.ishudhidden = false
			end

			local options = VMRT.Reminder2.options[data.data and data.data.uid or 0] or 0
			if bit.band(options,bit.lshift(1,0)) == 0 then
				button.onoff.status = 1
			else
				button.onoff.status = 2
			end
			button.onoff:Update(button.onoff.status)

			if bit.band(options,bit.lshift(1,1)) == 0 then
				button.sound.status = 1
			else
				button.sound.status = 2
			end
			button.sound:Update(button.sound.status)
			if not button.ishudhidden then
				if data.data and data.data.sound then
					button.sound:Show()
				else
					button.sound:Hide()
				end
			end

			if bit.band(options,bit.lshift(1,2)) == 0 then
				button.lock.status = 1
			else
				button.lock.status = 2
			end
			button.lock:Update(button.lock.status)

			if data.data then
				local rem_type = module:GetReminderType(data.data.msgSize)
				if data.data.msgSize == 2 then
					button.typeicon:SetType(2)
				elseif data.data.msgSize == 3 then
					button.typeicon:SetType(3)
				elseif rem_type == REM.TYPE_CHAT then
					button.typeicon:SetType(6)
				elseif rem_type == REM.TYPE_NAMEPLATE then
					button.typeicon:SetType(5)
				elseif rem_type == REM.TYPE_RAIDFRAME then
					button.typeicon:SetType(4)
				elseif rem_type == REM.TYPE_WA then
					button.typeicon:SetType(7)
				elseif rem_type == REM.TYPE_BAR then
					button.typeicon:SetType(8)
				else
					button.typeicon:SetType(1)
				end
			else
				button.typeicon:SetType()
			end

			if not data.data or data.data.disabled then
				button.Texture:SetGradient("VERTICAL",CreateColor(0.05,0.06,0.09,1), CreateColor(0.20,0.21,0.25,1))
			elseif module:CheckPlayerCondition(data.data) then
				button.Texture:SetGradient("VERTICAL",CreateColor(0.05,0.16,0.09,1), CreateColor(0.20,0.31,0.25,1))
			else
				button.Texture:SetGradient("VERTICAL",CreateColor(0.15,0.06,0.09,1), CreateColor(0.30,0.21,0.25,1))
			end
		end
	end

	function self:UpdateSenderDataText()
		if VMRT.Reminder2.Profile == 0 then
			self.lastUpdate:SetAlpha(1)
		else
			self.lastUpdate:SetAlpha(0)
		end
		if VMRT.Reminder2.LastUpdateName and VMRT.Reminder2.LastUpdateTime then
			self.lastUpdate:SetText( L.NoteLastUpdate..": "..VMRT.Reminder2.LastUpdateName.." ("..date("%H:%M:%S %d.%m.%Y",VMRT.Reminder2.LastUpdateTime)..")" )
		end
	end
	function self:UpdateData()
		local currZoneID = select(8,GetInstanceInfo())

		local Mdata = {}
		local zoneHeaders = {}
		for uid,data in pairs(CURRENT_DATA) do
			local tableToAdd

			local bossID = data.bossID
			local zoneID = data.zoneID
			if zoneID then
				zoneID = tonumber(tostring(zoneID):match("^[^, ]+") or "",10)
			end

			local function AddZone(zoneID)
				local zoneData = ExRT.F.table_find3(Mdata,zoneID,"zoneID")
				if not zoneData then
					local journalInstance = ExRT.GDB.MapIDToJournalInstance[tonumber(zoneID)]
					local fieldName = L.ReminderZone..(VMRT.Reminder2.zoneNames[zoneID] and ": "..VMRT.Reminder2.zoneNames[zoneID].." |cffcccccc("..zoneID..")|r" or " "..zoneID)..(currZoneID == zoneID and " |cff00ff00("..L.ReminderNow..")|r" or "")
					if journalInstance and EJ_GetInstanceInfo then
						local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(journalInstance)
						if name then
							fieldName = name..(currZoneID == zoneID and " |cff00ff00("..L.ReminderNow..")|r" or "")
						end
					elseif tonumber(zoneID) == -1 then
						fieldName = ALWAYS
					end
					zoneData = {
						zoneID = zoneID,
						name = fieldName,
						data = {},
						uid = "zone"..zoneID,
					}
					Mdata[#Mdata+1] = zoneData
			
					zoneHeaders[zoneID] = zoneData
				end
				return zoneData
			end

			local options = VMRT.Reminder2.options[uid] or 0
			local isPersonal = bit.band(options,bit.lshift(1,3)) > 0
			if 
				((isPersonal and module.options.isPersonalTab) or (not isPersonal and not module.options.isPersonalTab)) and
				(not module.options.search or (data.name and data.name:lower():find(module.options.search,1,true)) or (data.msg and data.msg:lower():find(module.options.search,1,true)))
			then
				if bossID then
					local bossData = ExRT.F.table_find3(Mdata,bossID,"bossID")
					if not bossData then
						local instanceName
						for i=1,#encountersList do
							local instance = encountersList[i]
							for j=2,#instance do
								if instance[j] == bossID then
									instanceName = GetMapNameByID(instance[1]) or ""
									break
								end
							end
							if instanceName then
								break
							end
						end
						local encounterName = ExRT.L.bossName[bossID]
						if encounterName == "" then
							encounterName = nil
						end
						bossData = {
							bossID = bossID,
							name = (instanceName and instanceName ~= "" and instanceName..": " or "")..(encounterName or L.ReminderEncounterID.." "..bossID)..(bossID == module.db.lastEncounterID and " |cff00ff00("..L.ReminderLastPull..")|r" or ""),
							data = {},
							uid = "boss"..bossID,
						}
						Mdata[#Mdata+1] = bossData

						local ej_bossID = ExRT.GDB.encounterIDtoEJ[bossID]
						if ej_bossID and EJ_GetEncounterInfo then
							local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID = EJ_GetEncounterInfo(ej_bossID)
							if journalInstanceID then
								local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(journalInstanceID)
								if mapID then
									local zoneData = AddZone(mapID)
									if not zoneData.zone_bossID then
										zoneData.zone_bossID = {}
									end
									zoneData.zone_bossID[bossID] = true
								end
									
							end
						end
					end
					tableToAdd = bossData.data
				elseif zoneID then
					tableToAdd = AddZone(zoneID).data
				else
					local otherData = ExRT.F.table_find3(Mdata,0,"otherID")
					if not otherData then
						otherData = {
							otherID = 0,
							name = L.ReminderNoLoad,
							data = {},
							uid = "other0",
						}
						Mdata[#Mdata+1] = otherData
					end
					tableToAdd = otherData.data
				end

				tableToAdd[#tableToAdd+1] = {
					name = data.name or data.msg and module:FormatMsg(data.msg) or "~"..L.ReminderNoName,
					uid = uid,
					--drag = true,
					data = data,
					isPersonal = isPersonal,
				}
			end
		end

		sort(Mdata,function(a,b)
			if a.bossID and b.bossID then 
				return GetEncounterSortIndex(a.bossID,10000+a.bossID) < GetEncounterSortIndex(b.bossID,10000+b.bossID)
			elseif a.zoneID and b.zoneID then
				return a.zoneID > b.zoneID
			elseif a.otherID then
				return false
			elseif b.otherID then
				return true
			elseif a.bossID then
				return true
			elseif b.bossID then
				return false
			end
		end)

		for i=1,#Mdata do
			local t = Mdata[i].data
			sort(t,function(a,b)
				if a.isPersonal and not b.isPersonal then
					return false
				elseif not a.isPersonal and b.isPersonal then
					return true
				else
					return a.name:lower() < b.name:lower()
				end
			end)
			t[#t+1] = 0
			t[#t+1] = {
				name = "|cffffffff  +"..(module.options.isPersonalTab and L.ReminderNewPersonal or L.ReminderNew),
				uid = "new"..i,
				nohud = true,
				isNew = true,
				isPersonal = module.options.isPersonalTab,
				bossIDnew = Mdata[i].bossID,
				zoneIDnew = Mdata[i].zoneID,
			}
		end

		--re add boss to dungeons
		for i=#Mdata,1,-1 do
			local bossID = Mdata[i].bossID
			if bossID then
				local ej_bossID = ExRT.GDB.encounterIDtoEJ[bossID]
				if ej_bossID and EJ_GetEncounterInfo then
					local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID = EJ_GetEncounterInfo(ej_bossID)
					if journalInstanceID then
						local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(journalInstanceID)
						if mapID and zoneHeaders[mapID] then
							Mdata[i].isSubData = true
							tinsert(zoneHeaders[mapID].data,1,Mdata[i])
							tremove(Mdata,i)
						end
							
					end
				end
			end
		end

		self.scrollList.data = Mdata
		self.scrollList:Update(true)

		module.options:UpdateSenderDataText()
	end

	self.AddButton = ELib:Button(self.tab.tabs[1],ADD):Point("TOPLEFT",self.scrollList,"BOTTOMLEFT",2,-5):Size(100,20):OnClick(function()
		local new = ExRT.F.table_copy2(newRemainderTemplate)
		new.uid = module.options:GetNewUID()

		if module.options.isPersonalTab then
			UpdateOption(new.uid,false,bit.bor(bit.lshift(1,3),bit.lshift(1,2)))
		end

		module.options.setupFrame:Update(new)
		module.options.setupFrame:Show()
	end)

	self.lastUpdate = ELib:Text(self.tab.tabs[1],"",11):Point("LEFT",self.AddButton,"RIGHT",10,0):Color()

	local zoneForRaid = {
		--[mapID in encountersList] = zoneID,
		[1735] = 2296,	--castle Nathria
		[1998] = 2450,	--sod
		[2047] = 2481,	--sfo
		[2119] = 2522,	--voti
		[2166] = 2569,	--a
		[2232] = 2549,	--adh
	}

	self.SyncButton = ELib:Button(self.tab.tabs[1],L.ReminderSend):Point("TOPLEFT",self.AddButton,"BOTTOMLEFT",0,-5):Size(100,20):OnClick(function(self)
		--[[
		self:Disable()
		self:SetText(L.ReminderSending.."...")
		ExRT.F.ScheduleTimer(function()
			self:Enable()
			self:SetText(L.ReminderSend)
		end, 1)
		]]
		if not VMRT.Reminder2.SyncOption then
			if encountersList[1] then
				local bossList = {}
				for i=2,#encountersList[1] do
					bossList[ encountersList[1][i] ] = true
				end
				module:Sync(false,bossList,zoneForRaid[ encountersList[1][1] ] or nil)
			else
				module:Sync()
			end
		elseif VMRT.Reminder2.SyncOption == 1 then
			if encountersList[2] then
				local bossList = {}
				for i=2,#encountersList[2] do
					bossList[ encountersList[2][i] ] = true
				end
				module:Sync(false,bossList,zoneForRaid[ encountersList[2][1] ] or nil)
			else
				module:Sync()
			end
		else
			module:Sync()
		end
	end):OnShow(function(self)
		if IsInRaid() then
			if ExRT.F.IsPlayerRLorOfficer("player") then
				self:Enable()
				self.raidLocked = false
			else
				self:Disable()
				self.raidLocked = true
			end
		else
			self:Enable()
			self.raidLocked = false
		end
	end):OnEnter(function (self)
		self.optsFrame:Show()
	end)

	local lastSyncTime = 0
	function self:SyncProgress(now,total)
		total = total or 1
		if not now or now == total then
			if not self.SyncButton.raidLocked then
				local t = GetTime()
				if t - lastSyncTime >= 0.5 then
					self.SyncButton:Enable()
				else
					C_Timer.After(0.5,function()
						self.SyncButton:Enable()
					end)
				end
			end
			self.SyncButton:SetText(L.ReminderSend)
			return
		end
		if now == 0 then
			lastSyncTime = GetTime()
		end
		local progress = now / total
		self.SyncButton:Disable()
		self.SyncButton:SetText(L.ReminderSending.." "..format("%d%%",progress * 100))
	end
	
	self.SyncButton.optsFrame = ELib:Frame(self.SyncButton):Size(300,75):Texture(0,0,0,.7):TexturePoint("x"):Point("BOTTOMLEFT","x","BOTTOMRIGHT")
	self.SyncButton.optsFrame:SetScript("OnUpdate",function(self)
		if not self:IsMouseOver() and not self:GetParent():IsMouseOver() then
			self:Hide()
		end
	end)

	self.SyncButton.optsFrame.onlyLastTier = ELib:Check(self.SyncButton.optsFrame,"Only current tier ("..(type(encountersList[1][1])=='string' and encountersList[1][1] or GetMapNameByID(encountersList[1][1]) or "???")..")",not VMRT.Reminder2.SyncOption):Point(5,-5):AddColorState():OnClick(function(self) 
		VMRT.Reminder2.SyncOption = nil

		self:GetParent().onlyLastTier:SetChecked(true)
		self:GetParent().onlyPrevTier:SetChecked(false)
		self:GetParent().all:SetChecked(false)
	end)
	self.SyncButton.optsFrame.onlyPrevTier = ELib:Check(self.SyncButton.optsFrame,"Only prev tier ("..(type(encountersList[2][1])=='string' and encountersList[2][1] or GetMapNameByID(encountersList[2][1]) or "???")..")",VMRT.Reminder2.SyncOption == 1):Point(5,-30):AddColorState():OnClick(function(self) 
		VMRT.Reminder2.SyncOption = 1

		self:GetParent().onlyLastTier:SetChecked(false)
		self:GetParent().onlyPrevTier:SetChecked(true)
		self:GetParent().all:SetChecked(false)
	end)
	self.SyncButton.optsFrame.all = ELib:Check(self.SyncButton.optsFrame,ALL or "All",VMRT.Reminder2.SyncOption == 0):Point(5,-55):AddColorState():OnClick(function(self) 
		VMRT.Reminder2.SyncOption = 0

		self:GetParent().onlyLastTier:SetChecked(false)
		self:GetParent().onlyPrevTier:SetChecked(false)
		self:GetParent().all:SetChecked(true)
	end)


	self.ResetButton = ELib:Button(self.tab.tabs[1],L.ReminderRemoveAll):Point("TOPRIGHT",self.scrollList,"BOTTOMRIGHT",-2,-30):Size(100,20):Tooltip(L.ReminderRemoveAllTip):OnClick(function()
		StaticPopupDialogs["EXRT_REMINDER_CLEAR"] = {
			text = L.ReminderRemove.."?",
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				for uid in pairs(CURRENT_DATA) do
					if bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,2)) == 0 then
						CURRENT_DATA[uid] = nil
					end
				end
				module.options:UpdateData()
				module:ReloadAll()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_REMINDER_CLEAR")
	end)

	self.importWindow, self.exportWindow = ExRT.F.CreateImportExportWindows()

	function self.importWindow:ImportFunc(str)
		local headerSize = str:sub(1,4) == "EXRT" and 9 or 8
		local header = str:sub(1,headerSize)
		if not (header:sub(1,headerSize-1) == "MRTREMD" or header:sub(1,headerSize-1) == "EXRTREMD") or (header:sub(headerSize,headerSize) ~= "0" and header:sub(headerSize,headerSize) ~= "1") then
			StaticPopupDialogs["EXRT_REM_IMPORT"] = {
				text = "|cffff0000"..ERROR_CAPS.."|r "..L.ProfilesFail3,
				button1 = OKAY,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("EXRT_REM_IMPORT")
			return
		end

		self:TextToProfile(str:sub(headerSize+1),header:sub(headerSize,headerSize)=="0",header:sub(headerSize,headerSize)=="2")
	end

	function self.importWindow:TextToProfile(str,uncompressed,undecoded)
		local decoded = LibDeflate:DecodeForPrint(str:trim():gsub("^[\t\n\r]*",""):gsub("[\t\n\r]*$",""))
		local decompressed
		if uncompressed then
			decompressed = decoded
		else
			decompressed = LibDeflate:DecompressDeflate(decoded)
			if not decompressed or decompressed:sub(-5) ~= "##F##" then
				decompressed = nil
				StaticPopupDialogs["EXRT_REM_IMPORT"] = {
					text = "|cffff0000"..ERROR_CAPS.."|r "..L.ProfilesFail3,
					button1 = OKAY,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
				}
				StaticPopup_Show("EXRT_REM_IMPORT")
				return
			end
			decompressed = decompressed:sub(1,-6)
		end
		decoded = nil

		if undecoded then
			decompressed = str
		end

		module:ProcessTextToData(decompressed, nil, true)
		decompressed = nil
	end


	self.ExportButton = ELib:Button(self.tab.tabs[1],L.Export):Point("RIGHT",self.ResetButton,"LEFT",-5,0):Size(100,20):OnClick(function()
		local export = module:Sync(true)

		self:ExportStr(export)
	end)

	function self:ExportStr(export)
		module.options.exportWindow:NewPoint("CENTER",UIParent,0,0)

		local compressed
		if #export < 1000000 then
			compressed = LibDeflate:CompressDeflate(export.."##F##",{level = 5})
		end
		local encoded = "MRTREMD"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or export)

		ExRT.F.dprint("Str len:",#export,"Encoded len:",#encoded)

		if IsShiftKeyDown() and IsControlKeyDown() then
			--encoded = "EXRTREMD".."2"..export
		end
		module.options.exportWindow.Edit:SetText(encoded)
		module.options.exportWindow:Show()
	end

	self.ImportButton = ELib:Button(self.tab.tabs[1],L.Import):Point("RIGHT",self.ExportButton,"LEFT",-5,0):Size(100,20):OnClick(function()
		self.importWindow:NewPoint("CENTER",UIParent,0,0)
		self.importWindow:Show()
	end)

	local function CopyClickDropDownFunc(self,arg1)
		StaticPopupDialogs["MRT_REMINDER_COPYPROFILE"] = {
			text = L.ReminderCopyTooltip:format(profiles[ arg1 ]),
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				for q,w in pairs(CURRENT_DATA) do
					VMRT.Reminder2.data[arg1][q] = ExRT.F.table_copy2(w)
				end
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("MRT_REMINDER_COPYPROFILE")

		ELib:DropDownClose()
	end

	self.copyClickDropDown = ELib:DropDownButton(self,"",250,#profilesSorted+1)
	self.copyClickDropDown.isModern = true
	for i=1,#profilesSorted do
		self.copyClickDropDown.List[i] = {text = L.InterruptsCopyTo.." "..profiles[ profilesSorted[i] ], arg1 = profilesSorted[i], func = CopyClickDropDownFunc}
	end
	self.copyClickDropDown.List[#profilesSorted+1] = {text = L.minimapmenuclose,func = ELib.ScrollDropDown.Close}
	
	self.copyClickDropDown:Hide()

	self.CopyToButton = ELib:Button(self.tab.tabs[1],L.InterruptsCopyTo.."..."):Point("RIGHT",self.ImportButton,"LEFT",-5,0):Size(100,20):OnClick(function()
		for i=1,#profilesSorted do
			local line = module.options.copyClickDropDown.List[i]
			if line.arg1 == VMRT.Reminder2.Profile then
				line.isTitle = true
			else
				line.isTitle = false
			end
		end

		local x,y = ExRT.F.GetCursorPos(self)
		module.options.copyClickDropDown:SetPoint("TOPLEFT",self,x,-y)
		module.options.copyClickDropDown:Click()
	end)

	--[[
	self.SendGuildButton = ELib:Button(self.tab.tabs[1],L.ReminderSendGuild):Point("RIGHT",self.CopyToButton,"LEFT",-5,0):Size(120,20):OnClick(function()
		module:SyncGuild()
		self.SyncButton:Click()
	end)
	]]





	function self:GetNewUID()
		local _,sid,pid = strsplit("-",UnitGUID("player"),nil)
		local t = module:ConvertTo36Bit((time() + GetTime() % 1) * 1000)
		return sid .. "-" .. pid .. "-" .. t
	end

	self.setupFrame = ELib:Popup(" "):Size(510,580)
	ELib:Border(self.setupFrame,1,.4,.4,.4,.9)

	self.setupFrame.decorationLine = ELib:DecorationLine(self.setupFrame,true,"BACKGROUND",1):Point("TOPLEFT",self.setupFrame,0,-16):Point("BOTTOMRIGHT",self.setupFrame,"TOPRIGHT",0,-36)

	self.setupFrame.tab = ELib:Tabs(self.setupFrame,0,L.ReminderTabGeneral,L.ReminderTabCond,L.ReminderTabLoadPlayers,L.ReminderTabPersonal):Point(0,-36):Size(510,598):SetTo(1)
	self.setupFrame.tab:SetBackdropBorderColor(0,0,0,0)
	self.setupFrame.tab:SetBackdropColor(0,0,0,0)

	self.setupFrame.tab.tabs[3].button.alert = CreateAlertIcon(self.setupFrame.tab.tabs[3].button,L.ReminderAlertConditionBossZone,L.ReminderAlertConditionBossZone2)
	self.setupFrame.tab.tabs[3].button.alert:SetScale(.8)
	self.setupFrame.tab.tabs[3].button.alert:SetPoint("CENTER",self.setupFrame.tab.tabs[3].button,"TOPRIGHT",-10,-10)
	self.setupFrame.tab.tabs[3].button.alert.Update = function(self)
		if not module.options.setupFrame.data.bossID and not module.options.setupFrame.data.zoneID then
			self:Show()
		else
			self:Hide()
		end
	end

	function self.setupFrame:CloseClick()
		local uid = self.data.uid
		if uid and CURRENT_DATA[uid] and ExRT.F.table_compare(self.data,CURRENT_DATA[uid]) == 1 then
			self:Hide()
			return
		end
		StaticPopupDialogs["EXRT_REMINDER_CLOSE"] = {
			text = L.ReminderDataNotSaved,
			button1 = L.ReminderSave,
			button2 = L.ReminderCloseConf,
			OnAccept = function()
				self.saveButton:Click()
			end,
			OnCancel = function()
				if not CURRENT_DATA[uid] then
					VMRT.Reminder2.options[uid] = nil
				end
				self:Hide()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_REMINDER_CLOSE")
	end

	self.setupFrame.saveButton = ELib:Button(self.setupFrame,L.ReminderSave):Point("BOTTOM",0,10):Size(300,20):OnClick(function()
		self.setupFrame:Hide()
		local uid = self.setupFrame.data.uid or self:GetNewUID()
		self.setupFrame.data.uid = uid
		CURRENT_DATA[uid] = self.setupFrame.data
		self.setupFrame.data.updatedName = ExRT.SDB.charName
		self.setupFrame.data.updatedTime = time()
		module.options:UpdateData()
		module:ReloadAll()
	end)

	self.setupFrame.copyButton = ELib:Button(self.setupFrame.tab.tabs[1],L.ReminderCopy):Point("BOTTOMRIGHT",self.setupFrame.saveButton,"TOP",-5,5):Size(200,20):OnClick(function()
		if not self.setupFrame.data.uid then
			print(L.ReminderAlertNoCopyEmpty)
			return
		end
		self.setupFrame:Hide()
		local uid = self:GetNewUID()
		local newData = ExRT.F.table_copy2(self.setupFrame.data)
		newData.uid = uid
		CURRENT_DATA[uid] = newData
		if newData.name then
			if newData.name:find(" %d+ *$") then
				newData.name = newData.name:gsub(" (%d+) *$",function(a)
					return " "..tonumber(a)+1
				end)
			else
				newData.name = newData.name .. " 2"
			end

		end

		if bit.band(VMRT.Reminder2.options[self.setupFrame.data.uid or 0] or 0,bit.lshift(1,3)) > 0 then
			UpdateOption(uid,false,bit.lshift(1,3))
		end

		module.options:UpdateData()
		module:ReloadAll()
	end)

	function self:RemoveReminder(uid)
		StaticPopupDialogs["EXRT_REMINDER_REMOVE_ONE"] = {
			text = L.ReminderRemove.."?",
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				self.setupFrame:Hide()
				if uid then
					CURRENT_DATA[uid] = nil
				end
				VMRT.Reminder2.removed[uid] = time()
				module.options:UpdateData()
				module:ReloadAll()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_REMINDER_REMOVE_ONE")
	end

	self.setupFrame.removeButton = ELib:Button(self.setupFrame.tab.tabs[1],L.ReminderRemove):Point("BOTTOMLEFT",self.setupFrame.saveButton,"TOP",5,5):Size(200,20):OnClick(function()
		local uid = self.setupFrame.data.uid
		module.options:RemoveReminder(uid)
	end)

	self.setupFrame.sendOneButton = ELib:Button(self.setupFrame.tab.tabs[1],L.ReminderSendOne):Point("BOTTOM",self.setupFrame.copyButton,"TOP",0,5):Size(200,20):OnClick(function(self)
		if not module.options.setupFrame.data.uid then
			print(L.ReminderAlertSaveB4Sending)
			return
		end
		if IsInRaid() then
			if not ExRT.F.IsPlayerRLorOfficer("player") then
				print(L.ReminderAlertSendOnlyRaidOfficer)
				return
			end
		end
		if ExRT.F.table_compare(module.options.setupFrame.data,CURRENT_DATA[module.options.setupFrame.data.uid]) ~= 1 then
			print(L.ReminderAlertSaveB4Sending)
			return
		end
		self:Disable()
		self:SetText(L.ReminderSending.."...")
		ExRT.F.ScheduleTimer(function()
			self:Enable()
			self:SetText(L.ReminderSendOne)
		end, 0.5)
		module:Sync(false,nil,nil,module.options.setupFrame.data.uid)
	end)

	self.setupFrame.exportOneButton = ELib:Button(self.setupFrame.tab.tabs[1],L.ReminderExportToString):Point("BOTTOM",self.setupFrame.removeButton,"TOP",0,5):Size(200,20):OnClick(function()
		self.setupFrame:Hide()
		local uid = self.setupFrame.data.uid

		local savedOriginal = CURRENT_DATA[uid]
		CURRENT_DATA[uid] = self.setupFrame.data
		local export = module:Sync(true,nil,nil,uid)
		CURRENT_DATA[uid] = savedOriginal

		self:ExportStr(export)
	end)

	self.setupFrame.nameEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):Point("TOPLEFT",180,-10):LeftText(L.ReminderName..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		module.options.setupFrame.data.name = text
	end)

	self.setupFrame.msgEdit = ELib:MultiEdit(self.setupFrame.tab.tabs[1]):Size(270,80):Point("TOPLEFT",self.setupFrame.nameEdit,"BOTTOMLEFT",0,-5):HideScrollOnNoScroll():OnChange(function(self,isUser)
		module.options.setupFrame.msgPreview:SetText( module:FormatMsg(self:GetText():gsub("\n",""), {}) or "" )
		if not isUser then return end
		local text = self:GetText():gsub("\n",""):trim()
		if text == "" then text = nil end
		module.options.setupFrame.data.msg = text
	end)
	self.setupFrame.nameEdit.LeftText(self.setupFrame.msgEdit,L.ReminderMsg..":")
	ELib:Border(self.setupFrame.msgEdit,1,.24,.25,.30,1)
	self.setupFrame.msgEdit.ScrollBar:Size(12,0)

	self.setupFrame.msgEdit.help = CreateAlertIcon(self.setupFrame.msgEdit,nil,nil,nil,true)
	self.setupFrame.msgEdit.help:SetPoint("LEFT",self.setupFrame.msgEdit,"RIGHT",30,0)
	self.setupFrame.msgEdit.help:SetType(3)
	self.setupFrame.msgEdit.help:Show()
	self.setupFrame.msgEdit.help.CreateIconsFromList = function(self,list)
		local icons = ""
		for class,spell in pairs(list) do 
			local _,_,spellTexture = GetSpellInfo(spell)
			if spellTexture then
				icons = icons .. "|T"..spellTexture..":0|t"
			end
		end
		return icons
	end
	self.setupFrame.msgEdit.help.msgFunc = function(self,textObj,custom)
		local GameTooltip = GameTooltip
		if custom == "TEXT" then
			GameTooltip = {
				SetOwner = function() end,
				text = "",
			}
			GameTooltip.AddLine = function(_,t)
				GameTooltip.text = GameTooltip.text .. t:gsub("\n","\n   ") .. "\n"
			end
			GameTooltip.Show = function()
				textObj:SetText(GameTooltip.text)
			end
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L.ReminderFormatTipHeader)
		GameTooltip:AddLine(L.ReminderFormatTipIcon)
		GameTooltip:AddLine(L.ReminderFormatTipColor)
		GameTooltip:AddLine(L.ReminderFormatTipMark)
		GameTooltip:AddLine(L.ReminderFormatTipUpper)
		GameTooltip:AddLine("|cff00ff00%pattX|r - "..L.ReminderFormatTipPatt)
		GameTooltip:AddLine("|cff00ff00%playerName|r - "..L.ReminderFormatTipPlayerName)
		GameTooltip:AddLine("|cff00ff00%playerClass|r - "..L.ReminderFormatTipClass..select(2,UnitClass'player'):lower())
		GameTooltip:AddLine("|cff00ff00%notePlayer|r - "..L.ReminderFormatTipNotePlayerLeft)
		GameTooltip:AddLine("|cff00ff00%notePlayerRight|r - "..L.ReminderFormatTipNotePlayerRight)
		local specid,specname = GetSpecializationInfo and GetSpecializationInfo(GetSpecialization() or 1)
		GameTooltip:AddLine("|cff00ff00%playerSpec|r - "..L.ReminderFormatTipSpec..(defSpecName[specid or 0] or specname and specname:lower() or ""))
		GameTooltip:AddLine("|cff00ff00%defCDIcon|r - "..L.ReminderFormatTipDefCDIcon..self:CreateIconsFromList(defCDList))
		GameTooltip:AddLine("|cff00ff00%damageImmuneCDIcon|r - "..L.ReminderFormatTipDefCDIcon2..self:CreateIconsFromList(damageImmuneCDList))
		GameTooltip:AddLine("|cff00ff00%sprintCDIcon|r - "..L.ReminderFormatTipDefCDIcon2..self:CreateIconsFromList(sprintCDList))
		GameTooltip:AddLine("|cff00ff00%healCDIcon|r - "..L.ReminderFormatTipDefCDIcon2..self:CreateIconsFromList(healCDList))
		GameTooltip:AddLine("|cff00ff00%raidCDIcon|r - "..L.ReminderFormatTipDefCDIcon2..self:CreateIconsFromList(raidCDList))
		GameTooltip:AddLine("|cff00ff00%classColor|r - "..L.ReminderFormatTipClassColor.." |cff00ff00%classColor%playerName|r => |c"..ExRT.F.classColor(select(2,UnitClass"player"),nil)..UnitName'player'.."|r")
		GameTooltip:AddLine("|cff00ff00%specIcon|r - "..L.ReminderFormatTipSpecIcon1.." |cff00ff00%specIcon%playerName|r => |A:groupfinder-icon-role-large-"..(math.random(1,2) == 1 and "dps" or "heal")..":0:0|a"..UnitName'player'..". "..L.ReminderFormatTipSpecIcon2:format("|cff00ff00%specIconAndClassColor|r"))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.ReminderFormatTipRepHeader)
		GameTooltip:AddLine(L.ReminderFormatTipRep1)
		GameTooltip:AddLine("|cff00ff00%counter|r - "..L.ReminderFormatTipSpellCounter)
		GameTooltip:AddLine("|cff00ff00%activeNum|r - "..L.ReminderFormatTipActiveTriggers)
		GameTooltip:AddLine("|cff00ff00%statusX|r - "..L.ReminderFormatTipStatus:format("|cff00ff00on|r","|cff00ff00off|r"))
		GameTooltip:AddLine("|cff00ff00%timeLeft|r - "..L.ReminderFormatTipTimeLeft)
		GameTooltip:AddLine("|cff00ff00%activeTime|r - "..L.ReminderFormatTipActiveTime)
		GameTooltip:AddLine("|cff00ff00%timeMinLeft|r - "..L.ReminderFormatTipTimeLeftMin)
		GameTooltip:AddLine("|cff00ff00%allSourceNames|r, |cff00ff00%allTargetNames|r - "..L.ReminderFormatTipAllSources)
		GameTooltip:AddLine("|cff00ff00%allSourceNames:indexFrom:indexTo|r, |cff00ff00%allTargetNames:indexFrom:indexTo|r - "..L.ReminderFormatTipAllSources2)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.ReminderFormatTipRepList)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.ReminderFormatTipRepYesNo:gsub("%$PN%$",UnitName("player")),nil)
		GameTooltip:AddLine(L.ReminderFormatTipRepYesNo2)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.ReminderFormatTipRepMath)
		GameTooltip:AddLine("|cff00ff00{min:X;Y;Z}|r - "..L.ReminderFormatTipMathMin:format("|cff00ff00{max:X;Y;Z}|r)"))
		GameTooltip:AddLine(L.ReminderFormatTipRepRepeat)
		GameTooltip:AddLine(L.ReminderFormatTipRepCrop)
		GameTooltip:AddLine("|cff00ff00{role:X}|r - "..L.ReminderFormatTipRaidRole.." tank,healer,damager,none")
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("|cff00ff00{note:NUM_IN_LIST:NOTE_PATTERN}|r - "..L.ReminderFormatTipNoteLinePos)
		GameTooltip:AddLine("|cff00ff00{noteline:NOTE_PATTERN}|r - "..L.ReminderFormatTipNoteLineFull)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("|cff00ff00{set:X}...{/set}|r - "..L.ReminderFormatTipSaveText:format("|cff00ff00%setX|r"))
		GameTooltip:AddLine("|cff00ff00{find:PATT:TEXT}YES;NO{/find}|r - "..L.ReminderFormatTipFind)
		GameTooltip:AddLine("|cff00ff00{replace:FROM:TO}TEXT{/replace}|r - "..L.ReminderFormatTipReplace)

		if module:GetReminderType(module.options.setupFrame.data.msgSize) == REM.TYPE_RAIDFRAME then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L.ReminderFormatTipFrame)
			GameTooltip:AddLine(L.ReminderFormatTipFrameText)
		end

		GameTooltip:Show()
	end
	self.setupFrame.msgEdit.help:SetScript("OnEnter",self.setupFrame.msgEdit.help.msgFunc)
	
	
	self.setupFrame.formattingHelpFrame = ELib:Popup(L.ReminderFormatTipHeader):AddScroll():Size(600,600)
	self.setupFrame.formattingHelpFrame:SetFrameStrata("FULLSCREEN")
	
	self.setupFrame.msgEdit.help:SetScript("OnClick",function()
		if not self.setupFrame.formattingHelpFrame.loaded then
			self.setupFrame.formattingHelpFrame.loaded = true
			self.setupFrame.formattingHelpFrame.text = ELib:Text(self.setupFrame.formattingHelpFrame.C.C,""):Point("TOPLEFT",5,-5):Point("RIGHT",-5,0):Color()
			self.setupFrame.msgEdit.help:msgFunc(self.setupFrame.formattingHelpFrame.text,"TEXT")
			self.setupFrame.formattingHelpFrame.C:Height(self.setupFrame.formattingHelpFrame.text:GetStringHeight()+1000)
		end
		self.setupFrame.formattingHelpFrame:Show()
	end)


	self.setupFrame.msgEdit.colorButton = CreateFrame("Button",nil,self.setupFrame.msgEdit)
	self.setupFrame.msgEdit.colorButton:SetPoint("LEFT", self.setupFrame.msgEdit, "RIGHT", 3, 0)
	self.setupFrame.msgEdit.colorButton:SetSize(24,24)
	self.setupFrame.msgEdit.colorButton:SetScript("OnClick",function(self)
		if not ColorPickerFrame.SetupColorPickerAndShow then
			local nilFunc = ExRT.NULLfunc
			local function changedCallback(restore)
				local r,g,b = ColorPickerFrame:GetColorRGB()
				local code = format("%02x%02x%02x",r*255,g*255,b*255)
				local hlstart,hlend = module.options.setupFrame.msgEdit:GetTextHighlight()
				if hlstart == hlend then
					module.options.setupFrame.msgEdit:SetText( "||cff"..code..module.options.setupFrame.msgEdit:GetText().."||r" )
				else
					local text = module.options.setupFrame.msgEdit:GetText()
					text = text:sub(1, hlend) .. "||r" .. text:sub(hlend+1)
					text = text:sub(1, hlstart) .. "||cff"..code .. text:sub(hlstart+1)
					module.options.setupFrame.msgEdit:SetText( text )
				end
				module.options.setupFrame.msgEdit.EditBox:GetScript("OnTextChanged")(module.options.setupFrame.msgEdit.EditBox,true)
			end
			ColorPickerFrame.func, ColorPickerFrame.cancelFunc, ColorPickerFrame.opacityFunc = nilFunc, nilFunc, nilFunc
			ColorPickerFrame:SetColorRGB(1,1,1)
			ColorPickerFrame.opacityFunc = changedCallback
			ColorPickerFrame.hasOpacity = false
			ColorPickerFrame:Show()
		else
			local info = {}
			info.r, info.g, info.b = 1,1,1
			info.opacity = 1
			info.hasOpacity = false
			info.swatchFunc = function()
				local btn = ColorPickerFrame.Footer and ColorPickerFrame.Footer.OkayButton or ColorPickerOkayButton
				if not MouseIsOver(btn) or IsMouseButtonDown() then return end
				local r,g,b = ColorPickerFrame:GetColorRGB()
				local code = format("%02x%02x%02x",r*255,g*255,b*255)
				local hlstart,hlend = module.options.setupFrame.msgEdit:GetTextHighlight()
				if hlstart == hlend then
					module.options.setupFrame.msgEdit:SetText( "||cff"..code..module.options.setupFrame.msgEdit:GetText().."||r" )
				else
					local text = module.options.setupFrame.msgEdit:GetText()
					text = text:sub(1, hlend) .. "||r" .. text:sub(hlend+1)
					text = text:sub(1, hlstart) .. "||cff"..code .. text:sub(hlstart+1)
					module.options.setupFrame.msgEdit:SetText( text )
				end
				module.options.setupFrame.msgEdit.EditBox:GetScript("OnTextChanged")(module.options.setupFrame.msgEdit.EditBox,true)
			end
			info.cancelFunc = function()
				local newR, newG, newB, newA = ColorPickerFrame:GetPreviousValues()
			end
			ColorPickerFrame:SetupColorPickerAndShow(info)
		end
	end)
	self.setupFrame.msgEdit.colorButton:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L.ReminderSelectColor)
		GameTooltip:Show()
	end)
	self.setupFrame.msgEdit.colorButton:SetScript("OnLeave",function(self)
		GameTooltip_Hide()
	end)
	self.setupFrame.msgEdit.colorButton.Texture = self.setupFrame.msgEdit.colorButton:CreateTexture(nil,"ARTWORK")
	self.setupFrame.msgEdit.colorButton.Texture:SetPoint("CENTER")
	self.setupFrame.msgEdit.colorButton.Texture:SetSize(20,20)
	self.setupFrame.msgEdit.colorButton.Texture:SetTexture([[Interface\AddOns\MRT\media\wheeltexture]])

	self.setupFrame.msgPreview = ELib:Text(self.setupFrame.tab.tabs[1]):Point("TOPLEFT",self.setupFrame.msgEdit,"BOTTOMLEFT",0,-5):Point("RIGHT",self.setupFrame,-5,0):Size(0,20):Color()
	self.setupFrame.msgPreview:SetMaxLines(1)

	self.setupFrame.soundList = ELib:DropDown(self.setupFrame.tab.tabs[1],270,15):AddText("|cffffd100"..L.ReminderSound..":"):Size(270):Point("TOPLEFT",self.setupFrame.msgEdit,"BOTTOMLEFT",0,-5-25)
	function self.setupFrame.soundList.func_SetValue(_,arg1)
		if arg1 == 0 then
			self.setupFrame.soundCustom:Shown(true):Point("TOPLEFT",self.setupFrame.soundList,"BOTTOMLEFT",0,-5)
			if not module.options.setupFrame.setup then
				module.options.setupFrame.data.sound = nil
			end

			self.setupFrame.soundList:SetText(L.ReminderCustom)
		elseif not arg1 then
			self.setupFrame.soundCustom:Shown(false):Point("TOPLEFT",self.setupFrame.soundList,"TOPLEFT",0,0)
			if not module.options.setupFrame.setup then
				module.options.setupFrame.data.sound = nil
			end

			self.setupFrame.soundList:SetText("-")
		else
			self.setupFrame.soundCustom:Shown(false):Point("TOPLEFT",self.setupFrame.soundList,"TOPLEFT",0,0)
			if not module.options.setupFrame.setup then
				module.options.setupFrame.data.sound = arg1
			end

			local val = ExRT.F.table_find3(self.setupFrame.soundList.List,arg1,"arg1")
			if val then
				self.setupFrame.soundList:SetText(val.text)
			else
				self.setupFrame.soundList:SetText(arg1)
			end
		end
		ELib:DropDownClose()
		if not module.options.setupFrame.setup and arg1 and arg1 ~= 0 then
			module:PlaySound(arg1)
		end
	end
	function self.setupFrame.soundList:PreUpdate()
		local List = self.List
		wipe(List)
		for i=1,#module.datas.sounds do
			List[#List+1] = {
				text = module.datas.sounds[i][2],
				arg1 = module.datas.sounds[i][1],
				func = self.func_SetValue,
				prio = 1,
			}
		end
		for name, path in ExRT.F.IterateMediaData("sound") do
			List[#List+1] = {
				text = name,
				arg1 = path,
				func = self.func_SetValue,
			}
		end
		sort(List,function(a,b) if a.prio == b.prio then return a.text < b.text else return (a.prio or 0) > (b.prio or 0) end end)
		tinsert(List,1,{
			text = "-",
			func = self.func_SetValue,
		})
		List[#List+1] = {
			text = L.ReminderCustom,
			arg1 = 0,
			func = self.func_SetValue,
		}
	end

	self.setupFrame.soundCustom = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):Point("TOPLEFT",self.setupFrame.soundList,"TOPLEFT",0,0):LeftText(L.ReminderCustomSound..":"):Shown(false):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		module.options.setupFrame.data.sound = text
	end)

	self.setupFrame.soundList.playButton = ELib:Icon(self.setupFrame.soundList,"Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128",20,true):Point("LEFT",self.setupFrame.soundCustom,"RIGHT",5,0)
	self.setupFrame.soundList.playButton.texture:SetTexCoord(0.375,0.4375,0.5,0.625)
	self.setupFrame.soundList.playButton:SetScript("OnClick",function()
		if module.options.setupFrame.data.sound == "TTS" then
			module:PlaySound(module.options.setupFrame.data.sound, {data={msg=(module.options.setupFrame.data.msg or "")},params={}})
		else
			module:PlaySound(module.options.setupFrame.data.sound)
		end
	end)

	self.setupFrame.msgSize = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.messageSize):AddText("|cffffd100"..L.ReminderMsgType..":"):Size(270):Point("TOPLEFT",self.setupFrame.soundCustom,"BOTTOMLEFT",0,-5)
	do
		local function msgSize_SetValue(_,arg1)
			ELib:DropDownClose()
			module.options.setupFrame.data.msgSize = arg1
			local val = ExRT.F.table_find3(module.datas.messageSize,arg1,1)
			if val then
				self.setupFrame.msgSize:SetText(val[2])
			else
				self.setupFrame.msgSize:SetText("?")
			end

			if module:GetReminderType(arg1) == REM.TYPE_WA then
				module.options.setupFrame.durEdit:Hide()
				module.options.setupFrame.countdownCheck:Hide()
				module.options.setupFrame.countdownType:Hide()
				module.options.setupFrame.countdownTypeText:Hide()
				module.options.setupFrame.countdownVoice:Hide()
				module.options.setupFrame.copyCheck:Hide()
				module.options.setupFrame.disableRewrite:Hide()
				module.options.setupFrame.disableDynamicUpdates:Hide()

				module.options.setupFrame.glowTypeEdit:Hide()
				module.options.setupFrame.glowColorEdit:Hide()
				module.options.setupFrame.customOpt1:Hide()
				module.options.setupFrame.glowImage.ignoreRepos = nil
				module.options.setupFrame.glowImage:Hide()
			elseif module:GetReminderType(arg1) == REM.TYPE_CHAT then
				module.options.setupFrame.durEdit:Show()
				module.options.setupFrame.countdownCheck:Show()
				module.options.setupFrame.countdownCheck:GetScript("OnClick")(module.options.setupFrame.countdownCheck)
				module.options.setupFrame.countdownVoice:Hide()
				module.options.setupFrame.copyCheck:Hide()
				module.options.setupFrame.disableRewrite:Hide()
				module.options.setupFrame.disableDynamicUpdates:Hide()

				module.options.setupFrame.glowTypeEdit:Hide()
				module.options.setupFrame.glowColorEdit:Hide()
				module.options.setupFrame.customOpt1:Hide()
				module.options.setupFrame.glowImage.ignoreRepos = nil
				module.options.setupFrame.glowImage:Hide()
			elseif module:GetReminderType(arg1) == REM.TYPE_NAMEPLATE or module:GetReminderType(arg1) == REM.TYPE_RAIDFRAME then
				module.options.setupFrame.durEdit:Show()
				module.options.setupFrame.countdownCheck:Hide()
				module.options.setupFrame.countdownType:Hide()
				module.options.setupFrame.countdownTypeText:Hide()
				module.options.setupFrame.countdownVoice:Hide()
				module.options.setupFrame.copyCheck:Hide()
				module.options.setupFrame.disableRewrite:Hide()
				module.options.setupFrame.disableDynamicUpdates:Show()

				module.options.setupFrame.disableRewrite:NewPoint("TOPLEFT",module.options.setupFrame.durEdit,"BOTTOMLEFT",0,-5+25)

				module.options.setupFrame.glowTypeEdit:Show()
				module.options.setupFrame.glowImage:Point("TOPLEFT",module.options.setupFrame.glowTypeEdit,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.glowColorEdit:Show()
				module.options.setupFrame.glowColorEdit:Point("TOPLEFT",module.options.setupFrame.glowImageCustomEdit,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.customOpt1:Hide()
				module.options.setupFrame.glowImage.ignoreRepos = nil
			elseif module:GetReminderType(arg1) == REM.TYPE_BAR then
				module.options.setupFrame.durEdit:Show()
				module.options.setupFrame.countdownCheck:Hide()
				module.options.setupFrame.countdownType:Show()
				module.options.setupFrame.countdownType:Point("TOPLEFT",module.options.setupFrame.durEdit,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.countdownTypeText:Hide()
				module.options.setupFrame.countdownVoice:Show()
				module.options.setupFrame.copyCheck:Show()
				module.options.setupFrame.disableRewrite:Show()
				module.options.setupFrame.disableDynamicUpdates:Show()

				module.options.setupFrame.disableRewrite:NewPoint("TOPLEFT",module.options.setupFrame.copyCheck,"BOTTOMLEFT",0,-5)

				module.options.setupFrame.glowTypeEdit:Hide()
				module.options.setupFrame.glowColorEdit:Show()
				module.options.setupFrame.glowColorEdit:Point("TOPLEFT",module.options.setupFrame.disableDynamicUpdates,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.customOpt1:Show()
				module.options.setupFrame.customOpt1:Point("TOPLEFT",module.options.setupFrame.glowColorEdit,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.glowImage.ignoreRepos = true
				module.options.setupFrame.glowImage:Show()
				module.options.setupFrame.glowImage:Point("TOPLEFT",module.options.setupFrame.customOpt1,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.glowImage:SetValue(module.options.setupFrame.data.glowImage)
			else
				module.options.setupFrame.durEdit:Show()
				module.options.setupFrame.countdownCheck:Show()
				module.options.setupFrame.countdownCheck:GetScript("OnClick")(module.options.setupFrame.countdownCheck)
				module.options.setupFrame.countdownVoice:Show()
				module.options.setupFrame.copyCheck:Show()
				module.options.setupFrame.disableRewrite:Show()
				module.options.setupFrame.disableDynamicUpdates:Show()

				module.options.setupFrame.disableRewrite:NewPoint("TOPLEFT",module.options.setupFrame.copyCheck,"BOTTOMLEFT",0,-5)

				module.options.setupFrame.glowTypeEdit:Hide()
				module.options.setupFrame.glowColorEdit:Hide()
				module.options.setupFrame.customOpt1:Hide()
				module.options.setupFrame.glowImage.ignoreRepos = nil
				module.options.setupFrame.glowImage:Hide()
			end
		end
		self.setupFrame.msgSize.SetValue = msgSize_SetValue

		local List = self.setupFrame.msgSize.List
		for i=1,#module.datas.messageSize do
			List[#List+1] = {
				text = module.datas.messageSize[i][2],
				arg1 = module.datas.messageSize[i][1],
				tooltip = module.datas.messageSize[i][3],
				func = msgSize_SetValue,
			}
		end
	end

	self.setupFrame.durEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):Point("TOPLEFT",self.setupFrame.msgSize,"BOTTOMLEFT",0,-5):LeftText(L.ReminderDuration..":"):OnChange(function(self,isUser)
		if not isUser then return end
		module.options.setupFrame.data.dur = tonumber( self:GetText() )
	end):Tooltip(function(self)
		self.lockTooltipText = true

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L.ReminderDuration)
		GameTooltip:AddLine(L.ReminderDurationTooltip)
		if module:GetReminderType(module.options.setupFrame.data.msgSize) == REM.TYPE_CHAT then
			GameTooltip:AddLine(L.ReminderDurationTooltipMsg)
		end
		GameTooltip:Show()
	end)

	self.setupFrame.countdownCheck = ELib:Check(self.setupFrame.tab.tabs[1],L.ReminderCountdown..":"):Point("TOPLEFT",self.setupFrame.durEdit,"BOTTOMLEFT",0,-5):Left(5):Tooltip(L.ReminderCountdownTooltip):OnClick(function(self)
		if module:GetReminderType(module.options.setupFrame.data.msgSize) == REM.TYPE_BAR then
			return
		end
		if self:GetChecked() then
			module.options.setupFrame.countdownType:Shown(module:GetReminderType(module.options.setupFrame.data.msgSize) ~= REM.TYPE_CHAT):Point("TOPLEFT",module.options.setupFrame.countdownCheck,"BOTTOMLEFT",0,-5)
			module.options.setupFrame.countdownTypeText:Shown(module:GetReminderType(module.options.setupFrame.data.msgSize) == REM.TYPE_CHAT)
			if not module.options.setupFrame.setup then
				module.options.setupFrame.data.countdown = true
			end
		else
			module.options.setupFrame.countdownType:Shown(false):Point("TOPLEFT",module.options.setupFrame.countdownCheck,"TOPLEFT",0,0)
			module.options.setupFrame.countdownTypeText:Shown(false)
			if not module.options.setupFrame.setup then
				module.options.setupFrame.data.countdown = nil
			end
		end
	end)

	self.setupFrame.countdownType = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.countdownType):AddText("|cffffd100"..L.ReminderCountdownAccuracy..":"):Size(270):Point("TOPLEFT",self.setupFrame.countdownCheck,"TOPLEFT",0,0):Shown(false)
	do
		local function countdownType_SetValue(_,arg1)
			ELib:DropDownClose()
			module.options.setupFrame.data.countdownType = arg1
			local val = ExRT.F.table_find3(module.datas.countdownType,arg1,1)
			if val then
				self.setupFrame.countdownType:SetText(val[2])
			else
				self.setupFrame.countdownType:SetText("?")
			end

			local val = ExRT.F.table_find3(module.datas.countdownTypeText,arg1,1)
			if val then
				self.setupFrame.countdownTypeText:SetText(val[2])
			else
				self.setupFrame.countdownTypeText:SetText("?")
			end
		end
		self.setupFrame.countdownType.SetValue = countdownType_SetValue

		local List = self.setupFrame.countdownType.List
		for i=1,#module.datas.countdownType do
			List[#List+1] = {
				text = module.datas.countdownType[i][2],
				arg1 = module.datas.countdownType[i][1],
				func = countdownType_SetValue,
			}
		end
	end

	self.setupFrame.countdownTypeText = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.countdownTypeText):AddText("|cffffd100"..L.ReminderCountdownFrequency..":"):Size(270):Point("TOPLEFT",self.setupFrame.countdownType,"TOPLEFT",0,0):Shown(false)
	do
		local function countdownType_SetValue(_,arg1)
			self.setupFrame.countdownType:SetValue(arg1)
		end
		self.setupFrame.countdownTypeText.SetValue = countdownType_SetValue

		local List = self.setupFrame.countdownTypeText.List
		for i=1,#module.datas.countdownTypeText do
			List[#List+1] = {
				text = module.datas.countdownTypeText[i][2],
				arg1 = module.datas.countdownTypeText[i][1],
				func = countdownType_SetValue,
			}
		end
	end

	self.setupFrame.countdownVoice = ELib:DropDown(self.setupFrame.tab.tabs[1],220,10):AddText("|cffffd100"..L.ReminderCountdownVoice..":"):Size(270):Point("TOPLEFT",self.setupFrame.countdownTypeText,"BOTTOMLEFT",0,-5)
	do
		local function countdownVoice_SetValue(_,arg1)
			ELib:DropDownClose()
			module.options.setupFrame.data.countdownVoice = arg1
			local val = ExRT.F.table_find3(module.datas.vcountdowns,arg1,1)
			if val then
				self.setupFrame.countdownVoice:SetText(val[2])
			else
				self.setupFrame.countdownVoice:SetText("-")
			end
		end
		self.setupFrame.countdownVoice.SetValue = countdownVoice_SetValue

		local List = self.setupFrame.countdownVoice.List
		for i=1,#module.datas.vcountdowns do
			List[#List+1] = {
				text = module.datas.vcountdowns[i][2],
				arg1 = module.datas.vcountdowns[i][1],
				func = countdownVoice_SetValue,
			}
		end
	end

	self.setupFrame.copyCheck = ELib:Check(self.setupFrame.tab.tabs[1],L.ReminderCopyLabel..":"):Point("TOPLEFT",self.setupFrame.countdownVoice,"BOTTOMLEFT",0,-5):Left(5):Tooltip(L.ReminderCopyLabelTooltip):OnClick(function(self)
		if self:GetChecked() then
			module.options.setupFrame.data.copy = true
		else
			module.options.setupFrame.data.copy = nil
		end
	end)

	self.setupFrame.disableRewrite = ELib:Check(self.setupFrame.tab.tabs[1],L.ReminderDisableRewrite..":"):Point("TOPLEFT",self.setupFrame.copyCheck,"BOTTOMLEFT",0,-5):Left(5):Tooltip(L.ReminderDisableRewriteTooltip):OnClick(function(self)
		if self:GetChecked() then
			module.options.setupFrame.data.norewrite = true
		else
			module.options.setupFrame.data.norewrite = nil
		end
	end)

	self.setupFrame.disableDynamicUpdates = ELib:Check(self.setupFrame.tab.tabs[1],L.ReminderDisableDynamicUpdates..":"):Point("TOPLEFT",self.setupFrame.disableRewrite,"BOTTOMLEFT",0,-5):Left(5):Tooltip(L.ReminderDisableDynamicUpdatesTooltip):OnClick(function(self)
		if self:GetChecked() then
			module.options.setupFrame.data.dynamicdisable = true
		else
			module.options.setupFrame.data.dynamicdisable = nil
		end
	end)

	self.setupFrame.glowTypeEdit = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.glowTypes):AddText("|cffffd100"..L.ReminderGlowType..":"):Size(270):Point("TOPLEFT",self.setupFrame.disableDynamicUpdates,"BOTTOMLEFT",0,-5)
	do
		local function glowType_SetValue(_,glowType)
			module.options.setupFrame.data.glowType = glowType
			local glow = ExRT.F.table_find3(module.datas.glowTypes,glowType,1)
			if glow then
				self.setupFrame.glowTypeEdit:SetText(glow[2])
			else
				self.setupFrame.glowTypeEdit:SetText(L.ReminderGlowType.." "..(glowType or 0))
			end
			ELib:DropDownClose()

			if glowType == 6 then
				module.options.setupFrame.glowImage:Point("TOPLEFT",module.options.setupFrame.glowTypeEdit,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.glowImage:Show()

				module.options.setupFrame.glowImage:SetValue(module.options.setupFrame.data.glowImage)
			elseif not module.options.setupFrame.glowImage.ignoreRepos then
				module.options.setupFrame.glowImage:Point("TOPLEFT",module.options.setupFrame.glowTypeEdit,"TOPLEFT",0,0)
				module.options.setupFrame.glowImage:Hide()
			end

			if not glowType or glowType == 1 or glowType == 4 or glowType == 7 then
				module.options.setupFrame.glowThickEdit:Point("TOPLEFT",module.options.setupFrame.glowColorEdit,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.glowThickEdit:Show()
			else
				module.options.setupFrame.glowThickEdit:Point("TOPLEFT",module.options.setupFrame.glowColorEdit,"TOPLEFT",0,0)
				module.options.setupFrame.glowThickEdit:Hide()
			end

			if not glowType or glowType == 1 or glowType == 2 or glowType == 3 or glowType == 6 then
				module.options.setupFrame.glowScaleEdit:Point("TOPLEFT",module.options.setupFrame.glowThickEdit,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.glowScaleEdit:Show()
			else
				module.options.setupFrame.glowScaleEdit:Point("TOPLEFT",module.options.setupFrame.glowThickEdit,"TOPLEFT",0,0)
				module.options.setupFrame.glowScaleEdit:Hide()
			end

			if not glowType or glowType == 1 or glowType == 3 or glowType == 7 then
				module.options.setupFrame.glowNEdit.leftText:SetText(glowType == 7 and "HP, %:" or L.ReminderGlowParticles..":")
				module.options.setupFrame.glowNEdit:Tooltip(glowType == 7 and L.ReminderExample..": |cff00ff0035|r" or L.ReminderFormatTipNameplateGlowAutocastSize)
				module.options.setupFrame.glowNEdit:Point("TOPLEFT",module.options.setupFrame.glowScaleEdit,"BOTTOMLEFT",0,-5)
				module.options.setupFrame.glowNEdit:Show()
			elseif not module.options.setupFrame.glowNEdit.ignoreRepos then
				module.options.setupFrame.glowNEdit:Point("TOPLEFT",module.options.setupFrame.glowScaleEdit,"TOPLEFT",0,0)
				module.options.setupFrame.glowNEdit:Hide()
			end
		end
		self.setupFrame.glowTypeEdit.SetValue = glowType_SetValue

		local List = self.setupFrame.glowTypeEdit.List
		for i=1,#module.datas.glowTypes do
			List[#List+1] = {
				text = module.datas.glowTypes[i][2],
				arg1 = module.datas.glowTypes[i][1],
				func = glowType_SetValue,
			}
		end
	end

	self.setupFrame.glowImage = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.glowImages):AddText("|cffffd100"..L.ReminderGlowImage..":"):Size(270):Point("TOPLEFT",self.setupFrame.glowTypeEdit,"TOPLEFT",0,0):Shown(false)
	do
		local function glowImage_SetValue(_,glowImage)
			module.options.setupFrame.glowImage.preview:SetTexture()

			local isCustomImg
			if glowImage == 0 or type(glowImage) == 'string' then
				isCustomImg = true
				glowImage = glowImage ~= 0 and glowImage or nil
			end
			module.options.setupFrame.data.glowImage = glowImage
			local glow = ExRT.F.table_find3(module.datas.glowImages,glowImage,1)
			if isCustomImg then
				self.setupFrame.glowImage:SetText(L.ReminderCustom)
				self.setupFrame.glowImageCustomEdit:SetText(glowImage or "")
				self.setupFrame.glowImageCustomEdit:Point("TOPLEFT",self.setupFrame.glowImage,"BOTTOMLEFT",0,-5)
				self.setupFrame.glowImageCustomEdit:Show()
			elseif glow then
				self.setupFrame.glowImage:SetText(glow[2])
				self.setupFrame.glowImageCustomEdit:Point("TOPLEFT",self.setupFrame.glowImage,"TOPLEFT",0,0)
				self.setupFrame.glowImageCustomEdit:Hide()
			else
				self.setupFrame.glowImage:SetText("Glow image "..(glowImage or 0))
				self.setupFrame.glowImageCustomEdit:Point("TOPLEFT",self.setupFrame.glowImage,"TOPLEFT",0,0)
				self.setupFrame.glowImageCustomEdit:Hide()
			end
			module.options.setupFrame.glowImage.preview:Update()
			ELib:DropDownClose()
		end
		self.setupFrame.glowImage.SetValue = glowImage_SetValue

		local List = self.setupFrame.glowImage.List
		for i=1,#module.datas.glowImages do
			List[#List+1] = {
				text = module.datas.glowImages[i][2],
				arg1 = module.datas.glowImages[i][1],
				func = glowImage_SetValue,
				icon = module.datas.glowImages[i][3],
				iconcoord = module.datas.glowImages[i][6],
			}
		end

		self.setupFrame.glowImage:SetScript("OnHide",function()
			self.setupFrame.glowImageCustomEdit:Point("TOPLEFT",self.setupFrame.glowImage,"TOPLEFT",0,0)
			self.setupFrame.glowImageCustomEdit:Hide()
		end)
	end
	self.setupFrame.glowImage.preview = self.setupFrame.glowImage:CreateTexture()
	self.setupFrame.glowImage.preview:SetPoint("LEFT",self.setupFrame.glowImage,"RIGHT",5,0)
	self.setupFrame.glowImage.preview:SetSize(30,30)
	self.setupFrame.glowImage.preview.Update = function(self)
		local glowImage = module.options.setupFrame.data.glowImage
		if type(glowImage) == 'string' then
			if glowImage:find("^A:") then
				self:SetTexCoord(0,1,0,1)
				self:SetAtlas(glowImage:sub(3))
			else
				self:SetTexture(glowImage)
				self:SetTexCoord(0,1,0,1)
			end
		else
			glowImage = ExRT.F.table_find3(module.datas.glowImages,glowImage,1)
			if glowImage then
				self:SetTexture(glowImage[3])
				if glowImage[6] then
					self:SetTexCoord(unpack(glowImage[6]))
				else
					self:SetTexCoord(0,1,0,1)
				end
			else
				self:SetTexture()
			end
		end
	end

	self.setupFrame.glowImageCustomEdit = ELib:Edit(self.setupFrame.glowImage):Size(270,20):Point("TOPLEFT",self.setupFrame.glowImage,"TOPLEFT",0,0):LeftText(L.ReminderGlowImageCustom..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		module.options.setupFrame.data.glowImage = text
		module.options.setupFrame.glowImage.preview:Update()
	end):Shown(false)


	self.setupFrame.glowColorEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(100,20):Point("TOPLEFT",self.setupFrame.glowImageCustomEdit,"BOTTOMLEFT",0,-5):LeftText(COLOR..":"):Run(function(s) 
		s:Disable() 
		s:SetTextColor(.35,.35,.35) 
		s:SetScript("OnMouseDown",function()
			s:Enable()
		end)
	end):OnChange(function(self,isUser)
		if not isUser then
			return
		end
		local text = self:GetText()
		if text == "" then
			module.options.setupFrame.data.glowColor = nil
			module.options.setupFrame.glowColorEdit.preview:Update()
		elseif text:find("^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$") then
			module.options.setupFrame.data.glowColor = text
			module.options.setupFrame.glowColorEdit.preview:Update()
			self:Disable()
		end
	end)
	self.setupFrame.glowColorEdit.preview = ELib:Texture(self.setupFrame.glowColorEdit,1,1,1,1):Point("LEFT",'x',"RIGHT",5,0):Size(40,20)
	self.setupFrame.glowColorEdit.preview.Update = function(self)
		local t = self:GetParent():GetText()
		local at,rt,gt,bt = t:match("(..)(..)(..)(..)")
		if bt then
			local r,g,b,a = tonumber(rt,16),tonumber(gt,16),tonumber(bt,16),tonumber(at,16)
			self:SetColorTexture(r/255,g/255,b/255,a/255)
		else
			self:SetColorTexture(1,1,1,1)
		end
	end

	self.setupFrame.glowColorEdit.colorButton = CreateFrame("Button",nil,self.setupFrame.glowColorEdit)
	self.setupFrame.glowColorEdit.colorButton:SetPoint("LEFT", self.setupFrame.glowColorEdit.preview, "RIGHT", 5, 0)
	self.setupFrame.glowColorEdit.colorButton:SetSize(24,24)
	self.setupFrame.glowColorEdit.colorButton:SetScript("OnClick",function(self)
		local r,g,b,a
		if module.options.setupFrame.data.glowColor then
			local at,rt,gt,bt = module.options.setupFrame.data.glowColor:match("(..)(..)(..)(..)")
			if bt then
				r,g,b,a = tonumber(rt,16)/255,tonumber(gt,16)/255,tonumber(bt,16)/255,tonumber(at,16)/255
			end
		end
		r,g,b,a = r or 1,g or 1,b or 1,a or 1

		if not ColorPickerFrame.SetupColorPickerAndShow then
			ColorPickerFrame.previousValues = {r,g,b,a}
			ColorPickerFrame.hasOpacity = true
	
			local nilFunc = ExRT.NULLfunc
			local function changedCallback(restore)
				local newR, newG, newB, newA
				if restore then
					newR, newG, newB, newA = unpack(restore)
				else
					newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
				end
				module.options.setupFrame.data.glowColor = format("%02x%02x%02x%02x",newA*255,newR*255,newG*255,newB*255)
	
				module.options.setupFrame.glowColorEdit:SetText(module.options.setupFrame.data.glowColor)
				module.options.setupFrame.glowColorEdit:Disable()
				module.options.setupFrame.glowColorEdit.preview:Update()
			end
			ColorPickerFrame.func, ColorPickerFrame.cancelFunc, ColorPickerFrame.opacityFunc = nilFunc, nilFunc, nilFunc
			ColorPickerFrame.opacity = a
			ColorPickerFrame:SetColorRGB(r,g,b)
			ColorPickerFrame.opacityFunc = changedCallback
			ColorPickerFrame:Show()
		else
			local info = {}
			info.r, info.g, info.b = r,g,b
			info.opacity = a
			info.hasOpacity = true
			info.swatchFunc = function()
				local newR, newG, newB = ColorPickerFrame:GetColorRGB()
				local newA = ColorPickerFrame:GetColorAlpha()
				module.options.setupFrame.data.glowColor = format("%02x%02x%02x%02x",newA*255,newR*255,newG*255,newB*255)
	
				module.options.setupFrame.glowColorEdit:SetText(module.options.setupFrame.data.glowColor)
				module.options.setupFrame.glowColorEdit:Disable()
				module.options.setupFrame.glowColorEdit.preview:Update()
			end
			info.cancelFunc = function()
				local newR, newG, newB, newA = ColorPickerFrame:GetPreviousValues()
				module.options.setupFrame.data.glowColor = format("%02x%02x%02x%02x",newA*255,newR*255,newG*255,newB*255)
	
				module.options.setupFrame.glowColorEdit:SetText(module.options.setupFrame.data.glowColor)
				module.options.setupFrame.glowColorEdit:Disable()
				module.options.setupFrame.glowColorEdit.preview:Update()
			end
			ColorPickerFrame:SetupColorPickerAndShow(info)
		end
	end)
	self.setupFrame.glowColorEdit.colorButton:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L.ReminderSelectColor)
		GameTooltip:Show()
	end)
	self.setupFrame.glowColorEdit.colorButton:SetScript("OnLeave",function(self)
		GameTooltip_Hide()
	end)
	self.setupFrame.glowColorEdit.colorButton.Texture = self.setupFrame.glowColorEdit.colorButton:CreateTexture(nil,"ARTWORK")
	self.setupFrame.glowColorEdit.colorButton.Texture:SetPoint("CENTER")
	self.setupFrame.glowColorEdit.colorButton.Texture:SetSize(20,20)
	self.setupFrame.glowColorEdit.colorButton.Texture:SetTexture([[Interface\AddOns\MRT\media\wheeltexture]])


	self.setupFrame.glowThickEdit = ELib:Edit(self.setupFrame.glowTypeEdit):Size(270,20):Point("TOPLEFT",self.setupFrame.glowColorEdit,"BOTTOMLEFT",0,-5):LeftText(L.ReminderGlowThick..":"):OnChange(function(self,isUser)
		if not isUser then return end
		module.options.setupFrame.data.glowThick = tonumber( self:GetText() )
	end):Tooltip(L.ReminderFormatTipNameplateGlowSize)

	self.setupFrame.glowScaleEdit = ELib:Edit(self.setupFrame.glowTypeEdit):Size(270,20):Point("TOPLEFT",self.setupFrame.glowThickEdit,"BOTTOMLEFT",0,-5):LeftText(L.ReminderGlowScale..":"):OnChange(function(self,isUser)
		if not isUser then return end
		module.options.setupFrame.data.glowScale = tonumber( self:GetText() )
	end):Tooltip(L.ReminderFormatTipNameplateGlowScale)

	self.setupFrame.glowNEdit = ELib:Edit(self.setupFrame.glowTypeEdit):Size(270,20):Point("TOPLEFT",self.setupFrame.glowScaleEdit,"BOTTOMLEFT",0,-5):LeftText(L.ReminderGlowParticles..":"):OnChange(function(self,isUser)
		if not isUser then return end
		module.options.setupFrame.data.glowN = tonumber( self:GetText() )
	end):Tooltip(L.ReminderFormatTipNameplateGlowAutocastSize)

	self.setupFrame.customOpt1 = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):Point("TOPLEFT",self.setupFrame.glowNEdit,"BOTTOMLEFT",0,-5):LeftText("Custom ticks:"):Tooltip(L.ReminderExample..":\n3\n2.5,5,7.5"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		module.options.setupFrame.data.customOpt1 = text
	end):Shown(false)

	self.setupFrame.debugCheck = ELib:Check(self.setupFrame.tab.tabs[1],"Debug:"):Point("TOPLEFT",self.setupFrame.customOpt1,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		if self:GetChecked() then
			module.options.setupFrame.data.debug = true
		else
			module.options.setupFrame.data.debug = nil
		end
	end):Shown(module.db.debug)


	self.setupFrame.disableCheck = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalDisable..":"):Point("TOPLEFT",350,-10):Left(5):OnClick(function(self)
		UpdateOption(module.options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,0))
	end)

	self.setupFrame.disableSound = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalSoundDisable..":"):Point("TOPLEFT",self.setupFrame.disableCheck,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		UpdateOption(module.options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,1))
	end)

	self.setupFrame.disableUpdates = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalUpdateDisable..":"):Point("TOPLEFT",self.setupFrame.disableSound,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		UpdateOption(module.options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,2))
	end)

	self.setupFrame.disableUpdatesSound = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalUpdateSoundDisable..":"):Point("TOPLEFT",self.setupFrame.disableUpdates,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		UpdateOption(module.options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,4))
	end)

	self.setupFrame.disableSynq = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalSendDisable..":"):Point("TOPLEFT",self.setupFrame.disableUpdatesSound,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		UpdateOption(module.options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,3))
	end)



	self.setupFrame.bossList = ELib:DropDown(self.setupFrame.tab.tabs[3],270,15):AddText("|cffffd100"..L.ReminderBoss..":"):Size(270):Point("TOPLEFT",180,-10)
	do
		local List = self.setupFrame.bossList.List
		local function bossList_SetValue(_,encounterID)
			if encounterID and encounterID ~= 0 and ExRT.F.table_find(List,encounterID,"arg1") then
				self.setupFrame.bossCustom:Shown(false):Point("TOPLEFT",self.setupFrame.bossList,"TOPLEFT",0,0)
				self.setupFrame.bossList:SetText(L.bossName[ encounterID ])
			elseif not encounterID then
				self.setupFrame.bossCustom:Shown(false):Point("TOPLEFT",self.setupFrame.bossList,"TOPLEFT",0,0)
				self.setupFrame.bossList:SetText("-")
			else
				self.setupFrame.bossCustom:Shown(true):Point("TOPLEFT",self.setupFrame.bossList,"BOTTOMLEFT",0,-5)
				self.setupFrame.bossList:SetText(L.ReminderCustomEncounterID)
			end
			if encounterID ~= 0 then
				module.options.setupFrame.data.bossID = encounterID
			end
			module.options.setupFrame.tab.tabs[3].button.alert:Update()
			ELib:DropDownClose()
		end
		self.setupFrame.bossList.SetValue = bossList_SetValue

		List[#List+1] = {
			text = "-",
			func = bossList_SetValue,
		}
		for i=1,#encountersList do
			local instance = encountersList[i]
			List[#List+1] = {
				text = type(instance[1])=='string' and instance[1] or GetMapNameByID(instance[1]) or "???",
				isTitle = true,
			}
			for j=2,#instance do
				List[#List+1] = {
					text = L.bossName[ instance[j] ],
					arg1 = instance[j],
					func = bossList_SetValue,
				}
			end
		end
		List[#List+1] = {
			text = OTHER,
			isTitle = true,
		}
		List[#List+1] = {
			text = L.ReminderCustomEncounterID,
			arg1 = 0,
			func = bossList_SetValue,
		}
	end

	self.setupFrame.bossCustom = ELib:Edit(self.setupFrame.tab.tabs[3]):Size(270,20):Point("TOPLEFT",self.setupFrame.bossList,"TOPLEFT",0,0):LeftText(L.ReminderEncounterID..":"):Shown(false):OnChange(function(self,isUser)
		if not isUser then return end
		module.options.setupFrame.data.bossID = tonumber(self:GetText())
		module.options.setupFrame.tab.tabs[3].button.alert:Update()
	end):Tooltip(function()
		if module.db.lastEncounterID then
			return L.ReminderEncounterIDLast..": "..module.db.lastEncounterID
		else
			return L.ReminderEncounterIDLastNoData
		end
	end)

	self.setupFrame.bossList.auto = ELib:Button(self.setupFrame.tab.tabs[3],L.ReminderAuto):Tooltip(L.ReminderEncounterIDLastAutoTip):Point("LEFT",self.setupFrame.bossList,"RIGHT",5,0):Size(40,20):OnClick(function()
		module.options.setupFrame.data.bossID = module.db.lastEncounterID
		module.options.setupFrame.tab.tabs[3].button.alert:Update()
		self.setupFrame:Update(self.setupFrame.data)
	end):OnShow(function(self)
		if module.db.lastEncounterID then
			self:Enable()
		else
			self:Disable()
		end
	end)

	self.setupFrame.bossDiff = ELib:DropDown(self.setupFrame.tab.tabs[3],220,#module.datas.bossDiff):AddText("|cffffd100"..L.ReminderRaidDiff..":"):Size(270):Point("TOPLEFT",self.setupFrame.bossCustom,"BOTTOMLEFT",0,-5)
	do
		local function bossDiff_SetValue(_,diffID)
			module.options.setupFrame.data.diffID = diffID
			local diff = ExRT.F.table_find3(module.datas.bossDiff,diffID,1)
			if diff then
				self.setupFrame.bossDiff:SetText(diff[2])
			else
				self.setupFrame.bossDiff:SetText("Diff ID: "..diffID)
			end
			ELib:DropDownClose()
		end
		self.setupFrame.bossDiff.SetValue = bossDiff_SetValue

		local List = self.setupFrame.bossDiff.List
		for i=1,#module.datas.bossDiff do
			List[#List+1] = {
				text = module.datas.bossDiff[i][2],
				arg1 = module.datas.bossDiff[i][1],
				func = bossDiff_SetValue,
			}
		end
	end

	self.setupFrame.zoneID = ELib:Edit(self.setupFrame.tab.tabs[3]):Size(270,20):Point("TOPLEFT",self.setupFrame.bossDiff,"BOTTOMLEFT",0,-5):LeftText(L.ReminderZoneID..":"):OnChange(function(self,isUser)
		local zoneID = self:GetText():trim()
		if zoneID == "" then zoneID = nil end
		local extraFilled
		if zoneID then
			local instanceID = ExRT.GDB.MapIDToJournalInstance[tonumber(zoneID) or tonumber(strsplit(",",zoneID),10) or ""]
			if instanceID and EJ_GetInstanceInfo then
				local name = EJ_GetInstanceInfo(instanceID)
				if name then
					self:ExtraText(name)
					extraFilled = true
				end
			end
			if zoneID == "-1" then
				self:ExtraText(ALWAYS)
				extraFilled = true
			end
		end
		if not extraFilled then
			self:ExtraText("")
		end
		if not isUser then return end
		module.options.setupFrame.data.zoneID = zoneID
		module.options.setupFrame.tab.tabs[3].button.alert:Update()
	end):Tooltip(function()
		local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
		return L.ReminderZoneIDTip1..(name or "")..L.ReminderZoneIDTip2..(instanceID or 0)
	end)

	self.setupFrame.zoneID.dd = ELib:DropDownButton(self,"",250,#ExRT.GDB.JournalInstance+3)
	self.setupFrame.zoneID.dd.isModern = true
	do
		local function SetZone(_,arg)
			module.options.setupFrame.data.zoneID = tostring(arg)
			ELib:DropDownClose()
			module.options.setupFrame.tab.tabs[3].button.alert:Update()
			self.setupFrame:Update(self.setupFrame.data)
		end
		self.setupFrame.zoneID.dd.List = {
			{text = L.ReminderZoneIDAutoTip,func = function()
				local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
				SetZone(nil,instanceID)
			end},
			{text = ALWAYS,func = function()
				SetZone(nil,-1)
			end},
			{text = L.minimapmenuclose,func = ELib.ScrollDropDown.Close},
		}
		if EJ_GetInstanceInfo then
			for i=1,#ExRT.GDB.JournalInstance do
				local line = ExRT.GDB.JournalInstance[i]
				local subMenu = {}
				for j=2,#line do 
					if line[j] == 0 then
						subMenu[#subMenu+1] = {
							text = " ",
							isTitle = true,
						}
					else
						local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(line[j])
						if mapID then
							subMenu[#subMenu+1] = {
								text = name,
								arg1 = mapID,
								func = SetZone,
							}
						end
					end
				end
				tinsert(self.setupFrame.zoneID.dd.List, 2, {text = (line[1] == -1 and (EXPANSION_SEASON_NAME or "%s Season %d"):format(EXPANSION_NAME9,999):gsub("999",""):gsub("%-й *","") or line[1] == -2 and "New" or _G["EXPANSION_NAME"..line[1]] or "Expansion "..line[1]),subMenu = subMenu})
			end
		end
	end
	self.setupFrame.zoneID.dd:Hide()

	self.setupFrame.zoneID.auto = ELib:Button(self.setupFrame.tab.tabs[3],LFG_LIST_SELECT or "Select"):Tooltip(L.ReminderZoneIDAutoTip):Point("LEFT",self.setupFrame.zoneID,"RIGHT",5,0):Size(40,20):OnClick(function()
		--[[
		local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
		module.options.setupFrame.data.zoneID = tostring(instanceID)
		module.options.setupFrame.tab.tabs[3].button.alert:Update()
		self.setupFrame:Update(self.setupFrame.data)
		]]
		self.setupFrame.zoneID.dd:Click()
	end)

	self.setupFrame.zoneID.dd:SetAllPoints(self.setupFrame.zoneID.auto)

	ELib:DecorationLine(self.setupFrame.tab.tabs[3]):Point("TOP",self.setupFrame.zoneID,"BOTTOM",0,-5):Point("LEFT",self.setupFrame,0,0):Point("RIGHT",self.setupFrame,0,0):Size(0,1)

	self.setupFrame.allPlayersCheck = ELib:Check(self.setupFrame.tab.tabs[3],L.ReminderAllPlayers..":"):Point("TOPLEFT",self.setupFrame.zoneID,"BOTTOMLEFT",0,-10):Left(5):OnClick(function(self)
		if self:GetChecked() then
			module.options.setupFrame.data.allPlayers = true
		else
			module.options.setupFrame.data.allPlayers = nil
		end
	end)

	self.setupFrame.playersChecks = {}
	for i=1,6 do
		self.setupFrame.playersChecks[i] = {}
		for j=1,5 do
			local chk = ELib:Check(self.setupFrame.tab.tabs[3],"Player "..((i-1)*5+j)):Point("LEFT",10+(j-1)*100,0):Point("TOP",self.setupFrame.allPlayersCheck,"BOTTOM",0,-5 -(i-1)*25):OnClick(function(self)
				if self:GetChecked() then
					module.options.setupFrame.data.players[self.playerName] = true
				else
					module.options.setupFrame.data.players[self.playerName] = nil
				end
				module.options.setupFrame.data.allPlayers = nil
				module.options.setupFrame.allPlayersCheck:SetChecked(false)
			end)
			self.setupFrame.playersChecks[i][j] = chk
			chk.text:SetWidth(80)
			chk.text:SetJustifyH("LEFT")
			chk.playerName = "Player "..((i-1)*5+j)
		end
	end
	self.setupFrame.playersChecksList = {}

	function self.setupFrame:UpdatePlayersChecks()
		wipe(self.playersChecksList)

		local g = {0,0,0,0,0,0}
		for _, name, subgroup, class, guid, rank, level, online, isDead, combatRole in ExRT.F.IterateRoster, ExRT.F.GetRaidDiffMaxGroup() do
			if subgroup <= 6 then
				g[subgroup] = g[subgroup]+1
				if g[subgroup] <= 5 then
					name = ExRT.F.delUnitNameServer(name)

					local classColor = RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr or ""
					local chk = self.playersChecks[subgroup][ g[subgroup] ]
					chk:SetText(classColor..name)
					chk:SetChecked(false)
					chk.playerName = name
					chk:Show()

					self.playersChecksList[name] = chk
				end
			end
		end
		for i=1,6 do
			for j=g[i]+1,5 do
				self.playersChecks[i][j]:Hide()
			end
		end

	end

	self.setupFrame.customPlayerList = ELib:Edit(self.setupFrame.tab.tabs[3]):Size(270,20):Point("TOPLEFT",self.setupFrame.allPlayersCheck,"BOTTOMLEFT",0,-5-150):LeftText(L.ReminderPlayerNames..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local inRaid = {}
		for _,name in ExRT.F.IterateRoster do
			inRaid[ExRT.F.delUnitNameServer(name)] = true
		end
		for k,v in pairs(module.options.setupFrame.data.players) do
			if not inRaid[k] then
				module.options.setupFrame.data.players[k] = nil
			end
		end
		local names = {strsplit(" ",self:GetText():gsub(" +"," "):trim(),nil)}
		for i=1,#names do
			module.options.setupFrame.data.players[ names[i] ]=true
		end
		if #names > 0 then
			module.options.setupFrame.data.allPlayers = nil
			module.options.setupFrame.allPlayersCheck:SetChecked(false)
		end
	end):Tooltip(L.ReminderPlayerNamesTip)

	self.setupFrame.notePatternEdit = ELib:Edit(self.setupFrame.tab.tabs[3]):Size(270,20):Point("TOPLEFT",self.setupFrame.customPlayerList,"BOTTOMLEFT",0,-5):LeftText(L.ReminderNotePatt..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		module.options.setupFrame.data.notePattern = text
		if text ~= nil then
			module.options.setupFrame.data.allPlayers = nil
			module.options.setupFrame.allPlayersCheck:SetChecked(false)
		end
	end):Tooltip(function()
		local str = L.ReminderNotePattTip1
		local isOkay,list = pcall(module.FindPlayersListInNote,0,module.options.setupFrame.data.notePattern)
		if isOkay and list then
			str = str .. L.ReminderNotePattTip2..list:gsub("([%S]+)",function(name)
				if not UnitName(name) then
					return "|cffaaaaaa"..name.."|r"
				end
			end)
		end
		return str
	end)

	ELib:DecorationLine(self.setupFrame.tab.tabs[3]):Point("TOP",self.setupFrame.notePatternEdit,"BOTTOM",0,-5):Point("LEFT",self.setupFrame,0,0):Point("RIGHT",self.setupFrame,0,0):Size(0,1)

	self.setupFrame.rolesChecks = {}
	for i=1,#module.datas.rolesList do
		local chk = ELib:Check(self.setupFrame.tab.tabs[3],module.datas.rolesList[i][2]):Point("LEFT",10+((i-1)%5)*100,0):Point("TOP",self.setupFrame.notePatternEdit,"BOTTOM",0,-10-floor((i-1)/5)*25):OnClick(function(self)
			if self:GetChecked() then
				module.options.setupFrame.data["role"..self.token] = true
			else
				module.options.setupFrame.data["role"..self.token] = nil
			end
			module.options.setupFrame.data.allPlayers = nil
			module.options.setupFrame.allPlayersCheck:SetChecked(false)
		end)
		self.setupFrame.rolesChecks[i] = chk
		chk.text:SetWidth(80)
		chk.text:SetJustifyH("LEFT")

		chk.token = module.datas.rolesList[i][1]
	end

	ELib:DecorationLine(self.setupFrame.tab.tabs[3]):Point("TOP",self.setupFrame.rolesChecks[1],"BOTTOM",0,-5-25):Point("LEFT",self.setupFrame,0,0):Point("RIGHT",self.setupFrame,0,0):Size(0,1)

	self.setupFrame.classChecks = {}
	for j=1,#ExRT.GDB.ClassList do
		local i = ((j - 1) % 5) + 1
		local class = ExRT.GDB.ClassList[j]
		local className = L.classLocalizate[class]
		local classColor = RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr or ""
		local chk = ELib:Check(self.setupFrame.tab.tabs[3],classColor..className):Point("LEFT",10+(i-1)*100,0):Point("TOP",self.setupFrame.rolesChecks[1],"BOTTOM",0,-10-25-25*floor((j-1)/5)):OnClick(function(self)
			if self:GetChecked() then
				module.options.setupFrame.data["class"..self.token] = true
			else
				module.options.setupFrame.data["class"..self.token] = nil
			end
			module.options.setupFrame.data.allPlayers = nil
			module.options.setupFrame.allPlayersCheck:SetChecked(false)
		end)
		self.setupFrame.classChecks[j] = chk
		chk.text:SetWidth(80)
		chk.text:SetJustifyH("LEFT")

		chk.token = class
	end

	ELib:DecorationLine(self.setupFrame.tab.tabs[3]):Point("TOP",self.setupFrame.classChecks[1],"BOTTOM",0,-5-50):Point("LEFT",self.setupFrame,0,0):Point("RIGHT",self.setupFrame,0,0):Size(0,1)

	self.setupFrame.neverCheck = ELib:Check(self.setupFrame.tab.tabs[3],L.ReminderDisable..":"):Point("LEFT",self.setupFrame.allPlayersCheck,"LEFT",0,0):Point("TOP",self.setupFrame.classChecks[1],"BOTTOM",0,-10-50):Left(5):OnClick(function(self)
		if self:GetChecked() then
			module.options.setupFrame.data.disabled = true
		else
			module.options.setupFrame.data.disabled = nil
		end
	end):Tooltip(L.ReminderDisableTip)



	self.setupFrame.triggersScrollFrame = ELib:ScrollFrame(self.setupFrame.tab.tabs[2]):Point("TOP",0,0):Size(510,505):Height(500)
	ELib:Border(self.setupFrame.triggersScrollFrame,0)

	ELib:DecorationLine(self.setupFrame.tab.tabs[2]):Point("TOP",self.setupFrame.triggersScrollFrame,"BOTTOM",0,0):Point("LEFT",self.setupFrame,0,0):Point("RIGHT",self.setupFrame,0,0):Size(0,1)

	self.setupFrame.triggersScrollFrame.triggers = {}

	local function TriggerButton_Update(self)
		if self.state == 1 then
			self.expandIcon.texture:SetTexCoord(0.375,0.4375,0.5,0.625)
			self.sub:Hide()
			self.sub:SetHeight(1)
		elseif self.state == 2 then
			self.expandIcon.texture:SetTexCoord(0.25,0.3125,0.5,0.625)
			self.sub:Show()
			self.sub:SetHeight(self.HEIGHT or 10)
		end

		local heightNow = 5 + 30 + (30 + (module.options.setupFrame.triggersScrollFrame.generalOptions.sub:IsShown() and (module.options.setupFrame.triggersScrollFrame.generalOptions.HEIGHT or 10) or 1))
		for _,t in pairs(module.options.setupFrame.triggersScrollFrame.triggers) do
			if t:IsShown() then
				local height = t.HEIGHT or 10
				heightNow = heightNow + 5 + 30 + (t.sub:IsShown() and height or 1)
			end
		end
		module.options.setupFrame.triggersScrollFrame:Height(heightNow)
	end

	function self.setupFrame.UpdateTriggerAlerts(button)
		local triggerData = module.options.setupFrame.data.triggers[button.num]
		if not triggerData then
			return
		end
		if module.C[triggerData.event] then
			local alertFields = module.C[triggerData.event].alertFields
			if alertFields then
				local alertType = 1
				local toHide
				for i,v in ipairs(alertFields) do
					if v == 0 then
						alertType = 2
						for j=i+1,#alertFields do
							if triggerData[ alertFields[j] ] then
								toHide = true
								break
							end
						end
					else
						local field = button[v]
						if (alertType == 1 and not triggerData[v]) or (alertType == 2 and not toHide) then
							if not field.alert then
								field.alert = CreateAlertIcon(field,L.ReminderAlertFieldReq,L.ReminderAlert,true)
							end
							field.alert:SetType(alertType)
							field.alert:Show()
						elseif field.alert then
							field.alert:Hide()
						end
					end
				end
			end
		end
	end

	function self.setupFrame:UpdateTriggerFieldsForEvent(button,event)
		for _,v in pairs(module.datas.fields) do
			local b = button[v]
			b:Hide()
			if b.alert then
				b.alert:Hide()
			end
			if b.repText then
				if b.LeftText then
					b:LeftText(b.repText)
				elseif b.SetText then
					b:SetText(b.repText)
				end
				b.repText = nil
			end
			if b.repTipText then
				b.tooltipText = b.repTipText
				b.repTipText = nil
			end
		end
		local eventDB = module.C[event]
		if not eventDB then
			return
		end

		local height = 0
		local prev = "eventDropDown"
		for _,v in ipairs(eventDB.triggerFields) do
			height = height + 25
			button[v]:Point("TOPLEFT",button[prev],"BOTTOMLEFT",0,-5-(prev == "spellID" and 25 or 0))
			button[v]:Show()
			prev = v
			if v == "spellID" then
				height = height + 25
			end
		end
		button.HEIGHT = 30 + height
		button:Update()

		if eventDB.main_id == 1 then
			button.eventDropDown:SetText(module.C[1].lname)
			button.eventCLEU:SetText(eventDB.lname)
		else
			button.eventDropDown:SetText(eventDB.lname)
		end

		if eventDB.fieldNames then
			for v,text in pairs(eventDB.fieldNames) do
				local b = button[v]
				if b.LeftText then
					b.repText = b.leftText:GetText()
					b:LeftText(text)
				elseif b.SetText then
					b.repText = b:GetText()
					b:SetText(text)
				end
			end
		end
		if eventDB.fieldTooltips then
			for v,text in pairs(eventDB.fieldTooltips) do
				local b = button[v]
				b.repTipText = b.tooltipText
				b.tooltipText = text
			end
		end

		if eventDB.help or eventDB.replaceres then
			if not button.eventDropDown.help then
				button.eventDropDown.help = CreateAlertIcon(button.eventDropDown,nil,nil,true)
			end
			button.eventDropDown.help:SetType(3)
			button.eventDropDown.help:Show()

			local text = eventDB.help or ""
			if eventDB.replaceres then
				text = text .. (text ~= "" and "\n" or "") .. L.ReminderReplacers
				for _,v in ipairs(eventDB.replaceres) do
					text = text .. "\n|cffffffff%" .. v .. "|r - ".. (eventDB.replaceres[v] or L["ReminderReplacer"..v])
				end
			end
			button.eventDropDown.help.tooltip = text
			button.eventDropDown.help.tooltipTitle = eventDB.lname
		elseif button.eventDropDown.help then
			button.eventDropDown.help:Hide()
		end

		button:UpdateTriggerAlerts()
	end

	local COLOR_BORDER_FULL = {CreateColor(0, 0, 0, 0.3), CreateColor(0, .5, 0, 0.3)}
	local COLOR_BORDER_EMPTY = {0,0,0,.3}
	local COLOR_BORDER_ALERT = {CreateColor(0, 0, 0, 0.3), CreateColor(.5, 0, 0, 0.3)}

	do
		local button = ELib:Button(self.setupFrame.triggersScrollFrame.C,L.ReminderTriggerOptionsGen):Size(480,25):OnClick(function(self)
			self.state = self.state == 1 and 2 or 1
			self:Update()
		end)
		self.setupFrame.triggersScrollFrame.generalOptions = button

		button:Point("TOP",0,-5)

		local textObj = button:GetTextObj()
		textObj:ClearAllPoints()
		textObj:SetJustifyH("LEFT")
		textObj:SetPoint("LEFT",60,0)
		textObj:SetPoint("RIGHT",-10,0)
		textObj:SetPoint("TOP",0,0)
		textObj:SetPoint("BOTTOM",0,0)

		button.expandIcon = ELib:Icon(button,"Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128",18):Point("RIGHT",-5,0)

		button.sub = CreateFrame("Frame",nil,button)
		button.sub:Hide()
		button.sub:SetPoint("TOPLEFT",button,"BOTTOMLEFT",0,-1)
		button.sub:SetPoint("TOPRIGHT",button,"BOTTOMRIGHT",0,-1)
		ELib:Border(button.sub,1,0,0,0,1)
		button.sub:SetHeight(1)

		button.sub.back = button.sub:CreateTexture(nil,"BACKGROUND")
		button.sub.back:SetAllPoints()
		button.sub.back:SetColorTexture(.2,.2,.2,.9)

		button.Update = TriggerButton_Update
		button.state = 1
		button:Update()

		button.HEIGHT = 5 + 25 * 4

		local function CheckDelayTimeText(text)
			if not text then
				return false
			else
				for c in string_gmatch(text, "[^ ,]+") do
					if not (tonumber(c) or c:find("%d+:%d+%.?%d*")) then
						return false
					end
				end
				return true
			end
		end

		self.setupFrame.delayedActivation = ELib:Edit(button.sub):Size(270,20):Point(180,-5):LeftText(L.ReminderDelayedActivation..":"):Tooltip(L.ReminderDelayedActivationTooltip):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText()
				if not CheckDelayTimeText(text) then
					text = nil
				end
				module.options.setupFrame.data.delayedActivation = text
			end
			if module.options.setupFrame.data.delayedActivation then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end)
		self.setupFrame.delayedActivation.Background:SetColorTexture(1,1,1,1)

		self.setupFrame.sametargetsCheck = ELib:Check(button.sub,L.ReminderSameTarget..":"):Point("TOPLEFT",self.setupFrame.delayedActivation,"BOTTOMLEFT",0,-5):Left(5):Tooltip(L.ReminderSameTargetTooltip):OnClick(function(self)
			if self:GetChecked() then
				module.options.setupFrame.data.sametargets = true
			else
				module.options.setupFrame.data.sametargets = nil
			end
		end)
	
		self.setupFrame.specialTarget = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",self.setupFrame.sametargetsCheck,"BOTTOMLEFT",0,-5):LeftText(L.ReminderSpecialTarget..":"):Tooltip(L.ReminderSpecialTargetTooltip):OnChange(function(self,isUser)
			local text = self:GetText():trim()
			if text == "" then text = nil end
			if not text then
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			else
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			end
			if not isUser then return end
			module.options.setupFrame.data.specialTarget = text
		end)
		self.setupFrame.specialTarget.Background:SetColorTexture(1,1,1,1)

		local nulltable = {}
		self.setupFrame.extraCheck = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",self.setupFrame.specialTarget,"BOTTOMLEFT",0,-5):LeftText(L.ReminderTriggerExtraCheck..":"):Tooltip(L.ReminderTriggerExtraCheckTip):OnChange(function(self,isUser)
			local text = self:GetText():trim()
			local isPass, isValid = module:ExtraCheckParams(text,nulltable)
			if text == "" then
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			elseif not isValid then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_ALERT))
			else
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			end
			if not isUser then return end
			if text == "" then text = nil end
			module.options.setupFrame.data.extraCheck = text
		end)
		self.setupFrame.extraCheck.Background:SetColorTexture(1,1,1,1)

		self.setupFrame.extraCheck.help = CreateAlertIcon(self.setupFrame.extraCheck,nil,nil,nil,true)
		self.setupFrame.extraCheck.help:SetPoint("LEFT",self.setupFrame.extraCheck,"RIGHT",3,0)
		self.setupFrame.extraCheck.help:SetType(3)
		self.setupFrame.extraCheck.help:Show()
		self.setupFrame.extraCheck.help.CreateIconsFromList = self.setupFrame.msgEdit.help.CreateIconsFromList
		self.setupFrame.extraCheck.help:SetScript("OnEnter",self.setupFrame.msgEdit.help.msgFunc)
		self.setupFrame.extraCheck.help:SetScript("OnClick",function()
			self.setupFrame.msgEdit.help:Click()
		end)
	end

	local function GetTriggerButton(triggerNum)
		local button = self.setupFrame.triggersScrollFrame.triggers[triggerNum]
		if button then
			return button
		end

		button = ELib:Button(self.setupFrame.triggersScrollFrame.C,L.ReminderTrigger.." "..triggerNum):Size(480,30):OnClick(function(self)
			self.state = self.state == 1 and 2 or 1
			self:Update()
		end)
		self.setupFrame.triggersScrollFrame.triggers[triggerNum] = button

		if triggerNum == 1 then
			--button:Point("TOP",0,-5)
			button:Point("TOP",self.setupFrame.triggersScrollFrame.generalOptions.sub,"BOTTOM",0,-5)
		else
			button:Point("TOP",self.setupFrame.triggersScrollFrame.triggers[triggerNum-1].sub,"BOTTOM",0,-5)
		end

		button.num = triggerNum

		local textObj = button:GetTextObj()
		textObj:ClearAllPoints()
		textObj:SetJustifyH("LEFT")
		textObj:SetPoint("LEFT",60,0)
		textObj:SetPoint("RIGHT",-10,0)
		textObj:SetPoint("TOP",0,0)
		textObj:SetPoint("BOTTOM",0,0)

		button.expandIcon = ELib:Icon(button,"Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128",18):Point("RIGHT",-5,0)

		button.sub = CreateFrame("Frame",nil,button)
		button.sub:Hide()
		button.sub:SetPoint("TOPLEFT",button,"BOTTOMLEFT",0,-1)
		button.sub:SetPoint("TOPRIGHT",button,"BOTTOMRIGHT",0,-1)
		ELib:Border(button.sub,1,0,0,0,1)
		button.sub:SetHeight(1)

		button.sub.back = button.sub:CreateTexture(nil,"BACKGROUND")
		button.sub.back:SetAllPoints()
		button.sub.back:SetColorTexture(.2,.2,.2,.9)

		button.Update = TriggerButton_Update
		button.state = triggerNum == 1 and 2 or 1
		button:Update()

		button.UpdateTriggerAlerts = self.setupFrame.UpdateTriggerAlerts

		button.andor = ELib:Button(button,L.ReminderAnd):Size(45,20):Point("LEFT",10,0):Shown(triggerNum ~= 1):OnClick(function(self)
			self.state = self.state == 1 and 2 or self.state == 2 and 3 or self.state == 3 and 4 or 1
			self:Update()

			module.options.setupFrame.data.triggers[button.num].andor = self.state

			self:GetScript("OnLeave")(self)
			self:GetScript("OnEnter")(self)
		end):OnEnter(function(self)
			local triggers = module.options.setupFrame.data.triggers
			local triggersStr = ""
			local opened = false
			for i=#triggers,2,-1 do
				local trigger = triggers[i]
				if not trigger.andor or trigger.andor == 1 then
					triggersStr = "+"..(opened and "(" or "")..(trigger.invert and "!" or "")..i.. triggersStr
					opened = false
				elseif trigger.andor == 2 then
					triggersStr = " "..L.ReminderOr.." "..(opened and "(" or "")..(trigger.invert and "!" or "")..i..triggersStr
					opened = false
				elseif trigger.andor == 3 then
					triggersStr = " "..L.ReminderOr.." "..(trigger.invert and "!" or "")..i..(not opened and ")" or "").. triggersStr
					opened = true
				end
			end
			triggersStr = (opened and "(" or "")..(module.options.setupFrame.data.triggers[1].invert and "!" or "").."1"..triggersStr

			if module.options.setupFrame.data.triggers[button.num].andor == 4 then
				triggersStr = L.ReminderTriggerTipIgnored:format(tostring(button.num)).."\n" .. triggersStr
			end

			ELib.Tooltip.Show(self,nil,triggersStr)
		end):OnLeave(function()
			GameTooltip_Hide()
		end)
		button.andor.state = 1
		button.andor.Update = function(self)
			if self.state == 1 then
				self:SetText(L.ReminderAnd)
			elseif self.state == 2 then
				self:SetText(L.ReminderOrU)
			elseif self.state == 3 then
				self:SetText(L.ReminderOrU.."+")
			elseif self.state == 4 then
				self:SetText(" ")
			end
		end

		button.remove = Button_Create(button):Point("RIGHT",button,"RIGHT",-30,0)
		button.remove:SetScript("OnClick",function()
			tremove(self.setupFrame.data.triggers,button.num)
			self.setupFrame:Update(self.setupFrame.data)
			button:Update()
		end)
		button.remove.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
		button.remove.tooltip1 = DELETE

		button.tobottom = Button_Create(button):Point("RIGHT",button.remove,"LEFT",-2,0)
		button.tobottom:SetScript("OnClick",function()
			local triggers = self.setupFrame.data.triggers
			if button.num < #triggers then
				triggers[button.num], triggers[button.num+1] = triggers[button.num+1], triggers[button.num]
				self.setupFrame:Update(self.setupFrame.data)
			end
		end)
		button.tobottom.texture:SetTexture("Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128")
		button.tobottom.texture:SetTexCoord(0.25,0.3125,0.5,0.625)
		button.tobottom.texture:SetSize(24,24)

		button.totop = Button_Create(button):Point("RIGHT",button.tobottom,"LEFT",-2,0)
		button.totop:SetScript("OnClick",function()
			local triggers = self.setupFrame.data.triggers
			if button.num > 1 then
				triggers[button.num], triggers[button.num-1] = triggers[button.num-1], triggers[button.num]
				self.setupFrame:Update(self.setupFrame.data)
			end
		end)
		button.totop.texture:SetTexture("Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128")
		button.totop.texture:SetTexCoord(0.25,0.3125,0.625,0.5)
		button.totop.texture:SetSize(24,24)

		button.copy = Button_Create(button):Point("RIGHT",button.totop,"LEFT",-2,0)
		button.copy:SetScript("OnClick",function()
			local triggers = self.setupFrame.data.triggers
			local copy = ExRT.F.table_copy2(triggers[button.num])
			tinsert(triggers, button.num, copy)
			self.setupFrame:Update(self.setupFrame.data)
		end)
		button.copy.texture:SetTexture("Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128")
		button.copy.texture:SetTexCoord(0.125,0.1875,0.875,1)
		button.copy.texture:SetSize(24,24)
		button.copy.tooltip1 = L.ReminderCopy


		button.eventDropDown = ELib:DropDown(button.sub,220,#module.datas.events):AddText("|cffffd100"..L.ReminderCond..":"):Size(270):Point("TOPLEFT",180,-5)
		do
			local function events_SetValue(_,arg1)
				module.options.setupFrame.data.triggers[button.num].event = arg1

				if arg1 == 1 then
					if not module.options.setupFrame.data.triggers[button.num].eventCLEU then
						module.options.setupFrame.data.triggers[button.num].eventCLEU = "SPELL_CAST_SUCCESS"
					end
					module.options.setupFrame:UpdateTriggerFieldsForEvent(button,module.options.setupFrame.data.triggers[button.num].eventCLEU or "SPELL_CAST_SUCCESS")
				else
					module.options.setupFrame:UpdateTriggerFieldsForEvent(button,arg1)
				end
				ELib:DropDownClose()
			end

			local function events_Tooltip(self,arg1)
				GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
				GameTooltip:SetText(arg1,nil,nil,nil,nil,true)
				GameTooltip:Show()
			end
			local function events_Tooltip_Hide()
				GameTooltip_Hide()
			end

			local List = button.eventDropDown.List
			for i=1,#module.datas.events do
				local eventDB = module.C[ module.datas.events[i] ]
				local l = {
					text = eventDB.lname,
					arg1 = eventDB.id,
					func = events_SetValue,
				}
				if eventDB.tooltip then
					l.hoverFunc = events_Tooltip
					l.leaveFunc = events_Tooltip_Hide
					l.hoverArg = eventDB.tooltip
				end
				List[#List+1] = l
			end
		end
		button.eventDropDown.Background:SetColorTexture(1,1,1,1)
		button.eventDropDown.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))


		button.eventCLEU = ELib:DropDown(button.sub,220,#module.C[1].subEvents):AddText("|cffffd100"..L.ReminderCombatLog..":"):Size(270):Point("TOPLEFT",button.eventDropDown,"BOTTOMLEFT",0,-5)
		do
			local function events_CLEU_SetValue(_,arg1)
				module.options.setupFrame.data.triggers[button.num].eventCLEU = arg1
				module.options.setupFrame:UpdateTriggerFieldsForEvent(button,arg1)
				ELib:DropDownClose()
			end

			local List = button.eventCLEU.List
			for i=1,#module.C[1].subEvents do
				local event = module.C[1].subEvents[i]
				List[#List+1] = {
					text = module.C[event] and module.C[event].lname or event,
					arg1 = event,
					func = events_CLEU_SetValue,
				}
			end
		end
		button.eventCLEU.Background:SetColorTexture(1,1,1,1)
		button.eventCLEU.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))

		button.sourceName = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.eventCLEU,"BOTTOMLEFT",0,-5):LeftText(L.ReminderSourceName..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText():trim()
				if text == "" then text = nil end
				module.options.setupFrame.data.triggers[button.num].sourceName = text
			end
			if module.options.setupFrame.data.triggers[button.num].sourceName then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(L.ReminderMultiplyTip)
		button.sourceName.Background:SetColorTexture(1,1,1,1)

		button.sourceID = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.sourceName,"BOTTOMLEFT",0,-5):LeftText(L.ReminderSourceID..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText():trim()
				if text == "" then text = nil end
				module.options.setupFrame.data.triggers[button.num].sourceID = text
			end
			if module.options.setupFrame.data.triggers[button.num].sourceID then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(L.ReminderSourceIDTip)
		button.sourceID.Background:SetColorTexture(1,1,1,1)

		button.sourceUnit = ELib:DropDown(button.sub,220,-1):AddText("|cffffd100"..L.ReminderSourceUnit..":"):Size(270):Point("TOPLEFT",button.sourceID,"BOTTOMLEFT",0,-5)
		button.sourceUnit.Background:SetColorTexture(1,1,1,1)
		do
			local function unit_SetValue(_,arg1)
				ELib:DropDownClose()
				module.options.setupFrame.data.triggers[button.num].sourceUnit = arg1
				local val = ExRT.F.table_find3(module.datas.units,arg1,1)
				if type(arg1) == "number" and arg1 < 0 then
					button.sourceUnit:SetText(L.ReminderSourceUnit1.." "..(-arg1))
				elseif val then
					button.sourceUnit:SetText(val[2] or val[1])
				else
					button.sourceUnit:SetText(arg1)
				end
				button:UpdateTriggerAlerts()

				if module.options.setupFrame.data.triggers[button.num].sourceUnit then
					button.sourceUnit.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
				else
					button.sourceUnit.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
				end
			end
			button.sourceUnit.SetValue = unit_SetValue

			local List = button.sourceUnit.List
			for i=1,#module.datas.units do
				List[#List+1] = {
					text = module.datas.units[i][2] or module.datas.units[i][1],
					arg1 = module.datas.units[i][1],
					func = unit_SetValue,
				}
			end

			local ListMaxDef = #List
			function button.sourceUnit:PreUpdate()
				for i=ListMaxDef+1,#List do
					List[i] = nil
				end
				local triggers = module.options.setupFrame.data.triggers
				for i=1,#triggers do
					if i ~= triggerNum then
						List[#List+1] = {
							text = L.ReminderSourceUnit1.." "..i,
							arg1 = -i,
							func = unit_SetValue,
						}
					end
				end
			end
		end

		button.sourceMark = ELib:DropDown(button.sub,220,#module.datas.marks):AddText("|cffffd100"..L.ReminderSourceMark..":"):Size(270):Point("TOPLEFT",button.sourceUnit,"BOTTOMLEFT",0,-5)
		button.sourceMark.Background:SetColorTexture(1,1,1,1)
		do
			local function mark_SetValue(_,arg1)
				ELib:DropDownClose()
				module.options.setupFrame.data.triggers[button.num].sourceMark = arg1
				local val = ExRT.F.table_find3(module.datas.marks,arg1,1)
				if val then
					button.sourceMark:SetText(val[2])
				else
					button.sourceMark:SetText(arg1)
				end

				if module.options.setupFrame.data.triggers[button.num].sourceMark then
					button.sourceMark.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
				else
					button.sourceMark.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
				end
			end
			button.sourceMark.SetValue = mark_SetValue

			local List = button.sourceMark.List
			for i=1,#module.datas.marks do
				List[#List+1] = {
					text = module.datas.marks[i][2],
					arg1 = module.datas.marks[i][1],
					func = mark_SetValue,
				}
			end
		end

		button.targetName = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.sourceMark,"BOTTOMLEFT",0,-5):LeftText(L.ReminderTargetName..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText():trim()
				if text == "" then text = nil end
				module.options.setupFrame.data.triggers[button.num].targetName = text
			end
			if module.options.setupFrame.data.triggers[button.num].targetName then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(L.ReminderMultiplyTip)
		button.targetName.Background:SetColorTexture(1,1,1,1)

		button.targetID = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.targetName,"BOTTOMLEFT",0,-5):LeftText(L.ReminderTargetID..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText():trim()
				if text == "" then text = nil end
				module.options.setupFrame.data.triggers[button.num].targetID = text
			end
			if module.options.setupFrame.data.triggers[button.num].targetID then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(L.ReminderSourceIDTip)
		button.targetID.Background:SetColorTexture(1,1,1,1)

		button.targetUnit = ELib:DropDown(button.sub,220,-1):AddText("|cffffd100"..L.ReminderTargetUnit..":"):Size(270):Point("TOPLEFT",button.targetID,"BOTTOMLEFT",0,-5)
		button.targetUnit.Background:SetColorTexture(1,1,1,1)
		do
			local function unit_SetValue(_,arg1)
				ELib:DropDownClose()
				module.options.setupFrame.data.triggers[button.num].targetUnit = arg1
				local val = ExRT.F.table_find3(module.datas.units,arg1,1)
				if type(arg1) == "number" and arg1 < 0 then
					button.targetUnit:SetText(L.ReminderSourceUnit1.." "..(-arg1))
				elseif val then
					button.targetUnit:SetText(val[2] or val[1])
				else
					button.targetUnit:SetText(arg1)
				end
				button:UpdateTriggerAlerts()

				if module.options.setupFrame.data.triggers[button.num].targetUnit then
					button.targetUnit.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
				else
					button.targetUnit.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
				end
			end
			button.targetUnit.SetValue = unit_SetValue

			local List = button.targetUnit.List
			for i=1,#module.datas.units do
				List[#List+1] = {
					text = module.datas.units[i][2] or module.datas.units[i][1],
					arg1 = module.datas.units[i][1],
					func = unit_SetValue,
				}
			end

			local ListMaxDef = #List
			function button.targetUnit:PreUpdate()
				for i=ListMaxDef+1,#List do
					List[i] = nil
				end
				local triggers = module.options.setupFrame.data.triggers
				for i=1,#triggers do
					if i ~= triggerNum then
						List[#List+1] = {
							text = L.ReminderSourceUnit1.." "..i,
							arg1 = -i,
							func = unit_SetValue,
						}
					end
				end
			end
		end

		button.targetMark = ELib:DropDown(button.sub,220,#module.datas.marks):AddText("|cffffd100"..L.ReminderTargetMark..":"):Size(270):Point("TOPLEFT",button.targetUnit,"BOTTOMLEFT",0,-5)
		button.targetMark.Background:SetColorTexture(1,1,1,1)
		do
			local function mark_SetValue(_,arg1)
				ELib:DropDownClose()
				module.options.setupFrame.data.triggers[button.num].targetMark = arg1
				local val = ExRT.F.table_find3(module.datas.marks,arg1,1)
				if val then
					button.targetMark:SetText(val[2])
				else
					button.targetMark:SetText(arg1)
				end

				if module.options.setupFrame.data.triggers[button.num].targetMark then
					button.targetUnit.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
				else
					button.targetMark.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
				end
			end
			button.targetMark.SetValue = mark_SetValue

			local List = button.targetMark.List
			for i=1,#module.datas.marks do
				List[#List+1] = {
					text = module.datas.marks[i][2],
					arg1 = module.datas.marks[i][1],
					func = mark_SetValue,
				}
			end
		end

		button.targetRole = ELib:DropDown(button.sub,220,-1):AddText("|cffffd100"..L.ReminderTargetRole..":"):Size(270):Point("TOPLEFT",button.targetMark,"BOTTOMLEFT",0,-5)
		button.targetRole.Background:SetColorTexture(1,1,1,1)
		do
			local function role_SetValue(_,arg1)
				ELib:DropDownClose()
				module.options.setupFrame.data.triggers[button.num].targetRole = arg1
				local val = ExRT.F.table_find3(module.datas.rolesList,arg1,1)
				if type(arg1) == "number" and arg1 > 100 then
					local text = ""
					for i=1,#module.datas.rolesList do
						if bit.band(arg1-100,module.datas.rolesList[i][4]) > 0 then
							text = text..(text ~= "" and "," or "")..module.datas.rolesList[i][2]
						end
					end
					button.targetRole:SetText(text)
				elseif val then
					button.targetRole:SetText(val[2])
				elseif not arg1 then
					button.targetRole:SetText("")
				else
					if arg1 == 6 then arg1 = L.ReminderNotTank end
					button.targetRole:SetText(arg1)
				end

				for i=1,#module.datas.rolesList do
					if (type(arg1) == "number" and arg1 >= 100 and bit.band(arg1-100,module.datas.rolesList[i][4]) > 0) or (type(arg1) == "number" and arg1 < 100 and arg1 == module.datas.rolesList[i][1]) then
						button.targetRole.List[i+1].checkState = true
					else
						button.targetRole.List[i+1].checkState = false
					end
				end

				if module.options.setupFrame.data.triggers[button.num].targetRole then
					button.targetRole.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
				else
					button.targetRole.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
				end
			end
			button.targetRole.SetValue = role_SetValue

			local function role_SetCheck(self,checkState)
				local val = module.options.setupFrame.data.triggers[button.num].targetRole or 0
				if val < 100 then
					local t = ExRT.F.table_find3(module.datas.rolesList,val,1)
					val = 100 + (t and t[4] or 0)
				end
				if val >= 100 then
					val = val - 100
				end
				if checkState then
					val = bit.bor(val,self.arg2)
				else
					val = bit.bxor(val,self.arg2)
				end
				val = val + 100
				if val == 100 then val = nil end
				role_SetValue(nil,val)
			end

			local List = button.targetRole.List
			List[#List+1] = {
				text = "-",
				arg1 = nil,
				func = role_SetValue,
			}
			for i=1,#module.datas.rolesList do
				List[#List+1] = {
					text = module.datas.rolesList[i][2],
					arg1 = module.datas.rolesList[i][1],
					arg2 = module.datas.rolesList[i][4],
					func = role_SetValue,
					checkable = true,
					checkFunc = role_SetCheck,
				}
			end
			List[#List+1] = {
				text = L.ReminderNotTank,
				arg1 = 6,
				func = role_SetValue,
			}
		end

		button.spellID = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.targetRole,"BOTTOMLEFT",0,-5):LeftText(L.ReminderSpellID..":"):OnChange(function(self,isUser)
			local spellID = tonumber(self:GetText())
			if not spellID then
				self.SIDtext:SetText("")
			else
				local t = module.options.setupFrame.data.triggers[button.num]
				if t.event == 1 and t.eventCLEU == "ENVIRONMENTAL_DAMAGE" then
					if spellID == 1 then spellID = 110122
					elseif spellID == 2 then spellID = 68730
					elseif spellID == 3 then spellID = 125024
					elseif spellID == 4 then spellID = 103795
 					elseif spellID == 5 then spellID = 119741
 					elseif spellID == 6 then spellID = 16456 end
				end
				local spellName,_,spellTexture = GetSpellInfo(spellID)
				self.SIDtext:SetText((spellTexture and "|T"..spellTexture..":16|t " or "")..(spellName or ""))
			end
			if isUser then
				module.options.setupFrame.data.triggers[button.num].spellID = tonumber(self:GetText())
				button:UpdateTriggerAlerts()
			end
			if module.options.setupFrame.data.triggers[button.num].spellID then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(function(self)
			local t = module.options.setupFrame.data.triggers[button.num]
 			if t.event == 1 and t.eventCLEU == "ENVIRONMENTAL_DAMAGE" then
				self.lockTooltipText = false
				return "1 - "..STRING_ENVIRONMENTAL_DAMAGE_FALLING.."\n2 - "..STRING_ENVIRONMENTAL_DAMAGE_DROWNING.."\n3 - "..STRING_ENVIRONMENTAL_DAMAGE_FATIGUE.."\n4 - "..STRING_ENVIRONMENTAL_DAMAGE_FIRE.."\n5 - "..STRING_ENVIRONMENTAL_DAMAGE_LAVA.."\n6 - "..STRING_ENVIRONMENTAL_DAMAGE_SLIME
			elseif t.event == 6 or t.event == 7 then
				self.lockTooltipText = false
				return L.ReminderSpellIDBWTip
			else
				self.lockTooltipText = true
			end
 		end)
		button.spellID.Background:SetColorTexture(1,1,1,1)

		button.spellID.SIDtext = ELib:Text(button.spellID,"",14):Point("TOPLEFT",button.spellID,"BOTTOMLEFT",2,-3):Size(270-4,20):Left():Middle():Color()

		button.spellName = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.spellID,"BOTTOMLEFT",0,-5):LeftText(L.ReminderSpellName..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText():trim()
				if text == "" then text = nil end
				module.options.setupFrame.data.triggers[button.num].spellName = text
				button:UpdateTriggerAlerts()
			end
			if module.options.setupFrame.data.triggers[button.num].spellName then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end)
		button.spellName.Background:SetColorTexture(1,1,1,1)

		button.extraSpellID = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.spellName,"BOTTOMLEFT",0,-5):LeftText(L.ReminderSpellIDExtra..":"):OnChange(function(self,isUser)
			if isUser then
				module.options.setupFrame.data.triggers[button.num].extraSpellID = tonumber(self:GetText())
			end
			if module.options.setupFrame.data.triggers[button.num].extraSpellID then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(L.ReminderSpellIDExtraTip)
		button.extraSpellID.Background:SetColorTexture(1,1,1,1)

		button.stacks = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.extraSpellID,"BOTTOMLEFT",0,-5):LeftText(L.ReminderStacksCount..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText():trim()
				if text == "" then text = nil end
				module.options.setupFrame.data.triggers[button.num].stacks = text
				button:UpdateTriggerAlerts()
			end
			if module.options.setupFrame.data.triggers[button.num].stacks then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(function(self)
			self.lockTooltipText = true
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(L.ReminderMultiplyTip2)
			GameTooltip:AddLine(L.ReminderMultiplyTip3)
			GameTooltip:AddLine(L.ReminderMultiplyTip4)
			GameTooltip:AddLine(L.ReminderMultiplyTip5)
			GameTooltip:AddLine(L.ReminderMultiplyTip6)
			GameTooltip:AddLine(L.ReminderMultiplyTip7)
			GameTooltip:Show()
		end)
		button.stacks.Background:SetColorTexture(1,1,1,1)

		button.numberPercent = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.stacks,"BOTTOMLEFT",0,-5):LeftText(L.ReminderPercent..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText():trim()
				if text == "" then text = nil end
				module.options.setupFrame.data.triggers[button.num].numberPercent = text
				button:UpdateTriggerAlerts()
			end
			if module.options.setupFrame.data.triggers[button.num].numberPercent then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(function(self)
			self.lockTooltipText = true
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(L.ReminderMultiplyTip2)
			GameTooltip:AddLine(L.ReminderMultiplyTip3)
			GameTooltip:AddLine(L.ReminderMultiplyTip4b)
			GameTooltip:AddLine(L.ReminderMultiplyTip6)
			GameTooltip:AddLine(L.ReminderMultiplyTip7b)
			GameTooltip:Show()
		end)
		button.numberPercent.Background:SetColorTexture(1,1,1,1)

		button.pattFind = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.numberPercent,"BOTTOMLEFT",0,-5):LeftText(L.ReminderSearchString..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText():trim()
				if text == "" then text = nil end
				module.options.setupFrame.data.triggers[button.num].pattFind = text
				button:UpdateTriggerAlerts()
			end
			if module.options.setupFrame.data.triggers[button.num].pattFind then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(function(self)
			local t = module.options.setupFrame.data.triggers[button.num]
 			if t.event == 1 and t.eventCLEU == "SPELL_MISSED" then
				self.lockTooltipText = false
				return L.ReminderMissTypeLabelTooltip..":\nABSORB, BLOCK, DEFLECT, DODGE, EVADE, IMMUNE, MISS, PARRY, REFLECT, RESIST"
			else
				self.lockTooltipText = true
			end
			if self.tooltipText then
				self.lockTooltipText = false
				return self.tooltipText
			end
		end)
		button.pattFind.Background:SetColorTexture(1,1,1,1)

		button.bwtimeleft = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.pattFind,"BOTTOMLEFT",0,-5):LeftText(L.ReminderTimerLeft..":"):OnChange(function(self,isUser)
			if isUser then
				module.options.setupFrame.data.triggers[button.num].bwtimeleft = tonumber(self:GetText())
				button:UpdateTriggerAlerts()
			end
			if module.options.setupFrame.data.triggers[button.num].bwtimeleft then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip("")
		button.bwtimeleft.Background:SetColorTexture(1,1,1,1)

		button.counter = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.bwtimeleft,"BOTTOMLEFT",0,-5):LeftText(L.ReminderCounter..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText():trim()
				if text == "" then text = nil end
				module.options.setupFrame.data.triggers[button.num].counter = text
			end
			if module.options.setupFrame.data.triggers[button.num].counter then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(function(self)
			self.lockTooltipText = true
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(L.ReminderMultiplyTip2)
			GameTooltip:AddLine(L.ReminderMultiplyTip3)
			GameTooltip:AddLine(L.ReminderMultiplyTip4)
			GameTooltip:AddLine(L.ReminderMultiplyTip5)
			GameTooltip:AddLine(L.ReminderMultiplyTip6)
			GameTooltip:AddLine(L.ReminderMultiplyTip7)
			GameTooltip:Show()
		end)
		button.counter.Background:SetColorTexture(1,1,1,1)

		button.cbehavior = ELib:DropDown(button.sub,220,#module.datas.counterBehavior):AddText("|cffffd100"..L.ReminderCounterBehavior..":"):Size(270):Point("TOPLEFT",button.counter,"BOTTOMLEFT",0,-5)
		button.cbehavior.Background:SetColorTexture(1,1,1,1)
		button.cbehavior.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
		do
			local function counterBehavior_SetValue(_,arg1)
				ELib:DropDownClose()
				module.options.setupFrame.data.triggers[button.num].cbehavior = arg1
				local val = ExRT.F.table_find3(module.datas.counterBehavior,arg1,1)
				if val then
					button.cbehavior:SetText(val[2])
				else
					button.cbehavior:SetText(arg1)
				end
			end
			button.cbehavior.SetValue = counterBehavior_SetValue

			local function counterBehavior_Tooltip(self,arg1)
				GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
				GameTooltip:SetText(arg1,nil,nil,nil,nil,true)
				GameTooltip:Show()
			end
			local function counterBehavior_Tooltip_Hide()
				GameTooltip_Hide()
			end

			local List = button.cbehavior.List
			for i=1,#module.datas.counterBehavior do
				List[#List+1] = {
					text = module.datas.counterBehavior[i][2],
					arg1 = module.datas.counterBehavior[i][1],
					func = counterBehavior_SetValue,
					hoverFunc = counterBehavior_Tooltip,
					leaveFunc = counterBehavior_Tooltip_Hide,
					hoverArg = module.datas.counterBehavior[i][3],
				}
			end
		end

		local function CheckDelayTimeText(text)
			if not text then
				return false
			else
				for c in string_gmatch(text, "[^ ,]+") do
					if not (tonumber(c) or c:find("%d+:%d+%.?%d*") or c:lower()=="note") then
						return false
					end
				end
				return true
			end
		end

		button.delayTime = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.counter,"BOTTOMLEFT",0,-5):LeftText(L.ReminderDelay..":"):OnChange(function(self,isUser)
			if isUser then
				local text = self:GetText()
				if not CheckDelayTimeText(text) then
					text = nil
				end
				module.options.setupFrame.data.triggers[button.num].delayTime = text
			end
			if module.options.setupFrame.data.triggers[button.num].delayTime then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(L.ReminderDelayTooltip)
		button.delayTime.Background:SetColorTexture(1,1,1,1)

		button.activeTime = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.delayTime,"BOTTOMLEFT",0,-5):LeftText(L.ReminderActiveTime..":"):OnChange(function(self,isUser)
			if isUser then
				module.options.setupFrame.data.triggers[button.num].activeTime = tonumber(self:GetText())
			end
			if module.options.setupFrame.data.triggers[button.num].activeTime then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(L.ReminderActiveTimeTooltip)
		button.activeTime.Background:SetColorTexture(1,1,1,1)

		button.invert = ELib:Check(button.sub,L.ReminderInvert..":"):Point("TOPLEFT",button.activeTime,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
			if self:GetChecked() then
				module.options.setupFrame.data.triggers[button.num].invert = true
			else
				module.options.setupFrame.data.triggers[button.num].invert = nil
			end
		end):Tooltip(L.ReminderInvertTooltip)

		button.guidunit = ELib:DropDown(button.sub,220,2):AddText("|cffffd100"..L.ReminderTriggerUnit..":"):Size(270):Point("TOPLEFT",button.invert,"BOTTOMLEFT",0,-5):Tooltip(L.ReminderTriggerUnitTooltip)
		button.guidunit.Background:SetColorTexture(1,1,1,1)
		button.guidunit.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
		do
			local function guidunit_SetValue(_,arg1)
				ELib:DropDownClose()
				module.options.setupFrame.data.triggers[button.num].guidunit = arg1
				button.guidunit:SetText(arg1 == 1 and L.ReminderSource or L.ReminderDest)
			end
			button.guidunit.SetValue = guidunit_SetValue

			local List = button.guidunit.List
			List[#List+1] = {
				text = L.ReminderSource,
				arg1 = 1,
				func = guidunit_SetValue,
			}
			List[#List+1] = {
				text = L.ReminderDest,
				arg1 = nil,
				func = guidunit_SetValue,
			}
		end

		button.onlyPlayer = ELib:Check(button.sub,L.ReminderTargetIsPlayer..":"):Point("TOPLEFT",button.activeTime,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
			if self:GetChecked() then
				module.options.setupFrame.data.triggers[button.num].onlyPlayer = true
			else
				module.options.setupFrame.data.triggers[button.num].onlyPlayer = nil
			end
		end):Tooltip(L.ReminderTargetIsPlayerTip)

		button.HEIGHT = 10

		return button
	end

	self.setupFrame.triggersScrollFrame.addTrigger = ELib:Button(self.setupFrame.triggersScrollFrame.C,L.ReminderAddTrigger):Size(480,20):Point("BOTTOM",0,5):OnClick(function(self)
		module.options.setupFrame.data.triggers[#module.options.setupFrame.data.triggers+1] = {
			event = 1,
			eventCLEU = "SPELL_CAST_SUCCESS",
		}
		module.options.setupFrame:Update(module.options.setupFrame.data)
	end)

	function self.setupFrame:Update(data)
		self.data = data

		self.setup = true

		self.nameEdit:SetText(data.name or "")
		self.msgEdit:SetText(data.msg or "")
		self.msgSize:SetValue(data.msgSize)
		self.durEdit:SetText(data.dur or "")
		self.countdownCheck:SetChecked(data.countdown)
		self.countdownCheck:GetScript("OnClick")(self.countdownCheck)
		self.countdownType:SetValue(data.countdownType)
		self.copyCheck:SetChecked(data.copy)
		self.sametargetsCheck:SetChecked(data.sametargets)
		self.extraCheck:SetText(data.extraCheck or "")
		self.specialTarget:SetText(data.specialTarget or "")
		self.delayedActivation:SetText(data.delayedActivation or "")
		self.debugCheck:SetChecked(data.debug)
		self.glowTypeEdit:SetValue(data.glowType)
		self.glowThickEdit:SetText(data.glowThick or "")
		self.glowScaleEdit:SetText(data.glowScale or "")
		self.glowNEdit:SetText(data.glowN or "")
		self.glowColorEdit:SetText(data.glowColor or "")
		self.glowColorEdit.preview:Update()
		self.customOpt1:SetText(data.customOpt1 or "")
		self.disableDynamicUpdates:SetChecked(data.dynamicdisable)
		self.disableRewrite:SetChecked(data.norewrite)
		self.countdownVoice:SetValue(data.countdownVoice)
		
		if data.sound then
			self.soundList:PreUpdate()
			local val = ExRT.F.table_find3(self.soundList.List,data.sound,"arg1")
			if val then
				self.soundList:func_SetValue(data.sound)
			else
				self.soundList:func_SetValue(0)
				self.soundCustom:SetText(data.sound or "")
			end
		else
			self.soundList:func_SetValue(data.sound)
		end

		if data.bossID then
			self.bossList:SetValue(data.bossID)
		else
			self.bossList:SetValue()
		end
		self.bossCustom:SetText(data.bossID or "")
		self.bossDiff:SetValue(data.diffID)
		self.zoneID:SetText(data.zoneID or "")

		self.allPlayersCheck:SetChecked(data.allPlayers)
		self:UpdatePlayersChecks()
		local playersStr = ""
		for k in pairs(data.players) do
			local chk = self.playersChecksList[k]
			if chk then
				chk:SetChecked(true)
			else
				playersStr = playersStr ..(playersStr ~= "" and " " or "")..k
			end
		end
		self.customPlayerList:SetText(playersStr)
		self.notePatternEdit:SetText(data.notePattern or "")
		for i=1,5 do
			self.rolesChecks[i]:SetChecked(data["role"..self.rolesChecks[i].token])
		end
		for i=1,#ExRT.GDB.ClassList do
			self.classChecks[i]:SetChecked(data["class"..self.classChecks[i].token])
		end
		self.neverCheck:SetChecked(data.disabled)

		for i=#data.triggers+1,#self.triggersScrollFrame.triggers do
			self.triggersScrollFrame.triggers[i]:Hide()
		end
		for i=1,#data.triggers do
			local button = GetTriggerButton(i)
			button:Show()

			local trigger = data.triggers[i]
			button.data = trigger

			button.andor.state = trigger.andor or 1
			button.andor:Update()

			if trigger.event == 1 then
				self:UpdateTriggerFieldsForEvent(button,trigger.eventCLEU)
			else
				self:UpdateTriggerFieldsForEvent(button,trigger.event)
			end

			button.sourceName:SetText(trigger.sourceName or "")
			button.sourceID:SetText(trigger.sourceID or "")
			button.sourceUnit:SetValue(trigger.sourceUnit)
			button.sourceMark:SetValue(trigger.sourceMark)
			button.targetName:SetText(trigger.targetName or "")
			button.targetID:SetText(trigger.targetID or "")
			button.targetUnit:SetValue(trigger.targetUnit)
			button.targetMark:SetValue(trigger.targetMark)
			button.targetRole:SetValue(trigger.targetRole)			
			button.spellID:SetText(trigger.spellID or "")
			button.spellName:SetText(trigger.spellName or "")
			button.extraSpellID:SetText(trigger.extraSpellID or "")
			button.stacks:SetText(trigger.stacks or "")
			button.numberPercent:SetText(trigger.numberPercent or "")
			button.pattFind:SetText(trigger.pattFind or "")
			button.bwtimeleft:SetText(trigger.bwtimeleft or "")
			button.counter:SetText(trigger.counter or "")
			button.cbehavior:SetValue(trigger.cbehavior)
			button.delayTime:SetText(trigger.delayTime or "")
			button.activeTime:SetText(trigger.activeTime or "")
			button.invert:SetChecked(trigger.invert)
			button.guidunit:SetValue(trigger.guidunit)
			button.onlyPlayer:SetChecked(trigger.onlyPlayer)

			button:UpdateTriggerAlerts()
		end

		local options = VMRT.Reminder2.options[data.uid or 0] or 0
		self.disableCheck:SetChecked(bit.band(options,bit.lshift(1,0)) > 0)
		self.disableSound:SetChecked(bit.band(options,bit.lshift(1,1)) > 0)
		self.disableUpdates:SetChecked(bit.band(options,bit.lshift(1,2)) > 0)
		self.disableUpdatesSound:SetChecked(bit.band(options,bit.lshift(1,4)) > 0)
		self.disableSynq:SetChecked(bit.band(options,bit.lshift(1,3)) > 0)

		if not data.uid then
			self.copyButton:Disable()
			self.sendOneButton:Disable()
			self.removeButton:Disable()
			self.exportOneButton:Disable()
		else
			self.copyButton:Enable()
			self.sendOneButton:Enable()
			self.removeButton:Enable()
			self.exportOneButton:Enable()
		end

		self.setup = false
	end


	self.setupFrame.historyShowButton = ELib:Button(self.setupFrame.tab.tabs[2],L.ReminderFastSetup):Size(18,495+2):Point("TOPLEFT",self.setupFrame,"TOPRIGHT",1,-15):SetVertical():OnClick(function()
		if self.setupFrame.historyFrame:IsShown() then
			self.setupFrame.historyFrame:Hide()
			VMRT.Reminder2.HistoryFrameShown = nil
		else
			self.setupFrame.historyFrame:Show()
			VMRT.Reminder2.HistoryFrameShown = true
		end
	end)

	self.setupFrame.historyFrame = CreateFrame("Frame",nil,self.setupFrame.tab.tabs[2])
	--self.setupFrame.historyFrame:SetPoint("TOPLEFT",self.setupFrame,"TOPRIGHT",1,-15)
	self.setupFrame.historyFrame:SetPoint("TOPLEFT",self.setupFrame.historyShowButton,"TOPRIGHT",1,-1)
	self.setupFrame.historyFrame:SetSize(450,495)
	ELib:Border(self.setupFrame.historyFrame,1,.4,.4,.4,.9)
	self.setupFrame.historyFrame.TRIGGER = 1
	self.setupFrame.historyFrame:EnableMouse(true)

	self.setupFrame.historyFrame:SetShown(VMRT.Reminder2.HistoryFrameShown)

	self.setupFrame.historyFrame.back = self.setupFrame.historyFrame:CreateTexture(nil, "BACKGROUND")
	self.setupFrame.historyFrame.back:SetAllPoints()
	self.setupFrame.historyFrame.back:SetColorTexture(0.05,0.05,0.07,0.98)

	self.setupFrame.historyFrame.importWindow, self.setupFrame.historyFrame.exportWindow = ExRT.F.CreateImportExportWindows()
	self.setupFrame.historyFrame.importWindow:SetFrameStrata("FULLSCREEN")
	self.setupFrame.historyFrame.exportWindow:SetFrameStrata("FULLSCREEN")

	function self.setupFrame.historyFrame.importWindow:ImportFunc(str)
		local header = str:sub(1,9)
		if header:sub(1,8) ~= "EXRTREMH" or (header:sub(9,9) ~= "0" and header:sub(9,9) ~= "1") then
			print("Import: wrong format")
			return
		end

		module.options.setupFrame.historyFrame:TextToHistory(str:sub(10),header:sub(9,9)=="0")
	end

	function self.setupFrame.historyFrame:TextToHistory(str,uncompressed)
		local decoded = LibDeflate:DecodeForPrint(str)
		local decompressed
		if uncompressed then
			decompressed = decoded
		else
			decompressed = LibDeflate:DecompressDeflate(decoded)
		end
		decoded = nil

		local successful, res = pcall(ExRT.F.TextToTable,decompressed)
		decompressed = nil
		if successful and res then
			module.db.history = res
			if VMRT.Reminder2.HistorySession then
				VMRT.Reminder2.history = module.db.history
			end
		else
			print("Import error")
		end
	end

	self.setupFrame.historyFrame.trigger = ELib:DropDown(self.setupFrame.historyFrame,100,5):AddText("|cffffd100"..L.ReminderFastSetupForTrigger..":"):Size(100):Point("TOPLEFT",250,-5):SetText("1")
	function self.setupFrame.historyFrame.trigger:PreUpdate()
		local List = self.List
		wipe(List)
		for i=1,#module.options.setupFrame.data.triggers do
			List[#List+1] = {
				text = L.ReminderTrigger.." "..i,
				arg1 = i,
				func = function(_,arg1)
					ELib:DropDownClose()
					module.options.setupFrame.historyFrame.trigger:SetText(arg1)
					module.options.setupFrame.historyFrame.TRIGGER = i

					module.options.setupFrame.historyFrame.tab.tabs[1].timelineScrollFrame:ResetActiveNavigation()
				end,
			}
		end
	end

	ELib:DecorationLine(self.setupFrame.historyFrame,true,"BACKGROUND",1):Point("TOPLEFT",self.setupFrame.historyFrame,0,-30):Point("BOTTOMRIGHT",self.setupFrame.historyFrame,"TOPRIGHT",0,-50)

	self.setupFrame.historyFrame.tab = ELib:Tabs(self.setupFrame.historyFrame,0,L.ReminderFastTabTimeline,L.ReminderFastTabList,L.ReminderFastTabBySpell):Point(0,-50):Size(450,445):SetTo(1)
	self.setupFrame.historyFrame.tab:SetBackdropBorderColor(0,0,0,0)
	self.setupFrame.historyFrame.tab:SetBackdropColor(0,0,0,0)

	function self.setupFrame.historyFrame.tab:buttonAdditionalFunc()
		local tabID = self.selected
		if tabID == 1 then
			module.options.setupFrame.historyFrame:SetWidth(450)
			self.tabs[1].timelineScrollFrame.filterDropDown:SetParent(self.tabs[1])
			self.tabs[1].timelineScrollFrame.filterDropDown:NewPoint("BOTTOMRIGHT",'x',"TOPRIGHT",-20,1)
		elseif tabID == 2 then
			module.options.setupFrame.historyFrame:SetWidth(580)
			self.tabs[1].timelineScrollFrame.filterDropDown:SetParent(self.tabs[2])
			self.tabs[1].timelineScrollFrame.filterDropDown:NewPoint("BOTTOMRIGHT",'x',"TOPRIGHT",-20,1)
		elseif tabID == 3 then
			module.options.setupFrame.historyFrame:SetWidth(450)
			self.tabs[1].timelineScrollFrame.filterDropDown:SetParent(self.tabs[3])
			self.tabs[1].timelineScrollFrame.filterDropDown:NewPoint("BOTTOMRIGHT",'x',"TOPRIGHT",-20,1)
		end
	end

	local TIMELINE_FRAME_WIDTH = 450
	local TIMELINE_FRAME_HEIGHT = 443-18

	local timelineFrame = ELib:ScrollFrame(self.setupFrame.historyFrame.tab.tabs[1]):Point("TOP",0,0):Size(TIMELINE_FRAME_WIDTH,TIMELINE_FRAME_HEIGHT):AddHorizontal(true):Height(500):Width(1000)
	self.setupFrame.historyFrame.tab.tabs[1].timelineScrollFrame = timelineFrame
	ELib:Border(timelineFrame,0)

	timelineFrame.LINE_HEIGHT = 30
	timelineFrame.PIX_PER_SEC = 6
	timelineFrame.SEC_PER_SEG = 10

	timelineFrame.fightLen = 300

	timelineFrame.isAuras = false

	local timelineContent = timelineFrame.C

	timelineFrame.filterDropDown = ELib:DropDown(self.setupFrame.historyFrame.tab.tabs[1],250,9):Point("BOTTOMRIGHT",'x',"TOPRIGHT",-20,1):Size(150):SetText(L.InspectViewerFilter)
	timelineFrame.filterDropDown:_Size(140,18)
	function timelineFrame.filterDropDown:PreUpdate()
		local tabID = module.options.setupFrame.historyFrame.tab.selected
		local List = self.List
		wipe(List)
		local subMenu = {}
		for i=1,#module.db.history do
			local fight = module.db.history[i]
			local fightLen = #fight > 1 and fight[#fight][1] - fight[1][1]
			subMenu[#subMenu+1] = {
				text = (#fight > 0 and fight[1][4] or L.ReminderFight.." "..i)..(fightLen and format(" %d:%02d",fightLen/60,fightLen%60) or ""),
				arg1 = fight,
				func = function(_,arg1)
					ELib:DropDownClose()
					timelineFrame:Update(arg1)
				end,
			}
		end
		subMenu[#subMenu+1] = {
			text = " ",
			isTitle = true,
		}
		subMenu[#subMenu+1] = {
			text = L.ReminderFightExport,
			func = function()
				ELib:DropDownClose()

				local str = module.options:GetHistoryString()

				local compressed
				if #str < 1000000 then
					compressed = LibDeflate:CompressDeflate(str,{level = 5})
				end
				local encoded = "EXRTREMH"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or str)

				module.options.setupFrame.historyFrame.exportWindow.Edit:SetText(encoded)
				module.options.setupFrame.historyFrame.exportWindow:Show()
			end,
		}
		subMenu[#subMenu+1] = {
			text = L.ReminderFightImport,
			func = function()
				ELib:DropDownClose()

				module.options.setupFrame.historyFrame.importWindow:NewPoint("CENTER",UIParent,0,0)
				module.options.setupFrame.historyFrame.importWindow:Show()
			end,
		}
		subMenu[#subMenu+1] = {
			text = " ",
			isTitle = true,
		}
		subMenu[#subMenu+1] = {
			text = L.ReminderFightClear,
			func = function()
				ELib:DropDownClose()

				wipe(module.db.history)
				module.db.history[1] = {}
			end,
		}
		List[#List+1] = {
			text = L.ReminderFightSaved,
			subMenu = subMenu,
		}
		if self.sourceFilter and (tabID == 1 or tabID == 2) then
			local subMenu = {}
			for k,v in pairs(self.sourceFilter) do
				subMenu[#subMenu+1] = {
					text = (v[1] or L.ReminderEnv).." "..format("%d:%02d",v[2]/60,v[2]%60).." |cff888888"..k,
					arg1 = k,
					sort = v[2],
					func = function(_,arg1)
						ELib:DropDownClose()
						if tabID == 1 then
							timelineFrame:Update("prev",arg1)
						elseif tabID == 2 then
							module.options.setupFrame.historyFrame.tab.tabs[2].historyList:Update2("prev",arg1)
						end
					end,
				}
			end
			sort(subMenu,function(a,b) return a.sort < b.sort end)
			List[#List+1] = {
				text = L.ReminderFilterSource,
				subMenu = subMenu,
				Lines = 20,
			}
		end
		if tabID == 1 or tabID == 2 then
			local frame = tabID == 1 and timelineFrame or module.options.setupFrame.historyFrame.tab.tabs[2].historyList
			List[#List+1] = {
				text = L.ReminderFilterEvents..":",
				isTitle = true,
			}
			List[#List+1] = {
				text = L.ReminderFilterCasts,
				checkState = not frame.isAuras,
				radio = true,
				func = function()
					ELib:DropDownClose()
					frame.isAuras = false
					if tabID == 1 then
						frame:Update("prev")
					elseif tabID == 2 then
						frame:Update2("prev")
					end
				end,
			}
			List[#List+1] = {
				text = L.ReminderFilterAuras,
				checkState = frame.isAuras == 1,
				radio = true,
				func = function()
					ELib:DropDownClose()
					frame.isAuras = 1
					if tabID == 1 then
						frame:Update("prev")
					elseif tabID == 2 then
						frame:Update2("prev")
					end
				end,
			}
			List[#List+1] = {
				text = L.ReminderFilterCastsAndAuras,
				checkState = frame.isAuras == 2,
				radio = true,
				func = function()
					ELib:DropDownClose()
					frame.isAuras = 2
					if tabID == 1 then
						frame:Update("prev")
					elseif tabID == 2 then
						frame:Update2("prev")
					end
				end,
			}
			List[#List+1] = {
				text = L.ReminderFilterReset,
				func = function()
					ELib:DropDownClose()
					if tabID == 1 then
						frame:Update("prev")
					elseif tabID == 2 then
						frame:Update2("prev")
					end
				end,
			}
			List[#List+1] = {
				text = L.ReminderFilterSpellsBlacklist,
				func = function()
					ELib:DropDownClose()

					ExRT.F.ShowInput(L.ReminderFilterSpellsBlacklistInput,function(_,text)
						if text:trim() == "" then
							text = nil
						end
						VMRT.Reminder2.HistoryBlacklist = text
						if tabID == 1 then
							frame:Update("prev")
						elseif tabID == 2 then
							frame:Update2("prev")
						end
					end,nil,nil,VMRT.Reminder2.HistoryBlacklist or "")
				end,
			}
		end
		List[#List+1] = {
			text = CLOSE,
			func = function()
				ELib:DropDownClose()
			end,
		}
	end

	for _,key in pairs({"pull","phase"}) do
		timelineContent[key] = timelineContent:CreateTexture()
		timelineContent[key]:SetColorTexture(.24,.25,.30,1)
		timelineContent[key]:SetPoint("TOPLEFT",0,-45)
		timelineContent[key]:SetPoint("BOTTOMRIGHT",timelineContent,"TOPRIGHT",0,-49)

		timelineContent[key].text = timelineContent:CreateFontString(nil,"ARTWORK","GameFontWhite")
		timelineContent[key].text:SetPoint("LEFT",timelineFrame,5,0)
		timelineContent[key].text:SetPoint("BOTTOM",timelineContent[key],"TOP",0,1)

		timelineContent[key].button = CreateFrame("Button",nil,timelineContent)
		timelineContent[key].button:SetPoint("TOPLEFT",timelineContent[key],"TOPLEFT",0,15)
		timelineContent[key].button:SetPoint("RIGHT",timelineContent,0,0)
		timelineContent[key].button:SetHeight(40)
		timelineContent[key].button:RegisterForClicks("RightButtonUp","LeftButtonUp")
		timelineContent[key].button.parent = timelineContent[key]
		--ELib:DebugBack(timelineContent[key].button)

		timelineContent[key].subs = {}
	end

	timelineContent.pull.button:SetScript("OnClick",function(self,button)
		timelineFrame:ResetActiveNavigation()
		if button == "RightButton" then
			return
		end
		local x = ExRT.F.GetCursorPos(self)
		local t = max((x - TIMELINE_FRAME_WIDTH / 2) / timelineFrame.PIX_PER_SEC,0)

		local trigger = module.options.setupFrame.data.triggers[module.options.setupFrame.historyFrame.TRIGGER]
		if trigger then
			trigger.event = 3
			trigger.delayTime = t < 60 and (floor(t * 10)/10) or format("%d:%02d.%d",t/60,t%60,t%1*10)
			module.options.setupFrame:Update(module.options.setupFrame.data)
		end
	end)

	timelineContent.pull.Update = function (self)
		local iMax = ceil(timelineFrame.fightLen / timelineFrame.SEC_PER_SEG) + floor(TIMELINE_FRAME_WIDTH / 2 / (timelineFrame.PIX_PER_SEC*timelineFrame.SEC_PER_SEG))
		for i=0,iMax do
			local t = self.subs[i+1]
			if not t then
				t = timelineContent:CreateTexture()
				self.subs[i+1] = t
				t:SetColorTexture(.24,.25,.30,1)
				t:SetPoint("TOPLEFT",self,"BOTTOMLEFT",TIMELINE_FRAME_WIDTH/2+i*timelineFrame.PIX_PER_SEC*timelineFrame.SEC_PER_SEG,0)
				t:SetSize(4,8)

				t.text = timelineContent:CreateFontString(nil,"ARTWORK","GameFontWhite")
				t.text:SetPoint("TOP",t,"BOTTOM",0,-2)
				t.text:SetFont(t.text:GetFont(),12, "")
			end
			t.text:SetFormattedText("%d:%02d",i*timelineFrame.SEC_PER_SEG/60,(i*timelineFrame.SEC_PER_SEG)%60)
			t:Show()
			t.text:Show()
		end
		for i=iMax+1,#self.subs do
			self.subs[i]:Hide()
			self.subs[i].text:Hide()
		end
	end

	timelineContent.phase.button:SetScript("OnClick",function(self,button)
		timelineFrame:ResetActiveNavigation()
		if button == "RightButton" then
			return
		end
		local x = ExRT.F.GetCursorPos(self)
		local t = max((x - TIMELINE_FRAME_WIDTH / 2) / timelineFrame.PIX_PER_SEC,0)
		local phasePos
		for i=1,#self.parent.phases,3 do
			if self.parent.phases[i+1] > t then
				break
			end
			phasePos = i
		end
		if not phasePos then
			return
		end
		local phaseText = self.parent.phases[phasePos]
		local count = self.parent.phases[phasePos+2]
		t = t - self.parent.phases[phasePos+1]

		local trigger = module.options.setupFrame.data.triggers[module.options.setupFrame.historyFrame.TRIGGER]
		if trigger then
			trigger.event = 2
			trigger.delayTime = t < 60 and (floor(t * 10)/10) or format("%d:%02d.%d",t/60,t%60,t%1*10)
			trigger.pattFind = tostring(phaseText)
			trigger.counter = count and tostring(count) or nil
			trigger.cbehavior = nil
			module.options.setupFrame:Update(module.options.setupFrame.data)
		end
	end)

	timelineContent.phase.subs2 = {}
	timelineContent.phase.phases = {1,0}
	timelineContent.phase.Update = function (self)
		local prevPhaseStart = 0
		local tCount = 0
		local tCountHeader = 0
		for j=1,#self.phases,3 do
			local phaseLen = (self.phases[j+4] or timelineFrame.fightLen) - self.phases[j+1]
			local iMax = ceil(phaseLen / timelineFrame.SEC_PER_SEG) - 1
			for i=0,iMax do
				tCount = tCount + 1
				local t = self.subs[tCount]
				if not t then
					t = timelineContent:CreateTexture()
					self.subs[tCount] = t
					t:SetColorTexture(.24,.25,.30,1)
					t:SetSize(4,8)

					t.text = timelineContent:CreateFontString(nil,"ARTWORK","GameFontWhite")
					t.text:SetPoint("TOP",t,"BOTTOM",0,-2)
					t.text:SetFont(t.text:GetFont(),12, "")
				end
				t:ClearAllPoints()
				t:SetPoint("TOPLEFT",self,"BOTTOMLEFT",TIMELINE_FRAME_WIDTH/2+self.phases[j+1]*timelineFrame.PIX_PER_SEC+i*timelineFrame.PIX_PER_SEC*timelineFrame.SEC_PER_SEG,0)
				t.text:SetFormattedText("%d:%02d",i*timelineFrame.SEC_PER_SEG/60,(i*timelineFrame.SEC_PER_SEG)%60)
				if j > 1 and i == 0 then
					t.text:SetText("")
				end
				t:Show()
				t.text:Show()
				if i == 0 then
					tCountHeader = tCountHeader + 1
					local header = self.subs2[tCountHeader]
					if not header then
						header = timelineContent:CreateTexture()
						self.subs2[tCountHeader] = header
						header:SetColorTexture(.24,.25,.30,1)
						header:SetSize(4,8)

						header.text = timelineContent:CreateFontString(nil,"ARTWORK","GameFontWhite")
						header.text:SetFont(header.text:GetFont(),12, "")
						header.text:SetPoint("BOTTOMLEFT",header,"BOTTOMRIGHT",0,4)
					end
					header:ClearAllPoints()
					header:SetPoint("BOTTOM",t,"TOP",0,4)
					local phaseText = self.phases[j]
					header.text:SetText(tonumber(phaseText) and L.ReminderPhase.." "..phaseText or phaseText)
					header:Show()
					header.text:Show()
				end
			end
		end
		for i=tCount+1,#self.subs do
			self.subs[i]:Hide()
			self.subs[i].text:Hide()
		end
		for i=tCountHeader+1,#self.subs2 do
			self.subs2[i]:Hide()
			self.subs2[i].text:Hide()
		end
	end

	timelineContent.phase:SetPoint("TOPLEFT",0,-105)
	timelineContent.phase:SetPoint("BOTTOMRIGHT",timelineContent,"TOPRIGHT",0,-109)

	timelineContent.pull.text:SetText(L.ReminderFightTime)

	timelineContent.middle = timelineContent:CreateTexture()
	timelineContent.middle:SetColorTexture(.24,.25,.30,1)
	timelineContent.middle:SetPoint("TOP",0,0)
	timelineContent.middle:SetPoint("LEFT",timelineFrame,"CENTER",0,0)
	timelineContent.middle:SetSize(4,24)

	timelineContent.middle2 = timelineContent:CreateTexture()
	timelineContent.middle2:SetColorTexture(.7,.7,.7,.7)
	timelineContent.middle2:SetPoint("TOP",timelineContent.middle,0,0)
	timelineContent.middle2:SetPoint("BOTTOM",timelineContent,0,0)
	timelineContent.middle2:SetWidth(2)
	timelineContent.middle2:Hide()

	timelineContent.middle.text = timelineContent:CreateFontString(nil,"ARTWORK","GameFontWhite")
	timelineContent.middle.text:SetPoint("LEFT",timelineContent.middle,"RIGHT",2,0)
	timelineContent.middle.text:SetFont(timelineContent.middle.text:GetFont(),14, "")
	timelineContent.middle.text:SetText("0:00.000")

	timelineContent.middle.text2 = timelineContent:CreateFontString(nil,"ARTWORK","GameFontWhite")
	timelineContent.middle.text2:SetPoint("LEFT",timelineContent.middle.text,"RIGHT",0,0)
	timelineContent.middle.text2:SetFont(timelineContent.middle.text:GetFont(),14, "")
	timelineContent.middle.text2:SetText("")

	timelineFrame.UpdateTimeText = function(self)
		local t = self:GetHorizontalScroll() / self.PIX_PER_SEC
		self.C.middle.text:SetFormattedText("%d:%02d.%03d",t/60,t%60,(t%1)*1000)
		local t2 = t - (self.C.VERTICAL or t)
		if t2 > 0 then
			self.C.middle.text2:SetFormattedText(" +%d:%02d.%03d",t2/60,t2%60,(t2%1)*1000)
			self.C.middle2:Show()
		else
			self.C.middle.text2:SetText("")
			self.C.middle2:Hide()
		end

		if self.C.VERTICAL then
			local trigger = module.options.setupFrame.data.triggers[module.options.setupFrame.historyFrame.TRIGGER]
			if trigger then
				if t2 < 0 then
					trigger.delayTime = nil
				else
					trigger.delayTime = t2 < 60 and (floor(t2 * 10)/10) or format("%d:%02d.%d",t2/60,t2%60,t2%1*10)
				end
				module.options.setupFrame:Update(module.options.setupFrame.data)
			end
		end
	end

	timelineFrame:SetScript("OnHorizontalScroll",function (self, offset)
		self:UpdateTimeText()

		self.C.filterEdit:Point(offset+10,-142)
	end)

	timelineContent.vertical = timelineContent:CreateTexture()
	timelineContent.vertical:SetColorTexture(.24,.85,.30,.4)
	timelineContent.vertical:SetPoint("TOP",0,0)
	timelineContent.vertical:SetPoint("BOTTOM",0,0)
	timelineContent.vertical:SetWidth(2)
	timelineContent.vertical:Hide()

	timelineContent.stopVertical = ELib:Button(timelineContent,"X"):Point("TOPRIGHT",timelineContent.middle,"TOPLEFT",-3,-3):Size(18,18):OnClick(function()
		timelineContent:SetVertical()
	end):OnEnter(function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine(L.ReminderCancelAutonavigation)
		GameTooltip:Show()
	end):OnLeave(function() GameTooltip_Hide() end)

	function timelineContent:SetVertical(t)
		if not t then
			self.VERTICAL = nil
			self.vertical:Hide()
			timelineFrame:UpdateTimeText()
			self.stopVertical:Hide()
			return
		end
		self.VERTICAL = t
		local x = TIMELINE_FRAME_WIDTH / 2 + t * timelineFrame.PIX_PER_SEC
		self.vertical:SetPoint("LEFT",x,0)
		self.vertical:Show()
		timelineFrame:UpdateTimeText()
		self.stopVertical:Show()
	end

	timelineContent.spells = {}
	timelineContent.emotes = {}

	local function SpellIconButton_OnEnter(self)
		self.linetoline:SetColorTexture(.8,1,.8,1)
		self.linetoline:SetDrawLayer("BACKGROUND", 2)
		GameTooltip:SetOwner(self,"ANCHOR_BOTTOMRIGHT")
		local spellName,_,spellTexture = GetSpellInfo(self.data[12])
		GameTooltip:AddLine(spellName or "Spell "..self.data[12])
		GameTooltip:AddTexture(spellTexture or 134400)
		GameTooltip:AddLine(L.ReminderEvent..": "..(module.C[ self.data[3] ] and module.C[ self.data[3] ].lname or self.data[3]))
		GameTooltip:AddLine(L.ReminderPullTime..": "..format("%d:%02d.%03d",self.data_time/60,self.data_time%60,(self.data_time%1)*1000))
		GameTooltip:AddLine(L.ReminderPhaseTime..": "..format("%d:%02d.%03d",self.data2.timePhase/60,self.data2.timePhase%60,(self.data2.timePhase%1)*1000))
		if self.data2.timePrev then GameTooltip:AddLine(L.ReminderFromPrevEvent..": "..format("%d:%02d.%03d",self.data2.timePrev/60,self.data2.timePrev%60,(self.data2.timePrev%1)*1000)) end
		if self.data[5] and self.data[5] ~= "" then GameTooltip:AddLine(L.ReminderSource..": "..self.data[5].." |cff888888"..self.data[4].."|r") end
		if self.data[9] and self.data[9] ~= "" then GameTooltip:AddLine(L.ReminderDest..": "..self.data[9].." |cff888888"..self.data[8].."|r") end
		GameTooltip:AddLine(L.ReminderGlobalCounter..": "..self.data2.count)
		GameTooltip:AddLine(L.ReminderCounterSource..": "..self.data2.count1)
		GameTooltip:AddLine(L.ReminderCounterDest..": "..self.data2.count2)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Spell ID: "..self.data[12])
		--GameTooltip:AddSpellByID(self.data[12])
		GameTooltip:Show()
	end
	local function SpellIconButton_OnLeave(self)
		self.linetoline:SetColorTexture(.24,.25,.30,1)
		self.linetoline:SetDrawLayer("BACKGROUND", 1)
		GameTooltip_Hide()
	end
	local function SpellIconButton_OnClick(self,button)
		timelineFrame:ResetActiveNavigation()
		if button == "RightButton" then
			return
		end
		timelineFrame.ScrollBarHorizontal:SetValue(self.data_time * timelineFrame.PIX_PER_SEC)
		timelineContent:SetVertical(self.data_time)

		local LCG = LibStub("LibCustomGlow-1.0",true)
		if LCG then
			timelineFrame.highlightsNow = timelineFrame.highlightsList[self]
			for _,frame in pairs(timelineFrame.highlightsNow) do
				LCG.PixelGlow_Start(frame,nil,nil,nil,nil,1,1,1) 
			end
		end

		local trigger = module.options.setupFrame.data.triggers[module.options.setupFrame.historyFrame.TRIGGER]
		if trigger then
			trigger.event = 1
			trigger.eventCLEU = self.data[3]
			trigger.delayTime = nil
			trigger.spellID = self.data[12]
			trigger.sourceName = self.data[5]
			trigger.sourceID = nil
			trigger.sourceUnit = nil
			trigger.sourceMark = nil
			trigger.sourceID = nil
			trigger.targetName = nil
			trigger.targetID = nil
			trigger.targetUnit = nil
			trigger.targetMark = nil
			trigger.spellName = nil
			trigger.extraSpellID = nil
			trigger.stacks = nil
			trigger.counter = self.data2 and self.data2.count1 and tostring(self.data2.count1) or nil
			trigger.cbehavior = 1

			module.options.setupFrame:Update(module.options.setupFrame.data)
		end
	end

	local function EmoteButton_OnEnter(self)
		self.etext:SetTextColor(0,1,0,1)

		GameTooltip:SetOwner(self,"ANCHOR_BOTTOMRIGHT")
		GameTooltip:AddLine(self.data[3])
		GameTooltip:AddLine(L.ReminderPullTime..": "..format("%d:%02d.%03d",self.data_time/60,self.data_time%60,(self.data_time%1)*1000))
		GameTooltip:AddLine(L.ReminderPhaseTime..": "..format("%d:%02d.%03d",self.data2.timePhase/60,self.data2.timePhase%60,(self.data2.timePhase%1)*1000))
		GameTooltip:AddLine(L.ReminderCounterSource..": "..(self.data[4] or "").." "..(self.data[5] and "|cff888888"..self.data[5].."|r" or ""))
		if self.data[6] and self.data[6] ~= "" then GameTooltip:AddLine(L.ReminderCounterDest..": "..self.data[6]) end
		GameTooltip:Show()
	end
	local function EmoteButton_OnLeave(self)
		self.etext:SetTextColor(1,1,1,1)
		GameTooltip_Hide()
	end

	local function EmoteButton_OnClick(self,button)
		timelineFrame:ResetActiveNavigation()
		if button == "RightButton" then
			return
		end
		timelineFrame.ScrollBarHorizontal:SetValue(self.data_time * timelineFrame.PIX_PER_SEC)
		timelineContent:SetVertical(self.data_time)

		local trigger = module.options.setupFrame.data.triggers[module.options.setupFrame.historyFrame.TRIGGER]
		if trigger then
			trigger.event = 8
			trigger.eventCLEU = nil
			trigger.delayTime = nil
			trigger.pattFind = self.data[3]:gsub("|","||")
			trigger.sourceName = self.data[4]
			trigger.sourceID = nil
			trigger.sourceUnit = nil
			trigger.sourceID = nil
			trigger.targetName = nil
			trigger.targetUnit = nil
			trigger.counter = self.data2 and self.data2.count1 and tostring(self.data2.count1) or nil
			trigger.cbehavior = nil

			module.options.setupFrame:Update(module.options.setupFrame.data)
		end
	end

	function timelineFrame:ResetActiveNavigation()
		local LCG = LibStub("LibCustomGlow-1.0",true)
		if LCG then
			if timelineFrame.highlightsNow then
				for _,frame in pairs(timelineFrame.highlightsNow) do
					LCG.PixelGlow_Stop(frame) 
				end
			end
			timelineFrame.highlightsNow = nil
		end
		timelineContent:SetVertical()
	end

	timelineContent.filterEdit = ELib:Edit(timelineContent):Point(10,-142):Size(300,20):BackgroundText(FILTER):Tooltip(L.ReminderFilterTooltip):OnChange(function (self)
		local text = self:GetText():trim()

		if text == "" then
			text = nil
		else
			text = text:lower()
		end

		timelineFrame.filter = text
		if self.sch then
			self.sch:Cancel()
		end
		self.sch = C_Timer.NewTimer(.5,function()
			self.sch = nil
			timelineFrame:Update("prev")
		end)
	end)

	timelineContent.iconsLine = timelineContent:CreateTexture()
	timelineContent.iconsLine:SetColorTexture(.24,.25,.30,1)
	timelineContent.iconsLine:SetPoint("TOPLEFT",0,-160-25)
	timelineContent.iconsLine:SetPoint("BOTTOMRIGHT",timelineContent,"TOPRIGHT",0,-164-25)

	local function History_CreateBlacklistData()
		local list = {}
		for w in string_gmatch(VMRT.Reminder2.HistoryBlacklist or "","%d+") do
			w = tonumber(w)
			if w then
				list[w] = true
			end
		end
		return list
	end

	timelineFrame.IsPassFilter = function (self, line)
		if line[5] and line[5]:lower():find(self.filter) then
			return true
		elseif line[9] and line[9]:lower():find(self.filter) then
			return true
		end
		if line[12] then
			local name = GetSpellInfo(line[12])
			if name and name:lower():find(self.filter) then
				return true
			end
			if tostring(line[12]) == self.filter then
				return true
			end
		end
	end

	timelineFrame.Update = function (self, historyTable, sourceGUIDFilter)
		self.history = (historyTable == "prev" and self.history) or historyTable or module.db.history[1]
		if not self.history or #self.history <= 1 then
			return
		end

		local len = self.history[#self.history][1] - self.history[1][1]
		if len == 0 then
			return
		end

		self.fightLen = len

		timelineContent.pull:Update()

		self:ResetActiveNavigation()

		local blacklist = History_CreateBlacklistData()
		local phases = {}
		local phaseCounts = {}
		local highlightsList = {}
		self.highlightsList = highlightsList
		local limits = {}
		local spellCounts = {}
		local emotesCounts = {}
		local count = 0
		local countEmote = 0
		local start = self.history[1][1]
		local phaseStart = start
		local sourceFilter = {}
		local lastCast = {}
		for i=1,#self.history do
			local hline = self.history[i]
			if hline[2] == 1 then
				if 
					(not sourceGUIDFilter or hline[4] == sourceGUIDFilter) and
					(
					 ((hline[3] == "SPELL_CAST_SUCCESS" or hline[3] == "SPELL_CAST_START") and (not self.isAuras or self.isAuras == 2)) or
					 ((hline[3] == "SPELL_AURA_APPLIED" or hline[3] == "SPELL_AURA_REMOVED") and self.isAuras) 
					) and
					(not self.filter or self:IsPassFilter(hline)) and
					not blacklist[ hline[12] ]
				then
					count = count + 1
					local icon = timelineContent.spells[count]
					if not icon then
						icon = CreateFrame("Button",nil,timelineContent)
						timelineContent.spells[count] = icon

						icon:RegisterForClicks("RightButtonUp","LeftButtonUp")
						icon:SetScript("OnEnter",SpellIconButton_OnEnter)
						icon:SetScript("OnLeave",SpellIconButton_OnLeave)
						icon:SetScript("OnClick",SpellIconButton_OnClick)
						icon:SetSize(self.LINE_HEIGHT,self.LINE_HEIGHT)

						icon.texture = icon:CreateTexture()
						icon.texture:SetSize(self.LINE_HEIGHT,self.LINE_HEIGHT)
						icon.texture:SetPoint("RIGHT")

						icon.subicon = icon:CreateTexture(nil, "ARTWORK", nil, 2)
						icon.subicon:SetSize(self.LINE_HEIGHT/5,self.LINE_HEIGHT/5)
						icon.subicon:SetPoint("TOPRIGHT",-2,-2)
						icon.subicon:SetTexture([[Interface\AddOns\MRT\media\circle256]])
						icon.subicon:Hide()

						icon.count = icon:CreateFontString(nil,"ARTWORK","GameFontWhite",2)
						icon.count:SetPoint("BOTTOMRIGHT",-2,2)
						icon.count:SetFont(icon.count:GetFont(),12,"OUTLINE")

						icon.linetoline = icon:CreateTexture(nil, "BACKGROUND")
						icon.linetoline:SetColorTexture(.24,.25,.30,1)
						icon.linetoline:SetWidth(2)
						icon.linetoline:SetPoint("TOP",timelineContent.iconsLine,"BOTTOM",0,0)
						icon.linetoline:SetPoint("BOTTOMLEFT",icon,"TOPLEFT",0,0)
					end
					local t = hline[1] - start
					local tp = hline[1] - phaseStart

					local posX = TIMELINE_FRAME_WIDTH / 2 + t*self.PIX_PER_SEC
					local line = 1
					while (limits[line] or 0) > posX do
						line = line + 1
					end
					limits[line] = posX + self.LINE_HEIGHT

					if self.isAuras == 2 then
						icon.subicon:SetShown(hline[3] ~= "SPELL_CAST_SUCCESS")
						if hline[3] == "SPELL_AURA_APPLIED" then
							icon.subicon:SetVertexColor(0,1,0,1)
						elseif hline[3] == "SPELL_AURA_REMOVED" then
							icon.subicon:SetVertexColor(1,1,0,1)
						else
							icon.subicon:SetVertexColor(1,1,1,1)
						end
					else
						icon.subicon:SetShown(hline[3] == "SPELL_CAST_START" or hline[3] == "SPELL_AURA_APPLIED")
						icon.subicon:SetVertexColor(1,1,1,1)
					end

					spellCounts[ hline[3] ] = spellCounts[ hline[3] ] or {}

					local data2 = {}
					spellCounts[ hline[3] ][ hline[4] ] = spellCounts[ hline[3] ][ hline[4] ] or {}
					spellCounts[ hline[3] ][ hline[4] ][ hline[12] ] = (spellCounts[ hline[3] ][ hline[4] ][ hline[12] ] or 0) + 1
					data2.count1 = spellCounts[ hline[3] ][ hline[4] ][ hline[12] ]

					spellCounts[ hline[3] ][ hline[12] ] = (spellCounts[ hline[3] ][ hline[12] ] or 0) + 1
					data2.count = spellCounts[ hline[3] ][ hline[12] ]

					spellCounts[ hline[3] ][ hline[8] ] = spellCounts[ hline[3] ][ hline[8] ] or {}
					spellCounts[ hline[3] ][ hline[8] ][ hline[12] ] = (spellCounts[ hline[3] ][ hline[8] ][ hline[12] ] or 0) + 1
					data2.count2 = spellCounts[ hline[3] ][ hline[8] ][ hline[12] ]

					if not sourceFilter[ hline[4] ] then
						sourceFilter[ hline[4] ] = {hline[5],t}
					end

					lastCast[ hline[3] ] = lastCast[ hline[3] ] or {}
					lastCast[ hline[3] ][ hline[4] ] = lastCast[ hline[3] ][ hline[4] ] or {}
					local prev = lastCast[ hline[3] ][ hline[4] ][ hline[12] ]
					if prev then
						data2.timePrev = t - prev
					end
					lastCast[ hline[3] ][ hline[4] ][ hline[12] ] = t

					icon.data = hline
					icon.data2 = data2
					icon.data_time = t
					data2.timePhase = tp

					icon.count:SetText(data2.count1)

					icon:SetPoint("TOPLEFT",posX,-175-(line-1)*(self.LINE_HEIGHT+4)-25)
					local spellName,_,spellTexture = GetSpellInfo(hline[12])
					icon.texture:SetTexture(spellTexture or 134400)
					icon:Show()

					highlightsList[ hline[3] ] = highlightsList[ hline[3] ] or {}
					highlightsList[ hline[3] ][ hline[12] ] = highlightsList[ hline[3] ][ hline[12] ] or {}
					tinsert(highlightsList[ hline[3] ][ hline[12] ],icon)
					highlightsList[ icon ] = highlightsList[ hline[3] ][ hline[12] ]
				end
			elseif hline[2] == 2 then
				phaseCounts[ hline[3] ] = (phaseCounts[ hline[3] ] or 0) + 1

				phases[#phases+1] = hline[3]
				phases[#phases+1] = hline[1] - start
				phases[#phases+1] = phaseCounts[ hline[3] ]

				phaseStart = hline[1]
			elseif hline[2] == 8 then
				countEmote = countEmote + 1
				local icon = timelineContent.emotes[countEmote]
				if not icon then
					icon = CreateFrame("Button",nil,timelineContent)
					timelineContent.emotes[countEmote] = icon

					icon:RegisterForClicks("RightButtonUp","LeftButtonUp")
					icon:SetScript("OnEnter",EmoteButton_OnEnter)
					icon:SetScript("OnLeave",EmoteButton_OnLeave)
					icon:SetScript("OnClick",EmoteButton_OnClick)
					icon:SetSize(10,10)

					icon.etext = icon:CreateFontString(nil,"ARTWORK","GameFontWhite",2)
					icon.etext:SetPoint("CENTER",0,0)
					icon.etext:SetFont(icon.etext:GetFont(),10,"OUTLINE")
					icon.etext:SetText("e")
				end
				local t = hline[1] - start
				local tp = hline[1] - phaseStart

				local posX = TIMELINE_FRAME_WIDTH / 2 + t*self.PIX_PER_SEC

				emotesCounts[ hline[3] or "" ] = (emotesCounts[ hline[3] or "" ] or 0)+1

				icon.data = hline
				icon.data2 = {
					timePhase = tp,
					count1 = emotesCounts[ hline[3] or "" ],
				}
				icon.data_time = t

				local diffY = 0
				if timelineContent.emotes[countEmote-1] and (posX - timelineContent.emotes[countEmote-1].posX) < 5 then
					diffY = 5
				end

				icon.posX = posX
				icon:SetPoint("BOTTOMLEFT",timelineContent,"TOPLEFT",posX,-158+diffY-25)
				icon:Show()
			end
		end
		for i=count+1,#timelineContent.spells do
			timelineContent.spells[i]:Hide()
		end
		for i=countEmote+1,#timelineContent.emotes do
			timelineContent.emotes[i]:Hide()
		end

		local maxLine = 1
		for i in pairs(limits) do
			maxLine = max(i,maxLine)
		end

		local height = 175 + 10 + maxLine * (self.LINE_HEIGHT + 4)

		self:Height(height)
		self.ScrollBar:SetShown(height > TIMELINE_FRAME_HEIGHT)
		self.ScrollBar:SetValue(0)

		self:Width(TIMELINE_FRAME_WIDTH+(len+self.SEC_PER_SEG)*self.PIX_PER_SEC)
		self.ScrollBarHorizontal:SetValue(0)

		timelineContent.phase.phases = phases
		timelineContent.phase:Update()

		self.filterDropDown.sourceFilter = sourceFilter
	end
	timelineFrame:SetScript("OnShow",function (self)
		self:Update()
	end)



	local historyList = ELib:ScrollTableList(self.setupFrame.historyFrame.tab.tabs[2],90,50,0,40,65,25,90,90):Size(580,444):Point("TOPLEFT",0,0):FontSize(11):HideBorders()
	self.setupFrame.historyFrame.tab.tabs[2].historyList = historyList
	function historyList:UpdateAdditional()
		for i=1,#self.List do
			self.List[i].text3:SetWordWrap(false)
			self.List[i].text6:SetWordWrap(false)
			self.List[i].text7:SetWordWrap(false)
		end
	end
	historyList.Background = historyList:CreateTexture(nil,"BACKGROUND")
	historyList.Background:SetColorTexture(0,0,0,.9)
	historyList.Background:SetPoint("TOPLEFT")
	historyList.Background:SetPoint("BOTTOMRIGHT")

	historyList.additionalLineFunctions = true
	function historyList:HoverMultitableListValue(isEnter,index,obj)
		if not isEnter then
			local line = obj.parent:GetParent()
			--line:GetScript("OnLeave")(line)
			line.HighlightTexture2:Hide()

			GameTooltip_Hide()
		else
			local line = obj.parent:GetParent()
			--line:GetScript("OnEnter")(line)
			if not line.HighlightTexture2 then
				line.HighlightTexture2 = line:CreateTexture()
				line.HighlightTexture2:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
				line.HighlightTexture2:SetBlendMode("ADD")
				line.HighlightTexture2:SetPoint("LEFT",0,0)
				line.HighlightTexture2:SetPoint("RIGHT",0,0)
				line.HighlightTexture2:SetHeight(15)
				line.HighlightTexture2:SetVertexColor(1,1,1,1)
			end
			line.HighlightTexture2:Show()

			local data = line.table
			if index == 3 then
				if data.notspell then
					return
				end
				GameTooltip:SetOwner(obj,"ANCHOR_CURSOR")
				GameTooltip:SetHyperlink("spell:"..data[2] )
				GameTooltip:Show()
			elseif index == 4 or index == 5 then
				GameTooltip:SetOwner(obj,"ANCHOR_CURSOR")
				GameTooltip:AddLine(index == 4 and L.ReminderPullTime or L.ReminderPhaseTime)
				local text = obj.parent:GetText()
				if text then
					local min,sec = text:match("(%d+):(%d+)")
					local insec = tonumber(min)*60 + tonumber(sec)
					GameTooltip:AddLine(L.ReminderSeconds..": "..insec)
				end
				if index == 5 and data.phase then
					GameTooltip:AddLine(L.ReminderPhase..": "..data.phase)
				end
				GameTooltip:Show()
			elseif index == 6 then
				GameTooltip:SetOwner(obj,"ANCHOR_CURSOR")
				GameTooltip:AddLine(L.ReminderFromPrevEvent)
				GameTooltip:Show()
			elseif index == 2 then
				GameTooltip:SetOwner(obj,"ANCHOR_CURSOR")
				GameTooltip:AddLine("Spell ID")
				GameTooltip:Show()
			else
				if obj.parent:IsTruncated() then
					GameTooltip:SetOwner(obj,"ANCHOR_CURSOR")
					GameTooltip:AddLine(obj.parent:GetText() )
					GameTooltip:Show()
				end
			end
		end
	end
	function historyList:ClickMultitableListValue(index,obj)
		local tdata = obj:GetParent().table
		if not tdata then
			return
		end
		local data = tdata.data

		local trigger = module.options.setupFrame.data.triggers[module.options.setupFrame.historyFrame.TRIGGER]
		if not trigger then
			return
		end
		if index == 4 then
			local t = tdata.timeFromStart
			trigger.event = 3
			trigger.delayTime = t < 60 and (floor(t * 10)/10) or format("%d:%02d.%d",t/60,t%60,t%1*10)
			module.options.setupFrame:Update(module.options.setupFrame.data)
		elseif index == 5 then
			local t = tdata.timeFromPhase
			trigger.event = 2
			trigger.delayTime = t < 60 and (floor(t * 10)/10) or format("%d:%02d.%d",t/60,t%60,t%1*10)
			trigger.pattFind = tostring(tdata.phase)
			trigger.counter = tdata.phaseCount and tostring(tdata.phaseCount) or nil
			trigger.cbehavior = nil
			module.options.setupFrame:Update(module.options.setupFrame.data)
		else
			local t = tdata.timeFromPrev

			trigger.event = 1
			trigger.eventCLEU = data[3]
			if index == 6 and tdata.timeFromPrev then
				trigger.delayTime = t < 60 and (floor(t * 10)/10) or format("%d:%02d.%d",t/60,t%60,t%1*10)
			else
				trigger.delayTime = nil
			end
			trigger.spellID = data[12]
			trigger.sourceName = data[5]
			trigger.sourceID = nil
			trigger.sourceUnit = nil
			trigger.sourceMark = nil
			trigger.sourceID = nil
			trigger.targetName = nil
			trigger.targetID = nil
			trigger.targetUnit = nil
			trigger.targetMark = nil
			trigger.spellName = nil
			trigger.extraSpellID = nil
			trigger.stacks = nil
			trigger.counter = tdata.data2 and index == 6 and tdata.timeFromPrev and tdata.data2.count1-1 and tostring(tdata.data2.count1-1) or tdata.data2 and tdata.data2.count1 and tostring(tdata.data2.count1) or nil
			trigger.cbehavior = 1

			module.options.setupFrame:Update(module.options.setupFrame.data)
		end
	end

	function historyList:FormatName(name,flags)
		if not name and not flags then
			return
		elseif name and flags then
			if UnitClass(name) then
				name = "|c" .. RAID_CLASS_COLORS[select(2,UnitClass(name))].colorStr .. name
			end
			local mark = module.datas.markToIndex[flags]
			if mark and mark > 0 then
				name = ExRT.F.GetRaidTargetText(mark).." " .. name
			end
			return name
		elseif flags then
			local mark = module.datas.markToIndex[flags]
			if mark and mark > 0 then
				return ExRT.F.GetRaidTargetText(mark)
			end
		else
			if UnitClass(name) then
				name = "|c" .. RAID_CLASS_COLORS[select(2,UnitClass(name))].colorStr .. name
			end
			return name
		end
	end

	function historyList:Update2(historyTable, sourceGUIDFilter)
		self.history = (historyTable == "prev" and self.history) or historyTable or module.db.history[1]
		if not self.history or #self.history <= 1 then
			return
		end

		local len = self.history[#self.history][1] - self.history[1][1]
		if len == 0 then
			return
		end

		local blacklist = History_CreateBlacklistData()
		local spellCounts = {}
		local phaseCounts = {}
		local count = 0
		local start = self.history[1][1]
		local phaseStart = start
		local sourceFilter = {}
		local lastCast = {}
		local phaseNow = "1"
		local phaseNowCount = 0

		local result = {}

		for i=2,#self.history do
			local hline = self.history[i]
			if hline[2] == 1 then
				if 
					(not sourceGUIDFilter or hline[4] == sourceGUIDFilter) and
					(
					 ((hline[3] == "SPELL_CAST_SUCCESS" or hline[3] == "SPELL_CAST_START") and (not self.isAuras or self.isAuras == 2)) or
					 ((hline[3] == "SPELL_AURA_APPLIED" or hline[3] == "SPELL_AURA_REMOVED") and self.isAuras) 
					) and
					not blacklist[ hline[12] ]
				then
					local t = hline[1] - start
					local tp = hline[1] - phaseStart

					spellCounts[ hline[3] ] = spellCounts[ hline[3] ] or {}

					local data2 = {}
					spellCounts[ hline[3] ][ hline[4] ] = spellCounts[ hline[3] ][ hline[4] ] or {}
					spellCounts[ hline[3] ][ hline[4] ][ hline[12] ] = (spellCounts[ hline[3] ][ hline[4] ][ hline[12] ] or 0) + 1
					data2.count1 = spellCounts[ hline[3] ][ hline[4] ][ hline[12] ]

					spellCounts[ hline[3] ][ hline[12] ] = (spellCounts[ hline[3] ][ hline[12] ] or 0) + 1
					data2.count = spellCounts[ hline[3] ][ hline[12] ]

					spellCounts[ hline[3] ][ hline[8] ] = spellCounts[ hline[3] ][ hline[8] ] or {}
					spellCounts[ hline[3] ][ hline[8] ][ hline[12] ] = (spellCounts[ hline[3] ][ hline[8] ][ hline[12] ] or 0) + 1
					data2.count2 = spellCounts[ hline[3] ][ hline[8] ][ hline[12] ]

					if not sourceFilter[ hline[4] ] then
						sourceFilter[ hline[4] ] = {hline[5],t}
					end

					lastCast[ hline[3] ] = lastCast[ hline[3] ] or {}
					lastCast[ hline[3] ][ hline[4] ] = lastCast[ hline[3] ][ hline[4] ] or {}
					local prev = lastCast[ hline[3] ][ hline[4] ][ hline[12] ]
					if prev then
						data2.timePrev = t - prev
					end
					lastCast[ hline[3] ][ hline[4] ][ hline[12] ] = t

					data2.timePhase = tp

					local spellName,_,spellTexture = GetSpellInfo(hline[12])

					result[#result+1] = {
						module.C[ hline[3] ] and module.C[ hline[3] ].lname or hline[3],
						hline[12],
						data2.count1.." |T"..(spellTexture or 134400)..":0|t "..(spellName or "Spell "..hline[12]),
						format("%d:%02d",t/60,t%60),
						"["..phaseNowCount.."] "..format("%d:%02d",tp/60,tp%60),
						data2.timePrev and format("%d",data2.timePrev),
						self:FormatName(hline[5],hline[7]),
						self:FormatName(hline[9],hline[11]),

						event=hline[3],
						timeFromStart=t,
						timeFromPhase=tp,
						phase=phaseNow,
						phaseCount=phaseCounts[ phaseNow ],
						timeFromPrev=data2.timePrev,
						data = hline,
						data2 = data2,
					}
				end
			elseif hline[2] == 2 then
				phaseCounts[ hline[3] ] = (phaseCounts[ hline[3] ] or 0) + 1

				phaseStart = hline[1]
				phaseNow = hline[3]
				phaseNowCount = phaseNowCount + 1
			end
		end

		self.L = result
		self:Update()

		timelineFrame.filterDropDown.sourceFilter = sourceFilter
	end
	historyList:SetScript("OnShow",function(self)
		self:Update2()
	end)


	local spellsHistory = ELib:ScrollButtonsList(self.setupFrame.historyFrame.tab.tabs[3]):Point("TOP",0,0):Size(450,425)
	spellsHistory.ButtonsInLine = 2
	self.setupFrame.historyFrame.tab.tabs[3].scrollList = spellsHistory
	ELib:Border(spellsHistory,0)

	function spellsHistory:ButtonClick(historyTable)
		local data = self.data
		if not data then
			return
		end
		local trigger = module.options.setupFrame.data.triggers[module.options.setupFrame.historyFrame.TRIGGER]
		if trigger then
			trigger.event = 1
			trigger.eventCLEU = data.event
			trigger.delayTime = nil
			trigger.spellID = data.sid
			trigger.sourceName = data.sname
			trigger.sourceID = nil
			trigger.sourceUnit = nil
			trigger.sourceMark = nil
			trigger.sourceID = nil
			trigger.targetName = nil
			trigger.targetID = nil
			trigger.targetUnit = nil
			trigger.targetMark = nil
			trigger.spellName = nil
			trigger.extraSpellID = nil
			trigger.stacks = nil
			trigger.counter = nil
			trigger.cbehavior = nil

			module.options.setupFrame:Update(module.options.setupFrame.data)
		end
	end

	function spellsHistory:UpdateData(historyTable)
		local Mdata = {}
		self.history = (historyTable == "prev" and self.history) or historyTable or module.db.history[1]
		if not self.history or #self.history <= 1 then
			return
		end

		local len = self.history[#self.history][1] - self.history[1][1]
		if len == 0 then
			return
		end

		local start = self.history[1][1]

		for i=2,#self.history do
			local hline = self.history[i]
			if hline[2] == 1 then
				if 
					hline[3] == "SPELL_CAST_SUCCESS" or hline[3] == "SPELL_CAST_START" or 
					hline[3] == "SPELL_AURA_APPLIED" or hline[3] == "SPELL_AURA_REMOVED"
				then
					local t = hline[1] - start
					local event = hline[3]
					if event == "SPELL_AURA_REMOVED" then
						event = "SPELL_AURA_APPLIED"
					end

					local sourceData = ExRT.F.table_find3(Mdata,hline[5] or L.ReminderEnv,"lname")
					if not sourceData then
						sourceData = {
							uid = hline[4],
							name = (hline[5] or L.ReminderEnv).." "..format("%d:%02d",t/60,t%60),
							lname = hline[5] or L.ReminderEnv,
							data = {},
						}
						Mdata[#Mdata+1] = sourceData
					end

					local isFound
					for i=1,#sourceData.data do
						local d = sourceData.data[i]
						if d.sid == hline[12] and d.event == event then
							isFound = true
							break
						end
					end
					if not isFound then
						local spellName,_,spellTexture = GetSpellInfo(hline[12])

						sourceData.data[#sourceData.data+1] = {
							uid = hline[4] .. "-" .. event .. "-" .. hline[12],
							name = "|T"..(spellTexture or 134400)..":0|t "..(spellName or "Spell "..hline[12]),
							sid = hline[12],
							sname = hline[5],
							event = event,
							lname = spellName or "Spell "..hline[12],
						}
					end
				elseif hline[2] == 2 then

				end
			end
		end
		for i=1,#Mdata do
			local d = Mdata[i].data
			sort(d,function(a,b)
				if a.event == b.event then
					return a.lname < b.lname
				else
					return a.event < b.event
				end
			end)
			local prev
			local c = 1
			while c <= #d do
				if d[c].event ~= prev then
					prev = d[c].event
					tinsert(d,c,module.C[prev] and module.C[prev].lname or prev)
					c = c + 1
				end
				c = c + 1
			end
		end

		self.data = Mdata
		self:Update(true)
	end

	spellsHistory:SetScript("OnShow",function(self)
		self:UpdateData()
	end)


	ELib:DecorationLine(self.tab.tabs[3],true,"BACKGROUND",1):Point("TOPLEFT",self,0,-50):Point("BOTTOMRIGHT",self,"TOPRIGHT",0,-70)

	self.options_tab = ELib:Tabs(self.tab.tabs[3],0,GENERAL_LABEL,L.cd2Appearance,TUTORIAL_TITLE19):Point(0,-25):Size(698,570):SetTo(1)
	self.options_tab:SetBackdropBorderColor(0,0,0,0)
	self.options_tab:SetBackdropColor(0,0,0,0)

	self.chkLock = ELib:Check(self.options_tab.tabs[1],L.ReminderTestMode..":",false):Point(200,-10):Left(5):OnClick(function(self) 
		frame.unlocked = self:GetChecked()
		module:UpdateVisual()
	end)

	self.ResetPosButton = ELib:Button(self.options_tab.tabs[1],L.MarksBarResetPos):Point("LEFT",self.chkLock,"RIGHT",100,0):Size(200,20):OnClick(function()
		VMRT.Reminder2.Left = nil
		VMRT.Reminder2.Top = nil
		VMRT.Reminder2.BarsLeft = nil
		VMRT.Reminder2.BarsTop = nil
		frame:ClearAllPoints()
		frame:SetPoint("CENTER",UIParent,"TOP",0,-100)
		frameBars:ClearAllPoints()
		frameBars:SetPoint("CENTER",UIParent,"TOP",0,-250)
	end)

	self.chkDebug = ELib:Check(self.options_tab.tabs[1],"Debug mode",false):Point(450,-10):OnClick(function(self) 
		module:ToggleDebugMode()

		self:SetChecked(module.db.debug)
	end)
	local debugCheckFrame = CreateFrame("Frame",nil,self.tab.tabs[3])
	debugCheckFrame:SetPoint("TOPLEFT")
	debugCheckFrame:SetSize(1,1)
	debugCheckFrame:SetScript("OnShow",function()
		if IsShiftKeyDown() and IsAltKeyDown() then
			self.chkDebug:Show()
		else
			self.chkDebug:Hide()
		end
	end)

	self.disableSound = ELib:Check(self.options_tab.tabs[1],L.ReminderDisableSound..":",VMRT.Reminder2.disableSound):Point("TOPLEFT",self.chkLock,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self) 
		VMRT.Reminder2.disableSound = self:GetChecked()
	end)

	self.disableUpdates = ELib:Check(self.options_tab.tabs[1],L.ReminderDisableUpdates..":",VMRT.Reminder2.disableUpdates):Point("TOPLEFT",self.disableSound,"BOTTOMLEFT",0,-5):Left(5):Tooltip(L.ReminderDisableUpdatesTooltip):OnClick(function(self) 
		VMRT.Reminder2.disableUpdates = self:GetChecked()
	end)

	self.disablePopups = ELib:Check(self.options_tab.tabs[1],L.ReminderDisablePopups..":",VMRT.Reminder2.disablePopups):Point("TOPLEFT",self.disableUpdates,"BOTTOMLEFT",0,-5):Left(5):Tooltip(L.ReminderDisablePopupsTooltip):OnClick(function(self) 
		VMRT.Reminder2.disablePopups = self:GetChecked()
	end)


	self.optionWidgets = ELib:Tabs(self.options_tab.tabs[2],0,L.ReminderAppText,L.ReminderAppGlow,L.ReminderAppBars):Point("TOP",0,-30):Point("LEFT",self.tab.tabs[3],10,0):Size(678,120):SetTo(1)
	self.optionWidgets:SetBackdropBorderColor(0,0,0,0)
	self.optionWidgets:SetBackdropColor(0,0,0,0)

	ELib:DecorationLine(self.optionWidgets,true,"BACKGROUND",1):Point("TOP",0,20):Point("LEFT",-1,0):Point("RIGHT",1,0):Size(0,20)

	ELib:Border(self.optionWidgets,1,.24,.25,.30)

	self.sliderFontSize = ELib:Slider(self.optionWidgets.tabs[1],""):Size(320):Point(190,-15):Range(10,80):SetTo(VMRT.Reminder2.FontSize or 50):OnChange(function(self,event) 
		event = floor(event + .5)
		VMRT.Reminder2.FontSize = event
		module:UpdateVisual()
		self.tooltipText = event
		self:tooltipReload(self)
	end)
	ELib:Text(self.optionWidgets.tabs[1],L.ReminderFontSize..":",11):Point("RIGHT",self.sliderFontSize,"LEFT",-5,0):Color(1,.82,0,1):Right()

	local function dropDownFontSetValue(_,arg1)
		ELib:DropDownClose()
		VMRT.Reminder2.Font = arg1
		self.dropDownFont:SetText(arg1)
		module:UpdateVisual()
	end

	self.dropDownFont = ELib:DropDown(self.optionWidgets.tabs[1],350,10):Size(320):Point("TOPLEFT",self.sliderFontSize,"BOTTOMLEFT",0,-15):SetText(VMRT.Reminder2.Font or ExRT.F.defFont):AddText("|cffffce00"..L.ReminderFont..":")
	for i=1,#ExRT.F.fontList do
		local info = {}
		self.dropDownFont.List[i] = info
		info.text = ExRT.F.fontList[i]
		info.arg1 = ExRT.F.fontList[i]
		info.func = dropDownFontSetValue
		info.font = ExRT.F.fontList[i]
		info.justifyH = "CENTER" 
	end
	for key,font in ExRT.F.IterateMediaData("font") do
		local info = {}
		self.dropDownFont.List[#self.dropDownFont.List+1] = info

		info.text = key
		info.arg1 = font
		info.func = dropDownFontSetValue
		info.font = font
		info.justifyH = "CENTER" 
	end

	local function dropDownFontAdjSetValue(_,arg1)
		ELib:DropDownClose()
		VMRT.Reminder2.FontAdj = arg1
		self.dropDownFontAdj:SetText(VMRT.Reminder2.FontAdj == 1 and L.cd2ColSetFontPosLeft or VMRT.Reminder2.FontAdj == 2 and L.cd2ColSetFontPosRight or L.cd2ColSetFontPosCenter)
		module:UpdateVisual()
	end
	self.dropDownFontAdj = ELib:DropDown(self.optionWidgets.tabs[1],350,-1):Size(320):Point("TOPLEFT",self.dropDownFont,"BOTTOMLEFT",0,-5):SetText(VMRT.Reminder2.FontAdj == 1 and L.cd2ColSetFontPosLeft or VMRT.Reminder2.FontAdj == 2 and L.cd2ColSetFontPosRight or L.cd2ColSetFontPosCenter):AddText("|cffffce00"..L.ReminderFontAdjustment..":")
	self.dropDownFontAdj.List[1] = {text = L.cd2ColSetFontPosCenter, func = dropDownFontAdjSetValue, arg1 = nil, justifyH = "CENTER"}
	self.dropDownFontAdj.List[2] = {text = L.cd2ColSetFontPosLeft, func = dropDownFontAdjSetValue, arg1 = 1, justifyH = "LEFT"}
	self.dropDownFontAdj.List[3] = {text = L.cd2ColSetFontPosRight, func = dropDownFontAdjSetValue, arg1 = 2, justifyH = "RIGHT"}

	self.fontOutline = ELib:Check(self.optionWidgets.tabs[1],L.ReminderGlow,VMRT.Reminder2.FontOutline):Point("LEFT",self.dropDownFont,"RIGHT",5,0):OnClick(function(self) 
		VMRT.Reminder2.FontOutline = self:GetChecked()
		module:UpdateVisual()
	end)


	local function HideNameplateGlows()
		local LCG = LibStub("LibCustomGlow-1.0",true)
		if LCG then
			for _,frame in pairs(module.db.nameplateFrames) do
				LCG.ButtonGlow_Stop(frame)
				LCG.AutoCastGlow_Stop(frame)
				LCG.PixelGlow_Stop(frame)
			end  
		end
	end

	self.nameplateTypeGlow1 = ELib:Radio(self.optionWidgets.tabs[2],""):Point(190,-10):OnClick(function() 
		self.nameplateTypeGlow1:SetChecked(true)
		self.nameplateTypeGlow2:SetChecked(false)
		self.nameplateTypeGlow3:SetChecked(false)
		VMRT.Reminder2.NameplateGlowType = 1
		HideNameplateGlows()
	end)
	self.nameplateTypeGlow1.f = CreateFrame("Frame",nil,self.nameplateTypeGlow1)
	self.nameplateTypeGlow1.f:SetPoint("LEFT",self.nameplateTypeGlow1,"RIGHT",5,0)
	self.nameplateTypeGlow1.f:SetSize(40,15)

	ELib:Text(self.optionWidgets.tabs[2],L.ReminderGlowTypeNameplate..":",12):Point("RIGHT",self.nameplateTypeGlow1,"LEFT",-5,0):Color(1,.82,0,1)

	self.nameplateTypeGlow2 = ELib:Radio(self.optionWidgets.tabs[2],""):Point("LEFT",self.nameplateTypeGlow1,100,0):OnClick(function() 
		self.nameplateTypeGlow1:SetChecked(false)
		self.nameplateTypeGlow2:SetChecked(true)
		self.nameplateTypeGlow3:SetChecked(false)
		VMRT.Reminder2.NameplateGlowType = 2
		HideNameplateGlows()
	end)
	self.nameplateTypeGlow2.f = CreateFrame("Frame",nil,self.nameplateTypeGlow2)
	self.nameplateTypeGlow2.f:SetPoint("LEFT",self.nameplateTypeGlow2,"RIGHT",5,0)
	self.nameplateTypeGlow2.f:SetSize(40,15)

	self.nameplateTypeGlow3 = ELib:Radio(self.optionWidgets.tabs[2],""):Point("LEFT",self.nameplateTypeGlow2,100,0):OnClick(function() 
		self.nameplateTypeGlow1:SetChecked(false)
		self.nameplateTypeGlow2:SetChecked(false)
		self.nameplateTypeGlow3:SetChecked(true)
		VMRT.Reminder2.NameplateGlowType = 3
		HideNameplateGlows()
	end)
	self.nameplateTypeGlow3.f = CreateFrame("Frame",nil,self.nameplateTypeGlow3)
	self.nameplateTypeGlow3.f:SetPoint("LEFT",self.nameplateTypeGlow3,"RIGHT",5,0)
	self.nameplateTypeGlow3.f:SetSize(40,15)

	local LCG = LibStub("LibCustomGlow-1.0",true)
	if LCG then
		LCG.PixelGlow_Start(self.nameplateTypeGlow1.f,nil,nil,nil,nil,2,1,1) 
		LCG.ButtonGlow_Start(self.nameplateTypeGlow2.f)
		LCG.AutoCastGlow_Start(self.nameplateTypeGlow3.f)
	end

	if VMRT.Reminder2.NameplateGlowType == 2 then
		self.nameplateTypeGlow2:SetChecked(true)
	elseif VMRT.Reminder2.NameplateGlowType == 3 then
		self.nameplateTypeGlow3:SetChecked(true)
	else
		self.nameplateTypeGlow1:SetChecked(true)
	end


	local function HideFrameGlows()
		for guid,frame in pairs(module.db.frameGUIDToFrames) do
			module:RaidframeUpdate(frame, guid, module.db.frameHL[guid])
		end
	end

	self.frameTypeGlow1 = ELib:Radio(self.optionWidgets.tabs[2],""):Point(190,-35):OnClick(function() 
		self.frameTypeGlow1:SetChecked(true)
		self.frameTypeGlow2:SetChecked(false)
		self.frameTypeGlow3:SetChecked(false)
		VMRT.Reminder2.FrameGlowType = 1
		HideFrameGlows()
	end)
	self.frameTypeGlow1.f = CreateFrame("Frame",nil,self.frameTypeGlow1)
	self.frameTypeGlow1.f:SetPoint("LEFT",self.frameTypeGlow1,"RIGHT",5,0)
	self.frameTypeGlow1.f:SetSize(40,15)

	ELib:Text(self.optionWidgets.tabs[2],L.ReminderGlowTypeFrame..":",12):Point("RIGHT",self.frameTypeGlow1,"LEFT",-5,0):Color(1,.82,0,1)

	self.frameTypeGlow2 = ELib:Radio(self.optionWidgets.tabs[2],""):Point("LEFT",self.frameTypeGlow1,100,0):OnClick(function() 
		self.frameTypeGlow1:SetChecked(false)
		self.frameTypeGlow2:SetChecked(true)
		self.frameTypeGlow3:SetChecked(false)
		VMRT.Reminder2.FrameGlowType = 2
		HideFrameGlows()
	end)
	self.frameTypeGlow2.f = CreateFrame("Frame",nil,self.frameTypeGlow2)
	self.frameTypeGlow2.f:SetPoint("LEFT",self.frameTypeGlow2,"RIGHT",5,0)
	self.frameTypeGlow2.f:SetSize(40,15)

	self.frameTypeGlow3 = ELib:Radio(self.optionWidgets.tabs[2],""):Point("LEFT",self.frameTypeGlow2,100,0):OnClick(function() 
		self.frameTypeGlow1:SetChecked(false)
		self.frameTypeGlow2:SetChecked(false)
		self.frameTypeGlow3:SetChecked(true)
		VMRT.Reminder2.FrameGlowType = 3
		HideFrameGlows()
	end)
	self.frameTypeGlow3.f = CreateFrame("Frame",nil,self.frameTypeGlow3)
	self.frameTypeGlow3.f:SetPoint("LEFT",self.frameTypeGlow3,"RIGHT",5,0)
	self.frameTypeGlow3.f:SetSize(40,15)

	local LCG = LibStub("LibCustomGlow-1.0",true)
	if LCG then
		ExRT.F:SafeCall(LCG.PixelGlow_Start, self.frameTypeGlow1.f,nil,nil,nil,nil,2,1,1)
		ExRT.F:SafeCall(LCG.ButtonGlow_Start, self.frameTypeGlow2.f)
		ExRT.F:SafeCall(LCG.AutoCastGlow_Start, self.frameTypeGlow3.f)
	end

	if VMRT.Reminder2.FrameGlowType == 2 then
		self.frameTypeGlow2:SetChecked(true)
	elseif VMRT.Reminder2.FrameGlowType == 3 then
		self.frameTypeGlow3:SetChecked(true)
	else
		self.frameTypeGlow1:SetChecked(true)
	end


	self.sliderBarWidth = ELib:Slider(self.optionWidgets.tabs[3],""):Size(320):Point(190,-15):Range(50,1000):SetTo(VMRT.Reminder2.BarWidth or 500):OnChange(function(self,event) 
		event = floor(event + .5)
		VMRT.Reminder2.BarWidth = event
		module:UpdateVisual()
		self.tooltipText = event
		self:tooltipReload(self)
	end)
	ELib:Text(self.optionWidgets.tabs[3],L.cd2width..":",11):Point("RIGHT",self.sliderBarWidth,"LEFT",-5,0):Color(1,.82,0,1):Right()

	self.sliderBarHeight = ELib:Slider(self.optionWidgets.tabs[3],""):Size(320):Point("TOPLEFT",self.sliderBarWidth,"BOTTOMLEFT",0,-15):Range(16,96):SetTo(VMRT.Reminder2.BarHeight or 40):OnChange(function(self,event) 
		event = floor(event + .5)
		VMRT.Reminder2.BarHeight = event
		module:UpdateVisual()
		self.tooltipText = event
		self:tooltipReload(self)
	end)
	ELib:Text(self.optionWidgets.tabs[3],L.ReminderHeight..":",11):Point("RIGHT",self.sliderBarHeight,"LEFT",-5,0):Color(1,.82,0,1):Right()

	local function dropDownBarTextureSetValue(_,arg1)
		ELib:DropDownClose()
		VMRT.Reminder2.BarTexture = arg1
		module:UpdateVisual()
	end

	self.dropDownBarTexture = ELib:DropDown(self.optionWidgets.tabs[3],350,10):Size(320):Point("TOPLEFT",self.sliderBarHeight,"BOTTOMLEFT",0,-15):SetText(""):AddText("|cffffce00"..L.cd2OtherSetTexture..":")
	self.dropDownBarTexture.List[1] = {
		text = "default",
		func = dropDownBarTextureSetValue,
		justifyH = "CENTER" ,
		texture = [[Interface\AddOns\MRT\media\bar17.tga]],
	}
	for i=1,#ExRT.F.textureList do
		local info = {}
		self.dropDownBarTexture.List[#self.dropDownBarTexture.List+1] = info
		info.text = i
		info.arg1 = ExRT.F.textureList[i]
		info.arg2 = i
		info.func = dropDownBarTextureSetValue
		info.texture = ExRT.F.textureList[i]
		info.justifyH = "CENTER" 
	end
	for key,texture in ExRT.F.IterateMediaData("statusbar") do
		local info = {}
		self.dropDownBarTexture.List[#self.dropDownBarTexture.List+1] = info

		info.text = key
		info.arg1 = texture
		info.arg2 = key
		info.func = dropDownBarTextureSetValue
		info.texture = texture
		info.justifyH = "CENTER" 
	end

	local function dropDownBarFontSetValue(_,arg1)
		ELib:DropDownClose()
		VMRT.Reminder2.BarFont = arg1
		self.dropDownBarFont:SetText(arg1)
		module:UpdateVisual()
	end

	self.dropDownBarFont = ELib:DropDown(self.optionWidgets.tabs[3],350,10):Size(320):Point("TOPLEFT",self.dropDownBarTexture,"BOTTOMLEFT",0,-5):SetText(VMRT.Reminder2.BarFont or ExRT.F.defFont):AddText("|cffffce00"..L.ReminderFont..":")
	for i=1,#ExRT.F.fontList do
		local info = {}
		self.dropDownBarFont.List[i] = info
		info.text = ExRT.F.fontList[i]
		info.arg1 = ExRT.F.fontList[i]
		info.func = dropDownBarFontSetValue
		info.font = ExRT.F.fontList[i]
		info.justifyH = "CENTER" 
	end
	for key,font in ExRT.F.IterateMediaData("font") do
		local info = {}
		self.dropDownBarFont.List[#self.dropDownBarFont.List+1] = info

		info.text = key
		info.arg1 = font
		info.func = dropDownBarFontSetValue
		info.font = font
		info.justifyH = "CENTER" 
	end


	self.chkHistory = ELib:Check(self.options_tab.tabs[1],L.ReminderSpellsHistory..":",VMRT.Reminder2.HistoryEnabled):Point("TOPLEFT",self.disablePopups,"BOTTOMLEFT",0,-10):Left(5):OnClick(function(self) 
		VMRT.Reminder2.HistoryEnabled = self:GetChecked()
	end):Tooltip(L.ReminderSpellsHistoryTooltip)

	self.chkHistorySession = ELib:Check(self.options_tab.tabs[1],L.ReminderSpellsHistorySaveSession..":",VMRT.Reminder2.HistorySession):Point("TOPLEFT",self.chkHistory,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self) 
		VMRT.Reminder2.HistorySession = self:GetChecked()
		if VMRT.Reminder2.HistorySession then
			VMRT.Reminder2.history = module.db.history
		else
			VMRT.Reminder2.history = nil
		end
	end)

	self.sliderHistoryNumSaved = ELib:Slider(self.options_tab.tabs[1],""):Size(320):Point("TOPLEFT",self.chkHistorySession,"BOTTOMLEFT",0,-10):Range(1,10):SetTo(VMRT.Reminder2.HistoryNumSaved or 1):SetObey(true):OnChange(function(self,event) 
		event = floor(event + .5)
		VMRT.Reminder2.HistoryNumSaved = event
		self.tooltipText = event
		self:tooltipReload(self)
	end)
	ELib:Text(self.options_tab.tabs[1],L.ReminderSpellsHistoryCount..":",11):Point("RIGHT",self.sliderHistoryNumSaved,"LEFT",-5,0):Color(1,.82,0,1):Right()

	local function dropDownGenSoundSetValue(_,arg1,arg2)
		ELib:DropDownClose()
		VMRT.Reminder2["generalSound"..arg1] = arg2
		pcall(PlaySoundFile, arg2, "Master")

		local soundName
		for name, path in ExRT.F.IterateMediaData("sound") do
			if arg2 == path then
				soundName = name
			end
		end
		self["dropDownSound"..arg1]:SetText(soundName or arg2 or "-")
	end
	local count = 0
	for k,v in pairs(module.datas.sounds) do
		if type(v[1])=='string' and tonumber(v[1]) then
			count = count + 1

			local obj = ELib:DropDown(self.options_tab.tabs[2],350,10):Size(320):Point(200,-125):SetText(VMRT.Reminder2["generalSound"..count] or "-"):AddText("|cffffce00"..L.ReminderSound..": "..v[2]:gsub("^[^%-]+- *",""))
			self["dropDownSound"..count] = obj
			if count == 1 then
				obj:Point("TOPLEFT",self.optionWidgets,"BOTTOMLEFT",190,-15)
			else
				obj:Point("TOPLEFT",self["dropDownSound"..(count-1)],"BOTTOMLEFT",0,-5)
			end

			obj.playButton = ELib:Icon(obj,"Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128",20,true):Point("LEFT",obj,"RIGHT",5,0)
			obj.playButton.texture:SetTexCoord(0.375,0.4375,0.5,0.625)
			local arg = "generalSound"..count
			obj.playButton:SetScript("OnClick",function()
				pcall(PlaySoundFile, VMRT.Reminder2[arg], "Master")
			end)

			local soundVal = VMRT.Reminder2["generalSound"..count]
			local soundName

			local List = obj.List
			for name, path in ExRT.F.IterateMediaData("sound") do
				List[#List+1] = {
					text = name,
					arg1 = count,
					arg2 = path,
					func = dropDownGenSoundSetValue,
				}
				if soundVal == path then
					soundName = name
				end
			end
			sort(List,function(a,b) if a.prio == b.prio then return a.text < b.text else return (a.prio or 0) > (b.prio or 0) end end)
			tinsert(List,1,{
				text = "-",
				arg1 = count,
				func = dropDownGenSoundSetValue,
			})

			obj:SetText(soundName or soundVal or "-")
		end
	end

	if C_VoiceChat and C_VoiceChat.GetTtsVoices then
		self.voicesList = ELib:DropDown(self.options_tab.tabs[2],350,-1):AddText("|cffffd100"..L.ReminderTTSVoice..":"):Size(320):Point("TOPLEFT",self["dropDownSound"..count],"BOTTOMLEFT",0,-5)
		function self.voicesList:Update()
			local voices = C_VoiceChat.GetTtsVoices()
			local voiceID = VMRT.Reminder2.ttsVoice or TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Standard).voiceID
			for i=1,#voices do
				if voices[i].voiceID == voiceID then
					self:SetText(voices[i].name)
					return
				end
			end
			self:SetText("Voice ID "..(voiceID or "unk"))
		end

		function self.voicesList.func_SetValue(_,arg1)
			VMRT.Reminder2.ttsVoice = arg1
			self.voicesList:Update()
			ELib:DropDownClose()

			C_VoiceChat.SpeakText(
				arg1 or TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Standard).voiceID,
				TEXT_TO_SPEECH_SAMPLE_TEXT,
				Enum.VoiceTtsDestination.QueuedLocalPlayback,
				VMRT.Reminder2.ttsSpeechRate or C_TTSSettings.GetSpeechRate() or 0,
				VMRT.Reminder2.ttsVolume or C_TTSSettings.GetSpeechVolume() or 100
			)
		end
		function self.voicesList:PreUpdate()
			local List = self.List
			wipe(List)
			local voices = C_VoiceChat.GetTtsVoices()
			for i=1,#voices do
				List[#List+1] = {
					text = voices[i].name or "id "..i,
					arg1 = voices[i].voiceID,
					func = self.func_SetValue,
				}
			end
			List[#List+1] = {
				text = "WoW default",
				func = self.func_SetValue,
				tooltip = L.ReminderTTSVoiceDefTip,
			}
		end
		self.voicesList:Update()

		self.voicesList.playButton = ELib:Icon(self.voicesList,"Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128",20,true):Point("LEFT",'x',"RIGHT",5,0)
		self.voicesList.playButton.texture:SetTexCoord(0.375,0.4375,0.5,0.625)
		self.voicesList.playButton:SetScript("OnClick",function()
			C_VoiceChat.SpeakText(
				VMRT.Reminder2.ttsVoice or TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Standard).voiceID or 1,
				"This is an example of text to speech",
				Enum.VoiceTtsDestination.QueuedLocalPlayback,
				VMRT.Reminder2.ttsSpeechRate or C_TTSSettings.GetSpeechRate() or 0,
				VMRT.Reminder2.ttsVolume or C_TTSSettings.GetSpeechVolume() or 100
			)
		end)

		self.ttsSpeechRate = ELib:Slider(self.options_tab.tabs[2],""):Size(320):Point("TOPLEFT",self.voicesList,"BOTTOMLEFT",0,-15):Range(-10,10):SetTo(VMRT.Reminder2.ttsSpeechRate or 0):SetObey(true):OnChange(function(self,event) 
			event = floor(event + .5)
			VMRT.Reminder2.ttsSpeechRate = event
			self.tooltipText = event
			self:tooltipReload(self)
		end)
		ELib:Text(self.options_tab.tabs[2],L.ReminderTTSSpeechRate..":",11):Point("RIGHT",self.ttsSpeechRate,"LEFT",-5,0):Color(1,.82,0,1):Right()

		self.ttsVolume = ELib:Slider(self.options_tab.tabs[2],""):Size(320):Point("TOPLEFT",self.ttsSpeechRate,"BOTTOMLEFT",0,-15):Range(0,100):SetTo(VMRT.Reminder2.ttsVolume or 100):SetObey(true):OnChange(function(self,event) 
			event = floor(event + .5)
			VMRT.Reminder2.ttsVolume = event
			self.tooltipText = event.."%"
			self:tooltipReload(self)
		end)
		ELib:Text(self.options_tab.tabs[2],L.ReminderTTSVolume..":",11):Point("RIGHT",self.ttsVolume,"LEFT",-5,0):Color(1,.82,0,1):Right()
	end

	ELib:Text(self.options_tab.tabs[3],L.ReminderOptPlayersTooltip,11,"GameFontNormal"):Point("TOPLEFT",10,-10):Point("RIGHT",-10,0):Color()

	self.updatesPlayersList = ELib:ScrollTableList(self.options_tab.tabs[3],0,150,150,10):Point("TOP",0,-30):Size(678,500):OnShow(function(self)
		local L = self.L

		wipe(L)
		for player,opt in pairs(VMRT.Reminder2.SyncPlayers) do
			L[#L+1] = {player,opt == 1 and "|cff00ff00"..ALWAYS.." "..ACCEPT or "|cffff0000"..ALWAYS.." "..DECLINE,REMOVE}
		end
		sort(L,function(a,b) return a[1]<b[1] end)

		self:Update()
	end,true)

	self.updatesPlayersList.additionalLineFunctions = true
	function self.updatesPlayersList:ClickMultitableListValue(index,obj)
		if index == 3 then
			local i = obj:GetParent().index
			if i then
				VMRT.Reminder2.SyncPlayers[ module.options.updatesPlayersList.L[i][1] ] = nil
				tremove(module.options.updatesPlayersList.L,i)
				module.options.updatesPlayersList:Update()
			end
		end
	end

	self.quickStartButton = CreateFrame("Button",nil,self,"MainHelpPlateButton")
	self.quickStartButton:SetPoint("TOPLEFT",190,25)
	self.quickStartButton:SetScale(.8)
	self.quickStartButton:SetScript("OnClick",function()
		self.quickStartFrame:Show()
	end)
	self.quickStartButton.MainHelpPlateButtonTooltipText = L.ReminderQuickStartTooltip

	
	self.quickStartFrame = ELib:Popup(L.ReminderQuickStart):Size(750,750)
	
	self.quickStartFrame.img1 = self.quickStartFrame:CreateTexture()
	self.quickStartFrame.img1:SetPoint("TOPLEFT",10,-20)
	self.quickStartFrame.img1:SetTexture([[Interface\AddOns\MRT\media\remhelp]])
	self.quickStartFrame.img1:SetTexCoord(0/1024,94/1024,0/1024,23/1024)
	self.quickStartFrame.img1:SetSize(94-0,23-0)
	
	self.quickStartFrame.text1 = ELib:Text(self.quickStartFrame,L.ReminderQuickStart1,12):Point("TOPLEFT",self.quickStartFrame.img1,"TOPRIGHT",10,0):Point("RIGHT",self.quickStartFrame,-10,0):Color()
	
	self.quickStartFrame.img2 = self.quickStartFrame:CreateTexture()
	self.quickStartFrame.img2:SetPoint("TOPLEFT",self.quickStartFrame.img1,"BOTTOMLEFT",0,-10)
	self.quickStartFrame.img2:SetTexture([[Interface\AddOns\MRT\media\remhelp]])
	self.quickStartFrame.img2:SetTexCoord(97/1024,547/1024,0/1024,338/1024)
	self.quickStartFrame.img2:SetSize((547-97)*0.5,(338-0)*0.5)
	
	self.quickStartFrame.text2 = ELib:Text(self.quickStartFrame,L.ReminderQuickStart2,12):Point("TOPLEFT",self.quickStartFrame.img2,"TOPRIGHT",10,0):Point("RIGHT",self.quickStartFrame,-10,0):Color()
	
	self.quickStartFrame.img3 = self.quickStartFrame:CreateTexture()
	self.quickStartFrame.img3:SetPoint("TOPLEFT",self.quickStartFrame.img2,"BOTTOMLEFT",0,-10)
	self.quickStartFrame.img3:SetTexture([[Interface\AddOns\MRT\media\remhelp]])
	self.quickStartFrame.img3:SetTexCoord(553/1024,1000/1024,0/1024,216/1024)
	self.quickStartFrame.img3:SetSize((1000-553)*0.5,(216-0)*0.5)
	
	self.quickStartFrame.text3 = ELib:Text(self.quickStartFrame,L.ReminderQuickStart3,12):Point("TOPLEFT",self.quickStartFrame.img3,"TOPRIGHT",10,0):Point("RIGHT",self.quickStartFrame,-10,0):Color()
	
	self.quickStartFrame.img4 = self.quickStartFrame:CreateTexture()
	self.quickStartFrame.img4:SetPoint("TOPLEFT",self.quickStartFrame.img3,"BOTTOMLEFT",0,-10)
	self.quickStartFrame.img4:SetTexture([[Interface\AddOns\MRT\media\remhelp]])
	self.quickStartFrame.img4:SetTexCoord(553/1024,1000/1024,220/1024,727/1024)
	self.quickStartFrame.img4:SetSize((1000-553)*0.5,(727-220)*0.5)
	
	self.quickStartFrame.text4 = ELib:Text(self.quickStartFrame,L.ReminderQuickStart4,12):Point("TOPLEFT",self.quickStartFrame.img4,"TOPRIGHT",10,0):Point("RIGHT",self.quickStartFrame,-10,0):Color()
	
	self.quickStartFrame.img5 = self.quickStartFrame:CreateTexture()
	self.quickStartFrame.img5:SetPoint("TOPLEFT",self.quickStartFrame.img4,"BOTTOMLEFT",0,-10)
	self.quickStartFrame.img5:SetTexture([[Interface\AddOns\MRT\media\remhelp]])
	self.quickStartFrame.img5:SetTexCoord(3/1024,91/1024,28/1024,49/1024)
	self.quickStartFrame.img5:SetSize(91-3,49-28)
	
	self.quickStartFrame.text5 = ELib:Text(self.quickStartFrame,L.ReminderQuickStart5,12):Point("TOPLEFT",self.quickStartFrame.img5,"TOPRIGHT",10,0):Point("RIGHT",self.quickStartFrame,-10,0):Color()


	self:UpdateData()
end

function module:Enable()
	module.IsEnabled = true

	module:RegisterEvents('ENCOUNTER_START','ENCOUNTER_END','ZONE_CHANGED_NEW_AREA')

	module:ResetPrevZone()
	module:LoadForCurrentZone()

	if module.db.debug then
		module:RegisterTimer()
	end

	C_Timer.After(3,function()
		if IsEncounterInProgress() and not module.db.encounterID and IsInRaid() then
			module.db.requestEncounterID = GetTime()
			local zoneID = select(8,GetInstanceInfo())
			ExRT.F.SendExMsg("rmd", "S\tE\tR\t"..(zoneID or 0))
		end
	end)
end

function module:Disable()
	module.IsEnabled = false

	module:UnregisterEvents('ENCOUNTER_START','ENCOUNTER_END','ZONE_CHANGED_NEW_AREA')

	module:UnregisterTimer()
	module:UnloadAll()
end

function module:timer(elapsed)
	local triggers = module.db.eventsToTriggers.PLAYERS_IN_RANGE
	if triggers then
		module:TriggerUnitsInRange(triggers)
	end
	local triggers = module.db.eventsToTriggers.MOBS_IN_RANGE
	if triggers then
		module:TriggerMobsInRange(triggers)
	end
end
do
	local debugText

	local function NewTicker()
		local res = ""
		local c = 0
		for i=1,#reminders do
			local reminder = reminders[i]
			if reminder.data.debug then
				c = c + 1
				res = res .. c ..". " .. (reminder.data.name or reminder.data.msg or "~no name") .. ": " 
				for j=1,#reminder.triggers do
					local trigger = reminder.triggers[j]

					local sc = 0
					if trigger.active then
						for _ in pairs(trigger.active) do
							sc = sc + 1
						end
					end

					res = res .. j.."-".. (trigger.status and "on" or "off") .. (sc > 0 and "("..sc..")" or "") .. " "
				end
				res = res .. "\n" 

				module.db.debugDB[c] = reminder
			end
		end
		for i=c+1,#module.db.debugDB do
			module.db.debugDB[i] = nil
		end
		debugText:SetText(res)	  
	end

	local oldTimer
	local debugTicker
	local IsTimerFuncUpdated
	local oldUnreg
	local function UpdateTimerFunc()
		if IsTimerFuncUpdated then
			return
		end
		IsTimerFuncUpdated = true
		oldTimer = module.timer
		oldUnreg = module.UnregisterTimer
		module.timer = function(...)
			oldTimer(...)
			if debugTicker then
				debugTicker(...)
			end
		end
	end

	function module:ToggleDebugMode()
		module.db.debug = not module.db.debug
		if module.db.debug then
			module.db.debugLog = true
			if module.options.setupFrame.debugCheck then
				module.options.setupFrame.debugCheck:Show()
			end
			if not debugText then
				debugText = ELib:Text(UIParent):Point("TOPLEFT",2,-2):Color()
			end
			debugTicker = NewTicker
			UpdateTimerFunc()
			module:RegisterTimer()
			module.UnregisterTimer = function() end
			print("Debug mode on")
		else
			module.db.debugLog = false
			if module.options.setupFrame.debugCheck then
				module.options.setupFrame.debugCheck:Hide()
			end
			module.UnregisterTimer = oldUnreg
			module:UnregisterTimer()
			debugTicker = nil
			if debugText then
				debugText:SetText("")
			end
			print("Debug mode off")
		end
	end
end

function module:DebugLogAdd(...)
	local text = ""
	for i=1,select("#",...) do
		text = text .. " " .. tostring( select(i,...), nil)
	end
	local encounterTime = ExRT.F.GetEncounterTime()
	module.db.debugLogDB[#module.db.debugLogDB+1] = date("%X",time()) .. "." .. format("%03d",(GetTime() % 1) * 1000) .. (encounterTime and format(" %d:%02d",encounterTime/60,encounterTime%60) or "") .. text
end

function module:CheckUnit(unitVal,unitguid,trigger)
	if not unitguid then
		return false
	elseif type(unitVal) == "string" then
		return UnitGUID(unitVal) == unitguid
	elseif type(unitVal) == "number" then
		if unitVal < 0 then
			local triggerDest = trigger and trigger._reminder.triggers[-unitVal]
			if triggerDest then
				for uid,data in pairs(triggerDest.active) do
					if data.guid == unitguid then
						return true
					end
				end
			end
		else
			local list = module.datas.unitsList[unitVal]
			for i=1,#list do
				local guid = UnitGUID(list[i])
				if guid == unitguid then
					return true
				end
			end
		end
	end
end

function module:CheckNumber(checkFuncs,num)
	for k,v in pairs(checkFuncs) do
		if v(num) then
			return true
		end
	end
end

function module:GetReminderType(remType)
	if remType == 4 or remType == 5 or remType == 8 or remType == 11 then
		return REM.TYPE_CHAT
	elseif remType == 6 or remType == 7 then
		return REM.TYPE_NAMEPLATE
	elseif remType == 9 then
		return REM.TYPE_RAIDFRAME
	elseif remType == 10 then
		return REM.TYPE_WA
	elseif remType == 12 or remType == 13 or remType == 14 then
		return REM.TYPE_BAR
	else
		return REM.TYPE_TEXT
	end
end



function module:CheckAllTriggers(trigger)
	local data, reminder = trigger._data, trigger._reminder
	local check = reminder.activeFunc(reminder.triggers)

	--if module.db.debug and data.debug then
	if module.db.debug then
		--for i=1,#reminder.triggers do
		--	print(GetTime(),data.msg,i,reminder.triggers[i].status,trigger.count)
		--end
		print('CheckAllTriggers',GetTime(),data.name or data.msg,"Check: "..tostring(check))
	end
	if module.db.debugLog then module:DebugLogAdd("CheckAllTriggers",data.name or data.msg,data.uid,check) end

	if not check then
		for i,t in pairs(reminder.triggers) do
			if t ~= trigger and t._trigger.cbehavior == 4 and not reminder.activeFunc2(reminder.triggers,i) then
				t.count = 0
			end
		end
	end

	local remType = module:GetReminderType(data.msgSize)
	if check then
		--if (data.copy or (remType == REM.TYPE_NAMEPLATE or remType == REM.TYPE_RAIDFRAME)) and data.sametargets then
		if data.sametargets then
			local guid = type(trigger.status) == "table" and trigger.status.guid
			if guid then
				local allguidsaresame = true
				for _,t in ipairs(reminder.triggers) do
					local foundAny, foundSame
					for _,s in pairs(t.active) do
						foundAny = true
						if s.guid and s.guid == guid then
							t.status = s
							foundSame = true
							break
						elseif not s.guid then
							foundSame = true
							break
						end
					end
					if foundAny and not foundSame then
						allguidsaresame = false
						break
					end
				end
				if allguidsaresame then
					module:ShowReminder(trigger)
				end
			end

		-- Duplicate show event for nameplate/frames highlights type reminder
		elseif (remType == REM.TYPE_NAMEPLATE or remType == REM.TYPE_RAIDFRAME) then
			local triggerNumToCheck = 1
			if data.specialTarget then
				local sourcedest,triggerNum = data.specialTarget:match("^%%([^%d]+)(%d+)")
				if (sourcedest == "source" or sourcedest == "target") and triggerNum then
					triggerNumToCheck = tonumber(triggerNum)
				end
			else
				for i,t in ipairs(reminder.triggers) do
					if type(t.status) == "table" and t.status.guid then
						triggerNumToCheck = i
						break
					end
				end
			end
			local triggerToCheck = reminder.triggers[triggerNumToCheck]
			if triggerToCheck then
				for _,s in pairs(triggerToCheck.active) do
					triggerToCheck.status = s
					module:ShowReminder(trigger)
				end
			end
		else
			module:ShowReminder(trigger)
		end
	end

	--hide all copies for reminders without duration
	if data.dur == 0 and not check then
		for j=#module.db.showedReminders,1,-1 do
			local showed = module.db.showedReminders[j]
			if showed.data == data then
				if showed.voice then
					showed.voice:Cancel()
				end
				tremove(module.db.showedReminders,j)
			end
		end
		if remType == REM.TYPE_NAMEPLATE then
			if reminder.nameplateguid then
				module:NameplateRemoveHighlight(reminder.nameplateguid)
				reminder.nameplateguid = nil
			end
			for guid,list in pairs(module.db.nameplateHL) do
				for uid,t in pairs(list) do
					if t.data == data then
						module:NameplateRemoveHighlight(guid, uid)
					end
				end
			end
		elseif remType == REM.TYPE_RAIDFRAME then
			if reminder.frameguid then
				module:FrameRemoveHighlight(reminder.frameguid)
				reminder.frameguid = nil
			end
			for guid,list in pairs(module.db.frameHL) do
				for uid,t in pairs(list) do
					if t.data == data then
						module:FrameRemoveHighlight(guid, uid)
					end
				end
			end
		elseif remType == REM.TYPE_CHAT then
			if reminder.textRepTmr then
				reminder.textRepTmr:Cancel()
				reminder.textRepTmr = nil
			end
		end
	end
end


function module:CheckUnitTriggerStatus(trigger)
	for guid in pairs(trigger.statuses) do
		if UnitGUID(trigger.units[guid]) ~= guid then
			trigger.statuses[guid] = nil
			trigger.units[guid] = nil
			module:DeactivateTrigger(trigger, guid)
		end
	end
end

function module:CheckUnitTriggerStatusOnDeactivating(trigger)
	for guid in pairs(trigger.statuses) do
		if UnitGUID(trigger.units[guid]) ~= guid then
			trigger.statuses[guid] = nil
			trigger.units[guid] = nil
			if not trigger.ignoreManualOff then
				trigger.active[guid] = nil
			end
		end
	end
end

function module:DeactivateTrigger(trigger, uid, isScheduled)
	if trigger.delays and #trigger.delays > 0 then
		for j=#trigger.delays,1,-1 do
			local delayTimer = trigger.delays[j]
			if not uid or delayTimer.args[3].uid == uid or delayTimer.args[3].guid == uid then
				delayTimer:Cancel()
				tremove(trigger.delays, j)
			end
		end
	end

	if not trigger.active[uid or 1] then
		return
	end
	if trigger.ignoreManualOff and not isScheduled then
		return
	end
	if module.db.debugLog then module:DebugLogAdd("DeactivateTrigger",trigger._data.name or trigger._data.msg,uid) end

	trigger.active[uid or 1] = nil

	if trigger.untimed and trigger.units then	--??? double recheck for units
		module:CheckUnitTriggerStatusOnDeactivating(trigger)
	end

	local status = false
	for _ in pairs(trigger.active) do
		status = true
		break
	end
	if not status then
		trigger.status = false
		module:CheckAllTriggers(trigger)
	elseif uid and trigger._data.dur == 0 and (trigger._data.copy or (module:GetReminderType(trigger._data.msgSize) == REM.TYPE_NAMEPLATE or module:GetReminderType(trigger._data.msgSize) == REM.TYPE_RAIDFRAME)) then
		for j=#module.db.showedReminders,1,-1 do
			local showed = module.db.showedReminders[j]
			if showed.data == trigger._data and showed.params and (showed.params.uid == uid or showed.params.guid == uid) then
				if showed.voice then
					showed.voice:Cancel()
				end
				tremove(module.db.showedReminders,j)
			end
		end
		if module:GetReminderType(trigger._data.msgSize) == REM.TYPE_NAMEPLATE then
			module:NameplateRemoveHighlight(uid, trigger._data.uid)
		elseif module:GetReminderType(trigger._data.msgSize) == REM.TYPE_RAIDFRAME then
			module:FrameRemoveHighlight(uid, trigger._data.uid)
		end
	end
end

do
	local indexNow = 1
	function module:ActivateTrigger(trigger, vars)
		vars = vars or {}
		if (vars.uid or vars.guid) and trigger.active[vars.uid or vars.guid] then
			return
		end
		if module.db.debugLog then module:DebugLogAdd("ActivateTrigger",trigger._data.name or trigger._data.msg,vars.uid or vars.guid) end
	
		trigger.status = vars
	
		trigger.active[vars.uid or vars.guid or 1] = vars

		vars.aindex = indexNow
		indexNow = indexNow + 1
	
		vars.atime = GetTime()
		vars.timeLeftB = vars.atime + (trigger._trigger.activeTime or 0)

		if trigger.untimed and trigger.units then	--??? double recheck for units
			module:CheckUnitTriggerStatus(trigger)
		end
		module:CheckAllTriggers(trigger)
	
		if trigger._trigger.activeTime then
			module.db.timers[#module.db.timers+1] = ScheduleTimer(module.DeactivateTrigger, max(trigger._trigger.activeTime, 0.01), 0, trigger, vars.uid or vars.guid or 1, true)
		elseif not trigger.untimed then
			module:DeactivateTrigger(trigger, vars.uid or vars.guid or 1)
		end
	end
end

function module:RunTrigger(trigger, vars)
	local triggerData = trigger._trigger
	if trigger.DdelayTime then
		for i=1,#trigger.DdelayTime do
			local t = ScheduleTimer(module.ActivateTrigger, trigger.DdelayTime[i], 0, trigger, vars)
			module.db.timers[#module.db.timers+1] = t
			if trigger.delays then
				trigger.delays[#trigger.delays+1] = t
			end
		end
	else
		module:ActivateTrigger(trigger, vars)
	end
end

do
	local valsExtra = {
		["sourceMark"] = function(m) return ExRT.F.GetRaidTargetText(m,0) end,
		["targetMark"] = function(m) return ExRT.F.GetRaidTargetText(m,0) end,
		["sourceMarkNum"] = function(_,t) return t.sourceMark or 0 end,
		["targetMarkNum"] = function(_,t) return t.targetMark or 0 end,		
		["health"] = function(_,t) 
			return function(accuracy,...) 
				if accuracy then
					local a,b = accuracy:match("^(%d+)(.-)$")
					return format("%."..(a or "1").."f",t.health)..(b or "")..strjoin(":",...), true
				else
					return format("%.1f",t.health) 
				end
			end 
		end,
		["value"] = function(_,t) return function() return t.value and format("%d",t.value) or "" end end,
		["auraValA"] = function(_,t) return function() return t._auraData and (t._auraData.points and t._auraData.points[1] or t._auraData[8]) or "" end end,
		["auraValB"] = function(_,t) return function() return t._auraData and (t._auraData.points and t._auraData.points[2] or t._auraData[9]) or "" end end,
		["auraValC"] = function(_,t) return function() return t._auraData and (t._auraData.points and t._auraData.points[3] or t._auraData[10]) or "" end end,
		["textModIcon"] = function(_,t) 
			return function(iconSize,repeatNum,otherStr)
				if not iconSize or not repeatNum then
					return t.text or ""
				end
				local isPass = not otherStr
				local t = t.text or ""
				if not isPass then
					local c = 1
					local tf = select(c,strsplit(";",otherStr))
					while tf do
						if t:find(tf) then
							isPass = true
							break
						end
						c = c + 1
						tf = select(c,strsplit(";",otherStr))
					end
				end
				if isPass then
					repeatNum = tonumber(repeatNum)
					t = t:gsub("{spell:(%d+):?(%d*)}",("{spell:%1:"..iconSize.."}"):rep(repeatNum))
					return t
				else
					return t
				end
			end 
		end,
		["text"] = function(v,_,t) 
			if t and t._trigger.event == 19 then
				if v and v:find("^{spell:[^}]+}$") then
					return v:rep(3)
				else
					return v
				end
			else
				return v
			end
		end,
	}
	local valsAdditional = {
		{"sourceMarkNum","sourceMark"},
		{"targetMarkNum","targetMark"},
		{"textModIcon","text"},
		{"auraValA","_auraData"},
		{"auraValB","_auraData"},
		{"auraValC","_auraData"},
	}
	local valsAdditionalFull = {
	}
	local function CancelSoundTimers(self)
		for i=1,#self do
			self[i]:Cancel()
		end
	end
	function module:ShowReminder(trigger)
		local data, reminder = trigger._data, trigger._reminder
		if module.db.debug then print('ShowReminder',data.name,date("%X",time())) end
		if module.db.debugLog then module:DebugLogAdd("ShowReminder",trigger._data.name or trigger._data.msg) end

		local params = {_data = data,_reminder = reminder,_trigger = trigger,_status = trigger.status}
		for j=1,#reminder.triggers do
			local trigger = reminder.triggers[j]
			if trigger.status then
				for k,v in pairs(trigger.status) do
					if valsExtra[k] then
						v = valsExtra[k](v,trigger.status,trigger)
					end
					params[k..j] = v
					if not params[k] then
						params[k] = v
					end
				end
				for _,k in pairs(valsAdditional) do
					if type(k)~="table" or trigger.status[ k[2] ] then
						k = type(k) == "table" and k[1] or k
						local v = valsExtra[k](nil,trigger.status,trigger)
						params[k..j] = v
						if not params[k] then
							params[k] = v
						end
					end
				end
			else
				if trigger.count then
					params["counter"..j] = trigger.count
				end
			end
			for _,k in pairs(valsAdditionalFull) do
				local v = valsExtra[k](nil,trigger.status,trigger)
				params[k..j] = v
				if not params[k] then
					params[k] = v
				end
			end
		end

		if data.specialTarget then
			local guid
			local sourcedest,triggerNum = data.specialTarget:match("^%%([^%d]+)(%d+)")
			if (sourcedest == "source" or sourcedest == "target") and triggerNum then
				guid = params[(sourcedest == "source" and "sourceGUID" or "targetGUID")..triggerNum]
			else
				guid = UnitGUID(data.specialTarget)
				if not guid then
					local fmt = module:FormatMsg(data.specialTarget,params)
					if fmt and type(fmt)=="string" then
						if fmt:find("[;,]") then
							for c in string_gmatch(fmt, "[^;,]+") do
								guid = (c:find("^guid:") and c:sub(6,100)) or (#c<=100 and UnitGUID(c))
								if guid then
									break
								end
							end
						else
							guid = (fmt:find("^guid:") and fmt:sub(6,100)) or (#fmt<=100 and UnitGUID(fmt))
						end
					end
				end
			end
			if guid then
				params.guid = guid
			end
		end
		--if module.db.debug and data.debug then
		--	print("Activate unit",params.guid)
		--end

		if data.extraCheck then
			local isPass,isValid = module:ExtraCheckParams(data.extraCheck,params)
			if isValid and not isPass then
				return
			end
		end

		if reminder.delayedActivation then
			for i=1,#reminder.delayedActivation do
				local t = ScheduleTimer(module.ShowReminderVisual, reminder.delayedActivation[i], self, trigger, data, reminder, params)
				module.db.timers[#module.db.timers+1] = t
			end
		else
			module:ShowReminderVisual(trigger,data,reminder,params)
		end
	end

	function module:ShowReminderVisual(trigger,data,reminder,params)
		local remType = module:GetReminderType(data.msgSize)

		--hide all showed copies
		if not data.copy then
			for j=#module.db.showedReminders,1,-1 do
				local showed = module.db.showedReminders[j]
				if showed.data == data then
					if data.norewrite then
						return
					end
					if showed.voice then
						showed.voice:Cancel()
					end
					tremove(module.db.showedReminders,j)
				end
			end
			if remType == REM.TYPE_BAR then
				if data.norewrite and frameBars:GetBarByID(data.uid) then
					return
				end
				frameBars:StopBar(data.uid)
			end
		end

		local reminderDuration = trigger.status and trigger.status._customDuration or data.dur or 2

		--stop duplicates for untimed text reminders
		if data.copy and reminderDuration == 0 then
			for j=#module.db.showedReminders,1,-1 do
				local showed = module.db.showedReminders[j]
				if showed.data == data and ((params.guid and showed.params and showed.params.guid == params.guid) or (params.uid and showed.params and showed.params.uid == params.uid)) then
					return
				end
			end
		end

		local now = GetTime()

		reminder.params = params
		if remType == REM.TYPE_CHAT then
			local msg, msgUpdateReq = module:FormatMsg(data.msg or "",params,true)
			msg = module:FormatMsgForChat(msg)
			local channelName = data.msgSize == 4 and "SAY" or data.msgSize == 8 and (IsInRaid() and "RAID" or "PARTY") or "YELL"
			local _SendChatMessage = SendChatMessage
			if (channelName == "SAY" or channelName == "YELL") and select(2,GetInstanceInfo()) == "none" then
				_SendChatMessage = ExRT.NULLfunc
			end
			if data.msgSize == 11 then
				_SendChatMessage = function(msg) print(msg) end
			end
			if data.countdown then
				local function printf(c)
					local newmsg = msgUpdateReq and module:FormatMsgForChat(module:FormatMsg(data.msg or "",params,true)) or msg
					_SendChatMessage(newmsg.." "..c, channelName)
				end
				local step = data.countdownType == 3 and 0.5 or data.countdownType == 1 and 2 or 1
				for i=1,reminderDuration,step do
					module.db.timers[#module.db.timers+1] = ScheduleTimer(printf, max(i-1,0.01), floor(reminderDuration-(i-1)))
				end
			else
				_SendChatMessage(msg, channelName)
				if reminderDuration <= 0 then
					if reminder.textRepTmr then
						reminder.textRepTmr:Cancel()
					end
					local repTime = 1
					if reminderDuration < 0 then
						repTime = -reminderDuration
					end
					local t
					t = ScheduleTimer(function()
						if not reminder.activeFunc(reminder.triggers) then
							t:Cancel()
							return
						end
						local newmsg = msgUpdateReq and module:FormatMsgForChat(module:FormatMsg(data.msg or "",params,true)) or msg
						_SendChatMessage(newmsg, channelName)
					end, -repTime)
					reminder.textRepTmr = t
					module.db.timers[#module.db.timers+1] = t
				end
			end
		elseif remType == REM.TYPE_NAMEPLATE then
			if params.guid then
				if reminder.nameplateguid then
					module:NameplateRemoveHighlight(reminder.nameplateguid)
				end
				local frame = module:NameplateAddHighlight(params.guid,data,params)
				if not data.copy then
				--	reminder.nameplateguid = params.guid
				end
				if reminderDuration ~= 0 then
					module.db.timers[#module.db.timers+1] = ScheduleTimer(module.NameplateRemoveHighlight, reminderDuration, module, params.guid, data.uid)
				end
			end
		elseif remType == REM.TYPE_RAIDFRAME then
			if params.guid then
				if reminder.frameguid then
					module:FrameRemoveHighlight(reminder.frameguid)
				end
				local frame = module:FrameAddHighlight(params.guid,data,params)
				if not data.copy then
				--	reminder.frameguid = params.guid
				end
				if reminderDuration ~= 0 then
					module.db.timers[#module.db.timers+1] = ScheduleTimer(module.FrameRemoveHighlight, reminderDuration, module, params.guid, data.uid)
				end
			end
		elseif remType == REM.TYPE_WA then
			if type(WeakAuras)=="table" and type(WeakAuras.ScanEvents)=="function" then
				WeakAuras.ScanEvents("MRT_REMINDER_EVENT", module:FormatMsg(data.msg or "",params), data.name, params)
			end
		elseif remType == REM.TYPE_BAR then
			local checkFunc, progressFunc
			if reminderDuration == 0 then
				if trigger.status and trigger.status.timeLeft then
					reminderDuration = trigger.status.timeLeft - now
					checkFunc = function() return trigger.status end
				elseif trigger.status and trigger.status.health then
					reminderDuration = 100
					checkFunc = function() return trigger.status end
					progressFunc = function() return trigger.status.health / 100,trigger.status.value end
				end
			end
			if reminderDuration > 0 then
				local id = data.uid
				if data.copy and not checkFunc then
					id = id .. tostring({})
				elseif data.copy then
					id = id .. (trigger.status and (trigger.status.uid or trigger.status.guid or 1) or tostring({}))
				end
				local msg, updateReq = module:FormatMsg(data.msg or "",params)
				if updateReq and not data.dynamicdisable then
					msg = {data.msg or "",params,msg}
				end
				local color
				if data.glowColor then
					local a,r,g,b = data.glowColor:match("(..)(..)(..)(..)")
					if r and g and b and a then
						a,r,g,b = tonumber(a,16),tonumber(r,16),tonumber(g,16),tonumber(b,16)
						color = {r/255,g/255,b/255,a/255}
					end
				end
				local countdownFormat = module.datas.countdownType[data.countdownType or 2][3]
				local voice = data.countdownVoice
				if progressFunc then
					voice = nil
				end
				local ticks = data.customOpt1
				if ticks then
					ticks = module:ConvertMinuteStrToNum(ticks)
				end
				local icon = type(data.glowImage) == "string" and data.glowImage or module.datas.glowImagesData[data.glowImage or 0]
				if icon and tonumber(icon) == 0 and trigger.status and trigger.status.spellID then
					icon = select(3,GetSpellInfo(trigger.status.spellID))
				end

				local barSize = data.msgSize == 13 and 0.5 or data.msgSize == 14 and 1.5 or 1

				frameBars:StartBar(id,reminderDuration,msg,barSize,color,countdownFormat,voice,ticks,icon,checkFunc,progressFunc)
			end
		else
			local t = {
				data = data,
				expirationTime = now + (reminderDuration == 0 and 86400 or reminderDuration or 2),
				params = params,
				dur = reminderDuration,
			}
			module.db.showedReminders[#module.db.showedReminders+1] = t
			if data.countdownVoice and reminderDuration ~= 0 and reminderDuration >= 1.3 then
				local clist = {Cancel = CancelSoundTimers}
				local soundTemplate = module.datas.vcdsounds[ data.countdownVoice ]
				if soundTemplate then
					for i=1,min(5,reminderDuration-0.3) do
						local sound = soundTemplate .. i .. ".ogg"
						local tmr = ScheduleTimer(PlaySoundFile, reminderDuration-(i+0.3), sound, "Master")
						module.db.timers[#module.db.timers+1] = tmr
						clist[#clist+1] = tmr
					end
					t.voice = clist
				end
			end
			frame:Show()
		end

		if data.sound and not VMRT.Reminder2.disableSound and bit.band(VMRT.Reminder2.options[data.uid or 0] or 0,bit.lshift(1,1)) == 0 then
			module:PlaySound(data.sound, reminder, now)
		end
	end
end

do
	local generalSounds = {}
	for k,v in pairs(module.datas.sounds) do
		if type(v[1])=='string' and tonumber(v[1]) then
			generalSounds[ v[1] ] = "generalSound"..v[1]
		end
	end
	local function FormatMsgForSound(msg)
		msg = msg:gsub("[<>]","")
		return msg
	end
	function module:PlaySound(sound, reminder, now)
		local soundLast = reminder and reminder.soundTime
		local now = now or GetTime()
		if not soundLast or now - soundLast > 0.1 then
			if generalSounds[sound] then
				sound = VMRT.Reminder2[ generalSounds[sound] ]
			elseif tonumber(sound) then
				sound = tonumber(sound)
			end
			if sound == "TTS" then
				if C_VoiceChat and C_VoiceChat.SpeakText and reminder then
					local msg = module:FormatMsgForChat( module:FormatMsg(reminder.data.msg or "",reminder.params) )
					C_Timer.After(0.01,function()	--Try to fix lag
						--C_VoiceChat.StopSpeakingText()
						C_VoiceChat.SpeakText(
							--VMRT.Reminder2.ttsVoice or TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Standard).voiceID or 1, 
							VMRT.Reminder2.ttsVoice or 1, 
							FormatMsgForSound( msg ), 
							Enum.VoiceTtsDestination.QueuedLocalPlayback, 
							VMRT.Reminder2.ttsSpeechRate or C_TTSSettings.GetSpeechRate() or 0, 
							VMRT.Reminder2.ttsVolume or C_TTSSettings.GetSpeechVolume() or 100
						)
					end)
				end
			else
				pcall(PlaySoundFile, sound, "Master")
			end
			if reminder then
				reminder.soundTime = now
			end
		end
	end
end

do
	local tmr = 0
	local showedReminders = module.db.showedReminders
	frame:SetScript("OnUpdate",function(self,elapsed)
		tmr = tmr + elapsed
		if tmr > 0.03 then
			tmr = 0

			if self.unlocked then	--test mode active
				return
			end

			local textBig,text,textSmall
			local now = GetTime()
			for j=#showedReminders,1,-1 do
				local showed = showedReminders[j]
				local data,t,params = showed.data, showed.expirationTime, showed.params
				if now <= t then
					local msg, updateReq = showed.msg
					if not msg then
						msg, updateReq = module:FormatMsg(data.msg or "",params)
						if not updateReq or data.dynamicdisable then
							showed.msg = msg
						end
					end
					local countdownFormat = showed.countdownFormat
					if not countdownFormat then
						countdownFormat = module.datas.countdownType[data.countdownType or 2][3]
						showed.countdownFormat = countdownFormat
					end
					if data.msgSize == 2 then
						textBig = msg .. (showed.dur ~= 0 and data.countdown and format(countdownFormat,t - now) or "") .. (textBig and "\n" or "") .. (textBig or "")
					elseif data.msgSize == 3 then
						textSmall = msg .. (showed.dur ~= 0 and data.countdown and format(countdownFormat,t - now) or "") .. (textSmall and "\n" or "") .. (textSmall or "")
					else
						text = msg .. (showed.dur ~= 0 and data.countdown and format(countdownFormat,t - now) or "") .. (text and "\n" or "") .. (text or "")
					end
				else
					if showed.voice then
						showed.voice:Cancel()
					end
					tremove(showedReminders,j)
				end
			end

			if textBig ~= self.textBig.prev then
				self.textBig:SetText(textBig or "")
				self.textBig.prev = textBig
			end
			if text ~= self.text.prev then
				self.text:SetText(text or "")
				self.text.prev = text
			end
			if textSmall ~= self.textSmall.prev then
				self.textSmall:SetText(textSmall or "")
				self.textSmall.prev = textSmall
			end
			if not textBig and not text and not textSmall then
				self:Hide()
			end
		end
	end)
end

do
	local function ResetCounter(trigger)
		trigger.count = 0
	end
	function module:AddTriggerCounter(trigger,behav1,behav2)
		if trigger._trigger.cbehavior == 1 and behav1 then
			trigger.count = behav1
		elseif trigger._trigger.cbehavior == 2 and behav2 then
			trigger.count = behav2
		elseif trigger._trigger.cbehavior == 3 or trigger._trigger.cbehavior == 4 then
			if trigger._reminder.activeFunc2(trigger._reminder.triggers,trigger._i) then
				trigger.count = trigger.count + 1
			end
		elseif trigger._trigger.cbehavior == 5 then
			trigger.count = (trigger._reminder.globalcounter or 0) + 1
			trigger._reminder.globalcounter = trigger.count
		else
			trigger.count = trigger.count + 1
	
			if trigger._trigger.cbehavior == 6 then
				module.db.timers[#module.db.timers+1] = ScheduleTimer(ResetCounter, 5, trigger)
			end
		end
	end
end

do
	local UIDNow = 1
	function module:GetNextUID()
		UIDNow = UIDNow + 1
		return UIDNow
	end
end


local CLEUIsHistoryEvent = {
	["SPELL_CAST_SUCCESS"] = true,
	["SPELL_CAST_START"] = true,
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REMOVED"] = true,
}
function module.main.COMBAT_LOG_EVENT_UNFILTERED(timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,school,arg1,arg2)
	local triggers = tCOMBAT_LOG_EVENT_UNFILTERED[event]
	if triggers then
		for i=1,#triggers do
			local trigger = triggers[i]
			local triggerData = trigger._trigger
			if 
				(not triggerData.spellID or triggerData.spellID == spellID) and
				(not triggerData.spellName or triggerData.spellName == spellName) and
				(not trigger.DsourceName or sourceName and trigger.DsourceName[sourceName]) and
				(not trigger.DsourceID or trigger.DsourceID(sourceGUID)) and
				(not triggerData.sourceMark or module.datas.markToIndex[sourceFlags2] == triggerData.sourceMark) and
				(not triggerData.sourceUnit or module:CheckUnit(triggerData.sourceUnit,sourceGUID,trigger)) and
				(not trigger.DtargetName or destName and trigger.DtargetName[destName]) and
				(not trigger.DtargetID or trigger.DtargetID(destGUID)) and
				(not triggerData.targetMark or module.datas.markToIndex[destFlags2] == triggerData.targetMark) and
				(not triggerData.targetUnit or module:CheckUnit(triggerData.targetUnit,destGUID,trigger)) and
				(not triggerData.extraSpellID or triggerData.extraSpellID == arg1) and
				(not trigger.Dstacks or module:CheckNumber(trigger.Dstacks,(event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE") and arg2 or 1)) and
				(not triggerData.pattFind or triggerData.pattFind == arg1) and
				(not triggerData.targetRole or destName and module:CmpUnitRole(destName,triggerData.targetRole))
			then
				trigger.countsS[sourceGUID] = (trigger.countsS[sourceGUID] or 0) + 1
				trigger.countsD[destGUID] = (trigger.countsD[destGUID] or 0) + 1
				module:AddTriggerCounter(trigger,trigger.countsS[sourceGUID],trigger.countsD[destGUID])
				if 
					(not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count)) and
					(not triggerData.onlyPlayer or destGUID == UnitGUID("player"))
				then
					local vars = {
						sourceName = sourceName,
						sourceMark = module.datas.markToIndex[sourceFlags2],
						targetName = destName,
						targetMark = module.datas.markToIndex[destFlags2],
						spellName = spellName,
						spellID = spellID,
						extraSpellID = arg1,
						stacks = (event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE") and arg2 or 1,
						counter = trigger.count,
						guid = triggerData.guidunit == 1 and sourceGUID or destGUID,
						sourceGUID = sourceGUID,
						targetGUID = destGUID,
						uid = module:GetNextUID(),
					}
					module:RunTrigger(trigger, vars)
				end
			end
		end
	end

	if IsHistoryEnabled and CLEUIsHistoryEvent[event] and bit_band(sourceFlags,0x000000F0) ~= 0x00000010 then
		module:AddHistoryRecord(1,event,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID)
	end
end

function module:TriggerHPLookup(unit,triggers,hp,hpValue)
	local guid = UnitGUID(unit)
	local name = UnitName(unit)
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger
		if 
			(not trigger.DtargetName or name and trigger.DtargetName[name]) and
			(not trigger.DtargetID or trigger.DtargetID(guid)) and
			(type(triggerData.targetUnit) ~= "number" or triggerData.targetUnit >= 0 or module:CheckUnit(triggerData.targetUnit,guid,trigger))
		then
			local hpCheck = 
				(not triggerData.targetMark or (GetRaidTargetIndex(unit) or 0) == triggerData.targetMark) and
				trigger.DnumberPercent and module:CheckNumber(trigger.DnumberPercent,hp)

			if not trigger.statuses[guid] and hpCheck then
				trigger.countsD[guid] = (trigger.countsD[guid] or 0) + 1
				module:AddTriggerCounter(trigger,nil,trigger.countsD[guid])
				local vars = {
					targetName = UnitName(unit),
					targetMark = GetRaidTargetIndex(unit),
					guid = guid,
					counter = trigger.count,
					health = hp,
					value = hpValue,
				}
				trigger.statuses[guid] = vars
				trigger.units[guid] = unit
				if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
					module:RunTrigger(trigger, vars)
				end
			elseif trigger.statuses[guid] and not hpCheck then
				trigger.statuses[guid] = nil
				trigger.units[guid] = nil

				module:DeactivateTrigger(trigger,guid)
			end

			if trigger.statuses[guid] then
				trigger.statuses[guid].health = hp
				trigger.statuses[guid].value = hpValue
			end
		end
	end
end

function module.main:UNIT_HEALTH(unit)
	local triggers = tUNIT_HEALTH[unit]
	if triggers then
		local hpMax = UnitHealthMax(unit)
		if hpMax == 0 then
			module:TriggerHPLookup(unit,triggers,0)
			return
		end
		local hpNow = UnitHealth(unit)
		local hp = hpNow / hpMax * 100
		module:TriggerHPLookup(unit,triggers,hp,hpNow)
	end
end

function module.main:UNIT_POWER_FREQUENT(unit)
	local triggers = tUNIT_POWER_FREQUENT[unit]
	if triggers then
		local powerMax = UnitPowerMax(unit)
		if powerMax == 0 then
			module:TriggerHPLookup(unit,triggers,0)
			return
		end
		local powerNow = UnitPower(unit)
		local power = powerNow / powerMax * 100
		module:TriggerHPLookup(unit,triggers,power,powerNow)
	end
end

function module.main:UNIT_ABSORB_AMOUNT_CHANGED(unit)
	local triggers = tUNIT_ABSORB_AMOUNT_CHANGED[unit]
	if triggers then
		local absorbs = UnitGetTotalAbsorbs(unit)
		module:TriggerHPLookup(unit,triggers,absorbs,absorbs)
	end
end

function module:TriggerBossPull(encounterID, encounterName)
	local triggers = module.db.eventsToTriggers.BOSS_START
	if triggers then
		for i=1,#triggers do
			module:RunTrigger(triggers[i])
		end
	end

	if (module.db.eventsToTriggers.NOTE_TIMERS or module.db.eventsToTriggers.NOTE_TIMERS_ALL) and VMRT and VMRT.Note and VMRT.Note.Text1 then

		for _,event_name in pairs({"NOTE_TIMERS","NOTE_TIMERS_ALL"}) do
			local triggers = module.db.eventsToTriggers[event_name]
			if triggers then
				local data = module:ParseNoteTimers(0,true,nil,event_name == "NOTE_TIMERS_ALL")
				for j=1,#data do
					local now = data[j]
		
					local prefix,spellID,counter = strsplit(":",now.cleu)
					local event = 
						prefix == "SCC" and "SPELL_CAST_SUCCESS" or
						prefix == "SCS" and "SPELL_CAST_START" or
						prefix == "SAA" and "SPELL_AURA_APPLIED" or
						prefix == "SAR" and "SPELL_AURA_REMOVED"
					if event and spellID and tonumber(spellID) and counter and tonumber(counter) then
						local triggerOverwrite = {
							Dcounter = counter ~= "0" and module:CreateNumberConditions(counter) or false,
							DsourceName = false,
							DsourceID = false,
							DtargetName = false,
							DtargetID = false,
							Dstacks = false,
							untimed = false,
						}
						local triggerDataOverwrite = {
							spellID = tonumber(spellID),
							spellName = false,
							sourceMark = false,
							sourceUnit = false,
							targetMark = false,
							targetUnit = false,
							extraSpellID = false,
							pattFind = false,
							cbehavior = false,
						}
		
						for i=1,#triggers do
							local trigger = triggers[i]
							local triggerData = trigger._trigger
		
							local DdelayTime = module:ConvertMinuteStrToNum(now.time)
							if DdelayTime then
								for k=1,#DdelayTime do
									DdelayTime[k] = max(DdelayTime[k] - (triggerData.bwtimeleft or 0) + now.diffTime,0.01)
								end
							end
							local dataTable = {count = 0}
		
							local newData = setmetatable({},{__index = function(_,a)
								if type(triggerDataOverwrite[a]) == "boolean" then
									return triggerDataOverwrite[a]
								end
								return triggerDataOverwrite[a] or triggerData[a]
							end})
		
							local new = setmetatable({},{__index = function(_,a)
								if a == "_trigger" then
									return newData
								elseif a == "DdelayTime" then
									return DdelayTime
								elseif a == "status" then
									return trigger.status
								elseif a == "count" then
									return dataTable.count
								else
									if type(triggerOverwrite[a]) == "boolean" then
										return triggerOverwrite[a]
									end
									return triggerOverwrite[a] or trigger[a]
								end
							end, __newindex = function(_,a,v)
								if a == "status" then
									trigger.status = v
									if type(v) == "table" then
										v.text = now.textRight
										v.textLeft = now.textLeft
										v.fullLine = now.fullLine
									end
								elseif a == "count" then
									dataTable.count = v
									trigger.count = v
								end
							end})
		
							tCOMBAT_LOG_EVENT_UNFILTERED[event] = tCOMBAT_LOG_EVENT_UNFILTERED[event] or {}
							tCOMBAT_LOG_EVENT_UNFILTERED[event][#tCOMBAT_LOG_EVENT_UNFILTERED[event]+1] = new
						end
					end
				end
			end
		end
	end

	if IsHistoryEnabled then
		module:AddHistoryRecord(3, encounterID, encounterName)
	end
end
--/run GExRT.A.Reminder2:TriggerBossPull()

function module:ParseNoteTimers(phaseNum,doCLEU,globalPhaseNum,ignoreName)
	local playerName = ExRT.SDB.charName
	local playerClass = select(2,UnitClass'player'):lower()
	local data = {}

	local lines = GetMRTNoteLines()
	for i=1,#lines do
		if lines[i]:find("{time:[^}]+}") then
			local l = lines[i]:gsub(" *$",""):gsub(" +"," ")
			local list = {strsplit(" ", l)}
			for j=1,#list do
				if (list[j]:gsub("|c........",""):gsub("|r",""):gsub("|","") == playerName) or ignoreName then
					local fulltime,subOpts = l:match("{time:([0-9:%.]+)([^{}]*)}")
					local phase
					local difftime,difflen = 0
					local isDisabled, isCLEU, isGlobalPhaseCounter
					if subOpts then
						for w in string_gmatch(subOpts,"[^,]+") do
							local igp,pf = w:match("^p(g?)([%d%.]+)$")
							if pf then
								phase = tonumber(pf)
							end
							if igp then
								isGlobalPhaseCounter = true
							end
							local a,b,c = strsplit(":",w)
							if a == "diff" and b and (b == playerName or b:lower() == playerClass) and c then
								difftime = difftime + (tonumber(c) or 0)
							end
							if a == "difflen" and b and (b == playerName or b:lower() == playerClass) and c then
								difflen = tonumber(c)
							end
							if w == "off" then
								isDisabled = true
							elseif w:find("^S[CA][CSAR]:") then
								isCLEU = w
							end
						end
					end
					if not isDisabled and ((doCLEU and isCLEU) or (not doCLEU and not isCLEU)) then
						local line2 = l:gsub("{time[^}]+}",""):gsub("{0}.-{/0}","")
						local prefix = line2:match("([^ ]+) +[^ ]*"..playerName) or ""
						if prefix:find("_$") then
							local prefix2 = line2:match("(%b__) +[^ ]*"..playerName)
							if prefix2 then
								prefix = prefix2:sub(2,-2)
							end
						end
						if prefix:find("^%(") then prefix = prefix:sub(2) end

						local suffix = line2:match(playerName.."[^ ]* +([^ ]+)") or ""
						if suffix:find("^_") then
							local suffix2 = line2:match(playerName.."[^ ]* +(%b__)")
							if suffix2 then
								suffix = suffix2:sub(2,-2)
							end
						end

						local phaseCheck = isGlobalPhaseCounter and globalPhaseNum or phaseNum

						data[#data+1] = {
							time = fulltime,
							phaseMatch = phaseCheck == tostring(phase or 1),
							textRight = suffix,
							textLeft = prefix,
							fullLine = l,
							phase = phase,
							diffTime = difftime,
							diffLen = difflen or nil,
							cleu = isCLEU,
						}
					end
					break
				end
			end
		end
	end

	return data
end

function module:TriggerBossPhase(phaseText,globalPhaseNum)
	local phaseNum = phaseText:match("%d+%.?%d*")

	if module.db.eventsToTriggers.BOSS_PHASE then
		local triggers = module.db.eventsToTriggers.BOSS_PHASE
		for i=1,#triggers do
			local trigger = triggers[i]
			local triggerData = trigger._trigger
			if 
				triggerData.pattFind
			then
				local phaseCheck = (phaseNum == triggerData.pattFind or phaseText:find(triggerData.pattFind,1,true))
	
				if not trigger.statuses[1] and phaseCheck then
					module:AddTriggerCounter(trigger)
					local vars = {
						phase = phaseText,
						counter = trigger.count,
					}
					trigger.statuses[1] = vars
					if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
						module:RunTrigger(trigger, vars)
					end
				elseif trigger.statuses[1] and not phaseCheck then
					trigger.statuses[1] = nil
					module:DeactivateTrigger(trigger)
				end
			end
		end
	end

	if (module.db.eventsToTriggers.NOTE_TIMERS or module.db.eventsToTriggers.NOTE_TIMERS_ALL) and VMRT and VMRT.Note and VMRT.Note.Text1 and phaseNum then

		for _,event_name in pairs({"NOTE_TIMERS","NOTE_TIMERS_ALL"}) do
			local triggers = module.db.eventsToTriggers[event_name]
			if triggers then
				local data = module:ParseNoteTimers(phaseNum,false,globalPhaseNum,event_name == "NOTE_TIMERS_ALL")
				for i=1,#triggers do
					local trigger = triggers[i]
					local triggerData = trigger._trigger
					for j=1,#data do
						local now = data[j]
						trigger.DdelayTime = module:ConvertMinuteStrToNum(now.time)
						if trigger.DdelayTime then
							for k=1,#trigger.DdelayTime do
								trigger.DdelayTime[k] = max(trigger.DdelayTime[k] - (trigger._trigger.bwtimeleft or 0) + now.diffTime,0.01)
							end
						end
						local uid = event_name .. ":" .. i .. ":" .. (now.phase or "0") .. ":" .. j

						local match = true
						if triggerData.pattFind and ((triggerData.pattFind:find("^%-") and now.fullLine:find(triggerData.pattFind:sub(2),1,true)) or (not triggerData.pattFind:find("^%-") and not now.fullLine:find(triggerData.pattFind,1,true))) then
							match = false
						end
		
						if not trigger.statuses[uid] and now.phaseMatch and match then
							local vars = {
								phase = phaseText,
								counter = 0,
								text = now.textRight,
								textLeft = now.textLeft,
								fullLine = now.fullLine,
								fullLineClear = (now.fullLine or ""):gsub("[{}]",""),
								uid = uid,
							}
							if now.diffLen then
								vars._customDuration = max((trigger._data.dur or 2) + now.diffLen,0.01)
							end
							trigger.statuses[uid] = vars
							module:RunTrigger(trigger, vars)
						elseif trigger.statuses[uid] and not now.phaseMatch then
							trigger.statuses[uid] = nil
							if now.phase then
								module:DeactivateTrigger(trigger, uid)
							end
						end
					end
				end
			end
		end
	end

	if IsHistoryEnabled then
		module:AddHistoryRecord(2,phaseText)
	end
end
--/run GExRT.A.Reminder2:TriggerBossPhase("1")

function module:TriggerBWMessage(key, text)
	local triggers = module.db.eventsToTriggers.BW_MSG
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger
		if 
			(triggerData.pattFind and type(text)=="string" and text:find(triggerData.pattFind,1,true)) or
			(triggerData.spellID and key == triggerData.spellID)
		then
			module:AddTriggerCounter(trigger)
			if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
				local vars = {
					counter = trigger.count,
					spellID = key,
					spellName = text,
					uid = module:GetNextUID(),
				}
				module:RunTrigger(trigger, vars)
			end
		end
	end
end

local function TriggerBWTimer_DelayActive(trigger, triggerData, expirationTime, key, text)
	module:AddTriggerCounter(trigger)
	if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
		local vars = {
			counter = trigger.count,
			spellID = key,
			spellName = text,
			timeLeft = expirationTime,
			uid = module:GetNextUID(),
		}
		module:RunTrigger(trigger, vars)
	end
end

function module:TriggerBWTimer(key, text, duration)
	local triggers = module.db.eventsToTriggers.BW_TIMER
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger
		if 
			key == -1 or
			(
			 triggerData.bwtimeleft and 
			 (duration == 0 or duration >= triggerData.bwtimeleft) and
			 (
			  (triggerData.pattFind and type(text)=="string" and text:find(triggerData.pattFind,1,true)) or
			  (triggerData.spellID and key == triggerData.spellID)
			 )
			)
		then
			if duration == 0 then
				for i=1,#trigger.delays2 do
					trigger.delays2[i]:Cancel()
				end
				wipe(trigger.delays2)
			else
				local t = ScheduleTimer(TriggerBWTimer_DelayActive, max(duration - triggerData.bwtimeleft, 0.01), trigger, triggerData, GetTime() + duration, key, text)
				module.db.timers[#module.db.timers+1] = t
				trigger.delays2[#trigger.delays2+1] = t
			end
		end
	end
end


do
	local BW_Locale
	local BW_Locale_Soon

	local BigWigsTextToKeys = {}
	local function BigWigsEventCallback(event, ...)
		if (event == "BigWigs_Message") then
			local bwModule, key, text, color, icon = ...

			if key == "stages" and type(text)=='string' and module.db.eventsToTriggers.BOSS_PHASE then
				local isSoonAnnounce

				if not BW_Locale_Soon then
					local CL = BW_Locale or BigWigsAPI:GetLocale("BigWigs: Common")
					BW_Locale = CL
					if CL and CL.soon and type(text)=='string' then
						local patt = CL.soon:gsub("%%s","")
						if CL.soon:find("^%%s") then
							patt = patt .. "$"
						else
							patt = "^" .. patt
						end
						BW_Locale_Soon = patt
					end
				end
				if BW_Locale_Soon and text:find(BW_Locale_Soon) then
					isSoonAnnounce = true
				end

				if not isSoonAnnounce and false then	--deprecated
					module:TriggerBossPhase(text)
				end
			end

			if module.db.eventsToTriggers.BW_MSG then
				module:TriggerBWMessage(key, text)
			end
		elseif event == "BigWigs_SetStage" then
			local bwModule, stage = ...
			if stage and module.db.eventsToTriggers.BOSS_PHASE then
				module:TriggerBossPhase(tostring(stage))
			end
		elseif (event == "BigWigs_StartBar") then
			local bwModule, key, text, duration, icon = ...

			BigWigsTextToKeys[text] = key
			if module.db.eventsToTriggers.BW_TIMER then
				module:TriggerBWTimer(key, text, duration)
			end
		elseif (event == "BigWigs_ResumeBar") then
			local bwModule, text = ...

			local duration = 0
			if BigWigs:GetPlugin("Bars") and bwModule then
				duration = bwModule:BarTimeLeft(text)
			end
			if duration == 0 then
				return
			end

			if module.db.eventsToTriggers.BW_TIMER and text then
				module:TriggerBWTimer(BigWigsTextToKeys[text], text, duration)
			end
		elseif (event == "BigWigs_StopBar") or (event == "BigWigs_PauseBar") then
			local bwModule, text = ...

			if module.db.eventsToTriggers.BW_TIMER and text then
				module:TriggerBWTimer(BigWigsTextToKeys[text], text, 0)
			end
		elseif (event == "BigWigs_StopBars" or event == "BigWigs_OnBossDisable"	or event == "BigWigs_OnPluginDisable") then
			local bwModule = ...

			if module.db.eventsToTriggers.BW_TIMER then
				module:TriggerBWTimer(-1, nil, 0)
			end
		end
	end

	local registeredBigWigsEvents = {}
	function module:RegisterBigWigsCallback(event)
		if (registeredBigWigsEvents[event]) then
			return
		end
		if (BigWigsLoader) then
			BigWigsLoader.RegisterMessage(module, event, BigWigsEventCallback)
			registeredBigWigsEvents[event] = true
		end
	end
	function module:UnregisterBigWigsCallback(event)
		if not (registeredBigWigsEvents[event]) then
			return
		end
		if (BigWigsLoader) then
			BigWigsLoader.UnregisterMessage(module, event)
			registeredBigWigsEvents[event] = nil
		end
	end
end

do
	local DBMIdToSpellID = {}
	local DBMIdToText = {}
	local function DBMEventCallback(event, ...)
		if BigWigsLoader then
			return
		end
		if (event == "DBM_Announce") then
			local message, icon, announce_type, spellId, modId = ...

			if module.db.eventsToTriggers.BW_MSG then
				module:TriggerBWMessage(spellId, message)
			end
		elseif event == "DBM_TimerStart" then
			local id, msg, duration, icon, timerType, spellId, dbmType = ...
			if module.db.eventsToTriggers.BW_TIMER and id then
				DBMIdToSpellID[id] = spellId
				DBMIdToText[id] = msg or ""
				module:TriggerBWTimer(spellId, msg, duration)
			end
		elseif event == "DBM_TimerStop" or event == "DBM_TimerPause" then
			local id = ...
			if module.db.eventsToTriggers.BW_TIMER and id and DBMIdToSpellID[id] then
				module:TriggerBWTimer(DBMIdToSpellID[id], DBMIdToText[id] or "", 0)
			end
		elseif (event == "DBM_TimerResume") then
			local id = ...

			local duration = 0
			if type(DBT) == "table" and DBT.GetBar and id then
				local bar = DBT:GetBar(id)
				duration = bar and bar.timer or 0
			end
			if duration == 0 then
				return
			end

			if module.db.eventsToTriggers.BW_TIMER and id and DBMIdToSpellID[id] then
				module:TriggerBWTimer(DBMIdToSpellID[id], DBMIdToText[id] or "", duration)
			end
		elseif (event == "DBM_TimerUpdate") then
			local id, elapsed, duration = ...

			if module.db.eventsToTriggers.BW_TIMER and id and DBMIdToSpellID[id] then
				module:TriggerBWTimer(DBMIdToSpellID[id], DBMIdToText[id] or "", duration - elapsed)
			end
		elseif event == "DBM_SetStage" then
			local addon, modId, stage, encounterId, stageTotal = ...
			if stage then
				module:TriggerBossPhase(tostring(stage),tostring(stageTotal))
			end
		elseif event == "kill" or event == "wipe" then
			if module.db.eventsToTriggers.BW_TIMER then
				module:TriggerBWTimer(-1, nil, 0)
			end
		end
	end

	local registeredDBMEvents = {}
	function module:RegisterDBMCallback(event)
		if (registeredDBMEvents[event]) then
			return
		end
		if type(DBM)=='table' and DBM.RegisterCallback then
			registeredDBMEvents[event] = true
			
			if event == "DBM_kill" or event == "DBM_wipe" then 
				event = event:sub(5) 
			end
			DBM:RegisterCallback(event, DBMEventCallback)
		end
	end
	function module:UnregisterDBMCallback(event)
		if not (registeredDBMEvents[event]) then
			return
		end
		if type(DBM)=='table' and DBM.UnregisterCallback then
			registeredDBMEvents[event] = nil

			if event == "DBM_kill" or event == "DBM_wipe" then 
				event = event:sub(5) 
			end
			DBM:UnregisterCallback(event, DBMEventCallback)
		end
	end
end


function module:TriggerChat(text, sourceName, sourceGUID, targetName)
	local triggers = module.db.eventsToTriggers.CHAT_MSG
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger
		if 
			triggerData.pattFind and 
			text:find(triggerData.pattFind,1,true) and
			(not trigger.DsourceName or sourceName and trigger.DsourceName[sourceName]) and
			(not trigger.DsourceID or not sourceGUID or trigger.DsourceID(sourceGUID)) and
			(not triggerData.sourceUnit or not sourceGUID or module:CheckUnit(triggerData.sourceUnit,sourceGUID,trigger)) and
			(not trigger.DtargetName or targetName and trigger.DtargetName[targetName]) and
			(not triggerData.targetUnit or not targetName or (UnitGUID(targetName) and module:CheckUnit(triggerData.targetUnit,UnitGUID(targetName),trigger)))
		then
			module:AddTriggerCounter(trigger)
			if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
				if sourceName and sourceName:find("%-") and UnitName(strsplit("-",sourceName),nil) then
					sourceName = strsplit("-",sourceName)
				end
				if targetName and targetName:find("%-") and UnitName(strsplit("-",targetName),nil) then
					targetName = strsplit("-",targetName)
				end
				local vars = {
					sourceName = sourceName,
					targetName = targetName,
					counter = trigger.count,
					guid = sourceGUID or UnitGUID(sourceName or ""),
					text = text,
					uid = module:GetNextUID(),
				}
				module:RunTrigger(trigger, vars)
			end
		end
	end

	if IsHistoryEnabled then
		module:AddHistoryRecord(8, text, sourceName, sourceGUID, targetName)
	end
end

local function CHAT_MSG(self, text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
	module:TriggerChat(text, playerName, guid, playerName2)
end

module.main.CHAT_MSG_RAID_WARNING = CHAT_MSG
module.main.CHAT_MSG_MONSTER_YELL = CHAT_MSG
module.main.CHAT_MSG_MONSTER_EMOTE = CHAT_MSG
module.main.CHAT_MSG_MONSTER_SAY = CHAT_MSG
module.main.CHAT_MSG_MONSTER_WHISPER = CHAT_MSG
module.main.CHAT_MSG_RAID_BOSS_EMOTE = CHAT_MSG
module.main.CHAT_MSG_RAID_BOSS_WHISPER = CHAT_MSG
module.main.CHAT_MSG_RAID = CHAT_MSG
module.main.CHAT_MSG_RAID_LEADER = CHAT_MSG
module.main.CHAT_MSG_PARTY = CHAT_MSG
module.main.CHAT_MSG_PARTY_LEADER = CHAT_MSG
module.main.CHAT_MSG_WHISPER = CHAT_MSG

local function RAID_MSG(self, text, playerName, displayTime, enableBossEmoteWarningSound)
	module:TriggerChat(text)
end

module.main.RAID_BOSS_EMOTE = RAID_MSG
module.main.RAID_BOSS_WHISPER = RAID_MSG


function module:TriggerBossFrame(targetName, targetGUID, targetUnit)
	local triggers = module.db.eventsToTriggers.INSTANCE_ENCOUNTER_ENGAGE_UNIT
	if triggers then
		for i=1,#triggers do
			local trigger = triggers[i]
			local triggerData = trigger._trigger
			if 
				(not trigger.DtargetName or targetName and trigger.DtargetName[targetName]) and
				(not trigger.DtargetID or trigger.DtargetID(targetGUID)) and
				(not triggerData.targetUnit or triggerData.targetUnit == targetUnit)
			then
				trigger.countsD[targetGUID] = (trigger.countsD[targetGUID] or 0) + 1
				module:AddTriggerCounter(trigger,nil,trigger.countsD[targetGUID])
				if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
					local vars = {
						targetName = targetName,
						counter = trigger.count,
						guid = targetGUID,
						uid = module:GetNextUID(),
					}
					module:RunTrigger(trigger, vars)
				end
			end
		end
	end

	if IsHistoryEnabled then
		module:AddHistoryRecord(9, targetName, targetGUID, targetUnit)
	end
end

local bossFramesblackList = {}
module.db.bossFramesblackList = bossFramesblackList
function module.main:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	for _,unit in pairs(module.datas.unitsList[1]) do
		local guid = UnitGUID(unit)
		if guid then
			if not bossFramesblackList[guid] then
				bossFramesblackList[guid] = true
				local name = UnitName(unit) or ""
				module:TriggerBossFrame(name, guid, unit)
			end
			module:CycleAllUnitEvents(unit)
		end
		module:CycleAllUnitEvents_UnitRefresh(unit)
	end
end

local function TriggerAura_DelayActive(trigger, triggerData, guid, vars)
	if not vars.__counter_added then
		vars.__counter_added = true
		trigger.countsD[guid] = (trigger.countsD[guid] or 0) + 1
		if vars.sourceGUID then
			trigger.countsS[vars.sourceGUID] = (trigger.countsS[vars.sourceGUID] or 0) + 1
		end
		module:AddTriggerCounter(trigger,vars.sourceGUID and trigger.countsS[vars.sourceGUID],trigger.countsD[guid])
	end
	if 
		(not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count)) and
		(not triggerData.onlyPlayer or guid == UnitGUID("player"))
	then
		vars.counter = trigger.count
		module:RunTrigger(trigger, vars)
	end
end

local unitAurasInstances = {}
local unitAuras = {}
module.db.unitAuras = unitAuras
module.db.unitAurasInstances = unitAurasInstances
local C_UnitAuras_GetAuraDataByAuraInstanceID = C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
if not ExRT.isClassic or C_UnitAuras_GetAuraDataByIndex then
	function module.main:UNIT_AURA(unit,updateInfo)
		local triggers = tUNIT_AURA[unit]
		if triggers then
			local guid = UnitGUID(unit)
			if guid then
				local a = unitAurasInstances[guid]
				if not a then
					a = {s = {},n = {}}
					unitAurasInstances[guid] = a
				end

				if updateInfo and not updateInfo.isFullUpdate then
					if updateInfo.removedAuraInstanceIDs then
						for _, auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
							local aura = a[auraInstanceID]
							if aura then
								a[auraInstanceID] = nil
								if aura.spellId then a.s[aura.spellId] = nil end
								if aura.name then a.n[aura.name] = nil end
							end
						end
					end
					if updateInfo.addedAuras then
						for _, aura in pairs(updateInfo.addedAuras) do
							a[aura.auraInstanceID] = aura
							if aura.spellId then a.s[aura.spellId] = aura.auraInstanceID end
							if aura.name then a.n[aura.name] = aura.auraInstanceID end
						end
					end
					
					if updateInfo.updatedAuraInstanceIDs then
						for _, auraInstanceID in pairs(updateInfo.updatedAuraInstanceIDs) do
							local oldAura = a[auraInstanceID]
							local newAura = C_UnitAuras_GetAuraDataByAuraInstanceID(unit, auraInstanceID)
							if newAura then
								a[auraInstanceID] = newAura
								if oldAura and (oldAura.applications ~= newAura.applications or oldAura.expirationTime ~= newAura.expirationTime) then
									newAura.rem_changed_dur = true
								else
									newAura.rem_changed_dur = nil
								end
							end
						end
					end
				else
					if updateInfo and updateInfo.isFullUpdate then
						wipe(a)
						a.s = {}
						a.n = {}
					end
					for index=1,255 do
						local aura = C_UnitAuras_GetAuraDataByIndex(unit, index, "HELPFUL")
						if not aura then
							break
						end
						a[aura.auraInstanceID] = aura
						if aura.spellId then a.s[aura.spellId] = aura.auraInstanceID end
						if aura.name then a.n[aura.name] = aura.auraInstanceID end
					end
					for index=1,255 do
						local aura = C_UnitAuras_GetAuraDataByIndex(unit, index, "HARMFUL")
						if not aura then
							break
						end
						a[aura.auraInstanceID] = aura
						if aura.spellId then a.s[aura.spellId] = aura.auraInstanceID end
						if aura.name then a.n[aura.name] = aura.auraInstanceID end
					end
				end
	
				local name = UnitName(unit)
				local now = GetTime()
				for i=1,#triggers do
					local trigger = triggers[i]
					local triggerData = trigger._trigger
					local auraData
					if triggerData.spellID then
						local auraInstanceID = a.s[triggerData.spellID]
						if auraInstanceID then
							auraData = a[auraInstanceID]
						end
					elseif triggerData.spellName then
						local auraInstanceID = a.n[triggerData.spellName]
						if auraInstanceID then
							auraData = a[auraInstanceID]
						end
					end
					local sourceName = auraData and auraData.sourceUnit and UnitName(auraData.sourceUnit) or nil
	
					if 
						auraData and
						(not trigger.DsourceName or sourceName and trigger.DsourceName[sourceName]) and
						(not trigger.DsourceID or auraData.sourceUnit and trigger.DsourceID(UnitGUID(auraData.sourceUnit))) and
						(not triggerData.sourceMark or auraData.sourceUnit and (GetRaidTargetIndex(auraData.sourceUnit) or 0) == triggerData.sourceMark) and
						(not triggerData.sourceUnit or auraData.sourceUnit and module:CheckUnit(triggerData.sourceUnit,UnitGUID(auraData.sourceUnit),trigger)) and
						(not trigger.DtargetName or name and trigger.DtargetName[name]) and
						(not trigger.DtargetID or trigger.DtargetID(guid)) and
						(not triggerData.targetMark or (GetRaidTargetIndex(unit) or 0) == triggerData.targetMark) and
						(not triggerData.targetUnit or module:CheckUnit(triggerData.targetUnit,guid,trigger)) and
						(not trigger.Dstacks or module:CheckNumber(trigger.Dstacks,auraData.applications)) and
						(not triggerData.targetRole or module:CmpUnitRole(unit,triggerData.targetRole))
					then
						if not trigger.statuses[guid] then
	
							local vars = {
								sourceName = sourceName,
								sourceMark = auraData.sourceUnit and GetRaidTargetIndex(auraData.sourceUnit) or nil,
								targetName = name,
								targetMark = GetRaidTargetIndex(unit),
								stacks = auraData.applications,
								guid = guid,
								sourceGUID = auraData.sourceUnit and UnitGUID(auraData.sourceUnit) or nil,
								targetGUID = guid,
								timeLeft = auraData.expirationTime,
								_auraData = auraData,
								spellID = auraData.spellId,
								spellName = auraData.name,
							}
							trigger.statuses[guid] = vars
							trigger.units[guid] = unit
							if not triggerData.bwtimeleft or auraData.expirationTime - now < triggerData.bwtimeleft then
								TriggerAura_DelayActive(trigger, triggerData, guid, vars)
							else
								local t = ScheduleTimer(TriggerAura_DelayActive, max(auraData.expirationTime - triggerData.bwtimeleft - now, 0.01), trigger, triggerData, guid, vars)
								module.db.timers[#module.db.timers+1] = t
								trigger.delays2[#trigger.delays2+1] = t
							end
						else
							local vars = trigger.statuses[guid]

							vars.timeLeft = auraData.expirationTime
							vars.stacks = auraData.applications

							if auraData.rem_changed_dur then	--for auras with changed durations
								for j=#trigger.delays2,1,-1 do
									if trigger.delays2[j].args[3] == guid then
										trigger.delays2[j]:Cancel()
										tremove(trigger.delays2, j)
									end
								end
								
								if not triggerData.bwtimeleft or auraData.expirationTime - now < triggerData.bwtimeleft then
									TriggerAura_DelayActive(trigger, triggerData, guid, vars)
								else
									local t = ScheduleTimer(TriggerAura_DelayActive, max(auraData.expirationTime - triggerData.bwtimeleft - now, 0.01), trigger, triggerData, guid, vars)
									module.db.timers[#module.db.timers+1] = t
									trigger.delays2[#trigger.delays2+1] = t
								end
							end
						end
					elseif trigger.statuses[guid] then
						trigger.statuses[guid] = nil
						trigger.units[guid] = nil
						module:DeactivateTrigger(trigger,guid)
						if #trigger.delays2 > 0 then
							for j=#trigger.delays2,1,-1 do
								if trigger.delays2[j].args[3] == guid then
									trigger.delays2[j]:Cancel()
									tremove(trigger.delays2, j)
								end
							end
						end
					end
				end
			end
		end
	end
else
	function module.main:UNIT_AURA(unit,updateInfo)
		local triggers = tUNIT_AURA[unit]
		if triggers then
			local guid = UnitGUID(unit)
			if guid then
				local a = unitAuras[guid]
				if not a then
					a = {}
					unitAuras[guid] = a
				end
				for k,v in pairs(a) do v.r=true end
				for i=1,255 do
					local name, _, count, _, duration, expirationTime, source, _, _, spellId, _, _, _, _, _, val1, val2, val3 = UnitAura(unit, i, "HELPFUL")
					if not spellId then
						break
					elseif not a[spellId] then
						a[spellId] = {name, count, duration, expirationTime, source, spellId, nil, val1, val2, val3}
					else
						local b = a[spellId]
						b[2] = count
						b[3] = duration
						if b[4] ~= expirationTime or b[2] ~= count then
							b[7] = true
						else
							b[7] = nil
						end
						b[4] = expirationTime
						b[8] = val1
						b[9] = val2
						b[10] = val3
						b.r = false
					end
				end
				for i=1,255 do
					local name, _, count, _, duration, expirationTime, source, _, _, spellId, _, _, _, _, _, val1, val2, val3 = UnitAura(unit, i, "HARMFUL")
					if not spellId then
						break
					elseif not a[spellId] then
						a[spellId] = {name, count, duration, expirationTime, source, spellId, nil, val1, val2, val3}
					else
						local b = a[spellId]
						b[2] = count
						b[3] = duration
						b[4] = expirationTime
						if b[4] ~= expirationTime or b[2] ~= count then
							b[7] = true
						else
							b[7] = nil
						end
						b[8] = val1
						b[9] = val2
						b[10] = val3
						b.r = false
					end
				end
				for k,v in pairs(a) do if v.r then a[k]=nil end end
	
				local name = UnitName(unit)
				local now = GetTime()
				for i=1,#triggers do
					local trigger = triggers[i]
					local triggerData = trigger._trigger
					local auraData
					if triggerData.spellID then
						auraData = a[triggerData.spellID]
					elseif triggerData.spellName then
						for k,v in pairs(a) do
							if v[1] == triggerData.spellName then
								auraData = v
								break
							end
						end
					end
					local sourceName = auraData and auraData[5] and UnitName(auraData[5]) or nil
	
					if 
						auraData and
						(not trigger.DsourceName or sourceName and trigger.DsourceName[sourceName]) and
						(not trigger.DsourceID or auraData[5] and trigger.DsourceID(UnitGUID(auraData[5]))) and
						(not triggerData.sourceMark or auraData[5] and (GetRaidTargetIndex(auraData[5]) or 0) == triggerData.sourceMark) and
						(not triggerData.sourceUnit or auraData[5] and module:CheckUnit(triggerData.sourceUnit,UnitGUID(auraData[5]),trigger)) and
						(not trigger.DtargetName or name and trigger.DtargetName[name]) and
						(not trigger.DtargetID or trigger.DtargetID(guid)) and
						(not triggerData.targetMark or (GetRaidTargetIndex(unit) or 0) == triggerData.targetMark) and
						(not triggerData.targetUnit or module:CheckUnit(triggerData.targetUnit,guid,trigger)) and
						(not trigger.Dstacks or module:CheckNumber(trigger.Dstacks,auraData[2])) and
						(not triggerData.targetRole or module:CmpUnitRole(unit,triggerData.targetRole))
					then
						if not trigger.statuses[guid] or auraData[7] then
	
							if auraData[7] then	--for auras with changed durations
								for j=#trigger.delays2,1,-1 do
									if trigger.delays2[j].args[3] == guid then
										trigger.delays2[j]:Cancel()
										tremove(trigger.delays2, j)
									end
								end
							end
	
							local vars = {
								sourceName = sourceName,
								sourceMark = auraData[5] and GetRaidTargetIndex(auraData[5]) or nil,
								targetName = name,
								targetMark = GetRaidTargetIndex(unit),
								stacks = auraData[2],
								guid = guid,
								sourceGUID = auraData[5] and UnitGUID(auraData[5]) or nil,
								targetGUID = guid,
								timeLeft = auraData[4],
								_auraData = auraData,
								spellID = auraData[6],
								spellName = auraData[1],
							}
							trigger.statuses[guid] = vars
							trigger.units[guid] = unit
							if not triggerData.bwtimeleft or auraData[4] - now < triggerData.bwtimeleft then
								TriggerAura_DelayActive(trigger, triggerData, guid, vars)
							else
								local t = ScheduleTimer(TriggerAura_DelayActive, max(auraData[4] - triggerData.bwtimeleft - now, 0.01), trigger, triggerData, guid, vars)
								module.db.timers[#module.db.timers+1] = t
								trigger.delays2[#trigger.delays2+1] = t
							end
						end
	
						if trigger.statuses[guid] then
							trigger.statuses[guid].timeLeft = auraData[4]
						end
					elseif trigger.statuses[guid] then
						trigger.statuses[guid] = nil
						trigger.units[guid] = nil
						module:DeactivateTrigger(trigger,guid)
						if #trigger.delays2 > 0 then
							for j=#trigger.delays2,1,-1 do
								if trigger.delays2[j].args[3] == guid then
									trigger.delays2[j]:Cancel()
									tremove(trigger.delays2, j)
								end
							end
						end
					end
				end
			end
		end
	end
end

function module:TriggerTargetLookup(unit,triggers)
	local guid = UnitGUID(unit)
	local name = UnitName(unit)
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger
		if 
			(not trigger.DsourceName or name and trigger.DsourceName[name]) and
			(not trigger.DsourceID or trigger.DsourceID(guid))
		then
			local tunit = unit.."target"
			local tguid = UnitGUID(tunit)
			local tname = UnitName(tunit)
			local targetCheck = tguid and
				(not triggerData.sourceMark or (GetRaidTargetIndex(unit) or 0) == triggerData.sourceMark) and
				(not trigger.DtargetName or tname and trigger.DtargetName[tname]) and
				(not trigger.DtargetID or trigger.DtargetID(tguid)) and
				(not triggerData.targetMark or (GetRaidTargetIndex(tunit) or 0) == triggerData.targetMark) and
				(not triggerData.targetUnit or module:CheckUnit(triggerData.targetUnit,tguid,trigger))

			if not trigger.statuses[guid] and targetCheck then
				trigger.countsS[guid] = (trigger.countsS[guid] or 0) + 1
				module:AddTriggerCounter(trigger,trigger.countsS[guid])
				local vars = {
					sourceName = name,
					sourceMark = GetRaidTargetIndex(unit),
					targetName = tname,
					targetMark = GetRaidTargetIndex(tunit),
					guid = triggerData.guidunit == 1 and guid or tguid,
					counter = trigger.count,
					sourceGUID = guid,
					targetGUID = tguid,
					uid = guid,
				}
				trigger.statuses[guid] = vars
				trigger.units[guid] = unit
				if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
					module:RunTrigger(trigger, vars)
				end
			elseif trigger.statuses[guid] and not targetCheck then
				trigger.statuses[guid] = nil
				trigger.units[guid] = nil
				module:DeactivateTrigger(trigger,guid)
			end
		end
	end
end

function module.main:UNIT_TARGET(unit)
	local triggers = tUNIT_TARGET[unit]
	if triggers then
		module:TriggerTargetLookup(unit,triggers)
	end
end

function module.main:UNIT_THREAT_LIST_UPDATE(unit)
	local triggers = tUNIT_TARGET[unit]
	if triggers then
		module:TriggerTargetLookup(unit,triggers)
	end
end

function module:TriggerSpellCD(triggers)
	local gstartTime, gduration, genabled = GetSpellCooldown(61304)
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger

		local spell = triggerData.spellID or triggerData.spellName
		if spell then
			local startTime, duration, enabled = GetSpellCooldown(spell)
			if duration then	--spell found
				local cdCheck = duration > gduration and duration > 0
				
				if not trigger.statuses[1] and cdCheck then
					module:AddTriggerCounter(trigger)
					local vars = {
						spellID = select(7,GetSpellInfo(spell)),
						spellName = GetSpellInfo(spell),
						counter = trigger.count,
						timeLeft = startTime + duration,
					}
					trigger.statuses[1] = vars
					if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
						module:RunTrigger(trigger, vars)
					end
				elseif trigger.statuses[1] and not cdCheck then
					trigger.statuses[1] = nil
					module:DeactivateTrigger(trigger)
				end

				if trigger.statuses[1] then
					trigger.statuses[1].timeLeft = startTime + duration
				end
			end
		end
	end
end


function module.main:SPELL_UPDATE_COOLDOWN(unit)
	local triggers = module.db.eventsToTriggers.CDABIL
	if triggers then
		module:TriggerSpellCD(triggers)
	end
end

function module:TriggerSpellcastSucceeded(unit, triggers, spellID)
	local guid = UnitGUID(unit)
	local name = UnitName(unit)
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger
		if 
			(not trigger.DsourceName or name and trigger.DsourceName[name]) and
			(not trigger.DsourceID or trigger.DsourceID(guid)) and
			(not triggerData.sourceMark or (GetRaidTargetIndex(unit) or 0) == triggerData.sourceMark) and
			(not triggerData.sourceUnit or module:CheckUnit(triggerData.sourceUnit,guid,trigger)) and
			(not triggerData.spellID or triggerData.spellID == spellID) and
			(not triggerData.spellName or triggerData.spellName == GetSpellInfo(spellID))
		then
			trigger.countsS[guid] = (trigger.countsS[guid] or 0) + 1
			module:AddTriggerCounter(trigger,trigger.countsS[guid])
			if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
				local vars = {
					sourceName = UnitName(unit),
					sourceMark = GetRaidTargetIndex(unit),
					spellID = spellID,
					spellName = GetSpellInfo(spellID),
					guid = guid,
					counter = trigger.count,
					uid = module:GetNextUID(),
				}
				module:RunTrigger(trigger, vars)
			end
		end
	end
end

function module.main:UNIT_SPELLCAST_SUCCEEDED(unit, castGUID, spellID)
	local triggers = tUNIT_SPELLCAST_SUCCEEDED[unit]
	if triggers then
		module:TriggerSpellcastSucceeded(unit, triggers, spellID)
	end
end

function module:TriggerWidgetUpdate(widgetID, widgetInfo)
	local widgetProgressData, isDouble, widgetRemoved = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID)
	if not widgetProgressData then
		widgetProgressData = C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo(widgetID)
		if not widgetProgressData then
			widgetRemoved = true
		end
		isDouble = true
	end
	local widgetVal, widgetValLeft, widgetValRight
	if not widgetRemoved then
		if not isDouble then
			widgetVal = ((widgetProgressData.barValue or 0) - (widgetProgressData.barMin or 0)) / max((widgetProgressData.barMax or 0) - (widgetProgressData.barMin or 0),1) * 100
		else
			widgetValLeft = ((widgetProgressData.leftBarValue or 0) - (widgetProgressData.leftBarMin or 0)) / max((widgetProgressData.leftBarMax or 0) - (widgetProgressData.leftBarMin or 0),1) * 100
			widgetValRight = ((widgetProgressData.rightBarValue or 0) - (widgetProgressData.rightBarMin or 0)) / max((widgetProgressData.rightBarMax or 0) - (widgetProgressData.rightBarMin or 0),1) * 100
		end
	end
	local triggers = module.db.eventsToTriggers.UPDATE_UI_WIDGET
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger
		if 
			(not triggerData.spellID or triggerData.spellID == widgetID) and
			(not triggerData.spellName or (
				widgetProgressData.text ~= "" and triggerData.spellName == widgetProgressData.text or 
				widgetProgressData.overrideBarText and widgetProgressData.overrideBarText ~= "" and widgetProgressData.overrideBarText:find(triggerData.spellName) or 
				widgetProgressData.tooltip and widgetProgressData.tooltip ~= "" and widgetProgressData.tooltip:find(triggerData.spellName)
			))
		then
			local check = trigger.DnumberPercent and 
				not widgetRemoved and
				(
				 (widgetVal and module:CheckNumber(trigger.DnumberPercent,widgetVal)) or
				 (widgetValLeft and module:CheckNumber(trigger.DnumberPercent,widgetValLeft)) or
				 (widgetValRight and module:CheckNumber(trigger.DnumberPercent,widgetValRight))
				)

			if not trigger.statuses[widgetID] and check then
				module:AddTriggerCounter(trigger)
				local vars = {
					counter = trigger.count,
					spellName = widgetProgressData.text ~= "" and widgetProgressData.text or widgetProgressData.overrideBarText ~= "" and widgetProgressData.overrideBarText or widgetProgressData.tooltip,
					spellID = widgetID,
					value = widgetVal,
					uid = widgetID,
				}
				trigger.statuses[widgetID] = vars
				if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
					module:RunTrigger(trigger, vars)
				end
			elseif trigger.statuses[widgetID] and not check then
				trigger.statuses[widgetID] = nil
				module:DeactivateTrigger(trigger,widgetID)
			end

			if trigger.statuses[widgetID] then
				trigger.statuses[widgetID].value = widgetVal
			end
		end
	end
end

do
	local ticker = nil
	local timerWidgets = {}
	local function WidgetTicker(self)
		for id, widget in pairs(timerWidgets) do
			local toremove = true
			local widgetProgressData = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(id)
			--print('tick',id,widgetProgressData and widgetProgressData.barValue)
			if widgetProgressData and widgetProgressData.barValue ~= (widgetProgressData.layoutDirection == 0 and widgetProgressData.barMin or widgetProgressData.barMax) then
				module.main:UPDATE_UI_WIDGET(widget)
				toremove = false
			end
			if toremove then
				timerWidgets[id] = nil
			end
		end
		for _ in pairs(timerWidgets) do
			return
		end
		ticker = nil
		self:Cancel()
	end
	function module.main:UPDATE_UI_WIDGET(widgetInfo)
		module:TriggerWidgetUpdate(widgetInfo.widgetID, widgetInfo)
	
		if widgetInfo.hasTimer then
			timerWidgets[widgetInfo.widgetID] = widgetInfo
			if not ticker then
				ticker = C_Timer.NewTicker(1, WidgetTicker)
			end
		end
	end
end

function module:TriggerPartyUnitUpdate(triggers)
	local allGUIDs,allNames = {},{}
	for _, name, subgroup, class, guid, rank, level, online, isDead, combatRole in ExRT.F.IterateRoster, ExRT.F.GetRaidDiffMaxGroup() do
		if guid and name then
			allGUIDs[guid] = name
			allNames[name] = guid
		end
	end
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger

		local list
		local isFirstArg
		if triggerData.pattFind then
			local pattList = module:FindPlayersListInNote(triggerData.pattFind)
			if pattList then
				list = {strsplit(" ",pattList)}
			end
		elseif trigger.DtargetName then
			list = trigger.DtargetName
			isFirstArg = true
		end
		if list then
			for arg1,arg2 in pairs(list) do
				local name = isFirstArg and arg1 or arg2
				local guid = allNames[name]
				if guid and not trigger.statuses[guid] then
					local vars = {
						targetName = name,
						targetGUID = guid,
						guid = guid,
						counter = 0,
					}
					trigger.statuses[guid] = vars
					trigger.units[guid] = name

					module:RunTrigger(trigger, vars)
				end
			end
		end
		for guid in pairs(trigger.statuses) do
			if not allGUIDs[guid] then
				trigger.statuses[guid] = nil
				trigger.units[guid] = nil

				module:DeactivateTrigger(trigger,guid)
			end
		end
	end
end

function module.main:GROUP_ROSTER_UPDATE()
	local triggers = module.db.eventsToTriggers.PARTY_UNIT
	if triggers then
		module:TriggerPartyUnitUpdate(triggers)
	end
end

do
	local CheckInteractDistance, IsItemInRange, UnitInRange = CheckInteractDistance, IsItemInRange, UnitInRange

	local _CheckInteractDistance = function(distIndex, unit)
		return CheckInteractDistance(unit, distIndex)
	end
	local _UnitInRange = function(_, unit)
		return UnitInRange(unit)
	end

	local existedRanges = {
		{4,IsItemInRange,90175},
		{5,IsItemInRange,37727},
		{6,IsItemInRange,42732},
		{7,IsItemInRange,129055},
		{8,IsItemInRange,63427},
		{10,_CheckInteractDistance,2},
		{13,IsItemInRange,32321},
		{18,IsItemInRange,6450},
		{22,IsItemInRange,21519},
		{28,IsItemInRange,13289},
		{30,_CheckInteractDistance,1},
		{33,IsItemInRange,1180},
		{38,IsItemInRange,18904},
		{43,_UnitInRange},
		{50,IsItemInRange,116139},
		{60,IsItemInRange,32825},
		{80,IsItemInRange,35278},
	}
	local existedRangesRaid = {
		{43,_UnitInRange},
	}

	function module:TriggerUnitsInRange(triggers)
		for i=1,#triggers do
			local trigger = triggers[i]
			local triggerData = trigger._trigger
			if 
				triggerData.bwtimeleft and
				trigger.Dstacks
			then
				local rangeData
				local rangesArr = existedRanges
				if not UnitPosition'player' then
					rangesArr = existedRangesRaid
				end
				for j=1,#rangesArr do
					if triggerData.bwtimeleft <= rangesArr[j][1] then
						rangeData = rangesArr[j]
						break
					end
				end

				local inRange = 0
				local list = ""
				if rangeData then
					for _, name, subgroup, class in ExRT.F.IterateRoster, ExRT.F.GetRaidDiffMaxGroup() do
						if not UnitIsUnit(name,'player') and not UnitIsDead(name) and rangeData[2](rangeData[3],name) then
							inRange = inRange + 1
							list = list .. "|c" .. ExRT.F.classColor(class) .. name .. "|r, "
						end
					end
					if #list > 0 then
						list = list:sub(1,-3)
					end
				end

				local check = module:CheckNumber(trigger.Dstacks,inRange)
				if not trigger.statuses[1] and check then
					local vars = {
						list = list,
						value = inRange,
						uid = 1,
					}
					trigger.statuses[1] = vars
					module:RunTrigger(trigger, vars)
				elseif trigger.statuses[1] and not check then
					trigger.statuses[1] = nil
					module:DeactivateTrigger(trigger,1)
				end

				if trigger.statuses[1] then
					trigger.statuses[1].value = inRange
					trigger.statuses[1].list = list
				end
			end
		end
	end

	local existedEnemyRanges = {
		{2,IsItemInRange,37727},
		{3,IsItemInRange,42732},
		{4,IsItemInRange,129055},
		{5,IsItemInRange,8149},
		{7,IsItemInRange,61323},
		{8,IsItemInRange,34368},
		{10,IsItemInRange,32321},
		{15,IsItemInRange,33069},
		{20,IsItemInRange,10645},
		{25,IsItemInRange,24268},
		{30,IsItemInRange,835},
		{35,IsItemInRange,24269},
		{38,IsItemInRange,140786},
		{40,IsItemInRange,28767},
		{45,IsItemInRange,23836},
		{50,IsItemInRange,116139},
		{55,IsItemInRange,74637},
		{60,IsItemInRange,32825},
		{70,IsItemInRange,41265},
		{80,IsItemInRange,35278},
		{90,IsItemInRange,133925},
		{100,IsItemInRange,33119},
		{150,IsItemInRange,46954},
		{200,IsItemInRange,75208},
	}

	function module:TriggerMobsInRange(triggers)
		for i=1,#triggers do
			local trigger = triggers[i]
			local triggerData = trigger._trigger
			if 
				triggerData.bwtimeleft and
				trigger.Dstacks and
				triggerData.targetUnit
			then
				local rangeData
				local rangesArr = existedEnemyRanges
				if not UnitPosition'player' then
					rangesArr = existedRangesRaid
				end
				for j=1,#rangesArr do
					if triggerData.bwtimeleft <= rangesArr[j][1] then
						rangeData = rangesArr[j]
						break
					end
				end

				for k,v in pairs(trigger.statuses) do
					v.subCheck = nil
				end

				local inRange = 0
				local list = ""
				if rangeData then
					local units = triggerData.targetUnit
					if type(units) == "number" then
						if units < 0 then
							units = module.datas.unitsList.ALL
						else
							units = module.datas.unitsList[units]
						end
					end

					if units then
						for _,unit in module.IterateTable(units) do
							local guid = UnitGUID(unit)
							if guid and module:CheckUnit(triggerData.targetUnit,guid,trigger) then
								if rangeData[2](rangeData[3],unit) then
									inRange = inRange + 1
									list = list .. (UnitName(unit) or unit) .. "|r, "

									local name = UnitName(unit)
									local mark = GetRaidTargetIndex(unit) or 0

									local check = 
										module:CheckNumber(trigger.Dstacks,inRange) and
										(not trigger.DtargetName or name and trigger.DtargetName[name]) and
										(not trigger.DtargetID or trigger.DtargetID(guid)) and
										(not triggerData.targetMark or mark == triggerData.targetMark) 

									if not trigger.statuses[guid] and check then
										local vars = {
											list = list,
											value = inRange,
											guid = guid,
											targetName = name,
											targetMark = mark,
										}
										trigger.statuses[guid] = vars
										module:RunTrigger(trigger, vars)
									elseif trigger.statuses[guid] and not check then
										trigger.statuses[guid] = nil
										module:DeactivateTrigger(trigger, guid)
									end

									if trigger.statuses[guid] then
										trigger.statuses[guid].subCheck = true
									end
								end
							end
						end
						if #list > 0 then
							list = list:sub(1,-3)
						end
					end
				end

				for k,v in pairs(trigger.statuses) do
					if not v.subCheck then
						trigger.statuses[k] = nil
						module:DeactivateTrigger(trigger, k)
					else
						v.value = inRange
						v.list = list
					end
				end
			end
		end
	end
end

function module:TriggerCast(unit,triggers,spellID,isStart,endTime)
	local guid = UnitGUID(unit)
	local name = UnitName(unit)
	local spellName = GetSpellInfo(spellID)
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger
		if 
			(not triggerData.spellID or spellID == triggerData.spellID) and
			(not triggerData.spellName or spellName == triggerData.spellName) and
			(not trigger.DsourceName or name and trigger.DsourceName[name]) and
			(not trigger.DsourceID or guid and trigger.DsourceID(guid)) and
			(not triggerData.sourceMark or (GetRaidTargetIndex(unit) or 0) == triggerData.sourceMark)
		then
			if not trigger.statuses[guid] and isStart then
				trigger.countsS[guid] = (trigger.countsS[guid] or 0) + 1
				module:AddTriggerCounter(trigger,trigger.countsS[guid])
				local vars = {
					sourceName = name,
					sourceMark = GetRaidTargetIndex(unit),
					guid = guid,
					counter = trigger.count,
					spellID = spellID,
					spellName = spellName,
					timeLeft = endTime,
				}
				trigger.statuses[guid] = vars
				trigger.units[guid] = unit
				if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
					module:RunTrigger(trigger, vars)
				end
			elseif trigger.statuses[guid] and not isStart then
				trigger.statuses[guid] = nil
				trigger.units[guid] = nil

				module:DeactivateTrigger(trigger,guid)
			end
		end
	end
end

function module.main:UNIT_SPELLCAST_START(unit,castGUID,spellID)
	local triggers = tUNIT_CAST[unit]
	if triggers then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, interruptible, spellId = UnitCastingInfo(unit)
		module:TriggerCast(unit,triggers,spellID,true,(endTime or 0)/1000)
	end
end

function module.main:UNIT_SPELLCAST_CHANNEL_START(unit,castGUID,spellID)
	local triggers = tUNIT_CAST[unit]
	if triggers then
		local name, text, texture, startTime, endTime, isTradeSkill, interruptible, spellId = UnitChannelInfo(unit)
		module:TriggerCast(unit,triggers,spellID,true,(endTime or 0)/1000)
	end
end

function module.main:UNIT_SPELLCAST_STOP(unit,castGUID,spellID)
	local triggers = tUNIT_CAST[unit]
	if triggers then
		module:TriggerCast(unit,triggers,spellID,false)
	end
end

function module.main:UNIT_SPELLCAST_CHANNEL_STOP(unit,castGUID,spellID)
	local triggers = tUNIT_CAST[unit]
	if triggers then
		module:TriggerCast(unit,triggers,spellID,false)
	end
end

function module.main:UNIT_CAST_CHECK(unit)
	local name, text, texture, startTime, endTime, isTradeSkill, castID, interruptible, spellId = UnitCastingInfo(unit)
	if name then
		local triggers = tUNIT_CAST[unit]
		if triggers then
			module:TriggerCast(unit,triggers,spellId,true,(endTime or 0)/1000)
		end
	else
		local name, text, texture, startTime, endTime, isTradeSkill, interruptible, spellId = UnitChannelInfo(unit)
		if name then
			local triggers = tUNIT_CAST[unit]
			if triggers then
				module:TriggerCast(unit,triggers,spellId,true,(endTime or 0)/1000)
			end
		end
	end
end

function module:CycleAllUnitEvents(unit)
	if UnitGUID(unit) then
		if tUNIT_HEALTH then module.main:UNIT_HEALTH(unit) end
		if tUNIT_POWER_FREQUENT then module.main:UNIT_POWER_FREQUENT(unit) end
		if tUNIT_ABSORB_AMOUNT_CHANGED then module.main:UNIT_ABSORB_AMOUNT_CHANGED(unit) end
		if tUNIT_AURA then module.main:UNIT_AURA(unit) end
		if tUNIT_TARGET then module.main:UNIT_TARGET(unit) end
		if tUNIT_CAST then module.main:UNIT_CAST_CHECK(unit) end
	end
end


function module:TriggerUnitRemovedLookup(unit,triggers,guid)
	guid = guid or UnitGUID(unit)
	for i=1,#triggers do
		local trigger = triggers[i]

		if trigger.statuses[guid] then
			trigger.statuses[guid] = nil
			trigger.units[guid] = nil
			module:DeactivateTrigger(trigger,guid)
		end
	end
end

do
	local tablesList = {"UNIT_HEALTH","UNIT_POWER_FREQUENT","UNIT_ABSORB_AMOUNT_CHANGED","UNIT_TARGET","UNIT_AURA","UNIT_CAST"}
	function module:CycleAllUnitEvents_UnitRefresh(unit)
		for _,e in pairs(tablesList) do
			if module.db.eventsToTriggers[e] then 
				local triggers = module.db.eventsToTriggers[e][unit]
				if triggers then
					for i=1,#triggers do
						local trigger = triggers[i]

						module:CheckUnitTriggerStatus(trigger)
					end
				end
			end
		end
	end

	function module:CycleAllUnitEvents_UnitRemoved(unit, guid)
		for _,e in pairs(tablesList) do
			if module.db.eventsToTriggers[e] then 
				local triggers = module.db.eventsToTriggers[e][unit]
				if triggers then
					module:TriggerUnitRemovedLookup(unit,triggers,guid)
				end
			end
		end
	end
end

do
	local scheduled = nil
	local function scheduleFunc()
		scheduled = nil
		for _,unit in pairs(module.datas.unitsList[1]) do
			module:CycleAllUnitEvents(unit)
		end
		for _,unit in pairs(module.datas.unitsList[2]) do
			module:CycleAllUnitEvents(unit)
		end
		for _,unit in pairs(module.datas.unitsList[3]) do
			module:CycleAllUnitEvents(unit)
		end
		for _,unit in pairs(module.datas.unitsList[4]) do
			module:CycleAllUnitEvents(unit)
		end
	end
	function module.main:RAID_TARGET_UPDATE()
		if not scheduled then
			scheduled = C_Timer.NewTimer(0.05,scheduleFunc)
		end
	end
end

do
	local prev
	function module.main:PLAYER_TARGET_CHANGED()
		local guid = UnitGUID("target")
		if guid then
			module:CycleAllUnitEvents("target")
			prev = guid
		else
			module:CycleAllUnitEvents_UnitRemoved("target", prev)
			prev = nil
		end
	end
end

do
	local prev
	function module.main:PLAYER_FOCUS_CHANGED()
		local guid = UnitGUID("focus")
		if guid then
			module:CycleAllUnitEvents("focus")
			prev = guid
		else
			module:CycleAllUnitEvents_UnitRemoved("focus", prev)
			prev = nil
		end
	end
end

do
	local prev
	local mouseoverframe = CreateFrame("Frame")
	local function mouseoverframe_onupdate()
		local guid = UnitGUID("mouseover")
		if not guid then
			mouseoverframe:SetScript("OnUpdate",nil)
			module:CycleAllUnitEvents_UnitRemoved("mouseover", prev)
			prev = nil
		end
	end
	function module.main:UPDATE_MOUSEOVER_UNIT()
		local guid = UnitGUID("mouseover")
		if guid then
			module:CycleAllUnitEvents("mouseover")
			prev = guid
			mouseoverframe:SetScript("OnUpdate",mouseoverframe_onupdate)
		end
	end
end

function module.main:NAME_PLATE_UNIT_ADDED(unit)
	module:CycleAllUnitEvents(unit)
	local guid = UnitGUID(unit)
	if guid then
		module.db.nameplateGUIDToUnit[guid] = unit
		local data = module.db.nameplateHL[guid]
		if data then
			module:NameplateUpdateForUnit(unit, guid, data)
		end
	end
end

function module.main:NAME_PLATE_UNIT_REMOVED(unit)
	module:CycleAllUnitEvents_UnitRemoved(unit)
	local guid = UnitGUID(unit)
	if guid then
		module.db.nameplateGUIDToUnit[guid] = nil
		module:NameplateHideForGUID(guid)
	end
end

function module:NameplatesReloadCycle()
	for _,unit in pairs(module.datas.unitsList[2]) do
		if UnitGUID(unit) then
			module.main:NAME_PLATE_UNIT_ADDED(unit)
		end
	end
end

function module:NameplateUpdateForUnit(unit, guid, guidTable)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if not nameplate then
		return
	end
	module:NameplateHideForGUID(guid)
	if guidTable then
		for uid,data in pairs(guidTable) do
			local frame = module:GetNameplateFrame(nameplate,data.text,data.textUpdateReq,data.color,data.noEdge,data.thick,data.type,data.customN,data.scale,data.textSize,data.posX,data.posY,data.pos,data.glowImage)
			module.db.nameplateGUIDToFrames[guid] = frame
			break
		end
	end
end

function module:NameplateHideForGUID(guid)
	local frame = module.db.nameplateGUIDToFrames[guid]
	if frame then
		frame:Hide()
		module.db.nameplateGUIDToFrames[guid] = nil
	end
end

function module:NameplateAddHighlight(guid,data,params)
	if module.db.nameplateHL[guid] and module.db.nameplateHL[guid][data and data.uid or 1] then
		return
	end
	local t = {
		data = data,
	}
	if data and data.msg then
		local text = data.msg

		if text:find("%%tsize:%d+") then
			local tsize = text:match("%%tsize:(%d+)")
			t.textSize = tonumber(tsize)
			text = text:gsub("%%tsize:%d+","")
		end

		if text:find("%%tposx:%-?%d+") then
			local posX = text:match("%%tposx:(%-?%d+)")
			t.posX = tonumber(posX)
			text = text:gsub("%%tposx:%-?%d+","")
		end

		if text:find("%%tposy:%-?%d+") then
			local posY = text:match("%%tposy:(%-?%d+)")
			t.posY = tonumber(posY)
			text = text:gsub("%%tposy:%-?%d+","")
		end

		if text:find("%%tpos:%d+") then
			local pos = text:match("%%tpos:(%d+)")
			t.pos = tonumber(pos)
			text = text:gsub("%%tpos:%d+","")
		end

		t.text, t.textUpdateReq = module:FormatMsg(text,params)
		if t.textUpdateReq and not data.dynamicdisable then
			t.textUpdateReq = function()
				return module:FormatMsg(text,params)
			end
		else
			t.textUpdateReq = nil
		end
	end
	if data and data.glowType then
		t.type = data.glowType
	end
	if data and data.glowScale then
		t.scale = data.glowScale
	end
	if data and data.glowN then
		t.customN = data.glowN
	end
	if data and data.glowThick then
		t.thick = data.glowThick
	end
	if data and data.glowColor then
		local a,r,g,b = data.glowColor:match("(..)(..)(..)(..)")
		if r and g and b and a then
			a,r,g,b = tonumber(a,16),tonumber(r,16),tonumber(g,16),tonumber(b,16)
			t.color = {r/255,g/255,b/255,a/255}
		end
	end
	if data and data.glowImage then
		t.glowImage = data.glowImage
	end
	if data and data.msgSize == 7 then
		t.noEdge = true
	end
	if not module.db.nameplateHL[guid] then
		module.db.nameplateHL[guid] = {}
	end
	module.db.nameplateHL[guid][data and data.uid or 1] = t
	local unit = module.db.nameplateGUIDToUnit[guid]
	if unit then
		module:NameplateUpdateForUnit(unit, guid, module.db.nameplateHL[guid])
	end
end

function module:NameplateRemoveHighlight(guid, uid)
	module:NameplateHideForGUID(guid)
	local hl_data = module.db.nameplateHL[guid]
	if hl_data then
		for c_uid,data in pairs(hl_data) do
			if not uid or c_uid == uid then
				hl_data[c_uid] = nil
			end
		end
	end
	local unit = module.db.nameplateGUIDToUnit[guid]
	if unit then
		module:NameplateUpdateForUnit(unit, guid, hl_data)
	end
end

local function NameplateFrame_OnUpdate(self)
	if GetTime() > self.expirationTime then
		self:Hide()
	end
end
local function NameplateFrame_SetExpiration(self,expirationTime)
	self.expirationTime = expirationTime
	self:SetScript("OnUpdate",NameplateFrame_OnUpdate)
end
local function NameplateFrame_OnHide(self)
	local LCG = LibStub("LibCustomGlow-1.0",true)
	if LCG then
		LCG.ButtonGlow_Stop(self)
		LCG.AutoCastGlow_Stop(self)
		LCG.PixelGlow_Stop(self)
	end 
	self.textUpate:Hide()
	self.textUpate.tmr = 0

	self.aim1:Hide()
	self.aim2:Hide()
	self.imgabove:Hide()

	self:SetScript("OnUpdate",nil)
end

local function NameplateFrame_TextUpdate(self, elapsed)
	self.tmr = self.tmr + elapsed
	if self.tmr > 0.03 then
		self.tmr = 0
		self.text:SetText( self.func() )
	end
end

local function NameplateFrame_OnScaleCheck(self,elapsed)
	self.tmr = self.tmr - elapsed
	if self.tmr <= 0 then
		self:SetScript("OnUpdate",nil)
	end
	local p = self:GetParent()
	local s1,s2 = p:GetSize()
	if p.s1 ~= s1 or p.s2 ~= s2 then
		p.s1,p.s2 = s1,s2
		p:UpdateGlow()
	end
end
local function NameplateFrame_OnShow(self)
	if not self.frameNP then
		return
	end
	if not self.scalecheck then
		self.scalecheck = CreateFrame("Frame",nil,self)
		self.scalecheck:SetPoint("TOPLEFT",0,0)
		self.scalecheck:SetSize(1,1)
	end
	self.scalecheck.tmr = 1
	if self.glow_customGlowType == 7 then
		self.scalecheck.tmr = 10000
	end
	self.scalecheck:SetScript("OnUpdate",NameplateFrame_OnScaleCheck)
end

local function NameplateFrame_UpdateGlow(frame)
	local color,noEdge,customThick,customGlowType,customN,customScale,glowImage = frame.glow_color,frame.glow_noEdge,frame.glow_customThick,frame.glow_customGlowType,frame.glow_customN,frame.glow_customScale,frame.glow_glowImage

	local LCG = LibStub("LibCustomGlow-1.0",true)
	if noEdge then
		return
	end

	local glowType = customGlowType or VMRT.Reminder2.NameplateGlowType
	if glowType == 2 then
		if not LCG then return end
		LCG.ButtonGlow_Start(frame,color)
	elseif glowType == 3 then
		if not LCG then return end
		LCG.AutoCastGlow_Start(frame,color,customN,nil,customScale or 1)
	elseif glowType == 4 then
		if color then
			frame.aim1:SetVertexColor(unpack(color))
			frame.aim2:SetVertexColor(unpack(color))
		else
			frame.aim1:SetVertexColor(1,1,1,1)
			frame.aim2:SetVertexColor(1,1,1,1)
		end
		if customThick then
			frame.aim1:SetWidth(customThick)
			frame.aim2:SetHeight(customThick)
		else
			frame.aim1:SetWidth(2)
			frame.aim2:SetHeight(2)
		end
		frame.aim1:Show()
		frame.aim2:Show()
	elseif glowType == 5 then
		if color then
			frame.solid:SetColorTexture(unpack(color))
		else
			frame.solid:SetColorTexture(1,1,1,1)
		end		
		frame.solid:Show()
	elseif glowType == 6 then
		local imgData = module.datas.glowImagesData[glowImage or 0]
		if imgData or type(glowImage)=='string' then
			if imgData then
				frame.imgabove:SetTexture(imgData[3])
				frame.imgabove:SetSize((imgData[4] or 80)*(customScale or 1),(imgData[5] or 80)*(customScale or 1))
				if imgData[6] then
					frame.imgabove:SetTexCoord(unpack(imgData[6]))
				else
					frame.imgabove:SetTexCoord(0,1,0,1)
				end
			else
				frame.imgabove:SetSize(80*(customScale or 1),80*(customScale or 1))
				if type(glowImage)=='string' and glowImage:find("^A:") then
					frame.imgabove:SetTexCoord(0,1,0,1)
					frame.imgabove:SetAtlas(glowImage:sub(3))
				else
					frame.imgabove:SetTexture(glowImage)
					frame.imgabove:SetTexCoord(0,1,0,1)
				end
			end
			if color then
				frame.imgabove:SetVertexColor(unpack(color))
			else
				frame.imgabove:SetVertexColor(1,1,1,1)
			end		
			frame.imgabove:Show()
		end
	elseif glowType == 7 then
		customN = customN or 100
		frame.hpline:SetPoint("LEFT",customN/100*frame:GetWidth(),0)
		if color then
			frame.hpline:SetColorTexture(unpack(color))
		else
			frame.hpline:SetColorTexture(1,1,1,1)
		end
		frame.hpline.hp = customN/100
		frame.hpline:SetWidth(customThick or 3)
		frame.hpline:Show()
	else
		if not LCG then return end
		local thick = customThick or VMRT.Reminder2.NameplateThick
		thick = tonumber(thick or 2)
		thick = floor(thick)
		LCG.PixelGlow_Start(frame,color,customN,nil,nil,thick,1,1) 
	end
end

function module:GetNameplateFrame(nameplate,text,textUpdateReq,color,noEdge,customThick,customGlowType,customN,customScale,textSize,posX,posY,pos,glowImage)
	local frame
	for i=1,#module.db.nameplateFrames do
		if not module.db.nameplateFrames[i]:IsShown() then
			frame = module.db.nameplateFrames[i]
			break
		end
	end
	if not frame then
		frame = CreateFrame("Frame",nil,UIParent)
		module.db.nameplateFrames[#module.db.nameplateFrames+1] = frame
		frame:Hide()
		frame:SetScript("OnHide",NameplateFrame_OnHide)
		frame.SetExpiration = NameplateFrame_SetExpiration
		frame:SetScript("OnShow",NameplateFrame_OnShow)
		frame.UpdateGlow = NameplateFrame_UpdateGlow

		frame.text = frame:CreateFontString(nil,"ARTWORK")
		frame.text:SetPoint("BOTTOMLEFT",frame,"TOPLEFT",2,2)
		frame.text:SetFont(ExRT.F.defFont, 12, "OUTLINE")
		--frame.text:SetShadowOffset(1,-1)
		frame.text:SetTextColor(1,1,1,1)
		frame.text.size = 12

		frame.textUpate = CreateFrame("Frame",nil,frame)
		frame.textUpate:SetPoint("CENTER")
		frame.textUpate:SetSize(1,1)
		frame.textUpate:Hide()
		frame.textUpate.tmr = 0
		frame.textUpate.text = frame.text
		frame.textUpate:SetScript("OnUpdate",NameplateFrame_TextUpdate)

		frame.aim1 = frame:CreateTexture(nil, "ARTWORK")
		frame.aim1:SetColorTexture(1,1,1,1)
		frame.aim1:SetPoint("CENTER")
		frame.aim1:SetSize(2,3000)
		frame.aim1:Hide()
		frame.aim2 = frame:CreateTexture(nil, "ARTWORK")
		frame.aim2:SetColorTexture(1,1,1,1)
		frame.aim2:SetPoint("CENTER")
		frame.aim2:SetSize(3000,2)
		frame.aim2:Hide()

		frame.imgabove = frame:CreateTexture(nil, "ARTWORK")
		frame.imgabove:SetPoint("BOTTOM",frame,"TOP",0,1)
		frame.imgabove:Hide()

		frame.solid = frame:CreateTexture(nil,"ARTWORK")
		frame.solid:SetAllPoints()
		frame.solid:Hide()

		frame.hpline = frame:CreateTexture(nil,"ARTWORK")
		frame.hpline:SetPoint("TOP")
		frame.hpline:SetPoint("BOTTOM")
		frame.hpline:Hide()
	end
	local frameNP = (nameplate.unitFramePlater and nameplate.unitFramePlater.healthBar) or (nameplate.unitFrame and nameplate.unitFrame.Health) or (nameplate.UnitFrame and nameplate.UnitFrame.healthBar) or nameplate
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT",frameNP,0,0)
	frame:SetPoint("BOTTOMRIGHT",frameNP,0,0)
	frame:SetFrameStrata( nameplate:GetFrameStrata() )
	frame.solid:Hide()
	frame.hpline:Hide()
	frame.frameNP = frameNP

	frame.s1,frame.s2 = frame:GetSize()

	if textSize and frame.text.size ~= textSize then
		frame.text:SetFont(ExRT.F.defFont, textSize, "OUTLINE")
		frame.text.size = textSize
	elseif not textSize and frame.text.size ~= 12 then
		frame.text:SetFont(ExRT.F.defFont, 12, "OUTLINE")
		frame.text.size = 12
	end

	posX = posX or 2
	posY = posY or 2
	pos = pos or 1
	if frame.text.posX ~= posX or frame.text.posY ~= posY or frame.text.pos ~= pos then
		frame.text.posX = posX
		frame.text.posY = posY
		frame.text.pos = pos
		local anchor1, anchor2 = "BOTTOMLEFT", "TOPLEFT"
		if pos == 2 then
			anchor1, anchor2 = "BOTTOM", "TOP"
		elseif pos == 3 then
			anchor1, anchor2 = "BOTTOMRIGHT", "TOPRIGHT"
		elseif pos == 4 then
			anchor1, anchor2 = "LEFT", "RIGHT"
		elseif pos == 5 then
			anchor1, anchor2 = "TOPRIGHT", "BOTTOMRIGHT"
		elseif pos == 6 then
			anchor1, anchor2 = "TOP", "BOTTOM"
		elseif pos == 7 then
			anchor1, anchor2 = "TOPLEFT", "BOTTOMLEFT"
		elseif pos == 8 then
			anchor1, anchor2 = "RIGHT", "LEFT"
		elseif pos == 9 then
			anchor1, anchor2 = "CENTER", "CENTER"
		end
		frame.text:ClearAllPoints()
		frame.text:SetPoint(anchor1,frame,anchor2,posX,posY)
	end

	frame.text:SetText(text or "")
	if textUpdateReq then
		frame.textUpate.func = textUpdateReq
		frame.textUpate:Show()
	else
		frame.textUpate:Hide()
	end

	frame.glow_color = color
	frame.glow_noEdge = noEdge
	frame.glow_customThick = customThick
	frame.glow_customGlowType = customGlowType
	frame.glow_customN = customN
	frame.glow_customScale = customScale
	frame.glow_glowImage = glowImage

	frame:UpdateGlow()

	frame:Show()
	return frame
end

local function RaidFrame_OnHide(self)
	self.textUpate:Hide()
	self.textUpate.tmr = 0

	self.aim1:Hide()
	self.aim2:Hide()
	self.imgabove:Hide()

	self:SetScript("OnUpdate",nil)
end

function module:RaidframeUpdate(frame, guid, guidTable)
	module:RaidframeHideHighlight(guid)
	if guidTable then
		local key = 0
		for uid,data in pairs(guidTable) do
			module.db.frameGUIDToFrames[guid] = frame

			local obj = module.db.frameText[frame]
			if not obj then
				obj = CreateFrame("Frame",nil,frame)
				module.db.frameText[frame] = obj
				obj:SetScript("OnHide",RaidFrame_OnHide)
		
				obj:SetAllPoints()
				obj.text = obj:CreateFontString(nil,"ARTWORK","GameFontWhite")
				obj.text:SetFont(obj.text:GetFont(),12,"OUTLINE")
				obj.text.size = 12
				obj.text:SetAllPoints()
		
				obj.textUpate = CreateFrame("Frame",nil,obj)
				obj.textUpate:SetPoint("CENTER")
				obj.textUpate:SetSize(1,1)
				obj.textUpate:Hide()
				obj.textUpate.tmr = 0
				obj.textUpate.text = obj.text
				obj.textUpate:SetScript("OnUpdate",NameplateFrame_TextUpdate)
		
				obj.aim1 = obj:CreateTexture(nil, "ARTWORK")
				obj.aim1:SetColorTexture(1,1,1,1)
				obj.aim1:SetPoint("CENTER")
				obj.aim1:SetSize(2,3000)
				obj.aim1:Hide()
				obj.aim2 = obj:CreateTexture(nil, "ARTWORK")
				obj.aim2:SetColorTexture(1,1,1,1)
				obj.aim2:SetPoint("CENTER")
				obj.aim2:SetSize(3000,2)
				obj.aim2:Hide()

				obj.imgabove = obj:CreateTexture(nil, "ARTWORK")
				obj.imgabove:SetPoint("CENTER")
				obj.imgabove:Hide()

				obj.solid = obj:CreateTexture(nil,"ARTWORK")
				obj.solid:SetAllPoints()
				obj.solid:Hide()

				obj.hpline = obj:CreateTexture(nil,"ARTWORK")
				obj.hpline:SetPoint("TOP")
				obj.hpline:SetPoint("BOTTOM")
				obj.hpline:Hide()
			end
			if data.text or data.showAnyway then
				if data.textSize ~= obj.text.size then
					obj.text:SetFont(obj.text:GetFont(),data.textSize,"OUTLINE")
					obj.text.size = data.textSize
				end
				obj.text:ClearAllPoints()
				if data.justifyH == "LEFT" then obj.text:SetPoint("LEFT")
					elseif data.justifyH == "RIGHT" then obj.text:SetPoint("RIGHT")
					else obj.text:SetPoint("CENTER") end
				if data.justifyV == "TOP" then obj.text:SetPoint("TOP")
					elseif data.justifyV == "BOTTOM" then obj.text:SetPoint("BOTTOM")
					else obj.text:SetPoint("CENTER") end
				obj.text:SetText(data.text or "")
				obj:Show()
		
				if data.textUpdateReq then
					obj.textUpate.func = data.textUpdateReq
					obj.textUpate:Show()
				else
					obj.textUpate:Hide()
				end
			else
				obj.text:SetText("")
			end

			obj.solid:Hide()
			obj.hpline:Hide()

			local LCG = LibStub("LibCustomGlow-1.0",true)			
			if LCG then
				local glowType = data.customType or VMRT.Reminder2.FrameGlowType
				if glowType == 2 then
					LCG.ButtonGlow_Start(frame,data.color)
				elseif glowType == 3 then
					LCG.AutoCastGlow_Start(frame,data.color,data.customN,nil,data.customScale)
				elseif glowType == 4 then
					if data.color then
						obj.aim1:SetVertexColor(unpack(data.color))
						obj.aim2:SetVertexColor(unpack(data.color))
					else
						obj.aim1:SetVertexColor(1,1,1,1)
						obj.aim2:SetVertexColor(1,1,1,1)
					end
					if data.thick then
						obj.aim1:SetWidth(data.thick)
						obj.aim2:SetHeight(data.thick)
					else
						obj.aim1:SetWidth(2)
						obj.aim2:SetHeight(2)
					end
					obj.aim1:Show()
					obj.aim2:Show()
					obj:Show()
				elseif glowType == 5 then
					if data.color then
						obj.solid:SetColorTexture(unpack(data.color))
					else
						obj.solid:SetColorTexture(1,1,1,1)
					end		
					obj.solid:Show()
					obj:Show()
				elseif glowType == 6 then
					local imgData = module.datas.glowImagesData[data.glowImage or 0]
					if imgData or type(data.glowImage)=='string' then
						local width,height = frame:GetSize()
						local size = min(width,height)
						if imgData then
							obj.imgabove:SetTexture(imgData[3])
							local iwidth,iheight = imgData[4],imgData[5]
							if iwidth and iheight then
								if iwidth > iheight then
									iwidth = size * (iheight / iwidth)
									iheight = size
								else
									iwidth = size
									iheight = size * (iheight / iwidth)
								end
							end
							obj.imgabove:SetSize((iwidth or size)*(data.customScale or 1),(iheight or size)*(data.customScale or 1))
							if imgData[6] then
								obj.imgabove:SetTexCoord(unpack(imgData[6]))
							else
								obj.imgabove:SetTexCoord(0,1,0,1)
							end
						else
							obj.imgabove:SetSize(size*(data.customScale or 1),size*(data.customScale or 1))
							if type(data.glowImage)=='string' and data.glowImage:find("^A:") then
								obj.imgabove:SetTexCoord(0,1,0,1)
								obj.imgabove:SetAtlas(data.glowImage:sub(3))
							else
								obj.imgabove:SetTexture(data.glowImage)
								obj.imgabove:SetTexCoord(0,1,0,1)
							end
						end
						if data.color then
							obj.imgabove:SetVertexColor(unpack(data.color))
						else
							obj.imgabove:SetVertexColor(1,1,1,1)
						end		
						obj.imgabove:Show()
						obj:Show()
					end
				elseif glowType == 7 then
					local customN = data.customN or 100
					obj.hpline:SetPoint("LEFT",customN/100*frame:GetWidth(),0)
					if data.color then
						obj.hpline:SetColorTexture(unpack(data.color))
					else
						obj.hpline:SetColorTexture(1,1,1,1)
					end
					obj.hpline:SetWidth(data.thick or 3)
					obj.hpline:Show()
					obj:Show()
				else
					local thick = floor(tonumber(data.thick or VMRT.Reminder2.FrameThick or 1))
					key = key + 1
					LCG.PixelGlow_Start(frame,data.color,data.customN,nil,nil,data.thick,1,1,nil,tostring(key)) 
				end
			end


			--multi temp fix
			--break
		end
	end
end

function module:RaidframeHideHighlight(guid)
	local frame = module.db.frameGUIDToFrames[guid]
	if frame then
		local LCG = LibStub("LibCustomGlow-1.0",true)
		if LCG then
			LCG.ButtonGlow_Stop(frame)
			LCG.AutoCastGlow_Stop(frame)
			LCG.PixelGlow_Stop(frame)

			local key = 1
			while frame["_PixelGlow"..key] do
				LCG.PixelGlow_Stop(frame,tostring(key))
				key = key + 1
			end
		end
	
		if module.db.frameText[frame] then
			module.db.frameText[frame]:Hide()
		end

		module.db.frameGUIDToFrames[guid] = nil
	end
end


local LGFNullOpt = {}
function module:FrameAddHighlight(guid,data,params)
	if module.db.frameHL[guid] and module.db.frameHL[guid][data and data.uid or 1] then
		return
	end
	local LGF = LibStub("LibGetFrame-1.0", true)
	if not LGF then
		return
	end
	local frame = LGF.GetFrame(guid, LGFNullOpt)
	if not frame then
		return
	end
	local t = {
		data = data,
		textSize = 12,
		customScale = 2,
	}
	if data and data.msg then
		local text = data.msg

		if text:find("%%tsize:%d+") then
			local tsize = text:match("%%tsize:(%d+)")
			t.textSize = tonumber(tsize)
			text = text:gsub("%%tsize:%d+","")
		end

		if text:find("%%tpos:..") then
			local posH,posV = text:match("%%tpos:(.)(.)")
			if posH == "L" then t.justifyH = "LEFT" 
				elseif posH == "C" then t.justifyH = "CENTER" 
				elseif posH == "R" then t.justifyH = "RIGHT" end
			if posV == "T" then t.justifyV = "TOP" 
				elseif posV == "M" then t.justifyV = "MIDDLE" 
				elseif posV == "B" then t.justifyV = "BOTTOM" end
			text = text:gsub("%%tpos:..","")
		end

		local textPreFormat = text
		t.text, t.textUpdateReq = module:FormatMsg(text,params)
		if t.textUpdateReq and not data.dynamicdisable then
			t.textUpdateReq = function()
				return module:FormatMsg(textPreFormat,params)
			end
		else
			t.textUpdateReq = nil
		end
	end

	if data and data.glowType then
		t.customType = data.glowType
	end
	if data and data.glowScale then
		t.customScale = data.glowScale
	elseif t.customType == 6 then
		t.customScale = 1	--fix default scale for image type
	end
	if data and data.glowN then
		t.customN = data.glowN
	end
	if data and data.glowThick then
		t.thick = data.glowThick
	end
	if data and data.glowColor then
		local a,r,g,b = data.glowColor:match("(..)(..)(..)(..)")
		if r and g and b and a then
			a,r,g,b = tonumber(a,16),tonumber(r,16),tonumber(g,16),tonumber(b,16)
			t.color = {r/255,g/255,b/255,a/255}
		end
	end
	if data and data.glowImage then
		t.glowImage = data.glowImage
	end

	if t.customType == 6 or t.customType == 5 or t.customType == 4 then
		t.showAnyway = true
	end

	if not module.db.frameHL[guid] then
		module.db.frameHL[guid] = {}
	end
	module.db.frameHL[guid][data and data.uid or 1] = t

	module:RaidframeUpdate(frame, guid, module.db.frameHL[guid])
end

function module:FrameRemoveHighlight(guid, uid)
	local hl_data = module.db.frameHL[guid]
	if hl_data then
		for c_uid,data in pairs(hl_data) do
			if not uid or c_uid == uid then
				hl_data[c_uid] = nil
			end
		end
	end
	local frame = module.db.frameGUIDToFrames[guid]
	if frame then
		module:RaidframeUpdate(frame, guid, hl_data)
	end
end

function module:AddHistoryRecord(eventType, ...)
	module.db.historyNow[#module.db.historyNow+1] = {
		GetTime(),
		eventType,
		...
	}
end


function module:SetProfile(profile)
	VMRT.Reminder2.Profile = profile
	if module.options.profileDropDown then
		module.options.profileDropDown:SetText(profiles[VMRT.Reminder2.Profile])
	end
	CURRENT_DATA = VMRT.Reminder2.data[VMRT.Reminder2.Profile]

	if module.options.UpdateData then
		module.options:UpdateData()
		module.options.scrollList:ResetScroll()
	end
	
	if VMRT.Reminder2.enabled then
		module:ReloadAll()
	end
end

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	VMRT.Reminder2 = VMRT.Reminder2 or {
		--enabled = true,
		FontOutline = true,
		HistoryEnabled = true,
		FontSize = 50,
		["generalSound1"] = "Interface\\AddOns\\MRT\\media\\Sounds\\CatMeow2.ogg",
		["generalSound2"] = "Interface\\AddOns\\MRT\\media\\Sounds\\KittenMeow.ogg",
		["generalSound3"] = "Interface\\Addons\\MRT\\media\\Sounds\\swordecho.ogg",
		["generalSound4"] = "Interface\\AddOns\\MRT\\media\\Sounds\\Applause.ogg",
		["generalSound5"] = "Interface\\AddOns\\MRT\\media\\Sounds\\BikeHorn.ogg",
		["generalSound6"] = "Interface\\Addons\\MRT\\media\\Sounds\\bam.ogg",
		HistoryFrameShown = true,
		v21 = true,
		v38 = true,
	}
	VMRT.Reminder2.data = VMRT.Reminder2.data or {}
	VMRT.Reminder2.options = VMRT.Reminder2.options or {}
	VMRT.Reminder2.removed = VMRT.Reminder2.removed or {}
	VMRT.Reminder2.zoneNames = VMRT.Reminder2.zoneNames or {}

	if VMRT.Reminder2.HistorySession then
		module.db.history = VMRT.Reminder2.history or {{}}
		VMRT.Reminder2.history = module.db.history
	else
		module.db.history = {{}}
		VMRT.Reminder2.history = nil
	end

	if not VMRT.Reminder2.v21 then
		local new = {}
		for uid,options in pairs(VMRT.Reminder2.options) do
			local check = 0
			if bit.band(options,0x1) > 0 then check = bit.bor(check,bit.lshift(1,0)) end
			if bit.band(options,0x10) > 0 then check = bit.bor(check,bit.lshift(1,1)) end
			if bit.band(options,0x100) > 0 then check = bit.bor(check,bit.lshift(1,2)) end
			if bit.band(options,0x1000) > 0 then check = bit.bor(check,bit.lshift(1,3)) end
			if bit.band(options,0x10000) > 0 then check = bit.bor(check,bit.lshift(1,4)) end
			if check > 0 then
				new[uid] = check
			end
		end
		VMRT.Reminder2.options = new
		VMRT.Reminder2.v21 = true
	end

	if not VMRT.Reminder2.Profile then
		VMRT.Reminder2.Profile = 1
	end

	if not VMRT.Reminder2.v38 then
		VMRT.Reminder2.data = {[1] = VMRT.Reminder2.data}
		VMRT.Reminder2.v38 = true
	end
	for k in pairs(profiles) do
		if not VMRT.Reminder2.data[k] then
			VMRT.Reminder2.data[k] = {}
		end
	end

	CURRENT_DATA = VMRT.Reminder2.data[VMRT.Reminder2.Profile] or VMRT.Reminder2.data[1]

	VMRT.Reminder2.SyncPlayers = VMRT.Reminder2.SyncPlayers or {}

	module:UpdateVisual()
	module:RegisterAddonMessage()
	module:RegisterSlash()

	if VMRT.Reminder2.enabled then
		module:Enable()
	end
end

do
	local scheduledUpdate
	local prevZoneID
	function module:LoadForCurrentZone()
		scheduledUpdate = nil
		if module.db.encounterID then
			return
		end
		local zoneName, _, _, _, _, _, _, zoneID = GetInstanceInfo()
		if zoneID ~= prevZoneID then
			prevZoneID = zoneID
			module:LoadReminders(nil,nil,zoneID,zoneName)
		end
	end
	function module.main:ZONE_CHANGED_NEW_AREA()
		if not scheduledUpdate then
			scheduledUpdate = ScheduleTimer(module.LoadForCurrentZone,1)
		end
	end
	function module:ResetPrevZone()
		prevZoneID = nil
	end
end

function module.main:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
	module.db.encounterID = encounterID
	module.db.lastEncounterID = encounterID
	module.db.encounterPullTime = GetTime()

	local zoneName, _, _, _, _, _, _, zoneID = GetInstanceInfo()
	module:LoadReminders(encounterID, difficultyID, zoneID, zoneName)

	if VMRT.Reminder2.HistoryEnabled then
		IsHistoryEnabled = true
	else
		IsHistoryEnabled = false
	end

	if (module.db.eventsToTriggers.BOSS_START or module.db.eventsToTriggers.NOTE_TIMERS or module.db.eventsToTriggers.NOTE_TIMERS_ALL) and not module.db.nextPullIsDelayed then
		module:TriggerBossPull(encounterID, encounterName)
	end
	if module.db.eventsToTriggers.BOSS_PHASE and not module.db.nextPullIsDelayed then
		module:TriggerBossPhase("1")
	end
	if module.db.eventsToTriggers.PARTY_UNIT then
		module.main:GROUP_ROSTER_UPDATE()
	end

	module.db.nextPullIsDelayed = nil
end

function module.main:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize)
	module.db.encounterID = nil

	if IsHistoryEnabled then
		module:AddHistoryRecord(0)


		local enoughLength
		if #module.db.historyNow > 1 and (module.db.historyNow[#module.db.historyNow][1] - module.db.historyNow[1][1]) >= 30 then
			enoughLength = true
		end
		if enoughLength then
			tinsert(module.db.history,1,module.db.historyNow)
		end
		module.db.historyNow = {}
		for i=(VMRT.Reminder2.HistoryNumSaved or 1)+1,#module.db.history do
			module.db.history[i] = nil
		end
	end

	IsHistoryEnabled = false

	module:ResetPrevZone()
	module:LoadForCurrentZone()

	if VMRT.Reminder2.HistoryEnabled and false then	---temp disabled
		module.db.sendHistoryByMe = true
		ExRT.F.ScheduleTimer(ExRT.F.SendExMsg, 0.1, "rmd","H\t2\t"..addonVersion)
		C_Timer.After(5,function()
			if not module.db.sendHistoryByMe then
				return
			end

			local str = module.options:GetHistoryString(true)

			if not str or #str > 500000 then
				return
			end
			local compressed = LibDeflate:CompressDeflate(str,{level = 5})
			if not compressed then
				return
			end

			local encoded = "EXRTREMH1"..LibDeflate:EncodeForPrint(compressed).."##F##"

			local parts = ceil(#encoded / 246)
			for i=1,parts do
				local msg = encoded:sub( (i-1)*246+1 , i*246 )
				ExRT.F.SendExMsg("rmd","H\t1\t"..msg)
			end
		end)
	end
end

function module:ReloadAll()
	module:ResetPrevZone()
	module:LoadForCurrentZone()
end

do
	local helpTable = {}
	function module.IterateTable(t)
		if type(t) == "table" then
			return next, t
		else
			helpTable[1] = t
			return next, helpTable
		end
	end
end

function module:UnloadAll()
	module:UnregisterEvents(
		"NAME_PLATE_UNIT_ADDED","NAME_PLATE_UNIT_REMOVED","RAID_TARGET_UPDATE",
		"PLAYER_TARGET_CHANGED","PLAYER_FOCUS_CHANGED","UPDATE_MOUSEOVER_UNIT"
	)

	for _,c in pairs(module.C) do
		if c.id and c.events then
			for _,event in module.IterateTable(c.events) do
				if event:find("^BigWigs_") then
					module:UnregisterBigWigsCallback(event)
				elseif event:find("^DBM_") then
					module:UnregisterDBMCallback(event)
				elseif event == "TIMER" then
					module:UnregisterTimer()
				else
					module:UnregisterEvents(event)
				end
			end
		end
	end

	wipe(module.db.eventsToTriggers)

	for i=1,#module.db.timers do
		module.db.timers[i]:Cancel()
	end
	wipe(module.db.timers)
	wipe(module.db.showedReminders)
	wipe(reminders)

	for _,f in pairs(module.db.nameplateFrames) do
		f:Hide()
	end
	wipe(module.db.nameplateHL)
	wipe(module.db.nameplateGUIDToFrames)

	for guid,f in pairs(module.db.frameGUIDToFrames) do
		module:FrameRemoveHighlight(guid)
	end
	wipe(module.db.frameHL)
	wipe(module.db.frameGUIDToFrames)

	wipe(unitAuras)
	wipe(unitAurasInstances)
	wipe(bossFramesblackList)

	tCOMBAT_LOG_EVENT_UNFILTERED = nil
	tUNIT_HEALTH = nil
	tUNIT_POWER_FREQUENT = nil
	tUNIT_ABSORB_AMOUNT_CHANGED = nil
	tUNIT_AURA = nil
	tUNIT_TARGET = nil
	tUNIT_SPELLCAST_SUCCEEDED = nil
	tUNIT_CAST = nil

	if C_VoiceChat and C_VoiceChat.StopSpeakingText then
		C_VoiceChat.StopSpeakingText()
	end

	frameBars:StopAllBars()
end

function module:CopyTriggerEventForReminder(trigger)
	if trigger.event ~= 1 then
		return trigger
	end
	local new = ExRT.F.table_copy2(trigger)
	local eventDB = module.C[trigger.eventCLEU or 0]
	for k,v in pairs(new) do
		if eventDB and not ExRT.F.table_find(eventDB.triggerFields,k) and k ~= "andor" and k ~= "event" then
			new[k] = nil
		end
	end
	if eventDB and not ExRT.F.table_find(eventDB.triggerFields,"targetName") then
		new.guidunit = 1
	end
	if eventDB and not ExRT.F.table_find(eventDB.triggerFields,"sourceName") then
		new.guidunit = nil
	end
	if new.eventCLEU == "ENVIRONMENTAL_DAMAGE" then
		if new.spellID == 1 then
			new.spellID = "Falling"
		elseif new.spellID == 2 then
			new.spellID = "Drowning"
		elseif new.spellID == 3 then
			new.spellID = "Fatigue"
		elseif new.spellID == 4 then
			new.spellID = "Fire"
		elseif new.spellID == 5 then
			new.spellID = "Lava"
		elseif new.spellID == 6 then
			new.spellID = "Slime"
		end
	end
	return new
end

function module:FindNumberInString(num,str)
	if type(str) == "number" then
		return num == str
	elseif type(str) ~= "string" then
		return
	end
	num = tostring(num)
	for n in string_gmatch(str,"[^, ]+") do
		if n == num then
			return true
		end
	end
end

function module:CreateNumberConditions(str)
	if not str then
		return
	end
	local r = {}
	for w in string_gmatch(str, "[^, ]+") do
		local isPlus
		if w:find("^%+") then
			isPlus = true
			w = w:sub(2)
		end
		local n = tonumber(w)
		local f
		if n then
			f = function(v) return v == n end
		elseif w:find("%%") then
			local a,b = w:match("(%d+)%%(%d+)")
			if a and b then
				a = tonumber(a) - 1
				b = tonumber(b)
				f = function(v)
					if a == (v - 1) % b then
						return true
					end
				end
			end
		elseif w:find("^>=") then
			n = tonumber(w:match("[0-9%.]+"),10)
			f = function(v) return v >= n end
		elseif w:find("^>") then
			n = tonumber(w:match("[0-9%.]+"),10)
			f = function(v) return v > n end
		elseif w:find("^<=") then
			n = tonumber(w:match("[0-9%.]+"),10)
			f = function(v) return v <= n end
		elseif w:find("^<") then
			n = tonumber(w:match("[0-9%.]+"),10)
			f = function(v) return v < n end
		elseif w:find("^!") then
			n = tonumber(w:match("[0-9%.]+"),10)
			f = function(v) return v ~= n end
		elseif w:find("^=") then
			n = tonumber(w:match("[0-9%.]+"),10)
			f = function(v) return v == n end
		end
		if f then
			if isPlus and #r > 0 then
				local c = r[#r]
				r[#r] = function(v)
					return c(v) and f(v)
				end
			else
				r[#r+1] = f
			end
		end
	end
	return r
end

function module:CreateStringConditions(str)
	if not str then
		return
	end
	local isReverse
	if str:find("^%-") then
		isReverse = true
		str = str:sub(2)
	end
	local r = {}
	for w in string_gmatch(str, "[^;]+") do
		r[w] = true
	end
	if isReverse then
		local t = r
		r = setmetatable({},{__index = function(_,v)
			if t[v] then
				return false
			else
				return true
			end
		end})
	end
	return r
end

function module:CreateMobIDConditions(str)
	if not str then
		return
	end
	local r = {}
	for w in string_gmatch(str,"[^,]+") do
		local substr = w
		if w:find(":") then
			local condID,condSpawn = strsplit(":",substr,2)
			r[#r+1] = function(guid)
				local unitType,_,serverID,instanceID,zoneUID,mobID,spawnID = strsplit("-", guid or "")
				if mobID == condID and (unitType == "Creature" or unitType == "Vehicle") then
					local spawnIndex = bit.rshift(bit.band(tonumber(string.sub(spawnID, 1, 5), 16), 0xffff8), 3)

					return condSpawn == tostring(spawnIndex)
				end
			end
		else
			r[#r+1] = function(guid)
				return select(6,strsplit("-", guid or "")) == substr
			end
		end
	end
	if #r > 1 then
		return function(guid)
			for i=1,#r do
				if r[i](guid) then
					return true
				end
			end
		end
	else
		return r[1]
	end
end


function module:ConvertMinuteStrToNum(delayStr,notePattern)
	if not delayStr then
		return
	end
	local r = {}
	for w in string_gmatch(delayStr,"[^, ]+") do
		if w:lower() == "note" then
			w = "0"
			if notePattern then
				local found, line = module:FindPlayerInNote(notePattern)
				if found and line then
					local t = line:match("{time:([0-9:%.]+)")
					if t then
						w = t
					end
				end
			end
		end

		local delayNum = tonumber(w)
		if delayNum then
			r[#r+1] = delayNum > 0 and delayNum or 0.01
		else
			local m,s,ms = w:match("(%d+):(%d+)%.?(%d*)")
			if m and s then
				m = tonumber(m)
				s = tonumber(s)
				ms = ms and tonumber("0."..ms) or 0
				local rn = m * 60 + s + ms
				r[#r+1] = rn > 0 and rn or 0.01
			end
		end
	end
	if #r > 0 then
		return r
	else
		return
	end
end

function module:CheckPlayerCondition(data,myName,myClass,myRole)
	if not myName then
		myName = ExRT.SDB.charName
	end
	if not myClass then
		myClass = select(2,UnitClass'player')
	end
	if not myRole then
		myRole = module:GetRoleIndex()
	end
	if
		 data.allPlayers or
		 data.players[myName] or
		 data["class"..myClass] or
		 data["role"..myRole] or
		 (data.notePattern and module:FindPlayerInNote(data.notePattern))
	then
		return true
	end
end

function module:LoadReminders(encounterID,encounterDiff,zoneID,zoneName)
	module:UnloadAll()
	if not module.IsEnabled then
		return
	end

	if module.db.debugLog then module:DebugLogAdd("LoadReminders",encounterID,encounterDiff,zoneID) end

	local myName = ExRT.SDB.charName
	local myClass = select(2,UnitClass'player')
	local myRole = module:GetRoleIndex()

	local eventsUsed, unitsUsed = {}, {}
	local nameplateUsed

	for uid_key,data in pairs(CURRENT_DATA) do
		if uid_key ~= data.uid or type(data.triggers)~="table" or type(data.players)~="table" then
			CURRENT_DATA[uid_key] = nil
		elseif 
			not data.disabled and 
			#data.triggers > 0 and
			(
			 (encounterID and data.bossID == encounterID and (not data.diffID or data.diffID == encounterDiff)) or
			 (zoneID and (module:FindNumberInString(zoneID,data.zoneID) or data.zoneID=="-1"))
			) and
			module:CheckPlayerCondition(data,myName,myClass,myRole) and
			bit.band(VMRT.Reminder2.options[data.uid or 0] or 0,bit.lshift(1,0)) == 0
		then
			local reminder = {
				triggers = {},
				data = data,
			}
			reminders[#reminders+1] = reminder
			for i=1,#data.triggers do
				local trigger = data.triggers[i]
				local triggerData = module:CopyTriggerEventForReminder(trigger)

				local triggerNow = {
					_i = i,
					_trigger = triggerData,
					_reminder = reminder,
					_data = data,

					status = false,
					count = 0,
					countsS = {},
					countsD = {},
					active = {},
					statuses = {},

					Dcounter = module:CreateNumberConditions(triggerData.counter),
					DnumberPercent = module:CreateNumberConditions(triggerData.numberPercent),
					Dstacks = module:CreateNumberConditions(triggerData.stacks),
					DdelayTime = module:ConvertMinuteStrToNum(triggerData.delayTime,data.notePattern),
					DsourceName = module:CreateStringConditions(triggerData.sourceName),
					DtargetName = module:CreateStringConditions(triggerData.targetName),
					DsourceID = module:CreateMobIDConditions(triggerData.sourceID),
					DtargetID = module:CreateMobIDConditions(triggerData.targetID),
				}
				reminder.triggers[i] = triggerNow

				if trigger.event and module.C[trigger.event] then
					local eventDB = module.C[trigger.event]

					eventsUsed[trigger.event] = true

					local eventTable = module.db.eventsToTriggers[eventDB.name]
					if not eventTable then
						eventTable = {}
						module.db.eventsToTriggers[eventDB.name] = eventTable
					end

					if eventDB.isUntimed and not trigger.activeTime then
						triggerNow.untimed = true
						triggerNow.delays = {}
					end
					if eventDB.extraDelayTable then
						triggerNow.delays2 = {}
					end
					if eventDB.isUntimed and trigger.activeTime then
						triggerNow.ignoreManualOff = true
					end

					if eventDB.subEventField then
						local subEventDB = module.C[ trigger[eventDB.subEventField] ]
						if subEventDB then
							for _,subRegEvent in module.IterateTable(subEventDB.events) do
								local subEventTable = eventTable[subRegEvent]
								if not subEventTable then
									subEventTable = {}
									eventTable[subRegEvent] = subEventTable
								end

								subEventTable[#subEventTable+1] = triggerNow
							end
						end
					elseif eventDB.isUnits then
						triggerNow.units = {}

						local units = trigger[eventDB.unitField]

						unitsUsed[units or 0] = true

						if type(units) == "number" then
							if units < 0 then
								units = module.datas.unitsList.ALL
								for j=1,#module.datas.unitsList do 
									unitsUsed[j] = true 
								end
							else
								units = module.datas.unitsList[units]
							end
						end

						if units then
							for _,unit in module.IterateTable(units) do
								local unitTable = eventTable[unit]
								if not unitTable then
									unitTable = {}
									eventTable[unit] = unitTable
								end

								unitTable[#unitTable+1] = triggerNow
							end
						else
							eventTable[#eventTable+1] = triggerNow
						end
					else
						eventTable[#eventTable+1] = triggerNow
					end
				end
			end
			local triggersStr = ""
			local opened = false
			for i=#data.triggers,2,-1 do
				local trigger = data.triggers[i]
				if not trigger.andor or trigger.andor == 1 then
					triggersStr = "and "..(opened and "(" or "")..(trigger.invert and "not " or "").."t["..i.."].status " .. triggersStr
					opened = false
				elseif trigger.andor == 2 then
					triggersStr = "or "..(opened and "(" or "")..(trigger.invert and "not " or "").."t["..i.."].status " .. triggersStr
					opened = false
				elseif trigger.andor == 3 then
					triggersStr = "or "..(trigger.invert and "not " or "").."t["..i.."].status"..(not opened and ")" or "").." " .. triggersStr
					opened = true
				end
			end
			triggersStr = (opened and "(" or "")..(data.triggers[1].invert and "not " or "").."t[1].status "..triggersStr

			reminder.activeFunc = loadstring("return function(t) return "..triggersStr.." end")()
			reminder.activeFunc2 = loadstring("return function(t,n) local s=t[n].status t[n].status=not t[n]._trigger.invert local r="..triggersStr.." t[n].status=s return r end")()

			reminder.delayedActivation = module:ConvertMinuteStrToNum(data.delayedActivation)

			if module:GetReminderType(data.msgSize) == REM.TYPE_RAIDFRAME then
				nameplateUsed = true
			end

			if #data.triggers > 0 then
				module:CheckAllTriggers(reminder.triggers[1])
			end

			if module.db.debug then
				module.db.debugByName[data.name or tostring(data)] = reminder
			end
		end
	end

	for id in pairs(eventsUsed) do
		local eventDB = module.C[id]
		if eventDB and eventDB.events then
			for _,event in module.IterateTable(eventDB.events) do
				if event:find("^BigWigs_") then
					module:RegisterBigWigsCallback(event)
				elseif event:find("^DBM_") then
					module:RegisterDBMCallback(event)
				elseif event == "TIMER" then
					module:RegisterTimer()
				else
					module:RegisterEvents(event)
				end
			end
		end
	end
	local anyUnit
	for unit in pairs(unitsUsed) do
		if unit == "target" then
			module:RegisterEvents("PLAYER_TARGET_CHANGED")
		elseif unit == "focus" then
			module:RegisterEvents("PLAYER_FOCUS_CHANGED")
		elseif unit == "mouseover" then
			module:RegisterEvents("UPDATE_MOUSEOVER_UNIT")
		elseif (type(unit) == "string" and unit:find("^boss")) or unit == 1 then
			module:RegisterEvents("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		elseif unit == 2 then
			nameplateUsed = true
		end

		anyUnit = true
	end
	if anyUnit then
		module:RegisterEvents("RAID_TARGET_UPDATE")
	end
	if nameplateUsed then
		module:RegisterEvents("NAME_PLATE_UNIT_ADDED","NAME_PLATE_UNIT_REMOVED")
	end

	if encounterID and VMRT.Reminder2.HistoryEnabled then
		if not module.db.eventsToTriggers.COMBAT_LOG_EVENT_UNFILTERED then 
			module.db.eventsToTriggers.COMBAT_LOG_EVENT_UNFILTERED = {} 
			module:RegisterEvents("COMBAT_LOG_EVENT_UNFILTERED")
		end
		if not module.db.eventsToTriggers.BOSS_START then 
			module.db.eventsToTriggers.BOSS_START = {} 
		end
		if not module.db.eventsToTriggers.BOSS_PHASE then 
			module.db.eventsToTriggers.BOSS_PHASE = {} 
			module:RegisterBigWigsCallback("BigWigs_Message")
			module:RegisterBigWigsCallback("BigWigs_SetStage")
			module:RegisterDBMCallback("DBM_SetStage")
		end
		if not module.db.eventsToTriggers.CHAT_MSG then 
			module.db.eventsToTriggers.CHAT_MSG = {} 
			module:RegisterEvents(unpack(module.C[8].events))
		end
		if not module.db.eventsToTriggers.INSTANCE_ENCOUNTER_ENGAGE_UNIT then 
			module.db.eventsToTriggers.INSTANCE_ENCOUNTER_ENGAGE_UNIT = {} 
			module:RegisterEvents("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		end
	end
	if (module.db.eventsToTriggers.NOTE_TIMERS or module.db.eventsToTriggers.NOTE_TIMERS_ALL) and not module.db.eventsToTriggers.COMBAT_LOG_EVENT_UNFILTERED then 
		module.db.eventsToTriggers.COMBAT_LOG_EVENT_UNFILTERED = {} 
	end

	tCOMBAT_LOG_EVENT_UNFILTERED = module.db.eventsToTriggers.COMBAT_LOG_EVENT_UNFILTERED
	tUNIT_HEALTH = module.db.eventsToTriggers.UNIT_HEALTH
	tUNIT_POWER_FREQUENT = module.db.eventsToTriggers.UNIT_POWER_FREQUENT
	tUNIT_ABSORB_AMOUNT_CHANGED = module.db.eventsToTriggers.UNIT_ABSORB_AMOUNT_CHANGED
	tUNIT_AURA = module.db.eventsToTriggers.UNIT_AURA
	tUNIT_TARGET = module.db.eventsToTriggers.UNIT_TARGET
	tUNIT_SPELLCAST_SUCCEEDED = module.db.eventsToTriggers.UNIT_SPELLCAST_SUCCEEDED
	tUNIT_CAST = module.db.eventsToTriggers.UNIT_CAST

	if nameplateUsed then
		module:NameplatesReloadCycle()
	end

	if module.db.eventsToTriggers.PARTY_UNIT then
		module.main:GROUP_ROSTER_UPDATE()
	end

	if anyUnit then
		module.main:RAID_TARGET_UPDATE()
	end

	if #reminders > 0 and zoneID and zoneName then
		VMRT.Reminder2.zoneNames[zoneID] = zoneName
	end
end

local DELIMITER_1 = string.char(172)
local DELIMITER_2 = string.char(164)

local STRING_CONVERT = {
	list = {
		["\17"] = "\18",
		[DELIMITER_1] = "\19",
		[DELIMITER_2] = "\20",
	},
	listRev = {},
}
do
	local senc,sdec = "",""

	for k,v in pairs(STRING_CONVERT.list) do
		STRING_CONVERT.listRev[v] = k
		senc = senc .. k
		sdec = sdec .. v
	end	

	STRING_CONVERT.encodePatt = "["..senc.."]"
	STRING_CONVERT.encodeFunc = function(a)
		return "\17"..STRING_CONVERT.list[a]
	end

	STRING_CONVERT.decodePatt = "\17(["..sdec.."])"
	STRING_CONVERT.decodeFunc = function(a)
		return STRING_CONVERT.listRev[a]
	end
end

do
	local checkType = {
		["invert"] = true,
		["onlyPlayer"] = true,
	}
	local stringType = {
		["sourceName"] = true,
		["sourceID"] = true,
		["targetName"] = true,
		["targetID"] = true,
		["spellName"] = true,
		["pattFind"] = true,
		["counter"] = true,
		["delayTime"] = true,
		["stacks"] = true,
		["numberPercent"] = true,
	}
	local numberType = {
		["sourceMark"] = true,
		["targetMark"] = true,
		["spellID"] = true,
		["extraSpellID"] = true,
		["bwtimeleft"] = true,
		["cbehavior"] = true,
		["activeTime"] = true,
		["guidunit"] = true,
		["targetRole"] = true,
	}
	local mixedType = {
		["sourceUnit"] = true,
		["targetUnit"] = true,
	}
	local cleu_events = {}
	for k,v in pairs(module.C) do
		if v.main_id == 1 and v.subID then
			cleu_events[tostring(v.subID)] = k
			cleu_events[k] = tostring(v.subID)
		end
	end
	function module:GetTriggerSyncString(trigger)
		local r = (trigger.event or "") .. DELIMITER_2 .. (trigger.andor or "") 

		local eventDB
		if trigger.event == 1 then
			eventDB = module.C[trigger.eventCLEU or 0]
		else
			eventDB = module.C[trigger.event or 0]
		end

		local keysList
		if eventDB then
			keysList = eventDB.triggerSynqFields or eventDB.triggerFields
		end

		if keysList then
			for i=1,#keysList do
				local key = keysList[i]
				if key == "eventCLEU" then
					r = r .. DELIMITER_2 .. (cleu_events[ trigger[key] or 0 ] or trigger[key] or "")
				elseif checkType[key] then
					r = r .. DELIMITER_2 .. (trigger[key] and "1" or "")
				elseif stringType[key] then
					r = r .. DELIMITER_2 .. tostring(trigger[key] or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc)
				else
					r = r .. DELIMITER_2 .. (trigger[key] or "")
				end
			end
		end

		r = r:gsub("["..DELIMITER_2.."]+$","")

		return r
	end

	function module:ProcessTextToData(text, sender, isStringImport, isSelfImport)
		local data = {strsplit("\n",text)}
		if data[1] then
			local ver,addonVer = strsplit(DELIMITER_1,data[1])
			if tonumber(ver or "?") ~= senderVersion then
				if tonumber(ver or "0") > senderVersion then
					print("MRT Reminder: your reminder addon version is outdated (string ver."..(addonVer or "unk")..", your addon ver."..addonVersion..")")
				else
					print("MRT Reminder: import data is outdated (string ver."..(addonVer or "unk")..", your addon ver."..addonVersion..")")
				end
				return
			end
		else
			return
		end
		local workingArray
		if isStringImport then
			workingArray = CURRENT_DATA
		else
			workingArray = VMRT.Reminder2.data[0]
		end
		local rc = 0
		for i=2,#data do
			local uid,name,msg,msgSize,dur,checks,countdownType,sound,extraOptions,glowOptions,countdownVoice,extraCheck,bossID,diffID,zoneID,players,notePattern,roles,classes,triggersNum,triggersData = strsplit(DELIMITER_1,data[i],21)
			if uid then
				if msg then
					local triggers = {}
					local players_arr = {}

					local glowType,glowColor,glowThick,glowScale,glowN,glowImage,customOpt1 = strsplit(DELIMITER_2,glowOptions or "")

					if glowImage then
						local num = tonumber(glowImage)
						if num and num < 1000 then
							glowImage = num
						elseif glowImage ~= "" then
							glowImage = glowImage:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc)
						else
							glowImage = nil
						end
					end

					local specialTarget,delayedActivation = strsplit(DELIMITER_2,extraOptions or "")

					local new = {
						uid = uid,
						name = name~="" and name or nil,
						msg = msg~="" and msg:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						msgSize = msgSize~="" and tonumber(msgSize) or nil,
						dur = dur~="" and tonumber(dur) or nil,
						countdownType = countdownType~="" and tonumber(countdownType) or nil,
						delayedActivation = delayedActivation and delayedActivation:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						sound = sound~="" and sound:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						bossID = bossID~="" and tonumber(bossID) or nil,
						diffID = diffID~="" and tonumber(diffID) or nil,
						zoneID = zoneID~="" and zoneID:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						notePattern = notePattern~="" and notePattern:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						players = players_arr,
						triggers = triggers, 
						specialTarget = specialTarget~="" and specialTarget:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						glowType = glowType and glowType~="" and tonumber(glowType) or nil,
						glowThick = glowThick and glowThick~="" and tonumber(glowThick) or nil,
						glowScale = glowScale and glowScale~="" and tonumber(glowScale) or nil,
						glowN = glowN and glowN~="" and tonumber(glowN) or nil,
						glowColor = glowColor and glowColor~="" and glowColor:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						glowImage = glowImage or nil,
						customOpt1 = customOpt1 and customOpt1~="" and customOpt1:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						extraCheck = extraCheck~="" and extraCheck:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						countdownVoice = countdownVoice ~= "" and tonumber(countdownVoice) or nil,
					}


					checks = tonumber(checks or 0) or 0
					roles = tonumber(roles or 0) or 0
					classes = tonumber(classes or 0) or 0

					if bit.band(checks,bit.lshift(1,0)) > 0 then new.countdown = true end
					if bit.band(checks,bit.lshift(1,1)) > 0 then new.copy = true end
					if bit.band(checks,bit.lshift(1,2)) > 0 then new.allPlayers = true end
					if bit.band(checks,bit.lshift(1,3)) > 0 then new.disabled = true end
					if bit.band(checks,bit.lshift(1,4)) > 0 then new.sametargets = true end
					if bit.band(checks,bit.lshift(1,5)) > 0 then new.dynamicdisable = true end
					if bit.band(checks,bit.lshift(1,6)) > 0 then new.norewrite = true end

					for j=1,#module.datas.rolesList do
						if bit.band(roles,bit.lshift(1, j-1)) > 0 then new["role"..j] = true end
					end
					for j=1,#ExRT.GDB.ClassList do
						if bit.band(classes,bit.lshift(1, j-1)) > 0 then 
							local class = ExRT.GDB.ClassList[j]
							new["class"..class] = true 
						end
					end

					for player in string_gmatch(players:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc), "[^:]+") do
						players_arr[player] = true
					end

					for j=1,tonumber(triggersNum) do
						local triggerStr = select(j,strsplit(DELIMITER_1,triggersData))
						local tnew = {event = 1}
						triggers[j] = tnew

						local c = 1
						local keysList
						local arg = strsplit(DELIMITER_2,triggerStr)
						while arg do
							if c == 3 and tnew.event == 1 then
								arg = cleu_events[arg] or arg
								tnew[ keysList[1] ] = arg
								keysList = module.C[arg or 0] and (module.C[arg].triggerSynqFields or module.C[arg].triggerFields)
							elseif c > 2 then
								if keysList then
									local key = keysList[c-2]
									if key then
										if checkType[key] then
											tnew[key] = arg=="1" and true or nil
										elseif numberType[key] then
											tnew[key] = arg~="" and tonumber(arg) or nil
										elseif mixedType[key] then
											tnew[key] = arg~="" and (tonumber(arg) or arg:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc)) or nil
										else
											tnew[key] = arg~="" and arg:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil
										end
									end
								end
							elseif c == 1 then
								tnew.event = tonumber(arg)
								keysList = module.C[tnew.event or 0] and (module.C[tnew.event].triggerSynqFields or module.C[tnew.event].triggerFields)
							elseif c == 2 then
								tnew.andor = arg~="" and tonumber(arg) or nil
							end
							c = c + 1
							arg = select(c,strsplit(DELIMITER_2,triggerStr))
						end
					end

					if bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,4)) > 0 and workingArray[uid] then
						new.sound = workingArray[uid].sound
					end

					if sender then
						new.updatedName = sender
						new.updatedTime = time()
					end
					VMRT.Reminder2.removed[uid] = nil
					if bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,2)) == 0 then
						workingArray[uid] = new
					end

					if isStringImport and name then
						print("Imported ",name,"("..(new.bossID and ExRT.GDB.encounterIDtoEJ[new.bossID] and L.bossName[new.bossID] or zoneID and zoneID ~= "" and "Zone "..zoneID or "none")..")")
					end
					rc = rc + 1
				else
					workingArray[uid] = nil
				end
			end
		end
		if module.db.debug then
			print("Reminder ProcessTextToData: encoded length:",#text,"reminders num:",rc)
		end

		if isStringImport then
			module:SetProfile(VMRT.Reminder2.Profile)
		elseif not isSelfImport or VMRT.Reminder2.Profile == 0 then
			module:SetProfile(0)
		end
		--[[
		if module.options.UpdateData then
			module.options:UpdateData()
		end
		if VMRT.Reminder2.enabled then
			module:ReloadAll()
		end
		]]
	end

end

do
	function module.options:GetHistoryString(minimized)
		local t = module.db.history
		if minimized then
			if #t > 0 then
				t = {t[1]}
				local new = {}
				for i=1,#t[1] do
					if t[1][i][2] ~= 1 or (t[1][i][3] ~= "SPELL_AURA_APPLIED" and t[1][i][3] ~= "SPELL_AURA_REMOVED") then
						new[#new+1] = t[1][i]
					end
				end
				t[1] = new
			end
		end

		local strlist = ExRT.F.TableToText(t)
		local str = table.concat(strlist)

		return str
	end

	function module:ProcessHistoryTextToData(str, sender)
		--if true then return end

		local header = str:sub(1,9)
		if header:sub(1,8) ~= "EXRTREMH" or (header:sub(9,9) ~= "0" and header:sub(9,9) ~= "1") then
			return
		end

		str = str:sub(10)

		local uncompressed = header:sub(9,9)=="0"

		local decoded = LibDeflate:DecodeForPrint(str)
		if not decoded then return end
		local decompressed
		if uncompressed then
			decompressed = decoded
		else
			decompressed = LibDeflate:DecompressDeflate(decoded)
		end
		decoded = nil
		if not decompressed then return end

		local successful, res = pcall(ExRT.F.TextToTable,decompressed)
		decompressed = nil
		if successful and res then
			if not(#res > 0 and #res[1] > 1 and (res[1][#res[1]][1] - res[1][1][1]) >= 30) then
				return
			end
			tinsert(module.db.history,1,res[1])
			for i=(VMRT.Reminder2.HistoryNumSaved or 1)+1,#module.db.history do
				module.db.history[i] = nil
			end
		end
	end
end

do
	local antiSpam = 0
	local nextSyncGuild, nextSyncGuildTmr
	function module:SyncGuild()
		nextSyncGuild = true
	end
	function module:Sync(isExport,bossID,zoneID,oneUID)
		local isGuild = nextSyncGuild
		isGuild = false	--disable
		nextSyncGuild = nil

		local r = senderVersion..DELIMITER_1..addonVersion.."\n"
		local rc = 0
		for uid,data in pairs(CURRENT_DATA) do
			if 
				uid == data.uid and 
				(bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,3)) == 0 or oneUID) and
				(
				 (not bossID and not zoneID and not oneUID) or
				 (bossID and ((type(bossID) == "table" and data.bossID and bossID[data.bossID]) or (type(bossID) ~= "table" and data.bossID == bossID))) or
				 (zoneID and module:FindNumberInString(zoneID,data.zoneID)) or
				 (oneUID and uid == oneUID)
				)
			then
				local players,roles,classes,checks = "",0,0,0
				for k in pairs(data.players) do
					players = players .. (players~="" and ":" or "") .. k
				end
				for i=1,#module.datas.rolesList do
					if data["role"..i] then
						roles = bit.bor(roles,bit.lshift(1, i-1))
					end
				end
				for i=1,#ExRT.GDB.ClassList do
					local class = ExRT.GDB.ClassList[i]
					if data["class"..class] then
						classes = bit.bor(classes,bit.lshift(1, i-1))
					end
				end
				if data.countdown then checks = bit.bor(checks,bit.lshift(1,0)) end
				if data.copy then checks = bit.bor(checks,bit.lshift(1,1)) end
				if data.allPlayers then checks = bit.bor(checks,bit.lshift(1,2)) end
				if data.disabled then checks = bit.bor(checks,bit.lshift(1,3)) end
				if data.sametargets then checks = bit.bor(checks,bit.lshift(1,4)) end
				if data.dynamicdisable then checks = bit.bor(checks,bit.lshift(1,5)) end
				if data.norewrite then checks = bit.bor(checks,bit.lshift(1,6)) end

				local glowOptions = (
					(data.glowType or "") .. DELIMITER_2 .. 
					(data.glowColor or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_2 .. 
					(data.glowThick or "") .. DELIMITER_2 .. 
					(data.glowScale or "") .. DELIMITER_2 .. 
					(data.glowN or "") .. DELIMITER_2 .. 
					(data.glowImage and tostring(data.glowImage) or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_2 .. 
					(data.customOpt1 or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc)
				):gsub(DELIMITER_2.."*$","")

				local extraOptions = (
					(data.specialTarget or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_2 .. 
					(data.delayedActivation or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc)
				):gsub(DELIMITER_2.."*$","")

				r = r .. (data.uid .. DELIMITER_1 .. (data.name or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_1 .. (data.msg or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_1 .. (data.msgSize or "") .. DELIMITER_1 .. (data.dur or "")  .. DELIMITER_1 .. checks .. DELIMITER_1 .. (data.countdownType or "") .. DELIMITER_1 ..
					(data.sound and tostring(data.sound) or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_1 .. extraOptions .. DELIMITER_1 .. glowOptions .. 
					DELIMITER_1 .. (data.countdownVoice or "") .. DELIMITER_1 .. (data.extraCheck or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_1 .. (data.bossID or "") .. DELIMITER_1 .. (data.diffID or "") .. DELIMITER_1 .. (data.zoneID or "") .. DELIMITER_1 ..
					players:gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_1 .. (data.notePattern or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_1 .. roles  .. DELIMITER_1 .. classes .. DELIMITER_1 .. (#data.triggers)):gsub("\n","")
				for i=1,#data.triggers do
					r = r .. DELIMITER_1 .. module:GetTriggerSyncString(data.triggers[i]):gsub("\n","")
				end
				r = r .. "\n"
				rc = rc + 1

				VMRT.Reminder2.removed[uid] = nil
			end
		end
		if rc == 0 then
			print("MRT "..L.Reminder..": "..L.ReminderErrorZeroSend)
			return
		end
		local now = time()
		if (not bossID or type(bossID)=="table") and (not zoneID or type(bossID)=="table") and not oneUID then
			for uid,time in pairs(VMRT.Reminder2.removed) do
				r = r .. uid .. DELIMITER_1.."\n"
				if now - time > 15552000 then --180*24*60*60
					VMRT.Reminder2.removed[uid] = nil
				end
			end
		end
		r = r:gsub("\n$","")
		if isExport then
			return r
		end
		local now = GetTime()
		if now < antiSpam then
			return
		end
		antiSpam = now + 0.5

		local compressed = LibDeflate:CompressDeflate(r,{level = 9})
		local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

		encoded = encoded .. "##F##"

		if module.db.debug then
			print("Reminder: encoded length:",#encoded,"data length:",#r,"reminders num:",rc,"enc per reminder:",#encoded/rc,"data per reminder:",#r/rc)
		end

		local newIndex = math.random(0,9)
		while module.db.synqPrevIndex == newIndex do
			newIndex = math.random(0,9)
		end
		module.db.synqPrevIndex = newIndex

		newIndex = tostring(newIndex)
		local parts = ceil(#encoded / 247)
		--print("Reminder: sending parts",parts,'send size',#encoded)

		if module.options.SyncProgress then
			module.options:SyncProgress(0)
		end
		for i=1,parts do
			local msg = encoded:sub( (i-1)*247+1 , i*247 )
			if not isGuild then
				local progress = i
				ExRT.F.SendExMsgExt({ondone=function() module.options:SyncProgress(progress,parts) end},"rmd","D\t"..newIndex.."\t"..msg)
			else
				ExRT.F.SendExMsg("rmd","d\t"..newIndex.."\t"..msg,"GUILD")
			end
		end
	end
end

module.db.synqText = {}
module.db.synqIndex = {}
function module:addonMessage(sender, prefix, subprefix, arg1, ...)
	if prefix == "rmd" then
		if subprefix == "D" or subprefix == "d" then
			if subprefix == "D" and IsInRaid() and not ExRT.F.IsPlayerRLorOfficer(sender) then
				return
			end
			if VMRT.Reminder2.disableUpdates then
				return
			end

			local currMsg = table.concat({...}, "\t")
			if tostring(arg1) == tostring(module.db.synqIndex[sender]) and type(module.db.synqText[sender])=='string' then
				module.db.synqText[sender] = module.db.synqText[sender] .. currMsg
			else
				module.db.synqText[sender] = currMsg
			end
			module.db.synqIndex[sender] = arg1

			if type(module.db.synqText[sender])=='string' and module.db.synqText[sender]:find("##F##$") then
				local str = module.db.synqText[sender]:sub(1,-6)
				local decoded = LibDeflate:DecodeForWoWAddonChannel(str)
				local decompressed = LibDeflate:DecompressDeflate(decoded)

				module.db.synqText[sender] = nil
				module.db.synqIndex[sender] = nil
				if decompressed then
					module.popup:Popup(sender,function()
						VMRT.Reminder2.LastUpdateName = sender
						VMRT.Reminder2.LastUpdateTime = time()
	
						module:ProcessTextToData(decompressed, sender, nil, sender == ExRT.SDB.charKey or sender == ExRT.SDB.charName)
						if module.options and module.options.UpdateSenderDataText then
							module.options:UpdateSenderDataText()
						end
					end)
				end
			end
		elseif subprefix == "H" then
			if true then return end	--temp disabled
			if sender == ExRT.SDB.charKey then
				return
			end
			if VMRT.Reminder2.disableUpdates or VMRT.Reminder2.disableHistoryUpdates or not VMRT.Reminder2.HistoryEnabled or not IsInRaid() then
				return
			end

			if tostring(arg1) == "1" then
				if select(4,UnitPosition'player') == select(4,UnitPosition(sender)) then
					return
				end

				local currMsg = table.concat({...}, "\t")
				module.db.synqHText = (module.db.synqHText or "") .. currMsg

				if type(module.db.synqHText)=='string' and module.db.synqHText:find("##F##$") then
					module:ProcessHistoryTextToData(module.db.synqHText:sub(1,-6), sender)
					module.db.synqHText = nil
				end
			elseif tostring(arg1) == "2" then
				local senderVer = ...
				if senderVer and (tonumber(senderVer) or 0) > addonVersion then
					module.db.sendHistoryByMe = false
					return
				end
				if sender < ExRT.SDB.charName and senderVer and (tonumber(senderVer) or 0) >= addonVersion then
					module.db.sendHistoryByMe = false
				end
			end
		elseif subprefix == "V" then
			if arg1 == "G" then
				ExRT.F.SendExMsg("rmd", "V\tR\t"..addonVersion)
			elseif arg1 == "R" then
				local ver = ...
				if not ver or not module.db.gettedVersions then
					return
				end
				module.db.gettedVersions[sender] = ver
			end
		elseif subprefix == "S" then
			if arg1 == "E" and module.IsEnabled then
				local arg2,arg3,arg4,arg5 = ...
				if arg2 == "P" then
					local zoneID = tostring(select(8,GetInstanceInfo()))
					if module.db.requestEncounterID and ( GetTime() - module.db.requestEncounterID < 5 ) and zoneID == arg3 and not module.db.encounterID then	--delayed pull
						module.db.nextPullIsDelayed = true
						module.main:ENCOUNTER_START(tonumber(arg4), nil, select(3,GetInstanceInfo()), select(9,GetInstanceInfo()), nil)
					end
				elseif arg2 == "R" then
					local zoneID = tostring(select(8,GetInstanceInfo()))
					if module.db.encounterID and zoneID == arg3 then
						ExRT.F.SendExMsg("rmd", "S\tE\tP\t"..zoneID.."\t"..module.db.encounterID.."\t"..(module.db.encounterPullTime and GetTime() - module.db.encounterPullTime or 0))
					end
				end
			end
			
		end
	end
end

function module:slash(arg)
	if arg == "rem ver" then
		module.db.getVersion = GetTime()
		module.db.gettedVersions = {}
		ExRT.F.SendExMsg("rmd", "V\tG")

		C_Timer.After(2,function()
			local str = ""
			local inList = {}
			for q,w in pairs(module.db.gettedVersions) do
				local name = ExRT.F.delUnitNameServer(q)
				inList[name] = true
				str = str .. name .. " "
				if tonumber(w) then
					w = tonumber(w)
					str = str .. (w < addonVersion and "|cffff0000" or w > addonVersion and "|cff00ff00" or "") .. w .. (w ~= addonVersion and "|r" or "") .. ","
				else
					str = str .. w .. ","
				end
			end
			str = str:gsub(",$","")
			print(str)

			str = "|cffff0000"
			for _, name in ExRT.F.IterateRoster do
				if not inList[ExRT.F.delUnitNameServer(name)] then
					str = str .. name .. ","
				end
			end

			str = str:gsub(",$","")
			print(str)
		end)
	end
end


do
	local queue = {}

	local frame = CreateFrame("Frame",nil,UIParent,BackdropTemplateMixin and "BackdropTemplate")
	module.popup = frame

	function frame:NextQueue()
		frame:Hide()
		tremove(queue, 1)
		tremove(queue, 1)
		C_Timer.After(0.2,function()
			frame:PopupNext()
		end)
	end

	frame:Hide()
	frame:SetBackdrop({bgFile="Interface\\Addons\\"..GlobalAddonName.."\\media\\White"})
	frame:SetBackdropColor(0.05,0.05,0.07,0.98)
	frame:SetSize(250,65)
	frame:SetPoint("RIGHT",UIParent,"CENTER",-200,0)
	frame:SetFrameStrata("DIALOG")
	frame:SetClampedToScreen(true)

	frame.border = ExRT.lib:Shadow(frame,20)

	frame.label = frame:CreateFontString(nil,"OVERLAY","GameFontWhiteSmall")
	frame.label:SetFont(frame.label:GetFont(),10,"")
	frame.label:SetPoint("TOP",0,-4)
	frame.label:SetTextColor(1,1,1,1)
	frame.label:SetText("MRT: "..L.Reminder)

	frame.player = frame:CreateFontString(nil,"OVERLAY","GameFontWhiteSmall")
	frame.player:SetFont(frame.player:GetFont(),10,"")
	frame.player:SetPoint("TOP",0,-16)
	frame.player:SetTextColor(1,1,1,1)
	frame.player:SetText("MyName-MyRealm")

	local function OnUpdate_HoverCheck(self)
		if not frame:IsShown() then
			self:SetScript("OnUpdate",nil)
			self.subButton:Hide()
			return
		end
		local extraSpace = 10
		local x,y = GetCursorPosition()
		local rect1x,rect1y,rect1w,rect1h = self:GetScaledRect()
		local rect2x,rect2y,rect2w,rect2h = self.subButton:GetScaledRect()
		if not (x >= rect1x-extraSpace and x <= rect1x+rect1w+extraSpace and y >= rect1y-extraSpace and y <= rect1y+rect1h+extraSpace) and
			not (x >= rect2x-extraSpace and x <= rect2x+rect2w+extraSpace and y >= rect2y-extraSpace and y <= rect2y+rect2h+extraSpace) then
			self:SetScript("OnUpdate",nil)
			self.subButton:Hide()
		end
	end

	frame.b1 = ELib:Button(frame,DECLINE):Point("BOTTOMLEFT",5,5):Size(100,20):OnClick(function() 
		frame:NextQueue() 
	end):OnEnter(function(self)
		frame.b1always:Show()
		self:SetScript("OnUpdate",OnUpdate_HoverCheck)
	end)

	frame.b3 = ELib:Button(frame,ACCEPT):Point("BOTTOMRIGHT",-5,5):Size(100,20):OnClick(function() 
		queue[2]()
		frame:NextQueue()
	end):OnEnter(function(self)
		frame.b3always:Show()
		self:SetScript("OnUpdate",OnUpdate_HoverCheck)
	end)

	frame.b1always = ELib:Button(frame,ALWAYS.." "..DECLINE):Point("TOPLEFT",frame.b1,"BOTTOMLEFT",0,-10):Size(140,20):OnClick(function() 
		VMRT.Reminder2.SyncPlayers[frame.playerRaw] = -1
		frame:NextQueue() 
	end):Shown(false)
	frame.b3always = ELib:Button(frame,ALWAYS.." "..ACCEPT):Point("TOPRIGHT",frame.b3,"BOTTOMRIGHT",0,-10):Size(140,20):OnClick(function() 
		VMRT.Reminder2.SyncPlayers[frame.playerRaw] = 1
		queue[2]()
		frame:NextQueue() 
	end):Shown(false)

	frame.b1.subButton = frame.b1always
	frame.b3.subButton = frame.b3always

	for _,btn in pairs({frame.b1,frame.b1always,frame.b3,frame.b3always}) do
		btn.icon = btn:CreateTexture(nil,"ARTWORK")
		btn.icon:SetPoint("RIGHT",btn:GetTextObj(),"LEFT")
		btn.icon:SetSize(18,18)
		btn.icon:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
		btn.icon:SetTexCoord(0.125+(0.1875 - 0.125)*6,0.1875+(0.1875 - 0.125)*6,0.5,0.625)
		btn.icon:SetVertexColor(1,0,0,1)
	end

	frame.b3.icon:SetTexCoord(0.125+(0.1875 - 0.125)*7,0.1875+(0.1875 - 0.125)*7,0.5,0.625)
	frame.b3.icon:SetVertexColor(0,1,0,1)
	frame.b3always.icon:SetTexCoord(0.125+(0.1875 - 0.125)*7,0.1875+(0.1875 - 0.125)*7,0.5,0.625)
	frame.b3always.icon:SetVertexColor(0,1,0,1)

	function frame:PopupNext()
		if VMRT and VMRT.Reminder2 and VMRT.Reminder2.disablePopups then
			return
		end
		local player = queue[1]
		if not player then
			return
		end
		if player == ExRT.SDB.charKey or player == ExRT.SDB.charName then
			queue[2]()
			frame:NextQueue()
			return
		elseif VMRT.Reminder2.SyncPlayers[player] == -1 then
			frame:NextQueue()
			return
		elseif VMRT.Reminder2.SyncPlayers[player] == 1 then
			queue[2]()
			frame:NextQueue()
			return
		end
		frame.playerRaw = player
		frame.player:SetText(player)
		frame:Show()
	end

	function frame:Popup(player,func)
		queue[#queue+1] = player
		queue[#queue+1] = func
	
		frame:PopupNext()
	end

	--C_Timer.After(2,function() frame:Popup("Myself",function()end) end)
end