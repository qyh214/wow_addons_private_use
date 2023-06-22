if GetLocale() ~= "ptBR" then return end
local L

---------------
-- Kurinnaxx --
---------------
L = DBM:GetModLocalization("Kurinnaxx")

L:SetGeneralLocalization{
	name 		= "Korinnaxx"
}
------------
-- Rajaxx --
------------
L = DBM:GetModLocalization("Rajaxx")

L:SetGeneralLocalization{
	name 		= "General Rajaxx"
}
L:SetWarningLocalization{
	WarnWave	= "Onda %s"
}
L:SetOptionLocalization{
	WarnWave	= "Anunciar a próxima onda de entrada"
}
L:SetMiscLocalization{
	Wave12		= "Eles estão vindo. Tenta não morrer, sangue-bom.",
	Wave12Alt	= "Você se lembra, Rajaxx, quando eu disse que ia te matar por último?",
	Wave3		= "A hora da vingança se aproxima! Deixem as trevas reinar nos corações dos nossos inimigos!",
	Wave4		= "Basta de portas trancadas e muros de pedra nos escondendo. Nossa vingança não será mais negada! Os próprios dragões tremerão diante da nossa ira!",
	Wave5		= "Levem o medo ao inimigo! Medo e morte!",
	Wave6		= "Guenelmo vai chorar e suplicar pela própria vida! Exatamente como o moleque do filho dele! Mil anos de injustiça... terminam hoje!",
	Wave7		= "Fandral, sua hora chegou! Vá se esconder no Sonho Esmeralda, e reze para que nós nunca o encontremos!",
	Wave8		= "Tolo insolente! Eu mesmo vou matá-lo!"
}

----------
-- Moam --
----------
L = DBM:GetModLocalization("Moam")

L:SetGeneralLocalization{
	name 		= "Moam"
}

----------
-- Buru --
----------
L = DBM:GetModLocalization("Buru")

L:SetGeneralLocalization{
	name 		= "Buru, o Banqueteador"
}
L:SetWarningLocalization{
	WarnPursue		= "Perseguir em >%s<",
	SpecWarnPursue	= "Perseguindo você",
	WarnDismember	= "%s em >%s< (%s)"
}
L:SetOptionLocalization{
	WarnPursue		= "Anunciar alvos perseguidos",
	SpecWarnPursue	= "Exibir aviso especial quando estiver sendo perseguido",
	WarnDismember	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(96)
}
L:SetMiscLocalization{
	PursueEmote 	= "%s vê o"
}

-------------
-- Ayamiss --
-------------
L = DBM:GetModLocalization("Ayamiss")

L:SetGeneralLocalization{
	name 		= "Ayamiss, o Caçador"
}

--------------
-- Ossirian --
--------------
L = DBM:GetModLocalization("Ossirian")

L:SetGeneralLocalization{
	name 		= "Ossirian, o Intocado"
}
L:SetWarningLocalization{
	WarnVulnerable	= "%s"
}
L:SetTimerLocalization{
	TimerVulnerable	= "%s"
}
L:SetOptionLocalization{
	WarnVulnerable	= "Anunciar fraqueza",
	TimerVulnerable	= "Exibir cronômetro para fraqueza"
}

----------------
-- AQ20 Trash --
----------------
L = DBM:GetModLocalization("AQ20Trash")

L:SetGeneralLocalization{
	name = "AQ20: Lixo"
}

------------
-- Skeram --
------------
L = DBM:GetModLocalization("Skeram")

L:SetGeneralLocalization{
	name = "Profeta Skeram"
}

----------------
-- Three Bugs --
----------------
L = DBM:GetModLocalization("ThreeBugs")

L:SetGeneralLocalization{
	name = "A Família de Insetos"
}
L:SetMiscLocalization{
	Yauj = "Princesa Yauj",
	Vem = "Veim",
	Kri = "Lorde Kri"
}

-------------
-- Sartura --
-------------
L = DBM:GetModLocalization("Sartura")

L:SetGeneralLocalization{
	name = "Guarda de Batalha Sartura"
}

--------------
-- Fankriss --
--------------
L = DBM:GetModLocalization("Fankriss")

L:SetGeneralLocalization{
	name = "Fankriss, o Obstinado"
}

--------------
-- Viscidus --
--------------
L = DBM:GetModLocalization("Viscidus")

