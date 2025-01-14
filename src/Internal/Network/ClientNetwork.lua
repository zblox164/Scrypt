--!strict
--[[
	@details
	An module containing functions to communicate with the server.

	@file ClientNetwork.lua
    @client
    @author zblox164
    @version 0.0.41-alpha
    @since 2024-12-17
--]]

--[=[
    @class ClientNetwork
    :::danger NOTICE
    Scrypt is in very **early stages** of development. Expect changes and bugs during this phase. If you find a bug or have a suggestion for how to improve Scrypt, please contact zblox164 and provide relevant details.
    :::
]=]
local ClientNetwork = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[=[
    @type Packet number | string | {ClientPacketData} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
    @within ClientNetwork
]=]

--[=[
    @interface ClientPacketData 
    .Data Packet
    .Reliable boolean
    @within ClientNetwork 
]=]
export type Packet = number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
export type ClientPacketData = {
    Data: Packet,
    Reliable: boolean
}

type Result<T> = {
    Success: boolean,
    Value: T?,
    Error: string?
}

-- Pure function to validate remote creation params
local function ValidateParams(Name: string, Remotes: Instance?): Result<string>
    if not Name then
        return { Success = false, Error = "Expected string as first argument" }:: Result<string>
    end

    if not Remotes then 
        return { Success = false, Error = "Attempt to create function before network was loaded" }:: Result<string>
    end

    return { Success = true, Value = Name }:: Result<string>
end

-- Creates and returns a function
local function CreateFunction(Name: string): RemoteFunction
    assert(Name, "Expected string as first argument.")

    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Attempt to create function before network was loaded!")

    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Attempt to create function before network was loaded!")

    local CreateRemote = Functions:WaitForChild("CreateRemote"):: RemoteFunction
    local FunctionName = CreateRemote:InvokeServer(false, Name):: string
    
    local Function = Functions:WaitForChild(FunctionName)
    assert(Function, "Error creating function!")

    return Function:: RemoteFunction
end

-- Creates and returns a remote
local function CreateRemote(Name: string, IsSignal: boolean, IsReliable: boolean): Instance
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Attempt to create remote before network was loaded!")

    local Category = if IsSignal then "Signals" else "Functions"
    local Container = Remotes:FindFirstChild(Category)
    assert(Container, "Attempt to create remote before network was loaded!")
    
    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Attempt to create remote before network was loaded!")

    local CreateRemoteFunc = Functions:WaitForChild("CreateRemote"):: RemoteFunction
    local RemoteName = CreateRemoteFunc:InvokeServer(IsSignal, Name, IsReliable):: string

    local Remote = Container:WaitForChild(RemoteName)
    assert(Remote, "Error creating remote!")

    return Remote
end

-- Function to get or create remote
local function GetOrCreateRemote(Name: string, Container: Folder, IsReliable: boolean): Instance
    local Existing = Container:FindFirstChild(Name)
    if Existing then
        return Existing
    end
    
    return CreateRemote(Name, true, IsReliable)
end

-- Finds unreliable signal based on name
local function GetUnreliableEvent(Name: string, Signals: Folder): UnreliableRemoteEvent  
    local Validation = ValidateParams(Name, Signals)
    assert(Validation.Success, Validation.Error)
    return GetOrCreateRemote(Name, Signals, false):: UnreliableRemoteEvent
end

-- Finds signal based on name
local function GetEvent(Name: string, Signals: Folder): RemoteEvent
    local Validation = ValidateParams(Name, Signals)
    assert(Validation.Success, Validation.Error)
    return GetOrCreateRemote(Name, Signals, true):: RemoteEvent
end

