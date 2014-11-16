--[[--------------------------------------------------------------------
	Grid
	Compact party and raid unit frames.
	Copyright (c) 2006-2014 Kyle Smith (Pastamancer), Phanx
	All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info5747-Grid.html
	http://www.wowace.com/addons/grid/
	http://www.curse.com/addons/wow/grid
------------------------------------------------------------------------
	GridLocale-koKR.lua
	Korean localization
	Contributors: 7destiny, Sayclub
----------------------------------------------------------------------]]

if GetLocale() ~= "koKR" then return end

local _, Grid = ...
local L = { }
Grid.L = L

------------------------------------------------------------------------
--	GridCore

L["Debugging"] = "디버깅"
-- L["Debugging messages help developers or testers see what is happening inside Grid in real time. Regular users should leave debugging turned off except when troubleshooting a problem for a bug report."] = ""
L["Enable debugging messages for the %s module."] = "%s 모듈에 대한 디버깅 메시지를 사용합니다." -- Needs review
L["General"] = "일반" -- Needs review
L["Module debugging menu."] = "모듈 디버깅 메뉴를 설정합니다."
L["Open Grid's options in their own window, instead of the Interface Options window, when typing /grid or right-clicking on the minimap icon, DataBroker icon, or layout tab."] = "인터페이스 옵션 창 대신 Grid 옵션을 열기위해 /grid를 대화창에 입력하거나 미니맵 아이콘, DataBroker 아이콘 또는 배치 탭에 오른쪽 버튼을 클릭하세요." -- Needs review
L["Output Frame"] = "프레임 출력" -- Needs review
L["Right-Click for more options."] = "옵션 메뉴을 열려면 오른쪽 버튼을 클릭하십시오."
L["Show debugging messages in this frame."] = "이 프레임의 디버깅 메시지를 표시합니다." -- Needs review
L["Show minimap icon"] = "미니맵 아이콘 표시"
L["Show the Grid icon on the minimap. Note that some DataBroker display addons may hide the icon regardless of this setting."] = "미니맵에 Grid 아이콘을 표시합니다.  DataBroker 애드온 설정에 관계없이 아이콘을 숨길 수 있습니다."
L["Standalone options"] = "독립형 옵션" -- Needs review
L["Toggle debugging for %s."] = "%s|1을;를; 위해 디버깅을 사용합니다."

------------------------------------------------------------------------
--	GridFrame

