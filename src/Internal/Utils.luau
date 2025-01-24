--!strict
local Utils = {}

-- Creates a table with only specified keys with the mapping function
function Utils.Map<T, RETURN>(Table: {T}, Mapping: (value: T) -> RETURN)
	assert(type(Table) == "table", "Expected a table as the first argument.")
    assert(typeof(Mapping) == "function", "Expected a function as the second argument.")
	
	local NewTable = table.create(#Table)

	for Index, Value in pairs(Table) do
		NewTable[Index] = Mapping(Value)
	end

	return NewTable
end

-- Runs a reducer function on a table and returns a single value based on the accumulator
function Utils.Reduce<T, U>(Table: {T}, Func: (accumulator: U, value: T) -> U, Initial: U): U
	assert(Table, "Table is not valid")
	assert(typeof(Func) == "function", "Function expected as second argument")

	local Result = Initial
	for _, v in ipairs(Table) do
		Result = Func(Result, v)
	end

	return Result
end

-- Filters out values in a table based on the predicate function
function Utils.Filter<T>(Table: {T}, Predicate: (value: T) -> boolean): {T}
	assert(Table, "Table is not valid")
	assert(typeof(Predicate) == "function", "Predicate function expected as second argument")

	local NewTable = {}

	for Index, Value in pairs(Table) do
		if not Predicate(Value) then continue end
		table.insert(NewTable, Value)
	end

	return NewTable
end

-- Returns if a value is empty
function Utils.IsEmpty(Value: any?): boolean
	if type(Value) == "table" then
		return next(Value :: {[any]: any}) == nil
	end

	return Value == nil or Value == ""
end

-- Returns if a value is nil
function Utils.IsNil(Value: any?): boolean
    return Value == nil
end

return Utils