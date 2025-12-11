local env = select(2, ...)
local Setting_Shared = env.WPM:New("@/Setting/Shared")


-- Variables
--------------------------------

Setting_Shared.NAME = env.NAME
Setting_Shared.FRAME_NAME = "WUISettingFrame"
Setting_Shared.DB_GLOBAL_NAME = "WaypointDB_Global"
