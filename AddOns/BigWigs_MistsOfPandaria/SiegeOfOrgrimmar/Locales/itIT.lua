local L = BigWigs:NewBossLocale("The Fallen Protectors", "itIT")
if not L then return end
if L then
L["defile_you"] = "Suolo Profanato sotto DI TE"
L["defile_you_desc"] = "Avvisa quando Suolo Profanato è sotto di te."
L["inferno_self"] = "Assalto dell'Inferno su DI TE"
L["inferno_self_bar"] = "Stai per esplodere!"
L["inferno_self_desc"] = "Conto alla rovescia speciale per quando Assalto dell'Inferno è su di te."
L["intermission_desc"] = "Avvisa quando i boss usano Misure Disperate"
L["no_meditative_field"] = "Non sei nella bolla!"

	L.custom_off_bane_marks = "Parola d'Ombra: Flagello"
	L.custom_off_bane_marks_desc = "Per aiutare a dissipare, evidenzia chi ha Parola d'Ombra: Flagello su di loro con {rt1}{rt2}{rt3}{rt4}{rt5} (in questo ordine, possono non essere usati tutti i simboli), richiede capo incursione o assistente."
end

L = BigWigs:NewBossLocale("Norushen", "itIT")
if L then
L["big_add"] = "Add Maggiore (%d)"
L["big_add_killed"] = "Add Maggiore ucciso (%d)"
L["big_adds"] = "Add Maggiori"
L["big_adds_desc"] = "Avvisi per l'apparizione degli add maggiori da uccidere."
L["warmup_trigger"] = "Molto bene, creerò un campo di contenimento per la corruzione che vi affligge."
end

L = BigWigs:NewBossLocale("Sha of Pride", "itIT")
if L then
L["projection_green_arrow"] = "FRECCIA VERDE"
L["titan_pride"] = "Titano+Orgoglio: %s"

	L.custom_off_titan_mark = "Marcatore Potenza dei Titani"
	L.custom_off_titan_mark_desc = "Evidenzia i giocatori con Dono dei Titani con {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}, richiede capoincursione o assistente.\n|cFFFF0000Soltanto 1 dei giocatori nell'incursione dovrebbe tenere abilitata questa opzione per evitare conflitti di marcamento.|r"

	L.custom_off_fragment_mark = "Corrupted Fragment marker"
	L.custom_off_fragment_mark_desc = "Mark the Corrupted Fragments with {rt8}{rt7}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
end

L = BigWigs:NewBossLocale("Galakras", "itIT")
if L then
L["adds_desc"] = "Avvisi per quando una nuova ondata di add entra in combattimento."
L["demolisher_message"] = "Demolitori"
L["drakes"] = "Proto-Draghi"
L["north_tower"] = "Torre nord"
L["north_tower_trigger"] = "La porta a protezione della torre a nord è stata sfondata!"
L["south_tower"] = "Torre sud"
L["south_tower_trigger"] = "La porta a protezione della torre a sud è stata sfondata!"
L["start_trigger_alliance"] = "Ben fatto! Squadre da sbarco in formazione! Fanti in prima linea!"
L["start_trigger_horde"] = "Ben fatto. La prima compagnia è riuscita a sbarcare."
L["tower_defender"] = "Difensore Torre"
L["towers"] = "Torri"
L["towers_desc"] = "Avvisa quando le torri vengono distrutte"
L["warlord_zaela"] = "Signora della Guerra Zaela"

	L.custom_off_shaman_marker = "Marcatore Sciamano"
	L.custom_off_shaman_marker_desc = "Per aiutare l'assegnazione delle interruzzioni, evidenzia gli Sciamani delle Maree delle Fauci di Drago con {rt1}{rt2}{rt3}{rt4}{rt5}, richiede capo incursione o assistente.\n|cFFFF0000Solo 1 persona nell'incursione dovrebbe attivare questa opzione per evitare conflitti con le assegnazioni.|r\n|cFFADFF2FSUGGERIMENTO: Se l'Incursione ha scelto te per abilitare questa opzione, muovere velocemente il mouse sopra gli sciamani è il modo più rapido per evidenziarli.|r"
end

L = BigWigs:NewBossLocale("Iron Juggernaut", "itIT")
if L then
	L.custom_off_mine_marks = "Marcatore delle Mine"
	L.custom_off_mine_marks_desc = "Per aiutare l'assegnazione degli assorbimenti, evidenzia le Mine Striscianti con {rt1}{rt2}{rt3}, richiede capo incursione o assistente.\n|cFFFF0000Solo 1 persona nell'incursione dovrebbe attivare questa opzione per evitare conflitti con le assegnazioni.|r\n|cFFADFF2FSUGGERIMENTO: Se l'Incursione ha scelto te per abilitare questa opzione, muovere velocemente il mouse sopra tutte le mine è il modo più rapido per evidenziarle.|r"
