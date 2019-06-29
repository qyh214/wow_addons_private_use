if not(GetLocale() == "zhTW") then
    return
end

local L = Narci.L

NARCI_GRADIENT = "|cffA236EFN|cff9448F1a|cff865BF2r|cff786DF4c|cff6A80F6i|cff5D92F7s|cff4FA4F9s|cff41B7FAu|cff33C9FCs|r 角色資訊"
MYMOG_GRADIENT = "|cffA236EFM|cff9448F1y |cff865BF2T|cff786DF4r|cff6A80F6a|cff5D92F7n|cff4FA4F9s|cff41B7FAm|cff33C9FCo|cff32c9fbg|r"

L["Movement Speed"] = "移動速度";
L["Damage Reduction Percentage"] = "減傷%";

L["Advanced Info"] = "點一下切換顯示進階資訊。";

L["Photo Mode"] = "拍照模式";
L["Photo Mode Tooltip Open"] = "點一下開啟截圖工具箱。";
L["Photo Mode Tooltip Close"] = "點一下關閉截圖工具箱。";
L["Photo Mode Tooltip Special"] = "在魔獸的 Screenshots 資料夾裡面的 截圖中將不會包含這個工具介面。";

L["Xmog Button"] = "分享塑形";
L["Xmog Button Tooltip Open"] = "點一下顯示塑形物品，而不是實際裝備。";
L["Xmog Button Tooltip Close"] = "點一下顯示裝備欄中穿著的實際裝備。";
L["Xmog Button Tooltip Special"] = "可以切換不同的版面配置。";

L["Emote Button"] = "表情動作";
L["Emote Button Tooltip Open"] = "搭配獨特的表情動畫。";

L["HideTexts Button"] = "隱藏文字";
L["HideTexts Button Tooltip Open"] = "點一下隱藏所有單位名稱、聊天泡泡和戰鬥文字。";
L["HideTexts Button Tooltip Close"] = "點一下恢復顯示單位名稱、聊天泡泡和戰鬥文字。";
L["HideTexts Button Tooltip Special"] = "結束拍照模式後都會恢復成原本的設定。";

L["TopQuality Button"] = "最高品質";
L["TopQuality Button Tooltip Open"] = "點一下將畫面設定中的每一個選項都設為最高值。";
L["TopQuality Button Tooltip Close"] = "點一下恢復畫面設定。";

L["Heritage Armor"] = "經典護甲";
ITEMSOURCE_SECRETFINDING = "秘密發現"

HEART_QUOTE_1 = "眼睛看不到的也非常重要。";

--Title Manager--
NARCI_TITLE_MANAGER_OPEN = "開啟頭銜管理員";
NARCI_TITLE_MANAGER_CLOSE = "關閉頭銜管理員";

--Alias--
NARCI_ALIAS_USE_ALIAS = "切換成暱稱"
NARCI_ALIAS_USE_PLAYER_NAME = "切換成"..CALENDAR_PLAYER_NAME;

L["Minimap Tooltip Double Click"] = "按兩下";
L["Minimap Tooltip Left Click"] = "左鍵|r";
L["Minimap Tooltip To Open"] = "|cffffffff開啟全螢幕角色資訊";
L["Minimap Tooltip Right Click"] = "右鍵";
L["Minimap Tooltip Shift Right Click"] = "Shift + 右鍵"
L["Minimap Tooltip Hide Button"] = "|cffffffff隱藏這個按鈕|r"
L["Minimap Tooltip Middle Button"] = "|CFFFF1000中鍵 |cffffffff重置鏡頭";
L["Minimap Tooltip Set Scale"] = "設定縮放大小: |cffffffff/narci [大小數值 0.8~1.2]";

NARCI_CLIPBOARD = "剪貼板";
NARCI_LAYOUT = "版面配置";
NARCI_LAYOUT_SYMMETRY = "對稱";
NARCI_LAYOUT_ASYMMETRY = "不對稱";
NARCI_COPY_TEXTS = "複製文字";
NARCI_SYNTAX = "句法";
NARCI_SYNTAX_PLAIN_TEXT = "純文字";
NARCI_EXPORT_INCLUDES = "同時導出...";
NARCI_ITEM_ID = "物品ID";

NARCI_3DMODEL = "3D模組";
NARCI_EQUIPMENTSLOTS = "裝備欄";

