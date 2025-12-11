-- Housing_Favorites.lua
-- 目标：
-- 1) 在目录元素右上角提供“收藏”星标按钮（默认悬停可见；收藏后常驻显示）。
-- 2) 在暴雪自带“过滤器”下拉菜单中新增一项“仅显示收藏”，启用后列表仅展示收藏内容。
-- 3) 全链路以 decor recordID 为唯一权威，不做任何兼容映射。
-- 4) 代码风格遵循本仓库“配置驱动/单一权威/解耦”的约定，避免与 Referrence/HousingTweaks/Tweaks/Favorites.lua 的实现结构相似。

local ADDON_NAME, ADT = ...
if not ADT then return end

local Favorites = {}
ADT.Favorites = Favorites

-- DB 约定（唯一权威）
local KEY_FAV_MAP = "FavoritesByRID"       -- map<number, boolean>
local KEY_FILTER_ON = "FavoritesFilterOn"  -- boolean

local function GetFavMap()
    local db = _G.ADT_DB or {}
    db[KEY_FAV_MAP] = db[KEY_FAV_MAP] or {}
    return db[KEY_FAV_MAP]
end

local function IsFavoritedRID(recordID)
    if not recordID then return false end
    local map = GetFavMap()
    return not not map[recordID]
end

local function SetFavoritedRID(recordID, state)
    if not recordID then return end
    local map = GetFavMap()
    if state then map[recordID] = true else map[recordID] = nil end
end

function Favorites:IsFilterOn()
    return ADT.GetDBBool(KEY_FILTER_ON)
end

function Favorites:SetFilter(on, silent)
    ADT.SetDBValue(KEY_FILTER_ON, not not on)
    if not silent then
        Favorites:RefreshCatalog()
    end
end

function Favorites:ToggleFilter()
    Favorites:SetFilter(not Favorites:IsFilterOn())
end

-- 工具：从“目录条目按钮”取 decor recordID（单一权威）
local function ExtractRecordIDFromEntryFrame(frame)
    -- 优先从 entryInfo.entryID.recordID 读取（更新且稳定）
    local info = frame and frame.entryInfo
    if info and info.entryID and info.entryID.recordID then
        return info.entryID.recordID
    end
    -- 次选：从元素数据回推（仍为 recordID）
    if frame and frame.GetElementData then
        local ed = frame:GetElementData()
        local e = ed and ed.entryID
        if e and e.recordID then return e.recordID end
    end
    return nil
end

-- 样式/动效统一参数（配置驱动：集中调整）
local FX = {
    starAtlas = "CampCollection-icon-star", -- 注意拼写：CampCollection
    starSize = 22,
    starOffset = { x = -4, y = -2 },
    color = {
        normal = {1, 1, 0},     -- 非收藏/提示用黄
        favorited = {1, 0.9, 0}, -- 收藏后更暖的黄
    },
    alpha = {
        decorHover = 0.5,  -- 鼠标在 Decor 卡片上但未悬停星标
        starHover  = 1.0,   -- 鼠标悬停在星标命中区
        starPressed= 0.8,   -- 鼠标按下星标
        favorite   = 1.0,   -- 收藏常驻显示
    },
    clickFlash = {          -- 点击后 Alpha 闪烁动效
        to = 0.6,
        inDur = 0.05,
        outDur = 0.08,
    },
}

local function SetColor(tex, rgb)
    tex:SetVertexColor(rgb[1], rgb[2], rgb[3])
end

-- 本地化包装：优先取 ADT.L，再回退英文
local function Ls(key, fallback)
    local L = ADT and ADT.L or nil
    return (L and L[key]) or fallback
end

