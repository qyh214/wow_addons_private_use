local W, F, L = unpack(select(2, ...))

local LibStub = _G.LibStub
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix

function W:OnInitialize()
    self:BuildDatabase()
    self:BuildOptions()

    C_ChatInfo_RegisterAddonMessagePrefix(self.AddonMsgPrefix)
end

function W:OnProfileChanged()
    self.db = self.Database.profile
    for _, module in self:IterateModules() do
        if module.ProfileUpdate then
            module:ProfileUpdate()
        end
    end
end