--Preferences--
NARCI_PREFERENCE = "偏好設定-PH";
NARCI_INTERFACE = "介面";
NARCI_THEME = "主題";
NARCI_CAMERA = "鏡頭";
NARCI_EFFECTS = "效果";
NARCI_TRANSMOG = "塑形";
NARCI_EXTENSIONS = "拓展功能";
NARCI_ABOUT = "關於"
NARCI_PREFERENCE_TOOLTIP = "點一下打開偏好設定";
NARCI_TRUNCATE_TEXT = "截斷文字";
NARCI_TEXT_WIDTH = "文字寬度";
NARCI_HOTKEY = "快捷鍵";
NARCI_DOUBLE_TAP = "按兩下";
NARCI_DOUBLE_TAP_DESCRIPTION = "Double-tap the key bound to Character Pane to open Narcissus."
NARCI_OVERRIDE = "是否覆蓋";
NARCI_INVALID_KEY = "無效的值";
NARCI_MINIMAP_BUTTON = "小地圖按鈕";
NARCI_SHORTCUTS = "快捷方式";
NARCI_FILTERS = "濾鏡";
NARCI_FILTERS_DESCRIPTION = "All filters except vignette will be disabled in transmog mode.";
NARCI_GRAIN_EFFECT = "顆粒效果";
NARCI_CAMERA_MOVEMENT = "鏡頭運動";
NARCI_CAMERA_ORBIT = "環繞鏡頭";
NARCI_CAMERA_ORBIT_ENABLED_DESCRIPTION = "When you open this addon, the camera will be rotated to your front and begin orbiting.";
NARCI_CAMERA_ORBIT_DISABLED_DESCRIPTION = "When you open this addon, the camera will be zoomed in without rotation";
NARCI_FADEOUT = "自動淡化";
NARCI_FADEOUT_DESCRIPTION = "Button fades out when you move the cursor out of it.";
NARCI_FADE_MUSIC = "淡入/淡出音樂";
NARCI_VIGNETTE_STRENGTH = "Vignette Strength";
NARCI_WEATHER_EFFECT = "天氣效果";
NARCI_LETTERBOX_EFFECT = "寬熒幕效果";
NARCI_LETTERBOX_RATIO = "寬高比";
NARCI_LETTERBOX_EFFECT_ALERT1 = "妳屏幕的寬高比超過了所選比例。";
NARCI_LETTERBOX_EFFECT_ALERT2 = "建議將UI縮放比設置為%0.1f\n(當前縮放比為%0.1f)";
NARCI_DEFAULT_LAYOUT = "預設佈局";
NARCI_LAYOUT_1 = "對稱，唯一模組";
NARCI_LAYOUT_2 = "雙模組";
NARCI_LAYOUT_3 = "緊湊模式";
NARCI_BORDER_THEME = "邊框主題";
NARCI_BORDER_THEME_BRIGHT = "明亮";
NARCI_BORDER_THEME_DARK = "灰暗";
NARCI_ALWAYS_SHOW_MODEL = "總是顯示模組";
NARCI_SHOW_FULL_BODY = "顯示全身";
NARCI_AFK_SCREEN = "AFK画面";
NARCI_AFK_SCREEN_DESCRIPTION = "在妳的人物暫離後自動打開Narcissus。";
NARCI_AFK_SCREEN_DESCRIPTION_EXTRA = "勾選此選項將覆蓋ElvUI的AFK模式。";
NARCI_GEMMA = "\"Gemma\"";
NARCI_GEMMY_DESCRIPTION = "在妳為壹件物品鑲嵌寶石時，顯示可用的寶石列表。"

--Model Control--
NARCI_SHEATH_WEAPON = "收起武器";
NARCI_STAND_IDLY = "站立狀態";
NARCI_RANGED_WEAPON = "遠程武器";
NARCI_MELEE_WEAPON = "近戰武器";
NARCI_SPELLCASTING = "施法動作";
NARCI_ANIMATION_ID = "動畫ID";
NARCI_GROUND_SHADOW = "模擬地面陰影";
NARCI_HIDE_PLAYER = "隱藏玩家自身";

--Equipment Comparison--
NARCI_AZERITE_POWERS = "艾澤萊晶岩之力"

