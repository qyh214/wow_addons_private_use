local _L = LibStub("AceLocale-3.0"):NewLocale("HandyNotes_Argus", "esES") or LibStub("AceLocale-3.0"):NewLocale("HandyNotes_Argus", "esMX")

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

_L["Watcher Aival"] = "Watcher Aival";
_L["Watcher Aival_search"] = { "aival", "aival" };
_L["Watcher Aival_note"] = "";
_L["Puscilla"] = "Puscilla";
_L["Puscilla_search"] = { "pus", "puscilla" };
_L["Puscilla_note"] = "La entrada a la cueva está al sureste, usa el puente del este para llegar hasta ahí.";
_L["Vrax'thul"] = "Vrax'thul";
_L["Vrax'thul_search"] = { "vrax", "vrax'thul", "vraxthul", "vrax thul" };
_L["Vrax'thul_note"] = "";
_L["Ven'orn"] = "Ven'orn";
_L["Ven'orn_search"] = { "ven", "ven'orn", "venorn", "ven orn" };
_L["Ven'orn_note"] = "La entrada a la cueva está al noreste de aquí, en la zona de las arañas en 66, 54.1";
_L["Varga"] = "Varga";
_L["Varga_search"] = { "var", "varga" };
_L["Varga_note"] = "";
_L["Lieutenant Xakaar"] = "Lieutenant Xakaar";
_L["Lieutenant Xakaar_search"] = { "xa", "xakaar" };
_L["Lieutenant Xakaar_note"] = "";
_L["Wrath-Lord Yarez"] = "Wrath-Lord Yarez";
_L["Wrath-Lord Yarez_search"] = { "ya", "yarez" };
_L["Wrath-Lord Yarez_note"] = "";
_L["Inquisitor Vethroz"] = "Inquisitor Vethroz";
_L["Inquisitor Vethroz_search"] = { "vet", "vethroz", "vetroz" };
_L["Inquisitor Vethroz_note"] = "";
_L["Portal to Commander Texlaz"] = "Portal a Commander Texlaz";
_L["Portal to Commander Texlaz_note"] = "";
_L["Commander Texlaz"] = "Commander Texlaz";
_L["Commander Texlaz_search"] = { "tex", "texlaz" };
_L["Commander Texlaz_note"] = "Usa el portal en 80.2, 62.3 para llegar a la nave";
_L["Admiral Rel'var"] = "Admiral Rel'var";
_L["Admiral Rel'var_search"] = { "rel", "rel.?var" };
_L["Admiral Rel'var_note"] = "";
_L["All-Seer Xanarian"] = "All-Seer Xanarian";
_L["All-Seer Xanarian_search"] = { "xa", "xanar" };
_L["All-Seer Xanarian_note"] = "";
_L["Worldsplitter Skuul"] = "Worldsplitter Skuul";
_L["Worldsplitter Skuul_search"] = { "sku", "skuul", "skul" };
_L["Worldsplitter Skuul_note"] = "Puede estar patrullando por el aire. A veces estará cerca del suelo, pero no siempre en cada vuelta.";
_L["Houndmaster Kerrax"] = "Houndmaster Kerrax";
_L["Houndmaster Kerrax_search"] = { "ker", "kerrax", "kerax" };
_L["Houndmaster Kerrax_note"] = "";
_L["Void Warden Valsuran"] = "Void Warden Valsuran";
_L["Void Warden Valsuran_search"] = { "val", "valsuran" };
_L["Void Warden Valsuran_note"] = "";
_L["Chief Alchemist Munculus"] = "Chief Alchemist Munculus";
_L["Chief Alchemist Munculus_search"] = { "mun", "munculus", "muculus" };
_L["Chief Alchemist Munculus_note"] = "";
_L["The Many-Faced Devourer"] = "The Many-Faced Devourer";
_L["The Many-Faced Devourer_search"] = { "face", "many.*face", "face.*devourer" };
_L["The Many-Faced Devourer_note"] = "Se puede invocar siempre. Pero tienes que encontrar la «Llamada del Devorador» en los enemigos cercanos y 3 cosas más, y volver al montón de huesos para invocarlo.";
_L["Portal to Squadron Commander Vishax"] = "Portal a Squadron Commander Vishax";
_L["Portal to Squadron Commander Vishax_note"] = "Primero consigue un Generador de portal machacado de un Caminante abisal inmortal. Luego consigue una vaina conductiva, un circuito eléctrico y una célula de energía de los Estratega eredar y Mirmidón jurapenas. Usa el Generador de portal machacado para desbloquear el portal a Vishax.";
_L["Squadron Commander Vishax"] = "Squadron Commander Vishax";
_L["Squadron Commander Vishax_search"] = { "vis", "vishax", "visax" };
_L["Squadron Commander Vishax_note"] = "Usa el portal en 77.2, 73.2 para llegar hasta la nave";
_L["Doomcaster Suprax"] = "Doomcaster Suprax";
_L["Doomcaster Suprax_search"] = { "sup", "suprax" };
_L["Doomcaster Suprax_note"] = "Ponte encima de las 3 runas para invocarlo. ¡Tardarán 5 minutos en aparecer si fracasas!";
_L["Mother Rosula"] = "Mother Rosula";
_L["Mother Rosula_search"] = { "ros", "rosula" };
_L["Mother Rosula_note"] = "Dentro de la cueva. Usa el puente del este. Consigue 100 Carnes de diablillo de los diablillos en la cueva. Úsalos para crear un Festín asqueroso y ponlo dentro de la sopa verde donde está marca.";
_L["Rezira the Seer"] = "Rezira the Seer";
_L["Rezira the Seer_search"] = { "rez", "rezira" };
_L["Rezira the Seer_note"] = "Usa el Resonador del Enclave del Observador para abrir un portal a él. Orix el Omnividente(60.2, 45.4) lo vende por 500 Ojos de demonio intactos.";
_L["Blistermaw"] = "Blistermaw";
_L["Blistermaw_search"] = { "blis", "blister" };
_L["Blistermaw_note"] = "";
_L["Mistress Il'thendra"] = "Mistress Il'thendra";
_L["Mistress Il'thendra_search"] = { "then", "thendra" };
_L["Mistress Il'thendra_note"] = "";
_L["Gar'zoth"] = "Gar'zoth";
_L["Gar'zoth_search"] = { "gar", "gar.?zot" };
_L["Gar'zoth_note"] = "";

_L["One-of-Many"] = "One-of-Many";
_L["One-of-Many_note"] = "";
_L["Minixis"] = "Minixis";
_L["Minixis_note"] = "";
_L["Watcher"] = "Watcher";
_L["Watcher_note"] = "";
_L["Bloat"] = "Bloat";
_L["Bloat_note"] = "";
_L["Earseeker"] = "Earseeker";
_L["Earseeker_note"] = "";
_L["Pilfer"] = "Pilfer";
_L["Pilfer_note"] = "";

