-- =============================================================
-- [[ ExwindTools 核心组件：队友专精系统 (PartySpec) ]]
-- 当前实现改为复用 PartySync：
-- 1. 继续保留旧接口，避免上层模块改动
-- 2. 不再依赖 LibSpecialization，规避副本中的插件通信限制
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

local PartySync = ExwindTools.PartySync
local PartySpec = {}
ExwindTools.PartySpec = PartySpec

function PartySpec:GetSpec(unit)
    if not PartySync then return 0 end
    return PartySync:GetSpec(unit)
end

function PartySpec:GetCache()
    if not PartySync then return {} end
    return PartySync:GetCache()
end

function PartySpec:Debug()
    if PartySync and PartySync.Debug then
        PartySync:Debug()
        return
    end
    print("|cffff0000[ExwindTools PartySpec]|r PartySync 未初始化。")
end
