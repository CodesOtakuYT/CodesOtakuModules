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
-- Made totally by CodesOtaku with love, the code is self explanatory.

--------[ SERVICES ]--------
local PlayersService = game:GetService("Players")

--------[ CONSTANTS ]--------

--------[ VARIABLES ]--------
local RandomGenerator = Random.new()

--------[ FUNCTIONS ]--------
local function CanBeColored(object)
	return object:IsA("BasePart")
end

local function SetColorIfNeeded(object, color)
	if CanBeColored(object) then
		object.Color = color
	end
end

local function ColorModelChildren(model, color)
	for _, child in ipairs(model:GetChildren()) do
		SetColorIfNeeded(child, color)
	end
end

local function GetRandomNumberFrom0To1()
	return RandomGenerator:NextNumber()
end

local function GetRandomColor3()
	return Color3.new(
		GetRandomNumberFrom0To1(),
		GetRandomNumberFrom0To1(),
		GetRandomNumberFrom0To1()
	)
end

local function ColorModelChildrenRandomly(model)
	local randomColor = GetRandomColor3()
	ColorModelChildren(model, randomColor)
end

--------[ CALLBACKS ]--------
local function CharacterAdded(character)
	wait() -- Wait a bit for all the character's children to load hopefully
	ColorModelChildrenRandomly(character)
end

local function PlayerAdded(player)
	player.CharacterAdded:Connect(CharacterAdded)
end

--------[ START FUNCTION ]--------
local function Start()
	PlayersService.PlayerAdded:Connect(PlayerAdded)
end

--------[ START ]--------
Start()
