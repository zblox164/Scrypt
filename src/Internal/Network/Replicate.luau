--!strict
--[[
	@details
	Allows functions to be added to instances (may become more moduluar in the future for direct dev use).

	@file Replicate.luau
    @shared
    @author zblox164
    @version 0.0.5-alpha
    @since 2024-12-17
--]]

local InstanceWrapper = {}
InstanceWrapper.__index = function(proxy, key)
    -- Check custom methods first
    if InstanceWrapper[key] then
        return InstanceWrapper[key]
    else
        local inst = rawget(proxy, "instance")
        if inst then
            return inst[key]
        else
            return nil
        end
    end
end

function InstanceWrapper.new(instance: Instance, path: string?)
    assert(instance or path, "Instance or Path is nil")

    local proxy
    if not instance then
        proxy = { path = path }
    else
        proxy = { instance = instance }
    end

    setmetatable(proxy, InstanceWrapper)
    return proxy
end

local function WaitForPath(rootNode: Instance, path: string, maxWait: number?): Instance?
	-- Error handling
	assert(rootNode, `RootNode is not valid. 'Instance' expected got: {tostring(typeof(rootNode))}`)
	assert(path, `Path is not valid. 'string' expected got: {tostring(typeof(path))}`)
	if typeof(maxWait) ~= "number" then maxWait = nil end

	-- Variables
	local waitTime: number
	local startTime = tick()
	local pathNodes = string.split(path, ".")

	-- Iterate through each node and wait for it to load
	for index, newNode in ipairs(pathNodes) do
		if maxWait then
			-- Calculate the remaining wait time
			waitTime = (startTime + maxWait) - tick()
		end

		rootNode = rootNode:WaitForChild(newNode, waitTime):: Instance
		if not rootNode then return nil end
	end

	return rootNode
end

-- Wait for the instance to replicate to the client
function InstanceWrapper:Replicate()
    if self.instance then
        return self.instance
    else
        local path = self.path
        self.instance = WaitForPath(game, path)
    end

    return self.instance
end

return InstanceWrapper