-- 为目录按钮附加/更新星标（不侵入按钮业务；完全独立）
local function EnsureStarOnButton(btn)
    if not btn or btn._ADTStar then return end

    -- 贴图层级：覆盖在按钮最上层但不遮挡Tooltip
    local star = btn:CreateTexture(nil, "OVERLAY", nil, 7)
    star:SetAtlas(FX.starAtlas)
    star:SetSize(FX.starSize, FX.starSize)
    star:SetPoint("TOPRIGHT", btn, "TOPRIGHT", FX.starOffset.x, FX.starOffset.y)
    star:Hide() -- 默认不常驻
    btn._ADTStar = star

    -- 独立点击区域，避免影响按钮原有左键放置
    local hit = CreateFrame("Button", nil, btn)
    hit:SetAllPoints(star)
    hit:SetFrameLevel(btn:GetFrameLevel() + 10)
    btn._ADTStarHit = hit

    -- 轻量交互动效：点击时做一个 Alpha 闪烁
    local clickAG = star:CreateAnimationGroup()
    local a1 = clickAG:CreateAnimation("Alpha")
    a1:SetFromAlpha(FX.alpha.starHover)
    a1:SetToAlpha(FX.clickFlash.to)
    a1:SetDuration(FX.clickFlash.inDur)
    local a2 = clickAG:CreateAnimation("Alpha")
    a2:SetFromAlpha(FX.clickFlash.to)
    a2:SetToAlpha(FX.alpha.starHover)
    a2:SetDuration(FX.clickFlash.outDur)
    star._ADTClickAG = clickAG

    hit:SetScript("OnEnter", function()
        local rid = ExtractRecordIDFromEntryFrame(btn)
        local fav = rid and IsFavoritedRID(rid)
        GameTooltip:SetOwner(hit, "ANCHOR_RIGHT")
        GameTooltip:SetText(fav and Ls("Unfavorite", "Unfavorite") or Ls("Favorite", "Favorite"))
        GameTooltip:Show()
        -- 关键修复：进入星标命中区时显式 Show，避免父按钮 OnLeave 抢先隐藏
        star:Show()
        star:SetAlpha(FX.alpha.starHover)
    end)
    hit:SetScript("OnLeave", function()
        GameTooltip:Hide()
        -- 若仍在父按钮上，回退为低透明度的悬停提示
        if btn:IsMouseOver() then
            local rid = ExtractRecordIDFromEntryFrame(btn)
            if rid and not IsFavoritedRID(rid) then
                star:SetAlpha(FX.alpha.decorHover)
                star:Show()
            end
            return
        end
        -- 完全离开：按收藏态决定显隐
        local rid = ExtractRecordIDFromEntryFrame(btn)
        if not (rid and IsFavoritedRID(rid)) then
            star:Hide()
        end
    end)
    hit:SetScript("OnMouseDown", function()
        star:SetAlpha(FX.alpha.starPressed)
    end)
    hit:SetScript("OnMouseUp", function()
        star:SetAlpha(FX.alpha.starHover)
    end)
    hit:SetScript("OnClick", function()
        local rid = ExtractRecordIDFromEntryFrame(btn)
        if not rid then return end
        local newState = not IsFavoritedRID(rid)
        SetFavoritedRID(rid, newState)
        Favorites:RefreshStar(btn)
        if star._ADTClickAG then star._ADTClickAG:Play() end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if newState then ADT.Notify(Ls("Added to Favorites", "Added to favorites"), "info")
        else ADT.Notify(Ls("Removed from Favorites", "Removed from favorites"), "info") end
        -- 若“仅显示收藏”开启，则实时刷新列表
        if Favorites:IsFilterOn() then
            Favorites:RefreshCatalog()
        end
    end)

    -- 悬停按钮卡片时，非收藏状态下短暂显示星标提示
    btn:HookScript("OnEnter", function()
        local rid = ExtractRecordIDFromEntryFrame(btn)
        if rid and not IsFavoritedRID(rid) then
            SetColor(star, FX.color.normal)
            star:SetAlpha(FX.alpha.decorHover)
            star:Show()
        end
    end)
    btn:HookScript("OnLeave", function()
        -- 若鼠标已进入星标命中区，不应隐藏，避免闪烁和“消失”
        if hit:IsMouseOver() then return end
        local rid = ExtractRecordIDFromEntryFrame(btn)
        if not (rid and IsFavoritedRID(rid)) then
            star:Hide()
        end
    end)
end

function Favorites:RefreshStar(btn)
    local star = btn and btn._ADTStar
    if not star then return end
    local rid = ExtractRecordIDFromEntryFrame(btn)
    local fav = rid and IsFavoritedRID(rid)
    if fav then
        -- 收藏：常驻显示
        SetColor(star, FX.color.favorited)
        star:SetAlpha(FX.alpha.favorite)
        star:Show()
    else
        -- 非收藏：默认隐藏（由悬停控制显示）
        SetColor(star, FX.color.normal)
        star:SetAlpha(FX.alpha.decorHover)
        star:Hide()
    end
