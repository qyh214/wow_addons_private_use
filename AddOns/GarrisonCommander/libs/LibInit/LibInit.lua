--- Main methods directly available in your addon
-- @classmod lib
-- @author Alar of Runetotem
-- @release 51
-- @set sort=true
-- @usage
-- -- Create a new addon this way:
-- local me,ns=... -- Wow engine passes you your addon name and a private table to use
-- addon=LibStub("LibInit"):newAddon(ns,me)
-- -- Since now, all LibInit methods are available on self
local me, ns = ...
local __FILE__=tostring(debugstack(1,2,0):match("(.*):12:")) -- Always check line number in regexp and file
local MAJOR_VERSION = "LibInit"
local MINOR_VERSION = 51
local LibStub=LibStub
local dprint=function() end
local encapsulate  = function ()
  if LibDebug and AlarDbg then
    LibDebug()
    dprint=print
  end
end
encapsulate()
local obj,old=LibStub:NewLibrary(MAJOR_VERSION,MINOR_VERSION)
if obj then
	dprint(strconcat("Loading ",MAJOR_VERSION,'.',MINOR_VERSION,' from ',__FILE__))
	if old then
		dprint(strconcat("Upgrading ",MAJOR_VERSION,'.',old))
	end
--	obj.loadedFrom=__FILE__
else
	dprint(strconcat("Already loaded ",MAJOR_VERSION,'.',MINOR_VERSION," checked from ", __FILE__))
	return
end
local off=(_G.RED_FONT_COLOR_CODE or '|cffff0000') .. (_G.VIDEO_OPTIONS_DISABLED or  'Off') .. ( _G.FONT_COLOR_CODE_CLOSE or '|r')
local on=(_G.GREEN_FONT_COLOR_CODE or '|cff00ff00') .. (_G.VIDEO_OPTIONS_ENABLED or 'On') .. ( _G.FONT_COLOR_CODE_CLOSE or '|r')
local nop=function() end
local pp=print -- Keeping a handy plain print around
local assert=assert
local strconcat=strconcat
local tostring=tostring
local tremove=tremove
local _G=_G -- Unmodified env
--@debug@
-- Checking packager behaviour
--@end-debug@

local lib=obj --#Lib
function lib:Info()
	print(MAJOR_VERSION,MINOR_VERSION,' loaded from ',__FILE__)
end
-- A default dictionary, in case something went wrong with localization
local L=setmetatable({},{
  __index=function(t,k) return k end
})
local C
local F
function lib:_SetLocalization(localization)
  L=localization
end
function lib:_SetColorize(colorize)
  C=colorize
end
function lib:_SetFactory(factory)
  F=factory
end
local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
-- Upvalues
local _G=_G
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
local toc=select(4,GetBuildInfo())

--]]
-- Help sections
local titles
local RELNOTES
local LIBRARIES
local PROFILE
local HELPSECTIONS
local AceConfig = LibStub("AceConfig-3.0",true)
assert(AceConfig,"LibInit needs AceConfig-3.0")
local AceRegistry = LibStub("AceConfigRegistry-3.0",true)
local AceDBOptions=LibStub("AceDBOptions-3.0",true)
local AceConfigDialog=LibStub("AceConfigDialog-3.0",true)
local AceGUI=LibStub("AceGUI-3.0",true)
local Ace=LibStub("AceAddon-3.0")
local AceLocale=LibStub("AceLocale-3.0",true)
local AceDB  = LibStub("AceDB-3.0",true)


-- Persistent tables

lib.mixinTargets=lib.mixinTargets or {}
--- Runtime storage for variables.
--
lib.toggles=lib.toggles or {}
lib.chats=lib.chats or {}
--- Runtime storage for information on LibInit managed addons.
--
lib.options=lib.options or {}
--- Recycling system pool.
--
lib.pool=lib.pool or setmetatable({},{__mode="k",__tostring=function(t) return "Recycle Pool:" end})
--- Mixins list
--
lib.mixins=lib.mixins or {}
wipe(lib.mixins)
-- Recycling function from ACE3

--- Table Recycling System.
--
-- A set of functions to allow for table reusing
-- @section Recycle
-- @usage
-- -- You better upvalue these functions
-- local addon=LibStub("LibInit"):NewAddon("myaddon")
-- local new=addon:Wrap("NewTable")
-- local new=addon:Wrap("DelTable")
--


local new, del, add, recursivedel,copy, cached, stats
do
	local meta={__metatable="RECYCLE"}
	local pool = lib.pool
--@debug@
	local newcount, delcount,createdcount= 0,0,0
--@end-debug@
	function new(t)
--@debug@
		newcount = newcount + 1
--@end-debug@
		if type(t)=="table" then
			local rc=pcall(setmetatable,t,meta)
			return t
		else
			t = next(pool)
		end
		if t then
			pool[t] = nil
			return t
		else
--@debug@
			createdcount = createdcount + 1
