local _L = LibStub("AceLocale-3.0"):NewLocale("HandyNotes_Argus", "ruRU")

if not _L then return end

if _L then

--
-- DATA
--

--
--	READ THIS BEFORE YOU TRANSLATE !!!
-- 
--	DO NOT TRANSLATE THE RARE NAMES HERE UNLESS YOU HAVE A GOOD REASON!!!
--	FOR EU KEEP THE RARE PART AS IT IS. CHINA & CO MAY NEED TO ADJUST!!!
--
--	_L["Rarename_search"] must have at least 2 Elements! First is the hardfilter, >=2nd are softfilters
--	Keep the hardfilter as general as possible. If you must, set it to "".
--	These Names are only used for the Group finder!
--	Tooltip names are already localized!
--

_L["Watcher Aival"] = "Смотритель Айвал";
_L["Watcher Aival_search"] = { "aival", "айвал" };
_L["Watcher Aival_note"] = "";
_L["Puscilla"] = "Пузцилла";
_L["Puscilla_search"] = { "pus", "puscilla", "пузицилла", "пузцилла", "пузи" };
_L["Puscilla_note"] = "Вход в пещеру на мосту 65.58 26.81. Рарник находится в самом конце.";
_L["Vrax'thul"] = "Вракс'тул";
_L["Vrax'thul_search"] = { "vrax", "вракс", "vrax'thul", "vraxthul", "vrax thul" };
_L["Vrax'thul_note"] = "";
_L["Ven'orn"] = "Яд'орн";
_L["Ven'orn_search"] = { "ven", "ядорн", "ven'orn", "venorn", "ven orn" };
_L["Ven'orn_note"] = "В пещере, в ущелье с пауками. Вход 66,7 53,9.";
_L["Varga"] = "Варга";
_L["Varga_search"] = { "var", "варга", "varga" };
_L["Varga_note"] = "Внизу, в пещере. Вход 64.2 47.4.";
_L["Lieutenant Xakaar"] = "Лейтенант Закаар";
_L["Lieutenant Xakaar_search"] = { "xa", "xakaar", "закар", "закаар" };
_L["Lieutenant Xakaar_note"] = "";
_L["Wrath-Lord Yarez"] = "Повелитель гнева Ярез";
_L["Wrath-Lord Yarez_search"] = { "ya", "ярез", "yarez" };
_L["Wrath-Lord Yarez_note"] = "";
_L["Inquisitor Vethroz"] = "Инквизитор Ветроз";
_L["Inquisitor Vethroz_search"] = { "vet", "ветроз", "vethroz", "vetroz" };
_L["Inquisitor Vethroz_note"] = "";
_L["Portal to Commander Texlaz"] = "Портал к Командиру Текслаз";
_L["Portal to Commander Texlaz_note"] = "";
_L["Commander Texlaz"] = "Командир Текслаз";
_L["Commander Texlaz_search"] = { "tex", "текслаз", "текс", "texlaz" };
_L["Commander Texlaz_note"] = "Чтобы попасть на корабль, используйте портал по координатам 80.2, 62.3.";
_L["Admiral Rel'var"] = "Адмирал Рел'вар";
_L["Admiral Rel'var_search"] = { "rel", "релвар", "relvar" };
_L["Admiral Rel'var_note"] = "";
_L["All-Seer Xanarian"] = "Провидец Ксанариан";
_L["All-Seer Xanarian_search"] = { "xa", "ксанариан", "ксанар", "xanar" };
_L["All-Seer Xanarian_note"] = "";
_L["Worldsplitter Skuul"] = "Миродробитель Скуул";
_L["Worldsplitter Skuul_search"] = { "sku", "скуул", "скул", "skuul", "skul" };
_L["Worldsplitter Skuul_note"] = "Может летать по большому кругу от точки респа.";
_L["Houndmaster Kerrax"] = "Псарь Керракс";
_L["Houndmaster Kerrax_search"] = { "ker", "псарь", "керакс", "керракс", "kerrax", "kerax" };
_L["Houndmaster Kerrax_note"] = "";
_L["Void Warden Valsuran"] = "Хранительница Бездны Валсурана";
_L["Void Warden Valsuran_search"] = { "val", "валсурана", "valsuran" };
_L["Void Warden Valsuran_note"] = "";
_L["Chief Alchemist Munculus"] = "Главный алхимик Мункул";
_L["Chief Alchemist Munculus_search"] = { "mun", "мункул", "munculus", "muculus" };
_L["Chief Alchemist Munculus_note"] = "";
_L["The Many-Faced Devourer"] = "Многоликий Пожиратель";
_L["The Many-Faced Devourer_search"] = { "face", "многоликий", "many.*face", "face.*devourer" };
_L["The Many-Faced Devourer_note"] = "Для вызова Рарника вам нужно выбить 'Зов Пожирателя' в зоне Костяной склон падальщиков (53,35). Затем собрать еще три предмета в разных точках (50.4 56.1 , 65.9 19.4 , 52.3 35.4). После чего будет доступен алтарь для призыва. Все предметы нужно собрать один раз.";
_L["Portal to Squadron Commander Vishax"] = "Портал к Командиру отряда Вишакс";
_L["Portal to Squadron Commander Vishax_note"] = "Чтобы открыть портал, нужно собрать 'Разбитый генератор портала' с Бессмертного демона Пустоты. После чего вы сможете выбить 'Токопроводящий кожух', 'Дуговая схема' и 'Энергетическая ячейка' с мобов вокруг. Собрав все предметы, получаете задание - Командир на палубе!";
_L["Squadron Commander Vishax"] = "Командир отряда Вишакс";
_L["Squadron Commander Vishax_search"] = { "vis", "вишакс", "vishax", "visax" };
_L["Squadron Commander Vishax_note"] = "Используйте портал по координатам 77.4 74.9";
_L["Doomcaster Suprax"] = "Навлекающий погибель Супракс";
_L["Doomcaster Suprax_search"] = { "sup", "супракс", "супра", "suprax" };
_L["Doomcaster Suprax_note"] = "На земле расположены три фиолетовые руны (север, восток, запад), в которые должны одновременно встать три человека. Не сбивайте произнесение Звезда рока.";
_L["Mother Rosula"] = "Мать Росула";
_L["Mother Rosula_search"] = { "ros", "росула" ,"rosula" };
_L["Mother Rosula_note"] = "Рарника необходимо призывать. Вход в пещеру на мосту 65.58 26.81 , там же где и Пузцилла. В самой пещере убиваете маленьких бесов и собираете с них 'Мясо беса' - 100 шт. После чего создаете 'Омерзительные яства' и ставите рядом с бассейном с рыбными костями (напротив второй матери бесов). Координаты призыва - 66.7 18.04";
_L["Rezira the Seer"] = "Провидец Резира";
_L["Rezira the Seer_search"] = { "rez", "rezira", "резира" };
_L["Rezira the Seer_note"] = "Доступен только через портал, который открывается с помощью 'Резонатор Места наблюдателя'. Его можно купить у Орикс Всевидящий (60.2, 45.4) за 500 'Невредимый глаз демона'. После открытия портала, в него может зайти любой игрок, любой фракции.";
_L["Blistermaw"] = "Язвоглот";
_L["Blistermaw_search"] = { "blis", "язвоглот", "язва", "blister" };
_L["Blistermaw_note"] = "";
_L["Mistress Il'thendra"] = "Госпожа Ил'тендра";
_L["Mistress Il'thendra_search"] = { "then", "илтендра", "thendra" };
_L["Mistress Il'thendra_note"] = "";
_L["Gar'zoth"] = "Гар'зот";
_L["Gar'zoth_search"] = { "gar", "гарзот", "garzot" };
_L["Gar'zoth_note"] = "";

