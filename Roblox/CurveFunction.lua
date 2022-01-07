--[[
	MIT License

	Copyright (c) 2022 Ilyas TAOUAOU (CodesOtaku)

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

--[[
	Bake(func, samples : number)
	
	Create a table (data) of length 'samples',
	by sampling the function's output at equidistant inputs (linear sampling).
	Needs a minimum of 2 samples.
]]
local function Bake(func, samples : number)
	if samples < 2 then
		error("A minimum of 2 samples is required", 2)
	end

	local result = table.create(samples)
	
	-- we're starting from 0 for the calculations
	samples = samples - 1

	for i = 0, samples do
		-- table index starts from 1
		result[i+1] = func(i/samples)
	end

	return result
end

--[[
	Length(data : table)

	Calculate the total length between data points
	More samples = More accurate length
	However you usually get a good approximation for length even with small samples
	So don't waste your computing power on calculating the length unless needed
	or performance isn't an issue for you
]]
local function Length(data : table)
	local length = 0
	local dataType = typeof(data[1])

	if dataType == "Vector3" or dataType == "Vector2" then
		local last = data[1]
		for i = 2, #data do
			local current = data[i]
			length += (current - last).magnitude
			last = current
		end
	elseif dataType == "number" then
		local abs = math.abs
		local last = data[1]
		for i = 2, #data do
			local current = data[i]
			length += abs(current - last)
			last = current
		end
	else
		error(string.format("data values type '%s' isn't supported in function 'Length'", dataType), 2)
	end

	return length
end

--[[
	BakeLinear(data : table, delta : number, length : number?, carryIn : number?)
	
	It takes a data table, and then it returns points that are distant apart by delta along the path
	delta should ideally be the minimum speed in the case of a moving object along the path
	taking the data samples = length/delta will yield the best results with the least computing power
	It also returns a carryOut, which is the amount of distance that couldn't be traveled to end the path
	You can pass it to the carryIn of the next BakeLinear curve if they're connected for example to have
	a fluid transition even if the delta is big.
]]
local function BakeLinear(data : table, delta : number, length : number?, carryIn : number?)
	if delta <= 0 then
		-- You're looking for infinity but computers doesn't know infinity yeet... :(
		error(string.format("Expected 'delta' to be a positive number, got '%f'", delta))
	end
	
	local ceil = math.ceil
	-- reserve the exact number or more hopefully.
	local pointsCountMax = length and ceil((length-(carryIn or 0))/delta)
	local result = length and table.create(pointsCountMax) or {}
	local dataType = typeof(data[1])
	
	-- the remaining untraveled distance due to reaching the end of the path
	local carryOut = nil

	-- Avoid unecessary conditions and function calls inside loops, and localize variables.
	if dataType == "Vector3" or dataType == "Vector2" then
		-- start at the first data value
		local pos = data[1]
		-- initialize the target as the second data value
		local targetIndex = 2
		local target = data[targetIndex]

		-- overrideDelta by carryIn at the start if given
		local overrideDelta = carryIn

		local pointIndex = 1
		
		-- Simulation
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
		
		-- confirm the carryOut
		carryOut = overrideDelta
	elseif dataType == "number" then
		-- start at the first data value
		local pos = data[1]
		-- initialize the target as the second data value
		local targetIndex = 2
		local target = data[targetIndex]

		-- overrideDelta by carryIn at the start if given
		local overrideDelta = carryIn

		local pointIndex = 1
		
		-- Simulation
		while(target) do
			-- use the corrected delta if any, otherwise use the fixed delta
			local delta = overrideDelta or delta
			overrideDelta = nil

			-- signed distance
			local distance = target-pos
			-- sign of distance
			local dir = (distance > 0 and 1) or (distance < 0 and -1) or 0
			-- absolute distance
			distance = dir*distance

			local distanceLeft = distance - delta

			if distanceLeft > 0 then
				---- Step
				pos += dir*delta
				-- register a new point
				result[pointIndex] = pos
				pointIndex += 1
			else
				---- Correction
				-- update position to the target and advance to the next target
				pos = target
				targetIndex += 1
				target = data[targetIndex]

				-- distanceLeft should be negative or zero at this point, get the absolute value by inversing it.
				overrideDelta = -distanceLeft
			end
		end

		-- Confirm the carryOut
		carryOut = overrideDelta
	else
		error(string.format("data values type '%s' isn't supported in function 'BakeLinear'", dataType), 2)
	end

	return result, carryOut
end

--[[
	Lerper(data : table)

	it takes a discrete data table, and then it returns a continuous function along the points
	it assumes equidistant points, otherwise it will be faster along bigger distances
	and slower along smaller distances.
	it also assumes that t is between 0 and 1.
--]]
local function Lerper(data : table)
	local samples = #data
	local clamp = math.clamp

	if samples > 2 then
		-- Boii, we gotta do it the hard way ;)
		local floor = math.floor
		local ceil = math.ceil
		local clamp = math.clamp
		
		return function(t)
			-- finding the interval where t lies in the data
			local x = samples*t
			local startIndex = clamp(floor(x), 1, samples)
			local start = data[startIndex]
			local finish = data[clamp(ceil(x), 1, samples)]
			
			local range = finish - start

			if range == 0 then
				-- the interval is empty
				return start
			else
				-- lerp between the interval (data[n], data[n or n+1])
				return start + (x-startIndex)*range
			end
		end
	elseif samples == 2 then
		-- lerp it up :D
		local start = data[1]
		local range = data[samples] - start

		return function(t)
			return start + t*range
		end
	else
		-- have you seen any curve with less than 2 points bro :)
		error(string.format("Expected '2' samples or more, got '%d'", samples), 2)
	end
end

--[[
	Path(func, minimumSpeed : number, accuracy : number, lengthAccuracy)
	
	Create a linear continuous path from the function func(t) where t goes from 0 to 1
	it can be done manually more efficiently depending on your use case and constraints
	but I added this for convinience and for people who doesn't know what they're doing
]]
local function Path(func, minimumSpeed : number, accuracy : number, lengthAccuracy)
	local data = Bake(func, lengthAccuracy or accuracy)
	local length = Length(data)
	data = lengthAccuracy and Bake(func, accuracy) or data
	local linearData = BakeLinear(data, minimumSpeed)
	return Lerper(linearData)
end

--[[
	Using local functions until the end allows function calls
	between the module members without any overhead, and also
	allows us to control which functions are for public use.
--]]
return {
	Bake = Bake,
	Length = Length,
	BakeLinear = BakeLinear,
	Lerper = Lerper,
	Path = Path
}