_L["Orix the All-Seer"] = "Orix the All-Seer";
_L["Orix the All-Seer_note"] = "Encuentra ojos demoníacos verdes. Haz clic en ellos. Pierde 90% de vida y empieza a matar demonios de esta zona para conseguir ojos.";

_L["Forgotten Legion Supplies"] = "Suministros de la Legión olvidados";
_L["Forgotten Legion Supplies_note"] = "Usa el salto del ensamblaje bélico forjado con luz para destruir los pedruscos que bloquean el paso.";
_L["Ancient Legion War Cache"] = "Alijo bélico de la Legión antiguo";
_L["Ancient Legion War Cache_note"] = "Con cuidado, desciende hasta la pequeña cueva. Un parapente puede ayudar. Destruye las rocas con la Sentencia de la luz.";
_L["Fel-Bound Chest"] = "Cofre de vínculo vil";
_L["Fel-Bound Chest_note"] = "Empieza un poco al sureste, en 53.7, 30.9. Usa las rocas para llegar hasta la cueva. Hay rocas bloqueando el paso. Destrúyelas con la Sentencia de la luz.";
_L["Legion Treasure Hoard"] = "Tesoro acumulado de la Legión";
_L["Legion Treasure Hoard_note"] = "Detrás de la cascada de fuego vil. Recógelo.";
_L["Timeworn Fel Chest"] = "Cofre vil vetusto";
_L["Timeworn Fel Chest_note"] = "Empieza en Xanarian. Pasa su edificio por el lado izquierdo. Baja por las rocas hasta llegar al cofre rodeado de mucosa verde.";
_L["Missing Augari Chest"] = "Cofre Augari desaparecido";
_L["Missing Augari Chest_note"] = "El cofre está cerca de la mucosa verde. Usa Embozo de ecos Arcanos y después ábrelo.";

-- 48382
_L["48382_67546980_note"] = "Dentro del edificio";
_L["48382_67466226_note"] = "";
_L["48382_71326946_note"] = "Al lado de Hadrox";
_L["48382_58066806_note"] = "";
_L["48382_68026624_note"] = "Dentro de la estructura de la Legión";
_L["48382_64506868_note"] = "Fuera";
_L["48382_62666823_note"] = "Dentro de edificio";
_L["48382_60096945_note"] = "Fuera, detrás del edificio";
_L["48382_62146938_note"] = "";
_L["48382_69496785_note"] = "";
_L["48382_58806467_note"] = "Dentro del edificio";
_L["48382_57796495_note"] = "";
-- 48383
_L["48383_56903570_note"] = "";
_L["48383_57633179_note"] = "";
_L["48383_52182918_note"] = "";
_L["48383_58174021_note"] = "";
_L["48383_51863409_note"] = "";
_L["48383_55133930_note"] = "";
_L["48383_58413097_note"] = "Dentro del edificio, planta baja";
_L["48383_53753556_note"] = "";
_L["48383_51703529_note"] = "En lo alto del precipicio";
_L["48383_59853583_note"] = "";
_L["48383_58273570_note"] = "Dentro del edificio, se entra por la plataforma de Il'thendra"
-- 48384
_L["48384_60872900_note"] = "";
_L["48384_61332054_note"] = "Dentro del edificio de Munculus";
_L["48384_59081942_note"] = "Dentro del edificio";
_L["48384_64152305_note"] = "Dentro de la cueva de Kerrax";
_L["48384_66621709_note"] = "Dentro de la cueva de diablillos, al lado de Rosula";
_L["48384_63682571_note"] = "Delante de la cueva de Kerrax";
_L["48384_61862236_note"] = "Fuera, al lado de Munculus";
_L["48384_64132738_note"] = "";
_L["48384_63522090_note"] = "Final de la cueva de Kerrax";
-- 48385
_L["48385_50605720_note"] = "";
_L["48385_55544743_note"] = "";
_L["48385_57135124_note"] = "";
_L["48385_55915425_note"] = "";
_L["48385_48195451_note"] = "";
_L["48385_57825901_note"] = "";
-- 48387
_L["48387_69403965_note"] = "";
_L["48387_66643654_note"] = "";
_L["48387_68983342_note"] = "";
_L["48387_65522831_note"] = "Debajo del puente";
_L["48387_73404669_note"] = "Pasa por la mucosa";
_L["48387_67954006_note"] = "";
_L["48387_63603642_note"] = "";
_L["48387_72404207_note"] = "";
-- 48388
_L["48388_51502610_note"] = "";
_L["48388_59261743_note"] = "";
_L["48388_55921387_note"] = "";
_L["48388_55841722_note"] = "";
_L["48388_55622042_note"] = "Cerca de Valsura, sube la cuesta rocosa";
_L["48388_59661398_note"] = "";
_L["48388_54102803_note"] = "Cerca de la plataforma de Aivals";
_L["48388_55922675_note"] = "";
-- 48389
_L["48389_64305040_note"] = "En la cueva de Varga";
_L["48389_60254351_note"] = "";
_L["48389_65514081_note"] = "";
_L["48389_60304675_note"] = "";
_L["48389_65345192_note"] = "En la cueva detrás de Varga";
_L["48389_64114242_note"] = "Bajo rocas";
_L["48389_58734323_note"] = "En trozos pequeños de tierra en la mucosa";
_L["48389_62955007_note"] = "La orilla de la mucosa verde";
_L["48389_64254720_note"] = "";
-- 48390
_L["48390_81306860_note"] = "En la nave";
_L["48390_80406152_note"] = "";
_L["48390_82566503_note"] = "En la nave";
_L["48390_73316858_note"] = "Nivel superior al lado de Rel'var";
_L["48390_77127529_note"] = "Al lado del portal a Vishax";
_L["48390_72527293_note"] = "Detrás de Rel'var";
_L["48390_77255876_note"] = "Bajando la cuesta";
_L["48390_72215680_note"] = "Dentro del edificio";
_L["48390_73277299_note"] = "Detrás de Rel'var";
_L["48390_77975620_note"] = "Bajando la cuesta y más allá pasando los precipicios"
_L["48390_77246412_note"] = "Cuidado de vuelta. ¡No te tires por los precipicios!";
_L["48390_76595659_note"] = "Dentro del edificio de Xanarian";
-- 48391
_L["48391_64135867_note"] = "En la cueva de arañas de Ven'or";
_L["48391_67404790_note"] = "En la zona de arañas, en una pequeña cueva al lado de la salida norte";
_L["48391_63615622_note"] = "En la cueva de arañas de Ven'or";
_L["48391_65005049_note"] = "Fuera en la zona de arañas";
_L["48391_63035762_note"] = "En la cueva de arañas de Ven'orn";
_L["48391_65185507_note"] = "Entrada superior a la zona de arañas";
_L["48391_68095075_note"] = "Dentro de una cueva pequeña en la zona de arañas";
_L["48391_69815522_note"] = "Fuera en la zona de arañas";
_L["48391_71205441_note"] = "Fuera en la zona de arañas";
_L["48391_66544668_note"] = "Deja la zona de arañas hacia el norte, donde está la zona verde en el suelo. Salta sobre las rocas.";
_L["48391_65164951_note"] = "Dentro de una cueva pequeña en la zona de arañas"

