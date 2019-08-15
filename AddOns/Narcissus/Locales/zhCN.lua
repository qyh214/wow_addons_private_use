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
L["Minimap Tooltip To Open"] = "|cffffffff打开装备界面";
L["Minimap Tooltip Enter Photo Mode"] = "|cffffffff进入拍照模式";
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
NARCI_CAMERA = "镜头";
NARCI_EFFECTS = "效果";
NARCI_TRANSMOG = "幻化";
NARCI_EXTENSIONS = "拓展功能";
NARCI_ABOUT = "关于"
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
NARCI_CAMERA_SAFE_MODE = "镜头安全模式";
NARCI_CAMERA_SAFE_MODE_DESCRIPTION = "在关闭此插件后彻底关闭ActionCam功能。";
NARCI_CAMERA_SAFE_MODE_DESCRIPTION_EXTRA = "已禁用因为你正在使用DynamicCam插件。";
NARCI_FADEOUT = "淡化图标";
NARCI_FADEOUT_DESCRIPTION = "在你将鼠标从小地图按钮上移出后，它的透明度会自动降低。";
NARCI_FADE_MUSIC = "淡入/淡出音乐";
NARCI_VIGNETTE_STRENGTH = "暗角强度";
NARCI_WEATHER_EFFECT = "天气效果";
NARCI_LETTERBOX_EFFECT = "宽荧幕效果";
NARCI_LETTERBOX_RATIO = "宽高比";
NARCI_LETTERBOX_EFFECT_ALERT1 = "你屏幕的宽高比超过了所选比例。";
NARCI_LETTERBOX_EFFECT_ALERT2 = "建议将UI缩放比设置为%0.1f\n(当前缩放比为%0.1f)";
NARCI_DEFAULT_LAYOUT = "默认布局";
NARCI_LAYOUT_1 = "对称，显示人物";
NARCI_LAYOUT_2 = "人物及模型";
NARCI_LAYOUT_3 = "紧凑模式";
NARCI_BORDER_THEME = "边框主题";
NARCI_BORDER_THEME_BRIGHT = "明亮";
NARCI_BORDER_THEME_DARK = "灰暗";
NARCI_ALWAYS_SHOW_MODEL = "总是显示3D模型";
NARCI_SHOW_FULL_BODY = "显示全身";
NARCI_AFK_SCREEN = "AFK画面";
NARCI_AFK_SCREEN_DESCRIPTION = "在你的人物暂离后自动打开Narcissus。";
NARCI_AFK_SCREEN_DESCRIPTION_EXTRA = "勾选此选项将覆盖ElvUI的AFK模式。";
NARCI_GEMMA = "\"Gemma\"";
NARCI_GEMMY_DESCRIPTION = "在你为一件物品镶嵌宝石时，显示可用的宝石列表。"
NARCI_DRESSING_ROOM = "试衣间"
NARCI_DRESSING_ROOM_DESCRIPTION = "增大试衣间窗口大小，并使你能够通过试衣间浏览、复制其他玩家的幻化调料包。";
NARCI_REQUIRE_RELOAD = "需要重载UI才能使设置生效。";

--模型控制面板--
NARCI_SHEATH_WEAPON = "收起武器";
NARCI_STAND_IDLY = "普通站姿";
NARCI_RANGED_WEAPON = "远程武器";
NARCI_MELEE_WEAPON = "近战武器";
NARCI_SPELLCASTING = "施法动作";
NARCI_ANIMATION_ID = "动画ID";
NARCI_GROUND_SHADOW = "模拟地面阴影";
NARCI_HIDE_PLAYER = "隐藏玩家自身";
NARCI_LINK_LIGHT_SETTINGS = "关联灯光设置";
NARCI_LINK_MODEL_SCALE = "关联模型比例";
NARCI_GROUP_PHOTO = "合影模式";
NARCI_GROUP_PHOTO_AVAILABLE = "现已加入Narcissus插件";
NARCI_GROUP_PHOTO_NOTIFICATION = "请选择一名玩家作为目标。";
NARCI_GROUP_PHOTO_INDEX = "序号";
NARCI_GROUP_PHOTO_FRONT = "|cff40c7eb顶层|r";
NARCI_GROUP_PHOTO_STATUS_HIDDEN = "隐藏";
--装备对比--
NARCI_AZERITE_POWERS = "艾泽里特之力";

