--- **LibInit** should make using Ace3 even more easier and pleasant
-- LibInit pulls Ace 3 for you if you use the curse packager and set it this way:
--
-- Inside your .pkgmeta
-- externals:
-- 		libs/LibInit:
--			url: git://git.curseforge.net/wow/libinit/mainline.git/Libs/LibInit
--
-- Inside your toc
-- libs/LibInit/LibInit.xml
--
-- @usage
-- me,ns=...
-- local myAddon=LibStub("LibInit):NewAddon(me,true) to pull all Ace3 embeddable
-- local myAddon=LibStub("LibInit):NewAddon(me,"AceHook-3.0","Someotherembeddablelibrary",...) to specify your needede embed
-- local myAddon=LibStub("LibInit):NewAddon(me,true,"Someotherembeddablelibrary",...) to pull all Ace3 embeddable and adding more libraries
-- @class file
-- @name LibInit
--
local MAJOR_VERSION = "LibInit"
local MINOR_VERSION = 18
local nop=function()end
local pp=print -- Keeping a handy plain print around
local _G=_G -- Unmodified env
local dprint=function() end
if LibDebug then
	--pulling libdebug print in without pulling also the whole _G management and without changing loading addon env
	LibDebug()
	dprint=print
	setfenv(1,_G)
end
--GAME_LOCALE="itIT"
local me, ns = ...
local LibStub=LibStub
local module,old=LibStub:NewLibrary(MAJOR_VERSION,MINOR_VERSION)
if module then
	if old then
		dprint("Upgrading ",MAJOR_VERSION,old,'to',MINOR_VERSION)
	else
		dprint("Loading ",MAJOR_VERSION,MINOR_VERSION)
	end
else
	dprint("Equal or newer",MAJOR_VERSION,'already loaded')
	return
end
local lib=module --#Lib
local L
local C=LibStub("LibInit-Colorize")()
-- Upvalues
local _G=_G
dprint("Local _G",_G)
local floor=floor
local abs=abs
local wipe=wipe
local print=print
local next = next
local pairs = pairs
local pcall = pcall
local type = type
local GetTime = GetTime
local gcinfo = gcinfo
local unpack = unpack
local geterrorhandler = geterrorhandler
local GetContainerNumSlots=GetContainerNumSlots
local GetContainerItemID=GetContainerItemID
local GetItemInfo=GetItemInfo
local UnitHealth=UnitHealth
local UnitHealthMax=UnitHealthMax
local setmetatable=setmetatable
local NUM_BAG_SLOTS=NUM_BAG_SLOTS
local InCombatLockdown=InCombatLockdown
local error=error
local tinsert=tinsert
local debugstack=debugstack
local ipairs=ipairs
local GetAddOnMetadata=GetAddOnMetadata
local format=format
local tostringall=tostringall
local tonumber=tonumber
local strconcat=strconcat
local strjoin=strjoin
local strsplit=strsplit
local select=select
local coroutine=coroutine
local cachedGetItemInfo
--]]
-- Help sections
local titles
local RELNOTES
local LIBRARIES
local PROFILE
local HELPSECTIONS
local AceConfig = LibStub("AceConfig-3.0",true)
local AceRegistry = LibStub("AceConfigRegistry-3.0",true)
local AceDBOptions=LibStub("AceDBOptions-3.0",true)
local AceConfigDialog=LibStub("AceConfigDialog-3.0",true)
local AceGUI=LibStub("AceGUI-3.0",true)
local Ace=LibStub("AceAddon-3.0")
local AceLocale=LibStub("AceLocale-3.0")
local AceDB  = LibStub("AceDB-3.0",true)

-- Recycling function from ACE3
----newcount, delcount,createdcount,cached = 0,0,0
local new, del, copy
do
	local pool = setmetatable({},{__mode="k"})
	function new()
		--newcount = newcount + 1
		local t = next(pool)
		if t then
			pool[t] = nil
			return t
		else
			--createdcount = createdcount + 1
			return {}
		end
	end
	function copy(t)
		local c = new()
		for k, v in pairs(t) do
			c[k] = v
		end
		return c
	end
	function del(t)
		--delcount = delcount + 1
		wipe(t)
		pool[t] = true
	end
--	function cached()
--		local n = 0
--		for k in pairs(pool) do
--			n = n + 1
--		end
--		return n
--	end
end
--- This storage must survive a library update
lib.mixinTargets=lib.mixinTargets or {}
lib.combatSchedules = lib.combatSchedules or {}
lib.frame=lib.frame or CreateFrame("Frame") -- This frame is needed for scheduleleavecombat
lib.debugs=lib.debugs or {}
lib.toggles=lib.toggles or {}
lib.addon=lib.addon or {}
lib.chats=lib.chats or {}
function lib:NewAddon(name,full,...)
	if (not Ace) then
		error("Could not find Ace3 Library")
		return
	end
	local mixins=new()
	if (type(full)=='boolean') then
		for i,k in  LibStub:IterateLibraries() do
			if (i:match("Ace%w*-3%.0") and k.Embed) then tinsert(mixins,i) end
		end
	else
		tinsert(mixins,full)
	end
	tinsert(mixins,MAJOR_VERSION)
	tinsert(mixins,"AceConsole-3.0")
	for i=1,select('#',...) do
		local mix=select(i,...)
		if (mix ~="AceConsole-3.0") then
			tinsert(mixins,mix)
		end
	end
	local target=Ace:NewAddon(name,unpack(mixins))
	del(mixins)
	target.interface=select(4,GetBuildInfo())
	target.version=GetAddOnMetadata(name,'Version') or "Internal"
	if (target.version:sub(1,1)=='@') then
		target.version=GetAddOnMetadata(name,'X-Version') or 0
	end
	local b,e=target.version:find(" ")
	if b and b>1 then
			target.version=target.version:sub(1,b-1)
	end
	target.revision=GetAddOnMetadata(name,'X-revision') or "Alpha"
	if (target.revision:sub(1,1)=='@') then
		target.revision='Development'
	end
	target.prettyversion=format("%s (Revision: %s)",tostringall(target.version,target.revision))
	target.title=GetAddOnMetadata(name,"title") or 'No title'
	target.notes=GetAddOnMetadata(name,"notes") or 'No notes'
	-- Setting sensible default for mandatory fields
	target.ID=GetAddOnMetadata(name,"X-ID") or (target.name:gsub("[^%u%d]","") .. "XXXX"):sub(1,3)
	target.DATABASE=GetAddOnMetadata(name,"X-Database") or "db" .. target.ID
	lib.addon[target]=name
	lib.toggles[target]={}
	RELNOTES=L["Release Notes"]
	PROFILE=L["Profile"]
	HELPSECTIONS={PROFILE,RELNOTES}
	titles={
		RELNOTES=RELNOTES,
		PROFILE=PROFILE
	}
	return target
end
-- Combat scheduler done with LibCallbackHandler
local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
if not lib.CombatScheduler then
	lib.CombatScheduler = CallbackHandler:New(lib,"_OnLeaveCombat","_CancelCombatAction")
	lib.CombatFrame=CreateFrame("Frame")
	lib.CombatFrame:SetScript("OnEvent",function()
		lib.CombatScheduler:Fire("LIBINIT_END_COMBAT")
		if lib.CombatScheduler.insertQueue then
			wipe(lib.CombatScheduler.insertQueue) -- hackish, depends on internal callbackhanlder implementation
		end
		wipe(lib.CombatScheduler.events)
		lib.CombatScheduler.recurse=0
	end)
	lib.CombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
end
local tremove=tremove
local function Run(args) tremove(args,1)(unpack(args)) end
function lib:OnLeaveCombat(action,...)
	if type(action)~="string" and type(action)~="function" then
		error("Usage: OnLeaveCombat (\"action\", ...): 'action' - string or function expected.", 2)
	end
	if type(action)=="string" and type(self[action]) ~= "function" then
		error("Usage: OnLeaveCombat (\"action\", ...): 'action' - method '"..tostring(action).."' not found on self.", 2)
	end
	if type(action) =="string" then
		lib._OnLeaveCombat(self,"LIBINIT_END_COMBAT",Run,{self[action],self,...})
	else
		lib._OnLeaveCombat(self,"LIBINIT_END_COMBAT",Run,{action,...})
	end
	if (not InCombatLockdown()) then
		lib.CombatFrame:GetScript("OnEvent")()
	end
end

function lib:NewSubModule(name,...)
	local module=self:NewModule(name,...)
	module.OnInitialized=function()end -- placeholder
	module.OnInitialize=function(self,...) return  self:OnInitialized(...) end
	module.OnEnable=nil
	module.OnDisable=nil
	return module
end
function lib:NewSubClass(name)
	return self:NewSubModule(name,self)
	-- To avoid strange interactions
end
--- Returns a closure to call a method as simple local function
--@usage local print=lib:Wrap("print")
function lib:Wrap(nome)
	if (nome=="Trace") then
		return function(...) lib._Trace(self,1,...) end
	end
	if (type(self[nome])=="function") then
		return function(...) self[nome](self,...) end
	else
		return nop
	end
end
function lib:GetAddon(name)
	return Ace:GetAddon(name,true)
end
function lib:GetLocale()
	return AceLocale:GetLocale(self.name)
end
function lib:Gradient(perc)
	return self:ColorGradient(perc,0,1,0,1,1,0,1,0,0)
end
function lib:ColorToString(r,g,b)
	return format("%02X%02X%02X", 255*r, 255*g, 255*b)
end
function lib:ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	local num = select('#', ...) / 3
	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)
	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end