L["Adjust the font outline."] = "글꼴 외각선을 조정합니다."
L["Adjust the font settings"] = "글꼴 설정을 조정합니다."
L["Adjust the font size."] = "글꼴 크기를 조정합니다."
L["Adjust the height of each unit's frame."] = "각 유닛의 창 높이를 조정합니다."
L["Adjust the size of the border indicators."] = "테두리 지시기의 크기를 조정합니다."
L["Adjust the size of the center icon."] = "중앙 아이콘의 크기를 조정합니다."
L["Adjust the size of the center icon's border."] = "중앙 아이콘의 테두리 크기를 조정합니다."
L["Adjust the size of the corner indicators."] = "모서리 지시기의 크기를 조정합니다."
L["Adjust the texture of each unit's frame."] = "각 유닛의 창 무늬를 조정합니다."
L["Adjust the width of each unit's frame."] = "각 유닛의 창 너비를 조정합니다."
L["Always"] = "항상"
L["Bar Options"] = "바 옵션"
L["Border"] = "테두리"
L["Border Size"] = "테두리 크기"
L["Bottom Left Corner"] = "좌측 하단 모서리"
L["Bottom Right Corner"] = "우측 하단 모서리"
L["Center Icon"] = "중앙 아이콘"
L["Center Text"] = "중앙 문자"
L["Center Text 2"] = "중앙 문자 2"
L["Center Text Length"] = "중앙 문자 길이"
L["Color the healing bar using the active status color instead of the health bar color."] = "생명력 바 색상 대신 활성 상태의 색상을 사용하여 치료 바 색상을 표시합니다."
L["Corner Size"] = "모서리 크기"
L["Darken the text color to match the inverted bar."] = "반대로 바에 맞춰 문자 색상을 어둡게합니다."
L["Enable Mouseover Highlight"] = "마우스오버 강조 사용"
L["Enable right-click menu"] = "오른쪽 클릭 메뉴 사용" -- Needs review
L["Enable %s"] = "%s|1을;를; 사용"
L["Enable %s indicator"] = "%s 지시기 사용"
L["Font"] = "글꼴"
L["Font Outline"] = "글꼴 외각선"
L["Font Shadow"] = "글꼴 그림자"
L["Font Size"] = "글꼴 크기"
L["Frame"] = "창"
L["Frame Alpha"] = "창 투명도"
L["Frame Height"] = "창 높이"
L["Frame Texture"] = "창 무늬"
L["Frame Width"] = "창 너비"
L["Healing Bar"] = "치유 바"
L["Healing Bar Opacity"] = "치유 바 투명도"
L["Healing Bar Uses Status Color"] = "치유 바 상태 색상 사용"
L["Health Bar"] = "생명력 바"
L["Health Bar Color"] = "생명력 바 색상"
L["Horizontal"] = "가로"
L["Icon Border Size"] = "아이콘 테두리 크기"
L["Icon Cooldown Frame"] = "아이콘 재사용 창"
L["Icon Options"] = "아이콘 옵션"
L["Icon Size"] = "아이콘 크기"
L["Icon Stack Text"] = "아이콘 중첩 문자"
L["Indicators"] = "지시기"
L["Invert Bar Color"] = "바 색상 반대로"
L["Invert Text Color"] = "문자 색상 반대로"
L["Make the healing bar use the status color instead of the health bar color."] = "치유 바 상태 색상 대신 생명력 색상을 사용합니다."
L["Never"] = "안함"
L["None"] = "없음"
L["Number of characters to show on Center Text indicator."] = "중앙 문자 지시기 위에 표시할 캐릭터의 숫자를 설정합니다."
L["OOC"] = "비전투"
L["Options for assigning statuses to indicators."] = "지시기를 위한 옵션을 설정합니다."
L["Options for GridFrame."] = "각 유닛 창의 표시를 위한 옵션을 설정합니다."
L["Options for %s indicator."] = "%s 지시기를 위한 옵션 설정합니다."
L["Options related to bar indicators."] = "바 지시기 관련 옵션을 설정합니다."
L["Options related to icon indicators."] = "아이콘 지시기 관련 옵션을 설정합니다."
L["Options related to text indicators."] = "문자 지시기 관련 옵션을 설정합니다."
L["Orientation of Frame"] = "프레임의 방향"
L["Orientation of Text"] = "문자의 방향"
L["Set frame orientation."] = "생명력 결손량의 프레임 방향을 설정합니다."
L["Set frame text orientation."] = "프레임 문자의 방향을 설정합니다."
L["Sets the opacity of the healing bar."] = "치유 바의 투명도를 설정합니다."
L["Show the standard unit menu when right-clicking on a frame."] = "창에 오른쪽 버튼을 클릭하면 기본 유닛 메뉴를 표시합니다." -- Needs review
L["Show Tooltip"] = "툴팁 표시"
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = "유닛 툴팁을 표시합니다. '항상', '안함' 또는 '비전투'을 선택합니다."
L["Statuses"] = "상태"
L["Swap foreground/background colors on bars."] = "바 위의 전경/배경 색상을 변경합니다."
L["Text Options"] = "문자 옵션"
L["Thick"] = "두껍게"
L["Thin"] = "얇게"
L["Throttle Updates"] = "조절판 업데이트"
L["Throttle updates on group changes. This option may cause delays in updating frames, so you should only enable it if you're experiencing temporary freezes or lockups when people join or leave your group."] = "그룹 변경에 대한 업데이트 시간(초)를 설정합니다."
L["Toggle center icon's cooldown frame."] = "중앙 아이콘에 재사용 창을 표시합니다."
L["Toggle center icon's stack count text."] = "중앙 아이콘에 중첩 갯수 문자를 표시합니다."
L["Toggle mouseover highlight."] = "마우스오버 강조를 사용합니다."
L["Toggle status display."] = "상태 표시 사용"
L["Toggle the font drop shadow effect."] = "글꼴에 그림자 효과를 사용합니다."
L["Toggle the %s indicator."] = "%s 지시기를 사용합니다."
L["Top Left Corner"] = "좌측 상단 모서리"
L["Top Right Corner"] = "우측 상단 모서리"
L["Vertical"] = "세로"

