local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

-- TODO: Bounding Whirl avoidable only if you're not the target

local mistakes = {
    -- Witherbark
    {
        -- Witherbark:Agitated Water
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 177734
    },
    {
        -- Witherbark:Unchecked Growth
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 164294
    },
    {
        -- Witherbark:Parched Gasp
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 164357,
        playerIsNotTank = true
    },
    -- {
    --     -- Witherbark:Unchecked Growth (Meele)
    --     type = AD.MISTAKE.MELEE,
    --     npc = 81737,
    --     playerIsNotTank = true
    -- },
    -- Ancient Protectors
    {
        -- Ancient Protectors:Noxious Charge
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 427512,
        playerIsNotTank = true
    },
    {
        -- Ancient Protectors:Noxious Discharge
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 427513
    },
    -- Archmage Sol
    {
        -- Archmage Sol:Blazing Cinders
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 426991
    },
    {
        -- Archmage Sol:Glacial Fusion
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 428084
    },
    -- Yainu
    {
        -- Yainu:Lumbering Swipe
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 169930
    },
    {
        -- Yainu:Verdant Eruption
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 428834
    },
    -- Mobs
    {
        -- Cold Fusion
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 426849
    },
    {
        -- Spatial Disruption
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 426982
    }
}

local mapIds = {620, 621}

AD:AddData("Everbloom", mistakes, mapIds)
