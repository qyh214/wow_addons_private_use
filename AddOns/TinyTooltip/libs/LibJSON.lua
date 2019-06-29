
--
-- Copyright 2010-2017 Jeffrey Friedl
-- http://regex.info/blog/
-- Latest version: http://regex.info/blog/lua/json
--
-- This code is released under a Creative Commons CC-BY "Attribution" License:
-- http://creativecommons.org/licenses/by/3.0/deed.en_US
--

local MAJOR, MINOR = "LibJSON", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end


local default_pretty_indent  = "  "
local default_pretty_options = { pretty = true, indent = default_pretty_indent, align_keys = false, array_newline = false }

local isArray  = { __tostring = function() return "JSON array"  end }  isArray.__index  = isArray
local isObject = { __tostring = function() return "JSON object" end }  isObject.__index = isObject

function lib:newArray(tbl)
   return setmetatable(tbl or {}, isArray)
end

function lib:newObject(tbl)
   return setmetatable(tbl or {}, isObject)
end

local function getnum(op)
   return type(op) == 'number' and op or op.N
end

local isNumber = {
   __tostring = function(T)  return T.S end,
   __unm      = function(op) return getnum(op) end,
   __concat   = function(op1, op2) return tostring(op1) .. tostring(op2) end,
   __add      = function(op1, op2) return getnum(op1)   +   getnum(op2)  end,
   __sub      = function(op1, op2) return getnum(op1)   -   getnum(op2)  end,
   __mul      = function(op1, op2) return getnum(op1)   *   getnum(op2)  end,
   __div      = function(op1, op2) return getnum(op1)   /   getnum(op2)  end,
   __mod      = function(op1, op2) return getnum(op1)   %   getnum(op2)  end,
   __pow      = function(op1, op2) return getnum(op1)   ^   getnum(op2)  end,
   __lt       = function(op1, op2) return getnum(op1)   <   getnum(op2)  end,
   __eq       = function(op1, op2) return getnum(op1)   ==  getnum(op2)  end,
   __le       = function(op1, op2) return getnum(op1)   <=  getnum(op2)  end,
}
isNumber.__index = isNumber

function lib:asNumber(item)
   if getmetatable(item) == isNumber then
      return item
   elseif type(item) == 'table' and type(item.S) == 'string' and type(item.N) == 'number' then
      return setmetatable(item, isNumber)
   else
      local holder = {
         S = tostring(item),
         N = tonumber(item),
      }
      return setmetatable(holder, isNumber)
   end
end

function lib:forceString(item)
   if type(item) == 'table' and type(item.S) == 'string' then
      return item.S
   else
      return tostring(item)
   end
end

function lib:forceNumber(item)
   if type(item) == 'table' and type(item.N) == 'number' then
      return item.N
   else
      return tonumber(item)
   end
end

function lib:isNumber(item)
   if type(item) == 'number' then
      return item
   elseif type(item) == 'table' and type(item.N) == 'number' then
      return item.N
   else
      return nil
   end
end

function lib:isString(item)
   if type(item) == 'string' then
      return item
   elseif type(item) == 'table' and type(item.S) == 'string' then
      return item.S
   else
      return nil
   end
end


local function unicode_codepoint_as_utf8(codepoint)
   if codepoint <= 127 then
      return string.char(codepoint)

   elseif codepoint <= 2047 then
      local highpart = math.floor(codepoint / 0x40)
      local lowpart  = codepoint - (0x40 * highpart)
      return string.char(0xC0 + highpart,
                         0x80 + lowpart)

   elseif codepoint <= 65535 then

      local highpart  = math.floor(codepoint / 0x1000)
      local remainder = codepoint - 0x1000 * highpart
      local midpart   = math.floor(remainder / 0x40)
      local lowpart   = remainder - 0x40 * midpart

      highpart = 0xE0 + highpart
      midpart  = 0x80 + midpart
      lowpart  = 0x80 + lowpart

      if ( highpart == 0xE0 and midpart < 0xA0 ) or
         ( highpart == 0xED and midpart > 0x9F ) or
         ( highpart == 0xF0 and midpart < 0x90 ) or
         ( highpart == 0xF4 and midpart > 0x8F )
      then
         return "?"
      else
         return string.char(highpart,
                            midpart,
                            lowpart)
      end

   else

      local highpart  = math.floor(codepoint / 0x40000)
      local remainder = codepoint - 0x40000 * highpart
      local midA      = math.floor(remainder / 0x1000)
      remainder       = remainder - 0x1000 * midA
      local midB      = math.floor(remainder / 0x40)
      local lowpart   = remainder - 0x40 * midB

      return string.char(0xF0 + highpart,
                         0x80 + midA,
                         0x80 + midB,
                         0x80 + lowpart)
   end
