if not(GetLocale() == "zhTW") then
    return
end

local L = Narci.L

NARCI_GRADIENT = "|cffA236EFN|cff9448F1a|cff865BF2r|cff786DF4c|cff6A80F6i|cff5D92F7s|cff4FA4F9s|cff41B7FAu|cff33C9FCs|r 角色資訊"
MYMOG_GRADIENT = "|cffA236EFM|cff9448F1y |cff865BF2T|cff786DF4r|cff6A80F6a|cff5D92F7n|cff4FA4F9s|cff41B7FAm|cff33C9FCo|cff32c9fbg|r"

NARCI_MODIFIER_ALT = "ALT鍵";   --Windows
if IsMacClient() then
    NARCI_MODIFIER_ALT = "Option鍵";  --Mac OS
end

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
L["Minimap Tooltip Enter Photo Mode"] = "|cffffffff開啟拍照模式";
L["Minimap Tooltip Right Click"] = "右鍵";
L["Minimap Tooltip Shift Right Click"] = "Shift + 右鍵"
L["Minimap Tooltip Hide Button"] = "|cffffffff隱藏這個按鈕|r"
L["Minimap Tooltip Middle Button"] = "|CFFFF1000中鍵 |cffffffff重置鏡頭";
L["Minimap Tooltip Set Scale"] = "設定縮放大小: |cffffffff/narci [大小數值 0.8~1.2]";
L["Corrupted Item Parser"] = "|cffffffff開啟腐化物品鏈接解析器|r";
L["Toggle Dressing Room"] = "|cffffffff開啟"..DRESSUP_FRAME.."|r";

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
NARCI_ABOUT = "關於";
NARCI_PREFERENCE_TOOLTIP = "點一下打開偏好設定";
NARCI_TRUNCATE_TEXT = "截斷文字";
NARCI_TEXT_WIDTH = "文字寬度";
NARCI_HOTKEY = "快捷鍵";
NARCI_DOUBLE_TAP = "按兩下";
NARCI_DOUBLE_TAP_DESCRIPTION = "連按兩下打開角色面板的快捷鍵來打開此插件。"
NARCI_OVERRIDE = "是否覆蓋";
NARCI_INVALID_KEY = "無效的值";
NARCI_MINIMAP_BUTTON = "小地圖按鈕";
NARCI_SHORTCUTS = "快捷方式";
NARCI_FILTERS = "濾鏡";
NARCI_FILTERS_DESCRIPTION = "除暗角以外的所有濾鏡都會在幻化模式被暫時禁用。";
NARCI_GRAIN_EFFECT = "顆粒效果";
NARCI_CAMERA_MOVEMENT = "鏡頭運動";
NARCI_CAMERA_ORBIT = "環繞鏡頭";
NARCI_CAMERA_ORBIT_ENABLED_DESCRIPTION = "當妳打開此插件時，鏡頭會自動旋轉到角色面前並開始環繞。";
NARCI_CAMERA_ORBIT_DISABLED_DESCRIPTION = "當妳打開此插件時，鏡頭只會被拉近不會有任何旋轉。";
NARCI_CAMERA_SAFE_MODE = "鏡頭安全模式";
NARCI_CAMERA_SAFE_MODE_DESCRIPTION = "在關閉此插件後徹底關閉ActionCam功能。";
NARCI_CAMERA_SAFE_MODE_DESCRIPTION_EXTRA = "已禁用因為妳正在使用DynamicCam插件。";
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
NARCI_AFK_SCREEN_DESCRIPTION = "在妳的人物暫離後自動打開Narcissus。";
NARCI_AFK_SCREEN_DESCRIPTION_EXTRA = "勾選此選項將覆蓋ElvUI的AFK模式。";
NARCI_GEMMA = "\"Gemma\"";
NARCI_GEMMY_DESCRIPTION = "在妳為壹件物品鑲嵌寶石時，顯示可用的寶石列表。"
NARCI_DRESSING_ROOM = "試衣間"
NARCI_DRESSING_ROOM_DESCRIPTION = "增大試衣間窗口大小，並使妳能夠通過試衣間瀏覽、復制其他玩家的幻化調料包。";
NARCI_REQUIRE_RELOAD = "|cffff5050需要重載UI才能使設置生效。|r";
L["Show Detailed Stats"] = "顯示詳盡的屬性信息";
L["Tooltip Color"] = "小提示顏色";
L["Entrance Visual"] = "登場效果";
L["Entrance Visual Description"] = "在模組登場時播放法術效果。";
L["Panel Scale"] = "面板縮放";
L["Exit Confirmation"] = "退出確認";
L["Exit Confirmation Texts"] = "退出合影模式？";
L["Exit Confirmation Leave"] = "退出";
L["Exit Confirmation Cancel"] = "取消";
L["Ultra-wide"] = "超寬屏";
L["Ultra-wide Optimization"] = "超寬屏優化";
L["Baseline Offset"] = "基準線偏移";
L["Ultra-wide Tooltip"] = "妳能看到此選項是因為妳正在使用壹臺%s:9顯示器。";
L["Interactive Area"] = "交互區域";
L["Item Socketing Tooltip"] = "雙擊左鍵進行鑲嵌";
L["No Available Gem"] = "|cffd8d8d8沒有可鑲嵌的寶石|r";
L["Credits"] = "致謝";
L["Use Bust Shot"] = "使用半身像";
L["Use Escape Button"] = "Esc鍵";
L["Use Escape Button Description"] = "按下Esc鍵來退出插件。或者點擊屏幕右上角隱藏的X按鈕。";
L["Handled by Other Addons"] = "受其他模組控制";
L["AFK Screen"] = "AFK画面";
L["Keep Standing"] = "保持站立";
L["Keep Standing Description"] = "當妳AFK後定時使用/站立表情。此選項不會中斷自動登出。"
L["None"] = "無";
L["NPC"] = "NPC";
L["Database"] = "數據庫";
L["Creature Tooltip"] = "生物信息";
L["RAM Usage"] = "內存占用";
L["Others"] = "其它";
L["Find Relatives"] = "查找相關生物";
L["Find Related Creatures Description"] = "找到與目標同姓的其他生物。";
L["Find Relatives Hotkey"] = "按Tab搜索相關生物。";
L["Find Relatives Hotkey Format"] = "按下%s開始查找。";
L["Translate Names"] = "翻譯姓名";
L["Translate Names Description On"] = "獲取目標譯名並將其顯示在...";
L["Select A Language"] = "已選語言：";
L["Select Multiple Languages"] = "已選語言：";
L["Load on Demand"] = "隨需求載入";
L["Load on Demand Description On"] = "在搜索功能被調用時再載入數據庫。";
L["Load on Demand Description Off"] = "數據庫將在妳登入時載入。";
L["Load on Demand Description Disabled"] = NARCI_COLOR_YELLOW.. "這壹選項被鎖住了，因為妳選擇顯示生物信息。";
L["Tooltip"] = "小提示";
L["Name Plate"] = "名條";
L["Y Offset"] = "縱向偏移";
L["Sceenshot Quality"] = "截圖質量";
L["Screenshot Quality Description"] = "更高的截圖質量會增加圖片大小。";

