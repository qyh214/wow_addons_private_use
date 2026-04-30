-- =============================================================
-- [[ 聊天频道快捷栏 ]]
-- { Key = "ExTools.ChatChannelBar", Name = "聊天频道快捷栏", Desc = "快速切换聊天频道的工具栏", Category = 1 },
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExTools.ChatChannelBar"

-- 全局函数引用
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local C_Timer = _G.C_Timer
local wipe = _G.wipe
local ChatEdit_ChooseBoxForSend = _G.ChatEdit_ChooseBoxForSend
local ChatEdit_SendText = _G.ChatEdit_SendText
local ChatEdit_ActivateChat = _G.ChatEdit_ActivateChat
local ChatFrame_OpenChat = _G.ChatFrame_OpenChat
local GetChannelName = _G.GetChannelName
local SlashCmdList = _G.SlashCmdList

-- =============================================================
-- Grid 布局定义
-- =============================================================
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 2, y = 1, w = 50, h = 2, label = L["聊天频道快捷栏"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 50, h = 2, label = L["快速切换聊天频道的工具栏，每个频道可自定义显示名称、颜色和指令"] },

        { key = "div1", type = "divider", x = 2, y = 7, w = 50, h = 1 },

        -- 基础设置
        { key = "subheader_basic", type = "subheader", x = 2, y = 6, w = 50, h = 1, label = L["基础设置"], labelSize = 20 },
        { key = "locked", type = "checkbox", x = 2, y = 8, w = 8, h = 2, label = L["锁定位置"] },
        { key = "btn_reset_pos", type = "button", x = 12, y = 8, w = 12, h = 2, label = L["重置位置"] },

        { key = "fontSize", type = "slider", x = 2, y = 11, w = 16, h = 2, label = L["字体大小"], min = 10, max = 30, step = 1 },
        { key = "buttonPadding", type = "slider", x = 20, y = 11, w = 16, h = 2, label = L["按钮间距"], min = 0, max = 20, step = 1 },
        { key = "buttonSize", type = "slider", x = 38, y = 11, w = 16, h = 2, label = L["按钮大小"], min = 20, max = 50, step = 1 },

        { key = "fontOutline", type = "dropdown", x = 2, y = 14, w = 16, h = 2, label = L["描边"], items = "无,OUTLINE,THICKOUTLINE" },
        { key = "anchorMode", type = "dropdown", x = 20, y = 14, w = 18, h = 2, label = L["依附目标"], items = "不吸附,暴雪(ChatFrame1),Chattynator,ElvUI" },

        { key = "div2", type = "divider", x = 2, y = 17, w = 50, h = 1 },

        -- 频道设置 (每个频道一行：启用、颜色、改名、指令)
        { key = "channels_header", type = "header", x = 2, y = 18, w = 50, h = 2, label = L["频道设置"], labelSize = 20 },

        -- 世界频道
        { key = "show_world", type = "checkbox", x = 2, y = 21, w = 8, h = 2, label = L["世界"] },
        { key = "world", type = "color", x = 11, y = 21, w = 12, h = 2, label = L["颜色"] },
        { key = "world_name", type = "input", x = 24, y = 21, w = 10, h = 2, label = L["改名"], placeholder = L["世"] },
        { key = "world_channel", type = "input", x = 35, y = 21, w = 17, h = 2, label = L["指令"], placeholder = "大脚世界频道" },

        -- 说话频道
        { key = "show_say", type = "checkbox", x = 2, y = 24, w = 8, h = 2, label = L["说话"] },
        { key = "say", type = "color", x = 11, y = 24, w = 12, h = 2, label = L["颜色"] },
        { key = "say_name", type = "input", x = 24, y = 24, w = 10, h = 2, label = L["改名"], placeholder = L["说"] },
        { key = "say_channel", type = "input", x = 35, y = 24, w = 17, h = 2, label = L["指令"], placeholder = "/s" },

        -- 喊话频道
        { key = "show_yell", type = "checkbox", x = 2, y = 27, w = 8, h = 2, label = L["喊话"] },
        { key = "yell", type = "color", x = 11, y = 27, w = 12, h = 2, label = L["颜色"] },
        { key = "yell_name", type = "input", x = 24, y = 27, w = 10, h = 2, label = L["改名"], placeholder = L["喊"] },
        { key = "yell_channel", type = "input", x = 35, y = 27, w = 17, h = 2, label = L["指令"], placeholder = "/y" },

        -- 队伍频道
        { key = "show_party", type = "checkbox", x = 2, y = 30, w = 8, h = 2, label = L["队伍"] },
        { key = "party", type = "color", x = 11, y = 30, w = 12, h = 2, label = L["颜色"] },
        { key = "party_name", type = "input", x = 24, y = 30, w = 10, h = 2, label = L["改名"], placeholder = L["队"] },
        { key = "party_channel", type = "input", x = 35, y = 30, w = 17, h = 2, label = L["指令"], placeholder = "/p" },

        -- 公会频道
        { key = "show_guild", type = "checkbox", x = 2, y = 33, w = 8, h = 2, label = L["公会"] },
        { key = "guild", type = "color", x = 11, y = 33, w = 12, h = 2, label = L["颜色"] },
        { key = "guild_name", type = "input", x = 24, y = 33, w = 10, h = 2, label = L["改名"], placeholder = L["会"] },
        { key = "guild_channel", type = "input", x = 35, y = 33, w = 17, h = 2, label = L["指令"], placeholder = "/g" },

        -- 副本频道
        { key = "show_instance", type = "checkbox", x = 2, y = 36, w = 8, h = 2, label = L["副本"] },
        { key = "instance", type = "color", x = 11, y = 36, w = 12, h = 2, label = L["颜色"] },
        { key = "instance_name", type = "input", x = 24, y = 36, w = 10, h = 2, label = L["改名"], placeholder = L["副"] },
        { key = "instance_channel", type = "input", x = 35, y = 36, w = 17, h = 2, label = L["指令"], placeholder = "/i" },

        -- 团队频道
        { key = "show_raid", type = "checkbox", x = 2, y = 39, w = 8, h = 2, label = L["团队"] },
        { key = "raid", type = "color", x = 11, y = 39, w = 12, h = 2, label = L["颜色"] },
        { key = "raid_name", type = "input", x = 24, y = 39, w = 10, h = 2, label = L["改名"], placeholder = L["团"] },
        { key = "raid_channel", type = "input", x = 35, y = 39, w = 17, h = 2, label = L["指令"], placeholder = "/raid" },

        -- 骰子
        { key = "show_roll", type = "checkbox", x = 2, y = 42, w = 8, h = 2, label = L["骰子"] },
        { key = "roll", type = "color", x = 11, y = 42, w = 12, h = 2, label = L["颜色"] },
        { key = "roll_name", type = "input", x = 24, y = 42, w = 10, h = 2, label = L["改名"], placeholder = L["骰"] },
        { key = "roll_channel", type = "input", x = 35, y = 42, w = 17, h = 2, label = L["指令"], placeholder = "/roll" },

        -- 确认检查
        { key = "show_rc", type = "checkbox", x = 2, y = 45, w = 8, h = 2, label = L["确认"] },
        { key = "rc", type = "color", x = 11, y = 45, w = 12, h = 2, label = L["颜色"] },
        { key = "rc_name", type = "input", x = 24, y = 45, w = 10, h = 2, label = L["改名"], placeholder = L["确"] },
        { key = "rc_channel", type = "input", x = 35, y = 45, w = 17, h = 2, label = L["指令"], placeholder = "/rc" },

        -- 倒数开怪
        { key = "show_pull", type = "checkbox", x = 2, y = 48, w = 8, h = 2, label = L["倒数"] },
        { key = "pull", type = "color", x = 11, y = 48, w = 12, h = 2, label = L["颜色"] },
        { key = "pull_name", type = "input", x = 24, y = 48, w = 10, h = 2, label = L["改名"], placeholder = L["倒"] },
        { key = "pull_channel", type = "input", x = 35, y = 48, w = 17, h = 2, label = L["指令"], placeholder = "/cd 10" },

        -- 自定义频道 1
        { key = "show_custom1", type = "checkbox", x = 2, y = 51, w = 8, h = 2, label = L["自定义1"] },
        { key = "custom1", type = "color", x = 11, y = 51, w = 12, h = 2, label = L["颜色"] },
        { key = "custom1_name", type = "input", x = 24, y = 51, w = 10, h = 2, label = L["改名"], placeholder = L["自1"] },
        { key = "custom1_channel", type = "input", x = 35, y = 51, w = 17, h = 2, label = L["指令"], placeholder = "/MDT" },

        -- 自定义频道 2
        { key = "show_custom2", type = "checkbox", x = 2, y = 54, w = 8, h = 2, label = L["自定义2"] },
        { key = "custom2", type = "color", x = 11, y = 54, w = 12, h = 2, label = L["颜色"] },
        { key = "custom2_name", type = "input", x = 24, y = 54, w = 10, h = 2, label = L["改名"], placeholder = L["自2"] },
        { key = "custom2_channel", type = "input", x = 35, y = 54, w = 17, h = 2, label = L["指令"], placeholder = "/DBM" },

        -- 自定义频道 3
        { key = "show_custom3", type = "checkbox", x = 2, y = 57, w = 8, h = 2, label = L["自定义3"] },
        { key = "custom3", type = "color", x = 11, y = 57, w = 12, h = 2, label = L["颜色"] },
        { key = "custom3_name", type = "input", x = 24, y = 57, w = 10, h = 2, label = L["改名"], placeholder = L["自3"] },
        { key = "custom3_channel", type = "input", x = 35, y = 57, w = 17, h = 2, label = L["指令"], placeholder = "/WA" },
    }

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