end

function lib:onDecodeError(message, text, location, etc)
   if text then
      if location then
         message = string.format("%s at byte %d of: %s", message, location, text)
      else
         message = string.format("%s: %s", message, text)
      end
   end

   if etc ~= nil then
      message = message .. " (" .. lib:encode(etc) .. ")"
   end

   if self.assert then
      self.assert(false, message)
   else
      assert(false, message)
   end
end

function lib:onTrailingGarbage(json_text, location, parsed_value, etc)
   return self:onDecodeError("trailing garbage", json_text, location, etc)
end

lib.onDecodeOfNilError  = lib.onDecodeError
lib.onDecodeOfHTMLError = lib.onDecodeError

function lib:onEncodeError(message, etc)
   if etc ~= nil then
      message = message .. " (" .. lib:encode(etc) .. ")"
   end

   if self.assert then
      self.assert(false, message)
   else
      assert(false, message)
   end
end

local function grok_number(self, text, start, options)
   local integer_part = text:match('^-?[1-9]%d*', start)
                     or text:match("^-?0",        start)

   if not integer_part then
      self:onDecodeError("expected number", text, start, options.etc)
      return nil, start
   end

   local i = start + integer_part:len()
   local decimal_part = text:match('^%.%d+', i) or ""

   i = i + decimal_part:len()

   local exponent_part = text:match('^[eE][-+]?%d+', i) or ""

   i = i + exponent_part:len()

   local full_number_text = integer_part .. decimal_part .. exponent_part

   if options.decodeNumbersAsObjects then

      local objectify = false

      if not options.decodeIntegerObjectificationLength and not options.decodeDecimalObjectificationLength then
         objectify = true

      elseif (options.decodeIntegerObjectificationLength
          and
         (integer_part:len() >= options.decodeIntegerObjectificationLength or exponent_part:len() > 0))

          or
         (options.decodeDecimalObjectificationLength 
          and
          (decimal_part:len() >= options.decodeDecimalObjectificationLength  or exponent_part:len() > 0))
      then
         objectify = true
      end

      if objectify then
         return lib:asNumber(full_number_text), i
      end

   else
      if (options.decodeIntegerStringificationLength
          and
         (integer_part:len() >= options.decodeIntegerStringificationLength or exponent_part:len() > 0))

          or

         (options.decodeDecimalStringificationLength 
          and
          (decimal_part:len() >= options.decodeDecimalStringificationLength or exponent_part:len() > 0))
      then
         return full_number_text, i
      end

   end

   local as_number = tonumber(full_number_text)

   if not as_number then
      self:onDecodeError("bad number", text, start, options.etc)
      return nil, start
   end

   return as_number, i
end


local function grok_string(self, text, start, options)

   if text:sub(start,start) ~= '"' then
      self:onDecodeError("expected string's opening quote", text, start, options.etc)
      return nil, start
   end

   local i = start + 1
   local text_len = text:len()
   local VALUE = ""
   while i <= text_len do
      local c = text:sub(i,i)
      if c == '"' then
         return VALUE, i + 1
      end
      if c ~= '\\' then
         VALUE = VALUE .. c
         i = i + 1
      elseif text:match('^\\b', i) then
         VALUE = VALUE .. "\b"
         i = i + 2
      elseif text:match('^\\f', i) then
         VALUE = VALUE .. "\f"
         i = i + 2
      elseif text:match('^\\n', i) then
         VALUE = VALUE .. "\n"
         i = i + 2
      elseif text:match('^\\r', i) then
         VALUE = VALUE .. "\r"
         i = i + 2
      elseif text:match('^\\t', i) then
         VALUE = VALUE .. "\t"
         i = i + 2
      else
         local hex = text:match('^\\u([0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF])', i)
         if hex then
            i = i + 6
            local codepoint = tonumber(hex, 16)
            if codepoint >= 0xD800 and codepoint <= 0xDBFF then
               local lo_surrogate = text:match('^\\u([dD][cdefCDEF][0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF])', i)
               if lo_surrogate then
                  i = i + 6
                  codepoint = 0x2400 + (codepoint - 0xD800) * 0x400 + tonumber(lo_surrogate, 16)
               else

               end
            end
            VALUE = VALUE .. unicode_codepoint_as_utf8(codepoint)

         else

            VALUE = VALUE .. text:match('^\\(.)', i)
            i = i + 2
         end
      end
   end

   self:onDecodeError("unclosed string", text, start, options.etc)
   return nil, start
end

