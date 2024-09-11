local ADDON_NAME, ns = ...

function ns.SyncWithMinimapScaleAlpha()
local db = ns.Addon.db.profile

    if db.activate.SyncCapitalsAndMinimap then 
        -- Instance Scale/Alpha
        db.MinimapCapitalsInstanceScale = db.CapitalsInstanceScale
        db.MinimapCapitalsInstanceAlpha = db.CapitalsInstanceAlpha
        -- Transport Scale/Alpha
        db.MinimapCapitalsTransportScale = db.CapitalsTransportScale
        db.MinimapCapitalsTransportAlpha = db.CapitalsTransportAlpha
        -- Professions Scale/Alpha
        db.MinimapCapitalsProfessionsScale = db.CapitalsProfessionsScale
        db.MinimapCapitalsProfessionsAlpha = db.CapitalsProfessionsAlpha
        --General Scale/Alpha
        db.MinimapCapitalsGeneralScale = db.CapitalsGeneralScale
        db.MinimapCapitalsGeneralAlpha = db.CapitalsGeneralAlpha
    end

    if db.activate.SyncZoneAndMinimap then
        -- General Scale/Alpha
        db.minimapScale = db.zoneScale  -- old sync, but atm needed for Classic+
        db.minimapAlpha = db.zoneAlpha  -- old sync, but atm needed for Classic+
        -- Instance Scale/Alpha
        db.instanceMiniMapScale = db.instanceScale  -- old sync, but atm needed for Classic+
        db.instanceMiniMapAlpha = db.instanceAlpha  -- old sync, but atm needed for Classic+
        -- Instance Scale/Alpha
        db.MiniMapInstanceScale = db.ZoneInstanceScale
        db.MiniMapInstanceAlpha = db.ZoneInstanceAlpha
        -- Transport Scale/Alpha
        db.MiniMapTransportScale = db.ZoneTransportScale
        db.MiniMapTransportAlpha = db.ZoneTransportAlpha
        -- General Scale/Alpha
        db.MiniMapGeneralScale = db.ZonesGeneralScale
        db.MiniMapGeneralAlpha = db.ZonesGeneralAlpha
        -- General Scale/Alpha
        db.MiniMapPathsScale = db.ZonesPathsScale
        db.MiniMapPathsAlpha = db.ZonesPathsAlpha
    end

end