-- Krokuun
_L["Khazaduum"] = "Khazaduum";
_L["Khazaduum_search"] = { "aza", "khazadum", "khazaduum", "kazadum", "kazaduum" };
_L["Khazaduum_note"] = "La entrada está al sureste en 50.3, 17.3";
_L["Commander Sathrenael"] = "Commander Sathrenael";
_L["Commander Sathrenael_search"] = { "sat", "sathrenael" };
_L["Commander Sathrenael_note"] = "";
_L["Commander Endaxis"] = "Commander Endaxis";
_L["Commander Endaxis_search"] = { "end", "endaxis" };
_L["Commander Endaxis_note"] = "";
_L["Sister Subversia"] = "Sister Subversia";
_L["Sister Subversia_search"] = { "sub", "subversia" };
_L["Sister Subversia_note"] = "";
_L["Siegemaster Voraan"] = "Siegemaster Voraan";
_L["Siegemaster Voraan_search"] = { "vor", "voran", "voraan" };
_L["Siegemaster Voraan_note"] = "";
_L["Talestra the Vile"] = "Talestra the Vile";
_L["Talestra the Vile_search"] = { "tal", "talestra" };
_L["Talestra the Vile_note"] = "";
_L["Commander Vecaya"] = "Commander Vecaya";
_L["Commander Vecaya_search"] = { "vec", "veca[yj]a" };
_L["Commander Vecaya_note"] = "El camino que te llevará a ella empieza en 42, 57.1";
_L["Vagath the Betrayed"] = "Vagath the Betrayed";
_L["Vagath the Betrayed_search"] = { "vag", "vagat" };
_L["Vagath the Betrayed_note"] = "";
_L["Tereck the Selector"] = "Tereck the Selector";
_L["Tereck the Selector_search"] = { "ter", "tereck", "terek" };
_L["Tereck the Selector_note"] = "";
_L["Tar Spitter"] = "Tar Spitter";
_L["Tar Spitter_search"] = { "tar", "tar.*spitter" };
_L["Tar Spitter_note"] = "";
_L["Imp Mother Laglath"] = "Imp Mother Laglath";
_L["Imp Mother Laglath_search"] = { "lag", "laglat" };
_L["Imp Mother Laglath_note"] = "";
_L["Naroua"] = "Naroua";
_L["Naroua_search"] = { "nar", "naroua" };
_L["Naroua_note"] = "";

_L["Baneglow"] = "Baneglow";
_L["Baneglow_note"] = "";
_L["Foulclaw"] = "Foulclaw";
_L["Foulclaw_note"] = "";
_L["Ruinhoof"] = "Ruinhoof";
_L["Ruinhoof_note"] = "";
_L["Deathscreech"] = "Deathscreech";
_L["Deathscreech_note"] = "";
_L["Gnasher"] = "Gnasher";
_L["Gnasher_note"] = "";
_L["Retch"] = "Retch";
_L["Retch_note"] = "";

-- Shoot First, Loot Later
_L["Krokul Emergency Cache"] = "Alijo krokul de emergencia";
_L["Krokul Emergency Cache_note"] = "La cueva está en lo alto del precipicio. Hay rocas bloqueando el camino. Usa el salto del ensamblaje bélico forjado con luz para destruir los pedruscos que bloquean el paso.";
_L["Legion Tower Chest"] = "Cofre de la torre de la Legión";
_L["Legion Tower Chest_note"] = "En el camino hacia Naroua hay rocas bloqueando el acceso al cofre. Destrúyelas con la Sentencia de la luz.";
_L["Lost Krokul Chest"] = "Cofre krokul perdido";
_L["Lost Krokul Chest_note"] = "En una pequeña cueva por el camino. Usa la Sentencia de la Luz para destruir las rocas.";
_L["Long-Lost Augari Treasure"] = "Tesoro Augari olvidado";
_L["Long-Lost Augari Treasure_note"] = "Usa Embozo de ecos Arcanos y después ábrelo.";
_L["Precious Augari Keepsakes"] = "Recuerdos Augari preciados";
_L["Precious Augari Keepsakes_note"] = "Usa Embozo de ecos Arcanos y después ábrelo.";

