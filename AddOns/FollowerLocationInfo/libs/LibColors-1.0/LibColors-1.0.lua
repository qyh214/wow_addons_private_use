
local MAJOR, MINOR = "LibColors-1.0", 107
local lib = LibStub:NewLibrary(MAJOR, MINOR)
local _G,string,match,tonumber,rawset,type = _G,string,match,tonumber,rawset,type

if not lib then return end

lib.num2hex = function(num)
	return ("%02x"):format(tonumber(num)*100/(100/255));
end

lib.colorTable2HexCode = function(cT)
	local _ = lib.num2hex;
	return _(cT[4] or cT["a"] or 1).._(cT[1] or cT["r"] or 1).._(cT[2] or cT["g"] or 1).._(cT[3] or cT["b"] or 1);
end

lib.hexCode2ColorTable = function(colorStr)
	local codes = {string.sub(colorStr,3,4), string.sub(colorStr,5,6), string.sub(colorStr,7,8), string.sub(colorStr,1,2)};
	for i,v in pairs(codes) do
		v = string.format("%d","0x"..v);
		if v~=0 then
			codes[i] = ((100/255) * v) / 100;
		end
	end
	return codes;
end

lib.colorset = setmetatable({},{
	__index=function(t,k)
		if k:match("%x") then
			return k
		end
		return "ffffffff"; -- fallback color
	end,
	__call=function(t,a,b)
		assert(type(a)=="string" or type(a)=="table","Usage: lib.colorset(<string|table>[, <string>])");

		if type(a)=="table" then
			for i,v in pairs(a) do
				if type(i)=="string" and (type(v)=="string" or type(v)=="table") then
					lib.colorset(i,v);
				end
			end
			return;
		end

		if type(b)=="table" then
			b = lib.colorTable2HexCode(b);
		end

		if type(b)=="string" then
			rawset(t,a,strrep("f",8-strlen(b))..b);
			return;
		end
		return;
	end
})

lib.color = function(reqColor, str)
	local color
	assert(type(reqColor)=="string" or type(reqColor)=="table","Usage: lib.color(<string|table>[, <string>])")

	-- convert table to string
	if type(reqColor)=="table" then
		reqColor = lib.colorTable2HexCode(reqColor)

	-- or replace special color keywords
	elseif reqColor=="playerclass" then
		reqColor = UnitName("player")
	end

	-- get color code from lib.colorset
	color = lib.colorset[reqColor:lower()]

	 -- return color as color table
	if str=="colortable" then
		return lib.hexCode2ColorTable(color)
	end

	-- return string with color or color code
	return (str==nil and color) or ("|c%s%s|r"):format(color, str)
end

lib.getNames = function(pattern)
	local names,_ = {}
	for name,_ in pairs(lib.colorset) do
		if pattern==nil or (pattern~=nil and name:match(pattern)) then
			tinsert(names,name)
		end
	end
	return names
end

do --[[ basic set of colors ]]
	local tmp = {
		-- basic colors
		yellow = "ffff00",
		orange = "ff8000",
		red    = "ff0000",
		violet = "ff00ff",
		blue   = "0000ff",
		cyan   = "00ffff",
		green  = "00ff00",
		black  = "000000",
		gray   = "808080",
		white  = "ffffff",
		-- wow money colors
		money_gold   = "ffd700",
		money_silver = "eeeeef",
		money_copper = "f0a55f",
	};

	-- add class names with english and localized names
	for n, c in pairs(_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS) do
		tmp[n:lower()] = c.colorStr;
		tmp[_G.LOCALIZED_CLASS_NAMES_MALE[n]:lower()] = c.colorStr;
		tmp[_G.LOCALIZED_CLASS_NAMES_FEMALE[n]:lower()] = c.colorStr;
	end

	-- add item quality colors [currently from -1 to 7]
	for i,v in pairs(_G.ITEM_QUALITY_COLORS) do
		tmp["quality"..i] = v;
		if (_G["ITEM_QUALITY"..i.."_DESC"]) then
			tmp[_G["ITEM_QUALITY"..i.."_DESC"]:lower()] = v;
		end
	end

	lib.colorset(tmp)
end

--[[ space for more colors later... ]]

