local me, ns = ...
local print,hooksecurefunc,IsAddOnLoaded=print,hooksecurefunc,IsAddOnLoaded
local gc,gb="GarrisonCommander","GarrisonCommander-Broker"

if (me ==  gc and  not IsAddOnLoaded(gb) or
    me ==  gb and  not IsAddOnLoaded(gc)
) then
     GarrisonLandingPageMinimapButton:HookScript("OnEnter",
     function(this)
        if this.description==MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP or
           this.description == GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP then
          GameTooltip:AddLine(CTRL_KEY_TEXT .. " " .. MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP)
          GameTooltip:AddLine(SHIFT_KEY_TEXT  .. " " .. MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP)
        end
        GameTooltip:Show()
    end
    )
    GarrisonLandingPageMinimapButton:HookScript("OnClick",
      function (this,button)
         local shown=GarrisonLandingPage:IsShown()
         local actual=GarrisonLandingPage.garrTypeID
         local requested=C_Garrison.GetLandingPageGarrisonType()
         if IsShiftKeyDown() then
            requested=LE_GARRISON_TYPE_7_0
         elseif IsControlKeyDown() then
            requested=LE_GARRISON_TYPE_6_0
         end
         if InCombatLockdown() then return end
         if shown and actual ~= requested then
           ShowGarrisonLandingPage(requested);
         end
      end
    )
end
