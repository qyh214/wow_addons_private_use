-- Populate DF_AllLocales["koKR"] so Core.lua's ADDON_LOADED handler
-- can apply this locale's translations as an overlay if the user's
-- languageOverride selects it. No AceLocale interaction here — the
-- overlay step happens once the SavedVariable is actually populated,
-- which is only guaranteed at ADDON_LOADED time (not file-scope).
DF_AllLocales = DF_AllLocales or {}
DF_AllLocales.koKR = {}
local L = DF_AllLocales.koKR
L["    Show Frame Glow"] = "프레임 반짝임 표시"
L["    Show ZZZ Icon"] = "ZZZ 아이콘 표시"
L["— click to edit"] = "— 클릭으로 수정"
L[" indicator"] = "표시기"
L[" indicators"] = "표시기"
L["⚠ Note: Click-through icons will not show tooltips."] = "⚠ 알림: 클릭 방지된 아이콘에는 툴팁이 표시되지 않습니다."
L["\"%s\" will be overwritten."] = "“%s”|1으로;로; 덮어씌웁니다."
L["%d - %d players"] = "%d - %d명"
L["%d binds"] = "%d개 등록"
L["%d blacklisted"] = "블랙리스트 %d개"
L["%d override"] = "%d개 설정 변경"
L["%d overrides"] = "%d개 설정 변경"
L["%d players"] = "%d명"
L["%d-%d players"] = "%d-%d명"
L["%s (Copy)"] = "%s (복사본)"
L["%s (currently %s)"] = "%s (현재 프로필 %s)"
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = [=[%s|1이;가; 감지되었습니다.
어떤 클릭 시전 애드온을 사용할까요?]=]
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = [=[%s|1이;가; 감지되었습니다.
어떤 클릭 시전 애드온을 사용할까요?]=]
L["%s settings reset to defaults."] = "%s의 설정이 기본값으로 초기화됩니다."
L["%sGlobal: 80%s %s— Setting matches global, no override stored%s"] = "%s전역 설정: 80%s %s— 설정을 전역 설정에 일치시키며, 변경한 설정값은 저장 안함%s"
L["%sModified%s %s— Setting differs from global. Click%s %sreset%s %sto revert.%s"] = "%s설정 조정%s %s— 전역 설정과 다르게 설정합니다. 초기화를%s %s클릭하면%s %s원래대로 돌아갑니다.%s"
L["(none)"] = "(없음)"
L["(offline)"] = "(오프라인)"
L["(skipped)"] = "(생략)"
L["[Linked]"] = "[연결됨]"
L["[Override]"] = "[설정 변경]"
L["[Unassigned]"] = "[미할당]"
L["+ Add"] = "+ 추가"
L["+ Add aura"] = "+ 오라 추가"
L["+ Add Indicator"] = "+ 표시기 추가"
L["+ Add Layout"] = "+ 레이아웃 추가"
L["+ Add Option"] = "+ 옵션 추가"
L["+ Add Step"] = "+ 단계 추가"
L["+ Add Trigger"] = "+ 트리거 추가"
L["+ Create Group"] = "+ 그룹 생성"
L["+ New"] = "+ 새로 추가"
L["+ New Wizard"] = "+ 새 설정 마법사"
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = [=[• 특정 버프나 디버프 표시에 문제가 있나요?
• 이 마법사는 올바른 오라 설정을 선택하는 데 도움을 줍니다.]=]
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = [=[• 특정 버프나 디버프 표시에 문제가 있나요?
• 이 마법사는 올바른 오라 설정을 선택하는 데 도움을 줍니다.]=]
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = [=[• 이름 텍스트
• 생명력 텍스트
• 상태 텍스트 (죽음/오프라인)
• 버프 중첩 및 지속시간
• 디버프 중첩 및 지속시간
• 소환수 프레임 텍스트
• 단일 대상 주문 지속시간
• 생존기 아이콘 지속시간
• 상태 아이콘 텍스트 (부활, 소환 등)
• 파티 레이블 (공격대)]=]
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = [=[• 이름 텍스트
• 생명력 텍스트
• 상태 텍스트 (죽음/오프라인)
• 버프 중첩 및 지속시간
• 디버프 중첩 및 지속시간
• 소환수 프레임 텍스트
• 단일 대상 주문 지속시간
• 생존기 아이콘 지속시간
• 상태 아이콘 텍스트 (부활, 소환 등)
• 파티 레이블 (공격대)]=]
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = [=[• 권장 기본값은 대부분의 플레이어에게 잘 작동합니다
• 수동으로 모든 필터 옵션을 미세 조정할 수 있습니다]=]
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = [=[• 권장 기본값은 대부분의 플레이어에게 잘 작동합니다
• 수동으로 모든 필터 옵션을 미세 조정할 수 있습니다]=]
L["0=Auto, Higher=On top of more elements"] = "0=자동, 높은 값=높을수록 더 많은 요소의 위에 표시"
L["1"] = "1"
L["1 = High"] = "1 = 높음"
L["1. Open ElvUI config with %s/ec%s"] = "1. %s/ec%s로 ElvUI 설정을 엽니다"
L["10 = Low"] = "10 = 낮음"
L["2. Go to %sUnitFrames%s (left sidebar)"] = "2. %s유닛프레임%s으로 이동합니다 (왼쪽 사이드바)"
L["20 players (fixed)"] = "20인 (고정)"
L["3. Click %sGeneral%s at the top"] = "3. 상단의 %s일반%s을 클릭합니다"
L["4. Scroll down to %sDisabled Blizzard Frames%s"] = "4. %s비활성화된 블리자드 프레임%s 옵션까지 스크롤을 내립니다"
L["5. Under %sGroup Units%s, uncheck %sParty%s and %sRaid%s"] = "5. %s그룹별 프레임%s에서 %s파티%s와 %s공격대%s 체크를 끕니다"
L["6. Click the reload button when prompted"] = "6. 팝업 창이 나오면 리로드 버튼을 클릭합니다"
L["A layout with this name already exists in %s"] = "%s에 이미 있는 레이아웃 이름입니다"
L["a placed indicator to remove it from the frame"] = "으로 배치된 표시기를 프레임에서 제거합니다"
L["a placed indicator to reposition it on the frame"] = "로 프레임에 배치된 표시기의 위치를 조정합니다"
L["A profile with this name already exists"] = "이미 같은 이름의 프로필이 있습니다"
L["A to Z"] = "이름순"
L["Abbreviate (K/M)"] = "숫자 축약 (K/M)"
L["Above Health Bar"] = "생명력 바 위"
L["Above Owner"] = "소환수 주인 위"
L["Above Party"] = "파티 위"
L["Above Raid"] = "공격대 위"
L["Absorb Shield"] = "보호막"
L["Absorbs"] = "흡수 효과"
L["Actions"] = "작업"
L["Active"] = "활성화"
L["Active Bindings"] = "사용 중인 단축키"
L["Active Bindings (%d)"] = "사용 중인 단축키 (%d)"
L["ACTIVE INDICATORS"] = "사용 중인 표시기"
L["Active:"] = "활성화:"
L["Actually, disable it"] = "비활성화 하겠습니다."
L["Add"] = "추가"
L["Add #showtooltip"] = "#showtooltip 추가"
L["Add /stopcasting"] = "/stopcasting 추가"
L["Add Layout"] = "레이아웃 추가"
L["Add New Binding"] = "단축키 추가"
L["Add Offline Player"] = "오프라인 플레이어 추가"
L[ [=[Add players from the roster
or use quick add buttons]=] ] = [=[명단에서 공대원을 추가하거나
빠른 추가 버튼을 사용하세요]=]
L[ [=[Add players from the roster
or use quick add buttons]=] ] = [=[명단에서 공대원을 추가하거나
빠른 추가 버튼을 사용하세요]=]
L["Additive (ADD)"] = "가산 (ADD)"
L["Advanced"] = "고급"
L["Affected Elements"] = "적용되는 요소"
L["AFK"] = "자리 비움"
L["AFK Icon"] = "자리 비움 아이콘"
L["Aggro Highlight"] = "어그로 강조"
L["Aggro Settings"] = "어그로 설정"
L["Alert if anyone is missing the buff"] = "버프가 없는 사람이 있으면 경고"
L["Alert only if nobody has the buff"] = "전원 버프가 없을 때만 경고"
L["Alert When Expiring"] = "끝나갈 때 경고"
L["All"] = "모두"
L["ALL (AND)"] = "모두 (AND)"
L["All Buffs"] = "모든 버프"
L["All Debuffs"] = "모든 디버프"
L["All Dispellable"] = "모든 해제 가능 디버프"
L["All players in a unified grid. Sorting applies raid-wide."] = "통합된 격자 프레임에 모든 플레이어를 넣습니다. 공격대 전체에 정렬이 적용됩니다."
L["ALL triggers must be active"] = "모든 트리거가 활성화되야 합니다"
L["Alpha"] = "불투명도"
L["Alphabetical"] = "이름순"
L["Alphabetical (within class/role)"] = "이름순 (직업/역할 기준)"
L["Always"] = "항상"
L["Always First"] = "항상 맨 앞에"
L["Always Green"] = "항상 녹색으로"
L["Always Last"] = "항상 맨 뒤에"
L["an indicator on the frame to expand its settings"] = "으로 프레임의 표시기 설정을 엽니다"
L["Anchor"] = "고정 지점"
L["Anchor Point"] = "고정 지점"
L["Anchor Position"] = "고정 위치"
L["Anchor To"] = "고정 대상"
L["Animated Border"] = "움직이는 테두리"
L["ANY (OR)"] = "아무거나 (OR)"
L["Any Target"] = "모든 대상"
L["ANY trigger activates the effect"] = "어느 트리거든 이 효과를 활성화합니다"
L["Appearance"] = "외형"
L["Apply"] = "적용"
L["Apply to All"] = "모두 적용"
L["Apply to Frames:"] = "프레임에 적용:"
L["Arcane Intellect (Mage)"] = "신비한 지능 (마법사)"
L["are secret-tracked"] = "|1이;가; 비밀 값 추적 대상입니다"
L["Are you sure?"] = "확실한가요?"
L["Arena"] = "투기장"
L["Arena header will show using raid1-5 unit IDs"] = "투기장 헤더는 raid1-5 유닛 ID를 사용해 표시됩니다"
L["Arena mode %sDISABLED%s"] = "투기장 모드 %s비활성화%s"
L["Arena mode %sENABLED%s for testing"] = "투기장 모드 %s활성화%s (테스트용)"
L["Arrange Groups In"] = "그룹 배열 방향:"
L["Arrange In"] = "배열 방향"
L["Arrange Players In"] = "플레이어 배열 방향"
L["Attach the handle to the container, the first visible unit, or the last visible unit."] = "핸들을 컨테이너, 첫번째 유닛이나 마지막 유닛에 붙입니다."
L["Attach To"] = "붙일 위치"
L["Attached + Overflow"] = "붙임 + 넘침"
L["Attached to Health"] = "생명력 바에 붙임"
L["Attached to Owner"] = "소환수 주인 유닛에 붙임"
L["Aura Blacklist"] = "오라 블랙리스트"
L["Aura Data Source"] = "오라 데이터 소스"
L["Aura Designer"] = "오라 디자이너"
L["Aura Designer Alpha"] = "오라 디자이너 불투명도"
L["Aura Designer is active alongside Buffs."] = "오라 디자이너가 버프와 같이 활성화되어 있습니다."
L["Aura Designer is disabled"] = "오라 디자이너가 비활성화 되었습니다."
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = [=[오라 디자이너에선 힐러 전문화와 증강 기원사를 지원합니다.
위의 드롭다운 메뉴에서 전문화를 직접 선택해 표시기를 미리 설정해 둘 수 있습니다.]=]
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = [=[오라 디자이너에선 힐러 전문화와 증강 기원사를 지원합니다.
위의 드롭다운 메뉴에서 전문화를 직접 선택해 표시기를 미리 설정해 둘 수 있습니다.]=]
L["Aura Filter Setup"] = "오라 필터 설정"
L["Aura Filters"] = "오라 필터"
L["Auras"] = "오라"
L["Auras Alpha"] = "오라 불투명도"
L["Auto (%s)"] = "자동 (%s)"
L["Auto (detect class)"] = "자동 (직업 감지)"
L["Auto (detect spec)"] = "자동 (전문화 감지)"
L["Auto (detect)"] = "자동 (감지)"
L["Auto (Spec Default)"] = "자동 (전문화 기본값)"
L["Auto Layouts"] = "자동 레이아웃"
L["Auto Layouts is a Raid-only feature. Switch to Raid mode to configure automatic layout switching based on content type and group size."] = "자동 레이아웃은 공격대 전용 기능입니다. 공격대 모드로 전환하면 콘텐츠 유형과 그룹 크기별로 자동 레이아웃 전환을 설정할 수 있습니다."
L["Auto Layouts module not loaded."] = "자동 레이아웃 모듈이 로드되지 않았습니다."
L["Auto-add DPS"] = "딜러 자동 추가"
L["Auto-add Healers"] = "힐러 자동 추가"
L["Auto-add Tanks"] = "탱커 자동 추가"
L["Auto-create disabled"] = "자동 생성 비활성화됨"
L["Auto-Create Profiles"] = "프로필 자동 생성"
L["Auto-create profiles for loadouts"] = "특성 구성마다 별도의 프로필 자동 생성"
L["Auto-detect (your class's buff)"] = "자동 감지 (내 직업의 버프)"
L["Auto-Fit Border to Frame Size"] = "테두리를 프레임 크기에 자동으로 맞춤"
L["Automatically add players by role when they join your group."] = "그룹에 참가할 때 역할별로 플레이어를 자동으로 추가합니다."
L["Automatically detects player-dispellable debuffs via the RAID_PLAYER_DISPELLABLE filter. Configure the overlay on the Dispel Overlay page."] = "RAID_PLAYER_DISPELLABLE 필터를 통해 플레이어가 해제 가능한 디버프를 자동으로 감지합니다. 해제 오버레이 페이지에서 오버레이를 설정하세요."
L["Auto-Populate"] = "자동 추가"
L["Auto-profile \"%s\" activated (%s, %d players)"] = "자동 프로필 \"%s\" 활성화됨 (%s, %d명)"
L["Auto-profile deactivated (profile deleted)"] = "자동 프로필 비활성화됨 (프로필 삭제됨)"
L["Auto-profile deactivated, using global settings"] = "자동 프로필 비활성화됨. 전역 설정 사용 중"
L["Auto-Switch by Spec"] = "전문화별 자동 전환"
L["Auto-switched to profile: %s"] = "프로필 자동 전환됨: %s"
L["Auto-switching disabled"] = "자동 전환 비활성화됨"
L["Available Profiles"] = "사용 가능한 프로필"
L["A-Z"] = "이름순"
L["Back"] = "뒤로"
L["Back to List"] = "목록으로 돌아가기"
L["Background"] = "배경"
L["Background Alpha"] = "배경 불투명도"
L["Background Color"] = "배경색"
L["Background Fill"] = "배경 채우기"
L["Background Mode"] = "배경 모드"
L["Background Only"] = "배경에만"
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = [=[배경에만: 일반 단색 배경
잃은 생명력에만: 잃은 생명력 부분에 색깔 있는 바 표시
모두: 모두 표시]=]
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = [=[배경에만: 일반 단색 배경
잃은 생명력에만: 잃은 생명력 부분에 색깔 있는 바 표시
모두: 모두 표시]=]
L["Background Texture"] = "배경 텍스처"
L["Bar"] = "바"
L["Bar Color"] = "바 색상"
L["Bar Texture"] = "바 텍스처"
L["Bars"] = "바"
L["Battle Shout (Warrior)"] = "전투의 함성 (전사)"
L["Battlegrounds"] = "전장"
L["Before You Enable"] = "활성화하기 전"
L["Below Health Bar"] = "생명력 바 아래쪽"
L["Below Owner"] = "소환수 주인 아래쪽"
L["Below Party"] = "파티 아래쪽"
L["Below Raid"] = "공격대 아래쪽"
L["Big Defensives"] = "큰 생존기"
L["Bind Action"] = "동작 등록"
L["Bind Item"] = "아이템 등록"
L["Bind Spell"] = "주문 등록"
L["Binding Tooltips"] = "단축키 툴팁"
L["Binding:"] = "마우스 동작:"
L["Bindings only cast their assigned spell"] = "등록한 주문만 시전"
L["BINDS"] = "단축키"
L["Bleed / Enrage"] = "출혈 / 격노"
L["Blend %"] = "혼합률"
L["Blend Mode"] = "혼합 모드"
L["Blessing of the Bronze (Evoker)"] = "청동용군단의 축복 (기원사)"
L["Blizzard"] = "블리자드"
L["Blizzard (Default)"] = "블리자드 (기본값)"
L["Blizzard Click-Casting"] = "블리자드 기본 클릭 시전"
L["Blizzard Frame Settings"] = "블리자드 기본 프레임 설정"
L["Blizzard Frames"] = "블리자드 기본 프레임"
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = [=[블리자드:
• 블리자드 기본 프레임의 버프/디버프를 복제
• 블리자드 기본 공격대 설정을 제대로 해놔야 함
• 대규모 그룹에서 성능 부하가 좀 더 있음

API 직접 사용:
• 프레임에 표시되는 것을 직접 제어 가능
• 일부 필터에 특정 버프/디버프가 빠질 수 있음
• 원하지 않는 것이 표시될 수 있음
• 최상의 결과를 위해 세밀한 조정이 가능]=]
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = [=[블리자드:
• 블리자드 기본 프레임의 버프/디버프를 복제
• 블리자드 기본 공격대 설정을 제대로 해놔야 함
• 대규모 그룹에서 성능 부하가 좀 더 있음

API 직접 사용:
• 프레임에 표시되는 것을 직접 제어 가능
• 일부 필터에 특정 버프/디버프가 빠질 수 있음
• 원하지 않는 것이 표시될 수 있음
• 최상의 결과를 위해 세밀한 조정이 가능]=]
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = [=[블리자드 기본 클릭 시전이 DandersFrames의 클릭 시전 설정과 충돌할 수 있습니다.

DandersFrames 단축키를 사용하는 프레임에선 블리자드 클릭 시전 설정 해제를 권장합니다.]=]
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = [=[블리자드 기본 클릭 시전이 DandersFrames의 클릭 시전 설정과 충돌할 수 있습니다.

DandersFrames 단축키를 사용하는 프레임에선 블리자드 클릭 시전 설정 해제를 권장합니다.]=]
L["Border"] = "테두리"
L["Border Color"] = "테두리 색상"
L["Border Inset"] = "테두리 삽입"
L["Border Mode:"] = "테두리 모드:"
L["Border Opacity"] = "테두리 불투명도"
L["Border Scale"] = "테두리 크기 비율"
L["Border Size"] = "테두리 크기"
L["Border Thickness"] = "테두리 두께"
L["Boss Debuffs"] = "보스 디버프"
L["Boss Debuffs (Private Auras) are special debuffs that Blizzard hides from addons."] = "보스 디버프(프라이빗 오라)는 블리자드가 애드온으로부터 숨기는 특수한 디버프입니다."
L["Both"] = "둘 다"
L["Bottom"] = "하단"
L["Bottom Edge"] = "아랫면"
L["Bottom Left"] = "좌측 하단"
L["Bottom Right"] = "우측 하단"
L["Bottom to Top"] = "아래에서 위로"
L["Bounce"] = "바운스"
L["Bound: %s"] = "마우스 동작: %s"
L["Branch"] = "분기"
L["Branching Rules"] = "분기 생성 규칙"
L["BUFF BLACKLIST"] = "버프 블랙리스트"
L["Buff Filters"] = "버프 필터"
L["Buff Icon"] = "버프 아이콘"
L["Buff Icons"] = "버프 아이콘"
L["Buff Icons Click-Through"] = "버프 아이콘 클릭 방지"
L["Buff Tooltips"] = "버프 툴팁"
L["Buffs"] = "버프"
L["Buffs are disabled. Aura Designer is managing your auras."] = "버프가 비활성화되었습니다. 오라 디자이너에서 오라를 관리중입니다."
L["Buffs flagged by Blizzard to show up on raid frames."] = "블리자드에서 공격대 프레임에 표시되도록 지정한 버프입니다."
L["Buffs flagged to show on raid frames during combat, such as self-cast HoTs."] = "전투 중 공격대 프레임에 표시하도록 지정된 버프로 내가 시전한 도트힐 같은 것들입니다."
L["Buffs that can be right-click cancelled."] = "우클릭으로 지울 수 있는 버프입니다."
L["Buffs that cannot be cancelled by the player."] = "플레이어가 지울 수 없는 버프입니다."
L["Buffs to Check (Manual Mode)"] = "감시할 버프 (수동 모드)"
L["Building: "] = "생성 중:"
L["Built-in Wizards"] = "내장 설정 마법사"
L["By Health %"] = "생명력 %"
L["Cancel"] = "취소"
L["Cancel Fade on Dispellable Debuff"] = "해제 가능 디버프에 흐려짐 효과 취소"
L["Cancelable"] = "취소 가능"
L["Cannot delete Default profile."] = "기본 프로필은 삭제할 수 없습니다."
L["Cannot disable test mode while frames are unlocked. Lock frames first."] = "프레임이 잠금 해제 상태일 땐 테스트 모드를 비활성화 할 수 없습니다. 먼저 프레임을 잠그세요."
L["Cannot Edit"] = "수정 불가"
L["Cannot enter test mode during combat."] = "전투 중에는 테스트 모드로 진입할 수 없습니다."
L["Cannot toggle arena mode during combat"] = "전투 중에는 투기장 모드를 켜고 끌 수 없습니다."
L["Cannot toggle test mode during combat."] = "전투 중에는 테스트 모드를 켜고 끌 수 없습니다."
L["Cannot unlock - container doesn't exist!"] = "잠금 해제 불가 - 컨테이너가 존재하지 않습니다!"
L["Cannot unlock - failed to create mover frame!"] = "잠금 해제 불가 - 무버 프레임 생성에 실패했습니다!"
L["Cannot unlock frames during combat."] = "전투 중에는 프레임을 잠금 해제할 수 없습니다."
L["Cannot use this action in combat."] = "전투 중에는 이 동작을 사용할 수 없습니다."
L["Cast on DOWN"] = "DOWN에 시전"
L["Categories"] = "범주"
L["Category Filters"] = "카테고리 필터"
L["CC effects like stuns, roots, and incapacitates."] = "스턴, 이동 불가, 행동 불가 같은 메즈 효과입니다."
L["Center"] = "가운데"
L["Center (Horizontal)"] = "가운데 (가로)"
L["Center (Vertical)"] = "가운데 (세로)"
L["Center of Group"] = "그룹 중앙"
L["Character"] = "캐릭터"
L["Character Import"] = "캐릭터 가져오기"
L["Choose how DandersFrames reads aura data for buffs, debuffs, defensives, and dispel detection."] = "DandersFrames가 버프, 디버프, 생존기 및 해제 감지용 오라 데이터를 읽을 방법을 선택하세요."
L["Choose Icon"] = "아이콘 선택"
L["Choose whether to enable the frame border overlay."] = "프레임 테두리 오버레이 활성화 상태를 선택하세요."
L["Choose which groups to display."] = "표시할 그룹을 선택하세요."
L["Clamp Mode"] = "최대치 고정 모드"
L["Class"] = "직업"
L["Class Color"] = "직업 색상"
L["Class Color Alpha"] = "직업 색상 불투명도"
L["Class Colors"] = "직업 색상"
L["Class Filter"] = "직업 필터"
L["Class Power"] = "직업 자원"
L["Class Power Pips"] = "직업 자원 버블"
L["Class Priority"] = "직업 우선순위"
L["Clear"] = "초기화"
L["Clear All"] = "모두 삭제"
L["Clear All Bindings"] = "모든 단축키 초기화"
L["Clear Blizzard Bindings"] = "블리자드 클릭 시전 설정 해제"
L["Clear Log"] = "기록 지우기"
L["Click"] = "클릭"
L["Click %sEdit Settings%s on a profile to customise it. This takes you to the settings tabs with an editing banner at the top. While editing, any setting you change is stored as an override for that profile only."] = "프로필을 커스터마이징 하려면 프로필의 %s설정 편집%s을 클릭하세요. 설정 탭으로 이동하면 상단에 편집 배너가 표시됩니다. 편집 과정에서 변경한 설정은 해당 프로필에만 선택적으로 저장됩니다."
L["Click %sExit Editing%s when done. Your overrides are saved to the profile. If you change a setting back to match global, the override is automatically removed."] = "완료되면 %s편집 종료%s를 클릭하세요. 변경한 설정이 해당 프로필에 저장됩니다. 전역 설정과 일치하도록 설정을 되돌릴 경우엔 변경했던 설정들이 자동으로 제거됩니다."
L["Click a color swatch to open the color picker. These settings are shared across party and raid frames."] = "표준 색상을 클릭하면 색상 선택기가 열립니다. 이 설정은 파티와 공격대 프레임 모두 공유됩니다."
L["Click a setting to link it to your wizard"] = "설정 마법사에 연결할 설정 클릭"
L["Click item slot to bind"] = "아이템을 클릭하면 등록"
L["Click macro to bind"] = "매크로를 클릭하면 등록"
L["Click or drag a spell onto the frame to place it"] = "주문을 프레임에 클릭이나 드래그로 배치"
L["Click spell to bind"] = "주문을 클릭하면 등록"
L["Click to bind..."] = "등록하려면 클릭..."
L["Click to cycle through steps"] = "클릭으로 순서 넘김"
L["Click to edit"] = "클릭으로 편집"
L["Click to edit range"] = "클릭으로 인원 규모 수정"
L["Click to set branch target"] = "클릭으로 분기 대상 설정"
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = [=[클릭하면 파티와 공격대 %s 설정을 동기화합니다.
한쪽에서 변경한 사항은 자동으로 다른 쪽에도 적용됩니다.]=]
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = [=[클릭하면 파티와 공격대 %s 설정을 동기화합니다.
한쪽에서 변경한 사항은 자동으로 다른 쪽에도 적용됩니다.]=]
L["Click to toggle"] = "클릭으로 켜기/끄기"
L["Click-cast profile: %s"] = "클릭 시전 프로필: %s"
L["Click-Casting"] = "클릭 시전"
L["Click-Casting Addon Conflict"] = "클릭 시전 애드온 충돌"
L["Click-Through Icons"] = "아이콘 클릭 방지"
L["Clip Border to Frame"] = "테두리를 프레임에 고정"
L["Close"] = "닫기"
L["Color"] = "색상"
L["Color and opacity of the empty/inactive pips."] = "빈/비활성화 버블 칸의 색상과 불투명도입니다."
L["Color Bar by Duration"] = "지속시간에 따른 바 색상"
L["Color by Dispel Type"] = "해제 유형별 색상"
L["Color by Time"] = "시간에 따른 색상"
L["Color by Time Remaining"] = "남은 시간에 따른 색상"
L["Color Duration by Time"] = "시간에 따른 지속시간 색상"
L["Color Mode"] = "색상 모드"
L["Color Name Text"] = "이름 텍스트 색상"
L["Color Picker"] = "색상 선택기"
L["Color shown when in combat to indicate the handle is locked."] = "전투 중일 때 핸들이 잠겨있음을 나타내는 색상입니다."
L["Colors"] = "색상"
L["Column Growth"] = "열 증가"
L["Column Spacing"] = "열 간격"
L["Columns"] = "열"
L["Columns Grow From"] = "열 증가 방향"
L["Combat"] = "전투"
L["Combat Color"] = "전투 색상"
L["Combat Limitation: All groups will not update with new players that join mid-combat."] = "전투 제한: 전투 도중 새 플레이어가 참가해도 모든 파티가 업데이트되지 않습니다."
L["Combat Limitation: Your group will not update with new players that join mid-combat."] = "전투 제한: 전투 도중 새 플레이어가 참가해도 파티원이 업데이트되지 않습니다."
L["Combat Mode"] = "전투 모드"
L["Combat Only"] = "전투시에만"
L["Compatible (%d)"] = "호환됨 (%d)"
L["Compatible Bindings"] = "호환되는 단축키"
L["Compatible Only"] = "호환 가능한 것만"
L["Confirm"] = "확인"
L["Console"] = "콘솔"
L["Container"] = "컨테이너"
L["Content type filters configured in Party tab."] = "파티 탭에서 설정된 콘텐츠 유형 필터입니다."
L["Content Types"] = "콘텐츠 유형"
L["Content:"] = "콘텐츠:"
L["Controls Blizzard's debuff filtering (affects our display too)."] = "블리자드 기본 디버프 필터를 제어합니다. (우리 화면에도 적용됨)"
L["Controls how multiple defensive icons are arranged when using Direct aura mode."] = "직접 오라 모드 사용 시 복수의 생존기 아이콘이 배열되는 방식을 제어합니다."
L["Copied %d settings from %s to %s."] = "%s에서 %s|1으로;로; %d개 설정이 복사됐습니다."
L["Copied settings from %s to %s."] = "%s에서 %s|1으로;로; 설정이 복사됐습니다."
L["Copies these settings from %s to %s."] = "이 메뉴의 설정을 %s에서 %s|1으로;로; 복사합니다."
L["Copy"] = "복사"
L["Copy %s Settings"] = "%s 설정 복사"
L["Copy %s settings to %s?"] = "%s 설정을 %s|1으로;로; 복사할까요?"
L["Copy all settings between Party and Raid modes."] = "파티와 공격대 모드 간 모든 설정을 복사합니다."
L["COPY APPEARANCE FROM"] = "외형 복사"
L["Copy Layout"] = "레이아웃 복사"
L["Copy Settings"] = "설정 복사"
L["Copy Settings to %s"] = "%s|1으로;로; 설정 복사"
L["Copy the string below to share this wizard:"] = "이 설정 마법사를 공유하려면 아래 문자열을 복사하세요:"
L["Copy this string to share your profile:"] = "프로필을 공유하려면 이 문자열을 복사하세요:"
L["Copy To"] = "복사:"
L["Copy to Clipboard"] = "클립보드로 복사"
L["Copy to Party"] = "파티로 복사"
L["Copy to Raid"] = "공격대로 복사"
L["Corners Only"] = "모서리만 표시"
L["Create"] = "생성"
L["Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."] = "제작 및 관리 설정 마법사가 사용자에게 애드온 설정을 안내합니다. 마법사는 가져오기/내보내기 문자열을 통해 다른 사람과 공유할 수 있습니다."
L["Create Custom Macro"] = "사용자 정의 매크로 만들기"
L["Create Empty"] = "빈 프로필 생성"
L["Create Layout"] = "레이아웃 만들기"
L["Create layouts below for different player ranges within each content type. Layouts only store settings that %sdiffer%s from your global settings — everything else is inherited automatically."] = "아래에서 각 콘텐츠 유형마다 다른 인원 범위에 맞춘 레이아웃을 제작하세요. 레이아웃은 전역 설정과 %s다른%s 설정값만 저장하고 — 그 외 설정값은 자동으로 상속받습니다."
L["Create Macro"] = "매크로 만들기"
L["Create New Profile"] = "새 프로필 만들기"
L["Create separate frame groups to pin specific players like tanks, healers, or key raid members. Drag players from your group roster to add them."] = "탱커, 힐러 또는 핵심 공대원과 같은 특정 공대원을 따로 표시하는 별도의 프레임 그룹을 생성합니다. 그룹 명단에서 공대원을 드래그하면 추가됩니다."
L["Created new profile: %s"] = "생성된 새 프로필: %s"
L["Crowd Control"] = "군중 제어"
L["Current / Max"] = "현재 / 최대"
L["Current Health"] = "현재 생명력"
L["Current Profile"] = "현재 프로필"
L["CURRENT STATUS"] = "현재 상태"
L["Currently: Percent. Click for Seconds."] = "현재 설정: 백분율. 클릭하면 초로 변경합니다."
L["Currently: Seconds. Click for Percent."] = "현재 설정: 초. 클릭하면 백분율로 변경합니다."
L["Curse"] = "저주"
L["Cursor"] = "커서"
L["Custom"] = "사용자 정의"
L["Custom Border"] = "사용자 정의 테두리"
L["Custom buff and frame effect indicators"] = "맞춤 버프 및 프레임 효과 표시기"
L["Custom Color"] = "사용자 정의 색상"
L["Custom Dead Background"] = "사용자 정의 죽음 배경"
L["Custom Dispel Colors"] = "사용자 정의 해제 색상"
L["Custom Health Color"] = "사용자 정의 생명력 색상"
L["Custom Macro"] = "사용자 정의 매크로"
L["Custom Sound Path"] = "사용자 정의 효과음 경로"
L["Custom Spell ID"] = "사용자 정의 주문 ID"
L["Customise"] = "사용자 정의"
L["Customize class colors used throughout DandersFrames. Changes apply to health bars, name text, borders, and all other class-colored elements."] = "DandersFrames 전반에 걸쳐 사용되는 직업 색상을 직접 설정합니다. 변경 사항은 생명력 바, 이름 텍스트, 테두리 및 모든 직업 색상 요소에 적용됩니다."
L["Customize resource bar colors per power type. Shared across party and raid frames."] = "자원 유형에 따른 자원 바의 색상을 직접 설정합니다. 파티와 공격대 프레임 간 공유됩니다."
L["Cut"] = "자르기"
L["Cycle Next CC Profile"] = "다음 메즈 프로필로 순환"
L["Cycle Next Profile"] = "다음 프로필로 순환"
L["Damage"] = "딜러"
L["DandersFrames Auto-Profile Overrides:"] = "DandersFrames 자동 프로필 설정 변경 내역 :"
L["Darken Amount"] = "어두움 농도"
L["Darken Behind Gradient"] = "그라디언트 뒷부분을 어둡게"
L["Darken Effect"] = "어두움 효과"
L["Dashed Border"] = "점선 테두리"
L["Dead + In combat: Cast Battle Res (Rebirth, etc.)"] = "죽음 + 전투 중: 전투 부활 시전 (환생 등)"
L["Dead + Out of combat: Cast Mass Res or normal Res"] = "죽음 + 비전투: 대규모 부활이나 일반 부활"
L["Dead Background Color"] = "죽음 배경색"
L["Dead/Offline Fading"] = "죽음/오프라인 흐려짐 효과"
L["Death Knight"] = "죽음의 기사"
L["DEBUFF BLACKLIST"] = "디버프 블랙리스트"
L["Debuff Filters"] = "디버프 필터"
L["Debuff Icon"] = "디버프 아이콘"
L["Debuff Icons"] = "디버프 아이콘"
L["Debuff Icons Click-Through"] = "디버프 아이콘 클릭 방지"
L["Debuff Tooltips"] = "디버프 툴팁"
L["Debuffs"] = "디버프"
L["Debuffs relevant during combat in a raid context."] = "공격대 콘텐츠에서 전투 중에 걸리는 디버프입니다."
L["Debuffs relevant in a raid context."] = "공격대 콘텐츠에서 걸리는 디버프입니다."
L["Debug"] = "디버그"
L["Debug Console"] = "디버그 콘솔"
L["Debug Log Export (Filtered)"] = "디버그 로그 내보내기 (필터링됨)"
L["Debug logging %s"] = "디버그 기록중 %s"
L["Debug mode %s"] = "디버그 모드 %s"
L["Debug Mode (print to chat)"] = "디버그 모드 (채팅창에 출력)"
L["Deduplication"] = "중복 제거"
L["Default (Slot Order)"] = "기본값 (슬롯 번호순)"
L["Default Frame Level"] = "기본 프레임 레벨"
L["Default Frame Strata"] = "기본 프레임 층"
L["Default Icon Size"] = "기본 아이콘 크기"
L["Default Scale"] = "기본 크기 비율"
L["Defensive buffs from other players, like Pain Suppression or Blessing of Sacrifice."] = "고통 억제나 희생의 축복 같은 다른 플레이어가 걸어주는 생존기 버프입니다."
L["Defensive Icon"] = "생존기 아이콘"
L["Defensive Icon Alpha"] = "생존기 아이콘 불투명도"
L["Defensive Icon Click-Through"] = "생존기 아이콘 클릭 방지"
L["Defensive Icon Tooltips"] = "생존기 아이콘 툴팁"
L["Defensives"] = "생존기"
L["Del"] = "삭제"
L["Delete"] = "삭제"
L["Delete Current Profile"] = "현재 프로필 삭제"
L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = [=[가져온 매크로 '%s'|1을;를; 삭제할까요?
이 매크로를 사용하는 단축키는 전부 삭제됩니다.

(원본 WoW 매크로는 삭제되지 않음)]=]
L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = [=[가져온 매크로 '%s'|1을;를; 삭제할까요?
이 매크로를 사용하는 단축키는 전부 삭제됩니다.

(원본 WoW 매크로는 삭제되지 않음)]=]
L["Delete Layout"] = "레이아웃 삭제"
L["Delete layout \"%s\"?"] = "\"%s\" 레이아웃을 삭제할까요?"
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = [=['%s' 매크로를 삭제할까요?
이 매크로를 사용하는 모든 단축키도 같이 삭제됩니다.]=]
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = [=['%s' 매크로를 삭제할까요?
이 매크로를 사용하는 모든 단축키도 같이 삭제됩니다.]=]
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = [=['%s' 프로필을 삭제할까요?

이 작업은 되돌릴 수 없습니다.]=]
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = [=['%s' 프로필을 삭제할까요?

이 작업은 되돌릴 수 없습니다.]=]
L["Delete Step"] = "단계 삭제"
L["Deleted profile: %s"] = "프로필 삭제됨: %s"
L["Demon Hunter"] = "악마 사냥꾼"
L["Desaturate When Missing"] = "없을 경우 흑백 처리"
L["Description"] = "설명"
L["Description (optional)"] = "설명 (선택 사항)"
L["Dialog"] = "대화"
L["Direct API"] = "다이렉트 API"
L["Direction"] = "방향"
L["Disable (set to false)"] = "비활성화 (false로 설정)"
L["Disable Buffs"] = "버프 비활성화"
L["Disable in Combat"] = "전투 중 비활성화"
L["Disable Overlay"] = "오버레이 비활성화"
L["Disable While Mounted"] = "탈것 탑승시 비활성화"
L["Disable while mounted/flying"] = "지상/비행 탈것을 탔을 때 비활성화"
L["Disabled"] = "비활성화"
L["disabled"] = "비활성화됨"
L["Disease"] = "질병"
L["Dispel Detection"] = "해제 감지"
L["Dispel Overlay"] = "해제 오버레이"
L["Dispel Overlay Alpha"] = "해제 오버레이 불투명도"
L["Dispel Type Colors"] = "해제 유형 색상"
L["Dispel Type Icon"] = "해제 유형 아이콘"
L["Dispellable By Me"] = "내가 해제 가능"
L["Display"] = "디스플레이"
L["Display labels above or beside each raid group."] = "각 공격대의 파티 위나 옆부분에 라벨을 표시합니다."
L["Display Mode"] = "표시 모드"
L["Displays class-specific resources (Holy Power, Chi, Combo Points, Soul Shards, Arcane Charges, Essence) as colored pips on your player frame."] = "특정 직업의 자원(신성한 힘, 기, 연계 점수, 영혼 조각, 비전 충전물, 정수)을 색깔 있는 작은 버블로 내 프레임에 표시합니다."
L["Done"] = "완료"
L["Don't show this warning again"] = "이 경고를 다시 표시하지 않음"
L["Down"] = "아래"
L["DPS"] = "딜러"
L["Drag"] = "드래그"
L["Drag to reorder groups. Top = first."] = "드래그로 그룹 순서를 변경합니다. 맨 위 = 첫 번째 유닛."
L["Drag to reorder. Top = first."] = "드래그로 순서를 변경합니다. 맨 위 = 첫 번째 유닛."
L["Drop on an anchor point to move %s"] = "%s|1을;를; 이동시키려면 고정 지점에 떨구세요"
L["Drop on an anchor point to place %s"] = "%s|1을;를; 배치하려면 고정 지점에 떨구세요"
L["Druid"] = "드루이드"
L["Dungeons"] = "던전"
L["Duplicate"] = "복제"
L["Duplicate Current"] = "현재 프로필 복제"
L["Duplicated profile '%s' to '%s'."] = "프로필 '%s'|1을;를; '%s'|1으로;로; 복제했습니다."
L["Duration"] = "지속시간"
L["Duration & stack display"] = "지속시간과 중첩 표시"
L["Duration Anchor"] = "지속시간 고정 지점"
L["Duration Color"] = "지속시간 색상"
L["Duration Font"] = "지속시간 글꼴"
L["Duration in seconds for the Pull Timer quick action."] = "빠른 작업의 풀링 타이머 지속시간입니다.(초)"
L["Duration Offset X"] = "지속시간 위치 조정 X"
L["Duration Offset Y"] = "지속시간 위치 조정 Y"
L["Duration Outline"] = "지속시간 외곽선"
L["Duration Position"] = "지속시간 위치"
L["Duration Scale"] = "지속시간 크기 비율"
L["Duration Text"] = "지속시간 텍스트"
L["Duration Text Color"] = "지속시간 텍스트 색상"
L["Echo to Chat"] = "채팅창에도 출력"
L["Edge Glow (All Sides)"] = "모든 방향에 적용"
L["Edit"] = "수정"
L["Edit Binding"] = "단축키 수정"
L["Edit Copy"] = "사본으로 수정"
L["Edit Layout Range"] = "레이아웃 인원 규모 수정"
L["Edit Macro"] = "매크로 수정"
L["Edit Settings"] = "설정 편집"
L["Edit Steps"] = "단계 수정"
L["Editing"] = "편집"
L["Editing:"] = "편집:"
L["Editing: %s"] = "편집: %s"
L["Effects"] = "효과 목록"
L["Ellipsis (...)"] = "말줄임표 (...)"
L["Enable"] = "활성화"
L["Enable (set to true)"] = "활성화 (true로 설정)"
L["Enable AFK Icon"] = "자리 비움 아이콘 활성화"
L["Enable Aura Designer"] = "오라 디자이너 활성화"
L["Enable Binding Tooltips"] = "단축키 툴팁 활성화"
L["Enable Boss Debuffs"] = "보스 디버프 활성화"
L["Enable Buff Tooltips"] = "버프 툴팁 활성화"
L["Enable Buffs"] = "버프 활성화"
L["Enable Class Power Pips"] = "직업 자원 버블 활성화"
L["Enable Custom Sorting"] = "사용자 정의 정렬 활성화"
L["Enable Dead Fade"] = "죽은 유닛 흐려짐 효과 활성화"
L["Enable Debuff Tooltips"] = "디버프 툴팁 활성화"
L["Enable Debug Logging"] = "디버그 기록 활성화"
L["Enable Defensive Icon"] = "생존기 아이콘 활성화"
L["Enable Defensive Icon Tooltips"] = "생존기 아이콘 툴팁 활성화"
L["Enable Dispel Overlay"] = "해제 오버레이 활성화"
L["Enable Element-Specific Alpha"] = "요소마다 개별 불투명도 활성화"
L["Enable Expiring Indicators"] = "만료 임박 표시기 활성화"
L["Enable Frame Border Overlay"] = "프레임 테두리 오버레이 활성화"
L["Enable Frame Tooltips"] = "프레임 툴팁 활성화"
L["Enable Group Labels"] = "파티 라벨 활성화"
L["Enable Heal Prediction"] = "치유량 예측 활성화"
L["Enable Health Threshold Fade"] = "생명력 기준 흐려짐 효과 활성화"
L["Enable Leader Icon"] = "공대/파티장 아이콘 활성화"
L["Enable Missing Buff Icon"] = "버프 누락 아이콘 활성화"
L["Enable Offscreen Nameplates"] = "화면 밖 이름표 활성화"
L["Enable Overlay"] = "오버레이 활성화"
L["Enable Permanent Mover"] = "위치 이동 핸들 활성화"
L["Enable Personal Targeted Spells"] = "단일 대상 주문 시전 활성화"
L["Enable Pet Frames"] = "소환수 프레임 활성화"
L["Enable Phased Icon"] = "위상 아이콘 활성화"
L["Enable Raid Auto-Switching Layouts"] = "공격대 자동 레이아웃 전환 활성화"
L["Enable Raid Role Icon"] = "공격대 역할 아이콘 활성화"
L["Enable Raid Target Icon"] = "공격대 징표 아이콘 활성화"
L["Enable Ready Check Icon"] = "전투 준비 아이콘 활성화"
L["Enable Resource Bar"] = "자원 바 활성화"
L["Enable Resurrection Icon"] = "부활 아이콘 활성화"
L["Enable Resurrection Icon Tooltips"] = "부활 아이콘 툴팁 활성화"
L["Enable Sound Alert"] = "소리 알림 활성화"
L["Enable Spec Auto-Switch"] = "전문화 자동 전환 활성화"
L["Enable Status Text"] = "상태 텍스트 활성화"
L["Enable Summon Icon"] = "소환 아이콘 활성화"
L["Enable Targeted Spells"] = "단일 대상 주문 활성화"
L["Enable the checkbox above to use"] = "사용하려면 위의 체크박스를 켜세요"
L["Enable Vehicle Icon"] = "차량 아이콘 활성화"
L["enabled"] = "활성화됨"
L["Enabled"] = "활성화"
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = [=[활성화: 공대원을 공격대 파티(1-8) 단위로 구성합니다.
비활성화: 모든 공대원을 하나의 통합 그리드에 넣습니다.]=]
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = [=[활성화: 공대원을 공격대 파티(1-8) 단위로 구성합니다.
비활성화: 모든 공대원을 하나의 통합 그리드에 넣습니다.]=]
L["End"] = "뒤쪽"
L["END"] = "뒤쪽"
L["End (Right/Bottom)"] = "뒤쪽 (우측/아래)"
L["End of Group"] = "마지막 파티"
L["Energy"] = "기력"
L["Enter a layout name"] = "레이아웃 이름을 입력하세요"
L["Enter a profile name"] = "프로필 이름을 입력하세요"
L["Enter a spell name above..."] = "위쪽에 주문 이름을 입력하세요..."
L["Enter any spell ID for range checking. Press Enter to apply. Leave empty to use dropdown selection."] = "거리 확인에 사용할 주문 ID를 입력하세요. Enter를 누르면 적용됩니다. 드롭다운 선택을 사용하려면 입력칸을 비워두세요."
L["Enter name for copy of '%s':"] = "'%s' 복사본의 이름 입력:"
L["Enter new name for '%s':"] = "'%s'의 새 이름 입력:"
L["Enter new profile name:"] = "새 프로필 이름 입력:"
L["Enter WoW texture paths (file extensions are stripped automatically). Leave empty to use DF Icons as fallback."] = "WoW 텍스처의 경로를 입력하세요. (파일 확장자는 자동으로 제거됨) 입력칸을 비워두면 DF 아이콘을 임시로 사용합니다."
L["Errors Only"] = "오류만"
L["Evoker"] = "기원사"
L["Exit Editing"] = "편집 종료"
L["Expire Alert"] = "만료 알림"
L["Expiring"] = "만료 임박"
L["Expiring Alpha"] = "만료 임박 불투명도"
L["Expiring Alpha Override"] = "만료 임박시 불투명도 변경"
L["Expiring Color"] = "만료 임박 색상"
L["Expiring Color Override"] = "만료 임박시 색상 변경"
L["Expiring Indicator"] = "만료 임박 표시기"
L["Expiring indicator tracks the trigger with the least time remaining."] = "만료 임박 표시기가 남은 시간이 가장 적은 트리거를 추적합니다."
L["Expiring indicator tracks the trigger with the most time remaining."] = "만료 임박 표시기가 남은 시간이 가장 많은 트리거를 추적합니다."
L["Expiring Threshold (%)"] = "만료 임박 기준값 (%)"
L["Expiring Threshold (seconds)"] = "만료 임박 기준값 (초)"
L["Export"] = "내보내기"
L["Export failed. Please try again or check for errors."] = "내보내기를 실패했습니다. 다시 시도하거나 오류를 확인하세요."
L["Export Settings"] = "내보내기 설정"
L["Export Wizard"] = "내보내기 마법사"
L["External"] = "외부 애드온"
L["External Defensives"] = "외부 생존기"
L["Fade frames or elements when a unit's health is above the set threshold (e.g. 100% or 80%)."] = "유닛의 생명력이 설정된 기준값(예: 100% 또는 80%) 이상일 때 프레임이나 요소를 흐림 처리합니다."
L["Fading"] = "흐려짐 효과"
L["Fill Color"] = "채워진 부위 색상"
L["Fill Direction"] = "채워지는 방향"
L["Fill Pulsate"] = "채워진 부위 박동"
L["Finish"] = "완료"
L["First question"] = "첫 번째 질문"
L["First Unit"] = "첫 번째 유닛"
L["Fixed at 20 players (Mythic)"] = "20인으로 고정 (신화)"
L["Flat Grid Settings"] = "통합 그리드 설정"
L["Floating Bar"] = "독립형 바"
L["Floating Bar Anchor"] = "독립형 바 고정 지점"
L["Floating Bar Position"] = "독립형 바 위치"
L["Focus"] = "집중"
L["Font"] = "글꼴"
L["Font Outline"] = "글꼴 외곽선"
L["Font Settings"] = "글꼴 설정"
L["Font settings for icons displayed as text (Summon, Res, AFK, etc.)"] = "아이콘 대신 텍스트(소환, 부활, 자리 비움 등)로 표시할 경우 글꼴 설정"
L["Font Size"] = "글꼴 크기"
L["For items/macros that need @cursor, @mouseover, etc. Consumes the keybind and prevents action bar use."] = "@cursor, @mouseover 등이 필요한 아이템/매크로 용입니다. 단축키를 독점하므로 액션 바에서 같은 단축키를 사용할 수 없습니다."
L["For nameplates & world units. %sDoes not work with action bar binds.%s"] = "이름표 및 월드 유닛용입니다. %s액션 바 단축키로는 작동하지 않습니다.%s"
L["Frame"] = "프레임"
L["Frame Alpha"] = "프레임 불투명도"
L["Frame Alpha (Above Threshold)"] = "프레임 불투명도 (기준값 이상)"
L["Frame Alpha (Out of Range)"] = "프레임 불투명도 (사거리 밖)"
L["Frame Border Overlay"] = "프레임 테두리 오버레이"
L["Frame Display"] = "프레임 표시"
L["Frame Growth"] = "프레임 증가"
L["Frame Height"] = "프레임 높이"
L["Frame Level"] = "프레임 레벨"
L["Frame Level Offset"] = "프레임 레벨 조정"
L["Frame opacity when health is above the threshold."] = "생명력이 기준값 이상일 때의 프레임 불투명도입니다."
L["Frame Padding"] = "프레임 내부 여백"
L["FRAME PREVIEW"] = "프레임 미리보기"
L["Frame Scale"] = "프레임 크기 비율"
L["Frame Size"] = "프레임 크기"
L["Frame Spacing"] = "프레임 간격"
L["Frame Strata"] = "프레임 층"
L["Frame Tooltips"] = "프레임 툴팁"
L["Frame Width"] = "프레임 너비"
L["FRAME-LEVEL EFFECTS"] = "프레임 단위 효과"
L["Frames centered on screen."] = "프레임이 화면 중앙에 배치됐습니다."
L["Frames Grow From"] = "프레임 증가 방향"
L["Frames locked."] = "프레임 위치 고정됨."
L["Frames unlocked. Drag to move, right-click to lock."] = "프레임 고정 해제됨. 드래그로 이동, 우클릭으로 고정."
L["Frames: %s"] = "프레임: %s"
L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = [=[FrameSort 애드온이 감지되었습니다. 활성화하면 FrameSort가 프레임 순서를 제어합니다.

%s시험용:%s 신기능으로 모든 환경에서 완벽하게 작동하지 않을 수 있습니다. 문제가 발생하면 신고해주세요.]=]
L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = [=[FrameSort 애드온이 감지되었습니다. 활성화하면 FrameSort가 프레임 순서를 제어합니다.

%s시험용:%s 신기능으로 모든 환경에서 완벽하게 작동하지 않을 수 있습니다. 문제가 발생하면 신고해주세요.]=]
L["FrameSort Integration"] = "FrameSort 통합"
L["Friendly Only"] = "우호적 유닛만"
L["Full Frame"] = "전체 프레임"
L["Fully Combat Safe: Frames will update normally during combat."] = "완벽하게 안전한 전투: 전투 중에도 프레임이 정상적으로 업데이트됩니다."
L["Fury"] = "분노"
L["G1"] = "G1"
L["Game Default"] = "게임 기본 설정"
L["Gap Between Pips"] = "버블 간격"
L["General"] = "일반"
L["General Import"] = "일반 가져오기"
L["Generate Export String"] = "내보내기 문자열 생성"
L["Gets its own independent border overlay. Multiple custom borders can be visible at the same time."] = "자체적으로 독립된 테두리 오버레이를 가집니다. 여러 사용자 정의 테두리가 동시에 표시될 수 있습니다."
L["Global"] = "전역 설정"
L["Global Font Settings"] = "전역 글꼴 설정"
L["Global Fonts"] = "전역 글꼴"
L["Global Keybind:"] = "전역 단축키:"
L["Glow"] = "반짝임"
L["Glow (ADD)"] = "반짝임 (ADD)"
L["Glow Alpha"] = "반짝임 불투명도"
L["Glow Color"] = "반짝임 색상"
L["Glow Style"] = "반짝임 스타일"
L["Go Back"] = "뒤로 가기"
L["Goes to: %s"] = "이동: %s"
L["Gradient"] = "그라디언트"
L["Gradient Color Alpha"] = "그라디언트 색상 불투명도"
L["Gradient Intensity"] = "그라디언트 강도"
L["Gradient Opacity"] = "그라디언트 불투명도"
L["Gradient Position"] = "그라디언트 위치"
L["Gradient Size"] = "그라디언트 크기"
L["Grid"] = "격자"
L["Grid Layout"] = "그리드 레이아웃"
L["Group"] = "파티"
L["Group 1"] = "Group 1"
L["Group Display Order"] = "파티 표시 순서"
L["Group Labels"] = "파티 라벨"
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = [=[파티 라벨은 통합 그리드 레이아웃에서 사용할 수 없습니다.

파티 라벨을 사용하려면 프레임 설정에서
'파티 기반 레이아웃 사용'을 활성화하세요.]=]
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = [=[파티 라벨은 통합 그리드 레이아웃에서 사용할 수 없습니다.

파티 라벨을 사용하려면 프레임 설정에서
'파티 기반 레이아웃 사용'을 활성화하세요.]=]
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = [=[파티 라벨은 공격대 프레임에서만 사용할 수 있습니다.

설정 패널 상단의 버튼을 눌러서 공격대 모드로 전환하면
파티 라벨을 설정할 수 있습니다.]=]
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = [=[파티 라벨은 공격대 프레임에서만 사용할 수 있습니다.

설정 패널 상단의 토글을 사용하여 공격대 모드로 전환하면
파티 라벨을 설정할 수 있습니다.]=]
L["Group Layout Settings"] = "파티 기반 레이아웃 설정"
L["GROUP NAME"] = "그룹 이름"
L["Group Position"] = "그룹 위치"
L["Group Roster"] = "그룹 명단"
L["Group Settings"] = "그룹 설정"
L["Group Spacing"] = "파티 간격"
L["Group Visibility"] = "파티 표시"
L["Group X Offset"] = "그룹 X 위치 조정"
L["Group Y Offset"] = "그룹 Y 위치 조정"
L["Groups Grow From"] = "파티 증가 방향"
L["Groups Per Column"] = "1열 당 파티 수"
L["Groups Per Row"] = "1행 당 파티 수"
L["Growth"] = "증가 방향"
L["GROWTH"] = "증가 방향"
L["Growth Direction"] = "증가 방향"
L["GUI reset to default size, scale, and position."] = "GUI가 기본 크기, 크기 비율, 위치로 초기화되었습니다."
L["Guided setup for configuring which buffs and debuffs appear on your frames."] = "프레임에 표시되는 버프와 디버프의 설정 가이드입니다."
L["Guided setup for the frame border overlay that highlights boss debuffs."] = "보스 디버프를 강조하는 프레임 테두리 오버레이 설정 가이드입니다."
L["Handle Color"] = "핸들 색상"
L["Handle Height"] = "핸들 높이"
L["Handle is invisible until you hover over it. Fades in and out smoothly."] = "마우스를 올리기 전엔 핸들이 보이지 않습니다. 서서히 나타나고 사라집니다."
L["Handle Position"] = "핸들 위치"
L["Handle Width"] = "핸들 너비"
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = [=[여러 클릭 시전 애드온이 활성화되면 충돌 및
예상치 못한 동작이 발생할 수 있습니다.

%s주의해서 사용하세요!%s]=]
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = [=[여러 클릭 시전 애드온이 활성화되면 충돌 및
예상치 못한 동작이 발생할 수 있습니다.

%s주의해서 사용하세요!%s]=]
L["Having trouble with buffs or debuffs? Run the setup wizard for guided help."] = "버프나 디버프에 문제가 있나요? 설정 마법사를 실행해서 도움을 받으세요."
L["Heal Absorb"] = "치유 흡수"
L["Heal Prediction"] = "치유량 예측"
L["Heal Prediction Color"] = "치유량 예측 색상"
L["Healer"] = "힐러"
L["Healers"] = "힐러"
L["Health"] = "생명력"
L["Health Bar"] = "생명력 바"
L["Health Bar Alpha"] = "생명력 바 불투명도"
L["Health Bar Color"] = "생명력 바 색상"
L["Health Bar Texture"] = "생명력 바 텍스처"
L["Health Deficit"] = "생명력 손실"
L["Health Format"] = "생명력 형식"
L["Health Gradient"] = "생명력 그라디언트"
L["Health Text"] = "생명력 텍스트"
L["Health Text Alpha"] = "생명력 텍스트 불투명도"
L["Health Text Anchor"] = "생명력 텍스트 고정 지점"
L["Health Text Color"] = "생명력 텍스트 색상"
L["Health Threshold (%)"] = "생명력 기준값 (%)"
L["Health Threshold Fading"] = "생명력 기준 흐려짐 효과"
L["Health X Offset"] = "생명력 X 위치 조정"
L["Health Y Offset"] = "생명력 Y 위치 조정"
L["Height"] = "높이"
L["Height / Thickness"] = "높이 / 두께"
L["Here's what we'll set up:"] = "설정할 사항들입니다:"
L["Hidden"] = "표시 안함"
L["Hide % Symbol"] = "% 기호 숨기기"
L["Hide Above (seconds)"] = "높으면 숨김 (초)"
L["Hide Above Threshold"] = "기준값보다 높으면 숨기기"
L["Hide Blizzard Party Frames"] = "블리자드 파티 프레임 숨기기"
L["Hide Blizzard Player Frame"] = "블리자드 플레이어 프레임 숨기기"
L["Hide Blizzard Raid Frames"] = "블리자드 공격대 프레임 숨기기"
L["Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."] = "생존기 바 또는 오라 디자이너에 이미 표시된 버프를 버프 바에서 숨깁니다."
L["Hide Cooldown Swipe"] = "쿨타임 애니메이션 숨기기"
L["Hide duplicate buffs"] = "중복 버프 숨기기"
L["Hide Duration Above Threshold"] = "기준값 이상일 때 지속시간 숨기기"
L["Hide Icon (Text Only)"] = "아이콘 숨기기 (텍스트만 표시)"
L["Hide in Combat"] = "전투 중 숨기기"
L["Hide raid buffs from buff bar"] = "버프 바에서 레이드 버프 숨기기"
L["Hide Self from Party Frames"] = "파티 프레임에서 내 프레임 숨기기"
L["Hide specific buffs and debuffs from your frames. Click a spell to toggle blacklisting. Blacklisted auras will not appear on buff bars or Aura Designer indicators."] = "프레임에서 특정 버프와 디버프를 숨깁니다. 주문을 클릭하면 블랙리스트에 넣고 뺄 수 있습니다. 블랙리스트에 들어간 오라는 버프 바나 오라 디자이너 표시기에 나타나지 않습니다."
L["Hide Tooltip on Mouseover"] = "마우스를 올렸을 때 툴팁 숨기기"
L["Hides Blizzard frames but keeps them active for aura filtering."] = "오라 필터링을 위해 블리자드 프레임을 활성화 상태로 유지하고 프레임만 숨깁니다."
L["Hides the default Blizzard player portrait and health bar."] = "기본 블리자드 플레이어 초상화 및 생명력 바를 숨깁니다."
L["Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."] = "전투 중 핸들을 숨깁니다. 비활성화하면 핸들 색상이 변경되어 전투 중에 잠금 여부를 표시합니다."
L["High"] = "높음"
L["High Health (100%)"] = "높은 생명력 (100%)"
L["High Threat (Yellow)"] = "높은 위협 수준 (노란색)"
L["Higher values render the bar above other elements. Frame border is at level 10."] = "값이 높을수록 바가 더 많은 요소 위에 그려집니다. 프레임 테두리는 10레벨에 있습니다."
L["Highest Threat (Orange)"] = "가장 높은 위협 (주황색)"
L["Highlight"] = "강조"
L["Highlight Color"] = "강조 색상"
L["Highlight Dispellable"] = "해제 가능 디버프 강조"
L["Highlight for User"] = "사용자에게 강조 표시"
L["Highlight for user to configure"] = "사용자가 직접 설정하도록 강조 표시"
L["Highlight Important Spells"] = "주요 주문 강조"
L["Highlight Settings"] = "강조 효과 설정"
L["Highlight Settings (comma-separated dbKeys)"] = "강조 효과 설정 (쉼표로 구분된 dbKey)"
L["Highlight Style"] = "강조 효과 스타일"
L["Highlighted Units"] = "강조된 유닛"
L["Highlights"] = "강조 효과"
L["Highlights: %s"] = "강조됨: %s"
L["Horizontal"] = "가로"
L["Horizontal anchors lay pips left-to-right. Left/Right anchors stack pips vertically along the frame side."] = "가로 고정은 버블을 왼쪽에서 오른쪽으로 나열합니다. 왼쪽/오른쪽 고정은 프레임 측면을 따라 버블을 세로로 쌓습니다."
L["Horizontal Spacing"] = "가로 간격"
L["Horizontal: Players stack vertically, groups grow left-to-right."] = "가로: 공대원이 세로로 쌓이고 파티는 왼쪽에서 오른쪽 방향으로 증가합니다."
L["Hostile Only"] = "적대적 유닛만"
L["Hover Highlight"] = "마우스오버 강조"
L["Hover Settings"] = "마우스오버 설정"
L["How it works"] = "작동 방식"
L["How often to check range (seconds). Lower = more responsive but higher CPU. Default: 0.5s"] = "거리 확인 빈도입니다. (초단위) 낮은 값 = 빠르게 반응하지만 더 많은 CPU 자원 사용. 기본값: 0.5초"
L["How would you like to configure the filters?"] = "필터를 어떻게 설정할까요?"
L["HP"] = "생명력"
L["Hunter"] = "사냥꾼"
L["I understand, enable it"] = "이해했어요. 활성화 합니다."
L["I, II, III..."] = "I, II, III..."
L["Icon"] = "아이콘"
L["Icon Height"] = "아이콘 높이"
L["Icon Offset X"] = "아이콘 위치 조정 X"
L["Icon Offset Y"] = "아이콘 위치 조정 Y"
L["Icon Opacity"] = "아이콘 불투명도"
L["Icon Position"] = "아이콘 위치"
L["Icon Ratio"] = "아이콘 비율"
L["Icon Size"] = "아이콘 크기"
L["Icon size, scale & border"] = "아이콘 크기, 크기 비율 및 테두리"
L["Icon Spacing"] = "아이콘 간격"
L["Icon Style"] = "아이콘 스타일"
L["Icon Width"] = "아이콘 너비"
L["Icons"] = "아이콘"
L["Icons Alpha"] = "아이콘 불투명도"
L["Icons Per Row"] = "1행당 아이콘 수"
L["Ignore"] = "무시"
L["Ignore Full Health Fade"] = "만피 흐려짐 효과 무시"
L["Import"] = "가져오기"
L["Import All"] = "모두 가져오기"
L["Import All (%d)"] = "모두 가져오기 (%d)"
L["Import Buffs Tab Defaults"] = "버프 탭 기본값 가져오기"
L["Import Click Casting Profile"] = "클릭 시전 프로필 가져오기"
L["Import failed"] = "가져오기 실패"
L["Import from Buffs Tab"] = "버프 탭에서 가져오기"
L["Import Selected"] = "선택한 항목 가져오기"
L["Import Settings"] = "설정 가져오기"
L["Import String"] = "가져오기 문자열"
L["Import Wizard"] = "설정 마법사 가져오기"
L["Import WoW Macros"] = "WoW 매크로 가져오기"
L["Import your existing Buffs tab settings as defaults for all auras. Compatible settings will be applied automatically."] = "버프 탭 설정을 모든 오라의 기본값으로 가져옵니다. 호환 가능한 설정이 자동으로 적용됩니다."
L["Import/Export"] = "가져오기/내보내기"
L["Important Spells"] = "주요 주문"
L["Important Spells Only"] = "주요 주문만"
L["Imported Profile"] = "가져온 프로필"
L["Imported!"] = "가져오기 완료!"
L["In Combat Only"] = "전투 중에만"
L["In Direct mode, all active big and external defensives are shown per unit (not just one). Adjust max count and layout on the Defensive Icon page."] = "직접 모드에서는 활성화된 모든 큰 생존기와 외부 생존기가 유닛별로 표시됩니다. (하나만 나오는게 아님) 생존기 아이콘 페이지에서 최대 개수와 레이아웃을 조정하세요."
L["Incompatible Bindings"] = "호환되지 않는 단축키"
L["Indicators"] = "표시기"
L["INFERRED TRACKING"] = "추론된 추적"
L["Info (All)"] = "정보 (전체)"
L["Inherit (Frame)"] = "상속 (프레임)"
L["Insanity"] = "광기"
L["Inset"] = "삽입"
L["Inside (Bottom)"] = "내부 (아래)"
L["Inside (Top)"] = "내부 (위)"
L["Instanced / PvP"] = "인스턴스 / PvP"
L["Integration"] = "통합"
L["Integration (advanced):"] = "통합 (고급):"
L["Integrations"] = "통합"
L["Interrupt Settings"] = "차단 설정"
L["Interrupted Visual"] = "차단됨 시각 효과"
L["is secret-tracked"] = "|1이;가; 비밀 값 추적 대상입니다"
L["Items"] = "아이템"
L["Join a raid group (2-5 players works best)"] = "공격대 그룹에 참가하세요 (2-5명이 최적)"
L["Keep Buffs"] = "버프 유지"
L["Keep when offline/left"] = "오프라인/퇴장 시 유지"
L["Label Color"] = "라벨 색상"
L["Label Format"] = "라벨 형식"
L["Label Name"] = "라벨 이름"
L["Label Position"] = "라벨 위치"
L["Label:"] = "라벨:"
L["Last Unit"] = "마지막 유닛"
L["Layout"] = "레이아웃"
L["Layout (Direct Mode)"] = "레이아웃 (직접 모드)"
L["Layout Direction"] = "레이아웃 방향"
L["Layout Group"] = "레이아웃 그룹"
L["Layout Groups"] = "레이아웃 그룹"
L["Layout Mode"] = "레이아웃 모드"
L["Layout Name"] = "레이아웃 이름"
L["Layout:"] = "레이아웃:"
L["Leader Icon"] = "공대/파티장 아이콘"
L["Left"] = "왼쪽"
L["Left Click"] = "왼쪽 버튼 클릭"
L["Left Edge"] = "왼쪽면"
L["Left of Health Bar"] = "생명력 바 왼쪽"
L["Left of Owner"] = "소환수 주인 왼쪽"
L["Left of Party"] = "파티 왼쪽"
L["Left of Raid"] = "공격대 왼쪽"
L["Left to Right"] = "왼쪽에서 오른쪽으로"
L["Left-click to add/edit binding"] = "왼쪽 클릭으로 단축키 추가/편집"
L["Left-click: Bind"] = "왼쪽 클릭: 등록"
L["Let Masque Control Aura Borders"] = "Masque가 오라의 테두리를 제어하도록 허용"
L["Let me configure it myself"] = "내가 직접 설정"
L["Line"] = "선"
L["Link: %s"] = "연결: %s"
L["Linked Settings"] = "연결된 설정"
L["List"] = "목록"
L["Loading..."] = "불러오는 중..."
L["LOADOUT ASSIGNMENTS"] = "특성 구성별 프로필 지정"
L["Loadout expects: %s"] = "이전 특성 구성: %s"
L["Lock"] = "잠금"
L["Lock Frames"] = "프레임 잠금"
L["Lock Position"] = "위치 고정"
L["Log Viewer"] = "로그 뷰어"
L["Loop Interval (sec)"] = "루프 간격 (초)"
L["Low"] = "낮음"
L["Low Health (0%)"] = "낮은 생명력 (0%)"
L["Lunar Power"] = "천공의 힘"
L["Macro Options:"] = "매크로 옵션:"
L["Macro Text:"] = "매크로 텍스트:"
L["Macros"] = "매크로"
L["Mage"] = "마법사"
L["Magic"] = "마법"
L["Major defensive cooldowns like Divine Shield, Ice Block, or Barkskin."] = "천상의 보호막, 얼음 방패, 나무 껍질과 같은 강력한 생존기입니다."
L["Make icons click-through for external click-casting addons. Not needed for DF built-in click-casting."] = "외부 클릭 시전 애드온을 위해 아이콘을 방지로 설정합니다. DF 기본 클릭 시전을 사용할 때는 설정할 필요가 없습니다."
L["Makes this binding work everywhere, consuming the keybind."] = "이 단축키가 어디서나 작동하게 되지만 단축키를 독점합니다."
L["Mana"] = "마나"
L["Manage"] = "관리"
L["Manage Profiles"] = "프로필 관리"
L["Marching Ants"] = "움직이는 점선"
L["Mark of the Wild (Druid)"] = "야생의 징표 (드루이드)"
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = [=[Masque 애드온이 설치되어 있지 않습니다.

Masque를 사용하면 버프/디버프 아이콘에 사용자 정의 텍스처를 적용할 수 있습니다. CurseForge에서 Masque를 설치하면 활성화됩니다.]=]
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = [=[Masque 애드온이 설치되어 있지 않습니다.

Masque를 사용하면 버프/디버프 아이콘에 사용자 정의 텍스처를 적용할 수 있습니다. CurseForge에서 Masque를 설치하면 활성화됩니다.]=]
L["Masque Integration"] = "Masque 통합"
L["Match Frame Height"] = "프레임 높이에 맞춤"
L["Match Frame Width"] = "프레임 너비에 맞춤"
L["Match Health Bar Width/Height"] = "생명력 바 너비/높이에 맞춤"
L["Match Owner Height"] = "주인 프레임 높이에 맞춤"
L["Match Owner Width"] = "주인 프레임 너비에 맞춤"
L["Matched (not applied)"] = "일치함 (적용되지 않음)"
L["Max Buffs"] = "최대 버프 수"
L["Max Debuffs"] = "최대 디버프 수"
L["Max Health"] = "최대 생명력"
L["Max Icons"] = "최대 아이콘 수"
L["Max Length (0=off)"] = "최대 길이 (0=꺼짐)"
L["Max Log Entries"] = "최대 로그 항목 수"
L["Max Name Length"] = "최대 이름 길이"
L["Max Slots"] = "최대 슬롯 수"
L["Medium"] = "중간"
L["Medium Health (50%)"] = "중간 생명력 (50%)"
L["Melee DPS"] = "근접 딜러"
L["MEMBERS"] = "구성원"
L["Min Stacks to Show"] = "표시할 최소 중첩 수"
L["Minimum Log Level"] = "최소 로그 단계"
L["Missing Buff Alpha"] = "버프 누락 불투명도"
L["Missing Buffs"] = "버프 누락"
L["Missing Health"] = "잃은 생명력"
L["Missing Health Alpha"] = "잃은 생명력 불투명도"
L["Missing Health Color"] = "잃은 생명력 색상"
L["Missing Health Only"] = "잃은 생명력에만"
L["Missing Health Texture"] = "잃은 생명력 텍스처"
L["Mode"] = "모드"
L["Modified"] = "수정됨"
L["Monk"] = "수도사"
L["Monochrome"] = "모노크롬"
L["Moves the glow to the opposite side (no HP side instead of max HP side)."] = "반짝임을 반대편으로 이동합니다. (최대 HP 쪽 말고 HP 없는 쪽으로)"
L["Multi Select"] = "다중 선택"
L["My Group First"] = "내 파티 먼저"
L["My Wizards"] = "내 설정 마법사"
L["Mythic"] = "신화"
L["Mythic has fixed range"] = "신화 난이도는 인원이 고정됩니다"
L["Name"] = "이름"
L["Name Alpha"] = "이름 불투명도"
L["Name already exists"] = "이미 있는 이름입니다"
L["Name Anchor"] = "이름 고정 지점"
L["Name Color"] = "이름 색상"
L["Name Text"] = "이름 텍스트"
L["Name Text Alpha"] = "이름 텍스트 불투명도"
L["Name Text Color"] = "이름 텍스트 색상"
L["Name X Offset"] = "이름 X 위치 조정"
L["Name Y Offset"] = "이름 Y 위치 조정"
L["Name:"] = "이름:"
L["New"] = "새 기능"
L["New Binding"] = "새 단축키"
L["New Feature: Frame Border Overlay"] = "신기능: 프레임 테두리 오버레이"
L["New Option"] = "새 옵션"
L["New question"] = "새 질문"
L["Next"] = "다음"
L["No"] = "아니오"
L["No %s effects configured."] = "%s에 설정된 효과가 없습니다."
L["No action selected"] = "선택된 동작이 없습니다"
L["No auto-profile is currently active or being edited."] = "현재 활성화되어 있거나 편집 중인 자동 프로필이 없습니다."
L["no branch"] = "분기 없음"
L["No built-in wizards available yet. Check back after updates!"] = "아직 내장 설정 마법사를 사용할 수 없습니다. 업데이트 후 다시 확인하세요!"
L["No changelog available."] = "변경사항이 없습니다."
L["No custom wizards yet. Click 'New Wizard' to create one!"] = "아직 사용자 설정 마법사가 없습니다. ‘새 마법사’를 클릭하여 생성하세요!"
L["No data to export"] = "내보낼 데이터가 없습니다"
L["No default profile set"] = "기본 프로필 세트 없음"
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = [=[설정된 효과가 없습니다.
'+ 표시기 추가'를 클릭해서 시작하세요.]=]
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = [=[설정된 효과가 없습니다.
'+ 표시기 추가'를 클릭해서 시작하세요.]=]
L["No item equipped"] = "착용한 아이템 없음"
L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = [=[생성된 레이아웃 그룹이 없습니다.
'+ 그룹 생성'을 클릭해서 시작하세요.]=]
L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = [=[생성된 레이아웃 그룹이 없습니다.
'+ 그룹 생성'을 클릭해서 시작하세요.]=]
L["No layout set. Using global settings."] = "설정된 레이아웃이 없습니다. 전역 설정을 사용합니다."
L["No loadout detected"] = "감지된 특성 구성 없음"
L["No macros match the current filter."] = "현재 필터와 일치하는 매크로가 없습니다."
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = [=[매크로가 없습니다.
'+ 제작'을 클릭해서 만들거나 '가져오기'로 WoW에서 가져오세요.]=]
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = [=[매크로가 없습니다.
'+ 제작'을 클릭해서 만들거나 '가져오기'로 WoW에서 가져오세요.]=]
L["No members yet"] = "아직 그룹에 사람이 없습니다"
L["No saved position to reset to."] = "초기화할 저장된 위치 정보가 없습니다."
L["No sound file selected. Choose a sound from the dropdown or enter a custom path."] = "선택한 효과음 파일이 없습니다. 드롭다운에서 효과음을 선택하거나 직접 경로를 입력하세요."
L["No spells available for this class"] = "이 직업에 사용 가능한 주문 없음"
L["No thanks"] = "아니요, 괜찮아요"
L["No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."] = "선택한 설정 마법사가 없습니다. 먼저 ‘내 마법사’ 탭으로 가서 마법사를 선택하거나 새로 만드세요."
L["None"] = "없음"
L["None (no clamping)"] = "없음 (고정 없음)"
L["None / Physical"] = "없음 / 물리"
L["None active (using global settings)"] = "활성 설정 없음 (전역 설정 사용)"
L["Normal (BLEND)"] = "일반 (BLEND)"
L["Not Cancelable"] = "취소 불가"
L["Not in a raid group"] = "공격대 그룹에 없을 때"
L["Not Set"] = "설정 안됨"
L["Note: Cmd + Left Click unavailable on Mac"] = "알림: Mac에선 Cmd + 왼쪽 클릭을 사용할 수 없습니다"
L["Note: Font sizes are not changed. Adjust sizes in each element's page."] = "알림: 글꼴 크기는 변경되지 않습니다. 각 요소의 페이지에서 크기를 조정하세요."
L["Notice"] = "알림"
L["Off"] = "없음"
L["Offset X"] = "위치 조정 X"
L["Offset Y"] = "위치 조정 Y"
L["OK"] = "확인"
L["Only changed settings will be saved"] = "변경된 설정만 저장됩니다"
L["Only Dispellable Debuffs"] = "해제 가능한 디버프만"
L["Only My Buffs"] = "내가 시전한 버프만"
L["Only show buffs that you cast. Applies to all buff filters."] = "내가 시전한 버프만 표시합니다. 모든 버프 필터에 적용됩니다."
L["Only Show When Tanking"] = "탱커 전문화일때만 표시"
L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = [=[자동 레이아웃이 작동중엔 활성화된 레이아웃만
편집이 가능합니다.]=]
L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = [=[자동 레이아웃이 작동중엔 활성화된 레이아웃만
편집이 가능합니다.]=]
L["OOC"] = "비전투"
L["Open Aura Designer"] = "오라 디자이너 열기"
L["Open Cast History"] = "시전 기록 열기"
L["Open Settings"] = "설정 열기"
L["Open Settings Tab"] = "설정 탭 열기"
L["Open the Profiles tab to manage profiles"] = "프로필 탭을 열어서 프로필 관리를 합니다"
L["Open Unit Menu"] = "유닛 메뉴 열기"
L["Open World"] = "야외"
L["Opens tab: %s"] = "탭 열기: %s"
L["Option A"] = "옵션 A"
L["Option B"] = "옵션 B"
L["Options"] = "옵션"
L["Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"] = "옵션: [S] = 설정 연결 [->] = 분기 [x] = 삭제"
L["Or enter Icon ID:"] = "또는 아이콘 ID 입력:"
L["Orientation"] = "방향"
L["Other"] = "기타"
L["Other (%d)"] = "기타 (%d)"
L["Other Frames"] = "다른 프레임"
L["Out of combat"] = "비전투"
L["Out of Combat Only"] = "비전투 시에만"
L["Out of Range"] = "사거리 벗어남"
L["Outline"] = "외곽선"
L["Overlaps with \"%s\""] = "\"%s\"|1과;와; 인원 범위 겹침"
L["Overlaps with \"%s\" (%d-%d)"] = "\"%s\"|1과;와; 인원 범위 겹침 (%d-%d)"
L["Overlay (on health bar)"] = "오버레이 (생명력 바)"
L["Overridden by Auto Layout"] = "자동 레이아웃 설정이 적용됨"
L["Overridden in this layout"] = "이 레이아웃에서 설정 변경됨"
L["Override Details"] = "설정 변경 내역"
L["Owner's Class Color"] = "소환수 주인 직업 색상"
L["Paladin"] = "성기사"
L["Parse String"] = "문자열 분석"
L["Party"] = "파티"
L["PARTY"] = "파티"
L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = [=[파티와 공격대의 %s 설정을 동기화합니다.
클릭하면 동기화를 중단합니다.]=]
L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = [=[파티와 공격대의 %s 설정을 동기화합니다.
클릭하면 동기화를 중단합니다.]=]
L["Party to Raid"] = "파티에서 공격대로"
L["Party: %s"] = "파티: %s"
L["Paste a profile string to import:"] = "문자열을 붙여넣기 해서 프로필을 가져옵니다."
L["Paste the wizard export string below:"] = "아래에 설정 마법사 문자열을 붙여넣기:"
L["Pattern:"] = "방식:"
L["Per-aura overrides"] = "오라에 적용된 별도의 설정"
L["Percent"] = "백분율"
L["Percentage"] = "백분율"
L["Permanent Mover"] = "위치 이동 핸들"
L["Per-setting reset is not available for Aura Designer"] = "오라 디자이너에선 설정별로 초기화를 할 수 없습니다."
L["Persist (sec)"] = "유지 시간 (초)"
L["Personal Targeted"] = "단일 대상"
L["Personal Targeted Spells"] = "단일 대상 주문"
L["Pet Frame Settings"] = "소환수 프레임 설정"
L["Pet Frames"] = "소환수 프레임"
L["Pet frames are grouped together in a separate container."] = "소환수 프레임은 별도의 컨테이너에서 그룹으로 형성됩니다."
L["Pet frames are positioned relative to their owner's frame."] = "소환수 프레임은 주인 프레임을 기준으로 배치됩니다."
L["Pet Spacing"] = "소환수 간격 "
L["Phased"] = "다른 위상"
L["Phased Icon"] = "위상 아이콘"
L["Picked setting: %s%s%s from tab %s%s%s"] = "선택한 설정: %s%s%s탭에서 %s%s%s"
L["Pinned Frames"] = "고정된 프레임"
L["Pip Color"] = "버블 색상"
L["Pip Height"] = "버블 높이"
L["Pixel-Perfect Scaling"] = "픽셀 퍼펙트 크기 조정"
L["Place %s at %s"] = "%s|1을;를; %s에 배치"
L["Placed"] = "배치됨"
L["PLACED ON FRAME"] = "프레임에 배치됨"
L["PLACEMENT"] = "배치"
L["Player Range"] = "인원 범위"
L["Players Grow From"] = "공대원 프레임 증가 방향"
L["Players Per Column"] = "1열 당 공대원 수"
L["Players Per Row"] = "1행당 공대원 수"
L["Please enter a profile name."] = "프로필 이름을 입력하세요."
L["Please select an action!"] = "동작을 선택하세요!"
L["Poison"] = "독"
L["Position"] = "위치"
L["Position & anchors"] = "위치와 고정 지점"
L["Position managed by: %s"] = "위치 관리자: %s"
L["Position reset."] = "위치가 초기화됨."
L["Power Bar Alpha"] = "자원 바 불투명도"
L["Power Word: Fortitude (Priest)"] = "신의 권능: 인내 (사제)"
L["Pre-configure players before they join the group"] = "그룹에 없는 플레이어를 미리 설정합니다"
L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = [=[키, 마우스 버튼 또는 스크롤 휠 입력
(조합 키 사용 가능)]=]
L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = [=[키, 마우스 버튼 또는 스크롤 휠 입력
(조합 키 사용 가능)]=]
L["Press Ctrl+A to select all, then Ctrl+C to copy"] = "Ctrl+A로 전체 선택 후 Ctrl+C로 복사"
L["Press Ctrl+C to copy, then Escape to close"] = "Ctrl+C로 복사 후 Esc로 닫기"
L["Press key/click/scroll..."] = "키/클릭/스크롤 입력..."
L["Preview"] = "미리보기"
L["Preview Scale"] = "미리보기 크기"
L["Preview Sound"] = "효과음 미리듣기"
L["Preview:"] = "미리보기:"
L["Priest"] = "사제"
L["Priority"] = "우선순위"
L["Priority:"] = "우선순위:"
L["Private Aura Overlay Setup"] = "프라이빗 오라 오버레이 설정"
L["Profile \"%s\" has no overrides."] = "프로필 \"%s\"에 변경된 설정이 없습니다."
L["Profile '%s' already exists."] = "프로필 '%s'|1은;는; 이미 있습니다."
L["Profile Actions"] = "프로필 작업"
L["Profile imported successfully!"] = "프로필을 가져오는데 성공했습니다!"
L["Profile matched to loadout"] = "프로필이 특성 구성과 연결됩니다"
L["Profile Name"] = "프로필 이름"
L["Profile not found"] = "프로필이 없음"
L["Profile Settings"] = "프로필 설정"
L["Profile:"] = "프로필:"
L["Profile: %s"] = "프로필: %s"
L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = [=[프로필: %s%s%s
%s호환 %d개%s %s비호환 %d개%s %s합계 %d%s]=]
L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = [=[프로필: %s%s%s
%s호환 %d개%s %s비호환 %d개%s %s합계 %d%s]=]
L["Profiles"] = "프로필"
L["Pull Timer"] = "풀링 타이머"
L["Pull Timer Duration"] = "풀링 타이머 지속시간"
L["Pulsate"] = "박동 효과"
L["Pulsate Border"] = "테두리 박동"
L["Pulse"] = "깜빡임 효과"
L["Pulse Animation"] = "깜빡임 애니메이션"
L["Question"] = "질문"
L["Question:"] = "질문:"
L["Quick Bind"] = "빠른 등록"
L["Quick Bind Mode"] = "빠른 등록 모드"
L["Quick Macro"] = "빠른 매크로"
L["Quick Macro Builder"] = "빠른 매크로 제작기"
L["Quick Switch CC Profile"] = "빠른 클릭 시전 프로필 변경"
L["Quick Switch Profile"] = "빠른 프로필 변경"
L["Rage"] = "분노"
L["Raid"] = "공격대"
L["RAID"] = "공격대"
L["Raid Auto Layouts"] = "공격대 자동 레이아웃"
L["Raid Buffs"] = "공격대 버프"
L["Raid Debuffs"] = "공격대 디버프"
L["Raid frames centered."] = "공격대 프레임 중앙 배치됨."
L["Raid Group Labels"] = "공격대 파티 라벨"
L["Raid In Combat"] = "공격대 전투 중"
L["Raid Layout Mode"] = "공격대 레이아웃 모드"
L["Raid position reset."] = "공격대 위치 초기화됨."
L["Raid Role (MT/MA)"] = "공격대 역할 (멘탱/점사)"
L["Raid Role Icon (MT/MA)"] = "공격대 역할 아이콘 (멘탱/점사)"
L["Raid Target Icon"] = "공격대 징표 아이콘"
L["Raid to Party"] = "공격대에서 파티로"
L["Raid: %s"] = "공격대: %s"
L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = [=[공격대: 파티 기반 레이아웃은 각 파티 단위로 정렬합니다.
통합 그리드 레이아웃은 모든 공대원을 함께 정렬합니다.]=]
L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = [=[공격대: 파티 기반 레이아웃은 각 파티 단위로 정렬합니다.
통합 그리드 레이아웃은 모든 공대원을 함께 정렬합니다.]=]
L["Raids"] = "공격대"
L["Raids, battlegrounds (1-40)"] = "공격대, 전장 (1-40)"
L["Range Check Interval"] = "거리 확인 주기"
L["Range Check Spell"] = "거리 확인용 주문"
L["Ranged DPS"] = "원거리 딜러"
L["Ready Check"] = "전투 준비"
L["Ready Check Icon"] = "전투 준비 아이콘"
L["Ready to copy"] = "복사 준비됨"
L["Recovered %d raid settings from interrupted auto layout editing session."] = "중단된 자동 레이아웃 편집 세션에서 %d개의 공격대 설정을 복구했습니다."
L["Refresh"] = "새로고침"
L["Reload UI"] = "UI 재시작"
L["Remove all bindings from the current profile."] = "현재 사용하는 프로필에 등록한 모든 단축키를 삭제합니다."
L["Remove Offline"] = "오프라인 삭제"
L["Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."] = "이 자동 레이아웃에서 모든 오라 디자이너 설정 변경 사항을 제거하고 전역 프로필과 일치하도록 복원합니다."
L["Removes your player frame from the DandersFrames party display."] = "DandersFrames 파티 프레임에서 내 프레임을 제거합니다."
L["Rename"] = "이름 변경"
L["Replace"] = "대체"
L["Replace Blizzard's color picker with the DandersFrames color picker for this addon."] = "이 애드온의 블리자드 기본 색상 선택기를 DandersFrames 색상 선택기로 대체합니다."
L["Replace Buffs"] = "버프 교체"
L["Res + Mass"] = "부활 + 대부"
L["Res + Mass + Combat"] = "부활 + 대부 + 전부"
L["Reset"] = "초기화"
L["Reset All Aura Configs"] = "모든 오라 설정 초기화"
L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = [=[이 자동 레이아웃의 모든 오라 디자이너 설정을 전역 프로필에 맞게 초기화 할까요?

이 작업은 되돌릴 수 없습니다.]=]
L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = [=[이 자동 레이아웃의 모든 오라 디자이너 설정을 전역 프로필에 맞게 초기화 할까요?

이 작업은 되돌릴 수 없습니다.]=]
L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = [=[모든 단축키를 기본값으로 초기화 할까요?

기본값 설정:
• 왼쪽 클릭 = 유닛 대상 지정
• 오른쪽 클릭 = 메뉴 열기

%s이 작업은 되돌릴 수 없습니다.%s]=]
L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = [=[모든 단축키를 기본값으로 초기화 할까요?

기본값 설정:
• 왼쪽 클릭 = 유닛 대상 지정
• 오른쪽 클릭 = 메뉴 열기

%s이 작업은 되돌릴 수 없습니다.%s]=]
L["Reset All to Default"] = "모두 기본값으로 초기화"
L["Reset Aura Designer to Global"] = "오라 디자이너를 전역 설정으로 초기화"
L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = [=[현재 프로필을 기본값으로 초기화 할까요?
파티와 공격대 설정이 모두 초기화됩니다.]=]
L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = [=[현재 프로필을 기본값으로 초기화 할까요?
파티와 공격대 설정이 모두 초기화됩니다.]=]
L["Reset Position"] = "위치 초기화"
L["Reset Profile to Defaults"] = "프로필을 기본값으로 초기화"
L["Reset to Defaults"] = "기본값으로 초기화"
L["Reset to Global"] = "전역 설정으로 초기화"
L["Reset to Global Order"] = "전역 파티 순서로 초기화"
L["Resource Bar"] = "자원 바"
L["Resource Bar Settings"] = "자원 바 설정"
L["Resource Colors"] = "자원 색상"
L["Rested Indicator"] = "휴식 중 표시기"
L["Resurrection"] = "부활"
L["Resurrection Icon"] = "부활 아이콘"
L["Resurrection Icon Tooltips"] = "부활 아이콘 툴팁"
L["Reverse Fill"] = "반대로 채우기"
L["Reverse Fill Direction"] = "반대로 채우기 방향"
L["Reverse Order"] = "역순"
L["Reverse Overlay Fill"] = "반대로 오버레이 채우기"
L["Reverse Position"] = "위치 반전"
L["Right"] = "오른쪽"
L["Right Click"] = "오른쪽 클릭"
L["Right Edge"] = "오른쪽면"
L["Right of Health Bar"] = "생명력 바 오른쪽"
L["Right of Owner"] = "소환수 주인 오른쪽"
L["Right of Party"] = "파티 오른쪽"
L["Right of Raid"] = "공격대 오른쪽"
L["Right to Left"] = "오른쪽에서 왼쪽으로"
L["Right-click"] = "우클릭"
L["Right-click: Edit/View"] = "우클릭: 편집/보기"
L["Rogue"] = "도적"
L["Role Icon"] = "역할 아이콘"
L["Role Priority"] = "역할 우선순위"
L["Row Spacing"] = "행 간격"
L["Rows"] = "행"
L["Rows Grow From"] = "행 증가 방향"
L["Run"] = "실행"
L["Run Overlay Setup Wizard"] = "오버레이 설정 마법사 실행"
L["Run Script"] = "스크립트 실행"
L["Run Setup Wizard"] = "설정 마법사 실행"
L["Runic Power"] = "룬 마력"
L["Runtime"] = "런타임"
L["Save"] = "저장"
L["Save & Close"] = "저장 및 닫기"
L["Save Changes"] = "변경 사항 저장"
L["Scale"] = "크기 비율"
L["Script Runner"] = "스크립트 실행기"
L["Search fonts..."] = "글꼴 검색..."
L["Search sounds..."] = "효과음 검색..."
L["Search spells..."] = "주문 검색..."
L["Search textures..."] = "텍스처 검색..."
L["Search..."] = "검색..."
L["Seconds"] = "초"
L["See Also:"] = "관련 항목:"
L["Select a destination"] = "목적지 선택"
L["Select a spell"] = "주문 선택"
L["Select a step to edit"] = "편집할 단계 선택"
L["Select All Text"] = "모든 텍스트 선택"
L["Select any tab"] = "아무 탭이나 선택"
L["Select Class"] = "직업 선택"
L["Select indicator..."] = "표시기 선택..."
L["Select or create a wizard"] = "마법사 선택 또는 생성"
L["Select trigger for %s"] = "%s에 대한 트리거 선택"
L["Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."] = "거리 확인에 사용할 주문을 선택합니다. 자동으로 설정하면 해당 전문화의 기본 치유/아군 주문을 사용합니다."
L["Select..."] = "선택..."
L["Selected: %d"] = "선택함: %d"
L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = [=[이 옵션을 선택하면 다른 애드온이 비활성화되고
UI가 다시 시작됩니다.]=]
L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = [=[이 옵션을 선택하면 다른 애드온이 비활성화되고
UI가 다시 시작됩니다.]=]
L["Selection Highlight"] = "선택 강조"
L["Selection Settings"] = "선택 설정"
L["Self Position"] = "자신의 위치"
L["Separate Melee & Ranged DPS"] = "근접과 원거리 딜러를 분리"
L["Separate Pet Group"] = "소환수 그룹 분리"
L["Set a font and outline style, then click Apply to update ALL text elements."] = "글꼴과 외곽선 스타일을 설정한 후 적용을 클릭하면 모든 텍스트 요소가 업데이트됩니다."
L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = [=[설정: %s
현재 값: %s

설정할 값을 입력하세요. 사용자를 위해 입력칸에 강조 표시가 됩니다.]=]
L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = [=[설정: %s
현재 값: %s

'%s'|1을;를; 선택했을 때 어떤 일이 발생해야 하나요?]=]
L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = [=[설정: %s
현재 값: %s

설정할 값을 입력하세요. 사용자를 위해 입력칸에 강조 표시가 됩니다.]=]
L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = [=[설정: %s
현재 값: %s

'%s'|1을;를; 선택했을 때 어떤 일이 발생해야 하나요?]=]
L["Settings"] = "설정"
L["Settings to Apply"] = "적용할 설정"
L["Setup Wizards"] = "설정 마법사"
L["Shadow"] = "그림자"
L["Shadow Color"] = "그림자 색상"
L["Shadow Settings"] = "그림자 설정"
L["Shadow settings are controlled in General > Global Fonts."] = "그림자 설정은 일반 > 전역 글꼴에서 합니다."
L["Shadow X Offset"] = "그림자 X 위치 조정"
L["Shadow Y Offset"] = "그림자 Y 위치 조정"
L["Shaman"] = "주술사"
L["Shared"] = "공유"
L["Shared Border"] = "공유 테두리"
L["Shift+Left Click"] = "Shift+왼쪽 클릭"
L["Shift+Right Click"] = "Shift+오른쪽 클릭"
L["Show a pulsing yellow glow around the frame."] = "프레임 주변에 깜빡이는 노란 반짝임 효과를 표시합니다."
L["Show All Roles Out of Combat"] = "비전투시 모든 역할 표시"
L["Show as Text"] = "텍스트로 표시"
L["Show Background"] = "배경 표시"
L["Show Border"] = "테두리 표시"
L["Show Buffs"] = "버프 표시"
L["Show Cooldown Swipe"] = "쿨타임 애니메이션 표시"
L["Show Debuffs"] = "디버프 표시"
L["Show Dispel Icon"] = "해제 아이콘 표시"
L["Show DPS"] = "딜러 표시"
L["Show Duration"] = "지속시간 표시"
L["Show Duration Numbers"] = "지속시간 텍스트 표시"
L["Show Duration Text"] = "지속시간 텍스트 표시"
L["Show every buff with no filtering."] = "필터 없이 모든 버프를 표시합니다."
L["Show every debuff with no filtering."] = "필터 없이 모든 디버프를 표시합니다."
L["Show Expiring Border"] = "만료 임박 테두리 표시"
L["Show Expiring Tint"] = "만료 임박 색조 표시"
L["Show for Roles"] = "표시할 역할"
L["Show Frame Border"] = "프레임 테두리 표시"
L["Show Gradient"] = "그라디언트 표시"
L["Show Group Label"] = "파티 라벨 표시"
L["Show Healer"] = "힐러 표시"
L["Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."] = "자신 및 파티/공격대원 소환수의 생명력 바를 표시하며, 소환수는 주인 프레임에 고정됩니다. 소환수 프레임은 주인이 죽으면 사라집니다."
L["Show Health Percentage"] = "생명력 백분율 표시"
L["Show in content types:"] = "다음 콘텐츠 유형에서 표시:"
L["Show in Solo Mode"] = "솔로 모드에서 표시"
L["Show Interrupted Visual"] = "차단시 시각 효과 표시"
L["Show Label"] = "라벨 표시"
L["Show LFG Eye for Cross-Instance"] = "다른 위상의 유닛에 눈알 아이콘 표시"
L["Show Main Assist"] = "점사 담당 표시"
L["Show Main Tank"] = "메인 탱커 표시"
L["Show Minimap Button"] = "미니맵 버튼 표시"
L["Show On Current Health Only"] = "현재 생명력에만 표시"
L["Show on Hover Only"] = "마우스오버 할때만 표시"
L["Show Overheal"] = "초과 치유 표시"
L["Show Overlay For"] = "오버레이 표시:"
L["Show Overshield Glow"] = "큰 보호막에 반짝임 표시"
L["Show Party/Raid Side Menu"] = "파티/공격대 사이드 메뉴 표시"
L["Show rested indicators when in a rested area (inn, city)."] = "휴식 지역(여관, 도시)에 있을 때 휴식 중 표시기를 표시합니다."
L["Show Shadow"] = "그림자 표시"
L["Show Stacks"] = "중첩 표시"
L["Show Tank"] = "탱커 표시"
L["Show the animated ZZZ icon on the player frame."] = "공대원 프레임에 ZZZ 아이콘 애니메이션을 표시합니다."
L["Show the DF color picker when any addon opens a color picker."] = "어떤 애드온이든 색상 선택기를 열 때 DF 색상 선택기가 표시됩니다."
L["Show Timer"] = "타이머 표시"
L["Show When Missing"] = "없을 때 표시"
L["Show X Mark"] = "X 표시"
L["Show:"] = "표시:"
L["Shows a border ring around the entire frame when a boss debuff is active."] = "보스 디버프에 걸리면 프레임을 둘러싼 테두리 링을 표시합니다."
L["Shows a colored border/glow when a dispellable debuff is present."] = "해제 가능한 디버프가 있을 때 색상 테두리/반짝임을 표시합니다."
L["Shows a glow at max health when absorb exceeds the clamp limit."] = "흡수량이 제한 범위를 초과하면 생명력 바 끝부분에 반짝임을 표시합니다."
L["Shows an icon when an enemy is casting a spell targeting a party/raid member."] = "적이 파티/공격대원 중 대상을 잡고 주문을 시전할 때 아이콘을 표시합니다."
L["Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."] = "파티원이 생존기(고통 억제, 나무 껍질 등)를 켰을 때 아이콘을 표시합니다."
L["Shows effects that reduce incoming healing (like Necrotic stacks)."] = "치유 감소 효과(괴저 중첩 같은)를 표시합니다."
L["Shows icon when party members are missing raid buffs."] = "파티원이 공격대 버프가 없으면 아이콘을 표시합니다."
L["Shows incoming targeted spells on YOU in the center of your screen."] = "화면 중앙에 당신을 대상으로 잡고 시전하는 주문을 표시합니다."
L["Shows the ping wheel & party management menu."] = "핑 휠 및 파티 관리 메뉴를 표시합니다."
L["Single Select"] = "단일 선택"
L["Size"] = "크기"
L["Size & Orientation"] = "크기 및 방향"
L["Size & Spacing"] = "크기 및 간격"
L["Skip for now"] = "지금 건너뛰기"
L["Skyfury (Shaman)"] = "하늘의 격노 (주술사)"
L["Smart Res:"] = "스마트 부활:"
L["Smart Resurrection"] = "스마트 부활"
L["Smooth Bar Animation"] = "부드러운 바 애니메이션"
L["Snaps sizes and borders to exact pixels for crisp rendering."] = "선명한 렌더링을 위해 크기와 테두리를 정확한 픽셀에 맞춥니다."
L["Solid (BLEND)"] = "단색 (BLEND)"
L["Solid Border"] = "실선 테두리"
L["Solo Mode"] = "솔로 모드"
L["Solo mode %s"] = "솔로 모드 %s"
L["Solo Mode: Show your player frame when not in a group."] = "솔로 모드: 그룹에 없을 때 내 프레임을 표시합니다."
L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = [=[일부 단축키가 내 직업이나 전문화에
없는 주문을 사용하고 있습니다.]=]
L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = [=[일부 단축키가 내 직업이나 전문화에
없는 주문을 사용하고 있습니다.]=]
L["Sort by Class (within role)"] = "직업별 정렬 (역할 단위)"
L["Sort Order"] = "정렬 순서"
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = [=[파티원을 역할, 직업, 이름으로 정렬합니다.

정렬 순서: 자신의 위치 > 역할 > 직업 > 이름]=]
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = [=[파티원을 역할, 직업, 이름으로 정렬합니다.

정렬 순서: 자신의 위치 > 역할 > 직업 > 이름]=]
L["Sorted with Group"] = "그룹 기준 정렬"
L["Sorting"] = "정렬"
L["Sound"] = "효과음"
L["Sound Alert"] = "소리 알림"
L["Sound Alerts"] = "소리 알림"
L["Sound file could not be played: %s"] = "효과음 파일을 재생할 수 없습니다: %s"
L["Source Mode"] = "소스 모드"
L["Spacing"] = "간격"
L["Spacing X"] = "X 간격"
L["Spacing Y"] = "Y 간격"
L["Spark"] = "불꽃 효과"
L["Spec Default"] = "전문화 기본값"
L["Spec:"] = "전문화:"
L["Specialization data not available."] = "전문화 데이터를 사용할 수 없습니다."
L["Spell:"] = "주문:"
L["Spells"] = "주문"
L["Spells flagged as important by Blizzard."] = "블리자드에서 중요한 것으로 지정한 주문입니다."
L["Square"] = "사각형"
L["Stack Anchor"] = "중첩 고정 지점"
L["Stack Count"] = "중첩 표시"
L["Stack Font"] = "중첩 글꼴"
L["Stack Minimum"] = "최소 중첩 수"
L["Stack Offset X"] = "중첩 위치 조정 X"
L["Stack Offset Y"] = "중첩 위치 조정 Y"
L["Stack Outline"] = "중첩 외곽선"
L["Stack Scale"] = "중첩 크기 비율"
L["Stack Text"] = "중첩 텍스트"
L["Stack Text Color"] = "중첩 텍스트 색상"
L["Standard Buffs are also visible on frames."] = "표준 버프도 프레임에 표시됩니다."
L["START"] = "시작"
L["Start"] = "앞쪽"
L["Start (Left/Top)"] = "앞쪽 (왼쪽/위쪽)"
L["Start = Left/Top, End = Right/Bottom depending on direction."] = "방향에 따라 앞쪽 = 왼쪽/위쪽, 뒤쪽 = 오른쪽/아래쪽입니다."
L["Start Delay (sec)"] = "시작 지연 (초)"
L["Start of Group"] = "그룹 시작"
L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = [=[앞쪽: 그룹의 위쪽/왼쪽입니다.
중앙: 그룹 가운데입니다.
뒤쪽: 그룹의 아래쪽/오른쪽입니다.]=]
L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = [=[앞쪽: 그룹의 위쪽/왼쪽입니다.
중앙: 그룹 가운데입니다.
뒤쪽: 그룹의 아래쪽/오른쪽입니다.]=]
L["Status Icon Text Settings"] = "상태 아이콘 텍스트 설정"
L["Status Text"] = "상태 텍스트"
L["Status Text (Dead/Offline)"] = "상태 텍스트 (죽음/오프라인)"
L["Status Text Alpha"] = "상태 텍스트 불투명도"
L["Step %d of %d"] = "%d / %d단계"
L["Step 1: Click here with desired key combo"] = "1단계: 여기를 클릭 (조합 키 사용 가능)"
L["Step 2: Select Action"] = "2단계: 동작 선택"
L["Step 3: Combat Condition (optional)"] = "3단계: 전투 조건 (선택 사항)"
L["Step Editor"] = "단계 편집기"
L["Step ID"] = "단계 ID"
L["Steps"] = "단계"
L["Style"] = "스타일"
L["Summary"] = "요약"
L["Summary Step"] = "요약 단계"
L["Summon"] = "소환"
L["Summon Icon"] = "소환 아이콘"
L["Switched to profile: %s"] = "프로필 변경: %s"
L["Sync"] = "동기화"
L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = [=[%s 설정을 동기화 할까요?

현재 %s 설정을 %s|1으로;로; 복사 후 동기화 상태를 유지합니다.]=]
L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = [=[%s 설정을 동기화 할까요?

현재 %s 설정을 %s|1으로;로; 복사 후 동기화 상태를 유지합니다.]=]
L["Sync from WoW"] = "WoW에서 동기화"
L["Sync with %s"] = "%s|1과;와; 동기화"
L["Sync: %s"] = "동기화: %s"
L["Synced with %s"] = "%s|1과;와; 동기화됨"
L["Synced: %s"] = "동기화됨: %s"
L["Tank"] = "탱커"
L["Tanking (Red)"] = "탱킹 중 (빨간색)"
L["Tanks"] = "탱커"
L["Target Type:"] = "대상 유형:"
L["Target Unit"] = "대상 유닛"
L["Targeted Spell Alpha"] = "단일 대상 주문 불투명도"
L["Targeted Spell Click-Through"] = "단일 대상 주문 아이콘 클릭 방지"
L["Targeted Spells"] = "단일 대상 주문"
L["Targeted Spells (on frames)"] = "단일 대상 주문 (프레임 상)"
L["Targeting Fallback:"] = "대상 지정 대체:"
L["Targeting: %s"] = "대상 지정: %s"
L["Test"] = "테스트"
L["Test Mode"] = "테스트 모드"
L["Test mode disabled."] = "테스트 모드가 비활성화됨."
L["Test mode enabled."] = "테스트 모드가 활성화됨."
L["Test mode ended — entering combat."] = "테스트 모드 종료됨 - 전투에 돌입합니다."
L["Test Mode: %s"] = "테스트 모드: %s"
L["Text"] = "텍스트"
L["Text Color"] = "텍스트 색상"
L["Text Colors:"] = "텍스트 색상:"
L["Text Format"] = "텍스트 형식"
L["Text Scale"] = "텍스트 크기 비율"
L["Texture"] = "텍스처"
L["Texture & Colors"] = "텍스처 및 색상"
L["The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."] = "첫 번째 이미지는 프레임에 활성화된 오버레이 테두리를 보여줍니다. 두 번째에는 표준 보스 디버프 아이콘만 표시하고 있습니다."
L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = [=[프레임 테두리 오버레이는 블리자드가 전적으로 렌더링하고 있어서 수정이 불가능하다는 시각적 특징이 있습니다:

%s주황색 테두리%s는 %s해제 불가능한%s 보스 디버프에 표시됩니다. 해제 가능한 디버프만 표준 색상 테두리가 표시됩니다.

프레임에 아이콘과 다른 위치에 %s중첩 텍스트%s가 나올 수 있습니다.

오버레이는 완벽한 솔루션이 아니며 몇몇 보스전에선 지저분해 보일 수 있습니다. 주의해서 사용하세요.]=]
L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = [=[프레임 테두리 오버레이는 블리자드가 전적으로 렌더링하고 있어서 수정이 불가능하다는 시각적 특징이 있습니다:

%s주황색 테두리%s는 %s해제 불가능한%s 보스 디버프에 표시됩니다. 해제 가능한 디버프만 표준 색상 테두리가 표시됩니다.

프레임에 아이콘과 다른 위치에 %s중첩 텍스트%s가 나올 수 있습니다.

오버레이는 완벽한 솔루션이 아니며 몇몇 보스전에선 지저분해 보일 수 있습니다. 주의해서 사용하세요.]=]
L["These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."] = "이 설정은 '그림자' 테두리 스타일 사용 시 적용됩니다. 보다 극적인 그림자 효과를 원한다면 위치 조정값을 더 크게 설정하세요."
L["Thick Outline"] = "두꺼운 외곽선"
L["Thickness"] = "두께"
L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = [=[프라이빗 오라 보스 디버프에 걸리면 프레임을 둘러싸는 테두리를 추가하는 기능입니다.

중요: 테두리는 해제 가능한 것을 포함 모든 보스 디버프에 표시됩니다. 해제 불가능한 디버프엔 실선 테두리가 표시됩니다.

테두리 외형은 블리자드가 제어하며 임의로 바꿀 수 없습니다 — 크기만 조정 가능합니다.

이 기능을 설정할까요?]=]
L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = [=[프라이빗 오라 보스 디버프에 걸리면 프레임을 둘러싸는 테두리를 추가하는 기능입니다.

중요: 테두리는 해제 가능한 것을 포함 모든 보스 디버프에 표시됩니다. 해제 불가능한 디버프엔 실선 테두리가 표시됩니다.

테두리 외형은 블리자드가 제어하며 임의로 바꿀 수 없습니다 — 크기만 조정 가능합니다.

이 기능을 설정할까요?]=]
L["this option"] = "이 옵션"
L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = [=[이 프로필은 %s%s%s에 맞게 제작되었습니다.
일부 단축키가 %s%s%s|1과;와; 호환되지 않을 수 있습니다.]=]
L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = [=[이 프로필은 %s%s%s에 맞게 제작되었습니다.
일부 단축키가 %s%s%s|1과;와; 호환되지 않을 수 있습니다.]=]
L["This setting differs from the global profile value. Click the reset button to revert."] = "이 설정은 전역 프로필 값과 다릅니다. 초기화 버튼을 클릭하여 되돌리세요."
L["This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."] = "이 설정은 활성 자동 레이아웃 프로필대로 설정 중입니다. 변경하려면 자동 레이아웃 탭에서 프로필을 편집하세요."
L["This step automatically shows a review of all the user's answers. It's always the last step."] = "이 단계에선 자동으로 사용자의 모든 답변 내역이 표시됩니다. 이게 마지막 단계입니다."
L["This warning will not appear again after confirming."] = "확인을 누르면 이 경고는 다시는 표시되지 않습니다."
L["Threat Colors"] = "위협 수준 색상"
L["Threshold Mode"] = "기준값 모드"
L["Time Remaining"] = "남은 시간순"
L["Timing"] = "타이밍"
L["Tint"] = "덧칠"
L["Tint Color"] = "색조 색상"
L["Tint Opacity"] = "색조 불투명도"
L[ [=[to customise
this profile's settings]=] ] = [=[이 프로필 설정을
맞춤 설정합니다]=]
L[ [=[to customise
this profile's settings]=] ] = [=[이 프로필 설정을
맞춤 설정합니다]=]
L["To fix the ElvUI compatibility issue:"] = "ElvUI와 호환성 문제 해결법:"
L["To reposition: Unlock frames (/df unlock) and drag the mover."] = "위치 변경: 프레임 잠금 해제 (/df unlock) 후 핸들을 드래그하세요."
L["Toggle Solo Mode"] = "솔로 모드 켜기/끄기"
L["Toggle Test Mode"] = "테스트 모드 켜기/끄기"
L["Tooltips"] = "툴팁"
L["Top"] = "위쪽"
L["Top Edge"] = "윗면"
L["Top Left"] = "좌측 상단"
L["Top Right"] = "우측 상단"
L["Top to Bottom"] = "위에서 아래로"
L["Total:"] = "합계:"
L["Track Highest Duration"] = "최장 지속시간 추적"
L["Track Lowest Duration"] = "최단 지속시간 추적"
L["Trigger"] = "트리거"
L["Trigger Mode"] = "트리거 모드"
L["TRIGGERED BY"] = "발동 조건"
L["Truncate Mode"] = "생략 모드"
L["Truncation"] = "생략"
L["Type"] = "유형"
L["Type /dfarena again to disable"] = "비활성화는 /dfarena를 다시 입력"
L["Type:"] = "유형:"
L["UI Scale:"] = "UI 크기 비율:"
L["Unit Frame"] = "유닛 프레임"
L["Unit Frame Sorting"] = "유닛 프레임 정렬"
L["Unit Selection"] = "유닛 선택"
L["Units at or above this health percent are faded."] = "다음의 생명력 백분율 이상의 유닛은 흐려집니다."
L["Units Per Row"] = "1행당 유닛 수"
L["Unknown"] = "알 수 없음"
L["Unknown error"] = "알 수 없는 오류"
L["Unlock"] = "잠금 해제"
L["Unlock Frames"] = "프레임 잠금 해제"
L["Unnamed"] = "이름 없음"
L["Up"] = "위"
L["Use"] = "사용"
L["USE"] = "사용"
L["Use %s"] = "%s 사용"
L["Use /df overrides for full details in chat"] = "채팅창에 /df overrides를 입력하면 전체 설정 내역이 표시됩니다"
L["Use Class Color"] = "직업 색상 사용"
L["Use Current (%s)"] = "현재 값 사용 (%s)"
L["Use Current Value"] = "현재 값 사용"
L["Use Custom Colors"] = "사용자 정의 색상 사용"
L["Use Custom Pip Color"] = "사용자 정의 버블 색 사용"
L["Use DandersFrames"] = "DandersFrames 사용"
L["Use DF Color Picker"] = "DF 색상 선택기 사용"
L["Use DF Color Picker for All Addons"] = "모든 애드온에 DF 색상 선택기 사용"
L["Use FrameSort Addon"] = "FrameSort 애드온 사용"
L["Use Group-Based Layout"] = "파티 기반 레이아웃 사용"
L["Use recommended defaults"] = "권장 기본값 사용"
L["Use Seconds Instead of Percent"] = "백분율 대신 초 사용"
L["Uses a single border per frame. Highest priority wins."] = "프레임 마다 단일 테두리를 사용합니다. 가장 높은 우선순위 1개만 표시됩니다."
L["Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."] = "시전 추적을 사용하여 WoW가 비밀 값으로 지정한 주문을 식별합니다. 자신의 시전만 추적합니다."
L["Uses party frame settings/position"] = "파티 프레임 설정/위치 사용"
L["Using highest duration trigger"] = "최장 지속시간 트리거 사용"
L["Using lowest duration trigger"] = "최단 지속시간 트리거 사용"
L["Using spec default"] = "전문화 기본값 사용 중"
L["v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."] = "v%s 로드됨. 설정은 %s/df%s, 창이 화면 밖에 있으면 %s/df resetgui%s를 입력하세요."
L["Valid range"] = "유효 범위"
L["Value:"] = "값:"
L["Vehicle"] = "차량"
L["Vehicle Icon"] = "차량 아이콘"
L["Vertical"] = "세로"
L["Vertical Spacing"] = "세로 간격"
L["View Imported Macro"] = "가져온 매크로 보기"
L["Visibility"] = "표시 설정"
L["Volume"] = "음량"
L["Warlock"] = "흑마법사"
L["Warnings + Errors"] = "경고 + 오류"
L["Warrior"] = "전사"
L["Weight"] = "가중치"
L["What should '%s' do with this setting?"] = "'%s'|1을;를; 선택하면 이 설정을 어떻게 할까요?"
L["When \"%s\" selected:"] = "\"%s\" 선택 시:"
L["When auto-detect is OFF, select which raid buffs to monitor manually."] = "자동 감지를 껐을 경우 감시할 공격대 버프를 직접 선택하세요."
L["When disabled: Click spell to open Binding Editor."] = "비활성화 시: 주문을 클릭하면 단축키 편집기가 열립니다."
L["When enabled, a new profile will be automatically"] = "활성화 하면 새 프로필이 자동으로 생성됩니다"
L["When enabled, all pips use a single custom color instead of the class-specific default."] = "활성화하면 모든 버블이 직업 기본값 대신 단일 사용자 정의 색상을 사용합니다."
L["When enabled, all role icons are shown outside of combat. The filters below only apply during combat."] = "활성화하면 비전투시 모든 역할 아이콘이 표시됩니다. 아래 필터는 전투 중에만 적용됩니다."
L["When enabled, click-casting bindings will be"] = "활성화하면 클릭 시전을 사용합니다"
L["When enabled, Masque skins aura icons and borders. DF border settings will be disabled."] = "활성화하면 Masque가 오라 아이콘과 테두리에 스킨을 입힙니다. DF 테두리 설정은 비활성화됩니다."
L["When enabled, shows incoming heals even if they would overheal."] = "활성화하면 초과 치유일 때도 받는 치유로 표시합니다."
L["When enabled, the group you are in will always be displayed first."] = "활성화하면 내가 있는 파티가 항상 맨 앞에 표시됩니다."
L["When enabled: Click spell, press key to bind instantly."] = "활성화 시: 주문을 클릭하고 키를 누르면 즉시 등록됩니다."
L["When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."] = "일치하는 콘텐츠에 들어가면 레이아웃의 설정이 전역 설정보다 우선 적용됩니다. 일치하는 레이아웃이 없으면 전역 설정을 그대로 사용합니다."
L["Which aura data source would you like to use?"] = "어떤 오라 데이터 소스를 사용할까요?"
L["While editing, each setting shows its override status:"] = "편집하는 동안 각 설정들은 변경 상태를 보여줍니다:"
L["Whitelist buffs take priority for the expiring indicator."] = "화이트리스트 버프는 만료 임박 표시기에서 우선순위를 갖습니다."
L["WHITELISTED"] = "화이트리스트 등록됨"
L["Whole Alpha Pulse"] = "전체 투명도 깜빡임"
L["Width"] = "너비"
L["Width / Length"] = "너비 / 길이"
L["Will auto-create on switch"] = "구성 변경 시 자동 생성함"
L["Will replace existing Mythic layout"] = "기존 신화 레이아웃을 교체합니다"
L["Wizard"] = "설정 마법사"
L["Wizard '%s' saved!"] = "설정 마법사 '%s'|1이;가; 저장됨!"
L["Wizard Builder"] = "설정 마법사 제작기"
L["Wizard Details"] = "설정 마법사 세부사항"
L["Wizard Name:"] = "설정 마법사 이름:"
L["Works when hovering frames. Action bars work when not hovering."] = "프레임에 마우스오버 시 작동합니다. 마우스오버를 안했을 땐 액션 바가 작동합니다."
L["World bosses, outdoor raids (1-40)"] = "필드 보스, 야외 공격대 (1-40)"
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = [=[표준 버프 아이콘을 오라 디자이너와 함께
유지할까요 아니면 완전히 대체할까요?]=]
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = [=[표준 버프 아이콘을 오라 디자이너와 함께
유지할까요 아니면 완전히 대체할까요?]=]
L["Would you like to set up your aura filters?"] = "오라 필터를 설정할까요?"
L["X Color"] = "X 색상"
L["X Mark"] = "X 표시"
L["X Size"] = "X 크기"
L["Yellow=high, Orange=highest, Red=tanking."] = "노란색=높음, 주황색=매우 높음, 빨간색=탱킹 중."
L["Yes"] = "예"
L["Yes, set it up"] = "예, 설정할게요"
L["YOUR PROFILES"] = "내 프로필"
L["Z to A"] = "이름 역순"

