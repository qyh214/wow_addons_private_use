---@class AbstractFramework
local AF = _G.AbstractFramework

AF.L = setmetatable({
    ["AF_VERSION_REQUIRED"] = "AbstractFramework Version Mismatch\n%s requires: %s or higher\nCurrent: %s",

    ["Blizzard"] = string.gsub(_G.SLASH_TEXTTOSPEECH_BLIZZARD, "^%l", strupper),
    -- ["Shift Click"] = _G.WARDROBE_SHORTCUTS_TUTORIAL_2:match("%[(.+)%]"),
    -- ["Ctrl Click"] = _G.WARDROBE_SHORTCUTS_TUTORIAL_2:match("%[(.+)%]"):gsub("Shift", "Ctrl"),
    -- ["Alt Click"] = _G.WARDROBE_SHORTCUTS_TUTORIAL_2:match("%[(.+)%]"):gsub("Shift", "Alt"),
    ["WIP"] = "Work In Progress",

    ["TANK"] = _G["TANK"],
    ["HEALER"] = _G["HEALER"],
    ["DAMAGER"] = _G["DAMAGER"],

    ["TOPLEFT"] = "Top Left",
    ["TOPRIGHT"] = "Top Right",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOMRIGHT"] = "Bottom Right",
    ["CENTER"] = "Center",
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
    ["TOP"] = "Top",
    ["BOTTOM"] = "Bottom",

    ["Edit Mode"] = _G.HUD_EDIT_MODE_MENU,
    ["Reload UI"] = _G.RELOADUI,
    ["Reset"] = _G.RESET,

    ["Options"] = _G.GAMEMENU_OPTIONS,
    ["Settings"] = _G.SETTINGS,

    ["Home"] = _G.HOME,
    ["Next"] = _G.NEXT,
    ["Prev"] = _G.PREV,

    ["Okay"] = _G.OKAY,
    ["Cancel"] = _G.CANCEL,
    ["None"] = _G.NONE,
    ["All"] = _G.ALL,
    ["Yes"] = _G.YES,
    ["No"] = _G.NO,
    ["Apply"] = _G.APPLY,
    -- ["Got It"] = _G.HELP_TIP_BUTTON_GOT_IT,

    ["Delete"] = _G.DELETE,
    ["Rename"] = _G.BATTLE_PET_RENAME,
    ["Create"] = _G.CALENDAR_CREATE,
    ["New"] = _G.NEW,
    ["Save"] = _G.SAVE,
    ["Apply"] = _G.APPLY,
    ["Edit"] = _G.EDIT,

    ["Default"] = _G.DEFAULT,
    ["Custom"] = _G.CUSTOM,
    ["Class"] = _G.CLASS,

    ["High"] = _G.HIGH,
    ["Medium"] = _G.LOAD_MEDIUM,
    ["Low"] = _G.LOW,

    ["Current"] = _G.REFORGE_CURRENT,
    ["Total"] = _G.TOTAL,
    ["Percentage"] = _G.STATUS_TEXT_PERCENT,
    ["Progress"] = _G.PVP_PROGRESS_REWARDS_HEADER,

    ["Completed"] = _G.ACCOUNT_COMPLETED_QUEST_NOTICE_LABEL,
    ["Incomplete"] = _G.INCOMPLETE,

    ["Level"] = _G.LEVEL,
    ["Honor Level"] = _G.LFG_LIST_HONOR_LEVEL_INSTR_SHORT,
    ["Reputation"] = _G.REPUTATION,
    ["Rested"] = _G.TUTORIAL_TITLE26,

    ["Name"] = _G.NAME,
    ["Description"] = _G.QUEST_DESCRIPTION,

    ["Auto"] = _G.SELF_CAST_AUTO,

    ["Sort"] = _G.STABLE_FILTER_BUTTON_LABEL,
    ["Sort By"] = _G.STABLE_FILTER_SORT_BY_LABEL,
}, {
    __index = function(self, Key)
        if (Key ~= nil) then
            rawset(self, Key, Key)
            return Key
        end
    end
})

local L = AF.L

if L.DAMAGER == "Damage" then
    L.DAMAGER = "Damager"
end

