BuildEnv(...)

LocomotiveIntroduce = Addon:NewModule(CreateFrame('Frame', nil, MainPanel), 'LocomotiveIntroduce', 'AceEvent-3.0', 'AceTimer-3.0', 'AceSerializer-3.0',
  'AceBucket-3.0')


local  title = {
    [0] = "勇士，打算何时开启你的挑战呢？",
    [1] = "不错的开端，勇士再接再厉！",
    [2] = "初露锋芒，长路仍漫漫！",
    [3] = "初露锋芒，长路仍漫漫！",
    [4] = "征程过半，前路星光灿烂！",
    [5] = "全力爆发，做最后的冲刺吧！",
    [6] = "全力爆发，做最后的冲刺吧！",
    [7] = "只差一步，荣耀触手可及！",
    [8] = "已符合火车头认证资格！",
}

--- 创建一个带背景和边框的 Frame
function CreateStyledFrame(parentFrame, name)
    local frame = CreateFrame("Frame", name, parentFrame, "BackdropTemplate")

    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.2, 0.8)      -- 背景颜色（RGBA）
    frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)  -- 边框颜色（RGBA）

    return frame
end

function LocomotiveIntroduce:CreateClippedScrollFrame(parent, name, width, height)
    -- 主剪裁框（带背景）
    local clipFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    clipFrame:SetSize(width, height)
    clipFrame:SetClipsChildren(true)

    -- 内容容器（自动调整高度）
    local content = CreateFrame("Frame", nil, clipFrame)
    content:SetSize(width - 20, 1) -- 初始高度设为1
    content:SetPoint("TOPLEFT", 5, -5)

    -- 滚动控制参数
    clipFrame.scrollOffset = 0
    clipFrame.maxOffset = 0
    clipFrame.content = content

    -- 鼠标滚轮处理（支持按住SHIFT加速）
    clipFrame:EnableMouseWheel(true)
    clipFrame:SetScript("OnMouseWheel", function(self, delta)
        local scrollStep = IsShiftKeyDown() and 50 or 20
        self:SetScrollOffset(self.scrollOffset - (delta * scrollStep))
    end)

    -- 设置滚动偏移
    function clipFrame:SetScrollOffset(offset)
        offset = math.max(0, math.min(offset, self.maxOffset))
        if self.scrollOffset ~= offset then
            self.scrollOffset = offset
            self.content:SetPoint("TOPLEFT", 5, -5 + offset)
        end
    end

    -- 更新滚动范围
    function clipFrame:UpdateScrollRange()
        local contentHeight = self.content:GetHeight()
        local frameHeight = self:GetHeight()
        self.maxOffset = math.max(0, contentHeight - frameHeight + 10)
        self:SetScrollOffset(math.min(self.scrollOffset, self.maxOffset))
    end

    return content, clipFrame
end

function ReleaseChildren(frame)
    if not frame or not frame.GetChildren then return end

    -- 逆向遍历防止删除时的索引错乱
    local children = {frame:GetChildren()}
    for i = #children, 1, -1 do
        local child = children[i]

        -- 先解除所有可能的回调
        child:SetScript("OnUpdate", nil)
        child:SetScript("OnEnter", nil)
        child:SetScript("OnLeave", nil)
        child:SetScript("OnClick", nil)

        -- 特殊处理文字和纹理
        if child:GetObjectType() == "FontString" then
            child:SetText("")
        elseif child:GetObjectType() == "Texture" then
            child:SetTexture(nil)
        end

        -- 通用清理
        child:ClearAllPoints()
        child:Hide()
        child:SetParent(nil)

        -- 兼容AceGUI等框架
        if child.Release then
            child:Release()
        end
    end
end

