local W, F, E, L = unpack((select(2, ...)))
local S = W.Modules.Skins

local _G = _G

function S:Blizzard_TrainerUI()
    if not self:CheckDB("trainer") then
        return
    end

    self:CreateShadow(_G.ClassTrainerFrame)
end

S:AddCallbackForAddon("Blizzard_TrainerUI")
