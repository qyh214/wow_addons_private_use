local AddonName, KeystoneLoot = ...;

if (GetLocale() ~= "zhTW") then
    return;
end

local L = KeystoneLoot.L;

-- keystoneloot_frame.lua
L["%s (%s Season %d)"] = "%s（%s 第 %d 賽季）";

-- itemlevel_dropdown.lua
L["Veteran"] = "精兵";
L["Champion"] = "勇士";
L["Hero"] = "英雄";

-- upgrade_tracks.lua
L["Myth"] = "神話";

-- catalyst_frame.lua
L["The Catalyst"] = "催化器";

-- settings_dropdown.lua
L["Minimap button"] = "小地圖按鈕";
L["Item level in keystone tooltip"] = "在傳奇鑰石顯示對應等級";
L["Favorite in item tooltip"] = "在物品提示中顯示最愛";
L["Loot reminder (dungeons)"] = "戰利品提醒（地城）";
L["Highlighting"] = "高亮顯示";
L["No stats"] = "無屬性";
L["Export..."] = "匯出...";
L["Import..."] = "匯入...";
L["Export favorites of %s"] = "匯出 %s 的最愛";
L["Import favorites for %s\nPaste import string here:"] = "匯入 %s 的最愛\n在此貼上匯入字串：";
L["Merge"] = "合併";
L["Overwrite"] = "覆蓋";
L["%d |4favorite:favorites; imported%s."] = "成功匯入 %d 件物品%s。";
L[" (overwritten)"] = "（已覆蓋）";
L["Import failed - %s"] = "匯入失敗 - %s";
L["Some specs were skipped - import string belongs to a different class."] = "部分專精已略過 - 匯入字串屬於其他職業。";
L["Manage characters"] = "管理角色";
L["Hidden"] = "已隱藏";
L["Delete..."] = "刪除...";
L["Delete all data for %s?"] = "刪除 %s 的所有資料？";
L["Cannot delete the currently logged in character."] = "無法刪除目前登入的角色。";
L["This character is hidden."] = "此角色已被隱藏。";
L["Wide mode"] = "寬屏模式";

-- favorites.lua
L["No favorites found"] = "未找到最愛";
L["Invalid import string."] = "無效的匯入字串。";
L["No character selected."] = "未選擇角色。";
L["No valid items found."] = "未找到有效物品。";

-- icon_button.lua / favorites.lua
L["Set Favorite"] = "設定最愛";
L["Nice to have"] = "有更好";
L["Must have"] = "必須取得";
L["Best in Slot"] = "最佳裝備";

-- loot_reminder_frame.lua
L["Correct loot specialization set?"] = "戰利品專精的設定是否正確？";
L["+1 item dropping for all specs."] = "+1 件物品對所有專精掉落。";
L["+%d items dropping for all specs."] = "+%d 件物品對所有專精掉落。";
L["%s has a smaller loot pool than %s"] = "%s的戰利品池比%s更小。";

-- minimap_button.lua
L["Left click: Open overview"] = "左鍵點擊：開啟概覽";
