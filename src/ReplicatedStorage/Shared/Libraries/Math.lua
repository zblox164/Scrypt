--!strict
local Math = {}

-- Normalizes a number between 0-1 depending on how close the number is to the min and max
function Math.Normalize(Value: number, Min: number, Max: number): number
	-- Handle edge cases where min >= max
	assert(Min < Max, "Minimum value must be less than maximum value.")

	-- Calculate range
	local Range = Max - Min
	if Range == 0 then return 0 end

	-- Normalize value
	local NormalizedValue = (Value - Min) / Range
	return NormalizedValue
end

-- Returns the factorial of a number
function Math.Factorial(N: number): number
	-- Check for negative input
	assert(N > 0, "Factorial is not defined for negative numbers")
	
	-- Base case (factorial of 0 is 1)
	if N == 0 then return 1 end
	return N * Math.Factorial(N - 1)
end

-- Calculates the nth Fibonacci number
function Math.Fibonacci(n: number): number
	if n <= 0 then return 0 end
	if n == 1 then return 1 end
	return Math.Fibonacci(n - 1) + Math.Fibonacci(n - 2)
end

-- Returns if a number is prime or not
function Math.IsPrime(n: number): boolean
	if n < 2 then return false end
	
	for i = 2, math.sqrt(n) do
		if n % i == 0 then
			return false
		end
	end
	
	return true
end

-- Maps a number from one range to another
function Math.Map(Value: number, FromMin: number, FromMax: number, ToMin: number, ToMax: number): number
	return ToMin + (ToMax - ToMin) * ((Value - FromMin) / (FromMax - FromMin))
end

function Math.ApproxEqual(a: number, b: number, Tolerance: number): boolean
	return math.abs(a - b) <= Tolerance
end

-- Interpolates between two numbers
function Math.Lerp(a: number, b: number, t: number): number
	return (1 - t)*a + t*b
end

-- Solves for time
function Math.InverseLerp(a: number, b: number, Value: number): number
	return (Value - a) / (b - a)
end

-- Snaps a number to the closest increment
function Math.Snap(n: number, Increment: number): number
	return math.round(n / Increment) * Increment
end

return Math