-- 47752
_L["47752_55555863_note"] = "Salta sobre las rocas, empieza un poco al oeste";
_L["47752_52185431_note"] = "Sigue el camino hasta donde te encuentras con Alleria por primera vez.";
_L["47752_50405122_note"] = "Sigue el camino hasta donde te encuentras con Alleria por primera vez.";
_L["47752_53265096_note"] = "Sigue el camino hasta donde te encuentras con Alleria por primera vez. Al otro lado de la mucosa verde. ¡El fuego, aunque verde, quema!";
_L["47752_57005472_note"] = "Under the rock outcropping, on the tiny lip of land";
_L["47752_59695196_note"] = "Cerca de Xeth'tal, detrás de rocas.";
_L["47752_51425958_note"] = "";
_L["47752_55525237_note"] = "Nivel inferior de la zona. Necesitas saltar por mierda verde. Es un cofre irritante. Empieza en Xeth'tal.";
_L["47752_58375051_note"] = "";
-- 47753
_L["47753_53137304_note"] = "";
_L["47753_55228114_note"] = "";
_L["47753_59267341_note"] = "";
_L["47753_56118037_note"] = "Fuera del edificio de Talestra";
_L["47753_58597958_note"] = "Detrás del pincho demoníaco";
_L["47753_58197157_note"] = "";
_L["47753_52737591_note"] = "Detrás de rocas";
_L["47753_58048036_note"] = "";
_L["47753_60297610_note"] = "";
_L["47753_56827212_note"] = "";
-- 47997
_L["47997_45876777_note"] = "Debajo de rocas, al lado del puente";
_L["47997_45797753_note"] = "";
_L["47997_43858139_note"] = "El camino empieza en 49.1, 69.3. Sigue la cresta dirección sur hasta llegar al cofre.";
_L["47997_43816689_note"] = "Debajo de rocas. Salta hacia abajo desde el camino cerca del puente.";
_L["47997_40687531_note"] = "";
_L["47997_46996831_note"] = "Encima de la calavera de serpiente";
_L["47997_41438003_note"] = "Escala las rocas para llegar a la nave de la legión estrellada";
_L["47997_41548379_note"] = "";
_L["47997_46458665_note"] = "Salta las rocas para llegar hasta el cofre.";
_L["47997_40357414_note"] = "";
_L["47997_44198653_note"] = "";
_L["47997_46787984_note"] = "";
_L["47997_42737546_note"] = "";
-- 47999
_L["47999_62592581_note"] = "";
_L["47999_59763951_note"] = "";
_L["47999_59071884_note"] = "Arriba, detrás de rocas";
_L["47999_61643520_note"] = "";
_L["47999_61463580_note"] = "Dentro del edificio";
_L["47999_59603052_note"] = "Nivel del puente";
_L["47999_60891852_note"] = "Dentro de la cabaña detrás de Vagath";
_L["47999_49063350_note"] = "";
_L["47999_65992286_note"] = "";
_L["47999_64632319_note"] = "Dentro del edificio";
_L["47999_51533583_note"] = "Fuera del edificio, cerca del charco de mucosa";
_L["47999_60422354_note"] = "";
_L["47999_62763812_note"] = "Dentro del edificio";
_L["47999_60492781_note"] = "";
_L["47999_46768337_note"] = "";
_L["47999_59433273_note"] = "En lo alto del precipicio";
_L["47999_58442866_note"] = "Dentro del edificio";
_L["47999_48613092_note"] = "";
_L["47999_57642617_note"] = "En lo alto del precipicio";
-- 48000
_L["48000_70907370_note"] = "";
_L["48000_74136790_note"] = "";
_L["48000_75166435_note"] = "La parte trasera de la cueva";
_L["48000_69605772_note"] = "";
_L["48000_69787836_note"] = "Salta a la cuesta que está al lado";
_L["48000_68566054_note"] = "Delante de la cueva de Tereck el Selector";
_L["48000_72896482_note"] = "";
_L["48000_71827536_note"] = "";
_L["48000_73577146_note"] = "";
_L["48000_71846166_note"] = "Escala el pilar marcado";
_L["48000_67886231_note"] = "Detrás del pilar";
_L["48000_74996922_note"] = "";
_L["48000_62946824_note"] = "En la cueva de arriba. Sube las rocas al este de aquí para llegar hasta la cueva."
_L["48000_69386278_note"] = "";
_L["48000_67656999_note"] = "Sube la cuesta y pasa los pilares marcados para llegar al cofre.";
_L["48000_69218397_note"] = "";
-- 48336
_L["48336_33575511_note"] = "Nivel superior de Xenadar, fuera";
_L["48336_32047441_note"] = "";
_L["48336_27196668_note"] = "";
_L["48336_31936750_note"] = "";
_L["48336_35415637_note"] = "Planta baja, delante de la entrada de abajo de Xenadar.";
_L["48336_29645761_note"] = "Dentro de la cueva";
_L["48336_40526067_note"] = "Dentro de la cabaña amarilla";
_L["48336_36205543_note"] = "Dentro de Xenadar, nivel superior";
_L["48336_25996814_note"] = "";
_L["48336_37176401_note"] = "Bajo escombros";
_L["48336_28247134_note"] = "";
_L["48336_30276403_note"] = "Dentro de la cápsula de escape";
_L["48336_34566305_note"] = "";
_L["48336_36605881_note"] = "Nivel superior de Xenadar, fuera";
-- 48339
_L["48339_68533891_note"] = "";
_L["48339_63054240_note"] = "";
_L["48339_64964156_note"] = "";
_L["48339_73393438_note"] = "";
_L["48339_72213234_note"] = "Detrás de la calavera enorme";
_L["48339_65983499_note"] = "";
_L["48339_64934217_note"] = "Dentro del tronco del árbol";
_L["48339_67713454_note"] = "";
_L["48339_72493605_note"] = "";
_L["48339_44864342_note"] = "";
_L["48339_46094082_note"] = "";
_L["48339_70503063_note"] = "";
_L["48339_61876413_note"] = "";

