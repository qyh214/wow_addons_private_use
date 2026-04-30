local addonName, DF = ...

-- ============================================================
-- EXPORT/IMPORT CATEGORY DEFINITIONS
-- ============================================================
-- Each setting from PartyDefaults/RaidDefaults is assigned to a category
-- for selective import/export

DF.ExportCategories = {
    -- ===========================================
    -- POSITION - Where frames appear on screen
    -- ===========================================
    position = {
        "anchorPoint",
        "anchorX",
        "anchorY",
        
        -- Raid-specific position
        "raidAnchorX",
        "raidAnchorY",
        "raidEnabled",
        "raidLocked",
    },
    
    -- ===========================================
    -- LAYOUT - Frame size, spacing, growth, sorting
    -- ===========================================
    layout = {
        -- Frame dimensions
        "frameWidth",
        "frameHeight",
        "framePadding",
        "frameSpacing",
        "frameScale",

        -- Growth & arrangement
        "growDirection",
        "growthAnchor",
        "gridSize",
        
        -- Sorting
        "sortEnabled",
        "sortAlphabetical",
        "sortByClass",
        "sortClassOrder",
        "sortRoleOrder",
        "sortSelfPosition",
        "sortSeparateMeleeRanged",
        
        -- Visibility & misc layout
        "soloMode",
        "hideDefaultPlayerFrame",
        "restedIndicator",
        "restedIndicatorIcon",
        "restedIndicatorGlow",
        "restedIndicatorSize",
        "restedIndicatorAnchor",
        "restedIndicatorOffsetX",
        "restedIndicatorOffsetY",
        "locked",
        "pixelPerfect",
        "snapToGrid",
        "hidePlayerFrame",
        
        -- Test frame counts (layout-related)
        "testFrameCount",
        "raidTestFrameCount",
        
        -- Raid-specific layout settings
        "raidFlatHorizontalSpacing",
        "raidFlatVerticalSpacing",
        "raidFlatPlayerAnchor",
        "raidFlatReverseFillOrder",
        "raidFlatColumnAnchor",
        "raidFlatFrameAnchor",
        "raidFlatGrowthAnchor",
        "raidGroupAnchor",
        "raidGroupRowGrowth",
        "raidGroupSpacing",
        "raidGroupsPerRow",
        "raidPlayerAnchor",
        "raidPlayersPerRow",
        "raidGroupOrder",
        "raidGroupDisplayOrder",
        "raidGroupVisible",
        "raidPlayerGroupFirst",
        "raidRowColSpacing",
        "raidUseGroups",
    },
    
    -- ===========================================
    -- BARS - Health, power, absorbs, heal prediction
    -- ===========================================
    bars = {
        -- Health Bar
        "healthTexture",
        "healthOrientation",
        "healthColor",
        "healthColorMode",
        "healthColorLow",
        "healthColorLowWeight",
        "healthColorLowUseClass",
        "healthColorMedium",
        "healthColorMediumWeight",
        "healthColorMediumUseClass",
        "healthColorHigh",
        "healthColorHighWeight",
        "healthColorHighUseClass",
        "smoothBars",
        
        -- Background
        "backgroundColor",
        "backgroundColorMode",
        "backgroundTexture",
        "backgroundClassAlpha",
        "backgroundMode",
        
        -- Missing Health Background
        "missingHealthColor",
        "missingHealthColorHigh",
        "missingHealthColorHighUseClass",
        "missingHealthColorHighWeight",
        "missingHealthColorLow",
        "missingHealthColorLowUseClass",
        "missingHealthColorLowWeight",
        "missingHealthColorMedium",
        "missingHealthColorMediumUseClass",
        "missingHealthColorMediumWeight",
        "missingHealthColorMode",
        "missingHealthGradientAlpha",
        "missingHealthTexture",
        "missingHealthClassAlpha",
        
        -- Border
        "borderSize",
        
        -- Class Color Alpha
        "classColorAlpha",
        
        -- Power Bar toggles
        "showPowerBar",
        "showAbsorbBar",
        "powerBarHeight",
        
        -- Resource/Power Bar
        "resourceBarClassColor",
        "resourceBarEnabled",
        "resourceBarAnchor",
        "resourceBarX",
        "resourceBarY",
        "resourceBarWidth",
        "resourceBarHeight",
        "resourceBarMatchWidth",
        "resourceBarOrientation",
        "resourceBarReverseFill",
        "resourceBarSmooth",
        "resourceBarShowHealer",
        "resourceBarShowTank",
        "resourceBarShowDPS",
        "resourceBarShowInSoloMode",
        "resourceBarClassFilter",
        "resourceBarBackgroundEnabled",
        "resourceBarBackgroundColor",
        "resourceBarBorderEnabled",
        "resourceBarBorderColor",
        "resourceBarFrameLevel",
        
        -- Class Power (player frame pips)
        "classPowerEnabled",
        "classPowerHeight",
        "classPowerGap",
        "classPowerAnchor",
        "classPowerX",
        "classPowerY",
        "classPowerIgnoreFade",
        "classPowerUseCustomColor",
        "classPowerColor",
        "classPowerBgColor",
        "classPowerShowTank",
        "classPowerShowHealer",
        "classPowerShowDamager",

        -- Absorb Bar
        "absorbBarMode",
        "absorbBarAnchor",
        "absorbBarX",
        "absorbBarY",
        "absorbBarWidth",
        "absorbBarHeight",
        "absorbBarTexture",
        "absorbBarColor",
        "absorbBarBackgroundColor",
        "absorbBarOrientation",
        "absorbBarReverse",
        "absorbBarOverlayReverse",
        "absorbBarBlendMode",
        "absorbBarStrata",
        "absorbBarFrameLevel",
        "absorbBarBorderEnabled",
        "absorbBarBorderColor",
        "absorbBarBorderSize",
        "absorbBarAttachedClampMode",
        "absorbBarShowOvershield",
        "absorbBarOvershieldStyle",
        "absorbBarOvershieldColor",
        "absorbBarOvershieldReverse",
        "absorbBarOvershieldAlpha",
        
        -- Heal Absorb Bar
        "healAbsorbBarMode",
        "healAbsorbBarAnchor",
        "healAbsorbBarX",
        "healAbsorbBarY",
        "healAbsorbBarWidth",
        "healAbsorbBarHeight",
        "healAbsorbBarTexture",
        "healAbsorbBarColor",
        "healAbsorbBarBackgroundColor",
        "healAbsorbBarOrientation",
        "healAbsorbBarReverse",
        "healAbsorbBarOverlayReverse",
        "healAbsorbBarBlendMode",
        "healAbsorbBarBorderEnabled",
        "healAbsorbBarBorderColor",
        "healAbsorbBarBorderSize",
        "healAbsorbBarAttachedClampMode",
        "healAbsorbBarShowOvershield",
        "healAbsorbBarOvershieldStyle",
        "healAbsorbBarOvershieldColor",
        "healAbsorbBarOvershieldReverse",
        "healAbsorbBarOvershieldAlpha",
        
        -- Heal Prediction
        "healPredictionEnabled",
        "healPredictionMode",
        "healPredictionShowMode",
        "healPredictionClampMode",
        "healPredictionOverflowPercent",
        "healPredictionShowOverheal",
        "healPredictionMyColor",
        "healPredictionOthersColor",
        "healPredictionAllColor",
        "healPredictionTexture",
        "healPredictionBlendMode",
        "healPredictionStrata",
        "healPredictionOverlayReverse",
        "healPredictionAnchor",
        "healPredictionX",
        "healPredictionY",
        "healPredictionWidth",
        "healPredictionHeight",
        "healPredictionOrientation",
        "healPredictionReverse",
        "healPredictionBackgroundColor",
        "healPredictionFrameLevel",
    },
    
    -- ===========================================
    -- AURAS - Buffs & Debuffs
    -- ===========================================
    auras = {
        -- Show toggles
        "showBuffs",
        "showDebuffs",
        
        -- Buff settings
        "buffAnchor",
        "buffOffsetX",
        "buffOffsetY",
        "buffSize",
        "buffScale",
        "buffAlpha",
        "buffMax",
        "buffWrap",
        "buffWrapOffsetX",
        "buffWrapOffsetY",
        "buffGrowth",
        "buffPaddingX",
        "buffPaddingY",
        "buffShowDuration",
        "buffShowCountdown",
        "buffHideSwipe",
        "buffClickThrough",
        "buffClickThroughInCombatOnly",
        "buffClickThroughKeybinds",
        "buffDeduplicateDefensives",
        "buffDisableMouse",
        "buffDurationFont",
        "buffDurationAnchor",
        "buffDurationScale",
        "buffDurationOutline",
        "buffDurationX",
        "buffDurationY",
        "buffDurationColorByTime",
        "buffDurationHideAboveEnabled",
        "buffDurationHideAboveThreshold",
        "buffCountdownFont",
        "buffCountdownScale",
        "buffCountdownOutline",
        "buffCountdownX",
        "buffCountdownY",
        "buffStackFont",
        "buffStackScale",
        "buffStackOutline",
        "buffStackAnchor",
        "buffStackX",
        "buffStackY",
        "buffStackMinimum",
        "buffBorderEnabled",
        "buffBorderThickness",
        "buffBorderInset",
        "buffExpiringEnabled",
        "buffExpiringThreshold",
        "buffExpiringThresholdMode",
        "buffExpiringBorderEnabled",
        "buffExpiringBorderColor",
        "buffExpiringBorderColorByTime",
        "buffExpiringBorderThickness",
        "buffExpiringBorderInset",
        "buffExpiringBorderPulsate",
        "buffExpiringTintEnabled",
        "buffExpiringTintColor",
        
        -- Debuff settings
        "debuffAnchor",
        "debuffOffsetX",
        "debuffOffsetY",
        "debuffSize",
        "debuffScale",
        "debuffAlpha",
        "debuffMax",
        "debuffWrap",
        "debuffWrapOffsetX",
        "debuffWrapOffsetY",
        "debuffGrowth",
        "debuffPaddingX",
        "debuffPaddingY",
        "debuffShowDuration",
        "debuffShowCountdown",
        "debuffHideSwipe",
        "debuffClickThrough",
        "debuffClickThroughInCombatOnly",
        "debuffClickThroughKeybinds",
        "debuffDisableMouse",
        "debuffDurationFont",
        "debuffDurationAnchor",
        "debuffDurationScale",
        "debuffDurationOutline",
        "debuffDurationX",
        "debuffDurationY",
        "debuffDurationColorByTime",
        "debuffDurationHideAboveEnabled",
        "debuffDurationHideAboveThreshold",
        "debuffCountdownFont",
        "debuffCountdownScale",
        "debuffCountdownOutline",
        "debuffCountdownX",
        "debuffCountdownY",
        "debuffStackFont",
        "debuffStackScale",
        "debuffStackOutline",
        "debuffStackAnchor",
        "debuffStackX",
        "debuffStackY",
        "debuffStackMinimum",
        "debuffBorderEnabled",
        "debuffBorderThickness",
        "debuffBorderInset",
        "debuffBorderColorByType",
        "debuffBorderColorNone",
        "debuffBorderColorMagic",
        "debuffBorderColorCurse",
        "debuffBorderColorDisease",
        "debuffBorderColorPoison",
        "debuffBorderColorBleed",
        "debuffExpiringEnabled",
        "debuffExpiringThreshold",
        "debuffExpiringThresholdMode",
        "debuffExpiringBorderEnabled",
        "debuffExpiringBorderColor",
        "debuffExpiringBorderColorByTime",
        "debuffExpiringBorderThickness",
        "debuffExpiringBorderInset",
        "debuffExpiringBorderPulsate",
        "debuffExpiringTintEnabled",
        "debuffExpiringTintColor",
        
        -- Boss Debuff (legacy highlight)
        "bossDebuffHighlight",
        "bossDebuffScale",
        
        -- Boss Debuffs Feature
        "bossDebuffsEnabled",
        "bossDebuffsAnchor",
        "bossDebuffsBorderScale",
        "bossDebuffsFrameLevel",
        "bossDebuffsStrata",
        "bossDebuffsGrowth",
        "bossDebuffsHideTooltip",
        "bossDebuffsIconSize",
        "bossDebuffsMax",
        "bossDebuffsOffsetX",
        "bossDebuffsOffsetY",
        "bossDebuffsShowCountdown",
        "bossDebuffsShowNumbers",
        "bossDebuffsSpacing",

        -- Container Overlay (12.0.5+) — enable state + dispel-type driven by
        -- the unified dispelOverlaySource / dispelOverlayDispelType keys in
        -- the Dispel category.
        "bossDebuffsContainerOverlayGradientDir",
        "bossDebuffsContainerOverlayAlpha",
        "bossDebuffsContainerOverlayFrameLevel",
        "bossDebuffsContainerOverlayStrata",
        "bossDebuffsContainerOverlaySizeAdjust",

        -- Buff Filters
        "buffFilterCancelable",
        "buffFilterMode",
        "buffFilterPlayer",
        "buffFilterRaid",
        
        -- Debuff Filters
        "debuffFilterMode",
        "debuffShowAll",

        -- Aura Source Mode (auraSourceMode intentionally excluded —
        -- forced to DIRECT, should not be overwritten by imports)
        "directBuffShowAll",
        "directBuffOnlyMine",
        "directBuffFilterRaid",
        "directBuffFilterRaidInCombat",
        "directBuffFilterCancelable",
        "directBuffFilterNotCancelable",
        "directBuffFilterImportant",
        "directBuffFilterBigDefensive",
        "directBuffFilterExternalDefensive",
        "directBuffSortOrder",
        "directDebuffShowAll",
        "directDebuffFilterRaid",
        "directDebuffFilterRaidInCombat",
        "directDebuffFilterCrowdControl",
        "directDebuffFilterImportant",
        "directDebuffDispellableMode",
        "directDebuffSortOrder",

        -- Dead Auras
        "fadeDeadAuras",
    },
    
    -- ===========================================
    -- TEXT - Name, status, health text & fonts
    -- ===========================================
    text = {
        -- Global Font Shadow Settings
        "fontShadowOffsetX",
        "fontShadowOffsetY",
        "fontShadowColor",
        
        -- Name Text
        "nameFont",
        "nameFontSize",
        "nameTextAnchor",
        "nameTextX",
        "nameTextY",
        "nameTextColor",
        "nameTextOutline",
        "nameTextLength",
        "nameTextTruncateMode",
        "nameTextUseClassColor",
        "nameColorClass",
        
        -- Status Text
        "statusTextEnabled",
        "statusTextFont",
        "statusTextFontSize",
        "statusTextAnchor",
        "statusTextX",
        "statusTextY",
        "statusTextColor",
        "statusTextOutline",
        
        -- Health Text
        "showHealthText",
        "healthFont",
        "healthFontSize",
        "healthTextAnchor",
        "healthTextX",
        "healthTextY",
        "healthTextColor",
        "healthTextUseClassColor",
        "healthTextOutline",
        "healthTextFormat",
        "healthTextHidePercent",
        "healthTextAbbreviate",
        
        -- Group Labels (Raid)
        "groupLabelColor",
        "groupLabelEnabled",
        "groupLabelFont",
        "groupLabelFontSize",
        "groupLabelFormat",
        "groupLabelOffsetX",
        "groupLabelOffsetY",
        "groupLabelOutline",
        "groupLabelPosition",
        "groupLabelShadow",
    },
    
    -- ===========================================
    -- ICONS - Role, leader, defensive, dispel, etc.
    -- ===========================================
    icons = {
        -- Status Icon Text Font Settings
        "statusIconFont",
        "statusIconFontSize",
        "statusIconFontOutline",
        
        -- Status Icon Text Colors
        "summonIconTextColor",
        "resurrectionIconTextColor",
        "phasedIconTextColor",
        "afkIconTextColor",
        "vehicleIconTextColor",
        "raidRoleIconTextColor",
        
        -- Role Icon
        "showRoleIcon",
        "roleIconAnchor",
        "roleIconX",
        "roleIconY",
        "roleIconScale",
        "roleIconAlpha",
        "roleIconFrameLevel",
        "roleIconStyle",
        "roleIconHide",
        "roleIconShowTank",
        "roleIconShowHealer",
        "roleIconShowDPS",
        "roleIconHideTank",
        "roleIconHideHealer",
        "roleIconHideDPS",
        "roleIconOnlyInCombat",
        "roleIconHideOnlyInCombat",
        "roleIconExternalTank",
        "roleIconExternalHealer",
        "roleIconExternalDPS",

        -- Leader Icon
        "leaderIconEnabled",
        "leaderIconAnchor",
        "leaderIconX",
        "leaderIconY",
        "leaderIconScale",
        "leaderIconAlpha",
        "leaderIconFrameLevel",
        "leaderIconHide",
        "leaderIconHideInCombat",
        
        -- Raid Target Icon
        "raidTargetIconEnabled",
        "raidTargetIconAnchor",
        "raidTargetIconX",
        "raidTargetIconY",
        "raidTargetIconScale",
        "raidTargetIconAlpha",
        "raidTargetIconFrameLevel",
        "raidTargetIconHide",
        "raidTargetIconHideInCombat",
        
        -- Ready Check Icon
        "readyCheckIconEnabled",
        "readyCheckIconAnchor",
        "readyCheckIconX",
        "readyCheckIconY",
        "readyCheckIconScale",
        "readyCheckIconAlpha",
        "readyCheckIconFrameLevel",
        "readyCheckIconHide",
        "readyCheckIconPersist",
        "readyCheckIconHideInCombat",
        
        -- Center Status Icon
        "centerStatusIconEnabled",
        "centerStatusIconAnchor",
        "centerStatusIconX",
        "centerStatusIconY",
        "centerStatusIconScale",
        "centerStatusIconFrameLevel",
        "centerStatusIconHide",
        
        -- Summon Icon
        "summonIconEnabled",
        "summonIconAnchor",
        "summonIconX",
        "summonIconY",
        "summonIconScale",
        "summonIconAlpha",
        "summonIconFrameLevel",
        "summonIconHideInCombat",
        "summonIconShowText",
        "summonIconTextPending",
        "summonIconTextAccepted",
        "summonIconTextDeclined",
        
        -- Resurrection Icon
        "resurrectionIconEnabled",
        "resurrectionIconAnchor",
        "resurrectionIconX",
        "resurrectionIconY",
        "resurrectionIconScale",
        "resurrectionIconAlpha",
        "resurrectionIconFrameLevel",
        "resurrectionIconShowText",
        "resurrectionIconTextCasting",
        "resurrectionIconTextPending",
        
        -- Phased Icon
        "phasedIconEnabled",
        "phasedIconAnchor",
        "phasedIconX",
        "phasedIconY",
        "phasedIconScale",
        "phasedIconAlpha",
        "phasedIconFrameLevel",
        "phasedIconHideInCombat",
        "phasedIconShowLFGEye",
        "phasedIconShowText",
        "phasedIconText",
        
        -- AFK Icon
        "afkIconEnabled",
        "afkIconAnchor",
        "afkIconX",
        "afkIconY",
        "afkIconScale",
        "afkIconAlpha",
        "afkIconFrameLevel",
        "afkIconHideInCombat",
        "afkIconShowText",
        "afkIconText",
        "afkIconShowTimer",
        
        -- Vehicle Icon
        "vehicleIconEnabled",
        "vehicleIconAnchor",
        "vehicleIconX",
        "vehicleIconY",
        "vehicleIconScale",
        "vehicleIconAlpha",
        "vehicleIconFrameLevel",
        "vehicleIconHideInCombat",
        "vehicleIconShowText",
        "vehicleIconText",
        
        -- Raid Role Icon (Main Tank/Assist)
        "raidRoleIconEnabled",
        "raidRoleIconAnchor",
        "raidRoleIconX",
        "raidRoleIconY",
        "raidRoleIconScale",
        "raidRoleIconAlpha",
        "raidRoleIconFrameLevel",
        "raidRoleIconHideInCombat",
        "raidRoleIconShowTank",
        "raidRoleIconShowAssist",
        "raidRoleIconShowText",
        "raidRoleIconTextTank",
        "raidRoleIconTextAssist",
        
        -- Defensive Icon
        "defensiveIconEnabled",
        "defensiveIconAnchor",
        "defensiveIconX",
        "defensiveIconY",
        "defensiveIconScale",
        "defensiveIconSize",
        "defensiveIconFrameLevel",
        "defensiveIconShowBorder",
        "defensiveIconBorderColor",
        "defensiveIconBorderSize",
        "defensiveIconShowDuration",
        "defensiveIconDurationFont",
        "defensiveIconDurationScale",
        "defensiveIconDurationOutline",
        "defensiveIconDurationX",
        "defensiveIconDurationY",
        "defensiveIconDurationColor",
        "defensiveIconDurationColorByTime",
        "defensiveIconHideSwipe",
        "defensiveIconClickThrough",
        "defensiveIconClickThroughInCombatOnly",
        "defensiveIconClickThroughKeybinds",
        "defensiveIconDisableMouse",
        
        -- Defensive Bar (legacy/bar mode)
        "defensiveBarEnabled",
        "defensiveBarAnchor",
        "defensiveBarX",
        "defensiveBarY",
        "defensiveBarScale",
        "defensiveBarIconSize",
        "defensiveBarFrameLevel",
        "defensiveBarMax",
        "defensiveBarGrowth",
        "defensiveBarSpacing",
        "defensiveBarWrap",
        "defensiveBarShowDuration",
        "defensiveBarBorderColor",
        "defensiveBarBorderSize",
        
        -- Targeted Spells
        "targetedSpellEnabled",
        "targetedSpellAnchor",
        "targetedSpellX",
        "targetedSpellY",
        "targetedSpellSize",
        "targetedSpellScale",
        "targetedSpellAlpha",
        "targetedSpellShowBorder",
        "targetedSpellBorderColor",
        "targetedSpellBorderSize",
        "targetedSpellHideSwipe",
        "targetedSpellShowDuration",
        "targetedSpellDurationFont",
        "targetedSpellDurationScale",
        "targetedSpellDurationOutline",
        "targetedSpellDurationX",
        "targetedSpellDurationY",
        "targetedSpellDurationColor",
        "targetedSpellDurationColorByTime",
        "targetedSpellGrowth",
        "targetedSpellSpacing",
        "targetedSpellFrameLevel",
        "targetedSpellMaxIcons",
        "targetedSpellSortByTime",
        "targetedSpellSortNewestFirst",
        "targetedSpellHighlightImportant",
        "targetedSpellHighlightStyle",
        "targetedSpellHighlightColor",
        "targetedSpellHighlightSize",
        "targetedSpellHighlightInset",
        "targetedSpellShowInterrupted",
        "targetedSpellInterruptedDuration",
        "targetedSpellInterruptedShowX",
        "targetedSpellInterruptedTintAlpha",
        "targetedSpellInterruptedTintColor",
        "targetedSpellInterruptedXColor",
        "targetedSpellInterruptedXSize",
        "targetedSpellDisableMouse",
        "targetedSpellNameplateOffscreen",
        "targetedSpellImportantOnly",
        "targetedSpellInOpenWorld",
        "targetedSpellInDungeons",
        "targetedSpellInArena",
        "targetedSpellInRaids",
        "targetedSpellInBattlegrounds",
        
        -- Personal Targeted Spells
        "personalTargetedSpellEnabled",
        "personalTargetedSpellX",
        "personalTargetedSpellY",
        "personalTargetedSpellSize",
        "personalTargetedSpellScale",
        "personalTargetedSpellAlpha",
        "personalTargetedSpellShowBorder",
        "personalTargetedSpellBorderColor",
        "personalTargetedSpellBorderSize",
        "personalTargetedSpellShowSwipe",
        "personalTargetedSpellShowDuration",
        "personalTargetedSpellDurationFont",
        "personalTargetedSpellDurationScale",
        "personalTargetedSpellDurationOutline",
        "personalTargetedSpellDurationX",
        "personalTargetedSpellDurationY",
        "personalTargetedSpellDurationColor",
        "personalTargetedSpellGrowth",
        "personalTargetedSpellSpacing",
        "personalTargetedSpellMaxIcons",
        "personalTargetedSpellHighlightImportant",
        "personalTargetedSpellHighlightStyle",
        "personalTargetedSpellHighlightColor",
        "personalTargetedSpellHighlightSize",
        "personalTargetedSpellHighlightInset",
        "personalTargetedSpellShowInterrupted",
        "personalTargetedSpellInterruptedDuration",
        "personalTargetedSpellInterruptedShowX",
        "personalTargetedSpellInterruptedTintAlpha",
        "personalTargetedSpellInterruptedTintColor",
        "personalTargetedSpellInterruptedXColor",
        "personalTargetedSpellInterruptedXSize",
        "personalTargetedSpellImportantOnly",
        "personalTargetedSpellInOpenWorld",
        "personalTargetedSpellInDungeons",
        "personalTargetedSpellInRaids",
        "personalTargetedSpellInArena",
        "personalTargetedSpellInBattlegrounds",
        
        -- Dispel Indicator
        "dispelOverlaySource",
        "dispelOverlayDispelType",
        "dispelOverlayMode",
        "dispelShowBorder",
        "dispelShowGradient",
        "dispelShowIcon",
        "dispelBorderStyle",
        "dispelBorderSize",
        "dispelBorderInset",
        "dispelBorderAlpha",
        "dispelGradientStyle",
        "dispelGradientSize",
        "dispelGradientIntensity",
        "dispelGradientAlpha",
        "dispelGradientBlendMode",
        "dispelGradientDarkenEnabled",
        "dispelGradientDarkenAlpha",
        "dispelGradientOnCurrentHealth",
        "dispelIconPosition",
        "dispelIconOffsetX",
        "dispelIconOffsetY",
        "dispelIconSize",
        "dispelIconAlpha",
        "dispelFrameLevel",
        "dispelShowMagic",
        "dispelShowCurse",
        "dispelShowPoison",
        "dispelShowDisease",
        "dispelShowBleed",
        "dispelShowEnrage",
        "dispelMagicColor",
        "dispelCurseColor",
        "dispelPoisonColor",
        "dispelDiseaseColor",
        "dispelBleedColor",
        "dispelOnlyPlayerTypes",
        "dispelAnimate",
        "dispelAnimateSpeed",
        "dispellableHighlight",
        
        -- Missing Buff Icon
        "missingBuffIconEnabled",
        "missingBuffIconAnchor",
        "missingBuffIconX",
        "missingBuffIconY",
        "missingBuffIconSize",
        "missingBuffIconScale",
        "missingBuffIconFrameLevel",
        "missingBuffIconShowBorder",
        "missingBuffIconBorderColor",
        "missingBuffIconBorderSize",
        "missingBuffCheckStamina",
        "missingBuffCheckIntellect",
        "missingBuffCheckAttackPower",
        "missingBuffCheckVersatility",
        "missingBuffCheckSkyfury",
        "missingBuffCheckBronze",
        "missingBuffClassDetection",
        "missingBuffHideFromBar",
        "missingBuffIconDebug",
        
        -- External Def (legacy)
        "externalDefEnabled",
        "externalDefAnchor",
        "externalDefX",
        "externalDefY",
        "externalDefScale",
        "externalDefFrameLevel",
        "externalDefStrata",
        "externalDefShowDuration",
        "externalDefBorderColor",
        "externalDefBorderSize",
    },
    
    -- ===========================================
    -- OTHER - Aggro, selection, range, tooltips, pets, misc
    -- ===========================================
    other = {
        -- Border
        "showFrameBorder",
        "borderColor",
        
        -- Aggro Highlight
        "aggroHighlightMode",
        "aggroHighlightAlpha",
        "aggroHighlightThickness",
        "aggroHighlightInset",
        "aggroOnlyTanking",
        "aggroUseCustomColors",
        "aggroColorHighThreat",
        "aggroColorHighestThreat",
        "aggroColorTanking",
        
        -- Selection Highlight
        "selectionHighlightMode",
        "selectionHighlightAlpha",
        "selectionHighlightColor",
        "selectionHighlightThickness",
        "selectionHighlightInset",
        
        -- Hover Highlight
        "hoverHighlightAlpha",
        "hoverHighlightColor",
        "hoverHighlightInset",
        "hoverHighlightMode",
        "hoverHighlightThickness",
        
        -- Health Threshold Fading
        "healthFadeEnabled",
        "healthFadeAlpha",
        "healthFadeThreshold",
        "hfCancelOnDispel",

        -- Out of Range
        "oorEnabled",
        "rangeAlpha",
        "rangeCheckEnabled",
        "rangeCheckSpellID",
        "rangeFadeAlpha",
        "oorHealthBarAlpha",
        "oorMissingHealthAlpha",
        "oorHealthTextAlpha",
        "oorBackgroundAlpha",
        "oorPowerBarAlpha",
        "oorAurasAlpha",
        "oorNameTextAlpha",
        "oorIconsAlpha",
        "oorDispelOverlayAlpha",
        "oorDefensiveIconAlpha",
        "oorMissingBuffAlpha",
        "oorTargetedSpellAlpha",
        "oorAuraDesignerAlpha",

        -- Dead/Offline
        "deadFadeEnabled",
        "deadUseCustomBgColor",
        "deadBackgroundColor",
        "deadBackgroundAlpha",
        "deadHealthBarAlpha",
        "deadHealthTextAlpha",
        "deadNameAlpha",
        "fadeDeadFrames",
        "fadeDeadUseCustomColor",
        "fadeDeadBackgroundColor",
        "fadeDeadBackground",
        "fadeDeadHealthBar",
        "fadeDeadPowerBar",
        "fadeDeadName",
        "fadeDeadStatusText",
        "fadeDeadIcons",
        
        -- Tooltips
        "tooltipFrameEnabled",
        "tooltipFrameAnchor",
        "tooltipFrameAnchorPos",
        "tooltipFrameX",
        "tooltipFrameY",
        "tooltipFrameDisableInCombat",
        "tooltipBuffEnabled",
        "tooltipBuffAnchor",
        "tooltipBuffAnchorPos",
        "tooltipBuffX",
        "tooltipBuffY",
        "tooltipBuffDisableInCombat",
        "tooltipDebuffEnabled",
        "tooltipDebuffAnchor",
        "tooltipDebuffAnchorPos",
        "tooltipDebuffX",
        "tooltipDebuffY",
        "tooltipDebuffDisableInCombat",
        "tooltipDefensiveEnabled",
        "tooltipDefensiveAnchor",
        "tooltipDefensiveAnchorPos",
        "tooltipDefensiveX",
        "tooltipDefensiveY",
        "tooltipDefensiveDisableInCombat",
        "tooltipBindingEnabled",
        "tooltipBindingAnchor",
        "tooltipBindingAnchorPos",
        "tooltipBindingX",
        "tooltipBindingY",
        "tooltipBindingDisableInCombat",
        "tooltipAuraEnabled",
        "tooltipAuraAnchor",
        "tooltipAuraX",
        "tooltipAuraY",
        "tooltipAuraDisableInCombat",
        
        -- Pet Frames
        "petEnabled",
        "petFrameWidth",
        "petFrameHeight",
        "petMatchOwnerWidth",
        "petMatchOwnerHeight",
        "petAnchor",
        "petOffsetX",
        "petOffsetY",
        "petTexture",
        "petShowBorder",
        "petBorderColor",
        "petBackgroundColor",
        "petHealthBgColor",
        "petHealthColorMode",
        "petHealthColor",
        "petShowHealthText",
        "petNameFont",
        "petNameFontSize",
        "petNameFontOutline",
        "petNameMaxLength",
        "petNameAnchor",
        "petNameX",
        "petNameY",
        "petNameColor",
        "petHealthFont",
        "petHealthFontSize",
        "petHealthFontOutline",
        "petHealthAnchor",
        "petHealthX",
        "petHealthY",
        "petHealthTextColor",
        "petGroupMode",
        "petGroupAnchor",
        "petGroupGrowth",
        "petGroupSpacing",
        "petGroupOffsetX",
        "petGroupOffsetY",
        "petGroupLabel",
        "petGroupShowLabel",
        
        -- Hide Blizzard Frames
        "hideBlizzardFrames",
        "hideBlizzardPartyFrames",
        "hideBlizzardRaidFrames",
        
        -- Misc UI
        "showMinimapButton",
        "showBlizzardSideMenu",
        "masqueBorderControl",
        
        -- Color Picker Overrides
        "colorPickerGlobalOverride",
        "colorPickerOverride",
        
        -- Test Mode settings
        "testPreset",
        "testAnimateHealth",
        "testShowAuras",
        "testShowAbsorbs",
        "testShowHealPrediction",
        "testShowAggro",
        "testShowSelection",
        "testShowOutOfRange",
        "testShowDispelGlow",
        "testShowExternalDef",
        "testShowMissingBuff",
        "testShowIcons",
        "testShowStatusIcons",
        "testShowPets",
        "testBuffCount",
        "testDebuffCount",
        "testBossDebuffCount",
        "testShowBossDebuffs",
        "testShowTargetedSpell",
        "testShowClassPower",
    },
    
    -- ===========================================
    -- HIGHLIGHT FRAMES - Separate frame sets for selected players
    -- ===========================================
    pinnedFrames = {
        "pinnedFrames",  -- The entire pinnedFrames table is treated as one setting
    },

    -- ===========================================
    -- AURA DESIGNER - Spec-specific aura indicators
    -- ===========================================
    auraDesigner = {
        "auraDesigner",  -- The entire auraDesigner table is treated as one setting
    },

    -- ===========================================
    -- AUTO LAYOUTS - Raid size auto-layout profiles
    -- ===========================================
    autoLayout = {
        "raidAutoProfiles",  -- Top-level key, handled specially in export/import
    },
}

