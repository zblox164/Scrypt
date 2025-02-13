--!strict
--[[
	@details
	An implementation of bindable events that can be used to create custom events.

	@file Signal.lua
    @shared
    @author zblox164
    @version 0.1.1-beta
    @since 2024-12-17
--]]

local HttpService = game:GetService("HttpService")
local Signal: SignalImpl = {}:: SignalImpl
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

export type Signal = typeof(setmetatable({}:: {
	Connections: {SignalConnection?},
	YieldedConnections: {thread?}
}, {}:: SignalImpl))

export type SignalImpl = {
	__index: SignalImpl,
	New: () -> Signal,
	Connect: (self: Signal, Function: CallbackFunction) -> SignalConnection?,
	Once: (self: Signal, Function: CallbackFunction) -> SignalConnection?,
	Wait: (self: Signal) -> (),
	Disconnect: (self: Signal) -> (),
	DisconnectAll: (self: Signal) -> (),
	Fire: (self: Signal, ...any) -> (),
}

export type CallbackFunction = (...any) -> ...any
export type SignalConnection = typeof(setmetatable({}:: {
	Function: CallbackFunction,
	IsOnce: boolean,
	Self: Signal,
}, Connection))

-- Create new signal (equivalent to bindable event)
function Signal.New(): Signal
	local SignalInfo = {
		Connections = {}:: {SignalConnection?},
		YieldedConnections = {}:: {thread?}
	}
	return setmetatable(SignalInfo, Signal)
end

-- Fire a signal
function Signal:Fire(...)
	for index, connection in ipairs(self.Connections:: {SignalConnection}) do
		coroutine.wrap(connection.Function)(...)
		if connection.IsOnce then connection:Disconnect() end
	end

	for index, yield in ipairs(self.YieldedConnections) do
		coroutine.resume(yield:: thread, ...)
		table.remove(self.YieldedConnections, index)
	end
end

-- Connect to signal
function Signal:Connect(Function: CallbackFunction): SignalConnection?	
	assert(Function and typeof(Function) == "function", `"Expected 'function' got: {typeof(Function)}`)

	local connectionInfo = {
		Function = Function,
		IsOnce = false,
		Self = self,
	}
	local newConnection = setmetatable(connectionInfo, Connection)

	table.insert(self.Connections, newConnection)
	return newConnection
end

function Signal:Once(Function: CallbackFunction): SignalConnection
	assert(Function and typeof(Function) == "function", `"Expected 'function' got: {typeof(Function)}`)

	local connectionInfo = {
		Function = Function,
		IsOnce = true,
		Self = self,
	}
	local newConnection = setmetatable(connectionInfo, Connection)

	table.insert(self.Connections, newConnection)
	return newConnection
end

-- Waits for the signal to fire
function Signal:Wait()
	table.insert(self.YieldedConnections, coroutine.running())
	return coroutine.yield()
end

-- Disconnects a signal connection
function Connection:Disconnect()
	for index, connection in ipairs(self.Self.Connections) do
		if connection ~= self then continue end
		table.remove(self.Self.Connections, index)
	end

	setmetatable(self, nil)
end

-- Destroys a signal and it's connections
function Signal:DisconnectAll()
	for index, connection in ipairs(self.Connections:: {SignalConnection}) do
		connection:Disconnect()
	end

	for index, yield in ipairs(self.YieldedConnections) do
		coroutine.resume(yield:: thread)
	end

	setmetatable(self, nil)
end

local SignalManager = {}
local Signals = {}

-- Make sure that all scripts use the same signal instance
function SignalManager.New(SignalName: string, Private: boolean?): Signal
	if not SignalName or typeof(SignalName) ~= "string" then
		SignalName = `{HttpService:GenerateGUID(false)}Signal`
	end

	if not Signals[SignalName] and not Private then
		Signals[SignalName] = Signal.New()
		return Signals[SignalName]
	end

	if not Private then return Signals[SignalName] end

	return Signal.New()
end

return SignalManager