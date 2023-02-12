local MDT = MDT
local L = MDT.L
local dungeonIndex = 53
MDT.dungeonList[dungeonIndex] = L["Azjol-Nerub"]
MDT.mapInfo[dungeonIndex] = {
  viewportPositionOverrides = {
    [2] = {
      zoomScale = 1.2999999523163;
      horizontalPan = 88.820487488064;
      verticalPan = 34.121367896864;
    };
    [3] = {
      zoomScale = 1.5999999046326;
      horizontalPan = 133.11897835951;
      verticalPan = 95.036627557383;
    };
  }
};

MDT.dungeonMaps[dungeonIndex] = {
  [0] = "azjolnerub",
  [1] = "azjolnerub3_",
  [2] = "azjolnerub2_",
  [3] = "azjolnerub1_",
}

MDT.dungeonSubLevels[dungeonIndex] = {
  [1] = L["The Brood Pit"],
  [2] = L["Hadronox's Lair"],
  [3] = L["The Gilded Gate"],
}

MDT.dungeonTotalCount[dungeonIndex] = { normal = 300, teeming = 1000, teemingEnabled = true }

MDT.mapPOIs[dungeonIndex] = {
  [3] = {
    [1] = {
      ["template"] = "MapLinkPinTemplate";
      ["type"] = "mapLink";
      ["target"] = 2;
      ["direction"] = 1;
      ["connectionIndex"] = 1;
      ["y"] = -291.2;
      ["x"] = 191.7;
    };
  };
  [2] = {
    [1] = {
      ["template"] = "MapLinkPinTemplate";
      ["type"] = "mapLink";
      ["target"] = 1;
      ["direction"] = -1;
      ["connectionIndex"] = 1;
      ["y"] = -334.3;
      ["x"] = 406.7;
    };
    [2] = {
      ["template"] = "MapLinkPinTemplate";
      ["type"] = "mapLink";
      ["target"] = 3;
      ["direction"] = 1;
      ["connectionIndex"] = 2;
      ["y"] = -178.1;
      ["x"] = 506.9;
    };
  };
  [1] = {
    [1] = {
      ["template"] = "MapLinkPinTemplate";
      ["type"] = "mapLink";
      ["target"] = 2;
      ["direction"] = -1;
      ["connectionIndex"] = 1;
      ["y"] = -111.1;
      ["x"] = 555.3;
    };
  };
};