-- =============================================================
-- 载入检查
-- =============================================================
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- =============================================================
-- 默认配置
-- =============================================================
local EX_DEFAULTS = {
    enabled = true,
    locked = true,
    fontSize = 16,
    buttonPadding = 3,
    buttonSize = 30,
    fontOutline = "OUTLINE",
    anchorMode = "不吸附",
    posX2 = 46,
    posY2 = 207,
    offsetX = 0,
    offsetY = 30,

    -- 频道显示开关和颜色
    show_world = true,
    worldR = 1,
    worldG = 0.5,
    worldB = 0.5,
    worldA = 1,
    world_name = "",
    world_channel = "大脚世界频道",

    show_say = true,
    sayR = 1,
    sayG = 1,
    sayB = 1,
    sayA = 1,
    say_name = "",
    say_channel = "/s",

    show_yell = true,
    yellR = 1,
    yellG = 0.25,
    yellB = 0.25,
    yellA = 1,
    yell_name = "",
    yell_channel = "/y",

    show_party = true,
    partyR = 0.67,
    partyG = 0.67,
    partyB = 1,
    partyA = 1,
    party_name = "",
    party_channel = "/p",

    show_guild = true,
    guildR = 0.25,
    guildG = 1,
    guildB = 0.25,
    guildA = 1,
    guild_name = "",
    guild_channel = "/g",

    show_instance = true,
    instanceR = 1,
    instanceG = 0.5,
    instanceB = 0,
    instanceA = 1,
    instance_name = "",
    instance_channel = "/i",

    show_raid = true,
    raidR = 1,
    raidG = 0.5,
    raidB = 0,
    raidA = 1,
    raid_name = "",
    raid_channel = "/raid",

    show_roll = true,
    rollR = 1,
    rollG = 1,
    rollB = 0,
    rollA = 1,
    roll_name = "",
    roll_channel = "/roll",

    show_rc = true,
    rcR = 0,
    rcG = 1,
    rcB = 1,
    rcA = 1,
    rc_name = "",
    rc_channel = "/rc",

    show_pull = true,
    pullR = 1,
    pullG = 0,
    pullB = 1,
    pullA = 1,
    pull_name = "",
    pull_channel = "/cd 10",

    show_custom1 = false,
    custom1R = 1,
    custom1G = 1,
    custom1B = 1,
    custom1A = 1,
    custom1_name = "",
    custom1_channel = "/MDT",

    show_custom2 = false,
    custom2R = 1,
    custom2G = 1,
    custom2B = 1,
    custom2A = 1,
    custom2_name = "",
    custom2_channel = "/DBM",

    show_custom3 = false,
    custom3R = 1,
    custom3G = 1,
    custom3B = 1,
    custom3A = 1,
    custom3_name = "",
    custom3_channel = "/WA",
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)
local isEditModeActive = false
local isEditModeVisible = true
local editModeRestoreLocked = nil

