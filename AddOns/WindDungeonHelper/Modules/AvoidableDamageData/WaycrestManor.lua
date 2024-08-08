local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

-- TODO: Ravaging Leap avoidable only if you're not the target

local mistakes = {
    -- Heartsbane Triad
    {
        -- Heartsbane Triad:Aura of Dread
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 268086
    },
    -- Soulbound Goliath
    {
        -- Soulbound Goliath:Burning Fists
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 272669
    },
    -- Raal the Gluttonous
    {
        -- Raal the Gluttonous:Tenderize
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 264923
    },
    {
        -- Raal the Gluttonous:Rotten Expulsion #1
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 264698
    },
    {
        -- Raal the Gluttonous:Rotten Expulsion #2
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 264712
    },
    {
        -- Raal the Gluttonous:Bile Expulsion
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 268234
    },
    -- Lord & Lady Waycrest
    {
        -- Lord Waycrest:Contagious Remnants
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 268387
    },
    {
        -- Lady Waycrest:Discordant Cadenza
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 268308
    },
    -- Mobs
    {
        -- Shadow Cleave
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 265372
    },
    {
        -- Toad Blight
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 265352
    },
    {
        -- Pallid Glare
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 265346
    },
    {
        -- Shatter
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 264150
    },
    {
        -- Retch
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 271174
    },
    {
        -- Dinner Bell
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 265407
    },
    {
        -- Shrapnel Trap
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 264525
    },
    {
        -- Wildfire
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 260570
    }
}

local mapIds = {1014, 1015, 1016, 1017, 1018}

AD:AddData("Waycrest Manor", mistakes, mapIds)
