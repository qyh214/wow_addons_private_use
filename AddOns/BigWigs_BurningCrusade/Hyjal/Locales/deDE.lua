local L = BigWigs:NewBossLocale("ArchimondeHyjal", "deDE")
if not L then return end
if L then
	L.engage_trigger = "Euer Widerstand ist sinnlos!"
	L.grip_other = "Würgegriff"
	L.fear_message = "Furcht, nächste in ~42sek!"

	L.killable = "Becomes Killable"
end

L = BigWigs:NewBossLocale("Azgalor", "deDE")
if L then
	L.howl_bar = "~Geheul"
	L.howl_message = "AoE Stille"
end

L = BigWigs:NewBossLocale("Kaz'rogal", "deDE")
if L then
	L.mark_bar = "Mal von Kaz'rogal (%d)"
	L.mark_warn = "Mal von Kaz'rogal in 5sek!"
end

L = BigWigs:NewBossLocale("Hyjal Summit Trash", "deDE")
if L then
	L.waves = "Wellen"
	L.waves_desc = "Zeigt Warnungen für die nächste Welle an."

	L.ghoul = "Ghule"
	L.fiend = "Gruftscheusale"
	L.abom = "Monstrositäten"
	L.necro = "Nekromanten"
	L.banshee = "Banshees"
	L.garg = "Gargoyles"
	L.wyrm = "Frostwyrm"
	L.fel = "Teufelshunde"
	L.infernal = "Höllenbestien"
	L.one = "Welle %d! %d %s"
	L.two = "Welle %d! %d %s, %d %s"
	L.three = "Welle %d! %d %s, %d %s, %d %s"
	L.four = "Welle %d! %d %s, %d %s, %d %s, %d %s"
	L.five = "Welle %d! %d %s, %d %s, %d %s, %d %s, %d %s"
	L.barWave = "Welle %d spawnt."

	L.waveInc = "Welle %d kommt!"
	L.message = "%s in ~%d sek!"
	L.waveMessage = "Welle %d in ~%d sek!"
end
