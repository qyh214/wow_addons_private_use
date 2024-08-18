local L = BigWigs:NewBossLocale("Jin'rokh the Breaker", "itIT")
if not L then return end
if L then
	L.storm_duration = "Durata Tempesta di Fulmini"
	L.storm_duration_desc = "Una barra di avviso separata per la durata del lancio di Tempesta di Fulmini"
	L.storm_short = "Tempesta"
end

L = BigWigs:NewBossLocale("Horridon", "itIT")
if L then
	L.charge_trigger = "posa il suo sguardo"
	L.door_trigger = "irrompono"
	--L.orb_trigger = "charge" -- PLAYERNAME forces Horridon to charge the Farraki door!

	L.chain_lightning_desc = "|cffff0000Avviso solo per il bersaglio Focus.|r {-7124}"
	L.chain_lightning_message = "Il tuo focus sta lanciando Catena di Fulmini!"
	L.chain_lightning_bar = "Focus: Catena di Fulmini"

	L.fireball_desc = "|cffff0000Avviso solo per il bersaglio Focus.|r {-7122}"
	L.fireball_message = "Il tuo focus sta lanciando Palla di Fuoco!"
	L.fireball_bar = "Focus: Palla di Fuoco"

	L.venom_bolt_volley_desc = "|cffff0000Avviso solo per il bersaglio Focus.|r {-7112}"
	L.venom_bolt_volley_message = "Il tuo Focus sta lanciando Raffica Venefica!"
	L.venom_bolt_volley_bar = "Focus: Raffica Venefica"

	L.adds = "Adds in arrivo"
	L.adds_desc = "Avvisa quando sono in arrivo i vari add dei Farraki, dei Gurubashi, dei Drakkari, degli Amani, e il Dio della Guerra Jalak."

	L.door_opened = "Porta Aperta!"
	L.door_bar = "Prossima porta (%d)"
	L.balcony_adds = "Add dal Balcone"
	L.orb_message = "Globo del Controllo a Terra!"
end

L = BigWigs:NewBossLocale("Council of Elders", "itIT")
if L then
	L.priestess_adds = "Add Sacerdotessa"
	L.priestess_adds_desc = "Avvisa quando la Gran Sacerdotessa Mar'li inizia ad evocare un'add"
	L.priestess_adds_message = "Add Sacerdotessa"

	--L.priestess_heal = "%s was healed!"
	L.assault_stun = "Difensore Stordito!"
	L.full_power = "Pieno Potere"
	L.assault_message = "Assalto"
	L.hp_to_go_power = "Punti Vita alla Fine %d%%! (Potenza: %d)"
	L.hp_to_go_fullpower = "Punti Vita alla Fine %d%%! (Piena Potenza)"

	L.custom_on_markpossessed = "Evidenzia Boss Posseduto"
	L.custom_on_markpossessed_desc = "Evidenzia il Boss posseduto con un teschio richiede capo incursione o assistente."
end

L = BigWigs:NewBossLocale("Tortos", "itIT")
if L then
	L.bats_desc = "Tanti pipistrelli. Dai una mano."

	L.kick = "Calcio"
	L.kick_desc = "Tieni il conto di quante tartarughe possono essere prese a calci"
	L.kick_message = "Tartarughe Calciabili: %d"
	L.kicked_message = "%s ha calciato! (%d rimaste)"

	L.custom_off_turtlemarker = "Selezionatore Tartarughe"
	L.custom_off_turtlemarker_desc = "Evidenzia le tartarughe usando tutti i simboli dell'incursione.\n|cFFFF0000Solo una persona dovrebbe abilitare questa opzione per evitare conflitti nella marcatura.|r\n|cFFADFF2FSUGGERIMENTO: Se l'Incursione ha scelto te per abilitare questa opzione, muovere velocemente il mouse sopra le tartarughe è il modo più rapido per evidenziarle.|r"
	L.no_crystal_shell = "NESSUNO Scudo di Cristallo"
end

