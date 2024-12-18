--[[

     Scrypt Framework [2024 - 2025] 
     
     DO NOT use without permission from the owner.
     Written by: zblox164
     
--]]

local RunService: RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.Server)
else
	task.defer(function() 
		script:WaitForChild("Server"):Destroy() 
	end)
	
	return require(script.Client)
end