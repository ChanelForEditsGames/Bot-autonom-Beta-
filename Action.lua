
local Action = {}

local ANGLES = {
    0, 30, -30, 60, -60,
    90, -90, 135, -135, 180
}

function Action.ChooseDirection(obs, goal, Environment)
    local offset = goal - obs.position
    local desired = Vector3.new(offset.X, 0, offset.Z)

    if desired.Magnitude < 0.001 then
        return Vector3.zero
    end

    desired = desired.Unit

    local origin =
        obs.root.Position + Vector3.new(0, 1.5, 0)

    local bestDirection = nil
    local bestScore = -math.huge

    for _, angle in ipairs(ANGLES) do
        local direction =
            CFrame.fromAxisAngle(
                Vector3.new(0, 1, 0),
                math.rad(angle)
            ):VectorToWorldSpace(desired).Unit

        -- Evitar elegir una dirección sin suelo detectable.
        if Environment.HasGroundAhead(obs, direction, 4) then
            local hit = Environment.Raycast(
                obs,
                origin,
                direction,
                8
            )

            local clearance = 8

            if hit then
                clearance = (hit.Position - origin).Magnitude
            end

            local alignment = desired:Dot(direction)

            -- Preferir avanzar hacia el objetivo,
            -- pero dejar espacio para esquivar.
            local score =
                alignment * 10 + clearance * 0.65

            if score > bestScore then
                bestScore = score
                bestDirection = direction
            end
        end
    end

    -- Si no encuentra una dirección segura,
    -- esperar al siguiente ciclo de evaluación.
    return bestDirection or Vector3.zero
end

function Action.Step(obs, direction)
    if obs.humanoid.Health <= 0 then
        return
    end

    obs.humanoid:Move(direction, false)
end

return Action