local combatSchedules = lib.combatSchedules
-- Gestione variabili
local varmeta={}
do
	local function f1(self,flag,value)
		return self:Apply(flag,value)
	end
	local function f2(self,flag,value)
		return self['Apply' .. flag](self,value)
	end
	varmeta={
		__index =
		function(table,cmd)
			local self=rawget(table,'_handler')
			if (type(self["Apply" .. cmd]) =='function') then
				rawset(table,cmd,f2)
			elseif (type(self.Apply)=='function') then
				rawset(table,cmd,f1)
			else
				rawset(table,cmd,function(...) end)
			end
			return rawget(table,cmd)
		end
	}
end
function lib:GetChatFrame(chat)
	if (chat) then
		if (lib.chats[chat]) then return lib.chats[chat] end
		for i=1,NUM_CHAT_WINDOWS do
			local frame=_G["ChatFrame" .. i]
			if (not frame) then break end
			if (frame.name==chat) then lib.chats[chat]=frame return frame end
		end
		return nil
	end
	return DEFAULT_CHAT_FRAME
end

local Myclass
---
-- Check if the unit in target hast the requested clas
-- @param #string class Requested Class
-- @param #string target Requested Unit (default 'player')
-- @return #boolean true if target has the requeste class
function lib:Is(class,target)
	target=target or "player"
	if (target == "player") then
		if (not Myclass) then
			Myclass=select(2,UnitClass('player'))
		end
		return Myclass==strupper(class)
	else
		local    rc,_,unitclass=pcall(UnitClass,target)
		if (rc) then
			return unitclass==strupper(class)
		else
			return false
		end
	end
end
---
-- Parses a command from chat or from an table options handjer command
-- Internally calls AceConsole-3.0:GetArgs
-- @param #mixed msg Can be a string (chat command) or a table (called by Ace3 Options Table Handler)
-- @return command,subcommand,arg,ffull string after command
function lib:Parse(msg,n)
	if (not msg) then
		return nil
	end
	if (type(msg) == 'table' and msg.input ) then msg=msg.input end
	if (type(msg) ~= 'string') then return end
	return self:GetArgs(msg,n)
end
---
-- Parses an itemlink and returns itemId without calling API again
-- @param #Lib self
-- @param #string itemlink
-- @return #number itemId or 0
function lib:GetItemID(itemlink)
	if (type(itemlink)=="string") then
			local itemid,context=GetItemInfoFromHyperlink(itemlink)
			return tonumber(itemid) or 0
			--return tonumber(itemlink:match("Hitem:(%d+):")) or 0
	else
			return 0
	end
end
---
-- Scans Bags for an item based on different criteria
--
-- All parameters are optional.
-- With no params ScanBags returns the first empty slot
--
-- @param index is index in GetItemInfo result. 0 is a special case to match just itemid
-- @param value is the value against to match. 0 is a special case for empty slot
-- @param startbag and starslot are used to restart scan from the last item found
-- @param startslot
-- @return Found ItemId,bag,slot,full GetItemInfo result
function lib:ScanBags(index,value,startbag,startslot)
	index=index or 0
	value=value or 0
	startbag=startbag or 0
	startslot=startslot or 1
	for bag=startbag,NUM_BAG_SLOTS,1 do
		for slot=startslot,GetContainerNumSlots(bag),1 do
			local itemlink=GetContainerItemLink(bag,slot)
			if (itemlink) then
				if (index==0) then
					if (self:GetItemID(itemlink)==value) then
						return itemlink,bag,slot
					end
				else
					local test=CachedGetItemInfo(itemlink,index)
					if (value==test) then
						return itemlink,bag,slot
					end
				end
			end
		end
	end
	return false
end
--- Returns unit's heatl as a normalized percentual value
-- @param #string unit A standard unit name
-- @return #number health as percent value

function lib:Health(unit)
		local totale=UnitHealthMax(unit) or 1
		local corrente=UnitHealth(unit) or 1
		if (corrente == 0) then corrente =1 end
		if (totale==0) then totale = corrente end
		local life=corrente/totale*100
		return math.ceil(life)
end

function lib:Age(secs)
		return self:TimeToStr(GetTime() - secs)
end
function lib:Mana(unit)
		local totale=UnitManaMax(unit) or 1
		local corrente=UnitMana(unit) or 1
		if (corrente == 0) then corrente =1 end
		if (totale==0) then totale = corrente end
		local life=corrente/totale*100
		return math.ceil(life)
end
function lib:IsFriend(player)
	local i
	for i =1,GetNumFriends() do
		local name,_,_,_,_ =GetFriendInfo(i)
		if (name == player) then
			return true
		end
	end
	return false
end
function lib:GetDistanceFromMe(unit)
	if not unit then return 99999 end
	local x,y=GetPlayerMapPosition(unit)
	return self:GetUnitDistance(x,y)
end
function lib:GetUnitDistance(x,y,unit)
		unit=unit or "player"
		local from={}
		local to={}
		from.x,from.y=GetPlayerMapPosition(unit)
		to.x=x
		to.y=y
		return self:GetDistance(from,to) * 10000
end
function lib:GetDistance(a,b)
--------------
-- Calculates distance betweeb 2 points given as
-- a.x,a.y and b.x,b.y
	local x=b.x - a.x
	local y=b.y -a.y
	local d=x*x + y* y
	local rc,distance=pcall(math.sqrt,d)
	if (rc) then
				return distance
		else
				return 99999
		end
