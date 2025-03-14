local AddonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

-- 插件集最大长度
Addon.ADDON_SET_NAME_MAX_LENGTH = 70
-- 备注最大长度
Addon.REMARK_MAX_LENGTH = 60

Addon.AddonInfos = {}

-- 插件初始启用状态
local AddonInfoInitialStates = {}
for i = 1, C_AddOns.GetNumAddOns() do
    local name, title, notes, loadable, reason, security = C_AddOns.GetAddOnInfo(i)
    local enabled = C_AddOns.GetAddOnEnableState(i, UnitName("player")) > 0
    AddonInfoInitialStates[name] = {
        Enabled = enabled,
        Expired = (reason == "INTERFACE_VERSION")
    }
end

-- 更新插件初始启用状态
function Addon:UpdateAddonInitialEnableState(addonName, enabled)
    AddonInfoInitialStates[addonName].Enabled = enabled
end

-- 插件是否为管理者，即是否为本插件
function Addon:IsAddonManager(name)
    if type(name) ~= "string" then
        return
    end
    return name == AddonName
end

-- 插件是否被收藏
function Addon:IsAddonFavorite(name)
    if type(name) ~= "string" then
        return
    end
    return self.Saved.FavoriteAddons[name]
end

-- 设置插件收藏状态
function Addon:SetAddonFavorite(name, favorite)
    if type(name) ~= "string" then
        return
    end
    self.Saved.FavoriteAddons[name] = favorite and true or nil
end

-- 插件是否被锁定
function Addon:IsAddonLocked(name)
    if type(name) ~= "string" then
        return
    end
    return self.Saved.LockedAddons[name]
end

-- 设置插件锁定状态
function Addon:SetAddonLock(name, lock)
    if type(name) ~= "string" then
        return
    end
    self.Saved.LockedAddons[name] = lock and true or nil
end

-- 插件备注
function Addon:GetAddonRemark(name)
    if type(name) ~= "string" then
        return
    end
    return self.Saved.AddonRemarks[name]
end

-- 设置插件备注
function Addon:SetAddonRemark(name, remark)
    if type(name) ~= "string" then
        return
    end

    if strlenutf8(remark) > self.REMARK_MAX_LENGTH then
        self:ShowError(L["edit_remark_error_too_long"])
        return
    end

    remark = strtrim(remark)
    
    if remark == nil or remark == "" then
        self.Saved.AddonRemarks[name] = nil
        return true
    else
        local addonInfos = self:GetAddonInfos()
        for _, addonInfo in ipairs(addonInfos) do
            if addonInfo.Name ~= name then
                -- 检查是否重名
                if addonInfo.Name == remark then
                    self:ShowError(L["edit_remark_error_name_duplicate"]:format(addonInfo.Title))
                    return
                elseif addonInfo.Title == remark or addonInfo.TitleWithoutColor == remark then
                    self:ShowError(L["edit_remark_error_title_duplicate"]:format(addonInfo.Title))
                    return
                elseif addonInfo.Remark == remark then
                    self:ShowError(L["edit_remark_error_remark_duplicate"]:format(addonInfo.Title))
                    return
                end
            end
        end
        self.Saved.AddonRemarks[name] = remark
        return true
    end
end