_L["One-of-Many"] = "Многоликий";
_L["One-of-Many_note"] = "";
_L["Minixis"] = "Миниксис";
_L["Minixis_note"] = "";
_L["Watcher"] = "Дозорный";
_L["Watcher_note"] = "";
_L["Bloat"] = "Вспучень";
_L["Bloat_note"] = "";
_L["Earseeker"] = "Ухокус";
_L["Earseeker_note"] = "";
_L["Pilfer"] = "Воришка";
_L["Pilfer_note"] = "";

_L["Orix the All-Seer"] = "Орикс Всевидящий";
_L["Orix the All-Seer_note"] = "60.2, 45.4 - Под мостом, в пещере. Продает предметы за 'Невредимый глаз демона'.";

-- Shoot First, Loot Later
_L["Forgotten Legion Supplies"] = "Забытые припасы Легиона";
_L["Forgotten Legion Supplies_note"] = "Чтобы убрать камни, используйте 'Экзоскелет озаренных' - способность 'Рыцарский рывок'.";
_L["Ancient Legion War Cache"] = "Древний военный тайник Легиона";
_L["Ancient Legion War Cache_note"] = "На уступе, нужно спрыгнуть сверху. Чтобы убрать камни, используйте 'Правосудие Света'.";
_L["Fel-Bound Chest"] = "Скованный Скверной сундук";
_L["Fel-Bound Chest_note"] = "Чтобы убрать камни, используйте 'Правосудие Света'.";
_L["Legion Treasure Hoard"] = "Собранные Легионом сокровища";
_L["Legion Treasure Hoard_note"] = "За зеленым водопадом, на уступе.";
_L["Timeworn Fel Chest"] = "Сундук Скверны с Древнего берега";
_L["Timeworn Fel Chest_note"] = "Внизу, под скалами";
_L["Missing Augari Chest"] = "Пропавший сундук авгари";
_L["Missing Augari Chest_note"] = "Используйте 'Магический покров', чтобы получить доступ к сундуку.";

