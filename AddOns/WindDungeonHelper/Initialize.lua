local addonName, addon = ...

local LibStub = _G.LibStub
local GetAddOnMetadata = GetAddOnMetadata

local Engine = LibStub("AceAddon-3.0"):NewAddon(addonName)
local Locale = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

addon[1] = Engine
addon[2] = {} -- Funtions
addon[3] = Locale

_G["WindDungeonHelper"] = addon

-- Variables
Engine.AddonName = Locale["Wind Dungeon Helper"]
Engine.Version = GetAddOnMetadata(addonName, "Version")
Engine.AddonMsgPrefix = "WINDDH"