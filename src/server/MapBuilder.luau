-- Builds the lit lobby and the dark arena with hiding spots when the game starts.
--
-- Want to build your own map in Studio instead? Make a Model in Workspace named
-- "Arena" with:
--   * a Folder named "HiderSpawns" holding parts where hiders appear
--   * a Part named "SeekerSpawn" where the seeker appears
-- and/or a Model named "Lobby" with a SpawnLocation named "LobbySpawn".
-- If those exist, this script uses them and skips building its own.

local Workspace = game:GetService("Workspace")

local MapBuilder = {}

export type Map = {
	lobbySpawn: CFrame,
	seekerSpawn: CFrame,
	hiderSpawns: { CFrame },
}

-- Both are floating high above the default baseplate so they don't collide with it.
local LOBBY_ORIGIN = Vector3.new(0, 100, 0)
local ARENA_ORIGIN = Vector3.new(0, 100, 300)

local ARENA_SIZE = 120 -- width and depth, in studs
local WALL_HEIGHT = 16

local COLORS = {
	floor = Color3.fromRGB(70, 52, 40),
	wall = Color3.fromRGB(95, 95, 100),
	crate = Color3.fromRGB(120, 88, 55),
	closet = Color3.fromRGB(85, 60, 45),
	table = Color3.fromRGB(105, 75, 50),
	shelf = Color3.fromRGB(60, 60, 65),
	lobbyFloor = Color3.fromRGB(200, 200, 210),
	lobbyWall = Color3.fromRGB(150, 150, 165),
}

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- Position relative to the arena floor (y = 0 is the top of the floor).
local function arenaAt(x: number, y: number, z: number): CFrame
	return CFrame.new(ARENA_ORIGIN + Vector3.new(x, y, z))
end

-- A closet you can walk into: back, two sides and a roof. The open side faces `facing`.
local function buildCloset(parent: Instance, x: number, z: number, facing: Vector3)
	local model = Instance.new("Model")
	model.Name = "Closet"
	local base = CFrame.lookAt(ARENA_ORIGIN + Vector3.new(x, 0, z), ARENA_ORIGIN + Vector3.new(x, 0, z) + facing)
	local w, h, d = 5, 8, 4
	makePart(model, "Back", Vector3.new(w, h, 0.5), base * CFrame.new(0, h / 2, d / 2), COLORS.closet, Enum.Material.Wood)
	makePart(model, "Left", Vector3.new(0.5, h, d), base * CFrame.new(-w / 2, h / 2, 0), COLORS.closet, Enum.Material.Wood)
	makePart(model, "Right", Vector3.new(0.5, h, d), base * CFrame.new(w / 2, h / 2, 0), COLORS.closet, Enum.Material.Wood)
	makePart(model, "Roof", Vector3.new(w + 0.5, 0.5, d), base * CFrame.new(0, h, 0), COLORS.closet, Enum.Material.Wood)
	model.Parent = parent
end

-- A tall table you can crouch under.
local function buildTable(parent: Instance, x: number, z: number)
	local model = Instance.new("Model")
	model.Name = "Table"
	local top = 6.5
	makePart(model, "Top", Vector3.new(9, 0.6, 6), arenaAt(x, top, z), COLORS.table, Enum.Material.Wood)
	for _, offset in { Vector2.new(-4, -2.6), Vector2.new(4, -2.6), Vector2.new(-4, 2.6), Vector2.new(4, 2.6) } do
		makePart(model, "Leg", Vector3.new(0.5, top, 0.5), arenaAt(x + offset.X, top / 2, z + offset.Y), COLORS.table, Enum.Material.Wood)
	end
	model.Parent = parent
end

-- A pile of crates to duck behind.
local function buildCrates(parent: Instance, x: number, z: number)
	local model = Instance.new("Model")
	model.Name = "Crates"
	makePart(model, "Crate", Vector3.new(4, 4, 4), arenaAt(x, 2, z), COLORS.crate, Enum.Material.WoodPlanks)
	makePart(model, "Crate", Vector3.new(4, 4, 4), arenaAt(x + 4.2, 2, z + 0.5), COLORS.crate, Enum.Material.WoodPlanks)
	makePart(model, "Crate", Vector3.new(4, 4, 4), arenaAt(x + 2, 6, z + 0.2), COLORS.crate, Enum.Material.WoodPlanks)
	makePart(model, "Crate", Vector3.new(4, 4, 4), arenaAt(x + 0.5, 2, z + 4.2), COLORS.crate, Enum.Material.WoodPlanks)
	model.Parent = parent
end

