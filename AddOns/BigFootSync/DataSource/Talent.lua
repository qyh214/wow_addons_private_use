---@class BigFootSync
local BigFootSync = select(2, ...)
BigFootSync.talent = {}

---@class Talent
local TL = BigFootSync.talent

---------------------------------------------------------------------
-- 保存玩家自己的天赋信息
---------------------------------------------------------------------
if BigFootSync.isRetail then
    -- from Blizzard_ClassTalentImportExport.lua
    local bitWidthHeaderVersion = 8
    local bitWidthSpecID = 16
    local bitWidthRanksPurchased = 6

    local function WriteLoadoutHeader(exportStream, serializationVersion, specID, treeHash)
        exportStream:AddValue(bitWidthHeaderVersion, serializationVersion)
        exportStream:AddValue(bitWidthSpecID, specID)
        -- treeHash is a 128bit hash, passed as an array of 16, 8-bit values
        for i, hashVal in ipairs(treeHash) do
            exportStream:AddValue(8, hashVal)
        end
    end

    local function GetActiveEntryIndex(treeNode)
        for i, entryID in ipairs(treeNode.entryIDs) do
            if(entryID == treeNode.activeEntry.entryID) then
                return i
            end
        end
        return 0
    end

    local function WriteLoadoutContent(exportStream, configID, treeID)
        local treeNodes = C_Traits.GetTreeNodes(treeID)
        for i, treeNodeID in ipairs(treeNodes) do
            local treeNode = C_Traits.GetNodeInfo(configID, treeNodeID)

            local isNodeGranted = treeNode.activeRank - treeNode.ranksPurchased > 0
            local isNodePurchased = treeNode.ranksPurchased > 0
            local isNodeSelected = isNodeGranted or isNodePurchased
            local isPartiallyRanked = treeNode.ranksPurchased ~= treeNode.maxRanks
            local isChoiceNode = treeNode.type == Enum.TraitNodeType.Selection or treeNode.type == Enum.TraitNodeType.SubTreeSelection

            exportStream:AddValue(1, isNodeSelected and 1 or 0)
            if(isNodeSelected) then
                exportStream:AddValue(1, isNodePurchased and 1 or 0)

                if isNodePurchased then
                    exportStream:AddValue(1, isPartiallyRanked and 1 or 0)
                    if(isPartiallyRanked) then
                        exportStream:AddValue(bitWidthRanksPurchased, treeNode.ranksPurchased)
                    end

                    exportStream:AddValue(1, isChoiceNode and 1 or 0)
                    if(isChoiceNode) then
                        local entryIndex = GetActiveEntryIndex(treeNode)
                        if(entryIndex <= 0 or entryIndex > 4) then
                            error("Error exporting tree node " .. treeNode.ID .. ". The active choice node entry index (" .. entryIndex .. ") is out of bounds. ")
                        end
                        -- store entry index as zero-index
                        exportStream:AddValue(2, entryIndex - 1)
                    end
                end
            end
        end
    end

    local function SaveTalentsByID(t, specID, configID, isActive)
        local exportStream = ExportUtil.MakeExportDataStream()
        local configInfo = C_Traits.GetConfigInfo(configID)
        local name = isActive and "CURRENT_ACTIVE" or "$" .. configInfo.name
        local treeID = configInfo.treeIDs[1]
        local treeHash = C_Traits.GetTreeHash(treeID)
        local serializationVersion = C_Traits.GetLoadoutSerializationVersion()
        WriteLoadoutHeader(exportStream, serializationVersion, specID, treeHash)
        WriteLoadoutContent(exportStream, configID, treeID)
        t[name] = exportStream:GetExportString()
    end

    -- local function SaveTalentsByConfigID(t, configID)
    --     local configInfo = C_Traits.GetConfigInfo(configID)
    --     t["name"] = configInfo.name -- talent loadout name
    --     t["nodes"] = {}

    --     for _, treeId in pairs(configInfo.treeIDs) do
    --         for _, nodeId in pairs(C_Traits.GetTreeNodes(treeId)) do
    --             -- https://warcraft.wiki.gg/wiki/API_C_Traits.GetNodeInfo
    --             local nodeInfo = C_Traits.GetNodeInfo(configID, nodeId)
    --             if nodeInfo.currentRank ~= 0 then
    --                 t["nodes"][nodeId] = nodeInfo.currentRank
    --             end
    --         end
    --     end
    -- end

    TL.SaveTalents = function(t)
        wipe(t)
        local specID = PlayerUtil.GetCurrentSpecID()

        -- 当前启用
        local activeConfigID = C_ClassTalents.GetActiveConfigID()
        SaveTalentsByID(t, specID, activeConfigID, true)

        -- 所有
        local configs = C_ClassTalents.GetConfigIDsBySpecID(specID)
        for _, configID in pairs(configs) do
            SaveTalentsByID(t, specID, configID)
        end

        -- 保存所有
        -- local classId = select(2, UnitClassBase("player"))
        -- t["specId"] = GetSpecializationInfoForClassID(classId, GetSpecialization())
        -- for i = 1, GetNumSpecializationsForClassID(PlayerUtil.GetClassID()) do
        --     local specId = GetSpecializationInfoForClassID(PlayerUtil.GetClassID(),  i)
        --     t[specId] = {}

        --     local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specId)
        --     for _, configID in pairs(configIDs) do
        --         t[specId][configID] = {}
        --         SaveTalentsByConfigID(t[specId][configID], configID)
        --     end
        -- end
    end
else
    TL.SaveTalents = function(t)
        -- 仅保存当前天赋配置
        for tabIndex = 1, GetNumTalentTabs() do
            -- 每个“专精”单独存放
            t[tabIndex] = {
                ["pointsSpent"] = select(3, GetTalentTabInfo(tabIndex)),
                ["details"] = {},
            }
            -- 遍历所有天赋点
            for talentIndex = 1, GetNumTalents(tabIndex) do
                local _, _, row, column, rank = GetTalentInfo(tabIndex, talentIndex)
                if rank ~= 0 then
                    tinsert(t[tabIndex]["details"], {
                        ["row"] = row,
                        ["column"] = column,
                        ["rank"] = rank,
                    })
                end
            end
        end
    end
end