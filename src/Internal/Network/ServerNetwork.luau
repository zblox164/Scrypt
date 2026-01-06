--!strict
--[[
	@details
	An module containing functions to communicate with the client.

	@file ClientNetwork.luau
    @server
    @author zblox164
    @version 0.0.63-alpha
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
    @type Packet number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor | {[string]: Packet}
    @within ServerNetwork
]=]

--[=[
    @interface ServerPacketData
    .Address Player
    .Reliable boolean
    .Data Packet
    @within ServerNetwork
]=]
export type Packet = number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor | {[string]: Packet}
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
    if not validation.Success then return warn(validation.Error) end

    local newSignal = CreateRemoteInstance(name, isReliable)
    if not newSignal.Success then return warn(newSignal.Error) end
    if not newSignal.Value then return warn("Error creating signal " .. name) end

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

    if not newUnreliableSignal then return warn("Error finding signal " .. name) end
    return newUnreliableSignal
end

-- Function to get or create a signal
local function GetEvent(name: string, signals: Folder): RemoteEvent
    local newSignal: RemoteEvent = signals:FindFirstChild(name):: RemoteEvent
    if not newSignal then
        newSignal = CreateSignal(name, signals, true):: RemoteEvent
    end

    if not newSignal then return warn("Error finding signal " .. name) end
    return newSignal
end

local function FindSignal(name: string, signals: Folder, isReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local newSignal = if isReliable then GetEvent(name, signals) else GetUnreliableEvent(name, signals)
    if not newSignal or not ((newSignal.ClassName == "RemoteEvent") or (newSignal.ClassName == "UnreliableRemoteEvent")) then
        return
    end

    return newSignal
end

-- Pure function to create function
local function CreateFunction(name: string, location: Instance): RemoteFunction
    local validation = ValidateParams(name, location)
    if not validation.Success then return warn(validation.Error) end

    local newFunction = Instance.new("RemoteFunction")
    newFunction.Name = name
    newFunction.Parent = location

    return newFunction
end

-- Returns a signal based on the name and reliability
local function ReturnSignal(name: string, isReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    if not remotes then return warn("Attempt to use event before network was loaded!") end

    local signals = remotes:FindFirstChild("Signals"):: Folder
    if not signals then return warn("Attempt to use event before network was loaded!") end

    local newSignal = FindSignal(name, signals, isReliable)
    if not newSignal or (not (newSignal.ClassName == "RemoteEvent") and not (newSignal.ClassName == "UnreliableRemoteEvent")) then
        return warn("Error finding signal " .. name)
    end

    return newSignal
end

-- Returns a function based on the name
local function ReturnFunction(name: string): RemoteFunction
    local remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    if not remotes then return warn("Attempt to use function before network was loaded!") end

    local functions = remotes:FindFirstChild("Functions")
    if not functions then return warn("Attempt to use function before network was loaded!") end

    local newFunction: RemoteFunction = functions:FindFirstChild(name):: RemoteFunction
    if not newFunction then
        newFunction = CreateFunction(name, functions)
    end

    if not newFunction then return warn("Error finding signal " .. name) end
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
        return warn(validationResult.Error)
    end

    local configResult = DetermineRemoteConfig(params)
    if not configResult.Success then
        return warn(configResult.Error)
    end

    local config = configResult.Value:: RemoteCreateResult
    local rootFolderResult = VerifyNetworkIntegrity():: Result<Folder>
    if not rootFolderResult.Success then return warn(rootFolderResult.Error) end

    local rootFolder = rootFolderResult.Value:: Folder
    if not rootFolder then return warn("Error finding root folder") end

    -- Create instance (this is the only impure operation)
    local newRemote = Instance.new(config.RemoteType)
    newRemote.Name = config.Name
    newRemote.Parent = rootFolder:FindFirstChild(config.Parent)

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
    if not rootFolder.Success then return warn(rootFolder.Error) end
    if not rootFolder.Value then return warn("Error finding root folder") end

    local functionFolder = rootFolder.Value:FindFirstChild("Functions")
    if not functionFolder then return warn("Error finding functions folder") end

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
    if typeof(Name) ~= "string" then return warn("Expected string a first argument.") end
    if not PacketData then return warn("Expected ServerPacketData as second argument.") end
    if not PacketData.Address or typeof(PacketData.Address) ~= "Instance" then return warn("Expected ServerPacketData as second argument.") end
    if not PacketData.Data then return warn("Expected ServerPacketData as second argument.") end
    if PacketData.Reliable == nil or typeof(PacketData.Reliable) ~= "boolean" then return warn("Expected ServerPacketData as second argument.") end

    local packetType = typeof(PacketData.Data)
    local isInstance = packetType == "Instance"
    local sendData = if isInstance
        then (PacketData.Data:: Instance):GetFullName()
        else PacketData.Data

    local signal = ReturnSignal(Name, PacketData.Reliable)
    if signal.ClassName == "RemoteEvent" then
        (signal:: RemoteEvent):FireClient(PacketData.Address, isInstance, sendData)
    else
        (signal:: UnreliableRemoteEvent):FireClient(PacketData.Address, isInstance, sendData)
    end
end

--[=[
    @param Name string
    @param IsReliable boolean
    @param Packet Packet
    @within ServerNetwork
    Sends data to all clients in a server.
]=]
function ServerNetwork.SendPacketToAllClients(Name: string, IsReliable: boolean, Packet: Packet)
    if typeof(Name) ~= "string" then return warn("Expected string a first argument.") end
    if typeof(IsReliable) ~= "boolean" then return warn("Expected boolean as second argument.") end
    if Packet == nil then return warn("Expected Packet as third argument.") end

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
    if typeof(Name) ~= "string" then return warn("Expected string a first argument.") end
    if not Address or typeof(Address) ~= "Instance" then return warn("Expected Player as second argument.") end
    if typeof(IsReliable) ~= "boolean" then return warn("Expected boolean as third argument.") end

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
    if typeof(Name) ~= "string" then return warn("Expected string a first argument.") end
    if typeof(IsReliable) ~= "boolean" then return warn("Expected boolean as second argument.") end

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
    if typeof(Name) ~= "string" then return warn("Expected string a first argument.") end
    if typeof(IsReliable) ~= "boolean" then return warn("Expected boolean as second argument.") end
    if typeof(Callback) ~= "function" then return warn("Expected function as third argument.") end

    local connection
    local signal = ReturnSignal(Name, IsReliable)
    if not signal then return warn("Error finding signal " .. Name) end

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
    @param IsReliable boolean
    @param Callback (Address: Player) -> ()
    @return RBXScriptConnection
    @within ServerNetwork
    @since v0.0.6-alpha
    Listens for client signals without receving data.
]=]
function ServerNetwork.Listen(Name: string, IsReliable: boolean, Callback: (Address: Player) -> ()): RBXScriptConnection
    if typeof(Name) ~= "string" then return warn("Expected string a first argument.") end
    if typeof(IsReliable) ~= "boolean" then return warn("Expected boolean as second argument.") end
    if typeof(Callback) ~= "function" then return warn("Expected function as third argument.") end

    local connection
    local signal = ReturnSignal(Name, IsReliable)
    if not signal then return warn("Error finding signal " .. Name) end

    if signal.ClassName == "RemoteEvent" then
        connection = (signal:: RemoteEvent).OnServerEvent:Connect(function(Address: Player)
            Callback(Address)
        end)
    else
        connection = (signal:: UnreliableRemoteEvent).OnServerEvent:Connect(function(Address: Player)
            Callback(Address)
        end)
    end

    assert(connection, "Error connecting to signal " .. Name)
    return connection
