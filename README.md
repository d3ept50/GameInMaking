# GameInMaking

**Flashlight Tag**: a dark room full of hiding spots. One player is the seeker and hunts with a flashlight; everyone else hides. Get close to a hider to tag them. The seeker wins if everyone is found before time runs out.

Settings (round times, tag distance, flashlight strength, how dark it is) are in `src/shared/Config.luau`.

To test alone in Studio: **Test** tab > **Clients and Servers** > 2 players > **Start**.

## Using your own map

The game builds a default lobby and arena when it starts. To use one you built in Studio, add a Model in Workspace named `Arena` with a `HiderSpawns` folder of parts and a part named `SeekerSpawn`, and/or a Model named `Lobby` with a SpawnLocation named `LobbySpawn`.

## About the code

A Roblox game. Code lives in `src/` and is synced into Roblox Studio with [Rojo](https://rojo.space).

## Where things go

| Folder | Shows up in Studio as | Runs on |
| --- | --- | --- |
| `src/server` | ServerScriptService > Server | server |
| `src/client` | StarterPlayer > StarterPlayerScripts > Client | each player |
| `src/shared` | ReplicatedStorage > Shared | both (modules) |

File names decide the script type: `Name.server.luau` is a Script, `Name.client.luau` is a LocalScript, and plain `Name.luau` is a ModuleScript.

## Connecting to Studio (each time you work)

1. Get the latest code: `git pull`
2. In this folder, run: `rojo serve`
3. In Studio, open your place, go to the **Plugins** tab, open **Rojo**, and click **Connect**.

Studio now matches the files and updates live while `rojo serve` is running.

## Important

- Pushing to GitHub does **not** change Studio or the live game by itself.
  Studio only gets the code while Rojo is connected.
- The live game only changes when you **Publish** from Studio (File > Publish to Roblox).
- Parts, maps and models you build in Studio are not stored here. Save the place in Studio as usual.

## One-time setup

- Install the Rojo command line tool: install [Rokit](https://github.com/rojo-rbx/rokit), then run `rokit install` in this folder.
- Install the Rojo plugin in Studio: run `rojo plugin install`, then restart Studio.
