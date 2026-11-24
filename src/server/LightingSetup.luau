-- Makes the whole game dark. The lobby has its own lamps, and the seeker's
-- flashlight is the only light in the arena.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local LightingSetup = {}

function LightingSetup.apply()
	Lighting.ClockTime = 0
	Lighting.Brightness = 0
	Lighting.Ambient = Config.DarkAmbient
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.GlobalShadows = true
end

return LightingSetup
