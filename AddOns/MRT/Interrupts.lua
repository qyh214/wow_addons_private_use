local GlobalAddonName, ExRT = ...

if ExRT.isMN then
	return
end

local VMRT = nil

local ELib,L = ExRT.lib,ExRT.L
local module = ExRT:New("Interrupts",L.Interrupts)

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LCG = LibStub("LibCustomGlow-1.0",true)

local UnitGUID, GetRaidTargetIndex, strsplit, select = UnitGUID, GetRaidTargetIndex, strsplit, select
local GetSpellInfo = ExRT.F.GetSpellInfo or GetSpellInfo

local VERSION = 7
local SENDER_VERSION = 1

local defOption = {
	Size = 45,
	FontSize = 40,
	Font = "Fonts\\ARIALN.TTF",
	SoundNext = "Interface\\AddOns\\MRT\\media\\Sounds\\Next.ogg",
	SoundKick = "Interface\\AddOns\\MRT\\media\\Sounds\\Interrupt.ogg",
	Anchor = 1,
	AnchorOffsetY = 3,
	AnchorOffsetX = 0,
	Alpha = 1,
	KickerFontSize = 12,
	KickerFont = "Fonts\\ARIALN.TTF",
	nocast = {1,1,1},
	cast = {1,1,1},
	minenocast = {1,1,0},
	minecast = {0,1,0},
	nocast_text = {1,0,0},
	cast_text = {1,1,0},
	minenocast_text = {1,0,0},
	minecast_text = {1,1,0},
}

local profiles = {
	[0] = L.InterruptsProfileShared,
	[1] = L.InterruptsProfilePersonal.." #1",
	[2] = L.InterruptsProfilePersonal.." #2",
	[3] = L.InterruptsProfilePersonal.." #3",
}
local profilesSorted = {0,1,2,3}

local CURRENT_DATA = {}

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	VMRT.Interrupts = VMRT.Interrupts or {}
	VMRT.Interrupts.Data = VMRT.Interrupts.Data or {}
	VMRT.Interrupts.Disabled = VMRT.Interrupts.Disabled or {}

	if not VMRT.Interrupts.Profile then
		VMRT.Interrupts.Profile = 1
		if not VMRT.Interrupts.Data[0] then
			VMRT.Interrupts.Data = {
				[1] = VMRT.Interrupts.Data,
			}
		end
	end
	for k in pairs(profiles) do
		if not VMRT.Interrupts.Data[k] then
			VMRT.Interrupts.Data[k] = {}
		end
	end

	CURRENT_DATA = VMRT.Interrupts.Data[VMRT.Interrupts.Profile]

	module:RegisterAddonMessage()

	if VMRT.Interrupts.enabled then
		module:Enable()
	end
end

function module:Enable()
	module:UpdateData()

	module:RegisterEvents('NAME_PLATE_UNIT_ADDED','NAME_PLATE_UNIT_REMOVED','COMBAT_LOG_EVENT_UNFILTERED','RAID_TARGET_UPDATE','ENCOUNTER_START')
end

function module:Disable()
	module:UnregisterEvents('NAME_PLATE_UNIT_ADDED','NAME_PLATE_UNIT_REMOVED','COMBAT_LOG_EVENT_UNFILTERED','RAID_TARGET_UPDATE','ENCOUNTER_START')

	module:ReloadAll(true)
end

function module:SetProfile(profile)
	VMRT.Interrupts.Profile = profile
	if module.options.profileDropDown then
		module.options.profileDropDown:SetText(profiles[VMRT.Interrupts.Profile])
	end
	CURRENT_DATA = VMRT.Interrupts.Data[VMRT.Interrupts.Profile]

	if module.options.list then
		module.options.list:UpdateDB()
		module.options.list:Update()
	end
	
	if VMRT.Interrupts.enabled then
		module:UpdateData()
	end
end

