
local L = BigWigs:NewBossLocale("Magmaw", "itIT")
if not L then return end
if L then
	L.stage2_yell_trigger = "Inconcepibile" --Inconcepibile! Avete sconfitto il mio Verme della Lava! Forse posso bilanciare la situazione.

	L.slump = "Crollo"
	L.slump_desc = "Avvisa il crollo di Magmaw ed espone la sua testa, permettendo ai cavalcatori del rodeo di iniziare."
	L.slump_bar = "Rodeo"
	L.slump_message = "Oh Sììì, cavalchiamo!!!"
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "itIT")
if L then
	L.nef = "Ser Victor Nefarius"
	L.nef_desc = "Avvisi per le abilità di Ser Victor Nefarius."

	L.pool_explosion = "Esplosione Pozza"
	L.incinerate = "Incenerimento"
	L.flamethrower = "Lanciafiamme"
	L.lightning = "Elettro"
	L.infusion = "Infusione"
end

L = BigWigs:NewBossLocale("Atramedes", "itIT")
if L then
	L.obnoxious_fiend = "Demonio Ripugnante" -- NPC ID 49740
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "itIT")
if L then
	L.flames = "Fiamme"
end

L = BigWigs:NewBossLocale("Nefarian", "itIT")
if L then
	L.discharge = "Scarica"
	L.stage3_yell_trigger = "UCCIDERVI TUTTI" -- Ho cercato di essere un ospite cortese, ma non volete proprio morire! È ora di abbandonare ogni formalità e... UCCIDERVI TUTTI!
	--L.too_close = "Dragons are too close"
end
