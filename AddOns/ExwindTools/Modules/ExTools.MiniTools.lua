-- [[ 小工具箱 (MiniTools) ]]
-- { Key = "ExTools.MiniTools", Name = "小工具箱", Desc = "汇集各种简单实用的功能 tweaks。", Category = 4 }

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

-- 全局函数引用
local UIParent = _G.UIParent


-- ========================================================================
-- 1. [ShowMapInfo] 地图ID + 鼠标坐标 + 玩家坐标
-- ========================================================================
local function Init_ShowMapInfo()
    local db = ExwindTools:GetModuleDB("ExTools.MiniTools")
    local ANCHOR_MAP = {
        ["左下"] = { point = "BOTTOMLEFT", relPoint = "BOTTOMLEFT", x = 10, y = 10, align = "LEFT" },
        ["左上"] = { point = "TOPLEFT", relPoint = "TOPLEFT", x = 10, y = -10, align = "LEFT" },
        ["右下"] = { point = "BOTTOMRIGHT", relPoint = "BOTTOMRIGHT", x = -10, y = 10, align = "RIGHT" },
        ["右上"] = { point = "TOPRIGHT", relPoint = "TOPRIGHT", x = -10, y = -10, align = "RIGHT" },
        ["中下"] = { point = "BOTTOM", relPoint = "BOTTOM", x = 0, y = 10, align = "CENTER" },
    }

    local frame = CreateFrame("Frame", "ExwindMapInfoWatcher", WorldMapFrame)
    frame:SetSize(520, 20)
    frame:SetFrameStrata("TOOLTIP")
    local text = frame:CreateFontString(nil, "OVERLAY")
    text:SetAllPoints(frame)

    local function ApplyFont()
        local cfg = db.MapInfoFont
        local rawFont = (cfg and cfg.font and cfg.font ~= "" and cfg.font ~= "默认") and cfg.font or nil
        local font
        if rawFont then
            -- [Fix] fontgroup 保存的是 LSM 显示名称，需解析为实际文件路径
            local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
            if LSM then
                local resolved = LSM:Fetch("font", rawFont)
                font = (resolved and resolved ~= "") and resolved or (ExwindTools.MAIN_FONT or "Fonts\\ARHei.ttf")
            else
                font = ExwindTools.MAIN_FONT or "Fonts\\ARHei.ttf"
            end
        else
            font = ExwindTools.MAIN_FONT or "Fonts\\ARHei.ttf"
        end
        local size = (cfg and cfg.size) or 14
        local outline = (cfg and cfg.outline and cfg.outline ~= "NONE") and cfg.outline or ""
        text:SetFont(font, size, outline)
        text:SetTextColor(
            (cfg and cfg.r) or 1,
            (cfg and cfg.g) or 1,
            (cfg and cfg.b) or 1,
            (cfg and cfg.a) or 1
        )
        if cfg and cfg.shadow then
            text:SetShadowOffset(cfg.shadowX or 1, -1)
            text:SetShadowColor(0, 0, 0, 1)
        else
            text:SetShadowOffset(0, 0)
        end
    end

    local function ApplyAnchor()
        local anchor = ANCHOR_MAP[db.MapInfoAnchor] or ANCHOR_MAP["左下"]
        local frameTarget = WorldMapFrame.ScrollContainer or WorldMapFrame

        -- 叠加字体设置里的偏移
        local cfg = db.MapInfoFont
        local offX = (anchor.x) + (cfg and cfg.x or 0)
        local offY = (anchor.y) + (cfg and cfg.y or 0)

        frame:ClearAllPoints()
        frame:SetPoint(anchor.point, frameTarget, anchor.relPoint, offX, offY)
        text:SetJustifyH(anchor.align)
    end

    local mapID = nil
    local function UpdateMapID()
        mapID = WorldMapFrame.mapID or C_Map.GetBestMapForUnit("player")
    end

    local function GetPlayerMapCoord()
        local currentMapID = WorldMapFrame.mapID or mapID or C_Map.GetBestMapForUnit("player")
        if not currentMapID then return nil, nil end

        local pos = C_Map.GetPlayerMapPosition(currentMapID, "player")
        if not pos then return nil, nil end

        local px, py = pos:GetXY()
        if type(px) ~= "number" or type(py) ~= "number" then return nil, nil end
        return px * 100, py * 100
    end

    frame:SetScript("OnUpdate", function()
        if not WorldMapFrame:IsVisible() then return end

        -- [12.0 Fix] 直接在 OnUpdate 中读取 mapID，避免 hooksecurefunc 污染 WorldMapFrame 导致
        -- UIWidget Tooltip 中 GetStringHeight() 返回 secret value 报错
        mapID = WorldMapFrame.mapID or C_Map.GetBestMapForUnit("player")

        local hideMapID = (db.MapInfoHideMapID ~= false) -- nil 也按默认”隐藏MapID”处理
        local showMapID = not hideMapID
        local mapText = showMapID and string.format(L["MapID: %s"], mapID or "?") or nil
        local pX, pY = GetPlayerMapCoord()
        local hasPlayerCoord = (type(pX) == "number" and type(pY) == "number")
        local canvas = WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
        if canvas and canvas:IsMouseOver() then
            local nx, ny = WorldMapFrame:GetNormalizedCursorPosition()
            if nx and ny then
                if hasPlayerCoord then
                    if mapText then
                        text:SetText(string.format("%s  " .. L["鼠标: %.2f, %.2f  玩家: %.2f, %.2f"], mapText, nx * 100,
                            ny * 100, pX, pY))
                    else
                        text:SetText(string.format(L["鼠标: %.2f, %.2f  玩家: %.2f, %.2f"], nx * 100, ny * 100, pX, pY))
                    end
                else
                    if mapText then
                        text:SetText(string.format("%s  " .. L["鼠标: %.2f, %.2f"], mapText, nx * 100, ny * 100))
                    else
                        text:SetText(string.format(L["鼠标: %.2f, %.2f"], nx * 100, ny * 100))
                    end
                end
                return
            end
        end
        if hasPlayerCoord then
            if mapText then
                text:SetText(string.format("%s  " .. L["玩家: %.2f, %.2f"], mapText, pX, pY))
            else
                text:SetText(string.format(L["玩家: %.2f, %.2f"], pX, pY))
            end
        else
            text:SetText(mapText or "")
        end
    end)

    -- [12.0 Fix] 移除 hooksecurefunc(WorldMapFrame, "OnMapChanged", UpdateMapID)
    -- 该 hook 会污染 WorldMapFrame 的执行上下文，导致 UIWidget 系统中
    -- GetStringHeight() 返回 secret value 并在算术运算时报错。
    -- mapID 改为在 OnUpdate 中直接读取，无需 hook。
    ExwindTools:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ExTools_Mini_MapInfo", UpdateMapID)

    ExwindTools:WatchState("ExTools.MiniTools.DatabaseChanged", "ExTools_MapInfo_ConfigUpdate", function(info)
        if not info or not info.key then return end
        if string.find(info.key, "MapInfoFont") then
            ApplyFont()
            ApplyAnchor() -- 坐标可能变化
        end
        if info.key == "MapInfoAnchor" then ApplyAnchor() end
    end)

    UpdateMapID()
    ApplyFont()
    ApplyAnchor()
end

-- ========================================================================
-- 2. [AutoDelete] 自动删除确认
-- ========================================================================
local function Init_AutoDelete()
    local DELETE_STR = DELETE_ITEM_CONFIRM_STRING or "DELETE"
    ExwindTools:RegisterEvent("DELETE_ITEM_CONFIRM", "ExTools_Mini_AutoDelete", function()
        C_Timer.After(0.1, function()
            local popupList = { "DELETE_GOOD_ITEM", "DELETE_GOOD_QUEST_ITEM", "DELETE_QUEST_ITEM" }
            for _, which in ipairs(popupList) do
                local dialog = StaticPopup_FindVisible(which)
                if dialog and dialog.GetEditBox then
                    local box = dialog:GetEditBox()
                    if box then box:SetText(DELETE_STR) end
                end
            end
        end)
    end)
end

-- ========================================================================
-- 3. [AutoSellJunk] 自动卖垃圾
-- ========================================================================
local function Init_AutoSellJunk()
    ExwindTools:RegisterEvent("MERCHANT_SHOW", "ExTools_Mini_Junk", function()
        if C_MerchantFrame and C_MerchantFrame.SellAllJunkItems then
            C_MerchantFrame.SellAllJunkItems()
        end
    end)
end

-- ========================================================================
-- 4. [AutoCombatLog] 自动战斗记录
-- ========================================================================
local function Init_AutoCombatLog()
    local function CheckLog()
        -- 扁平化配置读取：直接读取 db.ACL_xyz
        -- 注意：这些配置键必须与 EXWIND_DEFAULTS 中的一致
        local db = ExwindTools:GetModuleDB("ExTools.MiniTools")
        if not db then return end

        local _, _, dID = GetInstanceInfo()
        local shouldLog = false

        -- 5人本
        if dID == 1 and db.ACL_DungeonNormal then shouldLog = true end
        if dID == 2 and db.ACL_DungeonHeroic then shouldLog = true end
        if dID == 23 and (db.ACL_DungeonMythic or db.ACL_DungeonChallenge) then shouldLog = true end
        if dID == 8 and db.ACL_DungeonChallenge then shouldLog = true end
        if dID == 205 and db.ACL_DungeonFollower then shouldLog = true end

        -- 团本
        if dID == 17 and db.ACL_RaidLFR then shouldLog = true end
        if dID == 14 and db.ACL_RaidNormal then shouldLog = true end
        if dID == 15 and db.ACL_RaidHeroic then shouldLog = true end
        if dID == 16 and db.ACL_RaidMythic then shouldLog = true end

        local isLogging = LoggingCombat()
        if shouldLog and not isLogging then
            LoggingCombat(true)
            print("|cff00ff00[Ex] " .. L["进入副本，自动开启战斗记录"] .. "|r")
        elseif not shouldLog and isLogging then
            LoggingCombat(false)
            print("|cffff0000[Ex] " .. L["离开副本，自动关闭战斗记录"] .. "|r")
        end
    end

    ExwindTools:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ExTools_Mini_ACL", CheckLog)
    ExwindTools:RegisterEvent("CHALLENGE_MODE_START", "ExTools_Mini_ACL", CheckLog)
    ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", "ExTools_Mini_ACL", CheckLog)
    C_Timer.After(3, CheckLog)
