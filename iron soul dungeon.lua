--[[
    Automation Controller
    For your own Roblox game

    Features:
    • Auto Attack
    • Auto Skill
    • Auto Equip Best
    • Auto Movement
    • Auto Target
    • Auto Loot
    • Auto Dodge
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local Settings = {
    AutoAttack = false,
    AutoSkill = false,
    AutoEquipBest = false,
    AutoMovement = false,
    AutoTarget = false,
    AutoLoot = false,
    AutoDodge = false,

    AttackInterval = 0.35,
    SkillInterval = 2,
    MovementDistance = 8,
    TargetDistance = 60
}

--------------------------------------------------
-- CHARACTER
--------------------------------------------------

local Character
local Humanoid
local RootPart

local function setupCharacter(char)

    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")

end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

--------------------------------------------------
-- TARGET SYSTEM
--------------------------------------------------

local CurrentTarget = nil

local function getNearestEnemy()

    if not RootPart then
        return nil
    end

    local nearest = nil
    local nearestDistance = Settings.TargetDistance

    local enemiesFolder = workspace:FindFirstChild("Enemies")

    if not enemiesFolder then
        return nil
    end

    for _, enemy in ipairs(enemiesFolder:GetChildren()) do

        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")

        if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then

            local distance =
                (RootPart.Position - enemyRoot.Position).Magnitude

            if distance < nearestDistance then
                nearestDistance = distance
                nearest = enemy
            end

        end
    end

    return nearest
end

--------------------------------------------------
-- AUTO TARGET
--------------------------------------------------

local function updateTarget()

    if not Settings.AutoTarget then
        CurrentTarget = nil
        return
    end

    CurrentTarget = getNearestEnemy()

end

--------------------------------------------------
-- AUTO ATTACK
--------------------------------------------------

local lastAttack = 0

local function autoAttack()

    if not Settings.AutoAttack then
        return
    end

    if not CurrentTarget then
        return
    end

    if not RootPart then
        return
    end

    local targetRoot =
        CurrentTarget:FindFirstChild("HumanoidRootPart")

    if not targetRoot then
        return
    end

    local distance =
        (RootPart.Position - targetRoot.Position).Magnitude

    if distance > Settings.TargetDistance then
        return
    end

    if os.clock() - lastAttack < Settings.AttackInterval then
        return
    end

    lastAttack = os.clock()

    --------------------------------------------------
    -- IMPORTANT:
    -- Replace this with your game's RemoteEvent
    --------------------------------------------------

    local combatRemote =
        game.ReplicatedStorage:FindFirstChild("CombatRemote")

    if combatRemote then
        combatRemote:FireServer("Attack", CurrentTarget)
    end

end

--------------------------------------------------
-- AUTO SKILL
--------------------------------------------------

local lastSkill = 0

local function autoSkill()

    if not Settings.AutoSkill then
        return
    end

    if not CurrentTarget then
        return
    end

    if os.clock() - lastSkill < Settings.SkillInterval then
        return
    end

    lastSkill = os.clock()

    local skillRemote =
        game.ReplicatedStorage:FindFirstChild("SkillRemote")

    if skillRemote then
        skillRemote:FireServer(
            "UseSkill",
            CurrentTarget
        )
    end

end

--------------------------------------------------
-- AUTO MOVEMENT
--------------------------------------------------

local function autoMovement()

    if not Settings.AutoMovement then
        return
    end

    if not RootPart or not Humanoid then
        return
    end

    if not CurrentTarget then
        return
    end

    local targetRoot =
        CurrentTarget:FindFirstChild("HumanoidRootPart")

    if not targetRoot then
        return
    end

    local direction =
        targetRoot.Position - RootPart.Position

    local distance = direction.Magnitude

    if distance > Settings.MovementDistance then

        Humanoid:MoveTo(
            targetRoot.Position
        )

    end

end

--------------------------------------------------
-- AUTO EQUIP BEST
--------------------------------------------------

local function autoEquipBest()

    if not Settings.AutoEquipBest then
        return
    end

    local inventory =
        player:FindFirstChild("Inventory")

    if not inventory then
        return
    end

    local bestItem = nil
    local bestPower = -math.huge

    for _, item in ipairs(inventory:GetChildren()) do

        local power =
            item:GetAttribute("Power")

        if power and power > bestPower then
            bestPower = power
            bestItem = item
        end

    end

    if bestItem then

        local equipRemote =
            game.ReplicatedStorage:FindFirstChild("EquipmentRemote")

        if equipRemote then
            equipRemote:FireServer(
                "Equip",
                bestItem
            )
        end

    end

end

--------------------------------------------------
-- AUTO LOOT
--------------------------------------------------

local function autoLoot()

    if not Settings.AutoLoot then
        return
    end

    if not RootPart then
        return
    end

    local lootFolder =
        workspace:FindFirstChild("Loot")

    if not lootFolder then
        return
    end

    for _, loot in ipairs(lootFolder:GetChildren()) do

        local lootPart =
            loot:FindFirstChildWhichIsA("BasePart")

        if lootPart then

            local distance =
                (RootPart.Position - lootPart.Position).Magnitude

            if distance <= 15 then

                local lootRemote =
                    game.ReplicatedStorage:FindFirstChild("LootRemote")

                if lootRemote then
                    lootRemote:FireServer(
                        "Collect",
                        loot
                    )
                end

            end
        end
    end

end

--------------------------------------------------
-- AUTO DODGE
--------------------------------------------------

local function autoDodge()

    if not Settings.AutoDodge then
        return
    end

    if not Character then
        return
    end

    local dodgeRemote =
        game.ReplicatedStorage:FindFirstChild("DodgeRemote")

    if dodgeRemote then
        dodgeRemote:FireServer()
    end

end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

local targetTimer = 0
local equipTimer = 0
local dodgeTimer = 0

RunService.Heartbeat:Connect(function()

    --------------------------------------------------
    -- TARGET
    --------------------------------------------------

    if os.clock() - targetTimer >= 0.25 then
        targetTimer = os.clock()
        updateTarget()
    end

    --------------------------------------------------
    -- COMBAT
    --------------------------------------------------

    autoAttack()
    autoSkill()

    --------------------------------------------------
    -- MOVEMENT
    --------------------------------------------------

    autoMovement()

    --------------------------------------------------
    -- LOOT
    --------------------------------------------------

    autoLoot()

    --------------------------------------------------
    -- EQUIPMENT
    --------------------------------------------------

    if os.clock() - equipTimer >= 3 then
        equipTimer = os.clock()
        autoEquipBest()
    end

    --------------------------------------------------
    -- DODGE
    --------------------------------------------------

    if os.clock() - dodgeTimer >= 1 then
        dodgeTimer = os.clock()
        autoDodge()
    end

end)

--------------------------------------------------
-- PUBLIC CONTROLLER
--------------------------------------------------

local Automation = {}

function Automation:Set(feature, enabled)

    if Settings[feature] ~= nil then
        Settings[feature] = enabled
    end

end

function Automation:Get(feature)

    return Settings[feature]

end

function Automation:GetTarget()

    return CurrentTarget

end

_G.Automation = Automation

print("Automation Controller Loaded")