-- =============================================================
-- 频道配置
-- =============================================================
local CHANNELS = {
    { id = "world", name = L["世"], command = "/1", isWorld = true, chatType = nil },
    { id = "say", name = L["说"], command = "/s", chatType = "SAY" },
    { id = "yell", name = L["喊"], command = "/y", chatType = "YELL" },
    { id = "party", name = L["队"], command = "/p", chatType = "PARTY" },
    { id = "guild", name = L["会"], command = "/g", chatType = "GUILD" },
    { id = "instance", name = L["副"], command = "/i", chatType = "INSTANCE_CHAT" },
    { id = "raid", name = L["团"], command = "/raid", chatType = "RAID" },
    { id = "roll", name = L["骰"], command = "/roll", isCommand = true },
    { id = "rc", name = L["确"], command = "/rc", isCommand = true },
    { id = "pull", name = L["倒"], command = "/cd 10", isCommand = true },
    { id = "custom1", name = L["自1"], isCustom = true },
    { id = "custom2", name = L["自2"], isCustom = true },
    { id = "custom3", name = L["自3"], isCustom = true },
}

-- =============================================================
-- UI 框架
-- =============================================================
local barFrame = nil
local buttons = {}

-- 统一执行斜杠指令（例如 /MDT /DBM）
local function ExecuteSlashCommand(rawCmd)
    local cmd = tostring(rawCmd or "")
    cmd = string.gsub(cmd, "^%s*(.-)%s*$", "%1")
    if cmd == "" then
        return false
    end

    if not string.find(cmd, "^/") then
        cmd = "/" .. cmd
    end

    -- 方案1：按 SLASH_* 别名匹配并直接调用
    local slash, args = string.match(cmd, "^(/[^%s]+)%s*(.*)")
    if slash and SlashCmdList then
        slash = string.upper(slash)
        for key, func in pairs(SlashCmdList) do
            local i = 1
            while true do
                local registered = _G["SLASH_" .. key .. i]
                if not registered then
                    break
                end
                if string.upper(registered) == slash then
                    local ok = pcall(func, args or "")
                    return ok
                end
                i = i + 1
            end
        end
    end

    -- 方案2：通过聊天框发送（兜底）
    if ChatEdit_ChooseBoxForSend and ChatEdit_SendText then
        local editBox = ChatEdit_ChooseBoxForSend()
        if editBox then
            editBox:SetText(cmd)
            ChatEdit_SendText(editBox, 0)
            return true
        end
    end

    return false
