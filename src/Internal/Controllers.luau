--!strict
--[[
	@details
	Returns a function that finds all controllers in the Root instance.

	@file Controllers.lua
    @client
    @author zblox164
    @version 0.0.63-alpha
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
local function CreateController(module: ModuleScript): Controller
	return {
		["Name"] = tostring(module),
		["Controller"] = module
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

-- Loads a controller
local function LoadController<T>(module: ModuleScript, modules: {[string]: {Controller}}): {[string]: T}
    if not IsLoadableModule(module) then
        return modules
    end

    local moduleName = tostring(module)
    if not IsModuleNameUnique(moduleName, modules) then
        error(`{moduleName} has already been loaded!`)
    end

    local newModules = table.clone(modules):: {[string]: Controller}
    newModules[moduleName:: string] = CreateController(module)
    return newModules
end

-- Returns a table of controllers
local function FindModules(root: Instance, modules: {[string]: Controller}): {[string]: Controller}
	local children: {Instance} = root:GetChildren()

	-- Filter loadable modules
	local loadableModules: {Instance} = Filter(children, IsLoadableModule)
	local directories: {Instance} = Filter(children, function(child: Instance)
		return #child:GetChildren() > 0
	end)

	-- Load all modules and get their return values
	local newModules = Reduce(loadableModules, function(accumulatedServices: {[string]: Controller}, module: Instance)
		local Module = LoadController(module:: ModuleScript, accumulatedServices:: {[string]: any})

		if Module and module:IsA("ModuleScript") then
			accumulatedServices[tostring(module)] = CreateController(module)
		end

		return accumulatedServices
	end, table.clone(modules))

	return Reduce(directories, function(accumulator: {[string]: Controller}, directory: Instance)
		return FindModules(directory, accumulator)
	end, newModules):: {[string]: Controller}
end

return FindModules