--Model Control--
NARCI_HOLD_WEAPON = "握住武器";
NARCI_STAND_IDLY = "站立狀態";
NARCI_RANGED_WEAPON = "遠程武器";
NARCI_MELEE_WEAPON = "近戰武器";
NARCI_SPELLCASTING = "施法動作";
NARCI_ANIMATION_ID = "動畫ID";
NARCI_GROUND_SHADOW = "模擬地面陰影";
NARCI_HIDE_PLAYER = "隱藏玩家自身";
NARCI_LINK_LIGHT_SETTINGS = "關聯燈光設定";
NARCI_LINK_MODEL_SCALE = "關聯模組比例";
NARCI_GROUP_PHOTO = "合影模式";
NARCI_GROUP_PHOTO_AVAILABLE = "現已加入Narcissus插件";
NARCI_GROUP_PHOTO_NOTIFICATION = "請選擇壹個目標。";
NARCI_GROUP_PHOTO_STATUS_HIDDEN = "隱藏";
NARCI_DIRECTIONAL_AMBIENT_LIGHT = "平行光/環境光";
NARCI_DIRECTIONAL_AMBIENT_LIGHT_TOOLTIP = "在以下兩種燈光間切換：\n- 可以被模組遮擋並投射陰影的平行光\n- 影響整個模組表面的環境光";
L["Reset"] = "重置";
L["Actor Index"] = "序號";
L["Move To Font"] = "|cff40c7eb頂層|r";
L["Actor Index Tooltip"] = "拖動壹個序號按鈕來改變其模組的層級。";
L["Play Button Tooltip"] = "左鍵：播放此動畫\n右鍵：恢復所有模組的動畫";
L["Pause Button Tooltip"] = "左鍵：定格此動畫\n右鍵：暫停所有模組的動畫";
L["Save Layers"] = "保存圖層";
L["Save Layers Tooltip"] = "自動截取6張截圖以供後期合成使用。\n在此過程中請不要移動鼠標或點擊任何按鈕，否則在退出插件後妳的角色可能變為不可見。如果發生這種情況，請輸入以下指令：\n/console showplayer";
L["Ground Shadow"] = "模擬地面陰影";
L["Ground Shadow Tooltip"] = "為妳的模組下方添加壹個可調整的陰影。";
L["Hide Player"] = "隱藏玩家自身";
L["Hide Player Tooltip"] = "讓妳的角色變為不可見。";
L["Virtual Actor"] = "虛擬角色";
L["Virtual Actor Tooltip"] = "只有法術效果可見";
L["Self"] = "自身";
L["Target"] = "目標";
L["Compact Mode Tooltip"] = "僅用屏幕左側來展示妳的幻化。";
L["Toggle Equipment Slots"] = "顯示裝備欄";
L["Toggle Text Mask"] = "文字蒙版";
L["Toggle 3D Model"] = "顯示3D模組";
L["Toggle Model Mask"] = "模組蒙版";
L["Show Color Sliders"] = "顯示色彩滑桿";
L["Show Color Presets"] = "顯示色彩預設";


