local L = BigWigs:NewBossLocale("Za'qul, Herald of Ny'alotha", "itIT")
if not L then return end
if L then
	L.stage3_early = "Gli squarci di Za'qul aprono l'ascesa per il Regno del Delirio!"  -- Yell is 14.5s before the actual cast start
end

L = BigWigs:NewBossLocale("Lady Ashvane", "itIT")
if L then
	L.linkText = "|T%d:15:15:0:0:64:64:4:60:4:60|t(%s+%s) "
end

L = BigWigs:NewBossLocale("Queen Azshara", "itIT")
if L then
	L[299249] = "ASSORBI le Sfere"
	L[299251] = "EVITA le Sfere"
	L[299254] = "ABBRACCIA gli Altri"
	L[299255] = "Stai DA SOLO"
	L[299252] = "CONTINUA A MUOVERTI"
	L[299253] = "STAI FERMO"
	L.hugSay = "ABBRACCIA %s"
	L.hugNoMoveSay = "ABBRACCIA %s, Non posso muovermi"
	L.avoidSay = "EVITA %s"
	L.yourDecree = "Decreto: %s"
	L.yourDecree2 = "Decreto: %s & %s"
	L.hulk_killed = "%s ucciso - %.1f sec"
	L.fails_message = "%s (%d Accumuli di Sanzione)"
	L.reversal = "Rovesciamento"
	L.greater_reversal = "Rovesciamento (Superiore)"

	L.custom_off_repeating_decree_chat = "Ripetizione Decreti"
	L.custom_off_repeating_decree_chat_desc = "Spamma 'ABBRACCIA me' urlando, or 'EVITA me' in chat, mentrei sei sotto l'effetto |cff71d5ff[Decreto della Regina]|r. Forse sarà utile se vedono i fumetti della chat."
end
