---------------------------------------------------------------------------------------------------------------------
-- A minimal Crayon like implementation for managing color.
-- @name Colorize
-- @class module
-- @author Alar of Daggerspine

---
-- @type C
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
-- -- Each color became the name of a method
--
local LibStub=LibStub
local libinit,MINOR_VERSION = LibStub("LibInit")
if not libinit then return end

local C
-- Color system related function
local lib=LibStub:NewLibrary("LibInit-Colorize",MINOR_VERSION)
if (not lib) then return end
local setmetatable=setmetatable
local tonumber=tonumber
local tostring=tostring
local rawget=rawget
local rawset=rawset
local pairs=pairs
local format=format
local strlower=strlower
local type=type
local unpack=unpack
local _G=_G
local UIERRORS_HOLD_TIME=UIERRORS_HOLD_TIME or 1
local UIErrorsFrame=UIErrorsFrame
local ChatTypeInfo=ChatTypeInfo
local GetItemQualityColor=GetItemQualityColor

lib.colors={
azure                   ="0c92dc"
,aqua					="00ffff"
,black                  ="000000"
,blue                   ="0000ff"
,brightgrey             ="d0d0d0"
,connection_color       ="33ff66"
,copper                 ="cc9900"
,cyan					="00ffff"
,debug_color            ="00ff00"
,fuchsia				="ff00ff"
,gold                   ="ffff66"
,gray                   ="808080"
,green                  ="20ff20"
,green2                 ="00c000"
,green3					="008000"
,grey                   ="909090"
,guildchat              ="269926"
,highlight_color_code   ="ffffff"
,lightblue              ="515179"
,lightyellow            ="ffff9a"
,lightgrey              ="d0d0d0"
,lime					="00FF00"
,maroon					="800000"
,money_color            ="ffcc33"
,olive					="808000"
,navy					="000080"
,teal					="008080"
,orange                 ="ff9900"
,partychat              ="515179"
,purple                 ="800080"
,raidchat               ="66331a"
,red                    ="ff2020"
,red2                   ="f41400"
,silver                 ="c0c0c0"
,status_color           ="0066ff"
,white                  ="ffffff"
,yellow                 ="ffd200"
,yellow2                ="ffed1a"
,druid  			    ="ff7d0a"
,hunter					="abd473"
,mage        			="69ccf0"
,deathknight			="ff0000"
,paladin     			="f58cba"
,priest     			="ffffff"
,rogue       			="fff569"
,shaman      			="0000FF"
,warlock     			="9482ca"
,warrior     			="c79c6e"
,default				="ffd200"
}
if (_G.RAID_CLASS_COLORS) then
	for class,c in pairs (_G.RAID_CLASS_COLORS) do
		local color=format("%02X%02X%02X", 255*c.r, 255*c.g, 255*c.b)
		lib.colors[strlower(class)]=color
	end
end
local numqualities=_G.NUM_ITEM_QUALITIES or 8
for i=1,numqualities do
	local _,_,_,hex=GetItemQualityColor(i)
	local c=strlower(_G["ITEM_QUALITY"..i.."_DESC"])
	lib.colors[tostring(i)]=hex:sub(3)
	if (c) then
		lib.colors[c]=hex:sub(3)
	end
end

local ChatTypeInfo=ChatTypeInfo or {}
local format=format
setmetatable(lib.colors,
{__index=
	function(table,key)
		local color
		local okey=key
		if (key=='horde' or key== "chat_msg_bg_system_horde") then
			color = ChatTypeInfo["BG_SYSTEM_HORDE"]
			if type(color) == "table" and color.r and color.g and color.b then
				local r, g, b = color.r, color.g, color.b
				color=format("%02X%02X%02X", 255*r, 255*g, 255*b)
			else
				key='azure'
			end
		end
		if (key=='alliance' or key=='ally' or key== "chat_msg_bg_system_alliance") then
			color = ChatTypeInfo["BG_SYSTEM_ALLIANCE"]
			if type(color) == "table" and color.r and color.g and color.b then
				local r, g, b = color.r, color.g, color.b
				color=format("%02X%02X%02X", 255*r, 255*g, 255*b)
			else
				key='red'
			end
		end
		if (key=='neutral' or key== "chat_msg_bg_system_neutral") then
			color = ChatTypeInfo["BG_SYSTEM_NEUTRAL"]
			if type(color) == "table" and color.r and color.g and color.b then
				local r, g, b = color.r, color.g, color.b
				color=format("%02X%02X%02X", 255*r, 255*g, 255*b)
			else
				key='yellow'
			end
		end
		if (not color) then color=rawget(table,key) or table.default end
		rawset(table,okey,color)
		return color
	end
}
)
local function colorize(stringa,colore,dummy)
		-- Crayon compatibility
		if (type(stringa)=="table") then
				stringa=dummy
		end
		if (type(colore)~="string") then colore="Yellow" end
		if (colore:len()== 6 and colore:match("^%x%x%x%x%x%x$")) then
				return "|cff" .. colore .. tostring(stringa) .. "|r"
		else
				return "|cff" .. C[colore] .. tostring(stringa) .. "|r"
		end
end
local colors=lib.colors
local map={r=1,g=2,b=3,c=4}
local mt={
		__index=function(table,key)
				return rawget(table,map[key])
		end,
		__tostring=function(table)
				return rawget(table,4)
		end,
		__concat=function(t1,t2)
				return tostring(t1) .. tostring(t2)
		end,
		__call=function(table,...)
				return unpack(table)
		end

}
C=setmetatable({},{
		__index=function(table,key)
			key=strlower(tostring(key))
				local c=colors[key]
				local r,g,b=tonumber(c:sub(1,2),16)/255,tonumber(c:sub(3,4),16)/255,tonumber(c:sub(5,6),16)/255
				rawset(table,key,setmetatable({r,g,b,c},mt))
				return  rawget(table,key)
		end,
		__call = function(table,...)
						return colorize(...)
		end
	}
)
function lib:OnScreen(color,msg,hold)
	color=color or "Yellow"
	msg=msg or "Test message"
	local r,g,b=C[color]()
	hold=hold or 4
	UIErrorsFrame:AddMessage(tostring(msg), r,g,b, 1.0, UIERRORS_HOLD_TIME * hold);
end
setmetatable(lib,{
	__call=function(table,...) return C end
	}
)
function lib:example()
	for k,v in pairs(lib.colors) do
		print(C(k,k))
	end
	print("----------------")
	for k,v in pairs(ITEM_QUALITY_COLORS) do
		print(format("%s Quality: %2d|r",v.hex,k))
	end
end
libinit:_SetColorize(lib())