--Spell Visual Browser--
L["Visuals"] = "法術效果";
L["Visual ID"] = "效果ID";
L["Animation ID Abbre"] = "動畫ID";
L["Category"] = "類別";
L["Sub-category"] = "子類別";
L["My Favorites"] = "收藏夾";
L["Reset Visual Tooltip"] = "移除未應用的效果";
L["Remove Visual Tooltip"] = "左鍵：移除選中的效果\n長按：移除所有效果";
L["Apply"] = "應用";
L["Applied"] = "已應用";
L["Remove"] = "刪除";
L["Rename"] = "重命名";
L["Refresh Model"] = "重載模組";
L["Toggle Browser"] = "效果瀏覽器";
L["Next And Previous"] = "左鍵：下壹個\n右鍵：上壹個";
L["New Favorite"] = "新的收藏";
L["Favorites Add"] = "添加到收藏夾";
L["Favorites Remove"] = "從收藏夾中移除";
L["Auto-play"] = "Auto-play";   --Auto-play suggested animation
L["Auto-play Tooltip"] = "如果存在與選中的效果相關的動畫，自動播放它";
L["Delete Entry Plural"] = "即將刪除%s個條目";
L["Delete Entry Singular"] = "即將刪除%s個條目";
L["History Panel Note"] = "被應用的效果會顯示在這裏";
L["Return"] = "返回";
L["Close"] = "關閉";

--Dressing Room--
L["Favorited"] = "已設為最愛";
L["Unfavorited"] = "已取消最愛";
L["Item List"] = "裝備清單";
L["Use Target Model"] = "使用目標外形";
L["Use Your Model"] = "使用自身外形";
L["Cannot Inspect Target"] = "無法檢視目標";
L["External Link"] = "外部鏈接";
L["Add to MogIt Wishlist"] = "加入MogIt願望清單";

