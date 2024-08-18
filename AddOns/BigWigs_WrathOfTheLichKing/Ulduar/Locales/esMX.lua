local L = BigWigs:NewBossLocale("Auriaya", "esMX")
if not L then return end
if L then
	L.swarm_message = "Enjambre"

	L.defender = "Defensor feral"
	L.defender_desc = "Aviso para la vida del Defensor feral."
	L.defender_message = "¡Defensor vivo %d/9!"
end

L = BigWigs:NewBossLocale("Freya", "esMX")
if L then
	L.wave = "Oleadas"
	L.wave_desc = "Aviso para oleadas."
	L.wave_bar = "Próxima oleada"
	L.conservator_trigger = "¡Eonar, tus sirvientes requieren tu ayuda!"
	L.detonate_trigger = "¡El azote de los elementos podrá con vosotros!"
	L.elementals_trigger = "¡Hijos, ayudadme!"
	L.tree_trigger = "¡El |cFF00FFFFDon de Eonar|r empieza a brotar!" -- verificar
	L.conservator_message = "¡Conservador!"
	L.detonate_message = "¡Azotadores detonantes!"
	L.elementals_message = "¡Elementales!"

	L.tree = "Don de Eonar"
	L.tree_desc = "Alerta cuando Freya invoca un Don de Eonar."
	L.tree_message = "¡Arbol vivo!"

	L.fury_message = "Furia"

	L.tremor_warning = "¡Tremor terrenal inminente!"
	L.tremor_bar = "~Próximo Tremor terrenal"
	L.energy_message = "¡Energía inestable en TI!"
	L.sunbeam_message = "¡Rayos activos!"
	L.sunbeam_bar = "~Próximos Rayos de sol"
end

L = BigWigs:NewBossLocale("Hodir", "esMX")
if L then
	L.hardmode = "Modo difícil"
	L.hardmode_desc = "Mostrar contador para el modo difícil."
end

L = BigWigs:NewBossLocale("Ignis the Furnace Master", "esMX")
if L then
	L.brittle_message = "¡El ensamblaje es frágil!"
end

L = BigWigs:NewBossLocale("The Iron Council", "esMX")
if L then
	L.stormcaller_brundir = "Clamatormentas Brundir"
	L.steelbreaker = "Rompeacero"
	L.runemaster_molgeim = "Maestro de runas Molgeim"

	L.summoning_message = "¡Elementales inminentes!"

	L.chased_other = "¡%s está siendo perseguido!"
	L.chased_you = "¡TU estás siendo perseguido!"
end

L = BigWigs:NewBossLocale("Kologarn", "esMX")
if L then
	L.arm = "Muere el brazo"
	L.arm_desc = "Aviso cuando muere el brazo izquierdo/derecho."
	L.left_dies = "Muere el brazo izquierdo"
	L.right_dies = "Muere el brazo derecho"
	L.left_wipe_bar = "Reaparece el brazo izquierdo"
	L.right_wipe_bar = "Reaparece el brazo derecho"

	L.eyebeam = "Haz ocular enfocado"
	L.eyebeam_desc = "Avisa quien tiene el Haz ocular enfocado."
end

L = BigWigs:NewBossLocale("Mimiron", "esMX")
if L then
	L.phase = "Fases"
	L.phase_desc = "Aviso para cambios de fases."
	L.engage_warning = "Fase 1"
	L.engage_trigger = "^¡No tenemos mucho tiempo, amigos!"
	L.phase2_warning = "Fase 2 inminente"
	L.phase2_trigger = "^¡ESTUPENDO! ¡Unos resultados definitivamente maravillosos!"
	L.phase3_warning = "Fase 3 inminente"
	L.phase3_trigger = "^¡Gracias amigos!"
	L.phase4_warning = "Fase 4 inminente"
	L.phase4_trigger = "^Fase de prueba preliminar completada."
	L.phase_bar = "Fase %d"

	L.hardmode_trigger = "^¡Cómo se os ocurre hacer algo así!"

	L.plasma_warning = "¡Lanzando Explosión de plasma!"
	L.plasma_soon = "¡Plasma inminente!"
	L.plasma_bar = "Plasma"

	L.shock_next = "Próxima Explosión de choque"

	L.laser_soon = "¡Girando!"
	L.laser_bar = "Tromba de láseres"

	L.magnetic_message = "¡ACU pegado!"

	L.suppressant_warning = "¡Supresor inminente!"

	L.fbomb_bar = "Próxima Bomba de Escarcha"

	L.bomb_message = "¡Bombabot aparece!"
