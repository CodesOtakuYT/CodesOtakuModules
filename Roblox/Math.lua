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
--]]

-- Math library dependencies
local sqrt = math.sqrt
local cos, sin, tan, atan2 = math.cos, math.sin, math.tan, math.atan2
local exp, log, log10 = math.exp, math.log, math.log10
local floor, ceil, clamp = math.floor, math.ceil, math.clamp
local abs = math.abs
local pow = math.pow
local PI = math.pi
local sign = math.sign
local min, max = math.min, math.max

-- Constructors
local vector2, vector3 = Vector2.new, Vector3.new

-- Constants
local E = exp(1)
local TAU = PI*2
local PHI = (1+sqrt(5))/2
local EPSILON = 0.001

-- Pure Mathematical Functions
local function ncos(x)
	return -cos(x)
end

local function nsin(x)
	return -sin(x)
end

local function nrt(x, n)
	return x^(1/n)
end

local function cbrt(x)
	return x^(1/3)
end

local function ln(x)
	return math.log(x, E)
end

local function log2(x)
	return math.log(x, 2)
end

local function sec(x)
	return 1/cos(x)
end

local function csc(x)
	return 1/sin(x)
end

local function cot(x)
	return 1/tan(x)
end

local function inverse(x)
	return 1/x
end

local factCache = {
	[0] = 1,
	[1] = 1,
	[2] = 2,
	[10] = 3628800,
	[50] = 3.0414093202*pow(10, 64),
	[100] = 9.3326215444*pow(10, 157),
	[150] = 5.7133839564*pow(10,262),
}

local function factorial(x)
	local sign = sign(x)
	x = abs(x)
	local c = factCache[x]
	if c then return c*sign end

	c = x*factorial(x-1)
	factCache[x] = c
	return c*sign
end

local fibCache = {
	[0] = 0,
	[1] = 1,
	[2] = 1,
	[3] = 2,
	[10] = 55,
	[50] = 12586269025,
	[100] = 354224848179261915075,
	[200] = 280571172992510140037611932413038677189525,
	[500] = 139423224561697880139724382870407283950070256587697307264108962948325571622863290691557658876222521294125,
	[1000] = 43466557686937456435688527675040625802564660517371780402481729089536555417949051890403879840079255169295922593080322634775209689623239873322471161642996440906533187938298969649928516003704476137795166849228875,
	[1477] = math.huge, -- Overflow
}

local function fibonacci(x)
	local sign = sign(x)
	x = abs(x)

	local c = fibCache[x]
	if c then return c*sign end
	c = fibonacci(x-1)+fibonacci(x-2)
	fibCache[x] = c
	return c*sign
end

local function numberLength(x, base)
	base = base or 10
	return ceil(log(x, base))+1
end

local function fract(x)
	return x-floor(x)
end

local function toFract(x, base)
	base = base or 10
	return x*pow(base, -ceil(log(x, base)))
end

local function wrap(x, min, max)
	return (x-min)%(max-min+1) + min
end

local function step(x, factor, offset)
	offset = offset or 0
	if factor == 0 then return x end
	return floor((x-offset)/factor + 0.5)*factor + offset
end

local function snap(x, factor, offset, sep)
	if factor == 0 then return x end

	local a = step(x, factor + sep, offset)
	local b = a

	if x >= 0 then
		b -= sep
	else
		b += step
	end

	return abs(x-a < x-b and a or b)
end

local function stepDecimals(x, decimalPlaces)
	return step(x, 10^(-decimalPlaces))
end

local function cartesian2polar(x, y)
	return vector2(sqrt(x^2+y^2), atan2(y,x))
end

local function polar2cartesian(rau, angle)
	return vector2(rau*cos(angle), rau*sin(angle))
end

local function cylindrical2cartesian(rau, angle, z)
	return vector3(rau*cos(angle), rau*sin(angle), z)
end

local function spherical2cartesian(r, angle, theta, z)
	return vector3(r*cos(angle)*sin(theta), r*sin(angle)*sin(theta), r*cos(theta))
end

local function ease(x, curve)
	x = clamp(x, 0, 1)

	if curve > 0 then
		if curve < 1 then
			return 1 - pow(1-x, 1/curve)
		else
			return pow(x, curve)
		end
	elseif curve < 0 then
		if x < 0.5 then
			return pow(x*2, -curve) * 0.5
		else
			return (1 - pow(1 - (x-0.5)*2, -curve))*0.5 + 0.5
		end
	else
		return 0
	end
end

local function smoothStep(from, to, x)
	local s = clamp((x-from)/(to-from), 0, 1)
	return s*s*(3-2*s)
end

local function lerp(a, b, t)
	return a + (b-a)*t
end

local function inverseLerp(c, d, x)
	return (x-c)/(d-c)
end

