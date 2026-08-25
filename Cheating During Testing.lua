-- ===================================================================
-- MDScripts - Enhanced Controller for "Cheating During Testing"
-- Compatible with Delta, Arceus X, Fluxus, Codex, Synapse, KRNL
-- ===================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cleanup old instance
if CoreGui:FindFirstChild("MDScripts_CheatingTesting") then
    CoreGui.MDScripts_CheatingTesting:Destroy()
elseif LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MDScripts_CheatingTesting") then
    LocalPlayer.PlayerGui.MDScripts_CheatingTesting:Destroy()
end

-- Safely Parent ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MDScripts_CheatingTesting"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ===================================================================
-- Alert Warning Banner
-- ===================================================================
local AlertBanner = Instance.new("Frame")
AlertBanner.Name = "AlertBanner"
AlertBanner.Size = UDim2.new(0, 260, 0, 38)
AlertBanner.Position = UDim2.new(0.5, -130, 0, 25)
AlertBanner.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
AlertBanner.Visible = false
AlertBanner.Parent = ScreenGui

local AlertCorner = Instance.new("UICorner")
AlertCorner.CornerRadius = UDim.new(0, 8)
AlertCorner.Parent = AlertBanner

local AlertStroke = Instance.new("UIStroke")
AlertStroke.Color = Color3.fromRGB(255, 45, 45)
AlertStroke.Thickness = 2
AlertStroke.Parent = AlertBanner

local AlertText = Instance.new("TextLabel")
AlertText.Name = "AlertText"
AlertText.Size = UDim2.new(1, 0, 1, 0)
AlertText.BackgroundTransparency = 1
AlertText.Text = "⚠️ TEACHER IS LOOKING!"
AlertText.TextColor3 = Color3.fromRGB(255, 70, 70)
AlertText.Font = Enum.Font.FredokaOne
AlertText.TextSize = 14
AlertText.Parent = AlertBanner

-- ===================================================================
-- Main Control Window
-- ===================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainHub"
MainFrame.Size = UDim2.new(0, 270, 0, 280)
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MDSCRIPTS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Container
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 0, 185)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Container

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, -20, 0, 28)
Footer.Position = UDim2.new(0, 12, 1, -30)
Footer.BackgroundTransparency = 1
Footer.Text = "MDScripts | Testing Assistant"
Footer.TextColor3 = Color3.fromRGB(140, 140, 150)
Footer.Font = Enum.Font.FredokaOne
Footer.TextSize = 12
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.Parent = MainFrame

-- ===================================================================
-- State & Toggle Builder
-- ===================================================================
local Features = {
    ["Auto Answer"] = false,
    ["Teacher ESP"] = false,
    ["Teacher Looking Alert"] = false,
    ["Auto Reduce Anxiety"] = false
}

local function CreateToggle(name, defaultState, callback)
    Features[name] = defaultState or false

    local ToggleRow = Instance.new("Frame")
    ToggleRow.Name = name .. "_Row"
    ToggleRow.Size = UDim2.new(1, 0, 0, 36)
    ToggleRow.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    ToggleRow.BorderSizePixel = 0
    ToggleRow.Parent = Container

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = ToggleRow

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(240, 240, 245)
    Label.TextSize = 14
    Label.Font = Enum.Font.FredokaOne
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleRow

    local CheckBox = Instance.new("TextButton")
    CheckBox.Name = "CheckBox"
    CheckBox.Size = UDim2.new(0, 22, 0, 22)
    CheckBox.Position = UDim2.new(1, -32, 0.5, -11)
    CheckBox.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    CheckBox.Text = ""
    CheckBox.BorderSizePixel = 0
    CheckBox.AutoButtonColor = false
    CheckBox.Parent = ToggleRow

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 5)
    CheckCorner.Parent = CheckBox

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = Color3.fromRGB(70, 70, 80)
    CheckStroke.Thickness = 1.8
    CheckStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    CheckStroke.Parent = CheckBox

    local CheckIcon = Instance.new("TextLabel")
    CheckIcon.Name = "CheckIcon"
    CheckIcon.Size = UDim2.new(1, 0, 1, 0)
    CheckIcon.BackgroundTransparency = 1
    CheckIcon.Text = "✓"
    CheckIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    CheckIcon.TextSize = 14
    CheckIcon.Font = Enum.Font.GothamBold
    CheckIcon.TextTransparency = Features[name] and 0 or 1
    CheckIcon.Parent = CheckBox

    local function ToggleState()
        Features[name] = not Features[name]
        local isEnabled = Features[name]

        local targetColor = isEnabled and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(32, 32, 38)
        local targetStroke = isEnabled and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(70, 70, 80)
        local targetTransparency = isEnabled and 0 or 1

        TweenService:Create(CheckBox, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetColor
        }):Play()

        TweenService:Create(CheckStroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Color = targetStroke
        }):Play()

        TweenService:Create(CheckIcon, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = targetTransparency
        }):Play()

        if callback then
            task.spawn(function()
                callback(isEnabled)
            end)
        end
    end

    CheckBox.MouseButton1Click:Connect(ToggleState)

    local RowClick = Instance.new("TextButton")
    RowClick.Size = UDim2.new(1, -45, 1, 0)
    RowClick.BackgroundTransparency = 1
    RowClick.Text = ""
    RowClick.Parent = ToggleRow
    RowClick.MouseButton1Click:Connect(ToggleState)

    return ToggleRow