-- 48382
_L["48382_67546980_note"] = "Внутри здания";
_L["48382_67466226_note"] = "";
_L["48382_71326946_note"] = "";
_L["48382_58066806_note"] = "";
_L["48382_68026624_note"] = "";
_L["48382_64506868_note"] = "Снаружи";
_L["48382_62666823_note"] = "Внутри здания";
_L["48382_60096945_note"] = "За зданием";
-- 48383
_L["48383_56903570_note"] = "";
_L["48383_57633179_note"] = "";
_L["48383_52182918_note"] = "";
_L["48383_58174021_note"] = "";
_L["48383_51863409_note"] = "";
_L["48383_55133930_note"] = "";
_L["48383_58413097_note"] = "Внутри здания";
_L["48383_53753556_note"] = "";
_L["48383_51703529_note"] = "На скале";
_L["48383_59853583_note"] = "";
_L["48383_58273570_note"] = "Внутри здания"
-- 48384
_L["48384_60872900_note"] = "";
_L["48384_61332054_note"] = "Внутри здания";
_L["48384_59081942_note"] = "Внутри здания";
_L["48384_64152305_note"] = "Внутри пещеры";
_L["48384_66621709_note"] = "Внутри пещеры с бесами";
_L["48384_63682571_note"] = "У входа в пещеру";
_L["48384_61862236_note"] = "За зданием";
_L["48384_64132738_note"] = "";
-- 48385
_L["48385_50605720_note"] = "";
_L["48385_55544743_note"] = "";
_L["48385_57135124_note"] = "";
_L["48385_55915425_note"] = "";
_L["48385_48195451_note"] = "";
-- 48387
_L["48387_69403965_note"] = "";
_L["48387_66643654_note"] = "";
_L["48387_68983342_note"] = "";
_L["48387_65522831_note"] = "Под мостом";
_L["48387_63613643_note"] = "";
_L["48387_73404669_note"] = "";
_L["48387_67954006_note"] = "";
_L["48387_63603642_note"] = "";
-- 48388
_L["48388_51502610_note"] = "";
_L["48388_59261743_note"] = "";
_L["48388_55921387_note"] = "";
_L["48388_55841722_note"] = "";
_L["48388_55622042_note"] = "";
_L["48388_59661398_note"] = "";
_L["48388_54102803_note"] = "";
-- 48389
_L["48389_64305040_note"] = "В пещере где стоит Варга";
_L["48389_60254351_note"] = "";
_L["48389_65514081_note"] = "";
_L["48389_60304675_note"] = "";
_L["48389_65345192_note"] = "В пещере где стоит Варга";
_L["48389_64114242_note"] = "Наверху";
_L["48389_58734323_note"] = "";
_L["48389_62955007_note"] = "";
-- 48390
_L["48390_81306860_note"] = "На корабле где стоит Командир Текслаз";
_L["48390_80406152_note"] = "";
_L["48390_82566503_note"] = "На корабле где стоит Командир Текслаз";
_L["48390_73316858_note"] = "Наверху";
_L["48390_77127529_note"] = "";
_L["48390_72527293_note"] = "";
_L["48390_77255876_note"] = "Внизу";
_L["48390_72215680_note"] = "Внутри здания";
_L["48390_73277299_note"] = "";
_L["48390_77975620_note"] = "Внизу"
_L["48390_77246412_note"] = "Осторожно, не сорвитесь вниз";
-- 48391
_L["48391_64135867_note"] = "Внизу, в пещере где стоит Яд'орн";
_L["48391_67404790_note"] = "В маленькой пещере, в ущелье с пауками";
_L["48391_63615622_note"] = "Внизу, в пещере где стоит Яд'орн";
_L["48391_65005049_note"] = "";
_L["48391_63035762_note"] = "Внизу, в пещере где стоит Яд'орн";
_L["48391_65185507_note"] = "";
_L["48391_68095075_note"] = "В маленькой пещере, в ущелье с пауками";
_L["48391_69815522_note"] = "";
_L["48391_71205441_note"] = "";
_L["48391_66544668_note"] = "Наверху, на камнях";
_L["48391_65164951_note"] = "В маленькой пещере, в ущелье с пауками"

-- Krokuun
_L["Khazaduum"] = "Казадуум";
_L["Khazaduum_search"] = { "aza", "казадуум", "казадум", "khazadum", "khazaduum", "kazadum" };
_L["Khazaduum_note"] = "Вход в пещеру 50.3 17.3. Если активно локальное задание 'Оборона шпиля', то Рарник не будет доступен пока не завершено это задание.";
_L["Commander Sathrenael"] = "Командир Сатренаэль";
_L["Commander Sathrenael_search"] = { "sat", "сатренаэль", "sathrenael" };
_L["Commander Sathrenael_note"] = "";
_L["Commander Endaxis"] = "Командир Эндаксий";
_L["Commander Endaxis_search"] = { "end", "эндаксий", "endaxis" };
_L["Commander Endaxis_note"] = "";
_L["Sister Subversia"] = "Сестра Диверсия";
_L["Sister Subversia_search"] = { "sub", "сестра диверсия", "subversia" };
_L["Sister Subversia_note"] = "Подчиняет всех в радиусе метров 10-15 вокруг себя. Перед кастом лучше отпрыгнуть или отбежать подальше.";
_L["Siegemaster Voraan"] = "Осадный мастер Вораан";
_L["Siegemaster Voraan_search"] = { "vor", "вораан", "voran", "voraan" };
_L["Siegemaster Voraan_note"] = "";
_L["Talestra the Vile"] = "Талестра Злобная";
_L["Talestra the Vile_search"] = { "tal", "талестра", "talestra" };
_L["Talestra the Vile_note"] = "";
_L["Commander Vecaya"] = "Командир Викайя";
_L["Commander Vecaya_search"] = { "vec", "викайя", "veca[yj]a" };
_L["Commander Vecaya_note"] = "Ходит наверху, на балконе Ксенодара.";
_L["Vagath the Betrayed"] = "Вагат Обманутый";
_L["Vagath the Betrayed_search"] = { "vag", "вагат", "vagat" };
_L["Vagath the Betrayed_note"] = "Служил Иллидану в Черном храме, во время вторжения предал его и перешел на сторону Легиона.";
_L["Tereck the Selector"] = "Терек Подборщик";
_L["Tereck the Selector_search"] = { "ter", "терек", "tereck", "terek" };
_L["Tereck the Selector_note"] = "";
_L["Tar Spitter"] = "Смолоплюй";
_L["Tar Spitter_search"] = { "tar", "смолоплюй", "tar.*spitter" };
_L["Tar Spitter_note"] = "";
_L["Imp Mother Laglath"] = "Мать бесов Леглата";
_L["Imp Mother Laglath_search"] = { "lag", "леглата", "laglat" };
_L["Imp Mother Laglath_note"] = "";
_L["Naroua"] = "Нароу";
_L["Naroua_search"] = { "nar", "нароу", "naroua" };
_L["Naroua_note"] = "";

