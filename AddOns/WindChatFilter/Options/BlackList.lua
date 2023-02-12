local W, F, L, P, G, O = unpack(select(2, ...))

O.blackList = {
    order = 11,
    name = L["Black List"],
    type = "group",
    args = {
        description = {
            order = 0,
            type = "description",
            fontSize = "medium",
            name = L["The rules below will be applied to the black list."] .. "\n ",
            width = "full"
        },
        createNewRule = {
            order = 100000000,
            type = "execute",
            name = L["Create New Rule"],
            desc = L["Create a new rule for the black list."],
            width = "full",
            func = function()
                F.CreateNewRule(W.db.rules.blackList, O.blackList.args)
            end
        },
    }
}

W:AddPostInitFunction(
    function()
        for ruleID, rule in pairs(W.db.rules.blackList) do
            F.RefreshRuleOptions(W.db.rules.blackList, O.blackList.args, ruleID, rule)
        end
    end
)
