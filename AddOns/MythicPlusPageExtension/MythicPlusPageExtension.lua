local ADDON_NAME, mppe = ...
-- 初始化开始
if not mppe then mppe = {} end
-- REF https://www.curseforge.com/wow/addons/keystoneloot
mppe.Translate = setmetatable({}, {
    __index = function(t, key)
        rawset(t, key, key);
        return key;
    end
});
mppe.Mine = mppe.Mine or {}
mppe.Mine.Name = mppe.Mine.Name or UnitName("Player")
mppe.Mine.Realm = mppe.Mine.Realm or GetRealmName()
mppe.CurrentSeasonDungeon = nil

local MythicPlusPageExtension = CreateFrame("Frame")
MythicPlusPageExtension:RegisterEvent("ADDON_LOADED")
MythicPlusPageExtension:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == ADDON_NAME then
        -- 1. 加载/初始化主数据库
        MythicPlusPageExtensionDB = MythicPlusPageExtensionDB or {}
        -- 定义默认配置（仅在首次使用时生效）
        local defaultSettings = {
            ScoreNTeleport_Enable = true,
            ScoreNTeleport_TryClearOther = true,
            ScoreNTeleport_ScoreColorStyle = "highestlv",
            ScoreNTeleport_EnableTeleport = true,
            ScoreNTeleport_SendTeleportInfo = true,
            ScoreNTeleport_STI_CastStatu = "castsucceeded",
            ScoreNTeleport_UseOldStyle = false,
            ScoreNTeleport_DunShortName_FontSize = 13,
            ScoreNTeleport_DunShortName_PerLine = 7,
            ScoreNTeleport_DunLevel_FontSize = 22,
            ScoreNTeleport_DunScore_FontSize = 22,
            PartyKeyStone_Enable = true,
            PartyKeyStone_ScoreColorStyle = "raiderio",
            PartyKeyStone_xOffset = 0,
            PartyKeyStone_yOffset = 0,
            WeeklyReport_Enable = true,
            WeeklyReport_HideRaiderIOFrame = true,
            WeeklyReport_ShowWeeklyTOP8 = true,
            WeeklyReport_FontSize = 15,
            WeeklyReport_FrameWidth = 400,
            WeeklyReport_FrameHeightCorrection = 0
        }
        -- 2. (可选但推荐) 确保每个设置项都有默认值
        for key, defaultValue in pairs(defaultSettings) do
            if MythicPlusPageExtensionDB[key] == nil then
                MythicPlusPageExtensionDB[key] = defaultValue
            end
        end
        -- 3. 触发插件主初始化流程
        self:UnregisterEvent("ADDON_LOADED") -- 只需执行一次
    end
end)

local init = false
hooksecurefunc("PanelTemplates_SetTab", function(frame, id)
    if not init and frame == PVEFrame then
        if not init and id == 3 then
            ChallengesFrame:HookScript("OnShow", function() mppe.RefreshScoreNTeleport() mppe.WeeklyFrameShowOrHide(true) mppe.RefreshPartyInfo() end)
            ChallengesFrame:HookScript("OnHide", function() mppe.WeeklyFrameShowOrHide(false) end)
            init = true
        end
    end
end)
-- ==================================================================
-- 队友信息表，主表
mppe.PartyMember = {
    -- ["Name-Realm"] = {
    --     iLv = nil, -- 装等
    --     class = nil, -- 职业
    --     specId = nil, -- 专精id
    --     inParty = nil, -- 当前是否在队伍内
    --     source = nil, -- 来源(MPPE/INSP)
    --     updated = nil, -- 最近更新时间
    -- }
}
-- 队友钥石表
mppe.PartyKeystone = {
    -- ["Name-Realm"] = {
    --     ksId = nil, -- 钥石id
    --     ksLv = nil, -- 钥石层数
    --     source = nil, -- 来源(MPPE/AKS/LKS/LOR)
    --     updated = nil, -- 最近更新时间
    -- },
}
-- 队友副本记录表
mppe.PartyBest = {
    -- ["Name-Realm"] = {
    --     [123] = { duration = nil, lv = nil, score = nil, success = nil}, -- index:challengeModeID
    --     _meta = {
    --         rating = nil,
    --         source = nil, -- 来源(MPPE/INSP)
    --         updated = nil, -- 最近更新时间}
    --     }
    -- },
}
mppe.PartyEvent = CreateFrame("Frame")
local pe = mppe.PartyEvent
function pe.PartyMember_Upsert(personFullName, iLv, class, specId, inParty, source)
    -- 1. 基础校验
    if type(personFullName) ~= "string" or personFullName == "" then return end
    if mppe.Mine.Realm == nil then mppe.Mine.Realm = GetRealmName() end
    if not string.match(personFullName,"([^%-]+)%-(.*)") then
        personFullName = string.format("%s-%s", personFullName, mppe.Mine.Realm)
    end
    -- 2. 获取或创建记录
    mppe.PartyMember[personFullName] = mppe.PartyMember[personFullName] or {}
    local player = mppe.PartyMember[personFullName]

    -- 3. 安全更新字段
    if type(iLv) == "number" then player.iLv = iLv end
    if class then player.class = class end
    if type(specId) == "number" then player.specId = specId end
    if inParty ~= nil then player.inParty = inParty end -- 关键修复：允许设置为false
    if source then player.source = source end -- 仅在source有值时更新

    -- 4. 更新时间戳
    player.updated = time()