L:SetGeneralLocalization{
	name = "Viscidus"
}
L:SetWarningLocalization{
	WarnFreeze	= "Congelamento: %d/3",
	WarnShatter	= "Estilhaçar: %d/3"
}
L:SetOptionLocalization{
	WarnFreeze	= "Anunciar status de congelamento",
	WarnShatter	= "Anunciar status de estilhaçar"
}
L:SetMiscLocalization{
	Slow	= "começa a ficar lento!",
	Freezing= "está congelando!",
	Frozen	= "está totalmente congelado!",
	Phase4 	= "começa a rachar!",
	Phase5 	= "parece estar a ponto de se estilhaçar!",
	Phase6 	= "explode!",
	HitsRemain	= "Acertos restantes",
	Frost		= "Gelo",
	Physical	= "Dano físico"
}
-------------
-- Huhuran --
-------------
L = DBM:GetModLocalization("Huhuran")

L:SetGeneralLocalization{
	name = "Princesa Huhuran"
}
---------------
-- Twin Emps --
---------------
L = DBM:GetModLocalization("TwinEmpsAQ")

L:SetGeneralLocalization{
	name = "Imperadores Gêmeos"
}
L:SetMiscLocalization{
	Veklor = "Imperador Vek'lor",
	Veknil = "Imperador Vek'nilash"
}

------------
-- C'Thun --
------------
L = DBM:GetModLocalization("CThun")

L:SetGeneralLocalization{
	name = "C'Thun"
}
L:SetWarningLocalization{
	WarnEyeTentacle			= "Tentóculo",
	WarnClawTentacle2		= "Tentáculo de Garra",
	WarnGiantEyeTentacle	= "Tentóculo Gigante",
	WarnGiantClawTentacle	= "Tentáculo de Garra Gigante",
	SpecWarnWeakened		= "C'Thun enfraquece!"
}
L:SetTimerLocalization{
	TimerEyeTentacle		= "Próximo Tentóculo",
	TimerClawTentacle		= "Próximo Tentáculo de Garra",
	TimerGiantEyeTentacle	= "Próximo Tentóculo Gigante",
	TimerGiantClawTentacle	= "Próximo Tentáculo de Garra Gigante",
	TimerWeakened			= "Enfraquece acaba"
}
L:SetOptionLocalization{
	WarnEyeTentacle			= "Exibir aviso para Tentóculo",
	WarnClawTentacle2		= "Exibir aviso para Tentáculo de Garra",
	WarnGiantEyeTentacle	= "Exibir aviso para Tentóculo Gigante",
	WarnGiantClawTentacle	= "Exibir aviso para Tentáculo de Garra Gigante",
	SpecWarnWeakened		= "Exibir aviso especial quando o chefe enfraquece",
	TimerEyeTentacle		= "Exibir cronômetro para o próximo Tentóculo",
	TimerClawTentacle		= "Exibir cronômetro para o próximo Tentáculo de Garra",
	TimerGiantEyeTentacle	= "Exibir cronômetro para o próximo Tentóculo Gigante",
	TimerGiantClawTentacle	= "Exibir cronômetro para o próximo Tentáculo de Garra Gigante",
	TimerWeakened			= "Exibir cronômetro para duração mais fraca do chefe",
	RangeFrame				= "Exibir quadro de alcance (10 m)"
}
L:SetMiscLocalization{
	Stomach		= "Estômago",
	Eye			= "Olho de C'Thun",
	FleshTent	= "Tentáculo de Carne",
	Weakened 	= "enfraquece!",
	NotValid	= "AQ40 parcialmente limpo. %s chefes opcionais permanecem."
}
----------------
-- Ouro --
----------------
L = DBM:GetModLocalization("Ouro")

L:SetGeneralLocalization{
	name = "Ouroboros"
}
L:SetWarningLocalization{
	WarnSubmerge		= "Submersão",
	WarnEmerge			= "Emersão"
}
L:SetTimerLocalization{
	TimerSubmerge		= "Submersão",
	TimerEmerge			= "Emersão"
}
L:SetOptionLocalization{
	WarnSubmerge		= "Exibir aviso para submersão",
	TimerSubmerge		= "Exibir cronômetro para submersão",
	WarnEmerge			= "Exibir aviso para emersão",
	TimerEmerge			= "Exibir cronômetro para emersão"
}

----------------
-- AQ40 Trash --
----------------
L = DBM:GetModLocalization("AQ40Trash")

L:SetGeneralLocalization{
	name = "AQ40: Lixo"
}

-------------------
--  Venoxis  --
-------------------
L = DBM:GetModLocalization("Venoxis")

