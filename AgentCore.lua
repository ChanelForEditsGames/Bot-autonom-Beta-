
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AgentCore = {}

function AgentCore.Start(Environment, Think, Action)
    assert(type(Environment.Observe) == "function", "Falta Observe")
    assert(type(Think.New) == "function", "Falta Think.New")
    assert(type(Think.Update) == "function", "Falta Think.Update")
    assert(type(Action.ChooseDirection) == "function", "Falta ChooseDirection")
    assert(type(Action.Step) == "function", "Falta Step")

    local player = Players.LocalPlayer
    assert(player, "No se encontró el jugador")

    if _G.__AutonomousAgentStop then
        pcall(_G.__AutonomousAgentStop)
    end

    local active, character = true, player.Character
    local state, obs, direction = Think.New(), nil, Vector3.zero
    local timer, stuck = 0, 0
    local lastPosition, connection, charConnection

    local function stop()
        if not active then return end
        active = false
        if connection then connection:Disconnect() end
        if charConnection then charConnection:Disconnect() end

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(Vector3.zero, false) end

        if _G.__AutonomousAgentStop == stop then
            _G.__AutonomousAgentStop = nil
        end
        print("[Nexar] Detenido")
    end

    _G.__AutonomousAgentStop = stop

    local function reset(char)
        character, state = char, Think.New()
        obs, direction, lastPosition = nil, Vector3.zero, nil
        timer, stuck = 1, 0
    end

    charConnection = player.CharacterAdded:Connect(reset)
    reset(character)

    connection = RunService.Heartbeat:Connect(function(dt)
        if not active then return end
        if not character or character ~= player.Character then
            reset(player.Character)
            return
        end

        timer += dt
        if timer >= 0.12 then
            timer = 0

            local ok, newObs, newDirection = pcall(function()
                local o = Environment.Observe(character)
                if not o then return nil, Vector3.zero end

                local goal = Think.Update(state, o)
                if not goal then return o, Vector3.zero end

                return o, Action.ChooseDirection(o, goal, Environment)
            end)

            if ok then
                obs, direction = newObs, newDirection or Vector3.zero
            else
                obs, direction = nil, Vector3.zero
                warn("[Nexar] Error:", newObs)
            end
        end

        if obs then
            local ok, err = pcall(Action.Step, obs, direction)
            if not ok then warn("[Nexar] Movimiento:", err) end

            local pos = obs.root.Position
            if lastPosition and (pos - lastPosition).Magnitude < 0.15 then
                stuck += dt
            else
                stuck = 0
            end

            if stuck >= 3 then
                state, stuck, timer = Think.New(), 0, 1
            end

            lastPosition = pos
        end
    end)

    print("[Nexar] Agente iniciado")
    return {Stop = stop}
end

return AgentCore