local function map(i1, i2, o1, o2, x)
	-- return lerp(o1, o2, inverseLerp(i1, i2, x))
	return o1 + (o2-o1)*((x-i1)/(i2-i1))
end

-- Comparaison functions
local function approxEq(x, y, epsilon)
	epsilon = epsilon or EPSILON
	return abs(x-y) < epsilon
end

local function approxZero(x, epsilon)
	epsilon = epsilon or EPSILON
	return abs(x) < epsilon
end

-- Table helper functions
local function copyT(t, c, isDeepCopy)
	c = c or {}

	for k,v in pairs(t) do
		if isDeepCopy and typeof(v) == "table" then
			c[k] = copyT(v, nil, true)
		else
			c[k] = v
		end
	end

	return c
end

local function invertT(t, r)
	r = r or {}

	for k,v in pairs(t) do
		r[v] = k
	end

	return r
end

-- Calculus
local definiteDerivative = {
	[cos] = nsin,
	[nsin] = ncos,
	[ncos] = sin,
	[sin] = cos,
	[ln] = inverse,
	[exp] = exp
}

local definitePrimitive = invertT(definiteDerivative)

local function derivative(x, dx, f)
	local dF = definiteDerivative[f]

	if dF then
		return dF(x)
	end

	dx = dx or EPSILON

	return (f(x+dx)-f(x))/dx
end

local function productDerivative(x, dx, f, g)
	return g(x)*derivative(x, dx, f) + f(x)*derivative(x, dx, g)
end

local function quotientDerivative(x, dx, f, g)
	local gx = g(x)
	return (gx*derivative(x, dx, f) + f(x)*derivative(x, dx, g))/(gx^2)
end

local function compositeDerivative(x, dx, f, g)
	return derivative(g(x), dx, f)*derivative(x, dx, g)
end

local function integral(x1, x2, dx, f)
	local primitive = definitePrimitive[f]

	if primitive then
		return primitive(x2) - primitive(x1)
	end

	dx = dx or abs(x2-x1)*EPSILON
	local surface = 0

	for x = min(x1, x2), max(x1, x2), abs(dx) do
		surface += f(x)*dx
	end

	return surface*sign(x2-x1)*sign(dx)
end

local function integralAbs(x1, x2, dx, f)
	local primitive = definitePrimitive[f]

	if primitive then
		return primitive(x2) - primitive(x1)
	end

	dx = dx or abs(x2-x1)*EPSILON
	local surface = 0

	for x = x1, x2, dx do
		surface += abs(f(x)*dx)
	end

	return surface
end

local function addDefiniteFunction(f, dF)
	definiteDerivative[f] = dF
	definitePrimitive[dF] = f
end

local function getDefinitivePrimitive(f)
	return definitePrimitive[f]
end

local function getDefinitiveDerivative(f)
	return definiteDerivative[f]
end

-- Table math
local function sumT(t)
	local n = 0

	for _,v in pairs(t) do
		n += v
	end

	return n
end

local function differenceT(t)
	local n = 0

	for _,v in pairs(t) do
		n -= v
	end

	return n
end

local function productT(t)
	local n = 1

	for _,v in pairs(t) do
		if v == 0 then return 0 end
		n *= v
	end

	return n
end

local function quotientT(t)
	local n = 1

	for _,v in pairs(t) do
		n /= v
	end

	return n
end

local function meanT(t)
	return sumT(t)/#t
end

local function medianT(t)
	t = copyT(t)

	table.sort(t, function(a, b)
		return a < b
	end)

	local l = #t

	if l%2 == 0 then
		local mid = l/2
		return (t[mid]+t[mid+1])/2
	else
		return t[(l+1)/2]
	end
end

local function maxT(t, isOverride)
	local index = nil
	local value = -math.huge

	for k,v in pairs(t) do
		if isOverride and v >= value or v > value then
			index = k
			value = v
		end
	end

	return value, index
end

local function minT(t, isOverride)
	local index = nil
	local value = math.huge

	for k,v in pairs(t) do
		if isOverride and v <= value or v < value then
			index = k
			value = v
		end
	end

	return value, index
end

local function rangeT(t, isOverride)
	local indexMin, indexMax
	local min, max = math.huge, math.huge

	for k,v in pairs(t) do
		if isOverride and v <= min or v < min then
			indexMin = k
			min = v
		end

		if isOverride and v >= max or v > max then
			indexMax = k
			max = v
		end
	end

	return {min, indexMin}, {max, indexMax}
end

local function countValuesT(t)
	local elements = {}

	for k,v in pairs(t) do
		local element = elements[v]
		if element then
			elements[v] = element + 1
		else
			elements[v] = 1
		end
	end

	return elements
end

local function modeT(t, isOverride)
	return maxT(countValuesT(t), isOverride)
end

