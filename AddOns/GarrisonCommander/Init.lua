local me, ns = ...
local LibInit,minor=LibStub("LibInit",true)
assert(LibInit,me .. ": Missing LibInit, please reinstall")
local minvers=39
assert(minor>=minvers,me ..': Need at least Libinit version ' .. minvers)
local _G=_G
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
local tostring=tostring
local tonumber=tonumber
local type=type
--[===[@debug@
LoadAddOn("Blizzard_DebugTools")
LoadAddOn("LibDebug")
if LibDebug then LibDebug() ns.print=print else ns.print=function() end end
--@end-debug@]===]
--@non-debug@
ns.print=function() end
--@end-non-debug@
ns.addon=LibInit:NewAddon(me,{profile='Default',enhancedProfile=true},'AceHook-3.0','AceTimer-3.0','AceEvent-3.0','AceBucket-3.0','AceSerializer-3.0')
local addon=ns.addon --#addon
ns.toc=select(4,GetBuildInfo())
ns.AceGUI=LibStub("AceGUI-3.0")
ns.D=LibStub("LibDeformat-3.0")
ns.C=addon:GetColorTable()
ns.L=addon:GetLocale()
ns.G=C_Garrison
ns.GMF=_G.GarrisonMissionFrame
ns.blacklist=false
ns.prioritylist=false
ns.KEY_BUTTON1 = "\124TInterface\\TutorialFrame\\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:228:283\124t" -- left mouse button
ns.KEY_BUTTON2 = "\124TInterface\\TutorialFrame\\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:330:385\124t" -- right mouse button
if not ns.GMF then
--[===[@debug@
	print("GarrisonCommander is being loaded before Blizzard_GarrisonUI is available")
	print(GetTime())
--@end-debug@]===]
	LoadAddOn("Blizzard_GarrisonUI")
--[===[@debug@
	print(GetTime())
--@end-debug@]===]
	ns.GMF=_G.GarrisonMissionFrame
end
if not ns.GMF then error("GarrisonCommander is being loaded before Blizzard_GarrisonUI is available") end
ns.GSF=_G.GarrisonShipyardFrame
ns.GMFMissions=ns.GMF.MissionTab.MissionList
ns.GSFMissions=ns.GSF.MissionTab.MissionList
_G.GARRISON_FOLLOWER_MAX_ITEM_LEVEL = _G.GARRISON_FOLLOWER_MAX_ITEM_LEVEL or 675
ns.quests={}
GetQuestsCompleted(ns.quests)
function addon:EventQUEST_TURNED_IN(event,quest,item,gold)
	ns.quests[quest]=true
