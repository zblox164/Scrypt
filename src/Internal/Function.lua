--!strict
--[[
	@details
	A implementation of bindable functions that can be used to create custom functions.

	@file Function.lua
    @shared
    @author zblox164
    @version 0.1.0-beta
    @since 2024-12-17
--]]

local HttpService = game:GetService("HttpService")
local Function: FunctionImpl = {}:: FunctionImpl
Function.__index = Function

export type Function = typeof(setmetatable({}:: {
	Function: ((...any) -> ...any)?,
	YieldedCalls: {thread?}
}, {}:: FunctionImpl))

export type FunctionImpl = {
	__index: FunctionImpl,
	New: () -> Function,
	OnInvoke: (self: Function, ReturnFunction: (...any) -> ...any) -> (),
	Invoke: (self: Function, ...any) -> ...any,
	Destroy: (self: Function) -> ()
}

-- Create new custom function
function Function.New(): Function
	local FunctionInfo = {
		Function = nil,
		YieldedCalls = {}:: {thread?}
	}:: Function
	return setmetatable(FunctionInfo, Function)
end

-- Set the OnInvoke function
function Function:OnInvoke(ReturnFunction: (...any) -> ...any)
	assert(ReturnFunction and typeof(ReturnFunction) == "function", `Expected 'function' got: {typeof(Function)}`)
	self.Function = ReturnFunction
end

-- Invoke the function
function Function:Invoke(...: any): ...any	
	assert(self.Function, "Function is not valid.")

	local Result = self.Function(...)

	for index, yield in ipairs(self.YieldedCalls) do
		coroutine.resume(yield:: thread, Result)
		table.remove(self.YieldedCalls, index)
	end

	return Result
end

-- Destroys a function and its connections
function Function:Destroy()
	for _, yield in ipairs(self.YieldedCalls) do
		coroutine.resume(yield:: thread)
	end

	setmetatable(self, nil)
end

local FunctionManager = {}
local Functions = {}

-- Make sure that all scripts use the same function instance
function FunctionManager.New(FunctionName: string?, Private: boolean?): Function
	if not FunctionName or typeof(FunctionName) ~= "string" then
		FunctionName = `{HttpService:GenerateGUID(false)}Function`
	end

	if not Functions[FunctionName] and not Private then
		Functions[FunctionName] = Function.New()
		return Functions[FunctionName]
	end

	if not Private then return Functions[FunctionName] end

	return Function.New()
end

return FunctionManager