end

function pe.PartyKeystone_Upsert(personFullName, ksId, ksLv, rating, source)
    if type(personFullName) ~= "string" or personFullName == "" then return end
    if mppe.Mine.Realm == nil then mppe.Mine.Realm = GetRealmName() end
    if not string.match(personFullName,"([^%-]+)%-(.*)") then
        personFullName = string.format("%s-%s", personFullName, mppe.Mine.Realm)
    end
    mppe.PartyKeystone[personFullName] = mppe.PartyKeystone[personFullName] or {}
    local player = mppe.PartyKeystone[personFullName]

    if type(ksId) == "number" then player.ksId = ksId end
    if type(ksLv) == "number" then player.ksLv = ksLv end
    if type(rating) == "number" then player.rating = rating end
    if source then player.source = source end -- 有条件更新
    player.updated = time()
end

function pe.PartyBest_Upsert(personFullName, bestRuns, source)
    if type(personFullName) ~= "string" or personFullName == "" then return end
    if not string.match(personFullName,"([^%-]+)%-(.*)") then
        personFullName = string.format("%s-%s", personFullName, mppe.Mine.Realm)
    end
    mppe.PartyBest[personFullName] = mppe.PartyBest[personFullName] or {}
    local player = mppe.PartyBest[personFullName]

    local _rating = 0
    if type(bestRuns) == "table" then
        for _id, _info in pairs(bestRuns) do
            -- 选择1：合并更新（保留旧字段，仅更新新字段）
            player[_id] = player[_id] or {}
            local record = player[_id]
            if type(_info.duration) == "number" then record.duration = _info.duration end
            if type(_info.lv) == "number" then record.lv = _info.lv end
            if type(_info.score) == "number" then record.score = _info.score end
            if _info.success ~= nil then record.success = _info.success end -- success可能是布尔值false

            -- 安全累加评分
            if type(_info.score) == "number" then
                _rating = _rating + _info.score
            end
        end
    end

    -- 初始化并更新元数据
    player._meta = player._meta or {}
    local _meta = player._meta
    if source then _meta.source = source end
    _meta.updated = time()
    _meta.rating = _rating
end

function pe.PartyBest_Upsert_Old(personFullName, runs, rating, source)
    if type(personFullName) ~= "string" or personFullName == "" then return end
    if not string.match(personFullName,"([^%-]+)%-(.*)") then
        personFullName = string.format("%s-%s", personFullName, mppe.Mine.Realm)
    end
    mppe.PartyBest[personFullName] = mppe.PartyBest[personFullName] or {}
    local player = mppe.PartyBest[personFullName]

    if type(runs) == "table" then
        player.runs = runs
    end
    player._meta = player._meta or {}
    local _meta = player._meta
    if type(rating) == "number" then
        _meta.rating = rating
    end
    _meta.updated = time()
    _meta.source = source
end

