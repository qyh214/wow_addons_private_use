if (GetLocale() ~= 'koKR') then
    return;
end

local AddonName, KeystoneLoot = ...;
local Translate = KeystoneLoot.Translate;


Translate['Left click: Open overview'] = '왼쪽 클릭: 개요 열기';
Translate['Right click: Open settings'] = '오른쪽 클릭: 설정 열기';
Translate['Enable Minimap Button'] = '미니맵 버튼 활성화';
Translate['Enable Loot Reminder'] = '전리품 리마인더 활성화';
--Translate['Favorites Show All Specializations'] = '';
Translate['%s (%s Season %d)'] = '%s (%s 시즌 %d)';
Translate['Veteran'] = '노련가';
Translate['Champion'] = '챔피언';
Translate['Hero'] = '영웅';
Translate['Myth'] = '신화';
Translate['Revival Catalyst'] = '소생의 촉매';
Translate['Correct loot specialization set?'] = '올바른 전리품 전문화 설정?';
--Translate['Show Item Level In Keystone Tooltip'] = '';
Translate['Highlighting'] = '강조';
--Translate['No Stats'] = '';