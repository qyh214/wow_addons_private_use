if not (GetLocale() == "zhCN") then
    return
end

local L = Narci.L

NARCI_MODIFIER_ALT = "ALT键";   --Windows
if IsMacClient() then
    NARCI_MODIFIER_ALT = "Option键";  --Mac OS
end

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
L["Auto Capture"] = "自动截图";

L["HideTexts Button"] = "隐藏文本";
L["HideTexts Button Tooltip Open"] = "隐藏所有姓名、聊天气泡和战斗文字";
L["HideTexts Button Tooltip Close"] = "恢复姓名、聊天气泡和战斗文字的设置";
L["HideTexts Button Tooltip Special"] = "您先前的设置将会在你退出照片模式后自动恢复";

L["TopQuality Button"] = "最佳画质";
L["TopQuality Button Tooltip Open"] = "将画面设置中的所有选项都调至极佳";
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
L["Minimap Tooltip Shift Left Click"] = "Shift + 左键";
L["Minimap Tooltip Shift Right Click"] = "Shift + 右键";
L["Minimap Tooltip Hide Button"] = "|cffffffff隐藏此按钮|r"
L["Minimap Tooltip Middle Button"] = "|CFFFF1000中键 |cffffffff重置相机参数";
L["Minimap Tooltip Set Scale"] = "设置缩放: |cffffffff/narci [有效范围 0.8~1.2]";
L["Corrupted Item Parser"] = "|cffffffff打开腐蚀物品链接解析器|r";
L["Toggle Dressing Room"] = "|cffffffff打开"..DRESSUP_FRAME.."|r";

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
L["Credits"] = "致谢";
NARCI_ABOUT = "关于"
NARCI_PREFERENCE_TOOLTIP = "打开偏好设定。";
NARCI_TRUNCATE_TEXT = "截断文字";
NARCI_ATTRIBUTE_FRAME = "属性栏";
NARCI_SHOW_DETAILED_STATS = "显示详细信息";
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
NARCI_AFK_SCREEN_DESCRIPTION = "在你的人物暂离后自动打开Narcissus。";
NARCI_AFK_SCREEN_DESCRIPTION_EXTRA = "勾选此选项将覆盖ElvUI的AFK模式。";
NARCI_GEMMA = "\"Gemma\"";
NARCI_GEMMY_DESCRIPTION = "在你为一件物品镶嵌宝石时，显示可用的宝石列表。"
NARCI_DRESSING_ROOM = "试衣间"
NARCI_DRESSING_ROOM_DESCRIPTION = "增大试衣间窗口大小，并使你能够通过试衣间浏览、复制其他玩家的幻化调料包。";
NARCI_REQUIRE_RELOAD = "|cffff5050需要重载UI才能使设置生效。|r";
L["Show Detailed Stats"] = "显示详尽的属性信息";
L["Tooltip Color"] = "小提示颜色";
L["Entrance Visual"] = "登场效果";
L["Entrance Visual Description"] = "在模型登场时播放法术效果。";
L["Panel Scale"] = "面板缩放";
L["Exit Confirmation"] = "退出确认";
L["Exit Confirmation Texts"] = "退出合影模式？";
L["Exit Confirmation Leave"] = "退出";
L["Exit Confirmation Cancel"] = "取消";
L["Ultra-wide"] = "超宽屏";
L["Ultra-wide Optimization"] = "超宽屏优化";
L["Baseline Offset"] = "基准线偏移";
L["Ultra-wide Tooltip"] = "你能看到此选项是因为你正在使用一台%s:9显示器。";
L["Interactive Area"] = "交互区域";
L["Item Socketing Tooltip"] = "双击左键进行镶嵌";
L["No Available Gem"] = "|cffd8d8d8没有可镶嵌的宝石|r";
L["Use Bust Shot"] = "使用半身像";
L["Use Escape Button"] = "Esc键";
L["Use Escape Button Description"] = "按下Esc键来退出插件。或者点击屏幕右上角隐藏的X按钮。";
L["Handled by Other Addons"] = "受其他插件控制";
L["AFK Screen"] = "AFK画面";
L["Keep Standing"] = "保持站立";
L["Keep Standing Description"] = "当你AFK后定时使用/站立表情。此选项不会中断自动登出。"
L["None"] = "无";
L["NPC"] = "NPC";
L["Database"] = "数据库";
L["Creature Tooltip"] = "生物信息";
L["RAM Usage"] = "内存占用";
L["Others"] = "其它";
L["Find Relatives"] = "查找相关生物";
L["Find Related Creatures Description"] = "找到与目标同姓的其他生物。";
L["Find Relatives Hotkey"] = "按Tab搜索相关生物。";
L["Find Relatives Hotkey Format"] = "按下%s开始查找。";
L["Translate Names"] = "翻译姓名";
L["Translate Names Description On"] = "获取目标译名并将其显示在...";
L["Select A Language"] = "已选语言：";
L["Select Multiple Languages"] = "已选语言：";
L["Load on Demand"] = "按需加载";
L["Load on Demand Description On"] = "在搜索功能被调用时再加载数据库。";
L["Load on Demand Description Off"] = "数据库将在你登入时加载。";
L["Load on Demand Description Disabled"] = NARCI_COLOR_YELLOW.. "这一选项被锁住了，因为你选择显示生物信息。";
L["Tooltip"] = "鼠标提示";
L["Name Plate"] = "姓名板";
L["Y Offset"] = "纵向偏移";
L["Sceenshot Quality"] = "截图质量";
L["Screenshot Quality Description"] = "更高的截图质量会增加图片体积。";

