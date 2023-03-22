local W, F, E, L = unpack((select(2, ...)))
local A = E:GetModule("Auras")
local S = W.Modules.Skins

local _G = _G

function S:ElvUI_AltPowerBar()
    if not (E.private.WT.skins.elvui.enable and E.private.WT.skins.elvui.altPowerBar) then
        return
    end

    local bar = _G.ElvUI_AltPowerBar
    
    if not bar then
        return
    end
    
    self:CreateBackdropShadow(bar)
end

S:AddCallback("ElvUI_AltPowerBar")
