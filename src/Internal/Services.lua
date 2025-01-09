--!strict
--[[
	@details
	Returns a function that finds all services in the Root instance.

	@file Services.lua
    @server
    @author zblox164
    @version 0.0.4-alpha
    @since 2024-12-17
--]]

type Service = {
	["Name"]: string,
	["Service"]: any
}

-- Runtime check
do
	local RunService = game:GetService("RunService")
	if RunService:IsClient() then
		error("CANNOT LOAD SERVICES ON CLIENT", 2)
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
local function CreateService(Module: ModuleScript): Service
	return {
		["Name"] = tostring(Module),
		["Service"] = Module
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

-- Loads a service
local function LoadService<T>(Module: ModuleScript, Modules: {[string]: {Service}}): {[string]: T}
    if not IsLoadableModule(Module) then
        return Modules
    end

    local ModuleName = tostring(Module)
    if not IsModuleNameUnique(ModuleName, Modules) then
        error(`{ModuleName} has already been loaded!`)
    end

    local NewModules = table.clone(Modules):: {[string]: Service}
    NewModules[ModuleName:: string] = CreateService(Module)
    return NewModules
end

-- Returns a table of services
local function FindModules(Root: Instance, Modules: {[string]: Service}): {[string]: Service}
	local Children: {Instance} = Root:GetChildren()
	
	-- Filter loadable modules
	local LoadableModules: {Instance} = Filter(Children, IsLoadableModule)
	local Directories: {Instance} = Filter(Children, function(child: Instance) 
		return #child:GetChildren() > 0 
	end)
	
	-- Load all modules and get their return values
	local NewModules = Reduce(LoadableModules, function(accumulatedServices: {[string]: Service}, module: Instance)
		local Module = LoadService(module:: ModuleScript, accumulatedServices:: {[string]: any})

		if Module and module:IsA("ModuleScript") then
			accumulatedServices[tostring(module)] = CreateService(module)
		end

		return accumulatedServices
	end, table.clone(Modules))
	
	return Reduce(Directories, function(Accumulator: {[string]: Service}, Directory: Instance)
		return FindModules(Directory, Accumulator)
	end, NewModules):: {[string]: Service}
end

return FindModules