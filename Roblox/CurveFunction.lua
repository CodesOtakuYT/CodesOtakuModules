--[[
	MIT License

	Copyright (c) 2022 CodesOtaku

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

local ceil = math.ceil
local floor = math.floor

-- Create a table (data) of length 'samples', by sampling the function's output at equidistant inputs (linear sampling).
-- Needs a minimum of 2 samples.
local function Bake(func, samples : number)
	if samples < 2 then
		error("A minimum of 2 samples is required", 2)
	end
	
	local result = table.create(samples)
	
	samples = samples - 1
	
	for i = 0, samples do
		result[i+1] = func(i/samples)
	end
	
	return result
end

-- Calculate the total length between data points
-- More samples = More accurate length
-- However you usually get a good approximation for length even with small samples
-- So don't waste your computing power on calculating the length unless needed
local function Length(data : table)
	local length = 0
	local dataType = typeof(data[1])
	
	if dataType == "Vector3" or dataType == "Vector2" then
		for i = 2, #data do
			length += (data[i] - data[i-1]).magnitude
		end
	elseif dataType == "number" then
		local abs = math.abs
		for i = 2, #data do
			length += abs(data[i] - data[i-1])
		end
	else
		error(string.format("data values type '%s' isn't supported in function 'Length'", dataType), 2)
	end
	
	return length
end

--[[
	It takes a data table, and then it returns points that are distant apart by delta along the path
	delta should ideally be the minimum speed in the case of a moving object along the path
	taking the data samples = length/delta will yield the best results with the least computing power
	It also returns a carryOut, which is the amount of distance that couldn't be traveled to end the path
	You can pass it to the carryIn of the next BakeLinear curve if they're connected for example
]]
local function BakeLinear(data : table, delta : number, length : number?, carryIn : number?)
	if delta <= 0 then
		-- You're looking for infinity but computers doesn't know infinity yeet... :(
		error(string.format("Expected 'delta' to be a positive number, got '%f'", delta))
	end
	
	-- reserve the exact number or more hopefully.
	local pointsCountMax = length and ceil((length-(carryIn or 0))/delta)
	local result = length and table.create(pointsCountMax) or {}
	local dataType = typeof(data[1])
	
	local carryIn = nil
	
	-- Avoid unecessary conditions and function calls inside loops, and localize variables.
	if dataType == "Vector3" or dataType == "Vector2" then
		local pos = data[1]
		local targetIndex = 2
		local target = data[targetIndex]

		local overrideDelta = carryIn
		local pointIndex = 1
		
		while(target) do
			local delta = overrideDelta or delta
			overrideDelta = nil
			
			local dir = target-pos
			local distance = dir.Magnitude
			dir = dir.Unit
			
			local distanceLeft = distance - delta
			
			if distanceLeft > 0 then
				-- Step
				pos += dir*delta
				result[pointIndex] = pos
				pointIndex += 1
			else
				-- Correction
				pos = target
				targetIndex += 1
				target = data[targetIndex]
				
				overrideDelta = -distanceLeft
			end
		end
		
		carryIn = overrideDelta
	elseif dataType == "number" then
		local pos = data[1]
		local targetIndex = 2
		local target = data[targetIndex]

		local overrideDelta = carryIn
		local pointIndex = 1

		while(target) do
			local delta = overrideDelta or delta
			overrideDelta = nil

			local distance = target-pos
			local dir = (distance > 0 and 1) or (distance < 0 and -1) or 0
			distance = dir*distance

			local distanceLeft = distance - delta

			if distanceLeft > 0 then
				-- Step
				pos += dir*delta
				result[pointIndex] = pos
				pointIndex += 1
			else
				-- Correction
				pos = target
				targetIndex += 1
				target = data[targetIndex]

				overrideDelta = -distanceLeft
			end
		end

		carryIn = overrideDelta
	else
		error(string.format("data values type '%s' isn't supported in function 'BakeLinear'", dataType), 2)
	end
	
	return result, carryIn
end

-- it takes a discrete data table, and then it returns a continuous function along the points
-- it assumes equidistant points, otherwise it will be faster along bigger distances
-- and slower along smaller distances.
-- it also assumes that t is between 0 and 1.
-- to 

local function Lerper(data : table)
	local samples = #data
	local clamp = math.clamp
	
	if samples > 2 then
		-- Boii, we gotta do it the hard way ;)
		return function(t)
			local x = samples*t
			local startIndex = floor(x)
			local start = data[startIndex]
			
			return start + (x-startIndex)*(data[ceil(x)] - start)
		end
	elseif samples == 2 then
		-- Lerp it up :D
		local start = data[1]
		local range = data[samples] - start
		
		return function(t)
			return start + t*range
		end
	else
		-- Have you seen any curve with less than 2 points bro :)
		error(string.format("Expected '2' samples or more, got '%d'", samples), 2)
	end
end

-- Create a linear continuous path from the function func(t) where t goes from 0 to 1
-- it can be done manually more efficiently depending on your use case and constraints
-- but I added this for convinience and for people who doesn't know what they're doing
local function Path(func, minimumSpeed : number, accuracy : number)
	local data = Bake(func, accuracy)
	local length = Length(data)
	local linearData = BakeLinear(data, minimumSpeed)
	return Lerper(linearData)
end

return {
	Bake = Bake,
	Length = Length,
	BakeLinear = BakeLinear,
	Lerper = Lerper,
	Path = Path
}