_L["Baneglow"] = "Гиблосвет";
_L["Baneglow_note"] = "";
_L["Foulclaw"] = "Мерзокоготь";
_L["Foulclaw_note"] = "";
_L["Ruinhoof"] = "Сквернорог";
_L["Ruinhoof_note"] = "";
_L["Deathscreech"] = "Смертокрик";
_L["Deathscreech_note"] = "В пещере";
_L["Gnasher"] = "Костеглод";
_L["Gnasher_note"] = "";
_L["Retch"] = "Тошнотик";
_L["Retch_note"] = "";

-- Shoot First, Loot Later
_L["Krokul Emergency Cache"] = "Неприкосновенные запасы крокула";
_L["Krokul Emergency Cache_note"] = "Чтобы убрать камни, используйте 'Экзоскелет озаренных' - способность 'Рыцарский рывок'.";
_L["Legion Tower Chest"] = "Сундук из башни Легиона";
_L["Legion Tower Chest_note"] = "Чтобы убрать камни, используйте 'Правосудие Света'.";
_L["Lost Krokul Chest"] = "Потерянный сундук крокула";
_L["Lost Krokul Chest_note"] = "Чтобы убрать камни, используйте 'Правосудие Света'.";
_L["Long-Lost Augari Treasure"] = "Давно утерянные сокровища авгари";
_L["Long-Lost Augari Treasure_note"] = "Используйте 'Магический покров', чтобы получить доступ к сундуку.";
_L["Precious Augari Keepsakes"] = "Бесценные сувениры авгари";
_L["Precious Augari Keepsakes_note"] = "Используйте 'Магический покров', чтобы получить доступ к сундуку.";

-- 47752
_L["47752_55555863_note"] = "";
_L["47752_52185431_note"] = "";
_L["47752_50405122_note"] = "";
_L["47752_53265096_note"] = "";
_L["47752_57005472_note"] = "Под скалой";
_L["47752_59695196_note"] = "За камнями";
_L["47752_51425958_note"] = "";
_L["47752_55525237_note"] = "";
-- 47753
_L["47753_53137304_note"] = "";
_L["47753_55228114_note"] = "";
_L["47753_59267341_note"] = "";
_L["47753_56118037_note"] = "Снаружи здания";
_L["47753_58597958_note"] = "";
_L["47753_58197157_note"] = "";
_L["47753_52737591_note"] = "За камнями";
_L["47753_58048036_note"] = "";
-- 47997
_L["47997_45876777_note"] = "Рядом с мостом";
_L["47997_45797753_note"] = "";
_L["47997_43858139_note"] = "";
_L["47997_43816689_note"] = "Под камнями";
_L["47997_40687531_note"] = "";
_L["47997_46996831_note"] = "";
_L["47997_41438003_note"] = "";
_L["47997_41548379_note"] = "";
_L["47997_46458665_note"] = "";
_L["47997_40357414_note"] = "";
_L["47997_44198653_note"] = "";
-- 47999
_L["47999_62592581_note"] = "";
_L["47999_59763951_note"] = "";
_L["47999_59071884_note"] = "За камнями, наверху";
_L["47999_61643520_note"] = "";
_L["47999_61463580_note"] = "Внутри здания";
_L["47999_59603052_note"] = "";
_L["47999_60891852_note"] = "Внутри здания";
_L["47999_49063350_note"] = "";
_L["47999_65992286_note"] = "";
_L["47999_64632319_note"] = "Внутри здания";
_L["47999_51533583_note"] = "";
_L["47999_60422354_note"] = "";
_L["47999_62763812_note"] = "Внутри здания";
-- 48000
_L["48000_70907370_note"] = "";
_L["48000_74136790_note"] = "";
_L["48000_75166435_note"] = "";
_L["48000_69605772_note"] = "";
_L["48000_69787836_note"] = "";
_L["48000_68566054_note"] = "";
_L["48000_72896482_note"] = "";
_L["48000_71827536_note"] = "";
_L["48000_73577146_note"] = "";
_L["48000_71846166_note"] = "";
_L["48000_67886231_note"] = "За колонной";
_L["48000_74996922_note"] = "";
-- 48336
_L["48336_33575511_note"] = "Наверху Ксенодара";
_L["48336_32047441_note"] = "";
_L["48336_27196668_note"] = "";
_L["48336_31936750_note"] = "";
_L["48336_35415637_note"] = "";
_L["48336_29645761_note"] = "Внутри пещеры";
_L["48336_40526067_note"] = "Внутри здания";
_L["48336_36205543_note"] = "Внутри Ксенодара";
_L["48336_25996814_note"] = "";
_L["48336_37176401_note"] = "";
_L["48336_28247134_note"] = "";
_L["48336_30276403_note"] = "Внутри";
_L["48336_34566305_note"] = "";
-- 48339
_L["48339_68533891_note"] = "";
_L["48339_63054240_note"] = "";
_L["48339_64964156_note"] = "";
_L["48339_73393438_note"] = "";
_L["48339_72213234_note"] = "За большим черепом";
_L["48339_65983499_note"] = "";
_L["48339_64934217_note"] = "Внутри ствола дерева";
_L["48339_67713454_note"] = "";
_L["48339_72493605_note"] = "";
_L["48339_44864342_note"] = "";