end
---
-- Returns a numeric representation of version.
-- Can be overridden
-- In default incarnation assumes that version is in the form x,y,z
-- @return z+y*100+x*10000
--
function lib:NumericVersion()
	local v=tonumber(self.version)
	if (v) then return v end
	if (type(self.version) == "string") then
		local a,b,c=self.version:match("(%d*)%D?(%d*)%D?(%d*)%D*")
		a=tonumber(a) or 0
		b=tonumber(b) or 0
		c=tonumber(c) or 0
		return a*10000+b*100+c
	else
		return 0
	end
end
function lib:OnInitialized()
	print("|cff33ff99"..tostring( self ).."|r:",L["You should at least override this function to make a working addon"])
end
function lib:LoadHelp()
end
function lib:SetDbDefaults()
end
function lib:SetOptionsTable()
end
local function LoadDefaults(self)
	self.OptionsTable={
		handler=self,
		type="group",
		childGroups="tab",
		name=self.title,
		desc=self.notes,
		args={
			gui = {
				name="GUI",
				desc="Activates gui",
				type="execute",
				func="Gui",
				guiHidden=true,
			},
--[===[@debug@
			help = {
				name="HELP",
				desc="Show help",
				type="execute",
				func="Help",
				guiHidden=true,
			},
--@end-debug@]===]
			debug = {
				name="DBG",
				desc="Enable debug",
				type="execute",
				func="Debug",
				guiHidden=true,
				cmdHidden=true,
			},
			silent = {
				name="SILENT",
				desc="Eliminates startup messages",
				type="execute",
				func=function()
					self.db.global.silent=not self.db.global.silent
					print("Silent is now",self.db.global.silent,self.db.global.silent and "true" or "false" )
				end,
				guiHidden=true,
			},
			on = {
				name="On",
				desc="Activates " .. self.title,
				type="execute",
				func="Enable",
				guiHidden=true,
			},
			off = {
				name="Off",
				desc="Deactivates " .. self.title,
				type="execute",
				func="Disable",
				guiHidden=true,
				arg='Active'
			},
		}
	}
	self.DbDefaults={
		char={
			firstrun=true,
			lastversion=0,
		},
		global={
			firstrun=true,
			lastversion=0,
			lastinterface=60000
		},
		profile={
			toggles={
					Active=true,
			},
			["*"]={},
		}
	}
	self.MenuLevels={"root"}
	self.ItemOrder=setmetatable({},{
		__index=function(table,key) rawset(table,key,1)
			return 1
		end
		}
	)
end
local function BuildHelp(self)
	local main=self.name
	for _,section in ipairs(HELPSECTIONS) do
		if (section == RELNOTES) then
			self:HF_Load(section,main..section,' ' .. tostring(self.version) .. ' (r:' .. tostring(self.revision) ..')')
		else
			self:HF_Load(section,main .. section,'')
		end
	end
end
function lib:IsFirstRun()
	return self.db.global.firstrun
end
function lib:IsNewVersion()
	return self.numericversion > self.db.global.lastnumericversion and self.db.global.lastnumericversion or false
end
function lib:IsNewTocVersion()
	return self.interface > self.db.global.lastinterface  and self.db.global.lastinterface or false
end
function lib:RegisterDatabase(dbname,defaults,profile)
	return AceDB:New(dbname,defaults,profile)
end
function lib:OnInitialize(...)
--[===[@debug@
	dprint("OnInitialize",...)
	LoadAddOn("Blizzard_DebugTools")
--@end-debug@]===]
	self.numericversion=self:NumericVersion() -- Initialized now becaus NumericVersion could be overrided
	--CachedGetItemInfo=self:GetCachingGetItemInfo()
	LoadDefaults(self)
	local defaultProfile=self:SetDbDefaults(self.DbDefaults)
	self:SetOptionsTable(self.OptionsTable)
	if (AceDB and not self.db) then
		self.db=AceDB:New(self.DATABASE,nil,defaultProfile)
	end
	self.db:RegisterDefaults(self.DbDefaults)
	if (not self.db.global.silent) then
		self:Print(format("Version %s %s loaded",self:Colorize(self.version,'green'),self:Colorize(format("(Revision: %s)",self.revision),"silver")))
		self:Print("You can disable this message with /" .. strlower(self.ID) .. " silent")
	end
	self:SetEnabledState(self:GetBoolean("Active"))
	-- I have for sure some library that needs to be intialized Before the addon
	for _,library in self:IterateEmbeds(self) do
		local lib=LibStub(library)
		if (lib.OnEmbedPreInitialize) then
			lib:OnEmbedPreInitialize(self)
		end
	end

	self.help=setmetatable(
			{},
			{__index=function(table,key)
					rawset(table,key,"")
					return rawget(table,key)
					end
			}
	)
	--===============================================================================
	-- Calls initialization Callback
	local ignoreProfile=self:OnInitialized(...)
	--===============================================================================
	if (not self.OnDisabled) then
		self.OptionsTable.args.on=nil
		self.OptionsTable.args.off=nil
		self.OptionsTable.args.standby=nil
	end
	if (type(self.LoadHelp)=="function") then self:LoadHelp() end
	local main=self.name
	BuildHelp(self)
	AceConfig:RegisterOptionsTable(main,self.OptionsTable,{main,strlower(self.ID)})
	self.CfgDlg=AceConfigDialog:AddToBlizOptions(main,main )
	if (not ignoreProfile) then
		if (AceDBOptions) then
			self.ProfileOpts=AceDBOptions:GetOptionsTable(self.db)
			titles.PROFILE=self.ProfileOpts.name
			self.ProfileOpts.name=self.name
			local profile=main..PROFILE
		end
		AceConfig:RegisterOptionsTable(main .. PROFILE,self.ProfileOpts)
		AceConfigDialog:AddToBlizOptions(main .. PROFILE,titles.PROFILE,main)
	end
	if (self.help[RELNOTES]~='') then
		self.CfgRel=AceConfigDialog:AddToBlizOptions(main..RELNOTES,titles.RELNOTES,main)
	end
	self:UpdateVersion()
end
function lib:UpdateVersion()
	if (type(self.db.char) == "table") then
		self.db.char.lastversion=self.numericversion
		self.db.char.firstun=false
	end
	if (type(self.db.global)=="table") then
		self.db.global.lastversion=self.numericversion
		self.db.global.firstrun=false
		self.db.global.lastinterface=self.interface
	end
end

-- help related functions
function lib:HF_Push(section,text)
		section=section or self.lastsection or RELNOTES
		self.lastsection=section
		self.help[section]=self.help[section]  .. '\n' .. text
end
local getlibs
do
	local libs={}
		function lib:HF_Lib(libname)
				local o,minor=LibStub(libname,true)
				if (o and libs) then
						if (not libs[o] or libs[o] <minor) then
								libs[libname]=minor
						end
				end
		end
		function getlibs(self)
				local appo={}
				if (not libs) then return end
				for i,_ in pairs(libs) do
						table.insert(appo,i)
				end
				table.sort(appo)
				for _,libname in pairs(appo) do
						local minor=libs[libname]
						self:HF_Pre(format("%s release: %s",self:Colorize(libname,'green'),self:Colorize(minor,'orange')),LIBRARIES)
				end
				libs=nil
		end
end