end

-- ========================================================================
-- 5. [BulkBuy] 批量购买助手
-- ========================================================================
local function Init_BulkBuy()
    -- 延迟获取 DB，确保是最新的
    local function GetDB()
        return ExwindTools:GetModuleDB("ExTools.MiniTools")
    end

    local Frame

    -- [v4.3.16 Fix] 该面板直接挂载在 MerchantFrame 旁，不经过 EXUI 工厂，
    -- 因此 ElvUI / NDui 不会自动接管其主框体、输入框和快捷按钮样式。
    local function ApplyBulkBuySkin(frame)
        if not frame then return false end

        local elvSkin = ExwindTools.ElvUISkin
        if elvSkin and elvSkin:IsElvUILoaded() then
            local ok = _G.pcall(function()
                elvSkin:SkinFrame(frame, "Transparent")

                local E = _G.ElvUI and _G.ElvUI[1]
                local S = E and E:GetModule("Skins", true)
                if S and S.CreateShadowModule then
                    _G.pcall(S.CreateShadowModule, S, frame)
                end

                if frame.CloseBtn then
                    elvSkin:SkinCloseButton(frame.CloseBtn)
                end
                if frame.Input then
                    elvSkin:SkinEditBox(frame.Input)
                end
                if frame.BuyBtn then
                    elvSkin:SkinButton(frame.BuyBtn)
                end
                if frame.QuickButtons then
                    for _, btn in ipairs(frame.QuickButtons) do
                        elvSkin:SkinButton(btn)
                    end
                end
            end)
            if ok then return true end
        end

        local ndSkin = ExwindTools.NDuiSkin
        if ndSkin and ndSkin:IsNDuiLoaded() then
            local ok = _G.pcall(function()
                ndSkin:SkinFrame(frame)
                if frame.CloseBtn and ndSkin.SkinCloseButton then
                    ndSkin:SkinCloseButton(frame.CloseBtn)
                end
                if frame.Input then
                    ndSkin:SkinEditBox(frame.Input)
                end
                if frame.BuyBtn then
                    ndSkin:SkinButton(frame.BuyBtn)
                end
                if frame.QuickButtons then
                    for _, btn in ipairs(frame.QuickButtons) do
                        ndSkin:SkinButton(btn)
                    end
                end
            end)
            if ok then return true end
        end

        return false
    end

    local bulkBuySkinApplied = false
    local function EnsureBulkBuySkin(force)
        if bulkBuySkinApplied and not force then
            return true
        end

        local ok = ApplyBulkBuySkin(Frame)
        bulkBuySkinApplied = ok == true
        return bulkBuySkinApplied
    end

    -- UI Frame 构建
    Frame = CreateFrame("Frame", "ExwindMerchantBulkFrame", MerchantFrame, "BackdropTemplate")
    Frame:SetSize(240, 420)
    Frame:SetPoint("TOPLEFT", MerchantFrame, "TOPRIGHT", 5, -20)
    Frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    Frame:Hide()
    Frame:SetFrameStrata("DIALOG")

    -- 关闭按钮
    Frame.CloseBtn = CreateFrame("Button", nil, Frame, "UIPanelCloseButton")
    Frame.CloseBtn:SetPoint("TOPRIGHT", -5, -5)

    -- 标题
    Frame.Title = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Frame.Title:SetPoint("TOP", 0, -20)
    Frame.Title:SetText(L["批量购买"])

    -- 图标
    Frame.Icon = Frame:CreateTexture(nil, "ARTWORK")
    Frame.Icon:SetSize(50, 50)
    Frame.Icon:SetPoint("TOP", 0, -50)

    -- 物品名
    Frame.ItemName = Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    Frame.ItemName:SetPoint("TOP", Frame.Icon, "BOTTOM", 0, -10)
    Frame.ItemName:SetWidth(240)
    Frame.ItemName:SetWordWrap(true)

    -- 堆叠
    Frame.StackInfo = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    Frame.StackInfo:SetPoint("TOP", Frame.ItemName, "BOTTOM", 0, -5)

    -- 输入框
    Frame.Input = CreateFrame("EditBox", nil, Frame, "InputBoxTemplate")
    Frame.Input:SetSize(120, 30)
    Frame.Input:SetPoint("TOP", Frame.StackInfo, "BOTTOM", 0, -23)
    Frame.Input:SetAutoFocus(false)
    Frame.Input:SetNumeric(true)
    Frame.Input:SetFontObject(ChatFontNormal)

    Frame:SetScript("OnKeyDown", function(self, key) if key == "ESCAPE" then self:Hide() end end)
    Frame.Input:SetScript("OnEscapePressed", function() Frame:Hide() end)

    -- 逻辑变量
    local currentIndex = 0
    local currentMaxStack = 1
    local currentPrice = 0

    local function GetMerchantInfoSafe(index)
        if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
            local info = C_MerchantFrame.GetItemInfo(index)
            if info then
                return info.name, info.texture, info.price, info.stackCount, info.numAvailable, info.isUsable,
                    info.extendedCost
            end
        end
        if GetMerchantItemInfo then return GetMerchantItemInfo(index) end
    end

    local function UpdateFrame(index)
        local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantInfoSafe(index)
        if not name then return end
        local link = GetMerchantItemLink(index)
        local maxStack = 20
        if GetMerchantItemMaxStack then
            maxStack = GetMerchantItemMaxStack(index)
        elseif link then
            maxStack = select(8, C_Item.GetItemInfo(link)) or 20
        end

        currentIndex = index
        currentMaxStack = maxStack or 20
        currentPrice = price

        EnsureBulkBuySkin()

        Frame.Icon:SetTexture(texture)
        Frame.ItemName:SetText(link or name)
        Frame.StackInfo:SetText(L["堆叠上限: "] .. currentMaxStack)

        Frame.Input:SetNumber(currentMaxStack)
        Frame.Input:SetFocus()
        Frame.Input:HighlightText()
        Frame:Show()
    end

    -- 确认框
    StaticPopupDialogs["EXWIND_BULK_BUY_CONFIRM"] = {
        text = L["此次购买将花费 %s\n确认购买 %s 吗？"],
        button1 = YES,
        button2 = NO,
        OnAccept = function(self) self.data.callback() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    local function BuyBatch(index, remaining, callback)
        if remaining <= 0 then
            if callback then callback() end
            return
        end
        local BATCH_LIMIT = 200
        local thisBatch = math.min(remaining, BATCH_LIMIT)
        local stack = currentMaxStack
        local processed = 0
        local callCount = 0
        while processed < thisBatch do
            local buy = math.min(stack, thisBatch - processed)
            BuyMerchantItem(index, buy)
            processed = processed + buy
            callCount = callCount + 1
        end
        local left = remaining - thisBatch
        if left > 0 then
            -- 根据本批实际 API 调用次数动态决定延迟
            local delay
            if callCount <= 5 then
                delay = 0.3
            elseif callCount <= 20 then
                delay = 0.8
            else
                delay = 2
            end
            C_Timer.After(delay, function() BuyBatch(index, left, callback) end)
        else
            if callback then callback() end
        end
    end

    local function ExecuteBuy()
        local amount = tonumber(Frame.Input:GetText()) or 0
        if amount <= 0 or currentIndex == 0 then return end

        Frame.BuyBtn:Disable()
        Frame.BuyBtn:SetText(L["购买中..."])
        BuyBatch(currentIndex, amount, function()
            Frame.BuyBtn:Enable()
            Frame.BuyBtn:SetText(L["购买"])
            Frame.Input:ClearFocus()
            Frame:Hide()
        end)
    end

    local function DoBuyCheck()
        local amount = tonumber(Frame.Input:GetText()) or 0
        if amount <= 0 then return end
        local db = GetDB()

        if currentPrice and currentPrice > 0 then
            local totalCopper = currentPrice * amount
            local thresholdGold = tonumber(db.BulkBuy_WarnThreshold) or 1000
            if thresholdGold > 0 and (totalCopper / 10000) >= thresholdGold then
                local priceStr = GetMoneyString(totalCopper, true)
                local itemLink = GetMerchantItemLink(currentIndex) or L["物品"]
                local descStr = string.format(L["%d 个 %s"], amount, itemLink)
                StaticPopup_Show("EXWIND_BULK_BUY_CONFIRM", priceStr, descStr, { callback = ExecuteBuy })
                return
            end
        end
        ExecuteBuy()
    end

    Frame.TotalPrice = Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    Frame.TotalPrice:SetPoint("TOP", Frame.Input, "BOTTOM", 0, 52)
    Frame.Input:SetScript("OnTextChanged", function(self)
        local amount = tonumber(self:GetText()) or 0
        if currentPrice and currentPrice > 0 and amount > 0 then
            Frame.TotalPrice:SetText(L["总价: "] .. GetMoneyString(currentPrice * amount, true))
        else
            Frame.TotalPrice:SetText("")
        end
    end)

    Frame.BuyBtn = CreateFrame("Button", nil, Frame, "UIPanelButtonTemplate")
    Frame.BuyBtn:SetSize(160, 40)
    Frame.BuyBtn:SetPoint("BOTTOM", 0, 92)
    Frame.BuyBtn:SetText(L["购买"])
    Frame.BuyBtn:SetScript("OnClick", DoBuyCheck)
    Frame.Input:SetScript("OnEnterPressed", DoBuyCheck)

    -- 快捷按钮
    Frame.QuickButtons = {}
    local function AddQuickBtn(label, val, x, y, width)
        local btn = CreateFrame("Button", nil, Frame, "UIPanelButtonTemplate")
        btn:SetSize(width or 60, 22)
        btn:SetPoint("TOPLEFT", Frame.Input, "BOTTOMLEFT", x, y)
        btn:SetText(label)
        btn:SetScript("OnClick", function()
            Frame.Input:SetNumber(val); Frame.Input:HighlightText()
        end)
        table.insert(Frame.QuickButtons, btn)
    end
    local y1, y2, w = -10, -40, 60
    AddQuickBtn("20", 20, -35, y1, w); AddQuickBtn("50", 50, 30, y1, w); AddQuickBtn("100", 100, 95, y1, w)
    AddQuickBtn("200", 200, -35, y2, w); AddQuickBtn("500", 500, 30, y2, w); AddQuickBtn("999", 999, 95, y2, w)

    EnsureBulkBuySkin()
    Frame:HookScript("OnShow", function()
        if not bulkBuySkinApplied then
            C_Timer.After(0, function()
                EnsureBulkBuySkin(true)
            end)
        end
    end)

    -- Hook
    local Original_MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
    MerchantItemButton_OnModifiedClick = function(self, button)
        local db = GetDB()
        if db.BulkBuy and button == "RightButton" and MerchantFrame.selectedTab == 1 and IsModifiedClick("SPLITSTACK") then
            local index = self:GetID()
            UpdateFrame(index)
            return
        end
        if Original_MerchantItemButton_OnModifiedClick then
            Original_MerchantItemButton_OnModifiedClick(self, button)
        end
    end

    ExwindTools:RegisterEvent("MERCHANT_CLOSED", "ExTools_Mini_BulkBuy", function() Frame:Hide() end)
end

-- ========================================================================
-- 6. [ResetDMG] 进本重置伤害统计
-- ========================================================================
local function Init_ResetDamageMeter()
    _G.StaticPopupDialogs["EXWIND_RESET_DMG_METER"] = {
        text = L["检测到进入副本，是否重置伤害统计数据？"],
        button1 = _G.YES,
        button2 = _G.NO,
        OnAccept = function()
            local CDM = _G.C_DamageMeter
            if CDM and CDM.ResetAllCombatSessions then
                CDM.ResetAllCombatSessions()
                print("|cff00ff00[ExwindTools] " .. L["伤害统计已重置"] .. "|r")
            else
                print("|cffff0000[ExwindTools] " .. L["错误: C_DamageMeter.ResetAllCombatSessions API 不存在"] .. "|r")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    -- [关键修复] 记录初始真实状态
    -- 如果初始化时已经在副本里(lastInInstance=true)，那么 State 初始化同步带来的 false->true 变化将被忽略
    local lastInInstance = IsInInstance()

    ExwindTools:WatchState("InInstance", "ExTools_Mini_ResetDMG", function(inInstance)
        -- 仅当真正从野外(last=false)变为副本(curr=true)时触发
        if inInstance and lastInInstance == false then
            _G.StaticPopup_Show("EXWIND_RESET_DMG_METER")
        end
        lastInInstance = inInstance
    end)
end

-- ========================================================================
-- 7. [CombatAlert] 战斗提示
-- ========================================================================
local function Init_CombatAlert()
    local db = ExwindTools:GetModuleDB("ExTools.MiniTools")
    if not db then return end

    -- 创建进入战斗提示框架
    local enterFrame = CreateFrame("Frame", "ExwindCombatEnterAlert", UIParent)
    enterFrame:SetSize(400, 100)
    -- 读取保存的坐标，默认为 (0, 200)
    local eX = db.CombatEnterPosX or 0
    local eY = db.CombatEnterPosY or 200
    enterFrame:SetPoint("CENTER", UIParent, "CENTER", eX, eY)
    enterFrame:SetFrameStrata("HIGH")
    enterFrame:SetMovable(true)
    enterFrame:EnableMouse(false)
    enterFrame:RegisterForDrag("LeftButton")
    enterFrame:Hide()

    -- 编辑模式下的背景
    enterFrame.bg = enterFrame:CreateTexture(nil, "BACKGROUND")
    enterFrame.bg:SetAllPoints()
    enterFrame.bg:SetColorTexture(1, 0.2, 0.2, 0.3)
    enterFrame.bg:Hide()

    local enterText = enterFrame:CreateFontString(nil, "OVERLAY")
    enterText:SetPoint("CENTER")
    enterText:SetFont("Fonts\\ARHei.ttf", 48, "THICKOUTLINE")
    enterText:SetText(L[db.CombatEnterText or "进入战斗"] or db.CombatEnterText or "进入战斗")
    enterFrame.text = enterText

    -- 拖动逻辑（仅编辑模式下允许拖动）
    enterFrame:SetScript("OnDragStart", function(self)
        if not ExwindTools.GlobalEditMode then return end
        self:StartMoving()
    end)
    enterFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- 保存坐标
        local cx, cy = self:GetCenter()
        local sx, sy = UIParent:GetCenter()
        if cx and sx then
            db.CombatEnterPosX = cx - sx
            db.CombatEnterPosY = cy - sy
        end
    end)
    enterFrame.__ExwindOpenConfigKey = "ExTools.MiniTools"
    ExwindTools:RegisterHUD("ExTools.MiniTools.CombatAlert.Enter", enterFrame)
    enterFrame:EnableMouse(false)

    -- 创建离开战斗提示框架
    local leaveFrame = CreateFrame("Frame", "ExwindCombatLeaveAlert", UIParent)
    leaveFrame:SetSize(400, 100)
    -- 读取保存的坐标，默认为 (0, -200)
    local lX = db.CombatLeavePosX or 0
    local lY = db.CombatLeavePosY or -200
    leaveFrame:SetPoint("CENTER", UIParent, "CENTER", lX, lY)
    leaveFrame:SetFrameStrata("HIGH")
    leaveFrame:SetMovable(true)
    leaveFrame:EnableMouse(false)
    leaveFrame:RegisterForDrag("LeftButton")
    leaveFrame:Hide()

    -- 编辑模式下的背景
    leaveFrame.bg = leaveFrame:CreateTexture(nil, "BACKGROUND")
    leaveFrame.bg:SetAllPoints()
    leaveFrame.bg:SetColorTexture(0.2, 1, 0.2, 0.3)
    leaveFrame.bg:Hide()

    local leaveText = leaveFrame:CreateFontString(nil, "OVERLAY")
    leaveText:SetPoint("CENTER")
    leaveText:SetFont("Fonts\\ARHei.ttf", 48, "THICKOUTLINE")
    leaveText:SetText(L[db.CombatLeaveText or "离开战斗"] or db.CombatLeaveText or "离开战斗")
    leaveFrame.text = leaveText

    -- 拖动逻辑（仅编辑模式下允许拖动）
    leaveFrame:SetScript("OnDragStart", function(self)
        if not ExwindTools.GlobalEditMode then return end
        self:StartMoving()
    end)
    leaveFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- 保存坐标
        local cx, cy = self:GetCenter()
        local sx, sy = UIParent:GetCenter()
        if cx and sx then
            db.CombatLeavePosX = cx - sx
            db.CombatLeavePosY = cy - sy
        end
    end)
    leaveFrame.__ExwindOpenConfigKey = "ExTools.MiniTools"
    ExwindTools:RegisterHUD("ExTools.MiniTools.CombatAlert.Leave", leaveFrame)
    leaveFrame:EnableMouse(false)

    -- 应用字体配置
    local function ApplyFont(fontString, fontConfig)
        if not fontString or not fontConfig then return end

        -- "默认" 或无效值时回退到游戏主字体
        local font = fontConfig.font
        if not font or font == "" or font == "默认" then
            font = ExwindTools.MAIN_FONT or "Fonts\\ARHei.ttf"
        else
            -- [Fix] fontgroup 保存的是 LSM 显示名称（如"聊天"），需通过 LSM 解析为实际文件路径
            -- 否则 SetFont() 会静默失败，导致字体大小/样式无法生效（尤其在导入别人配置后）
            local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
            if LSM then
                local resolved = LSM:Fetch("font", font)
                if resolved and resolved ~= "" then
                    font = resolved
                else
                    -- LSM 中找不到该字体（可能是对方独有的 LSM 字体），安全回退
                    font = ExwindTools.MAIN_FONT or "Fonts\\ARHei.ttf"
                end
            end
        end
        local size = fontConfig.size or 35
        local outline = fontConfig.outline or ""
        if outline == "NONE" then outline = "" end

        fontString:SetFont(font, size, outline)
        fontString:SetTextColor(fontConfig.r or 1, fontConfig.g or 1, fontConfig.b or 1, fontConfig.a or 1)

        if fontConfig.shadow then
            fontString:SetShadowOffset(fontConfig.shadowX or 1, fontConfig.shadowY or -1)
            fontString:SetShadowColor(0, 0, 0, 1)
        else
            fontString:SetShadowOffset(0, 0)
        end

        -- 应用文字位置偏移
        fontString:ClearAllPoints()
        fontString:SetPoint("CENTER", fontConfig.x or 0, fontConfig.y or 0)
    end

    -- 更新字体样式和文字内容
    local function UpdateFonts()
        ApplyFont(enterText, db.CombatEnterFont)
        ApplyFont(leaveText, db.CombatLeaveFont)

        -- 更新文字内容
        enterText:SetText(L[db.CombatEnterText or "进入战斗"] or db.CombatEnterText or "进入战斗")
        leaveText:SetText(L[db.CombatLeaveText or "离开战斗"] or db.CombatLeaveText or "离开战斗")
    end

    -- 预创建动画组（只创建一次，避免重叠堆积）
    local function BuildAnimGroup(frame)
        local ag = frame:CreateAnimationGroup()
        local fadeIn = ag:CreateAnimation("Alpha")
        fadeIn:SetDuration(0.3)
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetOrder(1)
        local stay = ag:CreateAnimation("Alpha")
        stay:SetDuration(1.0)
        stay:SetFromAlpha(1)
        stay:SetToAlpha(1)
        stay:SetOrder(2)
        local fadeOut = ag:CreateAnimation("Alpha")
        fadeOut:SetDuration(0.5)
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0)
        fadeOut:SetOrder(3)
        ag:SetScript("OnFinished", function()
            frame:Hide()
            frame:SetAlpha(1)
        end)
        return ag
    end

    local enterAG = BuildAnimGroup(enterFrame)
    local leaveAG = BuildAnimGroup(leaveFrame)

    -- 播放动画：先停止对方，再重播自己
    local function PlayAnimation(frame, ag, otherFrame, otherAG)
        if not db.CombatAlert then
            return
        end
        -- 打断对方正在播放的动画
        if otherAG:IsPlaying() then
            otherAG:Stop()
            otherFrame:Hide()
            otherFrame:SetAlpha(1)
        end
        -- 重播自己（如果已在播放则重新开始）
        if ag:IsPlaying() then
            ag:Stop()
        end
        -- 战斗事件触发时强制确保锁定（非编辑模式下禁止鼠标交互和移动）
        if not ExwindTools.GlobalEditMode then
            frame:SetMovable(false)
            frame:EnableMouse(false)
        end
        frame:SetAlpha(0)
        frame:Show()
        ag:Play()
    end

    -- 战斗事件处理
    ExwindTools:RegisterEvent("PLAYER_REGEN_DISABLED", "ExTools_CombatAlert_Enter", function()
        UpdateFonts()
        PlayAnimation(enterFrame, enterAG, leaveFrame, leaveAG)
    end)

    ExwindTools:RegisterEvent("PLAYER_REGEN_ENABLED", "ExTools_CombatAlert_Leave", function()
        UpdateFonts()
        PlayAnimation(leaveFrame, leaveAG, enterFrame, enterAG)
    end)

    -- 监听配置变化
    ExwindTools:WatchState("ExTools.MiniTools.DatabaseChanged", "ExTools_CombatAlert_ConfigUpdate", function(info)
        if info and info.key then
            -- 字体配置或文字内容变化时更新
            if string.find(info.key, "CombatEnterFont") or string.find(info.key, "CombatLeaveFont") or
                info.key == "CombatEnterText" or info.key == "CombatLeaveText" then
                UpdateFonts()
            end
        end
    end)

    local isEditModeActive = false
    local isEnterVisible = true
    local isLeaveVisible = true

    local function ApplySingleFrameEditPresentation(frame, visible)
        if isEditModeActive and visible then
            frame:SetMovable(true)
            frame:EnableMouse(true)
            frame.bg:Show()
            frame:Show()
            frame:SetAlpha(1)
        else
            frame:SetMovable(false)
            frame:EnableMouse(false)
            frame.bg:Hide()
            frame:Hide()
        end
    end

    local function RefreshCombatAlertEditPresentation()
        ApplySingleFrameEditPresentation(enterFrame, isEnterVisible)
        ApplySingleFrameEditPresentation(leaveFrame, isLeaveVisible)
    end

    ExwindTools:RegisterEditModeHandler("ExTools.MiniTools.CombatAlert.Enter", {
        EnterEditMode = function()
            isEditModeActive = true
            isEnterVisible = true
            RefreshCombatAlertEditPresentation()
        end,
        ExitEditMode = function()
            isEditModeActive = false
            isEnterVisible = true
            RefreshCombatAlertEditPresentation()
        end,
        SetEditVisible = function(_, visible)
            isEnterVisible = (visible ~= false)
            RefreshCombatAlertEditPresentation()
        end,
    })

    ExwindTools:RegisterEditModeHandler("ExTools.MiniTools.CombatAlert.Leave", {
        EnterEditMode = function()
            isEditModeActive = true
            isLeaveVisible = true
            RefreshCombatAlertEditPresentation()
        end,
        ExitEditMode = function()
            isEditModeActive = false
            isLeaveVisible = true
            RefreshCombatAlertEditPresentation()
        end,
        SetEditVisible = function(_, visible)
            isLeaveVisible = (visible ~= false)
            RefreshCombatAlertEditPresentation()
        end,
    })

    -- 右键点击跳转到设置（手动实现，因为没用 RegisterHUD）
    enterFrame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" and ExwindTools.GlobalEditMode then
            ExwindTools:OpenConfig("ExTools.MiniTools")
        end
    end)

    leaveFrame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" and ExwindTools.GlobalEditMode then
            ExwindTools:OpenConfig("ExTools.MiniTools")
        end
    end)

    -- 初始应用字体
    UpdateFonts()
