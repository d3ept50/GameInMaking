-- Shared code: anything here can be used by both server and client scripts.
-- Lives in ReplicatedStorage > Shared > Hello in Studio.

local Hello = {}

function Hello.greet(who: string): string
	return "Hello from Rojo, " .. who .. "!"
end

return Hello