function ns.SyncWithMinimap(self)
local db = ns.Addon.db.profile

    if db.activate.SyncCapitalsAndMinimap then 
        -- Capitals EnemyFaction
        db.activate.MinimapCapitalsEnemyFaction = db.activate.CapitalsEnemyFaction
        -- Capitals Tabs
        db.activate.MinimapCapitals = db.activate.Capitals
        db.activate.MinimapCapitalsInstances = db.activate.CapitalsInstances
        db.activate.MinimapCapitalsTransporting = db.activate.CapitalsTransporting
        db.activate.MinimapCapitalsProfessions = db.activate.CapitalsProfessions
        db.activate.MinimapCapitalsGeneral = db.activate.CapitalsGeneral
        -- Capitals Capitals
        self.db.profile.showMinimapCapitalsOrgrimmar = self.db.profile.showCapitalsOrgrimmar
        self.db.profile.showMinimapCapitalsThunderBluff = self.db.profile.showCapitalsThunderBluff
        self.db.profile.showMinimapCapitalsSilvermoon = self.db.profile.showCapitalsSilvermoon
        self.db.profile.showMinimapCapitalsUndercity = self.db.profile.showCapitalsUndercity
        self.db.profile.showMinimapCapitalsStormwind = self.db.profile.showCapitalsStormwind
        self.db.profile.showMinimapCapitalsIronforge = self.db.profile.showCapitalsIronforge
        self.db.profile.showMinimapCapitalsDarnassus = self.db.profile.showCapitalsDarnassus
        self.db.profile.showMinimapCapitalsExodar = self.db.profile.showCapitalsExodar
        self.db.profile.showMinimapCapitalsShattrath = self.db.profile.showCapitalsShattrath
        self.db.profile.showMinimapCapitalsDalaranNorthrend = self.db.profile.showCapitalsDalaranNorthrend
        self.db.profile.showMinimapCapitalsDalaranLegion = self.db.profile.showCapitalsDalaranLegion
        self.db.profile.showMinimapCapitalsSot2M = self.db.profile.showCapitalsSot2M
        self.db.profile.showMinimapCapitalsSot7S = self.db.profile.showCapitalsSot7S
        self.db.profile.showMinimapCapitalsStormshield = self.db.profile.showCapitalsStormshield
        self.db.profile.showMinimapCapitalsWarspear = self.db.profile.showCapitalsWarspear
        self.db.profile.showMinimapCapitalsDazarAlor = self.db.profile.showCapitalsDazarAlor
        self.db.profile.showMinimapCapitalsBoralus = self.db.profile.showCapitalsBoralus
        self.db.profile.showMinimapCapitalsOribos = self.db.profile.showCapitalsOribos
        self.db.profile.showMinimapCapitalsValdrakken = self.db.profile.showCapitalsValdrakken
        self.db.profile.showMinimapCapitalsDornogal = self.db.profile.showCapitalsDornogal
        self.db.profile.showMinimapCapitalsDarkmoon = self.db.profile.showCapitalsDarkmoon
        -- Capitals Instances
        self.db.profile.showMinimapCapitalsRaids = self.db.profile.showCapitalsRaids
        self.db.profile.showMinimapCapitalsDungeons = self.db.profile.showCapitalsDungeons
        self.db.profile.showMinimapCapitalsInstancePassage = self.db.profile.showCapitalsInstancePassage
        self.db.profile.showMinimapCapitalsMultiple = self.db.profile.showCapitalsMultiple
        -- Capitals Transport
        self.db.profile.showMinimapCapitalsPortals = self.db.profile.showCapitalsPortals
        self.db.profile.showMinimapCapitalsZeppelins = self.db.profile.showCapitalsZeppelins
        self.db.profile.showMinimapCapitalsShips = self.db.profile.showCapitalsShips
        self.db.profile.showMinimapCapitalsTransport = self.db.profile.showCapitalsTransport
        self.db.profile.showMinimapCapitalsOldVanilla = self.db.profile.showCapitalsOldVanilla
        self.db.profile.showMinimapCapitalsLFR = self.db.profile.showCapitalsLFR
        self.db.profile.showMinimapCapitalsFP = self.db.profile.showCapitalsFP
        -- Capitals Professions    
        self.db.profile.activate.MinimapCapitalsProfessions = self.db.profile.activate.CapitalsProfessions
        self.db.profile.showMinimapCapitalsProfessionOrders = self.db.profile.showCapitalsProfessionOrders
        self.db.profile.showMinimapCapitalsAlchemy = self.db.profile.showCapitalsAlchemy
        self.db.profile.showMinimapCapitalsLeatherworking = self.db.profile.showCapitalsLeatherworking
        self.db.profile.showMinimapCapitalsEngineer = self.db.profile.showCapitalsEngineer
        self.db.profile.showMinimapCapitalsSkinning = self.db.profile.showCapitalsSkinning
        self.db.profile.showMinimapCapitalsTailoring = self.db.profile.showCapitalsTailoring
        self.db.profile.showMinimapCapitalsCooking = self.db.profile.showCapitalsCooking
        self.db.profile.showMinimapCapitalsFishing = self.db.profile.showCapitalsFishing
        self.db.profile.showMinimapCapitalsArchaeology = self.db.profile.showCapitalsArchaeology
        self.db.profile.showMinimapCapitalsMining =self.db.profile.showCapitalsMining
        self.db.profile.showMinimapCapitalsJewelcrafting = self.db.profile.showCapitalsJewelcrafting
        self.db.profile.showMinimapCapitalsBlacksmith = self.db.profile.showCapitalsBlacksmith
        self.db.profile.showMinimapCapitalsLeatherworking = self.db.profile.showCapitalsLeatherworking
        self.db.profile.showMinimapCapitalsHerbalism = self.db.profile.showCapitalsHerbalism
        self.db.profile.showMinimapCapitalsInscription = self.db.profile.showCapitalsInscription
        self.db.profile.showMinimapCapitalsEnchanting = self.db.profile.showCapitalsEnchanting
        -- Capital General
        self.db.profile.showMinimapCapitalsMapNotes = self.db.profile.showCapitalsMapNotes
        self.db.profile.showMinimapCapitalsInnkeeper = self.db.profile.showCapitalsInnkeeper
        self.db.profile.showMinimapCapitalsAuctioneer = self.db.profile.showCapitalsAuctioneer
        self.db.profile.showMinimapCapitalsPaths = self.db.profile.showCapitalsPaths
        self.db.profile.showMinimapCapitalsBank = self.db.profile.showCapitalsBank
        self.db.profile.showMinimapCapitalsBarber = self.db.profile.showCapitalsBarber
        self.db.profile.showMinimapCapitalsTransmogger = self.db.profile.showCapitalsTransmogger
        self.db.profile.showMinimapCapitalsPvPVendor = self.db.profile.showCapitalsPvPVendor
        self.db.profile.showMinimapCapitalsPvEVendor = self.db.profile.showCapitalsPvEVendor
        self.db.profile.showMinimapCapitalsItemUpgrade = self.db.profile.showCapitalsItemUpgrade
        self.db.profile.showMinimapCapitalsDragonFlyTransmog = self.db.profile.showCapitalsDragonFlyTransmog
        self.db.profile.showMinimapCapitalsCatalyst = self.db.profile.showCapitalsCatalyst
        self.db.profile.showMinimapCapitalsStablemaster = self.db.profile.showCapitalsStablemaster
        self.db.profile.showMinimapCapitalsTradingPost = self.db.profile.showCapitalsTradingPost
    end

    if db.activate.SyncZoneAndMinimap then
        -- Zone EnemyFaction
        db.activate.MiniMapEnemyFaction = db.activate.ZoneEnemyFaction
        -- Tabs
        db.activate.MiniMap = db.activate.ZoneMap
        db.activate.MiniMapInstances = db.activate.ZoneInstances
        db.activate.MiniMapTransporting = db.activate.ZoneTransporting
        db.activate.MiniMapGeneral = db.activate.ZoneGeneral
        db.activate.MiniMapPaths = db.activate.ZonePaths
        -- Icons
        self.db.profile.showMiniMapRaids = self.db.profile.showZoneRaids
        self.db.profile.showMiniMapDungeons = self.db.profile.showZoneDungeons
        self.db.profile.showMiniMapPassage = self.db.profile.showZonePassage
        self.db.profile.showMiniMapMultiple = self.db.profile.showZoneMultiple
        self.db.profile.showMiniMapPortals = self.db.profile.showZonePortals
        self.db.profile.showMiniMapZeppelins = self.db.profile.showZoneZeppelins
        self.db.profile.showMiniMapShips = self.db.profile.showZoneShips
        self.db.profile.showMiniMapTransport = self.db.profile.showZoneTransport
        self.db.profile.showMiniMapOgreWaygate = self.db.profile.showZoneOgreWaygate
        self.db.profile.showMiniMapTeleporter = self.db.profile.showZoneTeleporter
        self.db.profile.showMiniMapToyTransport = self.db.profile.showZoneToyTransport
        self.db.profile.showMiniMapTravel = self.db.profile.showZoneTravel
        self.db.profile.showMiniMapOldVanilla = self.db.profile.showZoneOldVanilla
        self.db.profile.showMiniMapLFR = self.db.profile.showZoneLFR
        self.db.profile.showMiniMapFP = self.db.profile.showZoneFP
        self.db.profile.showMiniMapGhost = self.db.profile.showZoneGhost
        self.db.profile.showMiniMapPaths = self.db.profile.showZonePaths
        self.db.profile.showMiniMapStablemaster = self.db.profile.showZoneStablemaster
        self.db.profile.showMiniMapInnkeeper = self.db.profile.showZoneInnkeeper
        self.db.profile.showMiniMapAuctioneer = self.db.profile.showZoneAuctioneer
        self.db.profile.showMiniMapBank = self.db.profile.showZoneBank
        self.db.profile.showMiniMapBarber = self.db.profile.showZoneBarber
        self.db.profile.showMiniMapMailbox = self.db.profile.showZoneMailbox
        self.db.profile.showMiniMapPvPVendor = self.db.profile.showZonePvPVendor
        self.db.profile.showMiniMapPvEVendor = self.db.profile.showZonePvEVendor
        self.db.profile.showMiniMapTransmogger = self.db.profile.showZoneTransmogger
        self.db.profile.showMiniMapItemUpgrade = self.db.profile.showZoneItemUpgrade
        self.db.profile.showMiniMapCatalyst = self.db.profile.showZoneCatalyst

        -- Zones
        self.db.profile.showMiniMapKalimdor = self.db.profile.showZoneKalimdor
        self.db.profile.showMiniMapEasternKingdom = self.db.profile.showZoneEasternKingdom
        self.db.profile.showMiniMapOutland = self.db.profile.showZoneOutland
        self.db.profile.showMiniMapNorthrend = self.db.profile.showZoneNorthrend
        self.db.profile.showMiniMapPandaria = self.db.profile.showZonePandaria
        self.db.profile.showMiniMapDraenor = self.db.profile.showZoneDraenor
        self.db.profile.showMiniMapBrokenIsles = self.db.profile.showZoneBrokenIsles
        self.db.profile.showMiniMapZandalar = self.db.profile.showZoneZandalar
        self.db.profile.showMiniMapKulTiras = self.db.profile.showZoneKulTiras
        self.db.profile.showMiniMapShadowlands = self.db.profile.showZoneShadowlands
        self.db.profile.showMiniMapDragonIsles = self.db.profile.showZoneDragonIsles
        self.db.profile.showMiniMapKhazAlgar = self.db.profile.showZoneKhazAlgar
    end

end