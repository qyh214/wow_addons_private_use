local myname, ns = ...

local master = {
    note="Profession master; talk to them for knowledge",
    texture=ns.atlas_texture("Professions-Crafting-Orders-Icon", {r=0.5,g=1,b=1,}),
    group="professionknowledge",
    minimap=true,
}

ns.RegisterPoints(ns.WAKINGSHORES, {
    [73276971] = { -- Zenzi
        quest=70259,
        npc=194844,
        currency=2033,
        requires=ns.conditions.Profession(ns.PROF_DF_SKINNING),
        active=ns.conditions.Profession(ns.PROF_DF_SKINNING, 25),
    },
    [60827591] = { -- Grigori Vialtry
        quest=70247,
        npc=194829,
        currency=2024,
        requires=ns.conditions.Profession(ns.PROF_DF_ALCHEMY),
        active=ns.conditions.Profession(ns.PROF_DF_ALCHEMY, 25),
    },
    [43326660] = { -- Grekka Anvilsmash
        quest=70250,
        npc=194836,
        currency=2023,
        requires=ns.conditions.Profession(ns.PROF_DF_BLACKSMITHING),
        active=ns.conditions.Profession(ns.PROF_DF_BLACKSMITHING, 25),
    },
}, master)

ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [62471867] = { -- Shalasar Glimmerdusk
        quest=70251,
        npc=194837,
        currency=2030,
        requires=ns.conditions.Profession(ns.PROF_DF_ENCHANTING),
        active=ns.conditions.Profession(ns.PROF_DF_ENCHANTING, 25),
        note="On second floor of tower",
    },
    [58425004] = { -- Hua Greenpaw
        quest=70253,
        npc=194839,
        currency=2034,
        requires=ns.conditions.Profession(ns.PROF_DF_HERBALISM),
        active=ns.conditions.Profession(ns.PROF_DF_HERBALISM, 25),
    },
    [82455067] = { -- Erden
        quest=70256,
        npc=194842,
        currency=2025,
        requires=ns.conditions.Profession(ns.PROF_DF_LEATHERWORKING),
        active=ns.conditions.Profession(ns.PROF_DF_LEATHERWORKING, 25),
    },
}, master)

ns.RegisterPoints(ns.AZURESPAN, {
    [17772168] = { -- Frizz Buzzcrank
        quest=70252,
        npc=194838,
        currency=2027,
        requires=ns.conditions.Profession(ns.PROF_DF_ENGINEERING),
        active=ns.conditions.Profession(ns.PROF_DF_ENGINEERING, 25),
    },
    [40156434] = { -- Lydiara Whisperfeather
        quest=70254,
        npc=194840,
        currency=2028,
        requires=ns.conditions.Profession(ns.PROF_DF_INSCRIPTION),
        active=ns.conditions.Profession(ns.PROF_DF_INSCRIPTION, 25),
    },
    [46224076] = { -- Pluutar
        quest=70255,
        npc=194841,
        currency=2029,
        requires=ns.conditions.Profession(ns.PROF_DF_JEWELCRAFTING),
        active=ns.conditions.Profession(ns.PROF_DF_JEWELCRAFTING, 25),
    },
}, master)

ns.RegisterPoints(ns.THALDRASZUS, {
    [61427695] = { -- Bridgette Holdug
        quest=70258,
        npc=194843,
        currency=2035,
        requires=ns.conditions.Profession(ns.PROF_DF_MINING),
        active=ns.conditions.Profession(ns.PROF_DF_MINING, 25),
        note = "On top of a rock spire.",
    },
}, master)

ns.RegisterPoints(ns.VALDRAKKEN, {
    [28134583] = { -- Elysa Raywinder
        quest=70260,
        npc=194845,
        currency=2026,
        requires=ns.conditions.Profession(ns.PROF_DF_TAILORING),
        active=ns.conditions.Profession(ns.PROF_DF_TAILORING, 25),
        parent=true,
    },
}, master)
