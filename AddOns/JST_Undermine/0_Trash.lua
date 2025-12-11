local T, C, L, G = unpack(JST)

G.Encounter_Order[1296] = {2639, 2640, 2641, 2642, 2653, 2644, 2645, 2646, "1296_R_Trash"}

local function soundfile(filename, arg)
	return string.format("[1296\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["1296_R_Trash"] = { -- Test
	map_id = 2769,
	alerts = {
		
	},
}