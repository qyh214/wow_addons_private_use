---@class BigFootSync
local BigFootSync = select(2, ...)
BigFootSync.utils = {}

BigFootSync.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
BigFootSync.isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
BigFootSync.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
BigFootSync.isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

---@class Utils
local U = BigFootSync.utils

---------------------------------------------------------------------
-- GetBigFootClientVersion
---------------------------------------------------------------------
function U.GetBigFootClientVersion(wowProjectID)
    wowProjectID = wowProjectID or WOW_PROJECT_ID
    if wowProjectID == WOW_PROJECT_MAINLINE then -- 正式服
        return 0
    elseif wowProjectID == WOW_PROJECT_CLASSIC then -- 经典60
        return 1
    elseif wowProjectID == WOW_PROJECT_WRATH_CLASSIC then -- 巫妖王
        return 3
    else -- 大灾变
        return 2
    end
end

---------------------------------------------------------------------
-- GetClassID
---------------------------------------------------------------------
local localizedClass
if FillLocalizedClassList then
    localizedClass = {}
    FillLocalizedClassList(localizedClass)
else
    localizedClass = LocalizedClassList()
end

local classFileToID = {}
local localizedClassToID = {}

do
    -- WARRIOR = 1,
    -- PALADIN = 2,
    -- HUNTER = 3,
    -- ROGUE = 4,
    -- PRIEST = 5,
    -- DEATHKNIGHT = 6,
    -- SHAMAN = 7,
    -- MAGE = 8,
    -- WARLOCK = 9,
    -- MONK = 10,
    -- DRUID = 11,
    -- DEMONHUNTER = 12,
    -- EVOKER = 13,
    for i = 1, GetNumClasses() do
        local classFile = select(2, GetClassInfo(i))
        if classFile then -- returns nil for classes not exist in Classic
            classFileToID[classFile] = i
            localizedClassToID[localizedClass[classFile]] = i
        end
    end
end

function U.GetClassID(class)
    return classFileToID[class] or localizedClassToID[class]
end

---------------------------------------------------------------------
-- MaxLevel
---------------------------------------------------------------------
function U.GetMaxLevel()
    if BigFootSync.isCata then
        return 85
    elseif BigFootSync.isWrath then
        return 80
    elseif BigFootSync.isVanilla then
        return 60
    else
        -- Upon initial login, this will return the result of GetMaxLevelForExpansionLevel(0) (currently 30)
        -- until sometime between PLAYER_ENTERING_WORLD and when a SHOW_SUBSCRIPTION_INTERSTITIAL would fire for a lapsed subscription
        -- but then provides the correct value through subsequent logins and reloads on the same server.
        return 80 -- GetMaxLevelForLatestExpansion()
    end
end

---------------------------------------------------------------------
-- UnitName
---------------------------------------------------------------------
function U.UnitName(unit)
    if not unit or not UnitIsPlayer(unit) then return end

    local name, realm = UnitNameUnmodified(unit)
    if not name or name == "" then return end

    -- 同服角色不带服务器名，不可使用 GetRealmName()，其中可能包含空格或短横线
    if not realm then realm = GetNormalizedRealmName() end
    if not realm or realm == "" then return end

    return name.."-"..realm, name, realm
end

---------------------------------------------------------------------
-- UnitShortName
---------------------------------------------------------------------
function U.ToShortName(fullName)
    if not fullName then return "" end
    local shortName = strsplit("-", fullName)
    return shortName
end

---------------------------------------------------------------------
-- IterateGroupMembers
---------------------------------------------------------------------
function U.IterateGroupMembers()
    local groupType = IsInRaid() and "raid" or "party"
    local numGroupMembers = GetNumGroupMembers()
    local i

    if groupType == "party" then
        i = 0
        numGroupMembers = numGroupMembers - 1
    else
        i = 1
    end

    return function()
        local ret
        if i == 0 then
            ret = "player"
        elseif i <= numGroupMembers and i > 0 then
            ret = groupType .. i
        end
        i = i + 1
        return ret
    end
end

---------------------------------------------------------------------
-- table to json - https://github.com/hjson/hjson-lua
---------------------------------------------------------------------
-- MIT License - Copyright (c) 2023 V (alis.is)
local escape_char_map = {
    ["\\"] = "\\\\",
    ['"'] = '\\"',
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t"
}

