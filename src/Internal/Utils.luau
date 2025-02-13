--!strict
local Utils = {}

-- Creates a table with only specified keys with the mapping function
function Utils.Map<T, RETURN>(Table: {T}, Mapping: (value: T) -> RETURN)
	assert(type(Table) == "table", "Expected a table as the first argument.")
    assert(typeof(Mapping) == "function", "Expected a function as the second argument.")

	local newTable = table.create(#Table)

	for Index, Value in pairs(Table) do
		newTable[Index] = Mapping(Value)
	end

	return newTable
end

-- Runs a reducer function on a table and returns a single value based on the accumulator
function Utils.Reduce<T, U>(Table: {T}, Function: (accumulator: U, value: T) -> U, Initial: U): U
	assert(Table, "Table is not valid")
	assert(typeof(Function) == "function", "Function expected as second argument")

	local result = Initial
	for _, v in ipairs(Table) do
		result = Function(result, v)
	end

	return result
end

-- Filters out values in a table based on the predicate function
function Utils.Filter<T>(Table: {T}, Predicate: (value: T) -> boolean): {T}
	assert(Table, "Table is not valid")
	assert(typeof(Predicate) == "function", "Predicate function expected as second argument")

	local newTable = {}

	for index, value in pairs(Table) do
		if not Predicate(value) then continue end
		table.insert(newTable, value)
	end

	return newTable
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