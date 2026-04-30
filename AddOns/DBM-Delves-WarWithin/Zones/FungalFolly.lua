local mod	= DBM:NewMod("z2664", "DBM-Delves-WarWithin", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260315034941")
mod:DisableHardcodedOptions()
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2664)

mod:RegisterCombat("scenario", 2664)
