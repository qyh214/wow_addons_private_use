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
local strspilit=strsplit
local tostringall=tostringall
--[===[@debug@
LoadAddOn("Blizzard_DebugTools")
if LibDebug then LibDebug() end
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
ns.G=C_Garrison
ns.print=ns.addon:Wrap("Print")
ns.dprint=ns.print
ns.trace=ns.addon:Wrap("Trace")
ns.xprint=function() end
ns.xdump=function() end
ns.xtrace=function() end
_G.GARRISON_FOLLOWER_MAX_ITEM_LEVEL = _G.GARRISON_FOLLOWER_MAX_ITEM_LEVEL or 675
--[===[@debug@
	ns.xprint=print
	ns.xdump=function(d,t) pp("|cffff9900DMP|r",t) DevTools_Dump(d) end
	ns.xtrace=print
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
local upgrades={
	"wt:120302:1",
	"we:114128:3",
	"we:114129:6",
	"we:114131:9",
	"wf:114616:615",
	"wf:114081:630",
	"wf:114622:645",
	"at:120301:1",
	"ae:114745:3",
	"ae:114808:6",
	"ae:114822:9",
	"af:114807:615",
	"af:114806:630",
	"af:114746:645",
}
local followerItems={}
local items={
[114053]={icon='inv_glove_plate_dungeonplate_c_06',quality=2},
[114052]={icon='inv_jewelry_ring_146',quality=3},
[114109]={icon='inv_sword_46',quality=3},
[114068]={icon='inv_misc_pvp_trinket',quality=3},
[114058]={icon='inv_chest_cloth_reputation_c_01',quality=3},
[114063]={icon='inv_shoulder_cloth_reputation_c_01',quality=3},
[114059]={icon='inv_boots_cloth_reputation_c_01',quality=3},
[114066]={icon='inv_jewelry_necklace_70',quality=3},
[114057]={icon='inv_bracer_cloth_reputation_c_01',quality=3},
[114101]={icon='inv_belt_cloth_reputation_c_01',quality=3},
[114098]={icon='inv_helmet_cloth_reputation_c_01',quality=3},
[114096]={icon='inv_boots_cloth_reputation_c_01',quality=3},
[114108]={icon='inv_sword_46',quality=3},
[114094]={icon='inv_bracer_cloth_reputation_c_01',quality=3},
[114099]={icon='inv_pants_cloth_reputation_c_01',quality=3},
[114097]={icon='inv_gauntlets_cloth_reputation_c_01',quality=3},
[114105]={icon='inv_misc_pvp_trinket',quality=3},
[114100]={icon='inv_shoulder_cloth_reputation_c_01',quality=3},
[114110]={icon='inv_sword_46',quality=3},
[114080]={icon='inv_misc_pvp_trinket',quality=3},
[114070]={icon='inv_chest_cloth_reputation_c_01',quality=3},
[114075]={icon='inv_shoulder_cloth_reputation_c_01',quality=3},
[114071]={icon='inv_boots_cloth_reputation_c_01',quality=3},
[114078]={icon='inv_jewelry_necklace_70',quality=3},
[114069]={icon='inv_bracer_cloth_reputation_c_01',quality=3},
[114112]={icon='inv_sword_46',quality=4},
[114087]={icon='inv_misc_pvp_trinket',quality=4},
[114083]={icon='inv_chest_cloth_reputation_c_01',quality=4},
[114085]={icon='inv_shoulder_cloth_reputation_c_01',quality=4},
[114084]={icon='inv_boots_cloth_reputation_c_01',quality=4},
[114086]={icon='inv_jewelry_necklace_70',quality=4},
[114082]={icon='inv_bracer_cloth_reputation_c_01',quality=4},
}
for i=1,#upgrades do
	local _,id,level=strsplit(':',upgrades[i])
	followerItems[id]=level
end
function addon:GetUpgrades()
	return upgrades
end
function addon:GetItems()
	return items
end
-- to be moved in LibInit
--[[
function addon:coroutineExecute(interval,func)
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
--]]
addon:coroutineExecute(0.1,
	function ()
		for itemID,_ in pairs(followerItems) do
			GetItemInfo(itemID)
			coroutine.yield(true)
		end
		for i,v in pairs(items) do
			GetItemInfo(i)
			coroutine.yield(true)
		end
	end
)
function addon:GetType(itemID)
	if (items[itemID]) then return "equip" end
	if (followerItems[itemID]) then return "followerEquip" end
	return "generic"
end


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

