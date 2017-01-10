-- Author      : Ris
-- Create Date : 11/20/2010 3:43:14 PM

-- Korean localization file for koKR
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local DEFAULT_ADS = AceLocale:NewLocale("SpeakinSpell_DEFAULT_SPEECHES", "koKR", false)
if not DEFAULT_ADS then return end

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
SpeakinSpell:PrintLoading("Locales/Ads-koKR.lua")

-------------------------------------------------------------------------------
-- ADVERTISEMENTS for /ss ad
-------------------------------------------------------------------------------

DEFAULT_ADS.ADVERTISEMENTS = {
	[[SpeakinSpell은 여러분이 마법을 사용하거나 버프 및 디버프를 받았을 경우 외부에 자동으로 알릴 수 있는 애드온입니다.]]
}

