--!strict
local StringUtilities = {}

-- Same as string.split except it unpacks the returned table
function StringUtilities.Split(String: string, Separator: string?): (...string)
	return unpack(string.split(String, Separator))
end

-- Trims whitespace from the edges of the string
function StringUtilities.Trim(String: string): string?
	local NewString = String:match("^%s*(.-)%s*$")
	return NewString
end

-- Trims whitespace from the beginning of the string
function StringUtilities.TrimStart(String: string): string?
	local NewString = String:match("^%s*(.-)$")
	return NewString
end

-- Trims whitespace from the end of the string
function StringUtilities.TrimEnd(String: string): string?
	local NewString = String:match("^(.-)%s*$")
	return NewString
end

-- Returns a dictionary containing the amount each character occurs in the string
function StringUtilities.CharFrequency(String: string): {[string]: number}
	local Frequency = {}
	
	for Char in String:gmatch(".") do
		Frequency[Char] = (Frequency[Char] or 0) + 1
	end
	
	return Frequency
end

-- Returns the number of times a substring occurs in the string
function StringUtilities.SubstringCount(String: string, Substring: string): number
	local Count = 0
	local Start = 1
	
	while true do
		local StartIndex = String:find(Substring, Start, true)
		if not StartIndex then break end
		
		Count = Count + 1
		Start = StartIndex + #Substring
	end
	
	return Count
end

-- Returns a random string of the specified length
function StringUtilities.RandomString(Length: number): string
	local Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local Result = {}
	
	for _ = 1, Length do
		local Index = math.random(1, #Characters)
		table.insert(Result, Characters:sub(Index, Index))
	end
	
	return table.concat(Result)
end

-- Pads the string with the specified character to the specified length from the left (length includes string size)
function StringUtilities.LeftPad(String: string, Length: number, PaddingChar: string): string
	assert(type(String) == "string", "Expected a string as the first argument.")
	assert(type(Length) == "number", "Expected a number as the second argument.")
	assert(type(PaddingChar) == "string", "Expected a string as the third argument.")
	return PaddingChar:rep(Length - #String) .. String
end

-- Pads the string with the specified character to the specified length from the right (length includes string size)
function StringUtilities.RightPad(String: string, Length: number, PaddingChar: string): string
	assert(type(String) == "string", "Expected a string as the first argument.")
	assert(type(Length) == "number", "Expected a number as the second argument.")
	assert(type(PaddingChar) == "string", "Expected a string as the third argument.")
	return String .. PaddingChar:rep(Length - #String)
end

-- Checks if the string starts with the specified pattern
function StringUtilities.StartsWith(String: string, Pattern: string): boolean
	assert(type(String) == "string", "Expected a string as the first argument.")
	assert(type(Pattern) == "string", "Expected a string as the second argument.")
	assert(#Pattern <= #String, "Pattern must be shorter than the string")
	return String:sub(1, #Pattern) == Pattern
end

-- Checks if the string ends with the specified pattern
function StringUtilities.EndsWith(String: string, Pattern: string): boolean
	assert(type(String) == "string", "Expected a string as the first argument.")
	assert(type(Pattern) == "string", "Expected a string as the second argument.")
	assert(#Pattern <= #String, "Pattern must be shorter than the string")
	return String:sub(#String - #Pattern + 1, #String) == Pattern
end

-- Returns a new string which is converted to title case. "hello world" -> "Hello World"
function StringUtilities.ToTitleCase(String: string): string
	assert(type(String) == "string", "Expected a string as the first argument.")

	local function Helper(First: string, Rest: string): string
		return `{First:upper()}{Rest:lower()}`
	end

	local NewString = {String:gsub("(%S)(%S*)", Helper:: (string) -> string)} 
	return NewString[1]
end

-- Replaces a pattern with a replacement string
function StringUtilities.Replace(String: string, Pattern: string, Replacement: string): string
	assert(type(String) == "string", "Expected a string as the first argument.")
	assert(type(Pattern) == "string", "Expected a string as the second argument.")
	assert(type(Replacement) == "string", "Expected a string as the third argument.")
	
	local SafePattern = Pattern:gsub("[%%%^%$%(%)%.%[%]%*%+%-%?]", "%%%1")
	
	-- Replace all occurrences of the target with the replacement
	local NewString = {String:gsub(SafePattern, Replacement)}
	return NewString[1]
end

-- Replaces the first occurrence of a pattern with a replacement string
function StringUtilities.ReplaceFirst(String: string, Pattern: string, Replacement: string): string
	assert(type(String) == "string", "Expected a string as the first argument.")
	assert(type(Pattern) == "string", "Expected a string as the second argument.")
	assert(type(Replacement) == "string", "Expected a string as the third argument.")
	
	local StartIndex, EndIndex = String:find(Pattern, 1, true)
	if not StartIndex or not EndIndex then return String end
	
	local NewString = String:sub(1, StartIndex - 1) .. Replacement .. String:sub(EndIndex + 1)
	return NewString
end

-- Converts a string to binary
function StringUtilities.ToBinary(Text: string): string
	assert(type(Text) == "string", "Expected a string as the first argument.")
	local BinaryString = ""

	for i = 1, #Text, 1 do
		local Char = Text:sub(i, i)
		local CharByte = string.byte(Char)

		-- Convert byte value to an 8-bit binary string using bitwise operations
		local BinaryValue = ""
		for j = 7, 0, -1 do
			if bit32.band(CharByte, bit32.lshift(1, j)) ~= 0 then
				BinaryValue = tostring(BinaryValue) .. "1"
			else
				BinaryValue = tostring(BinaryValue) .. "0"
			end
		end

		if BinaryString ~= "" then
			BinaryString = tostring(BinaryString) .. " "
		end

		BinaryString = BinaryString .. BinaryValue
	end

	return BinaryString
end

return StringUtilities