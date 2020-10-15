local PI = math.pi;

NarciModelInfo = {};

local GetSceneInfo = {
    --[raceID] = { [gender] = {Facing, Scale, Offset Amplifier, {PanningOffsets Full Central}, {PanningOffsets Full Right}, {PanningOffsets Upper Body Right}, {PanningOffsets Lower Body Right} }},
    [1]  = {2.4, 2},		-- Human
    [2]  = {2.5, 2},		-- Orc bow
    [3]  = {2.5, 2},		-- Dwarf
    [4] = {
        [2] = {-PI/2, 0.62, 1.4, {-1.24, -44.80}, },          -- Night Elf
    },
    [5]  = {2.5, 2},		-- UD
    [6]  = {3, 2.5},		-- Tauren
    [7]  = {2.6, 2.8},		-- Gnome
    [8]  = {2.5, 2},		-- Troll
    [9]  = {2.9, 2.9},		-- Goblin

    [10] = {
        [3] = {-PI/2, 0.84, 1, {0, -43.15}, {174, -47}, {170, 36}, {201, -188} },          -- Blood Elf
    },

    [11] = {2.4, 2},		-- Goat
    [22] = {2.8, 2},        -- Worgen
    [24] = {2.9, 2.4},		-- Pandaren
    [27] = {2, 2},		-- Nightborne
    --[29] = {2, 2},            -- Void Elf
    --[28] = {2, 2},		-- Highmountain Tauren
    --[30] = {2, 2},		-- Lightforged Draenei
    [31] = {2.2, 2},		-- Zandalari
    [32] = {2.4, 2.3},		-- Kul'Tiran
    --[34] = {2, 2},		-- Dark Iron Dwarf
    [35] = {2.6, 2.1},      -- Vulpera
    --[36] = {2, 2},		-- Mag'har
    --[37] = {2, 2},      -- Mechagnome
};

function NarciModelInfo:GetSceneInfo(raceID, genderID)
    raceID = 10 --4;
    genderID = 3 --2;
    return unpack(GetSceneInfo[raceID][genderID])
end

--[[
    Assets
    8fx_
    Spotlight
    Fog
    2125959/2150548 8fx_uldir_door_titan.m2     0.06  6,0,0     2180721 0.12
    1688083 7fx_argus_vol_sparkles.m2   0.1
    948186  arrow_state_animated.m2
    /dump Narci_Outfit.ModelScene:SetCameraNearClip(1)  -4.2, 0, 0.8

    Animations
    109 Bow Aim     105 Bow Load
--]]