local function skip_whitespace(text, start)
   local _, match_end = text:find("^[ \n\r\t]+", start)
   if match_end then
      return match_end + 1
   else
      return start
   end
end

local grok_one

local function grok_object(self, text, start, options)
   if text:sub(start,start) ~= '{' then
      self:onDecodeError("expected '{'", text, start, options.etc)
      return nil, start
   end

   local i = skip_whitespace(text, start + 1)
   local VALUE = self.strictTypes and self:newObject { } or { }

   if text:sub(i,i) == '}' then
      return VALUE, i + 1
   end
   local text_len = text:len()
   while i <= text_len do
      local key, new_i = grok_string(self, text, i, options)
      i = skip_whitespace(text, new_i)
      if text:sub(i, i) ~= ':' then
         self:onDecodeError("expected colon", text, i, options.etc)
         return nil, i
      end
      i = skip_whitespace(text, i + 1)
      local new_val, new_i = grok_one(self, text, i, options)
      VALUE[key] = new_val
      i = skip_whitespace(text, new_i)
      local c = text:sub(i,i)
      if c == '}' then
         return VALUE, i + 1
      end

      if text:sub(i, i) ~= ',' then
         self:onDecodeError("expected comma or '}'", text, i, options.etc)
         return nil, i
      end

      i = skip_whitespace(text, i + 1)
   end

   self:onDecodeError("unclosed '{'", text, start, options.etc)
   return nil, start
end

local function grok_array(self, text, start, options)
   if text:sub(start,start) ~= '[' then
      self:onDecodeError("expected '['", text, start, options.etc)
      return nil, start
   end

   local i = skip_whitespace(text, start + 1) -- +1 to skip the '['
   local VALUE = self.strictTypes and self:newArray { } or { }
   if text:sub(i,i) == ']' then
      return VALUE, i + 1
   end

   local VALUE_INDEX = 1

   local text_len = text:len()
   while i <= text_len do
      local val, new_i = grok_one(self, text, i, options)

      VALUE[VALUE_INDEX] = val
      VALUE_INDEX = VALUE_INDEX + 1

      i = skip_whitespace(text, new_i)

      local c = text:sub(i,i)
      if c == ']' then
         return VALUE, i + 1
      end
      if text:sub(i, i) ~= ',' then
         self:onDecodeError("expected comma or ']'", text, i, options.etc)
         return nil, i
      end
      i = skip_whitespace(text, i + 1)
   end
   self:onDecodeError("unclosed '['", text, start, options.etc)
   return nil, i
end


grok_one = function(self, text, start, options)
   start = skip_whitespace(text, start)

   if start > text:len() then
      self:onDecodeError("unexpected end of string", text, nil, options.etc)
      return nil, start
   end

   if text:find('^"', start) then
      return grok_string(self, text, start, options.etc)

   elseif text:find('^[-0123456789 ]', start) then
      return grok_number(self, text, start, options)

   elseif text:find('^%{', start) then
      return grok_object(self, text, start, options)

   elseif text:find('^%[', start) then
      return grok_array(self, text, start, options)

   elseif text:find('^true', start) then
      return true, start + 4

   elseif text:find('^false', start) then
      return false, start + 5

   elseif text:find('^null', start) then
      return options.null, start + 4

   else
      self:onDecodeError("can't parse JSON", text, start, options.etc)
      return nil, 1
   end
end

function lib:decode(text, etc, options)
   if type(options) ~= 'table' then
      options = {}
   end
   if etc ~= nil then
      options.etc = etc
   end

   if type(self) ~= 'table' or self.__index ~= lib then
      local error_message = "JSON:decode must be called in method format"
      lib:onDecodeError(error_message, nil, nil, options.etc)
      return nil, error_message
   end

   if text == nil then
      local error_message = "nil passed to JSON:decode()"
      self:onDecodeOfNilError(error_message, nil, nil, options.etc)
      return nil, error_message

   elseif type(text) ~= 'string' then
      local error_message = "expected string argument to JSON:decode()"
      self:onDecodeError(string.format("%s, got %s", error_message, type(text)), nil, nil, options.etc)
      return nil, error_message
   end

   if text:match('^%s*$') then
      return nil
   end

   if text:match('^%s*<') then
      local error_message = "HTML passed to JSON:decode()"
      self:onDecodeOfHTMLError(error_message, text, nil, options.etc)
      return nil, error_message
   end

   if text:sub(1,1):byte() == 0 or (text:len() >= 2 and text:sub(2,2):byte() == 0) then
      local error_message = "JSON package groks only UTF-8, sorry"
      self:onDecodeError(error_message, text, nil, options.etc)
      return nil, error_message
   end

   if options.decodeNumbersAsObjects == nil then
      options.decodeNumbersAsObjects = self.decodeNumbersAsObjects
   end
   if options.decodeIntegerObjectificationLength == nil then
      options.decodeIntegerObjectificationLength = self.decodeIntegerObjectificationLength
   end
   if options.decodeDecimalObjectificationLength == nil then
      options.decodeDecimalObjectificationLength = self.decodeDecimalObjectificationLength
   end
   if options.decodeIntegerStringificationLength == nil then
      options.decodeIntegerStringificationLength = self.decodeIntegerStringificationLength
   end
   if options.decodeDecimalStringificationLength == nil then
      options.decodeDecimalStringificationLength = self.decodeDecimalStringificationLength
   end

   local success, value, next_i = pcall(grok_one, self, text, 1, options)

   if success then

      local error_message = nil
      if next_i ~= #text + 1 then
         next_i = skip_whitespace(text, next_i)

         if next_i ~= #text + 1 then
            value, error_message = self:onTrailingGarbage(text, next_i, value, options.etc)
         end
      end
      return value, error_message

   else

      local error_message = value
      if self.assert then
         self.assert(false, error_message)
      else
         assert(false, error_message)
      end
      return nil, error_message

   end
