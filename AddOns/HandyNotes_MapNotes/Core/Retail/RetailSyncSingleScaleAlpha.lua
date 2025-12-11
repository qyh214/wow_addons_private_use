local ADDON_NAME, ns = ...


function ns.SyncSingleScaleAlpha()
  local db = ns.Addon.db.profile

  if db.activate.SyncZoneAndMinimap then

    -- Sync function General with General Minimap
    db.activate.MiniMapInstanceSyncScaleAlpha = db.activate.ZoneInstanceSyncScaleAlpha -- Transport
    db.activate.MiniMapTransportSyncScaleAlpha = db.activate.ZoneTransportSyncScaleAlpha -- Transport
    db.activate.MiniMapGeneralSyncScaleAlpha = db.activate.ZoneGeneralSyncScaleAlpha -- General

    -- Instance Minimap to Zone single Scale
    db.MiniMapScaleRaids = db.ZoneScaleRaids
    db.MiniMapScaleDungeons = db.ZoneScaleDungeons
    db.MiniMapScalePassage = db.ZoneScalePassage
    db.MiniMapScaleMultiple = db.ZoneScaleMultiple
    db.MiniMapScaleOldVanilla = db.ZoneScaleOldVanilla
    db.MiniMapScaleLFR = db.ZoneScaleLFR
    db.MiniMapScalePetBattleDungeons = db.ZoneScalePetBattleDungeons
    -- Instance Minimap to Zone single Alpha
    db.MiniMapAlphaRaids = db.ZoneAlphaRaids
    db.MiniMapAlphaDungeons = db.ZoneAlphaDungeons
    db.MiniMapAlphaPassage = db.ZoneAlphaPassage
    db.MiniMapAlphaMultiple = db.ZoneAlphaMultiple
    db.MiniMapAlphaOldVanilla = db.ZoneAlphaOldVanilla
    db.MiniMapAlphaLFR = db.ZoneAlphaLFR
    db.MiniMapAlphaPetBattleDungeons = db.ZoneAlphaPetBattleDungeons

    -- Transport Minimap to Zone single Scale
    db.MiniMapScalePortals = db.ZoneScalePortals
    db.MiniMapScaleZeppelins = db.ZoneScaleZeppelins
    db.MiniMapScaleShips = db.ZoneScaleShips
    db.MiniMapScaleTransport = db.ZoneScaleTransport
    db.MiniMapScaleOgreWaygate = db.ZoneScaleOgreWaygate
    db.MiniMapScaleTeleporter = db.ZoneScaleTeleporter
    db.MiniMapScaleMirror = db.ZoneScaleMirror
    db.MiniMapScaleTravel = db.ZoneScaleTravel
    db.MiniMapScaleDarkmoon = db.ZoneScaleDarkmoon
    db.MiniMapScaleRaces = db.ZoneScaleRaces
    -- Transport Minimap to Zone single Alpha
    db.MiniMapAlphaPortals = db.ZoneAlphaPortals
    db.MiniMapAlphaZeppelins = db.ZoneAlphaZeppelins
    db.MiniMapAlphaShips = db.ZoneAlphaShips
    db.MiniMapAlphaTransport = db.ZoneAlphaTransport
    db.MiniMapAlphaOgreWaygate = db.ZoneAlphaOgreWaygate
    db.MiniMapAlphaTeleporter = db.ZoneAlphaTeleporter
    db.MiniMapAlphaMirror = db.ZoneAlphaMirror
    db.MiniMapAlphaTravel = db.ZoneAlphaTravel
    db.MiniMapAlphaDarkmoon = db.ZoneAlphaDarkmoon
    db.MiniMapAlphaRaces = db.ZoneAlphaRaces

    -- General Minimap to Zone single Scale
    db.MiniMapScaleInnkeeper = db.ZoneScaleInnkeeper
    db.MiniMapScaleAuctioneer = db.ZoneScaleAuctioneer
    db.MiniMapScaleBank = db.ZoneScaleBank
    db.MiniMapScaleBarber = db.ZoneScaleBarber
    db.MiniMapScaleMailbox = db.ZoneScaleMailbox
    db.MiniMapScalePvPVendor = db.ZoneScalePvPVendor
    db.MiniMapScalePvEVendor = db.ZoneScalePvEVendor
    db.MiniMapScaleRenownQuartermaster = db.ZoneScaleRenownQuartermaster
    db.MiniMapScaleStablemaster = db.ZoneScaleStablemaster
    db.MiniMapScaleCatalyst = db.ZoneScaleCatalyst
    db.MiniMapScaleZidormi = db.ZoneScaleZidormi
    db.MiniMapScaleTransmogger = db.ZoneScaleTransmogger
    db.MiniMapScaleItemUpgrade = db.ZoneScaleItemUpgrade
    db.MiniMapScalePaths = db.ZoneScalePaths
    -- General Minimap to Zone single Alpha
    db.MiniMapAlphaInnkeeper = db.ZoneAlphaInnkeeper
    db.MiniMapAlphaAuctioneer = db.ZoneAlphaAuctioneer
    db.MiniMapAlphaBank = db.ZoneAlphaBank
    db.MiniMapAlphaBarber = db.ZoneAlphaBarber
    db.MiniMapAlphaMailbox = db.ZoneAlphaMailbox
    db.MiniMapAlphaPvPVendor = db.ZoneAlphaPvPVendor
    db.MiniMapAlphaPvEVendor = db.ZoneAlphaPvEVendor
    db.MiniMapAlphaRenownQuartermaster = db.ZoneAlphaRenownQuartermaster
    db.MiniMapAlphaStablemaster = db.ZoneAlphaStablemaster
    db.MiniMapAlphaCatalyst = db.ZoneAlphaCatalyst
    db.MiniMapAlphaZidormi = db.ZoneAlphaZidormi
    db.MiniMapAlphaTransmogger = db.ZoneAlphaTransmogger
    db.MiniMapAlphaItemUpgrade = db.ZoneAlphaItemUpgrade
    db.MiniMapAlphaPaths = db.ZoneAlphaPaths

  end

  -- Zone Instance
  if db.activate.ZoneInstanceSyncScaleAlpha then

    -- Scale
    db.ZoneScaleRaids = db.ZoneInstanceScale
    db.ZoneScaleDungeons = db.ZoneInstanceScale
    db.ZoneScalePassage = db.ZoneInstanceScale
    db.ZoneScaleMultiple = db.ZoneInstanceScale
    db.ZoneScaleOldVanilla = db.ZoneInstanceScale
    db.ZoneScaleLFR = db.ZoneInstanceScale
    db.ZoneScalePetBattleDungeons = db.ZoneInstanceScale
    -- Alpha
    db.ZoneAlphaRaids = db.ZoneInstanceAlpha
    db.ZoneAlphaDungeons = db.ZoneInstanceAlpha
    db.ZoneAlphaPassage = db.ZoneInstanceAlpha
    db.ZoneAlphaMultiple = db.ZoneInstanceAlpha
    db.ZoneAlphaOldVanilla = db.ZoneInstanceAlpha
    db.ZoneAlphaLFR = db.ZoneInstanceAlpha
    db.ZoneAlphaPetBattleDungeons = db.ZoneInstanceAlpha

  end

  -- Zone Transport
  if db.activate.ZoneTransportSyncScaleAlpha then

    -- Scale
    db.ZoneScalePortals = db.ZoneTransportScale
    db.ZoneScaleZeppelins = db.ZoneTransportScale
    db.ZoneScaleShips = db.ZoneTransportScale
    db.ZoneScaleTransport = db.ZoneTransportScale
    db.ZoneScaleOgreWaygate = db.ZoneTransportScale
    db.ZoneScaleTeleporter = db.ZoneTransportScale
    db.ZoneScaleMirror = db.ZoneTransportScale
    db.ZoneScaleTravel = db.ZoneTransportScale
    db.ZoneScaleDarkmoon = db.ZoneTransportScale
    db.ZoneScaleRaces = db.ZoneTransportScale
    -- Alpha
    db.ZoneAlphaPortals = db.ZoneTransportAlpha
    db.ZoneAlphaZeppelins = db.ZoneTransportAlpha
    db.ZoneAlphaShips = db.ZoneTransportAlpha
    db.ZoneAlphaTransport = db.ZoneTransportAlpha
    db.ZoneAlphaOgreWaygate = db.ZoneTransportAlpha
    db.ZoneAlphaTeleporter = db.ZoneTransportAlpha
    db.ZoneAlphaMirror = db.ZoneTransportAlpha
    db.ZoneAlphaTravel = db.ZoneTransportAlpha
    db.ZoneAlphaDarkmoon = db.ZoneTransportAlpha
    db.ZoneAlphaRaces = db.ZoneTransportAlpha

  end

  -- Zone General
  if db.activate.ZoneGeneralSyncScaleAlpha then

    -- Scale
    db.ZoneScaleMapNotesIcons = db.ZoneGeneralScale
    db.ZoneScaleHordeAllyIcons = db.ZoneGeneralScale
    db.ZoneScaleInnkeeper = db.ZoneGeneralScale
    db.ZoneScaleAuctioneer = db.ZoneGeneralScale
    db.ZoneScaleBank = db.ZoneGeneralScale
    db.ZoneScaleBarber = db.ZoneGeneralScale
    db.ZoneScaleMailbox = db.ZoneGeneralScale
    db.ZoneScalePvPVendor = db.ZoneGeneralScale
    db.ZoneScalePvEVendor = db.ZoneGeneralScale
    db.ZoneScaleRenownQuartermaster = db.ZoneGeneralScale
    db.ZoneScaleStablemaster = db.ZoneGeneralScale
    db.ZoneScaleCatalyst = db.ZoneGeneralScale
    db.ZoneScaleZidormi = db.ZoneGeneralScale
    db.ZoneScaleTransmogger = db.ZoneGeneralScale
    db.ZoneScaleItemUpgrade = db.ZoneGeneralScale
    db.ZoneScalePaths = db.ZoneGeneralScale
    -- Alpha
    db.ZoneAlphaMapNotesIcons = db.ZoneGeneralAlpha
    db.ZoneAlphaHordeAllyIcons = db.ZoneGeneralAlpha
    db.ZoneAlphaInnkeeper = db.ZoneGeneralAlpha
    db.ZoneAlphaAuctioneer = db.ZoneGeneralAlpha
    db.ZoneAlphaBank = db.ZoneGeneralAlpha
    db.ZoneAlphaBarber = db.ZoneGeneralAlpha
    db.ZoneAlphaMailbox = db.ZoneGeneralAlpha
    db.ZoneAlphaPvPVendor = db.ZoneGeneralAlpha
    db.ZoneAlphaPvEVendor = db.ZoneGeneralAlpha
    db.ZoneAlphaRenownQuartermaster = db.ZoneGeneralAlpha
    db.ZoneAlphaStablemaster = db.ZoneGeneralAlpha
    db.ZoneAlphaCatalyst = db.ZoneGeneralAlpha
    db.ZoneAlphaZidormi = db.ZoneGeneralAlpha
    db.ZoneAlphaTransmogger = db.ZoneGeneralAlpha
    db.ZoneAlphaItemUpgrade = db.ZoneGeneralAlpha
    db.ZoneAlphaPaths = db.ZoneGeneralAlpha

  end

  -- DungeonMap
  if db.activate.DungeonMapSyncScaleAlpha then
 
    -- Scale
    db.DungeonMapScaleExit = db.dungeonScale
    db.DungeonMapScalePortal = db.dungeonScale
    db.DungeonMapScalePassage = db.dungeonScale
    db.DungeonMapScaleTransport = db.dungeonScale
    db.DungeonMapScaleVendor = db.dungeonScale
    -- Alpha
    db.DungeonMapAlphaExit = db.dungeonAlpha
    db.DungeonMapAlphaPortal = db.dungeonAlpha
    db.DungeonMapAlphaPassage = db.dungeonAlpha
    db.DungeonMapAlphaTransport = db.dungeonAlpha
    db.DungeonMapAlphaVendor = db.dungeonAlpha

  end

  -- MiniMap Instance
  if db.activate.MiniMapInstanceSyncScaleAlpha then

    -- Scale
    db.MiniMapScaleRaids = db.MiniMapInstanceScale
    db.MiniMapScaleDungeons = db.MiniMapInstanceScale
    db.MiniMapScalePassage = db.MiniMapInstanceScale
    db.MiniMapScaleMultiple = db.MiniMapInstanceScale
    db.MiniMapScaleOldVanilla = db.MiniMapInstanceScale
    db.MiniMapScaleLFR = db.MiniMapInstanceScale
    db.MiniMapScalePetBattleDungeon = db.MiniMapInstanceScale
    -- Alpha
    db.MiniMapAlphaRaids = db.MiniMapInstanceAlpha
    db.MiniMapAlphaDungeons = db.MiniMapInstanceAlpha
    db.MiniMapAlphaPassage = db.MiniMapInstanceAlpha
    db.MiniMapAlphaMultiple = db.MiniMapInstanceAlpha
    db.MiniMapAlphaOldVanilla = db.MiniMapInstanceAlpha
    db.MiniMapAlphaLFR = db.MiniMapInstanceAlpha
    db.MiniMapAlphaPetBattleDungeon = db.MiniMapInstanceAlpha
  end

  -- Minimap Transport
  if db.activate.MiniMapTransportSyncScaleAlpha then

    -- Scale
    db.MiniMapScalePortals = db.MiniMapTransportScale
    db.MiniMapScaleZeppelins = db.MiniMapTransportScale
    db.MiniMapScaleShips = db.MiniMapTransportScale
    db.MiniMapScaleTransport = db.MiniMapTransportScale
    db.MiniMapScaleOgreWaygate = db.MiniMapTransportScale
    db.MiniMapScaleTeleporter = db.MiniMapTransportScale
    db.MiniMapScaleMirror = db.MiniMapTransportScale
    db.MiniMapScaleTravel = db.MiniMapTransportScale
    db.MiniMapScaleDarkmoon = db.MiniMapTransportScale
    db.MiniMapScaleRaces = db.MiniMapTransportScale
    -- Alpha
    db.MiniMapAlphaPortals = db.MiniMapTransportAlpha
    db.MiniMapAlphaZeppelins = db.MiniMapTransportAlpha
    db.MiniMapAlphaShips = db.MiniMapTransportAlpha
    db.MiniMapAlphaTransport = db.MiniMapTransportAlpha
    db.MiniMapAlphaOgreWaygate = db.MiniMapTransportAlpha
    db.MiniMapAlphaTeleporter = db.MiniMapTransportAlpha
    db.MiniMapAlphaMirror = db.MiniMapTransportAlpha
    db.MiniMapAlphaTravel = db.MiniMapTransportAlpha
    db.MiniMapAlphaDarkmoon = db.MiniMapTransportAlpha
    db.MiniMapAlphaRaces = db.MiniMapTransportAlpha

  end

  -- Minimap General
  if db.activate.MiniMapGeneralSyncScaleAlpha then

    -- Scale
    db.MiniMapScaleMapNotesIcons = db.MiniMapGeneralScale
    db.MiniMapScaleHordeAllyIcons = db.MiniMapGeneralScale
    db.MiniMapScaleInnkeeper = db.MiniMapGeneralScale
    db.MiniMapScaleAuctioneer = db.MiniMapGeneralScale
    db.MiniMapScaleBank = db.MiniMapGeneralScale
    db.MiniMapScaleBarber = db.MiniMapGeneralScale
    db.MiniMapScaleMailbox = db.MiniMapGeneralScale
    db.MiniMapScalePvPVendor = db.MiniMapGeneralScale
    db.MiniMapScalePvEVendor = db.MiniMapGeneralScale
    db.MiniMapScaleRenownQuartermaster = db.MiniMapGeneralScale
    db.MiniMapScaleStablemaster = db.MiniMapGeneralScale
    db.MiniMapScaleCatalyst = db.MiniMapGeneralScale
    db.MiniMapScaleZidormi = db.MiniMapGeneralScale
    db.MiniMapScaleTransmogger = db.MiniMapGeneralScale
    db.MiniMapScaleItemUpgrade = db.MiniMapGeneralScale
    db.MiniMapScalePaths = db.MiniMapGeneralScale
    -- Alpha
    db.MiniMapAlphaMapNotesIcons = db.MiniMapGeneralAlpha
    db.MiniMapAlphaHordeAllyIcons = db.MiniMapGeneralAlpha
    db.MiniMapAlphaInnkeeper = db.MiniMapGeneralAlpha
    db.MiniMapAlphaAuctioneer = db.MiniMapGeneralAlpha
    db.MiniMapAlphaBank = db.MiniMapGeneralAlpha
    db.MiniMapAlphaBarber = db.MiniMapGeneralAlpha
    db.MiniMapAlphaMailbox = db.MiniMapGeneralAlpha
    db.MiniMapAlphaPvPVendor = db.MiniMapGeneralAlpha
    db.MiniMapAlphaPvEVendor = db.MiniMapGeneralAlpha
    db.MiniMapAlphaRenownQuartermaster = db.MiniMapGeneralAlpha
    db.MiniMapAlphaStablemaster = db.MiniMapGeneralAlpha
    db.MiniMapAlphaCatalyst = db.MiniMapGeneralAlpha
    db.MiniMapAlphaZidormi = db.MiniMapGeneralAlpha
    db.MiniMapAlphaTransmogger = db.MiniMapGeneralAlpha
    db.MiniMapAlphaItemUpgrade = db.MiniMapGeneralAlpha
    db.MiniMapAlphaPaths = db.MiniMapGeneralAlpha

  end

end