-- Mac'Aree
_L["Shadowcaster Voruun"] = "Shadowcaster Voruun";
_L["Shadowcaster Voruun_search"] = { "vor", "voruun", "vorun" };
_L["Shadowcaster Voruun_note"] = "";
_L["Soultwisted Monstrosity"] = "Soultwisted Monstrosity";
_L["Soultwisted Monstrosity_search"] = { "mon", "monstro" };
_L["Soultwisted Monstrosity_note"] = "";
_L["Wrangler Kravos"] = "Wrangler Kravos";
_L["Wrangler Kravos_search"] = { "kra", "kravos" };
_L["Wrangler Kravos_note"] = "";
_L["Kaara the Pale"] = "Kaara the Pale";
_L["Kaara the Pale_search"] = { "ka", "ka?ara" };
_L["Kaara the Pale_note"] = "";
_L["Feasel the Muffin Thief"] = "Feasel the Muffin Thief";
_L["Feasel the Muffin Thief_search"] = { "f", "feasel", "muffin" };
_L["Feasel the Muffin Thief_note"] = "Interrumpe el excavar";
_L["Vigilant Thanos"] = "Vigilant Thanos";
_L["Vigilant Thanos_search"] = { "ano", "th?anos" };
_L["Vigilant Thanos_note"] = "";
_L["Vigilant Kuro"] = "Vigilant Kuro";
_L["Vigilant Kuro_search"] = { "kuro", "kuro" };
_L["Vigilant Kuro_note"] = "";
_L["Venomtail Skyfin"] = "Venomtail Skyfin";
_L["Venomtail Skyfin_search"] = { "i", "venomtail", "skyfin" };
_L["Venomtail Skyfin_note"] = "";
_L["Turek the Lucid"] = "Turek the Lucid";
_L["Turek the Lucid_search"] = { "tur", "turek" };
_L["Turek the Lucid_note"] = "Bajando las escaleras hacia el interior del edificio";
_L["Captain Faruq"] = "Captain Faruq";
_L["Captain Faruq_search"] = { "far", "faruq" };
_L["Captain Faruq_note"] = "";
_L["Umbraliss"] = "Umbraliss";
_L["Umbraliss_search"] = { "umb", "umbralis" };
_L["Umbraliss_note"] = "";
_L["Sorolis the Ill-Fated"] = "Sorolis the Ill-Fated";
_L["Sorolis the Ill-Fated_search"] = { "sor", "sorolis" };
_L["Sorolis the Ill-Fated_note"] = "";
_L["Herald of Chaos"] = "Herald of Chaos";
_L["Herald of Chaos_search"] = { "a", "herald", "harald" };
_L["Herald of Chaos_note"] = "Está en la segunda planta.";
_L["Sabuul"] = "Sabuul";
_L["Sabuul_search"] = { "sab", "sabuul", "sabul" };
_L["Sabuul_note"] = "";
_L["Jed'hin Champion Vorusk"] = "Jed'hin Champion Vorusk";
_L["Jed'hin Champion Vorusk_search"] = { "", "vorusk", "jed.?hin" };
_L["Jed'hin Champion Vorusk_note"] = "";
_L["Overseer Y'Beda"] = "Overseer Y'Beda";
_L["Overseer Y'Beda_search"] = { "beda", "beda" };
_L["Overseer Y'Beda_note"] = "";
_L["Overseer Y'Sorna"] = "Overseer Y'Sorna";
_L["Overseer Y'Sorna_search"] = { "sor", "sorna" };
_L["Overseer Y'Sorna_note"] = "";
_L["Overseer Y'Morna"] = "Overseer Y'Morna";
_L["Overseer Y'Morna_search"] = { "mor", "morna" };
_L["Overseer Y'Morna_note"] = "";
_L["Instructor Tarahna"] = "Instructor Tarahna";
_L["Instructor Tarahna_search"] = { "tara", "tarahna", "tarana" };
_L["Instructor Tarahna_note"] = "";
_L["Zul'tan the Numerous"] = "Zul'tan the Numerous";
_L["Zul'tan the Numerous_search"] = { "zul", "zul.?tan" };
_L["Zul'tan the Numerous_note"] = "Dentro del edificio";
_L["Commander Xethgar"] = "Commander Xethgar";
_L["Commander Xethgar_search"] = { "xet", "xethgar" };
_L["Commander Xethgar_note"] = "";
_L["Skreeg the Devourer"] = "Skreeg the Devourer";
_L["Skreeg the Devourer_search"] = { "skr", "skreeg", "skreg" };
_L["Skreeg the Devourer_note"] = "";
_L["Baruut the Bloodthirsty"] = "Baruut the Bloodthirsty";
_L["Baruut the Bloodthirsty_search"] = { "ba", "baruut", "barut" };
_L["Baruut the Bloodthirsty_note"] = "";
_L["Ataxon"] = "Ataxon";
_L["Ataxon_search"] = { "ata", "ataxon" };
_L["Ataxon_note"] = "";
_L["Slithon the Last"] = "Slithon the Last";
_L["Slithon the Last_search"] = { "sli", "slithon" };
_L["Slithon the Last_note"] = "";

_L["Gloamwing"] = "Gloamwing";
_L["Gloamwing_note"] = "";
_L["Bucky"] = "Bucky";
_L["Bucky_note"] = "";
_L["Mar'cuus"] = "Mar'cuus";
_L["Mar'cuus_note"] = "";
_L["Snozz"] = "Snozz";
_L["Snozz_note"] = "";
_L["Corrupted Blood of Argus"] = "Corrupted Blood of Argus";
_L["Corrupted Blood of Argus_note"] = "";
_L["Shadeflicker"] = "Shadeflicker";
_L["Shadeflicker_note"] = "";

_L["Nabiru"] = "Nabiru"
_L["Nabiru_note"] = "Está dentro de una cueva. Entrega 900 recursos para conseguir un seguidor de Sede de Clase.";

