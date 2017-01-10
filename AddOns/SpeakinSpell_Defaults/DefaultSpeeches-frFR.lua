-- Author      : RisM
-- Create Date : 5/21/2009 11:46:36 PM

-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local DEFAULT_SPEECHES = AceLocale:NewLocale("SpeakinSpell_DEFAULT_SPEECHES", "frFR", false)
if not DEFAULT_SPEECHES then return end

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
SpeakinSpell:PrintLoading("defaults/DefaultSpeeches-frFR.lua")

-------------------------------------------------------------------------------
-- DEFAULT SPEECH TEMPLATES FOR VARIOUS KINDS OF PLAYERS
-------------------------------------------------------------------------------

DEFAULT_SPEECHES.Templates = {


-------------------------------------------------------------------------------
} -- end DEFAULT_SPEECHES.Templates