--模型控制面板--
NARCI_HOLD_WEAPON = "握住武器";
NARCI_STAND_IDLY = "普通站姿";
NARCI_RANGED_WEAPON = "远程武器";
NARCI_MELEE_WEAPON = "近战武器";
NARCI_SPELLCASTING = "施法动作";
NARCI_ANIMATION_ID = "动画ID";
NARCI_LINK_LIGHT_SETTINGS = "关联灯光设置";
NARCI_LINK_MODEL_SCALE = "关联模型比例";
NARCI_GROUP_PHOTO = "合影模式";
NARCI_GROUP_PHOTO_AVAILABLE = "现已加入Narcissus插件";
NARCI_GROUP_PHOTO_NOTIFICATION = "请选择一个目标。";
NARCI_GROUP_PHOTO_STATUS_HIDDEN = "隐藏";
NARCI_DIRECTIONAL_AMBIENT_LIGHT = "平行光/环境光";
NARCI_DIRECTIONAL_AMBIENT_LIGHT_TOOLTIP = "在以下两种灯光间切换：\n- 可以被模型遮挡并投射阴影的平行光\n- 影响整个模型表面的环境光";
L["Reset"] = "重置";
L["Actor Index"] = "序号";
L["Move To Font"] = "|cff40c7eb顶层|r";
L["Actor Index Tooltip"] = "拖动一个序号按钮来改变其模型的层级。";
L["Play Button Tooltip"] = "左键：播放此动画\n右键：恢复所有模型的动画";
L["Pause Button Tooltip"] = "左键：定格此动画\n右键：暂停所有模型的动画";
L["Save Layers"] = "保存图层";
L["Save Layers Tooltip"] = "自动截取6张截图以供后期合成使用。\n在此过程中请不要移动鼠标或点击任何按钮，否则在退出插件后你的角色可能变为不可见。如果发生这种情况，请输入以下指令：\n/console showplayer";
L["Ground Shadow"] = "模拟地面阴影";
L["Ground Shadow Tooltip"] = "为你的模型下方添加一个可调整的阴影。";
L["Hide Player"] = "隐藏玩家自身";
L["Hide Player Tooltip"] = "让你的角色变为不可见。";
L["Virtual Actor"] = "虚拟角色";
L["Virtual Actor Tooltip"] = "只有法术效果可见";
L["Self"] = "自身";
L["Target"] = "目标";
L["Compact Mode Tooltip"] = "仅用屏幕左侧来展示你的幻化。";
L["Toggle Equipment Slots"] = "显示装备栏";
L["Toggle Text Mask"] = "文字蒙版";
L["Toggle 3D Model"] = "显示3D模型";
L["Toggle Model Mask"] = "模型蒙版";
L["Show Color Sliders"] = "显示色彩滑杆";
L["Show Color Presets"] = "显示色彩预设";

