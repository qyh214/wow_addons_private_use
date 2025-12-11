local name, addon = ...;


--[[----------------------------------------------------------------------------
	Stat conversion factors (data taken from simc)
	https:--https://github.com/simulationcraft/simc/blob/dragonflight/engine/dbc/generated/sc_scale_data.inc
------------------------------------------------------------------------------]]
local hst_cnv =   {
    2.948095354,	2.948095354,	2.948095354,	2.948095354,	2.948095354,	--    5
    2.948095354,	2.948095354,	2.948095354,	2.948095354,	2.948095354,	--   10
    2.948095354,	3.095500122,	3.242904889,	3.390309657,	3.537714425,	--   15
    3.685119192,	3.83252396,	3.979928728,	4.127333496,	4.274738263,	--   20
    4.453978039,	4.649329515,	4.862222314,	5.094247563,	5.347176954,	--   25
    5.622984341,	5.923870234,	6.252289599,	6.610983454,	7.003014772,	--   30
    7.431809367,	7.901202447,	8.415491714,	8.979497968,	9.598634353,	--   35
    10.27898556,	11.02739849,	11.85158626,	12.76024738,	13.76320282,	--   40
    14.87155354,	16.09786185,	17.45636041,	18.96319344,	20.63669526,	--   45
    22.49771244,	24.56997673,	26.88053735,	29.46026251,	32.34442221,	--   50
    35.57336588,	39.1933116,	43.25726608,	47.82609852,	52.96979542,	--   55
    58.76892862,	65.31637495,	72.71933289,	81.10169039,	90.60680851,	--   60
    95.70270333,	101.0852007,	106.7704197,	112.775386,	119.1180827,	--   65
    125.8175044,	132.893714,	140.3679028,	148.2624537,	174.7114226,	--   70
    195.1745499,	218.0344269,	243.5717739,	272.1001901,	303.9700056,	--   75
    339.5725827,	379.3451222,	423.7760322,	473.4109257,	660,	--   80
  };
	
local crt_cnv =  {
    3.1267678,	3.1267678,	3.1267678,	3.1267678,	3.1267678,	--    5
    3.1267678,	3.1267678,	3.1267678,	3.1267678,	3.1267678,	--   10
    3.1267678,	3.28310619,	3.43944458,	3.59578297,	3.75212136,	--   15
    3.90845975,	4.06479814,	4.221136529,	4.377474919,	4.533813309,	--   20
    4.723916102,	4.931107062,	5.156902454,	5.402989839,	5.671248285,	--   25
    5.963771271,	6.282892672,	6.631216242,	7.011649117,	7.42743991,	--   30
    7.882222056,	8.380063201,	8.925521515,	9.523709967,	10.18036977,	--   35
    10.90195438,	11.69572568,	12.56986421,	13.5335957,	14.59733632,	--   40
    15.77285982,	17.07348984,	18.51432165,	20.11247789,	21.88740407,	--   45
    23.86121016,	26.05906623,	28.50966082,	31.24573297,	34.30469023,	--   50
    37.72932745,	41.56866382,	45.87891857,	50.72464994,	56.18008605,	--   55
    62.33068187,	69.27494313,	77.12656519,	86.01694436,	96.09813024,	--   60
    101.5028672,	107.2115765,	113.2413543,	119.6102579,	126.3373604,	--   65
    133.4428077,	140.9478785,	148.8750484,	157.248057,	185.2999937,	--   70
    207.0033105,	231.2486346,	258.3336995,	288.5911108,	322.3924302,	--   75
    360.1527393,	402.3357357,	449.4594281,	502.102497,	700,	--   80
};

