-- Server script. Lives in ServerScriptService > Server > Main in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hello = require(ReplicatedStorage.Shared.Hello)

print(Hello.greet("server"))