--NPC Browser--
NARCI_NPC_BROWSER_TITLE_LEVEL = ".*%?%?.?";      --Level ?? --Use this to check if the second line of the tooltip is NPC's title or unit type
L["NPC Browser"] = "NPC瀏覽器";
L["NPC Browser Tooltip"] = "在列表中選擇壹個人物並加入到當前場景。";
L["Search for NPC"] = "查找人物";
L["Name or ID"] = "姓名或ID";
L["NPC Has Weapons"] = "包含獨特武器";
L["Retrieving NPC Info"] = "正在獲取NPC信息";
L["Loading Database"] = "數據庫加載中...\n遊戲畫面可能會靜止幾秒鐘。";
L["Other Last Name Format"] = "其他"..NARCI_COLOR_GREY_70.." %s(s)|r:\n";
L["Too Many Matches Format"] = "\n超過%s個結果";

--Equipment Comparison--
NARCI_AZERITE_POWERS = "艾澤萊晶岩之力"
L["Gem Tooltip Format1"] = "%s和%s";
L["Gem Tooltip Format2"] = "%s、%s和另外%s種...";

--Equipment Set Manager
L["Toggle Equipment Set Manager"] = "點擊以打開/關閉裝備管理員";
L["Low Item Level"] = "物品等级過低";
L["1 Missing Item"] = "缺少1件物品";
L["n Missing Items"] = "缺少%s件物品";
L["Update Items"] = "更新裝備";
L["Don't Update Items"] = "不要更新裝備";
L["Update Talents"] = "更新天賦";
L["Don't Update Talents"] = "不要更新天賦";
L["Old Icon"] = "舊圖示";
NARCI_ICON_SELECTOR = "圖示清單";
NARCI_DELETE_SET_WITH_LONG_CLICK = "刪除此套裝\n|cff808080(按住左鍵)|r";

--Corruption System
L["Corruption System"] = "腐化裝備";
L["Eye Color"] = "眼睛顏色";
L["Blizzard UI"] = "原生界面";
L["Corruption Bar"] = "腐化條";
L["Corruption Bar Description"] = "在角色資訊旁邊顯示腐化程度條。";
L["Corruption Debuff Tooltip"] = "Debuff提示";
L["Corruption Debuff Tooltip Description"] = "將默認的描述性的Debuff提示替換為數值型提示。";

L["Crit Gained"] = CRIT_ABBR.."獲取";
L["Haste Gained"] = STAT_HASTE.."獲取";
L["Mastery Gained"] = STAT_MASTERY.."獲取";
L["Versatility Gained"] = STAT_VERSATILITY.."獲取";

L["Proc Crit"] = "觸發"..CRIT_ABBR;
L["Proc Haste"] = "觸發"..STAT_HASTE;
L["Proc Mastery"] = "觸發"..STAT_MASTERY;
L["Proc Versatility"] = "觸發"..STAT_VERSATILITY;

L["Critical Damage"] = "致命傷害";

L["Corruption Effect Format1"] = "|cffffffff%s%%|r 移動速度降低";
L["Corruption Effect Format2"] = "|cffffffff%s|r 初始傷害\n|cffffffff%s 碼|r 半徑";
L["Corruption Effect Format3"] = "|cffffffff%s|r 傷害\n|cffffffff%s%%|r 生命力上限";
L["Corruption Effect Format4"] = "被異界之物擊中會立刻觸發其余負面效果";
L["Corruption Effect Format5"] = "|cffffffff%s%%|r 受到的傷害和治療改變";