end

--[=[
    @param Name string
    @param Callback (Address: Player, ...Packet?) -> ...any
    @return ()
    @within ServerNetwork
    Listens for a request and receives data from the client. The client expects a return value so make sure your function returns something.
]=]
function ServerNetwork.ListenForRequestPacket(Name: string, Callback: (Address: Player, ...Packet?) -> ...any): ()
    if typeof(Name) ~= "string" then return warn("Expected string a first argument.") end
    if typeof(Callback) ~= "function" then return warn("Expected function as second argument.") end

    local Function = ReturnFunction(Name)
    Function.OnServerInvoke = Callback
end

--[=[
    @param Name string
    @param Callback (Address: Player) -> ...any
    @return ()
    @within ServerNetwork
    @since v0.0.6-alpha
    Listens for a request from the client. The client expects a return value so make sure your function returns something.
]=]
function ServerNetwork.ListenForRequest(Name: string, Callback: (Address: Player) -> ...any): ()
    if typeof(Name) ~= "string" then return warn("Expected string a first argument.") end
    if typeof(Callback) ~= "function" then return warn("Expected function as second argument.") end

    local Function = ReturnFunction(Name)

    local function OnServerInvoke(Player: Player)
        return Callback(Player)
    end
    Function.OnServerInvoke = OnServerInvoke
end

return ServerNetwork