------------------------------------------------------------------------
--	GridLayout

L["10 Player Raid Layout"] = "10인 공격대 배치"
L["25 Player Raid Layout"] = "25인 공격대 배치"
L["40 Player Raid Layout"] = "40인 공격대 배치" -- Needs review
L["Adjust background color and alpha."] = "배경의 색상과 투명도를 조정합니다."
L["Adjust border color and alpha."] = "테두리의 색상과 투명도를 조정합니다."
L["Adjust frame padding."] = "창 패팅을 조정합니다."
L["Adjust frame spacing."] = "창 간격을 조정합니다."
L["Adjust Grid scale."] = "Grid의 크기를 조정합니다."
L["Adjust the extra spacing inside the layout frame, around the unit frames."] = "유닛 프레임 주위의 배치 창 안 여분의 간격을 조정합니다." -- Needs review
L["Adjust the spacing between individual unit frames."] = "유닛 프레임의 간격을 조정합니다." -- Needs review
L["Advanced"] = "고급"
L["Advanced options."] = "고급 옵션을 설정합니다."
L["Allows mouse click through the Grid Frame."] = "Grid 창을 통해 마우스 클릭을 허용합니다."
L["Alt-Click to permanantly hide this tab."] = "영구적으로 Alt-클릭으로 이 탭을 숨깁니다."
L["Arena Layout"] = "투기장 배치"
L["Background color"] = "배경 색상"
L["Background Texture"] = "배경 무늬" -- Needs review
L["Battleground Layout"] = "전장 배치"
L["Beast"] = "야수형"
L["Border color"] = "테두리 색상"
L["Border Inset"] = "테두리 삽입" -- Needs review
L["Border Size"] = "테두리 크기" -- Needs review
L["Border Texture"] = "테두리 무늬"
L["Bottom"] = "하단"
L["Bottom Left"] = "좌측 하단"
L["Bottom Right"] = "우측 하단"
L["By Creature Type"] = "창조물의 타입에 의해"
L["By Owner Class"] = "소환자의 직업에 의해"
L["Center"] = "중앙"
L["Choose the layout border texture."] = "배치 테두리의 무늬를 선택합니다."
L["Clamped to screen"] = "화면에 고정"
L["Class colors"] = "직업 색상"
L["Click through the Grid Frame"] = "Grid 창을 통해 클릭"
L["Color for %s."] = "%s 색상입니다."
L["Color of pet unit creature types."] = "소환수 유닛 타입 색상을 설정합니다."
L["Color of player unit classes."] = "플레이어들의 유닛 색상을 설정합니다."
L["Color of unknown units or pets."] = "알 수 없는 유닛이나 소환수의 색상을 설정합니다."
L["Color options for class and pets."] = "직업과 소환수의 색상 옵션을 설정합니다."
L["Colors"] = "색상"
L["Creature type colors"] = "소환수 타입 색상"
L["Demon"] = "악마형"
L["Dragonkin"] = "용족"
L["Drag this tab to move Grid."] = "Grid를 이동시키려면 이 탭을 드래그합니다."
L["Elemental"] = "정령"
L["Fallback colors"] = "대체 색상"
L["Flexible Raid Layout"] = "공격대 찾기 배치" -- Needs review
L["Frame lock"] = "창 잠금"
L["Frame Spacing"] = "창 간격" -- Needs review
L["Group Anchor"] = "그룹 위치"
L["Horizontal groups"] = "그룹 정렬"
L["Humanoid"] = "인간형"
L["Layout"] = "배치"
L["Layout Anchor"] = "배치 위치"
L["Layout Background"] = "배치 배경" -- Needs review
L["Layout Padding"] = "배치 간격" -- Needs review
L["Layouts"] = "배치" -- Needs review
L["Left"] = "좌측"
L["Lock Grid to hide this tab."] = "이 탭을 숨기려면 Grid를 잠급니다."
L["Locks/unlocks the grid for movement."] = "배치 창을 잠그거나 이동시킵니다."
L["Not specified"] = "알 수 없음"
L["Options for GridLayout."] = "배치 창과 그룹 배치를 위한 옵션을 설정합니다."
L["Padding"] = "패팅"
L["Party Layout"] = "파티 배치"
L["Pet color"] = "소환수 색상"
L["Pet coloring"] = "소환수 채색"
L["Reset Position"] = "위치 초기화"
L["Resets the layout frame's position and anchor."] = "배경 창의 위치와 앵커를 기본값으로 되돌립니다."
L["Right"] = "우측"
L["Scale"] = "크기"
L["Select which layout to use when in a 10 player raid."] = "10인 공격대시 사용할 배치를 선택합니다."
L["Select which layout to use when in a 25 player raid."] = "25인 공격대시 사용할 배치를 선택합니다."
L["Select which layout to use when in a 40 player raid."] = "40인 공격대시 사용할 배치를 선택합니다." -- Needs review
L["Select which layout to use when in a battleground."] = "전장에서 사용할 배치를 선택합니다."
L["Select which layout to use when in a flexible raid."] = "공격대 찾기에서 사용할 배치를 선택합니다." -- Needs review
L["Select which layout to use when in an arena."] = "투기장에서 사용할 배치를 선택합니다."
L["Select which layout to use when in a party."] = "파티시 사용할 배치를 선택합니다."
L["Select which layout to use when not in a party."] = "솔로잉시 사용할 배치를 선택합니다."
L["Sets where Grid is anchored relative to the screen."] = "Grid의 화면 위치를 설정합니다."
L["Sets where groups are anchored relative to the layout frame."] = "그룹 배치 창의 위치를 설정합니다."
L["Set the coloring strategy of pet units."] = "소환수의 유닛 채색 방법을 설정합니다."
L["Set the color of pet units."] = "소환수 유닛의 색상을 설정합니다."
L["Show a tab for dragging when Grid is unlocked."] = "Grid가 잠금 해제일 때 드래그 탭을 표시합니다."
L["Show Frame"] = "창 표시"
L["Show tab"] = "탭 표시"
L["Solo Layout"] = "솔로잉 배치"
L["Spacing"] = "간격"
L["Switch between horizontal/vertical groups."] = "그룹 표시 방법을 가로/세로로 변경합니다."
L["The color of unknown pets."] = "알 수 없는 소환수의 색상을 설정합니다."
L["The color of unknown units."] = "알 수 없는 유닛의 색상을 설정합니다."
L["Toggle whether to permit movement out of screen."] = "화면 밖으로 창이 나가지 않도록 사용합니다."
L["Top"] = "상단"
L["Top Left"] = "좌측 상단"
L["Top Right"] = "우측 상단"
L["Undead"] = "언데드"
L["Unknown Pet"] = "알 수 없는 소환수"
L["Unknown Unit"] = "알 수 없는 유닛"
L["Use the 40 Player Raid layout when in a raid group outside of a raid instance, instead of choosing a layout based on the current Raid Difficulty setting."] = "현재 공격대 난이도 설정에 따른 배치를 선택하는 대신, 공격대 인스턴스가 아닌 외부 공격대 그룹일 경우 40인 배치를 사용합니다." -- Needs review
L["Using Fallback color"] = "대체 색상 사용"
L["World Raid as 40 Player"] = "40인 월드 공격대" -- Needs review

