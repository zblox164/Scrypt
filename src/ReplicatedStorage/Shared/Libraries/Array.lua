--!strict
local ArrayUtilities = {}

-- Checks if the elements in the array are all a certain type
function ArrayUtilities.AllType<T>(Table: {T}, Predicate: (value: T) -> boolean): boolean
	assert(type(Table) == "table", "Expected a table as the first argument.")
	assert(typeof(Predicate) == "function", `Library.Functions.Array.AllType expects function, got: {typeof(Table)}`)
	
	for index, value in ipairs(Table) do
		-- If the predicate returns false, return false immediately
		if not Predicate then
			return false
		end
	end
	
	-- If the loop completes without returning false, all elements passed the condition
	return true
end

-- Deep Copies a table
function ArrayUtilities.DeepCopy<K, V>(Table: {[K]: V}): {[K]: V}
	assert(type(Table) == "table", "Expected a table as the first argument.")
	local CopiedTable = {}

	for key, value in pairs(Table) do
		if type(value) == "table" then
			CopiedTable[key] = ArrayUtilities.DeepCopy(value:: {[K]: V})
			continue
		end

		CopiedTable[key] = value
	end

	return CopiedTable:: {[K]: V}
end

-- Filters out a certain value in a table
function ArrayUtilities.Filter<T>(Table: {T}, Predicate: (value: T) -> boolean): {T}
	assert(Table, "Table is not valid")
	assert(typeof(Predicate) == "function", "Predicate function expected as second argument")

	local NewTable = {}

	for Index, Value in pairs(Table) do
		if not Predicate(Value) then continue end
		table.insert(NewTable, Value)
	end

	return NewTable
end

-- Creates a new array by applying a callback function to each element of the input array.
-- If the callback returns a non-nil value, that value is included in the new array.
function ArrayUtilities.FilterMap<T>(Array: {T}, Callback: (T, number) -> (any?)): {T}
	assert(type(Array) == "table", "Expected a table as the first argument.")
	assert(typeof(Callback) == "function", "Callback function expected as second argument")

	local NewArray = {}
	local Index = 1

	for i = 1, #Array, 1 do
		local Result = Callback(Array[i], i)
		if Result == nil then continue end

		NewArray[Index] = Result
		Index += 1
	end

	return NewArray
end

-- Flattens a nested array into a single 1-dimensional array
function ArrayUtilities.Flatten<T>(Array: {T}): {T}
	assert(type(Array) == "table", "Expected a table as the first argument.")
	
	-- Helper function to recursively flatten arrays
	local function FlattenHelper(array: {T}, accumulator: {T}): {T}
		for _, value in ipairs(array) do
			if type(value) == "table" then
				-- Recursively flatten nested arrays
				accumulator = FlattenHelper(value:: {T}, accumulator)
			else
				-- Add value to accumulator
				table.insert(accumulator, value)
			end
		end
		
		return accumulator
	end

	-- Start the flattening process
	return FlattenHelper(Array, {})
end

-- Checks if any value in the table satisfies the predicate function
function ArrayUtilities.HasValue<T>(Table: {T}, Predicate: (value: T) -> boolean): boolean
	assert(type(Table) == "table", "Expected a table as the first argument.")

	for i, value in ipairs(Table) do
		if Predicate(value) then
			return true
		end
	end

	return false
end

-- Returns a new array only containing elements within the range specified
function ArrayUtilities.GetRange<T>(Array: {T}, StartIndex: number, EndIndex: number)
	assert(type(Array) == "table", "Expected a table as the first argument.")
	assert(StartIndex <= EndIndex, "startIndex must be less than or equal to endIndex")
	
	-- Use the array slice to extract the range directly, avoiding mutable state
	local NewTable = {}
	for i = StartIndex, EndIndex do
		table.insert(NewTable, Array[i])
	end
	
	return NewTable
end

-- Joins array elements into a string format separated by a separator string and returns it
function ArrayUtilities.Join<T>(Array: {T}, Separator: string): string
	assert(type(Array) == "table", "Expected a table as the first argument.")
	assert(type(Separator) == "string", "Expected separator string as second argument.")

	-- Handle empty array or no separator provided
	if #Array <= 0 then return "" end

	Separator = Separator or ""
	
	-- Use map to convert elements and join them using the separator
	return table.concat(ArrayUtilities.Map(Array, tostring), Separator)
end

-- Creates a table with only specified keys with the mapping function
function ArrayUtilities.Map<T, RETURN>(Table: {T}, Mapping: (value: T) -> RETURN)
	assert(type(Table) == "table", "Expected a table as the first argument.")
	
	local NewTable = table.create(#Table)

	for Index, Value in pairs(Table) do
		NewTable[Index] = Mapping(Value)
	end

	return NewTable
end

-- Pops/removes the last element of the array and returns it
function ArrayUtilities.Pop<T>(Array: {T}): T?
	assert(type(Array) == "table", "Expected a table as the first argument.")

	-- Check if the table is empty
	if #Array == 0 then return {} end

	-- Remove and return the last element using table.remove
	local NewArray = table.create(1 - #Array, table.remove(Array, #Array))
	return NewArray
end

-- Pushes an element to the end of the array
function ArrayUtilities.Push<T>(Array: {T}, Element: T): {T}
	-- Check if the input is a valid table
	assert(type(Array) == "table", "Expected a table as the first argument.")

	-- Return a new array with the element appended
	local NewArray = {table.unpack(Array)}  -- Create a copy of the original array
	NewArray[#NewArray + 1] = Element      -- Add the new element
	return NewArray  -- Return the new array
end

-- Returns an array without certain elements if they are within the range specified
function ArrayUtilities.RemoveRange<T>(Array: {T}, StartIndex: number, EndIndex: number): {T}
	assert(type(Array) == "table", "Expected a table as the first argument.")
	assert(StartIndex <= EndIndex, "StartIndex must be less than or equal to EndIndex")

	-- Create a new array by filtering out the elements in the specified range
	local NewArray = {}
	for i = 1, #Array do
		if i < StartIndex or i > EndIndex then
			table.insert(NewArray, Array[i])  -- Add to new array if it's outside the range
		end
	end

	return NewArray
end

-- Reverses a table
function ArrayUtilities.Reverse<T>(Array: {T}): {T}
	-- Check if the input is a valid table
	assert(type(Array) == "table", "Expected a table as the first argument.")

	-- Loop through the original array in reverse order and insert elements into the new table
	local ReversedArray = {}
	for i = #Array, 1, -1 do
		table.insert(ReversedArray, Array[i])
	end

	return ReversedArray
end

-- Removes the first element of the array and returns it along with the new array
function ArrayUtilities.Shift<T>(Array: {T}): ({T}, T?)
	assert(type(Array) == "table", "Expected a table as the first argument.")

	-- Return nil if the array is empty
	if #Array == 0 then return {}, nil; end

	-- Create a new array excluding the first element and return it along with the removed element
	local NewArray = {}
	for i = 2, #Array, 1 do
		NewArray[i - 1] = Array[i]
	end

	return NewArray, Array[1]
end

-- Returns a sorted array without mutating the original array
function ArrayUtilities.Sort<T>(Array: {T}, Predicate: ((T, T) -> boolean)?): {T}
	assert(type(Array) == "table", "Expected a table as the first argument.")

	local SortedArray = table.create(#Array)
	for i = 1, #Array, 1 do
		SortedArray[i] = Array[i]
	end

	table.sort(SortedArray, Predicate)
	return SortedArray
end

return ArrayUtilities