-- 获取插件信息，返回值可能为nil
-- query:要么为index:与GetNumAddOns对应的插件位置；要么为name
function Addon:GetAddonInfoOrNil(query, addonInfo)
    if not query then
        return
    end
    if type(query) ~= "string" and type(query) ~= "number" then
        return
    end

    local name, title, notes, loadable, reason, security = C_AddOns.GetAddOnInfo(query)
    if reason == "MISSING" then
        return
    end

    addonInfo = addonInfo or {}

    if type(query) == "number" then
        addonInfo.Index = query
    end

    addonInfo.Name = name
    -- 标题
    addonInfo.Title = title
    -- 标题是否具有颜色
    addonInfo.TitleColorful = title:find("|c%x%x%x%x%x%x%x%x") and true or false
    -- 不带颜色的标题
    addonInfo.TitleWithoutColor = title:gsub("|c%x%x%x%x%x%x%x%x", "")
    addonInfo.Notes = notes
    addonInfo.Author = addonInfo.Author or C_AddOns.GetAddOnMetadata(query, "Author")
    addonInfo.Version = addonInfo.Version or C_AddOns.GetAddOnMetadata(query, "Version")

    -- 图标
    local iconTexture = C_AddOns.GetAddOnMetadata(query, "IconTexture")
    local iconAtlas = C_AddOns.GetAddOnMetadata(query, "IconAtlas")

    local iconText
    if iconTexture then
        iconText = CreateSimpleTextureMarkup(iconTexture, 14, 14)
    elseif iconAtlas then
        iconText = CreateAtlasMarkup(iconAtlas, 14, 14)
    end
    -- 图标文本
    addonInfo.IconText = iconText

    -- 是否可加载（或已加载）
    addonInfo.Loadable = loadable
    -- 是否已加载
    addonInfo.Loaded = C_AddOns.IsAddOnLoaded(query)
    -- 是否按需加载
    addonInfo.LoadOnDemand = C_AddOns.IsAddOnLoadOnDemand(query)
    -- 是否启用
    addonInfo.Enabled = C_AddOns.GetAddOnEnableState(query, UnitName("player")) > Enum.AddOnEnableState.None
    -- 初始启用状态
    addonInfo.InitialEnabled = AddonInfoInitialStates[name].Enabled
    -- 是否过期
    addonInfo.Expired = reason == "INTERFACE_VERSION"
    -- 初始过期状态
    addonInfo.InitialExpired = AddonInfoInitialStates[name].Expired
    -- 不可加载原因
    addonInfo.UnloadableReason = not loadable and reason and _G["ADDON_" .. reason] or ""
    -- 可能值：不安全，安全，非法
    addonInfo.Security = security
    -- 插件依赖
    addonInfo.Deps = addonInfo.Deps or { C_AddOns.GetAddOnDependencies(query) }
    -- 可选依赖
    addonInfo.OptionalDeps = addonInfo.OptionalDeps or { C_AddOns.GetAddOnOptionalDependencies(query) }
    -- 备注
    addonInfo.Remark = self:GetAddonRemark(name)
    -- 是否收藏
    addonInfo.IsFavorite = self:IsAddonFavorite(name)
    -- 是否锁定
    addonInfo.IsLocked = name == AddonName or self:IsAddonLocked(name)
    -- 是否允许解除锁定
    addonInfo.Unlockable = not self:IsAddonManager(name)

    return addonInfo
end

-- 获取插件信息，返回值不为nil
function Addon:GetAddonInfo(query, addonInfo)
    local info = self:GetAddonInfoOrNil(query, addonInfo)
    if not info then
        error("You cannot get a unexists addon's info by " .. query)
    end

    return info
end

-- 根据插件名获取插件信息，可能为nil
-- @param update:是否先刷新，再获取
function Addon:GetAddonInfoByNameOrNil(name, update)
    local addonInfos = self:GetAddonInfos()
    local addonIndex = addonInfos[name]
    if not addonIndex then
        return
    end

    return self:GetAddonInfoByIndexOrNil(addonIndex, update)
end

-- 根据插件名获取插件信息，返回值不为nil
function Addon:GetAddonInfoByName(name, update)
    local addonInfo = self:GetAddonInfoByNameOrNil(name, update)
    if not addonInfo then
        error("You cannot get a unexists addon's info by " .. name)
    end

    return addonInfo
end

-- 根据插件index获取插件信息，可能为nil
-- @param update:是否先刷新，再获取
function Addon:GetAddonInfoByIndexOrNil(index, update)
    local addonInfos = self:GetAddonInfos()
    if update then
        self:UpdateAddonInfoByIndex(index)
    end

    return addonInfos[index]