end

L = BigWigs:NewBossLocale("Razorscale", "esMX")
if L then
	L.ground_trigger = "¡Moveos! ¡No seguirá mucho más en el suelo!"
	L.ground_message = "¡Tajoescama está encandenado!"
	L.air_message = "¡Despega!"

	L.harpoon = "Arpones"
	L.harpoon_desc = "Anuncia cuando los arpones están listos para su uso."
	L.harpoon_message = "¡Arpón %d listo!"
	L.harpoon_trigger = "¡Torreta de arpones lista!"
	L.harpoon_nextbar = "Arpón %d"
end

L = BigWigs:NewBossLocale("Thorim", "esMX")
if L then
	L.phase2_trigger = "¡Intrusos! Vosotros, mortales que osáis interferir en mi diversión, pagaréis… Un momento..."
	L.phase3_trigger = "Gusanos impertinentes, ¿cómo osáis desafiarme en mi pedestal? ¡Os machacaré con mis propias manos!"

	L.hardmode = "Temporizador modo difícil"
	L.hardmode_desc = "Muestra un contador para cuando llegues a Thorim en modo difícil en fase 3."
	L.hardmode_warning = "Modo difícil expira"

	L.barrier_message = "¡Barrera activa!"

	L.charge_message = "Cargado x%d!"
	L.charge_bar = "Carga %d"
end

L = BigWigs:NewBossLocale("General Vezax", "esMX")
if L then
	L.surge_bar = "Oleada %d"

	L.animus = "Animus de saronita"
	L.animus_desc = "Avisa cuanto el Animus de saronita aparece."
	L.animus_trigger = "The saronite vapors mass and swirl violently, merging into a monstrous form!" -- translate
	L.animus_message = "¡Animus aparece!"

	L.vapor = "Vapores de saronita"
	L.vapor_desc = "Avisa cuando avaprecen vapores de saronita."
	L.vapor_message = "¡Vapor de saronita %d!"
	L.vapor_bar = "Vapor"
	L.vapor_trigger = "¡Cerca se forma una nube de vapores de saronita!" -- verificar

	L.vaporstack = "Stacks de Vapores"
	L.vaporstack_desc = "Avisa cuando tienes 5 o más stacks de Vapores de saronita."
	L.vaporstack_message = "¡Vapores x%d!"

	L.crash_say = "Fragor"

	L.mark_message = "Marca"
end

L = BigWigs:NewBossLocale("XT-002 Deconstructor", "esMX")
if L then
	L.lightbomb_other = "Luz"
end

L = BigWigs:NewBossLocale("Yogg-Saron", "esMX")
if L then
	L.engage_trigger = "^¡Pronto llegará la hora de"
	L.phase2_trigger = "^Soy un sueño lúcido."
	L.phase3_trigger = "^¡Observad el auténtico rostro de la muerte"

	L.portal = "Portal"
	L.portal_desc = "Aviso para portales."
	L.portal_message = "¡Portales abiertos!"
	L.portal_bar = "Próximos portales"

	L.fervor_message = "Fervor en %s!"

	L.sanity_message = "¡Te estás volviendo loco!"

	L.weakened = "Aturdido"
	L.weakened_desc = "Avisa cuando Yogg-saron está aturdido."
	L.weakened_message = "¡%s está aturdido!"

	L.madness_warning = "¡Locura en 10 seg!"
	L.malady_message = "Mal de la mente" -- short for Malady of the Mind (63830)

	L.tentacle = "Tentáculo triturador"
	L.tentacle_desc = "Aviso cuando Tentáculo triturador aparece."
	L.tentacle_message = "¡Triturador %d!"

	--L.small_tentacles = "Small Tentacles"
	--L.small_tentacles_desc = "Warn for Corruptor Tentacle and Constrictor Tentacle spawns."

	L.link_warning = "¡Estás enlazado!"

	L.guardian_message = "¡Guardian %d!"

	L.roar_warning = "¡Rugido en 5seg!"
	L.roar_bar = "Próximo rugido"
end