------------------------------------------------------------------------
--	GridLayoutLayouts

L["By Class 10"] = "10인 직업별"
L["By Class 10 w/Pets"] = "10인 직업별, 소환수"
L["By Class 25"] = "25인 직업별"
L["By Class 25 w/Pets"] = "25인 직업별, 소환수"
L["By Class 40"] = "40인 직업별" -- Needs review
L["By Class 40 w/Pets"] = "40인 직업별, 소환수" -- Needs review
L["By Group 10"] = "10인 공격대"
L["By Group 10 w/Pets"] = "10인 공격대, 소환수"
L["By Group 15"] = "15인 공격대"
L["By Group 15 w/Pets"] = "15인 공격대, 소환수"
L["By Group 25"] = "25인 공격대"
L["By Group 25 w/Pets"] = "25인 공격대, 소환수"
L["By Group 25 w/Tanks"] = "25인 공격대, 방어전담"
L["By Group 40"] = "40인 공격대"
L["By Group 40 w/Pets"] = "40인 공격대, 소환수"
L["By Group 5"] = "5인 공격대"
L["By Group 5 w/Pets"] = "5인 공격대, 소환수"
L["None"] = "없음"

------------------------------------------------------------------------
--	GridLDB

L["Click to toggle the frame lock."] = "창을 잠그려면 왼쪽 버튼을 클릭하십시오."

