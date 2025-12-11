local env                                   = select(2, ...)
local WoWClient_Versioning                  = env.WPM:New("wpm_modules/wow-client/versioning")

local BUILD_NUMBER                          = select(4, GetBuildInfo())
WoWClient_Versioning.IS_RETAIL              = BUILD_NUMBER >= 110000
WoWClient_Versioning.IS_CLASSIC_PROGRESSION = (not WoWClient_Versioning.IS_RETAIL) and (BUILD_NUMBER >= 50000)
WoWClient_Versioning.IS_CLASSIC_ERA         = (not WoWClient_Versioning.IS_RETAIL) and (not WoWClient_Versioning.IS_CLASSIC_PROGRESSION)
WoWClient_Versioning.IS_CLASSIC_ALL         = (WoWClient_Versioning.IS_CLASSIC_PROGRESSION) or (WoWClient_Versioning.IS_CLASSIC_ERA)
