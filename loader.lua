
local BASE =
    "https://raw.githubusercontent.com/ChanelForEditsGames/Bot-Autonom-Beta-/main/"

local function LoadModule(fileName)
    local source = game:HttpGet(BASE .. fileName)
    local chunk, err = loadstring(source)

    if not chunk then
        error("Error compilando " .. fileName .. ": " .. tostring(err))
    end

    return chunk()
end

local Environment = LoadModule("Environment.lua")
local Think = LoadModule("Think.lua")
local Action = LoadModule("Action.lua")
local AgentCore = LoadModule("AgentCore.lua")

local agent = AgentCore.Start(Environment, Think, Action)

print("Agente autónomo iniciado.")