--Tutorial--
NARCI_TUTORIAL_CAPTUREBUTTON = "点击此按钮后会自动保存5张图层：\n仅背景、带蓝\\绿幕的3D模型、装备栏的alpha\\颜色通道。\n\n如果想只保存一张截图，请按键盘上的截图快捷键。";
NARCI_TUTORIAL_ANIMATION_ID = "左键单击 ID +1  右键单击 ID -1\n动画ID的有效范围为 0~1472。";
NARCI_TUTORIAL_GREEN_SCREEN = "点击最左端的正方形按钮可以显示蓝\\绿幕。";

--Splash--
NARCI_PATCH_NOTES = "v1.0.6 Patch Notes";
NARCI_SPLASH_CLOSE_AND_CONTINUE = "关闭此窗口并继续";
NARCI_SPLASH_SOUNDS_GREAT_BYE = "听上去不错。一会儿见！";
NARCI_TRY_IT_NOW = "点击这里以启用...";
NARCI_DISABLE_IT_NOW = "点击这里以禁用...";
    --Patch-specific
    NARCI_DRESSING_ROOM_ENABLED_BY_DEFAULT = "|cff7cc576已默认开启。|r "..NARCI_DISABLE_IT_NOW;
    NARCI_DRESSING_ROOM_DISABLED = "|cffff5050已禁用。|r 需要重载UI才能使设置生效。 你可以在偏好设定-拓展功能中重新启用它。";
    NARCI_CAMERA_SAFE_MODE_ENABLED_BY_DEFAULT = "|cff7cc576已默认开启，因为你没有在使用DynamicCam插件。|r\n"..NARCI_DISABLE_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_DISABLED_BY_DEFAULT = "|cffff5050已默认关闭，因为你正在使用DynamicCam插件。|r\n"..NARCI_TRY_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_ENABLED = "|cff7cc576已启用。|r 你可以在偏好设定-镜头中关闭它。";
    NARCI_CAMERA_SAFE_MODE_DISABLED = "|cffff5050已禁用。|r 你可以在偏好设定-镜头中启用它。";
    --
NARCI_SHOW_DETAILS = "+ Show details...";
NARCI_SPLASH_HEADER1 = "合影模式和模型控制";
NARCI_SPLASH_HEADER2 = "其他";
NARCI_SPLASH_MESSAGE0 = "|cff40C7EB1. 借助Narcissus来拍摄合影|r\n你可通过小地图按钮或是模型控制面板来进入这个模式。选择玩家并把他们添加进你的场景，创作独一无二的故事。"
NARCI_SPLASH_MESSAGE1 = "|cff40C7EB2. 更全面地控制模型光照|r\n你可以控制光照强度，并分别设置聚光灯和环境光的颜色。";
NARCI_SPLASH_MESSAGE2 = "|cff40C7EB2. 镜头安全模式|r\n在罕见情况下，ActionCam功能没有在退出Narcissus后正确关闭。勾选此选项可以确保在关闭此插件后ActionCam被彻底关闭。"
NARCI_SPLASH_MESSAGE3 = "|cff40C7EB1. 试衣间增强|r\n增大试衣间窗口大小，并使你能够通过试衣间浏览、复制其他玩家的幻化调料包。"


--Project Details--
NARCI_ALL_PROJECTS = "全部项目";
NARCI_PROJECT_DETAILS = "|cFFFFD100插件作者: Peterodox\n更新日期: 2019.8.13|r\n\n感谢你使用此插件！如果你遇到任何问题，或者有任何想法或建议，请在CurseForge项目主页上留言，或者在以下网站上联系我。";
NARCI_PROJECT_AAA_SUMMARY = "探索艾泽拉斯上的不同景点，并收集各种故事和照片。";
NARCI_PROJECT_NARCISSUS_SUMMARY = "沉浸式角色面板；你最好的截图助手。"