end

-- ========================================================================

-- ========================================================================
-- 9. [AutoRepair] 自动修理
-- ========================================================================
local function Init_AutoRepair()
    local function GetDB() return ExwindTools:GetModuleDB("ExTools.MiniTools") end

    local function TryRepair()
        local db = GetDB()
        if not db.AutoRepair then return end
        if not CanMerchantRepair() then return end

        -- 优先尝试公会银行修理
        if db.AutoRepair_UseGuildBank and CanGuildBankRepair() then
            local cost = GetRepairAllCost()
            if cost and cost > 0 then
                RepairAllItems(true)
                if db.AutoRepair_ShowMessage then
                    local gold = GetMoneyString(cost, true)
                    print(string.format("|cffffd100[ExwindTools]|r " .. L["已使用公会银行修理全部装备，花费 %s"], gold))
                end
            end
            return
        end

        -- 自费修理
        local cost, canRepair = GetRepairAllCost()
        if canRepair and cost and cost > 0 then
            RepairAllItems()
            if db.AutoRepair_ShowMessage then
                local gold = GetMoneyString(cost, true)
                print(string.format("|cffffd100[ExwindTools]|r " .. L["已自动修理全部装备，花费 %s"], gold))
            end
        end
    end

    ExwindTools:RegisterEvent("MERCHANT_SHOW", "ExTools_Mini_AutoRepair", TryRepair)