-- Mac'Aree
_L["Shadowcaster Voruun"] = "Темный чародей Воруун";
_L["Shadowcaster Voruun_search"] = { "vor", "ваоруун", "voruun", "vorun" };
_L["Shadowcaster Voruun_note"] = "";
_L["Soultwisted Monstrosity"] = "Искаженное чудовище";
_L["Soultwisted Monstrosity_search"] = { "mon", "искаженное чудовище", "monstro" };
_L["Soultwisted Monstrosity_note"] = "";
_L["Wrangler Kravos"] = "Пастух Кравос";
_L["Wrangler Kravos_search"] = { "kra", "кравос", "kravos" };
_L["Wrangler Kravos_note"] = "";
_L["Kaara the Pale"] = "Каара Бледная";
_L["Kaara the Pale_search"] = { "ka", "каара", "ka?ara" };
_L["Kaara the Pale_note"] = "";
_L["Feasel the Muffin Thief"] = "Физл Кексовор";
_L["Feasel the Muffin Thief_search"] = { "f", "feasel", "muffin" };
_L["Feasel the Muffin Thief_note"] = "Не бейте его, он такой грустный (";
_L["Vigilant Thanos"] = "Дозорный Танос";
_L["Vigilant Thanos_search"] = { "ano", "танос", "th?anos" };
_L["Vigilant Thanos_note"] = "";
_L["Vigilant Kuro"] = "Дозорный Куро";
_L["Vigilant Kuro_search"] = { "kuro", "куро", "kuro" };
_L["Vigilant Kuro_note"] = "";
_L["Venomtail Skyfin"] = "Ядовитый небесный скат";
_L["Venomtail Skyfin_search"] = { "i", "скат", "venomtail", "skyfin" };
_L["Venomtail Skyfin_note"] = "";
_L["Turek the Lucid"] = "Турек Мерцающий";
_L["Turek the Lucid_search"] = { "tur", "турек", "turek" };
_L["Turek the Lucid_note"] = "Внутри здания";
_L["Captain Faruq"] = "Капитан Фарук";
_L["Captain Faruq_search"] = { "far", "фарук", "faruq" };
_L["Captain Faruq_note"] = "";
_L["Umbraliss"] = "Мраколиск";
_L["Umbraliss_search"] = { "umb", "мраколиск", "umbralis" };
_L["Umbraliss_note"] = "";
_L["Sorolis the Ill-Fated"] = "Соролис Нелюбимец Судьбы";
_L["Sorolis the Ill-Fated_search"] = { "sor", "соролис", "sorolis" };
_L["Sorolis the Ill-Fated_note"] = "";
_L["Herald of Chaos"] = "Вестник хаоса";
_L["Herald of Chaos_search"] = { "a", "вестник хаоса", "herald", "harald" };
_L["Herald of Chaos_note"] = "Моб на втором этаже";
_L["Sabuul"] = "Сабуул";
_L["Sabuul_search"] = { "sab", "сабуул", "sabuul", "sabul" };
_L["Sabuul_note"] = "";
_L["Jed'hin Champion Vorusk"] = "Чемпион джед'хин Воруск";
_L["Jed'hin Champion Vorusk_search"] = { "vorusk", "воруск", "jed.?hin" };
_L["Jed'hin Champion Vorusk_note"] = "";
_L["Overseer Y'Beda"] = "Надзирательница И'Беда";
_L["Overseer Y'Beda_search"] = { "beda", "ибеда", "beda" };
_L["Overseer Y'Beda_note"] = "";
_L["Overseer Y'Sorna"] = "Надзирательница И'cорна";
_L["Overseer Y'Sorna_search"] = { "sor", "исорна", "sorna" };
_L["Overseer Y'Sorna_note"] = "";
_L["Overseer Y'Morna"] = "Надзирательница И'Морна";
_L["Overseer Y'Morna_search"] = { "mor", "иморна", "morna" };
_L["Overseer Y'Morna_note"] = "";
_L["Instructor Tarahna"] = "Инструктор Тарахна";
_L["Instructor Tarahna_search"] = { "tara", "тарахна", "tarahna", "tarana" };
_L["Instructor Tarahna_note"] = "";
_L["Zul'tan the Numerous"] = "Зул'тан Многоликий";
_L["Zul'tan the Numerous_search"] = { "zul", "зултан", "zul.?tan" };
_L["Zul'tan the Numerous_note"] = "Внутри здания";
_L["Commander Xethgar"] = "Командир Ксетгар";
_L["Commander Xethgar_search"] = { "xet", "ксетгар", "xethgar" };
_L["Commander Xethgar_note"] = "";
_L["Skreeg the Devourer"] = "Скрииг Пожиратель";
_L["Skreeg the Devourer_search"] = { "skr", "скрииг", "skreeg", "skreg" };
_L["Skreeg the Devourer_note"] = "";
_L["Baruut the Bloodthirsty"] = "Баруут Кровожадный";
_L["Baruut the Bloodthirsty_search"] = { "ba", "барут", "баруут", "baruut", "barut" };
_L["Baruut the Bloodthirsty_note"] = "";
_L["Ataxon"] = "Атаксон";
_L["Ataxon_search"] = { "ata", "атаксон", "ataxon" };
_L["Ataxon_note"] = "";
_L["Slithon the Last"] = "Последний из Змеев";
_L["Slithon the Last_search"] = { "sli", "slithon" };
_L["Slithon the Last_note"] = "";

_L["Gloamwing"] = "Мракокрыл";
_L["Gloamwing_note"] = "";
_L["Bucky"] = "Баки";
_L["Bucky_note"] = "";
_L["Mar'cuus"] = "Мар'куус";
_L["Mar'cuus_note"] = "";
_L["Snozz"] = "Храпун";
_L["Snozz_note"] = "";
_L["Corrupted Blood of Argus"] = "Порченая кровь Аргуса";
_L["Corrupted Blood of Argus_note"] = "";
_L["Shadeflicker"] = "Тенепрыг";
_L["Shadeflicker_note"] = "";