end
ns.new=addon:Wrap("NewTable")
ns.del=addon:Wrap("DelTable")
--[===[@debug@
local t =ns.new()
if type(t)~="table" then
	error("new is broken")
	return
else
	ns.del(t)
end
--@end-debug@]===]
-- Caching iteminfo
ns.I=LibStub("LibItemUpgradeInfo-1.0")
ns.GetItemInfo=ns.I:GetCachingGetItemInfo()
function ns.GarrisonMissionFrame_SetItemRewardDetails(frame)
	if not frame.itemID then return end
	local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = ns.GetItemInfo(frame.itemID);
	if itemName then
		frame.Icon:SetTexture(itemTexture);
		if (frame.Name and itemName and itemRarity) then
			frame.Name:SetText(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
		end
	else
		addon:ScheduleTimer(ns.GarrisonMissionFrame_SetItemRewardDetails,0.2,frame)
	end
end

local backdrop = {
		--bgFile="Interface\\TutorialFrame\\TutorialFrameBackground",
		bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
		tile=true,
		tileSize=16,
		edgeSize=16,
		insets={bottom=3,left=3,right=3,top=3}
}
---@function [parent=#ns] AddBackdrop
--@param object frame Frame to add backdrop to
--@param int r,g,b optional color
function ns.AddBackdrop(frame,r,g,b)
	r=r or 1
	g=g or 0
	b=b or 0
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(1,1,1,0)
	frame:SetBackdropBorderColor(r,g,b,1)
end
-- my implementation of tonumber which accounts for nan and inf
---@function [parent=#ns] tonumber

function ns.tonumber(value,default)
	if value~=value then return default
	elseif value==math.huge then return default
	else return tonumber(value) or default
	end
end
-- my implementation of type which accounts for nan and inf
---@function [parent=#ns] type
function ns.type(value)
	if value~=value then return nil
	elseif value==math.huge then return nil
	else return type(value)
	end
end
ns.orig={}
ns.over={}
local orig=ns.orig
local over=ns.over
-- Blizzard functions override
---@function [parent=#ns] Override
function ns.override(blizfunc,secure)
	local overrider=blizfunc
	assert(type(over[overrider])=="function",overrider)
	if (orig[blizfunc]) then return end -- already hooked
	orig[blizfunc]=_G[blizfunc]
	if (secure) then
		hooksecurefunc(blizfunc,over[overrider])
	else
		_G[blizfunc]=over[overrider]
	end
end

local stacklevel=0
local frames
function ns.holdEvents()
	if stacklevel==0 then
		frames={GetFramesRegisteredForEvent('GARRISON_FOLLOWER_LIST_UPDATE')}
		for i=1,#frames do
			frames[i]:UnregisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
	end
	stacklevel=stacklevel+1
end
function ns.releaseEvents()
	stacklevel=stacklevel-1
	assert(stacklevel>=0)
	if (stacklevel==0) then
		for i=1,#frames do
			frames[i]:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
		frames=nil
	end
end
ns.OnLeave=function() GameTooltip:Hide() end
local upgrades={
	"wt:120302:1",
	"we:114128:3",
	"we:114129:6",
	"we:114131:9",
	"wf:114616:615",
	"wf:114081:630",
	"wf:114622:645",
	"wf:128307:645",
	"at:120301:1",
	"ae:114745:3",
	"ae:114808:6",
	"ae:114822:9",
	"af:114807:615",
	"af:114806:630",
	"af:114746:645",
	"af:128308:645",
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
local itemcaches={
[118529]=655,--Cache of Highmaul Treasures,
[118530]=670,--Cache of Highmaul Treasures,
[118531]=685,--Cache of Highmaul Treasures,
[122484]=670, --Blackrock Foundry Spoils,
[122485]=685, --Blackrock Foundry Spoils,
[122486]=700, --Blackrock Foundry Spoils,
[127853]=690,--Iron Fleet Treasure Chest
[127854]=705,--Iron Fleet Treasure Chest
[127855]=720,--Iron Fleet Treasure Chest
[128391]=685,--Iron Fleet Treasure Chest
[120301]=600, -- Folower Generic armor upgrade
[120302]=600, -- Folower Generic weapon upgrade

}
function addon:GetTrueLevel(itemid,itemlevel)
	return itemcaches[itemid] or itemlevel
end
for i=1,#upgrades do
	local _,id,level=strsplit(':',upgrades[i])
	followerItems[tonumber(id)]=level
end
function addon:IsFollowerUpgrade(id)
	return followerItems[id]
end
function addon:GetUpgrades()
	return upgrades
end
function addon:GetItems()
	return items
end
local function tickleItems()
	for itemID,_ in pairs(followerItems) do
		GetItemInfo(itemID)
		coroutine.yield(true)
	end
	for i,v in pairs(items) do
		GetItemInfo(i)
		coroutine.yield(true)
	end
end
addon:coroutineExecute(0.1,tickleItems)
function addon:GetType(itemID)
	if (items[itemID]) then return "equip" end
	if (followerItems[itemID]) then return "followerEquip" end
	return "generic"
end
-- Thanks to wowheade

ns.traitTable={
[1]={
	[45]="Cave Dweller",
	[8]="Cold-Blooded",
	[46]="Guerilla Fighter",
	[48]="Marshwalker",
	[7]="Mountaineer",
	[44]="Naturalist",
	[49]="Plainsrunner",
	[9]="Wastelander",
},
[2]={
	[326] = "Apexis Attenuation",
	[80]  ="Extra Training",
	[29]  ="Fast Learner",
	[314] ="Greasemonkey",
	[236] = "Heartstone Pro",
	[248] = "Mentor",
	[79]  ="Scavenger",
	[256] ="Treasure Hunter",
},
[3]={
	[77]="Burst of Power",
	[221]="Epic Mount",
	[76]="High Stamina",
	[250]="Speed of Light",
},
[4]={
	[201]="Combat Experience",
	[303]="Demonic Knowledge",
	[47]="Master Assassin",
},
[5]={
	[244]="Brute",
	[78]="Lone Wolf",
},
[6]={
	[54]="Alchemy",
	[227]="Angler",
	[55]="Blacksmithing",
	[231]="Bodyguard",
	[56]="Enchanting",
	[57]="Engineering",
	[62]="Evergreen",
	[53]="Herbalism",
	[52]="Mining",
	[58]="Inscription",
	[59]="Jewelcrafting",
	[60]="Leatherworking",
	[62]="Skinning",
	[61]="Tailoring",
},
[7]={
	[67] = "Ally of Argus",
	[254]= "Bird Watcher",
	[69] = "Brew Aficionado",
	[68] = "Canine Companion",
	[70] = "Child of Draenor",
	[66] = "Child of the Moon",
	[71] = "Death Fascination",
	[65] = "Dwarvenborn",
	[75] = "Economist",
	[74] = "Elvenkind",
	[63] = "Gnome-Lover",
	[64] = "Humanist",
	[253]= "Mechano Affictionado",
	[252]= "Ogre Buddy",
	[72] = "Totemist",
	[73] = "Voodoo Zealot",
	[255]= "Wildling",
},
[8]={
	[37]="Beastslayer",
	[36]="Demonslayer",
	[325]="Exorcist",
	[41]="Furyslayer",
	[40]="Gronnslayer",
	[38]="Ogreslayer",
	[4]="Orcslayer",
	[39]="Primalslayer",
	[43]="Talonslayer",
	[42]="Voidslayer",
},
[9]={
	[232]="Dancer"
}
}

-- Pseudo Global Support.
-- Calling ns.Configure() will give to the calling function a preloaded env

local ENV={}

for k,v in pairs(ns) do
	ENV[k]=v
end
setmetatable(ENV,
{__index=_G,
__newindex=function(t,k,v)
	assert(type(_G[k]) == 'nil',"Attempting to override global " ..k)
	return rawset(t,k,v)
end
}
)

---@function [parent=#ns] Configure
function ns.Configure()
		local old_env = getfenv(2)
		if old_env ~= _G and old_env ~= ENV then
			error("The calling function has a modified environment, I won't replace it.", 2)
		end
		setfenv(2, ENV)
end
function addon:EventADDON_LOADED(event,AddOn)
	if AddOn~="Blizzard_OrderHallUI" then return end
	self:UnregisterEvent("ADDON_LOADED")
	ns.GHF=_G.OrderHallMissionFrame
	ns.GHFMissions=ns.GHF.MissionTab.MissionList
	ENV.GHF=ns.GHF
	ENV.GHFMissions=ns.GHFMissions
	self:GetModule("OrderHall"):OnInitialize()
end
-- Order Hall data
local fake={}
local data={
	Upgrades={
		136412,
		137207,
		137208,
		
	},
	Xp={
		141028
	},
	Equipment={
		'Success Chance Increase',
		139816,
		139801,
		139802,
		140572,
		140571,
		140573,
		140581,
		140582,
		140583,
		'Mission Time Reduction',
		139813,
		139814,
		139799,
		'Combat Ally Bonus',
		139792,
		139808,
		139809,
		139795,
		139811,
		139812,
		'Troop Affinity',
		139875,
		139876,
		139877,
		139878,
		139835,
		139836,
		139837,
		139838,
		139863,
		139864,
		139865,
		139866,
		139847,
		139848,
		139849,
		139850,
		139843,
		139844,
		139845,
		139846,
		139859,
		139860,
		139861,
		139862,
		139867,
		139868,
		139869,
		139870,
		139871,
		139872,
		139873,
		139874,
		139831,
		139832,
		139833,
		139834,
		139839,
		139840,
		139841,
		139842,
		139855,
		139856,
		139857,
		139858,
		139851,
		139852,
		139853,
		139854,
		'Legendary Equipment',
		139830,
		139828,
		139829,
		139827,
		139825,
		139826,
		139821,
		139804,
		139819,
		139824,
		139823,
		139822,
		'Consumables',
		140749,
		139419,
		140760,
		139428,
		139177,
		139420,
		138883,
		139376,
		138418,
		138412,
		139670
	},
}
function addon:GetData(key)
	key=key or "none"
	return data[key] or fake
end