if LOCALE_zhCN then
    L["AF_VERSION_REQUIRED"] = "AbstractFramework 版本不匹配\n%s 需要：%s 及以上\n当前：%s"

    L["Got It"] = "明白了"

    L["%d days"] = "%d天"
    L["%d hours"] = "%d小时"
    L["%d minutes"] = "%d分钟"
    L["%d months"] = "%d月"
    L["%d seconds"] = "%d秒"
    L["%d weeks"] = "%d周"
    L["%d years"] = "%d年"
    L["%s ago"] = "%s前"
    L["%s from now"] = "%s后"
    L["just now"] = "刚刚"
    L["sec"] = "秒"

    L["TOPLEFT"] = "左上"
    L["TOPRIGHT"] = "右上"
    L["BOTTOMLEFT"] = "左下"
    L["BOTTOMRIGHT"] = "右下"
    L["TOP"] = "上"
    L["BOTTOM"] = "下"
    L["LEFT"] = "左"
    L["RIGHT"] = "右"
    L["CENTER"] = "中"

    L["Up"] = "上"
    L["Down"] = "下"
    L["Left"] = "左"
    L["Right"] = "右"

    L["Arrangement"] = "排列方式"

    L["Max Displayed"] = "最大显示个数"
    L["Max Lines"] = "最大行数/列数"
    L["Displayed Per Line"] = "每行/列显示个数"
    L["Max Rows"] = "最大行数"
    L["Displayed Per Row"] = "每行显示个数"
    L["Max Columns"] = "最大列数"
    L["Displayed Per Column"] = "每列显示个数"

    L["Sort Method"] = "排序方式"
    L["Sort Direction"] = "排序方向"

    L["Time"] = "时间"
    L["Index"] = "索引"

    L["Before"] = "前"
    L["After"] = "后"

    L["Ascending"] = "升序"
    L["Descending"] = "降序"

    L["Left to Right"] = "从左到右"
    L["Right to Left"] = "从右到左"
    L["Top to Bottom"] = "从上到下"
    L["Bottom to Top"] = "从下到上"
    L["Left to Right, then Up"] = "从左到右再到上"
    L["Left to Right, then Down"] = "从左到右再到下"
    L["Right to Left, then Up"] = "从右到左再到上"
    L["Right to Left, then Down"] = "从右到左再到下"
    L["Top to Bottom, then Left"] = "从上到下再到左"
    L["Top to Bottom, then Right"] = "从上到下再到右"
    L["Bottom to Top, then Left"] = "从下到上再到左"
    L["Bottom to Top, then Right"] = "从下到上再到右"

    L["A UI reload is required\nDo it now?"] = "需要重载界面\n现在重载么？"
    L["A UI reload is required"] = "需要重载界面"

    L["Addon Default"] = "插件默认"
    L["Module"] = "模块"
    L["Modules"] = "模块"

    L["Reset all settings"] = "重置所有设置"
    L["Reset to default settings?"] = "重置为默认设置？"
    L["Confirm deletion?"] = "确认删除？"
    L["Also deletes sub-items"] = "将同时删除子项"

    L["Always Show"] = "始终显示"
    L["Always Hide"] = "始终隐藏"

    L["Anchor Locked"] = "锚点已锁定"
    L["hide mover"] = "隐藏移动框"
    L["move frames horizontally"] = "水平方向移动框体"
    L["move frames vertically"] = "垂直方向移动框体"
    L["move frames"] = "移动框体"
    L["toggle Position Adjustment dialog"] = "打开/关闭微调窗口"
    L["Close this dialog to exit Edit Mode"] = "关闭此窗口以退出编辑模式"
    L["Right Click the Anchor button to lock the anchor"] = "右键单击锚点按钮以锁定锚点"

    L["Remaining"] = "剩余"

    L["Accent Color"] = "强调色"
    L["Solid"] = "纯色"
    L["Gradient"] = "渐变"

    L["Buff"] = "增益"
    L["Buffs"] = "增益"
    L["Debuff"] = "减益"
    L["Debuffs"] = "减益"
    L["Private Auras"] = "个人光环"

    L["Dead"] = "死亡"
    L["DEAD"] = "死亡"
    L["Ghost"] = "鬼魂"
    L["GHOST"] = "鬼魂"
    L["Offline"] = "离线"
    L["OFFLINE"] = "离线"
    L["AFK"] = "暂离"

    L["Curse"] = "诅咒"
    L["Disease"] = "疾病"
    L["Magic"] = "魔法"
    L["Poison"] = "中毒"
    L["Bleed"] = "流血"

    L["About"] = "关于"
    L["Author"] = "作者"
    L["Authors"] = "作者"
    L["General"] = "常规"
    L["Config"] = "设置"
    L["Configs"] = "设置"
    L["Feedback & Suggestions"] = "反馈与建议"
    L["Option"] = "选项"
    L["Setting"] = "设置"
    L["Profile"] = "配置"
    L["Profiles"] = "配置"
    L["Tip"] = "提示"
    L["Tips"] = "提示"
    L["Link"] = "链接"
    L["Links"] = "链接"
    L["Translators"] = "翻译者"
    L["Contributors"] = "贡献者"
    L["Changelog"] = "更新日志"
    L["Changelogs"] = "更新日志"
    L["Undo"] = "撤消"
    L["Version"] = "版本"
    L["WIP"] = "正在开发中"
    L["Button"] = "按钮"

    L["Enable"] = "启用"
    L["Enabled"] = "启用"
    L["Disable"] = "禁用"
    L["Disabled"] = "禁用"
    L["Copy"] = "复制"
    L["Paste"] = "粘贴"
    L["Color"] = "颜色"
    L["Colors"] = "颜色"
    L["Size"] = "尺寸"
    L["Length"] = "长度"
    L["Thickness"] = "粗细"
    L["Spacing"] = "间距"
    L["X Spacing"] = "X 间距"
    L["Y Spacing"] = "Y 间距"
    L["Offset"] = "偏移"
    L["X Offset"] = "X 偏移"
    L["Y Offset"] = "Y 偏移"
    L["Position"] = "位置"
    L["Anchor Point"] = "锚点"
    L["Relative Point"] = "相对锚点"
    L["Relative To"] = "相对于"
    L["Width"] = "宽度"
    L["Height"] = "高度"
    L["Margin"] = "外边距"
    L["Padding"] = "内边距"
    L["Scale"] = "缩放"
    L["Alpha"] = "透明度"
    L["Outline"] = "轮廓"
    L["Thick Outline"] = "粗轮廓"
    L["Monochrome"] = "单色"
    L["Mono Outline"] = "单色轮廓"
    L["Mono Thick"] = "单色粗轮廓"
    L["Shadow"] = "阴影"
    L["Font"] = "字体"
    L["Fonts"] = "字体"
    L["Font Size"] = "字体大小"
    L["Orientation"] = "方向"
    L["Horizontal"] = "水平"
    L["Vertical"] = "垂直"
    L["Frame Level"] = "框体层级"
    L["Frame Strata"] = "框体层级类型"
    L["Style"] = "样式"
    L["Parent"] = "父级"
    L["Background Color"] = "背景颜色"
    L["Border Color"] = "边框颜色"
    L["Text Color"] = "文本颜色"
    L["Texture"] = "材质"

    L["Icon"] = "图标"
    L["Icons"] = "图标"
    L["Text"] = "文本"
    L["Texts"] = "文本"

    L["Popups"] = "通知弹窗"
    L["Right Click the popup to dismiss"] = "右键单击可以关闭弹窗"

    L["Export"] = "导出"
    L["Import"] = "导入"
    L["Import & Export"] = "导入 & 导出"
    L["From"] = "从"
    L["To"] = "到"

    L["Left Click"] = "左键单击"
    L["Left Drag"] = "左键拖动"
    L["Middle Click"] = "中键单击"
    L["Right Click"] = "右键单击"
    L["Right Drag"] = "右键拖动"
    L["Mouse Wheel"] = "鼠标滚轮"
    L["Mouse wheel click"] = "鼠标滚轮按下"
    L["Shift Click"] = "按住Shift点击"
    L["Ctrl Click"] = "按住Ctrl点击"
    L["Alt Click"] = "按住Alt点击"

    L["Left-click: "] = "左键单击："
    L["Left-drag: "] = "左键拖动："
    L["Middle-click: "] = "中键单击："
    L["Right-click: "] = "右键单击："
    L["Right-drag: "] = "右键拖动："
    L["Mouse wheel: "] = "鼠标滚轮："
    L["Mouse wheel click: "] = "鼠标滚轮按下："

    L["Slash Commands"] = "斜杠命令"
    L["New version (%s) available!"] = "发现新版本（%s）！"
    L["New version (%s) available! Please visit %s to get the latest version."] = "发现新版本（%s）！请访问 %s 下载最新版本。"
end

L["WIP_WITH_ICON"] = "|TInterface\\AddOns\\AbstractFramework\\Media\\Icons\\Fluent_Tools:16|t |cffffd300" .. L["WIP"] .. "|r"