function module.options:Load()
	self:CreateTilte()

	--ExRT.lib:Text(self,"v."..VERSION,10):Point("BOTTOMLEFT",self.title,"BOTTOMRIGHT",5,2)

	self.decorationLine = ELib:DecorationLine(self,true,"BACKGROUND",-5):Point("TOPLEFT",self,0,-25):Point("BOTTOMRIGHT",self,"TOPRIGHT",0,-45)

	local chkEnable = ELib:Check(self,L.Enable,VMRT.Interrupts.enabled):Point(560,-26):Size(18,18):AddColorState():TextButton():OnClick(function(self) 
		VMRT.Interrupts.enabled = self:GetChecked() 
		if VMRT.Interrupts.enabled then
			module:Enable()
		else
			module:Disable()
		end
	end)
	
	self.tab = ELib:Tabs(self,0,L.cd2Spells,L.cd2Appearance,ADVANCED_LABEL):Point(0,-45):Size(698,570):SetTo(1)
	self.tab:SetBackdropBorderColor(0,0,0,0)
	self.tab:SetBackdropColor(0,0,0,0)

	local SPELL_LINE_HEIGHT,ALL_LINES_HEIGHT = 26,560

	self.profileDropDown = ELib:DropDown(self.tab.tabs[1],250,#profilesSorted+1):Point("TOPLEFT",390,19):Size(140):SetText(profiles[VMRT.Interrupts.Profile]):AddText(L.InterruptsProfile..":")
	self.profileDropDown:_Size(140,18)
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
				if VMRT.Interrupts.LastUpdateName then
					return L.NoteLastUpdate..": "..VMRT.Interrupts.LastUpdateName.." ("..date("%d.%m.%Y %H:%M",VMRT.Interrupts.LastUpdateTime or 0)..")"
				else
					return ""
				end
			end
		end
	end
	self.profileDropDown.List[#profilesSorted+1] = {text = L.minimapmenuclose,func = ELib.ScrollDropDown.Close}

	self.list = ELib:ScrollFrame(self.tab.tabs[1]):Point("TOPLEFT",0,0):Size(698,ALL_LINES_HEIGHT)
	ELib:Border(self.list,0)

	ELib:DecorationLine(self.tab.tabs[1]):Point("TOP",self.list,"BOTTOM",0,0):Point("LEFT",self):Point("RIGHT",self):Size(0,1)


	self.playerSelect = ELib:Template("ExRTDialogModernTemplate",self)
	self.playerSelect:EnableMouse(true)
	self.playerSelect:SetFrameStrata("DIALOG")
	self.playerSelect.border = ELib:Shadow(self.playerSelect,20)
	self.playerSelect:Hide()
	self.playerSelect:SetSize(100,95)

	local function PlayerSelectButtonOnClick(self)
		local edit = self:GetParent().edit
		edit:SetText(self.name)
		edit:GetScript("OnTextChanged")(edit,true)
		self:GetParent():Hide()	  
	end
	local function PlayerSelectButtonOnEnter(self)
		self.back:Show()	  
	end
	local function PlayerSelectButtonOnLeave(self)
		self.back:Hide()	  
	end

	self.playerSelect.GetNameButton = function(self,posI,posJ)
		local button = self.groups[posI][posJ]
		if not button then
			button = CreateFrame("Button", nil,self)
			self.groups[posI][posJ] = button
			button:SetSize(80,14)
			button:SetPoint("TOPLEFT", 5+(posI-1)*82,-20-(posJ-1)*15)

			button.back = ELib:Texture(button,1,1,1,.2):Point('x')
			button.back:Hide()
	
			button.text = ELib:Text(button,"",10):Color():Point('x')

			button:RegisterForClicks("LeftButtonDown")
			button:SetScript("OnClick", PlayerSelectButtonOnClick)	
			button:SetScript("OnEnter", PlayerSelectButtonOnEnter)	
			button:SetScript("OnLeave", PlayerSelectButtonOnLeave)	
		end
		button:Show()
		return button
	end

	self.playerSelect:SetScript("OnShow",function(self)
		self.groups = self.groups or {{},{},{},{},{},{},{},{}}
		local groupnow = {0,0,0,0,0,0,0,0}
		for _,name,subgroup,class in ExRT.F.IterateRoster do
			groupnow[subgroup] = groupnow[subgroup] + 1
			local cR,cG,cB = ExRT.F.classColorNum(class)

			local obj = self:GetNameButton(subgroup,groupnow[subgroup])
			
			if obj then
				name = ExRT.F.delUnitNameServer(name)
				obj.name = name
				obj.text:SetText(name)
				obj.text:SetTextColor(cR, cG, cB, 1)
			end
		end
		local gMax = 1
		for i=1,8 do
			for j=(groupnow[i]+1),#self.groups[i] do
				self.groups[i][j]:Hide()
			end
			if groupnow[i] > 0 then
				gMax = i
			end
		end
		self:SetWidth(8+82*gMax)
	end)

	self.spellExtraSettings = ELib:Popup():Size(500,105)
	function self.spellExtraSettings:OnShow()
		self.noNextAnnounce:SetChecked(self.data.nonext)

		self.noSpellCastSuccess:SetChecked(self.data.noscs)

		self.showForAll:SetChecked(self.data.all)
	end

	self.spellExtraSettings.noNextAnnounce = ELib:Check(self.spellExtraSettings,L.InterruptsStopNextAnn):Point(15,-15):OnClick(function (self)
		if self:GetChecked() then
			self:GetParent().data.nonext = true
		else
			self:GetParent().data.nonext = nil
		end
		module:UpdateData()
	end)


	self.spellExtraSettings.noSpellCastSuccess = ELib:Check(self.spellExtraSettings,L.InterruptsStopSCS):Point("TOPLEFT",self.spellExtraSettings.noNextAnnounce,"BOTTOMLEFT",0,-5):OnClick(function (self)
		if self:GetChecked() then
			self:GetParent().data.noscs = true
		else
			self:GetParent().data.noscs = nil
		end
		module:UpdateData()
	end)

	self.spellExtraSettings.showForAll = ELib:Check(self.spellExtraSettings,L.InterruptsShowForAllOpt):Point("TOPLEFT",self.spellExtraSettings.noSpellCastSuccess,"BOTTOMLEFT",0,-5):OnClick(function (self)
		if self:GetChecked() then
			self:GetParent().data.all = true
		else
			self:GetParent().data.all = nil
		end
		module:UpdateData()
	end)


	local npcIDtoName = {}
	local npcIDawait = {}

	local function LineNpcIDEditOnChange(self,isUser)
		self:BackgroundTextCheck()
		local text = self:GetText()
		if text == "" then
			text = nil
		end
		self:ColorBorder(text==nil)
		if text then
			local npcName = npcIDtoName[text]
			if not npcName and C_TooltipInfo then
				local tooltip = C_TooltipInfo.GetHyperlink("unit:Creature-0-0-0-0-"..text)
				if tooltip and tooltip.lines and tooltip.lines[1] and tooltip.lines[1].leftText ~= "" then
					npcName = tooltip.lines[1].leftText
				elseif not npcIDawait[text] then
					npcIDawait[text] = true
					C_Timer.After(0.5,function()
						LineNpcIDEditOnChange(self,false)
					end)
				end
				if npcName and npcName ~= "" then
					npcIDtoName[text] = npcName
				end
			end
			self.npcname:SetText(npcName or "")
		else
			self.npcname:SetText("")
		end
		if not isUser then
			return
		end
		self:GetParent().data.data.npcID = text

		module:UpdateData()
	end

	local function LineSpellIDEditOnChange(self,isUser)
		self:BackgroundTextCheck()
		local spellID = tonumber(self:GetText() or "-")
		if spellID then
			local texture = select(3,GetSpellInfo(spellID))
			self:InsideIcon(texture,18)
			self:ColorBorder()
		else
			self:InsideIcon()
			self:ColorBorder(true)
		end
		if not isUser then
			return
		end
		self:GetParent().data.spellData.spellID = spellID

		module:UpdateData()
	end
	local function LineSpellIDEditOnEnter(self)
		local spellID = self:GetText()
		if not spellID then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetHyperlink("spell:"..spellID)
		GameTooltip:Show()
	end
	local function LineSpellIDEditOnLeave(self)
		GameTooltip_Hide()
	end

	local function LineSpellResetEditOnChange(self,isUser)
		self:BackgroundTextCheck()
		if not isUser then
			return
		end
		local reset = self:GetText()
		if reset == "a" then reset = "A" end
		self:GetParent().data.spellData.reset = reset == "A" and reset or tonumber(reset or "-")

		module:UpdateData()
	end

	local function LinePlayerNameEditOnChange(self,isUser)
		self:BackgroundTextCheck()

		local name = self:GetText()
		if name and UnitName(name) then
			local r,g,b = ExRT.F.classColorNum(select(2,UnitClass(name)))
			self:SetTextColor(r,g,b,1)
		elseif name and name:find("%-") and UnitName(strsplit("-",name),nil) then
			local r,g,b = ExRT.F.classColorNum(select(2,UnitClass(strsplit("-",name),nil)))
			self:SetTextColor(r,g,b,1)
		else
			self:SetTextColor(.7,.7,.7,1)
		end

		if name == "" then
			name = nil
		end
		self:ColorBorder(name==nil)

		if not isUser then
			return
		end
		self:GetParent().data.playerData.name = name

		module:UpdateData()
	end

	local function LinePlayerCastEditOnChange(self,isUser)
		self:BackgroundTextCheck()
		local castNum = tonumber(self:GetText() or "-")
		self:ColorBorder(castNum==nil)
		if not isUser then
			return
		end
		self:GetParent().data.playerData.pos = castNum

		module:UpdateData()
	end

	local function LineCheckDisableOnClick(self)
		local data = self:GetParent().data
		local npcID = data.data.npcID
		if not npcID then
			self:SetChecked(false)
			return
		end
		if self:GetChecked() then
			VMRT.Interrupts.Disabled[npcID] = true
		else
			VMRT.Interrupts.Disabled[npcID] = nil
		end

		module:UpdateData()
	end


	local function LineButtonAddNPC(self)
		CURRENT_DATA[#CURRENT_DATA+1] = {
			npcID = "",
			spellData = {},
		}
		module.options.list:UpdateDB()
		module.options.list:Update()
	end
	local function LineButtonAddSpell(self)
		local data = self:GetParent().data.data.spellData
		data[#data+1] = {
			assignments = {},
		}
		module.options.list:UpdateDB()
		module.options.list:Update()
	end
	local function LineButtonAddPlayer(self)
		local data = self:GetParent().data.spellData.assignments
		data[#data+1] = {}
		module.options.list:UpdateDB()
		module.options.list:Update()
	end
	local function LineButtonGetList(self)
		local data = self:GetParent().data.spellData.assignments

		local res = {}
		for i=1,#data do
			if data[i].pos and data[i].name and (not IsShiftKeyDown() or UnitName(data[i].name)) then
				res[#res+1] = {name = data[i].name,mark = data[i].mark or -1,pos = data[i].pos,_i = i}
			end
		end  
		sort(res,function(a,b)
			if a.mark == b.mark then
				if a.pos == b.pos then
					return a._i < b._i
				else
					return a.pos < b.pos
				end
			else
				return a.mark < b.mark
			end
		end)
		local r = "startLine\n"
		local sub = ""
		local opened
		for i=1,#res do
			if (i > 1 and (res[i].mark ~= res[i-1].mark)) or i == 1 then
				if sub ~= "" then 
					r = r .. sub:sub(1,-2) .. "\n"
				end
				sub = (res[i].mark > 0 and "{rt"..res[i].mark.."}" or res[i].mark == 0 and "0" or "Any") .. " "
			end
			if (i < #res and res[i].mark == res[i+1].mark and res[i].pos == res[i+1].pos and not opened) then
				opened = true
				sub = sub .. "("
			end
			sub = sub .. "|cffffffff" .. res[i].name .. "|r "
			if opened and (i == #res or res[i].mark ~= res[i+1].mark or res[i].pos ~= res[i+1].pos) then
				sub = sub:sub(1,-2) .. ") "
				opened = false
			end
		end
		if sub ~= "" then
			r = r .. sub:sub(1,-2) .. "\n"
		end
		r = r .. "endLine"

		ExRT.F:Export(r,true)
	end

	local locals = {
	    --- Raid Target Icon [ENG]
	    {
	        "star",
	        "circle",
	        "diamond",
	        "triangle",
	        "moon",
	        "square",
	        "cross",
	        "skull",
	    },
	    --- Raid Target Icon [DE]
	    {
	        "stern",
	        "kreis",
	        "diamant",
	        "dreieck",
	        "mond",
	        "quadrat",
	        "kreuz",
	        "totenschädel",
	    },
	    --- Raid Target Icon [FR]
	    {
	        "étoile",
	        "cercle",
	        "losange",
	        "triangle",
	        "lune",
	        "carré",
	        "croix",
	        "crâne",
	    },
	    --- Raid Target Icon [IT]
	    {
	        "stella",
	        "cerchio",
	        "rombo",
	        "triangolo",
	        "luna",
	        "quadrato",
	        "croce",
	        "teschio",
	    },
	    --- Raid Target Icon [RU]
	    {
	        "звезда",
	        "круг",
	        "ромб",
	        "треугольник",
	        "полумесяц",
	        "квадрат",
	        "крест",
	        "череп",
	    }
	}
	
	local translateERT = {}
	for _, loc in ipairs(locals) do
		for j, v in ipairs(loc) do
			translateERT[v] = j
		end
	end
	for k, v in pairs(ICON_TAG_LIST) do
		translateERT[k] = v
	end
	translateERT["-1"] = -1	--Any
	translateERT["0 "] = 0	--No mark
	local function LineButtonFromNote(self)
		local data = self:GetParent().data.spellData.assignments
		local npc_data = self:GetParent().data

		if VMRT and VMRT.Note and VMRT.Note.Text1 then
			local text = VMRT.Note.Text1
			--counts lines except gaps
			local betweenLine = false
			local betweenLinev2 = false
			local tmp = {}
			for line in text:gmatch('[^\r\n]+') do
				--searches for "endLine" in Note
				if line == "endLine" then
					betweenLine = false
				elseif line == "intend" then
					betweenLinev2 = false
				end
				if betweenLine then
				--checks if your name is found inbetween startLine and endLine
					local mark = line:match("^{([^}]+)}")
					if not mark then
						mark = line:match("^Any ")
						if mark then mark = "-1" end
					end
					if not mark then
						mark = line:match("^0 ")
					end
					if mark and translateERT[mark] then
						line = line:gsub("^[^ ]+ +","")
						local turn = 0
						local backupsList = {}
						for backups in line:gmatch("%(([^)]*)%)") do
							local isbackup = false
							for name in backups:gmatch("[^ ,]+") do
								name = name:gsub("|+c%x%x%x%x%x%x%x%x",""):gsub("|+r","")
								if isbackup then
									backupsList[name] = true
								end
								isbackup = true
							end 
						end
						for name in line:gmatch("[^ ,%(%)]+") do
							name = name:gsub("|+c%x%x%x%x%x%x%x%x",""):gsub("|+r","")
							if not backupsList[name] then
								turn = turn + 1
							else
								backupsList[name] = nil
							end

							local markID = translateERT[mark]
							if markID == -1 then markID = nil end
							data[#data+1] = {pos = turn, name = name, mark = markID}
						end 
					end
				end
				if betweenLinev2 then
					for id in line:gmatch("spell:(%d+)") do
						tmp.spell[tonumber(id)] = true
					end

					local npc
					for id in line:gmatch("npc:(%d+)") do
						npc = id
					end

					local mark = line:match("^{([^}]+)}")
					if not mark then
						mark = line:match("^Any ")
						if mark then mark = "-1" end
					end
					if not mark then
						mark = line:match("^0 ")
					end
					if mark and translateERT[mark] and npc_data.npcData and npc_data.npcData.npcID == npc and npc_data.spellData and tmp.spell[npc_data.spellData.spellID] then
						line = line:gsub("^[^ ]+ +","")
							:gsub("npc:(%d+)", "")
							:gsub("c?spell:(%d+)", "")
						local turn = 0
						local backupsList = {}
						for backups in line:gmatch("%(([^)]*)%)") do
							local isbackup = false
							for name in backups:gmatch("[^ ,]+") do
								name = name:gsub("|+c%x%x%x%x%x%x%x%x",""):gsub("|+r","")
								if isbackup then
									backupsList[name] = true
								end
								isbackup = true
							end 
						end
						for name in line:gmatch("[^ ,%(%)]+") do
							name = name:gsub("|+c%x%x%x%x%x%x%x%x",""):gsub("|+r","")
							if not backupsList[name] then
								turn = turn + 1
							else
								backupsList[name] = nil
							end

							local markID = translateERT[mark]
							if markID == -1 then markID = nil end
							data[#data+1] = {pos = turn, name = name, mark = markID}
						end
					end
				end
				--searches for "startLine" in Note
				if line == "startLine" then
					betweenLine = true
				elseif line == "intstart" then
					betweenLinev2 = true
					tmp.spell = {}
				end
			end
		end

		module.options.list:UpdateDB()
		module.options.list:Update()
	end

	function self:NPCID_GetOrCreate(npcID)
		for i=1,#CURRENT_DATA do
			local data = CURRENT_DATA[i]
			if data.npcID == npcID then
				return data
			end
		end
		local new = {
			npcID = npcID,
			spellData = {},
		}
		CURRENT_DATA[ #CURRENT_DATA+1 ] = new
		return new
	end

	function self:SPELLID_GetOrCreate(npcData,spellID)
		for i=1,#npcData.spellData do
			local data = npcData.spellData[i]
			if data.spellID == spellID then
				return data
			end
		end
		local new = {
			spellID = spellID,
			assignments = {},
		}
		npcData.spellData[ #npcData.spellData+1 ] = new
		return new
	end

	local function LineButtonFromNoteGlobal(self)
		if VMRT and VMRT.Note and VMRT.Note.Text1 then
			local text = VMRT.Note.Text1
			--counts lines except gaps
			local betweenLine = false
			local betweenLinev2 = false
			local tmp = {}
			for line in text:gmatch('[^\r\n]+') do
				--searches for "endLine" in Note
				if line == "endLine" then
					betweenLine = false
				elseif line == "intend" then
					betweenLinev2 = false
				end
				if betweenLinev2 then
					for id in line:gmatch("spell:(%d+)") do
						tmp.spell[tonumber(id)] = true
						tmp.lastspell = tonumber(id)
					end

					local npc
					for id in line:gmatch("npc:(%d+)") do
						npc = id
					end

					local mark = line:match("^{([^}]+)}")
					if not mark then
						mark = line:match("^Any ")
						if mark then mark = "-1" end
					end
					if not mark then
						mark = line:match("^0 ")
					end

					if mark and translateERT[mark] and npc and tmp.lastspell then
						local npcData = module.options:NPCID_GetOrCreate(npc)
						local spellData = module.options:SPELLID_GetOrCreate(npcData,tmp.lastspell)
						local data = spellData.assignments
	
						line = line:gsub("^[^ ]+ +","")
							:gsub("npc:(%d+)", "")
							:gsub("c?spell:(%d+)", "")
						local turn = 0
						local backupsList = {}
						for backups in line:gmatch("%(([^)]*)%)") do
							local isbackup = false
							for name in backups:gmatch("[^ ,]+") do
								name = name:gsub("|+c%x%x%x%x%x%x%x%x",""):gsub("|+r","")
								if isbackup then
									backupsList[name] = true
								end
								isbackup = true
							end 
						end
						for name in line:gmatch("[^ ,%(%)]+") do
							name = name:gsub("|+c%x%x%x%x%x%x%x%x",""):gsub("|+r","")
							if not backupsList[name] then
								turn = turn + 1
							else
								backupsList[name] = nil
							end

							local markID = translateERT[mark]
							if markID == -1 then markID = nil end
							data[#data+1] = {pos = turn, name = name, mark = markID}
						end
					end
				end
				--searches for "startLine" in Note
				if line == "startLine" then
					betweenLine = true
				elseif line == "intstart" then
					betweenLinev2 = true
					tmp.spell = {}
				end
			end
		end

		module.options.list:UpdateDB()
		module.options.list:Update()
	end

	local function LineButtonRemoveNPC(self)
		local data = self:GetParent().data.data
		StaticPopupDialogs["EXRT_INTERRUPTS_POPUP"] = {
			text = "Remove NPC "..(data.npcID or ""),
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				for i=1,#CURRENT_DATA do
					if CURRENT_DATA[i] == data then
						tremove(CURRENT_DATA,i)
						break
					end
				end
				module.options.list:UpdateDB()
				module.options.list:Update()

				module:UpdateData()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_INTERRUPTS_POPUP")
	end

	local function CopyClickDropDownFunc(self,arg1)
		tinsert(VMRT.Interrupts.Data[arg1],ExRT.F.table_copy2(self:GetParent().parent.copiedData))

		ELib:DropDownClose()

		module:SetProfile(arg1)
	end

	self.copyClickDropDown = ELib:DropDownButton(self,"",250,#profilesSorted+1)
	self.copyClickDropDown.isModern = true
	for i=1,#profilesSorted do
		self.copyClickDropDown.List[i] = {text = L.InterruptsCopyTo.." "..profiles[ profilesSorted[i] ], arg1 = profilesSorted[i], func = CopyClickDropDownFunc}
	end
	self.copyClickDropDown.List[#profilesSorted+1] = {text = L.minimapmenuclose,func = ELib.ScrollDropDown.Close}
	
	self.copyClickDropDown:Hide()

	local function LineButtonCopyNPC(self)
		local data = self:GetParent().data.data

		module.options.copyClickDropDown.copiedData = data
		for i=1,#profilesSorted do
			local line = module.options.copyClickDropDown.List[i]
			if line.arg1 == VMRT.Interrupts.Profile then
				line.isTitle = true
			else
				line.isTitle = false
			end
		end

		local x,y = ExRT.F.GetCursorPos(self)
		module.options.copyClickDropDown:SetPoint("TOPLEFT",self,x,-y)
		module.options.copyClickDropDown:Click()
	end

	local function LineButtonRemoveSpell(self)
		local data = self:GetParent().data
		StaticPopupDialogs["EXRT_INTERRUPTS_POPUP"] = {
			text = "Remove Spell "..(data.spellData.spellID or ""),
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				for i=1,#data.data.spellData do
					if data.data.spellData[i] == data.spellData then
						tremove(data.data.spellData,i)
						break
					end
				end
				module.options.list:UpdateDB()
				module.options.list:Update()

				module:UpdateData()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_INTERRUPTS_POPUP")
	end

	local function LineButtonRemovePlayer(self)
		local data = self:GetParent().data
		for i=1,#data.spellData.assignments do
			if data.spellData.assignments[i] == data.playerData then
				tremove(data.spellData.assignments,i)
				break
			end
		end
		module.options.list:UpdateDB()
		module.options.list:Update()

		module:UpdateData()
	end

	local function LineButtonSelectPlayer(self)
		module.options.playerSelect:ClearAllPoints()
		module.options.playerSelect:SetPoint("TOP",self,"BOTTOM",0,-1)
		module.options.playerSelect.edit = self:GetParent().player
		module.options.playerSelect:Show()
	end

	local conditionsList, conditionsListDD = {
		{1,ExRT.F.GetRaidTargetText(1,20)},
		{2,ExRT.F.GetRaidTargetText(2,20)},
		{3,ExRT.F.GetRaidTargetText(3,20)},
		{4,ExRT.F.GetRaidTargetText(4,20)},
		{5,ExRT.F.GetRaidTargetText(5,20)},
		{6,ExRT.F.GetRaidTargetText(6,20)},
		{7,ExRT.F.GetRaidTargetText(7,20)},
		{8,ExRT.F.GetRaidTargetText(8,20)},
		{0,L.InterruptsNoMark},
		{nil,L.InterruptsAllTargets},
	}, {}
	if RAID_TARGET_USE_EXTRA then
		for i=16,9,-1 do
			tinsert(conditionsList,9,{i,ExRT.F.GetRaidTargetText(i,20)})
		end
	end


	do
		local function conditionList_SetValue(self,arg1)
			ELib:DropDownClose()
			self:GetParent().parent:GetParent().data.playerData.mark = arg1
			module.options.list:UpdateDB()
			module.options.list:Update()

			module:UpdateData()
		end
		
		for i=1,#conditionsList do
			conditionsListDD[#conditionsListDD+1] = {
				text = conditionsList[i][2],
				arg1 = conditionsList[i][1],
				func = conditionList_SetValue,
			}
		end
	end

	local function LineShowTypes(self,t)
		for k,v in pairs(self) do
			if type(v)=='table' and v.Ltype then
				v:SetShown(t[v.Ltype])
			end
		end
	end

	local function LinePlayerNameEditOnDragStart(self)
		if self:IsMovable() then
			self.point = {self:GetPoint()}

			self:StartMoving()
		end	  
	end
	local function LinePlayerNameEditOnDragStop(self)
		self:StopMovingOrSizing()

		for i=1,#module.options.list.lines do
			local edit2 = module.options.list.lines[i].player
			if edit2:IsMouseOver() and edit2 ~= self and edit2:IsShown() then
				local data1 = self:GetParent().data
				local data2 = edit2:GetParent().data
				if data1.data == data2.data then
					local pos1, pos2
					for j=1,#data1.spellData.assignments do
						if data1.spellData.assignments[j] == data1.playerData then
							pos1 = j
						elseif data2.spellData.assignments[j] == data2.playerData then
							pos2 = j
						end
					end
					if pos1 and pos2 then
						--[[
						tremove(data1.spellData.assignments, pos1)
						tinsert(data1.spellData.assignments, pos1, data2.playerData)

						tremove(data1.spellData.assignments, pos2)
						tinsert(data1.spellData.assignments, pos2, data1.playerData)
						]]

						tremove(data1.spellData.assignments, pos1)
						tinsert(data1.spellData.assignments, pos2, data1.playerData)

						module.options.list:UpdateDB()
						module.options.list:Update()
					end
				end
				break
			end
		end

		self:NewPoint(unpack(self.point)) 

		self:ClearFocus() 
	end

	local function LineSpellIDExtraClick(self)
		if not self.data then
			return
		end
		module.options.spellExtraSettings.data = self.data
		module.options.spellExtraSettings:Show()
	end

	self.list.lines = {}
	for i=1,ceil(ALL_LINES_HEIGHT/SPELL_LINE_HEIGHT)+2 do
		local line = CreateFrame("Frame",nil,self.list.C)
		self.list.lines[i] = line
		line:SetPoint("TOPLEFT",0,-(i-1)*SPELL_LINE_HEIGHT)
		line:SetPoint("RIGHT",0,0)
		line:SetHeight(SPELL_LINE_HEIGHT)

		line.npcid = ELib:Edit(line,nil,true):Size(70,20):Point("LEFT",10,0):OnChange(LineNpcIDEditOnChange):BackgroundText("Npc ID")
		line.npcid.Ltype = 1

		line.removeNpc = ELib:Button(line,""):Size(12,20):Point("LEFT",line.npcid,"RIGHT",3,0):OnClick(LineButtonRemoveNPC)
		ELib:Text(line.removeNpc,"x"):Point("CENTER",0,0)
		line.removeNpc.Texture:SetGradient("VERTICAL",CreateColor(0.35,0.06,0.09,1), CreateColor(0.50,0.21,0.25,1))
		line.removeNpc.Ltype = 1

		line.copyNpc = ELib:Button(line,""):Size(12,20):Point("LEFT",line.removeNpc,"RIGHT",1,0):Tooltip(L.InterruptsCopyTo.."..."):OnClick(LineButtonCopyNPC)
		ELib:Text(line.copyNpc,">"):Point("CENTER",0,0)
		line.copyNpc.Ltype = 1

		line.npcid.npcname = ELib:Text(line,"",8):Point("TOPLEFT",line.npcid,"BOTTOMLEFT",0,-2):Point("TOPRIGHT",line.copyNpc,"BOTTOMRIGHT",0,-2):Size(0,SPELL_LINE_HEIGHT):Top():Left()

		line.disableChk = ELib:Check(line,""):Size(20,20):Point("LEFT",line.copyNpc,"RIGHT",5,0):Tooltip(L.InterruptsDisableForMe):OnClick(LineCheckDisableOnClick):Run(function(self)
			self.CheckedTexture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_7")
			self.CheckedTexture:SetPoint("TOPLEFT",1,-1)
			self.CheckedTexture:SetPoint("BOTTOMRIGHT",-1,1)
			self.CheckedTexture:SetVertexColor(.9,.9,.9,1)

			self.PushedTexture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_7")
			self.PushedTexture:SetPoint("TOPLEFT",1,-1)
			self.PushedTexture:SetPoint("BOTTOMRIGHT",-1,1)
			self.PushedTexture:SetVertexColor(.8,.8,.8,.5)
		end)
		line.disableChk.Ltype = 1

		line.spellid = ELib:Edit(line,nil,true):Size(80,20):Point("LEFT",line.disableChk,"RIGHT",15,0):OnChange(LineSpellIDEditOnChange):BackgroundText("Spell ID"):OnEnter(LineSpellIDEditOnEnter):OnLeave(LineSpellIDEditOnLeave)
		line.spellid.Ltype = 2

		line.spellExtraButton = ELib:Button(line,""):Size(15,20):Point("LEFT",line.spellid,"RIGHT",3,0):Tooltip(L.InterruptsAdditionalOpts):OnClick(LineSpellIDExtraClick)
		ELib:Text(line.spellExtraButton,"E"):Point("CENTER",0,0)
		--line.spellExtraButton.Texture:SetGradientAlpha("VERTICAL",0.35,0.06,0.09,1, 0.50,0.21,0.25,1)
		line.spellExtraButton.Ltype = 2

		line.reset = ELib:Edit(line,nil,false):Size(55,20):Point("LEFT",line.spellExtraButton,"RIGHT",3,0):OnChange(LineSpellResetEditOnChange):BackgroundText("Reset"):Tooltip("Number of casts after which the counter will reset to 1.\nYou can use \"|cff00ff00A|r\" for autoreset based on maximum assigned number for |cffffffffselected mark|r.")
		line.reset.Ltype = 2

		line.removeSpell = ELib:Button(line,""):Size(12,20):Point("LEFT",line.reset,"RIGHT",3,0):OnClick(LineButtonRemoveSpell)
		ELib:Text(line.removeSpell,"x"):Point("CENTER",0,0)
		line.removeSpell.Texture:SetGradient("VERTICAL",CreateColor(0.35,0.06,0.09,1), CreateColor(0.50,0.21,0.25,1))
		line.removeSpell.Ltype = 2

		line.player = ELib:Edit(line):Size(140,20):Point("LEFT",line.removeSpell,"RIGHT",15,0):OnChange(LinePlayerNameEditOnChange):BackgroundText("Player name")
		line.player.Ltype = 3

		line.player:SetMovable(true)
		line.player:RegisterForDrag("LeftButton")
		line.player:SetScript("OnDragStart", LinePlayerNameEditOnDragStart)
		line.player:SetScript("OnDragStop", LinePlayerNameEditOnDragStop)

		line.selectPlayer = ELib:Template("ExRTDropDownButtonModernTemplate",line)
		line.selectPlayer:SetPoint("LEFT",line.player,"RIGHT",2,0)
		line.selectPlayer:SetSize(20,20)
		line.selectPlayer:SetScript("OnClick",LineButtonSelectPlayer)
		line.selectPlayer.Ltype = 3

		line.mark = ELib:DropDown(line,150,#conditionsList):Size(100):Point("LEFT",line.selectPlayer,"RIGHT",5,0):SetText("-")
		line.mark.List = conditionsListDD
		line.mark.Ltype = 3

		line.castnum = ELib:Edit(line):Size(50,20):Point("LEFT",line.mark,"RIGHT",5,0):OnChange(LinePlayerCastEditOnChange):BackgroundText("Cast num")
		line.castnum.Ltype = 3

		line.removePlayer = ELib:Button(line,""):Size(12,20):Point("LEFT",line.castnum,"RIGHT",3,0):OnClick(LineButtonRemovePlayer)
		ELib:Text(line.removePlayer,"x"):Point("CENTER",0,0)
		line.removePlayer.Texture:SetGradient("VERTICAL",CreateColor(0.35,0.06,0.09,1), CreateColor(0.50,0.21,0.25,1))
		line.removePlayer.Ltype = 3

		line.newSpell = ELib:Button(line,"+spell"):Size(0,20):Point("LEFT",line.spellid,0,0):Point("RIGHT",line.removeSpell,0,0):OnClick(LineButtonAddSpell)
		line.newSpell.Ltype = 4

		line.getList = ELib:Button(line,L.InterruptsGetList):Size(90,20):Point("RIGHT",line.removePlayer,0,0):OnClick(LineButtonGetList):Tooltip(L.InterruptsGetListTooltip)
		line.getList.Ltype = 5

		line.fromNote = ELib:Button(line,L.InterruptsFromNote):Size(90,20):Point("RIGHT",line.getList,"LEFT",-5,0):OnClick(LineButtonFromNote):Tooltip(L.InterruptsFromNoteTooltip)
		line.fromNote.Ltype = 5

		line.newPlayer = ELib:Button(line,"+player"):Size(0,20):Point("LEFT",line.player,0,0):Point("RIGHT",line.fromNote,"LEFT",-5,0):OnClick(LineButtonAddPlayer)
		line.newPlayer.Ltype = 5

		line.newNpc = ELib:Button(line,"+npc"):Size(0,20):Point("LEFT",line.npcid,0,0):Point("RIGHT",line.copyNpc,0,0):OnClick(LineButtonAddNPC)
		line.newNpc.Ltype = 6

		line.fromNoteGlobal = ELib:Button(line,L.InterruptsFromNote):Size(0,20):Point("LEFT",line.newNpc,"RIGHT",5,0):OnClick(LineButtonFromNoteGlobal):Tooltip("Import interrupts for multiple npc/spells from note.\nOnly new format with intstart - intend supported")
		line.fromNoteGlobal.Ltype = 6
		line.fromNoteGlobal:SetWidth( 100 )

		line.back = ELib:Texture(line,1,1,1,.05):Point('x'):Shown(false)

		line.ShowTypes = LineShowTypes
	end

	function self.list:UpdateDB()
		local list = {}
		local isOdd = true
		for i=1,#CURRENT_DATA do
			isOdd = not isOdd
			local data = CURRENT_DATA[i]
			local npcid = {
				data = data,
				[1] = true,
				[4] = true,
				isOdd = isOdd,
			}
			list[#list+1] = npcid
			for j=1,#data.spellData do
				local spellid
				if j==1 then
					spellid = npcid
					spellid[4] = nil
				end
				spellid = spellid or {
					data = data,
					isOdd = isOdd,
				}
				
				local spellData = data.spellData[j]
				spellid.spellData = spellData
				spellid[2] = true
				spellid[5] = true

				if spellid ~= npcid then
					list[#list+1] = spellid
				end
				for k=1,#spellData.assignments do
					local player
					if k==1 then
						player = spellid
						player[5] = nil
					end

					player = player or {
						spellData = spellData,
						data = data,
						isOdd = isOdd,
					}
					player.playerData = spellData.assignments[k]
					player[3] = true
					if player ~= spellid then
						list[#list+1] = player
					end
				end
				if not list[#list][5] then
					list[#list+1] = {
						spellData = spellData,
						npcData = data,
						[5]=true,
						isOdd = isOdd,
					}
				end
			end
			if not list[#list][4] then
				list[#list+1] = {
					data = data,
					[4]=true,
					isOdd = isOdd,
				}
			end
		end
		list[#list+1] = {
			[6]=true,
			isOdd = not isOdd,
		}
		self.list = list
	end

	function self.list:Update()
		local scroll = self.ScrollBar:GetValue()
		self:SetVerticalScroll(scroll % SPELL_LINE_HEIGHT) 

		local start = floor(scroll / SPELL_LINE_HEIGHT) + 1

		local prevNPC

		local list = self.list
		local lineCount = 1
		for i=start,#list do
			local line = self.lines[lineCount]
			lineCount = lineCount + 1
			if not line then
				break
			end
			local data = list[i]

			line:ShowTypes(data)

			if data.data then
				line.npcid:SetText(data.data.npcID or "")
				if data.data.npcID then
					line.disableChk:SetChecked(VMRT.Interrupts.Disabled[data.data.npcID])
				end

				if list[i+1] and not list[i+1][1] and not list[i+1][6] and prevNPC ~= data.data.npcID then
					prevNPC = data.data.npcID
					line.npcid.npcname:Show()
				else
					line.npcid.npcname:Hide()
				end
				--line.npcid.npcname:SetShown(list[i+1] and not list[i+1][1] and not list[i+1][6])
			else
				line.npcid:SetText("")
				line.npcid.npcname:Hide()
			end
			if data.spellData then
				line.spellid:SetText(data.spellData.spellID or "")
				line.reset:SetText(data.spellData.reset or "")
				line.spellExtraButton.data = data.spellData
			end
			if data.playerData then
				line.player:SetText(data.playerData.name or "")
				line.castnum:SetText(data.playerData.pos or "")
				for j=1,#conditionsList do
					if conditionsList[j][1] == data.playerData.mark then
						line.mark:SetText(conditionsList[j][2])
					end
				end
			end
			line.data = data

			line.back:Shown(data.isOdd)

			line:Show()
		end
		for i=lineCount,#self.lines do
			self.lines[i]:Hide()
		end
		self:Height(SPELL_LINE_HEIGHT * #list)	
	end
	self.list.ScrollBar.slider:SetScript("OnValueChanged", function(self)
		self:GetParent():GetParent():Update()
		self:UpdateButtons()
	end)

	self.list:UpdateDB()
	self.list:Update()


	self.SyncButton = ELib:Button(self.tab.tabs[1],L.messagebutsend):Point("TOPLEFT",self.list,"BOTTOMLEFT",5,-5):Size(140,20):OnClick(function()
		module:Sync()
	end)


	self.importWindow, self.exportWindow = ExRT.F.CreateImportExportWindows()

	function self.importWindow:ImportFunc(str)
		local header = str:sub(1,9)
		if header:sub(1,8) ~= "EXRTIRRU" or (header:sub(9,9) ~= "0" and header:sub(9,9) ~= "1") then
			StaticPopupDialogs["EXRT_IRRU_IMPORT"] = {
				text = "|cffff0000"..ERROR_CAPS.."|r "..L.ProfilesFail3,
				button1 = OKAY,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("EXRT_IRRU_IMPORT")
			return
		end

		self:TextToProfile(str:sub(10),header:sub(9,9)=="0")
	end

	function self.importWindow:TextToProfile(str,uncompressed)
		local decoded = LibDeflate:DecodeForPrint(str)
		local decompressed
		if uncompressed then
			decompressed = decoded
		else
			decompressed = LibDeflate:DecompressDeflate(decoded)
		end
		decoded = nil

		module:ProcessTextToData(decompressed,true)
		decompressed = nil
	end


	self.ExportButton = ELib:Button(self.tab.tabs[1],L.Export):Point("TOPRIGHT",self.list,"BOTTOMRIGHT",-5,-5):Size(100,20):OnClick(function()
		local export = module:Sync(true)

		self:ExportStr(export)
	end)

	function self:ExportStr(export)
		module.options.exportWindow:NewPoint("CENTER",UIParent,0,0)

		local compressed
		if #export < 1000000 then
			compressed = LibDeflate:CompressDeflate(export,{level = 5})
		end
		local encoded = "EXRTIRRU"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or export)
	
		ExRT.F.dprint("Str len:",#export,"Encoded len:",#encoded)
	
		module.options.exportWindow.Edit:SetText(encoded)
		module.options.exportWindow:Show()
	end

	self.ImportButton = ELib:Button(self.tab.tabs[1],L.Import):Point("RIGHT",self.ExportButton,"LEFT",-5,0):Size(100,20):OnClick(function()
		self.importWindow:NewPoint("CENTER",UIParent,0,0)
		self.importWindow:Show()
	end)



	self.SliderSize = ELib:Slider(self.tab.tabs[2],L.InterruptsIconSize):Size(400):Point("TOPLEFT",20,-20):Range(5,200):SetTo(VMRT.Interrupts.Size or defOption.Size):OnChange(function(self,event) 
		event = floor(event)
		VMRT.Interrupts.Size = event
		self.tooltipText = event
		self:tooltipReload(self)

		module:UpdateVisual()
	end)

	ELib:Text(self.tab.tabs[2],L.InterruptsCastNum..":",12):Point("TOPLEFT",15,-55):Color():Left()

	self.SliderFontSize = ELib:Slider(self.tab.tabs[2],L.InterruptsFontSize):Size(200):Point("TOPLEFT",160,-55):Range(5,200):SetTo(VMRT.Interrupts.FontSize or defOption.FontSize):OnChange(function(self,event) 
		event = floor(event)
		VMRT.Interrupts.FontSize = event
		self.tooltipText = event
		self:tooltipReload(self)

		module:UpdateVisual()
	end)

	local function dropDownFontSetValue(_,arg1)
		ELib:DropDownClose()
		VMRT.Interrupts.Font = arg1
		self.dropDownFont:SetText(arg1)
		module:UpdateVisual()
	end

	self.dropDownFont = ELib:DropDown(self.tab.tabs[2],350,10):Size(230):Point("LEFT",self.SliderFontSize,"RIGHT",90,-2):SetText(VMRT.Interrupts.Font or defOption.Font):AddText(L.InterruptsFont..":")
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


	ELib:Text(self.tab.tabs[2],L.InterruptsKickerNick..":",12):Point("TOPLEFT",15,-85):Color():Left()

	self.SliderKickerFontSize = ELib:Slider(self.tab.tabs[2],L.InterruptsFontSize):Size(200):Point("TOPLEFT",160,-85):Range(5,200):SetTo(VMRT.Interrupts.KickerFontSize or defOption.KickerFontSize):OnChange(function(self,event) 
		event = floor(event)
		VMRT.Interrupts.KickerFontSize = event
		self.tooltipText = event
		self:tooltipReload(self)

		module:UpdateVisual()
	end)

	local function dropDownKickerFontSetValue(_,arg1)
		ELib:DropDownClose()
		VMRT.Interrupts.KickerFont = arg1
		self.dropDownKickerFont:SetText(arg1)
		module:UpdateVisual()
	end

	self.dropDownKickerFont = ELib:DropDown(self.tab.tabs[2],350,10):Size(230):Point("LEFT",self.SliderKickerFontSize,"RIGHT",90,-2):SetText(VMRT.Interrupts.KickerFont or defOption.KickerFont):AddText(L.InterruptsFont..":")
	for i=1,#ExRT.F.fontList do
		local info = {}
		self.dropDownKickerFont.List[i] = info
		info.text = ExRT.F.fontList[i]
		info.arg1 = ExRT.F.fontList[i]
		info.func = dropDownKickerFontSetValue
		info.font = ExRT.F.fontList[i]
		info.justifyH = "CENTER" 
	end
	for key,font in ExRT.F.IterateMediaData("font") do
		local info = {}
		self.dropDownKickerFont.List[#self.dropDownKickerFont.List+1] = info
		
		info.text = key
		info.arg1 = font
		info.func = dropDownKickerFontSetValue
		info.font = font
		info.justifyH = "CENTER" 
	end
	

	local function dropDownSoundNextSetValue(_,arg1)
		ELib:DropDownClose()
		VMRT.Interrupts.SoundNext = arg1
		self.dropDownSoundNext:SetText(arg1)
		module:UpdateVisual()
		pcall(PlaySoundFile,arg1,"MASTER")
	end

	local sounds = {
		{"","No sound"},
		{"Interface\\AddOns\\MRT\\media\\Sounds\\RingingPhone.ogg","RingingPhone"},
		{"Interface\\AddOns\\MRT\\media\\Sounds\\Next.ogg","Next"},
		{"Interface\\AddOns\\MRT\\media\\Sounds\\Interrupt.ogg","Interrupt"},
		{"Interface\\AddOns\\MRT\\media\\Sounds\\AirHorn.ogg","AirHorn"},
		{"Interface\\AddOns\\MRT\\media\\Sounds\\BikeHorn.ogg","BikeHorn"},
	}

	self.dropDownSoundNext = ELib:DropDown(self.tab.tabs[2],350,10):Size(320):Point("TOPLEFT",100,-110):SetText(VMRT.Interrupts.SoundNext or defOption.SoundNext):AddText(L.InterruptsSoundNext..":")
	for i=1,#sounds do
		local info = {}
		self.dropDownSoundNext.List[i] = info
		info.text = sounds[i][2]
		info.arg1 = sounds[i][1]
		info.func = dropDownSoundNextSetValue
	end
	for key,sound in ExRT.F.IterateMediaData("sound") do
		local info = {}
		self.dropDownSoundNext.List[#self.dropDownSoundNext.List+1] = info
		
		info.text = key
		info.arg1 = sound
		info.func = dropDownSoundNextSetValue
	end

	local function dropDownSoundKickSetValue(_,arg1)
		ELib:DropDownClose()
		VMRT.Interrupts.SoundKick = arg1
		self.dropDownSoundKick:SetText(arg1)
		module:UpdateVisual()
		pcall(PlaySoundFile,arg1,"MASTER")
	end

	self.dropDownSoundKick = ELib:DropDown(self.tab.tabs[2],350,10):Size(320):Point("TOPLEFT",100,-135):SetText(VMRT.Interrupts.SoundKick or defOption.SoundKick):AddText(L.InterruptsSoundKick..":")
	for i=1,#sounds do
		local info = {}
		self.dropDownSoundKick.List[i] = info
		info.text = sounds[i][2]
		info.arg1 = sounds[i][1]
		info.func = dropDownSoundKickSetValue
	end
	for key,sound in ExRT.F.IterateMediaData("sound") do
		local info = {}
		self.dropDownSoundKick.List[#self.dropDownSoundKick.List+1] = info
		
		info.text = key
		info.arg1 = sound
		info.func = dropDownSoundKickSetValue
	end


	local posAnchor = {
		[1] = L.InterruptsPosTop,
		[2] = L.InterruptsPosBottom,
		[3] = L.InterruptsPosLeft,
		[4] = L.InterruptsPosRight,
	}

	local function dropDownPosAnchorSetValue(_,arg1)
		ELib:DropDownClose()
		VMRT.Interrupts.Anchor = arg1
		self.dropDownPosAnchor:SetText(posAnchor[arg1])
		module:UpdateVisual()
		module:ReloadAll()
	end


	self.dropDownPosAnchor = ELib:DropDown(self.tab.tabs[2],350,-1):Size(200):Point("TOPLEFT",220,-165):SetText(posAnchor[VMRT.Interrupts.Anchor or defOption.Anchor]):AddText(L.InterruptsAnchorPos..":")
	for k,v in pairs(posAnchor) do
		local info = {}
		self.dropDownPosAnchor.List[#self.dropDownPosAnchor.List+1] = info
		info.text = v
		info.arg1 = k
		info.func = dropDownPosAnchorSetValue
	end

	ELib:Text(self.tab.tabs[2],L.InterruptsOffset..":",12):Point("TOPLEFT",15,-205):Color():Left()

	self.SliderAnchorOffsetY = ELib:Slider(self.tab.tabs[2],L.InterruptsByVertical):Size(200):Point("TOPLEFT",160,-205):Range(-1000,1000):SetTo(VMRT.Interrupts.AnchorOffsetY or defOption.AnchorOffsetY):OnChange(function(self,event) 
		event = floor(event)
		VMRT.Interrupts.AnchorOffsetY = event
		self.tooltipText = event
		self:tooltipReload(self)

		module:UpdateVisual()
		module:ReloadAll()
	end)

	self.SliderAnchorOffsetX = ELib:Slider(self.tab.tabs[2],L.InterruptsByHorizontal):Size(200):Point("LEFT",self.SliderAnchorOffsetY,"RIGHT",50,0):Range(-1000,1000):SetTo(VMRT.Interrupts.AnchorOffsetX or defOption.AnchorOffsetX):OnChange(function(self,event) 
		event = floor(event)
		VMRT.Interrupts.AnchorOffsetX = event
		self.tooltipText = event
		self:tooltipReload(self)

		module:UpdateVisual()
		module:ReloadAll()
	end)

	self.SliderAlpha = ELib:Slider(self.tab.tabs[2],L.InterruptsTransparent):Size(400):Point("TOPLEFT",20,-240):Range(0,100):SetTo((VMRT.Interrupts.Alpha or defOption.Alpha)*100):OnChange(function(self,event) 
		event = floor(event)
		VMRT.Interrupts.Alpha = event / 100
		self.tooltipText = event
		self:tooltipReload(self)

		module:UpdateVisual()
	end)

	self.chkShowNextKickName = ELib:Check(self.tab.tabs[2],L.InterruptsNextPlayerName,not VMRT.Interrupts.HideNext):Point(10,-270):OnClick(function(self) 
		VMRT.Interrupts.HideNext = not self:GetChecked()

		module:UpdateVisual()
	end)
	self.chkNextKickInside = ELib:Check(self.tab.tabs[2],L.InterruptsNextPlayerInside,VMRT.Interrupts.NextInside):Point(10,-295):OnClick(function(self) 
		VMRT.Interrupts.NextInside = self:GetChecked()

		module:UpdateVisual()
	end)
	self.chkShowGlow = ELib:Check(self.tab.tabs[2],L.InterruptsGlow,VMRT.Interrupts.ShowGlow):Point(10,-320):OnClick(function(self) 
		VMRT.Interrupts.ShowGlow = self:GetChecked()

		module:UpdateVisual()
	end)
	self.chkShowGlow = ELib:Check(self.tab.tabs[2],L.InterruptsChangeBackgroundColor,not VMRT.Interrupts.NotShowColor):Point(10,-345):OnClick(function(self) 
		VMRT.Interrupts.NotShowColor = not self:GetChecked()

		module:UpdateVisual()
	end)

	self.ResetColorsButton = ELib:Button(self.tab.tabs[2],L.InterruptsResetColors):Point(10,-370):Size(300,20):OnClick(function()
		local color_names = {"nocast","cast","minenocast","minecast"}
		for i=1,4 do
			for j=1,2 do
				local var = color_names[i] .. (j==2 and "_text" or "")
				VMRT.Interrupts[var] = nil
				module.options["color"..var].color:SetColorTexture(unpack(defOption[var]))
			end
		end
		module:UpdateVisual()
	end)

	self.PreviewFrameLoad = ELib:Frame(self.tab.tabs[2]):Point("TOPLEFT"):Size(1,1):OnShow(function(self)
		module.options.PreviewFrame1 = module:GetFrame()
		module.options.PreviewFrame1:SetParent(module.options.tab.tabs[2])
		module.options.PreviewFrame1:ClearAllPoints()
		module.options.PreviewFrame1:SetPoint("BOTTOM",-225,70)
		module:UpdateFrame2(module.options.PreviewFrame1,1,false,false)
		module.options.PreviewFrame1.isPreview = true
		module.options.PreviewFrame1:Show()
		ELib:Text(module.options.PreviewFrame1,L.InterruptsNoCastNoMine,10):Point("TOP",module.options.PreviewFrame1,"BOTTOM",0,-10):Color():Center()

		module.options["colornocast"]:ClearAllPoints()
		module.options["colornocast"]:SetPoint("TOPLEFT",module.options.PreviewFrame1,"BOTTOMLEFT",0,-40)

		module.options.PreviewFrame2 = module:GetFrame()
		module.options.PreviewFrame2:SetParent(module.options.tab.tabs[2])
		module.options.PreviewFrame2:ClearAllPoints()
		module.options.PreviewFrame2:SetPoint("BOTTOM",-75,70)
		module:UpdateFrame2(module.options.PreviewFrame2,2,true,false)
		module.options.PreviewFrame2.isPreview = true
		module.options.PreviewFrame2:Show()
		ELib:Text(module.options.PreviewFrame2,L.InterruptsCastNoMine,10):Point("TOP",module.options.PreviewFrame2,"BOTTOM",0,-10):Color():Center()

		module.options["colorcast"]:ClearAllPoints()
		module.options["colorcast"]:SetPoint("TOPLEFT",module.options.PreviewFrame2,"BOTTOMLEFT",0,-40)

		module.options.PreviewFrame3 = module:GetFrame()
		module.options.PreviewFrame3:SetParent(module.options.tab.tabs[2])
		module.options.PreviewFrame3:ClearAllPoints()
		module.options.PreviewFrame3:SetPoint("BOTTOM",75,70)
		module:UpdateFrame2(module.options.PreviewFrame3,3,false,true)
		module.options.PreviewFrame3.isPreview = true
		module.options.PreviewFrame3:Show()
		ELib:Text(module.options.PreviewFrame3,L.InterruptsNoCastMine,10):Point("TOP",module.options.PreviewFrame3,"BOTTOM",0,-10):Color():Center()

		module.options["colorminenocast"]:ClearAllPoints()
		module.options["colorminenocast"]:SetPoint("TOPLEFT",module.options.PreviewFrame3,"BOTTOMLEFT",0,-40)

		module.options.PreviewFrame4 = module:GetFrame()
		module.options.PreviewFrame4:SetParent(module.options.tab.tabs[2])
		module.options.PreviewFrame4:ClearAllPoints()
		module.options.PreviewFrame4:SetPoint("BOTTOM",225,70)
		module:UpdateFrame2(module.options.PreviewFrame4,4,true,true)
		module.options.PreviewFrame4.isPreview = true
		module.options.PreviewFrame4:Show()
		ELib:Text(module.options.PreviewFrame4,L.InterruptsCastMine,10):Point("TOP",module.options.PreviewFrame4,"BOTTOM",0,-10):Color():Center()

		module.options["colorminecast"]:ClearAllPoints()
		module.options["colorminecast"]:SetPoint("TOPLEFT",module.options.PreviewFrame4,"BOTTOMLEFT",0,-40)

		self:OnShow()
	end,true)

	local function ColorPicker(self)
		local var = self.var
		local color = VMRT.Interrupts[var] or defOption[var]
		local colorMain = VMRT.Interrupts[var] or ExRT.F.table_copy2(color)
		VMRT.Interrupts[var] = colorMain
		local nilFunc = ExRT.NULLfunc
		local function changedCallback(restore)
			local newR, newG, newB
			if restore then
				newR, newG, newB = unpack(restore)
			else
				newR, newG, newB = ColorPickerFrame:GetColorRGB()
			end
			colorMain[1] = newR
			colorMain[2] = newG
			colorMain[3] = newB
			module:UpdateVisual()

			self.color:SetColorTexture(newR,newG,newB,1)
		end

		if not ColorPickerFrame.SetupColorPickerAndShow then
			ColorPickerFrame.previousValues = {color[1],color[2],color[3],1}
			ColorPickerFrame.hasOpacity = false
			ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = nilFunc, nilFunc, nilFunc
			ColorPickerFrame.opacity = 1
			ColorPickerFrame:SetColorRGB(unpack(color))
			ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, nilFunc, changedCallback
			ColorPickerFrame:Show()
		else
			local info = {}
			info.r, info.g, info.b = color[1],color[2],color[3]
			info.opacity = 1
			info.hasOpacity = false
			info.swatchFunc = function()
				local newR, newG, newB = ColorPickerFrame:GetColorRGB()
				colorMain[1] = newR
				colorMain[2] = newG
				colorMain[3] = newB

				module:UpdateVisual()
				self.color:SetColorTexture(newR,newG,newB,1)
			end
			info.cancelFunc = function()
				local newR, newG, newB = ColorPickerFrame:GetPreviousValues()
				colorMain[1] = newR
				colorMain[2] = newG
				colorMain[3] = newB

				module:UpdateVisual()
				self.color:SetColorTexture(newR,newG,newB,1)
			end
			ColorPickerFrame:SetupColorPickerAndShow(info)
		end
	end

	local color_names = {"nocast","cast","minenocast","minecast"}
	local color_points = {{"BOTTOM",-225-50,50},{"BOTTOM",-75-25,50},{"BOTTOM",75,50},{"BOTTOM",225+25,50}}
	for i=1,4 do
		for j=1,2 do
			local var = color_names[i] .. (j==2 and "_text" or "")
			local color = VMRT.Interrupts[var] or defOption[var]
			local backColor = ExRT.lib.CreateColorPickButton(self.tab.tabs[2],20,20,nil,0,0,unpack(color))
			backColor:ClearAllPoints()
			if j==1 then
				backColor:SetPoint(color_points[i][1],color_points[i][2],color_points[i][3] - (j==2 and 60 or 35))
			else
				backColor:SetPoint("TOP",module.options[ "color"..color_names[i] ],"BOTTOM",0,-5)
			end
			module.options["color"..var] = backColor
			ELib:Text(backColor, j==2 and L.InterruptsText or L.InterruptsBackground):Point("LEFT",'x',"RIGHT",3,0):Color()
			backColor:SetScript("OnClick",ColorPicker)
			backColor.var = var
		end
	end

	self.chkDisableUpdates = ELib:Check(self.tab.tabs[3],L.InterruptsStopUpdates,VMRT.Interrupts.DisableUpdates):Point(10,-15):OnClick(function(self) 
		VMRT.Interrupts.DisableUpdates = self:GetChecked()
	end)

	self.chkShowForUnassigned = ELib:Check(self.tab.tabs[3],L.InterruptsShowForUnassigned,VMRT.Interrupts.ShowForUnassigned):Point("TOP",self.chkDisableUpdates,"BOTTOM",0,-5):OnClick(function(self) 
		VMRT.Interrupts.ShowForUnassigned = self:GetChecked()

		module:UpdateData()
	end)

	self.chkOnlyPromoted = ELib:Check(self.tab.tabs[3],L.NoteOnlyPromoted,VMRT.Interrupts.OnlyPromoted):Point("TOP",self.chkShowForUnassigned,"BOTTOM",0,-5):Tooltip(L.InterruptsOnlyPromotedTooltip):OnClick(function(self) 
		if self:GetChecked() then
			VMRT.Interrupts.OnlyPromoted = true
		else
			VMRT.Interrupts.OnlyPromoted = nil
		end
	end)  

end

module.db.frames = {}
module.db.guidToFrame = {}
module.db.counter = {}
module.db.spellToData = {}
module.db.isCasting = {}
module.db.mobData = {}
module.db.currMark = {}
local spellToData = module.db.spellToData
local mobData = module.db.mobData
local counter = module.db.counter
local isCasting = module.db.isCasting
local currMark = module.db.currMark

local FlagMarkToIndex = {
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
}

--[[
VMRT.Interrupts.Data = {
	{npcID = "0", spellData = { {spellID = 17, reset = 3, assignments = {xxx} },{spellID = 740, reset = 2, assignments = {xxx}} }},
}
assignments: name, pos, mark

]]

local function nextNameInsideSetText(self,text)
	local col,name,e = text:match("(|c........)([^|]+)(|r)")
	name = name or text
	text = (col or "")..ExRT.F.utf8sub(name, 1, 6)..(e or "")
	self:_SetText(text)
end


function module:GetFrame()
	for i=1,#module.db.frames do
		local frame = module.db.frames[i]
		if not frame:IsShown() then
			return frame
		end
	end
	local frame = CreateFrame("Frame",nil,UIParent)
	module.db.frames[#module.db.frames+1] = frame
	
	local size = VMRT.Interrupts.Size or defOption.Size
	local fontSize = VMRT.Interrupts.FontSize or defOption.FontSize
	local font = VMRT.Interrupts.Font or defOption.Font
	local anchor, anchor1, anchor2 = VMRT.Interrupts.Anchor or defOption.Anchor, "BOTTOM","TOP"
	local anchorOffsetX = VMRT.Interrupts.AnchorOffsetX or defOption.AnchorOffsetX
	local anchorOffsetY = VMRT.Interrupts.AnchorOffsetY or defOption.AnchorOffsetY
	if anchor == 1 then anchor1, anchor2 = "BOTTOM","TOP"
	elseif anchor == 2 then anchor1, anchor2 = "TOP","BOTTOM"
	elseif anchor == 3 then anchor1, anchor2 = "RIGHT","LEFT"
	elseif anchor == 4 then anchor1, anchor2 = "LEFT","RIGHT" end
	local showColor = not VMRT.Interrupts.NotShowColor
	local showGlow = VMRT.Interrupts.ShowGlow
	local alpha = VMRT.Interrupts.Alpha or defOption.Alpha
	local fontKickerSize = VMRT.Interrupts.KickerFontSize or defOption.KickerFontSize
	local fontKicker = VMRT.Interrupts.KickerFont or defOption.KickerFont
	local nextInside = VMRT.Interrupts.NextInside

	frame:SetSize(size,size)
	frame.back = frame:CreateTexture(nil, "BACKGROUND")
	frame.back:SetAllPoints()
	frame.back:SetColorTexture(1,1,1)

	ELib:Border(frame,2,0,0,0,1)

	frame.text = frame:CreateFontString(nil,"ARTWORK","Number12Font_o1")
	frame.text:SetFont(font,fontSize,"OUTLINE")
	frame.text:SetPoint("CENTER")
	frame.text:SetTextColor(1,0,0,1)
	frame.text:SetText("1")

	frame.nextName = frame:CreateFontString(nil,"ARTWORK","Number12Font_o1")
	frame.nextName:SetFont(fontKicker,fontKickerSize,"OUTLINE")
	frame.nextName:SetTextColor(1,1,1,1)
	frame.nextName:SetText("")
	if nextInside then
		frame.nextName:SetPoint("BOTTOM",frame,0,2)
	elseif anchor == 2 then
		frame.nextName:SetPoint("TOP",frame,"BOTTOM",0,-2)
	else
		frame.nextName:SetPoint("BOTTOM",frame,"TOP",0,2)
	end
	frame.nextName._SetText = frame.nextName.SetText

	if nextInside then
		frame.nextName.SetText = nextNameInsideSetText
	else
		frame.nextName.SetText = frame.nextName._SetText
	end

	if nextInside then
		frame.text:SetPoint("CENTER",0,5)
	else
		frame.text:SetPoint("CENTER")
	end

	frame.anchor1 = anchor1
	frame.anchor2 = anchor2
	frame.anchorOffsetX = anchorOffsetX
	frame.anchorOffsetY = anchorOffsetY
	frame.showColor = showColor
	frame.showGlow = showGlow

	frame:SetAlpha(alpha)

	frame:SetIgnoreParentScale(true)

	frame.color_nocast = VMRT.Interrupts.nocast or defOption.nocast
	frame.color_cast = VMRT.Interrupts.cast or defOption.cast
	frame.color_minenocast = VMRT.Interrupts.minenocast or defOption.minenocast
	frame.color_minecast = VMRT.Interrupts.minecast or defOption.minecast
	frame.color_nocast_text = VMRT.Interrupts.nocast_text or defOption.nocast_text
	frame.color_cast_text = VMRT.Interrupts.cast_text or defOption.cast_text
	frame.color_minenocast_text = VMRT.Interrupts.minenocast_text or defOption.minenocast_text
	frame.color_minecast_text = VMRT.Interrupts.minecast_text or defOption.minecast_text

	--frame:SetFrameStrata("HIGH")
	ExRT.F:FireCallback("Interrupts_FrameStyle",frame)

	return frame
end

function module:UpdateVisual()
	local size = VMRT.Interrupts.Size or defOption.Size
	local fontSize = VMRT.Interrupts.FontSize or defOption.FontSize
	local font = VMRT.Interrupts.Font or defOption.Font
	local anchor, anchor1, anchor2 = VMRT.Interrupts.Anchor or defOption.Anchor, "BOTTOM","TOP"
	local anchorOffsetX = VMRT.Interrupts.AnchorOffsetX or defOption.AnchorOffsetX
	local anchorOffsetY = VMRT.Interrupts.AnchorOffsetY or defOption.AnchorOffsetY
	if anchor == 1 then anchor1, anchor2 = "BOTTOM","TOP"
	elseif anchor == 2 then anchor1, anchor2 = "TOP","BOTTOM"
	elseif anchor == 3 then anchor1, anchor2 = "RIGHT","LEFT"
	elseif anchor == 4 then anchor1, anchor2 = "LEFT","RIGHT" end
	local showColor = not VMRT.Interrupts.NotShowColor
	local showGlow = VMRT.Interrupts.ShowGlow and LCG
	local alpha = VMRT.Interrupts.Alpha or defOption.Alpha
	local hideNext = VMRT.Interrupts.HideNext
	local fontKickerSize = VMRT.Interrupts.KickerFontSize or defOption.KickerFontSize
	local fontKicker = VMRT.Interrupts.KickerFont or defOption.KickerFont
	local nextInside = VMRT.Interrupts.NextInside
	for i=1,#module.db.frames do
		local frame = module.db.frames[i]
		
		frame:SetSize(size,size)
		frame.text:SetFont(font,fontSize,"OUTLINE")
		frame.anchor1 = anchor1
		frame.anchor2 = anchor2
		frame.anchorOffsetX = anchorOffsetX
		frame.anchorOffsetY = anchorOffsetY
		frame.showColor = showColor
		frame.showGlow = showGlow
		frame:SetAlpha(alpha)
		frame.nextName:SetFont(fontKicker,fontKickerSize,"OUTLINE")
		frame.nextName:SetShown(not hideNext)

		frame.nextName:ClearAllPoints()
		if nextInside then
			frame.nextName:SetPoint("BOTTOM",frame,0,2)
		elseif anchor == 2 then
			frame.nextName:SetPoint("TOP",frame,"BOTTOM",0,-2)
		else
			frame.nextName:SetPoint("BOTTOM",frame,"TOP",0,2)
		end

		if nextInside then
			frame.nextName.SetText = nextNameInsideSetText
		else
			frame.nextName.SetText = frame.nextName._SetText
		end

		if nextInside then
			frame.text:SetPoint("CENTER",0,5)
		else
			frame.text:SetPoint("CENTER")
		end

		if LCG then
			LCG.ButtonGlow_Stop(frame)
		end

		frame.color_nocast = VMRT.Interrupts.nocast or defOption.nocast
		frame.color_cast = VMRT.Interrupts.cast or defOption.cast
		frame.color_minenocast = VMRT.Interrupts.minenocast or defOption.minenocast
		frame.color_minecast = VMRT.Interrupts.minecast or defOption.minecast
		frame.color_nocast_text = VMRT.Interrupts.nocast_text or defOption.nocast_text
		frame.color_cast_text = VMRT.Interrupts.cast_text or defOption.cast_text
		frame.color_minenocast_text = VMRT.Interrupts.minenocast_text or defOption.minenocast_text
		frame.color_minecast_text = VMRT.Interrupts.minecast_text or defOption.minecast_text

		frame.back:SetColorTexture(unpack(frame.color_nocast))

		ExRT.F:FireCallback("Interrupts_FrameStyle",frame)
		if frame.isPreview then
			module:UpdateFrame2(frame,unpack(frame.prevUpdate))
		end
	end
	module:ReloadAll(not VMRT.Interrupts.enabled)
end

function module:UpdateData()
	wipe(spellToData)
	wipe(mobData)
	wipe(counter)
	local preData = {}
	for i=1,#CURRENT_DATA do
		local data = CURRENT_DATA[i]
		if data.npcID and not VMRT.Interrupts.Disabled[data.npcID] then
			if not preData[data.npcID] then
				preData[data.npcID] = {}
			end
			preData[data.npcID][ #preData[data.npcID]+1 ] = data
		end
	end

	for npcID,dataSet in pairs(preData) do
		local mineConditions = false
		local showAll = false
		for i=1,#dataSet do
			local data = dataSet[i]
			for j=1,#data.spellData do
				local spellData = data.spellData[j]
				if spellData.spellID then
					local isAssigned = false
					if #spellData.assignments > 0 then
						for k=1,#spellData.assignments do
							local assignment = spellData.assignments[k]
							if assignment.pos and (assignment.name == ExRT.SDB.charName or (type(assignment.name)=="string" and strsplit("-",assignment.name) == ExRT.SDB.charName) or spellData.all) then
								if assignment.mark then
									if not mineConditions then
										mineConditions = {}
									end
									if type(mineConditions) == "table" then
										mineConditions[assignment.mark] = true
									end
								else
									mineConditions = true
								end
								isAssigned = true
							end
						end
					end
					if spellData.all then
						showAll = true
						isAssigned = true
					end
					if isAssigned or VMRT.Interrupts.ShowForUnassigned then
						if not spellToData[ spellData.spellID ] then
							spellToData[ spellData.spellID ] = {}
						end
						spellToData[ spellData.spellID ][#spellToData[ spellData.spellID ]+1] = data
					end
				end
			end
		end
		if not mineConditions and (VMRT.Interrupts.ShowForUnassigned or showAll) then
			mineConditions = true
		end
		mobData[npcID] = mineConditions
	end
	module:ReloadAll(not VMRT.Interrupts.enabled)
end

function module:UpdateFrame(frame,guid,isMine,assignedNames)
	if not frame then
		return
	end
	local num = counter[guid] or 1
	frame.text:SetText(num)
	frame.nextName:SetText(assignedNames or "")
	if isCasting[guid] then
		if frame.showColor then
			if isMine then
				frame.back:SetColorTexture(unpack(frame.color_minecast))
				frame.text:SetTextColor(unpack(frame.color_minecast_text))
			else
				frame.back:SetColorTexture(unpack(frame.color_cast))
				frame.text:SetTextColor(unpack(frame.color_cast_text))
			end
		else
			if isMine then
				frame.text:SetTextColor(unpack(frame.color_minecast_text))
			else
				frame.text:SetTextColor(unpack(frame.color_cast_text))
			end
		end
	else
		if frame.showColor then
			if isMine then
				frame.back:SetColorTexture(unpack(frame.color_minenocast))
				frame.text:SetTextColor(unpack(frame.color_minenocast_text))
			else
				frame.back:SetColorTexture(unpack(frame.color_nocast))
				frame.text:SetTextColor(unpack(frame.color_nocast_text))
			end
		else
			if isMine then
				frame.text:SetTextColor(unpack(frame.color_minenocast_text))
			else
				frame.text:SetTextColor(unpack(frame.color_nocast_text))
			end
		end
	end
	if frame.showGlow and LCG then
		if isMine then
			LCG.ButtonGlow_Start(frame)
		else
			LCG.ButtonGlow_Stop(frame)
		end
	end
end
function module:UpdateFrame2(frame,counter,isCasting,isMine)	--only for preview
	if not frame then
		return
	end
	frame.prevUpdate = {counter,isCasting,isMine}
	frame.text:SetText(counter)

	local class = select(2,UnitClass('player'))
	local classColor
	if class and RAID_CLASS_COLORS[class] then
		classColor = "|c"..RAID_CLASS_COLORS[class].colorStr
	end
	frame.nextName:SetText((classColor or "")..UnitName'player'..(classColor and "|r" or ""))

	if isCasting then
		if frame.showColor then
			if isMine then
				frame.back:SetColorTexture(unpack(frame.color_minecast))
				frame.text:SetTextColor(unpack(frame.color_minecast_text))
			else
				frame.back:SetColorTexture(unpack(frame.color_cast))
				frame.text:SetTextColor(unpack(frame.color_cast_text))
			end
		else
			if isMine then
				frame.text:SetTextColor(unpack(frame.color_minecast_text))
			else
				frame.text:SetTextColor(unpack(frame.color_cast_text))
			end
		end
	else
		if frame.showColor then
			if isMine then
				frame.back:SetColorTexture(unpack(frame.color_minenocast))
				frame.text:SetTextColor(unpack(frame.color_minenocast_text))
			else
				frame.back:SetColorTexture(unpack(frame.color_nocast))
				frame.text:SetTextColor(unpack(frame.color_nocast_text))
			end
		else
			if isMine then
				frame.text:SetTextColor(unpack(frame.color_minenocast_text))
			else
				frame.text:SetTextColor(unpack(frame.color_nocast_text))
			end
		end
	end
	if frame.showGlow and LCG then
		if isMine then
			LCG.ButtonGlow_Start(frame)
		else
			LCG.ButtonGlow_Stop(frame)
		end
	end
end

function module:PlaySound(event)
	if event == 1 then	--Kick
		pcall(PlaySoundFile,VMRT.Interrupts.SoundKick or defOption.SoundKick, "MASTER")
	elseif event == 2 then	--Next
		pcall(PlaySoundFile,VMRT.Interrupts.SoundNext or defOption.SoundNext, "MASTER")
	end
end

function module:ReloadAll(isAddonDisabled)
	for i=1,40 do
		local unit = "nameplate"..i
		local guid = UnitGUID(unit)
		if guid then
			module.main:NAME_PLATE_UNIT_REMOVED(unit)
			if not isAddonDisabled then
				module.main:NAME_PLATE_UNIT_ADDED(unit)
			end
		end
	end
end

function module.main:RAID_TARGET_UPDATE()
	for i=1,40 do
		local unit = "nameplate"..i
		local guid = UnitGUID(unit)
		if guid then
			local markIndex = GetRaidTargetIndex(unit) or 0
			if currMark[guid] ~= markIndex then
				module.main:NAME_PLATE_UNIT_REMOVED(unit)
				module.main:NAME_PLATE_UNIT_ADDED(unit)
			end
		end
	end
end

local function GetSpellData(spellID,npcID,targetMark)
	local list = spellToData[spellID]
	if not list then
		return
	end
	local savedData,savedSpellData
	for j=1,#list do
		local data = list[j]
		for i=1,#data.spellData do
			local spellData = data.spellData[i]
			if data.npcID == npcID and spellData.spellID == spellID then
				if not targetMark then
					return data, spellData
				else
					local haveNoMark = false
					for i=1,#spellData.assignments do
						local assignment = spellData.assignments[i]
						if assignment.mark == 0 then
							haveNoMark = true
						end
						if not assignment.mark or (assignment.mark == targetMark) then
							return data, spellData
						end
					end
					if targetMark == 0 and not haveNoMark then
						savedData, savedSpellData = data, spellData
					end
				end
			end
		end
	end
	return savedData, savedSpellData
end

local function GetResetAuto(spellData,targetMark)
	local count = 0
	local isAny = false
	for i=1,#spellData.assignments do
		local assignment = spellData.assignments[i]
		if (not assignment.mark or (assignment.mark == targetMark)) then
			count = math.max(count, assignment.pos or 0)
			isAny = true
		end
	end
	if not isAny then
		count = math.huge
	end
	return count
end

local function GetOwnAssignment(spellData,castNum,targetMark)
	for i=1,#spellData.assignments do
		local assignment = spellData.assignments[i]
		if (assignment.name == ExRT.SDB.charName or (type(assignment.name)=="string" and strsplit("-",assignment.name) == ExRT.SDB.charName)) and assignment.pos == castNum and (not assignment.mark or (assignment.mark == targetMark)) then
			return assignment
		end
	end
end
local function GetAllAssignments(npcID,castNum,targetMark)
	local res = ""
	for i=1,#CURRENT_DATA do
		local data = CURRENT_DATA[i]
		if data.npcID == npcID then
			for j=1,#data.spellData do
				local spellData = data.spellData[j]
				for k=1,#spellData.assignments do
					local assignment = spellData.assignments[k]
					if assignment.pos == castNum and (not assignment.mark or (assignment.mark == targetMark)) and UnitName(assignment.name or "") and not UnitIsDead(assignment.name) then
						local class = select(2,UnitClass(assignment.name or ""))
						local classColor
						if class and RAID_CLASS_COLORS[class] then
							classColor = "|c"..RAID_CLASS_COLORS[class].colorStr
						end
						res = res .. (res == "" and "" or ", ") .. (classColor or "")..(assignment.name or "")..(classColor and "|r" or "")
					end
				end
			end
		end
	end
	return res
end
local function GetOwnAssignmentGlobal(npcID,castNum,targetMark)
	castNum = castNum or 1
	local data, spellData, assignment
	for i=1,#CURRENT_DATA do
		data = CURRENT_DATA[i]
		if data.npcID == npcID then
			for j=1,#data.spellData do
				spellData = data.spellData[j]
				for k=1,#spellData.assignments do
					assignment = spellData.assignments[k]
					if (assignment.name == ExRT.SDB.charName or (type(assignment.name)=="string" and strsplit("-",assignment.name) == ExRT.SDB.charName)) and assignment.pos == castNum and (not assignment.mark or (assignment.mark == targetMark)) then
						return assignment
					end
				end
			end
		end
	end
end

function module.main.COMBAT_LOG_EVENT_UNFILTERED(_,event,_,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName,spellschool,extraspellID,extraspellName)
	if event == "SPELL_CAST_SUCCESS" then
		local npcID = select(6,strsplit("-", sourceGUID))

		if not npcID or VMRT.Interrupts.Disabled[npcID] then
			return
		end

		local markFlag = bit.band(sourceFlags2, COMBATLOG_OBJECT_RAIDTARGET_MASK)
		local markIndex = FlagMarkToIndex[markFlag]
		local data, spellData = GetSpellData(spellID,npcID,markIndex)

		if not data then
			return
		end

		if not spellData.noscs then
			counter[sourceGUID] = (counter[sourceGUID] or 1) + 1
			if counter[sourceGUID] > ((type(spellData.reset)=="string" and spellData.reset == "A" and GetResetAuto(spellData,markIndex)) or (type(spellData.reset)=="number" and spellData.reset) or math.huge) then
				counter[sourceGUID] = 1
			end
		end
		isCasting[sourceGUID] = nil

		local isMine = GetOwnAssignment(spellData,counter[sourceGUID],markIndex)

		if isMine and not spellData.nonext and not spellData.noscs then
			module:PlaySound(2)
		end

		local assignedNames = GetAllAssignments(npcID,counter[sourceGUID],markIndex)

		module:UpdateFrame(module.db.guidToFrame[sourceGUID],sourceGUID,isMine,assignedNames)
	elseif event == "SPELL_CAST_START" then
		local npcID = select(6,strsplit("-", sourceGUID))

		if not npcID or VMRT.Interrupts.Disabled[npcID] then
			return
		end

		local markFlag = bit.band(sourceFlags2, COMBATLOG_OBJECT_RAIDTARGET_MASK)
		local markIndex = FlagMarkToIndex[markFlag]
		local data, spellData = GetSpellData(spellID,npcID,markIndex)

		if not data then
			return
		end

		counter[sourceGUID] = (counter[sourceGUID] or 1)
		isCasting[sourceGUID] = spellID

		local isMine = GetOwnAssignment(spellData,counter[sourceGUID],markIndex)

		if isMine then
			module:PlaySound(1)
		end

		local assignedNames = GetAllAssignments(npcID,counter[sourceGUID],markIndex)

		module:UpdateFrame(module.db.guidToFrame[sourceGUID],sourceGUID,isMine,assignedNames)
	elseif event == "SPELL_INTERRUPT" then
		local npcID = select(6,strsplit("-", destGUID))

		if not npcID or VMRT.Interrupts.Disabled[npcID] then
			return
		end

		local markFlag = bit.band(destFlags2, COMBATLOG_OBJECT_RAIDTARGET_MASK)
		local markIndex = FlagMarkToIndex[markFlag]
		local data, spellData = GetSpellData(extraspellID,npcID,markIndex)

		if not data then
			return
		end

		counter[destGUID] = (counter[destGUID] or 1) + 1
		if counter[destGUID] > ((type(spellData.reset)=="string" and spellData.reset == "A" and GetResetAuto(spellData,markIndex)) or (type(spellData.reset)=="number" and spellData.reset) or math.huge) then
			counter[destGUID] = 1
		end
		isCasting[destGUID] = nil

		local isMine = GetOwnAssignment(spellData,counter[destGUID],markIndex)

		if isMine and not spellData.nonext then
			module:PlaySound(2)
		end

		local assignedNames = GetAllAssignments(npcID,counter[destGUID],markIndex)

		module:UpdateFrame(module.db.guidToFrame[destGUID],destGUID,isMine,assignedNames)
	end
end

function module.main:NAME_PLATE_UNIT_ADDED(unit)
	local guid = UnitGUID(unit)
	if guid and not module.db.guidToFrame[guid] then
		local npcID = select(6,strsplit("-", guid))
		if npcID and mobData[npcID] then
			local markIndex = GetRaidTargetIndex(unit) or 0
			currMark[guid] = markIndex
			if mobData[npcID] == true or mobData[npcID][markIndex] then
				local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
				if nameplate then
					local frame = module:GetFrame()
					module.db.guidToFrame[guid] = frame

					frame:ClearAllPoints()
	
					frame:SetPoint(frame.anchor1,nameplate,frame.anchor2,frame.anchorOffsetX,frame.anchorOffsetY)
					frame:SetFrameStrata( nameplate:GetFrameStrata() )
					frame.frameLevel = tonumber(unit:match("%d+"),10) + 1
					frame:SetFrameLevel(frame.frameLevel)
	
					local isMine = GetOwnAssignmentGlobal(npcID,counter[guid] or 1,GetRaidTargetIndex(unit) or 0)
					local assignedNames = GetAllAssignments(npcID,counter[guid] or 1,GetRaidTargetIndex(unit) or 0)
					module:UpdateFrame(frame,guid,isMine,assignedNames)
	
					frame:Show()
				end
			end
		end
	end
end

function module.main:NAME_PLATE_UNIT_REMOVED(unit)
	local guid = UnitGUID(unit)
	if guid then
		currMark[guid] = nil
		local frame = module.db.guidToFrame[guid]
		if frame then
			frame:Hide()
			module.db.guidToFrame[guid] = nil
		end
	end
end

do
	local prev
	function module.main:PLAYER_TARGET_CHANGED()
		local guid = UnitGUID("target")
		if prev then
			prev:SetFrameLevel(prev.frameLevel)
			prev = nil
		end
		if guid and not module.db.guidToFrame[guid] then
			prev = 	module.db.guidToFrame[guid]
			prev:SetFrameLevel(1)
			prev:Raise()
		end
	end
end

function module.main:ENCOUNTER_START()
	wipe(counter)
	wipe(isCasting)
	wipe(currMark)
end

local prevIndex
function module:Sync(isExport)
	local r = SENDER_VERSION.."\n"
	for i=1,#CURRENT_DATA do
		local data = CURRENT_DATA[i]
		r = r .. (data.npcID or "") 
		for j=1,#data.spellData do
			local spellData = data.spellData[j]
			r = r .. "^" .. (spellData.spellID or "") .. "#" .. (spellData.reset or "") .. (spellData.nonext and "*1" or "*") .. (spellData.noscs and "*1" or "*") .. (spellData.all and "*1" or "*")
			for k=1,#spellData.assignments do
				local playerData = spellData.assignments[k]
				r = r .. "#" .. (playerData.name or "") .. "#" .. (playerData.pos or "") .. "#" .. (playerData.mark or "")
			end
		end
		r = r .. "\n"
	end
	r = r:gsub("\n$","")

	if isExport then
		return r
	end

	local compressed = LibDeflate:CompressDeflate(r,{level = 9})
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

	encoded = encoded .. "##F##"

	local newIndex
	while prevIndex == newIndex do
		newIndex = math.random(100,999)
	end
	prevIndex = newIndex

	newIndex = tostring(newIndex)
	local parts = ceil(#encoded / 243)
	for i=1,parts do
		local msg = encoded:sub( (i-1)*243+1 , i*243 )
		ExRT.F.SendExMsg("irru","D\t"..newIndex.."\t"..msg)
	end
end

function module:ProcessTextToData(text,isImport)
	local data = {strsplit("\n",text)}
	if data[1] ~= tostring(SENDER_VERSION) then
		return
	end
	local workingArray
	if isImport then
		workingArray = CURRENT_DATA
	else
		workingArray = VMRT.Interrupts.Data[0]
	end
	wipe(workingArray)
	for i=2,#data do
		local npcID,rest = strsplit("^",data[i],2)
		
		local new = {
			npcID = npcID~="" and npcID or nil,
			spellData = {},
		}
		local now

		while rest do
			now,rest = strsplit("^",rest,2)

			local spellID,options,players = strsplit("#",now,3)

			local reset,nonext,noscs,all = strsplit("*",options)

			local newSpell = {
				spellID = spellID~="" and tonumber(spellID) or nil,
				reset = reset~="" and tonumber(reset) or (reset == "A" and "A") or nil,
				assignments = {},
				nonext = nonext=="1" and true or nil,
				noscs = noscs=="1" and true or nil,
				all = all=="1" and true or nil,
			}
			new.spellData[#new.spellData+1] = newSpell

			local pname,pos,mark
			while players do
				pname,pos,mark,players = strsplit("#",players,4)

				local newPlayer = {
					name = pname~="" and pname or nil,
					pos = pos~="" and tonumber(pos) or nil,
					mark = mark~="" and tonumber(mark) or nil,
				}
				newSpell.assignments[#newSpell.assignments+1] = newPlayer
			end
		end

		workingArray[#workingArray+1] = new
	end

	if isImport then
		module:SetProfile(VMRT.Interrupts.Profile)
	else
		module:SetProfile(0)
	end
end


function module:addonMessage(sender, prefix, prefix2, token, ...)
	if prefix == "irru" then
		if prefix2 == "D" then
			if (IsInRaid() and VMRT.Interrupts.OnlyPromoted and not ExRT.F.IsPlayerRLorOfficer(sender)) or sender == ExRT.SDB.charKey or sender == ExRT.SDB.charName then
				return
			end	
			if VMRT.Interrupts.DisableUpdates then
				return
			end
		
			local currMsg = table.concat({...}, "\t")
			if tostring(token) == tostring(module.db.msgindex) and type(module.db.lasttext)=='string' then
				module.db.lasttext = module.db.lasttext .. currMsg
			else
				module.db.lasttext = currMsg
			end
			module.db.msgindex = token

			if type(module.db.lasttext)=='string' and module.db.lasttext:find("##F##$") then
				local str = module.db.lasttext:sub(1,-6)
				local decoded = LibDeflate:DecodeForWoWAddonChannel(str)
				local decompressed = LibDeflate:DecompressDeflate(decoded)

				module:ProcessTextToData(decompressed)

				VMRT.Interrupts.LastUpdateName = sender
				VMRT.Interrupts.LastUpdateTime = time()
				
				module.db.lasttext = nil
			end
		end
	end
end