local L = BigWigs:NewBossLocale("Azuregos", "frFR")
if not L then return end
if L then
	L.bossName = "Azuregos"
end

L = BigWigs:NewBossLocale("Lord Kazzak", "frFR")
if L then
	L.bossName = "Seigneur Kazzak"

	L.engage_trigger = "Pour la Légion ! Pour Kil'Jaeden !"
end

L = BigWigs:NewBossLocale("Emeriss", "frFR")
if L then
	L.bossName = "Emeriss"

	L.engage_trigger = "L'espoir est une MALADIE de l'âme ! Ces terres vont flétrir et mourir !"
end

L = BigWigs:NewBossLocale("Lethon", "frFR")
if L then
	L.bossName = "Léthon"

	L.engage_trigger = "Je sens l'OMBRE dans vos cœurs. Il ne peut y avoir de repos pour les vilains !"
end

L = BigWigs:NewBossLocale("Taerar", "frFR")
if L then
	L.bossName = "Taerar"

	L.engage_trigger = "La paix n'est qu'un rêve éphémère ! Que le CAUCHEMAR règne !"
end

L = BigWigs:NewBossLocale("Ysondre", "frFR")
if L then
	L.bossName = "Ysondre"

	L.engage_trigger = "Les fils de la VIE ont été coupés ! Les Rêveurs doivent être vengés !"
end
