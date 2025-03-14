local ADDON_NAME, ns = ...


function ns.SyncSingleScaleAlpha()
  local db = ns.Addon.db.profile

  -- General Scale/Alpha
  db.MiniMapGeneralScale = db.ZonesGeneralScale
  db.MiniMapGeneralAlpha = db.ZonesGeneralAlpha

  -- Sync function General with General Minimap
  db.activate.MiniMapGeneralSyncScaleAlpha = db.activate.ZoneGeneralSyncScaleAlpha

  -- Zone Scale
  db.MiniMapScaleMapNotesIcons = db.ZoneScaleMapNotesIcons
  db.MiniMapScaleInnkeeper = db.ZoneScaleInnkeeper
  db.MiniMapScaleAuctioneer = db.ZoneScaleAuctioneer
  db.MiniMapScaleBank = db.ZoneScaleBank
  db.MiniMapScaleBarber = db.ZoneScaleBarber
  db.MiniMapScaleMailbox = db.ZoneScaleMailbox
  db.MiniMapScalePvPVendor = db.ZoneScalePvPVendor
  db.MiniMapScalePvEVendor = db.ZoneScalePvEVendor
  db.MiniMapScaleStablemaster = db.ZoneScaleStablemaster
  db.MiniMapScaleCatalyst = db.ZoneScaleCatalyst
  db.MiniMapScaleZidormi = db.ZoneScaleZidormi
  db.MiniMapScaleTransmogger = db.ZoneScaleTransmogger
  db.MiniMapScaleItemUpgrade = db.ZoneScaleItemUpgrade
  db.MiniMapScalePaths = db.ZoneScalePaths
  -- Zone Alpha
  db.MiniMapAlphaMapNotesIcons = db.ZoneAlphaMapNotesIcons
  db.MiniMapAlphaInnkeeper = db.ZoneAlphaInnkeeper
  db.MiniMapAlphaAuctioneer = db.ZoneAlphaAuctioneer
  db.MiniMapAlphaBank = db.ZoneAlphaBank
  db.MiniMapAlphaBarber = db.ZoneAlphaBarber
  db.MiniMapAlphaMailbox = db.ZoneAlphaMailbox
  db.MiniMapAlphaPvPVendor = db.ZoneAlphaPvPVendor
  db.MiniMapAlphaPvEVendor = db.ZoneAlphaPvEVendor
  db.MiniMapAlphaStablemaster = db.ZoneAlphaStablemaster
  db.MiniMapAlphaCatalyst = db.ZoneAlphaCatalyst
  db.MiniMapAlphaZidormi = db.ZoneAlphaZidormi
  db.MiniMapAlphaTransmogger = db.ZoneAlphaTransmogger
  db.MiniMapAlphaItemUpgrade = db.ZoneAlphaItemUpgrade
  db.MiniMapAlphaPaths = db.ZoneAlphaPaths

  if db.activate.ZoneGeneralSyncScaleAlpha then
    -- Scale
    db.ZoneScaleMapNotesIcons = db.ZonesGeneralScale
    db.ZoneScaleInnkeeper = db.ZonesGeneralScale
    db.ZoneScaleAuctioneer = db.ZonesGeneralScale
    db.ZoneScaleBank = db.ZonesGeneralScale
    db.ZoneScaleBarber = db.ZonesGeneralScale
    db.ZoneScaleMailbox = db.ZonesGeneralScale
    db.ZoneScalePvPVendor = db.ZonesGeneralScale
    db.ZoneScalePvEVendor = db.ZonesGeneralScale
    db.ZoneScaleStablemaster = db.ZonesGeneralScale
    db.ZoneScaleCatalyst = db.ZonesGeneralScale
    db.ZoneScaleZidormi = db.ZonesGeneralScale
    db.ZoneScaleTransmogger = db.ZonesGeneralScale
    db.ZoneScaleItemUpgrade = db.ZonesGeneralScale
    db.ZoneScalePaths = db.ZonesGeneralScale
    -- Alpha
    db.ZoneAlphaMapNotesIcons = db.ZonesGeneralAlpha
    db.ZoneAlphaInnkeeper = db.ZonesGeneralAlpha
    db.ZoneAlphaAuctioneer = db.ZonesGeneralAlpha
    db.ZoneAlphaBank = db.ZonesGeneralAlpha
    db.ZoneAlphaBarber = db.ZonesGeneralAlpha
    db.ZoneAlphaMailbox = db.ZonesGeneralAlpha
    db.ZoneAlphaPvPVendor = db.ZonesGeneralAlpha
    db.ZoneAlphaPvEVendor = db.ZonesGeneralAlpha
    db.ZoneAlphaStablemaster = db.ZonesGeneralAlpha
    db.ZoneAlphaCatalyst = db.ZonesGeneralAlpha
    db.ZoneAlphaZidormi = db.ZonesGeneralAlpha
    db.ZoneAlphaTransmogger = db.ZonesGeneralAlpha
    db.ZoneAlphaItemUpgrade = db.ZonesGeneralAlpha
    db.ZoneAlphaPaths = db.ZonesGeneralAlpha
  end

  if db.activate.MiniMapGeneralSyncScaleAlpha then
      -- Scale
      db.MiniMapScaleMapNotesIcons = db.MiniMapGeneralScale
      db.MiniMapScaleInnkeeper = db.MiniMapGeneralScale
      db.MiniMapScaleAuctioneer = db.MiniMapGeneralScale
      db.MiniMapScaleBank = db.MiniMapGeneralScale
      db.MiniMapScaleBarber = db.MiniMapGeneralScale
      db.MiniMapScaleMailbox = db.MiniMapGeneralScale
      db.MiniMapScalePvPVendor = db.MiniMapGeneralScale
      db.MiniMapScalePvEVendor = db.MiniMapGeneralScale
      db.MiniMapScaleStablemaster = db.MiniMapGeneralScale
      db.MiniMapScaleCatalyst = db.MiniMapGeneralScale
      db.MiniMapScaleZidormi = db.MiniMapGeneralScale
      db.MiniMapScaleTransmogger = db.MiniMapGeneralScale
      db.MiniMapScaleItemUpgrade = db.MiniMapGeneralScale
      db.MiniMapScalePaths = db.MiniMapGeneralScale
      -- Alpha
      db.MiniMapAlphaMapNotesIcons = db.MiniMapGeneralAlpha
      db.MiniMapAlphaInnkeeper = db.MiniMapGeneralAlpha
      db.MiniMapAlphaAuctioneer = db.MiniMapGeneralAlpha
      db.MiniMapAlphaBank = db.MiniMapGeneralAlpha
      db.MiniMapAlphaBarber = db.MiniMapGeneralAlpha
      db.MiniMapAlphaMailbox = db.MiniMapGeneralAlpha
      db.MiniMapAlphaPvPVendor = db.MiniMapGeneralAlpha
      db.MiniMapAlphaPvEVendor = db.MiniMapGeneralAlpha
      db.MiniMapAlphaStablemaster = db.MiniMapGeneralAlpha
      db.MiniMapAlphaCatalyst = db.MiniMapGeneralAlpha
      db.MiniMapAlphaZidormi = db.MiniMapGeneralAlpha
      db.MiniMapAlphaTransmogger = db.MiniMapGeneralAlpha
      db.MiniMapAlphaItemUpgrade = db.MiniMapGeneralAlpha
      db.MiniMapAlphaPaths = db.MiniMapGeneralAlpha
  end
end

