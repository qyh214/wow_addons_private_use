local THROTTLE = 0.33

local BulkieDisplayFrame = CreateFrame('Frame', 'BulkieFrame', UIParent);
BulkieDisplayFrame:SetFrameStrata('DIALOG');
BulkieDisplayFrame:SetToplevel(true);
BulkieDisplayFrame:EnableMouse(true);
BulkieDisplayFrame:SetClampedToScreen(true);
BulkieDisplayFrame:SetWidth(340);
BulkieDisplayFrame:SetHeight(50);
BulkieDisplayFrame:SetBackdrop{
  bgFile='Interface\\DialogFrame\\UI-DialogBox-Background' ,
  edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',
  tile = true,
  insets = {left = 11, right = 12, top = 12, bottom = 11},
  tileSize = 32,
  edgeSize = 32,
}
BulkieDisplayFrame:SetPoint('TOPLEFT', 13, -532);
BulkieDisplayFrame:Hide();

-- create title
local title = BulkieDisplayFrame:CreateFontString (nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16);
title:SetText("Bulkie");
BulkieDisplayFrame.Title = title;

-- create button
local button = CreateFrame('Button', 'BulkieBulkButton', BulkieDisplayFrame, "OptionsButtonTemplate");
button:SetPoint("TOPRIGHT", -16, -16);
button:SetWidth(160);
button:SetHeight(22);
button:SetText("Queue To Max");
button:Show();

-- register events
BulkieDisplayFrame:RegisterEvent("SHIPMENT_CRAFTER_OPENED");
BulkieDisplayFrame:RegisterEvent("SHIPMENT_CRAFTER_CLOSED");
BulkieDisplayFrame:RegisterEvent("SHIPMENT_CRAFTER_INFO");

function BulkieDisplayFrame:SHIPMENT_CRAFTER_OPENED (containerID)
  BulkieDisplayFrame:Show()
  self:SetScript("OnUpdate", nil);
end

function BulkieDisplayFrame:SHIPMENT_CRAFTER_CLOSED ()
  BulkieDisplayFrame:Hide()
  self:SetScript("OnUpdate", nil);
end

function BulkieDisplayFrame:SHIPMENT_CRAFTER_INFO (success, _, maxShipments, plotID)
  self.maxShipments = maxShipments;
  if self.maxShipments == C_Garrison.GetNumPendingShipments() then
    button:Disable();
  else
    button:Enable();
  end
end

-- set the click handler
button:SetScript('OnClick', function(self)
  BulkieDisplayFrame.elapsed = 0
  BulkieDisplayFrame:SetScript("OnUpdate", function (self, elapsed)
    self.elapsed = self.elapsed + elapsed;
    if self.elapsed > THROTTLE then
      self.elapsed = 0;
      C_Garrison.RequestShipmentCreation();
      if self.maxShipments == C_Garrison.GetNumPendingShipments() then
        self:SetScript("OnUpdate", nil);
        button:Disable();
      end
    end
  end)
end)

-- set handlers for frame events
BulkieDisplayFrame:SetScript ("OnEvent", function (self, event, ...)
  if self[event] then
    self[event] (self, ...)
  end
end)
