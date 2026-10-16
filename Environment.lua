
local Workspace = game:GetService("Workspace")

local Environment = {}

function Environment.Observe(character)
    if not character then
        return nil
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")
        or character.PrimaryPart

    if not humanoid or not root or not root:IsA("BasePart") then
        return nil
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    params.IgnoreWater = false

    return {
        character = character,
        humanoid = humanoid,
        root = root,
        position = root.Position,
        raycastParams = params
    }
end

function Environment.Raycast(obs, origin, direction, distance)
    if direction.Magnitude < 0.001 then
        return nil
    end

    return Workspace:Raycast(
        origin,
        direction.Unit * distance,
        obs.raycastParams
    )
end

function Environment.HasGroundAhead(obs, direction, distance)
    local origin =
        obs.root.Position
        + direction.Unit * distance
        + Vector3.new(0, 3, 0)

    local result = Environment.Raycast(
        obs,
        origin,
        Vector3.new(0, -1, 0),
        14
    )

    return result ~= nil
end

return Environment