MDT.dungeonEnemies[dungeonIndex] = {
  [1] = {
    ["name"] = "Anub'ar Warrior";
    ["id"] = 28732;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 23567;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -401.5;
        ["x"] = 149.1;
        ["g"] = 1;
        ["patrol"] = {
          [1] = {
            ["y"] = -203.2;
            ["x"] = 224.5;
          };
          [2] = {
            ["y"] = -211.4;
            ["x"] = 205.9;
          };
          [3] = {
            ["y"] = -409.1;
            ["x"] = 154.6;
          };
        };
      };
      [2] = {
        ["sublevel"] = 1;
        ["y"] = -206.4;
        ["x"] = 259.8;
        ["g"] = 2;
      };
      [3] = {
        ["sublevel"] = 1;
        ["y"] = -243.5;
        ["x"] = 358.6;
        ["g"] = 3;
      };
      [4] = {
        ["sublevel"] = 1;
        ["y"] = -310.3;
        ["x"] = 356.2;
        ["g"] = 4;
      };
    };
  };
  [2] = {
    ["name"] = "Anub'ar Webspinner";
    ["id"] = 29335;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 23565;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -407.5;
        ["x"] = 165.5;
        ["g"] = 1;
      };
    };
  };
  [3] = {
    ["name"] = "Skittering Swarmer";
    ["id"] = 28735;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 25656;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -202;
        ["x"] = 273.6;
        ["g"] = 2;
      };
    };
  };
  [4] = {
    ["name"] = "Anub'ar Skirmisher";
    ["id"] = 28734;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 25237;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -217.1;
        ["x"] = 269.2;
        ["g"] = 2;
      };
      [2] = {
        ["sublevel"] = 1;
        ["y"] = -194.5;
        ["x"] = 331;
        ["g"] = 5;
      };
      [3] = {
        ["sublevel"] = 1;
        ["y"] = -258.2;
        ["x"] = 358.8;
        ["g"] = 3;
      };
    };
  };
  [5] = {
    ["name"] = "Watcher Silthik";
    ["id"] = 28731;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 25729;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -205.4;
        ["x"] = 343;
        ["g"] = 5;
      };
    };
  };
  [6] = {
    ["name"] = "Anub'ar Shadowcaster";
    ["id"] = 28733;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 25258;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -190.1;
        ["x"] = 350.1;
        ["g"] = 5;
      };
      [2] = {
        ["sublevel"] = 1;
        ["y"] = -311.7;
        ["x"] = 343.8;
        ["g"] = 4;
      };
    };
  };
  [7] = {
    ["name"] = "Watcher Gashra";
    ["id"] = 28730;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 23568;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -250.8;
        ["x"] = 348.3;
        ["g"] = 3;
      };
    };
  };
  [8] = {
    ["name"] = "Watcher Narjil";
    ["id"] = 28729;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 23984;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -295.8;
        ["x"] = 346.9;
        ["g"] = 4;
      };
    };
  };
  [9] = {
    ["name"] = "Krik'thir the Gatewatcher";
    ["id"] = 28684;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 27394;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -251.3;
        ["x"] = 422.7;
      };
    };
  };
  [10] = {
    ["name"] = "Anub'ar Necromancer";
    ["id"] = 29064;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 23564;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -354;
        ["x"] = 496.4;
      };
    };
  };
  [11] = {
    ["name"] = "Anub'ar Crypt Fiend";
    ["id"] = 29063;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 3004;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -145.7;
        ["x"] = 498.8;
      };
    };
  };
  [12] = {
    ["name"] = "Anub'ar Crusher";
    ["id"] = 28922;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 27395;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -252.4;
        ["x"] = 634.7;
        ["g"] = 6;
      };
    };
  };
  [13] = {
    ["name"] = "Anub'ar Champion";
    ["id"] = 29117;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 25768;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -242.5;
        ["x"] = 634.2;
        ["g"] = 6;
      };
    };
  };
  [14] = {
    ["name"] = "Anub'ar Crypt Fiend";
    ["id"] = 29118;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 23102;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -263.3;
        ["x"] = 634.2;
        ["g"] = 6;
      };
    };
  };
  [15] = {
    ["name"] = "Anub'ar Champion";
    ["id"] = 29062;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 25768;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 1;
        ["y"] = -121.8;
        ["x"] = 524.4;
      };
    };
  };
  [16] = {
    ["name"] = "Hadronox";
    ["id"] = 28921;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 26776;
    ["creatureType"] = "Beast";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 2;
        ["y"] = -348.5;
        ["x"] = 444.6;
      };
    };
  };
  [17] = {
    ["name"] = "Skittering Swarmer";
    ["id"] = 32593;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 25656;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 2;
        ["y"] = -292.6;
        ["x"] = 395.3;
        ["g"] = 7;
      };
      [2] = {
        ["sublevel"] = 2;
        ["y"] = -291.6;
        ["x"] = 410.1;
        ["g"] = 7;
      };
      [3] = {
        ["sublevel"] = 2;
        ["y"] = -307.1;
        ["x"] = 407.6;
        ["g"] = 7;
      };
      [4] = {
        ["sublevel"] = 2;
        ["y"] = -286.5;
        ["x"] = 381.3;
        ["g"] = 7;
      };
      [5] = {
        ["sublevel"] = 2;
        ["y"] = -278.6;
        ["x"] = 392.6;
        ["g"] = 7;
      };
      [6] = {
        ["sublevel"] = 2;
        ["y"] = -315.7;
        ["x"] = 375.8;
        ["g"] = 7;
      };
      [7] = {
        ["sublevel"] = 2;
        ["y"] = -355.1;
        ["x"] = 390;
        ["g"] = 7;
      };
      [8] = {
        ["sublevel"] = 2;
        ["y"] = -381.3;
        ["x"] = 382.4;
        ["g"] = 7;
      };
      [9] = {
        ["sublevel"] = 2;
        ["y"] = -406.4;
        ["x"] = 387.8;
        ["g"] = 7;
      };
      [10] = {
        ["sublevel"] = 2;
        ["y"] = -408;
        ["x"] = 359.4;
        ["g"] = 7;
      };
      [11] = {
        ["sublevel"] = 2;
        ["y"] = -381.3;
        ["x"] = 346.3;
        ["g"] = 7;
      };
      [12] = {
        ["sublevel"] = 2;
        ["y"] = -372;
        ["x"] = 364.3;
        ["g"] = 7;
      };
      [13] = {
        ["sublevel"] = 2;
        ["y"] = -356.7;
        ["x"] = 348;
        ["g"] = 7;
      };
      [14] = {
        ["sublevel"] = 2;
        ["y"] = -365.4;
        ["x"] = 335.4;
        ["g"] = 7;
      };
      [15] = {
        ["sublevel"] = 2;
        ["y"] = -346.9;
        ["x"] = 339.8;
        ["g"] = 7;
      };
      [16] = {
        ["sublevel"] = 2;
        ["y"] = -345.5;
        ["x"] = 325;
        ["g"] = 7;
      };
      [17] = {
        ["sublevel"] = 2;
        ["y"] = -325.6;
        ["x"] = 329.1;
        ["g"] = 7;
      };
      [18] = {
        ["sublevel"] = 2;
        ["y"] = -305.6;
        ["x"] = 338.7;
        ["g"] = 7;
      };
      [19] = {
        ["sublevel"] = 2;
        ["y"] = -283.8;
        ["x"] = 344.7;
        ["g"] = 7;
      };
      [20] = {
        ["sublevel"] = 2;
        ["y"] = -264.9;
        ["x"] = 349.3;
        ["g"] = 7;
      };
      [21] = {
        ["sublevel"] = 2;
        ["y"] = -267.4;
        ["x"] = 376.1;
        ["g"] = 7;
      };
      [22] = {
        ["sublevel"] = 2;
        ["y"] = -282.1;
        ["x"] = 365.4;
        ["g"] = 7;
      };
      [23] = {
        ["sublevel"] = 2;
        ["y"] = -254.8;
        ["x"] = 361.9;
        ["g"] = 7;
      };
      [24] = {
        ["sublevel"] = 2;
        ["y"] = -253.5;
        ["x"] = 339.8;
        ["g"] = 7;
      };
      [25] = {
        ["sublevel"] = 2;
        ["y"] = -293.9;
        ["x"] = 329.9;
        ["g"] = 7;
      };
      [26] = {
        ["sublevel"] = 2;
        ["y"] = -331.3;
        ["x"] = 317.4;
        ["g"] = 7;
      };
      [27] = {
        ["sublevel"] = 2;
        ["y"] = -360.8;
        ["x"] = 372.8;
        ["g"] = 7;
      };
      [28] = {
        ["sublevel"] = 2;
        ["y"] = -404.2;
        ["x"] = 342.8;
        ["g"] = 7;
      };
      [29] = {
        ["sublevel"] = 2;
        ["y"] = -426.9;
        ["x"] = 389.7;
        ["g"] = 7;
      };
      [30] = {
        ["sublevel"] = 2;
        ["y"] = -402.9;
        ["x"] = 412.1;
        ["g"] = 7;
      };
      [31] = {
        ["sublevel"] = 2;
        ["y"] = -372.8;
        ["x"] = 404.2;
        ["g"] = 7;
      };
      [32] = {
        ["sublevel"] = 2;
        ["y"] = -335.7;
        ["x"] = 383.5;
        ["g"] = 7;
      };
      [33] = {
        ["sublevel"] = 2;
        ["y"] = -321.2;
        ["x"] = 386.2;
        ["g"] = 7;
      };
    };
  };
  [18] = {
    ["name"] = "Anub'ar Prime Guard";
    ["id"] = 29128;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 26194;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 3;
        ["y"] = -261.1;
        ["x"] = 424.4;
        ["g"] = 8;
      };
      [2] = {
        ["sublevel"] = 3;
        ["y"] = -280.8;
        ["x"] = 424.4;
        ["g"] = 8;
      };
    };
  };
  [19] = {
    ["name"] = "Anub'arak";
    ["id"] = 29120;
    ["count"] = 0;
    ["health"] = 12345;
    ["scale"] = 1;
    ["displayId"] = 27856;
    ["creatureType"] = "Undead";
    ["level"] = 60;
    ["clones"] = {
      [1] = {
        ["sublevel"] = 3;
        ["y"] = -271.6;
        ["x"] = 521.6;
      };
    };
  };
};
