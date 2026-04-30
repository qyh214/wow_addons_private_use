-- =============================================================
-- ExwindExport.lua - 配置导入导出核心引擎
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

local LibSerialize = LibStub and LibStub("LibSerialize")
local LibDeflate = LibStub and LibStub("LibDeflate")

local Export = {}
ExwindTools.Export = Export

-- 常量定义
local FORMAT_VERSION = 1
local MAGIC_PREFIX = "!EX1!" -- 导出字符串前缀标识

-- =============================================================
-- 导出功能
-- =============================================================

--- 获取可导出的模块列表
function Export:GetExportableModules()
    local modules = {}
    local moduleList = ExwindTools.ModuleList or {}

    for _, meta in ipairs(moduleList) do
        local db = ExwindTools.DB and ExwindTools.DB.ModuleDB and ExwindTools.DB.ModuleDB[meta.Key]
        if db and next(db) then
            table.insert(modules, {
                key = meta.Key,
                name = meta.Name or meta.Key,
                desc = meta.Desc or "",
                category = meta.Category or 1,
                hasData = true,
            })
        end
    end
    return modules
end

--- 获取玩家标识符
function Export:GetPlayerIdentifier()
    local name = UnitName("player") or "Unknown"
    local realm = GetRealmName() or "UnknownRealm"
    return name .. "-" .. realm
end

--- 导出选定模块的配置
-- @param selectedModules table 选中的模块 Key 集合 { ["ExTools.MiniTools"] = true }
-- @param profileName string 配置名称
-- @param authorName string|nil 自定义导出者名称 (nil 则使用玩家名)
-- @param note string|nil 导出备注说明
-- @return string 编码后的导出字符串
-- @return string|nil 错误信息
function Export:ExportModules(selectedModules, profileName, authorName, note)
    if not LibSerialize or not LibDeflate then
        return nil, "缺少必要的库: LibSerialize 或 LibDeflate"
    end

    -- 确定导出者名称
    local finalAuthor = authorName and authorName ~= "" and authorName or self:GetPlayerIdentifier()

    local exportData = {
        meta = {
            formatVersion = FORMAT_VERSION,
            profileName = profileName or "未命名配置",
            author = finalAuthor,
            note = note or "",
            exportTime = time(),
            exportTimeStr = date("%Y-%m-%d %H:%M"),
            addonVersion = ExwindTools.VERSION or "Unknown",
            moduleCount = 0,
            enabledModules = {},
        },
        modules = {},
    }

    local count = 0
    for moduleKey, isSelected in pairs(selectedModules) do
        if isSelected then
            local db = ExwindTools.DB and ExwindTools.DB.ModuleDB and ExwindTools.DB.ModuleDB[moduleKey]
            if db then
                exportData.modules[moduleKey] = self:DeepCopy(db)
                -- 同时记录该模块的启用状态
                local enabled = ExwindTools.DB.LoadByKey and ExwindTools.DB.LoadByKey[moduleKey]
                exportData.meta.enabledModules[moduleKey] = (enabled == true)
                count = count + 1
            end
        end
    end
    exportData.meta.moduleCount = count

    if count == 0 then
        return nil, "未选择任何模块或选中的模块没有保存数据"
    end

    -- 序列化 → 压缩 → 编码
    local ok, serialized = pcall(function()
        return LibSerialize:Serialize(exportData)
    end)
    if not ok then
        return nil, "序列化失败: " .. tostring(serialized)
    end

    local compressed = LibDeflate:CompressDeflate(serialized)
    if not compressed then
        return nil, "压缩失败"
    end

    local encoded = LibDeflate:EncodeForPrint(compressed)
    if not encoded then
        return nil, "编码失败"
    end

    return MAGIC_PREFIX .. encoded, nil
end

-- =============================================================
-- 导入功能
-- =============================================================

