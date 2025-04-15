local addonName, ham = ...
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)


ham.crimsonVialSpell = 185311
ham.renewal = 108238
ham.exhilaration = 109304
ham.fortitudeOfTheBear = 388035
ham.lastStand = 12975
ham.bitterImmunity = 383762
ham.desperatePrayer = 19236
ham.expelHarm = 322101
ham.healingElixir = 122281
ham.darkPact = 108416
ham.vampiricBlood = 55233

--Racials WTF These are all seperate Spells
ham.giftOfTheNaaruDK = 59545
ham.giftOfTheNaaruHunter = 59543
ham.giftOfTheNaaruMage = 59548
ham.giftOfTheNaaruMageWarlock = 416250
ham.giftOfTheNaaruMonk = 121093
ham.giftOfTheNaaruPaladin = 59542
ham.giftOfTheNaaruPriest = 59544
ham.giftOfTheNaaruRogue = 370626
ham.giftOfTheNaaruShaman = 59547
ham.giftOfTheNaaruWarrior = 28880

ham.bagOfTricks = 312411

ham.supportedSpells = {}
table.insert(ham.supportedSpells, ham.crimsonVialSpell)
table.insert(ham.supportedSpells, ham.renewal)
table.insert(ham.supportedSpells, ham.exhilaration)
table.insert(ham.supportedSpells, ham.fortitudeOfTheBear)
table.insert(ham.supportedSpells, ham.lastStand)
table.insert(ham.supportedSpells, ham.bitterImmunity)
table.insert(ham.supportedSpells, ham.desperatePrayer)
table.insert(ham.supportedSpells, ham.expelHarm)
table.insert(ham.supportedSpells, ham.healingElixir)
table.insert(ham.supportedSpells, ham.darkPact)
table.insert(ham.supportedSpells, ham.vampiricBlood)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruDK)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruHunter)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruMage)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruMageWarlock)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruMonk)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruPaladin)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruPriest)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruRogue)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruShaman)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruWarrior)
table.insert(ham.supportedSpells, ham.bagOfTricks)


ham.Spell = {}

ham.Spell.new = function(id, name)
    local self = {}

    self.id = id
    self.name = name
    if isRetail == true then
        self.cd = C_Spell.GetSpellCooldown(id).duration
    else
        self.cd = GetSpellBaseCooldown(id)
    end


    function self.getId()
        return self.id
    end

    function self.getName()
        return self.name
    end

    function self.getCd()
        return self.cd
    end

    return self
end
