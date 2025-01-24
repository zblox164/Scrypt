--[[
	@details
	Returns the Scrypt network framework for the client and server.

	@file Network.luau
    @shared
    @author zblox164
    @version 0.0.4-alpha
    @since 2024-12-17
--]]

local RunService: RunService = game:GetService("RunService")

local function GetServerNetwork()
	return require(script.ServerNetwork)
end

local function GetClientNetwork()
	task.defer(function() 
		script:WaitForChild("ServerNetwork"):Destroy() 
	end)
	
	return require(script.ClientNetwork)
end

local function Network()
	if RunService:IsServer() then
		return GetServerNetwork()
	else
		return GetClientNetwork()
	end
end

return Network()