end

-- 尝试把类似 /2 的输入当作“切换到频道并打开输入框”
local function OpenChatWithSlash(rawText)
    local text = tostring(rawText or "")
    text = string.gsub(text, "^%s*(.-)%s*$", "%1")
    if text == "" then
        return false
    end

    if ChatFrame_OpenChat then
        ChatFrame_OpenChat(text)
        return true
    end

    if not ChatEdit_ChooseBoxForSend or not ChatEdit_ActivateChat then
        return false
    end

    local editBox = ChatEdit_ChooseBoxForSend()
    if not editBox then
        return false
    end

    ChatEdit_ActivateChat(editBox)
    editBox:SetText(text)
    return true
end

local function TryActivateNumericChannel(rawCmd)
    local cmd = tostring(rawCmd or "")
    cmd = string.gsub(cmd, "^%s*(.-)%s*$", "%1")
    if cmd == "" then
        return false
    end

    if not string.find(cmd, "^/") then
        cmd = "/" .. cmd
    end

    local slash, args = string.match(cmd, "^(/[^%s]+)%s*(.*)")
    if not slash then
        return false
    end

    if args and args ~= "" then
        return false
    end

    if not string.match(slash, "^/%d+$") then
        return false
    end

    return OpenChatWithSlash(slash .. " ")
