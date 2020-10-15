if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

------------
-- Skeram --
------------
L = DBM:GetModLocalization("Skeram")

L:SetGeneralLocalization{
	name = "El profeta Skeram"
}

----------------
-- Three Bugs --
----------------
L = DBM:GetModLocalization("ThreeBugs")

L:SetGeneralLocalization{
	name = "Realeza silítida"
}
L:SetMiscLocalization{
	Yauj = "Princesa Yauj",
	Vem = "Vem",
	Kri = "Lord Kri"
}

-------------
-- Sartura --
-------------
L = DBM:GetModLocalization("Sartura")

L:SetGeneralLocalization{
	name = "Guardia de batalla Sartura"
}

--------------
-- Fankriss --
--------------
L = DBM:GetModLocalization("Fankriss")

L:SetGeneralLocalization{
	name = "Fankriss el Implacable"
}

--------------
-- Viscidus --
--------------
L = DBM:GetModLocalization("Viscidus")

L:SetGeneralLocalization{
	name = "Viscidus"
}
L:SetWarningLocalization{
	WarnFreeze	= "Freeze: %d/3",
	WarnShatter	= "Shatter: %d/3"
}
L:SetOptionLocalization{
	WarnFreeze	= "Announce Freeze status",
	WarnShatter	= "Announce Shatter status"
}
L:SetMiscLocalization{
	Slow	= "comienza a ir más despacio!",
	Freezing= "se está congelando!",
	Frozen	= "no se puede mover!",
	Phase4 	= "comienza a desmoronarse!",
	Phase5 	= "parece a punto de hacerse añicos!",
	Phase6 	= "explota"--Might want to double check this, since no further messages appeared after the previous one.
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
	name = "Los Emperadores Gemelos"
}
L:SetMiscLocalization{
	Veklor = "Emperor Vek'lor",
	Veknil = "Emperor Vek'nilash"
}

------------
-- C'Thun --
------------
L = DBM:GetModLocalization("CThun")

L:SetGeneralLocalization{
	name = "C'Thun"
}
L:SetWarningLocalization{
	WarnEyeTentacle			= "Tentáculo ocular",
	WarnClawTentacle2		= "Tentáculo Garral",
	WarnGiantEyeTentacle	= "Tentáculo ocular gigante",
	WarnGiantClawTentacle	= "Tentáculo garral gigante",
	WarnWeakened			= "C'Thun débil",
	SpecWarnWeakened		= "¡C'Thun está débil!"
}
L:SetTimerLocalization{
	TimerEyeTentacle		= "Siguiente Tentáculo ocular",
	TimerClawTentacle		= "Siguiente Tentáculo Garral",
	TimerGiantEyeTentacle	= "Siguiente Tentáculo ocular gigante",
	TimerGiantClawTentacle	= "Siguiente Tentáculo garral gigante",
	TimerWeakened			= "Debilidad termina"
}
L:SetOptionLocalization{
	WarnEyeTentacle			= "Mostrar aviso cuando aparezca un Tentáculo ocular",
	WarnClawTentacle2		= "Mostrar aviso cuando aparezca un Tentáculo Garral",
	WarnGiantEyeTentacle	= "Mostrar aviso cuando aparezca un Tentáculo ocular gigante",
	WarnGiantClawTentacle	= "Mostrar aviso cuando aparezca un Tentáculo garral gigante",
	WarnWeakened			= "Mostrar aviso cuando C'Thun se vuelva débil",
	SpecWarnWeakened		= "Mostrar aviso especial cuando C'Thun se vuelva débil",
	TimerEyeTentacle		= "Mostrar temporizador para el siguiente Tentáculo ocular",
	TimerClawTentacle		= "Mostrar temporizador para el siguiente Tentáculo Garral",
	TimerGiantEyeTentacle	= "Mostrar temporizador para el siguiente Tentáculo ocular gigante",
	TimerGiantClawTentacle	= "Mostrar temporizador para el siguiente Tentáculo garral gigante",
	TimerWeakened			= "Mostrar temporizador para la duración de la debilidad de C'Thun",
	RangeFrame				= "Mostrar marco de distancia (10 m)"
}
L:SetMiscLocalization{
	Stomach		= "Estómago de C'Thun",
	Eye			= "Ojo de C'Thun",
	FleshTent	= "Tentáculo de carne",
	Weakened 	= "está débil!",
	NotValid	= "AQ40 parcialmente limpiado. Quedan %s jefes opcionales."
}
----------------
-- Ouro --
----------------
L = DBM:GetModLocalization("Ouro")

L:SetGeneralLocalization{
	name = "Ouro"
}
L:SetWarningLocalization{
	WarnSubmerge		= "Ouro ha regresado",
	WarnEmerge			= "Ouro se sumerge"
}
L:SetTimerLocalization{
	TimerSubmerge		= "Sumersión",
	TimerEmerge			= "Emersión"
}
L:SetOptionLocalization{
	WarnSubmerge		= "Mostrar aviso cuando Ouro se sumerja",
	TimerSubmerge		= "Mostrar temporizador para cuando Ouro se sumerja",
	WarnEmerge			= "Mostrar aviso cuando Ouro regrese a la superficie",
	TimerEmerge			= "Mostrar temporizador para cuando Ouro regrese a la superficie"
}