local function isArray(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

local function escapeChar(c)
    return escape_char_map[c] or string.format("\\u%04x", c:byte())
end

local function encodeString(s)
    return '"' .. s:gsub('[%z\1-\31\\"]', escapeChar) .. '"'
end

local function encodeNil(val) return "null" end

local function encodeNumber(val)
    -- Check for NaN, -inf and inf
    if val ~= val or val <= -math.huge or val >= math.huge then
        error("unexpected number value '" .. tostring(val) .. "'")
    end
    return string.format("%.14g", val)
end

local JsonEncoder = {}

function JsonEncoder:new(options)
    if type(options) ~= "table" then options = {} end
    local skip_keys, sort_keys, item_sort_key, invalid_objects_as_type =
        options.skip_keys, options.sort_keys,
        options.item_sort_key, options.invalid_objects_as_type

    if skip_keys == nil then skip_keys = true end

    local stack = {}

    local function stringifyKey(key)
        local _type = type(key)
        if _type == "boolean" or _type == "number" then
            return tostring(key)
        elseif _type == "nil" then
            return "null"
        elseif _type == "string" then
            return encodeString(key)
        end
        if skip_keys then return nil end
        error(string.format("Invalid key type - %s (%s) ", _type, key))
    end

    local function encodeArray(arr, encode)
        if not arr or #arr == 0 then return "[]" end
        if stack[arr] then error("circular reference") end
        stack[arr] = true
        local separator = ","
        local buf = "["
        for i, v in ipairs(arr) do
            buf = buf .. encode(v)
            if i ~= #arr then buf = buf .. separator end
        end
        buf = buf .. "]"
        stack[arr] = nil
        return buf
    end

    local function encodeTable(tab, encode)
        if not tab then return "{}" end
        if stack[tab] then error("circular reference") end
        stack[tab] = true
        local separator = ","
        local keySeparator = ":"

        local keysetMap = {} -- stringified key (sk) is key for real key
        local keyset = {}
        local n = 0

        for k in pairs(tab) do
            local key = stringifyKey(k)
            if key ~= nil then
                table.insert(keyset, key)
                keysetMap[key] = k
            end
        end
        if sort_keys then
            if type(item_sort_key) == "function" then
                table.sort(keyset, item_sort_key)
            else
                table.sort(keyset,
                           function(a, b)
                    return a:upper() < b:upper()
                end)
            end
        end
        local buf = "{"
        for i, sk in ipairs(keyset) do
            local k = keysetMap[sk]
            local v = tab[k]
            buf = buf .. sk .. keySeparator .. encode(v)
            if i ~= #keyset then buf = buf .. separator end
        end
        buf = buf .. "}"
        stack[tab] = nil
        return buf
    end

    local encodeFunctionMap = {
        ["nil"] = encodeNil,
        ["table"] = encodeTable,
        ["array"] = encodeArray,
        ["string"] = encodeString,
        ["number"] = encodeNumber,
        ["boolean"] = tostring
    }

    local function encode(o)
        local _type = type(o)
        if _type == "table" then
            if isArray(o) then
                _type = "array"
            else
                _type = "table"
            end
        end
        local func = encodeFunctionMap[_type]
        if type(func) == "function" then return func(o, encode) end
        if invalid_objects_as_type then
            return encodeFunctionMap["string"]('__lua_' .. type(o))
        end
        error("Unexpected type '" .. _type .. "'")
    end

    local je = {_encode = encode}
    setmetatable(je, self)
    self.__index = self

    return je
end

function JsonEncoder:encode(o, allowNonJsonTypes)
    return self._encode(o, allowNonJsonTypes)
end

local je = JsonEncoder:new()

function U.ConvertTableToJson(t)
    return je:encode(t)
end

---------------------------------------------------------------------
-- lua base64 - https://github.com/iskolbin/lbase64
---------------------------------------------------------------------
--[[

 base64 -- v1.5.3 public domain Lua base64 encoder/decoder
 no warranty implied; use at your own risk

 Needs bit32.extract function. If not present it's implemented using BitOp
 or Lua 5.3 native bit operators. For Lua 5.1 fallbacks to pure Lua
 implementation inspired by Rici Lake's post:
   http://ricilake.blogspot.co.uk/2007/10/iterating-bits-in-lua.html

 author: Ilya Kolbin (iskolbin@gmail.com)
 url: github.com/iskolbin/lbase64

 COMPATIBILITY

 Lua 5.1+, LuaJIT

 LICENSE

 See end of file for license information.

--]]

local base64 = {}

local extract = _G.bit32 and _G.bit32.extract -- Lua 5.2/Lua 5.3 in compatibility mode
if not extract then
	if _G.bit then -- LuaJIT
		local shl, shr, band = _G.bit.lshift, _G.bit.rshift, _G.bit.band
		extract = function( v, from, width )
			return band( shr( v, from ), shl( 1, width ) - 1 )
		end
	elseif _G._VERSION == "Lua 5.1" then
		extract = function( v, from, width )
			local w = 0
			local flag = 2^from
			for i = 0, width-1 do
				local flag2 = flag + flag
				if v % flag2 >= flag then
					w = w + 2^i
				end
				flag = flag2
			end
			return w
		end
	else -- Lua 5.3+
		extract = load[[return function( v, from, width )
			return ( v >> from ) & ((1 << width) - 1)
		end]]()
	end
end


function base64.makeencoder( s62, s63, spad )
	local encoder = {}
	for b64code, char in pairs{[0]='A','B','C','D','E','F','G','H','I','J',
		'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
		'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
		'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
		'3','4','5','6','7','8','9',s62 or '+',s63 or'/',spad or'='} do
		encoder[b64code] = char:byte()
	end
	return encoder
end

function base64.makedecoder( s62, s63, spad )
	local decoder = {}
	for b64code, charcode in pairs( base64.makeencoder( s62, s63, spad )) do
		decoder[charcode] = b64code
	end
	return decoder
end

local DEFAULT_ENCODER = base64.makeencoder()
local DEFAULT_DECODER = base64.makedecoder()

local char, concat = string.char, table.concat

function base64.encode( str, encoder, usecaching )
	encoder = encoder or DEFAULT_ENCODER
	local t, k, n = {}, 1, #str
	local lastn = n % 3
	local cache = {}
	for i = 1, n-lastn, 3 do
		local a, b, c = str:byte( i, i+2 )
		local v = a*0x10000 + b*0x100 + c
		local s
		if usecaching then
			s = cache[v]
			if not s then
				s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
				cache[v] = s
			end
		else
			s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
		end
		t[k] = s
		k = k + 1
	end
	if lastn == 2 then
		local a, b = str:byte( n-1, n )
		local v = a*0x10000 + b*0x100
		t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[64])
	elseif lastn == 1 then
		local v = str:byte( n )*0x10000
		t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[64], encoder[64])
	end
	return concat( t )
