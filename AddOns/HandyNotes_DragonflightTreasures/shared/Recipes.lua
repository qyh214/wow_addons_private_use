local myname, ns = ...

local recipe = {
    atlas="poi-workorders",
    minimap=true,
}

ns.RegisterPoints(ns.WAKINGSHORES, {
    [32406840] = {
        npc=191476,
        loot={{195881, spell=381385}}, -- Recipe: Charred Hornswog Steaks
        note="Not a 100% drop",
    },
}, recipe)
ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [41546227] = {
        quest=nil, -- This doesn't seem to trip a quest
        label="{npc:192818:Elder Yusa}",
        loot={{194965, spell=381413}}, -- Recipe: Yusa's Hearty Stew
        note="Dismount, then use "..EMOTE58_CMD1.." on her",
    },
}, recipe)
ns.RegisterPoints(ns.AZURESPAN, {
    [58034202] = {
        quest=70237,
        loot={
            {198103, spell=381376}, -- Recipe: Snow in a Cone
            17202, -- Snowball
        },
        note="Snow covered scroll",
    },
}, recipe)
ns.RegisterPoints(ns.VALDRAKKEN, {
    [09575623] = {
        quest=70731,
        loot={
            {198106, spell=381380}, -- Recipe: Tasty Hatchling's Treat
            197769, -- Tasty Hatchling's Treat
        },
        note="In barrel",
    },
}, recipe)