-- ===========================================
-- CATEGORY DISPLAY INFO
-- ===========================================
DF.ExportCategoryInfo = {
    position = {
        name = "Position",
        description = "Where frames appear on screen",
        order = 1,
    },
    layout = {
        name = "Frame Layout",
        description = "Size, spacing, growth, sorting",
        order = 2,
    },
    bars = {
        name = "Bars",
        description = "Health, power, absorbs, heal prediction",
        order = 3,
    },
    auras = {
        name = "Auras",
        description = "Buffs & debuffs",
        order = 4,
    },
    text = {
        name = "Text",
        description = "Name, status, health text & fonts",
        order = 5,
    },
    icons = {
        name = "Icons",
        description = "Role, leader, defensive, dispel, etc.",
        order = 6,
    },
    other = {
        name = "Other",
        description = "Aggro, selection, range, tooltips, pets",
        order = 7,
    },
    pinnedFrames = {
        name = "Pinned Frames",
        description = "Separate frame sets for selected players",
        order = 8,
    },
    auraDesigner = {
        name = "Aura Designer",
        description = "Spec-specific aura indicators and effects",
        order = 9,
    },
    autoLayout = {
        name = "Auto Layouts",
        description = "Raid size auto-layout profiles",
        order = 10,
    },
}

-- ===========================================
-- QUICK PRESETS
-- ===========================================
DF.ExportPresets = {
    all = {
        name = "All",
        categories = {"position", "layout", "bars", "auras", "text", "icons", "other", "pinnedFrames", "auraDesigner", "autoLayout"},
    },
    appearance = {
        name = "Appearance",
        description = "Visual style without position/layout",
        categories = {"bars", "auras", "text", "icons", "other"},
    },
    layoutOnly = {
        name = "Layout",
        description = "Position and frame dimensions only",
        categories = {"position", "layout"},
    },
    none = {
        name = "None",
        categories = {},
    },
}

