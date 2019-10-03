-- Running tests from command line: (Make sure you run from root/main folder)
-- > lua DRList-1.0/tests/test-classic.lua
--
-- Running tests ingame:
-- /drlist

if loadfile then
    assert(loadfile("DRList-1.0/tests/engine.lua"))()
end

local Tests = SimpleTesting:New("DRList-1.0", "Classic")
if not Tests:IsInGame() then
    strmatch = string.match
    GetLocale = function() return "enUS" end
    GetBuildInfo = function() return nil, nil, nil, 11302 end
    GetSpellInfo = function(id)
        -- Need to mock some of the spells used in testing
        if id == 853 then return "Hammer of Justice"
        elseif id == 122 then return "Frost Nova"
        elseif id == 12355 then return "Impact"
        elseif id == 20066 then return "Repentance"
        elseif id == 5211 then return "Bash"
        else return "" end
    end

    assert(loadfile("DRList-1.0/libs/LibStub/LibStub.lua"))()
    assert(loadfile("DRList-1.0/DRList-1.0.lua"))()
    assert(loadfile("DRList-1.0/Spells.lua"))()
end

local DRList = LibStub("DRList-1.0")

--[[function Tests:BeforeEach()
    DRList.gameExpansion = "classic"
end]]

Tests:It("Loads lib", function()
    assert(LibStub("DRList-1.0"))
    assert(type(LibStub("DRList-1.0").spellList) == "table")
end)

Tests:It("GetsSpellList", function()
    assert(next(DRList.spellList))
    assert(DRList:GetSpells()["Hammer of Justice"].category == "stun")
    assert(DRList:GetSpells()["Hammer of Justice"].spellID == 853)
    assert(DRList:GetSpells()["Frost Nova"].category == "root")
    assert(DRList:GetSpells()["Frost Nova"].spellID == 122)
    assert(DRList:GetSpells()["Impact"].category == "random_stun")
end)

Tests:It("GetsResetTimes", function()
    assert(DRList:GetResetTime() == 18.5)
    assert(DRList:GetResetTime("stun") == 18.5)
    assert(DRList:GetResetTime(123) == 18.5)
    assert(DRList:GetResetTime(true) == 18.5)
    assert(DRList:GetResetTime({}) == 18.5)
    assert(DRList:GetResetTime("knockback") == 18.5)
end)

Tests:It("GetsCategoryNames", function()
    assert(type(DRList.categoryNames[DRList.gameExpansion].stun) == "string")
    assert(type(DRList:GetCategories().root) == "string")
    assert(type(DRList:GetCategories().random_root) == "string")
    assert(DRList:GetCategories().knockback == nil)
end)

Tests:It("GetsCategoryNamesPvE", function()
    assert(type(DRList:GetPvECategories().stun) == "string")
    assert(DRList:GetPvECategories().disorient == nil)
    assert(DRList:GetPvECategories().taunt == nil)
end)

Tests:It("GetsCategoryFromSpell", function()
    assert(DRList:GetCategoryBySpellID("Hammer of Justice") == "stun")
    assert(DRList:GetCategoryBySpellID("Frost Nova") == "root")
    assert(DRList:GetCategoryBySpellID("Repentance") == "incapacitate")
    assert(DRList:GetCategoryBySpellID("Impact") == "random_stun")

    assert(select(2, DRList:GetCategoryBySpellID("Frost Nova")) == 122)
    assert(select(2, DRList:GetCategoryBySpellID("Bash")) == 5211)

    assert(DRList:GetCategoryBySpellID(1776) == nil)
    assert(DRList:GetCategoryBySpellID("123") == nil)
    assert(DRList:GetCategoryBySpellID(true) == nil)
    assert(DRList:GetCategoryBySpellID({}) == nil)
    assert(DRList:GetCategoryBySpellID() == nil)
end)