end

-- ===================================================================
-- Robust Teacher NPC Finder
-- ===================================================================
local function GetTeacherModel()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local isRealPlayer = false
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character == obj then
                    isRealPlayer = true
                    break
                end
            end

            if not isRealPlayer then
                local n = string.lower(obj.Name)
                if string.find(n, "teach") or string.find(n, "instruct") or string.find(n, "prof") or string.find(n, "mr") or string.find(n, "miss") or string.find(n, "mrs") or string.find(n, "npc") then
                    return obj
                end
            end
        end
    end

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and (obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart")) then
            local isRealPlayer = false
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character == obj then
                    isRealPlayer = true
                    break
                end
            end
            if not isRealPlayer then
                return obj
            end
        end
    end

    return nil
end

-- ===================================================================
-- 1. Teacher ESP Implementation
-- ===================================================================
local currentHighlight = nil
local currentBillboard = nil

local function UpdateESP(enabled)
    if not enabled then
        if currentHighlight then currentHighlight:Destroy() currentHighlight = nil end
        if currentBillboard then currentBillboard:Destroy() currentBillboard = nil end
        return
    end

    task.spawn(function()
        while Features["Teacher ESP"] do
            local teacher = GetTeacherModel()
            if teacher and (teacher:FindFirstChild("HumanoidRootPart") or teacher:FindFirstChild("Head")) then
                local targetPart = teacher:FindFirstChild("HumanoidRootPart") or teacher:FindFirstChild("Head")
                
                if not currentHighlight or currentHighlight.Parent ~= teacher then
                    if currentHighlight then currentHighlight:Destroy() end
                    currentHighlight = Instance.new("Highlight")
                    currentHighlight.Name = "MD_TeacherHighlight"
                    currentHighlight.FillColor = Color3.fromRGB(255, 50, 50)
                    currentHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    currentHighlight.FillTransparency = 0.4
                    currentHighlight.OutlineTransparency = 0.1
                    currentHighlight.Parent = teacher
                end

                if not currentBillboard or currentBillboard.Parent ~= targetPart then
                    if currentBillboard then currentBillboard:Destroy() end
                    currentBillboard = Instance.new("BillboardGui")
                    currentBillboard.Name = "MD_TeacherTag"
                    currentBillboard.Adornee = targetPart
                    currentBillboard.Size = UDim2.new(0, 140, 0, 40)
                    currentBillboard.StudsOffset = Vector3.new(0, 3.5, 0)
                    currentBillboard.AlwaysOnTop = true

                    local tagLabel = Instance.new("TextLabel")
                    tagLabel.Name = "TagLabel"
                    tagLabel.Size = UDim2.new(1, 0, 1, 0)
                    tagLabel.BackgroundTransparency = 1
                    tagLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
                    tagLabel.Font = Enum.Font.FredokaOne
                    tagLabel.TextSize = 14
                    tagLabel.TextStrokeTransparency = 0.2
                    tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    tagLabel.Parent = currentBillboard

                    currentBillboard.Parent = targetPart
                end

                if currentBillboard and currentBillboard:FindFirstChild("TagLabel") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((targetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    currentBillboard.TagLabel.Text = "👩‍🏫 TEACHER [" .. tostring(dist) .. "m]"
                end
            else
                if currentHighlight then currentHighlight:Destroy() currentHighlight = nil end
                if currentBillboard then currentBillboard:Destroy() currentBillboard = nil end
            end
            task.wait(0.2)
        end
        if currentHighlight then currentHighlight:Destroy() currentHighlight = nil end
        if currentBillboard then currentBillboard:Destroy() currentBillboard = nil end
    end)
end

-- ===================================================================
-- 2. Teacher Looking Alert (Angle + Line of Sight)
-- ===================================================================
local function UpdateLookingAlert(enabled)
    if not enabled then
        AlertBanner.Visible = false
        return
    end

    task.spawn(function()
        while Features["Teacher Looking Alert"] do
            local teacher = GetTeacherModel()
            local myChar = LocalPlayer.Character

            if teacher and myChar and teacher:FindFirstChild("Head") and myChar:FindFirstChild("HumanoidRootPart") then
                local teacherHead = teacher.Head
                local myPos = myChar.HumanoidRootPart.Position
                local teacherPos = teacherHead.Position

                local dirToMe = (myPos - teacherPos).Unit
                local teacherLook = teacherHead.CFrame.LookVector

                local dot = teacherLook:Dot(dirToMe)
                local distance = (myPos - teacherPos).Magnitude

                if dot > 0.45 and distance < 75 then
                    AlertBanner.Visible = true
                    AlertText.Text = "⚠️ TEACHER IS LOOKING! (" .. math.floor(distance) .. "m)"
                else
                    AlertBanner.Visible = false
                end
            else
                AlertBanner.Visible = false
            end
            task.wait(0.1)
        end
        AlertBanner.Visible = false
    end)
end

-- ===================================================================
-- Helper: Click / Fill Answer Sheet Bubble
-- ===================================================================
local function ClickBubble(button)
    pcall(function()
        if firesignal then
            firesignal(button.MouseButton1Down)
            firesignal(button.MouseButton1Click)
            firesignal(button.Activated)
        end

        if VirtualInputManager and button.AbsoluteSize.X > 0 then
            local pos = button.AbsolutePosition
            local size = button.AbsoluteSize
            local clickX = pos.X + size.X / 2
            local clickY = pos.Y + size.Y / 2

            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
        end

        if button.MouseButton1Click then
            button.MouseButton1Click:Fire()
        end
    end)
end

-- ===================================================================
-- 3. Auto Answer (100% Comprehensive Bubble Solver)
-- ===================================================================
local function UpdateAutoAnswer(enabled)
    if not enabled then return end

    task.spawn(function()
        while Features["Auto Answer"] do
            task.wait(0.25)
            pcall(function()
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if not pGui then return end

                local foundSheet = false
                for _, g in ipairs(pGui:GetDescendants()) do
                    if g:IsA("TextLabel") or g:IsA("TextButton") then
                        if string.find(string.lower(g.Text), "answer sheet") or string.find(string.lower(g.Name), "answersheet") then
                            foundSheet = true
                            break
                        end
                    end
                end

                if not foundSheet and VirtualInputManager then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                    task.wait(0.3)
                end

                for _, obj in ipairs(pGui:GetDescendants()) do
                    if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                        local btnText = obj:IsA("TextButton") and string.upper(string.gsub(obj.Text, "%s+", "")) or ""
                        local btnName = string.upper(obj.Name)

                        local isA = (btnText == "A") or (btnName == "A") or string.find(btnName, "OPTIONA") or string.find(btnName, "BUBBLEA") or string.find(btnName, "BUTTONA") or string.find(btnName, "CHOICE1") or string.find(btnName, "ANS1")

                        if isA then
                            local isFilled = false
                            if obj.BackgroundColor3 == Color3.fromRGB(0, 0, 0) or obj.BackgroundColor3 == Color3.fromRGB(20, 20, 20) then
                                isFilled = true
                            end

                            if not isFilled then
                                ClickBubble(obj)
                                task.wait(0.04)
                            end
                        end
                    end
                end

                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            prompt:InputHoldBegin()
                            task.wait(prompt.HoldDuration or 0.1)
                            prompt:InputHoldEnd()
                        end
                    end
                end
            end)
        end
    end)
end

-- ===================================================================
-- 4. Auto Reduce Anxiety (Equip Pencil & Auto Focus)
-- ===================================================================
local function UpdateReduceAnxiety(enabled)
    if not enabled then return end

    task.spawn(function()
        while Features["Auto Reduce Anxiety"] do
            task.wait(0.3)
            pcall(function()
                local char = LocalPlayer.Character
                local backpack = LocalPlayer:FindFirstChild("Backpack")

                if char and char:FindFirstChildOfClass("Humanoid") then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")

                    local pencil = (backpack and (backpack:FindFirstChild("Pencil") or backpack:FindFirstChild("pencil"))) or (char:FindFirstChild("Pencil") or char:FindFirstChild("pencil"))

                    if pencil then
                        if pencil.Parent == backpack then
                            humanoid:EquipTool(pencil)
                        end
                        pencil:Activate()
                    end

                    if VirtualUser then
                        VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    end
                end
            end)
        end
    end)
end

-- ===================================================================
-- Register Toggles
-- ===================================================================
CreateToggle("Auto Answer", false, UpdateAutoAnswer)
CreateToggle("Teacher ESP", false, UpdateESP)
CreateToggle("Teacher Looking Alert", false, UpdateLookingAlert)
CreateToggle("Auto Reduce Anxiety", false, UpdateReduceAnxiety)

-- ===================================================================
-- Draggable UI (PC & Mobile Support)
-- ===================================================================
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

print("[MDScripts] Fully Loaded & Initialized for Cheating During Testing!")
