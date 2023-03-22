local W, F, E, L = unpack((select(2, ...)))
local S = W.Modules.Skins

local _G = _G

function S:TutorialFrame()
    if not self:CheckDB("trade") then
        return
    end

    self:CreateShadow(_G.TradeFrame)
end

S:AddCallback("TutorialFrame")