function lib:HF_Toggle(flag,description)
	flag=C(format("/%s toggle %s: ",strlower(self.ID),flag),'orange') ..C(description,'white')
	self:HF_Push(TOGGLES,"\n" .. C(flag,'orange'))
end

function lib:HF_Title(text,section)
	self:HF_Push(section,C(text or '','yellow') .. "\n")
end
function lib:HF_Command(text,description,section)
	self:HF_Push(section,C(text or '','orange') .. ':' ..  C(description or '','yellow') .. "\n")
end

function lib:HF_Paragraph(text,section)
	self:HF_Push(section,"\n"..C(text,'green'))
end
function lib:HF_CmdA(command,description,tooltip)
	self:HF_Push(nil,
	C('/' .. command,'orange') .. ' : ' .. (description or '') .. '\n' .. C(tooltip or '','yellow'))
end
function lib:HF_Cmd(command,description,tooltip)
	command=self.ID .. ' ' .. command
	self:HF_CmdA(command,description,tooltip)
end
function lib:HF_Pre(testo,section)
	self:HF_Push(section,testo)
end
function lib:Wiki(testo,section)
	section=section or self.lastsection or RELNOTES
	self.lastsection=section
	local fmtbullet=" * %s\n"
	local progressive=1
	local fmtnum=" %2d. %s\n"
	local fmthead1="|cff" .. C.Orange  .."%s|r\n \n \n"
	local fmthead2="|cff" .. C.Yellow  .."%s|r\n \n"
	local text=''
	for line in testo:gmatch("(%C*)%c+") do
		line=line:gsub("^ *","")
		line=line:gsub(" *$","")
		local i,j= line:find('^%=+')
		if (i) then
			if (j==1) then
				text=text .. fmthead1:format(line:sub(j+1,-j-1))
			else
				text=text .. fmthead2:format(line:sub(j+1,-j-1))
			end
		else
			local i,j= line:find('^%*+')
			if (i) then
				text=text.. fmtbullet:format(line:sub(j+1))
			else
				local i,j= line:find('^#+')
				if (i) then
					text=text .. fmtnum:format(progressive,line:sub(j+1))
					progressive=progressive + 1
				else
					text=text .. line.."\n"
				end
			end
		end
	end
	self.help[section]=self.help[section]  .. '\n' .. text
end

function lib:RelNotes(major,minor,revision,t)
	local fmt=self:Colorize("Release note for %d.%d.%s",'Yellow') .."\n%s"
	local lines={}
	local spacer=""
	local maxpanlen=70
	lines={strsplit("\n",t)}
	local max=5
	for i,tt in ipairs(lines) do
		local prefix,text=tt:match("^(%a+):(.*)")
		if (prefix == "Fixed" or prefix=="Fix") then
			prefix=self:Colorize("Fix: ",'Red')
			spacer="       "
		elseif (prefix == "Feature") then
			prefix=self:Colorize("Feature: ",'Green')
			spacer=             "         "
		else
			text=tt
			prefix=spacer
		end
		local tta=""
		tt=text
		while (tt:len() > maxpanlen)  do
			local p=tt:find("[%s%p]",maxpanlen -10) or maxpanlen
			tta=tta..prefix..tt:sub(1,p) .. "\n"
			prefix=spacer
			tt=tt:sub(p+1)
		end
		tta=tta..prefix..tt
		tta=tta:gsub("Upgrade:",self:Colorize("Upgrade:",'Azure'))
		lines[i]=tta:gsub("Example:",self:Colorize("Example:",'Orange'))
		max=max-1
		if (max<1) then
			break
		end
	end
	self:HF_Push(RELNOTES,fmt:format(major,minor,revision,strjoin("\n",unpack(lines))))
end

function lib:HF_Load(section,optionname,versione)
-- Creazione pannello di help
-- Livello due del
	if (section == LIBRARIES) then
		getlibs(self)
	end
	local testo =self.help[section]
	--debug(section)
	--debug(optionname)
	--debug(self.title)
	if (testo ~= '') then
		AceConfig:RegisterOptionsTable(optionname, {
			name = self.title .. (versione or ""),
			type = "group",
			args = {
				help = {
					type = "description",
					name = testo,
					fontSize='medium',
				},
			},
		})
		AceConfigDialog:SetDefaultSize(optionname, 600, 400)
	end
end
-- var area
local function getgroup(self)
	local group=self.OptionsTable
	local m=self.MenuLevels
	for i=2,#m do
			group=group.args[self.MenuLevels[i]]
	end
	if (type(group) ~= "table") then
			group={}
	end
	return group
end
local function getorder(self,group)
	local i=self.ItemOrder[group.name]+1
	self.ItemOrder[group.name]=i
	return i
end
local function toflag(...)
	local appo=''
	for i=1,select("#",...) do
		appo=appo .. tostring(select(i,...))
	end
		return appo:gsub("%W",'')
