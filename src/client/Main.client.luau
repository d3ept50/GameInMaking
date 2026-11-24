-- Client script. Lives in StarterPlayer > StarterPlayerScripts > Client > Main in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hello = require(ReplicatedStorage.Shared.Hello)

print(Hello.greet("client"))