end

-- 遍历可见的目录按钮，安装星标并刷新状态
local function SweepVisibleCatalogButtons(scrollBox)
    if not (scrollBox and scrollBox.ForEachFrame) then return end
    scrollBox:ForEachFrame(function(frame)
        -- 仅对“装饰项”模板添加；其他（分割线/说明/套装）跳过
        local ed = frame.GetElementData and frame:GetElementData()
        if ed and ed.templateKey == "CATALOG_ENTRY_DECOR" then
            EnsureStarOnButton(frame)
            Favorites:RefreshStar(frame)
        end
    end)
end

-- 收集“收藏 ∩ 当前筛选/分类/搜索结果”的目录条目
-- 说明：
-- - 为满足“叠加筛选”诉求，来源集合改为 catalogSearcher:GetCatalogSearchResults()
--   这样会自然叠加：仅染色/室内/室外/已收集/未收集/标签组/搜索框/分类等全部官方筛选。
-- - 仍保持 recordID 为唯一权威，严禁做任何“兼容映射”。
local function CollectFavoriteEntries(storagePanel)
    if not (storagePanel and storagePanel.catalogSearcher) then return {} end
    local favs = GetFavMap()
    if not next(favs) then return {} end
    local results = {}
    -- 以“当前筛选结果”为基集合，随后取与收藏的交集
    local filtered = storagePanel.catalogSearcher:GetCatalogSearchResults()
    for _, id in ipairs(filtered or {}) do
        if id.entryType == Enum.HousingCatalogEntryType.Decor and favs[id.recordID] then
            table.insert(results, id)
        end
    end
    return results
end

-- 根据“仅显示收藏”的开关，刷新右侧列表
function Favorites:RefreshCatalog()
    local hf = _G.HouseEditorFrame
    local sp = hf and hf.StoragePanel
    if not sp then return end

    -- 新逻辑：收藏筛选应与“左侧分类/返回按钮”解耦，仅覆盖右侧结果集。
    -- 因此不再使用 SetCustomCatalogData（它会触发 Categories:SetManualFocusState(true) 从而出现返回按钮）。
    if Favorites:IsFilterOn() then
        -- 仅在“仓库”标签内生效；市场/专题等自定义视图不叠加收藏筛选。
        if sp.IsInMarketTab and sp:IsInMarketTab() then
            return
        end
        if sp.customCatalogData then
            return
        end
        local entries = CollectFavoriteEntries(sp)
        local retain = true
        local header = Ls("Favorites", "Favorites")
        -- 直接把“收藏 ∩ 当前筛选”的结果送入 OptionsContainer；不改动分类焦点与返回按钮状态。
        sp.OptionsContainer:SetCatalogData(entries, retain, header, nil)
        -- 在我们覆盖结果后，同步星标与计数显示（官方会在 UpdateCatalogData 里做；此处补齐一次以避免滞后）。
        if sp.UpdateLoadingSpinner then pcall(sp.UpdateLoadingSpinner, sp) end
        if sp.UpdateCategoryTotal then pcall(sp.UpdateCategoryTotal, sp) end
    else
        -- 还原官方数据流：让 searcher 自行刷新
        if sp.catalogSearcher then
            sp.catalogSearcher:RunSearch()
        end
    end
end

-- 将“仅显示收藏”接入暴雪过滤下拉：在原菜单末尾追加复选项，并把重置按钮状态与之联动。
local function HookFilterDropdown(filters)
    if not (filters and filters.FilterDropdown) then return end
    local fd = filters.FilterDropdown
    if fd._ADTFavHooked then return end

    -- 1) 追加菜单项：保留官方生成器，并在其后注入“仅显示收藏”。
    local origGen = fd.menuGenerator
    fd:SetupMenu(function(dropdown, root)
        if type(origGen) == "function" then
            origGen(dropdown, root)
        end
        root:CreateDivider()
        root:CreateCheckbox(Ls("Show Favorites Only", "Show Favorites Only"), function() return Favorites:IsFilterOn() end, function()
            Favorites:ToggleFilter()
            -- 保持下拉菜单开启并刷新选中态
            return MenuResponse.Refresh
        end)
    end)

    -- 2) 重写“是否默认/重置”回调，让 Reset 按钮也管控我们的开关
    local origIsDefault = fd.isDefaultCallback
    local origDefault   = fd.defaultCallback
    fd:SetIsDefaultCallback(function()
        local ok = true
        if type(origIsDefault) == "function" then
            ok = not not origIsDefault()
        end
        return ok and (not Favorites:IsFilterOn())
    end)
    fd:SetDefaultCallback(function()
        if type(origDefault) == "function" then origDefault() end
        Favorites:SetFilter(false, true)
        Favorites:RefreshCatalog()
    end)

    fd._ADTFavHooked = true
    -- 初始校验一次重置按钮显隐
    if fd.ValidateResetState then fd:ValidateResetState() end
