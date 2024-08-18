local _G = _G
local _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'


local Utils = {}
function Utils.Length(t)
    local l=0
    for k,v in pairs(t) do
        l=l+1
    end
    return l
end

function Utils.Split(str,delimiter)
    local dLen = string.len(delimiter)
    local newDeli = ''
    for i=1,dLen,1 do
        newDeli = newDeli .. "["..string.sub(delimiter,i,i).."]"
    end

    local locaStart,locaEnd = string.find(str,newDeli)
    local arr = {}
    local n = 1
    while locaStart ~= nil
    do
        if locaStart>0 then
            arr[n] = string.sub(str,1,locaStart-1)
            n = n + 1
        end

        str = string.sub(str,locaEnd+1,string.len(str))
        locaStart,locaEnd = string.find(str,newDeli)
    end
    if str ~= nil then
        arr[n] = str
    end
    return arr
end


local function json2true(str, from, to)
    return true, from + 3
end

local function json2false(str, from, to)
    return false, from + 4
end

local function json2null(str, from, to)
    return nil, from + 3
end

local function json2nan(str, from, to)
    return nul, from + 2
end

local numberchars = {
    ['-'] = true,
    ['+'] = true,
    ['.'] = true,
    ['0'] = true,
    ['1'] = true,
    ['2'] = true,
    ['3'] = true,
    ['4'] = true,
    ['5'] = true,
    ['6'] = true,
    ['7'] = true,
    ['8'] = true,
    ['9'] = true,
}

local function json2number(str, from, to)
    local i = from + 1
    while (i <= to) do
        local char = string.sub(str, i, i)
        if not numberchars[char] then
            break
        end
        i = i + 1
    end
    local num = tonumber(string.sub(str, from, i - 1))
    if not num then
        Log("red", 'json格式错误，不正确的数字, 错误位置:', from)
    end
    return num, i - 1
end

local function json2string(str, from, to)
    local ignor = false
    for i = from + 1, to do
        local char = string.sub(str, i, i)
        if not ignor then
            if char == '\"' then
                return string.sub(str, from + 1, i - 1), i
            elseif char == '\\' then
                ignor = true
            end
        else
            ignor = false
        end
    end
    Log("red", 'json格式错误，字符串没有找到结尾, 错误位置:{from}', from)
end