local mst_cnv =  {
    3.1267678,	3.1267678,	3.1267678,	3.1267678,	3.1267678,	--    5
    3.1267678,	3.1267678,	3.1267678,	3.1267678,	3.1267678,	--   10
    3.1267678,	3.28310619,	3.43944458,	3.59578297,	3.75212136,	--   15
    3.90845975,	4.06479814,	4.221136529,	4.377474919,	4.533813309,	--   20
    4.723916102,	4.931107062,	5.156902454,	5.402989839,	5.671248285,	--   25
    5.963771271,	6.282892672,	6.631216242,	7.011649117,	7.42743991,	--   30
    7.882222056,	8.380063201,	8.925521515,	9.523709967,	10.18036977,	--   35
    10.90195438,	11.69572568,	12.56986421,	13.5335957,	14.59733632,	--   40
    15.77285982,	17.07348984,	18.51432165,	20.11247789,	21.88740407,	--   45
    23.86121016,	26.05906623,	28.50966082,	31.24573297,	34.30469023,	--   50
    37.72932745,	41.56866382,	45.87891857,	50.72464994,	56.18008605,	--   55
    62.33068187,	69.27494313,	77.12656519,	86.01694436,	96.09813024,	--   60
    101.5028672,	107.2115765,	113.2413543,	119.6102579,	126.3373604,	--   65
    133.4428077,	140.9478785,	148.8750484,	157.248057,	185.2999937,	--   70
    207.0033105,	231.2486346,	258.3336995,	288.5911108,	322.3924302,	--   75
    360.1527393,	402.3357357,	449.4594281,	502.102497,	700,	--   80
  };

local vrs_cnv =     {
    3.484112691,	3.484112691,	3.484112691,	3.484112691,	3.484112691,	--    5
    3.484112691,	3.484112691,	3.484112691,	3.484112691,	3.484112691,	--   10
    3.484112691,	3.658318326,	3.83252396,	4.006729595,	4.180935229,	--   15
    4.355140864,	4.529346498,	4.703552133,	4.877757767,	5.051963402,	--   20
    5.263792227,	5.494662155,	5.746262735,	6.020474392,	6.319390946,	--   25
    6.645345131,	7.000937549,	7.389069526,	7.812980445,	8.276290186,	--   30
    8.783047434,	9.33778471,	9.945581116,	10.61213396,	11.3438406,	--   35
    12.14789202,	13.03238004,	14.00642012,	15.08029235,	16.26560333,	--   40
    17.57547237,	19.02474582,	20.63024412,	22.41104679,	24.38882167,	--   45
    26.58820561,	29.03724523,	31.76790777,	34.81667388,	38.22522625,	--   50
    42.04125059,	46.31936825,	51.12222354,	56.5217528,	62.60066731,	--   55
    69.45418837,	77.19207949,	85.94102978,	95.84745228,	107.0807737,	--   60
    113.1031948,	119.4643281,	126.1832233,	133.2800016,	140.7759159,	--   65
    148.6934143,	157.0562075,	165.8893396,	175.2192635,	206.4771359,	--   70
    230.6608317,	257.67705,	287.8575509,	321.572952,	359.2372794,	--   75
    401.3130523,	448.3169626,	500.8262199,	559.4856395,	780,	--   80
  };

  local lee_cnv = {
    4.556125589,	4.556125589,	4.556125589,	4.556125589,	4.556125589,	--    5
    4.556125589,	4.556125589,	4.556125589,	4.556125589,	4.556125589,	--   10
    4.556125589,	4.783931869,	5.011738148,	5.239544428,	5.467350707,	--   15
    5.695156987,	5.922963266,	6.150769545,	6.378575825,	6.606382104,	--   20
    6.883387706,	7.185293091,	7.514307661,	7.872890423,	8.263779433,	--   25
    8.690025176,	9.155028423,	9.662583199,	10.2169256,	10.82278928,	--   30
    11.48546867,	12.21089087,	13.00569776,	13.87733962,	14.83418219,	--   35
    15.88562903,	17.04226168,	18.31600031,	19.72028806,	21.2703027,	--   40
    22.98320017,	24.87839486,	26.9778826,	29.30661343,	31.89292206,	--   45
    34.76902578,	37.97160074,	41.54245007,	45.52927901,	49.98659542,	--   50
    54.97675724,	60.57119206,	66.85181896,	73.91270808,	81.86201984,	--   55
    90.82427377,	100.9430061,	112.3838864,	125.338377,	140.0280348,	--   60
    147.903471,	156.2218363,	165.0080418,	174.2883999,	184.0907025,	--   65
    194.4443047,	205.3802128,	216.9311765,	229.1317879,	270.0072718,	--   70
    301.6319536,	336.9606856,	376.4273059,	420.5164658,	469.7695816,	--   75
    524.7914833,	586.2578415,	654.9234651,	731.6315702,	1019.995125,	--   80
  };
  