L:SetGeneralLocalization{
	name = "Sumo Sacerdote Venoxis"
}

-------------------
--  Jeklik  --
-------------------
L = DBM:GetModLocalization("Jeklik")

L:SetGeneralLocalization{
	name = "Alta-sacerdotisa Jeklik"
}

-------------------
--  Marli  --
-------------------
L = DBM:GetModLocalization("Marli")

L:SetGeneralLocalization{
	name = "Alta-sacerdotisa Mar'li"
}

-------------------
--  Thekal  --
-------------------
L = DBM:GetModLocalization("Thekal")

L:SetGeneralLocalization{
	name = "Sumo Sacerdote Thekal"
}

L:SetWarningLocalization({
	WarnSimulKill	= "Primeiro lacaio morto - ressurreição em ~ 15 segundos"
})

L:SetTimerLocalization({
	TimerSimulKill	= "Ressurreição"
})

L:SetOptionLocalization({
	WarnSimulKill	= "Anunciar o primeiro lacaio morto",
	TimerSimulKill	= "Mostrar a hora da ressurreição do sacerdote"
})

L:SetMiscLocalization({
	PriestDied	= "%s morre.",
	YellPhase2	= "Shirvallah! Me preenche com a tua fúria!",
	YellKill	= "Não sou mais prisioneiro de Hakkar! Enfim, paz!",
	Thekal		= "Sumo Sacerdote Thekal",
	Zath		= "Zelote Zath",
	LorKhan		= "Zelote Lor'Khan"
})

-------------------
--  Arlokk  --
-------------------
L = DBM:GetModLocalization("Arlokk")

L:SetGeneralLocalization{
	name = "Alta-sacerdotisa Arlokk"
}

-------------------
--  Hakkar  --
-------------------
L = DBM:GetModLocalization("Hakkar")

L:SetGeneralLocalization{
	name = "Hakkar"
}

-------------------
--  Bloodlord  --
-------------------
L = DBM:GetModLocalization("Bloodlord")

L:SetGeneralLocalization{
	name = "Sangrelorde Mandokir"
}
L:SetMiscLocalization{
	Bloodlord 	= "Sangrelorde Mandokir",
	Ohgan		= "Ohgan",
	GazeYell	= "Estou do olho em você"
}

-------------------
--  Edge of Madness  --
-------------------
L = DBM:GetModLocalization("EdgeOfMadness")

L:SetGeneralLocalization{
	name = "Beira da Loucura"
}
L:SetMiscLocalization{
	Hazzarah = "Hazza'rah",
	Renataki = "Renataki",
	Wushoolay = "Vuxulai",
	Grilek = "Gri'lek"
}

-------------------
--  Gahz'ranka  --
-------------------
L = DBM:GetModLocalization("Gahzranka")

L:SetGeneralLocalization{
	name = "Gahz'ranka"
}

-------------------
--  Jindo  --
-------------------
L = DBM:GetModLocalization("Jindo")

L:SetGeneralLocalization{
	name = "Jin'do, o Bagateiro"
}

-------------------
--  Venoxis  --
-------------------
L = DBM:GetModLocalization("Venoxis")

L:SetGeneralLocalization{
	name = "Sumo Sacerdote Venoxis"
}

-------------------
--  Jeklik  --
-------------------
L = DBM:GetModLocalization("Jeklik")

L:SetGeneralLocalization{
	name = "Alta-sacerdotisa Jeklik"
}

-------------------
--  Marli  --
-------------------
L = DBM:GetModLocalization("Marli")

L:SetGeneralLocalization{
	name = "Alta-sacerdotisa Mar'li"
}

-------------------
--  Thekal  --
-------------------
L = DBM:GetModLocalization("Thekal")

L:SetGeneralLocalization{
	name = "Sumo Sacerdote Thekal"
}

L:SetWarningLocalization({
	WarnSimulKill	= "Primeiro lacaio morto - ressurreição em ~ 15 segundos"
})

L:SetTimerLocalization({
	TimerSimulKill	= "Ressurreição"
})

L:SetOptionLocalization({
	WarnSimulKill	= "Anunciar o primeiro lacaio morto",
	TimerSimulKill	= "Mostrar a hora da ressurreição do sacerdote"
})

L:SetMiscLocalization({
	PriestDied	= "%s morre.",
	YellPhase2	= "Shirvallah! Me preenche com a tua fúria!",
	YellKill	= "Não sou mais prisioneiro de Hakkar! Enfim, paz!",
	Thekal		= "Sumo Sacerdote Thekal",
	Zath		= "Zelote Zath",
	LorKhan		= "Zelote Lor'Khan"
})