end
function lib:EndLabel()
	local m=self.MenuLevels
	if (#m > 1) then
			table.remove(m)
	end
end

--self:AddLabel("General","General Options",C.Green)
function lib:AddLabel(title,description,stringcolor)
	self:EndLabel()
	description=description or title
	stringcolor=stringcolor or C.yellow
	local t=self:AddSubLabel(title,description,stringcolor)
	t.childGroups="tab"
	self:AddSeparator(description)
	return t
end
--self:AddSubLabel("Local","Local Options",C.Green)
function lib:AddSubLabel(title,description,stringcolor)
	local m=self.MenuLevels
	description=description or title
	stringcolor=stringcolor or C.orange
	local group=getgroup(self)
	local flag=toflag(group.name,title)
	group.args[flag]={
			name="|cff" .. stringcolor .. title .. "|r",
			desc=description,
			type="group",
			cmdHidden=true,
			args={},
			order=getorder(self,group),
	}
	table.insert(m,flag)
	return group.args[flag]
end

--self:AddText("Testo"[,texture[,height[,width[,texcoords]]]])
function lib:AddText(text,image,imageHeight,imageWidth,imageCoords)
	local group=getgroup(self)
	local flag=toflag(group.name,text)
	local t={
			name=text,
			type="description",
			image=image,
			imageHeight=imageHeight,
			imageWidth=imageWidth,
			imageCoords=imageCoords,
			desc=text,
			order=getorder(self,group),

	}
	group.args[flag]=t
	return t
end

--self:AddToggle("AUTOLEAVE",true,"Quick Battlefield Leave","Alt-Click on hide button in battlefield alert leaves the queue")
function lib:AddToggle(flag,defaultvalue,name,description,icon)
	description=description or name
	local group=getgroup(self)
	local t={
			name=name,
			type="toggle",
			get="OptToggleGet",
			set="OptToggleSet",
			desc=description,
			width='full',
			arg=flag,
			cmdHidden=true,
			icon=icon,
			order=getorder(self,group),
	}
	lib.toggles[self][flag]=t
	group.args[flag]=t
	if (self.db.profile.toggles[flag]== nil) then
			self.db.profile.toggles[flag]=defaultvalue
	end
	return t
end
-- self:AddEdit("REFLECTTO",1,{a=1,b=2},"Whisper reflection receiver:","All your whispers will be forwarded to this guy")
function lib:AddSelect(flag,defaultvalue,values,name,description)
	description=description or name
	local group=getgroup(self)
	local t={
			name=name,
			type="select",
			get="OptToggleGet",
			set="OptToggleSet",
			desc=description,
			width="full",
			values=values,
			arg=flag,
			cmdHidden=true,
			order=getorder(self,group)
	}
	group.args[flag]=t
	if (self.db.profile.toggles[flag]== nil) then
			self.db.profile.toggles[flag]=defaultvalue
	end
	lib.toggles[self][flag]=t
	return t
end

--self:AddSlider("RESTIMER",5,1,10,"Enable res timer","Shows a timer for battlefield resser",1)
function lib:AddSlider(flag,defaultvalue,min,max,name,description,step)
	description=description or name
	min=min or 0
	max=max or 100
	local group=getgroup(self)
	local isPercent=nil
	if (type(step)=="boolean") then
		isPercent=step
		step=nil
	else
		step=tonumber(step)
	end
	local t={
		name=name,
		type="range",
		get="OptToggleGet",
		set="OptToggleSet",
		desc=description,
		width="full",
		arg=flag,
		step=step,
		isPercent=isPercent,
		min=min,
		max=max,
		order=getorder(self,group),
	}
	group.args[flag]=t
	if (self.db.profile.toggles[flag]== nil) then
		self.db.profile.toggles[flag]=defaultvalue
	end
	lib.toggles[self][flag]=t
	return t
end
-- self:AddEdit("REFLECTTO","","Whisper reflection receiver:","All your whispers will be forwarded to this guy","How to use it")
function lib:AddEdit(flag,defaultvalue,name,description,usage)
	description=description or name
	usage = usage or description
	local group=getgroup(self)
	local t={
			name=name,
			type="input",
			get="OptToggleGet",
			set="OptToggleSet",
			desc=description,
			arg=flag,
			usage=usage,
			order=getorder(self,group),

	}
	group.args[flag]=t
	if (self.db.profile.toggles[flag]== nil) then
			self.db.profile.toggles[flag]=defaultvalue
	end
	lib.toggles[self][flag]=t
	return t
end

-- self:AddAction("openSpells","Opens spell panel","You can choose yoru spells in spell panel")
function lib:AddAction(method,label,description,private)
	label=label or method
	description=description or label
		local group=getgroup(self)
		local t={
			func=method,
			name=label,
			type="execute",
			desc=description,
			confirm=false,
			cmdHidden=true,
			order=getorder(self,group)
		}
	if (private) then t.hidden=true end
	group.args[strlower(label)]=t
	lib.toggles[self][method]=t
	return t
end

function lib:AddPrivateAction(method,name,description)
	return self:AddAction(method,name,description,true)
end
function lib:AddKeyBinding(flag,name,description)
	name=name or strlower(name)
	description=description or name
	local group=getgroup(self)
	local t={
		name=name,
		type="keybinding",
		get="OptToggleGet",
		set="OptToggleSet",
		desc=description,
		arg=flag,
		order=getorder(self,group)
	}
	group.args[flag]=t
	lib.toggles[self][flag]=t
	return t
end
function lib:AddTable(flag,table)
	local group=getgroup(self)
	group.args[flag]=table
	lib.toggles[self][flag]=table
end
local function OpenCmd(self,info,args)
	print("libinit",info.arg,self,args,strsplit(' ',args))
	return self[info.arg](self,args,strsplit(' ',args))
end
function lib:AddOpenCmd(command,method,description,arguments,private)
	method=method or command
	description=description or command
	local group=getgroup(self)
	if (not private) then
		local command=C('/' .. self.ID .. ' ' .. command .. " (" .. description .. ")" ,'orange')
		local t={
			name=command,
			type="description",
			order=getorder(self,group),
			fontSize='medium',
			width='full'
		}
		group.args[command .. 'title']=t
	end
	local t={
		name=command,
		type="input",
		arg=method,
		get=function(...) end,
		set=function(...) return OpenCmd(self,...) end,
		desc=description,
		order=getorder(self,group),
		guiHidden=true,
		hidden=private
	}
	if (type(arguments)=="table") then
		local validate={}
		for _,v in pairs(arguments) do
			validate[v]=v
		end
		t.values=validate
		t.type="select"
	end
	self.OptionsTable.args[command]=t

	return t
end
function lib:AddPrivateOpenCmd(command,method,description,arguments)
	return self:AddOpenCmd(command,method,description,arguments,true)
end
function lib:GetVarInfo(flag)
	return lib.toggles[self][flag]
end

--self:AddSubCmd(flagname,method,label,description)
function lib:AddSubCmd(flag,method,name,description,input)
	method=method or flag
	name=name or flag
	description=description or name
	local group=getgroup(self)
	debug("AddSubCmd " .. flag .. " for " .. method)
	local t={
		func=method,
		name=name,
		type="execute",
		input=input,
		desc=description,
		confirm=true,
		order=getorder(self,group),
		guiHidden=true,
	}
	group.args[flag]=t
	return t
end



--self:AddCmd(flag,method,name,description)
function lib:AddChatCmd(method,label,description)
	if (not self.RegisterChatCommand) then
		LibStub("AceConsole-3.0"):Embed(self)
	end
	label=label or method
	self:RegisterChatCommand(label,method)
	description=description or label

	local group=getgroup(self)
	local t={
			name=C('/' .. label ..  " (" .. description .. ")",'orange'),
			type="description",
			order=getorder(self,group),
			fontSize="medium",
			width="full"
	}
	group.args[label .. 'title']=t
	return t
end

--self:AddSeparator(text)

function lib:AddSeparator(text)
	local group=getgroup(self)
	local i=getorder(self,group)
	local flag=group.name .. i
	flag=flag:gsub('%W','')
	local t={
			name=text,
			type="header",
			order=i,
	}
	group.args[flag]=t
	return t
end

function lib:OnEmbedEnable(first)
end

function lib:OnEmbedDisable()
end


function lib:OnEnable(first,...)
	if (self.OnEnabled) then
		if (not self.db.global.silent) then
			self:Print(C("enabled","green"))
		end
		pcall(self.OnEnabled,self)
	end
end
function lib:OnDisable(...)
	if (self.OnDisabled) then
		if (not self.db.global.silent) then
			self.print(C("disabled",'red'))
		end
		pcall(self.OnDisabled,self,...)
	end
end
local function _GetMethod(target,prefix,func)
	if (func == 'Start' or func == 'Stop') then return end
	local method=prefix .. func
	if (type(target[method])== "function") then
			return method
	elseif (type(target["_" .. prefix])) then
			return "_" .. prefix
	end
end
function lib:StartAutomaticEvents()
	for k,v in pairs(self) do
		if (type(v)=='function') then
			if (k:sub(1,3)=='Evt') then
				self:RegisterEvent(k:sub(4),k)
			end
		end
	end
end
function lib:StopAutomaticEvents(ignore)
	for k,v in pairs(self) do
		if (type(v)=='function') then
			if (k:sub(1,3)=='Evt') then
				if (ignore and k==ignore or k:sub(4)==ignore) then
					--a kickstart event not to be disabled
				else
					self:UnregisterEvent(k:sub(4))
				end
			end
		end
	end
end
function lib:Dprint(...)
end
function lib:Notify(...)
	return self:CustomPrint(C.orange.r,C.orange.g,C.orange.b, nil, nil, ' ', ...)
end
function lib:Debug()
	self.DebugOn=not self.DebugOn
	pp(self.name,"debug:",self.DebugOn and "On" or "Off")
	if self.DebugOn then
		self.Dprint=dprint
	else
		self.Dprint=nop
	end
end

function lib:Colorize(stringa,colore)
	return C(stringa,colore) .. "|r"
end
function lib:GetTocVersion()
	return tonumber(wow.TocVersion) or 0
end
function lib:Toggle()
	if (self:IsEnabled()) then
		self:Disable()
	else
		self:Enable()
	end
end
function lib:Vars()
	return pairs(self.db.profile.toggles)
end
function lib:SetBoolean(flag,value)
	if (value) then
		value=true
	else
		value=false
	end
	self.db.profile.toggles[flag]=value
	return not value
end
function lib:GetBoolean(flag)
	if (self.db.profile.toggles[flag]) then
		return true
	else
		return false
	end
end
lib.GetToggle=lib.GetBoolean -- alias
function lib:GetNumber(flag,default)
	return tonumber(self:GetSet(flag) or default or 0)
end
function lib:GetString(flag,default)
	return tostring(self:GetSet(flag) or default or '')
end
local CLOSE=_G.FONT_COLOR_CODE_CLOSE or '|r'
local off=(_G.RED_FONT_COLOR_CODE or '|cffff0000') .. 'Off' ..  CLOSE
local on=(_G.GREEN_FONT_COLOR_CODE or '|cff00ff00') .. 'On' ..  CLOSE
function lib:PrintBoolean(flag)
	if (type(flag) == "string") then
		flag=self:GetBoolean(flag)
	end
	if (flag) then
		return on
	else
		return off
	end
end
function lib:GetSet(...)
	local flag,value=select(1,...)
	if (select('#',...) == 2) then
		self.db.profile.toggles[flag]=value
	else
		return self.db.profile.toggles[flag]
	end
end
function lib:GetVar(flag)
	return self:GetSet(flag)
end
function lib:SetVar(flag,value)
	return self:GetSet(flag,value)
end
function lib:Trigger(flag)
	local info=self:GetVarInfo(flag)
	if (info) then
		local value=info.type=="toggle" and self:GetBoolean(flag) or self:GetVar(flag)
		self._Apply[flag](self,flag,value)
	end

end
function lib:OptToggleSet(info,value)
	local flag=info.option.arg
	local tipo=info.option.type

	if (tipo=="toggle") then
		self:SetBoolean(flag,value)
	else
		self:GetSet(flag,value)
	end
	if (self:IsEnabled()) then
		self._Apply[flag](self,flag,value)
	end
end
function lib:OptToggleGet(info)
	local flag=info.option.arg
	local tipo=info.option.type
	if (tipo=="toggle") then
		return self:GetBoolean(flag)
	else
		return self:GetSet(flag)
	end
end
function lib:ApplySettings()
	if (type(self.ApplyAll)=="function") then
		self:ApplyAll()
	else
		for i,v in self:Vars() do
			self._Apply[i](self,i,v)
		end
	end
end
local neveropened=true
function lib:Gui(info)
	if (AceConfigDialog and AceGUI) then
		if (neveropened) then
			InterfaceAddOnsList_Update()
			neveropened=false
		end
		InterfaceOptionsFrame_OpenToCategory(self.CfgDlg)
	else
		self:Print("No GUI available")
	end
end

function lib:Help(info)
	if (AceConfigDialog and AceGUI) then
		if (neveropened) then
			InterfaceAddOnsList_Update()
			neveropened=false
		end
		InterfaceOptionsFrame_OpenToCategory(self.CfgRel)
	else
		self:Print("No GUI available")
	end
end
function lib:IsEventScheduled(flag)
	lib.timerhandles=lib.timerhandles or {}
	return lib.timerhandles[flag]
end
function lib:ScheduleRepeatingEvent(flag,...)
	lib.timerhandles=lib.timerhandles or {}
	lib.timerhandles[flag]=self:ScheduleRepeatingTimer(...)
end
function lib:CancelScheduledEvent(flag)
	lib.timerhandles=lib.timerhandles or {}
	local h=lib.timerhandles[flag]
	self:CancelTimer(h)
end
function lib:Trace(...)
	lib._Trace(self,0,...)
end
function lib:_Trace(skip,...)
	--pp(...)
	local stack={strsplit("\n",debugstack(3,5,0))}
	local info=stack[1 + skip or 0]
	--pp(info)
	--local file,line,func=info:match("(%s%.lua):(%d+) in function (.*)")
	--pp(file,line,func)
	local file,line,func=tostringall(strsplit(":",info))
	pp(strjoin(" ",tostringall(...)),
		format(" in %s:%s%s",C(file,'azure'),C(line,'red'),C(func,'orange'))
	)
end
function lib:Long(msg) C:OnScreen('Yellow',msg,20) end
function lib:Onscreen_Orange(msg) C:OnScreen('Orange',msg,2) end
function lib:Onscreen_Purple(msg) C:OnScreen('Purple',msg,8) end
function lib:Onscreen_Yellow(msg) C:OnScreen('Yellow',msg,1) end
function lib:Onscreen_Azure(msg) C:OnScreen('Azure',msg,1) end
function lib:Onscreen_Red(msg) print("calling C") C:OnScreen('Red',msg,1) end
function lib:Onscreen_Green(msg) C:OnScreen('Green',msg,1) end
function lib:OnScreen(color,...) C:OnScreen(color,strjoin(' ',tostringall(...))) end
function lib:TimeToStr(time) -- Converts time data to a string format
	local p,s,m,h;
	if (not time) then
		return ("0:00")
	end
	if (time < 0) then
		time=abs(time)
		p='-'
	else
		p=''
	end
	s = floor(mod(time, 60));
	m = floor(time/ 60);
	if (m > 59) then
		h=floor(m/60)
		m=floor(mod(m,60))
	end
	if (h) then
		return format("%s%d:%02d:%02d",p,h,m,s)
	else
		return format("%s%d:%02d",p,m,s)
	end
end

function lib:GetColorTable()
	return C
end
-- In case of upgrade, we need to redo embed for ALL Addons
-- This function get called on addon creation
-- Anything I define here is immediately available to addon code
function lib:Embed(target)
	-- Standard libins
	for name,method in pairs(lib) do
			if (name~="NewAddon" and name~="GetAddon" and name:sub(1,1)~="_") then
				target[name] = method
			end
	end
	target._Apply=target._Apply or {}
	target._Apply._handler=target
	setmetatable(target._Apply,varmeta)
	target.registry=target.registry or {}
	lib.mixinTargets[target] = true
end

local function kpairs(t,f)
	local a = new()
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then
				del(a)
				return nil
		else
				local k=a[i]
				a[i]=nil -- Should optimize memory usage
				return k, t[k]
		end
	end
	return iter
end
if (not _G.kpairs) then
		_G.kpairs=kpairs
end
function lib:getKpairs()
	return kpairs
end
-- This metatable is used to generate a sorted proxy to an hashed table.
-- It should not used directly
lib.mt={__metatable=true,__version=MINOR_VERSION}
local mt=lib.mt
function mt:__index(k)
	print(self,self.__source)
	if k=="n" then
		return #mt.keys[self.__source]
	end
	return self.__source[k]
end
function mt:__len()
	return #self.__keys
end
function mt:__newindex(k,v)
	local pos=#self.__keys+1
	for i,x in ipairs(self.__keys) do
		if x>k then
			pos=i
			break;
		end
	end
	if (k:sub(1,2)~="__") then
		table.insert(self.__keys,pos,k)
	end
	self.__source[k]=v -- We want to trigger metamethods on original table
end
function mt:__call()
	do
		local current=0
		return function(unsorted,i)
			current=current+1
			local k=self.__keys[current]
			if k then return k,self.__source[k] end
		end,self,0
	end
end
function lib:GetSortedProxy(table)
	local proxy=setmetatable({__keys={},__source=table,__metatable=true},mt)
	for k,v in pairs(table) do
		proxy[k]=v
	end
	return proxy
end

-------------------------------------------------------------------------------
-- ScheduleLeaveCombatAction Port
-- Shamelessly stolen from Ace2
-------------------------------------------------------------------------------
function lib:CancelAllCombatSchedules()
	local i = 0
	while true do
		i = i + 1
		if not combatSchedules[i] then
			break
		end
		local v = combatSchedules[i]
		if v.self == self then
			v = del(v)
			table.remove(combatSchedules, i)
			i = i - 1
		end
	end
end
do
	local tmp = {}
	local doaftercombataction
	function doaftercombataction()
		for i, v in ipairs(combatSchedules) do
			tmp[i] = v
			combatSchedules[i] = nil
		end
		for i, v in ipairs(tmp) do
			local func = v.func
			if func then
				local success, err = pcall(func, unpack(v, 1, v.n))
				if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
			else
				local obj = v.obj or v.self
				local method = v.method
				local obj_method = obj[method]
				if obj_method then
					local success, err = pcall(obj_method, obj, unpack(v, 1, v.n))
					if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
				end
			end
			tmp[i] = del(v)
		end
	end
	lib.frame:SetScript("OnEvent",nil)
	lib.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	lib.frame:SetScript("OnEvent",doaftercombataction)
end

function lib:ScheduleLeaveCombatAction(method, ...)
	if true then return self:OnLeaveCombat(method,...) end
	local style = type(method)
	if style == "string" and type(self[method]) ~= "function" then
		error("Cannot schedule a combat action to method %q, it does not exist", method)
	elseif style == "table" then
		local func = (...)
		if type(method[func]) ~= "function" then
			error("Cannot schedule a combat action to method %q, it does not exist", func)
		end
	end

	if not InCombatLockdown() then
		local success, err
		if type(method) == "function" then
			success, err = pcall(method, ...)
		elseif type(method) == "table" then
			local func = (...)
			success, err = pcall(method[func], method, select(2, ...))
		else
			success, err = pcall(self[method], self, ...)
		end
		if not success then print(method,err) end
		return
	end
	local t
	local n = select('#', ...)
	if style == "table" then
		t = new(select(2, ...))
		t.obj = method
		t.method = (...)
		t.n = n-1
	else
		t = new(...)
		t.n = n
		if style == "function" then
			t.func = method
		else
			t.method = method
		end
	end
	t.self = self
	table.insert(combatSchedules, t)
end
function lib:coroutineExecute(interval,func)
	local co=coroutine.wrap(func)
	local interval=interval
	local repeater
	repeater=function()
		if (co()) then
			C_Timer.After(interval,repeater)
		else
			repeater=nil
		end
	end
	return repeater()
end
if not lib.secureframe then
	lib.secureframe=CreateFrame("Button",nil,nil,"StaticPopupButtonTemplate,SecureActionButtonTemplate")
	lib.secureframe:Hide()
end
local function StopSpellCasting(this)
	local b2=_G[this:GetName().."Button2"]
	local AC=lib.secureframe
	AC:SetParent(b2)
	AC:SetAllPoints()
	AC:SetText(b2:GetText())
	AC:SetAttribute("type","stop")
	AC:SetScript("PostClick",function() b2:Click() end)
	AC:Show()
end
local function StopSpellCastingCleanup(this)
	local AC=lib.secureframe
	AC:SetParent(nil)
	AC:Hide()

end
local StaticPopupDialogs=StaticPopupDialogs
local StaticPopup_Show=StaticPopup_Show
function lib:Popup(msg,timeout,OnAccept,OnCancel,data,StopCasting)
	if InCombatLockdown() then
		return self:ScheduleLeaveCombatAction("Popup",msg,timeout,OnAccept,OnCancel,data,StopCasting)
	end
	msg=msg or "Something strange happened"
	if type(timeout)=="function" then
		StopCasting=data
		data=OnCancel
		OnAccept=timeout
		timeout=60
	end
	StaticPopupDialogs["LIBINIT_POPUP"] = StaticPopupDialogs["LIBINIT_POPUP"] or
	{
	text = msg,
	button1 = ACCEPT,
	showAlert = true,
	timeout = timeout or 60,
	exclusive = true,
	whileDead = true,
	interruptCinematic = true
	};
	local popup=StaticPopupDialogs["LIBINIT_POPUP"]
	if StopCasting then
		popup.OnShow=StopSpellCasting
		popup.OnHide=StopSpellCastingCleanup
	else
		popup.OnShow=nil
		popup.OnHide=nil
	end
	popup.text=msg
	popup.OnCancel=nil
	popup.OnAccept=OnAccept
	popup.button2=nil
	if (OnCancel) then
		if (type(OnCancel)=="function") then
			popup.OnCancel=OnCancel
		end
		popup.button2 = CANCEL
	end
	StaticPopup_Show("LIBINIT_POPUP",nil,nil,data);
end
local factory={} --#factory
do
	local nonce=0
	local GetTime=GetTime
	local function SetScript(this,...)
		this.child:SetScript(...)
	end
	local function SetStep(this,value)
		this:SetObeyStepOnDrag(true)
		this:SetValueStep(value)
		this:SetStepsPerPage(1)
	end
	function factory:Slider(father,min,max,current,message,tooltip)
		if type(message)=="table" then
			tooltip=message.desc
			message=message.name
		end
		local name=tostring(GetTime()*1000) ..nonce
		nonce=nonce+1
		local sl = CreateFrame('Slider',name, father, 'OptionsSliderTemplate')
		sl:SetWidth(128)
		sl:SetHeight(20)
		sl:SetOrientation('HORIZONTAL')
		sl:SetMinMaxValues(min, max)
		sl:SetValue(current)
		sl.SetStep=SetStep
		sl.Low=_G[name ..'Low']
		sl.Low:SetText(min)
		sl.High=_G[name .. 'High']
		sl.High:SetText(max)
		sl.Text=_G[name.. 'Text']
		sl.Text:SetText(message)
		sl.OnValueChanged=function(this,value)
			if (not this.unrounded) then
				value = math.floor(value)
			end
			if (this.isPercent) then
				this.Text:SetFormattedText('%d%%',value)
			else
				this.Text:SetText(value)
			end
			return value
		end
		sl.SetText=function(this,value) this.Text:SetText(value) end
		sl.SetFormattedText=function(this,...) this.Text:SetFormattedText(...) end
		sl.SetTextColor=function(this,...) this.Text:SetTextColor(...) end
		sl:SetScript("OnValueChanged",sl.OnValueChanged)
		sl.tooltipText=tooltip
		return sl
	end
	function factory:Checkbox(father,current,message,tooltip)
		if type(message)=="table" then
			tooltip=message.desc
			message=message.name
		end
		local name=tostring(GetTime()*1000) ..nonce
		nonce=nonce+1
		local frame=CreateFrame("Frame",nil,father)
		local ck=CreateFrame("CheckButton",name,frame,"ChatConfigCheckButtonTemplate")
		frame.SetScript=SetScript
		frame.child=ck
		ck:SetPoint('TOPLEFT')
		ck.Text=_G[name..'Text']
		ck.Text:SetText(message)
		ck:SetChecked(current)
		ck.tooltip=tooltip
		frame:SetWidth(ck:GetWidth()+ck.Text:GetWidth()+2)
		frame:SetHeight(ck:GetHeight())
		return frame
	end
	function factory:Dropdown(father,current,list,message,tooltip)
		if type(message)=="table" then
			tooltip=message.desc
			message=message.name
		end
		do
		local dd=CreateFrame("Frame",nil,father)
		if (tooltip) then
			dd.tooltip=tooltip
			dd:SetScript("OnEnter",function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
					GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, (self.tooltipStyle or true));
				end
			)
		end
		dd:SetScript("OnLeave",function() GameTooltip:Hide() end)
		dd.text=dd:CreateFontString(nil,"ARTWORK","GameFontHighlight")
		function dd:SetText(...)
			self.text:SetText(...)
		end
		function dd:SetFormattedText(...)
			self.text:SetFormattedText(...)
		end
		function dd:SetTextColor(...)
			self.text:SetTextColor(...)
		end
		function dd:OnChange() end
		function dd:OnValueChanged(this,index,value)
			print(this:GetName(),value,index)
			value=value or index
			UIDropDownMenu_SetSelectedID(dd,index)
			return self:OnChange(value)
		end
		function dd:SetOnChange(func)
			self.OnChange=func
		end
		dd.list=list
		local name=tostring(GetTime()*1000) ..nonce
		nonce=nonce+1
		dd.dropdown=CreateFrame('Frame',name,father,"UIDropDownMenuTemplate")
		UIDropDownMenu_Initialize(frame, function(...)
			local i=0
			for k,v in pairs(dd.list) do
				i=i+1
				local info=UIDropDownMenu_CreateInfo()
				info.text=v
				info.value=v
				info.func=function(...) return dd:OnValueChanged(...) end
				info.arg1=i
				info.arg2=v
				UIDropDownMenu_AddButton(info,1)
			end
		end)
		UIDropDownMenu_SetWidth(frame, 100);
		UIDropDownMenu_SetButtonWidth(frame, 124)
		UIDropDownMenu_SetSelectedID(frame, 1)
		UIDropDownMenu_JustifyText(frame, "LEFT")
		end
	end
