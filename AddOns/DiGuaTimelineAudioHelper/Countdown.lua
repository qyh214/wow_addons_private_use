-- 创建模块表
local _, addonTable = ...
local Countdown = {}
addonTable.Countdown = Countdown

local ticker = nil

-- 获取媒体路径的辅助函数（抽离出来复用）
local function GetMediaPath()
    if C_AddOns.IsAddOnLoaded("DiGua-WYJJ") then
        return "Interface\\AddOns\\DiGua-WYJJ\\Media\\"
    else
        return "Interface\\AddOns\\DiGuaTimelineAudioHelper\\Media\\"
    end
end

-- 内部停止函数
function Countdown:Stop()
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
end

-- === 新增：就位确认处理函数 ===
function Countdown:PlayReadyCheckVoice()
    if C_AddOns.IsAddOnLoaded("DBM-Core") or C_AddOns.IsAddOnLoaded("BigWigs") then
        return 
    end
    local _, battleTag, _, _, _, _ = BNGetInfo()
    if battleTag and battleTag:find("简繁") then
        return
    else
        local path = GetMediaPath() .. "JiuWeiQueRen.ogg" -- 确保你的 Media 文件夹下有这个文件
        PlaySoundFile(path, "Master")
    end
end

-- 内部开始函数 (倒计时)
function Countdown:Start(timeRemaining)
    if C_AddOns.IsAddOnLoaded("DBM-Core") or C_AddOns.IsAddOnLoaded("BigWigs") then
        return 
    end

    local currentMediaPath = GetMediaPath()
    self:Stop() 

    local count = math.floor(timeRemaining)
    if count <= 0 then return end

    local function PlayVoice(num)
        local path = currentMediaPath .. "DaoShu" .. num .. ".ogg"
        PlaySoundFile(path, "Master")
    end

    PlayVoice(count)
    count = count - 1

    if count >= 0 then
        ticker = C_Timer.NewTicker(1, function()
            if count > 0 then
                PlayVoice(count)
                count = count - 1
            elseif count == 0 then
                self:Stop()
            else
                self:Stop()
            end
        end, count + 1)
    end
end

-- 模块初始化（注册事件）
local frame = CreateFrame("Frame")
frame:RegisterEvent("START_PLAYER_COUNTDOWN")
frame:RegisterEvent("CANCEL_PLAYER_COUNTDOWN")
-- 注册就位确认相关事件
frame:RegisterEvent("READY_CHECK") 
frame:RegisterEvent("READY_CHECK_FINISHED")

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "START_PLAYER_COUNTDOWN" then
        local _, timeRemaining = ...
        Countdown:Start(timeRemaining)
    elseif event == "CANCEL_PLAYER_COUNTDOWN" then
        Countdown:Stop()
    elseif event == "READY_CHECK" then
        -- 当团长发起就位确认时触发
        Countdown:PlayReadyCheckVoice()
    elseif event == "READY_CHECK_FINISHED" then
        -- 这里的逻辑可以根据需要添加，比如全员就位后的提示音
        -- PlaySoundFile(GetMediaPath() .. "ReadyCheckDone.ogg", "Master")
    end
end)