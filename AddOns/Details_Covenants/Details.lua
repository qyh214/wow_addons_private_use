local _, dc = ...
local oribos = _G.Oribos

function dc:replaceDetailsImplmentation()
    if _G.NickTag and _G._detalhes then
        _G._detalhes.GetNickname = function(self, playerName, default, silent)
            local covenantPrefix = ""
            local covenantSuffix = ""

            if default == false then
                if DCovenant["iconAlign"] == "right" then
                    covenantSuffix = " "..oribos:getCovenantIconForPlayer(playerName)
                else 
                    covenantPrefix = oribos:getCovenantIconForPlayer(playerName).." "
                end 
            end

            if (not silent) then
                assert (type (playerName) == "string", "NickTag 'GetNickname' expects a string or string on #1 argument.")
            end
            
            local _table = NickTag:GetNicknameTable (playerName)
            if (not _table) then
                if (_G._detalhes.remove_realm_from_name) then
                    playerName = playerName:gsub (("%-.*"), "")
                end

                return covenantPrefix..playerName..covenantSuffix or nil
            end
            
            local nickName = _table[1]
            if nickName then
                if TemniUgolok_SetEmojiToDetails then
                    return covenantPrefix..TemniUgolok_SetEmojiToDetails(_table[1])..covenantSuffix
                else 
                    return covenantPrefix.._table[1]..covenantSuffix
                end 
            else
                return default or nil
            end
        end
    end
end
