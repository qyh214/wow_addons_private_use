local addonName, addonTable = ...
local AntiSilence = CreateFrame("Frame")
local debug = false

-- 关键字列表
local keywordsType1 = {"公会YY", "工会YY", "局长", "微信", "gm",  "自杀",  "自焚", "8500", "89", "傻子", "GCD", "共CD", "BL", "狗贼", "憨批","kook","cao" ,"巨乳"}
local keywordsType2 = {"gay", "屌", "二奶", "脑残", "干死", "文革", "菜逼", "sb", "傻批", "叼毛", "傻逼", "傻B", "我日", "白痴", "蠢货", "废物", "狗东西", "你妈", "我草", "我操", "死妈", "艹你", "草的你", "你大爷", "操他" , "他妈", "妈的", "tmd", "jb", "j8", "寄吧", "几把", "鸡吧", "妈逼", "草拟吗","草泥马","国军","操死"}

if debug then
    for _, keyword in ipairs(keywordsType2) do
        table.insert(keywordsType1, keyword)
    end
end

-- UTF-8字符模式
local utf8_char_pattern = "[%z\1-\127\194-\244][\128-\191]*"

-- 提取物品链接函数
local function extractItemLinks(message)
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
    return message:gsub("(\124LINK%d+\124)", function(placeholder)
        local index = tonumber(placeholder:match("\124LINK(%d+)\124"))
        return links[index]
    end)
end

-- 替换函数
local function replaceKeywords(message)
    -- local startTime = debugprofilestop()  -- 记录开始时间
    local hasKeyword = false

    -- 处理类型1的关键字（多字打码）
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
        local keywordPattern = keyword:gsub("([^%w])", "%%%1")  -- 转义关键字中的特殊字符
        message = message:gsub("(%w-)"..keyword:lower().."(%w-)", "*哔*")
        message = message:gsub("(%w-)"..keyword:upper().."(%w-)", "*哔*")
    end

    -- local endTime = debugprofilestop()  -- 记录结束时间
    -- print("replaceKeywords execution time: " .. (endTime - startTime) .. "ms")

    return message
end

-- 发送消息钩子函数
local function SendChatMessageHook(message, chatType, language, channel, target, ...)
    local messageWithoutLinks, links = extractItemLinks(message)
    local newMessage = replaceKeywords(messageWithoutLinks)
    newMessage = restoreItemLinks(newMessage, links)
    return newMessage, chatType, language, channel, target, ...
end

-- 钩住 SendChatMessage 函数
local originalSendChatMessage = SendChatMessage
SendChatMessage = function(message, chatType, language, channel, target, ...)
    local success, newMessage, newChatType, newLanguage, newChannel, newTarget = pcall(SendChatMessageHook, message, chatType, language, channel, target)
    if success then
        originalSendChatMessage(newMessage, newChatType, newLanguage, newChannel, newTarget, ...)
    else
        originalSendChatMessage(message, chatType, language, channel, target, ...)
    end
end

-- 钩住 BNSendWhisper 函数
local originalBNSendWhisper = BNSendWhisper
BNSendWhisper = function(target, message, ...)
    local messageWithoutLinks, links = extractItemLinks(message)
    local success, newMessage = pcall(replaceKeywords, messageWithoutLinks)
    if success then
        newMessage = restoreItemLinks(newMessage, links)
        originalBNSendWhisper(target, newMessage, ...)
    else
        originalBNSendWhisper(target, message, ...)
    end
end

-- 初始化插件
local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print("AntiSilence反和谐已加载")
    end
end

AntiSilence:SetScript("OnEvent", OnEvent)
AntiSilence:RegisterEvent("PLAYER_LOGIN")