_L["Nabiru"] = "Набиру"
_L["Nabiru_note"] = "В пещере, внизу. Вход в пещеру 42.3,63.5. Продает прислужников - 'Очищенный от Бездны крокул' - за 900 ресурсов оплота.";

-- Shoot First, Loot Later
_L["Eredar Treasure Cache"] = "Эредарский сундук с сокровищами";
_L["Eredar Treasure Cache_note"] = "Чтобы убрать камни, используйте 'Экзоскелет озаренных' - способность 'Рыцарский рывок'.";
_L["Chest of Ill-Gotten Gains"] = "Сундук украденных сокровищ";
_L["Chest of Ill-Gotten Gains_note"] = "Чтобы убрать камни, используйте 'Правосудие Света'.";
_L["Student's Surprising Surplus"] = "Удивительный улов ученика";
_L["Student's Surprising Surplus_note"] = "В пещере, вход 62.2, 72.2. Чтобы убрать камни, используйте 'Правосудие Света'.";
_L["Void-Tinged Chest"] = "Опаленный Бездной сундук";
_L["Void-Tinged Chest_note"] = "Чтобы убрать камни, используйте 'Экзоскелет озаренных' - способность 'Рыцарский рывок'.";
_L["Augari Secret Stash"] = "Авгарский тайник";
_L["Augari Secret Stash_note"] = "Удобней всего добраться, используя 'Набор для сборки гоблинского планера' с координат 68.0, 56.9";
_L["Desperate Eredar's Cache"] = "Тайник отчаянного эредара";
_L["Desperate Eredar's Cache_note"] = "Прыгаем по камням вдоль здания, начиная с 57.1, 74.3 .";
_L["Shattered House Chest"] = "Сундук из расколотого дома";
_L["Shattered House Chest_note"] = "Используя 'Набор для сборки гоблинского планера' прыгаем с точки 31.2, 44.9, и в полете поворачиваете на право в здание с сундуком.";
_L["Doomseeker's Treasure"] = "Сокровища искателя погибели";
_L["Doomseeker's Treasure_note"] = "Сундук находится под землей. Нужно спрыгнуть в дыру, рядом водопадом. Для удобства можно использовать 'Набор для сборки гоблинского планера'.";
_L["Augari-Runed Chest"] = "Сундук с рунами авгари";
_L["Augari-Runed Chest_note"] = "Сундук под деревом. Используйте 'Магический покров', чтобы получить к нему доступ.";
_L["Secret Augari Chest"] = "Тайный сундук авгари";
_L["Secret Augari Chest_note"] = "Используйте 'Магический покров', чтобы получить доступ к сундуку.";
_L["Augari Goods"] = "Склад авгари";
_L["Augari Goods_note"] = "Используйте 'Магический покров', чтобы получить доступ к сундуку.";
-- Ancient Eredar Cache
-- 48346
_L["48346_55167766_note"] = "";
_L["48346_59386372_note"] = "" ;
_L["48346_57486159_note"] = "Внутри здания" ;
_L["48346_50836729_note"] = "";
_L["48346_52868241_note"] = "";
_L["48346_47186234_note"] = "";
_L["48346_50107580_note"] = "";
_L["48346_53328001_note"] = "В подвале"
-- 48350
_L["48350_59622088_note"] = "Внутри здания под лестницей";
_L["48350_60493338_note"] = "Внутри здания";
_L["48350_53912335_note"] = "Внутри здания";
_L["48350_55063508_note"] = "";
_L["48350_62202636_note"] = "Внутри здания, на балконе";
_L["48350_53332740_note"] = "Под деревом";
_L["48350_58574078_note"] = "";
_L["48350_63262000_note"] = "Внутри здания";
_L["48350_54952484_note"] = "";
-- 48351
_L["48351_43637134_note"] = "";
_L["48351_34205929_note"] = "На втором этаже";
_L["48351_43955630_note"] = "Под деревом";
_L["48351_46917346_note"] = "Под деревом";
_L["48351_36296646_note"] = "";
_L["48351_42645361_note"] = "В пещере";
_L["48351_38126342_note"] = "В подвале";
_L["48351_42395752_note"] = "Внутри здания где сидит Турек Мерцающий";
_L["48351_39175934_note"] = "Внутри разрушенного здания";
											  
