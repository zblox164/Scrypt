--!strict
--[[
	@details
	A simple implementation of the Maybe monad in Luau

	@file Monad.luau
    @server
    @author zblox164
    @version 0.0.5-alpha
    @since 2024-12-17
--]]

type Maybe<T> = {
    bind: (self: Maybe<T>, func: (T) -> Maybe<T>) -> Maybe<T>,
    map: (self: Maybe<T>, func: (T) -> T) -> Maybe<T>,
    fromMaybe: (self: Maybe<T>, default: T) -> T,
    isJust: (self: Maybe<T>) -> boolean,
    isNothing: (self: Maybe<T>) -> boolean,
    value: T | nil,
}

local function Just<T>(value: T): Maybe<T>
    return {
        bind = function(self, func: (T) -> Maybe<any>)
            return func(self.value)
        end,
        map = function(self, func: (T) -> any)
            return Just(func(self.value))
        end,
        fromMaybe = function(self, _default: T)
            return self.value
        end,
        isJust = function(self)
            return true
        end,
        isNothing = function(self)
            return false
        end,

        value = value,
    }
end

local function Nothing<T>(): Maybe<T>
    return {
        bind = function(self, _func: (T) -> Maybe<any>)
            return Nothing()
        end,
        map = function(self, _func: (T) -> any)
            return Nothing()
        end,
        fromMaybe = function(self, default: T)
            return default
        end,
        isJust = function(self)
            return false
        end,
        isNothing = function(self)
            return true
        end,

        value = nil,
    }
end

return {
    Maybe = {
        ["Just"] = Just,
        ["Nothing"] = Nothing
    },
}