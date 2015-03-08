local me, ns = ...
local _G=_G
local pp=print
local setmetatable=setmetatable
local next=next
local pairs=pairs
local wipe=wipe
local GetChatFrame=GetChatFrame
local format=format
local GetTime=GetTime
local strjoin=strjoin
local tostringall=tostringall
--[===[@debug@
LoadAddOn("Blizzard_DebugTools")
--@end-debug@]===]
ns.addon=LibStub("LibInit"):NewAddon(me,'AceHook-3.0','AceTimer-3.0','AceEvent-3.0','AceBucket-3.0')
local chatframe=ns.addon:GetChatFrame("aDebug")
local function pd(...)
	--if (chatframe) then chatframe:AddMessage(format("GC:%6.3f %s",GetTime(),strjoin(' ',tostringall(...)))) end
	pp(format("|cff808080GC:%6.3f|r %s",GetTime(),strjoin(' ',tostringall(...))))
end
local addon=ns.addon --#addon
ns.toc=select(4,GetBuildInfo())
ns.AceGUI=LibStub("AceGUI-3.0")
ns.D=LibStub("LibDeformat-3.0")
ns.C=ns.addon:GetColorTable()
ns.L=ns.addon:GetLocale()
ns.print=ns.addon:Wrap("Print")
ns.dprint=ns.print
ns.trace=ns.addon:Wrap("Trace")
ns.xprint=function() end
ns.xdump=function() end
ns.xtrace=function() end
--[===[@debug@
--ns.xprint=function(...) pd("|cffff9900DBG|r",...) end
--ns.xdump=function(d,t) pp("|cffff9900DMP|r",t) DevTools_Dump(d) end
--ns.xtrace=ns.trace
--@end-debug@]===]
do
	--[===[@debug@
	local newcount, delcount,createdcount,cached = 0,0,0
	--@end-debug@]===]
	local pool = setmetatable({},{__mode="k"})
	function ns.new()
	--[===[@debug@
		newcount = newcount + 1
	--@end-debug@]===]
		local t = next(pool)
		if t then
			pool[t] = nil
			return t
		else
	--[===[@debug@
			createdcount = createdcount + 1
	--@end-debug@]===]
			return {}
		end
	end
	function ns.copy(t)
		local c = ns.new()
		for k, v in pairs(t) do
			c[k] = v
		end
		return c
	end
	function ns.del(t)
	--[===[@debug@
		delcount = delcount + 1
	--@end-debug@]===]
		wipe(t)
		pool[t] = true
	end
	--[===[@debug@
	function cached()
		local n = 0
		for k in pairs(pool) do
			n = n + 1
		end
		return n
	end
	function ns.addon:CacheStats()
		ns.print("Created:",createdcount)
		ns.print("Aquired:",newcount)
		ns.print("Released:",delcount)
		ns.print("Cached:",cached())
	end
	--@end-debug@]===]
end

local stacklevel=0
local frames
function addon:holdEvents()
	if stacklevel==0 then
		frames={GetFramesRegisteredForEvent('GARRISON_FOLLOWER_LIST_UPDATE')}
		for i=1,#frames do
			frames[i]:UnregisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
	end
	stacklevel=stacklevel+1
end
function addon:releaseEvents()
	stacklevel=stacklevel-1
	assert(stacklevel>=0)
	if (stacklevel==0) then
		for i=1,#frames do
			frames[i]:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
		frames=nil
	end
end
local holdEvents,releaseEvents=addon.holdEvents,addon.releaseEvents
ns.OnLeave=function() GameTooltip:Hide() end

-------------------- to be estracted to CountersCache
--
--local G=C_Garrison
--ns.Abilities=setmetatable({},{
--	__index=function(t,k) rawset(t,k,G.GetFollowerAbilityName(k)) return rawget(t,k) end
--})
--
--

--@non-debug@
if true then return end
--@end-non-debug@