local function processPairsT(t, func)
	local r = {}

	for n = 1, #t, 2 do
		table.insert(r, func(t[n], t[n+1]))
	end

	return r
end

local function mapT(t, func, isOverride, isStrict)
	local r = isOverride and t or {}
	
	for k, v in pairs(func) do
		local rv, rk = func(v, k)
		if isStrict then
			r[rk] = rv
		else
			r[rk or k] = rv
		end
	end
	
	return r
end

local function filterT(t, func, isOrdered : bool?)
	local r = {}
	
	if isOrdered then
		for i, v in ipairs(func) do
			if func(v, i) then
				table.insert(v)
			end
		end
	else
		for k, v in pairs(func) do
			if func(v, k) then
				t[k] = v
			end
		end
	end

	return r
end

local function countT(t, func)
	local n = 0
	
	for k,v in pairs(t) do
		n += func(v) or 0
	end
	
	return n
end

local function countMulT(t, func)
	local n = 1

	for k,v in pairs(t) do
		n *= func(v) or 0
	end

	return n
end

local function zipT(t1, t2)
	local r = {}
	
	for i = 1, min(#t1, #t2) do
		r[i] = {t1[i], t2[i]}
	end
	
	return r
end

local function unzipT(t)
	local r1, r2 = {},{}
	
	for _, tuple in ipairs(t) do
		table.insert(r1, tuple[1])
		table.insert(r2, tuple[2])
	end
	
	return r1, r2
end

local function toRawT(t, isRecursive, tOut)
	local r = tOut or {}
	
	for _, tuple in ipairs(t) do
		for _, element in ipairs(tuple) do
			if isRecursive and typeof(element) == "table" then
				toRawT(t, true, r)
			else
				table.insert(r, element)
			end
		end
	end
	
	return r
end

local function keysT(t, isRecursive, tOut)
	local r = tOut or {}
	
	for k,v in pairs(t) do
		if isRecursive and typeof(v) == "table" then
			keysT(v, true, r)
		else
			table.insert(r, k)
		end
	end
	
	return r
end

local function valuesT(t, isRecursive, tOut)
	local r = tOut or {}

	for _,v in pairs(t) do
		if isRecursive and typeof(v) == "table" then
			keysT(v, true, r)
		else
			table.insert(r, v)
		end
	end

	return r
end

local function sampleT(func, samples, x1, x2)
	if samples < 2 then
		error("A minimum of 2 samples is required", 2)
	end

	local result = table.create(samples)

	-- we're starting from 0 for the calculations
	samples = samples - 1

	for i = 0, samples do
		-- table index starts from 1
		local t = i/samples
		result[i+1] = func(lerp(x1, x2, t))
	end

	return result
end

-- Vector math
local function distanceV(vec1, vec2)
	return (vec1 - vec2).magnitude
end

local function midPosV(vec1, vec2)
	return (vec1 + vec2)/2
end

local function applyV(vec, func)
	return Vector3.new(func(vec.X, 1), func(vec.Y, 2), func(vec.Z, 3))
end

local function absV(vec)
	return applyV(vec, abs)
end

return {
	----> Constants
	PI = PI, -- Ratio of a circle's circumference to its diameter.
	TAU = TAU, -- PI*2
	E = E, -- Euler's number
	PHI = PHI, -- Golden Ratio

	----> Pure mathematical functions
	nrt = nrt, -- Nth root; (x, n)
	cbrt = cbrt, -- Cubic root; (x)
	inverse = inverse, -- 1/x; (x)
	ln = ln, -- Natural logarithm; (x)
	log2 = log2, -- Log of base 2
	cos = cos, -- cos(x)
	sin = sin, -- sin(x)
	ncos = ncos, -- -cos(x), it might seem silly, but I added this so I can optimize derivative and integral by referencing it, so you can pass in this function to integral, and it's already optimized
	nsin = nsin, -- -sin(x)
	sec = sec, -- Secant(x), I don't use this functions usually, but it might be helpful if you have a formula that use them and you're too lazy like me
	csc = csc, -- Co-secant(x),
	cot = cot, -- Co-tangent(x),
	ease = ease, -- https://godotengine.org/qa/59172/how-do-i-properly-use-the-ease-function
	smoothStep = smoothStep, -- https://thebookofshaders.com/glossary/?search=smoothstep
	factorial = factorial, -- x!
	fibonacci = fibonacci, -- fib(x-1)+fib(x-2)

	----> Practical mathematical functions
	numberLength = numberLength, -- returns the number of digits in the number #tostring(number)
	fract = fract, -- return the fractional part of a number, what's after the comma
	toFract = toFract, -- return the number after the comma like 0.number
	wrap = wrap, -- it cycles a arbitrary value between min and max, equivalent to the modulo operator but with configurable minimum
	step = step, -- returns the closest multiple of factor to x, can be used to snap a position's components to a grid (Minecraft...)
	snap = snap, -- the same as step, but can also handle seperation, Ex: your grid have a border
	stepDecimals = stepDecimals, -- round the number to n digits after the comma
	lerp = lerp, -- takes a range [a -> b] and a t value [0->1]. it returns a value travalling from a to b linearly, where t is the percentage it advanced (Ex: 50% = 0.5)
	inverseLerp = inverseLerp, -- takes a range [c -> d] and a value x, it returns the t value of the value in range, basically where the value is relative to the range.
	map = map, -- lerp(o1, o2, inverseLerp(i1, i2, x)), remaps a value x from the range [i1->i2] to [o1->o2], can be useful to create sliders.
	
	----> Conversion
	cartesian2polar = cartesian2polar, -- x, y to rau, angle
	cylindrical2cartesian = cylindrical2cartesian, -- rau, angle, z to x,y,z
	spherical2cartesian = spherical2cartesian, -- rau, angle, theta to x,y,z
	polar2cartesian = polar2cartesian, -- rau, angle to x,y

	----> Comparaison functions
	approxEq = approxEq, -- Returns true if x approximately equals y, where EPSILON is the tolerance, error or deviation allowed; (x, y, epsilon?)
	approxZero = approxZero, -- Returns true if x approximately equals 0

	----> Calculus
	derivative = derivative, -- calculate the derivative of f using it's definite derivative (optimized) or numerically if none found
	integral = integral, -- calculate the integral of f from x1 to x2 using it's definite primitive (optimized) or numerically if none found
	integralAbs = integralAbs, -- the absolute version of the integral, the sign of f(x) is ignored
	addDefiniteFunction = addDefiniteFunction, -- takes 2 functions. a function and it's derivative, it will be used by the functions above if the definite version exist, as it's much better and accurate than the numerical method
	productDerivative = productDerivative, -- (f*g)' = f'g-g'f the chain rule
	quotientDerivative = quotientDerivative, -- (f/g)' = (f'g-g'f)/(g^2) the chain rule and the derivative of the inverse of f(x)
	compositeDerivative = compositeDerivative, -- (f(g))' = f'(g)*g'
	
	----> Table math
	sumT = sumT, -- Sum of the values; (table)
	differenceT = differenceT, -- Difference of the values; (table)
	productT = productT, -- Product of the values; (table)
	quotientT = quotientT, -- Quotient of the values; (table)
	meanT = meanT, -- Average of the values; (table)
	modeT = modeT, -- The middle value or the average of the middle values in the sorted version of the table; (table)
	maxT = maxT, -- The maximum value in the table, if isOverride is true, return the last maximum found, otherwise the first; (table, isOverride?)
	minT = minT, -- The minumum value in the table;, if isOverride is true, return the last minimum found, otherwise the first; (table, isOverride?)
	countValuesT = countValuesT, -- Returns a table with the count of all the values in the table; (table)
	rangeT = rangeT, -- Returns {min, minIndex}, {max, maxIndex}; (table)
	processPairsT = processPairsT, -- Gets a table with 2*n elements, it returns a table with n elements by processing each pair with the function f
	mapT = mapT, -- Gets a table [x1, x2, x3...xn] and a function, returns [f(x1), f(x2), f(x3)...f(xn)]
	filterT = filterT, -- Gets a table and a function, returns a new table with the elements that evaluated the function f(value, key) to true
	countT = countT, -- Accumulates the result of a function f(v, k) traversing a table, returns the accumulated value
	countMulT = countMulT, -- The same as countT but with multiplication
	sampleT = sampleT, -- Sample function output n times from x1 to x2 linearly
	
	----> Vector math
	distanceV = distanceV, -- Returns the distance between the position vec1 and vec2
	midPosV = midPosV, -- Returns the middle position between the position vec1 and vec2, equivalent to lerp(vec1, vec2, 0.5)
	applyV = applyV, -- Returns a new Vector3 by applying a function on the X, Y and Z components of a Vector3
	absV = absV, -- Returns a new Vector3 where all the components of the vector are absolute (positive or nil)
	
	----> Helper functions
	copyT = copyT, -- Returns a copy of a table
	invertT = invertT, -- the keys becomes the values and vice versa, takes a table [y1 = x1, y2 = x2...yn = xn], returns [x1 = y1, x2 = y2...xn = yn]
	zipT = zipT, -- takes 2 tables and zip them together {{t1[1], t2[1]}, {t1[2], t2[2]}...{t1[n], t2[n]}}
	unzipT = unzipT, -- the inverse of zip, takes 1 table of pairs and unzip it into 2 tables
	valuesT = valuesT, -- return a table of all the values inside the table, there is also recursive mode for nested tables
	keysT = keysT, -- the same as valuesT, but for table keys
}
