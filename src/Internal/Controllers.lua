--!strict
type Controller = {
	["Name"]: string,
	["Controller"]: any
}

do
	local RunService = game:GetService("RunService")
	if RunService:IsServer() then
		error("CANNOT LOAD CONTROLLERS ON SERVER", 2)
	end
end

-- Loads a module if it meets the criteria
local function LoadModule(Module: ModuleScript, Modules: {[string]: Controller}): {[string]: Controller}
	if Module.ClassName ~= "ModuleScript" then return Modules end

	local ModuleName = tostring(Module)
	if Modules[ModuleName] then 
		error(`{ModuleName} has already been loaded!`) 
	end
	
	-- Add the module to a new table
	local NewModules = table.clone(Modules)
	local NewModule: Controller = {["Name"] = ModuleName, ["Controller"] = Module}
	NewModules[ModuleName] = NewModule
	return NewModules
end

-- Recursively finds modules starting from the root
local function FindModules(Root: Instance, Modules: {[string]: Controller}): {[string]: Controller}
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