end

L = BigWigs:NewBossLocale("Kor'kron Dark Shaman", "itIT")
if L then
L["blobs"] = "Melme"

	L.custom_off_mist_marks = "Marcatore Nebbia Tossica"
	L.custom_off_mist_marks_desc = "Per aiutare l'assegnazione delle cure, evidenzia i giocatori che hanno Nebbia Tossica con {rt1}{rt2}{rt3}{rt4}{rt5}, richiede capo incursione o assistente.\n|cFFFF0000Solo 1 persona nell'incursione dovrebbe attivare questa opzione per evitare conflitti con le assegnazioni.|r"
end

L = BigWigs:NewBossLocale("General Nazgrim", "itIT")
if L then
	L.custom_off_bonecracker_marks = "Marcatore Colpo Incrinante"
	L.custom_off_bonecracker_marks_desc = "Per aiutare l'assegnazione delle cure, evidenzia i giocatori che hanno Colpo Incrinante su di loro con {rt1}{rt2}{rt3}{rt4}{rt5}, richiede capo incursione o assistente.\n|cFFFF0000Solo 1 persona nell'incursione dovrebbe attivare questa opzione per evitare conflitti con le assegnazioni.|r"

	L.stance_bar = "%s (ADESSO: %s)"
	L.battle = "Battaglia"
	L.berserker = "Berserker"
	L.defensive = "Difesa"

	L.adds_trigger1 = "Difendete il cancello!" --all triggers verified
	L.adds_trigger2 = "Radunate le forze!"
	L.adds_trigger3 = "Prossima squadra, al fronte!"
	L.adds_trigger4 = "Guerrieri, in marcia!"
	L.adds_trigger5 = "Kor'kron, con me!"
	L.adds_trigger_extra_wave = "Tutti i Kor'kron... al mio comando... uccideteli... ORA"
	L.extra_adds = "Armate Aggiuntive"
	L.final_wave = "Ultima Ondata"
	L.add_wave = "%s (%s): %s"

	L.chain_heal_message = "Il tuo focus sta lanciando Catena di Guarigione Potenziata!"

	L.arcane_shock_message = "Il tuo focus sta lanciando Folgore Arcana!"
end

L = BigWigs:NewBossLocale("Malkorok", "itIT")
if L then
	L.custom_off_energy_marks = "Marcatore Energia Dispersa"
	L.custom_off_energy_marks_desc = "Per aiutare l'assegnazione dei dissolvimenti, evidenzia i giocatori che hanno Energia Diffusa su di loro con {rt1}{rt2}{rt3}{rt4}, richiede capoincursione o assistente.\n|cFFFF0000Solo 1 persona nell'incursione dovrebbe attivare questa opzione per evitare conflitti con le assegnazioni.|r"
end

L = BigWigs:NewBossLocale("Spoils of Pandaria", "itIT")
if L then
L["enable_zone"] = "Immagazzinamento Artefatti"
L["start_trigger"] = "Stiamo registrando?"
L["win_trigger"] = "Riavvio del sistema. Non staccare la corrente o potrebbe saltare tutto in aria."

	L.crates = "Casse"
	L.crates_desc = "Messaggio per quanta Potenza è ancora richiesta e quante casse grandi*medie/piccole servono."
	L.full_power = "Piena Potenza!"
	L.power_left = "%d rimanenti! (%d/%d/%d)"
end

L = BigWigs:NewBossLocale("Thok the Bloodthirsty", "itIT")
if L then
L["adds_desc"] = "Avvisa quando Yeti o Pipistrelli entrano in combattimento."
L["cage_opened"] = "Gabbia Aperta"
L["npc_akolik"] = "Akolik"
L["npc_waterspeaker_gorai"] = "Oratore dell'Acqua Gorai"
end

L = BigWigs:NewBossLocale("Siegecrafter Blackfuse", "itIT")
if L then
L["assembly_line_items"] = "Oggetti (%d): %s"
L["assembly_line_message"] = "Armi non finite (%d)"
L["assembly_line_trigger"] = "Armi incomplete iniziano a uscire dalla catena di montaggio."
L["disabled"] = "Disabilitato"
L["item_deathdealer"] = "Torretta della Morte"
L["item_laser"] = "Laser"
L["item_magnet"] = "Magnete"
L["item_mines"] = "Mine"
L["item_missile"] = "Missile"
L["laser_on_you"] = "Laser su di te PEW PEW!"
L["overcharged_crawler_mine"] = "Mina Strisciante Sovraccaricata"
L["shockwave_missile_trigger"] = "Vi presento... la nuova, magnifica torretta lanciamissili a onda d'urto ST-03!"
L["shredder_engage_trigger"] = "Un Segatronchi Automatizzato si avvicina!"

	L.custom_off_mine_marker = "Marcatore delle Mine"
	L.custom_off_mine_marker_desc = "Evidenzia le mine per l'assegnazione specifica degli incapacitamenti (Vengono utilizzati tutti i simboli)"