local function json2array(str, from, to)
    local result = {}
    from = from or 1
    local pos = from + 1
    local to = to or string.len(str)
    while (pos <= to) do
        local char = string.sub(str, pos, pos)
        if char == '\"' then
            result[#result + 1], pos = json2string(str, pos, to)
        elseif char == '[' then
            result[#result + 1], pos = json2array(str, pos, to)
        elseif char == '{' then
            result[#result + 1], pos = Utils.json2table(str, pos, to)
        elseif char == ']' then
            return result, pos
        elseif (char == 'f' or char == 'F') then
            result[#result + 1], pos = json2false(str, pos, to)
        elseif (char == 't' or char == 'T') then
            result[#result + 1], pos = json2true(str, pos, to)
        elseif (char == 'n') then
            result[#result + 1], pos = json2null(str, pos, to)
        elseif (char == 'N') then
            result[#result + 1], pos = json2nan(str, pos, to)
        elseif numberchars[char] then
            result[#result + 1], pos = json2number(str, pos, to)
        end
        pos = pos + 1
    end
    Log("red", 'json格式错误，表没有找到结尾, 错误位置:{from}', from)
end

local function string2json(key, value)
    return string.format("\"%s\":\"%s\",", key, value)
end

local function number2json(key, value)
    return string.format("\"%s\":%s,", key, value)
end

local function boolean2json(key, value)
    value = value == nil and false or value
    return string.format("\"%s\":%s,", key, tostring(value))
end

local function array2json(key, value)
    local str = "["
    for k, v in pairs(value) do
        str = str .. Utils.table2json(v) .. ","
    end
    str = string.sub(str, 1, string.len(str) - 1) .. "]"
    return string.format("\"%s\":%s,", key, str)
end

local function isArrayTable(t)

    if type(t) ~= "table" then
        return false
    end

    local n = #t
    for i, v in pairs(t) do
        if type(i) ~= "number" then
            return false
        end

        if i > n then
            return false
        end
    end

    return true
end

local function table2json(key, value)
    if isArrayTable(value) then
        return array2json(key, value)
    end
    local tableStr = Utils.table2json(value)
    return string.format("\"%s\":%s,", key, tableStr)
end



function Utils.json2table(str, from, to)
    local result = {}
    from = from or 1
    local pos = from + 1
    local to = to or string.len(str)
    local key
    while (pos <= to) do
        local char = string.sub(str, pos, pos)
        if char == '\"' then
            if not key then
                key, pos = json2string(str, pos, to)
            else
                result[key], pos = json2string(str, pos, to)
                key = nil
            end
        --[[    elseif char == ' ' then

        elseif char == ':' then

        elseif char == ',' then]]
        elseif char == '[' then
            if not key then
                key, pos = json2array(str, pos, to)
            else
                result[key], pos = json2array(str, pos, to)
                key = nil
            end
        elseif char == '{' then
            if not key then
                key, pos = Utils.json2table(str, pos, to)
            else
                result[key], pos = Utils.json2table(str, pos, to)
                key = nil
            end
        elseif char == '}' then
            return result, pos
        elseif (char == 'f' or char == 'F') then
            result[key], pos = json2false(str, pos, to)
            key = nil
        elseif (char == 't' or char == 'T') then
            result[key], pos = json2true(str, pos, to)
            key = nil
        elseif (char == 'n') then
            result[key], pos = json2null(str, pos, to)
            key = nil
        elseif (char == 'N') then
            result[key], pos = json2nan(str, pos, to)
            key = nil
        elseif numberchars[char] then
            if not key then
                key, pos = json2number(str, pos, to)
            else
                result[key], pos = json2number(str, pos, to)
                key = nil
            end
        end
        pos = pos + 1
    end
    Log("red", 'json格式错误，表没有找到结尾, 错误位置:{from}', from)
end

local jsonfuncs = {
    ['\"'] = json2string,
    ['['] = json2array,
    ['{'] = Utils.json2table,
    ['f'] = json2false,
    ['F'] = json2false,
    ['t'] = json2true,
    ['T'] = json2true,
}

function Utils.json2lua(str)
    local char = string.sub(str, 1, 1)
    local func = jsonfuncs[char]
    if func then
        return func(str, 1, string.len(str))
    end
    if numberchars[char] then
        return json2number(str, 1, string.len(str))
    end
end

function Utils.table2json(tab)
    local str = "{"
    for k, v in pairs(tab) do
        if type(v) == "string" then
            str = str .. string2json(k, v)
        elseif type(v) == "number" then
            str = str .. number2json(k, v)
        elseif type(v) == "boolean" then
            str = str .. boolean2json(k, v)
        elseif type(v) == "table" then
            str = str .. table2json(k, v)
        end
    end
    str = string.sub(str, 1, string.len(str) - 1)
    return str .. "}"
end


function Utils.Encode(text, maxLineLength, lineEnding)
    local t = {}
    local byteToNum, numToChar = {}, {}
    for i = 1, #_chars do
	    numToChar[i - 1] = string.sub(_chars, i, i)
	    byteToNum[string.byte(_chars, i)] = i - 1
    end
	if type(text) ~= "string" then
		error(format("Bad argument #1 to `Encode'. Expected string, got %q", type(text)), 2)
	end

	if maxLineLength then
		if type(maxLineLength) ~= "number" then
			error(format("Bad argument #2 to `Encode'. Expected number or nil, got %q", type(maxLineLength)), 2)
		elseif (maxLineLength % 4) ~= 0 then
			error(format("Bad argument #2 to `Encode'. Expected a multiple of 4, got %s", maxLineLength), 2)
		elseif maxLineLength <= 0 then
			error(format("Bad argument #2 to `Encode'. Expected a number > 0, got %s", maxLineLength), 2)
		end
	end

	if lineEnding == nil then
		lineEnding = "\r\n"
	elseif type(lineEnding) ~= "string" then
		error(format("Bad argument #3 to `Encode'. Expected string, got %q", type(lineEnding)), 2)
	end

	local currentLength = 0
	for i = 1, #text, 3 do
		local a, b, c = string.byte(text, i, i+2)
		local nilNum = 0
		if not b then
			nilNum, b, c = 2, 0, 0
		elseif not c then
			nilNum, c = 1, 0
		end

		local num = a * 2^16 + b * 2^8 + c
		local d = num % 2^6;num = (num - d) / 2^6
		c = num % 2^6;num = (num - c) / 2^6
		b = num % 2^6;num = (num - b) / 2^6
		a = num % 2^6

		t[#t+1] = numToChar[a]
		t[#t+1] = numToChar[b]
		t[#t+1] = (nilNum >= 2) and "=" or numToChar[c]
		t[#t+1] = (nilNum >= 1) and "=" or numToChar[d]

		currentLength = currentLength + 4
		if maxLineLength and (currentLength % maxLineLength) == 0 then
			t[#t+1] = lineEnding
		end
	end

	local s = table.concat(t)
	return s
end


_G.Utils = Utils