--Spell Visual Browser--
L["Visuals"] = "法术效果";
L["Visual ID"] = "效果ID";
L["Animation ID Abbre"] = "动画ID";
L["Category"] = "类别";
L["Sub-category"] = "子类别";
L["My Favorites"] = "收藏夹";
L["Reset Visual Tooltip"] = "移除未应用的效果";
L["Remove Visual Tooltip"] = "左键：移除选中的效果\n长按：移除所有效果";
L["Apply"] = "应用";
L["Applied"] = "已应用";
L["Remove"] = "删除";
L["Rename"] = "重命名";
L["Refresh Model"] = "重载模型";
L["Toggle Browser"] = "效果浏览器";
L["Next And Previous"] = "左键：下一个\n右键：上一个";
L["New Favorite"] = "新的收藏";
L["Favorites Add"] = "添加到收藏夹";
L["Favorites Remove"] = "从收藏夹中移除";
L["Auto-play"] = "Auto-play";   --Auto-play suggested animation
L["Auto-play Tooltip"] = "如果存在与选中的效果相关的动画，自动播放它";
L["Delete Entry Plural"] = "即将删除%s个条目";
L["Delete Entry Singular"] = "即将删除%s个条目";
L["History Panel Note"] = "被应用的效果会显示在这里";
L["Return"] = "返回";
L["Close"] = "关闭";

--Dressing Room--
L["Favorited"] = "已设为偏好";
L["Unfavorited"] = "已取消偏好";
L["Item List"] = "装备清单";
L["Use Target Model"] = "使用目标模型";
L["Use Your Model"] = "使用自身模型";
L["Cannot Inspect Target"] = "无法检视目标";
L["External Link"] = "外部链接";
L["Add to MogIt Wishlist"] = "加入MogIt愿望清单";

--NPC Browser--
NARCI_NPC_BROWSER_TITLE_LEVEL = ".*%?%?.?";      --Level ?? --Use this to check if the second line of the tooltip is NPC's title or unit type
L["NPC Browser"] = "NPC浏览器";
L["NPC Browser Tooltip"] = "在列表中选择一个人物并加入到当前场景。";
L["Search for NPC"] = "查找人物";
L["Name or ID"] = "姓名或ID";
L["NPC Has Weapons"] = "包含独特武器";
L["Retrieving NPC Info"] = "正在获取NPC信息";
L["Loading Database"] = "数据库加载中...\n游戏画面可能会静止几秒钟。";
L["Other Last Name Format"] = "其他"..NARCI_COLOR_GREY_70.." %s(s)|r:\n";
L["Too Many Matches Format"] = "\n超过%s个结果";

--装备对比--
NARCI_AZERITE_POWERS = "艾泽里特之力";
L["Gem Tooltip Format1"] = "%s和%s";
L["Gem Tooltip Format2"] = "%s、%s和另外%s种...";

--Equipment Set Manager
L["Toggle Equipment Set Manager"] = "点击以打开/关闭套装管理器";
L["Duplicated Set"] = "重复的套装";
L["Low Item Level"] = "物品等级过低";
L["1 Missing Item"] = "缺失1件物品";
L["n Missing Items"] = "缺失%s件物品";
L["Update Items"] = "更新装备";
L["Don't Update Items"] = "不要更新装备";
L["Update Talents"] = "更新天赋";
L["Don't Update Talents"] = "不要更新天赋";
L["Old Icon"] = "旧图标";
NARCI_ICON_SELECTOR = "图标列表";
NARCI_DELETE_SET_WITH_LONG_CLICK = "删除此套装\n|cff808080(按住左键)|r";

