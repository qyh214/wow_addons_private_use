--[[---- Addon Bridge ----
#   Addon Name      Functionality
1   Pawn            (show item value in NarciTooltip)
2   AzeriteUI       (Special minimap button. Show actionbars when dragging an equipment)

--]]

---- Pawn ----
local PawnTooltipLineNum = 1;
local PawnTooltipText = "";


---- Hook Function ----
local Bridge = CreateFrame("Frame", "AddonBridge");
Bridge:RegisterEvent("VARIABLES_LOADED");
Bridge:SetScript("OnEvent",function(self,event,...)
    local _, isFinished = IsAddOnLoaded("Pawn")
    if isFinished and RefVirtualTooltip then
        hooksecurefunc(RefVirtualTooltip, "SetHyperlink", function(self, ...)
            PawnUpdateTooltip("RefVirtualTooltip", "SetHyperlink", ...)
            PawnTooltipLineNum = 1;
            PawnTooltipText = "";
        end)
        hooksecurefunc("PawnAddTooltipLine", function(Tooltip, Text, r, g, b)
            if Tooltip:GetName() ~= "RefVirtualTooltip" then
                PawnTooltipText = ""
                return;
            end
            PawnTooltipLineNum = PawnTooltipLineNum + 1;
            if not Text then
                NarciTooltip.PawnText:SetText("")
                NarciTooltip.PawnText:Hide()
                NarciTooltip_Resize()
                return;
            end

            if PawnTooltipText then
                PawnTooltipText = PawnTooltipText.."\n"..Text
            else
                PawnTooltipText = Text
            end

            NarciTooltip.PawnText:SetText(PawnTooltipText)
            NarciTooltip.PawnText:Show()
            NarciTooltip_Resize()
        end)
    end
end)

---- Action Bar Animation ----
--local AnimatedParent = CreateFrame("Frame", "AddonBridge");
local sin = math.sin;
local pi = math.pi;
local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

local duration_Translation = 0.8;

function Narci_SharedAnimatedParent_AnimFrame_OnUpdate(self, elapsed)
	local duration = 0.8;
	local offSet, alpha;
	local t = self.TimeSinceLastUpdate;
    local frame = self:GetParent();
    
    offSet = outSine(t, self.StartPointY, self.EndPointY - self.StartPointY , duration)
    --print(offSet)
    alpha = outSine(t, self.StartAlpha, self.EndAlpha - self.StartAlpha, duration)
	frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, 0, offSet);
    frame:SetAlpha(alpha)
	if t >= duration then
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, 0, self.EndPointY);
		if not self.OppoDirection then
			frame:SetAlpha(1)
			frame:Show()
		else
			frame:SetAlpha(0)
			--frame:Hide()
		end

		self:Hide()
		return;
	end
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    --print(self.TimeSinceLastUpdate)
end