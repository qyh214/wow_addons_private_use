local myname, ns = ...

ns.VALDRAKKEN = 2112
ns.WAKINGSHORES = 2022
ns.OHNAHRANPLAINS = 2023
ns.AZURESPAN = 2024
ns.THALDRASZUS = 2025
ns.FORBIDDENREACH = 2151 -- was 2026 before 10.0.7 (but was also unreachable)
ns.FORBIDDENREACHINTRO = 2118 -- Dracthyr
ns.PRIMALISTFUTURE = 2085
ns.ZARALEKCAVERN = 2133

ns.FACTION_MARUUK = 2503
ns.FACTION_DRAGONSCALE = 2507
ns.FACTION_VALDRAKKEN = 2510
ns.FACTION_ISKAARA = 2511
ns.FACTION_LOAMM = 2564

-- 67030 completes alongside 66221 (moving on) and 72366; it's then also completed on any alts, unlike the others
-- (It's what's in the vignettes as a condition for visibility)
ns.MAXLEVEL = {ns.conditions.QuestComplete(67030), ns.conditions.Level(70)}
ns.DRAGONRIDING = ns.conditions.SpellKnown(376777)

ns.PROF_DF_ALCHEMY = 2823 -- spell: 366261
ns.PROF_DF_BLACKSMITHING = 2822 -- spell: 365677
ns.PROF_DF_COOKING = 2824
ns.PROF_DF_ENCHANTING = 2825 -- spell: 366255
ns.PROF_DF_ENGINEERING = 2827 -- spell: 366254
ns.PROF_DF_FISHING = 2826
ns.PROF_DF_HERBALISM = 2832
ns.PROF_DF_INSCRIPTION = 2828 -- spell: 366251
ns.PROF_DF_JEWELCRAFTING = 2829 -- spell: 366250
ns.PROF_DF_LEATHERWORKING = 2830 -- spell: 366249
ns.PROF_DF_MINING = 2833
ns.PROF_DF_SKINNING = 2834
ns.PROF_DF_TAILORING = 2831 -- spell: 366258

ns.hiddenConfig = {}

ns.defaults.profile.groupsHidden = {
    scoutpack = true,
    disturbeddirt = true,
    tuskarrchests = true,
    warsupply = true,
    titanchests = true,
}

ns.groups["junk"] = BAG_FILTER_JUNK
ns.groups["scoutpack"] = "{spell:388272:Lost Expedition Scout Packs}"
ns.groups["disturbeddirt"] = "{spell:340561:Disturbed Dirt}"
ns.groups["magicbound"] = "{npc:191905:Magic-Bound Chest}"
ns.groups["tuskarrchests"] = "{item:200071:Sacred Tuskarr Totem}"
ns.groups["warsupply"] = "War Supply Chest"
ns.groups["titanchests"] = "Titan Chest"
ns.groups["glyphs"] = "Dragon Glyphs"
ns.groups["dailymount"] = "Daily Mounts"
ns.groups["races"] = "{achievement:15939:Dragon Racing Completionist}"
ns.groups["professionknowledge"] = "Profession Knowledge"
ns.groups["hunts"] = "{achievement:16540:Hunt Master}"

ns.SUPERRARE = ns.nodeMaker{
    texture=ns.atlas_texture("VignetteKillElite", {r=1, g=0.5, b=1, scale=1.5}),
    note="This is a \"super rare\" which can drop higher level loot",
}

--[[
notes:
Intro:
Talked to Azurathel: 72285
Talked to Genn and Shaw: 72286
Talked to Turalyon and Shaw: 72287

Rescued Waddles: 70872

Talked to Lethanak at the Life Pools: 72059

unlocked dragon customization: 68797

Herbalism: looted Dreambloom Petal 71858 71859
Inscriptions: looted Iskaaean Trading Ledger 66376

--]]
