--!strict
--[[
	@details
	Contains all functions and properties that are shared to the client

	@file Server.lua (Scrypt)
    @client
    @author zblox164
    @version 0.0.62-alpha
    @since 2024-12-17
--]]

--[=[
	@class ScryptClient
	@client
	:::danger NOTICE
	Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please create an issue on the GitHub repository.
	:::
]=]

--[=[
	@interface Controller
	.[Name] string
	.[Controller] any
	@within ScryptClient
]=]

--[=[
	@type Result<T> {Success: boolean, Value: T?, Error: string?}
	@within ScryptClient
]=]

--[=[
	@type GUI {[string]: {[string]: GuiObject}}
	@since v0.0.42-alpha
	@within ScryptClient
]=]

--[=[
	@prop Monad MonadClass
	@since v0.0.5-alpha
	@within ScryptClient
]=]

--[=[
	@prop LocalPlayer Player
	@within ScryptClient
]=]

--[=[
	@prop GUI GUI
	@within ScryptClient
	@since v0.0.42-alpha
	Contains a dictionary of GUI objects.
]=]

--[=[
	@prop Services {[Name]: Instance}
	@within ScryptClient
	Contains a dictionary of Roblox services.
]=]

--[=[
	@prop Utils {(...any) -> ...any}
	@within ScryptClient
	@since v0.0.4-alpha
	Returns the Utils module. Contains some basic pure functions.
]=]

--[=[
	@prop ClientNetwork ClientNetwork
	@within ScryptClient
	Returns the ClientNetwork class.
]=]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ScryptClient = {}
local Controllers = {}:: {[string]: any}
local Shared = {}:: {[string]: any}

-- Modules
local Function = require(script.Parent.Internal.Function)
local RBXServices = require(script.Parent.Internal.RBXServices)
local Signal = require(script.Parent.Internal.Signal)
local Symbol = require(script.Parent.Internal.Symbol)
local Monad = require(script.Parent.Internal.Monad)
local Loaded = Signal.New("Loaded", true)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- For better Intellisense (add modules here if you want them to be loaded manually)
local function ManualLoadModules()
	local replicatedStorage = game:GetService("ReplicatedStorage")

	-- Internals
	ScryptClient.Utils = require(replicatedStorage:WaitForChild("Scrypt"):WaitForChild("Internal"):WaitForChild("Utils"))

	-- Custom Modules
end

-- Validates a module
local function ValidateModule(module: ModuleScript): Result<ModuleScript>
    if not module:IsA("ModuleScript") then
        return { Success = false, Error = "Invalid module type" }:: Result<ModuleScript>
    end

    return { Success = true, Value = module }:: Result<ModuleScript>
end

-- Validates if a module is unique
local function ValidateUnique(name: string, modules: {[string]: ModuleScript}): Result<string>
    if modules[name] then
        return { Success = false, Error = `{name} has already been loaded!` }:: Result<string>
    end

    return { Success = true, Value = name }:: Result<string>
end

-- Loads a module if it meets the criteria
local function LoadModule(module: ModuleScript, modules: {[string]: ModuleScript}): Result<{[string]: ModuleScript}>
    local ModuleValidation = ValidateModule(module)
    if not ModuleValidation.Success then
        return { Success = false, Error = ModuleValidation.Error }:: Result<{[string]: ModuleScript}>
    end

    local ModuleName = tostring(module)
    local UniqueValidation = ValidateUnique(ModuleName, modules)
    if not UniqueValidation.Success then
        return { Success = false, Error = UniqueValidation.Error }:: Result<{[string]: ModuleScript}>
    end

    local NewModules = table.clone(modules)
    NewModules[ModuleName] = module
    return { Success = true, Value = NewModules }:: Result<{[string]: ModuleScript}>
end

local function IsLoadableModule(node: Instance): boolean
    return node:IsA("ModuleScript") and not node:GetAttribute("ManualLoad")
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

local function FindModules(root: Instance, modules: {[string]: ModuleScript}): Result<{[string]: ModuleScript}>
    return Reduce(root:GetChildren(), function(accumulator: any, node: Instance)
        if not accumulator.Success then
            return accumulator
        end

        if IsLoadableModule(node) then
            return LoadModule(node :: ModuleScript, accumulator.Value)
        end

        if #node:GetChildren() > 0 then
            return FindModules(node, accumulator.Value)
        end

        return accumulator
    end, { Success = true, Value = table.clone(modules) })
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Function to lazily load modules (only loads when needed)
local function LazyLoad(moduleTable: {[string]: ModuleScript}, lazyLoadTable: {[string]: any}): {[string]: any}
	local function LoadHelper(ModuleName: string): (boolean, any)
		return pcall(function()
			local require = require
			return require(moduleTable[ModuleName])
		end)
	end

	-- Setup lazy loading
	setmetatable(lazyLoadTable, {
		__index = function(T, moduleName: string): any
			local success, loadedModule = LoadHelper(moduleName)

			if not success then
				warn(`Failed to load module '{moduleName}'. Error message: {tostring(loadedModule)}`)
			else
				T[moduleName] = loadedModule
			end

			return loadedModule
		end
	})

	return lazyLoadTable
end

-- Waits for local player to load
local function WaitForLocalPlayer(players: Players): Player
	local player = players.LocalPlayer or function()
		while not players.LocalPlayer do
			task.wait()
		end

		return players.LocalPlayer
	end

	return player:: Player
end

-- Waits for game to load (yields)
local function WaitForAssets(): boolean
	repeat
		task.wait()
	until game:IsLoaded()

	return true
