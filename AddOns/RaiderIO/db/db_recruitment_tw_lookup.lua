--
-- Copyright (c) 2023 by Ludicrous Speed, LLC
-- All rights reserved.
--
local provider={name=...,data=3,region="tw",date="2023-12-05T21:41:32Z",numCharacters=30937,lookup={},recordSizeInBytes=2,encodingOrder={0,1,3}}
local F

-- chunk size: 32
F = function() provider.lookup[1] = "?\29?\29?\29?\29?\29?\29?\29?\29?\29?\29?\29?\29?\29?\29?\29?\29" end F()

F = nil
RaiderIO.AddProvider(provider)
