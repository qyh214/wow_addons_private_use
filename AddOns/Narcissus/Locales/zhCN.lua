if not (GetLocale() == "zhCN") then
    return
end

local L = Narci.L

L["Movement Speed"] = STAT_MOVEMENT_SPEED;
L["Damage Reduction Percentage"] = COMBAT_TEXT_SHOW_RESISTANCES_TEXT;

L["Advanced Info"] = "点击以显示更详细的装备、属性信息";

L["Photo Mode"] = "照片模式";
L["Photo Mode Tooltip Open"] = "点击以打开截图工具箱";
L["Photo Mode Tooltip Close"] = "点击以关闭截图工具箱";
L["Photo Mode Tooltip Special"] = "此控件不会出现在你(魔兽安装目录Screenshots文件夹内)的游戏截图里";

L["Xmog Button"] = "分享幻化";
L["Xmog Button Tooltip Open"] = "点击以显示幻化的名称及来源，而非装备栏内的实际物品";
L["Xmog Button Tooltip Close"] = "点击以显示装备栏内的实际物品";
L["Xmog Button Tooltip Special"] = "您可以尝试不同的布局，或是为当前的外观起一个名字";

L["Xmog Button Layout"] = "布局";
L["Xmog Button Copy Texts"] = "导出文本";

L["Emote Button"] = "快捷表情";
L["Emote Button Tooltip Open"] = "播放具有独特动画效果的表情";

L["HideTexts Button"] = "隐藏文本";
L["HideTexts Button Tooltip Open"] = "点击以隐藏所有单位的姓名、聊天气泡和战斗文字";
L["HideTexts Button Tooltip Close"] = "点击以恢复姓名、聊天气泡和战斗文字的设置";
L["HideTexts Button Tooltip Special"] = "您先前的设置将会在你退出照片模式后自动恢复";

L["TopQuality Button"] = "最佳画质";
L["TopQuality Button Tooltip Open"] = "点击以将画面设置中的所有选项都调至极佳";
L["TopQuality Button Tooltip Close"] = "点击以恢复先前的画质设置";

L["Heritage Armor"] = "传承护甲";
ITEMSOURCE_SECRETFINDING = "解密活动"

HEART_QUOTE_1 = "最本质的东西，是无法用肉眼看见的";

NARCI_TITLE_MANAGER_OPEN = "展开头衔列表";
NARCI_TITLE_MANAGER_CLOSE = "收起头衔列表";

NARCI_ALIAS_USE_ALIAS = "使用化名";
NARCI_ALIAS_USE_PLAYER_NAME = "使用本名";

L["Minimap Tooltip Double Click"] = "双击";
L["Minimap Tooltip Left Click"] = "左键|r";
L["Minimap Tooltip To Open"] = "|cffffffff打开主界面";
L["Minimap Tooltip Right Click"] = "右键";
L["Minimap Tooltip Shift Right Click"] = "Shift + 右键";
L["Minimap Tooltip Hide Button"] = "|cffffffff隐藏此按钮|r"
L["Minimap Tooltip Middle Button"] = "|CFFFF1000中键 |cffffffff重置相机参数";
L["Minimap Tooltip Set Scale"] = "设置缩放: |cffffffff/narci [有效范围 0.8~1.2]";

NARCI_CLIPBOARD = "剪切板";
NARCI_LAYOUT = "布局";
NARCI_LAYOUT_SYMMETRY = "对称";
NARCI_LAYOUT_ASYMMETRY = "非对称";
NARCI_COPY_TEXTS = "复制文本";
NARCI_SYNTAX = "语法";
NARCI_SYNTAX_PLAIN_TEXT = "纯文本";
NARCI_SYNTAX_BBCODE = "BB Code";
NARCI_SYNTAX_MARKDOWN = "Markdown";
NARCI_EXPORT_INCLUDES = "在导出中包含...";
NARCI_ITEM_ID = "物品ID";

NARCI_3DMODEL = "3D模型";
NARCI_EQUIPMENTSLOTS = "装备栏位";

--偏好设定--
NARCI_INTERFACE = "界面";
NARCI_THEME = "主题";
NARCI_EFFECTS = "效果";
NARCI_TRANSMOG = "幻化";
NARCI_TRUNCATE_TEXT = "截断文字";
NARCI_TEXT_WIDTH = "文本宽度";
NARCI_HOTKEY = "快捷键";
NARCI_DOUBLE_TAP = "双击";
NARCI_DOUBLE_TAP_DESCRIPTION = "连按两下打开角色面板的快捷键来打开此插件。"
NARCI_OVERRIDE = "是否覆盖";
NARCI_INVALID_KEY = "无效的组合键";
NARCI_MINIMAP_BUTTON = "小地图按钮";
NARCI_SHORTCUTS = "快捷方式";
NARCI_FILTERS = "滤镜";
NARCI_FILTERS_DESCRIPTION = "除暗角以外的所有滤镜都会在幻化模式被暂时禁用。";
NARCI_GRAIN_EFFECT = "颗粒效果";
NARCI_PREFERENCE = "偏好设定-PH";
NARCI_CAMERA_MOVEMENT = "镜头运动";
NARCI_CAMERA_ORBIT = "环绕镜头";
NARCI_CAMERA_ORBIT_ENABLED_DESCRIPTION = "当你打开此插件时，镜头会自动旋转到角色面前并开始环绕。";
NARCI_CAMERA_ORBIT_DISABLED_DESCRIPTION = "当你打开此插件时，镜头只会被拉近不会有任何旋转。";
NARCI_FADEOUT = "淡化图标";
NARCI_FADEOUT_DESCRIPTION = "在你将鼠标从小地图按钮上移出后，它的透明度会自动降低。";
NARCI_FADE_MUSIC = "淡入/淡出音乐";
NARCI_VIGNETTE_STRENGTH = "暗角强度";
NARCI_WEATHER_EFFECT = "天气效果";
NARCI_DEFAULT_LAYOUT = "默认布局";
NARCI_LAYOUT_1 = "对称，显示人物";
NARCI_LAYOUT_2 = "人物及模型";
NARCI_LAYOUT_3 = "紧凑模式";
NARCI_BORDER_THEME = "边框主题";
NARCI_BORDER_THEME_BRIGHT = "明亮";
NARCI_BORDER_THEME_DARK = "灰暗";
NARCI_ALWAYS_SHOW_MODEL = "总是显示3D模型";
NARCI_SHOW_FULL_BODY = "显示全身";
--模型控制面板--
NARCI_SHEATH_WEAPON = "收起武器";
NARCI_STAND_IDLY = "普通站姿";
NARCI_RANGED_WEAPON = "远程武器";
NARCI_MELEE_WEAPON = "近战武器";
NARCI_SPELLCASTING = "施法动作";
NARCI_ANIMATION_ID = "动画ID";
NARCI_GROUND_SHADOW = "模拟地面阴影";
NARCI_HIDE_PLAYER = "隐藏玩家自身";