--[[
	@details
	Returns the Scrypt network framework for the client and server.

	@file Network.lua
    @shared
    @author zblox164
    @version 0.0.2-alpha
    @since 2024-12-17
--]]

local RunService: RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.ServerNetwork)
else
	task.defer(function() 
		script:WaitForChild("ServerNetwork"):Destroy() 
	end)
	
	return require(script.ClientNetwork)
end