--Tutorial--
NARCI_TUTORIAL_CAPTUREBUTTON = "點擊此按鈕後會自動保存5張圖層：\n僅背景、帶藍\\綠幕的3D模型、裝備欄的alpha\\顏色通道。\n\n如果想只保存壹張截圖，請按鍵盤上的截圖快捷鍵。";
NARCI_TUTORIAL_ANIMATION_ID = "左鍵單擊 ID +1  右鍵單擊 ID -1\n動畫ID的有效範圍為 0~1447。";
NARCI_TUTORIAL_GREEN_SCREEN = "點擊最左端的正方形按鈕可以顯示藍\\綠幕。";

--Others need to be localized--
L["Level"] = "等級";
L["Resource"] = "能量";
L["Camera has been reset."] = "鏡頭已經重置。"
L["Minimap button has been hidden. You may type /Narci minimap to re-enable it."] = "小地圖按鈕已經隱藏，可以輸入 /Narci minimap 來重新啟用。"
L["Minimap button has been re-enabled."] = "小地圖按鈕已經重新啟用。"

--Splash--
NARCI_PATCH_NOTES = "v1.0.5 Patch Notes";
NARCI_SPLASH_CLOSE_AND_CONTINUE = "關閉此窗口並繼續";
NARCI_TRY_IT_NOW = "點擊這裏來啟用...";
    --Patch-specific
    NARCI_AFK_ENABLED = "AFK畫面已開啟。妳可以在“偏好設定-拓展功能”中關閉它。";
    NARCI_LETTERBOX_ENABLED = "寬熒幕效果已開啟。 妳可以在“偏好設定-效果”中關閉它。";
    --
NARCI_SHOW_DETAILS = "+ Show details...";
NARCI_SPLASH_HEADER1 = "裝備欄";
NARCI_SPLASH_HEADER2 = "效果";
NARCI_SPLASH_MESSAGE0 = "|cff40C7EB1. 裝備對比界面已經過更新。|r\n妳現在可以在對比裝備時查看該物品的艾澤萊晶岩之力或是其他特效。"
NARCI_SPLASH_MESSAGE1 = "|cff40C7EB2. 寶石管理員 -- \"Gemma\"|r\n當妳處於Narcissus界面時：如果壹件裝備有孔，點擊三角形圖標後會出現壹個可用的寶石列表。雙擊寶石來進行鑲嵌。\n\n當使用暴雪界面時：如果妳背包內有可用寶石，這個列表將會隨鑲嵌面板壹起顯示。";
NARCI_SPLASH_MESSAGE1_CONDITIONAL_LINE = "You have disabled the auto-follow feature so you will not feel any different."
NARCI_SPLASH_MESSAGE1_EXTRA_LINE = "In the previous versions, Narcissus set a CVar named |cffffffffcameraSmoothTimeMin|r to 0.8 (was 0.1 by default) to ensure a smooth camera transition after closing the addon. This, however, caused an increase of the auto-follow duration when the camera is moved by a small degree. After this update, all camera-related CVars used in this addon belong to the Actioncam feature which can be disabled by |cffffffff/console actioncam off|r";
NARCI_SPLASH_MESSAGE2 = "|cff40C7EB2. 新濾鏡：寬熒幕效果。|r"
NARCI_SPLASH_MESSAGE3 = "|cff40C7EB1. AFK畫面：在妳進入暫離狀態後自動打開Narcissus。|r"
NARCI_SPLASH_MESSAGE4 = "|cff40C7EB1. You can once again use an item via right-click. Equipment slots will be immediately closed when entering combat.|r"
NARCI_SPLASH_MESSAGE5 = "2. You can unequip a gear via Alt + Left-click. This action has been there since the very first version, and it now has visual feedback."

--Project Details--
NARCI_ALL_PROJECTS = "全部項目";
NARCI_PROJECT_DETAILS = "|cFFFFD100插件作者: Peterodox\n更新日期: 2019.6.16|r\n\n感謝妳使用此插件！如果妳遇到任何問題，或者有任何想法或建議，請在CurseForge項目主頁上留言，或者在以下網站上聯系我。";
NARCI_PROJECT_AAA_SUMMARY = "探索艾澤拉斯上的不同景點，並收集各種故事和照片。";
NARCI_PROJECT_NARCISSUS_SUMMARY = "沈浸式角色面板；妳最好的截圖助手。"