--[[
	@details
	Loads the client / server framework based on environment.

	@file Scrypt.lua
    @shared
    @author zblox164
    @version 0.0.2-alpha
    @since 2024-12-17
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