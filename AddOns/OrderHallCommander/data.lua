local __FILE__=tostring(debugstack(1,2,0):match("(.*):1:")) -- Always check line number in regexp and file, must be 1
local function pp(...) print(GetTime(),"|cff009900",__FILE__:sub(-15),strjoin(",",tostringall(...)),"|r") end
--*TYPE module
--*CONFIG profile=true,enhancedProfile=true
-- Generated on 20/01/2017 08:15:04
local me,ns=...
local addon=ns --#Addon (to keep eclipse happy)
ns=nil
local module=addon:NewSubModule('Data')  --#Module
function addon:GetDataModule() return module end
-- Template
local G=C_Garrison
local _
local AceGUI=LibStub("AceGUI-3.0")
local C=addon:GetColorTable()
local L=addon:GetLocale()
local new=addon.NewTable
local del=addon.DelTable
local kpairs=addon:GetKpairs()
local empty=addon:GetEmpty()
local OHF=OrderHallMissionFrame
local OHFMissionTab=OrderHallMissionFrame.MissionTab --Container for mission list and single mission
local OHFMissions=OrderHallMissionFrame.MissionTab.MissionList -- same as OrderHallMissionFrameMissions Call Update on this to refresh Mission Listing
local OHFFollowerTab=OrderHallMissionFrame.FollowerTab -- Contains model view
local OHFFollowerList=OrderHallMissionFrame.FollowerList -- Contains follower list (visible in both follower and mission mode)
local OHFFollowers=OrderHallMissionFrameFollowers -- Contains scroll list
local OHFMissionPage=OrderHallMissionFrame.MissionTab.MissionPage -- Contains mission description and party setup 
local OHFMapTab=OrderHallMissionFrame.MapTab -- Contains quest map
local followerType=LE_FOLLOWER_TYPE_GARRISON_7_0
local garrisonType=LE_GARRISON_TYPE_7_0
local FAKE_FOLLOWERID="0x0000000000000000"
local MAXLEVEL=110

local ShowTT=OrderHallCommanderMixin.ShowTT
local HideTT=OrderHallCommanderMixin.HideTT

local dprint=print
local ddump
--[===[@debug@
LoadAddOn("Blizzard_DebugTools")
ddump=DevTools_Dump
LoadAddOn("LibDebug")

if LibDebug then LibDebug() dprint=print end
local safeG=addon.safeG

--@end-debug@]===]
--@non-debug@
dprint=function() end
ddump=function() end
local print=function() end
--@end-non-debug@

-- End Template - DO NOT MODIFY ANYTHING BEFORE THIS LINE
--*BEGIN
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
	ArtifactPower={130152,131751,131753,131763,131795,131802,131808,132897,132950,136356,136655,136656,136657,136658,136659,136660,136661,136662,136663,136664,138480,138487,138732,138781,138782,138783,138785,138786,138812,138813,138814,138816,138839,138864,138865,138880,138881,138885,138886,139390,139506,139507,139508,139509,139510,139511,139512,139591,139608,139609,139610,139611,139612,139613,139614,139615,139616,139617,140176,140237,140238,140241,140244,140247,140250,140251,140252,140254,140255,140304,140305,140306,140307,140310,140322,140349,140357,140358,140359,140361,140364,140365,140366,140367,140368,140369,140370,140371,140372,140373,140374,140377,140379,140380,140381,140382,140383,140384,140385,140386,140387,140388,140389,140391,140392,140393,140396,140409,140410,140421,140422,140444,140445,140459,140460,140461,140462,140463,140466,140467,140468,140469,140470,140471,140473,140474,140475,140476,140477,140478,140479,140480,140481,140482,140484,140485,140486,140487,140488,140489,140490,140491,140492,140494,140497,140498,140503,140504,140505,140507,140508,140509,140510,140511,140512,140513,140515,140516,140517,140518,140519,140520,140521,140522,140523,140524,140525,140528,140529,140530,140531,140532,140685,140847,141023,141024,141310,141313,141314,141335,141383,141384,141385,141386,141387,141388,141389,141390,141391,141392,141393,141394,141395,141396,141397,141398,141399,141400,141401,141402,141403,141404,141405,141638,141639,141667,141668,141669,141670,141671,141672,141673,141674,141675,141676,141677,141678,141679,141680,141681,141682,141683,141684,141685,141689,141690,141699,141701,141702,141703,141704,141705,141706,141707,141708,141709,141710,141711,141852,141853,141854,141855,141856,141857,141858,141859,141863,141872,141876,141877,141883,141886,141887,141888,141889,141890,141891,141892,141896,141921,141922,141923,141924,141925,141926,141927,141928,141929,141930,141931,141932,141933,141934,141935,141936,141937,141940,141941,141942,141943,141944,141945,141946,141947,141948,141949,141950,141951,141952,141953,141954,141955,141956,142001,142002,142003,142004,142005,142006,142007,142054,142449,142450,142451,142454,142455,142533,142534,142535,142555,143333,143486,143487,143488,143498,143499,143533,143536,143538,143540,143677,143680,143713,143714,143715,143716,143738,143739,143740,143741,143742,143743,143744,143745,143746,143747,143749,143757,143844,143868,143869,143870,143871}
}
function addon:GetData(key)
	key=key or "none"
	return data[key] or fake
end
function module:OnInitialized()
	--
	addon.coroutineExecute(module,0,"TickleServer")
end
function module:AddItem(itemID)

end
function module:TickleServer()
	addon:Print("Precaching items")
	local i=0
	for _,categories in pairs(data) do
		for _,itemid in pairs(categories) do
			if type(itemid)=="number" then
				pcall(GetItemInfo,itemid)
				i=i+1
				coroutine.yield()
			end
		end
	end
	addon:Print("Precached ",i," items")
end
