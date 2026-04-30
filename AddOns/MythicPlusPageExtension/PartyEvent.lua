local ADDON_NAME, mppe = ...
local LKS = LibStub("LibKeystone")
local LOR = LibStub("LibOpenRaid-1.0")
local translate = mppe.Translate
local pe = mppe.PartyEvent

local PartyInspector = { queue = {}, isBusy = false, currentGUID = nil, currentUnit = nil, callback = nil, frame = nil}
local partyCheckTimer = nil

function PartyInspector:UpdateQueue(forceRefresh )
    -- 获取当前队伍成员信息
    local currentMembers = {}
    local currentTime = time()
    
    -- 1. 收集当前在线队友信息
    for i = 1, GetNumSubgroupMembers() do
        local unit = "party"..i
        local name, realm = UnitName(unit)
        local playerRealm = GetRealmName()
        
        if name then
            -- 构建完整名称（姓名-服务器）
            if not realm or realm == "" then
                realm = playerRealm
            end
            local fullName = name.."-"..realm
            local guid = UnitGUID(unit)
            
            currentMembers[fullName] = {
                unit = unit,
                guid = guid,
                name = name,
                realm = realm,
                fullName = fullName
            }
        end
    end
    
    -- 2. 构建新队列
    local newQueue = {}
    local inQueue = {}  -- 用于去重
    
    -- 3. 首先处理已在队列中的成员
    for _, unit in ipairs(self.queue) do
        -- 通过unit查找对应的fullName
        local name, realm = UnitName(unit)
        if name then
            local _, playerRealm = UnitFullName("player")
            if not realm or realm == "" then
                realm = playerRealm
            end
            local fullName = name.."-"..realm
            
            -- 检查成员是否仍在队伍中
            if currentMembers[fullName] then
                -- 检查是否需要重新观察
                local shouldObserve = self:ShouldObserveMember(fullName, currentTime,forceRefresh)
                if shouldObserve then
                    table.insert(newQueue, unit)
                    inQueue[unit] = true
                else
                    -- 数据足够新，跳过观察
                    --print("MPPE: 跳过观察 "..fullName.." (数据已更新)")
                end
            end
            -- 如果成员已离开队伍，自动从队列中移除
        end
    end
    
    -- 4. 添加新成员到队列
    for fullName, memberInfo in pairs(currentMembers) do
        local unit = memberInfo.unit
        
        if not inQueue[unit] then
            -- 检查是否需要观察
            local shouldObserve = self:ShouldObserveMember(fullName, currentTime,forceRefresh)
            if shouldObserve then
                table.insert(newQueue, unit)
                inQueue[unit] = true
            else
                --print("MPPE: 跳过观察 "..fullName.." (数据已更新)")
            end
        end
    end
    
    self.queue = newQueue
    
    -- 5. 如果当前观察的目标已离开队伍或不需要观察，停止观察
    if self.currentGUID then
        -- 查找当前观察目标对应的fullName
        local currentFullName = nil
        for fullName, memberInfo in pairs(currentMembers) do
            if memberInfo.guid == self.currentGUID then
                currentFullName = fullName
                break
            end
        end
        
        if not currentFullName or not self:ShouldObserveMember(currentFullName, currentTime,forceRefresh) then
            self.currentGUID = nil
            ClearInspectPlayer()
            self:InspectNext()
        end
    end
    
    -- 6. 如果队列为空但观察器还在运行，停止它
    if #self.queue == 0 and self.isBusy then
        self.isBusy = false
        if self.callback then self.callback("COMPLETE") end
    end
    
    return #newQueue  -- 返回队列长度
end

-- 辅助函数：判断是否需要观察某个成员
function PartyInspector:ShouldObserveMember(fullName, currentTime, forceRefresh)
    local memberData = mppe.PartyMember[fullName]
    
    -- 如果没有缓存数据，需要观察
    if not memberData then
        return true
    end
    
    -- 如果来源是MPPE，不需要观察（假设MPPE数据更可靠）
    if memberData.source == "MPPE" then
        return false
    end
    -- 强制刷新（刷新按钮）
    if forceRefresh then return true end
    -- 检查更新时间（最小观察时间间隔：秒）
    if memberData.updated and (currentTime - memberData.updated) < 180 then return false end
    
    -- 其他情况需要观察
    return true
