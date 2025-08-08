-- Developer: @AdaptiveX
-- ♡ Contributor: @BadBoyBarny

---@class addon
local addon = select(2, ...)
local NS = addon.C.AddonInfo; addon.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.SlashCommand = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do  -- CONSTANTS
	do -- REGISTER
		--------------------------------
		-- DOCUMENTATION
		--------------------------------

		do
			-- 	[1] = {
			-- 		["name"] = "EXAMPLE", -- Slash command ID.
			-- 		["hook"] = "EXAMPLE_02", -- Trigger when another slash command ID is called.
			-- 		["command"] = "/example",
			-- 		["callback"] = function(msg, tokens)
			-- 			...
			-- 		end
			-- 	}
		end

		--------------------------------
		-- TABLE
		--------------------------------

		local function WAYPOINT_UI_WAY_LOCATION()
			local playerMapID = C_Map.GetBestMapForUnit("player")
			local playerPosition = C_Map.GetPlayerMapPosition(playerMapID, "player")

			DEFAULT_CHAT_FRAME:AddMessage(addon.CS:GetChatIcon("chat-subdivider", 16) .. " " .. addon.C.AddonInfo.Locales["SlashCommand - /way - Map ID - Prefix"] .. playerMapID .. addon.C.AddonInfo.Locales["SlashCommand - /way - Map ID - Suffix"])
			DEFAULT_CHAT_FRAME:AddMessage(addon.CS:GetChatIcon("chat-subdivider", 16) .. " " .. addon.C.AddonInfo.Locales["SlashCommand - /way - Position - Axis (X) - Prefix"] .. math.ceil(playerPosition.x * 100) .. addon.C.AddonInfo.Locales["SlashCommand - /way - Position - Axis (X) - Suffix"] .. addon.C.AddonInfo.Locales["SlashCommand - /way - Position - Axis (Y) - Prefix"] .. math.ceil(playerPosition.y * 100) .. addon.C.AddonInfo.Locales["SlashCommand - /way - Position - Axis (Y) - Suffix"])
		end

		local function WAYPOINT_UI_WAY_CATCH()
			DEFAULT_CHAT_FRAME:AddMessage(addon.CS:GetAddonInlineIcon(16) .. " /way " .. addon.CS:GetSharedColor().RGB_YELLOW_HEXCODE .. "#<mapID> <x> <y> <name>" .. "|r")
			DEFAULT_CHAT_FRAME:AddMessage(addon.CS:GetChatIcon("chat-subdivider", 16) .. " /way " .. addon.CS:GetSharedColor().RGB_YELLOW_HEXCODE .. "<x> <y> <name>" .. "|r")
			DEFAULT_CHAT_FRAME:AddMessage(addon.CS:GetChatIcon("chat-subdivider", 16) .. " /way " .. addon.CS:GetSharedColor().RGB_YELLOW_HEXCODE .. "reset" .. "|r")

			WAYPOINT_UI_WAY_LOCATION()
		end

		NS.Variables.SlashCommand.REGISTER = {
			-- /way
			[1] = {
				["name"] = "WAYPOINT_UI_WAY",
				["hook"] = "TOMTOM_WAY",
				["command"] = "way",
				["callback"] = function(msg, tokens)
					if #tokens >= 1 then
						local firstToken = tokens[1]:lower()
						local token1 = tokens[1]
						local token2 = tokens[2]
						local token3 = tokens[3]

						local mapID = nil
						local x = nil
						local y = nil
						local name = ""

						--------------------------------

						if firstToken == "reset" or firstToken == "clear" then
							WaypointUI_ClearWay()
						else
							-- <#mapID> <x> <y>
							if token1 and token2 and token3 and (token1 and tonumber(token2) and tonumber(token3)) then
								-- Check for valid mapID
								local token1Formatted = string.gsub(token1, "#", "")
								local token1Number = tonumber(token1Formatted)
								local token1Valid = type(token1Number) == "number"

								if not token1Valid then
									WAYPOINT_UI_WAY_CATCH()

									--------------------------------

									return
								end

								-- Process /way
								mapID = token1Number
								x = token2
								y = token3
								for i = 4, #tokens do
									if #name >= 1 then
										name = name .. " " .. tokens[i]
									else
										name = name .. tokens[i]
									end
								end

								-- <x> <y>
							elseif token1 and token2 and (tonumber(token1) and tonumber(token2)) then
								mapID = C_Map.GetBestMapForUnit("player")
								x = token1
								y = token2
								for i = 3, #tokens do
									if #name >= 1 then
										name = name .. " " .. tokens[i]
									else
										name = name .. tokens[i]
									end
								end
							else
								WAYPOINT_UI_WAY_CATCH()

								--------------------------------

								return
							end

							--------------------------------

							WaypointUI_NewWay(name, mapID, x, y)
						end
					else
						WAYPOINT_UI_WAY_CATCH()

						--------------------------------

						return
					end
				end
			},
			-- General
			[2] = {
				["name"] = "WAYPOINT_UI",
				["hook"] = nil,
				["command"] = { "waypoint", "wp" },
				["callback"] = function(msg, tokens)
					if #tokens >= 1 then
						local firstToken = tokens[1]:lower()
						local token1 = tokens[1]
						local token2 = tokens[2]
						local token3 = tokens[3]

						--------------------------------

						if firstToken == "reset" or firstToken == "clear" or firstToken == "r" or firstToken == "c" then
							WaypointUI_ClearAll()
						end
					end
				end
			},
		}
	end
end
