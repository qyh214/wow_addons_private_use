local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

-- TODO: Glaive Toss avoidable damage only if you're not the target
-- TODO: Bloodthirsty Leap avoidable damage only if you're not the target
-- TODO: Brutal Glaive avoidable damage only if you're not the target
-- Commenting out Knife Dance, it can be LOS'ed, but it's debatable whether the addon should show it or not
-- Commenting out Fel Bat Pup meele damage, since it's debatable

local mistakes = {
    -- Amalgam of Souls
    {
        -- Amalgam of Souls:Reap Soul
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 194956
    },
    {
        -- Amalgam of Souls:Soul Echoes
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 194966
    },
    {
        -- Amalgam of Souls:Swirling Scythe
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 196517
    },
    -- Illysanna Ravencrest
    {
        -- Illysanna Ravencrest:Blazing Trail
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 197521
    },
    -- {
    --     -- Illysanna Ravencrest:Brutal Glaive
    --     type = AD.MISTAKE.SPELL_DAMAGE,
    --     spell = 197546
    -- },
    {
        -- Illysanna Ravencrest:Vengeful Shear
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 197418,
        playerIsNotTank = true
    },
    {
        -- Illysanna Ravencrest:Felblazed Ground
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 197821
    },
    {
        -- Illysanna Ravencrest:Bonecrushing Strike
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 197974
    },
    {
        -- Arcane Blitz
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 197797
    },
    -- Smashspite the Hateful
    {
        -- Smashspite the Hateful:Fel Vomitus
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198501
    },
    {
        -- Smashspite the Hateful:Hateful Charge
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198080,
        noPlayerDebuff = 224188
    },
    -- Lord Kur'talos Ravencrest
    {
        -- Lord Kur'talos Ravencrest:Dark Blast
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198820
    },
    {
        -- Lord Kur'talos Ravencrest:Dark Obliteration
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 199567
    },
    {
        -- Lord Kur'talos Ravencrest:Whirling Blade
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 198781
    },
    -- Mobs
    {
        -- Strike Down
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 225732,
        playerIsNotTank = true
    },
    {
        -- Soul Echoes
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 194960
    },
    {
        -- Phased Explosion
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 200256
    },
    {
        -- Arrow Barrage
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 200344
    },
    -- {
    --     -- Knife Dance
    --     type = AD.MISTAKE.SPELL_DAMAGE,
    --     spell = 200325
    -- },
    {
        -- Bonebreaking Strike
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 200261
    },
    {
        -- Boulder Crush
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 222397
    },
    {
        -- Brutal Assault
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 201139
    },
    {
        -- Indigestion
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 200914
    },
    {
        -- Bowled Over!
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 201062
    },
    -- {
    --     -- Fel Bat Pup fixated on a player
    --     type = AD.MISTAKE.MELEE,
    --     npc = 102781,
    --     playerIsNotTank = true
    -- },
    {
        -- Raven's Dive
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 214002
    },
    {
        -- Throw Priceless Artifact
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 201175
    }
}

local mapIds = {751, 752, 753, 754, 755, 756}

AD:AddData("Black Rook Hold", mistakes, mapIds)
