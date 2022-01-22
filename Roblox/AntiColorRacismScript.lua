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
