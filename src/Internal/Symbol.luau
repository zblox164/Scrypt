--!strict
--[[
	@details
	An implementation of symbols that can be used to create custom symbols.

	@file Symbol.lua
    @shared
    @author zblox164
    @version 1.0.2
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
	local newSymbol = newproxy(true)
	local newName = Name or "Symbol"
	assert(typeof(newName) == "string", "Name must be a string")

	getmetatable(newSymbol).__tostring = function()
		return newName
	end

	return newSymbol
end

return Symbol