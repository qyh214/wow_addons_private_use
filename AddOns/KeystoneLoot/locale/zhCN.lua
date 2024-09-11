if (GetLocale() ~= 'zhCN') then
    return;
end

local AddonName, KeystoneLoot = ...;
local Translate = KeystoneLoot.Translate;


Translate['Left click: Open overview'] = '左键点击：打开概览';
Translate['Right click: Open settings'] = '右键点击：打开设置';
Translate['Enable Minimap Button'] = '启用小地图按钮';
Translate['Enable Loot Reminder'] = '启用拾取专精提醒';
Translate['Favorites Show All Specializations'] = '显示所有专精的最爱装备';
Translate['%s (%s Season %d)'] = '%s（%s 第 %d 赛季）';
Translate['Veteran'] = '老兵';
Translate['Champion'] = '勇士';
Translate['Hero'] = '英雄';
Translate['Myth'] = '神话';
Translate['Revival Catalyst'] = '复苏化生台';
Translate['Correct loot specialization set?'] = '拾取专精是否正确？';
Translate['Show Item Level In Keystone Tooltip'] = '在史诗钥匙显示对应等级';
Translate['Highlighting'] = '高亮显示';
--Translate['No Stats'] = '';