-- Shoot First, Loot Later
_L["Eredar Treasure Cache"] = "Alijo de tesoro eredar";
_L["Eredar Treasure Cache_note"] = "En una pequeña cueva. Usa el salto del ensamblaje bélico forjado con luz para destruir los pedruscos que bloquean el paso.";
_L["Chest of Ill-Gotten Gains"] = "Cofre de ganancias obtenidas con malas artes";
_L["Chest of Ill-Gotten Gains_note"] = "Usa la Sentencia de la Luz para destruir las rocas.";
_L["Student's Surprising Surplus"] = "Sorprendente excedente de estudiante";
_L["Student's Surprising Surplus_note"] = "El cofre está dentro de una cueva. La entrada está en 62.2, 72.2. Usa la Sentencia de la Luz para destruir las rocas.";
_L["Void-Tinged Chest"] = "Cofre teñido de vacío";
_L["Void-Tinged Chest_note"] = "En cueva subterránea. Usa el salto del ensamblaje bélico forjado con luz para destruir los pedruscos que bloquean el paso.";
_L["Augari Secret Stash"] = "Alijo secreto Augari";
_L["Augari Secret Stash_note"] = "Ve a 68.0, 56.9. Desde aquí podrás ver el alijo. Usando una montura, salta hacia el cofre. Al saltar, usa un parapente para llegar al cofre sin riesgos.";
_L["Desperate Eredar's Cache"] = "Alijo de eredar desesperado";
_L["Desperate Eredar's Cache_note"] = "Empieza en 57.1, 74.3 y ve hacia arriba saltando alrededor de esa torre hacia la parte de atrás.";
_L["Shattered House Chest"] = "Cofre de casa destruida";
_L["Shattered House Chest_note"] = "Ve a 31.2, 44.9, un poco al sureste de aquí. Salta hacia el abismo y usa un parapente para llegar al cofre.";
_L["Doomseeker's Treasure"] = "Tesoro del buscador de fatalidad";
_L["Doomseeker's Treasure_note"] = "El cofre está bajo tierra. Al este de aquí hay un agujero profundo por donde cae el agua del lago. Salta y reza por conseguirlo. Puedes usar una montura, pero un Kit de parapente goblin te ayudará a llegar fácilmente a la casa con el cofre.";
_L["Augari-Runed Chest"] = "Cofre con runas Augari";
_L["Augari-Runed Chest_note"] = "El cofre está debajo de un árbol. Usa Embozo de ecos Arcanos y después ábrelo.";
_L["Secret Augari Chest"] = "Cofre Augari secreto";
_L["Secret Augari Chest_note"] = "Dentro de la cabaña pequeña. Usa Embozo de ecos Arcanos y después ábrelo.";
_L["Augari Goods"] = "Bienes Augari";
_L["Augari Goods_note"] = "El cofre está dentro de la casa pequeña. Usa Embozo de ecos Arcanos y después ábrelo.";
-- Ancient Eredar Cache
-- 48346
_L["48346_55167766_note"] = "";
_L["48346_59386372_note"] = "Dentro de la tienda de campaña roja transparente";
_L["48346_57486159_note"] = "Dentro del edificio al lado de Kravos";
_L["48346_50836729_note"] = "";
_L["48346_52868241_note"] = "";
_L["48346_47186234_note"] = "";
_L["48346_50107580_note"] = "";
_L["48346_53328001_note"] = "En el sótano";
_L["48346_55297347_note"] = "";
_L["48346_52696161_note"] = "";
_L["48346_54806710_note"] = "";
_L["48346_51677163_note"] = "";
_L["48346_57397517_note"] = "";
_L["48346_61047074_note"] = "Debajo del árbol";
-- 48350
_L["48350_59622088_note"] = "Dentro del edificio debajo de las escaleras";
_L["48350_60493338_note"] = "Dentro del árbol";
_L["48350_53912335_note"] = "Dentro del árbol";
_L["48350_55063508_note"] = "";
_L["48350_62202636_note"] = "En el balcón. Entra en el edificio y sube las escaleras de la derecha.";
_L["48350_53332740_note"] = "Debajo del árbol";
_L["48350_58574078_note"] = "";
_L["48350_63262000_note"] = "Dentro del edificio";
_L["48350_54952484_note"] = "";
_L["48350_63332255_note"] = "Dentro de la cabaña roja";
-- 48351
_L["48351_43637134_note"] = "";
_L["48351_34205929_note"] = "En la segunda planta, donde yace el Heraldo del caos.";
_L["48351_43955630_note"] = "Debajo del árbol";
_L["48351_46917346_note"] = "Escondido debajo del árbol";
_L["48351_36296646_note"] = "";
_L["48351_42645361_note"] = "En una cueva. La entrada está al suroeste de aquí.";
_L["48351_38126342_note"] = "Dentro del sótano de Tureks";
_L["48351_42395752_note"] = "Dentro del edificio";
_L["48351_39175934_note"] = "Dentro del edificio en ruinas";
_L["48351_43555993_note"] = "En la cueva de Naribu";
_L["48351_35535717_note"] = "Segunda planta";
_L["48351_43666847_note"] = "Dentro del edificio en ruinas";
_L["48351_38386704_note"] = "";
_L["48351_35635604_note"] = "Segunda planta";
_L["48351_33795558_note"] = "";
-- 48357
_L["48357_49412387_note"] = "";
_L["48357_47672180_note"] = "";
_L["48357_48482115_note"] = "";
_L["48357_57881053_note"] = "";
_L["48357_52871676_note"] = "";
_L["48357_47841956_note"] = "";
_L["48357_51802871_note"] = "En la zona subiendo las escaleras al norte";
_L["48357_49912946_note"] = "";
_L["48357_54951750_note"] = "";
_L["48357_46381509_note"] = "";
_L["48357_50021442_note"] = "";
_L["48357_52631644_note"] = "";
_L["48357_45981325_note"] = "";
_L["48357_44571860_note"] = "";
_L["48357_53491281_note"] = "";
_L["48357_45241327_note"] = "";
_L["48357_48251289_note"] = "Planta baja, cerca de Skreeg";
_L["48357_44952483_note"] = "";
-- 48371
_L["48371_48604971_note"] = "";
_L["48371_49865494_note"] = "";
_L["48371_47023655_note"] = "Subiendo las escaleras";
_L["48371_49623585_note"] = "Subiendo las escaleras";
_L["48371_51094790_note"] = "Debajo del árbol";
_L["48371_35535718_note"] = "Segunda planta, al lado del Heraldo del caos";
_L["48371_25383016_note"] = "";
_L["48371_53594211_note"] = "";
_L["48371_59405863_note"] = "";
_L["48371_19694227_note"] = "Dentro del edificio";
_L["48371_24763858_note"] = "Dentro del edificio en ruinas";
_L["48371_50575594_note"] = "";
_L["48371_28913361_note"] = "";
_L["48371_32644686_note"] = "";
-- 48362
_L["48362_66682786_note"] = "Dentro del edificio, al lado de Zul'tan el Cuantioso";
_L["48362_62134077_note"] = "Dentro del edificio";
_L["48362_67254608_note"] = "Dentro del edificio";
_L["48362_68355322_note"] = "Dentro del edificio";
_L["48362_65966017_note"] = "";
_L["48362_62053268_note"] = "En terreno elevado";
_L["48362_60964354_note"] = "Dentro del edificio";
_L["48362_64445956_note"] = "Dentro del edificio";
_L["48362_65354194_note"] = "";
_L["48362_63924532_note"] = "";
_L["48362_67893170_note"] = "";
_L["48362_65974679_note"] = "Dentro del edificio";
_L["48362_68404122_note"] = "";
_L["48362_61924258_note"] = "Dentro del edificio";
_L["48362_67235673_note"] = "Dentro del edificio";
_L["48362_70243379_note"] = "";
_L["48362_69304993_note"] = "Dentro del edificio, planta del medio";
_L["48362_61395555_note"] = "Dentro del edificio";
-- Void-Seeped Cache / Treasure Chest
-- 49264
_L["49264_38143985_note"] = "";
_L["49264_37613608_note"] = "";
_L["49264_37812344_note"] = "";
_L["49264_33972078_note"] = "";
_L["49264_33312952_note"] = "";
_L["49264_37102005_note"] = "";
_L["49264_33592361_note"] = "Escondido debajo del árbol"
_L["49264_31582553_note"] = "";
_L["49264_32332131_note"] = "Medio escondido en una esquina";
_L["49264_35293848_note"] = "";
-- 48361
_L["48361_37664221_note"] = "Detrás del pilar en la «cueva»";
_L["48361_25824471_note"] = "";
_L["48361_20674033_note"] = "";
_L["48361_29503999_note"] = "";
_L["48361_29455043_note"] = "Debajo del árbol";
_L["48361_18794171_note"] = "Fuera, detrás del edificio";
_L["48361_25293498_note"] = "";
_L["48361_35283586_note"] = "Detrás de Umbraliss"
_L["48361_24654126_note"] = "";
_L["48361_37754868_note"] = "Abajo en la zona de la cueva";
_L["48361_39174733_note"] = "Abajo en la zona de la cueva";
_L["48361_28784425_note"] = "";
_L["48361_32583679_note"] = "";
_L["48361_19804660_note"] = "";

--
--	KEEP THESE ENGLISH FOR THE GROUP BROWSER IN EU/US!! CHINA & CO ADJUST
--	SEARCH ARRAY AS BEFORE, MUST HAVE MINIMUM 2 ELEMENTS
--