end

-- 同步下拉UI（勾选状态、重置按钮、已打开菜单的文本）
local function SyncFilterDropdownUI()
    local sp = _G.HouseEditorFrame and _G.HouseEditorFrame.StoragePanel
    local fd = sp and sp.Filters and sp.Filters.FilterDropdown
    if not fd then return end
    if fd.ValidateResetState then pcall(fd.ValidateResetState, fd) end
    local menu = rawget(fd, "menu")
    if menu and menu.ReinitializeAll then pcall(menu.ReinitializeAll, menu) end
end

-- 在 HouseEditor 的存储面板可用时，安装滚动列表的星标刷新钩子
local function TryInstallToStoragePanel()
    local hf = _G.HouseEditorFrame
    local sp = hf and hf.StoragePanel
    local oc = sp and sp.OptionsContainer
    local sb = oc and oc.ScrollBox
    if not sb then return false end

    if not sb._ADTFavHooked then
        -- 列表刷新时检查/更新星标
        hooksecurefunc(sb, "Update", function(self)
            SweepVisibleCatalogButtons(self)
        end)
        -- 首次也走一遍
        C_Timer.After(0, function() SweepVisibleCatalogButtons(sb) end)
        sb._ADTFavHooked = true
    end

    -- 过滤下拉接入（官方在 StorageFrame:OnLoad 时已完成 Initialize，这里直接挂）
    HookFilterDropdown(sp and sp.Filters)

    -- 当官方搜索结果更新时，如“仅显示收藏”开启，则用“收藏 ∩ 当前结果”刷新自定义列表，
    -- 达成“叠加筛选”的体验（例如：仅可染色 + 仅收藏）。
    if not sp._ADTFav_Results_Hooked then
        hooksecurefunc(sp, "OnEntryResultsUpdated", function(self)
            if Favorites:IsFilterOn() then
                Favorites:RefreshCatalog()
            end
        end)
        sp._ADTFav_Results_Hooked = true
    end

    -- 不再拦截 SetCustomCatalogData：避免把“离开官方自定义视图”误判为需要关闭收藏筛选。

    return true
end

-- 入口：在编辑器出现或 UI 初始化后尝试安装
function Favorites:Init()
    -- 事件驱动：进入/离开编辑器时尝试安装
    local f = CreateFrame("Frame")
    f:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function()
        C_Timer.After(0, TryInstallToStoragePanel)
    end)

    -- 若已在编辑器中，立即尝试
    C_Timer.After(0, TryInstallToStoragePanel)

    -- 兼容：若暴雪过滤器 Mixin 刚初始化完，再次接入我们的下拉扩展
    if _G.HousingCatalogFiltersMixin and not _G.HousingCatalogFiltersMixin._ADT_Hooked then
        hooksecurefunc(HousingCatalogFiltersMixin, "Initialize", function(mixin)
            C_Timer.After(0, function()
                local sp = _G.HouseEditorFrame and _G.HouseEditorFrame.StoragePanel
                if sp and sp.Filters == mixin then
                    HookFilterDropdown(mixin)
                end
            end)
        end)
        _G.HousingCatalogFiltersMixin._ADT_Hooked = true
    end
end

-- 模块装载即初始化
Favorites:Init()

-- 语言切换：刷新标题/菜单文案
function Favorites:OnLocaleChanged()
    if Favorites:IsFilterOn() then
        Favorites:RefreshCatalog()
    end
    SyncFilterDropdownUI()
end