end

function base64.decode( b64, decoder, usecaching )
	decoder = decoder or DEFAULT_DECODER
	local pattern = '[^%w%+%/%=]'
	if decoder then
		local s62, s63
		for charcode, b64code in pairs( decoder ) do
			if b64code == 62 then s62 = charcode
			elseif b64code == 63 then s63 = charcode
			end
		end
		pattern = ('[^%%w%%%s%%%s%%=]'):format( char(s62), char(s63) )
	end
	b64 = b64:gsub( pattern, '' )
	local cache = usecaching and {}
	local t, k = {}, 1
	local n = #b64
	local padding = b64:sub(-2) == '==' and 2 or b64:sub(-1) == '=' and 1 or 0
	for i = 1, padding > 0 and n-4 or n, 4 do
		local a, b, c, d = b64:byte( i, i+3 )
		local s
		if usecaching then
			local v0 = a*0x1000000 + b*0x10000 + c*0x100 + d
			s = cache[v0]
			if not s then
				local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
				s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
				cache[v0] = s
			end
		else
			local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
			s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
		end
		t[k] = s
		k = k + 1
	end
	if padding == 1 then
		local a, b, c = b64:byte( n-3, n-1 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40
		t[k] = char( extract(v,16,8), extract(v,8,8))
	elseif padding == 2 then
		local a, b = b64:byte( n-3, n-2 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000
		t[k] = char( extract(v,16,8))
	end
	return concat( t )
end

--[[
------------------------------------------------------------------------------
This software is available under 2 licenses -- choose whichever you prefer.
------------------------------------------------------------------------------
ALTERNATIVE A - MIT License
Copyright (c) 2018 Ilya Kolbin
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------
ALTERNATIVE B - Public Domain (www.unlicense.org)
This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.
In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
------------------------------------------------------------------------------
--]]

function U.Base64Encode(str)
    return base64.encode(str)
end