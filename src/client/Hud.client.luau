-- On-screen info for each player: what's happening, your role, and pop-up messages.
-- Lives in StarterPlayer > StarterPlayerScripts > Client > Hud in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "FlashlightTagHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false

local function makeLabel(name: string, position: UDim2, size: UDim2, textSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = position
	label.Size = size
	label.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	label.BackgroundTransparency = 0.35
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize
	label.TextWrapped = true
	label.Text = ""
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
	label.Parent = gui
	return label
end

local statusLabel = makeLabel("Status", UDim2.new(0.5, 0, 0, 10), UDim2.new(0, 420, 0, 40), 20)
local roleLabel = makeLabel("Role", UDim2.new(0.5, 0, 0, 56), UDim2.new(0, 260, 0, 32), 18)
local announceLabel = makeLabel("Announce", UDim2.new(0.5, 0, 0.3, 0), UDim2.new(0, 480, 0, 50), 26)
announceLabel.BackgroundTransparency = 1
announceLabel.TextStrokeTransparency = 0.4
announceLabel.Visible = false

gui.Parent = player:WaitForChild("PlayerGui")

local ROLE_TEXT = {
	Seeker = { "You are the SEEKER", Color3.fromRGB(255, 200, 60) },
	Hider = { "You are HIDING", Color3.fromRGB(110, 200, 255) },
	Caught = { "You were found", Color3.fromRGB(255, 110, 110) },
}

local function updateStatus()
	statusLabel.Text = ReplicatedStorage:GetAttribute("Status") or ""
end

local function updateRole()
	local role = player:GetAttribute("Role")
	local info = role and ROLE_TEXT[role]
	if info then
		roleLabel.Text = info[1]
		roleLabel.TextColor3 = info[2]
		roleLabel.Visible = true
	else
		roleLabel.Visible = false
	end
end

ReplicatedStorage:GetAttributeChangedSignal("Status"):Connect(updateStatus)
player:GetAttributeChangedSignal("Role"):Connect(updateRole)
updateStatus()
updateRole()

-- Pop-up messages like "Alex found Sam!"
local announceToken = 0
local announceEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Announce") :: RemoteEvent
announceEvent.OnClientEvent:Connect(function(text: string)
	announceToken += 1
	local myToken = announceToken
	announceLabel.Text = text
	announceLabel.TextTransparency = 0
	announceLabel.TextStrokeTransparency = 0.4
	announceLabel.Visible = true
	task.wait(2.5)
	if myToken ~= announceToken then
		return
	end
	local fade = TweenService:Create(announceLabel, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 })
	fade:Play()
	fade.Completed:Wait()
	if myToken == announceToken then
		announceLabel.Visible = false
	end
end)
