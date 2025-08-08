---@class AbstractFramework
local AF = _G.AbstractFramework

AF.L = setmetatable({

}, {
    __index = function(self, Key)
        if (Key ~= nil) then
            rawset(self, Key, Key)
            return Key
        end
    end
})

local L = AF.L

if LOCALE_zhCN then
    L["%d days"] = "%d天"
    L["%d hours"] = "%d小时"
    L["%d minutes"] = "%d分钟"
    L["%d months"] = "%d月"
    L["%d seconds"] = "%d秒"
    L["%d weeks"] = "%d周"
    L["%d years"] = "%d年"
    L["%s ago"] = "%s前"
    L["%s from now"] = "%s后"
    L["About"] = "关于"
    L["Anchor Locked"] = "锚点已锁定"
    L["Author"] = "作者"
    L["Authors"] = "作者"
    L["Close this dialog to exit Edit Mode"] = "关闭此窗口以退出编辑模式"
    L["Config"] = "设置"
    L["Export"] = "导出"
    L["Feedback & Suggestions"] = "反馈与建议"
    L["hide mover"] = "隐藏移动框"
    L["Import & Export"] = "导入 & 导出"
    L["Import"] = "导入"
    L["just now"] = "刚刚"
    L["Left Click"] = "左键单击"
    L["Left Drag"] = "左键拖动"
    L["Middle Click"] = "中键单击"
    L["Mouse Wheel"] = "鼠标滚轮"
    L["move frames horizontally"] = "水平方向移动框体"
    L["move frames vertically"] = "垂直方向移动框体"
    L["move frames"] = "移动框体"
    L["Options"] = "选项"
    L["Popups"] = "通知弹窗"
    L["Right Click the Anchor button to lock the anchor"] = "右键单击锚点按钮以锁定锚点"
    L["Right Click the popup to dismiss"] = "右键单击可以关闭弹窗"
    L["Right Click"] = "右键单击"
    L["Right Drag"] = "右键拖动"
    L["Tips"] = "提示"
    L["toggle Position Adjustment dialog"] = "打开/关闭微调窗口"
    L["Translator"] = "翻译"
    L["Translators"] = "翻译"
    L["Undo"] = "撤消"
    L["Version"] = "版本"
end