end
function lib:GetFactory()
	return factory
end
local meta={__index=_G,
__newindex=function(t,k,v)
	assert(type(_G[k]) == 'nil',"Attempting to override global " ..k)
	return rawset(t,k,v)
end
}
function lib:SetCustomEnvironment(new_env)
	local old_env = getfenv(2)
	if old_env==new_env then return end
	if getmetatable(new_env)==meta then return end
	if not getmetatable(new_env) then
		if not new_env.print then new_env.print=dprint end
		setmetatable(new_env,meta)
		new_env.dprint=dprint
	else
		assert(false,"new_env already has metatable")
	end
	setfenv(2, new_env)
end
--- reembed routine
for target,_ in pairs(lib.mixinTargets) do
	lib:Embed(target)
end
local l=LibStub("AceLocale-3.0")
-- To avoid clash between versions, localization is versioned on major and minor
-- Lua strings are immutable so having more copies of the same string does not waist a noticeable slice of memory
local me=MAJOR_VERSION .. MINOR_VERSION

do
	local L=l:NewLocale(me,"enUS",true,true)
	L["Configuration"] = true
L["Description"] = true
L["Libraries"] = true
L["Release Notes"] = true
L["Toggles"] = true

	L=l:NewLocale(me,"ptBR")
	if (L) then
	L["Configuration"] = "configura\195\167\195\163o"
