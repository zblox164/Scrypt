local RunService: RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.ServerNetwork)
else
	task.defer(function() 
		script:WaitForChild("ServerNetwork"):Destroy() 
	end)
	
	return require(script.ClientNetwork)
end