end

L = BigWigs:NewBossLocale("Paragons of the Klaxxi", "itIT")
if L then
	L.catalyst_match = "Catalizzatore: |c%sHA SCELTO TE|r" -- might not be best for colorblind?
	L.you_ate = "Hai mangiato un parassita (%d rimasti)"
	L.other_ate = "%s ha mangiato un %sparassita (%d rimasti)"
	L.parasites_up = "%d |4Parassita:Parassiti; attivi"
	L.dance = "%s, Danza"
	L.prey_message = "Usa Preda sul Parassita"
	L.injection_over_soon = "Fine di Iniezione tra poco (%s)!"

	L.one = "Iyyokuk seleziona: Uno!"
	L.two = "Iyyokuk seleziona: Due!"
	L.three = "Iyyokuk seleziona: Tre!"
	L.four = "Iyyokuk seleziona: Quattro!"
	L.five = "Iyyokuk seleziona: Cinque!"

	L.custom_off_edge_marks = "Marcatori dei Limiti"
	L.custom_off_edge_marks_desc = "Evidenzia i giocatori che saranno i limiti in base ai calcoli {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}{rt8}, richiede capoincursione o assistente.\n|cFFFF0000Solo 1 persona nell'incursione dovrebbe attivare questa opzione per evitare conflitti con le assegnazioni.|r"
	L.edge_message = "Sei uno dei limiti"

	L.custom_off_parasite_marks = "Marcatore Parassita"
	L.custom_off_parasite_marks_desc = "Evidenzia i parassiti da controllare e le assegnazioni di Preda con {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, richiede capoincursione o assistente.\n|cFFFF0000Solo 1 persona nell'incursione dovrebbe attivare questa opzione per evitare conflitti con le assegnazioni.|r"
end

L = BigWigs:NewBossLocale("Garrosh Hellscream", "itIT")
if L then
L["bombardment"] = "Bombardmento"
L["bombardment_desc"] = "Bombardamendo di Roccavento che lascia dei fuochi sul terreno. Le Pirostelle Kor'kron possono apparire soltanto durante il bombardmento."
L["chain_heal_bar"] = "Focus: Catena di Guarigione"
L["chain_heal_desc"] = "{focus}Cura un bersaglio amico per il 40% della sua vita massima, e a catena anche i bersagli amici vicini."
L["chain_heal_message"] = "Il tuo focus sta lanciando Catena di Guarigione!"
L["clump_check_desc"] = "Controlla ogni 3 secondi durante il Bombardamento i giocatori ammucchiati, se viene rilevato un gruppo, verrà creata una Pirostella Kor'kron."
L["clump_check_warning"] = "Rilevato ammucchiamento, Pirostella in arrivo"
L["empowered_message"] = "%s adesso è potenziato!"
L["farseer_trigger"] = "Chiaroveggenti, guarite le nostre ferite!"
L["ironstar_impact_desc"] = "Una barra a tempo per quando la Pirostella si schianterà contro l'altra parte della stanza."
L["ironstar_rolling"] = "Pirostella in movimento!"
L["manifest_rage"] = "Manifestazione della Rabbia"
L["manifest_rage_desc"] = "Quando Garrosh raggiunge 100 inizierà a prelanciare Manifestazione della Rabbia per 2 secondi, e poi la canalizzerà. Mentre canalizza, evoca degli add grandi. Porta la Pirostella su Garrosh per incapacitarlo ed interrompere il suo lancio."
L["phase_3_end_trigger"] = "Pensate di aver VINTO? Siete CIECHI. VI COSTRINGERÒ AD APRIRE GLI OCCHI."

	L.custom_off_shaman_marker = "Marcatore Chiaroveggenti"
	L.custom_off_shaman_marker_desc = "Per aiutare l'assegnazione delle interruzioni, evidenzia i Cavalcalupi Chiaroveggenti con {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7} (in questo ordine, non tutti i simboli possono essere usati), richiede capo incursione o assistente."

	L.custom_off_minion_marker = "Marcatore servitori"
	L.custom_off_minion_marker_desc = "Per aiutare a separare i servitori, evidenziali con {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}{rt8}, richiede capoincursione o assistente."

	--L.warmup_yell_chat_trigger1 = "It is not too late, Garrosh" -- It is not too late, Garrosh. Lay down the mantle of Warchief. We can end this here, now, with no more bloodshed."
	--L.warmup_yell_chat_trigger2 = "Do you remember nothing of Honor" -- Ha! Do you remember nothing of Honor? Of glory on the battlefield?  You who would parlay with the humans, who allowed warlocks to practice their dark magics right under our feet.  You are weak.
end