--Corruption System
L["Corruption System"] = "腐蚀模块";
L["Eye Color"] = "眼睛顏色";
L["Blizzard UI"] = "原生界面";
L["Corruption Bar"] = "腐蚀条";
L["Corruption Bar Description"] = "在角色信息旁边显示腐蚀条。";
L["Corruption Debuff Tooltip"] = "Debuff提示";
L["Corruption Debuff Tooltip Description"] = "将默认的描述性的Debuff提示替换为数值型提示。";

L["Crit Gained"] = "爆击获取";
L["Haste Gained"] = STAT_HASTE.."获取";
L["Mastery Gained"] = STAT_MASTERY.."获取";
L["Versatility Gained"] = STAT_VERSATILITY.."获取";

L["Proc Crit"] = "触发"..CRIT_ABBR;
L["Proc Haste"] = "触发"..STAT_HASTE;
L["Proc Mastery"] = "触发"..STAT_MASTERY;
L["Proc Versatility"] = "触发"..STAT_VERSATILITY;

L["Critical Damage"] = "爆击伤害";

L["Corruption Effect Format1"] = "|cffffffff%s%%|r 移动速度降低";
L["Corruption Effect Format2"] = "|cffffffff%s|r 初始伤害\n|cffffffff%s 码|r 半径";
L["Corruption Effect Format3"] = "|cffffffff%s|r 伤害\n|cffffffff%s%%|r 最大生命值";
L["Corruption Effect Format4"] = "被彼岸之物击中会立刻触发其余效果";
L["Corruption Effect Format5"] = "|cffffffff%s%%|r 受到的伤害和治疗改变";

--Tutorial--
L["Alert"] = "警告";
L["Race Change"] = "种族/性别变更";
L["Race Change Line1"] = "你又可以改变你的种族和性别了。但是此功能存在一些限制：\n1. 你的武器会消失。\n2. 法术效果不再能被移除。\n3. 此操作对其他玩家或NPC无效。";
L["Guide Spell Headline"] = "试用和应用";
L["Guide Spell Criteria1"] = "单击左键：试用";
L["Guide Spell Criteria2"] = "单击右键：应用";
L["Guide Spell Line1"] = "大多数通过左键添加的效果会在几秒内自行消失，而通过右键添加的效果会一直保留在模型上。\n\n现在请将鼠标移到一个条目上：";
L["Guide Spell Choose Category"] = "选择一个你感兴趣的类别，随后展开一个子类别。"
L["Guide History Headline"] = "历史记录面板";
L["Guide History Line1"] = "至多5个被应用的效果会出现在这里。你可以选中一个，然后按右端的删除按钮将它移除。";
L["Guide Refresh Line1"] = "点击此按钮可以移除所有未被应用的效果。储存在你历史记录面板中的效果会被重新应用。";
L["Guide Input Headline"] = "人工输入";
L["Guide Input Line1"] = "你也可以自行输入SpellVisualKitID。截至8.3版本，这个ID的上限约为124,000。\n你可以用鼠标滚轮来快速预览上/下一个ID。\n有极少的ID可能会导致游戏报错。";
L["Guide Equipment Manager Line1"] = "双击：使用套装\n右击：编辑套装";
L["Guide Model Control Headline"] = "模型控制";
L["Guide Model Control Line1"] = format("你可以用控制试衣间的鼠标行为来控制此模型。此外，你还可以：\n\n1.按住%s和鼠标左键来改变俯仰角。\n2.按住%s和鼠标右键来进行细微缩放。", NARCI_MODIFIER_ALT, NARCI_MODIFIER_ALT);
L["Guide Minimap Button Headline"] = "小地图按钮";
L["Guide Minimap Button Line1"] = "此按钮现在可以被其他插件控制。\n你可以在偏好设定中更改这一选项，改动可能需要重载界面才能生效。"

