local GlobalAddonName, ExRT = ...

local ELib,L = ExRT.lib,ExRT.L
local module = ExRT:New("Reminder2",L.Reminder)
if not module then return end

local LibDeflate = LibStub:GetLibrary("LibDeflate")

local VMRT = nil

local UnitPowerMax, tonumber, tostring, UnitGUID, PlaySoundFile, RAID_CLASS_COLORS, floor, ceil = UnitPowerMax, tonumber, tostring, UnitGUID, PlaySoundFile, RAID_CLASS_COLORS, floor, ceil
local UnitHealthMax, UnitHealth, ScheduleTimer, UnitName, GetRaidTargetIndex, UnitCastingInfo, UnitChannelInfo, UnitIsUnit, UnitIsDead = UnitHealthMax, UnitHealth, ExRT.F.ScheduleTimer, UnitName, GetRaidTargetIndex, UnitCastingInfo, UnitChannelInfo, UnitIsUnit, UnitIsDead
local GetSpellInfo, strsplit, GetTime, UnitPower, UnitGetTotalAbsorbs, UnitClass, GetSpellCooldown, UnitGroupRolesAssigned = ExRT.F.GetSpellInfo or GetSpellInfo, strsplit, GetTime, UnitPower, UnitGetTotalAbsorbs, UnitClass, ExRT.F.GetSpellCooldown or GetSpellCooldown, UnitGroupRolesAssigned
local pairs, ipairs, bit, string_gmatch, tremove, pcall, format, wipe, type, select, loadstring, next, max, bit_band, unpack = pairs, ipairs, bit, string.gmatch, tremove, pcall, format, wipe, type, select, loadstring, next, math.max, bit.band, unpack
local GetSpellName = C_Spell and C_Spell.GetSpellName or GetSpellInfo
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture

local senderVersion = 4
local addonVersion = 65

local options = module.options

--[[
todo:
second activation
]]

module.db.timers = {}
module.db.reminders = {}
local reminders = module.db.reminders
module.db.remindersByName = {}
module.db.eventsToTriggers = {}
module.db.showedReminders = {}
module.db.historyNow = {}
module.db.history = {{}}
module.db.historySession = {{}}
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

local isLiveSession = false

local profiles = {
	[0] = L.InterruptsProfileShared,
}
for i=1,9 do
	profiles[i] = L.InterruptsProfilePersonal.." #"..i
end
local profilesSorted = {1,2,3,4,5,6,7,8,9}

local CURRENT_DATA = {}
local CURRENT_DATA_SHARED = {}

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

frame.dot = frame:CreateTexture(nil, "BACKGROUND",nil,-6)
frame.dot:SetTexture("Interface\\AddOns\\MRT\\media\\circle256")
frame.dot:SetAllPoints()
frame.dot:SetVertexColor(1,0,0,1)

frame:Hide()
frame.dot:Hide()

frame.textBigD = {}
frame.textD = {}
frame.textSmallD = {}

frame.textBig = {}
frame.text = {}
frame.textSmall = {}
function frame:CreateText(t,i,textSizeScale)
	local text = t[i]
	if text then
		return text
	end

	text = self:CreateFontString(nil,"ARTWORK")
	t[i] = text
	text:SetShadowOffset(1,-1)
	text:SetTextColor(1,1,1,1)

	text.tss = textSizeScale == 1 and 1.5 or textSizeScale == 2 and 1 or 0.5

	text.tmr = self:CreateFontString(nil,"ARTWORK")
	text.tmr:SetShadowOffset(1,-1)
	text.tmr:SetTextColor(1,1,1,1)
	text.tmr:SetPoint("LEFT",text,"RIGHT",floor(text.tss * 6 + 0.5),0)


	self:UpdateTextStyle(text)

	return text
end

function frame:UpdateTextStyle(obj)
	if not VMRT then
		return
	end
	local font = VMRT.Reminder2.Font or ExRT.F.defFont
	local outline = VMRT.Reminder2.FontOutline and "OUTLINE" or ""
	local fontSize = VMRT.Reminder2.FontSize or 50

	local ahText = (VMRT.Reminder2.FontAdj == 1 and "LEFT") or (VMRT.Reminder2.FontAdj == 2 and "RIGHT") or ""
	local avTextT,avTextB = "TOP","BOTTOM"
	if VMRT.Reminder2.GrowUp then
		avTextT,avTextB = avTextB,avTextT
	end
	local te = VMRT.Reminder2.FontTimerExcluded

	local rpf = avTextT..ahText
	local rpt = avTextB..ahText

	for o,t in pairs(obj and {{obj}} or {self.textBigD,self.textD,self.textSmallD}) do
		for ci,text in pairs(t) do
			text:SetFont(font, fontSize*text.tss, outline)
			text.tmr:SetFont(font, fontSize*text.tss, outline)

			text.te = te

			text.rpf = rpf
			text.rpt = rpt

			text.point = nil
		end
	end
end

do
	local pd = {"textBig","text","textSmall"}
	local p = {"textBigD","textD","textSmallD"}
	function frame:Update()
		local lastT
		for j,t in ipairs(pd) do
			local fp = self[t]
			local f = self[ p[j] ]
			local c = 0
			for i=#fp,1,-2 do
				c = c + 1
				local text = f[c]
				if not text then
					text = self:CreateText(f,c,j)
				end
		
				if text.te then
					text:SetText((fp[i-1] or "").." "..(fp[i] or ""))
					text.tmr:SetText("")				
				else
					text:SetText(fp[i-1])
					text.tmr:SetText((fp[i] or "").." ")
				end

				if text.point ~= (lastT or self) then
					text:ClearAllPoints()
					if lastT then
						text:SetPoint(text.rpf or "TOP",lastT,text.rpt or "BOTTOM",0,0)
						text.point = lastT
					else
						text:SetPoint(text.rpf or "TOP",self,"CENTER",0,0)
						text.point = self
					end
				end

				lastT = text
			end
			for i=c+1,#f do
				local text = f[i]

				text:SetText("")
				text.tmr:SetText("")
			end
		end
	end
end


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
	frame:UpdateTextStyle()

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
		wipe(frame.text)
		wipe(frame.textBig)
		wipe(frame.textSmall)
		frame.text[#frame.text+1] = module:FormatMsg("{spell:17} "..L.ReminderDefText)
		frame.text[#frame.text+1] = "2.3"
		frame.textBig[#frame.textBig+1] = module:FormatMsg("{spell:642} "..L.ReminderBigText)
		frame.textBig[#frame.textBig+1] = "4.5"
		frame.textSmall[#frame.textSmall+1] = module:FormatMsg("{spell:740} "..L.ReminderSmallText)
		frame.textSmall[#frame.textSmall+1] = "6.7"
		frame:Update()
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
		if frame.text[1] == L.ReminderDefText then
			wipe(frame.text)
			wipe(frame.textBig)
			wipe(frame.textSmall)
			frame:Update()
			frame:Hide()
		end

		frameBars.dot:Hide()
		frameBars:EnableMouse(false)
		frameBars:SetMovable(false)
		frameBars:StopAllBars()
		frameBars:Hide()
	end
end

ELib:FixPreloadFont(frame,function() 
	if VMRT then
		--frame.text:SetFont(GameFontWhite:GetFont(),11, "")
		--frame.textBig:SetFont(GameFontWhite:GetFont(),11, "")
		--frame.textSmall:SetFont(GameFontWhite:GetFont(),11, "")
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
		local spellTexture = GetSpellTexture( spellID )
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
		local spellTexture = GetSpellTexture( spellID )
		if not iconSize or iconSize == "" then
			iconSize = 0
		end
		if iconSize == 0 and VMRT.Reminder2.IconSizeCustom then
			iconSize = VMRT.Reminder2.IconSizeCustomSize or 20
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
				--return lines[i]:gsub("[{}]",""), nil
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
	condition = condition:gsub(" +OR +"," OR "):gsub(" +AND +"," AND ")

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
	if module.db.debug then	print('Find',find,'in',str,(str or ""):find(find) and "FOUND" or "NOT") end
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

	local conditionList = {
		["warrior"] = 1,
		["paladin"] = 1,
		["hunter"] = 1,
		["rogue"] = 1,
		["priest"] = 1,
		["deathknight"] = 1,
		["shaman"] = 1,
		["mage"] = 1,
		["warlock"] = 1,
		["monk"] = 1,
		["druid"] = 1,
		["demonhunter"] = 1,
		["evoker"] = 1,
		["healer"] = 2,
		["heal"] = 2,
		["dd"] = 2,
		["damager"] = 2,
		["tank"] = 2,
	}

	local pl_list = {}
	local pl_condres = {}
	local pl_condadd = {}
	local function GSUB_PlayersList_All(line)
		local filters,pos = strsplit(":",line)
		if not pos then
			return ""
		end
		pos = tonumber(pos)
		if not pos then
			return ""
		end
		for k in pairs(pl_list) do pl_list[k]=nil end
		for k in pairs(pl_condadd) do pl_condadd[k]=nil end
		local cond = {strsplit(",",filters:lower())}
		for i=#cond,1,-1 do
			if cond[i]:find("^%+") then
				pl_condadd[i] = pl_condadd[i] or i
				pl_condadd[i-1] = pl_condadd[i]

				cond[i] = cond[i]:sub(2)
			end
		end
		for _, name, subgroup, class, guid, rank, level, online, isDead, combatRole in ExRT.F.IterateRoster, ExRT.F.GetRaidDiffMaxGroup() do
			for k in pairs(pl_condres) do pl_condres[k]=nil end
			for i=1,#cond do
				local status = false

				local c = cond[i]
				local condType = conditionList[ c ]
				if condType == 1 then
					if class:lower() == c then
						status = true
					end
				elseif c:find("^g%d+") then
					if tostring(subgroup or "") == c:match("^g(%d+)") then
						status = true
					end
				elseif condType == 2 then
					if combatRole:lower() == c then
						status = true
					elseif (combatRole == "HEALER" and c == "heal") or
						(combatRole == "DAMAGER" and c == "dd")
					then
						status = true
					end
				end

				if pl_condadd[i] == i then
					for j=i-1,1,-1 do
						if pl_condadd[j] ~= i then break end
						status = status and pl_condres[j]
					end
					for j=i,1,-1 do
						if pl_condadd[j] ~= i then break end
						pl_condres[j] = status
					end
				else
					pl_condres[i] = status
				end
			end

			local isAny = false
			for i=1,#cond do
				if pl_condres[i] then
					isAny = true
					break
				end
			end
			if isAny then
				pl_list[#pl_list+1] = ExRT.F.delUnitNameServer(name)
			end
		end

		if pos < 0 then
			return #pl_list >= 0 and pl_list[-pos] or ""
		end
		return #pl_list >= 0 and pl_list[((pos - 1) % #pl_list) + 1] or ""
	end
	local function GSUB_PlayersList(mword,arg)
		return GSUB_PlayersList_All(mword..":"..arg)
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

		funit = GSUB_PlayersList_All,
	}
	local handlers_nocloser_withname = {
		["warrior"] = GSUB_PlayersList,
		["paladin"] = GSUB_PlayersList,
		["hunter"] = GSUB_PlayersList,
		["rogue"] = GSUB_PlayersList,
		["priest"] = GSUB_PlayersList,
		["deathknight"] = GSUB_PlayersList,
		["shaman"] = GSUB_PlayersList,
		["mage"] = GSUB_PlayersList,
		["warlock"] = GSUB_PlayersList,
		["monk"] = GSUB_PlayersList,
		["druid"] = GSUB_PlayersList,
		["demonhunter"] = GSUB_PlayersList,
		["evoker"] = GSUB_PlayersList,
	}

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

	local function replace_nocloser(mword,word,num,fullArg,arg)
		--if module.db.debug then print('replace_nocloser','mword',mword,'word',word,'num',num,'fullArg',fullArg,'arg',arg) end
		local handler = handlers_nocloser[word]
		if handler then
			--print('nc',word,arg)
			replace_counter = true
			return handler(arg) or ""
		elseif handlers_nocloser_withname[word] then
			replace_counter = true
			return handlers_nocloser_withname[word](mword,arg) or ""
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

	local function replace_closer(word,arg,data)
		--if module.db.debug then print('replace_closer',word,'arg',arg,'data',data) end
		local handler = handlers_closer[word]
		if handler then
			replace_counter = true
			--print('c',word,arg,data)
			return handler(arg,data) or ""
		end 
	end

	local function replace_other(word)
		if not handlers_nocloser[word] and not handlers_closer[word] then
			replace_counter = true
			return ""
		end
	end

	function module:FormatMsg(msg,params,isForChat,printLog)
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
			if printLog then 
				print('Iteration',subcount,"|cffaaaaaa"..msg.."|r")
			end
			subcount = subcount + 1
			--print('sc',subcount,msg)
			--if module.db.debug then	print('FormatMsg',msg) end
			msg = msg:gsub("{(([A-Za-z]+)(%d*))(:?([^{}]*))}",replace_nocloser)
				:gsub("{([^:{}]+):?([^{}]*)}([^{}]-){/%1}",replace_closer)
			if not replace_counter then
				msg = msg:gsub("{/?([^{}:]*)[^{}]*}",replace_other)
			end			
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

function module:FormatTime(t)
	t = tonumber(t or 0) or 0
	return format("%d:%02d",t/60,t%60)
end
function module:FormatTime2(t)
	t = tonumber(t or 0) or 0
	return format("%d:%02d.%d",t/60,t%60,(t*10)%10)
end
function module:FormatTime3(t)
	t = tonumber(t or 0) or 0
	local r = format("%d:%02d.%d",t/60,t%60,(t*10)%10)
	r = r:gsub("%.0$","")
	return r
end

function module:ExtraCheckParams(extraCheck,params,printLog)
	extraCheck = module:FormatMsg(extraCheck,params,false,printLog)

	if not extraCheck:find("[=~<>]") then
		return false, false, extraCheck
	else
		if GSUB_YesNoCondition(extraCheck,1) == "1" then
			return true, true, extraCheck
		else
			return false, true, extraCheck
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
		{"TTS2","Text-to-Speech [Custom]"},
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
		{1,L.ReminderTanks,"TANK",1,"roleicon-tiny-tank"},
		{2,L.ReminderHealers,"HEALER",2,"roleicon-tiny-healer"},
		{3,L.ReminderDD,"DAMAGER",4,"roleicon-tiny-dps"},
		{4,L.ReminderRDD,"RDD",8,"roleicon-tiny-dps"},
		{5,L.ReminderMDD,"MDD",16,"roleicon-tiny-dps"},
		{7,L.ReminderRHEALER,"RHEALER",32,"roleicon-tiny-healer"},
		{8,L.ReminderMHEALER,"MHEALER",64,"roleicon-tiny-healer"},
	},
	events = {
		1,2,3,6,7,4,5,11,8,9,10,12,13,14,15,16,17,20,18,19,21,22,
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
		{"boss1","boss2","boss3","boss4","boss5","arena1","arena2","arena3","arena4","arena5","arenapet1","arenapet2","arenapet3","arenapet4","arenapet5","npc"},
		{"nameplate1","nameplate2","nameplate3","nameplate4","nameplate5","nameplate6","nameplate7","nameplate8","nameplate9","nameplate10",
		 "nameplate11","nameplate12","nameplate13","nameplate14","nameplate15","nameplate16","nameplate17","nameplate18","nameplate19","nameplate20",
		 "nameplate21","nameplate22","nameplate23","nameplate24","nameplate25","nameplate26","nameplate27","nameplate28","nameplate29","nameplate30",
		 "nameplate31","nameplate32","nameplate33","nameplate34","nameplate35","nameplate36","nameplate37","nameplate38","nameplate39","nameplate40"},
		{"raid1","raid2","raid3","raid4","raid5","raid6","raid7","raid8","raid9","raid10",
		 "raid11","raid12","raid13","raid14","raid15","raid16","raid17","raid18","raid19","raid20",
		 "raid21","raid22","raid23","raid24","raid25","raid26","raid27","raid28","raid29","raid30",
		 "raid31","raid32","raid33","raid34","raid35","raid36","raid37","raid38","raid39","raid40"},
		{"player","party1","party2","party3","party4"},
		ALL = {"boss1","boss2","boss3","boss4","boss5","arena1","arena2","arena3","arena4","arena5","arenapet1","arenapet2","arenapet3","arenapet4","arenapet5","npc",
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

local unitreplace = {
	arena1 = "boss6",
	arena2 = "boss7",
	arena3 = "boss8",
	arena4 = "boss9",
	arena5 = "boss10",
	arenapet1 = "boss11",
	arenapet2 = "boss12",
	arenapet3 = "boss13",
	arenapet4 = "boss14",
	arenapet5 = "boss15",
	npc = "boss16",
}
local unitreplace_rev = {}
for k,v in pairs(unitreplace) do unitreplace_rev[v]=k end

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
		fieldTooltips = {["pattFind"]=L.ReminderSearchStringTip},
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
		fieldTooltips = {["pattFind"]=L.ReminderSearchStringTip},
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
	[22] = {
		id = 22,
		name = "MPLUS_START",
		lname = L.ReminderMplusPull,
		isUntimed = false,
		isUnits = false,
		triggerFields = {"delayTime","activeTime","invert"},
		triggerSynqFields = {"delayTime","activeTime","invert"},
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
			local l = lines[i]:gsub(pat.." *",""):gsub("|c........",""):gsub("|r",""):gsub(" *$",""):gsub("|",""):gsub(" +"," "):gsub("[%(%)#!%d%%]","")
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
	local mainRole, subRole = ExRT.F.GetPlayerRole(true)

	local main = ExRT.F.table_find3(module.datas.rolesList,mainRole,3)
	if main then
		return main[1]
	else
		return 0
	end
end

function module:GetSubRoleIndex()
	local mainRole, subRole = ExRT.F.GetPlayerRole(true)

	local sub = ExRT.F.table_find3(module.datas.rolesList,subRole,3)
	if sub then
		return sub[1]
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

function options:Load()
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
		dur = 3,
		players = {},
		countdown = true,
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

	function options:GetZoneName(zoneID)
		local name = GetRealZoneText(zoneID) or VMRT.Reminder2.zoneNames[zoneID] or "Zone ID "..(zoneID)
		local journalInstance = ExRT.GDB.MapIDToJournalInstance[zoneID]
		if journalInstance and EJ_GetInstanceInfo then
			name = EJ_GetInstanceInfo(journalInstance) or name
		end
		return name
	end

	ELib:DecorationLine(self,true,"BACKGROUND",1):Point("TOPLEFT",self,0,-25):Point("BOTTOMRIGHT",self,"TOPRIGHT",0,-45)

	self.chkEnable = ELib:Check(self,L.Enable,VMRT.Reminder2.enabled):Point("LEFT",560,0):Point("TOP",0,-26):Size(18,18):AddColorState():TextButton():OnClick(function(self) 
		VMRT.Reminder2.enabled = self:GetChecked() 

		if VMRT.Reminder2.enabled then
			module:Enable()
		else
			module:Disable()
		end
	end)

	self.tab = ELib:Tabs(self,0,L.ReminderGlobal,L.ReminderPersonal,L.minimapmenuset,"Timeline","Assignments"):Point(0,-45):Size(698,570):SetTo(1):ChangeTabPos({1,2,4,5,3})
	self.tab:SetBackdropBorderColor(0,0,0,0)
	self.tab:SetBackdropColor(0,0,0,0)

	if not VMRT.Reminder2.optNewTL and ExRT.V <= 5200 then
		self.tab.newicon_tl = ELib:Texture(self.tab.tabs[4].button):Atlas("CharacterCreate-NewLabel"):Point("RIGHT",0,3):Size(30,30)
	end
	if not VMRT.Reminder2.optNewAS and ExRT.V <= 5200 then
		self.tab.newicon_as = ELib:Texture(self.tab.tabs[5].button):Atlas("CharacterCreate-NewLabel"):Point("RIGHT",0,3):Size(30,30)
	end

	function self.tab:buttonAdditionalFunc()
		VMRT.Reminder2.OptSavedTabNum = self.selected

		if self.selected == 4 and self.newicon_tl then
			self.newicon_tl:Hide()
			self.newicon_tl = nil
			VMRT.Reminder2.optNewTL = true
			if VMRT.Reminder2.optNewAS and VMRT.Reminder2.optNewTL then
				ExRT.Options:RemoveIcon(module.name)
			end
		end
		if self.selected == 5 and self.newicon_as then
			self.newicon_as:Hide()
			self.newicon_as = nil
			VMRT.Reminder2.optNewAS = true
			if VMRT.Reminder2.optNewAS and VMRT.Reminder2.optNewTL then
				ExRT.Options:RemoveIcon(module.name)
			end
		end

		if self.selected == 4 then
			options.isWide = 1000
		elseif self.selected == 5 then
			options.isWide = options.assign.TL_PAGEWIDTH or 1000
		elseif self.selected == 1 or self.selected == 2 then
			options.isWide = 1000
		else
			options.isWide = nil
		end
		ExRT.Options.Frame:SetPage(ExRT.Options.Frame.CurrentFrame)

		options.profileDropDown:SetShown(self.selected == 1 or self.selected == 2 or self.selected == 4 or self.selected == 5)
		options.sharedProfileDropDown:SetShown(self.selected == 1 or self.selected == 2 or self.selected == 4 or self.selected == 5)
		if self.selected == 3 then
			options.chkEnable:Point("LEFT",560,0)
		else
			options.chkEnable:Point("LEFT",560+200,0)
		end

		if self.selected == 4 then
			if options.timeLine.preload then
				options.timeLine.preload()
				options.timeLine.preload = nil
			else
				options.timeLine:Update()
			end
		elseif self.selected == 5 then
			if options.assign.preload then
				options.assign.preload()
				options.assign.preload = nil
			else
				options.assign:Update()
			end
		elseif self.selected == 1 or self.selected == 2 then
			local prev = options.isPersonalTab
			options.isPersonalTab = nil
			if self.selected == 2 then
				options.isPersonalTab = true

				self.tabs[2]:Hide()
				self.tabs[1]:Show()
			end
			options:UpdateData()
				
			options.scrollList.ScrollBar.slider:SetValue(0)

			options.SyncButton:SetShown(self.selected == 1)
			options.ExportButton:SetShown(self.selected == 1)
			options.ImportButton:SetShown(self.selected == 1)
			options.CopyToButton:SetShown(self.selected == 1)
			options.ResetButton:SetShown(self.selected == 1)
			options.lastUpdate:SetShown(self.selected == 1)
		end
	end


	options.timeLine = {
		Data = ExRT.Data.ReminderTimeline,

		BOSS_ID = 0,

		TIMELINE_SCALE = 80,
		TIMELINE_ADJUST_NUM = 3,
		TIMELINE_ADJUST = 100,
		TIMELINE_ADJUST_DATA = {},

		TL_LINESIZE = 20,
		TL_REMSIZE = 24,	
		TL_HEADER_COLOR_OFF = {.2,.2,.2,1},
		TL_HEADER_COLOR_ON = {1,1,1,1},
		TL_HEADER_COLOR_HOVER = {1,1,0,1},

		FILTER_AURA = true,

		spell_status = {},
		spell_dur = {},
		custom_phase = {},
		reminder_hide = {},

		saved_colors = {}
	}

	function options.timeLine.util_sort_by2(a,b) return a[2]<b[2] end

	function options.timeLine:GetPosFromTime(t)
		local s = self.TIMELINE_SCALE
		if s < 100 then
			if s > 0 then
				s = 2^(-math.ceil((100-s)/10)+1) - (2^(-math.ceil((100-s)/10)))/10*(10-(s%10))
			else
				s = 1
			end
		elseif s > 100 then
			s = (s-90)/10
		else
			s = 1
		end
		return t/s
	end
	function options.timeLine:GetTimeFromPos(x)
		local s = self.TIMELINE_SCALE
		if s < 100 then
			if s > 0 then
				s = 2^(-math.ceil((100-s)/10)+1) - (2^(-math.ceil((100-s)/10)))/10*(10-(s%10))
			else
				s = 1
			end
		elseif s > 100 then
			s = (s-90)/10
		else
			s = 1
		end
		return x*s
	end
	function options.timeLine:GetTimeAdjust(t,reverse)
		if not reverse then t = t * (self.TIMELINE_ADJUST / 100) end
		for i=1,self.TIMELINE_ADJUST_NUM do
			local adj = self.TIMELINE_ADJUST_DATA[ i ]
			if adj[1] and adj[2] and t >= adj[1] then
				t = t + adj[2] * (reverse and -1 or 1)
			end
		end
		if reverse then t = t / (self.TIMELINE_ADJUST / 100) end
		return t
	end
	function options.timeLine:IsRemovedByTimeAdjust(t)
		t = t * (self.TIMELINE_ADJUST / 100)
		for i=1,self.TIMELINE_ADJUST_NUM do
			local adj = self.TIMELINE_ADJUST_DATA[ i ]
			if adj[1] and adj[2] then
				if adj[2] < 0 and t >= adj[1]+adj[2] and t < adj[1] then
					return true
				end
				if t >= adj[1] then
					t = t + adj[2]
				end
			end
		end
	end

	function options.timeLine:GetPhaseCounter(phaseNum,notIgnoreFirst)
		local timeLineData = self.timeLineData
		local c = {[1]=1}
		local f, fc
		for i=1,#timeLineData.p do
			local p = self.custom_phase[i] or (timeLineData.p.n and timeLineData.p.n[i]) or i+1
			c[p] = (c[p] or 0) + 1
			if phaseNum == i then
				f = p
				fc = c[p]
			end
		end
		if f and (notIgnoreFirst or fc ~= 1 or c[f] > 1) then
			return fc
		end
	end

	--phaseNum here for timeline phase, not actual phase
	function options.timeLine:GetPhaseTotalCount(phaseNum)
		local timeLineData = self.timeLineData
		local c = {[1]=1}
		local f = 1
		for i=1,#timeLineData.p do
			local p = self.custom_phase[i] or (timeLineData.p.n and timeLineData.p.n[i]) or i+1
			c[p] = (c[p] or 0) + 1
			if phaseNum == i then
				f = p
			end
		end
		return c[f]
	end

	function options.timeLine:GetPhaseFromTime(time)
		local timeLineData = self.timeLineData
		if not timeLineData or not timeLineData.p then return end

		local res
		local res_time
		for i=1,#timeLineData.p do
			local phase_time = self:GetTimeAdjust(timeLineData.p[i])
			if time > phase_time then
				--do this for wrong ordered phases
				if not res_time or res_time < phase_time then
					res = i
					res_time = phase_time	
				end
			end
		end
		if res then
			return (self.custom_phase[res] or timeLineData.p.n and timeLineData.p.n[res]) or res+1, time-self:GetTimeAdjust(timeLineData.p[res]), self:GetPhaseCounter(res), res
		end
	end

	function options.timeLine:GetTimeOnPhase(time,phase,phaseCount)
		local timeLineData = self.timeLineData
		if not timeLineData or not timeLineData.p then return end

		if phaseCount then
			phaseCount = module:CreateNumberConditions(phaseCount)
		end

		for i=1,#timeLineData.p do
			if (tostring(self.custom_phase[i] or (timeLineData.p.n and timeLineData.p.n[i]) or i+1) == tostring(phase)) and (not phaseCount or module:CheckNumber(phaseCount,self:GetPhaseCounter(i,true))) then
				return time + self:GetTimeAdjust(timeLineData.p[i]), i+1
			end
		end
	end

	do
		local res = {}
		function options.timeLine:GetTimeOnPhaseMulti(time,phase,phaseCount)
			local timeLineData = self.timeLineData
			if not timeLineData then return end

			for k in pairs(res) do res[k]=nil end

			if phaseCount then
				phaseCount = module:CreateNumberConditions(phaseCount)
			end
	
			if timeLineData.p then
				for i=1,#timeLineData.p do
					if (tostring(self.custom_phase[i] or (timeLineData.p.n and timeLineData.p.n[i]) or i+1) == tostring(phase)) and (not phaseCount or module:CheckNumber(phaseCount,self:GetPhaseCounter(i,true))) then
						res[#res+1] = time + self:GetTimeAdjust(timeLineData.p[i])
						res[#res+1] = i+1
					end
				end
			end
	
			if tostring(phase) == "1" and (not phaseCount or module:CheckNumber(phaseCount,1)) then
				res[#res+1] = time
			end
			return unpack(res)
		end
	end

	function options.timeLine:GetTimeUntilPhaseEnd(time)
		local timeLineData = self.timeLineData
		if not timeLineData.p then return end
		for i=1,#timeLineData.p do
			if time < self:GetTimeAdjust(timeLineData.p[i]) then
				return self:GetTimeAdjust(timeLineData.p[i]) - time
			end
		end
	end
	function options.timeLine:GetSpellFromTime(time,spell,afterEnd)
		local timeLineData = self.timeLineData
		if not timeLineData then return end

		if timeLineData[spell] then
			local spellData = timeLineData[spell]
			local counter = 0
			local res_time, res_counter
			for i=1,#spellData do
				local spell_time_og = (type(spellData[i])=="table" and spellData[i][1] or spellData[i])
				if not self:IsRemovedByTimeAdjust(spell_time_og) then
					counter = counter + 1

					local spell_time = self:GetTimeAdjust(spell_time_og)

					local dur = (afterEnd and (type(spellData[i])=="table" and spellData[i].d or spellData.d or 2) or 0)
					if dur == "p" then dur = self:GetTimeUntilPhaseEnd(spell_time) or 2 end

					if time > spell_time and (not afterEnd or (time - spell_time) > dur) then
						res_time = time - spell_time - dur
						res_counter = counter
					end
				end
			end

			return res_time, res_counter
		end
	end
	do
		local res = {}
		function options.timeLine:GetTimeForSpell(time,spell,counter,afterEnd)
			local timeLineData = self.timeLineData
			if not timeLineData then return end
	
			for k in pairs(res) do res[k]=nil end

			local spellData = timeLineData[spell]
			if spellData then
				if counter then
					counter = module:CreateNumberConditions(counter)
				end

				local ci = 0
				for i=1,#spellData do
					local spell_time = type(spellData[i])=="table" and spellData[i][1] or spellData[i]
					if not self:IsRemovedByTimeAdjust(spell_time) then
						ci = ci + 1

						if not counter or module:CheckNumber(counter,ci) then
							spell_time = self:GetTimeAdjust(spell_time)
			
							local dur = (afterEnd and (type(spellData[i])=="table" and spellData[i].d or spellData.d or 2) or 0)
							if dur == "p" then dur = self:GetTimeUntilPhaseEnd(spell_time) or 2 end
			
							res[#res+1] = time + spell_time + dur
							res[#res+1] = ci
						end
					end
				end
			end

			return unpack(res)
		end
	end

	function options.timeLine:IsPassFilterSpellType(spellData,spell)
		if 
			(
			 ((spellData.spellType or 1) == 1 and not self.FILTER_CAST) or
			 (spellData.spellType == 2 and not self.FILTER_AURA)
			) and
			(not self.FILTER_SPELL or self.FILTER_SPELL[spell])
		then
			return true
		end
	end

	function options.timeLine:GetTimeLineData()
		local timeLineData = self.CUSTOM_TIMELINE or (self.BOSS_ID and self.Data[self.BOSS_ID]) or (self.ZONE_ID and self.Data[-self.ZONE_ID])
		if timeLineData and timeLineData.m then return end
		return timeLineData
	end

	function options.timeLine:GetCompareTimeLineData()
		local timeLineData = self.CUSTOM_TIMELINE_CMP
		return timeLineData
	end

	options.timeLine.util_sort_reminders = function(a,b) 
		if a[2]~=b[2] then 
			return a[2]<b[2] 
		else 
			return a[1].uid<b[1].uid 
		end
	end

	function options.timeLine:GetRemindersList()
		local timeLineData = self.timeLineData

		local bossList
		if timeLineData and timeLineData.p and timeLineData.p.n then
			for i=1,#timeLineData.p.n do
				if timeLineData.p.n[i] < 0 and timeLineData.p.n[i]>-10000 then
					if not bossList then bossList = {} end
					bossList[ -timeLineData.p.n[i] ] = timeLineData.p[i]
				end
			end
		end

		local data_list,data_uncategorized = {}

		for uid,data in pairs(module:RemGetAll()) do
			local bossID = data.bossID
			local zoneID = tostring(data.zoneID)

			local roptions = VMRT.Reminder2.options[uid] or 0
			local ignoreTimelime = bit.band(roptions,bit.lshift(1,5)) > 0
			if 
				not ignoreTimelime and
				(
				 (self.BOSS_ID and bossID == self.BOSS_ID) or
				 (self.ZONE_ID and (
				  (bossList and (bossID and bossList[bossID])) or
				  module:FindNumberInString(self.ZONE_ID,zoneID)
				 ))
				) 
			then
				local isAdded = false
				if
					#data.triggers >= 1 and
					(
						data.triggers[1].event == 3 or 
						data.triggers[1].event == 2 or 
						data.triggers[1].event == 22 or 
						(data.triggers[1].event == 1 and (
							data.triggers[1].eventCLEU == "SPELL_CAST_SUCCESS" or
							data.triggers[1].eventCLEU == "SPELL_CAST_START" or
							data.triggers[1].eventCLEU == "SPELL_AURA_REMOVED" or 
							data.triggers[1].eventCLEU == "SPELL_AURA_APPLIED"
						))
					) and
					(not self.FILTER_REM_ONLYMY or module:CheckPlayerCondition(data))
				then
					local time = module:ConvertMinuteStrToNum(data.triggers[1].delayTime)
					time = time and time[1] or 0
	
					if bossList and bossList[bossID] then
						time = time + bossList[bossID]
					end
	
					local timeOnPhase, customData
					if data.triggers[1].event == 2 then
						timeOnPhase = time
						local phaseData = {self:GetTimeOnPhaseMulti(time,data.triggers[1].pattFind,data.triggers[1].counter)}
						time, customData = {}, {}
						for i=1,#phaseData,2 do
							if phaseData[i] then
								time[#time+1] = phaseData[i]
								local phaseNum = phaseData[i+1]
								if phaseNum and (self:GetPhaseTotalCount(phaseNum) or 0) > 1 then 
									phaseNum = {pg = phaseData[i+1]} 
								elseif phaseNum then 
									phaseNum = {p = data.triggers[1].pattFind} 
								end
								customData[#time] = phaseNum
							end
						end
					elseif data.triggers[1].event == 1 then
						timeOnPhase = time
						local isAfterEnd = data.triggers[1].eventCLEU == "SPELL_AURA_REMOVED"
						local spellData = {self:GetTimeForSpell(time,data.triggers[1].spellID,data.triggers[1].counter,isAfterEnd)}

						time, customData = {}, {}
						for i=1,#spellData,2 do
							if spellData[i] then
								time[#time+1] = spellData[i]
								customData[#time] = {
									s = data.triggers[1].spellID, 
									c = spellData[i+1], 
									e = data.triggers[1].eventCLEU == "SPELL_CAST_SUCCESS" and "SCC" or data.triggers[1].eventCLEU == "SPELL_CAST_START" and "SCS" or data.triggers[1].eventCLEU == "SPELL_AURA_REMOVED" and "SAR" or data.triggers[1].eventCLEU == "SPELL_AURA_APPLIED" and "SAA"
								}
							end
						end
						
						if self.FILTER_SPELL_REP and not tonumber(data.triggers[1].counter) then
							time = nil
						end
					end

					if self.reminder_hide[uid] then
						time = nil
					end
	
					if type(time)=="table" then
						if #time > 0 then
							for i=1,#time do
								data_list[#data_list+1] = {data, time[i], customData[i], timeOnPhase}
							end
							isAdded = true
						end
					elseif time then
						data_list[#data_list+1] = {data, time, customData, timeOnPhase}
						isAdded = true
					end
				end
				if not isAdded then
					if not data_uncategorized then
						data_uncategorized = {}
					end
					data_uncategorized[#data_uncategorized+1] = data
				end
			end
		end

		sort(data_list,self.util_sort_reminders)

		return data_list, data_uncategorized
	end
	--GMRT.A.Reminder2.options.assign:GetRemindersList()
	function options.timeLine:ExportToString()
		local data_list = self:GetRemindersList()

		local str = ""
		local prevTime
		for i=1,#data_list do
			local data, time, customData, timeOnPhase = unpack(data_list[i])

			local msg = data.msg or ""
			local pmsg
			for k in pairs(data.players) do 
				local class = select(2,UnitClass(k))
				local color
				if class and RAID_CLASS_COLORS[class] then
					color = RAID_CLASS_COLORS[class].colorStr
				end
				if not color then
					for j=1,#ExRT.GDB.ClassList do
						local class = ExRT.GDB.ClassList[j]
						if data["class"..class] then
							if RAID_CLASS_COLORS[class] then
								color = RAID_CLASS_COLORS[class].colorStr
								break
							end
						end
					end
				end

				pmsg = (pmsg or "").."||c"..(color or "ffffffff")..k.."||r "..msg.." " 
			end

			if module:GetReminderType(data.msgSize) == REM.TYPE_TEXT then

				if IsShiftKeyDown() then timeOnPhase = nil customData = nil end

				local timestr = module:FormatTime(floor((timeOnPhase or time)+0.5))
				if timestr:find("%.0$") then timestr = timestr:gsub("%.0$","") end

				if time ~= prevTime then
					str = str .. "\n" .. "{time:"..timestr..
						(customData and customData.p and ",p"..customData.p or "")..
						(customData and customData.pg and ",pg"..customData.pg or "")..
						(customData and customData.s and ","..customData.e..":"..customData.s..":"..customData.c or "")..
						"}"
					prevTime = time
				end

				str = str .. " " .. (pmsg and pmsg:trim() or msg)

			end

		end
		str = str:trim()

		return str
	end

	function options.timeLine:ResetAdjust()
		self.TIMELINE_ADJUST = 100
		wipe(self.TIMELINE_ADJUST_DATA)
		options.timeLineAdjustFL.subframe.timeScale.lock = true
		options.timeLineAdjustFL.subframe.timeScale:SetValue(self.TIMELINE_ADJUST)
		options.timeLineAdjustFL.subframe.timeScale.lock = false
		for i=1,self.TIMELINE_ADJUST_NUM do
			self.TIMELINE_ADJUST_DATA[i] = {0,0}
			options.timeLineAdjustFL.subframe["tpos"..i]:SetText("0")
			options.timeLineAdjustFL.subframe["addtime"..i]:SetText("0")
		end
	end

	options.timeLine.CreateCustomTimelineFromHistory = module.CreateCustomTimelineFromHistory

	options.timeLine.historyImportWindow, options.timeLine.historyExportWindow = ExRT.F.CreateImportExportWindows()
	options.timeLine.historyImportWindow:SetFrameStrata("FULLSCREEN")
	options.timeLine.historyExportWindow:SetFrameStrata("FULLSCREEN")

	function options.timeLine.historyImportWindow:ImportFunc(str)
		local header = str:sub(1,8)
		if header:sub(1,7) ~= "MRTREMH" or (header:sub(8,8) ~= "0" and header:sub(8,8) ~= "1") then
			print("Import: wrong format")
			return
		end

		options.timeLine.historyImportWindow:TextToHistory(str:sub(9),header:sub(8,8)=="0")
	end

	function options:ImportToHistory(res)
		wipe(module.db.historySession)
		if not VMRT.Reminder2.HistoryMPlusSessionEnabled then
			for i=#res,1,-1 do
				if #res[i] > 0 and res[i][1][2] == 22 then
					tinsert(module.db.historySession, 1, res[i])
					tremove(res, i)
				end
			end
		end

		module.db.history = res
		if VMRT.Reminder2.HistorySession then
			VMRT.Reminder2.history = module.db.history
		end
	end

	function options.timeLine.historyImportWindow:TextToHistory(str,uncompressed)
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
			options:ImportToHistory(res)
		else
			print("Import error")
		end
	end


	self.timeLineBoss = ELib:DropDown(self.tab.tabs[4],250,-1):Point("TOPLEFT",10,-10):Size(220):SetText(L.ReminderSelectBoss)
	self.timeLineBoss.mainframe = options.timeLine
	self.timeLineBoss.SetValue = function(self,arg1,arg2,arg3,arg4,ignoreReload)
		ELib:DropDownClose()
		options.timeLine.frame.bigBossButtons:Hide()

		if IsShiftKeyDown() and IsAltKeyDown() then
			local cmp
			if arg3 == 3 or arg3 == 4 then
				cmp = arg4 and arg4.tl
			elseif arg3 == 2 or arg3 == 5 then
				cmp = options.timeLine:CreateCustomTimelineFromHistory(arg1)
			end
			if cmp then
				options.timeLine.CUSTOM_TIMELINE_CMP = cmp
				print('added for comparsion',self.data.text)
				options.timeLine:Update()
				return
			end
		end

		module.db.simrun = nil
		wipe(options.timeLine.custom_phase)
		wipe(options.timeLine.reminder_hide)

		options.timeLine:ResetAdjust()

		options.timeLine.BOSS_ID = nil
		options.timeLine.ZONE_ID = nil
		options.timeLine.CUSTOM_TIMELINE = nil
		options.timeLine.CUSTOM_TIMELINE_CMP = nil
		VMRT.Reminder2.TLBoss = nil
		--options.timeLine.FILTER_SPELL = nil


		options.timeLineBoss:SetText(arg2)
		if arg3 == 2 then
			options.timeLine.BOSS_ID = arg1[1] and arg1[1][3]
			options.timeLine.CUSTOM_TIMELINE = options.timeLine:CreateCustomTimelineFromHistory(arg1)
			VMRT.Reminder2.TLBoss = nil
		elseif arg3 == 5 then
			options.timeLine.ZONE_ID = arg1[1] and arg1[1][3]
			options.timeLine.CUSTOM_TIMELINE = options.timeLine:CreateCustomTimelineFromHistory(arg1)
			VMRT.Reminder2.TLBoss = nil
		elseif arg3 == 3 then
			options.timeLine.BOSS_ID = arg1
			options.timeLine.CUSTOM_TIMELINE = arg4.tl
			VMRT.Reminder2.TLBoss = arg4.id
		elseif arg3 == 4 then
			options.timeLine.ZONE_ID = arg1
			options.timeLine.CUSTOM_TIMELINE = arg4 and arg4.tl
		else
			options.timeLine.BOSS_ID = arg1
			VMRT.Reminder2.TLBoss = arg1
		end

		if not ignoreReload then
			options.timeLine:Update()
			options.assignBoss:SetValue(arg1,arg2,arg3,arg4,true)
		end
	end

	function self.timeLineBoss:SelectBoss(bossID)
		local L = self.List
		for i=1,#L do
			local line = L[i]
			if line.subMenu then
				for j=1,#line.subMenu do
					local subline = line.subMenu[j]
					if subline.arg1 == bossID then
						return subline.func(self,subline.arg1,subline.arg2,subline.arg3,subline.arg4)
					end
				end
			end
		end
	end

	local SORT_DUNG_LIST = {
		[2661] = 2,
		[2651] = 2,
		[2097] = 2,
		[2649] = 2,
		[2773] = 2,
		[2648] = 2,
		[1594] = 2,
		[2293] = 2,
	}

	function options:GetHistoryTimelineString()
		local t = {}
		for _, h_key in pairs({"history","historySession"}) do
			local sepAdded
			for i=1,#module.db[h_key] do
				local fight = module.db[h_key][i]

				local timelineData = options.timeLine:CreateCustomTimelineFromHistory(fight)
				t[#t+1] = timelineData
			end
		end

		local strlist = ExRT.F.TableToText(t)
		local str = table.concat(strlist)

		return str
	end

	function self.timeLineBoss:PreUpdate()
		wipe(self.List)
		local subMenu = {}
		local res

		for _, h_key in pairs({"history","historySession"}) do
			local sepAdded
			for i=1,#module.db[h_key] do
				local fight = module.db[h_key][i]
				local fightLen = #fight > 1 and fight[#fight][1] - fight[1][1]
				local text = (#fight > 0 and fight[1][4] or L.ReminderFight.." "..i)..(fightLen and format(" %d:%02d",fightLen/60,fightLen%60) or "")
				local boss_list = {
					text = text,
					arg1 = fight,
					arg2 = text,
					arg3 = 2,
					func = self.SetValue,
				}
				if #fight > 0 and fight[1][2] == 22 then
					boss_list.arg3 = 5
					boss_list.text = boss_list.text:gsub(" %d+:"," +"..(fight[1][5] or 0).."%1")
					local mplusSubMenu
					local start = nil
					for j=1,#fight do
						if fight[j][2] == 3 then
							start = j
						elseif start and fight[j][2] == 0 then
							local newFight = {}
							for k=start,j do
								newFight[#newFight+1] = fight[k]
							end
							start = nil
							if not mplusSubMenu then
								mplusSubMenu = {}
							end
							local nf_fightLen = newFight[#newFight][1] - newFight[1][1]
							local nf_text = (newFight[1][4] or L.ReminderFight.." "..i)..format(" %d:%02d",nf_fightLen/60,nf_fightLen%60)
							local ej = ExRT.GDB.encounterIDtoEJ[ newFight[1][3] ]
							local nf_icon,nf_iconsize
							if ej and EJ_GetCreatureInfo then
								nf_icon = select(5, EJ_GetCreatureInfo(1, ej))
								nf_iconsize = 32
							end
							mplusSubMenu[#mplusSubMenu+1] = {
								text = nf_text,
								arg1 = newFight,
								arg2 = nf_text,
								arg3 = 2,
								func = self.SetValue,
								icon = nf_icon,
								iconsize = nf_iconsize,
							}
						end
					end
					if mplusSubMenu then
						boss_list.subMenu = mplusSubMenu
					end
				elseif #fight > 0 and fight[1][2] == 3 then
					local ej = ExRT.GDB.encounterIDtoEJ[ fight[1][3] ]
					if ej and EJ_GetCreatureInfo then
						boss_list.icon = select(5, EJ_GetCreatureInfo(1, ej))
						boss_list.iconsize = 32
					end
				elseif #fight > 0 and fight[1][2] == 0 then
					boss_list.arg1 = ExRT.F.table_copy2(fight)
					boss_list.arg1[1][3] = select(8,GetInstanceInfo())
					boss_list.arg3 = 5
				end
				if fightLen then
					if not sepAdded then
						sepAdded = true
						if #subMenu > 0 then
							subMenu[#subMenu+1] = {
								text = " ",
								isTitle = true,
							}
						end
					end

					subMenu[#subMenu+1] = boss_list
				end
			end
		end

		if module.db.historyTL then
			if #subMenu > 0 then
				subMenu[#subMenu+1] = {
					text = " ",
					isTitle = true,
				}
			end
			local syncSubMenu = {}
			subMenu[#subMenu+1] = {
				text = "Synced history",
				subMenu = syncSubMenu,
			}
			for i=1,#module.db.historyTL do
				local data = module.db.historyTL[i]
				local bossID = data.bossID or 0
				local text = ExRT.L.bossName[bossID]..(data.len and format(" %d:%02d",data.len/60,data.len%60) or "")
				local boss_list = {
					text = text,
					arg1 = bossID,
					arg2 = text,
					arg3 = 3,
					arg4 = {tl = data[1],id = bossID},
					tooltip = data.player,
					func = self.SetValue,
				}
				syncSubMenu[#syncSubMenu+1] = boss_list
			end
		end

		if #subMenu == 0 then
			subMenu[#subMenu+1] = {
				text = L.ReminderRecordsYet,
				isTitle = true,
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

				local str = options:GetHistoryString()
				--local str = options:GetHistoryTimelineString()

				local compressed
				if #str < 1000000 then
					compressed = LibDeflate:CompressDeflate(str,{level = 5})
				end
				local encoded = "MRTREMH"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or str)

				options.timeLine.historyExportWindow.Edit:SetText(encoded)
				options.timeLine.historyExportWindow:Show()
			end,
		}
		subMenu[#subMenu+1] = {
			text = L.ReminderFightImport,
			func = function()
				ELib:DropDownClose()

				options.timeLine.historyImportWindow:NewPoint("CENTER",UIParent,0,0)
				options.timeLine.historyImportWindow:Show()
			end,
		}
		subMenu[#subMenu+1] = {
			text = L.ReminderLogNextFight,
			tooltip = L.ReminderLogNextFightTip,
			func = function()
				ELib:DropDownClose()

				module:HistoryLogNextFight()
			end,
			isTitle = module.db.historyNextFight and true or false,
		}

		self.List[ #self.List+1 ] = {
			text = L.ReminderFightSaved,
			subMenu = subMenu,
			prio = 100000,
		}

		local dungBossList = ExRT.F.GetEncountersList(false,false,false,true)
		local dungIDs = {}
		for i=1,#dungBossList do dungIDs[ dungBossList[i][1] ] = true end

		local listDung = {}
		self.List[#self.List+1] = {text = DUNGEONS or "DUNGEONS", arg3 = "dung", subMenu = listDung, prio = 40000-1, isHidden = ExRT.isClassic}

		for bossID,bossData in pairs(options.timeLine.Data) do
			local toadd
			local isZone
			if bossID > 0 then
				local zone
				for i=1,#ExRT.GDB.EncountersList do
					local z = ExRT.GDB.EncountersList[i]
					for j=2,#z do
						if z[j] == bossID then
							zone = z
							break
						end
					end
				end
				if zone then
					local isDung = dungIDs[ zone[1] ]
					if not isDung then
						toadd = ExRT.F.table_find3(self.List,zone[1],"arg3")
					else
						toadd = ExRT.F.table_find3(listDung,zone[1],"arg3")
					end
					if not toadd then
						local text = GetMapNameByID(zone[1])

						local zoneImg
						local zoneMapID
						local ej_bossID = ExRT.GDB.encounterIDtoEJ[bossID]
						if ej_bossID and EJ_GetEncounterInfo then
							local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID = EJ_GetEncounterInfo(ej_bossID)
							if journalInstanceID then
								local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(journalInstanceID)
								zoneImg = buttonImage1
								text = name or text
								zoneMapID = mapID
							end
						end

						toadd = {text = text, arg3 = zone[1], subMenu = {}, zonemd = zone, prio = 40000+zone[1]+(zoneMapID and SORT_DUNG_LIST[ zoneMapID ] and SORT_DUNG_LIST[ zoneMapID ]*5000 or 0), icon = zoneImg}
						if not isDung then
							self.List[#self.List+1] = toadd
						else
							listDung[#listDung+1] = toadd
						end
					end
					toadd = toadd.subMenu
				end
			else
				isZone = true
				toadd = ExRT.F.table_find3(self.List,"m+","arg3")
				if not toadd then
					toadd = {text = PLAYER_DIFFICULTY_MYTHIC_PLUS or "M+", arg3 = "m+", subMenu = {}, prio = 40000-2, isHidden = ExRT.isClassic}
					self.List[#self.List+1] = toadd
				end
				toadd = toadd.subMenu
			end
			if not toadd then
				toadd = self.List
			end

			local bossImg
			if not isZone and ExRT.GDB.encounterIDtoEJ[bossID] and EJ_GetCreatureInfo then
				bossImg = select(5, EJ_GetCreatureInfo(1, ExRT.GDB.encounterIDtoEJ[bossID]))
			end

			local boss_list = {
				arg1 = bossID,
				arg2 = ExRT.L.bossName[bossID],
				text = ExRT.L.bossName[bossID],
				func = self.SetValue,
				prio = bossID,
				icon = bossImg,
				iconsize = 32,
			}
			if isZone then
				boss_list.arg1 = -bossID
				boss_list.arg3 = 4
				local name = GetRealZoneText(zoneID) or VMRT.Reminder2.zoneNames[-bossID] or "Zone ID "..(-bossID)
				local journalInstance = ExRT.GDB.MapIDToJournalInstance[-bossID]
				if journalInstance and EJ_GetInstanceInfo then
					local iname = EJ_GetInstanceInfo(journalInstance)
					if iname then
						name = iname
					end
				end
				boss_list.text = name
				boss_list.arg2 = name
				boss_list.prio = -100000-bossID+(SORT_DUNG_LIST[-bossID] and SORT_DUNG_LIST[-bossID]*5000 or 0)
			end
			if not (boss_list.text == "" and ExRT.isClassic) then
				toadd[#toadd+1] = boss_list
			end
			if boss_list.text == "" then
				boss_list.text = "Boss "..bossID
			end

			if bossData.m then
				local subMenu = {}
				boss_list.subMenu = subMenu
				for i=1,#bossData do
					local bossData_i = bossData[i]
					local text = (bossData_i.d[1] == 4 and (PLAYER_DIFFICULTY6 or "Mythic") or bossData_i.d[1] == 3 and (PLAYER_DIFFICULTY2 or "Heroic") or bossData_i.d[1] == 2 and (PLAYER_DIFFICULTY1 or "Normal") or "") .. (bossData_i.d.k and "+"..bossData_i.d.k or "") .. (bossData_i.d.name and " "..bossData_i.d.name or "") .. " ".. module:FormatTime(bossData_i.d[2])
					local newEntry = {
						arg1 = bossID,
						arg2 = boss_list.text .. " ".. module:FormatTime(bossData_i.d[2]),
						text = text,
						func = self.SetValue,
						prio = bossData_i.d[1] + bossData_i.d[2] / 10000,
						arg3 = 3,
						arg4 = {id = bossID + i/100, tl = bossData_i},
					}
					subMenu[#subMenu+1] = newEntry
					if isZone then
						newEntry.arg1 = -bossID
						newEntry.arg3 = 4
					end
					if not boss_list.prio2 or boss_list.prio2 < newEntry.prio then
						boss_list.arg3 = newEntry.arg3
						boss_list.arg4 = newEntry.arg4
						boss_list.prio2 = newEntry.prio
					end
				end
				sort(subMenu,function(a,b)
					return (a.prio or 0) > (b.prio or 0) 
				end)
			elseif bossData.d then
				boss_list.tooltip = (bossData.d[1] == 4 and (PLAYER_DIFFICULTY6 or "Mythic") or bossData.d[1] == 3 and (PLAYER_DIFFICULTY2 or "Heroic") or bossData.d[1] == 2 and (PLAYER_DIFFICULTY1 or "Normal") or "") .. " ".. module:FormatTime(bossData.d[2])
			end
	
			if module.db.lastEncounterID == bossID then
	 			res = function() self:SetValue(bossID,ExRT.L.bossName[bossID]) end
			elseif not module.db.lastEncounterID and VMRT.Reminder2.TLBoss and (VMRT.Reminder2.TLBoss == bossID or (type(VMRT.Reminder2.TLBoss == "number") and floor(VMRT.Reminder2.TLBoss) == bossID)) then
				if VMRT.Reminder2.TLBoss % 1 ~= 0 then
					local n = floor( (VMRT.Reminder2.TLBoss % 1) * 100 + 0.5 )
					res = function() self:SetValue(bossID,ExRT.L.bossName[bossID],3,{id = VMRT.Reminder2.TLBoss, tl = bossData.m and (bossData[n] or bossData[1]) or bossData}) end
				else
					res = function() self:SetValue(bossID,ExRT.L.bossName[bossID]) end
				end
			end
		end
		for i=1,#self.List do
			local list = self.List[i]
			if list.zonemd then
				sort(list.subMenu,function(a,b) return (ExRT.F.table_find(list.zonemd,a.arg1) or 0) > (ExRT.F.table_find(list.zonemd,b.arg1) or 0) end)
			end
		end
		for i=1,#listDung do
			local list = listDung[i]
			if list.zonemd then
				sort(list.subMenu,function(a,b) return (ExRT.F.table_find(list.zonemd,a.arg1) or 0) > (ExRT.F.table_find(list.zonemd,b.arg1) or 0) end)
			end
		end
		sort(listDung,function(a,b)
			return (a.prio or 0) > (b.prio or 0) 
		end)
		self.List[#self.List+1] = {
			text = L.ReminderCustom.." encounter ID",
			func = function() ELib:DropDownClose() ExRT.F.ShowInput(L.ReminderEncounterID,function(_,id) id=tonumber(id) if not id then return end self:SetValue(id,L.bossName[id]) end,nil,true) end,
			prio = -990000,
		}
		local customSubMenu = {}
		if VMRT.Reminder2.CustomTLData then
			for bossID,data in pairs(VMRT.Reminder2.CustomTLData) do
				local name = bossID < 0 and options:GetZoneName(-bossID) or ExRT.L.bossName[bossID]
				customSubMenu[#customSubMenu+1] = {
					text = name .. " ".. module:FormatTime(data.d and data.d[2] or 0),
					arg1 = bossID,
					arg2 = name,
					arg3 = 3,
					arg4 = {id = nil, tl = data},
					func = self.SetValue,
					prio = bossID,
					subMenu = {
						{text = "Edit", arg1 = bossID, arg2 = data, func = function(self,arg1,arg2)  ELib:DropDownClose() options.timeLine.customTimeLineDataFrame:OpenEdit(arg1,arg2) end},
						{text = L.ReminderRemove, arg1 = bossID, arg2 = data, func = function(self,arg1,arg2)  ELib:DropDownClose() VMRT.Reminder2.CustomTLData[arg1] = nil end},
					},
				}
			end
		end
		customSubMenu[#customSubMenu+1] = {
			text = "Open editor",
			func = function() ELib:DropDownClose() options.timeLine.customTimeLineDataFrame:OpenEdit(nil,{}) end,
			prio = 100000,
		}
		sort(customSubMenu,function(a,b)
			return (a.prio or 0) > (b.prio or 0) 
		end)
		self.List[#self.List+1] = {
			text = L.ReminderCustom,
			prio = -989990,
			subMenu = customSubMenu,
			Lines = #customSubMenu > 15 and 15,
		}

		sort(self.List,function(a,b)
			return (a.prio or 0) > (b.prio or 0) 
		end)


		if self.mainframe.frame.bigBossButtons:IsShown() then
			local list = self.List[2]	--most recent tier
			if list.zonemd then
				self.mainframe.frame.bigBossButtons:Reset()
				for i=2,#list.zonemd do
					local encounterID = list.zonemd[i]
					local inlist = ExRT.F.table_find3(list.subMenu,encounterID,"arg1")
					if inlist then
						self.mainframe.frame.bigBossButtons:Add(encounterID,function() inlist.func(self,inlist.arg1,inlist.arg2,inlist.arg3,inlist.arg4) end)
					end
				end
			end
		end

		if res then
			return res
		end
	end

	do
		local newList = {}
		for bossID,bossData in pairs(options.timeLine.Data) do
			for i,bossFight in ipairs(bossData.m and bossData or {bossData}) do
				if bossFight.p and bossFight.p[1] < 0 then
					local spell = -bossFight.p[1]
					local diff = bossFight.p[2] and bossFight.p[2] > 0 and bossFight.p[2] or 0
					for j=1,#bossFight[spell] do
						bossFight.p[j] = bossFight[spell][j] + diff
					end
				end
				--[[
				if bossFight.p and bossFight.p.n then
					for j=1,#bossFight.p.n do
						if bossFight.p.n[j] < 0 and bossFight.p.n[j] > -10000 then
							if newList[ -bossFight.p.n[j] ] then
								print('double for',-bossFight.p.n[j])
							end
							local fight_start, fight_end = bossFight.p[j], bossFight.p[j+1]
							local new = {d={8,fight_end - fight_start}}
							newList[ -bossFight.p.n[j] ] = new

							for k,v in pairs(bossFight) do
								if type(k)=="number" then
									new[k] = {}
									for l=1,#v do
										local time = (type(v[l]) == "table" and v[l][1] or v[l])
										if time >= fight_start and time <= fight_end then
											if type(v[l]) == "table" then
												local n = table_copy2(v[l])
												new[k][#new[k]+1] = n
												n[1] = n[1] - fight_start
											else
												new[k][#new[k]+1] = v[l] - fight_start
											end
										end
									end
									for k2,v2 in pairs(v) do
										if type(k2)~="number" then
											new[k][k2] = v
										end
									end
									if #new[k] == 0 then
										new[k] = nil
									end
								end
							end
						end
					end
				end
				]]
			end
		end
	end

	self.timeLineTestRun = ELib:Button(self.tab.tabs[4],L.ReminderTest):Point("TOP",self.tab.tabs[4],0,-10):Point("RIGHT",self,-10,0):Size(140,20):Tooltip(L.ReminderTestTip.."\nShift - x3\nShift + Alt - x10"):OnClick(function()
		if module.db.simrun then
			module.db.simrun = nil
			return
		end
		module:LoadReminders(options.timeLine.BOSS_ID,-1,options.timeLine.ZONE_ID)
		module.db.simrun = GetTime()

		module.db.simrunspeed = nil
		if IsShiftKeyDown() and IsAltKeyDown() then
			module.db.simrunspeed = 10
		elseif IsShiftKeyDown() then
			module.db.simrunspeed = 3
		end

		if options.timeLine.ZONE_ID then 
			module:TriggerMplusStart() 
		else
			module:TriggerBossPull()
			module:TriggerBossPhase("1")
		end
		local timeLineData = options.timeLine:GetTimeLineData()
		if timeLineData and not options.timeLine.ZONE_ID and timeLineData.p then
			for i=1,#timeLineData.p do
				local phase = options.timeLine.custom_phase[i] or (timeLineData.p.n and timeLineData.p.n[i]) or i+1
				local t = ScheduleTimer(function() module:TriggerBossPhase(tostring(phase),i+1) end, (timeLineData.p[i] / (module.db.simrunspeed or 1)))
				module.db.timers[#module.db.timers+1] = t
			end
		end

		local ts = module.db.simrun
		C_Timer.NewTicker(1,function(self)
			local tt = (GetTime()-ts) * (module.db.simrunspeed or 1)
			if not module.db.simrun or not options:IsVisible() then
				options.timeLineTestRun:SetText(L.ReminderTest)
				self:Cancel()
				print("Test run ended on "..module:FormatTime(tt))
				module:ReloadAll()
				return
			end
			options.timeLineTestRun:SetText(L.ReminderTest..": "..module:FormatTime(tt))
		end)
	end)

	self.timeLineImportFromNoteFrame = ELib:Popup(" "):Size(600,400+200)
	ELib:Border(self.timeLineImportFromNoteFrame,1,.4,.4,.4,.9)

	self.timeLineImportFromNoteFrame.Edit = ELib:MultiEdit(self.timeLineImportFromNoteFrame):Point("TOP",0,-15):Size(590,355)
	self.timeLineImportFromNoteFrame.Import = ELib:Button(self.timeLineImportFromNoteFrame,L.ReminderImportAdd):Point("BOTTOM",0,5):Size(590,20):OnClick(function(self)
		local parent = self:GetParent()
		local text = parent.Edit:GetText()
		local mainframe = parent.mainframe
		local timeLineData =  mainframe:GetTimeLineData()
		if not timeLineData then return end

		mainframe.undoimportlist = {remove={},repair={}}

		if parent.opt_removebefore then
			local currentlist = mainframe:GetRemindersList()

			for i=1,#currentlist do
				local uid = currentlist[i][1].uid
				mainframe.undoimportlist.repair[uid] = module:RemGet(uid)
				module:RemRem(uid)
			end
		end

		local lines = {strsplit("\n",text)}
		for i=1,#lines do
			local line = lines[i]
			if line:find("{time:") then
				local time = line:match("{time:([^,}]+)")
				local isgp,p = line:match("{time:[^,}]+,p(g?)([%d%.]+)")
				local cleu = line:match("{time:[^,}]+,(S[^},]+)")
				if time then
					local x = module:ConvertMinuteStrToNum(time)
					x = x and x[1]
					if x then
						local data = ExRT.F.table_copy2(newRemainderTemplate)
						data.bossID = mainframe.BOSS_ID
						data.zoneID = mainframe.ZONE_ID
						data.uid = options:GetNewUID()
						data.dur = 3
				
						local toadd = true

						--manual fixes
						if cleu == "SCS:450483:1" then cleu = nil p = "1.5"
						elseif cleu == "SAA:447207:1" then cleu = nil p = "2"

						elseif cleu == "SAA:442432:1" then cleu = nil p = "2"
						elseif cleu == "SAA:442432:2" then cleu = nil p = "3"
						elseif cleu == "SAA:442432:3" then cleu = nil p = "4"
						elseif cleu == "SAA:442432:4" then cleu = nil p = "5"
						elseif cleu == "SAA:442432:5" then cleu = nil p = "6"
						end

						if not data.triggers[1] then
							data.triggers[1] = {}
						end
						data.triggers[1].event = data.zoneID and 22 or 3
						if p and p~="1" then
							local isValid = false
							if timeLineData and timeLineData.p then
								data.triggers[1].event = 2
								p = tonumber(p)
								if p then
									if isgp == "g" then
										data.triggers[1].pattFind = timeLineData.p and timeLineData.p.n and tostring(timeLineData.p.n[p-1]) or tostring(p)
									else
										data.triggers[1].pattFind = tostring(p)
									end
									if timeLineData.p.nc and tonumber(p) then
										data.triggers[1].counter = tostring(timeLineData.p.nc[tonumber(p)-1])
									end
									if data.triggers[1].pattFind then
										isValid = true
									end
								end
							end
							if not isValid then
								toadd = false
							end
						end

						if cleu then
							local isValid = false

							local cleu_event,cleu_spell,cleu_count = strsplit(":",cleu)
							if cleu_event and cleu_spell and cleu_count then
								cleu_spell = tonumber(cleu_spell)
								cleu_count = tonumber(cleu_count)

								if not cleu_spell or not cleu_count or cleu_count <= 0 then
								elseif cleu_event == "SCC" or cleu_event == "SAA" or cleu_event == "SAR" or cleu_event == "SCS" then
									data.triggers[1].event = 1
									data.triggers[1].eventCLEU = cleu_event == "SCC" and "SPELL_CAST_SUCCESS" or cleu_event == "SCS" and "SPELL_CAST_START" or cleu_event == "SAR" and "SPELL_AURA_REMOVED" or "SPELL_AURA_APPLIED"
									data.triggers[1].spellID = cleu_spell
									data.triggers[1].counter = tostring(cleu_count)
									isValid = true
								end
							end
							if not isValid then
								toadd = false
							end
						end

						local t=floor(x*10)/10
						data.triggers[1].delayTime = format("%d:%02d.%d",t/60,t%60,(t*10)%10)

						local msg = line:gsub("{time:[^}]+}",""):trim()

						if parent.opt_filter_names then
							local ability,names = strsplit("-",msg,2)
							if names then
								names = names:gsub("%b{}","")
								for n in names:gmatch("[^ ]+") do
									if not n:find("[%d_#]") then
										n = n:gsub("|+c........",""):gsub("|+r","")
										data.players[n] = true
									end
								end

								if ability then
									msg = ability
								end
							end
						end
						local everylist
						if parent.opt_everyplayer then
							for player,spell in msg:gmatch("([^ _]+) *{spell:(%d+)}") do
								player = player:gsub("||c........",""):gsub("||r","")
								if not player:find("[%d:]") and #player > 1 then
									if not everylist then everylist = {} end

									local msg1 = "{spell:"..spell.."}"
									spell = tonumber(spell)
									local name = GetSpellName(spell)
									if name then
										msg1 = msg1 .. " " .. name
									end
	
									everylist[#everylist+1] = {player,msg1}
								end
							end
						end
						if parent.opt_linesmy then
							local playerName = UnitName'player'
							if not msg:find( playerName ) then
								toadd = false
							end
						end
						if parent.opt_wordmy then
							local playerName = UnitName'player'
							if not msg:find( playerName ) then
								toadd = false
							else
								msg = msg:match(playerName.."[^ ]* ([^ ]+)")
								if not msg then
									toadd = false
								end
								if msg and msg:gsub("%b{}",""):trim() == "" and msg:find("{spell:%d+") then
									local spell = msg:match("{spell:(%d+)")
									spell = tonumber(spell)
									local name = GetSpellName(spell)
									if name then
										msg = msg .. " " .. name
									end
								end
							end
						end
						if parent.opt_rev then
							data.durrev = true
						end

						if msg:find("^ *%- *") then
							msg = msg:gsub("^ *%- *","")
						end

						data.msg = msg

						if toadd and (not p or timeLineData) then
							if everylist then
								for i=1,#everylist do
									local player,msg = everylist[i][1],everylist[i][2]
									
									local data3 = ExRT.F.table_copy2(data)
									data3.uid = options:GetNewUID()

									data3.msg = msg
									data3.players[player] = true
									data3.allPlayers = nil

									if parent.opt_spellcd then
										options:AddSpellCDCheckTrigger(data3)
									end

									module:RemAdd(data3.uid,data3)

									mainframe.undoimportlist.remove[data3.uid] = true
									print("Added line with player filter",data3.triggers[1].delayTime,player,msg)
								end
							else
								if parent.opt_spellcd then
									options:AddSpellCDCheckTrigger(data)
								end

								module:RemAdd(data.uid,data)
								print("Added line",data.triggers[1].delayTime,msg)
								mainframe.undoimportlist.remove[data.uid] = true
							end


						end
					end
				end
			end
		end

		parent:Hide()
		options:Update()
		module:ReloadAll()

		mainframe.UndoButton:Show()
	end)
	self.timeLineImportFromNoteFrame.Copy = ELib:Button(self.timeLineImportFromNoteFrame,L.ReminderImportTextFromNote):Point("BOTTOM",0,30+25*7):Size(590,20):OnClick(function()
		self.timeLineImportFromNoteFrame.Edit:SetText(GMRT.F:GetNote())
	end)

	options.timeLineImportFromNoteFrame.opt_spellcd = true
	self.timeLineImportFromNoteFrame.isSpellCDcheck = ELib:Check(self.timeLineImportFromNoteFrame,"Hide message after using a spell",true):Tooltip(L.ReminderHideMsgCheck):Point("BOTTOMLEFT",self.timeLineImportFromNoteFrame.Import,25,25):OnClick(function(self)
		if self:GetChecked() then
			options.timeLineImportFromNoteFrame.opt_spellcd = true
		else
			options.timeLineImportFromNoteFrame.opt_spellcd = nil
		end
	end)

	options.timeLineImportFromNoteFrame.opt_rev = true
	self.timeLineImportFromNoteFrame.durRevCheck = ELib:Check(self.timeLineImportFromNoteFrame,L.ReminderDurRev,true):Tooltip(L.ReminderDurRevTooltip2):Point("BOTTOMLEFT",self.timeLineImportFromNoteFrame.isSpellCDcheck,0,25):OnClick(function(self)
		if self:GetChecked() then
			options.timeLineImportFromNoteFrame.opt_rev = true
		else
			options.timeLineImportFromNoteFrame.opt_rev = nil
		end
	end)

	self.timeLineImportFromNoteFrame.removeBefore = ELib:Check(self.timeLineImportFromNoteFrame,L.ReminderRemoveBeforeExport):Tooltip(L.ReminderRemoveBeforeExportTip):Point("BOTTOMLEFT",self.timeLineImportFromNoteFrame.durRevCheck,-25,25):OnClick(function(self)
		if self:GetChecked() then
			options.timeLineImportFromNoteFrame.opt_removebefore = true
		else
			options.timeLineImportFromNoteFrame.opt_removebefore = nil
		end
	end)

	self.timeLineImportFromNoteFrame.forEveryPlayer = ELib:Check(self.timeLineImportFromNoteFrame,L.ReminderForEveryPlayer):Tooltip(L.ReminderForEveryPlayerTip):Point("BOTTOMLEFT",self.timeLineImportFromNoteFrame.removeBefore,0,25):OnClick(function(self)
		if self:GetChecked() then
			options.timeLineImportFromNoteFrame.opt_everyplayer = true
		else
			options.timeLineImportFromNoteFrame.opt_everyplayer = nil
		end
	end)

	self.timeLineImportFromNoteFrame.useFilterNames = ELib:Check(self.timeLineImportFromNoteFrame,L.ReminderImportNameAsFilter):Tooltip(L.ReminderImportNameAsFilterTip):Point("BOTTOMLEFT",self.timeLineImportFromNoteFrame.forEveryPlayer,0,25):OnClick(function(self)
		if self:GetChecked() then
			options.timeLineImportFromNoteFrame.opt_filter_names = true
		else
			options.timeLineImportFromNoteFrame.opt_filter_names = nil
		end
	end)


	self.timeLineImportFromNoteFrame.onlyMyAbility = ELib:Check(self.timeLineImportFromNoteFrame,L.ReminderImportNoteWordMy):Point("BOTTOMLEFT",self.timeLineImportFromNoteFrame.useFilterNames,0,25):OnClick(function(self)
		if self:GetChecked() then
			options.timeLineImportFromNoteFrame.opt_wordmy = true
		else
			options.timeLineImportFromNoteFrame.opt_wordmy = nil
		end
	end)

	self.timeLineImportFromNoteFrame.onlyMyNameLines = ELib:Check(self.timeLineImportFromNoteFrame,L.ReminderImportNoteLinesMy):Point("BOTTOMLEFT",self.timeLineImportFromNoteFrame.onlyMyAbility,0,25):OnClick(function(self)
		if self:GetChecked() then
			options.timeLineImportFromNoteFrame.opt_linesmy = true
		else
			options.timeLineImportFromNoteFrame.opt_linesmy = nil
		end
	end)





	self.timeLineImportFromNote = ELib:Button(self.tab.tabs[4],L.ReminderImportFromNote):Point("RIGHT",self.timeLineTestRun,"LEFT",-5,0):Size(140,20):OnClick(function()
		self.timeLineImportFromNoteFrame.mainframe = options.timeLine
		self.timeLineImportFromNoteFrame:Show()
	end)
	options.timeLine.UndoButton = ELib:Button(self.tab.tabs[4],L.ReminderUndo):Tooltip(L.ReminderUndoTip):Point("TOP",self.timeLineImportFromNote,"BOTTOM",0,0):Shown(false):Size(140,20):OnClick(function(self)
		for uid in pairs(options.timeLine.undoimportlist.remove) do
			module:RemRem(uid)
		end
		for uid,data in pairs(options.timeLine.undoimportlist.repair) do
			module:RemAdd(uid,data)
		end
		options:Update()
		module:ReloadAll()
		self:Hide()
	end):OnShow(function(self)
		if self.tmr then
			self.tmr:Cancel()
		end
		self.tmr = C_Timer.NewTimer(30,function() self:Hide() end)
	end,true)


	self.timeLineExportToNote = ELib:Button(self.tab.tabs[4],L.ReminderExportToNote):Point("RIGHT",self.timeLineImportFromNote,"LEFT",-5,0):Tooltip("Hold Shift to ignore phases and use only timer from start of the fight"):Size(140,20):OnClick(function()
		local str = options.timeLine:ExportToString()

		ExRT.F:Export(str,true)
	end)

	self.timeLineAdjustFL = ELib:Button(self.tab.tabs[4],L.ReminderAdjustFL):Point("RIGHT",self.timeLineExportToNote,"LEFT",-5,0):Size(140,20):OnEnter(function(self)
		self.subframe:Show()
	end)

	self.timeLineAdjustFL.subframe = CreateFrame("Frame",nil,self.timeLineAdjustFL)
	self.timeLineAdjustFL.subframe:SetPoint("TOPLEFT",self.timeLineAdjustFL,"BOTTOMLEFT",-40,2)
	self.timeLineAdjustFL.subframe:SetPoint("TOPRIGHT",self.timeLineAdjustFL,"BOTTOMRIGHT",40,2)
	self.timeLineAdjustFL.subframe:SetHeight(25+25*options.timeLine.TIMELINE_ADJUST_NUM)
	self.timeLineAdjustFL.subframe:Hide()
	self.timeLineAdjustFL.subframe:SetScript("OnUpdate",function(self)
		if not self:IsMouseOver() and not self:GetParent():IsMouseOver() then
			self:Hide()
		end
	end)
	self.timeLineAdjustFL.subframe.bg = self.timeLineAdjustFL.subframe:CreateTexture(nil,"BACKGROUND")
	self.timeLineAdjustFL.subframe.bg:SetAllPoints()
	self.timeLineAdjustFL.subframe.bg:SetColorTexture(0,0,0,1)

	self.timeLineAdjustFL.subframe.timeScale = ELib:Slider(self.timeLineAdjustFL.subframe):Size(100):Point("TOP",0,-5):Range(10,200,true):SetTo(options.timeLine.TIMELINE_ADJUST):OnChange(function(self,val)
		options.timeLine.TIMELINE_ADJUST = floor(val+0.5)
		if not self.lock then
			options.timeLine:Update()
			options.timeLine:UpdateTimeText()
		end
		self.tooltipText = L.ReminderGlobalTimeScale..": "..options.timeLine.TIMELINE_ADJUST .. "%"
		self:tooltipReload(self)
	end)
	self.timeLineAdjustFL.subframe.timeScale.tooltipText = L.ReminderGlobalTimeScale..": "..options.timeLine.TIMELINE_ADJUST .. "%"

	for i=1,options.timeLine.TIMELINE_ADJUST_NUM do
		options.timeLine.TIMELINE_ADJUST_DATA[i] = {0,0}
		self.timeLineAdjustFL.subframe["tpos"..i] = ELib:Edit(self.timeLineAdjustFL.subframe,"0"):Size(40,20):Point("TOPLEFT",35,-20-(i-1)*25):LeftText(L.ReminderTimeScaleT1):Tooltip(L.ReminderTimeScaleTip1):OnChange(function(self,isUser)
			if not isUser then return end
			local t = self:GetText() or ""
			t = module:ConvertMinuteStrToNum(t)
			options.timeLine.TIMELINE_ADJUST_DATA[i][1] = t and t[1] or nil

			options.timeLine:Update()
			options.timeLine:UpdateTimeText()
		end)

		self.timeLineAdjustFL.subframe["addtime"..i] = ELib:Edit(self.timeLineAdjustFL.subframe,"0"):Size(40,20):Point("LEFT",self.timeLineAdjustFL.subframe["tpos"..i],"RIGHT",55,0):LeftText(L.ReminderTimeScaleT2):RightText(L.ReminderTimeScaleT3):Tooltip(L.ReminderTimeScaleTip2):OnChange(function(self,isUser)
			if not isUser then return end
			options.timeLine.TIMELINE_ADJUST_DATA[i][2] = tonumber(self:GetText() or "")

			options.timeLine:Update()
			options.timeLine:UpdateTimeText()
		end)
	end

	self.timeLineFilterButton = ELib:DropDownButton(self.tab.tabs[4],FILTER,220,-1):Point("RIGHT",self.timeLineAdjustFL,"LEFT",-5,0):Size(140,20)
	function self.timeLineFilterButton:SetValue(arg1)
		ELib:DropDownClose()
		options.timeLine[arg1] = not options.timeLine[arg1]
		options.timeLine:Update()
	end
	function self.timeLineFilterButton:SetValueTable(arg1)
		ELib:DropDownClose()
		if options.timeLine[arg1] then
			options.timeLine[arg1] = nil
		elseif arg1 == "FILTER_SPELL" then
			local filter = {}
			local data = options.timeLine.Data[options.timeLine.BOSS_ID]
			for _,e in pairs(data.m and data or {data}) do
				if type(e) == "table" then
					for k in pairs(e) do
						filter[k] = true
					end
				end
			end
			options.timeLine[arg1] = filter
		end
		options.timeLine:Update()
	end
	self.timeLineFilterButton.List = {
		{
			text = L.ReminderFilterCasts,
			checkable = true,
			func = self.timeLineFilterButton.SetValue,
			arg1 = "FILTER_CAST",
			alter = true,
		},{
			text = L.ReminderFilterAuras,
			checkable = true,
			func = self.timeLineFilterButton.SetValue,
			arg1 = "FILTER_AURA",
			alter = true,
		},{
			text = L.ReminderPresetFilter,
			checkable = true,
			func = self.timeLineFilterButton.SetValueTable,
			arg1 = "FILTER_SPELL",
			hidF = function() if options.timeLine.Data[options.timeLine.BOSS_ID] then return true end end,
		},{
			text = " ",
			isTitle = true,
		},{
			text = L.ReminderReminders,
			isTitle = true,
		},{
			text = L.ReminderOnlyForMe,
			checkable = true,
			func = self.timeLineFilterButton.SetValue,
			arg1 = "FILTER_REM_ONLYMY",
		},{
			text = L.ReminderRepeatableFilter,
			tooltip = L.ReminderRepeatableFilterTip,
			checkable = true,
			func = self.timeLineFilterButton.SetValue,
			arg1 = "FILTER_SPELL_REP",
			alter = true,
		}
	}
	function self.timeLineFilterButton:PreUpdate()
		for i=1,#self.List do
			local line = self.List[i]
			line.checkState = (line.alter and not options.timeLine[line.arg1]) or (not line.alter and options.timeLine[line.arg1])
			if line.hidF then
				line.isHidden = not line.hidF()
			end
		end
	end
	

	options.timeLine.frame = ELib:ScrollFrame(self.tab.tabs[4]):Size(780,520):Height(520):AddHorizontal(true):Width(1000)
	ELib:Border(options.timeLine.frame,0)
	options.timeLine.frame.headers = ELib:ScrollFrame(self.tab.tabs[4]):Point("TOPLEFT",0,-50):Size(220,520):Height(500)
	ELib:Border(options.timeLine.frame.headers,0)
	options.timeLine.frame:Point("TOPLEFT",options.timeLine.frame.headers,"TOPRIGHT",0,0)
	options.timeLine.frame.D = CreateFrame("Frame",nil,options.timeLine.frame.C)
	options.timeLine.frame.D:SetAllPoints()
	options.timeLine.frame.D:SetFrameLevel(8000)

	options.timeLine.frame.ScrollBar:Hide()
	options.timeLine.frame.headers.ScrollBar:NewPoint("TOPLEFT",3,-3):Point("BOTTOMLEFT",3,3)
	options.timeLine.frame.headers.ScrollBar:Hide()

	options.timeLine.frame.lines = {}
	options.timeLine.frame.buttons = {}
	options.timeLine.frame.pcursors = {}

	function options.timeLine:UpdateScale(val,forMid)
		local x,y = ExRT.F.GetCursorPos(self.frame)
		if forMid then x = self.frame:GetWidth() / 2 end
		local htime = self:GetTimeFromPos(x + self.frame:GetHorizontalScroll())

		self.TIMELINE_SCALE = val
		self:Update()
		self:UpdateTimeText()

		local htime2 = self:GetTimeFromPos(x + self.frame:GetHorizontalScroll())

		local newVal = self.frame.ScrollBarHorizontal:GetValue() - self:GetPosFromTime(htime2-htime)
		local min,max = self.frame.ScrollBarHorizontal:GetMinMaxValues()
		if newVal < min then newVal = min end
		if newVal > max then newVal = max end
		self.frame.ScrollBarHorizontal:SetValue(newVal)

		self.frame.zoomSlider:SetTo(self.TIMELINE_SCALE)
	end

	options.timeLine.frame.zoomSlider = ELib:Slider(options.timeLine.frame,"",true):Size(40):Point("BOTTOMRIGHT",-5,-15):Range(50,110):SetTo(options.timeLine.TIMELINE_SCALE):OnChange(function(self,val)
		if self.lock then return end
		self.lock = true
		options.timeLine:UpdateScale( floor(val+0.5),true )
		self.lock = nil
	end):OnEnter(function() options.timeLine.HideCursor = true end):OnLeave(function() options.timeLine.HideCursor = false end)

	options.timeLine.frame:SetScript("OnMouseWheel", function(self,delta)
		options.timeLine:UpdateScale( options.timeLine.TIMELINE_SCALE - delta )
	end)

	options.timeLine.frame.headers:SetScript("OnVerticalScroll", function(self)
		options.timeLine.frame:SetVerticalScroll( self:GetVerticalScroll() )
	end)

	options.timeLine.frame.timeLeft = ELib:Text(self.tab.tabs[4],"0:00",14):Point("BOTTOMLEFT",options.timeLine.frame,"TOPLEFT",0,2)
	options.timeLine.frame.timeRight = ELib:Text(self.tab.tabs[4],"1:00",14):Point("BOTTOMRIGHT",options.timeLine.frame,"TOPRIGHT",0,2):Right()

	options.timeLine.frame.cursor = options.timeLine.frame.D:CreateTexture(nil,"BACKGROUND")
	options.timeLine.frame.cursor:SetWidth(2)
	options.timeLine.frame.cursor:SetPoint("BOTTOM",0,0)
	options.timeLine.frame.cursor:SetColorTexture(1,1,1,.7)
	options.timeLine.frame.cursor:Hide()

	options.timeLine.frame.cursorH = options.timeLine.frame.C:CreateTexture(nil,"BACKGROUND")
	options.timeLine.frame.cursorH:SetSize(1000,2)
	options.timeLine.frame.cursorH:SetColorTexture(.2,.2,.2,1)

	options.timeLine.frame.cursorHT2 = self.tab.tabs[4]:CreateTexture(nil,"BACKGROUND")
	options.timeLine.frame.cursorHT2:SetHeight(2)
	options.timeLine.frame.cursorHT2:SetPoint("LEFT",options,0,0)
	options.timeLine.frame.cursorHT2:SetPoint("RIGHT",options,0,0)
	options.timeLine.frame.cursorHT2:SetPoint("BOTTOM",options.timeLine.frame,"TOP",0,0)
	options.timeLine.frame.cursorHT2:SetColorTexture(.2,.2,.2,1)

	options.timeLine.frame.runLine = options.timeLine.frame.D:CreateTexture(nil,"ARTWORK",nil,3)
	options.timeLine.frame.runLine:SetWidth(2)
	options.timeLine.frame.runLine:SetPoint("TOP",options.timeLine.frame.cursorHT2,"BOTTOM",0,0)
	options.timeLine.frame.runLine:SetPoint("BOTTOM",options.timeLine.frame.cursorH,"TOP",0,0)
	options.timeLine.frame.runLine:SetColorTexture(1,0,0,1)
	options.timeLine.frame.runLine:Hide()

	options.timeLine.frame.bg = options.timeLine.frame.C:CreateTexture(nil,"BACKGROUND",nil,-8)
	options.timeLine.frame.bg:SetColorTexture(23/255, 31/255, 33/255, 1)
	options.timeLine.frame.bg:SetPoint("TOPLEFT",0,0)
	--options.timeLine.frame.bg:SetPoint("BOTTOMRIGHT",options.timeLine.frame.cursorH,"TOPRIGHT",0,0)
	--options.timeLine.frame.bg:SetPoint("BOTTOMRIGHT",0,0)
	options.timeLine.frame.bg:SetPoint("BOTTOM",0,0)
	options.timeLine.frame.bg:SetPoint("RIGHT",options,0,0)

	options.timeLine.frame.bg2 = options.timeLine.frame.C:CreateTexture(nil,"BACKGROUND",nil,-7)
	options.timeLine.frame.bg2:SetPoint("LEFT",options.timeLine.frame.bg,0,0)
	options.timeLine.frame.bg2:SetPoint("RIGHT",options.timeLine.frame.bg,0,0)
	options.timeLine.frame.bg2:SetPoint("TOP",options.timeLine.frame.cursorHT2,"BOTTOM",0,0)
	options.timeLine.frame.bg2:SetPoint("BOTTOM",options.timeLine.frame.cursorH,"TOP",0,0)
	options.timeLine.frame.bg2:SetColorTexture(1,1,1, 1)
	options.timeLine.frame.bg2:SetGradient("VERTICAL",CreateColor(0,0,0,.2), CreateColor(0,0,0,0))


	options.timeLine.frame.timeCursor = ELib:Text(self.tab.tabs[4],"1:00",14):Point("CENTER",options.timeLine.frame.cursor,"TOP",0,0):Point("BOTTOM",options.timeLine.frame,"TOP",0,2):Shown(false)

	options.timeLine.frame:SetScript("OnUpdate",function(self)
		local x,y = ExRT.F.GetCursorPos(self)

		if self.saved_x and self.saved_y then
			if abs(x - self.saved_x) > 5 then
				local newVal = self.saved_scroll - (x - self.saved_x)
				local min,max = self.ScrollBarHorizontal:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.ScrollBarHorizontal:SetValue(newVal)

				self.moveSpotted = true
			end
			if self.headers.ScrollBar:IsShown() and abs(y - self.saved_y) > 5 then
				local newVal = self.saved_scroll_v - (y - self.saved_y)
				local min,max = self.headers.ScrollBar:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.headers.ScrollBar:SetValue(newVal)

				self.moveSpotted = true
			end
		end

		if self:IsMouseOver() and (not options.quickSetupFrame:IsShown() or not options.quickSetupFrame:IsMouseOver()) and not self.moveSpotted then
			if x <= 40 and self.timeLeft:IsShown() then
				self.timeLeft:Hide()
			elseif x > 40 and not self.timeLeft:IsShown() then
				self.timeLeft:Show()
			end

			if x >= self:GetWidth()-40 and self.timeRight:IsShown() then
				self.timeRight:Hide()
			elseif x < self:GetWidth()-40 and not self.timeRight:IsShown() then
				self.timeRight:Show()
			end

			x = x + self:GetHorizontalScroll()
			self.cursor:SetPoint("TOPLEFT",x,0)

			x = options.timeLine:GetTimeFromPos(x)
			self.timeCursor:SetText(module:FormatTime(x))
			if not self.cursor:IsShown() then
				self.cursor:Show()
				self.timeCursor:Show()
			end
		elseif self.cursor:IsShown() then
			self.cursor:Hide()
			self.timeCursor:Hide()
			if not self.timeLeft:IsShown() then
				self.timeLeft:Show()
			end
			if not self.timeRight:IsShown() then
				self.timeRight:Show()
			end
		end

		if options.timeLine.HideCursor and self.cursor:IsShown() then
			self.cursor:Hide()
		end

		if module.db.simrun then
			local t = (GetTime() - module.db.simrun) * (module.db.simrunspeed or 1)
			local x = options.timeLine:GetPosFromTime(t)
			self.runLine:SetPoint("LEFT",x,0)
			if not self.runLine:IsShown() then
				self.runLine:Show()
			end
		elseif self.runLine:IsShown() then
			self.runLine:Hide()
		end
	end)

	options.timeLine.frame:SetScript("OnMouseDown",function(self)
		local x,y = ExRT.F.GetCursorPos(self)
		self.saved_x = x
		self.saved_y = y
		self.saved_scroll = self.ScrollBarHorizontal:GetValue()
		self.saved_scroll_v = self.headers.ScrollBar:GetValue()
		self.moveSpotted = nil

	end)

	options.timeLine.frame:SetScript("OnMouseUp",function(self, button)
		self.saved_x = nil
		self.saved_y = nil
		if self.moveSpotted then
			self.moveSpotted = nil
			return
		end

		local x,y = ExRT.F.GetCursorPos(self)
		x = x + self:GetHorizontalScroll()
		y = y + self:GetVerticalScroll()
		options.timeLine:ProcessClick(x, y, button)
	end)

	options.timeLine.frame.HighlighSpellLine = function(self,id,show)
		for i=1,#self.lines do
			local line = self.lines[i]
			if (line.header.spell == id and show) or not show then
				line:SetAlpha(1)
			else
				line:SetAlpha(.3)
			end
		end
	end

	function options.timeLine:UpdateTimeText()
		local x = self:GetTimeFromPos(self.frame:GetHorizontalScroll())
		self.frame.timeLeft:SetText(module:FormatTime(x))

		local x2 = self:GetTimeFromPos(self.frame:GetHorizontalScroll() + self.frame:GetWidth())
		self.frame.timeRight:SetText(module:FormatTime(x2))

		local p,s = self:GetPosFromTime(30), self:GetPosFromTime(x)
		local c = 0
		for i=ceil(s/p)*p,s + self.frame:GetWidth(),p do
			c = c + 1
			local tc = self.frame.timeCursor[c]
			if not tc then
				tc = options.tab.tabs[4]:CreateTexture(nil,"BACKGROUND")
				self.frame.timeCursor[c] = tc
				tc:SetSize(2,4)
				tc:SetPoint("BOTTOM",self.frame.cursorHT2,"TOP",0,0)
				tc:SetColorTexture(.2,.2,.2,1)
				tc:Hide()
			end
			tc:SetPoint("LEFT",self.frame,i - s,0)
			tc:Show()
		end
		for i=c+1,#self.frame.timeCursor do
			self.frame.timeCursor[i]:Hide()
		end
		
	end
	options.timeLine.frame:SetScript("OnScrollRangeChanged",function(self)
		options.timeLine:UpdateTimeText()
	end)
	options.timeLine.frame:SetScript("OnHorizontalScroll",function(self)
		options.timeLine:UpdateTimeText()
	end)

	options.timeLine.frame.bigBossButtons = CreateFrame("Button",nil,options.timeLine.frame)
	options.timeLine.frame.bigBossButtons:SetPoint("TOPLEFT",options.timeLine.frame.headers,0,0)
	options.timeLine.frame.bigBossButtons:SetPoint("BOTTOMRIGHT",options,0,0)
	options.timeLine.frame.bigBossButtons:SetFrameLevel(9000)
	options.timeLine.frame.bigBossButtons:SetFrameStrata("DIALOG")

	options.timeLine.frame.bigBossButtons.bg = options.timeLine.frame.bigBossButtons:CreateTexture(nil,"BACKGROUND",nil,-8)
	options.timeLine.frame.bigBossButtons.bg:SetColorTexture(0,0,0, 1)
	options.timeLine.frame.bigBossButtons.bg:SetAllPoints()

	options.timeLine.frame.bigBossButtons.buttons = {}
	function options.timeLine.frame.bigBossButtons:Reset()
		for i=1,#self.buttons do
			self.buttons[i]:Hide()
		end
	end
	function options.timeLine.frame.bigBossButtons:Repos(t)
		local SIZE_W = 200 * (t.mini and 0.75 or 1)
		local SIZE_H = 200 * (t.mini and 0.75 or 1)
		for i=1,#t do
			for j=1,#t[i] do
				local button = self.buttons[ t[i][j] ]
				button:ClearAllPoints()
				button:SetPoint("CENTER",-SIZE_W*(#t[i]-1)/2+(j-1)*SIZE_W,SIZE_H*(#t-1)/2-(i-1)*SIZE_H)
			end
		end
	end

	function options.timeLine.frame.bigBossButtons.Util_BottonOnEnter(self)
		self.text:Color(1,1,0,1)
	end
	function options.timeLine.frame.bigBossButtons.Util_BottonOnLeave(self)
		self.text:Color()
	end
	function options.timeLine.frame.bigBossButtons.Util_BottonOnClick(self)
		self.click()
		options.timeLine.frame.bigBossButtons:Hide()
	end

	function options.timeLine.frame.bigBossButtons:Add(encounterID,clickFunc)
		local button
		for i=1,#self.buttons do
			if not self.buttons[i]:IsShown() then
				button = self.buttons[i]
				break
			end
		end
		if not button then
			button = CreateFrame("Button",nil,self)
			self.buttons[#self.buttons+1] = button

			button._i = #self.buttons
			
			button:SetSize(150,100)

			button.bg = button:CreateTexture()
			button.bg:SetSize(128,64)
			button.bg:SetPoint("CENTER",0,20)

			button.text = ELib:Text(button,"",16):Point("TOP",button.bg,"BOTTOM",0,-5):Color():Center()
			button.text:SetWidth(150)

			button:SetScript("OnEnter",self.Util_BottonOnEnter)
			button:SetScript("OnLeave",self.Util_BottonOnLeave)
			button:SetScript("OnClick",self.Util_BottonOnClick)
		end

		local bossImg
		if ExRT.GDB.encounterIDtoEJ[encounterID] and EJ_GetCreatureInfo then
			bossImg = select(5, EJ_GetCreatureInfo(1, ExRT.GDB.encounterIDtoEJ[encounterID]))
		end

		button.text:SetText(ExRT.L.bossName[encounterID])

		button.bg:SetTexture(bossImg)
		button.click = clickFunc
		
		button:Show()

		local tr
		if button._i <= 3 then
			tr = {{}}
			for i=1,button._i do tinsert(tr[1],i) end
		elseif button._i <= 8 then
			tr = {{},{}}
			local m = ceil(button._i / 2)
			for i=1,button._i do tinsert(tr[floor((i-1)/m)+1],i) end
		elseif button._i <= 12 then
			tr = {{},{},{}}
			local m = ceil(button._i / 3)
			for i=1,button._i do tinsert(tr[floor((i-1)/m)+1],i) end
		elseif button._i <= 16 then
			tr = {{},{},{},{},mini=true}
			local m = ceil(button._i / 4)
			for i=1,button._i do tinsert(tr[floor((i-1)/m)+1],i) end
		end
		self:Repos(tr)
	end


	self.quickSetupFrame = ELib:Popup(" "):Size(510,405)
	ELib:Border(self.quickSetupFrame,1,.4,.4,.4,.9)

	function options:AddSpellCDCheckTrigger(data)
		local msg = data.msg
		if msg then
			local spellID = msg:match("^{spell:(%d+)}")
			if spellID then
				data.triggers[2] = {
					event = 13,
					spellID = tonumber(spellID),
					invert = true,
				}
				data.hideTextChanged = true
	
				return true
			end
		end
	end

	self.quickSetupFrame.saveButton = ELib:Button(self.quickSetupFrame,L.ReminderSave):Point("BOTTOMRIGHT",self.quickSetupFrame,"BOTTOM",-5,10):Size(200,20):OnClick(function(_,button)
		local data = self.quickSetupFrame.data
		self.quickSetupFrame:Hide()
		local uid = data.uid or self:GetNewUID()
		data.uid = uid

		local removeTrigger2 = true
		if data.tmp_tl_glow and data.tmp_tl_glow:trim() ~= "" then
			data.triggers[2] = {
				event = 16,
				targetName = data.tmp_tl_glow:trim():gsub(" +",";")
			}
			data.msgSize = 9
			data.glowThick = 3
			if data.triggers[1].event == 1 then
				data.specialTarget = "%target2"
			else
				data.specialTarget = nil
			end
			removeTrigger2 = false
		elseif data.tmp_tl_cd then
			if options:AddSpellCDCheckTrigger(data) then
				removeTrigger2 = false
			end
		end
		data.tmp_tl_glow = nil

		if removeTrigger2 and data.triggers[2] and ((data.triggers[2].event == 13 and data.hideTextChanged) or data.triggers[2].event == 16) then
			tremove(data.triggers, 2)
			data.hideTextChanged = nil
			data.specialTarget = nil
		end
		if module:GetReminderType(data.msgSize) == REM.TYPE_RAIDFRAME and (not data.triggers[2] or data.triggers[2].event ~= 16) then
			data.msgSize = nil
			data.specialTarget = nil
		end
		if IsShiftKeyDown() or button == "RightButton" then
			module:RemAdd(uid,data,true)
		else
			module:RemAdd(uid,data)
		end
		options:Update()
		module:ReloadAll()

		options.quickSetupFrame.prev = options.quickSetupFrame.data
		options.quickSetupFrame:Hide()
	end):OnLeave(ELib.Tooltip.Hide):OnShow(function(self)
		local data = options.quickSetupFrame.data
		local uid = data and data.uid
		if uid and module:RemGetSource(uid) == 0 then
			self.icon_shared:Show()
		elseif self.icon_shared:IsShown() then
			self.icon_shared:Hide()
		end
	end,true)
	self.quickSetupFrame.saveButton.Texture:SetGradient("VERTICAL",CreateColor(0.05,0.15,0.07,1), CreateColor(0.15,0.31,0.15,1))
	self.quickSetupFrame.saveButton:RegisterForClicks("LeftButtonUp","RightButtonUp")

	self.quickSetupFrame.saveButton.icon_shared = ELib:Icon(self.quickSetupFrame.saveButton,nil,20):Point("LEFT",'x',"RIGHT",2,0):Shown(false):Tooltip("This reminder is from shared profile. It can be rewritten/removed upon updates from other players. Hold shift or use right click for saving it to currently selected profile.\nIf you will have same reminder in shared and personal profiles than newer version will be shown.", nil, nil, nil, nil, true)
	self.quickSetupFrame.saveButton.icon_shared.texture:SetAtlas("ShipMissionIcon-Bonus-MapBadge")
	

	self.quickSetupFrame.removeButton = ELib:Button(self.quickSetupFrame,L.ReminderRemove):Point("BOTTOMRIGHT",self.quickSetupFrame,"BOTTOM",-5,10):Size(200,20):OnClick(function()
		local uid = self.quickSetupFrame.data.uid
		options:RemoveReminder(uid)
	end)
	self.quickSetupFrame.removeButton.Texture:SetGradient("VERTICAL",CreateColor(0.15,0.06,0.09,1), CreateColor(0.30,0.21,0.25,1))

	self.quickSetupFrame.copyButton = ELib:Button(self.quickSetupFrame,L.ReminderCopyPrev):Point("BOTTOM",0,35):Size(410,20):OnClick(function()
		local prev = self.quickSetupFrame.prev
		if not prev then
			return
		end
		local data = options.quickSetupFrame.data

		data.dur = prev.dur
		data.durrev = prev.durrev
		data.countdown = prev.countdown
		data.msg = prev.msg
		data.countdown = prev.countdown
		data.countdownVoice = prev.countdownVoice
		data.sound = prev.sound
		data.allPlayers = prev.allPlayers
		data.sounddelay = prev.sounddelay
		data.tmp_tl_cd = prev.tmp_tl_cd

		if prev.triggers[2] and prev.triggers[2].event == 16 and module:GetReminderType(prev.msgSize) == REM.TYPE_RAIDFRAME then
			data.triggers[2] = ExRT.F.table_copy2(prev.triggers[2])
			data.msgSize = prev.msgSize
		end
		data.glowColor = prev.glowColor

		for k in pairs(data.players) do data.players[k]=nil end
		for k in pairs(prev.players) do data.players[k]=true end

		for k,v in pairs(data) do if type(k)=="string" and k:find("^role") then data[k]=nil end end
		for k,v in pairs(data) do if type(k)=="string" and k:find("^class") then data[k]=nil end end

		for k,v in pairs(prev) do if type(k)=="string" and k:find("^role") then data[k]=v end end
		for k,v in pairs(prev) do if type(k)=="string" and k:find("^class") then data[k]=v end end
		
		options.quickSetupFrame:Update(data)
	end)

	self.quickSetupFrame.quickFilter = ELib:DropDown(self.quickSetupFrame,220,-1):AddText("|cffffd100"..L.ReminderQuickFilter..":"):Size(270):Point("TOPLEFT",180,-10)
	do
		self.quickSetupFrame.quickFilter.List[#self.quickSetupFrame.quickFilter.List+1] = {
			text = L.ReminderAllPlayers,
			func = function()
				options.quickSetupFrame.data.allPlayers = true
				for k,v in pairs(options.quickSetupFrame.data.players) do options.quickSetupFrame.data.players[k]=nil end
				for k,v in pairs(options.quickSetupFrame.data) do if type(k)=="string" and k:find("^role") then options.quickSetupFrame.data[k]=nil end end
				for k,v in pairs(options.quickSetupFrame.data) do if type(k)=="string" and k:find("^class") then options.quickSetupFrame.data[k]=nil end end
				ELib:DropDownClose()
				self.quickSetupFrame.quickFilter:Update()
			end
		}

		self.quickSetupFrame.quickFilter.List[#self.quickSetupFrame.quickFilter.List+1] = {
			text = L.ReminderPlayerNames,
			func = function()
				options.quickSetupFrame.quickFilter:SetText(L.ReminderPlayerNames)
				options.quickSetupFrame.playersEdit:SetText("")
				options.quickSetupFrame.playersEdit:ExtraShow()
				ELib:DropDownClose()
			end,
		}
		local PLAYER = (ExRT.F.utf8sub(PLAYER, 1, 1)):upper() .. ExRT.F.utf8sub(PLAYER, 2)
		self.quickSetupFrame.quickFilter.List[#self.quickSetupFrame.quickFilter.List+1] = {
			text = PLAYER,
			func = function()
				options.quickSetupFrame.data.allPlayers = nil
				for k,v in pairs(options.quickSetupFrame.data.players) do options.quickSetupFrame.data.players[k]=nil end
				for k,v in pairs(options.quickSetupFrame.data) do if type(k)=="string" and k:find("^role") then options.quickSetupFrame.data[k]=nil end end
				for k,v in pairs(options.quickSetupFrame.data) do if type(k)=="string" and k:find("^class") then options.quickSetupFrame.data[k]=nil end end
				options.quickSetupFrame.quickFilter:SetText(PLAYER)
				options.quickSetupFrame.data.players[ UnitName'player' ] = true
				options.quickSetupFrame.playersEdit:SetText(UnitName'player')
				options.quickSetupFrame.playersEdit:ExtraShow()
				ELib:DropDownClose()
			end,
		}

		local listNow = {}
		self.quickSetupFrame.quickFilter.List[#self.quickSetupFrame.quickFilter.List+1] = {
			text = L.ReminderRoles,
			subMenu = listNow,
		}
		for i=1,#module.datas.rolesList do
			local token = module.datas.rolesList[i][1]
			listNow[#listNow+1] = {
				text = module.datas.rolesList[i][2],
				func = function()
					for k,v in pairs(options.quickSetupFrame.data.players) do options.quickSetupFrame.data.players[k]=nil end
					for k,v in pairs(options.quickSetupFrame.data) do if type(k)=="string" and k:find("^role") then options.quickSetupFrame.data[k]=nil end end
					for k,v in pairs(options.quickSetupFrame.data) do if type(k)=="string" and k:find("^class") then options.quickSetupFrame.data[k]=nil end end
					options.quickSetupFrame.data["role"..token] = true
					options.quickSetupFrame.data.allPlayers = nil
					ELib:DropDownClose()
					self.quickSetupFrame.quickFilter:Update()
				end
			}
		end

		local listNow = {}
		self.quickSetupFrame.quickFilter.List[#self.quickSetupFrame.quickFilter.List+1] = {
			text = CLASS or "Class",
			subMenu = listNow,
		}
		for i=1,#ExRT.GDB.ClassList do
			local class = ExRT.GDB.ClassList[i]
			listNow[#listNow+1] = {
				text = (RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr or "")..L.classLocalizate[class],
				func = function()
					for k,v in pairs(options.quickSetupFrame.data.players) do options.quickSetupFrame.data.players[k]=nil end
					for k,v in pairs(options.quickSetupFrame.data) do if type(k)=="string" and k:find("^role") then options.quickSetupFrame.data[k]=nil end end
					for k,v in pairs(options.quickSetupFrame.data) do if type(k)=="string" and k:find("^class") then options.quickSetupFrame.data[k]=nil end end
					options.quickSetupFrame.data["class"..class] = true
					options.quickSetupFrame.data.allPlayers = nil
					ELib:DropDownClose()
					self.quickSetupFrame.quickFilter:Update()
				end
			}
		end

		self.quickSetupFrame.quickFilter.Update = function(self)
			local res = ""

			options.quickSetupFrame.playersEdit:ExtraShow(true)
			if options.quickSetupFrame.data.allPlayers then
				res = res .. L.ReminderAllPlayers .. ","
			end
			local pnames_title_added
			for k in pairs(options.quickSetupFrame.data.players) do 
				if not pnames_title_added then
					res = res .. L.ReminderPlayerNames .. ","
					pnames_title_added = true
				end

				local str = ""
				for k in pairs(options.quickSetupFrame.data.players) do 
					str = str .. k .. " "
				end
				options.quickSetupFrame.playersEdit:SetText(str:trim())
				options.quickSetupFrame.playersEdit:ExtraShow()
			end
			for k,v in pairs(options.quickSetupFrame.data) do 
				if type(k)=="string" and k:find("^role") then 
					local token = k:match("^role(.-)$")
					for i=1,#module.datas.rolesList do
						if tostring(module.datas.rolesList[i][1]) == token then
							res = res .. module.datas.rolesList[i][2] .. ","
						end
					end
				elseif type(k)=="string" and k:find("^class") then 
					local class = k:match("^class(.-)$")
					for i=1,#ExRT.GDB.ClassList do
						if ExRT.GDB.ClassList[i] == class then
							res = res .. (RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr or "")..L.classLocalizate[class] .. "|r,"
						end
					end
				end 
			end

			res = res:gsub(",$","")
			self:SetText(res)
		end
	end
	self.quickSetupFrame.playersEdit = ELib:Edit(self.quickSetupFrame):Size(270,20):Point("TOPLEFT",self.quickSetupFrame.quickFilter,"BOTTOMLEFT",0,-5+25):Shown(false):LeftText(L.ReminderPlayerNames..":"):Tooltip(L.ReminderPlayerNamesTip):OnChange(function(self,isUser)
		if not isUser then return end
		for k,v in pairs(options.quickSetupFrame.data.players) do
			options.quickSetupFrame.data.players[k] = nil
		end
		local names = {strsplit(" ",self:GetText():gsub(" +"," "):trim(),nil)}
		for i=1,#names do
			options.quickSetupFrame.data.players[ names[i] ]=true
		end
		if #names > 0 then
			options.quickSetupFrame.data.allPlayers = nil
		else
			options.quickSetupFrame.data.allPlayers = true
		end
	end)
	function self.quickSetupFrame.playersEdit:ExtraShow(isHide)
		if isHide then
			self:Point("TOPLEFT",options.quickSetupFrame.quickFilter,"BOTTOMLEFT",0,-5+25):Shown(false)
		else
			self:Point("TOPLEFT",options.quickSetupFrame.quickFilter,"BOTTOMLEFT",0,-5):Shown(true)
		end
	end

	self.quickSetupFrame.spellDD = ELib:DropDown(self.quickSetupFrame,220,-1):AddText("|cffffd100"..L.cd2TextSpell..":"):Size(270):Point("TOPLEFT",self.quickSetupFrame.playersEdit,"BOTTOMLEFT",0,-5)

	self.quickSetupFrame.spellDD.recent = {}

	function self.quickSetupFrame.spellDD:ModText(isFromEdit)
		local msg = options.quickSetupFrame.msgEdit:GetText() or ""
		local spell = options.quickSetupFrame.spellDD.spell

		if msg:trim() == "" and spell and not isFromEdit then
			local spellName,_,spellTexture = GetSpellInfo(spell or 0)
			if spellName then
				msg = spellName
			end
		end

		if spell then
			msg = "{spell:"..spell.."} "..msg
		end

		if msg:trim() == "" then msg = nil end
		options.quickSetupFrame.data.msg = msg

		local showedText = msg and msg:gsub("^{spell:%d+} *","",1) or ""
		if showedText ~= options.quickSetupFrame.msgEdit:GetText() then
			options.quickSetupFrame.msgEdit:SetText(showedText)
		end
	end

	self.quickSetupFrame.spellDD.SetValue = function(_,arg1)
		local isCustom
		if arg1 == -1 then
			arg1 = nil
			options.quickSetupFrame.spellDD_extra:Point("TOPLEFT",options.quickSetupFrame.spellDD,"BOTTOMLEFT",0,-5):Shown(true)
			self.quickSetupFrame.spellDD:SetText(L.ReminderCustom)
			local spell = (options.quickSetupFrame.data.msg or ""):match("{spell:(%d+)}")
			options.quickSetupFrame.spellDD_extra:SetText(spell or "")
			isCustom = true
		else
			options.quickSetupFrame.spellDD_extra:Point("TOPLEFT",options.quickSetupFrame.spellDD,"BOTTOMLEFT",0,-5+25):Shown(false)
		end
		self.quickSetupFrame.spellDD.spell = arg1
		if arg1 then
			local spellName,_,spellTexture = GetSpellInfo(arg1)
			self.quickSetupFrame.spellDD:SetText( (spellTexture and "|T"..spellTexture..":20|t " or "")..(spellName or "spell:"..arg1) )

			if spellName then
				for i=5,1,-1 do
					if self.quickSetupFrame.spellDD.recent[i] == arg1 then
						tremove(self.quickSetupFrame.spellDD.recent, i)	
					end
				end
				tinsert(self.quickSetupFrame.spellDD.recent, 1, arg1)
				for i=6,#self.quickSetupFrame.spellDD.recent do
					self.quickSetupFrame.spellDD.recent[i] = nil
				end
			end
		elseif not isCustom then
			self.quickSetupFrame.spellDD:SetText("-")
		end
		options.quickSetupFrame.spellDD:ModText()

		options.quickSetupFrame.msgEdit:UpdateColorBorder()
		ELib:DropDownClose()
	end
	self.quickSetupFrame.cooldownCheck = ELib:Check(self.quickSetupFrame,""):Tooltip(L.ReminderHideMsgCheck):Point("LEFT",self.quickSetupFrame.spellDD,"RIGHT",5,0):OnClick(function(self)
		if self:GetChecked() then
			options.quickSetupFrame.data.tmp_tl_cd = true
		else
			options.quickSetupFrame.data.tmp_tl_cd = nil
		end
	end)
	do
		local cd_module = ExRT.A.ExCD2
		local List = self.quickSetupFrame.spellDD.List
		List[#List+1] = {
			text = L.ReminderRecent,
			subMenu = {},
		}
		for i=1,#cd_module.db.AllSpells do
			local line = cd_module.db.AllSpells[i]
			local class = strsplit(",",line[2] or "")
			if class and ExRT.GDB.ClassID[class] then
				local l
				for j=1,#List do
					if List[j].arg1 == class then
						l = List[j].subMenu
						break
					end
				end
				if not l then
					l = {
						text = L.classLocalizate[class],
						colorCode = (RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr or ""),
						arg1 = class,
						subMenu = {},
					}
					List[#List+1] = l
					l = l.subMenu
				end

				local name = GetSpellName(line[1])
				local texture = GetSpellTexture(line[1])
				name = name or "spell:"..line[1]

				for j=4,8 do
					if line[j] then
						local specSubMenu
						if j > 4 then
							for k=1,#l do
								if l[k].s == j then
									specSubMenu = l[k]
									break
								end
							end 
							if not specSubMenu then
								local specID = ExRT.GDB.ClassSpecializationList[class] and ExRT.GDB.ClassSpecializationList[class][j-4]
								specSubMenu = {
									text = specID and L.specLocalizate[ cd_module.db.specInLocalizate[specID] ] or "Spec "..j,
									s = j,
									subMenu = {},
									arg2 = "aaa"..string.char(64+j),
									icon = specID and ExRT.GDB.ClassSpecializationIcons[specID],
								}
								l[#l+1] = specSubMenu
							end
							specSubMenu = specSubMenu.subMenu
						else
							specSubMenu = l
						end

						specSubMenu[#specSubMenu+1] = {
							text = (texture and "|T"..texture..":20|t " or "")..name,
							arg1 = line[1],
							arg2 = name,
							func = self.quickSetupFrame.spellDD.SetValue,
						}
					end
				end
			end
		end
		for i=1,#List do
			if List[i].subMenu then
				for j=1,#List[i].subMenu do
					if List[i].subMenu[j].subMenu then
						sort(List[i].subMenu[j].subMenu,function(a,b) return a.arg2 < b.arg2 end)
					end
				end
				sort(List[i].subMenu,function(a,b) return a.arg2 < b.arg2 end)
			end
		end
		List[#List+1] = {
			text = L.ReminderBoss,
			subMenu = {},
		}
		List[#List+1] = {
			text = L.ReminderCustom,
			arg1 = -1,
			func = self.quickSetupFrame.spellDD.SetValue,
		}
		List[#List+1] = {
			text = "-",
			arg1 = nil,
			func = self.quickSetupFrame.spellDD.SetValue,
		}
		function self.quickSetupFrame.spellDD:PreUpdate()
			for i=1,#self.List do
				if self.List[i].text == L.ReminderBoss then
					local subMenu = self.List[i].subMenu
					wipe(subMenu)
				
					if options.timeLine.timeLineData then
						for k in pairs(options.timeLine.timeLineData) do
							if type(k) == "number" then
								local name = GetSpellName(k)
								if name then
									local texture = GetSpellTexture(k)
									subMenu[#subMenu+1] = {
										text = (texture and "|T"..texture..":20|t " or "")..name,
										arg1 = k,
										arg2 = name,
										func = self.SetValue,
									}
								end
							end
						end
						sort(subMenu,function(a,b) return a.arg2 < b.arg2 end)
						self.List[i].isHidden = false
					else
						self.List[i].isHidden = true
					end		
				elseif self.List[i].text == L.ReminderRecent then
					local subMenu = self.List[i].subMenu
					wipe(subMenu)
				
					if #options.quickSetupFrame.spellDD.recent > 0 then
						for _,k in ipairs(options.quickSetupFrame.spellDD.recent) do
							if type(k) == "number" then
								local name = GetSpellName(k)
								if name then
									local texture = GetSpellTexture(k)
									subMenu[#subMenu+1] = {
										text = (texture and "|T"..texture..":20|t " or "")..name,
										arg1 = k,
										arg2 = name,
										func = self.SetValue,
									}
								end
							end
						end
						self.List[i].isHidden = false

						self.List[i].arg1 = subMenu[1].arg1
						self.List[i].arg2 = subMenu[1].arg2
						self.List[i].func = subMenu[1].func
					else
						self.List[i].isHidden = true
					end
				end
			end
		end
	end
	self.quickSetupFrame.spellDD_extra = ELib:Edit(self.quickSetupFrame,nil,true):Size(270,20):Point("TOPLEFT",self.quickSetupFrame.spellDD,"BOTTOMLEFT",0,-5+25):LeftText(L.ReminderCustom.." "..L.cd2TextSpell..":"):Shown(false):OnChange(function(self,isUser)
		local text = self:GetText():trim()
		if text == "" then text = nil end
		local texture = GetSpellTexture(text or "")
		self:InsideIcon(texture)
		if not isUser then return end
		if texture then
			options.quickSetupFrame.spellDD.spell = text
		else
			options.quickSetupFrame.spellDD.spell = nil
		end
		options.quickSetupFrame.spellDD:ModText(true)
		options.quickSetupFrame.msgEdit:UpdateColorBorder()
	end)
	function self.quickSetupFrame.spellDD_extra:ExtraHide()
		options.quickSetupFrame.spellDD_extra:Point("TOPLEFT",options.quickSetupFrame.spellDD,"BOTTOMLEFT",0,-5+25):Shown(false)
	end

	self.quickSetupFrame.msgEdit = ELib:Edit(self.quickSetupFrame):Size(270,20):Point("TOPLEFT",self.quickSetupFrame.spellDD_extra,"BOTTOMLEFT",0,-5):LeftText(L.ReminderMsg..":"):OnChange(function(self,isUser)
		local text = self:GetText():trim()
		if text == "" then text = nil end
		self:UpdateColorBorder()
		if not isUser then return end
		options.quickSetupFrame.spellDD:ModText(true)
		self:UpdateColorBorder()
	end)
	function self.quickSetupFrame.msgEdit:UpdateColorBorder()
		local text = options.quickSetupFrame.data.msg
		if text and text:trim() == "" then text = nil end
		if not text and not options.quickSetupFrame.data.tmp_tl_glow then self:ColorBorder(true) else self:ColorBorder(false) end	  
	end

	self.quickSetupFrame.msgEdit.colorButton = CreateFrame("Button",nil,self.quickSetupFrame.msgEdit)
	self.quickSetupFrame.msgEdit.colorButton:SetPoint("LEFT", self.quickSetupFrame.msgEdit, "RIGHT", 3, 0)
	self.quickSetupFrame.msgEdit.colorButton:SetSize(24,24)
	self.quickSetupFrame.msgEdit.colorButton:SetScript("OnClick",function(self)
		if ColorPickerFrame.SetupColorPickerAndShow then
			local info = {}
			info.r, info.g, info.b = 1,1,1
			if options.quickSetupFrame.msgEdit then
				local at,rt,gt,bt = options.quickSetupFrame.msgEdit:GetText():match("|c(..)(..)(..)(..)")
				if bt then
					info.r, info.g, info.b = tonumber(rt,16)/255,tonumber(gt,16)/255,tonumber(bt,16)/255,tonumber(at,16)/255
				end
			end
			info.opacity = 1
			info.hasOpacity = false
			info.swatchFunc = function()
				local btn = ColorPickerFrame.Footer and ColorPickerFrame.Footer.OkayButton or ColorPickerOkayButton
				if not MouseIsOver(btn) or IsMouseButtonDown() then return end
				local r,g,b = ColorPickerFrame:GetColorRGB()
				local code = format("%02x%02x%02x",r*255,g*255,b*255)
				local hlstart,hlend = options.quickSetupFrame.msgEdit:GetTextHighlight()
				if hlstart == hlend then
					if options.quickSetupFrame.msgEdit:GetText():find("||cff") then
						options.quickSetupFrame.msgEdit:SetText( options.quickSetupFrame.msgEdit:GetText():gsub("||cff......","||cff"..code) )
					else
						options.quickSetupFrame.msgEdit:SetText( "||cff"..code..options.quickSetupFrame.msgEdit:GetText().."||r" )
					end
				else
					local text = options.quickSetupFrame.msgEdit:GetText()
					text = text:sub(1, hlend) .. "||r" .. text:sub(hlend+1)
					text = text:sub(1, hlstart) .. "||cff"..code .. text:sub(hlstart+1)
					options.quickSetupFrame.msgEdit:SetText( text )
				end
				options.quickSetupFrame.msgEdit:GetScript("OnTextChanged")(options.quickSetupFrame.msgEdit,true)
			end
			info.cancelFunc = function()
				local newR, newG, newB, newA = ColorPickerFrame:GetPreviousValues()
			end
			ColorPickerFrame:SetupColorPickerAndShow(info)
		end
	end)
	self.quickSetupFrame.msgEdit.colorButton:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L.ReminderSelectColor)
		GameTooltip:Show()
	end)
	self.quickSetupFrame.msgEdit.colorButton:SetScript("OnLeave",function(self)
		GameTooltip_Hide()
	end)
	self.quickSetupFrame.msgEdit.colorButton.Texture = self.quickSetupFrame.msgEdit.colorButton:CreateTexture(nil,"ARTWORK")
	self.quickSetupFrame.msgEdit.colorButton.Texture:SetPoint("CENTER")
	self.quickSetupFrame.msgEdit.colorButton.Texture:SetSize(20,20)
	self.quickSetupFrame.msgEdit.colorButton.Texture:SetTexture([[Interface\AddOns\MRT\media\wheeltexture]])


	self.quickSetupFrame.eventDD = ELib:DropDown(self.quickSetupFrame,220,-1):AddText("|cffffd100"..L.ReminderCond..":"):Size(270):Point("TOPLEFT",self.quickSetupFrame.msgEdit,"BOTTOMLEFT",0,-5)
	do
		self.quickSetupFrame.eventDD.SliderHidden = true

		self.quickSetupFrame.eventDD.List[#self.quickSetupFrame.eventDD.List+1] = {
			text = module.C[22].lname,
			func = function()
				if options.quickSetupFrame.mainframe.SAVED_VAR_X then
					local t=floor(options.quickSetupFrame.mainframe.SAVED_VAR_X*10)/10
					options.quickSetupFrame.data.triggers[1].delayTime = format("%d:%02d.%d",t/60,t%60,(t*10)%10)
				end
				options.quickSetupFrame.data.triggers[1].event = 22
				options.quickSetupFrame.data.zoneID = options.quickSetupFrame.mainframe.SAVED_VAR_ZONE
				options.quickSetupFrame.data.bossID = nil
				ELib:DropDownClose()
				self.quickSetupFrame:Update(options.quickSetupFrame.data)
			end
		}
		self.quickSetupFrame.eventDD.List[#self.quickSetupFrame.eventDD.List+1] = {
			text = module.C[3].lname,
			func = function()
				local saved = module.options.quickSetupFrame.mainframe.ZONE_ID and options.quickSetupFrame.mainframe.SAVED_VAR_XP or options.quickSetupFrame.mainframe.SAVED_VAR_X
				if saved then
					local t=floor(saved*10)/10
					options.quickSetupFrame.data.triggers[1].delayTime = format("%d:%02d.%d",t/60,t%60,(t*10)%10)
				end
				options.quickSetupFrame.data.triggers[1].event = 3
				options.quickSetupFrame.data.zoneID = nil
				options.quickSetupFrame.data.bossID = options.quickSetupFrame.mainframe.SAVED_VAR_BOSS_ZONE or options.quickSetupFrame.mainframe.SAVED_VAR_BOSS
				ELib:DropDownClose()
				self.quickSetupFrame:Update(options.quickSetupFrame.data)
			end
		}
		self.quickSetupFrame.eventDD.List[#self.quickSetupFrame.eventDD.List+1] = {
			text = module.C[2].lname,
			func = function()
				if options.quickSetupFrame.mainframe.SAVED_VAR_XP then
					local t=floor(options.quickSetupFrame.mainframe.SAVED_VAR_XP*10)/10
					options.quickSetupFrame.data.triggers[1].delayTime = format("%d:%02d.%d",t/60,t%60,(t*10)%10)
					options.quickSetupFrame.data.triggers[1].pattFind = options.quickSetupFrame.mainframe.SAVED_VAR_P
				else
					options.quickSetupFrame.data.triggers[1].pattFind = "1"
				end
				if options.quickSetupFrame.mainframe.SAVED_VAR_PC then
					options.quickSetupFrame.data.triggers[1].counter = tostring(options.quickSetupFrame.mainframe.SAVED_VAR_PC)
				else
					options.quickSetupFrame.data.triggers[1].counter = nil
				end
				options.quickSetupFrame.data.triggers[1].event = 2
				options.quickSetupFrame.data.zoneID = nil
				options.quickSetupFrame.data.bossID = options.quickSetupFrame.mainframe.SAVED_VAR_BOSS
				ELib:DropDownClose()
				self.quickSetupFrame:Update(options.quickSetupFrame.data)
			end
		}
		local function SetCLEU(_,event)
			local t=floor(options.quickSetupFrame.mainframe.SAVED_VAR_S*10)/10
			options.quickSetupFrame.data.triggers[1].event = 1
			options.quickSetupFrame.data.triggers[1].eventCLEU = event
			options.quickSetupFrame.data.triggers[1].spellID = tonumber(options.quickSetupFrame.mainframe.SAVED_VAR_SID)
			options.quickSetupFrame.data.triggers[1].delayTime = format("%d:%02d.%d",t/60,t%60,(t*10)%10)
			options.quickSetupFrame.data.triggers[1].counter = tostring(options.quickSetupFrame.mainframe.SAVED_VAR_SC)
			options.quickSetupFrame.data.zoneID = options.quickSetupFrame.mainframe.SAVED_VAR_ZONE
			options.quickSetupFrame.data.bossID = options.quickSetupFrame.mainframe.SAVED_VAR_BOSS
			ELib:DropDownClose()
			self.quickSetupFrame:Update(options.quickSetupFrame.data)
		end
		self.quickSetupFrame.eventDD.List[#self.quickSetupFrame.eventDD.List+1] = {
			text = module.C["SPELL_CAST_SUCCESS"].lname,
			func = SetCLEU,
			arg1 = "SPELL_CAST_SUCCESS",
		}
		self.quickSetupFrame.eventDD.List[#self.quickSetupFrame.eventDD.List+1] = {
			text = module.C["SPELL_AURA_REMOVED"].lname,
			func = SetCLEU,
			arg1 = "SPELL_AURA_REMOVED",
		}
		self.quickSetupFrame.eventDD.List[#self.quickSetupFrame.eventDD.List+1] = {
			text = module.C["SPELL_AURA_APPLIED"].lname,
			func = SetCLEU,
			arg1 = "SPELL_AURA_APPLIED",
		}
		self.quickSetupFrame.eventDD.List[#self.quickSetupFrame.eventDD.List+1] = {
			text = module.C["SPELL_CAST_START"].lname,
			func = SetCLEU,
			arg1 = "SPELL_CAST_START",
		}
		function self.quickSetupFrame.eventDD:PreUpdate()
			self.List[1].isHidden = (not options.quickSetupFrame.mainframe.ZONE_ID) and true or false
			self.List[3].isHidden = options.quickSetupFrame.mainframe.ZONE_ID and true or false
			self.List[4].isHidden = (not options.quickSetupFrame.mainframe.SAVED_VAR_S or (options.quickSetupFrame.mainframe.timeLineData[options.quickSetupFrame.mainframe.SAVED_VAR_SID].spellType or 1) ~= 1) and true or false
			self.List[5].isHidden = (not options.quickSetupFrame.mainframe.SAVED_VAR_S or (options.quickSetupFrame.mainframe.timeLineData[options.quickSetupFrame.mainframe.SAVED_VAR_SID].spellType or 1) ~= 2) and true or false
			self.List[6].isHidden = options.quickSetupFrame.data.triggers[1].eventCLEU ~= "SPELL_AURA_APPLIED"
			self.List[7].isHidden = options.quickSetupFrame.data.triggers[1].eventCLEU ~= "SPELL_CAST_START"

			self.List[4].isTitle = not options.quickSetupFrame.mainframe.SAVED_VAR_S and true or false
			self.List[5].isTitle = not options.quickSetupFrame.mainframe.SAVED_VAR_S and true or false
			self.List[6].isTitle = not options.quickSetupFrame.mainframe.SAVED_VAR_S and true or false
			self.List[7].isTitle = not options.quickSetupFrame.mainframe.SAVED_VAR_S and true or false
		end

		self.quickSetupFrame.eventDD.Update = function(self)
			local trigger = options.quickSetupFrame.data.triggers[1]
			if trigger.event == 2 then
				options.quickSetupFrame.eventDD_extra:Point("TOPLEFT",options.quickSetupFrame.eventDD,"BOTTOMLEFT",0,-5):Shown(true)

				options.quickSetupFrame.eventDD_extra:ExtraText(trigger.counter and "["..trigger.counter.."]" or "")
			else
				options.quickSetupFrame.eventDD_extra:Point("TOPLEFT",options.quickSetupFrame.eventDD,"BOTTOMLEFT",0,-5+25):Shown(false)
			end
			if trigger.event == 1 then
				local name,_,texture = GetSpellInfo(trigger.spellID or 0)
				self:TextInside((trigger.counter and "["..trigger.counter.."]" or "")..(texture and "|T"..texture..":0|t" or "")..(name or ""),10)
			else
				self:TextInside("",10)
			end
			for n,e in pairs(module.C) do
				if (e.id == trigger.event and trigger.event ~= 1) or (trigger.event == 1 and n == trigger.eventCLEU) then
					self:SetText(e.lname)
					return
				end
			end
			self:SetText("Event "..trigger.event)
		end
	end
	self.quickSetupFrame.eventDD_extra = ELib:Edit(self.quickSetupFrame):Size(270,20):Point("TOPLEFT",self.quickSetupFrame.eventDD,"BOTTOMLEFT",0,-5+25):LeftText(L.ReminderBossPhaseLabel):Shown(false):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		options.quickSetupFrame.data.triggers[1].pattFind = text
	end)


	self.quickSetupFrame.timeEdit = ELib:Edit(self.quickSetupFrame):Size(200,20):Point("TOPLEFT",self.quickSetupFrame.eventDD_extra,"BOTTOMLEFT",0,-5):LeftText(L.ReminderDelay..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		options.quickSetupFrame.data.triggers[1].delayTime = text
	end)

	self.quickSetupFrame.timeEdit.mod = ELib:DropDown(self.quickSetupFrame.timeEdit,100,-1):Point("LEFT",self.quickSetupFrame.timeEdit,"RIGHT",5,0):Size(65):SetText("Mod")
	function self.quickSetupFrame.timeEdit.mod:SetValue(arg1)
		local dt = module:ConvertMinuteStrToNum(options.quickSetupFrame.data.triggers[1].delayTime)
		if not dt or not dt[1] then
			return
		end
		local didSomething = false
		if options.quickSetupFrame.mainframe and options.quickSetupFrame.mainframe.SAVED_VAR_X then
			local phase1, phase_time1 = options.quickSetupFrame.mainframe:GetPhaseFromTime(options.quickSetupFrame.mainframe.SAVED_VAR_X)
			local phase2, phase_time2, phaseCount, phaseNum = options.quickSetupFrame.mainframe:GetPhaseFromTime(options.quickSetupFrame.mainframe.SAVED_VAR_X + arg1)
			if phase1 ~= phase2 and phase_time2 then
				options.quickSetupFrame.data.triggers[1].pattFind = tostring(phase2)
				options.quickSetupFrame.data.triggers[1].event = 2
				options.quickSetupFrame.data.triggers[1].delayTime = module:FormatTime2(phase_time2)
				if phaseCount then
					options.quickSetupFrame.data.triggers[1].counter = tostring(phaseCount)
				else
					options.quickSetupFrame.data.triggers[1].counter = nil
				end

				options.quickSetupFrame:Update(options.quickSetupFrame.data)

				didSomething = true
			end
		end
		if not didSomething then
			dt = dt[1] + arg1
			if dt < 0 then dt = 0 end
			options.quickSetupFrame.data.triggers[1].delayTime = module:FormatTime2(dt)
		end
		options.quickSetupFrame.timeEdit:SetText(options.quickSetupFrame.data.triggers[1].delayTime)
		ELib:DropDownClose()
	end
	for i=-20,20 do
		if (abs(i)<=10 or abs(i)%5 == 0) and i ~= 0 then
			self.quickSetupFrame.timeEdit.mod.List[#self.quickSetupFrame.timeEdit.mod.List+1] = {
				text = (i>0 and "+" or "")..i,
				arg1 = i,
				func = self.quickSetupFrame.timeEdit.mod.SetValue,
			}
		end
	end
	self.quickSetupFrame.timeEdit.mod.List[#self.quickSetupFrame.timeEdit.mod.List+1] = {
		text = "Round",
		func = function()
			local dt = module:ConvertMinuteStrToNum(options.quickSetupFrame.data.triggers[1].delayTime)
			if not dt or not dt[1] then
				return
			end
			dt = floor(dt[1] + 0.5)
			if dt < 0 then dt = 0 end
			options.quickSetupFrame.data.triggers[1].delayTime = module:FormatTime(dt)
			options.quickSetupFrame.timeEdit:SetText(options.quickSetupFrame.data.triggers[1].delayTime)
			ELib:DropDownClose()
		end,
	}


	self.quickSetupFrame.durEdit = ELib:Edit(self.quickSetupFrame):Size(135,20):Point("TOPLEFT",self.quickSetupFrame.timeEdit,"BOTTOMLEFT",0,-5):LeftText(L.ReminderDuration..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		if text then text = tonumber(text) end
		options.quickSetupFrame.data.dur = text
	end)

	self.quickSetupFrame.durRevese = ELib:Check(self.quickSetupFrame,L.ReminderDurRev):Tooltip(L.ReminderDurRevTooltip):Point("LEFT",self.quickSetupFrame.durEdit,"RIGHT",5,0):OnClick(function(self)
		if self:GetChecked() then
			options.quickSetupFrame.data.durrev = true
		else
			options.quickSetupFrame.data.durrev = nil
		end
	end)


	self.quickSetupFrame.countdownCheck = ELib:Check(self.quickSetupFrame,L.ReminderCountdown..":"):Left(5):Tooltip(L.ReminderCountdownTooltip):Point("TOPLEFT",self.quickSetupFrame.durEdit,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			options.quickSetupFrame.data.countdown = true
		else
			options.quickSetupFrame.data.countdown = nil
		end
		options.quickSetupFrame.countdownVoice:Update()
	end)

	self.quickSetupFrame.countdownVoice = ELib:DropDown(self.quickSetupFrame,220,10):AddText("|cffffd100"..L.ReminderCountdownVoice..":"):Point("TOPLEFT",self.quickSetupFrame.countdownCheck,"BOTTOMLEFT",0,-5+25):Shown(false):Size(270)
	do
		local function countdownVoice_SetValue(_,arg1)
			ELib:DropDownClose()
			options.quickSetupFrame.data.countdownVoice = arg1
			local val = ExRT.F.table_find3(module.datas.vcountdowns,arg1,1)
			if val then
				self.quickSetupFrame.countdownVoice:SetText(val[2])
			else
				self.quickSetupFrame.countdownVoice:SetText("-")
			end
		end
		self.quickSetupFrame.countdownVoice.SetValue = countdownVoice_SetValue

		local List = self.quickSetupFrame.countdownVoice.List
		for i=1,#module.datas.vcountdowns do
			List[#List+1] = {
				text = module.datas.vcountdowns[i][2],
				arg1 = module.datas.vcountdowns[i][1],
				func = countdownVoice_SetValue,
			}
		end

		function self.quickSetupFrame.countdownVoice:Update()
			if options.quickSetupFrame.data.countdown then
				options.quickSetupFrame.countdownVoice:Point("TOPLEFT",options.quickSetupFrame.countdownCheck,"BOTTOMLEFT",0,-5):Shown(true)
			else
				options.quickSetupFrame.countdownVoice:Point("TOPLEFT",options.quickSetupFrame.countdownCheck,"BOTTOMLEFT",0,-5+25):Shown(false)
			end
		end
	end


	self.quickSetupFrame.soundList = ELib:DropDown(self.quickSetupFrame,270,15):AddText("|cffffd100"..L.ReminderSound..":"):Size(270):Point("TOPLEFT",self.quickSetupFrame.countdownVoice,"BOTTOMLEFT",0,-5)

	self.quickSetupFrame.soundList.delayEdit = ELib:Edit(self.quickSetupFrame.soundList):Size(45,20):Point("LEFT",self.quickSetupFrame.soundList,"RIGHT",5,0):Tooltip(L.ReminderSoundDelay.."\n"..L.ReminderSoundDelayTip):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		options.quickSetupFrame.data.sounddelay = text
	end)

	function self.quickSetupFrame.soundList.func_SetValue(_,arg1)
		self.quickSetupFrame.soundCustom.tts = false
		self.quickSetupFrame.soundList.lastOpt = arg1
		if arg1 == 0 then
			if not options.quickSetupFrame.setup then
				options.quickSetupFrame.data.sound = nil
			end

			self.quickSetupFrame.soundList:SetText(L.ReminderCustom)
		elseif not arg1 then
			if not options.quickSetupFrame.setup then
				options.quickSetupFrame.data.sound = nil
			end

			self.quickSetupFrame.soundList:SetText("-")
		else
			if not options.quickSetupFrame.setup then
				options.quickSetupFrame.data.sound = arg1
			end

			local val = ExRT.F.table_find3(self.quickSetupFrame.soundList.List,arg1,"arg1")
			if val then
				self.quickSetupFrame.soundList:SetText(val.text)
			else
				self.quickSetupFrame.soundList:SetText(arg1)
			end

			if arg1 == "TTS2" then
				self.quickSetupFrame.soundCustom.tts = true
				if not options.quickSetupFrame.setup then
					options.quickSetupFrame.data.sound = "TTS:"
					self.quickSetupFrame.soundCustom:SetText("")
				end
			end
		end
		if options.quickSetupFrame.soundCustom:ExtraShown() then
			options.quickSetupFrame.soundCustom:Point("TOPLEFT",options.quickSetupFrame.soundList,"BOTTOMLEFT",0,-5):Shown(true)
		else
			options.quickSetupFrame.soundCustom:Point("TOPLEFT",options.quickSetupFrame.soundList,"BOTTOMLEFT",0,-5+25):Shown(false)
		end
		if options.quickSetupFrame.data.sound or self.quickSetupFrame.soundList.lastOpt == 0 then
			self.quickSetupFrame.soundList:Size(220)
			self.quickSetupFrame.soundList.delayEdit:Show()
		else
			self.quickSetupFrame.soundList:Size(270)
			self.quickSetupFrame.soundList.delayEdit:Hide()
		end

		ELib:DropDownClose()
		if not options.quickSetupFrame.setup and arg1 and arg1 ~= 0 then
			module:PlaySound(arg1)
		end
	end
	function self.quickSetupFrame.soundList.Update()
		local data = options.quickSetupFrame.data
		if data.sound then
			self.quickSetupFrame.soundList:PreUpdate()
			local val = ExRT.F.table_find3(self.quickSetupFrame.soundList.List,data.sound,"arg1")
			if val then
				self.quickSetupFrame.soundList:func_SetValue(data.sound)
			elseif type(data.sound)=='string' and data.sound:find("^TTS:") then
				self.quickSetupFrame.soundList:func_SetValue("TTS2")
				self.quickSetupFrame.soundCustom:SetText(type(data.sound)=="string" and data.sound:gsub("^TTS:","") or "")
			else
				self.quickSetupFrame.soundList:func_SetValue(0)
				self.quickSetupFrame.soundCustom:SetText(data.sound or "")
			end

			self.quickSetupFrame.soundList:Size(220)
			self.quickSetupFrame.soundList.delayEdit:Show()
		else
			self.quickSetupFrame.soundList:func_SetValue(data.sound)

			self.quickSetupFrame.soundList:Size(270)
			self.quickSetupFrame.soundList.delayEdit:Hide()
		end
	end
	function self.quickSetupFrame.soundList:PreUpdate()
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

	self.quickSetupFrame.soundCustom = ELib:Edit(self.quickSetupFrame):Size(270,20):LeftText(L.ReminderCustomSound..":"):Shown(false):Point("TOPLEFT",self.quickSetupFrame.soundList,"BOTTOMLEFT",0,-5+25):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		if self.tts and text then text = "TTS:" .. text end
		options.quickSetupFrame.data.sound = text
	end)
	function self.quickSetupFrame.soundCustom:ExtraShown()
		if options.quickSetupFrame.soundList:IsShown() and 
		(
			(type(options.quickSetupFrame.data.sound)=='string' and options.quickSetupFrame.data.sound:find("^TTS:")) or
			(options.quickSetupFrame.data.sound and not ExRT.F.table_find3(options.quickSetupFrame.soundList.List,options.quickSetupFrame.data.sound,"arg1")) or
			options.quickSetupFrame.soundList.lastOpt == 0
		) then
			return true
		end
	end

	self.quickSetupFrame.soundList.playButton = ELib:Icon(self.quickSetupFrame.soundList,"Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128",20,true):Point("LEFT",self.quickSetupFrame.soundList,"LEFT",5+270,0)
	self.quickSetupFrame.soundList.playButton.texture:SetTexCoord(0.375,0.4375,0.5,0.625)
	self.quickSetupFrame.soundList.playButton:SetScript("OnClick",function()
		if options.quickSetupFrame.data.sound == "TTS" then
			module:PlaySound(options.quickSetupFrame.data.sound, {data={msg=(options.quickSetupFrame.data.msg or "")},params={}})
		elseif type(options.quickSetupFrame.data.sound) == "string" and options.quickSetupFrame.data.sound:find("^TTS:") then
			module:PlaySound(options.quickSetupFrame.data.sound, {data={msg=(options.quickSetupFrame.data.msg or "")},params={}})
		else
			module:PlaySound(options.quickSetupFrame.data.sound)
		end
	end)

	self.quickSetupFrame.glowCheck = ELib:Check(self.quickSetupFrame,L.ReminderGlow..":"):Left(5):Tooltip(L.ReminderGlowQSFTip):Point("TOPLEFT",self.quickSetupFrame.soundCustom,"BOTTOMLEFT",0,-5):OnClick(function(self)
		if self:GetChecked() then
			options.quickSetupFrame.data.tmp_tl_glow = ""
		else
			options.quickSetupFrame.data.tmp_tl_glow = nil
		end
		options.quickSetupFrame.glowCheckEdit:Update()
	end)

	self.quickSetupFrame.glowCheckEdit = ELib:Edit(self.quickSetupFrame):Size(220,20):Point("LEFT",self.quickSetupFrame.glowCheck,"RIGHT",5,0):Tooltip(L.ReminderGlowQSFTip2):Shown(false):OnChange(function(self,isUser)
		if not isUser then return end
		options.quickSetupFrame.data.tmp_tl_glow = self:GetText() or ""
	end)
	function options.quickSetupFrame.glowCheckEdit:Update()
		self:SetText(options.quickSetupFrame.data.tmp_tl_glow or "")
		options.quickSetupFrame.msgEdit:UpdateColorBorder()
		if options.quickSetupFrame.data.tmp_tl_glow then
			self:Show()
		else
			self:Hide()
		end
	end

	self.quickSetupFrame.glowCheckEdit.preview = ELib:Texture(self.quickSetupFrame.glowCheckEdit,1,1,1,1):Point("LEFT",'x',"RIGHT",5,0):Size(20,20)
	self.quickSetupFrame.glowCheckEdit.preview.Update = function(self)
		local t = options.quickSetupFrame.data.glowColor or ""
		local at,rt,gt,bt = t:match("(..)(..)(..)(..)")
		if bt then
			local r,g,b,a = tonumber(rt,16),tonumber(gt,16),tonumber(bt,16),tonumber(at,16)
			self:SetColorTexture(r/255,g/255,b/255,a/255)
		else
			self:SetColorTexture(1,1,1,1)
		end
	end

	self.quickSetupFrame.glowCheckEdit.colorButton = CreateFrame("Button",nil,self.quickSetupFrame.glowCheckEdit)
	self.quickSetupFrame.glowCheckEdit.colorButton:SetPoint("LEFT", self.quickSetupFrame.glowCheckEdit.preview, "RIGHT", 5, 0)
	self.quickSetupFrame.glowCheckEdit.colorButton:SetSize(24,24)
	self.quickSetupFrame.glowCheckEdit.colorButton:SetScript("OnClick",function(self)
		local r,g,b,a
		if options.quickSetupFrame.data.glowColor then
			local at,rt,gt,bt = options.quickSetupFrame.data.glowColor:match("(..)(..)(..)(..)")
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
				options.quickSetupFrame.data.glowColor = format("%02x%02x%02x%02x",newA*255,newR*255,newG*255,newB*255)
	
				options.quickSetupFrame.glowCheckEdit.preview:Update()
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
				options.quickSetupFrame.data.glowColor = format("%02x%02x%02x%02x",newA*255,newR*255,newG*255,newB*255)
	
				options.quickSetupFrame.glowCheckEdit.preview:Update()
			end
			info.cancelFunc = function()
				local newR, newG, newB, newA = ColorPickerFrame:GetPreviousValues()
				options.quickSetupFrame.data.glowColor = format("%02x%02x%02x%02x",newA*255,newR*255,newG*255,newB*255)
	
				options.quickSetupFrame.glowCheckEdit.preview:Update()
			end
			ColorPickerFrame:SetupColorPickerAndShow(info)
		end
	end)
	self.quickSetupFrame.glowCheckEdit.colorButton:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L.ReminderSelectColor)
		GameTooltip:Show()
	end)
	self.quickSetupFrame.glowCheckEdit.colorButton:SetScript("OnLeave",function(self)
		GameTooltip_Hide()
	end)
	self.quickSetupFrame.glowCheckEdit.colorButton.Texture = self.quickSetupFrame.glowCheckEdit.colorButton:CreateTexture(nil,"ARTWORK")
	self.quickSetupFrame.glowCheckEdit.colorButton.Texture:SetPoint("CENTER")
	self.quickSetupFrame.glowCheckEdit.colorButton.Texture:SetSize(20,20)
	self.quickSetupFrame.glowCheckEdit.colorButton.Texture:SetTexture([[Interface\AddOns\MRT\media\wheeltexture]])




	function self.quickSetupFrame:Update(data)
		self.data = data

		self.setup = true

		self.durEdit:SetText(data.dur or "")

		local msg = data.msg or ""
		if msg:find("^{spell:%d+}") then
			local spell = tonumber( msg:match("^{spell:(%d+)}"),nil )
			local name,_,texture = GetSpellInfo(spell or 0)
			self.spellDD:SetText( (texture and "|T"..texture..":20|t " or "")..(name or "spell:"..spell) )
			self.spellDD.spell = spell
			msg = msg:gsub("{spell:%d+} *","",1)
		else
			self.spellDD:SetText( "-" )
			self.spellDD.spell = nil
		end
		self.spellDD_extra:ExtraHide()
		self.msgEdit:SetText(msg)
		self.msgEdit:UpdateColorBorder()
		self.countdownCheck:SetChecked(data.countdown)
		self.countdownVoice:SetValue(data.countdownVoice)
		self.countdownVoice:Update()
		self.quickFilter:Update()
		self.durRevese:SetChecked(data.durrev)

		for i=1,1 do
			local trigger = data.triggers[i]

			self.timeEdit:SetText(trigger.delayTime or "")
			self.eventDD_extra:SetText(trigger.pattFind or "")
		end

		if data.triggers[2] and data.triggers[2].event == 16 and module:GetReminderType(data.msgSize) == REM.TYPE_RAIDFRAME then
			data.tmp_tl_glow = data.triggers[2].targetName:gsub(";"," ")
		elseif not data.tmp_tl_cd and data.triggers[2] and data.triggers[2].event == 13 and data.triggers[2].invert and self.spellDD.spell and data.triggers[2].spellID == (tonumber(self.spellDD.spell) or 0) then
			data.tmp_tl_cd = true
		end

		self.cooldownCheck:SetChecked(data.tmp_tl_cd)

		self.glowCheck:SetChecked(data.tmp_tl_glow and true or false)
		self.glowCheckEdit:Update()
		self.glowCheckEdit.preview:Update()

		self.eventDD:Update()

		self.soundList:Update()
		self.soundList.delayEdit:SetText(data.sounddelay or "")

		if data.uid and module:RemGet(data.uid) then
			self.removeButton:Show()
			self.saveButton:NewPoint("BOTTOMLEFT",self,"BOTTOM",5,10):Size(200,20)
		else
			self.removeButton:Hide()
			self.saveButton:NewPoint("BOTTOM",self,"BOTTOM",0,10):Size(410,20)
		end

		if not self.prev then
			self.copyButton:Disable()
		else
			self.copyButton:Enable()
		end

		self.setup = false
	end


	function options.timeLine:ResetSavedVars()
		self.SAVED_VAR_X = nil
		self.SAVED_VAR_XP = nil
		self.SAVED_VAR_P = nil
		self.SAVED_VAR_PC = nil
		self.SAVED_VAR_SID = nil
		self.SAVED_VAR_S = nil
		self.SAVED_VAR_SC = nil

		self.SAVED_VAR_BOSS = nil
		self.SAVED_VAR_ZONE = nil
		self.SAVED_VAR_BOSS_ZONE = nil
	end

	function options.timeLine:OpenQuickSetupFrame(x, y, button, data2)
		--x - time, y - lineNum

		local line = self.frame.lines[y]
		local spell_time, spell_counter, spell_id
		if line and line.spell and line:IsShown() then
			spell_id = line.spell
			spell_time, spell_counter = self:GetSpellFromTime(x, spell_id, self.timeLineData and self.timeLineData[spell_id] and self.timeLineData[spell_id].spellType == 2)
		end

		local phase, x_phase, phaseCount, phaseNum = self:GetPhaseFromTime(x)
		--phaseNum is here for data array, actual num is +1
		if phase == 0 then
			phase, x_phase, phaseCount = nil
		end

		self.SAVED_VAR_X = x
		self.SAVED_VAR_XP = x_phase
		self.SAVED_VAR_P = phase
		self.SAVED_VAR_PC = phaseCount
		self.SAVED_VAR_SID = spell_id
		self.SAVED_VAR_S = spell_time
		self.SAVED_VAR_SC = spell_counter

		local data
		if options.quickSetupFrame:IsShown() then
			data = options.quickSetupFrame.data
		else
			data = ExRT.F.table_copy2(newRemainderTemplate)
			data.uid = options:GetNewUID()
			data.durrev = true
		end

		if self.ZONE_ID then
			data.bossID = nil
			data.zoneID = self.ZONE_ID
		else
			data.bossID = self.BOSS_ID
			data.zoneID = nil
		end

		self.SAVED_VAR_BOSS = data.bossID
		self.SAVED_VAR_ZONE = data.zoneID
		self.SAVED_VAR_BOSS_ZONE = nil

		if not data.triggers[1] then
			data.triggers[1] = {}
		end
		data.triggers[1].event = self.ZONE_ID and 22 or 3

		if phase and phase > 0 and (phase ~= 1 or phaseCount) then
			data.triggers[1].event = 2
			data.triggers[1].pattFind = tostring(phase)
			if phaseCount then
				data.triggers[1].counter = tostring(phaseCount)
			else		
				data.triggers[1].counter = nil
			end

			x = x_phase
		elseif phase and phase < 0 and phase > -10000 then
			data.triggers[1].event = 3
			data.bossID = -phase
			data.zoneID = nil
			x = x_phase

			self.SAVED_VAR_BOSS_ZONE = data.bossID
		end

		if button == "RightButton" and self.SAVED_VAR_S then
			data.triggers[1].event = 1
			data.triggers[1].eventCLEU = (self.timeLineData[self.SAVED_VAR_SID].spellType or 1) == 1 and "SPELL_CAST_SUCCESS" or "SPELL_AURA_REMOVED"
			data.triggers[1].counter = tostring(self.SAVED_VAR_SC)
			data.triggers[1].spellID = tonumber(self.SAVED_VAR_SID)
			x = spell_time

			data.zoneID = self.SAVED_VAR_ZONE
			data.bossID = self.SAVED_VAR_BOSS
		end

		local t=floor(x*10)/10
		data.triggers[1].delayTime = format("%d:%02d.%d",t/60,t%60,(t*10)%10)

		--ignore any updates
		if data2 then
			data = ExRT.F.table_copy2(data2)
		end

		if IsShiftKeyDown() then
			options.setupFrame.mainframe = self
			options.setupFrame:Update(data)
			options.setupFrame:Show()
		else
			options.quickSetupFrame.mainframe = self
			options.quickSetupFrame:Update(data)
			options.quickSetupFrame:Show()
		end
	end

	function options.timeLine:ProcessClick(x, y, button)
		x = self:GetTimeFromPos(x)

		y = ceil(y / self.TL_LINESIZE)

		local phase, x_phase, phaseCount, phaseNum = self:GetPhaseFromTime(x)
		--phaseNum is here for data array, actual num is +1
		if phase == 0 then
			phase, x_phase, phaseCount = nil
		end

		if button == "RightButton" and phase and x_phase <= 3 and y and y <= 2 then
			ExRT.F.ShowInput("Change phase (use numbers, x.5 for intermissions)",function(_,p) 
				options.timeLine.custom_phase[phaseNum] = tonumber(p)
				options.timeLine:Update()
			end)
			return
		end

		options.timeLine:OpenQuickSetupFrame(x, y, button)
	end

	options.timeLine.Util_SetLineTexture = function(self,line,c,data,color)
		local texture = line.textures[c]
		if not texture then
			texture = line:CreateTexture(nil,"ARTWORK",nil,2)
			line.textures[c] = texture
			texture:SetHeight(options.timeLine.TL_LINESIZE)

			texture.cast = line:CreateTexture(nil,"ARTWORK",nil,2)
			texture.cast:SetSize(2,14)
			texture.cast:Hide()

			texture.l = line:CreateTexture(nil,"ARTWORK",nil,2)
			texture.l:SetHeight(2)
			texture.l:SetPoint("LEFT",texture.cast,"RIGHT",0,0)
			texture.l:SetPoint("RIGHT",texture,"LEFT",0,0)
			texture.l:Hide()

		end
		if color then
			texture:SetColorTexture(unpack(color))
			texture.cast:SetColorTexture(unpack(color))
			texture.l:SetColorTexture(unpack(color))
		else
			texture:SetColorTexture(1,1,1,.7)
			texture.cast:SetColorTexture(1,1,1,.7)
			texture.l:SetColorTexture(1,1,1,.7)
		end
		texture:SetPoint("LEFT",self:GetPosFromTime(data.pos),0)
		texture:SetWidth(self:GetPosFromTime(data.len))
		texture:Show()
		if data.cast then
			texture.cast:SetPoint("LEFT",self:GetPosFromTime(data.pos-data.cast),0)
			texture.cast:Show()
			texture.l:Show()
		else
			texture.cast:Hide()
			texture.l:Hide()
		end
	end
	options.timeLine.Util_ButtonOnClick = function(self,button)
		if button == "RightButton" then
			if not self.data then return end
			local menu = {
				{ text = L.ReminderAdvanced, func = function() 
					ELib.ScrollDropDown.Close()
					local data = ExRT.F.table_copy2(self.data)
					options.setupFrame:Update(data)
					options.setupFrame:Show()
				end, notCheckable = true },
				{ text = L.ReminderSendOne, func = function() ELib.ScrollDropDown.Close() module:Sync(false,nil,nil,self.data.uid) end, notCheckable = true, isTitle = IsInRaid() and not ExRT.F.IsPlayerRLorOfficer("player") },
				{ text = L.ReminderHideOne, tooltip = L.ReminderHideOneTip, func = function() ELib.ScrollDropDown.Close() options.timeLine.reminder_hide[self.data.uid]=true options.timeLine:Update() end, notCheckable = true },
				{ text = DELETE, func = function() ELib.ScrollDropDown.Close() options:RemoveReminder(self.data.uid) end, notCheckable = true },
				{ text = CLOSE, func = function() ELib.ScrollDropDown.Close() end, notCheckable = true },
			}
			ELib.ScrollDropDown.EasyMenu(self,menu,150)
		else
			if self.uncategorized then
				if ELib:DropDownCloseIfOpened() then return end
				local menu = {}
				local function Click(_,data)
					ELib.ScrollDropDown.Close()
					local data2 = ExRT.F.table_copy2(data)
					options.setupFrame:Update(data2)
					options.setupFrame:Show()
				end
				for i=1,#self.uncategorized do
					local data = self.uncategorized[i]
					menu[#menu+1] = { text = data.name or data.msg or "#"..i, func = Click, arg1 = data, notCheckable = true }
				end
				menu[#menu+1] = { text = CLOSE, func = function() ELib.ScrollDropDown.Close() end, notCheckable = true }
				ELib.ScrollDropDown.EasyMenu(self,menu,250,min(#menu,15))
			else
				options.timeLine:ResetSavedVars()
				options.timeLine:OpenQuickSetupFrame(self.timestamp, nil, nil, self.data)
			end
		end
	end
	options.timeLine.Util_ButtonOnEnter = function(self)
		local data = self.data

		self:SetAlpha(.7)

		options.timeLine.HideCursor = true
		self.cursor:SetColorTexture(1,1,0,1)
		self.cursorToSpell:SetColorTexture(1,1,0,1)

		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		if not data then
			GameTooltip:AddLine(STABLE_PET_UNCATEGORIZED or "Uncategorized")
			GameTooltip:Show()
			return
		end
		local p,pc,pd
		local dt = module:ConvertMinuteStrToNum(data.triggers[1].delayTime)
		if data.triggers[1].event == 2 then
			p = data.triggers[1].pattFind
			pc = data.triggers[1].counter
			pd = dt and options.timeLine:GetTimeOnPhase(dt[1],p,pc)
		end
		if dt then
			GameTooltip:AddLine((p and "Phase "..p..(pc and " (#"..pc..")" or "")..": " or "")..module:FormatTime2(dt[1]))
		end
		local filter = ""
		for k,v in pairs(data.players) do 
			if UnitClass(k) then
				filter = filter .. "|c" .. RAID_CLASS_COLORS[select(2,UnitClass(k))].colorStr .. k .. " "
			else
				filter = filter .. k .. " " 
			end
		end
		for k,v in pairs(data) do 
			if type(k)=="string" and k:find("^role") then 
				local token = k:match("^role(.-)$")
				for i=1,#module.datas.rolesList do
					if tostring(module.datas.rolesList[i][1]) == token then
						filter = filter .. module.datas.rolesList[i][2] .. " "
					end
				end
			elseif type(k)=="string" and k:find("^class") then 
				local token = k:match("^class(.-)$")
				for i=1,#ExRT.GDB.ClassList do
					if ExRT.GDB.ClassList[i] == token then
						filter = filter..(RAID_CLASS_COLORS[token] and RAID_CLASS_COLORS[token].colorStr and "|c"..RAID_CLASS_COLORS[token].colorStr or "")..L.classLocalizate[token].."|r "
					end
				end
			end
		end
		if filter ~= "" then
			GameTooltip:AddLine("Filter: "..filter)
		end
		if pd then
			GameTooltip:AddLine("From start: "..module:FormatTime2(pd))
		end
		GameTooltip:AddLine(module:FormatMsg(data.msg or ""))
		GameTooltip:Show()
	end
	options.timeLine.Util_ButtonOnLeave = function(self)
		options.timeLine.HideCursor = false
		GameTooltip_Hide()
		self:SetAlpha(1)
		self.cursor:SetColorTexture(1,1,1,.5)
		self.cursorToSpell:SetColorTexture(1,1,1,.5)
	end

	options.timeLine.Util_HeaderOnEnter = function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetHyperlink("spell:"..self.spell )
		GameTooltip:Show()

		options.timeLine.frame:HighlighSpellLine(self.spell,true)

		if not self.isOff then
			self.name:Color(unpack(options.timeLine.TL_HEADER_COLOR_HOVER))
		end
	end
	options.timeLine.Util_HeaderOnLeave = function(self)
		GameTooltip_Hide()

		options.timeLine.frame:HighlighSpellLine(self.spell,false)

		self.name:Color(unpack(self.isOff and options.timeLine.TL_HEADER_COLOR_OFF or options.timeLine.TL_HEADER_COLOR_ON))
	end

	options.timeLine.Util_LineOnEnter = function(self)
		if not self.header.isOff then
			self.header.name:Color(unpack(options.timeLine.TL_HEADER_COLOR_HOVER))
		end
	end
	options.timeLine.Util_LineOnLeave = function(self)
		self.header.name:Color(unpack(self.header.isOff and options.timeLine.TL_HEADER_COLOR_OFF or options.timeLine.TL_HEADER_COLOR_ON))
	end

	options.timeLine.Util_HeaderOnClick = function(self,button)
		if button == "RightButton" then
			local menu = {
				{ text = L.ReminderCustomDurationLen, func = function() 
					ELib.ScrollDropDown.Close()
					ExRT.F.ShowInput(L.ReminderCustomDurationLenMore:format(GetSpellName(self.spell) or "spell"..self.spell),function(spell,dur) 
						options.timeLine.spell_dur[spell]=tonumber(dur) 
						options.timeLine:Update()
					end,self.spell,true,2)
				end, notCheckable = true },
				{ text = L.ReminderChangeColorRng, func = function() 
					ELib.ScrollDropDown.Close()
					options.timeLine.saved_colors[self.spell]={math.random(1,100)/100,math.random(1,100)/100,math.random(1,100)/100,1}
					options.timeLine:Update()
				end, notCheckable = true },
				{ text = CLOSE, func = function() ELib.ScrollDropDown.Close() end, notCheckable = true },
			}
			ELib.ScrollDropDown.EasyMenu(self,menu,200)
		else
			options.timeLine.spell_status[self.spell] = not options.timeLine.spell_status[self.spell]
			local currSpellStatus = options.timeLine.spell_status[self.spell]
			if IsShiftKeyDown() then
				local changeNext = false
				for i=1,#options.timeLine.frame.lines do
					local line = options.timeLine.frame.lines[i]
					if line and line.header:IsShown() and line.spell == self.spell then
						changeNext = true
					elseif line and line.header:IsShown() and line.spell and changeNext then
						options.timeLine.spell_status[line.spell] = currSpellStatus
					end
				end
			end
			options.timeLine:Update()
		end
	end


	function options.timeLine:Update()
		local timeLineData = self:GetTimeLineData()
		self.timeLineData = timeLineData

		local data_list, data_uncategorized = self:GetRemindersList()
		local max_delay = #data_list > 0 and data_list[#data_list][2] or 0

		local width = self:GetPosFromTime(self:GetTimeAdjust(max_delay)+10)

		local line_c = 0
		local line_c_off = 0
		local line_p = 0
		if timeLineData then
			local spells_sorted = {}
			for spell,spell_times in pairs(timeLineData) do
				if type(spell) == "number" and self:IsPassFilterSpellType(spell_times,spell) then
					spells_sorted[#spells_sorted+1] = {
						id = spell, 
						name = GetSpellName(spell) or "spell"..spell,
						isOff = self.spell_status[spell],
						prio = self.spell_status[spell] and 0 or 1,
						first = type(spell_times[1])=="table" and spell_times[1][1] or spell_times[1] or 0,
						times = spell_times,
					}
				end
				for i=1,#spell_times do
					local t = type(spell_times[i])=="table" and spell_times[i][1] or spell_times[i]
					if t > max_delay then
						max_delay = t
					end
				end
			end
			local cmpTimeLineData = self:GetCompareTimeLineData()
			if cmpTimeLineData then
				for spell,spell_times in pairs(cmpTimeLineData) do
					if type(spell) == "number" and self:IsPassFilterSpellType(spell_times,spell) then
						spells_sorted[#spells_sorted+1] = {
							id = spell, 
							name = "|A:None:0:0|a"..(GetSpellName(spell) or "spell"..spell),
							isOff = self.spell_status[spell],
							prio = self.spell_status[spell] and 0 or 1,
							first = type(spell_times[1])=="table" and spell_times[1][1] or spell_times[1] or 0,
							times = spell_times,
							isCompare = true,
						}
					end
					for i=1,#spell_times do
						local t = type(spell_times[i])=="table" and spell_times[i][1] or spell_times[i]
						if t > max_delay then
							max_delay = t
						end
					end
				end
			end
			local sortByFirst = #spells_sorted >= 0
			sort(spells_sorted,function(a,b) 
				if a.prio ~= b.prio then
					return a.prio > b.prio
				elseif sortByFirst and a.first ~= b.first then
					return a.first < b.first
				else
					return a.name < b.name 
				end
			end)
			width = self:GetPosFromTime(self:GetTimeAdjust(max_delay)+10)

			for j=1,#spells_sorted do
				local spell_data = spells_sorted[j]
				local spell = spell_data.id
				local spell_times = spell_data.times
				local isOff = spell_data.isOff
				line_c = line_c + 1
				local line = self.frame.lines[line_c]
				if not line then
					line = CreateFrame("Frame",nil,self.frame.C)
					self.frame.lines[line_c] = line
					line:SetPoint("TOPLEFT",0,-self.TL_LINESIZE*(line_c-1))
					line:SetSize(1000,self.TL_LINESIZE)
					if line.SetPropagateMouseClicks then	--not working on classic client rn
						line:SetScript("OnEnter",self.Util_LineOnEnter)
						line:SetScript("OnLeave",self.Util_LineOnLeave)
						line:SetPropagateMouseClicks(true)
					end
	
					line.textures = {}
	
					line.header = CreateFrame("Button",nil,self.frame.headers.C)
					line.header:SetPoint("TOPLEFT",0,-self.TL_LINESIZE*(line_c-1))
					line.header:SetSize(220,self.TL_LINESIZE)
					line.header:RegisterForClicks("LeftButtonUp","RightButtonUp")
					line.header:SetScript("OnClick",self.Util_HeaderOnClick)
					line.header:SetScript("OnEnter",self.Util_HeaderOnEnter)
					line.header:SetScript("OnLeave",self.Util_HeaderOnLeave)
	
					line.header.icon = line.header:CreateTexture()
					line.header.icon:SetPoint("RIGHT",0,0)
					line.header.icon:SetSize(self.TL_LINESIZE,self.TL_LINESIZE)
	
					line.header.name = ELib:Text(line.header,"Spell Name",12):Point("RIGHT",-22,0):Right()

					if line_c%2 == 1 then
						line.bg = line:CreateTexture(nil,"BACKGROUND")
						line.bg:SetAllPoints()
						line.bg:SetColorTexture(1,1,1,.005)
	
						line.header.bg = line.header:CreateTexture(nil,"BACKGROUND")
						line.header.bg:SetAllPoints()
						line.header.bg:SetColorTexture(1,1,1,.03)
					end
				end

				if spell_data.isCompare then
					if not line.cmpbg then
						line.cmpbg = line:CreateTexture(nil,"BACKGROUND")
						line.cmpbg:SetAllPoints()
						line.cmpbg:SetColorTexture(1,0,1,.1)
	
						line.header.cmpbg = line.header:CreateTexture(nil,"BACKGROUND")
						line.header.cmpbg:SetAllPoints()
						line.header.cmpbg:SetColorTexture(1,0,1,.1)
					end
					line.cmpbg:Show()
					line.header.cmpbg:Show()
				elseif line.cmpbg then
					line.cmpbg:Hide()
					line.header.cmpbg:Hide()
				end

				local color = spell_times.color or self.saved_colors[spell] or {math.random(1,100)/100,math.random(1,100)/100,math.random(1,100)/100,1}
				self.saved_colors[spell] = color
				local t_c = 0
				if not isOff then
					for i=1,#spell_times do
						local st = spell_times[i]
						local len = self.spell_dur[spell] or (type(st) == "table" and st.d) or spell_times.d or 2
						local cast = (type(st) == "table" and st.c) or (spell_times.cast)
						st = type(st) == "table" and st[1] or st
						if not self:IsRemovedByTimeAdjust(st) then
							st = self:GetTimeAdjust(st)
							if len == "p" then len = self:GetTimeUntilPhaseEnd(st) or 2 end
							t_c = t_c + 1
							self:Util_SetLineTexture(line,t_c,{pos=st,len=len,cast=cast},color)
						end
					end
				end
				for i=t_c+1,#line.textures do
					local t = line.textures[i]
					t:Hide()
					t.cast:Hide()
					t.l:Hide()
				end
				local name = GetSpellName(spell)
				local texture = GetSpellTexture(spell)
				line.header.name:SetText(spell_data.name or name or "spell"..spell)
				line.header.icon:SetTexture(texture)
				if isOff then
					line.header.isOff = true
					line.header.name:SetTextColor(unpack(self.TL_HEADER_COLOR_OFF))
					line:Hide()

					line_c_off = line_c_off + 1
				else
					line.header.isOff = false
					line.header.name:SetTextColor(unpack(self.TL_HEADER_COLOR_ON))

					line:Show()
				end
				line.header.spell = spell
				line.spell = spell

				line:SetWidth(width)

				line.header:Show()
			end

			if timeLineData.p then
				for i=1,#timeLineData.p do
					local x = timeLineData.p[i]

					line_p = line_p + 1
					local pcursor = self.frame.pcursors[line_p]
					if not pcursor then
						pcursor = self.frame.D:CreateTexture(nil,"ARTWORK", nil, 4)
						self.frame.pcursors[i] = pcursor
						pcursor:SetWidth(1)
						pcursor:SetPoint("TOP")
						pcursor:SetPoint("BOTTOM",self.frame.cursorH,"TOP",0,0)
						pcursor:SetColorTexture(0,1,0,.7)

						pcursor.text = ELib:Text(self.frame.D,"Phase "..(i+1),10):Point("RIGHT",pcursor,"TOPRIGHT",1,0):Point("TOP",self.frame.cursorHT2,"BOTTOM",0,-1):Right():Color(0,1,0,.7)
						pcursor.text:SetRotation(90*math.pi/180)
						pcursor.text:SetDrawLayer("ARTWORK", 4)
					end

					local pn = self.custom_phase[i] or (timeLineData.p.n and timeLineData.p.n[i]) or (i+1)
					local phase_time = self:GetTimeOnPhase(0,pn,self:GetPhaseCounter(i))
					x = self:GetPosFromTime(phase_time)
					pcursor:SetPoint("LEFT",x,0)
					local text = "Phase "..pn
					if tostring(pn):find("%d%.%d") then
						text = "Intermission "..tostring(pn):match("^%d+")
					elseif pn == 0 then
						text = ""
					elseif pn and type(pn)=="number" and pn < 0 and pn > -10000 then
						text = L.bossName[ -pn ]
					end
					pcursor.text:SetText(text)
					pcursor:Show()
					pcursor.text:Show()
				end
			end
		end
		for i=line_c+1,#self.frame.lines do
			local line = self.frame.lines[i]
			line:Hide()
			line.header:Hide()
		end
		for i=line_p+1,#self.frame.pcursors do
			local line = self.frame.pcursors[i]
			line:Hide()
			line.text:Hide()
		end
		local max_y = (line_c+1)*self.TL_LINESIZE

		line_c = line_c - line_c_off
		if line_c == 0 then
			line_c = 1
		end

		self.frame.cursorH:SetPoint("TOPLEFT",0,-self.TL_LINESIZE*(line_c))

		self.frame.cursorH:SetSize(width,2)

		self.frame:Width(width)


		max_y = max((line_c+1)*self.TL_LINESIZE,max_y)
		local prevButton = -100
		local prevY = 0
		local b_c = 0
		sort(data_list,self.util_sort_by2)
		for i=(data_uncategorized and 0 or 1),#data_list do
			b_c = b_c + 1

			local button = self.frame.buttons[b_c]
			if not button then
				button = CreateFrame("Button",nil,self.frame.C)
				self.frame.buttons[b_c] = button
				button:SetSize(self.TL_REMSIZE,self.TL_REMSIZE)

				button.cursor = button:CreateTexture(nil,"ARTWORK",nil,3)
				button.cursor:SetWidth(1)
				button.cursor:SetPoint("TOP",self.frame.cursorHT2,"BOTTOM",0,0)
				button.cursor:SetPoint("BOTTOMLEFT",button,"TOPLEFT",0,0)
				button.cursor:SetColorTexture(1,1,1,.5)

				button.cursorToSpell = button:CreateTexture(nil,"ARTWORK",nil,3)
				button.cursorToSpell:SetHeight(1)
				button.cursorToSpell:SetPoint("RIGHT",button.cursor,"TOP",0,0)
				button.cursorToSpell:SetColorTexture(1,1,1,.5)
				button.cursorToSpell:Hide()

				button.icon = button:CreateTexture()
				button.icon:SetAllPoints()
				button:RegisterForClicks("LeftButtonUp","RightButtonUp")
				button:SetScript("OnClick",self.Util_ButtonOnClick)
				button:SetScript("OnEnter",self.Util_ButtonOnEnter)
				button:SetScript("OnLeave",self.Util_ButtonOnLeave)
			end

			local data_line = data_list[i]
			local data = data_line and data_line[1]
			local x = data_line and data_line[2] or 0

			local pos = self:GetPosFromTime(x)
			local anchorLeft = data and not data.durrev

			if pos < (anchorLeft and 0 or self.TL_REMSIZE) then
				pos = (anchorLeft and 0 or self.TL_REMSIZE)
			end

			if prevButton >= (pos - (anchorLeft and 0 or self.TL_REMSIZE)) then
				prevY = prevY + self.TL_REMSIZE
			else
				prevY = 0
			end
			button:ClearAllPoints()

			prevButton = max(pos + (anchorLeft and self.TL_REMSIZE or 0),prevButton)

			button:SetPoint(anchorLeft and "TOPLEFT" or "TOPRIGHT",self.frame.C,"TOPLEFT",pos,-(line_c+1)*self.TL_LINESIZE-prevY)

			button.cursor:ClearAllPoints()
			button.cursor:SetPoint(anchorLeft and "BOTTOMLEFT" or "BOTTOMRIGHT",button,anchorLeft and "TOPLEFT" or "TOPRIGHT",0,0)
			button.cursor:SetPoint("TOP",self.frame.cursorHT2,"BOTTOM",0,0)
			button.cursor:Show()

			button.cursorToSpell:Hide()
			if data_line and data_line[3] and data_line[3].s then
				local spell = data_line[3].s
				local found = false
				for j=1,#self.frame.lines do
					local line = self.frame.lines[j]
					if line.spell == spell and line:IsShown() then
						button.cursor:SetPoint("TOP",line,"RIGHT",0,0)

						button.cursorToSpell:SetWidth( self:GetPosFromTime(data_line[4]) )
						button.cursorToSpell:Show()

						found = true
						break
					end
				end
				if not found then
					button.cursor:Hide()
				end
			end
			if i == 0 then
				button.cursor:Hide()
			end

			local texture = 134938
			if i == 0 then
				texture = 294476
			end
			if data and module:GetReminderType(data.msgSize) == REM.TYPE_RAIDFRAME then
				texture = ExRT.isClassic and 134993 or 878211
			end
			if data and type(data.msg) == "string" and data.msg:find("{spell:%d+}") then
				texture = GetSpellTexture( tonumber(data.msg:match("{spell:(%d+)}"),10) ) or texture
			end
			button.icon:SetTexture(texture)
			button.data = data
			button.timestamp = x
			button.uncategorized = i == 0 and data_uncategorized
			button:Show()

			if max_y < (line_c+1)*self.TL_LINESIZE + prevY + self.TL_REMSIZE*2 then
				max_y = (line_c+1)*self.TL_LINESIZE + prevY + self.TL_REMSIZE*2
			end
		end
		for i=b_c+1,#self.frame.buttons do
			self.frame.buttons[i]:Hide()
		end

		if max_y > self.frame:GetHeight() then
			self.frame:Height(max_y)
			self.frame.headers:Height(max_y)
			self.frame.headers.ScrollBar:Show()
		elseif self.frame.headers.ScrollBar:IsShown() then
			self.frame.headers.ScrollBar:SetValue(0)
			self.frame.headers.ScrollBar:Hide()
		end
	end
	self.timeLine:Update()

	

	options.timeLine.customTimeLineDataFrame = ELib:Popup("Edit custom encounter"):Size(800,600):OnShow(function(self) self:Update() end,true)
	ELib:Border(options.timeLine.customTimeLineDataFrame,1,.4,.4,.4,.9)

	options.timeLine.customTimeLineDataFrame.bossList = ELib:DropDown(options.timeLine.customTimeLineDataFrame,270,2):AddText("|cffffd100"..L.ReminderBoss..":"):Size(270):Point("TOPLEFT",100,-20)
	do
		local List = options.timeLine.customTimeLineDataFrame.bossList.List
		local function bossList_SetValue(_,encounterID)
			options.timeLine.customTimeLineDataFrame.bossID = encounterID
			options.timeLine.customTimeLineDataFrame.bossList:AutoText(encounterID,nil,true)
			ELib:DropDownClose()
		end
		options.timeLine.customTimeLineDataFrame.bossList.SetValue = bossList_SetValue

		local dungSubMenu,raidSubMenu = {},{}
		List[#List+1] = {
			text = RAIDS,
			subMenu = raidSubMenu,
			Lines = 20,
		}
		List[#List+1] = {
			text = DUNGEONS,
			subMenu = dungSubMenu,
			Lines = 20,
		}
		local encountersList = ExRT.F.GetEncountersList(true,false,true,false)
		for i=1,#encountersList do
			local instance = encountersList[i]
			raidSubMenu[#raidSubMenu+1] = {
				text = type(instance[1])=='string' and instance[1] or GetMapNameByID(instance[1]) or "???",
				isTitle = true,
			}
			for j=2,#instance do
				local bossID, bossImg = instance[j]
				if ExRT.GDB.encounterIDtoEJ[bossID] and EJ_GetCreatureInfo then
					bossImg = select(5, EJ_GetCreatureInfo(1, ExRT.GDB.encounterIDtoEJ[bossID]))
				end
				raidSubMenu[#raidSubMenu+1] = {
					text = L.bossName[ bossID ],
					arg1 = bossID,
					func = bossList_SetValue,
					icon = bossImg,
					iconsize = 32,
				}
			end
		end
		local dungEncountersList = ExRT.F.GetEncountersList(false,false,true,true)
		for i=1,#dungEncountersList do
			local instance = dungEncountersList[i]
			dungSubMenu[#dungSubMenu+1] = {
				text = type(instance[1])=='string' and instance[1] or GetMapNameByID(instance[1]) or "???",
				isTitle = true,
			}
			for j=2,#instance do
				local bossID, bossImg = instance[j]
				if ExRT.GDB.encounterIDtoEJ[bossID] and EJ_GetCreatureInfo then
					bossImg = select(5, EJ_GetCreatureInfo(1, ExRT.GDB.encounterIDtoEJ[bossID]))
				end
				dungSubMenu[#dungSubMenu+1] = {
					text = L.bossName[ bossID ],
					arg1 = bossID,
					func = bossList_SetValue,
					icon = bossImg,
					iconsize = 32,
				}
			end
		end
	end

	options.timeLine.customTimeLineDataFrame.copyFrom = ELib:DropDown(options.timeLine.customTimeLineDataFrame,270,15):Size(200):SetText("Copy from"):Point("TOPRIGHT",-30,-20)
	function options.timeLine.customTimeLineDataFrame.copyFrom:AddBoss(bossID,bossData,fightLen,extraNameText)
		local bossImg
		if ExRT.GDB.encounterIDtoEJ[bossID] and EJ_GetCreatureInfo then
			bossImg = select(5, EJ_GetCreatureInfo(1, ExRT.GDB.encounterIDtoEJ[bossID]))
		end

		local name = L.bossName[ bossID ] or ("boss id"..bossID)

		if bossID < 0 then
			name = GetRealZoneText(zoneID) or VMRT.Reminder2.zoneNames[-bossID] or "Zone ID "..(-bossID)
			local journalInstance = ExRT.GDB.MapIDToJournalInstance[-bossID]
			if journalInstance and EJ_GetInstanceInfo then
				name = EJ_GetInstanceInfo(journalInstance) or name
			end
		end

		local res = {
			text = name..(extraNameText or "").." ".. module:FormatTime(fightLen or bossData.d and bossData.d[2] or 0),
			arg1 = bossID, 
			arg2 = bossData,
			func = self.SetValue,
			icon = bossImg,
			iconsize = bossImg and 32,
		}

		return res
	end
	function options.timeLine.customTimeLineDataFrame.copyFrom:PreUpdate()
		wipe(self.List)

		for bossID,bossDatas in pairs(options.timeLine.Data) do
			for _,bossData in pairs(bossDatas.m and bossDatas or {bossDatas}) do
				if type(bossData) == "table" then
					self.List[#self.List+1] = self:AddBoss(bossID, bossData)
				end
			end
		end
		for _, h_key in pairs({"history","historySession"}) do
			for i=1,#module.db[h_key] do
				local fight = module.db[h_key][i]
				local fightLen = #fight > 1 and fight[#fight][1] - fight[1][1]
				local bossID
				if #fight > 0 and fight[1][2] == 22 then
					bossID = -fight[1][3]
				elseif #fight > 0 and fight[1][2] == 3 then
					bossID = fight[1][3]
				end
				if bossID and fightLen then
					local n = self:AddBoss(bossID, fight, fightLen, "*")
					n.arg3 = 2
					self.List[#self.List+1] = n
				end
			end
		end

		sort(self.List,function(a,b) return a.arg1 > b.arg1 end)

		local editInList = {text = " ", isTitle = true, edit = "", editIcon = [[Interface\Common\UI-Searchbox-Icon]]}
		editInList.editFunc = function(this)
			local search = this:GetText()
			if search and search:trim() == "" then
				search = nil
			end
			search = search and search:lower()
			for i=1,#self.List do
				local l = self.List[i]
				if not l.edit then
					l.isHidden = search and not l.text:lower():find(search,1,true)
				end
			end
			editInList.edit = search or ""
			ELib.ScrollDropDown:Reload()
			--this:SetFocus()
		end
		tinsert(self.List, 1, editInList)
	end
	function options.timeLine.customTimeLineDataFrame.copyFrom:SetValue(bossID,bossData,opt)
		ELib:DropDownClose()
		options.timeLine.customTimeLineDataFrame.bossID = bossID
		if opt == 2 then bossData = options.timeLine:CreateCustomTimelineFromHistory(bossData) end
		options.timeLine.customTimeLineDataFrame.data = ExRT.F.table_copy2(bossData)
		options.timeLine.customTimeLineDataFrame.bossList:AutoText(bossID,nil,true)
		options.timeLine.customTimeLineDataFrame:Update()
	end

	options.timeLine.customTimeLineDataFrame.frame = ELib:ScrollFrame(options.timeLine.customTimeLineDataFrame):Size(800,600-95-18):Height(600-40):AddHorizontal(true):Width(800):Point("TOP",0,-95)
	ELib:Border(options.timeLine.customTimeLineDataFrame.frame,0)
	options.timeLine.customTimeLineDataFrame.frame.lines = {}

	function options.timeLine.customTimeLineDataFrame:PrepData()
		local max_len = 0
		for k,v in pairs(self.data) do
			if type(k) == "number" or k == "p" then
				for i=#v,1,-1 do
					if not v[i] or (type(v[i])=="table" and not v[i][1]) then
						tremove(v, i)
					end
					max_len = max(max_len,type(v[i])=="number" and v[i] or type(v[i])=="table" and type(v[i][1])=="number" and v[i][1] or max_len)
				end
			end
		end
		if not self.data.d then
			self.data.d = {}
		end
		self.data.d[2] = max_len
	end
	function options.timeLine.customTimeLineDataFrame:Save()
		if not VMRT.Reminder2.CustomTLData then
			VMRT.Reminder2.CustomTLData = {}
		end
		local bossID = self.bossID
		if not bossID then
			print('data not saved, no boss selected')
			return
		end
		self:PrepData()
		VMRT.Reminder2.CustomTLData[bossID] = self.data
	end

	options.timeLine.customTimeLineDataFrame:SetScript("OnHide",function(self)
		StaticPopupDialogs["EXRT_REMINDER_CLOSE"] = {
			text = "Save data?",
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				self:Save()
			end,
			OnCancel = function()

			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_REMINDER_CLOSE")
	end)

	options.timeLine.customTimeLineDataFrame.frame:SetScript("OnMouseDown",function(self)
		local x,y = ExRT.F.GetCursorPos(self)
		self.saved_x = x
		self.saved_y = y
		self.saved_scroll_h = self.ScrollBarHorizontal:GetValue()
		self.saved_scroll_v = self.ScrollBar:GetValue()
		self.moveSpotted = nil

	end)

	options.timeLine.customTimeLineDataFrame.frame:SetScript("OnMouseUp",function(self, button)
		self.saved_x = nil
		self.saved_y = nil
		self.moveSpotted = nil
	end)


	options.timeLine.customTimeLineDataFrame.frame:SetScript("OnUpdate",function(self)
		local x,y = ExRT.F.GetCursorPos(self)

		if self.saved_x and self.saved_y then
			if self.ScrollBarHorizontal:IsShown() and abs(x - self.saved_x) > 5 then
				local newVal = self.saved_scroll_h - (x - self.saved_x)
				local min,max = self.ScrollBarHorizontal:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.ScrollBarHorizontal:SetValue(newVal)

				self.moveSpotted = true
			end
			if self.ScrollBar:IsShown() and abs(y - self.saved_y) > 5 then
				local newVal = self.saved_scroll_v - (y - self.saved_y)
				local min,max = self.ScrollBar:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.ScrollBar:SetValue(newVal)

				self.moveSpotted = true
			end
		end
	end)


	options.timeLine.customTimeLineDataFrame.importWindow, options.timeLine.customTimeLineDataFrame.exportWindow = ExRT.F.CreateImportExportWindows()
	options.timeLine.customTimeLineDataFrame.importWindow:SetFrameStrata("FULLSCREEN")
	options.timeLine.customTimeLineDataFrame.exportWindow:SetFrameStrata("FULLSCREEN")

	function options.timeLine.customTimeLineDataFrame.importWindow:ImportFunc(str)
		local bossID,datastr = strsplit("=",str,2)
		bossID = bossID:match("%d+")
		local data = ExRT.F.TextToTable(datastr)
		if not data or not bossID then
			print('import string is corrupted')
			return
		end
		options.timeLine.customTimeLineDataFrame:OpenEdit(tonumber(bossID), data)
	end

	options.timeLine.customTimeLineDataFrame.ExportButton = ELib:Button(options.timeLine.customTimeLineDataFrame,L.Export):Point("TOPRIGHT",options.timeLine.customTimeLineDataFrame.copyFrom,"BOTTOMRIGHT",0,-5):Size(200,20):OnClick(function()
		local str = ""

		options.timeLine.customTimeLineDataFrame:PrepData()

		str = ExRT.F.TableToText(options.timeLine.customTimeLineDataFrame.data)
		str[1] = "["..(options.timeLine.customTimeLineDataFrame.bossID or 0).."]="..str[1]
		str = table.concat(str)

		--ExRT.F:Export2(str)
		options.timeLine.historyExportWindow.Edit:SetText(str)
		options.timeLine.historyExportWindow:Show()

		options.timeLine.customTimeLineDataFrame:Update()
	end)


	options.timeLine.customTimeLineDataFrame.ImportButton = ELib:Button(options.timeLine.customTimeLineDataFrame,L.Import):Point("TOPRIGHT",options.timeLine.customTimeLineDataFrame.ExportButton,"BOTTOMRIGHT",0,-5):Size(200,20):OnClick(function()
		options.timeLine.customTimeLineDataFrame.importWindow:NewPoint("CENTER",UIParent,0,0)
		options.timeLine.customTimeLineDataFrame.importWindow:Show()
	end)

	options.timeLine.customTimeLineDataFrame.addButton = ELib:Button(options.timeLine.customTimeLineDataFrame.frame.C,"Add"):Size(100,20):OnClick(function(self)
		local data = options.timeLine.customTimeLineDataFrame.data

		data[self.spell] = {}

		self:Hide()
		options.timeLine.customTimeLineDataFrame:Update()
	end)


	function options.timeLine.customTimeLineDataFrame:removeButton_click()
		local data = options.timeLine.customTimeLineDataFrame.data
		local sList = options.timeLine.customTimeLineDataFrame.sList
		local i = self:GetParent().data_i
		data[ sList[i].spell ] = nil

		options.timeLine.customTimeLineDataFrame:Update()
	end

	function options.timeLine.customTimeLineDataFrame:spell_edit(isUser)
		local text = tonumber(self:GetText() or "")
		local texture = text and GetSpellTexture(text)
		self:InsideIcon(texture)
		self:BackgroundTextCheck()
		local data = self:GetParent().data
		options.timeLine.customTimeLineDataFrame.addButton:NewPoint("LEFT",self,"RIGHT",5,0):SetShown(text and not data)
		options.timeLine.customTimeLineDataFrame.addButton.spell = text
		if not isUser then return end
		if data then
			local mdata = options.timeLine.customTimeLineDataFrame.data
			mdata[data.spell] = nil
			data.spell = text
			mdata[data.spell] = data.data
		end
	end
	function options.timeLine.customTimeLineDataFrame:spell_enter()
		local text = tonumber(self:GetText() or "")
		if not text then return end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetHyperlink("spell:"..text )
		GameTooltip:Show()
	end
	function options.timeLine.customTimeLineDataFrame:spell_leave()
		GameTooltip_Hide()
	end

	function options.timeLine.customTimeLineDataFrame:time_mini_update()
		local parent = self:GetParent()
		
		local now = parent.data[parent._i]
		local prev = parent.data[parent._i-1]
		if type(now) == "table" then now = now[1] end
		if type(prev) == "table" then prev = prev[1] end
		local diff = now and prev and now - prev
		if diff and diff < 0 then diff = nil end
		self:Text(diff or "")
	end

	function options.timeLine.customTimeLineDataFrame:time_edit(isUser)
		if not isUser then return end
		local text = self:GetText()
		local t = module:ConvertMinuteStrToNum(text or "")
		if t then t = t[1] end
		self.data[self._i] = t
		self.mini:Update()
		if self.next then
			self.next.mini:Update()
		end
	end

	function options.timeLine.customTimeLineDataFrame:time_editmini(isUser)
		if not isUser then return end
		local text = self:GetText()
		local t = module:ConvertMinuteStrToNum(text or "")
		if t then t = t[1] end
		if not t then return end
		local parent = self:GetParent()
		local prev = parent.data[parent._i-1]
		if type(prev) == "table" then prev = prev[1] end
		parent.data[parent._i] = prev + t
		parent:Text( module:FormatTime3(parent.data[parent._i]) or "" )
		if parent.next then
			parent.next.mini:Update()
		end
	end

	function options.timeLine.customTimeLineDataFrame:time_remove_click()
		local parent = self:GetParent()
		tremove(parent.data, parent._i)

		options.timeLine.customTimeLineDataFrame:Update()
	end

	function options.timeLine.customTimeLineDataFrame:time_add_click()
		local parent = self:GetParent()
		tinsert(parent.data, self._I or parent._i, self._T or parent.data[parent._i] or 0)

		options.timeLine.customTimeLineDataFrame:Update()
	end

	options.timeLine.customTimeLineDataFrame.dataToLine = {}
	function options.timeLine.customTimeLineDataFrame:UpdateView()
		local pos = self.frame:GetVerticalScroll()
		local h_pos = self.frame:GetHorizontalScroll()

		local spellsList = self.sList

		for i=1,#self.frame.lines do
			self.frame.lines[i].used = false
		end

		local datasUsed = {}
		for i=1,#spellsList do
			local data = spellsList[i]
			if data.pos + 25 >= pos and data.pos <= pos+self.frame:GetHeight() then
				local line = self.dataToLine[data]
				if line then
					line.used = true
				end
			elseif self.dataToLine[data] then
				self.dataToLine[data] = nil
			end
		end

		for i=1,#spellsList do
			local data = spellsList[i]
			if data.pos + 25 >= pos and data.pos <= pos+self.frame:GetHeight() then
				local line = self.dataToLine[data]
				if not line then
					for j=1,#self.frame.lines do
						if not self.frame.lines[j].used then
							line = self.frame.lines[j]
							break
						end
					end
				end
				if not line then
					line = CreateFrame("Frame",nil,self.frame.C)
					self.frame.lines[#self.frame.lines+1] = line
					line:SetSize(500,24)

					line.spell = ELib:Edit(line):Size(100,20):Point("LEFT",5,0):BackgroundText("Spell ID"):OnChange(self.spell_edit):OnEnter(self.spell_enter):OnLeave(self.spell_leave)
	
					line.remove = ELib:Button(line,""):Size(12,20):Point("LEFT",line.spell,"RIGHT",3,0):OnClick(self.removeButton_click)
					ELib:Text(line.remove,"x"):Point("CENTER",0,0)
					line.remove.Texture:SetGradient("VERTICAL",CreateColor(0.35,0.06,0.09,1), CreateColor(0.50,0.21,0.25,1))

					line.bg = line:CreateTexture(nil,"BACKGROUND")
					line.bg:SetAllPoints()

					line.add = ELib:Button(line,""):Size(20,20):OnClick(self.time_add_click)
					ELib:Text(line.add,"+"):Point("CENTER",0,0)
					line.add.Texture:SetGradient("VERTICAL",CreateColor(0.25,0.25,0.09,1), CreateColor(0.45,0.45,0.17,1))
	
					line.timers = {}
				end
				line.used = true
				self.dataToLine[data] = line

				local timers_c = 0
				local data_len = 0
				if data.data then 
					line.remove:Show()
					line.add:Show()

					local prev = nil
					data_len = #data.data
					for j=1,data_len do
						local timer_pos = 5+100+30+(j-1)*130
						if timer_pos + 50 >= h_pos and timer_pos - 80 <= h_pos+self.frame:GetWidth() then
							timers_c = timers_c + 1
							local timer_edit = line.timers[timers_c]
							if not timer_edit then
								timer_edit = ELib:Edit(line):Size(50,20):OnChange(self.time_edit)
	
								timer_edit.remove = ELib:Button(timer_edit,""):Size(8,20):Point("LEFT",timer_edit,"RIGHT",0,0):OnClick(self.time_remove_click)
								ELib:Text(timer_edit.remove,"x",8):Point("CENTER",0,0)
								timer_edit.remove.Texture:SetGradient("VERTICAL",CreateColor(0.35,0.06,0.09,1), CreateColor(0.50,0.21,0.25,1))
	
								timer_edit.add = ELib:Button(timer_edit,""):Size(8,20):Point("RIGHT",timer_edit,"LEFT",0,0):OnClick(self.time_add_click)
								ELib:Text(timer_edit.add,"+",8):Point("CENTER",0,0)
								timer_edit.add.Texture:SetGradient("VERTICAL",CreateColor(0.06,0.2,0.09,1), CreateColor(0.14,0.35,0.17,1))
									
								timer_edit.mini = ELib:Edit(timer_edit):Size(30,12):FontSize(8):OnChange(self.time_editmini):Point("RIGHT",timer_edit,"LEFT",-25,0)
								timer_edit.mini.Update = self.time_mini_update

								timer_edit.borderleft = timer_edit:CreateTexture(nil,"BACKGROUND")
								timer_edit.borderleft:SetSize(20,1)
								timer_edit.borderleft:SetPoint("RIGHT",timer_edit.mini,"LEFT",0,0)
								timer_edit.borderleft:SetColorTexture(0.24,0.25,0.3,1)

								timer_edit.borderright = timer_edit:CreateTexture(nil,"BACKGROUND")
								timer_edit.borderright:SetSize(20,1)
								timer_edit.borderright:SetPoint("LEFT",timer_edit.mini,"RIGHT",0,0)
								timer_edit.borderright:SetColorTexture(0.24,0.25,0.3,1)
	
								line.timers[timers_c] = timer_edit
							end

							timer_edit._i = j
							timer_edit:Point("LEFT",timer_pos,0)
							if prev then
								prev.next = timer_edit
							end
							timer_edit.next = nil

							timer_edit.mini:SetShown(j > 1)
							timer_edit.borderleft:SetShown(j > 1)
							timer_edit.borderright:SetShown(j > 1)
	
							local t = data.data[j]
							if type(t) == "table" then t = t[1] end
	
							timer_edit.data = data.data						
							timer_edit:Text( t and module:FormatTime3(t) or "" )
							timer_edit.mini:Update()
							timer_edit:Show()

							prev = timer_edit
						end
					end
				else
					line.remove:Hide()
					line.add:Hide()
				end
		
				for j=timers_c+1,#line.timers do
					line.timers[j]:Hide()
				end
				line.add:Point("LEFT",line.spell,"RIGHT",30+data_len*50+max(0,data_len-1)*80+20,0)
				line.add._I = data_len+1
				line.add._T = data.data and data_len > 0 and (type(data.data[data_len])=="table" and data.data[data_len][1] or data.data[data_len]) or 0
		
				line.data = data.data
				line:SetPoint("TOPLEFT",0,-data.pos)
				line.spell:SetText(data.spell or "")
				if data.spell == "p" then
					line.spell:SetText("Phases")
					line.spell:Disable()
				else
					line.spell:Enable()
				end
				line.data_i = data._i
				line.remove._i = i

				line:SetWidth(max(200,self:GetWidth()))		

				line:Show()
			end
		end
		for i=1,#self.frame.lines do
			if not self.frame.lines[i].used then
				self.frame.lines[i]:Hide()
			end
		end
	end

	function options.timeLine.customTimeLineDataFrame:OpenEdit(bossID, data)
		self.data = data
		self.bossID = bossID
		self.bossList:AutoText(bossID or 0,nil,true)
		self:Show()
		self:Update()
	end
	function options.timeLine.customTimeLineDataFrame:Update()
		if not self.data then
			self.data = {}
		end
		local data = self.data
		wipe(self.dataToLine)

		local maxw = max(0,data.p and #data.p or 0)
		self.sList = {}
		if data.p then
			self.sList[#self.sList+1] = {
				spell = "p",
				data = data.p or {},
				sort = -1,
			}
		end
		for k,v in pairs(data) do
			if type(k) == "number" then
				self.sList[#self.sList + 1] = {
					spell = k,
					data = v,
					sort = #v == 0 and math.huge or type(v[1]) == "table" and v[1][1] or v[1],
				}
				maxw = max(maxw,#v)
			end
		end
		sort(self.sList,function(a,b)
			return a.sort < b.sort
		end)
		self.sList[#self.sList + 1] = {}

		for i=1,#self.sList do
			self.sList[i].pos = 5 + 25 * (i-1)
			self.sList[i]._i = i
		end

		local maxheight = 5 + #self.sList * 25 + 15
		local maxwidth = max(5+100+30+maxw*50+(maxw-1)*80+20+30+20, self:GetWidth())

		self.frame:Height(maxheight)
		self.frame:Width(maxwidth)

		self:UpdateView()
	end

	options.timeLine.customTimeLineDataFrame.frame:SetScript("OnVerticalScroll", function(self)
		self:GetParent():UpdateView()
	end)
	options.timeLine.customTimeLineDataFrame.frame:SetScript("OnHorizontalScroll", function(self)
		self:GetParent():UpdateView()
	end)




	self.assign = {
		Data = ExRT.Data.ReminderTimeline,

		BOSS_ID = 0,

		TIMELINE_SCALE = 80,
		TIMELINE_ADJUST_NUM = 3,
		TIMELINE_ADJUST = 100,
		TIMELINE_ADJUST_DATA = {},

		TL_PAGEWIDTH = type(VMRT.Reminder2.OptAssigWidth) == "number" and VMRT.Reminder2.OptAssigWidth or 1000,
		TL_LINESIZE = type(VMRT.Reminder2.OptAssigLineSize) == "number" and VMRT.Reminder2.OptAssigLineSize or 14,
		TL_REMSIZE = 24,	
		TL_HEADER_COLOR_OFF = {.2,.2,.2,1},
		TL_HEADER_COLOR_ON = {.5,.8,1,1},
		TL_HEADER_COLOR_HOVER = {1,1,0,1},
		TL_ASSIGNWIDTH = 100,
		TL_ASSIGNSPACING = 5,

		FILTER_AURA = true,

		gluerange = 2,

		spell_status = {},
		spell_dur = {},
		custom_phase = {},
		reminder_hide = {},
		custom_line = {},
		custom_cd = type(VMRT.Reminder2.OptAssigCustomCD) == "table" and VMRT.Reminder2.OptAssigCustomCD or {},
		custom_charges = {},
		custom_spells = {},

		QFILTER_CLASS = type(VMRT.Reminder2.OptAssigQFClass) == "table" and VMRT.Reminder2.OptAssigQFClass or {},
		QFILTER_ROLE = type(VMRT.Reminder2.OptAssigQFRole) == "table" and VMRT.Reminder2.OptAssigQFRole or {},
		QFILTER_SPELL = type(VMRT.Reminder2.OptAssigQFSpell) == "table" and VMRT.Reminder2.OptAssigQFSpell or {},

		FILTER_SPELLS = VMRT.Reminder2.OptAssigFSpells,

		SpellGroups_Presetup = {
			["names"] = {"raid cd","personals","externals","ultility","movement","dps cd","aoe cc","single cc",},
			{[388615]=true,[51052]=true,[200183]=true,[370960]=true,[47536]=true,[97462]=true,[370537]=true,[265202]=true,[33891]=true,[124974]=true,[207399]=true,[197721]=true,[325197]=true,[374227]=true,[359816]=true,[472433]=true,[363534]=true,[216331]=true,[108280]=true,[34433]=true,[414660]=true,[200652]=true,[15286]=true,[322118]=true,[62618]=true,[98008]=true,[108281]=true,[31821]=true,[31884]=true,[105809]=true,[740]=true,[114052]=true,[271466]=true,[421453]=true,[64843]=true,[115310]=true,[196718]=true,},
			{[47585]=true,[108270]=true,[55342]=true,[48792]=true,[19236]=true,[1160]=true,[374348]=true,[48743]=true,[86659]=true,[184364]=true,[198589]=true,[498]=true,[110959]=true,[196555]=true,[22842]=true,[49028]=true,[235450]=true,[31224]=true,[122470]=true,[104773]=true,[11426]=true,[23920]=true,[198103]=true,[586]=true,[871]=true,[185311]=true,[49039]=true,[642]=true,[235219]=true,[108271]=true,[264735]=true,[12975]=true,[122278]=true,[109304]=true,[186265]=true,[108416]=true,[55233]=true,[118038]=true,[5277]=true,[194679]=true,[45438]=true,[342245]=true,[184662]=true,[363916]=true,[1966]=true,[61336]=true,[155835]=true,[22812]=true,[122783]=true,[48707]=true,[108238]=true,[132578]=true,[115176]=true,[205191]=true,[235313]=true,[31850]=true,},
			{[102342]=true,[116849]=true,[633]=true,[6940]=true,[357170]=true,[108968]=true,[10060]=true,[204018]=true,[33206]=true,[47788]=true,},
			{[101643]=true,[157981]=true,[102793]=true,[19801]=true,[372048]=true,[186387]=true,[111771]=true,[115315]=true,[406732]=true,[49576]=true,[383013]=true,[388007]=true,[132469]=true,[66]=true,[51490]=true,[278326]=true,[116844]=true,[408233]=true,[8143]=true,[5938]=true,[57934]=true,[235219]=true,[1044]=true,[360827]=true,[383269]=true,[16191]=true,[29166]=true,[370665]=true,[236776]=true,[64901]=true,[374251]=true,[32375]=true,[319454]=true,[108285]=true,[2908]=true,[342245]=true,[1856]=true,[328774]=true,[157980]=true,[205364]=true,[79206]=true,[34477]=true,[1022]=true,[119996]=true,},
			{[48018]=true,[79206]=true,[195457]=true,[389713]=true,[6544]=true,[1953]=true,[190784]=true,[48265]=true,[374968]=true,[36554]=true,[106898]=true,[252216]=true,[58875]=true,[196884]=true,[102401]=true,[73325]=true,[121536]=true,[212653]=true,[111771]=true,[192077]=true,[101545]=true,[186257]=true,[212552]=true,[370665]=true,[2983]=true,[1850]=true,[116841]=true,},
			{[201430]=true,[409311]=true,[384631]=true,[376079]=true,[10060]=true,[1719]=true,[152279]=true,[49206]=true,[387184]=true,[191427]=true,[375087]=true,[228260]=true,[193530]=true,[13750]=true,[114051]=true,[51271]=true,[359844]=true,[107574]=true,[381989]=true,[50334]=true,[42650]=true,[357210]=true,[47568]=true,[102558]=true,[403631]=true,[1856]=true,[260402]=true,[111898]=true,[190319]=true,[19574]=true,[279302]=true,[370965]=true,[194223]=true,[192249]=true,[383269]=true,[102543]=true,[123904]=true,[360194]=true,[34433]=true,[360952]=true,[12472]=true,[288613]=true,[121471]=true,[198067]=true,[186289]=true,[12051]=true,[265187]=true,[1122]=true,[205180]=true,[443028]=true,[207289]=true,[343142]=true,[196937]=true,[365350]=true,[31884]=true,[102560]=true,[46924]=true,[227847]=true,[137639]=true,[391528]=true,[106951]=true,[114050]=true,[385408]=true,},
			{[197214]=true,[376079]=true,[157997]=true,[372048]=true,[202137]=true,[383121]=true,[113724]=true,[192058]=true,[8122]=true,[179057]=true,[109248]=true,[30283]=true,[386071]=true,[51490]=true,[207684]=true,[99]=true,[116844]=true,[46968]=true,[187698]=true,[2484]=true,[31661]=true,[115750]=true,[108199]=true,[102359]=true,[120]=true,[78675]=true,[5246]=true,[191427]=true,[5484]=true,[198898]=true,[2094]=true,[207167]=true,[122]=true,[12323]=true,[108920]=true,[51485]=true,[119381]=true,[202138]=true,[358385]=true,},
			{[20066]=true,[2094]=true,[5211]=true,[360806]=true,[51514]=true,[217832]=true,[853]=true,[187650]=true,[6789]=true,[64044]=true,[19577]=true,[107570]=true,[22570]=true,[213691]=true,[305483]=true,[10326]=true,[221562]=true,[183218]=true,[408]=true,[162488]=true,[1776]=true,[115078]=true,[211881]=true,},
		},

		spellsCDAdditional = {
			{414658,"MAGE",3,{414658,180,6}},
			{48018,"WARLOCK",3,{48018,10,0}},
			{48020,"WARLOCK",3,{48020,30,0}},
			{451235,"PRIEST",3,{451235,120,15}},
		},

		OPTS_TTS = VMRT.Reminder2.OptAssigTTS,
		OPTS_NOSPELLNAME = VMRT.Reminder2.OptAssigNospellname,
		OPTS_MARKSHARED = VMRT.Reminder2.OptAssigMarkShared,
		OPTS_SOUNDDELAY = VMRT.Reminder2.OptAssigSoundDelay,
		OPTS_DURDEF = VMRT.Reminder2.OptAssigDur,
	}

	VMRT.Reminder2.OptAssigQFClass = self.assign.QFILTER_CLASS
	VMRT.Reminder2.OptAssigQFRole = self.assign.QFILTER_ROLE
	VMRT.Reminder2.OptAssigQFSpell = self.assign.QFILTER_SPELL
	VMRT.Reminder2.OptAssigCustomCD = self.assign.custom_cd

	options.assign.GetTimeLineData = options.timeLine.GetTimeLineData

	options.assign.GetTimeForSpell = options.timeLine.GetTimeForSpell
	options.assign.GetSpellFromTime = options.timeLine.GetSpellFromTime
	options.assign.GetTimeUntilPhaseEnd = options.timeLine.GetTimeUntilPhaseEnd
	options.assign.GetTimeOnPhaseMulti = options.timeLine.GetTimeOnPhaseMulti
	options.assign.GetTimeOnPhase = options.timeLine.GetTimeOnPhase
	options.assign.GetPhaseFromTime = options.timeLine.GetPhaseFromTime
	options.assign.GetPhaseTotalCount = options.timeLine.GetPhaseTotalCount
	options.assign.GetPhaseCounter = options.timeLine.GetPhaseCounter
	options.assign.IsRemovedByTimeAdjust = options.timeLine.IsRemovedByTimeAdjust
	options.assign.GetTimeAdjust = options.timeLine.GetTimeAdjust
	options.assign.GetTimeFromPos = options.timeLine.GetTimeFromPos
	options.assign.GetPosFromTime = options.timeLine.GetPosFromTime
	options.assign.util_sort_by2 = options.timeLine.util_sort_by2
	options.assign.util_sort_reminders = options.timeLine.util_sort_reminders
	options.assign.ExportToString = options.timeLine.ExportToString

	options.assign.OpenQuickSetupFrame = options.timeLine.OpenQuickSetupFrame

	function options.assign:IsPassFilterSpellType(spellData,spell)
		if 
			(
			 ((spellData.spellType or 1) == 1 and not self.FILTER_CAST) or
			 (spellData.spellType == 2 and not self.FILTER_AURA)
			) and
			(not self.FILTER_SPELL or self.FILTER_SPELL[spell])
		then
			return true
		end
	end

	options.assign.GetRemindersList = options.timeLine.GetRemindersList

	options.assign.ResetAdjust = options.timeLine.ResetAdjust

	options.assign.CreateCustomTimelineFromHistory = options.timeLine.CreateCustomTimelineFromHistory

	function options.assign:GetSpellsCDList()
		local list = self.spellsCDList
		if not list then
			list = {}
			self.spellsCDList = list

			local cd_module = ExRT.A.ExCD2
			for i=1,#cd_module.db.AllSpells do
				local line = cd_module.db.AllSpells[i]
				local class = strsplit(",",line[2])
				if ExRT.GDB.ClassID[class or 0] and not line[2]:find("PVP") then
					list[#list+1] = line
				end
			end

			for i=1,#self.spellsCDAdditional do
				list[#list+1] = self.spellsCDAdditional[i]
			end

			if VMRT.ExCD2 and type(VMRT.ExCD2.userDB)=="table" then
				for i=1,#VMRT.ExCD2.userDB do
					local data = VMRT.ExCD2.userDB[i]
					if 	--Prevent any errors for userbased cds
						type(data[1]) == "number" and
						type(data[2]) == "string" and
						(data[4] or data[5] or data[6] or data[7] or data[8]) and
						((data[4] and data[4][1] and data[4][2] and data[4][3]) or not data[4]) and
						((data[5] and data[5][1] and data[5][2] and data[5][3]) or not data[5]) and
						((data[6] and data[6][1] and data[6][2] and data[6][3]) or not data[6]) and
						((data[7] and data[7][1] and data[7][2] and data[7][3]) or not data[7]) and
						((data[8] and data[8][1] and data[8][2] and data[8][3]) or not data[8])
					then
						local isInDBAlready
						for j=1,#list do
							if list[j][1] == data[1] then
								isInDBAlready = true
								break
							end
						end
						
						if not isInDBAlready then
							local class = strsplit(",",data[2])
							if ExRT.GDB.ClassID[class or 0] and not data[2]:find("PVP") then
								list[#list+1] = data
							end
						end
					end
				end
			end
		end

		return list
	end

	function options.assign:GetSpellsCDListClass(class)
		if not self.spellsCDListClass then
			self.spellsCDListClass = {}
		end
		if self.spellsCDListClass[class] then
			return self.spellsCDListClass[class]
		end
		local list = {}
		self.spellsCDListClass[class] = list
		local AllSpells = self:GetSpellsCDList()
		for i=1,#AllSpells do
			local line = AllSpells[i]
			if strsplit(",",line[2]) == class or strsplit(",",line[2]) == "ALL" then
				list[#list+1] = line
			end
		end

		return list
	end

	function options.assign:UpdatePageWidth()
		local width = self.TL_PAGEWIDTH
		VMRT.Reminder2.OptAssigWidth = width

		local left = ELib.ScrollDropDown.DropDownList[1]:GetLeft()
		local top = ELib.ScrollDropDown.DropDownList[1]:GetTop()
		ELib.ScrollDropDown.DropDownList[1]:ClearAllPoints()
		ELib.ScrollDropDown.DropDownList[1]:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",left,top)

		options.isWide = width
		ExRT.Options.Frame:SetPage(ExRT.Options.Frame.CurrentFrame,true)

		self.frame:Size((width-300)-((options.assign.TL_ASSIGNWIDTH + 10) * 2 + 5 + 15),self.frame:GetHeight())

		local width = self.frame.width_now
		self.frame:Width(width)
		if width > self.frame:GetWidth() then
			self.frame.ScrollBarHorizontal:Show()
		elseif self.frame.ScrollBarHorizontal:IsShown() then
			self.frame.ScrollBarHorizontal:SetValue(0)
			self.frame.ScrollBarHorizontal:Hide()
		end
	end

	self.assignBoss = ELib:DropDown(self.tab.tabs[5],250,-1):Point("TOPLEFT",10,-10):Size(220):SetText(L.ReminderSelectBoss)
	self.assignBoss.mainframe = options.assign
	self.assignBoss.SetValue = function(_,arg1,arg2,arg3,arg4,ignoreReload)
		ELib:DropDownClose()
		options.assign.frame.bigBossButtons:Hide()

		wipe(options.assign.custom_phase)
		wipe(options.assign.reminder_hide)
		wipe(options.assign.custom_line)

		options.assign:ResetAdjust()

		options.assign.BOSS_ID = nil
		options.assign.ZONE_ID = nil
		options.assign.CUSTOM_TIMELINE = nil
		VMRT.Reminder2.TLBoss = nil
		--options.assign.FILTER_SPELL = nil

		options.assign.var_draggedlastline = nil

		options.assignBoss:SetText(arg2)
		if arg3 == 2 then
			options.assign.BOSS_ID = arg1[1] and arg1[1][3]
			options.assign.CUSTOM_TIMELINE = options.assign:CreateCustomTimelineFromHistory(arg1)
			VMRT.Reminder2.TLBoss = nil
		elseif arg3 == 5 then
			options.assign.ZONE_ID = arg1[1] and arg1[1][3]
			options.assign.CUSTOM_TIMELINE = options.assign:CreateCustomTimelineFromHistory(arg1)
			VMRT.Reminder2.TLBoss = nil
		elseif arg3 == 3 then
			options.assign.BOSS_ID = arg1
			options.assign.CUSTOM_TIMELINE = arg4.tl
			VMRT.Reminder2.TLBoss = arg4.id
		elseif arg3 == 4 then
			options.assign.ZONE_ID = arg1
			options.assign.CUSTOM_TIMELINE = arg4 and arg4.tl
		else
			options.assign.BOSS_ID = arg1
			VMRT.Reminder2.TLBoss = arg1
		end

		if not ignoreReload then
			options.assign:Update()
			options.timeLineBoss:SetValue(arg1,arg2,arg3,arg4,true)
		end
	end
	self.assignBoss.PreUpdate = self.timeLineBoss.PreUpdate
	self.assignBoss.SelectBoss = self.timeLineBoss.SelectBoss


	self.assignSettingsButton = ELib:DropDownButton(self.tab.tabs[5],SETTINGS,220,-1):Point("LEFT",self.assignBoss,"RIGHT",40,0):Size(140,20)
	function self.assignSettingsButton:SetFilterValue(arg1,arg2)
		ELib:DropDownClose()
		options.assign[arg1] = not options.assign[arg1]
		options.assign:Update()
		if arg2 then
			VMRT.Reminder2[arg2] = options.assign[arg1]
		end
	end
	self.assignSettingsButton.List = {
		{
			text = "Assignment range for spell",
			isTitle = true,
		},{
			text = "",
			isTitle = true,	
			slider = {min = 0, max = 60, val = options.assign.gluerange, afterText = " "..(SECONDS or "sec."), func = function(self,val)
				options.assign.gluerange = floor(val + .5)
				self:GetParent().data.slider.val = val
				options.assign:Update()
			end}
		},{
			text = " ",
			isTitle = true,
		},{
			text = "Line height",
			isTitle = true,
		},{
			text = "",
			isTitle = true,	
			slider = {min = 3, max = 102, reset = 14, val = options.assign.TL_LINESIZE, func = function(self,val)
				options.assign.TL_LINESIZE = floor(val+0.5)
				options.assign:UpdateLineSize()
				self:GetParent().data.slider.val = val
			end}
		},{
			text = " ",
			isTitle = true,
		},{
			text = "Page width",
			isTitle = true,
		},{
			text = "",
			isTitle = true,	
			slider = {min = 800, max = 1600, reset = 1000, val = options.assign.TL_PAGEWIDTH, func = function(self,val)
				options.assign.TL_PAGEWIDTH = floor(val+0.5)
				options.assign:UpdatePageWidth()
				self:GetParent().data.slider.val = val
			end}
		},{
			text = " ",
			isTitle = true,
		},{
			text = "Lines filters",
			isTitle = true,
		},{
			text = L.ReminderFilterCasts,
			checkable = true,
			func = self.assignSettingsButton.SetFilterValue,
			arg1 = "FILTER_CAST",
			alter = true,
		},{
			text = L.ReminderFilterAuras,
			checkable = true,
			func = self.assignSettingsButton.SetFilterValue,
			arg1 = "FILTER_AURA",
			alter = true,
		},{
			text = " ",
			isTitle = true,
		},{
			text = "Reminders filters",
			isTitle = true,
		},{
			text = "Show only reminders for filtered spells",
			checkable = true,
			func = self.assignSettingsButton.SetFilterValue,
			arg1 = "FILTER_SPELLS",
			arg2 = "OptAssigFSpells",
			alter = true,
		},{
			text = "Mark reminders from shared profile",
			checkable = true,
			func = self.assignSettingsButton.SetFilterValue,
			arg1 = "OPTS_MARKSHARED",
			arg2 = "OptAssigMarkShared",
			alter = false,
		},{
			text = " ",
			isTitle = true,
		},{
			text = "New reminders options",
			isTitle = true,
		},{
			text = "",
			isTitle = true,	
			slider = {min = 1, max = 5, reset = 3, sliderText = function(_,val) return format("Duration: %d",val) end, val = options.assign.OPTS_DURDEF or 3, func = function(self,val)
				val = floor(val+0.5)
				self:GetParent().data.slider.val = val
				if val == 3 then val = nil end
				options.assign.OPTS_DURDEF = val
				VMRT.Reminder2.OptAssigDur = val
			end}
		},{
			text = "Use TTS as sound",
			checkable = true,
			func = self.assignSettingsButton.SetFilterValue,
			arg1 = "OPTS_TTS",
			arg2 = "OptAssigTTS",
			alter = true,
		},{
			text = "",
			isTitle = true,	
			slider = {min = 0, max = 3, reset = 0, step = 0.1, sliderText = function(_,val) return val == 0 and "No sound delay" or format("Sound delay: %.1fs",val) end, val = options.assign.OPTS_SOUNDDELAY or 0, func = function(self,val)
				self:GetParent().data.slider.val = val
				if val == 0 then val = nil end
				options.assign.OPTS_SOUNDDELAY = val
				VMRT.Reminder2.OptAssigSoundDelay = val
			end}
		},{
			text = "Icon without spell name",
			checkable = true,
			func = self.assignSettingsButton.SetFilterValue,
			arg1 = "OPTS_NOSPELLNAME",
			arg2 = "OptAssigNospellname",
			alter = false,
		},
	}
	function self.assignSettingsButton:PreUpdate()
		for i=1,#self.List do
			local line = self.List[i]
			if line.func == self.SetFilterValue then
				line.checkState = (line.alter and not options.assign[line.arg1]) or (not line.alter and options.assign[line.arg1])
				if line.hidF then
					line.isHidden = not line.hidF()
				end
			end
		end
	end


	self.assignAdjustFL = ELib:Button(self.tab.tabs[5],L.ReminderAdjustFL):Point("LEFT",self.assignSettingsButton,"RIGHT",5,0):Size(140,20):OnEnter(function(self)
		self.subframe:Show()
	end)

	self.assignAdjustFL.subframe = CreateFrame("Frame",nil,self.assignAdjustFL)
	self.assignAdjustFL.subframe:SetPoint("TOPLEFT",self.assignAdjustFL,"BOTTOMLEFT",-40,2)
	self.assignAdjustFL.subframe:SetPoint("TOPRIGHT",self.assignAdjustFL,"BOTTOMRIGHT",40,2)
	self.assignAdjustFL.subframe:SetHeight(25+25*options.assign.TIMELINE_ADJUST_NUM)
	self.assignAdjustFL.subframe:Hide()
	self.assignAdjustFL.subframe:SetScript("OnUpdate",function(self)
		if not self:IsMouseOver() and not self:GetParent():IsMouseOver() then
			self:Hide()
		end
	end)
	self.assignAdjustFL.subframe.bg = self.assignAdjustFL.subframe:CreateTexture(nil,"BACKGROUND")
	self.assignAdjustFL.subframe.bg:SetAllPoints()
	self.assignAdjustFL.subframe.bg:SetColorTexture(0,0,0,1)

	self.assignAdjustFL.subframe.timeScale = ELib:Slider(self.assignAdjustFL.subframe):Size(100):Point("TOP",0,-5):Range(10,200,true):SetTo(options.assign.TIMELINE_ADJUST):OnChange(function(self,val)
		options.assign.TIMELINE_ADJUST = floor(val+0.5)
		if not self.lock then
			options.assign:Update()
		end
		self.tooltipText = L.ReminderGlobalTimeScale..": "..options.assign.TIMELINE_ADJUST .. "%"
		self:tooltipReload(self)
	end)
	self.assignAdjustFL.subframe.timeScale.tooltipText = L.ReminderGlobalTimeScale..": "..options.assign.TIMELINE_ADJUST .. "%"

	for i=1,options.assign.TIMELINE_ADJUST_NUM do
		options.assign.TIMELINE_ADJUST_DATA[i] = {0,0}
		self.assignAdjustFL.subframe["tpos"..i] = ELib:Edit(self.assignAdjustFL.subframe,"0"):Size(40,20):Point("TOPLEFT",35,-20-(i-1)*25):LeftText(L.ReminderTimeScaleT1):Tooltip(L.ReminderTimeScaleTip1):OnChange(function(self,isUser)
			if not isUser then return end
			local t = self:GetText() or ""
			t = module:ConvertMinuteStrToNum(t)
			options.assign.TIMELINE_ADJUST_DATA[i][1] = t and t[1] or nil

			options.assign:Update()
		end)

		self.assignAdjustFL.subframe["addtime"..i] = ELib:Edit(self.assignAdjustFL.subframe,"0"):Size(40,20):Point("LEFT",self.assignAdjustFL.subframe["tpos"..i],"RIGHT",55,0):LeftText(L.ReminderTimeScaleT2):RightText(L.ReminderTimeScaleT3):Tooltip(L.ReminderTimeScaleTip2):OnChange(function(self,isUser)
			if not isUser then return end
			options.assign.TIMELINE_ADJUST_DATA[i][2] = tonumber(self:GetText() or "")

			options.assign:Update()
		end)
	end

	self.assignExportToNote = ELib:Button(self.tab.tabs[5],L.ReminderExportToNote):Point("LEFT",self.assignAdjustFL,"RIGHT",5,0):Tooltip("Hold Shift to ignore phases and use only timer from start of the fight"):Size(140,20):OnClick(function()
		local str = options.assign:ExportToString()

		ExRT.F:Export(str,true)
	end)


	self.assignImportFromNote = ELib:Button(self.tab.tabs[5],L.ReminderImportFromNote):Point("LEFT",self.assignExportToNote,"RIGHT",5,0):Size(140,20):OnClick(function()
		self.timeLineImportFromNoteFrame.mainframe = options.assign
		self.timeLineImportFromNoteFrame:Show()
	end)

	options.assign.UndoButton = ELib:Button(self.tab.tabs[5],L.ReminderUndo):Tooltip(L.ReminderUndoTip):Point("TOP",self.assignImportFromNote,"BOTTOM",0,0):Shown(false):Size(140,20):OnClick(function(self)
		for uid in pairs(options.assign.undoimportlist.remove) do
			module:RemRem(uid)
		end
		for uid,data in pairs(options.assign.undoimportlist.repair) do
			module:RemAdd(uid,data)
		end
		options:Update()
		module:ReloadAll()
		self:Hide()
	end):OnShow(function(self)
		if self.tmr then
			self.tmr:Cancel()
		end
		self.tmr = C_Timer.NewTimer(30,function() self:Hide() end)
	end,true)

	self.assignSend = ELib:Button(self.tab.tabs[5],L.ReminderSend):Point("LEFT",self.assignImportFromNote,"RIGHT",5,0):Size(140,20):OnClick(function()
		module:Sync(false,options.assign.BOSS_ID and {[options.assign.BOSS_ID]=true},options.assign.ZONE_ID and {[options.assign.ZONE_ID]=true})
	end)

	self.assignLive = ELib:Button(self.tab.tabs[5],"Start live session"):Point("BOTTOM",self.assignSend,"TOP",0,10):Size(140,20):Tooltip("Players will be invited to live session. Everyone who accept will able to add/change/remove reminders. All changes will be in shared profile, don't forget to copy them to any profile if you want to save them."):OnClick(function()
		if isLiveSession then
			if module.db.liveSessionMainProfile then
				module:StopLive()
			else
				module:StopLiveUser()
			end
		else
			module:StartLive(options.assign.BOSS_ID and {[options.assign.BOSS_ID]=true},options.assign.ZONE_ID and {[options.assign.ZONE_ID]=true})
		end
	end):OnShow(function(self) self:UpdateStatus() end,true)
	function self.assignLive:UpdateStatus()
		if isLiveSession then
			self:SetText("|cff00ff00Live session is ON")
			self.alert:Point("LEFT",options.profileDropDown,"RIGHT",5,0)
			self.alert:Show()
		else
			self:SetText("Start live session")
			self.alert:Hide()
		end
		if isLiveSession then
			self:Enable()
			if module.db.liveSessionMainProfile then

			else
				self:SetText("|cffff0000Exit live session")
			end
			return
		end
		if IsInRaid() then
			if ExRT.F.IsPlayerRLorOfficer("player") then
				self:Enable()
			else
				self:Disable()
			end
		else
			self:Enable()
		end
	end
	self.assignLiveAlert = ELib:Text(self,"Live session is on",12):Color(0,1,0,1):Left():Shown(false)
	self.assignLive.alert = self.assignLiveAlert

	options.assign.frame = ELib:ScrollFrame(self.tab.tabs[5]):Size(((options.assign.TL_PAGEWIDTH or 1000)-300)-((options.assign.TL_ASSIGNWIDTH + 10) * 2 + 5 + 15),520):Height(520):AddHorizontal(true):Width(1000)
	ELib:Border(options.assign.frame,0)

	options.assign.frame.headers = ELib:ScrollFrame(self.tab.tabs[5]):Point("TOPLEFT",0,-50):Size(300,520):Height(500)
	ELib:Border(options.assign.frame.headers,0)

	options.assign.frame:Point("TOPLEFT",options.assign.frame.headers,"TOPRIGHT",0,0)

	options.assign.frame.QUICK_HEIGHT = 60 + 20 + 10
	options.assign.frame.quick = ELib:ScrollFrame(self.tab.tabs[5]):Size(((options.assign.TL_ASSIGNWIDTH + 10) * 2 + 5 + 15),520-options.assign.frame.QUICK_HEIGHT):Height(100):Point("TOPLEFT",options.assign.frame,"TOPRIGHT",0,-options.assign.frame.QUICK_HEIGHT)
	ELib:Border(options.assign.frame.quick,0)
	options.assign.frame.quick.ScrollBar.thumb:SetHeight(60) 

	options.assign.frame.D = CreateFrame("Frame",nil,options.assign.frame.C)
	options.assign.frame.D:SetAllPoints()
	options.assign.frame.D:SetFrameLevel(8000)

	--options.assign.frame.ScrollBar:Hide()
	options.assign.frame.headers.ScrollBar:Hide()

	options.assign.frame.lines = {}
	options.assign.frame.red = {}
	options.assign.frame.yellow = {}

	options.assign.frame:SetScript("OnVerticalScroll", function(self)
		options.assign.frame.headers:SetVerticalScroll( self:GetVerticalScroll() )
		options.assign:UpdateView()
	end)
	options.assign.frame.headers:SetScript("OnMouseWheel", function(self,delta)
		options.assign.frame:GetScript("OnMouseWheel")(options.assign.frame, delta)
	end)

	options.assign.frame.bg = options.assign.frame.C:CreateTexture(nil,"BACKGROUND",nil,-8)
	options.assign.frame.bg:SetColorTexture(23/255, 31/255, 33/255, 1)
	options.assign.frame.bg:SetPoint("TOPLEFT",0,0)
	options.assign.frame.bg:SetPoint("BOTTOM",0,0)
	options.assign.frame.bg:SetPoint("RIGHT",options,0,0)

	options.assign.frame.bg2 = options.assign.frame.C:CreateTexture(nil,"BACKGROUND",nil,-7)
	options.assign.frame.bg2:SetPoint("LEFT",options.assign.frame.bg,0,0)
	options.assign.frame.bg2:SetPoint("RIGHT",options.assign.frame.bg,0,0)
	options.assign.frame.bg2:SetPoint("TOP",0,0)
	options.assign.frame.bg2:SetPoint("BOTTOM",0,0)
	options.assign.frame.bg2:SetColorTexture(1,1,1, 1)
	options.assign.frame.bg2:SetGradient("VERTICAL",CreateColor(0,0,0,.2), CreateColor(0,0,0,0))


	options.assign.frame.bigBossButtons = CreateFrame("Button",nil,options.assign.frame)
	options.assign.frame.bigBossButtons:SetPoint("TOPLEFT",options.assign.frame.headers,0,0)
	options.assign.frame.bigBossButtons:SetPoint("BOTTOMRIGHT",options,0,0)
	options.assign.frame.bigBossButtons:SetFrameLevel(9000)
	options.assign.frame.bigBossButtons:SetFrameStrata("DIALOG")

	options.assign.frame.bigBossButtons.bg = options.assign.frame.bigBossButtons:CreateTexture(nil,"BACKGROUND",nil,-8)
	options.assign.frame.bigBossButtons.bg:SetColorTexture(0,0,0, 1)
	options.assign.frame.bigBossButtons.bg:SetAllPoints()

	options.assign.frame.bigBossButtons.buttons = {}
	options.assign.frame.bigBossButtons.Reset = options.timeLine.frame.bigBossButtons.Reset
	options.assign.frame.bigBossButtons.Repos = options.timeLine.frame.bigBossButtons.Repos

	options.assign.frame.bigBossButtons.Util_BottonOnEnter = options.timeLine.frame.bigBossButtons.Util_BottonOnEnter
	options.assign.frame.bigBossButtons.Util_BottonOnLeave = options.timeLine.frame.bigBossButtons.Util_BottonOnLeave
	options.assign.frame.bigBossButtons.Util_BottonOnClick = options.timeLine.frame.bigBossButtons.Util_BottonOnClick
	options.assign.frame.bigBossButtons.Add = options.timeLine.frame.bigBossButtons.Add


	options.assign.frame:SetScript("OnUpdate",function(self)
		local x,y = ExRT.F.GetCursorPos(self)

		if self.saved_x and self.saved_y then
			if self.ScrollBarHorizontal:IsShown() and abs(x - self.saved_x) > 5 then
				local newVal = self.saved_scroll - (x - self.saved_x)
				local min,max = self.ScrollBarHorizontal:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.ScrollBarHorizontal:SetValue(newVal)

				self.moveSpotted = true
			end
			if self.ScrollBar:IsShown() and abs(y - self.saved_y) > 5 then
				local newVal = self.saved_scroll_v - (y - self.saved_y)
				local min,max = self.ScrollBar:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.ScrollBar:SetValue(newVal)

				self.moveSpotted = true
			end
		end

		if self.dragging then
			self.draggingNow = nil

			y = ceil((y + self:GetVerticalScroll()) / options.assign.TL_LINESIZE)

			x = x + self:GetHorizontalScroll() - self.draggingX - 1

			local line = options.assign.linedata[y]

			if not (self:IsMouseOver() or self.headers:IsMouseOver()) then
				line = nil
			end

			if IsShiftKeyDown() and not self.draggingShowShift then
				self.dragging:_SetAlpha(1)
				self.draggingShowShift = true
			elseif not IsShiftKeyDown() and self.draggingShowShift then
				self.dragging:_SetAlpha(0)
				self.draggingShowShift = false
			end

			options.assign:Util_LineAssignRemoveSpace()
			if line then
				self.draggingNow = line

				local p = ceil( x / ( options.assign.TL_ASSIGNWIDTH + options.assign.TL_ASSIGNSPACING ) )
				if p < 1 then p = 1 end

				if p <= #line.a and self.dragging ~= line.a[p].frame then
					line.a[p].frame:AddSpace(true)
				elseif self.dragging.line ~= line or IsShiftKeyDown() then
					options.assign:Util_LineAssignAddPhantom(line)
				end

				if self.prevHL and self.prevHL ~= line then
					options.assign.Util_LineOnLeave(self.prevHL)
					self.prevHL = nil
				end
				if not self.prevHL then
					options.assign.Util_LineOnEnter(line.line)
					self.prevHL = line.line
				end 
			else
				if self.prevHL then
					options.assign.Util_LineOnLeave(self.prevHL)
					self.prevHL = nil
				end
			end
		end
	end)


	options.assign.frame:SetScript("OnMouseDown",function(self)
		local x,y = ExRT.F.GetCursorPos(self)
		self.saved_x = x
		self.saved_y = y
		self.saved_scroll = self.ScrollBarHorizontal:GetValue()
		self.saved_scroll_v = self.ScrollBar:GetValue()
		self.moveSpotted = nil

	end)

	options.assign.frame:SetScript("OnMouseUp",function(self, button)
		self.saved_x = nil
		self.saved_y = nil
		if self.moveSpotted then
			self.moveSpotted = nil
			return
		end

		if self.dragging then
			return
		end

		local x,y = ExRT.F.GetCursorPos(self)
		x = x + self:GetHorizontalScroll()
		y = y + self:GetVerticalScroll()
		options.assign:ProcessClick(x, y, button)
	end)

	function options.assign:ProcessClick(x, y, button)
		y = ceil(y / self.TL_LINESIZE)

		local line = options.assign.linedata[y] 
		if not line then
			return
		end
		if button == "RightButton" then
			return
		end

		options.assign:AddNewReminderToLine(line,nil,true)
	end

	function options.assign:UpdateLineSize()
		VMRT.Reminder2.OptAssigLineSize = self.TL_LINESIZE
		for i=1,#self.frame.lines do
			local line = self.frame.lines[i]
			line:SetHeight(self.TL_LINESIZE)
			line:SetPoint("TOPLEFT",0,-self.TL_LINESIZE*(i-1))

			line.header:SetHeight(self.TL_LINESIZE)
			line.header:SetPoint("TOPLEFT",0,-self.TL_LINESIZE*(i-1))

			line.header.trigger:SetSize(self.TL_LINESIZE-2, self.TL_LINESIZE-2)
			line.header.icon:SetSize(self.TL_LINESIZE,self.TL_LINESIZE)
		end
		for j=1,#self.frame.assigns do
			local a = self.frame.assigns[j]
			a:SetHeight(self.TL_LINESIZE-2)
			a.icon:SetHeight(self.TL_LINESIZE-2)
			if a.icon:GetTexture() then
				a.icon:SetWidth(self.TL_LINESIZE-2)
			end
			a.iconRight:SetWidth(self.TL_LINESIZE-2)
		end
		for i=1,self.frame.quick.COLS_NUM do
			self.frame.quick.COLS_NOW[i] = 0
		end
		for i=1,#self.frame.quick.pframes do
			local line = self.frame.quick.pframes[i]
			local c = 0
			for j=1,#line.btn do
				local a = line.btn[j]
				a:SetHeight(self.TL_LINESIZE-2)
				a.icon:SetHeight(self.TL_LINESIZE-2)
				if a.icon:GetTexture() then
					a.icon:SetWidth(self.TL_LINESIZE-2)
				end
				a.iconRight:SetWidth(self.TL_LINESIZE-2)
			end
		end
		self:PlayerListUpdate()
		if self.frame.phantom_assign then
			local a = self.frame.phantom_assign
			a:SetHeight(self.TL_LINESIZE-2)
			a.icon:SetHeight(self.TL_LINESIZE-2)
			if a.icon:GetTexture() then
				a.icon:SetWidth(self.TL_LINESIZE-2)
			end
			a.iconRight:SetWidth(self.TL_LINESIZE-2)
		end
		if self.frame.draggingAssign then
			local a = self.frame.draggingAssign
			a:SetHeight(self.TL_LINESIZE-2)
			a.icon:SetHeight(self.TL_LINESIZE-2)
			if a.icon:GetTexture() then
				a.icon:SetWidth(self.TL_LINESIZE-2)
			end
			a.iconRight:SetWidth(self.TL_LINESIZE-2)
		end
		self:Update()
	end

	options.assign.Util_HeaderOnClick = function(self,button)
		local x,y = ExRT.F.GetCursorPos(self)
		local iconPos = self.icon:GetLeft() - self:GetLeft()
		if x < iconPos then
			ExRT.F.ShowInput("Add custom line at +X seconds",function(timestamp,t) 
				t = module:ConvertMinuteStrToNum(t)
				if not t then return end
				options.assign.custom_line[#options.assign.custom_line+1] = timestamp + t[1]
				options.assign:Update()
			end,self.data.time)
			return
		end
		if button == "RightButton" then
			if self.data.isCustom then
				for i=1,#options.assign.custom_line do
					if options.assign.custom_line[i] == self.data.isCustom then
						tremove(options.assign.custom_line, i)
						break
					end
				end
				options.assign:Update()
			end
		else
			options.assign.spell_status[self.spell] = not options.assign.spell_status[self.spell]
			options.assign:Update()
		end
	end

	options.assign.Util_HeaderOnEnter = function(self)
		if self.spell and self.spell ~= 0 then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:SetHyperlink("spell:"..self.spell )
			GameTooltip:Show()
		elseif self.tiptime then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:AddLine(module:FormatTime2(self.tiptime))
			GameTooltip:Show()
		end

		if not self.isOff then
			self.name:Color(unpack(options.assign.TL_HEADER_COLOR_HOVER))
		end
	end
	options.assign.Util_HeaderOnLeave = function(self)
		GameTooltip_Hide()

		self.name:Color(unpack(self.isOff and options.assign.TL_HEADER_COLOR_OFF or options.assign.TL_HEADER_COLOR_ON))
	end


	options.assign.Util_LineOnClick = function(self)
		--options.assign:AddNewReminderToLine(self,nil,true)
	end

	options.assign.Util_LineOnEnter = function(self)
		if not self.header.isOff then
			self.header.name:Color(unpack(options.assign.TL_HEADER_COLOR_HOVER))
		end
	end
	options.assign.Util_LineOnLeave = function(self)
		self.header.name:Color(unpack(self.header.isOff and options.assign.TL_HEADER_COLOR_OFF or options.assign.TL_HEADER_COLOR_ON))
	end

	options.assign.Util_LineAssignOnClick = function(self,button)
		if self.setup and self.setup.funcOnClick then return self.setup.funcOnClick(self.setup.funcOnClickArg) end
		if self.funcOnClick then self.funcOnClick(self) end
		if self.setup and button == "RightButton" then
			local spellName = GetSpellName(self.setup.spell)
			ExRT.F.ShowInput2("Set custom options for "..(spellName or self.setup.spell),function(res) 
				local t = module:ConvertMinuteStrToNum(res[1])
				if not t then 
					self.setup.cd = options.assign:GetSpellBaseCD(self.setup.spell)
					options.assign.custom_cd[self.setup.spell] = nil
				else
					self.setup.cd = t[1]
					options.assign.custom_cd[self.setup.spell] = t[1]
				end
				local c = tonumber(res[2] or 0)
				if type(c) == "number" and c > 1 then
					options.assign.custom_charges[self.setup.spell] = c
				else
					options.assign.custom_charges[self.setup.spell] = nil
				end
				self:UpdateFromData(self.setup,true)
			end,{text="Cooldown:",tip="Leave empty for reset to default value"},{text="Charges:",tip="Leave empty for reset to default value"})
			return
		elseif self.setup then
			if options.assign.var_draggedlastline then
				options.assign:AddNewReminderToLine(options.assign.var_draggedlastline,self.setup)
			end
		end
		if not self.data then return end
		if button == "RightButton" then
			options:RemoveReminder(self.data.uid)
		else
			options.assign:OpenQuickSetupFrame(self.timestamp, nil, nil, self.data)
		end
	end

	function options.assign:GetSpellBaseCD(spell)
		if not self.spellsBaseCDs then
			self.spellsBaseCDs = {}
		end
		if self.spellsBaseCDs[spell] then
			return self.spellsBaseCDs[spell]
		end

		local AllSpells = self:GetSpellsCDList()
		for i=1,#AllSpells do
			local line = AllSpells[i]
			if line[1] == spell then
				for j=4,8 do
					if line[j] then
						self.spellsBaseCDs[spell] = line[j][2]
						return line[j][2]
					end
				end
			end
		end
	end

	options.assign.Util_LineAssignOnEnter = function(self)
		if self.funcOnEnter then self.funcOnEnter(self) end
		local data = self.data

		self:SetAlpha(.7)

		local spell = (data and options.assign:GetSpell(data)) or (self.setup and self.setup.spell)
		if spell then
			local cd = self.setup and self.setup.cd or options.assign.custom_cd[spell] or options.assign:GetSpellBaseCD(spell)
			if cd then
				options.assign.frame:ShowCD(spell,cd,(data and data.players) or (self.setup and self.setup.players))
			end
		end

		if self.setup then
			if self.setup.cd then
				GameTooltip:SetOwner(self, "ANCHOR_LEFT")
				if self.setup.spell then
					GameTooltip:SetHyperlink("spell:"..self.setup.spell)
				end
				GameTooltip:AddLine("CD: "..module:FormatTime(self.setup.cd))
				if self.setup.spell and options.assign.custom_charges[self.setup.spell] then
					GameTooltip:AddLine("Charges: "..options.assign.custom_charges[self.setup.spell])					
				end
				GameTooltip:Show()
			end
		end

		if not data then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		local p,pc,pd
		local dt = module:ConvertMinuteStrToNum(data.triggers[1].delayTime)
		if data.triggers[1].event == 2 then
			p = data.triggers[1].pattFind
			pc = data.triggers[1].counter
			pd = dt and options.assign:GetTimeOnPhase(dt[1],p,pc)
		end
		if dt then
			GameTooltip:AddLine((p and "Phase "..p..(pc and " (#"..pc..")" or "")..": " or "")..module:FormatTime2(dt[1]))
		end
		local filter = ""
		for k,v in pairs(data.players) do 
			if UnitClass(k) then
				filter = filter .. "|c" .. RAID_CLASS_COLORS[select(2,UnitClass(k))].colorStr .. k .. " "
			else
				filter = filter .. k .. " " 
			end
		end
		for k,v in pairs(data) do 
			if type(k)=="string" and k:find("^role") then 
				local token = k:match("^role(.-)$")
				for i=1,#module.datas.rolesList do
					if tostring(module.datas.rolesList[i][1]) == token then
						filter = filter .. module.datas.rolesList[i][2] .. " "
					end
				end
			elseif type(k)=="string" and k:find("^class") then 
				local token = k:match("^class(.-)$")
				for i=1,#ExRT.GDB.ClassList do
					if ExRT.GDB.ClassList[i] == token then
						filter = filter..(RAID_CLASS_COLORS[token] and RAID_CLASS_COLORS[token].colorStr and "|c"..RAID_CLASS_COLORS[token].colorStr or "")..L.classLocalizate[token].."|r "
					end
				end
			end
		end
		if filter ~= "" then
			GameTooltip:AddLine("Filter: "..filter)
		end
		if pd then
			GameTooltip:AddLine("From start: "..module:FormatTime2(pd))
		end
		GameTooltip:AddLine(module:FormatMsg(data.msg or ""))
		GameTooltip:Show()
	end
	options.assign.Util_LineAssignOnLeave = function(self)
		if self.funcOnLeave then self.funcOnLeave(self) end
		GameTooltip_Hide()
		self:SetAlpha(1)

		options.assign.frame:ShowCD()
	end

	function options.assign:GetSpell(data)
		local spell = (data.msg or ""):match("^{spell:(%d+)}")
		if spell then
			return tonumber(spell)
		else
			return nil
		end
	end

	options.assign.IsKeyIsAnotherKey = function(t1,t2)
		if type(t1)~="table" or type(t2)~="table" then
			return false
		end
		for k in pairs(t1) do
			if t2[k] then
				return true
			end
		end
		return false
	end

	local hympOfHope_Spells = {
		[22812]=true,[198589]=true,[48792]=true,[204021]=true,[109304]=true,[55342]=true,
		[115203]=true,[19236]=true,[108271]=true,[104773]=true,[871]=true,[118038]=true,
		[184364]=true,[498]=true,[31850]=true,[185311]=true,[212800]=true,
		[403876]=true,[363916]=true,[243435]=true,[55233]=true,
	}

	options.assign.frame.hoveredNow = {}
	options.assign.frame.ShowCD = function(self,spell,length,names,cancelKey,doNotShowSelf)
		if not spell then
			if self.red.cancelKey and self.red.cancelKey ~= cancelKey then
				return
			end
			for i=1,#self.red do
				self.red[i]:Hide()
				self.red[i].h:Hide()
			end
			for i=1,#self.yellow do
				self.yellow[i]:Hide()
				self.yellow[i].h:Hide()
			end
			for k in pairs(self.hoveredNow) do
				k:HoverBorder(false)
			end
			self.red.cancelKey = nil
			return
		end
		if self.red.cancelKey then
			return
		end
		if names and ExRT.F.table_len(names) == 0 then
			names = nil
		end
		local filledRed = {}
		local yellowCheck = {}
		local chargesAv = {}
		local chargesCdD = {}
		local chargesMax = options.assign.custom_charges[spell] or 1
		local count = 0
		local linedata = options.assign.linedata
		for i=1,#linedata do
			local line = linedata[i]
			for j=1,#line.a do
				local a = line.a[j].frame
				if not line.isOff and a:IsShown() and a.data and options.assign:GetSpell(a.data) == spell and (not names or options.assign.IsKeyIsAnotherKey(names,a.data.players)) and ((not doNotShowSelf) or (doNotShowSelf ~= a)) then
					if not self.red then
						self.red = {}
					end
					count = count + 1
					local r = self.red[count]
					if not r then
						r = self.C:CreateTexture(nil,"BACKGROUND")

						self.red[count] = r

						r:SetColorTexture(1,.2,.2,.3)
						r:SetPoint("LEFT",self.headers,0,0)
						r:SetPoint("RIGHT",self,0,0)

						r.h = self.headers.C:CreateTexture(nil,"BACKGROUND")
						r.h:SetColorTexture(1,0,0,.2)
						r.h:SetPoint("LEFT",self.headers,0,0)
						r.h:SetPoint("RIGHT",self,0,0)
						r.h:SetPoint("TOP",r,0,0)
						r.h:SetPoint("BOTTOM",r,0,0)
					end

					r:SetPoint("TOP",0,-line.pos)

					local bottom
					local lengthNow = length
					if hympOfHope_Spells[spell] then
						for l=1,#line.a do
							local ba = line.a[l].frame
							if ba:IsShown() and ba.data and options.assign:GetSpell(ba.data) == 64901 then
								lengthNow = lengthNow - min(30,(a.timestamp + lengthNow) - ba.timestamp)
							end
						end
					end
					chargesAv[i] = (chargesAv[i] or chargesMax) - 1
					local cdStartTime = (chargesMax > 1 and chargesCdD[i]) or a.timestamp
					for k=i+1,#linedata do
						local bline = linedata[k]
						if hympOfHope_Spells[spell] and not bline.isOff then
							for l=1,#bline.a do
								local ba = bline.a[l].frame
								if ba:IsShown() and ba.data and options.assign:GetSpell(ba.data) == 64901 then
									lengthNow = lengthNow - min(30,(cdStartTime + lengthNow) - ba.timestamp)
								end
							end
						end
						if bline.time < cdStartTime + lengthNow and not bline.isOff then
							--bottom = bline

							--filledRed[bline] = true

							chargesCdD[k] = cdStartTime + lengthNow
							chargesAv[k] = (chargesAv[k] or chargesMax) - 1
							if (chargesAv[k] or chargesMax) <= 0 then
								bottom = bline
								filledRed[bline] = true
							end
						end
					end
					if (chargesAv[i] or chargesMax) <= 0 then
						filledRed[line] = true
					end

					if bottom then
						r:SetPoint("BOTTOM",self.C,"TOP",0,-bottom.pos-bottom.height)
					else
						r:SetPoint("BOTTOM",self.C,"TOP",0,-line.pos-line.height)
					end

					if (chargesAv[i] or chargesMax) == 0 then
						yellowCheck[#yellowCheck+1] = i
						yellowCheck[#yellowCheck+1] = a.timestamp
					end


					if (chargesAv[i] or chargesMax) <= 0 then
						r:Show()
						r.h:Show()
					else
						r:Hide()
						r.h:Hide()
					end

					a:HoverBorder(true)
					for k=j+1,#line.a do
						local a = line.a[k].frame
						if a:IsShown() and a.data and options.assign:GetSpell(a.data) == spell and (not names or options.assign.IsKeyIsAnotherKey(names,a.data.players)) and ((not doNotShowSelf) or (doNotShowSelf ~= a)) then
							a:HoverBorder(true)
						end
					end

					break
				end
			end
		end

		--[[
		for i=1,#linedata do
			local line = linedata[i]
			if line.line then
				line.line:DebugText(i.." filledRed:"..tostring(filledRed[line]).." charges:"..(chargesAv[i] or chargesMax).." cdd:"..(chargesCdD[i] or ""))
			end
		end
		]]

		local c_y = 0
		for i=1,#yellowCheck,2 do
			local line_i = yellowCheck[i]
			local line = linedata[line_i]
			local timestamp = yellowCheck[i+1]
			local isPass
			local lengthNow = length
			for k=line_i-1,1,-1 do
				local bline = linedata[k]
				if hympOfHope_Spells[spell] and not bline.isOff then
					for l=1,#bline.a do
						local ba = bline.a[l].frame
						if ba:IsShown() and ba.data and options.assign:GetSpell(ba.data) == 64901 then
							lengthNow = lengthNow - min(30,timestamp - ba.timestamp)
						end
					end
				end
				if chargesMax > 1 then
					for l=1,#bline.a do
						local ba = bline.a[l].frame
						if ba:IsShown() and ba.data and options.assign:GetSpell(ba.data) == spell then
							--lengthNow = lengthNow + length
							--timestamp = ba.timestamp
						end
					end
				end
				if (bline.time > timestamp - lengthNow) and not bline.isOff then
					if filledRed[bline] then
						--isPass = false
						break
					end
					isPass = bline
				elseif bline.time < timestamp - lengthNow then
					break
				end
			end
			if isPass then
				c_y = c_y + 1
				local r = self.yellow[c_y]
				if not r then
					r = self.C:CreateTexture(nil,"BACKGROUND")

					self.yellow[c_y] = r

					r:SetColorTexture(1,1,.2,.2)
					r:SetPoint("LEFT",self.headers,0,0)
					r:SetPoint("RIGHT",self,0,0)

					r.h = self.headers.C:CreateTexture(nil,"BACKGROUND")
					r.h:SetColorTexture(1,1,0,.2)
					r.h:SetPoint("LEFT",self.headers,0,0)
					r.h:SetPoint("RIGHT",self,0,0)
					r.h:SetPoint("TOP",r,0,0)
					r.h:SetPoint("BOTTOM",r,0,0)
				end

				r:SetPoint("BOTTOM",self.C,"TOP",0,-line.pos)
				r:SetPoint("TOP",0,-isPass.pos)

				r:Show()
				r.h:Show()
			end
		end

		self.red.cancelKey = cancelKey
	end

	function options.assign:Util_LineAssignAddPhantom(line)
		local phantom = self.frame.phantom_assign
		if not phantom then
			phantom = self:Util_CreateLineAssign(self.frame.C)
			phantom.text:SetText("")
			phantom.icon:SetTexture()
			phantom.bg:SetColorTexture(1,1,1,1)
			phantom.bg:SetGradient("HORIZONTAL",CreateColor(.6,.6,.6,1), CreateColor(.25,.25,.25,.7))

			self.frame.phantom_assign = phantom
		end

		local pos = #line.a

		phantom:ClearAllPoints()
		if pos == 0 then
			phantom:SetPoint("TOPLEFT", 1, -line.pos)
		else
			phantom:SetPoint("LEFT",line.a[pos].frame, "RIGHT", options.assign.TL_ASSIGNSPACING, 0)
		end
		phantom:Show()
	end
	function options.assign:Util_LineAssignRemoveSpace()
		if options.assign.line_space_last then
			options.assign.line_space_last:AddSpace(false,true)
		end
		if options.assign.frame.phantom_assign then
			options.assign.frame.phantom_assign:Hide()
		end
	end
	function options.assign:Util_LineAssignAddSpace(isAdd,secondCall)
		if options.assign.line_space_last ~= self then
			options.assign:Util_LineAssignRemoveSpace()
		end
		if isAdd then
			if self.spaceisadded then return end
			self:SetWidth( options.assign.TL_ASSIGNWIDTH + options.assign.TL_ASSIGNWIDTH + options.assign.TL_ASSIGNSPACING )
			self.bg:SetPoint("TOPLEFT",(options.assign.TL_ASSIGNWIDTH + options.assign.TL_ASSIGNSPACING),0)
			if not secondCall then
				options.assign.line_space_last = self
			end
			self.spaceisadded = true
		else
			if not self.spaceisadded then return end
			self:SetWidth( options.assign.TL_ASSIGNWIDTH )
			self.bg:SetPoint("TOPLEFT",0,0)
			self.spaceisadded = false
		end
	end
	function options.assign:Util_LineAssignHoverBorder(isHover)
		if isHover then
			options.assign.frame.hoveredNow[self] = true
			ELib:Border(self.bg,2,.7,.7,.7,1,nil,10)
		else
			options.assign.frame.hoveredNow[self] = nil
			ELib:Border(self.bg,0,nil,nil,nil,nil,nil,10)
		end
	end

	function options.assign:Util_CreateLineAssign(parent)
		local a = CreateFrame("Button",nil,parent or self.frame.D)

		a:SetSize(self.TL_ASSIGNWIDTH, self.TL_LINESIZE-2)

		a.bg = a:CreateTexture(nil,"BACKGROUND")
		a.bg:SetPoint("TOPLEFT",0,0)
		a.bg:SetPoint("BOTTOMRIGHT",0,0)
		--local color = ExRT.F.table_random(RAID_CLASS_COLORS)
		--a.bg:SetColorTexture(color.r,color.g,color.b)

		a.iconRight = a:CreateTexture(nil,"BACKGROUND",nil,2)
		a.iconRight:SetPoint("TOPRIGHT",0,0)
		a.iconRight:SetPoint("BOTTOMRIGHT",0,0)
		a.iconRight:SetWidth(self.TL_LINESIZE-2)

		a.icon = a:CreateTexture(nil, "ARTWORK")
		a.icon:SetSize(self.TL_LINESIZE-2,self.TL_LINESIZE-2)
		a.icon:SetPoint("LEFT",a.bg,0,0)
		a.icon:SetTexture(134399)

		a.text = ELib:Text(a,"Myname",8):Point("TOPLEFT",a.icon,"TOPRIGHT",2,-2):Point("BOTTOMRIGHT",a,-2,2):Color(0,0,0):Shadow(true)--:Outline(true)
		a.text:SetWordWrap(false)

		a.AddSpace = self.Util_LineAssignAddSpace

		a.UpdateFromData = self.Util_LineAssignUpdateFromData

		a:RegisterForClicks("LeftButtonUp","RightButtonUp")
		a:SetScript("OnClick",self.Util_LineAssignOnClick)
		a:SetScript("OnEnter",self.Util_LineAssignOnEnter)
		a:SetScript("OnLeave",self.Util_LineAssignOnLeave)

		a:SetMovable(true)
		a:RegisterForDrag("LeftButton")
		a:SetScript("OnDragStart", self.Util_AsignOnDragStart)
		a:SetScript("OnMouseDown", self.Util_AsignOnMouseDown)
		--a:SetScript("OnDragStop", self.Util_AsignOnDragStop)

		a._SetAlpha = a.SetAlpha
		a.HoverBorder = options.assign.Util_LineAssignHoverBorder

		return a
	end

	local assign_line_gragient_opts = {offset = 14}
	function options.assign:Util_LineAssignUpdateFromData(data,isSetup)
		local msg = data.msg or ""
		msg = msg:gsub("^{spell:%d+} *","")

		msg = module:FormatMsgForChat(module:FormatMsg(msg))

		local spell = data.msg and data.msg:match("^{spell:(%d+)}")
		self.icon:SetTexture()
		self.icon:SetWidth(2)

		if spell then
			spell = tonumber(spell)
			local texture = GetSpellTexture(spell)
			if texture then
				self.icon:SetTexture(texture)
				self.icon:SetWidth(options.assign.TL_LINESIZE-2)
			end
		end

		local color
		local multicolor
		for i=1,#ExRT.GDB.ClassList do
			local class = ExRT.GDB.ClassList[i]
			if data["class"..class] then
				if not multicolor and color then
					multicolor = {CreateColor(color.r,color.g,color.b,1)}
				end

				color = RAID_CLASS_COLORS[class]

				if multicolor and color then
					multicolor[#multicolor+1] = CreateColor(color.r,color.g,color.b,1)
				end
			end
		end

		if data.players and not isSetup then
			for k in pairs(data.players) do
				msg = k
	
				if UnitClass(k) then
					color = RAID_CLASS_COLORS[select(2,UnitClass(k))] or color
				end
			end
		end

		local roleicon
		for j=1,#module.datas.rolesList do
			if data["role"..j] and module.datas.rolesList[j][5] then
				local a = "|A:"..module.datas.rolesList[j][5]..":0:0:|a"
				if not roleicon or not roleicon:find(a,1,true) then
					roleicon = (roleicon or "")..a
				end
			end
		end
		if data.allPlayers then
			roleicon = nil
		end

		if multicolor then
			ELib:Gradient(self,assign_line_gragient_opts,unpack(multicolor))
			self.bg:SetColorTexture(1,1,1,0)
			self.text:Color(0,0,0)
			ELib:Border(self.bg,0)
		elseif color then
			self.bg:SetColorTexture(color.r,color.g,color.b)
			ELib:Border(self.bg,0)
			self.text:Color(0,0,0)
			ELib:Gradient(self)
		else
			self.bg:SetColorTexture(.1,.1,.1)
			ELib:Border(self.bg,1,.8,.8,.8,.8,-1)
			self.text:Color(1,1,1)
			ELib:Gradient(self)
		end

		local customCD
		if isSetup and spell and options.assign.custom_cd[spell] and options.assign.custom_cd[spell] == data.cd then
			customCD = module:FormatTime(options.assign.custom_cd[spell]).." "
		end

		self.text:SetText((roleicon or "")..(customCD or "")..msg)
	end

	options.assign.frame.assigns = {}
	local iconNotifAtlas = C_Texture.GetAtlasInfo("ShipMissionIcon-Bonus-MapBadge")
	function options.assign:Util_LineAddAssign(assign_num,data,line_data)
		local a
		for i=1,#self.frame.assigns do
			if not self.frame.assigns[i]:IsShown() then
				a = self.frame.assigns[i]
				break
			end
		end

		if not a then
			a = self:Util_CreateLineAssign()
			self.frame.assigns[#self.frame.assigns+1] = a
		end

		a.data = data
		a:UpdateFromData(data)
		a.timestamp = nil

		a._i = assign_num
		a.line = line_data

		if data and data.uid and self.OPTS_MARKSHARED and module:RemGetSource(data.uid) == 0 and not isLiveSession then
			a.iconRight:SetAtlas("ShipMissionIcon-Bonus-MapBadge")
			if iconNotifAtlas then
				a.iconRight:SetTexCoord(0,.75,0.125,0.875)
			end
			a.iconRight:Show()
		else
			a.iconRight:Hide()
		end

		line_data.a[assign_num].frame = a

		a:ClearAllPoints()
		if assign_num == 1 then
			a:SetPoint("TOPLEFT",1,-line_data.pos)
		else
			a:SetPoint("LEFT",line_data.a[assign_num - 1].frame,"RIGHT",self.TL_ASSIGNSPACING,0)
		end

		a:Show()

		return a
	end

	function options.assign:Util_AsignOnMouseDown()
		self.md_x, self.md_y = ExRT.F.GetCursorPos(self)
	end

	function options.assign:Util_AsignOnDragStart()
		if not self:IsMovable() then
			return
		end
		if options.assign.frame.dragging then
			return
		end
		if self.setup and self.setup.notMovable then
			return
		end
		if self.funcOnDrag then self.funcOnDrag(self) end
		local da = options.assign.frame.draggingAssign
		if not da then
			da = options.assign:Util_CreateLineAssign(options.assign.frame)
			options.assign.frame.draggingAssign = da
			da:SetScript("OnUpdate", options.assign.Util_AsignOnDragStop)
			da:SetParent(options)
			da:SetFrameLevel(9000)
		end
		da:ClearAllPoints()
		da:SetPoint(self:GetPoint())

		local x,y = ExRT.F.GetCursorPos(self)
		da:AdjustPointsOffset(x - self.md_x, -(y - self.md_y))

		da.data = self.data
		da.setup = self.setup
		da:UpdateFromData(self.data or self.setup)
		self:StopMovingOrSizing()

		self:_SetAlpha(0)
		self.SetAlpha = self.IsShown

		options.assign.frame.draggingNow = nil
		options.assign.frame.dragging = self
		options.assign.frame.draggingShowShift = nil

		options.assign.frame.draggingData = self.data
		options.assign.frame.draggingCopy = nil

		options.assign.frame.draggingX = x + (x - self.md_x)

		da:Show()
		da:StartMoving(true)

		options.assign.frame:ShowCD()
		local spell = (self.data and options.assign:GetSpell(self.data)) or (self.setup and self.setup.spell)
		if spell then
			local cd = self.setup and self.setup.cd or options.assign.custom_cd[spell] or options.assign:GetSpellBaseCD(spell)
			if cd then
				options.assign.frame:ShowCD(spell,cd,self.data and self.data.players or self.setup and self.setup.players,"DRAGGING",self)
			end
		end

		GameTooltip_Hide()
		C_Timer.After(.1,GameTooltip_Hide)
	end
	function options.assign:Util_AsignOnDragStop()
		local isCancel = IsMouseButtonDown("RightButton")
		if IsMouseButtonDown() and not isCancel then
			return
		end
		options.assign.frame.dragging:_SetAlpha(1)
		options.assign.frame.dragging.SetAlpha = options.assign.frame.dragging._SetAlpha
		options.assign.frame.dragging = nil

		self:StopMovingOrSizing()
		self:Hide()

		options.assign:Util_LineAssignRemoveSpace()
		options.assign.frame:ShowCD(nil,nil,nil,"DRAGGING")

		if options.assign.frame.draggingNow and not isCancel then
			options.assign:AddNewReminderToLine(options.assign.frame.draggingNow,self.setup,false,options.assign.frame.draggingData,IsShiftKeyDown())

			options.assign.var_draggedlastline = options.assign.frame.draggingNow
		end
	end

	function options.assign:AddNewReminderToLine(line,setup,window,existed,makeNew)
		local line_data = line

		local time = line_data.time

		local phase, x_phase, phaseCount, phaseNum = self:GetPhaseFromTime(time)
		--phaseNum is here for data array, actual num is +1
		if phase == 0 then
			phase, x_phase, phaseCount = nil
		end

		local data
		if existed then
			data = ExRT.F.table_copy2(existed)
		else
			data = ExRT.F.table_copy2(newRemainderTemplate)
		end
		data.uid = (not makeNew and data.uid) or options:GetNewUID()
		data.durrev = true

		if self.ZONE_ID then
			data.bossID = nil
			data.zoneID = self.ZONE_ID
		else
			data.bossID = self.BOSS_ID
			data.zoneID = nil
		end

		if not data.triggers[1] then
			data.triggers[1] = {}
		end
		data.triggers[1].event = self.ZONE_ID and 22 or 3

		if phase and phase > 0 and (phase ~= 1 or phaseCount) then
			data.triggers[1].event = 2
			data.triggers[1].pattFind = tostring(phase)
			if phaseCount then
				data.triggers[1].counter = tostring(phaseCount)
			else		
				data.triggers[1].counter = nil
			end

			time = x_phase
		elseif phase and phase < 0 and phase > -10000 then
			data.triggers[1].event = 3
			data.bossID = -phase
			data.zoneID = nil
			time = x_phase
		end

		if setup then
			data.msg = setup.msg or nil
			for k,v in pairs(setup) do
				if type(k)=='string' and (k:find("^class") or k:find("^role")) then
					data[k] = v
					data.allPlayers = nil
				end
			end
			if setup.players then
				for k,v in pairs(setup.players) do
					data.players[k] = v
					data.allPlayers = nil
				end
			end
			if setup.triggers and setup.triggers[2] then
				data.triggers[2] = setup.triggers[2]
			end
			data.hideTextChanged = setup.hideTextChanged
			if not self.OPTS_TTS then
				data.sound = "TTS"
				if self.OPTS_SOUNDDELAY and tonumber(self.OPTS_SOUNDDELAY) and self.OPTS_SOUNDDELAY > 0.1 then
					data.sounddelay = tostring(format("%.1f",self.OPTS_SOUNDDELAY))
				end
			end
			if self.OPTS_NOSPELLNAME and data.msg then
				if not self.OPTS_TTS then
					data.sound = "TTS:"..data.msg:match("^{spell:%d+} *(.-)$")
				end
				data.msg = data.msg:gsub("^({spell:%d+}).-$","%1")
			end
			if self.OPTS_DURDEF then
				data.dur = self.OPTS_DURDEF
			end
		end

		local t=floor(time*10)/10
		data.triggers[1].delayTime = format("%d:%02d.%d",t/60,t%60,(t*10)%10)

		if window then
			if IsShiftKeyDown() then
				options.setupFrame:Update(data)
				options.setupFrame:Show()
			else
				options.quickSetupFrame:Update(data)
				options.quickSetupFrame:Show()
			end
		else
			module:RemAdd(data.uid,data)
			options.assign:Update()
			module:ReloadAll()
		end
	end

	
	self.assign.frame.quick.pframes = {}
	self.assign.frame.quick.pframes_data = {}
	self.assign.frame.quick.COLS_NUM = 2
	self.assign.frame.quick.COLS_NOW = {}
	function options.assign:PlayerListReset()
		options.assign.frame.quick.lock = false
		for i=1,self.frame.quick.COLS_NUM do
			self.frame.quick.COLS_NOW[i] = 0
		end
		for i=1,#self.frame.quick.pframes do
			self.frame.quick.pframes[i]:Hide()
		end
		wipe(self.frame.quick.pframes_data)

		options.assign.frame.quick:Height(10)
		--options.assign.frame.quick:UpdateView()
	end

	function options.assign:IsPassQFilter(fliter_table,filterval)
		local isAny = false
		for k,v in pairs(fliter_table) do
			if v then
				isAny = true
				break
			end
		end
		if not isAny then
			return true
		elseif type(filterval) == "table" then
			for k in pairs(filterval) do
				if fliter_table[k] then
					return true
				end
			end
			return false
		elseif fliter_table[filterval] then
			return true
		else
			return false
		end
	end

	function options.assign.count_from_to(t,from,to)
		local c = 0
		for i=from,to do 
			if t[i] then
				c = c + 1
			end
		end  
		return c
	end

	function options.assign.do_search(where,what,exact)
		if type(what) == "table" then
			for i=1,#what do
				if (not exact and tostring(where or ""):lower():find(what[i],1,true)) or (exact and tostring(where or ""):lower() == what[i]) then
					return true
				end
			end
		else
			if (not exact and tostring(where or ""):lower():find(what,1,true)) or (exact and tostring(where or ""):lower() == what) then
				return true
			end
		end 
		return false
	end

	local ROLE_TO_ROLE = {
		RANGE = "DAMAGER",
		MELEE = "DAMAGER",
		TANK = "TANK",
		HEAL = "HEALER",

		RDD = "DAMAGER",
		MDD = "DAMAGER",
		RHEALER = "HEALER",
		MHEALER = "HEALER",

		DAMAGER = "DAMAGER",
		HEALER = "HEALER",
	}

	function options.assign.addCustomSpellWindow(class)
		local alertWindow = options.assign.customSpellWindow
		if not alertWindow then
			alertWindow = ExRT.lib:Popup():Size(500,90)
			options.assign.customSpellWindow = alertWindow
			alertWindow:SetFrameStrata("FULLSCREEN_DIALOG")

			alertWindow.header = ELib:Text(alertWindow,"Temporarily add custom spell",10):Point("TOP",0,-1):Center()

			alertWindow.SpellIDDD = ELib:DropDown(alertWindow,200,-1):Size(200):Point("TOPLEFT",90,-15-0*20)

			function alertWindow.SpellIDDD:PreUpdate()
				wipe(self.List)

				local classLocName,_,classID = UnitClass'player'

				local tabsToCollect = {[classLocName or 0]=true}
				self.List[#self.List+1] = {
					text = classLocName,
					subMenu = {},
				}

				if not GetNumSpecializationsForClassID or not GetSpecializationInfoForClassID or not C_SpellBook then
					return
				end
			  
				for spec=1,GetNumSpecializationsForClassID(classID) do
					local specName = select(2,GetSpecializationInfoForClassID(classID, spec))

					tabsToCollect[specName or 0] = true
					self.List[#self.List+1] = {
						text = specName,
						subMenu = {},
					}
				end

				local function SetValue(_,arg)
					ELib:DropDownClose()
					alertWindow.SpellID:SetText(arg)
					local cd = GetSpellBaseCooldown(arg)
					alertWindow.CD:SetText(cd/1000)
				end
					
				for tab=1,C_SpellBook.GetNumSpellBookSkillLines() do
					local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(tab)
					
					local tabName = skillLineInfo.name
					local offset = skillLineInfo.itemIndexOffset
					local numSlots = skillLineInfo.numSpellBookItems

					if tabName and tabsToCollect[tabName] then
						local subMenu = ExRT.F.table_find3(self.List,tabName,"text")
						if subMenu then
							subMenu = subMenu.subMenu
							for i=offset+1,offset+numSlots do
								local spellData = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Player)
								local spellID = spellData.spellID
								local isPassive = spellData.isPassive
								
								if spellID and not isPassive then
									subMenu[#subMenu+1] = {
										icon = spellData.iconID,
										text = spellData.name,
										arg1 = spellID,
										func = SetValue,
										tooltip = "spell:"..spellID
									}
								end
							end
						end
					end
				end
			end

			alertWindow.SpellID = ELib:Edit(alertWindow):Size(100,20):Point("LEFT",alertWindow.SpellIDDD,"RIGHT",70,0):LeftText("or Spell ID:"):OnChange(function(self) 
				local text = self:GetText() 
				text = tonumber(text or 0) or 0
				local spellName = GetSpellName(text)
				local spellTexture = GetSpellTexture(text)
				alertWindow.SpellIDDD:SetText("|T"..(spellTexture or "134400")..":0|t"..(spellName or ""))
				alertWindow.SpellID.t:SetText("|T"..(spellTexture or "134400")..":0|t"..(spellName or ""))
				alertWindow.SPELL_ID = text
			end)
			alertWindow.SpellID.t = ELib:Text(alertWindow.SpellID,"",12):Point("LEFT",alertWindow.SpellID,"RIGHT",5,0):Color():Left()
			alertWindow.CD = ELib:Edit(alertWindow):Size(200,20):Point("TOPLEFT",alertWindow.SpellIDDD,"BOTTOMLEFT",0,-5):LeftText("CD:"):OnChange(function(self)
				local text = self:GetText() 
				text = tonumber(text or 0)
				alertWindow.SPELL_CD = text
			end)
			
			alertWindow.OK = ExRT.lib:Button(alertWindow,ACCEPT):Size(130,20):Point("BOTTOM",0,3):OnClick(function (self)
				alertWindow:Hide()

				if alertWindow.SPELL_ID and alertWindow.SPELL_ID ~= 0 then
					options.assign.custom_spells[alertWindow.SPELL_ID] = alertWindow.CLASS
					options.assign.custom_cd[alertWindow.SPELL_ID] = alertWindow.SPELL_CD

					local new = {alertWindow.SPELL_ID,alertWindow.CLASS,3,{alertWindow.SPELL_ID,alertWindow.SPELL_CD,0}}
					tinsert(options.assign.spellsCDListClass[alertWindow.CLASS],new)
					tinsert(options.assign.spellsCDList,new)

					options.assign:PlayerListUpdate()
				end
			end)
		end

		if class == select(2,UnitClass'player') then
			alertWindow.SpellIDDD:Show()
			alertWindow.SpellID:Point("LEFT",alertWindow.SpellIDDD,"RIGHT",70,0):LeftText("or Spell ID:"):Size(100,20)
			alertWindow.SpellID.t:Hide()
		else
			alertWindow.SpellIDDD:Hide()
			alertWindow.SpellID:Point("LEFT",alertWindow.SpellIDDD,"LEFT",0,0):LeftText("Spell ID:"):Size(200,20)
			alertWindow.SpellID.t:Show()
		end

		alertWindow.header:SetText("Temporarily add custom spell"..(ExRT.GDB.ClassID[class or 0] and " for "..L.classLocalizate[class] or ""))

		alertWindow.SpellID:SetText("")
		alertWindow.SpellIDDD:SetText("")
		alertWindow.CD:SetText("")
		alertWindow.CLASS = class
		alertWindow.SPELL_ID = nil
		alertWindow.SPELL_CD = nil

		alertWindow:Show()
	end


	function options.assign:PlayerListAdd(name,class,spec,role)
		local new = {}

		local search = self.frame.quick.search

		local passSearch = false

		new.name = name or class and L.classLocalizate[class]
		if search then
			spec,role = nil
		end
		if search and options.assign.do_search(new.name,search) then
			passSearch = true
		end

		local list = {}
		if 
			(not class or options.assign:IsPassQFilter(self.QFILTER_CLASS,class)) and 
			(not role or options.assign:IsPassQFilter(self.QFILTER_ROLE,role))
		then
			local AllSpells = self:GetSpellsCDListClass(class)
	
			for i=1,#AllSpells do
				local line = AllSpells[i]
				for j=4,8 do
					local spell_role
					if j > 4 and ExRT.GDB.ClassSpecializationList[class] then
						spell_role = ROLE_TO_ROLE[ ExRT.GDB.ClassSpecializationRole[ ExRT.GDB.ClassSpecializationList[class][j-4] or 0 ] or 0 ]
					elseif ExRT.GDB.ClassSpecializationList[class] then
						local l = ExRT.GDB.ClassSpecializationList[class]
						spell_role = {}
						for k=1,#l do
							local r = ROLE_TO_ROLE[ ExRT.GDB.ClassSpecializationRole[ l[k] ] or 0 ]
							if r then spell_role[r] = true end
						end
					end

					local spell_filter
					if VMRT.Reminder2.SpellGroups then
						for i=1,#VMRT.Reminder2.SpellGroups.names do
							if VMRT.Reminder2.SpellGroups[i][ line[1] ] then
								spell_filter = spell_filter or {}
								spell_filter[i] = true
							end
						end
					end
					if not spell_filter then
						spell_filter = -1
					end

					if 
						line[j] and
						(name or (not spell_role or options.assign:IsPassQFilter(self.QFILTER_ROLE,spell_role))) and
						(not name or j == 4 or not role or spell_role == role) and
						options.assign:IsPassQFilter(self.QFILTER_SPELL,spell_filter)
					then
						local spellName = GetSpellName(line[1])
						if spellName and (not search or passSearch or (spellName and options.assign.do_search(spellName,search)) or options.assign.do_search(line[1],search,true)) then
							local setup = {
								msg = "{spell:"..line[1].."} "..(spellName or name),
								spell = line[1],
								cd = options.assign.custom_cd[ line[1] ] or line[j][2],
							}
							if name then
								setup.players = {[name] = true}
							end
							if class and not line[2]:find("^ALL") then
								setup["class"..class] = true
							end
							if j > 4 and spell_role and options.assign.count_from_to(line,4,8) > 1 then
								local roles = 0
								for j=1,#module.datas.rolesList do
									if module.datas.rolesList[j][3] == spell_role then setup["role"..j] = true end
								end
							end
							if not name and options.assign.custom_cd[ line[1] ] then
								setup.cd = options.assign.custom_cd[ line[1] ]
							end
							setup.triggers = {}
							setup.triggers[2] = {
								event = 13,
								spellID = line[1],
								invert = true,
							}
							setup.hideTextChanged = true

							list[#list+1] = {setup,line[1],spellName or tostring(line[1] or 0)}
						end
					end
				end
			end
		end
		if #list == 0 then
			return
		end

		sort(list,function(a,b) if a[3]~=b[3] then return a[3]<b[3] else return a[2]<b[2] end end)

		if class and not search and options.assign:IsPassQFilter(self.QFILTER_SPELL,-1) then 
			list[#list+1] = {{funcOnClick=self.addCustomSpellWindow,funcOnClickArg = class,msg = "+custom",notMovable=true},0,"+custom"} 
		end

		new.list = list

		local c = #list

		new.height = 20 + (self.TL_LINESIZE-2 + 2)*c + 5

		local col = 1
		for i=1,self.frame.quick.COLS_NUM do 
			if self.frame.quick.COLS_NOW[i] < self.frame.quick.COLS_NOW[col] then
				col = i
			end
		end

		new.pos = self.frame.quick.COLS_NOW[col]
		new.col = col

		if c > 0 then
			self.frame.quick.COLS_NOW[col] = self.frame.quick.COLS_NOW[col] + new.height + 5
		end

		local height = 0
		for i=1,self.frame.quick.COLS_NUM do
			height = max(height,self.frame.quick.COLS_NOW[i])
		end

		self.frame.quick:Height(height)
		self.frame.quick.ScrollBar:SetShown(height > self.frame.quick:GetHeight())

		if c > 0 then
			self.frame.quick.pframes_data[#self.frame.quick.pframes_data+1] = new
		end
		self.frame.quick:UpdateView()
	end

	function options.assign.frame.quick:OnUpdate()
	  	local x,y = ExRT.F.GetCursorPos(self)

		if self.saved_x and self.saved_y then
			if self.ScrollBarHorizontal and self.ScrollBarHorizontal:IsShown() and abs(x - self.saved_x) > 5 then
				local newVal = self.saved_scroll - (x - self.saved_x)
				local min,max = self.ScrollBarHorizontal:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.ScrollBarHorizontal:SetValue(newVal)

				self.moveSpotted = true
			end
			if self.ScrollBar:IsShown() and abs(y - self.saved_y) > 5 then
				local newVal = self.saved_scroll_v - (y - self.saved_y)
				local min,max = self.ScrollBar:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.ScrollBar:SetValue(newVal)

				self.moveSpotted = true
			end
		end
	end

	options.assign.frame.quick:SetScript("OnMouseDown",function(self)
		local x,y = ExRT.F.GetCursorPos(self)
		self.saved_x = x
		self.saved_y = y
		self.saved_scroll = self.ScrollBarHorizontal and self.ScrollBarHorizontal:GetValue()
		self.saved_scroll_v = self.ScrollBar:GetValue()
		self.moveSpotted = nil

		self:SetScript("OnUpdate",self.OnUpdate)
	end)

	options.assign.frame.quick:SetScript("OnMouseUp",function(self, button)
		self.saved_x = nil
		self.saved_y = nil

		if self.moveSpotted then
			self.moveSpotted = nil
			self:SetScript("OnUpdate",nil)
			return
		end
	end)

	options.assign.frame.quick.CDFrame = CreateFrame("Frame",nil,options.assign.frame.quick)
	options.assign.frame.quick.CDFrame:SetSize(90,32)
	options.assign.frame.quick.CDFrame:Hide()
	options.assign.frame.quick.CDFrame:SetFrameLevel(1000)
	options.assign.frame.quick.CDFrame:EnableMouse(true)
	options.assign.frame.quick.CDFrame:SetScript("OnUpdate",function(self)
		if not self.parent or not self.parent:IsVisible() then
			self:Hide()
		end
		local x,y = ExRT.F.GetCursorPos(self)
		local xp,yp = ExRT.F.GetCursorPos(self.parent)
		if (xp < -5 or xp > self.parent:GetWidth() + 5 or yp < -5 or yp > self.parent:GetHeight() + 5) and (x < -10 or x > self:GetWidth() + 10 or y < -10 or y > self:GetHeight() + 10) then
			self:Hide()
		elseif options.assign.frame.quick.ScrollBar.thumb:IsMouseOver() and (x < 0 or x > self:GetWidth() or y < 0 or y > self:GetHeight()) then
			self:Hide()
		end
	end)
	options.assign.frame.quick.CDFrame.bg = options.assign.frame.quick.CDFrame:CreateTexture(nil,"BACKGROUND")
	options.assign.frame.quick.CDFrame.bg:SetAllPoints()
	options.assign.frame.quick.CDFrame.bg:SetColorTexture(0,0,0,1)
	ELib:Border(options.assign.frame.quick.CDFrame,1,.24,.25,.30,1)

	options.assign.frame.quick.CDFrame.icon = options.assign.frame.quick.CDFrame:CreateTexture(nil,"ARTWORK")
	options.assign.frame.quick.CDFrame.icon:SetPoint("TOPLEFT",2,-2)
	options.assign.frame.quick.CDFrame.icon:SetSize(14,14)

	options.assign.frame.quick.CDFrame.CD = ELib:Edit(options.assign.frame.quick.CDFrame):Size(40,16):Point("TOPLEFT",50,0):LeftText("CD:",9):FontSize(9):Tooltip("Used only for visual red/yellow lines. Leave empty for reset to default"):OnChange(function(self,isUser)
		if not isUser then return end
		local t = self:GetText() or ""
		t = module:ConvertMinuteStrToNum(t)
		t = t and t[1]
		local parent = self:GetParent().parent
		local setup = parent.setup
		setup.cd = t or options.assign:GetSpellBaseCD(setup.spell)
		options.assign.custom_cd[ setup.spell ] = t
		parent:UpdateFromData(setup, true)
		for i=1,#options.assign.frame.quick.pframes_data do
			local data = options.assign.frame.quick.pframes_data[i]
			for i=1,#data.list do
				local setup2 = data.list[i][1]

				if setup2.spell == setup.spell then
					setup2.cd = setup.cd
				end
			end
		end
		for i=1,#options.assign.frame.quick.pframes do
			local line = options.assign.frame.quick.pframes[i]
			local c = 0
			for j=1,#line.btn do
				local a = line.btn[j]
				if a.setup and a.setup.spell == setup.spell then
					a:UpdateFromData(a.setup, true)
				end
			end
		end
	end)

	options.assign.frame.quick.CDFrame.Charges = ELib:Edit(options.assign.frame.quick.CDFrame):Size(40,16):Point("TOPLEFT",50,-16):LeftText("Charges:",9):FontSize(9):Tooltip("Used only for visual red/yellow lines. Leave empty for reset to default"):OnChange(function(self,isUser)
		if not isUser then return end
		local t = self:GetText() or ""
		t = tonumber(t)
		local setup = self:GetParent().parent.setup
		options.assign.custom_charges[setup.spell] = t
	end)

	function options.assign:Util_AssignSetupOnEnter()
	  	if not self.setup then
			return
		end
		local spell = self.setup.spell
		if not spell then
			return
		end
		if IsMouseButtonDown() then
			return
		end
		options.assign.frame.quick.CDFrame.parent = self
		options.assign.frame.quick.CDFrame:SetPoint("TOPLEFT",self,"BOTTOMRIGHT",0,5)
		local texture = GetSpellTexture(spell)
		options.assign.frame.quick.CDFrame.icon:SetTexture(texture)
		options.assign.frame.quick.CDFrame.CD:SetText( module:FormatTime(self.setup.cd) )
		options.assign.frame.quick.CDFrame.Charges:SetText( tostring(options.assign.custom_charges[spell] or 1) )
		options.assign.frame.quick.CDFrame.CD:ClearFocus()
		options.assign.frame.quick.CDFrame.Charges:ClearFocus()
		options.assign.frame.quick.CDFrame:Show()
	end
	function options.assign:Util_AssignSetupOnDrag()
		options.assign.frame.quick.CDFrame:Hide()
	end

	function options.assign.frame.quick:UpdateView(forceUnderLock)
		if self.lock and not forceUnderLock then return end
		local pos = self:GetVerticalScroll()

		local c = 0
		for i=1,#self.pframes_data do
			local data = self.pframes_data[i]
			if data.pos + data.height >= pos and data.pos <= pos+self:GetHeight() then
				c = c + 1

				local a = self.pframes[c]
		
				if not a then
					a = CreateFrame("Frame",nil,self.C)
					self.pframes[c] = a

					a:SetSize(options.assign.TL_ASSIGNWIDTH + 10, 80)
					a.btn = {}
			
					a.name = ELib:Text(a,"",12):Point("TOP",0,-2):Color()
		
					a._i = pos
				end

				a.name:SetText(data.name)

				local cb = 0
				for i=1,#data.list do
					cb = cb + 1
					local b = a.btn[cb] 
					if not b then
						b = options.assign:Util_CreateLineAssign(a)

						b.funcOnEnter = options.assign.Util_AssignSetupOnEnter
						b.funcOnLeave = options.assign.Util_AssignSetupOnLeave
						b.funcOnDrag = options.assign.Util_AssignSetupOnDrag

						a.btn[cb] = b
		
					end
					b:SetPoint("TOP",0,-20-(cb-1)*(options.assign.TL_LINESIZE-2 + 2))

					b.setup = data.list[i][1]
		
					b:UpdateFromData(b.setup, true)
					b:Show()
				end
				for j=cb+1,#a.btn do
					a.btn[j]:Hide()
				end

				a:SetHeight(data.height)

				a:ClearAllPoints()
				a:SetPoint("TOPLEFT",(data.col - 1) * (options.assign.TL_ASSIGNWIDTH + 10 + 5),-data.pos)

				a:Show()
			end
		end
		for i=c+1,#self.pframes do
			self.pframes[i]:Hide()
		end
	end

	options.assign.frame.quick:SetScript("OnVerticalScroll", function(self)
		self:UpdateView()
	end)


	function options.assign:PlayerListUpdateFromRoster()
		self:PlayerListReset()
		self.frame.quick.lock = true
		for _, name, subgroup, class, guid, rank, level, online, isDead, combatRole in ExRT.F.IterateRoster, ExRT.F.GetRaidDiffMaxGroup() do
			name = ExRT.F.delUnitNameServer(name)

			if combatRole == "NONE" then 
				combatRole = nil 
				if name == ExRT.SDB.charName and GetSpecializationInfo and GetSpecialization then
					combatRole = select(5,GetSpecializationInfo(GetSpecialization()))
				end
			end

			self:PlayerListAdd(name,class,nil,combatRole)
		end
		self.frame.quick.lock = false
		self.frame.quick:UpdateView()
	end

	function options.assign:PlayerListUpdateFromGuild()
		self:PlayerListReset()
		local guildList = {}
		for i=1, GetNumGuildMembers() do
			local name, _, rankIndex, level, _, _, _, _, _, _, class = GetGuildRosterInfo(i)

			name = ExRT.F.delUnitNameServer(name)

			guildList[#guildList+1] = {name,class,rankIndex}
		end
		sort(guildList,function(a,b)
			if a[3] == b[3] then
				return a[1] < b[1]
			else
				return a[3] < b[3]
			end
		end)

		if #guildList > 500 then
			local uid = debugprofilestop()
			self.coroutine_uid = uid
			ExRT.F:AddCoroutine(function()
				self.frame.quick.lock = true
				for i=1, #guildList do
					self:PlayerListAdd(guildList[i][1],guildList[i][2],nil,nil)
					if i % 100 == 0 then
						self.frame.quick:UpdateView(true)
					end
					if i % 50 == 0 then
						options.assign.frame.quick.dd:SetText(format("%d/%d",i,#guildList))
						coroutine.yield()
						if self.coroutine_uid ~= uid then
							return
						end
					end
				end
				self.frame.quick.lock = false
				self.frame.quick:UpdateView()

				options.assign.frame.quick.dd:AutoText(options.assign.frame.quick.last)
			end)
		else
			self.frame.quick.lock = true
			for i=1, #guildList do
				self:PlayerListAdd(guildList[i][1],guildList[i][2],nil,nil)
			end
			self.frame.quick.lock = false
			self.frame.quick:UpdateView()
		end
	end

	function options.assign:PlayerListUpdateAllClasses()
		self:PlayerListReset()
		self.frame.quick.lock = true
		for i=1,#ExRT.GDB.ClassList do
			self:PlayerListAdd(nil,ExRT.GDB.ClassList[i],nil,nil)
		end
		self.frame.quick.lock = false
		self.frame.quick:UpdateView()
	end

	function options.assign:PlayerListUpdateFromSavedRoster()
		self:PlayerListReset()
		self.frame.quick.lock = true
		for i=1,#VMRT.Reminder2.CustomRoster do
			local name, class, role = unpack(VMRT.Reminder2.CustomRoster[i])

			if name and class then 
				if role then role = ROLE_TO_ROLE[role] end

				self:PlayerListAdd(name,class,nil,role)
			end

		end
		self.frame.quick.lock = false
		self.frame.quick:UpdateView()
	end

	options.assign.frame.quick.last = VMRT.Reminder2.OptAssigLastQuick
	function options.assign:PlayerListUpdate()
		if self.frame.quick.last == 1 or not self.frame.quick.last then
			self:PlayerListUpdateFromRoster()
		elseif self.frame.quick.last == 3 then
			self:PlayerListUpdateFromGuild()
		elseif self.frame.quick.last == 4 then
			self:PlayerListUpdateFromSavedRoster()
		else
			self:PlayerListUpdateAllClasses()
		end
	end
	function options.assign:PlayerListUpdateOnShow()
		if self.frame.quick.last == 1 or not self.frame.quick.last then
			self:PlayerListUpdateFromRoster()
		end
	end
	--options.assign:PlayerListUpdate()

 
	options.assign.frame.quick.filter = CreateFrame("Frame",nil,self.tab.tabs[5])
	options.assign.frame.quick.filter:SetPoint("TOPLEFT",options.assign.frame,"TOPRIGHT",0,-10)
	options.assign.frame.quick.filter:SetSize(options.assign.frame.quick:GetWidth(),options.assign.frame.QUICK_HEIGHT)

	function options.assign:UpdateQFilter()
		for _,t in pairs({{self.QFILTER_CLASS,self.frame.quick.filter.class},{self.QFILTER_ROLE,self.frame.quick.filter.role},{self.QFILTER_SPELL,self.frame.quick.filter.filterbutton}}) do
			local fliter_table = t[1]
			local isAny = false
			for k,v in pairs(fliter_table) do
				if v then
					isAny = true
					break
				end
			end
	
			for _,b in pairs(t[2]) do
				if not isAny or fliter_table[b.filter] then
					b:UpdateState(true)
				else
					b:UpdateState(false)
				end
			end
		end

		options.assign:PlayerListUpdate()
		if not options.assign.FILTER_SPELLS and options.assign.Update then
			options.assign:Update()
		end
	end

	function options.assign:Util_QuickFilterButtonOnClick(button)
		local fliter_table = options.assign["QFILTER_"..self.fheader]
		if button == "RightButton" then
			for k,v in pairs(fliter_table) do fliter_table[k] = nil end
			fliter_table[self.filter] = true
		else
			fliter_table[self.filter] = not fliter_table[self.filter]
		end
		
		options.assign:UpdateQFilter()
	end
	function options.assign:Util_QuickFilterButtonOnEnter()
		self:SetAlpha(.7)
	end
	function options.assign:Util_QuickFilterButtonOnLeave()
		self:SetAlpha(1)
	end

	function options.assign:Util_QuickFilterButtonUpdateState(isOn)
		if isOn then
			self.icon:SetAlpha(1)
			self.icon:SetVertexColor(1,1,1)
		else
			self.icon:SetAlpha(.3)
			self.icon:SetVertexColor(1,.5,.5)
		end
	end
	function options.assign:Util_QuickFilterButtonUpdateStateCheck(isOn)
		if isOn then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end

	options.assign.frame.quick.filter.class = {}
	options.assign.frame.quick.filter.role = {}
	options.assign.frame.quick.filter.filterbutton = {}

	for i=1,#ExRT.GDB.ClassList do
		local b = CreateFrame("Button",nil,options.assign.frame.quick.filter)
		options.assign.frame.quick.filter.class[i] = b
		b:SetSize(26,26)
		b:SetPoint("TOPLEFT",2+((i-1)%8)*28,-(floor((i-1)/8)*28))
		
		b.icon = b:CreateTexture(nil,"BACKGROUND")
		b.icon:SetPoint("CENTER")
		b.icon:SetSize(26,26)
		b.icon:SetAtlas("classicon-"..ExRT.GDB.ClassList[i]:lower())

		b.fheader = "CLASS"
		b.filter = ExRT.GDB.ClassList[i]

		b:RegisterForClicks("LeftButtonUp","RightButtonUp")
		b:SetScript("OnClick",options.assign.Util_QuickFilterButtonOnClick)
		b:SetScript("OnEnter",options.assign.Util_QuickFilterButtonOnEnter)
		b:SetScript("OnLeave",options.assign.Util_QuickFilterButtonOnLeave)

		b.UpdateState = options.assign.Util_QuickFilterButtonUpdateState
	end
	for i,role in pairs({{"DAMAGER",ExRT.isClassic and "UI-LFG-RoleIcon-DPS" or "UI-Frame-DpsIcon"},{"HEALER",ExRT.isClassic and "UI-LFG-RoleIcon-Healer" or "UI-Frame-HealerIcon"},{"TANK",ExRT.isClassic and "UI-LFG-RoleIcon-Tank" or "UI-Frame-TankIcon"}}) do
		local b = CreateFrame("Button",nil,options.assign.frame.quick.filter)
		options.assign.frame.quick.filter.role[i] = b
		b:SetSize(26,26)
		local j = #ExRT.GDB.ClassList + i
		b:SetPoint("TOPLEFT",2+((j-1)%8)*28,-(floor((j-1)/8)*28))
		
		b.icon = b:CreateTexture(nil,"ARTWORK")
		b.icon:SetPoint("CENTER")
		b.icon:SetSize(26,26)
		b.icon:SetAtlas(role[2])

		b.fheader = "ROLE"
		b.filter = role[1]

		b:RegisterForClicks("LeftButtonUp","RightButtonUp")
		b:SetScript("OnClick",options.assign.Util_QuickFilterButtonOnClick)
		b:SetScript("OnEnter",options.assign.Util_QuickFilterButtonOnEnter)
		b:SetScript("OnLeave",options.assign.Util_QuickFilterButtonOnLeave)

		b.UpdateState = options.assign.Util_QuickFilterButtonUpdateState
	end


	options.assign.frame.quick.filter.editgroupsbut = ELib:ButtonIcon(options.assign.frame.quick.filter,ExRT.isClassic and "charactercreate-icon-customize-speechbubble" or "GM-icon-settings-hover",true):Size(20,20):IconSize(2):Point("TOPRIGHT",-5,-55):OnClick(function() options.assign.frame.quick.edit:Show() end):Tooltip("Edit spell groups"):VisualHover()


	options.assign.frame.quick.filter.searchEditBox = ELib:Edit(options.assign.frame.quick.filter):Point("BOTTOM",options.assign.frame.quick,"TOP",0,2):Size(200,16):AddSearchIcon():OnChange(function (self,isUser)
		if not isUser then
			return
		end
		local text = self:GetText():lower()
		if text == "" then
			text = nil
		else
			if text:find(",") then
				text = {strsplit(",",text)}
				for i=#text,1,-1 do
					if text[i] == "" then
						tremove(text,i)
					end
				end
				if #text == 0 then
					text = nil
				end
			end
		end
		options.assign.frame.quick.search = text

		if self.scheduledUpdate then
			return
		end
		self.scheduledUpdate = C_Timer.NewTimer(.3,function()
			self.scheduledUpdate = nil
			options.assign:PlayerListUpdate()
		end)
	end):Tooltip(SEARCH)

	function options.assign.frame.quick.filter:Update()
		if not VMRT.Reminder2.SpellGroups then
			VMRT.Reminder2.SpellGroups = ExRT.F.table_copy2(options.assign.SpellGroups_Presetup)
		end
		if not VMRT.Reminder2.CustomRoster then
			VMRT.Reminder2.CustomRoster = {}
		end

		local names_len = #VMRT.Reminder2.SpellGroups.names
		for i=1,names_len+1 do
			local b = options.assign.frame.quick.filter.filterbutton[i]
			if not b then
				b = ELib:Check(options.assign.frame.quick.filter,"",true):Size(10,10):TextButton()
				options.assign.frame.quick.filter.filterbutton[i] = b
				if i%2 == 1 then
					b:SetPoint("TOPLEFT",5,-(floor((i-1)/2)*14)-56-3)
				else
					b:SetPoint("TOPLEFT",options.assign.frame.quick.filter,"TOP",5,-(floor((i-1)/2)*14)-56-3)
				end
		
				b.UpdateState = options.assign.Util_QuickFilterButtonUpdateStateCheck
										
				b.fheader = "SPELL"
				b.filter = i
		
				b:RegisterForClicks("LeftButtonUp","RightButtonUp")
				b:SetScript("OnClick",options.assign.Util_QuickFilterButtonOnClick)
			end

			if i <= names_len then
				b:SetText(VMRT.Reminder2.SpellGroups.names[i])
				b.filter = i
			else
				b:SetText(L.cd2CatOther)
				b.filter = -1
			end
			b:Show()
		end

		local height = 14 * ceil((names_len+1) / 2)

		for i=names_len+2,#options.assign.frame.quick.filter.filterbutton do
			options.assign.frame.quick.filter.filterbutton[i]:Hide()
		end

		options.assign.frame.quick:Size(options.assign.frame.quick:GetWidth(),520-(options.assign.frame.QUICK_HEIGHT+height)):Point("TOPLEFT",options.assign.frame,"TOPRIGHT",0,-(options.assign.frame.QUICK_HEIGHT+height))

		options.assign:UpdateQFilter()
	end
	options.assign.frame.quick.filter:Update()

	options.assign.frame.quick.dd = ELib:DropDown(options.assign.frame.quick,250,-1):Point("BOTTOM",options.assign.frame.quick.filter,"TOP",0,5):Size(220):SetText("Select roster"):OnShow(function() options.assign:PlayerListUpdateOnShow() end,true)
	function options.assign.frame.quick.dd:SetValue(arg1)
		ELib:DropDownClose()
		options.assign.frame.quick.last = arg1
		VMRT.Reminder2.OptAssigLastQuick = arg1
		options.assign.frame.quick.dd:AutoText(arg1)
		options.assign:PlayerListUpdate()
	end
	function options.assign.frame.quick.dd:SetValue2(arg1)
		ELib:DropDownClose()
		options.assign.frame.quick.rosteredit:Show()
	end
	options.assign.frame.quick.dd.List = {
		{
			text = "Current roster",
			arg1 = 1,
			func = options.assign.frame.quick.dd.SetValue,
		},
		{
			text = "Guild",
			arg1 = 3,
			func = options.assign.frame.quick.dd.SetValue,
		},
		{
			text = "All classes",
			arg1 = 2,
			func = options.assign.frame.quick.dd.SetValue,
		},
		{
			text = "Custom roster",
			arg1 = 4,
			func = options.assign.frame.quick.dd.SetValue,
			subMenu = {
				{
					text = "Edit",
					func = options.assign.frame.quick.dd.SetValue2,
				}
			},
		}
	}

	options.assign.frame.quick.rosteredit = ELib:Popup("Edit custom roster"):Size(600,600):OnShow(function(self) self:Update() end,true)
	ELib:Border(options.assign.frame.quick.rosteredit,1,.4,.4,.4,.9)

	options.assign.frame.quick.rosteredit.frame = ELib:ScrollFrame(options.assign.frame.quick.rosteredit):Size(600,585):Height(585):AddHorizontal(true):Width(600):Point("TOP",0,-15)
	ELib:Border(options.assign.frame.quick.rosteredit.frame,0)
	options.assign.frame.quick.rosteredit.frame.lines = {}

	options.assign.frame.quick.rosteredit.groupsedit = {}


	options.assign.frame.quick.rosteredit:SetScript("OnHide",function()
		options.assign.frame.quick.filter:Update()
	end)

	options.assign.frame.quick.rosteredit.frame:SetScript("OnMouseDown",function(self)
		local x,y = ExRT.F.GetCursorPos(self)
		self.saved_x = x
		self.saved_y = y
		self.saved_scroll_h = self.ScrollBarHorizontal:GetValue()
		self.saved_scroll_v = self.ScrollBar:GetValue()
		self.moveSpotted = nil

	end)

	options.assign.frame.quick.rosteredit.frame:SetScript("OnMouseUp",function(self, button)
		self.saved_x = nil
		self.saved_y = nil
		self.moveSpotted = nil
	end)


	options.assign.frame.quick.rosteredit.ExportButton = ELib:Button(options.assign.frame.quick.rosteredit.frame.C,L.Export):Point("TOPLEFT",600-250,-0):Size(200,20):OnClick(function()
		local str = ""
		for i=1,#VMRT.Reminder2.CustomRoster do
			if VMRT.Reminder2.CustomRoster[i][1] then
				str = str .. VMRT.Reminder2.CustomRoster[i][1]  .."\t".. (VMRT.Reminder2.CustomRoster[i][2] or "").."\t" ..(VMRT.Reminder2.CustomRoster[i][3] or "").. "\n" 
			end
		end
		ExRT.F:Export2(str)
	end)

	options.assign.frame.quick.rosteredit.importWindow = ELib:Popup(" "):Size(600,400)
	ELib:Border(options.assign.frame.quick.rosteredit.importWindow,1,.4,.4,.4,.9)

	function options.assign.frame.quick.rosteredit.importWindow:DoImport(isErase)
		local text = options.assign.frame.quick.rosteredit.importWindow.Edit:GetText()
	  	if isErase then
			wipe(VMRT.Reminder2.CustomRoster)
		end

		local lines = {strsplit("\n",text)}
		for i=1,#lines do
			local l = {}
			for k in lines[i]:gmatch("[^\n\t ]+") do
				l[#l+1] = k
			end
			local name,class,role = unpack(l)

			if name and name:trim() == ""  then name = nil end

			if name then
				if class and class:trim() == ""  then class = nil end
				if role and role:trim() == ""  then role = nil end

				if class then
					local mclass
					for i=1,#ExRT.GDB.ClassList do
						if ExRT.GDB.ClassList[i]:lower() == class:lower() or (GetClassInfo(ExRT.GDB.ClassID[ ExRT.GDB.ClassList[i] ]) or "") == class:lower() then
							mclass = ExRT.GDB.ClassList[i]
							break
						end
					end
					class = mclass
				end

				if role then
					local mrole
					for i=1,#module.datas.rolesList do
						if module.datas.rolesList[i][3]:lower() == role:lower() or module.datas.rolesList[i][2]:lower() == role:lower() then
							mrole = module.datas.rolesList[i][3]
							break
						end
					end
					role = mrole
				end

				VMRT.Reminder2.CustomRoster[#VMRT.Reminder2.CustomRoster+1] = {
					name,
					class,
					role,
				}
			end
		end
		options.assign.frame.quick.rosteredit.importWindow:Hide()
		options.assign.frame.quick.rosteredit:Update()
	end

	options.assign.frame.quick.rosteredit.importWindow.Tip = ELib:Text(options.assign.frame.quick.rosteredit.importWindow,"1 line - 1 player, format: |cff00ff00name   class   role|r",12):Point("TOPLEFT",10,-5)
	options.assign.frame.quick.rosteredit.importWindow.Edit = ELib:MultiEdit(options.assign.frame.quick.rosteredit.importWindow):Point("TOP",0,-25):Size(590,400-50-30)
	options.assign.frame.quick.rosteredit.importWindow.Import = ELib:Button(options.assign.frame.quick.rosteredit.importWindow,"Add"):Point("BOTTOM",0,5):Size(590,20):OnClick(function()
		options.assign.frame.quick.rosteredit.importWindow:DoImport(false)
	end)
	options.assign.frame.quick.rosteredit.importWindow.Import2 = ELib:Button(options.assign.frame.quick.rosteredit.importWindow,"Add (rewrite current roster)"):Point("BOTTOM",options.assign.frame.quick.rosteredit.importWindow.Import,"TOP",0,5):Size(590,20):OnClick(function()
		options.assign.frame.quick.rosteredit.importWindow:DoImport(true)
	end)

	options.assign.frame.quick.rosteredit.ImportButton = ELib:Button(options.assign.frame.quick.rosteredit.frame.C,L.Import):Point("TOP",options.assign.frame.quick.rosteredit.ExportButton,"BOTTOM",0,-5):Size(200,20):OnClick(function()
		options.assign.frame.quick.rosteredit.importWindow:NewPoint("CENTER",UIParent,0,0)
		options.assign.frame.quick.rosteredit.importWindow.Edit:SetText("")
		options.assign.frame.quick.rosteredit.importWindow:Show()
	end)

	options.assign.frame.quick.rosteredit.CurrRoster = ELib:Button(options.assign.frame.quick.rosteredit.frame.C,"Add from current raid/group"):Point("RIGHT",options.assign.frame.quick.rosteredit.ExportButton,"LEFT",-5,0):Size(200,20):OnClick(function()
		for _, name, subgroup, class, guid, rank, level, online, isDead, combatRole in ExRT.F.IterateRoster, ExRT.F.GetRaidDiffMaxGroup() do
			name = ExRT.F.delUnitNameServer(name)

			if combatRole == "NONE" then combatRole = nil end

			VMRT.Reminder2.CustomRoster[#VMRT.Reminder2.CustomRoster+1] = {
				name,
				class,
				combatRole,
			}
		end
		options.assign.frame.quick.rosteredit:Update()
	end)

	options.assign.frame.quick.rosteredit.ClearList = ELib:Button(options.assign.frame.quick.rosteredit.frame.C,"Clear list"):Point("TOP",options.assign.frame.quick.rosteredit.CurrRoster,"BOTTOM",0,-5):Size(200,20):OnClick(function()
		StaticPopupDialogs["EXRT_REMINDER_RESET"] = {
			text = "Clear list?",
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				wipe(VMRT.Reminder2.CustomRoster)
				options.assign.frame.quick.rosteredit:Update()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_REMINDER_RESET")
	end)

	options.assign.frame.quick.rosteredit.addButton = ELib:Button(options.assign.frame.quick.rosteredit.frame.C,"Add"):Size(100,20):OnClick(function(self)
		local pos = #VMRT.Reminder2.CustomRoster+1
		VMRT.Reminder2.CustomRoster[pos] = {self.gtext}

		self:Hide()
		options.assign.frame.quick.rosteredit:Update()
	end)

	function options.assign.frame.quick.rosteredit:removeButton_click()
		local i = self:GetParent().data_i
		tremove(VMRT.Reminder2.CustomRoster, i)

		options.assign.frame.quick.rosteredit:Update()
	end

	function options.assign.frame.quick.rosteredit:class_click(class)
		ELib:DropDownClose()

		local data = self:GetParent().parent:GetParent().data
		data[2] = class

		options.assign.frame.quick.rosteredit:Update()
	end
	options.assign.frame.quick.rosteredit.ClassDD_List = {
		{
			text = "-",
			func = options.assign.frame.quick.rosteredit.class_click,
		},
	}
	for i=1,#ExRT.GDB.ClassList do
		local class = ExRT.GDB.ClassList[i]
		options.assign.frame.quick.rosteredit.ClassDD_List[#options.assign.frame.quick.rosteredit.ClassDD_List+1] = {
			text = (RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr or "")..L.classLocalizate[class],
			func = options.assign.frame.quick.rosteredit.class_click,
			arg1 = class,
		}
	end

	function options.assign.frame.quick.rosteredit:role_click(role)
		ELib:DropDownClose()

		local data = self:GetParent().parent:GetParent().data
		data[3] = role

		options.assign.frame.quick.rosteredit:Update()
	end
	options.assign.frame.quick.rosteredit.RoleDD_List = {
		{
			text = "-",
			func = options.assign.frame.quick.rosteredit.role_click,
		},
	}
	for i=1,#module.datas.rolesList do
		local roledata = module.datas.rolesList[i]
		options.assign.frame.quick.rosteredit.RoleDD_List[#options.assign.frame.quick.rosteredit.RoleDD_List+1] = {
			text = roledata[2],
			func = options.assign.frame.quick.rosteredit.role_click,
			arg1 = roledata[3],
			atlas = roledata[5],
		}
	end

	function options.assign.frame.quick.rosteredit:UpdateView()
		local pos = self.frame:GetVerticalScroll()

		local spellsList = self.pList

		local c = 0
		for i=1,#spellsList do
			local data = spellsList[i]
			if data.pos + 25 >= pos and data.pos <= pos+self.frame:GetHeight() then
				c = c + 1

				local line = self.frame.lines[c]
				if not line then
					line = CreateFrame("Frame",nil,self.frame.C)
					self.frame.lines[c] = line
					line:SetSize(500,24)

					line.edit = ELib:Edit(line):Size(200,20):Point("LEFT",5,0):OnChange(function(self,isUser)
						local text = self:GetText() or ""
						options.assign.frame.quick.rosteredit.addButton:NewPoint("LEFT",self,"RIGHT",5,0):SetShown(text:trim() ~= "" and not self:GetParent().data) 
						if not isUser then return end
						local data = self:GetParent().data
						if data then
							data[1] = text
						else
							options.assign.frame.quick.rosteredit.addButton.gtext = text
						end
					end)
	
					line.remove = ELib:Button(line,""):Size(12,20):Point("LEFT",line.edit,"RIGHT",3,0):OnClick(self.removeButton_click)
					ELib:Text(line.remove,"x"):Point("CENTER",0,0)
					line.remove.Texture:SetGradient("VERTICAL",CreateColor(0.35,0.06,0.09,1), CreateColor(0.50,0.21,0.25,1))
					line.remove._i = i

					line.bg = line:CreateTexture(nil,"BACKGROUND")
					line.bg:SetAllPoints()
	
					line.class = ELib:DropDown(line,220,-1):Size(150):Point("LEFT",line.edit,"RIGHT",25,0)
					line.class.List = options.assign.frame.quick.rosteredit.ClassDD_List

					line.role = ELib:DropDown(line,220,-1):Size(150):Point("LEFT",line.class,"RIGHT",10,0)
					line.role.List = options.assign.frame.quick.rosteredit.RoleDD_List
				end

				if data.data then 
					line.edit:SetScript("OnEditFocusGained",self.editgname_OnEditFocusGained) 
					line.edit:SetScript("OnEditFocusLost",self.editgname_OnEditFocusLost) 

					line.remove:Show()
					line.class:Show()
					line.role:Show()
				else
					line.edit:SetScript("OnEditFocusGained",nil) 
					line.edit:SetScript("OnEditFocusLost",nil) 

					line.remove:Hide()
					line.class:Hide()
					line.role:Hide()
				end
		
				line.data = data.data
				line:SetPoint("TOPLEFT",10,-data.pos)
				line.edit:SetText(data.data and data.data[1] or "")
				line.class:AutoText(data.data and data.data[2])
				line.role:AutoText(data.data and data.data[3])
				line.data_i = data._i

				local classColor = data.data and data.data[2] and RAID_CLASS_COLORS[ data.data[2] ]
				line.bg:SetColorTexture(1,1,1,1)
				if classColor then
					line.bg:SetGradient("HORIZONTAL",CreateColor(classColor.r,classColor.g,classColor.b, .5), CreateColor(classColor.r,classColor.g,classColor.b, 0))
				else
					line.bg:SetGradient("HORIZONTAL",CreateColor(1,1,1, 0), CreateColor(1,1,1, 0))
				end

				line:SetWidth(max(200,self:GetWidth()))		

				line:Show()
			end
		end
		for i=c+1,#self.frame.lines do
			self.frame.lines[i]:Hide()
		end
	end

	function options.assign.frame.quick.rosteredit:editgname_OnEditFocusGained()
		self.prefocustext = self:GetText()
	end
	function options.assign.frame.quick.rosteredit:editgname_OnEditFocusLost()
		if self.prefocustext ~= self:GetText() then 
			options.assign.frame.quick.rosteredit:Update() 
		end
	end

	function options.assign.frame.quick.rosteredit:Update()
		local names_len = #VMRT.Reminder2.CustomRoster

		self.pList = {}
		for i=1,names_len do
			self.pList[#self.pList + 1] = {
				data = VMRT.Reminder2.CustomRoster[i],
				_i = i,
			}
		end
		self.pList[#self.pList + 1] = {}

		for i=1,#self.pList do
			self.pList[i].pos = 50 + 25 * (i-1)
		end

		local maxheight = 50 + #self.pList * 25 + 15
		local maxwidth = max(200, self:GetWidth())

		self.frame:Height(maxheight)
		self.frame:Width(maxwidth)

		self:UpdateView()
	end

	options.assign.frame.quick.rosteredit.frame:SetScript("OnVerticalScroll", function(self)
		self:GetParent():UpdateView()
	end)






	

	options.assign.frame.quick.edit = ELib:Popup("Edit spells groups"):Size(900,600):OnShow(function(self) self:Update() end,true)
	ELib:Border(options.assign.frame.quick.edit,1,.4,.4,.4,.9)

	options.assign.frame.quick.edit.frame = ELib:ScrollFrame(options.assign.frame.quick.edit):Size(900,585):Height(585):AddHorizontal(true):Width(600):Point("TOP",0,-15)
	ELib:Border(options.assign.frame.quick.edit.frame,0)
	options.assign.frame.quick.edit.frame.lines = {}

	options.assign.frame.quick.edit.groupsedit = {}

	options.assign.frame.quick.edit:SetScript("OnHide",function()
		wipe(options.assign.QFILTER_SPELL)
		options.assign.frame.quick.edit:Update()
		options.assign.frame.quick.filter:Update()
	end)

	options.assign.frame.quick.edit.frame:SetScript("OnMouseDown",function(self)
		local x,y = ExRT.F.GetCursorPos(self)
		self.saved_x = x
		self.saved_y = y
		self.saved_scroll_h = self.ScrollBarHorizontal:GetValue()
		self.saved_scroll_v = self.ScrollBar:GetValue()
		self.moveSpotted = nil

	end)

	options.assign.frame.quick.edit.frame:SetScript("OnMouseUp",function(self, button)
		self.saved_x = nil
		self.saved_y = nil
		self.moveSpotted = nil
	end)

	options.assign.frame.quick.edit.frame:SetScript("OnUpdate",function(self)
		local x,y = ExRT.F.GetCursorPos(self)

		if self.saved_x and self.saved_y then
			if self.ScrollBarHorizontal:IsShown() and abs(x - self.saved_x) > 5 then
				local newVal = self.saved_scroll_h - (x - self.saved_x)
				local min,max = self.ScrollBarHorizontal:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.ScrollBarHorizontal:SetValue(newVal)

				self.moveSpotted = true
			end
			if self.ScrollBar:IsShown() and abs(y - self.saved_y) > 5 then
				local newVal = self.saved_scroll_v - (y - self.saved_y)
				local min,max = self.ScrollBar:GetMinMaxValues()
				if newVal < min then newVal = min end
				if newVal > max then newVal = max end
				self.ScrollBar:SetValue(newVal)

				self.moveSpotted = true
			end
		end

		local isAnyHL = false
		if self:IsMouseOver() and not self.moveSpotted then
			for i=1,#self.lines do
				if self.lines[i]:IsMouseOver() and self.lines[i]:IsShown() then
					if self.lines[i] ~= self.prevHL then
						if self.prevHL then
							self.prevHL.bg:SetColorTexture(1,1,1,1)
						end
						self.prevHL = self.lines[i]
						self.prevHL.bg:SetColorTexture(1,1,1,.4)
					end
					isAnyHL = true
					break
				end
			end
		end

		if not isAnyHL and self.prevHL then
			self.prevHL.bg:SetColorTexture(1,1,1,1)
			self.prevHL = nil
		end
	end)

	options.assign.frame.quick.edit.importWindow, options.assign.frame.quick.edit.exportWindow = ExRT.F.CreateImportExportWindows()
	options.assign.frame.quick.edit.importWindow:SetFrameStrata("FULLSCREEN")
	options.assign.frame.quick.edit.exportWindow:SetFrameStrata("FULLSCREEN")

	function options.assign.frame.quick.edit.importWindow:ImportFunc(str)
		local headerSize = str:sub(1,4) == "EXRT" and 9 or 8
		local header = str:sub(1,headerSize)
		if not (header:sub(1,headerSize-1) == "MRTREMS" or header:sub(1,headerSize-1) == "EXRTREMS") or (header:sub(headerSize,headerSize) ~= "0" and header:sub(headerSize,headerSize) ~= "1") then
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

		self:TextToData(str:sub(headerSize+1),header:sub(headerSize,headerSize)=="0",header:sub(headerSize,headerSize)=="2")
	end

	function options.assign.frame.quick.edit.importWindow:TextToData(str,uncompressed,undecoded)
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

		local successful, res = pcall(ExRT.F.TextToTable,decompressed)
		decompressed = nil
		if successful and res then
			local checks = true

			if type(res.names) ~= "table" or #res.names == 0 then
				checks = false
			end

			if checks then
				for i=1,#res.names do
					if type(res[i]) ~= "table" then res[i] = {} end
				end
				VMRT.Reminder2.SpellGroups = res

				options.assign.frame.quick.edit:Update()
				options.assign.frame.quick.filter:Update()
			else
				print("Import error: wrong data")
			end
		else
			print("Import error")
		end
	end


	function options.assign.frame.quick.edit:ExportStr(export)
		options.assign.frame.quick.edit.exportWindow:NewPoint("CENTER",UIParent,0,0)

		local compressed
		if #export < 1000000 then
			compressed = LibDeflate:CompressDeflate(export.."##F##",{level = 5})
		end
		local encoded = "MRTREMS"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or export)

		ExRT.F.dprint("Str len:",#export,"Encoded len:",#encoded)

		if IsShiftKeyDown() and IsControlKeyDown() then
			--encoded = "EXRTREMD".."2"..export
		end
		options.assign.frame.quick.edit.exportWindow.Edit:SetText(encoded)
		options.assign.frame.quick.edit.exportWindow:Show()
	end

	options.assign.frame.quick.edit.ExportButton = ELib:Button(options.assign.frame.quick.edit.frame.C,L.Export):Point("TOPLEFT",900-300,-5):Size(250,20):OnClick(function()
		local strlist = ExRT.F.TableToText(VMRT.Reminder2.SpellGroups)
		local str = table.concat(strlist)

		options.assign.frame.quick.edit:ExportStr(str)
	end)

	options.assign.frame.quick.edit.ImportButton = ELib:Button(options.assign.frame.quick.edit.frame.C,L.Import):Point("TOP",options.assign.frame.quick.edit.ExportButton,"BOTTOM",0,-5):Size(250,20):OnClick(function()
		options.assign.frame.quick.edit.importWindow:NewPoint("CENTER",UIParent,0,0)
		options.assign.frame.quick.edit.importWindow:Show()
	end)

	options.assign.frame.quick.edit.ResetButton = ELib:Button(options.assign.frame.quick.edit.frame.C,"Reset to default"):Point("TOP",options.assign.frame.quick.edit.ImportButton,"BOTTOM",0,-5):Size(250,20):OnClick(function()
		StaticPopupDialogs["EXRT_REMINDER_RESET"] = {
			text = "Current spell settings will be lost. Reset to default preset?",
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				VMRT.Reminder2.SpellGroups = ExRT.F.table_copy2(options.assign.SpellGroups_Presetup)
		
				options.assign.frame.quick.edit:Update()
				options.assign.frame.quick.filter:Update()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_REMINDER_RESET")
	end)

	options.assign.frame.quick.edit.addButton = ELib:Button(options.assign.frame.quick.edit.frame.C,"Add"):Size(100,20):OnClick(function(self)
		local pos = #VMRT.Reminder2.SpellGroups.names+1
		VMRT.Reminder2.SpellGroups.names[pos] = self.gtext
		VMRT.Reminder2.SpellGroups[pos] = {}

		self:Hide()
		options.assign.frame.quick.edit:Update()
	end)

	function options.assign.frame.quick.edit:removeButton_click()
		tremove(VMRT.Reminder2.SpellGroups.names, self._i)
		tremove(VMRT.Reminder2.SpellGroups, self._i)

		options.assign.frame.quick.edit:Update()
	end

	function options.assign.frame.quick.edit:line_onenter()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetHyperlink("spell:"..self.spell )
		GameTooltip:Show()
	end
	function options.assign.frame.quick.edit:line_onleave()
		GameTooltip_Hide()
	end

	function options.assign.frame.quick.edit:UpdateView()
		local pos = self.frame:GetVerticalScroll()

		local spellsList = self.spellsList
		local groups = VMRT.Reminder2.SpellGroups.names
		local spellsData = VMRT.Reminder2.SpellGroups

		local c = 0
		for i=1,#spellsList do
			local data = spellsList[i]
			if data.pos + 25 >= pos and data.pos <= pos+self.frame:GetHeight() then
				c = c + 1

				local line = self.frame.lines[c]
				if not line then
					line = CreateFrame("Frame",nil,self.frame.C)
					self.frame.lines[c] = line
					line:SetSize(500,24)

					line.gbuttons = {}

					line.bg = line:CreateTexture(nil,"BACKGROUND")
					line.bg:SetAllPoints()
		
					line.icon = line:CreateTexture()
					line.icon:SetPoint("LEFT",0,0)
					line.icon:SetSize(20,20)
		
					line.name = ELib:Text(line,"Spell Name",12):Point("LEFT",line.icon,"RIGHT",2,0):Left():Color()

					line:SetScript("OnEnter",self.line_onenter)
					line:SetScript("OnLeave",self.line_onleave)

					if line.SetPropagateMouseClicks then	--not working on classic client rn
						line:SetPropagateMouseClicks(true)
					end
				end	
		
				line:SetPoint("TOPLEFT",10,-data.pos)
				local name,_,texture = GetSpellInfo(data.spell)
				line.name:SetText(name or "spell"..data.spell)
				line.icon:SetTexture(texture)
				line.data = data

				local classColor = data.class and RAID_CLASS_COLORS[data.class]
				line.bg:SetColorTexture(1,1,1,1)
				if classColor then
					line.bg:SetGradient("HORIZONTAL",CreateColor(classColor.r,classColor.g,classColor.b, .5), CreateColor(classColor.r,classColor.g,classColor.b, 0))
				else
					line.bg:SetGradient("HORIZONTAL",CreateColor(1,1,1, 0), CreateColor(1,1,1, 0))
				end


				local isAnyGroup = false
				for j=1,#groups do
					local gbutton = line.gbuttons[j]
					if not gbutton then
						gbutton = CreateFrame("Button",nil,line)
						line.gbuttons[j] = gbutton
						gbutton:SetSize(80,24)
						gbutton:SetPoint("LEFT",(j-1)*85+200,0)
						
						gbutton.bg = gbutton:CreateTexture(nil,"BACKGROUND")
						gbutton.bg:SetAllPoints()
				
						gbutton.text = ELib:Text(gbutton,"",10):Point("CENTER"):Color()

						gbutton:RegisterForClicks("LeftButtonUp","RightButtonUp")
						gbutton:SetScript("OnClick",options.assign.frame.quick.edit.gbutton_click)
						gbutton.g = j

						if gbutton.SetPropagateMouseClicks then	--not working on classic client rn
							gbutton:SetPropagateMouseClicks(true)
						end
					end
					gbutton.text:SetText(groups[j])
					if spellsData[j][data.spell] then
						gbutton.bg:SetColorTexture(.2,.7,.2,1)
						isAnyGroup = true
					else
						gbutton.bg:SetColorTexture(.7,.2,.2,1)
					end

					gbutton:Show()
				end
				for j=#groups+1,#line.gbuttons do
					line.gbuttons[j]:Hide()
				end

				if isAnyGroup then
					line.name:Color(1,1,1,1)
				else
					line.name:Color(1,.8,.8,1)
				end

				line:SetWidth(max(200 + 85*#groups,self:GetWidth()))		

				line.spell = data.spell
				line:Show()
			end
		end
		for i=c+1,#self.frame.lines do
			self.frame.lines[i]:Hide()
		end
	end

	function options.assign.frame.quick.edit:editgname_OnEditFocusGained()
		self.prefocustext = self:GetText()
	end
	function options.assign.frame.quick.edit:editgname_OnEditFocusLost()
		if self.prefocustext ~= self:GetText() then 
			options.assign.frame.quick.edit:Update() 
		end
	end
	

	function options.assign.frame.quick.edit:Update()
		local names_len = #VMRT.Reminder2.SpellGroups.names
		for i=1,names_len+1 do
			local edit = self.groupsedit[i]
			if not edit then
				edit = ELib:Edit(self.frame.C):Size(270,20):Point("TOPLEFT",100,-5-25*(i-1)):LeftText("Group #"..i..":"):OnChange(function(self,isUser)
					local text = self:GetText() or ""
					if VMRT.Reminder2.SpellGroups.names[i] then 
						if not isUser then return end
						VMRT.Reminder2.SpellGroups.names[i] = text 
					else
						options.assign.frame.quick.edit.addButton:NewPoint("LEFT",self,"RIGHT",5,0):SetShown(text:trim() ~= "") 
						if not isUser then return end
						options.assign.frame.quick.edit.addButton.gtext = text
					end
				end)
				self.groupsedit[i] = edit

				edit.remove = ELib:Button(edit,""):Size(12,20):Point("LEFT",edit,"RIGHT",3,0):OnClick(self.removeButton_click)
				ELib:Text(edit.remove,"x"):Point("CENTER",0,0)
				edit.remove.Texture:SetGradient("VERTICAL",CreateColor(0.35,0.06,0.09,1), CreateColor(0.50,0.21,0.25,1))
				edit.remove._i = i
			end

			if i <= names_len then 
				edit:SetScript("OnEditFocusGained",self.editgname_OnEditFocusGained) 
				edit:SetScript("OnEditFocusLost",self.editgname_OnEditFocusLost) 
			else
				edit:SetScript("OnEditFocusGained",nil) 
				edit:SetScript("OnEditFocusLost",nil) 
			end

			edit:SetText(VMRT.Reminder2.SpellGroups.names[i] or "")
			edit:Show()

			edit.remove:SetShown(i <= names_len)
		end
		for i=names_len+2,#self.groupsedit do
			self.groupsedit[i]:Hide()
		end


		self.spellsList = {}
		local AllSpells = options.assign:GetSpellsCDList()
		local classprio = {}
		local classprio_c = 0
		for i=1,#AllSpells do
			local data = AllSpells[i]

			local class = strsplit(",",data[2])
			if not classprio[class] then
				classprio_c = classprio_c + 1
				classprio[class] = classprio_c
			end
			if ExRT.GDB.ClassID[class or 0] then

				self.spellsList[#self.spellsList + 1] = {
					spell = data[1],
					pos = (names_len + 1)*25 + 5 + 25 + 25 * #self.spellsList,
					class = class,
					spellName = GetSpellName(data[1]) or tostring(data[1] or 0),
					classprio = classprio[class],
				}
			end
		end

		sort(self.spellsList,function(a,b) if a.classprio ~= b.classprio then return a.classprio < b.classprio else return a.spellName < b.spellName end end)
		for i=1,#self.spellsList do
			self.spellsList[i].pos = (names_len + 1)*25 + 5 + 25 + 25 * (i-1)
		end

		local maxheight = (names_len + 1) * 25 + 5 + 25 + #self.spellsList * 25
		local maxwidth = max(200 + 85 * names_len + 15, self:GetWidth())

		self.frame:Height(maxheight)
		self.frame:Width(maxwidth)

		self:UpdateView()
	end

	function options.assign.frame.quick.edit:gbutton_click()
		local spell = self:GetParent().spell
		local data_table = VMRT.Reminder2.SpellGroups[self.g]

		if data_table[spell] then
			data_table[spell] = nil
			self.bg:SetColorTexture(.7,.2,.2)
		else
			data_table[spell] = true
			self.bg:SetColorTexture(.2,.7,.2)			
		end

		local groups = VMRT.Reminder2.SpellGroups.names
		local spellsData = VMRT.Reminder2.SpellGroups

		local parent = self:GetParent()
		local isAnyGroup = false
		for j=1,#groups do
			if spellsData[j][parent.spell] then
				isAnyGroup = true
				break
			end
		end

		if isAnyGroup then
			parent.name:Color(1,1,1,1)
		else
			parent.name:Color(1,.7,.7,1)
		end
	end

	options.assign.frame.quick.edit.frame:SetScript("OnVerticalScroll", function(self)
		self:GetParent():UpdateView()
	end)


	function options.assign:Util_DebugLine(text)
		if not self.debugtext then
			self.debugtext = ELib:Text(self,"",10):Point("LEFT",250,0):Left():Color()
		end
		self.debugtext:SetText(text)
	end

	function options.assign:UpdateView()
		local pos = self.frame:GetVerticalScroll()

		local line_c = 0
		for j=1,#self.linedata do
			local spell_data = self.linedata[j]
			if spell_data.pos + spell_data.height >= pos and spell_data.pos <= pos+self.frame:GetHeight() then
				if line_c == 0 then
					if self.frame.prevVPos == j then
						return
					end
					self.frame.prevVPos = j
				end
				local spell = spell_data.id
				local isOff = spell_data.isOff
				line_c = line_c + 1
				local line = self.frame.lines[line_c]
				if not line then
					line = CreateFrame("Button",nil,self.frame.C)
					self.frame.lines[line_c] = line
					line:SetPoint("TOPLEFT",0,-self.TL_LINESIZE*(line_c-1))
					line:SetSize(1000,self.TL_LINESIZE)
					--line:SetScript("OnClick",self.Util_LineOnClick)
					if line.SetPropagateMouseClicks then	--not working on classic client rn
						line:SetScript("OnEnter",self.Util_LineOnEnter)
						line:SetScript("OnLeave",self.Util_LineOnLeave)
						line:SetPropagateMouseClicks(true)
					end
					line.DebugText = self.Util_DebugLine

					line.assigns = {}

					line._i = line_c
		
					line.header = CreateFrame("Button",nil,self.frame.headers.C)
					line.header:SetPoint("TOPLEFT",0,-self.TL_LINESIZE*(line_c-1))
					line.header:SetSize(self.frame.headers:GetWidth(),self.TL_LINESIZE)
					line.header:RegisterForClicks("LeftButtonUp","RightButtonUp")
					line.header:SetScript("OnClick",self.Util_HeaderOnClick)
					line.header:SetScript("OnEnter",self.Util_HeaderOnEnter)
					line.header:SetScript("OnLeave",self.Util_HeaderOnLeave)
	
					line.header.time = ELib:Text(line.header,"Spell Name",10):Point("LEFT",5,0):Size(35,0):Left():Color(unpack(self.TL_HEADER_COLOR_ON))

					line.header.trigger = CreateFrame("Button",nil,line.header)
					line.header.trigger:SetSize(self.TL_LINESIZE-2, self.TL_LINESIZE-2)
					line.header.trigger:SetPoint("LEFT",line.header.time,"RIGHT",3,0)
			
					line.header.trigger.bg = line.header.trigger:CreateTexture(nil,"BACKGROUND")
					line.header.trigger.bg:SetPoint("TOPLEFT",0,0)
					line.header.trigger.bg:SetPoint("BOTTOMRIGHT",0,0)
					line.header.trigger.bg:SetColorTexture(.8,.33,1,.5)
			
					line.header.trigger.text = ELib:Text(line.header.trigger,"T",10):Point("CENTER",line.header.trigger):Color(1,1,1):Outline(true):Shadow(true)
					line.header.trigger.text2 = ELib:Text(line.header.trigger,"",10):Point("LEFT",line.header.trigger,"RIGHT",2,0):Left():Color(unpack(self.TL_HEADER_COLOR_ON))

					line.header.icon = line.header:CreateTexture()
					line.header.icon:SetPoint("LEFT",line.header.trigger,"RIGHT",40,0)
					line.header.icon:SetSize(self.TL_LINESIZE,self.TL_LINESIZE)

					line.header.name = ELib:Text(line.header,"Spell Name",10):Point("LEFT",line.header.icon,"RIGHT",3,0):Left():Color(unpack(self.TL_HEADER_COLOR_ON))

					if line_c%2 == 1 then
						line.bg = line:CreateTexture(nil,"BACKGROUND")
						line.bg:SetAllPoints()
						line.bg:SetColorTexture(1,1,1,.005)

						line.header.bg = line.header:CreateTexture(nil,"BACKGROUND")
						line.header.bg:SetAllPoints()
						line.header.bg:SetColorTexture(1,1,1,.03)
					end
	
				end

				line:SetPoint("TOPLEFT",0,-spell_data.pos)
				line.header:SetPoint("TOPLEFT",0,-spell_data.pos)
				line:SetWidth(max(self.frame.width_now,self.frame:GetWidth()))

				line.header.name:SetText(spell_data.line_name or "")
				line.header.icon:SetTexture(spell_data.line_icon)
				line.header.time:SetText(spell_data.line_time or "")
				line.header.trigger:SetShown(spell_data.line_trigger and true or false)
				line.header.tiptime = spell_data.line_tiptime

				line.header.trigger.text:SetText(spell_data.line_trigger_text or "")
				line.header.trigger.text2:SetText(spell_data.line_trigger_text2 or "")

				if isOff then
					line.header.isOff = true
					line.header.name:SetTextColor(unpack(self.TL_HEADER_COLOR_OFF))
					line:Hide()

				else
					line.header.isOff = false
					line.header.name:SetTextColor(unpack(self.TL_HEADER_COLOR_ON))

					line:Show()
				end
				line.header.spell = spell
				line.spell = spell

				line._i = j

				for i=1,#line.assigns do
					local t = line.assigns[i]
					t:Hide()
				end

				spell_data.line = line
				line.data = spell_data
				line.header.data = spell_data

				line.header:Show()
			end
		end
		for i=line_c+1,#self.frame.lines do
			local line = self.frame.lines[i]
			line:Hide()
			line.header:Hide()
		end
	end

	function options.assign:FilterRemindersList(data_list)

		for j=#data_list,1,-1 do
			local spell = self:GetSpell(data_list[j][1])

			local spell_filter
			if spell then
				if VMRT.Reminder2.SpellGroups then
					for i=1,#VMRT.Reminder2.SpellGroups.names do
						if VMRT.Reminder2.SpellGroups[i][ spell ] then
							if type(spell_filter) == "table" then
								spell_filter[i] = true
							elseif spell_filter then
								spell_filter = {[spell_filter]=true,[i]=true}
							else
								spell_filter = i
							end
						end
					end
				end
			end
			if not spell_filter then
				spell_filter = -1
			end
			if not self:IsPassQFilter(self.QFILTER_SPELL,spell_filter) then
				tremove(data_list, j)
			end
		end
	end


	function options.assign:Update()
		local timeLineData = self:GetTimeLineData()
		self.timeLineData = timeLineData

		local data_list, data_uncategorized = self:GetRemindersList()

		if not self.FILTER_SPELLS then
			self:FilterRemindersList(data_list)
		end

		self:Util_LineAssignRemoveSpace()
		
		local line_c = 0
		local line_c_off = 0

		self.linedata = {}

		local spells_sorted = {}
		if timeLineData then
			for spell,spell_times in pairs(timeLineData) do
				if type(spell) == "number" and self:IsPassFilterSpellType(spell_times,spell) then
					for i=1,#spell_times do
						local t = type(spell_times[i])=="table" and spell_times[i][1] or spell_times[i]

						local isAdd = true

						if true then
							for j=#spells_sorted,1,-1 do
								if spells_sorted[j].id == spell and (t - spells_sorted[j].time) < 10 then
									isAdd = false
									break
								end
							end
						end

						if self:IsRemovedByTimeAdjust(t) then
							isAdd = false
						end

						if isAdd then
							t = self:GetTimeAdjust(t)
							local pname,ptime,pcount,pnum = self:GetPhaseFromTime(t)

							spells_sorted[#spells_sorted+1] = {
								id = spell, 
								name = (GetSpellName(spell) or "spell"..spell),
								isOff = self.spell_status[spell],
								prio = self.spell_status[spell] and 0 or 1,
								time = t,
								counter = i,
								main = spell_times,
								phase = pname,
								cuid = #spells_sorted+1,
							}
						end
					end
				end
			end
		end
		for i=1,#self.custom_line do
			local t = self.custom_line[i]
			local pname,ptime,pcount,pnum = self:GetPhaseFromTime(t)

			spells_sorted[#spells_sorted+1] = {
				id = 0, 
				name = "",
				prio = 1,
				time = t,
				counter = 0,
				phase = pname,
				isCustom = t,
				cuid = #spells_sorted+1,
			}
		end
		sort(spells_sorted,function(a,b) 
			if a.prio ~= b.prio then
				return a.prio > b.prio
			elseif a.time ~= b.time then
				return a.time < b.time
			elseif a.name ~= b.name then
				return a.name < b.name 
			else
				return a.cuid < b.cuid 
			end
		end)

		for i=1,#data_list do
			local data_line = data_list[i]
			local time = data_line and data_line[2] or 0
			local line, linepos
	
			for j=1,#spells_sorted do
				if not spells_sorted[j].isOff and (time >= spells_sorted[j].time - self.gluerange and time <= min(spells_sorted[j].time + self.gluerange,spells_sorted[j+1] and not spells_sorted[j+1].isOff and spells_sorted[j+1].time or math.huge)) then
					line = spells_sorted[j]
					linepos = j
					break
				end
			end
	
			if not line then
				local pos = 1
				for j=1,#spells_sorted do
					if not spells_sorted[j].isOff then
						pos = j + 1
						if time < spells_sorted[j].time then
							pos = j
							break
						end
					end
				end
				tinsert(spells_sorted, pos, {
					id = 0, 
					name = "",
					prio = 1,
					time = time,
				})
			end
		end

		if #data_list == 0 and #spells_sorted == 0 then
			tinsert(spells_sorted, 1, {
				id = 0, 
				name = "",
				prio = 1,
				time = 0,
			})
		end

		for j=1,#spells_sorted do
			local spell_data = spells_sorted[j]
			local spell = spell_data.id
			local isOff = spell_data.isOff
			line_c = line_c + 1

			self.linedata[#self.linedata+1] = spell_data

			if spell == 0 then
				local prevTime
				for i=j-1,1,-1 do
					if spells_sorted[i] and spells_sorted[i].id and spells_sorted[i].id ~= 0 then
						prevTime = spells_sorted[i].time
						break
					end
				end
				if prevTime then
					spell_data.line_name = "+"..module:FormatTime(spell_data.time - prevTime)
					spell_data.line_tiptime = spell_data.time
				else
					spell_data.line_time = module:FormatTime(spell_data.time)
				end
			else
				local name = GetSpellName(spell)
				local texture = GetSpellTexture(spell)
				spell_data.line_name = (name or "spell"..spell).." ("..spell_data.counter..")"
				spell_data.line_icon = texture
				spell_data.line_time = module:FormatTime(spell_data.time)
				spell_data.line_trigger = true
			end

			if spell_data.phase and spell_data.phase ~= 0 then
				if type(spell_data.phase)=="number" and spell_data.phase < 0 and spell_data.phase > -10000 then
					spell_data.line_trigger_text = "E"
					spell_data.line_trigger_text2 = ExRT.F.utf8sub(ExRT.L.bossName[-spell_data.phase] or "",1,5)
				else
					spell_data.line_trigger_text = "P"
					spell_data.line_trigger_text2 = spell_data.phase
				end
			else
				spell_data.line_trigger_text = "T"
			end

			if isOff then
				line_c_off = line_c_off + 1
			end

			spell_data.pos = self.TL_LINESIZE*(line_c-1)
			spell_data.height = self.TL_LINESIZE
			spell_data.a = {}
		end

		local max_y = (line_c+1)*self.TL_LINESIZE

		line_c = line_c - line_c_off
		if line_c == 0 then
			line_c = 1
		end

		max_y = max((line_c+1)*self.TL_LINESIZE,max_y)
		local max_in_line = 0
		for i=1,#data_list do

			local data_line = data_list[i]
			local data = data_line and data_line[1]
			local time = data_line and data_line[2] or 0
			local line

			for j=1,#spells_sorted do
				if not spells_sorted[j].isOff and (time >= spells_sorted[j].time - self.gluerange and time <= min(spells_sorted[j].time + self.gluerange,spells_sorted[j+1] and spells_sorted[j+1].time or math.huge)) then
					line = spells_sorted[j]
					break
				end
			end

			if line then
				line.a[#line.a+1] = data_line

				if max_in_line < #line.a then
					max_in_line = #line.a
				end
			else
				--no lines for out-of-bounds
				--print('line not found for',time,module:FormatTime(time))
			end
		end


		for i=1,#self.frame.assigns do
			self.frame.assigns[i]:Hide()
		end
		for j=1,#self.linedata do
			local spell_data = self.linedata[j]
			for i=1,#spell_data.a do
				local data_line = spell_data.a[i]
				local data = data_line and data_line[1]
				local time = data_line and data_line[2] or 0
	
				local assign = self:Util_LineAddAssign(i,data,spell_data)
	
				assign.timestamp = time
			end
		end

		self.frame.spells_sorted = spells_sorted

		local width = 10 + max_in_line * (self.TL_ASSIGNSPACING + self.TL_ASSIGNWIDTH)
		self.frame.width_now = width
		self.frame:Width(width)
		if width > self.frame:GetWidth() then
			self.frame.ScrollBarHorizontal:Show()
		elseif self.frame.ScrollBarHorizontal:IsShown() then
			self.frame.ScrollBarHorizontal:SetValue(0)
			self.frame.ScrollBarHorizontal:Hide()
		end

		self.frame:Height(max_y)
		self.frame.headers:Height(max_y)
		if max_y > self.frame:GetHeight() then
			self.frame.ScrollBar:Show()
		elseif self.frame.ScrollBar:IsShown() then
			self.frame.ScrollBar:SetValue(0)
			self.frame.ScrollBar:Hide()
		end

		self.frame.prevVPos = nil
		self:UpdateView()
	end





	self.scrollList = ELib:ScrollButtonsList(self.tab.tabs[1]):Point("TOPLEFT",5,-5):Size(690+300,530)
	self.scrollList.ButtonsInLine = 3
	ELib:Border(self.scrollList,0)

	self.searchEditBox = ELib:Edit(self.scrollList):Point("TOPLEFT",self,350+150,-27):Size(200,16):AddSearchIcon():OnChange(function (self,isUser)
		if not isUser then
			return
		end
		local text = self:GetText():lower()
		if text == "" then
			text = nil
		end
		options.search = text

		if self.scheduledUpdate then
			return
		end
		self.scheduledUpdate = C_Timer.NewTimer(.3,function()
			self.scheduledUpdate = nil
			options.scrollList.ScrollBar.slider:SetValue(0)
			options:UpdateData()
		end)
	end):Tooltip(SEARCH)
	self.searchEditBox:SetTextColor(0,1,0,1)


	self.profileDropDown = ELib:DropDown(self,250,-1):Point("BOTTOMLEFT",self.searchEditBox,"TOPLEFT",0,10):Size(200):AddText("+")
	self.profileDropDown.leftText:SetFontObject("GameFontNormalSmall")
	self.profileDropDown.leftText:SetTextColor(1,.82,0)
	self.profileDropDown.leftText:SetFont(self.profileDropDown.leftText:GetFont(),10)

	local function SetProfile(_,arg1)
		module:SetProfile(arg1,VMRT.Reminder2.ProfileShared)
		ELib:DropDownClose()
	end
	function self.profileDropDown:PreUpdate()
		wipe(self.List)
		local sharedProfilesList = module:GetSharedProfilesList()
		for i=1,#profilesSorted do
			local subMenu = {}
			local profileId = profilesSorted[i]
			self.List[#self.List+1] = {text = VMRT.Reminder2.profilesinfo[profileId] and VMRT.Reminder2.profilesinfo[profileId].name or profiles[ profileId ], arg1 = profileId, func = SetProfile, subMenu = subMenu}
			subMenu[#subMenu+1] = {text = "Rename", arg1 = profileId, func = function()
				ELib:DropDownClose() 
				ExRT.F.ShowInput("Set name for profile #"..profileId,function(_,name) 
					if type(name)=="string" and name:trim()=="" then 
						name = nil 
					end 
					if not VMRT.Reminder2.profilesinfo[profileId] then VMRT.Reminder2.profilesinfo[profileId] = {} end
					VMRT.Reminder2.profilesinfo[profileId].name = name 
					options.profileDropDown:AutoText(VMRT.Reminder2.Profile)
				end,nil,nil,VMRT.Reminder2.profilesinfo[profileId] and VMRT.Reminder2.profilesinfo[profileId].name or "") 
			end}
			local function CopyClickDropDownFunc(self,arg1)
				ELib:DropDownClose()
				for uid,w in pairs(VMRT.Reminder2.data[arg1]) do
					VMRT.Reminder2.data[profileId][uid] = ExRT.F.table_copy2(w)
				end
				options:Update()
				module:ReloadAll()
			end
			local copySubMenu = {}
			for j=1,#profilesSorted do
				local p = profilesSorted[j]
				copySubMenu[j] = {text = "Copy from "..(VMRT.Reminder2.profilesinfo[p] and VMRT.Reminder2.profilesinfo[p].name or profiles[ j ]), arg1 = p, func = CopyClickDropDownFunc, isTitle = p == profileId}
			end
			copySubMenu[#copySubMenu+1] = {text = " ",isTitle = true}
			for j=1,#sharedProfilesList do
				local p = sharedProfilesList[j].id
				copySubMenu[#copySubMenu+1] = {text = "Copy from "..(VMRT.Reminder2.profilesinfo[p] and VMRT.Reminder2.profilesinfo[p].name or profiles[0]), arg1 = p, func = CopyClickDropDownFunc, isTitle = p == profileId}
			end
			subMenu[#subMenu+1] = {text = "Copy from", subMenu = copySubMenu}
			subMenu[#subMenu+1] = {text = "Remove all", arg1 = profileId, func = function()
				ELib:DropDownClose() 
				StaticPopupDialogs["EXRT_REMINDER_CLEAR"] = {
					text = L.ReminderRemove.."?",
					button1 = L.YesText,
					button2 = L.NoText,
					OnAccept = function()
						for uid in pairs(VMRT.Reminder2.data[profileId]) do
							if bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,2)) == 0 then
								VMRT.Reminder2.data[profileId][uid] = nil
							end
						end
						options:Update()
						module:ReloadAll()
					end,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
				}
				StaticPopup_Show("EXRT_REMINDER_CLEAR")
			end}
		end
		self.List[#self.List+1] = {text = "-", arg1 = -1, func = SetProfile, tooltip = "With disabled personal profile new reminders won't be saved"}
	end
	self.profileDropDown:AutoText(VMRT.Reminder2.Profile)


	self.sharedProfileDropDown = ELib:DropDown(self,250,-1):Point("RIGHT",self.profileDropDown,"LEFT",-20,0):Size(150):AddText(L.InterruptsProfile..":")
	self.sharedProfileDropDown.leftText:SetFontObject("GameFontNormalSmall")
	self.sharedProfileDropDown.leftText:SetTextColor(1,.82,0)
	self.sharedProfileDropDown.leftText:SetFont(self.sharedProfileDropDown.leftText:GetFont(),10)

	local function SetSharedProfile(_,arg1)
		module:SetProfile(VMRT.Reminder2.Profile,arg1)
		ELib:DropDownClose()
	end
	function self.sharedProfileDropDown:PreUpdate()
		wipe(self.List)
		local sharedProfilesList = module:GetSharedProfilesList()
		for i=1,#sharedProfilesList do
			local profile = sharedProfilesList[i]
			local subMenu
			if profile.id ~= 0 then
				subMenu = {
					{text = "Remove", arg1 = profile.id, func = function()
						ELib:DropDownClose() 
						VMRT.Reminder2.data[profile.id] = nil
						module:SetProfile("x","x")
					end},
				}
			end
			self.List[#self.List+1] = {text = profile.info and profile.info.name or profiles[0], arg1 = profile.id, func = SetSharedProfile, subMenu = subMenu, tooltip = function()
				if profile.id == 0 and VMRT.Reminder2.LastUpdateName and (not profile.info or not profile.info.lastupdate) then
					return L.NoteLastUpdate..": "..VMRT.Reminder2.LastUpdateName.." ("..date("%d.%m.%Y %H:%M",VMRT.Reminder2.LastUpdateTime or 0)..")"
				elseif profile.info and profile.info.lastupdate then
					return L.NoteLastUpdate..": "..(profile.info.lastname or "").." ("..date("%d.%m.%Y %H:%M",profile.info.lastupdate or 0)..")"					
				else
					return ""
				end
			end, prio = profile.id == 0 and math.huge or profile.info and profile.info.lastupdate or -i}
		end
		sort(self.List,function(a,b) return a.prio > b.prio end)
		self.List[#self.List+1] = {text = "-", arg1 = -1, func = SetSharedProfile}
	end
	self.sharedProfileDropDown:AutoText(VMRT.Reminder2.ProfileShared or -1)



	local function UpdateOption(uid,enable,optionBit)
		if not uid then return end
		local roptions = VMRT.Reminder2.options[uid] or 0
		if enable then
			if bit.band(roptions,optionBit) > 0 then
				roptions = bit.bxor(roptions,optionBit)
			end
		else
			roptions = bit.bor(roptions,optionBit)
		end
		if roptions == 0 then roptions = nil end
		VMRT.Reminder2.options[uid] = roptions
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
					{ text = DELETE, func = function() ELib.ScrollDropDown.Close() options:RemoveReminder(data.data.uid) end, notCheckable = true },
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
			data2.uid = options:GetNewUID()
			if data.isPersonal then
				UpdateOption(data2.uid,false,bit.bor(bit.lshift(1,3),bit.lshift(1,2)))
			end
		else
			data2 = ExRT.F.table_copy2(data.data)
		end
		options.setupFrame:Update(data2)
		options.setupFrame:Show()
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
				for uid,data in pairs(module:RemGetAll()) do
					if 
						bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,2)) == 0 and
						(
						 (bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,3)) == 0 and not options.isPersonalTab) or
						 (bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,3)) > 0 and options.isPersonalTab)
						) and
						(
						 (self.bossID and data.bossID == self.bossID) or 
						 (type(self.bossID)=="table" and self.bossID[data.bossID]) or 
						 (self.zoneID and module:FindNumberInString(self.zoneID,data.zoneID))
						)
					then
						module:RemRem(uid)
					end
				end
				options:Update()
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

		options:ExportStr(export)
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

			local textObj = button:GetTextObj()
			textObj:SetPoint("LEFT",5+22+3,0)
			button.bossImg:SetPoint("LEFT",5,0)

			if data.bossID then
				if ExRT.GDB.encounterIDtoEJ[data.bossID] and EJ_GetCreatureInfo then
					local displayInfo = select(4, EJ_GetCreatureInfo(1, ExRT.GDB.encounterIDtoEJ[data.bossID]))
					if displayInfo then
						button.bossImg:SetTexCoord(0,1,0,1)
						SetPortraitTextureFromCreatureDisplayID(button.bossImg, displayInfo)
						resetBossImg = false
					end
				end
				if data.isSubData then
					textObj:SetPoint("LEFT",5+22+3+25,0)
					button.bossImg:SetPoint("LEFT",5+25,0)
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

			if options.isPersonalTab then
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

			local roptions = VMRT.Reminder2.options[data.data and data.data.uid or 0] or 0
			if bit.band(roptions,bit.lshift(1,0)) == 0 then
				button.onoff.status = 1
			else
				button.onoff.status = 2
			end
			button.onoff:Update(button.onoff.status)

			if bit.band(roptions,bit.lshift(1,1)) == 0 then
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

			if bit.band(roptions,bit.lshift(1,2)) == 0 then
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
		for uid,data in pairs(module:RemGetAll()) do
			local tableToAdd, tableToAddMulti

			local bossID = data.bossID
			local zoneID = data.zoneID
			if zoneID then
				zoneID = tonumber(tostring(zoneID):match("^[^, ]+") or "",10)
			end

			local function AddZone(zoneID)
				local zoneData = ExRT.F.table_find3(Mdata,zoneID,"zoneID")
				if not zoneData then
					local journalInstance = ExRT.GDB.MapIDToJournalInstance[tonumber(zoneID)]
					local fieldName = L.ReminderZone..((GetRealZoneText(zoneID) or VMRT.Reminder2.zoneNames[zoneID]) and ": "..(GetRealZoneText(zoneID) or VMRT.Reminder2.zoneNames[zoneID]).." |cffcccccc("..zoneID..")|r" or " "..zoneID)..(currZoneID == zoneID and " |cff00ff00("..L.ReminderNow..")|r" or "")
					if journalInstance and EJ_GetInstanceInfo then
						local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(journalInstance)
						if name then
							--"|A:questlog-questtypeicon-raid:20:20|a"
							local icon = nil
							fieldName = (icon or "")..name..(currZoneID == zoneID and " |cff00ff00("..L.ReminderNow..")|r" or "")
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

			local roptions = VMRT.Reminder2.options[uid] or 0
			local isPersonal = bit.band(roptions,bit.lshift(1,3)) > 0
			if 
				((isPersonal and options.isPersonalTab) or (not isPersonal and not options.isPersonalTab)) and
				(not options.search or (data.name and data.name:lower():find(options.search,1,true)) or (data.msg and data.msg:lower():find(options.search,1,true)))
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
					if type(data.zoneID) == "string" and data.zoneID:find("[ ,]") then
						for zoneMulti in data.zoneID:gmatch("%d+") do
							zoneMulti = tonumber(zoneMulti)
							if zoneMulti ~= zoneID then
								if not tableToAddMulti then
									tableToAddMulti = {}
								end
								tableToAddMulti[#tableToAddMulti+1] = AddZone(zoneMulti).data
							end
						end
					end
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
				if tableToAddMulti then
					for j=1,#tableToAddMulti do
						tableToAddMulti[j][#tableToAddMulti[j]+1] = {
							name = data.name or data.msg and module:FormatMsg(data.msg) or "~"..L.ReminderNoName,
							uid = uid.."M:"..j,
							--drag = true,
							data = data,
							isPersonal = isPersonal,
						}
					end
				end
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
				name = "|cffffffff  +"..(options.isPersonalTab and L.ReminderNewPersonal or L.ReminderNew),
				uid = "new"..i,
				nohud = true,
				isNew = true,
				isPersonal = options.isPersonalTab,
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

		options:UpdateSenderDataText()
	end

	self.AddButton = ELib:Button(self.tab.tabs[1],ADD):Point("TOPLEFT",self.scrollList,"BOTTOMLEFT",2,-5):Size(100,20):OnClick(function()
		local new = ExRT.F.table_copy2(newRemainderTemplate)
		new.uid = options:GetNewUID()

		if options.isPersonalTab then
			UpdateOption(new.uid,false,bit.bor(bit.lshift(1,3),bit.lshift(1,2)))
		end

		options.setupFrame:Update(new)
		options.setupFrame:Show()
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
		[2292] = 2657,	--n
		[2406] = 2769,	--lod
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
					self.assignSend:Enable()
				else
					C_Timer.After(0.5,function()
						self.SyncButton:Enable()
						self.assignSend:Enable()
					end)
				end
			end
			self.SyncButton:SetText(L.ReminderSend)
			self.assignSend:SetText(L.ReminderSend)
			return
		end
		if now == 0 then
			lastSyncTime = GetTime()
		end
		local progress = now / total
		self.SyncButton:Disable()
		self.SyncButton:SetText(L.ReminderSending.." "..format("%d%%",progress * 100))
		self.assignSend:Disable()
		self.assignSend:SetText(L.ReminderSending.." "..format("%d%%",progress * 100))
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
				for uid in pairs(module:RemGetAll()) do
					if bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,2)) == 0 then
						module:RemRem(uid)
					end
				end
				options:Update()
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
		if not export then return end

		self:ExportStr(export)
	end)

	function self:ExportStr(export)
		options.exportWindow:NewPoint("CENTER",UIParent,0,0)

		local compressed
		if #export < 1000000 then
			compressed = LibDeflate:CompressDeflate(export.."##F##",{level = 5})
		end
		local encoded = "MRTREMD"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or export)

		ExRT.F.dprint("Str len:",#export,"Encoded len:",#encoded)

		if IsShiftKeyDown() and IsControlKeyDown() then
			--encoded = "EXRTREMD".."2"..export
		end
		options.exportWindow.Edit:SetText(encoded)
		options.exportWindow:Show()
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
				for q,w in pairs(module:RemGetAll()) do
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
			local line = options.copyClickDropDown.List[i]
			if line.arg1 == VMRT.Reminder2.Profile then
				line.isTitle = true
			else
				line.isTitle = false
			end
		end

		local x,y = ExRT.F.GetCursorPos(self)
		options.copyClickDropDown:SetPoint("TOPLEFT",self,x,-y)
		options.copyClickDropDown:Click()
	end)

	--[[
	self.SendGuildButton = ELib:Button(self.tab.tabs[1],L.ReminderSendGuild):Point("RIGHT",self.CopyToButton,"LEFT",-5,0):Size(120,20):OnClick(function()
		module:SyncGuild()
		self.SyncButton:Click()
	end)
	]]





	function self:GetNewUID()
		local _,sid,pid = strsplit("-",UnitGUID("player"),nil)
		local t
		local cn = 0
		while true do
			t = module:ConvertTo36Bit((time() + GetTime() % 1) * 1000 + cn)
		  	if module:RemGet(sid .. "-" .. pid .. "-" .. t) then
				cn = cn + 1
			else
				break
			end
		end
		return sid .. "-" .. pid .. "-" .. t
	end

	local SETUPFRAME_HEIGHT = 610

	self.setupFrame = ELib:Popup(" "):Size(510,SETUPFRAME_HEIGHT)
	ELib:Border(self.setupFrame,1,.4,.4,.4,.9)

	self.setupFrame.decorationLine = ELib:DecorationLine(self.setupFrame,true,"BACKGROUND",1):Point("TOPLEFT",self.setupFrame,0,-16):Point("BOTTOMRIGHT",self.setupFrame,"TOPRIGHT",0,-36)

	self.setupFrame.tab = ELib:Tabs(self.setupFrame,0,L.ReminderTabGeneral,L.ReminderTabCond,L.ReminderTabLoadPlayers,L.ReminderTabPersonal,"Test"):Point(0,-36):Size(510,598):SetTo(1)
	self.setupFrame.tab:SetBackdropBorderColor(0,0,0,0)
	self.setupFrame.tab:SetBackdropColor(0,0,0,0)

	self.setupFrame.tab.tabs[3].button.alert = CreateAlertIcon(self.setupFrame.tab.tabs[3].button,L.ReminderAlertConditionBossZone,L.ReminderAlertConditionBossZone2)
	self.setupFrame.tab.tabs[3].button.alert:SetScale(.8)
	self.setupFrame.tab.tabs[3].button.alert:SetPoint("CENTER",self.setupFrame.tab.tabs[3].button,"TOPRIGHT",-10,-10)
	self.setupFrame.tab.tabs[3].button.alert.Update = function(self)
		if not options.setupFrame.data.bossID and not options.setupFrame.data.zoneID then
			self:Show()
		else
			self:Hide()
		end
	end

	function self.setupFrame:CloseClick()
		local uid = self.data.uid
		if uid and module:RemGet(uid) and ExRT.F.table_compare(self.data,module:RemGet(uid)) == 1 then
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
				if not module:RemGet(uid) then
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

	self.setupFrame.saveButton = ELib:Button(self.setupFrame,L.ReminderSave):Point("BOTTOM",0,10):Size(300,20):OnClick(function(_,button)
		self.setupFrame:Hide()
		local uid = self.setupFrame.data.uid or self:GetNewUID()
		self.setupFrame.data.uid = uid
		if IsShiftKeyDown() or button == "RightButton" then
			module:RemAdd(uid,self.setupFrame.data,true)
		else
			module:RemAdd(uid,self.setupFrame.data)
		end
		self.setupFrame.data.updatedName = ExRT.SDB.charName
		self.setupFrame.data.updatedTime = time()
		options:Update()
		module:ReloadAll()
	end):OnShow(function(self)
		local data = options.setupFrame.data
		local uid = data and data.uid
		if uid and module:RemGetSource(uid) == 0 then
			self.icon_shared:Show()
		elseif self.icon_shared:IsShown() then
			self.icon_shared:Hide()
		end
	end,true)
	self.setupFrame.saveButton:RegisterForClicks("LeftButtonUp","RightButtonUp")

	self.setupFrame.saveButton.icon_shared = ELib:Icon(self.setupFrame.saveButton,nil,20):Point("LEFT",'x',"RIGHT",2,0):Shown(false):Tooltip("This reminder is from shared profile. It can be rewritten/removed upon updates from other players. Hold shift or use right click for saving it to currently selected profile.\nIf you will have same reminder in shared and personal profiles than newer version will be shown.", nil, nil, nil, nil, true)
	self.setupFrame.saveButton.icon_shared.texture:SetAtlas("ShipMissionIcon-Bonus-MapBadge")

	self.setupFrame.copyButton = ELib:Button(self.setupFrame.tab.tabs[1],L.ReminderCopy):Point("BOTTOMRIGHT",self.setupFrame.saveButton,"TOP",-5,5):Size(200,20):OnClick(function()
		if not self.setupFrame.data.uid then
			print(L.ReminderAlertNoCopyEmpty)
			return
		end
		self.setupFrame:Hide()
		local uid = self:GetNewUID()
		local newData = ExRT.F.table_copy2(self.setupFrame.data)
		newData.uid = uid
		module:RemAdd(uid,newData)
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

		options:Update()
		module:ReloadAll()
	end)

	function self:RemoveReminder(uid)
		local remove = function()
			self.setupFrame:Hide()
			self.quickSetupFrame:Hide()
			if uid then
				module:RemRem(uid)
			end
			options:Update()
			module:ReloadAll()
		end
		if module.db.removeIgnorePopup then
			remove()
		else
			StaticPopupDialogs["EXRT_REMINDER_REMOVE_ONE"] = {
				text = L.ReminderRemove.."?",
				button1 = L.YesText,
				button2 = L.ReminderYesNoAfter,
				button3 = L.NoText,
				OnAccept = function()
					remove()
				end,
				OnAlt = function() end,
				OnCancel = function() 
					module.db.removeIgnorePopup = true
					remove()
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("EXRT_REMINDER_REMOVE_ONE")
		end
	end

	self.setupFrame.removeButton = ELib:Button(self.setupFrame.tab.tabs[1],L.ReminderRemove):Point("BOTTOMLEFT",self.setupFrame.saveButton,"TOP",5,5):Size(200,20):OnClick(function()
		local uid = self.setupFrame.data.uid
		options:RemoveReminder(uid)
	end)

	self.setupFrame.sendOneButton = ELib:Button(self.setupFrame.tab.tabs[1],L.ReminderSendOne):Point("BOTTOM",self.setupFrame.copyButton,"TOP",0,5):Size(200,20):OnClick(function(self)
		if not options.setupFrame.data.uid then
			print(L.ReminderAlertSaveB4Sending)
			return
		end
		if IsInRaid() then
			if not ExRT.F.IsPlayerRLorOfficer("player") then
				print(L.ReminderAlertSendOnlyRaidOfficer)
				return
			end
		end
		if ExRT.F.table_compare(options.setupFrame.data,module:RemGet(options.setupFrame.data.uid)) ~= 1 then
			print(L.ReminderAlertSaveB4Sending)
			return
		end
		self:Disable()
		self:SetText(L.ReminderSending.."...")
		ExRT.F.ScheduleTimer(function()
			self:Enable()
			self:SetText(L.ReminderSendOne)
		end, 0.5)
		module:Sync(false,nil,nil,options.setupFrame.data.uid)
	end)

	self.setupFrame.exportOneButton = ELib:Button(self.setupFrame.tab.tabs[1],L.ReminderExportToString):Point("BOTTOM",self.setupFrame.removeButton,"TOP",0,5):Size(200,20):OnClick(function()
		self.setupFrame:Hide()
		local uid = self.setupFrame.data.uid

		local savedOriginal = module:RemGet(uid)
		module:RemAdd(uid,self.setupFrame.data)
		local export = module:Sync(true,nil,nil,uid)
		module:RemAdd(uid,savedOriginal)

		self:ExportStr(export)
	end)

	self.setupFrame.nameEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):Point("TOPLEFT",180,-10):LeftText(L.ReminderName..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		options.setupFrame.data.name = text
	end)

	self.setupFrame.msgSize = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.messageSize):AddText("|cffffd100"..L.ReminderMsgType..":"):Size(270)
	do
		local function msgSize_SetValue(_,arg1)
			ELib:DropDownClose()
			if not options.setupFrame.setup then
				options.setupFrame.data.msgSize = arg1
			end
			local val = ExRT.F.table_find3(module.datas.messageSize,arg1,1)
			if val then
				self.setupFrame.msgSize:SetText(val[2])
			else
				self.setupFrame.msgSize:SetText("?")
			end

			options.setupFrame:RebuildSetupPage()
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

	self.setupFrame.msgEdit = ELib:MultiEdit(self.setupFrame.tab.tabs[1]):Size(270,80):HideScrollOnNoScroll():OnChange(function(self,isUser)
		options.setupFrame.msgPreview:SetText( module:FormatMsg(self:GetText():gsub("\n",""), {}) or "" )
		if not isUser then return end
		local text = self:GetText():gsub("\n",""):trim()
		if text == "" then text = nil end
		options.setupFrame.data.msg = text
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
		GameTooltip:AddLine("|cff00ff00{funit:CONDITIONS:NUM_IN_LIST}|r - select player from raid/party that met conditions. Conditions can be class (|cff00ff00priest|r,|cff00ff00mage|r),\nrole (|cff00ff00healer|r,|cff00ff00damager|r), group (|cff00ff00g2|r,|cff00ff00g5|r). Multiple conditions must be written comma separated, player will be added to the list if any of the conditions are met.\nYou can use |cff00ff00+|r symbol before condition to make it additive. Examples: |cff00ff00{funit:paladin,+damager:2}|r, |cff00ff00{funit:mage,+g2,priest:3}|r\n(mages from group 2 or priests from any group will be added to the list. Pattern will return name of the third player from this list)")
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("|cff00ff00{set:X}...{/set}|r - "..L.ReminderFormatTipSaveText:format("|cff00ff00%setX|r"))
		GameTooltip:AddLine("|cff00ff00{find:PATT:TEXT}YES;NO{/find}|r - "..L.ReminderFormatTipFind)
		GameTooltip:AddLine("|cff00ff00{replace:FROM:TO}TEXT{/replace}|r - "..L.ReminderFormatTipReplace)

		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_RAIDFRAME then
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
				local hlstart,hlend = options.setupFrame.msgEdit:GetTextHighlight()
				if hlstart == hlend then
					options.setupFrame.msgEdit:SetText( "||cff"..code..options.setupFrame.msgEdit:GetText().."||r" )
				else
					local text = options.setupFrame.msgEdit:GetText()
					text = text:sub(1, hlend) .. "||r" .. text:sub(hlend+1)
					text = text:sub(1, hlstart) .. "||cff"..code .. text:sub(hlstart+1)
					options.setupFrame.msgEdit:SetText( text )
				end
				options.setupFrame.msgEdit.EditBox:GetScript("OnTextChanged")(options.setupFrame.msgEdit.EditBox,true)
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
				local hlstart,hlend = options.setupFrame.msgEdit:GetTextHighlight()
				if hlstart == hlend then
					options.setupFrame.msgEdit:SetText( "||cff"..code..options.setupFrame.msgEdit:GetText().."||r" )
				else
					local text = options.setupFrame.msgEdit:GetText()
					text = text:sub(1, hlend) .. "||r" .. text:sub(hlend+1)
					text = text:sub(1, hlstart) .. "||cff"..code .. text:sub(hlstart+1)
					options.setupFrame.msgEdit:SetText( text )
				end
				options.setupFrame.msgEdit.EditBox:GetScript("OnTextChanged")(options.setupFrame.msgEdit.EditBox,true)
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

	self.setupFrame.durEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):LeftText(L.ReminderDuration..":"):OnChange(function(self,isUser)
		if not isUser then return end
		options.setupFrame.data.dur = tonumber( self:GetText() )
	end):Tooltip(function(self)
		self.lockTooltipText = true

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L.ReminderDuration)
		GameTooltip:AddLine(L.ReminderDurationTooltip)
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_CHAT then
			GameTooltip:AddLine(L.ReminderDurationTooltipMsg)
		end
		GameTooltip:Show()
	end)
	function self.setupFrame.durEdit:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) ~= REM.TYPE_WA then
			return true
		end
	end

	self.setupFrame.durRevese = ELib:Check(self.setupFrame.tab.tabs[1],L.ReminderDurRev..":"):Left(5):Tooltip(L.ReminderDurRevTooltip):OnClick(function(self)
		if self:GetChecked() then
			options.setupFrame.data.durrev = true
		else
			options.setupFrame.data.durrev = nil
		end
	end)
	function self.setupFrame.durRevese:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) ~= REM.TYPE_WA then
			return true
		end
	end

	self.setupFrame.soundList = ELib:DropDown(self.setupFrame.tab.tabs[1],270,15):AddText("|cffffd100"..L.ReminderSound..":"):Size(270)
	function self.setupFrame.soundList.func_SetValue(_,arg1)
		self.setupFrame.soundCustom.tts = false
		self.setupFrame.soundList.lastOpt = arg1
		if arg1 == 0 then
			if not options.setupFrame.setup then
				options.setupFrame.data.sound = nil
			end

			self.setupFrame.soundList:SetText(L.ReminderCustom)
		elseif not arg1 then
			if not options.setupFrame.setup then
				options.setupFrame.data.sound = nil
			end

			self.setupFrame.soundList:SetText("-")
		else
			if not options.setupFrame.setup then
				options.setupFrame.data.sound = arg1
			end

			local val = ExRT.F.table_find3(self.setupFrame.soundList.List,arg1,"arg1")
			if val then
				self.setupFrame.soundList:SetText(val.text)
			else
				self.setupFrame.soundList:SetText(arg1)
			end

			if arg1 == "TTS2" then
				self.setupFrame.soundCustom.tts = true
				if not options.setupFrame.setup then
					options.setupFrame.data.sound = "TTS:"
					self.setupFrame.soundCustom:SetText("")
				end
			end
		end
		options.setupFrame:RebuildSetupPage()
		ELib:DropDownClose()
		if not options.setupFrame.setup and arg1 and arg1 ~= 0 then
			module:PlaySound(arg1)
		end
	end
	function self.setupFrame.soundList.Update()
		local data = options.setupFrame.data
		if data.sound then
			self.setupFrame.soundList:PreUpdate()
			local val = ExRT.F.table_find3(self.setupFrame.soundList.List,data.sound,"arg1")
			if val then
				self.setupFrame.soundList:func_SetValue(data.sound)
			elseif type(data.sound)=='string' and data.sound:find("^TTS:") then
				self.setupFrame.soundList:func_SetValue("TTS2")
				self.setupFrame.soundCustom:SetText(type(data.sound)=="string" and data.sound:gsub("^TTS:","") or "")
			else
				self.setupFrame.soundList:func_SetValue(0)
				self.setupFrame.soundCustom:SetText(data.sound or "")
			end
		else
			self.setupFrame.soundList:func_SetValue(data.sound)
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

	self.setupFrame.soundCustom = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):LeftText(L.ReminderCustomSound..":"):Shown(false):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		if self.tts and text then text = "TTS:" .. text end
		options.setupFrame.data.sound = text
	end)
	function self.setupFrame.soundCustom:ExtraShown()
		if options.setupFrame.soundList:IsShown() and 
		(
			(type(options.setupFrame.data.sound)=='string' and options.setupFrame.data.sound:find("^TTS:")) or
			(options.setupFrame.data.sound and not ExRT.F.table_find3(options.setupFrame.soundList.List,options.setupFrame.data.sound,"arg1")) or
			options.setupFrame.soundList.lastOpt == 0
		) then
			return true
		end
	end

	self.setupFrame.soundList.playButton = ELib:Icon(self.setupFrame.soundList,"Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128",20,true):Point("LEFT",self.setupFrame.soundList,"RIGHT",5,0)
	self.setupFrame.soundList.playButton.texture:SetTexCoord(0.375,0.4375,0.5,0.625)
	self.setupFrame.soundList.playButton:SetScript("OnClick",function()
		if options.setupFrame.data.sound == "TTS" then
			module:PlaySound(options.setupFrame.data.sound, {data={msg=(options.setupFrame.data.msg or "")},params={}})
		elseif type(options.setupFrame.data.sound) == "string" and options.setupFrame.data.sound:find("^TTS:") then
			module:PlaySound(options.setupFrame.data.sound, {data={msg=(options.setupFrame.data.msg or "")},params={}})
		else
			module:PlaySound(options.setupFrame.data.sound)
		end
	end)

	self.setupFrame.soundDelayEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):LeftText(L.ReminderSoundDelay..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText()
		if text and text:trim() == "" then text = nil end
		options.setupFrame.data.sounddelay = text
	end):Tooltip(L.ReminderSoundDelayTip)
	function self.setupFrame.soundDelayEdit:ExtraShown()
		if options.setupFrame.soundList:IsShown() and 
			(options.setupFrame.data.sound or options.setupFrame.soundList.lastOpt == 0)
		then
			return true
		end
	end

	self.setupFrame.soundAfterList = ELib:DropDown(self.setupFrame.tab.tabs[1],270,15):AddText("|cffffd100"..L.ReminderSoundAfter..":"):Size(270)
	function self.setupFrame.soundAfterList.func_SetValue(_,arg1)
		self.setupFrame.soundAfterCustom.tts = false
		self.setupFrame.soundAfterList.lastOpt = arg1
		if arg1 == 0 then
			if not options.setupFrame.setup then
				options.setupFrame.data.soundafter = nil
			end

			self.setupFrame.soundAfterList:SetText(L.ReminderCustom)
		elseif not arg1 then
			if not options.setupFrame.setup then
				options.setupFrame.data.soundafter = nil
			end

			self.setupFrame.soundAfterList:SetText("-")
		else
			if not options.setupFrame.setup then
				options.setupFrame.data.soundafter = arg1
			end

			local val = ExRT.F.table_find3(self.setupFrame.soundAfterList.List,arg1,"arg1")
			if val then
				self.setupFrame.soundAfterList:SetText(val.text)
			else
				self.setupFrame.soundAfterList:SetText(arg1)
			end

			if arg1 == "TTS2" then
				self.setupFrame.soundAfterCustom.tts = true
				if not options.setupFrame.setup then
					options.setupFrame.data.soundafter = "TTS:"
					self.setupFrame.soundAfterCustom:SetText("")
				end
			end
		end
		options.setupFrame:RebuildSetupPage()
		ELib:DropDownClose()
		if not options.setupFrame.setup and arg1 and arg1 ~= 0 then
			module:PlaySound(arg1)
		end
	end
	self.setupFrame.soundAfterList.PreUpdate = self.setupFrame.soundList.PreUpdate
	function self.setupFrame.soundAfterList:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_TEXT then
			return true
		end
	end

	function self.setupFrame.soundAfterList.Update(_,blockUpdate)
		local data = options.setupFrame.data
		if blockUpdate then
			self.setupFrame.soundAfterList.blockUpdate = true
		end
		if data.soundafter then
			self.setupFrame.soundAfterList:PreUpdate()
			local val = ExRT.F.table_find3(self.setupFrame.soundAfterList.List,data.soundafter,"arg1")
			if val then
				self.setupFrame.soundAfterList:func_SetValue(data.soundafter)
			elseif type(data.soundafter)=='string' and data.soundafter:find("^TTS:") then
				self.setupFrame.soundAfterList:func_SetValue("TTS2")
				self.setupFrame.soundAfterCustom:SetText(type(data.soundafter)=="string" and data.soundafter:gsub("^TTS:","") or "")
			else
				self.setupFrame.soundAfterList:func_SetValue(0)
				self.setupFrame.soundAfterCustom:SetText(data.soundafter or "")
			end
		else
			self.setupFrame.soundAfterList:func_SetValue(data.soundafter)
		end
		self.setupFrame.soundAfterList.blockUpdate = nil
	end

	self.setupFrame.soundAfterCustom = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):Point("TOPLEFT",self.setupFrame.soundAfterList,"TOPLEFT",0,0):LeftText(L.ReminderCustomSound..":"):Shown(false):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		if self.tts and text then text = "TTS:" .. text end
		options.setupFrame.data.soundafter = text
	end)
	function self.setupFrame.soundAfterCustom:ExtraShown()
		if options.setupFrame.soundAfterList:IsShown() and 
		(
			(type(options.setupFrame.data.soundafter)=='string' and options.setupFrame.data.soundafter:find("^TTS:")) or
			(options.setupFrame.data.soundafter and not ExRT.F.table_find3(options.setupFrame.soundAfterList.List,options.setupFrame.data.soundafter,"arg1")) or
			options.setupFrame.soundAfterList.lastOpt == 0
		) then
			return true
		end
	end

	self.setupFrame.soundAfterList.playButton = ELib:Icon(self.setupFrame.soundAfterList,"Interface\\AddOns\\MRT\\media\\DiesalGUIcons16x256x128",20,true):Point("LEFT",self.setupFrame.soundAfterList,"RIGHT",5,0)
	self.setupFrame.soundAfterList.playButton.texture:SetTexCoord(0.375,0.4375,0.5,0.625)
	self.setupFrame.soundAfterList.playButton:SetScript("OnClick",function()
		if options.setupFrame.data.soundafter == "TTS" then
			module:PlaySound(options.setupFrame.data.soundafter, {data={msg=(options.setupFrame.data.msg or "")},params={}})
		elseif type(options.setupFrame.data.soundafter) == "string" and options.setupFrame.data.soundafter:find("^TTS:") then
			module:PlaySound(options.setupFrame.data.soundafter, {data={msg=(options.setupFrame.data.msg or "")},params={}})
		else
			module:PlaySound(options.setupFrame.data.soundafter)
		end
	end)

	self.setupFrame.countdownCheck = ELib:Check(self.setupFrame.tab.tabs[1],L.ReminderCountdown..":"):Left(5):Tooltip(L.ReminderCountdownTooltip):OnClick(function(self)
		if not options.setupFrame.setup then
			if self:GetChecked() then
				options.setupFrame.data.countdown = true
			else
				options.setupFrame.data.countdown = nil
			end
		end
		options.setupFrame:RebuildSetupPage()
	end)
	function self.setupFrame.countdownCheck:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_CHAT or module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_TEXT then
			return true
		end
	end

	self.setupFrame.countdownType = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.countdownType):AddText("|cffffd100"..L.ReminderCountdownAccuracy..":"):Size(270):Shown(false)
	do
		local function countdownType_SetValue(_,arg1)
			ELib:DropDownClose()
			options.setupFrame.data.countdownType = arg1
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
	function self.setupFrame.countdownType:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_BAR or 
			(options.setupFrame.countdownCheck:IsShown() and options.setupFrame.data.countdown and module:GetReminderType(options.setupFrame.data.msgSize) ~= REM.TYPE_CHAT) 
		then
			return true
		end
	end

	self.setupFrame.countdownTypeText = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.countdownTypeText):AddText("|cffffd100"..L.ReminderCountdownFrequency..":"):Size(270):Shown(false)
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
	function self.setupFrame.countdownTypeText:ExtraShown()
		if options.setupFrame.countdownCheck:IsShown() and options.setupFrame.data.countdown and module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_CHAT then
			return true
		end
	end

	self.setupFrame.countdownVoice = ELib:DropDown(self.setupFrame.tab.tabs[1],220,10):AddText("|cffffd100"..L.ReminderCountdownVoice..":"):Size(270)
	do
		local function countdownVoice_SetValue(_,arg1)
			ELib:DropDownClose()
			options.setupFrame.data.countdownVoice = arg1
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
	function self.setupFrame.countdownVoice:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_BAR or module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_TEXT then
			return true
		end
	end

	self.setupFrame.copyCheck = ELib:Check(self.setupFrame.tab.tabs[1],L.ReminderCopyLabel..":"):Left(5):Tooltip(L.ReminderCopyLabelTooltip):OnClick(function(self)
		if self:GetChecked() then
			options.setupFrame.data.copy = true
		else
			options.setupFrame.data.copy = nil
		end
	end)
	function self.setupFrame.copyCheck:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_BAR or module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_TEXT then
			return true
		end
	end

	self.setupFrame.disableRewrite = ELib:Check(self.setupFrame.tab.tabs[1],L.ReminderDisableRewrite..":"):Left(5):Tooltip(L.ReminderDisableRewriteTooltip):OnClick(function(self)
		if self:GetChecked() then
			options.setupFrame.data.norewrite = true
		else
			options.setupFrame.data.norewrite = nil
		end
	end)
	function self.setupFrame.disableRewrite:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_BAR or module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_TEXT then
			return true
		end
	end

	self.setupFrame.disableDynamicUpdates = ELib:Check(self.setupFrame.tab.tabs[1],L.ReminderDisableDynamicUpdates..":"):Left(5):Tooltip(L.ReminderDisableDynamicUpdatesTooltip):OnClick(function(self)
		if self:GetChecked() then
			options.setupFrame.data.dynamicdisable = true
		else
			options.setupFrame.data.dynamicdisable = nil
		end
	end)
	function self.setupFrame.disableDynamicUpdates:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) ~= REM.TYPE_WA and module:GetReminderType(options.setupFrame.data.msgSize) ~= REM.TYPE_CHAT then
			return true
		end
	end

	self.setupFrame.glowTypeEdit = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.glowTypes):AddText("|cffffd100"..L.ReminderGlowType..":"):Size(270)
	do
		local function glowType_SetValue(_,glowType)
			options.setupFrame.data.glowType = glowType
			local glow = ExRT.F.table_find3(module.datas.glowTypes,glowType,1)
			if glow then
				self.setupFrame.glowTypeEdit:SetText(glow[2])
			else
				self.setupFrame.glowTypeEdit:SetText(L.ReminderGlowType.." "..(glowType or 0))
			end
			ELib:DropDownClose()

			if glowType == 6 then
				options.setupFrame.glowImage:SetValue(options.setupFrame.data.glowImage)
			end

			if not glowType or glowType == 1 or glowType == 3 or glowType == 7 then
				options.setupFrame.glowNEdit.leftText:SetText(glowType == 7 and "HP, %:" or L.ReminderGlowParticles..":")
				options.setupFrame.glowNEdit:Tooltip(glowType == 7 and L.ReminderExample..": |cff00ff0035|r" or L.ReminderFormatTipNameplateGlowAutocastSize)
			end

			options.setupFrame:RebuildSetupPage()
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
	function self.setupFrame.glowTypeEdit:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_NAMEPLATE or module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_RAIDFRAME then
			return true
		end
	end

	self.setupFrame.glowImage = ELib:DropDown(self.setupFrame.tab.tabs[1],220,#module.datas.glowImages):AddText("|cffffd100"..L.ReminderGlowImage..":"):Size(270):Shown(false)
	do
		local function glowImage_SetValue(_,glowImage)
			options.setupFrame.glowImage.preview:SetTexture()
			options.setupFrame.glowImage.lastOpt = glowImage

			local isCustomImg
			if glowImage == 0 or type(glowImage) == 'string' then
				isCustomImg = true
				glowImage = glowImage ~= 0 and glowImage or nil
			end
			options.setupFrame.data.glowImage = glowImage
			local glow = ExRT.F.table_find3(module.datas.glowImages,glowImage,1)
			if isCustomImg then
				self.setupFrame.glowImage:SetText(L.ReminderCustom)
				self.setupFrame.glowImageCustomEdit:SetText(glowImage or "")
			elseif glow then
				self.setupFrame.glowImage:SetText(glow[2])
			else
				self.setupFrame.glowImage:SetText("Glow image "..(glowImage or 0))
			end
			options.setupFrame.glowImage.preview:Update()
			options.setupFrame:RebuildSetupPage()
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
			self.setupFrame.glowImageCustomEdit:Hide()
			options.setupFrame:RebuildSetupPage()
		end)
	end
	function self.setupFrame.glowImage:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_BAR or (options.setupFrame.glowTypeEdit:IsShown() and options.setupFrame.data.glowType == 6) then
			return true
		end
	end

	self.setupFrame.glowImage.preview = self.setupFrame.glowImage:CreateTexture()
	self.setupFrame.glowImage.preview:SetPoint("LEFT",self.setupFrame.glowImage,"RIGHT",5,0)
	self.setupFrame.glowImage.preview:SetSize(30,30)
	self.setupFrame.glowImage.preview.Update = function(self)
		local glowImage = options.setupFrame.data.glowImage
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

	self.setupFrame.glowImageCustomEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):LeftText(L.ReminderGlowImageCustom..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		options.setupFrame.data.glowImage = text
		options.setupFrame.glowImage.preview:Update()
	end):Shown(false)
	function self.setupFrame.glowImageCustomEdit:ExtraShown()
		if options.setupFrame.glowImage:IsShown() and (type(options.setupFrame.data.glowImage) == "string" or options.setupFrame.glowImage.lastOpt == 0) then
			return true
		end
	end


	self.setupFrame.glowColorEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(100,20):LeftText(COLOR..":"):Run(function(s) 
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
			options.setupFrame.data.glowColor = nil
			options.setupFrame.glowColorEdit.preview:Update()
		elseif text:find("^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$") then
			options.setupFrame.data.glowColor = text
			options.setupFrame.glowColorEdit.preview:Update()
			self:Disable()
		end
	end)
	function self.setupFrame.glowColorEdit:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_BAR or module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_NAMEPLATE or module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_RAIDFRAME then
			return true
		end
	end

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
		if options.setupFrame.data.glowColor then
			local at,rt,gt,bt = options.setupFrame.data.glowColor:match("(..)(..)(..)(..)")
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
				options.setupFrame.data.glowColor = format("%02x%02x%02x%02x",newA*255,newR*255,newG*255,newB*255)
	
				options.setupFrame.glowColorEdit:SetText(options.setupFrame.data.glowColor)
				options.setupFrame.glowColorEdit:Disable()
				options.setupFrame.glowColorEdit.preview:Update()
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
				options.setupFrame.data.glowColor = format("%02x%02x%02x%02x",newA*255,newR*255,newG*255,newB*255)
	
				options.setupFrame.glowColorEdit:SetText(options.setupFrame.data.glowColor)
				options.setupFrame.glowColorEdit:Disable()
				options.setupFrame.glowColorEdit.preview:Update()
			end
			info.cancelFunc = function()
				local newR, newG, newB, newA = ColorPickerFrame:GetPreviousValues()
				options.setupFrame.data.glowColor = format("%02x%02x%02x%02x",newA*255,newR*255,newG*255,newB*255)
	
				options.setupFrame.glowColorEdit:SetText(options.setupFrame.data.glowColor)
				options.setupFrame.glowColorEdit:Disable()
				options.setupFrame.glowColorEdit.preview:Update()
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


	self.setupFrame.glowThickEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):LeftText(L.ReminderGlowThick..":"):OnChange(function(self,isUser)
		if not isUser then return end
		options.setupFrame.data.glowThick = tonumber( self:GetText() )
	end):Tooltip(L.ReminderFormatTipNameplateGlowSize)
	function self.setupFrame.glowThickEdit:ExtraShown()
		if options.setupFrame.glowTypeEdit:IsShown() and (options.setupFrame.data.glowType == 1 or options.setupFrame.data.glowType == 4 or options.setupFrame.data.glowType == 7 or not options.setupFrame.data.glowType) then
			return true
		end
	end

	self.setupFrame.glowScaleEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):LeftText(L.ReminderGlowScale..":"):OnChange(function(self,isUser)
		if not isUser then return end
		options.setupFrame.data.glowScale = tonumber( self:GetText() )
	end):Tooltip(L.ReminderFormatTipNameplateGlowScale)
	function self.setupFrame.glowScaleEdit:ExtraShown()
		if options.setupFrame.glowTypeEdit:IsShown() and (options.setupFrame.data.glowType == 1 or options.setupFrame.data.glowType == 2 or options.setupFrame.data.glowType == 3 or options.setupFrame.data.glowType == 6 or not options.setupFrame.data.glowType) then
			return true
		end
	end

	self.setupFrame.glowNEdit = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):LeftText(L.ReminderGlowParticles..":"):OnChange(function(self,isUser)
		if not isUser then return end
		options.setupFrame.data.glowN = tonumber( self:GetText() )
	end):Tooltip(L.ReminderFormatTipNameplateGlowAutocastSize)
	function self.setupFrame.glowNEdit:ExtraShown()
		if options.setupFrame.glowTypeEdit:IsShown() and (options.setupFrame.data.glowType == 1 or options.setupFrame.data.glowType == 3 or options.setupFrame.data.glowType == 7 or not options.setupFrame.data.glowType) then
			return true
		end
	end

	self.setupFrame.customOpt1 = ELib:Edit(self.setupFrame.tab.tabs[1]):Size(270,20):LeftText("Custom ticks:"):Tooltip(L.ReminderExample..":\n3\n2.5,5,7.5"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		options.setupFrame.data.customOpt1 = text
	end):Shown(false)
	function self.setupFrame.customOpt1:ExtraShown()
		if module:GetReminderType(options.setupFrame.data.msgSize) == REM.TYPE_BAR then
			return true
		end
	end

	self.setupFrame.debugCheck = ELib:Check(self.setupFrame.tab.tabs[1],"Debug:"):Left(5):OnClick(function(self)
		if self:GetChecked() then
			options.setupFrame.data.debug = true
			if not module.db.debug then
				module:ToggleDebugMode()
			end
		else
			options.setupFrame.data.debug = nil
		end
	end):Shown(module.db.debug)
	function self.setupFrame.debugCheck:ExtraShown()
		if IsAltKeyDown() and IsControlKeyDown() then
			return true
		end
	end


	self.setupFrame.SETUP_FRAMES_LIST = {
		priority = {
			[self.setupFrame.nameEdit] = 10,
			[self.setupFrame.msgSize] = 20,
			[self.setupFrame.msgEdit] = 30,
			[self.setupFrame.durEdit] = 40,
			[self.setupFrame.durRevese] = 45,
			[self.setupFrame.soundList] = 50,
			[self.setupFrame.soundCustom] = 60,
			[self.setupFrame.soundDelayEdit] = 65,
			[self.setupFrame.soundAfterList] = 70,
			[self.setupFrame.soundAfterCustom] = 80,
			[self.setupFrame.countdownCheck] = 90,
			[self.setupFrame.countdownType] = 100,
			[self.setupFrame.countdownTypeText] = 110,
			[self.setupFrame.countdownVoice] = 120,
			[self.setupFrame.copyCheck] = 130,
			[self.setupFrame.disableRewrite] = 140,
			[self.setupFrame.disableDynamicUpdates] = 150,
			[self.setupFrame.glowTypeEdit] = 160,
			[self.setupFrame.glowImage] = 170,
			[self.setupFrame.glowImageCustomEdit] = 180,
			[self.setupFrame.glowColorEdit] = 190,
			[self.setupFrame.glowThickEdit] = 200,
			[self.setupFrame.glowScaleEdit] = 210,
			[self.setupFrame.glowNEdit] = 220,
			[self.setupFrame.customOpt1] = 230,
			[self.setupFrame.debugCheck] = 240,
		},
		extra_margin = {
			[self.setupFrame.msgEdit] = 25,
		},
		parent = {
			[self.setupFrame.soundAfterCustom] = self.setupFrame.soundAfterList,
			[self.setupFrame.soundCustom] = self.setupFrame.soundList,
			[self.setupFrame.soundDelayEdit] = self.setupFrame.soundList,
		},
	}
	function self.setupFrame:RebuildSetupPage()
		local list = {}
		for frame,priority in pairs(self.SETUP_FRAMES_LIST.priority) do
			list[#list+1] = frame
		end
		sort(list,function(a,b) return self.SETUP_FRAMES_LIST.priority[a] < self.SETUP_FRAMES_LIST.priority[b] end)
		local prev
		if not self.data then
			self.data = {}
		end
		for _,frame in ipairs(list) do
			if frame.ExtraShown then
				if frame:ExtraShown() then
					frame:Show()
				else
					frame:Hide()
				end
			end
			if self.SETUP_FRAMES_LIST.parent[frame] and not self.SETUP_FRAMES_LIST.parent[frame]:IsShown() then
				frame:Hide()
			end
			if frame:IsShown() then
				if not prev then
					frame:NewPoint("TOPLEFT",self.tab.tabs[1],180,-10)
				else
					frame:NewPoint("TOPLEFT",prev,"BOTTOMLEFT",0,-5-(self.SETUP_FRAMES_LIST.extra_margin[prev] or 0))
				end
				prev = frame
			end
		end
	end
	self.setupFrame:RebuildSetupPage()


	self.setupFrame.disableCheck = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalDisable..":"):Point("TOPLEFT",350,-10):Left(5):OnClick(function(self)
		UpdateOption(options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,0))
	end)

	self.setupFrame.disableSound = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalSoundDisable..":"):Point("TOPLEFT",self.setupFrame.disableCheck,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		UpdateOption(options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,1))
	end)

	self.setupFrame.disableUpdates = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalUpdateDisable..":"):Point("TOPLEFT",self.setupFrame.disableSound,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		UpdateOption(options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,2))
	end)

	self.setupFrame.disableUpdatesSound = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalUpdateSoundDisable..":"):Point("TOPLEFT",self.setupFrame.disableUpdates,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		UpdateOption(options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,4))
	end)

	self.setupFrame.disableSynq = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderPersonalSendDisable..":"):Point("TOPLEFT",self.setupFrame.disableUpdatesSound,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		UpdateOption(options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,3))
	end)

	self.setupFrame.disableTimeLine = ELib:Check(self.setupFrame.tab.tabs[4],L.ReminderNotShowOnTimeline..":"):Point("TOPLEFT",self.setupFrame.disableSynq,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
		UpdateOption(options.setupFrame.data.uid,not self:GetChecked(),bit.lshift(1,5))
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
				self.setupFrame.bossCustom:SetText(encounterID)
				self.setupFrame.bossList:SetText(L.ReminderCustomEncounterID)
			end
			if encounterID ~= 0 then
				options.setupFrame.data.bossID = encounterID
			end
			options.setupFrame.tab.tabs[3].button.alert:Update()
			ELib:DropDownClose()
		end
		self.setupFrame.bossList.SetValue = bossList_SetValue

		List[#List+1] = {
			text = "-",
			func = bossList_SetValue,
		}
		local dungSubMenu = {}
		List[#List+1] = {
			text = DUNGEONS,
			subMenu = dungSubMenu,
			Lines = 20,
		}
		for i=1,#encountersList do
			local instance = encountersList[i]
			List[#List+1] = {
				text = type(instance[1])=='string' and instance[1] or GetMapNameByID(instance[1]) or "???",
				isTitle = true,
			}
			for j=2,#instance do
				local bossID, bossImg = instance[j]
				if ExRT.GDB.encounterIDtoEJ[bossID] and EJ_GetCreatureInfo then
					bossImg = select(5, EJ_GetCreatureInfo(1, ExRT.GDB.encounterIDtoEJ[bossID]))
				end
				List[#List+1] = {
					text = L.bossName[ bossID ],
					arg1 = bossID,
					func = bossList_SetValue,
					icon = bossImg,
					iconsize = 32,
				}
			end
		end
		local dungEncountersList = ExRT.F.GetEncountersList(false,false,true,true)
		for i=1,#dungEncountersList do
			local instance = dungEncountersList[i]
			dungSubMenu[#dungSubMenu+1] = {
				text = type(instance[1])=='string' and instance[1] or GetMapNameByID(instance[1]) or "???",
				isTitle = true,
			}
			for j=2,#instance do
				local bossID, bossImg = instance[j]
				if ExRT.GDB.encounterIDtoEJ[bossID] and EJ_GetCreatureInfo then
					bossImg = select(5, EJ_GetCreatureInfo(1, ExRT.GDB.encounterIDtoEJ[bossID]))
				end
				dungSubMenu[#dungSubMenu+1] = {
					text = L.bossName[ bossID ],
					arg1 = bossID,
					func = bossList_SetValue,
					icon = bossImg,
					iconsize = 32,
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
		if isUser then
			options.setupFrame.data.bossID = tonumber(self:GetText())
		end
		self:ExtraText(L.bossName[options.setupFrame.data.bossID or 0] or "")
		if isUser then
			options.setupFrame.tab.tabs[3].button.alert:Update()
		end
	end):Tooltip(function()
		if module.db.lastEncounterID then
			return L.ReminderEncounterIDLast..": "..module.db.lastEncounterID
		else
			return L.ReminderEncounterIDLastNoData
		end
	end)

	self.setupFrame.bossList.auto = ELib:Button(self.setupFrame.tab.tabs[3],L.ReminderAuto):Tooltip(L.ReminderEncounterIDLastAutoTip):Point("LEFT",self.setupFrame.bossList,"RIGHT",5,0):Size(40,20):OnClick(function()
		options.setupFrame.data.bossID = module.db.lastEncounterID
		options.setupFrame.tab.tabs[3].button.alert:Update()
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
			options.setupFrame.data.diffID = diffID
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
		options.setupFrame.data.zoneID = zoneID
		options.setupFrame.tab.tabs[3].button.alert:Update()
	end):Tooltip(function()
		local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
		return L.ReminderZoneIDTip1..(name or "")..L.ReminderZoneIDTip2..(instanceID or 0)
	end)

	self.setupFrame.zoneID.dd = ELib:DropDownButton(self,"",250,#ExRT.GDB.JournalInstance+3)
	self.setupFrame.zoneID.dd.isModern = true
	do
		local function SetZone(_,arg)
			options.setupFrame.data.zoneID = tostring(arg)
			ELib:DropDownClose()
			options.setupFrame.tab.tabs[3].button.alert:Update()
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
				tinsert(self.setupFrame.zoneID.dd.List, 2, {text = (line[1] == -1 and (EXPANSION_SEASON_NAME or "%s Season %d"):format(line.n or "?",line.s) or line[1] == -2 and "New" or _G["EXPANSION_NAME"..line[1]] or "Expansion "..line[1]),subMenu = subMenu})
			end
		end
	end
	self.setupFrame.zoneID.dd:Hide()

	self.setupFrame.zoneID.auto = ELib:Button(self.setupFrame.tab.tabs[3],LFG_LIST_SELECT or "Select"):Tooltip(L.ReminderZoneIDAutoTip):Point("LEFT",self.setupFrame.zoneID,"RIGHT",5,0):Size(40,20):OnClick(function()
		self.setupFrame.zoneID.dd:Click()
	end)

	self.setupFrame.zoneID.dd:SetAllPoints(self.setupFrame.zoneID.auto)

	ELib:DecorationLine(self.setupFrame.tab.tabs[3]):Point("TOP",self.setupFrame.zoneID,"BOTTOM",0,-5):Point("LEFT",self.setupFrame,0,0):Point("RIGHT",self.setupFrame,0,0):Size(0,1)

	self.setupFrame.allPlayersCheck = ELib:Check(self.setupFrame.tab.tabs[3],L.ReminderAllPlayers..":"):Point("TOPLEFT",self.setupFrame.zoneID,"BOTTOMLEFT",0,-10):Left(5):OnClick(function(self)
		if self:GetChecked() then
			options.setupFrame.data.allPlayers = true
		else
			options.setupFrame.data.allPlayers = nil
		end
	end)

	self.setupFrame.playersChecksFrame = ELib:ScrollFrame(self.setupFrame.tab.tabs[3]):Size(self.setupFrame:GetWidth(),25*6):Height(25*6):Point("LEFT",self.setupFrame.tab.tabs[3],0,0):Point("TOP",self.setupFrame.allPlayersCheck,"BOTTOM",0,-5)
	ELib:Border(self.setupFrame.playersChecksFrame,0)
	self.setupFrame.playersChecksFrame.ScrollBar:Minimal()

	self.setupFrame.playersChecks = {}
	function self.setupFrame.playersChecksFrame:GetCheck(i,j)
		if not options.setupFrame.playersChecks[i] then
			options.setupFrame.playersChecks[i] = {}
		end
		local chk = options.setupFrame.playersChecks[i][j]
		if not chk then
			chk = ELib:Check(options.setupFrame.playersChecksFrame.C,"Player "..((i-1)*5+j)):Point("LEFT",10+(j-1)*100,0):Point("TOP",0,-(i-1)*25-1):OnClick(function(self)
				if self:GetChecked() then
					options.setupFrame.data.players[self.playerName] = true
				else
					options.setupFrame.data.players[self.playerName] = nil
				end
				options.setupFrame.data.allPlayers = nil
				options.setupFrame.allPlayersCheck:SetChecked(false)
			end)
			options.setupFrame.playersChecks[i][j] = chk
			chk.text:SetWidth(80)
			chk.text:SetJustifyH("LEFT")
			chk.playerName = "Player "..((i-1)*5+j)
		end
		return chk
	end

	self.setupFrame.playersChecksList = {}

	function self.setupFrame:UpdatePlayersChecks()
		wipe(self.playersChecksList)

		local g,gmax = {},0
		if (options.tab.selected == 5 or options.tab.selected == 5) and VMRT.Reminder2.OptAssigLastQuick == 4 then
			local c = 0
			for i=1,#VMRT.Reminder2.CustomRoster do
				local name, class, role = unpack(VMRT.Reminder2.CustomRoster[i])
	
				if name and class then 
					c = c + 1
					local subgroup = floor((c - 1) / 5) + 1
	
					if not g[subgroup] then
						g[subgroup] = 0
					end
					if gmax < subgroup then gmax = subgroup end
					g[subgroup] = g[subgroup]+1

					name = ExRT.F.delUnitNameServer(name)
					
					local classColor = RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr or ""
					local chk = self.playersChecksFrame:GetCheck(subgroup,g[subgroup])
					chk:SetText(classColor..name)
					chk:SetChecked(false)
					chk.playerName = name
					chk:Show()

					self.playersChecksList[name] = chk
				end
	
			end
		else
			for _, name, subgroup, class, guid, rank, level, online, isDead, combatRole in ExRT.F.IterateRoster do
				if not g[subgroup] then
					g[subgroup] = 0
				end
				if gmax < subgroup then gmax = subgroup end
				g[subgroup] = g[subgroup]+1
				if g[subgroup] <= 5 then
					name = ExRT.F.delUnitNameServer(name)

					local classColor = RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr and "|c"..RAID_CLASS_COLORS[class].colorStr or ""
					local chk = self.playersChecksFrame:GetCheck(subgroup,g[subgroup])
					chk:SetText(classColor..name)
					chk:SetChecked(false)
					chk.playerName = name
					chk:Show()

					self.playersChecksList[name] = chk
				end
			end
		end
		for i=1,#self.playersChecks do
			for j=(g[i] or 0)+1,5 do
				self.playersChecksFrame:GetCheck(i,j):Hide()
			end
		end

		self.playersChecksFrame:Height(gmax*25)
		self.playersChecksFrame.ScrollBar:SetValue(0)
		if gmax > 6 then
			self.playersChecksFrame.ScrollBar:Show()
		elseif self.playersChecksFrame.ScrollBar:IsShown() then
			self.playersChecksFrame.ScrollBar:Hide()
		end

	end

	self.setupFrame.customPlayerList = ELib:Edit(self.setupFrame.tab.tabs[3]):Size(270,20):Point("TOPLEFT",self.setupFrame.allPlayersCheck,"BOTTOMLEFT",0,-5-150):LeftText(L.ReminderPlayerNames..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local inRaid = {}
		for _,name in ExRT.F.IterateRoster do
			inRaid[ExRT.F.delUnitNameServer(name)] = true
		end
		for k,v in pairs(options.setupFrame.data.players) do
			if not inRaid[k] then
				options.setupFrame.data.players[k] = nil
			end
		end
		local names = {strsplit(" ",self:GetText():gsub(" +"," "):trim(),nil)}
		for i=1,#names do
			options.setupFrame.data.players[ names[i] ]=true
		end
		if #names > 0 then
			options.setupFrame.data.allPlayers = nil
			options.setupFrame.allPlayersCheck:SetChecked(false)
		end
	end):Tooltip(L.ReminderPlayerNamesTip)

	self.setupFrame.notePatternEdit = ELib:Edit(self.setupFrame.tab.tabs[3]):Size(270,20):Point("TOPLEFT",self.setupFrame.customPlayerList,"BOTTOMLEFT",0,-5):LeftText(L.ReminderNotePatt..":"):OnChange(function(self,isUser)
		if not isUser then return end
		local text = self:GetText():trim()
		if text == "" then text = nil end
		options.setupFrame.data.notePattern = text
		if text ~= nil then
			options.setupFrame.data.allPlayers = nil
			options.setupFrame.allPlayersCheck:SetChecked(false)
		end
	end):Tooltip(function()
		local str = L.ReminderNotePattTip1
		local isOkay,list = pcall(module.FindPlayersListInNote,0,options.setupFrame.data.notePattern)
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
				options.setupFrame.data["role"..self.token] = true
			else
				options.setupFrame.data["role"..self.token] = nil
			end
			options.setupFrame.data.allPlayers = nil
			options.setupFrame.allPlayersCheck:SetChecked(false)
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
				options.setupFrame.data["class"..self.token] = true
			else
				options.setupFrame.data["class"..self.token] = nil
			end
			options.setupFrame.data.allPlayers = nil
			options.setupFrame.allPlayersCheck:SetChecked(false)
		end)
		self.setupFrame.classChecks[j] = chk
		chk.text:SetWidth(80)
		chk.text:SetJustifyH("LEFT")

		chk.token = class
	end

	ELib:DecorationLine(self.setupFrame.tab.tabs[3]):Point("TOP",self.setupFrame.classChecks[1],"BOTTOM",0,-5-50):Point("LEFT",self.setupFrame,0,0):Point("RIGHT",self.setupFrame,0,0):Size(0,1)

	self.setupFrame.neverCheck = ELib:Check(self.setupFrame.tab.tabs[3],L.ReminderDisable..":"):Point("LEFT",self.setupFrame.allPlayersCheck,"LEFT",0,0):Point("TOP",self.setupFrame.classChecks[1],"BOTTOM",0,-10-50):Left(5):OnClick(function(self)
		if self:GetChecked() then
			options.setupFrame.data.disabled = true
		else
			options.setupFrame.data.disabled = nil
		end
	end):Tooltip(L.ReminderDisableTip)



	self.setupFrame.triggersScrollFrame = ELib:ScrollFrame(self.setupFrame.tab.tabs[2]):Point("TOP",0,0):Size(510,SETUPFRAME_HEIGHT-75):Height(SETUPFRAME_HEIGHT-80)
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

		local heightNow = 5 + 30 + (30 + (options.setupFrame.triggersScrollFrame.generalOptions.sub:IsShown() and (options.setupFrame.triggersScrollFrame.generalOptions.HEIGHT or 10) or 1))
		for _,t in pairs(options.setupFrame.triggersScrollFrame.triggers) do
			if t:IsShown() then
				local height = t.HEIGHT or 10
				heightNow = heightNow + 5 + 30 + (t.sub:IsShown() and height or 1)
			end
		end
		options.setupFrame.triggersScrollFrame:Height(heightNow)
	end

	function self.setupFrame.UpdateTriggerAlerts(button)
		local triggerData = options.setupFrame.data.triggers[button.num]
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
				if b.repTipText == 0 then b.repTipText = nil end
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
				b.repTipText = b.tooltipText or 0
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

		button.HEIGHT = 5 + 25 * 5

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
				options.setupFrame.data.delayedActivation = text
			end
			if options.setupFrame.data.delayedActivation then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end)
		self.setupFrame.delayedActivation.Background:SetColorTexture(1,1,1,1)


		self.setupFrame.hideTextChangedCheck = ELib:Check(button.sub,L.ReminderHideTextAfterStatus..":"):Point("TOPLEFT",self.setupFrame.delayedActivation,"BOTTOMLEFT",0,-5):Left(5):Tooltip(L.ReminderHideTextAfterStatusTip):OnClick(function(self)
			if self:GetChecked() then
				options.setupFrame.data.hideTextChanged = true
			else
				options.setupFrame.data.hideTextChanged = nil
			end
		end)

		self.setupFrame.sametargetsCheck = ELib:Check(button.sub,L.ReminderSameTarget..":"):Point("TOPLEFT",self.setupFrame.hideTextChangedCheck,"BOTTOMLEFT",0,-5):Left(5):Tooltip(L.ReminderSameTargetTooltip):OnClick(function(self)
			if self:GetChecked() then
				options.setupFrame.data.sametargets = true
			else
				options.setupFrame.data.sametargets = nil
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
			options.setupFrame.data.specialTarget = text
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
			options.setupFrame.data.extraCheck = text
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

			options.setupFrame.data.triggers[button.num].andor = self.state

			self:GetScript("OnLeave")(self)
			self:GetScript("OnEnter")(self)
		end):OnEnter(function(self)
			local triggers = options.setupFrame.data.triggers
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
			triggersStr = (opened and "(" or "")..(options.setupFrame.data.triggers[1].invert and "!" or "").."1"..triggersStr

			if options.setupFrame.data.triggers[button.num].andor == 4 then
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
				options.setupFrame.data.triggers[button.num].event = arg1

				if arg1 == 1 then
					if not options.setupFrame.data.triggers[button.num].eventCLEU then
						options.setupFrame.data.triggers[button.num].eventCLEU = "SPELL_CAST_SUCCESS"
					end
					options.setupFrame:UpdateTriggerFieldsForEvent(button,options.setupFrame.data.triggers[button.num].eventCLEU or "SPELL_CAST_SUCCESS")
				else
					options.setupFrame:UpdateTriggerFieldsForEvent(button,arg1)
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
				options.setupFrame.data.triggers[button.num].eventCLEU = arg1
				options.setupFrame:UpdateTriggerFieldsForEvent(button,arg1)
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
				options.setupFrame.data.triggers[button.num].sourceName = text
			end
			if options.setupFrame.data.triggers[button.num].sourceName then
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
				options.setupFrame.data.triggers[button.num].sourceID = text
			end
			if options.setupFrame.data.triggers[button.num].sourceID then
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
				options.setupFrame.data.triggers[button.num].sourceUnit = arg1
				local val = ExRT.F.table_find3(module.datas.units,arg1,1)
				if type(arg1) == "number" and arg1 < 0 then
					button.sourceUnit:SetText(L.ReminderSourceUnit1.." "..(-arg1))
				elseif val then
					button.sourceUnit:SetText(val[2] or val[1])
				else
					button.sourceUnit:SetText(arg1)
				end
				button:UpdateTriggerAlerts()

				if options.setupFrame.data.triggers[button.num].sourceUnit then
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
				local triggers = options.setupFrame.data.triggers
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
				options.setupFrame.data.triggers[button.num].sourceMark = arg1
				local val = ExRT.F.table_find3(module.datas.marks,arg1,1)
				if val then
					button.sourceMark:SetText(val[2])
				else
					button.sourceMark:SetText(arg1)
				end

				if options.setupFrame.data.triggers[button.num].sourceMark then
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
				options.setupFrame.data.triggers[button.num].targetName = text
			end
			if options.setupFrame.data.triggers[button.num].targetName then
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
				options.setupFrame.data.triggers[button.num].targetID = text
			end
			if options.setupFrame.data.triggers[button.num].targetID then
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
				options.setupFrame.data.triggers[button.num].targetUnit = arg1
				local val = ExRT.F.table_find3(module.datas.units,arg1,1)
				if type(arg1) == "number" and arg1 < 0 then
					button.targetUnit:SetText(L.ReminderSourceUnit1.." "..(-arg1))
				elseif val then
					button.targetUnit:SetText(val[2] or val[1])
				else
					button.targetUnit:SetText(arg1)
				end
				button:UpdateTriggerAlerts()

				if options.setupFrame.data.triggers[button.num].targetUnit then
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
				local triggers = options.setupFrame.data.triggers
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
				options.setupFrame.data.triggers[button.num].targetMark = arg1
				local val = ExRT.F.table_find3(module.datas.marks,arg1,1)
				if val then
					button.targetMark:SetText(val[2])
				else
					button.targetMark:SetText(arg1)
				end

				if options.setupFrame.data.triggers[button.num].targetMark then
					button.targetMark.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
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
				options.setupFrame.data.triggers[button.num].targetRole = arg1
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

				if options.setupFrame.data.triggers[button.num].targetRole then
					button.targetRole.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
				else
					button.targetRole.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
				end
			end
			button.targetRole.SetValue = role_SetValue

			local function role_SetCheck(self,checkState)
				local val = options.setupFrame.data.triggers[button.num].targetRole or 0
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
				local t = options.setupFrame.data.triggers[button.num]
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
				options.setupFrame.data.triggers[button.num].spellID = tonumber(self:GetText())
				button:UpdateTriggerAlerts()
			end
			if options.setupFrame.data.triggers[button.num].spellID then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(function(self)
			local t = options.setupFrame.data.triggers[button.num]
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
				options.setupFrame.data.triggers[button.num].spellName = text
				button:UpdateTriggerAlerts()
			end
			if options.setupFrame.data.triggers[button.num].spellName then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end)
		button.spellName.Background:SetColorTexture(1,1,1,1)

		button.extraSpellID = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.spellName,"BOTTOMLEFT",0,-5):LeftText(L.ReminderSpellIDExtra..":"):OnChange(function(self,isUser)
			if isUser then
				options.setupFrame.data.triggers[button.num].extraSpellID = tonumber(self:GetText())
			end
			if options.setupFrame.data.triggers[button.num].extraSpellID then
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
				options.setupFrame.data.triggers[button.num].stacks = text
				button:UpdateTriggerAlerts()
			end
			if options.setupFrame.data.triggers[button.num].stacks then
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
				options.setupFrame.data.triggers[button.num].numberPercent = text
				button:UpdateTriggerAlerts()
			end
			if options.setupFrame.data.triggers[button.num].numberPercent then
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
				options.setupFrame.data.triggers[button.num].pattFind = text
				button:UpdateTriggerAlerts()
			end
			if options.setupFrame.data.triggers[button.num].pattFind then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(function(self)
			local t = options.setupFrame.data.triggers[button.num]
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
				options.setupFrame.data.triggers[button.num].bwtimeleft = tonumber(self:GetText())
				button:UpdateTriggerAlerts()
			end
			if options.setupFrame.data.triggers[button.num].bwtimeleft then
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
				options.setupFrame.data.triggers[button.num].counter = text
			end
			if options.setupFrame.data.triggers[button.num].counter then
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
				options.setupFrame.data.triggers[button.num].cbehavior = arg1
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
				options.setupFrame.data.triggers[button.num].delayTime = text
			end
			if options.setupFrame.data.triggers[button.num].delayTime then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(L.ReminderDelayTooltip)
		button.delayTime.Background:SetColorTexture(1,1,1,1)

		button.activeTime = ELib:Edit(button.sub):Size(270,20):Point("TOPLEFT",button.delayTime,"BOTTOMLEFT",0,-5):LeftText(L.ReminderActiveTime..":"):OnChange(function(self,isUser)
			if isUser then
				options.setupFrame.data.triggers[button.num].activeTime = tonumber(self:GetText())
			end
			if options.setupFrame.data.triggers[button.num].activeTime then
				self.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
			else
				self.Background:SetVertexColor(unpack(COLOR_BORDER_EMPTY))
			end
		end):Tooltip(L.ReminderActiveTimeTooltip)
		button.activeTime.Background:SetColorTexture(1,1,1,1)

		button.invert = ELib:Check(button.sub,L.ReminderInvert..":"):Point("TOPLEFT",button.activeTime,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self)
			if self:GetChecked() then
				options.setupFrame.data.triggers[button.num].invert = true
			else
				options.setupFrame.data.triggers[button.num].invert = nil
			end
		end):Tooltip(L.ReminderInvertTooltip)

		button.guidunit = ELib:DropDown(button.sub,220,2):AddText("|cffffd100"..L.ReminderTriggerUnit..":"):Size(270):Point("TOPLEFT",button.invert,"BOTTOMLEFT",0,-5):Tooltip(L.ReminderTriggerUnitTooltip)
		button.guidunit.Background:SetColorTexture(1,1,1,1)
		button.guidunit.Background:SetGradient("HORIZONTAL",unpack(COLOR_BORDER_FULL))
		do
			local function guidunit_SetValue(_,arg1)
				ELib:DropDownClose()
				options.setupFrame.data.triggers[button.num].guidunit = arg1
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
				options.setupFrame.data.triggers[button.num].onlyPlayer = true
			else
				options.setupFrame.data.triggers[button.num].onlyPlayer = nil
			end
		end):Tooltip(L.ReminderTargetIsPlayerTip)

		button.HEIGHT = 10

		return button
	end

	self.setupFrame.triggersScrollFrame.addTrigger = ELib:Button(self.setupFrame.triggersScrollFrame.C,L.ReminderAddTrigger):Size(480,20):Point("BOTTOM",0,5):OnClick(function(self)
		options.setupFrame.data.triggers[#options.setupFrame.data.triggers+1] = {
			event = 1,
			eventCLEU = "SPELL_CAST_SUCCESS",
		}
		options.setupFrame:Update(options.setupFrame.data)
	end)

	function self.setupFrame:Update(data)
		self.data = data

		self.setup = true

		self.nameEdit:SetText(data.name or "")
		self.msgEdit:SetText(data.msg or "")
		self.msgSize:SetValue(data.msgSize)
		self.durEdit:SetText(data.dur or "")
		self.durRevese:SetChecked(data.durrev)
		self.countdownCheck:SetChecked(data.countdown)
		self.countdownCheck:GetScript("OnClick")(self.countdownCheck)
		self.countdownType:SetValue(data.countdownType)
		self.copyCheck:SetChecked(data.copy)
		self.sametargetsCheck:SetChecked(data.sametargets)
		self.hideTextChangedCheck:SetChecked(data.hideTextChanged)
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
		
		--data.sound 
		self.soundList:Update()
		--data.soundafter
		self.soundAfterList:Update()
		self.soundDelayEdit:SetText(data.sounddelay or "")

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
		for i=1,#module.datas.rolesList do
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

		local roptions = VMRT.Reminder2.options[data.uid or 0] or 0
		self.disableCheck:SetChecked(bit.band(roptions,bit.lshift(1,0)) > 0)
		self.disableSound:SetChecked(bit.band(roptions,bit.lshift(1,1)) > 0)
		self.disableUpdates:SetChecked(bit.band(roptions,bit.lshift(1,2)) > 0)
		self.disableUpdatesSound:SetChecked(bit.band(roptions,bit.lshift(1,4)) > 0)
		self.disableSynq:SetChecked(bit.band(roptions,bit.lshift(1,3)) > 0)
		self.disableTimeLine:SetChecked(bit.band(roptions,bit.lshift(1,5)) > 0)

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
		local l = str:sub(1,2) == "EX" and 9 or 8
		local header = str:sub(1,l)
		if not (header:sub(1,l) == "EXRTREMH" or header:sub(1,l) == "MRTREMH") or (header:sub(l,l) ~= "0" and header:sub(l,l) ~= "1") then
			print("Import: wrong format")
			return
		end

		options.setupFrame.historyFrame:TextToHistory(str:sub(l+1),header:sub(l,l)=="0")
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
			options:ImportToHistory(res)
		else
			print("Import error")
		end
	end

	self.setupFrame.historyFrame.trigger = ELib:DropDown(self.setupFrame.historyFrame,100,5):AddText("|cffffd100"..L.ReminderFastSetupForTrigger..":"):Size(100):Point("TOPLEFT",250,-5):SetText("1")
	function self.setupFrame.historyFrame.trigger:PreUpdate()
		local List = self.List
		wipe(List)
		for i=1,#options.setupFrame.data.triggers do
			List[#List+1] = {
				text = L.ReminderTrigger.." "..i,
				arg1 = i,
				func = function(_,arg1)
					ELib:DropDownClose()
					options.setupFrame.historyFrame.trigger:SetText(arg1)
					options.setupFrame.historyFrame.TRIGGER = i

					options.setupFrame.historyFrame.tab.tabs[1].timelineScrollFrame:ResetActiveNavigation()
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
			options.setupFrame.historyFrame:SetWidth(450)
			self.tabs[1].timelineScrollFrame.filterDropDown:SetParent(self.tabs[1])
			self.tabs[1].timelineScrollFrame.filterDropDown:NewPoint("BOTTOMRIGHT",'x',"TOPRIGHT",-20,1)
		elseif tabID == 2 then
			options.setupFrame.historyFrame:SetWidth(580)
			self.tabs[1].timelineScrollFrame.filterDropDown:SetParent(self.tabs[2])
			self.tabs[1].timelineScrollFrame.filterDropDown:NewPoint("BOTTOMRIGHT",'x',"TOPRIGHT",-20,1)
		elseif tabID == 3 then
			options.setupFrame.historyFrame:SetWidth(450)
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
		local tabID = options.setupFrame.historyFrame.tab.selected
		local List = self.List
		wipe(List)
		local subMenu = {}
		for _, h_key in pairs({"history","historySession"}) do
			for i=1,#module.db[h_key] do
				if i==1 and #subMenu > 0 then
					subMenu[#subMenu+1] = {
						text = " ",
						isTitle = true,
					}
				end

				local fight = module.db[h_key][i]
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
		end
		subMenu[#subMenu+1] = {
			text = " ",
			isTitle = true,
		}
		subMenu[#subMenu+1] = {
			text = L.ReminderFightExport,
			func = function()
				ELib:DropDownClose()

				local str = options:GetHistoryString()

				local compressed
				if #str < 1000000 then
					compressed = LibDeflate:CompressDeflate(str,{level = 5})
				end
				local encoded = "MRTREMH"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or str)

				options.setupFrame.historyFrame.exportWindow.Edit:SetText(encoded)
				options.setupFrame.historyFrame.exportWindow:Show()
			end,
		}
		subMenu[#subMenu+1] = {
			text = L.ReminderFightImport,
			func = function()
				ELib:DropDownClose()

				options.setupFrame.historyFrame.importWindow:NewPoint("CENTER",UIParent,0,0)
				options.setupFrame.historyFrame.importWindow:Show()
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
				wipe(module.db.historySession)
				module.db.history[1] = {}
				module.db.historySession[1] = {}
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
							options.setupFrame.historyFrame.tab.tabs[2].historyList:Update2("prev",arg1)
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
			local frame = tabID == 1 and timelineFrame or options.setupFrame.historyFrame.tab.tabs[2].historyList
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

	timelineContent.line_onupdate_func = function(self,button)
		if self:IsMouseOver() and not self.IsHovered then
			self.parent:SetColorTexture(.24,.75,.30,1)
			self.IsHovered = true
		elseif not self:IsMouseOver() and self.IsHovered then
			self.parent:SetColorTexture(.24,.25,.30,1)
			self.IsHovered = false
		end
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

		timelineContent[key].button:SetScript("OnUpdate",timelineContent.line_onupdate_func)
	end

	timelineContent.pull.button:SetScript("OnClick",function(self,button)
		timelineFrame:ResetActiveNavigation()
		if button == "RightButton" then
			return
		end
		local x = ExRT.F.GetCursorPos(self)
		local t = max((x - TIMELINE_FRAME_WIDTH / 2) / timelineFrame.PIX_PER_SEC,0)

		local trigger = options.setupFrame.data.triggers[options.setupFrame.historyFrame.TRIGGER]
		if trigger then
			trigger.event = 3
			trigger.delayTime = t < 60 and (floor(t * 10)/10) or format("%d:%02d.%d",t/60,t%60,t%1*10)
			options.setupFrame:Update(options.setupFrame.data)
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

		local trigger = options.setupFrame.data.triggers[options.setupFrame.historyFrame.TRIGGER]
		if trigger then
			trigger.event = 2
			trigger.delayTime = t < 60 and (floor(t * 10)/10) or format("%d:%02d.%d",t/60,t%60,t%1*10)
			trigger.pattFind = tostring(phaseText)
			trigger.counter = count and tostring(count) or nil
			trigger.cbehavior = nil
			options.setupFrame:Update(options.setupFrame.data)
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
			local trigger = options.setupFrame.data.triggers[options.setupFrame.historyFrame.TRIGGER]
			if trigger then
				if t2 < 0 then
					trigger.delayTime = nil
				else
					trigger.delayTime = t2 < 60 and (floor(t2 * 10)/10) or format("%d:%02d.%d",t2/60,t2%60,t2%1*10)
				end
				options.setupFrame:Update(options.setupFrame.data)
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

		local trigger = options.setupFrame.data.triggers[options.setupFrame.historyFrame.TRIGGER]
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

			options.setupFrame:Update(options.setupFrame.data)
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

		local trigger = options.setupFrame.data.triggers[options.setupFrame.historyFrame.TRIGGER]
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

			options.setupFrame:Update(options.setupFrame.data)
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
			local name = GetSpellName(line[12])
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

		local trigger = options.setupFrame.data.triggers[options.setupFrame.historyFrame.TRIGGER]
		if not trigger then
			return
		end
		if index == 4 then
			local t = tdata.timeFromStart
			trigger.event = 3
			trigger.delayTime = t < 60 and (floor(t * 10)/10) or format("%d:%02d.%d",t/60,t%60,t%1*10)
			options.setupFrame:Update(options.setupFrame.data)
		elseif index == 5 then
			local t = tdata.timeFromPhase
			trigger.event = 2
			trigger.delayTime = t < 60 and (floor(t * 10)/10) or format("%d:%02d.%d",t/60,t%60,t%1*10)
			trigger.pattFind = tostring(tdata.phase)
			trigger.counter = tdata.phaseCount and tostring(tdata.phaseCount) or nil
			trigger.cbehavior = nil
			options.setupFrame:Update(options.setupFrame.data)
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

			options.setupFrame:Update(options.setupFrame.data)
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
		local trigger = options.setupFrame.data.triggers[options.setupFrame.historyFrame.TRIGGER]
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

			options.setupFrame:Update(options.setupFrame.data)
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

	local function GetRandom(t)
		local n = {}
		for k in pairs(t) do
			n[#n+1] = k
		end
		if #n == 0 then
			return
		end
		return n[math.random(1,#n)]
	end

	self.setupFrame.testData_RunTrigger = function(self,button)
		if button == "RightButton" then
			self.trigger.count = 0
		end
		if self.trigger.status then
			local target = UnitGUID'target'
			if target then
				module:DeactivateTrigger(self.trigger, target, false, true)
			else
				for uid in pairs(self.trigger.active) do
					module:DeactivateTrigger(self.trigger, uid, false, true)
				end
			end
		else
			local new
			local triggerID = self.trigger._trigger.event
			local eventData = module.C[triggerID]
			if eventData.subEventField and self.trigger._trigger[eventData.subEventField] then
				eventData = module.C[ self.trigger._trigger[eventData.subEventField] ]
			end
			if eventData.testVals then
				new = ExRT.F.table_copy2(eventData.testVals)
			else
				new = {}
			end
			module:AddTriggerCounter(self.trigger)

			new.counter = self.trigger.count
			new.sourceName = self.trigger.DsourceName and GetRandom(self.trigger.DsourceName) or self.trigger._trigger.sourceName or UnitName'player'
			new.targetName = self.trigger.DtargetName and GetRandom(self.trigger.DtargetName) or self.trigger._trigger.targetName or UnitName'target' or UnitName'player'
			new.spellID = self.trigger._trigger.spellID or 17
			new.spellName = self.trigger._trigger.spellName or GetSpellName(17) or "PW:S"
			new.sourceGUID = UnitGUID'player'
			new.targetGUID = UnitGUID'target' or new.sourceGUID
			if new.targetGUID then new.guid = new.targetGUID end
			if self.trigger._trigger.sourceMark then new.sourceMark = self.trigger._trigger.sourceMark end
			if self.trigger._trigger.targetMark then new.targetMark = self.trigger._trigger.targetMark end
			if self.trigger._trigger.bwtimeleft then new.timeLeft = GetTime() + self.trigger._trigger.bwtimeleft end
			if self.trigger.Dstacks then new.stacks = 1 end
			if self.trigger._trigger.text then new.text = self.trigger._trigger.text else new.text = "^_^" end
			if self.trigger.DnumberPercent then new.value = 910 new.health = 91 end

			module:RunTrigger(self.trigger, new, true)

			self:GetScript("OnEnter")(self)
		end
	end

	self.setupFrame.testData_TriggerButtonOnEnter = function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Current counter: "..self.trigger.count)
		GameTooltip:AddLine("Right Click for reset")
		GameTooltip:Show()
	end
	self.setupFrame.testData_TriggerButtonOnLeave = function(self)
		GameTooltip_Hide()
	end

	self.setupFrame.updateTestData = function()
		local uid = options.setupFrame.data.uid
		if not uid then
			for i=1,#self.setupFrame.triggerTestButtons do
				local button = self.setupFrame.triggerTestButtons[i]
				if button:IsShown() then
					button:Hide()
				end
			end
			if self.setupFrame.testLoadButton.status ~= 1 then 
				self.setupFrame.testLoadButton:SetText("Reminder not saved")
				self.setupFrame.testLoadButton:Disable()
				self.setupFrame.testLoadButton.status = 1
			end
			return
		end
		for i=1,#reminders do
			if reminders[i].data.uid == uid then
				for j=1,#reminders[i].triggers do
					local trigger = reminders[i].triggers[j]
	
					local button = self.setupFrame.triggerTestButtons[j]
					if not button then
						button = ELib:Button(self.setupFrame.tab.tabs[5],"Trigger "..j):Size(490,20):OnClick(self.setupFrame.testData_RunTrigger):OnEnter(self.setupFrame.testData_TriggerButtonOnEnter):OnLeave(self.setupFrame.testData_TriggerButtonOnLeave):Run(function(self) self:RegisterForClicks("LeftButtonUp","RightButtonUp") end)
						if j == 1 then
							button:Point("TOPLEFT",self.setupFrame.testLoadButton,"BOTTOMLEFT",0,-5)
						else
							button:Point("TOPLEFT",self.setupFrame.triggerTestButtons[j-1],"BOTTOMLEFT",0,-5)
						end
						self.setupFrame.triggerTestButtons[j] = button
					end
					button.trigger = trigger
					if not button:IsShown() then
						button:Show()
					end
					if trigger.status then
						button:SetText("Deactivate Trigger "..j.." (Current status: |cff00ff00ON|r)")
					else
						button:SetText("Activate Trigger "..j..((trigger.untimed or trigger._trigger.activeTime) and " (Current status: |cffff0000OFF|r)" or " (Trigger with instant deactivation)"))
					end
				end
				for j=#reminders[i].triggers+1,#self.setupFrame.triggerTestButtons do
					local button = self.setupFrame.triggerTestButtons[j]
					if button:IsShown() then
						button:Hide()
					end
				end
				local isOutdated = ExRT.F.table_compare(options.setupFrame.data,reminders[i].data) ~= 1
				if self.setupFrame.testLoadButton.status ~= 2 and not isOutdated then 
					self.setupFrame.testLoadButton:SetText("Already loaded")
					self.setupFrame.testLoadButton:Disable()
					self.setupFrame.testLoadButton.status = 2
				end
				if self.setupFrame.testLoadButton.status ~= 4 and isOutdated then 
					self.setupFrame.testLoadButton:SetText("Already loaded (loaded reminder is outdated. Save current for update)")
					self.setupFrame.testLoadButton:Disable()
					self.setupFrame.testLoadButton.status = 4
				end
				return
			end
		end
		for i=1,#self.setupFrame.triggerTestButtons do
			local button = self.setupFrame.triggerTestButtons[i]
			if button:IsShown() then
				button:Hide()
			end
		end
		if self.setupFrame.testLoadButton.status ~= 3 and not options.setupFrame.data.disabled then 
			self.setupFrame.testLoadButton:SetText("Load Reminder")
			self.setupFrame.testLoadButton:Enable()
			self.setupFrame.testLoadButton.status = 3
		end
		if self.setupFrame.testLoadButton.status ~= 5 and options.setupFrame.data.disabled then 
			self.setupFrame.testLoadButton:SetText("Reminder Disabled")
			self.setupFrame.testLoadButton:Disable()
			self.setupFrame.testLoadButton.status = 5
		end
	end

	self.setupFrame.testLoadButton = ELib:Button(self.setupFrame.tab.tabs[5],"Load Reminder"):Point("TOPLEFT",10,-30):Size(490,20):OnClick(function()
		local uid = options.setupFrame.data.uid
		if not uid then
			print(L.ReminderAlertNoCopyEmpty)
			return
		end
		module:LoadOneReminder(uid)
	end):OnUpdate(function()
		self.setupFrame.updateTestData()
	end)

	self.setupFrame.testPageHelp = CreateAlertIcon(self.setupFrame.tab.tabs[5],nil,nil,nil,true)
	self.setupFrame.testPageHelp:SetPoint("TOP",0,-5)
	self.setupFrame.testPageHelp:SetType(3)
	self.setupFrame.testPageHelp:Show()
	self.setupFrame.testPageHelp:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("You can manually activate triggers by yourself for test purposes.")
		GameTooltip:AddLine("But note that most information (such as names, IDs, marks, etc.) available only for real events.")
		GameTooltip:AddLine("Your current target (if exists) will be used for target data for some type of triggers.")
		GameTooltip:Show()
	end)

	self.setupFrame.triggerTestButtons = {}


	ELib:DecorationLine(self.tab.tabs[3],true,"BACKGROUND",1):Point("TOPLEFT",self,0,-50):Point("BOTTOMRIGHT",self,"TOPRIGHT",0,-70)

	self.options_tab = ELib:Tabs(self.tab.tabs[3],0,GENERAL_LABEL,L.cd2Appearance,TUTORIAL_TITLE19):Point(0,-25):Size(698,570):SetTo(1)
	self.options_tab:SetBackdropBorderColor(0,0,0,0)
	self.options_tab:SetBackdropColor(0,0,0,0)

	self.chkLock = ELib:Check(self.options_tab.tabs[1],L.ReminderTestMode..":",false):Point(310,-10):Left(5):OnClick(function(self) 
		frame.unlocked = self:GetChecked()
		module:UpdateVisual()

		options.chkLock2:SetChecked(self:GetChecked())
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

	self.chkDebug = ELib:Check(self.options_tab.tabs[1],"Debug mode",false):Point(450,-40):OnClick(function(self) 
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


	self.optionWidgets = ELib:Tabs(self.options_tab.tabs[2],0,L.ReminderAppText,L.ReminderAppGlow,L.ReminderAppBars):Point("TOP",0,-30):Point("LEFT",self.tab.tabs[3],10,0):Size(678,155):SetTo(1)
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

	self.optTimerExcluded = ELib:Check(self.optionWidgets.tabs[1],L.ReminderTimeExcluded,not VMRT.Reminder2.FontTimerExcluded):Point("LEFT",self.dropDownFontAdj,"RIGHT",5,0):OnClick(function(self) 
		VMRT.Reminder2.FontTimerExcluded = not self:GetChecked()
		module:UpdateVisual()
	end)

	self.optGrowUp = ELib:Check(self.optionWidgets.tabs[1],L.ReminderGrowUp..":",VMRT.Reminder2.GrowUp):Point("TOPLEFT",self.dropDownFontAdj,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self) 
		VMRT.Reminder2.GrowUp = self:GetChecked()
		module:UpdateVisual()
	end)

	self.optIconSizeCustom = ELib:Check(self.optionWidgets.tabs[1],"Use custom icon size in text:",VMRT.Reminder2.IconSizeCustom):Point("TOPLEFT",self.optGrowUp,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self) 
		VMRT.Reminder2.IconSizeCustom = self:GetChecked()
		module:UpdateVisual()
	end)
	self.sliderIconSize = ELib:Slider(self.optionWidgets.tabs[1],""):Size(320-30):Point("LEFT",self.optIconSizeCustom,"RIGHT",5,0):Range(6,200):SetTo(VMRT.Reminder2.IconSizeCustomSize or 20):OnChange(function(self,event) 
		event = floor(event + .5)
		VMRT.Reminder2.IconSizeCustomSize = event
		module:UpdateVisual()
		self.tooltipText = event
		self:tooltipReload(self)
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

	self.chkLock2 = ELib:Check(self.options_tab.tabs[2],L.ReminderTestMode,false):Point(330,20):OnClick(function(self) 
		frame.unlocked = self:GetChecked()
		module:UpdateVisual()

		options.chkLock:SetChecked(self:GetChecked())
	end)

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

	self.sliderFontSizeRaidframe = ELib:Slider(self.optionWidgets.tabs[2],""):Size(320):Point(190,-65):Range(5,80):SetTo(VMRT.Reminder2.TextSizeRaidframe or 12):OnChange(function(self,event) 
		event = floor(event + .5)
		VMRT.Reminder2.TextSizeRaidframe = event
		module:UpdateVisual()
		module:ReloadAll()
		if event == 5 then event = "Auto" end
		self.tooltipText = event
		self:tooltipReload(self)
	end)
	self.sliderFontSizeRaidframe.Low:SetText("Auto")
	ELib:Text(self.optionWidgets.tabs[2],L.ReminderFontSize..":",11):Point("RIGHT",self.sliderFontSizeRaidframe,"LEFT",-5,0):Color(1,.82,0,1):Right()


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

	self.chkHistoryMPlusDisabled = ELib:Check(self.options_tab.tabs[1],L.ReminderDisableMplusHistory..":",VMRT.Reminder2.HistoryMPlusDisabled):Point("TOPLEFT",self.chkHistory,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self) 
		if self:GetChecked() then
			VMRT.Reminder2.HistoryMPlusDisabled = true
		else
			VMRT.Reminder2.HistoryMPlusDisabled = nil
		end
	end)

	self.chkHistorySession = ELib:Check(self.options_tab.tabs[1],L.ReminderSpellsHistorySaveSession..":",VMRT.Reminder2.HistorySession):Point("TOPLEFT",self.chkHistoryMPlusDisabled,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self) 
		VMRT.Reminder2.HistorySession = self:GetChecked()
		if VMRT.Reminder2.HistorySession then
			VMRT.Reminder2.history = module.db.history
		else
			VMRT.Reminder2.history = nil
		end
	end)

	self.chkHistoryMPlusSessionDisabled = ELib:Check(self.options_tab.tabs[1],L.ReminderDisableSavingMplusHistory..":",not VMRT.Reminder2.HistoryMPlusSessionEnabled):Tooltip(L.ReminderDisableSavingMplusHistoryTip):Point("TOPLEFT",self.chkHistorySession,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self) 
		if self:GetChecked() then
			VMRT.Reminder2.HistoryMPlusSessionEnabled = nil
		else
			VMRT.Reminder2.HistoryMPlusSessionEnabled = true
		end
	end)

	self.chkHistorySync = ELib:Check(self.options_tab.tabs[1],L.ReminderHistorySync..":",VMRT.Reminder2.HistorySync):Point("TOPLEFT",self.chkHistoryMPlusSessionDisabled,"BOTTOMLEFT",0,-5):Left(5):OnClick(function(self) 
		if self:GetChecked() then
			VMRT.Reminder2.HistorySync = true
		else
			VMRT.Reminder2.HistorySync = nil
		end
	end)


	self.sliderHistoryNumSaved = ELib:Slider(self.options_tab.tabs[1],""):Size(320):Point("TOPLEFT",self.chkHistorySync,"BOTTOMLEFT",0,-10):Range(1,10):SetTo(VMRT.Reminder2.HistoryNumSaved or 1):SetObey(true):OnChange(function(self,event) 
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
			local voiceID = module:GetTTSVoiceID()--VMRT.Reminder2.ttsVoice or TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Standard).voiceID
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
				module:GetTTSVoiceID() or 0,
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
				VMRT.Reminder2.SyncPlayers[ options.updatesPlayersList.L[i][1] ] = nil
				tremove(options.updatesPlayersList.L,i)
				options.updatesPlayersList:Update()
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

	self.quickStartFrame.url = ELib:Edit(self.quickStartFrame):Size(300,20):Point("BOTTOM",0,20):Text("https://www.method.gg/method-raid-tools-reminders"):LeftText(LFG_LIST_MORE or "More:"):Run(function (self)
		self:SetScript("OnEditFocusGained", function(self)
			self:HighlightText()
		end)
		self:SetScript("OnMouseUp", function(self, button)
			self:HighlightText()
		end)
	end)

	function self:Update()
		local tab = VMRT.Reminder2.OptSavedTabNum or 1
		if tab == 1 or tab == 2 then options:UpdateData() end
		if tab == 4 then options.timeLine:Update() end
		if tab == 5 then options.assign:Update() end
	end

	local r=self.timeLineBoss:PreUpdate() if r then self.timeLine.preload = r end
	local r=self.assignBoss:PreUpdate() if r then  self.assign.preload = r end
	self.tab:SetTo(VMRT.Reminder2.OptSavedTabNum or 1)
end

function module:Enable()
	module.IsEnabled = true

	module:RegisterEvents('ENCOUNTER_START','ENCOUNTER_END','ZONE_CHANGED_NEW_AREA','CHALLENGE_MODE_START','CHALLENGE_MODE_COMPLETED','CHALLENGE_MODE_RESET')

	module:RegisterBigWigsCallback("BigWigs_OnBossEngage")
	module:RegisterDBMCallback("DBM_Pull")

	module:ResetPrevZone()
	module:LoadForCurrentZone()

	if module.db.debug then
		module:RegisterTimer()
	end
	ExRT.F.After(3,function()
		if IsEncounterInProgress() and not module.db.encounterID and IsInRaid() then
			module.db.requestEncounterID = GetTime()
			local zoneID = select(8,GetInstanceInfo())
			ExRT.F.SendExMsg("rmd", "S\tE\tR\t"..(zoneID or 0))
		end
		if select(3,GetInstanceInfo()) == 8 and C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive and C_ChallengeMode.IsChallengeModeActive() then
			--module.main:CHALLENGE_MODE_START()
		end
	end)
end

function module:Disable()
	module.IsEnabled = false

	module:UnregisterEvents('ENCOUNTER_START','ENCOUNTER_END','ZONE_CHANGED_NEW_AREA','CHALLENGE_MODE_START','CHALLENGE_MODE_COMPLETED','CHALLENGE_MODE_RESET')

	module:UnregisterTimer()
	module:UnloadAll()

	module:UnregisterBigWigsCallback("BigWigs_OnBossEngage")
	module:UnregisterDBMCallback("DBM_Pull")
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
			if options.setupFrame.debugCheck then
				options.setupFrame.debugCheck:Show()
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
			if options.setupFrame.debugCheck then
				options.setupFrame.debugCheck:Hide()
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
	if not num then return false end
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



function module:CheckAllTriggers(trigger, printLog)
	local data, reminder = trigger._data, trigger._reminder

	for i,t in ipairs(reminder.triggers) do
		if t.status and t.status.specialTriggerCheck and not t.status.specialTriggerCheck() then
			module:DeactivateTrigger(t)
			--module:RunAndRemoveTimer(module.DeactivateTrigger,nil,t,t.status.uid or t.status.guid or 1,true)

			--print('discard trigger status',i)
		end
	end

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
		if printLog then
			print("Reminder activation: all triggers check |cffff0000not passed|r")
		end
	end

	local remType = module:GetReminderType(data.msgSize)
	if check then
		if printLog then
			print("Reminder activation: all triggers check passed")
		end
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
					module:ShowReminder(trigger, printLog)
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
					module:ShowReminder(trigger, printLog)
				end
			end
		else
			module:ShowReminder(trigger, printLog)
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

	if remType == REM.TYPE_TEXT and not check and data.hideTextChanged then
		for j=#module.db.showedReminders,1,-1 do
			local showed = module.db.showedReminders[j]
			if showed.data == data then
				if showed.voice then
					showed.voice:Cancel()
				end
				tremove(module.db.showedReminders,j)
			end
		end
	end
end

function module:UnloadTrigger(trigger)
	local data, reminder = trigger._data, trigger._reminder

	trigger.unloaded = true

	for j=#module.db.showedReminders,1,-1 do
		local showed = module.db.showedReminders[j]
		if showed.data == data then
			if showed.voice then
				showed.voice:Cancel()
			end
			tremove(module.db.showedReminders,j)
		end
	end
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
	if reminder.textRepTmr then
		reminder.textRepTmr:Cancel()
		reminder.textRepTmr = nil
	end

	for j=#module.db.timers,1,-1 do
		local t = module.db.timers[j]
		if t.args[2] == trigger then
			t:Cancel()
			tremove(module.db.timers,j)
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

function module:DeactivateTrigger(trigger, uid, isScheduled, printLog)
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
	if printLog then
		print("Trigger #"..trigger._i.." deactivated")
	end

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
		module:CheckAllTriggers(trigger, printLog)
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
	function module:ActivateTrigger(trigger, vars, printLog)
		vars = vars or {}
		if (vars.uid or vars.guid) and trigger.active[vars.uid or vars.guid] then
			return
		end
		if module.db.debugLog then module:DebugLogAdd("ActivateTrigger",trigger._data.name or trigger._data.msg,vars.uid or vars.guid) end
		if printLog then
			print("Trigger #"..trigger._i.." activated")
		end
	
		trigger.status = vars
	
		trigger.active[vars.uid or vars.guid or 1] = vars

		vars.aindex = indexNow
		indexNow = indexNow + 1
	
		vars.atime = GetTime()
		vars.timeLeftB = vars.atime + (trigger._trigger.activeTime or 0)

		if trigger.untimed and trigger.units then	--??? double recheck for units
			module:CheckUnitTriggerStatus(trigger)
		end
		module:CheckAllTriggers(trigger, printLog)
	
		if trigger._trigger.activeTime then
			module.db.timers[#module.db.timers+1] = ScheduleTimer(module.DeactivateTrigger, max(trigger._trigger.activeTime, 0.01), 0, trigger, vars.uid or vars.guid or 1, true, printLog)
		elseif not trigger.untimed and trigger._data.hideTextChanged and trigger._data.dur and tonumber(trigger._data.dur) > 0 then
			module.db.timers[#module.db.timers+1] = ScheduleTimer(module.DeactivateTrigger, max(tonumber(trigger._data.dur), 0.01), 0, trigger, vars.uid or vars.guid or 1, true, printLog)
		elseif not trigger.untimed then
			module:DeactivateTrigger(trigger, vars.uid or vars.guid or 1, false, printLog)
		end
	end
end

local function RemoveTimer(needRun,func,...)
	local debugCount = 0
	for j=#module.db.timers,1,-1 do
		local timer = module.db.timers[j]
		if timer.func == func then
			local isPass = true
			for i=1,select("#",...) do
				local arg = select(i,...)
				if arg and arg ~= timer.args[i] then
					isPass = false
					break
				end
			end
			if isPass then
				if needRun then
					timer.func(unpack(timer.args))
				end
				timer:Cancel()
				tremove(module.db.timers, j)
				debugCount = debugCount + 1
			end
		end 
	end
end

function module:RemoveTimer(func,...)
	RemoveTimer(false,func,...)
end

function module:RunAndRemoveTimer(func,...)
	RemoveTimer(true,func,...)
end

function module:RunTrigger(trigger, vars, printLog)
	if printLog then
		print("|cffffff00MRT Reminder|r",trigger._data.name or "","Run trigger #"..trigger._i)
	end
	if trigger.unloaded then return end
	local triggerData = trigger._trigger
	if trigger.DdelayTime then
		for i=1,#trigger.DdelayTime do
			if trigger._data.durrev and trigger.DdelayTime[i] < (trigger._data.dur or 0) and trigger.DdelayTime[i] > 0.1 then
				vars = vars or {}
				vars._customDuration = trigger.DdelayTime[i]
			end

			local t = ScheduleTimer(module.ActivateTrigger, max(trigger.DdelayTime[i]-(trigger._data.durrev and (trigger._data.dur or 0) or 0),0.01) / (module.db.simrun and module.db.simrunspeed or 1), 0, trigger, vars, printLog)
			module.db.timers[#module.db.timers+1] = t
			if trigger.delays then
				trigger.delays[#trigger.delays+1] = t
			end
			if printLog then
				print("Activation delayed by "..trigger.DdelayTime[i].." sec.")
			end
		end
	else
		module:ActivateTrigger(trigger, vars, printLog)
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
	function module:ShowReminder(trigger, printLog)
		local data, reminder = trigger._data, trigger._reminder
		if module.db.debug then print('ShowReminder',data.name,date("%X",time())) end
		if module.db.debugLog then module:DebugLogAdd("ShowReminder",trigger._data.name or trigger._data.msg) end

		local params = {
			_data = data,
			_reminder = reminder,
			_trigger = trigger,
			_status = trigger.status,
			counterg = reminder.globalcounter or 0,
		}
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
			local isPass,isValid,extraCheckString = module:ExtraCheckParams(data.extraCheck,params)
			if isValid and not isPass then
				if module.db.debug then print('ShowReminder',data.name,date("%X",time()),'not pass extra check') print(extraCheckString) end
				if printLog then
					print("Reminder extra check |cffff0000not passed|r. Extra check string: |cffaaaaaa"..extraCheckString.."|r")
					module:ExtraCheckParams(data.extraCheck,params,printLog)
				end
				return
			end
			if printLog then
				print("Reminder extra check passed. "..(not isValid and "Warning! String is not valid" or "").."Extra check string: |cffaaaaaa"..extraCheckString.."|r")
			end
		end

		if reminder.delayedActivation then
			for i=1,#reminder.delayedActivation do
				local t = ScheduleTimer(module.ShowReminderVisual, reminder.delayedActivation[i], self, trigger, data, reminder, params)
				module.db.timers[#module.db.timers+1] = t
				if printLog then
					print("Reminder all checks |cff00ff00passed|r. Delayed activation in ",reminder.delayedActivation[i],"sec.")
				end
			end
		else
			if printLog then
				print("Reminder all checks |cff00ff00passed|r. Activation now")
			end
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

		local reminderDuration = trigger.status and trigger.status._customDuration or (data.dur and tonumber(data.dur)) or 2

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
				--	module:NameplateRemoveHighlight(reminder.nameplateguid)
				end
				module:NameplateRemoveHighlight(params.guid, data.uid)
				local frame = module:NameplateAddHighlight(params.guid,data,params)
				if not data.copy then
				--	reminder.nameplateguid = params.guid
				end
				if reminderDuration ~= 0 and frame then
					if not module.db.frameHLtimers then
						module.db.frameHLtimers = {}
					end
					if not module.db.frameHLtimers[frame] then
						module.db.frameHLtimers[frame] = {}
					end
					if module.db.frameHLtimers[frame][data.uid or 1] then
						module.db.frameHLtimers[frame][data.uid or 1]:Cancel()
					end
					local t = ScheduleTimer(module.NameplateRemoveHighlight, reminderDuration, module, params.guid, data.uid)
					module.db.frameHLtimers[frame][data.uid or 1] = t
					module.db.timers[#module.db.timers+1] = t
				end
			end
		elseif remType == REM.TYPE_RAIDFRAME then
			if params.guid then
				if reminder.frameguid then
				--	module:FrameRemoveHighlight(reminder.frameguid)
				end
				module:FrameRemoveHighlight(params.guid, data.uid)
				local frame = module:FrameAddHighlight(params.guid,data,params)
				if not data.copy then
				--	reminder.frameguid = params.guid
				end
				if reminderDuration ~= 0 and frame then
					if not module.db.frameHLtimers then
						module.db.frameHLtimers = {}
					end
					if not module.db.frameHLtimers[frame] then
						module.db.frameHLtimers[frame] = {}
					end
					if module.db.frameHLtimers[frame][data.uid or 1] then
						module.db.frameHLtimers[frame][data.uid or 1]:Cancel()
					end
					local t = ScheduleTimer(module.FrameRemoveHighlight, reminderDuration, module, params.guid, data.uid)
					module.db.frameHLtimers[frame][data.uid or 1] = t
					module.db.timers[#module.db.timers+1] = t
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
					icon = GetSpellTexture(trigger.status.spellID)
				end

				local barSize = data.msgSize == 13 and 0.5 or data.msgSize == 14 and 1.5 or 1

				frameBars:StartBar(id,reminderDuration,msg,barSize,color,countdownFormat,voice,ticks,icon,checkFunc,progressFunc)
			end
		else
			local msg, updateReq = module:FormatMsg(data.msg or "",params)
			local t = {
				data = data,
				expirationTime = now + (reminderDuration == 0 and 86400 or reminderDuration or 2),
				params = params,
				dur = reminderDuration,
				reminder = reminder,

				msg = msg,
				updateReq = updateReq,
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
				elseif data.countdownVoice == -9999 then --hardcoded ID for tts
					for i=1,min(5,reminderDuration-0.3) do
						local sound = i
						local tmr = ScheduleTimer(module.PlayTTS, reminderDuration-(i+0.3), module, i)
						module.db.timers[#module.db.timers+1] = tmr
						clist[#clist+1] = tmr
					end
					t.voice = clist
				end
			end
			frame:Show()
		end

		if data.sound and not VMRT.Reminder2.disableSound and bit.band(VMRT.Reminder2.options[data.uid or 0] or 0,bit.lshift(1,1)) == 0 then
			if reminder.delayedSound then
				for i=1,#reminder.delayedSound do
					local t = ScheduleTimer(module.PlaySound, reminder.delayedSound[i], module, data.sound, reminder, now + reminder.delayedSound[i])
					module.db.timers[#module.db.timers+1] = t
				end
			else
				module:PlaySound(data.sound, reminder, now)
			end
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
	local tts_voices
	function module:GetTTSVoiceID()
		if not tts_voices then
			local voices = C_VoiceChat.GetTtsVoices()
			tts_voices = {}
			for i=1,#voices do
				local voice = voices[i]
				tts_voices[voice.voiceID] = voice.name 
			end
		end
		local voice = tts_voices[VMRT.Reminder2.ttsVoice or 0] and (VMRT.Reminder2.ttsVoice or 0) or next(tts_voices)
		return voice
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
			local isCustomTTS = type(sound)=="string" and sound:find("^TTS:")
			if sound == "TTS" or isCustomTTS then
				if C_VoiceChat and C_VoiceChat.SpeakText and reminder then
					local msg = module:FormatMsgForChat( module:FormatMsg(isCustomTTS and sound:gsub("^TTS:","") or reminder.data.msg or "",reminder.params) )
					C_Timer.After(0.01,function()	--Try to fix lag
						--C_VoiceChat.StopSpeakingText()
						C_VoiceChat.SpeakText(
							--VMRT.Reminder2.ttsVoice or TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Standard).voiceID or 1, 
							module:GetTTSVoiceID(), 
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
	function module:PlayTTS(msg)
		C_Timer.After(0.01,function()	--Try to fix lag
			--C_VoiceChat.StopSpeakingText()
			C_VoiceChat.SpeakText(
				module:GetTTSVoiceID(), 
				tostring( msg or "" ), 
				Enum.VoiceTtsDestination.QueuedLocalPlayback, 
				VMRT.Reminder2.ttsSpeechRate or C_TTSSettings.GetSpeechRate() or 0, 
				VMRT.Reminder2.ttsVolume or C_TTSSettings.GetSpeechVolume() or 100
			)
		end)
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

			for k in pairs(self.textBig) do self.textBig[k]=nil end
			for k in pairs(self.text) do self.text[k]=nil end
			for k in pairs(self.textSmall) do self.textSmall[k]=nil end
			local total_c = 0
			local now = GetTime()
			for j=#showedReminders,1,-1 do
				local showed = showedReminders[j]
				local data,t,params = showed.data, showed.expirationTime, showed.params
				if now <= t then
					local msg = showed.msg
					if not msg or showed.updateReq then
						local msg2, updateReq = module:FormatMsg(data.msg or "",params)
						if not msg or (updateReq and not data.dynamicdisable) then
							showed.msg = msg2
						end
					end
					local countdownFormat = showed.countdownFormat
					if not countdownFormat then
						countdownFormat = module.datas.countdownType[data.countdownType or 2][3]
						showed.countdownFormat = countdownFormat
					end
					local table
					if data.msgSize == 2 then
						table = self.textBig
					elseif data.msgSize == 3 then
						table = self.textSmall
					else
						table = self.text
					end
					table[#table+1] = msg or ""
					table[#table+1] = showed.dur ~= 0 and data.countdown and format(countdownFormat,t - now) or ""
					total_c = total_c + 1
				else
					if data.soundafter and not VMRT.Reminder2.disableSound and bit.band(VMRT.Reminder2.options[data.uid or 0] or 0,bit.lshift(1,1)) == 0 then
						module:PlaySound(data.soundafter, showed.reminder, now)
					end
					if showed.voice then
						showed.voice:Cancel()
					end
					tremove(showedReminders,j)
				end
			end

			self:Update()
			if total_c == 0 then
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
		--remove server from names for party members
		if sourceName and sourceName:find("%-") and UnitName(sourceName) then sourceName = strsplit("-",sourceName) end
		if destName  and destName:find("%-") and UnitName(destName) then destName = strsplit("-",destName) end

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

	if IsHistoryEnabled and CLEUIsHistoryEvent[event] and bit_band(sourceFlags,0x000003F0) == 0x00000240 then	--0x000000F0 ~= 0x00000010
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
		local funit = unitreplace[unit] or unit

		local hpMax = UnitHealthMax(funit)
		if hpMax == 0 then
			module:TriggerHPLookup(funit,triggers,0,0)
			return
		end
		local hpNow = UnitHealth(funit)
		local hp = hpNow / hpMax * 100
		module:TriggerHPLookup(funit,triggers,hp,hpNow)
	end
end

function module.main:UNIT_POWER_FREQUENT(unit)
	local triggers = tUNIT_POWER_FREQUENT[unit]
	if triggers then
		local funit = unitreplace[unit] or unit

		local powerMax = UnitPowerMax(funit)
		if powerMax == 0 then
			module:TriggerHPLookup(funit,triggers,0,0)
			return
		end
		local powerNow = UnitPower(funit)
		local power = powerNow / powerMax * 100
		module:TriggerHPLookup(funit,triggers,power,powerNow)
	end
end

function module.main:UNIT_ABSORB_AMOUNT_CHANGED(unit)
	local triggers = tUNIT_ABSORB_AMOUNT_CHANGED[unit]
	if triggers then
		local funit = unitreplace[unit] or unit

		local absorbs = UnitGetTotalAbsorbs(funit)
		module:TriggerHPLookup(funit,triggers,absorbs,absorbs)
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
										v.fullLineClear = (now.fullLine or ""):gsub("[{}]","")
									end
								elseif a == "count" then
									dataTable.count = v
									trigger.count = v
								end
							end})

							local match = true
							if triggerData.pattFind and ((triggerData.pattFind:find("^%-") and now.fullLine:find(triggerData.pattFind:sub(2),1,true)) or (not triggerData.pattFind:find("^%-") and not now.fullLine:find(triggerData.pattFind,1,true))) then
								match = false
							end
		
							if match then
								tCOMBAT_LOG_EVENT_UNFILTERED[event] = tCOMBAT_LOG_EVENT_UNFILTERED[event] or {}
								tCOMBAT_LOG_EVENT_UNFILTERED[event][#tCOMBAT_LOG_EVENT_UNFILTERED[event]+1] = new
							end
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
				local phaseCheck = (phaseNum == triggerData.pattFind or (not tonumber(triggerData.pattFind) and phaseText:find(triggerData.pattFind,1,true)))
				--print(phaseCheck,phaseText,(not trigger.statuses[1] and phaseCheck) or (trigger.statuses[1] and phaseCheck),trigger.statuses[1] and not phaseCheck)

				if (not trigger.statuses[1] and phaseCheck) or (trigger.statuses[1] and phaseCheck) then
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

function module:TriggerMplusStart()
	local triggers = module.db.eventsToTriggers.MPLUS_START
	if triggers then
		for i=1,#triggers do
			module:RunTrigger(triggers[i])
		end
	end
end

function module:TriggerBWMessage(key, text)
	local triggers = module.db.eventsToTriggers.BW_MSG
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger
		if 
			(triggerData.pattFind or triggerData.spellID) and
			(not triggerData.pattFind or module:FindInString(text,triggerData.pattFind)) and
			(not triggerData.spellID or key == triggerData.spellID)
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
		 	  (triggerData.pattFind or triggerData.spellID) and
			  (not triggerData.pattFind or module:FindInString(text,triggerData.pattFind)) and
			  (not triggerData.spellID or key == triggerData.spellID)
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
	local registeredBigWigsEvents = {}

	local timers_on_pull = {}

	local BW_Locale
	local BW_Locale_Soon

	local BigWigsTextToKeys = {}
	local function BigWigsEventCallback(event, ...)
		if not event or not registeredBigWigsEvents[event] then
			return
		end
		if module.db.encounterBossmod and module.db.encounterBossmod ~= "BW" and event ~= "BigWigs_OnBossEngage" and DBM then
			return
		end
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

			if not module.db.encounterID then
				timers_on_pull[#timers_on_pull+1] = {event, ...}
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
		elseif event == "BigWigs_OnBossEngage" then
			module:RegisterBigWigsCallback("BigWigs_StartBar")

			module.db.encounterBossmod = "BW"
			wipe(timers_on_pull)
			ExRT.F.After(2,function()
				wipe(timers_on_pull)
			end)
		end
	end

	function module:BigWigsRecallEncounterStartEvents()
		if module.db.encounterBossmod == "BW" then
			for i=1,#timers_on_pull do
				BigWigsEventCallback(unpack(timers_on_pull[i]))
			end
		end
		wipe(timers_on_pull)
	end
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
	local registeredDBMEvents = {}

	local timers_on_pull = {}

	local DBMIdToSpellID = {}
	local DBMIdToText = {}
	local function DBMEventCallback(event, ...)
		if not event or not registeredDBMEvents[event] then
			return
		end
		if module.db.encounterBossmod and module.db.encounterBossmod ~= "DBM" and BigWigsLoader then
			return
		end
		if (event == "DBM_Announce") then
			local message, icon, announce_type, spellId, modId = ...

			if module.db.eventsToTriggers.BW_MSG then
				module:TriggerBWMessage(spellId, message)
			end
		elseif event == "DBM_TimerStart" then
			local id, msg, duration, icon, timerType, spellId, dbmType = ...

			if not id then return end
			DBMIdToSpellID[id] = spellId
			DBMIdToText[id] = msg or ""

			if module.db.eventsToTriggers.BW_TIMER and id then
				module:TriggerBWTimer(spellId, msg, duration)
			end

			if not module.db.encounterID then
				timers_on_pull[#timers_on_pull+1] = {event, ...}
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
		elseif event == "DBM_Pull" then
			module:RegisterDBMCallback("DBM_TimerStart")

			if not module.db.encounterBossmod then
				module.db.encounterBossmod = "DBM"
			end
			wipe(timers_on_pull)
			ExRT.F.After(2,function()
				wipe(timers_on_pull)
			end)
		end
	end

	function module:DBMRecallEncounterStartEvents()
		if module.db.encounterBossmod == "DBM" then
			for i=1,#timers_on_pull do
				DBMEventCallback(unpack(timers_on_pull[i]))
			end
		end
		wipe(timers_on_pull)
	end

	function module:RegisterDBMCallback(event)
		if (registeredDBMEvents[event]) then
			return
		end
		if type(DBM)=='table' and DBM.RegisterCallback then
			registeredDBMEvents[event] = true
			
			if event == "DBM_kill" or event == "DBM_wipe" then 
				event = event:sub(5) 
			end
			if not DBM:IsCallbackRegistered(event, DBMEventCallback) then
				DBM:RegisterCallback(event, DBMEventCallback)
			end
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

	if sourceName and sourceName:find("%-") and UnitName(strsplit("-",sourceName),nil) then
		sourceName = strsplit("-",sourceName)
	end
	if targetName and targetName:find("%-") and UnitName(strsplit("-",targetName),nil) then
		targetName = strsplit("-",targetName)
	end

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
		local funit = unitreplace[unit] or unit
		
		local guid = UnitGUID(funit)
		if guid then
			if not bossFramesblackList[guid] then
				bossFramesblackList[guid] = true
				local name = UnitName(funit) or ""
				module:TriggerBossFrame(name, guid, funit)
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
			local funit = unitreplace[unit] or unit

			local guid = UnitGUID(funit)
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
							local newAura = C_UnitAuras_GetAuraDataByAuraInstanceID(funit, auraInstanceID)
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
						local aura = C_UnitAuras_GetAuraDataByIndex(funit, index, "HELPFUL")
						if not aura then
							break
						end
						a[aura.auraInstanceID] = aura
						if aura.spellId then a.s[aura.spellId] = aura.auraInstanceID end
						if aura.name then a.n[aura.name] = aura.auraInstanceID end
					end
					for index=1,255 do
						local aura = C_UnitAuras_GetAuraDataByIndex(funit, index, "HARMFUL")
						if not aura then
							break
						end
						a[aura.auraInstanceID] = aura
						if aura.spellId then a.s[aura.spellId] = aura.auraInstanceID end
						if aura.name then a.n[aura.name] = aura.auraInstanceID end
					end
				end
	
				local name = UnitName(funit)
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
						(not triggerData.targetMark or (GetRaidTargetIndex(funit) or 0) == triggerData.targetMark) and
						(not triggerData.targetUnit or module:CheckUnit(triggerData.targetUnit,guid,trigger)) and
						(not trigger.Dstacks or module:CheckNumber(trigger.Dstacks,auraData.applications)) and
						(not triggerData.targetRole or module:CmpUnitRole(funit,triggerData.targetRole))
					then
						if not trigger.statuses[guid] then
	
							local vars = {
								sourceName = sourceName,
								sourceMark = auraData.sourceUnit and GetRaidTargetIndex(auraData.sourceUnit) or nil,
								targetName = name,
								targetMark = GetRaidTargetIndex(funit),
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
							trigger.units[guid] = funit
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
		local funit = unitreplace[unit] or unit

		module:TriggerTargetLookup(funit,triggers)
	end
end

function module.main:UNIT_THREAT_LIST_UPDATE(unit)
	local triggers = tUNIT_TARGET[unit]
	if triggers then
		local funit = unitreplace[unit] or unit

		module:TriggerTargetLookup(funit,triggers)
	end
end

function module:TriggerSpellCD(triggers)
	local gstartTime, gduration, genabled, gmodRate = GetSpellCooldown(61304)
	for i=1,#triggers do
		local trigger = triggers[i]
		local triggerData = trigger._trigger

		local spell = triggerData.spellID or triggerData.spellName
		if spell then
			local startTime, duration, enabled, modRate = GetSpellCooldown(spell)
			if type(spell) == "number" and duration == 0 and startTime == 0 then
				startTime, duration, enabled, modRate = GetSpellCooldown(GetSpellName(spell))
			end 
			if duration then	--spell found
				if not enabled then
					duration = 3600
				end
				local cdCheck = duration > gduration and duration > 0

				if not trigger.statuses[1] and cdCheck then
					module:AddTriggerCounter(trigger)
					local vars = {
						spellID = select(7,GetSpellInfo(spell)),
						spellName = GetSpellName(spell),
						counter = trigger.count,
						timeLeft = startTime + duration * (modRate or 1),
					}
					--special case, check if spell have cd less then dur
					if cdCheck and trigger._data.hideTextChanged and trigger._data.dur and tonumber(trigger._data.dur) > 0 then
						vars.specialTriggerCheck = function(s) if vars.timeLeft < GetTime() + trigger._data.dur then return false else return s or true end end
					end

					trigger.statuses[1] = vars
					if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
						module:RunTrigger(trigger, vars)
					end

					--schedule recheck after cd expiration
					--still can be wrong if cd duration will change afterwards
					local t = ScheduleTimer(module.TriggerSpellCD, duration * (modRate or 1), self, triggers)
					module.db.timers[#module.db.timers+1] = t
				elseif trigger.statuses[1] and not cdCheck then
					trigger.statuses[1] = nil
					module:DeactivateTrigger(trigger)
				end

				if trigger.statuses[1] then
					trigger.statuses[1].timeLeft = startTime + duration * (modRate or 1)
				end
			end
		end
	end
end


function module.main:SPELL_UPDATE_COOLDOWN()
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
			(not triggerData.spellName or triggerData.spellName == GetSpellName(spellID))
		then
			trigger.countsS[guid] = (trigger.countsS[guid] or 0) + 1
			module:AddTriggerCounter(trigger,trigger.countsS[guid])
			if not trigger.Dcounter or module:CheckNumber(trigger.Dcounter,trigger.count) then
				local vars = {
					sourceName = UnitName(unit),
					sourceMark = GetRaidTargetIndex(unit),
					spellID = spellID,
					spellName = GetSpellName(spellID),
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
		local funit = unitreplace[unit] or unit

		module:TriggerSpellcastSucceeded(funit, triggers, spellID)
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
			if name:find("%-") then
				allNames[strsplit("-",name)] = guid
			end
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
				if InCombatLockdown() then
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
				if InCombatLockdown() then
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
	local spellName = GetSpellName(spellID)
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
		local funit = unitreplace[unit] or unit

		local name, text, texture, startTime, endTime, isTradeSkill, castID, interruptible, spellId = UnitCastingInfo(funit)
		module:TriggerCast(funit,triggers,spellID,true,(endTime or 0)/1000)
	end
end

function module.main:UNIT_SPELLCAST_CHANNEL_START(unit,castGUID,spellID)
	local triggers = tUNIT_CAST[unit]
	if triggers then
		local funit = unitreplace[unit] or unit

		local name, text, texture, startTime, endTime, isTradeSkill, interruptible, spellId = UnitChannelInfo(funit)
		module:TriggerCast(funit,triggers,spellID,true,(endTime or 0)/1000)
	end
end

function module.main:UNIT_SPELLCAST_STOP(unit,castGUID,spellID)
	local triggers = tUNIT_CAST[unit]
	if triggers then
		local funit = unitreplace[unit] or unit

		module:TriggerCast(funit,triggers,spellID,false)
	end
end

function module.main:UNIT_SPELLCAST_CHANNEL_STOP(unit,castGUID,spellID)
	local triggers = tUNIT_CAST[unit]
	if triggers then
		local funit = unitreplace[unit] or unit

		module:TriggerCast(funit,triggers,spellID,false)
	end
end

function module.main:UNIT_CAST_CHECK(unit)
	local funit = unitreplace[unit] or unit

	local name, text, texture, startTime, endTime, isTradeSkill, castID, interruptible, spellId = UnitCastingInfo(funit)
	if name then
		local triggers = tUNIT_CAST[unit]
		if triggers then
			module:TriggerCast(funit,triggers,spellId,true,(endTime or 0)/1000)
		end
	else
		local name, text, texture, startTime, endTime, isTradeSkill, interruptible, spellId = UnitChannelInfo(funit)
		if name then
			local triggers = tUNIT_CAST[unit]
			if triggers then
				module:TriggerCast(funit,triggers,spellId,true,(endTime or 0)/1000)
			end
		end
	end
end

function module:CycleAllUnitEvents(unit)
	local funit = unitreplace[unit] or unit
	if UnitGUID(funit) then
		if tUNIT_HEALTH then module.main:UNIT_HEALTH(unit) end
		if tUNIT_POWER_FREQUENT then module.main:UNIT_POWER_FREQUENT(unit) end
		if tUNIT_ABSORB_AMOUNT_CHANGED then module.main:UNIT_ABSORB_AMOUNT_CHANGED(unit) end
		if tUNIT_AURA then module.main:UNIT_AURA(unit) end
		if tUNIT_TARGET then module.main:UNIT_TARGET(unit) end
		if tUNIT_CAST then module.main:UNIT_CAST_CHECK(unit) end
	end
end


function module:TriggerUnitRemovedLookup(unit,triggers,guid)
	local funit = unitreplace[unit] or unit

	guid = guid or UnitGUID(funit)
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
			scheduled = ExRT.F.After(0.05,scheduleFunc)
		end
	end
end

do
	local prev
	function module.main:PLAYER_TARGET_CHANGED()
		local guid = UnitGUID("target")
		if prev == guid then return end
		if guid then
			module:CycleAllUnitEvents("target")
		else
			module:CycleAllUnitEvents_UnitRemoved("target", prev)
		end
		prev = guid
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
		textSize = VMRT.Reminder2.TextSizeRaidframe or 12,
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

	frame.text:SetText(text and text:trim() or "")
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
				obj:SetFrameLevel(1000)
		
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
				obj.text:SetText(data.text and data.text:trim() or "")
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
	if module.db.debug then	print('FrameAddHighlight',guid) end
	local LGF = LibStub("LibGetFrame-1.0", true)
	if not LGF then
		return
	end
	local frame = LGF.GetFrame(guid, LGFNullOpt)
	if not frame then
		return
	end
	if module.db.debug then	print('FrameAddHighlight','frame found') end

	local t = {
		data = data,
		textSize = VMRT.Reminder2.TextSizeRaidframe or 12,
		customScale = 2,
	}
	if t.textSize == 5 then t.textSize = frame:GetHeight() * 0.4 end
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

	return frame
end

function module:FrameRemoveHighlight(guid, uid)
	if module.db.debug then	print('FrameRemoveHighlight',guid) end
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
	if module.db.simrun then
		return
	end
	module.db.historyNow[#module.db.historyNow+1] = {
		GetTime(),
		eventType,
		...
	}
end


function module:SetProfile(profile,sharedProfile)
	if sharedProfile == "x" and type(VMRT.Reminder2.ProfileShared)=="number" and VMRT.Reminder2.ProfileShared >= 0 and not VMRT.Reminder2.data[VMRT.Reminder2.ProfileShared] then	--if profile removed
		sharedProfile = 0
	end

	if profile == "x" then profile = VMRT.Reminder2.Profile end
	if sharedProfile == "x" then sharedProfile = VMRT.Reminder2.ProfileShared end

	VMRT.Reminder2.Profile = profile
	VMRT.Reminder2.ProfileShared = sharedProfile

	if options.profileDropDown then
		options.profileDropDown:AutoText(VMRT.Reminder2.Profile)
		options.sharedProfileDropDown:AutoText(VMRT.Reminder2.ProfileShared)
	end
	CURRENT_DATA = VMRT.Reminder2.data[VMRT.Reminder2.Profile or -1] or {}
	CURRENT_DATA_SHARED = VMRT.Reminder2.data[VMRT.Reminder2.ProfileShared or -1] or {}

	if options.Update then
		options:Update()
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
		v55 = true,
	}
	VMRT.Reminder2.data = VMRT.Reminder2.data or {}
	VMRT.Reminder2.options = VMRT.Reminder2.options or {}
	VMRT.Reminder2.removed = nil
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
	VMRT.Reminder2.profilesinfo = VMRT.Reminder2.profilesinfo or {}

	if not VMRT.Reminder2.v55 then
		if VMRT.Reminder2.Profile == 0 then VMRT.Reminder2.Profile = 6 end
		VMRT.Reminder2.data[6] = VMRT.Reminder2.data[0]
		VMRT.Reminder2.data[0] = {}
		VMRT.Reminder2.v55 = true
	end

	CURRENT_DATA = VMRT.Reminder2.data[VMRT.Reminder2.Profile or -1] or {}
	CURRENT_DATA_SHARED = VMRT.Reminder2.data[VMRT.Reminder2.ProfileShared or -1] or {}

	VMRT.Reminder2.SyncPlayers = VMRT.Reminder2.SyncPlayers or {}

	module:UpdateVisual()
	module:RegisterAddonMessage()
	module:RegisterSlash()

	if VMRT.Reminder2.enabled then
		module:Enable()
	end

	local addNewIcon = false
	if not VMRT.Reminder2.optNewTL and ExRT.V <= 5200 then
		addNewIcon = true
	end
	if not VMRT.Reminder2.optNewAS and ExRT.V <= 5200 then
		addNewIcon = true
	end
	if addNewIcon then
		--"NewCharacter-Horde" for classic
		ExRT.Options:AddIcon(module.name,{"CharacterCreate-NewLabel",40,isAtlas=true})
	end
end

function module.main:CHALLENGE_MODE_START()
	module:StopLiveForce()

	module.db.stayLoaded = true
	module.db.InChallengeMode = true

	module:PrepeareForHistoryRecording()

	local t = ScheduleTimer(function() 
		module:StartHistoryRecord(2)
		if IsHistoryEnabled then
			local zoneName, _, _, _, _, _, _, zoneID = GetInstanceInfo()
			local level = C_ChallengeMode.GetActiveKeystoneInfo()
			module:AddHistoryRecord(22,zoneID,zoneName,level)
		end
		if (module.db.eventsToTriggers.MPLUS_START) then
			module:TriggerMplusStart() 
		end
	end,10)
	module.db.timers[#module.db.timers+1] = t
end
function module.main:CHALLENGE_MODE_RESET()
	module.db.stayLoaded = false
	module.db.InChallengeMode = false

	module:ResetPrevZone()
	module:LoadForCurrentZone()

	module:SaveHistorySegment()
	IsHistoryEnabled = false
end
module.main.CHALLENGE_MODE_COMPLETED = module.main.CHALLENGE_MODE_RESET

do
	local scheduledUpdate
	local prevZoneID
	function module:LoadForCurrentZone()
		scheduledUpdate = nil
		if module.db.encounterID then
			return
		end
		local zoneName, _, difficultyID, _, _, _, _, zoneID = GetInstanceInfo()
		if zoneID ~= prevZoneID then
			prevZoneID = zoneID
			if module.db.debug then print("Load Zone ID",zoneID,zoneName) end

			if difficultyID ~= 8 then
				if module.db.InChallengeMode then
					module:SaveHistorySegment()
					IsHistoryEnabled = false
				end
				module.db.stayLoaded = false
				module.db.InChallengeMode = false
			end

			module.db.currentZoneID = zoneID
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
	module:StopLiveForce()

	module.db.encounterID = encounterID
	module.db.encounterDiff = difficultyID
	module.db.lastEncounterID = encounterID
	module.db.encounterPullTime = GetTime()

	local zoneName, _, _, _, _, _, _, zoneID = GetInstanceInfo()
	module:LoadReminders(encounterID, difficultyID, zoneID, zoneName)

	module:StartHistoryRecord()

	if (module.db.eventsToTriggers.BOSS_START or module.db.eventsToTriggers.NOTE_TIMERS or module.db.eventsToTriggers.NOTE_TIMERS_ALL) and not module.db.nextPullIsDelayed then
		module:TriggerBossPull(encounterID, encounterName)
	end
	if module.db.eventsToTriggers.BOSS_PHASE and not module.db.nextPullIsDelayed then
		module:TriggerBossPhase("1")
	end
	if module.db.eventsToTriggers.PARTY_UNIT then
		module.main:GROUP_ROSTER_UPDATE()
	end

	module:BigWigsRecallEncounterStartEvents()
	module:DBMRecallEncounterStartEvents()

	module.db.nextPullIsDelayed = nil
end

function module:HistoryLogNextFight()
	module.db.historyNextFight = true
	module:RegisterEvents('PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED')
end

function module.main:PLAYER_REGEN_DISABLED()
	if not module.db.historyNextFight then
		return
	end
	module.db.historyNextFight = nil
	module:PrepeareForHistoryRecording()
	module:StartHistoryRecord()
	module:AddHistoryRecord(0)
end

function module.main:PLAYER_REGEN_ENABLED()
	if not module.db.encounterID then
		module:SaveHistorySegment(true)
	end
	module:UnregisterEvents('PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED')
end

function module:StartHistoryRecord(mode)
	if mode == 2 and VMRT.Reminder2.HistoryMPlusDisabled then --m+
		return
	end

	if #module.db.historyNow > 0 then
		wipe(module.db.historyNow)
	end

	if VMRT.Reminder2.HistoryEnabled then
		IsHistoryEnabled = true
	else
		IsHistoryEnabled = false
	end
end
function module:SaveHistorySegment(ignoreFightLen)
	if IsHistoryEnabled then
		module:AddHistoryRecord(0)

		local enoughLength
		if #module.db.historyNow > 1 and (ignoreFightLen or ((module.db.historyNow[#module.db.historyNow][1] - module.db.historyNow[1][1]) >= 30)) then
			enoughLength = true
		end
		if enoughLength then
			if not VMRT.Reminder2.HistoryMPlusSessionEnabled and module.db.historyNow[1][2] == 22 then
				tinsert(module.db.historySession,1,module.db.historyNow)
			else
				tinsert(module.db.history,1,module.db.historyNow)
			end
		end
		local tosend = module.db.historyNow
		module.db.historyNow = {}
		for i=(VMRT.Reminder2.HistoryNumSaved or 1)+1,#module.db.history do
			module.db.history[i] = nil
		end
		for i=(VMRT.Reminder2.HistoryNumSaved or 1)+1,#module.db.historySession do
			module.db.historySession[i] = nil
		end

		if enoughLength and tosend and VMRT.Reminder2.HistorySync and IsInRaid() then
			C_Timer.After(2,function()
				module:SendLastHistory(tosend)
			end)
		end
	end
end
function module:SendLastHistory(history)
	history = history or module.db.history[1]
	if not history then
		return
	end
	local customtl,bossID,len = module:CreateCustomTimelineFromHistory(history)
	customtl = {customtl}
	customtl.bossID = bossID
	customtl.len = len

	local strlist = ExRT.F.TableToText(customtl)
	local str = table.concat(strlist)

	if not str or #str > 500000 then
		return
	end
	local compressed = LibDeflate:CompressDeflate(str,{level = 5})
	if not compressed then
		return
	end

	local encoded = LibDeflate:EncodeForPrint(compressed).."##F##"

	local parts = ceil(#encoded / 246)
	for i=1,parts do
		local msg = encoded:sub( (i-1)*246+1 , i*246 )
		ExRT.F.SendExMsg("rmd","H\t3\t"..msg)
	end
end

function module:CreateCustomTimelineFromHistory(fight)
	local data = {}

	local var = {spell = {}, aura = {}}

	local function add(spell,spellType,time,dur,cast)
		if data[spell] and data[spell].spellType == 2 and spellType == 1 then
			data[spell] = {spellType = spellType}
		end
		if data[spell] and data[spell].spellType ~= spellType then
			return
		end
		if not data[spell] then 
			data[spell] = {spellType = spellType} 
		end
		local r = time
		if dur or cast then r = {r} end
		if dur then r.d = dur end
		if cast then r.c = cast end
		data[spell][ #data[spell]+1 ] = r
	end

	local start = fight[1] and fight[1][1]
	local isChallenge = fight[1] and fight[1][2] == 22
	for i=1,#fight do
		local hline = fight[i]
		if hline[2] == 1 and false then
			if 
			 (hline[3] == "SPELL_CAST_SUCCESS" or hline[3] == "SPELL_CAST_START") or
			 (hline[3] == "SPELL_AURA_APPLIED" or hline[3] == "SPELL_AURA_REMOVED")
			then
				local spell = hline[12]
				if not data[spell] then data[spell] = {} end
				data[spell][ #data[spell]+1 ] = hline[1] - start
			end
		elseif hline[2] == 1 then
			if hline[3] == "SPELL_CAST_START" then
				var.spell[#var.spell+1] = hline
			elseif hline[3] == "SPELL_CAST_SUCCESS" then
				local s, cast, dur = hline[1] - start
				for j=#var.spell,1,-1 do
					if var.spell[j][4] == hline[4] and var.spell[j][12] == hline[12] then
						cast = hline[1]-var.spell[j][1]
						if cast >= 10 then
							--dur, cast = cast
							--s = var.spell[j][1] - start
						end
						if cast > 10 then
							cast = nil
						end
						tremove(var.spell,j)
						break
					end
				end
				add(hline[12],1,s,dur,cast)
			elseif hline[3] == "SPELL_AURA_APPLIED" then
				var.aura[#var.aura+1] = hline
			elseif hline[3] == "SPELL_AURA_REMOVED" then
				local s, dur = hline[1] - start
				for j=1,#var.aura do
					if var.aura[j][4] == hline[4] and var.aura[j][8] == hline[8] and var.aura[j][12] == hline[12] then
						dur = hline[1]-var.aura[j][1]
						s = var.aura[j][1] - start
						tremove(var.aura,j)
						break
					end
				end
				add(hline[12],2,s,dur)
			end
		elseif hline[2] == 2 and not isChallenge then
			if (hline[1] - start) > 2 then	--filter stage on pull
				if not data.p then data.p = {n={}} end
				data.p[ #data.p+1 ] = hline[1] - start
				data.p.n[ #data.p ] = tonumber(hline[3] or "-")
			end
		elseif hline[2] == 3 and isChallenge then
			if not data.p then data.p = {n={}} end
			data.p[ #data.p+1 ] = hline[1] - start
			data.p.n[ #data.p ] = -hline[3]
		elseif hline[2] == 0 and isChallenge then
			if not data.p then data.p = {n={}} end
			data.p[ #data.p+1 ] = hline[1] - start
			data.p.n[ #data.p ] = 0
		end
	end
	--for i=1,#var.spell do add(var.spell[i][12],1,var.spell[i][1] - start) end
	--for i=1,#var.aura do add(var.aura[i][12],2,var.aura[i][1] - start) end
	for _,list in pairs(data) do
		sort(list,function(a,b)
			if type(a) == type(b) and type(a) == "table" then
				return a[1] < b[1]
			elseif type(a) == type(b) then
				return a < b
			elseif type(a) == "table" then
				return a[1] < b
			else
				return a < b[1]
			end
		end)
	end
	return data, fight[1] and fight[1][3], #fight > 1 and fight[#fight][1] - fight[1][1]
end

function module.main:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize)
	module.db.encounterID = nil
	module.db.encounterDiff = nil
	module.db.encounterBossmod = nil

	if not module.db.InChallengeMode then
		module:SaveHistorySegment()
		IsHistoryEnabled = false
	else
		module:AddHistoryRecord(0)		
	end

	module:ResetPrevZone()
	module:LoadForCurrentZone()
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
	wipe(module.db.remindersByName)

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

	module.db.simrun = nil

	if C_VoiceChat and C_VoiceChat.StopSpeakingText then
		C_VoiceChat.StopSpeakingText()
	end

	frameBars:StopAllBars()

	--[[
	for _ in pairs(module.db.forceLoadUIDs) do
		wipe(module.db.forceLoadUIDs)
		break
	end
	]]
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

function module:FindInString(text, subj)
	if type(text) ~= "string" or not subj then
		return
	end
	subj = tostring(subj)
	if subj:find("^=") then
		if text == subj:sub(2) then
			return true
		else
			return false
		end
	elseif text:find(subj, 1, true) then
		return true
	else
		return false
	end
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

do
	local classKeys = {}
	local roleKeys = {}
	for i=1,#ExRT.GDB.ClassList do
		local class = ExRT.GDB.ClassList[i]
		classKeys["class"..class] = true
	end
	for i=1,#module.datas.rolesList do
		local token = module.datas.rolesList[i][1]
		roleKeys["role"..token] = true
	end
	function module:CheckPlayerCondition(data,myName,myClass,myRole,mySubRole)
		if not myName then
			myName = ExRT.SDB.charName
		end
		if not myClass then
			myClass = select(2,UnitClass'player')
		end
		if not myRole then
			myRole = module:GetRoleIndex()
		end
		if not mySubRole then
			mySubRole = module:GetSubRoleIndex()
		end
		local cflitercount, rflitercount, pflitercount = 0, 0, 0
		for k,v in pairs(classKeys) do 
			if data[k] then
				cflitercount = cflitercount + 1 
			end
		end
		for k,v in pairs(roleKeys) do 
			if data[k] then
				rflitercount = rflitercount + 1 
			end
		end
		for k,v in pairs(data.players) do 
			if v then 
				pflitercount = pflitercount + 1
			end
		end
		if
			data.allPlayers or
			(
				(pflitercount == 0 or data.players[myName]) and
				(not data.notePattern or module:FindPlayerInNote(data.notePattern)) and
				(cflitercount == 0 or data["class"..myClass]) and
				(rflitercount == 0 or data["role"..myRole] or data["role"..mySubRole])
			)
			 
		then
			return true
		end
	end
end

module.db.forceLoadUIDs = {}
function module:LoadOneReminder(uid)
	module.db.forceLoadUIDs[uid] = true
	module:ReloadAll()
	if module.db.encounterID then
		print("Reminder: Unable to reload during active boss encounter")
	end
end

function module:FindReminderByData(data)
	for i=1,#reminders do
		if reminders[i].data == data or reminders[i].data.uid == data.uid then
			return reminders[i]
		end
	end
end

function module:FilterFuncReminders(data,encounterID,encounterDiff,zoneID,myName,myClass,myRole,mySubRole,checkIsLoaded)
	if 
		not data.disabled and 
		#data.triggers > 0 and 
		(not checkIsLoaded or not module:FindReminderByData(data)) and
		((
		 (
		  (encounterID and data.bossID == encounterID and (not data.diffID or (data.diffID == encounterDiff or encounterDiff == -1))) or
		  (zoneID and (not encounterID or not data.bossID) and (module:FindNumberInString(zoneID,data.zoneID) or data.zoneID=="-1"))
		 ) and
		 (not myName or module:CheckPlayerCondition(data,myName,myClass,myRole,mySubRole)) and
		 bit.band(VMRT.Reminder2.options[data.uid or 0] or 0,bit.lshift(1,0)) == 0
		) or 
		 module.db.forceLoadUIDs[data.uid or 0])
	then
		return true
	else
		return false
	end
end

function module:UnloadUnusedReminders()
	local eventsTable = module.db.eventsToTriggers
	local count = 0
	for i=#reminders,1,-1 do
		local reminder = reminders[i]
		if not module:FilterFuncReminders(reminder.data,module.db.encounterID,module.db.encounterDiff,module.db.currentZoneID) then
			count = count + 1

			for event,edata in pairs(eventsTable) do
				for _,edata2 in pairs(#edata == 0 and edata or {edata}) do
					for j=#edata2,1,-1 do
						if edata2[j]._reminder == reminder then
							tremove(edata2, j)
						end
					end
				end
			end

			for j=1,#reminder.triggers do
				module:UnloadTrigger(reminder.triggers[j])
			end

			tremove(reminders, i)
		end
	end

	if module.db.debug then print("Unloaded Reminders",count) end
end

function module:LoadReminders(encounterID,encounterDiff,zoneID,zoneName)
	if module.db.stayLoaded then
		module:UnloadUnusedReminders()
	else
		module:UnloadAll()
	end
	if not module.IsEnabled then
		return
	end

	if module.db.debugLog then module:DebugLogAdd("LoadReminders",encounterID,encounterDiff,zoneID) end

	local myName = ExRT.SDB.charName
	local myClass = select(2,UnitClass'player')
	local myRole = module:GetRoleIndex()
	local mySubRole = module:GetSubRoleIndex()

	local eventsUsed, unitsUsed = {}, {}
	local nameplateUsed

	for uid_key,data in pairs(module:RemGetAll()) do
		if uid_key ~= data.uid or type(data.triggers)~="table" or type(data.players)~="table" then
			module:RemRem(uid_key)
		elseif 
			module:FilterFuncReminders(data,encounterID,encounterDiff,zoneID,myName,myClass,myRole,mySubRole,true)
		then
			local reminder = {
				triggers = {},
				data = data,
			}
			reminders[#reminders+1] = reminder
			module.db.remindersByName[data.name or data.uid or 0] = reminder
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
								local funit = unitreplace_rev[unit] or unit

								local unitTable = eventTable[funit]
								if not unitTable then
									unitTable = {}
									eventTable[funit] = unitTable
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
			reminder.delayedSound = module:ConvertMinuteStrToNum(data.sounddelay)

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

	if encounterID then
		module:PrepeareForHistoryRecording()
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

	for _ in pairs(module.db.forceLoadUIDs) do
		wipe(module.db.forceLoadUIDs)
		break
	end
end

function module:PrepeareForHistoryRecording()
	if not VMRT.Reminder2.HistoryEnabled then
		return
	end
	if not module.db.eventsToTriggers.COMBAT_LOG_EVENT_UNFILTERED then 
		module.db.eventsToTriggers.COMBAT_LOG_EVENT_UNFILTERED = {} 
		module:RegisterEvents("COMBAT_LOG_EVENT_UNFILTERED")

		tCOMBAT_LOG_EVENT_UNFILTERED = module.db.eventsToTriggers.COMBAT_LOG_EVENT_UNFILTERED
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

	local encountersList
	local function GetInstanceName(bossID)
		if not bossID then
			return
		end
		if not encountersList then
			encountersList = ExRT.F.GetEncountersList(true,false,true)
		end
		for i=1,#encountersList do
			local instance = encountersList[i]
			for j=2,#instance do
				if instance[j] == bossID then
					return (C_Map.GetMapInfo(instance[1]) or {}).name
				end
			end
	
		end
	end

	function module:ProcessTextToData_CheckVersion(dataStr)
		local ver,addonVer = strsplit(DELIMITER_1,dataStr)
		if tonumber(ver or "?") ~= senderVersion then
			if tonumber(ver or "0") > senderVersion then
				print("MRT Reminder: your reminder addon version is outdated (string ver."..(addonVer or "unk")..", your addon ver."..addonVersion..")")
			else
				print("MRT Reminder: import data is outdated (string ver."..(addonVer or "unk")..", your addon ver."..addonVersion..")")
			end
			return false
		end
		return true
	end

	function module:AnalyzeTextToData(text)
		local data = {strsplit("\n",text)}
		if not data[1] or not module:ProcessTextToData_CheckVersion(data[1]) then
			return
		end

		local counter = 0

		for i=2,#data do
			local uid,name,msg,msgSize,dur,checks,countdownType,sound,extraOptions,glowOptions,countdownVoice,extraCheck,bossID,diffID,zoneID,players,notePattern,roles,classes,triggersNum,triggersData = strsplit(DELIMITER_1,data[i],21)
			if uid then
				if msg then
					counter = counter + 1
				end
			end
		end

		return {
			count = counter,
		}
	end

	function module:ProcessTextToData(text, sender, isStringImport, isSelfImport)
		local data = {strsplit("\n",text)}
		if not data[1] or not module:ProcessTextToData_CheckVersion(data[1]) then
			return
		end

		local _,_,profileName = strsplit(DELIMITER_1,data[1])
		if profileName and profileName ~= "" then
			profileName = profileName:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc):sub(1,100)
		else
			profileName = nil
		end

		local time_now = time()

		local workingArray, sharedProfileNum
		if isStringImport then
			workingArray = CURRENT_DATA
		else
			workingArray, sharedProfileNum = module:GetSharedProfileByName(profileName,true)
			if #data > 2 and not isLiveSession then
				wipe(workingArray)

				if not VMRT.Reminder2.profilesinfo[sharedProfileNum] then
					VMRT.Reminder2.profilesinfo[sharedProfileNum] = {}
				end
				VMRT.Reminder2.profilesinfo[sharedProfileNum].lastupdate = time_now
				VMRT.Reminder2.profilesinfo[sharedProfileNum].lastname = sender
			end
		end

		if module.db.debug then
			print('ProcessTextToData',isLiveSession)
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

					local specialTarget,delayedActivation,soundafter,sounddelay = strsplit(DELIMITER_2,extraOptions or "")

					local new = {
						uid = uid,
						name = name~="" and name or nil,
						msg = msg~="" and msg:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						msgSize = msgSize~="" and tonumber(msgSize) or nil,
						dur = dur~="" and tonumber(dur) or nil,
						countdownType = countdownType~="" and tonumber(countdownType) or nil,
						delayedActivation = delayedActivation and delayedActivation~="" and delayedActivation:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						sounddelay = sounddelay and sounddelay~="" and sounddelay:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						sound = sound~="" and sound:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						soundafter = soundafter and soundafter~="" and soundafter:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						bossID = bossID~="" and tonumber(bossID) or nil,
						diffID = diffID~="" and tonumber(diffID) or nil,
						zoneID = zoneID~="" and zoneID:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						notePattern = notePattern~="" and notePattern:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
						players = players_arr,
						triggers = triggers, 
						specialTarget = specialTarget and specialTarget~="" and specialTarget:gsub(STRING_CONVERT.decodePatt,STRING_CONVERT.decodeFunc) or nil,
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
					if bit.band(checks,bit.lshift(1,7)) > 0 then new.durrev = true end
					if bit.band(checks,bit.lshift(1,8)) > 0 then new.hideTextChanged = true end


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
						new.updatedTime = time_now
					end
					new.lastupdate = time_now
					if bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,2)) == 0 then
						workingArray[uid] = new
					end

					if isStringImport and name then
						local instanceName = GetInstanceName(new.bossID)
						print("Imported ",name,"("..(new.bossID and ExRT.GDB.encounterIDtoEJ[new.bossID] and L.bossName[new.bossID] or zoneID and zoneID ~= "" and "Zone "..zoneID or "none")..(instanceName and " <"..instanceName..">" or "")..")")
					end
					rc = rc + 1
				else
					workingArray[uid] = nil
				end
			end
		end
		if module.db.debug then
			print("Reminder ProcessTextToData: encoded length:",#text,"reminders num:",rc)
			print('current workingArray',ExRT.F.table_len(workingArray))
		end

		if not isLiveSession then
			if isStringImport then
				module:SetProfile("x","x")
			--elseif not isSelfImport then
			else
				module:SetProfile("x",sharedProfileNum or 0)
			end
		else
			if options.Update then
				options:Update()
			end
		end
	end
end

do
	function options:GetHistoryString(minimized)
		local t = {}
		for _, h_key in pairs({"history","historySession"}) do	
			for i=1,#module.db[h_key] do
				t[#t+1] = module.db[h_key][i]
			end
		end
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

	function module:ProcessTimelineHistoryTextToData(str, sender)
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
			if not module.db.historyTL then
				module.db.historyTL = {}
			end
			res.player = sender
			tinsert(module.db.historyTL,1,res)
			for i=21,#module.db.historyTL do
				module.db.historyTL[i] = nil
			end

			--print('added history from',sender)
		end
	end
end


function module:RemAdd(uid,data,ignoreSharedProfile)
	if type(data) ~= "table" then error("not a table") return end
	local r = CURRENT_DATA[uid]
	local s = CURRENT_DATA_SHARED[uid]
	if (VMRT.Reminder2.ProfileShared or 0) < 0 then
		s = nil
	end
	if ignoreSharedProfile then
		s = nil
	end

	data.lastupdate = time()
	if isLiveSession then
		r = nil
		s = true
	end

	if r then CURRENT_DATA[uid] = data end
	if s then CURRENT_DATA_SHARED[uid] = data end
	if not r and not s then CURRENT_DATA[uid] = data end

	if isLiveSession then
		module:Sync(nil,nil,nil,uid,true)
	end
end
function module:RemGet(uid)
	local r = CURRENT_DATA[uid]
	local s = CURRENT_DATA_SHARED[uid]
	if (VMRT.Reminder2.ProfileShared or 0) ~= 0 then
		s = nil
	end
	if r and s then
		if (s.lastupdate or 0) > (r.lastupdate or 0) then
			r = s
		end
	end
	return r or s
end
function module:RemGetAll()
	local new = {}
	for k,v in pairs(CURRENT_DATA) do
		new[k] = v
	end
	for k,v in pairs(CURRENT_DATA_SHARED) do
		if not new[k] or ((v.lastupdate or 0) > (new[k].lastupdate or 0)) then
			new[k] = v
		end
	end
	return new
end
function module:RemGetSource(uid)
	local r = CURRENT_DATA[uid]
	local s = CURRENT_DATA_SHARED[uid]
	if not r and s then
		return 0
	elseif r then
		return VMRT.Reminder2.Profile
	end
end
function module:RemRem(uid)
	if not uid then return end
	CURRENT_DATA[uid] = nil
	CURRENT_DATA_SHARED[uid] = nil
	if isLiveSession then
		module:Sync(nil,nil,nil,uid,true)
	end
end

function module:GetSharedProfileByName(profileName,addNew)
	if not profileName then
		return VMRT.Reminder2.data[0], 0
	end
	for i=10001,10005 do
		if VMRT.Reminder2.data[i] and VMRT.Reminder2.profilesinfo[i] and VMRT.Reminder2.profilesinfo[i].name == profileName then
			return VMRT.Reminder2.data[i], i
		end
	end
	if addNew then
		local pos
		for i=10001,10005 do
			if not VMRT.Reminder2.data[i] then
				pos = i
				break
			elseif not pos then
				pos = i
			elseif (VMRT.Reminder2.profilesinfo[i] and VMRT.Reminder2.profilesinfo[i].lastupdate or math.huge) < (VMRT.Reminder2.profilesinfo[pos] and VMRT.Reminder2.profilesinfo[pos].lastupdate or math.huge) then
				pos = i
			end
		end
		if module.db.debug then print('add profile at pos',pos,VMRT.Reminder2.data[pos] and 'replace' or 'new') end
		if VMRT.Reminder2.data[pos] then
			wipe(VMRT.Reminder2.data[pos])
		else
			VMRT.Reminder2.data[pos] = {}
		end
		if not VMRT.Reminder2.profilesinfo[pos] then VMRT.Reminder2.profilesinfo[pos] = {} end
		VMRT.Reminder2.profilesinfo[pos].name = profileName
		return VMRT.Reminder2.data[pos], pos
	end
end
function module:GetSharedProfilesList()
	local res = {}
	res[#res+1] = {id = 0, data = VMRT.Reminder2.data[0], info = VMRT.Reminder2.profilesinfo[0]}
	for i=10001,10005 do
		if VMRT.Reminder2.data[i] then
			res[#res+1] = {id = i, data = VMRT.Reminder2.data[i], info = VMRT.Reminder2.profilesinfo[i]}
		end
	end
	return res
end

function module:GetCurrentProfileInfo()
	local profileNow = VMRT.Reminder2.Profile
	if profileName == -1 then
		return {}
	end
	if VMRT.Reminder2.profilesinfo[profileNow] then
		return VMRT.Reminder2.profilesinfo[profileNow]
	end
	return {}
end

do
	local antiSpam = 0
	local nextSyncGuild, nextSyncGuildTmr
	function module:SyncGuild()
		nextSyncGuild = true
	end
	function module:Sync(isExport,bossID,zoneID,oneUID,liveSession,customList)
		local isGuild = nextSyncGuild
		nextSyncGuild = nil

		local profileInfo = module:GetCurrentProfileInfo()
		local profileName = (profileInfo.name or ""):sub(1,100):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc)

		if liveSession or isLiveSession then
			profileName = ""
		end

		local r = senderVersion..DELIMITER_1..addonVersion..DELIMITER_1..profileName.."\n"
		local rc = 0
		local reminders
		if customList then
			reminders = customList
		elseif liveSession and oneUID then
			reminders = {[oneUID]=module:RemGet(oneUID)}
		else
			reminders = module:RemGetAll()
		end
		for uid,data in pairs(reminders) do
			if 
				uid == data.uid and 
				(bit.band(VMRT.Reminder2.options[uid] or 0,bit.lshift(1,3)) == 0 or oneUID) and
				(
				 (
				  (bossID and ((type(bossID) == "table" and data.bossID and bossID[data.bossID]) or (type(bossID) ~= "table" and data.bossID == bossID))) or
				  (zoneID and module:FindNumberInString(zoneID,data.zoneID)) or
				  (oneUID and uid == oneUID)
				 ) and
				 (not oneUID or uid == oneUID)
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
				if data.durrev then checks = bit.bor(checks,bit.lshift(1,7)) end
				if data.hideTextChanged then checks = bit.bor(checks,bit.lshift(1,8)) end

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
					(data.delayedActivation or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_2 .. 
					(data.soundafter or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc) .. DELIMITER_2 .. 
					(data.sounddelay or ""):gsub(STRING_CONVERT.encodePatt,STRING_CONVERT.encodeFunc)
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

				if not isExport and not liveSession and module:RemGetSource(uid) ~= 0 then
					module:RemAdd(uid,data,true)
				end
			end
		end
		if oneUID and rc == 0 and liveSession then
			r = r .. oneUID .. DELIMITER_1.."\n"
			rc = rc + 1
		end
		if rc == 0 then
			print("MRT "..L.Reminder..": "..L.ReminderErrorZeroSend)
			return
		end
		r = r:gsub("\n$","")
		if isExport then
			return r
		end
		local now = GetTime()
		if now < antiSpam and not isLiveSession then
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

		if options.SyncProgress then
			options:SyncProgress(0)
		end
		for i=1,parts do
			local msg = encoded:sub( (i-1)*247+1 , i*247 )
			local progress = i
			if liveSession then
				ExRT.F.SendExMsgExt({ondone=function() options:SyncProgress(progress,parts) end},"rmd","L\t"..newIndex.."\t"..msg)
			elseif not isGuild then
				ExRT.F.SendExMsgExt({ondone=function() options:SyncProgress(progress,parts) end},"rmd","D\t"..newIndex.."\t"..msg)
			else
				ExRT.F.SendExMsgExt({ondone=function() options:SyncProgress(progress,parts) end},"rmd","d\t"..newIndex.."\t"..msg,"GUILD")
			end
		end
	end

	local function GetFirstKey(t)
		for k in pairs(t) do return k end
	end

	local savedbossID, savedzoneID
	function module:StartLive(bossID,zoneID)
		ExRT.F.SendExMsg("rmd","C\tLIVE_SESSION\t"..(bossID and GetFirstKey(bossID) or "").."\t"..(zoneID and GetFirstKey(zoneID) or ""))
		isLiveSession = true
		module.db.liveSessionMainProfile = VMRT.Reminder2.Profile
		local reminders = module:RemGetAll()
		savedbossID, savedzoneID = bossID, zoneID
		wipe(VMRT.Reminder2.data[0])
		module:SetProfile(-1,0)
		module:Sync(false,bossID,zoneID,nil,true,reminders)
		if options.assignLive then
			options.assignLive:UpdateStatus()
			options.profileDropDown:Disable()
			options.sharedProfileDropDown:Disable()
		end
	end

	function module:StopLive()
		isLiveSession = false
		ExRT.F.SendExMsg("rmd","C\tLIVE_SESSION_STOP")
		--module:Sync(false,savedbossID,savedzoneID)
		if module.db.liveSessionMainProfile then
			module:SetProfile(module.db.liveSessionMainProfile,0)
		end
		module.db.liveSessionMainProfile = nil
		if options.assignLive then
			options.assignLive:UpdateStatus()
			options.profileDropDown:Enable()
			options.sharedProfileDropDown:Enable()
		end
	end

	function module:StartLiveUser(bossID, zoneID)
		if not module.db.preLiveSession then
			if isLiveSession then
				print('live session already started')
			else
				print('live session already ended')
			end
			return
		end
		module.db.liveSessionMainProfileUser = VMRT.Reminder2.Profile
		wipe(VMRT.Reminder2.data[0])
		module:SetProfile(-1,0)
		isLiveSession = true
		for i=1,#module.db.preLiveSession do
			module:ProcessTextToData(unpack(module.db.preLiveSession[i]))
		end
		module.db.preLiveSession = nil
		if not options:IsVisible() then
			if options.tab then
				options.tab:SetTo(5)
			else
				VMRT.Reminder2.OptSavedTabNum = 5
			end
			ExRT.Options:OpenByModuleName(module.name)
		end
		if options.assignBoss and bossID and bossID ~= "" and tonumber(bossID) then
			options.assignBoss:SelectBoss(tonumber(bossID))
		end
		if options.assignLive then
			options.assignLive:UpdateStatus()
			options.profileDropDown:Disable()
			options.sharedProfileDropDown:Disable()
		end
	end

	function module:StopLiveUser()
		isLiveSession = false
		module.db.preLiveSession = nil
		if module.db.liveSessionMainProfileUser or module.db.liveSessionMainProfile then
			module:SetProfile(module.db.liveSessionMainProfileUser or module.db.liveSessionMainProfile,0)
		end
		module.db.liveSessionMainProfileUser = nil
		if options.assignLive then
			options.assignLive:UpdateStatus()
			options.profileDropDown:Enable()
			options.sharedProfileDropDown:Enable()
		end
	end

	function module:StopLiveForce()
		if not isLiveSession then
			return
		end
		if module.db.liveSessionMainProfile then
			module:StopLive()
		elseif module.db.liveSessionMainProfileUser then
			module:StopLiveUser()
		end
	end
end

module.db.synqText = {}
module.db.synqIndex = {}
function module:addonMessage(sender, prefix, subprefix, arg1, ...)
	if prefix == "rmd" then
		if subprefix == "D" or subprefix == "d" or subprefix == "L" or subprefix == "l" then
			if IsEncounterInProgress() then
				return
			end
			if VMRT.Reminder2.disableUpdates then
				return
			end
			if subprefix == "D" and IsInRaid() and not ExRT.F.IsPlayerRLorOfficer(sender) then
				return
			end
			if subprefix == "L" and not (isLiveSession or module.db.preLiveSession) then
				return
			end
			if isLiveSession and subprefix ~= "L" then
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
					if subprefix == "L" then
						if not isLiveSession and module.db.preLiveSession then
							module.db.preLiveSession[#module.db.preLiveSession+1] = {decompressed, sender, nil, sender == ExRT.SDB.charKey or sender == ExRT.SDB.charName}
						elseif isLiveSession then
							VMRT.Reminder2.LastUpdateName = sender
							VMRT.Reminder2.LastUpdateTime = time()

							module:ProcessTextToData(decompressed, sender, nil, sender == ExRT.SDB.charKey or sender == ExRT.SDB.charName)
						end
					else
						module.popup:Popup(sender,function()
							VMRT.Reminder2.LastUpdateName = sender
							VMRT.Reminder2.LastUpdateTime = time()
		
							module:ProcessTextToData(decompressed, sender, nil, sender == ExRT.SDB.charKey or sender == ExRT.SDB.charName)
							if options and options.UpdateSenderDataText then
								options:UpdateSenderDataText()
							end
						end,module:AnalyzeTextToData(decompressed))
					end
				end
			end
		elseif subprefix == "H" then
			if sender == ExRT.SDB.charKey then
				return
			end
			if VMRT.Reminder2.disableUpdates or not IsInRaid() then
				return
			end

			if tostring(arg1) == "3" then
				local currMsg = table.concat({...}, "\t")
				if not module.db.synqHText then
					module.db.synqHText = {}
				end
				module.db.synqHText[sender] = (module.db.synqHText[sender] or "") .. currMsg

				if type(module.db.synqHText[sender])=='string' and module.db.synqHText[sender]:find("##F##$") then
					if not module.db.synqHTLast or GetTime() - module.db.synqHTLast > 2 then
						module:ProcessTimelineHistoryTextToData(module.db.synqHText[sender]:sub(1,-6), sender)
						module.db.synqHTLast = GetTime()
					end
					module.db.synqHText[sender] = nil
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
		elseif subprefix == "C" then
			if arg1 == "LIVE_SESSION" then
				if VMRT.Reminder2.disableUpdates then
					return
				end
				if sender == ExRT.SDB.charKey or sender == ExRT.SDB.charName then
					return
				end
				if IsInRaid() and not ExRT.F.IsPlayerRLorOfficer(sender) then
					return
				end
				if isLiveSession then
					return
				end
				local bossID, zoneID = ...
				module.db.preLiveSession = {}
				module.popup:Popup(sender,function()
					module:StartLiveUser(bossID, zoneID)
				end,{livesession = true})
			elseif arg1 == "LIVE_SESSION_STOP" then
				if VMRT.Reminder2.disableUpdates then
					return
				end
				if sender == ExRT.SDB.charKey or sender == ExRT.SDB.charName then
					return
				end
				if IsInRaid() and not ExRT.F.IsPlayerRLorOfficer(sender) then
					return
				end
				module:StopLiveUser()
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
		if frame.ignoreAlwaysButtons then return end
		frame.b1always:Show()
		self:SetScript("OnUpdate",OnUpdate_HoverCheck)
	end)

	frame.b3 = ELib:Button(frame,ACCEPT):Point("BOTTOMRIGHT",-5,5):Size(100,20):OnClick(function() 
		queue[2]()
		frame:NextQueue()
	end):OnEnter(function(self)
		if frame.ignoreAlwaysButtons then return end
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
		local player = queue[1] and queue[1].player
		if not player then
			return
		end
		local diffText
		frame.ignoreAlwaysButtons = nil
		if player == ExRT.SDB.charKey or player == ExRT.SDB.charName then
			queue[2]()
			frame:NextQueue()
			return
		elseif queue[1] and queue[1].data and queue[1].data.livesession then
			diffText = "Player "..strsplit("-",player).." is starting |A:unitframeicon-chromietime:20:20|a live session"
			frame.ignoreAlwaysButtons = true
		elseif VMRT.Reminder2.SyncPlayers[player] == -1 then
			frame:NextQueue()
			return
		elseif VMRT.Reminder2.SyncPlayers[player] == 1 then
			queue[2]()
			frame:NextQueue()
			return
		end
		frame.playerRaw = player
		if diffText then
			frame.player:SetText(diffText)
		else
			frame.player:SetText(player..(queue[1].data and queue[1].data.count and "\n"..(AUCTION_HOUSE_QUANTITY_LABEL or "Quantity")..": "..queue[1].data.count or ""))
		end
		frame:Show()
	end

	function frame:Popup(player,func,analyzeData)
		queue[#queue+1] = {player = player, data = analyzeData}
 		queue[#queue+1] = func
	
		frame:PopupNext()
	end
end

function module:Test_BW(phase)
	if not BigWigs then
		LibDBIcon10_BigWigs:GetScript("OnClick")(LibDBIcon10_BigWigs,"RightButton")--sorry
		BigWigsOptions:Close()
	end
	BigWigsLoader:LoadZone(2769)

	local bossID = boss == 2 and 2902 or 3016
	local bossName = boss == 2 and "Ulgrax the Devourer" or "Chrome King Gallywix"

	local mod = BigWigs:GetBossModule("Chrome King Gallywix")
	mod.Mythic = function() return true end

	if phase == -1 then
		module.db.simrun = nil
		module:ReloadAll()
		mod:Wipe()
		return
	elseif phase == -2 then
		return mod
	elseif phase == 1 then
		mod:TotalDestructionRemoved()
		return
	elseif phase == 1.5 then
		mod:CircuitRebootApplied({amount = 0, spellId = 450980, spellName = GetSpellName(450980), time = GetTime()})
		return
	elseif phase == 2 then
		mod:CircuitRebootRemoved({amount = 0, spellId = 450980, spellName = GetSpellName(450980), time = GetTime()})
		return
	elseif phase == 2.5 then
		mod:BurrowTransition()
		return
	elseif phase == 3 then
		mod:SpikeStormRemoved({amount = 0, spellId = 451277, spellName = GetSpellName(451277), time = GetTime()})
		return
	end

	mod:Enable()
	mod:Engage()

	module.db.simrun = GetTime()
	module:LoadReminders(bossID,-1)
	module:TriggerBossPull()
	module:TriggerBossPhase("1")
	module:BigWigsRecallEncounterStartEvents()
end
--/run GMRT.A.Reminder2:Test_BW()

function module:Test_DBM(phase,boss)
	local mod
	local bossData = {
		[2921] = {
			[1] = function() mod:UNIT_SPELLCAST_SUCCEEDED(nil,nil,441427) end,
			[1.5] = function() mod:SPELL_CAST_START({spellId=450483}) end,
			[2] = function() mod:SPELL_AURA_REMOVED({spellId=450980}) end,
			[2.5] = function() mod:SPELL_CAST_START({spellId=456174}) end,
			[3] = function() mod:SPELL_AURA_REMOVED({spellId=451277}) end,
		},
		[2902] = {
			[2] = function() mod:SPELL_CAST_START({spellId=445123}) end,
		},
		[2905] = {
			moduleName = "DBM-Party-WarWithin",
			[2] = function() mod:SPELL_CAST_START({spellId=441395}) end,
			[3] = function() mod:SPELL_CAST_START({spellId=441395}) end,
			[4] = function() mod:SPELL_CAST_SUCCESS({spellId=441395}) end,
		}
	}
	local bossID = boss == 2 and 2902 or boss == 3 and 2905 or 2921
	bossData = bossData[bossID]

	if #DBM.Mods == 0 then DBM:LoadModByName(bossData.moduleName or "DBM-Raids-WarWithin") end

	for v, vm in pairs(DBM.Mods) do
		if vm.encounterId == bossID then
			mod = vm
			break
		end
	end

	if phase == -1 then
		module.db.simrun = nil
		module:ReloadAll()
		DBM:EndCombat(mod, false, nil, "ENCOUNTER_END")
		return
	elseif phase == -2 then
		return mod
	end
	if phase and bossData[phase] then
		return bossData[phase]()
	end

	DBM:StartCombat(mod, 0, "ENCOUNTER_START")

	module.db.simrun = GetTime()
	module:LoadReminders(bossID,-1)
	module:TriggerBossPull()
	module:TriggerBossPhase("1")
	module:DBMRecallEncounterStartEvents()
end
--/run GMRT.A.Reminder2:Test_DBM()

