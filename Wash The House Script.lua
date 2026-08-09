-- =======================================================
-- ALL-IN-ONE ROBLOX STUDIO DEV & DEBUG PANEL (SINGLE SCRIPT)
-- =======================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Create Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WashHouseControlPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Main Resizable Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 360)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- 3. Draggable Header / TopBar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = Color3.fromRGB(36, 42, 56)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "🧹 WASH THE HOUSE - All-in-One Panel"
title.Size = UDim2.new(1, -15, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.Parent = topBar

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- 4. Resizable Handle (Bottom Right Corner)
local resizeGrip = Instance.new("TextLabel")
resizeGrip.Name = "ResizeGrip"
resizeGrip.Text = "◢"
resizeGrip.Size = UDim2.new(0, 22, 0, 22)
resizeGrip.Position = UDim2.new(1, -22, 1, -22)
resizeGrip.TextColor3 = Color3.fromRGB(160, 160, 160)
resizeGrip.BackgroundTransparency = 1
resizeGrip.TextSize = 14
resizeGrip.ZIndex = 10
resizeGrip.Parent = mainFrame

local resizing, resizeStart, startSize
resizeGrip.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		resizeStart = input.Position
		startSize = mainFrame.Size
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - resizeStart
		local newX = math.max(260, startSize.X.Offset + delta.X)
		local newY = math.max(200, startSize.Y.Offset + delta.Y)
		mainFrame.Size = UDim2.new(0, newX, 0, newY)
	end
end)

-- 5. Scrolling Frame for Features List
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "FeatureScroll"
scroll.Size = UDim2.new(1, -20, 1, -55)
scroll.Position = UDim2.new(0, 10, 0, 48)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0, 0, 0, 360) -- Dynamic height for scrolling
scroll.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 8)
uiList.Parent = scroll

-- Helper Function to Create Styled Buttons
local function createButton(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -8, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(44, 52, 68)
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.Font = Enum.Font.SourceSansSemibold
	btn.TextSize = 15
	btn.Text = text
	btn.Parent = scroll

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		callback(btn)
	end)

	return btn
end

-- =======================================================
-- FEATURES LOGIC
-- =======================================================

-- 1. Auto Clean Toggle
local autoClean = false
createButton("⚡ Toggle Auto Clean: OFF", function(btn)
	autoClean = not autoClean
	if autoClean then
		btn.Text = "⚡ Toggle Auto Clean: ON"
		btn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
	else
		btn.Text = "⚡ Toggle Auto Clean: OFF"
		btn.BackgroundColor3 = Color3.fromRGB(44, 52, 68)
	end
end)

RunService.RenderStepped:Connect(function()
	if autoClean then
		local houseDirt = workspace:FindFirstChild("HouseDirt")
		local events = ReplicatedStorage:FindFirstChild("WashEvents")
		local cleanEvent = events and events:FindFirstChild("CleanDirt")

		if houseDirt and cleanEvent then
			for _, part in ipairs(houseDirt:GetDescendants()) do
				if part:IsA("BasePart") and part:FindFirstChild("DirtHealth") and part.DirtHealth.Value > 0 then
					cleanEvent:FireServer(part)
					break
				end
			end
		end
	end
end)

-- 2. Fast Player Speed
local fastSpeed = false
createButton("🚀 Toggle Fast Speed (Speed x3)", function(btn)
	fastSpeed = not fastSpeed
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = fastSpeed and 48 or 16
		btn.BackgroundColor3 = fastSpeed and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(44, 52, 68)
	end
end)

-- 3. Infinite Spray Range
createButton("🎯 Set Infinite Washer Range", function(btn)
	local stats = player:FindFirstChild("PlayerStats")
	if stats and stats:FindFirstChild("WasherRange") then
		stats.WasherRange.Value = 99999
		btn.Text = "🎯 Washer Range: INFINITE ✅"
		btn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
	end
end)

-- 4. Max Washer Power
createButton("💥 Set Max Washer Power", function(btn)
	local stats = player:FindFirstChild("PlayerStats")
	if stats and stats:FindFirstChild("WasherPower") then
		stats.WasherPower.Value = 1000
		btn.Text = "💥 Washer Power: 1000 MAX ✅"
		btn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
	end
end)

-- 5. Give Cash
createButton("💰 Give +1,000 Cash", function(btn)
	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Cash") then
		player.leaderstats.Cash.Value = player.leaderstats.Cash.Value + 1000
	end
end)

-- 6. Reset All House Dirt
createButton("🔄 Reset & Respawn All Dirt", function(btn)
	local houseDirt = workspace:FindFirstChild("HouseDirt")
	if houseDirt then
		for _, part in ipairs(houseDirt:GetDescendants()) do
			if part:IsA("BasePart") and part:FindFirstChild("DirtHealth") then
				part.DirtHealth.Value = part:FindFirstChild("MaxDirtHealth") and part.MaxDirtHealth.Value or 100
				part.Transparency = 0
				part.CanCollide = true
			end
		end
	end
end)
