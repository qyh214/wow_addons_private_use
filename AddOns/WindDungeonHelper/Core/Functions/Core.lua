local W, F, L = unpack(select(2, ...))

local _G = _G
local abs = abs
local format = format
local min = min
local pairs = pairs
local pcall = pcall
local print = print
local strfind = strfind
local strmatch = strmatch
local tonumber = tonumber
local tostring = tostring
local tremove = tremove
local type = type
local unpack = unpack

local GetClassColor = GetClassColor

--[[
    从数据库设定字体颜色
    @param {object} text FontString 型对象
    @param {table} db 字体颜色数据库
]]
function F.SetFontColorWithDB(text, db)
	if not text or not text.GetFont then
		F.Developer.LogDebug("Functions.SetFontColorWithDB: text not found")
		return
	end
	if not db or type(db) ~= "table" then
		F.Developer.LogDebug("Functions.SetFontColorWithDB: db not found")
		return
	end

	text:SetTextColor(db.r, db.g, db.b, db.a)
end

--[[
    更换窗体内部字体描边为轮廓
    @param {object} frame 窗体
    @param {string} [font] 字型路径
    @param {number|string} [size] 字体尺寸或是尺寸变化量字符串
]]
function F.SetFrameFontOutline(frame, font, size)
	if not frame or not frame.GetRegions then
		F.Developer.LogDebug("Functions.SetFrameFontOutline: frame not found")
		return
	end
	for _, region in pairs({ frame:GetRegions() }) do
		if region:IsObjectType("FontString") then
			F.SetFontOutline(region, font, size)
		end
	end
end

--[[
    打印信息
    @param {string} text 文本
]]
function F.Print(text)
	if not text then
		return
	end

	local message = format("%s: %s", W.AddonName, text)
	print(message)
end

function F.Round(number, decimals)
	return format(format("%%.%df", decimals), number)
end

do
	local color = {
		start = {
			r = 1.000,
			g = 0.647,
			b = 0.008,
		},
		complete = {
			r = 0.180,
			g = 0.835,
			b = 0.451,
		},
	}

	function F.GetProgressColor(progress)
		local r = (color.complete.r - color.start.r) * progress + color.start.r
		local g = (color.complete.g - color.start.g) * progress + color.start.g
		local b = (color.complete.r - color.start.b) * progress + color.start.b

		-- algorithm to let the color brighter
		local addition = 0.35
		r = min(r + abs(0.5 - progress) * addition, r)
		g = min(g + abs(0.5 - progress) * addition, g)
		b = min(b + abs(0.5 - progress) * addition, b)

		return { r = r, g = g, b = b }
	end
end

function F.SetVertexColorWithDB(tex, db)
	if not tex or not tex.GetVertexColor then
		F.Developer.LogDebug("Functions.SetVertexColorWithDB: No texture to handling")
		return
	end
	if not db or type(db) ~= "table" then
		F.Developer.LogDebug("Functions.SetVertexColorWithDB: No texture color database")
		return
	end

	tex:SetVertexColor(db.r, db.g, db.b, db.a)
end

function F.In(val, tbl)
	if not val or not tbl or type(tbl) ~= "table" then
		return false
	end

	for _, v in pairs(tbl) do
		if v == val then
			return true
		end
	end

	return false
end

function F.IsNaN(val)
	return tostring(val) == tostring(0 / 0)
end

function F.Or(val, default)
	if not val or F.IsNaN(val) then
		return default
	end
	return val
end

local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function F.CreateColorString(text, r, g, b)
	if not text or not type(text) == "string" then
		print("Cannot find the text.")
		return
	end

	local hex

	if r and g and b then
		hex = RGBToHex(r, g, b)
	else
		hex = RGBToHex(52 / 255, 152 / 255, 219 / 255)
	end

	return "|cff" .. hex .. text .. "|r"
end

function F.CreateClassColorString(text, englishClass)
	if not text or not type(text) == "string" then
		print("Cannot find the text.")
		return
	end
	if not englishClass or type(englishClass) ~= "string" then
		print("Cannot find the class text.")
		return
	end

	local r, g, b = GetClassColor(englishClass)
	return F.CreateColorString(text, r, g, b)
end