L = BigWigs:NewBossLocale("Megaera", "itIT")
if L then
	L.breaths = "Soffi"
	L.breaths_desc = "Avvisi relativi ad ogni tipo di soffio possibile."
	L.arcane_adds = "Testa Arcana"
end

L = BigWigs:NewBossLocale("Ji-Kun", "itIT")
if L then
	L.first_lower_hatch_trigger = "Le uova in uno dei nidi inferiori iniziano a schiudersi!"
	L.lower_hatch_trigger = "Le uova in uno dei nidi inferiori iniziano a schiudersi!"
	L.upper_hatch_trigger = "Le uova in uno dei nidi superiori iniziano a schiudersi!"

	L.nest = "Nidi"
	L.nest_desc = "Avvisi relativi ai nidi.\n|cFFADFF2FSUGGERIMENTO: Deselezionalo per spengere gli avvisi, se non sei designato a gestire i nidi.|r"

	L.flight_over = "Termine del Volo tra %d sec!"
	L.upper_nest = "Nido |cff008000Superiore|r"
	L.lower_nest = "Nido |cffff0000Inferiore|r"
	L.up = "|cff008000SOPRA|r"
	L.down = "|cffff0000SOTTO|r"
	L.add = "Add"
	L.big_add_message = "Add Grande su %s"
end

L = BigWigs:NewBossLocale("Durumu the Forgotten", "itIT")
if L then
	L.red_spawn_trigger = "Nebbia Cremisi" -- "The Infrared Light reveals a Crimson Fog!"
	L.blue_spawn_trigger = "Nebbia Azzurra" -- "The Blue Rays reveal an Azure Fog!"
	L.yellow_spawn_trigger = "Nebbia d'Ambra" -- "The Bright Light reveals an Amber Fog!"

	L.adds = "Rivela Adds"
	L.adds_desc = "Avvisa quando rivela una Nebbia Cremisi, d'Ambra o Azzurra e quante Nebbie rimangono."

	L.custom_off_ray_controllers = "Controllori dei Raggi"
	L.custom_off_ray_controllers_desc = "Usa le icone di incursione {rt1}{rt7}{rt6} per evidenziare i giocatori che controllano le posizioni dei raggi e il loro movimento."

	L.custom_off_parasite_marks = "Marcatore Parassita Oscuro"
	L.custom_off_parasite_marks_desc = "Per aiutare l'assegnazione dei Guaritori, evidenzia i giocatori che hanno il Parassita Oscuro con {rt3}{rt4}{rt5}."

	L.initial_life_drain = "Lancio iniziale Risucchio di Vita"
	L.initial_life_drain_desc = "Messaggio per il primo lancio di Risucchio di Vita per aiutare le cure su colui che ha il maleficio sulle cure ricevute."

	L.life_drain_say = "%dx Risucchiato"

	L.rays_spawn = "Apparizione raggi"
	L.red_add = "Add |cffff0000Rosso|r"
	L.blue_add = "Add |cff0000ffBlu|r"
	L.yellow_add = "Add |cffffff00Giallo|r"
	L.death_beam = "Raggio Disintegratore"
	L.red_beam = "Raggio |cffff0000Rosso|r"
	L.blue_beam = "Raggio |cff0000ffBlu|r"
	L.yellow_beam = "Raggio |cffffff00Giallo|r"
end

L = BigWigs:NewBossLocale("Primordius", "itIT")
if L then
	L.mutations = "Mutazioni |cff008000(%d)|r |cffff0000(%d)|r"
	L.acidic_spines = "Spine Acide (Danno ad Area)"
end

L = BigWigs:NewBossLocale("Dark Animus", "itIT")
if L then
	L.engage_trigger = "Il globo esplode!"

	L.matterswap_desc = "Un giocatore con Scambio di Materia è troppo distante da te. Scambierai posto con lui se l'effetto verrà dissipato."
	L.matterswap_message = "Sei il più lontano dallo Scambio di Materia!"

	L.siphon_power = "Aspirazione dell'Anima (%d%%)"
	L.siphon_power_soon = "Aspirazione dell'Anima (%d%%) %s tra poco!"
	L.slam_message = "Urto Esplosivo"