-------------------
--  Arlokk  --
-------------------
L = DBM:GetModLocalization("Arlokk")

L:SetGeneralLocalization{
	name = "Alta-sacerdotisa Arlokk"
}

-------------------
--  Hakkar  --
-------------------
L = DBM:GetModLocalization("Hakkar")

L:SetGeneralLocalization{
	name = "Hakkar"
}

-------------------
--  Bloodlord  --
-------------------
L = DBM:GetModLocalization("Bloodlord")

L:SetGeneralLocalization{
	name = "Sangrelorde Mandokir"
}
L:SetMiscLocalization{
	Bloodlord 	= "Sangrelorde Mandokir",
	Ohgan		= "Ohgan",
	GazeYell	= "Estou do olho em você"
}

-------------------
--  Edge of Madness  --
-------------------
L = DBM:GetModLocalization("EdgeOfMadness")

L:SetGeneralLocalization{
	name = "Beira da Loucura"
}
L:SetMiscLocalization{
	Hazzarah = "Hazza'rah",
	Renataki = "Renataki",
	Wushoolay = "Vuxulai",
	Grilek = "Gri'lek"
}

-------------------
--  Gahz'ranka  --
-------------------
L = DBM:GetModLocalization("Gahzranka")

L:SetGeneralLocalization{
	name = "Gahz'ranka"
}

-------------------
--  Jindo  --
-------------------
L = DBM:GetModLocalization("Jindo")

L:SetGeneralLocalization{
	name = "Jin'do, o Bagateiro"
}

-----------------
--  Razorgore  --
-----------------
L = DBM:GetModLocalization("Razorgore")

L:SetGeneralLocalization{
	name = "Violâminus, o Indomado"
}
L:SetTimerLocalization{
	TimerAddsSpawn	= "Primeiros lacaios"
}
L:SetOptionLocalization{
	TimerAddsSpawn	= "Exibir cronômetro para quando os primeiros lacaios aparecerem"
}
L:SetMiscLocalization{
	Phase2Emote	= "fogem à medida que o poder do orbe é drenado.",
	YellEgg1	= "Vocês pagarão caro por me forçarem a fazer isso!",
	YellEgg2	= "Tolos! Esses ovos são mais preciosos do que vocês imaginam!",
	YellEgg3	= "Não! Mais um, não! Cortarei suas cabeças por esta atrocidade!",
	YellPull	= "Invasores violaram a incubadora! Soem o alarme! Protejam os ovos a todo custo!"
}
-------------------
--  Vaelastrasz  --
-------------------
L = DBM:GetModLocalization("Vaelastrasz")

L:SetGeneralLocalization{
	name				= "Vaelastrasz, o Corrupto"
}

L:SetMiscLocalization{
	Event				= "É tarde demais, meus amigos! A corrupção de Nefarius se espalhou... não consigo... me controlar."
}
-----------------
--  Broodlord  --
-----------------
L = DBM:GetModLocalization("Broodlord")

L:SetGeneralLocalization{
	name	= "Prolemestre Flagelador"
}

L:SetMiscLocalization{
	Pull	= "Nenhum de vocês deveria estar aqui! Vocês condenaram somente a si mesmos!"
}

---------------
--  Firemaw  --
---------------
L = DBM:GetModLocalization("Firemaw")

L:SetGeneralLocalization{
	name = "Fogorja"
}

---------------
--  Ebonroc  --
---------------
L = DBM:GetModLocalization("Ebonroc")

L:SetGeneralLocalization{
	name = "Petrébano"
}

----------------
--  Flamegor  --
----------------
L = DBM:GetModLocalization("Flamegor")

L:SetGeneralLocalization{
	name = "Flamagor"
}

-----------------------
--  Vulnerabilities  --
-----------------------
-- Chromaggus, Death Talon Overseer and Death Talon Wyrmguard
L = DBM:GetModLocalization("TalonGuards")

L:SetGeneralLocalization{
	name = "Guarda Garra da Morte"
}
L:SetWarningLocalization{
	WarnVulnerable		= "Vulnerabilidade: %s"
}
L:SetOptionLocalization{
	WarnVulnerable		= "Exibir aviso de vulnerabilidades de feitiços"
}
L:SetMiscLocalization{
	Fire		= "Fogo",
	Nature		= "Natureza",
	Frost		= "Gelo",
	Shadow		= "Sombra",
	Arcane		= "Arcano",
	Holy		= "Sagrado"
}

