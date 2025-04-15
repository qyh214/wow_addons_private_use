---@class Private
local Private = select(2, ...)

local L = Private.L

L["Difficulty-1"] = "L"
L["Difficulty-3"] = "N"
L["Difficulty-4"] = "H"
L["Difficulty-5"] = "M"
L["AllStars"] = "All Stars"
L["Rank"] = "Rank"
L["Kills"] = "Kills"
L["Unknown"] = [[Unknown]]
L["UnknownRealm"] = [[[%s] Realm '%s' (id %d) not in database. Please report to the Warcraft Logs team.]]
L["CopyProfileURL"] = [[Copy WCL URL]]
L["Subscriber"] = [[Subscriber]]
L["ShiftToExpand"] = [[<Shift> to Expand]]
L["SubAddonMissing"] = [[[%s] Database for '%s' (%s) is missing. Please install the addon.]]
L["DBLoadError"] = [[[%s] Could not load database for '%s'. Reason: %s]]
L["Main"] = [[Main]]

if Private.IsRetail then
    L["addon.parse-gate-description"] = "Parses shown after 20H or 5M kills"
    L["Encounter-3009"] = [[Vexie and the Geargrinders]]
    L["Encounter-3010"] = [[Cauldron of Carnage]]
    L["Encounter-3011"] = [[Rik Reverb]]
    L["Encounter-3012"] = [[Stix Bunkjunker]]
    L["Encounter-3013"] = [[Sprocketmonger Lockenstock]]
    L["Encounter-3014"] = [[One-Armed Bandit]]
    L["Encounter-3015"] = [[Mug'Zee, Heads of Security]]
    L["Encounter-3016"] = [[Chrome King Gallywix]]
elseif Private.IsCata then
    L["addon.parse-gate-description"] = "Parses shown after 20H kills"
    L["Encounter-1292"] = [[Morchok]]
    L["Encounter-1294"] = [[Warlord Zon'ozz]]
    L["Encounter-1295"] = [[Yor'sahj the Unsleeping]]
    L["Encounter-1296"] = [[Hagara the Stormbinder]]
    L["Encounter-1297"] = [[Ultraxion]]
    L["Encounter-1298"] = [[Warmaster Blackhorn]]
    L["Encounter-1291"] = [[Spine of Deathwing]]
    L["Encounter-1299"] = [[Madness of Deathwing]]
elseif Private.IsWrath then
    L["addon.parse-gate-description"] = "Parses shown after 8H kills"
    L["Encounter-50629"] = [[Northrend Beasts]]
    L["Encounter-50633"] = [[Lord Jaraxxus]]
    L["Encounter-50637"] = [[Faction Champions]]
    L["Encounter-50641"] = [[Val'kyr Twins]]
    L["Encounter-50645"] = [[Anub'arak]]
elseif Private.IsClassicEra then
    L["addon.parse-gate-description"] = ""
    L["Encounter-201118"] = [[Patchwerk]]
    L["Encounter-201111"] = [[Grobbulus]]
    L["Encounter-201108"] = [[Gluth]]
    L["Encounter-201120"] = [[Thaddius]]
    L["Encounter-201117"] = [[Noth the Plaguebringer]]
    L["Encounter-201112"] = [[Heigan the Unclean]]
    L["Encounter-201115"] = [[Loatheb]]
    L["Encounter-201107"] = [[Anub'Rekhan]]
    L["Encounter-201110"] = [[Grand Widow Faerlina]]
    L["Encounter-201116"] = [[Maexxna]]
    L["Encounter-201113"] = [[Instructor Razuvious]]
    L["Encounter-201109"] = [[Gothik the Harvester]]
    L["Encounter-201121"] = [[The Four Horsemen]]
    L["Encounter-201119"] = [[Sapphiron]]
    L["Encounter-201114"] = [[Kel'Thuzad]]
end

local locale = GAME_LOCALE or GetLocale()

if locale == "deDE" then
    L["Difficulty-1"] = "L"
    L["Difficulty-3"] = "N"
    L["Difficulty-4"] = "H"
    L["Difficulty-5"] = "M"
    L["AllStars"] = "Bestplatzierte"
    L["Rank"] = "Rang"
    L["Kills"] = "Kills"
    L["Unknown"] = [[Unbekannt]]
    L["UnknownRealm"] = [[[%s] Realm '%s' (id %d) not in database. Please report to the Warcraft Logs team.]]
    L["CopyProfileURL"] = [[Copy WCL URL]]
    L["Subscriber"] = [[Abonnent]]
    L["ShiftToExpand"] = [[<Shift> to Expand]]
    L["SubAddonMissing"] = [[[%s] Database for '%s' (%s) is missing. Please install the addon.]]
    L["DBLoadError"] = [[[%s] Could not load database for '%s'. Reason: %s]]
    L["Main"] = [[Main]]

    if Private.IsRetail then
        L["addon.parse-gate-description"] = "Parses shown after 20H or 5M kills"
        L["Encounter-3009"] = [[Strolch und die Gangzwinger]]
        L["Encounter-3010"] = [[Kessel des Gemetzels]]
        L["Encounter-3011"] = [[Rik Resonanz]]
        L["Encounter-3012"] = [[Stix Kojenschrotter]]
        L["Encounter-3013"] = [[Ritzelkrämer Lockenstock]]
        L["Encounter-3014"] = [[Einarmiger Bandit]]
        L["Encounter-3015"] = [[Mug'Zee, Wachleitung]]
        L["Encounter-3016"] = [[Chromkönig Gallywix]]
    elseif Private.IsCata then
        L["addon.parse-gate-description"] = "Parses shown after 20H kills"
        L["Encounter-1292"] = [[Morchok]]
        L["Encounter-1294"] = [[Kriegsherr Zon'ozz]]
        L["Encounter-1295"] = [[Yor'sahj der Unermüdliche]]
        L["Encounter-1296"] = [[Hagara die Sturmbinderin]]
        L["Encounter-1297"] = [[Ultraxion]]
        L["Encounter-1298"] = [[Kriegsmeister Schwarzhorn]]
        L["Encounter-1291"] = [[Todesschwinges Rückgrat]]
        L["Encounter-1299"] = [[Todesschwinges Wahnsinn]]
    elseif Private.IsWrath then
        L["addon.parse-gate-description"] = "Parses shown after 8H kills"
        L["Encounter-50629"] = [[Bestien von Nordend]]
        L["Encounter-50633"] = [[Lord Jaraxxus]]
        L["Encounter-50637"] = [[Fraktionschampions]]
        L["Encounter-50641"] = [[Zwillingsval'kyr]]
        L["Encounter-50645"] = [[Anub'arak]]
    elseif Private.IsClassicEra then
        L["addon.parse-gate-description"] = ""
        L["Encounter-201118"] = [[Flickwerk]]
        L["Encounter-201111"] = [[Grobbulus]]
        L["Encounter-201108"] = [[Gluth]]
        L["Encounter-201120"] = [[Thaddius]]
        L["Encounter-201117"] = [[Noth der Seuchenfürst]]
        L["Encounter-201112"] = [[Heigan der Unreine]]
        L["Encounter-201115"] = [[Loatheb]]
        L["Encounter-201107"] = [[Anub'Rekhan]]
        L["Encounter-201110"] = [[Großwitwe Faerlina]]
        L["Encounter-201116"] = [[Maexxna]]
        L["Encounter-201113"] = [[Instrukteur Razuvious]]
        L["Encounter-201109"] = [[Gothik der Ernter]]
        L["Encounter-201121"] = [[Die Vier Reiter]]
        L["Encounter-201119"] = [[Saphiron]]
        L["Encounter-201114"] = [[Kel'Thuzad]]
    end
elseif locale == "esES" or locale == "esMX" then
    L["Difficulty-1"] = "L"
    L["Difficulty-3"] = "N"
    L["Difficulty-4"] = "H"
    L["Difficulty-5"] = "M"
    L["AllStars"] = "Los Mejores"
    L["Rank"] = "Rango"
    L["Kills"] = "Kills"
    L["Unknown"] = [[Desconocido]]
    L["UnknownRealm"] = [[[%s] Realm '%s' (id %d) not in database. Please report to the Warcraft Logs team.]]
    L["CopyProfileURL"] = [[Copiar URL de WCL]]
    L["Subscriber"] = [[Subscriptor ]]
    L["ShiftToExpand"] = [[<Shift> para expandir]]
    L["SubAddonMissing"] = [[[%s] Falta la base de datos de %s (%s). Por favor, instale el addon.]]
    L["DBLoadError"] = [[[%s] No se ha podido cargar la base de datos de '%s'. Motivo: %s ]]
    L["Main"] = [[Principal]]

    if Private.IsRetail then
        L["addon.parse-gate-description"] = "Parses shown after 20H or 5M kills"
        L["Encounter-3009"] = [[Vexie y los Cadenas]]
        L["Encounter-3010"] = [[Caldera de la Carnicería]]
        L["Encounter-3011"] = [[Rik Reverberación]]
        L["Encounter-3012"] = [[Stix Chatarracatre]]
        L["Encounter-3013"] = [[Piñonero Todolisto]]
        L["Encounter-3014"] = [[Bandido manco]]
        L["Encounter-3015"] = [[Mug'Zee, responsable de seguridad]]
        L["Encounter-3016"] = [[Rey Cromado Gallywix]]
    elseif Private.IsCata then
        L["addon.parse-gate-description"] = "Parses shown after 20H kills"
        L["Encounter-1292"] = [[Morchok]]
        L["Encounter-1294"] = [[Señor de la guerra Zon'ozz]]
        L["Encounter-1295"] = [[Yor'sahj el Velador]]
        L["Encounter-1296"] = [[Hagara la Vinculatormentas]]
        L["Encounter-1297"] = [[Ultraxion]]
        L["Encounter-1298"] = [[Maestro de guerra Cuerno Negro]]
        L["Encounter-1291"] = [[Espinazo de Alamuerte]]
        L["Encounter-1299"] = [[Locura de Alamuerte]]
    elseif Private.IsWrath then
        L["addon.parse-gate-description"] = "Parses shown after 8H kills"
        L["Encounter-50629"] = [[Bestias de Rasganorte]]
        L["Encounter-50633"] = [[Lord Jaraxxus]]
        L["Encounter-50637"] = [[Campeones de la facción]]
        L["Encounter-50641"] = [[Gemelas Val'kyr]]
        L["Encounter-50645"] = [[Anub'arak]]
    elseif Private.IsClassicEra then
        L["addon.parse-gate-description"] = ""
        L["Encounter-201118"] = [[Remendejo]]
        L["Encounter-201111"] = [[Grobbulus]]
        L["Encounter-201108"] = [[Gluth]]
        L["Encounter-201120"] = [[Thaddius]]
        L["Encounter-201117"] = [[Noth el Pesteador]]
        L["Encounter-201112"] = [[Heigan el Impuro]]
        L["Encounter-201115"] = [[Loatheb]]
        L["Encounter-201107"] = [[Anub'Rekhan]]
        L["Encounter-201110"] = [[Gran Viuda Faerlina]]
        L["Encounter-201116"] = [[Maexxna]]
        L["Encounter-201113"] = [[Instructor Razuvious]]
        L["Encounter-201109"] = [[Gothik el Cosechador]]
        L["Encounter-201121"] = [[Los Cuatro Jinetes]]
        L["Encounter-201119"] = [[Sapphiron]]
        L["Encounter-201114"] = [[Kel'Thuzad]]
    end
elseif locale == "frFR" then
    L["Difficulty-1"] = "L"
    L["Difficulty-3"] = "N"
    L["Difficulty-4"] = "H"
    L["Difficulty-5"] = "M"
    L["AllStars"] = "All Stars"
    L["Rank"] = "Rang"
    L["Kills"] = "Kills"
    L["Unknown"] = [[Inconnu]]
    L["UnknownRealm"] = [[[%s] Le royaume '%s' (identifiant %d) n'est pas dans la base de données. Merci de contacter l'équipe de Warcraft Logs.]]
    L["CopyProfileURL"] = [[Copier l'URL WarcraftLogs]]
    L["Subscriber"] = [[Abonné]]
    L["ShiftToExpand"] = [[<Maj> pour déplier]]
    L["SubAddonMissing"] = [[[%s] Database for '%s' (%s) is missing. Please install the addon.]]
    L["DBLoadError"] = [[[%s] Impossible de charger la base de données de '%s'. Raison : %s]]
    L["Main"] = [[Main]]

    if Private.IsRetail then
        L["addon.parse-gate-description"] = "Parses shown after 20H or 5M kills"
        L["Encounter-3009"] = [[Vexie et les Écrouabouilles]]
        L["Encounter-3010"] = [[Chaudron du carnage]]
        L["Encounter-3011"] = [[Rik Rebond]]
        L["Encounter-3012"] = [[Stix Jettetout]]
        L["Encounter-3013"] = [[Pignonneur Crosseplatine]]
        L["Encounter-3014"] = [[Bandit manchot]]
        L["Encounter-3015"] = [[Verr’Minh, chefs de la sécurité]]
        L["Encounter-3016"] = [[Roi du chrome Gallywix]]
    elseif Private.IsCata then
        L["addon.parse-gate-description"] = "Parses shown after 20H kills"
        L["Encounter-1292"] = [[Morchok]]
        L["Encounter-1294"] = [[Seigneur de guerre Zon’ozz]]
        L["Encounter-1295"] = [[Yor'sahj l’Insomniaque]]
        L["Encounter-1296"] = [[Hagara la Lieuse des tempêtes]]
        L["Encounter-1297"] = [[Ultraxion]]
        L["Encounter-1298"] = [[Maître de guerre Corne-Noire]]
        L["Encounter-1291"] = [[Échine d’Aile de mort]]
        L["Encounter-1299"] = [[Folie d’Aile de mort]]
    elseif Private.IsWrath then
        L["addon.parse-gate-description"] = "Parses shown after 8H kills"
        L["Encounter-50629"] = [[Bêtes du Norfendre]]
        L["Encounter-50633"] = [[Seigneur Jaraxxus]]
        L["Encounter-50637"] = [[Champions de faction]]
        L["Encounter-50641"] = [[Jumelles val’kyrs]]
        L["Encounter-50645"] = [[Anub’arak]]
    elseif Private.IsClassicEra then
        L["addon.parse-gate-description"] = ""
        L["Encounter-201118"] = [[Le Recousu]]
        L["Encounter-201111"] = [[Grobbulus]]
        L["Encounter-201108"] = [[Gluth]]
        L["Encounter-201120"] = [[Thaddius]]
        L["Encounter-201117"] = [[Noth le Porte-Peste]]
        L["Encounter-201112"] = [[Heigan l'Impur]]
        L["Encounter-201115"] = [[Horreb]]
        L["Encounter-201107"] = [[Anub'Rekhan]]
        L["Encounter-201110"] = [[Grande veuve Faerlina]]
        L["Encounter-201116"] = [[Maexxna]]
        L["Encounter-201113"] = [[Instructeur Razuvious]]
        L["Encounter-201109"] = [[Gothik le Moissonneur]]
        L["Encounter-201121"] = [[Les quatre cavaliers]]
        L["Encounter-201119"] = [[Saphiron]]
        L["Encounter-201114"] = [[Kel'Thuzad]]
    end
elseif locale == "itIT" then
    L["Difficulty-1"] = "L"
    L["Difficulty-3"] = "N"
    L["Difficulty-4"] = "H"
    L["Difficulty-5"] = "M"
    L["AllStars"] = "Classificazione All-Stars"
    L["Rank"] = "Rango"
    L["Kills"] = "Kills"
    L["Unknown"] = [[Unknown]]
    L["UnknownRealm"] = [[[%s] Realm '%s' (id %d) not in database. Please report to the Warcraft Logs team.]]
    L["CopyProfileURL"] = [[Copy WCL URL]]
    L["Subscriber"] = [[Subscriber]]
    L["ShiftToExpand"] = [[<Shift> to Expand]]
    L["SubAddonMissing"] = [[[%s] Database for '%s' (%s) is missing. Please install the addon.]]
    L["DBLoadError"] = [[[%s] Could not load database for '%s'. Reason: %s]]
    L["Main"] = [[Main]]

    if Private.IsRetail then
        L["addon.parse-gate-description"] = "Parses shown after 20H or 5M kills"
        L["Encounter-3009"] = [[Vexie e i Pestaruote]]
        L["Encounter-3010"] = [[Calderone del Massacro]]
        L["Encounter-3011"] = [[Rik Riverbero]]
        L["Encounter-3012"] = [[Stix Tritabrande]]
        L["Encounter-3013"] = [[Ingraniere Lockenstock]]
        L["Encounter-3014"] = [[Bandito con un Braccio Solo]]
        L["Encounter-3015"] = [[Mug'zee, Capi della Sicurezza]]
        L["Encounter-3016"] = [[Re Cromato Gallywix]]
    elseif Private.IsCata then
        L["addon.parse-gate-description"] = "Parses shown after 20H kills"
        L["Encounter-1292"] = [[Morchok]]
        L["Encounter-1294"] = [[Zon'ozz il Signore della Guerra]]
        L["Encounter-1295"] = [[Yor'sahj il Senza Sonno]]
        L["Encounter-1296"] = [[Hagara la Tempestosa]]
        L["Encounter-1297"] = [[Ultraxion]]
        L["Encounter-1298"] = [[Maestro di Guerra Corno Nero]]
        L["Encounter-1291"] = [[Spina Dorsale di Alamorte]]
        L["Encounter-1299"] = [[Follia di Alamorte]]
    elseif Private.IsWrath then
        L["addon.parse-gate-description"] = "Parses shown after 8H kills"
        L["Encounter-50629"] = [[Northrend Beasts]]
        L["Encounter-50633"] = [[Lord Jaraxxus]]
        L["Encounter-50637"] = [[Faction Champions]]
        L["Encounter-50641"] = [[Val'kyr Twins]]
        L["Encounter-50645"] = [[Anub'arak]]
    elseif Private.IsClassicEra then
        L["addon.parse-gate-description"] = ""
        L["Encounter-201118"] = [[Pezzacarne]]
        L["Encounter-201111"] = [[Grobbulus]]
        L["Encounter-201108"] = [[Gluth]]
        L["Encounter-201120"] = [[Thaddius]]
        L["Encounter-201117"] = [[Noth l'Araldo della Piaga]]
        L["Encounter-201112"] = [[Heigan l'Impuro]]
        L["Encounter-201115"] = [[Loatheb]]
        L["Encounter-201107"] = [[Anub'rekhan]]
        L["Encounter-201110"] = [[Faerlina la Vedova Nera]]
        L["Encounter-201116"] = [[Maexxna]]
        L["Encounter-201113"] = [[Istruttore Razuvious]]
        L["Encounter-201109"] = [[Gothik il Falciatore]]
        L["Encounter-201121"] = [[Cavalieri dell'Apocalisse]]
        L["Encounter-201119"] = [[Zaffirion]]
        L["Encounter-201114"] = [[Kel'Thuzad]]
    end
elseif locale == "koKO" then
    L["Difficulty-1"] = "L"
    L["Difficulty-3"] = "일반"
    L["Difficulty-4"] = "영웅"
    L["Difficulty-5"] = "신화"
    L["AllStars"] = "올스타"
    L["Rank"] = "등급"
    L["Kills"] = "Kills"
    L["Unknown"] = [[Unknown]]
    L["UnknownRealm"] = [[[%s] Realm '%s' (id %d) not in database. Please report to the Warcraft Logs team.]]
    L["CopyProfileURL"] = [[Copy WCL URL]]
    L["Subscriber"] = [[Subscriber]]
    L["ShiftToExpand"] = [[<Shift> to Expand]]
    L["SubAddonMissing"] = [[[%s] Database for '%s' (%s) is missing. Please install the addon.]]
    L["DBLoadError"] = [[[%s] Could not load database for '%s'. Reason: %s]]
    L["Main"] = [[Main]]

    if Private.IsRetail then
        L["addon.parse-gate-description"] = "Parses shown after 20H or 5M kills"
        L["Encounter-3009"] = [[벡시와 연마공]]
        L["Encounter-3010"] = [[살육의 도가니]]
        L["Encounter-3011"] = [[리크 리버브]]
        L["Encounter-3012"] = [[스틱스 벙크정커]]
        L["Encounter-3013"] = [[스프로켓몽거 로켄스톡]]
        L["Encounter-3014"] = [[외팔이 좀도둑]]
        L["Encounter-3015"] = [[보안 책임자 머그지]]
        L["Encounter-3016"] = [[크롬왕 갤리윅스]]
    elseif Private.IsCata then
        L["addon.parse-gate-description"] = "Parses shown after 20H kills"
        L["Encounter-1292"] = [[모르초크]]
        L["Encounter-1294"] = [[장군 존오즈]]
        L["Encounter-1295"] = [[잠들지 않는 요르사지]]
        L["Encounter-1296"] = [[하가라]]
        L["Encounter-1297"] = [[울트락시온]]
        L["Encounter-1298"] = [[전투대장 블랙혼]]
        L["Encounter-1291"] = [[데스윙의 등]]
        L["Encounter-1299"] = [[데스윙의 광기]]
    elseif Private.IsWrath then
        L["addon.parse-gate-description"] = "Parses shown after 8H kills"
        L["Encounter-50629"] = [[노스렌드 야수]]
        L["Encounter-50633"] = [[군주 자락서스]]
        L["Encounter-50637"] = [[진영 대표 용사]]
        L["Encounter-50641"] = [[발키르 쌍둥이]]
        L["Encounter-50645"] = [[아눕아락]]
    elseif Private.IsClassicEra then
        L["addon.parse-gate-description"] = ""
        L["Encounter-201118"] = [[패치워크]]
        L["Encounter-201111"] = [[그라불루스]]
        L["Encounter-201108"] = [[글루스]]
        L["Encounter-201120"] = [[타디우스]]
        L["Encounter-201117"] = [[역병술사 노스]]
        L["Encounter-201112"] = [[부정의 헤이건]]
        L["Encounter-201115"] = [[로데브]]
        L["Encounter-201107"] = [[아눕레칸]]
        L["Encounter-201110"] = [[귀부인 팰리나]]
        L["Encounter-201116"] = [[맥스나]]
        L["Encounter-201113"] = [[훈련교관 라주비어스]]
        L["Encounter-201109"] = [[영혼 착취자 고딕]]
        L["Encounter-201121"] = [[4인 기사단]]
        L["Encounter-201119"] = [[사피론]]
        L["Encounter-201114"] = [[켈투자드]]
    end
elseif locale == "ptBR" then
    L["Difficulty-1"] = "L"
    L["Difficulty-3"] = "N"
    L["Difficulty-4"] = "D"
    L["Difficulty-5"] = "M"
    L["AllStars"] = "Maiores Estrelas"
    L["Rank"] = "Ranque"
    L["Kills"] = "Abates"
    L["Unknown"] = [[Desconhecido]]
    L["UnknownRealm"] = [[[%s] Domínio '%s' (id %d) não está no banco de dados. Por favor, reporte-se à equipe do Warcraft Logs.]]
    L["CopyProfileURL"] = [[Copiar URL do WCL]]
    L["Subscriber"] = [[Assinante]]
    L["ShiftToExpand"] = [[<Shift> para expandir]]
    L["SubAddonMissing"] = [[[%s] Base de dados para '%s' (%s) inexistente. Por favor, instale o addon.]]
    L["DBLoadError"] = [[[%s] Não foi possível carregar a base de dados '%s'. Motivo: %s]]
    L["Main"] = [[Principal]]

    if Private.IsRetail then
        L["addon.parse-gate-description"] = "Análises apresentadas após 20H ou 5M mortes"
        L["Encounter-3009"] = [[Vexie e os Trincatracas]]
        L["Encounter-3010"] = [[Caldeirão da Carnificina]]
        L["Encounter-3011"] = [[Rik Reverb]]
        L["Encounter-3012"] = [[Stix Sucateiro]]
        L["Encounter-3013"] = [[Rebimbocador Travaguarda]]
        L["Encounter-3014"] = [[Bandido de Um Braço]]
        L["Encounter-3015"] = [[Mag'Guila, Chefes de Segurança]]
        L["Encounter-3016"] = [[Rei do Cromo Gallywix]]
    elseif Private.IsCata then
        L["addon.parse-gate-description"] = "Análises apresentadas após 20H mortes"
        L["Encounter-1292"] = [[Morchok]]
        L["Encounter-1294"] = [[Senhor da Guerra Zon'ozz]]
        L["Encounter-1295"] = [[Yor'sahj, o Vígil]]
        L["Encounter-1296"] = [[Hagara, a Tempestigadora]]
        L["Encounter-1297"] = [[Ultraxion]]
        L["Encounter-1298"] = [[Mestre Guerreiro Chifre Negro]]
        L["Encounter-1291"] = [[Espinhaço do Asa da Morte]]
        L["Encounter-1299"] = [[Loucura do Asa da Morte]]
    elseif Private.IsWrath then
        L["addon.parse-gate-description"] = "Análises apresentadas após 8H mortes"
        L["Encounter-50629"] = [[Feras de Nortúndria]]
        L["Encounter-50633"] = [[Lorde Jaraxxus]]
        L["Encounter-50637"] = [[Campeões das Facções]]
        L["Encounter-50641"] = [[Gêmeas Val'kyr]]
        L["Encounter-50645"] = [[Anub'arak]]
    elseif Private.IsClassicEra then
        L["addon.parse-gate-description"] = ""
        L["Encounter-201118"] = [[Retalhoso]]
        L["Encounter-201111"] = [[Grobbulus]]
        L["Encounter-201108"] = [[Gluth]]
        L["Encounter-201120"] = [[Thaddius]]
        L["Encounter-201117"] = [[Noth, o Pestífero]]
        L["Encounter-201112"] = [[Heigan, o Sujo]]
        L["Encounter-201115"] = [[Repugnaz]]
        L["Encounter-201107"] = [[Anub'Rekhan]]
        L["Encounter-201110"] = [[Grã-viúva Faerlina]]
        L["Encounter-201116"] = [[Maexxna]]
        L["Encounter-201113"] = [[Instrutor Razúvio]]
        L["Encounter-201109"] = [[Gothik, o Ceifador]]
        L["Encounter-201121"] = [[Os Quatro Cavaleiros]]
        L["Encounter-201119"] = [[Sapphiron]]
        L["Encounter-201114"] = [[Kel'Thuzad]]
    end
elseif locale == "ruRU" then
    L["Difficulty-1"] = "ПР"
    L["Difficulty-3"] = "Н"
    L["Difficulty-4"] = "Г"
    L["Difficulty-5"] = "Э"
    L["AllStars"] = "Все звезды"
    L["Rank"] = "Ранг"
    L["Kills"] = "Убийств"
    L["Unknown"] = [[Неизвестно]]
    L["UnknownRealm"] = [[[%s] Реалм '%s' (id %d) отсутствует в базе данных. Пожалуйста, сообщите об этом команде Warcraft Logs.]]
    L["CopyProfileURL"] = [[Скопировать WCL URL]]
    L["Subscriber"] = [[Подписчик]]
    L["ShiftToExpand"] = [[<Shift> чтобы расширить]]
    L["SubAddonMissing"] = [[[%s] База данных для '%s' (%s) отсутствует. Пожалуйста, установите аддон.]]
    L["DBLoadError"] = [[[%s] Не удалось загрузить базу данных для '%s'. Причина: %s]]
    L["Main"] = [[Главная]]

    if Private.IsRetail then
        L["addon.parse-gate-description"] = "Парсы показываются после 20Г или 5M убийств"
        L["Encounter-3009"] = [[Векси и зуботочеры]]
        L["Encounter-3010"] = [[Котел смерти]]
        L["Encounter-3011"] = [[Рик Ревербер]]
        L["Encounter-3012"] = [[Стикс Бункохламзень]]
        L["Encounter-3013"] = [[Зубцеторг Всесхватс]]
        L["Encounter-3014"] = [[Однорукий бандит]]
        L["Encounter-3015"] = [[Граб'Зи, главы отдела охраны]]
        L["Encounter-3016"] = [[Хромовый король Галливикс]]
    elseif Private.IsCata then
        L["addon.parse-gate-description"] = "Парсы показываются после 20Г убийств"
        L["Encounter-1292"] = [[Морхок]]
        L["Encounter-1294"] = [[Полководец Зон'озз]]
        L["Encounter-1295"] = [[Йор'садж Неспящий]]
        L["Encounter-1296"] = [[Хагара Владычица Штормов]]
        L["Encounter-1297"] = [[Ультраксион]]
        L["Encounter-1298"] = [[Воевода Черный Рог]]
        L["Encounter-1291"] = [[Хребет Смертокрыла]]
        L["Encounter-1299"] = [[Безумие Смертокрыла]]
    elseif Private.IsWrath then
        L["addon.parse-gate-description"] = "Парсы показываются после 8Г убийств"
        L["Encounter-50629"] = [[Чудовища Нордскола]]
        L["Encounter-50633"] = [[Лорд Джараксус]]
        L["Encounter-50637"] = [[Чемпионы фракций]]
        L["Encounter-50641"] = [[Валь'киры-близнецы]]
        L["Encounter-50645"] = [[Ануб'арак]]
    elseif Private.IsClassicEra then
        L["addon.parse-gate-description"] = ""
        L["Encounter-201118"] = [[Лоскутик]]
        L["Encounter-201111"] = [[Гроббулус]]
        L["Encounter-201108"] = [[Глут]]
        L["Encounter-201120"] = [[Таддиус]]
        L["Encounter-201117"] = [[Нот Чумной]]
        L["Encounter-201112"] = [[Хейган Нечестивый]]
        L["Encounter-201115"] = [[Лотхиб]]
        L["Encounter-201107"] = [[Ануб'Рекан]]
        L["Encounter-201110"] = [[Великая вдова Фарлина]]
        L["Encounter-201116"] = [[Мексна]]
        L["Encounter-201113"] = [[Инструктор Разувий]]
        L["Encounter-201109"] = [[Готик Жнец]]
        L["Encounter-201121"] = [[Четыре всадника]]
        L["Encounter-201119"] = [[Сапфирон]]
        L["Encounter-201114"] = [[Кел'Тузад]]
    end
elseif locale == "zhCN" then
    L["Difficulty-1"] = "随机"
    L["Difficulty-3"] = "普通"
    L["Difficulty-4"] = "英雄"
    L["Difficulty-5"] = "史诗"
    L["AllStars"] = "全明星分"
    L["Rank"] = "排名"
    L["Kills"] = "击杀"
    L["Unknown"] = [[未知]]
    L["UnknownRealm"] = [[[%s] 服务器 '%s' (id %d) 不在数据库中。请报告给WCL团队。]]
    L["CopyProfileURL"] = [[复制 WCL 链接]]
    L["Subscriber"] = [[WCL会员]]
    L["ShiftToExpand"] = [[按住 <Shift> 展开]]
    L["SubAddonMissing"] = [[ '%s' (%s)的[%s]数据缺失. 请安装插件]]
    L["DBLoadError"] = [[[%s] 无法加载 '%s' 的数据库。原因：%s]]
    L["Main"] = [[大号]]

    if Private.IsRetail then
        L["addon.parse-gate-description"] = "分数在20次H或5次M击杀后显示"
        L["Encounter-3009"] = [[维克茜和磨轮]]
        L["Encounter-3010"] = [[血腥大熔炉]]
        L["Encounter-3011"] = [[里克·混响]]
        L["Encounter-3012"] = [[斯提克斯·堆渣]]
        L["Encounter-3013"] = [[链齿狂人洛肯斯多]]
        L["Encounter-3014"] = [[独臂盗匪]]
        L["Encounter-3015"] = [[穆格·兹伊，安保头子]]
        L["Encounter-3016"] = [[铬武大王加里维克斯]]
    elseif Private.IsCata then
        L["addon.parse-gate-description"] = "分数在20次H击杀后显示"
        L["Encounter-1292"] = [[莫卓克]]
        L["Encounter-1294"] = [[督军佐诺兹]]
        L["Encounter-1295"] = [[不眠的约萨希]]
        L["Encounter-1296"] = [[缚风者哈格拉]]
        L["Encounter-1297"] = [[奥卓克希昂]]
        L["Encounter-1298"] = [[战争大师黑角]]
        L["Encounter-1291"] = [[死亡之翼的背脊]]
        L["Encounter-1299"] = [[疯狂的死亡之翼]]
    elseif Private.IsWrath then
        L["addon.parse-gate-description"] = "分数在8次H击杀后显示"
        L["Encounter-50629"] = [[诺森德猛兽]]
        L["Encounter-50633"] = [[加拉克苏斯大王]]
        L["Encounter-50637"] = [[阵营冠军]]
        L["Encounter-50641"] = [[瓦格里双子]]
        L["Encounter-50645"] = [[阿努巴拉克]]
    elseif Private.IsClassicEra then
        L["addon.parse-gate-description"] = ""
        L["Encounter-201118"] = [[帕奇维克]]
        L["Encounter-201111"] = [[格罗布鲁斯]]
        L["Encounter-201108"] = [[格拉斯]]
        L["Encounter-201120"] = [[塔迪乌斯]]
        L["Encounter-201117"] = [[药剂师诺斯]]
        L["Encounter-201112"] = [[肮脏的希尔盖]]
        L["Encounter-201115"] = [[洛欧塞布]]
        L["Encounter-201107"] = [[阿努布雷坎]]
        L["Encounter-201110"] = [[黑女巫法琳娜]]
        L["Encounter-201116"] = [[迈克斯纳]]
        L["Encounter-201113"] = [[教官拉苏维奥斯]]
        L["Encounter-201109"] = [[收割者戈提克]]
        L["Encounter-201121"] = [[天启四骑士]]
        L["Encounter-201119"] = [[萨菲隆]]
        L["Encounter-201114"] = [[克尔苏加德]]
    end
elseif locale == "zhTW" then
    L["Difficulty-1"] = "隨團"
    L["Difficulty-3"] = "普通"
    L["Difficulty-4"] = "英雄"
    L["Difficulty-5"] = "傳奇"
    L["AllStars"] = "全明星"
    L["Rank"] = "階級"
    L["Kills"] = "Kills"
    L["Unknown"] = [[未知]]
    L["UnknownRealm"] = [[[%s] 伺服器『%s』(ID %d) 不存在於資料庫，請向戰鬥紀錄團隊回報]]
    L["CopyProfileURL"] = [[複製WCL網址]]
    L["Subscriber"] = [[訂閱者]]
    L["ShiftToExpand"] = [[按住 <Shift> 展開]]
    L["SubAddonMissing"] = [[[%s] Database for '%s' (%s) is missing. Please install the addon.]]
    L["DBLoadError"] = [[[%s] Could not load database for '%s'. Reason: %s]]
    L["Main"] = [[Main]]

    if Private.IsRetail then
        L["addon.parse-gate-description"] = "戰績解鎖條件：累積20小時或500萬擊殺"
        L["Encounter-3009"] = [[Vexie and the Geargrinders]]
        L["Encounter-3010"] = [[Cauldron of Carnage]]
        L["Encounter-3011"] = [[Rik Reverb]]
        L["Encounter-3012"] = [[Stix Bunkjunker]]
        L["Encounter-3013"] = [[Sprocketmonger Lockenstock]]
        L["Encounter-3014"] = [[One-Armed Bandit]]
        L["Encounter-3015"] = [[Mug'Zee, Heads of Security]]
        L["Encounter-3016"] = [[Chrome King Gallywix]]
    elseif Private.IsCata then
        L["addon.parse-gate-description"] = "戰績解鎖：累積20小時擊殺"
        L["Encounter-1292"] = [[Morchok]]
        L["Encounter-1294"] = [[Warlord Zon'ozz]]
        L["Encounter-1295"] = [[Yor'sahj the Unsleeping]]
        L["Encounter-1296"] = [[Hagara the Stormbinder]]
        L["Encounter-1297"] = [[Ultraxion]]
        L["Encounter-1298"] = [[Warmaster Blackhorn]]
        L["Encounter-1291"] = [[Spine of Deathwing]]
        L["Encounter-1299"] = [[Madness of Deathwing]]
    elseif Private.IsWrath then
        L["addon.parse-gate-description"] = "Parses shown after 8H kills"
        L["Encounter-50629"] = [[Northrend Beasts]]
        L["Encounter-50633"] = [[Lord Jaraxxus]]
        L["Encounter-50637"] = [[Faction Champions]]
        L["Encounter-50641"] = [[Val'kyr Twins]]
        L["Encounter-50645"] = [[Anub'arak]]
    elseif Private.IsClassicEra then
        L["addon.parse-gate-description"] = ""
        L["Encounter-201118"] = [[Patchwerk]]
        L["Encounter-201111"] = [[Grobbulus]]
        L["Encounter-201108"] = [[Gluth]]
        L["Encounter-201120"] = [[Thaddius]]
        L["Encounter-201117"] = [[Noth the Plaguebringer]]
        L["Encounter-201112"] = [[Heigan the Unclean]]
        L["Encounter-201115"] = [[Loatheb]]
        L["Encounter-201107"] = [[Anub'Rekhan]]
        L["Encounter-201110"] = [[Grand Widow Faerlina]]
        L["Encounter-201116"] = [[Maexxna]]
        L["Encounter-201113"] = [[Instructor Razuvious]]
        L["Encounter-201109"] = [[Gothik the Harvester]]
        L["Encounter-201121"] = [[The Four Horsemen]]
        L["Encounter-201119"] = [[Sapphiron]]
        L["Encounter-201114"] = [[Kel'Thuzad]]
    end
end