end

local function backslash_replacement_function(c)
   if c == "\n" then
      return "\\n"
   elseif c == "\r" then
      return "\\r"
   elseif c == "\t" then
      return "\\t"
   elseif c == "\b" then
      return "\\b"
   elseif c == "\f" then
      return "\\f"
   elseif c == '"' then
      return '\\"'
   elseif c == '\\' then
      return '\\\\'
   else
      return string.format("\\u%04x", c:byte())
   end
end

local chars_to_be_escaped_in_JSON_string
   = '['
   ..    '"'    -- class sub-pattern to match a double quote
   ..    '%\\'  -- class sub-pattern to match a backslash
   ..    '%z'   -- class sub-pattern to match a null
   ..    '\001' .. '-' .. '\031' -- class sub-pattern to match control characters
   .. ']'


local LINE_SEPARATOR_as_utf8      = unicode_codepoint_as_utf8(0x2028)
local PARAGRAPH_SEPARATOR_as_utf8 = unicode_codepoint_as_utf8(0x2029)
local function json_string_literal(value, options)
   local newval = value:gsub(chars_to_be_escaped_in_JSON_string, backslash_replacement_function)
   if options.stringsAreUtf8 then
      newval = newval:gsub(LINE_SEPARATOR_as_utf8, '\\u2028'):gsub(PARAGRAPH_SEPARATOR_as_utf8,'\\u2029')
   end
   return '"' .. newval .. '"'
end

local function object_or_array(self, T, etc)
   local string_keys = { }
   local number_keys = { }
   local number_keys_must_be_strings = false
   local maximum_number_key

   for key in pairs(T) do
      if type(key) == 'string' then
         table.insert(string_keys, key)
      elseif type(key) == 'number' then
         table.insert(number_keys, key)
         if key <= 0 or key >= math.huge then
            number_keys_must_be_strings = true
         elseif not maximum_number_key or key > maximum_number_key then
            maximum_number_key = key
         end
      elseif type(key) == 'boolean' then
         table.insert(string_keys, tostring(key))
      else
         self:onEncodeError("can't encode table with a key of type " .. type(key), etc)
      end
   end

   if #string_keys == 0 and not number_keys_must_be_strings then
      if #number_keys > 0 then
         return nil, maximum_number_key -- an array
      elseif tostring(T) == "JSON array" then
         return nil
      elseif tostring(T) == "JSON object" then
         return { }
      else
         return nil
      end
   end

   table.sort(string_keys)

   local map
   if #number_keys > 0 then
      if self.noKeyConversion then
         self:onEncodeError("a table with both numeric and string keys could be an object or array; aborting", etc)
      end
      map = { }
      for key, val in pairs(T) do
         map[key] = val
      end

      table.sort(number_keys)
      for _, number_key in ipairs(number_keys) do
         local string_key = tostring(number_key)
         if map[string_key] == nil then
            table.insert(string_keys , string_key)
            map[string_key] = T[number_key]
         else
            self:onEncodeError("conflict converting table with mixed-type keys into a JSON object: key " .. number_key .. " exists both as a string and a number.", etc)
         end
      end
   end

   return string_keys, nil, map
end

