local bit = bit

-- CRC32 表（预计算）
local crc32_table = {}
for i = 0, 255 do
    local crc = i
    for j = 1, 8 do
        crc = bit.band(bit.rshift(crc, 1), 0x7FFFFFFF)
        if bit.band(crc, 1) ~= 0 then
            crc = bit.bxor(crc, 0xEDB88320)
        end
    end
    crc32_table[i] = crc
end

-- CRC32 计算函数
function NewBeeHash32(input)
    local crc = 0xFFFFFFFF
    for i = 1, #input do
        local byte = input:byte(i)
        crc = bit.bxor(bit.rshift(crc, 8), crc32_table[bit.bxor(bit.band(crc, 0xFF), byte)])
    end
    return string.format("%08x",bit.bxor(crc, 0xFFFFFFFF))
end

-- FNV-1a 32位哈希算法实现
function NewBeeHash32(input)
    local hash = 0x811C9DC5 -- FNV偏移基础值
    for i = 1, #input do
        local byte = input:byte(i)
        hash = bit.bxor(hash, byte)
        hash = bit.band(hash * 0x01000193, 0xFFFFFFFF)
    end
    return string.format("%08x", hash)
end