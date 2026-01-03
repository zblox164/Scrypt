--!strict
--[[
	@details
	Returns a function that finds all services in the Root instance.

	@file Services.lua
    @server
    @author zblox164
    @version 0.0.62-alpha
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
local function Filter<T>(Table: {T}, predicate: (value: T) -> boolean): {T}
	assert(Table, "Table is not valid")
	assert(typeof(predicate) == "function", "Predicate function expected as second argument")

	local newTable = {}

	for Index, Value in ipairs(Table) do
		if not predicate(Value) then continue end
		table.insert(newTable, Value)
	end

	return newTable
end

-- Pure function to accumulate a table
local function Reduce<T, U>(Table: {T}, func: (accumulator: U, value: T) -> U, Initial: U): U
	assert(Table, "Table is not valid")
	assert(typeof(func) == "function", "Function expected as second argument")

	local result = Initial
	for _, v in ipairs(Table) do
		result = func(result, v)
	end

	return result
end

-- Pure function to create a service object
local function CreateService(module: ModuleScript): Service
	return {
		["Name"] = tostring(module),
		["Service"] = module
	}
end

-- Pure function to check if module can be loaded
local function IsLoadableModule(module: Instance): boolean
	if not (typeof(module) == "Instance") then return false end
    return module:IsA("ModuleScript") and not module:GetAttribute("ManualLoad")
end

-- Pure function to check if module name exists
local function IsModuleNameUnique<T>(moduleName: string, modules: {[string]: T}): boolean
    return not modules[moduleName]
end

-- Loads a service
local function LoadService<T>(module: ModuleScript, modules: {[string]: {Service}}): {[string]: T}
    if not IsLoadableModule(module) then
        return modules
    end

    local moduleName = tostring(module)
    if not IsModuleNameUnique(moduleName, modules) then
        error(`{moduleName} has already been loaded!`)
    end

    local newModules = table.clone(modules):: {[string]: Service}
    newModules[moduleName:: string] = CreateService(module)
    return newModules
end

-- Returns a table of services
local function FindModules(root: Instance, modules: {[string]: Service}): {[string]: Service}
	local children: {Instance} = root:GetChildren()

	-- Filter loadable modules
	local loadableModules: {Instance} = Filter(children, IsLoadableModule)
	local directories: {Instance} = Filter(children, function(child: Instance)
		return #child:GetChildren() > 0
	end)

	-- Load all modules and get their return values
	local newModules = Reduce(loadableModules, function(accumulatedServices: {[string]: Service}, module: Instance)
		local Module = LoadService(module:: ModuleScript, accumulatedServices:: {[string]: any})

		if Module and module:IsA("ModuleScript") then
			accumulatedServices[tostring(module)] = CreateService(module)
		end

		return accumulatedServices
	end, table.clone(modules))

	return Reduce(directories, function(accumulator: {[string]: Service}, directory: Instance)
		return FindModules(directory, accumulator)
	end, newModules):: {[string]: Service}
end

return FindModules