local function encode_value(self, value, parents, etc, options, indent, for_key)
   if value == nil or (not for_key and options and options.null and value == options.null) then
      return 'null'

   elseif type(value) == 'string' then
      return json_string_literal(value, options)

   elseif type(value) == 'number' then
      if value ~= value then
         return "null"
      elseif value >= math.huge then
         return "1e+9999"
      elseif value <= -math.huge then
         return "-1e+9999"
      else
         return tostring(value)
      end

   elseif type(value) == 'boolean' then
      return tostring(value)

   elseif type(value) ~= 'table' then

      if self.unsupportedTypeEncoder then
         local user_value, user_error = self:unsupportedTypeEncoder(value, parents, etc, options, indent, for_key)
         if type(user_value) == 'string' then
            return user_value
         elseif user_value ~= nil then
            self:onEncodeError("unsupportedTypeEncoder method returned a " .. type(user_value), etc)
         elseif user_error then
            self:onEncodeError(tostring(user_error), etc)
         end
      end

      self:onEncodeError("can't convert " .. type(value) .. " to JSON", etc)

   elseif getmetatable(value) == isNumber then
      return tostring(value)
   else
      local T = value

      if type(options) ~= 'table' then
         options = {}
      end
      if type(indent) ~= 'string' then
         indent = ""
      end

      if parents[T] then
         self:onEncodeError("table " .. tostring(T) .. " is a child of itself", etc)
      else
         parents[T] = true
      end

      local result_value

      local object_keys, maximum_number_key, map = object_or_array(self, T, etc)
      if maximum_number_key then
         local key_indent
         if options.array_newline then
            key_indent = indent .. tostring(options.indent or "")
         else
            key_indent = indent
         end

         local ITEMS = { }
         for i = 1, maximum_number_key do
            table.insert(ITEMS, encode_value(self, T[i], parents, etc, options, key_indent))
         end

         if options.array_newline then
            result_value = "[\n" .. key_indent .. table.concat(ITEMS, ",\n" .. key_indent) .. "\n" .. indent .. "]"
         elseif options.pretty then
            result_value = "[ " .. table.concat(ITEMS, ", ") .. " ]"
         else
            result_value = "["  .. table.concat(ITEMS, ",")  .. "]"
         end

      elseif object_keys then
         local TT = map or T

         if options.pretty then

            local KEYS = { }
            local max_key_length = 0
            for _, key in ipairs(object_keys) do
               local encoded = encode_value(self, tostring(key), parents, etc, options, indent, true)
               if options.align_keys then
                  max_key_length = math.max(max_key_length, #encoded)
               end
               table.insert(KEYS, encoded)
            end
            local key_indent = indent .. tostring(options.indent or "")
            local subtable_indent = key_indent .. string.rep(" ", max_key_length) .. (options.align_keys and "  " or "")
            local FORMAT = "%s%" .. string.format("%d", max_key_length) .. "s: %s"

            local COMBINED_PARTS = { }
            for i, key in ipairs(object_keys) do
               local encoded_val = encode_value(self, TT[key], parents, etc, options, subtable_indent)
               table.insert(COMBINED_PARTS, string.format(FORMAT, key_indent, KEYS[i], encoded_val))
            end
            result_value = "{\n" .. table.concat(COMBINED_PARTS, ",\n") .. "\n" .. indent .. "}"

         else

            local PARTS = { }
            for _, key in ipairs(object_keys) do
               local encoded_val = encode_value(self, TT[key],       parents, etc, options, indent)
               local encoded_key = encode_value(self, tostring(key), parents, etc, options, indent, true)
               table.insert(PARTS, string.format("%s:%s", encoded_key, encoded_val))
            end
            result_value = "{" .. table.concat(PARTS, ",") .. "}"

         end
      else
         result_value = "[]"
      end

      parents[T] = false
      return result_value
   end
end

local function top_level_encode(self, value, etc, options)
   local val = encode_value(self, value, {}, etc, options)
   if val == nil then
      return val
   else
      return val
   end
end

function lib:encode(value, etc, options)
   if type(self) ~= 'table' or self.__index ~= lib then
      lib:onEncodeError("JSON:encode must be called in method format", etc)
   end

   if type(options) ~= 'table' then
      options = {}
   end

   return top_level_encode(self, value, etc, options)
end

function lib:encode_pretty(value, etc, options)
   if type(self) ~= 'table' or self.__index ~= lib then
      lib:onEncodeError("JSON:encode_pretty must be called in method format", etc)
   end
   if type(options) ~= 'table' then
      options = default_pretty_options
   end

   return top_level_encode(self, value, etc, options)
end

function lib.__tostring()
   return "JSON encode/decode package"
end

lib.__index = lib

function lib:new(args)
   local new = { }

   if args then
      for key, val in pairs(args) do
         new[key] = val
      end
   end

   return setmetatable(new, lib)
end
