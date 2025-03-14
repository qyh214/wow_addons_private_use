
-- DruidFeral.lua
-- January 2025

-- TODO: Recalculate all ability damage / tick damage based on new formulas.

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID = ns.FindUnitBuffByID
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

local strformat = string.format

local spec = Hekili:NewSpecialization( 103 )

spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.ComboPoints, {
    predator_revealed = {
        aura = "predator_revealed",

        last = function ()
            local app = state.buff.predator_revealed.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 1.5 ) * 1.5
        end,

        interval = 1.5,
        value = 1
    },
    bs_inc = {
        talent = "berserk",
        aura = "bs_inc",

        last = function ()
            local app = state.buff.bs_inc.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 1.5 ) * 1.5
        end,

        interval = 1.5,
        value = 1
    }
} )

spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Druid
    aessinas_renewal               = {  82232, 474678, 1 }, -- When a hit deals more than 12% of your maximum health, instantly heal for 10% of your health. This effect cannot occur more than once every 30 seconds.
    astral_influence               = {  82210, 197524, 1 }, -- Increases the range of all of your spells by 5 yards.
    blooming_infusion              = {  94601, 429433, 1 }, -- Every 5 Regrowths you cast makes your next Wrath, Starfire, or Entangling Roots instant and increases damage it deals by 100%. Every 5 Starsurges you cast makes your next Regrowth or Entangling roots instant.
    bounteous_bloom                = {  94591, 429215, 1 }, -- Your Grove Guardians' healing is increased by 30%.
    cenarius_might                 = {  94604, 455797, 1 }, -- Casting Swiftmend increases your Haste by 10% for 6 sec.
    circle_of_the_heavens          = { 104078, 474541, 1 }, -- Magical damage dealt by your spells increased by 5%.
    circle_of_the_wild             = { 104078, 474530, 1 }, -- Physical damage dealt by your abilities increased by 5%.
    control_of_the_dream           = {  94592, 434249, 1 }, -- Time elapsed while your major abilities are available to be used or at maximum charges is subtracted from that ability's cooldown after the next time you use it, up to 15 seconds. Affects Force of Nature, Celestial Alignment, and Convoke the Spirits.
    cyclone                        = {  82229,  33786, 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 5 sec. Only one target can be affected by your Cyclone at a time.
    dream_surge                    = {  94600, 433831, 1 }, -- Grove Guardians causes your next targeted heal to create 2 Dream Petals near the target, healing up to 3 nearby allies for 33,111. Stacks up to 3 charges.
    durability_of_nature           = {  94605, 429227, 1 }, -- Your Grove Guardians' Nourish and Swiftmend spells also apply a Minor Cenarion Ward that heals the target for 63,229 over 6.8 sec the next time they take damage.
    early_spring                   = {  94591, 428937, 1 }, -- Grove Guardians cooldown reduced by 3 sec.
    expansiveness                  = {  94602, 429399, 1 }, -- Your maximum mana is increased by 5%.
    feline_swiftness               = {  82236, 131768, 1 }, -- Increases your movement speed by 15%.
    fluid_form                     = {  82246, 449193, 1 }, -- Shred, Rake, and Skull Bash can be used in any form and shift you into Cat Form, if necessary. Mangle can be used in any form and shifts you into Bear Form. Wrath and Starfire shift you into Moonkin Form, if known.
    forestwalk                     = {  82243, 400129, 1 }, -- Casting Regrowth increases your movement speed and healing received by 8% for 6 sec.
    frenzied_regeneration          = {  82220,  22842, 1 }, -- Heals you for 32% health over 3 sec, and increases healing received by 20%.
    gale_winds                     = { 104079, 400142, 1 }, -- Increases Typhoon's radius by 20% and its range by 5 yds.
    grievous_wounds                = {  82239, 474526, 1 }, -- Rake, Rip, and Thrash damage increased by 10%.
    groves_inspiration             = {  94595, 429402, 1 }, -- Wrath and Starfire damage increased by 10%. Regrowth, Wild Growth, and Swiftmend healing increased by 9%.
    harmony_of_the_grove           = {  94606, 428731, 1 }, -- Each of your Grove Guardians increases your healing done by 5% while active.
    heart_of_the_wild              = {  82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Cast time of Balance spells reduced by 30% and damage increased by 20%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges. Restoration: Healing increased by 30%, and mana costs reduced by 50%.
    hibernate                      = {  82211,   2637, 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin              = { 104085, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_stampeding_roar       = {  82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    incapacitating_roar            = {  82237,     99, 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 10 yards for 3 sec. Damage may cancel the effect.
    incessant_tempest              = { 104079, 400140, 1 }, -- Reduces the cooldown of Typhoon by 5 sec.
    innervate                      = { 100175,  29166, 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 8 sec.
    instincts_of_the_claw          = { 104081, 449184, 1 }, -- Ferocious Bite and Maul damage increased by 8%.
    ironfur                        = {  82227, 192081, 1 }, -- Increases armor by 20,157 for 7 sec.
    killer_instinct                = {  82225, 108299, 2 }, -- Physical damage and Armor increased by 6%.
    lingering_healing              = {  82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec. Regrowth's duration is increased by 3 sec when cast on yourself.
    lore_of_the_grove              = { 104080, 449185, 1 }, -- Moonfire and Sunfire damage increased by 10%.
    lycaras_meditation             = {  92229, 474728, 1 }, -- You retain Lycara's Teachings' bonus from your most recent shapeshift form for 5 sec after shifting out of it.
    lycaras_teachings              = {  82233, 378988, 2 }, -- You gain 3% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                           = {  82221,  22570, 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 6,385 damage, 1 sec 2 points: 12,771 damage, 2 sec 3 points: 19,157 damage, 3 sec 4 points: 25,543 damage, 4 sec 5 points: 31,929 damage, 5 sec
    mass_entanglement              = {  82207, 102359, 1 }, -- Roots the target and all enemies within 12 yards in place for 10 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                     = { 100177, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 84,734 damage for 8 sec.
    mighty_bash                    = {  82237,   5211, 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    moonkin_form                   = {  82208,  24858, 1 }, -- Shapeshift into Moonkin Form, increasing the damage of your spells by 10% and your armor by 125%, and granting protection from Polymorph effects. The act of shapeshifting frees you from movement impairing effects.
    natural_recovery               = {  82206, 377796, 1 }, -- Healing you receive is increased by 4%.
    natures_vigil                  = {  82244, 124974, 1 }, -- For 15 sec, all single-target damage also heals a nearby friendly target for 20% of the damage done.
    nurturing_instinct             = {  82214,  33873, 2 }, -- Magical damage and healing increased by 6%.
    oakskin                        = { 100176, 449191, 1 }, -- Survival Instincts and Barkskin reduce damage taken by an additional 10%.
    perfectlyhoned_instincts       = { 104082, 1213597, 1 }, -- Well-Honed Instincts can trigger up to once every 60 sec.
    potent_enchantments            = {  94595, 429420, 1 }, -- Reforestation grants Tree of Life for 3 additional sec.
    power_of_nature                = {  94605, 428859, 1 }, -- Your Grove Guardians increase the healing of your Rejuvenation, Efflorescence, and Lifebloom by 10% while active.
    power_of_the_dream             = {  94592, 434220, 1 }, -- Healing spells cast with Dream Surge generate an additional Dream Petal.
    primal_fury                    = {  82224, 159286, 1 }, -- While in Cat Form, when you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect. Mangle critical strike damage increased by 20%.
    protective_growth              = {  94593, 433748, 1 }, -- Your Regrowth protects you, reducing damage you take by 8% while your Regrowth is on you.
    rake                           = {  82199,   1822, 1 }, -- Rake the target for 18,861 Bleed damage and an additional 115,471 Bleed damage over 12 sec. Reduces the target's movement speed by 20% for 12 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    rejuvenation                   = {  82217,    774, 1 }, -- Heals the target for 67,858 over 12.8 sec.
    remove_corruption              = {  82241,   2782, 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    renewal                        = {  82232, 108238, 1 }, -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    rip                            = {  82222,   1079, 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 96,954 over 6 sec 2 points: 145,432 over 10 sec 3 points: 193,909 over 13 sec 4 points: 242,387 over 16 sec 5 points: 290,864 over 19 sec
    skull_bash                     = {  82242, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    soothe                         = {  82229,   2908, 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar                = {  82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 15 yards by 60% for 8 sec.
    starfire                       = {  91044, 197628, 1 }, -- Call down a burst of energy, causing 26,943 Arcane damage to the target, and 9,194 Arcane damage to all other enemies within 5 yards. Deals reduced damage beyond 8 targets.
    starlight_conduit              = { 100223, 451211, 1 }, -- Wrath, Starsurge, and Starfire damage increased by 5%. Starsurge's cooldown is reduced by 4 sec and its mana cost is reduced by 50%.
    starsurge                      = {  82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing 60,869 Astral damage.
    sunfire                        = {  93714,  93402, 1 }, -- A quick beam of solar light burns the enemy for 6,434 Nature damage and then an additional 59,436 Nature damage over 14.4 sec to the primary target and all enemies within 8 yards.
    symbiotic_relationship         = { 100173, 474750, 1 }, -- Form a bond with an ally. Your self-healing also heals your bonded ally for 10% of the amount healed. Your healing to your bonded ally also heals you for 8% of the amount healed.
    thick_hide                     = {  82228,  16931, 1 }, -- Reduces all damage taken by 4%.
    thrash                         = {  82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                     = {  82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    treants_of_the_moon            = {  94599, 428544, 1 }, -- Your Grove Guardians cast Moonfire on nearby targets about once every 6 sec.
    typhoon                        = {  82209, 132469, 1 }, -- Blasts targets within 15 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by 50% for 6 sec. Usable in all shapeshift forms.
    ursine_vigor                   = { 100174, 377842, 1 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 15%.
    ursocs_spirit                  = {  82219, 449182, 1 }, -- Stamina increased by 4%. Stamina in Bear Form is increased by an additional 5%.
    ursols_vortex                  = {  82207, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart                  = {  82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    wellhoned_instincts            = {  82235, 377847, 1 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 90 sec.
    wild_charge                    = {  82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                    = {  82205,  48438, 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 40,273 over 6.0 sec. Healing starts high and declines over the duration.

    -- Feral
    adaptive_swarm                 = {  82112, 391888, 1 }, -- Command a swarm that heals 62,825 or deals 93,207 Nature damage over 9.6 sec to a target, and increases the effectiveness of your periodic effects on them by 25%. Upon expiration, finds a new target, preferring to alternate between friend and foe up to 3 times.
    apex_predators_craving         = {  82092, 391881, 1 }, -- Rip damage has a 6.0% chance to make your next Ferocious Bite free and deal the maximum damage.
    ashamanes_guidance             = {  82113, 391548, 1 }, -- Incarnation: Avatar of Ashamane During Incarnation: Avatar of Ashamane and for 40 sec after it ends, your Rip and Rake each cause affected enemies to take 3% increased damage from your abilities.  Convoke the Spirits Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    berserk                        = {  82101, 106951, 1 }, -- Go Berserk for 15 sec. While Berserk: Generate 1 combo point every 1.5 sec. Combo point generating abilities generate 1 additional combo point. Finishing moves restore up to 3 combo points generated over the cap. All attack and ability damage is increased by 15%.
    berserk_frenzy                 = {  82090, 384668, 1 }, -- During Berserk your combo point-generating abilities bleed the target for an additional 150% of their direct damage over 8 sec.
    berserk_heart_of_the_lion      = {  82105, 391174, 1 }, -- Reduces the cooldown of Berserk by 60 sec.
    bloodtalons                    = {  82109, 319439, 1 }, -- When you use 3 different combo point-generating abilities within 4 sec, the damage of your next 3 Rips or Ferocious Bites is increased by 25% for their full duration.
    brutal_slash                   = {  82091, 202028, 1 }, -- Strikes all nearby enemies with a massive slash, inflicting 70,440 Physical damage. Deals 15% increased damage against bleeding targets. Deals reduced damage beyond 5 targets. Awards 1 combo point.
    carnivorous_instinct           = {  82110, 390902, 2 }, -- Tiger's Fury's damage bonus is increased by 6%.
    circle_of_life_and_death       = {  82095, 400320, 1 }, -- Your damage over time effects deal their damage in 20% less time, and your healing over time effects in 15% less time.
    coiled_to_spring               = {  82085, 449537, 1 }, -- If you generate a combo point in excess of what you can store, your next Ferocious Bite or Primal Wrath deals 10% increased direct damage.
    convoke_the_spirits            = {  82114, 391528, 1 }, -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of 16 Druid spells and abilities over 4 sec. You will cast Wild Growth, Swiftmend, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    doubleclawed_rake              = {  82086, 391700, 1 }, -- Rake also applies Rake to 1 additional nearby target.
    dreadful_bleeding              = {  82117, 391045, 1 }, -- Rip damage increased by 20%.
    feral_frenzy                   = {  82108, 274837, 1 }, -- Unleash a furious frenzy, clawing your target 5 times for 28,039 Physical damage and an additional 185,420 Bleed damage over 4.8 sec. Awards 5 combo points.
    frantic_momentum               = {  82115, 391875, 2 }, -- Finishing moves have a 3% chance per combo point spent to grant 10% Haste for 6 sec.
    incarnation                    = {  82114, 102543, 1 }, -- An improved Cat Form that grants all of your known Berserk effects and lasts 20 sec. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation: Energy cost of all Cat Form abilities is reduced by 25%, and Prowl can be used once while in combat. Generate 1 combo point every 1.5 sec. Combo point generating abilities generate 1 additional combo point. Finishing moves restore up to 3 combo points generated over the cap. All attack and ability damage is increased by 15%. 
    incarnation_avatar_of_ashamane = {  82114, 102543, 1 }, -- An improved Cat Form that grants all of your known Berserk effects and lasts 20 sec. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation: Energy cost of all Cat Form abilities is reduced by 25%, and Prowl can be used once while in combat. Generate 1 combo point every 1.5 sec. Combo point generating abilities generate 1 additional combo point. Finishing moves restore up to 3 combo points generated over the cap. All attack and ability damage is increased by 15%. 
    infected_wounds                = {  82118,  48484, 1 }, -- Rake damage increased by 30%, and Rake causes an Infected Wound in the target, reducing the target's movement speed by 20% for 12 sec.
    lions_strength                 = {  82109, 391972, 1 }, -- Ferocious Bite and Rip deal 15% increased damage.
    lunar_inspiration              = {  92641, 155580, 1 }, -- Moonfire is usable in Cat Form, costs 30 energy, and generates 1 combo point.
    merciless_claws                = {  82098, 231063, 1 }, -- Shred deals 20% increased damage and Swipe deals 15% increased damage against bleeding targets.
    moment_of_clarity              = {  82100, 236068, 1 }, -- Omen of Clarity now triggers 30% more often, can accumulate up to 2 charges, and increases the damage of your next Shred, Thrash, or Swipe by an additional 15%.
    omen_of_clarity                = {  82123,  16864, 1 }, -- Your auto attacks have a high chance to cause a Clearcasting state, making your next Shred, Thrash, or Swipe cost no Energy and deal 15% more damage. Clearcasting can accumulate up to 1 charges. 
    pouncing_strikes               = {  82119, 390772, 1 }, -- While stealthed, Rake will also stun the target for 4 sec, and deal 60% increased damage for its full duration. While stealthed, Shred deals 60% increased damage, has double the chance to critically strike, and generates 1 additional combo point.
    predator                       = {  82122, 202021, 1 }, -- Tiger's Fury lasts 5 additional seconds. Your combo point-generating abilities' direct damage is increased by 40% of your Haste.
    predatory_swiftness            = {  82106,  16974, 1 }, -- Your finishing moves have a 20% chance per combo point to make your next Regrowth or Entangling Roots instant, free, and castable in all forms.
    primal_wrath                   = {  82120, 285381, 1 }, -- Finishing move that deals instant damage and applies Rip to all enemies within 10 yards. Lasts longer per combo point. 1 point : 13,729 plus Rip for 3 sec 2 points: 20,594 plus Rip for 5 sec 3 points: 27,459 plus Rip for 6 sec 4 points: 34,324 plus Rip for 8 sec 5 points: 41,188 plus Rip for 10 sec
    raging_fury                    = {  82107, 391078, 1 }, -- Tiger's Fury lasts 5 additional seconds.
    rampant_ferocity               = {  82103, 391709, 1 }, -- Ferocious Bite also deals 13,798 damage per combo point spent to all nearby enemies affected by your Rip. Spending extra Energy on Ferocious Bite increases damage dealt by up to 100%. Damage reduced beyond 5 targets.
    rip_and_tear                   = {  82093, 391347, 1 }, -- Applying Rip to a target also applies a Tear that deals 15% of the new Rip's damage over 6.4 sec.
    saber_jaws                     = {  82094, 421432, 2 }, -- When you spend extra Energy on Ferocious Bite, the extra damage is increased by 40%. 
    sabertooth                     = {  82102, 202031, 1 }, -- Ferocious Bite deals 15% increased damage. For each Combo Point spent, Ferocious Bite's primary target takes 3% increased damage from your Cat Form bleed and other periodic abilities for 4 sec.
    savage_fury                    = {  82099, 449645, 1 }, -- Tiger's Fury increases your Haste by 10% and Energy recovery rate by 25% for 6 sec.
    soul_of_the_forest             = {  82096, 158476, 1 }, -- Your finishing moves grant 2 Energy per combo point spent and deal 5% increased damage.
    sudden_ambush                  = {  82104, 384667, 1 }, -- Finishing moves have a 6% chance per combo point spent to make your next Rake or Shred deal damage as though you were stealthed. 
    survival_instincts             = {  82116,  61336, 1 }, -- Reduces all damage you take by 50% for 6 sec.
    taste_for_blood                = {  82088, 384665, 1 }, -- Ferocious Bite deals 12% increased damage and an additional 12% during Tiger's Fury. 
    thrashing_claws                = {  82098, 405300, 1 }, -- Shred deals 5% increased damage against bleeding targets and Shred and Swipe apply the Bleed damage over time from Thrash, if known.
    tigers_fury                    = {  82124,   5217, 1 }, -- Instantly restores 50 Energy, and increases the damage of all your attacks by 27% for their full duration. Lasts 15 sec.
    tigers_tenacity                = {  82107, 391872, 1 }, -- Tiger's Fury causes your next 3 finishing moves to restore 1 combo point. Tiger's Fury also increases the periodic damage of your bleeds and Moonfire by an additional 10% for their full duration.
    tireless_energy                = {  82121, 383352, 2 }, -- Maximum Energy increased by 20 and Energy regeneration increased by 5%.
    unbridled_swarm                = {  82111, 391951, 1 }, -- Adaptive Swarm has a 60% chance to split into two Swarms each time it jumps.
    veinripper                     = {  82093, 391978, 1 }, -- Rip, Rake, and Thrash last 25% longer.
    wild_slashes                   = {  82091, 390864, 1 }, -- Swipe and Thrash damage is increased by 40%.

    -- Druid of the Claw
    aggravate_wounds               = {  94616, 441829, 1 }, -- Every attack with an Energy cost that you cast extends the duration of your Dreadful Wounds by 0.6 sec, up to 8 additional sec.
    bestial_strength               = {  94611, 441841, 1 }, -- Ferocious Bite and Rampant Ferocity damage increased by 10% and Primal Wrath's direct damage increased by 60%.
    claw_rampage                   = {  94613, 441835, 1 }, -- During Berserk, Shred, Swipe, and Thrash have a 25% chance to make your next Ferocious Bite become Ravage.
    dreadful_wound                 = {  94620, 441809, 1 }, -- Ravage also inflicts a Bleed that causes 26,607 damage over 6 sec and saps its victims' strength, reducing damage they deal to you by 4%. Dreadful Wound is not affected by Circle of Life and Death. If a Dreadful Wound benefiting from Tiger's Fury is re-applied, the new Dreadful Wound deals damage as if Tiger's Fury was active.
    empowered_shapeshifting        = {  94612, 441689, 1 }, -- Frenzied Regeneration can be cast in Cat Form for 40 Energy. Bear Form reduces magic damage you take by 4%. Shred and Swipe damage increased by 6%. Mangle damage increased by 15%.
    fount_of_strength              = {  94618, 441675, 1 }, -- Your maximum Energy and Rage are increased by 20. Frenzied Regeneration also increases your maximum health by 10%.
    killing_strikes                = {  94619, 441824, 1 }, -- Ravage increases your Agility by 8% and the armor granted by Ironfur by 20% for 8 sec. Your first Tiger's Fury after entering combat makes your next Ferocious Bite become Ravage.
    packs_endurance                = {  94615, 441844, 1 }, -- Stampeding Roar's duration is increased by 25%.
    ravage                         = { 94609, 441583, 1, "druid_of_the_claw" }, -- Your auto-attacks have a chance to make your next Ferocious Bite become Ravage. Ravage
    ruthless_aggression            = {  94619, 441814, 1 }, -- Ravage increases your auto-attack speed by 35% for 6 sec.
    strike_for_the_heart           = {  94614, 441845, 1 }, -- Shred, Swipe, and Mangle's critical strike chance and critical strike damage are increased by 15%. 
    tear_down_the_mighty           = {  94614, 441846, 1 }, -- The cooldown of Feral Frenzy is reduced by 10 sec.
    wildpower_surge                = {  94612, 441691, 1 }, -- Shred and Swipe grant Ursine Potential. When you have 8 stacks, the next time you transform into Bear Form, your next Mangle deals 300% increased damage or your next Swipe deals 75% increased damage. Either generates 15 extra Rage.
    wildshape_mastery              = {  94610, 441678, 1 }, -- Ironfur and Frenzied Regeneration persist in Cat Form. When transforming from Bear to Cat Form, you retain 80% of your Bear Form armor and health for 6 sec. For 6 sec after entering Bear Form, you heal for 10% of damage taken over 8 sec. 

    -- Wildstalker
    bond_with_nature               = {  94625, 439929, 1 }, -- Healing you receive is increased by 4%.
    bursting_growth                = {  94630, 440120, 1 }, -- When Bloodseeker Vines expire or you use Ferocious Bite on their target they explode in thorns, dealing 31,084 physical damage to nearby enemies. Damage reduced above 5 targets. When Symbiotic Blooms expire or you cast Rejuvenation on their target flowers grow around their target, healing them and up to 3 nearby allies for 5,518.
    entangling_vortex              = {  94622, 439895, 1 }, -- Enemies pulled into Ursol's Vortex are rooted in place for 3 sec. Damage may cancel the effect.
    flower_walk                    = {  94622, 439901, 1 }, -- During Barkskin your movement speed is increased by 10% and every second flowers grow beneath your feet that heal up to 3 nearby injured allies for 5,206.
    harmonious_constitution        = {  94625, 440116, 1 }, -- Your Regrowth's healing to yourself is increased by 25%.
    hunt_beneath_the_open_skies    = {  94629, 439868, 1 }, -- Damage and healing while in Cat Form increased by 3%. Moonfire and Sunfire damage increased by 10%.
    implant                        = {  94628, 440118, 1 }, -- When you gain or lose Tiger's Fury, your next single-target melee ability causes a Bloodseeker Vine to grow on the target for 6 sec.
    lethal_preservation            = {  94624, 455461, 1 }, -- When you remove an effect with Soothe or Remove Corruption, gain a combo point and heal for 4% of your maximum health. If you are at full health an injured party or raid member will be healed instead.
    resilient_flourishing          = {  94631, 439880, 1 }, -- Bloodseeker Vines and Symbiotic Blooms last 2 additional sec. When a target afflicted by Bloodseeker Vines dies, the vines jump to a valid nearby target for their remaining duration.
    root_network                   = {  94631, 439882, 1 }, -- Each active Bloodseeker Vine increases the damage your abilities deal by 2%. Each active Symbiotic Bloom increases the healing of your spells by 2%.
    strategic_infusion             = {  94623, 439890, 1 }, -- Tiger's Fury and attacking from Prowl increase the chance for Shred, Rake, and Swipe to critically strike by 8% for 6 sec. Casting Regrowth increases the chance for your periodic heals to critically heal by 8% for 10 sec.
    thriving_growth                = { 94626, 439528, 1, "wildstalker" }, -- Rip and Rake damage has a chance to cause Bloodseeker Vines to grow on the victim, dealing 49,441 Bleed damage over 6 sec. Wild Growth and Regrowth healing has a chance to cause Symbiotic Blooms to grow on the target, healing for 24,915 over 6 sec. Multiple instances of these can overlap.
    twin_sprouts                   = {  94628, 440117, 1 }, -- When Bloodseeker Vines or Symbiotic Blooms grow, they have a 20% chance to cause another growth of the same type to immediately grow on a valid nearby target.
    vigorous_creepers              = {  94627, 440119, 1 }, -- Bloodseeker Vines increase the damage your abilities deal to affected enemies by 5%. Symbiotic Blooms increase the healing your spells do to affected targets by 20%.
    wildstalkers_power             = {  94621, 439926, 1 }, -- Rip and Ferocious Bite damage increased by 5%. Rejuvenation healing increased by 10%.
} )

-- PvP Talents
spec:RegisterPvpTalents( { 
    ferocious_wound      =  611, -- (236020) 
    freedom_of_the_herd  =  203, -- (213200) Your Stampeding Roar clears all roots and snares from yourself and allies.
    fresh_wound          =  612, -- (203224) Rake has a 100% increased critical strike chance if used on a target that doesn’t already have Rake active.
    high_winds           = 5384, -- (200931) Increases the range of Cyclone, Typhoon, and Entangling Roots by 5 yds.
    leader_of_the_pack   = 3751, -- (202626) While in Cat Form, you increase the movement speed of raid members within 20 yards by 10%. Leader of the Pack also causes allies to heal themselves for 3% of their maximum health when they critically hit with a direct attack. The healing effect cannot occur more than once every 8 sec.
    malornes_swiftness   =  601, -- (236012) 
    savage_momentum      =  820, -- (205673) 
    strength_of_the_wild = 3053, -- (236019) 
    thorns               =  201, -- (1217017) Casting Barkskin sprouts thorns on you for until canceled. When victim to melee attacks, thorns deals 33,110 Nature damage back to the attacker. Attackers also have their movement speed reduced by 50% for 4 sec.
    tireless_pursuit     = 5647, -- (377801) For 3 sec after leaving Cat Form or Travel Form, you retain up to 40% movement speed.
    wicked_claws         =  620, -- (203242) 
} )


local mod_circle_hot = setfenv( function( x )
    return x * ( talent.circle_of_life_and_death.enabled and 0.85 or 1 )
end, state )

local mod_circle_dot = setfenv( function( x )
    return x * ( talent.circle_of_life_and_death.enabled and 0.8 or 1 )
end, state )



-- Ticks gained on refresh.
local tick_calculator = setfenv( function( t, action, pmult )
    local remaining_ticks = 0
    local potential_ticks = 0
    local remains = t.remains
    local tick_time = t.tick_time
    local ttd = min( fight_remains, target.time_to_die )

    local aura = action
    if action == "primal_wrath" then aura = "rip" end

    local duration = class.auras[ aura ].duration * ( action == "primal_wrath" and 0.5 or 1 )
    local app_duration = min( ttd, class.abilities[ action ].apply_duration or duration )
    local app_ticks = app_duration / tick_time

    remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( remains, ttd ) / tick_time
    duration = max( 0, min( remains + duration, 1.3 * duration, ttd ) )
    potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( duration, ttd ) / tick_time

    if action == "primal_wrath" and active_enemies > 1 then
        -- Current target's ticks are based on actual values.
        local total = potential_ticks - remaining_ticks

        -- Other enemies could have a different remains for other reasons.
        -- Especially SbT.
        local pw_remains = max( state.action.primal_wrath.lastCast + class.abilities.primal_wrath.max_apply_duration - query_time, 0 )

        local fresh = max( 0, active_enemies - active_dot[ aura ] )
        local dotted = max( 0, active_enemies - fresh )

        if remains == 0 then
            fresh = max( 0, fresh - 1 )
        else
            dotted = max( 0, dotted - 1 )
            pw_remains = min( remains, pw_remains )
        end

        local pw_duration = min( pw_remains + class.abilities.primal_wrath.apply_duration, 1.3 * class.abilities.primal_wrath.apply_duration )

        local targets = ns.dumpNameplateInfo()
        for guid, counted in pairs( targets ) do
            if counted then
                -- Use TTD info for enemies that are counted as targets
                ttd = min( fight_remains, max( 1, Hekili:GetDeathClockByGUID( guid ) - ( offset + delay ) ) )

                if dotted > 0 then
                    -- Dotted enemies use remaining ticks from previous primal wrath cast or target remains, whichever is shorter
                    remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( pw_remains, ttd ) / tick_time
                    dotted = dotted - 1
                else
                    -- Fresh enemies have no remaining_ticks
                    remaining_ticks = 0
                    pw_duration = class.abilities.primal_wrath.apply_duration
                end

                potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( pw_duration, ttd ) / tick_time

                total = total + potential_ticks - remaining_ticks
            end
        end
        return max( 0, total )

    elseif action == "thrash_cat" then
        local fresh = max( 0, active_enemies - active_dot.thrash_cat )
        local dotted = max( 0, active_enemies - fresh )

        return max( 0, fresh * app_ticks + dotted * ( potential_ticks - remaining_ticks ) )
    end

    return max( 0, potential_ticks - remaining_ticks )
end, state )


Hekili:EmbedAdaptiveSwarm( spec )


-- Auras
spec:RegisterAuras( {
    aquatic_form = {
        id = 276012,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Your next Ferocious Bite costs no Energy or combo points and deals the maximum damage.
    -- https://wowhead.com/beta/spell=391882
    apex_predators_craving = {
        id = 391882,
        duration = 15,
        max_stack = 1,
        copy = 339140
    },
    -- Your Rip and Rake each cause affected enemies to take $s1% increased damage from your abilities.
    ashamanes_guidance = {
        id = 421442,
        duration = 3600,
        max_stack = 1,
    },
    -- Armor increased by $w4%.; Stamina increased by $1178s2%.; Immune to Polymorph effects.$?$w13<0[; Arcane damage taken reduced by $w14% and all other magic damage taken reduced by $w13%.][]
    bear_form = {
        id = 5487,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap. All attack and ability damage is increased by $s3%.
    berserk = {
        id = 106951,
        duration = 15,
        max_stack = 1,
        copy = { 279526, "berserk_cat" },
        multiplier = 1.5,
    },
    -- Bleeding for $w1 damage every $t1 sec.
    bloodseeker_vines = {
        id = 439531,
        duration = function() return mod_circle_dot( talent.resilient_flourishing.enabled and 8 or 6 ) end,
        tick_time = mod_circle_dot( 2.0 ),
        max_stack = 1
    },
    overflowing_power = {
        id = 405189,
        duration = 10,
        max_stack = 3,
        --[[meta = {
            stack = function( t )
                if buff.bs_inc.down then return 0 end
                local deficit = combo_points.deficit
                if deficit > 0 then return t.count end
                return min( 3, t.count + max( 0, floor( ( query_time - t.applied ) / 1.5 ) ) )
            end,
            stacks = function( t )
                return t.stack
            end
        }--]]
    },

    -- Alias for Berserk vs. Incarnation
    bs_inc = {
        alias = { "berserk", "incarnation" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
        duration = function () return talent.incarnation.enabled and 20 or 15 end,
    },
    bloodtalons = {
        id = 145152,
        max_stack = 3,
        duration = 30,
        multiplier = 1.3,
    },
    -- Autoattack damage increased by $w4%.  Immune to Polymorph effects.  Movement speed increased by $113636s1% and falling damage reduced.
    -- https://wowhead.com/beta/spell=768
    cat_form = {
        id = 768,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Taking damage will grant $102352m1 healing every $102352t sec for $102352d.
    -- https://wowhead.com/beta/spell=102351
    cenarion_ward = {
        id = 102351,
        duration = 30,
        max_stack = 1
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=102352
    cenarion_ward_hot = {
        id = 102352,
        duration = 8,
        type = "Magic",
        max_stack = 1,
        dot = "buff"
    },
    -- Your next Shred, Thrash, or $?s202028[Brutal Slash][Swipe] costs no Energy$?s236068[ and deals $s3% increased damage][].
    -- https://wowhead.com/beta/spell=135700
    clearcasting = {
        id = 135700,
        duration = 15,
        type = "Magic",
        max_stack = function() return 1 + talent.moment_of_clarity.rank + talent.tranquil_mind.rank end,
        multiplier = function() return talent.moment_of_clarity.enabled and 1.15 or 1 end,
    },
    -- Your next Ferocious Bite or Primal Wrath deals $s1% increased direct damage.
    coiled_to_spring = {
        id = 449538,
        duration = 15.0,
        max_stack = 1,
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=200389
    cultivation = {
        id = 200389,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Disoriented and invulnerable.
    -- https://wowhead.com/beta/spell=33786
    cyclone = {
        id = 33786,
        duration = 5,
        mechanic = "banish",
        type = "Magic",
        max_stack = 1
    },
    -- Increased movement speed by $s1% while in Cat Form.
    -- https://wowhead.com/beta/spell=1850
    dash = {
        id = 1850,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Bleeding for $w1 damage every $t1 seconds. Weakened, dealing $w2% less damage to $@auracaster.
    dreadful_wound = {
        id = 451177,
        duration = 6,
        tick_time = 2,
        pandemic = true,
        mechanic = "bleed",
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Rooted.$?<$w2>0>[ Suffering $w2 Nature damage every $t2 sec.][]
    -- https://wowhead.com/beta/spell=339
    entangling_roots = {
        id = 339,
        duration = 30,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Bleeding for $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=274838
    feral_frenzy = {
        id = 274838,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,

            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        }
    },
    -- Increases speed and all healing taken by $w1%.
    forestwalk = {
        id = 400126,
        duration = 6.0,
        max_stack = 1,
    },
    -- Talent: Haste increased by $s1%.
    -- https://wowhead.com/beta/spell=391876
    frantic_momentum = {
        id = 391876,
        duration = 6,
        max_stack = 1
    },
    -- Bleeding for $w1 damage every $t sec.
    -- https://wowhead.com/beta/spell=391140
    frenzied_assault = {
        id = 391140,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=6795
    growl = {
        id = 6795,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    -- Talent: Abilities not associated with your specialization are substantially empowered.
    -- https://wowhead.com/beta/spell=108291
    heart_of_the_wild = {
        id = 108291,
        duration = 45,
        type = "Magic",
        max_stack = 1,
        copy = { 108292, 108293, 108294 }
    },
    -- Talent: Asleep.
    -- https://wowhead.com/beta/spell=2637
    hibernate = {
        id = 2637,
        duration = 40,
        mechanic = "sleep",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=99
    incapacitating_roar = {
        id = 99,
        duration = 3,
        mechanic = "incapacitate",
        max_stack = 1
    },
    -- Talent: Energy costs reduced by $w3%.$?s343223[    Finishing moves have a $w1% chance per combo point spent to refund $343216s1 combo $lpoint:points;.    Rake and Shred deal damage as though you were stealthed.][]    $?s384668[Combo point-generating abilities bleed the target for an additonal $384668s2% of their damage over $340056d.][]
    -- https://wowhead.com/beta/spell=102543
    incarnation_avatar_of_ashamane = {
        id = 102543,
        duration = 20,
        max_stack = 1,
        copy = { "incarnation", "incarnation_king_of_the_jungle" }
    },
    jungle_stalker = {
        id = 252071,
        duration = 30,
        max_stack = 1,
        copy = "incarnation_avatar_of_ashamane_prowl"
    },
    -- Talent: Movement speed slowed by $w1%.$?e1[ Healing taken reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=58180
    infected_wounds = {
        id = 58180,
        duration = 12,
        type = "Disease",
        max_stack = function () return pvptalent.wicked_claws.enabled and 2 or 1 end,
    },
    -- Talent: Mana costs reduced $w1%.
    -- https://wowhead.com/beta/spell=29166
    innervate = {
        id = 29166,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Armor increased by ${$w1*$AGI/100}.
    -- https://wowhead.com/beta/spell=192081
    ironfur = {
        id = 192081,
        duration = 7,
        type = "Magic",
        max_stack = 1
    },
    -- Agility increased by $w1% and armor granted by Ironfur increased by $w2%.
    killing_strikes = {
        id = 441825,
        duration = 8.0,
        max_stack = 1,
    },
    maim = {
        id = 22570,
        duration = function() return 1 + combo_points.current end,
        max_stack = 1,
    },
    -- Talent: Rooted.
    -- https://wowhead.com/beta/spell=102359
    mass_entanglement = {
        id = 102359,
        duration = 10,
        tick_time = 2.0,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=385787
    matted_fur = {
        id = 385787,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=5211
    mighty_bash = {
        id = 5211,
        duration = 4,
        mechanic = "stun",
        max_stack = 1
    },
    -- Suffering $w1 Arcane damage every $t1 sec.
    -- https://wowhead.com/beta/spell=155625
    moonfire_cat = {
        id = 155625,
        duration = function () return mod_circle_dot( 18 ) end,
        tick_time = function() return mod_circle_dot( 2 ) * haste end,
        max_stack = 1,
        copy = "lunar_inspiration",
        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,
            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        }
    },
    -- Suffering $w2 Arcane damage every $t2 seconds.
    -- https://wowhead.com/beta/spell=164812
    moonfire = {
        id = 164812,
        duration = function () return mod_circle_dot( 16 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Spell damage increased by $s9%.; Immune to Polymorph effects.$?$w3>0[; Armor increased by $w3%.][]$?$w12<0[; Arcane damage taken reduced by $w13% and all other magic damage taken reduced by $w12%.][]
    moonkin_form = {
        id = 24858,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $?s137012[Single-target healing also damages a nearby enemy target for $w3% of the healing done][Single-target damage also heals a nearby friendly target for $w3% of the damage done].
    -- https://wowhead.com/beta/spell=124974
    natures_vigil = {
        id = 124974,
        duration = 15,
        max_stack = 1
    },
    predatory_swiftness = {
        id = 69369,
        duration = 12,
        type = "Magic",
        max_stack = 1,
    },
    -- Stub for snapshot calcs. ???
    primal_wrath = {
        id = 285381,
        duration = function () return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 2 + 2 * combo_points.current ) end,
        tick_time = function () return mod_circle_dot( 2 ) * haste end,
        meta = {
            remains = function () return dot.rip.remains end,
            applied = function () return dot.rip.applied end
        }
    },
    -- Stealthed.
    -- https://wowhead.com/beta/spell=5215
    prowl_base = {
        id = 5215,
        duration = 3600,
        multiplier = function() return talent.pouncing_strikes.enabled and 1.6 or 1 end,
    },
    prowl_incarnation = {
        id = 102547,
        duration = 3600,
        multiplier = function() return talent.pouncing_strikes.enabled and 1.6 or 1 end,
    },
    prowl = {
        alias = { "prowl_base", "prowl_incarnation" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600
    },
    -- Talent: Bleeding for $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=155722
    rake = {
        id = 155722,
        duration = function () return mod_circle_dot( ( talent.veinripper.enabled and 1.25 or 1 ) * 15 ) end,
        tick_time = function() return mod_circle_dot( 3 ) * haste end,
        mechanic = "bleed",
        copy = "rake_bleed",

        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,

            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        }
    },
    ravage = {
        id = 441585,
        duration = 20,
        max_stack = 1,
        copy = "ravage_fb"
    },
    ravage_upon_combat = {
        duration = 3600,
        max_stack = 1
    },
    -- Heals $w2 every $t2 sec.
    -- https://wowhead.com/beta/spell=8936
    regrowth = {
        id = 8936,
        duration = function () return mod_circle_hot( 12 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Healing $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=155777
    rejuvenation_germination = {
        id = 155777,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Healing $s1 every $t sec.
    -- https://wowhead.com/beta/spell=364686
    renewing_bloom = {
        id = 364686,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Bleeding for $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=1079
    rip = {
        id = 1079,
        duration = function () return mod_circle_dot( ( talent.veinripper.enabled and 1.25 or 1 ) * ( 4 + ( combo_points.current * 4 ) ) ) end,
        tick_time = function() return mod_circle_dot( 2 ) * haste end,
        mechanic = "bleed",
        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,

            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        }
    },
    -- Auto-attack speed increased by $w1%.
    ruthless_aggression = {
        id = 441817,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage over time from $@auracaster increased by $w1%.
    sabertooth = {
        id = 391722,
        duration = 4,
        max_stack = 1,
    },
    -- Haste increased by $s1% and Energy recovery rate increased by $s2%.
    savage_fury = {
        id = 449646,
        duration = 6.0,
        max_stack = 1,
    },
    shadowmeld = {
        id = 58984,
        duration = 3600,
    },
    -- Dealing $s1 every $t1 sec.
    -- https://wowhead.com/beta/spell=363830
    sickle_of_the_lion = {
        id = 363830,
        duration = 10,
        tick_time = 1,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Interrupted.
    -- https://wowhead.com/beta/spell=97547
    solar_beam = {
        id = 97547,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=207386
    spring_blossoms = {
        id = 207386,
        duration = 6,
        max_stack = 1
    },
     -- Movement speed increased by $s1%.
     stampeding_roar = {
        id = 106898,
        duration = function() return talent.packs_endurance.enabled and 10 or 8 end,
        max_stack = 1,
    },
    -- Suffering $w2 Astral damage every $t2 sec.
    -- https://wowhead.com/beta/spell=202347
    stellar_flare = {
        id = 202347,
        duration = 24,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Rake or Shred will deal damage as though you were stealthed.
    -- https://wowhead.com/beta/spell=391974
    sudden_ambush = {
        id = 391974,
        duration = 15,
        max_stack = 1,
        copy = 340698
    },
    symbiotic_relationship = {
        id = 474754,
        duration = 3600,
        dot = "buff",
        friendly = true,
        max_stack = 1,
    },
    -- Talent: Suffering $w2 Nature damage every $t2 seconds.
    -- https://wowhead.com/beta/spell=164815
    sunfire = {
        id = 164815,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $50322s1%.
    -- https://wowhead.com/beta/spell=61336
    survival_instincts = {
        id = 61336,
        duration = 6,
        max_stack = 1
    },
    -- Bleeding for $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=391356
    tear = {
        id = 391356,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Melee attackers take Nature damage when hit and their movement speed is slowed by $232559s1% for $232559d.
    -- https://wowhead.com/beta/spell=305497
    thorns = {
        id = 305497,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Suffering $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=192090
    thrash_bear = {
        id = 192090,
        duration = function () return mod_circle_dot( 15 ) end,
        tick_time = function () return mod_circle_dot( 3 ) * haste end,
        max_stack = 3,
    },
    thrash_cat = {
        id = 405233,
        duration = function () return mod_circle_dot( ( talent.veinripper.enabled and 1.25 or 1 ) * 15 ) end,
        tick_time = function() return mod_circle_dot( 3 ) * haste end,
        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,

            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        },
        copy = { "thrash", 106830 }
    },
    -- Talent: Increased movement speed by $s1% while in Cat Form, reducing gradually over time.
    -- https://wowhead.com/beta/spell=252216
    tiger_dash = {
        id = 252216,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Attacks deal $s1% additional damage for their full duration.
    -- https://wowhead.com/beta/spell=5217
    tigers_fury = {
        id = 5217,
        duration = function() return 10 + ( talent.predator.enabled and 5 or 0 ) + ( talent.raging_fury.enabled and 5 or 0 ) end,
        multiplier = function() return 1.15 + state.conduit.carnivorous_instinct.mod * 0.01 + state.talent.carnivorous_instinct.rank * 0.06 end,
    },
    -- Talent: Your next finishing move restores $391874s1 combo $Lpoint:points;.
    -- https://wowhead.com/beta/spell=391873
    tigers_tenacity = {
        id = 391873,
        duration = 15,
        max_stack = 3
    },
    -- Immune to Polymorph effects.  Movement speed increased.
    -- https://wowhead.com/beta/spell=783
    travel_form = {
        id = 783,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Dazed.
    -- https://wowhead.com/beta/spell=61391
    typhoon = {
        id = 61391,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed slowed by $s1% and winds impeding movement.
    -- https://wowhead.com/beta/spell=102793
    ursols_vortex = {
        id = 102793,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Flying to an ally's position.
    -- https://wowhead.com/beta/spell=102401
    wild_charge = {
        id = 102401,
        duration = 0.5,
        max_stack = 1
    },
    -- Talent: Heals $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=48438
    wild_growth = {
        id = 48438,
        duration = 7,
        type = "Magic",
        max_stack = 1
    },
    -- You retain $w2% increased armor and $w3% increased Stamina from Bear Form.
    wildshape_mastery = {
        id = 441685,
        duration = 6.0,
        max_stack = 1,
    },

    any_form = {
        alias = { "bear_form", "cat_form", "moonkin_form" },
        duration = 3600,
        aliasMode = "first",
        aliasType = "buff",
    },

    -- PvP Talents
    ferocious_wound = {
        id = 236021,
        duration = 30,
        max_stack = 2,
    },
    high_winds = {
        id = 200931,
        duration = 4,
        max_stack = 1,
    },
    king_of_the_jungle = {
        id = 203059,
        duration = 24,
        max_stack = 3,
    },
    leader_of_the_pack = {
        id = 202636,
        duration = 3600,
        max_stack = 1,
    },

    -- Azerite Powers
    iron_jaws = {
        id = 276026,
        duration = 30,
        max_stack = 1,
    },
    jungle_fury = {
        id = 274426,
        duration = function () return talent.predator.enabled and 17 or 12 end,
        max_stack = 1,
    },

    -- Legendaries
    eye_of_fearful_symmetry = {
        id = 339142,
        duration = 15,
        max_stack = 2,
    }
} )


-- Snapshotting
local tf_spells = { rake = true, rip = true, thrash_cat = true, lunar_inspiration = true, primal_wrath = true }
local bt_spells = { rip = true, primal_wrath = true }
local mc_spells = { thrash_cat = true }
local pr_spells = { rake = true }
local bs_spells = { rake = true }

local stealth_dropped = 0


local function calculate_pmultiplier( spellID )
    local a = class.auras
    local tigers_fury = FindUnitBuffByID( "player", a.tigers_fury.id, "PLAYER" ) and a.tigers_fury.multiplier or 1
    local bloodtalons = FindUnitBuffByID( "player", a.bloodtalons.id, "PLAYER" ) and a.bloodtalons.multiplier or 1
    local clearcasting = state.talent.moment_of_clarity.enabled and FindUnitBuffByID( "player", a.clearcasting.id, "PLAYER" ) and a.clearcasting.multiplier or 1
    local prowling = ( FindUnitBuffByID( "player", a.prowl_base.id, "PLAYER" ) or FindUnitBuffByID( "player", a.prowl_incarnation.id, "PLAYER" ) or GetTime() - stealth_dropped < 0.2 ) and a.prowl_base.multiplier or 1
    local berserk = state.talent.berserk.enabled and FindUnitBuffByID( "player", state.talent.incarnation.enabled and a.incarnation.id or a.berserk.id, "PLAYER" ) and a.berserk.multiplier or 1

    if spellID == a.rake.id then
        return 1 * tigers_fury * prowling * berserk

    elseif spellID == a.rip.id or spellID == a.primal_wrath.id then
        return 1 * bloodtalons * tigers_fury

    elseif spellID == a.thrash_cat.id then
        return 1 * tigers_fury * clearcasting

    elseif spellID == a.lunar_inspiration.id then
        return 1 * tigers_fury

    end

    return 1
end

spec:RegisterStateExpr( "persistent_multiplier", function( act )
    local mult = 1

    act = act or this_action

    if not act then return mult end

    local a = class.auras
    if tf_spells[ act ] and buff.tigers_fury.up then mult = mult * a.tigers_fury.multiplier end
    if bt_spells[ act ] and buff.bloodtalons.up then mult = mult * a.bloodtalons.multiplier end
    if mc_spells[ act ] and talent.moment_of_clarity.enabled and buff.clearcasting.up then mult = mult * a.clearcasting.multiplier end
    if pr_spells[ act ] and ( effective_stealth or state.query_time - stealth_dropped < 0.2 ) then mult = mult * a.prowl_base.multiplier end
    if bs_spells[ act ] and talent.berserk.enabled and buff.bs_inc.up then mult = mult * a.berserk.multiplier end

    return mult
end )


local snapshots = {
    [155722] = true,
    [1079]   = true,
    [285381] = true,
    [106830] = true,
    [155625] = true
}


-- Tweaking for new Feral APL.
local rip_applied = false

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    rip_applied = false
end )

--[[spec:RegisterStateExpr( "opener_done", function ()
    return rip_applied
end )--]]


local last_bloodtalons_proc = 0
local last_bloodtalons_stack = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

    if sourceGUID == state.GUID then
        if subtype == "SPELL_AURA_REMOVED" then
            -- Track Prowl and Shadowmeld and Sudden Ambush dropping, give a 0.2s window for the Rake snapshot.
            if spellID == 58984 or spellID == 5215 or spellID == 102547 or spellID == 391974 or spellID == 340698 then
                stealth_dropped = GetTime()
            end
        elseif ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
            if snapshots[ spellID ] then
                local mult = calculate_pmultiplier( spellID )
                ns.saveDebuffModifier( spellID, mult )
                ns.trackDebuff( spellID, destGUID, GetTime(), true )

            end

        elseif subtype == "SPELL_CAST_SUCCESS" and ( spellID == class.abilities.rip.id or spellID == class.abilities.primal_wrath.id ) then
            rip_applied = true
        end

        if spellID == 145152 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REMOVED_DOSE" ) then
            local bloodtalons = GetPlayerAuraBySpellID( 145152 )
            if not bloodtalons or not bloodtalons.applications or bloodtalons.applications == 0 then
                last_bloodtalons_proc = 0
                last_bloodtalons_stack = 0
            else
                if bloodtalons.applications > last_bloodtalons_stack then last_bloodtalons_proc = GetTime() end
                last_bloodtalons_stack = bloodtalons.applications
            end
        end
    end
end )


spec:RegisterStateExpr( "last_bloodtalons", function ()
    return last_bloodtalons_proc
end )


spec:RegisterStateFunction( "break_stealth", function ()
    removeBuff( "shadowmeld" )
    if buff.prowl.up then
        setCooldown( "prowl", 6 )
        removeBuff( "prowl" )
    end
end )


-- Function to remove any form currently active.
spec:RegisterStateFunction( "unshift", function()
    if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

    removeBuff( "cat_form" )
    removeBuff( "bear_form" )
    removeBuff( "travel_form" )
    removeBuff( "moonkin_form" )
    removeBuff( "travel_form" )
    removeBuff( "aquatic_form" )
    removeBuff( "stag_form" )

    if legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent.restoration_affinity.enabled then
        applyBuff( "heart_of_the_wild" )
        applyDebuff( "player", "oath_of_the_elder_druid_icd" )
    end
end )


local affinities = {
    bear_form = "guardian_affinity",
    cat_form = "feral_affinity",
    moonkin_form = "balance_affinity",
}

-- Function to apply form that is passed into it via string.
spec:RegisterStateFunction( "shift", function( form )
    if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

    if buff.bear_form.up and form == "cat_form" and talent.wildshape_mastery.enabled then
        applyBuff( "wildshape_mastery" )
    end

    removeBuff( "cat_form" )
    removeBuff( "bear_form" )
    removeBuff( "travel_form" )
    removeBuff( "moonkin_form" )
    removeBuff( "travel_form" )
    removeBuff( "aquatic_form" )
    removeBuff( "stag_form" )
    applyBuff( form )

    if affinities[ form ] and legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down then
        applyBuff( "heart_of_the_wild" )
        applyDebuff( "player", "oath_of_the_elder_druid_icd" )
    end
end )

spec:RegisterHook( "runHandler_startCombat", function()
    if talent.killing_strikes.enabled then applyBuff( "ravage_upon_combat" ) end
end )

spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if not a or a.startsCombat then
        break_stealth()
    end

    if talent.aggravate_wounds.enabled and debuff.dreadful_wound.up and a.spendType == "energy" and a.spend > 0 then
        debuff.dreadful_wound.expires = debuff.dreadful_wound.expires + 0.6
    end

    if covenant.venthyr and buff.ravenous_frenzy.up and ability ~= "ravenous_frenzy" then
        stat.haste = stat.haste + 0.01
        addStack( "ravenous_frenzy", nil, 1 )
    end

end )


spec:RegisterStateExpr( "lunar_eclipse", function ()
    return eclipse.wrath_counter
end )

spec:RegisterStateExpr( "solar_eclipse", function ()
    return eclipse.starfire_counter
end )


local bt_auras = {
    bt_brutal_slash = "brutal_slash",
    bt_moonfire = "lunar_inspiration",
    bt_rake = "rake",
    bt_shred = "shred",
    bt_swipe = "swipe_cat",
    bt_thrash = "thrash_cat"
}

local bt_generator = function( t )
    local ab = bt_auras[ t.key ]
    ab = ab and class.abilities[ ab ]
    ab = ab and ab.lastCast

    if ab and ab + 4 > query_time then
        t.count = 1
        t.expires = ab + 4
        t.applied = ab
        t.caster = "player"
        return
    end

    t.count = 0
    t.expires = 0
    t.applied = 0
    t.caster = "nobody"
end

spec:RegisterAuras( {
    bt_brutal_slash = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator
    },
    bt_moonfire = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator,
        copy = "bt_lunar_inspiration"
    },
    bt_rake = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator
    },
    bt_shred = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator
    },
    bt_swipe = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator,
        copy = { "bt_swipe_cat", "bt_brutal_slash" }
    },
    bt_thrash = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator,
        copy = "bt_thrash_cat"
    },
    bt_triggers = {
        alias = { "bt_brutal_slash", "bt_moonfire", "bt_rake", "bt_shred", "bt_swipe", "bt_thrash" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 4,
    },
} )


local LycarasHandler = setfenv( function ()
    if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
    elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
    elseif buff.bear_form.up then state:RunHandler( "barkskin" )
    elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
    else state:RunHandler( "wild_growth" ) end
end, state )

local SinfulHysteriaHandler = setfenv( function ()
    applyBuff( "ravenous_frenzy_sinful_hysteria" )
end, state )


local ComboPointPeriodic = setfenv( function()
    gain( 1, "combo_points" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    if buff.cat_form.down then
        energy.regen = 10 + ( stat.haste * 10 )
    end
    debuff.rip.pmultiplier = nil
    debuff.rake.pmultiplier = nil
    debuff.thrash_cat.pmultiplier = nil

    eclipse.reset()
    spec.SwarmOnReset()

    -- Bloodtalons
    if talent.bloodtalons.enabled then
        for bt_buff, bt_ability in pairs( bt_auras ) do
            local last = action[ bt_ability ].lastCast
            if last > last_bloodtalons_proc and now - last < 4 then
                applyBuff( bt_buff )
                buff[ bt_buff ].applied = last
                buff[ bt_buff ].expires = last + 4
            end
        end
    end

    if prev_gcd[1].feral_frenzy and now - action.feral_frenzy.lastCast < gcd.execute and combo_points.current < 5 then
        -- combo_points.current = 5
        gain( 5, "combo_points", false )
    end

    -- opener_done = nil
    last_bloodtalons = nil

    if buff.jungle_stalker.up then buff.jungle_stalker.expires = buff.bs_inc.expires end

    if buff.bs_inc.up then
        if talent.ashamanes_guidance.enabled then buff.ashamanes_frenzy.expires = buff.bs_inc.expires + 40 end

        -- Queue combo point gain events every 1.5 seconds while Incarnation/Berserk is active, starting 1.5 seconds after cast
        local tick, expires = buff.bs_inc.applied, buff.bs_inc.expires
        for i = 1.5, expires - query_time, 1.5 do
            tick = query_time + i
            if tick < expires then
                state:QueueAuraEvent( "incarnation_combo_point_perodic", ComboPointPeriodic, tick, "AURA_TICK" )
            end
        end
    end

    if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
        state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
    end
end )

spec:RegisterHook( "gain", function( amt, resource, overflow )
    if overflow == nil then overflow = true end -- nil is yes
    if amt > 0 and resource == "combo_points" then
        if combo_points.deficit < amt and overflow then -- excess points
        local combo_points_to_store = amt - combo_points.deficit
            if buff.overflowing_power.stack > ( 3 - combo_points_to_store ) or buff.bs_inc.down then -- unable to store them all
                applyBuff( "coiled_to_spring" )
            end
            if buff.bs_inc.up then addStack( "overflowing_power", nil, combo_points_to_store ) end -- store as many as possible
        end
    end
    if azerite.untamed_ferocity.enabled and amt > 0 and resource == "combo_points" then
        if talent.incarnation.enabled then gainChargeTime( "incarnation", 0.2 )
        else gainChargeTime( "berserk", 0.3 ) end
    end
end )

local function comboSpender( a, r )
    if r == "combo_points" and a > 0 then
        if talent.soul_of_the_forest.enabled then
            gain( a * 2, "energy" )
        end

        if buff.overflowing_power.up then
            gain( buff.overflowing_power.stack, "combo_points" )
            removeBuff( "overflowing_power" )
        end

        if buff.tigers_tenacity.up then
            removeStack( "tigers_tenacity" )
            gain( 1, "combo_points" )
        end

        if talent.predatory_swiftness.enabled and a >= 5 then
            applyBuff( "predatory_swiftness" )
        end

        -- Legacy
        if legendary.frenzyband.enabled then
            reduceCooldown( talent.incarnation.enabled and "incarnation" or "berserk", 0.3 )
        end

        if set_bonus.tier29_4pc > 0 then
            applyBuff( "sharpened_claws", nil, a )
        end
    end
end

spec:RegisterHook( "spend", comboSpender )



local combo_generators = {
    brutal_slash      = true,
    feral_frenzy      = true,
    lunar_inspiration = true,
    rake              = true,
    shred             = true,
    swipe_cat         = true,
    thrash_cat        = true
}

spec:RegisterStateExpr( "active_bt_triggers", function ()
    if not talent.bloodtalons.enabled then return 0 end
    return buff.bt_triggers.stack
end )


local bt_remainingTime = {}

spec:RegisterStateFunction( "time_to_bt_triggers", function( n )
    if not talent.bloodtalons.enabled or buff.bt_triggers.stack == n then return 0 end
    if buff.bt_triggers.stack < n then return 3600 end

    table.wipe( bt_remainingTime )

    for bt_aura in pairs( bt_auras ) do
        local rem = buff[ bt_aura ].remains
        if rem > 0 then bt_remainingTime[ bt_aura ] = rem end
    end

    table.sort( bt_remainingTime )
    return bt_remainingTime[ n ]
end )

--[[ spec:RegisterStateExpr( "will_proc_bloodtalons", function ()
    if not talent.bloodtalons.enabled then return false end

    local count = 0
    for bt_buff, bt_ability in pairs( bt_auras ) do
        if buff[ bt_buff ].up then
            count = count + 1
        end
    end

    if count > 2 then return true end
end )

spec:RegisterStateFunction( "proc_bloodtalons", function()
    for aura in pairs( bt_auras ) do
        removeBuff( aura )
    end

    applyBuff( "bloodtalons", nil, 2 )
    last_bloodtalons = query_time
end ) ]]

spec:RegisterStateFunction( "check_bloodtalons", function ()
    if buff.bt_triggers.stack > 2 then
        removeBuff( "bt_triggers" )
        applyBuff( "bloodtalons", nil, 3 )
    end
end )


spec:RegisterStateTable( "druid", setmetatable( {},{
    __index = function( t, k )
        if k == "catweave_bear" then return false
        elseif k == "owlweave_bear" then return false
        elseif k == "owlweave_cat" then
            return talent.balance_affinity.enabled and settings.owlweave_cat or false
        elseif k == "no_cds" then return not toggle.cooldowns
        elseif k == "primal_wrath" then return class.abilities.primal_wrath
        elseif k == "lunar_inspiration" then return debuff.lunar_inspiration
        elseif k == "delay_berserking" then return settings.delay_berserking
        elseif debuff[ k ] ~= nil then return debuff[ k ]
        end
    end
} ) )


spec:RegisterStateExpr( "bleeding", function ()
    return debuff.rake.up or debuff.rip.up or debuff.thrash_bear.up or debuff.thrash_cat.up or debuff.feral_frenzy.up or debuff.sickle_of_the_lion.up
end )

spec:RegisterStateExpr( "effective_stealth", function ()
    return buff.prowl.up or buff.incarnation.up or buff.shadowmeld.up or buff.sudden_ambush.up
end )


-- The War Within
spec:RegisterGear( "tww2", 229310, 229308, 229306, 229307, 229305  )
spec:RegisterAuras( {
    -- https://www.wowhead.com/ptr-2/spell=1217236/winning-streak
    -- Your spells and abilities have a chance to activate a Winning Streak! increasing the damage of your Ferocious Bite, Rip, and Primal Wrath by 3% stacking up to 10 times. Ferocious Bite, Rip, and Primal Wrath have a 15% chance to remove Winning Streak!
    winning_streak = {
    id = 1217236,
    duration = 10,
    max_stack = 10,
    },

    big_winner = {
    -- https://www.wowhead.com/ptr-2/spell=1217245/big-winner
    id = 1217245,
    duration = 6,
    max_stack = 1,
    },

} )

-- Legendaries.  Ugh.
spec:RegisterGear( "ailuro_pouncers", 137024 )
spec:RegisterGear( "behemoth_headdress", 151801 )
spec:RegisterGear( "chatoyant_signet", 137040 )
spec:RegisterGear( "ekowraith_creator_of_worlds", 137015 )
spec:RegisterGear( "fiery_red_maimers", 144354 )
spec:RegisterGear( "luffa_wrappings", 137056 )
spec:RegisterGear( "soul_of_the_archdruid", 151636 )
spec:RegisterGear( "the_wildshapers_clutch", 137094 )

-- Dragonflight
spec:RegisterGear( "tier29", 200354, 200356, 200351, 200353, 200355 )
spec:RegisterAura( "sharpened_claws", {
    id = 394465,
    duration = 4,
    max_stack = 1
} )

-- Tier 30
spec:RegisterGear( "tier30", 202518, 202516, 202515, 202514, 202513 )
-- 2 pieces (Feral) : Your auto-attacks have a 25% chance to grant Shadows of the Predator, increasing your Agility by 1%. Each application past 5 has an increasing chance to reset to 2 stacks.
spec:RegisterAura( "shadows_of_the_predator", {
    id = 408340,
    duration = 20,
    max_stack = 12
} )
-- 4 pieces (Feral) : When a Shadows of the Predator application resets stacks, you gain 5% increased Agility and you generate 1 combo point every 1.5 secs for 6 sec.
spec:RegisterAura( "predator_revealed", {
    id = 408468,
    duration = 6,
    tick_time = 1.5,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207252, 207253, 207254, 207255, 207257, 217193, 217195, 217191, 217192, 217194 )
-- (2) Feral Frenzy grants Smoldering Frenzy, increasing all damage you deal by $422751s1% for $422751d.
-- (4) Feral Frenzy's cooldown is reduced by ${$s1/-1000} sec. During Smoldering Frenzy, enemies burn for $422751s6% of damage you deal as Fire over $422779d.
spec:RegisterAuras( {
    smoldering_frenzy = {
        id = 422751,
        duration = 8,
        max_stack = 1
    },
    burning_frenzy = {
        id = 422779,
        duration = 10,
        max_stack = 1
    }
} )

-- Legion Sets (for now).
spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )
    spec:RegisterAura( "apex_predator", {
        id = 252752,
        duration = 25
     } ) -- T21 Feral 4pc Bonus.

spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 )
spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )


local function calculate_damage( coefficient, masteryFlag, armorFlag, critChanceMult )
    local feralAura = 1
    local armor = armorFlag and 0.7 or 1
    local crit = min( ( 1 + state.stat.crit * 0.01 * ( critChanceMult or 1 ) ), 2 )
    local vers = 1 + state.stat.versatility_atk_mod
    local mastery = masteryFlag and ( 1 + state.stat.mastery_value * 0.01 ) or 1
    local tf = state.buff.tigers_fury.up and class.auras.tigers_fury.multiplier or 1

    return coefficient * state.stat.attack_power * crit * vers * mastery * feralAura * armor * tf
end

-- Force reset when Combo Points change, even if recommendations are in progress.
spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( _, _, powerType )
    if powerType == "COMBO_POINTS" then
        Hekili:ForceUpdate( powerType, true )
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Your skin becomes as tough as bark, reducing all damage you take by $s1% and preventing damage from delaying your spellcasts. Lasts $d.    Usable while stunned, frozen, incapacitated, feared, or asleep, and in all shapeshift forms.
    barkskin = {
        id = 22812,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "barkskin" )

            if legendary.the_natural_orders_will.enabled and buff.bear_form.up then
                applyBuff( "ironfur" )
                applyBuff( "frenzied_regeneration" )
            end

            if talent.matted_fur.enabled then applyBuff( "matted_fur" ) end
        end
    },

    -- Shapeshift into Bear Form, increasing armor by $m4% and Stamina by $1178s2%, granting protection from Polymorph effects, and increasing threat generation.    The act of shapeshifting frees you from movement impairing effects.
    bear_form = {
        id = 5487,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = -25,
        spendType = "rage",

        startsCombat = false,

        essential = true,
        noform = "bear_form",

        handler = function ()
            shift( "bear_form" )
            if talent.ursine_vigor.enabled or conduit.ursine_vigor.enabled then applyBuff( "ursine_vigor" ) end
        end,
    },

    -- Talent: Go Berserk for $d. While Berserk:    Finishing moves have a $343223s1% chance per combo point spent to refund $343216s1 combo $lpoint:points;.    Swipe generates $s3 additional combo $Lpoint:points;.    Rake and Shred deal damage as though you were stealthed.
    berserk = {
        id = 106951,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * ( talent.berserk_heart_of_the_lion.enabled and 180 or 120 ) end,
        gcd = "off",
        school = "physical",

        talent = "berserk",
        notalent = "incarnation",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if buff.cat_form.down then shift( "cat_form" ) end
            applyBuff( "berserk" )
            for i = 1.5, spec.auras.berserk.duration, 1.5 do
                state:QueueAuraEvent( "incarnation_combo_point_periodic", ComboPointPeriodic, query_time + i, "AURA_TICK" )
            end
        end,

        copy = { "berserk_cat", "bs_inc" }
    },

    -- Talent: Strikes all nearby enemies with a massive slash, inflicting $s2 Physical damage.$?a231063[ Deals $231063s1% increased damage against bleeding targets.][] Deals reduced damage beyond $s3 targets.    |cFFFFFFFFAwards $s1 combo $lpoint:points;.|r
    brutal_slash = {
        id = 202028,
        cast = 0,
        charges = 3,
        cooldown = 8,
        recharge = 8,
        hasteCD = true,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.clearcasting.up then return 0 end
            return 25 * ( buff.incarnation.up and 0.75 or 1 )
        end,
        spendType = "energy",

        talent = "brutal_slash",
        startsCombat = true,

        form = "cat_form",

        damage = function ()
            return calculate_damage( 1.476, false, true ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 )
        end,

        max_targets = 5,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.brutal_slash.spend ) end,

        handler = function ()
            gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1 + ( allow_crit_prediction and crit_pct_current * active_enemies >= 230 and 1 or 0 ), "combo_points" )
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end

            if talent.bloodtalons.enabled then
                applyBuff( "bt_brutal_slash" )
                check_bloodtalons()
            end

            if talent.thrashing_claws.enabled and talent.thrash.enabled then
                applyDebuff( "target", "thrash_cat" ) 
                active_dot.thrash_cat = min( true_active_enemies, active_dot.thrash_cat + active_enemies  )
            end
            
            removeStack( "clearcasting" )
        end,
    },

    -- Shapeshift into Cat Form, increasing auto-attack damage by $s4%, movement speed by $113636s1%, granting protection from Polymorph effects, and reducing falling damage.    The act of shapeshifting frees you from movement impairing effects.
    cat_form = {
        id = 768,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        startsCombat = false,
        essential = true,
        noform = "cat_form",

        handler = function ()
            shift( "cat_form" )
        end,
    },

    -- Talent: Tosses the enemy target into the air, disorienting them but making them invulnerable for up to $d. Only one target can be affected by your Cyclone at a time.
    cyclone = {
        id = 33786,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.1,
        spendType = "mana",

        talent = "cyclone",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "cyclone" )
        end,
    },

    -- Shift into Cat Form and increase your movement speed by $s1% while in Cat Form for $d.
    dash = {
        id = 1850,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        toggle = "cooldowns",
        notalent = "tiger_dash",

        handler = function ()
            shift( "cat_form" )
            applyBuff( "dash" )
        end,
    },


    strength_of_the_wild = {
        id = 236716,
        cast = 0,
        cooldown = 3,
        gcd = "spell",

        pvptalent = "strength_of_the_wild",
        form = "bear_form",

        spend = 40,
        spendType = "rage",

        startsCombat = true,
        texture = 132136,

        handler = function ()
        end,

        copy = "enraged_maul"
    },


    entangling_roots = {
        id = 339,
        cast = function ()
            if buff.predatory_swiftness.up then return 0 end
            return 1.7 * ( buff.heart_of_the_wild.up and 0.7 or 1 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 136100,

        handler = function ()
            applyDebuff( "target", "entangling_roots" )
            removeBuff( "predatory_swiftness" )
        end,
    },

    -- Talent: Unleash a furious frenzy, clawing your target $m2 times for ${$274838s1*$m2} Physical damage and an additional ${$m2*$274838s3*$274838d/$274838t3} Bleed damage over $274838d.    |cFFFFFFFFAwards $s1 combo points.|r
    feral_frenzy = {
        id = 274837,
        cast = 0,
        cooldown = function() return ( set_bonus.tier31_4pc > 0 and 30 or 45 ) - ( 5 * talent.tear_down_the_mighty.rank ) end,
        gcd = "totem",
        school = "physical",

        damage = function ()
            return calculate_damage( 0.099 * 5, true, true )
        end,
        tick_damage = function ()
            return calculate_damage( 0.198 * 5, true )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.198 * 5, true )
        end,

        spend = function ()
            return 25 * ( buff.incarnation.up and 0.75 or 1 ), "energy"
        end,
        spendType = "energy",

        talent = "feral_frenzy",
        startsCombat = true,

        form = "cat_form",
        indicator = function ()
            if active_enemies > 1 and settings.cycle and target.time_to_die < longest_ttd then return "cycle" end
        end,

        handler = function ()
            gain( 5, "combo_points", false )
            applyDebuff( "target", "feral_frenzy" )
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end
            if set_bonus.tier31_2pc > 0 then applyBuff( "smoldering_frenzy" ) end
        end,

        copy = "ashamanes_frenzy"
    },

    -- Finishing move that causes Physical damage per combo point and consumes up to $?a102543[${$s2*(1+$102543s2/100)}][$s2] additional Energy to increase damage by up to 100%.       1 point  : ${$m1*1/5} damage     2 points: ${$m1*2/5} damage     3 points: ${$m1*3/5} damage     4 points: ${$m1*4/5} damage     5 points: ${$m1*5/5} damage
    ferocious_bite = {
        id = function() return buff.ravage.up and 441591 or 22568 end,
        known = 22568,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.apex_predator.up or buff.apex_predators_craving.up then return 0 end
            -- Support true/false or 1/0 through this awkward transition.
            if args.max_energy and ( type( args.max_energy ) == 'boolean' or args.max_energy > 0 ) then return 50 * ( buff.incarnation.up and 0.75 or 1 ) * ( talent.relentless_predator.enabled and 0.9 or 1 ) end
            return max( 25, min( 50 * ( buff.incarnation.up and 0.75 or 1 ), energy.current ) ) * ( talent.relentless_predator.enabled and 0.9 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,
        texture = function() return buff.ravage.up and 5927623 or 132127 end,
        form = "cat_form",

        cycle = function() return hero_tree.wildstalker and "bloodseeker_vines" or "rip" end,
        cycle_to = true,

        -- Use maximum damage.
        damage = function () 
            return calculate_damage( 1.45 * 2 , true, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1 ) * ( talent.sabertooth.enabled and 1.15 or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 ) * ( talent.lions_strength.enabled and 1.15 or 1 ) *
                ( 1 + ( talent.taste_for_blood.enabled and ( buff.tigers_fury.up and 0.24 or 0.12 ) or 0 ) ) * ( talent.bestial_strength.enabled and 1.1 or 1 ) * ( buff.coiled_to_spring.up and 1.1 or 1 )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.ferocious_bite.spend ) end,

        usable = function () return buff.apex_predator.up or buff.apex_predators_craving.up or combo_points.current > 0 end,

        handler = function ()
            if talent.coiled_to_spring.enabled then removeBuff( "coiled_to_spring" ) end
            if talent.ravage.enabled then removeBuff( "ravage" ) end
            if talent.bloodtalons.enabled then removeStack( "bloodtalons" ) end
            if talent.sabertooth.enabled then applyDebuff( "target", "sabertooth" ) end
            if state.spec.restoration and talent.master_shapeshifter.enabled and combo_points.current == 5 then gain( 175000, "mana" ) end

            if buff.apex_predator.up or buff.apex_predators_craving.up then
                applyBuff( "predatory_swiftness" )
                removeBuff( "apex_predator" )
                removeBuff( "apex_predators_craving" )
                if set_bonus.tww2 >= 4 then applyBuff( "big_winner" ) end
            else
                spend( min( 5, combo_points.current ), "combo_points" )
            end

            --Legacy / PvP
            if legendary.eye_of_fearful_symmetry.enabled and buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end
            if pvptalent.ferocious_wound.enabled and combo_points.current >= 5 then
                applyDebuff( "target", "ferocious_wound", nil, min( 2, debuff.ferocious_wound.stack + 1 ) )
            end
            -- opener_done = true
        end,

        copy = { 22568, "ferocious_bite_max", 441591, "ravage" }
    },

    -- Talent: Heals you for $o1% health over $d$?s301768[, and increases healing received by $301768s1%][].
    frenzied_regeneration = {
        id = 22842,
        cast = 0,
        charges = function () if talent.innate_resolve.enabled then return 2 end end,
        cooldown = function () return 36 * ( buff.berserk.up and talent.berserk_persistence.enabled and 0 or 1 ) * ( 1 - 0.2 * talent.reinvigoration.rank ) end,
        recharge = function () if talent.innate_resolve.enabled then return ( 36 * ( buff.berserk.up and talent.berserk_persistence.enabled and 0 or 1 ) ) end end,
        gcd = "spell",
        school = "physical",

        spend = function() return ( buff.cat_form.up and talent.empowered_shapeshifting.enabled ) and 40 or 10 end,
        spendType = function() return ( buff.cat_form.up and talent.empowered_shapeshifting.enabled ) and "energy" or "rage" end,

        talent = "frenzied_regeneration",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        form = function() return ( buff.cat_form.up and talent.empowered_shapeshifting.enabled ) and "cat_form" or "bear_form" end,
        nobuff = "frenzied_regeneration",

        handler = function ()
            applyBuff( "frenzied_regeneration" )
            gain( health.max * 0.08, "health" )
        end,
    },

    -- Taunts the target to attack you.
    growl = {
        id = 6795,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        form = "bear_form",

        handler = function ()
            applyDebuff( "target", "growl" )
        end,
    },

    -- Talent: Abilities not associated with your specialization are substantially empowered for $d.$?!s137013[    |cFFFFFFFFBalance:|r Magical damage increased by $s1%.][]$?!s137011[    |cFFFFFFFFFeral:|r Physical damage increased by $s4%.][]$?!s137010[    |cFFFFFFFFGuardian:|r Bear Form gives an additional $s7% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has ${$s9+1} charges.][]$?!s137012[    |cFFFFFFFFRestoration:|r Healing increased by $s10%, and mana costs reduced by $s12%.][]
    heart_of_the_wild = {
        id = 319454,
        cast = 0,
        cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
        gcd = "spell",
        school = "nature",

        talent = "heart_of_the_wild",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "heart_of_the_wild" )
        end,
    },

    -- Talent: Forces the enemy target to sleep for up to $d.  Any damage will awaken the target.  Only one target can be forced to hibernate at a time.  Only works on Beasts and Dragonkin.
    hibernate = {
        id = 2637,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.06,
        spendType = "mana",

        talent = "hibernate",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hibernate" )
        end,
    },

    -- Talent: Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within $A1 yards for $d. Damage will cancel the effect.
    incapacitating_roar = {
        id = 99,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "incapacitating_roar",
        startsCombat = false,

        handler = function ()
            shift( "bear_form" )
            applyDebuff( "target", "incapacitating_roar" )
        end,
    },

    -- An improved Cat Form that grants all of your known Berserk effects and lasts $d. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation:; Energy cost of all Cat Form abilities is reduced by $s3%, and Prowl can be used once while in combat.$?s343223[; Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $106951s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap.; All attack and ability damage is increased by $s4%.][];
    incarnation = {
        id = 102543,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * ( talent.berserk_heart_of_the_lion.enabled and 120 or 180 ) end,
        gcd = "off",
        school = "physical",

        talent = "incarnation",
        startsCombat = false,
        toggle = "cooldowns",
        nobuff = "incarnation", -- VoP

        handler = function ()
            if buff.cat_form.down then shift( "cat_form" ) end
            applyBuff( "incarnation" )
            applyBuff( "jungle_stalker" )
            if talent.ashamanes_guidance.enabled then applyBuff( "ashamanes_guidance", buff.incarnation.remains + 40 ) end
            setCooldown( "prowl", 0 )

            for i = 1.5, spec.auras.incarnation.duration, 1.5 do
                state:QueueAuraEvent( "incarnation_combo_point_periodic", ComboPointPeriodic, query_time + i, "AURA_TICK" )
            end

        end,

        copy = { "incarnation_avatar_of_ashamane", "Incarnation" }
    },

    -- Talent: Increases armor by ${$s1*$AGI/100} for $d.$?a231070[ Multiple uses of this ability may overlap.][]
    ironfur = {
        id = 192081,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",
        school = "nature",

        spend = 40,
        spendType = "rage",

        talent = "ironfur",
        startsCombat = false,
        form = "bear_form",

        handler = function ()
            applyBuff( "ironfur", 6 + buff.ironfur.remains )
        end,
    },

    -- Talent: Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point:       1 point  : ${$s2*1} damage, 1 sec     2 points: ${$s2*2} damage, 2 sec     3 points: ${$s2*3} damage, 3 sec     4 points: ${$s2*4} damage, 4 sec     5 points: ${$s2*5} damage, 5 sec
    maim = {
        id = 22570,
        cast = 0,
        cooldown = 20,
        gcd = "totem",
        school = "physical",

        spend = function () return 30 * ( buff.incarnation.up and 0.75 or 1 ) end,
        spendType = "energy",

        talent = "maim",
        startsCombat = false,
        form = "cat_form",

        usable = function () return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            applyDebuff( "target", "maim", combo_points.current )
            if state.spec.restoration and talent.master_shapeshifter.enabled and combo_points.current == 5 then gain( 175000, "mana" ) end
            spend( combo_points.current, "combo_points" )

            removeBuff( "iron_jaws" )

            if legendary.eye_of_fearful_symmetry.enabled and buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end

            -- opener_done = true
        end,
    },


    -- Talent: Mangle the target for $s2 Physical damage.$?a231064[ Deals $s3% additional damage against bleeding targets.][]    |cFFFFFFFFGenerates ${$m4/10} Rage.|r
    mangle = {
        id = 33917,
        cast = 0,
        cooldown = function () return ( buff.berserk_bear.up and talent.berserk_ravage.enabled and 0 or 6 ) * haste end,
        gcd = "spell",
        school = "physical",

        spend = function() return ( -10 - ( buff.gore.up and 4 or 0 ) - ( 5 * talent.soul_of_the_forest.rank ) ) * ( buff.furious_regeneration.up and 1.15 or 1 ) end,
        spendType = "rage",

        startsCombat = true,
        form = function()
            if talent.fluid_form.enabled then return end
            return "bear_form"
        end,

        handler = function ()
            removeBuff( "vicious_cycle_mangle" )
            addStack( "vicious_cycle_maul" )

            if talent.fluid_form.enabled and buff.bear_form.down then shift( "bear_form" ) end

            if talent.guardian_of_elune.enabled then applyBuff( "guardian_of_elune" ) end

            if buff.gore.up then
                gain( 4, "rage" )
                removeBuff( "gore" )
            end

            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end
            if conduit.savage_combatant.enabled then addStack( "savage_combatant", nil, 1 ) end
        end,
    },

    -- Talent: Roots the target and all enemies within $A1 yards in place for $d. Damage may interrupt the effect. Usable in all shapeshift forms.
    mass_entanglement = {
        id = 102359,
        cast = 0,
        cooldown = function () return 30  * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
        gcd = "spell",
        school = "nature",

        talent = "mass_entanglement",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mass_entanglement" )
            active_dot.mass_entanglement = max( active_dot.mass_entanglement, true_active_enemies )
        end,
    },

    -- Talent: Invokes the spirit of Ursoc to stun the target for $d. Usable in all shapeshift forms.
    mighty_bash = {
        id = 5211,
        cast = 0,
        cooldown = function () return 60 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
        gcd = "spell",
        school = "physical",

        talent = "mighty_bash",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mighty_bash" )
        end,
    },


    lunar_inspiration = {
        id = 155625,
        known = 8921,
        flash = { 8921, 155625 },
        suffix = "(Cat)",
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return 30 * ( buff.incarnation.up and 0.75 or 1 ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 136096,

        talent = "lunar_inspiration",
        form = "cat_form",

        damage = function ()
            return calculate_damage( 0.12 )
        end,
        tick_damage = function ()
            return calculate_damage( 0.12 )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.12 )
        end,

        cycle = "lunar_inspiration",
        aura = "lunar_inspiration",

        handler = function ()
            applyDebuff( "target", "lunar_inspiration" )
            debuff.lunar_inspiration.pmultiplier = persistent_multiplier
            gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1 + ( allow_crit_prediction and crit_pct_current >= 95 and 1 or 0 ), "combo_points" )
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end

            if talent.bloodtalons.enabled then
                applyBuff( "bt_moonfire" )
                check_bloodtalons()
            end
        end,

        bind = "moonfire",

        copy = { 155625, "moonfire_cat" }
    },

    -- A quick beam of lunar light burns the enemy for $164812s1 Arcane damage and then an additional $164812o2 Arcane damage over $164812d$?s238049[, and causes enemies to deal $238049s1% less damage to you.][.]$?a372567[    Hits a second target within $279620s1 yds of the first.][]$?s197911[    |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r][]
    moonfire = {
        id = 8921,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        cycle = "moonfire",
        form = "moonkin_form",

        handler = function ()
            if not buff.moonkin_form.up then unshift() end
            applyDebuff( "target", "moonfire" )
        end,

        bind = { "lunar_inspiration", "moonfire_cat" }
    },

    -- Talent: Shapeshift into $?s114301[Astral Form][Moonkin Form], increasing your armor by $m3%, and granting protection from Polymorph effects.    The act of shapeshifting frees you from movement impairing effects.
    moonkin_form = {
        id = 197625,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        talent = "moonkin_form",
        startsCombat = false,

        handler = function ()
            shift( "moonkin_form" )
        end,
    },

    -- Talent: Finishing move that deals instant damage and applies Rip to all enemies within $A1 yards. Lasts longer per combo point.       1 point  : ${$s1*2} plus Rip for ${$s2*2} sec     2 points: ${$s1*3} plus Rip for ${$s2*3} sec     3 points: ${$s1*4} plus Rip for ${$s2*4} sec     4 points: ${$s1*5} plus Rip for ${$s2*5} sec     5 points: ${$s1*6} plus Rip for ${$s2*6} sec
    primal_wrath = {
        id = 285381,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return 25 * ( buff.incarnation.up and 0.75 or 1 ) end,
        spendType = "energy",

        talent = "primal_wrath",
        startsCombat = true,

        aura = "rip",

        apply_duration = function ()
            return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 2 + 2 * combo_points.current )
        end,

        max_apply_duration = function ()
            return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 12 )
        end,

        ticks_gained_on_refresh = function()
            return tick_calculator( debuff.rip, "primal_wrath", false )
        end,

        ticks_gained_on_refresh_pmultiplier = function()
            return tick_calculator( debuff.rip, "primal_wrath", true )
        end,

        form = "cat_form",

        usable = function () return combo_points.current > 0, "no combo points" end,
        handler = function ()
            applyDebuff( "target", "rip", action.primal_wrath.apply_duration )
            active_dot.rip = active_enemies

            spend( combo_points.current, "combo_points" )
            if talent.bloodtalons.enabled then removeStack( "bloodtalons" ) end
            if talent.coiled_to_spring.enabled then removeBuff( "coiled_to_spring" ) end
            if talent.rip_and_tear.enabled then applyDebuff( "target", "tear" ) end

            if legendary.eye_of_fearful_symmetry.enabled and buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end

            -- opener_done = true
        end,
    },

    -- Shift into Cat Form and enter stealth.
    prowl = {
        id = function () return buff.incarnation.up and 102547 or 5215 end,
        known = function()
            return time == 0 or ( boss or encounter or settings.solo_prowl ) and buff.jungle_stalker.up
        end,
        cast = 0,
        cooldown = function ()
            if buff.prowl.up then return 0 end
            return 6
        end,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        nobuff = "prowl",

        usable = function ()
            Hekili:Debug( "Time(%d), Jungle Stalker(%s), Incarnation of Ashamane Prowl(%s)", time, tostring( buff.jungle_stalker.up ), tostring( buff.incarnation_avatar_of_ashamane_prowl.up ) )
            return time == 0 or ( boss or encounter or settings.solo_prowl ) and buff.jungle_stalker.up, "requires out of combat or incarnation_avatar_of_ashamane_prowl"
        end,

        handler = function ()
            shift( "cat_form" )
            applyBuff( buff.jungle_stalker.up and "prowl_incarnation" or "prowl_base" )
            removeBuff( "jungle_stalker" )
        end,

        copy = { 5215, 102547 }
    },

    -- Talent: Rake the target for $s1 Bleed damage and an additional $155722o1 Bleed damage over $155722d.$?s48484[ Reduces the target's movement speed by $58180s1% for $58180d.][]$?a231052[     While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]    |cFFFFFFFFAwards $s2 combo $lpoint:points;.|r
    rake = {
        id = 1822,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            return 35 * ( buff.incarnation.up and talent.incarnation_avatar_of_ashamane.enabled and  0.75 or 1 ), "energy"
        end,
        spendType = "energy",

        talent = "rake",
        startsCombat = true,

        cycle = "rake",
        min_ttd = 6,

        damage = function ()
            return calculate_damage( 0.16, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.infected_wounds.enabled and 1.3 or 1 ) * ( 1 + 0.05 * talent.instincts_of_the_claw.rank )
        end,
        tick_damage = function ()
            return calculate_damage( 0.2311, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.infected_wounds.enabled and 1.3 or 1 ) * ( 1 + 0.05 * talent.instincts_of_the_claw.rank )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.2311, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.infected_wounds.enabled and 1.3 or 1 ) * ( 1 + 0.05 * talent.instincts_of_the_claw.rank )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.rake.spend ) end,

        form = function()
            if talent.fluid_form.enabled then return end
            return "cat_form"
        end,

        handler = function ()
            if talent.fluid_form.enabled and buff.cat_form.down then shift( "cat_form" ) end

            applyDebuff( "target", "rake" )
            debuff.rake.pmultiplier = persistent_multiplier
            if talent.sudden_ambush.enabled then removeBuff( "sudden_ambush" ) end
            if talent.doubleclawed_rake.enabled then active_dot.rake = min( true_active_enemies, active_dot.rake + 1 ) end
            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end
            if talent.bloodtalons.enabled then
                applyBuff( "bt_rake" )
                check_bloodtalons()
            end

            gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1 + ( allow_crit_prediction and crit_pct_current >= 95 and 1 or 0 ), "combo_points" )


        end,

        copy = "rake_bleed"
    },

    -- Heals a friendly target for $s1 and another ${$o2*$<mult>} over $d.$?s231032[ Initial heal has a $231032s1% increased chance for a critical effect if the target is already affected by Regrowth.][]$?s24858|s197625[ Usable while in Moonkin Form.][]$?s33891[    |C0033AA11Tree of Life: Instant cast.|R][]
    regrowth = {
        id = 8936,
        cast = function ()
            if buff.predatory_swiftness.up then return 0 end
            return 1.5 * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.10,
        spendType = "mana",

        startsCombat = false,

        usable = function ()
            if buff.prowl.up then return false, "prowling" end
            if buff.cat_form.up and time > 0 and buff.predatory_swiftness.down then return false, "predatory_swiftness is down" end
            return true
        end,

        handler = function ()
            if buff.predatory_swiftness.down then
                unshift()
            end

            removeBuff( "predatory_swiftness" )
            removeBuff( "protector_of_the_pack" )
            applyBuff( "regrowth" )
        end,
    },

    -- Talent: Heals the target for $o1 over $d.$?s155675[    You can apply Rejuvenation twice to the same target.][]$?s33891[    |C0033AA11Tree of Life: Healing increased by $5420s5% and Mana cost reduced by $5420s4%.|R][]
    rejuvenation = {
        id = 774,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.05,
        spendType = "mana",

        talent = "rejuvenation",
        startsCombat = false,

        handler = function ()
            unshift()
            applyBuff( "rejuvenation" )
        end,
    },

    -- Talent: Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    remove_corruption = {
        id = 2782,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "arcane",

        spend = 0.10,
        spendType = "mana",

        talent = "remove_corruption",
        startsCombat = false,

        usable = function ()
            return debuff.dispellable_curse.up or debuff.dispellable_poison.up, "requires dispellable curse or poison"
        end,

        handler = function ()
            removeDebuff( "player", "dispellable_curse" )
            removeDebuff( "player", "dispellable_poison" )
        end,
    },

    -- Talent: Instantly heals you for $s1% of maximum health. Usable in all shapeshift forms.
    renewal = {
        id = 108238,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "nature",

        talent = "renewal",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            health.actual = min( health.max, health.actual + ( 0.2 * health.max ) )
        end,
    },

    -- Talent: Finishing move that causes Bleed damage over time. Lasts longer per combo point.       1 point  : ${$o1*2} over ${$d*2} sec     2 points: ${$o1*3} over ${$d*3} sec     3 points: ${$o1*4} over ${$d*4} sec     4 points: ${$o1*5} over ${$d*5} sec     5 points: ${$o1*6} over ${$d*6} sec
    rip = {
        id = 1079,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return 20 * ( buff.incarnation.up and 0.75 or 1 ) end,
        spendType = "energy",

        talent = "rip",
        startsCombat = true,

        aura = "rip",
        cycle = "rip",
        min_ttd = 9.6,

        tick_damage = function ()
            return ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * calculate_damage( 0.2512, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 ) * ( talent.lions_strength.enabled and 1.15 or 1 ) * ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * ( talent.wildstalkers_power.enabled and 1.05 or 1 )
        end,
        tick_dmg = function ()
            return ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * calculate_damage( 0.2512, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 ) * ( talent.lions_strength.enabled and 1.15 or 1 ) * ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * ( talent.wildstalkers_power.enabled and 1.05 or 1 )
        end,

        form = "cat_form",

        apply_duration = function ()
            return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 4 + 4 * combo_points.current )
        end,

        usable = function ()
            if combo_points.current == 0 then return false, "no combo points" end

            local rip_duration = settings.rip_duration or 0
            if rip_duration > 0 and target.time_to_die < rip_duration then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. rip_duration .. ")" end
            --[[ if settings.hold_bleed_pct > 0 then
                local limit = settings.hold_bleed_pct * debuff.rip.duration
                if target.time_to_die < limit then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. limit .. ")" end
            end ]]
            return true
        end,

        handler = function ()
            applyDebuff( "target", "rip" )
            debuff.rip.pmultiplier = persistent_multiplier
            if state.spec.restoration and talent.master_shapeshifter.enabled and combo_points.current == 5 then gain( 175000, "mana" ) end
            spend( combo_points.current, "combo_points" )

            if talent.bloodtalons.enabled then removeStack( "bloodtalons" ) end
            if talent.rip_and_tear.enabled then applyDebuff( "target", "tear" ) end

            if legendary.eye_of_fearful_symmetry.enabled and buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end

            

            -- opener_done = true
        end,
    },

    -- Shred the target, causing $s1 Physical damage to the target.$?a231063[ Deals $231063s2% increased damage against bleeding targets.][]$?a343232[    While stealthed, Shred deals $m3% increased damage, has double the chance to critically strike, and generates $343232s1 additional combo $lpoint:points;.][]    |cFFFFFFFFAwards $s2 combo $lpoint:points;.
    shred = {
        id = 5221,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.clearcasting.up then return 0 end
            return 40 * ( buff.incarnation.up and talent.incarnation_avatar_of_ashamane.enabled and 0.75 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,
        form = function()
            if talent.fluid_form.enabled then return end
            return "cat_form"
        end,

        damage = function ()
            return calculate_damage( 1.025, false, true, ( talent.pouncing_strikes.enabled and effective_stealth and class.auras.prowl.multiplier or 1 ) * ( 1 + ( talent.instincts_of_the_claw.rank * 0.05 )  ) * ( talent.empowered_shapeshifting and 1.06 or 1 ) * ( talent.merciless_claws.enabled and bleeding and 1.2 or 1 ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.berserk.enabled and buff.bs_inc.up and class.auras.berserk.multiplier or 1 ) )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.shred.spend ) end,

        handler = function ()
            if talent.fluid_form.enabled and buff.cat_form.down then shift( "cat_form" ) end
            if talent.thrashing_claws.enabled and talent.thrash.enabled then applyDebuff( "target", "thrash_cat" ) end
            if talent.bloodtalons.enabled then
                applyBuff( "bt_shred" )
                check_bloodtalons()
            end

            gain( 1 + ( talent.berserk.enabled and buff.bs_inc.up and 1 or 0 ) + ( talent.pouncing_strikes.enabled and buff.prowl.up and 1 or 0 ) + ( allow_crit_prediction and crit_pct_current >= 95 and 1 or 0 ), "combo_points" )

            removeStack( "clearcasting" )
        end,
    },

    -- Talent: You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for $93985d.
    skull_bash = {
        id = 106839,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "skull_bash",
        startsCombat = false,

        toggle = "interrupts",
        interrupt = true,

        form = function ()
            if talent.fluid_form.enabled then return end
            return buff.bear_form.up and "bear_form" or "cat_form"
        end,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            if talent.fluid_form.enabled and buff.bear_form.down and buff.cat_form.down then shift( "cat_form" ) end
            interrupt()
            if pvptalent.savage_momentum.enabled then
                gainChargeTime( "tigers_fury", 10 )
                gainChargeTime( "survival_instincts", 10 )
                gainChargeTime( "stampeding_roar", 10 )
            end
        end,
    },

    -- Talent: Soothes the target, dispelling all enrage effects.
    soothe = {
        id = 2908,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "nature",

        spend = 0.056,
        spendType = "mana",

        talent = "soothe",
        startsCombat = false,

        toggle = "interrupts",

        usable = function () return debuff.dispellable_enrage.up end,
        handler = function ()
            removeDebuff( "target", "dispellable_enrage" )
        end,
    },

    starsurge = {
        id = 197626,
        cast = 0,
        cooldown = function() return 10 - ( 4 * talent.starlight_conduit.rank ) end,
        gcd = "spell",

        spend = function () return ( talent.starlight_conduit.enabled and 0.003 or 0.006 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135730,
        talent = "starsurge",

        handler = function ()
            gain( 0.3 * health.max, "health" )
            if talent.master_shapeshifter.enabled then gain( 43750, "mana" ) end
            if talent.call_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid.down then
                applyBuff( "heart_of_the_wild", 15 )
                applyDebuff( "player", "oath_of_the_elder_druid" )
            end
        end,
    },

    -- Talent: Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within $A1 yards by $s1% for $d.
    stampeding_roar = {
        id = 106898,
        cast = 0,
        cooldown = function () return pvptalent.freedom_of_the_herd.enabled and 60 or 120 end,
        gcd = "spell",
        school = "physical",

        talent = "stampeding_roar",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if buff.bear_form.down and buff.cat_form.down then
                shift( "bear_form" )
            end
            applyBuff( "stampeding_roar" )
        end,
    },

    -- Form a bond with an ally. Your self-healing also heals your bonded ally for 10% of the amount healed. Your healing to your bonded ally also heals you for 8% of the amount healed.
    symbiotic_relationship = {
        id = 474750,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0.02,
        spendType = "mana",
        
        talent = "symbiotic_relationship",
        startsCombat = false,
        texture = 1408837,
        
        handler = function ()
            applyBuff( "symbiotic_relationship" )
        end,
    },

    -- Talent: A quick beam of solar light burns the enemy for $164815s1 Nature damage and then an additional $164815o2 Nature damage over $164815d$?s231050[ to the primary target and all enemies within $164815A2 yards][].$?s137013[    |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r][]
    sunfire = {
        id = 93402,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.12,
        spendType = "mana",

        talent = "sunfire",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "sunfire" )
            if talent.improved_sunfire.enabled then active_dot.sunfire = active_enemies end
        end,
    },

    -- Talent: Swipe nearby enemies, inflicting Physical damage. Damage varies by shapeshift form.$?s137011[    |cFFFFFFFFAwards $s1 combo $lpoint:points;.|r][]
    swipe_cat = {
        id = 106785,
        known = 213764,
        suffix = "(Cat)",
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.clearcasting.up then return 0 end
            return max( 0, ( 35 * ( buff.incarnation.up and 0.75 or 1 ) ) + buff.scent_of_blood.v1 )
        end,
        spendType = "energy",

        startsCombat = true,
        notalent = "brutal_slash",
        form = "cat_form",

        damage = function ()
            return calculate_damage( 0.3824, false, true ) * ( talent.merciless_claws.enabled and bleeding and 1.1 or 1 ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 ) * ( talent.merciless_claws.enabled and ( debuff.rip.up or debuff.rake.up or debuff.thrash_cat.up ) and 1.1 or 1 )
        end,

        max_targets = 5,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.swipe_cat.spend ) end,

        handler = function ()
            gain( talent.berserk.enabled and 2 or 1 + ( allow_crit_prediction and crit_pct_current * active_enemies >= 230 and 1 or 0 ), "combo_points" )

            if talent.bloodtalons.enabled then
                applyBuff( "bt_swipe" )
                check_bloodtalons()
            end

            if talent.cats_curiosity.enabled and buff.clearcasting.up then
                gain( 35 * 0.25, "energy" )
            end

            if talent.thrashing_claws.enabled then
                applyDebuff( "target", "thrash_cat" )
                active_dot.thrash_cat = max( active_enemies, active_dot.thrash_cat )
            end
            removeStack( "clearcasting" )
        end,

        copy = { 213764, "swipe" },
        bind = { "swipe_cat", "swipe_bear", "swipe", "brutal_slash" }
    },

    -- Sprout thorns for $d on the friendly target. When victim to melee attacks, thorns deals $305496s1 Nature damage back to the attacker.    Attackers also have their movement speed reduced by $232559s1% for $232559d.
    thorns = {
        id = 305497,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "nature",

        spend = 0.18,
        spendType = "mana",

        pvptalent = "thorns",
        startsCombat = false,

        handler = function ()
            applyBuff( "thorns" )
        end,
    },

    -- Talent: Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    thrash_cat = {
        id = 106830,
        known = 106832,
        suffix = "(Cat)",
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if buff.clearcasting.up then return 0 end
            return 40 * ( buff.incarnation.up and 0.75 or 1 )
        end,
        spendType = "energy",

        -- talent = "thrash",
        startsCombat = false,

        aura = "thrash_cat",
        cycle = "thrash_cat",

        damage = function ()
            return calculate_damage( 0.202, true ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 )
        end,
        tick_damage = function ()
            return calculate_damage( 0.4865, true ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.4865, true ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 )
        end,

        form = "cat_form",
        handler = function ()
            applyDebuff( "target", "thrash_cat" )

            active_dot.thrash_cat = max( active_dot.thrash, active_enemies )
            debuff.thrash_cat.pmultiplier = persistent_multiplier

            if talent.cats_curiosity.enabled and buff.clearcasting.up then
                gain( 40 * 0.25, "energy" )
            end
            removeStack( "clearcasting" )

            if talent.scent_of_blood.enabled then
                applyBuff( "scent_of_blood" )
                buff.scent_of_blood.v1 = -3 * active_enemies
            end

            -- if target.within8 then
                gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1 + ( allow_crit_prediction and crit_pct_current * active_enemies >= 230 and 1 or 0 ), "combo_points" )
            -- end

            if talent.bloodtalons.enabled then
                applyBuff( "bt_thrash" )
                check_bloodtalons()
            end
        end,

        copy = { "thrash", 106832 },
        bind = { "thrash_cat", "thrash_bear", "thrash" }
    },

    -- Talent: Shift into Cat Form and increase your movement speed by $s1%, reducing gradually over $d.
    tiger_dash = {
        id = 252216,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "physical",

        talent = "tiger_dash",
        startsCombat = false,

        handler = function ()
            shift( "cat_form" )
            applyBuff( "tiger_dash" )
        end,
    },

    -- Talent: Instantly restores $s2 Energy, and increases the damage of all your attacks by $s1% for their full duration. Lasts $d.
    tigers_fury = {
        id = 5217,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        school = "physical",

        spend = -50,
        spendType = "energy",

        talent = "tigers_fury",
        startsCombat = false,

        usable = function () return buff.tigers_fury.down or energy.deficit > 50 + energy.regen end,
        handler = function ()
            shift( "cat_form" )
            applyBuff( "tigers_fury" )
            if talent.savage_fury.enabled then applyBuff( "savage_fury" ) end
            if talent.tigers_tenacity.enabled then addStack( "tigers_tenacity", nil, 3 ) end
            if talent.killing_strikes.enabled and buff.ravage_upon_combat.up then
                applyBuff( "ravage" )
                removeBuff( "ravage_upon_combat" )
            end

            -- Legacy
            if legendary.eye_of_fearful_symmetry.enabled then
                applyBuff( "eye_of_fearful_symmetry", nil, 2 )
            end
            if azerite.jungle_fury.enabled then applyBuff( "jungle_fury" ) end
        end,
    },
} )

spec:RegisterRanges( "rake", "shred", "skull_bash", "growl", "moonfire" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageDots = false,
    damageExpiration = 3,

    potion = "tempered_potion",

    package = "Feral"
} )

--[[ TODO: Revisit due to removal of Relentless Predator.
spec:RegisterSetting( "use_funnel", false, {
    name = strformat( "%s Funnel", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ) ),
    desc = function()
        return strformat( "If checked, when %s and %s are talented and %s is |cFFFFD100not|r talented, %s will be recommended over %s unless |W%s|w needs to be "
            .. "refreshed.\n\n"
            .. "Requires %s\n"
            .. "Requires %s\n"
            .. "Requires |W|c%sno %s|r|w",
            Hekili:GetSpellLinkWithTexture( spec.talents.taste_for_blood[2] ), Hekili:GetSpellLinkWithTexture( spec.talents.relentless_predator[2] ),
            Hekili:GetSpellLinkWithTexture( spec.talents.tear_open_wounds[2] ), Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ),
            Hekili:GetSpellLinkWithTexture( spec.abilities.primal_wrath.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ),
            Hekili:GetSpellLinkWithTexture( spec.talents.taste_for_blood[2], nil, state.talent.taste_for_blood.enabled ),
            Hekili:GetSpellLinkWithTexture( spec.talents.relentless_predator[2], nil, state.talent.relentless_predator.enabled ),
            ( not state.talent.tear_open_wounds.enabled and "FF00FF00" or "FFFF0000" ),
            Hekili:GetSpellLinkWithTexture( spec.talents.tear_open_wounds[2], nil, not state.talent.tear_open_wounds.enabled ) )
    end,
    type = "toggle",
    width = "full"
} )  ]]

--[[ Currently handled by the APL
spec:RegisterSetting( "zerk_biteweave", false, {
    name = strformat( "%s Biteweave", Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ) ),
    desc = function()
        return strformat( "If checked, the default priority will recommend %s more often when %s or %s is active.\n\n"
            .. "This option may not be optimal for all situations; the default setting is unchecked.", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ),
            Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.incarnation.id ) )
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterVariable( "zerk_biteweave", function()
    return settings.zerk_biteweave ~= false
end )--]]

--[[ spec:RegisterSetting( "owlweave_cat", false, {
    name = "|T136036:0|t Attempt Owlweaving (Experimental)",
    desc = "If checked, the addon will swap to Moonkin Form based on the default priority.",
    type = "toggle",
    width = "full"
} ) ]]

spec:RegisterSetting( "rip_duration", 9, {
    name = strformat( "%s Duration", Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ) ),
    desc = strformat( "If set above |cFFFFD1000|r, %s will not be recommended if the target will die within the specified timeframe.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ) ),
    type = "range",
    min = 0,
    max = 18,
    step = 0.1,
    width = 1.5
} )

spec:RegisterSetting( "frenzy_cp", 2, {
    name = strformat( "%s: Combo Point Cap", Hekili:GetSpellLinkWithTexture( spec.abilities.feral_frenzy.id ) ),
    desc = strformat( "In the default priority, %s will only be recommended if you have fewer than the specified number of Combo Points. "
        .. "When |W%s|w or |W%s|w is active, this cap is raised by one point.\n\nDefault: |cFFFFD1002|r",
        Hekili:GetSpellLinkWithTexture( spec.abilities.feral_frenzy.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.incarnation.id ) ),
    type = "range",
    min = 1,
    max = 5,
    step = 1,
    width = 1.5
} )

spec:RegisterSetting( "vigil_damage", 50, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( class.specs[ 102 ].abilities.natures_vigil.id ) ),
    desc = strformat( "If set below |cFFFFD100100%%|r, %s may only be recommended if your health has dropped below the specified percentage.\n\n"
        .. "By default, |W%s|w also requires the |cFFFFD100Defensives|r toggle to be active.",
        Hekili:GetSpellLinkWithTexture( class.specs[ 102 ].abilities.natures_vigil.id ),
        class.specs[ 102 ].abilities.natures_vigil.name ),
    type = "range",
    min = 1,
    max = 100,
    step = 1,
    width = 1.5
} )

spec:RegisterSetting( "allow_crit_prediction", true, {
    name = strformat( "%s Combo Point Prediction", Hekili:GetSpellLinkWithTexture( 159286 ) ), -- Primal Fury
    desc = strformat( "This setting enables prediction of an additional combo point on critical strikes when talented into %s.\n\n" ..
                      "This prediction activates only when it is |cFFFFD10095%%|r certain a critical strike will occur based on your critical strike chance and the number of targets the spell will hit.",
                      Hekili:GetSpellLinkWithTexture( 159286 )
    ),
    type = "toggle",
    width = "full",
} )

spec:RegisterVariable( "allow_crit_prediction", function()
    return settings.allow_crit_prediction ~= false
end )

spec:RegisterSetting( "lazy_swipe", false, {
    name = strformat( "%s: Don't %s in AOE", Hekili:GetSpellLinkWithTexture( spec.talents.wild_slashes[2] ), Hekili:GetSpellLinkWithTexture( spec.abilities.shred.id ) ),
    desc = function()
        return strformat( "If checked, when %s is talented, the use of %s will be minimized in multi-target situations even if "
            .. "%s is talented.\n\nThis option is a DPS loss but can be easier to execute correctly.",
            Hekili:GetSpellLinkWithTexture( spec.talents.wild_slashes[2] ),
            Hekili:GetSpellLinkWithTexture( spec.abilities.shred.id ),
            Hekili:GetSpellLinkWithTexture( spec.talents.bloodtalons[2] ) )
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterVariable( "lazy_swipe", function()
    return settings.lazy_swipe ~= false
end )

spec:RegisterSetting( "regrowth", true, {
    name = strformat( "Filler %s", Hekili:GetSpellLinkWithTexture( spec.abilities.regrowth.id ) ),
    desc = strformat( "If checked, %s may be recommended when higher priority abilities are not available or recommended.\n\n"
        .. "This recommendation generally occurs at very low energy, regardless of your current health.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.regrowth.id ) ),
    type = "toggle",
    width = "full",
} )

spec:RegisterVariable( "regrowth", function()
    return settings.regrowth ~= false
end )

spec:RegisterStateExpr( "filler_regrowth", function()
    return settings.regrowth ~= false
end )

spec:RegisterSetting( "solo_prowl", false, {
    name = strformat( "Allow %s in Combat When Solo", Hekili:GetSpellLinkWithTexture( spec.abilities.prowl.id ) ),
    desc = strformat( "If checked, %s can be recommended in combat when %s is active and you are solo.\n\n"
        .. "This option is off by default because |cFFFF0000it may drop combat|r outside of a group/encounter situation.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.prowl.id ),
        Hekili:GetSpellLinkWithTexture( spec.auras.jungle_stalker.id ),
        spec.abilities.prowl.name ),
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "allow_shadowmeld", nil, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( spec.auras.shadowmeld.id ) ),
    desc = strformat( "If checked, %s can be recommended for |W%s|w players if its conditions for use are met.\n\n"
            .. "Your stealth-based abilities can be used in |W%s|w, even if your action bar does not change. |W%s|w can only be recommended in boss fights or when you "
            .. "are in a group (to avoid resetting combat).",
        Hekili:GetSpellLinkWithTexture( spec.auras.shadowmeld.id ),
        C_CreatureInfo.GetRaceInfo(4).raceName,
        spec.auras.shadowmeld.name,
        spec.auras.shadowmeld.name ),
    type = "toggle",
    width = "full",
    get = function () return not Hekili.DB.profile.specs[ 103 ].abilities.shadowmeld.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 103 ].abilities.shadowmeld.disabled = not val
    end,
} )


spec:RegisterPack( "Feral", 20250228, [[Hekili:T3t)VnoUX(3YIfNx7njowkX7ExX6uCT9DO3H(fAoG7hkASvSPJ1lYsQsYXBoe4)2FZWVejfjLSJ9E3RTOlUglrnC4W5BoK8UG7(X7UDruf5U)s4OWXJUAuWWGVz0OR)M7UT65CYD3Mhn)XOhG)inAn8F)osruc(0NtYIwGFDz2MI5WBU7273eNu99P3DVvqgogABoz(D)LGrxD3TRIxSGWAlPC(D3IT9IrHxe(1)MDZ(XF6N2n7wsuzw6UzH7MTjhb4UFy3pan76lcgDryi0SGGHJgow(4rFZfHbWJVnE9VVX3aVmye8YVl(ZW)HuKnpoBt5Uz)UyOrZwh95PKusXdpR(bJU(8DZW))V2duhDfIWBjrpUBwvuXdKQ40hQBWxFr41YVoVioRiU65MW5RViym0SVDX)7MYkli4YSIDZ(P4KfLvrjpsk0(sCq)NJkaeiBjGeRiSMEU)oKoQ((0ksrXMCOpJsxa4zwg(9YM9rg6)JuygrXHQvXPahqr2Y4eyEpAEvCwA5W8cY8S13hvD2KlxdiZ0SLtbqnDlGj7(bBTcaX2KZJxo5n3Vz5YH0FoCtU9gppQAkqewx3EXtOFYB3nB(kYCGeeJKGI40hjWyQmjd(VZZsRIItbIze8OQi4riJ1Msyq1)POI4O7tG)mgAaJ8)ibjiXqBMhHnIrwH5vOfjXpImmXff4uskc)TzfpIt6Z2ceNDZwfvofG9uelhyF0i60ZrPQjC0DAa9tkp)POKnYNomyOka79M6NhxomEDoPyjzE10OY5K0frPZFEAjPyZAJgM9uCA0NlNUMumFd05jtjp8GrBa608mk2o9X4YsCgCbjcgs7Xyi06yi0XyiSRJHWomgc9pgElJ3ylm7fva)N8KONPZAH40z6gumd(6NYEKCoRzWODjiQP2GS0lOSnzpHV4QMVG8ejLXiKTbynUNuaJKhbrOvKOIkfj0eaf3hcBW0YNtNFEw(KsqfZsoboG9)pLKusMakdphgblIryobuuqsRgYhsuzXY8yqBqjqYyVlQCv06Ous50h2eJ0DsprNp0GPSx)AwL5zzjlY2MoCXMIiSV(QVkiC0KrV8c8)9vFLNgoz0Ejqe(l0yo8OpM1z(sFxvB8FaQNYA)8i4pq6Gg)28fLc9nCEmOrrOoUvzvj7drEVzSEt)dImp4q5TKp6(YPXPZviSV8IR31YmYlV0TE0Yi0E37RHTZD09jR9wI44nz1qOi84pzzbKQtw(7XJ8KLvCHjkZDRk(NjsFnkrrw0ZIK4uYfGljCHtqo9IBwdEFCHMJhWdtYsFanImFrnqU4MYvzfv4Jf9PspSh8jch)m5ucv5ucu5tCkC6Ir4LxCZI4LhP(DGlFZhgL(80f51ZadEF)GHJpRUvORdup(IEiobgt0geARbRJkbAh2alOgk4myWn99QSP(DDb3cAd3c6eUfWXn0TB(uSQ7X0pxiYayBph(l3MxYsX9LjGuo9PQFB5JBssMEpOlq7P8acElW2)NawBmsIDZ(e4i9kW7OjVBvvvE5V5Yl3UD7WTzBbVCwaK11xcH6LKmjy0Opm6Y8STKIlItxUPeG67U5VH)gJ9G9GpDz0ncXLFhZw2qwhwJgXmjwYNbAyk44ho2yC8uGpvaCt61M8xErmS52jNs9eteEIMByukiqey)eExzfRtKbjyGwLvz5txJ(L(a2ZpmFXWcckTxozupY)AtCEozHD)wv70Qyqtq50LBkEgbtFwOOdxqwgppU6MRgJkVwFF208S40QYjg)(Mjx1Brw1WI4CO7xwqa15aY2JrisYYwauauVXM8b96FFwzzVLXpSQAkhx)0KaaI9nvpZF7nHJ0B(nJhyT1rlE2OHbHV8c2DdgOoAlIapCM)88eqdmnG5sqtKyEdqDaQRjjlOZDo50tJQ2ad0PpfdcE4xlLQkipaTVAvpyEoPA1qi4ciQIQp9XrWy3G1G(BfQpsH0qvyMyBuxHV6xgTikVk(jWaZ2iqE0YWfNX0B10fGv4hidblfZF8tx1R)BC3MQ45ymNV8I7MiMDdh07nmeZOHdJtNUmbNX61NkVwJG1snBsVViErczb7BagibRMefwrkYMwvqidxuGAw4IwZtI2oy)Ojnuz1orYoAoKKItwl6PnUgwUnohqSOQBc6zmmur0LI0Vm9(4kIeXIYjFgSSswevLbmmZlIqbFQM1AL6PeahUVQhcnaNVVcOmXpGCytch0UMgHy15LWNnVQMvrdvFlMJcso6kbneIQvyYlIkMVkkgIt4DPqxqG)9oEMJEIeNwGkJkWWfMhrdvngDA5Esf1DJ4fyUtssGpaZqgO2h98qZabaaez4e8Aq2ZG3Pxn)W26mw1t6jAbyRm9bQ8wVgaBGqivtTLIs86NRWkky1h3RHeTux0OEg6mbLy9D1CGXsxJ7alklQvFoOz)cCfM6OfTxQ60cWyoysNdQYyPwsyBuDseNUAo18MdDUXg2VpZdnhP1wH8nAVjCSh664AFpHrZuHty34dI(7UjgmmDqGCzCACjq1q6Rolr7FlMr8fSp1HEiygrXFW41G(qSdYs(egXYBm1QO4Zn6F6Cuo6(QomkIYWuV1g2CZKqnMwyg4iJDcJNsDQc1Ppd6TJxwbXGI8z9AATTKKqyJkerUbD1AD0NvCzEOYySrCrk4dpKiEarMJbQ4hYBGzmgvSwGoepBfyLKGPggdSYvxYAmsiXHNQmGqQH1cepqJJL2SBWK6aRg0MYCib958PS4fyYGYZPA8VVOet5nodwoC3SVnPe0wa68xGVAd0DyYVbaqkVCl0s6umlL2aoFUipLICsHDotHdsOaqulDFonuuwFkDo3(4N1XtP9RnR7k(mQ0YHlX4oGiAPdg6S7NUgI5NZUTiM(ZIiWXcePr)bwuk1raVYWRoDvEG2Ol85FYaFZbuQMIUW6yWE5fTE5tT0jUOysjpfdROE5P85UE97oz41qf(creERWugDrHemOmwqohkMJKXNjwkTsrM2HygawWlxdULSmUG0n6PoPRVn6RlfHx3fkI75vzS7u7nq8oQXLX8zN(081BsQIZtIjfFkyO3oL2EmaoUR8COIbDPh2jlU)Yn46RonA99BOAr6vRTE(8POAeYcNurzmyFXgcUqAT4)SpgaMQfZzSia)ZnG27wysCf)PQcBoVYISnWVq2xyKGFxNgEUqtK3(QkRYaNxRIwXP8QvyU)5JhK)hTarhNDI)Fp43d7e)E96yOSs0G1sKWxUbxuTNZ2Gla6tCj5esujnPNeX8J6672TPL3iz14H)y3hwkULeRm9BHucXfDHcZc3COYAZKqzhfdHa)uBrprj4TWq5H8kaJBEN9JG1XUTv21Lq4GGf)ozThNN6eduh4BFvaAf4pzD2p9Ofe4mFMbpVS(i881H6(8969ZBj4((9ryHmCFLmtJ7lhGtTx2jk(zrql9hQeq788(GU)efE8gfsMMwydyjF3ch0(oaCy88dVIXGoFyhgiQrozXXfJuzttin4f5yxwQ7VFUjm49DrZe9bgPLG3)QPj22ar3hMFLpAQtW9BrlKpueTGWchRSIMKzMDi0lbC1yk2gJ5VJJAmZy5rPliRJNdXc(hijrplmXfHLSugg9g(x5zLLX3NWT4ftRDPnOBiihbRBTqlPSXy8B9vnTKdJJya)sbPzj14gR82kuoz(1gktPwdQVDiBdWEdCrs47B1HHxEHr8LHmnWoFex3GDuvhc2aGPzYUhdChDjRzxQPvw3HaBn)asBr7dBD6gObmQyo4lO78LBXIlUs7a1A3mEPzAjDfszGfz8k2JwCvPKpd)my4yGN)F8hjpgNe)p3n7h)R)H)kRwmzPobWAQRH0mNqWkNzlyaUG8V2ad6KNfPvhjL00GqGMVMUgOiImBBuC1SDZO5rcGWkMK09OqhTmoHHHvvSWqcMQz1n75iqMmAyOMwByWmLpYMIzIVNXcc(Xr9AK8nZjf)jc9QUWQEO8F1oH1PP5JahPvSq1NYwgimdIyrKMeNluDsx5e0lSADLPvQQkzRGszAuom5x5tZz7213h1PDrMFF98AV9KG73QPRecUUZW1SFEurknL9iKmwA4pYwAykvhdlZOUCRlRMhWc5fE2c2BLlqgUivQ22QNHIXIAEjbdbKfQTsz)EHk0TI2yvQgxrwFow8WIcQH5wTwvDGTJTwKwljQ6vpxnt5gvkZGUJbHQyqOtmiORyqGedERsjeYOxmngGeaOYWkgYBVu)U5sh5Oma8blEjuyAz5TO(5fzISmKqZNqjHxjT0QGmrwwkrpqtAFkQhNvnwO1IhP)opJ1ZCKILDaQXIYNtRWvsWcUX(OM4fB8yuffxbdZ(1eAev)zyG1t7j8ApRN3IrtaXaE9MLQugyOaruXfmo5srMke9bO7Atc(y8l2UIGElc)quP6WpFMcPhEGLueIAXYdMerPSF)FaCI87YeVhlb(sXNIZeBPYv4sfZSdJ7QJ4L46o)T)T)eASgGiDrj(ow)Uvuw9SkNwrgEOx2FMUbRcULNlQo7sLbaV87XLQPOEVp4VtAkL7ssPz1Jyz5JBZUB4y6QL2H5(paW3LAJoX9CHhLsJguVsU2kmuhLcKFqoagAVrxdLOvwlHt(xAPocftDtcgOwPUwljVB0nS0JzuPRZ4HwNXd)1ZmEWHmJBXiWRDg3ki1MXdCmJ38l9nJhoqLxzpMXvkmp1z9f0a)IMJHaUPe(7O0Y1XyoHNwfv6Yc2lVORApm0kl1sC3Wnf8on9NFMfBNYANpj4mdpYTX8upRug9eyjN(C4Hocz1IzhFCF81oozB0ZAgk5Can2bbONU0u4JB6aBJylSousyt0YxffE9yZLRSdvP5aR0p9Ap5ttAUqO6V)kamSCXnuz9bVz8fvUkfErPKvxkJA1iWLY81KVfnljIrLzx(ddhFgs5jl5o3MV9CvlOa1OIeHHns3MF6FCr068i0Hww9OHBJpgwIrws3jE09yeVzAWLboWV3NG58fILtvmF)bMlblj06WvSAq7M99AD)FNYqYbl16RWsFucgDm79Sf65J2HOKfsufn0umgVgKA2ccZ0Om1xsk13EtqV(0mXP(WA1LdhBgZllptgTwg8iw1QcUmonBQGYkRxW(Erh6ArrloIscbeiNIK3s5ctXqNckDHIoEa2hotIkyZhWxF8cm(tKnalSp0FoXmhsEZ3IUTICeBYHPR)ESCBgOuWgSpxHrbNv18OxWJWvgCpbI0LW7AC9hq3hxUuUjKwWZNipvl2MtX6pRLvIss6vPcguiSq62NYoZQ(uZAc0R(XE9fntt71lViE8190NthyNNotnNoa5CkMbQjbwBSr1LwV3JXnKHL1)0mKOJC)7Abwu6rwLBqdOcOSLOJ)Bv3HkBRt9fY7fLJPPyblFCZ3ua2hRyoYRK)rHlaNzwQwQL6hViT63)6Z6F97v1Kpa3Pfx0F0WW3l8QjUahiGfJK4LKPrPly78tAlpdB5yrtvk30bdoR2PlSRXPdrY0Rl5WFRZch0)aXk0(smQE)OHxXStLHHEr(CojTmgvRJz0IoNZcb(2v0G(od3K3SAD7mu1oDtiE9OZG)D1yEUWccglYflUmd8QcJLMhw(xqaEv4zW)c)A(h9nHInwFRemYsCxaJvnn7t0Rup2Zak2O3t5p1YPmTAWHPYREph)kipqsHhmE0777tdaDHiyQEjaOwd8OO5sW1aq5yAvCIQfrsA2MhwvNpARfm3WomsvRLs9rz)(av(cjhPjj5I(HxXg(kzxdvln4R0g4SeNqtFDbPAtrkno5nnCXiIN58uGwsNnfmROBfPp0f5vZKvlgiUw8aQf96KmkJ0W4XcHfKr(tqybdQRGRKnPr4w(bDaL2ggmvtbQgu1EHn4231cY6yfQgOTaH1DelBUMDaBUOqNFPYCMiGzIFeUnEN)yjl)wQM1BFMGNIwXEVVHfZEnmTY2efODI3YQTuzwwveUOQUruQDmqwajCCWHG6eq1fh9wNTgt5nOFd4oWiazKl6H5GWvgWSfMbkYNH(hD8mqjagg5NRic9AADhqtLeXj4w7s81N5TrY9i4n6HN2fiR79rNOaYy2MttjQf6WS2(F)gTI0cxRSYC6rJWsEI7oxUMz8dxJ32fMarIpBqA1Jc8mZNliGNn(ircboXISpt1P7HqYYXRf6iZZAL9HBMGa1nAap5XMubJerFwJxiPdbUjeMajySLXFwo2iSuWRtpmlT4yHItnnWkUE(H)cF3UXify8G)iy4GQryjQlct)lzzeOGSdeazH(dw3asU0(g8xOEaeZ59TFmfyfFidNYOly4cjd(3M9)86qW6Q3rIID4R2V9rqvbTsUQRiXMRvOZEsA0s8nv6Av1d7rGmGZ75fKNAAI8UBFcxGr4pWJLPRdgfgE3TBbpiWjJ7ULEa)eVopROIl()oL6l6DiVX)Atm1tXYm03OOnvzCNLMVc9ua97HTbHXJMPFpiOskOV(D29d4DmbkhVvepo0Q(bFEGe2xBh2Q14QbGvFLlOo(Ka1V2ouBuvEgGUX7Db)V5KG1bF4eo9f8Xtgnz3pyHhMRo4OW)wVR5nqU6x4CypYoin20QgW1XwATbWDituhoObCRFX(csLDUPbmvEZ(c0taEQ4IRbmvD(1fqDOn41GNoa5bINwz1LNji7hZEdkyJACaT2iXo(BRA8A)APLa17X9LLEPT239U16HWG9E0vt7EN56uiZE)5P1(ntPTwRoNRA86oc02O9M9sBTV7DB3MR820U3zDEUQTwR1LoSIAjagdjFBH44qTIJ(O5syz0fUxJRw7HMRPRiAflS22AZjf8Nma)leENbst0wuYc6Pd8iEotVKnrgRIzrg03hwA)aVZwlNmAq3zQpHiSc(2g6kNbC4G6rvU1rFCeLBB0dVsg0tm4pza(xi8(lLCBJJKVFTl32ne(qKBDeS9rvU1rFCeLBB0dVsg0tm4pza()I3)hbE3qpPVtR09qXtxoQzTRQu(Od64l1UwQ6cASL(03QkDahGPTOI)xAA9brQFvu6or)6oHUn6SKR3rIApQ2MC0hhrBtn6b(W3Yr8AdLc2BZjf8Nma)FX7)JaV)cABQPxXNGJwBBWutJ5x0dxB7yZxaBtDJwFqK6xfLUt0VUtOBJol56BU0uVs5jZL(4yd)UazRBBelq3v766iOR9dYYn9aGV5PlUfqBPjhzO7AHd6cK5h65(W76MCKH(EJ3hA0nNA43fi3nor3TRRJGU2phghFZZtFlG(G547m0paoNw5jT2KJm07kE301gNHW5Y(zNU8hSAOZLArJRwbdHyJ7vHMV1c604cFWAqHUyAnXNaV4tJ3AHIYWhPloF5O5x(RmA(LFXP5dDu0ehu9T5y5Boofi1PP45So4fKR9B0h4izgo2NkgyQRM5KEyV3Ef1IJdc8jc)D0BVc8)6w0LFK2ajc86Gb3L6GtI)okfQxjdUxy3OyynGEJ335YHG99hyzC5vBsJ9fHbKB8(ok0lugVFc9nyJ1CnP(COXJJjYg4x(G)HnpMiAaARn5ecCjyVYBKjEigwAGg(6cWbTJVwBYje4sW6APIomASboFCbUBWEcYh)Xf1pPaVdGf5Bv0CyJTw51NqC9Kc8wbB3J)TtXz)67gVHz7kt5hMe)jf4Ub7jq084I6NuG3bW6v0SXRpH46jf4Tc2UNm2ojA(67M9mdymUyLZaid(BL34mwjhbl58e1XOlC2Uo6AP4iM4D7LRLoqA2bUHbgYpfo2VyTupVrmGN2jfZ(b1d0N)D)W3tPziO(O4aRcpzMOB4YF4UBbk1QSI7U9ph9y0Q4hJV7w67U7hHxvVH8GF(xcWNX7G7(D3DBw(D3wsQe3i)3DRiOn8Vs2qQFGypksFYuC3gsVp)fBSX7QU7VeAaCbmR3G(3D7cs5Ciwv2lqXupxzs3Dl00kc0)3DR6Xr8SE7M9MDZ8hMNOv9R3EOYTzj(kA8NQhL(7Mnahex5yqOEo3ciM65Fcswvq1(kNvHTCEnVB2NGGZ3n7Lx2nt5KLs9XoU8EuBsFXOrE4RGdqTdjNDZUzc9Qa)c8sL359TdqdO)RBKoX55l9Hgibo6zyNbE8PoJggml)A6YSczuU2GrPMbGZyABJtkivh(K9XCM(xjtZcrm5HVmsEh7qoSUr6ShhN7ikTPr7Zr9LAECob74cZHErdD9(t2hWvn9bNCC2U5byyR1JcAC0emSZyc)mXxWYWMjuUiMOpv52sy3Sj0ZKeg0PqX8Wqr8sz)kpeqQNPPxWb44(J)AEC32iK(s5D1qhg21xcf4y)RDigGyHFZqMwm5mTo3v0hivXXOrt20(vTfo8(M9uk)4DByTpkS9jph2v6MI8moYdgDWZSVrH9wC7(I9K1J)tdc4R9I4II6MErkqD1ZmP9J5Sd0pLB8Q9H370C7ErjdU831K96agSDtiRbfgXQU5aRgnIFPDzWJ1goAYq72HO9ey2DiiW0Jan43nRmk3(sDCIqCLtOJx4dP4KBtYNMauSftfIhMMi7UYKozwWn1TDUy0frt(nB3xz0XHlZDgAwKyF30yWqbRslUmazkd)6Pa26(qtJaDCKPCJC5Mf3c)AOln3MdxpUp9Hx)O2uX5EpQDihq9wGE4TylxhgtMArW0RPVAwCe1nEl(yapyhQl1kF4cynpWxQ7aXxjZ)GCI7rmLb3t1yx3VIGpLTkdVGVmAHR4NmVQVz5kINqhz2F8gTrF5b6j)UfI6ieEIFIEERE0KsJeW6Z5bP2J7kd9qsv3kjBss7i9vyoedcfp)2X)w)emB2NMGNCkYi1QteJ2XihZZTr2aWnueEGhii88V5hgeYJrNIC6b3QC0BzlMg)6D0U46QtdqnRQnXmtDPwKYQpl36HUpI3ACdZjfZj4zVliT)Xrs6TrAhK4G(rkM2qonQcCRSC6tXpeNyZB)dcJuOvSJEoVEthTikNw6j0JdjtvC6VLVc7SJBsrkmydFUl32BV0hCrGN2BMAYCcv8SJhxP(hnmoD6YeKdtGcgjyzc1xuShR1X44WFsrSriSPHY(trJddNUSK4MGBvbz3NfABm2ZFCAbAkB4JFhJn365PJHOCYNNMd2IIQYaw)5frpftVI6AZLoKgbdt0Po2TPdBEmutQr)K22Ql9g2PvhpLaKNxr9XRtA8fQ3S6bVuqlo3WdUhjKC889NYdXoYGJkMVkcpdGFhesvjb(374lYtD9PHbFnpIETaexPekw8c8EKapF5xg)zC9FOhDMRT4NAZADR5mVq4ONJqIvMMKRruJtImvEoBD6aDnJg2P0LlTS6owKjv1pmU2eOLZFAgdnt3SvZQCBx99bcPGLnd2dCOHx3oRyqy1qGlCRN48sLHds7Rw7MbwJ8ZnFjL9bZI)2S6BMmv(pGtZEuAhnglxeJJbRIBcQUVt(jQOVpJBDcwWewBAw5m2Nce)9s7OXel8(dAjS6MmRDurNyHMTgUCn8DAcroZRQCx9izNjtmsoH20ca(c5tvw7un1)EheIvY1wOYDymCZer(k1jJY56FjhBQRuTTiZnmclS)sd2DzvkPSSre5AotwssiSUMTYR3WwZI1rFw1Js2hWILuE6ikJMuMoIOIhfUjHY)gXE1ECIEcY0TXElbzApgst74TVk)gf)Jy)riSuQ8AVhyF2BV1JBp7n11jLNHAE(jlo905M994YaG3jbaaQyAsuU)o53erY96blpWS7xWhj5vS0(I3zHStq)kmBDLyfwGPeEDCrH8YqeTRexFqFRTzsulncoAj2Fo2IiFpMvc9pR0YXOO923TzfVNFH2gWH1dytT48bC8sl(15Pu8K4eRLU3526c)gZac9B2kySARAFfge)iXcyIk1O)8RA77yT3SKfKRHaU0d5jrpt5CcrwQ0n4DTfFuZVUSyxoLAnqCfwYwS6RA(cwvmSvCTEXlqHFdn2zSkRySZeKxMZI1Gbf3UtozcNsskH)E0WXsUYaB5VqzU1gKAYLW61VG8bHFr5d8s8mnDBvWqlaLJdzzWXrcXmLyMdFw2(C1MosdPLevNXeFNRbwrl)FqhXrpY7PVRQnr(k6fLg2E8IteVrHNRjItVNInURflJqtBRYQsoIYYMEA9QLL)YX66sO2YgA9iZ6AThSW62kMCczD9GJTPIQrcvDPJYR2e3ZxAXl4y2S1j0l1Aa(TkbOcCmVNcJGHJP3pzo9MsPLHDSLwqDM8lR(jVPb(BvlYLAnOZ4VPp6UXFNT0YSwn(BOvJFn7g)ZejKl3XVPvWBh2lWWUy6PavwxCdgjV(nZp8q8k3hDHz(IAGCXnLRWYAUq7cZH)sBAAex4VTPHlqYlhYIKZtfqxZmBVc2exBB0KTmwOXIghM1LdUVsX5SNvLgB2PdLeGr1H4kJts8uD5J2RL18FBjjnJ)wVS7CvenSLNtt8qEv(IPDeVyEtqjbSHyjPHRmBX2y0vDXDHknytXvMhENiYVQuP1Fueg2zg6Za(x5zLLXusf6ArCL8wZevKq7270xx2(nZfyoEf(a4vA1uvkSm7BnO9AZkAPlEOrMHToB7Q)C1DY1bBpNI77mjS8KuX(U6LSCGTuJyUsR2gr6asLLHxwfURmP9DJa0nkH1ILsR(U8U(9kCikP0sTcBSeGN1p3WbUwQ0jx0r9AzYDEnPFV2fdy7l5MKK5ToUm9aw3(hnbOcLEn3Was5A6LIjB3SqBWNROgVbHN)XFK8yCs8)uE14DlEv7HZ)aQqRfr6ExGGU2VD3SL4wHciO4LnhBX1Wzg6grGanFnDpgHiYSTrXvZWHEcEnDcMtL3PUrlW8BbJzff(zkx4V3zB13nVwovu3RvRhFuwD3wj6we(616Qba6xWlxS4k0B0qR(GAgHXRxiPXYyVFDH)Id0TD19weYLWINLgUdeh6c)wJ4AvBPZ1cUPfW5j4LaoZ(fDbFXoR2Gfw5gs7v8f(vC)01zewwszhInnRlIyh7yJIi0L6splzLxWZRUtDGBwuBsVCpODWhZTGRPrgW(J3BUaqdudIGUTDG)yegnX7RJJVLtXMgq5mbugRcghRLo7FNPlZv46YWgMQ)Twx8qJ9e0X42hxnqe1La1MNZ)B1KX7X2FL5W368HnxMBNwimPYjfJODztJ88cbsYECfTDQNuqkVC8iXG2V5gf3zn5A(1YLFUkL38iu6WwLpgZhfPUqTKHnaUGNl8Q6ze9tQjblYLnMhmOLhRRhDTSbOSW0h26Q1VdwCvJCT5fpoLeTW(LpUqYHTO5HcAfVMC49QZJpk1(12LtUSNTEbL7VV77nC7p4nYUbwcLxhHyMO9HigmhhHRAEv(ctNx9SeK(wZvp1HJ0UT5THoVEOmhFV2RVD1rh35bpR9MNbLtLQtuSpWh5opKWAob22L)Uk(xVTLCVay(fz9MaCjZ4zDot5dObDyuf396A)8jJp1wfkuU7qUl6vPAkx68EwPMos3mRb(Z8TwhNjQdWF5Or)cDB1Bs)XRLEFljshP(g3(66KFZRXD6Bd6YeGnWIFyl0(t11CVjXJbbRHAJKp6vOUhcyJB(DJHXj72QxZT36QcRzq9TmkKoWPSTS64i4WUf7TMvG25undsvf3noMxAKAaVqxaeBxn9Qrj76gO3WIQJ7gFDlD6j(NfdTqGX)Aazzp98X690t9iuXDyBXbkdKNTWvGJby1PP(76U0YI1X2bechUSTgOA1YRL6YSXkQAA6g32ZgLhx9A79awpDWZeM259kUd7ZuxEI687arUIfFgoLWunOu9DxOcDFlUcVjHwPoMNdMnOonpaWAL6eOqD0MGcTfFLmhImZsgeuPXk24NXcccX4(9Ymh22Ro8w3pz(xQbxzxNJy4UdXIdX15g2M4w2ImXjeqc1eqjYzGEPsloLeAIOXrq0drOQPum71mTxOxUps)DdluOx)0uKx(CAfw(TUgeQJ(En3QFyKZYyBuNFfwTPFL2tLUDTp(WemIt8nD82uIAxD1O(a4n8fmE)sH7(1k4l2KGpMMiQve0YllsaAjMc)8zkKE4b2XuarbULRIOzF43)haBaFxM49yTRwk(uCsBlvse3rnSfQOmNmpEjg303(3(ty02aePNBsFh3rir9WYk3qfPELfqaL(GzQ1L28HFF055wsKjkyJnOF9BSUvtAzXfchRedBNN6)GSVDRATZSsx0UU8rYW1RtqrBfqLt)77C)nqH0Ox8VQNeKUlSjjeTwvpIQ2qShkg0O4(qcPAUDNyZJxMbynroRwyWLjJvjTLkYn8Y1gpE5kyNUC0qBTfuLpZrE5c()jmUbVkgxhMzpzmUE7pxmUb(yCTbX2zCdBY42OKZ8X420)cplVPX2ZzIifnwwvvxSw6tfwojqLnXtvu4X0RF(w99ZAuY0LqKx)8ZwJdu0qlSlMbTMSn65sv)oK2ZnQtwmGw6Pz08Oun)lCpG62HgW1QBCodb9AYDRNkQk8TE8iSjBG7dbWMT9kLoHTzWgQDK2XoPdUyxxk)wfVqz(cvPSJ6SerL0TsLdlvZLzjID4FEPSaQY3I6U1tr6hgo(mCgNSKhQs(2Zv9UbMxQir4k5fJ1mT(hxeTopcdpHTNQrjz2yLSa885NeBAcEZ0GldCqumpftdZMraf8zFG5U2sYwQhA8DA3UzFVw3)3PcDCWsnrj8clkbtWc79Smu9rRquL1vFx9Psy3vV)2RtYV2XuRMLHH6LSNbtSLVvPwfgO6VDLyZttjFtfezZvYOti(By9mn53LecObAks5l1oGZeOm)i9vGYT0bFqn726NgWsJi(cIVi22bSHNQ5qJ6y74c2cAR4CKQNeVI9kStRc22V5TOnxat1pXqdkcz1xZkMnZPlZ0quGvock0INKa0uFXLZqHH8TySIO87MCq46VJTLRNVEKZtEzTynkdQg9TuIMBY4EYYmmpf0UgpjQkPjrtUHmwWlht2KQT8vaF)uS6U0oLf0lUkpPpW48DOTt6pZW6X1FNVgWStRcZmc0nSZvEaAGDoZVGLtodX)7U)Vp]] )
