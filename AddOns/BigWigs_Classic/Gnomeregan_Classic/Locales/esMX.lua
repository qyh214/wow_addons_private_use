local L = BigWigs:NewBossLocale("Grubbis Discovery", "esMX")
if not L then return end
if L then
	L.bossName = "Grubbis"
	L.aoe = "Daño cuerpo a cuerpo en área"
	L.cloud = "Una nube alcanzó al jefe"
	L.cone = "Cono \"frontal\"" -- "Frontal" Cone, it's a rear cone (he's farting)
	--L.warmup_say_chat_trigger = "Gnomeregan" -- There are still ventilation shafts actively spewing radioactive material throughout Gnomeregan.
end

L = BigWigs:NewBossLocale("Viscous Fallout Discovery", "esMX")
if L then
	L.bossName = "Radiactivo viscoso"
	L.desiccated_fallout = "Radiactivo disecado" -- NPC ID 216810
end

L = BigWigs:NewBossLocale("Crowd Pummeler 9-60 Discovery", "esMX")
if L then
	L.bossName = "Golpeamasa 9-60"
end

L = BigWigs:NewBossLocale("Electrocutioner 6000 Discovery", "esMX")
if L then
	L.bossName = "Electrocutor 6000"
end

L = BigWigs:NewBossLocale("Mechanical Menagerie Discovery", "esMX")
if L then
	L.bossName = "Sala de fieras mecánicas"
	L.attack_buff = "Velocidad de ataque +50%"
	L.boss_at_hp = "%s al %d%%" -- BOSS_NAME at 50%
	L.red_button = "Botón rojo"

	L[218242] = "|T134153:0:0:0:0:64:64:4:60:4:60|tDragón"
	L[218243] = "|T136071:0:0:0:0:64:64:4:60:4:60|tOveja"
	L[218244] = "|T133944:0:0:0:0:64:64:4:60:4:60|tArdilla"
	L[218245] = "|T135996:0:0:0:0:64:64:4:60:4:60|tPollo"

	L.run = "Corre hacia la puerta"
	L.run_desc = "Muestra un mensaje cuando derrotes a este jefe para correr hacia la puerta. Esto tiene como objetivo ayudarte a evitar enfrentarte accidentalmente al próximo jefe."
end

L = BigWigs:NewBossLocale("Mekgineer Thermaplugg Discovery", "esMX")
if L then
	L.bossName = "Mekigeniero Termochufe"
	L.red_button = "Botón rojo"
	L.position = "Posición %d" -- Position 5
end