local avd_cnv = {
	2.429933648,	2.429933648,	2.429933648,	2.429933648,	2.429933648,	--    5
    2.429933648,	2.429933648,	2.429933648,	2.429933648,	2.429933648,	--   10
    2.429933648,	2.55143033,	2.672927012,	2.794423695,	2.915920377,	--   15
    3.03741706,	3.158913742,	3.280410424,	3.401907107,	3.523403789,	--   20
    3.67114011,	3.832156315,	4.007630753,	4.198874892,	4.407349031,	--   25
    4.634680094,	4.882681826,	5.153377706,	5.449026985,	5.772154285,	--   30
    6.125583292,	6.512475133,	6.936372139,	7.4012478,	7.911563836,	--   35
    8.47233548,	9.089206227,	9.7685335,	10.51748696,	11.34416144,	--   40
    12.25770676,	13.26847726,	14.38820405,	15.63019383,	17.00955843,	--   45
    18.54348041,	20.25152039,	22.15597337,	24.28228214,	26.65951756,	--   50
    29.3209372,	32.30463577,	35.65430345,	39.42011098,	43.65974391,	--   55
    48.43961268,	53.83626993,	59.93807276,	66.84713441,	74.68161856,	--   60
    78.88185118,	83.31831267,	88.00428898,	92.95381328,	98.18170799,	--   65
    103.7036292,	109.5361135,	115.6966275,	122.2036202,	144.0038783,	--   70
    160.8703752,	179.7123657,	200.7612298,	224.2754484,	250.5437769,	--   75
    279.8887911,	312.6708488,	349.2925147,	390.2035041,	543.9974,	--   80
};

local spd_cnv =  {
	0.759354265,	0.759354265,	0.759354265,	0.759354265,	0.759354265,	--    5
    0.759354265,	0.759354265,	0.759354265,	0.759354265,	0.759354265,	--   10
    0.759354265,	0.797321978,	0.835289691,	0.873257405,	0.911225118,	--   15
    0.949192831,	0.987160544,	1.025128258,	1.063095971,	1.101063684,	--   20
    1.147231284,	1.197548848,	1.25238461,	1.312148404,	1.377296572,	--   25
    1.448337529,	1.52583807,	1.610430533,	1.702820933,	1.803798214,	--   30
    1.914244779,	2.035148479,	2.167616293,	2.312889937,	2.472363699,	--   35
    2.647604838,	2.840376946,	3.052666719,	3.286714676,	3.54505045,	--   40
    3.830533362,	4.146399143,	4.496313767,	4.884435572,	5.315487011,	--   45
    5.794837629,	6.328600123,	6.923741679,	7.588213168,	8.331099237,	--   50
    9.162792874,	10.09519868,	11.14196983,	12.31878468,	13.64366997,	--   55
    15.13737896,	16.82383435,	18.73064774,	20.8897295,	23.3380058,	--   60
    24.65057849,	26.03697271,	27.50134031,	29.04806665,	30.68178375,	--   65
    32.40738412,	34.23003546,	36.15519609,	38.18863132,	45.00121196,	--   70
    50.27199227,	56.16011427,	62.73788432,	70.08607764,	78.29493027,	--   75
    87.46524721,	97.70964024,	109.1539108,	121.938595,	169.9991875,	--   80
};