--@end-debug@
			return setmetatable({},meta)
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
--@debug@
		delcount = delcount + 1
--@end-debug@
		if getmetatable(t)==meta then
			wipe(t)
			pool[t] = true
		end
	end
	function recursivedel(t,level)
		level=level or 0
--@debug@
		delcount = delcount + 1
--@end-debug@
		for k,v in pairs(t) do
			if type(v)=="table" and getmetatable(v) == "RECYCLE" then
				if level < 2 then
					recursivedel(v,level+1)
				end
			end
		end
		if getmetatable(t)=="RECYCLE" then
			wipe(t)
			pool[t] = true
		end
	end
	function cached()
		local n = 0
		for k in pairs(pool) do
			n = n + 1
		end
		return n
	end
--@debug@
	function stats()
		print("Created:",createdcount)
		print("Aquired:",newcount)
		print("Released:",delcount)
		print("Cached:",cached())
	end
--@end-debug@
--[===[@non-debug@
	function stats()
		return
	end
--@end-non-debug@]===]
end
--- Get a new table from the recycle pool
-- Preferred usage is assigning to a local via wrap function
-- @tparam[opt=nil] table tbl Optional table which will be added to the pool after use. Must NOT have a metatable
-- @treturn table A new table or a recycled one. Table is wiped
-- @usage
-- -- Assuming you upvalued it as new
-- local t=new()
-- -- do something
-- del(t)
-- t=new()
-- t.check=new()
-- del(t,true) -- will recycle both t and t.check
function lib:NewTable(tbl)
	if tbl and lib.options[tbl] then
		return new()
	else
		return new(tbl)
	end
end
--- Returns a table to the recycle pool
-- Table will be wiped
-- Only manages tables allocated via NewTable
-- Other tables are left intact
-- -- Preferred usage is assigning to a local via wrap function
-- @tparam table tbl table to be recycled
-- @tparam[opt=true] boolean recursive If true, embedded tables added cia new table will be wiped and recycled
--
function lib:DelTable(tbl,recursive)
	if type(recursive)=="nil" then recursive=true end
	--assert(type(tbl)=="table","Usage: DelTable(table) called as DelTable(" ..tostring(tbl) ..','..tostring(recursive)..")")
	return recursive and recursivedel(tbl) or del(tbl)
end

function lib:CachedTableCount()
	return cached()
end
function lib:CacheStats()
	return stats()
end

--- Addon management.
-- @section addon

--- Create a new AceAddon-3.0 addon.
--
-- Any library you specified will be embeded, and the addon will be scheduled for
-- its OnInitializee and OnEnabled callbacks.
--
-- The final addon object, with all libraries embeded, will be returned.
--
-- Options table format:
--
--* profile: choose the initial profile (if omittete, uses a per character one)
--* noswitch: disables Ace profile managemente, user will not be able to change it
--* nogui: do not generate a gui for configuration
--* nohelp: do not generate help (actually, help generation is not yet implemented)
--* enhancedProfile: adds "Switch all profiles to default" and "Remove unused profiles" do Ace profile gui
--
-- @tparam[opt] table target to use as a base for the addon (optional)
-- @tparam string name Name of the addon object to create
-- @tparam[opt] table options options list
-- @tparam[opt] bool full If true, all available and embeddable Ace3 library are embedded
-- @tparam[opt] string ... List of libraries to embed into the addon
-- @treturn table new addon
--
-- @usage
-- --Create a simple addon object
-- MyAddon = LibStub("LibInit"):NewAddon("MyAddon", "AceEvent-3.0")
--
-- -- Create a Addon object based on the table of a frame
-- local MyFrame = CreateFrame("Frame")
-- MyAddon = LibStub("LibInit"):NewAddon(MyFrame, "MyAddon", "AceEvent-3.0")
-- -- Create an Addon based on the private table provided by Blizzard Code:
-- local myname,addon = ...
-- LibStub("LibInit"):NewAddon(addon,myname)
--
function lib:NewAddon(target,...)
	local name
	local customOptions
	local start=1
	if type(target) ~= "table" then
		name=target
		target={}
	else
		name=(select(1,...))
		start=2
	end
	assert(Ace,"Could not find Ace3 Library")
	assert(type(name)=="string","Name is mandatory")
	local appo={}
	appo[MAJOR_VERSION]=true
	appo["AceConsole-3.0"]=true
	for i=start,select('#',...) do
		local mix=select(i,...)
		if type(mix)=="boolean" and mix then
			for n,k in  LibStub:IterateLibraries() do
				if (n:match("Ace%w*-3%.0") and k.Embed) then appo[n]=true end
			end
		elseif type(mix)=="string" then
			appo[mix]=true
		elseif type(mix)=="table" then
			customOptions=mix
		end
	end
	local mixins=new()
	for i,_ in pairs(appo) do
		tinsert(mixins,i)
	end
	local target=Ace:NewAddon(target,name,unpack(mixins))
	del(mixins)
	appo=nil
	local options={}
	options.name=name
	options.first=true
	options.libstub=__FILE__
	options.version=GetAddOnMetadata(name,'Version') or "Internal"
	if (options.version:sub(1,1)=='@') then
		options.version=GetAddOnMetadata(name,'X-Version') or "Internal"
	end
	local b,e=options.version:find(" ")
	if b and b>1 then
		options.version=options.version:sub(1,b-1)
	end
	options.revision=GetAddOnMetadata(name,'X-revision') or "Alpha"
	if (options.revision:sub(1,1)=='@') then
		options.revision='Development'
	end
	options.prettyversion=format("%s (Revision: %s)",tostringall(options.version,options.revision))
	options.title=GetAddOnMetadata(name,"title") or 'No title'
	options.notes=GetAddOnMetadata(name,"notes") or 'No notes'
	options.libinit=MAJOR_VERSION .. ' ' .. MINOR_VERSION
	-- Setting sensible default for mandatory fields
	options.ID=GetAddOnMetadata(name,"X-ID") or name
	options.DATABASE=GetAddOnMetadata(name,"X-Database") or "db" .. options.ID
	lib.toggles[target]={}
	if customOptions then
		for k,v in pairs(customOptions) do
			local key=strlower(k)
			if key=="enhanceprofile" then key = "enhancedprofile" end
			if 	key=="profile"
				or key=="noswitch"
				or key=="nogui"
				or key=="nohelp"
				or key=="enhancedprofile"
					then
				options[key]=v
			else
				error("Invalid options: " .. k)
			end
		end
	end
	lib.options[target]=options
	RELNOTES=L["Release Notes"]
	PROFILE=L["Profile"]
	HELPSECTIONS={PROFILE,RELNOTES}
	titles={
		RELNOTES=RELNOTES,
		PROFILE=PROFILE
	}
	return target