function pe.Party_Cleanup()
    -- 获取当前小队成员列表（包括自己）
    local currentPartyMembers = {}
    
    -- 首先将自己加入列表
    local playerName = UnitName("player")
    local playerRealm = GetRealmName()
    local playerFullName = playerName .. "-" .. playerRealm
    currentPartyMembers[playerFullName] = true
    
    -- 获取普通队伍成员（不包括自己）
    if IsInGroup() and not IsInRaid() then
        -- 关键修复：使用 GetNumGroupMembers() - 1 或检查 party1-party4
        local maxIndex = GetNumGroupMembers() - 1  -- 排除自己
        if maxIndex > 4 then maxIndex = 4 end  -- 安全上限，小队最多4个队友
        
        for i = 1, maxIndex do
            local unit = "party" .. i
            local name, realm = UnitName(unit)  -- UnitName 已足够，UnitFullName 在某些情况下可能不同
            
            if name then
                local fullName = name
                -- 使用简洁的三元运算逻辑
                fullName = fullName .. "-" .. (realm and realm ~= "" and realm or playerRealm)
                currentPartyMembers[fullName] = true
            end
        end
    end
    
    -- 第一步：更新小队成员的inParty状态和时间戳
    for fullName in pairs(currentPartyMembers) do
        -- 使用现有函数更新状态，如果玩家不存在于表中则跳过（符合缓存设计）
        if mppe.PartyMember[fullName] then 
            -- 明确传递 nil 表示不更新其他字段
            pe.PartyMember_Upsert(fullName, nil, nil, true) 
        end
    end
    
    -- 第二步：遍历所有PartyMember记录，清理过期数据
    local toDelete = {}
    local currentTime = time()
    
    for fullName, memberData in pairs(mppe.PartyMember) do
        -- 跳过当前在队的成员
        if not memberData.inParty then
            -- 获取三个表的时间戳
            local timestamps = {}
            
            -- 1. PartyMember 时间戳
            if memberData.updated then 
                table.insert(timestamps, memberData.updated) 
            end
            
            -- 2. PartyKeystone 时间戳
            local ksData = mppe.PartyKeystone[fullName]
            if ksData and ksData.updated then 
                table.insert(timestamps, ksData.updated) 
            end
            
            -- 3. PartyBest 时间戳（在 _meta 中）
            local bestData = mppe.PartyBest[fullName]
            if bestData and bestData._meta and bestData._meta.updated then 
                table.insert(timestamps, bestData._meta.updated) 
            end
            
            -- 检查是否应该删除
            if #timestamps > 0 then
                -- 安全地获取最小时间戳
                local minTimestamp
                if #timestamps == 1 then
                    minTimestamp = timestamps[1]
                else
                    minTimestamp = math.min(unpack(timestamps))
                end
                
                -- 如果最小时间戳超过1小时（3600秒），则标记为删除
                if (currentTime - minTimestamp) > 3600 then 
                    toDelete[fullName] = true 
                end
            else
                -- 如果没有任何时间戳，标记为删除（异常数据）
                toDelete[fullName] = true
            end
        end
    end
    
    -- 第三步：执行删除
    local deletedCount = 0
    for fullName in pairs(toDelete) do
        mppe.PartyMember[fullName] = nil
        mppe.PartyKeystone[fullName] = nil
        mppe.PartyBest[fullName] = nil
        deletedCount = deletedCount + 1
    end
    
    -- 第四步：将当前不在队的成员标记为false（确保数据一致性）
    -- 注意：第3步中删除的玩家不会在此被遍历到，这符合逻辑
    for fullName, memberData in pairs(mppe.PartyMember) do
        if not currentPartyMembers[fullName] then
            memberData.inParty = false
            -- 可选：不更新时间戳，用原始时间戳判断过期
        end
    end
    
    return deletedCount
end

