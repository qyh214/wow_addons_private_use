local myname, ns = ...

local KNOWLEDGE = {
    note="Profession master; buy knowledge from them",
    texture=ns.atlas_texture("Professions-Crafting-Orders-Icon", {r=0.5,g=1,b=1,}),
    backdrop=ns.atlas_texture("CircleMask", {r=0.5, g=1, b=1}),
    border=ns.atlas_texture("AutoQuest-badgeborder", 1.1),
    group="professionknowledge",
    minimap=true,
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
    [58203160] = surfaceRequirements{
        label="{npc:218195:Rukku}",
        loot={
            rItem(224052, {quest=82632, requires=cProfession(ns.PROF_WW_ENGINEERING)}), -- Clocks, Gears, Sprockets, and Legs
        },
    },
    [46602160] = surfaceRequirements{
        label="{npc:218166:Rakka}",
        loot={
            rItem(224055, {quest=82614, requires=cProfession(ns.PROF_WW_MINING)}), -- A Rocky Start
            rItem(224038, {quest=82631, requires=cProfession(ns.PROF_WW_BLACKSMITHING)}), -- Smithing After Saronite
        },
    },
    [43601980] = surfaceRequirements{
        label="{npc:218165:Kama}",
        loot={
            rItem(224007, {quest=82596, requires=cProfession(ns.PROF_WW_SKINNING)}), -- Uses for Leftover Husks (How to Take Them Apart)
            rItem(224056, {quest=82626, requires=cProfession(ns.PROF_WW_LEATHERWORKING)}), -- Uses for Leftover Husks (After You Take Them Apart)
        },
    },
    [47601860] = surfaceRequirements{
        label="{npc:218179:Alvus Valavulu}",
        loot={
            rItem(224054, {quest=82637, requires=cProfession(ns.PROF_WW_JEWELCRAFTING)}), -- Emergent Crystals of the Surface-Dwellers
            ns.rewards.Toy(228914), -- Arachnophile Spectacles
        },
    },
    [45601320] = surfaceRequirements{
        label="{npc:218192:Siesbarg}",
        loot={
            rItem(224024, {quest=82633, requires=cProfession(ns.PROF_WW_ALCHEMY)}), -- Theories of Bodily Transmutation, Chapter 8
        },
    },
    [45603360] = surfaceRequirements{
        label="{npc:218193:Iliani}",
        loot={
            rItem(224050, {quest=82635, requires=cProfession(ns.PROF_WW_ENCHANTING)}), -- Web Sparkles: Pretty and Powerful
        },
    },
    [50201680] = surfaceRequirements{
        label="{npc:218190:Saaria}",
        loot={
            rItem(224036, {quest=82634, requires=cProfession(ns.PROF_WW_TAILORING)}), -- And That's A Web-Wrap!
        },
    },
    [47001620] = surfaceRequirements{
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
}, ns.merge({parent=true, levels=true, translate={[2256]=true}}, KNOWLEDGE))
