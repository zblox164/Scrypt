--!strict
--[[
	@details
	An module containing functions to communicate with the client.

	@file ClientNetwork.luau
    @server
    @author zblox164
    @version 0.0.5-alpha
    @since 2024-12-17
--]]

--[=[
    @class ServerNetwork
    :::danger NOTICE
    Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please create an issue on the GitHub repository.
    :::
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--[=[
    @type Packet = number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
    @within ServerNetwork
]=]

--[=[
    @interface ServerPacketData
    .Address Player
    .Reliable boolean
    .Data Packet
    @within ServerNetwork
]=]
export type Packet = number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
export type ServerPacketData = {
    Address: Player,
    Reliable: boolean,
    Data: Packet
}

type Result<T> = {
    Success: boolean,
    Value: T?,
    Error: string?
}

type RemoteParams = {
    Player: Player,
    IsSignal: boolean,
    Name: string,
    Reliable: boolean?
}

type RemoteCreateResult = {
    RemoteType: string,
    Name: string,
    Parent: string
}

-- Pure function to validate remote creation params
local function ValidateParams(name: string, location: Instance?): Result<string>
    if not name then
        return { Success = false, Error = "Expected string as first argument" }:: Result<string>
    end

    if not location then
        return { Success = false, Error = "Expected Instance as second argument" }:: Result<string>
    end

    return { Success = true, Value = name }:: Result<string>
end

-- Pure function to validate remote params
local function ValidateRemoteParams(params: RemoteParams): Result<RemoteParams>
    if not params.Name then
        return { Success = false, Error = "Missing remote name" }:: Result<RemoteParams>
    end

    if params.IsSignal and params.Reliable == nil then
        return { Success = false, Error = "Reliability must be specified for signals" }:: Result<RemoteParams>
    end

    return { Success = true, Value = params }:: Result<RemoteParams>
end

-- Returns the root folder for the network and creates necessary subfolders
local function VerifyNetworkIntegrity(): Result<Folder>
    local commsFolder: Folder = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    if not commsFolder then
        commsFolder = Instance.new("Folder")
        commsFolder.Name = "ScryptCommunication"
        commsFolder.Parent = ReplicatedStorage
    end

    -- Create subfolders if they don't exist
    local signalsFolder = commsFolder:FindFirstChild("Signals") or Instance.new("Folder")
    signalsFolder.Name = "Signals"
    signalsFolder.Parent = commsFolder

    local functionsFolder = commsFolder:FindFirstChild("Functions") or Instance.new("Folder")
    functionsFolder.Name = "Functions"
    functionsFolder.Parent = commsFolder

    return { Success = true, Value = commsFolder }:: Result<Folder>
end

-- Function to create remote instance
local function CreateRemoteInstance(name: string, isReliable: boolean): Result<RemoteEvent | UnreliableRemoteEvent>
    local newEvent = if isReliable
        then Instance.new("RemoteEvent")
        else Instance.new("UnreliableRemoteEvent")

    newEvent.Name = name
    return { Success = true, Value = newEvent }:: Result<RemoteEvent | UnreliableRemoteEvent>
end

-- Function to create a new signal
local function CreateSignal(name: string, location: Instance, isReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local validation = ValidateParams(name, location)
    assert(validation.Success, validation.Error)

    local newSignal = CreateRemoteInstance(name, isReliable)
    assert(newSignal.Success, newSignal.Error)
    assert(newSignal.Value, "Error creating signal " .. name)

    newSignal.Value.Name = name
    newSignal.Value.Parent = location
    return newSignal.Value
end

-- Function to get or create an unreliable signal
local function GetUnreliableEvent(name: string, signals: Folder): UnreliableRemoteEvent
    local newUnreliableSignal: UnreliableRemoteEvent = signals:FindFirstChild(name):: UnreliableRemoteEvent
    if not newUnreliableSignal then
        newUnreliableSignal = CreateSignal(name, signals, false):: UnreliableRemoteEvent
    end

    assert(newUnreliableSignal, "Error finding signal " .. name)
    return newUnreliableSignal
end

-- Function to get or create a signal
local function GetEvent(name: string, signals: Folder): RemoteEvent
    local newSignal: RemoteEvent = signals:FindFirstChild(name):: RemoteEvent
    if not newSignal then
        newSignal = CreateSignal(name, signals, true):: RemoteEvent
    end

    assert(newSignal, "Error finding signal " .. name)
    return newSignal
end

local function FindSignal(name: string, signals: Folder, isReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local newSignal = if isReliable then GetEvent(name, signals) else GetUnreliableEvent(name, signals)
    assert(newSignal.ClassName == "RemoteEvent" or newSignal.ClassName == "UnreliableRemoteEvent", "Error finding signal " .. name)

    return newSignal
end

-- Pure function to create function
local function CreateFunction(name: string, location: Instance): RemoteFunction
    local validation = ValidateParams(name, location)
    assert(validation.Success, validation.Error)

    local newFunction = Instance.new("RemoteFunction")
    newFunction.Name = name
    newFunction.Parent = location

    return newFunction
end

-- Returns a signal based on the name and reliability
local function ReturnSignal(name: string, isReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    assert(remotes, "Attempt to use event before network was loaded!")

    local signals = remotes:FindFirstChild("Signals"):: Folder
    assert(signals, "Attempt to use event before network was loaded!")

    local newSignal = FindSignal(name, signals, isReliable)
    assert((newSignal.ClassName == "RemoteEvent" and isReliable) or (newSignal.ClassName == "UnreliableRemoteEvent" and not isReliable),
        "Incorrect remote type! Remotes between the client and server may be out of sync! Signal name: " .. name)
    return newSignal
end

-- Returns a function based on the name
local function ReturnFunction(name: string): RemoteFunction
    local remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    assert(remotes, "Attempt to use function before network was loaded!")

    local functions = remotes:FindFirstChild("Functions")
    assert(functions, "Attempt to use function before network was loaded!")

    local newFunction: RemoteFunction = functions:FindFirstChild(name):: RemoteFunction
    if not newFunction then
        newFunction = CreateFunction(name, functions)
    end

    assert(newFunction, "Error finding signal " .. name)
    return newFunction
end

-- Pure function to determine remote configuration
local function DetermineRemoteConfig(params: RemoteParams): Result<RemoteCreateResult>
    local remoteType
    local parentFolder = if params.IsSignal then "Signals" else "Functions"

    if params.IsSignal then
        remoteType = if params.Reliable then "RemoteEvent" else "UnreliableRemoteEvent"
    else
        remoteType = "RemoteFunction"
    end

    return {
        Success = true,
        Value = {
            RemoteType = remoteType,
            Name = params.Name,
            Parent = parentFolder
        }
    }:: Result<RemoteCreateResult>
end

-- Creates a remote from a request from the client and returns it
local function CreateClientRemote(params: RemoteParams): string
    local validationResult = ValidateRemoteParams(params)
    if not validationResult.Success then
        return error(validationResult.Error)
    end

    local configResult = DetermineRemoteConfig(params)
    if not configResult.Success then
        return error(configResult.Error)
    end

    local config = configResult.Value:: RemoteCreateResult
    local rootFolderResult = VerifyNetworkIntegrity():: Result<Folder>
    assert(rootFolderResult.Success, rootFolderResult.Error)

    local RootFolder = rootFolderResult.Value:: Folder
    assert(RootFolder, "Error finding root folder")

    -- Create instance (this is the only impure operation)
    local newRemote = Instance.new(config.RemoteType)
    newRemote.Name = config.Name
    newRemote.Parent = RootFolder:FindFirstChild(config.Parent)

    return newRemote.Name
end

local ServerNetwork = {}

--[=[
    @return Folder
    @yields
    @private
    @within ServerNetwork
    Private function to initialize the network on the server.
    This function should only be called once (by default, Scrypt does this internally).
]=]
function ServerNetwork.Init(): Folder
    local rootFolder = VerifyNetworkIntegrity():: Result<Folder>
    assert(rootFolder.Success, rootFolder.Error)
    assert(rootFolder.Value, "Error finding root folder")

    local functionFolder = rootFolder.Value:FindFirstChild("Functions")
    assert(functionFolder, "Error finding functions folder")

    if not functionFolder:FindFirstChild("CreateRemote") then
        local newRemote = Instance.new("RemoteFunction")
        newRemote.Name = "CreateRemote"
        newRemote.Parent = functionFolder

        newRemote.OnServerInvoke = function(Player, IsSignal: boolean, Name: string, Reliable: boolean)
            local RemoteCreateParams = {
                Player = Player,
                IsSignal = IsSignal,
                Name = Name,
                Reliable = Reliable
            }:: RemoteParams

            return CreateClientRemote(RemoteCreateParams)
        end
    end

    return rootFolder.Value
end

--[=[
    @param Name string
    @param PacketData ServerPacketData
    @within ServerNetwork
    Sends data to a specific player from the server.
]=]
function ServerNetwork.SendPacketToClient(Name: string, PacketData: ServerPacketData)
    assert(Name, "Expected string as first argument.")
    assert(PacketData, "Expected ServerPacketData as second argument.")

    local signal = ReturnSignal(Name, PacketData.Reliable)
    if signal.ClassName == "RemoteEvent" then
        (signal:: RemoteEvent):FireClient(PacketData.Address, typeof(PacketData.Data) == "Instance", PacketData.Data:GetFullName())
    else
        (signal:: UnreliableRemoteEvent):FireClient(PacketData.Address, typeof(PacketData.Data) == "Instance", PacketData.Data)
    end
end

--[=[
    @param Name string
    @param Packet Packet
    @param IsReliable boolean
    @within ServerNetwork
    Sends data to all clients in a server.
]=]
function ServerNetwork.SendPacketToAllClients(Name: string, Packet: Packet, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")
    assert(Packet, "Expected ServerPacketData as second argument.")

    for _, player in ipairs(Players:GetPlayers()) do
        local playerPacket = {
            Address = player,
            Data = Packet,
            Reliable = IsReliable
        }:: ServerPacketData

        ServerNetwork.SendPacketToClient(Name, playerPacket)
    end
end

--[=[
    @param Name string
    @param Address Player
    @param IsReliable boolean
    @within ServerNetwork
    Pings a specific client. This function should be used when you want to communicate with the client but don't want to send any data.
]=]
function ServerNetwork.PingClient(Name: string, Address: Player, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")
    assert(Address, "Expected Player as second argument.")
    assert(typeof(IsReliable) == "boolean", "Expected boolean as third argument.")

    local signal = ReturnSignal(Name, IsReliable)
    if signal.ClassName == "RemoteEvent" then
        (signal:: RemoteEvent):FireClient(Address)
    else
        (signal:: UnreliableRemoteEvent):FireClient(Address)
    end
end

--[=[
    @param Name string
    @param IsReliable boolean
    @within ServerNetwork
    Pings all clients. This function should be used when you want to communicate with all clients but don't want to send any data.
]=]
function ServerNetwork.PingAllClients(Name: string, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")
    assert(typeof(IsReliable) == "boolean", "Expected boolean as second argument.")

    for _, player in ipairs(Players:GetPlayers()) do
        ServerNetwork.PingClient(Name, player, IsReliable)
    end
end

--[=[
    @param Name string
    @param IsReliable boolean
    @param Callback (Address: Player, ...Packet?) -> ()
    @return RBXScriptConnection
    @within ServerNetwork
    Listens for data from the client.
]=]
function ServerNetwork.ListenForPacket(Name: string, IsReliable: boolean, Callback: (Address: Player, ...Packet?) -> ()): RBXScriptConnection
    assert(Name, "Expected string as first argument.")
    assert(Callback, "Expected boolean as second argument.")
    assert(Callback, "Expected function as third argument.")

    local connection
    local signal = ReturnSignal(Name, IsReliable)
    assert(signal, "Error finding signal " .. Name)

    if signal.ClassName == "RemoteEvent" then
        connection = (signal:: RemoteEvent).OnServerEvent:Connect(Callback)
    else
        connection = (signal:: UnreliableRemoteEvent).OnServerEvent:Connect(Callback)
    end

    assert(connection, "Error connecting to signal " .. Name)
    return connection
end

--[=[
    @param Name string
    @param Callback (Address: Player, ...Packet?) -> ...any
    @return ()
    @within ServerNetwork
    Listens for a request from the client. The client expects a return value so make sure your function returns something.
]=]
function ServerNetwork.ListenForRequest(Name: string, Callback: (Address: Player, ...Packet?) -> ...any): ()
    assert(Name, "Expected string as first argument.")
    assert(Callback, "Expected function as second argument.")

    local Function = ReturnFunction(Name)
    Function.OnServerInvoke = Callback
end

return ServerNetwork