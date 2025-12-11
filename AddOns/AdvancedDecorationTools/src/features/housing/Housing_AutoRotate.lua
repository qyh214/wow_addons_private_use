local ADDON_NAME, ADT = ...
local L = ADT and ADT.L or {}

local M = CreateFrame("Frame")
ADT.AutoRotate = M

-- 调试便捷函数
local function D(msg)
    if ADT and ADT.DebugPrint then ADT.DebugPrint(msg) end
end

-- 快速别名
local C_HousingBasicMode = C_HousingBasicMode
local C_HousingCatalog = C_HousingCatalog
local GetActiveHouseEditorMode = C_HouseEditor and C_HouseEditor.GetActiveHouseEditorMode

-- 只读枚举
local HouseEditorMode = Enum and Enum.HouseEditorMode

-- DB 子表（单一权威）
local function GetAutoRotateDB()
    if not _G.ADT_DB then _G.ADT_DB = {} end
    if not _G.ADT_DB.AutoRotate then _G.ADT_DB.AutoRotate = {} end
    local db = _G.ADT_DB.AutoRotate
    if not db.LastRotationByRID then db.LastRotationByRID = {} end
    if not db.SeqIndexByRID then db.SeqIndexByRID = {} end
    if not db.StepByRID then db.StepByRID = {} end
    return db
end

-- 工具：从 entryID 反查 recordID（CatalogEntryInfo.recordID）
local function ExtractRecordIDFromEntry(entryID)
    if type(entryID) == "table" and entryID.recordID then return entryID.recordID end
    if C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfo then
        local info = C_HousingCatalog.GetCatalogEntryInfo(entryID)
        if info and info.recordID then return info.recordID end
    end
    return nil
end

-- 角度归一化到 (-180, 180]
local function NormalizeDeg(d)
    if not d then return 0 end
    local x = math.fmod(d, 360)
    if x <= -180 then x = x + 360 end
    if x > 180 then x = x - 360 end
    return x
end

-- 解析“序列”字符串到数组（仅在 LoadSettings 时调用）
local function ParseSequence(seqStr)
    local result = {}
    for token in string.gmatch(tostring(seqStr or ""), "[^,]+") do
        local v = tonumber(token) or 0
        table.insert(result, NormalizeDeg(v))
    end
    if #result == 0 then
        -- 最小可用：默认两相 0/90
        result[1], result[2] = 0, 90
    end
    return result
end

-- 状态
M._currentRID = nil           -- 当前“抓起预览”的 recordID（StartPlacing* 捕获）
M._rotatedThisPreview = false -- 本次预览是否已经执行过一次自动旋转
M._inPreviewActive = false    -- 预览生命周期（StartPlacing→PlaceSuccess/取消）
M._accumDelta = 0             -- 学习模式：在“预览状态”期间累积的旋转增量（度）
M._seq = {0, 90}              -- 解析后的序列
M._plannedIdx = nil           -- 本次预览计划使用的序列索引（仅 mode=sequence）
M._plannedRID = nil           -- 计划对应的 rid
M._plannedToken = nil         -- 计划生成时对应的预览 token（用于事件配对）
M._previewToken = 0           -- 预览会话 token（每次 StartPlacing 递增）
M._nextIdxByRID = {}          -- 批量放置会话内：期望的“下一索引”（用于纠正意外重置）
-- 待提交（单一权威：仅维护一个 FIFO 队列，避免 rid 覆盖与队列不同步）
M._pendingQueue = {}         -- 每项 { rid=number|string, idx=number, token=number, t=number, skip0=bool }

-- 读取与应用设置（TSP 协议：DB→刷新）
function M:LoadSettings()
    self.enable = ADT.GetDBValue("EnableAutoRotateOnCtrlPlace") ~= false
    self.mode = ADT.GetDBValue("AutoRotateMode") or "preset"
    local preset = tonumber(ADT.GetDBValue("AutoRotatePresetDegrees")) or 90
    self.presetDeg = NormalizeDeg(preset)
    self.scope = ADT.GetDBValue("AutoRotateApplyScope") or "onlyPaint"
    self._seq = ParseSequence(ADT.GetDBValue("AutoRotateSequence"))
    local step = tonumber(ADT.GetDBValue("AutoRotateStepDegrees")) or 15
    if step < 1 then step = 1 end
    self.stepDeg = step
end

function M:GetStepForRID(rid)
    local db = GetAutoRotateDB()
    local v = db.StepByRID and db.StepByRID[tostring(rid or "")] or nil
    return tonumber(v) or self.stepDeg or 15
end

function M:SetStepForRID(rid, step)
    local db = GetAutoRotateDB()
    if not rid or not step then return end
    db.StepByRID[tostring(rid)] = tonumber(step)
    if ADT and ADT.Notify then ADT.Notify(string.format((L["Step for this decor set to %s°"] or "步进已设为 %s°"), tostring(step)), 'success') end
end

function M:ClearStepForRID(rid)
    local db = GetAutoRotateDB()
    if not rid then return end
    db.StepByRID[tostring(rid)] = nil
    if ADT and ADT.Notify then ADT.Notify(L["Step for this decor cleared"] or "已清除此装饰专属步进，使用全局步进", 'info') end
end

-- 计算本次应应用的角度（度）
local function CountPendingForRID(key)
    local c = 0
    for i = 1, #M._pendingQueue do
        if tostring(M._pendingQueue[i].rid) == key then c = c + 1 end
    end
    return c
end