--Tutorial--
L["Alert"] = "警告";
L["Race Change"] = "種族/性別變更";
L["Race Change Line1"] = "妳又可以改變妳的種族和性別了。但是此功能存在壹些限制：\n1. 妳的武器會消失。\n2. 法術效果不再能被移除。\n3. 此操作對其他玩家或NPC無效。";
L["Guide Spell Headline"] = "試用和應用";
L["Guide Spell Criteria1"] = "單擊左鍵：試用";
L["Guide Spell Criteria2"] = "單擊右鍵：應用";
L["Guide Spell Line1"] = "大多數通過左鍵添加的效果會在幾秒內自行消失，而通過右鍵添加的效果會壹直保留在模組上。\n\n現在請將鼠標移到壹個條目上：";
L["Guide Spell Choose Category"] = "選擇壹個妳感興趣的類別，隨後展開壹個子類別。"
L["Guide History Headline"] = "歷史記錄面板";
L["Guide History Line1"] = "至多5個被應用的效果會出現在這裏。妳可以選中壹個，然後按右端的刪除按鈕將它移除。";
L["Guide Refresh Line1"] = "點擊此按鈕可以移除所有未被應用的效果。儲存在妳歷史記錄面板中的效果會被重新應用。";
L["Guide Input Headline"] = "自行輸入";
L["Guide Input Line1"] = "妳也可以自行輸入SpellVisualKitID。截至8.3版本，這個ID的上限約為124,000。\n妳可以用鼠標滾輪來快速預覽上/下壹個ID。\n有極少的ID可能會導致遊戲報錯。";
L["Guide Equipment Manager Line1"] = "雙擊：使用套裝\n右擊：編輯套裝";
L["Guide Model Control Headline"] = "模組控制";
L["Guide Model Control Line1"] = format("妳可以用控制試衣間的鼠標行為來控制此模組。此外，妳還可以：\n\n1.按住%s和鼠標左鍵來改變俯仰角。\n2.按住%s和鼠標右鍵來進行細微縮放。", NARCI_MODIFIER_ALT, NARCI_MODIFIER_ALT);
L["Guide Minimap Button Headline"] = "小地圖按鈕";
L["Guide Minimap Button Line1"] = "此按鈕現在可以被其他插件控制。\n妳可以在偏好設定中更改這壹選項，改動可能需要重載界面才能生效。";

--Others need to be localized--
L["Level"] = "等級";
L["Resource"] = "能量";
L["Camera has been reset."] = "鏡頭已經重置。"
L["Minimap button has been hidden. You may type /Narci minimap to re-enable it."] = "小地圖按鈕已經隱藏，可以輸入 /Narci minimap 來重新啟用。"
L["Minimap button has been re-enabled."] = "小地圖按鈕已經重新啟用。"

--Splash--
NARCI_SPELL_VISUALS = "法術視覺效果";
NARCI_SPLASH_CLOSE_AND_CONTINUE = "關閉此窗口並繼續";
NARCI_SPLASH_SOUNDS_GREAT_BYE = "聽上去不錯。待會兒見！";
NARCI_TRY_IT_NOW = "點擊這裏以啟用...";
NARCI_DISABLE_IT_NOW = "點擊這裏以禁用...";
    --Patch-specific
    NARCI_DRESSING_ROOM_ENABLED_BY_DEFAULT = "|cff7cc576已默認開啟。|r "..NARCI_DISABLE_IT_NOW;
    NARCI_DRESSING_ROOM_DISABLED = "|cffff5050已禁用。|r 需要重載UI才能使設置生效。 妳可以在偏好設定-拓展功能中重新啟用它。";
    NARCI_CAMERA_SAFE_MODE_ENABLED_BY_DEFAULT = "|cff7cc576已默認開啟，因為妳沒有在使用DynamicCam插件。|r\n"..NARCI_DISABLE_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_DISABLED_BY_DEFAULT = "|cffff5050已默認關閉，因為妳正在使用DynamicCam插件。|r\n"..NARCI_TRY_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_ENABLED = "|cff7cc576已啟用。|r 妳可以在偏好設定-鏡頭中關閉它。";
    NARCI_CAMERA_SAFE_MODE_DISABLED = "|cffff5050已禁用。|r 妳可以在偏好設定-鏡頭中啟用它。";
    --