------------------
--  Chromaggus  --
------------------
L = DBM:GetModLocalization("Chromaggus")

L:SetGeneralLocalization{
	name = "Cromaggus"
}
L:SetWarningLocalization{
	WarnBreath		= "%s",
	WarnVulnerable	= "Vulnerabilidade: %s"
}
L:SetTimerLocalization{
	TimerBreathCD	= "%s recarga",
	TimerBreath		= "%s lançamento",
	TimerVulnCD		= "Recarga de Vulnerabilidade"
}
L:SetOptionLocalization{
	WarnBreath		= "Exibir aviso quando Cromaggus lançar uma das suas respirações",
	WarnVulnerable	= "Exibir cronômetro para recarga da respiração",
	TimerBreathCD	= "Exibir recarga da respiração",
	TimerBreath		= "Exibir lançamento da respiração",
	TimerVulnCD		= "Exibir recarga de Vulnerabilidade"
}
L:SetMiscLocalization{
	Breath1	= "Primeira respiração",
	Breath2	= "Segunda respiração",
	VulnEmote	= "%s tem espasmos à medida que sua pele começa a brilhar.",
	Vuln		= "Vulnerabilidade",
	Fire		= "Fogo",
	Nature		= "Natureza",
	Frost		= "Gelo",
	Shadow		= "Sombra",
	Arcane		= "Arcano",
	Holy		= "Sagrado"
}

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization("Nefarian-Classic")

L:SetGeneralLocalization{
	name = "Nefarian"
}
L:SetWarningLocalization{
	WarnAddsLeft		= "%d restante",
	WarnClassCall		= "Chamada de %s",
	specwarnClassCall	= "Chamada da sua classe!"
}
L:SetTimerLocalization{
	TimerClassCall		= "Chamada de %s acaba"
}
L:SetOptionLocalization{
	TimerClassCall		= "Exibir cronômetro para duração da chamada em cada classe",
	WarnAddsLeft		= "Anunciar as mortes restantes até a Fase 2",
	WarnClassCall		= "Exibir aviso para chamadas de classe",
	specwarnClassCall	= "Exibir aviso especial quando afetado por chamada em classe"
}
L:SetMiscLocalization{
	YellP1		= "Que comecem os jogos!",
	YellP2		= "Muito bem, meus lacaios. A coragem dos mortais começa a vacilar! Agora vejamos como eles enfrentarão o verdadeiro Senhor dos Rocha Negra!!!",
	YellP3		= "Impossível! Ergam-se, meus lacaios! Sirvam ao seu mestre mais uma vez!",
	YellShaman	= "Xamãs, mostrem-me do que seus totens são capazes!",
	YellPaladin	= "Paladinos... ouvi dizer que vocês têm muitas vidas. Isso eu quero ver.",
	YellDruid	= "Druidas e suas metamorfoses idiotas. Vamos vê-las em ação!",
	YellPriest	= "Sacerdotes! Se vocês continuarem a curar desse jeito, acho que podemos tornar as coisas um pouquinho mais interessantes!",
	YellWarrior	= "Guerreiros, sei que vocês conseguem bater mais forte que isso! Vamos!",
	YellRogue	= "Ladinos? Parem de se esconder e venham me enfrentar!",
	YellWarlock	= "Bruxos, vocês não deveriam brincar com magias que não compreendem. Viram só o que acontece?",
	YellHunter	= "Caçadores e seus irritantes atiradores de ervilhas!",
	YellMage	= "Magos também? Vocês deveriam ter mais cuidado ao brincar com magia..."
}

----------------
--  Lucifron  --
----------------
L = DBM:GetModLocalization("Lucifron")

L:SetGeneralLocalization{
	name = "Lúcifron"
}

----------------
--  Magmadar  --
----------------
L = DBM:GetModLocalization("Magmadar")

L:SetGeneralLocalization{
	name = "Magmadar"
}

----------------
--  Gehennas  --
----------------
L = DBM:GetModLocalization("Gehennas")

L:SetGeneralLocalization{
	name = "Geena"
}

------------
--  Garr  --
------------
L = DBM:GetModLocalization("Garr-Classic")

L:SetGeneralLocalization{
	name = "Garr"
}

--------------
--  Geddon  --
--------------
L = DBM:GetModLocalization("Geddon")

L:SetGeneralLocalization{
	name = "Barão Geddon"
}

----------------
--  Shazzrah  --
----------------
L = DBM:GetModLocalization("Shazzrah")

