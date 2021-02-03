local spell_effects = {
  [1]={["ID"]=1,["SpellID"]=1,["EffectIndex"]=0,["Effect"]=1,["Points"]=350,["TargetType"]=24,["Flags"]=1,["Period"]=0},
  [2]={["ID"]=2,["SpellID"]=2,["EffectIndex"]=0,["Effect"]=19,["Points"]=0.2,["TargetType"]=22,["Flags"]=1,["Period"]=2},
  [3]={["ID"]=3,["SpellID"]=3,["EffectIndex"]=0,["Effect"]=2,["Points"]=45.2,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [4]={["ID"]=4,["SpellID"]=3,["EffectIndex"]=1,["Effect"]=1,["Points"]=90.4,["TargetType"]=3,["Flags"]=0,["Period"]=0},
  [5]={["ID"]=7,["SpellID"]=4,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [6]={["ID"]=8,["SpellID"]=4,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [7]={["ID"]=9,["SpellID"]=5,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [8]={["ID"]=10,["SpellID"]=6,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [9]={["ID"]=11,["SpellID"]=7,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [10]={["ID"]=12,["SpellID"]=8,["EffectIndex"]=0,["Effect"]=1,["Points"]=10,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [11]={["ID"]=13,["SpellID"]=9,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.05,["TargetType"]=6,["Flags"]=0,["Period"]=0},
  [12]={["ID"]=14,["SpellID"]=10,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.2,["TargetType"]=3,["Flags"]=0,["Period"]=0},
  [13]={["ID"]=15,["SpellID"]=10,["EffectIndex"]=1,["Effect"]=7,["Points"]=0.03,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [14]={["ID"]=16,["SpellID"]=10,["EffectIndex"]=2,["Effect"]=8,["Points"]=0.01,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [15]={["ID"]=17,["SpellID"]=11,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [16]={["ID"]=18,["SpellID"]=12,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.2,["TargetType"]=6,["Flags"]=1,["Period"]=0},
  [17]={["ID"]=19,["SpellID"]=13,["EffectIndex"]=0,["Effect"]=2,["Points"]=10,["TargetType"]=2,["Flags"]=0,["Period"]=0},
  [18]={["ID"]=20,["SpellID"]=14,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.1,["TargetType"]=6,["Flags"]=1,["Period"]=0},
  [19]={["ID"]=21,["SpellID"]=15,["EffectIndex"]=0,["Effect"]=1,["Points"]=0.5,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [20]={["ID"]=22,["SpellID"]=16,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [21]={["ID"]=23,["SpellID"]=17,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [22]={["ID"]=24,["SpellID"]=17,["EffectIndex"]=1,["Effect"]=2,["Points"]=100,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [23]={["ID"]=25,["SpellID"]=17,["EffectIndex"]=2,["Effect"]=0,["Points"]=0,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [24]={["ID"]=26,["SpellID"]=18,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.2,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [25]={["ID"]=27,["SpellID"]=18,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.2,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [26]={["ID"]=28,["SpellID"]=18,["EffectIndex"]=2,["Effect"]=3,["Points"]=0.2,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [27]={["ID"]=29,["SpellID"]=19,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [28]={["ID"]=30,["SpellID"]=20,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.7,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [29]={["ID"]=31,["SpellID"]=21,["EffectIndex"]=0,["Effect"]=8,["Points"]=0.25,["TargetType"]=6,["Flags"]=1,["Period"]=0},
  [30]={["ID"]=32,["SpellID"]=22,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.9,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [31]={["ID"]=33,["SpellID"]=22,["EffectIndex"]=1,["Effect"]=7,["Points"]=0.1,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [32]={["ID"]=34,["SpellID"]=23,["EffectIndex"]=0,["Effect"]=10,["Points"]=11,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [33]={["ID"]=35,["SpellID"]=24,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.8,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [34]={["ID"]=36,["SpellID"]=24,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.2,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [35]={["ID"]=37,["SpellID"]=25,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [36]={["ID"]=38,["SpellID"]=25,["EffectIndex"]=1,["Effect"]=12,["Points"]=0.2,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [37]={["ID"]=39,["SpellID"]=26,["EffectIndex"]=0,["Effect"]=4,["Points"]=1,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [38]={["ID"]=40,["SpellID"]=26,["EffectIndex"]=1,["Effect"]=18,["Points"]=0.2,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [39]={["ID"]=41,["SpellID"]=27,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [40]={["ID"]=42,["SpellID"]=28,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [41]={["ID"]=43,["SpellID"]=29,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [42]={["ID"]=44,["SpellID"]=30,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [43]={["ID"]=45,["SpellID"]=31,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [44]={["ID"]=46,["SpellID"]=32,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [45]={["ID"]=47,["SpellID"]=33,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [46]={["ID"]=48,["SpellID"]=34,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [47]={["ID"]=49,["SpellID"]=35,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [48]={["ID"]=50,["SpellID"]=36,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [49]={["ID"]=51,["SpellID"]=37,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [50]={["ID"]=52,["SpellID"]=38,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [51]={["ID"]=53,["SpellID"]=39,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [52]={["ID"]=54,["SpellID"]=40,["EffectIndex"]=0,["Effect"]=1,["Points"]=1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [53]={["ID"]=55,["SpellID"]=41,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.25,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [54]={["ID"]=56,["SpellID"]=42,["EffectIndex"]=0,["Effect"]=16,["Points"]=0.1,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [55]={["ID"]=57,["SpellID"]=43,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.25,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [56]={["ID"]=58,["SpellID"]=43,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.2,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [57]={["ID"]=59,["SpellID"]=44,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [58]={["ID"]=60,["SpellID"]=44,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.25,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [59]={["ID"]=61,["SpellID"]=45,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [60]={["ID"]=62,["SpellID"]=45,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.25,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [61]={["ID"]=63,["SpellID"]=46,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.1,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [62]={["ID"]=64,["SpellID"]=46,["EffectIndex"]=1,["Effect"]=14,["Points"]=-0.1,["TargetType"]=16,["Flags"]=0,["Period"]=0},
  [63]={["ID"]=65,["SpellID"]=47,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.2,["TargetType"]=6,["Flags"]=0,["Period"]=0},
  [64]={["ID"]=66,["SpellID"]=48,["EffectIndex"]=0,["Effect"]=10,["Points"]=0,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [65]={["ID"]=67,["SpellID"]=48,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.2,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [66]={["ID"]=68,["SpellID"]=49,["EffectIndex"]=0,["Effect"]=14,["Points"]=0.33,["TargetType"]=17,["Flags"]=0,["Period"]=0},
  [67]={["ID"]=69,["SpellID"]=50,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [68]={["ID"]=70,["SpellID"]=51,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [69]={["ID"]=71,["SpellID"]=52,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.3,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [70]={["ID"]=72,["SpellID"]=53,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.1,["TargetType"]=7,["Flags"]=1,["Period"]=2},
  [71]={["ID"]=73,["SpellID"]=53,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.2,["TargetType"]=7,["Flags"]=1,["Period"]=2},
  [72]={["ID"]=74,["SpellID"]=54,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.9,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [73]={["ID"]=75,["SpellID"]=54,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.9,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [74]={["ID"]=76,["SpellID"]=55,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [75]={["ID"]=77,["SpellID"]=56,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.25,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [76]={["ID"]=78,["SpellID"]=57,["EffectIndex"]=0,["Effect"]=7,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [77]={["ID"]=79,["SpellID"]=58,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.7,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [78]={["ID"]=80,["SpellID"]=59,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [79]={["ID"]=81,["SpellID"]=60,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.4,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [80]={["ID"]=82,["SpellID"]=61,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [81]={["ID"]=83,["SpellID"]=62,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.3,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [82]={["ID"]=84,["SpellID"]=63,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [83]={["ID"]=85,["SpellID"]=63,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.2,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [84]={["ID"]=86,["SpellID"]=64,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [85]={["ID"]=87,["SpellID"]=65,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.65,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [86]={["ID"]=88,["SpellID"]=66,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=13,["Flags"]=1,["Period"]=0},
  [87]={["ID"]=89,["SpellID"]=67,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [88]={["ID"]=90,["SpellID"]=68,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.2,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [89]={["ID"]=91,["SpellID"]=68,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.8,["TargetType"]=15,["Flags"]=0,["Period"]=0},
  [90]={["ID"]=92,["SpellID"]=23,["EffectIndex"]=1,["Effect"]=7,["Points"]=0.1,["TargetType"]=11,["Flags"]=0,["Period"]=0},
  [91]={["ID"]=95,["SpellID"]=69,["EffectIndex"]=0,["Effect"]=1,["Points"]=50,["TargetType"]=1,["Flags"]=1,["Period"]=2},
  [92]={["ID"]=96,["SpellID"]=69,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.2,["TargetType"]=1,["Flags"]=1,["Period"]=2},
  [93]={["ID"]=97,["SpellID"]=69,["EffectIndex"]=2,["Effect"]=1,["Points"]=50,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [94]={["ID"]=98,["SpellID"]=69,["EffectIndex"]=3,["Effect"]=3,["Points"]=0.2,["TargetType"]=0,["Flags"]=0,["Period"]=0},
  [95]={["ID"]=99,["SpellID"]=71,["EffectIndex"]=0,["Effect"]=2,["Points"]=0.3,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [96]={["ID"]=100,["SpellID"]=72,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [97]={["ID"]=101,["SpellID"]=72,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.4,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [98]={["ID"]=102,["SpellID"]=73,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=13,["Flags"]=1,["Period"]=0},
  [99]={["ID"]=103,["SpellID"]=74,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.4,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [100]={["ID"]=104,["SpellID"]=74,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.4,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [101]={["ID"]=105,["SpellID"]=75,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [102]={["ID"]=106,["SpellID"]=76,["EffectIndex"]=0,["Effect"]=3,["Points"]=2.25,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [103]={["ID"]=107,["SpellID"]=77,["EffectIndex"]=0,["Effect"]=19,["Points"]=0.2,["TargetType"]=6,["Flags"]=1,["Period"]=0},
  [104]={["ID"]=108,["SpellID"]=78,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.3,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [105]={["ID"]=109,["SpellID"]=79,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.2,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [106]={["ID"]=110,["SpellID"]=79,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.2,["TargetType"]=6,["Flags"]=1,["Period"]=0},
  [107]={["ID"]=111,["SpellID"]=80,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [108]={["ID"]=112,["SpellID"]=80,["EffectIndex"]=1,["Effect"]=7,["Points"]=0.4,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [109]={["ID"]=113,["SpellID"]=81,["EffectIndex"]=0,["Effect"]=15,["Points"]=3,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [110]={["ID"]=114,["SpellID"]=82,["EffectIndex"]=0,["Effect"]=16,["Points"]=0.25,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [111]={["ID"]=115,["SpellID"]=83,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [112]={["ID"]=116,["SpellID"]=84,["EffectIndex"]=0,["Effect"]=12,["Points"]=-1,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [113]={["ID"]=117,["SpellID"]=85,["EffectIndex"]=0,["Effect"]=14,["Points"]=-50,["TargetType"]=2,["Flags"]=0,["Period"]=0},
  [114]={["ID"]=118,["SpellID"]=86,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [115]={["ID"]=119,["SpellID"]=87,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [116]={["ID"]=120,["SpellID"]=2,["EffectIndex"]=1,["Effect"]=4,["Points"]=1,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [117]={["ID"]=121,["SpellID"]=88,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.3,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [118]={["ID"]=123,["SpellID"]=88,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.4,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [119]={["ID"]=124,["SpellID"]=89,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.4,["TargetType"]=5,["Flags"]=3,["Period"]=1},
  [120]={["ID"]=125,["SpellID"]=90,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.2,["TargetType"]=8,["Flags"]=0,["Period"]=0},
  [121]={["ID"]=126,["SpellID"]=91,["EffectIndex"]=0,["Effect"]=11,["Points"]=-0.6,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [122]={["ID"]=127,["SpellID"]=92,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.4,["TargetType"]=17,["Flags"]=3,["Period"]=1},
  [123]={["ID"]=128,["SpellID"]=93,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.2,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [124]={["ID"]=129,["SpellID"]=93,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.8,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [125]={["ID"]=130,["SpellID"]=94,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.3,["TargetType"]=15,["Flags"]=1,["Period"]=1},
  [126]={["ID"]=131,["SpellID"]=95,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [127]={["ID"]=132,["SpellID"]=95,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.3,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [128]={["ID"]=133,["SpellID"]=96,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.4,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [129]={["ID"]=134,["SpellID"]=96,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.2,["TargetType"]=5,["Flags"]=0,["Period"]=0},
  [130]={["ID"]=135,["SpellID"]=97,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.9,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [131]={["ID"]=136,["SpellID"]=98,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [132]={["ID"]=137,["SpellID"]=99,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.4,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [133]={["ID"]=138,["SpellID"]=100,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.4,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [134]={["ID"]=139,["SpellID"]=101,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [135]={["ID"]=140,["SpellID"]=101,["EffectIndex"]=1,["Effect"]=14,["Points"]=0.2,["TargetType"]=3,["Flags"]=0,["Period"]=0},
  [136]={["ID"]=141,["SpellID"]=102,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.3,["TargetType"]=13,["Flags"]=1,["Period"]=0},
  [137]={["ID"]=142,["SpellID"]=103,["EffectIndex"]=0,["Effect"]=12,["Points"]=1,["TargetType"]=22,["Flags"]=0,["Period"]=0},
  [138]={["ID"]=143,["SpellID"]=104,["EffectIndex"]=0,["Effect"]=2,["Points"]=0.9,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [139]={["ID"]=144,["SpellID"]=104,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.1,["TargetType"]=2,["Flags"]=0,["Period"]=0},
  [140]={["ID"]=145,["SpellID"]=105,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.1,["TargetType"]=6,["Flags"]=0,["Period"]=0},
  [141]={["ID"]=146,["SpellID"]=106,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.4,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [142]={["ID"]=147,["SpellID"]=107,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.4,["TargetType"]=7,["Flags"]=3,["Period"]=0},
  [143]={["ID"]=148,["SpellID"]=107,["EffectIndex"]=1,["Effect"]=20,["Points"]=0.3,["TargetType"]=3,["Flags"]=3,["Period"]=0},
  [144]={["ID"]=149,["SpellID"]=108,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.4,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [145]={["ID"]=150,["SpellID"]=108,["EffectIndex"]=1,["Effect"]=18,["Points"]=0.1,["TargetType"]=2,["Flags"]=2,["Period"]=0},
  [146]={["ID"]=151,["SpellID"]=109,["EffectIndex"]=0,["Effect"]=16,["Points"]=0.6,["TargetType"]=0,["Flags"]=1,["Period"]=0},
  [147]={["ID"]=152,["SpellID"]=110,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.4,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [148]={["ID"]=153,["SpellID"]=111,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [149]={["ID"]=154,["SpellID"]=112,["EffectIndex"]=0,["Effect"]=19,["Points"]=0.3,["TargetType"]=8,["Flags"]=3,["Period"]=0},
  [150]={["ID"]=155,["SpellID"]=113,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [151]={["ID"]=156,["SpellID"]=114,["EffectIndex"]=0,["Effect"]=2,["Points"]=0.6,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [152]={["ID"]=157,["SpellID"]=115,["EffectIndex"]=0,["Effect"]=1,["Points"]=0.5,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [153]={["ID"]=158,["SpellID"]=116,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [154]={["ID"]=159,["SpellID"]=117,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.4,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [155]={["ID"]=160,["SpellID"]=118,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [156]={["ID"]=161,["SpellID"]=119,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [157]={["ID"]=162,["SpellID"]=120,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.5,["TargetType"]=20,["Flags"]=1,["Period"]=0},
  [158]={["ID"]=163,["SpellID"]=121,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.5,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [159]={["ID"]=164,["SpellID"]=122,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.3,["TargetType"]=21,["Flags"]=1,["Period"]=3},
  [160]={["ID"]=165,["SpellID"]=123,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.3,["TargetType"]=14,["Flags"]=1,["Period"]=0},
  [161]={["ID"]=166,["SpellID"]=124,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [162]={["ID"]=167,["SpellID"]=125,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=20,["Flags"]=1,["Period"]=0},
  [163]={["ID"]=168,["SpellID"]=125,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.5,["TargetType"]=0,["Flags"]=0,["Period"]=1},
  [164]={["ID"]=169,["SpellID"]=126,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.2,["TargetType"]=14,["Flags"]=1,["Period"]=0},
  [165]={["ID"]=170,["SpellID"]=127,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [166]={["ID"]=171,["SpellID"]=128,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [167]={["ID"]=172,["SpellID"]=129,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.3,["TargetType"]=6,["Flags"]=1,["Period"]=0},
  [168]={["ID"]=173,["SpellID"]=129,["EffectIndex"]=1,["Effect"]=12,["Points"]=0.5,["TargetType"]=6,["Flags"]=0,["Period"]=1},
  [169]={["ID"]=174,["SpellID"]=130,["EffectIndex"]=0,["Effect"]=16,["Points"]=1,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [170]={["ID"]=175,["SpellID"]=131,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [171]={["ID"]=176,["SpellID"]=132,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [172]={["ID"]=177,["SpellID"]=132,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.25,["TargetType"]=15,["Flags"]=0,["Period"]=1},
  [173]={["ID"]=178,["SpellID"]=133,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [174]={["ID"]=179,["SpellID"]=133,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.75,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [175]={["ID"]=180,["SpellID"]=134,["EffectIndex"]=0,["Effect"]=14,["Points"]=0.25,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [176]={["ID"]=181,["SpellID"]=135,["EffectIndex"]=0,["Effect"]=3,["Points"]=3,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [177]={["ID"]=182,["SpellID"]=136,["EffectIndex"]=0,["Effect"]=7,["Points"]=1.5,["TargetType"]=3,["Flags"]=1,["Period"]=3},
  [178]={["ID"]=183,["SpellID"]=137,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.25,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [179]={["ID"]=184,["SpellID"]=138,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.3,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [180]={["ID"]=185,["SpellID"]=139,["EffectIndex"]=0,["Effect"]=3,["Points"]=4,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [181]={["ID"]=186,["SpellID"]=140,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [182]={["ID"]=187,["SpellID"]=140,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.1,["TargetType"]=17,["Flags"]=0,["Period"]=0},
  [183]={["ID"]=188,["SpellID"]=141,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.5,["TargetType"]=6,["Flags"]=0,["Period"]=0},
  [184]={["ID"]=189,["SpellID"]=142,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.7,["TargetType"]=10,["Flags"]=1,["Period"]=0},
  [185]={["ID"]=190,["SpellID"]=143,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.25,["TargetType"]=1,["Flags"]=0,["Period"]=2},
  [186]={["ID"]=191,["SpellID"]=144,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.75,["TargetType"]=22,["Flags"]=0,["Period"]=0},
  [187]={["ID"]=192,["SpellID"]=145,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [188]={["ID"]=193,["SpellID"]=146,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [189]={["ID"]=194,["SpellID"]=147,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.5,["TargetType"]=22,["Flags"]=0,["Period"]=0},
  [190]={["ID"]=195,["SpellID"]=148,["EffectIndex"]=0,["Effect"]=4,["Points"]=1.25,["TargetType"]=14,["Flags"]=1,["Period"]=0},
  [191]={["ID"]=196,["SpellID"]=149,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [192]={["ID"]=197,["SpellID"]=150,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [193]={["ID"]=198,["SpellID"]=151,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.2,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [194]={["ID"]=199,["SpellID"]=152,["EffectIndex"]=0,["Effect"]=4,["Points"]=2,["TargetType"]=22,["Flags"]=1,["Period"]=0},
  [195]={["ID"]=200,["SpellID"]=152,["EffectIndex"]=1,["Effect"]=12,["Points"]=0.5,["TargetType"]=22,["Flags"]=0,["Period"]=1},
  [196]={["ID"]=201,["SpellID"]=153,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [197]={["ID"]=202,["SpellID"]=154,["EffectIndex"]=0,["Effect"]=16,["Points"]=1,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [198]={["ID"]=203,["SpellID"]=155,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.75,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [199]={["ID"]=204,["SpellID"]=156,["EffectIndex"]=0,["Effect"]=14,["Points"]=0.4,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [200]={["ID"]=205,["SpellID"]=157,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.8,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [201]={["ID"]=206,["SpellID"]=158,["EffectIndex"]=0,["Effect"]=3,["Points"]=3,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [202]={["ID"]=207,["SpellID"]=159,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.25,["TargetType"]=7,["Flags"]=0,["Period"]=2},
  [203]={["ID"]=208,["SpellID"]=160,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [204]={["ID"]=209,["SpellID"]=161,["EffectIndex"]=0,["Effect"]=4,["Points"]=1,["TargetType"]=6,["Flags"]=1,["Period"]=0},
  [205]={["ID"]=210,["SpellID"]=161,["EffectIndex"]=1,["Effect"]=12,["Points"]=0.25,["TargetType"]=6,["Flags"]=0,["Period"]=0},
  [206]={["ID"]=211,["SpellID"]=162,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.5,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [207]={["ID"]=212,["SpellID"]=163,["EffectIndex"]=0,["Effect"]=3,["Points"]=4,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [208]={["ID"]=213,["SpellID"]=164,["EffectIndex"]=0,["Effect"]=7,["Points"]=2,["TargetType"]=11,["Flags"]=3,["Period"]=3},
  [209]={["ID"]=214,["SpellID"]=165,["EffectIndex"]=0,["Effect"]=3,["Points"]=3,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [210]={["ID"]=215,["SpellID"]=166,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=21,["Flags"]=1,["Period"]=0},
  [211]={["ID"]=216,["SpellID"]=166,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.5,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [212]={["ID"]=217,["SpellID"]=167,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [213]={["ID"]=218,["SpellID"]=168,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.5,["TargetType"]=3,["Flags"]=0,["Period"]=0},
  [214]={["ID"]=219,["SpellID"]=169,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.65,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [215]={["ID"]=220,["SpellID"]=169,["EffectIndex"]=1,["Effect"]=7,["Points"]=0.5,["TargetType"]=3,["Flags"]=3,["Period"]=3},
  [216]={["ID"]=221,["SpellID"]=170,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [217]={["ID"]=222,["SpellID"]=171,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [218]={["ID"]=223,["SpellID"]=172,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.2,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [219]={["ID"]=224,["SpellID"]=172,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.5,["TargetType"]=15,["Flags"]=0,["Period"]=0},
  [220]={["ID"]=225,["SpellID"]=173,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [221]={["ID"]=226,["SpellID"]=173,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.25,["TargetType"]=5,["Flags"]=0,["Period"]=0},
  [222]={["ID"]=227,["SpellID"]=174,["EffectIndex"]=0,["Effect"]=16,["Points"]=0.4,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [223]={["ID"]=228,["SpellID"]=175,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=19,["Flags"]=1,["Period"]=0},
  [224]={["ID"]=229,["SpellID"]=176,["EffectIndex"]=0,["Effect"]=14,["Points"]=0.25,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [225]={["ID"]=230,["SpellID"]=177,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [226]={["ID"]=231,["SpellID"]=178,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [227]={["ID"]=232,["SpellID"]=178,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.5,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [228]={["ID"]=233,["SpellID"]=179,["EffectIndex"]=0,["Effect"]=4,["Points"]=1,["TargetType"]=6,["Flags"]=1,["Period"]=0},
  [229]={["ID"]=234,["SpellID"]=179,["EffectIndex"]=1,["Effect"]=12,["Points"]=0.5,["TargetType"]=6,["Flags"]=0,["Period"]=0},
  [230]={["ID"]=235,["SpellID"]=180,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=20,["Flags"]=1,["Period"]=0},
  [231]={["ID"]=236,["SpellID"]=181,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [232]={["ID"]=237,["SpellID"]=182,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.5,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [233]={["ID"]=238,["SpellID"]=183,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [234]={["ID"]=239,["SpellID"]=184,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [235]={["ID"]=240,["SpellID"]=185,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [236]={["ID"]=241,["SpellID"]=186,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [237]={["ID"]=242,["SpellID"]=187,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.5,["TargetType"]=7,["Flags"]=3,["Period"]=2},
  [238]={["ID"]=243,["SpellID"]=188,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [239]={["ID"]=244,["SpellID"]=188,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.5,["TargetType"]=3,["Flags"]=0,["Period"]=0},
  [240]={["ID"]=245,["SpellID"]=189,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [241]={["ID"]=246,["SpellID"]=190,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [242]={["ID"]=247,["SpellID"]=191,["EffectIndex"]=0,["Effect"]=1,["Points"]=0.2,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [243]={["ID"]=248,["SpellID"]=191,["EffectIndex"]=1,["Effect"]=2,["Points"]=0.1,["TargetType"]=6,["Flags"]=1,["Period"]=0},
  [244]={["ID"]=249,["SpellID"]=192,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.6,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [245]={["ID"]=250,["SpellID"]=193,["EffectIndex"]=0,["Effect"]=3,["Points"]=3,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [246]={["ID"]=251,["SpellID"]=193,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.5,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [247]={["ID"]=252,["SpellID"]=194,["EffectIndex"]=0,["Effect"]=19,["Points"]=0.4,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [248]={["ID"]=253,["SpellID"]=194,["EffectIndex"]=1,["Effect"]=14,["Points"]=-0.2,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [249]={["ID"]=254,["SpellID"]=194,["EffectIndex"]=2,["Effect"]=3,["Points"]=0.2,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [250]={["ID"]=255,["SpellID"]=195,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.8,["TargetType"]=11,["Flags"]=3,["Period"]=1},
  [251]={["ID"]=256,["SpellID"]=196,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [252]={["ID"]=257,["SpellID"]=196,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.9,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [253]={["ID"]=258,["SpellID"]=196,["EffectIndex"]=2,["Effect"]=3,["Points"]=0.6,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [254]={["ID"]=259,["SpellID"]=196,["EffectIndex"]=3,["Effect"]=3,["Points"]=0.3,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [255]={["ID"]=260,["SpellID"]=197,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.5,["TargetType"]=8,["Flags"]=1,["Period"]=0},
  [256]={["ID"]=261,["SpellID"]=198,["EffectIndex"]=0,["Effect"]=13,["Points"]=-0.5,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [257]={["ID"]=262,["SpellID"]=198,["EffectIndex"]=1,["Effect"]=16,["Points"]=0.5,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [258]={["ID"]=263,["SpellID"]=199,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [259]={["ID"]=264,["SpellID"]=200,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [260]={["ID"]=265,["SpellID"]=200,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.5,["TargetType"]=3,["Flags"]=0,["Period"]=1},
  [261]={["ID"]=266,["SpellID"]=201,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [262]={["ID"]=267,["SpellID"]=202,["EffectIndex"]=0,["Effect"]=9,["Points"]=2,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [263]={["ID"]=268,["SpellID"]=203,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [264]={["ID"]=269,["SpellID"]=204,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [265]={["ID"]=270,["SpellID"]=204,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.5,["TargetType"]=3,["Flags"]=0,["Period"]=2},
  [266]={["ID"]=271,["SpellID"]=205,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.75,["TargetType"]=14,["Flags"]=1,["Period"]=0},
  [267]={["ID"]=272,["SpellID"]=206,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [268]={["ID"]=273,["SpellID"]=207,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.3,["TargetType"]=13,["Flags"]=1,["Period"]=0},
  [269]={["ID"]=274,["SpellID"]=208,["EffectIndex"]=0,["Effect"]=9,["Points"]=2,["TargetType"]=21,["Flags"]=1,["Period"]=0},
  [270]={["ID"]=275,["SpellID"]=209,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.5,["TargetType"]=21,["Flags"]=0,["Period"]=0},
  [271]={["ID"]=276,["SpellID"]=210,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [272]={["ID"]=277,["SpellID"]=211,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [273]={["ID"]=278,["SpellID"]=212,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=19,["Flags"]=1,["Period"]=0},
  [274]={["ID"]=279,["SpellID"]=213,["EffectIndex"]=0,["Effect"]=4,["Points"]=1,["TargetType"]=10,["Flags"]=1,["Period"]=0},
  [275]={["ID"]=280,["SpellID"]=214,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [276]={["ID"]=281,["SpellID"]=215,["EffectIndex"]=0,["Effect"]=3,["Points"]=3,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [277]={["ID"]=282,["SpellID"]=216,["EffectIndex"]=0,["Effect"]=10,["Points"]=3,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [278]={["ID"]=283,["SpellID"]=217,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [279]={["ID"]=284,["SpellID"]=218,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.5,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [280]={["ID"]=285,["SpellID"]=219,["EffectIndex"]=0,["Effect"]=4,["Points"]=2,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [281]={["ID"]=286,["SpellID"]=219,["EffectIndex"]=1,["Effect"]=14,["Points"]=-0.5,["TargetType"]=2,["Flags"]=0,["Period"]=0},
  [282]={["ID"]=287,["SpellID"]=220,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [283]={["ID"]=288,["SpellID"]=221,["EffectIndex"]=0,["Effect"]=10,["Points"]=1.5,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [284]={["ID"]=289,["SpellID"]=222,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.3,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [285]={["ID"]=290,["SpellID"]=222,["EffectIndex"]=1,["Effect"]=7,["Points"]=0.3,["TargetType"]=3,["Flags"]=3,["Period"]=2},
  [286]={["ID"]=291,["SpellID"]=223,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.1,["TargetType"]=23,["Flags"]=1,["Period"]=1},
  [287]={["ID"]=292,["SpellID"]=224,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [288]={["ID"]=293,["SpellID"]=225,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [289]={["ID"]=294,["SpellID"]=226,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [290]={["ID"]=295,["SpellID"]=227,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.3,["TargetType"]=20,["Flags"]=0,["Period"]=0},
  [291]={["ID"]=296,["SpellID"]=228,["EffectIndex"]=0,["Effect"]=3,["Points"]=10,["TargetType"]=23,["Flags"]=1,["Period"]=0},
  [292]={["ID"]=297,["SpellID"]=229,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.5,["TargetType"]=21,["Flags"]=0,["Period"]=0},
  [293]={["ID"]=298,["SpellID"]=230,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.5,["TargetType"]=24,["Flags"]=1,["Period"]=0},
  [294]={["ID"]=299,["SpellID"]=231,["EffectIndex"]=0,["Effect"]=14,["Points"]=1,["TargetType"]=20,["Flags"]=0,["Period"]=0},
  [295]={["ID"]=300,["SpellID"]=232,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.5,["TargetType"]=20,["Flags"]=0,["Period"]=3},
  [296]={["ID"]=301,["SpellID"]=233,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [297]={["ID"]=302,["SpellID"]=234,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.5,["TargetType"]=21,["Flags"]=0,["Period"]=0},
  [298]={["ID"]=303,["SpellID"]=235,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [299]={["ID"]=304,["SpellID"]=236,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.5,["TargetType"]=6,["Flags"]=0,["Period"]=2},
  [300]={["ID"]=305,["SpellID"]=237,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [301]={["ID"]=306,["SpellID"]=238,["EffectIndex"]=0,["Effect"]=9,["Points"]=2,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [302]={["ID"]=307,["SpellID"]=239,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [303]={["ID"]=308,["SpellID"]=240,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.25,["TargetType"]=13,["Flags"]=1,["Period"]=0},
  [304]={["ID"]=309,["SpellID"]=241,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [305]={["ID"]=310,["SpellID"]=241,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.5,["TargetType"]=5,["Flags"]=0,["Period"]=0},
  [306]={["ID"]=311,["SpellID"]=242,["EffectIndex"]=0,["Effect"]=4,["Points"]=0.5,["TargetType"]=2,["Flags"]=1,["Period"]=0},
  [307]={["ID"]=312,["SpellID"]=242,["EffectIndex"]=1,["Effect"]=14,["Points"]=0.75,["TargetType"]=2,["Flags"]=0,["Period"]=0},
  [308]={["ID"]=313,["SpellID"]=243,["EffectIndex"]=0,["Effect"]=9,["Points"]=0,["TargetType"]=7,["Flags"]=1,["Period"]=0},
  [309]={["ID"]=314,["SpellID"]=243,["EffectIndex"]=1,["Effect"]=14,["Points"]=-0.5,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [310]={["ID"]=315,["SpellID"]=244,["EffectIndex"]=0,["Effect"]=19,["Points"]=2,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [311]={["ID"]=316,["SpellID"]=244,["EffectIndex"]=1,["Effect"]=20,["Points"]=0.3,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [312]={["ID"]=317,["SpellID"]=244,["EffectIndex"]=2,["Effect"]=3,["Points"]=0.3,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [313]={["ID"]=318,["SpellID"]=245,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [314]={["ID"]=319,["SpellID"]=246,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [315]={["ID"]=320,["SpellID"]=247,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [316]={["ID"]=321,["SpellID"]=247,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.2,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [317]={["ID"]=322,["SpellID"]=248,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.3,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [318]={["ID"]=323,["SpellID"]=248,["EffectIndex"]=1,["Effect"]=7,["Points"]=0.15,["TargetType"]=3,["Flags"]=1,["Period"]=1},
  [319]={["ID"]=324,["SpellID"]=249,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [320]={["ID"]=325,["SpellID"]=249,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.5,["TargetType"]=3,["Flags"]=0,["Period"]=0},
  [321]={["ID"]=326,["SpellID"]=250,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.8,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [322]={["ID"]=327,["SpellID"]=251,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.2,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [323]={["ID"]=328,["SpellID"]=252,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=9,["Flags"]=1,["Period"]=0},
  [324]={["ID"]=329,["SpellID"]=252,["EffectIndex"]=1,["Effect"]=14,["Points"]=0.25,["TargetType"]=9,["Flags"]=0,["Period"]=0},
  [325]={["ID"]=330,["SpellID"]=253,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [326]={["ID"]=331,["SpellID"]=254,["EffectIndex"]=0,["Effect"]=16,["Points"]=1,["TargetType"]=22,["Flags"]=1,["Period"]=0},
  [327]={["ID"]=332,["SpellID"]=255,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.5,["TargetType"]=2,["Flags"]=0,["Period"]=0},
  [328]={["ID"]=333,["SpellID"]=256,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [329]={["ID"]=334,["SpellID"]=257,["EffectIndex"]=0,["Effect"]=10,["Points"]=1,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [330]={["ID"]=335,["SpellID"]=258,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [331]={["ID"]=336,["SpellID"]=258,["EffectIndex"]=1,["Effect"]=7,["Points"]=0.5,["TargetType"]=3,["Flags"]=3,["Period"]=3},
  [332]={["ID"]=337,["SpellID"]=259,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.3,["TargetType"]=3,["Flags"]=1,["Period"]=3},
  [333]={["ID"]=338,["SpellID"]=260,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=5,["Flags"]=1,["Period"]=3},
  [334]={["ID"]=339,["SpellID"]=261,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.5,["TargetType"]=2,["Flags"]=0,["Period"]=0},
  [335]={["ID"]=340,["SpellID"]=262,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [336]={["ID"]=341,["SpellID"]=263,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=11,["Flags"]=1,["Period"]=0},
  [337]={["ID"]=342,["SpellID"]=264,["EffectIndex"]=0,["Effect"]=3,["Points"]=3,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [338]={["ID"]=343,["SpellID"]=265,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=13,["Flags"]=1,["Period"]=0},
  [339]={["ID"]=344,["SpellID"]=266,["EffectIndex"]=0,["Effect"]=3,["Points"]=10,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [340]={["ID"]=345,["SpellID"]=267,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [341]={["ID"]=346,["SpellID"]=268,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.3,["TargetType"]=15,["Flags"]=0,["Period"]=0},
  [342]={["ID"]=347,["SpellID"]=269,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [343]={["ID"]=348,["SpellID"]=270,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.5,["TargetType"]=3,["Flags"]=0,["Period"]=0},
  [344]={["ID"]=349,["SpellID"]=271,["EffectIndex"]=0,["Effect"]=7,["Points"]=1,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [345]={["ID"]=350,["SpellID"]=272,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [346]={["ID"]=351,["SpellID"]=273,["EffectIndex"]=0,["Effect"]=12,["Points"]=-0.5,["TargetType"]=3,["Flags"]=0,["Period"]=0},
  [347]={["ID"]=352,["SpellID"]=274,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.2,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [348]={["ID"]=353,["SpellID"]=275,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.75,["TargetType"]=2,["Flags"]=0,["Period"]=0},
  [349]={["ID"]=354,["SpellID"]=276,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.25,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [350]={["ID"]=355,["SpellID"]=276,["EffectIndex"]=1,["Effect"]=7,["Points"]=0.5,["TargetType"]=5,["Flags"]=3,["Period"]=3},
  [351]={["ID"]=356,["SpellID"]=277,["EffectIndex"]=0,["Effect"]=12,["Points"]=1,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [352]={["ID"]=357,["SpellID"]=278,["EffectIndex"]=0,["Effect"]=14,["Points"]=0.5,["TargetType"]=5,["Flags"]=0,["Period"]=0},
  [353]={["ID"]=358,["SpellID"]=279,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.5,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [354]={["ID"]=359,["SpellID"]=280,["EffectIndex"]=0,["Effect"]=3,["Points"]=2.5,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [355]={["ID"]=360,["SpellID"]=281,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=5,["Flags"]=1,["Period"]=3},
  [356]={["ID"]=361,["SpellID"]=282,["EffectIndex"]=0,["Effect"]=3,["Points"]=10,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [357]={["ID"]=362,["SpellID"]=283,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.75,["TargetType"]=13,["Flags"]=1,["Period"]=0},
  [358]={["ID"]=363,["SpellID"]=284,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.5,["TargetType"]=22,["Flags"]=0,["Period"]=0},
  [359]={["ID"]=364,["SpellID"]=285,["EffectIndex"]=0,["Effect"]=14,["Points"]=0.5,["TargetType"]=7,["Flags"]=0,["Period"]=0},
  [360]={["ID"]=365,["SpellID"]=286,["EffectIndex"]=0,["Effect"]=12,["Points"]=0.5,["TargetType"]=2,["Flags"]=0,["Period"]=0},
  [361]={["ID"]=366,["SpellID"]=287,["EffectIndex"]=0,["Effect"]=14,["Points"]=-0.5,["TargetType"]=1,["Flags"]=0,["Period"]=0},
  [362]={["ID"]=367,["SpellID"]=288,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [363]={["ID"]=368,["SpellID"]=289,["EffectIndex"]=0,["Effect"]=7,["Points"]=1,["TargetType"]=5,["Flags"]=3,["Period"]=3},
  [364]={["ID"]=369,["SpellID"]=290,["EffectIndex"]=0,["Effect"]=3,["Points"]=1.5,["TargetType"]=5,["Flags"]=1,["Period"]=3},
  [365]={["ID"]=370,["SpellID"]=291,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=15,["Flags"]=1,["Period"]=3},
  [366]={["ID"]=371,["SpellID"]=292,["EffectIndex"]=0,["Effect"]=14,["Points"]=0.5,["TargetType"]=3,["Flags"]=0,["Period"]=0},
  [367]={["ID"]=372,["SpellID"]=292,["EffectIndex"]=1,["Effect"]=3,["Points"]=0.75,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [368]={["ID"]=373,["SpellID"]=293,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.6,["TargetType"]=15,["Flags"]=1,["Period"]=0},
  [369]={["ID"]=374,["SpellID"]=294,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=3,["Flags"]=1,["Period"]=0},
  [370]={["ID"]=375,["SpellID"]=295,["EffectIndex"]=0,["Effect"]=14,["Points"]=0.5,["TargetType"]=3,["Flags"]=0,["Period"]=2},
  [371]={["ID"]=376,["SpellID"]=296,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=17,["Flags"]=1,["Period"]=0},
  [372]={["ID"]=377,["SpellID"]=297,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [373]={["ID"]=378,["SpellID"]=297,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.3,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [374]={["ID"]=379,["SpellID"]=298,["EffectIndex"]=0,["Effect"]=3,["Points"]=1,["TargetType"]=21,["Flags"]=1,["Period"]=0},
  [375]={["ID"]=380,["SpellID"]=298,["EffectIndex"]=1,["Effect"]=4,["Points"]=0.3,["TargetType"]=1,["Flags"]=1,["Period"]=0},
  [376]={["ID"]=381,["SpellID"]=299,["EffectIndex"]=0,["Effect"]=3,["Points"]=2,["TargetType"]=5,["Flags"]=1,["Period"]=0},
  [377]={["ID"]=383,["SpellID"]=300,["EffectIndex"]=0,["Effect"]=7,["Points"]=0.05,["TargetType"]=23,["Flags"]=1,["Period"]=1},
  [378]={["ID"]=384,["SpellID"]=301,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.1,["TargetType"]=20,["Flags"]=0,["Period"]=0},
  [379]={["ID"]=385,["SpellID"]=302,["EffectIndex"]=0,["Effect"]=3,["Points"]=0.2,["TargetType"]=7,["Flags"]=1,["Period"]=2},
  [380]={["ID"]=386,["SpellID"]=302,["EffectIndex"]=1,["Effect"]=12,["Points"]=-0.2,["TargetType"]=7,["Flags"]=1,["Period"]=0}
}


function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        if key ~= '__orderedIndex' then
            table.insert( orderedIndex, key )
        end
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,#t.__orderedIndex do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

function print_table(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            if k ~= '__orderedIndex' then size = size + 1 end
        end

        local cur_index = 1
        for k,v in orderedPairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end


local new_table = {}
for _, effect in pairs(spell_effects) do
    local spellID = effect.SpellID
    local effects = new_table[spellID]

    if effects == nil then
        new_table[spellID] = {effect}
    else
        table.insert(new_table[spellID], effect)
    end
end

-- для spellID = 17 надо убрать эффект с типом = 0 и заменить в хиле points с 100 на 1
-- для spellID = 15 points = 1
-- spellId = 109 по описанию target = self
-- spellID = 125 по описанию target = random enemy. Пока удалю
-- spellID = 91, effect = 11. Вообще не работает
-- spellID = 104, effectID = 143. Почему-то хилит больше, чем есть в БД


for spellID, effects in pairs(new_table) do
  if spellID == 17 then
    for i, effect in pairs(effects) do
      if effect.Effect == 2 then
        effect.Points = 1
      end
    end
      for i, effect in pairs(effects) do
        if effect.Effect == 0 then
          table.remove(effects, i)
        end
      end


  elseif spellID == 15 then
    effects[1].Points = 1

  elseif spellID == 109 then
    for i, effect in pairs(effects) do
      if effect.TargetType == 0 then effect.TargetType = 1 end
    end
  elseif spellID == 104 then
    for i, effect in pairs(effects) do
      if effect.ID == 143 then effect.Points = 1 end
    end
  end
end

print_table(new_table)
