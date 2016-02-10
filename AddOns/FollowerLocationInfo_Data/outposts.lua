
-- 946 Talador
-- 948 Spikes of Arak
-- 949 Gorgrond
-- 950 Nagrand

-- ["<zoneID>.<optionNum>"] = {"<optionName>",<coordX>,<coordY>}
FollowerLocationInfoData.Outpost = {};
local O = FollowerLocationInfoData.Outpost;
if FollowerLocationInfoData.faction==1 then
	-- alliance outposts
	O[946] = {{"Arcane Sanctum",70,20.3},          {"Wrynn Artillery Tower",70,20.3}};
	O[948] = {{"Smuggler's Den",39.63,61.20},      {"Hearthfire Tavern",39.63,61.20}};
	O[949] = {{"Lowlands Lumber Yard",53.01,59.57},{"Highpass Sparring Ring",53.01,59.57}};
	O[950] = {{"Rangari Corral",63.03,62.18},      {"Telaari Tankworks",63.03,62.18}};
else
	-- horde outposts
	O[946] = {{"Arcane Sanctum",70,95,30.37},      {"Vol'jin's Arsenal",70,95,30.37}};
	O[948] = {{"Smuggler's Den",40.05,43.06},      {"Stoktron Brewery",40.05,43.06}};
	O[949] = {{"Lowlands Lumber Yard",46.28,69.46},{"Highpass Sparring Ring",46.28,69.46}};
	O[950] = {{"Wor'var Corral",83.14,43.78},      {"Wor'var Tankworks",83.14,43.78}};
end

local L = FollowerLocationInfoData.Locale;
if LOCALE_deDE then
	L["Lowlands Lumber Yard"] = "Flachlandsägewerk";
	L["Highpass Sparring Ring"] = "Übungsring am Hochpass";
	L["Arcane Sanctum"] = "Arkanes Sanktum";
	L["Vol'jin's Arsenal"] = "Vol'jins Arsenal";
	L["Wrynn Artillery Tower"] = "Wrynns Artillerieturm";
	L["Smuggler's Den"] = "Schmugglerhöhle";
	L["Hearthfire Tavern"] = "Herdfeuertaverne";
	L["Stoktron Brewery"] = "Brauerei Stoktron";
	L["Wor'var Corral"] = "Wor'varpferch";
	L["Rangari Corral"] = "Rangaripferch";
	L["Wor'var Tankworks"] = "Panzerwerk von Wor'var";
	L["Telaari Tankworks"] = "Panzerwerk von Telaar";
end

if LOCALE_esES then
	L["Lowlands Lumber Yard"] = "Almacén de Madera de las Tierras Bajas";
	L["Highpass Sparring Ring"] = "Arena de Entrenamiento de Paso Alto";
	L["Arcane Sanctum"] = "Sagrario Arcano";
	L["Vol'jin's Arsenal"] = "Arsenal de Vol'jin";
	L["Wrynn Artillery Tower"] = "Torre de Artillería Wrynn";
	L["Smuggler's Den"] = "Guarida del Traficante";
	L["Hearthfire Tavern"] = "Taberna Lar de Fuego";
	L["Stoktron Brewery"] = "Cervecería Stoktron";
	L["Wor'var Corral"] = "Corral de Wor'var";
	L["Rangari Corral"] = "Corral Rangari";
	L["Wor'var Tankworks"] = "Tanquería de Wor'var";
	L["Telaari Tankworks"] = "Tanquería Telaari";
end

if LOCALE_esMX then
	L["Lowlands Lumber Yard"] = "Almacén de Madera del Bajío";
	L["Highpass Sparring Ring"] = "Ring de Entrenamiento del Paso Alto";
	L["Arcane Sanctum"] = "Santuario Arcano";
	L["Vol'jin's Arsenal"] = "Arsenal de Vol'jin";
	L["Wrynn Artillery Tower"] = "Torre de Artillería Wrynn";
	L["Smuggler's Den"] = "Guarida del Contrabandista";
	L["Hearthfire Tavern"] = "Taberna Fuego Hogareño";
	L["Stoktron Brewery"] = "Sidrería Stoktron";
	L["Wor'var Corral"] = "Corral Wor'var";
	L["Rangari Corral"] = "Corral Rangari";
	L["Wor'var Tankworks"] = "Estación de Tanques de Wor'var";
	L["Telaari Tankworks"] = "Estación de Tanques de Telaari";
end

if LOCALE_frFR then
	L["Lowlands Lumber Yard"] = "Dépôt de bois des Plaines";
	L["Highpass Sparring Ring"] = "Arène d’entraînement de la Haute-Route";
	L["Arcane Sanctum"] = "Le sanctum des Arcanes";
	L["Vol'jin's Arsenal"] = "Arsenal de Vol’jin";
	L["Wrynn Artillery Tower"] = "Tour d’artillerie de Wrynn";
	L["Smuggler's Den"] = "Tanière du Contrebandier";
	L["Hearthfire Tavern"] = "Taverne d’Âtrefeu";
	L["Stoktron Brewery"] = "Brasserie Stoktron";
	L["Wor'var Corral"] = "Corral de Wor’var";
	L["Rangari Corral"] = "Corral Rangari";
	L["Wor'var Tankworks"] = "Cuirasserie de Wor’var";
	L["Telaari Tankworks"] = "Cuirasserie Telaari";
end