_L["Invasion Point: Val"] = "Invasion Point: Val";
_L["Invasion Point: Aurinor"] = "Invasion Point: Aurinor";
_L["Invasion Point: Sangua"] = "Invasion Point: Sangua";
_L["Invasion Point: Naigtal"] = "Invasion Point: Naigtal";
_L["Invasion Point: Bonich"] = "Invasion Point: Bonich";
_L["Invasion Point: Cen'gar"] = "Invasion Point: Cen'gar";
_L["Greater Invasion Point: Mistress Alluradel"] = "Greater Invasion: Alluradel";
_L["Greater Invasion Point: Matron Folnuna"] = "Greater Invasion: Folnuna";
_L["Greater Invasion Point: Sotanathor"] = "Greater Invasion: Sotanathor";
_L["Greater Invasion Point: Inquisitor Meto"] = "Greater Invasion: Meto";
_L["Greater Invasion Point: Pit Lord Vilemus"] = "Greater Invasion: Vilemus";
_L["Greater Invasion Point: Occularus"] = "Greater Invasion: Occularus";

_L["invasion_val_search"] = { "val", "invasion.*val", "val.*invasion" };
_L["invasion_aurinor_search"] = { "aurinor", "aurinor" };
_L["invasion_sangua_search"] = { "sangua", "sangua" };
_L["invasion_naigtal_search"] = { "naigtal", "naigtal" };
_L["invasion_bonich_search"] = { "bonich", "bonich" };
_L["invasion_cengar_search"] = { "cen", "cen.*gar" };
_L["invasion_alluradel_search"] = { "radel", "alluradel" };
_L["invasion_folnuna_search"] = { "fol", "folnuna" };
_L["invasion_sotanathor_search"] = { "sot", "sotana" };
_L["invasion_meto_search"] = { "meto", "meto" };
_L["invasion_vilemus_search"] = { "vil", "vilemus" };
_L["invasion_occularus_search"] = { "cul", "cularus" };

_L["Dreadblade Annihilator"] = "Dreadblade Annihilator";
_L["bsrare_dreadbladeannihilator_search"] = { "la", "dreadblade", "annihilator" };
_L["Salethan the Broodwalker"] = "Salethan the Broodwalker";
_L["bsrare_salethan_search"] = { "sal", "saleth?an" };
_L["Corrupted Bonebreaker"] = "Corrupted Bonebreaker";
_L["bsrare_corruptedbonebreaker_search"] = { "bone", "bonebreak" };
_L["Flllurlokkr"] = "Flllurlokkr";
_L["bsrare_flllurlokkr_search"] = { "lur", "lurlok" };
_L["Grossir"] = "Grossir";
_L["bsrare_grossir_search"] = { "gro", "gross?ir" };
_L["Eye of Gurgh"] = "Eye of Gurgh";
_L["bsrare_eyeofgurgh_search"] = { "gur", "gurg" };
_L["Somber Dawn"] = "Somber Dawn";
_L["bsrare_somberdawn_search"] = { "somb", "somber" };
_L["Felcaller Zelthae"] = "Felcaller Zelthae";
_L["bsrare_zelthae_search"] = { "zel", "zelth" };
_L["Duke Sithizi"] = "Duke Sithizi";
_L["bsrare_dukesithizi_search"] = { "sit", "sith?izi" };
_L["Lord Hel'Nurath"] = "Lord Hel'Nurath";
_L["bsrare_helnurath_search"] = { "nur", "nurat" };
_L["Imp Mother Bruva"] = "Imp Mother Bruva";
_L["bsrare_bruva_search"] = { "bru", "bruva" };
_L["Potionmaster Gloop"] = "Potionmaster Gloop";
_L["bsrare_gloop_search"] = { "gloop", "gloop" };
_L["Dreadeye"] = "Dreadeye";
_L["bsrare_dreadeye_search"] = { "dread", "dreadeye" };
_L["Malorus the Soulkeeper"] = "Malorus the Soulkeeper";
_L["bsrare_malorus_search"] = { "mal", "malorus" };
_L["Brother Badatin"] = "Brother Badatin";
_L["bsrare_badatin_search"] = { "tin", "badatin", "batadin" };
_L["Felbringer Xar'thok"] = "Felbringer Xar'thok";
_L["bsrare_xarthok_search"] = { "xar", "xar'?thok" };
_L["Malgrazoth"] = "Malgrazoth";
_L["bsrare_malgrazoth_search"] = { "mal", "malgra" };
_L["Emberfire"] = "Emberfire";
_L["bsrare_emberfire_search"] = { "ember", "emberfire" };
_L["Xorogun the Flamecarver"] = "Xorogun the Flamecarver";
_L["bsrare_xorogun_search"] = { "xor", "xorogun" };
_L["Lady Eldrathe"] = "Lady Eldrathe";
_L["bsrare_eldrathe_search"] = { "eld", "eldrat" };
_L["Aqueux"] = "Aqueux";
_L["bsrare_aqueux_search"] = { "aq", "aqueux" };
_L["Doombringer Zar'thoz"] = "Doombringer Zar'thoz";
_L["bsrare_zarthoz_search"] = { "zar", "zar'?th?oz" };
_L["Felmaw Emberfiend"] = "Felmaw Emberfiend";
_L["bsrare_felmawemberfiend_search"] = { "m", "felmaw", "emberfiend" };
_L["Inquisitor Chillbane"] = "Inquisitor Chillbane";
_L["bsrare_chillbane_search"] = { "chillbane", "chillbane" };
_L["Brood Mother Nix"] = "Brood Mother Nix";
_L["bsrare_broodmothernix_search"] = { "nix", "nix" };

--
--
-- INTERFACE
--
--

_L["Argus"] = "Argus";
_L["Antoran Wastes"] = "Baldío Antoran";
_L["Krokuun"] = "Krokuun";
_L["Mac'Aree"] = "Mac'Aree";

_L["Shield"] = "Escudo";
_L["Cloth"] = "Tela";
_L["Leather"] = "Cuero";
_L["Mail"] = "Malla";
_L["Plate"] = "Placas";
_L["1h Mace"] = "Maza de 1 mano";
_L["1h Sword"] = "Espada de 1 mano";
_L["1h Axe"] = "Hacha de 1 mano";
_L["2h Mace"] = "Maza de 2 manos";
_L["2h Axe"] = "Hacha de 2 manos";
_L["2h Sword"] = "Espada de 2 manos";
_L["Dagger"] = "Daga";
_L["Staff"] = "Bastón";
_L["Fist"] = "Puño";
_L["Polearm"] = "Lanza";
_L["Bow"] = "Arco";
_L["Gun"] = "Arma de fuego";
_L["Crossbow"] = "Ballesta";

_L["groupBrowserOptionOne"] = "%s - %s Miembro (%s)";
_L["groupBrowserOptionMore"] = "%s - %s Miembros (%s)";
_L["chatmsg_no_group_priv"] = "|cFFFF0000No hay derechos suficientes. No eres líder.";
_L["chatmsg_group_created"] = "|cFF6CF70FGrupo creado para %s.";
_L["chatmsg_search_failed"] = "|cFFFF0000Demasiadas solicitudes de búsqueda. Inténtalo de nuevo más tarde.";
_L["hour_short"] = "h";
_L["minute_short"] = "m";
_L["second_short"] = "s";