-- 48357
_L["48357_49412387_note"] = "";
_L["48357_47672180_note"] = "";
_L["48357_48482115_note"] = "";
_L["48357_57881053_note"] = "";
_L["48357_52871676_note"] = "Up the stairs";
_L["48357_47841956_note"] = "";
_L["48357_51802871_note"] = "In the area up the northern stairs";
_L["48357_49912946_note"] = "";
_L["48357_54951750_note"] = "";
_L["48357_46381509_note"] = "";
_L["48357_50021442_note"] = "";
-- 48371
_L["48371_48604971_note"] = "";
_L["48371_49865494_note"] = "";
_L["48371_47023655_note"] = "Наверху";
_L["48371_49623585_note"] = "Наверху";
_L["48371_51094790_note"] = "Под деревом";
_L["48371_35535718_note"] = "На втором этаже";
_L["48371_25383016_note"] = "";
_L["48371_53594211_note"] = "";
_L["48371_59405863_note"] = "";
-- 48362
_L["48362_66682786_note"] = "Внутри здания";
_L["48362_62134077_note"] = "Внутри здания";
_L["48362_67254608_note"] = "Внутри здания";
_L["48362_68355322_note"] = "Внутри здания";
_L["48362_65966017_note"] = "";
_L["48362_62053268_note"] = "Наверху";
_L["48362_60964354_note"] = "Внутри здания";
_L["48362_64445956_note"] = "Внутри здания";
_L["48362_65354194_note"] = "";
-- Void-Seeped Cache / Treasure Chest
-- 49264
_L["49264_38143985_note"] = "";
_L["49264_37613608_note"] = "";
_L["49264_37812344_note"] = "";
_L["49264_33972078_note"] = "";
_L["49264_33312952_note"] = "";
_L["49264_37102005_note"] = "";
_L["49264_33592361_note"] = "Под деревом"
_L["49264_31582553_note"] = "";
_L["49264_32332131_note"] = "За углом";
-- 48361
_L["48361_37664221_note"] = "За колонной";
_L["48361_25824471_note"] = "";
_L["48361_20674033_note"] = "";
_L["48361_29503999_note"] = "";
_L["48361_29455043_note"] = "Под деревом";
_L["48361_18794171_note"] = "За зданием";
_L["48361_25293498_note"] = "";
_L["48361_35283586_note"] = ""
_L["48361_24654126_note"] = "";
_L["48361_37754868_note"] = "Внизу, в пещере"											   

--
--	KEEP THESE ENGLISH FOR THE GROUP BROWSER IN EU/US!! CHINA & CO ADJUST
--	SEARCH ARRAY AS BEFORE, MUST HAVE MINIMUM 2 ELEMENTS
--

_L["Invasion Point: Val"] = "Точка вторжения: Вал";
_L["Invasion Point: Aurinor"] = "Точка вторжения: Ауринор";
_L["Invasion Point: Sangua"] = "Точка вторжения: Сангва";
_L["Invasion Point: Naigtal"] = "Точка вторжения: Найтал";
_L["Invasion Point: Bonich"] = "Точка вторжения: Боних";
_L["Invasion Point: Cen'gar"] = "Точка вторжения: Сен'гар";
_L["Greater Invasion Point: Mistress Alluradel"] = "Точка массированного вторжения: госпожа Аллюрадель";
_L["Greater Invasion Point: Matron Folnuna"] = "Точка массированного вторжения: госпожа Фолнуна";
_L["Greater Invasion Point: Sotanathor"] = "Точка массированного вторжения: Сотанатор";

_L["invasion_val_search"] = { "val", "вал", "invasion.*val", "val.*invasion" };
_L["invasion_aurinor_search"] = { "aurinor", "ауринор", "aurinor" };
_L["invasion_sangua_search"] = { "sangua", "сангва", "sangua" };
_L["invasion_naigtal_search"] = { "naigtal", "найтал", "naigtal" };
_L["invasion_bonich_search"] = { "bonich", "боних", "bonich" };
_L["invasion_cengar_search"] = { "cen", "сенгар", "cen.*gar" };
_L["invasion_alluradel_search"] = { "radel", "аллюрадель", "аллюра", "alluradel" };
_L["invasion_folnuna_search"] = { "fol", "фолуна", "folnuna" };
_L["invasion_sotanathor_search"] = { "sot", "сотанатор", "sotana" };

--
--
-- INTERFACE
--
--

_L["Argus"] = "HandyNotes Аргус";
_L["Antoran Wastes"] = "Пустоши Анторуса";
_L["Krokuun"] = "Крокуун";
_L["Mac'Aree"] = "Мак'Ари";

_L["Shield"] = "Щит";
_L["Cloth"] = "Ткань";
_L["Leather"] = "Кожа";
_L["Mail"] = "Кольчуга";
_L["Plate"] = "Латы";
_L["1h Mace"] = "Одноручное Дробящее";
_L["1h Sword"] = "Одноручный Меч";
_L["1h Axe"] = "Одноручный Топор";
_L["2h Mace"] = "Двуручное Дробящее";
_L["2h Axe"] = "Двуручный Топор";
_L["2h Sword"] = "Двуручный Меч";
_L["Dagger"] = "Кинжал";
_L["Staff"] = "Посох";
_L["Fist"] = "Кистевое";
_L["Polearm"] = "Древковое";
_L["Bow"] = "Лук";
_L["Gun"] = "Огнестрельное";
_L["Crossbow"] = "Арбалет";

_L["groupBrowserOptionOne"] = "%s - участники: %s (создана %s назад)";
_L["groupBrowserOptionMore"] = "%s - участники: %s (создана %s назад)";
_L["chatmsg_no_group_priv"] = "|cFFFF0000Недостаточно прав. Вы не являетесь лидером группы.";
_L["chatmsg_group_created"] = "|cFF6CF70FСоздана группа для %s.";
_L["chatmsg_search_failed"] = "|cFFFF0000Слишком много запросов, пожалуйста подождите несколько секунд.";
_L["hour_short"] = " ч";
_L["minute_short"] = " мин.";
_L["second_short"] = " сек.";

-- KEEP THESE 2 ENGLISH IN EU/US
_L["listing_desc_rare"] = "Автоматически созданная группа для %s.";
_L["listing_desc_invasion"] = "Автоматически созданная группа для %s.";

_L["Pet"] = "Питомец";
_L["(Mount known)"] = "(|cFF00FF00Уже есть|r)";
_L["(Mount missing)"] = "(|cFFFF0000Еще не получен|r)";
_L["(Toy known)"] = "(|cFF00FF00Уже есть|r)";
_L["(Toy missing)"] = " (|cFFFF0000Предмет еще не получен|r)";
_L["(itemLinkGreen)"] = "(|cFF00FF00%s|r)";
_L["(itemLinkRed)"] = "(|cFFFF0000%s|r)";
_L["Retrieving data ..."] = "Получение данных ...";
_L["Sorry, no groups found!"] = "Группы не найдены!";
_L["Search in Quests"] = "Поиск в заданиях";
_L["Groups found:"] = "Найденные группы:";
_L["Create new group"] = "Создать новую группу";
_L["Close"] = "Закрыть";

