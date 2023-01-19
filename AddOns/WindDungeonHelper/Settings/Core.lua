local ns = select(2, ...)
local W, F, L = unpack(ns)
local ADB = LibStub("AceDB-3.0")

ns[4] = {
    enable = true,
    minimapIcon = {
        hide = false
    }
}

function W:BuildDatabase()
    self.Database =
        ADB:New(
        "WindDungeonHelperDB",
        {
            profile = ns[4],
            global = {
                logLevel = 2,
                loginMessage = true
            }
        },
        true
    )
    self.Database.RegisterCallback(self, "OnProfileChanged")
    self.db = self.Database.profile
end
