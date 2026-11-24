-- Runs the rounds of Flashlight Tag:
--   1. Wait in the lobby until enough players join, then count down.
--   2. Pick a random seeker. Hiders are sent into the dark arena to hide.
--   3. After the hide time, the seeker is sent in with a flashlight.
--   4. Getting close to a hider tags them and sends them back to the lobby.
--   5. Seeker wins if everyone is tagged. Hiders win if time runs out.
--
-- The server shares what's happening through attributes on ReplicatedStorage
-- ("Phase", "Status") and each player's "Role" attribute. The client HUD reads them.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Flashlight = require(script.Parent.Flashlight)
local MapBuilder = require(script.Parent.MapBuilder)

type Map = MapBuilder.Map

local RoundManager = {}

local DEFAULT_SPEED = 16

local announceEvent: RemoteEvent

local function setStatus(phase: string, text: string)
	ReplicatedStorage:SetAttribute("Phase", phase)
	ReplicatedStorage:SetAttribute("Status", text)
end

local function announce(text: string)
	announceEvent:FireAllClients(text)
end

local function formatTime(seconds: number): string
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

local function getHumanoid(player: Player): Humanoid?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		return humanoid
	end
	return nil
end

local function getRoot(player: Player): BasePart?
	if not getHumanoid(player) then
		return nil
	end
	return (player.Character :: Model):FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function teleport(player: Player, cframe: CFrame)
	local character = player.Character
	if character and getHumanoid(player) then
		character:PivotTo(cframe)
	end
end

local function setSpeed(player: Player, speed: number)
	local humanoid = getHumanoid(player)
	if humanoid then
		humanoid.WalkSpeed = speed
	end
end

local function shuffled<T>(list: { T }): { T }
	local copy = table.clone(list)
	for i = #copy, 2, -1 do
		local j = math.random(i)
		copy[i], copy[j] = copy[j], copy[i]
	end
	return copy
end

local function countHiders(hiders: { [Player]: boolean }): number
	local count = 0
	for _ in hiders do
		count += 1
	end
	return count
end

