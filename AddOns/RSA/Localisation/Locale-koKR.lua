local L = LibStub("AceLocale-3.0"):NewLocale("RSA", "koKR")
if not L then return end
L[" If you wish to add a message for this section, enter it above in the |cffFFD100Add New Message|r box. As no messages exist, nothing will be announced for this section."] = "메세지를 추가하고 싶으면, 아래에 있는 |cffFFD100새로운 메세지 추가|r 부분에서 추가하세요. 만약 메세지가 하나도 없다면, 해당 주문의 알림이 표시되지 않습니다."
L[" RSA will choose a message from this section at random, if you wish to remove a message, delete the contents and press enter. If no messages exist, nothing will be announced for this section."] = " RSA는 작성된 메시지 중 무작위로 선택하여 알립니다. 메시지를 제거하려면 내용을 지우고 엔터키를 누르세요. 메시지가 없으면, 아무것도 알리지 않습니다."
L["%s can only function inside instances since 8.2.5."] = "%s는 8.2.5이후 인스턴스 안에서만 작동합니다."
--[[Translation missing --]]
L["%s only while grouped"] = "%s only while grouped"
L["|c5500DBBD[TARGET]|r will be replaced with this when whispering someone."] = "|c5500DBBD[TARGET]|r - 누군가에게 귓속말할 경우 이것으로 대체됩니다."
L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."] = "|cff91BE0F/instance|r - 공격대 찾기나 전장과 같은 인스턴스 그룹"
L["|cff91BE0F/party|r if you're in a manually formed group."] = "|cff91BE0F/party|r - 직접 형성된 파티"
L["|cff91BE0F/raid|r if you're in a manually formed raid."] = "|cff91BE0F/raid|r - 직접 형성된 공격대"
L["|cffFFCC00Whispers|r the target of the spell."] = "|cffFFCC00Whispers|r - 주문 대상에게 귓속말을 합니다."
--[[Translation missing --]]
L["A custom description for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."] = "A custom description for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."
--[[Translation missing --]]
L["A custom name for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."] = "A custom name for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."
--[[Translation missing --]]
L["A Fake event supplied by RSA to allow only announcing when a SPELL_MISSED event is Immune."] = "A Fake event supplied by RSA to allow only announcing when a SPELL_MISSED event is Immune."
--[[Translation missing --]]
L["A Fake event supplied by RSA to that occurs when a player accepts a ressurect."] = "A Fake event supplied by RSA to that occurs when a player accepts a ressurect."
--[[Translation missing --]]
L["A Fake event supplied by RSA to trigger an announcement after a set number of seconds. Useful when a spell doesn't have an appropriate combat log event to track when it expires. You can modify the duration in the Spell Setup tab."] = "A Fake event supplied by RSA to trigger an announcement after a set number of seconds. Useful when a spell doesn't have an appropriate combat log event to track when it expires. You can modify the duration in the Spell Setup tab."
--[[Translation missing --]]
L["Accepted Resurrect"] = "Accepted Resurrect"
--[[Translation missing --]]
L["Add a Spell"] = "Add a Spell"
--[[Translation missing --]]
L["Add Announcement"] = "Add Announcement"
--[[Translation missing --]]
L["Add Event"] = "Add Event"
L["Add New Message"] = "새로운 메시지 추가"
--[[Translation missing --]]
L["Additional Spell IDs"] = "Additional Spell IDs"
--[[Translation missing --]]
L["Advanced Mode"] = "Advanced Mode"
--[[Translation missing --]]
L["Allow announcements if you are in combat."] = "Allow announcements if you are in combat."
--[[Translation missing --]]
L["Allow announcements if you are not in combat."] = "Allow announcements if you are not in combat."
--[[Translation missing --]]
L["Allow announcements in /%s only when you are in a group."] = "Allow announcements in /%s only when you are in a group."
--[[Translation missing --]]
L["Allows whispers to ignore the %s and %s location options on this page. Does not ignore %s."] = "Allows whispers to ignore the %s and %s location options on this page. Does not ignore %s."
L["Always allow Whispers"] = "항상 귓속말 허용"
L["Always uses spell target's name"] = "항상 대상의 이름을 사용합니다."
--[[Translation missing --]]
L["Announcements"] = "Announcements"
--[[Translation missing --]]
L["Are you sure you want to remove this spell ID?"] = "Are you sure you want to remove this spell ID?"
--[[Translation missing --]]
L["Aura Applied"] = "Aura Applied"
--[[Translation missing --]]
L["Aura Removed"] = "Aura Removed"
--[[Translation missing --]]
L["Basic Spell Settings"] = "Basic Spell Settings"
--[[Translation missing --]]
L["Cannot configure while in combat."] = "Cannot configure while in combat."
L["Cast"] = "시전"
--[[Translation missing --]]
L["Caster & Target Settings"] = "Caster & Target Settings"
L["Cauldrons"] = "가마솥"
--[[Translation missing --]]
L["CC Broken"] = "CC Broken"
L["Channel Name"] = "채널 이름"
--[[Translation missing --]]
L["Channel Options"] = "Channel Options"
--[[Translation missing --]]
L["Combat Log Events"] = "Combat Log Events"
--[[Translation missing --]]
L["Configure each spell's announcement settings, such as what channels to announce in and what messages to send."] = "Configure each spell's announcement settings, such as what channels to announce in and what messages to send."
--[[Translation missing --]]
L["Configure how this spell functions."] = "Configure how this spell functions."
--[[Translation missing --]]
L["Configuring:|r %s"] = "Configuring:|r %s"
--[[Translation missing --]]
L["Control the areas of the game that RSA is allowed announce in."] = "Control the areas of the game that RSA is allowed announce in."
--[[Translation missing --]]
L["Control the areas of the game this spell is allowed to be announced."] = "Control the areas of the game this spell is allowed to be announced."
--[[Translation missing --]]
L["Current Messages:"] = "Current Messages:"
L["Current Version: %s"] = "현재 버전: %s"
L["Curseforge"] = true
--[[Translation missing --]]
L["Custom Caster"] = "Custom Caster"
--[[Translation missing --]]
L["Custom Description"] = "Custom Description"
--[[Translation missing --]]
L["Custom Name"] = "Custom Name"
--[[Translation missing --]]
L["Custom Target"] = "Custom Target"
L["Damage"] = "피해"
--[[Translation missing --]]
L["Damage Absorb"] = "Damage Absorb"
--[[Translation missing --]]
L["Disabled Channels"] = "Disabled Channels"
L["Discord"] = "디스코드"
L["Dispel"] = "해제"
--[[Translation missing --]]
L["Dispel Resist"] = "Dispel Resist"
L["Does not affect Immune, Immune will always use its own replacement."] = "면역에 영향을 미치지 않습니다. 면역은 항상 고유 대체어를 사용할 것입니다."
L["Drums"] = "산의 북"
--[[Translation missing --]]
L["Duration"] = "Duration"
L["Enable in Arenas"] = "투기장에서 사용"
L["Enable in Battlegrounds"] = "전장에서 사용"
--[[Translation missing --]]
L["Enable in Combat"] = "Enable in Combat"
L["Enable in Dungeons"] = "던전에서 사용"
L["Enable in Group Finder Dungeons"] = "던전 찾기 그룹에서 사용"
L["Enable in Group Finder Raids"] = "공격대 찾기 그룹에서 사용"
L["Enable in manually formed dungeon groups."] = "사용자 구성 던전에서 사용합니다."
L["Enable in manually formed raid groups."] = "사용자 구성 공격대에서 사용합니다."
L["Enable in Raid Instances"] = "공격대 인스턴스에서 사용"
L["Enable in scenario instances."] = "시나리오 인스턴스에서 사용합니다."
L["Enable in Scenarios"] = "시나리오에서 사용"
--[[Translation missing --]]
L["Enable in the non-instanced world area when playing with PvP %s."] = "Enable in the non-instanced world area when playing with PvP %s."
--[[Translation missing --]]
L["Enable in the non-instanced world area when playing with War Mode %s."] = "Enable in the non-instanced world area when playing with War Mode %s."
L["Enable in the World"] = "필드에서 사용"
L["Enable in War Mode"] = "전쟁 모드에서 사용"
--[[Translation missing --]]
L["Enable out of Combat"] = "Enable out of Combat"
L["End"] = "끝"
--[[Translation missing --]]
L["Environments"] = "Environments"
--[[Translation missing --]]
L["Event unique spell ID"] = "Event unique spell ID"
--[[Translation missing --]]
L["Exposes more options to allow custom setup of spells."] = "Exposes more options to allow custom setup of spells."
L["Failed"] = "실패"
L["Feasts"] = "푸짐한 선장의 잔칫상"
L["Feedback"] = "피드백"
L["General Replacement"] = "일반 대체어"
--[[Translation missing --]]
L["Group Announcement"] = "Group Announcement"
L["Heal"] = "치유"
--[[Translation missing --]]
L["How long before this fake event triggers after any other event for this spell has been processed."] = "How long before this fake event triggers after any other event for this spell has been processed."
L["If selected, |c5500DBBD[MISSTYPE]|r will always use the General Replacement set below."] = "선택하면, |c5500DBBD[MISSTYPE]|r은 항상 아래 일반 대체어를 사용합니다."
L["If selected, |c5500DBBD[TARGET]|r will always use the spell target's name, rather than using the input below for whispers."] = "선택하면, |c5500DBBD[TARGET]|r은 귓속말에 아래 입력을 사용하지 않고 항상 주문 대상의 이름을 사용합니다."
--[[Translation missing --]]
L["If this event uses a different spell ID to the primary one, enter it here."] = "If this event uses a different spell ID to the primary one, enter it here."
--[[Translation missing --]]
L["If this spell can trigger multiple events at the same time, such as if it is an AoE spell, you can start the event tracker when you trigger the spell, and set it to end on all events where you want to prevent subsequent announcements. Where multiple events can trigger the final message, you should select Spell Ends on both events."] = "If this spell can trigger multiple events at the same time, such as if it is an AoE spell, you can start the event tracker when you trigger the spell, and set it to end on all events where you want to prevent subsequent announcements. Where multiple events can trigger the final message, you should select Spell Ends on both events."
--[[Translation missing --]]
L["If this spell has multiple spell IDs, such as if you are trying to announce different Portals, or if it is modified by a talent which changes its Spell ID, you can enter those additional IDs here. Entering an ID already in the list will prompt you to remove it."] = "If this spell has multiple spell IDs, such as if you are trying to announce different Portals, or if it is modified by a talent which changes its Spell ID, you can enter those additional IDs here. Entering an ID already in the list will prompt you to remove it."
L["Interrupt"] = "차단"
L["Invite Link"] = "초대 링크"
--[[Translation missing --]]
L["Killed"] = "Killed"
--[[Translation missing --]]
L["List of Additional Spell IDs"] = "List of Additional Spell IDs"
L["Local Message Output Area"] = "개인 메시지 출력 영역"
--[[Translation missing --]]
L["Local Output"] = "Local Output"
--[[Translation missing --]]
L["Manage Announcements"] = "Manage Announcements"
--[[Translation missing --]]
L["Missing options. Please report this!"] = "Missing options. Please report this!"
L["Module Settings"] = "모듈 설정"
--[[Translation missing --]]
L["No tracking required"] = "No tracking required"
L["Open Configuration Panel"] = "설정창 열기"
L["Other Options"] = "기타 옵션"
--[[Translation missing --]]
L["Prevent duplicate announcements"] = "Prevent duplicate announcements"
--[[Translation missing --]]
L["Prevents multiple announcements from occuring within this duration. Useful for abilities that can affect multiple targets at the same time. Select 0 to disable."] = "Prevents multiple announcements from occuring within this duration. Useful for abilities that can affect multiple targets at the same time. Select 0 to disable."
--[[Translation missing --]]
L["Prevents multiple RSA users from announcing this spell."] = "Prevents multiple RSA users from announcing this spell."
--[[Translation missing --]]
L["Primary spell ID"] = "Primary spell ID"
--[[Translation missing --]]
L["Purgatory Cooldown"] = "Purgatory Cooldown"
--[[Translation missing --]]
L["PvE"] = "PvE"
L["PvE Options"] = "PvE 옵션"
--[[Translation missing --]]
L["PvP"] = "PvP"
L["PvP Options"] = "PvP 옵션"
L["Racials"] = "종족"
--[[Translation missing --]]
L["racials"] = "Racials"
--[[Translation missing --]]
L["Remove a Spell"] = "Remove a Spell"
L["Remove Server Names"] = "서버 이름 제거"
--[[Translation missing --]]
L["Remove Spell"] = "Remove Spell"
L["Removes server name from |c5500DBBD[TARGET]|r tags."] = "|c5500DBBD[TARGET]|r 태그에서 서버 이름을 제거합니다"
L["Repair Bots"] = "야전수리로봇 110G"
L["Replacement"] = "대체어"
--[[Translation missing --]]
L["Resurrect"] = "Resurrect"
--[[Translation missing --]]
L["RSA takes the name and description for this to show in the configuration panel if a custom name & description are not set."] = "RSA takes the name and description for this to show in the configuration panel if a custom name & description are not set."
L["Say"] = "일반 대화"
L["Sends a message locally only visible to you. To choose which part of the UI this is displayed in go to the |cff00B2FALocal Message Output Area|r in the General options."] = "자신에게만 보이는 개인 메시지로 보냅니다. UI의 어느 부분에 표시할지 선택하려면 일반 옵션의 |cff00B2FA개인 메시지 출력 영역|r으로 가세요."
L["Sends a message to one of the following channels in order of priority:"] = "우선 순위에 따라 다음 채널 중 하나에 메시지를 보냅니다:"
L["Sleeping Mana Potions"] = "원기회복의 물약"
--[[Translation missing --]]
L["Smart Group"] = "Smart Group"
--[[Translation missing --]]
L["Spell Ends"] = "Spell Ends"
--[[Translation missing --]]
L["Spell ID"] = "Spell ID"
--[[Translation missing --]]
L["Spell Setup"] = "Spell Setup"
--[[Translation missing --]]
L["Spell Setup for this spell is locked."] = "Spell Setup for this spell is locked."
--[[Translation missing --]]
L["Spell Starts"] = "Spell Starts"
--[[Translation missing --]]
L["Spell Stolen"] = "Spell Stolen"
L["Start"] = "시작"
--[[Translation missing --]]
L["Summon"] = "Summon"
L["Tag Options"] = "태그 옵션"
--[[Translation missing --]]
L["Tags"] = "Tags"
--[[Translation missing --]]
L["This event is not currently supported by RSA or is not a valid event."] = "This event is not currently supported by RSA or is not a valid event."
--[[Translation missing --]]
L["Throttle Duration"] = "Throttle Duration"
--[[Translation missing --]]
L["turned off"] = "turned off"
--[[Translation missing --]]
L["turned on"] = "turned on"
--[[Translation missing --]]
L["Unlock setup"] = "Unlock setup"
L["URL"] = true
--[[Translation missing --]]
L["Use Global Environment Settings"] = "Use Global Environment Settings"
L["Use Single Replacement"] = "공통 대체어 사용"
--[[Translation missing --]]
L["Use the global settings to determine where it can be announced."] = "Use the global settings to determine where it can be announced."
L["Utilities"] = "유틸기"
--[[Translation missing --]]
L["Valid Tags:"] = "Valid Tags:"
--[[Translation missing --]]
L["WARNING: This spell is included with RSA by default and my cease to function correctly if you unlock and alter these settings."] = "WARNING: This spell is included with RSA by default and my cease to function correctly if you unlock and alter these settings."
--[[Translation missing --]]
L["When disabled, use the Environments tab below to configure where this spell is allowed to announce. Affects all events this spell can announce."] = "When disabled, use the Environments tab below to configure where this spell is allowed to announce. Affects all events this spell can announce."
--[[Translation missing --]]
L["When reporting an issue, please also post the version number above. Thanks!"] = "When reporting an issue, please also post the version number above. Thanks!"
--[[Translation missing --]]
L["When the casting of this spell begins."] = "When the casting of this spell begins."
--[[Translation missing --]]
L["When the spell's usual duration ends."] = "When the spell's usual duration ends."
L["When the target absorbs your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "대상이 주문을 흡수하면 |c5500DBBD[MISSTYPE]|r이 이걸로 대체됩니다."
L["When the target blocks your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "대상이 주문을 방패로 막으면 |c5500DBBD[MISSTYPE]|r이 이 것으로 대체됩니다."
L["When the target deflects your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "대상이 주문을 튕겨내면 |c5500DBBD[MISSTYPE]|r이 이 것으로 대체됩니다."
L["When the target dodges your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "대상이 주문을 회피하면 |c5500DBBD[MISSTYPE]|r이 이 것으로 대체됩니다."
L["When the target evades your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "대상이 주문의 효과에서 벗어나면 |c5500DBBD[MISSTYPE]|r이 이 것으로 대체됩니다."
L["When the target is immune to your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "대상이 해당 주문에 면역인 경우 |c5500DBBD[MISSTYPE]|r은 이 것으로 대체됩니다."
L["When the target is immune to your spell."] = "대상이 주문에 면역인 경우입니다."
--[[Translation missing --]]
L["When the target of this spell accepts the resurrection."] = "When the target of this spell accepts the resurrection."
L["When the target parries your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "대상이 주문을 무기로 막으면 |c5500DBBD[MISSTYPE]|r이 이 것으로 대체됩니다."
L["When the target reflects your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "대상이 주문을 반사하면 |c5500DBBD[MISSTYPE]|r이 이 것으로 대체됩니다."
L["When the target resists your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "대상이 주문에 저항하면 |c5500DBBD[MISSTYPE]|r이 이 것으로 대체됩니다."
--[[Translation missing --]]
L["When this buff or debuff is applied to a target."] = "When this buff or debuff is applied to a target."
--[[Translation missing --]]
L["When this buff or debuff is expires."] = "When this buff or debuff is expires."
--[[Translation missing --]]
L["When this CC ability is broken prematurely by another spell."] = "When this CC ability is broken prematurely by another spell."
--[[Translation missing --]]
L["When this resurrection spell finishes, giving the target the option to return to life."] = "When this resurrection spell finishes, giving the target the option to return to life."
--[[Translation missing --]]
L["When this spell absorbs damage or effects."] = "When this spell absorbs damage or effects."
--[[Translation missing --]]
L["When this spell captures a buff from the target."] = "When this spell captures a buff from the target."
--[[Translation missing --]]
L["When this spell causes damage."] = "When this spell causes damage."
--[[Translation missing --]]
L["When this spell causes healing."] = "When this spell causes healing."
--[[Translation missing --]]
L["When this spell fails to connect with the target. See the Tag Options to configure what the [MISSTYPE] tag will turn into when used."] = "When this spell fails to connect with the target. See the Tag Options to configure what the [MISSTYPE] tag will turn into when used."
--[[Translation missing --]]
L["When this spell instantly kills the target."] = "When this spell instantly kills the target."
--[[Translation missing --]]
L["When this spell interrupts another spell cast."] = "When this spell interrupts another spell cast."
--[[Translation missing --]]
L["When this spell is cast. If the spell has a cast-time, this is when you finish the cast. If the spell is instant, this is when the spell begins its effect."] = "When this spell is cast. If the spell has a cast-time, this is when you finish the cast. If the spell is instant, this is when the spell begins its effect."
--[[Translation missing --]]
L["When this spell is resisted by the target."] = "When this spell is resisted by the target."
--[[Translation missing --]]
L["When this spell removes a buff or debuff."] = "When this spell removes a buff or debuff."
--[[Translation missing --]]
L["When this spell spawns another creature or object in the world."] = "When this spell spawns another creature or object in the world."
L["When your spell misses the target |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "주문이 타켓을 놓친 경우|c5500DBBD[MISSTYPE]|r (으)로 대체됩니다."
L["Whether the target blocks, dodges, absorbs etc. your attack, |c5500DBBD[MISSTYPE]|r will be replaced to this."] = "대상이 공격을 방패로 막든지, 피하든지, 흡수하든지  |c5500DBBD[MISSTYPE]|r은 이걸로 대체됩니다."
L["Yell"] = "외침"
--[[Translation missing --]]
L["You can click a spell in this list to remove it."] = "You can click a spell in this list to remove it."
L["You have %d message for this section."] = "%d개의 메시지가 있습니다."
L["You have %d messages for this section."] = "%d개의 메시지가 있습니다."
L["You have no messages for this section."] = "메시지가 없습니다."
--[[Translation missing --]]
L["You must enter a number."] = "You must enter a number."
--[[Translation missing --]]
L["You must enter a valid Spell ID."] = "You must enter a valid Spell ID."
L["Your message must contain at least one number or letter!"] = "메시지에는 최소한 하나의 숫자 또는 문자가 포함되어야 합니다!"
L["Your version of RSA is out of date. You may want to grab the latest version from https://www.curseforge.com/wow/addons/rsa"] = "사용 중인 RSA가 구버전입니다. https://www.curseforge.com/wow/addons/rsa 에서 최신 버전으로 업데이트 할 수 있습니다."