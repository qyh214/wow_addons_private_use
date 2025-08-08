---@class Private
local Private = select(2, ...)

---@class BitDecoder
local BitDecoder = {}

---@class ParseState
---@field content string Binary contents (not safe to print!)
---@field position number

---decode an integer from the contents of the ParseState
---@param state ParseState mutated
---@param byteCount number
---@return number, ParseState
function BitDecoder.decodeInteger(state, byteCount)
	assert(string.len(state.content) >= state.position + byteCount - 1)
	local result = 0
	local base = 1
	while byteCount > 0 do
		result = result + base * string.byte(state.content, state.position)
		byteCount = byteCount - 1
		state.position = state.position + 1
		base = base * 256
	end
	return result, state
end

---decode a fixed-precision float from the data
---@param state ParseState
---@param beforeByteCount number
---@param afterByteCount number
---@return number, ParseState
function BitDecoder.decodeFixedFloat(state, beforeByteCount, afterByteCount)
	assert(string.len(state.content) >= state.position + beforeByteCount + afterByteCount - 1)
	local result, float_part
	result, state = BitDecoder.decodeInteger(state, beforeByteCount)
	float_part, state = BitDecoder.decodeInteger(state, afterByteCount)

	result = result + (float_part / 256 ^ afterByteCount)
	return result, state
end

---decode a fixed-precision percentile value
---@param state ParseState
---@return number, ParseState
function BitDecoder.decodePercentileFixed(state)
	local value, newState = BitDecoder.decodeInteger(state, 2)
	return value / 100, newState
end

---@param state ParseState
---@param lookup table<number, string>
---@return string, ParseState
function BitDecoder.decodeString(state, lookup)
	local index
	index, state = BitDecoder.decodeInteger(state, 2)

	-- check for inline strings
	if index == 0 then
		local length
		length, state = BitDecoder.decodeInteger(state, 1)
		local str = string.sub(state.content, state.position, state.position + length - 1)
		state.position = state.position + length
		return str, state
	end

	return lookup[index], state
end

---@param state ParseState
---@return boolean, ParseState
function BitDecoder.decodeBoolean(state)
	local result, newState = BitDecoder.decodeInteger(state, 1)
	return result == 1, newState
end

Private.BitDecoder = BitDecoder
