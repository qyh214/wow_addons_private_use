if (GetLocale() ~= 'zhTW') then
    return;
end

local AddonName, KeystoneLoot = ...;
local Translate = KeystoneLoot.Translate;


Translate['Left click: Open overview'] = '左鍵點擊：開啟概覽';
Translate['Right click: Open settings'] = '右鍵點擊：開啟設定';
Translate['Enable Minimap Button'] = '啟用小地圖按鈕';
Translate['Enable Loot Reminder'] = '啟用戰利品專精提醒';
Translate['Favorites Show All Specializations'] = '顯示所有專精的最愛裝備';
Translate['%s (%s Season %d)'] = '%s（%s 第 %d 賽季）';
Translate['Veteran'] = '精兵';    -- 探險者 Explorer 冒險者 Adventurer
Translate['Champion'] = '勇士';
Translate['Hero'] = '英雄';
Translate['Myth'] = '史詩';
Translate['Revival Catalyst'] = '重生育籃';
Translate['Correct loot specialization set?'] = '戰利品專精的設定是否正確？';
Translate['Show Item Level In Keystone Tooltip'] = '在傳奇鑰石顯示對應等級';
Translate['Highlighting'] = '高亮顯示';
--Translate['No Stats'] = '';