function pe.GetPlayer(name, realm)
    local player = {
            name = name,
            realm = realm,
            fullName = "",
            NameRealm = "",
            bYou = false,
            bSameRealm = false,
            bLeader = false,           
            class = "",
            spec = 0,
            hexColor = "",
            role = "",
            roleId = 9,
            score = 0,
            runs = {},
            ksLv = 0,
            ksId = 0,
            iLv = 0,
        }
        if name == mppe.Mine.Name and realm == mppe.Mine.Realm then   
            --if mppe.Mine.Realm == nil then mppe.Mine.Realm = GetRealmName() end
            --player.realm = mppe.Mine.Realm
            player.fullName = mppe.Mine.Name
            player.bYou = true
            player.bSameRealm = true
            player.NameRealm = mppe.Mine.Name.."-"..mppe.Mine.Realm
            player.class = select(2, UnitClass(player.fullName))
            player.spec = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization()) 
            player.ksId = C_MythicPlus.GetOwnedKeystoneChallengeMapID() or 0
            player.ksLv = C_MythicPlus.GetOwnedKeystoneLevel() or 0
            player.iLv = select(2, GetAverageItemLevel())
            local _playerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(player.fullName)
            player.runs = _playerMythicPlusRatingSummary and _playerMythicPlusRatingSummary.runs
            player.score = _playerMythicPlusRatingSummary and _playerMythicPlusRatingSummary.currentSeasonScore or 0
        else
            if realm == mppe.Mine.Realm or realm == nil or realm == "" then
                player.realm = mppe.Mine.Realm
                player.fullName = name
                player.bSameRealm = true                
            else
                player.fullName = string.format("%s-%s", name, realm)
                player.bSameRealm = false
            end
            player.NameRealm = string.format("%s-%s", player.name, player.realm)
            player.bYou = false
            local pm = mppe.PartyMember[player.NameRealm]
            if pm then 
            player.class, player.spec, player.iLv = pm.class, pm.specId, pm.iLv
            else
                player.class = select(2, UnitClass(player.fullName))
                player.spec, player.iLv =0, 0 
            end
            local pk = mppe.PartyKeystone[player.NameRealm]
            if pk then
                
                player.ksId, player.ksLv, player.score = pk.ksId, pk.ksLv, pk.rating
                --print( player.ksId..":"..player.ksLv..":"..player.score)
            end
            local pb = mppe.PartyBest[player.NameRealm]
            if pb then 
                local _meta = pb._meta
                if not player.score or player.score == 0 then
                    if _meta then
                        player.score = _meta.rating
                    end
                end
                player.runs = pb.runs
            end
        end
    return player
end
-- local cleanupScheduled = false

-- ep:RegisterEvent("GROUP_ROSTER_UPDATE")
-- ep:SetScript("OnEvent", function(self, event)
--     if event == "GROUP_ROSTER_UPDATE" and not cleanupScheduled then
--         cleanupScheduled = true
--         C_Timer.After(1, function()  -- 延迟1秒执行
--             ep.Party_Cleanup()
--             cleanupScheduled = false
--         end)
--     end
-- end)
mppe.LFG_Info = {
    titleName = "",
    typeName = "",
    modeName = "",
    activityID = 0,
    groupFinderActivityGroupID = 0,
    mapID = 0,
    -- descName = function()
    --     local value = ""
    --     if self.titleName or self.typeName then
    --         if self.titleName then 
    --             value = self.titleName
    --         end
    --         if self.titleName and self.titleName then
    --             value = value.."\n"
    --         end
    --         value = value..self.typeName
    --     end
    --     return value
    -- end,
    -- _savedName = "" --保存一下titleName
}

-- =================================================================
-- 共用方法组
-- hex转rgba颜色
function mppe.ColorHexToRGBA(hexColor)
    -- 移除可能的#前缀
    hexColor = string.gsub(hexColor, "^#", "")
    
    -- 如果是8位ARGB格式
    if #hexColor == 8 then
        local a = tonumber(string.sub(hexColor, 1, 2), 16) / 255
        local r = tonumber(string.sub(hexColor, 3, 4), 16) / 255
        local g = tonumber(string.sub(hexColor, 5, 6), 16) / 255
        local b = tonumber(string.sub(hexColor, 7, 8), 16) / 255
        return r, g, b, a
    -- 如果是6位RGB格式（默认不透明）
    elseif #hexColor == 6 then
        local r = tonumber(string.sub(hexColor, 1, 2), 16) / 255
        local g = tonumber(string.sub(hexColor, 3, 4), 16) / 255
        local b = tonumber(string.sub(hexColor, 5, 6), 16) / 255
        return r, g, b, 1  -- 默认Alpha=1（不透明）
    else
        return 1, 1, 1, 1  -- 默认白色不透明
    end
