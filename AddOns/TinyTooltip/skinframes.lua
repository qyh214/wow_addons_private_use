
local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local addon = TinyTooltip

local frames = {
    AtlasLootTooltip,
    QuestHelperTooltip,
    QuestGuru_QuestWatchTooltip,
    ChatMenu,
    EmoteMenu,
    LanguageMenu,
    VoiceMacroMenu,
    DropDownList1MenuBackdrop,
    DropDownList2MenuBackdrop,
    AutoCompleteBox,
    FriendsTooltip,
    FriendsMenuXPMenuBackdrop,
    FriendsMenuXPSecureMenuBackdrop,
    GeneralDockManagerOverflowButtonList,
    QueueStatusFrame,
    BattlePetTooltip,
    PetBattlePrimaryAbilityTooltip,
    PetBattlePrimaryUnitTooltip,
    FloatingBattlePetTooltip,
    FloatingPetBattleAbilityTooltip,
    GarrisonMissionMechanicTooltip,
    GarrisonMissionMechanicFollowerCounterTooltip,
    GarrisonShipyardMapMissionTooltip,
    GarrisonBonusAreaTooltip,
    FloatingGarrisonShipyardFollowerTooltip,
    GarrisonShipyardFollowerTooltip,
    GarrisonFollowerAbilityWithoutCountersTooltip,
    GarrisonFollowerMissionAbilityWithoutCountersTooltip,
    FloatingGarrisonFollowerTooltip,
    FloatingGarrisonFollowerAbilityTooltip,
    FloatingGarrisonMissionTooltip,
    GarrisonFollowerAbilityTooltip,
    GarrisonFollowerTooltip,
    QuestScrollFrame and QuestScrollFrame.StoryTooltip,
}

LibEvent:attachTrigger("tooltip:variables:loaded", function()
    if (addon.db.general.skinMoreFrames) then
        for _, v in pairs(frames) do
            if (v and not v.style) then tinsert(addon.tooltips, v) end
        end
    end
end)