L:SetGeneralLocalization{
	name = "Shazzrah"
}

----------------
--  Sulfuron  --
----------------
L = DBM:GetModLocalization("Sulfuron")

L:SetGeneralLocalization{
	name = "Emissário de Sulfuron"
}

----------------
--  Golemagg  --
----------------
L = DBM:GetModLocalization("Golemagg")

L:SetGeneralLocalization{
	name = "Golemagg, o Incinerador"
}

-----------------
--  Majordomo  --
-----------------
L = DBM:GetModLocalization("Majordomo")

L:SetGeneralLocalization{
	name = "Senescal Executus"
}
L:SetTimerLocalization{
	timerShieldCD		= "Próximo escudo"
}
L:SetOptionLocalization{
	timerShieldCD		= "Mostrar cronômetro para o próximo escudo de dano/reflexão"
}

----------------
--  Ragnaros  --
----------------
L = DBM:GetModLocalization("Ragnaros-Classic")

L:SetGeneralLocalization{
	name = "Ragnaros"
}
L:SetWarningLocalization{
	WarnSubmerge		= "Submersão",
	WarnEmerge			= "Emersão"
}
L:SetTimerLocalization{
	TimerSubmerge		= "Submersão",
	TimerEmerge			= "Emersão",
}
L:SetOptionLocalization{
	WarnSubmerge		= "Mostrar aviso para submersão",
	TimerSubmerge		= "Mostrar cronômetro para submersão",
	WarnEmerge			= "Mostrar aviso para emersão",
	TimerEmerge			= "Mostrar cronômetro para emersão",
}
L:SetMiscLocalization{
	Submerge	= "VENHAM, MEUS SERVOS! DEFENDAM SEU SENHOR!",
	Pull		= "Vermes abusados! Vocês se precipitaram para suas mortes! Vejam agora, o amo se agita!"
}

-----------------
--  MC: Trash  --
-----------------
L = DBM:GetModLocalization("MCTrash")

L:SetGeneralLocalization{
	name = "ND: Lixo"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name = "Onyxia"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "Dragonete Onyxiano em breve"
}

L:SetTimerLocalization{
	TimerWhelps	= "Dragonete Onyxiano"
}

L:SetOptionLocalization{
	TimerWhelps				= "Mostrar cronômetro para os seguintes Dragonetes Onyxiano",
	WarnWhelpsSoon			= "Mostrar aviso prévio para os seguintes Dragonetes Onyxiano",
	SoundWTF3				= "Reproduzir sons engraçados de um lendário raide clássico de Onyxia"
}

L:SetMiscLocalization{
	Breath = "%s respira fundo...",
	YellPull = "Que sorte. Geralmente costumo sair de minha caverna para poder me alimentar.",
	YellP2 = "Este esforço inútil me aborrece. Vou atear fogo em todos vocês do alto!",
	YellP3 = "Parece que vocês vão precisar de outra lição, mortais!"
}

-----------------
-- Anub'Rekhan --
-----------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "Anub'Rekhan"
})

L:SetWarningLocalization({
	SpecialLocust		= "Nuvem de Gafanhotos",
	WarningLocustFaded	= "Nuvem de Gafanhotos terminou"
})

L:SetOptionLocalization({
	SpecialLocust		= "Exibir aviso especial para $spell:28785",
	WarningLocustFaded	= "Exibir aviso cuando termina $spell:28785",
	ArachnophobiaTimer	= "Exibir cronômetro para a conquista 'Aracnofobia'"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Conquista: Aracnofobia",
	Pull1				= "¡Eso, corred! ¡Así la sangre circula más rápido!",
	Pull2				= "Solo un bocado..."
})

-------------------------
-- Gran Viuda Faerlina --
-------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "Grã-viúva Faerlina"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "Abraço da Viúva expirando em 5 s",
	WarningEmbraceExpired	= "Abraço da Viúva expirou"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "Exibir aviso prévio para quando expira Abraço da Viúva",
	WarningEmbraceExpired	= "Exibir aviso cuando expira Abraço da Viúvaex"
})

L:SetMiscLocalization({
	Pull					= "¡Arrodíllate ante mí, sabandija!"--Not actually pull trigger, but often said on pull
})

-------------
-- Maexxna --
-------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name = "Maexxna"
})

L:SetWarningLocalization({
	WarningSpidersSoon	= "Prole de Maexxna em 5 s",
	WarningSpidersNow	= "Proles de Maexxna"
})