-- ===========================================
-- HELPER FUNCTIONS
-- ===========================================

-- Build a reverse lookup: setting key -> category
function DF:BuildCategoryLookup()
    if self._categoryLookup then return self._categoryLookup end
    
    self._categoryLookup = {}
    for category, keys in pairs(self.ExportCategories) do
        for _, key in ipairs(keys) do
            self._categoryLookup[key] = category
        end
    end
    return self._categoryLookup
end

-- Get category for a setting key
function DF:GetSettingCategory(key)
    local lookup = self:BuildCategoryLookup()
    return lookup[key]
end

-- Extract settings for specific categories from a profile
function DF:ExtractCategorySettings(profile, categories, frameType)
    local result = {}
    local categorySet = {}
    for _, cat in ipairs(categories) do
        categorySet[cat] = true
    end
    
    for category, keys in pairs(self.ExportCategories) do
        if categorySet[category] then
            for _, key in ipairs(keys) do
                if profile[key] ~= nil then
                    result[key] = profile[key]
                end
            end
        end
    end
    
    return result
end

-- Merge imported settings into profile for specific categories
function DF:MergeCategorySettings(profile, imported, categories)
    local categorySet = {}
    for _, cat in ipairs(categories) do
        categorySet[cat] = true
    end
    
    for category, keys in pairs(self.ExportCategories) do
        if categorySet[category] then
            for _, key in ipairs(keys) do
                if imported[key] ~= nil then
                    profile[key] = imported[key]
                end
            end
        end
    end
end

-- Check which categories are present in imported data
function DF:DetectImportedCategories(imported)
    local found = {}
    local lookup = self:BuildCategoryLookup()
    
    for key, _ in pairs(imported) do
        local category = lookup[key]
        if category and not found[category] then
            found[category] = true
        end
    end
    
    -- Convert to sorted list
    local result = {}
    for category, _ in pairs(found) do
        table.insert(result, category)
    end
    table.sort(result, function(a, b)
        return (self.ExportCategoryInfo[a].order or 99) < (self.ExportCategoryInfo[b].order or 99)
    end)
    
    return result
end