end

-- 根据插件index获取插件信息，返回值不为nil
function Addon:GetAddonInfoByIndex(index, update)
    local addonInfo = self:GetAddonInfoByIndexOrNil(index, update)
    if not addonInfo then
        error("You cannot get a unexists addon's info by " .. index)
    end

    return addonInfo
end

-- 根据插件index更新插件信息
-- 返回对应插件信息
function Addon:UpdateAddonInfoByIndex(index)
    local addonInfos = self:GetAddonInfos()
    local addonInfo = self:GetAddonInfo(index, addonInfos[index])
    -- 按插件index存储
    addonInfos[index] = addonInfo
    -- 插件名和index映射
    addonInfos[addonInfo.Name] = index

    return addonInfo
end

-- 根据插件名更新插件信息
function Addon:UpdateAddonInfoByName(name)
    local addonInfos = self:GetAddonInfos()
    local addonIndex = addonInfos[name]

    -- 获取不到插件索引，就没有必要更新了
    if not addonIndex then
        return
    end

    return self:UpdateAddonInfoByIndex(addonIndex)
end

-- 获取插件信息
-- @param query:如果为nil，则更新所有插件信息，否则只更新指定插件信息
function Addon:UpdateAddonInfos(query)
    if query then
        if type(query) == "number" then
            self:UpdateAddonInfoByIndex(query)
        elseif type(query) == "string" then
            self:UpdateAddonInfoByName(query)
        end
    else
        for i = 1, C_AddOns.GetNumAddOns() do
            self:UpdateAddonInfoByIndex(i)
        end
    end
end

-- 获取所有插件信息
function Addon:GetAddonInfos()
    return self.AddonInfos
end

-- 查询插件信息
function Addon:QueryAddonInfo(query)
    local addonInfos = self:GetAddonInfos()
    local addonInfo
    if type(query) == "string" then
        addonInfo = addonInfos[addonInfos[query]]
    elseif type(query) == "number" then
        addonInfo = addonInfos[query]
    end
    return addonInfo
end

-- 插件是否可以按需加载
function Addon:CanAddonLoadOnDemand(query)
    local addonInfo = self:QueryAddonInfo(query)

    if not addonInfo.Enabled or not addonInfo.LoadOnDemand or addonInfo.Loaded then
        return false
    end

    for _, dep in pairs(addonInfo.Deps) do
        if dep and not C_AddOns.IsAddOnLoaded(dep) then
            return false
        end
    end

    return true
end

-- 获取需要重载的插件名
function Addon:GetAddonNamesShouldReload()
    local addonInfos = self:GetAddonInfos()
    local addonNames = {}
    for _, addonInfo in ipairs(addonInfos) do
        if self:IsAddonShouldReload(addonInfo) then
            table.insert(addonNames, addonInfo.Name)
        end
    end
    return addonNames
end

-- 插件是否需要重载
function Addon:IsAddonShouldReload(query)
    local addonInfo
    if type(query) == "string" or type(query) == "number" then
        addonInfo = self:QueryAddonInfo(query)
    elseif type(query) == "table" then
        addonInfo = query
    else
        return
    end
    -- 如果插件依赖被禁用，则其启用状态的变化就无关紧要
    return (addonInfo.Enabled ~= addonInfo.InitialEnabled or addonInfo.InitialExpired ~= addonInfo.Expired) and
               addonInfo.UnloadableReason ~= ADDON_DEP_DISABLED
end

-- 是否需要重载界面
function Addon:IsUIShouldReload()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if self:IsAddonShouldReload(addonInfo) then
            return true
        end
    end
end

-- 启用插件
local function enableAddon(addonName)
    if Addon:IsAddonEnableStatusCharacterOnly() then
        C_AddOns.EnableAddOn(addonName, UnitName("player"))
    else
        C_AddOns.EnableAddOn(addonName)
    end
