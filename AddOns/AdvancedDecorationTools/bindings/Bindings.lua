-- Bindings.lua
-- 为 ADT 注册按键绑定对应的全局函数

local ADDON_NAME, ADT = ...

-- 绑定头与名称（用于按键设置界面显示）
-- 注意：这些全局常量是暴雪的约定命名，必须是全局。
BINDING_HEADER_ADT = "AdvancedDecorationTools"
BINDING_NAME_ADT_TOGGLE_HISTORY = "打开/关闭：最近放置（Dock 分类）"
-- 临时板专用按键
BINDING_NAME_ADT_TEMP_STORE = "临时板：存入并移除（Ctrl+S）"
BINDING_NAME_ADT_TEMP_RECALL = "临时板：取出并放置（Ctrl+R）"
-- 旋转快捷键（建议在按键设置里绑定到 Q/E）
BINDING_NAME_ADT_ROTATE_CCW_90 = "旋转 -90°（逆时针）"
BINDING_NAME_ADT_ROTATE_CW_90  = "旋转 +90°（顺时针）"

-- 高级编辑（虚拟多选）相关绑定名称
BINDING_NAME_ADT_ADV_TOGGLE = "切换：虚拟多选开关（录制并批量同步）"
BINDING_NAME_ADT_ADV_TOGGLE_HOVER = "选集：将悬停装饰加入/移出选集"
BINDING_NAME_ADT_ADV_CLEAR = "选集：清空"
BINDING_NAME_ADT_ADV_ANCHOR_HOVER = "锚点：设为悬停装饰"
BINDING_NAME_ADT_ADV_ANCHOR_SELECTED = "锚点：设为当前选中"

-- 额外剪切板
-- 旧剪切板相关绑定名已移除

-- 历史面板切换
function ADT_ToggleHistory()
    local Main = ADT and ADT.CommandDock and ADT.CommandDock.SettingsPanel
    if not Main then return end
    -- 若当前已显示且正处于“最近放置”分类，则收起；否则打开并切到该分类
    if Main:IsShown() and Main.currentDecorCategory == 'History' then
        Main:Hide(); return
    end
    local mode = (HouseEditorFrame and HouseEditorFrame:IsShown()) and "editor" or "standalone"
    Main:ShowUI(mode)
    if Main.ShowDecorListCategory then Main:ShowDecorListCategory('History') end
end

-- 原“复制/粘贴/剪切”快捷键已废弃，避免多套逻辑并存。

-- ===== 高级编辑：虚拟多选 =====
local function AdvLoaded()
    return ADT and ADT.AdvancedEdit
end

function ADT_Adv_Toggle()
    if not AdvLoaded() then print("ADT: 高级编辑模块未加载") return end
    ADT.AdvancedEdit:ToggleEnabled()
end

function ADT_Adv_ToggleHovered()
    if not AdvLoaded() then print("ADT: 高级编辑模块未加载") return end
    ADT.AdvancedEdit:ToggleHovered()
end

function ADT_Adv_ClearSelection()
    if not AdvLoaded() then print("ADT: 高级编辑模块未加载") return end
    ADT.AdvancedEdit:ClearSelection()
    print("ADT: 选集已清空")
end

function ADT_Adv_SetAnchor_Hovered()
    if not AdvLoaded() then print("ADT: 高级编辑模块未加载") return end
    ADT.AdvancedEdit:SetAnchorByHovered()
end

function ADT_Adv_SetAnchor_Selected()
    if not AdvLoaded() then print("ADT: 高级编辑模块未加载") return end
    ADT.AdvancedEdit:SetAnchorBySelected()
end

-- ===== 临时板：仅保留两项快捷键 =====
local function TempLoaded()
    return ADT and ADT.Clipboard
end

function ADT_Temp_StoreSelected()
    if not TempLoaded() then print("ADT: 临时板模块未加载") return end
    ADT.Clipboard:StoreSelectedAndRemove()
end

function ADT_Temp_RecallTop()
    if not TempLoaded() then print("ADT: 临时板模块未加载") return end
    ADT.Clipboard:RecallTopStartPlacing()
end

-- ===== 基本模式：旋转90°（基于 AutoRotate 的步进映射） =====
local function RotateLoaded()
    return ADT and ADT.RotateHotkey and ADT.RotateHotkey.RotateSelectedByDegrees
end

function ADT_Rotate_CCW_90()
    if not RotateLoaded() then print("ADT: 旋转模块未加载") return end
    ADT.RotateHotkey:RotateSelectedByDegrees(-90)
end

function ADT_Rotate_CW_90()
    if not RotateLoaded() then print("ADT: 旋转模块未加载") return end
    ADT.RotateHotkey:RotateSelectedByDegrees(90)
end
