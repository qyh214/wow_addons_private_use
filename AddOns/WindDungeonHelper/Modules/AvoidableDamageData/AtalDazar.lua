local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

-- TODO: Deadeye Aim avoidable only if you're not the target

local mistakes = {
    -- Rezan
    {
        -- Rezan:Devour
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 255445
    },
    {
        -- Rezan:Tail
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 255373
    },
    -- Priestess Alun'za
    {
        -- Priestess Alun'za:Transfusion
        -- Transfusion damage, when you don't have Tainted Blood
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 255575,
        noPlayerDebuff = 255558
    },
    {
        -- Priestess Alun'za:Corrupted Gold
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 258709
    },
    -- Yazma
    {
        -- Yazma:Echoes of Shadra #1
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 250022
    },
    {
        -- Yazma:Echoes of Shadra #2
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 250028
    },
    -- Vol'kaal
    {
        -- Vol'kaal:Toxic Leap
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 250259
    },
    {
        -- Vol'kaal:Toxic Pool
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 250585
    },
    -- Mobs
    {
        -- Fiery Enchant
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 253654
    },
    {
        -- Fiery Bolt
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 253666
    },
    {
        -- Fervent Strike
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 256138,
        playerIsNotTank = true
    },
    {
        -- Merciless Assault
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 253239
    },
    {
        -- Transfusion
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 260668,
        noPlayerDebuff = 255558
    },
    {
        -- Rending Maul
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 255814,
        playerIsNotTank = true
    },
    {
        -- Waylaying Jab
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 252692
    },
    {
        -- Frenzied Charge
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 255567
    },
    {
        -- Grotesque Pool
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 258723
    },
    {
        -- Tiki Blaze
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 257692
    },
    {
        -- Festering Eruption
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 255620
    }
    -- {
    --     -- Deadeye Aim
    --     type = AD.MISTAKE.SPELL_DAMAGE,
    --     spell = 256846
    -- }
}

local mapIds = {934, 935}

AD:AddData("Atal'Dazar", mistakes, mapIds)
