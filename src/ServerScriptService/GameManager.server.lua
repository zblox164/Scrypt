--!strict
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

-- Handles all functions for when the character gets added
local function CharacterAdded(Character: Model, Player: Player)
	Scrypt.ServerNetwork.SendPacketToPlayer("TEST", {Reliable = true, Address = Player, Data = "Hello, World!"})
end

-- Handle Player joining
local function OnPlayerAdded(Player: Player)
	-- Handle character addeds
	CharacterAdded(Player.Character or Player.CharacterAdded:Wait(), Player)
	Player.CharacterAdded:Connect(function(Character)
		CharacterAdded(Character, Player)
	end)
	
	-- Handle memory leak
	Player.CharacterRemoving:Connect(function(Character: Model)
		repeat
			local Success = pcall(function()
				task.defer(Character.Destroy, Character)
			end)
		until Success
	end)
end

-- Handle Player leaving
local function OnPlayerRemoving(Player: Player)
	-- Erase player from server
	
	-- Handle memory leak
	repeat
		local Success = pcall(function()
			task.defer(Player.Destroy, Player)
		end)
	until Success
end

-- Signals & Setup
Scrypt.ServicesRBX.Players.PlayerAdded:Connect(OnPlayerAdded)
Scrypt.ServicesRBX.Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Initializers
task.spawn(function()

end)

-- Secondary setup
task.defer(function()
	
end)

-- Next Heartbeat setup
task.delay(0, function()
	
end)

-- Loops
--while true do
--	task.wait(1)
--end