L:SetTimerLocalization({
	TimerSpider	= "Próximos proles"
})

L:SetOptionLocalization({
	WarningSpidersSoon	= "Exibir aviso prévio para quando os Proles de Maexxna aparecerem",
	WarningSpidersNow	= "Exibir aviso quando Proles de Maexxna aparecem",
	TimerSpider			= "Exibir cronômetro para os seguintes Proles de Maexxna"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Conquista: Aracnofobia"
})

-----------------------
-- Noth el Pesteador --
-----------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name = "Noth, o Pestífero"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teleporte",
	WarningTeleportSoon	= "Teleporte em 20 s"
})

L:SetTimerLocalization({
	TimerTeleport		= "Teleporte: Sacada",
	TimerTeleportBack	= "Teleporte: Chão"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Exibir aviso para Teleporte",
	WarningTeleportSoon	= "Exibir aviso prévio para Teleporte",
	TimerTeleport		= "Exibir cronômetro para o próximo Teleporte: Sacada",
	TimerTeleportBack	= "Exibir cronômetro para Teleporte: Chão"
})

L:SetMiscLocalization({
	Pull				= "¡Muere, intruso!"
})

----------------------
-- Heigan el Impuro --
----------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name = "Heigan, o Sujo"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teleporte",
	WarningTeleportSoon	= "Teleporte em %d s"
})

L:SetTimerLocalization({
	TimerTeleport	= "Teleporte"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Exibir aviso para Teleporte",
	WarningTeleportSoon	= "Exibir aviso prévio para Teleporte",
	TimerTeleport		= "Exibir aviso para Teleporte"
})

L:SetMiscLocalization({
	Pull				= "Ahora me perteneces."
})

-------------
-- Loatheb --
-------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name = "Repugnaz"
})

L:SetWarningLocalization({
	WarningHealSoon	= "Cura possível em 3 s",
	WarningHealNow	= "Cure agora!"
})

L:SetOptionLocalization({
	WarningHealSoon		= "Exibir aviso prévio para janela de cura de 3 segundos",
	WarningHealNow		= "Exibir aviso prévio para janela de cura"
})

---------------
-- Retalhoso --
---------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name = "Retalhoso"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1 = "¡Remendejo quiere jugar!",
	yell2 = "¡Remendejo es la encarnación de guerra de Kel'Thuzad!"
})

---------------
-- Grobbulus --
---------------
L = DBM:GetModLocalization("Grobbulus")

L:SetGeneralLocalization({
	name = "Grobbulus"
})

-----------
-- Gluth --
-----------
L = DBM:GetModLocalization("Gluth")

L:SetGeneralLocalization({
	name = "Gluth"
})

--------------
-- Thaddius --
--------------
L = DBM:GetModLocalization("Thaddius")

L:SetGeneralLocalization({
	name = "Thaddius"
})

L:SetMiscLocalization({
	Yell	= "¡Stalagg aplasta!",
	Emote	= "¡%s se sobrecarga!",
	Emote2	= "¡Espiral Tesla se sobrecarga!",
	Boss1	= "Feugen",
	Boss2	= "Stalagg",
	Charge1 = "negativo",
	Charge2 = "positivo"
})

L:SetOptionLocalization({
	WarningChargeChanged	= "Exibir aviso especial quando sua polaridade mudar",
	WarningChargeNotChanged	= "Exibir aviso especial quando sua polaridade não mudar",
	AirowsEnabled			= "Exibir setas (estratégia típica de dois grupos)",
	ArrowsRightLeft			= "Exibe as setas para a esquerda e direita (estratégia de quatro grupos; mostra a seta para a esquerda se a polaridade mudar, seta para a direita se não mudar)",
	ArrowsInverse			= "Exibe as setas esquerda e direita reversas (estratégia de quatro grupos; mostra a seta para a direita se a polaridade mudar, a seta para a esquerda se não mudar)"
})

L:SetWarningLocalization({
	WarningChargeChanged	= "Polaridade alterada para %s",
	WarningChargeNotChanged	= "Sua polaridade não mudou"
})

--------------------------
-- Instructor Razuvious --
--------------------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name = "Instrutor Razúvio"
})

L:SetMiscLocalization({
	Yell1 = "¡No tengáis piedad!",
	Yell2 = "¡El tiempo de practicar ha pasado! ¡Quiero ver lo que habéis aprendido!",
	Yell3 = "¡Poned en práctica lo que os he enseñado!",
	Yell4 = "Un barrido con pierna... ¿Tienes algún problema?"
})