function addon.tsv:SetupConversionFactors()
	local level = UnitLevel("Player");
    level = math.max(level,1);
    
	addon.CritConv 		= crt_cnv[level];
	addon.HasteConv 	= hst_cnv[level];
	addon.VersConv 		= vrs_cnv[level];
	addon.MasteryConv 	= mst_cnv[level];
	addon.LeechConv		= lee_cnv[level];
	addon.AvoidConv     = avd_cnv[level];
	addon.SpeedConv     = spd_cnv[level];
end

local statIdMap = {
    [CR_CRIT_SPELL]={["conversionFactor"]="CritConv",["rating"]="BaseCritRating",["bracket"]="StatBrackets"},
    [CR_HASTE_SPELL]={["conversionFactor"]="HasteConv",["rating"]="BaseHasteRating", ["bracket"]="StatBrackets"},
    [CR_MASTERY]={["conversionFactor"]="MasteryConv",["rating"]="BaseMasteryRating",["bracket"]="StatBrackets"},
    [CR_VERSATILITY_DAMAGE_DONE]={["conversionFactor"]="VersConv",["rating"]="BaseVersatilityRating",["bracket"]="StatBrackets"},
    [CR_LIFESTEAL]={["conversionFactor"]="LeechConv",["rating"]="BaseLeechRating",["bracket"]="TertStatBrackets"},
	[CR_AVOIDANCE]={["conversionFactor"]="AvoidConv",["rating"]="BaseAvoidanceRating",["bracket"]="TertStatBrackets"},
	[CR_SPEED]={["conversionFactor"]="SpeedConv",["rating"]="BaseSpeedRating",["bracket"]="TertStatBrackets"},
}


--[[
    https://www.wowhead.com/news=318435/update-on-diminishing-returns-for-secondary-stats-in-shadowlands-new-thresholds-

    From 0 to 30%, there's no penalty.
    From 30% to 39%, there's a 10% penalty.
    From 39% to 47%, there's a 20% penalty.
    From 47% to 54%, there's a 30% penalty.
    From 54% to 66%, there's a 40% penalty.
    From 66% to 126%, there's a 50% penalty.
    You can't get more than 126% from gear rating.
]]
--[[
Secondary Stats get their scaling from id 21024
https://raw.githubusercontent.com/simulationcraft/simc/thewarwithin/engine/dbc/generated/item_scaling.inc
  { 21024,  0,    0.00000f,    0.00000f,    0.00000f,    0.00000f },
  { 21024,  1,   30.00000f,   30.00000f,    0.00000f,    0.00000f },
  { 21024,  2,   40.00000f,   39.00000f,    0.00000f,    0.00000f },
  { 21024,  3,   50.00000f,   47.00000f,    0.00000f,    0.00000f },
  { 21024,  4,   60.00000f,   54.00000f,    0.00000f,    0.00000f },
  { 21024,  5,   80.00000f,   66.00000f,    0.00000f,    0.00000f },
  { 21024,  6,  100.00000f,   76.00000f,    0.00000f,    0.00000f },
  { 21024,  7,  200.00000f,  126.00000f,    0.00000f,    0.00000f },
]]
addon.tsv.StatBrackets = {
    {["size"]=30,["penalty"]=0},
    {["size"]=10,["penalty"]=0.1},
    {["size"]=10,["penalty"]=0.2},
    {["size"]=10,["penalty"]=0.3},
    {["size"]=20,["penalty"]=0.4},
    {["size"]=120,["penalty"]=0.5},
    {["size"]=100000,["penalty"]=1.0},
};
--[[
Tertiary Stats get their scaling from id 21025
https://raw.githubusercontent.com/simulationcraft/simc/thewarwithin/engine/dbc/generated/item_scaling.inc
  { 21025,  0,    0.00000f,    0.00000f,    0.00000f,    0.00000f },
  { 21025,  1,    0.50000f,    0.50000f,    0.00000f,    0.00000f },
  { 21025,  2,   10.00000f,   10.00000f,    0.00000f,    0.00000f },
  { 21025,  3,   15.00000f,   14.00000f,    0.00000f,    0.00000f },
  { 21025,  4,   20.00000f,   17.00000f,    0.00000f,    0.00000f },
  { 21025,  5,   25.00000f,   19.00000f,    0.00000f,    0.00000f },
  { 21025,  6,  100.00000f,   49.00000f,    0.00000f,    0.00000f },
]]
addon.tsv.TertStatBrackets = {
    {["size"]=10,["penalty"]=0},
    {["size"]=5,["penalty"]=0.2},
    {["size"]=5,["penalty"]=0.4},
    {["size"]=80,["penalty"]=0.6},
    {["size"]=100000,["penalty"]=1.0},
};

