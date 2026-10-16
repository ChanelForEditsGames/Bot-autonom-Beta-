
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AgentCore = {}

function AgentCore.Start(Environment, Think, Action)
    if _G.__AutonomousAgentStop then
        pcall(_G.__AutonomousAgentStop)
    end

    local player = Players.LocalPlayer
    local active = true
    local connection

    local state = Think.New()
    local currentCharacter = nil
    local currentObs = nil
    local currentDirection = Vector3.zero
    local accumulator = 0.12

    local function stop()
        active = false

        if connection then
            connection:Disconnect()
            connection = nil
        end

        local character = player.Character
        if character then
            local humanoid =
                character:FindFirstChildOfClass("Humanoid")

            if humanoid then
                humanoid:Move(Vector3.zero, false)
            end
        end
    end

    _G.__AutonomousAgentStop = stop

    connection = RunService.Heartbeat:Connect(function(dt)
        if not active then
            return
        end

        local character = player.Character

        if character ~= currentCharacter then
            currentCharacter = character
            currentObs = nil
            currentDirection = Vector3.zero
            state = Think.New()
            accumulator = 0.12
        end

        accumulator += dt

        -- Percepción y planificación a intervalos cortos.
        if accumulator >= 0.12 then
            accumulator = 0

            currentObs = Environment.Observe(character)

            if currentObs then
                local goal = Think.Update(state, currentObs)

                currentDirection = Action.ChooseDirection(
                    currentObs,
                    goal,
                    Environment
                )
            else
                currentDirection = Vector3.zero
            end
        end

        -- Mantener la orden de movimiento entre evaluaciones.
        if currentObs then
            Action.Step(currentObs, currentDirection)
        end
    end)

    return {
        Stop = stop
    }
end

return AgentCore
