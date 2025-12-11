
-- local T, C, L, G = unpack(select(2, ...))

local addon, ns = ...
ns[1] = {} -- T, functions, constants, variables
ns[2] = {} -- C, config
ns[3] = {} -- L, localization
ns[4] = {} -- G, globals (Optionnal)

JST = ns

local T, C, L, G = unpack(select(2, ...))

--====================================================--
--[[                 -- Globals --                  ]]--
--====================================================--
G.addon_name = addon
G.addon_cname = select(2, C_AddOns.GetAddOnInfo(addon))
G.Client = GetLocale()
G.Version = C_AddOns.GetAddOnMetadata(addon, "Version")

G.PlayerName = UnitName("player")
G.PlayerGUID = UnitGUID("player")
G.myClassLocal, G.myClass = UnitClass("player")

G.link = "https://legacy.curseforge.com/wow/addons/jingsi-tools"
G.Contacts = "Bilibili 开船船的纪老师 QQ群 493691777"
--====================================================--
--[[                  -- Media --                   ]]--
--====================================================--
if G.Client == "ruRU" then
	G.Font = "Interface\\AddOns\\JST\\media\\narrowfont.ttf"
else
	G.Font = "Interface\\AddOns\\JST\\media\\font.ttf"
end

G.media = {
	arrow = "Interface\\AddOns\\JST\\media\\arrow",
	blank = "Interface\\Buttons\\WHITE8x8",
	circle = "Interface\\AddOns\\JST\\media\\circle",
	logo = "Interface\\AddOns\\JST\\media\\logo.png",
	overlay1 = "Interface\\AddOns\\JST\\media\\overlay_indicator_1",
	overlay2 = "Interface\\AddOns\\JST\\media\\overlay_indicator_2",
	overlay3 = "Interface\\AddOns\\JST\\media\\overlay_indicator_3",
	ring = "Interface\\AddOns\\JST\\media\\ring",
	triangle = "Interface\\AddOns\\JST\\media\\triangle",
}

--====================================================--
--[[                  -- Color --                   ]]--
--====================================================--
G.Ccolors = {}
if C_AddOns.IsAddOnLoaded('!ClassColors') and CUSTOM_CLASS_COLORS then
	G.Ccolors = CUSTOM_CLASS_COLORS
else
	G.Ccolors = RAID_CLASS_COLORS
end

G.addon_color = {1, 0, 0}
G.addon_colorStr = "|cffFF0000"

-- 彩色边框
G.hl_colors = {
	["red"] = {1, 0, 0},
	["gre"] = {.23, .96, .23},
	["blu"] = {.32, .65, .93},
	["pur"] = {.77, .45, 1},
	["org"] = {1, .5, 0},
	["yel"] = {1, .89, .12},
}

G.IconColor = {}
--====================================================--
--[[                  -- Init --                    ]]--
--====================================================--
G.SoundPacks = {}
G.ttsSpeakers = {}
G.Encounters = {}
G.Encounter_Order = {}
G.ChallengeMap_Order = {}
G.Encounter_Data = {}
G.Current_Data = {}
G.Timeline_Data = {}
G.MobData = {}

local RegisterAddonMessageResults = {
	--[0] = "成功 Success",
	[1] = "注册插件讯息失败，注册前缀重复 Duplicate Prefix",
	[2] = "注册插件讯息失败，注册前缀无效 Invalid Prefix",	
	[3] = "注册插件讯息失败，注册前缀数量达到上限 Max Prefixes",	
}

if not C_ChatInfo.IsAddonMessagePrefixRegistered("jstpaopao") then
	local succeed, reason = C_ChatInfo.RegisterAddonMessagePrefix("jstpaopao")
end

if reason and RegisterAddonMessageResults[reason] then
	T.msg(RegisterAddonMessageResults[reason])
end

--====================================================--
--[[                -- Callbacks --                 ]]--
--====================================================--
G.Init_callbacks = {}
T.RegisterInitCallback = function(func)
	table.insert(G.Init_callbacks, func)
end

G.EnteringWorld_callbacks = {}
T.RegisterEnteringWorldCallback = function(func)
	table.insert(G.EnteringWorld_callbacks, func)
end