L:SetOptionLocalization({
	WarningShieldWallSoon	= "Exibir aviso prévio para quando termina $spell:29061"
})

L:SetWarningLocalization({
	WarningShieldWallSoon	= "Barreira de ossos termina em 5 s"
})

--------------------------
-- Gothik el Cosechador --
--------------------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name = "Gothik, o Ceifador"
})

L:SetOptionLocalization({
	TimerWave			= "Exibir cronômetro para a próxima onda de lacaios",
	TimerPhase2			= "Exibir cronômetro para mudar para a Fase 2",
	WarningWaveSoon		= "Exibir aviso prévio para a próxima onda de lacaios",
	WarningWaveSpawned	= "Exibir aviso quando uma onda de lacaios começar",
	WarningRiderDown	= "Exibir aviso quando um Cavalgante Implacável morre",
	WarningKnightDown	= "Exibir aviso quando um Cavaleiro da Morte Implacável morre"
})

L:SetTimerLocalization({
	TimerWave	= "Onda %d",
	TimerPhase2	= "Fase 2"
})

L:SetWarningLocalization({
	WarningWaveSoon		= "Onda %d: %s em 3 s",
	WarningWaveSpawned	= "Onda %d: %s",
	WarningRiderDown	= "Cavalgante morto",
	WarningKnightDown	= "Cavaleiro morto",
	WarningPhase2		= "Fase 2"
})

L:SetMiscLocalization({
	yell			= "Tú mismo has buscado tu final.",
	WarningWave1	= "%d %s",
	WarningWave2	= "%d %s y %d %s",
	WarningWave3	= "%d %s, %d %s y %d %s",
	Trainee			= "Aprendiz",
	Knight			= "Cavaleiro",
	Rider			= "Cavalgante"
})

------------------------
-- Os Quatro Cavaleiros --
------------------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name = "Os Quatro Cavaleiros"
})

L:SetOptionLocalization({
	WarningMarkSoon				= "Exibir aviso prévio para marcas",
	SpecialWarningMarkOnPlayer	= "Exibir um aviso especial quando você for afetado por mais de quatro marcas"
})

L:SetTimerLocalization({
})

L:SetWarningLocalization({
	WarningMarkSoon				= "Marca %d em 3 s",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz	= "Thane Korth'azz",
	Rivendare	= "Barão Rivendare",
	Blaumeux	= "Lady Blaumeux",
	Zeliek		= "Sir Zeliek"
})

---------------
-- Sapphiron --
---------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name = "Sapphiron"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon	= "Exibir aviso prévio para mudança de fase de ar",
	WarningAirPhaseNow	= "Anunciar mudança para fase de ar",
	WarningLanded		= "Anunciar mudança de fase no solo",
	TimerAir			= "Exibir cronômetro para mudança para fase de ar",
	TimerLanding		= "Exibir cronômetro para mudança de fase no terra",
	TimerIceBlast		= "Exibir cronômetro para $spell:28524",
	WarningDeepBreath	= "Exibir aviso especial para $spell:28524",
	WarningIceblock		= "Grite quando te afeta $spell:28522"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s respira hondo.",
	WarningYellIceblock	= "Eu sou um bloco de gelo!"
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "Fase aérea em 10 s",
	WarningAirPhaseNow	= "Fase aérea",
	WarningLanded		= "Fase em terra",
	WarningDeepBreath	= "Sopro Gélido"
})

L:SetTimerLocalization({
	TimerAir		= "Fase aérea",
	TimerLanding	= "Fase em terra",
	TimerIceBlast	= "Sopro Gélido"
})

----------------
-- Kel'Thuzad --
----------------

L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name = "Kel'Thuzad"
})

L:SetOptionLocalization({
	TimerPhase2			= "Exibir cronômetro para mudar para a Fase 2",
	specwarnP2Soon		= "Exibir aviso especial 10 s antes de mudar para a Fase 2",
	warnAddsSoon		= "Exibir aviso prévio para quando os Guardiões da Coroa de Gelo aparecerem"
})

L:SetMiscLocalization({
	Yell = "¡Esbirros, sirvientes, soldados de la fría oscuridad! ¡Obedeced la llamada de Kel'Thuzad!"
})

L:SetWarningLocalization({
	specwarnP2Soon	= "Fase 2 em 10 s",
	warnAddsSoon	= "Guardiões da Coroa de Gelo em breve"
})

L:SetTimerLocalization({
	TimerPhase2	= "Fase 2"
})
