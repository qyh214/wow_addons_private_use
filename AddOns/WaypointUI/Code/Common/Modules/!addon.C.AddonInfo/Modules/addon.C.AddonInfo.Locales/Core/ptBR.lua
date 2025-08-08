-- ♡ Translation // cathtail
-- Tradutora @cathtail

---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.ptBR = {}
local NS = L.ptBR; L.ptBR = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "ptBR" then
		return
	end

	--------------------------------
	-- GENERAL
	--------------------------------

	do

	end

	--------------------------------
	-- WAYPOINT SYSTEM
	--------------------------------

	do
		-- PINPOINT
		L["WaypointSystem - Pinpoint - Quest - Complete"] = "Pronto para entregar"
	end

	--------------------------------
	-- SLASH COMMAND
	--------------------------------

	do
		L["SlashCommand - /way - Map ID - Prefix"] = "ID do mapa atual: "
		L["SlashCommand - /way - Map ID - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (X) - Prefix"] = "X: "
		L["SlashCommand - /way - Position - Axis (X) - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (Y) - Prefix"] = ", Y: "
		L["SlashCommand - /way - Position - Axis (Y) - Suffix"] = ""
	end

	--------------------------------
	-- CONFIG
	--------------------------------

	do
		L["Config - General"] = "Geral"
		L["Config - General - Title"] = "Geral"
		L["Config - General - Title - Subtext"] = "Personalize as configurações em geral."
		L["Config - General - Preferences"] = "Preferências"
		L["Config - General - Preferences - Meter"] = "Use metros em vez de jardas."
		L["Config - General - Preferences - Meter - Description"] = "Altera a unidade de medida para o sistema métrico."
		L["Config - General - Preferences - Font"] = "Fonte"
		L["Config - General - Preferences - Font - Description"] = "A fonte usada em todo o addon."
		L["Config - General - Reset"] = "Redefinir"
		L["Config - General - Reset - Button"] = "Redefinir pro padrão"
		L["Config - General - Reset - Confirm"] = "Tem certeza que desejar redefinir todas as configurações?"
		L["Config - General - Reset - Confirm - Yes"] = "Confirmar"
		L["Config - General - Reset - Confirm - No"] = "Cancelar"

		L["Config - WaypointSystem"] = "Marcador de Mapa"
		L["Config - WaypointSystem - Title"] = "Marcador de Mapa"
		L["Config - WaypointSystem - Title - Subtext"] = "Gerencie o marcador de mapa e o indicador de objetivo."
		L["Config - WaypointSystem - Type"] = "Habilitar"
		L["Config - WaypointSystem - Type - Both"] = "Tudo"
		L["Config - WaypointSystem - Type - Waypoint"] = "Marcador de Mapa"
		L["Config - WaypointSystem - Type - Pinpoint"] = "Marcador Preciso"
		L["Config - WaypointSystem - General"] = "Geral"
		L["Config - WaypointSystem - General - RightClickToClear"] = "Right-Click To Clear"
		L["Config - WaypointSystem - General - RightClickToClear - Description"] = "Allows you to clear the Waypoint/Pinpoint/Navigator by right-clicking it."
		L["Config - WaypointSystem - General - Transition Distance"] = "Distância do Marcador Preciso"
		L["Config - WaypointSystem - General - Transition Distance - Description"] = "Distância antes do Marcador Preciso ser exibido."
		L["Config - WaypointSystem - General - Hide Distance"] = "Distância Mínima"
		L["Config - WaypointSystem - General - Hide Distance - Description"] = "Distância até que seja oculto."
		L["Config - WaypointSystem - Waypoint"] = "Marcador de Mapa"
		L["Config - WaypointSystem - Waypoint - Footer - Type"] = "Informação adicional"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Both"] = "Tudo"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Distance"] = "Distância"
		L["Config - WaypointSystem - Waypoint - Footer - Type - ETA"] = "Tempo de chegada"
		L["Config - WaypointSystem - Waypoint - Footer - Type - None"] = "Nenhum"
		L["Config - WaypointSystem - Pinpoint"] = "Marcador Preciso"
		L["Config - WaypointSystem - Pinpoint - Info"] = "Mostrar informações"
		L["Config - WaypointSystem - Pinpoint - Info - Extended"] = "Mostrar dados detalhados"
		L["Config - WaypointSystem - Pinpoint - Info - Extended - Description"] = "Tal qual nome e descrição."
		L["Config - WaypointSystem - Navigator"] = "Navegador"
		L["Config - WaypointSystem - Navigator - Enable"] = "Mostrar"
		L["Config - WaypointSystem - Navigator - Enable - Description"] = "Quando o marcador de mapa ou preciso estiver fora da tela, o navegador indicará a direção."

		L["Config - Appearance"] = "Aparência"
		L["Config - Appearance - Title"] = "Aparência"
		L["Config - Appearance - Title - Subtext"] = "Personalize a aparência da interface do usuário."
		L["Config - Appearance - Waypoint"] = "Marcador de Mapa"
		L["Config - Appearance - Waypoint - Scale"] = "Tamanho"
		L["Config - Appearance - Waypoint - Scale - Description"] = "O tamanho muda com base na distância. Esta opção define o tamanho geral."
		L["Config - Appearance - Waypoint - Scale - Min"] = "% Mínima"
		L["Config - Appearance - Waypoint - Scale - Min - Description"] = "Tamanho mínimo."
		L["Config - Appearance - Waypoint - Scale - Max"] = "% Máxima"
		L["Config - Appearance - Waypoint - Scale - Max - Description"] = "Tamanho máximo."
		L["Config - Appearance - Waypoint - Beam"] = "Exibir feixe de luz"
		L["Config - Appearance - Waypoint - Beam - Alpha"] = "Transparência"
		L["Config - Appearance - Waypoint - Footer"] = "Mostrar texto com informações"
		L["Config - Appearance - Waypoint - Footer - Scale"] = "Tamanho"
		L["Config - Appearance - Waypoint - Footer - Alpha"] = "Transparência"
		L["Config - Appearance - Pinpoint"] = "Marcador Preciso"
		L["Config - Appearance - Pinpoint - Scale"] = "Tamanho"
		L["Config - Appearance - Navigator"] = "Navegador"
		L["Config - Appearance - Navigator - Scale"] = "Tamanho"
		L["Config - Appearance - Navigator - Alpha"] = "Transparência"
		L['Config - Appearance - Navigator - Distance'] = "Distance"
		L["Config - Appearance - Visual"] = "Visual"
		L["Config - Appearance - Visual - UseCustomColor"] = "Usar cor personalizada"
		L["Config - Appearance - Visual - UseCustomColor - Color"] = "Cor"
		L["Config - Appearance - Visual - UseCustomColor - TintIcon"] = "Ícone colorido"
		L["Config - Appearance - Visual - UseCustomColor - Reset"] = "Redefinir"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Default"] = "Missão normal"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Repeatable"] = "Missão repetível"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Important"] = "Missão importante"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Incomplete"] = "Missão incompleta"
		L["Config - Appearance - Visual - UseCustomColor - Neutral"] = "Marcador de Mapa genérico"

		L["Config - Audio"] = "Áudio"
		L["Config - Audio - Title"] = "Áudio"
		L["Config - Audio - Title - Subtext"] = "Configuração dos efeitos sonoros do  Waypoint UI."
		L["Config - Audio - General"] = "Geral"
		L["Config - Audio - General - EnableGlobalAudio"] = "Habilitar áudio"
		L["Config - Audio - Customize"] = "Personalizar"
		L["Config - Audio - Customize - UseCustomAudio"] = "Usar áudio personalizado"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID"] = "ID do áudio"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"] = "ID personalizado"
		L["Config - Audio - Customize - UseCustomAudio - Preview"] = "Prévia"
		L["Config - Audio - Customize - UseCustomAudio - Reset"] = "Redefinir"
		L["Config - Audio - Customize - UseCustomAudio - WaypointShow"] = "Exibir marcador de mapa"
		L["Config - Audio - Customize - UseCustomAudio - PinpointShow"] = "Exibir marcador preciso"

		L["Config - About"] = "Sobre"
		L["Config - About - Contributors"] = "Contribuidores"
		L["Config - About - Developer"] = "Desenvolvedor"
		L["Config - About - Developer - AdaptiveX"] = "AdaptiveX"
	end

	--------------------------------
	-- CONTRIBUTORS
	--------------------------------

	do
		L["Contributors - cathtail"] = "cathtail"
		L["Contributors - cathtail - Description"] = "Tradutora — Português Brasileiro"
		L["Contributors - ZamestoTV"] = "ZamestoTV"
		L["Contributors - ZamestoTV - Description"] = "Tradutor — Russo"
		L["Contributors - huchang47"] = "huchang47"
		L["Contributors - huchang47 - Description"] = "Tradutor — Chinês (Simplificado)"
		L["Contributors - BlueNightSky"] = "BlueNightSky"
		L["Contributors - BlueNightSky - Description"] = "Tradutor — Chinês (Tradicional)"
		L["Contributors - Crazyyoungs"] = "Crazyyoungs"
		L["Contributors - Crazyyoungs - Description"] = "Tradutor — Coreano"
		L["Contributors - Klep"] = "Klep"
		L["Contributors - Klep - Description"] = "Tradutor — Francês"
		L["Contributors - Kroffy"] = "Kroffy"
		L["Contributors - Kroffy - Description"] = "Tradutor — Francês"
		L["Contributors - Larsj02"] = "Larsj02"
		L["Contributors - Larsj02 - Description"] = "Tradutor — Alemão"
		L["Contributors - dabear78"] = "dabear78"
		L["Contributors - dabear78 - Description"] = "Tradutor — Alemao"
		L["Contributors - y45853160"] = "y45853160"
		L["Contributors - y45853160 - Description"] = "Code — Beta Bug Fix"
		L["Contributors - lemieszek"] = "lemieszek"
		L["Contributors - lemieszek - Description"] = "Code — Beta Bug Fix"
		L["Contributors - BadBoyBarny"] = "BadBoyBarny"
		L["Contributors - BadBoyBarny - Description"] = "Code — Bug Fix"
		L["Contributors - SyverGiswold"] = "SyverGiswold"
		L["Contributors - SyverGiswold - Description"] = "Code - Feature"
	end
end

NS:Load()
