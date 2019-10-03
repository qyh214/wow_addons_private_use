-- Running tests from command line: (Make sure you run from root/main folder)
-- > lua DRList-1.0/tests/test-retail.lua
--
-- Running tests ingame:
-- /drlist

if loadfile then
    assert(loadfile("DRList-1.0/tests/engine.lua"))()
end

local Tests = SimpleTesting:New("DRList-1.0", "Retail")
if not Tests:IsInGame() then
    strmatch = string.match
    GetLocale = function() return "enUS" end
    GetBuildInfo = function() return nil, nil, nil, 80000 end
    GetSpellInfo = function() return "" end

    assert(loadfile("DRList-1.0/libs/LibStub/LibStub.lua"))()
    assert(loadfile("DRList-1.0/DRList-1.0.lua"))()
    assert(loadfile("DRList-1.0/Spells.lua"))()
end

local DRList = LibStub("DRList-1.0")

--[[function Tests:BeforeEach()

end]]

Tests:It("Loads lib", function()
    assert(LibStub("DRList-1.0"))
    assert(type(LibStub("DRList-1.0").spellList) == "table")
end)

Tests:It("GetsSpellList", function()
    assert(next(DRList.spellList))
    assert(DRList:GetSpells()[853] == "stun")
    assert(DRList:GetSpells()[339] == "root")
end)

Tests:It("GetsResetTimes", function()
    assert(DRList:GetResetTime() == 18.3)
    assert(DRList:GetResetTime("stun") == 18.3)
    assert(DRList:GetResetTime(123) == 18.3)
    assert(DRList:GetResetTime(true) == 18.3)
    assert(DRList:GetResetTime({}) == 18.3)
    assert(DRList:GetResetTime("knockback") == 10.3)
end)

Tests:It("GetsCategoryNames", function()
    assert(type(DRList.categoryNames[DRList.gameExpansion].stun) == "string")
    assert(type(DRList:GetCategories().root) == "string")
    assert(type(DRList:GetCategories().knockback) == "string")
end)

Tests:It("GetsCategoryNamesPvE", function()
    assert(type(DRList:GetPvECategories().stun) == "string")
    assert(type(DRList:GetPvECategories().taunt) == "string")
    assert(DRList:GetPvECategories().disorient == nil)
end)

Tests:It("GetsCategoryFromSpell", function()
    assert(DRList:GetCategoryBySpellID(853) == "stun")
    assert(DRList:GetCategoryBySpellID(339) == "root")
    assert(DRList:GetCategoryBySpellID(1776) == "incapacitate")

    assert(DRList:GetCategoryBySpellID(123) == nil)
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
    assert(low(DRList:GetCategoryLocalization("root")) == low(DRList.L.ROOTS))
    assert(DRList:GetCategoryLocalization("knockback"))
    assert(DRList:GetCategoryLocalization("random_root") == nil)
end)

Tests:It("ChecksCategoriesPvE", function()
    assert(next(DRList.categoriesPvE))
    assert(DRList:IsPvECategory("stun") == true)
    assert(DRList:IsPvECategory("taunt") == true)
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
    assert(DRList:GetNextDR(1, "random_stun") == 0)

    assert(DRList:GetNextDR(1, "disorient") == 0.50)
    assert(DRList:GetNextDR(2, "disorient") == 0.25)

    assert(DRList:GetNextDR(0, "knockback") == 0)
    assert(DRList:GetNextDR(1, "knockback") == 0)

    assert(DRList:GetNextDR(1, "taunt") ==  0.65)
    assert(DRList:GetNextDR(2, "taunt") ==  0.42)
    assert(DRList:GetNextDR(3, "taunt") ==  0.27)
    assert(DRList:GetNextDR(4, "taunt") ==  0)
    assert(DRList:GetNextDR(10, "taunt") ==  0)
end)

Tests:It("IterateSpellsByCategory", function()
    local ran = false
    for spellID, category in DRList:IterateSpellsByCategory("root") do
        assert(type(spellID) == "number")
        assert(category == "root")
        ran = true
    end
    assert(ran)
    ran = false

    for category, localizedCategory in pairs(DRList:GetPvECategories()) do
        for spellID, cat in DRList:IterateSpellsByCategory(category) do -- luacheck: ignore
            assert(type(spellID) == "number")
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

    for spellID, category in pairs(DRList.spellList) do
        if type(spellID) ~= "number" or not GetSpellInfo(spellID) then
            success = false
            err = err .. "|cFFFF0000Invalid spell:|r " .. spellID .. "\n"
        end

        if type(category) ~= "string" or not DRList.categoryNames[DRList.gameExpansion][category] then
            success = false
            err = err .. "|cFFFF0000Invalid category:|r " .. category .. "\n"
        end
    end

    if not success then
        return error(err)
    end

    return success
end, true)

if Tests:IsInGame() then
    if select(4, GetBuildInfo()) > 80000 then
        SLASH_DRLIST1 = "/drlist"
        SlashCmdList["DRLIST"] = function()
            Tests:RunAll()
        end
    end
else
    DRList.gameExpansion = "retail"
    Tests:RunAll()
end
