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

--Splash--
NARCI_PATCH_NOTES = "v1.0.4b 补丁说明";
NARCI_SPLASH_CLOSE_AND_CONTINUE = "关闭此窗口并继续"
NARCI_SHOW_DETAILS = "+ 显示详细内容..."
NARCI_SPLASH_HEADER1 = "镜头";
NARCI_SPLASH_HEADER2 = "装备栏";
NARCI_SPLASH_MESSAGE0 = "|cff40C7EB本次更新修复了以下两个严重问题:|r\n\n1. 当角色为特定种族时无法打开插件。 |cFF959595(光铸德莱尼, 玛格汉兽人, 黑铁矮人, 狼人, 熊猫人)|r\n\n2. 当装备了某些物品时，进入分享幻化模式会报错。"
NARCI_SPLASH_MESSAGE1 = "|cff40C7EB1. 一个因使用以往版本 (1.0.0, 1.0.1, 1.0.2, 1.0.3) 而导致的镜头问题已得到解决。|r";
NARCI_SPLASH_MESSAGE1_CONDITIONAL_LINE = "你已经关闭了镜头跟随功能，因此你将不会感受到任何变化。"
NARCI_SPLASH_MESSAGE1_EXTRA_LINE = "在早期版本中，Narcissus将 |cffffffffcameraSmoothTimeMin|r 这个CVar的值由默认的0.1修改为0.8，以保证镜头能在退出插件后平稳地切换回原先位置。但是这一改变会导致一个问题——当你的镜头只转动了较小的角度，它将需要花费比原先更长的时间来调整到与你人物朝向一致的方向。在本次更新后，此插件所用到的所有镜头相关的CVar都将属于Actioncam这一类别之下，并且它们可以通过输入|cffffffff/console actioncam off|r来彻底关闭。";
NARCI_SPLASH_MESSAGE2 = "2. 如果你在移动或骑乘期间打开此插件，镜头将不再自动旋转到角色正面。"
NARCI_SPLASH_MESSAGE3 = "3. 如果你打开了镜头跟随功能，你的镜头距离将在退出插件后自动恢复。"
NARCI_SPLASH_MESSAGE4 = "|cff40C7EB1. 你又可以右键单击装备栏来使用物品了。装备栏将在你进入战斗后立即隐藏。|r"
NARCI_SPLASH_MESSAGE5 = "2. 你可以使用Alt+左键来快速卸下某件装备。这一操作在早期版本中就已加入，现在它有了一个视觉反馈。"