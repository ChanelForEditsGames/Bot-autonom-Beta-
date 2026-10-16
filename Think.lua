
local Think = {}

function Think.New()
    return {
        goal = nil,
        lastCheckTime = 0,
        lastCheckPosition = nil,
        stuckCount = 0
    }
end

function Think.Update(state, obs)
    local now = os.clock()
    local position = obs.position

    -- Comprobar el progreso una vez por segundo.
    if now - state.lastCheckTime >= 1 then
        if state.lastCheckPosition then
            local moved =
                (position - state.lastCheckPosition).Magnitude

            if moved < 1 then
                state.stuckCount += 1
            else
                state.stuckCount = 0
            end
        end

        state.lastCheckTime = now
        state.lastCheckPosition = position

        -- Si lleva unos segundos atascado,
        -- descartar el objetivo y elegir otro.
        if state.stuckCount >= 3 then
            state.goal = nil
            state.stuckCount = 0
        end
    end

    -- Elegir un destino cuando no hay uno válido.
    if not state.goal
        or (state.goal - position).Magnitude < 6 then

        local forward = obs.root.CFrame.LookVector
        forward = Vector3.new(forward.X, 0, forward.Z)

        if forward.Magnitude < 0.001 then
            forward = Vector3.new(0, 0, -1)
        end

        local angle = math.rad(math.random(-150, 150))
        local direction =
            CFrame.fromAxisAngle(
                Vector3.new(0, 1, 0),
                angle
            ):VectorToWorldSpace(forward.Unit)

        local distance = math.random(30, 55)

        state.goal = position + direction * distance
    end

    return state.goal
end

return Think
