-- By D4KiR
local _, SpecBisTooltip = ...
local s = {}
if SpecBisTooltip:GetWoWBuild() == "MISTS" then
    function SpecBisTooltip:GetTranslationMap()
        return s
    end
end

-- SOURCE FROM: 02.12.2025
if SpecBisTooltip:GetWoWBuild() == "MISTS" then
    function SpecBisTooltip:TranslationenUS()
        s["npc;drop=55265"] = {"Morchok", "Dragon Soul"}
        s["npc;drop=56427"] = {"Warmaster Blackhorn", "Dragon Soul"}
        s["npc;sold=44245"] = {"Faldren Tillsdale <Valor Quartermaster>", "Stormwind City"}
        s["npc;drop=52571"] = {"Majordomo Staghelm <Archdruid of the Flame>", "Firelands"}
        s["npc;drop=53879"] = {"Deathwing <The Destroyer>", "Dragon Soul"}
        s["npc;drop=55294"] = {"Ultraxion", "Dragon Soul"}
        s["npc;sold=64606"] = {"Commander Oxheart <Valor Quartermaster>", "Townlong Steppes"}
        s["npc;drop=60583"] = {"Protector Kaolan", "Terrace of Endless Spring"}
        s["npc;drop=62543"] = {"Blade Lord Ta'yak", "Heart of Fear"}
        s["npc;drop=62980"] = {"Imperial Vizier Zor'lok <Voice of the Empress>", "Heart of Fear"}
        s["npc;drop=62837"] = {"Grand Empress Shek'zeer", "Heart of Fear"}
        s["npc;drop=62442"] = {"Tsulong", "Terrace of Endless Spring"}
        s["npc;drop=62983"] = {"Lei Shi", "Terrace of Endless Spring"}
        s["npc;drop=60400"] = {"Jan-xi <Emperor's Open Hand>", "Mogu'shan Vaults"}
        s["npc;drop=60999"] = {"Sha of Fear", "Terrace of Endless Spring"}
        s["npc;drop=62511"] = {"Amber-Shaper Un'sok", "Heart of Fear"}
        s["npc;drop=62397"] = {"Wind Lord Mel'jarak", "Heart of Fear"}
        s["npc;drop=60701"] = {"Zian of the Endless Shadow <Sorcerer King>", "Mogu'shan Vaults"}
        s["npc;drop=60410"] = {"Elegon", "Mogu'shan Vaults"}
        s["quest;reward=30452"] = {"Darkmoon Tiger Deck", "Elwynn Forest"}
        s["npc;drop=63191"] = {"Garalon", "Heart of Fear"}
        s["npc;drop=60399"] = {"Qin-xi <Emperor's Closed Fist>", "Mogu'shan Vaults"}
        s["npc;drop=60009"] = {"Feng the Accursed <Keeper of Champion Spirits>", "Mogu'shan Vaults"}
        s["npc;drop=60043"] = {"Jade Guardian", "Mogu'shan Vaults"}
        s["quest;reward=31612"] = {"Shadow of the Empire", "Dread Wastes"}
        s["npc;sold=59908"] = {"Jaluu the Generous <The Golden Lotus Quartermaster>", "Vale of Eternal Blossoms"}
        s["quest;reward=30451"] = {"Darkmoon Serpent Deck", "Elwynn Forest"}
        s["npc;drop=60143"] = {"Gara'jal the Spiritbinder", "Mogu'shan Vaults"}
        s["quest;reward=30449"] = {"Darkmoon Crane Deck", "Elwynn Forest"}
        s["npc;drop=60051"] = {"Cobalt Guardian", "Mogu'shan Vaults"}
        s["quest;reward=30450"] = {"Darkmoon Ox Deck", "Elwynn Forest"}
        s["npc;drop=59080"] = {"Darkmaster Gandling", "Scholomance"}
        s["npc;drop=64340"] = {"Instructor Maltik <Keeper of Unseen Strike>", "Heart of Fear"}
        s["npc;sold=69060"] = {"Tuskripper Grukna <Dominance Offensive Quartermaster>", "Krasarang Wilds"}
    end

    function SpecBisTooltip:TranslationdeDE()
        s["npc;drop=56427"] = {"Kriegsmeister Schwarzhorn", "Drachenseele"}
        s["npc;sold=44245"] = {"Faldren Tillsdale <Rüstmeister für Tapferkeitspunkte>", "Sturmwind"}
        s["npc;drop=52571"] = {"Majordomus Hirschhaupt <Erzdruide der Flamme>", "Feuerlande"}
        s["npc;drop=53879"] = {"Todesschwinge <Der Zerstörer>", "Drachenseele"}
        s["npc;sold=64606"] = {"Kommandantin Ochsenherz <Rüstmeisterin für Tapferkeitspunkte>", "Tonlongsteppe"}
        s["npc;drop=60583"] = {"Beschützer Kaolan", "Terrasse des Endlosen Frühlings"}
        s["npc;drop=62543"] = {"Klingenfürst Ta'yak", "Das Herz der Angst"}
        s["npc;drop=62980"] = {"Kaiserlicher Wesir Zor'lok <Stimme der Kaiserin>", "Das Herz der Angst"}
        s["npc;drop=62837"] = {"Großkaiserin Shek'zeer", "Das Herz der Angst"}
        s["npc;drop=60400"] = {"Jan-xi <Offene Hand des Kaisers>", "Mogu'shangewölbe"}
        s["npc;drop=60999"] = {"Sha der Angst", "Terrasse des Endlosen Frühlings"}
        s["npc;drop=62511"] = {"Bernformer Un'sok", "Das Herz der Angst"}
        s["npc;drop=62397"] = {"Windfürst Mel'jarak", "Das Herz der Angst"}
        s["npc;drop=60701"] = {"Zian des endlosen Schattens <Zaubererkönig>", "Mogu'shangewölbe"}
        s["quest;reward=30452"] = {"Tigerkartenset des Dunkelmond-Jahrmarkts", "Wald von Elwynn"}
        s["npc;drop=60399"] = {"Qin-xi <Geschlossene Faust des Kaisers>", "Mogu'shangewölbe"}
        s["npc;drop=60009"] = {"Feng der Verfluchte <Hüter der Champion-Geister>", "Mogu'shangewölbe"}
        s["npc;drop=60043"] = {"Jadewächter", "Mogu'shangewölbe"}
        s["quest;reward=31612"] = {"Schatten des Kaiserreichs", "Schreckensöde"}
        s["npc;sold=59908"] = {"Jaluu der Spendable <Rüstmeister des Goldenen Lotus>", "Tal der Ewigen Blüten"}
        s["quest;reward=30451"] = {"Schlangenkartenset des Dunkelmond-Jahrmarkts", "Wald von Elwynn"}
        s["npc;drop=60143"] = {"Gara'jal der Geisterbinder", "Mogu'shangewölbe"}
        s["quest;reward=30449"] = {"Kranichkartenset des Dunkelmond-Jahrmarkts", "Wald von Elwynn"}
        s["npc;drop=60051"] = {"Kobaltwächter", "Mogu'shangewölbe"}
        s["quest;reward=30450"] = {"Ochsenkartenset des Dunkelmond-Jahrmarkts", "Wald von Elwynn"}
        s["npc;drop=59080"] = {"Dunkelmeister Gandling", "Scholomance"}
        s["npc;drop=64340"] = {"Ausbilder Maltik <Bewahrer des ungesehenen Schlages>", "Das Herz der Angst"}
        s["npc;sold=69060"] = {"Fangzahnschlächter Gurkna <Rüstmeister der Herrschaftsoffensive>", "Krasarangwildnis"}
    end

    function SpecBisTooltip:TranslationesES()
        s["npc;drop=56427"] = {"Maestro de guerra Cuerno Negro", "Alma de Dragón"}
        s["npc;sold=44245"] = {"Faldren Labravalle <Intendente de valor>", "Ciudad de Ventormenta"}
        s["npc;drop=52571"] = {"Mayordomo Corzocelada <Archidruida de la Llama>", "Tierras de Fuego"}
        s["npc;drop=53879"] = {"Alamuerte <El Destructor>", "Alma de Dragón"}
        s["npc;sold=64606"] = {"Comandante Corazón de Buey <Intendente de valor>", "Estepas de Tong Long"}
        s["npc;drop=62543"] = {"Señor de las espadas Ta'yak", "Corazón del Miedo"}
        s["npc;drop=62980"] = {"Visir imperial Zor'lok <Voz de la Emperatriz>", "Corazón del Miedo"}
        s["npc;drop=62837"] = {"Gran emperatriz Shek'zeer", "Corazón del Miedo"}
        s["npc;drop=60400"] = {"Jan-xi <Mano abierta del Emperador>", "Cámaras Mogu'shan"}
        s["npc;drop=60999"] = {"Sha del miedo", "Veranda de la Primavera Eterna"}
        s["npc;drop=62511"] = {"Formador de ámbar Un'sok", "Corazón del Miedo"}
        s["npc;drop=62397"] = {"Señor del viento Mel'jarak", "Corazón del Miedo"}
        s["npc;drop=60701"] = {"Zian de la Sombra Infinita <Rey hechicero>", "Cámaras Mogu'shan"}
        s["quest;reward=30452"] = {"La baraja del tigre de la Luna Negra", "Bosque de Elwynn"}
        s["npc;drop=60399"] = {"Qin-xi <Puño cerrado del Emperador>", "Cámaras Mogu'shan"}
        s["npc;drop=60009"] = {"Feng el Detestable <Vigilante de espíritus campeones>", "Cámaras Mogu'shan"}
        s["npc;drop=60043"] = {"Guardián de jade", "Cámaras Mogu'shan"}
        s["quest;reward=31612"] = {"La sombra del imperio", "Desierto del Pavor"}
        s["npc;sold=59908"] = {"Jaluu el Generoso <Intendente de El Loto Dorado>", "Valle de la Flor Eterna"}
        s["quest;reward=30451"] = {"La baraja del dragón de la Luna Negra", "Bosque de Elwynn"}
        s["npc;drop=60143"] = {"Gara'jal el Vinculador de Espíritus", "Cámaras Mogu'shan"}
        s["quest;reward=30449"] = {"La baraja de la grulla de la Luna Negra", "Bosque de Elwynn"}
        s["npc;drop=60051"] = {"Guardián de cobalto", "Cámaras Mogu'shan"}
        s["quest;reward=30450"] = {"La baraja del buey de la Luna Negra", "Bosque de Elwynn"}
        s["npc;drop=59080"] = {"Maestro oscuro Gandling", "Scholomance"}
        s["npc;drop=64340"] = {"Instructor Maltik <Vigilante del Golpe invisible>", "Corazón del Miedo"}
        s["npc;sold=69060"] = {"Destripacolmillo Grukna <Intendente de la Ofensiva de Dominancia>", "Espesura Krasarang"}
    end

    function SpecBisTooltip:TranslationfrFR()
        s["npc;drop=56427"] = {"Maître de guerre Corne-Noire", "L’Âme des dragons"}
        s["npc;sold=44245"] = {"Faldren Tillsdale <Intendant des emblèmes de vaillance>", "Hurlevent"}
        s["npc;drop=52571"] = {"Chambellan Forteramure <Archidruide de la Flamme>", "Terres de Feu"}
        s["npc;drop=53879"] = {"Aile de mort <Le Destructeur>", "L’Âme des dragons"}
        s["npc;sold=64606"] = {"Commandant Cœur de Buffle <Intendant des emblèmes de vaillance>", "Steppes de Tanglong"}
        s["npc;drop=60583"] = {"Protecteur Kaolan", "Terrasse Printanière"}
        s["npc;drop=62543"] = {"Seigneur des lames Ta’yak", "Cœur de la peur"}
        s["npc;drop=62980"] = {"Vizir impérial Zor’lok <Voix de l’impératrice>", "Cœur de la peur"}
        s["npc;drop=62837"] = {"Grande impératrice Shek’zeer", "Cœur de la peur"}
        s["npc;drop=60400"] = {"Jan Xi <Main ouverte de l’empereur>", "Caveaux Mogu’shan"}
        s["npc;drop=60999"] = {"Sha de la peur", "Terrasse Printanière"}
        s["npc;drop=62511"] = {"Sculpte-ambre Un’sok", "Cœur de la peur"}
        s["npc;drop=62397"] = {"Seigneur du Vent Mel’jarak", "Cœur de la peur"}
        s["npc;drop=60701"] = {"Zian des Ombres éternelles <Roi-sorcier>", "Caveaux Mogu’shan"}
        s["quest;reward=30452"] = {"Suite de Tigres de Sombrelune", "Forêt d’Elwynn"}
        s["npc;drop=60399"] = {"Qin Xi <Poing fermé de l’empereur>", "Caveaux Mogu’shan"}
        s["npc;drop=60009"] = {"Feng le Maudit <Gardien des esprits de champions>", "Caveaux Mogu’shan"}
        s["npc;drop=60043"] = {"Gardien de jade", "Caveaux Mogu’shan"}
        s["quest;reward=31612"] = {"L'ombre de l'empire", "Terres de l’Angoisse"}
        s["npc;sold=59908"] = {"Jaluu le Généreux <Intendant du Lotus doré>", "Val de l’Éternel printemps"}
        s["quest;reward=30451"] = {"Suite de Serpents de Sombrelune", "Forêt d’Elwynn"}
        s["npc;drop=60143"] = {"Gara’jal le Lieur d’esprit", "Caveaux Mogu’shan"}
        s["quest;reward=30449"] = {"Suite de Grues de Sombrelune", "Forêt d’Elwynn"}
        s["npc;drop=60051"] = {"Gardien de cobalt", "Caveaux Mogu’shan"}
        s["quest;reward=30450"] = {"Suite de Buffles de Sombrelune", "Forêt d’Elwynn"}
        s["npc;drop=59080"] = {"Sombre Maître Gandling", "Scholomance"}
        s["npc;drop=64340"] = {"Instructeur Maltik <Gardien de l’attaque invisible>", "Cœur de la peur"}
        s["npc;sold=69060"] = {"Arrache-défenses Grukna <Intendante de l’offensive Domination>", "Étendues sauvages de Krasarang"}
    end

    function SpecBisTooltip:TranslationitIT()
        s["npc;drop=52571"] = {"Majordomo Staghelm <Archdruid of the Flame>", "Firelands"}
        s["quest;reward=30452"] = {"[Darkmoon Tiger Deck]", "Elwynn Forest"}
        s["quest;reward=31612"] = {"[Shadow of the Empire]", "Dread Wastes"}
        s["quest;reward=30451"] = {"[Darkmoon Serpent Deck]", "Elwynn Forest"}
        s["quest;reward=30449"] = {"[Darkmoon Crane Deck]", "Elwynn Forest"}
        s["quest;reward=30450"] = {"[Darkmoon Ox Deck]", "Elwynn Forest"}
    end

    function SpecBisTooltip:TranslationkoKR()
        s["npc;drop=55265"] = {"[Morchok]", "용의 영혼"}
        s["npc;drop=56427"] = {"[Warmaster Blackhorn]", "용의 영혼"}
        s["npc;sold=44245"] = {"폴드런 틸스데일 <용맹 병참장교>", "스톰윈드"}
        s["npc;drop=52571"] = {"청지기 스태그헬름 <화염의 대드루이드>", "불의 땅"}
        s["npc;drop=53879"] = {"[Deathwing] <[The Destroyer]>", "용의 영혼"}
        s["npc;drop=55294"] = {"[Ultraxion]", "용의 영혼"}
        s["npc;sold=64606"] = {"사령관 옥스하트 <용맹 병참장교>", "탕랑 평원"}
        s["npc;drop=60583"] = {"수호병 카오란", "영원한 봄의 정원"}
        s["npc;drop=62543"] = {"[Blade Lord Ta'yak]", "공포의 심장"}
        s["npc;drop=62980"] = {"황실 장로 조르로크 <여제의 목소리>", "공포의 심장"}
        s["npc;drop=62837"] = {"위대한 여제 셰크지르", "공포의 심장"}
        s["npc;drop=62442"] = {"출롱", "영원한 봄의 정원"}
        s["npc;drop=62983"] = {"레이 스", "영원한 봄의 정원"}
        s["npc;drop=60400"] = {"잔시 <황제의 펼친 손>", "모구샨 금고"}
        s["npc;drop=60999"] = {"공포의 샤", "영원한 봄의 정원"}
        s["npc;drop=62511"] = {"호박석구체자 운속", "공포의 심장"}
        s["npc;drop=62397"] = {"바람군주 멜자라크", "공포의 심장"}
        s["npc;drop=60701"] = {"영원한 어둠의 쯔안 <마술사 왕>", "모구샨 금고"}
        s["npc;drop=60410"] = {"엘레곤", "모구샨 금고"}
        s["quest;reward=30452"] = {"다크문 호랑이 카드 한 벌", "엘윈 숲"}
        s["npc;drop=63191"] = {"[Garalon]", "공포의 심장"}
        s["npc;drop=60399"] = {"친시 <황제의 꽉 쥔 주먹>", "모구샨 금고"}
        s["npc;drop=60009"] = {"저주받은 펑 <용사 영혼 관리자>", "모구샨 금고"}
        s["npc;drop=60043"] = {"비취 수호자", "모구샨 금고"}
        s["quest;reward=31612"] = {"제국의 그림자", "공포의 황무지"}
        s["npc;sold=59908"] = {"너그러운 잘루 <황금 연꽃 병참장교>", "영원꽃 골짜기"}
        s["quest;reward=30451"] = {"다크문 용 카드 한 벌", "엘윈 숲"}
        s["npc;drop=60143"] = {"영혼결속자 가라잘", "모구샨 금고"}
        s["quest;reward=30449"] = {"다크문 학 카드 한 벌", "엘윈 숲"}
        s["npc;drop=60051"] = {"코발트 수호자", "모구샨 금고"}
        s["quest;reward=30450"] = {"다크문 소 카드 한 벌", "엘윈 숲"}
        s["npc;drop=59080"] = {"암흑스승 간들링", "스칼로맨스"}
        s["npc;drop=64340"] = {"[Instructor Maltik] <[Keeper of Unseen Strike]>", "공포의 심장"}
        s["npc;sold=69060"] = {"엄니갈퀴 그루크나 <지배령 선봉대 병참장교>", "크라사랑 밀림"}
    end

    function SpecBisTooltip:TranslationptBR()
        s["npc;drop=55265"] = {"[Morchok]", "Alma Dragônica"}
        s["npc;drop=56427"] = {"[Warmaster Blackhorn]", "Alma Dragônica"}
        s["npc;sold=44245"] = {"Fernão Thadeo <Intendente de Bravura>", "Ventobravo"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "Terras do Fogo"}
        s["npc;drop=53879"] = {"[Deathwing] <[The Destroyer]>", "Alma Dragônica"}
        s["npc;drop=55294"] = {"[Ultraxion]", "Alma Dragônica"}
        s["npc;sold=64606"] = {"[Commander Oxheart] <[Valor Quartermaster]>", "Estepes de Taolong"}
        s["npc;drop=60583"] = {"Protetor Kaolan", "Terraço da Primavera Eterna"}
        s["npc;drop=62543"] = {"[Blade Lord Ta'yak]", "Coração do Medo"}
        s["npc;drop=62980"] = {"[Imperial Vizier Zor'lok] <[Voice of the Empress]>", "Coração do Medo"}
        s["npc;drop=62837"] = {"Grã-imperatriz Shek'zeer", "Coração do Medo"}
        s["npc;drop=60400"] = {"[Jan-xi] <[Emperor's Open Hand]>", "Galerias Mogu'shan"}
        s["npc;drop=60999"] = {"Sha do Medo", "Terraço da Primavera Eterna"}
        s["npc;drop=62511"] = {"Molda-âmbar Un'sok", "Coração do Medo"}
        s["npc;drop=62397"] = {"Senhor do Vento Mel'jarak", "Coração do Medo"}
        s["npc;drop=60701"] = {"[Zian of the Endless Shadow] <[Sorcerer King]>", "Galerias Mogu'shan"}
        s["quest;reward=30452"] = {"Baralho do Tigre de Negraluna", "Floresta de Elwynn"}
        s["npc;drop=63191"] = {"[Garalon]", "Coração do Medo"}
        s["npc;drop=60399"] = {"[Qin-xi] <[Emperor's Closed Fist]>", "Galerias Mogu'shan"}
        s["npc;drop=60009"] = {"[Feng the Accursed] <[Keeper of Champion Spirits]>", "Galerias Mogu'shan"}
        s["npc;drop=60043"] = {"[Jade Guardian]", "Galerias Mogu'shan"}
        s["quest;reward=31612"] = {"[Shadow of the Empire]", "Ermo do Medo"}
        s["npc;sold=59908"] = {"Jaluu, o Generoso <Zelador>", "Vale das Flores Eternas"}
        s["quest;reward=30451"] = {"Baralho da Serpente de Negraluna", "Floresta de Elwynn"}
        s["npc;drop=60143"] = {"Gara'jal, o Atador de Almas", "Galerias Mogu'shan"}
        s["quest;reward=30449"] = {"Baralho do Grou de Negraluna", "Floresta de Elwynn"}
        s["npc;drop=60051"] = {"[Cobalt Guardian]", "Galerias Mogu'shan"}
        s["quest;reward=30450"] = {"Baralho do Boi de Negraluna", "Floresta de Elwynn"}
        s["npc;drop=59080"] = {"Umbromestre Gandling", "Scolomântia"}
        s["npc;drop=64340"] = {"[Instructor Maltik] <[Keeper of Unseen Strike]>", "Coração do Medo"}
        s["npc;sold=69060"] = {"[Tuskripper Grukna] <[Dominance Offensive Quartermaster]>", "Selva de Krasarang"}
    end

    function SpecBisTooltip:TranslationruRU()
        s["npc;drop=55265"] = {"Морхок", "Душа Дракона"}
        s["npc;drop=56427"] = {"Воевода Черный Рог", "Душа Дракона"}
        s["npc;sold=44245"] = {"Фалдрен Тиллсдейл <Награды за очки доблести>", "Штормград"}
        s["npc;drop=52571"] = {"Мажордом Фэндрал Олений Шлем <Верховный друид пламени>", "Огненные Просторы"}
        s["npc;drop=53879"] = {"Смертокрыл <Разрушитель>", "Душа Дракона"}
        s["npc;drop=55294"] = {"Ультраксион", "Душа Дракона"}
        s["npc;sold=64606"] = {"Командир Бычье Сердце <Награды за очки доблести>", "Танлунские степи"}
        s["npc;drop=60583"] = {"Защитник Каолань", "Терраса Вечной Весны"}
        s["npc;drop=62543"] = {"Повелитель клинков Та'як", "Сердце Страха"}
        s["npc;drop=62980"] = {"Императорский визирь Зор'лок <Голос императрицы>", "Сердце Страха"}
        s["npc;drop=62837"] = {"Великая императрица Шек'зир", "Сердце Страха"}
        s["npc;drop=62442"] = {"Цулон", "Терраса Вечной Весны"}
        s["npc;drop=62983"] = {"Лэй Ши", "Терраса Вечной Весны"}
        s["npc;drop=60400"] = {"Цзань-си <Открытая ладонь императора>", "Подземелья Могу'шан"}
        s["npc;drop=60999"] = {"Ша Страха", "Терраса Вечной Весны"}
        s["npc;drop=62511"] = {"Ваятель янтаря Ун'сок", "Сердце Страха"}
        s["npc;drop=62397"] = {"Повелитель ветров Мел'джарак", "Сердце Страха"}
        s["npc;drop=60701"] = {"Цзыань Беспросветная Тьма <Король чародеев>", "Подземелья Могу'шан"}
        s["npc;drop=60410"] = {"Элегон", "Подземелья Могу'шан"}
        s["quest;reward=30452"] = {"Колода карт Новолуния: Тигр", "Элвиннский лес"}
        s["npc;drop=63191"] = {"Гаралон", "Сердце Страха"}
        s["npc;drop=60399"] = {"Цинь-си <Сжатый кулак императора>", "Подземелья Могу'шан"}
        s["npc;drop=60009"] = {"Фэн Проклятый <Хранитель древних духов>", "Подземелья Могу'шан"}
        s["npc;drop=60043"] = {"Нефритовый страж", "Подземелья Могу'шан"}
        s["quest;reward=31612"] = {"Тень империи", "Жуткие пустоши"}
        s["npc;sold=59908"] = {"Джалуу Щедрый <Интендант Золотого Лотоса>", "Вечноцветущий дол"}
        s["quest;reward=30451"] = {"Колода карт Новолуния: Змея", "Элвиннский лес"}
        s["npc;drop=60143"] = {"Душелов Гара'джал", "Подземелья Могу'шан"}
        s["quest;reward=30449"] = {"Колода карт Новолуния: Журавль", "Элвиннский лес"}
        s["npc;drop=60051"] = {"Кобальтовый страж", "Подземелья Могу'шан"}
        s["quest;reward=30450"] = {"Колода карт Новолуния: Бык", "Элвиннский лес"}
        s["npc;drop=59080"] = {"Темный магистр Гандлинг", "Некроситет"}
        s["npc;drop=64340"] = {"Инструктор Малтик <Мастер незримого удара>", "Сердце Страха"}
        s["npc;sold=69060"] = {"Клыкодер Грукна <Интендант Армии Покорителей>", "Красарангские джунгли"}
    end

    function SpecBisTooltip:TranslationzhCN()
        s["npc;drop=55265"] = {"[Morchok]", "巨龙之魂"}
        s["npc;drop=56427"] = {"[Warmaster Blackhorn]", "巨龙之魂"}
        s["npc;sold=44245"] = {"[Faldren Tillsdale] <[Valor Quartermaster]>", "暴风城"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "火焰之地"}
        s["npc;drop=53879"] = {"[Deathwing] <[The Destroyer]>", "巨龙之魂"}
        s["npc;drop=55294"] = {"[Ultraxion]", "巨龙之魂"}
        s["npc;sold=64606"] = {"[Commander Oxheart] <[Valor Quartermaster]>", "螳螂高原"}
        s["npc;drop=60583"] = {"守护者考兰", "永春台"}
        s["npc;drop=62543"] = {"[Blade Lord Ta'yak]", "恐惧之心"}
        s["npc;drop=62980"] = {"皇家宰相佐尔洛克 <女王喉舌>", "恐惧之心"}
        s["npc;drop=62837"] = {"大女皇夏柯希尔", "恐惧之心"}
        s["npc;drop=62442"] = {"[Tsulong]", "永春台"}
        s["npc;drop=62983"] = {"雷施", "永春台"}
        s["npc;drop=60400"] = {"[Jan-xi] <[Emperor's Open Hand]>", "魔古山宝库"}
        s["npc;drop=60999"] = {"惧之煞", "永春台"}
        s["npc;drop=62511"] = {"琥珀塑形者昂舒克", "恐惧之心"}
        s["npc;drop=62397"] = {"风领主梅尔加拉克", "恐惧之心"}
        s["npc;drop=60701"] = {"永影之提安 <巫王>", "魔古山宝库"}
        s["npc;drop=60410"] = {"伊拉贡", "魔古山宝库"}
        s["quest;reward=30452"] = {"[Darkmoon Tiger Deck]", "艾尔文森林"}
        s["npc;drop=63191"] = {"[Garalon]", "恐惧之心"}
        s["npc;drop=60399"] = {"秦希 <皇帝的蓄势之拳>", "魔古山宝库"}
        s["npc;drop=60009"] = {"受诅者魔封 <勇士之魂守护者>", "魔古山宝库"}
        s["npc;drop=60043"] = {"青玉守护者", "魔古山宝库"}
        s["quest;reward=31612"] = {"[Shadow of the Empire]", "恐惧废土"}
        s["npc;sold=59908"] = {"[Jaluu the Generous] <[The Golden Lotus Quartermaster]>", "锦绣谷"}
        s["quest;reward=30451"] = {"[Darkmoon Serpent Deck]", "艾尔文森林"}
        s["npc;drop=60143"] = {"缚灵者戈拉亚", "魔古山宝库"}
        s["quest;reward=30449"] = {"[Darkmoon Crane Deck]", "艾尔文森林"}
        s["npc;drop=60051"] = {"[Cobalt Guardian]", "魔古山宝库"}
        s["quest;reward=30450"] = {"[Darkmoon Ox Deck]", "艾尔文森林"}
        s["npc;drop=59080"] = {"[Darkmaster Gandling]", "通灵学院"}
        s["npc;drop=64340"] = {"[Instructor Maltik] <[Keeper of Unseen Strike]>", "恐惧之心"}
        s["npc;sold=69060"] = {"[Tuskripper Grukna] <[Dominance Offensive Quartermaster]>", "卡桑琅丛林"}
    end

    function SpecBisTooltip:TranslationzhTW()
        s["npc;drop=55265"] = {"[Morchok]", "巨龙之魂"}
        s["npc;drop=56427"] = {"[Warmaster Blackhorn]", "巨龙之魂"}
        s["npc;sold=44245"] = {"[Faldren Tillsdale] <[Valor Quartermaster]>", "暴风城"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "火焰之地"}
        s["npc;drop=53879"] = {"[Deathwing] <[The Destroyer]>", "巨龙之魂"}
        s["npc;drop=55294"] = {"[Ultraxion]", "巨龙之魂"}
        s["npc;sold=64606"] = {"[Commander Oxheart] <[Valor Quartermaster]>", "螳螂高原"}
        s["npc;drop=60583"] = {"守护者考兰", "永春台"}
        s["npc;drop=62543"] = {"[Blade Lord Ta'yak]", "恐惧之心"}
        s["npc;drop=62980"] = {"皇家宰相佐尔洛克 <女王喉舌>", "恐惧之心"}
        s["npc;drop=62837"] = {"大女皇夏柯希尔", "恐惧之心"}
        s["npc;drop=62442"] = {"[Tsulong]", "永春台"}
        s["npc;drop=62983"] = {"雷施", "永春台"}
        s["npc;drop=60400"] = {"[Jan-xi] <[Emperor's Open Hand]>", "魔古山宝库"}
        s["npc;drop=60999"] = {"惧之煞", "永春台"}
        s["npc;drop=62511"] = {"琥珀塑形者昂舒克", "恐惧之心"}
        s["npc;drop=62397"] = {"风领主梅尔加拉克", "恐惧之心"}
        s["npc;drop=60701"] = {"永影之提安 <巫王>", "魔古山宝库"}
        s["npc;drop=60410"] = {"伊拉贡", "魔古山宝库"}
        s["quest;reward=30452"] = {"[Darkmoon Tiger Deck]", "艾尔文森林"}
        s["npc;drop=63191"] = {"[Garalon]", "恐惧之心"}
        s["npc;drop=60399"] = {"秦希 <皇帝的蓄势之拳>", "魔古山宝库"}
        s["npc;drop=60009"] = {"受诅者魔封 <勇士之魂守护者>", "魔古山宝库"}
        s["npc;drop=60043"] = {"青玉守护者", "魔古山宝库"}
        s["quest;reward=31612"] = {"[Shadow of the Empire]", "恐惧废土"}
        s["npc;sold=59908"] = {"[Jaluu the Generous] <[The Golden Lotus Quartermaster]>", "锦绣谷"}
        s["quest;reward=30451"] = {"[Darkmoon Serpent Deck]", "艾尔文森林"}
        s["npc;drop=60143"] = {"缚灵者戈拉亚", "魔古山宝库"}
        s["quest;reward=30449"] = {"[Darkmoon Crane Deck]", "艾尔文森林"}
        s["npc;drop=60051"] = {"[Cobalt Guardian]", "魔古山宝库"}
        s["quest;reward=30450"] = {"[Darkmoon Ox Deck]", "艾尔文森林"}
        s["npc;drop=59080"] = {"[Darkmaster Gandling]", "通灵学院"}
        s["npc;drop=64340"] = {"[Instructor Maltik] <[Keeper of Unseen Strike]>", "恐惧之心"}
        s["npc;sold=69060"] = {"[Tuskripper Grukna] <[Dominance Offensive Quartermaster]>", "卡桑琅丛林"}
    end
end