------------------------------------------------------------------------
--	GridRoster


------------------------------------------------------------------------
--	GridStatus

L["Color"] = "색상"
L["Color for %s"] = "%s 색상"
L["Enable"] = "사용"
L["Opacity"] = "투명도" -- Needs review
L["Options for %s."] = "%s|1을;를; 위한 옵션을 설정합니다."
L["Priority"] = "우선 순위"
L["Priority for %s"] = "%s|1을;를; 위한 우선 순위입니다."
L["Range filter"] = "거리 필터"
L["Reset class colors"] = "직업 색상 초기화"
L["Reset class colors to defaults."] = "직업 색상을 기본값으로 되돌립니다."
L["Show status only if the unit is in range."] = "유닛이 거리에 있을때 상태에 표시합니다."
L["Status"] = "상태"
L["Status: %s"] = "상태: %s"
L["Text"] = "문자"
L["Text to display on text indicators"] = "문자 지시기에 표시할 문자입니다."

------------------------------------------------------------------------
--	GridStatusAggro

L["Aggro"] = "어그로"
L["Aggro alert"] = "어그로 경고"
L["Aggro color"] = "어그로 색상"
L["Color for Aggro."] = "어그로일 때 색상입니다."
L["Color for High Threat."] = "위협 수준 높을 때 색상입니다."
L["Color for Tanking."] = "방어전담일 때 색상"
L["High"] = "높음"
L["High Threat color"] = "위협 수준 높음 색상"
L["Show detailed threat levels instead of simple aggro status."] = "상세한 위협 수준을 표시합니다."
L["Tank"] = "방어전담"
L["Tanking color"] = "방어전담 색상"
L["Threat"] = "위협 수준"

------------------------------------------------------------------------
--	GridStatusAuras