NARCI_SHOW_DETAILS = "+ Show details...";
NARCI_SPLASH_HEADER1 = "視覺效果和模組控制";
NARCI_SPLASH_HEADER2 = "套裝管理員";
NARCI_SPLASH_HEADER3 = "其他";
NARCI_SPLASH_MESSAGE0 = "|cffd9cdb41. 妳現在可以在場景裏應用獨特的效果了。|r\n妳可以為演員添加法術或者其他道具，甚至可以控制場景中的天氣。點擊模組控制面板左下角的按鈕即可展開選項。"
NARCI_SPLASH_MESSAGE1 = format("|cffd9cdb42. 翻轉模組和細微縮放|r\n妳可以按住%s和滑鼠左鍵來讓模組演Y軸旋轉；或是按住%s和滑鼠右鍵來進行細微縮放。", NARCI_MODIFIER_ALT, NARCI_MODIFIER_ALT);
NARCI_SPLASH_MESSAGE2 = "|cffd9cdb4可通過點擊右上方的六邊形按鈕（也是顯示妳最高物品等級的地方）來展開這個功能。";
NARCI_SPLASH_MESSAGE3 = "|cffd9cdb41. 現在AFK畫面會在妳移動或者進入戰鬥時自動退出。\n2. 試衣間增強又恢復了工作。|r";

L["Show Whats New"] = "顯示歡迎界面";
NARCI_SPLASH_WHATS_NEW_FORMAT = "Narcissus %s ".."更新內容";
NARCI_SPLASH_HEADER1 = "NPC瀏覽器";
NARCI_SPLASH_HEADER2 = "雜項";
NARCI_SPLASH_INTERACTIVE_TEXT1 = NARCI_COLOR_GREY_85.."合影模式|r\n- 妳現在可以隨時隨地添加NPC模型，不再需要先在遊戲中找到他。\n- 妳可以從已分類的列表中選擇，或是按姓名或ID進行搜索。\n\n" ..NARCI_COLOR_GREY_85.."NPC信息(可選)|r\n- 在妳的鼠標在目標身上懸停時，找到其他與其同姓的NPC。\n- 可以在NPC姓名版或鼠標提示上顯示其在其他語言中的譯名。";
NARCI_SPLASH_INTERACTIVE_TEXT2 = NARCI_COLOR_GREY_85.."";
NARCI_SPLASH_INTERACTIVE_TEXT3 = NARCI_COLOR_GREY_85.."AFK畫面|r\n保持站立這壹功能已變為可選。\n\n"..NARCI_COLOR_GREY_85.."截圖質量|r\n- 不再強制將截圖質量設置為10。\n- 偏好設定中新增壹個截圖質量滑桿。\n\n"..NARCI_COLOR_GREY_85.."腐化模塊|r\n- 修復了與Corruption Tooltip部分功能不兼容的問題。\n- 更新了腐化之眼的傷害計算公式。新公式為：\n(0.5*腐化值+ 15) * HP";

--Project Details--
NARCI_ALL_PROJECTS = "全部項目";
NARCI_PROJECT_DETAILS = "|cFFFFD100插件作者: Peterodox\n更新日期: 2020.4.26|r\n\n感謝妳使用此插件！如果妳遇到任何問題，或者有任何想法或建議，請在CurseForge項目主頁上留言，或者在以下網站上聯系我。";
NARCI_PROJECT_AAA_SUMMARY = "探索艾澤拉斯上的不同景點，並收集各種故事和照片。";
NARCI_PROJECT_NARCISSUS_SUMMARY = "沈浸式角色面板；妳最好的截圖助手。"

--Conversation--
L["Q1"] = "這是什麽？";
L["Q2"] = "這我知道。但是它為什麽這麽大？";
L["Q3"] = "這不好笑。我只想要個正常大小的提示。";
L["Q4"] = "很好。但我該怎麽禁用這個提示呢？";
L["Q5"] = "還有壹件事：妳能保證不再搞惡作劇了嗎？";
L["A1"] = "顯然這是壹個退出確認窗口。當妳嘗試按下快捷鍵來退出合影模式時它就會彈出來。";
L["A2"] = "哈哈哈，她也是這麽說的。";
L["A3"] = "好吧...好吧..."
L["A4"] = "打開偏好設定，然後選擇拍照模式標簽，妳就能看到這個選項啦。";