end

-- ========================================================================
-- 8. [HideBattleTag] 昵称伪装
-- ========================================================================
local function Init_HideBattleTag()
    local Hooked = false

    local function Apply()
        local db = ExwindTools:GetModuleDB("ExTools.MiniTools")
        local target = FriendsFrameBattlenetFrame and FriendsFrameBattlenetFrame.Tag
        if not target then return end

        if db.HideBattleTag then
            local fakeName = db.BattleTagText or ""
            if target:GetText() ~= fakeName then
                target:SetText(fakeName)
                target:SetTextColor(0.345, 0.667, 0.867)
            end
        end
    end

    -- Hook 逻辑
    if FriendsFrameBattlenetFrame and FriendsFrameBattlenetFrame.Tag then
        hooksecurefunc(FriendsFrameBattlenetFrame.Tag, "SetText", function(self, text)
            local db = ExwindTools:GetModuleDB("ExTools.MiniTools")
            if not db.HideBattleTag then return end

            local fakeName = db.BattleTagText or ""
            -- 只有当内容不一致时才覆盖，避免死循环
            if text ~= fakeName then
                self:SetText(fakeName)
                self:SetTextColor(0.345, 0.667, 0.867)
            end
        end)
    end

    ExwindTools:WatchState("ExTools.MiniTools.DatabaseChanged", "ExTools_HideBattleTag", function(info)
        if info.key == "HideBattleTag" or info.key == "BattleTagText" then
            Apply()
        end
    end)

    Apply()
end

-- ========================================================================
-- 10. [EJTooltip] 地下城手册增强
-- ========================================================================
local function Init_EJTooltip()
    local EJ_TOOLTIP = {}

    function EJ_TOOLTIP:OnEnter(button)
        local db = ExwindTools:GetModuleDB("ExTools.MiniTools")
        if not db.EJTooltip then return end
        local parent = button:GetParent()
        if not parent then return end

        local spellID = parent.spellID
        if spellID and spellID > 0 then
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            if GameTooltip.SetSpellByID then
                GameTooltip:SetSpellByID(spellID)
            else
                local link = GetSpellLink(spellID)
                if link then GameTooltip:SetHyperlink(link) end
            end

            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine("|cff00ff00SpellID:|r", "|cffffd100" .. spellID .. "|r")
            GameTooltip:Show()
        end
    end

    function EJ_TOOLTIP:OnLeave()
        if GameTooltip:IsForbidden() then return end
        GameTooltip:Hide()
    end

    function EJ_TOOLTIP:HookHeaders()
        if not EncounterJournal then return end

        local usedHeaders = EncounterJournal.encounter and EncounterJournal.encounter.usedHeaders
        if usedHeaders then
            for _, header in ipairs(usedHeaders) do
                if header.button and not header.button.EXWIND_EJ_Hooked then
                    header.button:HookScript("OnEnter", function(s) self:OnEnter(s) end)
                    header.button:HookScript("OnLeave", function() self:OnLeave() end)
                    header.button.EXWIND_EJ_Hooked = true
                end
            end
        end

        local overviewFrame = EncounterJournal.encounter and EncounterJournal.encounter.overviewFrame
        if overviewFrame and overviewFrame.overviews then
            for _, header in ipairs(overviewFrame.overviews) do
                if header.button and not header.button.EXWIND_EJ_Hooked then
                    header.button:HookScript("OnEnter", function(s) self:OnEnter(s) end)
                    header.button:HookScript("OnLeave", function() self:OnLeave() end)
                    header.button.EXWIND_EJ_Hooked = true
                end
            end
        end
    end

    local function SetupHooks()
        hooksecurefunc("EncounterJournal_ToggleHeaders", function() EJ_TOOLTIP:HookHeaders() end)
        hooksecurefunc("EncounterJournal_SetUpOverview", function() EJ_TOOLTIP:HookHeaders() end)

        hooksecurefunc("EncounterJournal_SetTooltipWithCompare", function(tooltip, link)
            local db = ExwindTools:GetModuleDB("ExTools.MiniTools")
            if not db.EJTooltip or not link then return end
            local type, id = link:match("H(%a+):(%d+)")
            if id then
                tooltip:AddLine(" ")
                local label = (type == "spell") and "SpellID:" or "ID:"
                tooltip:AddDoubleLine("|cff00ff00" .. label .. "|r", "|cffffd100" .. id .. "|r")
                tooltip:Show()
            end
        end)
    end

    if C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
        SetupHooks()
        EJ_TOOLTIP:HookHeaders()
    else
        ExwindTools:RegisterEvent("ADDON_LOADED", "ExTools_Mini_EJTooltip", function(_, addonName)
            if addonName == "Blizzard_EncounterJournal" then
                SetupHooks()
                C_Timer.After(0.1, function() EJ_TOOLTIP:HookHeaders() end)
            end
        end)
    end
end

