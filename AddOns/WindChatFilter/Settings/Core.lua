local ns = select(2, ...)
local W, F, L = unpack(ns)
local ADB = LibStub("AceDB-3.0")

ns[4] = {
    core = {
        enable = true
    },
    minimapIcon = {
        hide = false
    },
    rules = {
        blackList = {},
        whiteList = {}
    }
}

ns[5] = {
    advanced = {
        stopInInstance = false,
        includeMyself = false,
        includeFriend = false,
        includeGuildMember = false,
        playerInfoCacheExpiration = 7 * 24 * 60 * 60,
        logLevel = 1,
        doNotUseGUIDCache = false
    },
    playerInfoCache = {}
}

function W:BuildDatabase()
    self.Database =
        ADB:New(
        self.AddonNamePlain .. "DB",
        {
            profile = ns[4],
            global = ns[5]
        },
        true
    )

    self.Database.RegisterCallback(self, "OnProfileChanged")
    self.db = self.Database.profile
    self.global = self.Database.global

    if self.global.guidCache then -- Migrate from oldversion
        self.global.guidCache = nil
    end
end
