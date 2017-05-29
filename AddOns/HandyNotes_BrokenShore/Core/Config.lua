-- $Id: Config.lua 55 2017-05-17 11:57:08Z arith $
-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
-- Functions
local _G = getfenv(0)
local pairs = _G.pairs
-- Libraries
-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local FOLDER_NAME, private = ...
local LibStub = _G.LibStub;
local addon = LibStub("AceAddon-3.0"):GetAddon(private.addon_name)
local L = LibStub("AceLocale-3.0"):GetLocale(private.addon_name);

local config = {}
private.config = config

config.options = {
	type = "group",
	name = addon.pluginName,
	desc = addon.description,
	get = function(info) return private.db[info[#info]] end,
	set = function(info, v)
		private.db[info[#info]] = v
		addon:SendMessage("HandyNotes_NotifyUpdate", addon.pluginName)
	end,
	args = {
		icon = {
			type = "group",
			name = L["Icon settings"],
			inline = true,
			order = 10,
			args = {
				desc = {
					name = L["These settings control the look and feel of the icon."],
					type = "description",
					order = 0,
				},
				icon_scale = {
					type = "range",
					name = L["Icon Scale"],
					desc = L["The scale of the icons"],
					min = 0.25, max = 2, step = 0.01,
					order = 20,
				},
				icon_alpha = {
					type = "range",
					name = L["Icon Alpha"],
					desc = L["The alpha transparency of the icons"],
					min = 0, max = 1, step = 0.01,
					order = 30,
				},
			},
		},
		display = {
			type = "group",
			name = L["What to display"],
			inline = true,
			order = 20,
			args = {
				desc = {
					name = L["These settings control what type of icons to be displayed."],
					type = "description",
					order = 0,
				},
				show_entrance = {
					type = "toggle",
					name = L["Entrance"],
					desc = L["Show the entrance of specific cave or the entrance to special location."],
					order = 10,
				},
				show_ramp = {
					type = "toggle",
					name = L["Ramp"],
					desc = L["Show ramp to the higher ground. This could be useful before you can fly!"],
					order = 11,
				},
				show_rare = {
					type = "toggle",
					name = L["Rare mobs"],
					desc = L["Show rare mobs' location even if any of them has not yet spawned."],
					order = 12,
				},
				show_treasure = {
					type = "toggle",
					name = L["Wyrmtongue Chest"],
					desc = L["Show possible spawning location of Veiled Wyrmtongue Chest."],
					order = 13,
				},
				show_shrine = {
					type = "toggle",
					name = L["Ancient Shrine"],
					desc = L["Show Ancient Shrine's locations."],
					order = 14,
				},
				show_infernalCores = {
					type = "toggle",
					name = L["Smoldering Infernal Core"],
					desc = L["Show Smoldering Infernal Core's locations."],
					order = 15,
				},
				show_tamer = {
					type = "toggle",
					name = SHOW_PET_BATTLES_ON_MAP_TEXT,
					desc = L["Show Master Pet Tamer's location."],
					order = 16,
				},
				show_netherPortals = {
					type = "toggle",
					name = L["Unstable Nether Portal"],
					desc = L["Show Unstable Nether Portal's location."],
					order = 17,
				},
				show_others = {
					type = "toggle",
					name = L["Others"],
					desc = L["Show all the other misc nodes."],
					order = 20,
				},
			},
		},
		plugin_config = {
			type = "group",
			name = L["AddOn Settings"],
			inline = true,
			order = 30,
			args = {
				query_server = {
					type = "toggle",
					name = L["Query from server"],
					desc = L["Send query request to server to lookup localized names. May be a little bit slower for the first time lookup but would be very fast once the name is found and cached."],
					order = 10,
				},
				show_note = {
					type = "toggle",
					name = L["Show note"],
					desc = L["Show the node's additional notes when it's available."],
					order = 11,
				},
				hide_completed = {
					type = "toggle",
					name = L["Hide looted mobs"],
					desc = L["Hide the rare elite mobs which have been killed and looted today."],
					order = 15,
				},
				show_coords = {
					type = "toggle",
					name = L["Show coordinate"],
					desc = L["Show node's coordinate information."],
					order = 16,
				},
				unhide = {
					type = "execute",
					name = L["Reset hidden nodes"],
					desc = L["Show all nodes that you manually hid by right-clicking on them and choosing \"hide\"."],
					func = function()
						for map,coords in pairs(private.hidden) do
							wipe(coords)
						end
						addon:Refresh()
					end,
					order = 50,
				},
			},
		},
	},
}

