local myname, ns = ...

local chest = {
    label="Titan Chest",
    loot={
        -- all the treasure-prerequisite items
        {199061, quest=70527}, -- A Guide To Rare Fish
        {199066, quest=70535}, -- Letter of Caution
        {199068, quest=70537}, -- Time-Lost Memo
        -- the rest
        199906, -- Titan Relic
        192055, -- Dragon Isles Artifact
        201455, -- Tyrhold Broadsword
        201459, -- Tyrhold Shortsword
        201460, -- Gavel of Tyrhold
        201458, -- Aegis of Tyrhold
        201461, -- Tyrhold Pinnacle
        201457, -- Tyrhold Relic
        201456, -- Tyrhold Carbine
        201054, -- Tyrhold Drape
        201053, -- Tyrhold Gloves
        201049, -- Tyrhold Robe
        201048, -- Tyrhold Epaulets
        201052, -- Tyrhold Visage
        201050, -- Tyrhold Leggings
        201056, -- Tyrhold Sash
        201051, -- Tyrhold Slippers
    },
    requires=ns.conditions.MajorFaction(ns.FACTION_VALDRAKKEN, 2),
    texture=ns.atlas_texture("VignetteLoot", {r=0.5, g=1, b=1, scale=0.9}),
    group="titanchests", always=true,
}

ns.RegisterPoints(ns.THALDRASZUS, {
    [34107310] = chest,
    [34306600] = chest,
    [34706700] = chest,
    [35807550] = chest,
    [35906730] = chest,
    [37705110] = chest,
    [37706980] = chest,
    [38105300] = chest,
    [38705340] = chest,
    [38804480] = chest,
    [38904610] = chest,
    [41204520] = chest,
    [46007210] = chest,
    [48306900] = chest,
    [48807530] = chest,
    [48907100] = chest,
    [49707590] = chest,
    [51107470] = chest,
    [57108080] = chest,
    [57108240] = chest,
    [57606440] = chest,
    [57708040] = chest,
    [59305670] = chest,
    [59905590] = chest,
    [60005470] = chest,
    [60606220] = chest,
    [61906180] = chest,
})
