local function chars(text, startIndex, endIndex)
    local i = startIndex and math.max(startIndex - 1, 0) or 0
    local len = endIndex and math.min(endIndex, #text) or #text

    return function()
        i = i + 1
        return i <= len and string.sub(text, i, i) or nil
    end
end

local str = "Hello World"

print("Example 1:")
for char in chars(str) do
    print(char)
end

print("Example 2:")
for char in chars(str, 3) do
    print(char)
end

print("Example 3:")
for char in chars(str, 2, 7) do
    print(char)
end

print("Example 4:")
local iterator = chars(str)
print("First char:", iterator())
print("Second char:", iterator())
for char in iterator do
    print("Other:", char)
end