_L["context_menu_title"] = "HandyNotes Аргус";
_L["context_menu_check_group_finder"] = "Проверить наличие групп";
_L["context_menu_reset_rare_counters"] = "Сбросить счетчик групп";
_L["context_menu_add_tomtom"] = "Добавить в TomTom";
_L["context_menu_hide_node"] = "Спрятать эту точку";
_L["context_menu_restore_hidden_nodes"] = "Восстановить все скрытые ранее точки";

_L["options_title"] = "HandyNotes Аргус";

_L["options_icon_settings"] = "Настройки иконок";
_L["options_icon_settings_desc"] = "";
_L["options_icons_treasures"] = "Сундуки";
_L["options_icons_treasures_desc"] = "";
_L["options_icons_rares"] = "Рарники";
_L["options_icons_rares_desc"] = "";
_L["options_icons_pet_battles"] = "Боевые питомцы";
_L["options_icons_pet_battles_desc"] = "";
_L["options_icons_sfll"] = "'Стрелять сразу, грабить потом'";
_L["options_icons_sfll_desc"] = "Иконки сундуков для 'Стрелять сразу, грабить потом'";
_L["options_scale"] = "Масштаб";
_L["options_scale_desc"] = "";
_L["options_opacity"] = "Прозрачность";
_L["options_opacity_desc"] = "";
_L["options_visibility_settings"] = "Отображение";
_L["options_visibility_settings_desc"] = "Отображение";
_L["options_toggle_treasures"] = "Сундуки";
_L["options_toggle_rares"] = "Рарники";
_L["options_toggle_battle_pets"] = "Боевые Питомцы";
_L["options_toggle_sfll"] = "'Стрелять сразу, грабить потом'";
_L["options_toggle_npcs"] = "NPCs";
_L["options_toggle_portals"] = "Порталы";
_L["options_general_settings"] = "Основные Настройки";
_L["options_general_settings_desc"] = "Основные Настройки";
_L["options_toggle_alreadylooted_rares"] = "Всегда показывать всех Рарников";
_L["options_toggle_alreadylooted_rares_desc"] = "Показывать всех Рарников вне зависимости убивали вы его сегодня или нет";
_L["options_toggle_alreadylooted_treasures"] = "Всегда показывать все сундуки";
_L["options_toggle_alreadylooted_treasures_desc"] = "Всегда показывать иконки с сундуками, вне зависимости собирали вы его уже или нет";
_L["options_toggle_alreadylooted_sfll"] = "Всегда показывать сундуки для 'Стрелять сразу, грабить потом'";
_L["options_toggle_alreadylooted_sfll_desc"] = "Показывать уже собранные сундуки для достижения 'Стрелять сразу, грабить потом'";
_L["options_toggle_nodeRareGlow"] = "Подсветка доступности Рарников |cFFFF0000*"
_L["options_toggle_nodeRareGlow_desc"] = "Добавляет эффекты к иконкам Рарников. Красный - мало групп. Зеленый - много групп, большая вероятность что Рарник на месте."
_L["options_tooltip_settings"] = "Заметки";
_L["options_tooltip_settings_desc"] = "Заметки";
_L["options_toggle_show_loot"] = "Показывать добычу";
_L["options_toggle_show_loot_desc"] = "Добавлять информацию о возможной добыче в подсказки";
_L["options_toggle_show_notes"] = "Подсказки";
_L["options_toggle_show_notes_desc"] = "Показывать дополнительную информацию в описании";

_L["options_general_settings"] = "Дополнительно";
_L["options_general_settings_desc"] = "";
_L["options_toggle_leave_group_on_search"] = "Покидать текущую группу |cFFFF0000*";
_L["options_toggle_leave_group_on_search_desc"] = "Покидать текущую группу, когда пытаетесь найти новую группу. Используйте осторожно!";
_L["chatmsg_old_group_delisted_create"] = "|cFFF7C92AСтарая группа убрана. Нажмите еще раз чтобы создать новую группу для %s."
_L["chatmsg_left_group_create"] = "|cFFF7C92AВы вышли из группы. Нажмите еще раз чтобы создать новую группу для %s.";
_L["chatmsg_old_group_delisted_search"] = "|cFFF7C92AСтарая группа убрана. Нажмите еще раз чтобы найти новую группу для %s."
_L["chatmsg_left_group_search"] = "|cFFF7C92AВы вышли из группы. Нажмите еще раз чтобы найти новую группу для %s.";

_L["options_toggle_include_player_seen"] = "Include player seen rares";
_L["options_toggle_include_player_seen_desc"] = "Don't use this yet.";
_L["options_toggle_show_debug"] = "Debug";
_L["options_toggle_show_debug_desc"] = "Азурегосу привет! )";

_L["options_toggle_hideKnowLoot"] = "Спрятать Рарников с которых получены все доступные предметы";
_L["options_toggle_hideKnowLoot_desc"] = "";

_L["options_toggle_alwaysTrackCoA"] = "Всегда отслеживать 'Аргусский командир'";
_L["options_toggle_alwaysTrackCoA_desc"] = "Всегда отслеживать 'Аргусский командир', даже если это достижение получено для учетной записи, но не для текущего персонажа.";

end