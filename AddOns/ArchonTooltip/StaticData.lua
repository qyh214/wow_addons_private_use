---@class Private
local Private = select(2, ...)

Private.CharacterBaseUrl = "/character/%s/%s/%s?utm_source=addon"

Private.IsTestCharacter = false

table.insert(Private.LoginFnQueue, function()
	Private.IsTestCharacter = Private.db.IsTestCharacter or false
end)

function ArchonTooltip.ToggleTesting()
	Private.db.IsTestCharacter = not Private.db.IsTestCharacter
	ReloadUI()
end

---@type table<string, string>
local specToSpecIconMap = {
	["DeathKnight-Blood"] = "spell_deathknight_bloodpresence",
	["DeathKnight-BloodDPS"] = "inv_weapon_shortblade_40",
	["DeathKnight-Frost"] = "spell_deathknight_frostpresence",
	["DeathKnight-Unholy"] = "spell_deathknight_unholypresence",
	["DeathKnight-Runeblade"] = "spell_deathknight_darkconviction",
	["DeathKnight-Lichborne"] = "spell_shadow_raisedead",
	--
	["Druid-Balance"] = "spell_nature_starfall",
	["Druid-Feral"] = "ability_druid_catform",
	["Druid-Restoration"] = "spell_nature_healingtouch",
	["Druid-Guardian"] = "ability_racial_bearform",
	["Druid-Warden"] = "ability_druid_predatoryinstincts",
	["Druid-Dreamstate"] = "ability_druid_dreamstate",
	--
	["Hunter-BeastMastery"] = "ability_hunter_bestialdiscipline",
	["Hunter-Marksmanship"] = "ability_hunter_focusedaim",
	["Hunter-Survival"] = "ability_hunter_camouflage",
	["Hunter-Melee"] = "inv_throwingknife_06",
	["Hunter-Ranged"] = "ability_hunter_focusedaim",
	--
	["Mage-Arcane"] = "spell_holy_magicalsentry",
	["Mage-Fire"] = "spell_fire_firebolt02",
	["Mage-Frost"] = "spell_frost_frostbolt02",
	["Mage-Healer"] = "inv_enchant_essencenethersmall",
	--
	["Paladin-Holy"] = "spell_holy_holybolt",
	["Paladin-Protection"] = "spell_holy_devotionaura",
	["Paladin-Retribution"] = "spell_holy_auraoflight",
	["Paladin-Justicar"] = "spell_holy_divineintervention",
	--
	["Priest-Discipline"] = "spell_holy_powerwordshield",
	["Priest-Holy"] = "spell_holy_guardianspirit",
	["Priest-Shadow"] = "spell_shadow_shadowwordpain",
	--
	["Rogue-Assassination"] = "ability_rogue_deadlybrew",
	["Rogue-Combat"] = "ability_backstab",
	["Rogue-Outlaw"] = "ability_rogue_waylay",
	["Rogue-Subtlety"] = "ability_stealth",
	["Rogue-Tank"] = "ability_rogue_bloodyeye",
	--
	["Shaman-Elemental"] = "spell_nature_lightning",
	["Shaman-Enhancement"] = "spell_shaman_improvedstormstrike",
	["Shaman-Restoration"] = "spell_nature_magicimmunity",
	["Shaman-Tank"] = "spell_shaman_lavaflow",
	--
	["Warlock-Affliction"] = "spell_shadow_deathcoil",
	["Warlock-Demonology"] = "spell_shadow_metamorphosis",
	["Warlock-Destruction"] = "spell_shadow_rainoffire",
	["Warlock-Tank"] = "spell_shadow_demonform",
	--
	["Warrior-Arms"] = "ability_warrior_savageblow",
	["Warrior-Fury"] = "ability_warrior_innerrage",
	["Warrior-Protection"] = "ability_warrior_defensivestance",
	["Warrior-Gladiator"] = "spell_warrior_gladiatorstance",
	["Warrior-Champion"] = "ability_warrior_improveddisciplines",
	--
	["Monk-Brewmaster"] = "spell_monk_brewmaster_spec",
	["Monk-Mistweaver"] = "spell_monk_mistweaver_spec",
	["Monk-Windwalker"] = "spell_monk_windwalker_spec",
	--
	["Evoker-Preservation"] = "classicon_evoker_preservation",
	["Evoker-Augmentation"] = "classicon_evoker_augmentation",
	["Evoker-Devastation"] = "classicon_evoker_devastation",
	--
	["DemonHunter-Vengeance"] = "ability_demonhunter_spectank",
	["DemonHunter-Havoc"] = "ability_demonhunter_specdps",
}

table.insert(Private.LoginFnQueue, function()
	if Private.IsWrath and Private.CurrentRealm.region == "CN" then
		specToSpecIconMap["Hunter-BeastMastery"] = "ability_hunter_beasttaming"
		specToSpecIconMap["Hunter-Survival"] = "ability_hunter_swiftstrike"
		specToSpecIconMap["Warrior-Gladiator"] = "achievement_featsofstrength_gladiator_03"
	elseif Private.IsClassicEra then
		specToSpecIconMap["Rogue-Assassination"] = "ability_rogue_eviscerate"
		specToSpecIconMap["Hunter-Survival"] = "ability_hunter_swiftstrike"
	end
end)

---@param spec string
---@return string
function Private.GetSpecIcon(spec)
	return specToSpecIconMap[spec] or "inv_misc_questionmark"
end

Private.HasDifficulties = Private.IsRetail or Private.IsCata or Private.IsWrath or Private.IsClassicEra

---@type table<string, string>
Private.LocaleToSiteSubDomainMap = {
	["deDe"] = "de",
	["esES"] = "es",
	["esMX"] = "es",
	["frFR"] = "fr",
	["itIT"] = "it",
	["brBR"] = "br",
	["ruRU"] = "ru",
	["koKR"] = "ko",
	["zhTW"] = "tw",
	["zhCN"] = "cn",
}
