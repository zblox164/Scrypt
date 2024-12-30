--!strict
local DictionaryFunctions = {}

-- Returns an array of all the keys in a dictionary
function DictionaryFunctions.Keys<K, V>(Dictionary: {[K]: V}): {K}
	assert(type(Dictionary) == "table", "Expected a Dictionary as the first argument.")
	
	local KeysArray = {}
	local Index = 1

	for key, value in pairs(Dictionary) do
		KeysArray[Index] = key
		Index += 1
	end

	return KeysArray
end

-- Returns the length of a dictionary
function DictionaryFunctions.Length<K, V>(Dictionary: {[K]: V}): number
	assert(type(Dictionary) == "table", "Expected a Dictionary as the first argument.")
	
	local Length = 0
	for Key, Value in pairs(Dictionary) do
		Length += 1
	end

	return Length
end

-- Ignore this function
local function DeepCopy<K, V>(Table: {[K]: V}): {[K]: V}
	assert(type(Table) == "table", "Expected a table as the first argument.")
	local CopiedTable = {}

	for key, value in pairs(Table:: {[K]: V}) do
		if type(value) == "table" then
			CopiedTable[key] = DeepCopy(value:: {[K]: V})
			continue
		end

		CopiedTable[key] = value
	end

	return CopiedTable:: {[K]: V}
end

-- Restores empty keys not found in the table based on a template
function DictionaryFunctions.Reconcile<K, V>(Dictionary: {[K?]: V?}, Template: {[K]: V}): {[K]: V}
	assert(type(Dictionary) == "table", "Expected a Dictionary as the first argument.")
	local UpdatedTable = Dictionary

	for key, value in pairs(Template) do
		if UpdatedTable[key] == nil then
			if type(value) == "table" then
				UpdatedTable[key] = DeepCopy(value)
				continue
			end

			UpdatedTable[key] = value
		elseif type(UpdatedTable[key]) == "table" and type(value) == "table" then
			DictionaryFunctions.Reconcile(UpdatedTable[key]:: {[K?]: V?}, value)
		end
	end

	return UpdatedTable
end

-- Returns all values in a dictionary as an array
function DictionaryFunctions.Values<K, V>(Dictionary: {[K]: V}): {V}
	assert(type(Dictionary) == "table", "Expected a Dictionary as the first argument.")
	
	local ValuesArray = {}
	local Index = 1

	for key, value in pairs(Dictionary) do
		ValuesArray[Index] = value
		Index += 1
	end

	return ValuesArray
end

return DictionaryFunctions