local addonName, addonTable = ...
local AntiSilence = CreateFrame("Frame")
local debug = false

-- 关键字列表 K1干扰 K2哔
local keywordsType1 = {"公会YY","工会YY","局长","微信","自杀","GCD","共CD","wcl","打炮","二奶","脑残","8500","gm","菜逼","白痴","废物"}
local keywordsType2 = {"煞笔","gay","屌","狗贼","憨批","傻子","干死","文革","sb","傻批","叼毛","傻逼","傻B","我日","蠢货","狗东西","你妈","我草", "我操","死妈","艹你","草的你","你大爷","操他","他妈","妈的","tmd","鸡吧","鸡巴","妈逼","国军"}

if debug then
    for _, keyword in ipairs(keywordsType2) do
        table.insert(keywordsType1, keyword)
    end
end

-- UTF-8字符模式
local utf8_char_pattern = "[%z\1-\127\194-\244][\128-\191]*"

-- 将任意入参安全转为字符串（仅当其不是字符串时）
local function toSafeString(v)
    if type(v) == "string" then return v end
    if v == nil then return "" end
    return tostring(v)
end

-- 提取物品链接函数（要求传入字符串）
local function extractItemLinks(message)
    if type(message) ~= "string" or message == "" then
        return toSafeString(message), {} -- 兜底返回
    end
    local links = {}
    local index = 1
    message = message:gsub("(\124c.-\124r)", function(link)
        links[index] = link
        local placeholder = "\124LINK" .. index .. "\124"
        index = index + 1
        return placeholder
    end)
    return message, links
end

-- 恢复物品链接函数
local function restoreItemLinks(message, links)
    message = toSafeString(message)
    return message:gsub("(\124LINK%d+\124)", function(placeholder)
        local index = tonumber(placeholder:match("\124LINK(%d+)\124"))
        return links[index]
    end)
end

-- 替换函数（对非字符串直接原样返回）
local function replaceKeywords(message)
    if type(message) ~= "string" or message == "" then
        return toSafeString(message)
    end

    local hasKeyword = false

    -- 处理类型1的关键字
    for _, keyword in ipairs(keywordsType1) do
        if message:lower():find(keyword:lower(), 1, true) then
            hasKeyword = true
            break
        end
    end

    if hasKeyword then
        for _, keyword in ipairs(keywordsType1) do
            local pattern = keyword:gsub("%a", function(c)
                return string.format("[%s%s]", string.lower(c), string.upper(c))
            end)
            local replacement = keyword:gsub(utf8_char_pattern, "%1丶")
            message = message:gsub(pattern, replacement)
        end
    end

    -- 处理类型2的关键字（单字替换）
    for _, keyword in ipairs(keywordsType2) do
        message = message:gsub("(%w-)"..keyword:lower().."(%w-)", "*哔*")
        message = message:gsub("(%w-)"..keyword:upper().."(%w-)", "*哔*")
    end

    return message
end

-- 仅钩住 C_ChatInfo.SendChatMessage
if C_ChatInfo and type(C_ChatInfo.SendChatMessage) == "function" then
    local originalC_SendChatMessage = C_ChatInfo.SendChatMessage
    C_ChatInfo.SendChatMessage = function(message, chatType, language, target, ...)
        -- 先把 message 安全转为字符串（处理 BigWigs 等传数字的情况）
        local msgStr = toSafeString(message)
        local messageWithoutLinks, links = extractItemLinks(msgStr)
        local ok, newMessage = pcall(replaceKeywords, messageWithoutLinks)
        if ok then
            newMessage = restoreItemLinks(newMessage, links)
            return originalC_SendChatMessage(newMessage, chatType, language, target, ...)
        else
            -- 出错就走原消息（已是字符串）
            return originalC_SendChatMessage(msgStr, chatType, language, target, ...)
        end
    end
end

-- 钩住 BNSendWhisper 函数
if type(BNSendWhisper) == "function" then
    local originalBNSendWhisper = BNSendWhisper
    BNSendWhisper = function(target, message, ...)
        local msgStr = toSafeString(message)
        local messageWithoutLinks, links = extractItemLinks(msgStr)
        local ok, newMessage = pcall(replaceKeywords, messageWithoutLinks)
        if ok then
            newMessage = restoreItemLinks(newMessage, links)
            return originalBNSendWhisper(target, newMessage, ...)
        else
            return originalBNSendWhisper(target, msgStr, ...)
        end
    end
end

-- 初始化插件
local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
--        print("插件已加载")
    end
end

AntiSilence:SetScript("OnEvent", OnEvent)
AntiSilence:RegisterEvent("PLAYER_LOGIN")
