-- LogStatistics.lua
-- @Date   : 07/09/2024, 3:43:12 PM
--
-- @Description :

BuildEnv(...)

LogStatistics = Addon:NewModule('LogStatistics', 'NetEaseSocket-2.0', 'AceEvent-3.0')

function LogStatistics:OnInitialize()
    self.isSendExposure = false
    self.logs = {}
    C_Timer.NewTicker(60 * 5, function() self:SendLogs() end)
end

function LogStatistics:OnEnable()
    self:RegisterEvent('PLAYER_LOGOUT')
    self:RegisterEvent('PLAYER_LEAVING_WORLD')
end

function LogStatistics:SendServerExposure()
    if not Logic:IsServerLogon() or self.isSendExposure then
        return
    end
    local version = '199701010000' -- 暂时只写默认版本号

    Logic:SendServer('EXPOSURE', version, ADDON_VERSION)
    self.isSendExposure = true
end

function LogStatistics:InsertLog(log)
    if not log then
        return
    end
    table.insert(self.logs, log)
end

function LogStatistics:SendLogs()
    if not Logic:IsServerLogon() then
        return
    end
    if #self.logs > 0 then
        Logic:SendServer('STATISTICS', self.logs)
    end
    self.logs = {}
end

function LogStatistics:PLAYER_LEAVING_WORLD()
    self:SendLogs()
end

function LogStatistics:PLAYER_LOGOUT()
    self:SendLogs()
end
