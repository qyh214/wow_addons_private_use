if not ACP then return end

--@non-debug@

if (GetLocale() == "esMX") then
	ACP:UpdateLocale(

{
	["*** Enabling <%s> %s your UI ***"] = "*** Activando <%s> %s su IU ***",
	["*** Unknown Addon <%s> Required ***"] = "*** Addon desconocido <%s> requerido ***",
	["ACP: Some protected addons aren't loaded. Reload now?"] = "ACP: Algunos Addons protegidos no se encuentran cargados. ¿Recargar ahora?",
	["Active Embeds"] = "Integración activa",
	["Add to current selection"] = "Añadir a la selección actual",
	["Addon <%s> not valid"] = "Addon <%s> incorrecto",
	["AddOns"] = "Addons",
	["Addons [%s] Loaded."] = "Addons [%s] cargados.",
	["Addons [%s] renamed to [%s]."] = "Addons [%s] renombrados a [%s].",
	["Addons [%s] Saved."] = "Addons [%s] guardados.",
	["Addons [%s] Unloaded."] = "Addons [%s] descargados.",
	["Author"] = "Autor",
	["Blizzard_AchievementUI"] = "Blizzard: Logros",
	["Blizzard_AuctionUI"] = "Blizzard: Subasta",
	["Blizzard_BarbershopUI"] = "Blizzard: Barbería",
	["Blizzard_BattlefieldMinimap"] = "Blizzard: Minimapa del campo de batalla",
	["Blizzard_BindingUI"] = "Blizzard: Asignación",
	["Blizzard_Calendar"] = "Blizzard: Calendario",
	["Blizzard_CombatLog"] = "Blizzard: Registro de combate",
	["Blizzard_CombatText"] = "Blizzard: Texto de combate",
	["Blizzard_FeedbackUI"] = "Blizzard: Comentarios",
	["Blizzard_GlyphUI"] = "Blizzard: Glifo",
	["Blizzard_GMSurveyUI"] = "Blizzard: Ayuda MJ",
	["Blizzard_GuildBankUI"] = "Blizzard: Banco de hermandad",
	["Blizzard_InspectUI"] = "Blizzard: Inspección",
	["Blizzard_ItemSocketingUI"] = "Blizzard: Huecos de gemas",
	["Blizzard_MacroUI"] = "Blizzard: Macro",
	["Blizzard_RaidUI"] = "Blizzard: Banda",
	["Blizzard_TalentUI"] = "Blizzard: Talento",
	["Blizzard_TimeManager"] = "Blizzard: Administrador de tiempo",
	["Blizzard_TokenUI"] = "Blizzard: Ficha",
	["Blizzard_TradeSkillUI"] = "Blizzard: Profesión",
	["Blizzard_TrainerUI"] = "Blizzard: Instructor",
	["Blizzard_VehicleUI"] = "Blizzard: Vehículo",
	["Click to enable protect mode. Protected addons will not be disabled"] = "Clic para activar el modo protegido. Los Addons protegidos no serán deshabilitados.",
	["Close"] = "Cerrar",
	["Default"] = "Por defecto",
	["Dependencies"] = "Dependencias",
	["Disable All"] = "Desact. todo",
	["Disabled on reloadUI"] = "Desactivar al recargar IU",
	["Embeds"] = "Inclusiones",
	["Enable All"] = "Activ. todo",
	["Enter the new name for [%s]:"] = "Escriba el nuevo nombre para [%s]:",
	["Load"] = "Cargar",
	["Loadable OnDemand"] = "Cargable a demanda",
	["Loaded"] = "Cargado",
	["Loaded on demand."] = "Cargar a demanda.",
	["LoD Child Enable is now %s"] = "Carga a demanda de dependientes está ahora %s",
	["Memory Usage"] = "Uso de memoria",
	["No information available."] = "No hay información disponible.",
	["Recursive"] = "Repetir indef.",
	["Recursive Enable is now %s"] = "La activación \"Repetir indef.\" está ahora %s",
	["Reload"] = "Recargar",
	["Reload your User Interface?"] = "¿Recargar la interfaz de usuario?",
	["ReloadUI"] = "Recargar IU",
	["Remove from current selection"] = "Eliminar de la selección actual",
	["Rename"] = "Renombrar",
	--[[Translation missing --]]
	--[[ ["Resurse-ToolTip"] = "",--]] 
	["Save"] = "Guardar",
	["Save the current addon list to [%s]?"] = "¿Guardar la lista actual de Addons en [%s]?",
	["Set "] = "Establecido",
	["Sets"] = "Perf.",
	["Status"] = "Estado",
	["Use SHIFT to override the current enabling of dependancies behaviour."] = "Utilice Shift para remplazar el comportamiento de activación de dependencias actual.",
	["Version"] = "Versión",
	["when performing a reloadui."] = "cuando realice \"Recargar IU\"."
}

    )
end

--@end-non-debug@
