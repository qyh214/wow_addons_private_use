local myname, ns = ...

ns.KHAZALGAR = 2274
ns.DORNOGAL = 2339
ns.ISLEOFDORN = 2248
ns.RINGINGDEEPS = 2214
ns.HALLOWFALL = 2215
ns.AZJKAHET = 2255
ns.CITYOFTHREADS = 2213
ns.CITYOFTHREADSLOWER = 2216

-- ns.MAXLEVEL = {ns.conditions.QuestComplete(67030), ns.conditions.Level(70)}
-- ns.DRAGONRIDING = ns.conditions.SpellKnown(376777)

ns.FACTION_DORNOGAL = 2590
ns.FACTION_ARATHI = 2570
ns.FACTION_ASSEMBLY = 2594
ns.FACTION_SEVERED = 2600
ns.FACTION_SEVERED_WEAVER = 2601
ns.FACTION_SEVERED_GENERAL = 2605
ns.FACTION_SEVERED_VIZIER = 2607

ns.CURRENCY_DORNOGAL = 2897
ns.CURRENCY_ARATHI = 2899
ns.CURRENCY_ASSEMBLY = 2902
ns.CURRENCY_SEVERED = 2903
ns.CURRENCY_SEVERED_WEAVER = 3002
ns.CURRENCY_SEVERED_GENERAL = 3003
ns.CURRENCY_SEVERED_VIZIER = 3004
ns.CURRENCY_RESONANCE = 2815

ns.PROF_WW_ALCHEMY = 2871 -- spell:
ns.PROF_WW_BLACKSMITHING = 2872 -- spell:423332
ns.PROF_WW_COOKING = 2873 -- spell:
ns.PROF_WW_ENCHANTING = 2874 -- spell:
ns.PROF_WW_ENGINEERING = 2875 -- spell:
ns.PROF_WW_FISHING = 2876
ns.PROF_WW_HERBALISM = 2877
ns.PROF_WW_INSCRIPTION = 2878 -- spell:
ns.PROF_WW_JEWELCRAFTING = 2879 -- spell:
ns.PROF_WW_LEATHERWORKING = 2880 -- spell:
ns.PROF_WW_MINING = 2881
ns.PROF_WW_SKINNING = 2882
ns.PROF_WW_TAILORING = 2883 -- spell:

ns.hiddenConfig = {}

ns.defaults.profile.groupsHidden = {
    snuffling = true,
    worldboss = true, -- we get their loot in the POI, without showing the points when you can't see them...
}

ns.defaults.profile.achievementsHidden = {
    [40475] = true, -- To All the Slimes I Love
    [40762] = true, -- Khaz Algar Lore Hunter (is disabled by Blizzard currently)
}

ns.groups["junk"] = BAG_FILTER_JUNK
ns.groups["professionknowledge"] = "Profession Knowledge"
ns.groups["glyphs"] = GLYPHS
ns.groups["delves"] = DELVES_LABEL
ns.groups["races"] = "{spell:369968:Racing}"
ns.groups["beledar"] = "{spell:452526:Beledar's Influence}"
ns.groups["beledarspawn"] = "{npc:207802:Beledar's Spawn}"
ns.groups["snuffling"] = "{spell:431909:Snuffling}"
ns.groups["worldboss"] = MAP_LEGEND_WORLDBOSS

--[[
notes:

--]]