Tests:It("GetsLocalizations", function()
    assert(next(DRList.categoryNames))
    assert(DRList:GetCategoryLocalization("abc") == nil)
    assert(DRList:GetCategoryLocalization(123) == nil)
    assert(DRList:GetCategoryLocalization(true) == nil)
    assert(DRList:GetCategoryLocalization({}) == nil)
    assert(DRList:GetCategoryLocalization() == nil)

    local low = string.lower
    assert(low(DRList.categoryNames[DRList.gameExpansion]["stun"]) == low(DRList.L.STUNS))
    assert(low(DRList:GetCategoryLocalization("random_root")) == low(DRList.L.RANDOM_ROOTS))
    assert(low(DRList:GetCategoryLocalization("mind_control")) == low(DRList.L.MIND_CONTROL))
    assert(DRList:GetCategoryLocalization("knockback") == nil)
end)

Tests:It("ChecksCategoriesPvE", function()
    assert(next(DRList.categoriesPvE))
    assert(DRList:IsPvECategory("stun") == true)
    assert(DRList:IsPvECategory("taunt") == false)
    assert(DRList:IsPvECategory("disorient") == false)

    assert(DRList:IsPvECategory() == false)
    assert(DRList:IsPvECategory({}) == false)
    assert(DRList:IsPvECategory("") == false)
    assert(DRList:IsPvECategory(853) == false)
    assert(DRList:IsPvECategory(true) == false)
end)

Tests:It("GetsNextDR", function()
    assert(DRList:GetNextDR(1, "stun") == 0.50)
    assert(DRList:GetNextDR(2, "stun") == 0.25)
    assert(DRList:GetNextDR(3, "stun") == 0)
    assert(DRList:GetNextDR(10, "stun") == 0)

    assert(DRList:GetNextDR(1, "abc") == 0)
    assert(DRList:GetNextDR(1, 123) == 0)
    assert(DRList:GetNextDR(1, true) == 0)
    assert(DRList:GetNextDR("1", "stun") == 0)
    assert(DRList:GetNextDR(true, "stun") == 0)
    assert(DRList:GetNextDR({}, "stun") == 0)
    assert(DRList:GetNextDR(true) == 0)
    assert(DRList:GetNextDR() == 0)
    assert(DRList:GetNextDR(-1, {}) == 0)

    assert(DRList:GetNextDR(1, "knockback") == 0)
    assert(DRList:GetNextDR(1, "taunt") ==  0)
    assert(DRList:GetNextDR(1, "random_stun") == 0.50)
    assert(DRList:GetNextDR(2, "random_root") == 0.25)
    assert(DRList:GetNextDR(1, "mind_control") == 0.50)
end)

Tests:It("IterateSpellsByCategory", function()
    local ran = false
    for spellID, category in DRList:IterateSpellsByCategory("root") do
        assert(type(spellID) == "string")
        assert(category == "root")
        ran = true
    end
    assert(ran)
    ran = false

    for category, localizedCategory in pairs(DRList:GetPvECategories()) do
        for spellID, cat in DRList:IterateSpellsByCategory(category) do -- luacheck: ignore
            assert(type(spellID) == "string")
            assert(category == cat)
            ran = true
            break
        end
    end
    assert(ran)
end)

-- This test is only ran ingame
Tests:It("Verifies spell list", function()
    local success = true
    local err = ""

    for spellName, data in pairs(DRList.spellList) do
        if type(spellName) ~= "string" or spellName ~= GetSpellInfo(data.spellID) then
            success = false
            err = err .. "|cFFFF0000Invalid spell:|r " .. spellName .. "\n"
        end

        if type(data.category) ~= "string" or not DRList.categoryNames[DRList.gameExpansion][data.category] then
            success = false
            err = err .. "|cFFFF0000Invalid category:|r " .. data.category .. "\n"
        end
    end

    if not success then
        return error(err)
    end

    return success
end, true)

if Tests:IsInGame() then
    if select(4, GetBuildInfo()) < 80000 then
        SLASH_DRLIST1 = "/drlist"
        SlashCmdList["DRLIST"] = function()
            Tests:RunAll()
        end
    end
else
    DRList.gameExpansion = "classic"
    Tests:RunAll()
end