function M:GetPlannedDegrees(rid)
    local db = GetAutoRotateDB()
    local mode = self.mode
    if mode == "preset" then
        return self.presetDeg
    elseif mode == "learn" then
        local v = db.LastRotationByRID[tostring(rid)] or 0
        return NormalizeDeg(v)
    elseif mode == "sequence" then
        -- 使用“计划索引”（每次抓起固定），首次计算= DB索引 + 未提交pending数
        local key = tostring(rid)
        local idx = self._plannedIdx
        if not idx or self._plannedToken ~= self._previewToken or self._plannedRID ~= rid then
            local dbIdx = tonumber(db.SeqIndexByRID[key]) or 1
            local pend = CountPendingForRID(key)
            idx = dbIdx + pend
            -- 环绕
            local nwrap = #self._seq
            while idx > nwrap do idx = idx - nwrap end
            self._plannedIdx = idx
            self._plannedRID = rid
            self._plannedToken = self._previewToken
            if ADT and ADT.DebugPrint then
                ADT.DebugPrint(string.format("[AutoRotate] Plan(seq) calc: rid=%s, dbIdx=%d, pend=%d => idx=%d/%d", key, dbIdx, pend, idx, #self._seq))
            end
        end
        local n = #self._seq
        if idx < 1 or idx > n then idx = 1 end
        local v = self._seq[idx]
        D(string.format("[AutoRotate] Plan seq: rid=%s, idx=%d/%d, v=%s, dbIdx=%s, pend=%d, qlen=%d", tostring(rid), idx, n, tostring(v), tostring((db.SeqIndexByRID[tostring(rid or '')]) or 'nil'), CountPendingForRID(key), #M._pendingQueue))
        return NormalizeDeg(v)
    end
    return 0
end

local function CommitSequenceAdvance(plannedRID, plannedIdx)
    local db = GetAutoRotateDB()
    local key = tostring(plannedRID)
    local n = #M._seq
    if n <= 1 then db.SeqIndexByRID[key] = 1; return end
    local nextIdx = (tonumber(plannedIdx) or 1) + 1
    if nextIdx > n then nextIdx = 1 end
    local oldDB = tonumber(db.SeqIndexByRID[key]) or 1
    db.SeqIndexByRID[key] = nextIdx
    -- 记录“期望的下一值”（已确认），用于紧随其后的 StartPlacing 纠偏
    local now = GetTime and GetTime() or 0
    M._nextIdxByRID[key] = { idx = nextIdx, t = now, token = M._previewToken, speculative = false }
    D(string.format("[AutoRotate] Seq commit: rid=%s, commit=%d -> %d, oldDB=%d, n=%d", key, tonumber(plannedIdx) or 1, nextIdx, oldDB, n))
end

-- 是否满足“当前抓起即可应用”的条件
local function IsPreviewReady()
    local inPlacing = (C_HousingBasicMode and C_HousingBasicMode.IsPlacingNewDecor and C_HousingBasicMode.IsPlacingNewDecor()) or false
    local selected = (C_HousingBasicMode and C_HousingBasicMode.IsDecorSelected and C_HousingBasicMode.IsDecorSelected()) or false
    return inPlacing and selected
end

function M:ShouldApplyOnThisPreview(isPreview)
    if not self.enable then return false end
    -- 允许 StartPlacing 钩子未知 isPreview 时传入 nil：改为用生命周期与状态推断
    local previewFlag = (isPreview == true) or self._inPreviewActive or IsPreviewReady()
    if not previewFlag then D("[AutoRotate] ShouldApply: previewFlag=false"); return false end
    -- 仅在住宅编辑器内
    if not (GetActiveHouseEditorMode and GetActiveHouseEditorMode()) then return false end
    -- 仅在“按住 CTRL 批量放置”时应用，除非 scope=all
    if (self.scope == "onlyPaint") and (not IsControlKeyDown()) then D("[AutoRotate] ShouldApply: scope=onlyPaint + CTRL up"); return false end
    if not self._currentRID then D("[AutoRotate] ShouldApply: no currentRID"); return false end
    if self._rotatedThisPreview then D("[AutoRotate] ShouldApply: already rotated"); return false end
    -- 必须“正在新建放置且已选中”（规避右键转视角导致的瞬时失选）
    if not IsPreviewReady() then D("[AutoRotate] ShouldApply: not ready (not placing/selected)"); return false end
    return true
end

-- 执行一次自动旋转
function M:ApplyAutoRotate()
    local rid = self._currentRID
    if not rid then return end
    local deg = self:GetPlannedDegrees(rid)
    -- 在“序列模式”下，若序列项为 0°，也要视为已消费一次，推进索引；
    -- 否则会在 0° 处反复重试且永远不前进，表现为“没有旋转”。
    if deg == 0 then
        if self.mode == "sequence" then
            if ADT and ADT.DebugPrint then
                ADT.DebugPrint(string.format("[AutoRotate] Apply(skip 0°): rid=%s, mode=%s (waiting commit on place)", tostring(rid), tostring(self.mode)))
            end
            -- 不立即置 rotated 标记；该标记用来阻止重复执行，与 0° 情形无关
            -- 预先设置“守护的下一索引”（投机值），以防下次 StartPlacing 先于 PlaceSuccess 发生
            do
                local db = GetAutoRotateDB(); local key = tostring(rid)
                local n = #self._seq; local planned = self._plannedIdx or (tonumber(db.SeqIndexByRID[key]) or 1)
                local nextIdx = planned + 1; if nextIdx > n then nextIdx = 1 end
                M._nextIdxByRID[key] = { idx = nextIdx, t = GetTime and GetTime() or 0, token = self._previewToken, speculative = true }
                if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("[AutoRotate] Guard set(next) skip0: rid=%s, nextIdx=%d", key, nextIdx)) end
            end
            -- 标记“待提交”：即使后续立即触发下一次 StartPlacing 导致 token 变化，也能在 PlaceSuccess 时正确推进
            do
                -- 去重：若队尾已是同一 rid+token，则不重复入队
                local last = M._pendingQueue[#M._pendingQueue]
                if not (last and last.rid == rid and last.token == self._plannedToken) then
                    table.insert(M._pendingQueue, { rid = rid, idx = self._plannedIdx or 1, token = self._plannedToken, t = GetTime and GetTime() or 0, skip0 = true })
                    if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("[AutoRotate] Pending enqueue(skip0): rid=%s, idx=%s, token=%s, qlen=%d", tostring(rid), tostring(self._plannedIdx), tostring(self._plannedToken), #M._pendingQueue)) end
                else
                    if ADT and ADT.DebugPrint then ADT.DebugPrint("[AutoRotate] Skip duplicate enqueue(skip0) for same token") end
                end
            end
            -- 标记本预览已消费（即使是 0° 也只应计一次），避免重试又再次入队
            self._rotatedThisPreview = true
            -- 不再立即推进序列：改为在 PlaceSuccess 时提交
        end
        return
    end

    D(string.format("[AutoRotate] Apply: rid=%s, plannedIdx=%s, token=%s, deg=%s, mode=%s, scope=%s, step=%s", tostring(rid), tostring(self._plannedIdx), tostring(self._plannedToken), tostring(deg), tostring(self.mode), tostring(self.scope), tostring(self:GetStepForRID(rid))))

    -- 可靠旋转驱动：逐步执行，每步前验证“仍处于预览且选中”；否则短暂延迟重试。
    -- 这样在右键转视角造成的瞬时失选期间不会丢步。
    local unit = self:GetStepForRID(rid)
    local steps = math.floor((math.abs(deg) + (unit/2)) / unit)
    if steps <= 0 then steps = 1 end
    local sign = (deg >= 0) and 1 or -1

    -- 防重入：若已存在同一 token 的旋转任务，则不重复创建
    if self._rotateJob and self._rotateJob.token == self._plannedToken then
        return
    end

    self._suppressLearn = true
    local job = {
        rid = rid,
        remaining = steps,
        sign = sign,
        token = self._plannedToken,
        deadline = (GetTime and (GetTime() + 3.0)) or nil, -- 右键转视角时可能更久，放宽至 ~3s
        started = false,
    }
    self._rotateJob = job

    local function tick()
        -- 若 token 变化或 rid 变化，终止任务
        if M._plannedToken ~= job.token or M._currentRID ~= job.rid then
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[AutoRotate] Job aborted: token/rid changed") end
            M._rotateJob = nil; M._suppressLearn = false; return
        end
        -- 超时保护
        if job.deadline and GetTime and GetTime() > job.deadline then
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[AutoRotate] Job timeout, giving up") end
            M._rotateJob = nil; M._suppressLearn = false; return
        end
        -- 就绪检查
        local ready = IsPreviewReady()
        if not ready then
            C_Timer.After(0.05, tick)
            return
        end
        -- 执行一步旋转
        local ok = pcall(C_HousingBasicMode.RotateDecor, job.sign)
        if ok and not job.started then
            job.started = true
            M._rotatedThisPreview = true -- 仅在第一步真正执行后再标记
        end
        job.remaining = job.remaining - 1
        if job.remaining > 0 then
            C_Timer.After(0.01, tick)
        else
            -- 完成
            M._rotateJob = nil
            C_Timer.After(0.01, function() M._suppressLearn = false end)
        end
    end

    -- 预先设置“守护的下一索引”（投机值），以防下次 StartPlacing 先于 PlaceSuccess 发生
    do
        local db = GetAutoRotateDB(); local key = tostring(rid)
        local n = #self._seq; local planned = self._plannedIdx or (tonumber(db.SeqIndexByRID[key]) or 1)
        local nextIdx = planned + 1; if nextIdx > n then nextIdx = 1 end
        M._nextIdxByRID[key] = { idx = nextIdx, t = GetTime and GetTime() or 0, token = self._previewToken, speculative = true }
        if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("[AutoRotate] Guard set(next): rid=%s, nextIdx=%d", key, nextIdx)) end
    end
    -- 记录“待提交”以抵御 StartPlacing 抢先到来导致的 token 不匹配
    do
        table.insert(M._pendingQueue, { rid = rid, idx = self._plannedIdx or 1, token = self._plannedToken, t = GetTime and GetTime() or 0, skip0 = false })
        if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("[AutoRotate] Pending enqueue: rid=%s, idx=%s, token=%s, qlen=%d", tostring(rid), tostring(self._plannedIdx), tostring(self._plannedToken), #M._pendingQueue)) end
    end

    -- 启动任务
    tick()
    -- 序列推进延后到 PlaceSuccess，确保一次抓起只推进一次，且取消不推进
end

-- 带重试的应用：在抓起后部分帧未就绪（未选中/未进入预览）时尝试多次
function M:TryApplyWithRetries(label)
    -- 延长重试窗口，右键拖拽视角时“就绪”可能被拉长
    local tries = {0, 0.03, 0.06, 0.1, 0.16, 0.22, 0.30, 0.40, 0.50, 0.65, 0.80, 1.00, 1.20}
    for i, t in ipairs(tries) do
        C_Timer.After(t, function()
            if self._rotatedThisPreview then return end
            local ready = IsPreviewReady()
            if self:ShouldApplyOnThisPreview(nil) and ready then
                D(string.format("[AutoRotate] Retry#%d (%s): ready=true", i, tostring(label)))
                self:ApplyAutoRotate()
            end
        end)
    end
end

-- 事件处理
M:SetScript("OnEvent", function(self, event, ...)
    if event == "HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED" or event == "HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED" then
        local hasSelected, targetType, isPreviewBasic = ...
        -- Expert 事件没有 isPreview 参数：用 Basic API 判定当前是否在“新建放置”
        local isPreview = (isPreviewBasic == true) or (C_HousingBasicMode and C_HousingBasicMode.IsPlacingNewDecor and C_HousingBasicMode.IsPlacingNewDecor())
        if hasSelected and isPreview then
            self._inPreviewActive = true
            -- 抓起即安排多次重试（避免切视角导致的迟滞）
            self:TryApplyWithRetries("SelectedChanged")
            -- 若之前进入过“待确认取消”窗口，则视为抖动恢复，取消该窗口
            self._pendingCancelCheckToken = nil
        else
            -- 右键转视角常导致“非选中/非预览”持续较久。
            -- 新逻辑：基于时间窗口 + 右键/鼠标观察状态判断，尽量不误判为取消。
            local checkToken = (self._pendingCancelCheckToken or 0) + 1
            self._pendingCancelCheckToken = checkToken
            local tokenAtSchedule = self._previewToken
            local ridAtSchedule = self._currentRID
            local startAt = (GetTime and GetTime()) or 0

            local function isRightDragging()
                local down = false
                if IsMouseButtonDown then
                    pcall(function()
                        down = IsMouseButtonDown("RightButton") or IsMouseButtonDown(2)
                    end)
                end
                local ml = false
                if IsMouselooking then
                    pcall(function() ml = IsMouselooking() end)
                end
                return down or ml
            end

            local function confirmOrRetry()
                -- 若期间已重新选中或开始了新一轮预览，则放弃本次取消判定
                if M._pendingCancelCheckToken ~= checkToken then return end
                if M._previewToken ~= tokenAtSchedule then return end

                local stillSelected = (C_HousingBasicMode and C_HousingBasicMode.IsDecorSelected and C_HousingBasicMode.IsDecorSelected()) or false
                local stillPlacing  = (C_HousingBasicMode and C_HousingBasicMode.IsPlacingNewDecor and C_HousingBasicMode.IsPlacingNewDecor()) or false
                if stillSelected and stillPlacing then
                    -- 抖动恢复：继续尝试自动旋转
                    M._inPreviewActive = true
                    M:TryApplyWithRetries("SelectedChanged-Resume")
                    return
                end

                local now = (GetTime and GetTime()) or startAt
                local elapsed = now - startAt
                local dragging = isRightDragging()

                -- 当右键拖拽中：持续等待，不按取消处理
                if dragging then
                    C_Timer.After(0.10, confirmOrRetry)
                    return
                end

                -- 未拖拽：给出宽限（普通 0.6s；若仍按 CTRL 则 1.2s）后再判定取消
                local grace = IsControlKeyDown() and 1.2 or 0.6
                if elapsed < grace then
                    C_Timer.After(0.10, confirmOrRetry)
                    return
                end

                -- 确认取消：清理与本 token 关联的 pending/guard（仅限当前 rid）
                M._inPreviewActive = false
                local rid = ridAtSchedule
                if rid then
                    for i = #M._pendingQueue, 1, -1 do
                        local it = M._pendingQueue[i]
                        if it and it.rid == rid and it.token == tokenAtSchedule then
                            table.remove(M._pendingQueue, i)
                            if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("[AutoRotate] Pending dequeue(cancel): rid=%s, token=%s, qlen=%d", tostring(rid), tostring(tokenAtSchedule), #M._pendingQueue)) end
                            break
                        end
                    end
                    local key = tostring(rid)
                    local guard = M._nextIdxByRID[key]
                    if guard and guard.speculative and guard.token == tokenAtSchedule then
                        M._nextIdxByRID[key] = nil
                    end
                end
            end

            -- 启动确认流程（时间窗 + 右键状态）
            C_Timer.After(0.10, confirmOrRetry)
        end
    elseif event == "HOUSING_DECOR_PLACE_SUCCESS" then
        -- 将事件与当前预览配对（防误提交）
        local decorGUID, size, isNew, isPreview = ...
        local eventRID
        pcall(function()
            if C_HousingDecor and C_HousingDecor.GetDecorInstanceInfoForGUID and decorGUID then
                local info = C_HousingDecor.GetDecorInstanceInfoForGUID(decorGUID)
                eventRID = info and info.decorID or nil
            end
        end)
        D(string.format("[AutoRotate] PLACE_SUCCESS: plannedRID=%s, eventRID=%s, token=%s~%s, rotated=%s, qlen(before)=%d",
            tostring(self._plannedRID), tostring(eventRID), tostring(self._plannedToken), tostring(self._previewToken), tostring(self._rotatedThisPreview), #M._pendingQueue))

        -- 1) 正常：token 严格匹配；2) 备选：使用我们维护的 FIFO 队列
        local matchedStrict = (self._plannedToken ~= nil) and (self._plannedToken == self._previewToken)
        local matchedByQueue = false
        local pendItem
        if not matchedStrict then
            pendItem = table.remove(M._pendingQueue, 1)
            matchedByQueue = (pendItem ~= nil)
        else
            -- 严格匹配：从队列中找出当前 token 对应项（若存在），同时拿到 skip0 标记
            for i = #M._pendingQueue, 1, -1 do
                local it = M._pendingQueue[i]
                if it and it.token == self._plannedToken then
                    pendItem = it
                    table.remove(M._pendingQueue, i)
                    if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("[AutoRotate] Pending dequeue(commit strict): rid=%s, token=%s, qlen=%d", tostring(it.rid), tostring(it.token), #M._pendingQueue)) end
                    break
                end
            end
        end
        local matched = matchedStrict or matchedByQueue
        D(string.format("[AutoRotate] PLACE_SUCCESS match: strict=%s, queue=%s, qlen=%d", tostring(matchedStrict), tostring(matchedByQueue), #M._pendingQueue))

        -- 仅在事件与本轮计划完全匹配时才做后续逻辑（补旋转与序列提交）
        if matched then
            -- 移除“落地后补旋转”以避免双重旋转/错位，由预览阶段的 Apply 保证
            -- 计算要提交的索引：优先用待提交表中的 idx，避免与当前 plannedIdx 冲突
            local commitRID = (pendItem and pendItem.rid) or eventRID or self._plannedRID
            local commitIdx = (pendItem and pendItem.idx) or self._plannedIdx or 1
            local allowCommit = true
            if self.mode == "sequence" then
                -- 仅当预览期间真的发生了旋转，或此项本身为 0°（skip0）时才推进序列；
                -- 这样可避免“旋转未发生但索引已推进”的错位。
                local wasRotated = (self._rotatedThisPreview == true)
                local isSkip0 = (pendItem and pendItem.skip0) or false
                allowCommit = wasRotated or isSkip0
                if not allowCommit and ADT and ADT.DebugPrint then
                    ADT.DebugPrint(string.format("[AutoRotate] PLACE_SUCCESS no-commit: rotated=false & not skip0 (rid=%s, idx=%s)", tostring(commitRID), tostring(commitIdx)))
                end
            end
            if (self.mode == "sequence") and commitRID then
                if allowCommit then
                    CommitSequenceAdvance(commitRID, commitIdx)
                    D(string.format("[AutoRotate] PLACE_SUCCESS committed: rid=%s, idx=%s, qlen(after)=%d, dbNow=%s", tostring(commitRID), tostring(commitIdx), #M._pendingQueue, tostring((GetAutoRotateDB().SeqIndexByRID[tostring(commitRID or '')]) or 'nil')))
                else
                    -- 未旋转成功：撤销此前设置的“下一索引”投机值，保持 DB 不变，保证下一轮仍使用相同索引
                    local key = tostring(commitRID)
                    local guard = M._nextIdxByRID[key]
                    if guard and guard.speculative then M._nextIdxByRID[key] = nil end
                    D(string.format("[AutoRotate] PLACE_SUCCESS rollback(nextIdx guard): rid=%s (no commit)", key))
                end
            end
        end

        -- 学习模式：仅当“你有手动改动”时才更新学习角度；否则保持上次值，避免被 0 覆盖
        local db = GetAutoRotateDB()
        local key = tostring(self._currentRID or "")
        if key ~= "" then
            local delta = NormalizeDeg(self._accumDelta or 0)
            local threshold = math.max((self:GetStepForRID(self._currentRID) or 15) * 0.5, 1) -- 半步或至少1度
            if math.abs(delta) >= threshold then
                db.LastRotationByRID[key] = delta
                if ADT and ADT.DebugPrint then ADT.DebugPrint("[AutoRotate] Learn(Update): rid="..key..", deg="..tostring(delta)) end
            else
                if ADT and ADT.DebugPrint then ADT.DebugPrint("[AutoRotate] Learn(Skip keep last): rid="..key..", delta="..tostring(delta)) end
            end
            -- 若事件与计划匹配，才推进序列与清理状态；否则忽略该次 PlaceSuccess
            if matched then
                -- 提交序列推进（仅当本轮确实执行过一次自动旋转或遇到0°被视为已消费）
                -- 已在上文 matched 分支处理，这里不重复提交
                -- 预览闭环后，重置状态
                self._rotatedThisPreview = false
                self._accumDelta = 0
                self._inPreviewActive = false
                self._plannedIdx = nil
                self._plannedRID = nil
                self._plannedToken = nil
            end
        end
    elseif event == "HOUSING_DECOR_PLACE_FAILURE" then
        -- 明确的失败/取消：按“取消”流程清理一次（更可靠地对应非放置退出的场景）
        local tokenAtSchedule = self._previewToken
        local rid = self._currentRID
        self._inPreviewActive = false
        if rid then
            for i = #M._pendingQueue, 1, -1 do
                local it = M._pendingQueue[i]
                if it and it.rid == rid and it.token == tokenAtSchedule then
                    table.remove(M._pendingQueue, i)
                    if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("[AutoRotate] Pending dequeue(failure): rid=%s, token=%s, qlen=%d", tostring(rid), tostring(tokenAtSchedule), #M._pendingQueue)) end
                    break
                end
            end
            local key = tostring(rid)
            local guard = M._nextIdxByRID[key]
            if guard and guard.speculative and guard.token == tokenAtSchedule then
                M._nextIdxByRID[key] = nil
            end
        end
    end
end)

M:RegisterEvent("HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED")
M:RegisterEvent("HOUSING_DECOR_PLACE_SUCCESS")
M:RegisterEvent("HOUSING_DECOR_PLACE_FAILURE")

-- 钩子：捕获“开始抓起”的 recordID；并在预览期间累加 RotateDecor 的增量
do
    if C_HousingBasicMode and C_HousingBasicMode.StartPlacingNewDecor then
        hooksecurefunc(C_HousingBasicMode, "StartPlacingNewDecor", function(entryID)
            -- 新的预览会话 token
            M._previewToken = (M._previewToken or 0) + 1
            M._currentRID = ExtractRecordIDFromEntry(entryID)
            M._rotatedThisPreview = false
            M._accumDelta = 0
            M._inPreviewActive = true
            -- 纠偏：若刚刚提交过下一索引，且时间窗口内，则强制使用该索引
            do
                local key = tostring(M._currentRID or "")
                local guard = key ~= "" and M._nextIdxByRID[key] or nil
                local now = GetTime and GetTime() or 0
                if guard and guard.t and (now - guard.t) <= 3.0 then
                    -- 不写 DB，仅对本轮预览进行“计划索引覆盖”
                    M._plannedIdx = guard.idx
                    M._plannedRID = M._currentRID
                    M._plannedToken = M._previewToken
                    if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("[AutoRotate] Guard plan override idx=%d (rid=%s)", guard.idx, key)) end
                end
            end
            D(string.format("[AutoRotate] StartPlacing(New): rid=%s, dbIdx=%s, qlen=%d", tostring(M._currentRID), tostring((GetAutoRotateDB().SeqIndexByRID[tostring(M._currentRID or '')]) or 'nil'), #M._pendingQueue))
            -- 在 StartPlacing 阶段也安排重试，确保就绪后旋转
            M:TryApplyWithRetries("StartPlacingNew")
        end)
    end
    if C_HousingBasicMode and C_HousingBasicMode.StartPlacingPreviewDecor then
        hooksecurefunc(C_HousingBasicMode, "StartPlacingPreviewDecor", function(decorRecordID)
            -- 新的预览会话 token
            M._previewToken = (M._previewToken or 0) + 1
            M._currentRID = decorRecordID
            M._rotatedThisPreview = false
            M._accumDelta = 0
            M._inPreviewActive = true
            -- 同样做序列索引纠偏
            do
                local key = tostring(M._currentRID or "")
                local guard = key ~= "" and M._nextIdxByRID[key] or nil
                local now = GetTime and GetTime() or 0
                if guard and guard.t and (now - guard.t) <= 3.0 then
                    -- 不写 DB，仅对本轮预览进行“计划索引覆盖”
                    M._plannedIdx = guard.idx
                    M._plannedRID = M._currentRID
                    M._plannedToken = M._previewToken
                    if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("[AutoRotate] Guard plan override idx=%d (rid=%s)", guard.idx, key)) end
                end
            end
            D(string.format("[AutoRotate] StartPlacing(Preview): rid=%s, dbIdx=%s, qlen=%d", tostring(M._currentRID), tostring((GetAutoRotateDB().SeqIndexByRID[tostring(M._currentRID or '')]) or 'nil'), #M._pendingQueue))
            M:TryApplyWithRetries("StartPlacingPreview")
        end)
    end
    if C_HousingBasicMode and C_HousingBasicMode.RotateDecor then
        hooksecurefunc(C_HousingBasicMode, "RotateDecor", function(deg)
            -- 在预览生命周期内累加（不依赖 IsPlacingNewDecor 瞬态），避免被事件顺序打断
            if M._inPreviewActive and not M._suppressLearn then
                local d = tonumber(deg) or 0
                -- 官方按键传入的是 ±1：按“步进角度”换算到度；若传的是度值则直接累加
                local delta
                if math.abs(d) <= 2 then
                    delta = d * (M:GetStepForRID(M._currentRID) or 15)
                else
                    delta = d
                end
                M._accumDelta = NormalizeDeg((M._accumDelta or 0) + delta)
            end
        end)
    end
end

-- 设置模块（接入 CommandDock）
local function RegisterSettings()
    if not (ADT and ADT.CommandDock and ADT.CommandDock.AddModule) then return end
    local CC = ADT.CommandDock
    -- 将自动旋转设置独立到“AutoRotate”分类；ui 顺序从 1 起
    local uiOrderBase = 1

    -- 开关：启用自动旋转
    CC:AddModule({
        name = L["Enable Auto Rotate on CTRL"] or "Enable Auto Rotate (Batch)",
        dbKey = 'EnableAutoRotateOnCtrlPlace',
        description = L["Enable Auto Rotate on CTRL tooltip"] or "When holding CTRL to batch place, the decor will be auto-rotated at grab time.",
        toggleFunc = function(state)
            ADT.SetDBValue('EnableAutoRotateOnCtrlPlace', state)
            if ADT and ADT.AutoRotate and ADT.AutoRotate.LoadSettings then ADT.AutoRotate:LoadSettings() end
        end,
        categoryKeys = { 'AutoRotate' },
        uiOrder = uiOrderBase,
    })

    -- 模式：预设/学习/序列
    CC:AddModule({
        name = L["Auto Rotate Mode"] or "Auto Rotate Mode",
        dbKey = 'AutoRotateMode',
        type = 'dropdown',
        options = {
            { value = 'preset',  text = L["Mode Preset Angle"] or "Preset Angle" },
            { value = 'learn',   text = L["Mode Learn Last"] or "Learn Last Used" },
            { value = 'sequence',text = L["Mode Sequence"] or "Sequence" },
        },
        description = L["Auto Rotate Mode tooltip"] or "Preset: always rotate by the specified degrees. Learn: reuse the last rotation you used before placing. Sequence: cycle through configured angles.",
        toggleFunc = function(value)
            ADT.SetDBValue('AutoRotateMode', value)
            if ADT and ADT.AutoRotate and ADT.AutoRotate.LoadSettings then ADT.AutoRotate:LoadSettings() end
        end,
        categoryKeys = { 'AutoRotate' },
        uiOrder = uiOrderBase + 1,
    })

    -- 预设角度（-180..180 常见值，覆盖正负方向）
    CC:AddModule({
        name = L["Preset Angle"] or "Preset Angle",
        dbKey = 'AutoRotatePresetDegrees',
        type = 'dropdown',
        options = (function()
            local vals = { -180, -150, -135, -120, -90, -60, -45, -30, -15, 0, 15, 30, 45, 60, 90, 120, 135, 150, 180 }
            local t = {}
            for _, v in ipairs(vals) do table.insert(t, { value = v, text = (v.."°") }) end
            return t
        end)(),
        description = L["Preset Angle tooltip"] or "Used when Mode=Preset.",
        toggleFunc = function(value)
            ADT.SetDBValue('AutoRotatePresetDegrees', value)
            if ADT and ADT.AutoRotate and ADT.AutoRotate.LoadSettings then ADT.AutoRotate:LoadSettings() end
        end,
        categoryKeys = { 'AutoRotate' },
        uiOrder = uiOrderBase + 2,
    })

    -- 序列预设（覆盖常用正负组合）
    -- 自定义序列输入弹窗（使用暴雪 StaticPopup 模板）
    local function ShowSequenceInput(owner)
        local cur = tostring(ADT.GetDBValue('AutoRotateSequence') or "0,90")
        if not StaticPopupDialogs then return end
        if not StaticPopupDialogs["ADT_INPUT_SEQUENCE"] then
            StaticPopupDialogs["ADT_INPUT_SEQUENCE"] = {
                text = (L["Enter sequence angles"] or "请输入序列角度（最多4个，逗号分隔）"),
                button1 = (OKAY or "OK"),
                button2 = (CANCEL or "Cancel"),
                timeout = 0,
                whileDead = 1,
                hideOnEscape = 1,
                hasEditBox = 1,
                maxLetters = 64,
                OnShow = function(self)
                    local eb = self.editBox or self.EditBox
                    if not eb then return end
                    eb:SetAutoFocus(true)
                    eb:SetText(tostring(self.data or cur or "0,90"))
                    eb:HighlightText()
                end,
                OnAccept = function(self)
                    local eb = self.editBox or self.EditBox
                    local txt = eb and eb:GetText() or ""
                    local list = {}
                    for token in string.gmatch(txt, "[^,]+") do
                        token = token:gsub("%s+", "")
                        local v = tonumber(token)
                        if v then
                            table.insert(list, NormalizeDeg(v))
                            if #list >= 4 then break end
                        end
                    end
                    if #list > 0 then
                        local norm = table.concat(list, ",")
                        ADT.SetDBValue('AutoRotateSequence', norm)
                        if owner and owner.data and owner.data.toggleFunc then
                            owner.data.toggleFunc(norm)
                        elseif ADT and ADT.AutoRotate and ADT.AutoRotate.LoadSettings then
                            ADT.AutoRotate:LoadSettings()
                        end
                        if owner and owner.UpdateDropdownLabel then
                            owner:UpdateDropdownLabel()
                        end
                        if ADT and ADT.Notify then ADT.Notify(string.format((L["Sequence saved: %s"] or "序列已保存：%s"), norm), 'success') end
                    else
                        if ADT and ADT.Notify then ADT.Notify(L["Invalid sequence input"] or "输入无效：请用逗号分隔的数字", 'error') end
                    end
                end,
                EditBoxOnEnterPressed = function(self)
                    local parent = self:GetParent()
                    StaticPopup_OnClick(parent, 1)
                    parent:Hide()
                end,
            }
        end
        StaticPopup_Show("ADT_INPUT_SEQUENCE", nil, nil, cur)
    end

    CC:AddModule({
        name = L["Sequence Angles"] or "Sequence Angles",
        dbKey = 'AutoRotateSequence',
        type = 'dropdown',
        options = {
            { value = "0,90",             text = "0°,90°" },
            { value = "0,-90",            text = "0°,-90°" },
            { value = "0,180",            text = "0°,180°" },
            { value = "0,90,180,270",     text = "0°,90°,180°,270°" },
            { value = "0,-90,-180,-270",  text = "0°,-90°,-180°,-270°" },
            { value = "0,45,90,135",      text = "0°,45°,90°,135°" },
            { value = "0,-45,-90,-135",   text = "0°,-45°,-90°,-135°" },
            { value = "0,60,120,180",     text = "0°,60°,120°,180°" },
        },
        description = L["Sequence Angles tooltip"] or "Used when Mode=Sequence. Will cycle each time you grab a preview.",
        toggleFunc = function(value)
            ADT.SetDBValue('AutoRotateSequence', value)
            if ADT and ADT.AutoRotate and ADT.AutoRotate.LoadSettings then ADT.AutoRotate:LoadSettings() end
        end,
        -- 自定义：在下拉菜单尾部追加“自定义…”按钮
        dropdownBuilder = function(owner, root)
            -- 注意：此处由 SettingsPanel 传入 owner（即条目按钮本体）。
            -- 选择项后必须立即：1) 写入DB；2) 调用模块原有 toggleFunc；3) 刷新当前条目的显示文本。
            local function IsSelected(value)
                return ADT.GetDBValue('AutoRotateSequence') == value
            end
            local function SetSelected(value)
                -- 1) 更新配置（silent=true 防止重复刷新）
                ADT.SetDBValue('AutoRotateSequence', value, true)
                -- 2) 复用模块的 toggleFunc 以保持单一权威（而不是在此复制逻辑）
                if owner and owner.data and owner.data.toggleFunc then
                    owner.data.toggleFunc(value)
                elseif ADT and ADT.AutoRotate and ADT.AutoRotate.LoadSettings then
                    -- 兜底：旧结构兼容（仍然调一次加载）
                    ADT.AutoRotate:LoadSettings()
                end
                -- 3) 立刻刷新该条目的标签文本，使用户看到实时变更
                if owner and owner.UpdateDropdownLabel then
                    owner:UpdateDropdownLabel()
                end
                return MenuResponse.Close
            end
            for _, opt in ipairs({
                { value = "0,90",             text = "0°,90°" },
                { value = "0,-90",            text = "0°,-90°" },
                { value = "0,180",            text = "0°,180°" },
                { value = "0,90,180,270",     text = "0°,90°,180°,270°" },
                { value = "0,-90,-180,-270",  text = "0°,-90°,-180°,-270°" },
                { value = "0,45,90,135",      text = "0°,45°,90°,135°" },
                { value = "0,-45,-90,-135",   text = "0°,-45°,-90°,-135°" },
                { value = "0,60,120,180",     text = "0°,60°,120°,180°" },
            }) do
                root:CreateRadio(opt.text, IsSelected, SetSelected, opt.value)
            end
            root:CreateDivider()
            root:CreateButton(L["Custom Sequence…"] or "自定义…", function()
                ShowSequenceInput(owner)
                return MenuResponse.Close
            end)
        end,
        categoryKeys = { 'AutoRotate' },
        uiOrder = uiOrderBase + 3,
    })

    -- 作用范围：仅 CTRL 批量 或 全入口
    CC:AddModule({
        name = L["Apply Scope"] or "Apply Scope",
        dbKey = 'AutoRotateApplyScope',
        type = 'dropdown',
        options = {
            { value = 'onlyPaint', text = L["Scope Only Paint"] or "Only CTRL Batch Place" },
            { value = 'all',       text = L["Scope All Starts"] or "All Start Paths" },
        },
        description = L["Apply Scope tooltip"] or "Only CTRL Batch Place: apply when CTRL is held. All Start Paths: also apply to catalog/history/clipboard/duplicate.",
        toggleFunc = function(value)
            ADT.SetDBValue('AutoRotateApplyScope', value)
            if ADT and ADT.AutoRotate and ADT.AutoRotate.LoadSettings then ADT.AutoRotate:LoadSettings() end
        end,
        categoryKeys = { 'AutoRotate' },
        uiOrder = uiOrderBase + 4,
    })

    -- 基本模式单步角度（用于把一次方向单位换算为多少度）
    CC:AddModule({
        name = L["Rotation Step"] or "Rotation Step",
        dbKey = 'AutoRotateStepDegrees',
        type = 'dropdown',
        options = {
            { value = 5,   text = "5°" },
            { value = 7.5, text = "7.5°" },
            { value = 10,  text = "10°" },
            { value = 15,  text = "15°" },
            { value = 22.5,text = "22.5°" },
            { value = 30,  text = "30°" },
        },
        description = L["Rotation Step tooltip"] or "One unit sent to RotateDecor() equals this many degrees in Basic Mode. Adjust to match your client feel.",
        toggleFunc = function(value)
            ADT.SetDBValue('AutoRotateStepDegrees', tonumber(value))
            if ADT and ADT.AutoRotate and ADT.AutoRotate.LoadSettings then ADT.AutoRotate:LoadSettings() end
        end,
        categoryKeys = { 'AutoRotate' },
        uiOrder = uiOrderBase + 5,
    })

    -- 专属步进（当前抓取的装饰）
    CC:AddModule({
        name = L["Per-decor Step"] or "Per-decor Step (Current)",
        dbKey = 'AutoRotateStepRID',
        type = 'dropdown',
        options = {
            { value = 15,  text = "15°" },
            { value = 22.5,text = "22.5°" },
            { value = 30,  text = "30°" },
            { value = 45,  text = "45°" },
            { value = 90,  text = "90°" },
            { value = -1,  text = (L["Reset to global"] or "使用全局值") },
        },
        description = L["Per-decor Step tooltip"] or "Sets a dedicated step for the currently grabbed decor (recordID). If none grabbed, uses the last grabbed one in this session.",
        toggleFunc = function(value)
            local rid = M._currentRID
            if not rid then
                if ADT and ADT.Notify then ADT.Notify(L["Grab an item to calibrate"] or "请先抓起一个装饰以校准", 'info') end
                return
            end
            if tonumber(value) == -1 then
                M:ClearStepForRID(rid)
            else
                M:SetStepForRID(rid, tonumber(value))
            end
        end,
        categoryKeys = { 'AutoRotate' },
        uiOrder = uiOrderBase + 6,
    })
end

-- 初始化
M:LoadSettings()
RegisterSettings()

-- 绑定设置事件：避免每个选项重复写一份 toggleFunc
if ADT and ADT.Settings and ADT.Settings.On then
    for _, k in ipairs({
        'EnableAutoRotateOnCtrlPlace',
        'AutoRotateMode',
        'AutoRotatePresetDegrees',
        'AutoRotateSequence',
        'AutoRotateApplyScope',
        'AutoRotateStepDegrees',
    }) do
        ADT.Settings.On(k, function()
            if ADT and ADT.AutoRotate and ADT.AutoRotate.LoadSettings then
                ADT.AutoRotate:LoadSettings()
            end
        end)
    end
end

-- 注册“模块提供者”，以便在语言切换导致 CommandDock 重建时，重新注入本模块的设置项。
if ADT and ADT.CommandDock and ADT.CommandDock.RegisterModuleProvider then
    ADT.CommandDock:RegisterModuleProvider(function(CC)
        -- 复用单一权威的注册函数，避免重复实现
        RegisterSettings()
    end)
end
