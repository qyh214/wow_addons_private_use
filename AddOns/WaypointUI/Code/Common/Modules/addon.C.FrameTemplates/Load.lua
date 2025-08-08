---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales

--------------------------------

addon.C.FrameTemplates = {}
addon.C.FrameTemplates.Styles = {}
local NS = addon.C.FrameTemplates; addon.C.FrameTemplates = NS

--------------------------------

function NS:Load()
	local function Modules()

	end

	local function Prefabs()
		NS.Prefabs:Load()
	end

	--------------------------------

	Prefabs()
	Modules()
end