L["Description"] = "Descri\195\167\195\163o"
L["Libraries"] = "bibliotecas"
L["Release Notes"] = "Notas de Lan\195\167amento"
L["Toggles"] = "Alterna"

	end
	L=l:NewLocale(me,"frFR")
	if (L) then
	L["Configuration"] = "configuration"
L["Description"] = "description"
L["Libraries"] = "biblioth\195\168ques"
L["Release Notes"] = "notes de version"
L["Toggles"] = "Bascule"

	end
	L=l:NewLocale(me,"deDE")
	if (L) then
	L["Configuration"] = "Konfiguration"
L["Description"] = "Beschreibung"
L["Libraries"] = "Bibliotheken"
L["Release Notes"] = true
L["Toggles"] = "Schaltet"

	end
	L=l:NewLocale(me,"itIT")
	if (L) then
	L["Configuration"] = "Configurazione"
L["Description"] = "Descrizione"
L["Libraries"] = "Librerie"
L["Release Notes"] = "Note di rilascio"
L["Toggles"] = "Interruttori"

	end
	L=l:NewLocale(me,"koKR")
	if (L) then
	L["Configuration"] = "\234\181\172\236\132\177"
L["Description"] = "\236\132\164\235\170\133"
L["Libraries"] = "\235\157\188\236\157\180\235\184\140\235\159\172\235\166\172"
L["Release Notes"] = "\235\166\180\235\166\172\236\138\164 \235\133\184\237\138\184"
L["Toggles"] = "\236\160\132\237\153\152"

	end
	L=l:NewLocale(me,"esMX")
	if (L) then
	L["Configuration"] = "Configuraci\195\179n"