if LOCALE_itIT then
	L["Lowlands Lumber Yard"] = "Campo di Taglio del Bassopiano";
	L["Highpass Sparring Ring"] = "Spiazzo d'Addestramento di Altopasso";
	L["Arcane Sanctum"] = "Santuario Arcano";
	L["Vol'jin's Arsenal"] = "Armeria di Vol'jin";
	L["Wrynn Artillery Tower"] = "Torre d'Artiglieria di Wrynn";
	L["Smuggler's Den"] = "Antro del Contrabbandiere";
	L["Hearthfire Tavern"] = "Taverna del Caldo Focolare";
	L["Stoktron Brewery"] = "Birrificio di Stoktron";
	L["Wor'var Corral"] = "Recinto di Wor'var";
	L["Rangari Corral"] = "Recinto dei Guardaselve";
	L["Wor'var Tankworks"] = "Officina Bellica di Wor'var";
	L["Telaari Tankworks"] = "Officina Bellica di Telaar";
end

if LOCALE_koKR then
	L["Lowlands Lumber Yard"] = "저지대 벌목장";
	L["Highpass Sparring Ring"] = "오름길 대련장";
	L["Arcane Sanctum"] = "비전 성소";
	L["Vol'jin's Arsenal"] = "볼진의 전쟁기지";
	L["Wrynn Artillery Tower"] = "린의 포격 요새";
	L["Smuggler's Den"] = "밀수업자의 소굴";
	L["Hearthfire Tavern"] = "난롯불 선술집";
	L["Stoktron Brewery"] = "스톡트론 양조장";
	L["Wor'var Corral"] = "올바르 동물 우리";
	L["Rangari Corral"] = "랑가리 동물 우리";
	L["Wor'var Tankworks"] = "올바르 전차작업장";
	L["Telaari Tankworks"] = "텔라아리 전차작업장";
end

if LOCALE_ptBR or LOCALE_ptPT then
	L["Lowlands Lumber Yard"] = "Serraria das Terras Baixas";
	L["Highpass Sparring Ring"] = "Arena de Pugilato de Passoalto";
	L["Arcane Sanctum"] = "Santuário Arcano";
	L["Vol'jin's Arsenal"] = "Arsenal de Vol'jin";
	L["Wrynn Artillery Tower"] = "Torre de Artilharia de Wrynn";
	L["Smuggler's Den"] = "Covil do Contrabandista";
	L["Hearthfire Tavern"] = "Taberna Calor da Lareira";
	L["Stoktron Brewery"] = "Cervejaria Stoktron";
	L["Wor'var Corral"] = "Curral de Wor'var";
	L["Rangari Corral"] = "Curral Rangari";
	L["Wor'var Tankworks"] = "Oficina de Tanques de Wor'var";
	L["Telaari Tankworks"] = "Oficina de Tanques Telaari";
end

if LOCALE_ruRU then
	L["Lowlands Lumber Yard"] = "Низинная лесопилка";
	L["Highpass Sparring Ring"] = "Бойцовская арена Верхнего Пути";
	L["Arcane Sanctum"] = "Волшебное святилище";
	L["Vol'jin's Arsenal"] = "Оружейная Вол'джина";
	L["Wrynn Artillery Tower"] = "Артиллерийская башня Ринна";
	L["Smuggler's Den"] = "Логово контрабандистов";
	L["Hearthfire Tavern"] = "Таверна \"Домашний очаг\"";
	L["Stoktron Brewery"] = "Хмелеварня Стоктрона";
	L["Wor'var Corral"] = "Вор'варские стойла";
	L["Rangari Corral"] = "Стойла рангари";
	L["Wor'var Tankworks"] = "Танковая мастерская Вор'вара";
	L["Telaari Tankworks"] = "Танковая мастерская Телаара";
end

if LOCALE_zhCN then
	L["Lowlands Lumber Yard"] = "低地伐木场";
	L["Highpass Sparring Ring"] = "高山走廊格斗竞技场";
	L["Arcane Sanctum"] = "奥秘圣殿";
	L["Vol'jin's Arsenal"] = "沃金的军械库";
	L["Wrynn Artillery Tower"] = "乌瑞恩炮塔";
	L["Smuggler's Den"] = "走私者巢穴";
	L["Hearthfire Tavern"] = "炉火旅店";
	L["Stoktron Brewery"] = "斯托克顿酿酒厂";
	L["Wor'var Corral"] = "沃尔瓦兽栏";
	L["Rangari Corral"] = "游侠兽栏";
	L["Wor'var Tankworks"] = "沃尔瓦坦克工厂";
	L["Telaari Tankworks"] = "塔拉坦克工厂";
end

if LOCALE_zhTW then
	L["Lowlands Lumber Yard"] = "低地鋸木廠";
	L["Highpass Sparring Ring"] = "高地之路搏擊競技場";
	L["Arcane Sanctum"] = "秘法聖所";
	L["Vol'jin's Arsenal"] = "沃金軍備所";
	L["Wrynn Artillery Tower"] = "烏瑞恩砲塔";
	L["Smuggler's Den"] = "走私者的巢穴";
	L["Hearthfire Tavern"] = "爐火旅店";
	L["Stoktron Brewery"] = "史塔克釀酒場";
	L["Wor'var Corral"] = "沃瓦爾畜欄";
	L["Rangari Corral"] = "遊俠畜欄";
	L["Wor'var Tankworks"] = "沃瓦爾坦克工坊";
	L["Telaari Tankworks"] = "泰拉蕊坦克工坊";
end