end

L = BigWigs:NewBossLocale("Iron Qon", "itIT") -- commented out strings not present anymore in this module, keeping translated strings for lazyness; if not useful feel free to delete them
if L then
	L.molten_energy = "Energia Fusa"

	L.arcing_lightning_cleared = "Fulmine Arcuato non più presente sull'Incursione"
end

L = BigWigs:NewBossLocale("Twin Consorts", "itIT")
if L then
	L.barrage_fired = "Lancio di Raffica!"
	L.last_phase_yell_trigger = "Solo per questa volta..." -- "<490.4 01:24:30> CHAT_MSG_MONSTER_YELL#Just this once...#Lu'lin###Suen##0#0##0#3273#nil#0#false#false", -- [6]
end

L = BigWigs:NewBossLocale("Lei Shen", "itIT")
if L then
	L.custom_off_diffused_marker = "Marcatore Fulmine Diffuso"
	L.custom_off_diffused_marker_desc = "Marca gli add Fulmine Diffuso usando tutte le icone dell'incursione, richiede capogruppo o assistente.\n|cFFFF0000Solo 1 persona nell'incursione dovrebbe attivare questa opzione per evitare conflitti di marcamento.|r\n|cFFADFF2FTIP: Se l'incursione ha scelto te attivalo, e muovi velocemente il mouse sopra OGNI add per marcarli più velocemente possibile.|r"

	L.shock_self = "Folgore Statica SU DI TE!!!"
	L.shock_self_desc = "Mostra una barra di durata per il maleficio Folgore Statica su di te."

	L.overcharged_self = "Sovraccarico SU DI TE!!!"
	L.overcharged_self_desc = "Mostra una barra di durata per il maleficio Sovraccarico su di te."

	L.last_inermission_ability = "Ultima abilità intermezzo usata!"
	L.safe_from_stun = "Sei probabilmente al sicuro dai disorientamenti di Sovraccarico"
	L.diffusion_add = "Add di Diffusione"
	L.shock = "Folgore"
	L.static_shock_bar = "<Divisione Folgore Statica>"
	L.overcharge_bar = "<Pulsazione Sovraccarico>"
end

L = BigWigs:NewBossLocale("Ra-den", "itIT")
if L then
	L.vita_abilities = "Abilità Vita"
	L.anima_abilities = "Abilità Anima"
	L.worm = "Verme"
	L.worm_desc = "Evocazione verme"

	L.balls = "Sfere"
	L.balls_desc = "Sfere dell'Anima (rosse) e della Vita (blu), che determinano quali abilità guadagna Ra-den"
	L.corruptedballs = "Sfere Corrotte"
	L.corruptedballs_desc = "Sfere Corrotte della Vita e dell'Anima, che aumentano il danno fatto (Vita) o i pf massimi (Anima)"
	L.unstablevitajumptarget = "Cambio bersaglio Vita Instabile"
	L.unstablevitajumptarget_desc = "Ti avvisa quando sei il più distante da un giocatore con Vita Instabile. Se enfatizzi questo avviso, attiverai un conto alla rovescia che indica quando Vita Instabile salterà SU DI TE."
	L.unstablevitajumptarget_message = "Sei il più lontano da Vita Instabile"
	L.sensitivityfurthestbad = "Sensitività Vita + più lontano = |cffff0000NON BENE|r!"
	L.kill_trigger = "Fermi!"

	L.assistPrint = "Un plugin di nome 'BigWigs_Ra-denAssist' è stato rilasciato e reso disponibile per assistenza durante lo scontro con Ra-den che potrebbe interessare alla tua gilda."
end

L = BigWigs:NewBossLocale("Throne of Thunder Trash", "itIT")
if L then
	L.stormcaller = "Invocatore delle Tempeste Zandalari"
	L.stormbringer = "Araldo della Tempesta Draz'kil"
	L.monara = "Monara"
	L.rockyhorror = "Orrore Roccioso"
	L.thunderlord_guardian = "Signore del Tuono / Guardiano del Fulmine"
end