--Splash--
NARCI_SPELL_VISUALS = "法术视觉效果";
NARCI_PATCH_NOTES = "v1.0.7 Patch Notes";
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
NARCI_SPLASH_HEADER3 = "其他";
NARCI_SPLASH_MESSAGE0 = "|cffd9cdb41. 你现在可以在场景里应用独特的效果了。|r\n你可以为演员添加法术或者其他道具，甚至可以控制场景中的天气。点击模型控制面板左下角的按钮即可展开选项。"
NARCI_SPLASH_MESSAGE1 = format("|cffd9cdb42. 翻转模型和细微缩放|r\n你可以按住%s和鼠标左键来让模型演Y轴旋转；或是按住%s和鼠标右键来进行细微缩放。", NARCI_MODIFIER_ALT, NARCI_MODIFIER_ALT);
NARCI_SPLASH_MESSAGE2 = "|cffd9cdb4可通过点击右上方的六边形按钮（也是显示你最高物品等级的地方）来展开这个功能。";
NARCI_SPLASH_MESSAGE3 = "|cffd9cdb41. 现在AFK画面会在你移动或者进入战斗时自动退出。\n2. 试衣间增强又恢复了工作。|r";


L["Show Whats New"] = "显示欢迎界面";
NARCI_SPLASH_WHATS_NEW_FORMAT = "Narcissus %s ".."更新内容";
NARCI_SPLASH_HEADER1 = "NPC浏览器";
NARCI_SPLASH_HEADER2 = "杂项";
NARCI_SPLASH_INTERACTIVE_TEXT1 = NARCI_COLOR_GREY_85.."合影模式|r\n- 你现在可以随时随地添加NPC模型，不再需要先在游戏中找到他。\n- 你可以从已分类的列表中选择，或是按姓名或ID进行搜索。\n\n" ..NARCI_COLOR_GREY_85.."NPC信息(可选)|r\n- 在你的鼠标在目标身上悬停时，找到其他与其同姓的NPC。\n- 可以在NPC姓名版或鼠标提示上显示其在其他语言中的译名。";
NARCI_SPLASH_INTERACTIVE_TEXT2 = NARCI_COLOR_GREY_85.."";
NARCI_SPLASH_INTERACTIVE_TEXT3 = NARCI_COLOR_GREY_85.."AFK画面|r\n保持站立这一功能已变为可选。\n\n"..NARCI_COLOR_GREY_85.."截图质量|r\n- 不再强制将截图质量设置为10。\n- 偏好设定中新增一个截图质量滑杆。\n\n"..NARCI_COLOR_GREY_85.."腐蚀模块|r\n- 修复了与Corruption Tooltip部分功能不兼容的问题。\n- 更新了腐化之眼的伤害计算公式。新公式为：\n(0.5*腐蚀值+ 15) * HP";

--Project Details--
NARCI_ALL_PROJECTS = "全部项目";
NARCI_PROJECT_DETAILS = "|cFFFFD100插件作者: Peterodox\n更新日期: 2020.4.26|r\n\n感谢你使用此插件！如果你遇到任何问题，或者有任何想法或建议，请在CurseForge项目主页上留言，或者在以下网站上联系我。";
NARCI_PROJECT_AAA_SUMMARY = "探索艾泽拉斯上的不同景点，并收集各种故事和照片。";
NARCI_PROJECT_NARCISSUS_SUMMARY = "沉浸式角色面板；你最好的截图助手。"

--Conversation--
L["Q1"] = "这是个啥？";
L["Q2"] = "这我知道。但是它为什么这么大？";
L["Q3"] = "这不好笑。我只想要个正常大小的提示。";
L["Q4"] = "很好。但我该怎么禁用这个提示呢？";
L["Q5"] = "还有一件事：你能保证不再搞恶作剧了吗？";
L["A1"] = "显然这是一个退出确认窗口。当你尝试按下快捷键来退出合影模式时它就会弹出来。";
L["A2"] = "哈哈哈，她也是这么说的。";
L["A3"] = "好吧...好吧..."
L["A4"] = "打开偏好设定，然后选择拍照模式标签，你就能看到这个选项啦。";