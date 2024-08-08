local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

-- TODO: Grievous Rip avoidable only if you're not the target
-- TODO: Frantic Rip avoidable only if you're not the target

local mistakes = {
    -- Arch-Druid Gladialis
    {
        -- Arch-Druid Gladialis:Primal Rampage #1
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198376
    },
    {
        -- Arch-Druid Gladialis:Primal Rampage #2
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198386
    },
    {
        -- Arch-Druid Gladialis:Nightfall
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198401
    },
    {
        -- Arch-Druid Gladialis:Nightmare Abomination (Meele)
        type = AD.MISTAKE.MELEE,
        npc = 109908
    },
    -- Oakheart
    {
        -- Oakheart:Nightmare Breath
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 204667,
        playerIsNotTank = true
    },
    {
        -- Oakheart:Strangling Roots
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 199063
    },
    -- Dresaron
    {
        -- Dresaron:Breath of Corruption
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 191326
    },
    {
        -- Dresaron:Falling Rocks
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 199460
    },
    -- Shade of Xavius
    {
        -- Shade of Xavius:Apocalyptic Fire
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 200111
    },
    -- Mobs
    {
        -- Propelling Charge
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 200771
    },
    {
        -- Star Shower
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 204402
    },
    {
        -- Festering Swipe
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 200589,
        playerIsNotTank = true
    },
    {
        -- Root Burst
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 201123
    },
    {
        -- Blood Assault
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 201227
    },
    {
        -- Vile Burst
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198916
    },
    {
        -- Corruption Pool
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 218759
    },
    {
        -- Blood Bomb
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 201273
    },
    {
        -- Volcanic Plume
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 209862
    }
}

local mapIds = {733}

AD:AddData("Darkheart Thicket", mistakes, mapIds)
