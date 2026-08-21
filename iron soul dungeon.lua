--[[
    Automation Controller (Delta Executor Ready)
    Optimized for Delta Mobile & PC
]]

-- Re-execution Cleanup (Purani script ko band karega agar dubara execute karein)
if getgenv().AutomationLoaded and getgenv().AutomationCleanup then
    pcall(getgenv().AutomationCleanup)
end
getgenv().AutomationLoaded = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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
    SkillInterval = 2.0,
    MovementDistance = 8,
    TargetDistance = 60
}

--------------------------------------------------
-- CHARACTER HANDLING
--------------------------------------------------
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid", 5)
local RootPart = Character:WaitForChild("HumanoidRootPart", 5)

local charConn = player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid", 5)
    RootPart = newChar:WaitForChild("HumanoidRootPart", 5)
end)

--------------------------------------------------
-- TARGET SYSTEM
--------------------------------------------------
local CurrentTarget = nil

local function getNearestEnemy()
    if not RootPart or not RootPart.Parent then return nil end

    local nearest = nil
    local nearestDistance = Settings.TargetDistance

    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs") or workspace:FindFirstChild("Monsters")
    local list = enemiesFolder and enemiesFolder:GetChildren() or workspace:GetChildren()

    for _, enemy in ipairs(list) do
        if enemy:IsA("Model") and enemy ~= Character then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
            local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")

            if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                local distance = (RootPart.Position - enemyRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearest = enemy
                end
            end
        end
    end

    return nearest
end

local function updateTarget()
    if not Settings.AutoTarget then
        CurrentTarget = nil
        return
    end
    CurrentTarget = getNearestEnemy()
end

--------------------------------------------------
-- COMBAT & SKILLS
--------------------------------------------------
local lastAttack = 0
local function autoAttack()
    if not Settings.AutoAttack or not CurrentTarget or not RootPart then return end

    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart") or CurrentTarget:FindFirstChild("Torso")
    if not targetRoot then return end

    local distance = (RootPart.Position - targetRoot.Position).Magnitude
    if distance > Settings.TargetDistance then return end

    if os.clock() - lastAttack < Settings.AttackInterval then return end
    lastAttack = os.clock()

    local combatRemote = ReplicatedStorage:FindFirstChild("CombatRemote") or ReplicatedStorage:FindFirstChild("Attack")
    if combatRemote and combatRemote:IsA("RemoteEvent") then
        pcall(function()
            combatRemote:FireServer("Attack", CurrentTarget)
        end)
    end
end

local lastSkill = 0
local function autoSkill()
    if not Settings.AutoSkill or not CurrentTarget then return end
    if os.clock() - lastSkill < Settings.SkillInterval then return end
    lastSkill = os.clock()

    local skillRemote = ReplicatedStorage:FindFirstChild("SkillRemote") or ReplicatedStorage:FindFirstChild("UseSkill")
    if skillRemote and skillRemote:IsA("RemoteEvent") then
        pcall(function()
            skillRemote:FireServer("UseSkill", CurrentTarget)
        end)
    end
end

--------------------------------------------------
-- MOVEMENT
--------------------------------------------------
local function autoMovement()
    if not Settings.AutoMovement or not RootPart or not Humanoid or not CurrentTarget then return end

    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart") or CurrentTarget:FindFirstChild("Torso")
    if not targetRoot then return end

    local distance = (targetRoot.Position - RootPart.Position).Magnitude
    if distance > Settings.MovementDistance then
        Humanoid:MoveTo(targetRoot.Position)
    end
end

--------------------------------------------------
-- AUTO EQUIP BEST
--------------------------------------------------
local function autoEquipBest()
    if not Settings.AutoEquipBest then return end

    local inventory = player:FindFirstChild("Inventory") or player:FindFirstChild("Backpack")
    if not inventory then return end

    local bestItem = nil
    local bestPower = -math.huge

    for _, item in ipairs(inventory:GetChildren()) do
        local power = item:GetAttribute("Power") or item:GetAttribute("Damage")
        if power and power > bestPower then
            bestPower = power
            bestItem = item
        end
    end

    if bestItem then
        local equipRemote = ReplicatedStorage:FindFirstChild("EquipmentRemote") or ReplicatedStorage:FindFirstChild("Equip")
        if equipRemote and equipRemote:IsA("RemoteEvent") then
            pcall(function()
                equipRemote:FireServer("Equip", bestItem)
            end)
        end
    end
end

--------------------------------------------------
-- AUTO LOOT & DODGE
--------------------------------------------------
local function autoLoot()
    if not Settings.AutoLoot or not RootPart then return end

    local lootFolder = workspace:FindFirstChild("Loot") or workspace:FindFirstChild("Drops")
    if not lootFolder then return end

    for _, loot in ipairs(lootFolder:GetChildren()) do
        local lootPart = loot:FindFirstChildWhichIsA("BasePart")
        if lootPart then
            local distance = (RootPart.Position - lootPart.Position).Magnitude
            if distance <= 20 then
                local lootRemote = ReplicatedStorage:FindFirstChild("LootRemote") or ReplicatedStorage:FindFirstChild("CollectLoot")
                if lootRemote and lootRemote:IsA("RemoteEvent") then
                    pcall(function()
                        lootRemote:FireServer("Collect", loot)
                    end)
                end
            end
        end
    end
end

local function autoDodge()
    if not Settings.AutoDodge or not Character then return end

    local dodgeRemote = ReplicatedStorage:FindFirstChild("DodgeRemote") or ReplicatedStorage:FindFirstChild("Dodge")
    if dodgeRemote and dodgeRemote:IsA("RemoteEvent") then
        pcall(function()
            dodgeRemote:FireServer()
        end)
    end
end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------
local targetTimer = 0
local equipTimer = 0
local dodgeTimer = 0

local heartbeatConn = RunService.Heartbeat:Connect(function()
    if os.clock() - targetTimer >= 0.25 then
        targetTimer = os.clock()
        updateTarget()
    end

    autoAttack()
    autoSkill()
    autoMovement()
    autoLoot()

    if os.clock() - equipTimer >= 3 then
        equipTimer = os.clock()
        autoEquipBest()
    end

    if os.clock() - dodgeTimer >= 1 then
        dodgeTimer = os.clock()
        autoDodge()
    end
end)

-- Cleanup function
getgenv().AutomationCleanup = function()
    if heartbeatConn then heartbeatConn:Disconnect() end
    if charConn then charConn:Disconnect() end
end

--------------------------------------------------
-- DELTA MOBILE FRIENDLY UI (Rayfield Library)
--------------------------------------------------
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if success and Rayfield then
    local Window = Rayfield:CreateWindow({
       Name = "⚡ Automation Hub | Delta",
       LoadingTitle = "Delta Controller",
       LoadingSubtitle = "by AutoScript",
       ConfigurationSaving = {
          Enabled = false
       },
       KeySystem = false
    })

    local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
    local MoveTab = Window:CreateTab("🏃 Movement & Loot", 4483362458)

    CombatTab:CreateToggle({
       Name = "Auto Target (Nearest Enemy)",
       CurrentValue = Settings.AutoTarget,
       Flag = "AutoTarget",
       Callback = function(Value)
           Settings.AutoTarget = Value
       end,
    })

    CombatTab:CreateToggle({
       Name = "Auto Attack",
       CurrentValue = Settings.AutoAttack,
       Flag = "AutoAttack",
       Callback = function(Value)
           Settings.AutoAttack = Value
       end,
    })

    CombatTab:CreateToggle({
       Name = "Auto Skill",
       CurrentValue = Settings.AutoSkill,
       Flag = "AutoSkill",
       Callback = function(Value)
           Settings.AutoSkill = Value
       end,
    })

    CombatTab:CreateToggle({
       Name = "Auto Dodge",
       CurrentValue = Settings.AutoDodge,
       Flag = "AutoDodge",
       Callback = function(Value)
           Settings.AutoDodge = Value
       end,
    })

    CombatTab:CreateSlider({
       Name = "Target Distance",
       Range = {10, 150},
       Increment = 5,
       Suffix = " Studs",
       CurrentValue = Settings.TargetDistance,
       Flag = "TargetDist",
       Callback = function(Value)
           Settings.TargetDistance = Value
       end,
    })

    MoveTab:CreateToggle({
       Name = "Auto Follow Target",
       CurrentValue = Settings.AutoMovement,
       Flag = "AutoMove",
       Callback = function(Value)
           Settings.AutoMovement = Value
       end,
    })

    MoveTab:CreateToggle({
       Name = "Auto Loot",
       CurrentValue = Settings.AutoLoot,
       Flag = "AutoLoot",
       Callback = function(Value)
           Settings.AutoLoot = Value
       end,
    })

    MoveTab:CreateToggle({
       Name = "Auto Equip Best Weapon",
       CurrentValue = Settings.AutoEquipBest,
       Flag = "AutoEquip",
       Callback = function(Value)
           Settings.AutoEquipBest = Value
       end,
    })

    Rayfield:Notify({
       Title = "Automation Loaded",
       Content = "Delta Executor ke sath script load ho chuki hai!",
       Duration = 5,
       Image = 4483362458,
    })
else
    -- Fallback simple ScreenGui if Rayfield fails
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaFallbackGUI"
    ScreenGui.Parent = game.CoreGui or player:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 180, 0, 200)
    Frame.Position = UDim2.new(0, 20, 0.3, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "⚡ Delta Auto Hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Title.Parent = Frame

    local function makeButton(text, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 30)
        btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.Text = text .. ": OFF"
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = Frame
        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = text .. (state and ": ON" or ": OFF")
            btn.BackgroundColor3 = state and Color3.fromRGB(40, 180, 70) or Color3.fromRGB(60, 60, 70)
            callback(state)
        end)
    end

    makeButton("Auto Attack", 40, function(s) Settings.AutoAttack = s Settings.AutoTarget = s end)
    makeButton("Auto Skill", 80, function(s) Settings.AutoSkill = s end)
    makeButton("Auto Follow", 120, function(s) Settings.AutoMovement = s end)
    makeButton("Auto Loot", 160, function(s) Settings.AutoLoot = s end)
end
