local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "itIT");

if not L then return end

L.core = {
	ageDays = "%s giorni", -- Needs review
	ageHours = "%s ore", -- Needs review
	ageMinutes = "%s minuti", -- Needs review
	ageSeconds = "%s secondi", -- Needs review
	desc = "Aggiungi il Livello Oggetti Medio al tooltip di altri giocatori", -- Needs review
	load = "Caricando la versione %s", -- Needs review
	minimapClick = "Simple iLevel - Clicca per i dettagli", -- Needs review
	minimapClickDrag = "Clicca e trascina per spostare l'icona.", -- Needs review
	name = "Simple iLevel", -- Needs review
	purgeNotification = "Eliminando %s personaggi dalla tua cache", -- Needs review
	purgeNotificationFalse = "Non hai una cancellazione automatica impostata.", -- Needs review
	scoreDesc = "Questo è un Livello Oggetti Medio di tutti gli oggetti che indossi.", -- Needs review
	scoreYour = "Il tuo Livello Oggetti Medio è %s", -- Needs review
	slashClear = "Cancellando le impostazioni", -- Needs review
	slashGetScore = "%s ha un Livello Oggetti Medio di %s e l'informazione è di %s fa", -- Needs review
	slashGetScoreFalse = "Spiacenti, si è verificato un errore nel recupero del punteggio di %s", -- Needs review
	slashTargetScore = "%s ha un Livello Oggetti Medio di %s", -- Needs review
	slashTargetScoreFalse = "Spiacenti, c'è stato un errore nel calcolo del punteggio del tuo bersaglio.", -- Needs review
	ttAdvanced = "%s fa", -- Needs review
	ttLeft = "Livello Oggetti Medio:", -- Needs review
	options = {
		autoscan = "Scandisci automaticamente dopo dei cambiamenti", -- Needs review
		autoscanDesc = "Scandisce automaticamente i membri del gruppo quando sembra cambi dell'equipaggiamento", -- Needs review
		clear = "Cancella Impostazioni", -- Needs review
		clearDesc = "Cancella tutte le impostazioni e la cache", -- Needs review
		color = "Color Score", -- Requires localization
		colorDesc = "Color the AiL where appropriate. Disable this if you only want to see white and gray scores.", -- Requires localization
		get = "Recupera Punteggio", -- Needs review
		getDesc = "Recupera il Livello Oggetti Medio di un nome se è in cache", -- Needs review
		ldb = "Opzioni di LibDataBroker", -- Needs review
		ldbRefresh = "Frequenza di aggiornamento", -- Needs review
		ldbRefreshDesc = "Quanto spesso deve essere aggiornato LibDataBroker in secondi.", -- Needs review
		ldbSource = "Etichetta della sorgente di LibDataBroker", -- Needs review
		ldbSourceDesc = "Mostra un'etichetta della sorgente dei dati per il punteggio di LibDataBroker", -- Needs review
		ldbText = "Testo di LibDataBroker", -- Needs review
		ldbTextDesc = "Attiva/Disattiva LibDataBroker per risparmiare risorse", -- Needs review
		maxAge = "Intervallo Massimo di Refresh (minuti)", -- Needs review
		maxAgeDesc = "Imposta la quantità di tempo tra il refresh delle ispezioni in minuti", -- Needs review
		minimap = "Mostra il pulsante sulla minimappa", -- Needs review
		minimapDesc = "Imposta il bottone sulla minimappa", -- Needs review
		modules = "Load Modules", -- Requires localization
		modulesDesc = "For these changes to take effect you need to reload your UI with /rl or /console reloadui.", -- Requires localization
		mouseover = "Scan on MouseOver", -- Requires localization
		mouseoverDesc = "Automatically scans players on mouseover. May add major UI lag in cities and you will hit the inspecting rate limit.", -- Requires localization
		name = "Opzioni di Simple iLevel", -- Needs review
		open = "Apri l'IU delle opzioni di Simple iLevel", -- Needs review
		options = "Opzioni di Simple iLevel", -- Needs review
		paperdoll = "Mostra nelle Informazioni del Personaggio", -- Needs review
		paperdollDesc = "Mostra il tuo Livello Oggetti Medio nella finestra Informazioni del Personaggio nel pannello delle statistiche.", -- Needs review
		purge = "Pulisci la cache", -- Needs review
		purgeAuto = "Pulisci automaticamente la cache", -- Needs review
		purgeAutoDesc = "Pulisci automaticamente la cache antecedente i # giorni. 0 è Mai.", -- Needs review
		purgeDesc = "Cancella tutti i personaggi in cache più vecchi di %s giorni", -- Needs review
		purgeError = "Prego inserire il numero di giorni.", -- Needs review
		round = "Round iLevel", -- Requires localization
		roundDesc = "Round the iLevel to the nearest whole number", -- Requires localization
		target = "Recupera Punteggio del Bersaglio", -- Needs review
		targetDesc = "Recupera il Livello Oggetti Medio del tuo bersagli attuale", -- Needs review
		ttAdvanced = "Tooltip avanzati", -- Needs review
		ttAdvancedDesc = "Imposta tooltip avanzati inclusa la \"vecchiaia\" dei punteggi", -- Needs review
		ttCombat = "Tooltip in combattimento", -- Needs review
		ttCombatDesc = "Mostra le informazioni di Simple iLevel nel tooltip in combattimento", -- Needs review
	},
}
L.group = {
	addonName = "Simple iLevel - Group", -- Requires localization
	desc = "Guarda il Livello Oggetti Medio di tutti nel tuo gruppo", -- Needs review
	load = "Modulo Gruppo Caricato", -- Needs review
	name = "Simple iLevel - Gruppo", -- Needs review
	nameShort = "Gruppo", -- Needs review
	outputHeader = "Simple iLevel: Media gruppo %s", -- Needs review
	outputNoScore = "%s non è disponibile", -- Needs review
	outputRough = "* indica un punteggio approssimato", -- Needs review
	options = {
		group = "Punteggio del Gruppo", -- Needs review
		groupDesc = "Stampa il punteggio del gruppo su <%s>", -- Needs review
	},
}
L.resil = {
	addonName = "Simple iLevel - Resilience", -- Requires localization
	desc = "Shows the amount of PvP gear other players have equipped in the tooltip", -- Requires localization
	load = "Modulo Resilienza Caricato", -- Needs review
	name = "Simple iLevel - Resilienza", -- Needs review
	nameShort = "Resilienza", -- Needs review
	outputHeader = "Simple iLevel: Group Average PvP Gear %s", -- Requires localization
	outputNoScore = "%s is not available", -- Requires localization
	outputRough = "* denotes an approximate score", -- Requires localization
	ttPaperdoll = "Hai %s/%s oggetti con un punteggio %s di Resilienza PVP.", -- Needs review
	ttPaperdollFalse = "Non indossi oggetti PVP.", -- Needs review
	options = {
		cinfo = "Mostra nelle Informazioni del Personaggio.", -- Needs review
		cinfoDesc = "Mostra il tuo punteggio Simple iLevel - Resilienza nel pannello statistiche.", -- Needs review
		group = "Group PvP Score", -- Requires localization
		groupDesc = "Prints the PvP Score of your group to <%s>.", -- Requires localization
		name = "Opzioni Simple iLevel - Resilienza", -- Needs review
		pvpDesc = "Mostra l'equipaggiamento PVP di tutti nel tuo gruppo.", -- Needs review
		ttType = "Tipo di tooltip", -- Needs review
		ttZero = "Zero tooltip", -- Needs review
		ttZeroDesc = "Mostra informazioni nel tooltip anche se non hanno oggetti PVP.", -- Needs review
	},
}
L.social = {
	addonName = "Simple iLevel - Social", -- Requires localization
	desc = "Added the AiL to chat windows for various channels", -- Requires localization
	load = "Modulo Sociale Caricato", -- Needs review
	name = "Simple iLevel - Sociale", -- Needs review
	nameShort = "Sociale", -- Needs review
	options = {
		chatEvents = "Mostra punteggio su:", -- Needs review
		color = "Colora Punteggio", -- Needs review
		colorDesc = "Colora il punteggio nella finestra di chat.", -- Needs review
		enabled = "Abilitato", -- Needs review
		enabledDesc = "Abilita tutte le caratteristiche di Simple iLevel - Sociale", -- Needs review
		name = "Simple iLevel - Opzioni Sociali", -- Needs review
	},
}