end

-- 获取分数颜色(以魔兽标准品质颜色，在默认颜色逻辑基础上增加了artifact和poor颜色区间)
function mppe.GetColorByScore(score, colorStyle, bHexColor)
    score = score or 0
    local r, g, b = 1, 1 ,1
    if colorStyle == "raiderio" then 
        -- REF Raider.IO 参考其颜色区间设置建立的算法函数
        local _rRange = mppe.RaiderIOScoreRange
        -- if type(NowRaiderIOTopScore) ~= "number" then NowRaiderIOTopScore = 4075 end
        -- 确保分数在有效范围内
        score = math.max(0, math.min(score, _rRange[1]))    
        if score >= _rRange[2] then
            local t = (_rRange[1] - score) / (_rRange[1] - _rRange[2])
            r, g, b = 1-0.36*t, 0.5-0.29*t, 0.93*t
        elseif score >= _rRange[3] then
            local t = (_rRange[2] - score) / (_rRange[2] - _rRange[3])
            r, g, b = 0.64-0.39*t, 0.21+0.21*t, 0.93-0.05*t
        elseif score >= _rRange[4] then
            local t = (_rRange[3] - score) / (_rRange[3] - _rRange[4])
            r, g, b = 0.25-0.13*t, 0.42+0.58*t, 0.88-0.88*t
        elseif score >= _rRange[5] then
            local t = (_rRange[4] - score) / (_rRange[4] - _rRange[5])
            r, g, b = 0.12+0.26*t, 1.00, 0.28*t
        elseif score >= _rRange[6] then
            local t = (_rRange[5] - score) / (_rRange[5] - _rRange[6])
            r, g, b = 0.38+0.62*t, 1.00, 0.28+0.72*t
        else r, g, b = 1.00, 1.00, 1.00
        end     
    else
        r,g,b = 0.62, 0.62, 0.62 -- poor
        if score >= 3000 then  r,g,b = 0.90, 0.80, 0.50 -- artifact
        elseif score >= 2200 then r,g,b = 1.00, 0.50, 0.00 -- legendary
        elseif score >= 1800 then r,g,b = 0.64, 0.21, 0.93 -- epic
        elseif score >= 1500 then r,g,b = 0.00, 0.44, 0.87 -- rare
        elseif score >= 1000 then r,g,b = 0.12, 1.00, 0.00 -- uncommon
        elseif score >= 500 then r,g,b = 1.00, 1.00, 1.00 --common
        end
    end
    if bHexColor then
        return string.format("FF%02X%02X%02X", r*255, g*255, b*255)
    else
        return r, g, b, 1
    end
end

function mppe.MathRound(value, decimalPlaces)
    if type(value) ~= "number" then value = 0 end
    if type(decimalPlaces) ~= "number" then decimalPlaces = 0 end
    if decimalPlaces > 10 then decimalPlaces = 10 end
    value = math.floor(value * math.pow(10, decimalPlaces) +0.5 ) / math.pow(10, decimalPlaces)
    return value
end

-- 通用的漂亮打印函数（递归处理嵌套表）
function mppe.DebugPrint(t, indent, visited)
    indent = indent or 0
    visited = visited or {}
    local spaces = string.rep("  ", indent) -- 缩进

    -- 防止循环引用导致无限递归
    if type(t) == "table" and visited[t] then
        print(spaces .. "（已打印过此表，防止循环引用）")
        return
    end
    if type(t) == "table" then
        visited[t] = true
    end

    for key, value in pairs(t) do
        local keyStr = tostring(key)
        if type(value) == "table" then
            print(string.format("%s[%s] => {", spaces, keyStr))
            mppe.DebugPrint(value, indent + 1, visited)
            print(spaces .. "}")
        else
            -- 对字符串值进行转义，使其更易读
            local valueStr = tostring(value)
            if type(value) == "string" then
                valueStr = '"' .. valueStr .. '"'
            end
            print(string.format("%s[%s] => %s", spaces, keyStr, valueStr))
        end
    end
end