--penalty is the % penalty currently
--trueRating is how much stat you effectively have after accounting for diminishes
--bracketRating is how far into the current bracket you are.
--bracketMaxRating is the total rating in your current bracket
function addon.tsv:GetStatDiminishBracket(statId,amount)
    local stat = statIdMap[statId];
    if ( not stat ) then
        return;
    end

    local rating = addon[stat.rating];
    local conversionFactor = addon[stat.conversionFactor];
    local amount = amount or 0;
    local bracket = addon.tsv[stat.bracket];

    local percent = (rating+amount) / conversionFactor;
    local bracket_rating = 0;
    local bracket_max_rating = 0;
    local bracket_penalty = 0;
    local bracket_next_penalty = 0.1;
    local true_rating = 0;

    for i,bracket in ipairs(bracket) do
        if ( percent < bracket.size ) then
            bracket_rating = math.floor(0.5+percent * conversionFactor);
            bracket_max_rating = math.floor(0.5+bracket.size * conversionFactor);
            bracket_penalty = bracket.penalty;
            bracket_next_penalty = self.StatBrackets[i+1] and self.StatBrackets[i+1].penalty or 1;
            true_rating = true_rating + (percent * conversionFactor * (1.0 - bracket.penalty) );
            break;
        else
            true_rating = true_rating + (bracket.size * conversionFactor * (1.0 - bracket.penalty) );
        end
        percent = percent - bracket.size;
    end

    true_rating = math.floor(0.005+100*true_rating)/100;
    return true_rating, bracket_penalty, bracket_next_penalty, bracket_rating, bracket_max_rating
end


function addon.tsv:RecalculateTrueStatRatings() 
    addon.BaseCritRating = GetCombatRating(CR_CRIT_SPELL);
    addon.BaseHasteRating = GetCombatRating(CR_HASTE_SPELL);
    addon.BaseMasteryRating = GetCombatRating(CR_MASTERY);
    addon.BaseVersatilityRating = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	addon.BaseLeechRating = GetCombatRating(CR_LIFESTEAL);
	addon.BaseAvoidanceRating = GetCombatRating(CR_AVOIDANCE);
	addon.BaseSpeedRating = GetCombatRating(CR_SPEED);
    
    addon.TrueStatInfo = addon.TrueStatInfo or {};
    for statId,stat in pairs(statIdMap) do 
        local true_rating, bracket_penalty, bracket_next_penalty, bracket_rating, bracket_max_rating = self:GetStatDiminishBracket(statId);
        addon.TrueStatInfo[statId] = {
            bracketPenalty = bracket_penalty,
            bracketNextPenalty = bracket_next_penalty,
            bracketRating = bracket_rating,
            bracketMaxRating = bracket_max_rating,
            trueRating = true_rating,
            baseRating = addon[stat.rating],
            conversionFactor = addon[stat.conversionFactor]
        };
    end
end

function addon.tsv:GetTrueStatRatingAdded(statId,amountStr)
    local amountStr = amountStr:gsub(",",""); --numbers are big enough to have commas now
    local amount = tonumber(amountStr);
    local currentTrueRating = addon.TrueStatInfo[statId].trueRating;
    local addedTrueRating = self:GetStatDiminishBracket(statId,amount);
    local diff = addedTrueRating - currentTrueRating;
    diff = math.floor(0.005+100*diff)/100;
    return diff;
end
