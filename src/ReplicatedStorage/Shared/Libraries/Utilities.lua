--!strict
local Utilities = {}

local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")

-- Waits for a full path has loaded and returns the end object
function Utilities.WaitForPath(RootNode: Instance, Path: string, MaxWait: number?): Instance?
	-- Error handling
	assert(RootNode, `RootNode is not valid. 'Instance' expected got: {tostring(typeof(RootNode))}`)
	assert(Path, `Path is not valid. 'string' expected got: {tostring(typeof(Path))}`)
	if typeof(MaxWait) ~= "number" then MaxWait = nil end

	-- Variables
	local WaitTime
	local StartTime = tick()
	local PathNodes = string.split(Path, ".")

	-- Iterate through each node and wait for it to load
	for Index, NewNode in ipairs(PathNodes) do
		if MaxWait then
			-- Calculate the remaining wait time
			WaitTime = (StartTime + MaxWait) - tick()
		end

		RootNode = RootNode:WaitForChild(NewNode, WaitTime)
		if not RootNode then return nil end
	end

	return RootNode
end

-- Safely finds an object in a path and errors if it fails to find it
function Utilities.SafeFindObject(RootNode: Instance, Path: string): Instance?
	-- Error handling
	assert(RootNode, `RootNode is not valid. 'Instance' expected got: {tostring(typeof(RootNode))}`)
	assert(Path, `Path is not valid. 'string' expected got: {tostring(typeof(Path))}`)
	
	local PathNodes = string.split(Path, ".")
	
	for _, NewNode in ipairs(PathNodes) do
		local CurrentNode = RootNode:FindFirstChild(NewNode)
		if not CurrentNode then 
			error(`Failed to find object '{tostring(NewNode)} under {RootNode:GetFullName()}. Attempted path: {Path}`, 2) 
		end
		
		RootNode = CurrentNode
	end	
	
	return RootNode
end

-- Safely connects a player added event and runs the callback for all current players
function Utilities.SafePlayerAdded(OnPlayerAddedCallback: (Player: Player) -> ()): RBXScriptConnection
	for Index, Player in ipairs(Players:GetPlayers()) do
		task.spawn(OnPlayerAddedCallback, Player)
	end
	return Players.PlayerAdded:Connect(OnPlayerAddedCallback)
end

-- Verifies if the Part can be found
local function Verify(User: Player, Part: string): any
	if not User then warn("Failed to grab the user") return end
	if not Part then warn("Part is not valid") return end

	local Character = User.Character or User.CharacterAdded:Wait()
	if Character then 
		repeat
			Character = User.Character or User.CharacterAdded:Wait()
			task.wait()
		until Character:FindFirstChild(Part)
	end

	local Object = Character:WaitForChild(Part)
	if not Object then warn("Failed to grab " .. tostring(Part)); return false  end

	return Object
end

-- Returns an object from the player
function Utilities.GetPlayerObject(Object: string, Player: Player?): Instance
	assert(Object and typeof(Object) == "string", "Object is not valid.")
	
	local IsClient = RunService:IsClient()
	local User = Player
	
	-- Make sure player is valid
	if IsClient then User = Player or Players.LocalPlayer end
	if not User then error("Could not find player") end
	
	User = User:: Player
	Object = string.lower(Object)
	
	-- Return values 
	if Object == "camera" then return workspace.CurrentCamera end
	if Object == "character" then return User.Character or User.CharacterAdded:Wait() end
	if Object == "player" then return User end
	if Object == "rootpart" then return Verify(User, "HumanoidRootPart") end
	if Object == "torso" then return Verify(User, "UpperTorso") end
	if Object == "humanoid" then return Verify(User, "Humanoid") end	
	if Object == "playergui" then return User:WaitForChild("PlayerGui") end
	if Object == "starterplayer" then return User:WaitForChild("StarterPlayer") end	
	if Object == "backpack" then return User:WaitForChild("Backpack") end
	if Object == "mouse" then return User:GetMouse() end
	return
end

return Utilities