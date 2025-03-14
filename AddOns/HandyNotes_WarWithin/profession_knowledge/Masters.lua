local myname, ns = ...

local KNOWLEDGE = {
    note="Profession master; buy knowledge from them",
    texture=ns.atlas_texture("Professions-Crafting-Orders-Icon", {r=0.5,g=1,b=1,}),
    backdrop=ns.atlas_texture("CircleMask", {r=0.5, g=1, b=1}),
    border=ns.atlas_texture("AutoQuest-badgeborder", 1.1),
    hide_before=ns.conditions.QuestComplete(81623), -- pheromones applied just before the end of into a skittering city (78228)
    group="professionknowledge",
    minimap=true,
    parent=true, levels=true, translate={[2256]=true},
}

local rItem = ns.rewards.Item
local cProfession = ns.conditions.Profession

local function surfaceRequirements(point)
    local requires = point.requires or {}
    for _, item in ipairs(point.loot) do
        if not item.requires then
            -- abandon for things with non-requirement items
            return point
        end
        table.insert(requires, item.requires)
    end
    if #requires > 0 then
        requires.any = true
        point.requires = requires
    end
    return point
end

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [58323156] = surfaceRequirements{
        label="{npc:218195:Rukku}",
        loot={
            rItem(224052, {quest=82632, requires=cProfession(ns.PROF_WW_ENGINEERING)}), -- Clocks, Gears, Sprockets, and Legs
        },
    },
    [46712208] = surfaceRequirements{
        label="{npc:218166:Rakka}",
        loot={
            rItem(224055, {quest=82614, requires=cProfession(ns.PROF_WW_MINING)}), -- A Rocky Start
            rItem(224038, {quest=82631, requires=cProfession(ns.PROF_WW_BLACKSMITHING)}), -- Smithing After Saronite
        },
    },
    [46282913] = surfaceRequirements{
        label="{npc:218224:\"Calmest\" Gobbu}",
        loot={
            rItem(224055, {quest=82614, requires=cProfession(ns.PROF_WW_MINING)}), -- A Rocky Start
            rItem(224038, {quest=82631, requires=cProfession(ns.PROF_WW_BLACKSMITHING)}), -- Smithing After Saronite
            {222968, pet=true}, -- Itchbite
            {222973, pet=true}, -- Fringe
        },
    },
    [43511957] = surfaceRequirements{
        label="{npc:218165:Kama}",
        loot={
            rItem(224007, {quest=82596, requires=cProfession(ns.PROF_WW_SKINNING)}), -- Uses for Leftover Husks (How to Take Them Apart)
            rItem(224056, {quest=82626, requires=cProfession(ns.PROF_WW_LEATHERWORKING)}), -- Uses for Leftover Husks (After You Take Them Apart)
        },
    },
    [47751874] = surfaceRequirements{
        label="{npc:218179:Alvus Valavulu}",
        loot={
            rItem(224054, {quest=82637, requires=cProfession(ns.PROF_WW_JEWELCRAFTING)}), -- Emergent Crystals of the Surface-Dwellers
            ns.rewards.Toy(228914), -- Arachnophile Spectacles
        },
    },
    [45481240] = surfaceRequirements{
        label="{npc:218192:Siesbarg}",
        loot={
            rItem(224024, {quest=82633, requires=cProfession(ns.PROF_WW_ALCHEMY)}), -- Theories of Bodily Transmutation, Chapter 8
            -- 225784, -- Potion of Polymorphic Translation: Nerubian
        },
    },
    [55574754] = surfaceRequirements{
        label="{npc:224337:Zara'azj the Magnificent}",
        loot={
            rItem(224024, {quest=82633, requires=cProfession(ns.PROF_WW_ALCHEMY)}), -- Theories of Bodily Transmutation, Chapter 8
        },
    },
    [57253628] = surfaceRequirements{
        label="{npc:223172:Rej the Dying}",
        loot={
            rItem(224024, {quest=82633, requires=cProfession(ns.PROF_WW_ALCHEMY)}), -- Theories of Bodily Transmutation, Chapter 8
            rItem(224036, {quest=82634, requires=cProfession(ns.PROF_WW_TAILORING)}), -- And That's A Web-Wrap!
            -- 225784, -- Potion of Polymorphic Translation: Nerubian
        },
    },
    [45723279] = surfaceRequirements{
        label="{npc:218193:Iliani}",
        loot={
            rItem(224050, {quest=82635, requires=cProfession(ns.PROF_WW_ENCHANTING)}), -- Web Sparkles: Pretty and Powerful
        },
    },
    [50391700] = surfaceRequirements{
        label="{npc:218190:Saaria}",
        loot={
            rItem(224036, {quest=82634, requires=cProfession(ns.PROF_WW_TAILORING)}), -- And That's A Web-Wrap!
        },
    },
    [51411251] = surfaceRequirements{
        label="{npc:218214:Ruukk}",
        loot={
            rItem(224036, {quest=82634, requires=cProfession(ns.PROF_WW_TAILORING)}), -- And That's A Web-Wrap!
        },
    },
    [50363163] = surfaceRequirements{
        label="{npc:218202:Thripps}", -- also Xlox'zillswan standing right next to them, really
        loot={
            rItem(224036, {quest=82634, requires=cProfession(ns.PROF_WW_TAILORING)}), -- And That's A Web-Wrap!
        },
    },
    [46851611] = surfaceRequirements{
        label="{npc:218169:Llyot}",
        loot={
            rItem(224023, {quest=82630, requires=cProfession(ns.PROF_WW_HERBALISM)}), -- Herbal Embalming Techniques
        },
    },
    [42202680] = surfaceRequirements{
        label="{npc:218176:Nuel Prill}",
        loot={
            rItem(224053, {quest=82636, requires=cProfession(ns.PROF_WW_INSCRIPTION)}), -- Eight Views on Defense against Hostile Runes
        },
    },
    [51551396] = surfaceRequirements{
        label="{npc:218212:Violesca}",
        loot={
            rItem(224053, {quest=82636, requires=cProfession(ns.PROF_WW_INSCRIPTION)}), -- Eight Views on Defense against Hostile Runes
        },
    },
    [54351601] = surfaceRequirements{
        label="{npc:223162:Th'z of the Dark Web}",
        loot={
            rItem(224053, {quest=82636, requires=cProfession(ns.PROF_WW_INSCRIPTION)}), -- Eight Views on Defense against Hostile Runes
            rItem(224036, {quest=82634, requires=cProfession(ns.PROF_WW_TAILORING)}), -- And That's A Web-Wrap!
        },
    },
}, KNOWLEDGE)