end

function PartyInspector:New(callbackFunc)
    local o = { callback = callbackFunc, queue = {} }
    setmetatable(o, { __index = self })
    
    o.frame = CreateFrame("Frame")
    o.frame:RegisterEvent("INSPECT_READY")
    o.frame:SetScript("OnEvent", function(self, event, guid)
        if event == "INSPECT_READY" then o:HandleReady(guid) end
    end)
    return o
end

function PartyInspector:Start(forceRefresh)
    -- 仅在未运行时且在小队中启动
    if self.isBusy or not IsInGroup() or IsInRaid() then return end
    
    -- 更新队列（会应用智能过滤）
    self:UpdateQueue(forceRefresh)
    if #self.queue > 0 then
        self.isBusy = true
        self:InspectNext()
    else
        -- 队列为空，直接完成
        self.isBusy = false
        if self.callback then self.callback("COMPLETE") end
    end
end


function PartyInspector:Stop()
    self.isBusy = false
    self.currentGUID = nil
    self.queue = {}
    ClearInspectPlayer()
end

function PartyInspector:InspectNext()
    if #self.queue == 0 then
        self.isBusy = false
        if self.callback then self.callback("COMPLETE") end
        return
    end

    local unit = table.remove(self.queue, 1)
    self.currentGUID = UnitGUID(unit)
    self.currentUnit = unit

    if not self.currentGUID then
        -- 玩家可能离线，跳过
        C_Timer.After(0.2, function() self:InspectNext() end)
        return
    end

    -- 发起观察请求
    NotifyInspect(unit)
    -- 设置超时保护（2.5秒）
    C_Timer.After(2.5, function()
        if self.currentGUID then
            self.currentGUID = nil
            self.currentUnit = nil
            self:InspectNext()
        end
    end)
end

-- 辅助函数：获取观察目标的平均装等
local function GetInspectItemLevel(unit)
    if not unit or not UnitExists(unit) then return 0 end
    local totalItemLevel = 0
    local itemCount = 15
    local TwoHanded = true
    -- 遍历所有装备槽位（1-17是标准装备槽位，4是衬衣）
    for slot = 1, 17 do
        local itemLink = GetInventoryItemLink(unit, slot)
        if slot ~= 4 then 
            if itemLink then
                -- 从物品链接中解析装等
                -- 物品链接格式：|cff9d9d9d|Hitem:6948::::::::60:::::::|h[炉石]|h|r
                -- 或者包含装等：|cffa335ee|Hitem:18832::::::::60::1::::|h[ Brutality Blade ]|h|r
                -- 我们可以使用GetItemInfo来获取物品信息
                local _, link, quality, itemLevel, _, _, _, _, _, _, _, itemClassID, itemSubClassID, _, _, _ = GetItemInfo(itemLink)
                -- 神话披风、地下堡腰带以及好多旧版本装备从链接获取的装等都有问题
                local itemID = string.match(itemLink, "item:(%d+)")
                if tostring(itemID) == "235499" or itemLevel == 720 then itemLevel = 170 end
                if tostring(itemID) == "245965" or itemLevel == 701 then itemLevel = 141 end
                --单手/双手判断
                if itemClassID == 2 then
                    local oneHandedTypes = {[0]=true, [4]=true, [7]=true, [13]=true, [15]=true, [19]=true}
                    if oneHandedTypes[itemSubClassID] then TwoHanded = false
                    end
                end
                if itemLevel > 170 then
                    --print(slot..":"..itemLevel..":"..itemLink)
                end
                totalItemLevel = totalItemLevel + (itemLevel and itemLevel or 0)
            elseif slot == 17 and itemLink == nil and TwoHanded == false then
                itemCount = itemCount + 1
            end
        end
    end
    
    if itemCount > 0 then
        return mppe.MathRound(totalItemLevel / itemCount, 0)
    end
    
    return 0
end