local function buildArena(): Model
	local arena = Instance.new("Model")
	arena.Name = "Arena"

	local half = ARENA_SIZE / 2
	local structure = Instance.new("Folder")
	structure.Name = "Structure"
	structure.Parent = arena

	-- Floor, ceiling, outer walls
	makePart(structure, "Floor", Vector3.new(ARENA_SIZE, 1, ARENA_SIZE), arenaAt(0, -0.5, 0), COLORS.floor, Enum.Material.WoodPlanks)
	makePart(structure, "Ceiling", Vector3.new(ARENA_SIZE, 1, ARENA_SIZE), arenaAt(0, WALL_HEIGHT + 0.5, 0), COLORS.wall, Enum.Material.Concrete)
	makePart(structure, "Wall", Vector3.new(ARENA_SIZE, WALL_HEIGHT, 1), arenaAt(0, WALL_HEIGHT / 2, half), COLORS.wall, Enum.Material.Concrete)
	makePart(structure, "Wall", Vector3.new(ARENA_SIZE, WALL_HEIGHT, 1), arenaAt(0, WALL_HEIGHT / 2, -half), COLORS.wall, Enum.Material.Concrete)
	makePart(structure, "Wall", Vector3.new(1, WALL_HEIGHT, ARENA_SIZE), arenaAt(half, WALL_HEIGHT / 2, 0), COLORS.wall, Enum.Material.Concrete)
	makePart(structure, "Wall", Vector3.new(1, WALL_HEIGHT, ARENA_SIZE), arenaAt(-half, WALL_HEIGHT / 2, 0), COLORS.wall, Enum.Material.Concrete)

	-- Inside walls that split the room into corners and corridors
	makePart(structure, "InnerWall", Vector3.new(40, WALL_HEIGHT, 1), arenaAt(-40, WALL_HEIGHT / 2, -20), COLORS.wall, Enum.Material.Concrete)
	makePart(structure, "InnerWall", Vector3.new(40, WALL_HEIGHT, 1), arenaAt(40, WALL_HEIGHT / 2, 20), COLORS.wall, Enum.Material.Concrete)
	makePart(structure, "InnerWall", Vector3.new(1, WALL_HEIGHT, 40), arenaAt(20, WALL_HEIGHT / 2, -40), COLORS.wall, Enum.Material.Concrete)
	makePart(structure, "InnerWall", Vector3.new(1, WALL_HEIGHT, 30), arenaAt(-20, WALL_HEIGHT / 2, 45), COLORS.wall, Enum.Material.Concrete)

	-- Hiding spots
	local spots = Instance.new("Folder")
	spots.Name = "HidingSpots"
	spots.Parent = arena

	buildCloset(spots, -56, -50, Vector3.new(1, 0, 0))
	buildCloset(spots, 56, -10, Vector3.new(-1, 0, 0))
	buildCloset(spots, -10, -56, Vector3.new(0, 0, 1))
	buildCloset(spots, 30, 56, Vector3.new(0, 0, -1))
	buildCloset(spots, -40, 25, Vector3.new(0, 0, -1))

	buildCrates(spots, 6, 8)
	buildCrates(spots, -34, 32)
	buildCrates(spots, 34, -16)
	buildCrates(spots, -8, -42)
	buildCrates(spots, 48, 40)

	buildTable(spots, 0, 30)
	buildTable(spots, -36, 4)
	buildTable(spots, 40, -40)

	makePart(spots, "Shelf", Vector3.new(16, 10, 3), arenaAt(26, 5, 0), COLORS.shelf, Enum.Material.Metal)
	makePart(spots, "Shelf", Vector3.new(3, 10, 16), arenaAt(-8, 5, 46), COLORS.shelf, Enum.Material.Metal)
	makePart(spots, "Shelf", Vector3.new(16, 10, 3), arenaAt(-40, 5, -36), COLORS.shelf, Enum.Material.Metal)

	-- Glowing red exit signs for a bit of atmosphere (they glow but don't light the room)
	makePart(structure, "ExitSign", Vector3.new(4, 1.2, 0.2), arenaAt(0, 12, half - 0.6), Color3.fromRGB(255, 40, 40), Enum.Material.Neon)
	makePart(structure, "ExitSign", Vector3.new(4, 1.2, 0.2), arenaAt(0, 12, -half + 0.6), Color3.fromRGB(255, 40, 40), Enum.Material.Neon)

	-- Spawn points (invisible markers)
	local hiderSpawns = Instance.new("Folder")
	hiderSpawns.Name = "HiderSpawns"
	hiderSpawns.Parent = arena
	for _, spot in
		{
			Vector2.new(-50, 0),
			Vector2.new(50, 0),
			Vector2.new(0, -10),
			Vector2.new(0, 50),
			Vector2.new(-30, -40),
			Vector2.new(45, -50),
			Vector2.new(30, 30),
			Vector2.new(-45, 45),
		}
	do
		local marker = makePart(hiderSpawns, "HiderSpawn", Vector3.new(2, 1, 2), arenaAt(spot.X, 0.5, spot.Y), Color3.new(0, 1, 0))
		marker.Transparency = 1
		marker.CanCollide = false
		marker.CanQuery = false
		marker.CanTouch = false
	end

	local seekerSpawn = makePart(arena, "SeekerSpawn", Vector3.new(2, 1, 2), arenaAt(0, 0.5, 54), Color3.new(1, 0, 0))
	seekerSpawn.Transparency = 1
	seekerSpawn.CanCollide = false
	seekerSpawn.CanQuery = false
	seekerSpawn.CanTouch = false

	arena.Parent = Workspace
	return arena
end

local function buildLobby(): Model
	local lobby = Instance.new("Model")
	lobby.Name = "Lobby"
	local size = 60
	local wallHeight = 6

	local function at(x: number, y: number, z: number): CFrame
		return CFrame.new(LOBBY_ORIGIN + Vector3.new(x, y, z))
	end

	makePart(lobby, "Floor", Vector3.new(size, 1, size), at(0, -0.5, 0), COLORS.lobbyFloor)
	makePart(lobby, "Wall", Vector3.new(size, wallHeight, 1), at(0, wallHeight / 2, size / 2), COLORS.lobbyWall)
	makePart(lobby, "Wall", Vector3.new(size, wallHeight, 1), at(0, wallHeight / 2, -size / 2), COLORS.lobbyWall)
	makePart(lobby, "Wall", Vector3.new(1, wallHeight, size), at(size / 2, wallHeight / 2, 0), COLORS.lobbyWall)
	makePart(lobby, "Wall", Vector3.new(1, wallHeight, size), at(-size / 2, wallHeight / 2, 0), COLORS.lobbyWall)

	-- Lamps so the lobby is bright while the rest of the game is dark
	for _, offset in { Vector2.new(-15, -15), Vector2.new(15, -15), Vector2.new(-15, 15), Vector2.new(15, 15) } do
		local lamp = makePart(lobby, "Lamp", Vector3.new(2, 1, 2), at(offset.X, 14, offset.Y), Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
		lamp.CanCollide = false
		local light = Instance.new("PointLight")
		light.Range = 40
		light.Brightness = 3
		light.Color = Color3.fromRGB(255, 240, 210)
		light.Parent = lamp
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "LobbySpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0 -- no spawn shield
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = at(0, 0.5, 0)
	spawn.Color = Color3.fromRGB(90, 160, 255)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Parent = lobby

	lobby.Parent = Workspace
	return lobby
end

-- Stop players spawning anywhere except the lobby (e.g. the Baseplate template's spawn).
local function disableOtherSpawns(keep: Instance)
	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("SpawnLocation") and descendant ~= keep then
			descendant.Enabled = false
		end
	end
end

local function spawnCFrame(part: BasePart): CFrame
	return part.CFrame + Vector3.new(0, 3, 0)
end

function MapBuilder.build(): Map
	local arena = Workspace:FindFirstChild("Arena") or buildArena()
	local lobby = Workspace:FindFirstChild("Lobby") or buildLobby()

	local lobbySpawn = lobby:FindFirstChild("LobbySpawn", true) :: BasePart
	assert(lobbySpawn, "Lobby needs a SpawnLocation named LobbySpawn")
	disableOtherSpawns(lobbySpawn)

	local seekerSpawn = arena:FindFirstChild("SeekerSpawn", true) :: BasePart
	assert(seekerSpawn, "Arena needs a part named SeekerSpawn")

	local hiderFolder = arena:FindFirstChild("HiderSpawns", true)
	assert(hiderFolder, "Arena needs a folder named HiderSpawns")
	local hiderSpawns = {}
	for _, child in hiderFolder:GetChildren() do
		if child:IsA("BasePart") then
			table.insert(hiderSpawns, spawnCFrame(child))
		end
	end
	assert(#hiderSpawns > 0, "HiderSpawns folder needs at least one part")

	return {
		lobbySpawn = spawnCFrame(lobbySpawn),
		seekerSpawn = spawnCFrame(seekerSpawn),
		hiderSpawns = hiderSpawns,
	}
end

return MapBuilder
