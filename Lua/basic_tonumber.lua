local ZERO_BYTE = string.byte('0')

local function to_number(text, radix)
        local n = 0
        local len = #text

        if radix < 0 or radix > 10 then
                error(string.format("The number system of radix %d is not supported", radix))
        end

        for i = 1, len do
                local charByte = string.byte(text, i, i)
                local digit = charByte - ZERO_BYTE
                if digit < 0 or digit >= radix then
                        error(string.format("The digit %d is not supported in radix %d", digit, radix))
                end

                local factor = radix^(len-i)
                n = n + factor*digit
        end

        return n
end

local str = "1010011"
local num = to_number(str, 10)
print(num)