function PartyInspector:HandleReady(guid)
    --print("HReady: "..(guid or "nil"))
    
    -- 检查GUID是否匹配当前观察目标
    if not self.currentGUID or guid ~= self.currentGUID then
        --print("GUID不匹配或没有当前观察目标，返回")
        return
    end
    
    local unit = self.currentUnit
    
    -- 验证unit是否仍然有效
    if not unit or UnitGUID(unit) ~= guid then
        -- print("unit无效，尝试通过GUID查找")
        -- unit无效，尝试通过GUID查找
        for i = 1, GetNumSubgroupMembers() do
            local partyUnit = "party"..i
            if UnitGUID(partyUnit) == guid then
                unit = partyUnit
                self.currentUnit = unit  -- 更新当前unit
                -- print("找到unit: "..unit)
                break
            end
        end
    end
    
    if not unit then
        -- print("无法找到对应的unit，跳过")
        ClearInspectPlayer()
        self.currentGUID = nil
        self.currentUnit = nil
        C_Timer.After(0.4, function() self:InspectNext() end)
        return
    end
    
    -- print("处理观察结果，unit: "..unit)
    
    -- 1. 获取专精ID
    local specID = GetInspectSpecialization(unit)
    -- print("专精ID: "..(specID or "nil"))
    
    -- 2. 尝试获取装等（使用重试机制）
    local function TryGetItemLevel(retryCount)
        local iLv = GetInspectItemLevel(unit)
        -- print("尝试获取装等，重试次数: "..retryCount..", 结果: "..iLv)
        
        if iLv == 0 and retryCount < 3 then
            -- 重试
            C_Timer.After(0.1, function()
                TryGetItemLevel(retryCount + 1)
            end)
            return
        end
        
        -- 如果无法通过观察获取装等，尝试其他方法
        if iLv == 0 then
            -- 尝试使用Unit平均装等相关API
            local avgItemLevel = GetAverageItemLevel()
            if avgItemLevel then
                -- print("最终装等: "..avgItemLevel)
                iLv = math.floor(avgItemLevel)
                -- print("使用GetAverageItemLevel获取装等: "..iLv)
            end
        end
        
        -- print("最终装等: "..iLv)
        
        -- 回调处理结果
        if self.callback then
            self.callback(unit, specID, iLv)
        end
        
        -- 清理并继续下一个
        ClearInspectPlayer()
        self.currentGUID = nil
        self.currentUnit = nil
        
        C_Timer.After(0.4, function() self:InspectNext() end)
    end
    
    -- 开始尝试获取装等
    TryGetItemLevel(0)
end

function mppe.RefreshPartyInspector()
    PartyInspector:Start(true)
end

--观察器的回调函数
local function HandleInspectResult(unit, specID, iLv)
    if unit == "COMPLETE" then mppe.RefreshPartyInfo() return end
    local name, realm = UnitFullName(unit)
    local fullName
    if realm == nil or realm == "" or realm == mppe.Mine.Realm then
        fullName = name
        realm = mppe.Mine.Realm
    else
        fullName = string.format("%s-%s", name, realm)
    end
    if not name then return end
    local class = select(2, UnitClass(fullName))
    local NameRealm = string.format("%s-%s", name, realm)
    pe:MPPE_GetPartyBestRuns(fullName)
    pe.PartyMember_Upsert(NameRealm, iLv, class, specID, true, "INSP")
    C_Timer.After(0.5, function() mppe.RefreshPartyInfo() end) 
end

pe:RegisterEvent("ADDON_LOADED")
pe:RegisterEvent("GROUP_JOINED")
pe:RegisterEvent("GROUP_LEFT")
pe:RegisterEvent("GROUP_ROSTER_UPDATE")
pe:RegisterEvent("INSPECT_READY")
local g_Inspector = PartyInspector:New(HandleInspectResult)


