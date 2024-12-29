--!strict
--[[
	@details
	Returns a function that finds all services in the Root instance.

	@file Services.lua
    @server
    @author zblox164
    @version 0.0.2-alpha
    @since 2024-12-17
--]]

type Service = {
	["Name"]: string,
	["Service"]: any
}

do
	local RunService = game:GetService("RunService")
	if RunService:IsClient() then
		error("CANNOT LOAD SERVICES ON CLIENT", 2)
	end
end

-- Loads a module if it meets the criteria
local function LoadModule(Module: ModuleScript, Modules: {[string]: Service}): {[string]: Service}
	if Module.ClassName ~= "ModuleScript" then return Modules end

	local ModuleName = tostring(Module)
	if Modules[ModuleName] then 
		error(`{ModuleName} has already been loaded!`) 
	end
	
	-- Add the module to a new table
	local NewModules = table.clone(Modules)
	local NewModule: Service = {["Name"] = ModuleName, ["Service"] = Module}
	NewModules[ModuleName] = NewModule
	return NewModules
end

-- Recursively finds modules starting from the root
local function FindModules(Root: Instance, Modules: {[string]: Service}): {[string]: Service}
	local CurrentModules = table.clone(Modules)

	for _, Node: Instance in ipairs(Root:GetChildren()) do
		if Node:IsA("ModuleScript") and not Node:GetAttribute("ManualLoad") then
			CurrentModules = LoadModule(Node, CurrentModules)
		elseif #Node:GetChildren() > 0 then
			CurrentModules = FindModules(Node, CurrentModules)
		end
	end

	return CurrentModules
end

return FindModules