-- Finds signal based on name and reliability
local function FindSignal(Name: string, Signals: Folder, IsReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local NewSignal = if IsReliable then GetEvent(Name, Signals) else GetUnreliableEvent(Name, Signals)
    print(typeof(NewSignal), NewSignal)
    assert(NewSignal.ClassName == "RemoteEvent" or NewSignal.ClassName == "UnreliableRemoteEvent", "Error finding signal " .. Name)

    return NewSignal
end

-- Returns a function based on the name and creates one if it does not exist
local function ReturnFunction(Name: string): RemoteFunction
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication")
    assert(Remotes, "Attempt to use function before network was loaded!")

    local Functions = Remotes:FindFirstChild("Functions")
    assert(Functions, "Attempt to use function before network was loaded!")

    local NewFunction: RemoteFunction = Functions:FindFirstChild(Name):: RemoteFunction

    if not NewFunction then
        NewFunction = CreateFunction(Name)
    end

    assert(NewFunction, "Error finding signal " .. Name)
    return NewFunction
end

-- Returns a signal based on the name and reliability
local function ReturnSignal(Name: string, IsReliable: boolean): RemoteEvent | UnreliableRemoteEvent
    local Remotes = ReplicatedStorage:FindFirstChild("ScryptCommunication"):: Folder
    assert(Remotes, "Attempt to use signal before network was loaded!")

    local Signals = Remotes:FindFirstChild("Signals"):: Folder
    assert(Signals, "Attempt to use signal before network was loaded!")

    local NewSignal = FindSignal(Name, Signals, IsReliable)
    assert(NewSignal, "Error finding signal " .. Name)

    return NewSignal
end

--[=[
    @return Folder
    @yields
    @private
    @within ClientNetwork
]=]
function ClientNetwork.Init(): Folder
    local Location: Folder = ReplicatedStorage:WaitForChild("ScryptCommunication"):: Folder
    Location:WaitForChild("Signals")
    Location:FindFirstChild("Functions")

    return Location
end

--[=[
    @param Name string
    @param PacketData ClientPacketData
    @within ClientNetwork
    Sends data to the server.
]=]
function ClientNetwork.SendPacket(Name: string, PacketData: ClientPacketData)
    assert(Name, "Expected string as first argument.")
    assert(PacketData, "Expected ClientPacketData as second argument.")
    
    local Signal = ReturnSignal(Name, PacketData.Reliable)
    if Signal:IsA("RemoteEvent") then
        (Signal:: RemoteEvent):FireServer(PacketData.Data)
    else
        (Signal:: UnreliableRemoteEvent):FireServer(PacketData.Data)
    end
end

--[=[
    @param Name string
    @param IsReliable boolean
    @within ClientNetwork
    Pings the server. This function should be used when you want to communicate with the server but don't want to send any data.
]=]
function ClientNetwork.PingServer(Name: string, IsReliable: boolean)
    assert(Name, "Expected string as first argument.")

    local Signal = ReturnSignal(Name, IsReliable)
    if Signal:IsA("RemoteEvent") then
        (Signal:: RemoteEvent):FireServer()
    else
        (Signal:: UnreliableRemoteEvent):FireServer()
    end
end

--[=[
    @param Name string
    @param IsReliable boolean
    @param Callback (...Packet) -> ()
    @return RBXScriptConnection
    @within ClientNetwork
    Listens for data from the server.
]=]
function ClientNetwork.ListenForPacket(Name: string, IsReliable: boolean, Callback: (...Packet) -> ()): RBXScriptConnection
    assert(Name, "Expected string as first argument.")
    assert(Callback, "Expected boolean as second argument.")
    assert(Callback, "Expected function as third argument.")
    
    local Connection
    local Signal = ReturnSignal(Name, IsReliable)
    Connection = (Signal.OnClientEvent:: RBXScriptSignal):Connect(Callback)
    return Connection
end

--[=[
    @param Name string
    @param Packet Packet
    @return Packet
    @yields
    @within ClientNetwork
    Sends and requests data from the server.
]=]
function ClientNetwork.RequestPacket(Name: string, Packet: Packet): Packet
    assert(Name, "Expected string as first argument.")
    assert(Packet, "Expected Packet as second argument.")

    local Function = ReturnFunction(Name)
    local Request = Function:InvokeServer(Packet)
    return Request
end

--[=[
    @param Name string
    @yields
    @within ClientNetwork
    Requests a packet from the server without sending data. This function should be used when you want to request a response from the server but don't want to send any data.
]=]
function ClientNetwork.EmptyRequest(Name: string): Packet
    assert(Name, "Expected string as first argument.")

    local Function = ReturnFunction(Name)
    local Request = Function:InvokeServer()
    return Request
end

type ClientNetwork = {
    SendPacket: (Name: string, Packet: ClientPacketData) -> (),
    PingServer: (Name: string, IsReliable: boolean) -> (),
    RequestPacket: (Name: string, Packet: ClientPacketData) -> Packet,
    EmptyRequest: (Name: string) -> Packet,
    ListenForPacket: (Name: string, IsReliable: boolean, Callback: (...ClientPacketData) -> ()) -> RBXScriptConnection,
    Init: () -> Folder,
}

return ClientNetwork