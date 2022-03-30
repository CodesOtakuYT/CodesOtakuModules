local COMMA_BYTE = string.byte('.')
local ZERO_BYTE = string.byte('0')
local MINUS_BYTE = string.byte('-')

local function tokenize(text, radix)
    local comma = nil
    local is_negative = false

    local tokens = {}
    
    local k = 0

    for i = 1, #text, 1 do
        local char = string.byte(text, i, i)
        
        if char == COMMA_BYTE then
            comma = k    
        else
            local digit = char - ZERO_BYTE

            if digit >= 0 and digit < radix then
                table.insert(tokens, digit)
                k = k + 1
            elseif char == MINUS_BYTE then
                is_negative = true
            else
                -- Ignore invalid chars
            end
        end
    end

    return tokens, comma, is_negative
end

local function to_number(text, radix)
    local tokens, comma, is_negative = tokenize(text, radix)
    local n = 0
    local len = #tokens

    for i, digit in ipairs(tokens) do
        local factor = radix^(comma - i)
        n = n + digit*factor
    end
    return is_negative and -n or n
end

print(to_number("        -123.this characters are ignored lol45657123", 10))