L["Description"] = "Descripci\195\179n"
L["Libraries"] = "Bibliotecas"
L["Release Notes"] = "Notas de la versi\195\179n"
L["Toggles"] = "Alterna"

	end
	L=l:NewLocale(me,"ruRU")
	if (L) then
	L["Configuration"] = "\208\154\208\190\208\189\209\132\208\184\208\179\209\131\209\128\208\176\209\134\208\184\209\143"
L["Description"] = "\208\158\208\191\208\184\209\129\208\176\208\189\208\184\208\181"
L["Libraries"] = "\208\145\208\184\208\177\208\187\208\184\208\190\209\130\208\181\208\186\208\184"
L["Release Notes"] = "\208\159\209\128\208\184\208\188\208\181\209\135\208\176\208\189\208\184\209\143 \208\186 \208\178\209\139\208\191\209\131\209\129\208\186\209\131"
L["Toggles"] = "\208\159\208\181\209\128\208\181\208\186\208\187\209\142\209\135\208\181\208\189\208\184\208\181"

	end
	L=l:NewLocale(me,"zhCN")
	if (L) then
	L["Configuration"] = "\233\133\141\231\189\174"
L["Description"] = "\232\175\180\230\152\142"
L["Libraries"] = "\229\155\190\228\185\166\233\166\134"
L["Release Notes"] = "\229\143\145\232\161\140\232\175\180\230\152\142"
L["Toggles"] = "\229\136\135\230\141\162"

	end
	L=l:NewLocale(me,"esES")
	if (L) then
	L["Configuration"] = "Configuraci\195\179n"
L["Description"] = "Descripci\195\179n"
L["Libraries"] = "Bibliotecas"
L["Release Notes"] = "Notas de la versi\195\179n"
L["Toggles"] = "Alterna"

	end
	L=l:NewLocale(me,"zhTW")
	if (L) then
	L["Configuration"] = "\233\133\141\231\189\174"
L["Description"] = "\232\175\180\230\152\142"
L["Libraries"] = "\229\155\190\228\185\166\233\166\134"
L["Release Notes"] = "\229\143\145\232\161\140\232\175\180\230\152\142"
L["Toggles"] = "\229\136\135\230\141\162"

	end
end
L=LibStub("AceLocale-3.0"):GetLocale(me,true)