-- KEEP THESE 2 ENGLISH IN EU/US
_L["listing_desc_rare"] = "Doing rare encounter against %s on Argus.";
_L["listing_desc_invasion"] = "Doing %s on Argus.";

_L["Pet"] = "Mascota";
_L["(Mount known)"] = "(|cFF00FF00Montura conocida|r)";
_L["(Mount missing)"] = "(|cFFFF0000Montura no encontrada|r)";
_L["(Toy known)"] = "(|cFF00FF00Juguete conocido|r)";
_L["(Toy missing)"] = " (|cFFFF0000Juguete no encontrado|r)";
_L["(itemLinkGreen)"] = "(|cFF00FF00%s|r)";
_L["(itemLinkRed)"] = "(|cFFFF0000%s|r)";
_L["Retrieving data ..."] = "Recuperando datos ...";
_L["Sorry, no groups found!"] = "¡Lo siento, no se encontró grupo!";
_L["Search in Quests"] = "Buscar en Misiones";
_L["Groups found:"] = "Grupos encontrados:";
_L["Create new group"] = "Crear un nuevo grupo";
_L["Close"] = "Cerrar";

_L["context_menu_title"] = "Handynotes Argus";
_L["context_menu_check_group_finder"] = "Comprobar disponibilidad de grupos";
_L["context_menu_reset_rare_counters"] = "Reiniciar contadores de grupo";
_L["context_menu_add_tomtom"] = "Añadir a TomTom";
_L["context_menu_hide_node"] = "Ocultar este nodo";
_L["context_menu_restore_hidden_nodes"] = "Restablecer todos los nodos ocultos";

_L["options_title"] = "Argus";

_L["options_icon_settings"] = "Opciones de iconos";
_L["options_icon_settings_desc"] = "Opciones de iconos";
_L["options_icons_treasures"] = "Iconos de cofres del tesoro";
_L["options_icons_treasures_desc"] = "Iconos de cofres del tesoro";
_L["options_icons_rares"] = "Iconos de raros";
_L["options_icons_rares_desc"] = "Iconos de raros";
_L["options_icons_pet_battles"] = "Iconos de duelos de mascota";
_L["options_icons_pet_battles_desc"] = "Iconos de duelos de mascota";
_L["options_icons_sfll"] = "Iconos de «Dispara primero, despoja después»";
_L["options_icons_sfll_desc"] = "Iconos de «Disparar primero, despojar después»";
_L["options_scale"] = "Escala";
_L["options_scale_desc"] = "1 = 100%";
_L["options_opacity"] = "Opacidad";
_L["options_opacity_desc"] = "0 = transparente, 1 = opaco";
_L["options_visibility_settings"] = "Visibilidad";
_L["options_visibility_settings_desc"] = "Visibilidad";
_L["options_toggle_treasures"] = "Tesoros";
_L["options_toggle_rares"] = "Raros";
_L["options_toggle_battle_pets"] = "Mascotas de duelo";
_L["options_toggle_sfll"] = "Disparar primero, despojar después";
_L["options_toggle_npcs"] = "PNJs";
_L["options_toggle_portals"] = "Portales";
_L["options_general_settings"] = "General";
_L["options_general_settings_desc"] = "General";
_L["options_toggle_alreadylooted_rares"] = "Raros despojados";
_L["options_toggle_alreadylooted_rares_desc"] = "Mostrar todos los raros independientemente del estado de despojo";
_L["options_toggle_alreadylooted_treasures"] = "Tesoros despojados";
_L["options_toggle_alreadylooted_treasures_desc"] = "Mostrar todos los tesoros independientemente del estado de despojo";
_L["options_toggle_alreadylooted_sfll"] = "Ya has despojado los tesoros de «Disparar primero, despojar después»";
_L["options_toggle_alreadylooted_sfll_desc"] = "Mostrar todos los tesoros de logro independientemente del estado de despojo";
_L["options_toggle_nodeRareGlow"] = "Brillo de Iconos de raros"
_L["options_toggle_nodeRareGlow_desc"] = "Añade un brillo a los Iconos de raros dependiendo de la disponibilidad de grupos. Sin brillo = no hay grupos, brillo rojo = pocos grupos, brillo verde = muchos grupos."
_L["options_tooltip_settings"] = "Descripción emergente";
_L["options_tooltip_settings_desc"] = "Descripción emergente";
_L["options_toggle_show_loot"] = "Mostrar botín";
_L["options_toggle_show_loot_desc"] = "Añadir información de botín a la descripción emergente";
_L["options_toggle_show_notes"] = "Mostrar notas";
_L["options_toggle_show_notes_desc"] = "Añadir notas útiles a la descripción emergente cuando sea posible";

_L["options_general_settings"] = "General";
_L["options_general_settings_desc"] = "Opcines generales";
_L["options_toggle_leave_group_on_search"] = "Dejar grupos";
_L["options_toggle_leave_group_on_search_desc"] = "Dejar grupos al buscar grupos estando en uno. ¡Usar con cuidado!";
_L["chatmsg_old_group_delisted_create"] = "Se ha eliminado el grupo |cFFF7C92AOld de la lista. Haz clic otra vez para crear un nuevo grupo para %s."
_L["chatmsg_left_group_create"] = "|cFFF7C92AHa abandonado el grupo. Haz clic otra vez para crear un nuevo grupo para %s.";
_L["chatmsg_old_group_delisted_search"] = "Se ha eliminado el grupo |cFFF7C92AOld de la lista. Haz clic otra vez para buscar grupos para %s."
_L["chatmsg_left_group_search"] = "|cFFF7C92AHa abandonado el grupo. Haz clic otra vez para buscar grupos para %s.";

_L["options_toggle_include_player_seen"] = "Incluir los raros vistos por el jugador";
_L["options_toggle_include_player_seen_desc"] = "No usar todavía.";
_L["options_toggle_show_debug"] = "Eliminar fallos";
_L["options_toggle_show_debug_desc"] = "Mostrar cosas de eliminar fallos";

_L["options_toggle_hideKnowLoot"] = "Ocultar raro, si se conoce todo el botín";
_L["options_toggle_hideKnowLoot_desc"] = "Ocultar todos los raros de los cuales se conozca el botín.";

_L["options_toggle_alwaysTrackCoA"] = "Monitorizar siempre Comandante de Argus";
_L["options_toggle_alwaysTrackCoA_desc"] = "Monitorizar siempre Comandante de Argus, aunque el logro se haya completado en la cuenta pero no en este personaje.";
_L["Missing for CoALink"] = "No encontrado para %s";

end