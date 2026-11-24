-- Game settings for Flashlight Tag. Change numbers here to tune the game.
-- Lives in ReplicatedStorage > Shared > Config, so server and client can both read it.

local Config = {
	-- Players needed before a round starts.
	-- To test alone in Studio: Test tab > Clients and Servers > 2 players > Start.
	MinPlayers = 2,

	-- Times, in seconds
	IntermissionTime = 15, -- waiting in the lobby between rounds
	HideTime = 20, -- hiders run and hide, seeker waits in the lobby
	SeekTime = 150, -- seeker hunts with the flashlight
	ResultsTime = 6, -- who won is shown for this long

	-- How close (in studs) the seeker has to get to tag a hider
	TagDistance = 5,

	-- Walk speeds
	SeekerSpeed = 18,
	HiderSpeed = 16,

	-- The seeker's flashlight
	Flashlight = {
		Range = 45,
		Angle = 50,
		Brightness = 4,
		Color = Color3.fromRGB(255, 244, 214),
	},

	-- How dark it is. Black is pitch dark; a little above black lets players
	-- just barely make out shapes.
	DarkAmbient = Color3.fromRGB(12, 12, 18),
}

return Config