-- ========================================================================
-- 11. [MerchantExpansion] 商人界面加宽
-- ========================================================================
local function Init_MerchantExpansion()
    local function GetDB() return ExwindTools:GetModuleDB("ExTools.MiniTools") end

    -- 记录当前宽度，供修理按钮 hook 使用
    local currentMerchantWidth = 0
    local merchantBottomBorderLeft, merchantBottomBorderRight

    local function EnsureBottomBorderParts()
        if merchantBottomBorderLeft and merchantBottomBorderRight then
            return
        end

        merchantBottomBorderLeft = MerchantFrame:CreateTexture(nil, "OVERLAY")
        merchantBottomBorderLeft:SetAtlas("UI-Merchant-BotFrame")
        merchantBottomBorderLeft:SetTexCoord(0, 0.495, 0, 1)

        merchantBottomBorderRight = MerchantFrame:CreateTexture(nil, "OVERLAY")
        merchantBottomBorderRight:SetAtlas("UI-Merchant-BotFrame")
        merchantBottomBorderRight:SetTexCoord(0.505, 1, 0, 1)
    end

    -- 底部边框处理：
    -- 原生纹理中间存在明显分隔视觉，这里使用同一段纹理整段铺开，
    -- 避免任何中心拼接线。
    local function UpdateBottomBorder(isBuyback, newWidth)
        EnsureBottomBorderParts()

        if MerchantFrameBottomLeftBorder then
            MerchantFrameBottomLeftBorder:Hide()
        end

        if isBuyback then
            if merchantBottomBorderLeft then merchantBottomBorderLeft:Hide() end
            if merchantBottomBorderRight then merchantBottomBorderRight:Hide() end
            return
        end

        merchantBottomBorderLeft:Show()
        merchantBottomBorderLeft:ClearAllPoints()
        merchantBottomBorderLeft:SetPoint("BOTTOMLEFT", MerchantFrame, "BOTTOMLEFT", 1, 26)
        merchantBottomBorderLeft:SetPoint("TOPRIGHT", MerchantFrame, "BOTTOMRIGHT", -1, 87)
        merchantBottomBorderLeft:SetTexCoord(0.02, 0.47, 0, 1)

        merchantBottomBorderRight:Hide()
    end

    -- 重新锚定底部 inset，避免加宽后出现中段“截断重启”的视觉断层
    local function UpdateBottomInsets(newWidth)
        -- 暴雪原生将底部拆成左右两个 inset（货币区 + 金币区），
        -- 在加宽布局下中间接缝会非常明显。这里统一成单一全宽 inset。
        if MerchantExtraCurrencyInset then
            MerchantExtraCurrencyInset:Hide()
        end
        if MerchantExtraCurrencyBg then
            MerchantExtraCurrencyBg:Hide()
        end

        if MerchantMoneyInset then
            MerchantMoneyInset:Show()
            MerchantMoneyInset:ClearAllPoints()
            MerchantMoneyInset:SetPoint("TOPLEFT", MerchantFrame, "BOTTOMLEFT", 4, 27)
            MerchantMoneyInset:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMRIGHT", -5, 4)
            if MerchantMoneyInset.Bg then
                MerchantMoneyInset.Bg:SetTexture("Interface\\Buttons\\WHITE8X8")
                MerchantMoneyInset.Bg:SetHorizTile(false)
                MerchantMoneyInset.Bg:SetVertTile(false)
                MerchantMoneyInset.Bg:SetVertexColor(0, 0, 0, 0.35)
            end
        end

        if MerchantMoneyBg then
            MerchantMoneyBg:Show()
            MerchantMoneyBg:ClearAllPoints()
            MerchantMoneyBg:SetPoint("TOPLEFT", MerchantFrame, "BOTTOMLEFT", 7, 25)
            MerchantMoneyBg:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMRIGHT", -7, 6)
            if MerchantMoneyBgMiddle then
                MerchantMoneyBgMiddle:SetTexture("Interface\\Buttons\\WHITE8X8")
                MerchantMoneyBgMiddle:SetTexCoord(0, 1, 0, 1)
                MerchantMoneyBgMiddle:SetVertexColor(0, 0, 0, 1)
            end
        end
    end

    -- 修理/卖垃圾按钮定位（独立函数，防止暴雪 MerchantFrame_UpdateRepairButtons 的
    -- SetPoint 叠加锚点导致图标畸形）
    local function FixRepairButtons()
        if not MerchantFrame or not MerchantFrame:IsShown() then return end
        local centerX = currentMerchantWidth / 2
        local btnY = 34

        -- 暴雪在 MerchantFrame_UpdateRepairButtons 里会先 SetPoint 不清点，
        -- 所以这里必须先 ClearAllPoints 再设置，确保只有一个锚点。
        if MerchantRepairAllButton and MerchantRepairAllButton:IsShown() then
            MerchantRepairAllButton:ClearAllPoints()
            MerchantRepairAllButton:SetPoint("BOTTOM", MerchantFrame, "BOTTOMLEFT", centerX + 10, btnY)
        end

        if MerchantRepairItemButton and MerchantRepairItemButton:IsShown() then
            MerchantRepairItemButton:ClearAllPoints()
            MerchantRepairItemButton:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", -4, 0)
        end

        if MerchantSellAllJunkButton then
            MerchantSellAllJunkButton:ClearAllPoints()
            if MerchantRepairAllButton and MerchantRepairAllButton:IsShown() then
                -- 卖垃圾在修理全部右侧
                MerchantSellAllJunkButton:SetPoint("LEFT", MerchantRepairAllButton, "RIGHT", 12, 0)
            else
                -- 无修理按钮时居中显示
                MerchantSellAllJunkButton:SetPoint("BOTTOM", MerchantFrame, "BOTTOMLEFT", centerX, btnY)
            end
        end

        if MerchantGuildBankRepairButton and MerchantGuildBankRepairButton:IsShown() then
            MerchantGuildBankRepairButton:ClearAllPoints()
            MerchantGuildBankRepairButton:SetPoint("LEFT", MerchantSellAllJunkButton, "RIGHT", 4, 0)
        end
    end

    local function ApplyLayout()
        if not MerchantFrame then return end
        local db = GetDB()
        local cols = tonumber(db.MerchantColumns) or 3
        -- 严格执行"原本高度"：商人页 5 行，买回页 6 行
        local isBuyback = (MerchantFrame.selectedTab == 2)
        local rows = isBuyback and 6 or 5
        local itemsPerPage = cols * rows

        _G.MERCHANT_ITEMS_PER_PAGE = itemsPerPage
        _G.BUYBACK_ITEMS_PER_PAGE = itemsPerPage

        -- 按需补全格子，支持 2-5 列
        for i = 1, 30 do
            local name = "MerchantItem" .. i
            local f = _G[name]
            if i <= itemsPerPage then
                if not f then
                    f = CreateFrame("Frame", name, MerchantFrame, "MerchantItemTemplate")
                end
                f:Show()
            elseif f then
                f:Hide()
            end
        end

        local itemWidth = 153
        local spacingX = 12
        local newWidth = 11 + cols * itemWidth + (cols - 1) * spacingX + 19
        local originalHeight = 444 -- 锁定暴雪原始高度

        MerchantFrame:SetSize(newWidth, originalHeight)
        currentMerchantWidth = newWidth

        UpdateBottomBorder(isBuyback, newWidth)
        UpdateBottomInsets(newWidth)

        -- 分页文字与按钮 居中展示
        local centerX = newWidth / 2
        if MerchantPageText then
            MerchantPageText:ClearAllPoints()
            MerchantPageText:SetPoint("BOTTOM", MerchantFrame, "BOTTOMLEFT", centerX, 86)
        end
        if MerchantPrevPageButton then
            MerchantPrevPageButton:ClearAllPoints()
            MerchantPrevPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", 25, 96)
        end
        if MerchantNextPageButton then
            MerchantNextPageButton:ClearAllPoints()
            MerchantNextPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", newWidth - 26, 96)
        end

        -- 修理/卖垃圾按钮由 FixRepairButtons 统一处理
        FixRepairButtons()
    end

    local function PositionItems()
        if not MerchantFrame or not MerchantFrame:IsShown() then return end
        local db = GetDB()
        local cols = tonumber(db.MerchantColumns) or 3
        local isBuyback = MerchantFrame.selectedTab == 2
        local offset_y = isBuyback and 15 or 8
        local rows = isBuyback and 6 or 5

        for i = 1, cols * rows do
            local item = _G["MerchantItem" .. i]
            if item then
                item:ClearAllPoints()
                if i == 1 then
                    item:SetPoint("TOPLEFT", 11, -69) -- 原始高度起始
                elseif (i - 1) % cols == 0 then
                    -- 换行
                    item:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - cols)], "BOTTOMLEFT", 0, -offset_y)
                else
                    -- 水平排列
                    item:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", 12, 0)
                end
            end
        end

        -- BuyBackItem 原生锚定 MerchantItem10，列数变化后位置错乱，
        -- 固定在框架右侧，与修理按钮区保持分离。
        if MerchantBuyBackItem and not isBuyback then
            MerchantBuyBackItem:ClearAllPoints()
            MerchantBuyBackItem:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMRIGHT", -8, 33)
        end
    end

    hooksecurefunc("MerchantFrame_Update", function()
        ApplyLayout()
        PositionItems()
    end)

    -- 暴雪 MerchantFrame_UpdateRepairButtons 内部用 SetPoint 不先 ClearAllPoints，
    -- 导致按钮锚点叠加而变形。在其执行完毕后重新修正。
    hooksecurefunc("MerchantFrame_UpdateRepairButtons", function()
        FixRepairButtons()
    end)

    MerchantFrame:HookScript("OnShow", function()
        ApplyLayout()
        PositionItems()
    end)

    ExwindTools:WatchState("ExTools.MiniTools.DatabaseChanged", "ExTools_Merchant_Update", function(info)
        if info.key == "MerchantExpansion" or info.key == "MerchantColumns" then
            ApplyLayout()
            PositionItems()
            if MerchantFrame:IsShown() then MerchantFrame_Update() end
        end
    end)
end

