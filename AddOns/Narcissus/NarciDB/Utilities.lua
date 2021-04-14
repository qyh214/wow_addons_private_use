--Not Loaded
local After = C_Timer.After;

local DistanceCalculator;
local MovementListener;

function NarciAPI_ActivateDistanceCalculator(calibrateDistance)
    if not DistanceCalculator then
        --Timer frame
        DistanceCalculator = CreateFrame("Frame");
        DistanceCalculator:Hide();
        DistanceCalculator.basicSpeed = 0;

        local function OnUpdate(self, elapsed)
            self.t = self.t + elapsed;
        end

        DistanceCalculator:SetScript("OnShow", function(self)
            self.t = 0;
        end);

        DistanceCalculator:SetScript("OnHide", function(self)
            print(self.t);
            if self.basicSpeed > 0 then
                local d = self.basicSpeed * self.t;
                d = math.floor(d * 100 + 0.5) / 100;
                print("|cffFFF569"..d.." yd|r");
            elseif self.t > 0.2 then
                if self.calibrateDistance then
                    self.basicSpeed = self.calibrateDistance / self.t;
                    self.calibrateDistance = nil;
                    print("Speed: ".. math.floor(self.basicSpeed * 100 + 0.5) / 100 .. " yd/s" );
                else
                    print("Speed Not Calibrated");
                end
            end
            self.t = 0;
        end);

        DistanceCalculator:SetScript("OnUpdate", OnUpdate);

        --Event listener
        MovementListener = CreateFrame("Frame");
        MovementListener:Hide();

        MovementListener:SetScript("OnShow", function(self)
            self:RegisterEvent("PLAYER_STARTED_MOVING");
            self:RegisterEvent("PLAYER_STOPPED_MOVING");
        end);

        local function OnEvent(self, event)
            if event == "PLAYER_STARTED_MOVING" then
                DistanceCalculator:Show();
            else
                DistanceCalculator:Hide();
            end
        end

        MovementListener:SetScript("OnEvent", OnEvent);

        --Global
        function NarciAPI_DeactivateDistanceCalculator()
            MovementListener:Hide();
            DistanceCalculator:Hide();
        end
    end

    MovementListener:Show();

    if calibrateDistance and type(calibrateDistance) == "number" and calibrateDistance >= 5 then
        DistanceCalculator.basicSpeed = 0;
        DistanceCalculator.calibrateDistance = calibrateDistance;
    end
end

local Globals = {};
local totalGlobals = 1;
for k, v in pairs(_G) do
    Globals[totalGlobals] = k;
    totalGlobals = totalGlobals + 1;
end

local SEARCH_PER_FRAME = 240;
local numLoop = 0;
local numMatch = 0;
local function SearchLoop(b, key)
    local find = string.find;
    local index;
    for i = b, b + SEARCH_PER_FRAME  do
        if Globals[i] then
            index = i;

            if find(Globals[i], key) then
                numMatch = numMatch + 1;
                
                local t = type(_G[ Globals[i] ]);
                if t == "number" or t == "string" then
                    print("|cffffd200".. Globals[i].."|r = ".. (_G[Globals[i]] or "nil") );
                else
                    print("|cff808080"..t.." |cffffd200".. Globals[i]);
                end
            end
        else
            print("Search Completes ---------------")
            print("Found ".. "|cffffd200".. numMatch .. "|r matches.")
            numLoop = 0;
            return
        end
    end
    After(0, function()
        SearchLoop(b + SEARCH_PER_FRAME + 1, key)
    end)


    numLoop = numLoop + 1;
    if numLoop == 100 then
        numLoop = 0;
        print(math.floor(index / totalGlobals * 10000 + 0.5)/100 .. "% ----------------------------")
    end
end

function Narci_SearchGlobalString(key)
    if type(key) ~= "string" then
        print("The key must be a string!");
        return
    end
    numLoop = 0;
    numMatch = 0;
    local beginning = 1;
    SearchLoop(beginning, key)
end