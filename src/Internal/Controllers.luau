--!strict
--[[
	@details
	Returns a function that finds all controllers in the Root instance.

	@file Controllers.lua
    @client
    @author zblox164
    @version 0.0.4-alpha
    @since 2024-12-17
--]]

type Controller = {
	["Name"]: string,
	["Controller"]: any
}


-- Runtime check
do
	local RunService = game:GetService("RunService")
	if RunService:IsServer() then
		error("CANNOT LOAD CONTROLLERS ON SERVER", 2)
	end
end

-- Utilities
-- Pure function to filter a table
local function Filter<T>(Table: {T}, Predicate: (value: T) -> boolean): {T}
	assert(Table, "Table is not valid")
	assert(typeof(Predicate) == "function", "Predicate function expected as second argument")

	local NewTable = {}

	for Index, Value in ipairs(Table) do
		if not Predicate(Value) then continue end
		table.insert(NewTable, Value)
	end

	return NewTable
end

-- Pure function to accumulate a table
local function Reduce<T, U>(Table: {T}, Func: (accumulator: U, value: T) -> U, Initial: U): U
	assert(Table, "Table is not valid")
	assert(typeof(Func) == "function", "Function expected as second argument")

	local Result = Initial
	for _, v in ipairs(Table) do
		Result = Func(Result, v)
	end

	return Result
end

-- Pure function to create a service object
local function CreateController(Module: ModuleScript): Controller
	return {
		["Name"] = tostring(Module),
		["Controller"] = Module
	}
end

-- Pure function to check if module can be loaded
local function IsLoadableModule(Module: Instance): boolean
	if not (typeof(Module) == "Instance") then return false end
    return Module:IsA("ModuleScript") and not Module:GetAttribute("ManualLoad")
end

-- Pure function to check if module name exists
local function IsModuleNameUnique<T>(ModuleName: string, Modules: {[string]: T}): boolean
    return not Modules[ModuleName]
end

-- Loads a controller
local function LoadController<T>(Module: ModuleScript, Modules: {[string]: {Controller}}): {[string]: T}
    if not IsLoadableModule(Module) then
        return Modules
    end

    local ModuleName = tostring(Module)
    if not IsModuleNameUnique(ModuleName, Modules) then
        error(`{ModuleName} has already been loaded!`)
    end

    local NewModules = table.clone(Modules):: {[string]: Controller}
    NewModules[ModuleName:: string] = CreateController(Module)
    return NewModules
end

-- Returns a table of controllers
local function FindModules(Root: Instance, Modules: {[string]: Controller}): {[string]: Controller}
	local Children: {Instance} = Root:GetChildren()
	
	-- Filter loadable modules
	local LoadableModules: {Instance} = Filter(Children, IsLoadableModule)
	local Directories: {Instance} = Filter(Children, function(child: Instance) 
		return #child:GetChildren() > 0 
	end)
	
	-- Load all modules and get their return values
	local NewModules = Reduce(LoadableModules, function(accumulatedServices: {[string]: Controller}, module: Instance)
		local Module = LoadController(module:: ModuleScript, accumulatedServices:: {[string]: any})

		if Module and module:IsA("ModuleScript") then
			accumulatedServices[tostring(module)] = CreateController(module)
		end

		return accumulatedServices
	end, table.clone(Modules))
	
	return Reduce(Directories, function(Accumulator: {[string]: Controller}, Directory: Instance)
		return FindModules(Directory, Accumulator)
	end, NewModules):: {[string]: Controller}
end

return FindModules