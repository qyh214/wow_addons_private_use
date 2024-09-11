local L = LibStub("AceLocale-3.0"):NewLocale("RSA", "ruRU")
if not L then return end
L[" If you wish to add a message for this section, enter it above in the |cffFFD100Add New Message|r box. As no messages exist, nothing will be announced for this section."] = "Если вы желаете добавить новое сообщение для этой секции, введите его выше поля ввода |cffFFD100Добавить новое сообщение|r. Если сообщение не введено - ничего не будет отправлено из этой секции."
L[" RSA will choose a message from this section at random, if you wish to remove a message, delete the contents and press enter. If no messages exist, nothing will be announced for this section."] = "RSA выберет случайное сообщение из этой секции, если вы хотите удалить сообщение, сотрите содержимое и нажмите ввод. Если сообщение не введено - ничего не будет отправлено из этой секции."
L["%s can only function inside instances since 8.2.5."] = "%s может функционировать только внутри подземелья, начиная с 8.2.5."
--[[Translation missing --]]
L["%s only while grouped"] = "%s only while grouped"
L["|c5500DBBD[TARGET]|r will be replaced with this when whispering someone."] = "Тег |c5500DBBD[TARGET]|r будет заменён именем цели личного сообщения."
L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."] = "|cff91BE0F/подземелье|r если вы в автоматически собранной группе, такой как Поиск Рейда или Поле Боя."
L["|cff91BE0F/party|r if you're in a manually formed group."] = "|cff91BE0F/группа|r если вы в вручную собранной группе."
L["|cff91BE0F/raid|r if you're in a manually formed raid."] = "|cff91BE0F/рейд|r если вы в вручную собранном рейде."
L["|cffFFCC00Whispers|r the target of the spell."] = "|cffFFCC00Шепнуть|r цели заклинания."
--[[Translation missing --]]
L["A custom description for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."] = "A custom description for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."
--[[Translation missing --]]
L["A custom name for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."] = "A custom name for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."
--[[Translation missing --]]
L["A Fake event supplied by RSA to allow only announcing when a SPELL_MISSED event is Immune."] = "A Fake event supplied by RSA to allow only announcing when a SPELL_MISSED event is Immune."
--[[Translation missing --]]
L["A Fake event supplied by RSA to allow only announcing when a SPELL_MISSED event is Reflect."] = "A Fake event supplied by RSA to allow only announcing when a SPELL_MISSED event is Reflect."
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
L["Add New Message"] = "Добавить новое сообщение"
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
L["Always allow Whispers"] = "Всегда дозволять личные сообщения"
L["Always uses spell target's name"] = "Всегда использовать имя цели заклинания"
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
L["Cast"] = "Каст"
--[[Translation missing --]]
L["Caster & Target Settings"] = "Caster & Target Settings"
L["Cauldrons"] = "Котлы"
--[[Translation missing --]]
L["CC Broken"] = "CC Broken"
L["Channel Name"] = "Название канала"
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
L["Current Version: %s"] = "Текущая версия: %s"
L["Curseforge"] = true
--[[Translation missing --]]
L["Custom Caster"] = "Custom Caster"
--[[Translation missing --]]
L["Custom Description"] = "Custom Description"
--[[Translation missing --]]
L["Custom Name"] = "Custom Name"
--[[Translation missing --]]
L["Custom Target"] = "Custom Target"
L["Damage"] = "Урон"
--[[Translation missing --]]
L["Damage Absorb"] = "Damage Absorb"
--[[Translation missing --]]
L["Disabled Channels"] = "Disabled Channels"
L["Discord"] = true
L["Dispel"] = "Рассеивание"
--[[Translation missing --]]
L["Dispel Resist"] = "Dispel Resist"
L["Does not affect Immune, Immune will always use its own replacement."] = "Не затрагивает невосприимчивость, у невосприимчивости всегда своё собственное сообщение."
L["Drums"] = "Барабаны"
--[[Translation missing --]]
L["Duration"] = "Duration"
L["Enable in Arenas"] = "Включить на арене"
L["Enable in Battlegrounds"] = "Включить на полях боя"
--[[Translation missing --]]
L["Enable in Combat"] = "Enable in Combat"
L["Enable in Dungeons"] = "Включить в подземельях"
L["Enable in Group Finder Dungeons"] = "Активно в Поиске Подземелья."
L["Enable in Group Finder Raids"] = "Активно в Поиске Рейда."
L["Enable in manually formed dungeon groups."] = "Активно во вручную собранной группе."
L["Enable in manually formed raid groups."] = "Активно во вручную собранном рейде."
L["Enable in Raid Instances"] = "Включить в рейдах"
L["Enable in scenario instances."] = " Активно в сценариях."
L["Enable in Scenarios"] = " Активно в сценариях."
--[[Translation missing --]]
L["Enable in the non-instanced world area when playing with PvP %s."] = "Enable in the non-instanced world area when playing with PvP %s."
--[[Translation missing --]]
L["Enable in the non-instanced world area when playing with War Mode %s."] = "Enable in the non-instanced world area when playing with War Mode %s."
L["Enable in the World"] = "Включить в мире"
L["Enable in War Mode"] = " Активно в Режиме Войны."
--[[Translation missing --]]
L["Enable out of Combat"] = "Enable out of Combat"
L["End"] = "Конец"
--[[Translation missing --]]
L["Environments"] = "Environments"
--[[Translation missing --]]
L["Event unique spell ID"] = "Event unique spell ID"
--[[Translation missing --]]
L["Exposes more options to allow custom setup of spells."] = "Exposes more options to allow custom setup of spells."
L["Failed"] = "Неудачно"
L["Feasts"] = "Пиры"
L["Feedback"] = "Обратная связь"
L["General Replacement"] = "Основная замена"
--[[Translation missing --]]
L["Group Announcement"] = "Group Announcement"
L["Heal"] = "Исцеление"
--[[Translation missing --]]
L["How long before this fake event triggers after any other event for this spell has been processed."] = "How long before this fake event triggers after any other event for this spell has been processed."
L["If selected, |c5500DBBD[MISSTYPE]|r will always use the General Replacement set below."] = "Если выбрано - тег |c5500DBBD[MISSTYPE]|r всегда использует графу \"Основная замена\"."
L["If selected, |c5500DBBD[TARGET]|r will always use the spell target's name, rather than using the input below for whispers."] = "Если выбрано - тег |c5500DBBD[TARGET]|r всегда использует имя цели заклинания, вместо цели шепота."
--[[Translation missing --]]
L["If this event uses a different spell ID to the primary one, enter it here."] = "If this event uses a different spell ID to the primary one, enter it here."
--[[Translation missing --]]
L["If this spell can trigger multiple events at the same time, such as if it is an AoE spell, you can start the event tracker when you trigger the spell, and set it to end on all events where you want to prevent subsequent announcements. Where multiple events can trigger the final message, you should select Spell Ends on both events."] = "If this spell can trigger multiple events at the same time, such as if it is an AoE spell, you can start the event tracker when you trigger the spell, and set it to end on all events where you want to prevent subsequent announcements. Where multiple events can trigger the final message, you should select Spell Ends on both events."
--[[Translation missing --]]
L["If this spell has multiple spell IDs, such as if you are trying to announce different Portals, or if it is modified by a talent which changes its Spell ID, you can enter those additional IDs here. Entering an ID already in the list will prompt you to remove it."] = "If this spell has multiple spell IDs, such as if you are trying to announce different Portals, or if it is modified by a talent which changes its Spell ID, you can enter those additional IDs here. Entering an ID already in the list will prompt you to remove it."
L["Interrupt"] = "Прерывание"
L["Invite Link"] = "Ссылка приглашение"
--[[Translation missing --]]
L["Killed"] = "Killed"
--[[Translation missing --]]
L["List of Additional Spell IDs"] = "List of Additional Spell IDs"
L["Local Message Output Area"] = "Локальный вывод сообщений"
--[[Translation missing --]]
L["Local Output"] = "Local Output"
--[[Translation missing --]]
L["Manage Announcements"] = "Manage Announcements"
--[[Translation missing --]]
L["Missing options. Please report this!"] = "Missing options. Please report this!"
L["Module Settings"] = "Настройки модулей"
--[[Translation missing --]]
L["No tracking required"] = "No tracking required"
L["Open Configuration Panel"] = "Открыть панель конфигурации"
L["Other Options"] = "Прочие настройки"
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
L["PvE Options"] = "PvE параметры"
--[[Translation missing --]]
L["PvP"] = "PvP"
L["PvP Options"] = "PvP параметры"
L["Racials"] = "Расовые"
--[[Translation missing --]]
L["racials"] = "Racials"
--[[Translation missing --]]
L["Remove a Spell"] = "Remove a Spell"
L["Remove Server Names"] = "Убрать название серверов (миры)"
--[[Translation missing --]]
L["Remove Spell"] = "Remove Spell"
L["Removes server name from |c5500DBBD[TARGET]|r tags."] = "Убирает название сервера с тегов |c5500DBBD[TARGET]|r"
L["Repair Bots"] = "Ремонтные боты"
L["Replacement"] = "Замена"
--[[Translation missing --]]
L["Resurrect"] = "Resurrect"
--[[Translation missing --]]
L["RSA takes the name and description for this to show in the configuration panel if a custom name & description are not set."] = "RSA takes the name and description for this to show in the configuration panel if a custom name & description are not set."
L["Say"] = "Сказать"
L["Sends a message locally only visible to you. To choose which part of the UI this is displayed in go to the |cff00B2FALocal Message Output Area|r in the General options."] = "Локальный вывод сообщений видете только вы. Его можно настроить в секции |cff00B2FAЛокальный вывод сообщений|r  в основных настройках."
L["Sends a message to one of the following channels in order of priority:"] = "Отправлять сообшение в один из канналов списка приоритетов:"
L["Sleeping Mana Potions"] = "Усыпляющие зелье маны"
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
L["Start"] = "Начало"
--[[Translation missing --]]
L["Summon"] = "Summon"
L["Tag Options"] = "Настройки тэгов"
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
L["URL"] = "Ссылка"
--[[Translation missing --]]
L["Use Global Environment Settings"] = "Use Global Environment Settings"
L["Use Single Replacement"] = "Использовать простую замену"
--[[Translation missing --]]
L["Use the global settings to determine where it can be announced."] = "Use the global settings to determine where it can be announced."
L["Utilities"] = "Полезное"
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
L["When the target absorbs your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда цель поглощает заклинание - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["When the target blocks your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда цель блокирует заклинание - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["When the target deflects your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда цель отклоняет заклинание - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["When the target dodges your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда цель уворачивается от заклинания - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["When the target evades your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда цель избегает заклинания - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["When the target is immune to your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда цель невосприимчива к заклинанию - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["When the target is immune to your spell."] = "Когда цель невосприимчива к вашему заклинанию."
--[[Translation missing --]]
L["When the target of this spell accepts the resurrection."] = "When the target of this spell accepts the resurrection."
L["When the target parries your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда цель парирует заклинание - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["When the target reflects your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда цель отражает заклинание - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["When the target resists your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда цель сопротивляется заклинанию - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
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
L["When this spell reflects another spell."] = "When this spell reflects another spell."
--[[Translation missing --]]
L["When this spell removes a buff or debuff."] = "When this spell removes a buff or debuff."
--[[Translation missing --]]
L["When this spell spawns another creature or object in the world."] = "When this spell spawns another creature or object in the world."
L["When your spell misses the target |c5500DBBD[MISSTYPE]|r will be replaced with this."] = "Когда ваше заклинание промахивается, тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["Whether the target blocks, dodges, absorbs etc. your attack, |c5500DBBD[MISSTYPE]|r will be replaced to this."] = "Когда цель блокирует, уворачивается, поглощает и т. п. вашу атаку - тег |c5500DBBD[MISSTYPE]|r будет заменён этим."
L["Yell"] = "Крик"
--[[Translation missing --]]
L["You can click a spell in this list to remove it."] = "You can click a spell in this list to remove it."
L["You have %d message for this section."] = "У вас %d сообщение в этой секции."
L["You have %d messages for this section."] = "У вас %d сообщений в этой секции."
L["You have no messages for this section."] = "У вас нет сообщений в этой секции."
--[[Translation missing --]]
L["You must enter a number."] = "You must enter a number."
--[[Translation missing --]]
L["You must enter a valid Spell ID."] = "You must enter a valid Spell ID."
L["Your message must contain at least one number or letter!"] = "Сообщение должно содержать хотябы одну букву (или цифру)!"
L["Your version of RSA is out of date. You may want to grab the latest version from https://www.curseforge.com/wow/addons/rsa"] = "Ваша версия RSA устарела. Если хотите - новую версию можно скачать по ссылке: https://www.curseforge.com/wow/addons/rsa"