end

local TrimCommand

local function TryActivateNamedChannel(channelName)
    local name = TrimCommand(channelName)
    if name == "" then
        return false
    end

    if not GetChannelName then
        return false
    end

    local id = GetChannelName(name)
    if not id or id <= 0 then
        return false
    end

    return OpenChatWithSlash("/" .. id .. " ")
end

TrimCommand = function(raw)
    local cmd = tostring(raw or "")
    return string.gsub(cmd, "^%s*(.-)%s*$", "%1")
end

local function NormalizeSlashCommand(raw)
    local cmd = TrimCommand(raw)
    if cmd == "" then
        return ""
    end
    if not string.find(cmd, "^/") then
        cmd = "/" .. cmd
    end
    return cmd
end

local function GetChannelConfiguredCommand(channel)
    if not channel or not channel.id then
        return "", false
    end

    local key = channel.id .. "_channel"
    local raw = TrimCommand(EX_DB[key])

    if channel.isWorld then
        local worldName = raw ~= "" and raw or "大脚世界频道"
        if not string.find(worldName, "^/") then
            return worldName, true
        end
    end

    local cmd = NormalizeSlashCommand(raw)
    if cmd ~= "" then
        return cmd, false
    end

    return NormalizeSlashCommand(channel.command), false
end

-- 创建主框架
local function CreateBarFrame()
    if barFrame then return end

    barFrame = CreateFrame("Frame", "ExChatChannelBar", UIParent)
    barFrame:SetMovable(true)
    barFrame:EnableMouse(true)
    barFrame:RegisterForDrag("LeftButton")

    -- 锚点背景（解锁时显示）- 增大尺寸方便拖动
    barFrame.bg = barFrame:CreateTexture(nil, "BACKGROUND")
    barFrame.bg:SetAllPoints()
    barFrame.bg:SetColorTexture(0, 0.5, 0, 0.5)
    barFrame.bg:Hide()

    -- 锚点标签
    barFrame.label = barFrame:CreateFontString(nil, "OVERLAY")
    barFrame.label:SetFont("Fonts\\ARHei.ttf", 14, "OUTLINE")
    barFrame.label:SetPoint("CENTER")
    barFrame.label:SetText(L["聊天快捷栏 - 拖动此框移动位置"])
    barFrame.label:SetTextColor(1, 1, 1)
    barFrame.label:Hide()

    -- 注册到编辑模式
    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, barFrame)

    -- 拖动逻辑
    barFrame:SetScript("OnDragStart", function(self)
        if not EX_DB.locked then
            self:StartMoving()
        end
    end)

    barFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- 如果开启了吸附模式，则计算相对目标框架偏移量，类似 Mythic Cast 的设计
        if EX_DB.anchorMode and EX_DB.anchorMode ~= "不吸附" then
            local target = nil
            if EX_DB.anchorMode == "暴雪(ChatFrame1)" and _G.ChatFrame1 then
                target = _G.ChatFrame1
            elseif EX_DB.anchorMode == "Chattynator" and _G.ChattynatorHyperlinkHandler then
                for _, child in ipairs({ _G.ChattynatorHyperlinkHandler:GetChildren() }) do
                    if type(child.GetID) == "function" and child:GetID() == 1 then
                        target = child
                        break
                    end
                end
            elseif EX_DB.anchorMode == "ElvUI" and _G.LeftChatPanel then
                target = _G.LeftChatPanel
            end

            if target then
                local sLeft, sBottom = self:GetLeft(), self:GetBottom()
                local tLeft, tTop = target:GetLeft(), target:GetTop()
                if sLeft and sBottom and tLeft and tTop then
                    local scale = self:GetEffectiveScale()
                    local tScale = target:GetEffectiveScale()
                    EX_DB.offsetX = math.floor((sLeft * scale - tLeft * tScale) / scale)
                    EX_DB.offsetY = math.floor((sBottom * scale - tTop * tScale) / scale)
                end
            end
        else
            -- 不吸附时，保存绝对坐标
            local x, y = self:GetLeft(), self:GetBottom()
            if x and y then
                EX_DB.posX2 = math.floor(x)
                EX_DB.posY2 = math.floor(y)
            end
        end

        if ExwindTools.UI and ExwindTools.UI.RefreshContent then
            ExwindTools.UI:RefreshContent()
        end
    end)

    -- 初始位置将在 RefreshAll 中统一处理
