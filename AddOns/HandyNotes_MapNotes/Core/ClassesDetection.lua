local ADDON_NAME, ns = ...

function ns.AutomaticClassDetectionCapital()

local playerClass, englishClass, classIndex = UnitClass("player");

    if ns.Addon.db.profile.activate.CapitalsClasses then
        if ns.Addon.db.profile.showCapitalsClassDetection then
            if englishClass == "DRUID" then
                ns.Addon.db.profile.showCapitalsClassDruid = true

                ns.Addon.db.profile.showCapitalsClassHunter = false
                ns.Addon.db.profile.showCapitalsClassMage = false
                ns.Addon.db.profile.showCapitalsClassPaladin = false
                ns.Addon.db.profile.showCapitalsClassPriest = false
                ns.Addon.db.profile.showCapitalsClassRogue = false
                ns.Addon.db.profile.showCapitalsClassShaman = false
                ns.Addon.db.profile.showCapitalsClassWarlock = false
                ns.Addon.db.profile.showCapitalsClassWarrior = false
            elseif englishClass == "HUNTER" then
                ns.Addon.db.profile.showCapitalsClassHunter = true
       
                ns.Addon.db.profile.showCapitalsClassDruid = false
                ns.Addon.db.profile.showCapitalsClassMage = false
                ns.Addon.db.profile.showCapitalsClassPaladin = false
                ns.Addon.db.profile.showCapitalsClassPriest = false
                ns.Addon.db.profile.showCapitalsClassRogue = false
                ns.Addon.db.profile.showCapitalsClassShaman = false
                ns.Addon.db.profile.showCapitalsClassWarlock = false
                ns.Addon.db.profile.showCapitalsClassWarrior = false
            elseif englishClass == "MAGE" then
                ns.Addon.db.profile.showCapitalsClassMage = true
       
                ns.Addon.db.profile.showCapitalsClassDruid = false
                ns.Addon.db.profile.showCapitalsClassHunter = false
                ns.Addon.db.profile.showCapitalsClassPaladin = false
                ns.Addon.db.profile.showCapitalsClassPriest = false
                ns.Addon.db.profile.showCapitalsClassRogue = false
                ns.Addon.db.profile.showCapitalsClassShaman = false
                ns.Addon.db.profile.showCapitalsClassWarlock = false
                ns.Addon.db.profile.showCapitalsClassWarrior = false
            elseif englishClass == "PALADIN" then
                ns.Addon.db.profile.showCapitalsClassPaladin = true
       
                ns.Addon.db.profile.showCapitalsClassDruid = false
                ns.Addon.db.profile.showCapitalsClassHunter = false
                ns.Addon.db.profile.showCapitalsClassMage = false
                ns.Addon.db.profile.showCapitalsClassPriest = false
                ns.Addon.db.profile.showCapitalsClassRogue = false
                ns.Addon.db.profile.showCapitalsClassShaman = false
                ns.Addon.db.profile.showCapitalsClassWarlock = false
                ns.Addon.db.profile.showCapitalsClassWarrior = false
            elseif englishClass == "PRIEST" then
                ns.Addon.db.profile.showCapitalsClassPriest = true
       
                ns.Addon.db.profile.showCapitalsClassDruid = false
                ns.Addon.db.profile.showCapitalsClassHunter = false
                ns.Addon.db.profile.showCapitalsClassMage = false
                ns.Addon.db.profile.showCapitalsClassPaladin = false
                ns.Addon.db.profile.showCapitalsClassRogue = false
                ns.Addon.db.profile.showCapitalsClassShaman = false
                ns.Addon.db.profile.showCapitalsClassWarlock = false
                ns.Addon.db.profile.showCapitalsClassWarrior = false
            elseif englishClass == "ROGUE" then
                ns.Addon.db.profile.showCapitalsClassRogue = true
       
                ns.Addon.db.profile.showCapitalsClassDruid = false
                ns.Addon.db.profile.showCapitalsClassHunter = false
                ns.Addon.db.profile.showCapitalsClassMage = false
                ns.Addon.db.profile.showCapitalsClassPaladin = false
                ns.Addon.db.profile.showCapitalsClassPriest = false
                ns.Addon.db.profile.showCapitalsClassShaman = false
                ns.Addon.db.profile.showCapitalsClassWarlock = false
                ns.Addon.db.profile.showCapitalsClassWarrior = false
            elseif englishClass == "SHAMAN" then
                ns.Addon.db.profile.showCapitalsClassShaman = true
       
                ns.Addon.db.profile.showCapitalsClassDruid = false
                ns.Addon.db.profile.showCapitalsClassHunter = false
                ns.Addon.db.profile.showCapitalsClassMage = false
                ns.Addon.db.profile.showCapitalsClassPaladin = false
                ns.Addon.db.profile.showCapitalsClassPriest = false
                ns.Addon.db.profile.showCapitalsClassRogue = false
                ns.Addon.db.profile.showCapitalsClassWarlock = false
                ns.Addon.db.profile.showCapitalsClassWarrior = false
            elseif englishClass == "WARLOCK" then
                ns.Addon.db.profile.showCapitalsClassWarlock = true
       
                ns.Addon.db.profile.showCapitalsClassDruid = false
                ns.Addon.db.profile.showCapitalsClassHunter = false
                ns.Addon.db.profile.showCapitalsClassMage = false
                ns.Addon.db.profile.showCapitalsClassPaladin = false
                ns.Addon.db.profile.showCapitalsClassPriest = false
                ns.Addon.db.profile.showCapitalsClassRogue = false
                ns.Addon.db.profile.showCapitalsClassShaman = false
                ns.Addon.db.profile.showCapitalsClassWarrior = false
            elseif englishClass == "WARRIOR" then
                ns.Addon.db.profile.showCapitalsClassWarrior = true
       
                ns.Addon.db.profile.showCapitalsClassDruid = false
                ns.Addon.db.profile.showCapitalsClassHunter = false
                ns.Addon.db.profile.showCapitalsClassMage = false
                ns.Addon.db.profile.showCapitalsClassPaladin = false
                ns.Addon.db.profile.showCapitalsClassPriest = false
                ns.Addon.db.profile.showCapitalsClassRogue = false
                ns.Addon.db.profile.showCapitalsClassShaman = false
                ns.Addon.db.profile.showCapitalsClassWarlock = false
            end
        end
    end

    if ns.Addon.db.profile.activate.MinimapCapitalsClasses then
        if ns.Addon.db.profile.showMinimapCapitalsClassDetection then
            if englishClass == "DRUID" then
                ns.Addon.db.profile.showMinimapCapitalsClassDruid = true

                ns.Addon.db.profile.showMinimapCapitalsClassHunter = false
                ns.Addon.db.profile.showMinimapCapitalsClassMage = false
                ns.Addon.db.profile.showMinimapCapitalsClassPaladin = false
                ns.Addon.db.profile.showMinimapCapitalsClassPriest = false
                ns.Addon.db.profile.showMinimapCapitalsClassRogue = false
                ns.Addon.db.profile.showMinimapCapitalsClassShaman = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarlock = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarrior = false
            elseif englishClass == "HUNTER" then
                ns.Addon.db.profile.showMinimapCapitalsClassHunter = true
       
                ns.Addon.db.profile.showMinimapCapitalsClassDruid = false
                ns.Addon.db.profile.showMinimapCapitalsClassMage = false
                ns.Addon.db.profile.showMinimapCapitalsClassPaladin = false
                ns.Addon.db.profile.showMinimapCapitalsClassPriest = false
                ns.Addon.db.profile.showMinimapCapitalsClassRogue = false
                ns.Addon.db.profile.showMinimapCapitalsClassShaman = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarlock = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarrior = false
            elseif englishClass == "MAGE" then
                ns.Addon.db.profile.showMinimapCapitalsClassMage = true
       
                ns.Addon.db.profile.showMinimapCapitalsClassDruid = false
                ns.Addon.db.profile.showMinimapCapitalsClassHunter = false
                ns.Addon.db.profile.showMinimapCapitalsClassPaladin = false
                ns.Addon.db.profile.showMinimapCapitalsClassPriest = false
                ns.Addon.db.profile.showMinimapCapitalsClassRogue = false
                ns.Addon.db.profile.showMinimapCapitalsClassShaman = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarlock = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarrior = false
            elseif englishClass == "PALADIN" then
                ns.Addon.db.profile.showMinimapCapitalsClassPaladin = true
       
                ns.Addon.db.profile.showMinimapCapitalsClassDruid = false
                ns.Addon.db.profile.showMinimapCapitalsClassHunter = false
                ns.Addon.db.profile.showMinimapCapitalsClassMage = false
                ns.Addon.db.profile.showMinimapCapitalsClassPriest = false
                ns.Addon.db.profile.showMinimapCapitalsClassRogue = false
                ns.Addon.db.profile.showMinimapCapitalsClassShaman = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarlock = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarrior = false
            elseif englishClass == "PRIEST" then
                ns.Addon.db.profile.showMinimapCapitalsClassPriest = true
       
                ns.Addon.db.profile.showMinimapCapitalsClassDruid = false
                ns.Addon.db.profile.showMinimapCapitalsClassHunter = false
                ns.Addon.db.profile.showMinimapCapitalsClassMage = false
                ns.Addon.db.profile.showMinimapCapitalsClassPaladin = false
                ns.Addon.db.profile.showMinimapCapitalsClassRogue = false
                ns.Addon.db.profile.showMinimapCapitalsClassShaman = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarlock = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarrior = false
            elseif englishClass == "ROGUE" then
                ns.Addon.db.profile.showMinimapCapitalsClassRogue = true
       
                ns.Addon.db.profile.showMinimapCapitalsClassDruid = false
                ns.Addon.db.profile.showMinimapCapitalsClassHunter = false
                ns.Addon.db.profile.showMinimapCapitalsClassMage = false
                ns.Addon.db.profile.showMinimapCapitalsClassPaladin = false
                ns.Addon.db.profile.showMinimapCapitalsClassPriest = false
                ns.Addon.db.profile.showMinimapCapitalsClassShaman = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarlock = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarrior = false
            elseif englishClass == "SHAMAN" then
                ns.Addon.db.profile.showMinimapCapitalsClassShaman = true
       
                ns.Addon.db.profile.showMinimapCapitalsClassDruid = false
                ns.Addon.db.profile.showMinimapCapitalsClassHunter = false
                ns.Addon.db.profile.showMinimapCapitalsClassMage = false
                ns.Addon.db.profile.showMinimapCapitalsClassPaladin = false
                ns.Addon.db.profile.showMinimapCapitalsClassPriest = false
                ns.Addon.db.profile.showMinimapCapitalsClassRogue = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarlock = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarrior = false
            elseif englishClass == "WARLOCK" then
                ns.Addon.db.profile.showMinimapCapitalsClassWarlock = true
       
                ns.Addon.db.profile.showMinimapCapitalsClassDruid = false
                ns.Addon.db.profile.showMinimapCapitalsClassHunter = false
                ns.Addon.db.profile.showMinimapCapitalsClassMage = false
                ns.Addon.db.profile.showMinimapCapitalsClassPaladin = false
                ns.Addon.db.profile.showMinimapCapitalsClassPriest = false
                ns.Addon.db.profile.showMinimapCapitalsClassRogue = false
                ns.Addon.db.profile.showMinimapCapitalsClassShaman = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarrior = false
            elseif englishClass == "WARRIOR" then
                ns.Addon.db.profile.showMinimapCapitalsClassWarrior = true
       
                ns.Addon.db.profile.showMinimapCapitalsClassDruid = false
                ns.Addon.db.profile.showMinimapCapitalsClassHunter = false
                ns.Addon.db.profile.showMinimapCapitalsClassMage = false
                ns.Addon.db.profile.showMinimapCapitalsClassPaladin = false
                ns.Addon.db.profile.showMinimapCapitalsClassPriest = false
                ns.Addon.db.profile.showMinimapCapitalsClassRogue = false
                ns.Addon.db.profile.showMinimapCapitalsClassShaman = false
                ns.Addon.db.profile.showMinimapCapitalsClassWarlock = false
            end
        end
    end

    ns.Addon:FullUpdate()
    HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end