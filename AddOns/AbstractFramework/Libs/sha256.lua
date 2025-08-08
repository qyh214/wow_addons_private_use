-------------------------------------------------
-- https://github.com/OGabrieLima
-- compatible with WoW Lua
-- edit by enderneko
-- 2025-04-15
-------------------------------------------------
local MAJOR_VERSION = "AF_SHA256"
local MINOR_VERSION = 1
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

--[[
  Author: OGabrieLima
  GitHub: https://github.com/OGabrieLima
  Discord: ogabrielima
  Description: This is a Lua script that implements the SHA-256 algorithm to calculate the hash of a message.
               It includes a helper function for right rotation (bitwise) and the main function `sha256`.
               The `sha256` function can be used to calculate the SHA-256 hash of a message.
  Creation Date: 2024-04-08
]]

local band = bit.band
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift
local bxor = bit.bxor
local bnot = bit.bnot

local char = string.char
local byte = string.byte
local rep = string.rep
local format = string.format

local insert = table.insert
local unpack = unpack

-- Auxiliary function: right rotation (bitwise)
local function bit_ror(x, y)
    return band(bor(rshift(x, y), lshift(x, (32 - y))), 0xFFFFFFFF)
end

-- Main function: SHA256
lib.hash = function(message)
    message = tostring(message)

    local k = {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    }

    local function preprocess(message)
        local len = #message
        -- 长度以位为单位，但确保不会造成精度问题（Lua的数字是双精度浮点）
        local bitLen = len * 8
        message = message .. "\128" -- 附加一个 '1' 位

        -- 计算需要填充的0的数量，需要保证总长度对64字节对齐，并留8字节给长度
        local zeroPad = (56 - (len + 1) % 64) % 64
        message = message .. rep("\0", zeroPad)

        -- 附加原始消息长度（以位为单位），以大端序表示的64位长度
        -- 对于大多数情况，高32位都是0（因为Lua字符串长度通常不会超过 2^29）
        message = message .. char(0, 0, 0, 0) -- 高32位填0

        -- 低32位表示消息长度
        message = message .. char(
            band(rshift(bitLen, 24), 0xFF),
            band(rshift(bitLen, 16), 0xFF),
            band(rshift(bitLen, 8), 0xFF),
            band(bitLen, 0xFF)
        )

        return message
    end

    local function chunkify(message)
        local chunks = {}
        for i = 1, #message, 64 do
            insert(chunks, message:sub(i, i + 63))
        end
        return chunks
    end

    local function processChunk(chunk, hash)
        local w = {}

        -- 从块中提取字（以大端序）
        for i = 1, 16 do
            local j = (i - 1) * 4 + 1
            w[i] = bor(
                lshift(byte(chunk, j), 24),
                lshift(byte(chunk, j + 1), 16),
                lshift(byte(chunk, j + 2), 8),
                byte(chunk, j + 3)
            )
        end

        -- 扩展消息调度表
        for i = 17, 64 do
            local s0 = bxor(bit_ror(w[i - 15], 7), bxor(bit_ror(w[i - 15], 18), rshift(w[i - 15], 3)))
            local s1 = bxor(bit_ror(w[i - 2], 17), bxor(bit_ror(w[i - 2], 19), rshift(w[i - 2], 10)))
            w[i] = band((w[i - 16] + s0 + w[i - 7] + s1), 0xFFFFFFFF)
        end

        local a, b, c, d, e, f, g, h = unpack(hash)

        -- 主循环
        for i = 1, 64 do
            local S1 = bxor(bit_ror(e, 6), bxor(bit_ror(e, 11), bit_ror(e, 25)))
            local ch = bxor(band(e, f), band(bnot(e), g))
            local temp1 = band((h + S1 + ch + k[i] + w[i]), 0xFFFFFFFF)
            local S0 = bxor(bit_ror(a, 2), bxor(bit_ror(a, 13), bit_ror(a, 22)))
            local maj = bxor(band(a, b), bxor(band(a, c), band(b, c)))
            local temp2 = band((S0 + maj), 0xFFFFFFFF)

            h = g
            g = f
            f = e
            e = band((d + temp1), 0xFFFFFFFF)
            d = c
            c = b
            b = a
            a = band((temp1 + temp2), 0xFFFFFFFF)
        end

        -- 更新哈希状态
        hash[1] = band((hash[1] + a), 0xFFFFFFFF)
        hash[2] = band((hash[2] + b), 0xFFFFFFFF)
        hash[3] = band((hash[3] + c), 0xFFFFFFFF)
        hash[4] = band((hash[4] + d), 0xFFFFFFFF)
        hash[5] = band((hash[5] + e), 0xFFFFFFFF)
        hash[6] = band((hash[6] + f), 0xFFFFFFFF)
        hash[7] = band((hash[7] + g), 0xFFFFFFFF)
        hash[8] = band((hash[8] + h), 0xFFFFFFFF)

        return hash
    end

    message = preprocess(message)
    local chunks = chunkify(message)

    local hash = {0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19}

    for _, chunk in ipairs(chunks) do
        hash = processChunk(chunk, hash)
    end

    local result = ""
    for _, h in ipairs(hash) do
        result = result .. format("%08x", h)
    end

    return result
end