-- ========================================================================
-- 12. [MacroEnhancement] 宏界面增强（迁移自 ExTools.MacroExtension）
-- 说明：仅提供"启用/禁用"开关，不提供额外参数。
-- ========================================================================
local function Init_MacroEnhancement()
    local DB_KEY = "ExTools.MiniTools"
    local OWNER_PREFIX = "ExTools_Mini_MacroEnhance"

    local BASE_WIDTH = 338
    local BASE_HEIGHT = 424
    local TARGET_WIDTH = 500
    local TARGET_HEIGHT = 560

    local SpellIconKeywordMap = {}
    local IconPathFileIDCache = {}
    local IconFileIDProbeTexture = nil
    local HooksInstalled = false

    local function IsFeatureEnabled()
        local db = ExwindTools:GetModuleDB(DB_KEY)
        return db and db.MacroEnhancement
    end

    local function TrimText(text)
        if not text then return "" end
        text = string.gsub(text, "^%s+", "")
        text = string.gsub(text, "%s+$", "")
        return text
    end

    local function Clamp(value, minValue, maxValue)
        if value < minValue then return minValue end
        if value > maxValue then return maxValue end
        return value
    end

    local function UpdateSearchBoxVisual(searchBox)
        if not searchBox then return end
        if SearchBoxTemplate_OnTextChanged then
            SearchBoxTemplate_OnTextChanged(searchBox)
        elseif searchBox.Instructions then
            searchBox.Instructions:SetShown(searchBox:GetText() == "")
        end
    end

    local function AddIconKeyword(map, icon, keyword)
        if not icon or not keyword or keyword == "" then return end
        local normalized = string.lower(keyword)
        local current = map[icon]
        if not current then
            map[icon] = normalized
            return
        end
        if not string.find(current, normalized, 1, true) then
            map[icon] = current .. "\n" .. normalized
        end
    end

    local function RebuildSpellIconKeywordMap()
        SpellIconKeywordMap = {}
        if not C_SpellBook or not Enum or not Enum.SpellBookSpellBank then
            return
        end

        local skillLineCount = C_SpellBook.GetNumSpellBookSkillLines and C_SpellBook.GetNumSpellBookSkillLines() or 0
        for skillLineIndex = 1, skillLineCount do
            local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex)
            if skillLineInfo then
                for i = 1, skillLineInfo.numSpellBookItems do
                    local slotIndex = skillLineInfo.itemIndexOffset + i
                    local icon = C_SpellBook.GetSpellBookItemTexture(slotIndex, Enum.SpellBookSpellBank.Player)
                    local name, subName = C_SpellBook.GetSpellBookItemName(slotIndex, Enum.SpellBookSpellBank.Player)
                    AddIconKeyword(SpellIconKeywordMap, icon, name)
                    AddIconKeyword(SpellIconKeywordMap, icon, subName)
                end
            end
        end
    end

    local function GetIconFileID(icon)
        if not icon then return nil end
        if type(icon) == "number" then return icon end
        if type(icon) ~= "string" then return nil end

        local cached = IconPathFileIDCache[icon]
        if cached ~= nil then
            return cached
        end

        local fileID = nil
        if GetFileIDFromPath then
            local pathVariants = {
                icon,
                string.gsub(icon, "\\", "/"),
                string.lower(icon),
                string.lower(string.gsub(icon, "\\", "/")),
            }
            for i = 1, #pathVariants do
                local ok, result = pcall(GetFileIDFromPath, pathVariants[i])
                if ok and result and result > 0 then
                    fileID = result
                    break
                end
            end
        end

        if not fileID then
            if not IconFileIDProbeTexture then
                local probeFrame = CreateFrame("Frame")
                IconFileIDProbeTexture = probeFrame:CreateTexture(nil, "ARTWORK")
            end
            local ok = pcall(IconFileIDProbeTexture.SetTexture, IconFileIDProbeTexture, icon)
            if ok and IconFileIDProbeTexture.GetTextureFileID then
                local probeFileID = IconFileIDProbeTexture:GetTextureFileID()
                if probeFileID and probeFileID > 0 then
                    fileID = probeFileID
                end
            end
            IconFileIDProbeTexture:SetTexture(nil)
        end

        IconPathFileIDCache[icon] = fileID or false
        return fileID
    end

    local function ApplyMacroFrameLayout()
        if not MacroFrame then return end

        local enabled = IsFeatureEnabled()
        local width = enabled and TARGET_WIDTH or BASE_WIDTH
        local height = enabled and TARGET_HEIGHT or BASE_HEIGHT

        local deltaHeight = height - BASE_HEIGHT
        local selectorExtraHeight = math.floor(deltaHeight * 0.65)
        local inputExtraHeight = deltaHeight - selectorExtraHeight

        MacroFrame:SetSize(width, height)

        if MacroFrame.MacroSelector then
            local selectorWidth = width - 19
            local selectorHeight = math.max(146, 146 + selectorExtraHeight)
            MacroFrame.MacroSelector:SetSize(selectorWidth, selectorHeight)
            MacroFrame.MacroSelector:ClearAllPoints()
            MacroFrame.MacroSelector:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 12, -66)

            local selector = MacroFrame.MacroSelector
            local stride, horizontalSpacing
            if enabled then
                -- 启用增强时优先固定一行 10 个，宽度不足时自动降级。
                local usableWidth = selectorWidth - 32
                local targetStride = 10
                local buttonSize = 36
                local minSpacing = 2
                local maxSpacing = 20
                horizontalSpacing = math.floor((usableWidth - targetStride * buttonSize) / (targetStride - 1))
                stride = targetStride

                if horizontalSpacing < minSpacing then
                    horizontalSpacing = minSpacing
                    stride = Clamp(math.floor((usableWidth + horizontalSpacing) / (buttonSize + horizontalSpacing)), 6,
                        targetStride)
                elseif horizontalSpacing > maxSpacing then
                    horizontalSpacing = maxSpacing
                end
            else
                -- 关闭增强时回到暴雪原始 6 列节奏。
                stride = 6
                horizontalSpacing = 13
            end

            if selector.SetCustomPadding then
                selector:SetCustomPadding(5, 5, 5, 5, horizontalSpacing, 13)
            end
            if selector.SetCustomStride then
                selector:SetCustomStride(stride)
            end

            -- ScrollBoxSelector 的 stride 在 Init() 时固化，更新后重建视图。
            if selector.initialized and selector.Init then
                selector.initialized = false
                selector:Init()
            elseif selector.UpdateSelections then
                selector:UpdateSelections()
            end
        end

        if MacroHorizontalBarLeft then
            MacroHorizontalBarLeft:SetWidth(width - 82)
            MacroHorizontalBarLeft:ClearAllPoints()
            MacroHorizontalBarLeft:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 2, -(210 + selectorExtraHeight))
        end

        if MacroFrameSelectedMacroBackground then
            MacroFrameSelectedMacroBackground:ClearAllPoints()
            MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 5,
                -(218 + selectorExtraHeight))
        end

        if MacroFrameSelectedMacroName then
            MacroFrameSelectedMacroName:SetWidth(width - 82)
            MacroFrameSelectedMacroName:ClearAllPoints()
            MacroFrameSelectedMacroName:SetPoint("TOPLEFT", MacroFrameSelectedMacroBackground, "TOPRIGHT", -4, -10)
        end

        if MacroEditButton then
            MacroEditButton:ClearAllPoints()
            MacroEditButton:SetPoint("TOPLEFT", MacroFrameSelectedMacroBackground, "TOPLEFT", 55, -30)
            MacroEditButton:SetWidth(math.max(170, width - 163))
        end

        if MacroFrameTextBackground then
            MacroFrameTextBackground:SetSize(width - 16, 95 + inputExtraHeight)
            MacroFrameTextBackground:ClearAllPoints()
            MacroFrameTextBackground:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 6, -(289 + selectorExtraHeight))
        end

        if MacroFrameScrollFrame then
            local scrollWidth = width - 52
            local scrollHeight = 85 + inputExtraHeight
            MacroFrameScrollFrame:SetSize(scrollWidth, scrollHeight)
            MacroFrameScrollFrame:ClearAllPoints()
            MacroFrameScrollFrame:SetPoint("TOPLEFT", MacroFrameSelectedMacroBackground, "BOTTOMLEFT", 11, -13)
            if MacroFrameText then
                MacroFrameText:SetSize(scrollWidth, scrollHeight)
            end
            if MacroFrameTextButton then
                MacroFrameTextButton:SetSize(scrollWidth, scrollHeight)
            end
        end

        SetUIPanelAttribute(MacroFrame, "width", width)
        if MacroFrame:IsShown() then
            UpdateUIPanelPositions(MacroFrame)
        end
    end

    local function GetSearchBox(popup)
        if not popup or not popup.BorderBox then return nil end
        if popup.ExMiniMacroSearchBox then
            return popup.ExMiniMacroSearchBox
        end

        local searchBox = CreateFrame("EditBox", nil, popup.BorderBox, "SearchBoxTemplate")
        searchBox:SetSize(182, 20)
        searchBox:SetPoint("TOPLEFT", popup.BorderBox.IconSelectorEditBox, "BOTTOMLEFT", 0, -13)
        searchBox:SetAutoFocus(false)
        if searchBox.Instructions then
            searchBox.Instructions:SetText(L["搜索法术/图标ID"])
        end

        popup.ExMiniMacroSearchBox = searchBox
        return searchBox
    end

    local function UpdatePopupHintTextState(popup)
        if not popup or not popup.BorderBox or not popup.BorderBox.IconSelectionText then return end
        if IsFeatureEnabled() then
            popup.BorderBox.IconSelectionText:Hide()
            popup.BorderBox.IconSelectionText:SetAlpha(0)
        else
            popup.BorderBox.IconSelectionText:SetAlpha(1)
            local draggingIcon = popup.BorderBox.IconDragArea and popup.BorderBox.IconDragArea:IsShown()
            popup.BorderBox.IconSelectionText:SetShown(not draggingIcon)
        end
    end

    local function MatchIcon(icon, queryLower, queryNumber)
        if icon == nil then return false end

        if queryNumber then
            if type(icon) == "number" then
                if icon == queryNumber or string.find(tostring(icon), queryLower, 1, true) then
                    return true
                end
            elseif type(icon) == "string" then
                local asNumber = tonumber(icon)
                if asNumber and (asNumber == queryNumber or string.find(tostring(asNumber), queryLower, 1, true)) then
                    return true
                end

                local fileID = GetIconFileID(icon)
                if fileID and (fileID == queryNumber or string.find(tostring(fileID), queryLower, 1, true)) then
                    return true
                end
            end
        end

        if type(icon) == "string" then
            local iconLower = string.lower(icon)
            if string.find(iconLower, queryLower, 1, true) then
                return true
            end
            local shortName = string.gsub(iconLower, "^interface\\icons\\", "")
            if string.find(shortName, queryLower, 1, true) then
                return true
            end
        elseif type(icon) == "number" then
            if string.find(tostring(icon), queryLower, 1, true) then
                return true
            end
        end

        local keywords = SpellIconKeywordMap[icon]
        if keywords and string.find(keywords, queryLower, 1, true) then
            return true
        end

        return false
    end

    local function BuildFilteredIcons(popup, query)
        local filtered = {}
        if not popup or not popup.iconDataProvider then
            return filtered
        end

        local queryLower = string.lower(query)
        local queryNumber = tonumber(queryLower)
        local seen = {}

        local function BuildIconKey(icon)
            if type(icon) == "number" then
                return "n:" .. tostring(icon)
            end
            return "s:" .. tostring(icon)
        end

        local function AddUnique(icon)
            if icon == nil then return end
            local key = BuildIconKey(icon)
            if seen[key] then return end
            seen[key] = true
            filtered[#filtered + 1] = icon
        end

        local total = popup.iconDataProvider:GetNumIcons()
        for i = 1, total do
            local icon = popup.iconDataProvider:GetIconByIndex(i)
            if MatchIcon(icon, queryLower, queryNumber) then
                AddUnique(icon)
            end
        end

        if queryNumber then
            AddUnique(queryNumber)
            if C_Spell and C_Spell.GetSpellTexture then
                local ok, spellIcon = pcall(C_Spell.GetSpellTexture, queryNumber)
                if ok and spellIcon then
                    AddUnique(spellIcon)
                end
            end
        end

        return filtered
    end

    local function ApplyDefaultProvider(popup)
        popup.IconSelector:SetSelectionsDataProvider(
            GenerateClosure(popup.GetIconByIndex, popup),
            GenerateClosure(popup.GetNumIcons, popup)
        )
        popup.IconSelector:UpdateSelections()
    end

    local function ApplyFilteredProvider(popup, filteredIcons)
        popup._exMiniMacroFilteredIcons = filteredIcons
        popup.IconSelector:SetSelectionsDataProvider(
            function(index)
                local list = popup._exMiniMacroFilteredIcons
                return list and list[index] or nil
            end,
            function()
                local list = popup._exMiniMacroFilteredIcons
                return list and #list or 0
            end
        )
        popup.IconSelector:UpdateSelections()
    end

    local function ReevaluateSelection(popup, filteredIcons)
        local selectedTexture = popup.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture()
        local selectedIndex = nil

        if filteredIcons then
            for i = 1, #filteredIcons do
                if filteredIcons[i] == selectedTexture then
                    selectedIndex = i
                    break
                end
            end
        else
            selectedIndex = popup:GetIndexOfIcon(selectedTexture)
        end

        popup.IconSelector:SetSelectedIndex(selectedIndex)
        popup:SetSelectedIconText()
        if selectedIndex then
            popup.IconSelector:ScrollToSelectedIndex()
        end
    end

    local function RefreshIconSearch(popup)
        if not popup or not popup.IconSelector or not popup.iconDataProvider then return end

        local searchBox = GetSearchBox(popup)
        if not searchBox then return end

        local searchEnabled = IsFeatureEnabled()
        if not searchEnabled then
            searchBox:Hide()
            popup._exMiniMacroFilteredIcons = nil
            ApplyDefaultProvider(popup)
            ReevaluateSelection(popup, nil)
            UpdatePopupHintTextState(popup)
            return
        end

        UpdatePopupHintTextState(popup)
        searchBox:Show()

        local query = TrimText(searchBox:GetText() or "")
        if query == "" then
            popup._exMiniMacroFilteredIcons = nil
            ApplyDefaultProvider(popup)
            ReevaluateSelection(popup, nil)
            return
        end

        local filteredIcons = BuildFilteredIcons(popup, query)
        ApplyFilteredProvider(popup, filteredIcons)
        ReevaluateSelection(popup, filteredIcons)
    end

    local function SetupSearchBoxHandlers(popup)
        local searchBox = GetSearchBox(popup)
        if not searchBox or searchBox._exMiniMacroHooked then return end

        searchBox:SetScript("OnTextChanged", function(self)
            UpdateSearchBoxVisual(self)
            RefreshIconSearch(popup)
        end)

        searchBox:SetScript("OnEscapePressed", function(self)
            self:SetText("")
            self:ClearFocus()
            RefreshIconSearch(popup)
        end)

        searchBox._exMiniMacroHooked = true
    end

    local function InstallHooks()
        if HooksInstalled or not MacroFrame or not MacroPopupFrame then return end
        HooksInstalled = true

        MacroFrame:HookScript("OnShow", function()
            -- 关闭增强后不再在每次打开宏界面时强制重排，避免覆盖其他插件布局
            if IsFeatureEnabled() then
                ApplyMacroFrameLayout()
            end
        end)

        MacroPopupFrame:HookScript("OnShow", function(popup)
            RebuildSpellIconKeywordMap()
            SetupSearchBoxHandlers(popup)
            UpdatePopupHintTextState(popup)
            if popup.ExMiniMacroSearchBox then
                popup.ExMiniMacroSearchBox:SetText("")
                UpdateSearchBoxVisual(popup.ExMiniMacroSearchBox)
            end
            RefreshIconSearch(popup)
        end)

        MacroPopupFrame:HookScript("OnHide", function(popup)
            if popup.ExMiniMacroSearchBox then
                popup.ExMiniMacroSearchBox:SetText("")
                UpdateSearchBoxVisual(popup.ExMiniMacroSearchBox)
            end
            popup._exMiniMacroFilteredIcons = nil
        end)

        hooksecurefunc(MacroPopupFrame, "Update", function(popup)
            RefreshIconSearch(popup)
        end)
        hooksecurefunc(MacroPopupFrame, "SetIconFilterInternal", function(popup)
            RefreshIconSearch(popup)
        end)
        hooksecurefunc(MacroPopupFrame, "UpdateStateFromCursorType", function(popup)
            UpdatePopupHintTextState(popup)
        end)

        ApplyMacroFrameLayout()
    end

    local function TryInit()
        if not C_AddOns.IsAddOnLoaded("Blizzard_MacroUI") then
            return false
        end
        if not MacroFrame or not MacroPopupFrame then
            return false
        end
        InstallHooks()
        return true
    end

    -- 始终注册监听器以支持运行时开启，但只有开关打开时才真正安装钩子
    ExwindTools:RegisterEvent("ADDON_LOADED", OWNER_PREFIX .. "_Init", function(_, addonName)
        if addonName ~= "Blizzard_MacroUI" then return end
        if not IsFeatureEnabled() or HooksInstalled then return end
        C_Timer.After(0, TryInit)
    end)

    if IsFeatureEnabled() then
        TryInit()
    end

    ExwindTools:WatchState(DB_KEY .. ".DatabaseChanged", OWNER_PREFIX .. "_DB", function(info)
        if not info or info.key ~= "MacroEnhancement" then return end

        if IsFeatureEnabled() and not HooksInstalled then
            TryInit()
        end

        if MacroFrame then
            ApplyMacroFrameLayout()
        end
        if MacroPopupFrame and MacroPopupFrame:IsShown() then
            RefreshIconSearch(MacroPopupFrame)
        end
    end)
end

-- ========================================================================
-- 模块核心
-- ========================================================================
local EXWIND_MODULE_KEY = "ExTools.MiniTools"
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local EXWIND_DEFAULTS = {
    --
    ShowMapInfo = true,
    MapInfoHideMapID = true,
    MapInfoAnchor = "中下",
    MapInfoFont = {
        font = "默认",
        size = 20,
        outline = "OUTLINE",
        r = 1,
        g = 0.88,
        b = 0.11,
        a = 1,
        shadow = false,
        shadowX = 1,
    },
    AutoDelete = true,
    AutoSellJunk = true,

    -- AutoCombatLog 详细配置
    AutoCombatLog = true, -- 总开关
    ACL_DungeonNormal = false,
    ACL_DungeonHeroic = false,
    ACL_DungeonMythic = true,
    ACL_DungeonChallenge = true, -- M+
    ACL_DungeonFollower = false,
    ACL_RaidLFR = false,
    ACL_RaidNormal = false,
    ACL_RaidHeroic = true,
    ACL_RaidMythic = true,

    -- BulkBuy
    BulkBuy = true,
    BulkBuy_WarnThreshold = 1000,

    -- ResetDMG
    AutoResetDamageMeter = true,

    -- CombatAlert
    CombatAlert = true,
    CombatEnterText = "进入战斗",
    CombatLeaveText = "离开战斗",
    CombatEnterFont = {
        font = "默认",
        size = 35,
        r = 1,
        g = 0.2,
        b = 0.2,
        a = 1,
        outline = "THICKOUTLINE",
        shadow = true,
        shadowX = 2,
        shadowY = -2,
        x = 0,
        y = 0,
    },
    CombatLeaveFont = {
        font = "默认",
        size = 35,
        r = 0.2,
        g = 1,
        b = 0.2,
        a = 1,
        outline = "THICKOUTLINE",
        shadow = true,
        shadowX = 2,
        shadowY = -2,
        x = 0,
        y = 0,
    },
    CombatEnterPosX = 0,
    CombatEnterPosY = 200,
    CombatLeavePosX = 0,
    CombatLeavePosY = 200,
    -- AutoRepair
    AutoRepair = true,
    AutoRepair_UseGuildBank = false,
    AutoRepair_ShowMessage = true,

    -- HideBattleTag
    HideBattleTag = false,
    BattleTagText = "",

    -- EJTooltip
    EJTooltip = true,

    -- MerchantExpansion
    MerchantExpansion = false,
    MerchantColumns = "3",

    -- MacroEnhancement
    MacroEnhancement = false,
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)

-- 初始化逻辑
local function SafeInit(func, name)
    local ok, err = pcall(func)
    if not ok then
        print("|cffff0000[ExwindTools] MiniTool Init Error (" .. name .. "):|r " .. tostring(err))
    end
end

if EX_DB.ShowMapInfo then SafeInit(Init_ShowMapInfo, "ShowMapInfo") end
if EX_DB.AutoDelete then SafeInit(Init_AutoDelete, "AutoDelete") end
if EX_DB.AutoSellJunk then SafeInit(Init_AutoSellJunk, "AutoSellJunk") end
if EX_DB.AutoCombatLog then SafeInit(Init_AutoCombatLog, "AutoCombatLog") end
if EX_DB.BulkBuy then SafeInit(Init_BulkBuy, "BulkBuy") end
if EX_DB.AutoResetDamageMeter then SafeInit(Init_ResetDamageMeter, "AutoResetDamageMeter") end
SafeInit(Init_CombatAlert, "CombatAlert")
if EX_DB.AutoRepair then SafeInit(Init_AutoRepair, "AutoRepair") end
if EX_DB.HideBattleTag then SafeInit(Init_HideBattleTag, "HideBattleTag") end
if EX_DB.EJTooltip then SafeInit(Init_EJTooltip, "EJTooltip") end
if EX_DB.MerchantExpansion then SafeInit(Init_MerchantExpansion, "MerchantExpansion") end
SafeInit(Init_MacroEnhancement, "MacroEnhancement")

-- ========================================================================
-- Grid 布局
-- ========================================================================
local function EX_RegisterLayout()
    local layout = {
        { key = "head", type = "header", x = 2, y = 1, w = 52, h = 2, label = L["小工具箱 (Mini Tools)"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 52, h = 2, label = L["汇集各种小型实用功能。|cffff0000注意：更改设置后通常需要重载界面 (/reload) 才能完全生效。|r"] },
        { key = "h_map", type = "header", x = 2, y = 6, w = 52, h = 2, label = L["1. 地图信息 (可隐藏ID + 鼠标/玩家坐标)"], labelSize = 20 },
        { key = "ShowMapInfo", type = "checkbox", x = 2, y = 9, w = 30, h = 2, label = L["启用：世界地图显示坐标信息"] },
        { key = "MapInfoHideMapID", type = "checkbox", x = 34, y = 9, w = 20, h = 2, label = L["不显示地图ID"] },
        { key = "MapInfoAnchor", type = "dropdown", x = 2, y = 12, w = 14, h = 2, label = L["显示位置"], items = { "左下", "左上", "右下", "右上", "中下" } },
        { key = "MapInfoFont", type = "fontgroup", x = 2, y = 15, w = 53, h = 20, label = L["字体设置"] },
        { key = "h_del", type = "header", x = 2, y = 36, w = 52, h = 2, label = L["2. 自动删除确认"], labelSize = 20 },
        { key = "AutoDelete", type = "checkbox", x = 2, y = 39, w = 30, h = 2, label = L["启用：删除物品时自动填写 'DELETE'"] },
        { key = "h_junk", type = "header", x = 2, y = 42, w = 52, h = 2, label = L["3. 自动卖垃圾"], labelSize = 18 },
        { key = "AutoSellJunk", type = "checkbox", x = 2, y = 45, w = 30, h = 2, label = L["启用：打开商人时自动出售灰色物品"] },
        { key = "h_acl", type = "header", x = 2, y = 48, w = 52, h = 2, label = L["4. 自动战斗记录"], labelSize = 18 },
        { key = "AutoCombatLog", type = "checkbox", x = 2, y = 51, w = 30, h = 2, label = L["启用模块 (总开关)"] },
        { key = "lbl_dungeon", type = "description", x = 2, y = 54, w = 20, h = 2, label = "|cffffd100> " .. L["5人地下城设置"] .. "|r" },
        { key = "ACL_DungeonNormal", type = "checkbox", x = 9, y = 56, w = 5, h = 2, label = L["普通"] },
        { key = "ACL_DungeonHeroic", type = "checkbox", x = 15, y = 56, w = 5, h = 2, label = L["英雄"] },
        { key = "ACL_DungeonMythic", type = "checkbox", x = 21, y = 56, w = 5, h = 2, label = L["史诗"] },
        { key = "ACL_DungeonChallenge", type = "checkbox", x = 27, y = 56, w = 6, h = 2, label = L["大秘境"] },
        { key = "ACL_DungeonFollower", type = "checkbox", x = 2, y = 56, w = 6, h = 2, label = L["追随者"] },
        { key = "lbl_raid", type = "description", x = 2, y = 59, w = 10, h = 2, label = "|cffffd100> " .. L["团队副本设置"] .. "|r" },
        { key = "ACL_RaidLFR", type = "checkbox", x = 2, y = 61, w = 6, h = 2, label = L["随机"] },
        { key = "ACL_RaidNormal", type = "checkbox", x = 9, y = 61, w = 5, h = 2, label = L["普通"] },
        { key = "ACL_RaidHeroic", type = "checkbox", x = 15, y = 61, w = 5, h = 2, label = L["英雄"] },
        { key = "ACL_RaidMythic", type = "checkbox", x = 21, y = 61, w = 6, h = 2, label = L["史诗"] },
        { key = "h_bulk", type = "header", x = 2, y = 73, w = 53, h = 2, label = L["6. 批量购买助手"], labelSize = 20 },
        { key = "BulkBuy", type = "checkbox", x = 2, y = 76, w = 30, h = 2, label = L["启用：Shift+点击 接管商人物品购买"] },
        { key = "BulkBuy_WarnThreshold", type = "input", x = 2, y = 80, w = 7, h = 2, label = L["超过多少金后 必须弹出确认窗口才购买"], labelPos = "top" },
        { key = "h_dmg", type = "header", x = 2, y = 83, w = 53, h = 2, label = L["7. 进本重置伤害"], labelSize = 20 },
        { key = "AutoResetDamageMeter", type = "checkbox", x = 2, y = 86, w = 30, h = 2, label = L["启用：进入副本时弹出重置伤害统计确认框"] },
        { key = "h_combat", type = "header", x = 2, y = 89, w = 53, h = 2, label = L["8. 战斗提示"], labelSize = 20 },
        { key = "CombatAlert", type = "checkbox", x = 2, y = 92, w = 30, h = 2, label = L["启用：进入/离开战斗时屏幕中心显示文字提示"] },
        { key = "lbl_combat_enter", type = "description", x = 2, y = 95, w = 53, h = 2, label = "|cffff7777" .. L["进入战斗文字样式"] .. "|r" },
        { key = "CombatEnterText", type = "input", x = 2, y = 98, w = 20, h = 2, label = L["显示文字"] },
        { key = "CombatEnterFont", type = "fontgroup", x = 2, y = 101, w = 53, h = 20, label = L["进入战斗字体"] },
        { key = "lbl_combat_leave", type = "description", x = 2, y = 122, w = 50, h = 2, label = "|cff77ff77" .. L["离开战斗文字样式"] .. "|r" },
        { key = "CombatLeaveText", type = "input", x = 2, y = 125, w = 20, h = 2, label = L["显示文字"] },
        { key = "CombatLeaveFont", type = "fontgroup", x = 2, y = 128, w = 53, h = 20, label = L["离开战斗字体"] },
        { key = "h_btag", type = "header", x = 2, y = 149, w = 53, h = 2, label = L["9. 修改战网名称"], labelSize = 20 },
        { key = "HideBattleTag", type = "checkbox", x = 2, y = 152, w = 30, h = 2, label = L["启用: 修改战网名称 |cffff0c08(需要 /rl 生效)|r"] },
        { key = "BattleTagText", type = "input", x = 2, y = 156, w = 20, h = 2, label = L["输入名称 (留空则隐藏)"] },
        { key = "h_repair", type = "header", x = 2, y = 159, w = 53, h = 2, label = L["10. 自动修理"], labelSize = 20 },
        { key = "AutoRepair", type = "checkbox", x = 2, y = 162, w = 30, h = 2, label = L["启用：打开商人时自动修理全部装备"] },
        { key = "AutoRepair_UseGuildBank", type = "checkbox", x = 2, y = 164, w = 30, h = 2, label = L["优先使用公会银行修理（公会银行余额不足则自费）"] },
        { key = "AutoRepair_ShowMessage", type = "checkbox", x = 2, y = 166, w = 30, h = 2, label = L["修理后在聊天框显示花费提示"] },
        { key = "h_ej", type = "header", x = 2, y = 169, w = 53, h = 2, label = L["11. 地下城手册增强"], labelSize = 20 },
        { key = "EJTooltip", type = "checkbox", x = 2, y = 172, w = 40, h = 2, label = L["启用：技能标题悬停显示 SpellID 及完整法术提示"] },
        { key = "h_merch", type = "header", x = 2, y = 175, w = 53, h = 2, label = L["12. 商人界面增强"], labelSize = 20 },
        { key = "MerchantExpansion", type = "checkbox", x = 2, y = 178, w = 40, h = 2, label = L["启用：商人界面加宽 (不改动高度)"] },
        { key = "MerchantColumns", type = "dropdown", x = 2, y = 181, w = 15, h = 2, label = L["显示列数"], items = { "2", "3", "4", "5" } },
        { key = "h_macro", type = "header", x = 2, y = 184, w = 53, h = 2, label = L["13. 宏界面增强"], labelSize = 20 },
        { key = "MacroEnhancement", type = "checkbox", x = 2, y = 187, w = 48, h = 2, label = L["启用：宏界面增强|cffff1f13(注意 功能测试中!!!)|r"] },
    }





    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end

EX_RegisterLayout()

-- 绑定按钮事件
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(data)
    if data.key == "rlbtn" then C_UI.Reload() end
end)

ExwindTools:ReportReady(EXWIND_MODULE_KEY)
