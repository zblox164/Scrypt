--!strict
--[[
	@details
	An module containing functions to communicate with the client.

	@file ClientNetwork.lua
    @server
    @author zblox164
    @version 0.0.4-alpha
    @since 2024-12-17
--]]

--[=[
    @class ServerNetwork
    :::danger NOTICE
    Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please contact zblox164 and provide relevant details.
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
local function ValidateParams(Name: string, Location: Instance?): Result<string>
    if not Name then
        return { Success = false, Error = "Expected string as first argument" }:: Result<string>
    end

    if not Location then 
        return { Success = false, Error = "Expected Instance as second argument" }:: Result<string>
    end

    return { Success = true, Value = Name }:: Result<string>
end

-- Pure function to validate remote params
local function ValidateRemoteParams(Params: RemoteParams): Result<RemoteParams>
    if not Params.Name then
        return { Success = false, Error = "Missing remote name" }:: Result<RemoteParams>
    end
    
    if Params.IsSignal and Params.Reliable == nil then
        return { Success = false, Error = "Reliability must be specified for signals" }:: Result<RemoteParams>
    end

    return { Success = true, Value = Params }:: Result<RemoteParams>
end

-- Returns the root folder for the network and creates necessary subfolders
local function VerifyNetworkIntegrity(): Result<Folder>
    local CommsFolder: Folder = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    if not CommsFolder then
        CommsFolder = Instance.new("Folder")
        CommsFolder.Name = "ScryptCommunication"
        CommsFolder.Parent = ReplicatedStorage
    end

    -- Create subfolders if they don't exist
    local SignalsFolder = CommsFolder:FindFirstChild("Signals") or Instance.new("Folder")
    SignalsFolder.Name = "Signals"
    SignalsFolder.Parent = CommsFolder

    local FunctionsFolder = CommsFolder:FindFirstChild("Functions") or Instance.new("Folder")
    FunctionsFolder.Name = "Functions"
    FunctionsFolder.Parent = CommsFolder

    return { Success = true, Value = CommsFolder }:: Result<Folder>
end

-- Function to create remote instance
local function CreateRemoteInstance(Name: string, IsReliable: boolean): Result<RemoteEvent | UnreliableRemoteEvent>
    local NewEvent = if IsReliable 
        then Instance.new("RemoteEvent") 
        else Instance.new("UnreliableRemoteEvent")
    
    NewEvent.Name = Name
    return { Success = true, Value = NewEvent }:: Result<RemoteEvent | UnreliableRemoteEvent>
end

-- Function to create a new signal
local function CreateSignal(Name: string, Location: Instance, IsReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local Validation = ValidateParams(Name, Location)
    assert(Validation.Success, Validation.Error)

    local NewSignal = CreateRemoteInstance(Name, IsReliable)
    assert(NewSignal.Success, NewSignal.Error)
    assert(NewSignal.Value, "Error creating signal " .. Name)

    NewSignal.Value.Name = Name
    NewSignal.Value.Parent = Location
    return NewSignal.Value
end

-- Function to get or create an unreliable signal
local function GetUnreliableEvent(Name: string, Signals: Folder): UnreliableRemoteEvent
    local NewUnreliableSignal: UnreliableRemoteEvent = Signals:FindFirstChild(Name):: UnreliableRemoteEvent
    if not NewUnreliableSignal then
        NewUnreliableSignal = CreateSignal(Name, Signals, false):: UnreliableRemoteEvent
    end

    assert(NewUnreliableSignal, "Error finding signal " .. Name)
    return NewUnreliableSignal
end

-- Function to get or create a signal
local function GetEvent(Name: string, Signals: Folder): RemoteEvent
    local NewSignal: RemoteEvent = Signals:FindFirstChild(Name):: RemoteEvent
    if not NewSignal then
        NewSignal = CreateSignal(Name, Signals, true):: RemoteEvent
    end

    assert(NewSignal, "Error finding signal " .. Name)
    return NewSignal
end

local function FindSignal(Name: string, Signals: Folder, IsReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local NewSignal = if IsReliable then GetEvent(Name, Signals) else GetUnreliableEvent(Name, Signals)
    assert(NewSignal.ClassName == "RemoteEvent" or NewSignal.ClassName == "UnreliableRemoteEvent", "Error finding signal " .. Name)

    return NewSignal
end

-- Pure function to create function
local function CreateFunction(Name: string, Location: Instance): RemoteFunction
    local Validation = ValidateParams(Name, Location)
    assert(Validation.Success, Validation.Error)
    
    local NewFunction = Instance.new("RemoteFunction")
    NewFunction.Name = Name
    NewFunction.Parent = Location

    return NewFunction
end

-- Returns a signal based on the name and reliability
local function ReturnSignal(Name: string, IsReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    assert(Remotes, "Attempt to use event before network was loaded!")

    local Signals = Remotes:FindFirstChild("Signals"):: Folder
    assert(Signals, "Attempt to use event before network was loaded!")
    
    local NewSignal = FindSignal(Name, Signals, IsReliable)
    assert((NewSignal.ClassName == "RemoteEvent" and IsReliable) or (NewSignal.ClassName == "UnreliableRemoteEvent" and not IsReliable), 
        "Incorrect remote type! Remotes between the client and server may be out of sync! Signal name: " .. Name)
    return NewSignal
end

-- Returns a function based on the name
local function ReturnFunction(Name: string): RemoteFunction
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    assert(Remotes, "Attempt to use function before network was loaded!")

    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Attempt to use function before network was loaded!")

    local NewFunction: RemoteFunction = Functions:FindFirstChild(Name):: RemoteFunction
    if not NewFunction then
        NewFunction = CreateFunction(Name, Functions)
    end

    assert(NewFunction, "Error finding signal " .. Name)
    return NewFunction
end

-- Pure function to determine remote configuration
local function DetermineRemoteConfig(Params: RemoteParams): Result<RemoteCreateResult>
    local RemoteType
    local ParentFolder = if Params.IsSignal then "Signals" else "Functions"
    
    if Params.IsSignal then
        RemoteType = if Params.Reliable then "RemoteEvent" else "UnreliableRemoteEvent"
    else
        RemoteType = "RemoteFunction"
    end
    
    return {
        Success = true,
        Value = {
            RemoteType = RemoteType,
            Name = Params.Name,
            Parent = ParentFolder
        }
    }:: Result<RemoteCreateResult>
end

-- Creates a remote from a request from the client and returns it
local function CreateClientRemote(Params: RemoteParams): Instance
    local ValidationResult = ValidateRemoteParams(Params)
    if not ValidationResult.Success then
        return error(ValidationResult.Error)
    end
    
    local ConfigResult = DetermineRemoteConfig(Params)
    if not ConfigResult.Success then
        return error(ConfigResult.Error)
    end
    
    local Config = ConfigResult.Value:: RemoteCreateResult
    
    -- Create instance (this is the only impure operation)
    local NewRemote = Instance.new(Config.RemoteType)
    NewRemote.Name = Config.Name
    
    return NewRemote
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
    local RootFolder = VerifyNetworkIntegrity():: Result<Folder>
    assert(RootFolder.Success, RootFolder.Error)
    assert(RootFolder.Value, "Error finding root folder")

    local FunctionFolder = RootFolder.Value:FindFirstChild("Functions")
    assert(FunctionFolder, "Error finding functions folder")

    if not FunctionFolder:FindFirstChild("CreateRemote") then
        local NewRemote = Instance.new("RemoteFunction")
        NewRemote.Name = "CreateRemote"
        NewRemote.Parent = FunctionFolder

        NewRemote.OnServerInvoke = function(Player, IsSignal: boolean, Name: string, Reliable: boolean)
            local RemoteCreateParams = {
                Player = Player,
                IsSignal = IsSignal,
                Name = Name,
                Reliable = Reliable
            }:: RemoteParams

            return CreateClientRemote(RemoteCreateParams)
        end
    end
    
    return RootFolder.Value
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
    
    local Signal = ReturnSignal(Name, PacketData.Reliable)
    if Signal.ClassName == "RemoteEvent" then
        (Signal:: RemoteEvent):FireClient(PacketData.Address, PacketData.Data)
    else
        (Signal:: UnreliableRemoteEvent):FireClient(PacketData.Address, PacketData.Data)
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
        local PlayerPacket = {
            Address = player,
            Data = Packet,
            Reliable = IsReliable
        }:: ServerPacketData

        ServerNetwork.SendPacketToClient(Name, PlayerPacket)
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
    
    local Signal = ReturnSignal(Name, IsReliable)
    if Signal.ClassName == "RemoteEvent" then
        (Signal:: RemoteEvent):FireClient(Address)
    else
        (Signal:: UnreliableRemoteEvent):FireClient(Address)
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
    
    local Connection
    local Signal = ReturnSignal(Name, IsReliable)
    assert(Signal, "Error finding signal " .. Name)

    if Signal.ClassName == "RemoteEvent" then
        Connection = (Signal:: RemoteEvent).OnServerEvent:Connect(Callback)
    else
        Connection = (Signal:: UnreliableRemoteEvent).OnServerEvent:Connect(Callback)
    end

    assert(Connection, "Error connecting to signal " .. Name)
    return Connection
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