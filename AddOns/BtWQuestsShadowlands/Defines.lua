--[[@TODO
    Update campaign chapter requirements with torghast, remove return to the maw
    Figure out requirements for New Rules, at most is part way through torghast
    Update chain rewards
    Update locales
    Update campaign names

    62706 Flagged as completed after accepting the quest A Calling in Bastion during the intro
          Seemed to happen before after finishing the Maw intro, maybe something to do with Torghast realm
    62924 Flagged as completed after accepting the quest Our Most Previous Resource
    62907 Flagged while getting my first 5 souls, after the eye of the jailer popped up

    When doing the Kyrian covenant skip the tracking quests 62706, 62907, 62924, 63001, 63023 are flag completed. might be related to something else
        Seems like 63001 and 63023 are the thing to look for
        Same for venthyr it appears

    Questlines 1201, 1202, 1203, 1204, 1205 all seem to be the quests that get flagged as completed when you do the covenant skip
        1203 and 1205 are both night fae, they are slightly different though. 1203 seems to have an extra tracking quest
        First quests after skips are different
        Night Fae have 2 skip options, one BEFORE [Show, Don't Tell] and the other BEFORE [The Forest Will Sing Your Name]
            First skip also flags 63007 as completed, gives a different version of For Queen and Grove (63006) and leads to (The Forge of Bonds) 63008
]]
local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
BtWQuests.Constant.Expansions.Shadowlands = LE_EXPANSION_SHADOWLANDS or 8

BtWQuests.Constant.Category.Shadowlands = {
    Bastion = 901,
    Maldraxxus = 902,
    Ardenweald = 903,
    Revendreth = 904,
    Kyrian = 906,
    Necrolord = 907,
    NightFae = 908,
    Venthyr = 909,
    ChainsOfDomination = 910,
    EternitysEnd = 911,
}
BtWQuests.Constant.Chain.Shadowlands = {
    IntoTheMaw = 90001,
    ArrivalInTheShadowlandsMain = 90002,
    ArrivalInTheShadowlandsAlt = 90003,
    TheMawEmbed = 90004,
    Torghast = 90005,
    NewRules = 90006,
    PeeringIntoDarkness = 90007,

    Chain92501 = 90008,
    Chain92502 = 90009,
    Chain92503 = 90010,
    Chain92504 = 90011,
    Chain92505 = 90012,
    Chain92506 = 90013,

    EternitysEnd = {
        IntoTheUnknown = 91101,
        WeBattleOnward = 91102,
        FormingAnUnderstanding = 91103,
        ForgingANewPath = 91104,
        CrownOfWills = 91105,
        AMeansToAnEnd = 91106,
        StartingOver = 91107,
        EpilogueJudgment = 91108,

        NotAlAreLost = 91109,
        SmallPetProblems = 91110,
        TheWatersOfGrace = 91111,
        CyphersOfTheFirstOnes = 91112,

        JiroToHero = 91113,
        TheFinalSong = 91114,
        ReapWhatYouSow = 91115,
        ANewArchitect = 91116,

        Chain01 = 91117,
        Chain02 = 91118,
        Chain03 = 91119,
        Chain04 = 91120,
        Chain05 = 91121,
        Chain06 = 91122,
        Chain07 = 91123,
        Chain08 = 91124,
    },

    ChainsOfDomination = {
        BattleOfArdenweald = 91001,
        MawWalkers = 91002,
        FocusingTheEye = 91003,
        TheLastSigil = 91004,
        AnArmyOfBoneAndSteel = 91005,
        TheUnseenGuest = 91006,
        ThePowerOfNight = 91007,
        ANewPath = 91008,
        WhatLiesAhead = 91009,
        
        TheyCouldBeAnyone = 91010,
        ArchivistsOfKorthia = 91011,
        TazaveshTheVeiledMarket = 91012,
    },

    Bastion = {
        EternitysCall = 90101,
        TheAspirantsCrucible = 90102,
        TheTempleOfPurity = 90103,
        ChasingAMemory = 90104,
        ByTheArchonsWill = 90105,
        TheTempleOfCourage = 90106,

        Chain01 = 90111,
        Chain02 = 90112,
        Chain03 = 90113,
        Chain04 = 90114,
        Chain05 = 90115,
        Chain06 = 90116,
        Chain07 = 90127,

        EmbedChain01 = 90121,
        EmbedChain02 = 90122,
        EmbedChain03 = 90123,

        OtherAlliance = 90197,
        OtherHorde = 90198,
        OtherBoth = 90199,
    },
    Maldraxxus = {
        ChampionOfPain = 90201,
        HouseOfTheChosen = 90202,
        MatronOfSpies = 90203,
        HouseOfConstructs = 90204,
        HouseOfPlagues = 90205,
        RitualForTheDamned = 90206,
        TheEmptyThrone = 90207,

        Chain01 = 90211,
        Chain02 = 90212,
        Chain03 = 90213,
        Chain04 = 90214,

        EmbedChain02 = 90221,
        EmbedChain03 = 90222,
        EmbedChain04 = 90223,
        EmbedChain05 = 90224,
        EmbedChain06 = 90225,
        EmbedChain07 = 90226,

        OtherAlliance = 90297,
        OtherHorde = 90298,
        OtherBoth = 90299,
    },
    Ardenweald = {
        WelcomeToArdenweald = 90301,
        TranquilPools = 90302,
        SpiritGlen = 90303,
        WaningGrove = 90304,
        GlitterfallHeights = 90305,
        ThisIsTheWay = 90306,
        TheFallenTree = 90307,
        VisionsOfTheDreamer = 90308,
        AwakenTheDreamer = 90309,

        Chain01 = 90311,
        Chain02 = 90312,
        Chain03 = 90313,
        Chain04 = 90314,
        Chain05 = 90315,
        Chain06 = 90316,

        TempChain14 = 90317,
        TempChain15 = 90318,
        TempChain16 = 90319,
        TempChain17 = 90320,

        EmbedChain01 = 90321,
        EmbedChain02 = 90322,
        EmbedChain03 = 90323,
        EmbedChain04 = 90324,
        EmbedChain05 = 90325,

        OtherAlliance = 90397,
        OtherHorde = 90398,
        OtherBoth = 90399,
    },
    Revendreth = {
        WelcomeToRevendreth = 90401,
        MeetTheMaster = 90402,
        TheAccusersSecret = 90403,
        TheRebellion = 90404,
        SecuringSinfall = 90405,
        ThePrinceAndTheTower = 90406,
        MenagerieOfTheMaster = 90407,

        Chain01 = 90411,
        Chain02 = 90412,
        Chain03 = 90413,
        Chain04 = 90414,
        Chain05 = 90415,
        Chain06 = 90416,
        Chain07 = 90417,
        Chain08 = 90418,
        Chain09 = 90419,

        EmbedChain01 = 90421,
        EmbedChain02 = 90422,
        EmbedChain03 = 90423,
        EmbedChain04 = 90424,
        EmbedChain05 = 90425,
        EmbedChain06 = 90426,
        EmbedChain07 = 90427,
        EmbedChain08 = 90428,
        EmbedChain09 = 90429,
        EmbedChain10 = 90430,
        EmbedChain11 = 90431,
        EmbedChain12 = 90432,

        OtherAlliance = 90497,
        OtherHorde = 90498,
        OtherBoth = 90499,
    },
    Kyrian = {
        AmongTheKyrian = 90601,
        ReturnToTheMaw = 90602,
        TrialOfAscension = 90603,
        PhaestusGenesisOfAeons = 90604,
        RighteousRetribution = 90605,
        TheSealOfContrition = 90606,
        AVesselOfArdenweald = 90607,
        ClosingIn = 90608,
        TheBellTolls = 90609,

        Chain01 = 90611,
        Chain02 = 90612,
        Chain03 = 90613,
        Chain04 = 90614,

        OtherAlliance = 90697,
        OtherHorde = 90698,
        OtherBoth = 90699,
    },
    Necrolord = {
        LoyalToThePrimus = 90701,
        ReturnToTheMaw = 90702,
        TheHouseOfEyes = 90703,
        GrandTheftNecropolis = 90704,
        DoNotForget = 90705,
        AGoldenDawn = 90706,
        TheWagesOfSin = 90707,
        TheHouseOfRituals = 90708,
        AssaultOnTheHouseOfRituals = 90709,

        Chain01 = 90711,
        Chain02 = 90712,
        Chain03 = 90713,
        Chain04 = 90714,
        
        TempChain12 = 90722,
        TempChain13 = 90723,
        TempChain14 = 90724,
        TempChain15 = 90725,

        OtherAlliance = 90797,
        OtherHorde = 90798,
        OtherBoth = 90799,
    },
    NightFae = {
        ForQueenAndGrove = 90801,
        ReturnToTheMaw = 90802,
        DaughterOfTheNightWarrior = 90803,
        DeBoss = 90804,
        NightWarriorsCurse = 90805,
        DrustToDrust = 90806,
        TheHornedHunter = 90807,
        DealForALoa = 90808,
        DrustAndAshes = 90809,

        Chain01 = 90811,
        Chain02 = 90812,
        Chain03 = 90813,
        Chain04 = 90814,

        OtherAlliance = 90897,
        OtherHorde = 90898,
        OtherBoth = 90899,
    },
    Venthyr = {
        Sinfall = 90901,
        ReturnToTheMaw = 90902,
        TheCourtOfHarvesters = 90903,
        Desire = 90904,
        Avarice = 90905,
        TheCrownedPrince = 90906,
        ConfrontingSin = 90907,
        Envy = 90908,
        Dominion = 90909,
        
        Chain01 = 90911,
        Chain02 = 90912,
        Chain03 = 90913,
        Chain04 = 90914,

        OtherAlliance = 90997,
        OtherHorde = 90998,
        OtherBoth = 90999,
    },
}

do
    local ItemMixin = BtWQuests.Database.ItemMixin
    local RenownItem = CreateFromMixins(ItemMixin)
    function RenownItem:GetName(database, item, character)
        if item.name then
            return ItemMixin.GetName(self, database, item, character);
        end

        return string.format(L["RENOWN_LEVEL"], item.level);
    end
    function RenownItem:IsActive(database, item, character)
        if self:IsCompleted(database, item, character) then
            return false;
        end

        return true
    end
    function RenownItem:IsCompleted(database, item, character)
        return character:RenownAtleastLevel(item.level);
    end

    local CovenantItem = CreateFromMixins(ItemMixin)
    function CovenantItem:GetName(database, item, character)
        if item.name then
            return ItemMixin.GetName(self, database, item, character);
        end

        return C_Covenants.GetCovenantData(item.id).name;
    end
    function CovenantItem:IsActive(database, item, character)
        if self:IsCompleted(database, item, character) then
            return false;
        end

        return true
    end
    function CovenantItem:IsCompleted(database, item, character)
        if item.id then
            return character:IsCovenant(item.id);
        else
            return character:InCovenants(item.ids);
        end
    end

    Database:RegisterItemType("renown", RenownItem);
    Database:RegisterItemType("covenant", CovenantItem);
    Database:AddCondition(86994, { type = "quest", ids = {62713, 57559}, count = 2 }) -- Quests should be level 50 now
    Database:AddCondition(87203, { type = "quest", id = 62713, status = {"pending"} }) -- Did not choose Threads of Fate alt leveling
    Database:AddCondition(-90000, { type = "quest", id = 63001, status = {"pending"} }) -- Didnt skip convenant hall intro
    Database:AddCondition(-90001, { type = "quest", id = 63007, status = {"pending"} }) -- Didnt skip convenant hall intro pre-play in night fae
end

Database:AddExpansion(BtWQuests.Constant.Expansions.Shadowlands, {
    image = {
        texture = "Interface\\AddOns\\BtWQuestsShadowlands\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})

Database:AddMapRecursive(1670, {
    type = "expansion",
    id = BtWQuests.Constant.Expansions.Shadowlands,
})