end

function lib:NewSubModule(name,...)
	local obj=self:NewModule(name,...)
	-- To avoid strange interactions
	obj.OnInitialized=function()end -- placeholder
	obj.OnInitialize=function(self,...) return  self:OnInitialized(...) end
	obj.OnEnable=nil
	obj.OnDisable=nil
	return obj
end
function lib:NewSubClass(name)
	return self:NewSubModule(name,self)
end

--- Returns a closure to call a method as simple local function
-- @tparam string name Method name
-- @usage local print=self:Wrap("print") ; print("Hello") same as self:print("Hello")
-- @treturn func Wrapper
function lib:Wrap(name)
	if (name=="Trace") then
		return function(...) lib._Trace(self,1,...) end
	end
	if (type(self[name])=="function") then
		return function(...) return self[name](self,...) end
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

--- Generic.
-- General utilities
-- @section utils

--- Colors a string.
-- @tparam string stringa A string
-- @tparam string colore Name of a color (red, rare, alliance and so on). If not existent uses yellow
-- @treturn string Colored string
--
function lib:Colorize(stringa,colore)
	return C(stringa,colore) .. "|r"
end
function lib:GetTocVersion()
	return select(4,GetBuildInfo())
end

-- Combat scheduler done with LibCallbackHandler
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
		for _,c in pairs(lib.coroutines) do
			if c.waiting then
				c.waiting=false
				C_Timer.After(c.interval,c.repeater) -- to avoid hammering client with a shitload of corooutines starting together
			end
		end
	end)
	lib.CombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
end
local function Run(args) tremove(args,1)(unpack(args)) end

--- Executes an action as soon as combat restrictions lift.
-- Action can be executed immediately if toon is out of combat
-- @tparam string|func action To be executed, Can be a function or a method name
-- @tparam[opt] mixed ... More parameters will be directly passed to action
--
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

--- Return a named chatframe.
--  Returns nil if chat does not exist
-- @tparam[opt=DEFAULT_CHAT_FRAME] string chat Chat name
-- @treturn frame|nil requested chat frame, can be nil if "chat" does not exist
--
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
-- Check if the unit in target hast the requested class
-- @tparam string class Requested Class
-- @tparam string target Requested Unit (default 'player')
-- @return boolean true if target has the requeste class
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
-- @tparam string|table msg Can be a string (when called from chat command) or a table (wbe called by Ace3 Options Table Handler)
-- @tparam number n index in command list
-- @return command,subcommand,arg,full string after command
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
-- @tparam string itemlink A standard wow itemlink
-- @treturn number itemId or 0
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
-- Return the total numner of bag slots
-- @treturn number Total bag slots
function lib:GetTotalBagSlots()
	local i=0
	for bag=0,NUM_BAG_SLOTS do
		i=i+GetContainerNumSlots(bag)
	end
	return i