end

-- 创建频道按钮
local function CreateButtons()
    -- 清理旧按钮
    for _, btn in ipairs(buttons) do
        if btn then
            btn:Hide()
            btn:SetParent(nil)
        end
    end
    wipe(buttons)

    if not barFrame then return end

    -- 只创建启用的频道按钮
    local index = 0
    for _, channel in ipairs(CHANNELS) do
        local showKey = "show_" .. channel.id
        if EX_DB[showKey] then
            index = index + 1
            local btn = CreateFrame("Frame", "ExChatChannelBtn_" .. channel.id, barFrame)
            btn:SetSize(EX_DB.buttonSize, EX_DB.buttonSize)
            btn:EnableMouse(true)

            -- 获取显示名称（优先使用自定义名称，否则取第一个字）
            local nameKey = channel.id .. "_name"
            local displayName = EX_DB[nameKey] or ""
            if displayName == "" then
                if channel.isCustom then
                    displayName = ""
                else
                    displayName = channel.name
                end
            else
                -- 只显示第一个字符
                displayName = string.sub(displayName, 1, 3) -- UTF-8 中文可能占3字节
            end

            -- 文字
            local text = btn:CreateFontString(nil, "OVERLAY")
            text:SetPoint("CENTER")
            -- 先设置默认字体，避免 "Font not set" 错误
            text:SetFont("Fonts\\ARHei.ttf", 14, "OUTLINE")
            text:SetText(displayName)
            btn.text = text
            btn.channelData = channel

            -- 鼠标事件
            btn:SetScript("OnEnter", function(self)
                if self.text then
                    self.text:SetScale(1.2)
                end
            end)

            btn:SetScript("OnLeave", function(self)
                if self.text then
                    self.text:SetScale(1.0)
                end
            end)

            btn:SetScript("OnMouseDown", function(self)
                if self.text then
                    self.text:SetAlpha(0.7)
                end
            end)

            btn:SetScript("OnMouseUp", function(self)
                if self.text then
                    self.text:SetAlpha(1.0)
                end

                local ch = self.channelData
                if not ch then return end

                local cmd, isNamedChannel = GetChannelConfiguredCommand(ch)
                if cmd == "" then
                    return
                end

                if isNamedChannel then
                    if not TryActivateNamedChannel(cmd) then
                        print("|cffff0000[" .. L["聊天快捷栏"] .. "]|r " .. L["未找到频道: "] .. tostring(cmd))
                    end
                    return
                end

                -- 纯数字频道（/1 /2 /3...）优先按“切换聊天频道”处理
                if TryActivateNumericChannel(cmd) then
                    return
                end

                if ch.isCommand then
                    -- 执行命令
                    if not ExecuteSlashCommand(cmd) then
                        print("|cffff0000[" .. L["聊天快捷栏"] .. "]|r " .. L["指令执行失败: "] .. tostring(cmd))
                    end
                elseif ch.isCustom then
                    -- 自定义指令（例如 /MDT /DBM）
                    if not ExecuteSlashCommand(cmd) then
                        print("|cffff0000[" .. L["聊天快捷栏"] .. "]|r " .. L["指令执行失败: "] .. cmd)
                    end
                else
                    -- 普通聊天切换（可自定义为任意 /频道 指令）
                    if not OpenChatWithSlash(cmd .. " ") then
                        print("|cffff0000[" .. L["聊天快捷栏"] .. "]|r " .. L["聊天框打开失败: "] .. tostring(cmd))
                    end
                end
            end)

            buttons[index] = btn
        end
    end