function LocomotiveIntroduce:OnInitialize()
    GUI:Embed(self, 'Tab')
    MainPanel:RegisterPanel('火车头', self, { after = '管理活动' })

    -- 顶部信息框（保留原有样式）
    local upperLeftFrame = CreateStyledFrame(self, "upperLeftFrame")
    upperLeftFrame:SetSize(300, 50)
    upperLeftFrame:SetPoint("TOPLEFT", 0, 5)

    local playerName = GetUnitName("player", true)
    self.LeaderNameLabel = upperLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.LeaderNameLabel:SetPoint("TOP", 0, -5)
    self.LeaderNameLabel:SetText(playerName)

    self.HintLabel = upperLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.HintLabel:SetPoint("TOP", self.LeaderNameLabel, "BOTTOM", 0, -5)
    self.HintLabel:SetText(title[0])
    self.HintLabel:SetTextColor(0.4, 0.6, 1.0)

    -- 已通关列表区域
    self.completedContainer = CreateStyledFrame(self, "CompletedContainer")
    self.completedContainer:SetSize(300, 110)
    self.completedContainer:SetPoint("TOP", upperLeftFrame, "BOTTOM", 0, -30)

    self.completedHeader = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.completedHeader:SetPoint("BOTTOMLEFT", self.completedContainer, "TOPLEFT", 10, 5)
    self.completedHeader:SetText("已限时通关10层或以上：")
    self.completedHeader:SetTextColor(0, 1, 0)

    self.completedScrollChild, self.completedScrollFrame = self:CreateClippedScrollFrame(
        self.completedContainer, "Completed", 290, 100
    )
    self.completedScrollFrame:SetPoint("TOPLEFT", 5, -5)

    -- 未通关列表区域
    self.incompleteContainer = CreateStyledFrame(self, "IncompleteContainer")
    self.incompleteContainer:SetSize(300, 110)
    self.incompleteContainer:SetPoint("TOP", self.completedContainer, "BOTTOM", 0, -30)

    self.incompleteHeader = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.incompleteHeader:SetPoint("BOTTOMLEFT", self.incompleteContainer, "TOPLEFT", 10, 5)
    self.incompleteHeader:SetText("尚未限时通关10层或以上：")
    self.incompleteHeader:SetTextColor(1, 0, 0)

   self.incompleteScrollChild, self.incompleteScrollFrame = self:CreateClippedScrollFrame(
        self.incompleteContainer, "Incomplete", 290, 100
    )
    self.incompleteScrollFrame:SetPoint("TOPLEFT", 5, -5)

    local childRightFrameTemp = CreateStyledFrame(self, "childRightFrameTemp")
    childRightFrameTemp:SetSize(674, 330)
    childRightFrameTemp:SetPoint("TOPLEFT", upperLeftFrame, "TOPRIGHT", 0, 0)

    -- 右侧图片区域
    local childRightFrame = CreateFrame("Frame", "childRightFrame", self, "BackdropTemplate")
    childRightFrame:SetSize(666, 322)
    childRightFrame:SetPoint("TOPLEFT", childRightFrameTemp, "TOPLEFT", 4, -4)

    local texture = childRightFrame:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints(childRightFrame)
    texture:SetTexture("Interface/AddOns/MeetingStone/Media/Locomotive/LocomotiveIntroduce")

    self:SetScript("OnShow", self.UpdateDungeonStatus) -- 界面显示时更新
end

function LocomotiveIntroduce:UpdateDungeonStatus()
    -- 防抖：如果已经在更新中则跳过
    if self.updating then return end
    self.updating = true

    -- 延迟0.5秒执行（避免事件密集触发）
    C_Timer.After(0.5, function()
        self:RealUpdateDungeonStatus()
    end)
end

function LocomotiveIntroduce:HasCompleted10Plus(mapID)
    local runs = C_MythicPlus.GetRunHistory(false, true)
    local bestRun = nil
    for _, run in ipairs(runs or {}) do
        if run.mapChallengeModeID == mapID and run.completed then
            if not bestRun or run.level > bestRun.level then
                bestRun = run
            end
        end
    end
    return bestRun  -- 返回最佳记录，无论是否达到10层
end

