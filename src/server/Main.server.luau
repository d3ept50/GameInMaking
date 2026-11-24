-- Starts Flashlight Tag. Lives in ServerScriptService > Server > Main in Studio.

local LightingSetup = require(script.Parent.LightingSetup)
local MapBuilder = require(script.Parent.MapBuilder)
local RoundManager = require(script.Parent.RoundManager)

LightingSetup.apply()
local map = MapBuilder.build()
RoundManager.run(map)