end

-- 禁用插件
local function disableAddon(addonName)
    if Addon:IsAddonEnableStatusCharacterOnly() then
        C_AddOns.DisableAddOn(addonName, UnitName("player"))
    else
        C_AddOns.DisableAddOn(addonName)
    end
end

-- 重置插件列表
function Addon:ResetAddonList()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if addonInfo.InitialEnabled then
            enableAddon(addonInfo.Name)
        else
            disableAddon(addonInfo.Name)
        end
    end
    self:UpdateAddonInfos()
end

-- 启用插件
function Addon:EnableAddon(addonName)
    local addonInfo = self:GetAddonInfoByNameOrNil(addonName)
    if addonInfo and not addonInfo.IsLocked and not self:IsAddonManager(addonInfo.Name) then
        enableAddon(addonName)
    end
end

-- 启用所有插件
function Addon:EnableAllAddons()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if not addonInfo.IsLocked then
            enableAddon(addonInfo.Name)
        end
    end
    self:UpdateAddonInfos()
end

-- 禁用插件
function Addon:DisableAddon(addonName)
    local addonInfo = self:QueryAddonInfo(addonName)
    if addonInfo and not addonInfo.IsLocked and not self:IsAddonManager(addonInfo.Name) then
        disableAddon(addonInfo.Name)
    end
end

-- 刷新插件启用状态
function Addon:UpdateAddonsEnableStatus()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if addonInfo.Enabled then
            enableAddon(addonInfo.Name)
        else
            disableAddon(addonInfo.Name)
        end
    end
end

-- 禁用所有插件
function Addon:DisableAllAddons()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if self:IsAddonManager(addonInfo.Name) then
            enableAddon(addonInfo.Name)
        elseif not addonInfo.IsLocked then
            disableAddon(addonInfo.Name)
        end
    end
    self:UpdateAddonInfos()
end

-- 所有插件是否都已启用
function Addon:IsAllAddonsEnabled()
    local addonInfos = self:GetAddonInfos()

    local allEnabled, allDisabled, canReset, shouldReload
    for _, addonInfo in ipairs(addonInfos) do
        local isAddonManager = self:IsAddonManager(addonInfo.Name)
        local locked = addonInfo.IsLocked
        local enabled = addonInfo.Enabled
        local initialEnabled = addonInfo.InitialEnabled

        if allEnabled == nil and not isAddonManager and not locked and not enabled then
            allEnabled = false
        end

        if allDisabled == nil and not isAddonManager and not locked and enabled then
            allDisabled = false
        end

        if canReset == nil and initialEnabled ~= enabled then
            canReset = true
        end 

        if shouldReload == nil and self:IsAddonShouldReload(addonInfo) then
            shouldReload = true
        end

        if allEnabled ~= nil and allDisabled and canReset ~= nil and shouldReload ~= nil then
            break
        end
    end

    if allEnabled == nil then
        allEnabled = true
    end

    if allDisabled == nil then
        allDisabled = true
    end

    return allEnabled, allDisabled, canReset, shouldReload
end

-- 获取插件集列表
function Addon:GetAddonSets()
    return self.Saved.AddonSets
end

-- 返回当前的插件集，或nil
function Addon:GetActiveAddonSet()
    local guid = UnitGUID("player")
    local activeAddonSet = self.Saved.ActiveAddonSets[guid]
    if not activeAddonSet then return end
    return self:GetAddonSets()[activeAddonSet]
end

-- 返回当前的插件集名称
function Addon:GetActiveAddonSetName()
    local guid = UnitGUID("player")
    return self.Saved.ActiveAddonSets[guid]
end

