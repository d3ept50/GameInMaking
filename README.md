# GameInMaking

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
