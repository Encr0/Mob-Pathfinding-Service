local PathfindingService = game:GetService('PathfindingService')
local RunService = game:GetService('RunService')
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MobService = {}
local MobsTable = {}
MobService.__index = MobService

local function findPlayers(rootPart, dist)
    local players = {} -- Use a more efficient way to find players, like through tags or a dedicated tracking system
    -- Populate the players table with relevant player instances
    -- ...
    return players
end

local function createPath(agentRadius, agentHeight, agentCanJump, start, target)
    local path = PathfindingService:CreatePath({
        AgentRadius = agentRadius,
        AgentHeight = agentHeight,
        AgentCanJump = agentCanJump,
        AgentJumpHeight = 10, -- Set an appropriate jump height
        AgentJumpGap = 3, -- Set an appropriate jump gap
        AgentMaxSlope = 45, -- Set an appropriate max slope angle
        })
    path:ComputeAsync(start, target)
    return path
end

function MobService.new(name, level, health, radius, height, canJump, cframe)
    local mobModel = ReplicatedStorage[name]:Clone()
    mobModel.Parent = workspace.Enemies

    local newMob = {
        _BaseHealth = health or 100,
        _EnemyType = name or "Dummy",
        _Model = mobModel,
        _Distance = 70,
        _WalkSpeed = 8,
        _Radius = radius,
        _Height = height,
        _spawnCFrame = cframe,
        _CanJump = canJump,
        _Level = level
    }

    setmetatable(newMob, MobService)
    table.insert(MobsTable, newMob)
    return newMob
end

function MobService:SetProperties()
    self._Model.Humanoid.Health = self._BaseHealth
    self._Model.Humanoid.WalkSpeed = self._WalkSpeed
    self._Model.Head.MobName.TextLabel.Text = "Lvl " .. self._Level .. ". " .. self._EnemyType
    self._Model:SetPrimaryPartCFrame(self._spawnCFrame)
end

function MobService:SetAnimations()
    local idleAnim = self._Model.Humanoid.Animator:LoadAnimation(script.IdleAnim)
    local runAnim = self._Model.Humanoid.Animator:LoadAnimation(script.RunAnim)

    idleAnim:Play()

    self._Model.Humanoid.Running:Connect(function(speed)
        if speed > 1 then
            if not self._Walking then
                self._Walking = true
                runAnim:Play()
            end
        elseif speed == 0 then
            if self._Walking then
                self._Walking = false
                local activeTracks = self._Model.Humanoid.Animator:GetPlayingAnimationTracks()
                for _, track in pairs(activeTracks) do
                    if track.Name == "RunAnim" then
                        track:Stop()
                        idleAnim:Play()
                    end
                end
            end
        end
    end)
end

function MobService.PathfindServiceLoop()
    RunService.Heartbeat:Connect(function()
        for _, mob in pairs(MobsTable) do
            local players = findPlayers(mob._Model.HumanoidRootPart, mob._Distance)
            if #players > 0 then
                local target = players[1].Head.Position -- Assuming players is a table of player instances with Head property
                local path = createPath(mob._Radius, mob._Height, mob._CanJump, mob._Model.HumanoidRootPart.Position, target)
                if path.Status == Enum.PathStatus.Complete then
                    local nodes = path:GetWaypoints()
                    for _, nodeParts in pairs(nodes) do
                        if nodeParts.Action == Enum.PathWaypointAction.Jump then
                            mob._Model.Humanoid.Jump = true
                        end
                        mob._Model.Humanoid:MoveTo(nodeParts.Position)
                    end
                end
            end
        end
    end)
end

return MobService
