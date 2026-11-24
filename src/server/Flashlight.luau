-- Gives the seeker a flashlight: a spotlight on their head that points
-- wherever their character is facing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Flashlight = {}

local NAME = "Flashlight"

function Flashlight.give(player: Player)
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	if not head or head:FindFirstChild(NAME) then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = NAME
	attachment.Position = Vector3.new(0, 0, -0.6) -- just in front of the face

	local light = Instance.new("SpotLight")
	light.Face = Enum.NormalId.Front
	light.Range = Config.Flashlight.Range
	light.Angle = Config.Flashlight.Angle
	light.Brightness = Config.Flashlight.Brightness
	light.Color = Config.Flashlight.Color
	light.Shadows = true
	light.Parent = attachment

	-- A small glow around the seeker so they can see their own feet.
	local glow = Instance.new("PointLight")
	glow.Range = 6
	glow.Brightness = 0.4
	glow.Color = Config.Flashlight.Color
	glow.Parent = attachment

	attachment.Parent = head
end

function Flashlight.remove(player: Player)
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local existing = head and head:FindFirstChild(NAME)
	if existing then
		existing:Destroy()
	end
end

return Flashlight
