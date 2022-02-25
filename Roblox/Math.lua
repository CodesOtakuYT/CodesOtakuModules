-- Math library dependencies
local sqrt = math.sqrt
local cos, sin, tan, atan2 = math.cos, math.sin, math.tan, math.atan2
local exp, log, log10 = math.exp, math.log, math.log10
local floor, ceil, clamp = math.floor, math.ceil, math.clamp
local abs = math.abs
local pow = math.pow
local PI = math.pi
local sign = math.sign

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
	return x^(-1/n)
end

local function cbrt(x)
	return x^(-1/3)
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
	return x*pow(10, -ceil(log(x, base)))
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
local function copyT(t, c)
	local c = c or {}
	
	for k,v in pairs(t) do
		c[k] = v
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

local function integral(x1, x2, dx, f)
	local primitive = definitePrimitive[f]
	
	if primitive then
		return primitive(x2) - primitive(x1)
	end
	
	dx = dx or abs(x2-x1)*EPSILON
	local surface = 0
	
	for x = x1, x2, dx do
		surface += f(x)*dx
	end
	
	return surface
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

return {
	----> Constants
	PI = PI, -- Ratio of a circle's circumference to its diameter.
	TAU = TAU, -- PI*2
	E = E, -- Euler's number
	PHI = PHI, -- Golden Ratio
	
	----> Pure mathematical functions
	nrt = nrt, -- Nth root; (x, n)
	cbrt = cbrt, -- Cubic root; (x)
	inverse = inverse,
	ln = ln,
	log2 = log2, -- Natural logarithm; (x)
	cos = cos,
	sin = sin,
	ncos = ncos,
	nsin = nsin,
	sec = sec, -- Secant; (x)
	csc = csc, -- Co-secant; (x)
	cot = cot, -- Co-tangent; (x)	
	ease = ease,
	smoothStep = smoothStep,
	factorial = factorial,
	fibonacci = fibonacci,
	
	----> Practical mathematical functions
	numberLength = numberLength,
	fract = fract,
	toFract = toFract,
	wrap = wrap,
	step = step,
	snap = snap,
	stepDecimals = stepDecimals,
	
	----> Conversion
	cartesian2polar = cartesian2polar,
	polar2cartesian = polar2cartesian,
	
	----> Comparaison functions
	approxEq = approxEq, -- Returns true if x approximately equals y, where EPSILON is the tolerance, error or deviation allowed; (x, y, epsilon?)
	approxZero = approxZero, -- Returns true if x approximately equals 0
	
	----> Calculus
	derivative = derivative,
	integral = integral,
	integralAbs = integralAbs,
	addDefiniteFunction = addDefiniteFunction,
	productDerivative = productDerivative,
	quotientDerivative = quotientDerivative,
	
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

	----> Helper functions
	copyT = copyT,
}
