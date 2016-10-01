
BuildEnv(...)

Object = Addon:NewClass('Object')

function Object:InitAttr(list)
    for i, v in ipairs(list) do
        local key = '_' .. v
        self['Set' .. v] = function(self, value)
            self[key] = value
        end

        self[v:match('^Is') and v or 'Get' .. v] = function(self)
            return self[key]
        end
    end
end