local function playRound(map: Map)
	-- Everyone who is alive right now plays
	local roundPlayers = {}
	for _, player in Players:GetPlayers() do
		if getRoot(player) then
			table.insert(roundPlayers, player)
		end
	end
	if #roundPlayers < Config.MinPlayers then
		return
	end

	local seeker = roundPlayers[math.random(#roundPlayers)]
	local hiders: { [Player]: boolean } = {}
	for _, player in roundPlayers do
		if player ~= seeker then
			hiders[player] = true
			player:SetAttribute("Role", "Hider")
		end
	end
	seeker:SetAttribute("Role", "Seeker")

	local phase = "Hiding"
	local roundOver = false
	local winner: string? = nil
	local connections: { RBXScriptConnection } = {}

	local function catch(player: Player, taggedBySeeker: boolean)
		if not hiders[player] then
			return
		end
		hiders[player] = nil
		player:SetAttribute("Role", "Caught")
		if taggedBySeeker then
			teleport(player, map.lobbySpawn)
			setSpeed(player, DEFAULT_SPEED)
			announce(`{seeker.DisplayName} found {player.DisplayName}!`)
		else
			announce(`{player.DisplayName} is out!`)
		end
	end

	-- Players leaving or dying mid-round
	table.insert(
		connections,
		Players.PlayerRemoving:Connect(function(player)
			if player == seeker then
				roundOver = true
				winner = "Hiders"
				announce("The seeker left the game!")
			elseif hiders[player] then
				hiders[player] = nil
			end
		end)
	)
	for _, player in roundPlayers do
		local humanoid = getHumanoid(player)
		if humanoid and player ~= seeker then
			table.insert(
				connections,
				humanoid.Died:Connect(function()
					catch(player, false)
				end)
			)
		end
	end
	-- If the seeker resets during the hunt, put them back in with their flashlight
	table.insert(
		connections,
		seeker.CharacterAdded:Connect(function(character)
			character:WaitForChild("HumanoidRootPart")
			task.wait(0.1)
			if phase == "Seeking" and not roundOver then
				teleport(seeker, map.seekerSpawn)
				setSpeed(seeker, Config.SeekerSpeed)
				Flashlight.give(seeker)
			end
		end)
	)

	-- Send hiders into the dark
	local spawns = shuffled(map.hiderSpawns)
	local index = 0
	for player in hiders do
		index += 1
		teleport(player, spawns[(index - 1) % #spawns + 1])
		setSpeed(player, Config.HiderSpeed)
	end
	announce(`{seeker.DisplayName} is the seeker!`)

	-- Hide phase: the seeker waits in the lobby
	for secondsLeft = Config.HideTime, 1, -1 do
		if roundOver or next(hiders) == nil then
			break
		end
		setStatus("Hiding", `Hide! The seeker comes in {secondsLeft}`)
		task.wait(1)
	end

	-- Seek phase
	if not roundOver and next(hiders) ~= nil then
		phase = "Seeking"
		teleport(seeker, map.seekerSpawn)
		setSpeed(seeker, Config.SeekerSpeed)
		Flashlight.give(seeker)
		announce("Ready or not, here they come!")

		local tagCheck = RunService.Heartbeat:Connect(function()
			local seekerRoot = getRoot(seeker)
			if not seekerRoot then
				return
			end
			for player in hiders do
				local root = getRoot(player)
				if root and (root.Position - seekerRoot.Position).Magnitude <= Config.TagDistance then
					catch(player, true)
				end
			end
		end)
		table.insert(connections, tagCheck)

		local deadline = os.clock() + Config.SeekTime
		while not roundOver do
			local secondsLeft = math.ceil(deadline - os.clock())
			if next(hiders) == nil then
				winner = "Seeker"
				break
			elseif secondsLeft <= 0 then
				winner = "Hiders"
				break
			end
			setStatus("Seeking", `{countHiders(hiders)} still hiding · {formatTime(secondsLeft)}`)
			task.wait(0.25)
		end
	elseif next(hiders) == nil and not roundOver then
		-- Every hider left or died before the seeker came in
		winner = "Seeker"
	end

	phase = "Results"
	for _, connection in connections do
		connection:Disconnect()
	end
	Flashlight.remove(seeker)

	-- Show who won
	if winner == "Seeker" then
		setStatus("Results", `{seeker.DisplayName} found everyone! Seeker wins!`)
	else
		local survivors = {}
		for player in hiders do
			table.insert(survivors, player.DisplayName)
		end
		if #survivors > 0 then
			setStatus("Results", `Hiders win! Never found: {table.concat(survivors, ", ")}`)
		else
			setStatus("Results", "Hiders win!")
		end
	end

	-- Everyone back to the lobby
	for _, player in roundPlayers do
		if player.Parent then
			player:SetAttribute("Role", nil)
			teleport(player, map.lobbySpawn)
			setSpeed(player, DEFAULT_SPEED)
		end
	end

	task.wait(Config.ResultsTime)
end

function RoundManager.run(map: Map)
	local remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	announceEvent = Instance.new("RemoteEvent")
	announceEvent.Name = "Announce"
	announceEvent.Parent = remotes
	remotes.Parent = ReplicatedStorage

	local function enoughPlayers(): boolean
		return #Players:GetPlayers() >= Config.MinPlayers
	end

	while true do
		while not enoughPlayers() do
			setStatus("Waiting", `Waiting for players ({#Players:GetPlayers()}/{Config.MinPlayers})`)
			task.wait(1)
		end

		local ready = true
		for secondsLeft = Config.IntermissionTime, 1, -1 do
			if not enoughPlayers() then
				ready = false
				break
			end
			setStatus("Intermission", `Round starts in {secondsLeft}`)
			task.wait(1)
		end

		if ready then
			playRound(map)
		end
	end
end

return RoundManager
