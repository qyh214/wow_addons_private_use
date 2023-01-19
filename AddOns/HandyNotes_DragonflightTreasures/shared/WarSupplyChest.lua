local myname, ns = ...

local warsupply = {
    label="War Supply Chest",
    loot={
        190451, -- Rousing Ire
        201756, -- Bulging Coin Purse
        -- Materials patterns
        201256, -- Bloodstained Plans: Infurious Alloy
        201257, -- Bloodstained Pattern: Infurious Hide
        201259, -- Bloodstained Pattern: Infurious Scales
        201258, -- Bloodstained Pattern: Infurious Wildercloth Bolt
        -- Blacksmithing
        194456, -- Plans: Crimson Combatant's Draconium Pauldrons
        -- Leather
        197965, -- Pattern: Crimson Combatant's Resilient Chestpiece
        197964, -- Pattern: Crimson Combatant's Resilient Mask
        197974, -- Pattern: Crimson Combatant's Adamant Leggings
        197969, -- Pattern: Crimson Combatant's Resilient Gloves
        197966, -- Pattern: Crimson Combatant's Resilient Trousers
        -- Tailoring
        194258, -- Pattern: Infurious Legwraps of Possibility
        -- Jewelcrafting
        194638, -- Design: Crimson Combatant's Jeweled Signet
    },
    texture=ns.atlas_texture("VignetteLootElite", {r=1, g=0.5, b=1, scale=1.2}),
    minimap=true,
    note="War Mode only",
    group="warsupply",
}

ns.RegisterPoints(ns.WAKINGSHORES, {
    [24307990] = {},
    [32006380] = {},
    [32605100] = {},
    [48007640] = {},
    [51605640] = {},
    [51804270] = {},
    [66103330] = {},
    [70906540] = {},
    [78704910] = {},
}, warsupply)
ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [22406360] = {},
    [36003220] = {},
    [36006290] = {},
    [48502630] = {},
    [61106160] = {},
    [62908060] = {},
    [75104960] = {},
    [77702440] = {},
    [80907570] = {},
}, warsupply)
ns.RegisterPoints(ns.AZURESPAN, {
    [21403520] = {},
    [24505010] = {},
    [26202970] = {},
    [38303290] = {},
    [44904680] = {},
    [48505360] = {},
    [69705400] = {},
    [71402890] = {},
}, warsupply)
ns.RegisterPoints(ns.THALDRASZUS, {
    [37407480] = {},
    [42004890] = {},
    [43806980] = {},
    [50105870] = {},
    [53903600] = {},
    [57405390] = {},
    [59606170] = {},
    [61903080] = {},
    [64605970] = {},
}, warsupply)