end

-- 更新布局
local function UpdateLayout()
    if not barFrame then return end

    local padding = EX_DB.buttonPadding
    local size = EX_DB.buttonSize
    local count = #buttons

    if count == 0 then
        -- 即使没有按钮，编辑模式下也要有足够大的锚点
        barFrame:SetSize(200, 40)
        return
    end

    local barWidth = (count * (size + padding)) + padding
    local barHeight = size + (padding * 2)

    -- 编辑模式下增大锚点尺寸，方便拖动
    if not EX_DB.locked then
        barHeight = math.max(barHeight, 40) -- 至少40像素高
        barWidth = math.max(barWidth, 200)  -- 至少200像素宽
    end

    barFrame:SetSize(barWidth, barHeight)

    for i, btn in ipairs(buttons) do
        btn:SetSize(size, size)
        btn:ClearAllPoints()
        btn:SetPoint("LEFT", barFrame, "LEFT", padding + ((i - 1) * (size + padding)), 0)
    end
end

-- 更新按钮样式
local function UpdateButtonStyles()
    -- 获取字体路径
    local fontPath = "Fonts\\ARHei.ttf"

    -- 获取描边
    local outline = EX_DB.fontOutline
    if outline == "无" then
        outline = ""
    end

    for _, btn in ipairs(buttons) do
        local channel = btn.channelData
        if not channel then return end

        -- 应用字体
        if btn.text then
            btn.text:SetFont(fontPath, EX_DB.fontSize, outline)

            -- 应用颜色（从数据库读取，使用大写 R/G/B 格式）
            local rKey = channel.id .. "R"
            local gKey = channel.id .. "G"
            local bKey = channel.id .. "B"

            local r = EX_DB[rKey] or 1
            local g = EX_DB[gKey] or 1
            local b = EX_DB[bKey] or 1

            btn.text:SetTextColor(r, g, b)

            -- 更新显示名称
            local nameKey = channel.id .. "_name"
            local displayName = EX_DB[nameKey] or ""
            if displayName == "" then
                if channel.isCustom then
                    displayName = ""
                else
                    displayName = channel.name
                end
            else
                -- 只显示第一个字符
                displayName = string.sub(displayName, 1, 3)
            end
            btn.text:SetText(displayName)
        end
    end
end

-- 刷新所有UI
local function RefreshAll()
    if not EX_DB.enabled then
        if barFrame then
            barFrame:Hide()
        end
        return
    end

    if not barFrame then
        CreateBarFrame()
    end

    CreateButtons()
    UpdateLayout()
    UpdateButtonStyles()

    barFrame:Show()

    -- 更新锁定状态
    if EX_DB.locked then
        barFrame:EnableMouse(false)
        barFrame.bg:Hide()
        barFrame.label:Hide()
    else
        barFrame:EnableMouse(true)
        barFrame.bg:Show()
        barFrame.label:Show()
    end

    -- 更新位置：根据吸附模式或保存的坐标
    -- 更新位置：根据吸附模式或保存的坐标
    barFrame:ClearAllPoints()
    local attached = false
    local anchorTarget = nil

    if EX_DB.anchorMode == "暴雪(ChatFrame1)" and _G.ChatFrame1 then
        anchorTarget = _G.ChatFrame1
    elseif EX_DB.anchorMode == "Chattynator" and _G.ChattynatorHyperlinkHandler then
        for _, child in ipairs({ _G.ChattynatorHyperlinkHandler:GetChildren() }) do
            if type(child.GetID) == "function" and child:GetID() == 1 then
                anchorTarget = child
                break
            end
        end
    elseif EX_DB.anchorMode == "ElvUI" and _G.LeftChatPanel then
        anchorTarget = _G.LeftChatPanel
    end

    if anchorTarget then
        barFrame:SetPoint("BOTTOMLEFT", anchorTarget, "TOPLEFT", EX_DB.offsetX or 0, EX_DB.offsetY or 30)
        attached = true
    end

    if not attached then
        -- 回退到默认位置或不吸附位置
        if EX_DB.posX2 and EX_DB.posY2 then
            barFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", EX_DB.posX2, EX_DB.posY2)
        else
            barFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
    end