function LocomotiveIntroduce:RealUpdateDungeonStatus()
    -- 数据准备
    local mapTable = C_ChallengeMode.GetMapTable()
    if not mapTable or #mapTable == 0 then return end

    -- 保存当前滚动位置
    local lastCompletedScroll = self.completedScrollFrame.scrollOffset or 0
    local lastIncompleteScroll = self.incompleteScrollFrame.scrollOffset or 0

    -- 清理并复用现有元素
    self:ReleaseListItems(true)   -- 已通关列表
    self:ReleaseListItems(false)  -- 未通关列表

    -- 初始化计数器和内容高度
    local completedCount, incompleteCount = 0, 0
    local totalCompleted = 0
    local contentWidth = self.completedScrollChild:GetWidth() - 10

    -- 遍历所有副本
    for idx, dungeonID in ipairs(mapTable) do
        -- 获取副本信息
        local dungeonName, _, _, texture = C_ChallengeMode.GetMapUIInfo(dungeonID)
        if not dungeonName then
            dungeonName = "未知副本("..dungeonID..")"
            texture = "Interface\\ICONS\\Achievement_Dungeon_GloryoftheHero"
        end

        local bestRun = C_MythicPlus.GetSeasonBestForMap(dungeonID)
        local isCompleted = bestRun and bestRun.level >= 10  -- 只显示10层以上的

        -- 创建/复用列表项
        local itemFrame, isNew = self:GetOrCreateListItem(isCompleted, isCompleted and completedCount or incompleteCount)

        -- 配置显示内容
        if isCompleted then
            completedCount = completedCount + 1
            self:SetupCompletedItem(itemFrame, dungeonName, bestRun.level, texture)
        else
            incompleteCount = incompleteCount + 1
            local level = bestRun and bestRun.level or 0
            self:SetupIncompleteItem(itemFrame, dungeonName, level, texture)
        end

        -- 定位元素
        itemFrame:ClearAllPoints()
        if isCompleted then
            itemFrame:SetPoint("TOPLEFT", self.completedScrollChild, 5, -((completedCount-1)*30 + 5))
        else
            itemFrame:SetPoint("TOPLEFT", self.incompleteScrollChild, 5, -((incompleteCount-1)*30 + 5))
        end
        itemFrame:Show()

        -- 统计总完成数
        if isCompleted then totalCompleted = totalCompleted + 1 end
    end

    -- 更新内容容器高度
    self.completedScrollChild:SetHeight(math.max(completedCount * 30 + 10, 40))
    self.incompleteScrollChild:SetHeight(math.max(incompleteCount * 30 + 10, 40))

    -- 更新滚动范围
    self.completedScrollFrame:UpdateScrollRange()
    self.incompleteScrollFrame:UpdateScrollRange()

    -- 恢复滚动位置（不超过新范围）
    self.completedScrollFrame:SetScrollOffset(math.min(lastCompletedScroll, self.completedScrollFrame.maxOffset))
    self.incompleteScrollFrame:SetScrollOffset(math.min(lastIncompleteScroll, self.incompleteScrollFrame.maxOffset))

    -- 更新提示文本
    self.HintLabel:SetText(title[math.min(totalCompleted, #title)] or title[0])
    self.HintLabel:SetTextColor(self:GetTitleColor(totalCompleted))
end

-- 辅助函数：获取列表项（复用或新建）
function LocomotiveIntroduce:GetOrCreateListItem(isCompleted, index)
    local poolName = isCompleted and "Completed" or "Incomplete"
    local parent = isCompleted and self.completedScrollChild or self.incompleteScrollChild

    -- 尝试复用
    if parent.itemPool and parent.itemPool[index] then
        return parent.itemPool[index], false
    end

    -- 创建新项
    local item = CreateFrame("Frame", nil, parent)
    item:SetSize(parent:GetWidth() - 10, 28)

    -- 背景纹理
    if not item.bg then
        item.bg = item:CreateTexture(nil, "BACKGROUND")
        item.bg:SetAllPoints()
    end

    -- 副本图标
    if not item.icon then
        item.icon = item:CreateTexture(nil, "OVERLAY")
        item.icon:SetSize(24, 24)
        item.icon:SetPoint("LEFT", 5, 0)
        item.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    -- 副本名称
    if not item.name then
        item.name = item:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        item.name:SetPoint("LEFT", item.icon, "RIGHT", 8, 0)
        item.name:SetWidth(180)
        item.name:SetJustifyH("LEFT")
    end

    -- 层数显示（仅已完成）
    if not item.level then
        item.level = item:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        item.level:SetPoint("RIGHT", -10, 0)
        item.level:SetWidth(60)
        item.level:SetJustifyH("RIGHT")
    end

    -- 初始化对象池
    parent.itemPool = parent.itemPool or {}
    parent.itemPool[index] = item

    return item, true
end

-- 辅助函数：清理列表项
function LocomotiveIntroduce:ReleaseListItems(isCompleted)
    local parent = isCompleted and self.completedScrollChild or self.incompleteScrollChild
    if not parent.itemPool then return end

    -- 逆向遍历安全删除
    for i = #parent.itemPool, 1, -1 do
        local item = parent.itemPool[i]
        if item then
            item:Hide()
            item:ClearAllPoints()
            item:SetParent(nil)
            item.icon:SetTexture(nil)
            item.name:SetText("")
            if item.level then item.level:SetText("") end
        end
    end
    wipe(parent.itemPool)
end

-- 配置已完成项
function LocomotiveIntroduce:SetupCompletedItem(item, name, level, texture)
    item.icon:SetTexture(texture)
    item.name:SetTextColor(1, 1, 1)
    item.name:SetText(name)

    -- 修改这里：显示具体层数信息
    local levelText = level >= 10 and ("|cFF00FF00"..level.."层|r") or ("|cFFFF0000"..level.."层|r")
    item.level:SetText(levelText)

    item:SetScript("OnEnter", function()
        GameTooltip:SetOwner(item, "ANCHOR_RIGHT")
        GameTooltip:AddLine("最佳记录", 0, 1, 0)
        GameTooltip:AddLine("限时通关层数："..level, 1, 1, 1)
        if level >= 10 then
            GameTooltip:AddLine("已符合火车头认证资格", 0, 1, 0)
        else
            GameTooltip:AddLine("需要10层或以上才能认证", 1, 0, 0)
        end
        GameTooltip:Show()
    end)
    item:SetScript("OnLeave", GameTooltip_Hide)
end

-- 配置未完成项
function LocomotiveIntroduce:SetupIncompleteItem(item, name, level, texture)
    item.icon:SetTexture(texture)
    item.name:SetTextColor(0.6, 0.6, 0.6)  -- 灰色表示未完成10层
    item.name:SetText(name)

    if level > 0 then
      -- 显示层数（红色表示未达标）
      item.level:SetText(level.."层")
      item.level:SetTextColor(1, 0, 0)  -- 红色
      item.level:Show()
    else
      item.level:Hide()
    end

    item:SetScript("OnEnter", function()
        GameTooltip:SetOwner(item, "ANCHOR_RIGHT")
        GameTooltip:AddLine("尚未完成10层", 1, 0, 0)
        if level > 0 then
            GameTooltip:AddLine("当前最佳记录："..level.."层", 1, 1, 1)
        else
            GameTooltip:AddLine("尚未限时通关", 1, 1, 1)
        end
        GameTooltip:AddLine("需要10层或以上才能认证", 1, 0.5, 0)
        GameTooltip:Show()
    end)
    item:SetScript("OnLeave", GameTooltip_Hide)
end

-- 获取标题颜色梯度
function LocomotiveIntroduce:GetTitleColor(count)
    local r = math.min(0.2 + count*0.1, 1)
    local g = math.min(0.4 + count*0.1, 1)
    local b = 1.0 - count*0.1
    return r, g, b
end

