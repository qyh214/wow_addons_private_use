-- file generated automatically
local loadedFrame = CreateFrame("FRAME")
loadedFrame:RegisterEvent("ADDON_LOADED")
loadedFrame:SetScript("OnEvent", function(_, _, addonName)
  if addonName == "WeakAurasCompanion" then
    if WeakAuras and WeakAuras.AddCompanionData and WeakAurasCompanionWagoData then
      WeakAuras.AddCompanionData(WeakAurasCompanionWagoData)
      local count = WeakAuras.CountWagoUpdates()
      if count and count > 0 then
        WeakAuras.prettyPrint(WeakAuras.L["There are %i updates to your auras ready to be installed!"]:format(count))
      end
    end

    if Plater and Plater.CheckWagoUpdates then
      Plater.CheckWagoUpdates()
    end
  end
end)
