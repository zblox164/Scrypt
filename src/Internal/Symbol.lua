--!strict
--[[
	@details
	An implementation of symbols that can be used to create custom symbols.

	@file Symbol.lua
    @shared
    @author zblox164
    @version 1.0.1
    @since 2024-12-17

--]]

export type Symbol = typeof(newproxy(true)) & {[string]: any}

--[=[
	@within ScryptClient
	@type Symbol typeof(newproxy(true)) & {[string]: any}
]=]

--[=[
	@within ScryptServer
	@type Symbol typeof(newproxy(true)) & {[string]: any}
]=]

--[=[
	@within ScryptClient
	@param Name string?
	@return Symbol
]=]

--[=[
	@within ScryptServer
	@param Name string?
	@return Symbol
]=]
local function Symbol(Name: string?): Symbol
	local NewSymbol = newproxy(true)
	local NewName = Name or "Symbol"
	assert(typeof(NewName) == "string", "Name must be a string")
	
	getmetatable(NewSymbol).__tostring = function()
		return NewName
	end
	
	return NewSymbol
end

return Symbol