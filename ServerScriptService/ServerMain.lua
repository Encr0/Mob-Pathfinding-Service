local SS_Service = game:GetService("ServerScriptService")
local MobService = require(SS_Service.ServerMain.MobService)

-- Constants
local MAX_MOBS = 15
local NUM_SPAWNERS = 4
local MOB_NAME = "Amber Golem"
local MOB_LEVEL = 2
local MOB_HP = 50
local MOB_RADIUS = 6
local MOB_HEIGHT = 12
local CAN_JUMP = true

-- Function to spawn mobs
local function spawnMobs()
    for i = 1, MAX_MOBS do
        -- Randomly select a spawner
        local randomSpawner = math.random(1, NUM_SPAWNERS)
        local spawnCFrame = workspace.Spawners:FindFirstChild("Spawner" .. tostring(randomSpawner)).CFrame
        
        -- Create and configure mob object
        local mob = MobService.new(MOB_NAME, MOB_LEVEL, MOB_HP, MOB_RADIUS, MOB_HEIGHT, CAN_JUMP, spawnCFrame)
        
        -- Check if mob object is valid and set its properties and animations
        if mob then
            mob:SetProperties()
            mob:SetAnimations()
        else
            warn("Failed to create mob object.")
        end
    end
end

-- Spawn mobs and initialize pathfinding loop
spawnMobs()
MobService.PathfindServiceLoop()
