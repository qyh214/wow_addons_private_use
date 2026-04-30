-- By D4KiR
local _, SpecBisTooltip = ...
local s = {}
if SpecBisTooltip:GetWoWBuild() == "TBC" then
    function SpecBisTooltip:GetTranslationMap()
        return s
    end
end

-- SOURCE FROM: 07.02.2026
if SpecBisTooltip:GetWoWBuild() == "TBC" then
    function SpecBisTooltip:TranslationenUS()
        s["npc;sold=20613"] = {"Arodis Sunblade <Keeper of Sha'tari Artifacts>", "Shattrath City"}
        s["npc;drop=18831"] = {"High King Maulgar <Lord of the Ogres>", "Gruul's Lair"}
        s["spell;created=26754"] = {"Spellfire Robe", "CRAFTING"}
        s["npc;sold=12792"] = {"Lady Palanseer <Armor Quartermaster>", "Alterac Valley"}
        s["spell;created=26753"] = {"Spellfire Gloves", "CRAFTING"}
        s["spell;created=26752"] = {"Spellfire Belt", "CRAFTING"}
        s["npc;drop=16457"] = {"Maiden of Virtue", "Karazhan"}
        s["npc;drop=15690"] = {"Prince Malchezaar", "Karazhan"}
        s["quest;reward=11002"] = {"The Fall of Magtheridon", "Hellfire Peninsula"}
        s["npc;drop=15688"] = {"Terestian Illhoof", "Karazhan"}
        s["npc;drop=17711"] = {"Doomwalker", "Shadowmoon Valley"}
        s["npc;sold=18525"] = {"G'eras", "Shattrath City"}
        s["npc;drop=17257"] = {"Magtheridon", "Magtheridon's Lair"}
        s["spell;created=31455"] = {"Spellstrike Hood", "CRAFTING"}
        s["spell;created=35588"] = {"Windhawk Bracers", "CRAFTING"}
        s["spell;created=31452"] = {"Spellstrike Pants", "CRAFTING"}
        s["npc;drop=15687"] = {"Moroes <Tower Steward>", "Karazhan"}
        s["npc;drop=16807"] = {"Grand Warlock Nethekurse", "The Shattered Halls"}
        s["spell;created=31454"] = {"Whitemend Hood", "CRAFTING"}
        s["spell;created=26761"] = {"Primal Mooncloth Shoulders", "CRAFTING"}
        s["spell;created=26762"] = {"Primal Mooncloth Robe", "CRAFTING"}
        s["npc;sold=21643"] = {"Alurmi <Keepers of Time Quartermaster>", "Tanaris"}
        s["spell;created=26760"] = {"Primal Mooncloth Belt", "CRAFTING"}
        s["npc;drop=18728"] = {"Doom Lord Kazzak", "Hellfire Peninsula"}
        s["quest;reward=11032"] = {"Protector No More", "Deadwind Pass"}
        s["npc;drop=18731"] = {"Ambassador Hellmaw", "Shadow Labyrinth"}
        s["npc;drop=19220"] = {"Pathaleon the Calculator", "The Mechanar"}
        s["npc;drop=17798"] = {"Warlord Kalithresh", "The Steamvault"}
        s["spell;created=31449"] = {"Vengeance Wrap", "CRAFTING"}
        s["npc;drop=17977"] = {"Warp Splinter", "The Botanica"}
        s["npc;drop=18096"] = {"Epoch Hunter", "Old Hillsbrad Foothills"}
        s["npc;drop=16808"] = {"Warchief Kargath Bladefist", "The Shattered Halls"}
        s["npc;drop=19044"] = {"Gruul the Dragonkiller", "Gruul's Lair"}
        s["npc;drop=18371"] = {"Shirrak the Dead Watcher", "Auchenai Crypts"}
        s["npc;drop=17534"] = {"Julianne", "Karazhan"}
        s["spell;created=34544"] = {"Mooncleaver", "CRAFTING"}
        s["npc;sold=17904"] = {"Fedryen Swiftspear <Cenarion Expedition Quartermaster>", "Zangarmarsh"}
        s["npc;sold=17585"] = {"Quartermaster Urgronn <Thrallmar Quartermaster>", "Hellfire Peninsula"}
        s["npc;drop=18168"] = {"The Crone", "Karazhan"}
        s["npc;drop=15691"] = {"The Curator", "Karazhan"}
        s["npc;drop=15689"] = {"Netherspite", "Karazhan"}
        s["npc;drop=16524"] = {"Shade of Aran", "Karazhan"}
        s["spell;created=26756"] = {"Frozen Shadoweave Shoulders", "CRAFTING"}
        s["spell;created=26758"] = {"Frozen Shadoweave Robe", "CRAFTING"}
        s["spell;created=31435"] = {"Bracers of Havok", "CRAFTING"}
        s["spell;created=31443"] = {"Girdle of Ruination", "CRAFTING"}
        s["spell;created=26757"] = {"Frozen Shadoweave Boots", "CRAFTING"}
        s["npc;drop=18667"] = {"Blackheart the Inciter", "Shadow Labyrinth"}
        s["quest;reward=9120"] = {"The Fall of Kel'Thuzad", "Eastern Plaguelands"}
        s["npc;drop=17521"] = {"The Big Bad Wolf", "Karazhan"}
        s["spell;created=42546"] = {"Cloak of Darkness", "CRAFTING"}
        s["npc;drop=16411"] = {"Spectral Chef", "Karazhan"}
        s["quest;reward=10280"] = {"Special Delivery to Shattrath City", "Netherstorm"}
        s["quest;reward=10806"] = {"Showdown", "Blade's Edge Mountains"}
        s["npc;drop=17225"] = {"Nightbane", "Karazhan"}
        s["spell;created=34540"] = {"Lionheart Champion", "CRAFTING"}
        s["npc;drop=17381"] = {"The Maker", "The Blood Furnace"}
        s["npc;drop=18697"] = {"Chief Engineer Lorthander", "Netherstorm"}
        s["npc;drop=16181"] = {"Rokad the Ravager", "Karazhan"}
        s["npc;drop=18693"] = {"Speaker Mar'grom", "Blade's Edge Mountains"}
        s["npc;drop=16179"] = {"Hyakiss the Lurker", "Karazhan"}
        s["npc;drop=16180"] = {"Shadikith the Glider", "Karazhan"}
        s["npc;drop=16485"] = {"Arcane Watchman", "Karazhan"}
        s["npc;drop=23281"] = {"Insidion", "Blade's Edge Mountains"}
        s["npc;drop=18478"] = {"Avatar of the Martyred", "Auchenai Crypts"}
        s["npc;drop=17881"] = {"Aeonus", "The Black Morass"}
        s["spell;created=34546"] = {"Dragonmaw", "CRAFTING"}
        s["npc;sold=25176"] = {"Grikkin Copperspring <Arena Vendor>", "Nagrand"}
        s["npc;sold=17657"] = {"Logistics Officer Ulrike <Honor Hold Quartermaster>", "Hellfire Peninsula"}
        s["spell;created=35580"] = {"Netherstrike Breastplate", "CRAFTING"}
        s["spell;created=35582"] = {"Netherstrike Belt", "CRAFTING"}
        s["npc;drop=184259"] = {"Night Lord", "Karazhan"}
        s["object;contained=184465"] = {"Cache of the Legion", "The Mechanar"}
        s["npc;drop=17942"] = {"Quagmirran", "The Slave Pens"}
        s["quest;reward=9271"] = {"Atiesh, Greatstaff of the Guardian", "Stratholme"}
        s["quest;reward=11033"] = {"Assassin No More", "Deadwind Pass"}
        s["spell;created=35587"] = {"Windhawk Belt", "CRAFTING"}
        s["npc;drop=16816"] = {"Echo of Medivh", "Karazhan"}
        s["npc;drop=16152"] = {"Attumen the Huntsman", "Karazhan"}
        s["spell;created=35584"] = {"Netherstrike Bracers", "CRAFTING"}
        s["spell;created=35585"] = {"Windhawk Hauberk", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationdeDE()
        s["npc;sold=20613"] = {"Arodis Sonnenklinge <Bewahrer der Artefakte der Sha'tari>", "Shattrath"}
        s["npc;drop=18831"] = {"Hochkönig Maulgar <Lord der Oger>", "Gruuls Unterschlupf"}
        s["spell;created=26754"] = {"Zauberfeuerrobe", "CRAFTING"}
        s["npc;sold=12792"] = {"Lady Palanseher <Rüstmeisterin für Rüstungen>", "Alteractal"}
        s["spell;created=26753"] = {"Zauberfeuerhandschuhe", "CRAFTING"}
        s["spell;created=26752"] = {"Zauberfeuergürtel", "CRAFTING"}
        s["npc;drop=16457"] = {"Tugendhafte Maid", "Karazhan"}
        s["npc;drop=15690"] = {"Prinz Malchezaar", "Karazhan"}
        s["quest;reward=11002"] = {"Magtheridons Untergang", "Höllenfeuerhalbinsel"}
        s["npc;drop=15688"] = {"Terestian Siechhuf", "Karazhan"}
        s["npc;drop=17711"] = {"Verdammniswandler", "Schattenmondtal"}
        s["spell;created=31455"] = {"Kapuze des Zauberschlags", "CRAFTING"}
        s["spell;created=35588"] = {"Windfalkenarmschienen", "CRAFTING"}
        s["spell;created=31452"] = {"Hose des Zauberschlags", "CRAFTING"}
        s["npc;drop=15687"] = {"Moroes <Turmwärter>", "Karazhan"}
        s["npc;drop=16807"] = {"Großhexenmeister Nethekurse", "Die Zerschmetterten Hallen"}
        s["spell;created=31454"] = {"Kapuze des weißen Heilers", "CRAFTING"}
        s["spell;created=26761"] = {"Urmondstoffschultern", "CRAFTING"}
        s["spell;created=26762"] = {"Urmondstoffrobe", "CRAFTING"}
        s["npc;sold=21643"] = {"Alurmi <Rüstmeisterin der Hüter der Zeit>", "Tanaris"}
        s["spell;created=26760"] = {"Urmondstoffgürtel", "CRAFTING"}
        s["npc;drop=18728"] = {"Verdammnislord Kazzak", "Höllenfeuerhalbinsel"}
        s["quest;reward=11032"] = {"Nicht mehr Beschützer", "Gebirgspass der Totenwinde"}
        s["npc;drop=18731"] = {"Botschafter Höllenschlund", "Schattenlabyrinth"}
        s["npc;drop=19220"] = {"Pathaleon der Kalkulator", "Die Mechanar"}
        s["npc;drop=17798"] = {"Kriegsherr Kalithresh", "Die Dampfkammer"}
        s["spell;created=31449"] = {"Wickeltuch der Vergeltung", "CRAFTING"}
        s["npc;drop=17977"] = {"Warpzweig", "Die Botanika"}
        s["npc;drop=18096"] = {"Epochenjäger", "Vorgebirge des Alten Hügellands"}
        s["npc;drop=16808"] = {"Kriegshäuptling Kargath Messerfaust", "Die Zerschmetterten Hallen"}
        s["npc;drop=19044"] = {"Gruul der Drachenschlächter", "Gruuls Unterschlupf"}
        s["npc;drop=18371"] = {"Shirrak der Totenwächter", "Auchenaikrypta"}
        s["spell;created=34544"] = {"Mondspaltbeil", "CRAFTING"}
        s["npc;sold=17904"] = {"Fedryen Flinkspeer <Rüstmeister der Expedition des Cenarius>", "Zangarmarschen"}
        s["npc;sold=17585"] = {"Rüstmeister Urgronn <Rüstmeister von Thrallmar>", "Höllenfeuerhalbinsel"}
        s["npc;drop=18168"] = {"Die böse Hexe", "Karazhan"}
        s["npc;drop=15691"] = {"Der Kurator", "Karazhan"}
        s["npc;drop=15689"] = {"Nethergroll", "Karazhan"}
        s["npc;drop=16524"] = {"Arans Schemen", "Karazhan"}
        s["spell;created=26756"] = {"Eisschattenzwirnschultern", "CRAFTING"}
        s["spell;created=26758"] = {"Eisschattenzwirnrobe", "CRAFTING"}
        s["spell;created=31435"] = {"Armschienen der Verwüstung", "CRAFTING"}
        s["spell;created=31443"] = {"Gurt der Zerstörung", "CRAFTING"}
        s["spell;created=26757"] = {"Eisschattenzwirnstiefel", "CRAFTING"}
        s["npc;drop=18667"] = {"Schwarzherz der Hetzer", "Schattenlabyrinth"}
        s["quest;reward=9120"] = {"Der Niedergang Kel'Thuzads", "Östliche Pestländer"}
        s["npc;drop=17521"] = {"Der große böse Wolf", "Karazhan"}
        s["spell;created=42546"] = {"Umhang der Dunkelheit", "CRAFTING"}
        s["npc;drop=16411"] = {"Spektraler Küchenchef", "Karazhan"}
        s["quest;reward=10280"] = {"Sonderlieferung nach Shattrath", "Nethersturm"}
        s["quest;reward=10806"] = {"Finale", "Schergrat"}
        s["npc;drop=17225"] = {"Schrecken der Nacht", "Karazhan"}
        s["spell;created=34540"] = {"Löwenherzchampion", "CRAFTING"}
        s["npc;drop=17381"] = {"Der Schöpfer", "Der Blutkessel"}
        s["npc;drop=18697"] = {"Chefingenieur Lorthander", "Nethersturm"}
        s["npc;drop=16181"] = {"Rokad der Verheerer", "Karazhan"}
        s["npc;drop=18693"] = {"Sprecher Mar'grom", "Schergrat"}
        s["npc;drop=16179"] = {"Hyakiss der Lauerer", "Karazhan"}
        s["npc;drop=16180"] = {"Shadikith der Gleiter", "Karazhan"}
        s["npc;drop=16485"] = {"Arkanwachmann", "Karazhan"}
        s["npc;drop=18478"] = {"Avatar des Gemarterten", "Auchenaikrypta"}
        s["spell;created=34546"] = {"Drachenmal", "CRAFTING"}
        s["npc;sold=25176"] = {"Grikkin Kupferspule <Arenaverkäufer>", "Nagrand"}
        s["npc;sold=17657"] = {"Nachschuboffizier Ulrike <Rüstmeisterin der Ehrenfeste>", "Höllenfeuerhalbinsel"}
        s["spell;created=35580"] = {"Netherstoßbrustplatte", "CRAFTING"}
        s["spell;created=35582"] = {"Netherstoßgürtel", "CRAFTING"}
        s["npc;drop=184259"] = {"Herr der Nacht", "Karazhan"}
        s["object;contained=184465"] = {"Behälter der Legion", "Die Mechanar"}
        s["quest;reward=9271"] = {"Atiesh, Hohestab des Wächters", "Stratholme"}
        s["quest;reward=11033"] = {"Nicht mehr Assassine", "Gebirgspass der Totenwinde"}
        s["spell;created=35587"] = {"Windfalkengürtel", "CRAFTING"}
        s["npc;drop=16816"] = {"Echo Medivhs", "Karazhan"}
        s["npc;drop=16152"] = {"Attumen der Jäger", "Karazhan"}
        s["spell;created=35584"] = {"Netherstoßarmschienen", "CRAFTING"}
        s["spell;created=35585"] = {"Windfalkenhalsberge", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationesES()
        s["npc;sold=20613"] = {"Arodis Filosol <Vigilante de artefactos Sha'tari>", "Ciudad de Shattrath"}
        s["npc;drop=18831"] = {"Su majestad Maulgar <Señor de los ogros>", "Guarida de Gruul"}
        s["spell;created=26754"] = {"Toga fuego de hechizo", "CRAFTING"}
        s["npc;sold=12792"] = {"Lady Palanseer <Intendente de armaduras>", "Cuenca de Arathi"}
        s["spell;created=26753"] = {"Guantes fuego de hechizo", "CRAFTING"}
        s["spell;created=26752"] = {"Cinturón fuego de hechizo", "CRAFTING"}
        s["npc;drop=16457"] = {"Doncella de Virtud", "Karazhan"}
        s["npc;drop=15690"] = {"Príncipe Malchezaar", "Karazhan"}
        s["quest;reward=11002"] = {"La caída de Magtheridon", "Península del Fuego Infernal"}
        s["npc;drop=15688"] = {"Terestian Pezuña Enferma", "Karazhan"}
        s["npc;drop=17711"] = {"Caminante del Destino", "Valle Sombraluna"}
        s["spell;created=31455"] = {"Caperuza de golpe de hechizo", "CRAFTING"}
        s["spell;created=35588"] = {"Brazales de halcón del viento", "CRAFTING"}
        s["spell;created=31452"] = {"Pantalones de golpe de hechizo", "CRAFTING"}
        s["npc;drop=15687"] = {"Moroes <Administrador de la torre>", "Karazhan"}
        s["npc;drop=16807"] = {"Brujo supremo Malbisal", "Las Salas Arrasadas"}
        s["spell;created=31454"] = {"Caperuza con remiendos blancos", "CRAFTING"}
        s["spell;created=26761"] = {"Sobrehombros de tela lunar primigenia", "CRAFTING"}
        s["spell;created=26762"] = {"Toga de tela lunar primigenia", "CRAFTING"}
        s["npc;sold=21643"] = {"Alurmi <Intendente de los Vigilantes del Tiempo>", "Tanaris"}
        s["spell;created=26760"] = {"Cinturón de tela lunar primigenia", "CRAFTING"}
        s["npc;drop=18728"] = {"Señor Apocalíptico Kazzak", "Península del Fuego Infernal"}
        s["quest;reward=11032"] = {"Ya no es protector", "Paso de la Muerte"}
        s["npc;drop=18731"] = {"Embajador Faucinferno", "Laberinto de las Sombras"}
        s["npc;drop=19220"] = {"Pathaleon el Calculador", "El Mechanar"}
        s["npc;drop=17798"] = {"Señor de la Guerra Kalithresh", "La Cámara de Vapor"}
        s["spell;created=31449"] = {"Brazalete de venganza", "CRAFTING"}
        s["npc;drop=17977"] = {"Disidente de distorsión", "El Invernáculo"}
        s["npc;drop=18096"] = {"Cazador de eras", "Antiguas Laderas de Trabalomas"}
        s["npc;drop=16808"] = {"Jefe de Guerra Kargath Garrafilada", "Las Salas Arrasadas"}
        s["npc;drop=19044"] = {"Gruul el Asesino de Dragones", "Guarida de Gruul"}
        s["npc;drop=18371"] = {"Shirrak el Vigía de los Muertos", "Criptas Auchenai"}
        s["spell;created=34544"] = {"Cortaluna", "CRAFTING"}
        s["npc;sold=17904"] = {"Fedryen Lanzapresta <Intendente de la expedición de Cenarion>", "Marisma de Zangar"}
        s["npc;sold=17585"] = {"Intendente Urgronn <Intendente de Thrallmar>", "Península del Fuego Infernal"}
        s["npc;drop=18168"] = {"La Vieja Bruja", "Karazhan"}
        s["npc;drop=15691"] = {"Curator", "Karazhan"}
        s["npc;drop=15689"] = {"Rencor abisal", "Karazhan"}
        s["npc;drop=16524"] = {"Sombra de Aran", "Karazhan"}
        s["spell;created=26756"] = {"Sobrehombros de tejido de sombra congelado", "CRAFTING"}
        s["spell;created=26758"] = {"Túnica de tejido de sombra congelado", "CRAFTING"}
        s["spell;created=31435"] = {"Brazales del caos", "CRAFTING"}
        s["spell;created=31443"] = {"Faja de ruina", "CRAFTING"}
        s["spell;created=26757"] = {"Botas de tejido de sombra congelado", "CRAFTING"}
        s["npc;drop=18667"] = {"Negrozón el Incitador", "Laberinto de las Sombras"}
        s["quest;reward=9120"] = {"La caída de Kel'Thuzad", "Tierras de la Peste del Este"}
        s["npc;drop=17521"] = {"El Lobo Feroz", "Karazhan"}
        s["spell;created=42546"] = {"Capa de oscuridad", "CRAFTING"}
        s["npc;drop=16411"] = {"Chef espectral", "Karazhan"}
        s["quest;reward=10280"] = {"Una entrega especial a la Ciudad de Shattrath", "Tormenta Abisal"}
        s["quest;reward=10806"] = {"Enfrentamiento", "Montañas Filospada"}
        s["npc;drop=17225"] = {"Nocturno", "Karazhan"}
        s["spell;created=34540"] = {"Campeón corazón de león", "CRAFTING"}
        s["npc;drop=17381"] = {"El Hacedor", "El Horno de Sangre"}
        s["npc;drop=18697"] = {"Ingeniero jefe Lorthander", "Tormenta Abisal"}
        s["npc;drop=16181"] = {"Rokad el Devastador", "Karazhan"}
        s["npc;drop=18693"] = {"Portavoz Mar'grom", "Montañas Filospada"}
        s["npc;drop=16179"] = {"Hyakiss el Rondador", "Karazhan"}
        s["npc;drop=16180"] = {"Shadikith el Planeador", "Karazhan"}
        s["npc;drop=16485"] = {"Velador Arcano", "Karazhan"}
        s["npc;drop=18478"] = {"Avatar de los Martirizados", "Criptas Auchenai"}
        s["spell;created=34546"] = {"Faucedraco", "CRAFTING"}
        s["npc;sold=25176"] = {"Grikkin Pococobre <Vendedor de arena>", "Nagrand"}
        s["npc;sold=17657"] = {"Oficial de logística Ulrike <Intendente del Bastión del Honor>", "Península del Fuego Infernal"}
        s["spell;created=35580"] = {"Coraza de golpe abisal", "CRAFTING"}
        s["spell;created=35582"] = {"Cinturón de golpe abisal", "CRAFTING"}
        s["npc;drop=184259"] = {"Dueño de la noche", "Karazhan"}
        s["object;contained=184465"] = {"Alijo de la Legión", "El Mechanar"}
        s["quest;reward=9271"] = {"Atiesh, el gran báculo del guardián", "Stratholme"}
        s["quest;reward=11033"] = {"Ya no es asesino", "Paso de la Muerte"}
        s["spell;created=35587"] = {"Cinturón de halcón del viento", "CRAFTING"}
        s["npc;drop=16816"] = {"Eco de Medivh", "Karazhan"}
        s["npc;drop=16152"] = {"Attumen el Montero", "Karazhan"}
        s["spell;created=35584"] = {"Brazales de golpe abisal", "CRAFTING"}
        s["spell;created=35585"] = {"Camisote de halcón del viento", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationfrFR()
        s["npc;sold=20613"] = {"Arodis Lamesoleil <Gardien des artefacts sha'tari>", "Shattrath"}
        s["npc;drop=18831"] = {"Haut Roi Maulgar <Seigneur des ogres>", "Repaire de Gruul"}
        s["spell;created=26754"] = {"Robe du feu-sorcier", "CRAFTING"}
        s["npc;sold=12792"] = {"Dame Palanseer <Intendant des armures>", "Bassin d'Arathi"}
        s["spell;created=26753"] = {"Gants du feu-sorcier", "CRAFTING"}
        s["spell;created=26752"] = {"Ceinture du feu-sorcier", "CRAFTING"}
        s["npc;drop=16457"] = {"Damoiselle de vertu", "Karazhan"}
        s["quest;reward=11002"] = {"La chute de Magtheridon", "Péninsule des Flammes infernales"}
        s["npc;drop=15688"] = {"Terestian Malsabot", "Karazhan"}
        s["npc;drop=17711"] = {"Marche-funeste", "Vallée d'Ombrelune"}
        s["spell;created=31455"] = {"Chaperon frappe-sort", "CRAFTING"}
        s["spell;created=35588"] = {"Brassards Faucon-du-vent", "CRAFTING"}
        s["spell;created=31452"] = {"Pantalon frappe-sort", "CRAFTING"}
        s["npc;drop=15687"] = {"Moroes <Régisseur de la tour>", "Karazhan"}
        s["npc;drop=16807"] = {"Grand démoniste Néanathème", "Les Salles brisées"}
        s["spell;created=31454"] = {"Chaperon de la blanche guérison", "CRAFTING"}
        s["spell;created=26761"] = {"Epaulières d'étoffe lunaire primordiale", "CRAFTING"}
        s["spell;created=26762"] = {"Robe d'étoffe lunaire primordiale", "CRAFTING"}
        s["npc;sold=21643"] = {"Alurmi <Intendant des gardiens du Temps>", "Tanaris"}
        s["spell;created=26760"] = {"Ceinture d'étoffe lunaire primordiale", "CRAFTING"}
        s["npc;drop=18728"] = {"Seigneur funeste Kazzak", "Péninsule des Flammes infernales"}
        s["quest;reward=11032"] = {"Quitter la voie du protecteur", "Défilé de Deuillevent"}
        s["npc;drop=18731"] = {"Ambassadeur Gueule-d'enfer", "Labyrinthe des ombres"}
        s["npc;drop=19220"] = {"Pathaleon le Calculateur", "Le Méchanar"}
        s["npc;drop=17798"] = {"Seigneur de guerre Kalithresh", "Le Caveau de la vapeur"}
        s["spell;created=31449"] = {"Houppelande vengeresse", "CRAFTING"}
        s["npc;drop=17977"] = {"Brise-dimension", "La Botanica"}
        s["npc;drop=18096"] = {"Chasseur d'époques", "Contreforts de Hautebrande d'antan"}
        s["npc;drop=16808"] = {"Chef de guerre Kargath Lamepoing", "Les Salles brisées"}
        s["npc;drop=19044"] = {"Gruul le Tue-dragon", "Repaire de Gruul"}
        s["npc;drop=18371"] = {"Shirrak le Veillemort", "Cryptes Auchenaï"}
        s["spell;created=34544"] = {"Tranchelune", "CRAFTING"}
        s["npc;sold=17904"] = {"Fedryen Vivelance <Intendant de l'Expédition cénarienne>", "Marécage de Zangar"}
        s["npc;sold=17585"] = {"Intendant Urgronn <Intendant de Thrallmar>", "Péninsule des Flammes infernales"}
        s["npc;drop=18168"] = {"La Mégère", "Karazhan"}
        s["npc;drop=15691"] = {"Le conservateur", "Karazhan"}
        s["npc;drop=15689"] = {"Dédain-du-Néant", "Karazhan"}
        s["npc;drop=16524"] = {"Ombre d'Aran", "Karazhan"}
        s["spell;created=26756"] = {"Epaulières en tisse-ombre gelé", "CRAFTING"}
        s["spell;created=26758"] = {"Robe en tisse-ombre gelé", "CRAFTING"}
        s["spell;created=31435"] = {"Brassards de Sans-quartier", "CRAFTING"}
        s["spell;created=31443"] = {"Ceinturon de saccage", "CRAFTING"}
        s["spell;created=26757"] = {"Bottes en tisse-ombre gelé", "CRAFTING"}
        s["npc;drop=18667"] = {"Coeur-noir le Séditieux", "Labyrinthe des ombres"}
        s["quest;reward=9120"] = {"La chute de Kel'Thuzad", "Maleterres de l'est"}
        s["npc;drop=17521"] = {"Le Grand Méchant Loup", "Karazhan"}
        s["spell;created=42546"] = {"Cape des ténèbres", "CRAFTING"}
        s["npc;drop=16411"] = {"Chef spectral", "Karazhan"}
        s["quest;reward=10280"] = {"Livraison spéciale à Shattrath", "Raz-de-Néant"}
        s["quest;reward=10806"] = {"Cartes sur table", "Les Tranchantes"}
        s["npc;drop=17225"] = {"Plaie-de-nuit", "Karazhan"}
        s["spell;created=34540"] = {"Championne Coeur-de-lion", "CRAFTING"}
        s["npc;drop=17381"] = {"Le Faiseur", "La Fournaise du sang"}
        s["npc;drop=18697"] = {"Ingénieur en chef Lorthander", "Raz-de-Néant"}
        s["npc;drop=16181"] = {"Rodak le ravageur", "Karazhan"}
        s["npc;drop=18693"] = {"Porte-parole Mar'grom", "Les Tranchantes"}
        s["npc;drop=16179"] = {"Hyakiss la Rôdeuse", "Karazhan"}
        s["npc;drop=16180"] = {"Shadikith le glisseur", "Karazhan"}
        s["npc;drop=16485"] = {"Veilleur arcanique", "Karazhan"}
        s["npc;drop=18478"] = {"Avatar des martyrs", "Cryptes Auchenaï"}
        s["spell;created=34546"] = {"Gueule-de-dragon", "CRAFTING"}
        s["npc;sold=25176"] = {"Grikkin Cuivressort <Vendeur de l'arène>", "Nagrand"}
        s["npc;sold=17657"] = {"Officier de logistique Ulrike <Intendante du bastion de l'Honneur>", "Péninsule des Flammes infernales"}
        s["spell;created=35580"] = {"Cuirasse Coup-de-Néant", "CRAFTING"}
        s["spell;created=35582"] = {"Ceinture Coup-de-Néant", "CRAFTING"}
        s["npc;drop=184259"] = {"Seigneur de la Nuit", "Karazhan"}
        s["object;contained=184465"] = {"Cache de la Légion", "Le Méchanar"}
        s["npc;drop=17942"] = {"Bourbierreux", "Les enclos aux esclaves"}
        s["quest;reward=9271"] = {"Atiesh, le grand bâton du Gardien", "Stratholme"}
        s["quest;reward=11033"] = {"Quitter la voie de l'assassin", "Défilé de Deuillevent"}
        s["spell;created=35587"] = {"Ceinture Faucon-du-vent", "CRAFTING"}
        s["npc;drop=16816"] = {"Echo de Medivh", "Karazhan"}
        s["npc;drop=16152"] = {"Attumen le Veneur", "Karazhan"}
        s["spell;created=35584"] = {"Brassards Coup-de-Néant", "CRAFTING"}
        s["spell;created=35585"] = {"Haubert Faucon-du-vent", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationitIT()
        s["npc;sold=20613"] = {"Arodis Sunblade <Keeper of Sha'tari Artifacts>", "Shattrath City"}
        s["npc;drop=18831"] = {"High King Maulgar <Lord of the Ogres>", "Gruul's Lair"}
        s["npc;sold=12792"] = {"Lady Palanseer <Armor Quartermaster>", "Alterac Valley"}
        s["quest;reward=11002"] = {"The Fall of Magtheridon", "Hellfire Peninsula"}
        s["npc;drop=15687"] = {"Moroes <Tower Steward>", "Karazhan"}
        s["npc;sold=21643"] = {"Alurmi <Keepers of Time Quartermaster>", "Tanaris"}
        s["quest;reward=11032"] = {"Protector No More", "Deadwind Pass"}
        s["npc;sold=17904"] = {"Fedryen Swiftspear <Cenarion Expedition Quartermaster>", "Zangarmarsh"}
        s["npc;sold=17585"] = {"Quartermaster Urgronn <Thrallmar Quartermaster>", "Hellfire Peninsula"}
        s["quest;reward=9120"] = {"The Fall of Kel'Thuzad", "Eastern Plaguelands"}
        s["quest;reward=10280"] = {"Special Delivery to Shattrath City", "Netherstorm"}
        s["quest;reward=10806"] = {"Showdown", "Blade's Edge Mountains"}
        s["npc;sold=25176"] = {"Grikkin Copperspring <Arena Vendor>", "Nagrand"}
        s["npc;sold=17657"] = {"Logistics Officer Ulrike <Honor Hold Quartermaster>", "Hellfire Peninsula"}
        s["quest;reward=9271"] = {"Atiesh, Greatstaff of the Guardian", "Stratholme"}
        s["quest;reward=11033"] = {"Assassin No More", "Deadwind Pass"}
    end

    function SpecBisTooltip:TranslationkoKR()
        s["npc;sold=20613"] = {"아로디스 선블레이드 <샤타리 유물의 수호자>", "샤트라스"}
        s["npc;drop=18831"] = {"왕중왕 마울가르 <오우거 군주>", "그룰의 둥지"}
        s["spell;created=26754"] = {"마법불꽃 로브", "CRAFTING"}
        s["npc;sold=12792"] = {"여군주 팔란시어 <방어구 병참장교>", "아라시 분지"}
        s["spell;created=26753"] = {"마법불꽃 장갑", "CRAFTING"}
        s["spell;created=26752"] = {"마법불꽃 허리띠", "CRAFTING"}
        s["npc;drop=16457"] = {"고결의 여신", "카라잔"}
        s["npc;drop=15690"] = {"공작 말체자르", "카라잔"}
        s["quest;reward=11002"] = {"마그테리돈의 죽음", "지옥불 반도"}
        s["npc;drop=15688"] = {"테레스티안 일후프", "카라잔"}
        s["npc;drop=17711"] = {"파멸의 절단기", "어둠달 골짜기"}
        s["npc;sold=18525"] = {"게라스", "샤트라스"}
        s["npc;drop=17257"] = {"마그테리돈", "마그테리돈의 둥지"}
        s["spell;created=31455"] = {"마법 강타의 두건", "CRAFTING"}
        s["spell;created=35588"] = {"바람매 팔보호구", "CRAFTING"}
        s["spell;created=31452"] = {"마법 강타의 바지", "CRAFTING"}
        s["npc;drop=15687"] = {"모로스 <집사>", "카라잔"}
        s["npc;drop=16807"] = {"대흑마법사 네더쿠르스", "으스러진 손의 전당"}
        s["spell;created=31454"] = {"백마법 두건", "CRAFTING"}
        s["spell;created=26761"] = {"태초의 달빛매듭 어깨보호대", "CRAFTING"}
        s["spell;created=26762"] = {"태초의 달빛매듭 로브", "CRAFTING"}
        s["npc;sold=21643"] = {"알룰미 <시간의 수호자 병참장교>", "타나리스"}
        s["spell;created=26760"] = {"태초의 달빛매듭 허리띠", "CRAFTING"}
        s["npc;drop=18728"] = {"파멸의 군주 카자크", "지옥불 반도"}
        s["quest;reward=11032"] = {"위대한 수호자의 길 포기", "죽음의 고개"}
        s["npc;drop=18731"] = {"사자 지옥아귀", "어둠의 미궁"}
        s["npc;drop=19220"] = {"철두철미한 파탈리온", "메카나르"}
        s["npc;drop=17798"] = {"장군 칼리스레쉬", "증기 저장고"}
        s["spell;created=31449"] = {"복수의 외투", "CRAFTING"}
        s["npc;drop=17977"] = {"차원의 분리자", "신록의 정원"}
        s["npc;drop=18096"] = {"시대의 사냥꾼", "옛 힐스브래드 구릉지"}
        s["npc;drop=16808"] = {"대족장 카르가스 블레이드피스트", "으스러진 손의 전당"}
        s["npc;drop=19044"] = {"용 학살자 그룰", "그룰의 둥지"}
        s["npc;drop=18371"] = {"죽음의 감시인 쉴라크", "아키나이 납골당"}
        s["npc;drop=17534"] = {"줄리엔", "카라잔"}
        s["spell;created=34544"] = {"달빛 클레버", "CRAFTING"}
        s["npc;sold=17904"] = {"페드리엔 스위프트스피어 <세나리온 원정대 병참장교>", "장가르 습지대"}
        s["npc;sold=17585"] = {"병참장교 울그론 <스랄마 병참장교>", "지옥불 반도"}
        s["npc;drop=18168"] = {"마녀", "카라잔"}
        s["npc;drop=15691"] = {"전시 관리인", "카라잔"}
        s["npc;drop=15689"] = {"황천의 원령", "카라잔"}
        s["npc;drop=16524"] = {"아란의 망령", "카라잔"}
        s["spell;created=26756"] = {"얼어붙은 그림자매듭 어깨보호구", "CRAFTING"}
        s["spell;created=26758"] = {"얼어붙은 그림자매듭 로브", "CRAFTING"}
        s["spell;created=31435"] = {"대혼란의 팔보호구", "CRAFTING"}
        s["spell;created=31443"] = {"몰락의 벨트", "CRAFTING"}
        s["spell;created=26757"] = {"얼어붙은 그림자매듭 장화", "CRAFTING"}
        s["npc;drop=18667"] = {"선동자 검은심장", "어둠의 미궁"}
        s["quest;reward=9120"] = {"켈투자드의 죽음", "동부 역병지대"}
        s["npc;drop=17521"] = {"커다란 나쁜 늑대", "카라잔"}
        s["spell;created=42546"] = {"암흑의 망토", "CRAFTING"}
        s["npc;drop=16411"] = {"유령 주방장", "카라잔"}
        s["quest;reward=10280"] = {"샤트라스로 특별 배달", "황천의 폭풍"}
        s["quest;reward=10806"] = {"최후의 대결", "칼날 산맥"}
        s["npc;drop=17225"] = {"파멸의 어둠", "카라잔"}
        s["spell;created=34540"] = {"용사의 사자심장 검", "CRAFTING"}
        s["npc;drop=17381"] = {"재앙의 창조자", "피의 용광로"}
        s["npc;drop=18697"] = {"선임기술자 노산더", "황천의 폭풍"}
        s["npc;drop=16181"] = {"파괴자 로카드", "카라잔"}
        s["npc;drop=18693"] = {"연설가 마르그롬", "칼날 산맥"}
        s["npc;drop=16179"] = {"잠복꾼 히아키스", "카라잔"}
        s["npc;drop=16180"] = {"활강의 샤디키스", "카라잔"}
        s["npc;drop=16485"] = {"비전 보초", "카라잔"}
        s["npc;drop=23281"] = {"인시디온", "칼날 산맥"}
        s["npc;drop=18478"] = {"순교자의 화신", "아키나이 납골당"}
        s["npc;drop=17881"] = {"아에누스", "검은늪"}
        s["spell;created=34546"] = {"용아귀", "CRAFTING"}
        s["npc;sold=25176"] = {"그리킨 코퍼스프링 <투기장 상인>", "나그란드"}
        s["npc;sold=17657"] = {"병참장교 울리케 <명예의 요새 병참장교>", "지옥불 반도"}
        s["spell;created=35580"] = {"황천쐐기 흉갑", "CRAFTING"}
        s["spell;created=35582"] = {"황천쐐기 허리띠", "CRAFTING"}
        s["npc;drop=184259"] = {"밤의 군주", "카라잔"}
        s["object;contained=184465"] = {"군단 저장고", "메카나르"}
        s["npc;drop=17942"] = {"쿠아그미란", "강제 노역소"}
        s["quest;reward=9271"] = {"아티쉬, 수호자의 지팡이", "스트라솔름"}
        s["quest;reward=11033"] = {"일급 암살자의 길 포기", "죽음의 고개"}
        s["spell;created=35587"] = {"바람매 허리띠", "CRAFTING"}
        s["npc;drop=16816"] = {"메디브의 메아리", "카라잔"}
        s["npc;drop=16152"] = {"사냥꾼 어튜멘", "카라잔"}
        s["spell;created=35584"] = {"황천쐐기 팔보호구", "CRAFTING"}
        s["spell;created=35585"] = {"바람매 갑옷", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationptBR()
        s["npc;sold=20613"] = {"Arodis Gumélion <Guardião das Relíquias Sha'tari>", "Shattrath"}
        s["npc;drop=18831"] = {"Alto-rei Maulgar <Senhor dos Ogros>", "Covil de Gruul"}
        s["spell;created=26754"] = {"Veste de Fogo Místico", "CRAFTING"}
        s["npc;sold=12792"] = {"Lady Palanseer <Intendente de Armaduras>", "Bacia Arathi"}
        s["spell;created=26753"] = {"Luvas de Fogo Místico", "CRAFTING"}
        s["spell;created=26752"] = {"Cinto de Fogo Místico", "CRAFTING"}
        s["npc;drop=16457"] = {"Donzela da Virtude", "Karazhan"}
        s["npc;drop=15690"] = {"Príncipe Malquezaar", "Karazhan"}
        s["quest;reward=11002"] = {"A queda de Magtheridon", "Península Fogo do Inferno"}
        s["npc;drop=15688"] = {"Terestian Cascopodre", "Karazhan"}
        s["npc;drop=17711"] = {"Armagedom", "Vale da Lua Negra"}
        s["spell;created=31455"] = {"Capuz do Golpe Mágico", "CRAFTING"}
        s["spell;created=35588"] = {"Braçadeiras do Falcão do Vento", "CRAFTING"}
        s["spell;created=31452"] = {"Calças do Golpe Mágico", "CRAFTING"}
        s["npc;drop=15687"] = {"Moroes <Castelão da Torre>", "Karazhan"}
        s["npc;drop=16807"] = {"Grão-bruxo Eterrívio", "Salões Despedaçados"}
        s["spell;created=31454"] = {"Capuz Remendalvo", "CRAFTING"}
        s["spell;created=26761"] = {"Omoplatas de Lunatrama Primeva", "CRAFTING"}
        s["spell;created=26762"] = {"Veste de Lunatrama Primeva", "CRAFTING"}
        s["npc;sold=21643"] = {"Alurmi <Intendente dos Defensores do Tempo>", "Tanaris"}
        s["spell;created=26760"] = {"Cinto de Lunatrama Primeva", "CRAFTING"}
        s["npc;drop=18728"] = {"Senhor da Perdição Kazzak", "Península Fogo do Inferno"}
        s["quest;reward=11032"] = {"Protetor, não mais", "Trilha do Vento Morto"}
        s["npc;drop=18731"] = {"Embaixador Gorjavernus", "Labirinto Soturno"}
        s["npc;drop=19220"] = {"Pathaleon, o Calculista", "Mecanar"}
        s["npc;drop=17798"] = {"Senhor da Guerra Kalithresh", "Câmara dos Vapores"}
        s["spell;created=31449"] = {"Mantelete da Vingança", "CRAFTING"}
        s["npc;drop=17977"] = {"Estilhaço Dimensional", "Jardim Botânico"}
        s["npc;drop=18096"] = {"Caçador das Eras", "Antigo Contraforte de Eira dos Montes"}
        s["npc;drop=16808"] = {"Chefe Guerreiro Karrath Carpunhal", "Salões Despedaçados"}
        s["npc;drop=19044"] = {"Gruul, o Matador de Dragões", "Covil de Gruul"}
        s["npc;drop=18371"] = {"Shirrak, o Vigia dos Mortos", "Catacumbas Auchenai"}
        s["spell;created=34544"] = {"Fendelua", "CRAFTING"}
        s["npc;sold=17904"] = {"Fedryen Lancélere <Intendente da Expedição Cenariana>", "Pântano Zíngaro"}
        s["npc;sold=17585"] = {"Intendente Urgronn <Intendente de Thrallmar>", "Península Fogo do Inferno"}
        s["npc;drop=18168"] = {"Bruxa Má", "Karazhan"}
        s["npc;drop=15691"] = {"O Curador", "Karazhan"}
        s["npc;drop=15689"] = {"Eteródio", "Karazhan"}
        s["npc;drop=16524"] = {"Vulto de Aran", "Karazhan"}
        s["spell;created=26756"] = {"Omoplatas de Umbratrama Congeladas", "CRAFTING"}
        s["spell;created=26758"] = {"Veste de Umbratrama Congelada", "CRAFTING"}
        s["spell;created=31435"] = {"Braçadeiras da Tormenta", "CRAFTING"}
        s["spell;created=31443"] = {"Cinturão da Ruína", "CRAFTING"}
        s["spell;created=26757"] = {"Botas de Umbratrama Congeladas", "CRAFTING"}
        s["npc;drop=18667"] = {"Nerocordius, o Incitador", "Labirinto Soturno"}
        s["quest;reward=9120"] = {"A queda de Kel'Thuzad", "Terras Pestilentas Orientais"}
        s["npc;drop=17521"] = {"Lobo Mau", "Karazhan"}
        s["spell;created=42546"] = {"Manto de Trevas", "CRAFTING"}
        s["npc;drop=16411"] = {"Cozinheiro Espectral", "Karazhan"}
        s["quest;reward=10280"] = {"Entrega especial para Shattrath", "Eternévoa"}
        s["quest;reward=10806"] = {"Confronto final", "Montanhas da Lâmina Afiada"}
        s["npc;drop=17225"] = {"Nocturno", "Karazhan"}
        s["spell;created=34540"] = {"Campeão Coração de Leão", "CRAFTING"}
        s["npc;drop=17381"] = {"O Criador", "Fornalha de Sangue"}
        s["npc;drop=18697"] = {"Engenheiro-chefe Lorthander", "Eternévoa"}
        s["npc;drop=16181"] = {"Rokad, o Assolador", "Karazhan"}
        s["npc;drop=18693"] = {"Orador Mar'grom", "Montanhas da Lâmina Afiada"}
        s["npc;drop=16179"] = {"Hyakiss, a Tocaieira", "Karazhan"}
        s["npc;drop=16180"] = {"Shadikith, o Planador", "Karazhan"}
        s["npc;drop=16485"] = {"Vigia Arcano", "Karazhan"}
        s["npc;drop=18478"] = {"Avatar do Mártir", "Catacumbas Auchenai"}
        s["spell;created=34546"] = {"Presa do Dragão", "CRAFTING"}
        s["npc;sold=25176"] = {"Grikkin Molacobre <Comerciante da Arena>", "Nagrand"}
        s["npc;sold=17657"] = {"Oficial de Logística Ulrike <Intendente da Fortaleza da Honra>", "Península Fogo do Inferno"}
        s["spell;created=35580"] = {"Peitoral do Golpe Etéreo", "CRAFTING"}
        s["spell;created=35582"] = {"Cinto do Golpe Etéreo", "CRAFTING"}
        s["npc;drop=184259"] = {"[Night Lord]", "Karazhan"}
        s["object;contained=184465"] = {"Baú da Legião", "Mecanar"}
        s["npc;drop=17942"] = {"Atolaço", "Pátio dos Escravos"}
        s["quest;reward=9271"] = {"Atiesh, Grande Cajado do Guardião", "Stratholme"}
        s["quest;reward=11033"] = {"Assassino, não mais", "Trilha do Vento Morto"}
        s["spell;created=35587"] = {"Cinto do Falcão do Vento", "CRAFTING"}
        s["npc;drop=16816"] = {"Eco de Medivh", "Karazhan"}
        s["npc;drop=16152"] = {"Attumen, o Caçador", "Karazhan"}
        s["spell;created=35584"] = {"Braçadeiras do Golpe Etéreo", "CRAFTING"}
        s["spell;created=35585"] = {"Cota do Falcão do Vento", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationruRU()
        s["npc;sold=20613"] = {"Ародис Солнечный Клинок <Хранитель артефактов Ша'тар>", "Шаттрат"}
        s["npc;drop=18831"] = {"Король Молгар <Повелитель огров>", "Логово Груула"}
        s["spell;created=26754"] = {"Одеяние из огненной чароткани", "CRAFTING"}
        s["npc;sold=12792"] = {"Леди Палансир <Начальник снабжения доспехами>", "Альтеракская долина"}
        s["spell;created=26753"] = {"Перчатки из огненной чароткани", "CRAFTING"}
        s["spell;created=26752"] = {"Пояс из огненной чароткани", "CRAFTING"}
        s["npc;drop=16457"] = {"Благочестивая дева", "Каражан"}
        s["npc;drop=15690"] = {"Принц Малчезар", "Каражан"}
        s["quest;reward=11002"] = {"Падение Магтеридона", "Полуостров Адского Пламени"}
        s["npc;drop=15688"] = {"Терестиан Больное Копыто", "Каражан"}
        s["npc;drop=17711"] = {"Судьболом", "Долина Призрачной Луны"}
        s["npc;sold=18525"] = {"Г'ирас", "Шаттрат"}
        s["npc;drop=17257"] = {"Магтеридон", "Логово Магтеридона"}
        s["spell;created=31455"] = {"Капюшон сокрушительной магии", "CRAFTING"}
        s["spell;created=35588"] = {"Наручи легкокрылого ястреба", "CRAFTING"}
        s["spell;created=31452"] = {"Штаны сокрушительной магии", "CRAFTING"}
        s["npc;drop=15687"] = {"Мороуз <Дворецкий>", "Каражан"}
        s["npc;drop=16807"] = {"Главный чернокнижник Пустоклят", "Разрушенные залы"}
        s["spell;created=31454"] = {"Капюшон белого целителя", "CRAFTING"}
        s["spell;created=26761"] = {"Наплечники из изначальной луноткани", "CRAFTING"}
        s["spell;created=26762"] = {"Одеяние из изначальной луноткани", "CRAFTING"}
        s["npc;sold=21643"] = {"Алурми <Начальник снабжения Хранителей Времени>", "Танарис"}
        s["spell;created=26760"] = {"Пояс из изначальной луноткани", "CRAFTING"}
        s["npc;drop=18728"] = {"Владыка судеб Каззак", "Полуостров Адского Пламени"}
        s["quest;reward=11032"] = {"Перестать быть защитником из Аметистового Ока", "Перевал Мертвого Ветра"}
        s["npc;drop=18731"] = {"Посол Гиблочрев", "Темный лабиринт"}
        s["npc;drop=19220"] = {"Паталеон Вычислитель", "Механар"}
        s["npc;drop=17798"] = {"Полководец Калитреш", "Паровое подземелье"}
        s["spell;created=31449"] = {"Плащ отмщения", "CRAFTING"}
        s["npc;drop=17977"] = {"Узлодревень", "Ботаника"}
        s["npc;drop=18096"] = {"Охотник Вечности", "Старые предгорья Хилсбрада"}
        s["npc;drop=16808"] = {"Вождь Каргат Острорук", "Разрушенные залы"}
        s["npc;drop=19044"] = {"Груул Драконобой", "Логово Груула"}
        s["npc;drop=18371"] = {"Ширрак Страж Мертвых", "Аукенайские гробницы"}
        s["npc;drop=17534"] = {"Джулианна", "Каражан"}
        s["spell;created=34544"] = {"Лунный колун", "CRAFTING"}
        s["npc;sold=17904"] = {"Федриен Быстрое Копье <Начальник снабжения Кенарийской экспедиции>", "Зангартопь"}
        s["npc;sold=17585"] = {"Интендант Ургронн <Начальник снабжения Траллмара>", "Полуостров Адского Пламени"}
        s["npc;drop=18168"] = {"Ведьма", "Каражан"}
        s["npc;drop=15691"] = {"Смотритель", "Каражан"}
        s["npc;drop=15689"] = {"Гнев Пустоты", "Каражан"}
        s["npc;drop=16524"] = {"Тень Арана", "Каражан"}
        s["spell;created=26756"] = {"Наплечники из застывшей тенеткани", "CRAFTING"}
        s["spell;created=26758"] = {"Одеяние из застывшей тенеткани", "CRAFTING"}
        s["spell;created=31435"] = {"Наручи Разора", "CRAFTING"}
        s["spell;created=31443"] = {"Ремень опустошения", "CRAFTING"}
        s["spell;created=26757"] = {"Сапоги из застывшей тенеткани", "CRAFTING"}
        s["npc;drop=18667"] = {"Черносерд Подстрекатель", "Темный лабиринт"}
        s["quest;reward=9120"] = {"Падение Кел'Тузада", "Восточные Чумные земли"}
        s["npc;drop=17521"] = {"Злой и страшный серый волк", "Каражан"}
        s["spell;created=42546"] = {"Плащ Тьмы", "CRAFTING"}
        s["npc;drop=16411"] = {"Призрачный шеф-повар", "Каражан"}
        s["quest;reward=10280"] = {"Специальный груз в город Шаттрат", "Пустоверть"}
        s["quest;reward=10806"] = {"Перед выстрелом", "Острогорье"}
        s["npc;drop=17225"] = {"Ночная Погибель", "Каражан"}
        s["spell;created=34540"] = {"Защитник львиного сердца", "CRAFTING"}
        s["npc;drop=17381"] = {"Мастер", "Кузня Крови"}
        s["npc;drop=18697"] = {"Главный инженер Лортандер", "Пустоверть"}
        s["npc;drop=16181"] = {"Рокад Опустошитель", "Каражан"}
        s["npc;drop=18693"] = {"Проповедник Маргром", "Острогорье"}
        s["npc;drop=16179"] = {"Хиакисс Скрытень", "Каражан"}
        s["npc;drop=16180"] = {"Шадикит Скользящий", "Каражан"}
        s["npc;drop=16485"] = {"Волшебный смотритель", "Каражан"}
        s["npc;drop=23281"] = {"Инсидион", "Острогорье"}
        s["npc;drop=18478"] = {"Аватара Мученика", "Аукенайские гробницы"}
        s["npc;drop=17881"] = {"Эонус", "Черные топи"}
        s["spell;created=34546"] = {"Драконья Пасть", "CRAFTING"}
        s["npc;sold=25176"] = {"Гриккин Медипрыг <Продавец экипировки арены>", "Награнд"}
        s["npc;sold=17657"] = {"Офицер-логистик Ульрика <Интендантка Оплота Чести>", "Полуостров Адского Пламени"}
        s["spell;created=35580"] = {"Кираса удара Пустоты", "CRAFTING"}
        s["spell;created=35582"] = {"Пояс удара Пустоты", "CRAFTING"}
        s["npc;drop=184259"] = {"Владыка ночи", "Каражан"}
        s["object;contained=184465"] = {"Тайник Легиона", "Механар"}
        s["npc;drop=17942"] = {"Зыбун", "Узилище"}
        s["quest;reward=9271"] = {"Атиеш, большой посох Стража", "Стратхольм"}
        s["quest;reward=11033"] = {"Перестать быть убийцей из Аметистового Ока", "Перевал Мертвого Ветра"}
        s["spell;created=35587"] = {"Пояс легкокрылого ястреба", "CRAFTING"}
        s["npc;drop=16816"] = {"Эхо Медива", "Каражан"}
        s["npc;drop=16152"] = {"Ловчий Аттумен", "Каражан"}
        s["spell;created=35584"] = {"Наручи удара Пустоты", "CRAFTING"}
        s["spell;created=35585"] = {"Хауберк легкокрылого ястреба", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationzhCN()
        s["npc;sold=20613"] = {"阿罗迪斯·炎刃 <沙塔尔神器管理者>", "沙塔斯城"}
        s["npc;drop=18831"] = {"莫加尔大王 <食人魔之王>", "格鲁尔的巢穴"}
        s["spell;created=26754"] = {"魔焰长袍", "CRAFTING"}
        s["npc;sold=12792"] = {"帕兰蒂尔 <护甲军需官>", "奥特兰克山谷"}
        s["spell;created=26753"] = {"魔焰手套", "CRAFTING"}
        s["spell;created=26752"] = {"魔焰腰带", "CRAFTING"}
        s["npc;drop=16457"] = {"贞节圣女", "卡拉赞"}
        s["npc;drop=15690"] = {"玛克扎尔王子", "卡拉赞"}
        s["quest;reward=11002"] = {"玛瑟里顿之死", "地狱火半岛"}
        s["npc;drop=15688"] = {"特雷斯坦·邪蹄", "卡拉赞"}
        s["npc;drop=17711"] = {"末日行者", "影月谷"}
        s["npc;sold=18525"] = {"基厄拉斯", "沙塔斯城"}
        s["npc;drop=17257"] = {"玛瑟里顿", "玛瑟里顿的巢穴"}
        s["spell;created=31455"] = {"法术打击兜帽", "CRAFTING"}
        s["spell;created=35588"] = {"风鹰护腕", "CRAFTING"}
        s["spell;created=31452"] = {"法术打击短裤", "CRAFTING"}
        s["npc;drop=15687"] = {"莫罗斯 <管家>", "卡拉赞"}
        s["npc;drop=16807"] = {"高阶术士奈瑟库斯", "破碎大厅"}
        s["spell;created=31454"] = {"白色治愈兜帽", "CRAFTING"}
        s["spell;created=26761"] = {"原始月布护肩", "CRAFTING"}
        s["spell;created=26762"] = {"原始月布长袍", "CRAFTING"}
        s["npc;sold=21643"] = {"艾鲁尔米 <时光守护者军需官>", "塔纳利斯"}
        s["spell;created=26760"] = {"原始月布腰带", "CRAFTING"}
        s["npc;drop=18728"] = {"末日领主卡扎克", "地狱火半岛"}
        s["quest;reward=11032"] = {"远离保卫者之路", "逆风小径"}
        s["npc;drop=18731"] = {"赫尔默大使", "暗影迷宫"}
        s["npc;drop=19220"] = {"计算者帕萨雷恩", "能源舰"}
        s["npc;drop=17798"] = {"督军卡利瑟里斯", "蒸汽地窟"}
        s["spell;created=31449"] = {"复仇披风", "CRAFTING"}
        s["npc;drop=17977"] = {"迁跃扭木", "生态船"}
        s["npc;drop=18096"] = {"时空猎手", "旧希尔斯布莱德丘陵"}
        s["npc;drop=16808"] = {"酋长卡加斯·刃拳", "破碎大厅"}
        s["npc;drop=19044"] = {"屠龙者格鲁尔", "格鲁尔的巢穴"}
        s["npc;drop=18371"] = {"死亡观察者希尔拉克", "奥金尼地穴"}
        s["npc;drop=17534"] = {"朱丽叶", "卡拉赞"}
        s["spell;created=34544"] = {"月牙屠斧", "CRAFTING"}
        s["npc;sold=17904"] = {"芬德雷·迅矛 <塞纳里奥远征队军需官>", "赞加沼泽"}
        s["npc;sold=17585"] = {"军需官乌尔格隆 <萨尔玛军需官>", "地狱火半岛"}
        s["npc;drop=18168"] = {"巫婆", "卡拉赞"}
        s["npc;drop=15691"] = {"馆长", "卡拉赞"}
        s["npc;drop=15689"] = {"虚空幽龙", "卡拉赞"}
        s["npc;drop=16524"] = {"埃兰之影", "卡拉赞"}
        s["spell;created=26756"] = {"冰霜暗纹护肩", "CRAFTING"}
        s["spell;created=26758"] = {"冰霜暗纹外衣", "CRAFTING"}
        s["spell;created=31435"] = {"浩劫护腕", "CRAFTING"}
        s["spell;created=31443"] = {"毁灭束带", "CRAFTING"}
        s["spell;created=26757"] = {"冰霜暗纹长靴", "CRAFTING"}
        s["npc;drop=18667"] = {"煽动者布莱卡特", "暗影迷宫"}
        s["quest;reward=9120"] = {"克尔苏加德的末日", "东瘟疫之地"}
        s["npc;drop=17521"] = {"大灰狼", "卡拉赞"}
        s["spell;created=42546"] = {"黑暗披风", "CRAFTING"}
        s["npc;drop=16411"] = {"鬼灵厨师", "卡拉赞"}
        s["quest;reward=10280"] = {"送往沙塔斯的特殊货物", "虚空风暴"}
        s["quest;reward=10806"] = {"摊牌", "刀锋山"}
        s["npc;drop=17225"] = {"夜之魇", "卡拉赞"}
        s["spell;created=34540"] = {"狮心圣剑", "CRAFTING"}
        s["npc;drop=17381"] = {"制造者", "鲜血熔炉"}
        s["npc;drop=18697"] = {"主工程师洛杉德尔", "虚空风暴"}
        s["npc;drop=16181"] = {"蹂躏者洛卡德", "卡拉赞"}
        s["npc;drop=18693"] = {"演讲者玛尔高姆", "刀锋山"}
        s["npc;drop=16179"] = {"潜伏者希亚其斯", "卡拉赞"}
        s["npc;drop=16180"] = {"滑翔者沙德基斯", "卡拉赞"}
        s["npc;drop=16485"] = {"奥术看守", "卡拉赞"}
        s["npc;drop=23281"] = {"因斯迪安", "刀锋山"}
        s["npc;drop=18478"] = {"殉难者的化身", "奥金尼地穴"}
        s["npc;drop=17881"] = {"埃欧努斯", "黑色沼泽"}
        s["spell;created=34546"] = {"巨龙之喉", "CRAFTING"}
        s["npc;sold=25176"] = {"格里金·考伯斯宾 <竞技场商人>", "纳格兰"}
        s["npc;sold=17657"] = {"后勤军需官乌瑞卡 <荣耀堡军需官>", "地狱火半岛"}
        s["spell;created=35580"] = {"虚空打击胸甲", "CRAFTING"}
        s["spell;created=35582"] = {"虚空打击腰带", "CRAFTING"}
        s["npc;drop=184259"] = {"夜之领主", "卡拉赞"}
        s["object;contained=184465"] = {"军团宝箱", "能源舰"}
        s["npc;drop=17942"] = {"夸格米拉", "奴隶围栏"}
        s["quest;reward=9271"] = {"埃提耶什，守护者的传说之杖", "斯坦索姆"}
        s["quest;reward=11033"] = {"远离刺客之路", "逆风小径"}
        s["spell;created=35587"] = {"风鹰腰带", "CRAFTING"}
        s["npc;drop=16816"] = {"麦迪文的回音", "卡拉赞"}
        s["npc;drop=16152"] = {"猎手阿图门", "卡拉赞"}
        s["spell;created=35584"] = {"虚空打击护腕", "CRAFTING"}
        s["spell;created=35585"] = {"风鹰胸甲", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationzhTW()
        s["npc;sold=20613"] = {"阿罗迪斯·炎刃 <沙塔尔神器管理者>", "沙塔斯城"}
        s["npc;drop=18831"] = {"莫加尔大王 <食人魔之王>", "格鲁尔的巢穴"}
        s["spell;created=26754"] = {"魔焰长袍", "CRAFTING"}
        s["npc;sold=12792"] = {"帕兰蒂尔 <护甲军需官>", "奥特兰克山谷"}
        s["spell;created=26753"] = {"魔焰手套", "CRAFTING"}
        s["spell;created=26752"] = {"魔焰腰带", "CRAFTING"}
        s["npc;drop=16457"] = {"贞节圣女", "卡拉赞"}
        s["npc;drop=15690"] = {"玛克扎尔王子", "卡拉赞"}
        s["quest;reward=11002"] = {"玛瑟里顿之死", "地狱火半岛"}
        s["npc;drop=15688"] = {"特雷斯坦·邪蹄", "卡拉赞"}
        s["npc;drop=17711"] = {"末日行者", "影月谷"}
        s["npc;sold=18525"] = {"基厄拉斯", "沙塔斯城"}
        s["npc;drop=17257"] = {"玛瑟里顿", "玛瑟里顿的巢穴"}
        s["spell;created=31455"] = {"法术打击兜帽", "CRAFTING"}
        s["spell;created=35588"] = {"风鹰护腕", "CRAFTING"}
        s["spell;created=31452"] = {"法术打击短裤", "CRAFTING"}
        s["npc;drop=15687"] = {"莫罗斯 <管家>", "卡拉赞"}
        s["npc;drop=16807"] = {"高阶术士奈瑟库斯", "破碎大厅"}
        s["spell;created=31454"] = {"白色治愈兜帽", "CRAFTING"}
        s["spell;created=26761"] = {"原始月布护肩", "CRAFTING"}
        s["spell;created=26762"] = {"原始月布长袍", "CRAFTING"}
        s["npc;sold=21643"] = {"艾鲁尔米 <时光守护者军需官>", "塔纳利斯"}
        s["spell;created=26760"] = {"原始月布腰带", "CRAFTING"}
        s["npc;drop=18728"] = {"末日领主卡扎克", "地狱火半岛"}
        s["quest;reward=11032"] = {"远离保卫者之路", "逆风小径"}
        s["npc;drop=18731"] = {"赫尔默大使", "暗影迷宫"}
        s["npc;drop=19220"] = {"计算者帕萨雷恩", "能源舰"}
        s["npc;drop=17798"] = {"督军卡利瑟里斯", "蒸汽地窟"}
        s["spell;created=31449"] = {"复仇披风", "CRAFTING"}
        s["npc;drop=17977"] = {"迁跃扭木", "生态船"}
        s["npc;drop=18096"] = {"时空猎手", "旧希尔斯布莱德丘陵"}
        s["npc;drop=16808"] = {"酋长卡加斯·刃拳", "破碎大厅"}
        s["npc;drop=19044"] = {"屠龙者格鲁尔", "格鲁尔的巢穴"}
        s["npc;drop=18371"] = {"死亡观察者希尔拉克", "奥金尼地穴"}
        s["npc;drop=17534"] = {"朱丽叶", "卡拉赞"}
        s["spell;created=34544"] = {"月牙屠斧", "CRAFTING"}
        s["npc;sold=17904"] = {"芬德雷·迅矛 <塞纳里奥远征队军需官>", "赞加沼泽"}
        s["npc;sold=17585"] = {"军需官乌尔格隆 <萨尔玛军需官>", "地狱火半岛"}
        s["npc;drop=18168"] = {"巫婆", "卡拉赞"}
        s["npc;drop=15691"] = {"馆长", "卡拉赞"}
        s["npc;drop=15689"] = {"虚空幽龙", "卡拉赞"}
        s["npc;drop=16524"] = {"埃兰之影", "卡拉赞"}
        s["spell;created=26756"] = {"冰霜暗纹护肩", "CRAFTING"}
        s["spell;created=26758"] = {"冰霜暗纹外衣", "CRAFTING"}
        s["spell;created=31435"] = {"浩劫护腕", "CRAFTING"}
        s["spell;created=31443"] = {"毁灭束带", "CRAFTING"}
        s["spell;created=26757"] = {"冰霜暗纹长靴", "CRAFTING"}
        s["npc;drop=18667"] = {"煽动者布莱卡特", "暗影迷宫"}
        s["quest;reward=9120"] = {"克尔苏加德的末日", "东瘟疫之地"}
        s["npc;drop=17521"] = {"大灰狼", "卡拉赞"}
        s["spell;created=42546"] = {"黑暗披风", "CRAFTING"}
        s["npc;drop=16411"] = {"鬼灵厨师", "卡拉赞"}
        s["quest;reward=10280"] = {"送往沙塔斯的特殊货物", "虚空风暴"}
        s["quest;reward=10806"] = {"摊牌", "刀锋山"}
        s["npc;drop=17225"] = {"夜之魇", "卡拉赞"}
        s["spell;created=34540"] = {"狮心圣剑", "CRAFTING"}
        s["npc;drop=17381"] = {"制造者", "鲜血熔炉"}
        s["npc;drop=18697"] = {"主工程师洛杉德尔", "虚空风暴"}
        s["npc;drop=16181"] = {"蹂躏者洛卡德", "卡拉赞"}
        s["npc;drop=18693"] = {"演讲者玛尔高姆", "刀锋山"}
        s["npc;drop=16179"] = {"潜伏者希亚其斯", "卡拉赞"}
        s["npc;drop=16180"] = {"滑翔者沙德基斯", "卡拉赞"}
        s["npc;drop=16485"] = {"奥术看守", "卡拉赞"}
        s["npc;drop=23281"] = {"因斯迪安", "刀锋山"}
        s["npc;drop=18478"] = {"殉难者的化身", "奥金尼地穴"}
        s["npc;drop=17881"] = {"埃欧努斯", "黑色沼泽"}
        s["spell;created=34546"] = {"巨龙之喉", "CRAFTING"}
        s["npc;sold=25176"] = {"格里金·考伯斯宾 <竞技场商人>", "纳格兰"}
        s["npc;sold=17657"] = {"后勤军需官乌瑞卡 <荣耀堡军需官>", "地狱火半岛"}
        s["spell;created=35580"] = {"虚空打击胸甲", "CRAFTING"}
        s["spell;created=35582"] = {"虚空打击腰带", "CRAFTING"}
        s["npc;drop=184259"] = {"夜之领主", "卡拉赞"}
        s["object;contained=184465"] = {"军团宝箱", "能源舰"}
        s["npc;drop=17942"] = {"夸格米拉", "奴隶围栏"}
        s["quest;reward=9271"] = {"埃提耶什，守护者的传说之杖", "斯坦索姆"}
        s["quest;reward=11033"] = {"远离刺客之路", "逆风小径"}
        s["spell;created=35587"] = {"风鹰腰带", "CRAFTING"}
        s["npc;drop=16816"] = {"麦迪文的回音", "卡拉赞"}
        s["npc;drop=16152"] = {"猎手阿图门", "卡拉赞"}
        s["spell;created=35584"] = {"虚空打击护腕", "CRAFTING"}
        s["spell;created=35585"] = {"风鹰胸甲", "CRAFTING"}
    end
end