end

local function LoadSharedModules(): {[string]: ModuleScript}
	local sharedFolder = RBXServices.ReplicatedStorage:WaitForChild("Shared")
	local libraries = FindModules(sharedFolder:WaitForChild("Libraries"), {})

	assert(libraries.Success, libraries.Error)
	local sharedAndLibraries = FindModules(RBXServices.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"), libraries.Value:: {[string]: ModuleScript})

	assert(sharedAndLibraries.Success, sharedAndLibraries.Error)
	return sharedAndLibraries.Value:: {[string]: ModuleScript}
end

local function SetupBuiltInFeatures()
	ScryptClient.Symbol = Symbol
	ScryptClient.Monad = Monad

	local network = require(script.Parent.Internal.Network)
	ScryptClient.ClientNetwork = network
	ScryptClient.ClientNetwork.Init()

	--[=[
		Creates and returns a Signal. This is an implementation of BindableEvents.
		:::info What is IsPrivate?
		IsPrivate is an optional argument that toggles whether you want
		the event to be used in other scripts. By default this is set to false.
		:::

		@within ScryptClient
		@param Name string
		@param IsPrivate boolean?
		@return Signal
		@client
	]=]
	ScryptClient.CreateSignal = function(Name: string, IsPrivate: boolean?): Signal
		return Signal.New(Name, IsPrivate)
	end

	--[=[
		Creates and returns a Function. This is an implementation of BindableFunctions.
		:::info What is IsPrivate?
		IsPrivate is an optional argument that toggles whether you want
		the function to be used in other scripts. By default this is set to false.
		:::

		@within ScryptClient
		@param Name string
		@param IsPrivate boolean?
		@return Function
		@client
	]=]
	ScryptClient.CreateFunction = function(Name: string?, IsPrivate: boolean?): Function
		return Function.New(Name, IsPrivate)
	end

	--[=[
		@prop Version string
		@since v0.0.61-alpha
		@readonly
		@within ScryptClient
	]=]
	ScryptClient.Version = "0.0.62-alpha"
end

-- Loads all game modules (controllers)
local function GetGameModules(environmentLocation: Instance?): {[string]: ModuleScript}
	local controllerList: {[string]: Controller} = require(script.Parent.Internal.Controllers)(environmentLocation or RBXServices.ReplicatedStorage:WaitForChild("Controllers"), {})
	local modules = {}

	for Name, Controller in pairs(controllerList) do
		modules[Name] = Controller.Controller
	end

	return modules
end

-- Function to load directly accessable features
local function LoadDirectAccess()
	-- Built in access
	ManualLoadModules()
	ScryptClient.Services = RBXServices
	ScryptClient.LocalPlayer = WaitForLocalPlayer(RBXServices.Players)

	ScryptClient.GUI = {}:: GUI
	ScryptClient.GUI = require(script.Parent.Internal.GUI)
end

local function SetupFeatures(environmentLocation: Instance?)
	WaitForAssets()

	local gameModules = GetGameModules(environmentLocation)
	pcall(LazyLoad, gameModules, Controllers)

	LoadDirectAccess()

	local sharedModules = LoadSharedModules()
	pcall(LazyLoad, sharedModules, Shared)

	SetupBuiltInFeatures()

	Loaded:Fire()
end

--[=[
	Loads and returns a controller by name. Controllers are lazily loaded so they are only run when this function is invoked.

	@within ScryptClient
	@param Name string
	@return any
	@client
]=]
function ScryptClient.GetController(Name: string): any
	return Controllers[Name]
end

--[=[
	Loads and returns a shared module by name. Shared modules are lazily loaded so they are only run when this function is invoked.

	@within ScryptClient
	@param Name string
	@return any
	@client
]=]
function ScryptClient.GetModule(Name: string): any
	return Shared[Name]
end

--[=[
	Initializes the framework and loads all shared modules, libraries, and controllers.
	This function returns an event that fires once everything has been loaded. You can optionally specify
	the location of environment modules. By default, Scrypt assumes ReplicatedStorage.

	Usage example:
	```lua
	local Scrypt = require(game:GetService("ReplicatedStorage"):WaitForChild("Scrypt"))
	Scrypt.Init():Wait()

	print(Scrypt.LocalPlayer) -> zblox164
	```
	:::caution
	If you are adding libraries, shared modules, or controllers, you do not have to wait for the framework to load.
	Doing so can cause issues.
	:::

	@param EnvironmentLocation Instance?
	@return Signal
	@client
]=]
function ScryptClient.Init(EnvironmentLocation: Instance?): Signal
	task.spawn(SetupFeatures, EnvironmentLocation)
	return Loaded
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Types
type Result<T> = {
    Success: boolean,
    Value: T?,
    Error: string?
}

type Controller = {
	["Name"]: string,
	["Controller"]: any
}

type Maybe<T> = {
    bind: (func: (T) -> Maybe<T>) -> Maybe<T>,
    map: (func: (T) -> T) -> Maybe<T>,
    fromMaybe: (default: T) -> T,
    isJust: () -> boolean,
    isNothing: () -> boolean,
    value: T | nil,
}

type GUI = {[string]: {[string]: GuiObject} | {Root: GuiObject}}

type Signal = typeof(setmetatable({}:: {
	Connections: {Signal.SignalConnection?},
	YieldedConnections: {thread?}
}, {}:: Signal.SignalImpl))

type Function = typeof(setmetatable({}:: {
	Function: ((...any) -> ...any)?,
	YieldedCalls: {thread?}
}, {}:: Function.FunctionImpl))

return ScryptClient