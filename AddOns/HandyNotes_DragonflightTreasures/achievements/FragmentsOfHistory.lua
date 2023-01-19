local myname, ns = ...

local FRAGMENT = {
    achievement=16323,
    texture=ns.atlas_texture("ArchBlob", {r=1, g=1, b=0, scale=1.2}), -- or reagents?
    minimap=true,
    onquest=true,
    hide_before={
        ns.conditions.QuestComplete(70231), -- asking Emelia what they're doing here
    },
    note="Bring to {npc:193915} at Wingrest Embassy",
}

ns.RegisterPoints(ns.WAKINGSHORES, {
    [75403380] = { -- Emelia Bellocq
        achievement=16323,
        npc=193915,
        loot={{198646, toy=true}}, -- Ornate Dragon Statue
        atlas="ArchBlob", scale=1.2, minimap=true,
        note="Talk to her to trigger the rest of the achievement treasures appearing",
    },
})

ns.RegisterPoints(ns.WAKINGSHORES, {
    [60555786] = {criteria=55025, quest=70236, note="Under the dragon statue"}, -- Dislodged Dragoneye
    [58246841] = {criteria=55026, quest=70207, note="Under the dragon statue"}, -- Tail Fragment
    [47238848] = {criteria=55030, quest=70789, note="Under the dragon statue"}, -- Finely Carved Wing
    [81143040] = {criteria=55027, quest=70175, note="On the statue's foot"}, -- Broken Banding
}, FRAGMENT)

-- ns.RegisterPoints(ns.OHNAHRANPLAINS, {
-- }, FRAGMENT)

ns.RegisterPoints(ns.AZURESPAN, {
    [47833888] = {criteria=55029, quest=70791, note="Underwater"}, -- Coldwashed Dragonclaw
    [66086012] = {criteria=55028, quest=70806, note="Behind the statue"}, -- Chunk of Sculpture
    [69174757] = {criteria=55033, quest=70790, note="By the statue's base"}, -- Stone Dragontooth
    [47342459] = {criteria=55034, quest=70788, note="On the statue's foot"}, -- Wrapped Gold Band
}, FRAGMENT)

ns.RegisterPoints(ns.THALDRASZUS, {
    [38904500] = {criteria=55031, quest=70204, note="On the statue's foot"}, -- Golden Claw
    [57126460] = {criteria=55032, quest=70805, note="Under the statue's foot"}, -- Precious Stone Fragment
}, FRAGMENT)