L["Add Buff"] = "새로운 버프 추가"
L["Add Debuff"] = "새로운 디버프 추가"
L["Auras"] = "효과"
L["<buff name>"] = "<버프 이름>"
L["Buff: %s"] = "버프: %s"
L["Change what information is shown by the status color."] = "상태 색상에 어떤 정보를 표시할지 변경합니다."
L["Change what information is shown by the status color and text."] = "상태 색상과 문자 표시 정보를 변경합니다."
L["Change what information is shown by the status text."] = "상태 문자에 어떤 정보를 표시할지 변경합니다."
L["Class Filter"] = "직업 필터"
L["Color"] = "색상"
L["Color to use when the %s is above the high count threshold values."] = "%s일때 높음 갯수 수치값이 있을때 사용할 색상을 설정합니다."
L["Color to use when the %s is between the low and high count threshold values."] = "%s일때 낮음 갯수 수치값이 있을때 사용할 색상을 설정합니다."
L["Color when %s is below the low threshold value."] = "%s일때 색상 낮음 수치값을 설정합니다."
L["Create a new buff status."] = "상태 모듈에 새로운 버프를 추가합니다."
L["Create a new debuff status."] = "상태 모듈에 새로운 디버프를 추가합니다."
L["Curse"] = "저주"
L["<debuff name>"] = "<디버프 이름>"
L["(De)buff name"] = "(디)버프 이름"
L["Debuff: %s"] = "디버프: %s"
L["Debuff type: %s"] = "디버프 형태: %s"
L["Disease"] = "질병"
L["Display status only if the buff is not active."] = "버프가 사라졌을때 상태에 표시합니다."
L["Display status only if the buff was cast by you."] = "자신이 시전한 버프만 상태에 표시합니다."
L["Ghost"] = "유령"
L["High color"] = "높음 색상"
L["High threshold"] = "높음 수치값"
L["Low color"] = "낮음 색상"
L["Low threshold"] = "낮음 수치값"
L["Magic"] = "마법"
L["Middle color"] = "중간 색상"
L["Pet"] = "소환수"
L["Poison"] = "독"
L["Present or missing"] = "존재하거나 사라짐"
L["Refresh interval"] = "새로 고침 간격"
L["Remove an existing buff or debuff status."] = "기존의 디버프를 상태 모듈에서 삭제합니다."
L["Remove Aura"] = "(디)버프 삭제"
L["Remove %s from the menu"] = "메뉴에서 %s|1을;를; 제거합니다."
L["%s colors"] = "%s 색상"
L["%s colors and threshold values."] = "%s 색상과 수치값을 조정합니다."
L["Show advanced options"] = "상세 옵션 표시" -- Needs review
L[ [=[Show advanced options for buff and debuff statuses.

Beginning users may wish to leave this disabled until you are more familiar with Grid, to avoid being overwhelmed by complicated options menus.]=] ] = [=[버프 및 디버프에 대한 상세한 옵션을 표시합니다.

복잡한 옵션 메뉴가 표시되며, Grid 설정에 익숙하지 않다면 해당 항목을 비활성화하세요."]=] -- Needs review
L["Show duration"] = "지속시간 표시"
L["Show if mine"] = "내것만 표시"
L["Show if missing"] = "사라질때 표시"
L["Show on pets and vehicles."] = "소환수와 탈것 탑승시 표시합니다."
L["Show on %s players."] = "%s 플레이어를 표시합니다."
L["Show status for the selected classes."] = "선택한 직업에 대한 상태를 표시합니다."
L["Show the time left to tenths of a second, instead of only whole seconds."] = "Show the time left to tenths of a second, instead of only whole seconds."
L["Show the time remaining, for use with the center icon cooldown."] = "중앙 아이콘 재사용 대기시간의 사용을 위해 남은 시간을 표시합니다."
L["Show time left to tenths"] = "10초전 남은 시간 표시"
L["%s is high when it is at or above this value."] = "%s의 높은 수치값을 조정합니다."
L["%s is low when it is at or below this value."] = "%s의 낮음 수치값을 조정합니다."
L["Stack count"] = "중첩 갯수"
L["Status Information"] = "상태 정보"
L["Text"] = "문자"
L["Time in seconds between each refresh of the status time left."] = "Time in seconds between each refresh of the status time left."
L["Time left"] = "남은 시간"

------------------------------------------------------------------------
--	GridStatusHeals

L["Heals"] = "치유"
L["Ignore heals cast by you."] = "자신의 치유 시전은 무시합니다."
L["Ignore Self"] = "자신 무시"
L["Incoming heals"] = "치유 받음"
L["Minimum Value"] = "최소값"
L["Only show incoming heals greater than this amount."] = "받는 치유가 이 값보다 클 경우만 표시합니다."

------------------------------------------------------------------------
--	GridStatusHealth

L["Color deficit based on class."] = "직업에 기준을 둔 결손 색상을 사용합니다."
L["Color health based on class."] = "직업에 기준을 둔 생명력 색상을 사용합니다."
L["DEAD"] = "죽음"
L["Death warning"] = "죽음 경고"
L["FD"] = "죽척"
L["Feign Death warning"] = "죽은척하기 경고"
L["Health"] = "생명력"
L["Health deficit"] = "결손 생명력"
L["Health threshold"] = "생명력 수치"
L["Low HP"] = "생명력 낮음"
L["Low HP threshold"] = "생명력 낮음 수치"
L["Low HP warning"] = "생명력 낮음 경고"
L["Offline"] = "오프라인"
L["Offline warning"] = "오프라인 경고"
L["Only show deficit above % damage."] = "결손량을 표시할 백분율을 설정합니다."
L["Set the HP % for the low HP warning."] = "생명력 낮음 경고를 위한 백분율을 설정합니다."
L["Show dead as full health"] = "죽은후 모든 생명력 표시"
L["Treat dead units as being full health."] = "죽은 플레이어들의 전체 생명력을 표시합니다."
L["Unit health"] = "유닛 생명력"
L["Use class color"] = "직업 색상 사용"

------------------------------------------------------------------------
--	GridStatusMana

L["Low Mana"] = "마나 낮음"
L["Low Mana warning"] = "마나 낮음 경고"
L["Mana"] = "마나"
L["Mana threshold"] = "마나 수치"
L["Set the percentage for the low mana warning."] = "마나 낮음 경고를 위한 백분율을 설정합니다."

------------------------------------------------------------------------
--	GridStatusName

L["Color by class"] = "직업별 색상"
L["Unit Name"] = "유닛 이름"

------------------------------------------------------------------------
--	GridStatusRange

L["Out of Range"] = "사정거리"
L["Range"] = "거리"
L["Range check frequency"] = "거리 체크 빈도"
L["Seconds between range checks"] = "거리 체크의 시간(초)를 설정합니다."

------------------------------------------------------------------------
--	GridStatusReadyCheck

L["?"] = "?"
L["AFK"] = "자리비움"
L["AFK color"] = "자리비움 색상"
L["Color for AFK."] = "자리비움 상태일 때 색상"
L["Color for Not Ready."] = "전투 준비가 되지 않았을 때 색상"
L["Color for Ready."] = "전투 준비가 되었을 때 색상"
L["Color for Waiting."] = "대기 상태일 때 색상"
L["Delay"] = "지연"
L["Not Ready color"] = "준비되지 않음 색상"
L["R"] = "R"
L["Ready Check"] = "전투 준비"
L["Ready color"] = "준비됨 색상"
L["Set the delay until ready check results are cleared."] = "전투 준비 체크 결과를 표시합니다."
L["Waiting color"] = "대기 색상"
L["X"] = "X"

------------------------------------------------------------------------
--	GridStatusResurrect

L["Casting color"] = "시전 색상" -- Needs review
L["Pending color"] = "보류 색상" -- Needs review
L["RES"] = "부활" -- Needs review
L["Resurrection"] = "부활" -- Needs review
L["Show the status until the resurrection is accepted or expires, instead of only while it is being cast."] = "부활이 수락될 때까지 상태 창에 표시합니다." -- Needs review
L["Show until used"] = "부활 때까지 표시" -- Needs review
L["Use this color for resurrections that are currently being cast."] = "현재 시전되는 부활에 이 색상을 사용합니다." -- Needs review
L["Use this color for resurrections that have finished casting and are waiting to be accepted."] = "시전이 완료되어 수락을 대기중인 부활에 이 색상을 사용합니다." -- Needs review

------------------------------------------------------------------------
--	GridStatusTarget

L["Target"] = "대상"
L["Your Target"] = "당신의 대상"

------------------------------------------------------------------------
--	GridStatusVehicle

L["Driving"] = "운전"
L["In Vehicle"] = "탈것"

------------------------------------------------------------------------
--	GridStatusVoiceComm

L["Talking"] = "대화중"
L["Voice Chat"] = "음성 대화"
