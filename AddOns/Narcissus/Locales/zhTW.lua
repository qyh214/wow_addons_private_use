if not(GetLocale() == "zhTW") then
    return
end

local L = Narci.L

NARCI_GRADIENT = "|cffA236EFN|cff9448F1a|cff865BF2r|cff786DF4c|cff6A80F6i|cff5D92F7s|cff4FA4F9s|cff41B7FAu|cff33C9FCs|r 角色資訊"
MYMOG_GRADIENT = "|cffA236EFM|cff9448F1y |cff865BF2T|cff786DF4r|cff6A80F6a|cff5D92F7n|cff4FA4F9s|cff41B7FAm|cff33C9FCo|cff32c9fbg|r"
NARCI_TRANSLATOR_INFO = "Translated by gaspy10";

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
NARCI_LAYOUT_TEXTS_ONLY = "只有文字";
NARCI_LAYOUT_TEXTS_MODEL = "文字和模組";
NARCI_COPY_TEXTS = "複製文字";
NARCI_SYNTAX = "句法";
NARCI_SYNTAX_PLAIN_TEXT = "純文字";
NARCI_EXPORT_INCLUDES = "同時導出...";
NARCI_ITEM_ID = "物品ID";
NARCI_DOUBLE_TAP = "按兩下";
NARCI_OVERRIDE = "是否覆蓋";
NARCI_INVALID_KEY = "無效的值";
NARCI_MINIMAP_BUTTON = "小地圖按鈕";
NARCI_SHORTCUTS = "快捷鍵";
NARCI_FILTERS = "濾鏡";
NARCI_GRAIN_EFFECT = "顆粒效果";
NARCI_PREFERENCE = "偏好設定-PH";

--Others need to be localized--
L["Level"] = "等級";
L["Resource"] = "能量";
L["Camera has been reset."] = "鏡頭已經重置。"
L["Minimap button has been hidden. You may type /Narci minimap to re-enable it."] = "小地圖按鈕已經隱藏，可以輸入 /Narci minimap 來重新啟用。"
L["Minimap button has been re-enabled."] = "小地圖按鈕已經重新啟用。"