end
---
-- Scans Bags for an item based on different criteria
--
-- All parameters are optional.
--
-- With no parameters ScanBags returns the first empty slot
--
-- Passing starbag and scanslot allows to continue scanning after the first finding
--
-- @tparam[opt=0] number index index in GetItemInfo result. 0 is a special case to match just itemid
-- @tparam[opt=0] number value value against to match. 0 is a special case for empty slot
-- @tparam[opt=0] number startbag Initialbag to start scan from
-- @tparam[opt=1] number startslot Initial slot to start scan from
-- @treturn[1] number ItemId
-- @treturn[1] number bag
-- @treturn[1] number slot
-- @treturn[1] list all return value from GetItemInfo called on _Itemid_
-- @treturn[2] bool false If nothing found
--
function lib:ScanBags(index,value,startbag,startslot)
	index=index or 0
	value=value or 0
	startbag=startbag or 0
	startslot=startslot or 1
	for bag=startbag,NUM_BAG_SLOTS do
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
			elseif value==0 then
				return bag,slot

			end
		end
	end
	return false
end

--- Returns number of free bag slots and total bagt slots.
-- @treturn number Free bag slots
-- @treturn number Total bag slots
function lib:GetBagSlotCount()
	local free,total=0,0
	for bag=0,NUM_BAG_SLOTS do
		free=free+(GetContainerNumFreeSlots(bag) or 0)
		total=total+(GetContainerNumSlots(bag) or 0)
	end
	return free,total
end

--- Returns unit's health as a normalized percent value
-- @tparam string unit A standard unit name
-- @treturn number health as percent value
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
local function loadOptionsTable(self)
	local options=lib.options[self]
	self.OptionsTable={
		handler=self,
		type="group",
		childGroups="tab",
		name=options.title,
		desc=options.notes,
		args={
			gui = {
				name="GUI",
				desc=_G.CHAT_CONFIGURATION,
				type="execute",
				func="Gui",
				guiHidden=true,
			},
--@debug@
			help = {
				name="HELP",
				desc="Show help",
				type="execute",
				func="Help",
				guiHidden=true,
			},
			debug = {
				name="DBG",
				desc="Enable debug",
				type="execute",
				func="Debug",
				guiHidden=true,
				cmdHidden=true,
			},
--@end-debug@
			silent = {
				name="SILENT",
				desc="Eliminates startup messages",
				type="execute",
				func=function()
					self.db.global.silent=not self.db.global.silent
					self:Print("Silent is now",self.db.global.silent and "true" or "false" )
				end,
				guiHidden=true,
			},
			on = {
				name=strlower(_G.ENABLE),
				desc=_G.ENABLE .. ' ' .. options.title,
				type="execute",
				func="Enable",
				guiHidden=true,
			},
			off = {
				name=strlower(_G.DISABLE),
				desc=_G.DISABLE .. ' ' .. options.title,
				type="execute",
				func="Disable",
				guiHidden=true,
				arg='Active'
			},
		}
	}