--- 预解析导入字符串 (仅解析元数据，不应用)
-- @param importString string 导入字符串
-- @return table|nil 解析结果
-- @return string|nil 错误信息
function Export:ParseImportString(importString)
    if not importString or importString == "" then
        return nil, "导入字符串为空"
    end

    if not LibSerialize or not LibDeflate then
        return nil, "缺少必要的库: LibSerialize 或 LibDeflate"
    end

    -- 去除首尾空白
    importString = importString:match("^%s*(.-)%s*$")

    -- 检查前缀
    if not importString:find("^" .. MAGIC_PREFIX:gsub("!", "%%!")) then
        return nil, "无效的导入字符串格式 (缺少 !EX1! 前缀)"
    end

    local encoded = importString:sub(#MAGIC_PREFIX + 1)
    if encoded == "" then
        return nil, "导入字符串内容为空"
    end

    -- 解码 → 解压 → 反序列化
    local decoded = LibDeflate:DecodeForPrint(encoded)
    if not decoded then
        return nil, "字符串解码失败 (可能已损坏)"
    end

    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then
        return nil, "数据解压失败 (可能已损坏)"
    end

    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then
        return nil, "数据反序列化失败: " .. tostring(data)
    end

    -- 验证数据结构
    if type(data) ~= "table" then
        return nil, "数据结构无效 (不是表)"
    end
    if not data.meta then
        return nil, "数据结构无效 (缺少元数据)"
    end
    if not data.modules then
        return nil, "数据结构无效 (缺少模块数据)"
    end

    return data, nil
end

--- 获取导入摘要 (用于预览)
function Export:GetImportSummary(data)
    local summary = {
        profileName = data.meta.profileName or "未命名",
        author = data.meta.author or "未知",
        note = data.meta.note or "",
        exportTime = data.meta.exportTimeStr or "未知时间",
        addonVersion = data.meta.addonVersion or "未知版本",
        formatVersion = data.meta.formatVersion or 1,
        moduleCount = data.meta.moduleCount or 0,
        modules = {},
    }

    for moduleKey, _ in pairs(data.modules) do
        local meta = self:GetModuleMeta(moduleKey)
        table.insert(summary.modules, {
            key = moduleKey,
            name = meta and meta.Name or moduleKey,
            exists = meta ~= nil,
        })
    end

    -- 按名称排序
    table.sort(summary.modules, function(a, b)
        return a.name < b.name
    end)

    return summary
end

--- 应用导入的配置
-- @param data table 解析后的导入数据
-- @param selectedModules table 选中导入的模块 { ["ExTools.MiniTools"] = true }
-- @param mergeMode string "replace" 或 "merge"
-- @return number 成功导入的模块数量
function Export:ApplyImport(data, selectedModules, mergeMode)
    mergeMode = mergeMode or "replace"

    if not ExwindTools.DB or not ExwindTools.DB.ModuleDB then
        return 0, "数据库未初始化"
    end

    local applied = 0
    local targetDB = ExwindTools.DB.ModuleDB

    for moduleKey, isSelected in pairs(selectedModules) do
        if isSelected and data.modules[moduleKey] then
            if mergeMode == "replace" then
                targetDB[moduleKey] = self:DeepCopy(data.modules[moduleKey])
            else
                targetDB[moduleKey] = targetDB[moduleKey] or {}
                self:DeepMerge(targetDB[moduleKey], data.modules[moduleKey])
            end
            -- 同步模块启用状态（仅当导出数据中包含时）
            if data.meta and data.meta.enabledModules and data.meta.enabledModules[moduleKey] ~= nil then
                ExwindTools.DB.LoadByKey[moduleKey] = data.meta.enabledModules[moduleKey]
            end
            applied = applied + 1
        end
    end

    return applied
end

-- =============================================================
-- 工具函数
-- =============================================================

function Export:DeepCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for k, v in pairs(orig) do
            copy[self:DeepCopy(k)] = self:DeepCopy(v)
        end
        -- 不复制 metatable，避免带入函数
    else
        copy = orig
    end
    return copy
end

function Export:DeepMerge(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            self:DeepMerge(target[k], v)
        else
            target[k] = self:DeepCopy(v)
        end
    end
end

function Export:GetModuleMeta(moduleKey)
    local moduleList = ExwindTools.ModuleList or {}
    for _, meta in ipairs(moduleList) do
        if meta.Key == moduleKey then
            return meta
        end
    end
    return nil
end

-- =============================================================
-- 导入成功弹窗
-- =============================================================
StaticPopupDialogs["EXWIND_IMPORT_SUCCESS"] = {
    text = "导入成功！已导入 %d 个模块的配置。\n\n配置需要重载界面才能完全生效。",
    button1 = "立即重载",
    button2 = "稍后重载",
    OnAccept = function()
        C_UI.Reload()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

EXDebug("ExwindExport 核心加载完成")