-- 设置当前插件集
function Addon:SetActiveAddonSetName(addonSetName)
    if addonSetName then
        local exists = self:GetAddonSets()[addonSetName]
        if not exists then
            self:ShowError(L["addon_set_can_not_find"]:format(WrapTextInColor(addonSetName, NORMAL_FONT_COLOR)))
            return
        end
    end

    self.Saved.ActiveAddonSets[UnitGUID("player")] = addonSetName
end

-- 插件集是否完全匹配
function Addon:IsAddonSetPerfectMacth(addonSetName)
    local addonSet = self:GetAddonSetByName(addonSetName)
    if not addonSet or not addonSet.Addons then return false end

    local perfectMatch = true
    
    -- 检查是否完全匹配
    for _, addonInfo in ipairs(self:GetAddonInfos()) do
        if not self:IsAddonManager(addonInfo.Name) then
            if addonInfo.Enabled and not addonSet.Addons[addonInfo.Name] then
                perfectMatch = false
                break
            elseif not addonInfo.Enabled and addonSet.Addons[addonInfo.Name] then
                perfectMatch = false
                break
            end
        end
    end

    return perfectMatch
end

-- 应用插件集
function Addon:ApplyAddonSetAddons(addonSetName)
    local addonSet = self:GetAddonSetByName(addonSetName)
    if addonSet then
        local addonInfos = self:GetAddonInfos()
        local addonSetAddons = addonSet.Addons

        for _, addonInfo in ipairs(addonInfos) do
            local addonName = addonInfo.Name
            if not self:IsAddonManager(addonName) and not self:IsAddonLocked(addonName) then
                local shouldEnabled = addonSetAddons and addonSetAddons[addonName]
                if shouldEnabled then
                    enableAddon(addonName)
                else
                    disableAddon(addonName)
                end
            end

            self:UpdateAddonInfoByName(addonName)
        end
    end
end

-- 根据名称获取插件集
function Addon:GetAddonSetByName(name)
    return self:GetAddonSets()[name]
end

-- 新建插件集
function Addon:NewAddonSet(name)
    if type(name) ~= "string" then
        return
    end

    name = strtrim(name)
    
    if name == "" then
        return
    end
    
    if strlenutf8(name) > self.ADDON_SET_NAME_MAX_LENGTH then
        self:ShowError(L["addon_set_name_error_too_long"])
        return
    end

    local addonSets = self:GetAddonSets()

    for _, addonSet in pairs(addonSets) do
        if addonSet.Name == name then
            self:ShowError(L["addon_set_name_error_duplicate"])
            return
        end
    end

    addonSets[name] = { Name = name, Enabled = true, Addons = {} }

    return true
end

-- 删除插件集
function Addon:DeleteAddonSet(name)
    if type(name) ~= "string" or name == "" then
        return
    end

    local activeAddonSetName = self:GetActiveAddonSetName()
    if activeAddonSetName == name then
        self:SetActiveAddonSetName(nil)
    end

    self:GetAddonSets()[name] = nil
end

-- 设置插件集插件列表
function Addon:SetAddonSetAddonList(addonSetName, addonList)
    local addonSet = self:GetAddonSetByName(addonSetName)
    if not addonSet then
        return
    end

    local addons = addonSet.Addons
    wipe(addons)

    if addonList then
        for addonName, enableStatus in pairs(addonList) do
            if type(addonName) == "string" and strlen(addonName) > 0 then
                addons[addonName] = enableStatus
            end
        end
    end

    -- 插件集不保存此插件
    addons[AddonName] = nil
end

-- 合并插件列表到插件集
function Addon:MergeAddonListToAddonSet(addonSetName, addonList)
    local addonSet = self:GetAddonSetByName(addonSetName)
    if not addonSet then
        return
    end

    local addons = addonSet.Addons

    if addonList then
        for addonName, enableStatus in pairs(addonList) do
            if type(addonName) == "string" and strlen(addonName) > 0 then
                addons[addonName] = enableStatus
            end
        end
    end

    -- 插件集不保存此插件
    addons[AddonName] = nil
end