pe:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        -- 初始化处理
        C_Timer.After(0.5, function() pe:Lib_Register() end) 
        C_Timer.After(1, function() pe:PartyCheckTimer(true) end) 
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "GROUP_JOINED" then
        --print("MPPE: 已加入队伍")
        C_Timer.After(0.5, function() mppe:RequestPartyInfo() end) 
        -- 清空队列，重新构建
        g_Inspector:Stop()
        C_Timer.After(1, function() pe:PartyCheckTimer(true) end)
        
    elseif event == "GROUP_LEFT" then
        --print("MPPE: 已离开队伍")
        mppe.LFG_Info = {titleName = "", typeName = "", modeName = "", activityID = 0, groupFinderActivityGroupID = 0, mapID = 0}
        g_Inspector:Stop()
        mppe.RefreshPartyInfo()
        pe:PartyCheckTimer(false)
        C_Timer.After(5, function() pe.Party_Cleanup() end) 
    elseif event == "GROUP_ROSTER_UPDATE" then
        --print("MPPE: 队伍成员发生变化")
        C_Timer.After(1, function() mppe:RequestPartyInfo() end) 
        -- 增量更新队列
        local queueSize = g_Inspector:UpdateQueue()
        
        -- 如果队列有成员但观察器未运行，启动它
        if queueSize > 0 and not g_Inspector.isBusy then
            g_Inspector:Start()
        end
        
        -- -- 刷新UI显示
        -- if mppe.RefreshPartyInfo then mppe.RefreshPartyInfo() end
    end
    
    if event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        --print(string.format("消息详情：prefix[%s], channel[%s], sender[%s]\nmessage: [%s]", prefix, channel, sender, message)) 
        if prefix == "AngryKeystones" then
            pe:AKS_Callback(message, sender)
        end
    end
end)

-- 定时检查器
function pe:PartyCheckTimer(enable)
    -- 检查状态是否改变
    local currentState = (partyCheckTimer ~= nil)
    if enable == currentState then return end
    
    -- 取消现有定时器
    if partyCheckTimer then partyCheckTimer:Cancel() partyCheckTimer = nil
    end
    -- 创建新定时器（如果需要）
    if enable then
        -- 定义检查函数
        local function doPartyCheck()
            if IsInGroup() and not IsInRaid() and not UnitAffectingCombat("player") then
                g_Inspector:Start()
                mppe:RequestPartyInfo()
            end
        end
        -- 立即执行一次
        doPartyCheck()
        -- 创建周期性定时器
        partyCheckTimer = C_Timer.NewTicker(181, doPartyCheck)
    end
end




-- =================================================================
-- Lib库相关
function pe:Lib_Register()
    LKS.Register(self, function(keyLevel, keyChallengeMapID, playerRating, sender, channel)
        if channel == "PARTY" and keyLevel > 0 then
            pe.PartyKeystone_Upsert(sender, keyChallengeMapID, keyLevel, playerRating, "LKS")
            --print(string.format("LKS_Callback: 玩家 %s 有 %d 级钥石 (地下城ID: %d, 评分: %d)", sender, keyLevel, keyChallengeMapID, playerRating, sender))  
        end
    end)    
    LOR.RegisterCallback(self, "UnitInfoUpdate", "LOR_UnitCallback")
    LOR.RegisterCallback(self, "GearUpdate", "LOR_GearCallback")
    LOR.RegisterCallback(self, "KeystoneUpdate", "LOR_KeystoneCallback")  

    C_Timer.After(0.5, function() mppe:RequestPartyInfo() end) 
end

function pe:Lib_Unregister()
    LKS.Unregister(self)

    LOR.UnregisterCallback(self, "UnitInfoUpdate")
    LOR.UnregisterCallback(self, "GearUpdate")
    LOR.UnregisterCallback(self, "KeystoneUpdate")
end

function mppe:RequestPartyInfo()
    if IsInGroup() and not IsInRaid() then
        local ksId = C_MythicPlus.GetOwnedKeystoneChallengeMapID() 
	    local ksLv = C_MythicPlus.GetOwnedKeystoneLevel()
        if not IsInInstance() then
            C_ChatInfo.SendAddonMessage("AngryKeystones","request|PARTY", "PARTY")
            LKS.Request("PARTY")
        else
            C_ChatInfo.SendAddonMessage("AngryKeystones","request|PARTY", "INSTANCE")
        end
        LOR.RequestAllData()
    end
end

-- AKS回调函数
function pe:AKS_Callback(message, fullName)
    if message == "request|PARTY" and fullName ~= mppe.Mine.Name then 
        local ksId = C_MythicPlus.GetOwnedKeystoneChallengeMapID() 
	    local ksLv = C_MythicPlus.GetOwnedKeystoneLevel()
        if not ksId or not ksLv then return end
        if not IsInInstance() then
            C_ChatInfo.SendAddonMessage("AngryKeystones",string.format("%d:%d", ksId, ksLv), "PARTY")
        else
            C_ChatInfo.SendAddonMessage("AngryKeystones",string.format("%d:%d", ksId, ksLv), "INSTANCE")
        end
    end
    local ksId, ksLv = string.match(message, "^(%d+):(%d+)$")
    pe.PartyKeystone_Upsert(fullName, ksId, ksLv, nil, "AKS")
    C_Timer.After(0.5, function() mppe.RefreshPartyInfo() end) 