end

-- =============================================================
-- 事件处理
-- =============================================================
ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    EX_DB.locked = true
    C_Timer.After(0.5, function()
        RefreshAll()
    end)
end)

-- 监听配置变化
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    -- 如果是频道开关变化，需要重建按钮
    if string.find(info.key, "^show_") then
        RefreshAll()
    else
        -- 其他设置只需刷新样式
        UpdateLayout()
        UpdateButtonStyles()

        -- 更新锁定状态
        if info.key == "locked" then
            if EX_DB.locked then
                barFrame:EnableMouse(false)
                barFrame.bg:Hide()
                barFrame.label:Hide()
            else
                barFrame:EnableMouse(true)
                barFrame.bg:Show()
                barFrame.label:Show()
            end
        end

        -- 启用/禁用 或 吸附模式改变
        if info.key == "enabled" or info.key == "anchorMode" then
            RefreshAll()
        end
    end
end)

-- 按钮点击事件
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    if info.key == "btn_reset_pos" then
        EX_DB.posX2 = nil
        EX_DB.posY2 = nil
        EX_DB.offsetX = 0
        EX_DB.offsetY = 30
        if barFrame then
            barFrame:ClearAllPoints()
            barFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
        RefreshAll()
    end
end)

-- 全局编辑模式回调
local function ApplyEditModePresentation()
    if isEditModeActive then
        EX_DB.locked = not isEditModeVisible
        C_Timer.After(0.05, function()
            if isEditModeActive and not isEditModeVisible then
                if barFrame then
                    barFrame:Hide()
                end
                return
            end
            RefreshAll()
        end)
    else
        if editModeRestoreLocked ~= nil then
            EX_DB.locked = editModeRestoreLocked
            editModeRestoreLocked = nil
        end
        C_Timer.After(0.05, RefreshAll)
    end
end

ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
    EnterEditMode = function()
        if editModeRestoreLocked == nil then
            editModeRestoreLocked = EX_DB.locked
        end
        isEditModeActive = true
        isEditModeVisible = true
        ApplyEditModePresentation()
    end,
    ExitEditMode = function()
        isEditModeActive = false
        isEditModeVisible = true
        ApplyEditModePresentation()
    end,
    SetEditVisible = function(_, visible)
        isEditModeVisible = (visible ~= false)
        ApplyEditModePresentation()
    end,
})

-- =============================================================
-- 斜杠命令
-- =============================================================
_G.SLASH_EXCHATCHANNEL1 = "/cc"
_G.SlashCmdList["EXCHATCHANNEL"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "show" then
        EX_DB.enabled = true
        RefreshAll()
    elseif msg == "hide" then
        EX_DB.enabled = false
        RefreshAll()
    elseif msg == "toggle" then
        EX_DB.enabled = not EX_DB.enabled
        RefreshAll()
    elseif msg == "reset" then
        EX_DB.posX = 0
        EX_DB.posY = 0
        RefreshAll()
    else
        -- 打开设置面板
        ExwindTools:OpenSettingsPanel(EXWIND_MODULE_KEY)
    end
end

-- =============================================================
-- 模块就绪报告
-- =============================================================
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