end
local function loadDbDefaults(self)
	self.DbDefaults={
		char={
			firstrun=true,
			lastversion=0,
		},
		global={
			firstrun=true,
			lastversion=0,
			lastinterface=60200
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
local function SetCommonProfile(info,...)
	local db=info.handler.db
	for k,v in pairs(db.sv.profileKeys) do
		db.sv.profileKeys[k]="Default"
	end
	db:SetProfile("Default")
end
local function PurgeProfiles(info,...)
	local profiles=new()
	local used=new()
	local db=info.handler.db
	db:GetProfiles(profiles)
	for k,v in pairs(db.sv.profileKeys) do
		used[v]=true
	end
	for _,v in ipairs(profiles) do
		if not used[v] then
			db:DeleteProfile(v)
		end
	end
	del(used)
	del(profiles)

end
local function SetupProfileSwitcher(tbl,addon)
	local profiles=tbl.handler:ListProfiles({args="both"})
	local default=profiles.Default or "Default"
	wipe(profiles)
	tbl.args.UseDefault_Desc={
		order=900,
		type='description',
		name="\n"..format(L['UseDefault_Desc'],default)
	}
	tbl.args.UseDefault={
		order=910,
		type='execute',
		func=SetCommonProfile,
		name=format(L['UseDefault1'],default),
		desc=format(L['UseDefault2'],default),
		width="double",
	}
	tbl.args.Purge_Desc={
		order=920,
		type='description',
		--name="forcedescname",
		name="\n"..L['Purge_Desc'],
	}
	tbl.args.Purge={
		order=930,
		type='execute',
		func=PurgeProfiles,
		name=L['Purge1'],
		desc=L['Purge2'],
		width="double",
	}
end
function lib:OnInitialize(...)
	self.numericversion=self:NumericVersion() -- Initialized now becaus NumericVersion could be overrided
	--CachedGetItemInfo=self:GetCachingGetItemInfo()
	loadOptionsTable(self)
	loadDbDefaults(self)
	self:SetOptionsTable(self.OptionsTable) --hook
	self:SetDbDefaults(self.DbDefaults) -- hook
	local options=lib.options[self]
	self.version=self.version or options.version
	self.prettyversion=self.prettyversion or options.prettyversion
	self.revision=self.revision or options.revision
	if (AceDB and not self.db) then
		self.db=AceDB:New(options.DATABASE,nil,options.profile)
	end
	if self.db then
		self.db:RegisterDefaults(self.DbDefaults)
		if (not self.db.global.silent) then
			self:Print(format("Version %s %s loaded (%s)",
				self:Colorize(options.version,'green'),
				self:Colorize(format("(Revision: %s)",options.revision),"silver"),
				"Disable message with /" .. strlower(options.ID) .. " silent")
			)
			self:Print("Using profile ",self.db:GetCurrentProfile())
		end
		self:SetEnabledState(self:GetBoolean("Active"))
	else
		self.db=setmetatable({},{
			__index=function(t,l)
				assert(false,"You need AceDB-3.0 in order to use database")
			end
			}
		)
		self:SetEnabledState(true)
	end
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
	local main=options.name
	BuildHelp(self)
	if AceConfig and not options.nogui then
		AceConfig:RegisterOptionsTable(main,self.OptionsTable,{main,strlower(options.ID)})
		self.CfgDlg=AceConfigDialog:AddToBlizOptions(main,main )
		if (not ignoreProfile and not options.noswitch) then
			if (AceDBOptions) then
				local profileOpts=AceDBOptions:GetOptionsTable(self.db)
				self.ProfileOpts={} -- We dont want to propagate this change to all ace3 addons
				for k,v in pairs(profileOpts) do
					if k=='args' then
						self.ProfileOpts.args={}
						for k2,v2 in pairs(v) do
							self.ProfileOpts.args[k2]=v2
						end
					else
						self.ProfileOpts[k]=v
					end
				end
				titles.PROFILE=self.ProfileOpts.name
				self.ProfileOpts.name=self.name
				if options.enhancedprofile then
					SetupProfileSwitcher(self.ProfileOpts,self)
				end
				local profile=main..PROFILE
			end
			AceConfig:RegisterOptionsTable(main .. PROFILE,self.ProfileOpts)
			AceConfigDialog:AddToBlizOptions(main .. PROFILE,titles.PROFILE,main)
		end
	else
		self.OptionsTable.args.gui=nil
	end
	if (self.help[RELNOTES]~='') then
		self.CfgRel=AceConfigDialog:AddToBlizOptions(main..RELNOTES,titles.RELNOTES,main)
	end
	if AceDB then
		self:UpdateVersion()
	end
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

--- Help system.
-- @section help
function lib:HF_Push(section,text)
	if section then section=titles[section] end
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
		function getlibs(l)
				local appo={}
				if (not libs) then return end
				for i,_ in pairs(libs) do
						table.insert(appo,i)
				end
				table.sort(appo)
				for _,libname in pairs(appo) do
						local minor=libs[libname]
						l:HF_Pre(format("%s release: %s",l:Colorize(libname,'green'),l:Colorize(minor,'orange')),LIBRARIES)
				end
				libs=nil
		end
end
function lib:HF_Toggle(flag,description)
	flag=C(format("/%s toggle %s: ",strlower(lib.options[self].ID),flag),'orange') ..C(description,'white')
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
	command=lib.options[self].ID .. ' ' .. command
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
			name = lib.options[self].title .. (versione or ""),
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
--- Configuration panel.
-- These functions allow to build a ACE option table which will be fed to
-- AceConfigDialog:AddToBlizOptions
-- @section add

--self:AddLabel("General","General Options",C.Green)
---@section Variables management
--- Create a tab (ace type "header")
-- @tparam string title
-- @tparam string description
-- @tparam string stringcolor esadecimal color string without "|cff"
-- @treturn table Pointer to option table fragment added
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
--- Create a label (ace type "group")
-- @tparam string title
-- @tparam string description
-- @tparam string stringcolor esadecimal color string without "|cff"
-- @treturn table Pointer to option table fragment added
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
--- Create a description (ace type "description")
-- @tparam string text
-- @tparam[opt] string image
-- @tparam[opt] number imageHeight
-- @tparam[opt] string imageWidth
-- @tparam[opt] table imageCoords
-- @treturn table Pointer to option table fragment added
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
function lib:AddBoolean(...) return self:AddToggle(...) end
--- Create a boolean configuration var
-- @tparam string flag variable name
-- @tparam any defaultvalue
-- @tparam string name public name  (appears in gui)
-- @tparam[opt=name] string description long description (appears in tooltip)
-- @tparam[opt] string icon icon reference
-- @treturn table A reference to the newly create item inside Ace OptionTable
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
function lib:AddMultiSelect(flag,defaultvalue,...)
	local t=self:AddSelect(flag,defaultvalue,...)
	t.type="multiselect"
	if type(self.db.profile.toggles[flag])~="table" then
		self.db.profile.toggles[flag]={}
	end
	if type(self.db.profile.toggles[flag]._default)=="nil" then
		self.db.profile.toggles[flag]=defaultvalue
		self.db.profile.toggles[flag]._default=true
	end
	return t
end
--self:AddSlider("RESTIMER",5,1,10,"Enable res timer","Shows a timer for battlefield resser",1)
function lib:AddRange(...) return self:AddSlider(...) end
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
		step=tonumber(step) or 1
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
	return self[info.arg](self,args,strsplit(' ',args))
end
function lib:AddOpenCmd(command,method,description,arguments,private)
	method=method or command
	description=description or command
	local group=getgroup(self)
	if (not private) then
		local command=C('/' .. lib.options[self].ID .. ' ' .. command .. " (" .. description .. ")" ,'orange')
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



--self:AddChatCmd(method,label,description)
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
function lib:GetIndexedVar(flag,index)
	local rc=GetVar(flag)
	if index and type(rc)=="table" then
		return rc[index]
	else
		return rc
	end

end
function lib:GetVar(flag)
	return self:GetSet(flag)
end
function lib:SetVar(flag,value)
	return self:GetSet(flag,value)
end
--- Simulates a configuration  variable change.
--
-- Generates Apply* events if needed
-- @tparam string flag Variable name
function lib:Trigger(flag)
	local info=self:GetVarInfo(flag)
	if (info) then
		local value=info.type=="toggle" and self:GetBoolean(flag) or self:GetVar(flag)
		self._Apply[flag](self,flag,value)
	end

end
function lib:OptToggleSet(info,value,extra)
	return self:ToggleSet(info.option.arg,info.option.type,value,extra)
end
function lib:ToggleSet(flag,tipo,value,extra)
	if (tipo=="toggle") then
		self:SetBoolean(flag,value)
	elseif (tipo=="multiselect") then
		self.db.profile.toggles[flag][value]=extra
	else
		self:GetSet(flag,value)
	end
	if (self:IsEnabled()) then
		self._Apply[flag](self,flag,value)
	end
end
function lib:OptToggleGet(info,extra)
	return self:ToggleGet(info.option.arg,info.option.type,extra)
end
function lib:ToggleGet(flag,tipo,extra)
	if (tipo=="toggle") then
		return self:GetBoolean(flag)
	elseif (tipo=="multiselect") then
		if type(self.db.profile.toggles[flag])~="table" then
			self.db.profile.toggles[flag]={}
		end
		return self.db.profile.toggles[flag][extra]
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

--- Hooks.
-- Stub function you can (and should) overrid in your addon
-- @section hooks

--- Called When the embedding addon is enabled
--
function lib:OnEmbedEnable(first)
end

--- Called when the wmbedding addon is disabled
--
function lib:OnEmbedDisable()
end

--- Called after VARIABLES_LOADED event, by OnInitialize Ace Hook
--
function lib:OnInitialized()
	print("|cff33ff99"..tostring( self ).."|r:",format(ITEM_MISSING,"OnInitialized"))
end

--- Called to fill the help system
--
function lib:LoadHelp()
end

--- Called with the db default table as argument
--
-- You can customize defaults here
--
-- @tparam table tbl ACE DB default table
function lib:SetDbDefaults(tbl)
end

--- Called with the current option table
--
-- You can change the default options table here
-- @tparam table tbl ACE Options Table
--
function lib:SetOptionsTable(tbl)
end

--- Called from the OnEnable ACE event
-- @function lib:OnEnabled
-- @tparam[opt] bool first True on the first activation
function lib:OnEnable()
	if (self.OnEnabled) then
		if (not self.db.global.silent) then
			self:Print(C(VIDEO_OPTIONS_ENABLED,"green"))
		end
		pcall(self.OnEnabled,self,lib.options[self].first)
		lib.options[self].first=nil
	end
end

--- Called from the OnDisable ACE event
-- @function lib:OnDisabled
--
function lib:OnDisable(...)
	if (self.OnDisabled) then
		if (not self.db.global.silent) then
			self.print(C(VIDEO_OPTIONS_DISABLED,'red'))
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
function lib:Long(msg) C:OnScreen('Yellow',msg,20) end
function lib:Onscreen_Orange(msg) C:OnScreen('Orange',msg,2) end
function lib:Onscreen_Purple(msg) C:OnScreen('Purple',msg,8) end
function lib:Onscreen_Yellow(msg) C:OnScreen('Yellow',msg,1) end
function lib:Onscreen_Azure(msg) C:OnScreen('Azure',msg,1) end
function lib:Onscreen_Red(msg) C:OnScreen('Red',msg,1) end
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
---
-- Returns a crayon like object
-- @usage
-- local C=LibStub("LibInit"):GetColorTable()
-- C.Azure.c --returns a string "rrggbb"
-- C.Azure.r --returns red value as a number
-- C.Azure.g --returns green value as a number
-- C.Azure.b --returns blue value as a number
-- tostring(C.Azure) -- returns a string "rrggbb"
-- "aa" .. C.Azure -- returns "aarrggbb"
-- C.Azure() -- returns r,g,b as float list
-- C.Azure.r -- returns r as float
-- C("testo","azure") -- returns "|cff" .. >color code for azure> .. "test" .. "|r"
-- -- For a list of available color check Colors
-- -- Each color became the name of a meth

function lib:GetColorTable()
	return C
end

--- Returns a factory for lightweight widgets
-- @see factory
function lib:GetFactory()
	return F
end
-- In case of upgrade, we need to redo embed for ALL Addons
-- This function get called on addon creation
-- Anything I define here is immediately available to newAddon method and in addon right after creation
function lib:Embed(target)
	-- All methods are pulled in via metatable in order to not pollute addon table
	local mt=getmetatable(target)
	if not mt then mt={__tostring=function(me) return me.name end} end
	mt.__index=lib.mixins
	setmetatable(target,mt)
	target._Apply=target._Apply or {}
	target._Apply._handler=target
	for k,v in pairs(self) do
		if type(v)=="string" or type(v)=="number" then pp (self,k,v) end
	end
	setmetatable(target._Apply,varmeta)
	lib.mixinTargets[target] = true
	if type(lib.options[target])=="table" then -- Updating library version if needed
		lib.options[target].libinit=MAJOR_VERSION .. ' ' .. MINOR_VERSION
	end
end
local function fsort(a,b)
	if type(a)=="number" then
		a=format("%07d",a)
	end
	if type(b)=="number" then
		b=format("%07d",b)
	end
	return b>a
end
local function kpairs(t,f)
	local a = new()
	f=f or fsort
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
function lib:Kpairs(t,f)
	return kpairs(t,f)
end
--- Returns kpairs implementation
-- Deprecated in favour of Wrap("Kpairs")
--
function lib:GetKpairs()
	return kpairs
end
lib.getKpairs=lib.GetKpairs

--- Implements PHP empty function.
-- @tparam any obj variable to be tested
-- @treturn boolean
function lib:Empty(obj)
	if not obj then return true end -- Simplest case, obj evaluates to false in boolean context
	local t=type(obj)
	if t=="number" then
		return obj==0
	elseif t=="bool" then
		return t
	elseif t=="string" then
		return obj=='' or obj==tostring(nil) or obj=="0"
	elseif t=="table" then
		return not next(obj)
	end
	return false -- Userdata and threads can never be empty
end
-- This metatable is used to generate a sorted proxy to an hashed table.
-- It should not used directly
lib.mt={__metatable=true,__version=MINOR_VERSION}
local mt=lib.mt
function mt:__index(k)
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

function lib:ScheduleLeaveCombatAction(method, ...)
	return self:OnLeaveCombat(method,...)
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
--- Show a popup
-- Display a popup message with Accept and optionally Cancel button
-- @tparam string msg Message to be shown
-- @tparam[opt=60] number timeout In seconds, if omitted assumes 60
-- @tparam[opt] func OnAccept Executed when clicked on Accept
-- @tparam[opt] func OnCancel Executed when clicked on Cancel (if nill, Cancel button is not shown)
-- @tparam[opt] mixed data Passed to the callback function
-- @tparam[opt] bool StopCasting If true, when the popup appear will stop any running casting.
-- Useful to ask confirmation before performing a programmatic initiated spellcasting
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
	popup.timeout=timeout
	popup.text=msg
	popup.OnCancel=nil
	popup.OnAccept=OnAccept
	popup.button1=ACCEPT
	popup.button2=nil
	if (OnCancel) then
		if (type(OnCancel)=="function") then
			popup.OnCancel=OnCancel
		end
		popup.button2=CANCEL
	else
		popup.button1=OKAY
	end
	return StaticPopup_Show("LIBINIT_POPUP",timeout,SECONDS,data);
end
--- Coroutines.
-- Methods to manage coroutines
-- @section coroutine
lib.coroutines=lib.coroutines or setmetatable({},{__index=function(t,k) rawset(t,k,{}) return t[k] end})
if not lib.CoroutineScheduler then
	lib.CoroutineScheduler = CallbackHandler:New(lib,"_OnCoroutineEnd","_CancelOnCoroutine")
end
---
local coroutines=lib.coroutines --#Coroutines

--- Executes an action as soon as a coroutine exit
-- Action can be executed immediately if coroutine is already dead
-- @tparam string signature Coroutine indentifier as returined by coroutineExecute
-- @tparam string|function action To be executed, Can be a function or a method name
-- @tparam[opt] mixed ... More parameters will be directly passed to action
--
function lib:coroutineOnEnd(signature,action,...)
	if type(action)~="string" and type(action)~="function" then
		error("Usage: OnCoroutineEnd (\"action\", ...): 'action' - string or function expected.", 2)
	end
	if type(action)=="string" and type(self[action]) ~= "function" then
		error("Usage: OnCoroutineEnd (\"action\", ...): 'action' - method '"..tostring(action).."' not found on self.", 2)
	end
	if type(action) =="string" then
		dprint("onend",self,signature,action,...)
		lib._OnCoroutineEnd(self,signature,Run,{self[action],self,...})
	else
		lib._OnCoroutineEnd(self,signature,Run,{action,...})
	end
end


--- Generates and executes a coroutine with configurable interval and combat status
-- If called for already running coroutine changes the interval and the combat status
-- @tparam number interval between steps
-- @tparam string|function action To be executed, Can be a function or a method name
-- @tparam[opt] bool combatSafe keep running in combat
-- @tparam[opt] mixed more parameter are passed to function
-- @treturn string coroutine handle
function lib:coroutineExecute(interval,action,combatSafe,...)
	local signature=strjoin(':',tostringall(self,action,...))
	if type(action)=="string" then
		action=self[action]
	end
	assert(type(action) =="function","coroutineExecute arg1 was not convertible to a function " .. tostring(action))
	local c=lib.coroutines[signature]
	c.signature=signature
	c.interval=interval
	c.combatSafe=combatSafe
	if c.running then
		return signature
	end
	if type(c.co)=="thread" and coroutine.status(c.co)=="suspended" then return signature end
	c.co=coroutine.create(action)
	c.running=true
	c.paused=false
	do
		local args={...}
		local obj=self
		local c=c
		c.repeater=function()
			if not c.combatSafe and InCombatLockdown() then
				c.waiting=true
				return
			end
			if c.paused then return end
			local rc,res=pcall(coroutine.resume,c.co,obj,unpack(args))
			if rc and res then
				C_Timer.After(c.interval,c.repeater)
			else
				if not rc then error(res,2) end
				lib.coroutines[signature]=nil
				lib.CoroutineScheduler:Fire(c.signature)
			end
		end
	end
	c.repeater()
	return signature
end
lib.coroutineStart=lib.coroutineExecute -- alias
function lib:coroutineGet(signature)
	return coroutines[signature]
end
function lib:coroutinePause(signature)
	local co=coroutines[signature]
	if co then
		co.paused=true
	end
end
function lib:coroutineRestart(signature)
	local c=coroutines[signature]
	if c then
		if c.paused then
			c.paused=false
			local rc,res=pcall(c.repeater)
			if not rc then error(res,2) end
		end
	end
end
function lib:coroutineGetList()
  return coroutines
end

local C_Timer=C_Timer
local NDTProto={}
local NDTMeta={
		__index=NDTProto,
		__metatable=true,
}
function NDTProto:UpdateTimes(seconds)
	seconds=seconds or self.delay
	self.delay=seconds
	self.expire=GetTime()+seconds-0.05
end
function NDTProto:Start(seconds)
	self:UpdateTimes(seconds)
	return self:Callback()
end
function NDTProto:Callback(reset)
	if reset then self.running=false end
	if self.expire <=GetTime() then
		self.callback()
		self=nil
	else
		if not self.running then
			self:UpdateTimes()
			C_Timer.After(self.delay,function() return self:Callback(true) end)
			self.running=true
		end

	end
end
function NDTProto:New(callback)
	local timer=setmetatable({},NDTMeta)
	timer.expire=GetTime()
	timer.delay=0.001
	timer.callback=callback
	return timer
end

--- Delayable timers
-- Create a timer that can be delayed. Useful for example for throttling sliders' events
-- This function just create the timer, to start (or delay) it use the :Start(seconds) method
-- @tparam function callback Function to be called at expire time
-- @treturn object
--
function lib:NewDelayableTimer(callback)
	return NDTProto:New(callback)
end


--- Automatic events.
--  You can have automatic events creating methods with the name EvtEVENTNAME
--  For example in order to manage the event ADDON\_LOADED you can just define
--  a EvtADDON\_LOADED method
--  @section event
--  @usage
--  function addon:EvtADDON_LOADED(event,addonname)
--  end
--  function addon:OnEnabled()
--  self:StartAutomaticEvents()
--  end
--  function addon:OnDisabled()
--  self:StopAutomaticEvents()
--  end

---
-- Starts all automatic events.
-- Automatic events are the one for which exists and EvtEVENTNAME method
--
function lib:StartAutomaticEvents()
	for k,v in pairs(self) do
		if (type(v)=='function') then
			if (k:sub(1,3)=='Evt') then
				_G.print(self,"Registering",k)
				self:Print("Registering",k)
				self:RegisterEvent(k:sub(4),k)
			end
		end
	end
end

---
-- Stops all automatic events.
-- Automatic events are the one for which exists and EvtEVENTNAME method
-- @tparam[opt] string ignore Name of an event method not to be stopped
-- @usage
-- self:StopAutomaticEvents("ADDON_LOADED")
-- -- Will stop all events but ADDON_LOADED
--
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

for name,method in pairs(lib) do
	if type(method)=="function" and name~="NewAddon" and name~="GetAddon" and name:sub(1,1)~="_" then
		lib.mixins[name] = method
	end
end
for target,_ in pairs(lib.mixinTargets) do
	lib:Embed(target)
end