end

-- LOR回调函数
-- 1. 玩家信息回调（职业、专精ID）
function pe:LOR_UnitCallback(unitId, unitInfo, allUnitsInfo)
    pe.PartyMember_Upsert(unitId.name, nil, unitId.class, unitId.specId, nil, "LOR")
    mppe.RefreshPartyInfo()
end

-- 2. 装备信息回调（装备等级）
function pe:LOR_GearCallback(unitId, gearInfo, allGear)
    if type(gearInfo) ~= "table" then return end
    for name, info in pairs(gearInfo) do
        if type(info) == "table" then
            pe.PartyMember_Upsert(
                name,
                rawget(info, "ilevel"),
                nil,
                nil,
                nil,
                "LOR"
            )
        end
    end
    C_Timer.After(0.5, function() mppe.RefreshPartyInfo() end) 
end

-- 3. 钥石信息回调
function pe:LOR_KeystoneCallback(unitName, keystoneInfo, allKeystones)
    if type(keystoneInfo) ~= "table" then return end
    for name, info in pairs(keystoneInfo) do
        if type(info) == "table" then
            pe.PartyKeystone_Upsert(
                name,
                rawget(info, "challengeMapID"),
                rawget(info, "level"),
                rawget(info, "rating"),
                "LOR"
            )
        end
    end
    C_Timer.After(0.5, function() mppe.RefreshPartyInfo() end) 
end

function pe:MPPE_GetPartyBestRuns(fullName)
    --print("pe:MPPE_GetPartyBestRuns")
    local _playerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(fullName)
    if _playerMythicPlusRatingSummary then
        local runs = _playerMythicPlusRatingSummary and _playerMythicPlusRatingSummary.runs
        --mppe.DebugPrint(runs)
        local score = _playerMythicPlusRatingSummary and _playerMythicPlusRatingSummary.currentSeasonScore 
        pe.PartyBest_Upsert_Old(fullName, runs, score, "INSP")
        C_Timer.After(0.5, function() mppe.RefreshPartyInfo() end) 
    end
end




















-- =================================================================
-- 预创建队伍事件
local PartyEvent_LFG = CreateFrame("Frame")
--LFG_Event:RegisterEvent("PLAYER_LOGIN")
PartyEvent_LFG:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE") 
PartyEvent_LFG:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
PartyEvent_LFG:RegisterEvent("LFG_LIST_JOINED_GROUP")
PartyEvent_LFG:SetScript("OnEvent", function(self, event, ...)
    if event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" or event == "LFG_LIST_APPLICATION_STATUS_UPDATED" or event == "LFG_LIST_JOINED_GROUP" then
        --print(event)
        C_Timer.After(0.5, function() PartyEvent_LFG:Update() end) 
    end
end)

function PartyEvent_LFG:Update()
    if IsInGroup() and not IsInRaid() then 
        local LFG_ActiveEntryInfo = C_LFGList.GetActiveEntryInfo()
        if LFG_ActiveEntryInfo then
            --mppe.DebugPrint(LFG_ActiveEntryInfo)
            local _titleName = tostring(LFG_ActiveEntryInfo.name) or ""
            mppe.LFG_Info.titleName = _titleName
            if LFG_ActiveEntryInfo.activityIDs and #LFG_ActiveEntryInfo.activityIDs > 0 then
                mppe.LFG_Info.activityID = LFG_ActiveEntryInfo.activityIDs[1]
                local activityInfo = C_LFGList.GetActivityInfoTable(mppe.LFG_Info.activityID) 
                mppe.LFG_Info.typeName = activityInfo.fullName or ""
                mppe.LFG_Info.modeName = activityInfo.shortName or ""
                mppe.LFG_Info.groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID or 0
                mppe.LFG_Info.mapID = activityInfo.mapID or 0
            end
        end
    end
    --print("LFGFrame:Update Finish - "..mppe.LFG_Info.titleName)
end