--!strict
--[[
	@details
	Contains all functions and properties that are shared to the client

	@file Server.lua (Scrypt)
    @client
    @author zblox164
    @version 0.0.4-alpha
    @since 2024-12-17
--]]

--[=[
	@class ScryptClient
	@client
	:::danger NOTICE
	Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please contact zblox164 and provide relevant details.
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
	@prop RegExp RegularExpressionClass
	@within ScryptClient
	Regular expressions module published by Roblox. See more information in RegEx.lua.
]=]


--[=[
	@prop Promise PromiseClass
	@within ScryptClient
	Promise module created by evaera. 
]=]

--[=[
	@prop LocalPlayer Player
	@within ScryptClient
]=]

--[=[
	@prop Services {[Name]: Instance}
	@within ScryptClient
	Contains a dictionary of Roblox services.
]=]

--[=[
	@prop Utils {(...any) -> ...any}
	@within ScryptClient
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
local Promise = require(script.Parent.Internal.Promise)
local Symbol = require(script.Parent.Internal.Symbol)
local RegularExpressions = require(script.Parent.Internal.LuauRegExp)
local Loaded = Signal.New("Loaded", true)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- For better Intellisense (add modules here if you want them to be loaded manually)
local function ManualLoadModules()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	
	-- Internals
	ScryptClient.Utils = require(ReplicatedStorage:WaitForChild("Scrypt"):WaitForChild("Internal"):WaitForChild("Utils"))
	
	-- Custom Modules
end

-- Validates a module
local function ValidateModule(Module: ModuleScript): Result<ModuleScript>
    if not Module:IsA("ModuleScript") then
        return { Success = false, Error = "Invalid module type" }:: Result<ModuleScript>
    end

    return { Success = true, Value = Module }:: Result<ModuleScript>
end

-- Validates if a module is unique
local function ValidateUnique(Name: string, Modules: {[string]: ModuleScript}): Result<string>
    if Modules[Name] then
        return { Success = false, Error = `{Name} has already been loaded!` }:: Result<string>
    end

    return { Success = true, Value = Name }:: Result<string>
end

-- Loads a module if it meets the criteria
local function LoadModule(Module: ModuleScript, Modules: {[string]: ModuleScript}): Result<{[string]: ModuleScript}>
    local ModuleValidation = ValidateModule(Module)
    if not ModuleValidation.Success then
        return { Success = false, Error = ModuleValidation.Error }:: Result<{[string]: ModuleScript}>
    end

    local ModuleName = tostring(Module)
    local UniqueValidation = ValidateUnique(ModuleName, Modules)
    if not UniqueValidation.Success then
        return { Success = false, Error = UniqueValidation.Error }:: Result<{[string]: ModuleScript}>
    end

    local NewModules = table.clone(Modules)
    NewModules[ModuleName] = Module
    return { Success = true, Value = NewModules }:: Result<{[string]: ModuleScript}>
end

local function IsLoadableModule(Node: Instance): boolean
    return Node:IsA("ModuleScript") and not Node:GetAttribute("ManualLoad")
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

local function FindModules(Root: Instance, Modules: {[string]: ModuleScript}): Result<{[string]: ModuleScript}>
    return Reduce(Root:GetChildren(), function(accumulator: any, node: Instance)
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
    end, { Success = true, Value = table.clone(Modules) })
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Function to lazily load modules (only loads when needed)
local function LazyLoad(ModuleTable: {[string]: ModuleScript}, LazyLoadTable: {[string]: any}): {[string]: any}
	local function LoadHelper(ModuleName: string): (boolean, any)
		return pcall(function()
			local require = require
			return require(ModuleTable[ModuleName])
		end)
	end

	-- Setup lazy loading
	setmetatable(LazyLoadTable, {
		__index = function(T, ModuleName: string): any
			local Success, LoadedModule = LoadHelper(ModuleName)

			if not Success then 
				warn(`Failed to load module '{ModuleName}'. Error message: {tostring(LoadedModule)}`)
			else
				T[ModuleName] = LoadedModule
			end

			return LoadedModule
		end
	})
	
	return LazyLoadTable
end

-- Waits for local player to load
local function WaitForLocalPlayer(Players: Players): Player
	local Player = Players.LocalPlayer or function()
		while not Players.LocalPlayer do
			task.wait()
		end
		
		return Players.LocalPlayer
	end
	
	return Player:: Player
end

-- Waits for game to load (yields)
local function WaitForAssets(): boolean
	repeat
		task.wait()
	until game:IsLoaded()

	return true
end

local function LoadSharedModules(): {[string]: ModuleScript}
	local SharedFolder = RBXServices.ReplicatedStorage:WaitForChild("Shared")
	local Libraries = FindModules(SharedFolder:WaitForChild("Libraries"), {})

	assert(Libraries.Success, Libraries.Error)
	local SharedAndLibraries = FindModules(RBXServices.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"), Libraries.Value:: {[string]: ModuleScript})

	assert(SharedAndLibraries.Success, SharedAndLibraries.Error)
	return SharedAndLibraries.Value:: {[string]: ModuleScript}
end

local function SetupBuiltInFeatures()
	ScryptClient.Promise = Promise
	ScryptClient.Symbol = Symbol
	ScryptClient.RegExp = RegularExpressions
	
	local Network = require(script.Parent.Internal.Network)
	ScryptClient.ClientNetwork = Network
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
end

-- Loads all game modules (controllers)
local function GetGameModules(EnvironmentLocation: Instance?): {[string]: ModuleScript}
	local ControllerList: {[string]: Controller} = require(script.Parent.Internal.Controllers)(EnvironmentLocation or RBXServices.ReplicatedStorage:WaitForChild("Controllers"), {})
	local Modules = {}

	for Name, Controller in pairs(ControllerList) do
		Modules[Name] = Controller.Controller
	end

	return Modules
end

-- Function to load directly accessable features
local function LoadDirectAccess()
	-- Built in access
	ManualLoadModules()
	ScryptClient.Services = RBXServices
	ScryptClient.LocalPlayer = WaitForLocalPlayer(RBXServices.Players)
	ScryptClient.GUI = {}:: {[string]: {[string]: GuiObject}}
	ScryptClient.GUI = nil:: any	
end

local function SetupFeatures(EnvironmentLocation: Instance?)
	WaitForAssets()
	
	local GameModules = GetGameModules(EnvironmentLocation)
	pcall(LazyLoad, GameModules, Controllers)
	
	LoadDirectAccess()
	
	local SharedModules = LoadSharedModules()
	pcall(LazyLoad, SharedModules, Shared)
	
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

type Signal = typeof(setmetatable({}:: {
	Connections: {Signal.SignalConnection?},
	YieldedConnections: {thread?}
}, {}:: Signal.SignalImpl))

type Function = typeof(setmetatable({}:: {
	Function: ((...any) -> ...any)?,
	YieldedCalls: {thread?}
}, {}:: Function.FunctionImpl))

return ScryptClient