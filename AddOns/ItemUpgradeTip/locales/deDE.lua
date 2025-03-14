-- ItemUpgradeTip Locale
-- Please use the Localization App on CurseForge to update this
-- https://legacy.curseforge.com/wow/addons/itemupgradetip/localization

-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string

---@type Localizations?
local L = LibStub("AceLocale-3.0"):NewLocale(AddOnFolderName, "deDE", false)

if not L then
    return
end

L["ANIMA_UPGRADES"] = "Anima Aufwertungen"
L["ASPECT_CRESTS"] = "Wappen des Aspekts"
L["ASPECT_CRESTS_SHORT"] = "Aspekt"
L["AUTHOR"] = "Author"
L["BOSS"] = "Boss"
L["BOSS_X"] = "Boss #%s"
L["BUG_REPORT_SUGGEST"] = "Fehlerbericht / Featurevorschlag"
L["BUG_REPORT_SUGGEST_TOOLTIP"] = "Melde einen Fehler oder einen Verbesserungsvorschlag via GitHub"
L["CARVED_CRESTS"] = "Geschnitztes Vorbotenwappen"
L["CARVED_CRESTS_SHORT"] = "Geschnitzt"
L["COMPACT_TOOLTIPS"] = "Kompakte Tooltips"
L["COMPACT_TOOLTIPS_DESC"] = "Wenn diese Option aktiviert ist, verwenden kompatible Tooltip-Integrationen ein kompakteres Format, anstatt die vollständigen Upgrade-Informationen anzuzeigen."
L["CONQUEST_UPGRADES"] = "Eroberungs Aufwertungen"
L["CONTACT"] = "Kontakt"
L["COST_FOR_NEXT_LEVEL"] = "Kosten für die nächste Stufe:"
L["COST_TO_UPGRADE_TO_MAX"] = "Kosten um auf die maximal Stufe aufzuwerten:"
L["CRAFTING"] = "Herstellen"
L["CRAFTING_TITLE"] = "ItemUpgradeTip - Crafting"
L["CREST_TYPE"] = "Wappen Typ"
L["CURRENCY_NEEDED_FOR_MAX"] = "Für die maximal Stufe benötigte Währung:"
L["CURRENCY_REMAINING_AFTER_UPGRADING"] = "Verbleibende Währung nach dem Aufwerten:"
L["DISABLED_INTEGRATIONS"] = "Integration deaktivieren"
L["DISABLED_INTEGRATIONS_DESC"] = "Falls bestimmte Tooltip-Integrationen deaktiviert werden sollen, kann dies über die folgenden Optionen gemacht werden."
L["DRAKE_CRESTS"] = "Wappen des Drachen"
L["DRAKE_CRESTS_SHORT"] = "Drachen"
L["FLIGHTSTONE_CREST_UPGRADES"] = "Flugstein / Wappen Aufwertung"
L["FLIGHTSTONES"] = "Flugsteine"
L["GENERAL"] = "Allgemein"
L["GILDED_CRESTS"] = "Vergoldetes Vorbotenwappen"
L["GILDED_CRESTS_SHORT"] = [=[Vergoldet
]=]
L["HEIRLOOM_UPGRADES"] = "Erbstückaufwertungen"
L["HEROIC"] = "Heroisch"
L["HONOR_UPGRADES"] = "Ehren Aufwertungen"
L["INFO"] = "Info"
L["INFO_TITLE"] = "ItemUpgradeTip - Info"
L["ITEM_CAN_BE_UPGRADED_TO_MAX"] = "Gegenstand kann auf die maximal Stufe aufgewertet werden!"
L["ITEM_LEVEL"] = "Item Level"
L["ITEM_UPGRADED_TO_MAX"] = "Gegenstand auf maximal Stufe aufgewertet!"
L["KEY_LEVEL"] = "Schlüsselsteinstufe"
L["LEFT_CLICK"] = "Linksklick"
L["LEFT_CLICK_DESC"] = "um das Aufwertungshelfer Fenster zu öffnen"
L["LFR"] = "LFR"
L["LOOT_DROPS"] = "Beute"
L["MAX_UPGRADE_X"] = "Max. Aufwertung (%d):"
L["MODIFIER_KEY"] = "Modifikatortaste"
L["MODIFIER_KEY_DESC"] = "Falls aktiviert, muss diese Taste gedrückt gehalten werden, damit die Tooltip-Integration angezeigt wird."
L["MYTHIC"] = "Mythisch"
L["MYTHICPLUS"] = "Mythisch+"
L["MYTHICPLUS_TITLE"] = "ItemUpgradeTip - Mythisch+"
L["NEXT_UPGRADE_X"] = "Nächste Aufwertung (%d):"
L["NORMAL"] = "Normal"
L["RAID"] = "Schlachtzug"
L["RAID_TITLE"] = "ItemUpgradeTip - Schlachtzug"
L["RANK"] = "Rang"
L["REQUIRED_ITEM"] = "Erforderlicher Gegenstand"
L["RIGHT_CLICK"] = "Rechtsklick"
L["RIGHT_CLICK_DESC"] = "um die Einstellungen zu öffnen"
L["RUNED_CRESTS"] = "Runenverziertes Vorbotenwappen"
L["RUNED_CRESTS_SHORT"] = "Runenverziert"
L["UPGRADE_LEVEL_X_Y"] = "Aufwertungsstufe: %d / %d"
L["UPGRADE_TRACK_ADVENTURER"] = "Abenteurer"
L["UPGRADE_TRACK_AWAKENED"] = "Erweckt"
L["UPGRADE_TRACK_CHAMPION"] = "Champion"
L["UPGRADE_TRACK_HERO"] = "Held"
L["UPGRADE_TRACK_MYTH"] = "Mythos"
L["UPGRADE_TRACK_VETERAN"] = "Veteran"
L["UPGRADE_TRACKS"] = "Aufwertungstabelle"
L["UPGRADE_TRACKS_TITLE"] = "ItemUpgradeTip - Aufwertungstabelle"
L["VALORSTONE_CREST_UPGRADES"] = "Tapferkeitsstein / Wappen Aufwertung"
L["VALORSTONES"] = "Tapferkeitssteine"
L["VAULT_REWARD"] = "Schatzkammer"
L["VERSION"] = "Version"
L["WEATHERED_CRESTS"] = "Verwittertes Vorbotenwappen"
L["WEATHERED_CRESTS_SHORT"] = "Verwittert"
L["WHELP_CRESTS"] = "Wappen des Welplings"
L["WHELP_CRESTS_SHORT"] = "Welpling"
L["WYRM_CRESTS"] = "Wappen des Wyrms"
L["WYRM_CRESTS_SHORT"] = "Wyrm"
L["X_RARE"] = "%d (Selten)"
L["X_UPGRADES"] = "%s Aufwertungen"

