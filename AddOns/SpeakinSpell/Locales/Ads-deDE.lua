-- Author      : Ris
-- Create Date : 11/20/2010 3:43:04 PM

-- German localization file for deDE
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local DEFAULT_ADS = AceLocale:NewLocale("SpeakinSpell_DEFAULT_SPEECHES", "deDE", false)
if not DEFAULT_ADS then return end

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
SpeakinSpell:PrintLoading("Locales/Ads-deDE.lua")

-------------------------------------------------------------------------------
-- ADVERTISEMENTS for /ss ad
-------------------------------------------------------------------------------

DEFAULT_ADS.ADVERTISEMENTS = {
	[[Gefallen an meinen Makros gefunden? Besorg dir auch das Add on "SpeakinSpell", jetzt auch komplett in Deutsch!]],
}

