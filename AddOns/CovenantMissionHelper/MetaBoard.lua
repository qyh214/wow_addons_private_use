CovenantMissionHelper, CMH = ...

local MetaBoard = {}
CMH.MetaBoard = MetaBoard

local function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

local function get_subs(numbers)
    local result = {}
    if #numbers == 2 then return {{numbers[1], numbers[2]}, {numbers[2], numbers[1]}} end

    for i, number in pairs(numbers) do
        local new_numbers = {}
        for _, n in pairs(numbers) do if n ~= number then table.insert(new_numbers, n) end end
        local tmp = get_subs(new_numbers)
        for _, v in pairs(tmp) do
            table.insert(v, 1, number)
            table.insert(result, v)
        end
    end

    return result
end

function MetaBoard:new(missionPage, isCalcRandom)
    local newObj = {
        baseBoard = CMH.Board:new(missionPage, isCalcRandom)
    }
    self.__index = self
    setmetatable(newObj, self)

    return newObj
end

function MetaBoard:findBestDisposition()
    local bestBoard, bestLostHP = {}, 9999999
    for board in self:findBestDispositionIterator() do
        board:simulate()
        local lostHP = board:getTotalLostHP(board:isWin())
        if board:isWin() then
            if lostHP < bestLostHP then
                bestLostHP = lostHP
                bestBoard = board
            end
        end

        CMH.Board.CombatLog = {}
        CMH.Board.HiddenCombatLog = {}
        CMH.Board.CombatLogEvents = {}
    end

    return next(bestBoard) ~= nil and bestBoard or self.baseBoard
end

function MetaBoard:findBestDispositionIterator()
    -- unique subs only
    local hash = {}
    local numbers = {}
    local subs = get_subs({0, 1, 2, 3, 4})

    return function ()
        for _, sub in ipairs(subs) do
            local unitIDs = ''

            for _, boardIndex in ipairs(sub) do
                    unitIDs = self.baseBoard.units[boardIndex] == nil and unitIDs .. '-1|' or unitIDs .. self.baseBoard.units[boardIndex].ID .. '|'
            end

            if not hash[unitIDs] then
                --print(unitIDs)
                --print(table.concat(sub, ';'))
                hash[unitIDs] = true

                local newBoard = copy(self.baseBoard)
                for newIndex, oldIndex in ipairs(sub) do
                    if self.baseBoard.units[oldIndex] ~= nil then
                        -- newIndex starts from 1
                        newBoard.units[newIndex-1] = copy(self.baseBoard.units[oldIndex])
                        newBoard.units[newIndex-1].boardIndex = newIndex-1
                        --print(newIndex-1 .. ', ' .. oldIndex .. ': ' .. newBoard.units[newIndex-1].name)
                    else
                        newBoard.units[newIndex-1] = nil
                    end
                end
                newBoard.isCalcRandom = false
                return newBoard
            end
        end
        return nil
    end
end
