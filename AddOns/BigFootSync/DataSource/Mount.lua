---@class BigFootSync
local BigFootSync = select(2, ...)
BigFootSync.mount = {}

---@class Mount
local M = BigFootSync.mount

if BigFootSync.isRetail then
    function M.GetMounts()
        local mounts = ""
        -- local total = C_MountJournal.GetNumMounts()
        for _, id in pairs(C_MountJournal.GetMountIDs()) do
            local isCollected = select(11, C_MountJournal.GetMountInfoByID(id))
            if isCollected then
                if mounts == "" then
                    mounts = id
                else
                    mounts = mounts .. "," .. id
                end
            end
        end
        return mounts
    end
else
    function M.GetMounts()
        return ""
    end
end