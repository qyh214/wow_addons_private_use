local addonName, ham = ...
ham.defaults = {
    cdReset = false,
    stopCast = false,
    raidStone = false,
    witheringPotion = false,
    witheringDreamsPotion = false,
    cavedwellerDelight = true,
    heartseekingInjector = false,
    activatedSpells = { ham.crimsonVialSpell, ham.renewal, ham.exhilaration, ham.fortitudeOfTheBear, ham.lastStand, ham
        .bitterImmunity,
        ham.desperatePrayer, ham.healingElixir, ham.darkPact, ham.giftOfTheNaaruDK, ham.giftOfTheNaaruHunter, ham
        .giftOfTheNaaruMage,
        ham.giftOfTheNaaruMageWarlock, ham.giftOfTheNaaruMonk, ham.giftOfTheNaaruPaladin, ham.giftOfTheNaaruPriest, ham
        .giftOfTheNaaruRogue, ham.giftOfTheNaaruShaman, ham.giftOfTheNaaruWarrior, ham.bagOfTricks }
}


function ham.dbContains(id)
    local found = false
    for _, v in pairs(HAMDB.activatedSpells) do
        if v == id then
            found = true
        end
    end
    return found
end

function ham.removeFromDB(id)
    local backup = {}
    if ham.dbContains(id) then
        for _, v in pairs(HAMDB.activatedSpells) do
            if v ~= id then
                table.insert(backup, v)
            end
        end
    end

    HAMDB.activatedSpells = CopyTable(backup)
end

function ham.insertIntoDB(id)
    table.insert(HAMDB.activatedSpells, id)
end
