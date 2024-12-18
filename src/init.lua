local RunService: RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.Server)
else
	task.defer(function() 
		script:WaitForChild("Server"):Destroy() 
	end)
	
	return require(script.Client)
end
