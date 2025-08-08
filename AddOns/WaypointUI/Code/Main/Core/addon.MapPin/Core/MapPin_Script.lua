---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.MapPin; addon.MapPin = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		function Callback:GetCurrentPinPosition()
			local result = {}

			--------------------------------

			local pin = C_Map.GetUserWaypoint()
			if not pin then return nil end

			local mapID = pin.uiMapID
			local pos = pin.position

			result = {
				pin = pin,
				mapID = mapID,
				pos = pos
			}

			--------------------------------

			return result
		end
	end

	--------------------------------
	-- FUNCTIONS (GLOBAL)
	--------------------------------

	do
		function WaypointUI_ClearWay()
			if WaypointUI_IsWay() then
				C_Map.ClearUserWaypoint()
			end

			--------------------------------

			WaypointUI_SetWay()
		end

		function WaypointUI_SetWay(name, mapID, x, y)
			NS.Variables.Way = {
				["name"] = name or nil,
				["mapID"] = mapID or nil,
				["x"] = x or nil,
				["y"] = y or nil,
			}
			addon.C.Database.Variables.DB_LOCAL_PERSISTENT.profile.SAVED_WAY = NS.Variables.Way
		end

		function WaypointUI_GetWay()
			-- [@y45853160]: 获取保存的标记数据
			-- Get saved way
			local savedWay = addon.C.Database.Variables.DB_LOCAL_PERSISTENT.profile.SAVED_WAY

			-- [@y45853160]: 检查数据是否存在，如果不存在则返回默认值
			-- Check if the way exists, if not return a default value
			if not savedWay then
				-- [@y45853160]: 创建一个空的Way对象
				-- Reset way
				NS.Variables.Way = {
					name = nil,
					mapID = nil,
					x = nil,
					y = nil
				}
				-- [@y45853160]: 保存到数据库，确保数据初始化
				-- Save to the database
				addon.C.Database.Variables.DB_LOCAL_PERSISTENT.profile.SAVED_WAY = NS.Variables.Way
			else
				NS.Variables.Way = savedWay
			end

			return NS.Variables.Way
		end

		function WaypointUI_NewWay(name, mapID, x, y)
			if C_Map.CanSetUserWaypointOnMap(mapID) then
				local pos = CreateVector2D(x / 100, y / 100)
				local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)

				--------------------------------

				WaypointUI_SetWay(name, mapID, pos.x, pos.y)
				C_Map.SetUserWaypoint(mapPoint)
				C_SuperTrack.SetSuperTrackedUserWaypoint(true)

				--------------------------------

				CallbackRegistry:Trigger("MapPin.NewWay")

				--------------------------------

				addon.C.Sound.Script:PlaySound(89712)
			end
		end

		function WaypointUI_IsWay()
			-- [@y45853160]: 检查是否存在用户标记
			-- Check if map pin exists
			if C_Map.HasUserWaypoint() then
				local pinTracked = C_SuperTrack.GetHighestPrioritySuperTrackingType() == Enum.SuperTrackingType.UserWaypoint
				local pin = Callback:GetCurrentPinPosition()
				local way = WaypointUI_GetWay()

				-- [@y45853160]: 检查way是否有效
				-- Check if way is valid
				if way and way.mapID and way.x and way.y then
					-- [@y45853160]: 比较地图ID和坐标（四舍五入到整数以处理浮点数精度问题
					-- Compare map IDs and coordinates (rounded to integers to handle floating point precision issues)
					return pinTracked and
						tostring(pin.mapID) == tostring(way.mapID) and
						math.ceil(pin.pos.x * 100) == math.ceil(way.x * 100) and
						math.ceil(pin.pos.y * 100) == math.ceil(way.y * 100)
				end
			end

			return false
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	do
		local Event = addon.C.FrameTemplates:CreateFrame("Frame")
		Event:RegisterEvent("USER_WAYPOINT_UPDATED")
		Event:SetScript("OnEvent", function(_, event, ...)
			if event == "USER_WAYPOINT_UPDATED" then
				C_Timer.After(0, function()
					C_SuperTrack.SetSuperTrackedUserWaypoint(true)
				end)
			end
		end)
	end

	--------------------------------
	-- SETUP
	--------------------------------

	do
		-- [@y45853160]: 初始化数据
		-- initialization data

		-- [@y45853160]: 确保数据已初始化
		-- Make sure the data is initialized

		WaypointUI_GetWay()
	end
end
